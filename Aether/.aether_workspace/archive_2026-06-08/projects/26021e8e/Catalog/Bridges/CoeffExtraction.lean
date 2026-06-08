/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Coefficient Extraction and the Combinatorial Nullstellensatz

This file formalizes the **coefficient extraction identity** for univariate polynomials
over a field, and derives the Combinatorial Nullstellensatz as a corollary.

## Main results

* `CoeffExtraction.lagrangeDen_ne_zero` : The Lagrange denominator is nonzero for elements
  of a Finset.
* `CoeffExtraction.gridPoly_dvd_of_roots` : The vanishing polynomial divides any polynomial that
  vanishes on the entire set.
* `CoeffExtraction.coeff_eq_sum_eval_div_lagrangeDen` : **The Univariate Coefficient Extraction
  Theorem.** For `p` with `natDegree p < |S|`:
  `p.coeff (|S| - 1) = ∑ s ∈ S, p.eval s * (lagrangeDen S s)⁻¹`
* `CoeffExtraction.exists_eval_ne_zero_of_coeff_ne_zero_univ` : **Univariate Combinatorial
  Nullstellensatz.** Nonzero top coefficient implies a nonzero evaluation in `S`.
* `CoeffExtraction.exists_eval_ne_zero_mv` : **Multivariate Combinatorial Nullstellensatz.**
  Nonzero grid evaluation existence from nonzero top monomial coefficient.

## References

* N. Alon, "Combinatorial Nullstellensatz", Combin. Probab. Comput. 8 (1999), 7–29.

## Tags

combinatorial nullstellensatz, coefficient extraction, Lagrange interpolation, polynomial method
-/

import Mathlib

open Polynomial Finset BigOperators

namespace CoeffExtraction

variable {K : Type*} [Field K] [DecidableEq K]

/-! ## §1. Lagrange denominator -/

/-- The Lagrange denominator at `x` with respect to a set `S`:
  `lagrangeDen S x = ∏ y ∈ S.erase x, (x - y)` -/
noncomputable def lagrangeDen (S : Finset K) (x : K) : K :=
  ∏ y ∈ S.erase x, (x - y)

/-- The Lagrange denominator is nonzero when `x ∈ S`, because all elements of a
`Finset` are distinct. -/
theorem lagrangeDen_ne_zero {S : Finset K} {x : K} (hx : x ∈ S) :
    lagrangeDen S x ≠ 0 := by
  unfold lagrangeDen
  apply Finset.prod_ne_zero_iff.mpr
  intro y hy
  rw [Finset.mem_erase] at hy
  exact sub_ne_zero.mpr (Ne.symm hy.1)

/-! ## §2. Grid polynomial (vanishing polynomial) -/

/-- The vanishing polynomial of a finite set `S`:
  `gridPoly S = ∏ s ∈ S, (X - C s)` -/
noncomputable def gridPoly (S : Finset K) : Polynomial K :=
  ∏ s ∈ S, (X - C s)

omit [DecidableEq K] in
theorem eval_gridPoly (S : Finset K) (x : K) :
    (gridPoly S).eval x = ∏ s ∈ S, (x - s) := by
  simp [gridPoly, eval_prod, eval_sub, eval_X, eval_C]

/-
If a polynomial vanishes on all elements of `S`, then `∏_{s ∈ S} (X - s)` divides it.
-/
theorem gridPoly_dvd_of_roots {S : Finset K} {p : Polynomial K}
    (h : ∀ s ∈ S, p.IsRoot s) : gridPoly S ∣ p := by
  -- Apply the fact that if a polynomial divides another polynomial for each element in a finite set, then the product of the polynomials divides the second polynomial.
  apply Finset.prod_dvd_of_coprime;
  · intro x Sx y Sy hxy; exact Polynomial.irreducible_X_sub_C _ |> fun hx => hx.coprime_iff_not_dvd.2 fun H => hxy <| by simpa [ sub_eq_iff_eq_add ] using Polynomial.dvd_iff_isRoot.1 H;
  · exact fun s hs => Polynomial.dvd_iff_isRoot.mpr ( h s hs )

/-! ## §3. Lagrange basis coefficient -/

/-
The leading coefficient of `Lagrange.basisDivisor a b` is `(a - b)⁻¹`.
-/
theorem leadingCoeff_basisDivisor {a b : K} (h : a ≠ b) :
    (Lagrange.basisDivisor a b).leadingCoeff = (a - b)⁻¹ := by
  simp +decide [ Lagrange.basisDivisor ]

/-
The natDegree of `Lagrange.basisDivisor a b` is 1 when `a ≠ b`.
-/
theorem natDegree_basisDivisor {a b : K} (h : a ≠ b) :
    (Lagrange.basisDivisor a b).natDegree = 1 := by
  unfold Lagrange.basisDivisor;
  rw [ Polynomial.natDegree_C_mul, Polynomial.natDegree_X_sub_C ] ; simp +decide [ sub_ne_zero.mpr h ]

/-
The leading coefficient of `Lagrange.basis S id s` for `s ∈ S` is
  `(lagrangeDen S s)⁻¹ = (∏_{t ∈ S.erase s} (s - t))⁻¹`.
-/
theorem leadingCoeff_basis {S : Finset K} {s : K} (hs : s ∈ S) :
    (Lagrange.basis S id s).leadingCoeff = (lagrangeDen S s)⁻¹ := by
  unfold Lagrange.basis;
  simp +decide [ Finset.prod_apply, Polynomial.leadingCoeff_prod, Lagrange.basisDivisor ];
  rfl

/-
The natDegree of `Lagrange.basis S id s` for `s ∈ S` is `|S| - 1`.
-/
theorem natDegree_basis {S : Finset K} {s : K} (hs : s ∈ S) :
    (Lagrange.basis S id s).natDegree = S.card - 1 := by
  simp +decide [ Lagrange.basis, Polynomial.natDegree_prod', hs ];
  rw [ Polynomial.natDegree_prod, Finset.sum_congr rfl fun x hx => natDegree_basisDivisor ( by aesop ) ];
  · aesop;
  · exact fun x hx => mul_ne_zero ( Polynomial.C_ne_zero.mpr <| inv_ne_zero <| sub_ne_zero.mpr <| by aesop ) <| Polynomial.X_sub_C_ne_zero _

/-- For `s ∈ S`, the coefficient of `X^{|S|-1}` in `Lagrange.basis S id s`
  is `(lagrangeDen S s)⁻¹`. -/
theorem coeff_top_basis {S : Finset K} {s : K} (hs : s ∈ S) :
    (Lagrange.basis S id s).coeff (S.card - 1) = (lagrangeDen S s)⁻¹ := by
  rw [← natDegree_basis hs, ← Polynomial.leadingCoeff, leadingCoeff_basis hs]

/-! ## §4. Univariate coefficient extraction -/

/-
**Univariate Coefficient Extraction Theorem.**
For a polynomial `p` with `p.natDegree < |S|`, the coefficient of `X^{|S|-1}` equals
the weighted sum of evaluations divided by Lagrange denominators:

  `p.coeff (|S| - 1) = ∑ s ∈ S, p.eval s * (lagrangeDen S s)⁻¹`

This is the algebraic engine behind the Combinatorial Nullstellensatz.
-/
theorem coeff_eq_sum_eval_div_lagrangeDen
    (S : Finset K) (hS : S.Nonempty)
    (p : Polynomial K)
    (hdeg : p.natDegree < S.card) :
    p.coeff (S.card - 1) =
      ∑ s ∈ S, p.eval s * (lagrangeDen S s)⁻¹ := by
  -- By Lagrange interpolation uniqueness (Lagrange.eq_interpolate_of_eval_eq), since p has degree < |S| (from hdeg : p.natDegree < S.card, use Polynomial.degree_lt_iff or natDegree_lt_iff) and evaluates to p.eval s at each s ∈ S, we get p = Lagrange.interpolate S id (fun s => p.eval s).
  have h_interpolate : p = Lagrange.interpolate S id (fun s => p.eval s) := by
    convert Lagrange.eq_interpolate_of_eval_eq _ _ _;
    any_goals assumption;
    rotate_left;
    exact id;
    exact fun s => p.eval s;
    · exact Set.injOn_id _;
    · exact lt_of_le_of_lt ( Polynomial.degree_le_natDegree ) ( WithBot.coe_lt_coe.mpr hdeg );
    · aesop;
  conv_lhs => rw [ h_interpolate, Lagrange.interpolate_apply ];
  rw [ Polynomial.finset_sum_coeff, Finset.sum_congr rfl ];
  intro x hx;
  rw [ Polynomial.coeff_C_mul, ← coeff_top_basis hx ]

/-! ## §5. Univariate Nullstellensatz -/

/-
**Univariate Combinatorial Nullstellensatz.**
If `p` has degree `< |S|` and the coefficient of `X^{|S|-1}` is nonzero,
then `p` has a nonzero evaluation point in `S`.
-/
theorem exists_eval_ne_zero_of_coeff_ne_zero_univ
    (S : Finset K) (hS : S.Nonempty)
    (p : Polynomial K)
    (hdeg : p.natDegree < S.card)
    (hcoeff : p.coeff (S.card - 1) ≠ 0) :
    ∃ s ∈ S, p.eval s ≠ 0 := by
  exact Classical.not_forall_not.1 fun href => hcoeff <| by rw [ coeff_eq_sum_eval_div_lagrangeDen _ hS _ hdeg ] ; exact Finset.sum_eq_zero fun x hx => by aesop;

/-! ## §6. Multivariate definitions and Nullstellensatz -/

variable {ι : Type*} [DecidableEq ι] [Fintype ι]

/-- The Cartesian product grid: all functions `ι → K` choosing from `S i` for each `i`. -/
noncomputable def grid (S : ι → Finset K) : Finset (ι → K) :=
  Fintype.piFinset S

omit [Field K] [DecidableEq K] in
theorem mem_grid {S : ι → Finset K} {x : ι → K} :
    x ∈ grid S ↔ ∀ i, x i ∈ S i := by
  simp [grid, Fintype.mem_piFinset]

/-
**Multivariate Combinatorial Nullstellensatz** (Alon's theorem).

If `f` is a multivariate polynomial over a field `K` and `S : ι → Finset K`
assigns a nonempty finite set to each variable, and if the coefficient of the
monomial `∏ i, X_i^{|S i| - 1}` in `f` is nonzero (with each variable degree
bounded by `|S i| - 1`), then there exists an evaluation point `x` in the
Cartesian product `∏ i, S i` where `f(x) ≠ 0`.

This is the key consequence of the coefficient extraction identity.
-/
theorem exists_eval_ne_zero_mv
    (S : ι → Finset K)
    (hS : ∀ i, (S i).Nonempty)
    (f : MvPolynomial ι K)
    (hdeg : ∀ i, f.degreeOf i ≤ (S i).card - 1)
    (hcoeff : MvPolynomial.coeff
      (Finsupp.equivFunOnFinite.invFun (fun i => (S i).card - 1)) f ≠ 0) :
    ∃ x ∈ grid S, MvPolynomial.eval x f ≠ 0 := by
  revert hcoeff;
  simp +decide [ MvPolynomial.degreeOf_eq_sup ] at hdeg ⊢;
  -- By definition of polynomial evaluation, we can write
  have h_eval : ∀ x : ι → K, (MvPolynomial.eval x) f = ∑ b ∈ f.support, (MvPolynomial.coeff b f) * (∏ i, x i ^ (b i)) := by
    simp +decide [ MvPolynomial.eval_eq' ];
  -- By definition of polynomial evaluation, we can write the sum as
  have h_sum : ∑ x ∈ grid S, (∏ i, (lagrangeDen (S i) (x i))⁻¹) * (MvPolynomial.eval x) f = ∑ b ∈ f.support, (MvPolynomial.coeff b f) * (∏ i, (∑ x ∈ S i, (lagrangeDen (S i) x)⁻¹ * x ^ (b i))) := by
    simp +decide only [grid, h_eval, Finset.mul_sum _ _ _, prod_sum];
    rw [ Finset.sum_comm ];
    refine' Finset.sum_congr rfl fun b hb => _;
    refine' Finset.sum_bij ( fun x hx => fun i _ => x i ) _ _ _ _ <;> simp +decide [ Finset.prod_mul_distrib ];
    · simp +contextual [ funext_iff ];
    · exact fun b hb => ⟨ fun i => b i ( Finset.mem_univ i ), hb, rfl ⟩;
    · exact fun _ _ => by ring;
  -- By definition of polynomial evaluation, we know that
  have h_eval : ∀ i, ∀ b : ℕ, b ≤ (S i).card - 1 → (∑ x ∈ S i, (lagrangeDen (S i) x)⁻¹ * x ^ b) = if b = (S i).card - 1 then 1 else 0 := by
    intro i b hb
    have h_eval : ∀ p : Polynomial K, p.natDegree < (S i).card → (∑ x ∈ S i, (lagrangeDen (S i) x)⁻¹ * p.eval x) = p.coeff ((S i).card - 1) := by
      grind +suggestions;
    convert h_eval ( Polynomial.X ^ b ) _ using 1 <;> simp +decide [ Polynomial.natDegree_X_pow ];
    · simp +decide only [eq_comm];
    · exact lt_of_le_of_lt hb ( Nat.pred_lt ( ne_bot_of_gt ( Finset.card_pos.mpr ( hS i ) ) ) );
  -- Apply the evaluation result to each term in the sum.
  have h_sum_eval : ∑ x ∈ grid S, (∏ i, (lagrangeDen (S i) (x i))⁻¹) * (MvPolynomial.eval x) f = (MvPolynomial.coeff (Finsupp.equivFunOnFinite.symm fun i => (S i).card - 1) f) := by
    rw [ h_sum, Finset.sum_eq_single ( Finsupp.equivFunOnFinite.symm fun i => ( S i |> Finset.card ) - 1 ) ];
    · simp +decide [ h_eval ];
    · intro b hb hb';
      rw [ Finset.prod_eq_zero_iff.mpr ];
      · ring;
      · contrapose! hb';
        ext i; specialize hb' i; specialize h_eval i ( b i ) ( hdeg i b ( by aesop ) ) ; aesop;
    · simp +contextual [ MvPolynomial.coeff ];
  contrapose! h_sum_eval;
  rw [ Finset.sum_eq_zero fun x hx => by rw [ h_sum_eval.2 x hx, MulZeroClass.mul_zero ] ] ; simp +decide [ h_sum_eval.1 ];
  exact Ne.symm h_sum_eval.1

end CoeffExtraction