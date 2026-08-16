import Mathlib
import Computation.DatabaseSheafProbability

/-!
# Where the binomial coefficient really belongs

The assignment conjectured `P(sheaf) = (1−r)^{C(n,k)}`, a binomial coefficient in
the *exponent*.  `Catalog/Computation/DatabaseSheafProbability.lean` refutes that
law and replaces it by the exact one, `P(sheaf) = base(k,q,r)^n` with
`base = q·A^k − (q−1)·r^k` and `A = r + (1−r)/q`, in which no binomial
coefficient occurs.

This file rescues the binomial coefficient in its correct role.  A column fails
the sheaf condition exactly when *some pair* of its rows is observed with
different values, so a union bound over the `C(k,2)` pairs of rows gives the
per-column failure probability an upper bound `C(k,2)·(1−1/q)·(1−r)²`.  We prove
this inequality directly from the closed form, and show it is an *equality* for
two rows.

Main results.
* `base_two_exact` — for `k = 2` rows the law is exactly
  `P(sheaf) = (1 − (1−1/q)(1−r)²)^n`; the failure probability is the probability
  that the two rows are both observed and differ.
* `one_sub_base_le_pairs` — the pair union bound
  `1 − base(k,q,r) ≤ C(k,2)·(1−1/q)·(1−r)²` for every `k`, `q ≥ 1`,
  `r ∈ [0,1]`.  The binomial coefficient counts *pairs of rows*, appears as a
  linear factor rather than an exponent, and multiplies `(1−r)²` rather than
  `(1−r)`.
* `sheafProb_ge_pairs`, `sheafProb_ge_linear` — consequently
  `P(sheaf) ≥ 1 − n·C(k,2)·(1−1/q)·(1−r)²`: databases with many columns still
  glue with high probability as long as `n·k²·(1−r)² → 0`, a threshold in which
  the number of rows enters quadratically and the missing rate enters through
  `(1−r)²`.

-- !-- Lab Notes -- !--
Hypothesis: the binomial coefficient of the original conjecture is not spurious
but misplaced; it should count pairs of rows in a union bound.
Experiment: expand `1 − base(k,q,r)` near `r = 1`; the first-order terms cancel
because `q·a = q−1` for `a = (q−1)/q`, leaving `C(k,2)·a·(1−r)²` at second order.
Then prove the corresponding global inequality by induction on `k`, using
`x^k − y^k ≤ k(x−y)` on `0 ≤ y ≤ x ≤ 1`.
Analysis: the increment `g(k+1) − g(k)` of the failure probability equals
`(1−r)(q−1)(A^k − r^k) ≤ k·a·(1−r)²`, and summing the arithmetic progression
gives exactly the binomial coefficient `C(k,2) = 0 + 1 + ⋯ + (k−1)`.  For `k = 2`
the bound is an identity, so the estimate is sharp at the first nontrivial row
count.
Critique: the bound is one-sided; for small `r` it is far from tight (at `r = 0`
the true failure probability tends to `1` while the bound grows like `k²`), so it
is informative only in the sparse-observation regime `k(1−r) ≪ 1`.
Synthesis: `(1−r)^{C(n,k)}` is false, but `1 − P(sheaf)^{1/n} ≤ C(k,2)(1−1/q)(1−r)²`
is true: the binomial coefficient counts overlapping *pairs of rows*, and the
correct small parameter is `(1−r)²`, the probability that both members of a pair
are observed.
-- !-- Lab Notes -- !--
-/

namespace DatabasePairBound

open DatabaseSheafProb

/-! ### An elementary power inequality -/

/-- On `[0,1]`, the `k`-th powers of two points differ by at most `k` times the
distance between them. -/
theorem pow_sub_pow_le_mul (k : ℕ) {x y : ℝ} (hy : 0 ≤ y) (hxy : y ≤ x) (hx : x ≤ 1) :
    x ^ k - y ^ k ≤ k * (x - y) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hx0 : 0 ≤ x := hy.trans hxy
      have hmono : y ^ k ≤ x ^ k := pow_le_pow_left₀ hy hxy k
      have hyk : y ^ k ≤ 1 := pow_le_one₀ hy (hxy.trans hx)
      have hstep : x ^ (k + 1) - y ^ (k + 1) = x * (x ^ k - y ^ k) + y ^ k * (x - y) := by
        ring
      have h1 : x * (x ^ k - y ^ k) ≤ x ^ k - y ^ k :=
        mul_le_of_le_one_left (by linarith) hx
      have h2 : y ^ k * (x - y) ≤ x - y :=
        mul_le_of_le_one_left (by linarith) hyk
      rw [hstep]
      push_cast
      linarith [ih]

/-! ### The two-row law, exactly -/

/-- **Two rows: an exact quadratic law.** For `k = 2` the per-column probability
is `1 − (1−1/q)(1−r)²`: the failure probability is exactly the probability that
both rows are observed (`(1−r)²`) and disagree (`1 − 1/q`). -/
theorem base_two_exact (q : ℕ) (hq : 0 < q) (r : ℝ) :
    base 2 q r = 1 - (1 - 1 / (q : ℝ)) * (1 - r) ^ 2 := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  simp only [base]
  field_simp
  ring

/-- The exact law for two rows, in the form of a probability. -/
theorem sheafProb_two (n q : ℕ) (hq : 0 < q) (r : ℝ) :
    sheafProb n 2 q r = (1 - (1 - 1 / (q : ℝ)) * (1 - r) ^ 2) ^ n := by
  rw [sheafProb_eq_baseSum_pow, baseSum_eq_base 2 q hq r, base_two_exact q hq r]

/-! ### The pair union bound -/

/-- **The binomial coefficient counts pairs of rows.** The per-column failure
probability of the sheaf condition is at most the number of pairs of rows times
the probability `(1−1/q)(1−r)²` that a fixed pair is observed twice and
disagrees. -/
theorem one_sub_base_le_pairs (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    1 - base k q r ≤ ((k : ℝ) * (k - 1) / 2) * (1 - 1 / (q : ℝ)) * (1 - r) ^ 2 := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  set a : ℝ := 1 - 1 / (q : ℝ) with ha
  have ha0 : 0 ≤ a := by
    have : 1 / (q : ℝ) ≤ 1 := by
      rw [div_le_one hq0]; exact hq1
    simp only [ha]; linarith
  set A : ℝ := r + (1 - r) / q with hAdef
  have hA1 : A ≤ 1 := by
    have hdiv : (1 - r) / (q : ℝ) ≤ 1 - r := div_le_self (by linarith) hq1
    simp only [hAdef]; linarith
  have hAr : r ≤ A := by
    have : 0 ≤ (1 - r) / (q : ℝ) := div_nonneg (by linarith) hq0.le
    simp only [hAdef]; linarith
  have hArdiff : A - r = (1 - r) / q := by simp only [hAdef]; ring
  -- the failure probability, as a function of the number of rows
  induction k with
  | zero => simp [base]
  | succ k ih =>
      have hqA : (q : ℝ) * (1 - A) = (1 - r) * ((q : ℝ) - 1) := by
        rw [hAdef]; field_simp; ring
      have hstep : (1 - base (k + 1) q r) - (1 - base k q r)
          = (1 - r) * ((q : ℝ) - 1) * (A ^ k - r ^ k) := by
        simp only [base, ← hAdef, pow_succ]
        linear_combination (A ^ k) * hqA
      have hpow : A ^ k - r ^ k ≤ (k : ℝ) * ((1 - r) / q) :=
        hArdiff ▸ pow_sub_pow_le_mul k h0 hAr hA1
      have hpos : 0 ≤ (1 - r) * ((q : ℝ) - 1) := by
        have : (0 : ℝ) ≤ 1 - r := by linarith
        nlinarith
      have hincr : (1 - base (k + 1) q r) - (1 - base k q r)
          ≤ (k : ℝ) * a * (1 - r) ^ 2 := by
        have hmul : (1 - r) * ((q : ℝ) - 1) * (A ^ k - r ^ k)
            ≤ (1 - r) * ((q : ℝ) - 1) * ((k : ℝ) * ((1 - r) / q)) :=
          mul_le_mul_of_nonneg_left hpow hpos
        have hrw : (1 - r) * ((q : ℝ) - 1) * ((k : ℝ) * ((1 - r) / q))
            = (k : ℝ) * a * (1 - r) ^ 2 := by
          simp only [ha]
          field_simp
        rw [hstep, ← hrw]
        exact hmul
      have hk : ((k : ℝ) + 1) * ((k : ℝ) + 1 - 1) / 2
          = (k : ℝ) * ((k : ℝ) - 1) / 2 + (k : ℝ) := by ring
      have := ih
      push_cast
      push_cast at this
      rw [hk]
      have hsq : 0 ≤ (1 - r) ^ 2 := sq_nonneg _
      nlinarith [hincr, this]

/-- **Consequence for the exact law.** As long as the pair bound is itself a
probability, it lower-bounds the exact law columnwise. -/
theorem sheafProb_ge_pairs (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1)
    (hple : ((k : ℝ) * (k - 1) / 2) * (1 - 1 / (q : ℝ)) * (1 - r) ^ 2 ≤ 1) :
    (1 - ((k : ℝ) * (k - 1) / 2) * (1 - 1 / (q : ℝ)) * (1 - r) ^ 2) ^ n
      ≤ sheafProb n k q r := by
  rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r]
  refine pow_le_pow_left₀ (by linarith) ?_ n
  have := one_sub_base_le_pairs k q hq h0 h1
  linarith

/-- **A linear (Bernoulli) form of the bound.** For `n` columns and `k` rows the
sheaf condition holds with probability at least
`1 − n·C(k,2)·(1−1/q)·(1−r)²`, so a database glues with high probability as soon
as `n·k²·(1−r)² → 0`.  No side condition is needed: when the bound exceeds one it
is vacuous. -/
theorem sheafProb_ge_linear (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    1 - (n : ℝ) * (((k : ℝ) * (k - 1) / 2) * (1 - 1 / (q : ℝ)) * (1 - r) ^ 2)
      ≤ sheafProb n k q r := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  have h1q : 1 / (q : ℝ) ≤ 1 := by rw [div_le_one hq0]; exact hq1
  set p : ℝ := ((k : ℝ) * (k - 1) / 2) * (1 - 1 / (q : ℝ)) * (1 - r) ^ 2 with hp
  have hp0 : 0 ≤ p := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp [hp]
    · have hk1 : (1 : ℝ) ≤ k := by exact_mod_cast hk
      have h2 : 0 ≤ (k : ℝ) * ((k : ℝ) - 1) / 2 := by nlinarith
      have h3 : 0 ≤ 1 - 1 / (q : ℝ) := by linarith
      simp only [hp]
      positivity
  have hProb_nonneg : 0 ≤ sheafProb n k q r := by
    rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r]
    exact pow_nonneg (base_nonneg k q hq h0 h1) n
  rcases le_or_gt p 1 with hple | hpgt
  · have hbern : 1 + (n : ℝ) * (-p) ≤ (1 + (-p)) ^ n :=
      one_add_mul_le_pow (by linarith) n
    have hge := sheafProb_ge_pairs n k q hq h0 h1 (by rw [← hp]; exact hple)
    rw [← hp] at hge
    have hrw : (1 : ℝ) - p = 1 + (-p) := by ring
    rw [hrw] at hge
    linarith
  · rcases Nat.eq_zero_or_pos n with rfl | hn
    · have : sheafProb 0 k q r = 1 := by
        rw [sheafProb_eq_baseSum_pow, pow_zero]
      simp [this]
    · have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
      have : p ≤ (n : ℝ) * p := le_mul_of_one_le_left hp0 hn1
      linarith

end DatabasePairBound