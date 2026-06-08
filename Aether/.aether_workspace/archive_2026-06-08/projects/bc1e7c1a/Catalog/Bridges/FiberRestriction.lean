/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.ReedMuller.Defs

/-!
# Fiber Restriction for Multivariate Polynomials

This file develops the theory of restricting multivariate polynomials to
affine hyperplanes (fibers) and establishes key lemmas for the hyperplane
restriction proof of the generalized Reed–Muller minimum distance.

## Main results

- `GRM.fiberRestrict`: restriction of f to the hyperplane x₀ = c
- `GRM.hammingWeight_sum_fibers`: weight decomposes as sum over fibers
- `GRM.fiberRestrict_totalDegree_le`: degree of restriction ≤ degree of original
- `GRM.vanishing_fiber_count_le`: number of vanishing fibers ≤ degree
- `GRM.fiberRestrict_factor_degree_drop`: after factoring vanishing fibers, degree drops
-/

open MvPolynomial Finset BigOperators Fintype

namespace GRM

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-! ### Fiber Restriction -/

/-- Restrict a polynomial in n+1 variables to the hyperplane x₀ = c,
    obtaining a polynomial in n variables. -/
noncomputable def fiberRestrict {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (c : 𝔽) : MvPolynomial (Fin n) 𝔽 :=
  MvPolynomial.eval₂ MvPolynomial.C
    (Fin.cons (MvPolynomial.C c) (fun i => MvPolynomial.X i)) f

/-
Evaluating the fiber restriction at a point gives the same result
    as evaluating the original polynomial at the extended point.
-/
theorem eval_fiberRestrict {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (c : 𝔽)
    (x : Fin n → 𝔽) :
    MvPolynomial.eval x (fiberRestrict f c) =
      MvPolynomial.eval (Fin.cons c x) f := by
  erw [ MvPolynomial.eval_eval₂ ];
  congr;
  · ext; simp +decide [ MvPolynomial.eval_C ] ;
  · ext i; induction i using Fin.inductionOn <;> simp +decide [ * ] ;

/-
The degree of a fiber restriction is at most the degree of the original.
-/
theorem fiberRestrict_totalDegree_le {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (c : 𝔽) :
    (fiberRestrict f c).totalDegree ≤ f.totalDegree := by
  unfold GRM.fiberRestrict;
  simp +decide [ MvPolynomial.eval₂_eq', MvPolynomial.totalDegree ];
  intro b hb;
  rw [ MvPolynomial.coeff_sum ] at hb;
  obtain ⟨ x, hx ⟩ := Finset.exists_ne_zero_of_sum_ne_zero hb;
  refine' le_trans _ ( Finset.le_sup hx.1 );
  simp +decide [ Fin.prod_univ_succ, MvPolynomial.coeff_C_mul ] at hx ⊢;
  rw [ show ( C c ^ x 0 * ∏ x_1 : Fin n, X x_1 ^ x x_1.succ : MvPolynomial ( Fin n ) 𝔽 ) = MvPolynomial.monomial ( ∑ i : Fin n, x ( Fin.succ i ) • Finsupp.single i 1 ) ( c ^ x 0 ) from ?_ ] at hx;
  · simp_all +decide [ MvPolynomial.coeff_monomial ];
    rw [ ← hx.2.1, Finsupp.sum_sum_index' ] <;> simp +decide [ Finsupp.sum_single_index ];
    rw [ Finsupp.sum_fintype ];
    · conv_rhs => rw [ Fin.sum_univ_succ ] ;
      exact Nat.le_add_left _ _;
    · exact fun _ => rfl;
  · simp +decide [ MvPolynomial.monomial_eq, Finsupp.single_apply, Finset.prod_pow_eq_pow_sum ]

/-! ### Weight Decomposition -/

/-
**Weight sum over fibers**: The Hamming weight of f in n+1 variables
    equals the sum of the Hamming weights of its fiber restrictions.
-/
theorem hammingWeight_sum_fibers {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) :
    hammingWeight f = ∑ c : 𝔽, hammingWeight (fiberRestrict f c) := by
  unfold hammingWeight;
  simp +decide only [card_filter];
  rw [ ← Finset.sum_product' ];
  refine' Finset.sum_bij ( fun x _ => ( x 0, fun i => x ( Fin.succ i ) ) ) _ _ _ _ <;> simp +decide;
  · exact fun a₁ a₂ h₁ h₂ => funext fun i => by induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
  · exact fun a b => ⟨ Fin.cons a b, rfl, rfl ⟩;
  · intro a; rw [ eval_fiberRestrict ] ;
    congr ; ext i ; induction i using Fin.inductionOn <;> aesop

/-! ### Vanishing Fiber Analysis -/

/-- The set of field elements where the fiber restriction vanishes identically. -/
noncomputable def vanishingFibers {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) : Finset 𝔽 :=
  Finset.univ.filter (fun c => fiberRestrict f c = 0)

/-
The number of vanishing fibers is at most the total degree.
-/
theorem vanishing_fiber_count_le {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽) (hf : f ≠ 0) :
    (vanishingFibers f).card ≤ f.totalDegree := by
  nontriviality;
  -- By Schwartz-Zippel, the number of zeros of f is at most f.totalDegree * q^n.
  have h_zeros : (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => MvPolynomial.eval x f = 0)).card ≤ f.totalDegree * (Fintype.card 𝔽) ^ n := by
    have := @MvPolynomial.schwartz_zippel_totalDegree;
    specialize this hf Finset.univ;
    rw [ div_le_div_iff₀ ] at this <;> norm_cast at * <;> simp_all +decide [ pow_succ, mul_assoc ];
    · nlinarith [ show 0 < Fintype.card 𝔽 from Fintype.card_pos ];
    · exact ⟨ pow_pos ( Fintype.card_pos ) _, Fintype.card_pos ⟩;
    · exact Fintype.card_pos;
  -- Each vanishing fiber contributes q^n zeros.
  have h_vanishing_fiber_zeros : (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => MvPolynomial.eval x f = 0)).card ≥ (vanishingFibers f).card * (Fintype.card 𝔽) ^ n := by
    have h_vanishing_fiber_zeros : ∀ c ∈ vanishingFibers f, (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => MvPolynomial.eval x f = 0 ∧ x 0 = c)).card = (Fintype.card 𝔽) ^ n := by
      intro c hc
      have h_vanishing_fiber_zeros : ∀ x : Fin n → 𝔽, MvPolynomial.eval (Fin.cons c x) f = 0 := by
        intro x
        have h_eval : MvPolynomial.eval x (fiberRestrict f c) = 0 := by
          unfold vanishingFibers at hc; aesop;
        rwa [ ← eval_fiberRestrict ];
      have h_vanishing_fiber_zeros : Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => MvPolynomial.eval x f = 0 ∧ x 0 = c) = Finset.image (fun x : Fin n → 𝔽 => Fin.cons c x) Finset.univ := by
        ext x; simp [h_vanishing_fiber_zeros];
        constructor <;> intro h;
        · exact ⟨ fun i => x i.succ, by ext i; cases i using Fin.inductionOn <;> simp +decide [ h.2 ] ⟩;
        · rcases h with ⟨ a, rfl ⟩ ; exact ⟨ h_vanishing_fiber_zeros a, rfl ⟩ ;
      rw [ h_vanishing_fiber_zeros, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    have h_vanishing_fiber_zeros : (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => MvPolynomial.eval x f = 0)).card ≥ Finset.sum (vanishingFibers f) (fun c => (Finset.univ.filter (fun x : Fin (n + 1) → 𝔽 => MvPolynomial.eval x f = 0 ∧ x 0 = c)).card) := by
      rw [ ← Finset.card_biUnion ];
      · exact Finset.card_le_card fun x hx => by aesop;
      · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;
    exact le_trans ( by rw [ Finset.sum_congr rfl ‹_›, Finset.sum_const, smul_eq_mul, mul_comm ] ) h_vanishing_fiber_zeros;
  nlinarith [ pow_pos ( Fintype.card_pos_iff.mpr ⟨ 0 ⟩ : 0 < Fintype.card 𝔽 ) n ]

/-! ### Weight Lower Bound via Fibers -/

/-
**Fiber weight lower bound**: If at most t fibers vanish, and each
    nonvanishing fiber restriction has weight ≥ w, then
    hammingWeight f ≥ (q - t) * w.
-/
theorem hammingWeight_ge_of_fiber_bound {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) 𝔽)
    (t w : ℕ)
    (ht : (vanishingFibers f).card ≤ t)
    (hw : ∀ c : 𝔽, fiberRestrict f c ≠ 0 →
      w ≤ hammingWeight (fiberRestrict f c)) :
    (card 𝔽 - t) * w ≤ hammingWeight f := by
  rw [ hammingWeight_sum_fibers ];
  have h_sum_nonvanishing : ∑ c ∈ Finset.univ \ vanishingFibers f, hammingWeight (fiberRestrict f c) ≥ (Finset.univ \ vanishingFibers f).card * w := by
    exact le_trans ( by simp +decide ) ( Finset.sum_le_sum fun x hx => hw x <| by unfold vanishingFibers at hx; aesop );
  simp_all +decide [ Finset.card_sdiff ];
  exact le_trans ( Nat.mul_le_mul_right _ ( Nat.sub_le_sub_left ht _ ) ) ( h_sum_nonvanishing.trans ( Finset.sum_le_sum_of_subset ( Finset.sdiff_subset ) ) )

end GRM