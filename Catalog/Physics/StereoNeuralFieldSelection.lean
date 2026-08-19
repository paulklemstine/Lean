import Mathlib
import Physics.StereoNeuralFieldCalculus
import Physics.StereoNeuralFieldHarmonics

/-!
# Stereographic neural fields III: Mexican-hat mode selection and the `2N+1` pattern count

The linearised neural-field equation on `S²` with a rotation-invariant ("Mexican-hat")
connectivity kernel acts diagonally on spherical harmonics: by the Funk–Hecke theorem the
kernel multiplies every degree-`l` harmonic by a number `λ_l` that depends only on `l` and
on the interaction radius `r`.  A difference-of-Gaussians kernel of radius `r` has a
band-pass profile whose gain, normalised to peak value `1`, is

`mexicanHatMultiplier r l = (l r)² exp(1 - (l r)²)`.

This file proves, with no calculus and no numerical evaluation:

* `mexicanHatGain_lt_one` — the profile is `< 1` away from its peak (a sharp exponential
  inequality obtained from `x + 1 < eˣ`);
* `mexicanHatGain_lt_of_lt_one`, `mexicanHatGain_lt_of_one_le` — strict unimodality;
* `mexicanHatMultiplier_argmax` — for every radius `r > 0` the maximising degree over `ℕ`
  is `⌊1/r⌋` or `⌈1/r⌉`;
* `mexicanHat_selects` — for the resonant radii `r = 1/k` the maximiser is *exactly*
  `k = ⌊1/r⌋`, and it is a strict maximiser.

Combining this with the explicit harmonics of `Physics.StereoNeuralFieldHarmonics` gives
the conjectured picture for `k = 1, 2, 3`: the selected degree is `N = ⌊1/r⌋` and the
selected eigenspace contains `2N+1` linearly independent stereographically projected
patterns (`stereographic_pattern_theorem_one/two/three`).

**Adversarial correction to the conjecture.**  The conjecture also claims that all `2N+1`
patterns decay at infinity in the plane.  That is false: `degree_one_north_pole_obstruction`
shows the zonal mode tends to `1`, and `degree_one_decay_iff` isolates the exact boundary —
a degree-one pattern decays along every ray if and only if its north-pole value vanishes.
The decaying part of the degree-`N` pattern space therefore has dimension `2N`, not `2N+1`.
-/

namespace StereoNeuralField

noncomputable section

open NExpr Filter

/-! ## The Mexican-hat spectral gain -/

/-- Normalised band-pass gain profile `s ↦ s e^{1-s}`, evaluated at `s = (l r)²`. -/
def mexicanHatGain (s : ℝ) : ℝ := s * Real.exp (1 - s)

/-- Funk–Hecke multiplier of a Mexican-hat kernel of interaction radius `r` acting on the
degree-`l` spherical-harmonic eigenspace. -/
def mexicanHatMultiplier (r : ℝ) (l : ℕ) : ℝ := mexicanHatGain (((l : ℝ) * r) ^ 2)

@[simp] theorem mexicanHatGain_one : mexicanHatGain 1 = 1 := by
  simp [mexicanHatGain]

/-- **Sharp peak bound.**  The gain is strictly below its peak value away from resonance. -/
theorem mexicanHatGain_lt_one {s : ℝ} (hs : s ≠ 1) : mexicanHatGain s < 1 := by
  have hne : s - 1 ≠ 0 := sub_ne_zero.mpr hs
  have h : (s - 1) + 1 < Real.exp (s - 1) := Real.add_one_lt_exp hne
  have hpos : 0 < Real.exp (1 - s) := Real.exp_pos _
  have hmul : Real.exp (s - 1) * Real.exp (1 - s) = 1 := by
    rw [← Real.exp_add]; norm_num
  calc mexicanHatGain s = s * Real.exp (1 - s) := rfl
    _ < Real.exp (s - 1) * Real.exp (1 - s) := by
        apply mul_lt_mul_of_pos_right _ hpos; linarith
    _ = 1 := hmul

/-- **Strict monotonicity below resonance.** -/
theorem mexicanHatGain_lt_of_lt_one {s t : ℝ} (hs : 0 ≤ s) (hst : s < t) (ht : t ≤ 1) :
    mexicanHatGain s < mexicanHatGain t := by
  have ht0 : 0 < t := lt_of_le_of_lt hs hst
  have hne : s - t ≠ 0 := sub_ne_zero.mpr (ne_of_lt hst)
  have h : (s - t) + 1 < Real.exp (s - t) := Real.add_one_lt_exp hne
  have key : s < t * Real.exp (s - t) := by nlinarith
  have hexp : Real.exp (s - t) * Real.exp (1 - s) = Real.exp (1 - t) := by
    rw [← Real.exp_add]; ring_nf
  have hpos : 0 < Real.exp (1 - s) := Real.exp_pos _
  calc mexicanHatGain s = s * Real.exp (1 - s) := rfl
    _ < (t * Real.exp (s - t)) * Real.exp (1 - s) := by
        exact mul_lt_mul_of_pos_right key hpos
    _ = t * Real.exp (1 - t) := by rw [mul_assoc, hexp]
    _ = mexicanHatGain t := rfl

/-- **Strict antitonicity above resonance.** -/
theorem mexicanHatGain_lt_of_one_le {s t : ℝ} (hs : 1 ≤ s) (hst : s < t) :
    mexicanHatGain t < mexicanHatGain s := by
  have hs0 : 0 < s := lt_of_lt_of_le zero_lt_one hs
  have hne : t - s ≠ 0 := sub_ne_zero.mpr (ne_of_gt hst)
  have h : (t - s) + 1 < Real.exp (t - s) := Real.add_one_lt_exp hne
  have key : t < s * Real.exp (t - s) := by nlinarith
  have hexp : Real.exp (t - s) * Real.exp (1 - t) = Real.exp (1 - s) := by
    rw [← Real.exp_add]; ring_nf
  have hpos : 0 < Real.exp (1 - t) := Real.exp_pos _
  calc mexicanHatGain t = t * Real.exp (1 - t) := rfl
    _ < (s * Real.exp (t - s)) * Real.exp (1 - t) := mul_lt_mul_of_pos_right key hpos
    _ = s * Real.exp (1 - s) := by rw [mul_assoc, hexp]
    _ = mexicanHatGain s := rfl

theorem mexicanHatGain_le_of_le_one {s t : ℝ} (hs : 0 ≤ s) (hst : s ≤ t) (ht : t ≤ 1) :
    mexicanHatGain s ≤ mexicanHatGain t := by
  rcases eq_or_lt_of_le hst with h | h
  · rw [h]
  · exact le_of_lt (mexicanHatGain_lt_of_lt_one hs h ht)

theorem mexicanHatGain_le_of_one_le {s t : ℝ} (hs : 1 ≤ s) (hst : s ≤ t) :
    mexicanHatGain t ≤ mexicanHatGain s := by
  rcases eq_or_lt_of_le hst with h | h
  · rw [h]
  · exact le_of_lt (mexicanHatGain_lt_of_one_le hs h)

/-! ## Mode selection -/

/-- The degree `k` is the strict spectral maximiser at interaction radius `r`. -/
def SelectedDegree (r : ℝ) (k : ℕ) : Prop :=
  ∀ l : ℕ, l ≠ k → mexicanHatMultiplier r l < mexicanHatMultiplier r k

/-- At a resonant radius `r = 1/k` the degree-`k` multiplier attains the peak value `1`. -/
theorem mexicanHatMultiplier_reciprocal_self {k : ℕ} (hk : 0 < k) :
    mexicanHatMultiplier (1 / (k : ℝ)) k = 1 := by
  have hk0 : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  have : ((k : ℝ) * (1 / (k : ℝ))) ^ 2 = 1 := by
    field_simp
  rw [mexicanHatMultiplier, this, mexicanHatGain_one]

/-- **Mexican-hat mode selection.**  At the resonant radius `r = 1/k` the degree-`k`
eigenspace is the strict maximiser of the spectral gain among all degrees. -/
theorem mexicanHat_selects {k : ℕ} (hk : 0 < k) : SelectedDegree (1 / (k : ℝ)) k := by
  intro l hl
  have hk0 : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  have hkpos : (0 : ℝ) < (k : ℝ) := by positivity
  have hne : ((l : ℝ) * (1 / (k : ℝ))) ^ 2 ≠ 1 := by
    intro hcon
    have hl0 : (0 : ℝ) ≤ (l : ℝ) * (1 / (k : ℝ)) := by positivity
    have h1 : (l : ℝ) * (1 / (k : ℝ)) = 1 := by nlinarith
    have : (l : ℝ) = (k : ℝ) := by field_simp at h1; linarith
    exact hl (Nat.cast_injective this)
  rw [mexicanHatMultiplier_reciprocal_self hk, mexicanHatMultiplier]
  exact mexicanHatGain_lt_one hne

/-- The selected degree at a resonant radius is `⌊1/r⌋`. -/
theorem floor_reciprocal_resonant {k : ℕ} (hk : 0 < k) :
    ⌊1 / (1 / (k : ℝ))⌋₊ = k := by
  have hk0 : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  rw [one_div_one_div]
  exact Nat.floor_natCast k

/-! ## Unimodality of the multiplier for a general radius -/

theorem mexicanHatMultiplier_le_below {r : ℝ} (hr : 0 < r) {l m : ℕ} (hlm : l ≤ m)
    (hm : (m : ℝ) * r ≤ 1) : mexicanHatMultiplier r l ≤ mexicanHatMultiplier r m := by
  have hl : (0 : ℝ) ≤ (l : ℝ) * r := by positivity
  have hml : (l : ℝ) * r ≤ (m : ℝ) * r :=
    mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hlm) hr.le
  have hsq : ((l : ℝ) * r) ^ 2 ≤ ((m : ℝ) * r) ^ 2 := by nlinarith
  have hone : ((m : ℝ) * r) ^ 2 ≤ 1 := by nlinarith
  exact mexicanHatGain_le_of_le_one (by positivity) hsq hone

theorem mexicanHatMultiplier_le_above {r : ℝ} (hr : 0 < r) {l m : ℕ} (hml : m ≤ l)
    (hm : 1 ≤ (m : ℝ) * r) : mexicanHatMultiplier r l ≤ mexicanHatMultiplier r m := by
  have hlm : (m : ℝ) * r ≤ (l : ℝ) * r :=
    mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hml) hr.le
  have hsq : ((m : ℝ) * r) ^ 2 ≤ ((l : ℝ) * r) ^ 2 := by nlinarith
  have hone : (1 : ℝ) ≤ ((m : ℝ) * r) ^ 2 := by nlinarith
  exact mexicanHatGain_le_of_one_le hone hsq

/-- **Unimodality / localisation of the argmax.**  For every interaction radius the
maximising degree is one of the two integers bracketing `1/r`. -/
theorem mexicanHatMultiplier_argmax {r : ℝ} (hr : 0 < r) (l : ℕ) :
    mexicanHatMultiplier r l
      ≤ max (mexicanHatMultiplier r ⌊1 / r⌋₊) (mexicanHatMultiplier r ⌈1 / r⌉₊) := by
  rcases le_or_gt l ⌊1 / r⌋₊ with h | h
  · have hfl : (⌊1 / r⌋₊ : ℝ) ≤ 1 / r := Nat.floor_le (by positivity)
    have hm : (⌊1 / r⌋₊ : ℝ) * r ≤ 1 := by
      have h2 : (1 / r) * r = 1 := by field_simp
      have h3 := mul_le_mul_of_nonneg_right hfl hr.le
      linarith
    exact le_trans (mexicanHatMultiplier_le_below hr h hm) (le_max_left _ _)
  · have hcl : ⌈1 / r⌉₊ ≤ l := by
      have := Nat.ceil_le_floor_add_one (1 / r)
      omega
    have hge : 1 / r ≤ (⌈1 / r⌉₊ : ℝ) := Nat.le_ceil _
    have hm : (1 : ℝ) ≤ (⌈1 / r⌉₊ : ℝ) * r := by
      have h2 : (1 / r) * r = 1 := by field_simp
      have h3 := mul_le_mul_of_nonneg_right hge hr.le
      linarith
    exact le_trans (mexicanHatMultiplier_le_above hr hcl hm) (le_max_right _ _)

/-! ## Decay at infinity: the north-pole obstruction -/

/-- Value of a general degree-one pattern along the ray of unit direction `(u,v)`. -/
theorem degree_one_ray_value (a b c u v R : ℝ) (huv : u ^ 2 + v ^ 2 = 1) :
    a * evalAt chartX (R * u) (R * v) + b * evalAt chartY (R * u) (R * v)
        + c * evalAt chartZ (R * u) (R * v)
      = c + (2 * a * u * R + 2 * b * v * R - 2 * c) / (1 + R ^ 2) := by
  have hden : 1 + (R * u) ^ 2 + (R * v) ^ 2 = 1 + R ^ 2 := by nlinarith [huv]
  have hpos : (1 : ℝ) + R ^ 2 ≠ 0 := by positivity
  simp only [evalAt_chartX, evalAt_chartY, evalAt_chartZ, W, hden]
  field_simp
  linear_combination (c * R ^ 2) * huv

/-- **Quantitative decay estimate.**  Along every ray, a degree-one pattern converges to
its north-pole value `c` at rate `1/R`. -/
theorem degree_one_decay_estimate (a b c u v R : ℝ) (huv : u ^ 2 + v ^ 2 = 1) (hR : 1 ≤ R) :
    |a * evalAt chartX (R * u) (R * v) + b * evalAt chartY (R * u) (R * v)
        + c * evalAt chartZ (R * u) (R * v) - c|
      ≤ (2 * |a| + 2 * |b| + 2 * |c|) / R := by
  have hR0 : 0 < R := lt_of_lt_of_le zero_lt_one hR
  have hu : |u| ≤ 1 := by
    have : u ^ 2 ≤ 1 := by nlinarith [sq_nonneg v]
    exact abs_le_one_iff_mul_self_le_one.mpr (by nlinarith [sq_abs u])
  have hv : |v| ≤ 1 := by
    have : v ^ 2 ≤ 1 := by nlinarith [sq_nonneg u]
    exact abs_le_one_iff_mul_self_le_one.mpr (by nlinarith [sq_abs v])
  rw [degree_one_ray_value a b c u v R huv]
  have hsimp : c + (2 * a * u * R + 2 * b * v * R - 2 * c) / (1 + R ^ 2) - c
      = (2 * a * u * R + 2 * b * v * R - 2 * c) / (1 + R ^ 2) := by ring
  rw [hsimp, abs_div, abs_of_pos (show (0:ℝ) < 1 + R ^ 2 by positivity)]
  have hnum : |2 * a * u * R + 2 * b * v * R - 2 * c| ≤ (2 * |a| + 2 * |b| + 2 * |c|) * R := by
    have h1 : |2 * a * u * R| ≤ 2 * |a| * R := by
      rw [abs_mul, abs_mul, abs_mul, abs_of_pos hR0]
      have : |(2 : ℝ)| = 2 := by norm_num
      rw [this]
      have := mul_le_mul_of_nonneg_left hu (by positivity : (0:ℝ) ≤ 2 * |a|)
      nlinarith [abs_nonneg a, hR0.le]
    have h2 : |2 * b * v * R| ≤ 2 * |b| * R := by
      rw [abs_mul, abs_mul, abs_mul, abs_of_pos hR0]
      have : |(2 : ℝ)| = 2 := by norm_num
      rw [this]
      have := mul_le_mul_of_nonneg_left hv (by positivity : (0:ℝ) ≤ 2 * |b|)
      nlinarith [abs_nonneg b, hR0.le]
    have h3 : |2 * c| = 2 * |c| := by
      rw [abs_mul]; norm_num
    have h4 : |2 * a * u * R + 2 * b * v * R - 2 * c|
        ≤ |2 * a * u * R| + |2 * b * v * R| + |2 * c| := by
      have h := abs_add_three (2 * a * u * R) (2 * b * v * R) (-(2 * c))
      simpa [sub_eq_add_neg, abs_neg] using h
    nlinarith [abs_nonneg c]
  rw [div_le_div_iff₀ (by positivity) hR0]
  nlinarith [abs_nonneg a, abs_nonneg b, abs_nonneg c, sq_nonneg (R - 1)]

/-- Along every ray, a degree-one pattern converges to its north-pole coefficient `c`. -/
theorem degree_one_ray_limit (a b c u v : ℝ) (huv : u ^ 2 + v ^ 2 = 1) :
    Tendsto (fun R : ℝ => a * evalAt chartX (R * u) (R * v)
      + b * evalAt chartY (R * u) (R * v) + c * evalAt chartZ (R * u) (R * v)) atTop (nhds c) := by
  have hsq : Tendsto (fun R : ℝ =>
      |a * evalAt chartX (R * u) (R * v) + b * evalAt chartY (R * u) (R * v)
        + c * evalAt chartZ (R * u) (R * v) - c|) atTop (nhds 0) := by
    refine squeeze_zero' (g := fun R : ℝ => (2 * |a| + 2 * |b| + 2 * |c|) / R)
      (Eventually.of_forall fun R => abs_nonneg _) ?_ ?_
    · filter_upwards [eventually_ge_atTop (1 : ℝ)] with R hR
      exact degree_one_decay_estimate a b c u v R huv hR
    · exact Tendsto.const_div_atTop tendsto_id _
  have := (tendsto_zero_iff_abs_tendsto_zero _).mpr hsq
  simpa using this.add_const c

/-- **North-pole obstruction.**  The zonal degree-one pattern does *not* decay at infinity:
along the horizontal ray it converges to the north-pole value `1`. -/
theorem degree_one_north_pole_obstruction :
    Tendsto (fun R : ℝ => evalAt chartZ R 0) atTop (nhds 1) := by
  have h := degree_one_ray_limit 0 0 1 1 0 (by norm_num)
  simpa using h

/-- **Exact decay boundary for degree one.**  A degree-one stereographic pattern decays
along every ray if and only if its north-pole coefficient vanishes.  Hence exactly a
`2`-dimensional subspace of the `3`-dimensional degree-one pattern space decays. -/
theorem degree_one_decay_iff (a b c : ℝ) :
    (∀ u v : ℝ, u ^ 2 + v ^ 2 = 1 →
        Tendsto (fun R : ℝ => a * evalAt chartX (R * u) (R * v)
          + b * evalAt chartY (R * u) (R * v) + c * evalAt chartZ (R * u) (R * v))
          atTop (nhds 0))
      ↔ c = 0 := by
  constructor
  · intro h
    have h1 := h 1 0 (by norm_num)
    have h2 := degree_one_ray_limit a b c 1 0 (by norm_num)
    exact tendsto_nhds_unique h2 h1
  · intro hc u v huv
    subst hc
    exact degree_one_ray_limit a b 0 u v huv

/-! ## The `2N+1` pattern count at the resonant radii `r = 1/k`, `k = 1,2,3` -/

/-- Degree-one pattern basis (dipolar patterns). -/
def deg1Basis : List NExpr := [chartX, chartY, chartZ]
/-- Degree-two pattern basis (quadrupolar patterns). -/
def deg2Basis : List NExpr := [H2xy, H2xz, H2yz, H2x2y2, H2z2]
/-- Degree-three pattern basis (octupolar patterns). -/
def deg3Basis : List NExpr := [H3a, H3b, H3c, H3d, H3e, H3f, H3g]

theorem deg1Basis_card : deg1Basis.length = 2 * 1 + 1 := by decide
theorem deg2Basis_card : deg2Basis.length = 2 * 2 + 1 := by decide
theorem deg3Basis_card : deg3Basis.length = 2 * 3 + 1 := by decide

theorem deg1Basis_eigen : ∀ u ∈ deg1Basis, LapBeltrami u 1 := by
  intro u hu
  simp only [deg1Basis, List.mem_cons, List.not_mem_nil, or_false] at hu
  rcases hu with h | h | h <;> subst h
  · exact chartX_deg1
  · exact chartY_deg1
  · exact chartZ_deg1

theorem deg2Basis_eigen : ∀ u ∈ deg2Basis, LapBeltrami u 2 := by
  intro u hu
  simp only [deg2Basis, List.mem_cons, List.not_mem_nil, or_false] at hu
  rcases hu with h | h | h | h | h <;> subst h
  · exact H2xy_deg2
  · exact H2xz_deg2
  · exact H2yz_deg2
  · exact H2x2y2_deg2
  · exact H2z2_deg2

theorem deg3Basis_eigen : ∀ u ∈ deg3Basis, LapBeltrami u 3 := by
  intro u hu
  simp only [deg3Basis, List.mem_cons, List.not_mem_nil, or_false] at hu
  rcases hu with h | h | h | h | h | h | h <;> subst h
  · exact H3a_deg3
  · exact H3b_deg3
  · exact H3c_deg3
  · exact H3d_deg3
  · exact H3e_deg3
  · exact H3f_deg3
  · exact H3g_deg3

/-- **Main theorem, `r = 1`.**  The Mexican-hat kernel of radius `r = 1` strictly selects
degree `N = ⌊1/r⌋ = 1`, and the selected eigenspace contains exactly `2N+1 = 3` linearly
independent stereographically projected patterns. -/
theorem stereographic_pattern_theorem_one :
    SelectedDegree (1 / (1 : ℝ)) 1 ∧ ⌊1 / (1 / (1 : ℝ))⌋₊ = 1 ∧
      deg1Basis.length = 2 * 1 + 1 ∧ (∀ u ∈ deg1Basis, LapBeltrami u 1) ∧
      (∀ a b c : ℝ, (∀ x y, a * evalAt chartX x y + b * evalAt chartY x y
        + c * evalAt chartZ x y = 0) → a = 0 ∧ b = 0 ∧ c = 0) := by
  refine ⟨?_, ?_, deg1Basis_card, deg1Basis_eigen, degree_one_independent⟩
  · simpa using mexicanHat_selects (k := 1) (by norm_num)
  · norm_num

/-- **Main theorem, `r = 1/2`.**  The selected degree is `N = 2` and the selected
eigenspace contains exactly `2N+1 = 5` independent projected patterns. -/
theorem stereographic_pattern_theorem_two :
    SelectedDegree (1 / (2 : ℝ)) 2 ∧ ⌊1 / (1 / (2 : ℝ))⌋₊ = 2 ∧
      deg2Basis.length = 2 * 2 + 1 ∧ (∀ u ∈ deg2Basis, LapBeltrami u 2) ∧
      (∀ a b c d e : ℝ, (∀ x y, a * evalAt H2xy x y + b * evalAt H2xz x y
        + c * evalAt H2yz x y + d * evalAt H2x2y2 x y + e * evalAt H2z2 x y = 0) →
          a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 ∧ e = 0) := by
  refine ⟨?_, ?_, deg2Basis_card, deg2Basis_eigen, degree_two_independent⟩
  · simpa using mexicanHat_selects (k := 2) (by norm_num)
  · norm_num

/-- **Main theorem, `r = 1/3`.**  The selected degree is `N = 3` and the selected
eigenspace contains exactly `2N+1 = 7` independent projected patterns, among them the
three-fold symmetric modes `x(x²-3y²)` and `y(3x²-y²)`. -/
theorem stereographic_pattern_theorem_three :
    SelectedDegree (1 / (3 : ℝ)) 3 ∧ ⌊1 / (1 / (3 : ℝ))⌋₊ = 3 ∧
      deg3Basis.length = 2 * 3 + 1 ∧ (∀ u ∈ deg3Basis, LapBeltrami u 3) ∧
      (∀ c1 c2 c3 c4 c5 c6 c7 : ℝ, (∀ x y, c1 * evalAt H3a x y + c2 * evalAt H3b x y
        + c3 * evalAt H3c x y + c4 * evalAt H3d x y + c5 * evalAt H3e x y
        + c6 * evalAt H3f x y + c7 * evalAt H3g x y = 0) →
          c1 = 0 ∧ c2 = 0 ∧ c3 = 0 ∧ c4 = 0 ∧ c5 = 0 ∧ c6 = 0 ∧ c7 = 0) := by
  refine ⟨?_, ?_, deg3Basis_card, deg3Basis_eigen, degree_three_independent⟩
  · simpa using mexicanHat_selects (k := 3) (by norm_num)
  · norm_num

/-! ## The representation-theoretic count -/

/-- Dimension of the space of degree-`l` spherical harmonics on `S²`, as the difference of
the dimensions of the degree-`l` and degree-`(l-2)` homogeneous polynomial spaces in three
variables. -/
theorem spherical_harmonic_dimension (l : ℕ) :
    Nat.choose (l + 2) 2 - Nat.choose l 2 = 2 * l + 1 := by
  induction l with
  | zero => decide
  | succ m ih =>
      have h1 : (m + 3).choose 2 = (m + 2).choose 2 + (m + 2) := by
        simp [Nat.choose_succ_succ (m + 2) 1, Nat.choose_one_right, Nat.add_comm]
      have h2 : (m + 1).choose 2 = m.choose 2 + m := by
        simp [Nat.choose_succ_succ m 1, Nat.choose_one_right, Nat.add_comm]
      have hle : Nat.choose m 2 ≤ Nat.choose (m + 2) 2 := Nat.choose_le_choose 2 (by omega)
      have h3 : m + 1 + 2 = m + 3 := by omega
      rw [h3, h1, h2]
      omega

end

end StereoNeuralField