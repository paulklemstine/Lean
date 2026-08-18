import Logic.TriangularForest.Decomposition

/-!
# The sharp sparsity bound for triangular forests

A connected triangular forest on `n` vertices with `t` triangular blocks has `n - 1 + t` edges
and `2t ≤ n - 1`, so `2e ≤ 3(n-1)`.  Here we prove this sharp bound
(`TriangularForest.two_mul_card_edgeFinset_le`) without developing block decompositions, by
refining the longest-path argument of `Logic.TriangularForest.Sparsity`:

* `TriangularForest.degree_second_le_two` — if `p = a → v₁ → v₂ → ⋯` is a longest path in a
  triangular forest and `a` is also adjacent to `v₂` (which happens as soon as `a` has degree
  two), then the *second* vertex `v₁` also has degree at most two.  Neighbours of `v₁` off the
  path would allow the reroute `y → v₁ → a → v₂ → ⋯`, which is longer; neighbours further along
  the path close a cycle of length `≥ 4`, except for the vertex `v₃`, which is excluded by the
  4-cycle `a → v₁ → v₃ → v₂ → a`.
* `TriangularForest.exists_adj_degree_le_two` — hence a triangular forest of minimum degree at
  least two contains an *edge* both of whose endpoints have degree two (a leaf triangle).
* Deleting such a pair removes two vertices and exactly three edges, which powers the induction
  giving `2e ≤ 3(n-1)`.

As a consequence `Kₙ` fails to decompose into two triangular forests already for `n ≥ 6`, which
combined with `TriangularForest.completeGraph_decomposesIntoTwo_five` pins the threshold
exactly: `Kₙ` decomposes into two triangular forests if and only if `n ≤ 5`.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V}

/-- A walk of length at least two starts with two `cons`. -/
theorem exists_cons_cons_of_two_le_length {a b : V} (p : G.Walk a b) (h : 2 ≤ p.length) :
    ∃ (v₁ v₂ : V) (h₀₁ : G.Adj a v₁) (h₁₂ : G.Adj v₁ v₂) (r : G.Walk v₂ b),
      p = Walk.cons h₀₁ (Walk.cons h₁₂ r) := by
  cases p with
  | nil => simp at h
  | cons h₀₁ q =>
    cases q with
    | nil => simp at h
    | cons h₁₂ r => exact ⟨_, _, h₀₁, h₁₂, r, rfl⟩

section Leaf

variable [Fintype V] [DecidableEq V] [DecidableRel G.Adj]

/-- **The second vertex of a longest path.**  In a triangular forest, if `a → v₁ → v₂ → ⋯` is a
longest path and `a` is adjacent to `v₂`, then `v₁` has degree at most two. -/
theorem degree_second_le_two (hG : IsTriangularForest G)
    {a v₁ v₂ b : V} (h₀₁ : G.Adj a v₁) (h₁₂ : G.Adj v₁ v₂) (r : G.Walk v₂ b)
    (hp : (Walk.cons h₀₁ (Walk.cons h₁₂ r)).IsPath)
    (hmax : ∀ (x y : V) (q : G.Walk x y), q.IsPath →
      q.length ≤ (Walk.cons h₀₁ (Walk.cons h₁₂ r)).length)
    (ha₂ : G.Adj a v₂) : G.degree v₁ ≤ 2 := by
  classical
  have hp₁ : (Walk.cons h₁₂ r).IsPath := ((Walk.cons_isPath_iff _ _).1 hp).1
  have hr : r.IsPath := ((Walk.cons_isPath_iff _ _).1 hp₁).1
  have hv₁r : v₁ ∉ r.support := ((Walk.cons_isPath_iff _ _).1 hp₁).2
  have har : a ∉ (Walk.cons h₁₂ r).support := ((Walk.cons_isPath_iff _ _).1 hp).2
  have har' : a ∉ r.support := fun h => har (by simp [Walk.support_cons, h])
  have hsub : G.neighborFinset v₁ ⊆ {a, v₂} := by
    intro y hy
    have hadj : G.Adj v₁ y := (G.mem_neighborFinset v₁ y).1 hy
    by_contra hcon
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hcon
    obtain ⟨hya, hyv₂⟩ := hcon
    have hyv₁ : y ≠ v₁ := hadj.ne'
    have e1 : a ≠ v₁ := h₀₁.ne
    have e2 : a ≠ v₂ := ha₂.ne
    have e3 : a ≠ y := fun h => hya h.symm
    have e4 : v₁ ≠ v₂ := h₁₂.ne
    have e5 : v₁ ≠ y := hadj.ne
    have e6 : v₂ ≠ y := fun h => hyv₂ h.symm
    -- Step 1: `y` lies on the tail `r` of the path.
    have hys : y ∈ r.support := by
      by_contra hnot
      have hnew : (Walk.cons hadj.symm (Walk.cons h₀₁.symm (Walk.cons ha₂ r))).IsPath := by
        rw [Walk.cons_isPath_iff, Walk.cons_isPath_iff, Walk.cons_isPath_iff]
        refine ⟨⟨⟨hr, har'⟩, ?_⟩, ?_⟩
        · simp only [Walk.support_cons, List.mem_cons, not_or]
          exact ⟨e1.symm, hv₁r⟩
        · simp only [Walk.support_cons, List.mem_cons, not_or]
          exact ⟨hyv₁, e3.symm, hnot⟩
      have hlen := hmax _ _ _ hnew
      simp [Walk.length_cons] at hlen
    -- Step 2: `y` sits at position `m + 2` of the path, with `m ≥ 1`.
    set q := r.takeUntil y hys with hq
    have hqp : q.IsPath := hr.takeUntil hys
    have hqv₁ : v₁ ∉ q.support := fun h => hv₁r (r.support_takeUntil_subset hys h)
    have hqlen : q.length ≠ 0 := by
      intro h0
      exact hyv₂ (((r.nil_takeUntil hys).1 (Walk.nil_iff_length_eq.2 h0)).symm)
    rcases Nat.lt_or_ge q.length 2 with hm1 | hm2
    · -- `y` is the vertex `v₃` right after `v₂`: the 4-cycle `a → v₁ → y → v₂ → a` is forbidden.
      have hlen1 : q.length = 1 := by omega
      have hrlen : 0 < r.length := by
        have hle := r.length_takeUntil_le hys
        rw [← hq] at hle
        omega
      have hy1 : r.getVert 1 = y := by
        have := r.getVert_support_idxOf hys
        rwa [← r.length_takeUntil hys, ← hq, hlen1] at this
      have hv₂y : G.Adj v₂ y := by
        have := r.adj_getVert_succ (i := 0) hrlen
        simpa [hy1] using this
      have hcyc : (Walk.cons h₀₁ (Walk.cons hadj (Walk.cons hv₂y.symm
          (Walk.cons ha₂.symm Walk.nil)))).IsCycle := by
        rw [Walk.cons_isCycle_iff]
        refine ⟨?_, ?_⟩
        · simp [Walk.isPath_def, e4, e5, e1.symm, e2.symm, e3.symm, e6.symm]
        · simp [e1, e2, e3, e4, e5, e1.symm]
      have hcl := hG _ hcyc
      simp only [Walk.length_cons, Walk.length_nil] at hcl
      omega
    · -- `y` is further along: it closes a cycle of length `q.length + 2 ≥ 4`.
      have hedge : s(y, v₁) ∉ (Walk.cons h₁₂ q).edges := by
        simp only [Walk.edges_cons, List.mem_cons, Sym2.eq_iff, not_or]
        refine ⟨by simp [e4, e5.symm, e6.symm], ?_⟩
        intro hmem
        exact hqv₁ (Walk.snd_mem_support_of_mem_edges q hmem)
      have hcyc : (Walk.cons hadj.symm (Walk.cons h₁₂ q)).IsCycle := by
        rw [Walk.cons_isCycle_iff]
        refine ⟨?_, hedge⟩
        rw [Walk.cons_isPath_iff]
        exact ⟨hqp, hqv₁⟩
      have hcl := hG _ hcyc
      simp only [Walk.length_cons] at hcl
      omega
  calc G.degree v₁ = #(G.neighborFinset v₁) := (card_neighborFinset_eq_degree G v₁).symm
    _ ≤ #({a, v₂} : Finset V) := Finset.card_le_card hsub
    _ ≤ 2 := Finset.card_insert_le _ _ |>.trans (by simp)

/-- **Leaf triangle lemma.**  A finite triangular forest with minimum degree at least two
contains an edge whose two endpoints both have degree at most two. -/
theorem exists_adj_degree_le_two [Nonempty V] (hG : IsTriangularForest G)
    (hmin : ∀ v : V, 2 ≤ G.degree v) :
    ∃ u v : V, G.Adj u v ∧ G.degree u ≤ 2 ∧ G.degree v ≤ 2 := by
  classical
  obtain ⟨a, b, p, hp, hmax⟩ := exists_maxPath G
  have hdega : G.degree a ≤ 2 := degree_le_two_of_maxPath_endpoint hG p hp hmax
  have hdega' : G.degree a = 2 := le_antisymm hdega (hmin a)
  -- position `2` along `p` is occupied by a neighbour of `a`
  have himg : (G.neighborFinset a).image (fun x => p.support.idxOf x) = {1, 2} := by
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro i hi
      simp only [Finset.mem_image] at hi
      obtain ⟨x, hx, rfl⟩ := hi
      have := maxPath_neighbor_idx hG p hp hmax hx
      simpa using this
    · rw [Finset.card_image_of_injOn (maxPath_idx_injOn p hp hmax)]
      simp [card_neighborFinset_eq_degree, hdega']
  have h2img : (2 : ℕ) ∈ (G.neighborFinset a).image (fun x => p.support.idxOf x) := by
    rw [himg]; simp
  simp only [Finset.mem_image] at h2img
  obtain ⟨x, hx, hx2⟩ := h2img
  have hxs : x ∈ p.support := maxPath_neighbor_mem_support p hp hmax hx
  have hxgv : p.getVert 2 = x := by
    have := p.getVert_support_idxOf hxs
    rwa [hx2] at this
  have hlen : 2 ≤ p.length := by
    by_contra hcon
    push_neg at hcon
    have hidx : p.support.idxOf x < p.support.length := List.idxOf_lt_length_of_mem hxs
    rw [Walk.length_support] at hidx
    omega
  obtain ⟨v₁, v₂, h₀₁, h₁₂, r, rfl⟩ := exists_cons_cons_of_two_le_length p hlen
  have ha₂ : G.Adj a v₂ := by
    have : v₂ = x := by simpa using hxgv
    rw [this]
    exact (G.mem_neighborFinset a x).1 hx
  refine ⟨a, v₁, h₀₁, hdega, degree_second_le_two hG h₀₁ h₁₂ r hp hmax ha₂⟩

end Leaf

section Counting

/-- Deleting a vertex `u` drops the degree of each of its neighbours by at least one. -/
theorem degree_induce_compl_singleton_add_one_le [Fintype V] [DecidableEq V]
    [DecidableRel G.Adj] {u v : V} (h : G.Adj v u) (hv : v ∈ ({u}ᶜ : Set V)) :
    (G.induce ({u}ᶜ : Set V)).degree ⟨v, hv⟩ + 1 ≤ G.degree v := by
  classical
  have hmaps : Set.MapsTo (fun w : ({u}ᶜ : Set V) => (w : V))
      (((G.induce ({u}ᶜ : Set V)).neighborFinset ⟨v, hv⟩ : Finset _) : Set _)
      (((G.neighborFinset v).erase u : Finset V) : Set V) := by
    intro w hw
    simp only [Finset.mem_coe, mem_neighborFinset] at hw
    simp only [Finset.mem_coe, Finset.mem_erase, mem_neighborFinset]
    refine ⟨fun hh => ?_, hw⟩
    exact (w.2 : (w : V) ∈ ({u}ᶜ : Set V)) (by simp [hh])
  have hcard := Finset.card_le_card_of_injOn _ hmaps (Subtype.val_injective.injOn)
  rw [Finset.card_erase_of_mem (by simpa using h)] at hcard
  have hpos : 1 ≤ G.degree v := by
    rw [← card_neighborFinset_eq_degree]
    exact Finset.card_pos.2 ⟨u, by simpa using h⟩
  rw [card_neighborFinset_eq_degree, card_neighborFinset_eq_degree] at hcard
  omega

private theorem sharp_aux : ∀ n : ℕ, ∀ (V : Type u) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj], Fintype.card V = n → 1 ≤ n →
    IsTriangularForest G → 2 * #G.edgeFinset ≤ 3 * (n - 1) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro V _ _ G _ hcard hn hG
    rcases eq_or_lt_of_le hn with h1 | h2
    · -- a single vertex carries no edge
      have hch := G.card_edgeFinset_le_card_choose_two
      rw [hcard, ← h1] at hch
      rw [show Nat.choose 1 2 = 0 from rfl] at hch
      omega
    · have hne : Nonempty V := Fintype.card_pos_iff.1 (by omega)
      by_cases hmin : ∀ v : V, 2 ≤ G.degree v
      · -- minimum degree two: delete a leaf triangle, i.e. two adjacent degree-two vertices
        obtain ⟨u, v, huv, hu, hv⟩ := exists_adj_degree_le_two hG hmin
        have hn3 : 3 ≤ n := by
          have hlt : G.degree u < Fintype.card V := G.degree_lt_card_verts u
          have := hmin u
          omega
        have hvs : v ∈ ({u}ᶜ : Set V) := by simpa using huv.ne'
        have hG'tf : IsTriangularForest (G.induce ({u}ᶜ : Set V)) := hG.induce _
        have hcard' : Fintype.card ({u}ᶜ : Set V) = n - 1 := by
          rw [Fintype.card_compl_set]
          simp [hcard]
        have hedges' : #(G.induce ({u}ᶜ : Set V)).edgeFinset = #G.edgeFinset - G.degree u := by
          rw [G.card_edgeFinset_induce_compl_singleton u, G.card_edgeFinset_deleteIncidenceSet u]
        have hdegu : G.degree u ≤ #G.edgeFinset := G.degree_le_card_edgeFinset u
        -- now delete `v` inside the smaller graph
        have hdegv' : (G.induce ({u}ᶜ : Set V)).degree ⟨v, hvs⟩ + 1 ≤ G.degree v :=
          degree_induce_compl_singleton_add_one_le huv.symm hvs
        have hG''tf : IsTriangularForest
            ((G.induce ({u}ᶜ : Set V)).induce ({(⟨v, hvs⟩ : ({u}ᶜ : Set V))}ᶜ)) :=
          hG'tf.induce _
        have hcard'' : Fintype.card ({(⟨v, hvs⟩ : ({u}ᶜ : Set V))}ᶜ : Set ({u}ᶜ : Set V))
            = n - 2 := by
          rw [Fintype.card_compl_set]
          simp only [Set.card_singleton, hcard']
          omega
        have hedges'' : #((G.induce ({u}ᶜ : Set V)).induce
              ({(⟨v, hvs⟩ : ({u}ᶜ : Set V))}ᶜ)).edgeFinset
            = #(G.induce ({u}ᶜ : Set V)).edgeFinset
              - (G.induce ({u}ᶜ : Set V)).degree ⟨v, hvs⟩ := by
          rw [(G.induce ({u}ᶜ : Set V)).card_edgeFinset_induce_compl_singleton ⟨v, hvs⟩,
            (G.induce ({u}ᶜ : Set V)).card_edgeFinset_deleteIncidenceSet ⟨v, hvs⟩]
        have hdegv'' : (G.induce ({u}ᶜ : Set V)).degree ⟨v, hvs⟩
            ≤ #(G.induce ({u}ᶜ : Set V)).edgeFinset :=
          (G.induce ({u}ᶜ : Set V)).degree_le_card_edgeFinset ⟨v, hvs⟩
        have hIH := ih (n - 2) (by omega)
          ({(⟨v, hvs⟩ : ({u}ᶜ : Set V))}ᶜ : Set ({u}ᶜ : Set V))
          ((G.induce ({u}ᶜ : Set V)).induce ({(⟨v, hvs⟩ : ({u}ᶜ : Set V))}ᶜ)) hcard''
          (by omega) hG''tf
        omega
      · -- some vertex has degree at most one: delete it
        push_neg at hmin
        obtain ⟨v, hv⟩ := hmin
        have hcard' : Fintype.card ({v}ᶜ : Set V) = n - 1 := by
          rw [Fintype.card_compl_set]
          simp [hcard]
        have hedges' : #(G.induce ({v}ᶜ : Set V)).edgeFinset = #G.edgeFinset - G.degree v := by
          rw [G.card_edgeFinset_induce_compl_singleton v, G.card_edgeFinset_deleteIncidenceSet v]
        have hdegv : G.degree v ≤ #G.edgeFinset := G.degree_le_card_edgeFinset v
        have hIH := ih (n - 1) (by omega) ({v}ᶜ : Set V) (G.induce ({v}ᶜ : Set V)) hcard'
          (by omega) (hG.induce _)
        omega

/-- **Sharp sparsity bound.**  A triangular forest on `n ≥ 1` vertices satisfies
`2e ≤ 3(n - 1)`; equality holds exactly for connected unions of triangles glued in a tree
pattern. -/
theorem two_mul_card_edgeFinset_le {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (hG : IsTriangularForest G) (hcard : 1 ≤ Fintype.card V) :
    2 * #G.edgeFinset ≤ 3 * (Fintype.card V - 1) :=
  sharp_aux (Fintype.card V) V G rfl hcard hG

end Counting

section Threshold

/-- A graph on `n ≥ 1` vertices decomposing into two triangular forests has at most
`2⌊3(n-1)/2⌋` edges. -/
theorem card_edgeFinset_le_of_decomposesIntoTwo' {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (hG : DecomposesIntoTwo G)
    (hcard : 1 ≤ Fintype.card V) :
    ∃ e₁ e₂ : ℕ, #G.edgeFinset ≤ e₁ + e₂ ∧ 2 * e₁ ≤ 3 * (Fintype.card V - 1) ∧
      2 * e₂ ≤ 3 * (Fintype.card V - 1) := by
  classical
  obtain ⟨G₁, G₂, h₁, h₂, -, hsup⟩ := hG
  refine ⟨#G₁.edgeFinset, #G₂.edgeFinset, ?_, two_mul_card_edgeFinset_le G₁ h₁ hcard,
    two_mul_card_edgeFinset_le G₂ h₂ hcard⟩
  exact card_edgeFinset_le_of_le_sup (le_of_eq hsup.symm)

/-- **`Kₙ` is not decomposable into two triangular forests for `n ≥ 6`** — the sharp threshold. -/
theorem completeGraph_not_decomposesIntoTwo_six {n : ℕ} (hn : 6 ≤ n) :
    ¬ DecomposesIntoTwo (⊤ : SimpleGraph (Fin n)) := by
  intro hdec
  have hcard : 1 ≤ Fintype.card (Fin n) := by simp; omega
  obtain ⟨e₁, e₂, hle, hb₁, hb₂⟩ :=
    card_edgeFinset_le_of_decomposesIntoTwo' (⊤ : SimpleGraph (Fin n)) hdec hcard
  have htop : #(⊤ : SimpleGraph (Fin n)).edgeFinset = n.choose 2 := by
    rw [SimpleGraph.card_edgeFinset_top_eq_card_choose_two]
    simp
  have hle' : n.choose 2 ≤ e₁ + e₂ := le_trans (le_of_eq htop.symm) hle
  rw [Fintype.card_fin] at hb₁ hb₂
  clear hle htop
  have hchoose : 2 * n.choose 2 = n * (n - 1) := by
    obtain ⟨r, hr⟩ := Nat.even_mul_pred_self n
    rw [Nat.choose_two_right, hr]
    omega
  rcases eq_or_lt_of_le hn with h6 | h7
  · subst_vars
    rw [show Nat.choose 6 2 = 15 by decide] at hle'
    omega
  · -- for `n ≥ 7` the count `n(n-1)` already beats `6(n-1)`
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
    simp only [Nat.add_sub_cancel] at hchoose hb₁ hb₂ h7
    nlinarith [hle', hchoose, hb₁, hb₂, h7]

/-- **Exact threshold for complete graphs.**  `Kₙ` decomposes into two triangular forests
precisely when `n ≤ 5`. -/
theorem completeGraph_decomposesIntoTwo_iff_le_five {n : ℕ} (hn : 5 ≤ n) :
    DecomposesIntoTwo (⊤ : SimpleGraph (Fin n)) ↔ n = 5 := by
  constructor
  · intro hdec
    by_contra hne
    exact completeGraph_not_decomposesIntoTwo_six (by omega) hdec
  · rintro rfl
    exact completeGraph_decomposesIntoTwo_five

end Threshold

end TriangularForest