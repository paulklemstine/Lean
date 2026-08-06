/-
# An explicit small instance of the sumset-avoiding construction

The general theorems of `Bridges/DeltaDenseSumsetAvoidance.lean` are asymptotic: they
produce, for each `0 < δ < 1` and all large `n`, a `δ`-dense set `S ⊆ [n]` containing no
sumset of two arithmetic progressions of common length `≥ 3 log n / log(1/δ)`.

Here we verify a concrete instance by kernel computation: the set

`S = {0, 1, 3, 6, 8, 12, 13, 14} ⊆ [16]`

has density exactly `1/2` in `[16]` and

* contains no `4`-term arithmetic progression, and
* contains no sumset `A + B` of two arithmetic progressions of common length `≥ 4`
  (with arbitrary positive common differences).

Note that `3 log 16 / log 2 = 12`, so this explicit example is far stronger than what the
asymptotic theorem guarantees at `n = 16`; the union-bound constant is not optimal for
small `n`.
-/
import Bridges.DeltaDenseSumsetAvoidance

namespace DeltaDense

open Finset Pointwise

/-- An explicit density-`1/2` subset of `[16]` with no `4`-term progression. -/
def S16 : Finset ℕ := {0, 1, 3, 6, 8, 12, 13, 14}

lemma card_S16 : S16.card = 8 := by decide

lemma S16_subset : S16 ⊆ range 16 := by decide

set_option maxRecDepth 100000 in
private lemma S16_no_ap_bounded :
    ∀ a ∈ range 16, ∀ d ∈ Icc 1 16, ¬ (apF a d 4 ⊆ S16) := by decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 2000000 in
private lemma S16_no_grid_bounded :
    ∀ t ∈ range 16, ∀ d₁ ∈ Icc 1 16, ∀ d₂ ∈ Icc 1 16, ¬ (gridWitness t d₁ d₂ 4 ⊆ S16) := by
  decide

/-- `S16` contains no `4`-term arithmetic progression at all. -/
theorem S16_no_ap : ∀ a d : ℕ, 0 < d → ¬ (apF a d 4 ⊆ S16) := by
  intro a d hd hsub
  have ha : a < 16 := by simpa using S16_subset (hsub (self_mem_apF (by omega)))
  have had : a + d < 16 := by simpa using S16_subset (hsub (second_mem_apF (by omega)))
  exact S16_no_ap_bounded a (Finset.mem_range.2 ha) d (Finset.mem_Icc.2 ⟨hd, by omega⟩) hsub

/-- `S16` contains no L-shaped grid witness with `k = 4`. -/
theorem S16_no_grid : ∀ t d₁ d₂ : ℕ, 0 < d₁ → 0 < d₂ → ¬ (gridWitness t d₁ d₂ 4 ⊆ S16) := by
  intro t d₁ d₂ h1 h2 hsub
  have ht : t < 16 := by
    simpa using S16_subset (hsub (Finset.mem_union_left _ (self_mem_apF (by omega))))
  have htd : t + d₁ < 16 := by
    simpa using S16_subset (hsub (Finset.mem_union_left _ (second_mem_apF (by omega))))
  have htd2 : t + d₁ * (4 - 1) + d₂ < 16 := by
    simpa using S16_subset (hsub (Finset.mem_union_right _ (second_mem_apF (by omega))))
  exact S16_no_grid_bounded t (Finset.mem_range.2 ht) d₁ (Finset.mem_Icc.2 ⟨h1, by omega⟩)
    d₂ (Finset.mem_Icc.2 ⟨h2, by omega⟩) hsub

/-- **Explicit instance.**  The density-`1/2` set `S16 ⊆ [16]` contains no sumset of two
arithmetic progressions of common length at least `4`, whatever their (positive) common
differences. -/
theorem S16_no_ap_sumset (a b d₁ d₂ k : ℕ) (h1 : 0 < d₁) (h2 : 0 < d₂) (hk : 4 ≤ k) :
    ¬ (apF a d₁ k + apF b d₂ k ⊆ S16) := fun hsub =>
  S16_no_grid (a + b) d₁ d₂ h1 h2 ((gridWitness_subset_add (by omega) hk).trans hsub)

end DeltaDense