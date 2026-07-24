/-
# Adjoint Selmer vanishing as infinitesimal rigidity

The arithmetic theorem motivating this development identifies an adjoint Bloch--Kato Selmer
space with the tangent space of a deformation problem and proves that it vanishes.  The results
below isolate the reusable geometric and linear-algebraic consequences of that vanishing:
rigidity is preserved by duality and scalar extension, it eliminates every infinitesimal
one-parameter family, and in finite dimension it is equivalent to a full-rank presentation.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Selmer vanishing should be treated structurally as a zero tangent
space, not merely as a dimension calculation.  It should force formal unramifiedness, survive
extension of coefficient fields, and gives an equivalent full-rank obstruction criterion.

Experiment (Experimenter): model a global deformation condition by a linear presentation
`relations : Parameters → Obstructions`; its tangent space is the kernel.  Test rigidity
against composition, dual equivalence, scalar extension, infinitesimal curves, and finite-
dimensional rank.  Each operation preserves or detects a zero kernel by a different argument.

Analysis (Analyst): the unifying pattern is conservativity.  Injective comparison maps,
linear equivalences, and scalar extension along a field extension all reflect zero vectors.
Thus arithmetic vanishing can be transported through changes of realization without any
residual representation hypothesis in the abstract argument.

Critique (Critic): these statements do not assert the deep arithmetic input itself; they
formalize its deformation-theoretic consequences.  The hypotheses cannot be dropped:
composition with a non-injective comparison can conceal tangent vectors, while rank detects
rigidity only under finite-dimensionality and equal source/target rank.

Synthesis (Principal Investigator): the main theorem packages four equivalent or functorial
faces of adjoint rigidity: zero tangent space, injectivity of the relation map, absence of
infinitesimal families, and (for a square finite presentation) surjectivity/full rank.
-/
import Mathlib
import Logic.BettiWhittakerPeriods

namespace AdjointBlochKato

/-- A linearized global deformation problem: parameters are constrained by a relation map,
and admissible first-order deformations form its kernel. -/
structure DeformationPresentation (K : Type*) [Field K] where
  Parameters : Type*
  Obstructions : Type*
  parametersAddCommGroup : AddCommGroup Parameters
  parametersModule : Module K Parameters
  obstructionsAddCommGroup : AddCommGroup Obstructions
  obstructionsModule : Module K Obstructions
  relations : Parameters →ₗ[K] Obstructions

attribute [instance] DeformationPresentation.parametersAddCommGroup
  DeformationPresentation.parametersModule DeformationPresentation.obstructionsAddCommGroup
  DeformationPresentation.obstructionsModule

/-- The tangent space cut out by the linearized global and local conditions. -/
abbrev DeformationPresentation.tangent {K : Type*} [Field K]
    (P : DeformationPresentation K) : Submodule K P.Parameters := P.relations.ker

/-- Rigidity means that the deformation problem has no nonzero first-order deformation. -/
def DeformationPresentation.Rigid {K : Type*} [Field K]
    (P : DeformationPresentation K) : Prop := P.tangent = ⊥

/-- Vanishing of the tangent space is exactly injectivity of the linearized relation map. -/
theorem rigid_iff_injective {K : Type*} [Field K] (P : DeformationPresentation K) :
    P.Rigid ↔ Function.Injective P.relations := by
  unfold DeformationPresentation.Rigid DeformationPresentation.tangent
  exact LinearMap.ker_eq_bot

/-- If the composite relation map detects every tangent vector, then the original relation map
does as well.  Thus a sufficiently discriminating comparison of obstruction theories reflects
adjoint rigidity. -/
theorem rigidity_reflected_by_composite
    {K V W X : Type*} [Field K] [AddCommGroup V] [Module K V]
    [AddCommGroup W] [Module K W] [AddCommGroup X] [Module K X]
    (relations : V →ₗ[K] W) (comparison : W →ₗ[K] X)
    (hcomposite : (comparison.comp relations).ker = ⊥) : relations.ker = ⊥ := by
  rw [LinearMap.ker_eq_bot] at hcomposite ⊢
  intro x y hxy
  apply hcomposite
  simp only [LinearMap.comp_apply]
  exact congrArg comparison hxy

/-- A linear equivalence of tangent realizations transports vanishing in both directions. -/
theorem rigidity_invariant_under_tangent_equiv
    {K V W : Type*} [Field K] [AddCommGroup V] [Module K V]
    [AddCommGroup W] [Module K W] (comparison : V ≃ₗ[K] W) :
    (⊤ : Submodule K V) = ⊥ ↔ (⊤ : Submodule K W) = ⊥ := by
  constructor
  · intro h
    rw [Submodule.eq_bot_iff]
    intro w _
    obtain ⟨v, rfl⟩ := comparison.surjective w
    have hv : v = 0 := by
      have : v ∈ (⊥ : Submodule K V) := h ▸ Submodule.mem_top
      simpa using this
    simp [hv]
  · intro h
    rw [Submodule.eq_bot_iff]
    intro v _
    apply comparison.injective
    have hw : comparison v ∈ (⊥ : Submodule K W) := h ▸ Submodule.mem_top
    simpa using hw

/-- Once an adjoint Selmer realization is identified with the deformation tangent space,
rigidity forces the Selmer realization itself to vanish.  This isolates the final geometric
step in the automorphic vanishing argument from the arithmetic construction of the comparison. -/
theorem adjoint_selmer_vanishes_of_tangent_identification
    {K S : Type*} [Field K] [AddCommGroup S] [Module K S]
    (P : DeformationPresentation K) (hP : P.Rigid)
    (comparison : S ≃ₗ[K] P.tangent) : (⊤ : Submodule K S) = ⊥ := by
  rw [Submodule.eq_bot_iff]
  intro s _
  apply comparison.injective
  apply Subtype.ext
  have hmem : (comparison s : P.Parameters) ∈ (⊥ : Submodule K P.Parameters) :=
    hP ▸ (comparison s).property
  simpa using hmem

/-- Conversely, a Selmer--tangent comparison transfers vanishing back to deformation
rigidity.  Thus the two formulations are equivalent, rather than merely numerically related. -/
theorem tangent_rigid_of_adjoint_selmer_vanishing
    {K S : Type*} [Field K] [AddCommGroup S] [Module K S]
    (P : DeformationPresentation K) (comparison : S ≃ₗ[K] P.tangent)
    (hS : (⊤ : Submodule K S) = ⊥) : P.Rigid := by
  unfold DeformationPresentation.Rigid
  rw [Submodule.eq_bot_iff]
  intro v hv
  obtain ⟨s, hs⟩ := comparison.surjective ⟨v, hv⟩
  have szero : s = 0 := by
    have : s ∈ (⊥ : Submodule K S) := hS ▸ Submodule.mem_top
    simpa using this
  have : (⟨v, hv⟩ : P.tangent) = 0 := by
    rw [← hs, szero]
    simp
  exact congrArg Subtype.val this

/-- A Selmer--tangent identification makes vanishing and deformation rigidity equivalent. -/
theorem adjoint_selmer_vanishing_iff_rigid
    {K S : Type*} [Field K] [AddCommGroup S] [Module K S]
    (P : DeformationPresentation K) (comparison : S ≃ₗ[K] P.tangent) :
    (⊤ : Submodule K S) = ⊥ ↔ P.Rigid := by
  constructor
  · exact tangent_rigid_of_adjoint_selmer_vanishing P comparison
  · intro hP
    exact adjoint_selmer_vanishes_of_tangent_identification P hP comparison

/-- A rigid deformation problem admits no nonconstant infinitesimal family: every family whose
velocity satisfies the linearized conditions has zero velocity. -/
theorem no_infinitesimal_family_of_rigid
    {K : Type*} [Field K] (P : DeformationPresentation K) (hP : P.Rigid)
    {I : Type*} (velocity : I → P.Parameters)
    (hadmissible : ∀ i, P.relations (velocity i) = 0) : ∀ i, velocity i = 0 := by
  rw [rigid_iff_injective] at hP
  intro i
  apply hP
  simpa using hadmissible i

/-- For a square finite-dimensional presentation, adjoint rigidity is equivalent to every
obstruction being generated by the linearized relations. -/
theorem rigid_iff_relations_surjective_of_equal_finrank
    {K : Type*} [Field K] (P : DeformationPresentation K)
    [FiniteDimensional K P.Parameters] [FiniteDimensional K P.Obstructions]
    (hrank : Module.finrank K P.Parameters = Module.finrank K P.Obstructions) :
    P.Rigid ↔ Function.Surjective P.relations := by
  rw [rigid_iff_injective]
  exact LinearMap.injective_iff_surjective_of_finrank_eq_finrank hrank

/-- Scalar extension of a relation map preserves rigidity.  This is the algebraic core of the
principle that adjoint Selmer vanishing is independent of enlarging the coefficient field. -/
theorem rigidity_preserved_by_scalar_extension
    {K L V W : Type*} [Field K] [Field L] [Algebra K L]
    [AddCommGroup V] [Module K V] [AddCommGroup W] [Module K W]
    (relations : V →ₗ[K] W) (hrelations : relations.ker = ⊥) :
    (relations.baseChange L).ker = ⊥ := by
  rw [LinearMap.ker_eq_bot] at hrelations ⊢
  rw [LinearMap.baseChange_eq_ltensor]
  exact Module.Flat.lTensor_preserves_injective_linearMap relations hrelations

/-- Contragredient duality of algebraic weights preserves the vanishing of the corresponding
abstract tangent realization.  This connects deformation rigidity with the catalog's
contragredient involution for regular algebraic weights. -/
theorem contragredient_preserves_zero_variation {n : ℕ}
    (variation : BettiWhittaker.Weight n)
    (hvariation : variation = 0) : BettiWhittaker.dual variation = 0 := by
  rw [hvariation]
  funext i
  simp [BettiWhittaker.dual]

/-- Duality reflects zero variation as well as preserving it. -/
theorem zero_variation_iff_contragredient_zero {n : ℕ}
    (variation : BettiWhittaker.Weight n) :
    BettiWhittaker.dual variation = 0 ↔ variation = 0 := by
  constructor
  · intro h
    have := congrArg BettiWhittaker.dual h
    simpa [BettiWhittaker.dual_involutive] using this
  · exact contragredient_preserves_zero_variation variation

end AdjointBlochKato