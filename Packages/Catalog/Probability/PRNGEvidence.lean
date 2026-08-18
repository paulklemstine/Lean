import Probability.PRNGComplexityHierarchy
import Probability.PRNGLCGFingerprint

/-!
# Kernel-checked small cases

Small instances of the counting statements, decided by the kernel rather than
merely evaluated.  They pin down the constants appearing in
`ComputationalEvidence.md` and confirm that the general bounds are attained
(and are not vacuous).

* over `GF(2)` there are exactly `3` files of length `4` and linear complexity
  `≤ 1`, and exactly `11` of complexity `≤ 2` — against the general upper bound
  `2^{2L}` (`4` and `16`) and lower bound `2^L` (`2` and `4`);
* saturation at `n = 2L` is visible already at `L = 2`: the count is `11` for
  `n = 4` and still `11` for `n = 5`;
* the `6` LCG files of length `4` over `GF(2)` all lie in the order-`2` LFSR
  family, as `lcg_satisfiesLFSR` predicts;
* two further data points for the enumeration conjecture C1, at orders where the
  conjectured value `(q^{2L+1}+1)/(q+1)` has not been proved: `q = 3, L = 2`
  gives `61 = (3^5+1)/4` and `q = 2, L = 3` gives `43 = (2^7+1)/3`.
-/

namespace Catalog.Probability.SeedRec

theorem card_lfsrWords_two_one_four : (lfsrWords (ZMod 2) 1 4).card = 3 := by decide

theorem card_lfsrWords_two_two_four : (lfsrWords (ZMod 2) 2 4).card = 11 := by decide

theorem card_lfsrWords_two_two_five : (lfsrWords (ZMod 2) 2 5).card = 11 := by decide

theorem card_lcgWords_two_four : (lcgWords (ZMod 2) 4).card = 6 := by decide

theorem lcgWords_subset_lfsrWords_two :
    lcgWords (ZMod 2) 4 ⊆ lfsrWords (ZMod 2) 2 4 := by decide

set_option maxRecDepth 100000 in
/-- Conjecture C1 at `q = 3, L = 2`: `(3^5 + 1)/(3 + 1) = 61`. -/
theorem card_lfsrWords_three_two_four : (lfsrWords (ZMod 3) 2 4).card = 61 := by decide

set_option maxRecDepth 100000 in
/-- Conjecture C1 at `q = 2, L = 3`: `(2^7 + 1)/(2 + 1) = 43`. -/
theorem card_lfsrWords_two_three_six : (lfsrWords (ZMod 2) 3 6).card = 43 := by decide

end Catalog.Probability.SeedRec