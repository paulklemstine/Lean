/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Advanced Sheaf-Theoretic Tropical Persistence

This file extends the sheaf-theoretic framework for tropical persistence with:
- Difference-bound stability (not just interleaving)
- Poset sheaf structure on the critical stratification
- Cumulative sheaf jump as a Möbius-like inversion formula
- Higher sheaf jump vanishing for injective filtrations
- Singular support characterization
- Path and cycle graph computations

## Main Results

* `sheafEvtProfile_abs_diff_bound` — |profile₁(t) - profile₂(t)| ≤ controlled bound
* `stalkRank_eq_cumulative_stalkJump` — stalk rank = cumulative fiber counts
* `sheafEvtProfile_diff_eq_jump_sum` — interval jump sum (Möbius inversion)
* `posetSheaf_restriction_compatible` — poset sheaf functoriality
* `higherSheafJump_vanishes_of_injective` — higher jump vanishing
* `sheafJump_le_three_pathGr` — path graph jump bound
* `singularSupport_sub_critVals` — singular support containment
* `pathGr_degree_le_two` — path graph degree bound

## References

* Curry, "Sheaves, Cosheaves and Applications" (2014)
* Kashiwara-Schapira, "Sheaves on Manifolds" (1990)
-/

import Mathlib
import Bridges.SheafPersistence
open Finset BigOperators Classical

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

noncomputable section

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Stability Difference Bounds -/

/-- **Symmetric difference bound:** the absolute difference of sheaf event
    profiles is bounded by the maximum shift-increment from either side.
    This converts the interleaving into a single pointwise estimate. -/
theorem sheafEvtProfile_abs_diff_bound
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VFilt V) (ε : ℝ) (hε : 0 ≤ ε)
    (hclose : ∀ v, |f v - g v| ≤ ε) (t : ℝ) :
    |sheafEvtProfile G f t - sheafEvtProfile G g t| ≤
      max (sheafEvtProfile G g (t + ε) - sheafEvtProfile G g t)
          (sheafEvtProfile G f (t + ε) - sheafEvtProfile G f t) := by
  rw [abs_le]
  constructor
  · have h1 := sheafEvtProfile_stability G g f ε
        (fun v => by rw [abs_sub_comm]; exact hclose v) t
    linarith [le_max_right
      (sheafEvtProfile G g (t + ε) - sheafEvtProfile G g t)
      (sheafEvtProfile G f (t + ε) - sheafEvtProfile G f t)]
  · linarith [sheafEvtProfile_stability G f g ε hclose t,
      le_max_left
        (sheafEvtProfile G g (t + ε) - sheafEvtProfile G g t)
        (sheafEvtProfile G f (t + ε) - sheafEvtProfile G f t)]

/-! ## Stalk Rank and Weighted Fibers -/

/-- The **stalk rank** at threshold t: the cardinality of the active vertex set. -/
def stalkRank (f : VFilt V) (t : ℝ) : ℕ :=
  (activeVerts f t).card

/-- Stalk rank is monotone. -/
theorem stalkRank_mono (f : VFilt V) {s t : ℝ} (hst : s ≤ t) :
    stalkRank f s ≤ stalkRank f t :=
  Finset.card_le_card (activeVerts_mono f hst)

/-- Stalk rank is constant between critical values. -/
theorem stalkRank_const_between_critical
    (f : VFilt V) {s t : ℝ}
    (hgap : sameCritGap (critVals f) s t) :
    stalkRank f s = stalkRank f t := by
  unfold stalkRank
  rw [activeVerts_eq_of_sameCritGap f hgap]

/-- The **unweighted stalk jump**: number of vertices entering at time c. -/
def stalkJump (f : VFilt V) (c : ℝ) : ℕ :=
  (Finset.univ.filter (fun v => f v = c)).card

/-- Stalk rank decomposes as cumulative stalk jumps. -/
theorem stalkRank_eq_cumulative_stalkJump
    (f : VFilt V) (t : ℝ) :
    stalkRank f t =
      ∑ c ∈ (critVals f).filter (fun c => c ≤ t), stalkJump f c := by
  unfold stalkRank stalkJump
  rw [show activeVerts f t =
    ((critVals f).filter (fun c => c ≤ t)).biUnion
      (fun c => Finset.univ.filter (fun v => f v = c))
    from activeVerts_eq_biUnion f t]
  rw [Finset.card_biUnion (fibers_pairwiseDisjoint f _)]

/-! ## Poset Sheaf Structure -/

/-- Poset sheaf restriction map: inclusion of active sets for s ≤ t. -/
def posetSheafRestriction (f : VFilt V) {s t : ℝ} (hst : s ≤ t) :
    activeVerts f s → activeVerts f t :=
  fun ⟨v, hv⟩ => ⟨v, activeVerts_mono f hst hv⟩

/-- **Poset sheaf restriction maps compose** (functoriality condition).
    This is the key structural property that makes the active vertex assignment
    a genuine functor from the threshold poset to the category of finite sets. -/
theorem posetSheaf_restriction_compatible (f : VFilt V)
    {r s t : ℝ} (hrs : r ≤ s) (hst : s ≤ t) :
    posetSheafRestriction f (le_trans hrs hst) =
      posetSheafRestriction f hst ∘ posetSheafRestriction f hrs := by
  ext ⟨v, hv⟩; rfl

/-- Poset sheaf restriction is the identity on equal thresholds. -/
theorem posetSheaf_restriction_id (f : VFilt V) (t : ℝ) :
    posetSheafRestriction f (le_refl t) = id := by
  ext ⟨v, hv⟩; rfl

/-- The critical stratification has at most |V| elements. -/
theorem crit_strata_finite (f : VFilt V) :
    (critVals f).card ≤ Fintype.card V :=
  Finset.card_image_le

/-! ## Profile Inversion Formula -/

/-- Helper: the filter decomposition for critical values. -/
private theorem critVals_filter_split (f : VFilt V) (s t : ℝ) (hst : s ≤ t) :
    (critVals f).filter (fun c => c ≤ t) =
      (critVals f).filter (fun c => c ≤ s) ∪
      (critVals f).filter (fun c => s < c ∧ c ≤ t) := by
  ext c; simp only [mem_filter, mem_union]
  constructor
  · intro ⟨hc, hle⟩
    by_cases h : c ≤ s
    · left; exact ⟨hc, h⟩
    · right; exact ⟨hc, not_le.mp h, hle⟩
  · intro h; cases h with
    | inl h => exact ⟨h.1, le_trans h.2 hst⟩
    | inr h => exact ⟨h.1, h.2.2⟩

/-- Helper: disjointness of the two filter pieces. -/
private theorem critVals_filter_disjoint (f : VFilt V) (s t : ℝ) :
    Disjoint
      ((critVals f).filter (fun c => c ≤ s))
      ((critVals f).filter (fun c => s < c ∧ c ≤ t)) := by
  rw [Finset.disjoint_filter]
  intro c _ h1 h2; linarith

/-- **Sheaf jump inversion:** the sheaf event profile difference between t and s
    equals the sum of sheaf jumps at values in (s, t].
    This is a Möbius-like inversion formula on the threshold poset:
    the "global" persistence observable decomposes as a sum of "local" jump data. -/
theorem sheafEvtProfile_diff_eq_jump_sum
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (s t : ℝ) (hst : s ≤ t) :
    sheafEvtProfile G f t - sheafEvtProfile G f s =
      ∑ c ∈ (critVals f).filter (fun c => s < c ∧ c ≤ t),
        sheafJump G f c := by
  simp only [sheafEvtProfile]
  rw [critVals_filter_split f s t hst,
      Finset.sum_union (critVals_filter_disjoint f s t)]
  ring

/-! ## Higher Sheaf Jump Vanishing -/

/-- **Higher sheaf jump** at a critical value: a measure of "simultaneous"
    vertex entrance. For filtrations that add exactly one vertex at a time,
    this is always zero. -/
def higherSheafJump (f : VFilt V) (c : ℝ) : ℕ :=
  let fiber := Finset.univ.filter (fun v => f v = c)
  if fiber.card ≤ 1 then 0 else fiber.card - 1

/-- **Higher jump vanishing for injective filtrations.**
    If the filtration assigns distinct entrance times to all vertices,
    then all higher sheaf jumps vanish. This is the degree-0 concentration
    property: generic filtrations have no simultaneous events. -/
theorem higherSheafJump_vanishes_of_injective
    (f : VFilt V)
    (hinj : Function.Injective f)
    (c : ℝ) :
    higherSheafJump f c = 0 := by
  unfold higherSheafJump
  simp only
  have hle : (Finset.univ.filter (fun v => f v = c)).card ≤ 1 := by
    rw [Finset.card_le_one]
    intro a ha b hb
    simp only [mem_filter, mem_univ, true_and] at ha hb
    exact hinj (ha.trans hb.symm)
  simp [show (Finset.univ.filter (fun v => f v = c)).card ≤ 1 from hle]

/-- The path filtration is injective: distinct vertices enter at distinct times. -/
theorem pathFilt_injective (n : ℕ) : Function.Injective (pathFilt n) := by
  intro a b h
  simp [pathFilt] at h
  exact Fin.ext (by exact_mod_cast h)

/-- Higher sheaf jumps vanish for path filtrations. -/
theorem higherSheafJump_pathGr_vanishes (n : ℕ) (c : ℝ) :
    higherSheafJump (pathFilt n) c = 0 :=
  higherSheafJump_vanishes_of_injective _ (pathFilt_injective n) c

/-! ## Path Graph Sheaf Jump Bound -/

/-- Path graph vertices have degree at most 2. -/
theorem pathGr_degree_le_two (n : ℕ) (v : Fin (n + 1)) :
    (pathGr n).degree v ≤ 2 := by
  simp only [SimpleGraph.degree]
  let S1 := Finset.univ.filter (fun w : Fin (n + 1) => w.val + 1 = v.val)
  let S2 := Finset.univ.filter (fun w : Fin (n + 1) => v.val + 1 = w.val)
  have hsub : (pathGr n).neighborFinset v ⊆ S1 ∪ S2 := by
    intro w hw
    rw [SimpleGraph.mem_neighborFinset] at hw
    simp only [S1, S2, mem_union, mem_filter, mem_univ, true_and, pathGr] at hw ⊢
    exact hw.symm
  have hS1 : S1.card ≤ 1 := by
    rw [Finset.card_le_one]; intro a ha b hb
    simp [S1] at ha hb; exact Fin.ext (by omega)
  have hS2 : S2.card ≤ 1 := by
    rw [Finset.card_le_one]; intro a ha b hb
    simp [S2] at ha hb; exact Fin.ext (by omega)
  linarith [Finset.card_le_card hsub, Finset.card_union_le S1 S2]

/-- At most one vertex enters at each critical time for path filtration. -/
theorem pathFilt_fiber_card_le_one (n : ℕ) (c : ℝ) :
    (Finset.univ.filter (fun v => pathFilt n v = c)).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  simp only [mem_filter, mem_univ, true_and] at ha hb
  simp [pathFilt] at ha hb
  exact Fin.ext (by exact_mod_cast ha.trans hb.symm)

/-- **Path graph sheaf jump bound.** At any critical value of a path graph,
    the sheaf jump is at most 3 (degree ≤ 2, plus 1, times at most 1 vertex). -/
theorem sheafJump_le_three_pathGr (n : ℕ) (c : ℝ) :
    sheafJump (pathGr n) (pathFilt n) c ≤ 3 := by
  simp only [sheafJump]
  by_cases h : (Finset.univ.filter (fun v => pathFilt n v = c)).card = 0
  · rw [Finset.card_eq_zero.mp h]; simp
  · have hone : (Finset.univ.filter (fun v => pathFilt n v = c)).card = 1 := by
      have := pathFilt_fiber_card_le_one n c; omega
    obtain ⟨w, hw⟩ := Finset.card_eq_one.mp hone
    rw [hw]; simp
    have := pathGr_degree_le_two n w
    omega

/-! ## Singular Support -/

/-- The **singular support** of the tropical rank sheaf: the set of critical
    values where the sheaf jump is nonzero. This is the 1-dimensional analogue
    of the microsupport in Kashiwara-Schapira theory. -/
def singularSupport (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) : Finset ℝ :=
  (critVals f).filter (fun c => sheafJump G f c ≠ 0)

/-- The singular support is contained in the critical values. -/
theorem singularSupport_sub_critVals
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) :
    singularSupport G f ⊆ critVals f :=
  Finset.filter_subset _ _

/-- The singular support has at most |V| elements. -/
theorem singularSupport_card_le
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) :
    (singularSupport G f).card ≤ Fintype.card V :=
  le_trans (Finset.card_le_card (singularSupport_sub_critVals G f))
    (crit_strata_finite f)

/-! ## Constructibility Package -/

/-- **Extended constructibility:** Both the stalk rank and the Euler characteristic
    are constant on each open interval between critical values. -/
theorem constructibility_package
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) {s t : ℝ}
    (hgap : sameCritGap (critVals f) s t) :
    stalkRank f s = stalkRank f t ∧
    tropEvtProfile G f s = tropEvtProfile G f t ∧
    activeEulerChar G f s = activeEulerChar G f t :=
  ⟨stalkRank_const_between_critical f hgap,
   tropEvtProfile_const_between_critical G f hgap,
   activeEulerChar_const_between_critical G f hgap⟩

/-! ## Sheaf Profile Above All Critical Values -/

/-- For a threshold above all critical values, the sheaf event profile
    equals the sum of all sheaf jumps. -/
theorem sheafEvtProfile_above_all_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) (ht : ∀ v, f v ≤ t) :
    sheafEvtProfile G f t = ∑ c ∈ critVals f, sheafJump G f c := by
  simp only [sheafEvtProfile]
  congr 1
  rw [Finset.filter_eq_self]
  intro c hc
  obtain ⟨v, _, rfl⟩ := Finset.mem_image.mp hc
  exact ht v

/-- The event profile below all critical values is zero. -/
theorem sheafEvtProfile_below_all_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) (ht : ∀ v, t < f v) :
    sheafEvtProfile G f t = 0 := by
  have := tropEvtProfile_below_all_critical G f t ht
  rwa [tropEvtProfile_eq_cumSheafJump] at this

/-! ## Filtration Sup Distance via Sheaf -/

/-- Filtration sup distance for VFilt. -/
def vfiltSupDist [Nonempty V] (f g : VFilt V) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun v => |f v - g v|)

/-- Individual vertex differences bounded by sup distance. -/
theorem vfiltSupDist_spec [Nonempty V] (f g : VFilt V) (v : V) :
    |f v - g v| ≤ vfiltSupDist f g := by
  exact Finset.le_sup' (fun v => |f v - g v|) (Finset.mem_univ v)

/-- **Main stability theorem via sheaf profiles.**
    Stability follows from the functoriality of the sheaf construction. -/
theorem sheaf_stability_via_supDist [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VFilt V) (ε : ℝ) (hε : 0 ≤ ε)
    (hfg : vfiltSupDist f g ≤ ε) (t : ℝ) :
    sheafEvtProfile G f t ≤ sheafEvtProfile G g (t + ε) ∧
    sheafEvtProfile G g t ≤ sheafEvtProfile G f (t + ε) := by
  have hclose : ∀ v, |f v - g v| ≤ ε :=
    fun v => le_trans (vfiltSupDist_spec f g v) hfg
  exact sheafEvtProfile_stability_both G f g ε hclose t

/-! ## Cycle Graph -/

/-- The cycle graph on `Fin n` for `n ≥ 3`: vertex i adjacent to (i±1) mod n. -/
def cycleGr (n : ℕ) (hn : 3 ≤ n) : SimpleGraph (Fin n) where
  Adj i j := (i.val + 1) % n = j.val ∨ (j.val + 1) % n = i.val
  symm := by intro i j h; cases h with | inl h => exact Or.inr h | inr h => exact Or.inl h
  loopless := ⟨fun i h => by
    have hi := i.isLt
    rcases h with h | h
    all_goals {
      have h1 : (i.val + 1) % n = i.val := h
      by_cases hge : i.val + 1 ≥ n
      · rw [Nat.mod_eq_sub_mod hge] at h1; simp at h1; omega
      · push_neg at hge; rw [Nat.mod_eq_of_lt hge] at h1; omega
    }⟩

instance cycleGrDecAdj (n : ℕ) (hn : 3 ≤ n) : DecidableRel (cycleGr n hn).Adj := by
  intro i j; simp only [cycleGr]; exact inferInstance

/-- Cycle filtration: vertex i enters at time i. -/
def cycleFilt (n : ℕ) : VFilt (Fin n) :=
  fun i => (i : ℝ)

/-- The cycle filtration is injective. -/
theorem cycleFilt_injective (n : ℕ) : Function.Injective (cycleFilt n) := by
  intro a b h; simp [cycleFilt] at h; exact Fin.ext (by exact_mod_cast h)

/-- Higher sheaf jumps vanish for cycle filtrations. -/
theorem higherSheafJump_cycleGr_vanishes (n : ℕ) (hn : 3 ≤ n) (c : ℝ) :
    higherSheafJump (cycleFilt n) c = 0 :=
  higherSheafJump_vanishes_of_injective _ (cycleFilt_injective n) c

end