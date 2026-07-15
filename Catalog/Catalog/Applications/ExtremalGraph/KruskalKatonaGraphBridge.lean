/-
# Extremal Graph Theory IV: a Kruskal–Katona bridge to triangle/edge counting

This file builds a **cross-domain bridge** between the set-family world (where the
Kruskal–Katona theorem lives, `Mathlib.Combinatorics.SetFamily.KruskalKatona`) and the
extremal-graph world (cliques, edges).  The catalog already contains:

* `Catalog/Applications/ExtremalGraph/Turan.lean` — Turán/Mantel edge bounds;
* `Catalog/Applications/ExtremalGraph/KruskalKatona.lean` — `ExtremalKK.kk_shadow_lower`,
  the abstract shadow lower bound for uniform set families.

The new content here turns the *abstract* shadow bound into a concrete *graph-theoretic*
inequality:

> **A graph with many triangles has many edges.**
> If a graph `G` on `Fin n` contains at least `C(k,3)` triangles (with `3 ≤ k ≤ n`),
> then it has at least `C(k,2)` edges.

The key structural observation (`shadow_triangles_subset_edges`) is that the **shadow** of the
family of triangles (every `3`-clique with one vertex deleted) is contained in the family of
**edges** (the `2`-cliques): deleting a vertex from a triangle leaves an edge.  Kruskal–Katona
then lower-bounds the shadow, and that bound transfers to the edges.  This is exactly the
viewpoint that makes "triangles are `3`-sets, edges are their `2`-shadows" precise.

CATEGORY (Menu Balance, v19a): **cross-domain bridge** — Kruskal–Katona set-family
combinatorics ⨯ extremal graph theory (cliques/edges).
-/
import Mathlib

open Finset SimpleGraph
open scoped FinsetFamily

namespace ExtremalKKGraph

variable {n k : ℕ} {G : SimpleGraph (Fin n)} [DecidableRel G.Adj]

/-! ## The structural lemmas -/

/-- The triangle family of a graph is `3`-uniform. -/
theorem triangles_sized :
    (↑(G.cliqueFinset 3) : Set (Finset (Fin n))).Sized 3 := by
  intro s hs
  rw [mem_coe, mem_cliqueFinset_iff] at hs
  exact hs.2

/-- **The geometric heart of the bridge.** The shadow of the family of triangles (`3`-cliques) is
contained in the family of edges (`2`-cliques): erasing one vertex from a triangle yields an edge
of the graph. -/
theorem shadow_triangles_subset_edges :
    ∂ (G.cliqueFinset 3) ⊆ G.cliqueFinset 2 := by
  intro t ht
  rw [mem_shadow_iff] at ht
  obtain ⟨s, hs, a, ha, rfl⟩ := ht
  rw [mem_cliqueFinset_iff] at hs ⊢
  rw [isNClique_iff] at hs ⊢
  exact ⟨hs.1.subset (Finset.erase_subset _ _),
    by rw [Finset.card_erase_of_mem ha, hs.2]⟩

/-! ## The main bridge theorem -/

/-- **Kruskal–Katona for graphs (clique form).** A graph on `Fin n` with at least `C(k,3)`
triangles (where `3 ≤ k ≤ n`) has at least `C(k,2)` edges, where edges are counted as `2`-cliques.

The proof feeds the `3`-uniform triangle family to the Lovász form of Kruskal–Katona
(`kruskal_katona_lovasz_form`, the engine behind `ExtremalKK.kk_shadow_lower`) to bound the
shadow, then transfers that bound to the edges via `shadow_triangles_subset_edges`. -/
theorem card_cliqueFinset_two_ge_of_triangles (hk : 3 ≤ k) (hkn : k ≤ n)
    (h : k.choose 3 ≤ #(G.cliqueFinset 3)) :
    k.choose 2 ≤ #(G.cliqueFinset 2) := by
  have hlov := kruskal_katona_lovasz_form (i := 1) (r := 3) (k := k) (by norm_num) hk hkn
    triangles_sized h
  simp only [Function.iterate_one] at hlov
  calc k.choose 2 = k.choose (3 - 1) := by norm_num
    _ ≤ #(∂ (G.cliqueFinset 3)) := hlov
    _ ≤ #(G.cliqueFinset 2) := card_le_card shadow_triangles_subset_edges

/-- The number of `2`-cliques equals the number of edges of a finite graph. -/
theorem card_cliqueFinset_two_eq_edgeFinset {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleGraph V) [DecidableRel H.Adj] :
    #(H.cliqueFinset 2) = #H.edgeFinset := by
  convert Set.ncard_coe_finset ( H.edgeFinset.image ( fun e : Sym2 V => e.toFinset ) ) using 1;
  · convert Set.ncard_coe_finset ( H.cliqueFinset 2 ) using 2;
    · rw [ Set.ncard_coe_finset ];
    · convert Set.ncard_coe_finset ( H.cliqueFinset 2 ) using 2;
      ext; simp [SimpleGraph.isNClique_iff];
      constructor <;> intro h;
      · rcases h with ⟨ x, hx, rfl ⟩ ; rcases x with ⟨ u, v ⟩ ; simp_all +decide [ SimpleGraph.isClique_iff, Sym2.toFinset ] ;
        simp +decide [ Sym2.toMultiset, hx.ne, hx ];
      · rcases Finset.card_eq_two.mp h.2 with ⟨ a, b, hab, rfl ⟩ ; use s(a, b) ; aesop;
  · rw [ Finset.card_image_of_injOn ];
    intro e₁ he₁ e₂ he₂ h; simp_all +decide [ Finset.ext_iff, Sym2.ext_iff ] ;

/-- **Kruskal–Katona for graphs (edge form).** A graph on `Fin n` with at least `C(k,3)` triangles
(where `3 ≤ k ≤ n`) has at least `C(k,2)` edges. -/
theorem card_edgeFinset_ge_of_triangles (hk : 3 ≤ k) (hkn : k ≤ n)
    (h : k.choose 3 ≤ #(G.cliqueFinset 3)) :
    k.choose 2 ≤ #G.edgeFinset := by
  rw [← card_cliqueFinset_two_eq_edgeFinset]
  exact card_cliqueFinset_two_ge_of_triangles hk hkn h

end ExtremalKKGraph