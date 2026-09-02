/-
# Refining the chart grid: one grid size per coordinate

`Bridges.ChartDegreeExactness` certifies an identity between expressions of *total* degree
`≤ d` on the grid `{0,…,d}^n`, that is `(d+1)^n` points.  For many identities this is
wasteful: the monomial `x₀x₁⋯x_{n-1}` has total degree `n` but degree `1` in each variable.

This file refines the calculus by a *multidegree*: `NExpr.degOf e i` bounds the degree of
`e` in the variable `i` alone, and the corresponding exactness theorem uses a box grid
`∏ᵢ {0,…,Dᵢ}` of `∏ᵢ (Dᵢ+1)` points.

Main results:
* `NExpr.degreeOf_toZ_le` — the syntactic multidegree bounds the true one;
* `NExpr.box_exact` — box-grid exactness in every commutative ring;
* `NExpr.multilinear_exact` — a multilinear identity is decided by the `2^n` points of the
  Boolean cube `{0,1}^n`;
* `NExpr.boolean_cube_beats_total_degree_grid` — for `n ≥ 2` the Boolean cube is strictly
  smaller than the total-degree grid that `degree_exact` would require for a multilinear
  expression, so the refinement is a genuine improvement.
-/
import Bridges.ChartUniversality

open MvPolynomial

namespace ChartCalculus

namespace NExpr

variable {n : ℕ}

/-! ## Syntactic multidegree -/

/-- `degOf e i` is a syntactic bound for the degree of `e` in the single variable `i`. -/
def degOf : NExpr n → Fin n → ℕ
  | .var j, i => if i = j then 1 else 0
  | .const _, _ => 0
  | .add a b, i => max (degOf a i) (degOf b i)
  | .mul a b, i => degOf a i + degOf b i
  | .neg a, i => degOf a i

/-- The syntactic multidegree bounds the multidegree of the denotation. -/
theorem degreeOf_toZ_le (e : NExpr n) (i : Fin n) : e.toZ.degreeOf i ≤ e.degOf i := by
  classical
  induction e with
  | var j => simp [toZ, degOf, MvPolynomial.degreeOf_X]
  | const c => exact le_of_eq (MvPolynomial.degreeOf_C c i)
  | add a b ha hb =>
      exact (MvPolynomial.degreeOf_add_le i _ _).trans (max_le_max ha hb)
  | mul a b ha hb =>
      exact (MvPolynomial.degreeOf_mul_le i _ _).trans (Nat.add_le_add ha hb)
  | neg a ha => simpa [toZ, degOf, MvPolynomial.degreeOf_neg] using ha

/-! ## Box-grid exactness -/

/-- A product of integer grids, one per coordinate, certifies equality of denotations as
soon as each grid is larger than the corresponding syntactic multidegree. -/
theorem toZ_eq_of_box (e₁ e₂ : NExpr n) (S : Fin n → Finset ℤ)
    (h₁ : ∀ i, e₁.degOf i < (S i).card) (h₂ : ∀ i, e₂.degOf i < (S i).card)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ S i) → e₁.eval x = e₂.eval x) :
    e₁.toZ = e₂.toZ := by
  have hzero : e₁.toZ - e₂.toZ = 0 := by
    refine MvPolynomial.eq_zero_of_eval_zero_at_prod_finset _ S (fun i => ?_) (fun x hx => ?_)
    · refine lt_of_le_of_lt (MvPolynomial.degreeOf_sub_le i _ _) ?_
      exact max_lt (lt_of_le_of_lt (degreeOf_toZ_le e₁ i) (h₁ i))
        (lt_of_le_of_lt (degreeOf_toZ_le e₂ i) (h₂ i))
    · simp only [map_sub, sub_eq_zero, ← eval_int]
      exact hgrid x hx
  exact sub_eq_zero.mp hzero

/-- **Box exactness.**  If each variable `i` occurs with syntactic degree at most `D i` in
both expressions, then agreement on `∏ᵢ {0,…,D i}` — that is on `∏ᵢ (D i + 1)` integer
points — implies the identity in every commutative ring. -/
theorem box_exact (e₁ e₂ : NExpr n) (D : Fin n → ℕ)
    (h₁ : ∀ i, e₁.degOf i ≤ D i) (h₂ : ∀ i, e₂.degOf i ≤ D i)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ stdGrid (D i)) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x := by
  refine eval_eq_of_toZ_eq e₁ e₂ (toZ_eq_of_box e₁ e₂ (fun i => stdGrid (D i))
    (fun i => ?_) (fun i => ?_) hgrid) x
  · rw [card_stdGrid]; exact Nat.lt_succ_of_le (h₁ i)
  · rw [card_stdGrid]; exact Nat.lt_succ_of_le (h₂ i)

/-- **Multilinear exactness.**  Expressions that are affine in each variable separately are
determined by their `2^n` values on the Boolean cube `{0,1}^n`. -/
theorem multilinear_exact (e₁ e₂ : NExpr n)
    (h₁ : ∀ i, e₁.degOf i ≤ 1) (h₂ : ∀ i, e₂.degOf i ≤ 1)
    (hcube : ∀ x : Fin n → ℤ, (∀ i, x i = 0 ∨ x i = 1) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x := by
  refine box_exact e₁ e₂ (fun _ => 1) h₁ h₂ (fun y hy => hcube y (fun i => ?_)) R x
  obtain ⟨k, hk, hky⟩ := mem_stdGrid.mp (hy i)
  interval_cases k
  · exact Or.inl hky.symm
  · exact Or.inr hky.symm

/-- The Boolean cube is strictly smaller than the total-degree grid needed for a
multilinear expression in `n ≥ 2` variables (whose total degree can be `n`). -/
theorem boolean_cube_beats_total_degree_grid {n : ℕ} (hn : 2 ≤ n) : 2 ^ n < (n + 1) ^ n :=
  Nat.pow_lt_pow_left (by omega) (by omega)

/-! ## A multilinear certificate

The two-variable inclusion–exclusion identity `(1-x₀)(1-x₁) = 1 - x₀ - x₁ + x₀x₁` needs
only the four points of `{0,1}²`, whereas its total degree `2` would ask for nine. -/

/-- `(1 - x₀)(1 - x₁)` as a syntax tree. -/
def incExclLHS : NExpr 2 :=
  .mul (.add (.const 1) (.neg (.var 0))) (.add (.const 1) (.neg (.var 1)))

/-- `1 - x₀ - x₁ + x₀x₁` as a syntax tree. -/
def incExclRHS : NExpr 2 :=
  .add (.const 1) (.add (.neg (.var 0)) (.add (.neg (.var 1)) (.mul (.var 0) (.var 1))))

set_option maxRecDepth 20000 in
theorem incExcl_cube_cert :
    ∀ x ∈ Fintype.piFinset (fun _ : Fin 2 => stdGrid 1), eval x incExclLHS = eval x incExclRHS := by
  decide

/-- Inclusion–exclusion in an arbitrary commutative ring, certified by four integer
evaluations. -/
theorem incExcl_identity {R : Type*} [CommRing R] (a b : R) :
    (1 - a) * (1 - b) = 1 - a - b + a * b := by
  have h := multilinear_exact incExclLHS incExclRHS (by decide) (by decide)
    (fun y hy => incExcl_cube_cert y (Fintype.mem_piFinset.mpr (fun i => by
      rcases hy i with h | h
      · exact mem_stdGrid.mpr ⟨0, by norm_num, by simp [h]⟩
      · exact mem_stdGrid.mpr ⟨1, le_refl 1, by simp [h]⟩))) R ![a, b]
  simp only [incExclLHS, incExclRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  push_cast at h
  linear_combination h

end NExpr

end ChartCalculus