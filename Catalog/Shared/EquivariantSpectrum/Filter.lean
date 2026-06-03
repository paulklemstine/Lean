/-
# Obstruction Filters

An **obstruction filter** is an abstract algebraic structure axiomatizing the
properties of impossibility spectra.
-/

import Shared.EquivariantSpectrum.Basic

open MulAction Set Function

universe u v w

variable {G : Type u} [Group G]

/-! ## The Obstruction Filter -/

/-- An **obstruction filter** on a group `G` is a set of subgroups satisfying:
1. **Upward closure**: if `H` is in the filter and `H ≤ K`, then `K` is in the filter
2. **Excludes bottom**: the trivial subgroup `⊥` is not in the filter
3. **Conjugation invariance**: if `H` is in the filter and `g ∈ G`, then `gHg⁻¹` is in the filter

This axiomatizes the key structural properties of impossibility spectra. -/
structure ObstructionFilter (G : Type u) [Group G] where
  /-- The carrier set of subgroups -/
  carrier : Set (Subgroup G)
  /-- Upward closure in the subgroup lattice -/
  upward_closed : ∀ {H K : Subgroup G}, H ∈ carrier → H ≤ K → K ∈ carrier
  /-- The trivial subgroup is not an obstruction -/
  bot_not_mem : ⊥ ∉ carrier
  /-- Conjugation invariance: the filter is closed under conjugation by group elements -/
  conj_invariant : ∀ (g : G) {H : Subgroup G}, H ∈ carrier →
    H.map (MulEquiv.toMonoidHom (MulAut.conj g)) ∈ carrier

/-! ## Transfer principle -/

/-- An equivariant bijection transfers the spectrum: if there exist mutual inverses
`φ : X → X'` and `ψ : X' → X` that are both equivariant, then
Spectrum(X', Y) ⊆ Spectrum(X, Y). -/
theorem spectrum_transfer_source {X X' : Type v} {Y : Type w}
    [MulAction G X] [MulAction G X'] [MulAction G Y]
    (φ : X → X') (ψ : X' → X)
    (_hφ : ∀ H : Subgroup G, IsEquivariantMap H φ)
    (hψ : ∀ H : Subgroup G, IsEquivariantMap H ψ)
    (_hφψ : LeftInverse ψ φ)
    (H : Subgroup G) (hH : H ∈ ImpossibilitySpectrum G X' Y) :
    H ∈ ImpossibilitySpectrum G X Y := by
  refine' fun ⟨ f, hf ⟩ => hH ⟨ f ∘ ψ, fun h hh x => _ ⟩
  have := hψ H h hh; aesop

/-
**Target covariance**: If there is an equivariant surjection `π : Y → Y'`,
then any equivariant map `X → Y` can be composed with `π` to get an equivariant
map `X → Y'`. Contrapositively, if no equivariant map `X → Y'` exists, then
no equivariant map `X → Y` can exist either.
-/
theorem spectrum_covariant_surj_target {X : Type v} {Y Y' : Type w}
    [MulAction G X] [MulAction G Y] [MulAction G Y']
    (π : Y → Y')
    (hπ_equiv : ∀ H : Subgroup G, IsEquivariantMap H π)
    {H : Subgroup G}
    (hH : H ∈ ImpossibilitySpectrum G X Y') :
    H ∈ ImpossibilitySpectrum G X Y := by
  contrapose! hH;
  simp_all +decide [ ImpossibilitySpectrum ];
  exact ⟨ π ∘ hH.choose, fun g hg x => by simpa using hπ_equiv H g hg ( hH.choose x ) ▸ hH.choose_spec g hg x ▸ rfl ⟩

/-! ## Monotonicity in the lattice -/

/-- The impossibility spectrum is monotone in the subgroup lattice:
it forms an upper set. -/
theorem ImpossibilitySpectrum.isUpperSet {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y] :
    IsUpperSet (ImpossibilitySpectrum G X Y) := by
  intro H K hHK hH
  exact ImpossibilitySpectrum.upward_closed hHK hH

/-! ## Intersection of spectra -/

/-- The intersection of two impossibility spectra is again upward closed. -/
theorem ImpossibilitySpectrum.inter_upward_closed
    {X₁ : Type v} {Y₁ : Type w} {X₂ : Type v} {Y₂ : Type w}
    [MulAction G X₁] [MulAction G Y₁] [MulAction G X₂] [MulAction G Y₂] :
    IsUpperSet (ImpossibilitySpectrum G X₁ Y₁ ∩ ImpossibilitySpectrum G X₂ Y₂) := by
  exact IsUpperSet.inter ImpossibilitySpectrum.isUpperSet ImpossibilitySpectrum.isUpperSet

/-! ## Quantitative fixed-point obstruction -/

/-- **Quantitative fixed-point obstruction**: If the number of fixed points of `H` in `X`
exceeds the number of fixed points of `H` in `Y`, then no *injective* `H`-equivariant
map `X → Y` exists. This is a quantitative strengthening of the qualitative obstruction. -/
theorem no_injective_equivariant_of_fixed_card_lt {X : Type v} {Y : Type w}
    [MulAction G X] [MulAction G Y] [Fintype X] [Fintype Y]
    (H : Subgroup G)
    [DecidablePred (· ∈ FixedPointSet H X)]
    [DecidablePred (· ∈ FixedPointSet H Y)]
    (hcard : (FixedPointSet H Y).toFinset.card < (FixedPointSet H X).toFinset.card) :
    ¬ ∃ f : X → Y, Injective f ∧ IsEquivariantMap H f := by
  contrapose! hcard
  obtain ⟨ f, hf₁, hf₂ ⟩ := hcard; have hf₃ := @equivariant_maps_fixed_to_fixed
  have := @Finset.card_le_card_of_injOn
  convert this f _ _
  exacts [ fun x hx => by simpa using hf₃ H f hf₂ (by simpa using hx),
           fun x hx y hy hxy => hf₁ hxy ]