/-
# Finite `q`-Pochhammer symbols and the denominators of Nahm sums

The denominator of every Nahm-sum summand is a product of finite `q`-Pochhammer
symbols `(q;q)_n = ∏_{i=1}^{n} (1 - q^i)`.  Modularity of the whole sum is, on the
"numerator" side, controlled by the quadratic form (see `Discriminant.lean`); on
the "denominator" side it is controlled by these `q`-Pochhammer products, which are
the partition generating functions.

Here we record two genuinely non-trivial combinatorial facts about the polynomial
`(q;q)_n ∈ ℤ[q]` viewed as a polynomial in `q`:

## Main results
* `NahmRank4.qPochFactor_natDegree` — `deg (1 - X^{m+1}) = m+1`.
* `NahmRank4.qPoch_natDegree`       — `deg (q;q)_n = Σ_{i<n} (i+1)` (a triangular number).
* `NahmRank4.qPoch_natDegree_two_mul` — closed form `2·deg (q;q)_n = n(n+1)`.
* `NahmRank4.qPoch_coeff_zero`      — the constant term of `(q;q)_n` is `1`.
-/
import Mathlib

open Polynomial

namespace NahmRank4

/-- The finite `q`-Pochhammer symbol `(q;q)_n = ∏_{i=1}^{n}(1 - q^i)`, as a polynomial. -/
noncomputable def qPoch (n : ℕ) : ℤ[X] := ∏ i ∈ Finset.range n, (1 - X ^ (i + 1))

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): "The Nahm-sum denominator `(q;q)_n` has a clean,
--   triangular degree law `deg = 1 + 2 + ⋯ + n`, reflecting that its inverse is
--   the partition generating function graded by part size."
-- EXPERIMENT (Experimenter): compute `deg (q;q)_n` via `natDegree_prod`, which
--   needs each factor `1 - X^{i+1}` to be nonzero and to have degree `i+1`.
-- ANALYSIS (Analyst): `1 - X^{i+1} = -(X^{i+1}) + 1` has leading term `-X^{i+1}`
--   (degree `i+1`, leading coeff `-1 ≠ 0`), so the constant `1` does not raise the
--   degree; summing `i+1` over `i < n` gives the `n`-th triangular number.
-- CRITIQUE (Critic): `natDegree_prod` requires an integral domain and nonzero
--   factors — both genuinely used; this is not a `simp`-only fact.  The closed
--   form is stated as `2·deg = n(n+1)` to avoid the lossy integer division `/2`.
-- !-- end Lab Notes -- !--

/-- Each `q`-Pochhammer factor `1 - X^{m+1}` has degree `m+1`. -/
theorem qPochFactor_natDegree (m : ℕ) :
    ((1 - X ^ (m + 1) : ℤ[X])).natDegree = m + 1 := by
  rw [sub_eq_add_neg]
  rw [natDegree_add_eq_right_of_natDegree_lt] <;> simp

/-- **Degree of the finite `q`-Pochhammer symbol.**  `deg (q;q)_n = Σ_{i<n}(i+1)`. -/
theorem qPoch_natDegree (n : ℕ) :
    (qPoch n).natDegree = ∑ i ∈ Finset.range n, (i + 1) := by
  unfold qPoch
  rw [natDegree_prod]
  · exact Finset.sum_congr rfl (fun i _ => qPochFactor_natDegree i)
  · intro i _ hz
    have h := qPochFactor_natDegree i
    rw [hz] at h; simp at h

/-- **Closed form for the degree** (avoiding integer division): the degree of
`(q;q)_n` is the `n`-th triangular number `n(n+1)/2`. -/
theorem qPoch_natDegree_two_mul (n : ℕ) :
    2 * (qPoch n).natDegree = n * (n + 1) := by
  rw [qPoch_natDegree]
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, Nat.mul_add, ih]; ring

/-- The constant term of `(q;q)_n` is `1` (each factor contributes its constant `1`).
This is the partition-theoretic normalisation: the empty partition is counted once. -/
theorem qPoch_coeff_zero (n : ℕ) : (qPoch n).coeff 0 = 1 := by
  unfold qPoch
  rw [Polynomial.coeff_zero_eq_eval_zero, eval_prod, Finset.prod_eq_one]
  intro i _; simp

-- !-- Lab Notes -- !--
-- SYNTHESIS (Principal Investigator): the Nahm-sum denominator is, term by term, a
--   polynomial of triangular degree with unit constant term.  The triangular degree
--   `n(n+1)/2` is precisely the quadratic growth that the numerator exponent `Q(n)`
--   must balance for the full series to be a modular (eta-quotient) object — the
--   "denominator" half of the modularity bookkeeping that the discriminant
--   conjecture quantifies on the "numerator" side.
-- !-- end Lab Notes -- !--

end NahmRank4