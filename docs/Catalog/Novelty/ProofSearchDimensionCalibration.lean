import Bridges.ProofSearchFractalDimension

/-!
# Calibrating proof-search dimension

This file builds on `ProofSearchFractalDimension` rather than introducing a
second notion of dimension.  It isolates two consequences relevant to empirical
claims about proof search.

First, the logarithmic estimator obtained from finite-depth path counts is
already exactly equal to the self-similar dimension at every positive depth.
Thus Monte Carlo work in this model estimates a fixed growth exponent, rather
than a depth-dependent quantity.

Second, because successful paths form a subset of the ambient `b`-ary boundary,
their dimension cannot exceed one.  Consequently, a proposed classification in
which `D > 1` means a hard theorem cannot hold for this model.  The natural hard
regime is instead small positive codimension `1 - D`.  We define its reciprocal
as a length scale and prove the exact inverse relationship suggested by the
heuristic `length ≈ 1 / epsilon`.
-/

namespace ProofSearchDimensionCalibration

open ProofSearchFractalDimension

/-- The finite-depth log-count estimator used to recover the growth dimension. -/
noncomputable def empiricalDim (b s n : ℕ) : ℝ :=
  Real.log (succPaths s n) / Real.log (totalPaths b n)

/-- Codimension in the ambient proof-search boundary. -/
noncomputable def searchCodim (b s : ℕ) : ℝ := 1 - searchDim b s

/-- The reciprocal-codimension length scale.  It is meaningful when `s < b`,
which makes the denominator positive. -/
noncomputable def difficultyScale (b s : ℕ) : ℝ := 1 / searchCodim b s

/-- At every positive sampling depth, the log-count estimator exactly recovers
`searchDim`; no limiting argument is required in the uniform self-similar model. -/
theorem empiricalDim_eq_searchDim (b s n : ℕ) (hb : 1 < b) (hs : 1 ≤ s)
    (hn : 0 < n) :
    empiricalDim b s n = searchDim b s := by
  simp only [empiricalDim, searchDim, succPaths_eq, totalPaths_eq]
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  rw [show (↑(s ^ n) : ℝ) = (↑s : ℝ) ^ n by simp, show (↑(b ^ n) : ℝ) = (↑b : ℝ) ^ n by simp]
  rw [Real.log_pow, Real.log_pow]
  field_simp

/-- Successful-path dimension is never super-ambient.  In particular, the
suggested `D > 1` hard regime is empty for successful subsets of this uniform
search boundary. -/
theorem no_superambient_dimension (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s)
    (hsb : s ≤ b) :
    ¬ 1 < searchDim b s := by
  exact not_lt.mpr (dim_le_one b s hb hs hsb)

/-- Removing at least one branch gives strictly positive codimension. -/
theorem searchCodim_pos (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s) (hsb : s < b) :
    0 < searchCodim b s := by
  unfold searchCodim
  linarith [dim_lt_one_of_lt b s hb hs hsb]

/-- The reciprocal-codimension scale obeys the exact calibration
`scale * (1 - D) = 1`.  This is a precise version of the heuristic that if
`D = 1 - epsilon`, the characteristic search length is `1 / epsilon`. -/
theorem difficultyScale_mul_codim (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s)
    (hsb : s < b) :
    difficultyScale b s * searchCodim b s = 1 := by
  rw [difficultyScale]
  exact div_mul_cancel₀ _ (ne_of_gt (searchCodim_pos b s hb hs hsb))

/-- Equivalently, prescribing a positive codimension `epsilon` prescribes the
reciprocal length scale exactly. -/
theorem difficultyScale_eq_inv_of_codim (b s : ℕ) (ε : ℝ)
    (hε : searchCodim b s = ε) :
    difficultyScale b s = 1 / ε := by
  unfold difficultyScale
  rw [hε]

end ProofSearchDimensionCalibration