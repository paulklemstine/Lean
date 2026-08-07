/-
# Bridges are *not* an obstruction in the infinite setting

For finite cubic graphs, a bridge kills all three conjectures: the bridge is a one-element odd
cut, and `not_bergeFulkerson_of_oddCut_singleton` shows the same in the infinite setting
*provided one side of the cut is finite*.  This file shows that the finiteness proviso is
essential, by exhibiting

  `k4Chain` : an infinite cubic graph, every level of which is a copy of `K₄` with one edge
  "unrolled" along ℤ,

which

* is cubic (`k4Chain_isCubic`),
* satisfies Berge–Fulkerson, Fan–Raspaud and Máčajová–Škoviera
  (`k4Chain_bergeFulkerson`, …), and yet
* **has a bridge** (`k4Chain_isBridge`): in fact every edge joining level `m` to level `m+1`
  is one, so it has infinitely many bridges (`k4Chain_bridges_infinite`).

Hence, unlike in the finite case, bridgelessness is not a necessary condition for any of the
three properties once the graph is infinite: the two sides of the offending cut are infinite,
so the parity argument behind the finite obstruction has nothing to bite on.
-/
import Bridges.InfiniteCubicMatchingsPetersenLift

namespace Bridges.InfiniteCubicMatchings

universe u

/-! ## A separation criterion for non-reachability -/

variable {V : Type u}

/-- Walking inside a graph cannot change the side of a set that no edge crosses. -/
theorem mem_iff_of_walk {H : SimpleGraph V} {S : Set V}
    (hsep : ∀ a b, H.Adj a b → (a ∈ S ↔ b ∈ S)) :
    ∀ {a b : V}, H.Walk a b → (a ∈ S ↔ b ∈ S) := by
  intro a b w
  induction w with
  | nil => exact Iff.rfl
  | cons h _ ih => exact (hsep _ _ h).trans ih

/-- If no edge of `H` crosses `S`, then no vertex of `S` reaches a vertex outside `S`. -/
theorem not_reachable_of_separating {H : SimpleGraph V} {S : Set V}
    (hsep : ∀ a b, H.Adj a b → (a ∈ S ↔ b ∈ S)) {a b : V} (ha : a ∈ S) (hb : b ∉ S) :
    ¬ H.Reachable a b := by
  rintro ⟨w⟩
  exact hb ((mem_iff_of_walk hsep w).mp ha)

/-! ## `K₄` and its three perfect matchings -/

/-- The complete graph on four vertices. -/
def k4 : SimpleGraph (Fin 4) where
  Adj u v := u ≠ v
  symm := fun _ _ h => h.symm
  loopless := ⟨fun _ h => h rfl⟩

instance : DecidableRel k4.Adj := fun u v => inferInstanceAs (Decidable (u ≠ v))

theorem k4_isCubic : IsCubic k4 := by
  intro v
  rw [show k4.neighborSet v = {u | u ∈ (Finset.univ.filter (fun u => u ≠ v) : Finset (Fin 4))}
      by ext u; simp [k4, SimpleGraph.mem_neighborSet, ne_comm],
    Set.ncard_eq_toFinset_card', Set.toFinset_setOf]
  revert v
  decide

/-- The three perfect matchings of `K₄`, as partner tables. -/
def k4PM : Fin 3 → Fin 4 → Fin 4
  | 0 => ![1, 0, 3, 2]
  | 1 => ![2, 3, 0, 1]
  | 2 => ![3, 2, 1, 0]

/-- Each table is a perfect matching of `K₄`. -/
def k4Matching (i : Fin 3) : PerfectMatching k4 where
  partner := k4PM i
  isAdj := by revert i; decide
  invol := by revert i; decide

/-- The three matchings form a proper 3-edge-colouring of `K₄`. -/
theorem k4_properThreeEdgeColoring : ProperThreeEdgeColoring k4 := by
  refine ⟨k4Matching, ?_, ?_⟩
  · intro i j hij
    rw [Set.disjoint_left]
    intro e hei hej
    induction e with
    | _ u w =>
      rw [PerfectMatching.mem_edges] at hei hej
      have key : ∀ (i j : Fin 3) (u w : Fin 4), i ≠ j → k4PM i u = w → k4PM j u = w → False := by
        decide
      exact key i j u w hij hei hej
  · intro e
    induction e with
    | _ u w =>
      intro hE
      have key : ∀ u w : Fin 4, u ≠ w → ∃ i : Fin 3, k4PM i u = w := by decide
      obtain ⟨i, hi⟩ := key u w hE
      exact ⟨i, by rw [PerfectMatching.mem_edges]; exact hi⟩

theorem k4_bergeFulkerson : BergeFulkerson k4 := k4_properThreeEdgeColoring.bergeFulkerson

/-! ## Unrolling one edge of `K₄` along ℤ -/

/-- The voltage assignment giving the edge `3 — 0` of `K₄` voltage `1`, all other edges
voltage `0`. -/
def k4Vol (u v : Fin 4) : ℤ := if u = 3 ∧ v = 0 then 1 else if u = 0 ∧ v = 3 then -1 else 0

theorem k4Vol_antisymm (u v : Fin 4) : k4Vol v u = -k4Vol u v := by
  revert u v
  decide

/-- The infinite ℤ-voltage lift of `K₄` along `k4Vol`: an infinite chain of `K₄`-blocks, each
joined to the next by a single edge. -/
abbrev k4Chain : SimpleGraph (ℤ × Fin 4) := zLift k4 k4Vol k4Vol_antisymm

theorem k4Chain_isCubic : IsCubic k4Chain :=
  zLift_isCubic k4 k4Vol k4Vol_antisymm k4_isCubic

/-- **The chain satisfies Berge–Fulkerson**, even though it has a bridge. -/
theorem k4Chain_bergeFulkerson : BergeFulkerson k4Chain :=
  zLift_bergeFulkerson k4 k4Vol k4Vol_antisymm k4_bergeFulkerson

theorem k4Chain_fanRaspaud : FanRaspaud k4Chain := k4Chain_bergeFulkerson.fanRaspaud

theorem k4Chain_macajovaSkoviera : MacajovaSkoviera k4Chain :=
  k4Chain_bergeFulkerson.macajovaSkoviera

theorem k4Chain_edgeSet_infinite : k4Chain.edgeSet.Infinite :=
  zLift_edgeSet_infinite k4 k4Vol k4Vol_antisymm (show k4.Adj 0 1 by decide)

/-! ## The chain has infinitely many bridges -/

/-- Levels `≤ m` of the chain. -/
def leftLevels (m : ℤ) : Set (ℤ × Fin 4) := {p | p.1 ≤ m}

/-- Apart from the edge `(m,3) — (m+1,0)`, no edge of the chain joins a level `≤ m` to a level
`≥ m+1`. -/
theorem k4Chain_separating (m : ℤ) (a b : ℤ × Fin 4)
    (h : (k4Chain \ SimpleGraph.fromEdgeSet {s((m, 3), (m + 1, 0))}).Adj a b) :
    (a ∈ leftLevels m ↔ b ∈ leftLevels m) := by
  obtain ⟨⟨hadj, hlev⟩, hne⟩ := h
  simp only [leftLevels, Set.mem_setOf_eq]
  by_cases h30 : a.2 = 3 ∧ b.2 = 0
  · have hb : b.1 = a.1 + 1 := by
      rw [hlev, k4Vol, if_pos h30]
    by_cases ha0 : a.1 = m
    · exfalso
      refine hne ?_
      have ha' : a = (m, (3 : Fin 4)) := Prod.ext ha0 h30.1
      have hb' : b = (m + 1, (0 : Fin 4)) := Prod.ext (by rw [hb, ha0]) h30.2
      simp only [SimpleGraph.fromEdgeSet_adj, Set.mem_singleton_iff]
      exact ⟨by rw [ha', hb'], by rw [ha', hb']; simp⟩
    · constructor
      · intro _; omega
      · intro _; omega
  · by_cases h03 : a.2 = 0 ∧ b.2 = 3
    · have hb : b.1 = a.1 - 1 := by
        rw [hlev, k4Vol, if_neg h30, if_pos h03]
        ring
      constructor
      · intro _; omega
      · intro hle
        by_contra hgt
        push_neg at hgt
        have ha1 : a.1 = m + 1 := by omega
        exfalso
        refine hne ?_
        have ha' : a = (m + 1, (0 : Fin 4)) := Prod.ext ha1 h03.1
        have hb' : b = (m, (3 : Fin 4)) := Prod.ext (by rw [hb, ha1]; ring) h03.2
        simp only [SimpleGraph.fromEdgeSet_adj, Set.mem_singleton_iff]
        refine ⟨?_, by rw [ha', hb']; simp⟩
        rw [ha', hb', Sym2.eq_swap]
    · have hb : b.1 = a.1 := by
        rw [hlev, k4Vol, if_neg h30, if_neg h03]
        ring
      rw [hb]

/-- **Every level-crossing edge of the chain is a bridge.** -/
theorem k4Chain_isBridge (m : ℤ) :
    k4Chain.IsBridge s((m, (3 : Fin 4)), (m + 1, (0 : Fin 4))) := by
  rw [SimpleGraph.isBridge_iff]
  refine ⟨⟨show (3 : Fin 4) ≠ (0 : Fin 4) by decide, by simp [k4Vol]⟩, ?_⟩
  refine not_reachable_of_separating (k4Chain_separating m) ?_ ?_
  · show m ≤ m
    exact le_refl _
  · show ¬ (m + 1 ≤ m)
    omega

/-- The chain has infinitely many bridges. -/
theorem k4Chain_bridges_infinite : {e | k4Chain.IsBridge e}.Infinite := by
  apply Set.infinite_of_injective_forall_mem
    (f := fun m : ℤ => s((m, (3 : Fin 4)), (m + 1, (0 : Fin 4))))
  · intro m n hmn
    rcases Sym2.eq_iff.mp hmn with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact congrArg Prod.fst h1
    · exact absurd (congrArg Prod.snd h1) (show (3 : Fin 4) ≠ (0 : Fin 4) by decide)
  · intro m
    exact k4Chain_isBridge m

/-- **Bridgelessness is not necessary in the infinite setting.**  There is an infinite cubic
graph with a bridge satisfying all three properties. -/
theorem exists_bridged_cubic_bergeFulkerson :
    ∃ (V : Type) (G : SimpleGraph V), IsCubic G ∧ ¬ Bridgeless G ∧ G.edgeSet.Infinite ∧
      BergeFulkerson G ∧ FanRaspaud G ∧ MacajovaSkoviera G := by
  refine ⟨ℤ × Fin 4, k4Chain, k4Chain_isCubic, ?_, k4Chain_edgeSet_infinite,
    k4Chain_bergeFulkerson, k4Chain_fanRaspaud, k4Chain_macajovaSkoviera⟩
  intro hbr
  exact hbr _ (k4Chain_isBridge 0).1 (k4Chain_isBridge 0)

end Bridges.InfiniteCubicMatchings