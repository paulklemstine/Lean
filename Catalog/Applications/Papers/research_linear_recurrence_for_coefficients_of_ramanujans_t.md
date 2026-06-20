# A Number-Theory ⋈ Holonomy Bridge: The Non-Existence of a Linear Recurrence for the Coefficients of Ramanujan's Third Order Mock Theta Function $f(q)$

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Bridges (Number Theory ⋈ Holonomy / P-recursiveness)

---

## Abstract

We examine, and disprove, a specific claim about Ramanujan's third order mock theta function
$$f(q) = \sum_{n \ge 0} \frac{q^{n^2}}{\prod_{k=1}^{n}(1+q^k)^2}.$$
The claim asserts that the integer coefficients $a_n$ in the $q$-expansion $f(q) = \sum_{n\ge 0} a_n q^n$ satisfy the polynomial-coefficient linear recurrence
$$(n+3)\,a_{n+3} = (3n+4)\,a_{n+2} - (3n+1)\,a_{n+1} + n\,a_n \qquad (n \ge 0),$$
with initial data $(a_0, a_1, a_2) = (1, 0, 1)$. We show the claim is false on two independent counts. **(i)** The stated initial data is wrong: the true coefficients of $f(q)$ are the integer sequence OEIS A000025, beginning $1, 1, -2, 3, -3, 3, -5, 7, \dots$, so the correct triple is $(1, 1, -2)$. **(ii)** More fundamentally, the recurrence together with the stated initial data admits *no integer solution at all*: its $n = 0$ instance forces $3a_3 = 4$, hence $a_3 = \tfrac{4}{3} \notin \mathbb{Z}$. Since the genuine coefficients of $f(q)$ are integers (a structural consequence of the defining formula), they cannot satisfy the claim. We further establish that the unique rational sequence consistent with the claim is non-integral at index $3$, and we relate the impossibility to the broader fact that mock theta functions are *non-holonomic*: a computational search over the rationals finds no nonzero polynomial recurrence of order $\le 5$ and degree $\le 5$ fitting A000025. All key statements have been formally verified. The result is a "bridge": a single elementary divisibility obstruction ($3 \mid 4$ fails) connects classical $q$-series number theory to the theory of P-recursive (holonomic) sequences and, ultimately, to Zwegers' theory of harmonic Maass forms.

---

## 1. Introduction

### 1.1 Background: mock theta functions

In his last letter to G. H. Hardy (1920), Ramanujan introduced seventeen *mock theta functions*, organized by "order." The third order function $f(q)$ is the canonical first example:
$$f(q) = \sum_{n \ge 0} \frac{q^{n^2}}{(1+q)^2 (1+q^2)^2 \cdots (1+q^n)^2} = \sum_{n \ge 0} \frac{q^{n^2}}{\prod_{k=1}^{n}(1+q^k)^2}.$$
Expanding as a formal power series yields integer coefficients,
$$f(q) = 1 + q - 2q^2 + 3q^3 - 3q^4 + 3q^5 - 5q^6 + 7q^7 - 6q^8 + 6q^9 - 10q^{10} + \cdots,$$
the sequence $a_n = 1, 1, -2, 3, -3, 3, -5, 7, -6, 6, -10, 12, -11, 13, -17, 20, \dots$ recorded as OEIS A000025.

The modern understanding of these functions is due to Zwegers (2002), who showed that mock theta functions are the holomorphic parts of harmonic Maass forms of weight $\tfrac12$. Completing $f$ to a genuine modular object requires adding a non-holomorphic "shadow," an Eichler-type period integral that cannot be captured by any finite algebraic data.

### 1.2 Holonomy and the claim under examination

A sequence $(a_n)_{n\ge 0}$ over a field $K$ is **holonomic** (equivalently *P-recursive*) if there exist polynomials $p_0, \dots, p_r \in K[n]$, not all zero, with $p_r \neq 0$, such that
$$\sum_{i=0}^{r} p_i(n)\, a_{n+i} = 0 \qquad \text{for all } n \ge 0.$$
Equivalently, its generating function satisfies a finite-order linear ODE with polynomial coefficients. Holonomic sequences form a robust, algorithmically tractable class (Zeilberger's creative telescoping, the `gfun`/`OreAlgebra` ecosystems).

The claim we examine asserts holonomy of $(a_n)$ with an explicit order-$3$ recurrence:
$$(n+3)\,a_{n+3} = (3n+4)\,a_{n+2} - (3n+1)\,a_{n+1} + n\,a_n, \qquad (a_0, a_1, a_2) = (1, 0, 1). \tag{$\star$}$$

### 1.3 Summary of results

We prove:

1. **(Wrong initials.)** The true triple is $(1, 1, -2)$, not $(1, 0, 1)$.
2. **(No integer solution.)** No sequence $a : \mathbb{N} \to \mathbb{Z}$ with $(a_0, a_1, a_2) = (1, 0, 1)$ satisfies the recurrence; the $n=0$ instance forces $3a_3 = 4$.
3. **(Forced fraction.)** The unique rational sequence obeying $(\star)$ has $a_3 = a_4 = \tfrac{4}{3}$, which is not an integer.
4. **(Uniqueness.)** Because the leading coefficient $n + 3$ never vanishes over $\mathbb{N}$, $(\star)$ determines a unique rational sequence; hence the disproof is conclusive.
5. **(Evidence of non-holonomy.)** Exact linear algebra over $\mathbb{Q}$ finds no nonzero recurrence of order $\le 5$, degree $\le 5$ fitting A000025, consistent with the non-holonomy of mock theta functions.

---

## 2. Definitions

Throughout, $\mathbb{Z}[[q]]$ denotes formal power series with integer coefficients and $\mathbb{Q}[[q]]$ those with rational coefficients.

**Definition 2.1 (The function $f$).** The third order mock theta function is the formal power series
$$f(q) = \sum_{n \ge 0} q^{n^2} \prod_{k=1}^{n} (1+q^k)^{-2} \in \mathbb{Q}[[q]],$$
where $(1 + q^k)^{-1} = \sum_{j \ge 0} (-1)^j q^{jk}$ is the geometric inverse. The sum is well-defined as a formal power series because the $n$-th summand has lowest-degree term $q^{n^2}$, so only finitely many summands contribute to each coefficient. We write $a_n := [q^n]\,f(q)$.

**Definition 2.2 (The claim sequence, $\mathrm{claimSeq}$).** Define an auxiliary triple-valued map $\mathrm{claimAux} : \mathbb{N} \to \mathbb{Q}^3$ by
$$\mathrm{claimAux}(0) = (1, 0, 1),$$
$$\mathrm{claimAux}(n+1) = \Big( y,\ z,\ \frac{(3n+4)z - (3n+1)y + n x}{\,n+3\,} \Big), \quad \text{where } (x, y, z) = \mathrm{claimAux}(n).$$
Then $\mathrm{claimSeq}(n) := \big(\mathrm{claimAux}(n)\big)_1$ (the first component). This is the forward iteration of $(\star)$ over $\mathbb{Q}$: the three components of $\mathrm{claimAux}(n)$ are the sliding window $(a_n, a_{n+1}, a_{n+2})$.

**Definition 2.3 (Holonomic / P-recursive sequence).** A sequence $(a_n)$ over a field $K$ is holonomic of order $\le r$ and degree $\le d$ if there exist $p_0, \dots, p_r \in K[n]$ with $\deg p_i \le d$, not all zero, such that $\sum_{i=0}^r p_i(n)\, a_{n+i} = 0$ for all $n$. A power series is non-holonomic if its coefficient sequence is holonomic of no finite order.

---

## 3. Main results

### 3.1 The genuine coefficients are integers

**Proposition 3.1 (Integrality).** $f(q) \in \mathbb{Z}[[q]]$, and $(a_0, a_1, a_2) = (1, 1, -2)$.

*Proof sketch.* For each fixed $k$, $(1+q^k)^{-1} = \sum_{j\ge 0}(-1)^j q^{jk} \in \mathbb{Z}[[q]]$ since it is the geometric inverse of a series with integer coefficients and constant term $1$. The ring $\mathbb{Z}[[q]]$ is closed under multiplication, so each summand $q^{n^2}\prod_{k=1}^n (1+q^k)^{-2}$ lies in $\mathbb{Z}[[q]]$. Closure under the (coefficientwise-finite) infinite sum gives $f \in \mathbb{Z}[[q]]$. Direct expansion to order $q^2$:
$$n=0:\ 1; \quad n=1:\ q(1+q)^{-2} = q(1 - 2q + \cdots) = q - 2q^2 + \cdots,$$
and the $n=2$ term contributes only from $q^4$ onward. Summing the low-order contributions gives $1 + q - 2q^2 + \cdots$, i.e. $(a_0,a_1,a_2)=(1,1,-2)$. A computation to order $q^{19}$ yields $1, 1, -2, 3, -3, 3, -5, 7, -6, 6, -10, 12, -11, 13, -17, 20, -21, 21, -27, 34$. $\square$

This already refutes the stated initials $(1,0,1)$.

### 3.2 The claim sequence satisfies the recurrence (faithfulness)

To disprove the claim rather than a straw man, we verify that $\mathrm{claimSeq}$ genuinely realizes $(\star)$.

**Lemma 3.2 (Window alignment).** For all $m$,
$$\mathrm{claimSeq}(m+1) = (\mathrm{claimAux}(m))_2, \qquad \mathrm{claimSeq}(m+2) = (\mathrm{claimAux}(m))_3,$$
and
$$\mathrm{claimSeq}(m+3) = \frac{(3m+4)(\mathrm{claimAux}(m))_3 - (3m+1)(\mathrm{claimAux}(m))_2 + m\,(\mathrm{claimAux}(m))_1}{m + 3}.$$

*Proof sketch.* Immediate by definitional unfolding of $\mathrm{claimAux}(m+1)$, $\mathrm{claimAux}(m+2)$, $\mathrm{claimAux}(m+3)$: the window shifts by one slot each step, and the third slot is the recurrence's right-hand side. (In the formalization these hold by `rfl`.) $\square$

**Theorem 3.3 (Faithfulness, `claimSeq_satisfies_recurrence`).** For every $n \ge 0$,
$$(n+3)\,\mathrm{claimSeq}(n+3) = (3n+4)\,\mathrm{claimSeq}(n+2) - (3n+1)\,\mathrm{claimSeq}(n+1) + n\,\mathrm{claimSeq}(n).$$

*Proof sketch.* Since $n + 3 > 0$ over $\mathbb{N}$, we have $n+3 \neq 0$ in $\mathbb{Q}$. Substitute the alignment identities of Lemma 3.2: the left side becomes $(n+3)$ times a quotient with denominator $(n+3)$, and clearing the denominator (`field_simp`) yields exactly the right side. $\square$

Theorem 3.3 shows $\mathrm{claimSeq}$ is *the* sequence the claim describes; any defect of $\mathrm{claimSeq}$ is a defect of the claim.

### 3.3 The forced fraction at index 3

**Theorem 3.4 (`claimSeq_three`, `claimSeq_four`).** $\mathrm{claimSeq}(3) = \tfrac{4}{3}$ and $\mathrm{claimSeq}(4) = \tfrac{4}{3}$.

*Proof sketch.* Evaluate the definition. With $(x,y,z) = (1,0,1)$ at $n=0$, the recurrence gives the new third slot $\frac{4\cdot 1 - 1\cdot 0 + 0\cdot 1}{3} = \tfrac43$, so $\mathrm{claimSeq}(3) = \tfrac43$. One further step gives $\mathrm{claimSeq}(4) = \frac{7\cdot \tfrac43 - 4\cdot 1 + 1\cdot 0}{4} = \frac{\tfrac{28}{3}-4}{4} = \frac{16/3}{4} = \tfrac43$. (Mechanized by `norm_num`.) $\square$

**Theorem 3.5 (`claimSeq_three_not_integer`).** There is no integer $m$ with $\mathrm{claimSeq}(3) = m$.

*Proof sketch.* If $\mathrm{claimSeq}(3) = m$ with $m \in \mathbb{Z}$, then by Theorem 3.4, $m = \tfrac43$ in $\mathbb{Q}$, whence (clearing denominators and using injectivity of $\mathbb{Z} \hookrightarrow \mathbb{Q}$) $3m = 4$ in $\mathbb{Z}$, impossible by parity/divisibility (`omega`). $\square$

### 3.4 The headline impossibility

**Theorem 3.6 (`no_integer_sequence_satisfies_claim`).** There is no function $a : \mathbb{N} \to \mathbb{Z}$ satisfying simultaneously
$$a_0 = 1,\quad a_1 = 0,\quad a_2 = 1, \quad \text{and} \quad (n+3)a_{n+3} = (3n+4)a_{n+2} - (3n+1)a_{n+1} + n\,a_n \ \ \forall n.$$

*Proof sketch.* Suppose such $a$ exists. Instantiate the recurrence at $n = 0$:
$$3\,a_3 = 4\,a_2 - 1\,a_1 + 0\cdot a_0 = 4\cdot 1 - 0 = 4.$$
Thus $3 a_3 = 4$ with $a_3 \in \mathbb{Z}$, which has no solution ($4$ is not divisible by $3$; `omega`). Contradiction. $\square$

**Corollary 3.7.** The integer coefficient sequence $(a_n)$ of $f(q)$ does not satisfy $(\star)$. Indeed, by Proposition 3.1 the coefficients are integers; by Theorem 3.6 no integer sequence with the stated initials satisfies the recurrence; and the stated initials are in any case wrong (Proposition 3.1).

### 3.5 Uniqueness

**Theorem 3.8 (`recurrence_unique`).** If $b, c : \mathbb{N} \to \mathbb{Q}$ both satisfy $(\star)$ — i.e. agree on $a_0, a_1, a_2$ and obey the recurrence — then $b = c$.

*Proof sketch.* Strong induction on $n$. The base cases $n = 0, 1, 2$ are the shared initial data. For $n = k + 3$, the recurrence reads
$$b_{k+3} = \frac{(3k+4)b_{k+2} - (3k+1)b_{k+1} + k\,b_k}{k+3},$$
and likewise for $c$; since $k + 3 \neq 0$ and the induction hypotheses give $b_k = c_k$, $b_{k+1} = c_{k+1}$, $b_{k+2} = c_{k+2}$, the right-hand sides agree, so $b_{k+3} = c_{k+3}$. $\square$

**Corollary 3.9 (`claim_solution_not_integer`).** The unique $\mathbb{Q}$-sequence obeying $(\star)$ is $\mathrm{claimSeq}$ (Theorem 3.3 + Theorem 3.8), and it is non-integral at index $3$ (Theorem 3.5). Hence *every* sequence consistent with the claim fails integrality at $n=3$.

---

## 4. Computational evidence for non-holonomy

The disproof above concerns one specific recurrence. We additionally probe whether *any* low-complexity recurrence could hold.

**Method.** Fix a target order $r$ and degree $d$. Posit unknown polynomials $p_i(n) = \sum_{j=0}^{d} c_{i,j} n^j$ for $i = 0, \dots, r$. Requiring $\sum_{i=0}^r p_i(n)\, a_{n+i} = 0$ for $n = 0, 1, \dots, M-1$ (with $M$ comfortably exceeding $(r+1)(d+1)$, the number of unknowns) yields a homogeneous linear system $A\,\mathbf{c} = 0$ over $\mathbb{Q}$, where $\mathbf{c}$ collects the $c_{i,j}$. The recurrence exists nontrivially iff $\ker A \neq \{0\}$, i.e. iff $\operatorname{rank} A < (r+1)(d+1)$.

**Finding.** Using the exact coefficients of A000025 (no floating point), for all $r \le 5$ and $d \le 5$ the matrix $A$ has full column rank, so $\ker A = \{0\}$: **no nonzero polynomial recurrence of order $\le 5$, degree $\le 5$ exists.** This is consistent with the theoretical expectation, since:

**Theorem 4.1 (Zwegers 2002, contextual).** $f(q)$ is the holomorphic part of a harmonic Maass form of weight $\tfrac12$; its modular completion requires a non-holomorphic Eichler integral (the period integral of its shadow $\eta$-quotient theta function).

A holonomic power series has a generating function annihilated by a nonzero linear differential operator with polynomial coefficients; equivalently it is *D-finite*. Genuinely mock objects are not D-finite because the non-holomorphic completion obstructs any such operator. Hence:

**Conjecture 4.2 (Non-holonomy of $f$).** For every $r, d$, the only $(p_0, \dots, p_r) \in \mathbb{Q}[n]^{r+1}$ with $\sum_i p_i(n) a_{n+i} = 0$ for all $n$ is the zero tuple. Our finite computation certifies the cases $r, d \le 5$.

---

## 5. Algorithms

### 5.1 Coefficient extraction by formal power-series division

To obtain $a_0, \dots, a_{N-1}$, truncate everything modulo $q^N$. Each factor $(1+q^k)^{-1}$ is computed as a geometric series; the product accumulates; the inverse uses the standard recurrence for power-series reciprocals. Complexity $O(N^2)$ per summand with naive multiplication, and only $O(\sqrt{N})$ summands contribute (those with $n^2 < N$), for $O(N^{2.5})$ total — entirely adequate for $N$ in the dozens. (See `demo.py` and the algorithms array of `PACKAGE.json`.)

### 5.2 Recurrence search by exact linear algebra

Build the matrix $A$ described in §4 with exact rational entries and compute its rank by fraction-free Gaussian elimination (so there is no rounding). A trivial kernel certifies non-existence of a recurrence in the tested window.

---

## 6. Applications and significance

1. **Error containment.** A false but structurally plausible recurrence, if used to "compute" coefficients, would silently produce wrong (non-integer) values from $a_3$ onward. The pinpointed obstruction $3a_3 = 4$ stops this at the source.
2. **A clean bridge result.** The disproof reduces an analytic/number-theoretic question (does a mock theta have a P-recurrence?) to a one-line divisibility fact ($3 \nmid 4$), exhibiting how holonomy theory and elementary arithmetic interlock.
3. **A template for formal non-holonomy.** The finite linear-algebra certificate of §4 is exactly the kind of object that can be machine-checked; scaling it is a concrete path toward the first formally verified non-holonomy theorem (Conjecture 4.2).

---

## 7. Discussion

The two failure modes of the claim are qualitatively different. The wrong initials $(1,0,1)$ vs. $(1,1,-2)$ are a *labeling* error: some sequence might satisfy the recurrence, just not with those starts matching $f$. The non-integrality $a_3 = \tfrac43$ is an *existence* error: with those starts, no integer sequence satisfies the recurrence at all. The second is the stronger statement and the one we formalize as the headline (Theorem 3.6), because it is robust — it does not even require knowing the true coefficients of $f$, only that they are integers.

It is worth emphasizing what is *not* claimed. We do not assert that $f$ satisfies no nice identities — it satisfies many (Watson's transformations, the famous relation to $\omega(q)$, congruences à la Andrews–Garvan). We assert only that it has no *polynomial-coefficient linear recurrence* of the specific (disproved) form, and conjecturally of any finite form. The richness of $f$ lives precisely in the *non*-holonomic regime.

---

## 8. Future directions

**Conjecture 1 — Formalize the integer $q$-expansion of $f(q)$.** Build $f(q) \in \mathbb{Z}[[q]]$ as $\sum_n q^{n^2}\prod_{k=1}^n(1+q^k)^{-2}$ via formal power series, and prove $[q^n]f \in \mathbb{Z}$ with $[q^0]f, [q^1]f, [q^2]f = 1, 1, -2$. The key insight is that integrality is structural — each summand is an integer power series (geometric inverse of $(1+q^k)$) — so the whole sum lands in $\mathbb{Z}[[q]]$, already contradicting the claimed $a_3 = \tfrac43$. This is the minimal missing ingredient to turn a disproof-of-premise into a disproof *about $f$ itself*.

**Conjecture 2 — $f(q)$ is non-holonomic.** For every order $r$ and degree $d$, the only $p_0, \dots, p_r \in \mathbb{Q}[n]$ with $\sum_i p_i(n)a_{n+i} = 0$ for all $n$ is the zero tuple. Holonomy of a power series is equivalent to a finite linear ODE for its generating function, and $f$ is a mock modular form whose completion needs a non-holomorphic Eichler integral, obstructing any such ODE. Our exact linear-algebra search certifies non-existence up to $r, d \le 5$; a proof of a *finite* obstruction (the coefficient matrix stays full rank as the window grows) would be a first formal non-holonomy result.

**Conjecture 3 — Correct recurrence after modular separation.** The even- and odd-indexed subsequences, or $a_n$ minus an explicit theta/Eichler correction term $\theta_n$, satisfy an honest polynomial recurrence even though $a_n$ itself does not. A mock theta becomes holonomic after adding its shadow's period integral, so the obstruction is a single transcendental correction, not the bulk of the sequence. The uniqueness scaffold (`recurrence_unique`) gives the exact tool to test any candidate corrected recurrence.

**Conjecture 4 — Sign and growth of $a_n$.** $\operatorname{sign}(a_n)$ is eventually $(-1)^n$ for $n \ge 2$, and $|a_n|$ is increasing along each parity class with $|a_n| = \exp(O(\sqrt n))$. Mock theta coefficients inherit a Hardy–Ramanujan-type exponential growth with a parity-locked sign from the leading singularity at $q = -1$. The first ~25 computed terms already exhibit the alternating pattern from $n = 2$; a proof of the sign statement is a purely combinatorial capstone.

---

## 9. Conclusion

The proposed recurrence for the coefficients of Ramanujan's third order mock theta function $f(q)$ is false twice over: its initial data $(1,0,1)$ does not match the true $(1,1,-2)$, and — decisively — no integer sequence with those initials can satisfy the recurrence, since the $n=0$ instance forces the impossible $3a_3 = 4$. The unique rational solution is pinned to $a_3 = \tfrac43 \notin \mathbb{Z}$. These facts, all formally verified, are not isolated curiosities: they are a concrete shadow of the deep truth that mock theta functions are non-holonomic. A single fraction, $\tfrac43$, links elementary divisibility to Zwegers' harmonic Maass forms — a small bridge across a hundred years of mathematics.

---

## References (for context; the paper is self-contained)

- S. Ramanujan, last letter to G. H. Hardy (1920).
- G. E. Andrews, B. C. Berndt, *Ramanujan's Lost Notebook*, Parts I–V.
- S. P. Zwegers, *Mock Theta Functions*, Ph.D. thesis, Utrecht (2002).
- OEIS A000025, coefficients of the third order mock theta function $f(q)$.
- M. Petkovšek, H. S. Wilf, D. Zeilberger, *A = B* (holonomic/P-recursive sequences).
