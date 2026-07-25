/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Cellular Sheaf Cohomology on Graphs

We develop the theory of cellular sheaves on simple graphs, formalizing
the zeroth cohomology group H⁰(G, R) of the constant sheaf and proving
its fundamental connection to graph connectivity.

The central result is `mem_H0_iff_reachable`: a function f : V → R belongs
to H⁰(G, R) if and only if f is constant on reachable pairs of vertices.
This characterizes global sections of the constant sheaf in terms of the
connected component structure of the graph.

## Main definitions

* `CellularSheaf.H0`: Zeroth cohomology of the constant sheaf on a graph
* `CellularSheaf.constSubmodule`: The submodule of constant functions
* `CellularSheaf.GraphSheaf`: A general cellular sheaf on a simple graph

## Main results

* `CellularSheaf.mem_H0_iff_reachable`: f ∈ H⁰(G,R) ↔ f constant on reachable pairs
* `CellularSheaf.H0_eq_const_of_connected`: H⁰ = constants for connected graphs
* `CellularSheaf.H0_antitone`: More edges ⟹ fewer global sections
* `CellularSheaf.mkConstantSheaf_section_iff_H0`: Bridge to general sheaf theory
-/

namespace CellularSheaf

open SimpleGraph

/-! ### H⁰ of the Constant Sheaf -/

section ConstantSheaf

variable {V : Type*} [DecidableEq V] (G : SimpleGraph V) (R : Type*) [CommRing R]

/-- The zeroth cohomology H⁰(G, R) of the constant sheaf with values in R.
    A function f : V → R belongs to H⁰ iff it is constant on adjacent vertices.
    These are precisely the global sections of the constant sheaf. -/
def H0 : Submodule R (V → R) where
  carrier := {f | ∀ v w, G.Adj v w → f v = f w}
  zero_mem' _ _ _ := rfl
  add_mem' {a b} ha hb v w hadj := by
    show (a + b) v = (a + b) w
    simp only [Pi.add_apply, ha v w hadj, hb v w hadj]
  smul_mem' c f hf v w hadj := by
    show (c • f) v = (c • f) w
    simp only [Pi.smul_apply, hf v w hadj]

/-- The submodule of constant functions V → R. -/
def constSubmodule (V : Type*) (R : Type*) [CommRing R] : Submodule R (V → R) where
  carrier := {f | ∀ v w, f v = f w}
  zero_mem' _ _ := rfl
  add_mem' {a b} ha hb v w := by
    show (a + b) v = (a + b) w
    simp only [Pi.add_apply, ha v w, hb v w]
  smul_mem' c f hf v w := by
    show (c • f) v = (c • f) w
    simp only [Pi.smul_apply, hf v w]

variable {G R}

/-
A function in H⁰ is constant along any walk in the graph.
    This is the key inductive step: adjacency-constancy propagates along walks.
-/
lemma H0_const_along_walk {f : V → R} (hf : f ∈ H0 G R)
    {v w : V} (p : G.Walk v w) : f v = f w := by
  induction p;
  · rfl;
  · exact hf _ _ ‹_› ▸ by assumption;

/-
**Core characterization theorem**: f ∈ H⁰(G,R) if and only if f is constant
    on all pairs of vertices connected by a path in G.

    This connects sheaf cohomology (an algebraic invariant) to graph reachability
    (a combinatorial/topological property). The forward direction propagates
    constancy along walks by induction; the backward direction is immediate
    since adjacency implies reachability.
-/
theorem mem_H0_iff_reachable (f : V → R) :
    f ∈ H0 G R ↔ ∀ v w, G.Reachable v w → f v = f w := by
  refine' ⟨ fun hf v w h => _, fun hf => _ ⟩;
  · exact H0_const_along_walk hf h.some;
  · exact fun v w hvw => hf v w hvw.reachable

variable (G R)

/-
Constant functions are always global sections.
-/
lemma constSubmodule_le_H0 : constSubmodule V R ≤ H0 G R := by
  intro f hf v w h; have := hf v w; aesop;

/-
For a connected graph, H⁰ consists exactly of the constant functions.
    Sheaf-theoretically: a connected network has no barriers to information
    propagation, so global sections are precisely the universally constant signals.
-/
theorem H0_eq_const_of_connected (hconn : G.Connected) :
    H0 G R = constSubmodule V R := by
  ext f
  constructor
  intro hf
  exact (by
  exact fun v w => by have := hconn.preconnected v w; exact mem_H0_iff_reachable f |>.1 hf v w this;)
  intro hf
  exact (by
  exact fun v w hvw => hf v w)

/-
For the discrete graph (no edges), H⁰ is the entire function space.
    With no adjacency constraints, every function is a global section.
-/
theorem H0_bot_eq_top : H0 (⊥ : SimpleGraph V) R = ⊤ := by
  exact Submodule.ext fun x => by simp +decide [ H0 ] ;

/-
For the complete graph on a nonempty type, H⁰ = constant functions.
-/
theorem H0_top_eq_const [Nonempty V] :
    H0 (⊤ : SimpleGraph V) R = constSubmodule V R := by
  exact H0_eq_const_of_connected _ _ SimpleGraph.connected_top

/-! ### PEGB: Examples -/

/-- Example: the constant-1 function is a global section of the complete graph. -/
example : (fun _ : Fin 3 => (1 : ℤ)) ∈ H0 (⊤ : SimpleGraph (Fin 3)) ℤ := by
  intro v w _; rfl

/-- Example: on the discrete graph, the identity is a global section. -/
example : (fun i : Fin 3 => (i : ℤ)) ∈ H0 (⊥ : SimpleGraph (Fin 3)) ℤ := by
  intro v w h; exact absurd h (by simp [bot_adj])

/-! ### PEGB: Generalizations -/

/-
Generalization: H⁰ = ⊤ for any graph with empty adjacency relation.
-/
theorem H0_eq_top_of_no_adj (h : ∀ v w : V, ¬G.Adj v w) : H0 G R = ⊤ := by
  exact SetLike.ext fun x => by simp +decide [ H0, h ] ;

/-
**Antitone monotonicity**: H⁰ is contravariant in the graph — adding edges
    imposes more consistency constraints and shrinks the space of global sections.

    This is a functoriality result: the assignment G ↦ H⁰(G, R) is a contravariant
    functor from the poset of graphs (ordered by subgraph inclusion) to the poset
    of submodules (ordered by inclusion).
-/
theorem H0_antitone : Antitone (fun G : SimpleGraph V => H0 G R) := by
  intro G₁ G₂ hG₁₂ f hf v w hvw;
  exact hf v w ( hG₁₂ hvw )

/-! ### PEGB: Boundary Analysis -/

/-
Boundary: on a discrete 2-vertex graph, a non-constant function is in H⁰.
    This shows the connected hypothesis in `H0_eq_const_of_connected` is essential.
-/
example : ∃ f : Fin 2 → ℤ, f ∈ H0 (⊥ : SimpleGraph (Fin 2)) ℤ ∧
    ¬(∀ v w, f v = f w) := by
  refine' ⟨ fun v => if v = 0 then 0 else 1, _, _ ⟩ <;> simp +decide [ H0 ]

end ConstantSheaf

/-! ### General Cellular Sheaves -/

section GeneralSheaf

variable {V : Type*} [DecidableEq V] (R : Type*) [CommRing R]

/-- A cellular sheaf on a simple graph assigns an R-module to each vertex
    and an R-linear comparison map to each directed edge (ordered adjacent pair).

    In the sheaf-theoretic picture, `comparison v w h` transports a local section
    at vertex v to a local section at vertex w along the edge (v,w). -/
structure GraphSheaf (G : SimpleGraph V) where
  /-- The stalk (fiber) module at each vertex -/
  Stalk : V → Type*
  [instAddCommGroup : ∀ v, AddCommGroup (Stalk v)]
  [instModule : ∀ v, Module R (Stalk v)]
  /-- Comparison map transporting sections along edges -/
  comparison : ∀ v w, G.Adj v w → Stalk v →ₗ[R] Stalk w

attribute [instance] GraphSheaf.instAddCommGroup GraphSheaf.instModule

/-- The constant sheaf assigns R to every vertex with identity comparison maps. -/
def mkConstantSheaf (G : SimpleGraph V) : GraphSheaf R G where
  Stalk _ := R
  comparison _ _ _ := LinearMap.id

variable {R}

/-- A global section of a graph sheaf: a dependent function choosing a stalk
    element at each vertex, compatible under all comparison maps. -/
def GraphSheaf.IsGlobalSection {G : SimpleGraph V} (F : GraphSheaf R G)
    (s : ∀ v, F.Stalk v) : Prop :=
  ∀ v w (h : G.Adj v w), F.comparison v w h (s v) = s w

/-
The global sections of the constant sheaf correspond exactly to H⁰.
    This bridges the abstract sheaf framework with the concrete H⁰ definition.
-/
omit [DecidableEq V] in
theorem mkConstantSheaf_section_iff_H0 (G : SimpleGraph V) (f : V → R) :
    (mkConstantSheaf R G).IsGlobalSection f ↔ f ∈ H0 G R := by
  aesop

end GeneralSheaf

/-! ### Dimension of H⁰ (Generalization for future work) -/

section DimensionBounds

variable {V : Type*} [DecidableEq V] [Fintype V]
  (G : SimpleGraph V) [DecidableRel G.Adj] (k : Type*) [Field k]

/-
**Generalization** (stated for future work): For a finite graph over a field,
    the dimension of H⁰ equals the number of connected components —
    the sheaf-theoretic zeroth Betti number.
-/
theorem finrank_H0_eq_card_connectedComponent :
    Module.finrank k (H0 G k) = Fintype.card G.ConnectedComponent := by
  -- To prove the dimension equality, we establish a linear isomorphism between H0(G, k) and the space of functions on connected components.
  have h_iso : H0 G k ≃ₗ[k] (G.ConnectedComponent → k) := by
    refine' ( LinearEquiv.ofBijective _ ⟨ _, _ ⟩ );
    refine' { toFun := fun f c => f.val ( Classical.choose ( c.exists_rep ) ), map_add' := _, map_smul' := _ } <;> simp +decide [ H0 ];
    all_goals norm_num [ funext_iff, Function.Injective, Function.Surjective ];
    · intro f hf g hg hfg v
      have h_reachable : f v = f (Classical.choose (G.connectedComponentMk v).exists_rep) ∧ g v = g (Classical.choose (G.connectedComponentMk v).exists_rep) := by
        have h_const : ∀ v w, G.Reachable v w → f v = f w ∧ g v = g w := by
          grind +suggestions
        generalize_proofs at *; (
        exact h_const _ _ ( by have := Classical.choose_spec ‹∃ x, Quot.mk G.Reachable x = G.connectedComponentMk v›; exact? ))
      generalize_proofs at *; (
      aesop);
    · intro b
      use fun v => b (G.connectedComponentMk v);
      refine' ⟨ _, _ ⟩
      all_goals generalize_proofs at *;
      · intro v w hvw
        generalize_proofs at *; (
        exact congr_arg b ( SimpleGraph.ConnectedComponent.sound hvw.reachable ));
      · exact fun x => congr_arg b ( Classical.choose_spec ( ‹∀ x : G.ConnectedComponent, ∃ x_1, Quot.mk G.Reachable x_1 = x› x ) )
  generalize_proofs at *; (
  convert LinearEquiv.finrank_eq h_iso using 1 ; simp +decide [ Module.finrank_pi ])

end DimensionBounds

end CellularSheaf