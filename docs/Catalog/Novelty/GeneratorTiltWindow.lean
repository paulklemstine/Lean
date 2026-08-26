/-
# Generator tilt and the window/sqrt scan-order inversion (discrete layer)

This file formalises the *scan-order* cost model behind the "Λ-channel" question for
semiprime factor search, and proves the exact algebraic law that governs which of the two
canonical divisor scan orders wins on a given population of semiprimes.

Setting.  A semiprime `N = p * q` with `p ≤ q` has its small factor `p` in the *canonical
window* `(√(N/2), √N]` exactly when the pair is *balanced*, i.e. `q < 2p`
(`GeneratorTilt.window_iff_balanced`).  Inside a window `[a, b]` one may scan

* **window-ascending**: `a, a+1, …` until the divisor is hit — cost `d - a + 1`;
* **sqrt-descending**:  `b, b-1, …` until the divisor is hit — cost `b - d + 1`.

The two costs are complementary (`ascCost_add_descCost`), so the comparison is decided by a
single scalar: the *tilt* `z = (d - a)/(b - a) ∈ [0,1]`, the normalised height of the divisor
in the window.  The main results are:

* `GeneratorTilt.speedup_eq` — the exact pool speedup
  `S = (L(1 - z̄) + 1)/(L z̄ + 1)` where `z̄` is the mean tilt and `L` the window length;
* `GeneratorTilt.predictor_sub_speedup` / `abs_speedup_sub_predictor_le` — the tilt-only
  predictor `(1 - z̄)/z̄` is exact up to `O(1/L)`, with an explicit error identity;
* `GeneratorTilt.descending_wins_iff_top_heavy` — *the inversion*: sqrt-descending strictly
  beats window-ascending **iff** the pool is top-heavy (`z̄ > 1/2`).  Hence a Λ-style
  window-ascending advantage exists only for bottom-heavy pools; a measured mean tilt
  `z̄ > 1/2` refutes it outright, no matter how the window is realised.

Together with `Novelty.GeneratorTiltRatio` (which computes `z̄` from the prime-ratio law)
this pins down exactly which generator classes can support a window-ascending gain.
-/
import Mathlib

namespace GeneratorTilt

open Finset

/-! ## The two scan costs inside a window -/

/-- Touch count of a window-ascending scan of `[a, b]` that stops at divisor `d`. -/
def ascCost (a d : ℤ) : ℤ := d - a + 1

/-- Touch count of a sqrt-descending scan of `[a, b]` that stops at divisor `d`. -/
def descCost (b d : ℤ) : ℤ := b - d + 1

/-- **Conservation law**: the two scan orders share the window budget; their touch counts
always sum to the window length plus two. -/
theorem ascCost_add_descCost (a b d : ℤ) : ascCost a d + descCost b d = (b - a) + 2 := by
  unfold ascCost descCost; ring

theorem ascCost_pos {a d : ℤ} (h : a ≤ d) : 0 < ascCost a d := by
  unfold ascCost; omega

theorem descCost_pos {b d : ℤ} (h : d ≤ b) : 0 < descCost b d := by
  unfold descCost; omega

/-- Pointwise inversion: descending beats ascending exactly above the window midpoint. -/
theorem descCost_lt_ascCost_iff (a b d : ℤ) :
    descCost b d < ascCost a d ↔ a + b < 2 * d := by
  unfold ascCost descCost; omega

/-! ## The canonical window is the balance window -/

/-- **Window membership is exactly balance.**  For a factorisation `N = p * q` with `0 < p`,
the small factor lies in the canonical window `(√(N/2), √N]` — i.e. `p^2 ≤ N < 2p^2` —
if and only if `p ≤ q` and `q < 2p`.  In particular a generator that does *not* enforce
`q < 2p` produces keys for which window-ascending is not even well defined. -/
theorem window_iff_balanced {p q : ℕ} (hp : 0 < p) :
    (p * p ≤ p * q ∧ p * q < 2 * (p * p)) ↔ (p ≤ q ∧ q < 2 * p) := by
  have h2 : 2 * (p * p) = p * (2 * p) := by ring
  rw [h2, Nat.mul_le_mul_left_iff hp, Nat.mul_lt_mul_left hp]

/-- Enforced balance puts every key inside the window (`in_win = 1`). -/
theorem balanced_in_window {p q : ℕ} (hp : 0 < p) (h1 : p ≤ q) (h2 : q < 2 * p) :
    p * p ≤ p * q ∧ p * q < 2 * (p * p) := (window_iff_balanced hp).mpr ⟨h1, h2⟩

/-- **Same-bit-length keys are automatically balanced**, hence automatically inside the
canonical window (`in_win = 1`).  This is why a deployed-style pool of two independent
primes of equal bit length never leaves the window ascending scan undefined — and why the
loss it suffers there cannot be blamed on window misses. -/
theorem same_bitlength_in_window {b p q : ℕ} (hb : 1 ≤ b) (hp : 2 ^ (b - 1) ≤ p)
    (hpq : p ≤ q) (hq : q < 2 ^ b) : p * p ≤ p * q ∧ p * q < 2 * (p * p) := by
  have hp0 : 0 < p := lt_of_lt_of_le (Nat.two_pow_pos (b-1)) hp
  have hpow : 2 ^ b = 2 * 2 ^ (b - 1) := by
    conv_lhs => rw [show b = (b - 1) + 1 by omega]
    rw [pow_succ]
    ring
  refine (window_iff_balanced hp0).mpr ⟨hpq, ?_⟩
  omega

/-- Off-balance semiprimes really do fall outside the canonical window: `21 = 3 * 7`. -/
theorem exists_semiprime_outside_window :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≤ q ∧ ¬ (p * q < 2 * (p * p)) := by
  refine ⟨3, 7, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-! ## Pool-level totals -/

variable {ι : Type*}

/-- Total ascending touch count over a pool. -/
def totalAsc (s : Finset ι) (a : ℤ) (d : ι → ℤ) : ℤ := ∑ i ∈ s, ascCost a (d i)

/-- Total descending touch count over a pool. -/
def totalDesc (s : Finset ι) (b : ℤ) (d : ι → ℤ) : ℤ := ∑ i ∈ s, descCost b (d i)

theorem totalAsc_eq (s : Finset ι) (a : ℤ) (d : ι → ℤ) :
    totalAsc s a d = (∑ i ∈ s, d i) - s.card * a + s.card := by
  unfold totalAsc ascCost
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  simp [mul_comm]

theorem totalDesc_eq (s : Finset ι) (b : ℤ) (d : ι → ℤ) :
    totalDesc s b d = s.card * b - (∑ i ∈ s, d i) + s.card := by
  unfold totalDesc descCost
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  simp [mul_comm]

/-- Integer form of the inversion at pool level: descending wins iff the mean divisor
position sits above the window midpoint. -/
theorem totalDesc_lt_totalAsc_iff (s : Finset ι) (a b : ℤ) (d : ι → ℤ) :
    totalDesc s b d < totalAsc s a d ↔ (s.card : ℤ) * (a + b) < 2 * ∑ i ∈ s, d i := by
  rw [totalAsc_eq, totalDesc_eq]; constructor <;> intro h <;> nlinarith [h]

/-! ## Mean tilt and the exact speedup law -/

/-- The tilt of a divisor: its normalised height in the window, `0` at the bottom,
`1` at the top. -/
noncomputable def tilt (a b : ℤ) (x : ℤ) : ℝ := ((x : ℝ) - a) / ((b : ℝ) - a)

/-- Mean tilt of a pool (`z̄`). -/
noncomputable def meanTilt (s : Finset ι) (a b : ℤ) (d : ι → ℤ) : ℝ :=
  (∑ i ∈ s, tilt a b (d i)) / s.card

theorem sum_tilt (s : Finset ι) {a b : ℤ} (hab : a < b) (d : ι → ℤ) :
    ∑ i ∈ s, tilt a b (d i) = ((∑ i ∈ s, (d i : ℝ)) - s.card * a) / ((b : ℝ) - a) := by
  have hL : ((b : ℝ) - a) ≠ 0 := by
    have : (a : ℝ) < b := by exact_mod_cast hab
    linarith
  unfold tilt
  rw [← Finset.sum_div, Finset.sum_sub_distrib]
  simp [mul_comm]

/-- Ascending total, expressed through the mean tilt: `n (L z̄ + 1)`. -/
theorem totalAsc_eq_meanTilt (s : Finset ι) {a b : ℤ} (hab : a < b) (d : ι → ℤ)
    (hs : s.Nonempty) :
    (totalAsc s a d : ℝ) =
      s.card * (((b : ℝ) - a) * meanTilt s a b d + 1) := by
  have hcard : (s.card : ℝ) ≠ 0 := by
    simpa using (Nat.cast_ne_zero (R := ℝ)).mpr (Finset.card_ne_zero_of_mem hs.choose_spec)
  have hL : ((b : ℝ) - a) ≠ 0 := by
    have : (a : ℝ) < b := by exact_mod_cast hab
    linarith
  rw [totalAsc_eq]
  unfold meanTilt
  rw [sum_tilt s hab d]
  push_cast
  field_simp

/-- Descending total, expressed through the mean tilt: `n (L (1 - z̄) + 1)`. -/
theorem totalDesc_eq_meanTilt (s : Finset ι) {a b : ℤ} (hab : a < b) (d : ι → ℤ)
    (hs : s.Nonempty) :
    (totalDesc s b d : ℝ) =
      s.card * (((b : ℝ) - a) * (1 - meanTilt s a b d) + 1) := by
  have hcard : (s.card : ℝ) ≠ 0 := by
    simpa using (Nat.cast_ne_zero (R := ℝ)).mpr (Finset.card_ne_zero_of_mem hs.choose_spec)
  have hL : ((b : ℝ) - a) ≠ 0 := by
    have : (a : ℝ) < b := by exact_mod_cast hab
    linarith
  rw [totalDesc_eq]
  unfold meanTilt
  rw [sum_tilt s hab d]
  push_cast
  field_simp
  ring

/-- **Exact speedup law.**  The pool speedup of window-ascending over sqrt-descending,
`S = totalDesc / totalAsc`, is a function of the mean tilt alone:
`S = (L(1 - z̄) + 1) / (L z̄ + 1)` with `L` the window length. -/
theorem speedup_eq (s : Finset ι) {a b : ℤ} (hab : a < b) (d : ι → ℤ) (hs : s.Nonempty)
    (hz : 0 < meanTilt s a b d) :
    (totalDesc s b d : ℝ) / (totalAsc s a d : ℝ) =
      (((b : ℝ) - a) * (1 - meanTilt s a b d) + 1) / (((b : ℝ) - a) * meanTilt s a b d + 1) := by
  have hcard : (0 : ℝ) < s.card := by
    exact_mod_cast Finset.card_pos.mpr hs
  have hL : (0 : ℝ) < (b : ℝ) - a := by
    have : (a : ℝ) < b := by exact_mod_cast hab
    linarith
  have hden : ((b : ℝ) - a) * meanTilt s a b d + 1 > 0 := by positivity
  rw [totalAsc_eq_meanTilt s hab d hs, totalDesc_eq_meanTilt s hab d hs]
  field_simp

/-! ## The tilt-only predictor -/

/-- **Predictor error identity.**  The discrepancy between the exact speedup and the
tilt-only predictor `(1 - z)/z` is `(2z - 1) / (z (L z + 1))`: it vanishes at the
balanced tilt `z = 1/2` and is `O(1/L)` elsewhere. -/
theorem predictor_sub_speedup {L z : ℝ} (hL : 0 < L) (hz : 0 < z) :
    (L * (1 - z) + 1) / (L * z + 1) - (1 - z) / z = (2 * z - 1) / (z * (L * z + 1)) := by
  have h1 : L * z + 1 > 0 := by positivity
  field_simp
  ring

/-- **Predictor accuracy.**  For any positive tilt the tilt-only predictor is correct to
within `1/(L z²)`; in particular it becomes exact as the window length grows. -/
theorem abs_speedup_sub_predictor_le {L z : ℝ} (hL : 0 < L) (hz : 0 < z) (hz1 : z ≤ 1) :
    |(L * (1 - z) + 1) / (L * z + 1) - (1 - z) / z| ≤ 1 / (L * z ^ 2) := by
  rw [predictor_sub_speedup hL hz, abs_div]
  have hpos : (0 : ℝ) < z * (L * z + 1) := by positivity
  rw [abs_of_pos hpos]
  rw [div_le_div_iff₀ hpos (by positivity)]
  have h2 : |2 * z - 1| ≤ 1 := by
    rw [abs_le]; constructor <;> nlinarith
  nlinarith [mul_le_mul_of_nonneg_right h2 (le_of_lt (by positivity : (0:ℝ) < L * z ^ 2))]

/-! ## The inversion theorem -/

/-- **Scan-order inversion (main theorem).**  On any pool with a nondegenerate window,
sqrt-descending strictly beats window-ascending **iff** the pool is top-heavy, i.e. the mean
tilt exceeds `1/2`.  A measured `z̄ > 1/2` therefore refutes any window-ascending
(Λ-channel) advantage for that generator class, and `z̄ < 1/2` is exactly the condition
under which the advantage exists. -/
theorem descending_wins_iff_top_heavy (s : Finset ι) {a b : ℤ} (hab : a < b) (d : ι → ℤ)
    (hs : s.Nonempty) :
    (totalDesc s b d : ℝ) < (totalAsc s a d : ℝ) ↔ 1 / 2 < meanTilt s a b d := by
  have hcard : (0 : ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  have hL : (0 : ℝ) < (b : ℝ) - a := by
    have : (a : ℝ) < b := by exact_mod_cast hab
    linarith
  rw [totalAsc_eq_meanTilt s hab d hs, totalDesc_eq_meanTilt s hab d hs,
    mul_lt_mul_iff_of_pos_left hcard]
  constructor <;> intro h <;> nlinarith

/-- Quantitative form of the refutation over the measured RSA-style tilt interval
`z̄ ∈ [0.6150, 0.6562]`: the pool is top-heavy (so by `descending_wins_iff_top_heavy`
sqrt-descending wins), and the tilt-only speedup predictor is pinned in `(0.52, 0.63)`,
i.e. window-ascending loses roughly `40%`–`48%` of the work. -/
theorem rsa_pool_predictor_lt (z : ℝ) (h1 : (0.6150 : ℝ) ≤ z) (h2 : z ≤ 0.6562) :
    0.52 < (1 - z) / z ∧ (1 - z) / z < 0.63 ∧ 1 / 2 < z := by
  refine ⟨?_, ?_, by linarith⟩
  · rw [lt_div_iff₀ (by linarith)]; nlinarith
  · rw [div_lt_iff₀ (by linarith)]; nlinarith

end GeneratorTilt