/-
# Finite grid certificates: a decision procedure for the chart calculus

Building on `Bridges.ChartDegreeExactness`, this file turns the degree-graded exactness
theorem into an *effective* device:

* `NExpr.GridCert d e₁ e₂` is the (decidable!) statement that two expressions agree on the
  `(d+1)^n` integer grid points `{0,…,d}^n`;
* `NExpr.gridCert_iff_toZ_eq` shows the certificate is **sound and complete**: for
  expressions of degree `≤ d` it holds iff the two expressions denote the *same*
  polynomial;
* consequently equality of denotations is decidable (`NExpr.decEqToZ`), and any successful
  finite check yields a ring identity valid in **every** commutative ring
  (`NExpr.universal_of_gridCert`).

Three classical algebraic identities (the binomial cube, a degree-four difference of
squares identity, and the symmetric-function factorisation of `a³+b³+c³-3abc`) are then
*derived* from purely numerical checks on `16`, `25` and `64` integer points respectively.

Finally `no_small_uniqueness_set` proves the strongest possible converse: *no* finite set
of at most `d` points in any integral domain — grid or not — determines polynomials of
total degree `≤ d`.
-/
import Bridges.ChartDegreeExactness

open MvPolynomial

namespace ChartCalculus

namespace NExpr

variable {n : ℕ}

/-! ## The decidable certificate -/

/-- The finite grid certificate: agreement on the `(d+1)^n` points of `{0,…,d}^n ⊆ ℤ^n`. -/
def GridCert (d : ℕ) (e₁ e₂ : NExpr n) : Prop :=
  ∀ x ∈ Fintype.piFinset (fun _ : Fin n => stdGrid d), eval x e₁ = eval x e₂

instance (d : ℕ) (e₁ e₂ : NExpr n) : Decidable (GridCert d e₁ e₂) :=
  inferInstanceAs (Decidable (∀ x ∈ _, _))

/-- **Soundness and completeness of the grid certificate.**  For expressions of syntactic
degree at most `d`, agreeing on `{0,…,d}^n` is *equivalent* to denoting the same
polynomial. -/
theorem gridCert_iff_toZ_eq {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d) :
    GridCert d e₁ e₂ ↔ e₁.toZ = e₂.toZ := by
  constructor
  · intro hc
    exact toZ_eq_of_grid e₁ e₂ h₁ h₂ (stdGrid d) (by rw [card_stdGrid]; omega)
      (fun x hx => hc x (Fintype.mem_piFinset.mpr hx))
  · intro h x _
    exact eval_eq_of_toZ_eq e₁ e₂ h x

/-- Equality of denotations in the chart calculus is decidable: run the grid check at the
degree `max (deg e₁) (deg e₂)`. -/
def decEqToZ (e₁ e₂ : NExpr n) : Decidable (e₁.toZ = e₂.toZ) :=
  decidable_of_iff (GridCert (max e₁.deg e₂.deg) e₁ e₂)
    (gridCert_iff_toZ_eq e₁ e₂ (le_max_left _ _) (le_max_right _ _))

/-- A verified finite check certifies the identity in every commutative ring. -/
theorem universal_of_gridCert {d : ℕ} {e₁ e₂ : NExpr n} (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d)
    (hc : GridCert d e₁ e₂) {R : Type*} [CommRing R] (x : Fin n → R) :
    e₁.eval x = e₂.eval x :=
  eval_eq_of_toZ_eq e₁ e₂ ((gridCert_iff_toZ_eq e₁ e₂ h₁ h₂).mp hc) x

/-! ## Worked certificates

Each identity below is *proved* by evaluating both sides at finitely many integer points
(`decide`) and then transporting the result along `universal_of_gridCert`. -/

section Cube

/-- `(x₀ + x₁)³` as a syntax tree. -/
def cubeLHS : NExpr 2 :=
  .mul (.add (.var 0) (.var 1)) (.mul (.add (.var 0) (.var 1)) (.add (.var 0) (.var 1)))

/-- `x₀³ + 3x₀²x₁ + 3x₀x₁² + x₁³` as a syntax tree. -/
def cubeRHS : NExpr 2 :=
  .add (.mul (.var 0) (.mul (.var 0) (.var 0)))
    (.add (.mul (.const 3) (.mul (.var 0) (.mul (.var 0) (.var 1))))
      (.add (.mul (.const 3) (.mul (.var 0) (.mul (.var 1) (.var 1))))
        (.mul (.var 1) (.mul (.var 1) (.var 1)))))

set_option maxRecDepth 40000 in
theorem cube_gridCert : GridCert 3 cubeLHS cubeRHS := by decide

/-- The binomial cube identity in an arbitrary commutative ring, obtained from a check on
`16` integer points. -/
theorem cube_identity {R : Type*} [CommRing R] (a b : R) :
    (a + b) ^ 3 = a ^ 3 + 3 * (a ^ 2 * b) + 3 * (a * b ^ 2) + b ^ 3 := by
  have h := universal_of_gridCert (d := 3) (e₁ := cubeLHS) (e₂ := cubeRHS)
    (by decide) (by decide) cube_gridCert (R := R) ![a, b]
  simp only [cubeLHS, cubeRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  rw [show ((3 : ℤ) : R) = 3 by push_cast; ring] at h
  linear_combination h

end Cube

section Quartic

/-- `(x₀ + x₁)² (x₀ - x₁)²`. -/
def quarticLHS : NExpr 2 :=
  .mul (.mul (.add (.var 0) (.var 1)) (.add (.var 0) (.var 1)))
    (.mul (.add (.var 0) (.neg (.var 1))) (.add (.var 0) (.neg (.var 1))))

/-- `(x₀² - x₁²)²`. -/
def quarticRHS : NExpr 2 :=
  .mul (.add (.mul (.var 0) (.var 0)) (.neg (.mul (.var 1) (.var 1))))
    (.add (.mul (.var 0) (.var 0)) (.neg (.mul (.var 1) (.var 1))))

set_option maxRecDepth 100000 in
theorem quartic_gridCert : GridCert 4 quarticLHS quarticRHS := by decide

/-- A degree-four identity in an arbitrary commutative ring, obtained from a check on `25`
integer points. -/
theorem quartic_identity {R : Type*} [CommRing R] (a b : R) :
    (a + b) ^ 2 * (a - b) ^ 2 = (a ^ 2 - b ^ 2) ^ 2 := by
  have h := universal_of_gridCert (d := 4) (e₁ := quarticLHS) (e₂ := quarticRHS)
    (by decide) (by decide) quartic_gridCert (R := R) ![a, b]
  simp only [quarticLHS, quarticRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  linear_combination h

end Quartic

section Symmetric

/-- `x₀³ + x₁³ + x₂³ - 3 x₀x₁x₂`. -/
def symLHS : NExpr 3 :=
  .add (.mul (.var 0) (.mul (.var 0) (.var 0)))
    (.add (.mul (.var 1) (.mul (.var 1) (.var 1)))
      (.add (.mul (.var 2) (.mul (.var 2) (.var 2)))
        (.neg (.mul (.const 3) (.mul (.var 0) (.mul (.var 1) (.var 2)))))))

/-- `(x₀+x₁+x₂)(x₀²+x₁²+x₂² - x₀x₁ - x₁x₂ - x₂x₀)`. -/
def symRHS : NExpr 3 :=
  .mul (.add (.var 0) (.add (.var 1) (.var 2)))
    (.add (.mul (.var 0) (.var 0))
      (.add (.mul (.var 1) (.var 1))
        (.add (.mul (.var 2) (.var 2))
          (.add (.neg (.mul (.var 0) (.var 1)))
            (.add (.neg (.mul (.var 1) (.var 2))) (.neg (.mul (.var 2) (.var 0))))))))

set_option maxRecDepth 200000 in
theorem sym_gridCert : GridCert 3 symLHS symRHS := by decide

/-- The classical factorisation of `a³+b³+c³-3abc`, valid in every commutative ring,
obtained from a check on `64` integer points. -/
theorem sym_identity {R : Type*} [CommRing R] (a b c : R) :
    a ^ 3 + b ^ 3 + c ^ 3 - 3 * (a * b * c) =
      (a + b + c) * (a ^ 2 + b ^ 2 + c ^ 2 - a * b - b * c - c * a) := by
  have h := universal_of_gridCert (d := 3) (e₁ := symLHS) (e₂ := symRHS)
    (by decide) (by decide) sym_gridCert (R := R) ![a, b, c]
  simp only [symLHS, symRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons] at h
  rw [show ((3 : ℤ) : R) = 3 by push_cast; ring] at h
  linear_combination h

end Symmetric

end NExpr

/-! ## No small uniqueness set

The exactness theorem needs `> d` values per coordinate.  The following shows that this is
not an artefact of using product grids: *no* set of at most `d` points of an integral
domain, however cleverly chosen, can determine polynomials of total degree `≤ d`. -/

/-- For every finite set `T` of at most `d` points of `Rⁿ` (`n ≥ 1`, `R` a domain) there is
a nonzero polynomial of total degree `≤ d` vanishing on `T`.  Hence `T` is not a uniqueness
set for total degree `≤ d`. -/
theorem no_small_uniqueness_set {R : Type*} [CommRing R] [IsDomain R] {n d : ℕ} (hn : 0 < n)
    (T : Finset (Fin n → R)) (hT : T.card ≤ d) :
    ∃ p : MvPolynomial (Fin n) R, p ≠ 0 ∧ p.totalDegree ≤ d ∧ ∀ t ∈ T, eval t p = 0 := by
  classical
  set i₀ : Fin n := ⟨0, hn⟩
  refine ⟨∏ t ∈ T, (X i₀ - C (t i₀)), ?_, ?_, ?_⟩
  · refine Finset.prod_ne_zero_iff.mpr (fun t _ => ?_)
    intro hzero
    have hcoeff := congrArg (MvPolynomial.coeff (Finsupp.single i₀ 1)) hzero
    have hne : (0 : Fin n →₀ ℕ) ≠ Finsupp.single i₀ 1 :=
      Ne.symm (Finsupp.single_ne_zero.mpr one_ne_zero)
    simp [MvPolynomial.coeff_X', MvPolynomial.coeff_C, hne] at hcoeff
  · refine (MvPolynomial.totalDegree_finset_prod _ _).trans ?_
    calc ∑ t ∈ T, (X i₀ - C (t i₀) : MvPolynomial (Fin n) R).totalDegree
        ≤ ∑ _t ∈ T, 1 := by
          refine Finset.sum_le_sum (fun t _ => ?_)
          refine (MvPolynomial.totalDegree_sub _ _).trans ?_
          simp [MvPolynomial.totalDegree_X, MvPolynomial.totalDegree_C]
      _ = T.card := by simp
      _ ≤ d := hT
  · intro t ht
    rw [map_prod]
    exact Finset.prod_eq_zero ht (by simp)

end ChartCalculus