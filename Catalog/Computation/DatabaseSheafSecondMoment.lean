import Mathlib
import Computation.DatabaseSheafProbability

/-!
# The second moment of the number of global sections, and a matching lower bound

`Catalog/Computation/DatabaseSheafProbability.lean` proves the exact law for the
sheaf condition of a random `k × n` database over an alphabet of size `q` with
cellwise missing rate `r`,

  `P(sheaf) = base(k,q,r) ^ n`,  `base = q·A^k − (q−1)·r^k`,  `A = r + (1−r)/q`,

together with the first moment `E[N] = (q·A^k)^n` of the number `N` of global
sections and the Markov bound `P(sheaf) ≤ E[N]`.  This file closes the
second-moment conjecture recorded in `FUTURE_DIRECTIONS.md` (C4).

Since a column with observed row set `S ≠ ∅` admits at most one completion, in
that column `N` is a `{0,1}`-variable and `N² = N`; a fully unobserved column
contributes a factor `q` to `N` and `q²` to `N²`.  Hence the second moment also
factorises over columns, with per-column factor

  `baseSq(k,q,r) = q·A^k + (q² − q)·r^k`.

Main results.
* `expSectionsSq_eq` — the exact second moment `E[N²] = baseSq ^ n`.
* `second_moment_column` — the per-column Cauchy–Schwarz inequality
  `base · baseSq ≥ (q·A^k)²`, which is exactly the statement that the
  Paley–Zygmund bound is *valid* for this law.
* `sheafProb_mul_expSectionsSq_ge` and `second_moment_bound` — the
  second-moment lower bound `E[N]² / E[N²] ≤ P(sheaf)`, complementing the
  first-moment upper bound `P(sheaf) ≤ E[N]`.
* `second_moment_tight_at_one`, `second_moment_tight_at_zero` — the bound is an
  equality at both ends of the missing-rate range.
* `second_moment_strict` — and strictly loses inside the range, for `q ≥ 2`,
  `k ≥ 1` and `0 < r < 1`.

-- !-- Lab Notes -- !--
Hypothesis (C4 of the previous cycle): `E[N²]` factorises over columns and the
resulting Paley–Zygmund bound is asymptotically tight as `r → 1`.
Experiment: compute `E[N²]` exactly by the same columnwise factorisation used
for the first moment, then compare `E[N]²/E[N²]` with the exact `P(sheaf)`.
Analysis: with `u = q·A^k` and `v = (q−1)·r^k` one has `P = (u−v)^n`,
`E[N] = u^n`, `E[N²] = (u+qv)^n`, and
`(u−v)(u+qv) − u² = q(q−1)²·r^k·(A^k − r^k) ≥ 0`, so the bound is valid always,
an equality exactly when `v = 0` (i.e. `r = 0`, `k ≥ 1`) or `A^k = r^k`
(i.e. `r = 1`, or `q = 1`), and strict in between.  The predicted asymptotic
tightness at `r → 1` is confirmed in the sharpest possible form: exact equality
at `r = 1`.
Critique: the conjectured second moment in the previous cycle carried an
unspecified correction factor `c(k,q,r)`; the correct statement needs none, the
only correction is the fully-unobserved-column term `(q²−q)r^k`.  The bound is
therefore *not* asymptotically tight as `n → ∞` at fixed `r ∈ (0,1)`: both sides
decay exponentially but with different bases.
Synthesis: the sheaf condition of a random database is squeezed between two
explicit exponentials, `(u²/(u+qv))^n ≤ P(sheaf) = (u−v)^n ≤ u^n`, all three
bases being elementary functions of `k, q, r`.
-- !-- Lab Notes -- !--
-/

open Finset

namespace DatabaseSheafSecondMoment

open DatabaseSheafProb

variable (k q n : ℕ) (r : ℝ)

/-- Expected value of the *square* of the number of admissible values in a single
column whose observed row set is `S`: a nonempty `S` pins the column down, so the
count is `0` or `1` and squaring changes nothing; an unobserved column
contributes `q²`. -/
noncomputable def colExpSectionsSq (q k : ℕ) (S : Finset (Fin k)) : ℝ :=
  if S = ∅ then (q : ℝ) ^ 2 else (q : ℝ) * ((q : ℝ)⁻¹) ^ S.card

/-- The second moment of the number of global sections of a random database. -/
noncomputable def expSectionsSq (n k q : ℕ) (r : ℝ) : ℝ :=
  ∑ M : Fin n → Finset (Fin k), ∏ c : Fin n, maskWeight k r (M c) * colExpSectionsSq q k (M c)

/-- Closed form of the per-column second-moment factor. -/
noncomputable def baseSq (k q : ℕ) (r : ℝ) : ℝ :=
  (q : ℝ) * (r + (1 - r) / q) ^ k + ((q : ℝ) ^ 2 - q) * r ^ k

/-! ### The per-column sums -/

/-- The per-column first-moment sum, extracted from `expSections_eq` at `n = 1`. -/
theorem colSum_expSections (k q : ℕ) (hq : 0 < q) (r : ℝ) :
    ∑ S : Finset (Fin k), maskWeight k r S * colExpSections q k S
      = (q : ℝ) * (r + (1 - r) / q) ^ k := by
  have h := expSections_eq 1 k q hq r
  rw [expSections, sum_prod_factor 1 k (fun S => maskWeight k r S * colExpSections q k S),
    pow_one, pow_one] at h
  exact h

/-- The mask weight of the empty observation pattern. -/
theorem maskWeight_empty (k : ℕ) (r : ℝ) : maskWeight k r (∅ : Finset (Fin k)) = r ^ k := by
  simp [maskWeight]

/-- The per-column second-moment sum. -/
theorem colSum_expSectionsSq (k q : ℕ) (hq : 0 < q) (r : ℝ) :
    ∑ S : Finset (Fin k), maskWeight k r S * colExpSectionsSq q k S = baseSq k q r := by
  classical
  have hsplit : ∀ S : Finset (Fin k),
      maskWeight k r S * colExpSectionsSq q k S
        = maskWeight k r S * colExpSections q k S
          + (if S = ∅ then maskWeight k r S * ((q : ℝ) ^ 2 - q) else 0) := by
    intro S
    by_cases hS : S = ∅
    · subst hS
      simp [colExpSectionsSq, colExpSections]
      ring
    · simp [colExpSectionsSq, colExpSections, hS]
  rw [Finset.sum_congr rfl (fun S _ => hsplit S), Finset.sum_add_distrib,
    colSum_expSections k q hq r]
  have : ∑ S : Finset (Fin k), (if S = ∅ then maskWeight k r S * ((q : ℝ) ^ 2 - q) else 0)
      = maskWeight k r (∅ : Finset (Fin k)) * ((q : ℝ) ^ 2 - q) := by
    rw [Finset.sum_ite_eq' Finset.univ (∅ : Finset (Fin k))
      (fun S => maskWeight k r S * ((q : ℝ) ^ 2 - q))]
    simp
  rw [this, maskWeight_empty, baseSq]
  ring

/-- **Exact second moment.** The second moment of the number of global sections
of a random database factorises over columns, with per-column factor
`q·A^k + (q²−q)·r^k`. -/
theorem expSectionsSq_eq (n k q : ℕ) (hq : 0 < q) (r : ℝ) :
    expSectionsSq n k q r = baseSq k q r ^ n := by
  rw [expSectionsSq, sum_prod_factor n k (fun S => maskWeight k r S * colExpSectionsSq q k S),
    colSum_expSectionsSq k q hq r]

/-! ### The second-moment (Paley–Zygmund) inequality -/

/-- Positivity of `A = r + (1−r)/q` on the whole range of missing rates. -/
theorem A_pos (q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    0 < r + (1 - r) / q := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  rcases eq_or_lt_of_le h1 with rfl | hlt
  · simp
  · have : 0 < (1 - r) / q := div_pos (by linarith) hq0
    linarith

/-- `r ≤ A`, hence `r^k ≤ A^k`. -/
theorem r_le_A (q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h1 : r ≤ 1) : r ≤ r + (1 - r) / q := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have : 0 ≤ (1 - r) / q := div_nonneg (by linarith) hq0.le
  linarith

/-- **The per-column Cauchy–Schwarz inequality.** The product of the per-column
sheaf probability and the per-column second moment dominates the square of the
per-column first moment. -/
theorem second_moment_column (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    ((q : ℝ) * (r + (1 - r) / q) ^ k) ^ 2 ≤ base k q r * baseSq k q r := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  set A : ℝ := r + (1 - r) / q with hA
  have hApos : 0 < A := A_pos q hq h0 h1
  have hrA : r ^ k ≤ A ^ k := pow_le_pow_left₀ h0 (r_le_A q hq h1) k
  have hrk : 0 ≤ r ^ k := pow_nonneg h0 k
  -- `u = q A^k`, `v = (q-1) r^k`; the difference is `q(q-1) r^k (A^k - r^k) ≥ 0`
  have key : base k q r * baseSq k q r - ((q : ℝ) * A ^ k) ^ 2
      = (q : ℝ) * ((q : ℝ) - 1) ^ 2 * r ^ k * (A ^ k - r ^ k) := by
    simp only [base, baseSq, ← hA]
    ring
  nlinarith [mul_nonneg (mul_nonneg (mul_nonneg hq0.le
      (sq_nonneg ((q : ℝ) - 1))) hrk) (by linarith : (0:ℝ) ≤ A ^ k - r ^ k)]

/-- **The second-moment bound, multiplicative form.** -/
theorem sheafProb_mul_expSectionsSq_ge (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ}
    (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    (expSections n k q r) ^ 2 ≤ sheafProb n k q r * expSectionsSq n k q r := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hE2 : (expSections n k q r) ^ 2
      = (((q : ℝ) * (r + (1 - r) / q) ^ k) ^ 2) ^ n := by
    rw [expSections_eq n k q (by omega) r, ← pow_mul, mul_comm n 2, pow_mul]
  rw [hE2, sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r,
    expSectionsSq_eq n k q (by omega) r, ← mul_pow]
  exact pow_le_pow_left₀ (by positivity) (second_moment_column k q hq h0 h1) n

/-- Positivity of the second moment. -/
theorem expSectionsSq_pos (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    0 < expSectionsSq n k q r := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  have hApos : 0 < r + (1 - r) / q := A_pos q hq h0 h1
  rw [expSectionsSq_eq n k q (by omega) r]
  have : 0 < baseSq k q r := by
    have h2 : 0 ≤ ((q : ℝ) ^ 2 - q) * r ^ k :=
      mul_nonneg (by nlinarith) (pow_nonneg h0 k)
    have h3 : 0 < (q : ℝ) * (r + (1 - r) / q) ^ k := by positivity
    simp only [baseSq]; linarith
  positivity

/-- **The second-moment lower bound.** The probability that a random database
satisfies the sheaf condition is at least `E[N]² / E[N²]`, where `N` is the
number of global sections.  Together with `sheafProb_le_expSections` this traps
the exact law between two explicit exponentials. -/
theorem second_moment_bound (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    (expSections n k q r) ^ 2 / expSectionsSq n k q r ≤ sheafProb n k q r :=
  (div_le_iff₀ (expSectionsSq_pos n k q hq h0 h1)).2
    (sheafProb_mul_expSectionsSq_ge n k q hq h0 h1)

/-! ### Sharpness -/

/-- At full missingness the second-moment bound is an equality (both sides are
`1`): the predicted asymptotic tightness as `r → 1` holds exactly at `r = 1`. -/
theorem second_moment_tight_at_one (n k q : ℕ) (hq : 1 ≤ q) :
    (expSections n k q 1) ^ 2 / expSectionsSq n k q 1 = sheafProb n k q 1 := by
  have hq0 : (q : ℝ) ≠ 0 := by
    have : (0 : ℝ) < q := by exact_mod_cast hq
    exact this.ne'
  have hE : expSections n k q 1 = ((q : ℝ)) ^ n := by
    rw [expSections_eq n k q (by omega) 1]; norm_num
  have hSq : expSectionsSq n k q 1 = ((q : ℝ) ^ 2) ^ n := by
    rw [expSectionsSq_eq n k q (by omega) 1]
    simp only [baseSq]
    norm_num
  have hP : sheafProb n k q 1 = 1 := by
    rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) 1, base_at_one k q (by omega),
      one_pow]
  rw [hE, hSq, hP, sq, ← pow_mul, ← pow_add, ← two_mul, div_self (by positivity)]

/-- At zero missingness the bound is again an equality: with `k ≥ 1` rows every
observed column is fully constrained, so `N` is a `{0,1}`-variable in each
column and the second moment equals the first. -/
theorem second_moment_tight_at_zero (n k q : ℕ) (hq : 1 ≤ q) (hk : 0 < k) :
    (expSections n k q 0) ^ 2 / expSectionsSq n k q 0 = sheafProb n k q 0 := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hE : expSections n k q 0 = ((q : ℝ) * ((q : ℝ)⁻¹) ^ k) ^ n := by
    rw [expSections_eq n k q (by omega) 0]
    congr 1
    simp [inv_pow, one_div]
  have hSq : expSectionsSq n k q 0 = ((q : ℝ) * ((q : ℝ)⁻¹) ^ k) ^ n := by
    rw [expSectionsSq_eq n k q (by omega) 0]
    congr 1
    simp only [baseSq, zero_pow hk.ne', mul_zero, add_zero]
    congr 1
    simp [inv_pow, one_div]
  have hP : sheafProb n k q 0 = ((q : ℝ) * ((q : ℝ)⁻¹) ^ k) ^ n :=
    sheafProb_at_zero n k q (by omega) hk
  have hpos : (0 : ℝ) < (q : ℝ) * ((q : ℝ)⁻¹) ^ k := by positivity
  rw [hE, hSq, hP, sq, mul_div_assoc, div_self (by positivity), mul_one]

/-- **Strictness inside the range.** For a nontrivial alphabet, at least one row
and an intermediate missing rate, the second-moment bound is strictly below the
exact law: the number of global sections is genuinely non-concentrated. -/
theorem second_moment_strict (n k q : ℕ) (hn : 0 < n) (hk : 0 < k) (hq : 2 ≤ q) {r : ℝ}
    (h0 : 0 < r) (h1 : r < 1) :
    (expSections n k q r) ^ 2 / expSectionsSq n k q r < sheafProb n k q r := by
  have hq1 : 1 ≤ q := by omega
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (by omega : 0 < q)
  have hqR : (2 : ℝ) ≤ q := by exact_mod_cast hq
  set A : ℝ := r + (1 - r) / q with hA
  have hApos : 0 < A := A_pos q hq1 h0.le h1.le
  have hrA : r < A := by
    have : 0 < (1 - r) / q := div_pos (by linarith) hq0
    simp only [hA]; linarith
  have hrAk : r ^ k < A ^ k := pow_lt_pow_left₀ hrA h0.le hk.ne'
  have hrk : 0 < r ^ k := pow_pos h0 k
  -- strict per-column inequality
  have hcol : ((q : ℝ) * A ^ k) ^ 2 < base k q r * baseSq k q r := by
    have key : base k q r * baseSq k q r - ((q : ℝ) * A ^ k) ^ 2
        = (q : ℝ) * ((q : ℝ) - 1) ^ 2 * r ^ k * (A ^ k - r ^ k) := by
      simp only [base, baseSq, ← hA]; ring
    nlinarith [mul_pos (mul_pos (mul_pos hq0
      (by nlinarith : (0:ℝ) < ((q:ℝ) - 1) ^ 2)) hrk)
      (by linarith : (0:ℝ) < A ^ k - r ^ k)]
  have hEpos : (0 : ℝ) < (q : ℝ) * A ^ k := by positivity
  have hSqpos : 0 < expSectionsSq n k q r := expSectionsSq_pos n k q hq1 h0.le h1.le
  have hE2 : (expSections n k q r) ^ 2
      = (((q : ℝ) * (r + (1 - r) / q) ^ k) ^ 2) ^ n := by
    rw [expSections_eq n k q (by omega) r, ← pow_mul, mul_comm n 2, pow_mul]
  rw [div_lt_iff₀ hSqpos, hE2, sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r,
    expSectionsSq_eq n k q (by omega) r, ← mul_pow]
  exact pow_lt_pow_left₀ hcol (by positivity) hn.ne'

end DatabaseSheafSecondMoment