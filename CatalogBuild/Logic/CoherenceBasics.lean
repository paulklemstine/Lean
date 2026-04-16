/-! # CatalogBuild.Logic.CoherenceBasics

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6
-/

import Mathlib

noncomputable section

/-- The spectral landscape entropy L(f) = H(spectral distribution) / n,
normalized to [0, 1]. For our formalization, we define it abstractly. -/
def landscapeEntropy (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) : ℝ :=
  H_spectral / n



/-- The coherence C(f) = 1 - H(spectral distribution) / n. -/
def coherenceMeasure (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) : ℝ :=
  1 - H_spectral / n



/-- [Section: # CatalogBuild.Logic.CoherenceBasics
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 6] -/
theorem coherence_add_landscape_eq_one (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) :
    coherenceMeasure H_spectral n hn + landscapeEntropy H_spectral n hn = 1 := by
  -- By definition of coherenceMeasure and landscapeEntropy, we have:
  simp [coherenceMeasure, landscapeEntropy]



theorem shannonEntropy_le_log (p : Fin k → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) (hk : 0 < k) :
    shannonEntropy p hp hsum ≤ Real.log k := by
  unfold shannonEntropy;
  -- Apply Jensen's inequality for the concave function $f(x) = x \log x$.
  have h_jensen : (∑ i, (1 / k : ℝ) * (p i * Real.log (p i))) ≥ ((∑ i, (1 / k : ℝ) * p i) * Real.log (∑ i, (1 / k : ℝ) * p i)) := by
    -- The function $f(x) = x \log x$ is convex on $[0, \infty)$.
    have h_convex : ConvexOn ℝ (Set.Ici 0) (fun x : ℝ => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    apply ConvexOn.map_sum_le h_convex;
    · aesop;
    · simp +decide [ hk.ne' ];
    · aesop;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  nlinarith [ inv_mul_cancel_left₀ ( by positivity : ( k : ℝ ) ≠ 0 ) ( Real.log k ), inv_mul_cancel₀ ( by positivity : ( k : ℝ ) ≠ 0 ) ]



theorem coherence_nonneg (H_spectral : ℝ) (n : ℕ) (hn : 0 < n)
    (hH : H_spectral ≤ n) : 0 ≤ coherenceMeasure H_spectral n hn := by
  exact sub_nonneg_of_le ( div_le_one_of_le₀ hH <| Nat.cast_nonneg _ )



theorem coherence_le_one (H_spectral : ℝ) (n : ℕ) (hn : 0 < n)
    (hH : 0 ≤ H_spectral) : coherenceMeasure H_spectral n hn ≤ 1 := by
  exact sub_le_self _ ( by positivity )



end
