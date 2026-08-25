/-
# Cycle 4b: sharpness of the thick-shell count, and two refutations

The companion file `Cryptography.ShellThicknessBudget` proves the uniform upper bound
`thickCount R d N δ ≤ 1 + R/(dδ)`.  Here we show that bound is of the correct order and that
the two conjectures stated for this cycle are **false**.

* `all_thick_of_small_budget` : if `δ < R/(dN)` then *every* one of the `N` shells is thick.
  Combined with the uniform lower bound `R/(dN) ≤ thickness_k` this is what makes the count
  large; `thickCount_sharp` (with `δ = R/(2dN)`) and `thickCount_max_ge` show the supremum over
  `N` of the thick-shell count is `Θ(R/(dδ))`.

* `thickCount_not_bigO_dim_log` : **the conjecture `#thick = O(d log(R/δ))` is false.**  For any
  constant `C` and any dimension `d`, take `N` large and `δ = 1/(2dN)`; then all `N` shells are
  thick while `C d log(1/δ) = C d log(2dN)` grows only logarithmically in `N`.  The true answer,
  `Θ(R/(dδ))`, is *decreasing* in the dimension — the opposite of the conjectured `d`-dependence
  — and grows polynomially, not logarithmically, in `R/δ`.

* `least_thin_N` : the least `N` for which the whole peeling respects the budget is exactly
  `max 1 ⌈(R/δ)^d⌉`; `thin_threshold_exceeds_conjectured` shows this is **not** `(1-δ/R)^{-d}`:
  at `δ = R/4` the two candidate bases are `4` and `4/3`, and `4^d` outgrows every constant
  multiple of `(4/3)^d`.  The conjectured base is only correct in the degenerate case
  `δ = R/2`.

So the qualitative picture ("exponentially many skins, boundedly many thick layers") survives,
but both quantitative guesses were wrong: the skins are `(R/δ)^d`, and the thick layers number
`Θ(R/(dδ))`.

## Lab notes

`R = 1, d = 2, δ = 0.01`: `N = 49 ↦ 49`, `N = 50 ↦ 50` thick shells (with `1 + R/(dδ) = 51`),
`N = 51 ↦ 49`, `N = 60 ↦ 42`, `N = 100 ↦ 25`.  The maximum over `N ≤ 400` is `50 = R/(dδ)`.  For `d = 10,
δ = 0.01` the maximum over `N ≤ 2000` is `10 = R/(dδ)`, versus the conjectured
`d log(R/δ) ≈ 46` — the conjecture is not merely off by a constant, it has the wrong sign in
`d`.
-/
import Mathlib
import Cryptography.ShellThicknessBudget

namespace Catalog.Cryptography.ShellBudget

open Finset Catalog.Geometry.Peel Catalog.Shared.ShellSharp

/-! ## Every shell is thick when the budget is below `R/(dN)` -/

theorem all_thick_of_small_budget {R δ : ℝ} (hR : 0 ≤ R) {d N : ℕ} (hd : 0 < d)
    (hδ : δ < R / (d * N)) : thickCount R d N δ = N :=
  thickCount_eq_of_all_thick fun _ hk => lt_of_lt_of_le hδ (shellThickness_ge_uniform hR hd hk)

/-- **The `1 + R/(dδ)` bound is attained up to a factor `2`.** -/
theorem thickCount_sharp {R : ℝ} (hR : 0 < R) {d N : ℕ} (hd : 0 < d) (hN : 0 < N) :
    thickCount R d N (R / (2 * d * N)) = N ∧ R / (d * (R / (2 * d * N))) = 2 * N := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  constructor
  · refine all_thick_of_small_budget hR.le hd ?_
    have h1 : R / (2 * (d : ℝ) * N) < R / ((d : ℝ) * N) :=
      div_lt_div_of_pos_left hR (by positivity) (by nlinarith)
    exact h1
  · field_simp

/-- **Matching lower bound for the worst `N`.**  For every `R, δ, d` some peeling has at least
`R/(2dδ) - 1` shells thicker than `δ`.  With `thickCount_le` this pins the supremum over `N` of
the thick-shell count to `Θ(R/(dδ))`. -/
theorem thickCount_max_ge {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d : ℕ} (hd : 0 < d) :
    ∃ N : ℕ, 0 < N ∧ R / (2 * d * δ) - 1 ≤ (thickCount R d N δ : ℝ) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set B : ℝ := R / (2 * d * δ) with hB
  have hB0 : 0 < B := by rw [hB]; positivity
  rcases Nat.eq_zero_or_pos ⌊B⌋₊ with hfl | hfl
  · refine ⟨1, Nat.one_pos, ?_⟩
    have hlt : B < 1 := by
      by_contra hge
      push_neg at hge
      have : 1 ≤ ⌊B⌋₊ := Nat.one_le_floor_iff B |>.2 hge
      omega
    have : (0 : ℝ) ≤ (thickCount R d 1 δ : ℝ) := by positivity
    linarith
  · refine ⟨⌊B⌋₊, hfl, ?_⟩
    have hNle : ((⌊B⌋₊ : ℕ) : ℝ) ≤ B := Nat.floor_le hB0.le
    have hNpos : (0 : ℝ) < ((⌊B⌋₊ : ℕ) : ℝ) := by exact_mod_cast hfl
    have hcount : thickCount R d ⌊B⌋₊ δ = ⌊B⌋₊ := by
      refine all_thick_of_small_budget hR.le hd ?_
      rw [lt_div_iff₀ (by positivity)]
      have h1 : (d : ℝ) * ((⌊B⌋₊ : ℕ) : ℝ) * δ ≤ (d : ℝ) * B * δ := by
        apply mul_le_mul_of_nonneg_right _ hδ.le
        exact mul_le_mul_of_nonneg_left hNle hdpos.le
      have h2 : (d : ℝ) * B * δ = R / 2 := by rw [hB]; field_simp
      nlinarith
    rw [hcount]
    have hfloor := Nat.lt_floor_add_one B
    have : B - 1 ≤ ((⌊B⌋₊ : ℕ) : ℝ) := by linarith
    linarith

/-! ## Refutation of the `O(d log(R/δ))` conjecture -/

/-- **The conjectured bound `#thick shells = O(d log(R/δ))` is false.**  For every constant `C`
and every dimension `d` there are a budget `δ` and a number of shells `N` for which the count of
shells thicker than `δ` exceeds `C d log(R/δ)`.  The true growth is `Θ(R/(dδ))`. -/
theorem thickCount_not_bigO_dim_log (C : ℝ) (hC : 0 < C) (d : ℕ) (hd : 0 < d) :
    ∃ (N : ℕ) (δ : ℝ), 0 < N ∧ 0 < δ ∧ δ < 1 ∧
      C * d * Real.log (1 / δ) < (thickCount 1 d N δ : ℝ) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast hd
  set A : ℝ := C * d with hA_def
  have hA : 0 < A := by rw [hA_def]; positivity
  obtain ⟨n, hn⟩ := exists_nat_gt (2 * A * (Real.log (2 * d) + Real.log (2 * A)))
  refine ⟨max 1 n, 1 / (2 * d * (max 1 n : ℕ)), ?_, ?_, ?_, ?_⟩
  · exact lt_of_lt_of_le Nat.zero_lt_one (le_max_left 1 n)
  · have : (0 : ℝ) < (max 1 n : ℕ) := by
      exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one (le_max_left 1 n)
    positivity
  · have hN1 : (1 : ℝ) ≤ ((max 1 n : ℕ) : ℝ) := by
      exact_mod_cast le_max_left 1 n
    rw [div_lt_one (by nlinarith)]
    nlinarith
  · set N : ℕ := max 1 n with hN_def
    have hN0 : 0 < N := lt_of_lt_of_le Nat.zero_lt_one (le_max_left 1 n)
    have hNpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN0
    have hN1 : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast Nat.one_le_iff_ne_zero.2 hN0.ne'
    have hNT : 2 * A * (Real.log (2 * d) + Real.log (2 * A)) < (N : ℝ) := by
      refine lt_of_lt_of_le hn ?_
      exact_mod_cast Nat.le_max_right 1 n
    have hcount : thickCount 1 d N (1 / (2 * d * (N : ℝ))) = N := by
      refine all_thick_of_small_budget (by norm_num) hd ?_
      exact div_lt_div_of_pos_left one_pos (by positivity) (by nlinarith)
    rw [hcount, one_div_one_div]
    -- reduces to `A * log (2 d N) < N`
    have hlog_split : Real.log (2 * (d : ℝ) * N) = Real.log (2 * d) + Real.log (N : ℝ) := by
      rw [Real.log_mul (by positivity) (by positivity)]
    have hkey : Real.log (N : ℝ) ≤ Real.log (2 * A) + (N : ℝ) / (2 * A) - 1 := by
      have h1 : Real.log ((N : ℝ) / (2 * A)) ≤ (N : ℝ) / (2 * A) - 1 :=
        Real.log_le_sub_one_of_pos (by positivity)
      rw [Real.log_div (by positivity) (by positivity)] at h1
      linarith
    have hAN : A * ((N : ℝ) / (2 * A)) = (N : ℝ) / 2 := by field_simp
    have hmul : A * Real.log (N : ℝ) ≤ A * Real.log (2 * A) + (N : ℝ) / 2 - A := by
      have h2 := mul_le_mul_of_nonneg_left hkey hA.le
      rw [mul_sub, mul_add, hAN] at h2
      linarith
    rw [hlog_split, mul_add]
    nlinarith [hNT, hmul, hA]

/-! ## The exact number of shells needed for a budget -/

/-- **The least admissible number of shells is `⌈(R/δ)^d⌉`.**  It grows exponentially in the
dimension with base `R/δ`. -/
theorem least_thin_N {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d : ℕ} (hd : 0 < d) :
    IsLeast {N : ℕ | 0 < N ∧ ∀ k < N, shellThickness R d N k ≤ δ}
      (max 1 ⌈(R / δ) ^ d⌉₊) := by
  have hM : 0 < max 1 ⌈(R / δ) ^ d⌉₊ := lt_of_lt_of_le Nat.zero_lt_one (le_max_left _ _)
  constructor
  · refine ⟨hM, ?_⟩
    refine (all_thin_iff_card hR hδ hd hM).2 ?_
    calc (R / δ) ^ d ≤ (⌈(R / δ) ^ d⌉₊ : ℝ) := Nat.le_ceil _
      _ ≤ ((max 1 ⌈(R / δ) ^ d⌉₊ : ℕ) : ℝ) := by exact_mod_cast Nat.le_max_right _ _
  · rintro N ⟨hN, hthin⟩
    have h := (all_thin_iff_card hR hδ hd hN).1 hthin
    exact max_le hN (Nat.ceil_le.2 h)

/-- **The conjectured base `(1 - δ/R)^{-1}` is wrong.**  For `δ = R/4` the true threshold `4^d`
outgrows any constant multiple of `(1 - δ/R)^{-d} = (4/3)^d`. -/
theorem thin_threshold_exceeds_conjectured (C : ℝ) :
    ∃ d : ℕ, 0 < d ∧ C * ((1 - (1 : ℝ) / 4)⁻¹) ^ d < (4 : ℝ) ^ d := by
  obtain ⟨m, hm⟩ := pow_unbounded_of_one_lt C (by norm_num : (1 : ℝ) < 3)
  refine ⟨m + 1, Nat.succ_pos m, ?_⟩
  have hm' : C < (3 : ℝ) ^ (m + 1) := by
    refine lt_of_lt_of_le hm ?_
    exact pow_le_pow_right₀ (by norm_num) (Nat.le_succ m)
  have hbase : ((1 - (1 : ℝ) / 4)⁻¹) = 4 / 3 := by norm_num
  have hpos : (0 : ℝ) < (4 / 3 : ℝ) ^ (m + 1) := by positivity
  calc C * ((1 - (1 : ℝ) / 4)⁻¹) ^ (m + 1) = C * (4 / 3 : ℝ) ^ (m + 1) := by rw [hbase]
    _ < (3 : ℝ) ^ (m + 1) * (4 / 3 : ℝ) ^ (m + 1) := by exact mul_lt_mul_of_pos_right hm' hpos
    _ = (4 : ℝ) ^ (m + 1) := by rw [← mul_pow]; norm_num

end Catalog.Cryptography.ShellBudget