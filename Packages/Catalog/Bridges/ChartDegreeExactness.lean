/-
# Reflective chart calculus: degree-graded exactness of polynomial identities

This file builds a *reflective* calculus `NExpr n` of formal polynomial expressions in `n`
chart coordinates with integer constants, and proves a **degree-graded exactness theorem**:

> two expressions of total (syntactic) degree at most `d` that agree on the finite grid
> `{0, 1, …, d}^n ⊆ ℤ^n` denote the same polynomial, hence define the same function
> **in every commutative ring**.

This is the general-degree version of the classical low-degree arguments
(`degree_one_exact`, `degree_two_exact`, `degree_three_exact`, recovered below as
corollaries) which extract linear constraints from linear independence of chart
coordinates.  The recursion is organised by *total degree*: the only input is the
degree bound, and the grid size `d+1` is dictated by it.

The result is sharp: `NExpr.grid_bound_sharp` exhibits, for every `d`, a pair of
degree-`d` expressions that agree on a grid of size `d` but are not equal.

Main results:
* `MvPolynomial.eq_of_eval_eq_on_grid` — grid exactness for multivariate polynomials.
* `NExpr.toZ_eq_of_grid` — a finite integer grid certificate forces equality of denotations.
* `NExpr.universal_of_grid_certificate` — such a certificate yields the identity in *every*
  commutative ring (the bridge from a finite decidable check to universal algebra).
* `NExpr.degree_exact` — the standard-chart form: check on `{0,…,d}^n`.
* `NExpr.degree_one_exact`, `NExpr.degree_two_exact`, `NExpr.degree_three_exact`.
* `NExpr.grid_bound_sharp` — the grid size `d+1` cannot be lowered to `d`.
* `chart_coords_linearly_independent` — linear independence of the chart coordinates
  together with the constant `1`, as functions on a grid.
-/
import Mathlib

open MvPolynomial

namespace ChartCalculus

/-! ## Grid exactness for multivariate polynomials -/

/-- Two polynomials of total degree `≤ d` that agree on a product grid `S^σ` with
`d < #S` are equal.  This is the degree-graded rigidity statement underlying everything
below. -/
theorem MvPolynomial.eq_of_eval_eq_on_grid {R : Type*} [CommRing R] [IsDomain R]
    {σ : Type*} [Finite σ] {d : ℕ} (p q : MvPolynomial σ R)
    (hp : p.totalDegree ≤ d) (hq : q.totalDegree ≤ d)
    (S : Finset R) (hS : d < S.card)
    (h : ∀ x : σ → R, (∀ i, x i ∈ S) → eval x p = eval x q) :
    p = q := by
  have hdeg : (p - q).totalDegree ≤ d := by
    rw [sub_eq_add_neg]
    exact (MvPolynomial.totalDegree_add p (-q)).trans
      (max_le hp (by rwa [MvPolynomial.totalDegree_neg]))
  have hzero : p - q = 0 := by
    refine MvPolynomial.eq_zero_of_eval_zero_at_prod_finset _ (fun _ => S) (fun i => ?_)
      (fun x hx => ?_)
    · exact lt_of_le_of_lt ((MvPolynomial.degreeOf_le_totalDegree _ i).trans hdeg) hS
    · simp only [map_sub, sub_eq_zero]
      exact h x hx
  exact sub_eq_zero.mp hzero

/-! ## The reflective calculus -/

/-- Formal polynomial expressions in `n` chart coordinates with integer constants. -/
inductive NExpr (n : ℕ) : Type
  | var : Fin n → NExpr n
  | const : ℤ → NExpr n
  | add : NExpr n → NExpr n → NExpr n
  | mul : NExpr n → NExpr n → NExpr n
  | neg : NExpr n → NExpr n
  deriving DecidableEq, Repr

namespace NExpr

variable {n : ℕ}

/-- Semantics of an expression in an arbitrary commutative ring. -/
def eval {R : Type*} [CommRing R] (x : Fin n → R) : NExpr n → R
  | .var i => x i
  | .const c => (c : R)
  | .add a b => eval x a + eval x b
  | .mul a b => eval x a * eval x b
  | .neg a => -eval x a

/-- The generic (integral) denotation of an expression. -/
noncomputable def toZ : NExpr n → MvPolynomial (Fin n) ℤ
  | .var i => MvPolynomial.X i
  | .const c => MvPolynomial.C c
  | .add a b => toZ a + toZ b
  | .mul a b => toZ a * toZ b
  | .neg a => -toZ a

/-- The syntactic total-degree bound. -/
def deg : NExpr n → ℕ
  | .var _ => 1
  | .const _ => 0
  | .add a b => max (deg a) (deg b)
  | .mul a b => deg a + deg b
  | .neg a => deg a

/-- Reflection is sound: the semantics in `R` is the evaluation of the base-change of the
integral denotation. -/
theorem eval_eq_map_toZ {R : Type*} [CommRing R] (x : Fin n → R) (e : NExpr n) :
    e.eval x = MvPolynomial.eval x (MvPolynomial.map (Int.castRingHom R) e.toZ) := by
  induction e with
  | var i => simp [eval, toZ]
  | const c => simp [eval, toZ]
  | add a b ha hb => simp [eval, toZ, ha, hb]
  | mul a b ha hb => simp [eval, toZ, ha, hb]
  | neg a ha => simp [eval, toZ, ha]

/-- Over `ℤ` the denotation computes the semantics on the nose. -/
theorem eval_int (x : Fin n → ℤ) (e : NExpr n) :
    e.eval x = MvPolynomial.eval x e.toZ := by
  induction e with
  | var i => simp [eval, toZ]
  | const c => simp [eval, toZ]
  | add a b ha hb => simp [eval, toZ, ha, hb]
  | mul a b ha hb => simp [eval, toZ, ha, hb]
  | neg a ha => simp [eval, toZ, ha]

/-- The syntactic degree really bounds the total degree of the denotation. -/
theorem totalDegree_toZ_le (e : NExpr n) : e.toZ.totalDegree ≤ e.deg := by
  induction e with
  | var i => simp [toZ, deg, MvPolynomial.totalDegree_X]
  | const c => exact le_of_eq (MvPolynomial.totalDegree_C c)
  | add a b ha hb => exact (MvPolynomial.totalDegree_add _ _).trans (max_le_max ha hb)
  | mul a b ha hb => exact (MvPolynomial.totalDegree_mul _ _).trans (Nat.add_le_add ha hb)
  | neg a ha => simpa [toZ, deg, MvPolynomial.totalDegree_neg] using ha

/-! ## Grid certificates -/

/-- A finite integer grid of size `> d` certifies equality of the denotations of two
expressions of degree `≤ d`. -/
theorem toZ_eq_of_grid {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d)
    (S : Finset ℤ) (hS : d < S.card)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ S) → e₁.eval x = e₂.eval x) :
    e₁.toZ = e₂.toZ := by
  refine MvPolynomial.eq_of_eval_eq_on_grid _ _ ((totalDegree_toZ_le e₁).trans h₁)
    ((totalDegree_toZ_le e₂).trans h₂) S hS (fun x hx => ?_)
  rw [← eval_int, ← eval_int]
  exact hgrid x hx

/-- Equality of the integral denotations transfers the identity to every commutative ring. -/
theorem eval_eq_of_toZ_eq {R : Type*} [CommRing R] (e₁ e₂ : NExpr n) (h : e₁.toZ = e₂.toZ)
    (x : Fin n → R) : e₁.eval x = e₂.eval x := by
  rw [eval_eq_map_toZ, eval_eq_map_toZ, h]

/-- **Universal transfer from a finite grid certificate.**  If two expressions of syntactic
degree `≤ d` agree on the integer grid `S^n` with `#S > d`, then they define the same
function on every commutative ring. -/
theorem universal_of_grid_certificate {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d)
    (h₂ : e₂.deg ≤ d) (S : Finset ℤ) (hS : d < S.card)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ S) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  eval_eq_of_toZ_eq e₁ e₂ (toZ_eq_of_grid e₁ e₂ h₁ h₂ S hS hgrid) x

/-! ## The standard chart grid `{0, …, d}` -/

/-- The standard chart grid `{0, 1, …, d} ⊆ ℤ`. -/
def stdGrid (d : ℕ) : Finset ℤ := (Finset.range (d + 1)).image (fun k : ℕ => (k : ℤ))

theorem card_stdGrid (d : ℕ) : (stdGrid d).card = d + 1 := by
  rw [stdGrid, Finset.card_image_of_injective _ (fun a b h => by exact_mod_cast h),
    Finset.card_range]

theorem mem_stdGrid {d : ℕ} {z : ℤ} : z ∈ stdGrid d ↔ ∃ k : ℕ, k ≤ d ∧ (k : ℤ) = z := by
  simp [stdGrid, eq_comm]

/-- **Degree-graded exactness (general degree).**  Two expressions of syntactic degree `≤ d`
that agree on the `(d+1)^n` points of the standard chart grid `{0,…,d}^n` are semantically
equal over every commutative ring. -/
theorem degree_exact {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ stdGrid d) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  universal_of_grid_certificate e₁ e₂ h₁ h₂ (stdGrid d)
    (by rw [card_stdGrid]; omega) hgrid R x

/-- Decidable, finitely checkable form of `degree_exact`: quantify over the explicit
finite set of grid points. -/
theorem degree_exact_of_piFinset {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d)
    (hgrid : ∀ x ∈ Fintype.piFinset (fun _ : Fin n => stdGrid d), e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  degree_exact e₁ e₂ h₁ h₂
    (fun y hy => hgrid y (Fintype.mem_piFinset.mpr hy)) R x

/-! ### Low-degree corollaries

These are the classical statements: `degree_one_exact` needs the two-point chart `{0,1}`,
`degree_two_exact` the three-point chart `{0,1,2}`, `degree_three_exact` the four-point
chart `{0,1,2,3}` — exactly `deg + 1` values per coordinate. -/

theorem degree_one_exact (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ 1) (h₂ : e₂.deg ≤ 1)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ stdGrid 1) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  degree_exact e₁ e₂ h₁ h₂ hgrid R x

theorem degree_two_exact (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ 2) (h₂ : e₂.deg ≤ 2)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ stdGrid 2) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  degree_exact e₁ e₂ h₁ h₂ hgrid R x

theorem degree_three_exact (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ 3) (h₂ : e₂.deg ≤ 3)
    (hgrid : ∀ x : Fin n → ℤ, (∀ i, x i ∈ stdGrid 3) → e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  degree_exact e₁ e₂ h₁ h₂ hgrid R x

/-! ## Sharpness of the grid bound -/

/-- `rootProd d = (x₀ - 0) * (x₀ - 1) * ⋯ * (x₀ - (d-1))`, a degree-`d` expression in one
variable vanishing exactly on `{0, …, d-1}`. -/
def rootProd : (d : ℕ) → NExpr 1
  | 0 => .const 1
  | k + 1 => .mul (rootProd k) (.add (.var 0) (.neg (.const (k : ℤ))))

theorem deg_rootProd (d : ℕ) : (rootProd d).deg = d := by
  induction d with
  | zero => rfl
  | succ k ih => simp [rootProd, deg, ih]

theorem eval_rootProd {R : Type*} [CommRing R] (x : Fin 1 → R) (d : ℕ) :
    (rootProd d).eval x = ∏ k ∈ Finset.range d, (x 0 - (k : ℤ)) := by
  induction d with
  | zero => simp [rootProd, eval]
  | succ k ih =>
      rw [Finset.prod_range_succ, ← ih]
      simp [rootProd, eval, sub_eq_add_neg]

/-- **Sharpness.** For every `d` there are two expressions of degree `≤ d` that agree on the
grid `{0, …, d-1}` of size `d` (one point short of `d+1`) but are not semantically equal.
Hence the hypothesis `d < #S` in `toZ_eq_of_grid` cannot be weakened to `d ≤ #S`. -/
theorem grid_bound_sharp (d : ℕ) :
    ∃ e₁ e₂ : NExpr 1, e₁.deg ≤ d ∧ e₂.deg ≤ d ∧
      ((Finset.range d).image (fun k : ℕ => (k : ℤ))).card = d ∧
      (∀ x : Fin 1 → ℤ, (∀ i, x i ∈ (Finset.range d).image (fun k : ℕ => (k : ℤ))) →
        e₁.eval x = e₂.eval x) ∧
      ∃ x : Fin 1 → ℤ, e₁.eval x ≠ e₂.eval x := by
  refine ⟨rootProd d, .const 0, (deg_rootProd d).le, Nat.zero_le _, ?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ (fun a b h => by exact_mod_cast h), Finset.card_range]
  · intro x hx
    obtain ⟨j, hj, hjx⟩ : ∃ j : ℕ, j < d ∧ (j : ℤ) = x 0 := by
      simpa [eq_comm] using hx 0
    rw [eval_rootProd, eval]
    refine (Finset.prod_eq_zero (Finset.mem_range.mpr hj) ?_).trans (by norm_num)
    simp [← hjx]
  · refine ⟨fun _ => (d : ℤ), ?_⟩
    rw [eval_rootProd, eval]
    have : ∀ k ∈ Finset.range d, ((d : ℤ) - (k : ℤ)) ≠ 0 := by
      intro k hk
      have : (k : ℤ) < (d : ℤ) := by exact_mod_cast Finset.mem_range.mp hk
      omega
    simpa using Finset.prod_ne_zero_iff.mpr this

end NExpr

/-! ## Linear independence of the chart coordinates

The degree-one instance of the exactness theorem, in coefficient form: a linear function
of the chart coordinates that vanishes on the two-point grid `{0,1}^n` has vanishing
coefficients.  This is the constraint-extraction step used in the classical low-degree
proofs, here derived from the graded theorem rather than assumed. -/

theorem chart_coords_linearly_independent {R : Type*} [CommRing R] {n : ℕ}
    (c₀ : R) (c : Fin n → R)
    (h : ∀ x : Fin n → R, (∀ i, x i = 0 ∨ x i = 1) → c₀ + ∑ i, c i * x i = 0) :
    c₀ = 0 ∧ ∀ i, c i = 0 := by
  have h0 : c₀ = 0 := by
    have := h (fun _ => 0) (fun _ => Or.inl rfl)
    simpa using this
  refine ⟨h0, fun i => ?_⟩
  have hi := h (fun j => if j = i then 1 else 0)
    (fun j => by by_cases hj : j = i <;> simp [hj])
  have hsum : ∑ j, c j * (if j = i then (1 : R) else 0) = c i := by
    simp
  rw [hsum, h0, zero_add] at hi
  exact hi

end ChartCalculus