import Mathlib

/-!
# Tropical Energy Semantics: Definitions

We define a simply-typed lambda calculus with de Bruijn indices and a
**tropical potential** — a compositional energy function that reinterprets
β-reduction as irreversible energy dissipation.

## Key Concepts

* **Type depth** (tropical height): measures computational nesting of function types.
* **Tropical potential** (product interpretation): a multiplicative energy that
  decomposes algebraically under substitution.
* **Parameterized potential**: the key technical device for tracking how
  substitution transforms energy by replacing variable weights.
-/

namespace TropicalEnergy

/-! ## Simple Types -/

/-- Simple types for the lambda calculus. -/
inductive Ty where
  | base : Ty
  | arr : Ty → Ty → Ty
  deriving DecidableEq, Repr

/-- Type depth: the tropical height of a type.
    Measures the maximum nesting depth of arrow types on the left. -/
def typeDepth : Ty → ℕ
  | .base => 0
  | .arr A B => max (typeDepth A + 1) (typeDepth B)

/-- Type weight: additive measure of type complexity. -/
def typeWeight : Ty → ℕ
  | .base => 1
  | .arr A B => typeWeight A + typeWeight B + 1

/-! ## Lambda Terms (de Bruijn) -/

/-- Lambda calculus terms with de Bruijn indices. -/
inductive Tm where
  | var : ℕ → Tm
  | lam : Tm → Tm
  | app : Tm → Tm → Tm
  deriving DecidableEq, Repr

/-! ## Lifting (Renaming) -/

/-- Lift free variables ≥ c by 1. Used when traversing under a binder. -/
def Tm.lift (c : ℕ) : Tm → Tm
  | .var n => .var (if n < c then n else n + 1)
  | .lam t => .lam (Tm.lift (c + 1) t)
  | .app f a => .app (Tm.lift c f) (Tm.lift c a)

/-! ## Substitution -/

/-- Substitute variable `n` with `s`, shifting free variables > n down by 1. -/
def Tm.substN (n : ℕ) (s : Tm) : Tm → Tm
  | .var m => if m < n then .var m
              else if m = n then s
              else .var (m - 1)
  | .lam t => .lam (Tm.substN (n + 1) (Tm.lift 0 s) t)
  | .app f a => .app (Tm.substN n s f) (Tm.substN n s a)

/-- Top-level substitution: replace variable 0 with `s`. -/
def Tm.substTop (s : Tm) (t : Tm) : Tm := Tm.substN 0 s t

/-! ## Occurrence Counting -/

/-- Count occurrences of variable `n` in a term.
    Under binders, the target index shifts up. -/
def Tm.occN (n : ℕ) : Tm → ℕ
  | .var m => if m = n then 1 else 0
  | .lam t => Tm.occN (n + 1) t
  | .app f a => Tm.occN n f + Tm.occN n a

/-! ## Term Size -/

/-- Standard size (number of nodes). -/
def Tm.size : Tm → ℕ
  | .var _ => 1
  | .lam t => Tm.size t + 1
  | .app f a => Tm.size f + Tm.size a + 1

/-! ## Tropical Potential (Product Interpretation) -/

/-- The tropical potential assigns each term a natural number "energy".

    * Variables have ground energy 2 (the tropical base level).
    * Lambda abstraction stores +1 binding energy.
    * Application **multiplies** energies — the interaction/coupling term.

    This multiplicative structure is the key to the compositional
    substitution theorem: substituting a term of energy `v` for a variable
    simply replaces its weight in the product tree. -/
def tropicalPotential : Tm → ℕ
  | .var _ => 2
  | .lam t => tropicalPotential t + 1
  | .app f a => tropicalPotential f * tropicalPotential a

/-- Parameterized potential: evaluates the product tree with variable `n`
    assigned weight `v` instead of the default 2.

    This is the technical heart of the energy accounting:
    `potentialWith v n t` is a polynomial in `v` whose structure
    mirrors the term's syntax tree. -/
def potentialWith (v : ℕ) (n : ℕ) : Tm → ℕ
  | .var m => if m = n then v else 2
  | .lam t => potentialWith v (n + 1) t + 1
  | .app f a => potentialWith v n f * potentialWith v n a

/-! ## Duplication Load -/

/-- The duplication load of a term at variable `n`:
    excess occurrences beyond the affine limit.
    When this is 0, substitution does not duplicate. -/
def Tm.duplicationLoad (n : ℕ) : Tm → ℕ
  | .var _ => 0
  | .lam t => Tm.duplicationLoad (n + 1) t
  | .app f a => Tm.duplicationLoad n f + Tm.duplicationLoad n a +
                Tm.occN n f * Tm.occN n a

/-! ## Step Relation -/

/-- One-step β-reduction with full contextual closure. -/
inductive Step : Tm → Tm → Prop where
  | beta : Step (.app (.lam t) s) (Tm.substTop s t)
  | appL : Step f f' → Step (.app f a) (.app f' a)
  | appR : Step a a' → Step (.app f a) (.app f a')
  | xi   : Step t t' → Step (.lam t) (.lam t')

/-! ## Tropical Energy Model -/

/-- A tropical energy model packages a potential function together with
    a certified dissipation property: every step in the given reduction
    relation strictly decreases the potential.

    This is the discrete analog of a Lyapunov function for a dynamical system:
    existence of such a model certifies termination. -/
structure TropicalEnergyModel (Step : Tm → Tm → Prop) where
  potential : Tm → ℕ
  dissipative : ∀ {t u : Tm}, Step t u → potential u < potential t

end TropicalEnergy