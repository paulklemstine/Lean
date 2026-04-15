/-! # CatalogBuild.Speculative.SciFi.TimeTravel

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3
-/

import Mathlib

theorem monotone_has_fixed_point {L : Type*} [CompleteLattice L]
    (f : L → L) (hf : Monotone f) :
    ∃ x, f x = x := by
  -- By the Knaster-Tarski theorem, since $f$ is monotone, it has a least fixed point.
  have h_least_fixed_point : ∃ x, IsLeast {x | f x ≤ x} x := by
    refine' ⟨ _, ⟨ _, fun x hx => _ ⟩ ⟩;
    exact ⨅ x : { x // f x ≤ x }, x.val;
    · simp +zetaDelta at *;
      exact fun x hx => le_trans ( hf <| iInf_le _ ⟨ x, hx ⟩ ) hx;
    · exact iInf_le_of_le ⟨ x, hx ⟩ le_rfl;
  obtain ⟨ x, hx ⟩ := h_least_fixed_point;
  exact ⟨ x, le_antisymm hx.1 ( hx.2 ( hf hx.1 ) ) ⟩

/-! ## Iterated Function Systems and Temporal Loops

A time loop that repeats n times is mathematically equivalent to computing
the n-th iterate of a function. -/

/-
If f has a unique fixed point x*, then the iterates f^n(y) converge to x*
    for any starting point y (in a contraction mapping setting).
    Here we prove the simpler statement: the iterate of f at the fixed point
    is still the fixed point.
-/

theorem iterate_at_fixed_point {X : Type*} (f : X → X)
    (x : X) (hx : f x = x) (n : ℕ) :
    f^[n] x = x := by
  exact Function.iterate_fixed hx n

/-! ## The Bootstrap Paradox: Self-Referential Objects

The bootstrap paradox creates an object that is its own cause.
Mathematically, this is simply a fixed point. -/

/-
If f(x) = x (x is a fixed point), then the "origin" of x is x itself.
    This is the mathematical content of the bootstrap paradox: the object
    x exists self-consistently without requiring an external cause.
-/

theorem bootstrap_self_consistent {X : Type*} (f : X → X)
    (x : X) (hfx : f x = x) :
    f (f x) = f x := by
  grind +suggestions

