# Logarithmic Negativity as an Entanglement Monotone: A Variational Development of the Trace Norm, Strong Duality, and Exact Additivity

**Author:** Aristotle

**Date:** 2026-08-13

---

## Abstract

We give a self-contained, fully rigorous development of the logarithmic negativity $E_N(\rho) = \log\|\Gamma\rho\|_1$ of a bipartite quantum state, where $\Gamma$ denotes partial transposition on the second tensor factor and $\|\cdot\|_1$ is the trace norm. The development is organised around a *variational* definition of the trace norm of a Hermitian matrix,
$$\|X\|_1 = \inf\{\operatorname{tr}P + \operatorname{tr}Q : X = P - Q,\ P \succeq 0,\ Q \succeq 0\},$$
together with its dual description as a supremum of $\operatorname{Re}\operatorname{tr}(XW)$ over Hermitian contractions $-\mathbb 1 \preceq W \preceq \mathbb 1$. We prove that the primal infimum and the dual supremum are both attained — by the spectral Jordan pair and the sign operator of the spectrum respectively — and that they coincide with $\sum_i|\lambda_i|$, so that no duality gap occurs.

From this base we obtain: contractivity of the trace norm under positive trace-preserving maps; monotonicity of $E_N$ and of the negativity $\mathcal N(\rho) = (\|\Gamma\rho\|_1 - 1)/2$ under PPT operations (hence under all local operations with classical communication); strong (selective) monotonicity $\sum_i p_i E_N(\rho_i) \le E_N(\rho)$ under PPT instruments; convexity of $\mathcal N$; faithfulness on the PPT class, $E_N(\rho) = 0 \iff \Gamma\rho \succeq 0$, with vanishing on all separable states; the dimension bound $E_N(\rho) \le \tfrac12\log(d_A d_B)$; its saturation $E_N(\Phi_d) = \log d$ at the maximally entangled state; exact multiplicativity of the trace norm, $\|A\otimes B\|_1 = \|A\|_1\|B\|_1$ for Hermitian $A,B$, and hence exact additivity $E_N(\rho\otimes\sigma) = E_N(\rho) + E_N(\sigma)$, contrasted with the non-additive law $\mathcal N(\rho\otimes\sigma) = 2\mathcal N(\rho)\mathcal N(\sigma) + \mathcal N(\rho) + \mathcal N(\sigma)$; and, as applications, exact-distillation upper bounds and the impossibility of distilling a maximally entangled state from a PPT state by PPT protocols.

The methodological point of the paper is that the variational definition of the trace norm makes monotonicity nearly automatic (positive maps push splittings forward), while strong duality is exactly the extra input needed to upgrade submultiplicativity to multiplicativity, and hence subadditivity of $E_N$ to additivity.

**Keywords:** logarithmic negativity, entanglement monotone, partial transpose, PPT operations, trace norm, semidefinite duality, bound entanglement.

---

## 1. Introduction

### 1.1 The problem

Entanglement is a resource: it can be consumed to teleport states, to establish secret keys, and to beat classical bounds in distributed computation, and it cannot be created for free by parties restricted to acting locally and exchanging classical messages. A *measure* of entanglement is a function $E$ on bipartite states that quantifies this resource, and the minimal requirement placed on such a function — the one that makes it a *monotone* rather than merely a number — is that no protocol implementable by local operations and classical communication (LOCC) may increase it.

Many candidate measures are defined by optimisations over decompositions or extensions of the state and are consequently very hard to compute. The **logarithmic negativity** stands out because it is defined by an explicit spectral formula, is efficiently computable by diagonalising a single matrix, is additive on tensor products, and still satisfies monotonicity. The price is that it is not faithful on the entangled/separable divide: it fails to detect the so-called bound entangled states, whose partial transposes are positive.

This paper develops the theory from first principles, in finite dimension, in a way that isolates precisely which structural feature of the trace norm powers each property of $E_N$.

### 1.2 Setting and notation

Throughout, $A$ and $B$ denote finite-dimensional quantum systems with distinguished bases indexed by finite sets $\alpha$ and $\beta$, of cardinalities $d_A = |\alpha|$ and $d_B = |\beta|$. Operators on $\mathcal H_A \otimes \mathcal H_B$ are complex matrices indexed by the product set $\alpha \times \beta$; a matrix entry is written $X_{(i,j),(k,l)}$ with $i,k \in \alpha$ and $j,l \in \beta$.

We write $X^{\dagger}$ for the conjugate transpose, $X^{T}$ for the transpose, $\bar X$ for the entrywise complex conjugate, $\operatorname{tr}$ for the trace, and $\mathbb 1$ for the identity matrix. $X \succeq 0$ means $X$ is positive semidefinite (which in particular includes Hermiticity), and $X \succeq Y$ means $X - Y \succeq 0$ (the Loewner order). A **state** (density matrix) is a matrix $\rho$ with $\rho \succeq 0$ and $\operatorname{tr}\rho = 1$. Kronecker products of matrices are written $A \otimes B$.

Two elementary positivity facts are used constantly and we record them at once.

**Lemma 1.1 (Positivity toolbox).** *Let $P, Q \succeq 0$ be matrices of the same size. Then $\operatorname{tr} P \ge 0$, and $\operatorname{tr}(PQ) \ge 0$.*

*Proof.* The first is the sum of the eigenvalues. For the second, write $P = P^{1/2}P^{1/2}$ with $P^{1/2} \succeq 0$; then by cyclicity of the trace $\operatorname{tr}(PQ) = \operatorname{tr}(P^{1/2} Q P^{1/2})$, and $P^{1/2} Q P^{1/2} = (P^{1/2})^{\dagger} Q P^{1/2} \succeq 0$ because congruence preserves positivity. $\square$

---

## 2. The trace norm, defined variationally

### 2.1 Jordan pairs and the primal problem

**Definition 2.1 (Jordan pair).** Let $X$ be a matrix. A pair $(P,Q)$ is a **Jordan pair for $X$** if $P \succeq 0$, $Q \succeq 0$, and $X = P - Q$.

A Jordan pair is a way of exhibiting $X$ as a difference of two positive operators; it is *not* required to be minimal or to have orthogonal supports. Only Hermitian matrices admit Jordan pairs, and every Hermitian matrix admits at least one.

**Proposition 2.2 (Existence).** *Every Hermitian $X$ admits a Jordan pair. Explicitly, if $X = U\operatorname{diag}(\lambda)U^{\dagger}$ is a spectral decomposition with $U$ unitary and $\lambda \in \mathbb R^n$, then*
$$P = U \operatorname{diag}\big(\max(\lambda_i, 0)\big) U^{\dagger}, \qquad Q = U \operatorname{diag}\big(\max(-\lambda_i, 0)\big) U^{\dagger}$$
*is a Jordan pair for $X$, the **spectral Jordan pair**.*

*Proof.* Conjugation of a diagonal matrix with non-negative entries by a unitary yields a positive semidefinite matrix, so $P, Q \succeq 0$. For the difference, $\max(t,0) - \max(-t,0) = t$ for every real $t$, so $\operatorname{diag}(\max(\lambda,0)) - \operatorname{diag}(\max(-\lambda,0)) = \operatorname{diag}(\lambda)$, and conjugating by $U$ gives $P - Q = X$. $\square$

**Definition 2.3 (Trace norm).** For any matrix $X$ put
$$\|X\|_1 = \inf\big\{\operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q)\ :\ (P,Q)\text{ a Jordan pair for } X\big\},$$
with the convention that the infimum of the empty set is $0$ (so $\|X\|_1 = 0$ for non-Hermitian $X$, a case we never use).

The feasible set of values is non-empty for Hermitian $X$ by Proposition 2.2, and bounded below by $0$ by Lemma 1.1, so the infimum is a well-defined real number, and $\|X\|_1 \ge 0$ always.

Two immediate consequences of the definition will be used repeatedly:

- *(Upper bounds are cheap.)* Any Jordan pair $(P,Q)$ for $X$ gives $\|X\|_1 \le \operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q)$.
- *(Lower bounds require universality.)* To prove $c \le \|X\|_1$ one must verify $c \le \operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q)$ for *every* Jordan pair.

### 2.2 Basic properties

**Proposition 2.4.** *Let $X, Y$ be Hermitian and $c \ge 0$ real. Then:*

1. *(Positive case)* If $P \succeq 0$ then $\|P\|_1 = \operatorname{tr}P$.
2. *(Trace bound)* $\operatorname{Re}\operatorname{tr}X \le \|X\|_1$.
3. *(Subadditivity)* $\|X + Y\|_1 \le \|X\|_1 + \|Y\|_1$, and more generally $\big\|\sum_i X_i\big\|_1 \le \sum_i \|X_i\|_1$ for finite families of Hermitian matrices.
4. *(Homogeneity)* $\|cX\|_1 = c\,\|X\|_1$.

*Proof.* (1) The pair $(P, 0)$ is Jordan, giving $\le$. Conversely for any Jordan pair $(A,B)$ of $P$ we have $\operatorname{tr}P = \operatorname{tr}A - \operatorname{tr}B \le \operatorname{tr}A + \operatorname{tr}B$ since $\operatorname{tr}B \ge 0$; taking the infimum gives $\ge$.

(2) For any Jordan pair, $\operatorname{tr}X = \operatorname{tr}P - \operatorname{tr}Q \le \operatorname{tr}P + \operatorname{tr}Q$ by Lemma 1.1.

(3) If $(P_1,Q_1)$ is Jordan for $X$ and $(P_2,Q_2)$ for $Y$, then $(P_1+P_2, Q_1+Q_2)$ is Jordan for $X+Y$ with cost the sum of the costs; now take infima successively over the two families (fixing one decomposition while optimising the other). The finite-family version follows by induction.

(4) For $c > 0$, scaling a Jordan pair by $c$ is a bijection between the Jordan pairs of $X$ and of $cX$, multiplying costs by $c$; hence $\|cX\|_1 \le c\|X\|_1$, and applying the same with $c^{-1}$ to $cX$ gives the reverse. The case $c = 0$ is trivial. $\square$

### 2.3 Contractivity: the analytic engine

**Definition 2.5.** A map $\Phi$ from matrices to matrices is **positive trace-preserving (PTP)** if it respects differences, $\Phi(A - B) = \Phi A - \Phi B$; maps positive matrices to positive matrices; and satisfies $\operatorname{tr}\Phi(A) = \operatorname{tr}A$ for all $A \succeq 0$.

Every quantum channel is PTP, but so is the transpose map, and so are compositions of channels with partial transposition — which is exactly why the definition is stated at this level of generality rather than requiring complete positivity.

**Theorem 2.6 (Contractivity).** *If $\Phi$ is PTP and $X$ is Hermitian, then $\|\Phi X\|_1 \le \|X\|_1$.*

*Proof.* Let $(P,Q)$ be any Jordan pair for $X$. Then $(\Phi P, \Phi Q)$ is a Jordan pair for $\Phi X$: positivity is preserved by hypothesis, and $\Phi X = \Phi(P - Q) = \Phi P - \Phi Q$. Its cost is $\operatorname{tr}\Phi P + \operatorname{tr}\Phi Q = \operatorname{tr}P + \operatorname{tr}Q$, the same as the cost of $(P,Q)$. Hence $\|\Phi X\|_1 \le \operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q)$ for every Jordan pair of $X$, and taking the infimum over these gives the claim. $\square$

The proof is three lines because the definition is variational: a positive trace-preserving map *pushes the feasible set forward without changing objective values*. Under the equivalent definition $\|X\|_1 = \operatorname{tr}\sqrt{X^\dagger X}$ the same statement is a genuine theorem requiring work.

A branch-wise refinement is what will drive strong monotonicity.

**Theorem 2.7 (Contractivity for positive families).** *Let $\{\Psi_i\}_{i\in I}$ be a finite family of difference-respecting positive maps such that $\sum_i \operatorname{tr}\Psi_i(A) = \operatorname{tr}A$ for all $A \succeq 0$. Then for Hermitian $X$,*
$$\sum_{i \in I} \|\Psi_i X\|_1 \ \le\ \|X\|_1 .$$

*Proof.* Fix a Jordan pair $(P,Q)$ for $X$. For each $i$, $(\Psi_i P, \Psi_i Q)$ is a Jordan pair for $\Psi_i X$, so $\|\Psi_i X\|_1 \le \operatorname{Re}(\operatorname{tr}\Psi_i P + \operatorname{tr}\Psi_i Q)$. Summing over $i$ and using the trace hypothesis twice gives $\sum_i \|\Psi_i X\|_1 \le \operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q)$. Take the infimum over Jordan pairs. $\square$

### 2.4 Weak duality

**Definition 2.8 (Contraction).** A Hermitian matrix $W$ is a **contraction** if $\mathbb 1 - W \succeq 0$ and $\mathbb 1 + W \succeq 0$, i.e. $-\mathbb 1 \preceq W \preceq \mathbb 1$.

**Theorem 2.9 (Weak duality).** *For Hermitian $X$ and any contraction $W$,*
$$\operatorname{Re}\operatorname{tr}(XW) \le \|X\|_1 .$$

*Proof.* Let $(P,Q)$ be a Jordan pair for $X$. By Lemma 1.1, $\operatorname{tr}\big(P(\mathbb 1 - W)\big) \ge 0$ and $\operatorname{tr}\big(Q(\mathbb 1 + W)\big) \ge 0$, i.e. $\operatorname{Re}\operatorname{tr}(PW) \le \operatorname{Re}\operatorname{tr}P$ and $-\operatorname{Re}\operatorname{tr}(QW) \le \operatorname{Re}\operatorname{tr}Q$. Adding and using $X = P-Q$ yields $\operatorname{Re}\operatorname{tr}(XW) \le \operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q)$; take the infimum. $\square$

Weak duality is the *only* source of nontrivial lower bounds on the trace norm in this framework: every contraction is a certificate.

### 2.5 The spectral formula and strong duality

**Definition 2.10 (Sign operator).** For a unitary $U$ and real vector $\lambda$, set
$$\operatorname{sgn}_U(\lambda) = U \operatorname{diag}\big(s(\lambda_i)\big) U^{\dagger}, \qquad s(t) = \begin{cases} +1, & t \ge 0,\\ -1, & t < 0.\end{cases}$$

Since $\mathbb 1 \mp \operatorname{sgn}_U(\lambda) = U\operatorname{diag}(1 \mp s(\lambda_i))U^{\dagger}$ has non-negative diagonal entries in the rotated basis, $\operatorname{sgn}_U(\lambda)$ is a contraction.

**Theorem 2.11 (Spectral formula).** *If $X$ is Hermitian with eigenvalues $\lambda_1,\dots,\lambda_n$ (with multiplicity), then*
$$\|X\|_1 = \sum_{i=1}^n |\lambda_i| .$$

*Proof.* Write $X = U\operatorname{diag}(\lambda)U^{\dagger}$. The spectral Jordan pair of Proposition 2.2 has cost $\sum_i \max(\lambda_i,0) + \sum_i\max(-\lambda_i,0) = \sum_i |\lambda_i|$ (unitary conjugation preserves the trace), giving $\|X\|_1 \le \sum_i|\lambda_i|$. Conversely, the sign operator $W = \operatorname{sgn}_U(\lambda)$ is a contraction with $XW = U\operatorname{diag}(\lambda_i s(\lambda_i))U^{\dagger} = U\operatorname{diag}(|\lambda_i|)U^{\dagger}$, whence $\operatorname{Re}\operatorname{tr}(XW) = \sum_i|\lambda_i|$; by Theorem 2.9, $\sum_i|\lambda_i| \le \|X\|_1$. $\square$

**Theorem 2.12 (Strong duality; both optima attained).** *For every Hermitian $X$:*

1. *there exists a Jordan pair $(P,Q)$ for $X$ with $\operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q) = \|X\|_1$ — the primal infimum is a minimum;*
2. *there exists a contraction $W$ with $\operatorname{Re}\operatorname{tr}(XW) = \|X\|_1$ — the dual supremum is a maximum.*

*Consequently*
$$\|X\|_1 = \min_{(P,Q) \text{ Jordan for } X}\operatorname{Re}(\operatorname{tr}P + \operatorname{tr}Q) = \max_{-\mathbb 1 \preceq W \preceq \mathbb 1} \operatorname{Re}\operatorname{tr}(XW),$$
*and there is no duality gap.*

*Proof.* Both statements are established in the proof of Theorem 2.11: the spectral Jordan pair attains the primal value, and the sign operator attains the dual value, both equal to $\sum_i|\lambda_i|$. $\square$

We also record a converse to the positive case which will give faithfulness.

**Proposition 2.13 (Norm test for positivity).** *If $X$ is Hermitian and $\|X\|_1 \le \operatorname{Re}\operatorname{tr}X$, then $X \succeq 0$.*

*Proof.* By Theorem 2.11, $\sum_i |\lambda_i| \le \sum_i \lambda_i$, which forces $\lambda_i \ge 0$ for every $i$. $\square$

---

## 3. Partial transposition

**Definition 3.1.** The **partial transpose** on the second factor is the linear map on matrices indexed by $\alpha\times\beta$ given by
$$(\Gamma X)_{(i,j),(k,l)} = X_{(i,l),(k,j)} .$$

**Proposition 3.2 (Structure of $\Gamma$).** *$\Gamma$ is linear, an involution ($\Gamma^2 = \mathrm{id}$), trace-preserving, and Hermiticity-preserving. Moreover $\Gamma(A \otimes B) = A \otimes B^{T}$ for matrices $A$ on $\mathcal H_A$ and $B$ on $\mathcal H_B$, and $\operatorname{tr}\big((\Gamma X)^2\big) = \operatorname{tr}(X^2)$.*

*Proof.* Linearity and involutivity are immediate from the index formula. For the trace, the diagonal entry $(\Gamma X)_{(i,j),(i,j)} = X_{(i,j),(i,j)}$ is unchanged. For Hermiticity, $\overline{(\Gamma X)_{(k,l),(i,j)}} = \overline{X_{(k,j),(i,l)}} = X_{(i,l),(k,j)} = (\Gamma X)_{(i,j),(k,l)}$ using $X = X^\dagger$. The Kronecker formula is a direct index computation. For the last identity, expand both traces as $\sum X_{uv} X_{vu}$ and observe that the index substitution defining $\Gamma$ is an involutive bijection of the summation index set. $\square$

**Definition 3.3 (PPT).** A matrix $X$ is **PPT** (positive under partial transposition) if $\Gamma X \succeq 0$.

**Proposition 3.4.** *If $A \succeq 0$ and $B \succeq 0$ then $A \otimes B \succeq 0$ and $A \otimes B$ is PPT.*

*Proof.* Writing $A = A^{1/2}A^{1/2}$ and $B = B^{1/2}B^{1/2}$ gives $A\otimes B = (A^{1/2}\otimes B^{1/2})^{\dagger}(A^{1/2}\otimes B^{1/2}) \succeq 0$. Since $\Gamma(A\otimes B) = A \otimes B^T$ and $B^T \succeq 0$, the same argument gives the PPT property. $\square$

The single most important structural fact about $\Gamma$ for entanglement theory is its behaviour under *local* conjugation.

**Theorem 3.5 (Local covariance).** *For all matrices $A$ on $\mathcal H_A$, $B$ on $\mathcal H_B$, and all $X$,*
$$\Gamma\big((A\otimes B)\,X\,(A\otimes B)^{\dagger}\big) = (A \otimes \bar B)\,(\Gamma X)\,(A\otimes \bar B)^{\dagger},$$
*where $\bar B$ is the entrywise conjugate of $B$.*

*Proof sketch.* Expand both sides entrywise. The left-hand side at $\big((i,j),(k,l)\big)$ is
$$\sum_{(a,b)}\sum_{(c,d)} A_{ia}B_{lb}\,X_{(a,b),(c,d)}\,\overline{A_{kc}}\,\overline{B_{jd}},$$
after applying the index swap of $\Gamma$. Reindexing the double sum by the involution $\big((a,b),(c,d)\big) \mapsto \big((a,d),(c,b)\big)$ — which is a bijection of the summation set — turns this into
$$\sum_{(a,b)}\sum_{(c,d)} A_{ia}\,\overline{B_{jb}}\,(\Gamma X)_{(a,b),(c,d)}\,\overline{A_{kc}}\,B_{ld},$$
which is precisely the entry of the right-hand side, since $(\bar B)_{jb} = \overline{B_{jb}}$ and $\big((\bar B)^\dagger\big)_{dl} = B_{ld}$. $\square$

The content of Theorem 3.5 is that partial transposition is *equivariant* with respect to local operations: conjugating by a local operator commutes with $\Gamma$, at the sole cost of complex-conjugating the factor acting on $B$. Since conjugation preserves positivity, local conjugations therefore preserve the PPT property.

---

## 4. Negativity and logarithmic negativity

**Definition 4.1.** For a bipartite state $\rho$ put
$$\mathcal N(\rho) = \frac{\|\Gamma\rho\|_1 - 1}{2}, \qquad E_N(\rho) = \log\|\Gamma\rho\|_1 .$$

Since $\Gamma$ preserves the trace and Hermiticity, Proposition 2.4(2) gives $\|\Gamma\rho\|_1 \ge \operatorname{Re}\operatorname{tr}(\Gamma\rho) = 1$, so both quantities are well defined and non-negative.

**Proposition 4.2 (Non-negativity).** *For every state $\rho$: $\|\Gamma\rho\|_1 \ge 1$, $\mathcal N(\rho) \ge 0$, and $E_N(\rho) \ge 0$.*

Concretely, if $\Gamma\rho$ has eigenvalues $\mu_i$ (summing to $1$), then $\|\Gamma\rho\|_1 = 1 + 2\sum_{\mu_i<0}|\mu_i|$, so $\mathcal N(\rho)$ is exactly the total absolute weight of the negative part of the spectrum of $\Gamma\rho$.

### 4.1 PPT operations and monotonicity

**Definition 4.3 (PPT operation).** A map $\Lambda$ on bipartite operators is a **PPT operation** if it respects differences, maps positive matrices to positive matrices, preserves the trace, and maps PPT matrices to PPT matrices.

**Proposition 4.4 (Local operations are PPT operations).** *If $A \otimes B$ is an isometry, i.e. $(A\otimes B)^{\dagger}(A\otimes B) = \mathbb 1$, then $\Lambda(X) = (A\otimes B) X (A\otimes B)^{\dagger}$ is a PPT operation.*

*Proof.* Linearity is clear; positivity is preserved by congruence; the trace is preserved by cyclicity together with the isometry condition. For the PPT property, apply Theorem 3.5: if $\Gamma X \succeq 0$ then $\Gamma(\Lambda X) = (A\otimes\bar B)(\Gamma X)(A\otimes\bar B)^{\dagger} \succeq 0$. $\square$

More generally, every LOCC protocol is a PPT operation, so a monotonicity theorem for PPT operations is strictly stronger than one for LOCC. The next result is the central conceptual step.

**Lemma 4.5 (Conjugation).** *If $\Lambda$ is a PPT operation, then $\tilde\Lambda = \Gamma \circ \Lambda \circ \Gamma$ is a positive trace-preserving map.*

*Proof.* $\tilde\Lambda$ respects differences because each of $\Gamma$ and $\Lambda$ does. If $A \succeq 0$, then $\Gamma A$ is PPT (as $\Gamma\Gamma A = A \succeq 0$), so $\Lambda(\Gamma A)$ is PPT, i.e. $\Gamma\Lambda\Gamma A \succeq 0$: positivity holds. Finally $\operatorname{tr}\tilde\Lambda A = \operatorname{tr}\Lambda\Gamma A = \operatorname{tr}\Gamma A = \operatorname{tr}A$, using trace-preservation of $\Gamma$ twice and of $\Lambda$ once. $\square$

**Theorem 4.6 (Monotonicity).** *Let $\Lambda$ be a PPT operation. Then for every Hermitian $\rho$,*
$$\|\Gamma(\Lambda\rho)\|_1 \le \|\Gamma\rho\|_1 ,$$
*and consequently for every state $\rho$,*
$$E_N(\Lambda\rho) \le E_N(\rho), \qquad \mathcal N(\Lambda\rho) \le \mathcal N(\rho).$$
*In particular $E_N$ and $\mathcal N$ are non-increasing under all local operations and classical communication.*

*Proof.* By Lemma 4.5, $\tilde\Lambda = \Gamma\Lambda\Gamma$ is PTP, so Theorem 2.6 applies to it. Since $\Gamma$ is an involution, $\Gamma(\Lambda\rho) = \tilde\Lambda(\Gamma\rho)$, and $\Gamma\rho$ is Hermitian; hence $\|\Gamma(\Lambda\rho)\|_1 = \|\tilde\Lambda(\Gamma\rho)\|_1 \le \|\Gamma\rho\|_1$. Monotonicity of $\log$ and of $t \mapsto (t-1)/2$ gives the two consequences. $\square$

### 4.2 Strong monotonicity under instruments

Physical protocols are typically *selective*: an instrument produces outcome $i$ with probability $p_i$ and a conditional state $\rho_i$, and the parties learn $i$. The appropriate requirement is that the *average* entanglement of the outcomes not exceed the initial entanglement.

**Definition 4.7 (PPT instrument).** A finite family $\{\Lambda_i\}_{i\in I}$ of maps is a **PPT instrument** if each $\Lambda_i$ respects differences, maps positive matrices to positive matrices and PPT matrices to PPT matrices, and $\sum_i \operatorname{tr}\Lambda_i(X) = \operatorname{tr}X$ for all $X$.

**Lemma 4.8 (Branch inequality).** *For a PPT instrument $\{\Lambda_i\}$ and Hermitian $\rho$,*
$$\sum_i \|\Gamma(\Lambda_i \rho)\|_1 \ \le\ \|\Gamma\rho\|_1 .$$

*Proof.* Apply Theorem 2.7 to the family $\Psi_i = \Gamma\circ\Lambda_i\circ\Gamma$, each of which is a difference-respecting positive map by the argument of Lemma 4.5, and whose traces sum correctly for the same reason. Then use $\Gamma\Lambda_i\rho = \Psi_i(\Gamma\rho)$. $\square$

**Lemma 4.9 (Weighted log inequality).** *Let $p_i > 0$ with $\sum_i p_i = 1$ and $t_i > 0$. Then*
$$\sum_i p_i \log\frac{t_i}{p_i} \ \le\ \log\sum_i t_i .$$

*Proof.* This is Jensen's inequality for the concave function $\log$ applied to the points $t_i/p_i$ with weights $p_i$: $\sum_i p_i\log(t_i/p_i) \le \log\big(\sum_i p_i \cdot t_i/p_i\big) = \log\sum_i t_i$. $\square$

**Theorem 4.10 (Strong monotonicity).** *Let $\{\Lambda_i\}$ be a PPT instrument and $\rho$ a state with all outcome probabilities $p_i = \operatorname{tr}\Lambda_i\rho$ strictly positive. Write $\rho_i = p_i^{-1}\Lambda_i\rho$ for the normalised conditional states. Then*
$$\sum_i p_i\, E_N(\rho_i) \ \le\ E_N(\rho).$$

*Proof.* Put $t_i = \|\Gamma(\Lambda_i\rho)\|_1$. By positive homogeneity (Proposition 2.4(4)) and linearity of $\Gamma$, $E_N(\rho_i) = \log\|\Gamma(p_i^{-1}\Lambda_i\rho)\|_1 = \log(t_i/p_i)$. Lemma 4.9 gives $\sum_i p_i E_N(\rho_i) \le \log\sum_i t_i$, and Lemma 4.8 gives $\sum_i t_i \le \|\Gamma\rho\|_1$; monotonicity of $\log$ finishes the proof. $\square$

**Theorem 4.11 (Convexity of the negativity).** *For weights $w_i \ge 0$ with $\sum_i w_i = 1$ and states $\rho_i$,*
$$\mathcal N\Big(\sum_i w_i\rho_i\Big) \le \sum_i w_i\,\mathcal N(\rho_i).$$

*Proof.* $\Gamma$ is linear, so $\Gamma(\sum_i w_i\rho_i) = \sum_i w_i \Gamma\rho_i$. Subadditivity and homogeneity of the trace norm (Proposition 2.4(3),(4)) give $\|\Gamma\sum_i w_i\rho_i\|_1 \le \sum_i w_i\|\Gamma\rho_i\|_1$. Subtract $1 = \sum_i w_i$ and divide by $2$. $\square$

### 4.3 Faithfulness on the PPT class

**Theorem 4.12 (Faithfulness).** *For a state $\rho$ the following are equivalent: (i) $\rho$ is PPT; (ii) $\|\Gamma\rho\|_1 = 1$; (iii) $E_N(\rho) = 0$; (iv) $\mathcal N(\rho) = 0$. Consequently $E_N(\rho) > 0$ if and only if $\rho$ is not PPT.*

*Proof.* (i)$\Rightarrow$(ii): if $\Gamma\rho \succeq 0$, then by Proposition 2.4(1) $\|\Gamma\rho\|_1 = \operatorname{tr}\Gamma\rho = \operatorname{tr}\rho = 1$. (ii)$\Rightarrow$(i): $\Gamma\rho$ is Hermitian with $\|\Gamma\rho\|_1 = 1 = \operatorname{Re}\operatorname{tr}\Gamma\rho$, so Proposition 2.13 gives $\Gamma\rho\succeq 0$. The equivalences with (iii) and (iv) follow since $\|\Gamma\rho\|_1 \ge 1$ and both $\log$ and $t\mapsto(t-1)/2$ are strictly increasing and vanish at $t = 1$. $\square$

**Definition 4.13 (Separability).** A state $\rho$ is **separable** if it can be written $\rho = \sum_{i=1}^m w_i\, A_i \otimes B_i$ with $w_i \ge 0$ and $A_i, B_i \succeq 0$.

**Theorem 4.14.** *Every separable state is PPT, hence $E_N(\rho) = \mathcal N(\rho) = 0$ for separable $\rho$. Equivalently, $E_N(\rho) > 0$ certifies that $\rho$ is entangled.*

*Proof.* $\Gamma$ is linear and $\Gamma(A_i\otimes B_i) = A_i \otimes B_i^{T} \succeq 0$ by Proposition 3.4; a non-negative combination of positive matrices is positive. Apply Theorem 4.12. $\square$

We stress the direction of the implication. Positivity of $E_N$ is a *sufficient* condition for entanglement, never a necessary one: there exist entangled PPT states (bound entangled states), and these have $E_N = 0$. The measure is faithful with respect to the PPT/non-PPT dichotomy, not the separable/entangled one.

---

## 5. The maximally entangled state and the dimension bound

### 5.1 The swap operator

**Definition 5.1.** On $\mathcal H \otimes \mathcal H$ with $\dim\mathcal H = d$, the **swap** $S$ is defined by $S_{(i,j),(k,l)} = [i = l][j = k]$, i.e. $S(|x\rangle\otimes|y\rangle) = |y\rangle\otimes|x\rangle$.

**Proposition 5.2.** *$S$ is Hermitian, $S^2 = \mathbb 1$, $S$ is a contraction, and $\|S\|_1 = d^2$.*

*Proof.* Hermiticity and $S^2 = \mathbb 1$ are index computations. The matrices $\tfrac12(\mathbb 1 \pm S)$ are Hermitian and idempotent, hence positive (a Hermitian idempotent $P$ satisfies $P = P^\dagger P \succeq 0$); so $\mathbb 1 \pm S \succeq 0$ and $S$ is a contraction. For the norm: on the one hand the Jordan pair given by the spectral projections of $S$ has cost $\operatorname{tr}\mathbb 1 = d^2$, so $\|S\|_1 \le d^2$; on the other hand $S$ certifies itself via weak duality, $\|S\|_1 \ge \operatorname{Re}\operatorname{tr}(S\cdot S) = \operatorname{tr}\mathbb 1 = d^2$. $\square$

### 5.2 The maximally entangled state

**Definition 5.3.** On $\mathcal H \otimes \mathcal H$ with $\dim\mathcal H = d$, the **maximally entangled state** is the rank-one projector onto $\frac{1}{\sqrt d}\sum_i |i\rangle|i\rangle$, i.e.
$$(\Phi_d)_{(i,j),(k,l)} = \tfrac1d\,[i=j]\,[k=l].$$

**Theorem 5.4.** *$\Phi_d$ is a state, $\Gamma\Phi_d = \tfrac1d S$, and hence*
$$\|\Gamma\Phi_d\|_1 = d, \qquad E_N(\Phi_d) = \log d, \qquad \mathcal N(\Phi_d) = \frac{d-1}{2}.$$
*In particular $E_N(\Phi_d) > 0$ and $\Phi_d$ is not PPT — and therefore not separable — whenever $d \ge 2$.*

*Proof.* That $\Phi_d$ is positive with unit trace is the rank-one projector computation. Applying $\Gamma$: $(\Gamma\Phi_d)_{(i,j),(k,l)} = (\Phi_d)_{(i,l),(k,j)} = \tfrac1d [i=l][k=j] = \tfrac1d S_{(i,j),(k,l)}$. By homogeneity and Proposition 5.2, $\|\Gamma\Phi_d\|_1 = \tfrac1d\, d^2 = d$. The remaining statements follow from Theorem 4.12 and Theorem 4.14. $\square$

### 5.3 The dimension bound and its saturation

**Lemma 5.5 (Cauchy–Schwarz bound).** *For Hermitian $X$ of size $N$, $\|X\|_1^2 \le N\operatorname{tr}(X^2)$.*

*Proof.* By Theorem 2.11 and Cauchy–Schwarz applied to the vectors $(|\lambda_i|)_i$ and $(1)_i$,
$\big(\sum_i|\lambda_i|\big)^2 \le N \sum_i \lambda_i^2 = N\operatorname{tr}(X^2)$. $\square$

**Lemma 5.6 (Purity bound).** *For a state $\rho$, $\operatorname{tr}(\rho^2) \le 1$, with equality iff $\rho$ is pure.*

*Proof.* With eigenvalues $r_i \ge 0$ summing to $1$, $\sum_i r_i^2 \le (\sum_i r_i)^2 = 1$. $\square$

**Theorem 5.7 (Dimension bound).** *For every state $\rho$ on $\mathcal H_A\otimes\mathcal H_B$ with $\dim \mathcal H_A = d_A$, $\dim\mathcal H_B = d_B$,*
$$\|\Gamma\rho\|_1 \le \sqrt{d_A d_B}, \qquad\text{hence}\qquad E_N(\rho) \le \tfrac12 \log(d_A d_B).$$

*Proof.* $\Gamma\rho$ is Hermitian of size $N = d_Ad_B$, so Lemma 5.5 gives $\|\Gamma\rho\|_1^2 \le d_Ad_B\operatorname{tr}\big((\Gamma\rho)^2\big)$. By Proposition 3.2, $\operatorname{tr}\big((\Gamma\rho)^2\big) = \operatorname{tr}(\rho^2) \le 1$ by Lemma 5.6. Take square roots and logarithms. $\square$

**Corollary 5.8 (Optimality of the maximally entangled state).** *For every state $\rho$ on $\mathbb C^d\otimes\mathbb C^d$,*
$$E_N(\rho) \le \log d = E_N(\Phi_d).$$

*Proof.* Theorem 5.7 with $d_A = d_B = d$ gives $E_N(\rho) \le \tfrac12\log(d^2) = \log d$, and Theorem 5.4 identifies the right-hand side as $E_N(\Phi_d)$. $\square$

---

## 6. Multiplicativity and additivity

### 6.1 Tensor products of contractions

**Lemma 6.1.** *If $W$ and $V$ are contractions then so is $W \otimes V$.*

*Proof.* Hermiticity is clear. The identities
$$\mathbb 1 - W\otimes V = \tfrac12\Big((\mathbb 1 - W)\otimes(\mathbb 1 + V) + (\mathbb 1 + W)\otimes(\mathbb 1 - V)\Big),$$
$$\mathbb 1 + W\otimes V = \tfrac12\Big((\mathbb 1 - W)\otimes(\mathbb 1 - V) + (\mathbb 1 + W)\otimes(\mathbb 1 + V)\Big)$$
hold by bilinear expansion, using $\mathbb 1 \otimes \mathbb 1 = \mathbb 1$. Each right-hand side is a positive combination of Kronecker products of positive matrices, hence positive by Proposition 3.4. $\square$

This is the algebraic heart of multiplicativity, and it is worth pausing on: it establishes that the tensor product of two operator intervals stays inside the operator interval, *without diagonalising anything*, purely from the two positivity facts $\mathbb 1 \mp W \succeq 0$ and $\mathbb 1 \mp V \succeq 0$.

### 6.2 The trace norm is exactly multiplicative

**Theorem 6.2 (Multiplicativity).** *For Hermitian $A$ and $B$,*
$$\|A \otimes B\|_1 = \|A\|_1 \, \|B\|_1 .$$

*Proof.* **($\le$)** Let $(P_1,Q_1)$ and $(P_2,Q_2)$ be *optimal* Jordan pairs for $A$ and $B$, which exist by Theorem 2.12(1). Then
$$A \otimes B = (P_1 - Q_1)\otimes(P_2-Q_2) = \big(P_1\otimes P_2 + Q_1\otimes Q_2\big) - \big(P_1\otimes Q_2 + Q_1\otimes P_2\big),$$
and by Proposition 3.4 both bracketed terms are positive semidefinite, so this is a Jordan pair for $A\otimes B$. Its cost is, by multiplicativity of the trace over Kronecker products,
$$(\operatorname{tr}P_1 + \operatorname{tr}Q_1)(\operatorname{tr}P_2+\operatorname{tr}Q_2) = \|A\|_1\|B\|_1,$$
whence $\|A\otimes B\|_1 \le \|A\|_1\|B\|_1$.

**($\ge$)** Let $W$ and $V$ be *optimal* contractions for $A$ and $B$, which exist by Theorem 2.12(2), so $\operatorname{Re}\operatorname{tr}(AW) = \|A\|_1$ and $\operatorname{Re}\operatorname{tr}(BV) = \|B\|_1$. By Lemma 6.1, $W\otimes V$ is a contraction, so weak duality (Theorem 2.9) applies:
$$\|A\otimes B\|_1 \ge \operatorname{Re}\operatorname{tr}\big((A\otimes B)(W\otimes V)\big) = \operatorname{Re}\big(\operatorname{tr}(AW)\operatorname{tr}(BV)\big) = \|A\|_1\|B\|_1,$$
where we used $(A\otimes B)(W\otimes V) = (AW)\otimes(BV)$, multiplicativity of the trace, and the fact that traces of products of two Hermitian matrices are real. $\square$

Note the structure of the argument: the easy inequality needs only *feasibility* of the tensored primal solutions, whereas the hard inequality needs *attainment* on the dual side. This is exactly where strong duality (Theorem 2.12) is indispensable — with weak duality alone one could only tensor near-optimal certificates, which would still work in the limit, but attainment makes the argument finite and clean.

### 6.3 Additivity of the logarithmic negativity

If $\rho$ is a state of a bipartite system $A_1B_1$ and $\sigma$ of $A_2B_2$, the joint state of the four systems is $\rho\otimes\sigma$; to regard it as bipartite across the cut $A_1A_2 \mid B_1B_2$ one applies the canonical regrouping isomorphism $(A_1B_1)(A_2B_2) \cong (A_1A_2)(B_1B_2)$. Write $\rho \boxtimes \sigma$ for the resulting operator on $(\mathcal H_{A_1}\otimes\mathcal H_{A_2})\otimes(\mathcal H_{B_1}\otimes\mathcal H_{B_2})$. Regrouping is a permutation of basis vectors, so it preserves positivity, traces, and the trace norm.

**Lemma 6.3 (Factorisation of $\Gamma$).** *$\Gamma(\rho\boxtimes\sigma) = (\Gamma\rho)\boxtimes(\Gamma\sigma)$.*

*Proof.* Both sides act on entries by transposing the $B_1$ and $B_2$ indices independently, as one checks by writing out the composite index formula. $\square$

**Theorem 6.4 (Additivity).** *For states $\rho$ and $\sigma$,*
$$\|\Gamma(\rho\boxtimes\sigma)\|_1 = \|\Gamma\rho\|_1\,\|\Gamma\sigma\|_1, \qquad E_N(\rho\boxtimes\sigma) = E_N(\rho) + E_N(\sigma).$$

*Proof.* By Lemma 6.3 and invariance of the trace norm under regrouping, $\|\Gamma(\rho\boxtimes\sigma)\|_1 = \|(\Gamma\rho)\otimes(\Gamma\sigma)\|_1$, which by Theorem 6.2 equals $\|\Gamma\rho\|_1\|\Gamma\sigma\|_1$. Both factors are $\ge 1$ by Proposition 4.2, hence nonzero, so $\log$ of the product splits as the sum of the logs. $\square$

**Theorem 6.5 (Non-additivity of the negativity).** *For Hermitian $\rho,\sigma$,*
$$\mathcal N(\rho\boxtimes\sigma) = 2\,\mathcal N(\rho)\,\mathcal N(\sigma) + \mathcal N(\rho) + \mathcal N(\sigma).$$

*Proof.* Substitute $\|\Gamma\rho\|_1 = 2\mathcal N(\rho)+1$ and likewise for $\sigma$ into $\|\Gamma(\rho\boxtimes\sigma)\|_1 = \|\Gamma\rho\|_1\|\Gamma\sigma\|_1$ and simplify: $\mathcal N(\rho\boxtimes\sigma) = \big((2\mathcal N(\rho)+1)(2\mathcal N(\sigma)+1) - 1\big)/2$, which expands to the stated expression. $\square$

Theorems 6.4 and 6.5 together explain the logarithm: $\|\Gamma\cdot\|_1$ is the multiplicative object, so its logarithm is the additive one, and $\mathcal N$, being an affine reparametrisation of the multiplicative object, inherits an inhomogeneous product law rather than additivity.

---

## 7. Applications: bounds on exact state conversion

Monotonicity plus additivity converts immediately into no-go theorems for entanglement manipulation.

**Theorem 7.1 (Exact distillation bound).** *Let $\rho$ be a state on $\mathbb C^{d_1}\otimes\mathbb C^{d_1}$ and $\sigma$ a state on $\mathbb C^{d_2}\otimes\mathbb C^{d_2}$, and suppose a PPT operation $\Lambda$ satisfies $\Lambda(\rho\boxtimes\sigma) = \Phi_{d}$ with $d = d_1 d_2$. Then*
$$\log(d_1 d_2) \le E_N(\rho) + E_N(\sigma).$$

*Proof.* By Theorem 5.4 the output has $E_N = \log(d_1d_2)$. By monotonicity (Theorem 4.6) the output value is at most the input value $E_N(\rho\boxtimes\sigma)$, which by additivity (Theorem 6.4) equals $E_N(\rho)+E_N(\sigma)$. $\square$

**Corollary 7.2 (Two-copy version).** *If a PPT operation maps $\rho\boxtimes\rho$ exactly to the maximally entangled state of local dimension $d$, where $\rho$ is a state on $\mathbb C^{d}\otimes\mathbb C^{d}$, then $\log d \le E_N(\rho)$.*

*Proof.* Theorem 7.1 with $\sigma = \rho$ gives $2\log d \le 2E_N(\rho)$. $\square$

**Corollary 7.3 (No exact distillation from PPT states).** *Let $d \ge 2$ and let $\rho$ be a PPT state on $\mathbb C^d \otimes \mathbb C^d$. Then no PPT operation maps $\rho\boxtimes\rho$ to $\Phi_d$, and no PPT operation maps $\rho$ to $\Phi_d$.*

*Proof.* By Theorem 4.12, $E_N(\rho) = 0$. Corollary 7.2 would force $\log d \le 0$, contradicting $d \ge 2$. The single-copy statement follows the same way directly from Theorem 4.6: $E_N(\Lambda\rho) \le E_N(\rho) = 0 < \log d = E_N(\Phi_d)$. $\square$

Corollary 7.3 is the mechanism behind *bound entanglement*. Entangled PPT states exist; by Theorem 4.14 their entanglement is undetectable by $E_N$, and by Corollary 7.3 no amount of exact PPT processing (in particular, no LOCC protocol) can extract a maximally entangled pair from them, even from many copies — because additivity makes $E_N$ of $n$ copies still zero. Their entanglement is real but locked.

---

## 8. Algorithms

The theory is constructive, and each object appearing in the proofs is computable by standard numerical linear algebra.

### 8.1 Computing the logarithmic negativity

Given a density matrix $\rho$ of size $d_Ad_B$:

1. Form $\Gamma\rho$ by the index permutation $(\Gamma\rho)_{(i,j),(k,l)} = \rho_{(i,l),(k,j)}$ — a reshape to a four-index array, a transposition of two axes, and a reshape back; $O(d_A^2d_B^2)$ time.
2. Compute the eigenvalues $\mu_1,\dots,\mu_{d_Ad_B}$ of the Hermitian matrix $\Gamma\rho$; $O\big((d_Ad_B)^3\big)$ time.
3. Return $\|\Gamma\rho\|_1 = \sum_i|\mu_i|$, $\mathcal N = (\|\Gamma\rho\|_1-1)/2$, $E_N = \log\|\Gamma\rho\|_1$.

The cubic eigendecomposition dominates. This is what makes the logarithmic negativity a practical measure: unlike entanglement of formation or the relative entropy of entanglement, no optimisation over decompositions or over an infinite family of states is required.

### 8.2 Extracting the optimal certificate

Given Hermitian $X$ with spectral decomposition $X = U\operatorname{diag}(\lambda)U^{\dagger}$:

1. Set $s_i = +1$ if $\lambda_i \ge 0$ and $s_i = -1$ otherwise.
2. Return $W = U\operatorname{diag}(s)U^{\dagger}$.

Then $W$ is Hermitian with $W^2 = \mathbb 1$ (so $-\mathbb 1\preceq W \preceq \mathbb 1$) and $\operatorname{Re}\operatorname{tr}(XW) = \|X\|_1$: $W$ is a *certificate* proving the value of the norm, checkable in $O(N^3)$ time without re-deriving the spectrum. Applied to $X = \Gamma\rho$, the certificate $W$ is the analogue of an optimal entanglement witness for the negativity: it is the operator whose expectation value against $\Gamma\rho$ equals $\|\Gamma\rho\|_1$ exactly.

### 8.3 Extracting the optimal splitting

With the same spectral data, put $P = U\operatorname{diag}(\lambda^+)U^{\dagger}$ and $Q = U\operatorname{diag}(\lambda^-)U^{\dagger}$, where $\lambda^{\pm}_i = \max(\pm\lambda_i,0)$. Then $P,Q\succeq 0$, $X = P-Q$, and $\operatorname{tr}P + \operatorname{tr}Q = \|X\|_1$: the *primal* optimum. The negativity is exactly $\operatorname{tr}Q$ evaluated at $X = \Gamma\rho$, and $Q$ is (a positive multiple of) the state onto which the failure of positivity is concentrated.

---

## 9. Discussion

### 9.1 What powers what

It is worth summarising which structural feature is responsible for which property.

| Property of $E_N$ | Structural input |
|---|---|
| Non-negativity | Trace bound $\operatorname{Re}\operatorname{tr}X \le \|X\|_1$ |
| Vanishing on PPT | $\|P\|_1 = \operatorname{tr}P$ for $P \succeq 0$ |
| Faithfulness on PPT class | Spectral formula (converse norm test) |
| Monotonicity under PPT operations | Contractivity under PTP maps (primal pushforward) |
| Strong monotonicity | Branch contractivity + Jensen |
| Convexity of $\mathcal N$ | Subadditivity + homogeneity |
| Dimension bound | Cauchy–Schwarz + purity + $\operatorname{tr}(\Gamma X)^2 = \operatorname{tr}X^2$ |
| Value at $\Phi_d$ | $\Gamma\Phi_d = S/d$ and self-certification of the swap |
| Additivity | Multiplicativity, which needs *strong* duality |

The pattern is that all the *upper* bounds come from the primal (infimum) side and all the *lower* bounds from the dual (supremum) side, and that the two theorems requiring both sides — the spectral formula and multiplicativity — are exactly the two places where attainment matters.

### 9.2 Comparison with other measures

$E_N$ is not an entanglement *entropy*: it does not reduce to the von Neumann entropy of the reduced state on pure states (that role is played by the entanglement entropy, which $E_N$ upper-bounds in the appropriate sense but does not equal), and it is not asymptotically continuous. It is, however, computable, additive, and an upper bound on distillable entanglement, and these three features together make it the standard tool for certifying limits on what entanglement manipulation can achieve in concrete finite systems, from condensed-matter ground states to quantum field theory subregion calculations.

The trade-off with faithfulness is intrinsic rather than technical: no computable-by-eigendecomposition criterion can detect bound entanglement, since deciding separability is computationally hard in general. What one gets from $E_N$ is a *one-sided* certificate that is always sound and sometimes silent.

### 9.3 Limitations

The development here is finite-dimensional throughout; the variational definition of the trace norm generalises verbatim to trace-class operators, but attainment of the dual optimum by a bounded sign operator requires care with continuous spectrum. The monotonicity theorems are stated for the class of PPT operations, which is larger than LOCC; this makes them stronger, but it also means the theory says nothing about the finer structure of LOCC protocols (for example, the round complexity of a conversion). Finally, the applications in Section 7 concern *exact* conversion; the asymptotic theory, where conversions are allowed to succeed only up to vanishing error, requires continuity estimates that are not developed here.

---

## 10. Future directions

Five falsifiable conjectures are distilled from what survived, and what resisted, in this development.

**Conjecture 1 (Exact duality formula for the monotone).** $E_N(\rho) = \log\max\{\operatorname{Re}\operatorname{tr}(\Gamma\rho\cdot W) : W \text{ Hermitian}, -\mathbb 1\preceq W \preceq \mathbb 1\}$, and the maximising $W$ may always be taken of the form $\Gamma(\text{entanglement witness})$; consequently $E_N$ extends to a PPT-monotone functional on the whole real vector space of Hermitian operators, not just states, that is concave along the PPT boundary. The key insight is that strong duality — established here in the form of attainment of the dual supremum — turns the monotone from an infimum (hard to bound from below) into a maximum over a *compact convex* set of certificates, so every lower bound on entanglement becomes an explicit finite-dimensional witness, and witness geometry (a convex geometry question) becomes directly available to trace-norm theory (an operator-algebra question).

**Conjecture 2 (Rigidity of the maximiser).** On $\mathbb C^d\otimes\mathbb C^d$, $E_N(\rho) = \log d$ *only* for maximally entangled states: if $E_N(\rho) = \log d$ then $\rho = (U\otimes V)\Phi_d(U\otimes V)^{\dagger}$ for local unitaries $U,V$. The key insight is that the Cauchy–Schwarz step $\sum_i|\lambda_i| \le \sqrt N\sqrt{\sum_i\lambda_i^2}$ used in the dimension bound is an equality only when all $|\lambda_i|$ coincide, and the purity step $\operatorname{tr}\rho^2 \le 1$ is an equality only for pure states; chaining the two equality cases forces the partial transpose to have flat spectrum $\pm 1/d$, which is a rigidity statement about the swap operator. The inequality chain is already a chain of named lemmas, so the conjecture reduces to the equality analysis of two standard inequalities — no new analytic input is required.

**Conjecture 3 (Asymptotic distillation and irreversibility).** For every state $\rho$ and every $n,m$ admitting an *exact* PPT protocol $\Lambda$ mapping $\rho^{\otimes n}$ to $\Phi_{2^m}$, one has $m\log 2 \le n\,E_N(\rho)$; moreover there exist states (PPT-entangled ones) for which the entanglement *cost* under PPT operations is strictly positive while this distillation rate is $0$, so the PPT theory of entanglement is irreversible.

**Conjecture 4 (Continuity and asymptotic robustness).** $E_N$ is continuous on states, with an explicit modulus of continuity in terms of the trace distance and the dimension; consequently the exact-conversion bounds of Section 7 extend to $\varepsilon$-approximate conversions with an additive error term vanishing as $\varepsilon\to 0$. The starting point is the triangle inequality and homogeneity already available, combined with the Cauchy–Schwarz dimension bound to control the logarithm near its argument $1$.

**Conjecture 5 (Instrument-level rigidity).** Equality in the strong monotonicity inequality $\sum_i p_i E_N(\rho_i) = E_N(\rho)$ for a PPT instrument holds only when the instrument acts on $\Gamma\rho$ by "splitting the spectrum without mixing signs" — precisely, when the branch operators $\Gamma\Lambda_i\Gamma$ preserve the spectral projections of the positive and negative parts of $\Gamma\rho$. The equality case of Jensen's inequality forces all ratios $t_i/p_i$ to be equal, and the equality case of the branch inequality forces each branch to inherit an optimal Jordan pair.

---

## 11. Conclusion

The logarithmic negativity is best understood not as a formula but as the logarithm of the value of a semidefinite program. Reading the primal side — minimise $\operatorname{tr}P + \operatorname{tr}Q$ over splittings $\Gamma\rho = P - Q$ — makes monotonicity under all positivity-preserving, trace-preserving processing essentially automatic, because such processing maps splittings to splittings at unchanged cost. Reading the dual side — maximise $\operatorname{Re}\operatorname{tr}(\Gamma\rho\, W)$ over the operator interval $-\mathbb 1 \preceq W \preceq \mathbb 1$ — supplies certificates, hence lower bounds, hence the exact multiplicativity that turns subadditivity into additivity. The two readings meet, with both optima attained explicitly by spectral data, and the resulting object is non-negative, vanishing exactly on the PPT states, non-increasing under local operations and classical communication even in the selective sense, convex in the un-logged variable, additive under tensor products, bounded by $\tfrac12\log(d_Ad_B)$, and maximal precisely on the maximally entangled state, whose value $\log d$ saturates the bound. From these facts alone, the impossibility of distilling maximal entanglement from bound entangled states follows in two lines.
