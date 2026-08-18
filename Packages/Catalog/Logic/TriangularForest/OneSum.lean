import Logic.TriangularForest.ClassProperties

/-!
# Triangular forests are closed under 1-sums

A *1-sum* of two graphs glues them along a single vertex.  Together with closure under
subgraphs, decidable membership, containing a triangle and not being everything, this is one of
the properties the Lee–Liu–Tsai framework requires of the graph class `F`.

The formalisation keeps both summands on the same vertex type: `G₁` and `G₂` are graphs whose
supports meet in at most one vertex `x`, and the 1-sum is `G₁ ⊔ G₂`.

The combinatorial core is `TriangularForest.edges_side`: along a walk that avoids `x` at every
position except possibly its last, consecutive edges are forced to stay on the same side, since
a vertex incident to an edge of `G₁` and to an edge of `G₂` must be the gluing vertex `x`.  A
cycle can then be transferred wholesale into `G₁` or into `G₂`, where it is a triangle.
-/

namespace TriangularForest

open SimpleGraph

variable {V : Type*} {G₁ G₂ : SimpleGraph V} {x : V}

/-- Along a walk none of whose non-final vertices is the gluing vertex `x`, all edges lie on the
same side of the 1-sum. -/
theorem edges_side (hx : ∀ y : V, (∃ u, G₁.Adj y u) → (∃ w, G₂.Adj y w) → y = x)
    {u w : V} (p : (G₁ ⊔ G₂).Walk u w) (hne : ∀ i < p.length, p.getVert i ≠ x) :
    (∀ e ∈ p.edges, e ∈ G₁.edgeSet) ∨ (∀ e ∈ p.edges, e ∈ G₂.edgeSet) := by
  induction p with
  | nil => exact Or.inl (by simp)
  | @cons a b c h q ih =>
    have hne' : ∀ i < q.length, q.getVert i ≠ x := by
      intro i hi
      have := hne (i + 1) (by simp only [Walk.length_cons]; omega)
      simpa using this
    cases q with
    | nil =>
      rcases ((sup_adj _ _ _ _).1 h) with h1 | h1
      · exact Or.inl (by simp [h1])
      · exact Or.inr (by simp [h1])
    | @cons _ c' _ h' q' =>
      have hbx : b ≠ x := by
        have := hne' 0 (by simp only [Walk.length_cons]; omega)
        simpa using this
      rcases ih hne' with hL | hR
      · have hb' : G₁.Adj b c' := by
          have : s(b, c') ∈ (Walk.cons h' q').edges := by simp
          simpa using hL _ this
        rcases ((sup_adj _ _ _ _).1 h) with h1 | h1
        · refine Or.inl ?_
          intro e he
          rw [Walk.edges_cons, List.mem_cons] at he
          rcases he with rfl | he
          · simpa using h1
          · exact hL _ he
        · exact absurd (hx b ⟨c', hb'⟩ ⟨a, h1.symm⟩) hbx
      · have hb' : G₂.Adj b c' := by
          have : s(b, c') ∈ (Walk.cons h' q').edges := by simp
          simpa using hR _ this
        rcases ((sup_adj _ _ _ _).1 h) with h1 | h1
        · exact absurd (hx b ⟨a, h1.symm⟩ ⟨c', hb'⟩) hbx
        · refine Or.inr ?_
          intro e he
          rw [Walk.edges_cons, List.mem_cons] at he
          rcases he with rfl | he
          · simpa using h1
          · exact hR _ he

/-- Every cycle of a 1-sum lives entirely in one of the two summands. -/
theorem cycle_edges_side (hx : ∀ y : V, (∃ u, G₁.Adj y u) → (∃ w, G₂.Adj y w) → y = x)
    {v : V} (c : (G₁ ⊔ G₂).Walk v v) (hc : c.IsCycle) :
    ∃ (u : V) (c' : (G₁ ⊔ G₂).Walk u u), c'.IsCycle ∧ c'.length = c.length ∧
      ((∀ e ∈ c'.edges, e ∈ G₁.edgeSet) ∨ (∀ e ∈ c'.edges, e ∈ G₂.edgeSet)) := by
  classical
  by_cases hxs : x ∈ c.support
  · -- rotate the cycle so that it starts at the gluing vertex
    refine ⟨x, c.rotate hxs, hc.rotate hxs, ?_, ?_⟩
    · obtain ⟨n, hn⟩ := c.rotate_edges hxs
      have hlen : (c.rotate hxs).edges.length = c.edges.length := by
        rw [← hn, List.length_rotate]
      simpa [Walk.length_edges] using hlen
    · set c' := c.rotate hxs with hc'def
      have hc' : c'.IsCycle := hc.rotate hxs
      have hlen : 3 ≤ c'.length := hc'.three_le_length
      obtain ⟨y, h₀, q, hq⟩ := Walk.not_nil_iff.1 hc'.not_nil
      have hqlen : q.length = c'.length - 1 := by
        have : c'.length = q.length + 1 := by rw [hq]; simp
        omega
      -- interior vertices of the cycle differ from `x`
      have hinner : ∀ i < q.length, q.getVert i ≠ x := by
        intro i hi hcon
        have hgv : c'.getVert (i + 1) = x := by
          rw [hq]
          simpa using hcon
        have hle : i + 1 ≤ c'.length := by omega
        have := (hc'.getVert_endpoint_iff hle).1 hgv
        omega
      have hyx : y ≠ x := by
        have h0 : q.getVert 0 = y := by simp
        have := hinner 0 (by omega)
        rw [h0] at this
        exact this
      have hqnil : ¬ q.Nil := Walk.not_nil_iff_lt_length.2 (by omega)
      obtain ⟨z, hyz, q', hq'⟩ := Walk.not_nil_iff.1 hqnil
      rcases edges_side hx q hinner with hL | hR
      · refine Or.inl ?_
        have hyz₁ : G₁.Adj y z := by
          have : s(y, z) ∈ q.edges := by rw [hq']; simp
          simpa using hL _ this
        have h₀₁ : G₁.Adj x y := by
          rcases ((sup_adj _ _ _ _).1 h₀) with h1 | h1
          · exact h1
          · exact absurd (hx y ⟨z, hyz₁⟩ ⟨x, h1.symm⟩) hyx
        intro e he
        rw [hq, Walk.edges_cons, List.mem_cons] at he
        rcases he with rfl | he
        · simpa using h₀₁
        · exact hL _ he
      · refine Or.inr ?_
        have hyz₂ : G₂.Adj y z := by
          have : s(y, z) ∈ q.edges := by rw [hq']; simp
          simpa using hR _ this
        have h₀₂ : G₂.Adj x y := by
          rcases ((sup_adj _ _ _ _).1 h₀) with h1 | h1
          · exact absurd (hx y ⟨x, h1.symm⟩ ⟨z, hyz₂⟩) hyx
          · exact h1
        intro e he
        rw [hq, Walk.edges_cons, List.mem_cons] at he
        rcases he with rfl | he
        · simpa using h₀₂
        · exact hR _ he
  · refine ⟨v, c, hc, rfl, edges_side hx c ?_⟩
    intro i _ hcon
    exact hxs (hcon ▸ c.getVert_mem_support i)

/-- **Triangular forests are closed under 1-sums.**  If `G₁` and `G₂` are triangular forests
whose supports meet only in the vertex `x`, then their union is a triangular forest. -/
theorem isTriangularForest_oneSum (h₁ : IsTriangularForest G₁) (h₂ : IsTriangularForest G₂)
    (hx : ∀ y : V, (∃ u, G₁.Adj y u) → (∃ w, G₂.Adj y w) → y = x) :
    IsTriangularForest (G₁ ⊔ G₂) := by
  intro v c hc
  obtain ⟨u, c', hc', hlen, hside⟩ := cycle_edges_side hx c hc
  rcases hside with h | h
  · have := h₁ (c'.transfer G₁ h) (hc'.transfer h)
    rw [Walk.length_transfer] at this
    omega
  · have := h₂ (c'.transfer G₂ h) (hc'.transfer h)
    rw [Walk.length_transfer] at this
    omega

end TriangularForest