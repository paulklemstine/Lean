/-! # CatalogBuild.Logic.GodelianSelfReference

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3
-/

import Mathlib

theorem cantor_via_bool (α : Type*) : ¬ ∃ f : α → α → Bool, Surjective f := by
  convert cantor_via_lawvere ( Bool.not ) _;
  grobner

/-! ## Knaster-Tarski Fixed Point Theorem

The Knaster-Tarski theorem states that every monotone function on a
complete lattice has a fixed point. Rucker discusses fixed points
as fundamental to self-referential constructions.
-/

/-
PROBLEM
The Knaster-Tarski fixed point theorem: every monotone function on a
  complete lattice has a least fixed point.

PROVIDED SOLUTION
Let x = sInf {y | f y ≤ y}. Show f x = x using monotonicity and completeness. Then show x is least among fixed points.
-/

theorem no_self_deciding_predicate (α : Type*) :
    ¬ ∃ (eval : α → α → Prop) (_ : Surjective eval),
      ∃ neg : α, ∀ a, eval neg a ↔ ¬ eval a a := by
        norm_num +zetaDelta at *;
        intro x hx y; use y; by_cases h : x y y <;> simp +decide [ h ] ;

/-! ## Infinity of Primes — A Concrete Diagonal Construction

Rucker discusses Euclid's proof as an early "diagonal argument":
you take everything you have and construct something new.
We formalize this as a connection to Rucker's themes.
-/

/-
Euclid's theorem: there are infinitely many primes.
  Rucker sees this as a proto-diagonal argument: given any finite
  list of primes, you construct a new one.
-/

theorem no_enumeration_of_subsets :
    ¬ ∃ f : ℕ → Set ℕ, Surjective f := by
      -- Apply the fact that there is no surjection from a set to its power set.
      apply cantor_via_lawvere;
      swap;
      exact fun b => ¬b;
      grind

