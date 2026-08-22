/-
# The `L¹` rounding energy of a rational mesh is a Turán number

Continuing the NET-52 analysis of round-to-nearest (RTN) quantization, this file computes the
*total absolute* rounding error over one period of the mesh `(1/q)ℤ` — the quantity that
controls the `ℓ¹` weight perturbation of a quantized tensor whose entries are equidistributed
on the grid.  The answer is a purely combinatorial number:

`∑_{j<q} |round(j/q) − j/q| = ⌊q²/4⌋ / q`,

and `⌊q²/4⌋` is exactly the Mantel–Turán number `ex(q; K₃)`, the maximum number of edges of a
triangle-free graph on `q` vertices.  The bridge is not an accident: both count the same
optimization `max_{j} j·(q−j)` / `∑_j min(j, q−j)` over a balanced bipartition of `q`.

Main results (all proved here from scratch, so the file is self-contained):

* `four_mul_sum_min` — the exact division-free identity `4·∑_{j<q} min(j, q−j) + q % 2 = q²`.
* `sum_min_eq_turan` — hence `∑_{j<q} min(j, q−j) = ⌊q²/4⌋`, the Mantel–Turán number.
* `sawtooth_l1_period` — the real-analytic consequence: the `L¹` rounding energy of the mesh.
* `sawtooth_l1_le_quarter`, `sawtooth_l1_ge` — the mean absolute error is `1/4` of a mesh unit
  up to `O(1/q)`, i.e. *half* of the worst case `1/2` and strictly larger than the signed bias
  `1/(2q)` computed in `QuantSawtoothBias.lean`.  Absolute damage is `Θ(1)` per weight in mesh
  units, whereas the *signed* drift is `Θ(1/q)`: only compensation schemes that track signs can
  exploit the difference.
-/
import Mathlib

namespace Catalog.NumberTheory.QuantTuran

open Finset

/-- The signed round-to-nearest error at unit mesh. -/
noncomputable def sawtooth (x : ℝ) : ℝ := (round x : ℝ) - x

/-- On a full period, `round (j/q)` is `0` below the midpoint and `1` from the tie on. -/
lemma round_div_of_lt {q j : ℕ} (hq : 0 < q) (hj : j < q) :
    round ((j : ℝ) / q) = if 2 * j < q then 0 else 1 := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  by_cases h : 2 * j < q
  · have hlt : (j : ℝ) / q < 1 / 2 := by
      rw [div_lt_div_iff₀ hqR (by norm_num)]
      have h' := (Nat.cast_lt (α := ℝ)).2 h
      push_cast at h'
      linarith
    have hge : (0:ℝ) ≤ (j : ℝ) / q := by positivity
    rw [round_eq, if_pos h]
    have : ⌊(j : ℝ) / q + 1 / 2⌋ = 0 := by
      rw [Int.floor_eq_zero_iff]
      constructor <;> simp <;> linarith
    exact this
  · push_neg at h
    have hge : 1 / 2 ≤ (j : ℝ) / q := by
      rw [le_div_iff₀ hqR]
      have h' := (Nat.cast_le (α := ℝ)).2 h
      push_cast at h'
      linarith
    have hlt : (j : ℝ) / q < 1 := by
      rw [div_lt_one hqR]
      exact_mod_cast hj
    rw [round_eq, if_neg (by omega)]
    have : ⌊(j : ℝ) / q + 1 / 2⌋ = 1 := by
      rw [Int.floor_eq_iff]
      constructor <;> push_cast <;> linarith
    exact this

/-- The absolute rounding error on the mesh is the *distance to the nearer end* of the period. -/
lemma abs_sawtooth_div {q j : ℕ} (hq : 0 < q) (hj : j < q) :
    |sawtooth ((j : ℝ) / q)| = (min j (q - j) : ℕ) / q := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  rw [sawtooth, round_div_of_lt hq hj]
  by_cases h : 2 * j < q
  · rw [if_pos h]
    have hmin : min j (q - j) = j := by omega
    have hnn : (0:ℝ) ≤ (j : ℝ) / q := by positivity
    have hval : ((0 : ℤ) : ℝ) - (j : ℝ) / q = -((j : ℝ) / q) := by push_cast; ring
    rw [hmin, hval, abs_neg, abs_of_nonneg hnn]
  · rw [if_neg h]
    have hmin : min j (q - j) = q - j := by omega
    have hcast : ((q - j : ℕ) : ℝ) = (q : ℝ) - j := by
      have : j ≤ q := le_of_lt hj
      push_cast [Nat.cast_sub this]
      ring
    rw [hmin, hcast]
    have hnn : (0:ℝ) ≤ 1 - (j : ℝ) / q := by
      have : (j : ℝ) ≤ q := by exact_mod_cast le_of_lt hj
      rw [sub_nonneg, div_le_one hqR]
      exact this
    rw [show ((1 : ℤ) : ℝ) - (j : ℝ) / q = 1 - (j : ℝ) / q by push_cast; ring,
      abs_of_nonneg hnn]
    field_simp

/-! ## The combinatorial identity -/

private lemma sum_range_id (n : ℕ) : 2 * ∑ i ∈ Finset.range n, i + n = n * n := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ]
      have hexp : 2 * ((∑ i ∈ Finset.range k, i) + k) + (k + 1)
          = (2 * ∑ i ∈ Finset.range k, i + k) + (2 * k + 1) := by ring
      rw [hexp, ih]
      ring

/-- The lower half of a period contributes the triangular number of `⌈q/2⌉`. -/
private lemma sum_lower (q : ℕ) :
    ∑ j ∈ Finset.range q with 2 * j < q, min j (q - j) = ∑ i ∈ Finset.range ((q + 1) / 2), i := by
  have hset : (Finset.range q).filter (fun j => 2 * j < q) = Finset.range ((q + 1) / 2) := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_range]
    omega
  rw [hset]
  exact Finset.sum_congr rfl fun j hj => by
    have := Finset.mem_range.1 hj
    omega

/-- The upper half of a period contributes the triangular number of `⌊q/2⌋ + 1` minus one. -/
private lemma sum_upper (q : ℕ) :
    ∑ j ∈ Finset.range q with ¬ 2 * j < q, min j (q - j)
      = (∑ i ∈ Finset.range (q / 2), i) + q / 2 := by
  have hset : (Finset.range q).filter (fun j => ¬ 2 * j < q) = Finset.Ico ((q + 1) / 2) q := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]
    omega
  rw [hset]
  have hval : ∀ j ∈ Finset.Ico ((q + 1) / 2) q, min j (q - j) = q - j := by
    intro j hj
    simp only [Finset.mem_Ico] at hj
    omega
  rw [Finset.sum_congr rfl hval]
  have hle : (q + 1) / 2 ≤ q := by omega
  rw [Finset.sum_Ico_eq_sum_range]
  have hd : q - (q + 1) / 2 = q / 2 := by omega
  rw [hd]
  have hval2 : ∀ k ∈ Finset.range (q / 2), q - ((q + 1) / 2 + k) = q / 2 - k := by
    intro k hk
    have := Finset.mem_range.1 hk
    omega
  rw [Finset.sum_congr rfl hval2]
  have hrefl := Finset.sum_range_reflect (fun k => q / 2 - k) (q / 2)
  rw [← hrefl]
  have hval3 : ∀ k ∈ Finset.range (q / 2), q / 2 - (q / 2 - 1 - k) = k + 1 := by
    intro k hk
    have := Finset.mem_range.1 hk
    omega
  rw [Finset.sum_congr rfl hval3, Finset.sum_add_distrib]
  simp

/-- **Division-free form of the `L¹` energy.** -/
theorem four_mul_sum_min (q : ℕ) :
    4 * ∑ j ∈ Finset.range q, min j (q - j) + q % 2 = q ^ 2 := by
  have hsplit := Finset.sum_filter_add_sum_filter_not (Finset.range q)
    (fun j => 2 * j < q) (fun j => min j (q - j))
  rw [sum_lower q, sum_upper q] at hsplit
  have hc := sum_range_id ((q + 1) / 2)
  have hd := sum_range_id (q / 2)
  set A := ∑ i ∈ Finset.range ((q + 1) / 2), i with hA
  set B := ∑ i ∈ Finset.range (q / 2), i with hB
  rw [← hsplit]
  rcases Nat.even_or_odd q with ⟨m, hm⟩ | ⟨m, hm⟩
  · have hq1 : (q + 1) / 2 = m := by omega
    have hq2 : q / 2 = m := by omega
    rw [hq1] at hc
    rw [hq2] at hd
    have hmod : q % 2 = 0 := by omega
    subst hm
    rw [hmod, hq2]
    have h4 : (m + m) ^ 2 = 4 * (m * m) := by ring
    rw [h4]
    linarith [hc, hd]
  · have hq1 : (q + 1) / 2 = m + 1 := by omega
    have hq2 : q / 2 = m := by omega
    rw [hq1] at hc
    rw [hq2] at hd
    have hmod : q % 2 = 1 := by omega
    subst hm
    rw [hmod, hq2]
    have h4 : (2 * m + 1) ^ 2 = 4 * (m * m) + 4 * m + 1 := by ring
    have h5 : (m + 1) * (m + 1) = m * m + 2 * m + 1 := by ring
    rw [h4]
    rw [h5] at hc
    linarith [hc, hd]

/-- **Bridge to extremal graph theory.**  The `L¹` rounding energy of the mesh `(1/q)ℤ`, in
units of the mesh, is the Mantel–Turán number `⌊q²/4⌋ = ex(q; K₃)`. -/
theorem sum_min_eq_turan (q : ℕ) : ∑ j ∈ Finset.range q, min j (q - j) = q ^ 2 / 4 := by
  have h := four_mul_sum_min q
  omega

/-- **The `L¹` rounding energy of a rational mesh.** -/
theorem sawtooth_l1_period {q : ℕ} (hq : 0 < q) :
    ∑ j ∈ Finset.range q, |sawtooth ((j : ℝ) / q)|
      = ((q : ℝ) ^ 2 - (q % 2 : ℕ)) / (4 * q) := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  have hpt : ∀ j ∈ Finset.range q,
      |sawtooth ((j : ℝ) / q)| = ((min j (q - j) : ℕ) : ℝ) / q :=
    fun j hj => abs_sawtooth_div hq (Finset.mem_range.1 hj)
  rw [Finset.sum_congr rfl hpt, ← Finset.sum_div]
  have hcast : ∑ j ∈ Finset.range q, ((min j (q - j) : ℕ) : ℝ)
      = ((∑ j ∈ Finset.range q, min j (q - j) : ℕ) : ℝ) := by
    push_cast
    rfl
  rw [hcast]
  have hnat := four_mul_sum_min q
  have hreal : 4 * ((∑ j ∈ Finset.range q, min j (q - j) : ℕ) : ℝ) + ((q % 2 : ℕ) : ℝ)
      = (q : ℝ) ^ 2 := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) hnat
  field_simp
  linarith

/-- The mean absolute error never exceeds a quarter of a mesh unit. -/
theorem sawtooth_l1_le_quarter {q : ℕ} (hq : 0 < q) :
    ∑ j ∈ Finset.range q, |sawtooth ((j : ℝ) / q)| ≤ (q : ℝ) / 4 := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  rw [sawtooth_l1_period hq, div_le_div_iff₀ (by positivity) (by norm_num)]
  have hmod : (0:ℝ) ≤ ((q % 2 : ℕ) : ℝ) := by positivity
  nlinarith

/-- ... and it is within `1/(4q)` of that quarter: absolute damage is `Θ(1)` per weight, in
sharp contrast with the `Θ(1/q)` *signed* bias. -/
theorem sawtooth_l1_ge {q : ℕ} (hq : 0 < q) :
    (q : ℝ) / 4 - 1 / (4 * q) ≤ ∑ j ∈ Finset.range q, |sawtooth ((j : ℝ) / q)| := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  rw [sawtooth_l1_period hq]
  have hmod : ((q % 2 : ℕ) : ℝ) ≤ 1 := by
    have : q % 2 ≤ 1 := by omega
    exact_mod_cast this
  rw [div_sub_div _ _ (by norm_num : (4:ℝ) ≠ 0) (by positivity : (4 * (q:ℝ)) ≠ 0),
    div_le_div_iff₀ (by positivity) (by positivity)]
  nlinarith [hqR, sq_nonneg ((q:ℝ))]

end Catalog.NumberTheory.QuantTuran