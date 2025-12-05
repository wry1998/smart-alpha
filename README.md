# Smart Alpha Portfolio Selection Model

## Overview

This repository contains my Master's project, where I implement and study the portfolio selection algorithm introduced in [Boucher et al., 2021](#boucher2021)

The Smart Alpha strategy is applied to the **European stock market (STOXX600)** from **2015-01-01 to 2021-12-31**.  
The main goal of this project is to investigate how **sparsity levels** and other **hyper-parameters** affect portfolio performance and risk characteristics.

---

## Methodology
Capital Asset Pricing Mondel: 

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

## Implementation

Optimal number of latent factors is estimated by:

Latent factors are estimated by sparse-PCA via a hard-thresholding:

Optimaization program is solved using [Gurobi R interface](https://www.gurobi.com/documentation/9.5/refman/r_api_overview.html).


The algorithm is implemented in R, and then applied to the European stock market on a **rolling-window scheme**:
- Stock Universe: constituents of the **STOXX Europe 600** index, with ticker scrapped from DividendMax and data downloaded from python library [`yfinance`](https://pypi.org/project/yfinance/).
- Use daily returns from 2015-01 to 2021-12.
- Window length is 13 months (12 months for training and 1 month for out-of-sample testing), each iteration moves forward by 1 month.

---

## Empirical Findings



---

## Repository Structure

---

## Original Paper
<a id="boucher2021"></a>
**Boucher, C., Jasinski, A., Kouontchou, P., & Tokpavi, S. (2021).##
Smart Alpha: active management with unstable and latent factors.
*Quantitative Finance, 21(6), 893–909.*

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
