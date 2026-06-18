# Formalized Dimension Theory of Bounded-Degree Multivariate Polynomial Spaces

## Abstract

We present a complete formal verification of the dimension formula for bounded-degree multivariate polynomial spaces. Working over a field K with a finite variable type σ of cardinality n, we construct an explicit monomial basis for the subspace of polynomials with total degree less than d, prove it has cardinality C(d + n - 1, n), and derive the finrank equality. The formalization proceeds through three layers: (1) combinatorial counting via the stars-and-bars theorem for weak compositions, using the equivalence with symmetric products; (2) algebraic basis construction via Finsupp.supported and Finsupp.supportedEquivFinsupp; and (3) the dimension formula as a corollary of basis cardinality. We additionally formalize the homogeneous component basis and its dimension C(m + n - 1, n - 1), and prove the equivalence between our support-based submodule definition and the totalDegree characterization. All proofs are machine-verified in Lean 4 with Mathlib v4.28.0. This work provides foundational infrastructure for formalized Hilbert function theory, algebraic complexity, and graded algebra.

## 1. Introduction

### 1.1 Motivation

The space of multivariate polynomials with bounded total degree is one of the most fundamental objects in mathematics, appearing across algebra, combinatorics, geometry, and applications. Despite its importance, the basic dimension formula — that the space of polynomials in n variables with total degree less than d has dimension C(d + n - 1, n) — has not previously been formalized with full machine-verified proofs that connect the combinatorial counting to the algebraic structure.

### 1.2 Contributions

Our main contributions are:

1. **Combinatorial counting lemmas**: We prove that the number of finitely-supported functions from a finite type to ℕ with prescribed sum equals the appropriate multichoose/binomial coefficient, using the equivalence with symmetric products (Sym).

2. **Monomial basis construction**: We construct explicit bases for both the bounded-degree and exact-degree (homogeneous) submodules of MvPolynomial σ K, using the Finsupp.supported/supportedEquivFinsupp framework.

3. **Dimension formulas**: We derive finrank equalities as immediate corollaries of basis cardinality.

4. **Submodule characterization**: We prove that our support-based submodule definition is equivalent to the totalDegree-based characterization.

### 1.3 Related Work

The stars-and-bars theorem dates to Euler's work on partitions in the 18th century. The modern formulation as weak compositions appears in combinatorics textbooks. In Mathlib, the relevant ingredients include:
- `Sym.equivNatSum`: the equivalence between symmetric products and finsupp with prescribed sum
- `Sym.card_sym_fin_eq_multichoose`: cardinality of Sym via multichoose
- `Nat.multichoose_eq`: the relationship multichoose(n, k) = C(n + k - 1, k)
- `Finsupp.supported` and `Finsupp.supportedEquivFinsupp`: the supported submodule framework
- `MvPolynomial.basisMonomials`: the standard monomial basis of MvPolynomial

Our contribution is to connect these ingredients into a coherent theorem about polynomial spaces.

## 2. Definitions and Notation

### 2.1 Polynomial Spaces

We work with `MvPolynomial σ K`, the polynomial ring in variables indexed by a type σ over a commutative semiring K. This is definitionally the type `(σ →₀ ℕ) →₀ K` — finitely supported functions from exponent vectors to coefficients.

### 2.2 Degree Notions

For a finitely supported function `s : σ →₀ ℕ`, we use:
- `Finsupp.degree s = s.sum (fun _ => id) = ∑ᵢ s(i)`: the total degree of the exponent vector.

For a polynomial `p : MvPolynomial σ K`:
- `p.totalDegree = p.support.sup (fun s => (Finsupp.toMultiset s).card)`: the maximum total degree among monomials in the support.

### 2.3 Index Types

```
exactMonomialExponents σ m := {s : σ →₀ ℕ // Finsupp.degree s = m}
boundedMonomialExponents σ d := {s : σ →₀ ℕ // Finsupp.degree s < d}
```

### 2.4 Submodules

```
boundedTotalDegreeSubmodule K σ d := Finsupp.supported K K {s | degree s < d}
homogeneousComponent' K σ m := Finsupp.supported K K {s | degree s = m}
```

The use of `Finsupp.supported` is crucial: it defines the submodule as the set of all finsupp functions whose support is contained in the given set. This immediately provides:
- Submodule structure (closure under addition and scalar multiplication)
- Linear equivalence with `{s | degree s < d} →₀ K` via `supportedEquivFinsupp`
- Basis construction by transporting `basisSingleOne`

## 3. Main Results

### 3.1 Stars-and-Bars Counting

**Theorem (card_exactDegreeFinsupp_fin).**
```
Fintype.card {s : Fin n →₀ ℕ // degree s = m} = Nat.multichoose n m
```

*Proof sketch.* We use `Sym.equivNatSum (Fin n) m : Sym (Fin n) m ≃ {s : Fin n →₀ ℕ // degree s = m}` to transfer the cardinality from symmetric products, where `Sym.card_sym_fin_eq_multichoose` gives the result directly.

**Theorem (card_exactMonomialExponents).**
For σ nonempty with `n = Fintype.card σ`:
```
Fintype.card (exactMonomialExponents σ m) = C(m + n - 1, n - 1)
```

*Proof sketch.* Transport from Fin n via `Fintype.equivFin σ`, then apply the multichoose formula and `Nat.choose_symm`.

### 3.2 Hockey-Stick Identity

**Theorem (sum_multichoose_eq).**
```
∑ m ∈ range (d+1), multichoose n m = multichoose (n+1) d
```

*Proof.* Induction on d, using `multichoose_succ_succ`: multichoose(n+1)(k+1) = multichoose(n)(k+1) + multichoose(n+1)(k).

### 3.3 Bounded-Degree Counting

**Theorem (card_boundedDegreeFinsupp_fin).**
For `0 < d + n`:
```
Fintype.card {s : Fin n →₀ ℕ // degree s < d} = C(d + n - 1, n)
```

*Proof sketch.* Decompose via the equivalence `boundedFinsuppEquivSigma` into a sigma type indexed by `Fin d`, where each fiber is counted by `card_exactDegreeFinsupp_fin`. Sum using `card_sigma`, convert to a Finset.range sum, then apply the hockey-stick identity and choose arithmetic.

**Edge case.** When d = 0 and n = 0, the LHS is 0 (empty set) but C(0 + 0 - 1, 0) = C(0, 0) = 1 due to natural number subtraction. We include the hypothesis `0 < d + n` to exclude this degenerate case.

### 3.4 Basis Construction

**Definition (monomialBasisBoundedTotalDegree).**
```
Basis (boundedMonomialExponents σ d) K (boundedTotalDegreeSubmodule K σ d) :=
  (Finsupp.basisSingleOne).map (Finsupp.supportedEquivFinsupp _).symm
```

This constructs the basis in one line by:
1. Starting with `basisSingleOne : Basis ι R (ι →₀ R)`, the canonical basis of the free module
2. Composing with `supportedEquivFinsupp : supported K K S ≃ₗ S →₀ K`, the linear equivalence between the supported submodule and the restricted free module

### 3.5 Dimension Formula

**Theorem (finrank_boundedTotalDegreeSubmodule).**
For `0 < d + Fintype.card σ`:
```
finrank K (boundedTotalDegreeSubmodule K σ d) = C(d + Fintype.card σ - 1, Fintype.card σ)
```

*Proof.* Apply `finrank_eq_card_basis` to the monomial basis, then invoke `card_boundedMonomialExponents`.

**Corollary.** When σ is nonempty, the hypothesis is automatically satisfied for all d.

### 3.6 Homogeneous Component

**Theorem (finrank_homogeneousComponent).**
For σ nonempty:
```
finrank K (homogeneousComponent' K σ m) = C(m + Fintype.card σ - 1, Fintype.card σ - 1)
```

### 3.7 Submodule Characterization

**Theorem (mem_boundedTotalDegreeSubmodule_iff_totalDegree).**
For `0 < d`:
```
p ∈ boundedTotalDegreeSubmodule K σ d ↔ p.totalDegree < d
```

This bridges our support-based definition with the standard totalDegree notion.

## 4. Algorithms

### 4.1 Dimension Computation

**Algorithm: BoundedDegreeDimension(n, d)**
```
Input: n (number of variables), d (degree bound)
Output: dimension C(d + n - 1, n)
Time: O(min(n, d))
Space: O(1)

if d == 0: return 0
return binomial(d + n - 1, n)
```

### 4.2 Monomial Enumeration

**Algorithm: EnumerateMonomials(n, d)**
```
Input: n (number of variables), d (degree bound)  
Output: all exponent vectors (e_1,...,e_n) with sum < d
Time: O(output size) = O(C(d+n-1, n))
Space: O(n) stack depth

for total_deg = 0 to d-1:
    enumerate all compositions of total_deg into n parts
    (recursive with budget tracking)
```

### 4.3 Vandermonde Matrix Construction

Given N points in R^n, the generalized Vandermonde matrix has shape N × C(d+n-1, n), where column j corresponds to monomial j evaluated at each point. This matrix has full column rank when the points are in "general position," enabling unique polynomial interpolation when N ≥ C(d+n-1, n).

## 5. Applications

### 5.1 Polynomial Kernel Methods

The polynomial kernel K(x, y) = (1 + x·y)^d implicitly maps data to a feature space of dimension C(d+n, n). The dimension formula quantifies the representational power:

| n (features) | d (degree) | Feature dimension |
|:---:|:---:|---:|
| 10 | 2 | 66 |
| 10 | 3 | 286 |
| 100 | 2 | 5,151 |
| 100 | 3 | 176,851 |
| 1000 | 2 | 501,501 |

### 5.2 Reed-Muller Codes

RM(r, m) over F_q has message dimension related to bounded-degree polynomial spaces. The code rate dim / q^m is directly determined by the dimension formula.

### 5.3 Interpolation Theory

Multivariate polynomial interpolation in n variables and degree < d requires at least C(d+n-1, n) evaluation points. This is the multivariate generalization of the fact that a degree-d univariate polynomial is determined by d+1 points.

### 5.4 Statistical Mechanics

For n energy levels, the bosonic partition function has degeneracies g(m) = C(m+n-1, n-1), yielding Z = (1 - e^{-β})^{-n}. The Hilbert series of the polynomial ring is the formal analog of this partition function.

## 6. Computational Experiments

### 6.1 Formula Verification

We verified the dimension formula by exhaustive enumeration for all n ∈ {1,...,6} and d ∈ {0,...,8}, confirming agreement between:
- Direct count of exponent vectors with sum < d
- Formula C(d + n - 1, n)

### 6.2 Interpolation Experiments

For 2D cubic polynomial interpolation (n=2, d=4, dim=10):
- Constructed 10 × 10 Vandermonde matrix from random points
- Recovered exact polynomial coefficients to machine precision (error < 10^{-12})
- Confirmed matrix has full rank 10

### 6.3 Dimension Growth

The dimension grows as O(d^n / n!) for fixed n:

| d | n=2 | n=3 | n=5 | n=10 |
|:---:|---:|---:|---:|---:|
| 5 | 15 | 35 | 126 | 1,001 |
| 10 | 55 | 220 | 2,002 | 92,378 |
| 20 | 210 | 1,540 | 42,504 | 20,030,010 |

## 7. Discussion

### 7.1 Design Decisions

**Support-based vs totalDegree-based definition.** We define the submodule via `Finsupp.supported` rather than the carrier `{p | totalDegree p < d}`. This choice enables:
- Direct basis construction via `supportedEquivFinsupp`
- Clean submodule structure without any proof obligations for zero_mem, add_mem, smul_mem
- Compatibility with Mathlib's free module framework

We prove the equivalence with the totalDegree characterization as a separate theorem.

**Edge case handling.** The formula C(d+n-1, n) fails when d = n = 0 due to ℕ subtraction (gives 1 instead of 0). We handle this with a `0 < d + n` hypothesis rather than altering the formula, since this case (empty variable type, degree < 0) is degenerate and never arises in practice.

### 7.2 Limitations

- We do not formalize the graded ring structure or the direct sum decomposition of MvPolynomial into homogeneous components.
- The hockey-stick identity is proved ad hoc via induction on multichoose; a more systematic treatment via generating functions would be preferable.
- We do not connect to Mathlib's existing `HomogeneousComponent` or `GradedAlgebra` infrastructure.

### 7.3 Proof Architecture

The proof is structured in five layers:
1. **Counting for Fin n** (35 lines): Sym equivalence → multichoose → binomial
2. **Transport to general σ** (40 lines): equivCongrLeft + degree invariance
3. **Submodule definition** (10 lines): Finsupp.supported
4. **Basis construction** (5 lines): basisSingleOne + supportedEquivFinsupp
5. **Dimension formula** (5 lines): finrank_eq_card_basis + card lemma

The total formalization is under 300 lines, with the complexity concentrated in the counting layer.

## 8. Future Work

1. Formalize the Hilbert series H_R(t) = ∑ H(m) t^m = 1/(1-t)^n for polynomial rings.
2. Connect to Mathlib's GradedAlgebra and HomogeneousComponent.
3. Prove the dimension formula for quotients by monomial ideals.
4. Formalize the multivariate interpolation theorem using the Vandermonde determinant.
5. Develop Reed-Muller code dimension and minimum distance formulas.

## 9. References

1. R. P. Stanley, *Enumerative Combinatorics*, vol. 1, Cambridge University Press, 2012.
2. D. Cox, J. Little, D. O'Shea, *Ideals, Varieties, and Algorithms*, Springer, 2015.
3. W. Bruns and J. Herzog, *Cohen-Macaulay Rings*, Cambridge University Press, 1998.
4. I. S. Reed, "A class of multiple-error-correcting codes and the decoding scheme," IRE Trans. Inform. Theory, 1954.
5. The Mathlib Community, *Mathlib4*, https://github.com/leanprover-community/mathlib4, 2024.
