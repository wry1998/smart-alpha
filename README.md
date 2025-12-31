# Smart Alpha Portfolio Selection Model

## Overview

This repository contains my Master's project, where I implement and study the portfolio selection algorithm introduced in [Boucher et al., 2021](#boucher2021)

The Smart Alpha strategy is applied to the **European stock market (STOXX600)** from **2015-01-01 to 2021-12-31**.  
The main goal of this project is to investigate how **sparsity levels** and other **hyper-parameters** affect portfolio performance and risk characteristics.

---

## Methodology
Capital Asset Pricing Model: 

$$
\mathbb{E}[r]^{\text{actual}} 
= \alpha + \mathbb{E}[r]^{\text{CAPM}}
= \alpha + r_f + \beta \left(\mathbb{E}[r_M] - r_f\right)
$$

The core idea of the Smart Alpha approach is to construct a portfolio that:

- **Minimises exposure to systematic risk ($\beta$)**, while  
- **Achieving a target level of $\alpha$**, and  
- **Preserving diversification** through an upper bound on single-stock weights.

The optimization program is written as follows:

$$
\begin{aligned}
\min_{w} \quad & w' \Sigma_S w \\
\text{u.c.} \quad 
& w' \alpha \ge \varepsilon, \\
& w' \mathbf{1} = 1, \\
& 0 \le w_i \le \bar w \quad \forall i,
\end{aligned}
$$

where

- $w$ is the vector of **stock weights**
- $\Sigma_S$ is the **systematic covariance matrix**,
- $\alpha$ is the vector of **stock alpha's**, and  
- $\epsilon$ and $\bar w$ are the hyper-parameters representing **alpha lower bound** and **weight upper bound**.

Dynamic factor model is used for asset pricing. At time $t$, the stocks' returns are written as:

$$r_t = \Lambda F_t + e_t,$$

where 

- $F_t$ is the vector of **dynamic factors**,
- $\Lambda$ is the matrix of **factor loadings**, and
- $e_t$ is the vector of **residuals**.

Thus, we have for $\Sigma_S$ and $\alpha$:

$$\Sigma_S = \Lambda \Sigma_F \Lambda',$$

$$\alpha = \mathbb{E}[e_t] = \mathbb{E}[r_t] - \Lambda \bar{F},$$

And the dynamic factors are estimated using a sparse-PCA algorithm which was initially introduced by [Zou et al., 2006](#zou-2006) and refined by [Wu & Chen, 2016](#wu-chen-2016), while the optimal number of latent factors, $m$, is chosen using the information criteria introduced in [Bai & Ng, 2002](#bai-ng-2002):

$$
IC(k) = \ln\bigl( V(k,\hat F(k)) \bigr) + k  \frac{N + T}{N T} \ln\bigl( C_{TN}^2 \bigr).
$$

where

- $V(k,\hat F(k)) = \frac{1}{TN} \sum_{i=1}^N \sum_{t=1}^T \hat e_{it}^2,$
- $C_{TN} = \min(\sqrt{N}, \sqrt{T}),$ and
- $i=1,...,N$ specifies $N$ stocks , $t=1,...,T$ specifies $T$ returns.

Choose the $k$ that minimizes $IC(k)$ to be the estimate of $m$.

---

## Algorithm & Implementation

Optimal number of latent factors, $m$, is estimated as follows:

```text
Input:
- R: T × N return matrix (N stocks, T daily returns)
- mmax: an interger specify the upper bound of m

Algorithm:
(U,V,D) <-- svd(R,mmax)
LC <-- a null vector of length mmax-1
FOR k = 2,...,mmax DO:
    (U_m,V_m,D_m) <-- first m components of the SVD decomposition of R
    F <-- normalized(U_m %*% D_m)
    Lambda <-- (R' %*% F)/T
    E <-- R - F %*% Lambda'
    V <-- sum(E_tn^2)/(TN)
    IC[k-1] <-- ln(V)+k(N+T)/(NT)ln(min{sqrt(N),sqrt(T)})
END
m_optimal <- m such that the corresponding IC is minimized

Output: m_optimal
```

For a given $m$, Latent factors are estimated by sparse-PCA via a hard-thresholding, and the $\alpha$ and $\Sigma_S$ in the optimization problem follows:

```text
Input:
- R: T × N return matrix
- m: number of sparse principal components
- rho: hard threshold chosen between (0,1) to decided if 2 stocks are correlated

Algorithm:
FOR i=1,...,N; j=1,...N DO
    H[ij] <-- IF cor(R[i],R[j]) >= rho THEN 1 ELSE 0
END
UPDATE H <-- rearrange columns (h_1,...,h_N) such that var(h_1) >= ... >= var(h_N)
(U,V,D) <-- svd(R,m)  
(a_1,...a_m) <-- V
REPEAT until convergence:
    FOR j = 1, ...,m Do
        D_j <-- diag(h_j,N)   ## use jth column of H to construct diagonal matrix 
        b_j = D_j %*% R' %*% R %*% a_j
    END
    UPDATE B <-- (b_1,...,b_m)
    X <-- R' %*% R %*% B
    UPDATE (U,V,D) <-- svd(X,m) 
    UPDATE (a_1,...a_m) <-- U %*% V'
END
Lambda <-- (norm(b_1),...,norm(b_m))
F <-- R %*% Lambda
Cov_S <-- Lambda %*% cov(F) %*% Lambda'
Alpha <-- mean(R) - mean(F) %*% Lambda'

Output: Cov_s, Alpha
```

Given $\alpha$ and $\Sigma_S$, the optimized weights are solved using [Gurobi R interface](https://www.gurobi.com/documentation/9.5/refman/r_api_overview.html).

The above portfolio selection algorithm is implemented in R, and then applied to the European stock market on a **rolling-window scheme**:
- Stock Universe: constituents of the **STOXX Europe 600** index, with ticker scrapped from DividendMax and data downloaded from python library [`yfinance`](https://pypi.org/project/yfinance/).
- Use daily returns from 2015-01 to 2021-12.
- Window length is 13 months (12 months for training and 1 month for out-of-sample testing), each iteration moves forward by 1 month.

---

## Empirical Findings

Portfolio is evaluated considering: **return**, **volatility**, **Sharpe ratio**, **drawdown in crash periods**, **beta**, **alpha**, **residual risk**, **excess return**, and **appraisal ratio**. Followed [Boucher et al., 2021](#boucher2021),I reproduced the main empiracal results with some additional robustness checks and extensions:

- The optimal number of dynamic factors is typically **2–4**, and this number tends to **increase at the beginning of crisis periods**.
- **Sparse-PCA** produces significantly better dynamic factors than standard PCA in this setting, although it is more computationally expensive.
- Sparsity, jointly controlled by the **number of factors** and the **hard-thresholding level**, has a **non-monotonic** effect on performance: as sparsity increases, performance firstly decreases, then improves and reaches to maximum, and finally deteriorates again when the model becomes too sparse.
- A “greedy” choice of a high alpha lower bound $\varepsilon$ can lead to **lower realised alpha** out of sample. In my experiments, the best portfolios are often obtained when **alpha is left unconstrained or only mildly constrained**.

---

## Repository Structure

```text
.
├── 01_python/                     # Data download
│   ├── 01_scrap_ticker.py         # Scrap STOXX600 component stocks' ticker and exchange
│   └── 02_download_data.py        # Download STOXX600 price data via yfinance
│
├── 02_R/                          # R implementation of the Smart Alpha model
│   ├── 01_SPCA&PCA.R              # Choice of dynamic factor number, sparse-PCA/PCA process of selecting dynamic factors
│   ├── 02_main_function.R         # Iteratively compute smart-alpha portfolio and evaluate it's performance on a rolling window process
│   └── 03_emprical_result.R       # Load data and generate results
│
├── 03_data/                       # Data folder
│   ├── raw_data/                  # Examples of raw stock data
│   ├── settle_list.csv            # Exchange
│   └── ticker_list.csv            # Ticker
│
├── 04_report/                       
│   └── report.pdf                 # Final report
│
├── .gitignore                     # Ignore rules for R history, etc.
└── README.md
```

Note, Due to data size, I do **not** distribute the full dataset in this repository. Instead, I provide:

- A list of STOXX600 tickers and exchanges,
- A small example return panel to illustrate the required input format, and
- A Python script that downloads price data from Yahoo Finance using `yfinance`.
  
Users can reproduce or extend my empirical analysis by running the program files in order with their preferred sample period.

---

## References

<a id="boucher2021"></a>
**Boucher, C., Jasinski, A., Kouontchou, P., & Tokpavi, S. (2021).**  
Smart Alpha: active management with unstable and latent factors.  
*Quantitative Finance*, 21(6), 893–909.

<a id="zou-2006"></a>
**Zou, H., Hastie, T., & Tibshirani, R. (2006).**  
Sparse principal component analysis.  
*Journal of Computational and Graphical Statistics*, 15(2), 265–286.

<a id="wu-chen-2016"></a>
**Wu, M.-C., & Chen, K.-C. (2016).**  
Sparse PCA via hard thresholding for blind source separation.  
In *IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP 2016)*.

<a id="bai-ng-2002"></a>
**Bai, J., & Ng, S. (2002).**  
Determining the number of factors in approximate factor models.  
*Econometrica*, 70(1), 191–221.

---
*For an overview of my research projects, see my [research portfolio](https://github.com/wry1998/research-portfolio).*
