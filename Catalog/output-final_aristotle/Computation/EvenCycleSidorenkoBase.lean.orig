/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Base cases of Sidorenko's inequality: the even cycles `C₂` and `C₄`

The tensor-amplification framework (`Catalog/Computation/TensorAmplificationSidorenko.lean`)
shows that the Sidorenko property is *closed* under tensor products and that surpluses/deficits
are *amplified*.  To make the framework non-vacuous it must be seeded with weighted graphs that
provably satisfy the Sidorenko property.  This file supplies the two fundamental analytic seeds:
the **even cycles** `C₂` and `C₄`.

For a symmetric weighted graph `A`, we prove

* `sidorenko_two` : `t(C₂, A) ≥ t(K₂, A)²`, and
* `sidorenko_four` : `t(C₄, A) ≥ t(K₂, A)⁴`,

the first two instances of Sidorenko's conjecture for even cycles.  Both proofs are pure spectral
Cauchy–Schwarz arguments: `C₂` is a single application of Cauchy–Schwarz to the `|ι|²` entries,
and `C₄` chains two applications through the intermediate quantity `∑ (A²)ᵢⱼ = ∑ₖ (column-sumₖ)²`.
Remarkably, *neither result needs the edge weights to be nonnegative*: symmetry alone suffices,
because the closed-walk counts organise into genuine sums of squares.

Combined with `TensorSidorenko.Sidorenko_kron_even`, these seeds yield an entire tensor-closed
class of graphons satisfying the even-cycle Sidorenko inequality (`sidorenko_four_kron`), again
with no positivity assumption.

## Catalog connection

This file imports and applies `Catalog/Computation/TensorAmplificationSidorenko.lean`; the two
even-cycle inequalities are exactly the base cases that the transfer principles propagate.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The even cycles `C₂` and `C₄` satisfy Sidorenko for every symmetric
  weighted graph, and the proofs are elementary Cauchy–Schwarz once the closed-walk count is
  written as a sum of squares.
Experiment (Experimenter): `tr(A²) = ∑ᵢⱼ (Aᵢⱼ)²` for symmetric `A`; Cauchy–Schwarz on the `|ι|²`
  ordered pairs gives `(∑ Aᵢⱼ)² ≤ |ι|² ∑ (Aᵢⱼ)²`, which is exactly `C₂`.  For `C₄` we write
  `tr(A⁴) = ∑ᵢⱼ ((A²)ᵢⱼ)²`, apply Cauchy–Schwarz once to get `|ι|² tr(A⁴) ≥ (∑ (A²)ᵢⱼ)²`, and once
  more to bound `∑ (A²)ᵢⱼ = ∑ₖ (∑ᵢ Aᵢₖ)² ≥ (∑ Aᵢⱼ)² / |ι|`.
Analysis (Analyst): The proofs never inspect the sign of an entry — the intermediate quantities are
  sums of squares and are nonnegative automatically.  Consequently the anticipated nonnegativity
  hypothesis was *dropped*, strengthening both inequalities to all symmetric real weightings.  The
  empty vertex space is a harmless degenerate case (all densities `0`).
Critique (Critic): The inequalities are sharp (equality for constant graphons), so neither is
  vacuous.  Odd cycles are deliberately excluded: `C₃` does *not* satisfy Sidorenko in general,
  matching the classical restriction of the conjecture to bipartite host patterns.  The even-cycle
  closure inherits the same sign-freeness from `Sidorenko_kron_even`.
Synthesis (PI): Two sharp spectral seeds — valid for *all* symmetric weightings — that, via the
  even-cycle tensor transfer principle, generate an entire closed class of Sidorenko graphons.
-/
import Mathlib
import Computation.TensorAmplificationSidorenko

open Matrix BigOperators
open scoped Kronecker

namespace TensorSidorenko

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- For a symmetric weighted graph, `tr(A²)` is the sum of squared edge weights. -/
theorem trace_sq_symm (A : Matrix ι ι ℝ) (hsym : ∀ i j, A i j = A j i) :
    trace (A ^ 2) = ∑ i, ∑ j, (A i j) ^ 2 := by
  rw [pow_two, Matrix.trace_mul_comm]
  unfold Matrix.trace Matrix.diag
  simp only [Matrix.mul_apply]
  refine Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => ?_))
  rw [hsym j i, sq]

omit [DecidableEq ι] in
/-- Cauchy–Schwarz over the `|ι|²` ordered pairs: the squared total weight is at most `|ι|²` times
the sum of squared weights. -/
theorem sq_homEdge_le (A : Matrix ι ι ℝ) :
    (∑ i, ∑ j, A i j) ^ 2 ≤ (Fintype.card ι : ℝ) ^ 2 * (∑ i, ∑ j, (A i j) ^ 2) := by
  have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (ι × ι)))
    (f := fun p => A p.1 p.2)
  simp only [Fintype.sum_prod_type, Finset.card_univ, Fintype.card_prod] at h
  push_cast at h
  convert h using 2
  ring

/-- **Sidorenko for the 2-cycle `C₂`.** Every symmetric weighted graph satisfies
`t(C₂, A) ≥ t(K₂, A)²`. -/
theorem sidorenko_two (A : Matrix ι ι ℝ) (hsym : ∀ i j, A i j = A j i) :
    Sidorenko 2 A := by
  unfold Sidorenko tEdge tCycle homEdge homCycle
  rw [trace_sq_symm A hsym]
  set N : ℝ := (Fintype.card ι : ℝ) with hN
  have hk := sq_homEdge_le A
  have hNnn : (0 : ℝ) ≤ N := by positivity
  rcases eq_or_lt_of_le hNnn with h0 | hpos
  · rw [← h0]; simp
  · rw [div_pow, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hk, hpos, sq_nonneg N]

/-- For a symmetric weighted graph, `A²` is again symmetric. -/
theorem sq_symm (A : Matrix ι ι ℝ) (hsym : ∀ i j, A i j = A j i) :
    ∀ i j, (A ^ 2) i j = (A ^ 2) j i := by
  intro i j
  simp only [pow_two, Matrix.mul_apply]
  refine Finset.sum_congr rfl (fun k _ => ?_)
  rw [hsym i k, hsym k j, mul_comm]

/-- The total weight of `A²` equals the sum of squared column sums of `A`. -/
theorem sum_sq_eq (A : Matrix ι ι ℝ) (hsym : ∀ i j, A i j = A j i) :
    ∑ i, ∑ j, (A ^ 2) i j = ∑ k, (∑ i, A i k) ^ 2 := by
  simp only [pow_two, Matrix.mul_apply]
  have step : ∀ i : ι, (∑ j, ∑ k, A i k * A k j) = ∑ k, ∑ j, A i k * A k j :=
    fun _ => Finset.sum_comm
  simp only [step]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun k _ => ?_)
  rw [← Finset.sum_mul_sum]
  congr 1
  exact Finset.sum_congr rfl (fun j _ => hsym k j)

/-- **Sidorenko for the 4-cycle `C₄`.** Every symmetric weighted graph satisfies
`t(C₄, A) ≥ t(K₂, A)⁴`. -/
theorem sidorenko_four (A : Matrix ι ι ℝ) (hsym : ∀ i j, A i j = A j i) :
    Sidorenko 4 A := by
  unfold Sidorenko tEdge tCycle homEdge homCycle
  set N : ℝ := (Fintype.card ι : ℝ) with hN
  set S : ℝ := ∑ i, ∑ j, A i j with hS
  have hA4 : (A : Matrix ι ι ℝ) ^ 4 = (A ^ 2) ^ 2 := by rw [← pow_mul]
  have hTr : trace (A ^ 4) = ∑ i, ∑ j, ((A ^ 2) i j) ^ 2 := by
    rw [hA4, trace_sq_symm (A ^ 2) (sq_symm A hsym)]
  set Tr : ℝ := trace (A ^ 4) with hTrdef
  set T : ℝ := ∑ i, ∑ j, (A ^ 2) i j with hTdef
  have hk1 : T ^ 2 ≤ N ^ 2 * Tr := by rw [hTr]; exact sq_homEdge_le (A ^ 2)
  have hmid : T = ∑ k, (∑ i, A i k) ^ 2 := sum_sq_eq A hsym
  have hSc : S = ∑ k, (∑ i, A i k) := by rw [hS]; exact Finset.sum_comm
  have hk2 : S ^ 2 ≤ N * T := by
    have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset ι))
      (f := fun k => ∑ i, A i k)
    rw [Finset.card_univ] at h
    rw [hSc, hmid]; convert h using 2
  have hT0 : 0 ≤ T := by rw [hmid]; exact Finset.sum_nonneg (fun k _ => sq_nonneg _)
  have hNnn : (0 : ℝ) ≤ N := by positivity
  rcases eq_or_lt_of_le hNnn with h0 | hpos
  · rw [← h0]; simp
  · rw [div_pow, div_le_div_iff₀ (by positivity) (by positivity)]
    have e1 : N ^ 6 * T ^ 2 ≤ N ^ 6 * (N ^ 2 * Tr) :=
      mul_le_mul_of_nonneg_left hk1 (by positivity)
    have hSq4 : S ^ 2 * S ^ 2 ≤ (N * T) * (N * T) :=
      mul_le_mul hk2 hk2 (sq_nonneg S) (mul_nonneg hNnn hT0)
    have e2 : N ^ 4 * (S ^ 2 * S ^ 2) ≤ N ^ 4 * ((N * T) * (N * T)) :=
      mul_le_mul_of_nonneg_left hSq4 (by positivity)
    nlinarith [e1, e2]

omit [Fintype ι] [DecidableEq ι] in
/-- The tensor product of two symmetric weighted graphs is symmetric. -/
theorem kron_symm {κ : Type*} (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ)
    (hA : ∀ i j, A i j = A j i) (hB : ∀ i j, B i j = B j i) :
    ∀ p q : ι × κ, (A ⊗ₖ B) p q = (A ⊗ₖ B) q p := by
  intro p q
  simp only [Matrix.kroneckerMap_apply]
  rw [hA, hB]

/-- **Closure of the `C₄`-Sidorenko class.** The tensor product of two symmetric weighted graphs
again satisfies `C₄`-Sidorenko: the analytic seed propagates through the even-cycle tensor transfer
principle, with no positivity assumption anywhere. -/
theorem sidorenko_four_kron {κ : Type*} [Fintype κ] [DecidableEq κ]
    (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ)
    (hAs : ∀ i j, A i j = A j i) (hBs : ∀ i j, B i j = B j i) :
    Sidorenko 4 (A ⊗ₖ B) :=
  Sidorenko_kron_even (by decide) (sidorenko_four A hAs) (sidorenko_four B hBs)

end TensorSidorenko