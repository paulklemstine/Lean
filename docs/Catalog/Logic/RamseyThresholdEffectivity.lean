import Mathlib
import Combinatorics.RamseyExponentialBounds

/-!
# Effectivity of the merged threshold constant

This file settles conjecture **FD4** of the research thread on exponential bounds
for diagonal Ramsey numbers.  FD4 has two halves; we prove one and refute the
other.

Setting: a threshold-elimination argument merges an asymptotic constant `ε₁`
(valid for all `k ≥ k₀`) with the finitely many small-case gaps
`rootGap r k = 4 - (r k)^{1/k}` for `2 ≤ k < k₀`, producing a single `ε` valid
for all `k ≥ 2`.

* **True half.**  For the tabulated diagonal Ramsey upper bounds
  `2, 6, 18, 48` at `k = 2, 3, 4, 5` the root gap is strictly *decreasing*
  (`RamseyBounds.tabRootGap_strictAnti`).
* **False half.**  FD4 also asserts that the merged constant equals
  `min (ε₁) (rootGap r 2)`.  Strict decrease of the gaps means precisely that the
  binding small case is the *largest* index in the finite range, not `k = 2`.
  `RamseyBounds.merged_constant_not_min_with_rootGap_two` exhibits an explicit
  `r` (the table, extended by `0`) and an admissible asymptotic constant `ε₁`
  for which `min ε₁ (rootGap r 2)` is *not* a valid uniform constant, being
  violated at `k = 5`.

The auxiliary lemma `RamseyBounds.rpow_inv_lt_rpow_inv_of_pow_lt_pow` converts
comparisons of `k`-th roots into purely arithmetic comparisons of naturals, so
all numeric verifications below are `decide`/`norm_num` computations.
-/

namespace RamseyBounds

/-- The root gap of a sequence at index `k`: how far `(r k)^{1/k}` stays below
the classical base four. -/
noncomputable def rootGap (r : ℕ → ℕ) (k : ℕ) : ℝ :=
  4 - (r k : ℝ) ^ ((k : ℝ)⁻¹)

/-- Comparing `k`-th roots reduces to a comparison of natural powers. -/
theorem rpow_inv_lt_rpow_inv_of_pow_lt_pow {a b k l : ℕ} (hk : 0 < k) (hl : 0 < l)
    (h : a ^ l < b ^ k) :
    (a : ℝ) ^ ((k : ℝ)⁻¹) < (b : ℝ) ^ ((l : ℝ)⁻¹) := by
  have hka : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  have hla : (l : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hl.ne'
  set x : ℝ := (a : ℝ) ^ ((k : ℝ)⁻¹) with hx
  set y : ℝ := (b : ℝ) ^ ((l : ℝ)⁻¹) with hy
  have hy0 : 0 ≤ y := Real.rpow_nonneg (Nat.cast_nonneg _) _
  have hxp : x ^ (k * l) = (a : ℝ) ^ l := by
    rw [hx, ← Real.rpow_natCast ((a : ℝ) ^ ((k : ℝ)⁻¹)) (k * l),
      ← Real.rpow_mul (Nat.cast_nonneg _)]
    push_cast
    rw [show (k : ℝ)⁻¹ * ((k : ℝ) * (l : ℝ)) = (l : ℝ) by field_simp,
      Real.rpow_natCast]
  have hyp : y ^ (k * l) = (b : ℝ) ^ k := by
    rw [hy, ← Real.rpow_natCast ((b : ℝ) ^ ((l : ℝ)⁻¹)) (k * l),
      ← Real.rpow_mul (Nat.cast_nonneg _)]
    push_cast
    rw [show (l : ℝ)⁻¹ * ((k : ℝ) * (l : ℝ)) = (k : ℝ) by field_simp,
      Real.rpow_natCast]
  have hcast : (a : ℝ) ^ l < (b : ℝ) ^ k := by exact_mod_cast h
  have hlt : x ^ (k * l) < y ^ (k * l) := by rw [hxp, hyp]; exact hcast
  exact lt_of_pow_lt_pow_left₀ (k * l) hy0 hlt

/-- Strict decrease of the root gap between two consecutive indices is exactly
an arithmetic inequality between natural powers. -/
theorem rootGap_lt_rootGap {r : ℕ → ℕ} {k l : ℕ} (hk : 0 < k) (hl : 0 < l)
    (h : r k ^ l < r l ^ k) : rootGap r l < rootGap r k := by
  have := rpow_inv_lt_rpow_inv_of_pow_lt_pow (a := r k) (b := r l) hk hl h
  unfold rootGap
  linarith

/-! ### The tabulated diagonal Ramsey upper bounds -/

/-- The classical tabulated upper bounds for the diagonal Ramsey numbers
`R(k,k)` at `k = 2,3,4,5`, extended by `0` outside that range.  (No claim about
Ramsey numbers themselves is made or used here: this is simply the table used as
the small-case input of a threshold-elimination argument.) -/
def tabR (k : ℕ) : ℕ :=
  if k = 2 then 2 else if k = 3 then 6 else if k = 4 then 18
    else if k = 5 then 48 else 0

@[simp] theorem tabR_two : tabR 2 = 2 := rfl
@[simp] theorem tabR_three : tabR 3 = 6 := rfl
@[simp] theorem tabR_four : tabR 4 = 18 := rfl
@[simp] theorem tabR_five : tabR 5 = 48 := rfl

theorem tabR_eq_zero {k : ℕ} (hk : 6 ≤ k) : tabR k = 0 := by
  unfold tabR
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega)]

/-- **True half of FD4.**  On the tabulated range the root gap is strictly
decreasing. -/
theorem tabRootGap_strictAnti :
    rootGap tabR 3 < rootGap tabR 2 ∧
    rootGap tabR 4 < rootGap tabR 3 ∧
    rootGap tabR 5 < rootGap tabR 4 := by
  refine ⟨rootGap_lt_rootGap (by norm_num) (by norm_num) ?_,
    rootGap_lt_rootGap (by norm_num) (by norm_num) ?_,
    rootGap_lt_rootGap (by norm_num) (by norm_num) ?_⟩
  · simp only [tabR_two, tabR_three]; norm_num
  · simp only [tabR_three, tabR_four]; norm_num
  · simp only [tabR_four, tabR_five]; norm_num

/-- In particular the binding small case is the *largest* index of the range,
not `k = 2`. -/
theorem tabRootGap_five_lt_two : rootGap tabR 5 < rootGap tabR 2 :=
  lt_trans tabRootGap_strictAnti.2.2
    (lt_trans tabRootGap_strictAnti.2.1 tabRootGap_strictAnti.1)

/-! ### Refutation of the second half of FD4 -/

theorem sqrt_two_rpow_le : (2 : ℝ) ^ ((2 : ℝ)⁻¹) ≤ 2 := by
  have h := Real.rpow_le_rpow_of_exponent_le (x := (2 : ℝ)) (by norm_num)
    (show (2 : ℝ)⁻¹ ≤ 1 by norm_num)
  simpa using h

/-- **False half of FD4.**  The merged threshold constant is *not* in general
`min ε₁ (rootGap r 2)`.

Witness: `r = tabR` (the tabulated bounds, extended by `0`) and `ε₁ = 2`, which
is a legitimate asymptotic constant from `k₀ = 6` onwards and satisfies the
strict small-case inequalities `r k < 4^k` for all `k ≥ 2`.  Nevertheless
`min ε₁ (rootGap r 2) = 2` fails at `k = 5`, where `48 > 2^5 = 32`.  The reason
is exactly the monotonicity established above: the finite minimum of the gaps is
attained at the top of the range. -/
theorem merged_constant_not_min_with_rootGap_two :
    ∃ (r : ℕ → ℕ) (ε₁ : ℝ), 0 < ε₁ ∧ ε₁ < 4 ∧
      (∀ k ≥ 6, (r k : ℝ) ≤ (4 - ε₁) ^ k) ∧
      (∀ k ≥ 2, (r k : ℝ) < 4 ^ k) ∧
      ¬ (∀ k ≥ 2, (r k : ℝ) ≤ (4 - min ε₁ (rootGap r 2)) ^ k) := by
  refine ⟨tabR, 2, by norm_num, by norm_num, ?_, ?_, ?_⟩
  · intro k hk
    rw [tabR_eq_zero hk]
    have h0 : (0 : ℝ) ≤ (4 - 2 : ℝ) ^ k := by positivity
    simpa using h0
  · intro k hk
    rcases (by omega : k = 2 ∨ k = 3 ∨ k = 4 ∨ k = 5 ∨ 6 ≤ k) with
      h | h | h | h | h
    · subst h; norm_num
    · subst h; norm_num
    · subst h; norm_num
    · subst h; norm_num
    · rw [tabR_eq_zero h]
      simp
  · intro hcon
    have hmin : min (2 : ℝ) (rootGap tabR 2) = 2 := by
      refine min_eq_left ?_
      have := sqrt_two_rpow_le
      unfold rootGap
      simp only [tabR_two]
      norm_num
      linarith
    have h5 := hcon 5 (by norm_num)
    rw [hmin] at h5
    norm_num at h5

end RamseyBounds