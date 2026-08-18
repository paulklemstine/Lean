import Logic.TriangularForest.ClassProperties

/-!
# A clique obstruction to decomposing into two triangular forests

The sharp threshold `Kₙ` (decomposable iff `n ≤ 5`) upgrades to an obstruction for *arbitrary*
graphs: since the property of decomposing into two triangular forests is inherited by subgraphs
(pulled back along injections), any graph containing six mutually adjacent vertices fails to
decompose.

* `TriangularForest.IsTriangularForest.comap` — triangular forests pull back along injections;
* `TriangularForest.DecomposesIntoTwo.comap` — so does decomposability, whenever the pullback
  of the ambient graph is the graph we decompose;
* `TriangularForest.not_decomposesIntoTwo_of_six_clique` — a graph with a `K₆` subgraph does not
  decompose into two triangular forests.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V W : Type*} {G : SimpleGraph V}

/-- Triangular forests pull back along injective maps. -/
theorem IsTriangularForest.comap (f : W ↪ V) (hG : IsTriangularForest G) :
    IsTriangularForest (G.comap f) := by
  intro v c hc
  have hinj : Function.Injective (SimpleGraph.Embedding.comap f G).toHom :=
    (SimpleGraph.Embedding.comap f G).injective
  have := hG (c.map (SimpleGraph.Embedding.comap f G).toHom) (hc.map hinj)
  simpa using this

/-- Decomposability into two triangular forests is inherited by pullbacks along injections. -/
theorem DecomposesIntoTwo.comap {H : SimpleGraph W} (f : W ↪ V) (hG : DecomposesIntoTwo G)
    (hH : H ≤ G.comap f) : DecomposesIntoTwo H := by
  obtain ⟨G₁, G₂, h₁, h₂, hdisj, hsup⟩ := hG
  refine ⟨H ⊓ G₁.comap f, H ⊓ G₂.comap f, (h₁.comap f).mono inf_le_right,
    (h₂.comap f).mono inf_le_right, ?_, ?_⟩
  · refine Disjoint.mono inf_le_right inf_le_right ?_
    rw [disjoint_iff_inf_le] at hdisj ⊢
    intro a b hab
    exact hdisj hab
  · rw [← inf_sup_left]
    have hcs : G₁.comap f ⊔ G₂.comap f = G.comap f := by
      ext a b
      simp [← hsup]
    rw [hcs]
    exact inf_eq_left.2 hH

/-- **Clique obstruction.**  A graph containing six mutually adjacent vertices does not decompose
into two triangular forests. -/
theorem not_decomposesIntoTwo_of_six_clique (f : Fin 6 ↪ V)
    (hf : ∀ i j : Fin 6, i ≠ j → G.Adj (f i) (f j)) : ¬ DecomposesIntoTwo G := by
  intro hdec
  have hle : (⊤ : SimpleGraph (Fin 6)) ≤ G.comap f := by
    intro i j hij
    exact hf i j hij
  exact completeGraph_not_decomposesIntoTwo_six (le_refl 6) (hdec.comap f hle)

end TriangularForest