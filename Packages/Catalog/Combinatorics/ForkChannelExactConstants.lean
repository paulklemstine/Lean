/-
# Exact asymptotic constants of the four fork channels

This file formalises, from scratch and with complete proofs, the "exact constant laws"
of a four–channel *fork* model built out of the binary entropy function.

For a resolution parameter `n ≥ 2` we consider four scalar channels:

* the **capacity channel** `X n = 1 - H(1/2 + 1/n)`
  (equivalently the forward divergence `D(Bern(1/2+1/n) ‖ Bern(1/2))`),
* the **ambiguity channel** `A n = log₂ n / n²`
  (half the surprisal of a fork event of probability `1/n²`),
* the **gap channel** `g n = -(1 - 1/n²)·log₂(1 - 1/n²) - 1/n²`
  (the excess of the survival entropy term over the fork probability),
* the **reverse channel** `R n = -(1/2)·log₂(1 - 4/n²)`
  (the reverse divergence `D(Bern(1/2) ‖ Bern(1/2+1/n))`), and the
  **isolation channel** `Is n = A n + R n`.

The four exact constant laws proved below are

* `gch_mul_sq_tendsto`      : `g·n² → log₂ e - 1 = 0.442695…`  (no logarithmic factor),
* `Xch_mul_sq_tendsto`      : `X·n² → 2 log₂ e = 2.885390…`,
* `Ach_scaled_eq_one`       : `A·n²/log₂ n = 1` exactly, hence `→ 1`,
* `Isch_sub_Ach_mul_sq_tendsto` : `(Is - A)·n² → 2 log₂ e`,

and consequently

* `Xch_div_gch_tendsto`     : `X/g → 2 log₂ e/(log₂ e - 1) = 2/(1 - log 2) = 6.51778…`,
* `Xch_div_gch_not_tendsto_two` : the ratio does **not** tend to `2`
  (a formal refutation of the pre-data guess `X/g → 2`).

and, combining the `A` and `X` laws,

* `Ach_div_Xch_tendsto_atTop` : `A/X → ∞` (the ambiguity channel eventually dominates the
  capacity channel, which is the asymptotic form of the `A/X` sign flip below).

Finally the small-scale structure predicted by the numerical table is verified exactly:

* `Xch_two`, `Ach_two`, `gch_two` : the values at the collapse point `n = 2`,
* `Ach_seven_lt_Xch_seven` and `Xch_eight_lt_Ach_eight` : the `A/X` sign flip happens
  exactly in the window `(7,8)`.

Note on `n = 2`: the reverse channel `R n = -(1/2) log₂(1 - 4/n²)` diverges at `n = 2`
(its argument is `0`), so no value of `R 2` or `Is 2` is asserted here; only the three
channels that are genuinely defined at `n = 2` are evaluated.

All logarithm estimates are derived from scratch (two-sided bounds on `log(1-u)` and a
cubic Taylor window for `(1+x)log(1+x) + (1-x)log(1-x)`), and all numerical
inequalities are reduced to integer power comparisons such as `7^100 < 3^126·5^35`
and `5^40·3^24 < 2^131`.
-/
import Mathlib

namespace Catalog.Combinatorics.ForkChannel

open Real Filter Topology

noncomputable section

/-- Binary logarithm. -/
def lb (x : ℝ) : ℝ := Real.logb 2 x

/-- Binary entropy (in bits). -/
def binEnt (p : ℝ) : ℝ := -p * lb p - (1 - p) * lb (1 - p)

/-- The capacity channel `X n = 1 - H(1/2 + 1/n)`. -/
def Xch (n : ℝ) : ℝ := 1 - binEnt (1 / 2 + 1 / n)

/-- The ambiguity channel `A n = log₂ n / n²`. -/
def Ach (n : ℝ) : ℝ := lb n / n ^ 2

/-- The gap channel `g n = -(1 - 1/n²) log₂(1 - 1/n²) - 1/n²`. -/
def gch (n : ℝ) : ℝ := -(1 - 1 / n ^ 2) * lb (1 - 1 / n ^ 2) - 1 / n ^ 2

/-- The reverse-divergence channel `R n = -(1/2) log₂(1 - 4/n²)`. -/
def Rch (n : ℝ) : ℝ := -(1 / 2) * lb (1 - 4 / n ^ 2)

/-- The isolation channel `Is n = A n + R n`. -/
def Isch (n : ℝ) : ℝ := Ach n + Rch n

/-! ### Elementary logarithm windows -/

lemma log_two_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)

lemma log_two_lt_one : Real.log 2 < 1 := by
  have h := Real.log_lt_sub_one_of_pos (x := 2) (by norm_num) (by norm_num)
  linarith

/-- Lower window: `u ≤ -log (1-u)` for `u < 1`. -/
lemma neg_log_one_sub_ge {u : ℝ} (hu : u < 1) : u ≤ -Real.log (1 - u) := by
  have h : Real.log (1 - u) ≤ (1 - u) - 1 :=
    Real.log_le_sub_one_of_pos (by linarith)
  linarith

/-- Upper window: `-log (1-u) ≤ u + 2u²` for `u ≤ 1/2`. -/
lemma neg_log_one_sub_le {u : ℝ} (hu1 : u ≤ 1 / 2) :
    -Real.log (1 - u) ≤ u + 2 * u ^ 2 := by
  have hpos : (0:ℝ) < 1 - u := by linarith
  have h : Real.log (1 - u)⁻¹ ≤ (1 - u)⁻¹ - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_inv] at h
  have hle : (1:ℝ) / (1 - u) ≤ 1 + u + 2 * u ^ 2 := by
    rw [div_le_iff₀ hpos]; nlinarith
  rw [inv_eq_one_div] at h
  linarith

/-- Quadratic Taylor window for `log (1+x)` with cubic error. -/
lemma abs_log_one_add_sub_quad {x : ℝ} (hx : |x| ≤ 1 / 2) :
    |Real.log (1 + x) - (x - x ^ 2 / 2)| ≤ 2 * |x| ^ 3 := by
  have habs : |(-x)| < 1 := by rw [abs_neg]; linarith [abs_nonneg x]
  have h := Real.abs_log_sub_add_sum_range_le habs 2
  have hsum : (∑ i ∈ Finset.range 2, (-x) ^ (i + 1) / ((i : ℝ) + 1)) = -x + x ^ 2 / 2 := by
    simp [Finset.sum_range_succ]; ring
  rw [hsum, show (1 : ℝ) - -x = 1 + x from by ring, abs_neg] at h
  have hx0 : (0:ℝ) ≤ |x| := abs_nonneg x
  have hden : (1 : ℝ) / 2 ≤ 1 - |x| := by linarith
  have hbound : |x| ^ 3 / (1 - |x|) ≤ 2 * |x| ^ 3 := by
    rw [div_le_iff₀ (by linarith)]
    nlinarith [pow_nonneg hx0 3]
  have h' : |Real.log (1 + x) - (x - x ^ 2 / 2)| ≤ |x| ^ (2 + 1) / (1 - |x|) := by
    rw [show Real.log (1 + x) - (x - x ^ 2 / 2) = -x + x ^ 2 / 2 + Real.log (1 + x) from by ring]
    exact h
  rw [show |x| ^ (2 + 1) = |x| ^ 3 from by norm_num] at h'
  linarith

/-- The symmetrised fork function. -/
def forkF (x : ℝ) : ℝ := (1 + x) * Real.log (1 + x) + (1 - x) * Real.log (1 - x)

/-- Cubic Taylor window: `forkF x = x² + O(x³)` on `|x| ≤ 1/2`. -/
lemma abs_forkF_sub_sq {x : ℝ} (hx : |x| ≤ 1 / 2) : |forkF x - x ^ 2| ≤ 6 * |x| ^ 3 := by
  have hx' : |(-x)| ≤ 1 / 2 := by rwa [abs_neg]
  have h1 := abs_log_one_add_sub_quad hx
  have h2 := abs_log_one_add_sub_quad hx'
  rw [abs_neg] at h2
  rw [show (1:ℝ) + -x = 1 - x from by ring,
    show (-x) - (-x) ^ 2 / 2 = -x - x ^ 2 / 2 from by ring] at h2
  have hexp : forkF x - x ^ 2 =
      (1 + x) * (Real.log (1 + x) - (x - x ^ 2 / 2))
        + (1 - x) * (Real.log (1 - x) - (-x - x ^ 2 / 2)) := by
    simp only [forkF]; ring
  have hb1 := abs_le.mp hx
  have h1x : |1 + x| ≤ 3 / 2 := by rw [abs_le]; constructor <;> linarith [hb1.1, hb1.2]
  have h2x : |1 - x| ≤ 3 / 2 := by rw [abs_le]; constructor <;> linarith [hb1.1, hb1.2]
  have step1 : |(1 + x) * (Real.log (1 + x) - (x - x ^ 2 / 2))| ≤ (3/2) * (2 * |x| ^ 3) := by
    rw [abs_mul]
    exact mul_le_mul h1x h1 (abs_nonneg _) (by norm_num)
  have step2 : |(1 - x) * (Real.log (1 - x) - (-x - x ^ 2 / 2))| ≤ (3/2) * (2 * |x| ^ 3) := by
    rw [abs_mul]
    exact mul_le_mul h2x h2 (abs_nonneg _) (by norm_num)
  have htri := abs_add_le ((1 + x) * (Real.log (1 + x) - (x - x ^ 2 / 2)))
      ((1 - x) * (Real.log (1 - x) - (-x - x ^ 2 / 2)))
  rw [hexp]
  linarith

/-! ### Closed forms -/

lemma logb_eq (x : ℝ) : lb x = Real.log x / Real.log 2 := rfl

/-- Closed form of the capacity channel in terms of `forkF`. -/
lemma Xch_eq_forkF {n : ℝ} (hn : 2 < n) :
    Xch n = forkF (2 / n) / (2 * Real.log 2) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hx1 : (0:ℝ) < 1 + 2 / n := by positivity
  have hx2 : (0:ℝ) < 1 - 2 / n := by
    have : 2 / n < 1 := by rw [div_lt_one hn0]; linarith
    linarith
  have hp : 1 / 2 + 1 / n = (1 + 2 / n) / 2 := by field_simp
  have hq : (1:ℝ) - (1 + 2 / n) / 2 = (1 - 2 / n) / 2 := by ring
  have hl1 : Real.log ((1 + 2 / n) / 2) = Real.log (1 + 2 / n) - Real.log 2 :=
    Real.log_div (ne_of_gt hx1) (by norm_num)
  have hl2 : Real.log ((1 - 2 / n) / 2) = Real.log (1 - 2 / n) - Real.log 2 :=
    Real.log_div (ne_of_gt hx2) (by norm_num)
  have hlog2 : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  simp only [Xch, binEnt, forkF, logb_eq, hp, hq, hl1, hl2]
  field_simp
  ring

/-! ### Quantitative one-step estimates -/

/-- Core estimate for the gap channel: `(1-u)·(-log(1-u))/u` is within `2u` of `1`. -/
lemma fork_gap_core {u L : ℝ} (hu0 : 0 < u) (hu4 : u ≤ 1 / 4) (hL1 : u ≤ L)
    (hL2 : L ≤ u + 2 * u ^ 2) : |(1 - u) * L / u - 1| ≤ 2 * u := by
  have e : (1 - u) * L / u - 1 = ((1 - u) * L - u) / u := by field_simp
  rw [e, abs_div, abs_of_pos hu0, div_le_iff₀ hu0, abs_le]
  constructor
  · nlinarith
  · nlinarith

/-- Core estimate for the reverse channel: `(-log(1-v))/v` is within `2v` of `1`. -/
lemma fork_rev_core {v L : ℝ} (hv0 : 0 < v) (hL1 : v ≤ L) (hL2 : L ≤ v + 2 * v ^ 2) :
    |L / v - 1| ≤ 2 * v := by
  have e : L / v - 1 = (L - v) / v := by field_simp
  rw [e, abs_div, abs_of_pos hv0, div_le_iff₀ hv0, abs_le]
  constructor <;> nlinarith

/-- Rate estimate for the gap channel. -/
lemma gch_bound {n : ℝ} (hn : 2 ≤ n) :
    |gch n * n ^ 2 - (1 / Real.log 2 - 1)| ≤ 1 / (n * Real.log 2) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hnsq : (0:ℝ) < n ^ 2 := by positivity
  have hlog : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have hu0 : (0:ℝ) < 1 / n ^ 2 := by positivity
  have hu4 : 1 / n ^ 2 ≤ 1 / 4 := by
    rw [div_le_div_iff₀ hnsq (by norm_num)]; nlinarith
  have hL1 : 1 / n ^ 2 ≤ -Real.log (1 - 1 / n ^ 2) := neg_log_one_sub_ge (by linarith)
  have hL2 : -Real.log (1 - 1 / n ^ 2) ≤ 1 / n ^ 2 + 2 * (1 / n ^ 2) ^ 2 :=
    neg_log_one_sub_le (by linarith)
  have hcore := fork_gap_core hu0 hu4 hL1 hL2
  have hg : gch n * n ^ 2 - (1 / Real.log 2 - 1)
      = ((1 - 1 / n ^ 2) * (-Real.log (1 - 1 / n ^ 2)) / (1 / n ^ 2) - 1) / Real.log 2 := by
    simp only [gch, lb, Real.logb]; field_simp; ring
  rw [hg, abs_div, abs_of_pos log_two_pos, div_le_div_iff₀ log_two_pos (by positivity)]
  have h2 : 2 * (1 / n ^ 2) * (n * Real.log 2) ≤ 1 * Real.log 2 := by
    have heq : 2 * (1 / n ^ 2) * (n * Real.log 2) = (2 / n) * Real.log 2 := by field_simp
    rw [heq]
    have h2n : 2 / n ≤ 1 := by rw [div_le_one hn0]; linarith
    nlinarith [log_two_pos]
  calc |(1 - 1 / n ^ 2) * (-Real.log (1 - 1 / n ^ 2)) / (1 / n ^ 2) - 1| * (n * Real.log 2)
      ≤ (2 * (1 / n ^ 2)) * (n * Real.log 2) :=
        mul_le_mul_of_nonneg_right hcore (by positivity)
    _ ≤ 1 * Real.log 2 := h2

/-- Rate estimate for the reverse channel. -/
lemma Rch_bound {n : ℝ} (hn : 4 ≤ n) :
    |Rch n * n ^ 2 - 2 / Real.log 2| ≤ 16 / (n * Real.log 2) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hnsq : (0:ℝ) < n ^ 2 := by positivity
  have hlog : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have hv0 : (0:ℝ) < 4 / n ^ 2 := by positivity
  have hv4 : 4 / n ^ 2 ≤ 1 / 4 := by
    rw [div_le_div_iff₀ hnsq (by norm_num)]; nlinarith
  have hL1 : 4 / n ^ 2 ≤ -Real.log (1 - 4 / n ^ 2) := neg_log_one_sub_ge (by linarith)
  have hL2 : -Real.log (1 - 4 / n ^ 2) ≤ 4 / n ^ 2 + 2 * (4 / n ^ 2) ^ 2 :=
    neg_log_one_sub_le (by linarith)
  have hcore := fork_rev_core hv0 hL1 hL2
  have hg : Rch n * n ^ 2 - 2 / Real.log 2
      = (2 * (-Real.log (1 - 4 / n ^ 2) / (4 / n ^ 2) - 1)) / Real.log 2 := by
    simp only [Rch, lb, Real.logb]; field_simp; ring
  rw [hg, abs_div, abs_of_pos log_two_pos, div_le_div_iff₀ log_two_pos (by positivity)]
  have habs : |2 * (-Real.log (1 - 4 / n ^ 2) / (4 / n ^ 2) - 1)| ≤ 2 * (2 * (4 / n ^ 2)) := by
    rw [abs_mul, show |(2:ℝ)| = 2 from by norm_num]
    exact mul_le_mul_of_nonneg_left hcore (by norm_num)
  calc |2 * (-Real.log (1 - 4 / n ^ 2) / (4 / n ^ 2) - 1)| * (n * Real.log 2)
      ≤ (2 * (2 * (4 / n ^ 2))) * (n * Real.log 2) :=
        mul_le_mul_of_nonneg_right habs (by positivity)
    _ ≤ 16 * Real.log 2 := by
        have heq : (2 * (2 * (4 / n ^ 2))) * (n * Real.log 2) = (16 / n) * Real.log 2 := by
          field_simp; ring
        rw [heq]
        have h16 : 16 / n ≤ 16 := by rw [div_le_iff₀ hn0]; nlinarith
        nlinarith [log_two_pos]

/-- Rate estimate for the capacity channel. -/
lemma Xch_bound {n : ℝ} (hn : 4 ≤ n) :
    |Xch n * n ^ 2 - 2 / Real.log 2| ≤ 24 / (n * Real.log 2) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hnsq : (0:ℝ) < n ^ 2 := by positivity
  have hlog : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have hxabs : |2 / n| = 2 / n := abs_of_pos (by positivity)
  have hx : |2 / n| ≤ 1 / 2 := by
    rw [hxabs, div_le_div_iff₀ hn0 (by norm_num)]; linarith
  have hT := abs_forkF_sub_sq hx
  rw [hxabs] at hT
  have hg : Xch n * n ^ 2 - 2 / Real.log 2
      = (n ^ 2 * (forkF (2 / n) - (2 / n) ^ 2)) / (2 * Real.log 2) := by
    rw [Xch_eq_forkF (by linarith)]
    field_simp
  rw [hg, abs_div, abs_of_pos (by positivity : (0:ℝ) < 2 * Real.log 2),
    div_le_div_iff₀ (by positivity) (by positivity)]
  have h1 : |n ^ 2 * (forkF (2 / n) - (2 / n) ^ 2)| ≤ n ^ 2 * (6 * (2 / n) ^ 3) := by
    rw [abs_mul, abs_of_pos hnsq]
    exact mul_le_mul_of_nonneg_left hT (le_of_lt hnsq)
  calc |n ^ 2 * (forkF (2 / n) - (2 / n) ^ 2)| * (n * Real.log 2)
      ≤ (n ^ 2 * (6 * (2 / n) ^ 3)) * (n * Real.log 2) :=
        mul_le_mul_of_nonneg_right h1 (by positivity)
    _ = 48 * Real.log 2 := by field_simp; ring
    _ ≤ 24 * (2 * Real.log 2) := by linarith

/-- Convergence from a `C/n` error bound valid from some index on. -/
lemma tendsto_of_abs_le_const_div {f : ℕ → ℝ} {c C : ℝ} {N : ℕ}
    (h : ∀ n : ℕ, N ≤ n → |f n - c| ≤ C / n) : Tendsto f atTop (𝓝 c) := by
  rw [← tendsto_sub_nhds_zero_iff]
  refine squeeze_zero_norm' ?_ (tendsto_const_div_atTop_nhds_zero_nat C)
  filter_upwards [eventually_ge_atTop N] with n hn
  simpa [Real.norm_eq_abs] using h n hn

/-! ### The four exact constant laws -/

/-- **Law for `g`**: `g·n² → log₂ e - 1`. -/
theorem gch_mul_sq_tendsto :
    Tendsto (fun n : ℕ => gch n * (n : ℝ) ^ 2) atTop (𝓝 (1 / Real.log 2 - 1)) := by
  refine tendsto_of_abs_le_const_div (C := 1 / Real.log 2) (N := 2) ?_
  intro n hn
  have hn2 : (2:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hn0 : (0:ℝ) < (n : ℝ) := by linarith
  have := gch_bound hn2
  rwa [show (1 / Real.log 2) / (n : ℝ) = 1 / ((n : ℝ) * Real.log 2) from by
    rw [div_div, mul_comm]]

/-- **Law for `X`**: `X·n² → 2 log₂ e`. -/
theorem Xch_mul_sq_tendsto :
    Tendsto (fun n : ℕ => Xch n * (n : ℝ) ^ 2) atTop (𝓝 (2 / Real.log 2)) := by
  refine tendsto_of_abs_le_const_div (C := 24 / Real.log 2) (N := 4) ?_
  intro n hn
  have hn4 : (4:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have := Xch_bound hn4
  rwa [show (24 / Real.log 2) / (n : ℝ) = 24 / ((n : ℝ) * Real.log 2) from by
    rw [div_div, mul_comm]]

/-- **Law for `A`**: `A·n²/log₂ n = 1` exactly for `n ≥ 2`. -/
theorem Ach_scaled_eq_one {n : ℝ} (hn : 2 ≤ n) : Ach n * n ^ 2 / lb n = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  have hlb : 0 < lb n := by
    rw [lb]; exact Real.logb_pos (by norm_num) (by linarith)
  have hnsq : (n : ℝ) ^ 2 ≠ 0 := by positivity
  rw [Ach, div_mul_cancel₀ _ hnsq, div_self (ne_of_gt hlb)]

/-- **Law for `A`**, limit form. -/
theorem Ach_scaled_tendsto :
    Tendsto (fun n : ℕ => Ach n * (n : ℝ) ^ 2 / lb n) atTop (𝓝 1) := by
  refine Tendsto.congr' ?_ tendsto_const_nhds
  filter_upwards [eventually_ge_atTop 2] with n hn
  have hn2 : (2:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  exact (Ach_scaled_eq_one hn2).symm

/-- **Law for `Is - A`**: `(Is - A)·n² → 2 log₂ e`. -/
theorem Isch_sub_Ach_mul_sq_tendsto :
    Tendsto (fun n : ℕ => (Isch n - Ach n) * (n : ℝ) ^ 2) atTop (𝓝 (2 / Real.log 2)) := by
  refine tendsto_of_abs_le_const_div (C := 16 / Real.log 2) (N := 4) ?_
  intro n hn
  have hn4 : (4:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hIs : Isch (n : ℝ) - Ach (n : ℝ) = Rch (n : ℝ) := by simp [Isch]
  rw [hIs]
  have := Rch_bound hn4
  rwa [show (16 / Real.log 2) / (n : ℝ) = 16 / ((n : ℝ) * Real.log 2) from by
    rw [div_div, mul_comm]]

/-- **Ratio law**: `X/g → 2/(1 - log 2) = 6.51778…`. -/
theorem Xch_div_gch_tendsto :
    Tendsto (fun n : ℕ => Xch n / gch n) atTop (𝓝 (2 / (1 - Real.log 2))) := by
  have hlog : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have hden : 1 / Real.log 2 - 1 ≠ 0 := by
    have h1 : 1 < 1 / Real.log 2 := by
      rw [lt_div_iff₀ log_two_pos]; linarith [log_two_lt_one]
    linarith
  have hlim := Xch_mul_sq_tendsto.div gch_mul_sq_tendsto hden
  have hval : (2 / Real.log 2) / (1 / Real.log 2 - 1) = 2 / (1 - Real.log 2) := by
    have h1 : 1 - Real.log 2 ≠ 0 := by linarith [log_two_lt_one]
    field_simp
  rw [hval] at hlim
  refine Tendsto.congr' ?_ hlim
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hn0 : (n : ℝ) ≠ 0 := by
    have : 1 ≤ n := hn
    positivity
  have hsq : ((n : ℝ) ^ 2) ≠ 0 := pow_ne_zero 2 hn0
  simp only [Pi.div_apply]
  rw [mul_comm (Xch (n : ℝ)), mul_comm (gch (n : ℝ)), mul_div_mul_left _ _ hsq]

/-- The ratio limit exceeds `6`; in particular the pre-data guess `X/g → 2` is false. -/
theorem Xch_div_gch_not_tendsto_two :
    ¬ Tendsto (fun n : ℕ => Xch n / gch n) atTop (𝓝 2) := by
  intro h
  have heq := tendsto_nhds_unique h Xch_div_gch_tendsto
  have h1 : 1 - Real.log 2 ≠ 0 := by linarith [log_two_lt_one]
  rw [eq_div_iff h1] at heq
  have := log_two_pos
  nlinarith

/-- **Domination law**: since `A·n² = log₂ n` grows while `X·n² → 2 log₂ e` stays bounded,
the ambiguity channel eventually dwarfs the capacity channel: `A/X → ∞`. -/
theorem Ach_div_Xch_tendsto_atTop :
    Tendsto (fun n : ℕ => Ach n / Xch n) atTop atTop := by
  have hlb : Tendsto (fun n : ℕ => lb (n : ℝ)) atTop atTop :=
    (Real.tendsto_logb_atTop (b := 2) (by norm_num)).comp tendsto_natCast_atTop_atTop
  have hne : (2 / Real.log 2) ≠ 0 := by positivity
  have hinv : Tendsto (fun n : ℕ => (Xch (n : ℝ) * (n : ℝ) ^ 2)⁻¹) atTop
      (𝓝 (Real.log 2 / 2)) := by
    have h := Xch_mul_sq_tendsto.inv₀ hne
    rwa [inv_div] at h
  have hmul := Filter.Tendsto.atTop_mul_pos
    (show (0:ℝ) < Real.log 2 / 2 from by positivity) hlb hinv
  refine hmul.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hn0 : (n : ℝ) ≠ 0 := by
    have : 1 ≤ n := hn
    positivity
  rw [Ach, div_div, mul_comm ((n : ℝ) ^ 2) (Xch (n : ℝ)), ← div_eq_mul_inv]

/-! ### Collapse values at `n = 2` and the `A/X` sign flip -/

theorem Xch_two : Xch 2 = 1 := by
  rw [Xch, show (1:ℝ) / 2 + 1 / 2 = 1 from by norm_num, binEnt]
  simp [lb]

theorem Ach_two : Ach 2 = 1 / 4 := by
  have h : lb (2:ℝ) = 1 := by rw [lb]; simp [Real.logb_self_eq_one]
  rw [Ach, h]
  norm_num

theorem gch_two : gch 2 = 5 / 4 - (3 / 4) * lb 3 := by
  have h4 : lb (4:ℝ) = 2 := by
    rw [lb, show (4:ℝ) = 2 ^ (2:ℕ) from by norm_num, Real.logb_pow]
    simp [Real.logb_self_eq_one]
  have h34 : lb ((3:ℝ) / 4) = lb 3 - 2 := by
    rw [lb, lb] at *
    rw [Real.logb_div (by norm_num) (by norm_num), h4]
  rw [gch, show (1:ℝ) - 1 / 2 ^ 2 = 3 / 4 from by norm_num, h34]
  ring

/-- Integer certificate for the `n = 7` side of the sign flip: `7^100 < 3^126·5^35`. -/
lemma log_ineq_seven : (100:ℝ) * Real.log 7 < 126 * Real.log 3 + 35 * Real.log 5 := by
  have h : ((7:ℝ) ^ (100:ℕ)) < (3:ℝ) ^ (126:ℕ) * 5 ^ (35:ℕ) := by norm_num
  have hl := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_mul (by positivity) (by positivity), Real.log_pow,
    Real.log_pow] at hl
  push_cast at hl
  linarith

/-- Integer certificate for the `n = 8` side of the sign flip: `5^40·3^24 < 2^131`. -/
lemma log_ineq_eight : (40:ℝ) * Real.log 5 + 24 * Real.log 3 < 131 * Real.log 2 := by
  have h : ((5:ℝ) ^ (40:ℕ)) * 3 ^ (24:ℕ) < (2:ℝ) ^ (131:ℕ) := by norm_num
  have hl := Real.log_lt_log (by positivity) h
  rw [Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow,
    Real.log_pow] at hl
  push_cast at hl
  linarith

theorem Ach_seven_lt_Xch_seven : Ach 7 < Xch 7 := by
  have hlog := log_two_pos
  have h97 : Real.log ((9:ℝ) / 7) = 2 * Real.log 3 - Real.log 7 := by
    rw [Real.log_div (by norm_num) (by norm_num),
      show (9:ℝ) = 3 ^ (2:ℕ) from by norm_num, Real.log_pow]
    push_cast; ring
  have h57 : Real.log ((5:ℝ) / 7) = Real.log 5 - Real.log 7 :=
    Real.log_div (by norm_num) (by norm_num)
  have hfork : forkF ((2:ℝ) / 7)
      = (9 / 7) * (2 * Real.log 3 - Real.log 7) + (5 / 7) * (Real.log 5 - Real.log 7) := by
    rw [forkF, show (1:ℝ) + 2 / 7 = 9 / 7 from by norm_num,
      show (1:ℝ) - 2 / 7 = 5 / 7 from by norm_num, h97, h57]
  rw [Ach, lb, Real.logb, Xch_eq_forkF (by norm_num), hfork,
    div_lt_div_iff₀ (by positivity) (by positivity),
    show Real.log 7 / Real.log 2 * (2 * Real.log 2) = 2 * Real.log 7 from by
      field_simp]
  linarith [log_ineq_seven]

theorem Xch_eight_lt_Ach_eight : Xch 8 < Ach 8 := by
  have hlog := log_two_pos
  have h54 : Real.log ((5:ℝ) / 4) = Real.log 5 - 2 * Real.log 2 := by
    rw [Real.log_div (by norm_num) (by norm_num),
      show (4:ℝ) = 2 ^ (2:ℕ) from by norm_num, Real.log_pow]
    push_cast; ring
  have h34 : Real.log ((3:ℝ) / 4) = Real.log 3 - 2 * Real.log 2 := by
    rw [Real.log_div (by norm_num) (by norm_num),
      show (4:ℝ) = 2 ^ (2:ℕ) from by norm_num, Real.log_pow]
    push_cast; ring
  have hfork : forkF ((2:ℝ) / 8)
      = (5 / 4) * (Real.log 5 - 2 * Real.log 2) + (3 / 4) * (Real.log 3 - 2 * Real.log 2) := by
    rw [forkF, show (1:ℝ) + 2 / 8 = 5 / 4 from by norm_num,
      show (1:ℝ) - 2 / 8 = 3 / 4 from by norm_num, h54, h34]
  have hlb8 : lb (8:ℝ) = 3 := by
    rw [lb, show (8:ℝ) = 2 ^ (3:ℕ) from by norm_num, Real.logb_pow]
    simp [Real.logb_self_eq_one]
  rw [Ach, hlb8, Xch_eq_forkF (by norm_num), hfork,
    div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith [log_ineq_eight]

end

end Catalog.Combinatorics.ForkChannel