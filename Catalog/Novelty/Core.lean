import Mathlib

/-!
# The Jacobian Conjecture: a working formal framework

The **Jacobian Conjecture** (Keller, 1939) asserts that a polynomial map
`F : k^n → k^n` over a field `k` of characteristic zero whose Jacobian
determinant `det(JF)` is a nonzero constant is a polynomial automorphism.
It is open for every `n ≥ 2`.

This file sets up the algebraic objects needed to study the conjecture *honestly*
in Lean over an arbitrary commutative ring `R`:

* a **polynomial map** is a tuple `F : Fin n → MvPolynomial (Fin n) R`;
* `pcomp F G` is the composition obtained by substituting `G` into `F`
  (`aeval`-substitution), the monoid operation of polynomial endomorphisms;
* `IsPolyAut F G` says `F` and `G` are mutually inverse polynomial endomorphisms,
  i.e. `F` is a *polynomial automorphism* with explicit inverse `G`;
* `polyJacobian F` / `jacDet F` are the Jacobian matrix and determinant, built
  from formal partial derivatives `MvPolynomial.pderiv`.

## Main results

* `aeval_induced` — substitution is functorial: evaluating a substituted
  polynomial equals substituting then evaluating.
* `leftInverse_induced` — one half of the bridge from algebra to set theory.
* `IsPolyAut.bijective_induced` — **the bridge theorem**: a polynomial
  automorphism induces an honest bijection on *every* `R`-algebra `A`
  (in particular on `R^n` itself). This is what "automorphism" means
  geometrically, and it is the reusable engine for all concrete instances in
  the sibling files `Druzkowski.lean`, `DegreeTwo.lean`, `Counterexamples.lean`.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the right Lean notion of "polynomial
  automorphism" is purely algebraic — mutual `aeval`-inverses — and it should
  *automatically* yield a geometric bijection on all base algebras, with no
  field / characteristic-zero hypotheses needed.  The hard analytic content of
  the Jacobian Conjecture lives entirely in *producing* the inverse `G`, not in
  the bookkeeping that an inverse, once found, is genuine.
* Experiment (Experimenter): defined `pcomp` via `aeval` and proved the
  substitution functoriality lemma `aeval_induced` by `MvPolynomial.induction_on`.
  The bridge theorem then follows from two `LeftInverse` instances.
* Analysis (Analyst): the bridge holds over an *arbitrary* commutative ring,
  confirming the hypothesis — invertibility is a formal identity, not an
  analytic fact.  This cleanly separates "verify a candidate automorphism"
  (easy, mechanizable, done here for several families) from "the conjecture"
  (open).
* Critique (Critic): `IsPolyAut` could be vacuous if no `F, G` satisfy it; the
  sibling files exhibit explicit non-trivial witnesses (degree 2 and a genuine
  degree-3 Druzkowski cubic-linear map), so the definition has content.
* Synthesis (PI): this is the foundation; concrete Jacobian-Conjecture
  instances are verified downstream by exhibiting `G` and discharging
  `IsPolyAut` with `ring`, then invoking `bijective_induced`.
-/

open MvPolynomial

namespace JacobianConjecture

variable {n : ℕ} {R : Type*} [CommRing R]

/-- Composition of polynomial maps: substitute `G` into `F`. This is the
multiplication of the endomorphism monoid of `R[X_0,…,X_{n-1}]`. -/
noncomputable def pcomp (F G : Fin n → MvPolynomial (Fin n) R) :
    Fin n → MvPolynomial (Fin n) R := fun i => aeval G (F i)

/-- `F` is a polynomial automorphism with two-sided inverse `G`: substituting
either into the other recovers the identity polynomial map `X`. -/
def IsPolyAut (F G : Fin n → MvPolynomial (Fin n) R) : Prop :=
  pcomp F G = X ∧ pcomp G F = X

/-- The Jacobian matrix of a polynomial map, with entries the formal partial
derivatives `∂F_i/∂X_j`. -/
noncomputable def polyJacobian (F : Fin n → MvPolynomial (Fin n) R) :
    Matrix (Fin n) (Fin n) (MvPolynomial (Fin n) R) :=
  Matrix.of fun i j => pderiv j (F i)

/-- The Jacobian determinant `det(JF)`. -/
noncomputable def jacDet (F : Fin n → MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (polyJacobian F).det

/-- The set-theoretic map induced on an `R`-algebra `A` by evaluating a
polynomial map at a point `v : Fin n → A`. -/
noncomputable def induced (F : Fin n → MvPolynomial (Fin n) R)
    {A : Type*} [CommRing A] [Algebra R A] (v : Fin n → A) : Fin n → A :=
  fun i => aeval v (F i)

/-- Functoriality of substitution: evaluating `p` at the point `induced G v`
equals substituting `G` into `p` and then evaluating at `v`. -/
theorem aeval_induced {A : Type*} [CommRing A] [Algebra R A]
    (G : Fin n → MvPolynomial (Fin n) R) (p : MvPolynomial (Fin n) R) (v : Fin n → A) :
    aeval (induced G v) p = aeval v (aeval G p) := by
  induction p using MvPolynomial.induction_on with
  | C a => simp
  | add p q hp hq => simp [hp, hq]
  | mul_X p i hp => simp [hp, induced]

/-- If `pcomp Q P = X` then `induced Q` is a left inverse of `induced P` on every
`R`-algebra. -/
theorem leftInverse_induced {P Q : Fin n → MvPolynomial (Fin n) R} (hQP : pcomp Q P = X)
    (A : Type*) [CommRing A] [Algebra R A] :
    Function.LeftInverse (induced Q (A := A)) (induced P (A := A)) := by
  intro v
  funext i
  show aeval (induced P v) (Q i) = v i
  rw [aeval_induced]
  have : aeval P (Q i) = X i := congrFun hQP i
  rw [this, aeval_X]

/-- **Bridge theorem.** A polynomial automorphism `F` (with inverse `G`) induces
an honest bijection `A^n → A^n` on *every* commutative `R`-algebra `A`,
in particular on `R^n` itself. -/
theorem IsPolyAut.bijective_induced {F G : Fin n → MvPolynomial (Fin n) R}
    (h : IsPolyAut F G) (A : Type*) [CommRing A] [Algebra R A] :
    Function.Bijective (induced F (A := A)) :=
  ⟨(leftInverse_induced h.2 A).injective, (leftInverse_induced h.1 A).surjective⟩

end JacobianConjecture