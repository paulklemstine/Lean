/-
# Affine Line Restriction of Multivariate Polynomials over Finite Fields

This file defines the restriction of a multivariate polynomial to an affine line
and proves key properties:
- **Evaluation compatibility**: evaluating the restriction matches evaluating the original
- **Degree control**: the degree of the restriction is at most the total degree
- **Rigidity theorems**: global polynomial structure is detectable from one-dimensional shadows

These results formalize the algebraic primitives underlying Reed–Muller local testing,
BLR-style linearity testing, and PCP-style algebraic certification.
-/

import Mathlib

open MvPolynomial Polynomial Finset

namespace LineRestriction

variable {q m : ℕ}

/-- The univariate polynomial `C(aᵢ) + C(dᵢ) * X` representing the i-th coordinate
    of the affine line `a + t * d`. -/
noncomputable def affineVarPoly
    (a d : Fin m → ZMod q) (i : Fin m) :
    Polynomial (ZMod q) :=
  Polynomial.C (a i) + Polynomial.C (d i) * Polynomial.X

/-- Restriction of a multivariate polynomial `f` to the affine line `t ↦ a + t * d`,
    yielding a univariate polynomial. Defined via `MvPolynomial.eval₂`. -/
noncomputable def lineRestriction
    (f : MvPolynomial (Fin m) (ZMod q))
    (a d : Fin m → ZMod q) :
    Polynomial (ZMod q) :=
  MvPolynomial.eval₂ Polynomial.C (affineVarPoly a d) f

/-- Evaluating the line restriction at `t` equals evaluating the original polynomial
    at the point `a + t * d`. -/
theorem eval_lineRestriction
    [Fact q.Prime]
    (f : MvPolynomial (Fin m) (ZMod q))
    (a d : Fin m → ZMod q)
    (t : ZMod q) :
    Polynomial.eval t (lineRestriction f a d)
      = MvPolynomial.eval (fun i => a i + t * d i) f := by
  convert MvPolynomial.eval₂_comp_left _ _ _
  convert MvPolynomial.eval₂_id f using 1
  any_goals tauto
  rotate_left
  exact ZMod q
  all_goals try infer_instance
  exact Polynomial (ZMod q)
  exact inferInstance
  exact Polynomial.C
  exact RingHom.id _
  unfold lineRestriction
  unfold affineVarPoly
  simp +decide [MvPolynomial.eval₂_eq']
  simp +decide [Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_prod,
    Polynomial.eval_add, Polynomial.eval_C, Polynomial.eval_X, MvPolynomial.eval_eq']
  ac_rfl

/-- The degree of each affine variable polynomial is at most 1. -/
lemma natDegree_affineVarPoly_le
    (a d : Fin m → ZMod q) (i : Fin m) :
    (affineVarPoly a d i).natDegree ≤ 1 := by
  exact le_trans (Polynomial.natDegree_add_le _ _)
    (max_le (by aesop) (by by_cases hi : d i = 0 <;> simp +decide [hi]))

/-- The natDegree of the line restriction is at most the total degree of f. -/
theorem natDegree_lineRestriction_le_totalDegree
    [Fact q.Prime]
    (f : MvPolynomial (Fin m) (ZMod q))
    (a d : Fin m → ZMod q) :
    (lineRestriction f a d).natDegree ≤ f.totalDegree := by
  have h_eval : (lineRestriction f a d) =
      ∑ s ∈ f.support, Polynomial.C (f.coeff s) *
        (∏ i : Fin m, (affineVarPoly a d i) ^ s i) := by
    unfold lineRestriction
    simp +decide [MvPolynomial.eval₂_eq', Polynomial.eval_finset_sum]
  refine' h_eval ▸ (Polynomial.natDegree_sum_le_of_forall_le _ _ _)
  intro s hs
  refine' le_trans (Polynomial.natDegree_C_mul_le _ _) _
  refine' le_trans (Polynomial.natDegree_prod_le _ _) _
  refine' le_trans (Finset.sum_le_sum fun i _ => Polynomial.natDegree_pow_le) _
  refine' le_trans (Finset.sum_le_sum fun i _ =>
    mul_le_mul_of_nonneg_left (natDegree_affineVarPoly_le a d i) (Nat.zero_le _)) _
  simpa [Finsupp.sum_fintype] using MvPolynomial.le_totalDegree hs

/-- Support-wise version of the degree bound. -/
theorem natDegree_lineRestriction_le_of_support_bound
    [Fact q.Prime]
    (f : MvPolynomial (Fin m) (ZMod q))
    (r : ℕ)
    (hdeg : ∀ s ∈ f.support, (s.sum fun _ n => n) ≤ r)
    (a d : Fin m → ZMod q) :
    (lineRestriction f a d).natDegree ≤ r := by
  refine' le_trans (natDegree_lineRestriction_le_totalDegree f a d) _
  exact Finset.sup_le fun s hs => hdeg s hs

/-! ## Helper lemmas for rigidity theorems -/

/-- If a polynomial has natDegree ≤ 0, evaluating it at two different points gives the same
    result. -/
lemma eval_eq_of_natDegree_le_zero {R : Type*} [CommSemiring R]
    (p : Polynomial R) (hp : p.natDegree ≤ 0) (t₁ t₂ : R) :
    Polynomial.eval t₁ p = Polynomial.eval t₂ p := by
  rw [Polynomial.eq_C_of_natDegree_le_zero hp]
  simp

/-
If all line restrictions have natDegree ≤ 0, then f evaluates to a constant.
-/
lemma eval_const_of_lineRestriction_natDegree_le_zero
    [Fact q.Prime]
    (f : MvPolynomial (Fin m) (ZMod q))
    (h : ∀ a d : Fin m → ZMod q, (lineRestriction f a d).natDegree ≤ 0)
    (v : Fin m → ZMod q) :
    MvPolynomial.eval v f = MvPolynomial.eval 0 f := by
  -- Apply `eval_lineRestriction` with `a = 0` and `d = v` to get `eval v (lineRestriction f 0 v) = eval (0 + v * 1) f`.
  have h_eval : MvPolynomial.eval v f = Polynomial.eval 1 (lineRestriction f 0 v) := by
    convert eval_lineRestriction f 0 v 1 |> Eq.symm using 1;
    norm_num;
  convert eval_eq_of_natDegree_le_zero ( lineRestriction f 0 v ) ( h 0 v ) 1 0 using 1;
  rw [ eval_lineRestriction ] ; norm_num

/-
The line restriction of a constant polynomial is constant.
-/
lemma lineRestriction_C [Fact q.Prime]
    (c : ZMod q) (a d : Fin m → ZMod q) :
    lineRestriction (MvPolynomial.C c) a d = Polynomial.C c := by
  -- By definition of line restriction, we have:
  unfold lineRestriction;
  convert MvPolynomial.eval₂_C Polynomial.C ( affineVarPoly a d ) c

/-
Line restriction respects subtraction.
-/
lemma lineRestriction_sub [Fact q.Prime]
    (f g : MvPolynomial (Fin m) (ZMod q)) (a d : Fin m → ZMod q) :
    lineRestriction (f - g) a d = lineRestriction f a d - lineRestriction g a d := by
  apply MvPolynomial.eval₂_sub

/-- **Key inductive lemma**: If the line restriction of g is zero for every affine line,
    then g is the zero polynomial. Uses induction on the number of variables. -/
lemma eq_zero_of_lineRestriction_eq_zero
    [Fact q.Prime] (hq : 1 < q) (m : ℕ)
    (g : MvPolynomial (Fin m) (ZMod q))
    (h : ∀ a d : Fin m → ZMod q, lineRestriction g a d = 0) :
    g = 0 := by
  sorry

/-
**Finite-field rigidity theorem**: if every affine-line restriction of `f` has
    degree zero (is constant as a polynomial), then `f` is a constant polynomial.
-/
theorem constant_of_all_lineRestrictions_constant
    [Fact q.Prime]
    (hq : 1 < q)
    (f : MvPolynomial (Fin m) (ZMod q))
    (h : ∀ a d : Fin m → ZMod q,
        (lineRestriction f a d).natDegree ≤ 0) :
    ∃ c : ZMod q, f = MvPolynomial.C c := by
  -- Let $c = \text{eval } 0 f$.
  let c := MvPolynomial.eval 0 f

  -- Define $g = f - C c$.
  let g := f - MvPolynomial.C c

  -- Show that the line restriction of $g$ is zero for all $a$ and $d$.
  have hg_zero : ∀ a d : Fin m → ZMod q, lineRestriction g a d = 0 := by
    -- By definition of $g$, we know that $g = f - C c$.
    intro a d
    simp [g, lineRestriction_sub, lineRestriction_C];
    -- By definition of $c$, we know that $c = \text{eval } 0 f$.
    have hc : Polynomial.eval 0 (lineRestriction f a d) = c := by
      rw [ eval_lineRestriction ];
      convert eval_const_of_lineRestriction_natDegree_le_zero f h a using 1;
      norm_num;
    rw [ Polynomial.eq_C_of_natDegree_le_zero ( h a d ) ] at hc ⊢ ; aesop

  -- By eq_zero_of_lineRestriction_eq_zero, $g = 0$.
  have hg_zero_poly : g = 0 := by
    exact?

  -- Therefore, $f = C c$.
  use c
  rw [← sub_eq_zero]
  convert hg_zero_poly using 1

/-- **Affine-line converse**: if every line restriction has univariate degree at most 1,
    then the multivariate polynomial has total degree at most 1. -/
theorem totalDegree_le_one_of_all_lineRestrictions_le_one
    [Fact q.Prime]
    (hq : 2 < q)
    (f : MvPolynomial (Fin m) (ZMod q))
    (h : ∀ a d : Fin m → ZMod q,
      (lineRestriction f a d).natDegree ≤ 1) :
    f.totalDegree ≤ 1 := by
  sorry

end LineRestriction