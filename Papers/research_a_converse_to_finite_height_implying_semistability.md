# A Determinantal Converse to Finite Height for Breuil–Kisin Modules

**Author:** Aristotle
**Domain:** Novelty (p-adic Hodge theory / Breuil–Kisin modules)
**Date:** 2026-06-28

## Abstract

In the theory of $p$-adic Galois representations, *finite-height* objects are the integral, lattice-theoretic shadow of *semistable* representations: by Kisin's classification, lattices in semistable representations with Hodge–Tate weights in $[0,h]$ correspond to Breuil–Kisin modules of $E$-height $\le h$. The easy direction (finite height forces good generic behavior) is elementary; the substantial converse (good generic behavior manufactures a finite-height lattice) is what makes the theory usable. We isolate the exact finite-dimensional linear-algebra core of this correspondence. Presenting a Breuil–Kisin module by the matrix $A \in M_n(\mathfrak{S})$ of its linearized Frobenius over an arbitrary commutative ring $\mathfrak{S}$ with a distinguished "Eisenstein" element $E$, we prove that the module is of finite height if and only if it is *Newton-concentrated*, i.e. $\det A \mid E^N$ for some $N$. The converse direction is **constructive**: from a factorization $E^N = (\det A)\cdot c$ we exhibit the explicit two-sided height witness $B = c\cdot\operatorname{adj}(A)$, giving the sharp bound height $\le N$. We further show: height $0$ is equivalent to $\det A$ being a unit (the étale/unramified case); heights are monotone; finite height is closed under direct sums; and finite height is detected by the rank-one determinant module. Non-vacuity is witnessed over $\mathbb{Q}[X]$ with $E = X$ by three worked examples — a positive case, an étale case, and a negative case $[X+1]$ whose determinant degenerates away from the special divisor and which therefore admits *no* finite height. All results hold over an arbitrary commutative coefficient ring, with no domain, Noetherian, or $p$-adic hypotheses.

---

## 1. Introduction

### 1.1 Motivation

A $p$-adic Galois representation is a continuous homomorphism $\rho \colon G_K \to \mathrm{GL}_n(\mathbb{Z}_p)$, where $G_K$ is the absolute Galois group of a finite extension $K/\mathbb{Q}_p$. These objects encode arithmetic — the étale cohomology of varieties, the Galois action on Tate modules of abelian varieties, deformations attached to modular forms — and classifying them is a central program of arithmetic geometry. Among the structural conditions one imposes, two are paramount:

- **Semistability** (and its refinement, crystallinity), an analytic condition phrased through Fontaine's period rings $B_{\mathrm{st}}$, $B_{\mathrm{cris}}$.
- **Finite height**, an integral condition phrased through the existence of a Frobenius-stable lattice whose Frobenius is invertible up to a bounded power of an Eisenstein element.

Kisin's theorem provides the bridge: lattices in semistable representations with Hodge–Tate weights in $[0,h]$ are classified by **Breuil–Kisin modules** of $E$-height $\le h$. Thus "finite height" is precisely the lattice-theoretic shadow of "semistable with bounded weights." Of the two implications relating the conditions, one is comparatively easy (finite height $\Rightarrow$ good generic/Newton behavior), while the converse — that generic good behavior produces a genuine finite-height lattice — is the deep content.

### 1.2 Contribution

We extract the **exact linear-algebra core** of the finite-height/Newton correspondence and prove it cleanly and constructively over any commutative ring. After choosing a basis, the linearized Frobenius $\Phi$ of a Breuil–Kisin module becomes a square matrix $A$. The height condition "$E^h \cdot \mathfrak{M} \subseteq \Phi(\mathfrak{M})$" becomes the two-sided matrix identity $AB = BA = E^h I$; the Newton condition "$\Phi$ is an isomorphism after inverting $E$" becomes the scalar divisibility $\det A \mid E^N$. In this exact shadow we establish:

1. **The equivalence** (`finiteHeight_iff_newton`): $\mathrm{FiniteHeight}(A) \iff \mathrm{NewtonConcentrated}(A)$.
2. **The constructive converse** (`newton_implies_finiteHeight`): $\det A \mid E^N \implies$ height $\le N$, witnessed by $B = c\cdot\operatorname{adj}(A)$.
3. **The easy forward direction** (`finiteHeight_implies_newton`): height $\le h \implies \det A \mid E^{h\cdot n}$.
4. **Height zero $=$ étale** (`hasHeightLE_zero_iff`): height $0 \iff \det A$ is a unit.
5. **Monotonicity** (`hasHeightLE_mono`): height $\le h \implies$ height $\le h'$ for $h \le h'$.
6. **Closure under direct sums** (`finiteHeight_directSum`).
7. **Determinantal detection** (`finiteHeight_iff_det`): a module has finite height iff its rank-one determinant module does.

Non-vacuity is pinned down over $\mathbb{Q}[X]$, $E = X$, by `example_finiteHeight` ($[X^2]$), `example_etale` ($[1]$), and the load-bearing negative example `example_not_finiteHeight` ($[X+1]$).

---

## 2. Definitions

Throughout, $\mathfrak{S}$ (denoted `S` in code) is a commutative ring, written additively and multiplicatively in the usual way, and $E \in \mathfrak{S}$ is a fixed element playing the role of the Eisenstein polynomial whose vanishing locus $V(E)$ is the *special divisor*.

### 2.1 Breuil–Kisin modules

> **Definition 2.1 (Breuil–Kisin module).** A *Breuil–Kisin module* over $\mathfrak{S}$ is a pair $\mathfrak{M} = (n, A)$ consisting of a rank $n \in \mathbb{N}$ and a square matrix $A \in M_n(\mathfrak{S})$ — the matrix, in a chosen basis, of the linearized Frobenius $\Phi \colon \varphi^*\mathfrak{M} \to \mathfrak{M}$.

In the geometric theory, $\mathfrak{M}$ is a finite free module over $\mathfrak{S} = W(k)[[u]]$ equipped with a $\varphi$-semilinear endomorphism whose linearization $\Phi$ is injective with cokernel killed by a power of $E(u)$. The semilinearity and the Eisenstein element are external data; all height and Newton information is carried by the matrix $A$ and the chosen $E$. This is the "exact finite shadow."

### 2.2 Height

> **Definition 2.2 (Height $\le h$, `HasHeightLE`).** A module $\mathfrak{M} = (n,A)$ *has $E$-height $\le h$* if there is a matrix $B \in M_n(\mathfrak{S})$ with
> $$A B = E^h\, I_n \qquad\text{and}\qquad B A = E^h\, I_n.$$

The matrix $B$ is an *integral* two-sided pseudo-inverse: $A$ is invertible after multiplying by $E^h$, and only powers of $E$ are needed to invert it. This is the cokernel condition $E^h\cdot\mathfrak{M}\subseteq\Phi(\mathfrak{M})$ made symmetric and explicit.

> **Definition 2.3 (Finite height, `FiniteHeight`).** $\mathfrak{M}$ is of *finite height* (with respect to $E$) if it has height $\le h$ for some $h \in \mathbb{N}$:
> $$\mathrm{FiniteHeight}(\mathfrak{M}) \iff \exists h,\ \mathrm{HasHeightLE}(\mathfrak{M}, E, h).$$

### 2.3 The Newton condition

> **Definition 2.4 (Newton-concentrated, `NewtonConcentrated`).** $\mathfrak{M}$ is *Newton-concentrated* (with respect to $E$) if its determinant divides a power of $E$:
> $$\mathrm{NewtonConcentrated}(\mathfrak{M}) \iff \exists N,\ \det A \mid E^N.$$

This says the determinant's only "slopes" lie on the special divisor $V(E)$: away from $V(E)$, $\det A$ is invertible, so $\Phi$ is an isomorphism on the generic fiber. It is the lattice-theoretic encoding of "$\Phi$ is an isomorphism after inverting $E$."

---

## 3. Main Results

### 3.1 The easy direction

> **Theorem 3.1 (`finiteHeight_implies_newton`).** If $\mathfrak{M} = (n,A)$ has height $\le h$, then $\det A \mid E^{h\cdot n}$; in particular $\mathfrak{M}$ is Newton-concentrated.

*Proof sketch.* Let $B$ witness height $\le h$, so $AB = E^h I_n$. Apply $\det$ and use multiplicativity together with $\det(E^h I_n) = (E^h)^n$:
$$\det A \cdot \det B = \det(E^h I_n) = E^{h n}.$$
Hence $\det A \mid E^{h n}$, with cofactor $\det B$. $\qquad\blacksquare$

The bound $N = h\cdot n$ reflects the determinant accumulating at most $h$ units of "weight" per basis vector. (Only one of the two height equations is needed for this direction.)

### 3.2 The constructive converse

> **Theorem 3.2 (`newton_implies_finiteHeight`).** Suppose $\det A \mid E^N$, say $E^N = (\det A)\cdot c$ with $c \in \mathfrak{S}$. Then $\mathfrak{M} = (n,A)$ has height $\le N$. Explicitly, $B := c\cdot\operatorname{adj}(A)$ satisfies $AB = BA = E^N I_n$.

*Proof sketch.* The adjugate (classical adjoint) $\operatorname{adj}(A) \in M_n(\mathfrak{S})$ satisfies the fundamental identities
$$A\cdot\operatorname{adj}(A) = (\det A)\, I_n, \qquad \operatorname{adj}(A)\cdot A = (\det A)\, I_n,$$
(`Matrix.mul_adjugate`, `Matrix.adjugate_mul`), with entries polynomial in those of $A$ — no division. Setting $B = c\cdot\operatorname{adj}(A)$,
$$A B = c\cdot\big(A\cdot\operatorname{adj}(A)\big) = c\cdot(\det A)\, I_n = (\det A \cdot c)\, I_n = E^N I_n,$$
and symmetrically $B A = E^N I_n$. Thus $B$ is an honest two-sided height-$\le N$ witness. $\qquad\blacksquare$

This is the headline result. Note that the witness is produced directly (no contradiction, no nonconstructive choice), mirroring how semistability *constructs* the Breuil–Kisin lattice.

### 3.3 The equivalence

> **Theorem 3.3 (`finiteHeight_iff_newton`).** For any Breuil–Kisin module $\mathfrak{M} = (n, A)$ over $\mathfrak{S}$ and any $E$,
> $$\mathrm{FiniteHeight}(\mathfrak{M}) \iff \mathrm{NewtonConcentrated}(\mathfrak{M}) \iff \exists N,\ \det A \mid E^N.$$

*Proof sketch.* The forward implication is Theorem 3.1: take any height witness and pass to determinants. The reverse is Theorem 3.2: from $\det A \mid E^N$ build $B = c\cdot\operatorname{adj}(A)$ to witness height $\le N$. $\qquad\blacksquare$

The content of the equivalence is the collapse of an apparently module-wide condition (existence of a full matrix $B$) to a single scalar divisibility ($\det A \mid E^N$).

### 3.4 Height zero is the étale case

> **Theorem 3.4 (`hasHeightLE_zero_iff`).** $\mathfrak{M} = (n,A)$ has height $\le 0$ if and only if $\det A$ is a unit in $\mathfrak{S}$ (equivalently, $A \in \mathrm{GL}_n(\mathfrak{S})$).

*Proof sketch.* Height $\le 0$ means $AB = BA = E^0 I_n = I_n$, i.e. $A$ is invertible. Over a commutative ring, $A$ is invertible iff $\det A$ is a unit (`Matrix.isUnit_iff_isUnit_det`). $\qquad\blacksquare$

Height $0$ is the **étale/unramified** regime: the Frobenius is already an isomorphism integrally, with no degeneration even at the special divisor.

### 3.5 Monotonicity

> **Theorem 3.5 (`hasHeightLE_mono`).** If $\mathfrak{M}$ has height $\le h$ and $h \le h'$, then $\mathfrak{M}$ has height $\le h'$.

*Proof sketch.* Write $h' = h + d$. If $AB = E^h I_n$, then $A\,(E^d B) = E^{h+d} I_n = E^{h'} I_n$, and likewise on the other side; so $E^d B$ witnesses height $\le h'$. $\qquad\blacksquare$

### 3.6 Closure under direct sums

> **Theorem 3.6 (`finiteHeight_directSum`).** If $\mathfrak{M} = (m, A)$ and $\mathfrak{N} = (n, C)$ are of finite height with respect to $E$, then so is their direct sum $\mathfrak{M}\oplus\mathfrak{N} = \big(m+n,\ \mathrm{diag}(A,C)\big)$ (block-diagonal Frobenius).

*Proof sketch.* The block-diagonal determinant factors,
$$\det\begin{pmatrix} A & 0 \\ 0 & C \end{pmatrix} = \det A \cdot \det C$$
(`Matrix.det_fromBlocks_zero₂₁`). If $\det A \mid E^{N_1}$ and $\det C \mid E^{N_2}$, then $\det A\cdot\det C \mid E^{N_1+N_2}$, so the sum is Newton-concentrated; apply Theorem 3.3. (Concretely, the block-diagonal witness $\mathrm{diag}(B_A, B_C)$ scaled to a common power of $E$ also works.) $\qquad\blacksquare$

### 3.7 Detection by the determinant

> **Theorem 3.7 (`finiteHeight_iff_det`).** Let $\det(\mathfrak{M})$ be the rank-one Breuil–Kisin module $\big(1, [\det A]\big)$ — the top exterior power $\wedge^{\mathrm{top}}\mathfrak{M}$, whose Frobenius is multiplication by $\det A$. Then
> $$\mathrm{FiniteHeight}(\mathfrak{M}) \iff \mathrm{FiniteHeight}(\det\mathfrak{M}).$$

*Proof sketch.* By Theorem 3.3, both sides are equivalent to $\exists N,\ \det A \mid E^N$: the right side is the Newton condition of the $1\times 1$ matrix $[\det A]$, whose determinant is exactly $\det A$. $\qquad\blacksquare$

This is the faithful shadow of the fact that the determinant of a semistable representation is a cyclotomic-twist datum carrying the total Hodge–Tate weight: finite height is a *rank-one* phenomenon.

---

## 4. Worked Examples (Non-Vacuity)

We instantiate $\mathfrak{S} = \mathbb{Q}[X]$ and $E = X$. The special divisor is $V(X) = \{X = 0\}$.

> **Example 4.1 (`example_finiteHeight`).** $\mathfrak{M} = (1, [X^2])$ has finite height. Indeed $\det A = X^2 = E^2$, so $\det A \mid E^2$ and the module has height $\le 2$ (explicitly $B = [1]$, since $[X^2][1] = [X^2] = X^2 I_1$).

> **Example 4.2 (`example_etale`).** $\mathfrak{M} = (1, [1])$ has height $0$. Here $\det A = 1$ is a unit; the Frobenius is already invertible. This is the étale case.

> **Example 4.3 (`example_not_finiteHeight`).** $\mathfrak{M} = (1, [X+1])$ has **no** finite height. For if $X+1 \mid X^N$, evaluate at $X = -1$: the right side becomes $(-1)^N \ne 0$ while the left vanishes, a contradiction. Geometrically, $\det A = X+1$ degenerates at $X = -1$, *off* the special divisor $V(X)$. The Newton condition fails, so by Theorem 3.3 no finite-height lattice exists.

Example 4.3 is **load-bearing**: it shows that Newton-concentration is a genuine constraint, not automatic, which is exactly why the converse (Theorem 3.2) is a theorem rather than a triviality. A perfectly good integral Frobenius can fail to have finite height when its determinant strays from the special divisor.

> **Corner case (rank $0$).** The empty module $\mathfrak{M} = (0, [\ ])$ has $\det A = 1$ (empty product), hence height $0$ — faithfully, the zero representation is crystalline of height $0$.

---

## 5. Algorithms

The proofs are constructive and translate directly into algorithms over any computable commutative ring.

### 5.1 Adjugate height-witness construction

Given $A$ and a witness $c$ with $E^N = (\det A)c$, the converse produces the height witness $B = c\cdot\operatorname{adj}(A)$ explicitly:

```
INPUT:  matrix A ∈ M_n(S), element E ∈ S, exponent N, cofactor c with det(A)·c = E^N
OUTPUT: matrix B with A·B = B·A = E^N·I

1. D ← det(A)                       # det of A
2. assert D · c == E^N              # Newton certificate
3. Adj ← adjugate(A)                # classical adjoint (cofactor transpose)
4. B ← c · Adj                      # scale entrywise by c
5. assert A·B == E^N·I and B·A == E^N·I
6. return B
```

Cost: $O(n^2)$ cofactors, each an $(n-1)\times(n-1)$ determinant; with naive expansion this is super-exponential, but with fraction-free Gaussian elimination (Bareiss) the determinant and adjugate are computed in $O(n^3)$ ring operations.

### 5.2 Newton/finite-height decision

To decide finite height over $\mathfrak{S} = k[X]$ (or $k[[u]]$) with $E = X$: compute $\det A$, then test whether $\det A$ divides a power of $X$. Over $k[X]$, $\det A \mid X^N$ for some $N$ iff $\det A = \lambda X^m$ is a monomial ($\lambda \in k^\times$); the minimal such $N$ is then $m$ (an upper bound for the height; equality is the Smith-normal-form refinement, Conjecture C4).

```
INPUT:  matrix A ∈ M_n(k[X])
OUTPUT: (is_finite_height: bool, height_bound: int or ∞)

1. D ← det(A) ∈ k[X]
2. if D == 0: return (False, ∞)                  # degenerate
3. strip the largest power of X dividing D: D = X^m · R, R(0) ≠ 0
4. if R is a nonzero constant:  return (True, m)  # det = λ X^m, Newton-concentrated
5. else:                        return (False, ∞) # determinant strays off V(X)
```

---

## 6. Applications

1. **A computable certificate for finite height.** For matrices over $k[X]$ or $k[[u]]$, finite height is decided by a determinant computation and a monomial test, sidestepping any search for the witness matrix $B$ — and when the answer is yes, $B$ is produced explicitly by the adjugate formula.

2. **Structural stability.** Monotonicity, closure under direct sums, and determinantal detection give a robust calculus of finite-height modules: one can build new finite-height objects from old, and check the property on a rank-one proxy.

3. **A teaching model for $p$-adic Hodge theory.** The equivalence "finite height $\iff$ determinant on the special divisor" gives a fully elementary, fully rigorous miniature of the deep Kisin correspondence, accessible with nothing beyond the adjugate identity and multiplicativity of the determinant.

4. **A template for refinements.** Because everything is reduced to the determinant and the adjugate, refinements (tensor products, duals, extensions, Smith normal form, monodromy) become precise, testable matrix conjectures (Section 8).

---

## 7. Discussion

The mathematical heart of the result is the tension between two readings of "invertibility up to $E$." The *height* reading is global and matrix-valued: produce a two-sided pseudo-inverse $B$ with $AB = BA = E^h I$. The *Newton* reading is local-at-$V(E)$ and scalar-valued: $\det A$ vanishes only on $V(E)$. The theorems show these coincide, and that the bridge in both directions is the adjugate identity $A\cdot\operatorname{adj}(A) = (\det A) I$, used forward via the determinant and backward via the explicit construction.

Two features are worth emphasizing. First, **generality**: only a commutative ring is assumed — no integral domain, Noetherian, or $p$-adic hypotheses. The "shadow" is exactly as clean as the linear algebra permits, which clarifies precisely which features of the arithmetic theory are formal and which are genuinely arithmetic. Second, **sharpness**: the bound height $\le N$ when $\det A \mid E^N$ is the determinant-level statement; the *minimal* height can be strictly smaller and is governed by the full Smith normal form (the largest elementary divisor), which agrees with $v_E(\det A)$ exactly in the cyclic case (Conjecture C4).

The negative example $[X+1]$ shows the theory is not vacuous: Newton-concentration is a real constraint. This is the linear-algebra echo of the fact that not every $p$-adic representation is of finite height; only those whose Frobenius degenerates solely at the special divisor — i.e. the semistable ones, by Kisin — qualify.

---

## 8. Future Directions

The following conjectures are precise, falsifiable matrix statements, each a concrete next target.

- **C1 — Tensor sub-additivity of height.** If $\mathfrak{M}$ has height $\le a$ and $\mathfrak{N}$ has height $\le b$, then $\mathfrak{M}\otimes\mathfrak{N}$ (Kronecker product $A\otimes C$) has height $\le a+b$, with $\det(A\otimes C) = (\det A)^{\,\mathrm{rank}\,\mathfrak{N}}(\det C)^{\,\mathrm{rank}\,\mathfrak{M}}$. Combine the Kronecker determinant identity with determinantal detection (Theorem 3.7).

- **C2 — Duality preserves finite height.** The dual $\mathfrak{M}^\vee$ (Frobenius $\operatorname{adj}(A)$, up to the determinant twist) is of finite height iff $\mathfrak{M}$ is, and $\mathrm{height}(\mathfrak{M}^\vee)+\mathrm{height}(\mathfrak{M})$ is controlled by $v_E(\det A)$. Use $\det(\operatorname{adj}A) = (\det A)^{\,n-1}$.

- **C3 — Two-out-of-three in short exact sequences.** For a block-upper-triangular Frobenius $\begin{psmallmatrix} A & * \\ 0 & C \end{psmallmatrix}$ (an extension $0 \to \mathfrak{M}' \to \mathfrak{M} \to \mathfrak{M}'' \to 0$), $\mathfrak{M}$ is of finite height iff $\mathfrak{M}'$ and $\mathfrak{M}''$ are, since $\det = \det A\cdot\det C$. Generalize Theorem 3.6 to a nonzero upper-right block.

- **C4 — Sharp height = top elementary divisor (Smith normal form).** Over a DVR $\mathfrak{S} = k[[u]]$, $E = u$, the *minimal* height equals the $u$-adic valuation of the *largest* elementary divisor of $A$ (its last Smith exponent), not merely $v_u(\det A)$; the two agree iff $\mathfrak{M}$ is cyclic over $\mathfrak{S}[\varphi]$.

- **C5 — Monodromy refinement: crystalline vs semistable.** Enrich the module with a monodromy operator $N$ satisfying $N\Phi = E\cdot(\cdots)\cdot\Phi N$. Conjecture: a finite-height module is *crystalline* iff some basis has $N = 0$, and *semistable but not crystalline* iff $N \ne 0$ is nilpotent commuting with $A$ up to the $E$-twist — the matrix shadow distinguishing the two regimes that the present model collapses.

---

## 9. Conclusion

We have isolated and proved, over an arbitrary commutative ring, the exact linear-algebra core of the finite-height/semistability correspondence: a Breuil–Kisin module presented by a Frobenius matrix $A$ has finite height if and only if $\det A$ divides a power of the Eisenstein element $E$, with the converse direction made constructive through the adjugate witness $B = c\cdot\operatorname{adj}(A)$ and the sharp bound height $\le N$. Height $0$ is the étale case ($\det A$ a unit), heights are monotone, finite height is closed under direct sums and detected by the rank-one determinant, and the theory is genuinely non-vacuous — the module $[X+1]$ over $\mathbb{Q}[X]$ has no finite height because its determinant degenerates off the special divisor. The result turns an apparently module-wide structural condition into a single determinantal divisibility test, providing a transparent, computable miniature of one of the central correspondences of $p$-adic Hodge theory.
