/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.ReedMuller.Defs

/-!
# Extremal Polynomial Construction for Generalized Reed–Muller Codes

This file constructs the extremal polynomial that achieves the minimum weight
of the generalized Reed–Muller code.

## Main results

- `GRM.extremal_poly_exists`: existence of a nonzero polynomial of degree ≤ d with
  Hamming weight exactly `(q - b) * q^(n-1-a)`.
-/

open MvPolynomial Finset BigOperators Fintype

namespace GRM

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-! ### Univariate factor: product of (X_i - c) for c in a set -/

/-- A univariate-in-coordinate-i factor: ∏_{c ∈ s} (X_i - C c). -/
noncomputable def coordProd {n : ℕ} (i : Fin n) (s : Finset 𝔽) :
    MvPolynomial (Fin n) 𝔽 :=
  ∏ c ∈ s, (X i - C c)

/-- Evaluation of coordProd: equals ∏_{c ∈ s} (x i - c). -/
theorem eval_coordProd {n : ℕ} (i : Fin n) (s : Finset 𝔽)
    (x : Fin n → 𝔽) :
    eval x (coordProd i s) = ∏ c ∈ s, (x i - c) := by
  unfold coordProd;
  simp +decide [ eval_prod, sub_eq_add_neg ]

/-- coordProd vanishes at x iff x i ∈ s. -/
theorem eval_coordProd_eq_zero_iff {n : ℕ} (i : Fin n) (s : Finset 𝔽)
    (x : Fin n → 𝔽) :
    eval x (coordProd i s) = 0 ↔ x i ∈ s := by
  simp +decide [ eval_coordProd, Finset.prod_eq_zero_iff, sub_eq_zero ]

/-- coordProd is nonzero as a polynomial. -/
theorem coordProd_ne_zero {n : ℕ} (i : Fin n) (s : Finset 𝔽) :
    coordProd i s ≠ (0 : MvPolynomial (Fin n) 𝔽) := by
  exact Finset.prod_ne_zero_iff.mpr fun c _ => ne_of_apply_ne ( MvPolynomial.eval ( fun _ => c + 1 ) ) ( by simp +decide )

/-- Total degree of coordProd is at most |s|. -/
theorem totalDegree_coordProd_le {n : ℕ} (i : Fin n) (s : Finset 𝔽) :
    (coordProd i s).totalDegree ≤ s.card := by
  unfold coordProd
  calc (∏ c ∈ s, (X i - C c : MvPolynomial (Fin n) 𝔽)).totalDegree
      ≤ ∑ c ∈ s, (X i - C c : MvPolynomial (Fin n) 𝔽).totalDegree :=
        MvPolynomial.totalDegree_finset_prod s _
    _ ≤ ∑ _c ∈ s, 1 := Finset.sum_le_sum fun c _ =>
        le_trans (MvPolynomial.totalDegree_sub _ _) (by simp [MvPolynomial.totalDegree_X])
    _ = s.card := by simp

/-! ### Full coordinate vanishing factor -/

/-- The "full coordinate vanishing" factor for coordinate i:
    ∏_{c ∈ 𝔽 \ {α}} (X_i - c), which has degree q-1 and vanishes
    at x iff x i ≠ α. -/
noncomputable def fullCoordFactor {n : ℕ} (i : Fin n) (α : 𝔽) :
    MvPolynomial (Fin n) 𝔽 :=
  coordProd i (Finset.univ.erase α)

/-- fullCoordFactor vanishes at x iff x i ≠ α. -/
theorem eval_fullCoordFactor_eq_zero_iff {n : ℕ} (i : Fin n) (α : 𝔽)
    (x : Fin n → 𝔽) :
    eval x (fullCoordFactor i α) = 0 ↔ x i ≠ α := by
  convert eval_coordProd_eq_zero_iff i ( Finset.univ.erase α ) x using 1;
  simp +decide

/-- fullCoordFactor is nonzero at x when x i = α. -/
theorem eval_fullCoordFactor_ne_zero {n : ℕ} (i : Fin n) (α : 𝔽)
    (x : Fin n → 𝔽) (hx : x i = α) :
    eval x (fullCoordFactor i α) ≠ 0 := by
  simp only [ne_eq, eval_fullCoordFactor_eq_zero_iff]
  exact not_not.mpr hx

/-- The degree of fullCoordFactor is at most q-1. -/
theorem totalDegree_fullCoordFactor_le {n : ℕ} (i : Fin n) (α : 𝔽) :
    (fullCoordFactor i α).totalDegree ≤ card 𝔽 - 1 := by
  exact totalDegree_coordProd_le i ( Finset.univ.erase α ) |> le_trans <| by simp +decide ;

/-! ### Existence of subsets of given cardinality -/

/-
Any fintype with at least k elements has a k-element subset.
-/
theorem exists_finset_card_eq (k : ℕ) (hk : k ≤ card 𝔽) :
    ∃ s : Finset 𝔽, s.card = k := by
  obtain ⟨s, hs⟩ := Finset.exists_subset_card_eq hk; exact ⟨s, hs.2⟩;

/-! ### Support counting for product polynomials -/

/-- Product of fullCoordFactors over Fin a: the polynomial ∏_{i < a} fullCoordFactor(i, α). -/
noncomputable def fullCoordProd {n : ℕ} (a : ℕ) (ha : a ≤ n) (α : 𝔽) :
    MvPolynomial (Fin n) 𝔽 :=
  ∏ i : Fin a, fullCoordFactor (⟨i.val, by omega⟩ : Fin n) α

/-
fullCoordProd vanishes at x iff some coordinate i < a has x i ≠ α.
-/
theorem eval_fullCoordProd_eq_zero_iff {n : ℕ} (a : ℕ) (ha : a ≤ n) (α : 𝔽)
    (x : Fin n → 𝔽) :
    eval x (fullCoordProd a ha α) = 0 ↔ ∃ i : Fin a, x ⟨i.val, by omega⟩ ≠ α := by
  rw [ fullCoordProd, eval_prod ];
  simp +decide [ Finset.prod_eq_zero_iff, eval_fullCoordFactor_eq_zero_iff ]

/-
fullCoordProd is nonzero at x when all coordinates i < a have x i = α.
-/
theorem eval_fullCoordProd_ne_zero {n : ℕ} (a : ℕ) (ha : a ≤ n) (α : 𝔽)
    (x : Fin n → 𝔽) (hx : ∀ i : Fin a, x ⟨i.val, by omega⟩ = α) :
    eval x (fullCoordProd a ha α) ≠ 0 := by
  exact fun h => by have := eval_fullCoordProd_eq_zero_iff a ha α x; aesop;

/-
The total degree of fullCoordProd is at most a*(q-1).
-/
theorem totalDegree_fullCoordProd_le {n : ℕ} (a : ℕ) (ha : a ≤ n) (α : 𝔽) :
    (fullCoordProd a ha α).totalDegree ≤ a * (card 𝔽 - 1) := by
  -- Use MvPolynomial.totalDegree_finset_prod to get ≤ sum of individual degrees.
  have h_prod_deg : (fullCoordProd a ha α).totalDegree ≤ ∑ i : Fin a, (fullCoordFactor (⟨i.val, by omega⟩ : Fin n) α).totalDegree := by
    -- Apply the lemma that the total degree of a product of polynomials is less than or equal to the sum of their total degrees.
    have h_total_degree_mul : ∀ (p q : MvPolynomial (Fin n) 𝔽), (p * q).totalDegree ≤ p.totalDegree + q.totalDegree := by
      exact?;
    -- Apply the lemma that the total degree of a product of polynomials is less than or equal to the sum of their total degrees iteratively.
    have h_total_degree_prod_iter : ∀ (l : List (MvPolynomial (Fin n) 𝔽)), (List.prod l).totalDegree ≤ List.sum (List.map (fun p => p.totalDegree) l) := by
      intro l
      induction' l with p l ih;
      · simp +decide;
      · grind +revert;
    convert h_total_degree_prod_iter ( List.map ( fun i : Fin a => fullCoordFactor ( ⟨ i.val, by omega ⟩ : Fin n ) α ) ( List.finRange a ) ) using 1;
    simp +decide [ Finset.sum ];
    exact congr_arg _ ( by rw [ List.ofFn_eq_map ] ; rfl );
  exact h_prod_deg.trans <| le_trans ( Finset.sum_le_sum fun _ _ => totalDegree_fullCoordFactor_le _ _ ) <| by simp +decide ;

/-
fullCoordProd is nonzero as a polynomial.
-/
theorem fullCoordProd_ne_zero {n : ℕ} (a : ℕ) (ha : a ≤ n) (α : 𝔽) :
    fullCoordProd a ha α ≠ 0 := by
  exact Finset.prod_ne_zero_iff.mpr fun i _ => coordProd_ne_zero _ _

/-! ### The extremal polynomial and its properties -/

/-- The extremal polynomial: product of a full coordinate factors and
    a partial factor in one additional coordinate.
    f = fullCoordProd(a, α) * coordProd(a, T) -/
noncomputable def extremalPoly {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) : MvPolynomial (Fin n) 𝔽 :=
  fullCoordProd a (le_of_lt ha) α * coordProd ⟨a, ha⟩ T

/-
The extremal polynomial is nonzero.
-/
theorem extremalPoly_ne_zero {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) :
    extremalPoly a ha α T ≠ (0 : MvPolynomial (Fin n) 𝔽) := by
  exact mul_ne_zero ( fullCoordProd_ne_zero a ( le_of_lt ha ) α ) ( coordProd_ne_zero _ _ )

/-
The total degree of the extremal polynomial is at most a*(q-1) + |T|.
-/
theorem totalDegree_extremalPoly_le {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) :
    (extremalPoly a ha α T).totalDegree ≤ a * (card 𝔽 - 1) + T.card := by
  exact le_trans ( MvPolynomial.totalDegree_mul _ _ ) ( add_le_add ( totalDegree_fullCoordProd_le a ( le_of_lt ha ) α ) ( totalDegree_coordProd_le _ _ ) )

/-
The extremal polynomial vanishes at x iff
    some coordinate i < a has x i ≠ α, or x a ∈ T.
-/
theorem eval_extremalPoly_eq_zero_iff {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) (x : Fin n → 𝔽) :
    eval x (extremalPoly a ha α T) = 0 ↔
      (∃ i : Fin a, x ⟨i.val, by omega⟩ ≠ α) ∨ x ⟨a, ha⟩ ∈ T := by
  unfold extremalPoly;
  simp_all +decide [ ← not_and_or, MvPolynomial.eval_prod, eval_coordProd_eq_zero_iff, eval_fullCoordProd_eq_zero_iff ]

/-
The support set: the extremal polynomial is nonzero at x iff
    all coordinates i < a have x i = α, and x a ∉ T.
-/
theorem eval_extremalPoly_ne_zero_iff {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) (x : Fin n → 𝔽) :
    eval x (extremalPoly a ha α T) ≠ 0 ↔
      (∀ i : Fin a, x ⟨i.val, by omega⟩ = α) ∧ x ⟨a, ha⟩ ∉ T := by
  convert eval_extremalPoly_eq_zero_iff a ha α T x |> Iff.not using 1 ; aesop

/-
**Key cardinality lemma**: The number of functions x : Fin n → 𝔽 satisfying
    (∀ i < a, x i = α) ∧ (x a ∉ T) is (q - |T|) * q^(n-1-a).
-/
theorem card_support_set {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) (hT : T.card ≤ card 𝔽) :
    (Finset.univ.filter (fun x : Fin n → 𝔽 =>
      (∀ i : Fin a, x ⟨i.val, by omega⟩ = α) ∧ x ⟨a, ha⟩ ∉ T)).card =
    (card 𝔽 - T.card) * (card 𝔽) ^ (n - 1 - a) := by
  have h_finset_card : (Finset.univ.filter (fun x : Fin n → 𝔽 => (∀ i : Fin a, x ⟨i, by omega⟩ = α) ∧ x ⟨a, ha⟩ ∉ T)).card = (Finset.univ.filter (fun x : Fin (a + 1) → 𝔽 => (∀ i : Fin a, x ⟨i, by omega⟩ = α) ∧ x ⟨a, by omega⟩ ∉ T)).card * (Finset.univ : Finset (Fin (n - 1 - a) → 𝔽)).card := by
    nontriviality;
    convert Set.ncard_image_of_injective _ ( show Function.Injective ( fun x : { x : Fin ( a + 1 ) → 𝔽 // ( ∀ i : Fin a, x ⟨ i, by omega ⟩ = α ) ∧ x ⟨ a, by omega ⟩ ∉ T } × ( Fin ( n - 1 - a ) → 𝔽 ) => fun i : Fin n => if hi : i.val < a + 1 then x.1.val ⟨ i.val, by omega ⟩ else x.2 ⟨ i.val - ( a + 1 ), by omega ⟩ ) from ?_ ) using 1;
    any_goals exact Set.univ;
    · rw [ ← Set.ncard_coe_finset ];
      congr with x;
      constructor;
      · intro hx;
        refine' ⟨ ⟨ ⟨ fun i => x ⟨ i, by omega ⟩, _, _ ⟩, fun i => x ⟨ i + a + 1, by omega ⟩ ⟩, Set.mem_univ _, _ ⟩ <;> simp_all +decide [ Fin.ext_iff ];
        grind;
      · grind;
    · simp +decide [ Set.ncard_univ, Fintype.card_subtype ];
    · intro x y hxy;
      ext i;
      · simpa [ i.2 ] using congr_fun hxy ⟨ i, by linarith [ Fin.is_lt i ] ⟩;
      · convert congr_fun hxy ⟨ a + 1 + i, by omega ⟩ using 1 <;> simp +decide [ Fin.ext_iff ];
        · exact fun h => False.elim <| by linarith [ Fin.is_lt i ] ;
        · grind;
  have h_finset_card : (Finset.univ.filter (fun x : Fin (a + 1) → 𝔽 => (∀ i : Fin a, x ⟨i, by omega⟩ = α) ∧ x ⟨a, by omega⟩ ∉ T)).card = (Finset.univ.filter (fun x : 𝔽 => x ∉ T)).card := by
    refine' Finset.card_bij ( fun x hx => x ⟨ a, by omega ⟩ ) _ _ _ <;> simp +decide;
    · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h; ext i; induction i using Fin.lastCases <;> simp_all +decide ;
      · exact h;
      · exact ha₁ _ ▸ ha₃ _ ▸ rfl;
    · intro b hb;
      refine' ⟨ fun i => if i.val < a then α else b, _, _ ⟩ <;> simp +decide [ hb ];
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff ]

/-
The Hamming weight of the extremal polynomial is (q - |T|) * q^(n-1-a).
-/
theorem hammingWeight_extremalPoly {n : ℕ} (a : ℕ) (ha : a < n)
    (α : 𝔽) (T : Finset 𝔽) (hT : T.card ≤ card 𝔽) :
    hammingWeight (extremalPoly a ha α T) =
      (card 𝔽 - T.card) * (card 𝔽) ^ (n - 1 - a) := by
  convert card_support_set a ha α T hT using 1;
  exact congr_arg _ ( Finset.filter_congr fun x _ => eval_extremalPoly_ne_zero_iff a ha α T x )

/-! ### Main existence theorem -/

/-- **Generalized Reed–Muller upper bound**: Given d = a*(q-1) + b with b < q-1 and a < n,
    there exists a nonzero polynomial of degree ≤ d with Hamming weight
    exactly (q-b) * q^(n-1-a). This establishes the upper bound on the
    minimum distance of the generalized Reed–Muller code. -/
theorem extremal_poly_exists
    (n d a b : ℕ)
    (hq : 1 < card 𝔽)
    (h_decomp : d = a * (card 𝔽 - 1) + b)
    (hb : b < card 𝔽 - 1)
    (ha : a < n) :
    ∃ f : MvPolynomial (Fin n) 𝔽,
      f ≠ 0 ∧
      f.totalDegree ≤ d ∧
      hammingWeight f = (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a) := by
  obtain ⟨T, hT⟩ := exists_finset_card_eq (𝔽 := 𝔽) b (by omega)
  exact ⟨extremalPoly a ha 0 T,
    extremalPoly_ne_zero a ha 0 T,
    by rw [h_decomp]; exact totalDegree_extremalPoly_le a ha 0 T |>.trans (by rw [hT]),
    by rw [hammingWeight_extremalPoly a ha 0 T (by omega), hT]⟩

end GRM