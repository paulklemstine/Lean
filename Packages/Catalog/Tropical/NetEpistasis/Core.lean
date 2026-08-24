/-
# Tropical pruning costs and layer epistasis — Core

A *prunable net* is a finite family of "computation paths".  Each path `i` uses a
finite set of layers `supp i` (the layers whose fine structure the path depends
on) and, if it survives, incurs a loss `loss i`.  Pruning a set `S` of layers
destroys exactly the paths whose support meets `S`; the network then falls back
on the best surviving path.  The resulting quantity

  `netLoss S = min { loss i | supp i ∩ S = ∅ }`

is a **min-plus (tropical) sum** over the surviving paths, and the *pruning cost*
of `S` is `cost S = netLoss S - netLoss ∅`.

This is the mathematical skeleton behind the NET-60 measurement
("THE-EPISTASIS-LIVES-IN-THE-TAIL-PAIR"): a per-layer sparsification budget
destroys some paths, and the accuracy drop is the increase of the tropical
minimum.  The point of the development is that the *joint* cost of two layers is
not determined by their solo costs; the deviation is the epistasis `epi`.

Main contents of this file:
* `NetEpistasis.PrunableNet`, `netLoss`, `cost`, `epi`;
* monotonicity and non-negativity of `cost`;
* `netLoss_eq_untrop_sum`: `netLoss` *is* a tropical sum in `Tropical (WithTop ℚ)`.
-/
import Mathlib

namespace NetEpistasis

open Finset

/-- A finite path system on `n` layers.  `supp i` is the set of layers that path
`i` depends on, `loss i` is the loss the network incurs when path `i` is the best
surviving one.  `base` is a fallback path using no layer at all (a fully pruned
network still computes something), which guarantees that some path always
survives. -/
structure PrunableNet (n : ℕ) where
  /-- Index type of the paths. -/
  ι : Type
  [fintypeι : Fintype ι]
  [decEqι : DecidableEq ι]
  /-- Layers used by a path. -/
  supp : ι → Finset (Fin n)
  /-- Loss incurred by a path. -/
  loss : ι → ℚ
  /-- The fallback path. -/
  base : ι
  /-- The fallback path uses no layer. -/
  base_supp : supp base = ∅

attribute [instance] PrunableNet.fintypeι PrunableNet.decEqι

variable {n : ℕ} (N : PrunableNet n)

/-- The paths that survive pruning the layers in `S`. -/
def survivors (S : Finset (Fin n)) : Finset N.ι :=
  Finset.univ.filter fun i => Disjoint (N.supp i) S

variable {N}

@[simp] lemma mem_survivors {S : Finset (Fin n)} {i : N.ι} :
    i ∈ survivors N S ↔ Disjoint (N.supp i) S := by
  simp [survivors]

lemma base_mem_survivors (S : Finset (Fin n)) : N.base ∈ survivors N S := by
  simp [N.base_supp]

lemma survivors_nonempty (S : Finset (Fin n)) : (survivors N S).Nonempty :=
  ⟨N.base, base_mem_survivors S⟩

lemma survivors_antitone {S T : Finset (Fin n)} (h : S ⊆ T) :
    survivors N T ⊆ survivors N S := by
  intro i hi
  simp only [mem_survivors] at hi ⊢
  exact hi.mono_right h

variable (N)

/-- The loss of the network after pruning the layers in `S`: the tropical
(min-plus) sum of the losses of the surviving paths. -/
noncomputable def netLoss (S : Finset (Fin n)) : ℚ :=
  (survivors N S).inf' (survivors_nonempty S) N.loss

/-- The pruning cost of a set of layers: the increase of the tropical minimum. -/
noncomputable def cost (S : Finset (Fin n)) : ℚ := netLoss N S - netLoss N ∅

/-- The setwise **epistasis**: the excess of the joint cost over the sum of the
individual costs.  Positive means super-additive. -/
noncomputable def epi (S T : Finset (Fin n)) : ℚ :=
  cost N (S ∪ T) - cost N S - cost N T

variable {N}

lemma netLoss_le {S : Finset (Fin n)} {i : N.ι} (hi : Disjoint (N.supp i) S) :
    netLoss N S ≤ N.loss i :=
  Finset.inf'_le _ (mem_survivors.mpr hi)

lemma le_netLoss {S : Finset (Fin n)} {q : ℚ}
    (h : ∀ i, Disjoint (N.supp i) S → q ≤ N.loss i) : q ≤ netLoss N S :=
  Finset.le_inf' _ _ fun i hi => h i (mem_survivors.mp hi)

/-- The tropical minimum is attained by some surviving path. -/
lemma exists_netLoss_eq (S : Finset (Fin n)) :
    ∃ i, Disjoint (N.supp i) S ∧ N.loss i = netLoss N S := by
  obtain ⟨i, hi, hval⟩ := Finset.exists_mem_eq_inf' (survivors_nonempty S) N.loss
  exact ⟨i, mem_survivors.mp hi, hval.symm⟩

/-- Computing the tropical loss from an explicit minimizing path. -/
lemma netLoss_eq_of_witness {S : Finset (Fin n)} (i₀ : N.ι)
    (h₁ : Disjoint (N.supp i₀) S)
    (h₂ : ∀ i, Disjoint (N.supp i) S → N.loss i₀ ≤ N.loss i) :
    netLoss N S = N.loss i₀ :=
  le_antisymm (netLoss_le h₁) (le_netLoss h₂)

/-- Pruning more layers can only increase the tropical loss. -/
lemma netLoss_mono {S T : Finset (Fin n)} (h : S ⊆ T) : netLoss N S ≤ netLoss N T :=
  le_netLoss fun _ hi => netLoss_le (hi.mono_right h)

@[simp] lemma cost_empty : cost N ∅ = 0 := by simp [cost]

lemma cost_nonneg (S : Finset (Fin n)) : 0 ≤ cost N S := by
  have := netLoss_mono (N := N) (Finset.empty_subset S)
  simp only [cost, sub_nonneg]
  exact this

lemma cost_mono {S T : Finset (Fin n)} (h : S ⊆ T) : cost N S ≤ cost N T := by
  have := netLoss_mono (N := N) h
  simpa [cost, sub_le_sub_iff_right] using this

/-- Epistasis is symmetric. -/
lemma epi_comm (S T : Finset (Fin n)) : epi N S T = epi N T S := by
  simp only [epi, Finset.union_comm S T]; ring

/-- Epistasis against the empty set vanishes. -/
@[simp] lemma epi_empty_right (S : Finset (Fin n)) : epi N S ∅ = 0 := by
  simp [epi]

/-- A pair of layer sets is **super-additive** when its joint cost exceeds the
sum of its solo costs. -/
def SuperAdditive (N : PrunableNet n) (S T : Finset (Fin n)) : Prop := 0 < epi N S T

/-- A pair of layer sets is **sub-additive** when its joint cost falls short of
the sum of its solo costs. -/
def SubAdditive (N : PrunableNet n) (S T : Finset (Fin n)) : Prop := epi N S T < 0

/-!
### The tropical identity

`netLoss` is literally a sum in the tropical semiring `Tropical (WithTop ℚ)`
(whose addition is `min`), taken over the surviving paths.
-/

lemma netLoss_eq_untrop_sum (S : Finset (Fin n)) :
    Tropical.untrop (∑ i ∈ survivors N S, Tropical.trop ((N.loss i : WithTop ℚ)))
      = ((netLoss N S : ℚ) : WithTop ℚ) := by
  classical
  rw [Finset.untrop_sum']
  refine le_antisymm ?_ ?_
  · obtain ⟨i, hi, hval⟩ := exists_netLoss_eq (N := N) S
    refine le_trans (Finset.inf_le (mem_survivors.mpr hi)) ?_
    simp [hval]
  · refine Finset.le_inf ?_
    intro i hi
    simp only [Function.comp_apply, Tropical.untrop_trop, WithTop.coe_le_coe]
    exact netLoss_le (mem_survivors.mp hi)

end NetEpistasis