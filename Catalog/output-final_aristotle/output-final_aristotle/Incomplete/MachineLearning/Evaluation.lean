import Mathlib
import Logic.Defs

/-!
# Chromatic Polynomial — Evaluation Theorem

This file proves the fundamental evaluation theorem: the chromatic polynomial
evaluated at a natural number `k` equals the number of proper colorings
with `k` colors.

The proof proceeds via inclusion-exclusion over the edge set.
-/

open Polynomial Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Step 1: Polynomial evaluation simplification -/

/-- Evaluating the chromatic polynomial at `k` gives the inclusion-exclusion sum. -/
theorem eval_chromaticPolynomial_eq_sum (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    Polynomial.eval (k : ℤ) G.chromaticPolynomial =
      ∑ A ∈ G.edgeFinset.powerset,
        ((-1 : ℤ) ^ A.card) * (k : ℤ) ^ numComponentsOfEdges A := by
  unfold chromaticPolynomial
  simp [Polynomial.eval_finset_sum]

/-! ### Step 2: Counting functions constant on components -/

/-- The set of functions `V → α` that are constant on connected components
of a graph `H` is in bijection with functions from the components to `α`. -/
noncomputable def constOnComponentsEquiv (H : SimpleGraph V) [DecidableRel H.Adj]
    (α : Type*) :
    { f : V → α // ∀ u v, H.Reachable u v → f u = f v } ≃
      (H.ConnectedComponent → α) where
  toFun := fun ⟨f, hf⟩ => Quot.lift f (fun a b h => hf a b h)
  invFun := fun g => ⟨fun v => g (H.connectedComponentMk v),
    fun u v h => by
      show g (H.connectedComponentMk u) = g (H.connectedComponentMk v)
      congr 1; exact Quot.sound h⟩
  left_inv := fun ⟨f, hf⟩ => by ext v; rfl
  right_inv := fun g => by ext c; exact Quot.inductionOn c (fun v => rfl)

/-
The number of functions `V → Fin k` constant on connected components
of graph `H` equals `k ^ (number of components)`.
-/
theorem card_constOnComponents (H : SimpleGraph V) [DecidableRel H.Adj] (k : ℕ) :
    Fintype.card { f : V → Fin k // ∀ u v, H.Reachable u v → f u = f v } =
      k ^ Fintype.card H.ConnectedComponent := by
  convert Fintype.card_congr ( constOnComponentsEquiv H ( Fin k ) ) using 1;
  convert Fintype.card_fun;
  convert rfl;
  rotate_left;
  convert Fintype.card_fun;
  all_goals try infer_instance;
  exact?;
  exact?;
  simp +decide [ Fintype.card_fun ]

/-! ### Step 3: Agreement sets and edge compatibility -/

/-- A function `f : V → α` "agrees on" an edge set `A` if for every edge
`{u,v} ∈ A`, we have `f u = f v`. -/
def AgreesOnEdges (f : V → α) (A : Finset (Sym2 V)) : Prop :=
  ∀ e ∈ A, ∀ u v, e = s(u, v) → f u = f v

instance AgreesOnEdges.decidable [DecidableEq α] (f : V → α) (A : Finset (Sym2 V)) :
    Decidable (AgreesOnEdges f A) :=
  Fintype.decidableForallFintype

/-- A function agrees on edges of `A` iff it's constant on connected components
of the spanning subgraph with edge set `A`. -/
theorem agreesOnEdges_iff_constOnComponents (f : V → α) (A : Finset (Sym2 V)) :
    AgreesOnEdges f A ↔
      ∀ u v, (spanningSubgraphOfEdges A).Reachable u v → f u = f v := by
  constructor
  · intro h u v huv
    induction huv
    induction' ‹_› with u v w huv ih
    · grind
    · have := h (s(v, w)) ih.1 v w rfl; aesop
  · intro h he
    rintro heA u v rfl
    by_cases huv : u = v
    · rw [huv]
    · exact h u v (SimpleGraph.Adj.reachable (by exact ⟨heA, huv⟩))

/-- The number of functions `V → Fin k` that agree on edge set `A` equals
`k ^ c(A)` where `c(A)` is the number of connected components. -/
theorem card_agreesOnEdges (A : Finset (Sym2 V)) (k : ℕ) :
    Fintype.card { f : V → Fin k // AgreesOnEdges f A } =
      k ^ numComponentsOfEdges A := by
  have h_card : Fintype.card { f : V → Fin k //
      ∀ u v, (spanningSubgraphOfEdges A).Reachable u v → f u = f v } =
      k ^ numComponentsOfEdges A := by
    convert card_constOnComponents (spanningSubgraphOfEdges A) k using 1
  convert h_card using 2
  exact congr_arg _ (by ext; exact agreesOnEdges_iff_constOnComponents _ _)

/-! ### Step 4: Inclusion-exclusion -/

/-
Auxiliary: alternating sum over subsets of a nonempty finite set is zero.
-/
theorem alternating_sum_powerset_eq_zero {S : Finset (Sym2 V)} (hS : S.Nonempty) :
    ∑ A ∈ S.powerset, ((-1 : ℤ) ^ A.card) = 0 := by
  grind +suggestions

/-
The inclusion-exclusion identity for proper colorings:
the number of proper colorings equals the alternating sum over edge subsets
of the number of functions agreeing on each subset. This is proved
independently of the chromatic polynomial definition (no circular dependency).
-/
theorem numColorings_eq_incl_excl (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    (G.numColorings k : ℤ) =
      ∑ A ∈ G.edgeFinset.powerset,
        ((-1 : ℤ) ^ A.card) *
          ↑(Fintype.card { f : V → Fin k // AgreesOnEdges f A }) := by
  -- For each function `f`, the inner sum is zero unless `f` is a proper coloring.
  have h_inner : ∀ f : V → Fin k, (∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * if AgreesOnEdges f A then 1 else 0) = if G.IsProperColoring f then 1 else 0 := by
    intro f;
    by_cases h : G.IsProperColoring f <;> simp +decide [ h ];
    · -- Since $f$ is a proper coloring, for any edge $e \in G$, $f$ does not agree on $e$.
      have h_not_agree : ∀ e ∈ G.edgeFinset, ¬AgreesOnEdges f {e} := by
        intro e he
        simp [AgreesOnEdges];
        rcases e with ⟨ u, v ⟩ ; use u, v; aesop;
      rw [ Finset.sum_eq_single ∅ ] <;> simp_all +decide [ Finset.subset_iff ];
      · exact fun e he => by contradiction;
      · intro b hb hb'; obtain ⟨ e, he ⟩ := Finset.nonempty_of_ne_empty hb'; specialize h_not_agree e ( hb he ) ; simp_all +decide [ AgreesOnEdges ] ;
        grind;
    · -- Let $S(f)$ be the set of edges on which $f$ agrees.
      set S := Finset.filter (fun e => ∃ u v, e = s(u, v) ∧ f u = f v) G.edgeFinset with hS_def;
      -- The set of subsets of $E(G)$ on which $f$ agrees is exactly the powerset of $S$.
      have h_powerset : Finset.filter (fun A => AgreesOnEdges f A) (Finset.powerset G.edgeFinset) = Finset.powerset S := by
        ext A; simp [hS_def, AgreesOnEdges];
        constructor <;> intro hA <;> simp_all +decide [ Finset.subset_iff ];
        · exact fun e he => by rcases e with ⟨ u, v ⟩ ; exact ⟨ u, v, rfl, hA.2 _ he _ _ rfl ⟩ ;
        · grind;
      rw [ ← Finset.sum_filter, h_powerset, alternating_sum_powerset_eq_zero ];
      contrapose! h; simp_all +decide [ SimpleGraph.IsProperColoring ] ;
      intro u v huv; replace hS_def := Finset.ext_iff.mp hS_def ( s(u, v) ) ; aesop;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * (Fintype.card { f : V → Fin k // AgreesOnEdges f A }) = ∑ f : V → Fin k, (∑ A ∈ G.edgeFinset.powerset, (-1 : ℤ) ^ A.card * if AgreesOnEdges f A then 1 else 0) := by
    rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; intros ; rw [ Fintype.card_subtype ] ; simp +decide [ Finset.sum_ite ] ; ring;
  simp_all +decide [ Fintype.card_subtype ];
  exact Fintype.card_subtype _

/-! ### Main theorem assembly -/

/-- **Fundamental evaluation theorem**: The chromatic polynomial evaluated at `k`
equals the number of proper colorings with `k` colors. -/
theorem eval_chromaticPolynomial' (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) :
    Polynomial.eval (k : ℤ) G.chromaticPolynomial = ↑(G.numColorings k) := by
  rw [eval_chromaticPolynomial_eq_sum, numColorings_eq_incl_excl]
  apply Finset.sum_congr rfl
  intro A hA
  simp only [card_agreesOnEdges, Nat.cast_pow]

end SimpleGraph