/-
# Heat Death of Mathematics: finite computation versus infinite theorem spaces

This file separates mathematical consequences from physical assumptions.  A finitary
proof system has finite strings as statements and an arbitrary certificate relation.
Countability is unconditional.  Infinitude is represented by an explicit family of
pairwise distinct provable statements; for ZFC, such a family can be supplied by the
usual distinct logical validities after fixing an encoding.

The physical constants are parameters or named finite budgets.  The Bekenstein area
law is modelled by `c * M^2`; its physical derivation is not claimed here.
-/

import Mathlib

open Filter Topology

namespace HeatDeathMathematics

/-- A minimal finitary deductive system: statements and certificates are finite strings. -/
structure FinitarySystem where
  StatementAlphabet : Type
  CertificateAlphabet : Type
  statementAlphabet_finite : Finite StatementAlphabet
  certificateAlphabet_finite : Finite CertificateAlphabet
  accepts : List CertificateAlphabet → List StatementAlphabet → Prop

attribute [instance] FinitarySystem.statementAlphabet_finite
attribute [instance] FinitarySystem.certificateAlphabet_finite

namespace FinitarySystem

variable (S : FinitarySystem)

abbrev Statement := List S.StatementAlphabet
abbrev Certificate := List S.CertificateAlphabet

/-- A theorem is a statement together with the proposition that some finite certificate
is accepted. -/
def Theorem := {φ : S.Statement // ∃ p : S.Certificate, S.accepts p φ}

/-- The theorems of every finitary deductive system are countable. -/
theorem theorem_countable : Countable S.Theorem := by
  have h : Set.Countable (Set.univ : Set (List S.StatementAlphabet)) := Set.countable_univ
  have hp : Set.Countable {φ : List S.StatementAlphabet | ∃ p : List S.CertificateAlphabet, S.accepts p φ} := h.mono (fun x _ => trivial)
  exact Set.countable_coe_iff.mpr hp

/-- An explicit infinite family of distinct theorems makes the theorem type infinite. -/
theorem theorem_infinite_of_injective (family : ℕ → S.Theorem)
    (hfamily : Function.Injective family) : Infinite S.Theorem := by
  exact Infinite.of_injective family hfamily

/-- A concrete enumerability formulation: if the theorem type is infinite and countable,
it admits a bijective numbering by natural numbers. -/
theorem theorem_denumerable [Infinite S.Theorem] : Nonempty (ℕ ≃ S.Theorem) := by
  haveI : Countable S.Theorem := theorem_countable S
  exact ⟨((Cardinal.eq.1 (Cardinal.mk_eq_aleph0 S.Theorem)).some.trans Equiv.ulift).symm⟩

end FinitarySystem

/-! ## Finite operation budgets -/

/-- The conventional heat-death operation budget used in this model.  The only fact
needed below is that it is a natural number and hence finite. -/
def cosmicOperationBudget : ℕ := 10 ^ 120

/-- Outputs produced by the first `B` calls of a theorem enumerator. -/
def discovered {T : Type*} (enumerate : ℕ → T) (B : ℕ) : Set T :=
  enumerate '' Set.Iio B

/-- Any computation producing at most one theorem per operation discovers a finite set
under a finite operation budget. -/
theorem discovered_finite {T : Type*} (enumerate : ℕ → T) (B : ℕ) :
    (discovered enumerate B).Finite := by
  rw [discovered]
  exact Set.Finite.image enumerate (Set.finite_Iio B)

/-- The number of distinct outputs cannot exceed the operation budget. -/
theorem discovered_ncard_le_budget {T : Type*} (enumerate : ℕ → T) (B : ℕ) :
    (discovered enumerate B).ncard ≤ B := by
  unfold discovered
  calc (enumerate '' Set.Iio B).ncard ≤ (Set.Iio B).ncard := Set.ncard_image_le (s := Set.Iio B)
    _ = B := by simp [Set.ncard_eq_toFinset_card']

/-- In particular, the `10^120` operation horizon discovers only finitely many outputs. -/
theorem cosmic_horizon_finite {T : Type*} (enumerate : ℕ → T) :
    (discovered enumerate cosmicOperationBudget).Finite := by
  exact discovered_finite enumerate cosmicOperationBudget

/-- **Disproof of global finite-time completion.** No finite initial segment of an
enumeration of an infinite type can contain every object.  Countable infinitude means
each theorem may occur at a finite index, not that all occur before one common finite
time. -/
theorem no_finite_time_discovers_all {T : Type*} [Infinite T]
    (enumerate : ℕ → T) (B : ℕ) :
    discovered enumerate B ≠ Set.univ := by
  intro h
  have hf := discovered_finite enumerate B
  rw [h] at hf
  exact Set.infinite_univ hf

/-- The same no-go theorem at the named cosmic operation horizon. -/
theorem cosmic_budget_not_exhaustive {T : Type*} [Infinite T]
    (enumerate : ℕ → T) :
    discovered enumerate cosmicOperationBudget ≠ Set.univ := by
  exact no_finite_time_discovers_all enumerate cosmicOperationBudget

/-! ## Density-zero theorem -/

/-- The fraction, among the first `N` indices, whose numbered objects lie in `D`. -/
noncomputable def discoveryFraction {T : Type*} (numbering : ℕ → T) (D : Set T)
    (N : ℕ) : ℝ := by
  classical
  exact ((Finset.filter (fun n => numbering n ∈ D) (Finset.range N)).card : ℝ) / N

/-- A finite collection has asymptotic natural density zero in any injective numbering. -/
theorem finite_discovery_fraction_tendsto_zero {T : Type*}
    (numbering : ℕ → T) (hn : Function.Injective numbering) (D : Set T)
    (hD : D.Finite) :
    Tendsto (discoveryFraction numbering D) atTop (𝓝 0) := by
  unfold discoveryFraction
  -- The set of n with numbering n ∈ D is finite since numbering is injective and D is finite
  have hpreimage : Set.Finite {n : ℕ | numbering n ∈ D} := by
    have hD' : Set.Finite D := hD
    exact Set.Finite.preimage (Set.injOn_of_injective hn) hD'
  -- The cardinality is bounded by the size of the preimage
  classical
  have hbound : ∃ C, ∀ N, ((Finset.filter (fun n => numbering n ∈ D) (Finset.range N)).card : ℝ) ≤ C := by
    exact ⟨hpreimage.toFinset.card, fun N => by
      have : Finset.filter (fun n => numbering n ∈ D) (Finset.range N) ⊆ hpreimage.toFinset := by
        simp [Finset.subset_iff]
      exact_mod_cast Finset.card_le_card this⟩
  obtain ⟨C, hC⟩ := hbound
  have hnonneg : ∀ N, 0 ≤ ((Finset.filter (fun n => numbering n ∈ D) (Finset.range N)).card : ℝ) := fun N => by positivity
  have htends : Tendsto (fun N : ℕ => C / (N : ℝ)) atTop (𝓝 0) := tendsto_const_div_atTop_nhds_zero_nat C
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds htends _ _
  · intro N; exact div_nonneg (hnonneg N) (Nat.cast_nonneg N)
  · intro N; exact div_le_div_of_nonneg_right (hC N) (Nat.cast_nonneg N)

/-- Consequently, any finite operation horizon captures density zero of an injectively
numbered infinite theorem family. -/
theorem budget_discovery_fraction_tendsto_zero {T : Type*}
    (numbering enumerate : ℕ → T) (hn : Function.Injective numbering) (B : ℕ) :
    Tendsto (discoveryFraction numbering (discovered enumerate B))
      atTop (𝓝 0) := by
  exact finite_discovery_fraction_tendsto_zero numbering hn _
    (discovered_finite enumerate B)

/-! ## Black-hole area-law model -/

/-- Idealized Bekenstein capacity: for coefficient `c`, a black hole of mass `M`
stores `c M²` bits.  This is the precise mathematical meaning of the scaling claim
inside this model. -/
def blackHoleCapacity (c M : ℝ) : ℝ := c * M ^ 2

/-- The area-law capacity scales quadratically under mass rescaling. -/
theorem blackHoleCapacity_scale (c a M : ℝ) :
    blackHoleCapacity c (a * M) = a ^ 2 * blackHoleCapacity c M := by
  unfold blackHoleCapacity
  ring

/-- Doubling mass quadruples idealized storage. -/
theorem blackHoleCapacity_double (c M : ℝ) :
    blackHoleCapacity c (2 * M) = 4 * blackHoleCapacity c M := by
  unfold blackHoleCapacity
  ring

/-- Merging two nonnegative masses never decreases total area-law capacity. -/
theorem merged_capacity_dominates (c M₁ M₂ : ℝ)
    (hc : 0 ≤ c) (hM₁ : 0 ≤ M₁) (hM₂ : 0 ≤ M₂) :
    blackHoleCapacity c M₁ + blackHoleCapacity c M₂ ≤
      blackHoleCapacity c (M₁ + M₂) := by
  unfold blackHoleCapacity
  nlinarith [mul_nonneg hM₁ hM₂, mul_nonneg hc (mul_nonneg hM₁ hM₂)]

/-- The exact storage gain from merging is the cross term `2 c M₁ M₂`. -/
theorem merged_capacity_gain (c M₁ M₂ : ℝ) :
    blackHoleCapacity c (M₁ + M₂) -
      (blackHoleCapacity c M₁ + blackHoleCapacity c M₂) =
      2 * c * M₁ * M₂ := by
  unfold blackHoleCapacity
  ring

/-- A finite positive mass and finite coefficient yield finite natural-bit capacity
when rounded down. -/
noncomputable def blackHoleBitBudget (c M : ℝ) : ℕ :=
  ⌊max 0 (blackHoleCapacity c M)⌋₊

/-- **Black holes do not evade the finite-horizon result.** For every fixed black-hole
bit budget, the set of theorem strings that can be selected by one output per stored bit
is finite and cannot exhaust an infinite theorem type. -/
theorem black_hole_storage_not_exhaustive {T : Type*} [Infinite T]
    (enumerate : ℕ → T) (c M : ℝ) :
    discovered enumerate (blackHoleBitBudget c M) ≠ Set.univ := by
  exact no_finite_time_discovers_all enumerate (blackHoleBitBudget c M)

/-- Even with black-hole storage, every fixed mass budget captures density zero of an
injectively numbered theorem family. -/
theorem black_hole_fraction_tendsto_zero {T : Type*}
    (numbering enumerate : ℕ → T) (hn : Function.Injective numbering) (c M : ℝ) :
    Tendsto
      (discoveryFraction numbering
        (discovered enumerate (blackHoleBitBudget c M)))
      atTop (𝓝 0) := by
  exact budget_discovery_fraction_tendsto_zero numbering enumerate hn
    (blackHoleBitBudget c M)

end HeatDeathMathematics