/-
# A concrete infinite cubic bridgeless graph satisfying all three conjectures

The doubly infinite ladder `L` on the vertex set `ℤ × Bool` (rungs `(n,b) — (n,¬b)` and rails
`(n,b) — (n+1,b)`) is an infinite, cubic, bridgeless graph.  We verify all of this formally
and exhibit an explicit proper 3-edge-colouring, which by
`ProperThreeEdgeColoring.bergeFulkerson` yields the Berge–Fulkerson property, hence also the
Fan–Raspaud and Máčajová–Škoviera properties.

This shows that the framework of `Bridges.InfiniteCubicMatchings` is not vacuous: it is
satisfied by a genuinely infinite cubic bridgeless graph.
-/
import Bridges.InfiniteCubicMatchings

namespace Bridges.InfiniteCubicMatchings

namespace Ladder

/-- The doubly infinite ladder graph on `ℤ × Bool`. -/
def ladder : SimpleGraph (ℤ × Bool) where
  Adj p q := (p.1 = q.1 ∧ p.2 ≠ q.2) ∨ (p.2 = q.2 ∧ (q.1 = p.1 + 1 ∨ p.1 = q.1 + 1))
  symm := by
    rintro ⟨n, b⟩ ⟨m, c⟩ (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact Or.inl ⟨h1.symm, h2.symm⟩
    · exact Or.inr ⟨h1.symm, h2.symm⟩
  loopless := ⟨by
    rintro ⟨n, b⟩ (⟨-, h⟩ | ⟨-, h | h⟩)
    · exact h rfl
    · omega
    · omega⟩

lemma adj_rung (n : ℤ) (b : Bool) : ladder.Adj (n, b) (n, !b) := by
  refine Or.inl ⟨rfl, ?_⟩
  cases b <;> simp

lemma adj_rail (n : ℤ) (b : Bool) : ladder.Adj (n, b) (n + 1, b) := Or.inr ⟨rfl, Or.inl rfl⟩

/-! ## Three perfect matchings forming a proper 3-edge-colouring -/

/-- The matching consisting of all rungs. -/
def rung : PerfectMatching ladder where
  partner p := (p.1, !p.2)
  isAdj p := adj_rung p.1 p.2
  invol p := by simp

/-- The matching consisting of the rails leaving even columns to the right. -/
def evenRail : PerfectMatching ladder where
  partner p := if p.1 % 2 = 0 then (p.1 + 1, p.2) else (p.1 - 1, p.2)
  isAdj p := by
    by_cases h : p.1 % 2 = 0
    · simpa [h] using adj_rail p.1 p.2
    · simpa [h] using (adj_rail (p.1 - 1) p.2).symm
  invol p := by
    by_cases h : p.1 % 2 = 0
    · rw [if_pos h, if_neg (by simp; omega)]
      simp
    · rw [if_neg h, if_pos (by simp; omega)]
      simp

/-- The matching consisting of the rails leaving odd columns to the right. -/
def oddRail : PerfectMatching ladder where
  partner p := if p.1 % 2 = 0 then (p.1 - 1, p.2) else (p.1 + 1, p.2)
  isAdj p := by
    by_cases h : p.1 % 2 = 0
    · simpa [h] using (adj_rail (p.1 - 1) p.2).symm
    · simpa [h] using adj_rail p.1 p.2
  invol p := by
    by_cases h : p.1 % 2 = 0
    · rw [if_pos h, if_neg (by simp; omega)]
      simp
    · rw [if_neg h, if_pos (by simp; omega)]
      simp

lemma disjoint_rung_evenRail : Disjoint rung.edges evenRail.edges := by
  refine PerfectMatching.disjoint_edges _ _ fun p => ?_
  show (p.1, !p.2) ≠ (if p.1 % 2 = 0 then (p.1 + 1, p.2) else (p.1 - 1, p.2))
  split <;> simp

lemma disjoint_rung_oddRail : Disjoint rung.edges oddRail.edges := by
  refine PerfectMatching.disjoint_edges _ _ fun p => ?_
  show (p.1, !p.2) ≠ (if p.1 % 2 = 0 then (p.1 - 1, p.2) else (p.1 + 1, p.2))
  split <;> simp

lemma disjoint_evenRail_oddRail : Disjoint evenRail.edges oddRail.edges := by
  refine PerfectMatching.disjoint_edges _ _ fun p => ?_
  show (if p.1 % 2 = 0 then (p.1 + 1, p.2) else (p.1 - 1, p.2))
      ≠ (if p.1 % 2 = 0 then (p.1 - 1, p.2) else (p.1 + 1, p.2))
  by_cases h : p.1 % 2 = 0
  · rw [if_pos h, if_pos h]
    intro hEq
    have h' : p.1 + 1 = p.1 - 1 := congrArg Prod.fst hEq
    omega
  · rw [if_neg h, if_neg h]
    intro hEq
    have h' : p.1 - 1 = p.1 + 1 := congrArg Prod.fst hEq
    omega

/-- The explicit proper 3-edge-colouring of the infinite ladder. -/
theorem ladder_properThreeEdgeColoring : ProperThreeEdgeColoring ladder := by
  refine ⟨![rung, evenRail, oddRail], ?_, ?_⟩
  · intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all <;>
      first
        | exact disjoint_rung_evenRail
        | exact disjoint_rung_oddRail
        | exact disjoint_evenRail_oddRail
        | exact disjoint_rung_evenRail.symm
        | exact disjoint_rung_oddRail.symm
        | exact disjoint_evenRail_oddRail.symm
  · intro e
    induction e with
    | _ p q =>
      rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
      · refine ⟨0, ?_⟩
        simp only [Matrix.cons_val_zero, PerfectMatching.mem_edges]
        show (p.1, !p.2) = q
        obtain ⟨n, b⟩ := p
        obtain ⟨m, c⟩ := q
        simp only at h1 h2 ⊢
        subst h1
        cases b <;> cases c <;> simp_all
      · rcases h2 with h2 | h2
        · by_cases hpar : p.1 % 2 = 0
          · refine ⟨1, ?_⟩
            simp only [Matrix.cons_val_one, PerfectMatching.mem_edges]
            show (if p.1 % 2 = 0 then (p.1 + 1, p.2) else (p.1 - 1, p.2)) = q
            rw [if_pos hpar]
            exact Prod.ext h2.symm h1
          · refine ⟨2, ?_⟩
            simp only [Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons,
              PerfectMatching.mem_edges]
            show (if p.1 % 2 = 0 then (p.1 - 1, p.2) else (p.1 + 1, p.2)) = q
            rw [if_neg hpar]
            exact Prod.ext h2.symm h1
        · by_cases hpar : p.1 % 2 = 0
          · refine ⟨2, ?_⟩
            simp only [Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons,
              PerfectMatching.mem_edges]
            show (if p.1 % 2 = 0 then (p.1 - 1, p.2) else (p.1 + 1, p.2)) = q
            rw [if_pos hpar]
            refine Prod.ext ?_ h1
            show p.1 - 1 = q.1
            have h2' : p.1 = q.1 + 1 := h2
            omega
          · refine ⟨1, ?_⟩
            simp only [Matrix.cons_val_one, PerfectMatching.mem_edges]
            show (if p.1 % 2 = 0 then (p.1 + 1, p.2) else (p.1 - 1, p.2)) = q
            rw [if_neg hpar]
            refine Prod.ext ?_ h1
            show p.1 - 1 = q.1
            have h2' : p.1 = q.1 + 1 := h2
            omega

/-- The infinite ladder satisfies the Berge–Fulkerson property. -/
theorem ladder_bergeFulkerson : BergeFulkerson ladder :=
  ladder_properThreeEdgeColoring.bergeFulkerson

/-- The infinite ladder satisfies the Fan–Raspaud property. -/
theorem ladder_fanRaspaud : FanRaspaud ladder := ladder_bergeFulkerson.fanRaspaud

/-- The infinite ladder satisfies the Máčajová–Škoviera property. -/
theorem ladder_macajovaSkoviera : MacajovaSkoviera ladder :=
  ladder_bergeFulkerson.macajovaSkoviera

/-! ## The ladder is an infinite, cubic, bridgeless graph -/

theorem ladder_neighborSet (p : ℤ × Bool) :
    ladder.neighborSet p = {(p.1, !p.2), (p.1 + 1, p.2), (p.1 - 1, p.2)} := by
  obtain ⟨n, b⟩ := p
  ext ⟨m, c⟩
  simp only [SimpleGraph.mem_neighborSet, Set.mem_insert_iff, Set.mem_singleton_iff,
    Prod.mk.injEq]
  constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact Or.inl ⟨h1.symm, by cases b <;> cases c <;> simp_all⟩
    · rcases h2 with h2 | h2
      · exact Or.inr (Or.inl ⟨by simp only at h2; omega, h1.symm⟩)
      · exact Or.inr (Or.inr ⟨by simp only at h2; omega, h1.symm⟩)
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact Or.inl ⟨rfl, by cases b <;> simp⟩
    · exact Or.inr ⟨rfl, Or.inl rfl⟩
    · exact Or.inr ⟨rfl, Or.inr (by omega)⟩

theorem ladder_isCubic : IsCubic ladder := by
  intro p
  rw [ladder_neighborSet]
  rw [Set.ncard_insert_of_notMem (by simp) (Set.toFinite _),
    Set.ncard_pair (by
      intro hEq
      have : p.1 + 1 = p.1 - 1 := congrArg Prod.fst hEq
      omega)]

lemma not_isBridge_of_walk {p q : ℤ × Bool} (w : ladder.Walk p q) (hw : s(p, q) ∉ w.edges) :
    ¬ ladder.IsBridge s(p, q) := by
  rw [SimpleGraph.isBridge_iff]
  rintro ⟨-, hnr⟩
  exact hnr (SimpleGraph.reachable_delete_edges_iff_exists_walk.mpr ⟨w, hw⟩)

/-- Every rung lies on a 4-cycle, hence is not a bridge. -/
lemma not_isBridge_rung (n : ℤ) (b : Bool) : ¬ ladder.IsBridge s((n, b), (n, !b)) := by
  refine not_isBridge_of_walk (SimpleGraph.Walk.cons (adj_rail n b)
    (SimpleGraph.Walk.cons (adj_rung (n + 1) b)
      (SimpleGraph.Walk.cons (by simpa using (adj_rail n (!b)).symm)
        SimpleGraph.Walk.nil))) ?_
  simp only [SimpleGraph.Walk.edges_cons, SimpleGraph.Walk.edges_nil, List.mem_cons,
    List.not_mem_nil, or_false, Sym2.eq_iff, Prod.mk.injEq]
  push_neg
  refine ⟨?_, ?_, ?_⟩ <;> constructor <;> intro h <;> simp_all

/-- Every rail lies on a 4-cycle, hence is not a bridge. -/
lemma not_isBridge_rail (n : ℤ) (b : Bool) : ¬ ladder.IsBridge s((n, b), (n + 1, b)) := by
  refine not_isBridge_of_walk (SimpleGraph.Walk.cons (adj_rung n b)
    (SimpleGraph.Walk.cons (adj_rail n (!b))
      (SimpleGraph.Walk.cons (by simpa using adj_rung (n + 1) (!b))
        SimpleGraph.Walk.nil))) ?_
  simp only [SimpleGraph.Walk.edges_cons, SimpleGraph.Walk.edges_nil, List.mem_cons,
    List.not_mem_nil, or_false, Sym2.eq_iff, Prod.mk.injEq]
  push_neg
  refine ⟨?_, ?_, ?_⟩ <;> constructor <;> intro h <;> simp_all

theorem ladder_bridgeless : Bridgeless ladder := by
  intro e
  induction e with
  | _ p q =>
    intro he
    obtain ⟨n, b⟩ := p
    obtain ⟨m, c⟩ := q
    rcases he with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · simp only at h1 h2
      subst h1
      have : c = !b := by cases b <;> cases c <;> simp_all
      subst this
      exact not_isBridge_rung n b
    · simp only at h1 h2
      subst h1
      rcases h2 with h2 | h2
      · subst h2
        exact not_isBridge_rail n b
      · have hn : n = m + 1 := h2
        subst hn
        rw [Sym2.eq_swap]
        exact not_isBridge_rail m b

/-- The ladder has infinitely many vertices. -/
theorem ladder_infinite : Infinite (ℤ × Bool) := inferInstance

/-- Since the ladder satisfies Berge–Fulkerson, it has no one-edge odd cut. -/
theorem ladder_no_oddCut_singleton (e : Sym2 (ℤ × Bool)) : ¬ IsOddCut ladder {e} := fun h =>
  not_bergeFulkerson_of_oddCut_singleton h ladder_bergeFulkerson

end Ladder

end Bridges.InfiniteCubicMatchings