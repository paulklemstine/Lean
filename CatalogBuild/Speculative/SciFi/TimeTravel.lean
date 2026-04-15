/-! # CatalogBuild.Speculative.SciFi.TimeTravel

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3
-/

import Mathlib

/-- [Section: ## The Knaster-Tarski Theorem (Order-Theoretic Fixed Points)
If timelines can be ordered and time travel preserves this ordering,
then the set of self-consistent timelines is rich and structured.] -/
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


/-- [Section: ## Iterated Function Systems and Temporal Loops
A time loop that repeats n times is mathematically equivalent to computing
the n-th iterate of a function.] -/
theorem iterate_at_fixed_point {X : Type*} (f : X → X)
    (x : X) (hx : f x = x) (n : ℕ) :
    f^[n] x = x := by
  exact Function.iterate_fixed hx n


/-- [Section: ## The Bootstrap Paradox: Self-Referential Objects
The bootstrap paradox creates an object that is its own cause.
Mathematically, this is simply a fixed point.] -/
theorem bootstrap_self_consistent {X : Type*} (f : X → X)
    (x : X) (hfx : f x = x) :
    f (f x) = f x := by
  grind +suggestions

