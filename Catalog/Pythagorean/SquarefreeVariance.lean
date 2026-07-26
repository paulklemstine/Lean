import Mathlib

/-!
# Variance of the squarefree indicator

We consider the uniform probability distribution on the integers `{1, …, N}` and study the
random variable `chi` which is the indicator of squarefreeness.  Its expectation is the
proportion of squarefree numbers in `[1, N]`, and because `chi` is a `0/1` random variable its
variance can be written entirely in terms of the count of squarefree numbers.

The development is organised as a chain of small, independent lemmas:

* `expec_const`, `expec_smul` — linearity properties of the uniform expectation;
* `prod_chi_mul` — idempotency of the indicator (`chi m * chi m = chi m`);
* `sum_prod_indicator` — the sum of the indicator over `[1, N]` equals the squarefree count;
* `expec_single`, `expec_pair`, `expec_square` — the first and second moments of `chi`;
* `mean_eq` — the squared mean of `chi`;
* `variance_eq_sub` — the general identity `Var f = E[f²] − (E f)²`;
* `variance_eq_squarefree_count` — the final formula for the variance of `chi`.
-/

open Finset

namespace SquarefreeVariance

open scoped Classical

/-- The squarefree indicator on `ℕ`, valued in `ℝ`. -/
noncomputable def chi (m : ℕ) : ℝ := if Squarefree m then 1 else 0

/-- The number of squarefree integers in the interval `[1, N]`. -/
noncomputable def sqfCount (N : ℕ) : ℕ :=
  ((Finset.Icc 1 N).filter (fun m => Squarefree m)).card

/-- The expectation of `f` with respect to the uniform distribution on `[1, N]`. -/
noncomputable def expec (N : ℕ) (f : ℕ → ℝ) : ℝ :=
  (∑ m ∈ Finset.Icc 1 N, f m) / N

/-- The variance of `f` with respect to the uniform distribution on `[1, N]`. -/
noncomputable def variance (N : ℕ) (f : ℕ → ℝ) : ℝ :=
  expec N (fun m => (f m - expec N f) ^ 2)

/-- The expectation of a constant is that constant. -/
lemma expec_const (N : ℕ) (hN : N ≠ 0) (c : ℝ) :
    expec N (fun _ => c) = c := by
  unfold expec
  rw [Finset.sum_const, Nat.card_Icc]
  simp only [Nat.add_sub_cancel, nsmul_eq_mul]
  field_simp

/-- The expectation is homogeneous: scalars factor out. -/
lemma expec_smul (N : ℕ) (c : ℝ) (f : ℕ → ℝ) :
    expec N (fun m => c * f m) = c * expec N f := by
  unfold expec
  rw [← Finset.mul_sum]; ring

/-- The indicator is idempotent under multiplication. -/
lemma prod_chi_mul (m : ℕ) : chi m * chi m = chi m := by
  unfold chi; split_ifs <;> ring

/-- The sum of the squarefree indicator over `[1, N]` counts the squarefree numbers. -/
lemma sum_prod_indicator (N : ℕ) :
    (∑ m ∈ Finset.Icc 1 N, chi m) = (sqfCount N : ℝ) := by
  unfold chi sqfCount; rw [Finset.sum_boole]

/-- First moment: the expectation of the squarefree indicator. -/
lemma expec_single (N : ℕ) : expec N chi = (sqfCount N : ℝ) / N := by
  unfold expec; rw [sum_prod_indicator]

/-- Second moment via the product of two copies of the indicator. -/
lemma expec_pair (N : ℕ) :
    expec N (fun m => chi m * chi m) = expec N chi := by
  simp only [prod_chi_mul]

/-- Second moment via the square of the indicator. -/
lemma expec_square (N : ℕ) :
    expec N (fun m => (chi m) ^ 2) = expec N chi := by
  simp only [sq, prod_chi_mul]

/-- The squared mean of the squarefree indicator. -/
lemma mean_eq (N : ℕ) :
    (expec N chi) ^ 2 = (sqfCount N : ℝ) ^ 2 / (N : ℝ) ^ 2 := by
  rw [expec_single, div_pow]

/-- The variance decomposition `Var f = E[f²] − (E f)²`. -/
lemma variance_eq_sub (N : ℕ) (hN : N ≠ 0) (f : ℕ → ℝ) :
    variance N f = expec N (fun m => (f m) ^ 2) - (expec N f) ^ 2 := by
  unfold variance expec
  have hcard : (Finset.Icc 1 N).card = N := by simp
  have hN' : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN
  set g : ℝ := (∑ m ∈ Finset.Icc 1 N, f m) / N with hg
  have expand : ∀ m, (f m - g) ^ 2 = (f m) ^ 2 - 2 * g * f m + g ^ 2 := fun m => by ring
  have hsum : (∑ m ∈ Finset.Icc 1 N, f m) = g * N := by rw [hg]; field_simp
  simp only [expand, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    Finset.sum_const, hcard, nsmul_eq_mul]
  rw [hsum]
  field_simp
  ring

/-- The variance of the squarefree indicator expressed via the squarefree count. -/
theorem variance_eq_squarefree_count (N : ℕ) (hN : N ≠ 0) :
    variance N chi = (sqfCount N : ℝ) / N - (sqfCount N : ℝ) ^ 2 / (N : ℝ) ^ 2 := by
  rw [variance_eq_sub N hN chi, expec_square, mean_eq, expec_single]

end SquarefreeVariance