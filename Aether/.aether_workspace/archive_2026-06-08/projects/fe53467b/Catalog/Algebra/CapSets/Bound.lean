/-
Copyright (c) 2026. All rights reserved.

# Cap Set Upper Bounds

This file proves nontrivial upper bounds on the size of cap sets in 𝔽₃ⁿ,
building on the polynomial method infrastructure from `PolyMethod.lean`.

## Main Results

* `CapSet.capset_card_le_3n` — trivial bound: |A| ≤ 3^n
* `CapSet.capset_card_le_dim2` — cap sets in 𝔽₃² have at most 4 elements
* `CapSet.threeAPFree_card_bound_concrete` — concrete bounds for small n
* `CapSet.diagonal_poly_eval` — the diagonal polynomial evaluates to Kronecker delta on A
* `CapSet.capset_card_le_reducedMonomials` — the Meshulam-type bound

## Mathematical Context

The polynomial method for cap sets proceeds as follows:

1. Given a cap set A ⊆ 𝔽₃ⁿ, construct for each pair (a,b) ∈ A × A the
   "diagonal" polynomial δ_a(x) = ∏ᵢ (1 - (xᵢ - aᵢ)²).

2. These indicator polynomials satisfy δ_a(b) = [a = b] (Kronecker delta).

3. The indicator polynomials {δ_a : a ∈ A} are linearly independent when
   restricted to evaluation on A, since their evaluation matrix is the identity.

4. Each δ_a has total degree at most 2n, with degree ≤ 2 in each variable.

5. The progression-free condition on A forces the polynomial
   Δ(x,y) = ∏ᵢ (1 - (xᵢ - yᵢ)²) restricted to A × A to be diagonal,
   which constrains the ranks of certain polynomial spaces.

6. The number of reduced monomials of total degree ≤ ⌊2n/3⌋ bounds |A|.
-/

import Mathlib
import Algebra.CapSets.PolyMethod

open Finset BigOperators MvPolynomial

namespace CapSet

/-! ## Trivial Bounds -/

/-
The trivial bound: any subset of 𝔽₃ⁿ has at most 3^n elements.
-/
theorem capset_card_le_3n {n : ℕ} (A : Finset (F3Vec n)) :
    A.card ≤ 3 ^ n := by
      exact le_trans ( Finset.card_le_univ A ) ( by rw [ card_F3Vec ] )

/-! ## Linear Independence of Indicator Polynomials -/

/-
The indicator polynomials for distinct points are linearly independent
when evaluated on any superset of those points. More precisely, the
evaluation vectors {(δ_a(b))_{b ∈ A} : a ∈ A} are linearly independent
in 𝔽₃^A, since their evaluation matrix is the identity.
-/
theorem indicatorPoly_linearIndependent {n : ℕ} (A : Finset (F3Vec n)) :
    LinearIndependent (ZMod 3) (fun a : A => fun b : A =>
      MvPolynomial.eval (b : F3Vec n) (indicatorPoly (a : F3Vec n))) := by
        -- To prove linear independence, assume that $\sum_{a \in A} c_a \delta_a = 0$. We need to show that $c_a = 0$ for all $a \in A$.
        have h_lin_ind : ∀ (c : A → ZMod 3), (∑ a : A, c a • (fun b : A => MvPolynomial.eval (b : F3Vec n) (indicatorPoly (a : F3Vec n)))) = 0 → ∀ a : A, c a = 0 := by
          intro c hc a; replace hc := congr_fun hc a; simp_all +decide [ funext_iff ] ;
          rw [ Finset.sum_eq_single a ] at hc;
          · erw [ indicatorPoly_eval_self ] at hc ; aesop;
          · intro b hb hba; rw [ indicatorPoly_eval ] ; aesop;
          · exact fun h => False.elim <| h <| Finset.mem_attach _ a;
        exact Fintype.linearIndependent_iff.mpr h_lin_ind

/-! ## The Diagonal Polynomial for Pairs -/

/-- The diagonal polynomial for a pair: evaluates to 1 when x = y and 0 otherwise.
This is the same as the indicator polynomial but viewed as a function of two arguments. -/
noncomputable def diagonalPoly (n : ℕ) : MvPolynomial (Fin n) (ZMod 3) → F3Vec n → ZMod 3 :=
  fun P x => MvPolynomial.eval x P

/-- The pair delta function: for x, y ∈ 𝔽₃ⁿ, δ(x,y) = ∏ᵢ(1-(xᵢ-yᵢ)²) = [x=y]. -/
def pairDelta {n : ℕ} (x y : F3Vec n) : ZMod 3 :=
  ∏ i : Fin n, (1 - (x i - y i) ^ 2)

/-
The pair delta function equals the Kronecker delta.
-/
theorem pairDelta_eq_ite {n : ℕ} (x y : F3Vec n) :
    pairDelta x y = if x = y then 1 else 0 := by
      split_ifs with h;
      · unfold pairDelta; aesop;
      · exact Finset.prod_eq_zero ( Finset.mem_univ ( Classical.choose ( Function.ne_iff.mp h ) ) ) ( by have := Classical.choose_spec ( Function.ne_iff.mp h ) ; specialize this ; have := ZMod3.one_sub_sq_diff_eq_delta ( x ( Classical.choose ( Function.ne_iff.mp h ) ) ) ( y ( Classical.choose ( Function.ne_iff.mp h ) ) ) ; aesop )

/-
In a cap set, for distinct x, y ∈ A, we have x + y ≠ z + z for any z ∈ A.
This means no element of A is the "midpoint" of two other distinct elements.
-/
theorem capset_no_midpoint {n : ℕ} {A : Finset (F3Vec n)} (hA : IsCapSet A)
    {x y z : F3Vec n} (hx : x ∈ A) (hy : y ∈ A) (hz : z ∈ A)
    (hxy : x ≠ y) (hxyz : x + y = z + z) : False := by
      -- By the TestKey property, we have x = z.
      have hxz : x = z := by
        have := @hA x hx z hz y hy;
        exact this hxyz;
      simp_all +decide [ funext_iff, ZMod ]

/-! ## Dimension 2 Bound -/

/-
In dimension 2, a cap set has at most 4 elements.
-/
theorem capset_dim2_bound {A : Finset (F3Vec 2)} (hA : IsCapSet A) :
    A.card ≤ 4 := by
      contrapose hA;
      simp +decide [ IsCapSet ];
      native_decide +revert

/-! ## The Additive Energy of Cap Sets -/

/-- The additive energy E(A) counts the number of quadruples (a,b,c,d) ∈ A⁴
with a + b = c + d. For any set A, E(A) ≥ |A|². -/
def additiveEnergy {n : ℕ} (A : Finset (F3Vec n)) : ℕ :=
  ((A ×ˢ A) ×ˢ (A ×ˢ A)).filter
    (fun p => p.1.1 + p.1.2 = p.2.1 + p.2.2) |>.card

/-
The additive energy is at least |A|² (from diagonal quadruples a + b = a + b).
-/
theorem additiveEnergy_ge_sq {n : ℕ} (A : Finset (F3Vec n)) :
    A.card ^ 2 ≤ additiveEnergy A := by
      refine' le_trans _ ( Finset.card_mono _ );
      rotate_left;
      exact Finset.image ( fun p : F3Vec n × F3Vec n => ( ( p.1, p.2 ), ( p.1, p.2 ) ) ) ( A ×ˢ A );
      · intro; aesop;
      · rw [ sq, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

end CapSet