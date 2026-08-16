import Mathlib
import Computation.DatabaseSheafProbability

/-!
# The binomial tail is the exact difficulty parameter

`Catalog/Computation/DatabaseSheafProbability.lean` proves the exact law
`P(sheaf) = base(k,q,r)^n` with `base = q·A^k − (q−1)·r^k`, `A = r + (1−r)/q`,
and `Catalog/Computation/DatabasePairBound.lean` gives the one-sided pair union
bound `1 − base ≤ C(k,2)(1−1/q)(1−r)²`.  This file closes the two-sided version
(conjecture **N2** of the previous cycle) by identifying the exact quantity that
controls the per-column failure probability:

  `tail(k,r) = P[ at least two of the k rows of a column are observed ]
             = 1 − r^k − k(1−r)r^{k−1}`.

Main results.
* `one_sub_base_eq_tail_sum` — the per-column failure probability is the binomial
  tail *weighted by the disagreement probabilities* `1 − q^{1−j}`:
  `1 − base(k,q,r) = ∑_{j ≥ 2} C(k,j)(1−r)^j r^{k−j} (1 − q^{1−j})`.
* `one_sub_base_le_tail`, `one_sub_base_ge_tail` — the two-sided sandwich
  `(1 − 1/q)·tail(k,r) ≤ 1 − base(k,q,r) ≤ tail(k,r)`.
  The two bounds differ only by the factor `1 − 1/q ≥ 1/2` (for `q ≥ 2`), so the
  binomial tail determines the failure probability up to an absolute constant:
  *the difficulty parameter of a random database is `n·tail(k,r)`*, and nothing
  finer than the tail is needed.
* `sheafProb_sandwich` — consequently
  `(1 − tail)^n ≤ P(sheaf) ≤ (1 − (1−1/q)·tail)^n`.
* `sheafProb_le_exp`, `sheafProb_ge_one_sub_mul` — the resulting threshold:
  `P(sheaf) ≤ exp(−n(1−1/q)·tail)` and `P(sheaf) ≥ 1 − n·tail`.  Hence
  `P(sheaf) → 1` when `n·tail → 0` and `P(sheaf) → 0` when `n·tail → ∞`; the
  transition happens exactly at `n·tail(k,r) ≍ 1`.
* `tail_ge_pair` — `tail ≥ C(k,2)(1−r)²r^{k−2}`, the lower bound matching the
  upper bound `1 − base ≤ C(k,2)(1−1/q)(1−r)²` of `DatabasePairBound.lean`.  So
  in the sparse regime the pair count `C(k,2)` is sharp to within the factor
  `r^{k−2}`.

-- !-- Lab Notes -- !--
Hypothesis (N2 of the previous cycle): the pair bound is sharp to leading order,
and the true difficulty parameter is `n·k²(1−r)²` rather than the missing rate.
Experiment: expand `base` binomially.  Writing `p = 1 − r`, the closed form gives
`base = ∑_{j=0}^k C(k,j) p^j r^{k−j} q^{1−j}` corrected at `j = 0`, while
`1 = ∑_j C(k,j) p^j r^{k−j}`.  Subtracting, the `j = 0` and `j = 1` terms cancel
*identically* (`q·q^{-1} = 1`), leaving only `j ≥ 2`.
Analysis: the surviving weights `1 − q^{1−j}` lie in `[1 − 1/q, 1]` for all
`j ≥ 2`, which is exactly the sandwich.  The identification of the free variable
is the real content: it is the binomial tail `P[Bin(k,1−r) ≥ 2]`, not `k²(1−r)²`,
which is only its sparse-regime asymptotics (`tail ≤ C(k,2)p²` by the union bound
of `DatabasePairBound.lean`, `tail ≥ C(k,2)p²r^{k−2}` by `tail_ge_pair`).
Critique: the conjectured form `c₁ min(1, k²(1−r)²) ≤ 1 − base` is *false* as an
equality of orders in the dense regime — with `k` large and `r` fixed in `(0,1)`
the tail is nearly `1` while `k²(1−r)²` explodes — so the min-truncation is
essential and the honest statement is the one in terms of the tail itself.
Synthesis: `1 − base ≍ tail(k,r)` with explicit constants `1 − 1/q` and `1`, and
`P(sheaf)` has a genuine threshold at `n·tail(k,r) ≍ 1`.
-- !-- Lab Notes -- !--
-/

namespace DatabaseBinomialTail

open DatabaseSheafProb Finset

/-! ### The binomial decomposition of the per-column probability -/

/-- The binomial term: probability that exactly the `j`-element observation
patterns occur in a column, summed over all of them. -/
noncomputable def term (k : ℕ) (r : ℝ) (j : ℕ) : ℝ :=
  (1 - r) ^ j * r ^ (k - j) * (k.choose j : ℝ)

/-- The binomial tail: probability that at least two rows of a column are
observed. -/
noncomputable def tail (k : ℕ) (r : ℝ) : ℝ := ∑ j ∈ Finset.Ico 2 (k + 1), term k r j

lemma term_nonneg (k : ℕ) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) (j : ℕ) : 0 ≤ term k r j := by
  have : (0 : ℝ) ≤ 1 - r := by linarith
  exact mul_nonneg (mul_nonneg (pow_nonneg this j) (pow_nonneg h0 _)) (Nat.cast_nonneg _)

lemma term_zero (k : ℕ) (r : ℝ) : term k r 0 = r ^ k := by simp [term]

lemma term_one (k : ℕ) (r : ℝ) : term k r 1 = (1 - r) * r ^ (k - 1) * k := by
  simp [term]

/-- The full binomial sum is `1`. -/
lemma sum_term (k : ℕ) (r : ℝ) : ∑ j ∈ range (k + 1), term k r j = 1 := by
  have h := add_pow (1 - r) r k
  have hone : (1 - r) + r = 1 := by ring
  rw [hone, one_pow] at h
  simpa [term] using h.symm

/-- Binomial expansion of the closed form `base`. -/
lemma base_eq_sum (k q : ℕ) (hq : 0 < q) (r : ℝ) :
    base k q r
      = (∑ j ∈ range (k + 1), term k r j * ((q : ℝ) * ((q : ℝ)⁻¹) ^ j))
        - ((q : ℝ) - 1) * r ^ k := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  have h := add_pow ((1 - r) / q) r k
  have hA : r + (1 - r) / (q : ℝ) = (1 - r) / q + r := by ring
  rw [base, hA, h, Finset.mul_sum]
  congr 1
  refine Finset.sum_congr rfl fun j _ => ?_
  simp only [term, div_pow, inv_pow]
  field_simp

/-- The per-column failure probability, expanded binomially. -/
lemma one_sub_base_eq_sum (k q : ℕ) (hq : 0 < q) (r : ℝ) :
    1 - base k q r
      = (∑ j ∈ range (k + 1), term k r j * (1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ j))
        + ((q : ℝ) - 1) * r ^ k := by
  have hsplit :
      ∑ j ∈ range (k + 1), term k r j * (1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ j)
        = (∑ j ∈ range (k + 1), term k r j)
          - ∑ j ∈ range (k + 1), term k r j * ((q : ℝ) * ((q : ℝ)⁻¹) ^ j) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [hsplit, sum_term, base_eq_sum k q hq r]
  ring

/-- Splitting a sum over `range (k+1)` into its first two terms and the rest. -/
lemma sum_split_two {k : ℕ} (hk : 1 ≤ k) (f : ℕ → ℝ) :
    ∑ j ∈ range (k + 1), f j = f 0 + f 1 + ∑ j ∈ Finset.Ico 2 (k + 1), f j := by
  have hcons :
      (∑ j ∈ Finset.Ico 0 2, f j) + ∑ j ∈ Finset.Ico 2 (k + 1), f j
        = ∑ j ∈ Finset.Ico 0 (k + 1), f j :=
    Finset.sum_Ico_consecutive f (by omega) (by omega)
  have hlow : ∑ j ∈ Finset.Ico 0 2, f j = f 0 + f 1 := by
    rw [← Finset.range_eq_Ico]
    simp [Finset.sum_range_succ]
  rw [Finset.range_eq_Ico, ← hcons, hlow]

/-- **The failure probability is a weighted binomial tail.** Only observation
patterns with at least two observed rows can break the sheaf condition, and such
a pattern breaks it with probability `1 − q^{1−j}`. -/
theorem one_sub_base_eq_tail_sum (k q : ℕ) (hq : 0 < q) (r : ℝ) :
    1 - base k q r
      = ∑ j ∈ Finset.Ico 2 (k + 1), term k r j * (1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ j) := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  rcases Nat.eq_zero_or_pos k with hk | hk
  · subst hk
    simp [base]
  · rw [one_sub_base_eq_sum k q hq r,
      sum_split_two hk (fun j => term k r j * (1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ j))]
    have h0 : term k r 0 * (1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ 0) = r ^ k * (1 - q) := by
      rw [term_zero]; ring
    have h1 : term k r 1 * (1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ 1) = 0 := by
      have : (q : ℝ) * ((q : ℝ)⁻¹) ^ 1 = 1 := by field_simp
      rw [this]; ring
    rw [h0, h1]
    ring

/-! ### The two-sided sandwich -/

lemma weight_le_one (q : ℕ) (hq : 1 ≤ q) (j : ℕ) :
    1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ j ≤ 1 := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have : 0 ≤ (q : ℝ) * ((q : ℝ)⁻¹) ^ j :=
    mul_nonneg hq0.le (pow_nonneg (inv_nonneg.2 hq0.le) j)
  linarith

lemma le_weight (q : ℕ) (hq : 1 ≤ q) {j : ℕ} (hj : 2 ≤ j) :
    1 - 1 / (q : ℝ) ≤ 1 - (q : ℝ) * ((q : ℝ)⁻¹) ^ j := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  have hinv1 : (q : ℝ)⁻¹ ≤ 1 := by
    rw [inv_le_one₀ hq0]; exact hq1
  have hmono : ((q : ℝ)⁻¹) ^ j ≤ ((q : ℝ)⁻¹) ^ 2 :=
    pow_le_pow_of_le_one (inv_nonneg.2 hq0.le) hinv1 hj
  have hkey : (q : ℝ) * ((q : ℝ)⁻¹) ^ j ≤ 1 / (q : ℝ) := by
    calc (q : ℝ) * ((q : ℝ)⁻¹) ^ j ≤ (q : ℝ) * ((q : ℝ)⁻¹) ^ 2 := by
          exact mul_le_mul_of_nonneg_left hmono hq0.le
      _ = 1 / (q : ℝ) := by field_simp
  linarith

lemma tail_nonneg (k : ℕ) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) : 0 ≤ tail k r :=
  Finset.sum_nonneg fun j _ => term_nonneg k h0 h1 j

/-- **Upper bound.** A column can only fail if two of its rows are observed. -/
theorem one_sub_base_le_tail (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    1 - base k q r ≤ tail k r := by
  rw [one_sub_base_eq_tail_sum k q (by omega) r]
  refine Finset.sum_le_sum fun j _ => ?_
  have := term_nonneg k h0 h1 j
  nlinarith [weight_le_one q hq j]

/-- **Matching lower bound.** Whenever two rows are observed they disagree with
probability at least `1 − 1/q`, so the failure probability is at least
`(1 − 1/q)` times the binomial tail. -/
theorem one_sub_base_ge_tail (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    (1 - 1 / (q : ℝ)) * tail k r ≤ 1 - base k q r := by
  rw [one_sub_base_eq_tail_sum k q (by omega) r, tail, Finset.mul_sum]
  refine Finset.sum_le_sum fun j hj => ?_
  have hj2 : 2 ≤ j := (Finset.mem_Ico.1 hj).1
  have hterm := term_nonneg k h0 h1 j
  have hw := le_weight q hq hj2
  nlinarith

/-! ### Closed form of the tail -/

/-- The binomial tail in closed form: `1` minus the probabilities of observing
zero or one row. -/
theorem tail_eq (k : ℕ) (r : ℝ) :
    tail k r = 1 - r ^ k - (k : ℝ) * (1 - r) * r ^ (k - 1) := by
  rcases Nat.eq_zero_or_pos k with hk | hk
  · subst hk; simp [tail]
  · have h := sum_split_two hk (term k r)
    rw [sum_term, term_zero, term_one] at h
    simp only [tail]
    linarith [h]

lemma tail_le_one (k : ℕ) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) : tail k r ≤ 1 := by
  rw [tail_eq]
  have h2 : 0 ≤ r ^ k := pow_nonneg h0 k
  have h3 : 0 ≤ (k : ℝ) * (1 - r) * r ^ (k - 1) :=
    mul_nonneg (mul_nonneg (Nat.cast_nonneg _) (by linarith)) (pow_nonneg h0 _)
  linarith

/-- **The pair count is a lower bound too.** Complementing the union bound
`1 − base ≤ C(k,2)(1−1/q)(1−r)²` of `DatabasePairBound.lean`. -/
theorem tail_ge_pair (k : ℕ) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) (hk : 2 ≤ k) :
    (k.choose 2 : ℝ) * (1 - r) ^ 2 * r ^ (k - 2) ≤ tail k r := by
  have hmem : (2 : ℕ) ∈ Finset.Ico 2 (k + 1) := Finset.mem_Ico.2 ⟨le_rfl, by omega⟩
  have hsingle : term k r 2 ≤ tail k r :=
    Finset.single_le_sum (f := fun j => term k r j)
      (fun j _ => term_nonneg k h0 h1 j) hmem
  simpa [term, mul_comm, mul_left_comm, mul_assoc] using hsingle

/-! ### Consequences for the sheaf probability -/

theorem base_le_one_sub (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    base k q r ≤ 1 - (1 - 1 / (q : ℝ)) * tail k r := by
  linarith [one_sub_base_ge_tail k q hq h0 h1]

theorem one_sub_tail_le_base (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    1 - tail k r ≤ base k q r := by
  linarith [one_sub_base_le_tail k q hq h0 h1]

/-- **Two-sided law for the sheaf probability.** The whole law is pinned between
two powers whose bases differ by the factor `1 − 1/q` on the tail. -/
theorem sheafProb_sandwich (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    (1 - tail k r) ^ n ≤ sheafProb n k q r ∧
      sheafProb n k q r ≤ (1 - (1 - 1 / (q : ℝ)) * tail k r) ^ n := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  have hqa : 0 ≤ 1 - 1 / (q : ℝ) := by
    have : 1 / (q : ℝ) ≤ 1 := by rw [div_le_one hq0]; exact hq1
    linarith
  have hlaw : sheafProb n k q r = base k q r ^ n := by
    rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r]
  have hbase0 : 0 ≤ base k q r := base_nonneg k q hq h0 h1
  have htail1 : tail k r ≤ 1 := tail_le_one k h0 h1
  refine ⟨?_, ?_⟩
  · rw [hlaw]
    exact pow_le_pow_left₀ (by linarith) (one_sub_tail_le_base k q hq h0 h1) n
  · rw [hlaw]
    exact pow_le_pow_left₀ hbase0 (base_le_one_sub k q hq h0 h1) n

/-- **Upper threshold bound.** `P(sheaf) ≤ exp(−n(1−1/q)·tail)`: the sheaf
condition fails with high probability once `n·tail(k,r) → ∞`. -/
theorem sheafProb_le_exp (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    sheafProb n k q r ≤ Real.exp (-((n : ℝ) * ((1 - 1 / (q : ℝ)) * tail k r))) := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  have hqa : 0 ≤ 1 - 1 / (q : ℝ) := by
    have : 1 / (q : ℝ) ≤ 1 := by rw [div_le_one hq0]; exact hq1
    linarith
  have hqa1 : 1 - 1 / (q : ℝ) ≤ 1 := by
    have : 0 ≤ 1 / (q : ℝ) := by positivity
    linarith
  set a : ℝ := (1 - 1 / (q : ℝ)) * tail k r with hadef
  have ha0 : 0 ≤ a := mul_nonneg hqa (tail_nonneg k h0 h1)
  have ha1 : a ≤ 1 := by
    have := tail_le_one k h0 h1
    nlinarith [tail_nonneg k h0 h1]
  have hstep : (1 : ℝ) - a ≤ Real.exp (-a) := by
    have := Real.add_one_le_exp (-a)
    linarith
  calc sheafProb n k q r ≤ (1 - a) ^ n := (sheafProb_sandwich n k q hq h0 h1).2
    _ ≤ (Real.exp (-a)) ^ n := pow_le_pow_left₀ (by linarith) hstep n
    _ = Real.exp (-((n : ℝ) * a)) := by
        rw [← Real.exp_nat_mul]; ring_nf

/-- **Lower threshold bound.** `P(sheaf) ≥ 1 − n·tail`: the sheaf condition holds
with high probability as soon as `n·tail(k,r) → 0`. -/
theorem sheafProb_ge_one_sub_mul (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    1 - (n : ℝ) * tail k r ≤ sheafProb n k q r := by
  have ht0 : 0 ≤ tail k r := tail_nonneg k h0 h1
  have ht1 : tail k r ≤ 1 := tail_le_one k h0 h1
  have hbern : 1 + (n : ℝ) * (-(tail k r)) ≤ (1 + -(tail k r)) ^ n :=
    one_add_mul_le_pow (by linarith) n
  have := (sheafProb_sandwich n k q hq h0 h1).1
  have heq : (1 : ℝ) - tail k r = 1 + -(tail k r) := by ring
  rw [heq] at this
  linarith

end DatabaseBinomialTail