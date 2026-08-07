import Applications.AdjacentSumPolytopes.Growth

/-!
# Parity classes: even counts are sums of squares, and both classes are log-convex

The transfer matrix `adjMat s` is symmetric.  This forces two structural facts that link
the two parity classes of the adjacent-sum model:

* **Even = sum of squares.**  A cyclic count of *even* length `2k` is the squared
  Frobenius norm of the `k`-th power of the transfer matrix, and an open count of even
  length is the squared Euclidean norm of the vector of row sums
  (`cycCount_even_eq_sum_sq`, `openCount_even_eq_sum_sq`).
* **Log-convexity.**  Cauchy–Schwarz then gives
  `c(m+n)² ≤ c(2m) · c(2n)` for both the cyclic and the open counting sequences
  (`cycCount_sq_le`, `openCount_sq_le`): each odd-index count is controlled by the two
  neighbouring even-index counts.  Equivalently, `k ↦ log c(k)` is midpoint convex along
  the even/odd interleaving, so the even class dominates the odd class.

These are exactly the statements that make the two parity classes comparable even though
their generating-function *numerators* differ (the denominator being shared, by
`Applications.AdjacentSumPolytopes.Recurrence`).

-- !-- Lab Notes -- !--
* **Hypothesis.** Symmetry of the constraint `a + b ≤ s` should make even-length counts
  sums of squares, hence force a Cauchy–Schwarz relation between the parity classes.
* **Experiment.** `s = 2`: cyclic counts `c(d) = #cyclic of length d+1` are
  `2, 6, 11, 26, 57, 129, 289`.  Testing `c(p+q+1)² ≤ c(2p+1)·c(2q+1)` at `p = 0, q = 1`:
  `c(2)² = 121 ≤ c(1)·c(3) = 6·26 = 156` ✓; at `p = 1, q = 2`: `c(4)² = 3249 ≤
  c(3)·c(5) = 26·129 = 3354` ✓ — tight but valid.  Open counts `3, 6, 14, 31, 70, 157`:
  `o(3)² = 961 ≤ o(2)·o(4) = 14·70 = 980` ✓.
* **Analysis.** The margin shrinks as `d` grows, as it must: log-convexity is asymptotically
  an equality for a sequence dominated by a single exponential.  This is independent
  evidence for a *simple* dominant pole.
* **Critique.** Both inequalities are proved for all `s` and all `m, n` with no hypotheses;
  the equality cases (`m = n`) are genuine equalities, so the bound cannot be improved
  to a strict inequality.
-/

namespace AdjSum

open Finset Matrix

variable {s : ℕ}

lemma adjMat_pow_symm (s k : ℕ) (a b : Fin (s + 1)) :
    (adjMat s ^ k) b a = (adjMat s ^ k) a b := by
  have h : ((adjMat s) ^ k).IsSymm := (adjMat_isSymm s).pow k
  exact congrFun (congrFun h a) b

/-! ## Even counts as sums of squares -/

/-- The trace of `M^(m+n)` is the "Frobenius inner product" of `M^m` and `M^n`. -/
theorem trace_pow_add (s m n : ℕ) :
    Matrix.trace (adjMat s ^ (m + n))
      = ∑ a, ∑ b, (adjMat s ^ m) a b * (adjMat s ^ n) a b := by
  rw [pow_add, trace_eq_sum]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [Matrix.mul_apply]
  refine Finset.sum_congr rfl (fun b _ => ?_)
  rw [adjMat_pow_symm s n a b]

/-- **Even cyclic counts are sums of squares.** -/
theorem cycCount_even_eq_sum_sq (s k : ℕ) :
    cycCount s (2 * k + 1) = ∑ a, ∑ b, ((adjMat s ^ (k + 1)) a b) ^ 2 := by
  rw [cycCount, card_cycSet, show 2 * k + 1 + 1 = (k + 1) + (k + 1) from by omega,
    trace_pow_add]
  exact Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun b _ => (sq _).symm))

/-- The row sums of the powers of the transfer matrix. -/
def rowSum (s k : ℕ) (c : Fin (s + 1)) : ℕ := ∑ b, (adjMat s ^ k) c b

/-- The total number of open points of length `m + n + 1` is the inner product of the
row-sum vectors of `M^m` and `M^n`. -/
theorem sum_pow_add (s m n : ℕ) :
    ∑ a, ∑ b, (adjMat s ^ (m + n)) a b = ∑ c, rowSum s m c * rowSum s n c := by
  have h1 : ∀ a b : Fin (s + 1),
      (adjMat s ^ (m + n)) a b = ∑ c, (adjMat s ^ m) a c * (adjMat s ^ n) c b := by
    intro a b
    rw [pow_add, Matrix.mul_apply]
  simp_rw [h1]
  rw [Finset.sum_comm]
  rw [Finset.sum_congr rfl (fun b (_ : b ∈ (Finset.univ : Finset (Fin (s + 1)))) =>
    Finset.sum_comm (s := (Finset.univ : Finset (Fin (s + 1))))
      (t := (Finset.univ : Finset (Fin (s + 1))))
      (f := fun a c => (adjMat s ^ m) a c * (adjMat s ^ n) c b))]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  rw [rowSum, rowSum, Finset.sum_mul_sum]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun b _ => ?_)
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [adjMat_pow_symm s m c b]

/-- **Even open counts are sums of squares** (of the row sums). -/
theorem openCount_even_eq_sum_sq (s k : ℕ) :
    openCount s (2 * k) = ∑ c, (rowSum s k c) ^ 2 := by
  rw [openCount, card_openSet, show 2 * k = k + k from by omega, sum_pow_add]
  exact Finset.sum_congr rfl (fun c _ => (sq _).symm)

/-! ## Log-convexity of both parity classes -/

/-- **Log-convexity of the cyclic counts.**  `c(p+q+1)² ≤ c(2p+1) · c(2q+1)`. -/
theorem cycCount_sq_le (s p q : ℕ) :
    (cycCount s (p + q + 1)) ^ 2 ≤ cycCount s (2 * p + 1) * cycCount s (2 * q + 1) := by
  have hmn : cycCount s (p + q + 1)
      = ∑ x : Fin (s + 1) × Fin (s + 1),
          (adjMat s ^ (p + 1)) x.1 x.2 * (adjMat s ^ (q + 1)) x.1 x.2 := by
    rw [cycCount, card_cycSet, show p + q + 1 + 1 = (p + 1) + (q + 1) from by omega,
      trace_pow_add, Fintype.sum_prod_type]
  have hp : cycCount s (2 * p + 1)
      = ∑ x : Fin (s + 1) × Fin (s + 1), ((adjMat s ^ (p + 1)) x.1 x.2) ^ 2 := by
    rw [cycCount_even_eq_sum_sq, Fintype.sum_prod_type]
  have hq : cycCount s (2 * q + 1)
      = ∑ x : Fin (s + 1) × Fin (s + 1), ((adjMat s ^ (q + 1)) x.1 x.2) ^ 2 := by
    rw [cycCount_even_eq_sum_sq, Fintype.sum_prod_type]
  rw [hmn, hp, hq]
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _

/-- **Log-convexity of the open counts.**  `o(m+n)² ≤ o(2m) · o(2n)`. -/
theorem openCount_sq_le (s m n : ℕ) :
    (openCount s (m + n)) ^ 2 ≤ openCount s (2 * m) * openCount s (2 * n) := by
  rw [openCount, card_openSet, sum_pow_add, openCount_even_eq_sum_sq,
    openCount_even_eq_sum_sq]
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _

/-- Consequence: the odd-index cyclic count is dominated by the geometric mean of its
even-index neighbours; in particular `c(k+1)² ≤ c(k) · c(k+2)` for odd `k`. -/
theorem cycCount_sq_le_neighbours (s k : ℕ) :
    (cycCount s (2 * k + 2)) ^ 2 ≤ cycCount s (2 * k + 1) * cycCount s (2 * k + 3) := by
  have h := cycCount_sq_le s k (k + 1)
  rw [show k + (k + 1) + 1 = 2 * k + 2 from by omega,
    show 2 * (k + 1) + 1 = 2 * k + 3 from by omega] at h
  exact h

end AdjSum