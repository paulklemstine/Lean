/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
theorem energyDefect_nonneg (x y : S) (β : ℝ) (hβ : 0 ≤ β)
    (ν : SpectralPoint S → ℝ) (hν : ∀ p, 0 ≤ ν p) :
    0 ≤ energyDefect x y β ν :=
  mul_nonneg hβ (Finset.sum_nonneg fun p _ =>
    mul_nonneg (hν p) (countermodelDefect_nonneg x y p))

/-- The rate functional is nonneg for nonneg inputs. -/
theorem thermodynamicRate_nonneg (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (hβ : 0 ≤ β) (x y : S)
    (ν : SpectralPoint S → ℝ) (hν : ∀ p, 0 ≤ ν p) :
    0 ≤ thermodynamicRate D μ β x y ν :=
  add_nonneg (D.d_nonneg ν μ) (energyDefect_nonneg x y β hβ ν hν)

/-- The energy defect vanishes when `x` derives `y`. -/
theorem energyDefect_zero_of_derivable (x y : S) (β : ℝ)
    (μ : SpectralPoint S → ℝ) (h : derivable x y) :
    energyDefect x y β μ = 0 := by
  unfold energyDefect
  suffices ∑ p : SpectralPoint S, μ p * countermodelDefect x y p = 0 by
    rw [this]; ring
  exact Finset.sum_eq_zero fun p _ => by
    rw [derivable_implies_zero_defect x y h p]; ring

/-- When derivable, the rate at the reference measure is zero. -/
theorem thermodynamicRate_self_zero_of_derivable (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S) (h : derivable x y) :
    thermodynamicRate D μ β x y μ = 0 := by
  unfold thermodynamicRate
  rw [D.d_self, energyDefect_zero_of_derivable x y β μ h]
  ring

/-- The rate is zero iff both components are zero. -/
theorem thermodynamicRate_eq_zero_iff (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (hβ : 0 ≤ β) (x y : S)
    (ν : SpectralPoint S → ℝ) (hν : ∀ p, 0 ≤ ν p) :
    thermodynamicRate D μ β x y ν = 0 ↔
      D.d ν μ = 0 ∧ energyDefect x y β ν = 0 := by
  constructor
  · intro h
    have h1 := D.d_nonneg ν μ
    have h2 := energyDefect_nonneg x y β hβ ν hν
    constructor <;> linarith [show thermodynamicRate D μ β x y ν =
      D.d ν μ + energyDefect x y β ν from rfl]
  · rintro ⟨h1, h2⟩
    show D.d ν μ + energyDefect x y β ν = 0
    linarith

/-! ## Part 7: Full Support and the Backward Direction -/

/-- A distribution has **full support** if `μ(p) > 0` for all spectral points. -/
def FullSupport (μ : SpectralPoint S → ℝ) : Prop :=
  ∀ p : SpectralPoint S, 0 < μ p

/-- If `μ` has full support and `¬derivable x y`, then the expected defect under `μ`
is strictly positive. -/
theorem expected_defect_pos_of_nonderivable [PrimeSpectralComplete S]
    (μ : SpectralPoint S → ℝ) (hμ : FullSupport μ) (x y : S)
    (hnd : ¬derivable x y) :
    0 < ∑ p : SpectralPoint S, μ p * countermodelDefect x y p := by
  obtain ⟨p₀, hp₀⟩ := nonderivable_exists_positive_defect x y hnd
  exact Finset.sum_pos' (fun p _ => mul_nonneg (le_of_lt (hμ p)) (countermodelDefect_nonneg x y p))
    ⟨p₀, Finset.mem_univ p₀, mul_pos (hμ p₀) hp₀⟩

/-- Non-derivability implies strictly positive rate at the reference measure. -/
theorem nonderivable_rate_at_ref_pos [PrimeSpectralComplete S]
    (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμ : FullSupport μ) (x y : S)
    (hnd : ¬derivable x y) (β : ℝ) (hβ : 0 < β) :
    0 < thermodynamicRate D μ β x y μ := by
  show 0 < D.d μ μ + energyDefect x y β μ
  rw [D.d_self, zero_add]
  exact mul_pos hβ (expected_defect_pos_of_nonderivable μ hμ x y hnd)

/-! ## Part 8: Rate Set and Infimum -/

/-- The set of thermodynamic rates over nonneg distributions. -/
def rateSet (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S) : Set ℝ :=
  { r | ∃ ν : SpectralPoint S → ℝ, (∀ p, 0 ≤ ν p) ∧
    r = thermodynamicRate D μ β x y ν }

theorem rateSet_bddBelow (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (hβ : 0 ≤ β) (x y : S) :
    BddBelow (rateSet D μ β x y) :=
  ⟨0, fun _ ⟨ν, hν, hr⟩ => hr ▸ thermodynamicRate_nonneg D μ β hβ x y ν hν⟩

theorem rateSet_nonempty (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμ : ∀ p, 0 ≤ μ p)
    (β : ℝ) (x y : S) :
    (rateSet D μ β x y).Nonempty :=
  ⟨thermodynamicRate D μ β x y μ, μ, hμ, rfl⟩

/-- **Forward direction**: derivable implies sInf of rate set = 0. -/
theorem derivable_implies_sInf_rateSet_eq_zero (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμ : ∀ p, 0 ≤ μ p) (x y : S) (β : ℝ) (hβ : 0 < β)
    (h : derivable x y) :
    sInf (rateSet D μ β x y) = 0 := by
  apply le_antisymm
  · apply csInf_le (rateSet_bddBelow D μ β hβ.le x y)
    exact ⟨μ, hμ, (thermodynamicRate_self_zero_of_derivable D μ β x y h).symm⟩
  · exact le_csInf (rateSet_nonempty D μ hμ β x y)
      (fun _ ⟨ν, hν, hr⟩ => hr ▸ thermodynamicRate_nonneg D μ β hβ.le x y ν hν)

/-! ## Part 9: The Sanov Property and Backward Direction -/

/-- Enhanced divergence with the **Sanov property**: if the infimum of the
rate functional approaches zero, then the expected observable at the
reference must be zero. This models the key concentration-of-measure
property that makes the large-deviation argument work. -/
structure StrongDivergence (Ω : Type*) [Fintype Ω] extends Divergence Ω where
  sanov_property : ∀ (μ : Ω → ℝ) (f : Ω → ℝ) (β : ℝ),
    (∀ p, 0 ≤ μ p) → (∀ p, 0 ≤ f p) → 0 < β →
    (∀ ε > 0, ∃ ν : Ω → ℝ, (∀ p, 0 ≤ ν p) ∧
      toDivergence.d ν μ + β * ∑ p, ν p * f p < ε) →
    ∑ p, μ p * f p = 0

/-- **Backward direction with StrongDivergence**. -/
theorem sInf_rateSet_eq_zero_implies_derivable [PrimeSpectralComplete S]
    (D : StrongDivergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμpos : FullSupport μ) (hμnn : ∀ p, 0 ≤ μ p)
    (x y : S) (β : ℝ) (hβ : 0 < β)
    (hinf : sInf (rateSet D.toDivergence μ β x y) = 0) :
    derivable x y := by
  rw [derivable_iff_zero_defect]
  intro p
  rw [countermodelDefect_eq_zero_iff]
  -- Show that the expected defect under μ is zero
  suffices hsum : ∑ q : SpectralPoint S, μ q * countermodelDefect x y q = 0 by
    have hp_term : μ p * countermodelDefect x y p = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun q _ =>
        mul_nonneg (le_of_lt (hμpos q)) (countermodelDefect_nonneg x y q))).mp
        hsum p (Finset.mem_univ p)
    rcases mul_eq_zero.mp hp_term with hm | hd
    · exact absurd hm (ne_of_gt (hμpos p))
    · rwa [countermodelDefect_eq_zero_iff] at hd
  -- Apply the Sanov property
  apply D.sanov_property μ (countermodelDefect x y) β hμnn
    (countermodelDefect_nonneg x y) hβ
  -- Show: ∀ ε > 0, ∃ ν nonneg with D(ν‖μ) + β * E_ν[defect] < ε
  intro ε hε
  have : ∃ r ∈ rateSet D.toDivergence μ β x y, r < ε := by
    by_contra h
    push_neg at h
    have : ε ≤ sInf (rateSet D.toDivergence μ β x y) :=
      le_csInf (rateSet_nonempty D.toDivergence μ hμnn β x y) h
    linarith
  obtain ⟨_, ⟨ν, hν, rfl⟩, hr⟩ := this
  exact ⟨ν, hν, hr⟩

/-! ## Part 10: Main Completeness Theorems -/

/-- **Thermodynamic Sanov Completeness (per β)**. -/
theorem thermodynamic_sanov_completeness_fixed_beta [PrimeSpectralComplete S]
    (D : StrongDivergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμpos : FullSupport μ) (hμnn : ∀ p, 0 ≤ μ p)
    (x y : S) (β : ℝ) (hβ : 0 < β) :
    derivable x y ↔ sInf (rateSet D.toDivergence μ β x y) = 0 :=
  ⟨derivable_implies_sInf_rateSet_eq_zero D.toDivergence μ hμnn x y β hβ,
   sInf_rateSet_eq_zero_implies_derivable D μ hμpos hμnn x y β hβ⟩

/-- **Thermodynamic Sanov Completeness (full)**: derivability ↔ the infimum of
the rate set is zero for all inverse temperatures β > 0. -/
theorem thermodynamic_sanov_completeness [PrimeSpectralComplete S]
    (D : StrongDivergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμpos : FullSupport μ) (hμnn : ∀ p, 0 ≤ μ p)
    (x y : S) :
    derivable x y ↔
      ∀ β : ℝ, 0 < β → sInf (rateSet D.toDivergence μ β x y) = 0 := by
  constructor
  · intro h β hβ
    exact (thermodynamic_sanov_completeness_fixed_beta D μ hμpos hμnn x y β hβ).mp h
  · intro h
    exact (thermodynamic_sanov_completeness_fixed_beta D μ hμpos hμnn x y 1 one_pos).mpr
      (h 1 one_pos)

/-- **Non-derivability creates a positive rate gap**. -/
theorem nonderivable_has_positive_rate_gap [PrimeSpectralComplete S]
    (D : StrongDivergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (hμpos : FullSupport μ) (hμnn : ∀ p, 0 ≤ μ p)
    (x y : S) (hnd : ¬derivable x y) :
    ∃ β : ℝ, 0 < β ∧ 0 < sInf (rateSet D.toDivergence μ β x y) := by
  refine ⟨1, one_pos, ?_⟩
  have hge : 0 ≤ sInf (rateSet D.toDivergence μ 1 x y) :=
    le_csInf (rateSet_nonempty D.toDivergence μ hμnn 1 x y)
      (fun _ ⟨ν, hν, hr⟩ => hr ▸ thermodynamicRate_nonneg D.toDivergence μ 1 zero_le_one x y ν hν)
  rcases lt_or_eq_of_le hge with h | h
  · exact h
  · exfalso
    exact hnd ((thermodynamic_sanov_completeness_fixed_beta D μ hμpos hμnn x y 1 one_pos).mpr h.symm)

/-! ## Part 11: Concrete Divergence: Squared L2 -/

/-- The squared L2 divergence: `D(ν‖μ) = ∑ p, (ν p - μ p)^2`. -/
def l2Divergence (Ω : Type*) [Fintype Ω] : Divergence Ω where
  d ν μ := ∑ p : Ω, (ν p - μ p) ^ 2
  d_nonneg _ _ := Finset.sum_nonneg fun _ _ => sq_nonneg _
  d_self _ := by simp
  d_faithful ν μ h := by
    ext p
    have hp : (ν p - μ p) ^ 2 = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg (fun q _ => sq_nonneg (ν q - μ q))).mp h p
        (Finset.mem_univ p)
    exact sub_eq_zero.mp (pow_eq_zero_iff two_ne_zero |>.mp hp)

/-
The squared L2 divergence satisfies the Sanov property.
-/
theorem l2_sanov_property (Ω : Type*) [Fintype Ω] :
    ∀ (μ : Ω → ℝ) (f : Ω → ℝ) (β : ℝ),
    (∀ p, 0 ≤ μ p) → (∀ p, 0 ≤ f p) → 0 < β →
    (∀ ε > 0, ∃ ν : Ω → ℝ, (∀ p, 0 ≤ ν p) ∧
      (∑ p : Ω, (ν p - μ p) ^ 2) + β * ∑ p, ν p * f p < ε) →
    ∑ p, μ p * f p = 0 := by
  intro μ f β hμ hf hβ happrox
  -- Key insight: taking ν = μ gives rate = β * ∑ μ*f.
  -- If ∑ μ*f > 0, then β * ∑ μ*f > 0.
  -- For any ε with 0 < ε < β * ∑ μ*f, the approximation gives
  -- a ν with ∑(ν-μ)² + β*∑ν*f < ε.
  -- But ∑(ν-μ)² ≥ 0 so β*∑ν*f < ε.
  -- We need to show this leads to a contradiction by using the
  -- fact that ν close to μ in L2 gives ∑ν*f close to ∑μ*f.
  by_contra hne
  have hpos : 0 < ∑ p, μ p * f p :=
    lt_of_le_of_ne (Finset.sum_nonneg fun p _ => mul_nonneg (hμ p) (hf p)) (Ne.symm hne)
  -- Take ε = β * ∑ μ*f / 2
  have hε : 0 < β * (∑ p, μ p * f p) / 2 := by positivity
  obtain ⟨ν, hν, hrate⟩ := happrox _ hε
  -- From hrate: ∑(ν-μ)² + β*∑ν*f < β*∑μ*f / 2
  have hl2 : ∑ p : Ω, (ν p - μ p) ^ 2 < β * (∑ p, μ p * f p) / 2 := by
    have : β * ∑ p, ν p * f p ≥ 0 := by
      apply mul_nonneg hβ.le
      exact Finset.sum_nonneg fun p _ => mul_nonneg (hν p) (hf p)
    linarith
  -- The key estimate: |∑ ν*f - ∑ μ*f| ≤ (∑ f) * √(∑(ν-μ)²)
  -- by Cauchy-Schwarz. But this is complex to formalize.
  -- Instead, use: for each p, |ν p - μ p| ≤ √(∑(ν-μ)²),
  -- so ν p * f p ≥ (μ p - √(∑(ν-μ)²)) * f p.
  -- But this still needs √, which is messy.
  -- Direct approach: since ∑(ν-μ)² ≥ 0 and rate < ε,
  -- we have β*∑ν*f < ε, i.e., ∑ν*f < ε/β.
  -- But ε = β*∑μ*f/2, so ∑ν*f < ∑μ*f/2.
  -- Now we need: when ∑(ν-μ)² is small, ∑ν*f cannot be much smaller than ∑μ*f.
  -- This requires a quantitative lower bound. Let me do a cleaner argument.
  -- Use: β * ∑ ν*f ≥ 0, so ∑(ν-μ)² < ε.
  -- Also ∑ν*f < ε/β = ∑μ*f/2.
  -- But ∑ν*f = ∑μ*f + ∑(ν-μ)*f.
  -- So ∑(ν-μ)*f < ∑μ*f/2 - ∑μ*f = -∑μ*f/2 < 0.
  -- And |∑(ν-μ)*f|² ≤ (∑(ν-μ)²)*(∑f²) by Cauchy-Schwarz.
  -- So (∑μ*f/2)² ≤ (∑(ν-μ)*f)² ≤ (∑(ν-μ)²)*(∑f²).
  -- Since ∑(ν-μ)² < β*∑μ*f/2, we get:
  -- (∑μ*f)²/4 ≤ β*∑μ*f/2 * ∑f²
  -- ∑μ*f/4 ≤ β*∑f²/2 (dividing by ∑μ*f > 0)
  -- ∑μ*f ≤ 2β*∑f².
  -- This is satisfied for large ∑μ*f, so no contradiction from one ε.
  -- The issue is we can only get the contradiction by going to smaller ε.
  -- Let me try ε = β²*(∑μ*f)²/(8*∑f² + 1).
  -- This is getting too complex. Let me just sorry this and prove it with the subagent.
  -- By contradiction, assume $\sum \mu p * f p > 0$.
  have h_contra : ∀ ε > 0, ∃ ν : Ω → ℝ, (∀ p, 0 ≤ ν p) ∧ ∑ p, (ν p - μ p) ^ 2 + β * ∑ p, ν p * f p < ε := by
    exact happrox;
  -- Choose $\epsilon = \min(\mu p₀^2 / 4, \beta \mu p₀ f p₀ / 2)$.
  obtain ⟨p₀, hp₀⟩ : ∃ p₀, μ p₀ * f p₀ > 0 := by
    contrapose! hne; exact Finset.sum_eq_zero fun p _ => le_antisymm ( hne p ) ( mul_nonneg ( hμ p ) ( hf p ) ) ;
  set ε := min (μ p₀ ^ 2 / 4) (β * μ p₀ * f p₀ / 2) / 2 with hε_def
  have hε_pos : 0 < ε := by
    exact div_pos ( lt_min ( div_pos ( sq_pos_of_pos ( lt_of_le_of_ne ( hμ p₀ ) ( Ne.symm ( by rintro h; simp +decide [ h ] at hp₀ ) ) ) ) zero_lt_four ) ( div_pos ( mul_pos ( mul_pos hβ ( lt_of_le_of_ne ( hμ p₀ ) ( Ne.symm ( by rintro h; simp +decide [ h ] at hp₀ ) ) ) ) ( lt_of_le_of_ne ( hf p₀ ) ( Ne.symm ( by rintro h; simp +decide [ h ] at hp₀ ) ) ) ) zero_lt_two ) ) zero_lt_two;
  obtain ⟨ν, hν, hrate⟩ := h_contra ε hε_pos
  have hl2 : ∑ p, (ν p - μ p) ^ 2 < ε := by
    exact lt_of_le_of_lt ( le_add_of_nonneg_right <| mul_nonneg hβ.le <| Finset.sum_nonneg fun _ _ => mul_nonneg ( hν _ ) <| hf _ ) hrate
  have hν_p₀ : ν p₀ > μ p₀ / 2 := by
    have hν_p₀ : (ν p₀ - μ p₀) ^ 2 < μ p₀ ^ 2 / 4 := by
      exact lt_of_le_of_lt ( Finset.single_le_sum ( fun p _ => sq_nonneg ( ν p - μ p ) ) ( Finset.mem_univ p₀ ) ) ( hl2.trans_le ( by linarith [ min_le_left ( μ p₀ ^ 2 / 4 ) ( β * μ p₀ * f p₀ / 2 ) ] ) );
    nlinarith only [ hν p₀, hμ p₀, hν_p₀ ]
  have hsum : ∑ p, ν p * f p ≥ ν p₀ * f p₀ := by
    exact Finset.single_le_sum ( fun p _ => mul_nonneg ( hν p ) ( hf p ) ) ( Finset.mem_univ p₀ )
  have hrate_ge : β * ν p₀ * f p₀ > ε := by
    cases min_cases ( μ p₀ ^ 2 / 4 ) ( β * μ p₀ * f p₀ / 2 ) <;> nlinarith [ mul_le_mul_of_nonneg_left hν_p₀.le hβ.le, mul_le_mul_of_nonneg_left hν_p₀.le ( hf p₀ ), mul_le_mul_of_nonneg_left hν_p₀.le ( hμ p₀ ), hμ p₀, hf p₀ ] ;
  have hrate_lt : ∑ p, (ν p - μ p) ^ 2 + β * ∑ p, ν p * f p ≥ β * ν p₀ * f p₀ := by
    nlinarith [ show 0 ≤ ∑ p, ( ν p - μ p ) ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]
  linarith [hrate]

/-- The squared L2 strong divergence. -/
def l2StrongDivergence (Ω : Type*) [Fintype Ω] : StrongDivergence Ω where
  toDivergence := l2Divergence Ω
  sanov_property := l2_sanov_property Ω

/-! ## Part 12: The Minimizer Predicate -/

/-- The rate function minimizer predicate. -/
def isRateFunctionMinimizer (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) (I : ℝ) : Prop :=
  I = thermodynamicRate D μ β x y ν ∧
  ∀ ν', thermodynamicRate D μ β x y ν ≤ thermodynamicRate D μ β x y ν'

/-- The infimum over minimizer values is ≤ infimum of the rate set
(which ranges over all nonneg distributions). -/
theorem sInf_rateSet_le_of_minimizer (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (hβ : 0 ≤ β) (x y : S)
    (ν : SpectralPoint S → ℝ) (hν : ∀ p, 0 ≤ ν p) (I : ℝ)
    (hmin : isRateFunctionMinimizer D μ β x y ν I) :
    sInf (rateSet D μ β x y) ≤ I := by
  rw [hmin.1]
  exact csInf_le (rateSet_bddBelow D μ β hβ x y) ⟨ν, hν, rfl⟩

end ThermodynamicSanov

/-! ## Part 13: Axiom verification -/

open ThermodynamicSanov in
#print axioms countermodelDefect_nonneg
open ThermodynamicSanov in
#print axioms countermodelDefect_le_one
open ThermodynamicSanov in
#print axioms derivable_implies_zero_defect
#print axioms ThermodynamicSanov.derivable_iff_zero_defect
#print axioms ThermodynamicSanov.nonderivable_exists_positive_defect
#print axioms ThermodynamicSanov.energyDefect_nonneg
#print axioms ThermodynamicSanov.thermodynamicRate_nonneg
#print axioms ThermodynamicSanov.thermodynamicRate_self_zero_of_derivable
#print axioms ThermodynamicSanov.thermodynamicRate_eq_zero_iff
#print axioms ThermodynamicSanov.expected_defect_pos_of_nonderivable
#print axioms ThermodynamicSanov.nonderivable_rate_at_ref_pos
#print axioms ThermodynamicSanov.derivable_implies_sInf_rateSet_eq_zero
#print axioms ThermodynamicSanov.thermodynamic_sanov_completeness_fixed_beta
#print axioms ThermodynamicSanov.thermodynamic_sanov_completeness
#print axioms ThermodynamicSanov.nonderivable_has_positive_rate_gap