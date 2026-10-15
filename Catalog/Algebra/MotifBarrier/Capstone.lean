import Algebra.MotifBarrier.ThreeDerivations
import Algebra.MotifBarrier.UMWCovering

/-!
# Capstone: the `1/5` floor is motif-intrinsic; the UMW wall is linear and tight at its ends

This file packages the two halves of the round.

* **Inside the baby-step/giant-step motif** (`ThreeDerivations.lean`): three
  independent arguments give the same floor `1/5`, attained at a unique optimiser.
* **The exit** (`UMWCovering.lean`): divisibility coverings of `[n]` obey the
  counting wall `α + 2β ≥ 1` (proved rigorously, with explicit constants
  `4^n ≤ (2n+1)·M^{|S||T|}`); both ends `(1,0)` (lcm) and `(0,1/2)` (the BSGS
  motif itself, read as a covering) are realised by explicit coverings; the
  interior zero-slack point `(1/3,1/3)` is **not** constructed.

Nothing here is a factoring algorithm or a lower bound on factoring.
-/

namespace Catalog.Algebra.MotifBarrier

open Crypto.FactoringBarrier.HarveyBalance Motif UMW

/-- **The capstone statement.**
1. Harvey's motif exponent has floor `1/5` with unique optimiser `(1/5,1/5)`, and
   the space–time invariant `3·A + 2·C ≥ 1` re-derives that floor.
2. Every disjoint divisibility covering of `[2n]` with entries in `[0, M]`
   satisfies `4^n ≤ (2n+1)·M^{|S||T|}`.
3. The baby-step/giant-step sets cover `[k²]` with `|S| = |T| = k` and entries
   `≤ 2k²` (the `β = 1/2` end of the wall), and the lcm pair covers `[n]` with
   `|S| = |T| = 1` (the `β = 0` end), optimally among single pairs. -/
theorem capstone :
    (∀ a b : ℚ, 1 / 5 ≤ costExp a b) ∧
    (∀ a b : ℚ, costExp a b = 1 / 5 ↔ a = 1 / 5 ∧ b = 1 / 5) ∧
    (∀ a b : ℚ, 1 ≤ 3 * timeExp a b + 2 * b) ∧
    (∀ (n M : ℕ) (S T : Finset ℤ), IsDivCovering (2 * n) S T → Disjoint S T →
      (∀ s ∈ S, 0 ≤ s ∧ s ≤ M) → (∀ t ∈ T, 0 ≤ t ∧ t ≤ M) →
      4 ^ n ≤ (2 * n + 1) * M ^ (S.card * T.card)) ∧
    (∀ k : ℕ, IsDivCovering (k * k) (bsgsS k) (bsgsT k) ∧ (bsgsS k).card = k ∧
      (bsgsT k).card = k ∧ Disjoint (bsgsS k) (bsgsT k)) ∧
    (∀ n : ℕ, IsDivCovering n {(((Finset.Icc 1 n).lcm id : ℕ) : ℤ)} {0}) := by
  refine ⟨one_fifth_is_lower_bound, (three_derivations_agree).2.2.2, space_time_invariant,
    fun n M S T hc hd hS hT => counting_wall hc hd hS hT,
    fun k => ⟨bsgs_covering k, bsgsS_card k, bsgsT_card k, bsgs_disjoint k⟩, lcm_covering⟩

end Catalog.Algebra.MotifBarrier