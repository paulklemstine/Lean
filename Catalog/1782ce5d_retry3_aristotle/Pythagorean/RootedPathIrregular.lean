import Mathlib.Combinatorics.SimpleGraph.Finite

/-!
# Rooted three-vertex paths

For a finite simple graph, the number of copies of the three-vertex path in which
`v` is the central (rooted) vertex is `choose (degree v) 2`: one chooses the two
neighbours of `v`. This file formalizes the paper's obstruction: no graph with
at least two vertices can have pairwise-distinct such rooted counts.
-/

namespace RootedPathIrregular

open SimpleGraph

variable {V : Type*} [Fintype V]

/-- The number of rooted copies of `P₃` having `v` as their central vertex. -/
def centralP3Count (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : ℕ :=
  Nat.choose (G.degree v) 2

/-- A finite simple graph on at least two vertices cannot have an injective degree map. -/
theorem not_injective_degree (G : SimpleGraph V) [DecidableRel G.Adj]
    (hcard : 2 ≤ Fintype.card V) : ¬ Function.Injective (fun v => G.degree v) := by
  intro h_inj
  -- All degrees are distinct, so they realize every value from 0 to N-1
  have h_bound : ∀ v, G.degree v < Fintype.card V := fun v => by
    rw [SimpleGraph.degree]
    apply Finset.card_lt_card
    rw [Finset.ssubset_iff_subset_ne]
    constructor
    · exact Finset.subset_univ _
    · intro h
      have := G.loopless.irrefl v
      have hv : v ∈ G.neighborFinset v := (h ▸ Finset.mem_univ v)
      rw [SimpleGraph.mem_neighborFinset] at hv
      exact this hv
  have h_image : Finset.image (fun v => G.degree v) Finset.univ = Finset.range (Fintype.card V) := by
    apply Finset.eq_of_subset_of_card_le
    · exact Finset.image_subset_iff.mpr fun v _ => Finset.mem_range.mpr (h_bound v)
    · rw [Finset.card_image_of_injective _ h_inj, Finset.card_univ, Finset.card_range]
  -- There exist vertices of degree 0 and degree N-1
  have h0 : 0 ∈ Finset.range (Fintype.card V) := Finset.mem_range.mpr (by omega)
  have hN : Fintype.card V - 1 ∈ Finset.range (Fintype.card V) :=
    Finset.mem_range.mpr (Nat.sub_lt (by omega) (by omega))
  obtain ⟨v0, _, hv0⟩ := Finset.mem_image.mp (h_image.symm ▸ h0)
  obtain ⟨vN, _, hvN⟩ := Finset.mem_image.mp (h_image.symm ▸ hN)
  -- If v0 = vN, then 0 = N - 1, contradiction since N ≥ 2
  by_cases hv : v0 = vN
  · subst hv; rw [hv0] at hvN; omega
  · -- vN is adjacent to v0 since vN has degree N - 1
    haveI : DecidableEq V := Classical.decEq V
    have h_adj_vN : G.Adj vN v0 := by
      by_contra h_not_adj
      have h_not_neighbor : v0 ∉ G.neighborFinset vN := by
        simp [SimpleGraph.mem_neighborFinset, h_not_adj]
      -- The neighbor set doesn't contain vN (loopless) or v0
      have h_sub : G.neighborFinset vN ⊆ Finset.univ.filter (fun w => w ≠ vN ∧ w ≠ v0) := by
        intro w hw
        simp [SimpleGraph.mem_neighborFinset] at hw
        simp
        refine ⟨?_, ?_⟩
        · intro heq
          rw [heq] at hw
          exact G.loopless.irrefl vN hw
        · intro heq
          rw [heq] at hw
          exact h_not_neighbor (by simp [SimpleGraph.mem_neighborFinset, hw])
      -- The filter set excludes vN and v0, so has at most card V - 2 elements
      have h_card_vN : (G.neighborFinset vN).card = Fintype.card V - 1 := hvN
      have h_card_le : (G.neighborFinset vN).card ≤ (Finset.univ.filter (fun w => w ≠ vN ∧ w ≠ v0)).card :=
        Finset.card_le_card h_sub
      -- The filter set is a subset of (univ \ {vN}) and excludes v0, so has at most card V - 2
      -- The neighbor set is contained in univ \ {vN, v0} which has N-2 elements
      -- But it has N-1 elements, contradiction
      have h_excl : {vN, v0} ⊆ Finset.univ := Finset.subset_univ _
      have h_excl' : Finset.univ ⊇ {vN, v0} := h_excl
      have h_card_excl : ({vN, v0} : Finset V).card = 2 := by
        rw [Finset.card_insert_of_notMem] <;> simp [ne_comm.mp hv]
      have h_not_sub : ¬(G.neighborFinset vN ⊆ Finset.univ \ {vN, v0}) := by
        intro h
        have : (G.neighborFinset vN).card ≤ (Finset.univ \ {vN, v0}).card := Finset.card_le_card h
        rw [Finset.card_sdiff, Finset.card_univ, Finset.inter_univ, h_card_excl] at this
        omega
      apply h_not_sub
      intro w hw
      simp [SimpleGraph.mem_neighborFinset] at hw
      simp [Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
      constructor
      · intro heq; rw [heq] at hw; exact G.loopless.irrefl vN hw
      · intro heq; rw [heq] at hw; exact h_not_neighbor (by simp [SimpleGraph.mem_neighborFinset, hw])
    -- But v0 has degree 0, so not adjacent to anyone
    have h_deg0 : G.neighborFinset v0 = ∅ := by
      rw [SimpleGraph.degree] at hv0
      exact Finset.card_eq_zero.mp hv0
    have hvN_mem : vN ∈ G.neighborFinset v0 := by
      rw [SimpleGraph.mem_neighborFinset]
      exact (G.adj_comm vN v0).mp h_adj_vN
    rw [h_deg0] at hvN_mem
    cases hvN_mem

/-- Central-rooted `P₃` irregularity would force all vertex degrees to differ. -/
theorem injective_degree_of_injective_centralP3Count (G : SimpleGraph V)
    [DecidableRel G.Adj] (h : Function.Injective (centralP3Count G)) :
    Function.Injective (fun v => G.degree v) := by
  intro v w hd
  apply h
  simp only [centralP3Count, hd]

/-- The central-root obstruction for `P₃`: every finite simple graph with at
least two vertices has two distinct vertices belonging to the same number of
central-rooted copies of `P₃`. -/
theorem exists_distinct_equal_centralP3Count (G : SimpleGraph V) [DecidableRel G.Adj]
    (hcard : 2 ≤ Fintype.card V) :
    ∃ v w : V, v ≠ w ∧ centralP3Count G v = centralP3Count G w := by
  by_contra h_not
  push_neg at h_not
  have h_inj : Function.Injective (centralP3Count G) := by
    intro v w hvw
    by_contra hvw'
    exact h_not v w hvw' hvw
  have h_deg_inj := injective_degree_of_injective_centralP3Count G h_inj
  exact not_injective_degree G hcard h_deg_inj

/-- Equivalently, injectivity of the central-rooted `P₃` count forces the graph
to have at most one vertex. -/
theorem card_le_one_of_injective_centralP3Count (G : SimpleGraph V)
    [DecidableRel G.Adj] (h : Function.Injective (centralP3Count G)) :
    Fintype.card V ≤ 1 := by
  by_contra h_not_le
  push_neg at h_not_le
  exact not_injective_degree G h_not_le (injective_degree_of_injective_centralP3Count G h)

end RootedPathIrregular