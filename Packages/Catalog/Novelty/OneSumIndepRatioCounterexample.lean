import Mathlib
import Novelty.IndependenceRatioChromatic
import Novelty.IndependenceRatioLowerBound
import Novelty.OneSumEqualityAnalysis

/-!
# The independence-ratio constraint `i(G) ≥ 1/4` is *not* closed under 1-sums

The companion file `Novelty.OneSumEqualityAnalysis` proved two things about 1-sums (vertex
amalgamations) `G = G₁ ⊕_v G₂`:

* colourability *is* closed under 1-sums (`SimpleGraph.IsOneSum.colorable`), so the class of
  `4`-colourable graphs — which by the catalog bound `indepRatio_ge_quarter_of_colorable_four`
  satisfies `i ≥ 1/4` — is 1-sum stable; and
* independence is only *superadditive with a defect of one*
  (`SimpleGraph.IsOneSum.card_add_card_le_indepNum_succ`), giving the sharp ratio bound
  `i(G) ≥ r - (1-r)/n` (`SimpleGraph.IsOneSum.indepRatio_ge_of_sides`).

This file settles the resulting dichotomy by an explicit extremal example, hence proves that
the "Minimum Independence Ratio Constraint" `i ≥ 1/4` is **not** a 1-sum closed property, and
that the defect term `-(1-r)/n` above cannot be improved.

The example is the 1-sum of two copies of `K₈` minus an edge (`K8me`), amalgamated at an
endpoint of the missing edge:

* `K8me.indepRatio = 1/4` — each side sits exactly on the threshold;
* `Glue.indepNum = 3` and `Glue.indepRatio = 1/5 < 1/4` — the amalgam falls below it;
* `Glue.indepRatio = 1/4 - (1 - 1/4)/15` — the general defect bound of the companion file is
  attained *with equality*, so it is sharp;
* `K8me_not_colorable_four` — consistently with the closure theorem, the sides are not
  `4`-colourable (they contain `K₇`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): 1-sums act as `max` on `χ` and `ω` but as a *mediant with defect*
on the pair `(α, n)`.  Bold prediction: the threshold property `i ≥ 1/4` is therefore not
1-sum closed, and the extremal configuration is a graph whose every maximum independent set
uses the cut vertex.
Experiment (Experimenter): brute-force search over the parameter space
`(n₁, α₁, α(G₁ - v))` showed that a drop below the threshold needs `4α_i - n_i ≤ 1` and
`α(G_i - v) = α_i - 1` on both sides; the smallest realisation is `K₈` minus an edge with
`v` an endpoint of the missing edge (`n = 8`, `α = 2`, `α(G - v) = 1`).  Exhaustive
enumeration of the `2¹⁵` vertex subsets of the amalgam confirmed `α = 3` (witness `{0,1,8}`),
i.e. `i = 1/5`.
Analysis (Analyst): the drop is exactly the defect term: `1/4 - (1 - 1/4)/15 = 1/5`.  So the
failure is not an accident of the example but the equality case of the general bound; any
1-sum of two threshold graphs loses at most `(1-r)/n`.
Critique (Critic): the sides are necessarily *not* `4`-colourable — otherwise the closure
theorem of the companion file would force `i ≥ 1/4` on the amalgam.  We verify this directly
(`K8me` contains a `K₇`), so the example does not contradict the colouring side of the
dictionary; it delimits it.
Synthesis (PI): "sharp bound + closure" do *not* compose into "closure of the sharp bound":
the reciprocal dictionary `i ≥ 1/k ↔ k`-colourability survives amalgamation only on the
colouring side.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace SimpleGraph

namespace OneSumCounterexample

/-! ### A generic two-element bound

If any two distinct elements of a finite set are forced to be the pair `{a, b}`, then the set
has at most two elements, and it contains `a` as soon as it has two. -/

theorem card_le_two_of_forced_pair {α : Type*} [DecidableEq α] {t : Finset α} {a b : α}
    (H : ∀ x ∈ t, ∀ y ∈ t, x ≠ y → (x = a ∧ y = b) ∨ (x = b ∧ y = a)) :
    t.card ≤ 2 ∧ (2 ≤ t.card → a ∈ t) := by
  by_cases hc : 2 ≤ t.card
  · obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.1 (show 1 < t.card by omega)
    have hsub : t ⊆ ({a, b} : Finset α) := by
      intro z hz
      obtain ⟨w, hw, hwz⟩ : ∃ w ∈ t, w ≠ z := by
        by_cases hpz : p = z
        · exact ⟨q, hq, fun hqz => hpq (hpz.trans hqz.symm)⟩
        · exact ⟨p, hp, hpz⟩
      rcases H z hz w hw (fun hzw => hwz hzw.symm) with ⟨hz1, _⟩ | ⟨hz1, _⟩ <;>
        simp [hz1]
    have hcard : t.card ≤ 2 :=
      le_trans (Finset.card_le_card hsub) (le_trans (Finset.card_insert_le _ _) (by simp))
    refine ⟨hcard, fun _ => ?_⟩
    rcases H p hp q hq hpq with ⟨hz1, _⟩ | ⟨_, hw1⟩
    · exact hz1 ▸ hp
    · exact hw1 ▸ hq
  · exact ⟨by omega, fun hcon => absurd hcon hc⟩

/-! ### The side graph: `K₈` minus an edge -/

/-- Adjacency of `K₈` minus the edge `{0, 1}`. -/
def k8meAdj (x y : Fin 8) : Prop :=
  x ≠ y ∧ ¬((x : ℕ) = 0 ∧ (y : ℕ) = 1) ∧ ¬((x : ℕ) = 1 ∧ (y : ℕ) = 0)

instance : DecidableRel k8meAdj := fun x y => by unfold k8meAdj; infer_instance

/-- `K₈` minus one edge: the extremal side graph, with independence ratio exactly `1/4`. -/
def K8me : SimpleGraph (Fin 8) where
  Adj := k8meAdj
  symm := by intro x y hxy; revert hxy; revert x y; decide
  loopless := ⟨by decide⟩

instance : DecidableRel K8me.Adj := inferInstanceAs (DecidableRel k8meAdj)

/-- In `K₈ - e`, two distinct non-adjacent vertices are the endpoints of the missing edge. -/
theorem forced_pair_k8me (x y : Fin 8) (hne : x ≠ y) (hadj : ¬ K8me.Adj x y) :
    (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 0) := by
  revert x y; decide

theorem K8me_indepNum : K8me.indepNum = 2 := by
  classical
  refine le_antisymm ?_ ?_
  · obtain ⟨s, hs, hcard⟩ := K8me.exists_isNIndepSet_indepNum
    have H : ∀ x ∈ s, ∀ y ∈ s, x ≠ y →
        (x = (0 : Fin 8) ∧ y = (1 : Fin 8)) ∨ (x = (1 : Fin 8) ∧ y = (0 : Fin 8)) := by
      intro x hx y hy hne
      exact forced_pair_k8me x y hne (hs (Finset.mem_coe.2 hx) (Finset.mem_coe.2 hy) hne)
    have := (card_le_two_of_forced_pair H).1
    omega
  · have hind : K8me.IsIndepSet ↑({0, 1} : Finset (Fin 8)) := by
      intro x hx y hy hne
      simp only [Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
        Set.mem_singleton_iff] at hx hy
      rcases hx with rfl | rfl <;> rcases hy with rfl | rfl <;> first
        | exact absurd rfl hne
        | decide
    have := hind.card_le_indepNum
    simpa using this

/-- Each side of the amalgam sits exactly on the threshold: `i(K₈ - e) = 1/4`. -/
theorem K8me_indepRatio : K8me.indepRatio = (1 : ℚ) / 4 := by
  rw [SimpleGraph.indepRatio, K8me_indepNum]
  norm_num

/-- The sides are *not* `4`-colourable: they contain a `K₇`.  (By the closure theorem of the
companion file this is forced for any counterexample to closure of `i ≥ 1/4`.) -/
theorem K8me_not_colorable_four : ¬ K8me.Colorable 4 := by
  classical
  rintro ⟨C⟩
  set s : Finset (Fin 8) := {1, 2, 3, 4, 5, 6, 7} with hs
  have hclique : ∀ x ∈ s, ∀ y ∈ s, x ≠ y → K8me.Adj x y := by
    rw [hs]; decide
  have hinj : Set.InjOn C s := by
    intro x hx y hy hxy
    by_contra hne
    exact C.valid (hclique x hx y hy hne) hxy
  have hcard : s.card ≤ (Finset.univ : Finset (Fin 4)).card :=
    Finset.card_le_card_of_injOn C (fun x _ => Finset.mem_univ (C x)) hinj
  simp [hs] at hcard

/-! ### The amalgam: two copies of `K₈ - e` glued at an endpoint of the missing edge

Vertices `0,…,7` form the first side (missing edge `{0,1}`), vertices `0, 8,…,14` the second
(missing edge `{0,8}`); the cut vertex is `0`. -/

/-- Adjacency of the first part: `K₈` minus `{0,1}` on the vertices `0,…,7`. -/
def glueLeftAdj (x y : Fin 15) : Prop :=
  x ≠ y ∧ (x : ℕ) ≤ 7 ∧ (y : ℕ) ≤ 7 ∧
    ¬((x : ℕ) = 0 ∧ (y : ℕ) = 1) ∧ ¬((x : ℕ) = 1 ∧ (y : ℕ) = 0)

/-- Adjacency of the second part: `K₈` minus `{0,8}` on the vertices `0, 8,…,14`. -/
def glueRightAdj (x y : Fin 15) : Prop :=
  x ≠ y ∧ ((x : ℕ) = 0 ∨ 8 ≤ (x : ℕ)) ∧ ((y : ℕ) = 0 ∨ 8 ≤ (y : ℕ)) ∧
    ¬((x : ℕ) = 0 ∧ (y : ℕ) = 8) ∧ ¬((x : ℕ) = 8 ∧ (y : ℕ) = 0)

/-- Adjacency of the 1-sum. -/
def glueAdj (x y : Fin 15) : Prop := glueLeftAdj x y ∨ glueRightAdj x y

instance : DecidableRel glueLeftAdj := fun x y => by unfold glueLeftAdj; infer_instance
instance : DecidableRel glueRightAdj := fun x y => by unfold glueRightAdj; infer_instance
instance : DecidableRel glueAdj := fun x y => by unfold glueAdj; infer_instance

/-- The first part of the amalgam. -/
def GlueLeft : SimpleGraph (Fin 15) where
  Adj := glueLeftAdj
  symm := by intro x y hxy; revert hxy; revert x y; decide
  loopless := ⟨by decide⟩

/-- The second part of the amalgam. -/
def GlueRight : SimpleGraph (Fin 15) where
  Adj := glueRightAdj
  symm := by intro x y hxy; revert hxy; revert x y; decide
  loopless := ⟨by decide⟩

/-- The amalgam of two copies of `K₈ - e` at an endpoint of the missing edge. -/
def Glue : SimpleGraph (Fin 15) where
  Adj := glueAdj
  symm := by intro x y hxy; revert hxy; revert x y; decide
  loopless := ⟨by decide⟩

instance : DecidableRel Glue.Adj := inferInstanceAs (DecidableRel glueAdj)

/-- The first side. -/
def sideA : Set (Fin 15) := {x | (x : ℕ) ≤ 7}

/-- The second side. -/
def sideB : Set (Fin 15) := {x | (x : ℕ) = 0 ∨ 8 ≤ (x : ℕ)}

/-- **The amalgam really is a 1-sum** of its two parts along the cut vertex `0`. -/
theorem glue_isOneSum : Glue.IsOneSum GlueLeft GlueRight sideA sideB 0 where
  sup_eq := rfl
  left_support := fun {x y} hxy => ⟨hxy.2.1, hxy.2.2.1⟩
  right_support := fun {x y} hxy => ⟨hxy.2.1, hxy.2.2.1⟩
  inter_eq := by
    ext x
    simp only [sideA, sideB, Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_singleton_iff,
      Fin.ext_iff]
    omega
  union_eq := by
    ext x
    simp only [sideA, sideB, Set.mem_union, Set.mem_setOf_eq, Set.mem_univ, iff_true]
    omega

/-- On the first side, non-adjacency forces the missing edge `{0,1}`. -/
theorem forced_pair_left (x y : Fin 15) (hx : x ∈ sideA) (hy : y ∈ sideA) (hne : x ≠ y)
    (hadj : ¬ Glue.Adj x y) : (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 0) := by
  simp only [sideA, Set.mem_setOf_eq] at hx hy
  revert x y
  decide

/-- On the second side, non-adjacency forces the missing edge `{0,8}`. -/
theorem forced_pair_right (x y : Fin 15) (hx : x ∈ sideB) (hy : y ∈ sideB) (hne : x ≠ y)
    (hadj : ¬ Glue.Adj x y) : (x = 0 ∧ y = 8) ∨ (x = 8 ∧ y = 0) := by
  simp only [sideB, Set.mem_setOf_eq] at hx hy
  revert x y
  decide

instance : DecidablePred (· ∈ sideA) := fun x => by unfold sideA; infer_instance
instance : DecidablePred (· ∈ sideB) := fun x => by unfold sideB; infer_instance

/-- **Every independent set of the amalgam has at most three vertices.**  This is the
splitting identity of the companion file combined with the two "forced pair" facts. -/
theorem card_le_three_of_indepSet {s : Finset (Fin 15)} (hs : Glue.IsIndepSet ↑s) :
    s.card ≤ 3 := by
  classical
  have hsplit := glue_isOneSum.card_add_indicator_eq s
  set tA := s.filter (· ∈ sideA) with htA
  set tB := s.filter (· ∈ sideB) with htB
  have HA : ∀ x ∈ tA, ∀ y ∈ tA, x ≠ y →
      (x = (0 : Fin 15) ∧ y = (1 : Fin 15)) ∨ (x = (1 : Fin 15) ∧ y = (0 : Fin 15)) := by
    intro x hx y hy hne
    rw [htA, Finset.mem_filter] at hx hy
    exact forced_pair_left x y hx.2 hy.2 hne
      (hs (Finset.mem_coe.2 hx.1) (Finset.mem_coe.2 hy.1) hne)
  have HB : ∀ x ∈ tB, ∀ y ∈ tB, x ≠ y →
      (x = (0 : Fin 15) ∧ y = (8 : Fin 15)) ∨ (x = (8 : Fin 15) ∧ y = (0 : Fin 15)) := by
    intro x hx y hy hne
    rw [htB, Finset.mem_filter] at hx hy
    exact forced_pair_right x y hx.2 hy.2 hne
      (hs (Finset.mem_coe.2 hx.1) (Finset.mem_coe.2 hy.1) hne)
  obtain ⟨hA2, hA0⟩ := card_le_two_of_forced_pair HA
  obtain ⟨hB2, hB0⟩ := card_le_two_of_forced_pair HB
  by_cases hv : (0 : Fin 15) ∈ s
  · rw [if_pos hv] at hsplit
    omega
  · rw [if_neg hv] at hsplit
    have hA1 : tA.card ≤ 1 := by
      by_contra hcon
      have := hA0 (by omega)
      rw [htA, Finset.mem_filter] at this
      exact hv this.1
    have hB1 : tB.card ≤ 1 := by
      by_contra hcon
      have := hB0 (by omega)
      rw [htB, Finset.mem_filter] at this
      exact hv this.1
    omega

/-- **The independence number of the amalgam is `3`** (witness `{0, 1, 8}`). -/
theorem glue_indepNum : Glue.indepNum = 3 := by
  classical
  refine le_antisymm ?_ ?_
  · obtain ⟨s, hs, hcard⟩ := Glue.exists_isNIndepSet_indepNum
    exact hcard ▸ card_le_three_of_indepSet hs
  · have hind : Glue.IsIndepSet ↑({0, 1, 8} : Finset (Fin 15)) := by
      intro x hx y hy hne
      simp only [Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
        Set.mem_singleton_iff] at hx hy
      rcases hx with rfl | rfl | rfl <;> rcases hy with rfl | rfl | rfl <;> first
        | exact absurd rfl hne
        | decide
    have := hind.card_le_indepNum
    simpa using this

/-- **The amalgam falls below the threshold**: `i(Glue) = 1/5`. -/
theorem glue_indepRatio : Glue.indepRatio = (1 : ℚ) / 5 := by
  rw [SimpleGraph.indepRatio, glue_indepNum]
  norm_num

theorem glue_indepRatio_lt_quarter : Glue.indepRatio < (1 : ℚ) / 4 := by
  rw [glue_indepRatio]; norm_num

/-- **The general defect bound of the companion file is attained**: the amalgam realises
`i(G) = r - (1 - r)/n` for `r = 1/4` and `n = 15`. -/
theorem glue_attains_defect_bound :
    Glue.indepRatio = (1 : ℚ) / 4 - (1 - (1 : ℚ) / 4) / (Fintype.card (Fin 15) : ℚ) := by
  rw [glue_indepRatio]
  norm_num

/-! ### The two sides are copies of `K₈ - e` -/

/-- Embedding of the first side. -/
def embA (x : Fin 8) : Fin 15 := ⟨(x : ℕ), by omega⟩

/-- Embedding of the second side (the cut vertex `0` is fixed). -/
def embB (x : Fin 8) : Fin 15 := if (x : ℕ) = 0 then 0 else ⟨(x : ℕ) + 7, by omega⟩

theorem embA_injective : Function.Injective embA := by
  intro a b hab; revert hab; revert a b; decide

theorem embB_injective : Function.Injective embB := by
  intro a b hab; revert hab; revert a b; decide

theorem range_embA (z : Fin 15) : z ∈ sideA ↔ ∃ x : Fin 8, embA x = z := by
  revert z; decide

theorem range_embB (z : Fin 15) : z ∈ sideB ↔ ∃ x : Fin 8, embB x = z := by
  revert z; decide

/-- The first side of the amalgam is a copy of `K₈ - e`. -/
theorem glue_left_side (x y : Fin 8) : Glue.Adj (embA x) (embA y) ↔ K8me.Adj x y := by
  revert x y; decide

/-- The second side of the amalgam is a copy of `K₈ - e`. -/
theorem glue_right_side (x y : Fin 8) : Glue.Adj (embB x) (embB y) ↔ K8me.Adj x y := by
  revert x y; decide

/-! ### The main negative result -/

/-- **The Minimum Independence Ratio Constraint is not 1-sum closed.**  There is a 1-sum whose
two sides are isomorphic copies of a graph with independence ratio exactly `1/4`, but whose
amalgam has independence ratio `1/5 < 1/4`.  Contrast with
`SimpleGraph.IsOneSum.colorable`: `4`-colourability *is* 1-sum closed. -/
theorem indepRatio_quarter_not_oneSum_closed :
    ∃ (G G₁ G₂ : SimpleGraph (Fin 15)) (A B : Set (Fin 15)) (v : Fin 15)
      (H : SimpleGraph (Fin 8)) (f g : Fin 8 → Fin 15),
      G.IsOneSum G₁ G₂ A B v ∧
      Function.Injective f ∧ Function.Injective g ∧
      (∀ z, z ∈ A ↔ ∃ x, f x = z) ∧
      (∀ z, z ∈ B ↔ ∃ x, g x = z) ∧
      (∀ x y, G.Adj (f x) (f y) ↔ H.Adj x y) ∧
      (∀ x y, G.Adj (g x) (g y) ↔ H.Adj x y) ∧
      H.indepRatio = (1 : ℚ) / 4 ∧ G.indepRatio < (1 : ℚ) / 4 := by
  classical
  exact ⟨Glue, GlueLeft, GlueRight, sideA, sideB, 0, K8me, embA, embB, glue_isOneSum,
    embA_injective, embB_injective, range_embA, range_embB, glue_left_side, glue_right_side,
    K8me_indepRatio, glue_indepRatio_lt_quarter⟩

/-- **Boundary of the phenomenon.**  Whenever a 1-sum drops below the threshold, at least one
side fails to be `4`-colourable; in the example both sides do (they contain `K₇`). -/
theorem side_not_colorable_four_of_drop
    {G G₁ G₂ : SimpleGraph (Fin 15)} {A B : Set (Fin 15)} {v : Fin 15}
    (h : G.IsOneSum G₁ G₂ A B v) (hdrop : G.indepRatio < (1 : ℚ) / 4) :
    ¬ G₁.Colorable 4 ∨ ¬ G₂.Colorable 4 := by
  by_contra hcon
  push_neg at hcon
  exact absurd (h.indepRatio_ge_quarter (by norm_num) hcon.1 hcon.2) (not_le.2 hdrop)

end OneSumCounterexample

end SimpleGraph