/-
# Concrete instances of the greedy lower bound

The abstract counting criterion `DenseSumsetLower.exists_sumset_nat_range` says that a set
`S ⊆ [0, n)` with `k (2n)^k ≤ |S| (|S| - k)^k` must contain a sumset `A + B` with
`|A| = |B| = k`.  This file records two fully checked numerical instances of that
criterion, which are the formal counterpart of the tables in `ComputationalEvidence.md`:

* every set of `2^19` integers below `2^20` (density `1/2`) contains a `7 + 7` sumset;
* every set of `2^19` integers below `2^22` (density `1/8`) contains a `4 + 4` sumset.

Both are obtained by discharging the explicit arithmetic inequality; nothing here is
definitional or vacuous.
-/
import Bridges.DenseSumsetLower.Core

namespace DenseSumsetLower

open Pointwise

/-- Auxiliary form of the interval criterion, stated with a *lower* bound on the density:
it suffices to test the counting condition at the threshold cardinality `m`. -/
theorem exists_sumset_nat_range_of_le {n m k : ℕ} {S : Finset ℕ} (hS : S ⊆ Finset.range n)
    (hm : m ≤ S.card) (hkm : k ≤ m) (hcond : k * (2 * n) ^ k ≤ m * (m - k) ^ k) :
    ∃ A B : Finset ℕ, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  obtain ⟨T, hTS, hTcard⟩ := Finset.exists_subset_card_eq hm
  obtain ⟨A, B, hA, hB, hAB⟩ :=
    exists_sumset_nat_range (k := k) (hTS.trans hS) (by rw [hTcard]; exact hkm)
      (by rw [hTcard]; exact hcond)
  exact ⟨A, B, hA, hB, hAB.trans hTS⟩

/-- **Density `1/2`, `n = 2^20`.**  Every set of at least `2^19` naturals below `2^20`
contains a sumset `A + B` with `|A| = |B| = 7`. -/
theorem sumset_seven_of_half_dense (S : Finset ℕ) (hS : S ⊆ Finset.range (2 ^ 20))
    (hcard : 2 ^ 19 ≤ S.card) :
    ∃ A B : Finset ℕ, A.card = 7 ∧ B.card = 7 ∧ A + B ⊆ S :=
  exists_sumset_nat_range_of_le hS hcard (by norm_num) (by norm_num)

/-- **Density `1/8`, `n = 2^22`.**  Every set of at least `2^19` naturals below `2^22`
contains a sumset `A + B` with `|A| = |B| = 4`. -/
theorem sumset_four_of_eighth_dense (S : Finset ℕ) (hS : S ⊆ Finset.range (2 ^ 22))
    (hcard : 2 ^ 19 ≤ S.card) :
    ∃ A B : Finset ℕ, A.card = 4 ∧ B.card = 4 ∧ A + B ⊆ S :=
  exists_sumset_nat_range_of_le hS hcard (by norm_num) (by norm_num)

end DenseSumsetLower