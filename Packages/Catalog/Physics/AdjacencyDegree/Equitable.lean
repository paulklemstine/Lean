import Physics.AdjacencyDegree.Basic

/-!
# The cyclic module lives inside every equitable partition

Colour refinement (the 1-dimensional Weisfeiler–Leman algorithm) produces an *equitable*
partition of the vertex set: two vertices of the same colour have, for every colour class,
the same number of neighbours in that class.  We show that the adjacency-degree cyclic module
`M_G = 𝒜(G)𝟏` is contained in the space of functions constant on the classes of **any**
equitable partition.  This is the precise sense in which adjacency-degree moment rigidity
"lies inside the colour-refinement hierarchy".

Main results:

* `AdjDeg.degree_eq_of_equitable` : an equitable colouring is degree-preserving;
* `AdjDeg.cyclicModule_le_colorModule` : `M_G ⊆ {f : f constant on colour classes}`.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable {C : Type*} [Fintype C] [DecidableEq C]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- A colouring is *equitable* if vertices of the same colour have the same number of
neighbours in each colour class. -/
def IsEquitable (c : V → C) : Prop :=
  ∀ u v : V, c u = c v → ∀ κ : C,
    ((G.neighborFinset u).filter fun w => c w = κ).card
      = ((G.neighborFinset v).filter fun w => c w = κ).card

/-- Functions constant on the classes of a colouring. -/
def colorModule (c : V → C) : Submodule ℝ (V → ℝ) where
  carrier := {f | ∀ u v : V, c u = c v → f u = f v}
  add_mem' hf hg := fun u v huv => by simp [hf u v huv, hg u v huv]
  zero_mem' := fun _ _ _ => rfl
  smul_mem' a f hf := fun u v huv => by simp [hf u v huv]

omit [Fintype V] [DecidableEq V] in
/-- Fibrewise decomposition of a sum along a colouring. -/
lemma sum_fiber_color (c : V → C) (s : Finset V) (g : C → ℝ) :
    ∑ w ∈ s, g (c w) = ∑ κ : C, ((s.filter fun w => c w = κ).card : ℝ) * g κ := by
  rw [← Finset.sum_fiberwise' s c g]
  refine Finset.sum_congr rfl fun κ _ => ?_
  rw [Finset.sum_const, nsmul_eq_mul]

omit [DecidableEq V] in
/-- Equitable colourings refine the degree partition. -/
theorem degree_eq_of_equitable {c : V → C} (hc : IsEquitable G c) {u v : V} (huv : c u = c v) :
    G.degree u = G.degree v := by
  have hu : G.degree u = ∑ κ : C, ((G.neighborFinset u).filter fun w => c w = κ).card := by
    rw [← SimpleGraph.card_neighborFinset_eq_degree]
    exact Finset.card_eq_sum_card_fiberwise fun w _ => Finset.mem_univ (c w)
  have hv : G.degree v = ∑ κ : C, ((G.neighborFinset v).filter fun w => c w = κ).card := by
    rw [← SimpleGraph.card_neighborFinset_eq_degree]
    exact Finset.card_eq_sum_card_fiberwise fun w _ => Finset.mem_univ (c w)
  rw [hu, hv]
  exact Finset.sum_congr rfl fun κ _ => hc u v huv κ

omit [DecidableEq V] [Fintype C] in
/-- A function constant on colour classes factors through the colouring. -/
lemma exists_factor {c : V → C} {f : V → ℝ} (hf : f ∈ colorModule c) :
    ∃ g : C → ℝ, ∀ v : V, f v = g (c v) := by
  classical
  refine ⟨fun κ => if h : ∃ v : V, c v = κ then f h.choose else 0, fun v => ?_⟩
  have hex : ∃ w : V, c w = c v := ⟨v, rfl⟩
  show f v = if h : ∃ w : V, c w = c v then f h.choose else 0
  rw [dif_pos hex]
  exact (hf _ _ hex.choose_spec).symm

omit [DecidableEq V] in
/-- The adjacency matrix preserves colour-constant functions, for an equitable colouring. -/
theorem adjMatrix_mulVec_mem_colorModule {c : V → C} (hc : IsEquitable G c)
    {f : V → ℝ} (hf : f ∈ colorModule c) : G.adjMatrix ℝ *ᵥ f ∈ colorModule c := by
  obtain ⟨g, hg⟩ := exists_factor hf
  intro u v huv
  have hrew : ∀ x : V, (G.adjMatrix ℝ *ᵥ f) x
      = ∑ κ : C, (((G.neighborFinset x).filter fun w => c w = κ).card : ℝ) * g κ := by
    intro x
    rw [SimpleGraph.adjMatrix_mulVec_apply]
    rw [Finset.sum_congr rfl (fun w _ => hg w)]
    exact sum_fiber_color c (G.neighborFinset x) g
  rw [hrew u, hrew v]
  exact Finset.sum_congr rfl fun κ _ => by rw [hc u v huv κ]

/-- The degree matrix preserves colour-constant functions, for an equitable colouring. -/
theorem degMatrix_mulVec_mem_colorModule {c : V → C} (hc : IsEquitable G c)
    {f : V → ℝ} (hf : f ∈ colorModule c) : degMatrix G *ᵥ f ∈ colorModule c := by
  intro u v huv
  rw [degMatrix_mulVec, degMatrix_mulVec, degree_eq_of_equitable G hc huv, hf u v huv]

/-- **Moment rigidity is refined by colour refinement.** The cyclic module `M_G` consists of
functions constant on the classes of any equitable partition of `G`. -/
theorem cyclicModule_le_colorModule {c : V → C} (hc : IsEquitable G c) :
    cyclicModule G ≤ colorModule c := by
  refine cyclicModule_le_of_stable G _ (fun u v _ => rfl) ?_ ?_
  · exact fun f hf => adjMatrix_mulVec_mem_colorModule G hc hf
  · exact fun f hf => degMatrix_mulVec_mem_colorModule G hc hf

end AdjDeg