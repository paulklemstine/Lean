/-
# Sturmian structure of the binomial argmax staircase

Companion to `Shared.UnimodalArgmaxBinomial`, where it is proved that the upper
bracketing degree (the largest maximiser) of the binomial weights
`C(n,k) p^k q^(n-k)` is `⌊(n+1) p/(p+q)⌋`.

Writing `α = p/(p+q) ∈ (0,1)` this says that the *argmax staircase*

`S α n = ⌊(n+1) α⌋`

is a Beatty sequence, evaluated at the shifted index `n+1`.  This file studies the
*increment word* of the staircase,

`w α n = S α (n+1) - S α n ∈ {0,1}`,

and shows that it is the lower mechanical (Sturmian) word of slope `α` **shifted by
one letter** — the extra arithmetic carried by the `+1` in `(n+1)α`.

## Main results

* `lastArgmax_eq_staircase` — the catalog bracketing degree is the staircase.
* `staircase_eq_beattySeq` — the staircase is mathlib's Beatty sequence `beattySeq`
  at index `n+1`.
* `incWord_eq_zero_or_one`, `staircase_succ` — the increment word is a binary word.
* `incWord_eq_mechanical_succ`, `incWord_ne_mechanical_zero` — the increment word is
  the *shift* of the mechanical word of slope `α`, and genuinely differs from it:
  the staircase word is Sturmian only after the `+1` shift is accounted for.
* `windowSum_bounds`, `staircase_balanced` — the word is **balanced**: any two
  factors of the same length have letter sums differing by at most `1`.
* `windowSum_sub_slope_abs_lt` — uniformly bounded discrepancy, i.e. the frequency
  of the letter `1` is exactly `α`.
* `incWord_periodic_of_rat`, `incWord_periodic_iff_not_irrational` — the
  Morse–Hedlund dichotomy for the staircase: the increment word is periodic iff the
  slope is rational; for irrational slope the word is aperiodic.
* `incWord_ones_per_period` — for the binomial slope `P/(P+Q)` the word has period
  `P+Q` carrying exactly `P` ones.
* `complexity_pigeonhole`, `factorSet_ncard_le` — **subword complexity ≤ L+1**: among
  any `L+2` positions two carry the same factor of length `L`.
* `factorSet_ncard_le_period` — for a rational binomial slope the complexity is also
  capped by the period `P+Q`.
* `lastArgmax_succ` — the binomial mode advances by exactly one letter of the word.
* `tendsto_windowSum_div` — the frequency of the letter `1` converges to `α`.
* `both_letters_occur` — both letters occur for every slope in `(0,1)`.
-/
import Mathlib
import Shared.UnimodalArgmaxBinomial

namespace Shared
namespace SturmianArgmax

open Shared.UnimodalArgmaxBracketing

/-! ## The staircase and its increment word -/

/-- The slope attached to the binomial weights: `α = p/(p+q)`. -/
noncomputable def slope (p q : ℝ) : ℝ := p / (p + q)

/-- The **argmax staircase** of slope `α`: `S α n = ⌊(n+1) α⌋`. -/
noncomputable def staircase (α : ℝ) (n : ℕ) : ℤ := ⌊((n : ℝ) + 1) * α⌋

/-- The **increment word** of the staircase, `w α n = S α (n+1) - S α n`. -/
noncomputable def incWord (α : ℝ) (n : ℕ) : ℤ := staircase α (n + 1) - staircase α n

/-- The lower **mechanical word** of slope `α`: `s α m = ⌊(m+1)α⌋ - ⌊mα⌋`. -/
noncomputable def mechanical (α : ℝ) (m : ℕ) : ℤ := ⌊((m : ℝ) + 1) * α⌋ - ⌊(m : ℝ) * α⌋

variable {α : ℝ}

theorem modeParameter_eq_slope (n : ℕ) (p q : ℝ) :
    modeParameter n p q = ((n : ℝ) + 1) * slope p q := by
  rw [modeParameter, slope, mul_div_assoc]

/-- **The catalog bracketing degree is the staircase.**  The largest maximiser of the
binomial weights of row `n` is `⌊(n+1)α⌋` with `α = p/(p+q)`. -/
theorem lastArgmax_eq_staircase {n : ℕ} {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    lastArgmax n (binomialWeight n p q) = (staircase (slope p q) n).toNat := by
  rw [binomialWeight_lastArgmax hp hq, modeParameter_eq_slope, staircase, Int.floor_toNat]

/-- The staircase is mathlib's Beatty sequence of slope `α`, read at index `n+1`. -/
theorem staircase_eq_beattySeq (α : ℝ) (n : ℕ) :
    staircase α n = beattySeq α ((n : ℤ) + 1) := by
  simp [staircase, beattySeq]

theorem staircase_succ (α : ℝ) (n : ℕ) : staircase α (n + 1) = staircase α n + incWord α n := by
  simp [incWord]

theorem slope_pos {p q : ℝ} (hp : 0 < p) (hq : 0 < q) : 0 < slope p q := by
  rw [slope]
  positivity

theorem slope_lt_one {p q : ℝ} (hp : 0 < p) (hq : 0 < q) : slope p q < 1 := by
  rw [slope, div_lt_one (by linarith)]
  linarith

theorem staircase_nonneg {α : ℝ} (hα : 0 ≤ α) (n : ℕ) : 0 ≤ staircase α n := by
  rw [staircase, Int.le_floor]
  push_cast
  positivity

/-! ## The increment word is binary -/

/-- Unfolding the staircase one step: `S α (n+1) = ⌊(n+1)α + α⌋`. -/
theorem staircase_succ_eq (α : ℝ) (n : ℕ) :
    staircase α (n + 1) = ⌊((n : ℝ) + 1) * α + α⌋ := by
  simp only [staircase]
  push_cast
  ring_nf

/-- The increment word as a floor difference of a single real step. -/
theorem incWord_eq_floor_step (α : ℝ) (n : ℕ) :
    incWord α n = ⌊((n : ℝ) + 1) * α + α⌋ - ⌊((n : ℝ) + 1) * α⌋ := by
  rw [incWord, staircase_succ_eq, staircase]

theorem incWord_nonneg (hα : 0 ≤ α) (n : ℕ) : 0 ≤ incWord α n := by
  rw [incWord_eq_floor_step, sub_nonneg]
  exact Int.floor_le_floor (by linarith)

theorem incWord_le_one (hα : α ≤ 1) (n : ℕ) : incWord α n ≤ 1 := by
  rw [incWord_eq_floor_step, sub_le_iff_le_add]
  have h2 : ⌊((n : ℝ) + 1) * α + α⌋ ≤ ⌊((n : ℝ) + 1) * α + 1⌋ :=
    Int.floor_le_floor (by linarith)
  have : ⌊((n : ℝ) + 1) * α + 1⌋ = ⌊((n : ℝ) + 1) * α⌋ + 1 := by
    exact_mod_cast Int.floor_add_one _
  omega

theorem incWord_eq_zero_or_one (h0 : 0 ≤ α) (h1 : α ≤ 1) (n : ℕ) :
    incWord α n = 0 ∨ incWord α n = 1 := by
  have := incWord_nonneg h0 n
  have := incWord_le_one h1 n
  omega

/-- **The binomial mode advances by exactly one Sturmian letter.**  Going from row `n` to
row `n+1` of the binomial weights, the largest maximiser increases by the letter
`w α n ∈ {0,1}` of the staircase word of slope `α = p/(p+q)`. -/
theorem lastArgmax_succ {n : ℕ} {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    lastArgmax (n + 1) (binomialWeight (n + 1) p q)
      = lastArgmax n (binomialWeight n p q) + (incWord (slope p q) n).toNat := by
  have hα0 : 0 < slope p q := slope_pos hp hq
  have h1 := staircase_nonneg hα0.le (α := slope p q) n
  have h2 := incWord_nonneg (α := slope p q) hα0.le n
  rw [lastArgmax_eq_staircase hp hq, lastArgmax_eq_staircase hp hq,
    staircase_succ (slope p q) n]
  omega

/-! ## Window sums: balance and letter frequency -/

/-- The sum of the `L` letters of the increment word starting at position `m`, i.e. the
total rise of the argmax staircase across the window `[m, m+L)`. -/
noncomputable def windowSum (α : ℝ) (m L : ℕ) : ℤ := ∑ i ∈ Finset.range L, incWord α (m + i)

/-- Telescoping: a window sum is a difference of staircase values. -/
theorem windowSum_eq (α : ℝ) (m L : ℕ) :
    windowSum α m L = staircase α (m + L) - staircase α m := by
  induction L with
  | zero => simp [windowSum]
  | succ L ih =>
      rw [windowSum, Finset.sum_range_succ, ← windowSum, ih,
        show m + (L + 1) = (m + L) + 1 from rfl, staircase_succ]
      ring

/-- Superadditivity/subadditivity of the floor function. -/
theorem floor_add_sandwich (x y : ℝ) :
    ⌊x⌋ + ⌊y⌋ ≤ ⌊x + y⌋ ∧ ⌊x + y⌋ ≤ ⌊x⌋ + ⌊y⌋ + 1 := by
  constructor
  · refine Int.le_floor.2 ?_
    push_cast
    have := Int.floor_le x
    have := Int.floor_le y
    linarith
  · have h : ⌊x + y⌋ < ⌊x⌋ + ⌊y⌋ + 2 := by
      refine Int.floor_lt.2 ?_
      push_cast
      have := Int.lt_floor_add_one x
      have := Int.lt_floor_add_one y
      linarith
    omega

/-- The staircase over a window of length `L`, written with the fractional shift made
explicit. -/
theorem staircase_add_eq (α : ℝ) (m L : ℕ) :
    staircase α (m + L) = ⌊((m : ℝ) + 1) * α + (L : ℝ) * α⌋ := by
  simp only [staircase]
  push_cast
  ring_nf

/-- **Two-sided bound for every window sum.**  Every factor of length `L` of the
increment word has letter sum `⌊Lα⌋` or `⌊Lα⌋ + 1`, independently of the position. -/
theorem windowSum_bounds (α : ℝ) (m L : ℕ) :
    ⌊(L : ℝ) * α⌋ ≤ windowSum α m L ∧ windowSum α m L ≤ ⌊(L : ℝ) * α⌋ + 1 := by
  have h := floor_add_sandwich (((m : ℝ) + 1) * α) ((L : ℝ) * α)
  rw [windowSum_eq, staircase_add_eq, staircase]
  omega

/-- **The increment word of the argmax staircase is balanced.**  Any two factors of the
same length have letter sums differing by at most one. -/
theorem staircase_balanced (α : ℝ) (m m' L : ℕ) :
    |windowSum α m L - windowSum α m' L| ≤ 1 := by
  have h1 := windowSum_bounds α m L
  have h2 := windowSum_bounds α m' L
  rw [abs_le]
  omega

/-- **Bounded discrepancy.**  The number of `1`s in any window of length `L` differs
from `Lα` by less than `2`; hence the letter `1` has frequency exactly `α`. -/
theorem windowSum_sub_slope_abs_lt (α : ℝ) (m L : ℕ) :
    |(windowSum α m L : ℝ) - (L : ℝ) * α| < 2 := by
  obtain ⟨hlo, hhi⟩ := windowSum_bounds α m L
  have h1 : ((⌊(L : ℝ) * α⌋ : ℤ) : ℝ) ≤ (L : ℝ) * α := Int.floor_le _
  have h2 : (L : ℝ) * α < (⌊(L : ℝ) * α⌋ : ℝ) + 1 := Int.lt_floor_add_one _
  have hlo' : ((⌊(L : ℝ) * α⌋ : ℤ) : ℝ) ≤ (windowSum α m L : ℝ) := by exact_mod_cast hlo
  have hhi' : (windowSum α m L : ℝ) ≤ ((⌊(L : ℝ) * α⌋ : ℤ) : ℝ) + 1 := by exact_mod_cast hhi
  rw [abs_lt]
  constructor <;> linarith

/-! ## Periodicity: the Morse–Hedlund dichotomy for the argmax staircase -/

/-- If `Tα` is an integer `c`, the staircase satisfies the exact quasi-period relation
`S α (n + T) = S α n + c`. -/
theorem staircase_add_of_int_mul {T : ℕ} {c : ℤ} (h : (T : ℝ) * α = (c : ℝ)) (n : ℕ) :
    staircase α (n + T) = staircase α n + c := by
  rw [staircase_add_eq, h, staircase, Int.floor_add_intCast]

/-- If `Tα` is an integer the increment word is periodic with period `T`. -/
theorem incWord_periodic_of_int_mul {T : ℕ} {c : ℤ} (h : (T : ℝ) * α = (c : ℝ)) (n : ℕ) :
    incWord α (n + T) = incWord α n := by
  have h1 := staircase_add_of_int_mul h n
  have h2 := staircase_add_of_int_mul h (n + 1)
  simp only [incWord]
  rw [show n + T + 1 = (n + 1) + T from by ring, h2, h1]
  ring

/-- For a rational slope the increment word is periodic, with period the denominator. -/
theorem incWord_periodic_of_rat (q : ℚ) (n : ℕ) :
    incWord (q : ℝ) (n + q.den) = incWord (q : ℝ) n := by
  refine incWord_periodic_of_int_mul (c := q.num) ?_ n
  have hden : ((q.den : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 q.den_nz
  rw [Rat.cast_def]
  field_simp

/-- A period of the increment word forces the staircase to be exactly quasi-periodic. -/
theorem staircase_sub_of_periodic {T : ℕ}
    (h : ∀ n, incWord α (n + T) = incWord α n) (n : ℕ) :
    staircase α (n + T) - staircase α n = staircase α T - staircase α 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have e1 : (n + 1) + T = (n + T) + 1 := by ring
      rw [e1, staircase_succ, staircase_succ, h n]
      omega

/-- Iterating a period: `S α (kT) = S α 0 + k (S α T - S α 0)`. -/
theorem staircase_mul_period {T : ℕ} (h : ∀ n, incWord α (n + T) = incWord α n) (k : ℕ) :
    staircase α (k * T) = staircase α 0 + k * (staircase α T - staircase α 0) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have e : (k + 1) * T = k * T + T := by ring
      have hstep := staircase_sub_of_periodic h (k * T)
      rw [e]
      push_cast
      push_cast at ih
      linarith

/-- **A period pins the slope.**  If the increment word has period `T` then `Tα` is an
integer, namely the number of `1`s in one period. -/
theorem slope_mul_period_eq_int {T : ℕ}
    (h : ∀ n, incWord α (n + T) = incWord α n) :
    (T : ℝ) * α = ((staircase α T - staircase α 0 : ℤ) : ℝ) := by
  have key : ∀ k : ℕ,
      ((staircase α 0 : ℤ) : ℝ) ≤ (k : ℝ) * ((T : ℝ) * α - ((staircase α T - staircase α 0 : ℤ) : ℝ)) + α ∧
      (k : ℝ) * ((T : ℝ) * α - ((staircase α T - staircase α 0 : ℤ) : ℝ)) + α
        < ((staircase α 0 : ℤ) : ℝ) + 1 := by
    intro k
    have hstair := staircase_mul_period h k
    have hcast : ((staircase α (k * T) : ℤ) : ℝ)
        = ((staircase α 0 : ℤ) : ℝ)
          + (k : ℝ) * ((staircase α T - staircase α 0 : ℤ) : ℝ) := by
      rw [hstair]
      push_cast
      ring
    have hval : (((k * T : ℕ) : ℝ) + 1) * α
        = (k : ℝ) * ((staircase α T - staircase α 0 : ℤ) : ℝ)
          + ((k : ℝ) * ((T : ℝ) * α - ((staircase α T - staircase α 0 : ℤ) : ℝ)) + α) := by
      push_cast
      ring
    have h1 : ((staircase α (k * T) : ℤ) : ℝ) ≤ (((k * T : ℕ) : ℝ) + 1) * α := by
      simpa only [staircase] using Int.floor_le ((((k * T : ℕ) : ℝ) + 1) * α)
    have h2 : (((k * T : ℕ) : ℝ) + 1) * α < ((staircase α (k * T) : ℤ) : ℝ) + 1 := by
      simpa only [staircase] using Int.lt_floor_add_one ((((k * T : ℕ) : ℝ) + 1) * α)
    rw [hcast, hval] at h1 h2
    exact ⟨by linarith, by linarith⟩
  -- if `d ≠ 0`, the quantity `k d` escapes the bounded interval `[s - α, s + 1 - α)`
  by_contra hne
  rcases lt_trichotomy ((T : ℝ) * α - ((staircase α T - staircase α 0 : ℤ) : ℝ)) 0 with
    hneg | hzero | hpos
  · obtain ⟨k, hk⟩ := exists_nat_gt ((α - ((staircase α 0 : ℤ) : ℝ)) /
      (-((T : ℝ) * α - ((staircase α T - staircase α 0 : ℤ) : ℝ))))
    rw [div_lt_iff₀ (by linarith)] at hk
    have := (key k).1
    nlinarith
  · exact hne (by linarith)
  · obtain ⟨k, hk⟩ := exists_nat_gt ((((staircase α 0 : ℤ) : ℝ) + 1 - α) /
      ((T : ℝ) * α - ((staircase α T - staircase α 0 : ℤ) : ℝ)))
    rw [div_lt_iff₀ hpos] at hk
    have := (key k).2
    nlinarith

/-- **Morse–Hedlund dichotomy for the argmax staircase.**  The increment word of the
staircase is periodic exactly when the slope is rational; for irrational slope it is
aperiodic. -/
theorem incWord_periodic_iff_not_irrational (α : ℝ) :
    (∃ T : ℕ, 0 < T ∧ ∀ n, incWord α (n + T) = incWord α n) ↔ ¬ Irrational α := by
  constructor
  · rintro ⟨T, hT, h⟩
    have hTα := slope_mul_period_eq_int h
    set c : ℤ := staircase α T - staircase α 0
    have hTne : ((T : ℝ)) ≠ 0 := by positivity
    have hα : α = ((c : ℚ) / (T : ℚ) : ℚ) := by
      have : α = (c : ℝ) / (T : ℝ) := by
        field_simp at hTα ⊢
        linarith [hTα]
      rw [this]
      push_cast
      ring
    rw [hα]
    exact Rat.not_irrational _
  · intro h
    rw [Irrational, not_not] at h
    obtain ⟨q, rfl⟩ := h
    exact ⟨q.den, q.pos, fun n => incWord_periodic_of_rat q n⟩

/-- For irrational slope the increment word of the argmax staircase is aperiodic. -/
theorem incWord_aperiodic (hα : Irrational α) {T : ℕ} (hT : 0 < T) :
    ∃ n, incWord α (n + T) ≠ incWord α n := by
  by_contra hcon
  push_neg at hcon
  exact (incWord_periodic_iff_not_irrational α).1 ⟨T, hT, hcon⟩ hα

/-! ## The binomial slope: exact period and exact number of ones -/

theorem slope_period_mul {P Q : ℕ} (hPQ : 0 < P + Q) :
    ((P + Q : ℕ) : ℝ) * slope (P : ℝ) (Q : ℝ) = ((P : ℤ) : ℝ) := by
  have h : ((P : ℝ) + (Q : ℝ)) ≠ 0 := by
    have : (0 : ℝ) < (P : ℝ) + (Q : ℝ) := by
      have : (0 : ℝ) < ((P + Q : ℕ) : ℝ) := by exact_mod_cast hPQ
      push_cast at this ⊢
      linarith
    linarith
  rw [slope]
  push_cast
  field_simp

/-- For the binomial slope `P/(P+Q)` the increment word has period `P + Q`. -/
theorem incWord_periodic_slope {P Q : ℕ} (hPQ : 0 < P + Q) (n : ℕ) :
    incWord (slope (P : ℝ) (Q : ℝ)) (n + (P + Q)) = incWord (slope (P : ℝ) (Q : ℝ)) n :=
  incWord_periodic_of_int_mul (slope_period_mul hPQ) n

/-- **Exactly `P` peaks-shifts per period.**  Every window of length `P + Q` of the
increment word of the binomial argmax staircase contains exactly `P` ones. -/
theorem incWord_ones_per_period {P Q : ℕ} (hPQ : 0 < P + Q) (m : ℕ) :
    windowSum (slope (P : ℝ) (Q : ℝ)) m (P + Q) = (P : ℤ) := by
  rw [windowSum_eq, staircase_add_of_int_mul (slope_period_mul hPQ) m]
  ring

/-! ## The `+1` shift: the staircase word is the mechanical word, shifted -/

/-- **The increment word is the shift of the mechanical word of slope `α`.**  This is the
precise sense in which the binomial argmax staircase is Sturmian. -/
theorem incWord_eq_mechanical_succ (α : ℝ) (n : ℕ) : incWord α n = mechanical α (n + 1) := by
  simp only [incWord, mechanical, staircase]
  push_cast
  ring_nf

/-- **…but it is not literally the mechanical word.**  For every slope in `[1/2, 1)` the
staircase word and the mechanical word already differ in their first letter: the `+1`
shift in `⌊(n+1)α⌋` is genuinely visible. -/
theorem incWord_ne_mechanical_zero (h : 1 / 2 ≤ α) (h1 : α < 1) :
    incWord α 0 ≠ mechanical α 0 := by
  have hfl0 : ⌊α⌋ = 0 := Int.floor_eq_zero_iff.2 (Set.mem_Ico.2 ⟨by linarith, by linarith⟩)
  have hfl2 : ⌊α + α⌋ = 1 := by
    rw [Int.floor_eq_iff]
    constructor <;> push_cast <;> linarith
  have hmech : mechanical α 0 = 0 := by simp [mechanical, hfl0]
  have hinc : incWord α 0 = 1 := by
    have e : incWord α 0 = ⌊α + α⌋ - ⌊α⌋ := by rw [incWord_eq_floor_step]; norm_num
    rw [e, hfl2, hfl0]
    norm_num
  rw [hinc, hmech]
  norm_num

/-! ## Both letters occur -/

theorem exists_incWord_eq_one (h0 : 0 < α) (h1 : α ≤ 1) : ∃ n, incWord α n = 1 := by
  by_contra hcon
  push_neg at hcon
  have hzero : ∀ n, incWord α n = 0 := by
    intro n
    rcases incWord_eq_zero_or_one h0.le h1 n with h | h
    · exact h
    · exact absurd h (hcon n)
  obtain ⟨L, hL⟩ := exists_nat_gt (1 / α)
  have hsum : windowSum α 0 L = 0 := by
    simp [windowSum, hzero]
  have hbig : (1 : ℝ) < (L : ℝ) * α := by
    rw [div_lt_iff₀ h0] at hL
    linarith
  have := (windowSum_bounds α 0 L).1
  rw [hsum] at this
  have hfl : (1 : ℤ) ≤ ⌊(L : ℝ) * α⌋ := by
    rw [Int.le_floor]
    push_cast
    linarith
  omega

theorem exists_incWord_eq_zero (h0 : 0 ≤ α) (h1 : α < 1) : ∃ n, incWord α n = 0 := by
  by_contra hcon
  push_neg at hcon
  have hone : ∀ n, incWord α n = 1 := by
    intro n
    rcases incWord_eq_zero_or_one h0 h1.le n with h | h
    · exact absurd h (hcon n)
    · exact h
  obtain ⟨L, hL⟩ := exists_nat_gt (2 / (1 - α))
  have hsum : windowSum α 0 L = (L : ℤ) := by
    simp [windowSum, hone]
  have hbig : (2 : ℝ) < (L : ℝ) * (1 - α) := by
    rw [div_lt_iff₀ (by linarith : (0:ℝ) < 1 - α)] at hL
    linarith
  have hup := (windowSum_bounds α 0 L).2
  rw [hsum] at hup
  have hfl : ((⌊(L : ℝ) * α⌋ : ℤ) : ℝ) ≤ (L : ℝ) * α := Int.floor_le _
  have hup' : ((L : ℤ) : ℝ) ≤ ((⌊(L : ℝ) * α⌋ : ℤ) : ℝ) + 1 := by exact_mod_cast hup
  push_cast at hup'
  nlinarith

/-- **Both letters occur**: the staircase word of a slope in `(0,1)` is a genuinely
binary word, so it has exactly two factors of length one. -/
theorem both_letters_occur (h0 : 0 < α) (h1 : α < 1) :
    (∃ n, incWord α n = 0) ∧ (∃ n, incWord α n = 1) :=
  ⟨exists_incWord_eq_zero h0.le h1, exists_incWord_eq_one h0 h1.le⟩

/-- **The staircase word is never the mechanical word.**  For every slope in `(0,1)` the
increment word of the argmax staircase differs from the lower mechanical word of the same
slope at some position: the `+1` shift can never be undone. -/
theorem incWord_ne_mechanical (h0 : 0 < α) (h1 : α < 1) :
    ∃ n : ℕ, incWord α n ≠ mechanical α n := by
  by_contra hcon
  push_neg at hcon
  have hconst : ∀ n : ℕ, mechanical α (n + 1) = mechanical α n := by
    intro n
    rw [← incWord_eq_mechanical_succ, hcon n]
  have hzero : ∀ n : ℕ, mechanical α n = 0 := by
    intro n
    induction n with
    | zero => simp [mechanical, Int.floor_eq_zero_iff.2 (Set.mem_Ico.2 ⟨h0.le, h1⟩)]
    | succ n ih => rw [hconst n, ih]
  obtain ⟨n, hn⟩ := exists_incWord_eq_one h0 h1.le
  rw [incWord_eq_mechanical_succ, hzero (n + 1)] at hn
  exact absurd hn (by norm_num)

/-! ## Letter frequency: the density of `1`s is exactly the slope -/

/-- **The frequency of the letter `1` is `α`.**  The proportion of unit steps of the argmax
staircase in any window converges to the slope `α = p/(p+q)`. -/
theorem tendsto_windowSum_div (α : ℝ) (m : ℕ) :
    Filter.Tendsto (fun L : ℕ => (windowSum α m L : ℝ) / (L : ℝ)) Filter.atTop (nhds α) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨N, hN⟩ := exists_nat_gt (2 / ε)
  refine ⟨max N 1, fun L hL => ?_⟩
  have hL1 : 1 ≤ L := le_trans (le_max_right N 1) hL
  have hLN : (N : ℝ) ≤ (L : ℝ) := by exact_mod_cast le_trans (le_max_left N 1) hL
  have hL0 : (0 : ℝ) < (L : ℝ) := by exact_mod_cast hL1
  have hbd := windowSum_sub_slope_abs_lt α m L
  have hsplit : (windowSum α m L : ℝ) / (L : ℝ) - α
      = ((windowSum α m L : ℝ) - (L : ℝ) * α) / (L : ℝ) := by
    field_simp
  rw [Real.dist_eq, hsplit, abs_div, abs_of_pos hL0]
  rw [div_lt_iff₀ hL0]
  have h2 : 2 / ε < (L : ℝ) := lt_of_lt_of_le hN hLN
  rw [div_lt_iff₀ hε] at h2
  calc |(windowSum α m L : ℝ) - (L : ℝ) * α| < 2 := hbd
    _ < ε * (L : ℝ) := by linarith

/-! ## Subword complexity: at most `L + 1` factors of length `L`

The factor of length `L` read at position `m` is encoded by its prefix sums
`pref α m j = S α (m+j) - S α m`, and these depend on `m` only through the fractional
part `x_m = {(m+1)α}` via `pref α m j = ⌊x_m + jα⌋`.  Each of the `L` functions
`x ↦ ⌊x + jα⌋ - ⌊jα⌋` is monotone with values in `{0,1}`, so their sum `level` is a
monotone integer statistic taking at most `L+1` values which *determines* the factor. -/

/-- The prefix-sum profile of the factor of length `L` read at position `m`. -/
noncomputable def pref (α : ℝ) (m j : ℕ) : ℤ := staircase α (m + j) - staircase α m

theorem incWord_eq_pref_sub (α : ℝ) (m t : ℕ) :
    incWord α (m + t) = pref α m (t + 1) - pref α m t := by
  simp only [pref, incWord, show m + (t + 1) = (m + t) + 1 from rfl]
  ring

/-- The profile depends on the position only through the fractional part of `(m+1)α`. -/
theorem pref_eq_floor_fract (α : ℝ) (m j : ℕ) :
    pref α m j = ⌊Int.fract (((m : ℝ) + 1) * α) + (j : ℝ) * α⌋ := by
  have hu : ((m : ℝ) + 1) * α + (j : ℝ) * α
      = ((⌊((m : ℝ) + 1) * α⌋ : ℤ) : ℝ) + (Int.fract (((m : ℝ) + 1) * α) + (j : ℝ) * α) := by
    simp only [Int.fract]
    ring
  rw [pref, staircase_add_eq, hu, Int.floor_intCast_add, staircase]
  ring

theorem pref_mono_of_fract_le {α : ℝ} {m m' : ℕ}
    (h : Int.fract (((m : ℝ) + 1) * α) ≤ Int.fract (((m' : ℝ) + 1) * α)) (j : ℕ) :
    pref α m j ≤ pref α m' j := by
  rw [pref_eq_floor_fract, pref_eq_floor_fract]
  exact Int.floor_le_floor (by linarith)

/-- Each coordinate of the profile sits within one unit of the reference profile `⌊jα⌋`. -/
theorem pref_sub_floor_bounds (α : ℝ) (m j : ℕ) :
    0 ≤ pref α m j - ⌊(j : ℝ) * α⌋ ∧ pref α m j - ⌊(j : ℝ) * α⌋ ≤ 1 := by
  have h0 : (0 : ℝ) ≤ Int.fract (((m : ℝ) + 1) * α) := Int.fract_nonneg _
  have h1 : Int.fract (((m : ℝ) + 1) * α) < 1 := Int.fract_lt_one _
  rw [pref_eq_floor_fract]
  constructor
  · have : ⌊(j : ℝ) * α⌋ ≤ ⌊Int.fract (((m : ℝ) + 1) * α) + (j : ℝ) * α⌋ :=
      Int.floor_le_floor (by linarith)
    omega
  · have hle : ⌊Int.fract (((m : ℝ) + 1) * α) + (j : ℝ) * α⌋ ≤ ⌊(j : ℝ) * α + 1⌋ :=
      Int.floor_le_floor (by linarith)
    rw [Int.floor_add_one] at hle
    omega

theorem pref_zero (α : ℝ) (m : ℕ) : pref α m 0 = 0 := by simp [pref]

/-- The **level** of the position `m` for windows of length `L`: a monotone integer
statistic in `{0, …, L}` that determines the factor of length `L` read at `m`. -/
noncomputable def level (α : ℝ) (L m : ℕ) : ℤ :=
  ∑ j ∈ Finset.range (L + 1), (pref α m j - ⌊(j : ℝ) * α⌋)

theorem level_nonneg (α : ℝ) (L m : ℕ) : 0 ≤ level α L m :=
  Finset.sum_nonneg fun j _ => (pref_sub_floor_bounds α m j).1

theorem level_le (α : ℝ) (L m : ℕ) : level α L m ≤ (L : ℤ) := by
  rw [level, Finset.sum_range_succ']
  have h0 : pref α m 0 - ⌊((0 : ℕ) : ℝ) * α⌋ = 0 := by
    simp [pref_zero]
  rw [h0, add_zero]
  calc ∑ j ∈ Finset.range L, (pref α m (j + 1) - ⌊((j + 1 : ℕ) : ℝ) * α⌋)
      ≤ ∑ _j ∈ Finset.range L, (1 : ℤ) :=
        Finset.sum_le_sum fun j _ => (pref_sub_floor_bounds α m (j + 1)).2
    _ = (L : ℤ) := by simp

/-- **The level determines the factor.**  Two positions with the same level carry the
same prefix profile, hence the same factor. -/
theorem pref_eq_of_level_eq {α : ℝ} {L m m' : ℕ} (h : level α L m = level α L m')
    {j : ℕ} (hj : j ≤ L) : pref α m j = pref α m' j := by
  have main : ∀ a b : ℕ,
      Int.fract (((a : ℝ) + 1) * α) ≤ Int.fract (((b : ℝ) + 1) * α) →
      level α L a = level α L b → ∀ i ∈ Finset.range (L + 1), pref α a i = pref α b i := by
    intro a b hfr hlev i hi
    have hterm : ∀ i ∈ Finset.range (L + 1),
        pref α a i - ⌊(i : ℝ) * α⌋ ≤ pref α b i - ⌊(i : ℝ) * α⌋ := by
      intro i _
      have := pref_mono_of_fract_le hfr i
      omega
    have := (Finset.sum_eq_sum_iff_of_le hterm).1 hlev i hi
    omega
  have hj' : j ∈ Finset.range (L + 1) := Finset.mem_range.2 (by omega)
  rcases le_total (Int.fract (((m : ℝ) + 1) * α)) (Int.fract (((m' : ℝ) + 1) * α)) with hle | hle
  · exact main m m' hle h j hj'
  · exact (main m' m hle h.symm j hj').symm

/-- Two positions with the same level read the same factor of length `L`. -/
theorem incWord_eq_of_level_eq {α : ℝ} {L m m' : ℕ} (h : level α L m = level α L m')
    {t : ℕ} (ht : t < L) : incWord α (m + t) = incWord α (m' + t) := by
  rw [incWord_eq_pref_sub, incWord_eq_pref_sub,
    pref_eq_of_level_eq h (by omega : t + 1 ≤ L), pref_eq_of_level_eq h (by omega : t ≤ L)]

/-- **Subword complexity bound (pigeonhole form).**  Among any `L + 2` positions of the
argmax staircase, two read the same factor of length `L`; i.e. the increment word has at
most `L + 1` factors of length `L`. -/
theorem complexity_pigeonhole (α : ℝ) (L : ℕ) (f : Fin (L + 2) → ℕ) :
    ∃ i j : Fin (L + 2), i ≠ j ∧ ∀ t < L, incWord α (f i + t) = incWord α (f j + t) := by
  have hb : ∀ i : Fin (L + 2), (level α L (f i)).toNat < L + 1 := by
    intro i
    have h1 := level_nonneg α L (f i)
    have h2 := level_le α L (f i)
    omega
  obtain ⟨i, j, hij, hfij⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (L + 2) => (⟨_, hb i⟩ : Fin (L + 1)))
      (by simp)
  refine ⟨i, j, hij, fun t ht => ?_⟩
  have hlev : level α L (f i) = level α L (f j) := by
    have h1 := level_nonneg α L (f i)
    have h2 := level_nonneg α L (f j)
    have : (level α L (f i)).toNat = (level α L (f j)).toNat := congrArg Fin.val hfij
    omega
  exact incWord_eq_of_level_eq hlev ht

/-- The factor of length `L` read at position `m`, as a word supported on `[0, L)`. -/
noncomputable def factor (α : ℝ) (m L : ℕ) : ℕ → ℤ :=
  fun t => if t < L then incWord α (m + t) else 0

theorem factor_partial_sum {α : ℝ} {L : ℕ} (m : ℕ) {j : ℕ} (hj : j ≤ L) :
    ∑ t ∈ Finset.range j, factor α m L t = pref α m j := by
  induction j with
  | zero => simp [pref_zero]
  | succ j ih =>
      rw [Finset.sum_range_succ, ih (by omega), factor, if_pos (by omega : j < L),
        incWord_eq_pref_sub]
      ring

/-- **Subword complexity bound (set form).**  For every length `L`, the increment word of
the argmax staircase has at most `L + 1` distinct factors of length `L`; in particular the
word has linear (indeed sublinear-slope) complexity, in sharp contrast with a generic
binary sequence. -/
theorem factorSet_ncard_le (α : ℝ) (L : ℕ) :
    {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard ≤ L + 1 := by
  classical
  set φ : (ℕ → ℤ) → ℕ := fun w =>
    (∑ j ∈ Finset.range (L + 1), ((∑ t ∈ Finset.range j, w t) - ⌊(j : ℝ) * α⌋)).toNat with hφ
  have hval : ∀ m : ℕ, φ (factor α m L) = (level α L m).toNat := by
    intro m
    have : (∑ j ∈ Finset.range (L + 1),
        ((∑ t ∈ Finset.range j, factor α m L t) - ⌊(j : ℝ) * α⌋)) = level α L m := by
      refine Finset.sum_congr rfl fun j hj => ?_
      rw [factor_partial_sum m (by simpa [Nat.lt_succ_iff] using Finset.mem_range.1 hj)]
    rw [hφ]
    simp only
    rw [this]
  have hmaps : ∀ w ∈ {w : ℕ → ℤ | ∃ m, w = factor α m L}, φ w ∈ (↑(Finset.range (L + 1)) : Set ℕ) := by
    rintro w ⟨m, rfl⟩
    have h1 := level_nonneg α L m
    have h2 := level_le α L m
    simp only [Finset.coe_range, Set.mem_Iio, hval m]
    omega
  have hinj : Set.InjOn φ {w : ℕ → ℤ | ∃ m, w = factor α m L} := by
    rintro w1 ⟨m1, rfl⟩ w2 ⟨m2, rfl⟩ hEq
    rw [hval m1, hval m2] at hEq
    have hlev : level α L m1 = level α L m2 := by
      have h1 := level_nonneg α L m1
      have h2 := level_nonneg α L m2
      omega
    funext t
    by_cases ht : t < L
    · simp only [factor, if_pos ht]
      exact incWord_eq_of_level_eq hlev ht
    · simp [factor, ht]
  have hcard : ((↑(Finset.range (L + 1)) : Set ℕ)).ncard = L + 1 := by
    simp [Set.ncard_eq_toFinset_card']
  calc {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard
      ≤ ((↑(Finset.range (L + 1)) : Set ℕ)).ncard :=
        Set.ncard_le_ncard_of_injOn φ hmaps hinj (Set.toFinite _)
    _ = L + 1 := hcard

/-! ## Rational slope: the complexity is also capped by the period -/

theorem factor_periodic {α : ℝ} {T : ℕ} (h : ∀ n, incWord α (n + T) = incWord α n) (m L : ℕ) :
    factor α (m + T) L = factor α m L := by
  funext t
  by_cases ht : t < L
  · simp only [factor, if_pos ht, show m + T + t = (m + t) + T from by ring, h]
  · simp [factor, ht]

theorem factor_mod {α : ℝ} {T : ℕ} (hT : 0 < T) (h : ∀ n, incWord α (n + T) = incWord α n)
    (m L : ℕ) : factor α m L = factor α (m % T) L := by
  induction m using Nat.strong_induction_on with
  | _ m ih =>
      by_cases hm : m < T
      · rw [Nat.mod_eq_of_lt hm]
      · have hle : T ≤ m := by omega
        have hstep : factor α m L = factor α (m - T) L := by
          have := factor_periodic h (m - T) L
          rwa [Nat.sub_add_cancel hle] at this
        rw [hstep, ih (m - T) (by omega), ← Nat.mod_eq_sub_mod hle]

/-- **Rational slope: complexity capped by the period.**  For the binomial slope
`P/(P+Q)` there are at most `P + Q` factors of any given length — combined with
`factorSet_ncard_le` this gives `p(L) ≤ min (L+1) (P+Q)`. -/
theorem factorSet_ncard_le_period {P Q : ℕ} (hPQ : 0 < P + Q) (L : ℕ) :
    {w : ℕ → ℤ | ∃ m, w = factor (slope (P : ℝ) (Q : ℝ)) m L}.ncard ≤ P + Q := by
  classical
  set α : ℝ := slope (P : ℝ) (Q : ℝ) with hα
  have hper : ∀ n, incWord α (n + (P + Q)) = incWord α n := fun n =>
    incWord_periodic_slope hPQ n
  have hSeq : {w : ℕ → ℤ | ∃ m, w = factor α m L}
      ⊆ Set.range (fun i : Fin (P + Q) => factor α (i : ℕ) L) := by
    rintro w ⟨m, rfl⟩
    exact ⟨⟨m % (P + Q), Nat.mod_lt _ hPQ⟩, (factor_mod hPQ hper m L).symm⟩
  calc {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard
      ≤ (Set.range (fun i : Fin (P + Q) => factor α (i : ℕ) L)).ncard :=
        Set.ncard_le_ncard hSeq (Set.finite_range _)
    _ ≤ (Set.univ : Set (Fin (P + Q))).ncard := by
        rw [← Set.image_univ]
        exact Set.ncard_image_le (Set.finite_univ)
    _ = P + Q := by simp

end SturmianArgmax
end Shared