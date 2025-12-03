# Smart Alpha Portfolio Selection Model

## Overview

This repository contains my Master's project, where I implement and study the portfolio selection algorithm introduced in:

> C. Boucher, “Smart Alpha: active management with unstable and latent factors”, *Quantitative Finance*, 2021.

The Smart Alpha strategy is applied to the **European stock market (STOXX600)** from **2015-01-01 to 2021-12-31**.  
The main goal of this project is to investigate how **sparsity levels** and other **hyper-parameters** affect portfolio performance and risk characteristics.

---

## Methodology

### 1. Portfolio optimization problem

The core idea of the Smart Alpha approach is to construct a portfolio that:

- **Minimises exposure to systematic (factor) risk**, while  
- **Achieving a target level of alpha**, and  
- **Preserving diversification** through an upper bound on single-stock weights.

Formally, the weights \(w \in \mathbb{R}^N\) solve:

\[
\begin{aligned}
\min_{w} \quad & w' \Sigma_S w \\
\text{s.t.} \quad 
& w' \alpha \ge \varepsilon, \\
& w' \mathbf{1} = 1, \\
& 0 \le w_i \le \bar w \quad \forall i,
\end{aligned}
\]

where

- \(\Sigma_S\) is the **systematic covariance matrix**,
- \(\alpha\) is the vector of **stock alphas**, and  
- \(\varepsilon\) is the **alpha lower bound**.

In CAPM notation, the actual expected return of asset \(i\) can be decomposed as:

\[
\mathbb{E}[r_i]^{\text{actual}} 
= \alpha_i + \mathbb{E}[r_i]^{\text{CAPM}}
= \alpha_i + r_f + \beta_i \left(\mathbb{E}[r_M] - r_f\right),
\]

so the optimisation explicitly **controls alpha** instead of relying on the traditional “smart beta” idea of simply picking low-beta portfolios and letting alpha be realised implicitly through the beta–alpha relation.

---
