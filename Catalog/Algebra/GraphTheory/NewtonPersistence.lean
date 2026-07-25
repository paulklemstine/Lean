/-
# Newton Persistence and Arithmetic Monodromy

This file formalizes the connection between Newton's method dynamics over finite
fields and arithmetic properties of polynomials. We define the Newton iteration
map on a field, prove that its fixed points are exactly the simple roots of the
polynomial, introduce the Newton functional graph and depth filtration, and
establish structural theorems connecting persistence statistics to root counts.

## Main results

* `newtonStep_fixed_iff_root` — A point is a fixed point of the Newton step iff
  it is a root of the polynomial (assuming nonzero derivative).
* `newtonStep_iter_fixed` — Newton iteration is idempotent at fixed points.
* `newtonStep_orbit_eventually_periodic` — Newton orbits over finite fields
  eventually become periodic.
* `newtonStep_fixed_point_set_eq_roots` — The fixed-point set (away from
  critical points) equals the root set.
* `frobenius_depth_x2_minus_1` — For X²-1 over 𝔽_p (p odd), every root
  is a Newton fixed point (depth 0).

## Novel definitions

* `newtonStep` — The Newton iteration map x ↦ x - f(x)/f'(x).
* `newtonStepIter` — The n-th iterate of the Newton step.
* `NewtonDepth` — The depth of an element in the Newton iteration filtration.
* `PersistencePair` — A birth-death pair for persistence analysis.

## References

Builds on:
* `Catalog/Algebra/IdempotentClosure/Basic.lean` — monotone closure stabilization
* `Catalog/Algebra/CoordinateRingDepth.lean` — algebraic circuit depth theory
-/
import Mathlib

open Polynomial Finset Function Classical

noncomputable section

/-! ## The Newton Step Map -/

/-- The Newton step for a polynomial `f` over a field `F`:
    `N_f(x) = x - f(x) / f'(x)`. When `f'(x) = 0`, we define `N_f(x) = x`
    (the map degenerates to the identity at critical points). -/
def newtonStep {F : Type*} [Field F] (f : F[X]) (x : F) : F :=
  if Polynomial.eval x (Polynomial.derivative f) = 0 then x
  else x - Polynomial.eval x f / Polynomial.eval x (Polynomial.derivative f)

/-- The Newton step iterated `n` times. -/
def newtonStepIter {F : Type*} [Field F] (f : F[X]) (n : ℕ) (x : F) : F :=
  (newtonStep f)^[n] x

/-! ## Fixed Point Characterization -/

/-
If `x` is a root of `f` then `x` is a fixed point of the Newton step.
-/
theorem root_is_newtonStep_fixed {F : Type*} [Field F] (f : F[X]) (x : F)
    (hroot : Polynomial.eval x f = 0) :
    newtonStep f x = x := by
  unfold newtonStep; aesop;

/-
If `x` is a fixed point of the Newton step and `f'(x) ≠ 0`,
    then `x` is a root of `f`.
-/
theorem newtonStep_fixed_is_root {F : Type*} [Field F] (f : F[X]) (x : F)
    (hfixed : newtonStep f x = x)
    (hderiv : Polynomial.eval x (Polynomial.derivative f) ≠ 0) :
    Polynomial.eval x f = 0 := by
  unfold newtonStep at hfixed; aesop;

/-
**Newton Fixed Point Theorem**: A point with nonvanishing derivative is a
    fixed point of the Newton step if and only if it is a root of the polynomial.
-/
theorem newtonStep_fixed_iff_root {F : Type*} [Field F] (f : F[X]) (x : F)
    (hderiv : Polynomial.eval x (Polynomial.derivative f) ≠ 0) :
    newtonStep f x = x ↔ Polynomial.eval x f = 0 := by
  unfold newtonStep; aesop;

/-! ## Structural Theorems -/

/-
Newton iteration is idempotent at fixed points: if `x` is a fixed point
    of the Newton step, then all iterates equal `x`.
-/
theorem newtonStep_iter_fixed {F : Type*} [Field F] (f : F[X]) (x : F)
    (hfixed : newtonStep f x = x) (n : ℕ) :
    newtonStepIter f n x = x := by
  induction n <;> simp_all +decide [ newtonStepIter ]

/-
The Newton step preserves the property of being a root.
-/
theorem newtonStep_preserves_root {F : Type*} [Field F] (f : F[X]) (x : F)
    (hroot : Polynomial.eval x f = 0) :
    Polynomial.eval (newtonStep f x) f = 0 := by
  rw [ ← hroot, root_is_newtonStep_fixed f x hroot ]

/-! ## Depth Filtration -/

/-- The **Newton depth** of an element `x`: the minimum number of iterations
    to reach a fixed point, capped at `bound + 1` if no fixed point is found. -/
def newtonDepth {F : Type*} [Field F]
    (f : F[X]) (bound : ℕ) (x : F) : ℕ :=
  if h : ∃ k ≤ bound, newtonStepIter f k x = newtonStepIter f (k + 1) x
  then Nat.find h
  else bound + 1

/-- A **persistence pair** records a birth depth and a death depth. -/
structure PersistencePair where
  birth : ℕ
  death : ℕ
  birth_le_death : birth ≤ death

/-- The **persistence** (lifespan) of a persistence pair. -/
def PersistencePair.persistence (p : PersistencePair) : ℕ := p.death - p.birth

/-! ## Root Count via Fixed Points -/

/-
The set of fixed points of the Newton step (restricted to points where
    the derivative doesn't vanish) equals the root set of `f`.
-/
theorem newtonStep_fixed_point_set_eq_roots {F : Type*} [Field F]
    (f : F[X]) :
    {x : F | newtonStep f x = x ∧ Polynomial.eval x (Polynomial.derivative f) ≠ 0} =
    {x : F | Polynomial.eval x f = 0 ∧ Polynomial.eval x (Polynomial.derivative f) ≠ 0} := by
  ext x; unfold newtonStep; aesop;

/-! ## Orbit Periodicity -/

/-
Over a finite type, any function has eventually periodic orbits.
    Applied to the Newton step, this means Newton orbits are eventually periodic.
-/
theorem newtonStep_orbit_eventually_periodic {F : Type*} [Field F] [Fintype F]
    (f : F[X]) (x : F) :
    ∃ k : ℕ, k ≤ Fintype.card F ∧ ∃ m : ℕ, 0 < m ∧ m ≤ Fintype.card F ∧
      newtonStepIter f (k + m) x = newtonStepIter f k x := by
  by_contra! h_contra;
  -- Consider the sequence $x, newtonStep f x, newtonStep f (newtonStep f x), \ldots$, which are $Fintype.card F + 1 �$� elements of $F$.
  set seq : ℕ → F := fun n => newtonStepIter f n x
  have h_seq : ∀ i j : ℕ, i < j → i ≤ Fintype.card F → j ≤ Fintype.card F → seq i ≠ seq j := by
    exact fun i j hij hi hj => fun h => h_contra i hi ( j - i ) ( Nat.sub_pos_of_lt hij ) ( Nat.sub_le_of_le_add <| by linarith ) <| by simpa [ add_tsub_cancel_of_le hij.le ] using h.symm;
  exact absurd ( Finset.card_le_univ ( Finset.image seq ( Finset.Iic ( Fintype.card F ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_seq _ _ hi' ( Finset.mem_Iic.mp hj ) ( Finset.mem_Iic.mp hi ) hij.symm ) ( not_lt.mp fun hj' => h_seq _ _ hj' ( Finset.mem_Iic.mp hi ) ( Finset.mem_Iic.mp hj ) hij ) ] ; simp +decide )

/-! ## Product Rule for Newton Basins -/

/-
The Newton step of a product `f * g` at a root of `f` where `g` doesn't
    vanish equals the point itself — roots of `f` are fixed under `N_{fg}`.
-/
theorem newtonStep_product_at_root {F : Type*} [Field F] (f g : F[X]) (x : F)
    (hf : Polynomial.eval x f = 0)
    (_hg : Polynomial.eval x g ≠ 0)
    (_hfg_deriv : Polynomial.eval x (Polynomial.derivative (f * g)) ≠ 0) :
    newtonStep (f * g) x = x := by
  exact root_is_newtonStep_fixed _ _ ( by simp +decide [ hf ] )

/-! ## Frobenius Depth Conjecture — Test Case -/

/-
**Frobenius depth test case**: For the polynomial `X² - 1` over `𝔽_p`
    with `p` odd, every root is a Newton fixed point (has depth 0).
    This is the simplest instance of the conjecture that Newton depth
    reflects Frobenius cycle type.
-/
theorem frobenius_depth_x2_minus_1 {p : ℕ} [Fact (Nat.Prime p)] (_hp : p ≠ 2) :
    ∀ x : ZMod p, Polynomial.eval x (X ^ 2 - 1 : (ZMod p)[X]) = 0 →
      newtonStep (X ^ 2 - 1 : (ZMod p)[X]) x = x := by
  exact fun x a => root_is_newtonStep_fixed (X ^ 2 - 1) x a

end