import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialWashoutInvariance
import Bridges.ORDialMultiPrimeWashout

/-!
# Washout of a residue dial of arbitrary order

`Bridges.ORDialCharacterWashout` shows that a multiplier group containing a quadratic
non-residue flattens the quadratic-character profile.  The same phenomenon is not special
to order two.  Let `K ≤ G` be *any* subgroup of the class group, of index `d ≥ 2`, and let
`H` be a multiplier group with `H ⊔ K = ⊤` — i.e. the multipliers already generate every
residue class modulo `K`.  Then:

* `mix_subgroupProfile_eq_const` : the randomised profile is the constant `1/d`, so the
  whole order-`d` residue channel is flattened;
* `orInfo_mix_subgroupProfile_of_sup_eq_top` : the dial reads exactly `0`;
* `orInfo_subgroupProfile_pos` : with fixed multipliers the same profile reads
  `H(1/d²) - (1/d)H(1/d) > 0`, strictly positive for every index `d ≥ 2`;
* `residue_channel_collapse` : the two facts together, with the mean rate `1/d`
  unchanged — the count statistic is blind to the collapse at every order, not only at
  order two.

The proof of constancy is a pure coset argument: for classes `a, b` write `a b⁻¹ = h k`
with `h ∈ H`, `k ∈ K`; translating the summation index by `h` matches the two sums term by
term.  No character theory and no counting of `H ∩ K` is needed — the value of the
constant is recovered afterwards from `avg_mix`.
-/

open Real Finset

namespace ORDial

section ResidueWashout

variable {G : Type*} [Fintype G] [CommGroup G]

open Classical in
/-- **Constancy of the randomised residue profile.**  If the multiplier group together
with `K` generates the whole class group, the randomised kernel profile takes the same
value at every class. -/
lemma mix_subgroupProfile_const (K H : Subgroup G) (hHK : H ⊔ K = ⊤) (a b : G) :
    mix H (subgroupProfile K) a = mix H (subgroupProfile K) b := by
  classical
  obtain ⟨h₀, hh₀, k, hk, hab⟩ : ∃ y ∈ H, ∃ z ∈ K, y * z = a * b⁻¹ :=
    Subgroup.mem_sup.mp (by rw [hHK]; exact Subgroup.mem_top _)
  have hkey : h₀⁻¹ * a = k * b := by
    have ha : a = h₀ * k * b := by rw [hab]; group
    rw [ha]
    group
  have hmem : ∀ g : G, (g * h₀⁻¹ ∈ H ↔ g ∈ H) := by
    intro g
    constructor
    · intro hg; simpa using H.mul_mem hg hh₀
    · intro hg; exact H.mul_mem hg (H.inv_mem hh₀)
  unfold mix
  congr 1
  refine (Fintype.sum_equiv (Equiv.mulRight h₀⁻¹) _ _ (fun g => ?_)).symm
  by_cases hg : g ∈ H
  · have hgh : g * h₀⁻¹ ∈ H := (hmem g).mpr hg
    simp only [Equiv.coe_mulRight, if_pos hgh, if_pos hg]
    have harg : g * h₀⁻¹ * a = g * b * k := by
      rw [mul_assoc, hkey, ← mul_assoc, mul_right_comm]
    rw [harg]
    unfold subgroupProfile
    by_cases hb : g * b ∈ K
    · rw [if_pos (K.mul_mem hb hk), if_pos hb]
    · have : ¬ (g * b * k ∈ K) := fun hc => hb (by simpa using K.mul_mem hc (K.inv_mem hk))
      rw [if_neg this, if_neg hb]
  · have : ¬ (g * h₀⁻¹ ∈ H) := fun hc => hg ((hmem g).mp hc)
    simp [this, hg]

/-- **The randomised residue profile is the constant `1/d`.** -/
theorem mix_subgroupProfile_eq_const (K H : Subgroup G) (hHK : H ⊔ K = ⊤) :
    mix H (subgroupProfile K) = fun _ : G => 1 / (K.index : ℝ) := by
  have hconst : mix H (subgroupProfile K) = fun _ : G => mix H (subgroupProfile K) 1 := by
    funext a
    exact mix_subgroupProfile_const K H hHK a 1
  have havg : avg (mix H (subgroupProfile K)) = 1 / (K.index : ℝ) := by
    rw [avg_mix, avg_subgroupProfile]
  rw [hconst] at havg ⊢
  rw [avg_const] at havg
  rw [havg]

/-- **Total collapse of an order-`d` residue channel.** -/
theorem orInfo_mix_subgroupProfile_of_sup_eq_top (K H : Subgroup G) (hHK : H ⊔ K = ⊤) :
    orInfo (mix H (subgroupProfile K)) = 0 := by
  rw [mix_subgroupProfile_eq_const K H hHK]
  exact orInfo_const _

/-- **The residue dial is strictly positive at every index `d ≥ 2`.**  Fixed multipliers
keep a genuine channel open no matter what the order of the character is. -/
theorem orInfo_subgroupProfile_pos (K : Subgroup G) (hd : 2 ≤ K.index) :
    0 < orInfo (subgroupProfile K) := by
  have hd0 : (0:ℝ) < (K.index : ℝ) := by
    have : (0:ℕ) < K.index := by omega
    exact_mod_cast this
  set x : ℝ := 1 / (K.index : ℝ) with hx
  have hxpos : 0 < x := by rw [hx]; positivity
  have h2R : (2:ℝ) ≤ (K.index : ℝ) := by exact_mod_cast hd
  have hxhalf : x ≤ 1/2 := by
    rw [hx]
    exact one_div_le_one_div_of_le (by norm_num) h2R
  have hx1 : x < 1 := by linarith
  have hxsq1 : x ^ 2 < 1 := by nlinarith
  have hlow := binEntropy_ge_negMulLog_add_mul (x := x ^ 2) hxsq1
  have hup := binEntropy_le_negMulLog_add_self hxpos hx1
  have hlogsq : Real.log (x ^ 2) = 2 * Real.log x := by
    rw [Real.log_pow]; push_cast; ring
  rw [hlogsq] at hlow
  have hlogx : Real.log x ≤ -Real.log 2 := by
    have h := Real.log_le_log (by positivity) hxhalf
    rwa [show (1:ℝ)/2 = 2⁻¹ by norm_num, Real.log_inv] at h
  have h2gt : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hxB : x * Real.binEntropy x ≤ x * (-(x * Real.log x) + x) :=
    mul_le_mul_of_nonneg_left hup hxpos.le
  have hlog2 : x ^ 2 * Real.log x ≤ x ^ 2 * (-Real.log 2) :=
    mul_le_mul_of_nonneg_left hlogx (by positivity)
  have hxsq : x ^ 2 ≤ 1/4 := by nlinarith
  have hx4 : x ^ 4 ≤ x ^ 2 * (1/4) :=
    calc x ^ 4 = x ^ 2 * x ^ 2 := by ring
      _ ≤ x ^ 2 * (1/4) := mul_le_mul_of_nonneg_left hxsq (sq_nonneg x)
  rw [orInfo_subgroupProfile K, ← hx]
  nlinarith [hlow, hxB, hlog2, hx4, hxpos, h2gt]

/-- **The residue-channel collapse.**  For a class-group character of any order `d ≥ 2`:
fixed multipliers give a strictly positive dial, a multiplier group generating all residue
classes gives exactly `0`, and the mean rate `1/d` is the same in both cases. -/
theorem residue_channel_collapse (K H : Subgroup G) (hd : 2 ≤ K.index) (hHK : H ⊔ K = ⊤) :
    0 < orInfo (subgroupProfile K) ∧
      orInfo (mix H (subgroupProfile K)) = 0 ∧
      avg (mix H (subgroupProfile K)) = avg (subgroupProfile K) ∧
      avg (subgroupProfile K) = 1 / (K.index : ℝ) :=
  ⟨orInfo_subgroupProfile_pos K hd, orInfo_mix_subgroupProfile_of_sup_eq_top K H hHK,
    avg_mix H (subgroupProfile K), avg_subgroupProfile K⟩

end ResidueWashout

end ORDial