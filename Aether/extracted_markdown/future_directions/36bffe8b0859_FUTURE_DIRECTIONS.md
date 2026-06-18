# Future Directions: Model Theory–Algebra Bridge (Extended)

This document describes five research conjectures extending the results
formalized in `Catalog/Bridges/ModelTheoryAlgebraBridge.lean` and the
existing Ax-Kochen–Morley bridge.

---

## 1. Robinson's Joint Consistency Lemma

Two theories T₁ and T₂ in the same language L are jointly consistent
(i.e., T₁ ∪ T₂ is satisfiable) if and only if there is no sentence φ
such that T₁ ⊨ᵇ φ and T₂ ⊨ᵇ ¬φ. As a corollary, if T₁ and T₂ are
both complete and share a common model, then T₁ = T₂.

The key insight is that our `IsComplete.models_iff_mem_completeTheory`
theorem provides half the infrastructure: it shows that for a complete
theory, semantic consequence and membership in the complete theory of
any model coincide. Robinson's lemma extends this to pairs of theories,
showing that the "agreement interface" between two theories is exactly
the set of sentences decided by their intersection.

Why now? The `isComplete_iff_allModels_elEquiv` characterization gives
us a new angle: joint consistency of two complete theories reduces to
showing that a model of one is elementarily equivalent to a model of the
other. This sidesteps the usual compactness-based proof and could yield
a cleaner formalization using our elementary equivalence infrastructure.

---

## 2. Model-Completeness and Quantifier Elimination

A theory T is model-complete if every embedding between models of T is
elementary. The key conjecture for formalization: if T is model-complete
and has a prime model (a model that embeds into every model of T), then
T is complete.

The key insight is that our `elementarilyEquivalent_iff_same_theories`
theorem shows elementary equivalence is equivalent to agreeing on all
theories. For a model-complete theory, every embedding is elementary,
so the prime model is elementarily equivalent to every other model. By
our characterization, this forces completeness. The chain is:
model-completeness + prime model → universal elementary equivalence →
completeness (via our iff theorem).

Why now? Mathlib has `FirstOrder.Language.ElementaryEmbedding` and our
bridge file has the `isComplete_iff_allModels_elEquiv` characterization.
The missing piece is defining model-completeness (every embedding is
elementary) and formalizing the prime model existence theorem. Both are
clean definitions that build directly on existing Mathlib infrastructure.

---

## 3. Multivariate Henselian Lifting via Jacobian Criterion

Let R be a henselian local ring with maximal ideal m, and let
f₁, …, fₙ ∈ R[X₁, …, Xₙ]. If a₀ ∈ Rⁿ satisfies fᵢ(a₀) ∈ m for all
i and det(∂fᵢ/∂Xⱼ)(a₀) is a unit in R, then there exists a unique
a ∈ Rⁿ with fᵢ(a) = 0 and a ≡ a₀ mod m.

The key insight is that our `derivative_unit_of_congr` theorem provides
the critical stability ingredient: the Jacobian determinant remains a
unit throughout the Newton iteration because each iterate stays
congruent to a₀ modulo m. The `polynomial_eval_sub_mem_maximalIdeal`
lemma generalizes to the multivariate setting via the chain rule for
MvPolynomial.

Why now? The univariate stability theorem (`derivative_unit_of_congr`)
is now proven without sorry. Mathlib has `MvPolynomial`, `Matrix.det`,
and `MvPolynomial.pderiv`. The multivariate lift requires defining the
Jacobian matrix as a `Matrix (Fin n) (Fin n) R` of partial derivative
evaluations, then applying Newton iteration in the product topology.
This is a concrete next step with all API prerequisites in place.

---

## 4. Categorical Theories and Spectrum Functions

The spectrum function Sp(T, κ) counts the number of non-isomorphic
models of T of cardinality κ. Morley's theorem implies that for a
countable complete theory, if Sp(T, κ) = 1 for any uncountable κ,
then Sp(T, κ) = 1 for all uncountable κ. The Vaught conjecture (still
open) asks whether Sp(T, ℵ₀) ∈ {ℵ₀, 1, 2, …, ℵ₀} for countable
complete T (i.e., no countable complete theory has exactly ℵ₁ countable
models).

The key insight is that our `Categorical.all_models_elementarilyEquivalent`
theorem, which chains categoricity through completeness to universal
elementary equivalence, provides the semantic infrastructure for
reasoning about spectrum functions. The spectrum function at uncountable
cardinals is determined by the number of non-isolated types, which
connects to our complete theory characterization.

Why now? Formalizing `Cardinal.mk (Quotient (setoid of isomorphism))`
for models of a given cardinality is now feasible with Mathlib's
`Cardinal` and `Equiv` infrastructure. The first target should be
proving Sp(ACF_p, κ) = 1 for uncountable κ, which follows from the
transcendence degree classification and would connect to the ACF
completeness project.

---

## 5. Elementary Equivalence via Ehrenfeucht-Fraïssé Games

Two L-structures M and N are elementarily equivalent iff Duplicator has
a winning strategy in the Ehrenfeucht-Fraïssé game of length ω on M and
N. For each finite n, Duplicator wins the n-round game iff M and N
satisfy the same sentences of quantifier depth ≤ n.

The key insight is that our `elementarilyEquivalent_iff_same_theories`
characterization could be refined to a "quantifier-depth stratified"
version: instead of checking all theories, check theories axiomatized
by sentences of bounded quantifier depth. The EF game provides the
combinatorial counterpart, and formalizing it would give a powerful tool
for proving elementary equivalence results (e.g., for the Ax-Kochen
transfer principle) without checking sentences one by one.

Why now? The game definition is purely combinatorial (sequences of moves
and responses, defined inductively on round number) and fits naturally
into Lean's inductive type system. Mathlib's `BoundedFormula` already
tracks the number of free variables; adding a `quantifierDepth` function
and stratifying `completeTheory` by depth would connect the game to our
existing infrastructure. This would provide an alternative proof method
for results like the backward direction of
`isComplete_iff_allModels_elEquiv`.
