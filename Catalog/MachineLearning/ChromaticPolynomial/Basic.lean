import Mathlib
import Speculative.ChromaticPolynomial.Defs

/-!
# Chromatic Polynomial — Structural Properties

This file establishes structural properties of the chromatic polynomial:
degree, monicity, and the relationship between connected components
and edge sets.

## Main Results

* `SimpleGraph.numComponentsOfEdges_empty` — the empty edge set has `|V|` components.
* `SimpleGraph.numComponentsOfEdges_lt` — adding edges reduces the component count.
* `SimpleGraph.natDegree_chromaticPolynomial` — degree equals `|V|`.
* `SimpleGraph.monic_chromaticPolynomial` — the chromatic polynomial is monic.
-/

open Polynomial Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Component counting lemmas -/

/-
The empty edge set yields `|V|` connected components (each vertex is isolated).
-/
theorem numComponentsOfEdges_empty :
    numComponentsOfEdges (∅ : Finset (Sym2 V)) = Fintype.card V := by
  -- Since the graph is empty, each vertex is its own connected component.
  have h_empty_components : ∀ (v w : V), (spanningSubgraphOfEdges (∅ : Finset (Sym2 V))).Reachable v w ↔ v = w := by
    rintro v w
    constructor
    intro h
    have h_path : ∃ p : SimpleGraph.Walk (spanningSubgraphOfEdges (∅ : Finset (Sym2 V))) v w, True := by
      exact ⟨ h.some, trivial ⟩;
    · obtain ⟨ p, hp ⟩ := h_path
      induction' p with v w p ih;
      · rfl;
      · cases ‹ ( spanningSubgraphOfEdges ∅ ).Adj w p › ; tauto;
    · rintro rfl; exact SimpleGraph.Reachable.refl _;
  refine' Fintype.card_congr _;
  symm;
  refine' Equiv.ofBijective ( fun v => ( spanningSubgraphOfEdges ∅ ).connectedComponentMk v ) ⟨ fun v w h => _, fun c => _ ⟩;
  · exact h_empty_components v w |>.1 ( by simpa using h );
  · exact c.exists_rep

/-
For any nonempty subset `A` of edges, the number of components is strictly
less than `|V|`.
-/
theorem numComponentsOfEdges_lt_of_nonempty {A : Finset (Sym2 V)}
    (hA : A.Nonempty)
    (hA_edges : ∀ e ∈ A, ¬ Sym2.IsDiag e) :
    numComponentsOfEdges A < Fintype.card V := by
  -- Since there's at least one edge in A, there must be at least two vertices connected by that edge. Therefore, the connected components can't be as many as the vertices because those two vertices are in the same component.
  obtain ⟨u, v, huv⟩ : ∃ u v : V, u ≠ v ∧ s(u, v) ∈ A := by
    obtain ⟨ e, he ⟩ := hA;
    rcases e with ⟨ u, v ⟩;
    exact ⟨ u, v, by specialize hA_edges _ he; aesop, he ⟩;
  -- Since $u$ and $v$ are connected by an edge in $A$, they are in the same connected component.
  have h_connected : (spanningSubgraphOfEdges A).Reachable u v := by
    exact SimpleGraph.Adj.reachable ( by unfold spanningSubgraphOfEdges; aesop );
  -- Since $u$ and $v$ are in the same connected component, the map $connectedComponentMk : V → ConnectedComponent$ is not injective.
  have h_not_inj : ¬Function.Injective (fun x : V => (spanningSubgraphOfEdges A).connectedComponentMk x) := by
    exact fun hinj => huv.1 ( hinj <| by aesop );
  contrapose! h_not_inj;
  have h_surj : Function.Surjective (fun x : V => (spanningSubgraphOfEdges A).connectedComponentMk x) := by
    intro c;
    obtain ⟨ x, hx ⟩ := c.exists_rep; use x; aesop;
  exact ( Fintype.bijective_iff_surjective_and_card _ ).mpr ⟨ h_surj, by simpa [ numComponentsOfEdges ] using h_not_inj.antisymm ( Fintype.card_le_of_surjective _ h_surj ) ⟩ |>.1

/-
The number of components never exceeds `|V|`.
-/
theorem numComponentsOfEdges_le (A : Finset (Sym2 V)) :
    numComponentsOfEdges A ≤ Fintype.card V := by
  -- By definition of `numComponentsOfEdges`, each vertex belongs to exactly one connected component.
  have h_components : Fintype.card (spanningSubgraphOfEdges A).ConnectedComponent ≤ Fintype.card V := by
    have h_surjective : Function.Surjective (fun v : V => (spanningSubgraphOfEdges A).connectedComponentMk v) := by
      intro c;
      exact c.exists_rep
    exact Fintype.card_le_of_surjective _ h_surjective;
  exact h_components

/-! ### Degree and Monicity -/

/-
The chromatic polynomial has degree equal to `|V|`.
-/
theorem natDegree_chromaticPolynomial (G : SimpleGraph V) [DecidableRel G.Adj]
    [Nonempty V] :
    G.chromaticPolynomial.natDegree = Fintype.card V := by
  have h_leading : Polynomial.coeff G.chromaticPolynomial (Fintype.card V) = 1 := by
    have h_leading : Polynomial.coeff G.chromaticPolynomial (Fintype.card V) = ∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * if numComponentsOfEdges A = Fintype.card V then 1 else 0 := by
      unfold SimpleGraph.chromaticPolynomial; simp +decide [ Polynomial.coeff_sum ] ;
      refine' Finset.sum_congr rfl fun A hA => _;
      by_cases h : Even A.card <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ];
      · simp +decide only [eq_comm];
      · grind;
    rw [ h_leading, Finset.sum_eq_single ∅ ] <;> simp_all +decide;
    · exact?;
    · intro A hA hA_nonempty
      have hA_lt : numComponentsOfEdges A < Fintype.card V := by
        apply SimpleGraph.numComponentsOfEdges_lt_of_nonempty;
        · exact Finset.nonempty_of_ne_empty hA_nonempty;
        · exact?;
      exact ne_of_lt hA_lt;
  refine' Polynomial.natDegree_eq_of_le_of_coeff_ne_zero _ _ <;> norm_num [ h_leading ];
  refine' Polynomial.natDegree_le_of_degree_le _;
  refine' le_trans ( Polynomial.degree_sum_le _ _ ) ( Finset.sup_le _ );
  simp +decide [ numComponentsOfEdges_le ]

/-
The chromatic polynomial is monic.
-/
theorem monic_chromaticPolynomial (G : SimpleGraph V) [DecidableRel G.Adj]
    [Nonempty V] :
    G.chromaticPolynomial.Monic := by
  have h_coeff : Polynomial.coeff G.chromaticPolynomial (Fintype.card V) = 1 := by
    unfold SimpleGraph.chromaticPolynomial;
    rw [ Polynomial.finset_sum_coeff, Finset.sum_eq_single ∅ ] <;> simp +decide [ numComponentsOfEdges_empty ];
    intro b hb hb_nonempty
    have h_card : numComponentsOfEdges b < Fintype.card V := by
      apply numComponentsOfEdges_lt_of_nonempty;
      · exact Finset.nonempty_of_ne_empty hb_nonempty;
      · intro e he; specialize hb he; aesop;
    rw [ Polynomial.coeff_eq_zero_of_natDegree_lt ] ; aesop;
  rwa [ Polynomial.Monic, Polynomial.leadingCoeff, SimpleGraph.natDegree_chromaticPolynomial ]

/-
The leading coefficient of the chromatic polynomial is 1.
-/
theorem leadingCoeff_chromaticPolynomial (G : SimpleGraph V) [DecidableRel G.Adj]
    [Nonempty V] :
    G.chromaticPolynomial.leadingCoeff = 1 := by
  convert monic_chromaticPolynomial G

end SimpleGraph