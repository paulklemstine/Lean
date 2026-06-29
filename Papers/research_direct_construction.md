# Polynomial Interpolation as a Certified Linear Equivalence: From Lagrange to Reed–Solomon

## Abstract

We establish that evaluation of bounded-degree polynomials at $n+1$ distinct field points constitutes a $K$-linear equivalence, with Lagrange interpolation as the explicit certified inverse. The result is formalized as a `LinearEquiv` in the Lean 4 proof assistant with the Mathlib library, providing a reusable algebraic interface that connects polynomial algebra, evaluation codes, finite sheaf reconstruction, and symbolic regression over fields. We provide complete proofs of all constituent lemmas — degree bounds, evaluation correctness, linearity, and uniqueness-based left inverse recovery — and package them into a single canonical isomorphism. We discuss applications to Reed–Solomon codes, Shamir secret sharing, and finite-domain learning theory, and present computational demonstrations validating the algebraic structure.

**Keywords:** polynomial interpolation, linear equivalence, Lagrange basis, Vandermonde matrix, Reed–Solomon codes, evaluation codes, formal verification

---

## 1. Introduction

### 1.1 Motivation

Polynomial interpolation — the problem of finding a polynomial passing through prescribed data points — is one of the oldest problems in computational mathematics, with roots in Newton's work on divided differences and Lagrange's explicit formula from the 1790s. Despite centuries of use, the precise algebraic status of interpolation as a *linear isomorphism* on appropriate spaces has rarely been formalized with full rigor.

The classical result is well-known: a polynomial of degree at most $n$ is uniquely determined by its values at $n+1$ distinct points. This statement, however, is merely an injectivity claim for the evaluation map. The complete picture — that evaluation and interpolation form a pair of mutually inverse *linear* maps between finite-dimensional spaces — constitutes a stronger algebraic theorem that serves as infrastructure for:

1. **Coding theory**: Reed–Solomon codes are evaluation codes; encoding is the forward map, and decoding (from erasures) is the inverse.
2. **Cryptography**: Shamir's secret sharing scheme relies on the uniqueness and linearity of polynomial interpolation.
3. **Numerical analysis**: interpolation-based quadrature, spectral methods, and collocation solvers depend on the algebraic properties of the interpolation operator.
4. **Algebraic geometry**: evaluation on finite point sets is a finite-dimensional model for the restriction map on sheaves of polynomial functions.

### 1.2 Contributions

We provide:

1. A complete formalization of the evaluation–interpolation linear equivalence using Mathlib's `Lagrange.interpolate` infrastructure.
2. Modular proofs of degree bounds, evaluation correctness, and the uniqueness-based left inverse identity.
3. A packaged `LinearEquiv` that can serve as a plug-in component for downstream formalizations.
4. Computational demonstrations in Python covering Lagrange and Newton interpolation, Vandermonde systems, Reed–Solomon codes, and applications.

### 1.3 Related Work

The Mathlib library provides `Lagrange.interpolate` as a linear map from function values to polynomials, with lemmas for:
- Evaluation correctness at nodes (`eval_interpolate_at_node`),
- Degree bounds (`degree_interpolate_lt`, `degree_interpolate_le`),
- Uniqueness of bounded-degree polynomials agreeing on sufficiently many points (`eq_of_degree_sub_lt_of_eval_index_eq`).

Our contribution assembles these ingredients into a certified `LinearEquiv`, which Mathlib does not currently provide.

---

## 2. Mathematical Setup

### 2.1 Notation

Let $K$ be a field, $n \in \mathbb{N}$, and $v : \text{Fin}(n+1) \to K$ an injective map (the "node vector"). We work with:

- **Polynomial side**: $\mathcal{P}_{\le n} := \{p \in K[X] \mid \deg(p) < n+1\}$, formalized as the Mathlib submodule `Polynomial.degreeLT K (n+1)`.
- **Function side**: $K^{n+1} \cong \text{Fin}(n+1) \to K$.

### 2.2 The Evaluation Map

The evaluation map $\text{ev}_v : \mathcal{P}_{\le n} \to K^{n+1}$ sends a polynomial $p$ to the tuple $(p(v_0), p(v_1), \ldots, p(v_n))$.

**Linearity**: For all $p, q \in \mathcal{P}_{\le n}$ and $\alpha \in K$:
$$\text{ev}_v(\alpha p + q)(i) = (\alpha p + q)(v_i) = \alpha \cdot p(v_i) + q(v_i) = \alpha \cdot \text{ev}_v(p)(i) + \text{ev}_v(q)(i)$$

### 2.3 The Interpolation Map

The interpolation map $\text{interp}_v : K^{n+1} \to \mathcal{P}_{\le n}$ sends a function $f$ to the Lagrange interpolating polynomial:
$$\text{interp}_v(f) = \sum_{i=0}^{n} f(v_i) \cdot \ell_i(X)$$
where $\ell_i(X) = \prod_{j \neq i} \frac{X - v_j}{v_i - v_j}$ is the $i$-th Lagrange basis polynomial.

**Linearity**: Immediate from the definition as a weighted sum — the map is linear in the values $f(v_i)$.

---

## 3. Main Results

### 3.1 Degree Bound

**Theorem 3.1** (Degree bound for interpolation). *If $v : \text{Fin}(n+1) \to K$ is injective, then for all $f : \text{Fin}(n+1) \to K$:*
$$\deg(\text{interp}_v(f)) < n+1$$

*Proof.* Each Lagrange basis polynomial $\ell_i$ is a product of $n$ linear factors, hence has degree exactly $n$ (when the node $v_i$ is distinct from all others, which injectivity guarantees for basis polynomials of nodes in the set). The interpolant is a $K$-linear combination of these, so its degree is at most $n$, hence strictly less than $n+1$.

In Mathlib, this follows from `Lagrange.degree_interpolate_lt` applied to `s = Finset.univ` with the observation that `Finset.card (Finset.univ : Finset (Fin (n+1))) = n+1`. □

### 3.2 Right Inverse Identity

**Theorem 3.2** (Evaluation of interpolant recovers data). *For all $f : \text{Fin}(n+1) \to K$ and all $i \in \text{Fin}(n+1)$:*
$$\text{ev}_v(\text{interp}_v(f))(i) = f(i)$$

*Proof.* By definition of the Lagrange basis, $\ell_i(v_j) = \delta_{ij}$. Therefore:
$$\text{interp}_v(f)(v_i) = \sum_{j=0}^{n} f(v_j) \cdot \ell_j(v_i) = f(v_i)$$

In the formalization, this is `Lagrange.eval_interpolate_at_node` applied at each node. □

### 3.3 Left Inverse Identity (Uniqueness)

**Theorem 3.3** (Interpolation of evaluation recovers polynomial). *For all $p \in \mathcal{P}_{\le n}$:*
$$\text{interp}_v(\text{ev}_v(p)) = p$$

*Proof.* Let $q = \text{interp}_v(\text{ev}_v(p))$. Then:
1. $\deg(q) < n+1$ by Theorem 3.1.
2. $\deg(p) < n+1$ by hypothesis ($p \in \mathcal{P}_{\le n}$).
3. For all $i \in \text{Fin}(n+1)$: $q(v_i) = \text{ev}_v(p)(i) = p(v_i)$ by Theorem 3.2.

Since $p - q$ has degree $< n+1$ and vanishes at all $n+1$ distinct points $v_0, \ldots, v_n$, we conclude $p - q = 0$ by the root-counting argument: a nonzero polynomial of degree $< n+1$ can have at most $n$ roots.

In Mathlib, this uses `Polynomial.eq_of_degree_sub_lt_of_eval_index_eq`. □

### 3.4 The Linear Equivalence

**Theorem 3.4** (Main theorem). *The evaluation map $\text{ev}_v$ is a $K$-linear equivalence from $\mathcal{P}_{\le n}$ to $K^{n+1}$, with inverse $\text{interp}_v$.*

*Proof.* Theorems 3.2 and 3.3 establish that $\text{interp}_v$ is simultaneously a left and right inverse of $\text{ev}_v$. Both maps are $K$-linear (evaluation by linearity of polynomial evaluation, interpolation by the Lagrange sum formula). The result is a `LinearEquiv`. □

### 3.5 Formal Statement

```
noncomputable def evalOnNodesLinearEquiv (v : Fin (n + 1) → K)
    (hv : Function.Injective v) :
    Polynomial.degreeLT K (n + 1) ≃ₗ[K] (Fin (n + 1) → K)
```

The formalization uses:
- `Polynomial.degreeLT K (n+1)` for the bounded-degree submodule.
- `Lagrange.interpolate Finset.univ v` for the interpolation map.
- `Lagrange.eval_interpolate_at_node` for the right inverse.
- `Polynomial.eq_of_degree_sub_lt_of_eval_index_eq` for the uniqueness argument in the left inverse.

All proofs compile without `sorry` and use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

---

## 4. The Vandermonde Perspective

### 4.1 Matrix Representation

Choosing the monomial basis $\{1, X, X^2, \ldots, X^n\}$ for $\mathcal{P}_{\le n}$ and the standard basis for $K^{n+1}$, the evaluation map $\text{ev}_v$ is represented by the **Vandermonde matrix**:

$$V = \begin{pmatrix} 1 & v_0 & v_0^2 & \cdots & v_0^n \\ 1 & v_1 & v_1^2 & \cdots & v_1^n \\ \vdots & \vdots & \vdots & \ddots & \vdots \\ 1 & v_n & v_n^2 & \cdots & v_n^n \end{pmatrix}$$

### 4.2 Determinant Formula

The Vandermonde determinant is:
$$\det(V) = \prod_{0 \le i < j \le n} (v_j - v_i)$$

This is nonzero if and only if all nodes are distinct, which is precisely the injectivity hypothesis on $v$.

### 4.3 Condition Number

The Vandermonde matrix is notoriously ill-conditioned for large $n$ with equispaced nodes. For $n$ equispaced points on $[0, 1]$, the condition number grows exponentially as $\kappa(V) \sim 2^n / \sqrt{n}$. This is relevant for numerical stability but does not affect the algebraic result, which holds exactly over any field.

---

## 5. Applications

### 5.1 Reed–Solomon Codes

An $[n, k, d]$ Reed–Solomon code over a field $K$ with $|K| \ge n$:
- **Message space**: $\mathcal{P}_{\le k-1} \cong K^k$ (polynomials of degree $< k$)
- **Codeword space**: $K^n$ (evaluations at $n$ distinct points)
- **Encoding**: evaluation map (forward direction of our linear equivalence)
- **Minimum distance**: $d = n - k + 1$ (any two distinct codewords differ in at least $d$ positions)
- **Erasure decoding**: any $k$ received symbols suffice for exact reconstruction via interpolation (inverse direction)

The linear equivalence theorem certifies that encoding is a $K$-linear injection and that erasure decoding (from any $k$ received symbols) is the inverse linear map.

**Computational demonstration**: Our Python implementation shows a $[7, 4, 4]$ RS code correctly encoding and decoding from 4 of 7 received symbols.

### 5.2 Shamir's Secret Sharing

A $(t, n)$-threshold secret sharing scheme:
1. Choose a random polynomial $p \in \mathcal{P}_{\le t-1}$ with $p(0) = s$ (the secret).
2. Distribute shares $(i, p(i))$ for $i = 1, \ldots, n$.
3. Any $t$ shares reconstruct $p$ by interpolation; fewer than $t$ shares reveal nothing about $s$.

The linear equivalence guarantees reconstruction is exact and unique from any $t$ shares. Information-theoretic security follows from the fact that $t-1$ evaluations of a degree-$(t-1)$ polynomial are consistent with every possible value of $p(0)$.

### 5.3 Symbolic Regression

On a finite domain $\{x_0, \ldots, x_n\} \subset K$, the linear equivalence provides:
- **Existence**: for any data $(x_i, y_i)$, there exists a unique $p \in \mathcal{P}_{\le n}$ fitting the data.
- **Linearity**: the coefficient vector depends linearly on the data values.
- **Identifiability**: the polynomial representation is unique, resolving any ambiguity in the symbolic model.

Our demonstration recovers the function $f(x) = x^3$ exactly from 6 sample points.

### 5.4 Signal Reconstruction

For signals representable as polynomials of degree $\le n$ (a finite-dimensional analogue of bandlimited signals), the theorem provides the polynomial version of the Nyquist–Shannon sampling theorem: $n+1$ distinct samples suffice for perfect reconstruction, and the reconstruction operator (interpolation) is linear and bounded.

---

## 6. Computational Experiments

### 6.1 Round-Trip Verification

We verified the evaluation–interpolation round-trip on random polynomials of degree $\le 3$ with nodes $\{1, 2, 3, 4\}$ over $\mathbb{R}$. Maximum coefficient error after round-trip: $< 10^{-10}$ (floating-point precision).

### 6.2 Linearity Verification

For random polynomials $p, q$ and scalars $a, b$:
- $\text{ev}(ap + bq) = a \cdot \text{ev}(p) + b \cdot \text{ev}(q)$: verified to machine precision.
- $\text{interp}(af + bg) = a \cdot \text{interp}(f) + b \cdot \text{interp}(g)$: verified to machine precision.

### 6.3 Finite Field Computation

Interpolation over $\text{GF}(11)$ with nodes $\{1, 3, 5, 7\}$ and values $\{2, 8, 4, 10\}$:
- Recovered coefficients: $[0, 2, 6, 5]$ (mod 11).
- Verification: all evaluations match exactly.

### 6.4 Reed–Solomon Demonstration

$[7, 4, 4]$ Reed–Solomon code with message $[3, 1, 4, 1]$:
- Encoding: $[9, 29, 69, 135, 233, 369, 549]$.
- Decoding from 4 of 7 symbols: exact recovery of $[3, 1, 4, 1]$.

### 6.5 Vandermonde Conditioning

| Nodes | $n$ | $\det(V)$ | $\kappa(V)$ |
|-------|-----|-----------|-------------|
| $\{0,1,2,3\}$ | 4 | 12.0 | 154.5 |
| $\{1,2,3,5\}$ | 4 | 48.0 | 88.1 |
| $\{-1,0,1,2\}$ | 4 | 12.0 | 47.4 |

Balanced node placement reduces the condition number, a well-known phenomenon in numerical analysis.

---

## 7. Proof Architecture

### 7.1 Dependency Graph

```
degree_interpolate_lt_of_injective
        ↓
natDegree_interpolate_le    eval_interp_eq_id    interp_eval_eq_id
        ↓                        ↓                      ↓
  interpAtNodes ←────────── evalOnNodesLinearEquiv ──→ evalAtNodes
```

### 7.2 Key Proof Techniques

1. **Degree bound**: Follows from Mathlib's `Lagrange.degree_interpolate_lt` after converting between `Finset.univ` cardinality and the natural number $n+1$.

2. **Right inverse**: Direct application of `Lagrange.eval_interpolate_at_node` at each node, using `Function.Injective.injOn` for the `Set.InjOn` hypothesis.

3. **Left inverse**: Uses the polynomial uniqueness theorem `Polynomial.eq_of_degree_sub_lt_of_eval_index_eq`. The key insight: both the original polynomial and its re-interpolation have degree $< n+1$ and agree at all $n+1$ nodes, so their difference has degree $< n+1$ with $n+1$ roots, forcing it to be zero.

### 7.3 Axiom Usage

The formalization depends on exactly three axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

These are the standard foundational axioms of Lean's type theory and introduce no unsoundness.

---

## 8. Contrast with Tropical Algebra

In tropical mathematics, where $a \oplus b = \max(a, b)$ and $a \otimes b = a + b$, the evaluation map for tropical polynomials does *not* admit a canonical inverse:

1. Different tropical polynomials can have identical evaluation functions (e.g., $\max(x, 0)$ and $\max(x, 0, x+(-\infty))$).
2. The tropical evaluation map is not injective on the coefficient space.
3. Right inverses exist but are non-unique.

This contrast, already formalized in related work on tropical inverse problems, highlights that the classical linear equivalence depends essentially on the algebraic properties of fields: commutativity, the absence of zero divisors, and the root-counting bound for polynomials.

---

## 9. Discussion

### 9.1 Significance

The linear equivalence theorem upgrades polynomial interpolation from an algorithmic technique to a certified algebraic isomorphism. This distinction matters because:

- **Composability**: The `LinearEquiv` interface allows downstream theorems to transport properties between polynomial and function spaces without re-proving interpolation properties.
- **Abstraction**: The result holds over *any* field, not just $\mathbb{R}$ or $\mathbb{C}$, including finite fields relevant to coding theory and cryptography.
- **Canonicity**: Unlike arbitrary bijections, this equivalence preserves linear structure, making it compatible with tensor products, duality, and other categorical constructions.

### 9.2 Limitations

1. The result requires the field to contain at least $n+1$ distinct elements, which fails for very small finite fields with degree exceeding the field characteristic.
2. Numerical stability of the interpolation map (condition number of the Vandermonde matrix) is not addressed by the algebraic result.
3. The formalization uses `degreeLT` rather than `natDegree ≤ n` for the polynomial subspace, which is natural but may require conversion lemmas in some downstream applications.

### 9.3 Comparison with Alternative Approaches

**Strategy B (Vandermonde)**: Would require formalizing matrix representations and the Vandermonde determinant formula. More overhead for the same result, but would yield additional corollaries about determinants.

**Strategy C (Dimension argument)**: Would use `FiniteDimensional.linearEquiv_of_injective` after proving injectivity and equal dimensions. Cleaner abstractly but hides the explicit inverse.

Our Strategy A (direct construction) was chosen because it gives the strongest computational content: the inverse map is *exactly* `Lagrange.interpolate`, not merely an abstract existence.

---

## 10. Future Work

1. **Reed–Solomon distance theorem**: Formalize that the minimum distance of the $[n, k]$ evaluation code is $n - k + 1$.
2. **Multivariate interpolation**: Extend to tensor-product grids for multivariate polynomials.
3. **Error correction**: Formalize the Berlekamp–Welch algorithm for decoding from errors (not just erasures).
4. **Sheaf-theoretic formulation**: Define a sheaf of polynomial functions on a finite discrete site and prove the global sections are computed by interpolation.
5. **Tropical comparison**: Formalize the precise structural obstruction that prevents tropical polynomials from admitting a linear evaluation inverse.

---

## References

1. J.-L. Lagrange, *Leçons élémentaires sur les mathématiques*, 1795.
2. I. S. Reed and G. Solomon, "Polynomial codes over certain finite fields," *J. SIAM*, 8(2):300–304, 1960.
3. A. Shamir, "How to share a secret," *Comm. ACM*, 22(11):612–613, 1979.
4. R. Roth, *Introduction to Coding Theory*, Cambridge University Press, 2006.
5. The Mathlib Community, *Mathlib: a unified library of mathematics formalized in Lean 4*, 2024. Available at https://github.com/leanprover-community/mathlib4.
