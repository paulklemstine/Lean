# Future Directions: Model Theory–Algebra Bridge

This document describes five research conjectures extending the
Ax-Kochen–Morley bridge formalized in `Bridges/AxKochenMorleyBridge.lean`.

---

## 1. Full Morley Categoricity Theorem

**Conjecture.** If `L` is a countable first-order language and `T` is a
complete `L`-theory that is categorical in some uncountable cardinal
`κ ≥ ℵ₁`, then `T` is categorical in every uncountable cardinal.

The key insight is that categoricity at one uncountable cardinal forces
the theory to have no Vaughtian pairs, which in turn forces every model
to be "geometrically controlled" by a strongly minimal set. The proof
passes through the Baldwin–Lachlan characterization: a countable complete
theory is uncountably categorical iff it has no Vaughtian pairs and every
model is prime over a strongly minimal set.

**Why now?** Mathlib already has `Cardinal.Categorical`, `IsComplete`,
and `ElementarilyEquivalent`. Our bridge file proves that categoricity
implies elementary equivalence via completeness — the first link in the
Morley chain. The next step is formalizing strongly minimal sets and
Vaughtian pairs. The statement is already present (with sorry) as
`morley_categoricity_statement` in the bridge file.

---

## 2. Ax-Kochen Transfer Principle for p-adic Fields

**Conjecture.** For all but finitely many primes `p`, the p-adic field
`ℚ_p` is elementarily equivalent to the Laurent series field `𝔽_p((t))`.
More precisely, if `v₁ : ValuedField K₁` and `v₂ : ValuedField K₂` are
henselian valued fields of equicharacteristic zero with elementarily
equivalent residue fields and value groups, then `K₁` and `K₂` are
elementarily equivalent.

The key insight is that Ax-Kochen-Ershov reduces the model theory of
henselian valued fields to the model theory of their residue fields and
value groups, which are much simpler objects. For equicharacteristic zero,
the transfer is unconditional; for mixed characteristic, it holds for
all sufficiently large residue characteristics.

**Why now?** Mathlib has `HenselianLocalRing`, `ValuationSubring`, and
we proved `root_unique_of_simple` establishing the uniqueness complement
to Hensel's lemma. The valued field language needs to be defined as a
`FirstOrder.Language` extending the ring language, which is a concrete
next step given Mathlib's `FirstOrder.Language.Theory.field`.

---

## 3. Henselian Lifting for Multivariate Systems

**Conjecture.** Let `R` be a henselian local ring with maximal ideal `m`,
and let `f₁, …, fₙ ∈ R[X₁, …, Xₙ]`. If `a₀ = (a₀₁, …, a₀ₙ) ∈ Rⁿ`
satisfies `fᵢ(a₀) ∈ m` for all `i` and `det(∂fᵢ/∂Xⱼ)(a₀)` is a unit
in `R`, then there exists a unique `a ∈ Rⁿ` with `fᵢ(a) = 0` and
`a - a₀ ∈ mⁿ`.

The key insight is that the univariate case (our `root_unique_of_simple`)
extends to multivariate systems via the Newton–Raphson iteration in the
m-adic topology. The Jacobian determinant condition replaces the
derivative unit condition, and the contraction mapping principle in the
m-adic complete case gives both existence and uniqueness.

**Why now?** Our theorem `root_unique_of_simple` provides the univariate
uniqueness foundation. Mathlib has `MvPolynomial` and `Matrix.det`.
The multivariate generalization connects to deformation theory and
smooth morphisms in algebraic geometry.

---

## 4. Completeness of ACF via Categoricity

**Conjecture.** The theory ACF_p (algebraically closed fields of
characteristic p, for p = 0 or p prime) is complete. This follows from
the Łoś–Vaught test: ACF_p is categorical in every uncountable cardinal
(by the transcendence degree classification), has only infinite models,
and the language is countable.

The key insight is that our `Categorical.models_elementarilyEquivalent`
theorem, combined with Mathlib's existing `FirstOrder.Language.Theory.ACF`,
provides a direct path to proving completeness of ACF. The categoricity
of ACF in uncountable cardinals follows from the fact that algebraically
closed fields of the same characteristic and transcendence degree are
isomorphic.

**Why now?** Mathlib defines `Theory.ACF` and has extensive infrastructure
for algebraically closed fields (`IsAlgClosed`). Our bridge theorem
reduces completeness to categoricity. The missing piece is formally
establishing uncountable categoricity of ACF, which requires connecting
`IsAlgClosed` with the first-order `Theory.ACF` and proving the
transcendence degree classification.

---

## 5. Elementary Equivalence and Ultraproducts

**Conjecture.** Two structures `M` and `N` are elementarily equivalent if
and only if there exists an ultrafilter `U` on some index set `I` such
that the ultrapower `M^I/U` is isomorphic to `N^I/U`.

The key insight is that Keisler's theorem provides a semantic
characterization of elementary equivalence via ultrapowers, giving a
"geometric" proof technique for showing elementary equivalence without
checking every sentence. This is the model-theoretic analogue of the
Yoneda lemma: structures are determined by their relationship to
ultraproducts.

**Why now?** Mathlib has `Filter.Ultrafilter` and product types.
Defining ultraproducts as quotients of product structures by an
ultrafilter equivalence relation is a natural formalization target.
Combined with our bridge theorems connecting elementary equivalence
to completeness and categoricity, this would provide a complete
toolkit for model-theoretic transfer arguments.
