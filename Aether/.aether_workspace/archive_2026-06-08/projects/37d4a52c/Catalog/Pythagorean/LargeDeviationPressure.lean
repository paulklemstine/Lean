/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Large Deviation Principles for Random Generation via Subgroup Pressure

This file establishes a thermodynamic formalism for random generation of
finite groups. The central object is the **subgroup pressure** — a partition
function over proper subgroups weighted by inverse index powers — which
governs the exponential statistics of generation failure.

## Main Definitions

* `subgroupPressure` — Partition function: sum of `[G:H]^{-2t}` over proper subgroups.
* `logPressure` — Free energy: logarithm of the partition function.
* `candidateRateFunction` — Legendre–Fenchel transform of a log-moment generating function.

## Main Results

* `subgroupPressure_nonneg` — Pressure is nonneg for all `t`.
* `subgroupPressure_antitone` — Pressure is antitone in inverse temperature.
* `subgroupPressure_geometric_convex` — Log-convexity (Hölder form) of pressure.
* `candidateRateFunction_nonneg` — Rate function is nonneg under natural conditions.

## Cross-Domain Bridges

### Statistical mechanics
`subgroupPressure G t` is a partition function with energy `E(H) = 2 log [G:H]`
at inverse temperature `t`. Log-convexity is thermodynamic stability.

### Large deviations
The Legendre transform of log-pressure is the rate function controlling
exponential decay of generation-failure probabilities in product families.

### Information theory
The rate function quantifies the information cost of atypical nongeneration —
a Cramér transform for the group-theoretic setting.

## Application keywords

large deviations, random generation, subgroup growth, partition function,
free energy, Legendre transform, convexity, Chernoff bound, statistical
mechanics, information theory, direct products, maximal subgroups,
asymptotic concentration.
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

/-! ## Core Definitions -/

/-- The **subgroup pressure** of a finite group `G` at inverse temperature `t`.
This is the partition function `Z_G(t) = ∑_{H < G proper} [G:H]^{-2t}`,
where the sum ranges over all proper subgroups `H ≠ ⊤`.

Each proper subgroup is an obstruction "microstate" with energy `E(H) = 2 log [G:H]`.
The pressure controls the exponential statistics of generation failure. -/
def subgroupPressure (G : Type*) [Group G] [Fintype G] (t : ℝ) : ℝ :=
  ∑ H : {H : Subgroup G // H ≠ ⊤},
    ((H.1.index : ℝ)) ^ (-2 * t)

/-- The **log-pressure** (free energy) of a finite group at inverse temperature `t`.
In statistical mechanics, this is the free energy `F(t) = log Z(t)`. -/
def logPressure (G : Type*) [Group G] [Fintype G] (t : ℝ) : ℝ :=
  Real.log (subgroupPressure G t)

/-- The **candidate rate function** obtained as the Legendre–Fenchel transform
of a log-moment generating function `Λ`. This is the key object in large deviation
theory: `Λ*(α) = sup_t {t·α - Λ(t)}`. -/
def candidateRateFunction (Λ : ℝ → ℝ) (α : ℝ) : ℝ :=
  sSup {r : ℝ | ∃ t : ℝ, r = t * α - Λ t}

/-! ## Section 1: Basic Properties of Pressure -/

/-- Each summand in the pressure is nonneg, since it is a real power of a nonneg base. -/
theorem subgroupPressure_nonneg (G : Type*) [Group G] [Fintype G] (t : ℝ) :
    0 ≤ subgroupPressure G t := by
  apply Finset.sum_nonneg
  intro H _
  apply rpow_nonneg
  exact Nat.cast_nonneg _

/-- At `t = 0`, every summand equals 1, so pressure counts proper subgroups. -/
theorem subgroupPressure_zero (G : Type*) [Group G] [Fintype G] :
    subgroupPressure G 0 = Fintype.card {H : Subgroup G // H ≠ ⊤} := by
  simp [subgroupPressure, mul_zero, rpow_zero]

/-! ## Section 2: Log-convexity of Pressure

The key thermodynamic property: each summand `[G:H]^{-2t}` is a positive
exponential in `t`, and a sum of log-convex functions is log-convex.
This is the finite-level analytic condition that underpins large deviation theory.

### Strategy C: Hölder interpolation
Each summand `f_H(t) = ([G:H])^{-2t} = exp(-2t · log[G:H])` is log-affine in `t`,
hence log-convex. A finite sum of log-convex functions with nonneg coefficients
is log-convex (by Hölder's inequality applied termwise). -/

/-
**Hölder/geometric convexity of pressure**: For any `θ ∈ [0,1]`,
the pressure at the convex combination `θ·t₁ + (1-θ)·t₂` is bounded
by the geometric mean of pressures. This is the two-point form of log-convexity
and follows from applying Hölder's inequality termwise to the exponential summands.
-/
theorem subgroupPressure_geometric_convex
    (G : Type*) [Group G] [Fintype G]
    (t₁ t₂ θ : ℝ) (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    subgroupPressure G (θ * t₁ + (1 - θ) * t₂)
      ≤ (subgroupPressure G t₁) ^ θ * (subgroupPressure G t₂) ^ (1 - θ) := by
  -- Factor out the common term $((H.index : ℝ) ^ (-2 * t₁)) ^ θ * ((H.index : ℝ) ^ (-2 * t₂)) ^ (1 - θ)$.
  have h_factor : ∀ H : {H : Subgroup G // H ≠ ⊤}, ((H.1.index : ℝ) ^ (-2 * (θ * t₁ + (1 - θ) * t₂))) = ((H.1.index : ℝ) ^ (-2 * t₁)) ^ θ * ((H.1.index : ℝ) ^ (-2 * t₂)) ^ (1 - θ) := by
    intro H; rw [ ← Real.rpow_mul ( Nat.cast_nonneg _ ), ← Real.rpow_mul ( Nat.cast_nonneg _ ) ] ; ring;
    rw [ Real.rpow_add ( Nat.cast_pos.mpr <| Nat.pos_of_ne_zero <| Subgroup.index_ne_zero_of_finite ) ];
  -- Apply Hölder's inequality to the sum.
  have h_holder : ∀ (u v : {H : Subgroup G // H ≠ ⊤} → ℝ), (∀ H, 0 ≤ u H) → (∀ H, 0 ≤ v H) → (∑ H, u H ^ θ * v H ^ (1 - θ)) ≤ (∑ H, u H) ^ θ * (∑ H, v H) ^ (1 - θ) := by
    intros u v hu hv_Lp_mul_Lq;
    have := @Real.inner_le_Lp_mul_Lq;
    specialize @this {H : Subgroup G // H ≠ ⊤} Finset.univ (fun H => u H ^ θ) (fun H => v H ^ (1 - θ)) (1 / θ) (1 / (1 - θ));
    by_cases hθ : θ = 0 <;> by_cases hθ' : θ = 1 <;> simp_all +decide [ abs_of_nonneg, Real.rpow_nonneg ];
    convert this _ using 3;
    · exact Finset.sum_congr rfl fun _ _ => by rw [ ← Real.rpow_mul ( hv_Lp_mul_Lq _ _ ), mul_inv_cancel₀ ( sub_ne_zero_of_ne ( Ne.symm hθ' ) ), Real.rpow_one ] ;
    · constructor <;> norm_num;
      · positivity;
      · exact lt_of_le_of_ne hθ1 hθ';
  convert h_holder _ _ _ _ using 1 <;> norm_num [ subgroupPressure, h_factor ];
  · exact Finset.sum_congr rfl fun _ _ => by simpa using h_factor _;
  · exact fun _ _ => Real.rpow_nonneg ( Nat.cast_nonneg _ ) _;
  · exact fun _ _ => Real.rpow_nonneg ( Nat.cast_nonneg _ ) _

/-! ## Section 3: Monotonicity of Pressure

### Thermodynamic interpretation
Increasing inverse temperature `t` suppresses high-energy (low-index) obstruction
channels. Each summand `[G:H]^{-2t}` is a decreasing function of `t` when
`[G:H] > 1` (i.e., H is proper), so the total pressure is antitone. -/

/-
Pressure is antitone (decreasing) in inverse temperature `t`.
Each summand `[G:H]^{-2t}` with `[G:H] ≥ 1` satisfies `a^{-2s} ≥ a^{-2t}`
when `s ≤ t` and `a ≥ 1`.
-/
theorem subgroupPressure_antitone
    (G : Type*) [Group G] [Fintype G] :
    Antitone (subgroupPressure G) := by
  intro s t hst
  apply Finset.sum_le_sum
  intro H _
  apply rpow_le_rpow_of_exponent_le (by
  exact_mod_cast Nat.one_le_iff_ne_zero.mpr ( Subgroup.index_ne_zero_of_finite )) (by
  linarith)

/-! ## Section 4: Rate Function Properties

The candidate rate function `Λ*(α) = sup_t {tα - Λ(t)}` is the Legendre transform.
When `Λ(0) ≤ 0`, the rate function is nonneg. -/

/-
The candidate rate function is nonneg when `Λ(0) ≤ 0`.
This follows because setting `t = 0` in the supremum gives `0·α - Λ(0) = -Λ(0) ≥ 0`,
so the supremum is at least nonneg.
-/
theorem candidateRateFunction_nonneg
    (Λ : ℝ → ℝ) (α : ℝ) (hΛ : Λ 0 ≤ 0)
    (hbdd : BddAbove {r : ℝ | ∃ t : ℝ, r = t * α - Λ t}) :
    0 ≤ candidateRateFunction Λ α := by
  exact le_trans ( by linarith ) ( le_csSup hbdd ⟨ 0, rfl ⟩ )

/-! ## Section 5: Subgroup index lemma for proper subgroups -/

/-
The index of any proper subgroup of a nontrivial finite group is at least 2.
-/
theorem Subgroup.index_ge_two_of_ne_top {G : Type*} [Group G] [Fintype G]
    (H : Subgroup G) (hH : H ≠ ⊤) :
    2 ≤ H.index := by
  contrapose! hH;
  interval_cases _ : H.index <;> simp_all +decide [ Subgroup.eq_top_iff' ];
  simp_all +decide [ Subgroup.index ];
  simp_all +decide [ Nat.card_eq_zero ];
  exact False.elim <| ‹Infinite ( G ⧸ H ) ›.false

/-! ## Section 6: Summand monotonicity helper

For `a ≥ 1`, the function `t ↦ a ^ (-2*t)` is antitone. -/

theorem rpow_neg_two_mul_antitone {a : ℝ} (ha : 1 ≤ a) :
    Antitone (fun t : ℝ => a ^ (-2 * t)) := by
  exact fun t t' h => Real.rpow_le_rpow_of_exponent_le ha <| by linarith;

end