/-
# TRACE-BATTERY, part III: the which-factor wall is an imbalance meter

The round-30 experiment reports a *which-factor wall* at `0.4677` bits: the
binary "which factor?" statistic never carries more than that, a value the paper
attributes to sparse-table bias.  This file explains what such a number can and
cannot mean.

A binary statistic on a finite population is completely described, as far as
capacity is concerned, by the fraction `p` of the population in its smaller
class:

* `TraceBattery.H_two_values` — for a statistic attaining exactly the two
  readings `a ≠ b`, the empirical entropy equals Mathlib's binary entropy
  `Real.binEntropy` of the fraction of the `a`-class.  So the wall value is a
  *measurement of class imbalance*, nothing else.
* `TraceBattery.binary_capacity_lt_of_lt` — on the balanced side `[0, 1/2]` the
  capacity is strictly increasing in the minority fraction.
* `TraceBattery.wall_determines_imbalance` — hence a reported wall value pins
  the imbalance down uniquely: two binary statistics with equal capacity and
  minority fractions in `[0, 1/2]` have the *same* fraction.
* `TraceBattery.binary_capacity_le_one_bit` — and the wall can never exceed one
  bit, so any reported value below `1` is admissible; only the *inverted*
  fraction carries information.

All statements are sorry-free.
-/
import Mathlib
import Combinatorics.TraceBatteryEntropy

namespace TraceBattery

open Finset

section Binary

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {α : Type*}

open Classical in
/-- A statistic attaining exactly two readings has empirical entropy equal to
the binary entropy of the fraction sitting in the first class. -/
theorem H_two_values (f : Ω → α) {a b : α} (hab : a ≠ b) (himg : img f = {a, b}) :
    H f = Real.binEntropy ((cnt f a : ℝ) / (Fintype.card Ω : ℝ)) := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hamem : a ∈ img f := by rw [himg]; exact Finset.mem_insert_self a {b}
  have hbmem : b ∈ img f := by
    rw [himg]; exact Finset.mem_insert_of_mem (Finset.mem_singleton_self b)
  have hapos : (0 : ℝ) < cnt f a := by exact_mod_cast cnt_pos_of_mem_img hamem
  have hbpos : (0 : ℝ) < cnt f b := by exact_mod_cast cnt_pos_of_mem_img hbmem
  have hsum : (cnt f a : ℝ) + cnt f b = (Fintype.card Ω : ℝ) := by
    have h := sum_cnt f
    rw [himg, Finset.sum_pair hab] at h
    exact_mod_cast h
  have hHf : H f = ((cnt f a : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt f a)
      + ((cnt f b : ℝ) / (Fintype.card Ω : ℝ))
        * Real.log ((Fintype.card Ω : ℝ) / cnt f b) := by
    rw [H, himg, Finset.sum_pair hab]
  set p : ℝ := (cnt f a : ℝ) / (Fintype.card Ω : ℝ) with hp
  have hp0 : 0 < p := by rw [hp]; positivity
  have h1p : 1 - p = (cnt f b : ℝ) / (Fintype.card Ω : ℝ) := by
    rw [hp]; field_simp; linarith [hsum]
  have hinvp : p⁻¹ = (Fintype.card Ω : ℝ) / cnt f a := by
    rw [hp, inv_div]
  have hinvq : (1 - p)⁻¹ = (Fintype.card Ω : ℝ) / cnt f b := by
    rw [h1p, inv_div]
  rw [hHf, Real.binEntropy, hinvp, ← h1p, hinvq, h1p]

/-- Two-valued statistics carry at most one bit. -/
theorem binary_capacity_le_one_bit (f : Ω → α) (hcard : (img f).card ≤ 2) : Hb f ≤ 1 := by
  classical
  have hpos : (0 : ℝ) < ((img f).card : ℝ) := by
    have : (img f).Nonempty := ⟨f (Classical.arbitrary Ω), self_mem_img _ _⟩
    exact_mod_cast Finset.card_pos.2 this
  have hle : ((img f).card : ℝ) ≤ 2 := by exact_mod_cast hcard
  have h := (Hb_le_logb_card_img f).trans (Real.logb_le_logb_of_le (by norm_num) hpos hle)
  simpa using h

end Binary

section Wall

/-- **Strict monotonicity of the wall in the imbalance.**  On the balanced side
`[0, 1/2]`, a larger minority fraction means strictly more capacity. -/
theorem binary_capacity_lt_of_lt {p q : ℝ} (hp : p ∈ Set.Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Set.Icc (0 : ℝ) 2⁻¹) (hpq : p < q) :
    Real.binEntropy p < Real.binEntropy q :=
  Real.binEntropy_strictMonoOn hp hq hpq

/-- **The wall value is an imbalance meter.**  A measured binary capacity
determines the class imbalance uniquely (on the balanced side): there is no
freedom left once the wall value is reported. -/
theorem wall_determines_imbalance {p q : ℝ} (hp : p ∈ Set.Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Set.Icc (0 : ℝ) 2⁻¹) (h : Real.binEntropy p = Real.binEntropy q) : p = q :=
  Real.binEntropy_strictMonoOn.injOn hp hq h

variable {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Nonempty Ω₁] [Fintype Ω₂] [Nonempty Ω₂]
  {α₁ α₂ : Type*}

open Classical in
/-- **Wall inversion for statistics.**  Two binary statistics — possibly on
different populations — with the same capacity and with minority fractions in
`[0, 1/2]` have exactly the same class imbalance.  Hence the round-30 wall
`0.4677` bits is a faithful report of one number: the imbalance of the
which-factor split. -/
theorem binary_wall_inversion (f : Ω₁ → α₁) (g : Ω₂ → α₂) {a b : α₁} {c e : α₂}
    (hab : a ≠ b) (hce : c ≠ e) (hf : img f = {a, b}) (hg : img g = {c, e})
    (hpf : (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) ∈ Set.Icc (0 : ℝ) 2⁻¹)
    (hpg : (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) ∈ Set.Icc (0 : ℝ) 2⁻¹)
    (hcap : H f = H g) :
    (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) = (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) := by
  have h1 := H_two_values f hab hf
  have h2 := H_two_values g hce hg
  exact wall_determines_imbalance hpf hpg (by rw [← h1, ← h2, hcap])

end Wall

end TraceBattery