import Mathlib
import MachineLearning.SemitotalDomination.Defs

/-!
# The BFS-layered greedy maximal independent set

This file formalizes the combinatorial engine of the algorithm of the paper
*Semitotal domination in unit disk graphs*: the algorithm scans the vertices in
Breadth-First-Search order and greedily builds a maximal independent set `S`.

The point of the BFS order is the following (the `MIS` alone is *not* enough: in the path
`P₇` the maximal independent set `{0,3,6}` violates the semitotal condition):

> **Theorem** (`greedyMIS_isSemitotalSet`).  If `G` is connected and the greedy BFS maximal
> independent set rooted at `r` is not the singleton `{r}`, then it is a *semitotal*
> dominating set.

The proof is a "parent" argument: if `v ∈ S` lies in BFS layer `d ≥ 1`, its parent `u` in layer
`d - 1` is not in `S`, hence at the moment `u` was scanned it already had a neighbour `s ∈ S`;
that `s` lies in an earlier layer, so `s ≠ v` and `dist(v, s) ≤ 2`.  The root is handled by
looking at layer `2`.
-/

namespace SemitotalDomination

open Finset

variable {V : Type*} [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-! ### The greedy scan -/

/-- Greedy independent set construction: scan the list, adding a vertex to the current set
whenever it has no neighbour in it. -/
def greedyFrom (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : List V → Finset V
  | [] => S
  | v :: t => greedyFrom G (if ∃ s ∈ S, G.Adj s v then S else insert v S) t

@[simp] lemma greedyFrom_nil (S : Finset V) : greedyFrom G S [] = S := rfl

lemma greedyFrom_cons (S : Finset V) (v : V) (t : List V) :
    greedyFrom G S (v :: t) = greedyFrom G (if ∃ s ∈ S, G.Adj s v then S else insert v S) t := rfl

lemma greedyFrom_append (S : Finset V) (l₁ l₂ : List V) :
    greedyFrom G S (l₁ ++ l₂) = greedyFrom G (greedyFrom G S l₁) l₂ := by
  induction l₁ generalizing S with
  | nil => rfl
  | cons a t ih => simp only [List.cons_append, greedyFrom_cons, ih]

lemma subset_greedyFrom (S : Finset V) (l : List V) : S ⊆ greedyFrom G S l := by
  induction l generalizing S with
  | nil => exact subset_rfl
  | cons a t ih =>
    rw [greedyFrom_cons]
    by_cases hP : ∃ s ∈ S, G.Adj s a
    · rw [if_pos hP]; exact ih S
    · rw [if_neg hP]; exact (Finset.subset_insert a S).trans (ih _)

lemma greedyFrom_mem (S : Finset V) (l : List V) {x : V} (hx : x ∈ greedyFrom G S l) :
    x ∈ S ∨ x ∈ l := by
  induction l generalizing S with
  | nil => exact Or.inl hx
  | cons a t ih =>
    rw [greedyFrom_cons] at hx
    by_cases hP : ∃ s ∈ S, G.Adj s a
    · rw [if_pos hP] at hx
      rcases ih S hx with h | h
      · exact Or.inl h
      · exact Or.inr (List.mem_cons_of_mem _ h)
    · rw [if_neg hP] at hx
      rcases ih _ hx with h | h
      · rcases Finset.mem_insert.mp h with rfl | h
        · exact Or.inr (List.mem_cons_self)
        · exact Or.inl h
      · exact Or.inr (List.mem_cons_of_mem _ h)

/-- The greedy scan preserves independence. -/
lemma greedyFrom_indep (S : Finset V) (l : List V)
    (hS : ∀ a ∈ S, ∀ b ∈ S, ¬ G.Adj a b) :
    ∀ a ∈ greedyFrom G S l, ∀ b ∈ greedyFrom G S l, ¬ G.Adj a b := by
  induction l generalizing S with
  | nil => exact hS
  | cons v t ih =>
    rw [greedyFrom_cons]
    by_cases hP : ∃ s ∈ S, G.Adj s v
    · rw [if_pos hP]; exact ih S hS
    · rw [if_neg hP]
      refine ih _ ?_
      intro a ha b hb hab
      rcases Finset.mem_insert.mp ha with rfl | ha' <;>
        rcases Finset.mem_insert.mp hb with rfl | hb'
      · exact G.irrefl hab
      · exact hP ⟨b, hb', hab.symm⟩
      · exact hP ⟨a, ha', hab⟩
      · exact hS a ha' b hb' hab

/-- Basic dichotomy at the moment a vertex is scanned: either it enters the set, or it already
had a neighbour in the set built so far. -/
lemma greedyFrom_dichotomy (S : Finset V) (v : V) (t : List V) :
    v ∈ greedyFrom G S (v :: t) ∨ ∃ s ∈ S, G.Adj s v := by
  by_cases hP : ∃ s ∈ S, G.Adj s v
  · exact Or.inr hP
  · refine Or.inl ?_
    rw [greedyFrom_cons, if_neg hP]
    exact subset_greedyFrom _ _ (Finset.mem_insert_self v S)

/-- **Key scan lemma.**  For a vertex `v` occurring in the list, either `v` belongs to the final
greedy set, or some *earlier* vertex `s` of the list, itself in the final greedy set, is
adjacent to `v`. -/
theorem greedyFrom_prefix_witness (l₁ : List V) (v : V) (l₂ : List V) :
    v ∈ greedyFrom G ∅ (l₁ ++ v :: l₂) ∨
      ∃ s, s ∈ l₁ ∧ s ∈ greedyFrom G ∅ (l₁ ++ v :: l₂) ∧ G.Adj s v := by
  have hsplit : greedyFrom G ∅ (l₁ ++ v :: l₂)
      = greedyFrom G (greedyFrom G ∅ l₁) (v :: l₂) := greedyFrom_append _ _ _
  rcases greedyFrom_dichotomy (G := G) (greedyFrom G ∅ l₁) v l₂ with h | ⟨s, hs, hadj⟩
  · exact Or.inl (hsplit ▸ h)
  · refine Or.inr ⟨s, ?_, ?_, hadj⟩
    · rcases greedyFrom_mem ∅ l₁ hs with h | h
      · simp at h
      · exact h
    · rw [hsplit]
      exact subset_greedyFrom _ _ hs

/-! ### The BFS order -/

variable [Fintype V]

/-- All vertices, listed in order of increasing distance from the root `r` (a BFS order). -/
noncomputable def bfsOrder (G : SimpleGraph V) (r : V) : List V :=
  (Finset.univ.toList).mergeSort (fun a b => decide (G.dist r a ≤ G.dist r b))

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma mem_bfsOrder (r x : V) : x ∈ bfsOrder G r := by
  rw [bfsOrder, (List.mergeSort_perm _ _).mem_iff]
  simp

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma bfsOrder_sorted (r : V) :
    (bfsOrder G r).Pairwise (fun a b => G.dist r a ≤ G.dist r b) := by
  have := List.pairwise_mergeSort (le := fun a b => decide (G.dist r a ≤ G.dist r b))
    (fun a b c hab hbc => by simp_all; omega) (fun a b => by simp; omega)
    (Finset.univ.toList (α := V))
  simpa [bfsOrder] using this

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- In a BFS order, vertices occurring before `u` are not farther from the root than `u`. -/
lemma dist_le_of_mem_prefix {r u s : V} {l₁ l₂ : List V}
    (hl : bfsOrder G r = l₁ ++ u :: l₂) (hs : s ∈ l₁) : G.dist r s ≤ G.dist r u := by
  have hp := bfsOrder_sorted (G := G) r
  rw [hl] at hp
  exact (List.pairwise_append.mp hp).2.2 s hs u List.mem_cons_self

/-! ### The greedy BFS maximal independent set -/

/-- The maximal independent set produced by greedily scanning the vertices in BFS order. -/
noncomputable def greedyMIS (G : SimpleGraph V) [DecidableRel G.Adj] (r : V) : Finset V :=
  greedyFrom G ∅ (bfsOrder G r)

/-- The greedy set is independent. -/
theorem greedyMIS_indep (r : V) :
    ∀ a ∈ greedyMIS G r, ∀ b ∈ greedyMIS G r, ¬ G.Adj a b :=
  greedyFrom_indep ∅ _ (by simp)

/-- Every vertex is in the greedy set or has a neighbour in it that is scanned no later
than itself. -/
theorem greedyMIS_witness (r v : V) :
    v ∈ greedyMIS G r ∨ ∃ s, s ∈ greedyMIS G r ∧ G.Adj s v ∧ G.dist r s ≤ G.dist r v := by
  obtain ⟨l₁, l₂, hl⟩ := List.append_of_mem (mem_bfsOrder (G := G) r v)
  rcases greedyFrom_prefix_witness (G := G) l₁ v l₂ with h | ⟨s, hs₁, hs₂, hadj⟩
  · exact Or.inl (by rw [greedyMIS, hl]; exact h)
  · exact Or.inr ⟨s, by rw [greedyMIS, hl]; exact hs₂, hadj,
      dist_le_of_mem_prefix (G := G) hl hs₁⟩

/-- The greedy set is a dominating set (i.e. the independent set is maximal). -/
theorem greedyMIS_isDominatingSet (r : V) : IsDominatingSet G (greedyMIS G r) := by
  intro v
  rcases greedyMIS_witness (G := G) r v with h | ⟨s, hs, hadj, -⟩
  · exact Or.inl h
  · exact Or.inr ⟨s, hs, hadj⟩

/-! ### BFS layers -/

omit [DecidableEq V] [DecidableRel G.Adj] [Fintype V] in
/-- Every vertex at positive distance from the root has a parent one layer closer. -/
theorem exists_parent (hconn : G.Connected) {r v : V} (h : 0 < G.dist r v) :
    ∃ u, G.Adj u v ∧ G.dist r u + 1 = G.dist r v := by
  obtain ⟨p, hp⟩ := (hconn.preconnected r v).exists_walk_length_eq_dist
  have hne : v ≠ r := by
    rintro rfl
    simp at h
  obtain ⟨u, hadj, q, hq⟩ := SimpleGraph.Walk.exists_eq_cons_of_ne hne p.reverse
  have hlen : q.length + 1 = G.dist r v := by
    have : p.reverse.length = q.length + 1 := by rw [hq]; simp
    rw [SimpleGraph.Walk.length_reverse, hp] at this
    omega
  have h1 : G.dist r u ≤ q.length := by simpa using SimpleGraph.dist_le q.reverse
  have h2 : G.dist r v ≤ G.dist r u + G.dist u v := hconn.dist_triangle
  have h3 : G.dist u v = 1 := SimpleGraph.dist_eq_one_iff_adj.mpr hadj.symm
  exact ⟨u, hadj.symm, by omega⟩

omit [DecidableEq V] [DecidableRel G.Adj] [Fintype V] in
/-- If some vertex is at distance at least `2` from the root, then some vertex is at distance
exactly `2`. -/
theorem exists_dist_eq_two (hconn : G.Connected) {r x : V} (hx : 2 ≤ G.dist r x) :
    ∃ w, G.dist r w = 2 := by
  generalize hn : G.dist r x = n at hx
  induction n using Nat.strong_induction_on generalizing x with
  | _ n ih =>
    rcases eq_or_lt_of_le hx with h | h
    · exact ⟨x, by omega⟩
    · obtain ⟨u, -, hu⟩ := exists_parent hconn (r := r) (v := x) (by omega)
      exact ih (n - 1) (by omega) (x := u) (by omega) (by omega)

omit [DecidableEq V] [DecidableRel G.Adj] [Fintype V] in
/-- If no vertex is at distance `2` from `r`, every other vertex is a neighbour of `r`. -/
theorem adj_root_of_no_layer_two (hconn : G.Connected) {r : V} (h : ∀ w, G.dist r w ≠ 2)
    {x : V} (hx : x ≠ r) : G.Adj r x := by
  have hpos : G.dist r x ≠ 0 := fun h0 => hx ((hconn.dist_eq_zero_iff.mp h0).symm)
  have : G.dist r x = 1 := by
    by_contra hne
    exact absurd (exists_dist_eq_two hconn (r := r) (x := x) (by omega)) (by simpa using h)
  exact SimpleGraph.dist_eq_one_iff_adj.mp this

/-! ### The semitotal property of the greedy BFS set -/

/-- **Main structural theorem.**  In a connected graph, the greedy BFS maximal independent set
rooted at `r` satisfies the semitotal condition, unless it is the singleton `{r}`. -/
theorem greedyMIS_isSemitotalSet (hconn : G.Connected) (r : V)
    (hne : greedyMIS G r ≠ {r}) : IsSemitotalSet G (greedyMIS G r) := by
  intro v hv
  rcases Nat.eq_zero_or_pos (G.dist r v) with hd | hd
  · -- `v` is the root
    have hvr : v = r := ((hconn.dist_eq_zero_iff).mp hd).symm
    subst hvr
    -- there must be a vertex at distance exactly 2, otherwise the greedy set is `{v}`
    have hlayer : ∃ w, G.dist v w = 2 := by
      by_contra hno
      push_neg at hno
      refine hne (Finset.eq_singleton_iff_unique_mem.mpr ⟨hv, ?_⟩)
      intro x hx
      by_contra hxv
      exact greedyMIS_indep (G := G) v v hv x hx (adj_root_of_no_layer_two hconn hno hxv)
    obtain ⟨w, hw⟩ := hlayer
    rcases greedyMIS_witness (G := G) v w with h | ⟨s, hs, hadj, hdist⟩
    · refine ⟨w, h, ?_, ?_⟩
      · rintro rfl; simp at hw
      · exact ((within2_iff_dist_le_two (hconn.preconnected w v)).mpr
          (by rw [SimpleGraph.dist_comm]; omega))
    · refine ⟨s, hs, ?_, ?_⟩
      · rintro rfl
        rw [SimpleGraph.dist_eq_one_iff_adj.mpr hadj] at hw
        omega
      · exact ((within2_iff_dist_le_two (hconn.preconnected s v)).mpr
          (by rw [SimpleGraph.dist_comm]; omega))
  · -- `v` is in some layer `d ≥ 1`; use its parent
    obtain ⟨u, hadj, hu⟩ := exists_parent hconn hd
    have huS : u ∉ greedyMIS G r := fun hmem =>
      greedyMIS_indep (G := G) r u hmem v hv hadj
    rcases greedyMIS_witness (G := G) r u with h | ⟨s, hs, hsu, hdist⟩
    · exact absurd h huS
    · refine ⟨s, hs, ?_, Within2.of_adj_adj hsu hadj⟩
      rintro rfl
      omega

/-- The greedy BFS set is a semitotal dominating set, unless it is the singleton `{r}`. -/
theorem greedyMIS_isSemitotalDominatingSet (hconn : G.Connected) (r : V)
    (hne : greedyMIS G r ≠ {r}) : IsSemitotalDominatingSet G (greedyMIS G r) :=
  ⟨greedyMIS_isDominatingSet r, greedyMIS_isSemitotalSet hconn r hne⟩

end SemitotalDomination