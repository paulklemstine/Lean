/-
  # Tropical Vacuum Energy: Min-Plus Cosmological Constant

  This file formalizes the principle that in an idempotent min-plus (tropical)
  quantization, vacuum energy is determined by *selection* of the least-action
  diagram rather than *accumulation* over all diagrams.

  ## Mathematical content

  Given a finite family of "vacuum diagrams" indexed by `ι` with action
  functional `S : ι → ℝ`, the tropical vacuum energy is defined as the
  infimum (minimum) of the action spectrum over a nonempty finite set `s`.

  We prove:
  1. The tropical vacuum energy is attained by some diagram.
  2. It dominates all other actions from below.
  3. Adding higher-action diagrams cannot change the vacuum value (stability).
  4. A unique minimizer with a positive gap gives rigidity.
  5. Uniform action shifts translate the vacuum level covariantly.

  These results formalize the "vacuum catastrophe collapse" principle:
  in the tropical regime, the min-plus semiring sum replaces additive
  accumulation with extremal selection, so divergent sums over high-energy
  sectors are structurally impossible.
-/

import Mathlib

open Finset

/-! ## Definition of tropical vacuum energy -/

/-- The tropical vacuum energy of a finite nonempty set of diagrams with
    action functional `S` is the minimum action over the set.
    This is the min-plus analogue of the partition function. -/
noncomputable def tropicalVacuumEnergy {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (S : ι → ℝ) : ℝ :=
  s.inf' hs S

/-! ## Core properties -/

/-- The tropical vacuum energy is a lower bound: it is at most the action
    of any diagram in the set. -/
theorem tropical_vacuum_energy_le {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (S : ι → ℝ) :
    ∀ j ∈ s, tropicalVacuumEnergy s hs S ≤ S j :=
  fun _ hj => Finset.inf'_le _ hj

/-- The tropical vacuum energy is attained: there exists a diagram whose
    action equals the vacuum energy. This is the "selector" property —
    the tropical partition function picks an actual diagram. -/
theorem tropical_vacuum_energy_mem {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (S : ι → ℝ) :
    ∃ i ∈ s, tropicalVacuumEnergy s hs S = S i :=
  exists_mem_eq_inf' hs S

/-- Combined attainment and domination: the tropical vacuum energy is
    realized by an actual diagram and dominates all others. -/
theorem tropical_vacuum_energy_eq_minimal_action {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (S : ι → ℝ) :
    ∃ i ∈ s, tropicalVacuumEnergy s hs S = S i ∧
      ∀ j ∈ s, tropicalVacuumEnergy s hs S ≤ S j :=
  Exists.elim (tropical_vacuum_energy_mem s hs S)
    fun i hi => ⟨i, hi.1, hi.2, fun j hj => tropical_vacuum_energy_le s hs S j hj⟩

/-! ## Stability / catastrophe-collapse theorems -/

/-- If one diagram has action no larger than all others, the tropical vacuum
    energy equals that diagram's action. The vacuum is controlled by the
    shortest / least-action diagram. -/
theorem tropical_vacuum_energy_of_dominating_diagram {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (i : ι) (hi : i ∈ s) (S : ι → ℝ)
    (hmin : ∀ j ∈ s, S i ≤ S j) :
    tropicalVacuumEnergy s hs S = S i :=
  le_antisymm (Finset.inf'_le _ hi) (Finset.le_inf' _ _ hmin)

/-- Adding a diagram whose action is at least the current vacuum energy
    does not change the vacuum value. This is the "120 orders of magnitude
    do not accumulate" principle: expensive diagrams are irrelevant. -/
theorem tropical_vacuum_energy_insert_of_ge {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (hs : s.Nonempty) (i : ι) (S : ι → ℝ)
    (hge : tropicalVacuumEnergy s hs S ≤ S i) :
    tropicalVacuumEnergy (insert i s) (Finset.insert_nonempty i s) S
    = tropicalVacuumEnergy s hs S := by
  unfold tropicalVacuumEnergy at *
  simp +decide [*, Finset.inf'_insert]

/-! ## Gap rigidity -/

/-- Gap rigidity theorem: if a diagram `i` is the unique minimizer with a
    positive gap `δ` separating it from all competitors, then the vacuum
    energy equals `S i`. This gives a certified robustness radius. -/
theorem tropical_vacuum_gap_rigidity {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (i : ι) (hi : i ∈ s)
    (S : ι → ℝ) (δ : ℝ) (hδ : 0 < δ)
    (hgap : ∀ j ∈ s, j ≠ i → S i + δ ≤ S j) :
    tropicalVacuumEnergy s hs S = S i :=
  le_antisymm (Finset.inf'_le _ hi)
    (Finset.le_inf' _ _ fun j hj => by
      by_cases h : j = i <;> [aesop; linarith [hgap j hj h]])

/-! ## Renormalization covariance -/

/-- Uniform action shift covariance: shifting all actions by a constant `c`
    shifts the vacuum energy by `c`. This is the tropical analogue of
    vacuum-energy renormalization under uniform counterterms. -/
theorem tropical_vacuum_energy_shift {ι : Type*}
    (s : Finset ι) (hs : s.Nonempty) (S : ι → ℝ) (c : ℝ) :
    tropicalVacuumEnergy s hs (fun i => c + S i) = c + tropicalVacuumEnergy s hs S := by
  unfold tropicalVacuumEnergy
  refine le_antisymm ?_ ?_ <;> simp +decide [Finset.inf'_le_iff, Finset.le_inf'_iff]
  · exact Finset.exists_min_image _ _ hs
  · exact fun i hi => ⟨i, hi, le_rfl⟩

/-! ## Idempotence -/

/-- Min-plus idempotence: `min a a = a`. Repeated copies of the same vacuum
    contribution do not change the value — multiplicity is annihilated. -/
theorem tropical_min_idempotent (a : ℝ) : min a a = a := min_self a

/-- Idempotence at the vacuum level: inserting a diagram already in the set
    does not change the vacuum energy. -/
theorem tropical_vacuum_energy_insert_self {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (hs : s.Nonempty) (i : ι) (hi : i ∈ s) (S : ι → ℝ) :
    tropicalVacuumEnergy (insert i s) (Finset.insert_nonempty i s) S
    = tropicalVacuumEnergy s hs S := by
  simp [tropicalVacuumEnergy, Finset.insert_eq_of_mem hi]

/-! ## Monotonicity -/

/-- Enlarging the diagram set can only decrease the vacuum energy.
    More diagrams means more candidates for the minimum. -/
theorem tropical_vacuum_energy_mono {ι : Type*}
    (s t : Finset ι) (hs : s.Nonempty) (hst : s ⊆ t) (S : ι → ℝ) :
    tropicalVacuumEnergy t (hs.mono hst) S ≤ tropicalVacuumEnergy s hs S := by
  unfold tropicalVacuumEnergy
  simp +zetaDelta at *
  exact fun b hb => ⟨b, hst hb, le_rfl⟩