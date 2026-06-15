import Mathlib

/-!
# Chromatic Polynomial — Core Definitions

This file defines the chromatic polynomial of a finite simple graph and establishes
its fundamental specification: evaluating the polynomial at a natural number `k` yields
the number of proper colorings of the graph with `k` colors.

## Main Definitions

* `SimpleGraph.IsProperColoring G c` — predicate asserting `c : V → α` assigns
  distinct colors to adjacent vertices.
* `SimpleGraph.numColorings G k` — the number of proper colorings with `Fin k` colors.
* `SimpleGraph.chromaticPolynomial G` — the chromatic polynomial via the Whitney rank
  formula (inclusion-exclusion over edge subsets).

## Main Results

* `SimpleGraph.eval_chromaticPolynomial` — the evaluation/counting specification.
* `SimpleGraph.chromaticPolynomial_bot` — for the edgeless graph, `χ_G(X) = X ^ n`.
-/

open Polynomial Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Proper colorings -/

/-- A coloring `c : V → α` is proper for graph `G` if adjacent vertices receive
distinct colors. -/
def IsProperColoring (G : SimpleGraph V) (c : V → α) : Prop :=
  ∀ ⦃u v : V⦄, G.Adj u v → c u ≠ c v

instance IsProperColoring.decidable (G : SimpleGraph V) [DecidableRel G.Adj]
    [DecidableEq α] (c : V → α) : Decidable (G.IsProperColoring c) :=
  Fintype.decidableForallFintype

/-- The number of proper colorings of `G` using `Fin k` colors. -/
noncomputable def numColorings (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) : ℕ :=
  Fintype.card { c : V → Fin k // G.IsProperColoring c }

/-! ### Equivalence with `SimpleGraph.Coloring` -/

/-- The type of proper colorings is equivalent to `G.Coloring α`. -/
noncomputable def properColoringEquivColoring (G : SimpleGraph V) [DecidableRel G.Adj]
    (α : Type*) [DecidableEq α] :
    { c : V → α // G.IsProperColoring c } ≃ G.Coloring α where
  toFun := fun ⟨c, hc⟩ => Coloring.mk c (fun h => hc h)
  invFun := fun C => ⟨C, fun {_} {_} h => C.valid h⟩
  left_inv := fun ⟨_, _⟩ => rfl
  right_inv := fun _ => rfl

/-- `numColorings` equals the cardinality of `G.Coloring (Fin k)`. -/
theorem numColorings_eq_card_coloring (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    G.numColorings k = Fintype.card (G.Coloring (Fin k)) :=
  Fintype.card_congr (G.properColoringEquivColoring (Fin k))

/-! ### Spanning subgraph from an edge set -/

/-- The spanning subgraph of `V` with exactly the edges in `edges`. -/
def spanningSubgraphOfEdges (edges : Finset (Sym2 V)) : SimpleGraph V where
  Adj u v := s(u, v) ∈ edges ∧ u ≠ v
  symm _ _ h := ⟨by rw [Sym2.eq_swap]; exact h.1, h.2.symm⟩
  loopless := ⟨fun _ h => h.2 rfl⟩

instance spanningSubgraphOfEdges_decidableAdj (edges : Finset (Sym2 V)) :
    DecidableRel (spanningSubgraphOfEdges edges).Adj :=
  fun _ _ => instDecidableAnd

/-- The number of connected components of the spanning subgraph with edge set `A`. -/
noncomputable def numComponentsOfEdges (A : Finset (Sym2 V)) : ℕ :=
  Fintype.card (spanningSubgraphOfEdges A).ConnectedComponent

/-! ### Chromatic Polynomial via Whitney rank formula -/

/-- The chromatic polynomial of `G`, defined via the Whitney rank formula
(inclusion-exclusion over edge subsets):
  `χ_G(X) = ∑_{A ⊆ E(G)} (-1)^|A| · X^{c(A)}`
where `c(A)` is the number of connected components of the spanning subgraph
with edge set `A`. This is a polynomial in `ℤ[X]` of degree `|V|`. -/
noncomputable def chromaticPolynomial (G : SimpleGraph V) [DecidableRel G.Adj] :
    Polynomial ℤ :=
  ∑ A ∈ G.edgeFinset.powerset,
    ((-1 : ℤ) ^ A.card) • (X : Polynomial ℤ) ^ numComponentsOfEdges A

/-! ### Basic evaluations -/

/-
For the edgeless graph (⊥), every function is a proper coloring.
-/
theorem numColorings_bot (k : ℕ) :
    (⊥ : SimpleGraph V).numColorings k = k ^ Fintype.card V := by
  simp +decide [ SimpleGraph.numColorings ];
  unfold SimpleGraph.IsProperColoring;
  simp +decide [ SimpleGraph.adj_comm ]

/-
The chromatic polynomial of the edgeless graph is `X ^ n` where `n = |V|`.
-/
theorem chromaticPolynomial_bot :
    (⊥ : SimpleGraph V).chromaticPolynomial = X ^ Fintype.card V := by
  unfold SimpleGraph.chromaticPolynomial;
  rw [ Finset.sum_eq_single ∅ ] <;> simp +contextual [ numComponentsOfEdges ];
  · fapply congr_arg _ _;
    nontriviality;
    refine' Fintype.card_congr _;
    symm;
    refine' Equiv.ofBijective ( fun v => ( spanningSubgraphOfEdges ∅ ).connectedComponentMk v ) ⟨ fun a b h => _, fun a => _ ⟩;
    · simp_all +decide [ SimpleGraph.connectedComponentMk ];
      erw [ Quot.eq ] at h;
      induction h <;> simp_all +decide [ spanningSubgraphOfEdges ];
      rename_i x y h; rcases h with ⟨ _ | ⟨ _, _, h ⟩ ⟩ ; tauto;
      · tauto;
      · tauto;
    · exact a.exists_rep;
  · grind +suggestions

/-! ### Fundamental evaluation theorem -/

/-
**Fundamental evaluation theorem**: The chromatic polynomial evaluated at `k` equals
the number of proper colorings with `k` colors. This is the core correctness
specification for the chromatic polynomial.

The proof uses inclusion-exclusion over edge subsets:
  `χ_G(k) = ∑_{A ⊆ E(G)} (-1)^|A| · k^{c(A)}`
where each `k^{c(A)}` counts functions constant on connected components of `(V,A)`,
and the alternating sum sifts exactly the proper colorings.
-/
-- !-- Lab Notebook -- !--
--
-- Hypothesis:  The previously-`sorry`'d evaluation theorem can be proved
--   *inline* (without the missing `Evaluation.lean`) by a single Fubini swap
--   plus a `Finset.prod_add` collapse of the alternating powerset sum.
--
-- Result:  Proved.  Three `have`s carry the argument: (`h_count`) a bijection
--   `{ f // f constant on components of (V,A) } ≃ (ConnectedComponent → Fin k)`
--   giving `k^{c(A)} = #{f agreeing on A}`; (`h_fubini`) the order swap; and
--   (`h_inner`) the per-`f` product `∏_{e} (1 + (-1)·[f agrees on e])`, which is
--   `1` iff `f` is a proper colouring.
--
-- Insight:  The connected-component count `c(A)` is exactly the number of
--   equivalence classes a colouring may collapse, so `k^{c(A)}` is a function
--   count over the quotient `ConnectedComponent`; this is the lemma that turns
--   the Whitney rank formula into a counting statement.
--
-- Failure analysis:  The proof needs more than the default heartbeat budget;
--   `set_option maxHeartbeats 1000000 in` is required for the final `convert`
--   chain to elaborate.
--
-- !-- The proof is inclusion–exclusion: `k^{c(A)}` counts functions constant on
-- components of `(V,A)`, then a Fubini swap and `Finset.prod_add` collapse the
-- signed powerset sum to the indicator of proper colourings. -- !--
set_option maxHeartbeats 1000000 in
theorem eval_chromaticPolynomial (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    Polynomial.eval (k : ℤ) G.chromaticPolynomial = ↑(G.numColorings k) := by
  -- Defined in Evaluation.lean; inline the key argument here.
  -- Step 1: eval distributes through the sum
  have h_eval : Polynomial.eval (k : ℤ) G.chromaticPolynomial =
      ∑ A ∈ G.edgeFinset.powerset,
        ((-1 : ℤ) ^ A.card) * (k : ℤ) ^ numComponentsOfEdges A := by
    unfold chromaticPolynomial; simp [Polynomial.eval_finset_sum]
  -- Step 2: Define AgreesOnEdges locally
  let agreesOn (f : V → Fin k) (A : Finset (Sym2 V)) : Prop :=
    ∀ e ∈ A, ∀ u v, e = s(u, v) → f u = f v
  -- Step 3: k^{c(A)} = card of functions agreeing on A
  -- Step 4: alternating sum = numColorings
  -- (Full proof is in Speculative.ChromaticPolynomial.Evaluation)
  -- We show that `k^(numComponentsOfEdges A)` counts the number of functions `f : V → Fin k` that agree on the initially dark edges `A`.
  have h_count : ∀ A : Finset (Sym2 V),
      let H := spanningSubgraphOfEdges A;
      let n := numComponentsOfEdges A;
      (k : ℤ) ^ n = Fintype.card { f : V → Fin k // ∀ u v, H.Adj u v → f u = f v } := by
        intro A
        let H := spanningSubgraphOfEdges A
        let n := numComponentsOfEdges A
        have h_bij : { f : V → Fin k // ∀ u v, H.Adj u v → f u = f v } ≃ (H.ConnectedComponent → Fin k) := by
          refine' Equiv.ofBijective ( fun f => fun c => f.val ( Classical.choose ( c.exists_rep ) ) ) ⟨ fun f g h => _, fun f => _ ⟩;
          · ext v;
            convert congr_fun h ( H.connectedComponentMk v ) using 1;
            have h_const : ∀ u v : V, H.Reachable u v → f.val u = f.val v ∧ g.val u = g.val v := by
              rintro u v ⟨ p ⟩;
              induction p <;> simp_all +decide [ SimpleGraph.Walk.cons ];
              grind +splitIndPred;
            have := Classical.choose_spec ( show ∃ u, H.connectedComponentMk u = H.connectedComponentMk v from ⟨ v, rfl ⟩ );
            grind +suggestions;
          · refine' ⟨ ⟨ fun v => f ( H.connectedComponentMk v ), _ ⟩, _ ⟩;
            intro u v huv
            have h_comp : H.connectedComponentMk u = H.connectedComponentMk v := by
              grind +suggestions
            simp [h_comp];
            all_goals generalize_proofs at *;
            ext c; exact (by
            have := Classical.choose_spec ( c.exists_rep );
            exact?);
        convert Fintype.card_congr h_bij |> Eq.symm using 1;
        simp +decide [ Fintype.card_pi ];
        norm_cast;
        convert Iff.rfl;
        convert Fintype.card_fun;
        all_goals try infer_instance;
        · simp +decide;
        · exact?;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * (Fintype.card { f : V → Fin k // ∀ u v, (spanningSubgraphOfEdges A).Adj u v → f u = f v }) = ∑ f : V → Fin k, ∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * (if ∀ e ∈ A, ∀ u v, e = s(u, v) → f u = f v then 1 else 0) := by
    rw [ Finset.sum_comm, Finset.sum_congr rfl ];
    simp +decide [ Fintype.card_subtype, Finset.sum_ite ];
    simp +decide [ mul_comm, spanningSubgraphOfEdges ];
    intro A hA; congr; ext f; simp +decide [ Sym2.forall ] ;
    grind;
  -- For each fixed function `f`, the inner sum evaluates to `1` if `f` is a proper coloring of `G` and `0` otherwise.
  have h_inner : ∀ f : V → Fin k, ∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * (if ∀ e ∈ A, ∀ u v, e = s(u, v) → f u = f v then 1 else 0) = if ∀ u v, G.Adj u v → f u ≠ f v then 1 else 0 := by
    intro f
    have h_inner_sum : ∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * (if ∀ e ∈ A, ∀ u v, e = s(u, v) → f u = f v then 1 else 0) = ∏ e ∈ G.edgeFinset, (1 + (-1 : ℤ) * (if ∀ u v, e = s(u, v) → f u = f v then 1 else 0)) := by
      simp +decide [ add_comm ( 1 : ℤ ), Finset.prod_add ];
      rw [ Finset.sum_congr rfl ] ; intros ; split_ifs <;> simp +decide [ *, Finset.prod_ite ];
      rw [ Finset.filter_true_of_mem ‹_›, Finset.filter_false_of_mem ] <;> simp +decide [ * ];
      assumption;
    split_ifs with h <;> simp +decide [ h_inner_sum, h ];
    · convert h_inner_sum using 1;
      · exact Finset.sum_congr rfl fun _ _ => by split_ifs <;> ring;
      · rw [ Finset.prod_eq_one ] ; simp +contextual [ h ];
        rintro ⟨ u, v ⟩ huv; exact ⟨ u, v, rfl, h u v <| by simpa using huv ⟩ ;
    · convert h_inner_sum using 1;
      · exact Finset.sum_congr rfl fun _ _ => by split_ifs <;> ring;
      · rw [ Finset.prod_eq_zero_iff.mpr ];
        simp +zetaDelta at *;
        obtain ⟨ u, v, huv, h ⟩ := h; use s(u, v); simp +decide [ huv, h ] ;
        grind;
  convert h_fubini using 1;
  · grind;
  · simp +decide only [numColorings, h_inner];
    simp +decide [ Fintype.card_subtype, SimpleGraph.IsProperColoring ]

end SimpleGraph