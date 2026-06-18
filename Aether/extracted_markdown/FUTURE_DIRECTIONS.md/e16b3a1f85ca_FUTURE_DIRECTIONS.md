# Future Directions: Kakeya Conjecture Formalization

## 1. Full Formalization of Dvir's Finite Field Kakeya Theorem

The statement `dvir_kakeya_bound` is currently sorry'd. The full proof requires
building the polynomial method infrastructure: showing that the space of
multivariate polynomials of bounded total degree has dimension `(d+n choose n)`,
constructing a nonzero vanishing polynomial via linear algebra when `|K| < (q-1+n choose n)`,
and then using the Schwartz-Zippel base case (which we have proved as
`poly_vanishing_on_finite_field`) to derive a contradiction via restriction to lines.

The key insight is that the parameter counting step — dim of degree-≤-d polynomials
in n variables equals `(d+n choose n)` — requires formalizing the bijection between
monomials and compositions, which is nontrivial in Lean but entirely within reach
using `MvPolynomial` and `Finsupp` infrastructure.

Why now? Our formalization of `poly_vanishing_on_finite_field` provides the inductive
base case. The remaining gap is the linear algebra dimension argument and the
restriction-to-lines step, both of which are well-supported by Mathlib's
`LinearMap` and `MvPolynomial.eval` APIs.

## 2. Plünnecke-Ruzsa Inequality

The Ruzsa triangle inequality (proved here) is the first step toward the full
Plünnecke-Ruzsa inequality: if `|A + A| ≤ K|A|`, then `|nA - mA| ≤ K^{n+m}|A|`.
This inequality is the engine behind most applications of additive combinatorics
to the Kakeya problem.

The key insight is that Plünnecke's graph-theoretic proof can be formalized using
Mathlib's directed graph infrastructure and the Ruzsa triangle inequality as a
building block. The recent Petridis proof simplifies this significantly by avoiding
graph theory entirely and working directly with Finset cardinality estimates.

Why now? The Ruzsa triangle inequality and sum-difference bound formalized here
are the exact prerequisites for Petridis's proof. The remaining argument is a
clever induction on `|A'|` for subsets `A' ⊆ A` minimizing `|A' + B|/|A'|`.

## 3. Multivariate Schwartz-Zippel Lemma

Our `poly_vanishing_on_finite_field` handles the univariate case. The full
Schwartz-Zippel lemma bounds the probability that a random evaluation of a
multivariate polynomial is zero: for `p ∈ F[X₁,...,Xₙ]` of total degree d
and S ⊆ F, `Pr[p(r₁,...,rₙ) = 0] ≤ d/|S|` when rᵢ are uniform on S.

The key insight is that the proof proceeds by induction on n, reducing to the
univariate case by writing p = Σ Xₙ^i · pᵢ(X₁,...,Xₙ₋₁) and applying
the union bound. Each step uses exactly our `poly_roots_card_le_degree` lemma.

Why now? The univariate polynomial root bound is proved and the inductive
structure only requires `MvPolynomial` decomposition along a variable, which
Mathlib supports via `MvPolynomial.finSuccEquiv`.

## 4. Kakeya Maximal Function Estimates

The continuous Kakeya conjecture (Hausdorff dimension n for Besicovitch sets in ℝⁿ)
connects to maximal function estimates. The Kakeya maximal operator Kδf(e) takes
the supremum of averages of |f| over δ-tubes in direction e. Wolff (1995) showed
that Lp bounds on this operator imply Hausdorff dimension bounds for Kakeya sets.

The key insight is that formalizing this connection requires defining
Hausdorff dimension (currently absent from Mathlib) and the Kakeya maximal
function, then proving the standard implication: `‖Kδ‖_{Lp→Lp} ≤ C δ^{-α}`
implies dim(Besicovitch) ≥ n - (n-1)·α. This bridges discrete (finite field)
and continuous Kakeya theory.

Why now? Mathlib's measure theory and Lp space infrastructure is mature enough
to state these results precisely, even if the deep harmonic analysis proofs
(e.g., Bourgain's bush argument, Wolff's hairbrush) remain challenging targets.

## 5. Sum-Product Estimates and Kakeya

The Erdős-Szemerédi conjecture (max(|A+A|, |A·A|) ≥ |A|^{2-ε}) is deeply
connected to Kakeya through the work of Bourgain, Katz, and Tao (2004).
They showed that sum-product estimates in finite fields imply lower bounds
on Kakeya sets. Formalizing even the basic sum-product inequality
`max(|A+A|, |A·A|) ≥ c|A|^{1+δ}` for some δ > 0 would be a significant
contribution.

The key insight is that the Ruzsa triangle inequality (proved here) combined
with multiplicative energy estimates yields the connection: if both |A+A|
and |A·A| are small, the additive and multiplicative structures of A are
simultaneously constrained, leading to a contradiction for large |A|.

Why now? Our Ruzsa infrastructure handles the additive side. The multiplicative
side requires analogous estimates for `Finset.mul` which follow by the same
injection technique (our proof of `ruzsa_triangle_ineq` readily adapts to the
multiplicative setting via `to_additive` or direct analogy).
