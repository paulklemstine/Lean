/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Catalog.Pythagorean.BrillNoether.Divisors
import Catalog.Pythagorean.BrillNoether.Reduced
import Catalog.Pythagorean.BrillNoether.ReducedUnique

/-!
# Dhar's burning algorithm

Being `q`-reduced is defined by a quantifier over *all* nonempty sets of vertices
avoiding `q` (`BrillNoetherReducedUnique.IsReduced`).  Dhar's burning algorithm
replaces this by a linear-time process: a fire starts at `q` and spreads to a
vertex `v` as soon as the number of burnt edges at `v` exceeds the number of chips
`D v`.  The divisor is `q`-reduced exactly when the whole graph burns.

This file defines the burning process

`burnStep B = insert q (B ∪ {v | D v < #(N(v) ∩ B)})`,   `burn = burnStep^[#V] ∅`

and proves:

* `BrillNoetherDhar.burnStep_burn` — after `#V` rounds the fire has stabilised
  (a pigeonhole argument on an increasing chain of finite sets);
* `BrillNoetherDhar.disjoint_burn_of_legal` — a set that can legally be fired never
  catches fire;
* `BrillNoetherDhar.isReduced_iff_burn_eq_univ` — **Dhar's criterion**: `D` is
  `q`-reduced if and only if it is nonnegative away from `q` and `burn = univ`.

The unburnt set is the largest legal firing set (`legal_unburnt` together with
`disjoint_burn_of_legal`), which is what makes the reduction algorithm terminate in
polynomial time: fire the unburnt set, and repeat.
-/

open Finset SimpleGraph

namespace BrillNoetherDhar

open BrillNoetherDivisor BrillNoetherReduced BrillNoetherReducedUnique

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- One round of Dhar's burning process: the fire keeps `B`, always includes the
base vertex `q`, and spreads to every vertex with fewer chips than burnt
incident edges. -/
def burnStep (q : V) (D : Divisor V) (B : Finset V) : Finset V :=
  insert q (B ∪ univ.filter (fun v => D v < (#(G.neighborFinset v ∩ B) : ℤ)))

/-- The burnt set: `#V` rounds of burning, started from the empty set. -/
def burn (q : V) (D : Divisor V) : Finset V := (burnStep G q D)^[Fintype.card V] ∅

lemma subset_burnStep (q : V) (D : Divisor V) (B : Finset V) : B ⊆ burnStep G q D B := by
  intro x hx
  exact Finset.mem_insert.mpr (Or.inr (Finset.mem_union_left _ hx))

lemma burnStep_mono (q : V) (D : Divisor V) {B B' : Finset V} (h : B ⊆ B') :
    burnStep G q D B ⊆ burnStep G q D B' := by
  intro x hx
  rcases Finset.mem_insert.mp hx with hx | hx
  · exact Finset.mem_insert.mpr (Or.inl hx)
  rcases Finset.mem_union.mp hx with hx | hx
  · exact Finset.mem_insert.mpr (Or.inr (Finset.mem_union_left _ (h hx)))
  · refine Finset.mem_insert.mpr (Or.inr (Finset.mem_union_right _ ?_))
    rw [Finset.mem_filter] at hx ⊢
    refine ⟨Finset.mem_univ x, lt_of_lt_of_le hx.2 ?_⟩
    exact_mod_cast Finset.card_le_card (Finset.inter_subset_inter_left h)

/-- The burning process is an increasing chain of sets. -/
lemma burn_chain_mono (q : V) (D : Divisor V) (i : ℕ) :
    (burnStep G q D)^[i] ∅ ⊆ (burnStep G q D)^[i + 1] ∅ := by
  induction i with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', Function.iterate_succ_apply' _ (n + 1)]
      exact burnStep_mono G q D ih

/-- Once the fire stops spreading it stops for good. -/
lemma burn_chain_const (q : V) (D : Divisor V) {i : ℕ}
    (h : (burnStep G q D)^[i + 1] ∅ = (burnStep G q D)^[i] ∅) :
    ∀ j, (burnStep G q D)^[i + j] ∅ = (burnStep G q D)^[i] ∅ := by
  intro j
  induction j with
  | zero => rfl
  | succ m ih =>
      have : i + (m + 1) = (i + m) + 1 := by ring
      rw [this, Function.iterate_succ_apply' _ (i + m), ih]
      rw [← Function.iterate_succ_apply' (burnStep G q D) i, h]

/-- As long as the fire keeps spreading, the burnt set grows by at least one vertex
per round. -/
lemma card_burn_chain (q : V) (D : Divisor V) (i : ℕ)
    (h : ∀ j < i, (burnStep G q D)^[j + 1] ∅ ≠ (burnStep G q D)^[j] ∅) :
    i ≤ #((burnStep G q D)^[i] ∅) := by
  induction i with
  | zero => simp
  | succ n ih =>
      have hn : n ≤ #((burnStep G q D)^[n] ∅) := ih fun j hj => h j (by omega)
      have hsub : (burnStep G q D)^[n] ∅ ⊆ (burnStep G q D)^[n + 1] ∅ :=
        burn_chain_mono G q D n
      have hne : (burnStep G q D)^[n + 1] ∅ ≠ (burnStep G q D)^[n] ∅ := h n (by omega)
      have hlt : #((burnStep G q D)^[n] ∅) < #((burnStep G q D)^[n + 1] ∅) :=
        Finset.card_lt_card (lt_of_le_of_ne hsub (fun hEq => hne hEq.symm))
      omega

/-- **The fire has stabilised after `#V` rounds.** -/
theorem burnStep_burn (q : V) (D : Divisor V) :
    burnStep G q D (burn G q D) = burn G q D := by
  classical
  set n := Fintype.card V with hn
  by_cases h : ∃ j < n, (burnStep G q D)^[j + 1] ∅ = (burnStep G q D)^[j] ∅
  · obtain ⟨j, hjn, hj⟩ := h
    have hstab := burn_chain_const G q D hj
    have h1 : (burnStep G q D)^[n] ∅ = (burnStep G q D)^[j] ∅ := by
      have := hstab (n - j)
      rwa [show j + (n - j) = n by omega] at this
    have h2 : (burnStep G q D)^[n + 1] ∅ = (burnStep G q D)^[j] ∅ := by
      have := hstab (n + 1 - j)
      rwa [show j + (n + 1 - j) = n + 1 by omega] at this
    rw [burn, ← Function.iterate_succ_apply' (burnStep G q D) n, h1, h2]
  · push_neg at h
    have hcard : n ≤ #((burnStep G q D)^[n] ∅) := card_burn_chain G q D n h
    have huniv : (burnStep G q D)^[n] ∅ = univ := by
      apply Finset.eq_univ_of_card
      have h2 : #((burnStep G q D)^[n] ∅) ≤ n := by
        simpa [hn] using Finset.card_le_univ ((burnStep G q D)^[n] ∅)
      omega
    rw [burn, huniv]
    exact Finset.Subset.antisymm (Finset.subset_univ _) (subset_burnStep G q D univ)

/-- The base vertex always burns (when the graph is nonempty). -/
lemma mem_burn_base (q : V) (D : Divisor V) : q ∈ burn G q D := by
  have h := burnStep_burn G q D
  rw [← h, burnStep]
  exact Finset.mem_insert_self _ _

/-- **A legal firing set never burns.**  If every vertex of `S` has at least as many
chips as edges leaving `S`, and `q ∉ S`, then the fire never reaches `S`. -/
theorem disjoint_burn_of_legal {q : V} {D : Divisor V} {S : Finset V} (hq : q ∉ S)
    (hlegal : ∀ v ∈ S, (outdeg G S v : ℤ) ≤ D v) :
    ∀ i, ∀ x ∈ (burnStep G q D)^[i] ∅, x ∉ S := by
  intro i
  induction i with
  | zero => simp
  | succ m ih =>
      rw [Function.iterate_succ_apply' (burnStep G q D) m]
      intro x hx hxS
      set B := (burnStep G q D)^[m] ∅ with hB
      rcases Finset.mem_insert.mp hx with hx | hx
      · exact hq (hx ▸ hxS)
      rcases Finset.mem_union.mp hx with hx | hx
      · exact ih x hx hxS
      · rw [Finset.mem_filter] at hx
        have hBS : G.neighborFinset x ∩ B ⊆ G.neighborFinset x \ S := by
          intro y hy
          rw [Finset.mem_inter] at hy
          exact Finset.mem_sdiff.mpr ⟨hy.1, fun hyS => ih y hy.2 hyS⟩
        have hcard : (#(G.neighborFinset x ∩ B) : ℤ) ≤ (outdeg G S x : ℤ) := by
          rw [outdeg]
          exact_mod_cast Finset.card_le_card hBS
        exact absurd hx.2 (not_lt.mpr (le_trans hcard (hlegal x hxS)))

/-- **The unburnt set is legal.**  Every vertex that survives the fire has at least
as many chips as it has edges to the burnt part, i.e. as many as it would spend by
firing the unburnt set. -/
theorem legal_unburnt (q : V) (D : Divisor V) {v : V} (hv : v ∉ burn G q D) :
    (outdeg G (univ \ burn G q D) v : ℤ) ≤ D v := by
  classical
  have hstep := burnStep_burn G q D
  have hnot : v ∉ burnStep G q D (burn G q D) := by rw [hstep]; exact hv
  have hfil : v ∉ univ.filter (fun u => D u < (#(G.neighborFinset u ∩ burn G q D) : ℤ)) := by
    intro hmem
    exact hnot (Finset.mem_insert.mpr (Or.inr (Finset.mem_union_right _ hmem)))
  have hle : ¬ (D v < (#(G.neighborFinset v ∩ burn G q D) : ℤ)) := by
    intro hlt
    exact hfil (Finset.mem_filter.mpr ⟨Finset.mem_univ v, hlt⟩)
  have hset : G.neighborFinset v \ (univ \ burn G q D) = G.neighborFinset v ∩ burn G q D := by
    ext x
    simp [Finset.mem_sdiff, Finset.mem_inter]
  rw [outdeg, hset]
  exact not_lt.mp hle

/-- **Dhar's criterion.**  A divisor is `q`-reduced if and only if it is nonnegative
away from `q` and the burning process started at `q` consumes the whole graph. -/
theorem isReduced_iff_burn_eq_univ (q : V) (D : Divisor V) :
    IsReduced G q D ↔ (∀ v, v ≠ q → 0 ≤ D v) ∧ burn G q D = univ := by
  classical
  constructor
  · rintro ⟨hnn, hfire⟩
    refine ⟨hnn, ?_⟩
    by_contra hne
    have hne' : (univ \ burn G q D).Nonempty := by
      rw [Finset.sdiff_nonempty]
      intro hsub
      exact hne (Finset.univ_subset_iff.mp hsub)
    have hsub : univ \ burn G q D ⊆ univ.erase q := by
      intro x hx
      rw [Finset.mem_sdiff] at hx
      refine Finset.mem_erase.mpr ⟨fun hxq => hx.2 (hxq ▸ mem_burn_base G q D), Finset.mem_univ x⟩
    obtain ⟨v, hv, hlt⟩ := hfire (univ \ burn G q D) hsub hne'
    have hvnot : v ∉ burn G q D := (Finset.mem_sdiff.mp hv).2
    exact absurd (legal_unburnt G q D hvnot) (not_le.mpr hlt)
  · rintro ⟨hnn, hburn⟩
    refine ⟨hnn, fun S hS hSne => ?_⟩
    by_contra hcon
    push_neg at hcon
    have hlegal : ∀ v ∈ S, (outdeg G S v : ℤ) ≤ D v := fun v hv => hcon v hv
    have hq : q ∉ S := fun hq => (Finset.mem_erase.mp (hS hq)).1 rfl
    obtain ⟨x, hx⟩ := hSne
    have hxburn : x ∈ burn G q D := by rw [hburn]; exact Finset.mem_univ x
    exact disjoint_burn_of_legal G hq hlegal (Fintype.card V) x hxburn hx

end BrillNoetherDhar