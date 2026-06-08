import Mathlib

/-!
# Exceptional Set Finiteness: Definitions

## Overview

This file introduces the obstruction-theoretic language for studying
the exceptional set of parameters `c ∈ ℤ` where Benford universality
fails for the quadratic dynamical system `T_c(x) = x² + c`.

The key conceptual contribution is the separation of:
- **Global digital failure** (`ExceptionalParameter`): Benford universality fails.
- **Local arithmetic degeneracy** (`LocalObstruction`): the orbit is eventually
  periodic modulo some prime.
- **Admissibility** (`AdmissibleParameter`): no local obstruction exists.

This language enables a local-to-global principle: exceptional behavior must
be witnessed by a finite-level modular degeneracy.

## Definitions

- `EventuallyPeriodic`: a sequence eventually repeats with some period.
- `BenfordUniversal`: a sequence has unbounded absolute values (necessary
  condition for meaningful Benford digit statistics).
- `DegenerateModPrime`: the orbit is eventually periodic modulo a prime.
- `ExceptionalParameter`: Benford universality fails for the orbit.
- `LocalObstruction`: there exists a prime witnessing modular degeneracy.
- `AdmissibleParameter`: no local obstruction exists.
- `FiniteDepthObstruction`: computably checkable finite-depth version.
-/

noncomputable section

open Finset Filter Set

/-! ## Dynamical System -/

/-- One step of the quadratic map T_c(x) = x² + c. -/
def quadraticStep (c : ℤ) (x : ℤ) : ℤ := x ^ 2 + c

/-- The orbit of x under T_c, defined recursively. -/
def quadIter (c : ℤ) (x : ℤ) : ℕ → ℤ
  | 0 => x
  | n + 1 => quadraticStep c (quadIter c x n)

@[simp] theorem quadIter_zero (c x : ℤ) : quadIter c x 0 = x := rfl
@[simp] theorem quadIter_succ (c x : ℤ) (n : ℕ) :
    quadIter c x (n + 1) = quadraticStep c (quadIter c x n) := rfl

/-! ## Periodicity -/

/-- A sequence `f : ℕ → ℤ` is eventually periodic if there exist
a preperiod `N` and period `p > 0` such that `f(n + p) = f(n)` for all `n ≥ N`. -/
def EventuallyPeriodic (f : ℕ → ℤ) : Prop :=
  ∃ N p : ℕ, 0 < p ∧ ∀ n, N ≤ n → f (n + p) = f n

/-! ## Benford Universality -/

/-- A sequence is Benford-universal if its absolute values are unbounded.
This is a necessary condition for the leading-digit distribution to converge
to Benford's law: a bounded sequence can only produce finitely many distinct
leading digits with rational frequencies, which cannot match the irrational
Benford probabilities log₁₀(1 + 1/d).

Mathematically, unboundedness ensures the orbit explores all scales,
which is the dynamical prerequisite for logarithmic equidistribution. -/
def BenfordUniversal (f : ℕ → ℤ) : Prop :=
  ∀ M : ℕ, ∃ n : ℕ, M < (f n).natAbs

/-! ## Modular Degeneracy -/

/-- The orbit is degenerate modulo a prime `p` if the sequence of residues
`f(n) mod p` is eventually periodic. This captures the arithmetic shadow
of dynamical collapse: the orbit gets trapped in a finite cycle modulo `p`.

For the quadratic map, eventual periodicity mod `p` means the orbit
visits only finitely many residue classes, a strong constraint that
limits the logarithmic equidistribution needed for Benford behavior. -/
def DegenerateModPrime (f : ℕ → ℤ) (p : ℕ) : Prop :=
  EventuallyPeriodic (fun n => f n % (p : ℤ))

/-! ## Exceptional Set Language -/

/-- A parameter `c` is exceptional for the dynamical system `T` if
Benford universality fails for the orbit `T c`. -/
def ExceptionalParameter (T : ℤ → ℕ → ℤ) (c : ℤ) : Prop :=
  ¬ BenfordUniversal (T c)

/-- A parameter `c` has a local obstruction if there exists a prime `p`
such that the orbit `T c` is degenerate modulo `p`. This is the
arithmetic fingerprint of digital anomaly. -/
def LocalObstruction (T : ℤ → ℕ → ℤ) (c : ℤ) : Prop :=
  ∃ p : ℕ, Nat.Prime p ∧ DegenerateModPrime (T c) p

/-- A parameter `c` is admissible if it has no local obstruction:
the orbit is non-degenerate modulo every prime. -/
def AdmissibleParameter (T : ℤ → ℕ → ℤ) (c : ℤ) : Prop :=
  ¬ LocalObstruction T c

/-- A finite-depth obstruction is a computably checkable version of
degeneracy: within the first `N` iterates, two distinct iterates
have the same residue mod `p`. By the pigeonhole principle, this
witnesses eventual periodicity for orbits in `ℤ/pℤ`. -/
def FiniteDepthObstruction (f : ℕ → ℤ) (p : ℕ) (N : ℕ) : Prop :=
  ∃ i j : ℕ, i < j ∧ j ≤ N ∧ f i % (p : ℤ) = f j % (p : ℤ)

/-- The exceptional set: all parameters `c` where Benford universality fails. -/
def ExceptionalSet (T : ℤ → ℕ → ℤ) : Set ℤ :=
  {c : ℤ | ExceptionalParameter T c}

end