import Mathlib
import Speculative.ChromaticPolynomial.Defs
import Speculative.ChromaticPolynomial.Evaluation

/-!
# Chromatic Polynomial — Explicit Formulas for Graph Classes

Closed-form chromatic polynomials for fundamental graph classes,
serving both as correctness benchmarks and as building blocks for
recursive computations.

## Main Results

* `SimpleGraph.numColorings_completeGraph` — colorings of complete graphs
  equal falling factorials.
* `SimpleGraph.chromaticPolynomial_completeGraph` — `χ_{K_n}(X) = X(X-1)⋯(X-n+1)`.
-/

open Polynomial Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Single-edge graph -/

/-
For a graph with exactly one edge, the number of proper colorings with
`k` colors is `k^n - k^(n-1)`, where `n = |V|`. Equivalently, with 2 vertices
and 1 edge, it is `k(k-1)`.
-/
theorem numColorings_singleEdge (k : ℕ) :
    (⊤ : SimpleGraph (Fin 2)).numColorings k = k * (k - 1) := by
  -- By definition of the complete graph, a coloring is proper if and only if the two vertices have different colors.
  have h_bij : {c : Fin 2 → Fin k | c 0 ≠ c 1} ≃ {c : Fin 2 → Fin k // (⊤ : SimpleGraph (Fin 2)).IsProperColoring c} := by
    refine' Equiv.subtypeEquivRight _;
    exact fun x => ⟨ fun h => by intro u v huv; fin_cases u <;> fin_cases v <;> tauto, fun h => by simpa using h ( show ( ⊤ : SimpleGraph ( Fin 2 ) ).Adj 0 1 from by decide ) ⟩;
  convert Fintype.card_congr h_bij.symm;
  rcases k with ( _ | _ | k ) <;> simp_all +decide [ Finset.card_univ, Fintype.card_eq ];
  rw [ show Fintype.card { x : Fin 2 → Fin ( k + 2 ) // x 0 = x 1 } = k + 2 from ?_ ] ; rw [ Nat.sub_eq_of_eq_add ] ; ring;
  rw [ Fintype.card_of_subtype ];
  rotate_left;
  exact Finset.image ( fun x : Fin ( k + 2 ) => fun i => if i = 0 then x else x ) Finset.univ;
  · simp +decide [ funext_iff, Fin.forall_fin_two ];
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    exact fun a₁ a₂ h => congr_fun h 0

/-
The chromatic polynomial of `K_2` is `X(X-1)`.
-/
theorem chromaticPolynomial_completeGraph_two :
    (⊤ : SimpleGraph (Fin 2)).chromaticPolynomial =
      X * (X - 1 : Polynomial ℤ) := by
  -- Apply the evaluation theorem to conclude the proof.
  have h_eval : ∀ k : ℕ, Polynomial.eval (k : ℤ) (⊤ : SimpleGraph (Fin 2)).chromaticPolynomial = k * (k - 1) := by
    intro k
    have := SimpleGraph.eval_chromaticPolynomial' (⊤ : SimpleGraph (Fin 2)) k
    simp_all +decide [ SimpleGraph.numColorings_singleEdge ];
    grind;
  -- Since these two polynomials agree at infinitely many points, they must be equal.
  have h_poly_eq : Set.Infinite {k : ℤ | Polynomial.eval k (⊤ : SimpleGraph (Fin 2)).chromaticPolynomial = Polynomial.eval k (X * (X - 1))} := by
    exact Set.infinite_of_injective_forall_mem ( Nat.cast_injective ) fun k => by simpa using h_eval k;
  exact Classical.not_not.1 fun h => h_poly_eq <| Set.Finite.subset ( Polynomial.roots ( ( ⊤ : SimpleGraph ( Fin 2 ) ).chromaticPolynomial - X * ( X - 1 ) ) |> Multiset.toFinset |> Finset.finite_toSet ) fun x hx => by simp_all +decide [ sub_eq_iff_eq_add ] ;

/-! ### Complete graph colorings -/

/-
The number of proper colorings of the complete graph `K_n` with `k` colors
is the falling factorial `k · (k-1) · ⋯ · (k-n+1)`.
-/
theorem numColorings_completeGraph (n k : ℕ) :
    (⊤ : SimpleGraph (Fin n)).numColorings k = Nat.descFactorial k n := by
  -- The number of injective functions from Fin n to Fin k is equal to the descending factorial of k taken n times.
  have h_inj_card : Fintype.card { f : Fin n → Fin k // Function.Injective f } = Nat.descFactorial k n := by
    rw [ Fintype.card_of_subtype ];
    swap;
    exact Finset.image ( fun x : Fin n ↪ Fin k => x.toFun ) ( Finset.univ );
    · rw [ Finset.card_image_of_injective ];
      · simp +decide [ Finset.card_univ, Nat.descFactorial_eq_factorial_mul_choose ];
      · exact fun x y h => by simpa [ Fin.ext_iff ] using h;
    · exact fun x => ⟨ fun hx => by obtain ⟨ y, _, rfl ⟩ := Finset.mem_image.mp hx; exact y.injective, fun hx => Finset.mem_image.mpr ⟨ ⟨ x, hx ⟩, Finset.mem_univ _, rfl ⟩ ⟩;
  refine' h_inj_card ▸ Fintype.card_congr _;
  refine' Equiv.subtypeEquivRight _;
  intro f; simp +decide [ Function.Injective, SimpleGraph.IsProperColoring ] ;
  exact ⟨ fun h u v huv => Classical.not_not.1 fun huv' => h huv' huv, fun h u v huv => fun huv' => huv <| h huv' ⟩

/-
The chromatic polynomial of `K_n` is the falling factorial polynomial
`∏ i ∈ range n, (X - i)`.
-/
theorem chromaticPolynomial_completeGraph (n : ℕ) :
    (⊤ : SimpleGraph (Fin n)).chromaticPolynomial =
      ∏ i ∈ Finset.range n, (X - C (i : ℤ)) := by
  -- We'll use the fact that if the evaluation of two polynomials is equal at infinitely many points, then the polynomials are equal.
  have h_eval_eq : ∀ k : ℕ, (⊤ : SimpleGraph (Fin n)).numColorings k = (∏ i ∈ (Finset.range n), (k - i)) := by
    simp_all +decide [ SimpleGraph.numColorings_completeGraph, Nat.descFactorial_eq_prod_range ];
  refine' Polynomial.map_injective ( Int.castRingHom ℚ ) Int.cast_injective _;
  refine' Polynomial.eq_of_infinite_eval_eq _ _ _;
  refine Set.infinite_of_forall_exists_gt ?_;
  intro a;
  refine' ⟨ ⌊a⌋₊ + n + 1, _, _ ⟩ <;> norm_num;
  · convert congr_arg ( ( ↑ ) : ℕ → ℚ ) ( h_eval_eq ( ⌊a⌋₊ + n + 1 ) ) using 1;
    · convert congr_arg ( ( ↑ ) : ℤ → ℚ ) ( eval_chromaticPolynomial' ( ⊤ : SimpleGraph ( Fin n ) ) ( ⌊a⌋₊ + n + 1 ) ) using 1;
      simp +decide [ Polynomial.eval_map ];
      norm_num [ Polynomial.eval₂_eq_sum_range, Polynomial.eval_eq_sum_range ];
    · simp +decide [ Polynomial.map_prod, Polynomial.eval_prod ];
      exact Finset.prod_congr rfl fun x hx => by rw [ Nat.cast_sub ] <;> push_cast <;> linarith [ Finset.mem_range.mp hx ] ;
  · linarith [ Nat.lt_floor_add_one a ]

/-! ### Edgeless graph (reproved from Defs for completeness) -/

/-
The edgeless graph on `n` vertices has chromatic polynomial `X^n`.
-/
theorem chromaticPolynomial_edgeless (n : ℕ) :
    (⊥ : SimpleGraph (Fin n)).chromaticPolynomial =
      (X : Polynomial ℤ) ^ n := by
  convert chromaticPolynomial_bot;
  rw [ Fintype.card_fin ]

end SimpleGraph