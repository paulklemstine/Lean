module

public import Catalog.Logic.TieHeadroom

/-!
# Reading the pooled value 0.669 against a flattened dial

With a tie-free (flattened) dial, every pairing of observations obeys
`ρ_u ≤ tieFactor M` and `ρ_c ≤ √(tieFactor M)`. Consequently an observed Spearman
reading `r` forces the response tie factor to satisfy `tieFactor M ≥ r` (textbook
normalisation) or `tieFactor M ≥ r²` (two-sided tie correction). We instantiate this at
the recorded pooled reading `r = 0.669`.
-/

@[expose] public section

namespace Catalog.Logic.TieHeadroom

/-- With a flattened dial, every pairing gives `ρ_u ≤ tieFactor M`. -/
theorem rhoUncorr_untied_le (M : List ℕ) (hn : 2 ≤ M.sum)
    (σ : Equiv.Perm (Fin (List.replicate M.sum 1).sum)) :
    rhoUncorr (List.replicate M.sum 1) M σ ≤ tieFactor M := by
  have hs : (List.replicate M.sum 1).sum = M.sum := sum_untied _
  have hn' : 2 ≤ (List.replicate M.sum 1).sum := by rw [hs]; exact hn
  have h1 := rhoUncorr_le_aligned _ M hs.symm hn' σ
  rw [← maxRho_eq_aligned _ M hs.symm hn', maxRho_untied M hn] at h1
  exact h1

/-- With a flattened dial and a non-degenerate response, every pairing gives
`ρ_c ≤ √(tieFactor M)`. -/
theorem rhoCorr_untied_le (M : List ℕ) (hn : 2 ≤ M.sum) (h0 : 0 < tieFactor M)
    (σ : Equiv.Perm (Fin (List.replicate M.sum 1).sum)) :
    rhoCorr (List.replicate M.sum 1) M σ ≤ Real.sqrt (tieFactor M) := by
  have hs : (List.replicate M.sum 1).sum = M.sum := sum_untied _
  have hn' : 2 ≤ (List.replicate M.sum 1).sum := by rw [hs]; exact hn
  have hp : 0 < Real.sqrt (tieFactor M) := Real.sqrt_pos.mpr h0
  have hsq := Real.sq_sqrt h0.le
  rw [rhoCorr_eq _ M hs.symm hn', tieFactor_untied, one_mul, div_le_iff₀ hp]
  have := rhoUncorr_untied_le M hn σ
  nlinarith

/-- **Pooled-reading check (textbook rho).** If some pairing with a flattened dial
produces the reading `ρ_u = 0.669`, then the response tie factor is at least `0.669`,
i.e. the response alone accounts for at most `0.331` of headroom. -/
theorem pooled_reading_uncorr (M : List ℕ) (hn : 2 ≤ M.sum)
    (σ : Equiv.Perm (Fin (List.replicate M.sum 1).sum))
    (hobs : rhoUncorr (List.replicate M.sum 1) M σ = 0.669) :
    (0.669 : ℝ) ≤ tieFactor M := by
  have := rhoUncorr_untied_le M hn σ
  linarith

/-- **Pooled-reading check (tie-corrected rho).** If some pairing with a flattened dial
produces the corrected reading `ρ_c = 0.669`, then `tieFactor M ≥ 0.669² = 0.447561`. -/
theorem pooled_reading_corr (M : List ℕ) (hn : 2 ≤ M.sum) (h0 : 0 < tieFactor M)
    (σ : Equiv.Perm (Fin (List.replicate M.sum 1).sum))
    (hobs : rhoCorr (List.replicate M.sum 1) M σ = 0.669) :
    (0.447561 : ℝ) ≤ tieFactor M := by
  have h := rhoCorr_untied_le M hn h0 σ
  rw [hobs] at h
  have hsq := Real.sq_sqrt h0.le
  nlinarith [Real.sqrt_nonneg (tieFactor M)]

end Catalog.Logic.TieHeadroom