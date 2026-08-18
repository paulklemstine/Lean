import Logic.TriangularForest.Defs

/-!
# Sparsity of triangular forests

The main result of this file is that triangular forests are *sparse*: a triangular forest on
`n ≥ 2` vertices has at most `2n - 3` edges (`TriangularForest.card_edgeFinset_add_three_le`).

The proof runs through a longest-path argument, which is the combinatorial heart of the file:

* `TriangularForest.exists_maxPath` — a finite nonempty graph has a path of maximum length;
* `TriangularForest.degree_le_two_of_maxPath_endpoint` — in a triangular forest the endpoint of
  a maximum length path has degree at most two.  Indeed all its neighbours lie on the path (else
  the path could be extended), and a neighbour sitting at distance `ℓ ≥ 2` along the path closes
  a cycle of length `ℓ + 1`, which must be `3`;
* `TriangularForest.exists_degree_le_two` — hence every finite nonempty triangular forest has a
  vertex of degree at most two (triangular forests are `2`-degenerate);
* the edge bound then follows by induction on the number of vertices, deleting a vertex of
  degree at most two.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V}

/-- If a path from `a` to `x` contains the edge `s(x, a)`, then it is a single edge. -/
theorem length_eq_one_of_mem_edges {a x : V} (q : G.Walk a x) (hq : q.IsPath)
    (h : s(x, a) ∈ q.edges) : q.length = 1 := by
  cases q with
  | nil => simp at h
  | @cons _ c _ hadj q' =>
    rw [Walk.edges_cons, List.mem_cons] at h
    have hq'p : q'.IsPath := hq.of_cons
    rcases h with heq | hmem
    · have hxc : x = c := by
        rw [Sym2.eq_iff] at heq
        rcases heq with ⟨_, ha⟩ | ⟨hx, _⟩
        · exact absurd ha hadj.ne
        · exact hx
      subst hxc
      have hnil : (⟨q', hq'p⟩ : G.Path x x) = SimpleGraph.Path.nil :=
        SimpleGraph.Path.loop_eq _
      have hlen0 : q'.length = 0 := by
        have := congrArg (fun r : G.Path x x => (r : G.Walk x x).length) hnil
        simpa using this
      simp [hlen0]
    · have hain : a ∈ q'.support := Walk.snd_mem_support_of_mem_edges q' hmem
      exact absurd hain ((Walk.cons_isPath_iff hadj q').1 hq).2

/-- A finite nonempty graph has a path of maximum length. -/
theorem exists_maxPath [Fintype V] [Nonempty V] (G : SimpleGraph V) :
    ∃ (a b : V) (p : G.Walk a b), p.IsPath ∧
      ∀ (x y : V) (q : G.Walk x y), q.IsPath → q.length ≤ p.length := by
  classical
  set S : Finset ℕ := {n ∈ Finset.range (Fintype.card V) |
      ∃ (a b : V) (p : G.Walk a b), p.IsPath ∧ p.length = n} with hS
  obtain ⟨v⟩ := ‹Nonempty V›
  have h0 : 0 ∈ S := by
    simp only [hS, Finset.mem_filter, Finset.mem_range]
    exact ⟨Fintype.card_pos, v, v, Walk.nil, Walk.IsPath.nil, rfl⟩
  have hne : S.Nonempty := ⟨0, h0⟩
  obtain ⟨a, b, p, hp, hlen⟩ : ∃ (a b : V) (p : G.Walk a b), p.IsPath ∧ p.length = S.max' hne := by
    have := S.max'_mem hne
    simp only [hS, Finset.mem_filter, Finset.mem_range] at this
    exact this.2
  refine ⟨a, b, p, hp, fun x y q hq => ?_⟩
  have hq' : q.length ∈ S := by
    simp only [hS, Finset.mem_filter, Finset.mem_range]
    exact ⟨hq.length_lt, x, y, q, hq, rfl⟩
  rw [hlen]
  exact S.le_max' _ hq'

section MaxPath

variable [Fintype V] [DecidableEq V] [DecidableRel G.Adj]

/-- Every neighbour of the starting point of a maximum length path lies on that path. -/
theorem maxPath_neighbor_mem_support {a b : V} (p : G.Walk a b) (hp : p.IsPath)
    (hmax : ∀ (x y : V) (q : G.Walk x y), q.IsPath → q.length ≤ p.length)
    {x : V} (hx : x ∈ G.neighborFinset a) : x ∈ p.support := by
  by_contra hnot
  have hadj : G.Adj x a := ((G.mem_neighborFinset a x).1 hx).symm
  have hpath : (Walk.cons hadj p).IsPath := hp.cons hnot
  have := hmax x b (Walk.cons hadj p) hpath
  simp [Walk.length_cons] at this

/-- A neighbour of the starting point of a maximum length path in a triangular forest sits at
position `1` or `2` along the path: further along it would close a cycle of length `≥ 4`. -/
theorem maxPath_neighbor_idx {a b : V} (hG : IsTriangularForest G) (p : G.Walk a b)
    (hp : p.IsPath) (hmax : ∀ (x y : V) (q : G.Walk x y), q.IsPath → q.length ≤ p.length)
    {x : V} (hx : x ∈ G.neighborFinset a) :
    p.support.idxOf x = 1 ∨ p.support.idxOf x = 2 := by
  have hxs : x ∈ p.support := maxPath_neighbor_mem_support p hp hmax hx
  have hadj : G.Adj a x := (G.mem_neighborFinset a x).1 hx
  set q := p.takeUntil x hxs with hq
  have hqp : q.IsPath := hp.takeUntil hxs
  have hqlen : q.length = p.support.idxOf x := p.length_takeUntil hxs
  have hne0 : q.length ≠ 0 := by
    intro h0
    have : q.Nil := Walk.nil_iff_length_eq.2 h0
    exact hadj.ne ((p.nil_takeUntil hxs).1 this)
  have hle2 : q.length ≤ 2 := by
    by_contra hgt
    push_neg at hgt
    have hnotedge : s(x, a) ∉ q.edges := fun hmem' => by
      have := length_eq_one_of_mem_edges q hqp hmem'
      omega
    have hcyc : (Walk.cons hadj.symm q).IsCycle :=
      SimpleGraph.Path.cons_isCycle ⟨q, hqp⟩ hadj.symm hnotedge
    have := hG _ hcyc
    rw [Walk.length_cons] at this
    omega
  rw [← hqlen]
  omega

/-- Positions along a path determine vertices, so distinct neighbours of the starting point of a
maximum length path occupy distinct positions. -/
theorem maxPath_idx_injOn {a b : V} (p : G.Walk a b) (hp : p.IsPath)
    (hmax : ∀ (x y : V) (q : G.Walk x y), q.IsPath → q.length ≤ p.length) :
    Set.InjOn (fun x => p.support.idxOf x) (G.neighborFinset a : Set V) := by
  intro x hx y hy hxy
  have hxs : x ∈ p.support := maxPath_neighbor_mem_support p hp hmax (by simpa using hx)
  have hys : y ∈ p.support := maxPath_neighbor_mem_support p hp hmax (by simpa using hy)
  have hx' := p.getVert_support_idxOf hxs
  have hy' := p.getVert_support_idxOf hys
  simp only at hxy
  rw [← hx', ← hy', hxy]

/-- In a triangular forest, the endpoint of a maximum length path has degree at most two. -/
theorem degree_le_two_of_maxPath_endpoint
    (hG : IsTriangularForest G) {a b : V} (p : G.Walk a b) (hp : p.IsPath)
    (hmax : ∀ (x y : V) (q : G.Walk x y), q.IsPath → q.length ≤ p.length) :
    G.degree a ≤ 2 := by
  classical
  have hmaps : Set.MapsTo (fun x => p.support.idxOf x) (G.neighborFinset a : Set V)
      ((({1, 2} : Finset ℕ) : Set ℕ)) := by
    intro x hx
    have := maxPath_neighbor_idx hG p hp hmax (x := x) (by simpa using hx)
    simpa using this
  have := Finset.card_le_card_of_injOn _ hmaps (maxPath_idx_injOn p hp hmax)
  simpa [card_neighborFinset_eq_degree] using this

end MaxPath

/-- Every finite nonempty triangular forest has a vertex of degree at most two: triangular
forests are 2-degenerate. -/
theorem exists_degree_le_two [Fintype V] [Nonempty V] [DecidableEq V] [DecidableRel G.Adj]
    (hG : IsTriangularForest G) : ∃ v : V, G.degree v ≤ 2 := by
  obtain ⟨a, b, p, hp, hmax⟩ := exists_maxPath G
  exact ⟨a, degree_le_two_of_maxPath_endpoint hG p hp hmax⟩

private theorem sparsity_aux : ∀ n : ℕ, ∀ (V : Type u) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj], Fintype.card V = n → 2 ≤ n →
    IsTriangularForest G → #G.edgeFinset + 3 ≤ 2 * n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro V _ _ G _ hcard hn hG
    rcases eq_or_lt_of_le hn with h2 | h3
    · -- two vertices: at most one edge
      have hch := G.card_edgeFinset_le_card_choose_two
      rw [hcard, ← h2] at hch
      norm_num at hch
      omega
    · -- at least three vertices: delete a vertex of degree at most two
      have : Nonempty V := Fintype.card_pos_iff.1 (by omega)
      obtain ⟨v, hv⟩ := exists_degree_le_two hG
      have hcard' : Fintype.card ({v}ᶜ : Set V) = n - 1 := by
        rw [Fintype.card_compl_set]
        simp [hcard]
      have hedges : #(G.induce ({v}ᶜ : Set V)).edgeFinset = #G.edgeFinset - G.degree v := by
        rw [G.card_edgeFinset_induce_compl_singleton v, G.card_edgeFinset_deleteIncidenceSet v]
      have hdeg : G.degree v ≤ #G.edgeFinset := G.degree_le_card_edgeFinset v
      have hIH := ih (n - 1) (by omega) ({v}ᶜ : Set V) (G.induce ({v}ᶜ : Set V)) hcard'
        (by omega) (hG.induce _)
      rw [hedges] at hIH
      omega

/-- **Sparsity of triangular forests.** A triangular forest on `n ≥ 2` vertices has at most
`2n - 3` edges. -/
theorem card_edgeFinset_add_three_le {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (hG : IsTriangularForest G) (hcard : 2 ≤ Fintype.card V) :
    #G.edgeFinset + 3 ≤ 2 * Fintype.card V :=
  sparsity_aux (Fintype.card V) V G rfl hcard hG

end TriangularForest