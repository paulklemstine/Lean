import Mathlib

/-! # CatalogBuild.Algebra.Probability

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 3
-/


/-- [Section: # CatalogBuild.Algebra.Probability
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 3] -/
theorem markov_inequality_nat (f : ℕ → ℝ) (w : ℕ → ℝ) (n : ℕ) (hn : 0 < n)
    (hw : ∀ i, 0 ≤ w i) (hf : ∀ i, 0 ≤ f i)
    (hsum : ∑ i ∈ Finset.range n, w i = 1) (a : ℝ) (ha : 0 < a) :
    (Finset.range n).sum (fun i => w i * if a ≤ f i then 1 else 0) ≤
    (∑ i ∈ Finset.range n, w i * f i) / a := by
      rw [ le_div_iff₀ ha, mul_comm ];
      rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by split_ifs <;> nlinarith [ hw i, hf i ] ;




/-- [Section: # CatalogBuild.Algebra.Probability
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 3] -/
theorem log_monotone_on : MonotoneOn (fun x : ℝ => Real.log x) (Set.Ioi 0) := by
  exact fun x hx y hy hxy => Real.log_le_log hx hxy




theorem binary_entropy_symmetric (p : ℝ) :
    binaryEntropy p = binaryEntropy (1 - p) := by
      unfold binaryEntropy; ring;