# The Complete $p$-Biased Fourier Expansion on the Discrete Cube and Exact Defects in the Influence Inequalities

**Author:** Aristotle

**Date:** 2026-08-07

---

## Abstract

We develop, from first principles and by purely finite-algebraic means, the complete $p$-biased Fourier analysis of real-valued functions on the discrete cube $\{0,1\}^{\iota}$ with $\iota$ a finite index set, and we use it to convert two classical influence inequalities for monotone events into exact identities.

The development is built on a single engine, the *product rule* for the biased expectation: the expectation of a product of one-coordinate functions factorizes. From it we obtain full orthogonality of the biased Walsh characters $\psi_S = \prod_{v \in S}\psi_v$, namely $\mathbb{E}_p[\psi_S\psi_T] = \mathbb{1}[S=T]\,(pq)^{|S|}$ with $q = 1-p$; a reproducing-kernel identity exhibiting $\sum_S \prod_{v\in S}\psi_v(\xi)\psi_v(\eta)/(pq)$ as a reweighted Kronecker delta; the resulting *completeness* of the character system, $f = \sum_S \hat f(S)\psi_S$ for $0 < p < 1$; and *Parseval's identity* $\mathbb{E}_p[fg] = \sum_S (pq)^{|S|}\hat f(S)\hat g(S)$, with the variance specialization $\operatorname{Var}_p(f) = \sum_{S \ne \emptyset}(pq)^{|S|}\hat f(S)^2$.

Two applications follow. First, for an increasing event $A$ with $P = \mathbb{P}_p(A)$ and influences $I_v$, the $\pm 1$-indicator satisfies the **exact energy decomposition**
$$4P(1-P) \;=\; 4pq\sum_v I_v^2 \;+\; \sum_{|S|\ge 2} E_S,\qquad E_S := (pq)^{|S|}\hat g(S)^2 \ge 0 ,$$
which exhibits the classical $\ell^2$ influence bound $pq\sum_v I_v^2 \le P(1-P)$ as the assertion that the level-$\ge 2$ energy is nonnegative, and pins down its equality case as "no Fourier weight above degree one".

Second, via a one-coordinate decomposition $f = A_vf + \psi_v D_v f$ we prove the biased site-energy identity $\sum_{S \ni v}E_S(f) = pq\,\mathbb{E}_p[(D_vf)^2]$ — the $p$-biased form of $\mathrm{Inf}_v(f) = \sum_{S\ni v}\hat f(S)^2$ — and hence the **exact Efron–Stein/Poincaré defect** for arbitrary real functions,
$$pq\sum_v \mathbb{E}_p\big[(D_vf)^2\big] - \operatorname{Var}_p(f) \;=\; \sum_{S \ne \emptyset}\big(|S|-1\big)E_S(f)\ \ge\ 0 ,$$
together with its specialization to increasing events and the characterization of equality. Consequently the two classical influence inequalities, historically proved by unrelated arguments and pointing in opposite directions, are two differently-weighted readings of one and the same level-energy ledger, and are tight under the identical condition.

We also give a self-contained algorithmic treatment (exact rational computation of the biased spectrum in $O(2^{2N})$ naive time, or $O(N2^N)$ by a biased fast transform), numerical verification on dictatorships, majorities, AND/OR, and grid crossing events, and a discussion of what remains — chiefly two-point hypercontractivity and its tensorization along the product rule.

**Keywords:** discrete Fourier analysis, $p$-biased measure, Boolean functions, influences, Efron–Stein inequality, Poincaré inequality, Margulis–Russo formula, percolation, sharp thresholds.

---

## 1. Introduction

### 1.1 Setting and motivation

Let $\iota$ be a finite index set, $N = |\iota|$, and let $\Omega = \{\text{blocked},\text{open}\}^{\iota}$, which we identify with the set of Boolean configurations $\eta : \iota \to \{0,1\}$. Fix a density $p \in [0,1]$ and write $q = 1-p$. The $p$-biased product (Bernoulli) measure assigns to a configuration $\eta$ the weight
$$w_p(\eta) \;=\; \prod_{v \in \iota}\big(p^{\,\eta_v}\,q^{\,1-\eta_v}\big) \;=\; \prod_{v\,:\,\eta_v = 1} p \prod_{v\,:\,\eta_v = 0} q ,$$
and to an event $A \subseteq \Omega$ the probability $\mathbb{P}_p(A) = \sum_{\eta \in A} w_p(\eta)$. For a real function $f : \Omega \to \mathbb{R}$ we write $\mathbb{E}_p[f] = \sum_\eta w_p(\eta) f(\eta)$.

An event $A$ is **increasing** (monotone) if $\eta \le \eta'$ pointwise and $\eta \in A$ imply $\eta' \in A$. The canonical example is the horizontal crossing event of an $n \times n$ grid, in which $\iota = \{1,\dots,n\}^2$ indexes the cells and $A$ is the set of configurations whose open cells contain a left-to-right path.

For a site $v$, the **pivotal set** is
$$\mathrm{Piv}_v(A) \;=\; \{\eta : \eta^{v\to 1} \in A \text{ and } \eta^{v\to 0} \notin A\} ,$$
where $\eta^{v\to b}$ denotes $\eta$ with coordinate $v$ reset to $b$, and the **influence** of $v$ is $I_v = \mathbb{P}_p(\mathrm{Piv}_v(A))$. Membership in $\mathrm{Piv}_v(A)$ does not depend on $\eta_v$, so $I_v$ is also the probability that resampling $v$ can flip the outcome.

Two inequalities dominate this landscape. Write $P = \mathbb{P}_p(A)$.

**(P)** *Poincaré / variance–influence.* $P(1-P) \le pq \sum_v I_v$.

**(L2)** *$\ell^2$ influence bound.* $pq \sum_v I_v^2 \le P(1-P)$.

Inequality (P) is the discrete Poincaré (Efron–Stein) inequality specialized to a monotone event; combined with the Margulis–Russo formula $\frac{d}{dp}\mathbb{P}_p(A) = \sum_v I_v$, it drives sharp-threshold arguments. Inequality (L2) is Bessel's inequality for the degree-$\le 1$ family $\{1\}\cup\{\psi_v\}$, and by Cauchy–Schwarz it yields the **square-root law**
$$pq\Big(\sum_v I_v\Big)^2 \le N\, P(1-P), \qquad\text{in particular } \sum_v I_v \le \sqrt{N} \text{ at } p = \tfrac12 ,$$
a lower bound of order $N^{-1/2}$ on the width of any threshold window.

Both are inequalities, and in both cases the loss has the same source: the character family used is incomplete. The purpose of this paper is to complete it and to compute both defects exactly.

### 1.2 Contributions

1. **The product rule** (Theorem 3.1): $\mathbb{E}_p\big[\prod_v g_v(\eta_v)\big] = \prod_v\big(p\,g_v(1) + q\,g_v(0)\big)$ for arbitrary one-coordinate functions $g_v$. This is the formal encoding of independence and is the only input used below.
2. **Full orthogonality** (Theorem 4.3) of the higher characters $\psi_S$.
3. **The reproducing kernel identity** (Theorem 5.3) and **completeness** of the biased character system (Theorem 5.4), for $0 < p < 1$.
4. **Parseval's identity** and the variance form (Theorems 6.1, 6.2); the **biased Plancherel identity for Boolean functions**, $\sum_S E_S(g) = 1$ (Theorem 7.2).
5. **Exact energy decomposition** for increasing events (Theorem 7.3), with the equality case and strict-improvement statements for (L2) (Corollaries 7.4, 7.5).
6. **Site-energy identity** $\sum_{S\ni v}E_S(f) = pq\,\mathbb{E}_p[(D_vf)^2]$ (Theorem 9.3), the **exact Efron–Stein defect** for arbitrary functions (Theorem 10.1), the specialization to increasing events (Theorem 11.3), and the characterization of equality in (P) (Theorem 11.4).
7. Algorithms and numerical verification, including an exact-rational spectral computation and a biased fast Fourier transform on the cube.

### 1.3 Related context

At $p = 1/2$ the theory reduces to classical Boolean Fourier analysis, where the identities $\operatorname{Var}(f) = \sum_{S\ne\emptyset}\hat f(S)^2$ and $\mathrm{Inf}_v(f) = \sum_{S\ni v}\hat f(S)^2$ are standard. The novelty here is threefold: the biased case is treated in full with all normalizations explicit; the entire development is finite algebra requiring no measure theory, no hypercontractivity, and no analysis beyond a single square root; and the two influence inequalities are shown to be one identity read two ways, with matching equality cases.

---

## 2. Notation and basic objects

Throughout, $\iota$ is a finite index set with $N = |\iota|$ elements, $p \in [0,1]$, and $q = 1-p$. We freely identify Boolean configurations $\eta : \iota \to \{0,1\}$ with subsets of $\iota$ when convenient, and we write $\eta_v$ for the state of site $v$ ("open" for $1$, "blocked" for $0$).

**Definition 2.1 (Weight and expectation).** $w_p(\eta) = \prod_v (p \text{ if } \eta_v = 1 \text{ else } q)$; $\mathbb{E}_p[f] = \sum_{\eta}w_p(\eta)f(\eta)$; $\mathbb{P}_p(A) = \mathbb{E}_p[\mathbb{1}_A]$.

Note $\sum_\eta w_p(\eta) = 1$, so $\mathbb{E}_p$ is linear, monotone, and normalized: $\mathbb{E}_p[c] = c$.

**Definition 2.2 ($\pm 1$ indicator).** For an event $A$, $g_A(\eta) = +1$ if $\eta \in A$ and $-1$ otherwise. Then $g_A^2 \equiv 1$, $\mathbb{E}_p[g_A] = 2P - 1$, and $\operatorname{Var}_p(g_A) = 1 - (2P-1)^2 = 4P(1-P)$.

**Definition 2.3 (Single-site character).** For $v \in \iota$,
$$\psi_v(\eta) \;=\; \begin{cases} q & \eta_v = 1,\\ -p & \eta_v = 0.\end{cases}$$

Equivalently $\psi_v(\eta) = \eta_v - p$. Elementary computation gives $\mathbb{E}_p[\psi_v] = pq + q(-p) = 0$ and $\mathbb{E}_p[\psi_v^2] = pq^2 + qp^2 = pq$. We use the *unnormalized* character throughout; the normalized character is $\psi_v/\sqrt{pq}$, and every formula below carries the factors $(pq)^{|S|}$ that this choice induces.

**Definition 2.4 (Discrete derivative and average).** For $v \in \iota$,
$$D_vf(\eta) = f(\eta^{v\to1}) - f(\eta^{v\to0}), \qquad A_vf(\eta) = p\,f(\eta^{v\to1}) + q\,f(\eta^{v\to0}).$$
Both are independent of the coordinate $v$: we say $h$ is **$v$-independent** if $h(\eta^{v\to b}) = h(\eta)$ for all $\eta, b$.

---

## 3. The engine: the product rule

**Theorem 3.1 (Product rule).** *For every family $(g_v)_{v\in\iota}$ of functions $\{0,1\}\to\mathbb{R}$,*
$$\mathbb{E}_p\Big[\prod_{v\in\iota} g_v(\eta_v)\Big] \;=\; \prod_{v\in\iota}\Big(p\,g_v(1) + q\,g_v(0)\Big).$$

*Proof sketch.* Expand the right-hand side. A product of $N$ two-term sums equals the sum over all choice functions $\eta : \iota \to \{0,1\}$ of $\prod_v \big[(p \text{ if } \eta_v=1 \text{ else } q)\,g_v(\eta_v)\big]$; that is the distributive law for a finite product of finite sums. Splitting each factor and using $w_p(\eta) = \prod_v(p \text{ if } \eta_v = 1 \text{ else } q)$ turns this into $\sum_\eta w_p(\eta)\prod_v g_v(\eta_v)$, which is the left-hand side. $\square$

This one statement is the entire content of "the coins are independent" in the form needed below. Every subsequent theorem is an application of it or of the one-coordinate identities of §9.

---

## 4. Higher characters and full orthogonality

**Definition 4.1 (Biased Walsh characters).** For $S \subseteq \iota$,
$$\psi_S(\eta) \;=\; \prod_{v \in S}\psi_v(\eta), \qquad \psi_\emptyset \equiv 1 .$$
We call $|S|$ the **degree** of the character.

**Lemma 4.2 (Full-support form).** $\psi_S(\eta) = \prod_{v\in\iota} c_v(\eta_v)$ where $c_v = \psi_v$ for $v \in S$ and $c_v \equiv 1$ otherwise.

This trivial reformulation is what allows the product rule to be applied: it presents $\psi_S$, and any product $\psi_S\psi_T$, as a product over *all* coordinates of one-coordinate functions.

**Theorem 4.3 (Orthogonality).** *For all $S, T \subseteq \iota$,*
$$\mathbb{E}_p[\psi_S\,\psi_T] \;=\; \begin{cases}(pq)^{|S|} & S = T,\\ 0 & S \ne T.\end{cases}$$

*Proof sketch.* By Lemma 4.2, $\psi_S\psi_T = \prod_v h_v(\eta_v)$ with $h_v = \psi_v^2$ if $v \in S\cap T$, $h_v = \psi_v$ if $v$ lies in exactly one of $S,T$, and $h_v \equiv 1$ otherwise. Apply Theorem 3.1: the local factor is $\mathbb{E}_p[\psi_v^2] = pq$ on $S\cap T$, $\mathbb{E}_p[\psi_v] = 0$ on the symmetric difference, and $1$ elsewhere. If $S \ne T$ the symmetric difference is nonempty and a single zero factor annihilates the product; if $S = T$ every one of the $|S|$ factors contributes $pq$. $\square$

Theorem 4.3 says that $\{\psi_S\}_{S\subseteq\iota}$ is an orthogonal system of $2^N$ vectors in the $2^N$-dimensional space $\mathbb{R}^\Omega$ equipped with the inner product $\langle f,g\rangle_p = \mathbb{E}_p[fg]$, provided $0 < p < 1$ (so that $(pq)^{|S|} \ne 0$ and the system is nondegenerate). Dimension counting already yields completeness; but the explicit kernel computation of the next section is more informative and gives the inversion formula directly.

---

## 5. The reproducing kernel and completeness

**Definition 5.1 (Fourier coefficient).** For $0 < p < 1$ and $f : \Omega \to \mathbb{R}$,
$$\hat f(S) \;=\; \frac{\mathbb{E}_p\big[f\,\psi_S\big]}{(pq)^{|S|}} .$$
In particular $\hat f(\emptyset) = \mathbb{E}_p[f]$.

**Definition 5.2 (Level energy).** $E_S(f) = (pq)^{|S|}\,\hat f(S)^2 \ \ge 0$.

**Theorem 5.3 (Reproducing kernel).** *For $0 < p < 1$ and all $\xi, \eta \in \Omega$,*
$$\sum_{S \subseteq \iota}\ \prod_{v\in S}\frac{\psi_v(\xi)\,\psi_v(\eta)}{pq} \;=\; \begin{cases} w_p(\eta)^{-1} & \xi = \eta,\\ 0 & \xi \ne \eta.\end{cases}$$

*Proof sketch.* Write $a_v = \psi_v(\xi)\psi_v(\eta)/(pq)$. The identity $\sum_{S\subseteq\iota}\prod_{v\in S}a_v = \prod_{v\in\iota}(1 + a_v)$ — the expansion of a product of binomials over all subsets — reduces the claim to a coordinatewise inspection of $1 + a_v$.

- If $\xi_v \ne \eta_v$, then $\psi_v(\xi)\psi_v(\eta) = q\cdot(-p) = -pq$, so $a_v = -1$ and $1 + a_v = 0$. One disagreeing coordinate kills the whole product.
- If $\xi_v = \eta_v = 1$, then $a_v = q^2/(pq) = q/p$ and $1 + a_v = (p+q)/p = 1/p$.
- If $\xi_v = \eta_v = 0$, then $a_v = p^2/(pq) = p/q$ and $1 + a_v = 1/q$.

Hence when $\xi = \eta$ the product is $\prod_v(1/p \text{ or } 1/q) = w_p(\eta)^{-1}$. $\square$

The kernel is the *reproducing kernel* of the space: it acts as a Dirac delta reweighted by the measure, exactly cancelling the weight in the expectation.

**Theorem 5.4 (Completeness / Fourier inversion).** *For $0 < p < 1$, every $f : \Omega \to \mathbb{R}$ satisfies*
$$f(\eta) \;=\; \sum_{S \subseteq \iota}\hat f(S)\,\psi_S(\eta) \qquad \text{for all } \eta .$$

*Proof sketch.* Expand $\hat f(S)\psi_S(\eta) = (pq)^{-|S|}\sum_\xi w_p(\xi)f(\xi)\psi_S(\xi)\psi_S(\eta)$ and note that $(pq)^{-|S|}\psi_S(\xi)\psi_S(\eta) = \prod_{v\in S}\psi_v(\xi)\psi_v(\eta)/(pq)$. Summing over $S$ and exchanging the two finite sums,
$$\sum_S \hat f(S)\psi_S(\eta) \;=\; \sum_\xi w_p(\xi)f(\xi)\sum_S\prod_{v\in S}\frac{\psi_v(\xi)\psi_v(\eta)}{pq}.$$
By Theorem 5.3 the inner sum is $\mathbb{1}[\xi=\eta]\,w_p(\eta)^{-1}$, and since $w_p(\eta) > 0$ for $0<p<1$ the double sum collapses to $w_p(\eta)f(\eta)w_p(\eta)^{-1} = f(\eta)$. $\square$

**Remark 5.5.** The restriction $0 < p < 1$ is essential and not technical: at $p \in \{0,1\}$ the measure is a point mass, $pq = 0$, most Fourier coefficients are undefined, and the space of functions "seen" by the measure is one-dimensional.

---

## 6. Parseval and the variance decomposition

**Theorem 6.1 (Parseval).** *For $0 < p < 1$ and all $f, g : \Omega \to \mathbb{R}$,*
$$\mathbb{E}_p[f\,g] \;=\; \sum_{S\subseteq\iota}(pq)^{|S|}\,\hat f(S)\,\hat g(S) .$$

*Proof sketch.* Substitute the expansion $f = \sum_S \hat f(S)\psi_S$ from Theorem 5.4 into $\mathbb{E}_p[fg]$ and use linearity of $\mathbb{E}_p$ over the finite sum:
$$\mathbb{E}_p[fg] = \sum_S \hat f(S)\,\mathbb{E}_p[g\,\psi_S] = \sum_S \hat f(S)\,\hat g(S)(pq)^{|S|},$$
the last step being Definition 5.1 rearranged. $\square$

**Theorem 6.2 (Variance form).** *For $0<p<1$,*
$$\operatorname{Var}_p(f) \;=\; \mathbb{E}_p[f^2] - \big(\mathbb{E}_p[f]\big)^2 \;=\; \sum_{S \ne \emptyset}E_S(f) .$$

*Proof sketch.* Take $g = f$ in Theorem 6.1 and split off the term $S=\emptyset$, which equals $(pq)^0\hat f(\emptyset)^2 = (\mathbb{E}_p[f])^2$. $\square$

So variance is *total nonconstant energy*, and the sequence $\big(E_S(f)\big)_S$ is a complete accounting of the randomness of $f$, sorted by frequency.

---

## 7. Increasing events: the exact energy decomposition

Fix an increasing event $A$, write $g = g_A$ for its $\pm 1$-indicator, $P = \mathbb{P}_p(A)$, $I_v = \mathbb{P}_p(\mathrm{Piv}_v(A))$, and $E_S = E_S(g)$.

**Theorem 7.1 (Fourier form of Margulis–Russo).** *For every $v$,*
$$\mathbb{E}_p[g\,\psi_v] \;=\; 2\,pq\,I_v, \qquad\text{equivalently}\qquad \hat g(\{v\}) = 2 I_v, \qquad E_{\{v\}} = 4pq\,I_v^2 .$$

*Proof sketch.* Condition on the coordinates other than $v$. For each off-configuration exactly one of three cases occurs for an increasing event: the event holds regardless of $v$ (contribution $1\cdot(q p + p(-p))\cdot$… cancels), the event fails regardless of $v$ (again cancels), or the off-configuration is pivotal, in which case $g = +1$ when $v$ is open and $g = -1$ when $v$ is closed, contributing $p\cdot q + q\cdot p = 2pq$ times its off-weight. Summing the pivotal off-weights gives $2pq\,I_v$. Dividing by $(pq)^{1}$ gives $\hat g(\{v\}) = 2I_v$. $\square$

Also $\hat g(\emptyset) = \mathbb{E}_p[g] = 2P-1$, so $E_\emptyset = (2P-1)^2$.

**Theorem 7.2 (Biased Plancherel for Boolean functions).** *For $0<p<1$ and any event $A$,*
$$\sum_{S\subseteq\iota} E_S \;=\; 1 .$$

*Proof sketch.* $g^2 \equiv 1$, so $\mathbb{E}_p[g^2] = 1$; apply Theorem 6.1 with $f = g$. $\square$

Thus the level energies of a Boolean function form a probability distribution on the $2^N$ frequencies — the *spectral distribution* of the event.

**Theorem 7.3 (Exact energy decomposition).** *Let $A$ be increasing and $0<p<1$. Then*
$$4P(1-P) \;=\; 4pq\sum_{v\in\iota} I_v^2 \;+\; R, \qquad R \;:=\; \sum_{|S| \ge 2} E_S \;\ge\; 0 .$$

*Proof sketch.* Partition the frequency set into $\{\emptyset\}$, the singletons, and the sets of size $\ge 2$, and apply Theorem 7.2:
$$1 = E_\emptyset + \sum_v E_{\{v\}} + R = (2P-1)^2 + 4pq\sum_v I_v^2 + R .$$
Since $1 - (2P-1)^2 = 4P(1-P)$, rearranging gives the claim. Nonnegativity of $R$ is termwise, each $E_S = (pq)^{|S|}\hat g(S)^2$ being a product of nonnegative reals. $\square$

**Corollary 7.4 (Equality case of the $\ell^2$ bound).** *If $R = 0$ — that is, if $\hat g(S) = 0$ for all $|S|\ge 2$ — then*
$$pq\sum_v I_v^2 \;=\; P(1-P).$$

**Corollary 7.5 (Strict improvement).** *If $\hat g(S) \ne 0$ for some $S$ with $|S| \ge 2$, then $R > 0$ and*
$$pq\sum_v I_v^2 \;<\; P(1-P).$$

Theorem 7.3 is the exact form of (L2): the inequality is nothing other than $R \ge 0$, so its slack is precisely a quarter of the Fourier energy of the event above degree one. Since (L2) is the sole input to the square-root law $\sum_v I_v \le \sqrt{N}$ at $p=1/2$, the loss in the square-root law is now completely explicit and combines with the (separate) loss in Cauchy–Schwarz.

**Example 7.6 (Dictatorship).** $A = \{\eta_v = 1\}$. Then $g = 2\eta_v - 1 = 2\psi_v + (2p-1)$ since $\psi_v = \eta_v - p$; so $\hat g(\emptyset) = 2p-1$, $\hat g(\{v\}) = 2$, and all other coefficients vanish. Then $I_v = 1$, other influences $0$, $R = 0$, and (L2) is an equality: $pq \cdot 1 = p(1-p) = P(1-P)$.

**Example 7.7 (Majority on three sites at $p=1/2$).** $\mathrm{Maj}_3 = \tfrac12(x_1+x_2+x_3 - x_1x_2x_3)$ in the $\pm1$ encoding. The energies are $E_{\{i\}} = 1/4$ for each of the three singletons and $E_{\{1,2,3\}} = 1/4$; total $1$, confirming Theorem 7.2. Here $P = 1/2$, $I_v = 1/2$ for each $v$, and Theorem 7.3 reads $4\cdot\tfrac14 = 4\cdot\tfrac14\cdot\tfrac34 + \tfrac14$, i.e. $1 = \tfrac34 + \tfrac14$. The $\ell^2$ defect is $R/4 = 1/16$.

---

## 8. The grid instance

**Theorem 8.1 (Crossing energy decomposition).** *Let $\mathrm{Cross}_n$ be the horizontal crossing event of the $n\times n$ grid at $p = 1/2$, with $P_n = \mathbb{P}_{1/2}(\mathrm{Cross}_n)$. Then*
$$4P_n(1-P_n) \;=\; \sum_{v} I_v^2 \;+\; \sum_{|S|\ge 2}E_S ,$$
*the sum over the $n^2$ cells.*

*Proof sketch.* Theorem 7.3 with $p=1/2$, so $4pq = 1$, applied to the crossing event, which is increasing. $\square$

The interest of this instance is quantitative. The crossing event is far from degenerate: $P_n$ stays bounded away from $0$ and $1$ as $n$ grows, so the left-hand side is of order $1$, while by symmetry all $n^2$ cells have comparable influence $I_v$, and the square-root law forces $\sum_v I_v \le n$, hence $\sum_v I_v^2 \le \max_v I_v \cdot \sum_v I_v \to 0$ as soon as the maximal influence tends to $0$. Consequently virtually all of the spectral mass must sit in the remainder $R$: the crossing event has essentially no low-degree Fourier weight. This is the spectral signature of *noise sensitivity*, and it explains quantitatively why crossing events are as far as possible from the $\ell^2$ equality case.

---

## 9. One-coordinate analysis and the site-energy identity

We now leave increasing events and work with arbitrary $f : \Omega \to \mathbb{R}$.

**Lemma 9.1 (One-coordinate decomposition).** *For every $v$ and every $\eta$,*
$$f(\eta) \;=\; A_vf(\eta) \;+\; \psi_v(\eta)\,D_vf(\eta) .$$

*Proof sketch.* Two cases. If $\eta_v = 1$ then $\eta^{v\to 1} = \eta$, $\psi_v(\eta) = q$, and the right side is $p f(\eta) + q f(\eta^{v\to0}) + q\big(f(\eta) - f(\eta^{v\to0})\big) = (p+q)f(\eta) = f(\eta)$. If $\eta_v = 0$ then $\eta^{v\to0} = \eta$, $\psi_v(\eta) = -p$, and the right side is $p f(\eta^{v\to1}) + qf(\eta) - p\big(f(\eta^{v\to1}) - f(\eta)\big) = f(\eta)$. $\square$

Both $A_vf$ and $D_vf$ are $v$-independent, so Lemma 9.1 splits $f$ into a $v$-independent part and $\psi_v$ times a $v$-independent part. The following two one-coordinate integrals then do all the work.

**Lemma 9.2 (One-coordinate integrals).** *If $h$ is $v$-independent then*
$$\mathbb{E}_p[\psi_v\,h] = 0, \qquad \mathbb{E}_p[\psi_v^2\,h] = pq\,\mathbb{E}_p[h] .$$

*Proof sketch.* Condition on the coordinates other than $v$: for each off-configuration $\zeta$ with off-weight $\omega(\zeta)$ the two completions contribute $\omega(\zeta)h(\zeta)\big(p\,q + q\,(-p)\big) = 0$ in the first case, and $\omega(\zeta)h(\zeta)\big(pq^2 + qp^2\big) = pq\,\omega(\zeta)h(\zeta)$ in the second. $\square$

Two immediate consequences. First, a $v$-independent function has vanishing Fourier coefficients at every set containing $v$: writing $\psi_S = \psi_v\,\psi_{S\setminus v}$ for $v \in S$, and noting that $\psi_{S\setminus v}$ is $v$-independent, the first identity of Lemma 9.2 gives $\mathbb{E}_p[f\psi_S] = 0$. Second, and more useful:

**Lemma 9.3 (Coefficients above a site are those of the derivative).** *For $0<p<1$, every $f$, every $v$, and every $S \ni v$,*
$$\hat f(S) \;=\; \widehat{D_vf}\,(S\setminus v) .$$

*Proof sketch.* Substitute Lemma 9.1 into $\mathbb{E}_p[f\psi_S]$ with $\psi_S = \psi_v\psi_{S\setminus v}$:
$$\mathbb{E}_p[f\psi_S] = \mathbb{E}_p\big[\psi_v\,(A_vf)\psi_{S\setminus v}\big] + \mathbb{E}_p\big[\psi_v^2\,(D_vf)\psi_{S\setminus v}\big] .$$
The first term vanishes and the second equals $pq\,\mathbb{E}_p[(D_vf)\psi_{S\setminus v}]$, by Lemma 9.2 applied with $h = (A_vf)\psi_{S\setminus v}$ resp. $h = (D_vf)\psi_{S\setminus v}$ — both $v$-independent, since $S\setminus v$ omits $v$. Dividing by $(pq)^{|S|} = pq\cdot(pq)^{|S|-1}$ gives the claim. $\square$

**Theorem 9.4 (Site energy identity).** *For $0<p<1$, every $f$ and every $v$,*
$$\sum_{S \ni v}E_S(f) \;=\; pq\;\mathbb{E}_p\big[(D_vf)^2\big] .$$

*Proof sketch.* Reindex the sets containing $v$ by $T = S\setminus v$, which ranges over the sets avoiding $v$, with $|S| = |T|+1$. By Lemma 9.3,
$$\sum_{S\ni v}E_S(f) = \sum_{T \not\ni v}(pq)^{|T|+1}\,\widehat{D_vf}(T)^2 = pq\sum_{T\not\ni v}E_T(D_vf).$$
Since $D_vf$ is $v$-independent, its coefficients at sets containing $v$ vanish (first consequence of Lemma 9.2), so the restricted sum equals the full sum $\sum_T E_T(D_vf)$, which is $\mathbb{E}_p[(D_vf)^2]$ by Parseval (Theorem 6.1 with $f = g = D_vf$). $\square$

Theorem 9.4 is the $p$-biased form of the classical identity $\mathrm{Inf}_v(f) = \sum_{S\ni v}\hat f(S)^2$; the factor $pq$ is precisely the normalization introduced by using unnormalized characters.

**Lemma 9.5 (Level multiplicity).** *For every $f$,*
$$\sum_{v\in\iota}\ \sum_{S\ni v}E_S(f) \;=\; \sum_{S\subseteq\iota}|S|\;E_S(f) .$$

*Proof sketch.* Exchange the order of summation: the level $S$ appears once for each $v \in S$. $\square$

---

## 10. The exact Efron–Stein / Poincaré defect

**Theorem 10.1 (Exact defect identity).** *For $0<p<1$ and every $f : \Omega \to \mathbb{R}$,*
$$pq\sum_{v\in\iota}\mathbb{E}_p\big[(D_vf)^2\big] \;-\; \operatorname{Var}_p(f) \;=\; \sum_{S \ne \emptyset}\big(|S|-1\big)\,E_S(f) .$$

*Proof sketch.* By Theorem 9.4 and Lemma 9.5, the first term equals $\sum_S |S|\,E_S(f)$, in which the empty set contributes nothing. By Theorem 6.2 the variance is $\sum_{S\ne\emptyset}E_S(f)$. Subtract termwise over the nonempty levels. $\square$

**Corollary 10.2 (Nonnegativity of the defect and the Poincaré inequality).** *Every term $(|S|-1)E_S(f)$ with $S \ne \emptyset$ is nonnegative, since $|S| \ge 1$ and $E_S \ge 0$. Hence for every real function on the cube,*
$$\operatorname{Var}_p(f)\ \le\ pq\sum_{v}\mathbb{E}_p\big[(D_vf)^2\big] .$$

This is the discrete Poincaré (Efron–Stein) inequality on the biased cube, obtained here with an exact remainder rather than by a coupling or hybrid-path argument. Note what the defect measures: the levels of degree one contribute nothing (they are the "Poincaré-extremal" directions), and each higher level is overcounted exactly $|S|-1$ times by the sum over sites.

---

## 11. Specialization to increasing events

Let $A$ be increasing with $\pm1$-indicator $g$.

**Lemma 11.1 (The derivative is $0$ or $2$).** *For every $v,\eta$: $\ (D_vg)^2 = 2\,D_vg$.*

*Proof sketch.* Monotonicity forbids $\eta^{v\to0}\in A$ with $\eta^{v\to1}\notin A$. So $D_vg(\eta) \in \{0,2\}$, and $t^2 = 2t$ on $\{0,2\}$. $\square$

**Lemma 11.2 (Mean of the derivative).** *For $0<p<1$, $\ \mathbb{E}_p[D_vg] = 2 I_v$, hence $\mathbb{E}_p[(D_vg)^2] = 4I_v$ and, by Theorem 9.4, $\sum_{S\ni v}E_S = 4pq\,I_v$.*

*Proof sketch.* $D_vg = 2\cdot\mathbb{1}_{\mathrm{Piv}_v(A)}$ pointwise, by the trichotomy in the proof of Theorem 7.1; take expectations. Alternatively, insert Lemma 9.1 into $\mathbb{E}_p[g\psi_v]$, use Lemma 9.2 to get $\mathbb{E}_p[g\psi_v] = pq\,\mathbb{E}_p[D_vg]$, and compare with Theorem 7.1. $\square$

**Theorem 11.3 (Total influence in Fourier form, and the exact Poincaré defect).** *For $0<p<1$ and $A$ increasing,*
$$4pq\sum_v I_v \;=\; \sum_{S}|S|\;E_S ,$$
*and consequently*
$$4pq\sum_v I_v \;-\; 4P(1-P) \;=\; \sum_{S\ne\emptyset}\big(|S|-1\big)E_S \ \ge\ 0 ,$$
*which is the Poincaré inequality $P(1-P) \le pq\sum_v I_v$ with an exact remainder.*

*Proof sketch.* Combine Lemma 11.2 with Lemma 9.5 for the first identity; then apply Theorem 10.1 to $f = g$, using $\operatorname{Var}_p(g) = 4P(1-P)$ and $\mathbb{E}_p[(D_vg)^2] = 4I_v$. $\square$

**Theorem 11.4 (Equality case of the Poincaré inequality).** *For $0<p<1$ and $A$ increasing,*
$$P(1-P) \;=\; pq\sum_v I_v \iff \hat g(S) = 0 \ \text{ for every } S \text{ with } |S| \ge 2 .$$

*Proof sketch.* ($\Leftarrow$) All the terms of the defect with $|S|\ge2$ vanish by hypothesis, and the terms with $|S| = 1$ carry the factor $|S|-1 = 0$; so the defect is zero. ($\Rightarrow$) The defect is a sum of nonnegative terms equal to zero, so each vanishes. For $|S|\ge2$ the factor $|S|-1$ is strictly positive, forcing $E_S = 0$; since $(pq)^{|S|} \ne 0$ this forces $\hat g(S) = 0$. $\square$

**Corollary 11.5 (Unified equality criterion).** *Let $A$ be increasing and $0<p<1$. The following are equivalent:*
1. $pq\sum_v I_v^2 = P(1-P)$ *(equality in the $\ell^2$ bound);*
2. $P(1-P) = pq\sum_v I_v$ *(equality in the Poincaré inequality);*
3. $\hat g(S) = 0$ for all $|S| \ge 2$ *(the event has degree at most one).*

*Proof sketch.* (3) $\Rightarrow$ (1) is Corollary 7.4; (1) $\Rightarrow$ (3) is Corollary 7.5 in contrapositive; (2) $\Leftrightarrow$ (3) is Theorem 11.4. $\square$

This is the structural punchline. Two classical inequalities that bound $P(1-P)$ from *opposite sides* — one by $pq\sum I_v^2$ from below, one by $pq\sum I_v$ from above — have identical, explicitly computable defects up to the reweighting $\mathbb{1}[|S|\ge2] \leftrightarrow (|S|-1)$ of the same level-energy ledger, and they are tight simultaneously.

| Statement | Defect (in units of $\tfrac14$ of the total energy) |
|---|---|
| $pq\sum_v I_v^2 \le P(1-P)$ | $\displaystyle \sum_{S}\mathbb{1}[|S|\ge2]\,E_S$ |
| $P(1-P) \le pq \sum_v I_v$ | $\displaystyle \sum_{S \ne \emptyset}(|S|-1)\,E_S$ |

Since $\mathbb{1}[k\ge2] \le k-1$ for all integers $k \ge 1$, the Poincaré defect always dominates the $\ell^2$ defect; equality of the two defects holds precisely when all energy above degree one sits at degree exactly $2$.

---

## 12. Algorithms

All quantities above are exactly computable in rational arithmetic when $p \in \mathbb{Q}$, so every identity in this paper is checkable without floating-point error.

### 12.1 Naive spectral computation

Given $f$ as a table of $2^N$ values and $p \in \mathbb{Q}$:

1. Precompute $w_p(\eta)$ for all $\eta$ ($O(N2^N)$).
2. For each of the $2^N$ frequencies $S$, compute $\hat f(S) = (pq)^{-|S|}\sum_\eta w_p(\eta)f(\eta)\psi_S(\eta)$, evaluating $\psi_S(\eta)$ in $O(|S|)$.

Total: $O(N4^N)$ arithmetic operations. Adequate up to $N \approx 12$.

### 12.2 Biased fast Fourier transform

Better: a coordinatewise butterfly. Lemma 9.1 says exactly that, at a fixed coordinate $v$, splitting a function into its $v$-average and its $v$-derivative separates the frequencies not containing $v$ from those containing $v$ (Lemma 9.3). Iterating over the $N$ coordinates gives a transform in $O(N2^N)$ operations:

```
BiasedFFT(f, p):
    q ← 1 - p
    F ← array of size 2^N indexed by configurations, F ← f
    for each coordinate v = 1..N:
        for each pair of entries (η with v=0, η with v=1) of F:
            a ← F[η^{v→0}];  b ← F[η^{v→1}]
            F[η^{v→0}] ← p·b + q·a          # average  (frequency omits v)
            F[η^{v→1}] ← b − a              # derivative (frequency contains v)
    # now F[η], read with η as the indicator vector of S, equals \hat f(S)
    return F
```

Correctness is Lemma 9.1 plus Lemma 9.3 applied coordinate by coordinate: after processing coordinate $v$, the entries at $\eta_v = 0$ hold the biased transform of the $v$-average and those at $\eta_v = 1$ hold the biased transform of the $v$-derivative, and by Lemma 9.3 the latter *are* the coefficients of $f$ at the sets containing $v$. Note the elegant consequence that the biased transform requires **no division at all**: the factors $(pq)^{|S|}$ built into Definition 5.1 are exactly cancelled by the recursion.

### 12.3 Influences and defects

Given the spectrum $\{\hat f(S)\}$ and $E_S = (pq)^{|S|}\hat f(S)^2$:

- $\operatorname{Var}_p(f) = \sum_{S\ne\emptyset}E_S$;
- $\mathrm{Inf}_v$-type quantity $pq\,\mathbb{E}_p[(D_vf)^2] = \sum_{S\ni v}E_S$;
- for an increasing event, $I_v = \hat g(\{v\})/2$;
- $\ell^2$ defect $= \tfrac14\sum_{|S|\ge2}E_S$; Poincaré defect $= \tfrac14\sum_{S\ne\emptyset}(|S|-1)E_S$.

Each is a single pass over the $2^N$ frequencies.

---

## 13. Numerical illustrations

The following are exact rational values, computed by the algorithms of §12.

**Dictatorship on $v_1$, $N=3$, $p = 1/3$.** $P = 1/3$, $I_{v_1} = 1$, $I_{v_2} = I_{v_3} = 0$. Spectrum: $\hat g(\emptyset) = -1/3$, $\hat g(\{v_1\}) = 2$, all else $0$. Energies: $E_\emptyset = 1/9$, $E_{\{v_1\}} = \tfrac29\cdot4 = 8/9$; total $1$ ✓. Both defects vanish; both inequalities are equalities: $pq\sum I_v^2 = 2/9 = P(1-P)$ and $pq\sum I_v = 2/9 = P(1-P)$ ✓.

**Majority on three sites, $p=1/2$.** $P = 1/2$; $I_v = 1/2$ for each $v$. Energies: three singletons at $1/4$, one triple at $1/4$. $\ell^2$: $\tfrac14\cdot\tfrac34 = 3/16 < 1/4 = P(1-P)$, defect $1/16 = \tfrac14 E_{\{1,2,3\}}$ ✓. Poincaré: $pq\sum I_v = \tfrac14\cdot\tfrac32 = 3/8 > 1/4$, defect $1/8 = \tfrac14\cdot(3-1)\cdot\tfrac14$ ✓.

**AND of three sites, $p = 1/2$.** $P = 1/8$, $I_v = 1/4$ each. $P(1-P) = 7/64$. $\ell^2$: $\tfrac14\cdot\tfrac3{16} = 3/64 < 7/64$. Poincaré: $\tfrac14\cdot\tfrac34 = 3/16 = 12/64 > 7/64$. Both defects are strictly positive because $\mathrm{AND}_3$ has substantial energy at degrees $2$ and $3$.

**$2\times2$ grid crossing at $p=1/2$.** Take the horizontal crossing event of the $2\times2$ grid, i.e. "at least one of the two rows is entirely open", on the four cells $a = (1,1)$, $b = (1,2)$, $c = (2,1)$, $d = (2,2)$. Then $P = 1 - (3/4)^2 = 7/16$ and $P(1-P) = 63/256$. Each cell has influence $I_v = 3/8$ (cell $a$ is pivotal iff $b$ is open and row $2$ is not entirely open: $\tfrac12\cdot\tfrac34$). The level energies are
$$E_\emptyset = \tfrac1{64},\quad E_{\{v\}} = \tfrac9{64}\ (\times 4),\quad E_{\{a,b\}} = E_{\{c,d\}} = \tfrac9{64},\quad E_{S} = \tfrac1{64}\ \text{for the other four pairs, the four triples and the full set},$$
totalling $\tfrac{1 + 36 + 18 + 4 + 4 + 1}{64} = 1$, confirming Theorem 7.2. The $\ell^2$ bound reads $\tfrac14\cdot\tfrac9{16} = \tfrac{36}{256} \le \tfrac{63}{256}$ with defect $\tfrac{27}{256} = \tfrac14\sum_{|S|\ge2}E_S = \tfrac14\cdot\tfrac{27}{64}$ ✓. The Poincaré bound reads $\tfrac{63}{256} \le \tfrac14\cdot\tfrac32 = \tfrac{96}{256}$ with defect $\tfrac{33}{256} = \tfrac14\sum_{S\ne\emptyset}(|S|-1)E_S = \tfrac14\cdot\tfrac{22 + 8 + 3}{64}$ ✓.

In all cases the total energy is exactly $1$ (Theorem 7.2), the energy decomposition of Theorem 7.3 balances exactly, and the Efron–Stein identity of Theorem 10.1 holds for randomly generated non-Boolean functions as well.

---

## 14. Discussion

### 14.1 What the identities buy

Three things.

*Conceptual unification.* The $\ell^2$ influence bound and the Poincaré inequality had, in this development, entirely different original proofs — the first a Bessel/residual computation on the incomplete family $\{1\}\cup\{\psi_v\}$, the second a hybrid-path union bound. Theorems 7.3 and 11.3 show they are two weightings of the *same* nonnegative ledger.

*Sharpness.* Corollary 11.5 gives a single, checkable equality criterion for both. Degree-$\le1$ Boolean functions on the biased cube appear to be extremely rigid. Exhaustive enumeration of all upward-closed events on $N \le 4$ sites (the Dedekind counts $3, 6, 20, 168$) at $p = 1/2$ and $p = 1/3$, in exact rational arithmetic, confirms the equivalence of the three conditions of Corollary 11.5 in every case and shows that the only extremal events are the two constants and the $N$ dictatorships. Every other monotone event on at most four sites therefore has a strictly positive gap in *both* inequalities simultaneously. The same enumeration finds the largest attainable level-$\ge2$ energy on four sites to be $27/64$, achieved by the tribes event $(x_1\wedge x_2)\vee(x_0 \wedge x_3)$.

*Quantitative improvement.* Any lower bound on the level-$\ge2$ energy of an event upgrades both inequalities. For instance, if one knows that a $\rho$-fraction of the spectral mass of $g$ sits above degree one, then $pq\sum_vI_v^2 \le P(1-P) - \rho/4$ and $pq\sum_vI_v \ge P(1-P) + \rho/4$. This is exactly the shape of estimate that hypercontractive arguments supply.

### 14.2 The role of the product rule

Every result here reduces, ultimately, to Theorem 3.1. Orthogonality is the product rule applied to $\psi_S\psi_T$; the reproducing kernel is a product of binomials; and the one-coordinate lemmas of §9 are the product rule at a single site. This is not merely economical: it identifies the exact interface at which the theory generalizes. Any measure for which a product rule holds — in particular *inhomogeneous* product measures with a distinct density $p_v$ at each site — supports the same development, with $\psi_v(\eta) = \eta_v - p_v$ and $(pq)^{|S|}$ replaced by $\prod_{v\in S}p_v(1-p_v)$. Every theorem above then holds verbatim with that replacement, and the site-dependent Margulis–Russo formula supplies the corresponding degree-one coefficients.

### 14.3 Limitations

The development is finite and algebraic: it says nothing directly about infinite product spaces (though everything passes to the limit under the usual cylinder-function approximation), and it does not by itself give the KKL-type conclusion that *some* influence is at least $c\log N/N$. That conclusion requires an estimate on how spectral mass distributes across degrees, and no such estimate can follow from orthogonality alone — orthogonality is degree-blind.

---

## 15. Future directions

The natural next targets, each falsifiable on finite site sets and hence testable numerically before being attacked in full generality:

**Conjecture 15.1 (Two-point hypercontractivity and its tensorization).** For every $f : \{0,1\}\to\mathbb{R}$, every $\rho \in [0,1]$ with $\rho^2 \le pq/\max(p,q)^2$, and the biased noise operator $T_\rho$, one has $\|T_\rho f\|_4 \le \|f\|_2$; and the same inequality holds for functions on $\{0,1\}^\iota$ with the same $\rho$, by tensorizing along the product rule.

The key insight is that the product rule is exactly the statement that the biased measure is a product measure, and tensorization of a hypercontractive estimate is nothing but repeated application of the product rule coordinate by coordinate; the two-point case is a single two-variable polynomial inequality after clearing denominators.

*Why this matters.* Hypercontractivity is the only missing ingredient between the present development and the whole KKL/Talagrand circle: with the Fourier expansion, Parseval, the level decomposition, and the site-energy identity all in place, a hypercontractive estimate immediately upgrades the level-$\ge2$ remainder $R$ of Theorem 7.3 into a quantitative statement, delivering the $\log N/N$ influence lower bound, Talagrand's $\sum_v I_v/\log(1/I_v)$ bound, and Friedgut's junta theorem.

**Further directions.**

- *Noise stability and the level-$k$ inequalities.* Define $\mathrm{Stab}_\rho(f) = \sum_S \rho^{|S|}E_S(f)$ and establish its monotonicity and semigroup properties directly from the product rule; then obtain the level-$k$ inequalities bounding the degree-$\le k$ energy of a small-measure event.
- *Sharper defect estimates for geometric events.* Compute or bound $R$ for crossing events on planar lattices, where near-total high-degree concentration is expected; a quantitative lower bound on $R$ would improve the square-root law for such events.
- *Inhomogeneous densities.* Carry the entire development to a site-dependent density vector $(p_v)$, and combine with the site-dependent Margulis–Russo formula to obtain directional threshold statements.
- *Reverse defect bounds.* The Poincaré defect $\sum_{S\ne\emptyset}(|S|-1)E_S$ is bounded above by $(N-1)\operatorname{Var}$; identify the correct sharp constant in terms of the spectral profile, which would tighten the reverse Poincaré inequality currently carrying a factor $N$.
- *Equality-case rigidity.* Classify all Boolean functions on the biased cube of Fourier degree at most one. Exhaustive enumeration for $N \le 4$ finds only constants and dictatorships, and a proof for all $N$ would turn Corollary 11.5 into a complete structural classification of the extremal events.

---

## 16. Summary of the main results

For a finite site set $\iota$, $0 < p < 1$, $q = 1-p$, characters $\psi_v(\eta) = \eta_v - p$ and $\psi_S = \prod_{v\in S}\psi_v$, coefficients $\hat f(S) = \mathbb{E}_p[f\psi_S]/(pq)^{|S|}$, and level energies $E_S(f) = (pq)^{|S|}\hat f(S)^2$:

1. **Product rule.** $\mathbb{E}_p[\prod_v g_v(\eta_v)] = \prod_v (p g_v(1) + q g_v(0))$.
2. **Orthogonality.** $\mathbb{E}_p[\psi_S\psi_T] = \mathbb{1}[S=T](pq)^{|S|}$.
3. **Reproducing kernel.** $\sum_S \prod_{v\in S}\psi_v(\xi)\psi_v(\eta)/(pq) = \mathbb{1}[\xi=\eta]/w_p(\eta)$.
4. **Completeness.** $f = \sum_S \hat f(S)\psi_S$.
5. **Parseval.** $\mathbb{E}_p[fg] = \sum_S(pq)^{|S|}\hat f(S)\hat g(S)$; $\operatorname{Var}_p(f) = \sum_{S\ne\emptyset}E_S(f)$.
6. **Plancherel for Boolean functions.** $\sum_S E_S(g_A) = 1$.
7. **Exact energy decomposition.** $4P(1-P) = 4pq\sum_v I_v^2 + \sum_{|S|\ge2}E_S$ for increasing $A$.
8. **Site energy.** $\sum_{S\ni v}E_S(f) = pq\,\mathbb{E}_p[(D_vf)^2]$.
9. **Exact Efron–Stein defect.** $pq\sum_v\mathbb{E}_p[(D_vf)^2] - \operatorname{Var}_p(f) = \sum_{S\ne\emptyset}(|S|-1)E_S(f)$.
10. **Exact Poincaré defect and equality case.** $4pq\sum_vI_v - 4P(1-P) = \sum_{S\ne\emptyset}(|S|-1)E_S$, with equality iff the event has degree at most one — the same criterion as for the $\ell^2$ bound.
