import Cryptography.ResidueDial.Core

/-!
# Paper 137 — the positional speedup law and where it crosses the residue cap

`SqrtDescending.lean` gives the exact costs `p - 1` (ascending) and `⌊√N⌋ + 1 - p`
(sqrt-descending) of trial division on `N = p q`.  Dropping the floor, with balance ratio
`r = q / p`, the descending cost is `p (√r - 1)` and the per-instance positional speedup is

  `posSpeedup r = 1 / (√r - 1)`.

This file proves the shape of this law and lines it up against the residue cap `4/3` of
`Cryptography.ResidueDial.Core`.

## Main results

* `posSpeedup_eq_ratio` — the law, from the continuous costs `p` and `√(pq) - p`.
* `lt_posSpeedup_iff` — `k < posSpeedup r ↔ r < (1 + 1/k)²`: the stratum on which position
  pays more than `k` is an explicit balance window.
* `posSpeedup_strictAntiOn` — the gain decays monotonically with imbalance (mechanism (a)'s
  gradient: concentrated at near-squares).
* `posSpeedup_unbounded` — and it is unbounded at the near-square edge `r → 1⁺`.
* `position_beats_every_residue_dial` — **the barrier map**: on `1 < r < 49/16` the
  positional speedup strictly exceeds the speedup of *every* residue dial, whatever its
  modulus and filter; `residue_cap_reached_at_wall` — at `r = 49/16` it equals `4/3` exactly,
  and beyond it never exceeds `4/3`.
* `stratum_near_square`, `stratum_middle`, `stratum_wide` — exact pointwise bands on the
  three experimental strata `q/p ∈ (1, 5/4]`, `[5/4, 2]`, `[2, 4]`:
  `[4 + 2√5, ∞)`, `[1 + √2, 4 + 2√5]`, `[1, 1 + √2]`.
* `ratio_of_sums_mem` — the mediant principle: a ratio of *expected* costs over any finite
  sample lies in the band of its pointwise ratios; `stratum_ratio_band` applies it, and
  `exp467_mechanism_a_consistent` checks that the three measured stratum speedups
  `20.67 / 4.74 / 1.97` of mechanism (a) fall inside the proved bands.
-/

namespace PositionalFilter

open Real

/-- The per-instance positional (sqrt-descending vs ascending) speedup at balance `r`. -/
noncomputable def posSpeedup (r : ℝ) : ℝ := 1 / (√r - 1)

theorem one_lt_sqrt_of_one_lt {r : ℝ} (hr : 1 < r) : 1 < √r := by
  rw [show (1 : ℝ) = √1 by simp]
  exact Real.sqrt_lt_sqrt zero_le_one hr

theorem posSpeedup_pos {r : ℝ} (hr : 1 < r) : 0 < posSpeedup r := by
  have := one_lt_sqrt_of_one_lt hr
  unfold posSpeedup
  apply div_pos one_pos; linarith

/-- **The law.** With continuous costs `p` (ascending) and `√(p q) - p` (descending), the
speedup depends on the balance `q/p` alone. -/
theorem posSpeedup_eq_ratio {p q : ℝ} (hp : 0 < p) (hpq : p < q) :
    p / (√(p * q) - p) = posSpeedup (q / p) := by
  have hr : 1 < q / p := (one_lt_div hp).mpr hpq
  have hs := one_lt_sqrt_of_one_lt hr
  have hsq : √(p * q) = p * √(q / p) := by
    rw [show p * q = p ^ 2 * (q / p) by field_simp, Real.sqrt_mul (by positivity),
      Real.sqrt_sq hp.le]
  rw [hsq, posSpeedup]
  have : p * √(q / p) - p = p * (√(q / p) - 1) := by ring
  rw [this]
  have hne : √(q / p) - 1 ≠ 0 := by linarith
  field_simp

/-- **Balance windows.** Position pays more than `k` exactly on `1 < r < (1 + 1/k)²`. -/
theorem lt_posSpeedup_iff {r k : ℝ} (hr : 1 < r) (hk : 0 < k) :
    k < posSpeedup r ↔ r < (1 + 1 / k) ^ 2 := by
  have hs := one_lt_sqrt_of_one_lt hr
  have hpos : 0 < √r - 1 := by linarith
  rw [posSpeedup, lt_div_iff₀ hpos, ← Real.sqrt_lt' (by positivity)]
  constructor
  · intro h
    have : k * √r < k * (1 + 1 / k) := by
      rw [mul_add, mul_one_div_cancel hk.ne']; linarith
    exact lt_of_mul_lt_mul_left this hk.le
  · intro h
    have := mul_lt_mul_of_pos_left h hk
    rw [mul_add, mul_one_div_cancel hk.ne'] at this
    linarith

/-- The same window in non-strict form. -/
theorem le_posSpeedup_iff {r k : ℝ} (hr : 1 < r) (hk : 0 < k) :
    k ≤ posSpeedup r ↔ r ≤ (1 + 1 / k) ^ 2 := by
  have hs := one_lt_sqrt_of_one_lt hr
  have hpos : 0 < √r - 1 := by linarith
  rw [posSpeedup, le_div_iff₀ hpos, ← Real.sqrt_le_left (by positivity)]
  constructor
  · intro h
    have : k * √r ≤ k * (1 + 1 / k) := by
      rw [mul_add, mul_one_div_cancel hk.ne']; linarith
    exact le_of_mul_le_mul_left this hk
  · intro h
    have := mul_le_mul_of_nonneg_left h hk.le
    rw [mul_add, mul_one_div_cancel hk.ne'] at this
    linarith

/-- The gain decays strictly with imbalance. -/
theorem posSpeedup_strictAntiOn : StrictAntiOn posSpeedup (Set.Ioi 1) := by
  intro a ha b hb hab
  have hsa := one_lt_sqrt_of_one_lt (Set.mem_Ioi.mp ha)
  have hsb := one_lt_sqrt_of_one_lt (Set.mem_Ioi.mp hb)
  have hlt : √a < √b := Real.sqrt_lt_sqrt (by linarith [Set.mem_Ioi.mp ha]) hab
  unfold posSpeedup
  exact one_div_lt_one_div_of_lt (by linarith) (by linarith)

/-- At the near-square edge the positional gain is unbounded. -/
theorem posSpeedup_unbounded (k : ℝ) : ∃ r, 1 < r ∧ k < posSpeedup r := by
  set m := max k 1 with hm
  have hmpos : 0 < m := lt_of_lt_of_le one_pos (le_max_right _ _)
  refine ⟨(1 + 1 / (2 * m)) ^ 2, ?_, ?_⟩
  · have : 0 < 1 / (2 * m) := by positivity
    nlinarith
  · have hr : 1 < (1 + 1 / (2 * m)) ^ 2 := by
      have : 0 < 1 / (2 * m) := by positivity
      nlinarith
    have h2 : (2 * m) ≤ posSpeedup ((1 + 1 / (2 * m)) ^ 2) :=
      (le_posSpeedup_iff hr (by positivity)).mpr le_rfl
    have : k ≤ m := le_max_left _ _
    linarith

/-- **The barrier map.** On the balance window `1 < r < 49/16` the positional speedup
strictly exceeds the speedup of every residue dial, for every modulus and filter: the
residue cap `4/3` (a theorem about congruence information under a uniform marginal) is not a
cap on positional information. -/
theorem position_beats_every_residue_dial {r : ℝ} (hr : 1 < r) (h : r < 49 / 16)
    (M : ℕ) [NeZero M] (K : Finset (ZMod M)ˣ) :
    ResidueDial.speedup (ResidueDial.density M K) < posSpeedup r := by
  have hk : (4 / 3 : ℝ) < posSpeedup r := by
    rw [lt_posSpeedup_iff hr (by norm_num)]; norm_num; linarith
  exact lt_of_le_of_lt (ResidueDial.dialSpeedup_le_four_thirds M K) hk

/-- **The wall.** At `r = 49/16` the positional speedup is exactly the residue cap `4/3`,
and beyond it position never beats `4/3`. -/
theorem residue_cap_reached_at_wall :
    posSpeedup (49 / 16) = 4 / 3 ∧ ∀ r, 49 / 16 ≤ r → posSpeedup r ≤ 4 / 3 := by
  have h7 : √(49 / 16 : ℝ) = 7 / 4 := by
    rw [show (49 / 16 : ℝ) = (7 / 4) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  have e : posSpeedup (49 / 16) = 4 / 3 := by rw [posSpeedup, h7]; norm_num
  refine ⟨e, fun r hr => ?_⟩
  rcases eq_or_lt_of_le hr with h | h
  · rw [← h, e]
  · have := posSpeedup_strictAntiOn (show (49/16 : ℝ) ∈ Set.Ioi 1 by norm_num)
      (show r ∈ Set.Ioi 1 by simp; linarith) h
    rw [e] at this
    exact this.le

/-! ## The three experimental strata -/

theorem posSpeedup_five_quarters : posSpeedup (5 / 4) = 4 + 2 * √5 := by
  have h : √(5 / 4 : ℝ) = √5 / 2 := by
    rw [Real.sqrt_div' _ (by norm_num : (0:ℝ) ≤ 4), show (4:ℝ) = 2 ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num)]
  have h5 : √5 * √5 = (5 : ℝ) := Real.mul_self_sqrt (by norm_num)
  have hgt : (2 : ℝ) < √5 := by
    rw [show (2:ℝ) = √4 by rw [show (4:ℝ) = 2^2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  rw [posSpeedup, h]
  have hne : √5 / 2 - 1 ≠ 0 := by linarith
  rw [div_eq_iff hne]
  nlinarith

theorem posSpeedup_two : posSpeedup 2 = 1 + √2 := by
  have h2 : √2 * √2 = (2 : ℝ) := Real.mul_self_sqrt (by norm_num)
  have hgt : (1 : ℝ) < √2 := one_lt_sqrt_of_one_lt (by norm_num)
  rw [posSpeedup]
  have hne : √2 - 1 ≠ 0 := by linarith
  rw [div_eq_iff hne]
  nlinarith

theorem posSpeedup_four : posSpeedup 4 = 1 := by
  rw [posSpeedup, show (4:ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]; norm_num

private theorem anti_le {a b : ℝ} (ha : 1 < a) (hab : a ≤ b) : posSpeedup b ≤ posSpeedup a :=
  posSpeedup_strictAntiOn.antitoneOn (Set.mem_Ioi.mpr ha)
    (Set.mem_Ioi.mpr (lt_of_lt_of_le ha hab)) hab

/-- Near-square stratum `q/p ∈ (1, 5/4]`: every instance pays at least `4 + 2√5 ≈ 8.47`. -/
theorem stratum_near_square {r : ℝ} (h1 : 1 < r) (h2 : r ≤ 5 / 4) :
    4 + 2 * √5 ≤ posSpeedup r := by
  rw [← posSpeedup_five_quarters]; exact anti_le h1 h2

/-- Middle stratum `q/p ∈ [5/4, 2]`: between `1 + √2 ≈ 2.41` and `4 + 2√5 ≈ 8.47`. -/
theorem stratum_middle {r : ℝ} (h1 : 5 / 4 ≤ r) (h2 : r ≤ 2) :
    1 + √2 ≤ posSpeedup r ∧ posSpeedup r ≤ 4 + 2 * √5 := by
  rw [← posSpeedup_five_quarters, ← posSpeedup_two]
  exact ⟨anti_le (by linarith) h2, anti_le (by norm_num) h1⟩

/-- Wide stratum `q/p ∈ [2, 4]`: between `1` and `1 + √2 ≈ 2.41`. -/
theorem stratum_wide {r : ℝ} (h1 : 2 ≤ r) (h2 : r ≤ 4) :
    1 ≤ posSpeedup r ∧ posSpeedup r ≤ 1 + √2 := by
  rw [← posSpeedup_two, ← posSpeedup_four]
  exact ⟨anti_le (by linarith) h2, anti_le (by norm_num) h1⟩

/-- **Mediant principle.** If every pointwise ratio `a i / b i` lies in `[L, U]`, so does
the ratio of sums `(∑ a) / (∑ b)` — a ratio of expected costs. -/
theorem ratio_of_sums_mem {ι : Type*} (s : Finset ι) (a b : ι → ℝ) {L U : ℝ}
    (hs : s.Nonempty) (hb : ∀ i ∈ s, 0 < b i)
    (h : ∀ i ∈ s, L * b i ≤ a i ∧ a i ≤ U * b i) :
    L ≤ (∑ i ∈ s, a i) / (∑ i ∈ s, b i) ∧ (∑ i ∈ s, a i) / (∑ i ∈ s, b i) ≤ U := by
  have hB : 0 < ∑ i ∈ s, b i := Finset.sum_pos hb hs
  rw [le_div_iff₀ hB, div_le_iff₀ hB, Finset.mul_sum, Finset.mul_sum]
  exact ⟨Finset.sum_le_sum (fun i hi => (h i hi).1),
    Finset.sum_le_sum (fun i hi => (h i hi).2)⟩

/-- **Stratum band for expected speedups.** For any finite sample of balanced semiprimes
with continuous costs `p i` (ascending) and `√(p i q i) - p i` (descending), whose
balance ratios lie in `[r₁, r₂] ⊆ (1, ∞)`, the ratio of expected costs lies in
`[posSpeedup r₂, posSpeedup r₁]`. -/
theorem stratum_ratio_band {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (p q : ι → ℝ)
    {r₁ r₂ : ℝ} (hr₁ : 1 < r₁) (hp : ∀ i ∈ s, 0 < p i)
    (hlo : ∀ i ∈ s, r₁ * p i ≤ q i) (hhi : ∀ i ∈ s, q i ≤ r₂ * p i) :
    posSpeedup r₂ ≤ (∑ i ∈ s, p i) / (∑ i ∈ s, (√(p i * q i) - p i)) ∧
    (∑ i ∈ s, p i) / (∑ i ∈ s, (√(p i * q i) - p i)) ≤ posSpeedup r₁ := by
  have key : ∀ i ∈ s, 1 < q i / p i ∧ r₁ ≤ q i / p i ∧ q i / p i ≤ r₂ := by
    intro i hi
    have hpi := hp i hi
    refine ⟨?_, (le_div_iff₀ hpi).mpr (hlo i hi), (div_le_iff₀ hpi).mpr (hhi i hi)⟩
    exact lt_of_lt_of_le hr₁ ((le_div_iff₀ hpi).mpr (hlo i hi))
  have hd : ∀ i ∈ s, 0 < √(p i * q i) - p i := by
    intro i hi
    have hpi := hp i hi
    have hqi : p i < q i := by have := (key i hi).1; rwa [one_lt_div hpi] at this
    have : p i < √(p i * q i) := by
      rw [Real.lt_sqrt hpi.le]
      nlinarith
    linarith
  apply ratio_of_sums_mem s _ _ hs hd
  intro i hi
  obtain ⟨h1, hlo', hhi'⟩ := key i hi
  have hpi := hp i hi
  have hqi : p i < q i := by rwa [one_lt_div hpi] at h1
  have heq := posSpeedup_eq_ratio hpi hqi
  have hdi := hd i hi
  rw [eq_comm, eq_div_iff hdi.ne'] at heq
  constructor
  · calc posSpeedup r₂ * (√(p i * q i) - p i)
        ≤ posSpeedup (q i / p i) * (√(p i * q i) - p i) :=
          mul_le_mul_of_nonneg_right (anti_le h1 hhi') hdi.le
      _ = p i := heq
  · calc p i = posSpeedup (q i / p i) * (√(p i * q i) - p i) := heq.symm
      _ ≤ posSpeedup r₁ * (√(p i * q i) - p i) :=
          mul_le_mul_of_nonneg_right (anti_le hr₁ hlo') hdi.le

/-- **Consistency audit of experiment 467, mechanism (a).**  The three measured stratum
speedups `20.67`, `4.74`, `1.97` fall inside the proved bands `[4 + 2√5, ∞)`,
`[1 + √2, 4 + 2√5]`, `[1, 1 + √2]`; and all three strata of the near-square and middle bands
clear the residue cap `4/3`. -/
theorem exp467_mechanism_a_consistent :
    4 + 2 * √5 ≤ (20.67 : ℝ) ∧
    (1 + √2 ≤ (4.74 : ℝ) ∧ (4.74 : ℝ) ≤ 4 + 2 * √5) ∧
    (1 ≤ (1.97 : ℝ) ∧ (1.97 : ℝ) ≤ 1 + √2) ∧
    (4 / 3 : ℝ) < 1 + √2 := by
  have h5 : √5 < 3 := by
    rw [show (3:ℝ) = √9 by rw [show (9:ℝ) = 3^2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  have h5' : (2 : ℝ) < √5 := by
    rw [show (2:ℝ) = √4 by rw [show (4:ℝ) = 2^2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  have h2 : √2 < 3 / 2 := by
    rw [show (3/2:ℝ) = √(9/4) by
      rw [show (9/4:ℝ) = (3/2)^2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  have h2' : (1.4 : ℝ) < √2 := by
    rw [show (1.4:ℝ) = √(1.96) by
      rw [show (1.96:ℝ) = (1.4)^2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  refine ⟨by linarith, ⟨by linarith, by linarith⟩, ⟨by norm_num, by linarith⟩, by linarith⟩

end PositionalFilter