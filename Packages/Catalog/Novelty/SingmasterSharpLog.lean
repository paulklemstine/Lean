/-
# A factor-two sharpening of the unconditional Singmaster bound

`Combinatorics.SingmasterOccurrences` proves the unconditional estimate

`N(t) ≤ 2 · log₂ t`   (`Singmaster.mult_le_two_mul_log`),

obtained from the growth estimate `2 ^ b ≤ C(n,b)` for `2b ≤ n`.  That growth estimate
is lossy: the true size of the smallest entry with folded column index `b` is the central
binomial coefficient `C(2b,b) ≈ 4 ^ b / √b`, not `2 ^ b`.  This file replaces `2 ^ b` by
`4 ^ b / (2b+1)`, an estimate that is *free* (it is only the pigeonhole statement that the
`2b+1` entries of row `2b` sum to `4 ^ b` and are all at most the central one), and thereby
halves the leading constant of the bound:

`N(t) ≤ log₂ t + log₂(2 log₂ t + 1) + 1 = log₂ t + O(log log t)`.

For `t = 3003` the catalog bound gives `22`, the bound proved here gives `16`; for
`t < 10⁶` they give `38` and `25`.  The Erdős–Abbott–Hanson–Singmaster bound
`O(log t / log log t)` is still stronger asymptotically, but it is not elementary; the
statement proved here is elementary and gives the correct leading constant `1` for the
"one column per power of four" heuristic.

## Structure of the argument

1. `four_pow_le_mul_centralBinom` — `4 ^ b ≤ (2b+1) · C(2b,b)` (row-`2b` pigeonhole).
2. `centralBinom_le_of_occ` — an occurrence `C(n,k) = t` with folded index `b` satisfies
   `C(2b,b) ≤ t` (monotonicity in the row index).
3. `four_pow_fold_le` — hence `4 ^ b ≤ (2b+1) · t`, and since `b ≤ log₂ t` already,
   `4 ^ b ≤ (2 log₂ t + 1) · t =: X`, so `b ≤ log₂ X / 2`.
4. Column uniqueness (`Singmaster.fibre_card_le_two`) bounds each folded index by two
   positions, giving `N(t) ≤ 2 · (log₂ X / 2) ≤ log₂ X`.

## Results

* `mult_le_log_mul` — **`N(t) ≤ log₂ ((2 log₂ t + 1) · t)`** for `t ≥ 2`;
* `mult_le_log_add_log_log` — **`N(t) ≤ log₂ t + log₂ (2 log₂ t + 1) + 1`**;
* `mult_lt_two_mul_log` — the new bound is *strictly* better than `2 log₂ t` as soon as
  `t ≥ 2 ^ 16`.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences

open Finset

namespace Catalog.Novelty.SingmasterSharpLog

open Singmaster

/-! ## Step 1: the pigeonhole lower bound for the central binomial coefficient -/

/-- **Row-`2b` pigeonhole.**  The `2b+1` entries of row `2b` sum to `4 ^ b` and each is at
most the central entry, hence `4 ^ b ≤ (2b+1) · C(2b,b)`. -/
theorem four_pow_le_mul_centralBinom (b : ℕ) : 4 ^ b ≤ (2 * b + 1) * (2 * b).choose b := by
  have h1 : ∑ k ∈ Finset.range (2 * b + 1), (2 * b).choose k = 2 ^ (2 * b) :=
    Nat.sum_range_choose (2 * b)
  have h2 : ∀ k ∈ Finset.range (2 * b + 1), (2 * b).choose k ≤ (2 * b).choose b := by
    intro k _
    have := Nat.choose_le_middle k (2 * b)
    simpa [Nat.mul_div_cancel_left] using this
  have h3 := Finset.sum_le_card_nsmul _ _ _ h2
  simp only [h1, Finset.card_range, smul_eq_mul] at h3
  calc (4 : ℕ) ^ b = 2 ^ (2 * b) := by rw [pow_mul]; norm_num
    _ ≤ (2 * b + 1) * (2 * b).choose b := by simpa [mul_comm] using h3

/-! ## Step 2: an occurrence dominates the central binomial coefficient of its
folded index -/

/-- If `C(n,k) = t` and `b = min k (n-k)` is the folded column index, then `C(2b,b) ≤ t`.
-/
theorem centralBinom_le_of_choose_eq {n k t : ℕ} (hk : k ≤ n) (h : n.choose k = t) :
    (2 * min k (n - k)).choose (min k (n - k)) ≤ t := by
  set b := min k (n - k) with hb
  have hbn : 2 * b ≤ n := by omega
  have hfold : n.choose b = t := by
    have := choose_fold (n := n) (k := k) hk
    rw [fold_mk] at this
    rw [← hb] at this
    rw [this, h]
  calc (2 * b).choose b ≤ n.choose b := Nat.choose_mono b hbn
    _ = t := hfold

/-- **Step 3.**  The folded index `b` of any occurrence of `t` satisfies
`4 ^ b ≤ (2b+1) · t`. -/
theorem four_pow_fold_le {t n k : ℕ} (hk : k ≤ n) (h : n.choose k = t) :
    4 ^ fold (n, k) ≤ (2 * fold (n, k) + 1) * t := by
  rw [fold_mk]
  exact le_trans (four_pow_le_mul_centralBinom _)
    (Nat.mul_le_mul_left _ (centralBinom_le_of_choose_eq hk h))

/-- Uniform version: since the folded index is already known to be at most `log₂ t`, the
factor `2b+1` can be replaced by the `t`-dependent constant `2 log₂ t + 1`. -/
theorem four_pow_fold_le_uniform {t n k : ℕ} (ht : 2 ≤ t) (hk : k ≤ n) (h : n.choose k = t) :
    4 ^ fold (n, k) ≤ (2 * Nat.log 2 t + 1) * t := by
  refine le_trans (four_pow_fold_le hk h) (Nat.mul_le_mul_right _ ?_)
  have := fold_le_log ht hk h
  omega

/-- Consequently the folded index is at most `log₂ ((2 log₂ t + 1) · t) / 2`, roughly
half of the bound `log₂ t` used in the catalog. -/
theorem fold_le_half_log {t n k : ℕ} (ht : 2 ≤ t) (hk : k ≤ n) (h : n.choose k = t) :
    fold (n, k) ≤ Nat.log 2 ((2 * Nat.log 2 t + 1) * t) / 2 := by
  set X := (2 * Nat.log 2 t + 1) * t with hX
  have hXpos : X ≠ 0 := by
    rw [hX]; positivity
  have hpow : 2 ^ (2 * fold (n, k)) ≤ X := by
    have := four_pow_fold_le_uniform ht hk h
    calc 2 ^ (2 * fold (n, k)) = 4 ^ fold (n, k) := by rw [pow_mul]; norm_num
      _ ≤ X := this
  have := (Nat.le_log_iff_pow_le (b := 2) (by norm_num) hXpos).2 hpow
  omega

/-! ## Step 4: assembling the improved bound -/

/-- A convenient logarithm-of-product estimate. -/
theorem log_mul_le {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) :
    Nat.log 2 (a * b) ≤ Nat.log 2 a + Nat.log 2 b + 1 := by
  have h1 : a < 2 ^ (Nat.log 2 a + 1) := Nat.lt_pow_succ_log_self (by norm_num) a
  have h2 : b < 2 ^ (Nat.log 2 b + 1) := Nat.lt_pow_succ_log_self (by norm_num) b
  have h3 : a * b < 2 ^ (Nat.log 2 a + Nat.log 2 b + 2) := by
    calc a * b < 2 ^ (Nat.log 2 a + 1) * 2 ^ (Nat.log 2 b + 1) :=
          Nat.mul_lt_mul_of_lt_of_lt h1 h2
      _ = 2 ^ (Nat.log 2 a + Nat.log 2 b + 2) := by rw [← pow_add]; ring_nf
  have := Nat.log_lt_of_lt_pow (b := 2) (x := Nat.log 2 a + Nat.log 2 b + 2) (y := a * b)
    (by positivity) h3
  omega

/-- **Main theorem: a factor-two sharpening of the unconditional Singmaster bound.**
Every `t ≥ 2` occurs at most `log₂ ((2 log₂ t + 1) · t)` times in Pascal's triangle. -/
theorem mult_le_log_mul {t : ℕ} (ht : 2 ≤ t) :
    mult t ≤ Nat.log 2 ((2 * Nat.log 2 t + 1) * t) := by
  classical
  set L := Nat.log 2 t with hL
  have hL1 : 1 ≤ L := by
    rw [hL]
    exact (Nat.le_log_iff_pow_le (by norm_num) (by omega)).2 (by simpa using ht)
  set X := (2 * L + 1) * t with hX
  set M := Nat.log 2 X / 2 with hM
  -- `M ≥ 1`, since `X ≥ 6`
  have hX6 : 6 ≤ X := by
    rw [hX]
    calc 6 = 3 * 2 := by norm_num
      _ ≤ (2 * L + 1) * t := Nat.mul_le_mul (by omega) ht
  have hlogX : 2 ≤ Nat.log 2 X :=
    (Nat.le_log_iff_pow_le (by norm_num) (by omega)).2 (by norm_num; omega)
  have hM1 : 1 ≤ M := by omega
  set A := (occ t).filter (fun p => fold p ≤ 1) with hA
  set B := (occ t).filter (fun p => ¬ fold p ≤ 1) with hB
  have hsplit : mult t = A.card + B.card := by
    rw [hA, hB, mult]
    exact (Finset.card_filter_add_card_filter_not _).symm
  have hAcard : A.card ≤ 2 :=
    le_trans (card_le_card (occ_boundary ht)) (le_trans (card_insert_le _ _) (by simp))
  have himg : B.image fold ⊆ Finset.Icc 2 M := by
    intro b hb
    rw [mem_image] at hb
    obtain ⟨⟨n, k⟩, hmem, rfl⟩ := hb
    rw [hB, mem_filter, mem_occ_iff ht] at hmem
    obtain ⟨⟨hk, h⟩, hf⟩ := hmem
    rw [Finset.mem_Icc]
    exact ⟨by omega, fold_le_half_log ht hk h⟩
  have hfib : ∀ b ∈ B.image fold, (B.filter (fun p => fold p = b)).card ≤ 2 := by
    intro b hb
    have hb2 : 2 ≤ b := by
      have hmem := himg hb
      rw [Finset.mem_Icc] at hmem
      exact hmem.1
    refine le_trans (card_le_card ?_) (fibre_card_le_two ht b hb2)
    intro x hx
    rw [mem_filter] at hx ⊢
    rw [hB, mem_filter] at hx
    exact ⟨hx.1.1, hx.2⟩
  have hBcard : B.card ≤ 2 * (B.image fold).card := Finset.card_le_mul_card_image B 2 hfib
  have hIcc : (B.image fold).card ≤ M - 1 := by
    refine le_trans (card_le_card himg) ?_
    rw [Nat.card_Icc]
    omega
  omega

/-- **Explicit form.**  `N(t) ≤ log₂ t + log₂(2 log₂ t + 1) + 1`: the leading constant is
`1`, versus `2` in `Singmaster.mult_le_two_mul_log`. -/
theorem mult_le_log_add_log_log {t : ℕ} (ht : 2 ≤ t) :
    mult t ≤ Nat.log 2 t + Nat.log 2 (2 * Nat.log 2 t + 1) + 1 := by
  refine le_trans (mult_le_log_mul ht) ?_
  have := log_mul_le (a := 2 * Nat.log 2 t + 1) (b := t) (by omega) (by omega)
  omega

/-- **Strict improvement.**  For `t ≥ 2 ^ 16` the bound proved here is strictly smaller
than the catalog bound `2 log₂ t`. -/
theorem mult_lt_two_mul_log {t : ℕ} (ht : 2 ^ 16 ≤ t) : mult t < 2 * Nat.log 2 t := by
  have ht2 : 2 ≤ t := le_trans (by norm_num) ht
  set L := Nat.log 2 t with hL
  have hL16 : 16 ≤ L := (Nat.le_log_iff_pow_le (by norm_num) (by omega)).2 ht
  -- `log₂ (2L+1) ≤ L - 2` because `2L + 1 < 2 ^ (L-2)` for `L ≥ 16`
  have hsmall : 2 * L + 1 < 2 ^ (L - 2) := by
    have hpow : ∀ m : ℕ, 14 ≤ m → 2 * m + 5 < 2 ^ m := by
      intro m hm
      induction m with
      | zero => omega
      | succ r ih =>
        rcases Nat.lt_or_ge r 14 with hr | hr
        · have : r = 13 := by omega
          subst this; norm_num
        · have := ih hr
          have h2 : 2 ^ r + 2 ^ r = 2 ^ (r + 1) := by ring
          omega
    have := hpow (L - 2) (by omega)
    omega
  have hlog : Nat.log 2 (2 * L + 1) ≤ L - 3 := by
    have := Nat.log_lt_of_lt_pow (b := 2) (x := L - 2) (y := 2 * L + 1) (by omega) hsmall
    omega
  have hmain := mult_le_log_add_log_log ht2
  rw [← hL] at hmain
  omega

end Catalog.Novelty.SingmasterSharpLog