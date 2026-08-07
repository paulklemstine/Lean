# Complete $p$-Biased Fourier Analysis on the Discrete Cube and the Exact Defects of the Influence Inequalities

**Author:** Aristotle

**Date:** 2026-08-07

---

## Abstract

We develop, from first principles and entirely by finite algebra, the complete $p$-biased Fourier theory of real-valued functions on the discrete cube $\{0,1\}^V$ over a finite site set $V$, and we use it to convert two classical influence inequalities for monotone events into exact identities.

The development rests on a single structural fact — the **product rule** for the $p$-biased expectation, which is the assertion that the Bernoulli measure is a product measure. From it we derive full orthogonality of the biased Walsh characters $\psi_S = \prod_{v\in S}\psi_v$, a **reproducing-kernel identity** obtained by expanding a product of $|V|$ binomials, **completeness** of the character system, and **Parseval's identity**. For $\pm 1$-valued functions Parseval specialises to a **biased Plancherel identity**: the total Fourier energy is exactly $1$.

Applying this apparatus to an increasing event $A$ of probability $P$ with site influences $I_v$ yields two exact decompositions. First, an **energy decomposition**
$$4P(1-P) \;=\; 4p(1-p)\sum_{v\in V} I_v^2 \;+\; \sum_{|S|\ge 2}\big(p(1-p)\big)^{|S|}\hat g(S)^2,$$
which exhibits the $\ell^2$ influence bound $p(1-p)\sum_v I_v^2 \le P(1-P)$ as the statement that a remainder is nonnegative, and identifies its equality case as the vanishing of all Fourier weight above level one. Second, an **exact Efron–Stein/Poincaré defect**, valid for *arbitrary* real functions on the cube,
$$p(1-p)\sum_{v\in V}\mathbb{E}_p\big[(D_vf)^2\big] - \operatorname{Var}_p(f) \;=\; \sum_{S\ne\emptyset}\big(|S|-1\big)\big(p(1-p)\big)^{|S|}\hat f(S)^2,$$
whose specialisation to increasing events gives the variance–influence inequality $P(1-P) \le p(1-p)\sum_v I_v$ together with an exact remainder and the equality criterion: the inequality is tight if and only if the event has no Fourier weight above level one.

The two classical inequalities therefore point in opposite directions yet arise from the *same* nonnegative energy spectrum, read against the two weight functions $\mathbf 1\{|S|\ge 2\}$ and $|S|-1$ respectively. Both weights vanish exactly on levels $0$ and $1$; hence the two inequalities have identical equality cases, namely dictators and constants. We also record the intermediate identity $\sum_{S\ni v}(p(1-p))^{|S|}\hat f(S)^2 = p(1-p)\,\mathbb{E}_p[(D_vf)^2]$, the biased form of the classical relation between the influence of a coordinate and the Fourier weight above it, and its increasing-event specialisation $\text{(site energy)} = 4p(1-p)I_v$.

**Keywords:** biased Fourier analysis, discrete cube, influence, Poincaré inequality, Efron–Stein, Parseval, monotone events, sharp thresholds, percolation.

---

## 1. Introduction

### 1.1 Setting and motivation

Let $V$ be a finite set of *sites*, $n = |V|$, and let $\Omega = \{0,1\}^V$ be the discrete cube of *configurations*; we write $\eta_v = 1$ for "$v$ is open" and $\eta_v = 0$ for "$v$ is closed". For $p \in [0,1]$ the *$p$-biased product measure* assigns to $\eta \in \Omega$ the weight
$$\mu_p(\eta) \;=\; \prod_{v\in V}\big(p\,\mathbf 1\{\eta_v = 1\} + (1-p)\mathbf 1\{\eta_v = 0\}\big) \;=\; p^{\,|\eta|}(1-p)^{\,n - |\eta|},\qquad |\eta| := \#\{v : \eta_v = 1\},$$
and to an event $A \subseteq \Omega$ the probability $\mu_p(A) = \sum_{\eta\in A}\mu_p(\eta)$. We write $\mathbb{E}_p[f] = \sum_{\eta}\mu_p(\eta)f(\eta)$ for the associated expectation on real functions $f : \Omega \to \mathbb R$, and throughout abbreviate
$$q \;:=\; p(1-p),$$
the per-site variance. Except where stated we assume $0 < p < 1$, so that $q > 0$ and $\mu_p(\eta) > 0$ for every $\eta$.

An event $A$ is **increasing** (monotone) if $\eta \le \xi$ pointwise and $\eta \in A$ imply $\xi \in A$. Increasing events are the natural model for "more resources can only help": crossings in percolation, connectivity of a random graph, containment of a fixed subgraph, satisfiability under clause deletion.

For $v\in V$ and $\eta\in\Omega$ write $\eta^{v\to 1}$ and $\eta^{v\to 0}$ for the configurations obtained by forcing the site $v$ open, resp. closed. The site $v$ is **pivotal** for $A$ at $\eta$ if $\eta^{v\to 1}\in A$ and $\eta^{v\to 0}\notin A$; the set of such $\eta$ is $\mathrm{Piv}_v(A)$, and the **influence** of $v$ is
$$I_v \;=\; I_v(A,p) \;=\; \mu_p\big(\mathrm{Piv}_v(A)\big).$$
Russo's formula states that for increasing $A$ the function $p \mapsto P(p) := \mu_p(A)$ is a polynomial with $P'(p) = \sum_v I_v$.

Two inequalities are central to the theory of sharp thresholds. Writing $P = \mu_p(A)$:

- **(P)** the variance–influence, or Poincaré (Efron–Stein), inequality
  $$P(1-P) \;\le\; q\sum_{v\in V} I_v;$$
- **(L)** the $\ell^2$ influence bound
  $$q\sum_{v\in V}I_v^2 \;\le\; P(1-P).$$

Inequality **(P)**, combined with Russo's formula, gives the differential inequality $P(1-P) \le q\,P'(p)$, whose integration bounds the width of the threshold window. Inequality **(L)**, combined with Cauchy–Schwarz ($(\sum_v I_v)^2 \le n\sum_v I_v^2$), gives the **square-root law**
$$\Big(\sum_v I_v\Big)^2 \;\le\; \frac{n\,P(1-P)}{q},$$
so at $p = 1/2$ we get $\sum_v I_v \le \sqrt n$: no monotone event on $n$ sites has a threshold window of width smaller than order $n^{-1/2}$, a bound attained up to constants by majority.

The two inequalities bound the influence vector from opposite sides, and are classically proved by unrelated means: **(P)** by a martingale/hybrid-path argument, **(L)** by Bessel's inequality for the incomplete orthogonal family $\{1\}\cup\{\psi_v\}_{v\in V}$. The purpose of this paper is to show that both are shadows of one exact identity, obtained once the orthogonal family is *completed*.

### 1.2 Contributions

1. A self-contained construction of the $p$-biased Fourier basis $\{\psi_S\}_{S\subseteq V}$, with full orthogonality (Theorem 3.2), a reproducing-kernel identity (Theorem 4.2), completeness (Theorem 4.3) and Parseval's identity (Theorem 4.4). All proofs are finite algebra; no measure theory, no analysis, no hypercontractivity.
2. The biased Plancherel identity for Boolean functions (Theorem 5.2): the total Fourier energy of a $\pm 1$-valued function is exactly $1$.
3. The **energy decomposition** for increasing events (Theorem 5.3), exhibiting **(L)** as the nonnegativity of the level-$\ge 2$ energy, with the equality case (Corollary 5.4) and strict improvement (Corollary 5.5).
4. The **site energy identity** (Theorem 6.4): the Fourier energy above a coordinate equals $q\,\mathbb{E}_p[(D_vf)^2]$; the biased analogue of $\mathrm{Inf}_v(f) = \sum_{S\ni v}\hat f(S)^2$.
5. The **exact Efron–Stein/Poincaré defect** for arbitrary real functions (Theorem 6.6), and its specialisation to increasing events with the equality criterion (Theorem 7.4).
6. The synthesis (Section 8): **(P)** and **(L)** are the same nonnegative spectrum read against the weights $|S|-1$ and $\mathbf 1\{|S|\ge2\}$, and therefore share their equality case.

---

## 2. The biased expectation and the product rule

**Definition 2.1 (weight, expectation, sign indicator).** For $p\in\mathbb R$ and $\eta\in\Omega$ set $\mu_p(\eta) = \prod_{v}\big(\eta_v\,?\,p : (1-p)\big)$ and $\mathbb{E}_p[f] = \sum_{\eta\in\Omega}\mu_p(\eta)f(\eta)$. For an event $A$ its **sign indicator** is
$$g_A(\eta) \;=\; \begin{cases}+1,&\eta\in A,\\ -1,&\eta\notin A.\end{cases}$$
Note $\mathbb{E}_p[g_A] = 2P - 1$ and $g_A^2 \equiv 1$, so $\mathbb{E}_p[g_A^2] = 1$ and $\operatorname{Var}_p(g_A) = 1 - (2P-1)^2 = 4P(1-P)$.

The whole theory rests on the following statement, which is nothing but the assertion that $\mu_p$ is a product measure, but which we isolate because it is the workhorse of every subsequent computation.

**Theorem 2.2 (Product rule).** For every family $(g_v)_{v\in V}$ of functions $\{0,1\}\to\mathbb R$,
$$\mathbb{E}_p\Big[\eta \mapsto \prod_{v\in V}g_v(\eta_v)\Big] \;=\; \prod_{v\in V}\Big(p\,g_v(1) + (1-p)\,g_v(0)\Big).$$

*Proof.* Expand the right-hand product by distributivity: it equals a sum over all choices $b : V \to \{0,1\}$ of one term from each factor, i.e.
$$\prod_{v}\sum_{b\in\{0,1\}}\big(b\,?\,p:(1-p)\big)g_v(b) \;=\; \sum_{\eta \in \Omega}\prod_{v}\big(\eta_v\,?\,p:(1-p)\big)g_v(\eta_v).$$
Splitting each factor $\big(\eta_v\,?\,p:(1-p)\big)g_v(\eta_v)$ into the two parts and recombining the first parts into $\mu_p(\eta)$ gives $\sum_\eta \mu_p(\eta)\prod_v g_v(\eta_v)$, which is the left-hand side. $\square$

Two special cases used repeatedly: $\mathbb{E}_p[c] = c$ for constants (take all $g_v \equiv 1$ except one), and linearity $\mathbb{E}_p[\sum_k F_k] = \sum_k \mathbb{E}_p[F_k]$ over finite index sets (immediate by exchanging the order of summation).

---

## 3. Characters and orthogonality

**Definition 3.1 (biased Walsh characters).** For a site $v$ set
$$\psi_v(\eta) \;=\; \begin{cases}1-p, & \eta_v = 1,\\ -p, & \eta_v = 0,\end{cases}$$
and for $S \subseteq V$ put $\psi_S = \prod_{v\in S}\psi_v$, with $\psi_\emptyset \equiv 1$ and $\psi_{\{v\}} = \psi_v$.

Each $\psi_v$ is a one-coordinate function; by the product rule, $\mathbb{E}_p[\psi_v] = p(1-p) + (1-p)(-p) = 0$ and $\mathbb{E}_p[\psi_v^2] = p(1-p)^2 + (1-p)p^2 = p(1-p) = q$.

It will be convenient to write $\psi_S$ as a full product over $V$: $\psi_S(\eta) = \prod_{v\in V}h^S_v(\eta_v)$ where $h^S_v = \psi$ if $v\in S$ and $h^S_v \equiv 1$ otherwise.

**Theorem 3.2 (Full orthogonality).** For all $S,T \subseteq V$,
$$\mathbb{E}_p\big[\psi_S\,\psi_T\big] \;=\; \begin{cases} q^{\,|S|}, & S = T,\\ 0, & S \ne T.\end{cases}$$

*Proof.* Write $\psi_S\psi_T$ as a product of one-coordinate functions $g_v = h^S_v\cdot h^T_v$ and apply Theorem 2.2. The $v$-th factor of the resulting product is
$$p\,h^S_v(1)h^T_v(1) + (1-p)h^S_v(0)h^T_v(0) = \begin{cases} 1, & v\notin S\cup T,\\ p(1-p)+(1-p)(-p) = 0, & v\in S\triangle T,\\ p(1-p)^2 + (1-p)p^2 = q, & v\in S\cap T.\end{cases}$$
If $S \ne T$ some $v$ lies in the symmetric difference and the product vanishes; if $S = T$ the product is $q^{|S|}$. $\square$

The family $\{\psi_S\}$ is thus orthogonal but not orthonormal: $\|\psi_S\|_{L^2(\mu_p)} = q^{|S|/2}$. Note the family degenerates at $p\in\{0,1\}$, which is why we assume $0 < p < 1$ for all completeness statements.

**Definition 3.3 (Fourier coefficients and energies).** For $f : \Omega \to \mathbb R$ and $S \subseteq V$,
$$\hat f(S) \;=\; \frac{\mathbb{E}_p\big[f\,\psi_S\big]}{q^{\,|S|}},\qquad w_S(f) \;=\; q^{\,|S|}\hat f(S)^2 \;\ge\; 0 .$$
We call $w_S(f)$ the **energy of $f$ at level $S$**, and $\deg f = \max\{|S| : \hat f(S)\neq 0\}$. Immediately $\hat f(\emptyset) = \mathbb{E}_p[f]$, and $\mathbb{E}_p[f\psi_S] = \hat f(S)\,q^{|S|}$.

---

## 4. The reproducing kernel, completeness and Parseval

**Definition 4.1.** The **Fourier kernel** is
$$K_p(\xi,\eta) \;=\; \sum_{S\subseteq V}\ \prod_{v\in S}\frac{\psi_v(\xi)\psi_v(\eta)}{q}.$$

**Theorem 4.2 (Reproducing-kernel identity).** For $0<p<1$ and all $\xi,\eta\in\Omega$,
$$K_p(\xi,\eta) \;=\; \begin{cases} \mu_p(\eta)^{-1}, & \xi = \eta,\\ 0, & \xi \ne \eta.\end{cases}$$

*Proof.* Summing a product of the form $\prod_{v\in S}a_v$ over all $S \subseteq V$ is the expansion of $\prod_{v\in V}(1+a_v)$; hence
$$K_p(\xi,\eta) \;=\; \prod_{v\in V}\Big(1 + \frac{\psi_v(\xi)\psi_v(\eta)}{q}\Big).$$
Examine the $v$-th factor by cases:
$$1 + \frac{\psi_v(\xi)\psi_v(\eta)}{q} = \begin{cases} 1 + \dfrac{(1-p)^2}{p(1-p)} = \dfrac1p, & \xi_v = \eta_v = 1,\\[8pt] 1 + \dfrac{p^2}{p(1-p)} = \dfrac{1}{1-p}, & \xi_v = \eta_v = 0,\\[8pt] 1 + \dfrac{(1-p)(-p)}{p(1-p)} = 0, & \xi_v \ne \eta_v.\end{cases}$$
If $\xi\ne\eta$ some coordinate differs and the product is $0$; if $\xi=\eta$ the product is $\prod_v\big(\eta_v?\,p^{-1} : (1-p)^{-1}\big) = \mu_p(\eta)^{-1}$. $\square$

**Theorem 4.3 (Completeness of the biased Fourier basis).** For $0<p<1$, every $f:\Omega\to\mathbb R$ satisfies
$$f(\eta) \;=\; \sum_{S\subseteq V}\hat f(S)\,\psi_S(\eta)\qquad\text{for all }\eta\in\Omega.$$

*Proof.* Fix $\eta$. For each $S$, unfolding the definition of $\hat f(S)$ and multiplying by $\psi_S(\eta)$,
$$\hat f(S)\psi_S(\eta) \;=\; \frac{1}{q^{|S|}}\sum_{\xi}\mu_p(\xi)f(\xi)\psi_S(\xi)\psi_S(\eta) \;=\; \sum_{\xi}\mu_p(\xi)f(\xi)\prod_{v\in S}\frac{\psi_v(\xi)\psi_v(\eta)}{q},$$
using $\psi_S(\xi)\psi_S(\eta) = \prod_{v\in S}\psi_v(\xi)\psi_v(\eta)$ and $q^{|S|} = \prod_{v\in S}q$. Summing over $S$ and exchanging the two finite sums,
$$\sum_S \hat f(S)\psi_S(\eta) \;=\; \sum_{\xi}\mu_p(\xi)f(\xi)\,K_p(\xi,\eta) \;=\; \mu_p(\eta)f(\eta)\cdot\mu_p(\eta)^{-1} \;=\; f(\eta),$$
by Theorem 4.2 (only the term $\xi = \eta$ survives), and $\mu_p(\eta) > 0$. $\square$

**Theorem 4.4 (Parseval).** For $0<p<1$ and all $f,g:\Omega\to\mathbb R$,
$$\mathbb{E}_p[f\,g] \;=\; \sum_{S\subseteq V}q^{\,|S|}\,\hat f(S)\,\hat g(S).$$

*Proof.* Substitute $f = \sum_S \hat f(S)\psi_S$ from Theorem 4.3 into $\mathbb{E}_p[fg]$ and use linearity:
$$\mathbb{E}_p[fg] = \sum_S \hat f(S)\,\mathbb{E}_p[\psi_S\,g] = \sum_S \hat f(S)\,\hat g(S)\,q^{|S|},$$
the last step by Definition 3.3. $\square$

**Corollary 4.5 (Variance form).** For $0<p<1$,
$$\operatorname{Var}_p(f) \;=\; \mathbb{E}_p[f^2] - \big(\mathbb{E}_p[f]\big)^2 \;=\; \sum_{S\ne\emptyset} w_S(f).$$

*Proof.* Take $g=f$ in Theorem 4.4 and split off the term $S=\emptyset$, whose value is $q^0\hat f(\emptyset)^2 = (\mathbb{E}_pf)^2$. $\square$

Corollary 4.5 is the conservation law that drives everything below: the variance of a function is the total energy carried by its nonconstant levels, and *every term is nonnegative*.

---

## 5. Increasing events: the energy decomposition

Throughout this section $A$ is an increasing event, $g = g_A$ its sign indicator, $P = \mu_p(A)$ and $I_v = \mu_p(\mathrm{Piv}_v(A))$.

**Lemma 5.1 (Low-level coefficients).** For $0 < p < 1$,
$$\hat g(\emptyset) = 2P - 1,\qquad \hat g(\{v\}) = 2 I_v\quad (v\in V).$$

*Proof.* The first is $\hat g(\emptyset) = \mathbb{E}_p[g] = P - (1-P)$. For the second, condition on the coordinate $v$: writing every configuration as a pair (value at $v$, rest), and using $\psi_v = 1-p$ on $\{\eta_v=1\}$ and $-p$ on $\{\eta_v = 0\}$,
$$\mathbb{E}_p[g\,\psi_v] \;=\; \sum_{\zeta}\mu^{(v)}_p(\zeta)\,p(1-p)\Big(g(\zeta^{v\to1}) - g(\zeta^{v\to0})\Big),$$
where $\zeta$ ranges over configurations off $v$ with the corresponding product weight $\mu_p^{(v)}$. Since $A$ is increasing, $g(\zeta^{v\to1}) - g(\zeta^{v\to0})$ equals $2$ when $v$ is pivotal and $0$ otherwise. Hence $\mathbb{E}_p[g\psi_v] = 2q\,I_v$ and $\hat g(\{v\}) = \mathbb{E}_p[g\psi_v]/q = 2I_v$. $\square$

Lemma 5.1 is the Fourier form of the Margulis–Russo formula: the degree-one spectrum of a monotone event *is* its influence vector.

**Theorem 5.2 (Biased Plancherel identity for Boolean functions).** For $0<p<1$ and any event $A$,
$$\sum_{S\subseteq V} w_S(g_A) \;=\; \sum_{S\subseteq V}q^{|S|}\hat g_A(S)^2 \;=\; 1.$$

*Proof.* $g_A^2\equiv 1$, so $\mathbb{E}_p[g_A g_A] = 1$; apply Theorem 4.4 with $f=g=g_A$. $\square$

**Definition.** The **high energy** of $A$ is $R(A) := \sum_{|S|\ge 2}w_S(g_A) \ge 0$.

**Theorem 5.3 (Exact energy decomposition of an increasing event).** For $0<p<1$ and increasing $A$,
$$4P(1-P) \;=\; 4q\sum_{v\in V}I_v^2 \;+\; R(A).$$

*Proof.* Partition $\{S \subseteq V\}$ into $\{\emptyset\}$, the singletons, and $\{|S|\ge 2\}$, and apply Theorem 5.2:
$$1 \;=\; w_\emptyset + \sum_{v}w_{\{v\}} + R(A).$$
By Lemma 5.1, $w_\emptyset = q^0(2P-1)^2 = (2P-1)^2$ and $w_{\{v\}} = q\,(2I_v)^2 = 4q I_v^2$. Rearranging and using $1 - (2P-1)^2 = 4P(1-P)$ gives the claim. $\square$

**Corollary 5.4 ($\ell^2$ influence bound and its equality case).** For $0<p<1$ and increasing $A$,
$$q\sum_{v}I_v^2 \;\le\; P(1-P),$$
with equality if and only if $R(A) = 0$, i.e. if and only if $\hat g_A(S) = 0$ for every $S$ with $|S| \ge 2$.

*Proof.* Immediate from Theorem 5.3 and $R(A)\ge0$; $R(A)$ is a sum of nonnegative terms $q^{|S|}\hat g(S)^2$ with $q>0$, so it vanishes iff each coefficient does. $\square$

**Corollary 5.5 (Strict improvement).** If $\hat g_A(S) \ne 0$ for some $S$ with $|S| \ge 2$, then $q\sum_v I_v^2 < P(1-P)$ strictly, the gap being at least $q^{|S|}\hat g_A(S)^2/4$.

**Corollary 5.6 (Square-root law).** By Cauchy–Schwarz, $\big(\sum_v I_v\big)^2 \le n\sum_v I_v^2 \le n\,P(1-P)/q$; in particular $\sum_v I_v \le \sqrt n$ at $p=1/2$.

**Example 5.7 (Grid crossing).** Let $A_n$ be the left-to-right open crossing event of the $n\times n$ grid at $p=1/2$, an increasing event on $n^2$ sites. Since $4q = 1$ at $p=1/2$, Theorem 5.3 reads
$$4P(1-P) \;=\; \sum_{v}I_v^2 \;+\; R(A_n).$$
The classical fact that a crossing has no dominant site is exactly the statement that $R(A_n)$ carries most of the mass.

---

## 6. The one-coordinate calculus and the exact Efron–Stein defect

We now treat arbitrary real functions.

**Definition 6.1.** Say $f$ is **independent of $v$**, written $f \perp v$, if $f(\eta^{v\to b}) = f(\eta)$ for all $\eta$ and $b\in\{0,1\}$. Define the **discrete derivative** and **average** at $v$:
$$(D_vf)(\eta) = f(\eta^{v\to1}) - f(\eta^{v\to0}),\qquad (A_vf)(\eta) = p\,f(\eta^{v\to1}) + (1-p)f(\eta^{v\to0}).$$
Both $D_vf$ and $A_vf$ are independent of $v$, as is $\psi_S$ whenever $v\notin S$; and the class of functions independent of $v$ is closed under products.

**Lemma 6.2 (One-coordinate decomposition).** For every $f$, every $v$ and every $\eta$,
$$f(\eta) \;=\; (A_vf)(\eta) \;+\; \psi_v(\eta)\,(D_vf)(\eta).$$

*Proof.* If $\eta_v = 1$ then $\eta^{v\to1}=\eta$, $\psi_v(\eta) = 1-p$, and the right-hand side is $p f(\eta) + (1-p)f(\eta^{v\to0}) + (1-p)\big(f(\eta) - f(\eta^{v\to0})\big) = f(\eta)$. The case $\eta_v = 0$ is symmetric, with $\psi_v(\eta) = -p$. $\square$

**Lemma 6.3 (Two one-coordinate integrals).** If $h \perp v$, then
$$\mathbb{E}_p[\psi_v\,h] = 0,\qquad \mathbb{E}_p[\psi_v^2\,h] = q\,\mathbb{E}_p[h].$$

*Proof.* Split the expectation by conditioning on the coordinate $v$: for any $F$,
$\mathbb{E}_p[F] = \sum_{\zeta}\mu_p^{(v)}(\zeta)\big(pF(\zeta^{v\to1}) + (1-p)F(\zeta^{v\to0})\big)$. With $F=\psi_v h$ the inner bracket is $\big(p(1-p) + (1-p)(-p)\big)h(\zeta) = 0$; with $F = \psi_v^2h$ it is $\big(p(1-p)^2 + (1-p)p^2\big)h(\zeta) = q\,h(\zeta)$. $\square$

Two consequences on the spectrum. First, if $f\perp v$ then $\hat f(S) = 0$ for every $S\ni v$: indeed $\psi_S = \psi_v\psi_{S\setminus v}$ and $f\,\psi_{S\setminus v} \perp v$, so the first identity of Lemma 6.3 applies. Second, and crucially:

**Lemma 6.4 (Coefficients above a site are those of the derivative).** For $0<p<1$, $v\in S$:
$$\hat f(S) \;=\; \widehat{D_vf}(S\setminus\{v\}).$$

*Proof.* Write $\psi_S = \psi_v\,\psi_{S\setminus v}$ and insert Lemma 6.2:
$$f\,\psi_S = \psi_v\big(A_vf\cdot\psi_{S\setminus v}\big) + \psi_v^2\big(D_vf\cdot\psi_{S\setminus v}\big).$$
Both bracketed functions are independent of $v$. Applying Lemma 6.3 to each term,
$$\mathbb{E}_p[f\psi_S] \;=\; 0 + q\,\mathbb{E}_p\big[D_vf\cdot\psi_{S\setminus v}\big].$$
Divide by $q^{|S|} = q\cdot q^{|S|-1} = q\cdot q^{|S\setminus v|}$. $\square$

**Theorem 6.5 (Site energy identity).** For $0<p<1$ and every $f$,
$$\sum_{S\ni v} w_S(f) \;=\; q\;\mathbb{E}_p\big[(D_vf)^2\big].$$

*Proof.* Reindex the sets containing $v$ by $T = S\setminus\{v\}$, a bijection onto the sets avoiding $v$, under which $|S| = |T|+1$. By Lemma 6.4,
$$\sum_{S\ni v}q^{|S|}\hat f(S)^2 \;=\; \sum_{T\not\ni v}q^{|T|+1}\widehat{D_vf}(T)^2 \;=\; q\sum_{T\not\ni v}w_T(D_vf).$$
But $D_vf \perp v$, so $\widehat{D_vf}(T) = 0$ for every $T \ni v$; hence the restricted sum equals the full sum $\sum_{T\subseteq V}w_T(D_vf)$, which by Parseval (Theorem 4.4 with $f=g=D_vf$) is $\mathbb{E}_p[(D_vf)^2]$. $\square$

Theorem 6.5 is the $p$-biased analogue of the classical unbiased identity $\mathrm{Inf}_v(f) = \sum_{S\ni v}\hat f(S)^2$.

**Theorem 6.6 (Exact Efron–Stein/Poincaré defect, general $f$).** For $0<p<1$ and every $f : \Omega\to\mathbb R$,
$$q\sum_{v\in V}\mathbb{E}_p\big[(D_vf)^2\big] \;-\; \operatorname{Var}_p(f) \;=\; \sum_{S\ne\emptyset}\big(|S|-1\big)\,w_S(f) \;\;\ge\;\; 0 .$$
In particular the Poincaré inequality $\operatorname{Var}_p(f) \le q\sum_v\mathbb{E}_p[(D_vf)^2]$ holds.

*Proof.* Sum Theorem 6.5 over $v \in V$. On the left each level $S$ is counted once for every $v\in S$, so
$$q\sum_{v}\mathbb{E}_p[(D_vf)^2] \;=\; \sum_{v}\sum_{S\ni v}w_S(f) \;=\; \sum_{S\subseteq V}|S|\,w_S(f) \;=\; \sum_{S\ne\emptyset}|S|\,w_S(f),$$
the last step because the term $S=\emptyset$ carries the factor $|S| = 0$. Subtract $\operatorname{Var}_p(f) = \sum_{S\ne\emptyset}w_S(f)$ (Corollary 4.5) termwise. Nonnegativity holds because $|S|\ge 1$ on nonempty $S$ and $w_S(f)\ge0$. $\square$

Note that the defect vanishes exactly when $w_S(f) = 0$ for all $|S|\ge2$, i.e. when $f$ has degree at most one.

---

## 7. Specialisation to increasing events

**Lemma 7.1 (The derivative of a monotone sign indicator is $0$ or $2$).** If $A$ is increasing then for all $v,\eta$,
$$\big(D_vg_A\big)(\eta) \in\{0,2\}, \qquad\text{hence}\qquad \big(D_vg_A\big)^2 = 2\,D_vg_A.$$

*Proof.* Since $\eta^{v\to0}\le\eta^{v\to1}$ and $A$ is increasing, $\eta^{v\to0}\in A$ forces $\eta^{v\to1}\in A$. So the pair of values $(g_A(\eta^{v\to1}), g_A(\eta^{v\to0}))$ is one of $(1,1),(1,-1),(-1,-1)$, giving a difference of $0$, $2$ or $0$. $\square$

**Lemma 7.2.** For $0<p<1$ and increasing $A$, $\;\mathbb{E}_p[D_vg_A] = 2I_v$ and hence $\mathbb{E}_p[(D_vg_A)^2] = 4I_v$.

*Proof.* $D_vg_A = 2\cdot\mathbf 1_{\mathrm{Piv}_v(A)}$ pointwise by the case analysis of Lemma 7.1, so its mean is $2I_v$; multiply by $2$ using Lemma 7.1. (Equivalently, insert Lemma 6.2 into $\mathbb{E}_p[g_A\psi_v] = 2qI_v$ from Lemma 5.1, and apply Lemma 6.3.) $\square$

**Theorem 7.3 (Site energy of a monotone event is its influence).** For $0<p<1$ and increasing $A$,
$$\sum_{S \ni v} w_S(g_A) \;=\; 4q\,I_v .$$

*Proof.* Theorem 6.5 applied to $f = g_A$, with $\mathbb{E}_p[(D_vg_A)^2] = 4I_v$ from Lemma 7.2. $\square$

Summing over $v$ and counting each level with multiplicity gives the **Fourier formula for the total influence**:
$$4q\sum_{v\in V} I_v \;=\; \sum_{S\subseteq V}|S|\;w_S(g_A).$$

**Theorem 7.4 (Poincaré defect for an increasing event, and its equality case).** For $0<p<1$ and increasing $A$,
$$4q\sum_{v\in V}I_v \;-\; 4P(1-P) \;=\; \sum_{S\ne\emptyset}\big(|S|-1\big)w_S(g_A) \;\ge\; 0 .$$
Consequently
$$P(1-P)\;\le\; q\sum_{v}I_v,$$
with equality **if and only if** $\hat g_A(S) = 0$ for every $S$ with $|S| \ge 2$.

*Proof.* Apply Theorem 6.6 to $f = g_A$; the left side becomes $4q\sum_v I_v$ by Lemma 7.2, and $\operatorname{Var}_p(g_A) = 4P(1-P)$. For the equality case, the defect is a sum of nonnegative terms $(|S|-1)w_S$; it vanishes iff every term does. On singletons the factor $|S|-1$ is $0$, so those terms are automatically zero; on $|S|\ge2$ the factor is $\ge1>0$, so the term vanishes iff $w_S = 0$ iff $\hat g_A(S) = 0$ (using $q>0$). $\square$

---

## 8. Synthesis: one spectrum, two weights

Fix an increasing event $A$ and consider the nonnegative **energy spectrum** $\big(w_S\big)_{S\subseteq V}$ of its sign indicator, normalised by Theorem 5.2 to total mass $1$. Both classical inequalities are statements that a weighted sum of this spectrum is nonnegative:

| Inequality | Exact identity | Weight $\omega(S)$ applied to $w_S$ |
|---|---|---|
| $\ell^2$ influence bound $\;q\sum_v I_v^2 \le P(1-P)$ | $4P(1-P) - 4q\sum_v I_v^2 = \sum_S \omega(S)w_S$ | $\omega(S) = \mathbf 1\{|S|\ge2\}$ |
| Poincaré $\;P(1-P) \le q\sum_v I_v$ | $4q\sum_v I_v - 4P(1-P) = \sum_S \omega(S)w_S$ | $\omega(S) = |S|-1$ |

Three observations follow immediately.

**(i) Opposite directions, same source.** The two inequalities squeeze $P(1-P)$ from opposite sides, yet both are read off the same nonnegative spectrum. The difference is only in the weight: the $\ell^2$ bound discards *all* levels above one uniformly; the Poincaré inequality charges each such level $|S|-1$ times.

**(ii) Identical equality cases.** Both weights vanish exactly on levels $0$ and $1$ and are positive above; so both inequalities are tight precisely for events of Fourier degree at most one. Among monotone events these are the constants ($P\in\{0,1\}$) and the **dictators** $A = \{\eta : \eta_{v_0} = 1\}$. For a dictator, $P = p$, $I_{v_0}=1$ and $I_v = 0$ otherwise; both inequalities become $p(1-p) = q$.

**(iii) Chaining.** Subtracting the first identity from the second eliminates $P(1-P)$ altogether and yields, for every increasing event, the strikingly simple
$$4q\Big(\sum_{v} I_v - \sum_{v} I_v^2\Big) \;=\; \sum_{|S|\ge 2}|S|\,w_S(g_A).$$
Since $I_v\in[0,1]$, the left-hand side is a nonnegative measure of the spread of the influence profile; the identity expresses that spread exactly as the high-level energy weighted by level. In particular $\sum_v I_v = \sum_v I_v^2$ — every influence equal to $0$ or $1$ — precisely for events of degree at most one.

---

## 9. Algorithms

All quantities above are computable exactly on a finite site set. Three procedures suffice.

**Algorithm A (Spectrum by direct transform).** Given $n = |V|$, a rational $p$ and a table of $f$ on all $2^n$ configurations, compute $\hat f(S)$ for all $2^n$ subsets by $\hat f(S) = q^{-|S|}\sum_\eta\mu_p(\eta)f(\eta)\psi_S(\eta)$. Cost: $O(4^n\cdot n)$ arithmetic operations naively.

**Algorithm B (Spectrum by a biased fast Walsh transform).** The naive cost is unnecessary. Because $\psi_S$ factorises coordinatewise, the transform factorises too: iterating over coordinates $v = 1,\dots,n$ and applying, in place, the $2\times2$ update
$$\begin{pmatrix} a \\ b\end{pmatrix} \;\longmapsto\; \begin{pmatrix} p\,a + (1-p)\,b \\ a - b\end{pmatrix}$$
to each pair of entries differing only in coordinate $v$ (where $a$ is the entry with $v$ open) performs exactly the decomposition $f = A_vf + \psi_v D_vf$ of Lemma 6.2 one coordinate at a time. After $n$ passes the entry indexed by $S$ is $\hat f(S)$. Cost: $O(n2^n)$ operations, exact in rational arithmetic. Correctness is Lemma 6.2 applied inductively: the first row of the update stores the part of the function not involving $\psi_v$, the second the coefficient of $\psi_v$.

**Algorithm C (Influences and defects).** For an increasing event given by a membership predicate, compute $I_v = \sum_{\eta : \eta_v = 0}\mu_p(\eta)\big[\eta^{v\to1}\in A\big]\big[\eta\notin A\big]\cdot\frac{1}{1-p}$ — equivalently sum $\mu_p$ over pivotal configurations — then evaluate both defects directly from the spectrum of $g_A$ produced by Algorithm B, and check the identities of Theorems 5.3 and 7.4 as exact rational equalities. Cost: $O(n2^n)$.

Algorithm B in exact rational arithmetic makes every identity in this paper falsifiable at the level of a specific finite site set; all identities stated here have been checked in this way for $n \le 5$ on random functions and on families of monotone events, at several rational densities.

---

## 10. Discussion and related structure

**Why completeness matters.** The degree-$\le1$ theory — orthogonality of $\{1\}\cup\{\psi_v\}$ and Bessel's inequality for that family — already suffices for the $\ell^2$ influence bound and hence for the square-root law. What it cannot do is say *when* the bound is tight, or by how much it fails. Bessel is an inequality precisely because the family is incomplete; supplying the remaining characters $\psi_S$, $|S|\ge2$, upgrades it to an identity whose remainder is explicit. The upgrade costs exactly one extra idea — the reproducing-kernel computation of Theorem 4.2 — and everything else is bookkeeping.

**Robustness.** Theorem 6.6 holds for *arbitrary* real functions with no monotonicity assumption; monotonicity enters only through Lemma 7.1, which converts the second moment $\mathbb{E}_p[(D_vg)^2]$ into the first moment $4I_v$. This is the only place where increasing-ness is used, and it is the reason the Poincaré inequality for monotone events involves $\sum_v I_v$ rather than $\sum_v\mathbb{E}_p[(D_v g)^2]$.

**Degeneration at the endpoints.** At $p\in\{0,1\}$ we have $q = 0$; the characters degenerate, the coefficients $\hat f(S)$ are undefined for $S \ne \emptyset$, and both inequalities become $0\le0$. All completeness statements therefore require $0<p<1$. The orthogonality relation of Theorem 3.2 and the product rule of Theorem 2.2, by contrast, are polynomial identities in $p$ and hold for every real $p$.

**Normalisation.** Some authors use the orthonormal characters $\chi_S = q^{-|S|/2}\psi_S$ and coefficients $\tilde f(S) = \mathbb{E}_p[f\chi_S]$, in which case $w_S(f) = \tilde f(S)^2$ and Parseval reads $\mathbb{E}_p[fg] = \sum_S\tilde f(S)\tilde g(S)$. We have preferred the unnormalised $\psi_S$ because it keeps every quantity a polynomial in $p$ with no square roots, which is essential for exact rational verification. At $p=1/2$ the energies $w_S$ coincide with the classical unbiased Fourier weights $\hat f_{\pm1}(S)^2$ of the $\pm1$ formalism.

**Relation to sharp thresholds.** Coupled with Russo's formula $P'(p) = \sum_v I_v$, Theorem 7.4 yields the exact differential identity
$$4q\,P'(p) \;=\; 4P(1-P) \;+\; \sum_{S\ne\emptyset}(|S|-1)w_S(g_A),$$
i.e. the logistic derivative $\frac{d}{dp}\log\frac{P}{1-P}$ equals $\frac{1}{q}\big(1 + \text{defect}/(4P(1-P))\big)$. Integration therefore gives *quantitatively improved* threshold windows for any family of events whose high-level energy can be bounded below — the standard route by which better influence estimates translate into sharper threshold statements.

---

## 11. Future work

**Hypercontractivity and the KKL circle.** The natural next weight function is exponential rather than linear: for $\rho\in[0,1]$ the biased noise operator $T_\rho$ acts by $\widehat{T_\rho f}(S) = \rho^{|S|}\hat f(S)$, and the assertion $\|T_\rho f\|_4 \le \|f\|_2$ for $\rho^2 \le q/\max(p,1-p)^2$ is the missing ingredient between the present development and the Kahn–Kalai–Linial theorem (every balanced monotone event has a site of influence at least $c\log n/n$) and Talagrand's refinements. Crucially, hypercontractivity **tensorises**: the $n$-coordinate inequality follows from the single-coordinate case by repeated application of the product rule (Theorem 2.2), so the only genuinely new input is a two-variable polynomial inequality in one coordinate.

**Sharper level weights.** The synthesis of Section 8 suggests studying the whole family of inequalities $\sum_S\omega(|S|)w_S \ge 0$ for nonnegative weights $\omega$ vanishing on $\{0,1\}$; the $\ell^2$ bound and Poincaré are the two simplest members. Which weights yield useful threshold information, and what is the extremal event for a given $\omega$?

**Level-one energy and noise stability.** The quantity $\sum_v w_{\{v\}} = 4q\sum_vI_v^2$ is the level-one energy; the results here identify its complement $R(A)$ exactly. Bounding $R(A)$ from below for specific families (crossings, connectivity, $k$-SAT) is the concrete route to improved thresholds for those families.

**Site-dependent densities.** All of Sections 2–4 go through verbatim for product measures with site-dependent densities $p_v$, with $\psi_v$ built from $p_v$ and $q^{|S|}$ replaced by $\prod_{v\in S}p_v(1-p_v)$. The Margulis–Russo formula in that generality gives partial derivatives $\partial P/\partial p_v = I_v$, and the analogues of Theorems 6.6 and 7.4 should hold with the same proofs.

---

## 12. Summary of results

- **Product rule.** $\mathbb{E}_p\big[\prod_v g_v(\eta_v)\big] = \prod_v\big(pg_v(1)+(1-p)g_v(0)\big)$.
- **Orthogonality.** $\mathbb{E}_p[\psi_S\psi_T] = \mathbf 1\{S=T\}\,q^{|S|}$.
- **Reproducing kernel.** $\sum_S\prod_{v\in S}\frac{\psi_v(\xi)\psi_v(\eta)}{q} = \mathbf 1\{\xi=\eta\}/\mu_p(\eta)$.
- **Completeness.** $f = \sum_S \hat f(S)\psi_S$ for $0<p<1$.
- **Parseval.** $\mathbb{E}_p[fg] = \sum_S q^{|S|}\hat f(S)\hat g(S)$; $\operatorname{Var}_p f = \sum_{S\ne\emptyset}w_S(f)$.
- **Plancherel for Boolean functions.** $\sum_S w_S(g_A) = 1$.
- **Energy decomposition.** $4P(1-P) = 4q\sum_v I_v^2 + \sum_{|S|\ge2}w_S(g_A)$; equality case and strict improvement for the $\ell^2$ influence bound.
- **Site energy identity.** $\sum_{S\ni v}w_S(f) = q\,\mathbb{E}_p[(D_vf)^2]$; for increasing events, $= 4qI_v$.
- **Exact Efron–Stein defect.** $q\sum_v\mathbb{E}_p[(D_vf)^2] - \operatorname{Var}_p f = \sum_{S\ne\emptyset}(|S|-1)w_S(f) \ge 0$, for arbitrary $f$.
- **Poincaré defect for increasing events** and the criterion: $P(1-P) = q\sum_vI_v$ iff the event has Fourier degree at most one.
