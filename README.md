# Smart Alpha Portfolio Selection Model

## Overview

This repository contains my Master's project, where I implement and study the portfolio selection algorithm introduced in:

> C. Boucher, “Smart Alpha: active management with unstable and latent factors”, *Quantitative Finance*, 2021.

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

And the dynamic factors are estimated using a sparse-PCA algorithm initially introduced by:

> Zhou. H.

and refined by:

> Wu. M.-C

with the optimal number of latent factors, $m$, chosen using 

---

## Implementation

The algorithm to compute 



---

## Empirical Findings



---

## Repository Structure

