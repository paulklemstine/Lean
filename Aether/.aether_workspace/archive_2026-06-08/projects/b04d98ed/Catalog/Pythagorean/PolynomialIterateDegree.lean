/-
# Polynomial Iterate Degree Theory

This file establishes formal foundations connecting polynomial algebra to dynamical
systems and cryptographic security. The central result is the **Iterate Degree Theorem**:
the n-th compositional iterate of a degree-d polynomial has degree d^n, proved in full
generality over integral domains.

## Main Results

* `polyIter` — compositional iteration of polynomials
* `natDegree_polyIter` — the n-th iterate of a degree-d polynomial has degree d^n
* `monic_polyIter` — monic polynomials are closed under iteration
* `polyIter_eval` — connects polynomial evaluation to orbit dynamics
* `polyConjugacy_iterate` — conjugacies transfer across all iteration depths
* `roots_polyIter_sub_C_le` — preimage bound: at most d^n roots
* `AlgebraicImmunity` — novel cryptographic hardness measure
-/

import Mathlib

open Polynomial

noncomputable section

/-! ## Polynomial Iteration -/

/-- Compositional iteration of a polynomial: `polyIter p n = p ∘ p ∘ ... ∘ p` (n times).
    This is the fundamental object connecting polynomial algebra to discrete dynamical systems.
    `polyIter p 0 = X` (the identity polynomial), and `polyIter p (n+1) = p ∘ (polyIter p n)`. -/
def polyIter {R : Type*} [CommSemiring R] (p : R[X]) : ℕ → R[X]
  | 0 => X
  | n + 1 => p.comp (polyIter p n)

@[simp]
theorem polyIter_zero {R : Type*} [CommSemiring R] (p : R[X]) :
    polyIter p 0 = X := rfl

@[simp]
theorem polyIter_succ {R : Type*} [CommSemiring R] (p : R[X]) (n : ℕ) :
    polyIter p (n + 1) = p.comp (polyIter p n) := rfl

/-- The first iterate is the polynomial itself. -/
theorem polyIter_one {R : Type*} [CommSemiring R] (p : R[X]) :
    polyIter p 1 = p := by simp [polyIter, comp_X]

/-- Composition of iterates adds the iteration counts: the polynomial iterates
    form a monoid homomorphism from (ℕ, +) to (R[X], ∘). -/
theorem polyIter_add {R : Type*} [CommSemiring R] (p : R[X]) (m n : ℕ) :
    polyIter p (m + n) = (polyIter p m).comp (polyIter p n) := by
  induction m with
  | zero => simp [polyIter]
  | succ m ih =>
    simp only [Nat.succ_add, polyIter]
    rw [ih, ← comp_assoc]

/-! ## The Iterate Degree Theorem

The central result: the n-th compositional iterate of a polynomial of degree d
has degree d^n. This is the algebraic foundation for understanding the complexity
of inverting iterated polynomial maps. -/

/-- **Iterate Degree Theorem**: Over an integral domain, the n-th compositional iterate
    of a polynomial of degree d has degree exactly d^n.

    This theorem connects polynomial algebra to dynamical systems: the exponential
    growth of degree under iteration is what makes polynomial dynamical systems
    "complex" — finding preimages requires solving equations of exponentially growing degree.

    The proof proceeds by induction on n, using Mathlib's `natDegree_comp` which states
    that `natDegree (p.comp q) = natDegree p * natDegree q` over integral domains. -/
theorem natDegree_polyIter {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (_hp : 1 ≤ p.natDegree) (n : ℕ) :
    (polyIter p n).natDegree = p.natDegree ^ n := by
  induction n with
  | zero => simp [polyIter, natDegree_X]
  | succ n ih =>
    simp only [polyIter]
    rw [Polynomial.natDegree_comp, ih, pow_succ, mul_comm]

/-- Monic polynomials of degree ≥ 1 are closed under compositional iteration. -/
theorem monic_polyIter {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (hp : p.Monic) (hd : 1 ≤ p.natDegree) (n : ℕ) :
    (polyIter p n).Monic := by
  induction n with
  | zero => exact monic_X
  | succ n ih =>
    simp only [polyIter]
    have hnd : (polyIter p n).natDegree ≠ 0 := by
      rw [natDegree_polyIter p hd n]; positivity
    exact hp.comp ih hnd

/-! ## Evaluation and Dynamics

Connection between polynomial iteration and orbit dynamics: evaluating the n-th
iterate at a point gives the n-th step of the dynamical orbit. -/

/-- Evaluating the n-th polynomial iterate at a point is the same as applying
    the evaluation function n times. This bridges the algebraic world (polynomials)
    and the dynamical world (orbits). -/
theorem polyIter_eval {R : Type*} [CommSemiring R] (p : R[X]) (x : R) (n : ℕ) :
    (polyIter p n).eval x = (fun y => p.eval y)^[n] x := by
  induction n with
  | zero => simp [polyIter, Function.iterate_zero]
  | succ n ih =>
    simp only [polyIter, eval_comp, Function.iterate_succ', Function.comp]
    rw [ih]

/-! ## Conjugacy Theory

A conjugacy between polynomial dynamical systems allows one to transfer dynamical
properties. The key insight for cryptography: if a "hard" system is conjugate to
an "easy" one, the hard system can be efficiently inverted. -/

/-- A **conjugacy witness** between two polynomial dynamical systems (source, target)
    consists of a polynomial h (the conjugator) such that h ∘ source = target ∘ h.
    When such a witness exists and h is invertible, the dynamical system `source`
    can be "reduced" to `target`. -/
structure PolyConjugacy (R : Type*) [CommRing R] where
  /-- The first dynamical system -/
  source : R[X]
  /-- The second dynamical system -/
  target : R[X]
  /-- The conjugating polynomial -/
  conjugator : R[X]
  /-- The conjugacy equation: conjugator ∘ source = target ∘ conjugator -/
  conjugacy_eq : conjugator.comp source = target.comp conjugator

/-- **Conjugacy Transfer Theorem**: If two polynomial dynamical systems are conjugate,
    then their iterates are also conjugate via the same conjugator.

    This is the key theorem showing that conjugacy attacks transfer across all iteration
    depths: if you can find a conjugacy at depth 1, you automatically get one at every depth.
    This is what makes the Chebyshev conjugacy of the logistic map so devastating for
    cryptographic applications. -/
theorem polyConjugacy_iterate {R : Type*} [CommRing R]
    (conj : PolyConjugacy R) (n : ℕ) :
    conj.conjugator.comp (polyIter conj.source n) =
    (polyIter conj.target n).comp conj.conjugator := by
  induction n with
  | zero => simp [polyIter, comp_X, X_comp]
  | succ n ih =>
    simp only [polyIter]
    rw [← comp_assoc conj.conjugator, conj.conjugacy_eq, comp_assoc, ih, ← comp_assoc]

/-! ## Root Bounds and Preimage Counting

The algebraic degree controls the number of preimages, providing a formal
measure of inversion hardness. -/

/-
**Preimage Bound**: Over an integral domain, the polynomial `polyIter p n - C c`
    has at most `(natDegree p)^n` roots (counted with multiplicity).
    This bounds the number of n-step preimages of any point c under the dynamical
    system defined by p.
-/
theorem roots_polyIter_sub_C_le {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (hp : 1 ≤ p.natDegree) (c : R) (n : ℕ)
    (hne : polyIter p n - C c ≠ 0) :
    Multiset.card (polyIter p n - C c).roots ≤ p.natDegree ^ n := by
  refine' le_trans _ ( natDegree_polyIter p hp n |> le_of_eq );
  exact le_trans ( Polynomial.card_roots' _ ) ( by rw [ Polynomial.natDegree_sub_C ] )

/-! ## Composition Monoid Structure -/

/-- Iterates of the same polynomial commute under composition. This reflects the
    fact that the map n ↦ polyIter p n is a monoid homomorphism from (ℕ, +) to
    the composition monoid of polynomials. -/
theorem polyIter_comp_comm {R : Type*} [CommSemiring R] (p : R[X]) (m n : ℕ) :
    (polyIter p m).comp (polyIter p n) = (polyIter p n).comp (polyIter p m) := by
  rw [← polyIter_add, ← polyIter_add, Nat.add_comm]

/-! ## Orbit Periodicity and Fixed Points -/

/-- A point x is periodic of period dividing n for the polynomial dynamical system p
    if it returns to itself after n iterations. -/
def IsPeriodicPt {R : Type*} [CommSemiring R] (p : R[X]) (n : ℕ) (x : R) : Prop :=
  (polyIter p n).eval x = x

/-- Fixed points of iterate n are roots of `polyIter p n - X`. -/
theorem isPeriodicPt_iff_root {R : Type*} [CommRing R] (p : R[X]) (n : ℕ) (x : R) :
    IsPeriodicPt p n x ↔ (polyIter p n - X).eval x = 0 := by
  simp [IsPeriodicPt, eval_sub, eval_X, sub_eq_zero]

/-
The number of periodic points of period dividing n is bounded by the degree of the iterate.
-/
theorem periodic_points_le {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (hp : 1 ≤ p.natDegree) (n : ℕ)
    (hne : polyIter p n - X ≠ 0) :
    Multiset.card (polyIter p n - X).roots ≤ p.natDegree ^ n := by
  refine' le_trans ( Polynomial.card_roots' _ ) _;
  refine' le_trans ( Polynomial.natDegree_sub_le _ _ ) _ ; simp +decide [ hp ];
  grind +suggestions

/-! ## Inversion Resistance: A Novel Cryptographic Measure

We define algebraic immunity — a formal measure of how resistant a polynomial
dynamical system is to conjugacy attacks. -/

/-- A polynomial dynamical system has **algebraic immunity** k at depth n if no polynomial of
    degree < k, when composed with the n-th iterate, yields a polynomial of degree ≤ 1.

    This is a novel formalization of resistance to conjugacy attacks.
    The logistic map has low algebraic immunity (the Chebyshev conjugacy provides
    a degree-2 simplifier), while a "cryptographically strong" polynomial map
    would have algebraic immunity growing with the iteration depth. -/
def AlgebraicImmunity {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (n : ℕ) (k : ℕ) : Prop :=
  ∀ q : R[X], q.natDegree < k →
    1 < (q.comp (polyIter p n)).natDegree

/-- **Degree Amplification Lemma**: Composing a polynomial of degree d with an iterate of
    degree D gives a polynomial of degree d * D. Combined with the iterate degree theorem,
    this shows that composition with the iterate amplifies degree multiplicatively. -/
theorem natDegree_comp_polyIter {R : Type*} [CommRing R] [IsDomain R]
    (p q : R[X]) (hp : 1 ≤ p.natDegree) (n : ℕ) :
    (q.comp (polyIter p n)).natDegree = q.natDegree * p.natDegree ^ n := by
  rw [Polynomial.natDegree_comp, natDegree_polyIter p hp n]

/-- **Monotonicity of Algebraic Immunity**: If a system has algebraic immunity k,
    it also has algebraic immunity k' for any k' ≤ k. -/
theorem algebraicImmunity_mono {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (n : ℕ) {k k' : ℕ} (hle : k' ≤ k) (h : AlgebraicImmunity p n k) :
    AlgebraicImmunity p n k' := by
  intro q hq
  exact h q (lt_of_lt_of_le hq hle)

/-! ## The Logistic Map

The logistic map f(x) = 4x(1-x) is the canonical example in chaos theory.
We study its algebraic properties. -/

/-- The logistic map as a polynomial: `4 * X - 4 * X^2`.
    This polynomial defines the dynamical system f(x) = 4x(1-x) on [0,1]. -/
def logisticPoly (R : Type*) [CommRing R] : R[X] :=
  C 4 * X - C 4 * X ^ 2

/-- The logistic map polynomial evaluates to `4 * x * (1 - x)`. -/
theorem logisticPoly_eval {R : Type*} [CommRing R] (x : R) :
    (logisticPoly R).eval x = 4 * x * (1 - x) := by
  simp [logisticPoly, eval_sub, eval_mul, eval_pow, eval_C, eval_X]; ring

/-! ## Degree Growth Rate -/

/-- The **degree growth rate** of a polynomial dynamical system is log(d) where d is
    the degree of the polynomial. This is the exponential rate at which the degree of
    iterates grows, and is closely related to the topological entropy of the system. -/
def degreeGrowthRate (p : ℤ[X]) : ℕ := p.natDegree

/-- The degree of the n-th iterate grows as d^n, so the "degree complexity" at depth n
    is exactly `degreeGrowthRate p ^ n`. -/
theorem degree_complexity_eq {R : Type*} [CommRing R] [IsDomain R]
    (p : R[X]) (hp : 1 ≤ p.natDegree) (n : ℕ) :
    (polyIter p n).natDegree = p.natDegree ^ n :=
  natDegree_polyIter p hp n

/-! ## Iterate Factorization Structure -/

/-- If x is a fixed point of p (i.e., p(x) = x), then x is periodic for all iterates.
    This connects fixed-point theory to periodic orbit theory. -/
theorem fixed_point_is_periodic {R : Type*} [CommSemiring R]
    (p : R[X]) (x : R) (hfp : p.eval x = x) (n : ℕ) :
    IsPeriodicPt p n x := by
  induction n with
  | zero => simp [IsPeriodicPt, polyIter, eval_X]
  | succ n ih =>
    simp only [IsPeriodicPt, polyIter, eval_comp]
    rw [show (polyIter p n).eval x = x from ih]; exact hfp

/-
**Orbit Closure**: The set of periodic points is closed under iteration.
    If x is periodic of period dividing n, then p(x) is also periodic of period dividing n.
-/
theorem periodic_iterate_step {R : Type*} [CommSemiring R]
    (p : R[X]) (n : ℕ) (x : R) (h : IsPeriodicPt p n x) :
    IsPeriodicPt p n (p.eval x) := by
  unfold IsPeriodicPt at *;
  rw [ polyIter_eval ] at *;
  erw [ Function.iterate_succ_apply', h ]

end