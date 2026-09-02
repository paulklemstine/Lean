/-
# From a finite grid check to all commutative rings, and back

`Bridges.ChartDegreeCertificates` shows that a finite grid check implies a ring identity in
every commutative ring.  This file proves the converse and thereby closes the loop:

* `NExpr.eval_X_eq_toZ` — the free commutative ring `ℤ[x₀,…,x_{n-1}]` computes the
  denotation of an expression;
* `NExpr.universal_iff_toZ_eq` — an identity of the chart calculus holds in **every**
  commutative ring iff the two expressions have the same integral denotation, i.e. the free
  ring is a complete test object;
* `NExpr.gridCert_iff_universal` — for expressions of degree `≤ d`, the *decidable* finite
  check on `{0,…,d}^n` is **equivalent** to validity in every commutative ring;
* `NExpr.decidableUniversal` — consequently the validity of such an identity over the class
  of all commutative rings is a decidable predicate of the two syntax trees;
* `NExpr.int_test_ring` — `ℤ` alone is a test ring: validity over `ℤ` implies validity
  everywhere (no degree hypothesis needed).
-/
import Bridges.ChartDegreeCertificates

open MvPolynomial

namespace ChartCalculus

namespace NExpr

variable {n : ℕ}

/-- Evaluating an expression at the generators of the free commutative ring on `n`
generators returns its denotation: reflection is *faithful*. -/
theorem eval_X_eq_toZ (e : NExpr n) :
    e.eval (fun i => (X i : MvPolynomial (Fin n) ℤ)) = e.toZ := by
  induction e with
  | var i => simp [eval, toZ]
  | const c => simp [eval, toZ]
  | add a b ha hb => simp [eval, toZ, ha, hb]
  | mul a b ha hb => simp [eval, toZ, ha, hb]
  | neg a ha => simp [eval, toZ, ha]

/-- **The free commutative ring is a complete test object.**  Two expressions define the
same function on every commutative ring precisely when they denote the same polynomial. -/
theorem universal_iff_toZ_eq (e₁ e₂ : NExpr n) :
    (∀ (R : Type) [CommRing R] (x : Fin n → R), e₁.eval x = e₂.eval x) ↔ e₁.toZ = e₂.toZ := by
  refine ⟨fun h => ?_, fun h R _ x => eval_eq_of_toZ_eq e₁ e₂ h x⟩
  have := h (MvPolynomial (Fin n) ℤ) (fun i => X i)
  rwa [eval_X_eq_toZ, eval_X_eq_toZ] at this

/-- **The main bridge.**  For expressions of syntactic degree at most `d`, the finite,
decidable check on the `(d+1)^n` integer grid points of `{0,…,d}^n` is *equivalent* to the
identity holding in every commutative ring. -/
theorem gridCert_iff_universal {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d) :
    GridCert d e₁ e₂ ↔ ∀ (R : Type) [CommRing R] (x : Fin n → R), e₁.eval x = e₂.eval x :=
  (gridCert_iff_toZ_eq e₁ e₂ h₁ h₂).trans (universal_iff_toZ_eq e₁ e₂).symm

/-- Validity of a chart-calculus identity over the class of all commutative rings is
decidable. -/
def decidableUniversal (e₁ e₂ : NExpr n) :
    Decidable (∀ (R : Type) [CommRing R] (x : Fin n → R), e₁.eval x = e₂.eval x) :=
  decidable_of_iff (GridCert (max e₁.deg e₂.deg) e₁ e₂)
    (gridCert_iff_universal e₁ e₂ (le_max_left _ _) (le_max_right _ _))

/-- **`ℤ` is a test ring.**  If an identity of the chart calculus holds for all integer
arguments, it holds in every commutative ring.  (No degree hypothesis is needed here: this
uses that `ℤ` is an infinite domain.) -/
theorem int_test_ring (e₁ e₂ : NExpr n) (h : ∀ x : Fin n → ℤ, e₁.eval x = e₂.eval x)
    (R : Type*) [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x := by
  refine eval_eq_of_toZ_eq e₁ e₂ (MvPolynomial.funext (fun y => ?_)) x
  rw [← eval_int, ← eval_int]
  exact h y

/-- Combining the two directions: validity over `ℤ` (infinitely many points) is equivalent
to validity on the finite grid `{0,…,d}^n`, for expressions of degree `≤ d`. -/
theorem int_valid_iff_gridCert {d : ℕ} (e₁ e₂ : NExpr n) (h₁ : e₁.deg ≤ d) (h₂ : e₂.deg ≤ d) :
    (∀ x : Fin n → ℤ, e₁.eval x = e₂.eval x) ↔ GridCert d e₁ e₂ := by
  refine ⟨fun h => (gridCert_iff_universal e₁ e₂ h₁ h₂).mpr (fun R _ x => ?_), fun hc x => ?_⟩
  · exact int_test_ring e₁ e₂ h R x
  · exact universal_of_gridCert h₁ h₂ hc x

end NExpr

end ChartCalculus