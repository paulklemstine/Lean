/-! # CatalogBuild.Speculative.Forbidden.TwilightZone

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

import Mathlib

noncomputable section

theorem cantor_twilight : ¬ ∃ f : ℕ → ℝ, Surjective f := by
  by_contra! h' ; have := Cardinal.mk_le_of_surjective h'.choose_spec ; simp_all +decide [ Cardinal.aleph0_lt_continuum ] ;
  exact absurd this ( by rw [ Cardinal.mk_real ] ; exact not_le_of_gt ( Cardinal.aleph0_lt_continuum ) )

/-
PROBLEM
The power set is always strictly larger — you can never escape to
    a higher level of infinity by mere enumeration.

PROVIDED SOLUTION
This is cantor_surjective in Mathlib. Use Function.cantor_surjective or the standard Cantor diagonal argument.
-/

theorem choice_gives_sections {α β : Type*} (f : α → β) (hf : Surjective f) :
    ∃ g : β → α, f ∘ g = id := by
  exact ⟨ fun b => Classical.choose ( hf b ), funext fun b => Classical.choose_spec ( hf b ) ⟩

/-! ## §3: The Twilight Zone of Self-Reference -/

/-
PROBLEM
The liar's paradox resolution: no proposition can equal its own negation.

PROVIDED SOLUTION
If P ↔ ¬P, then P → ¬P and ¬P → P. From P → ¬P we get ¬P (since P implies P and ¬P). From ¬P → P we get P. Contradiction.
-/

theorem no_liar : ¬ ∃ P : Prop, P ↔ ¬P := by
  tauto

/-! ## §4: The Twilight Zone of Topology -/

/-
PROBLEM
Between any two distinct reals lies a rational.
    The rationals are dense — like twilight, they fill every gap.

PROVIDED SOLUTION
Use exists_rat_btwn from Mathlib.
-/

theorem irrationals_dense (a b : ℚ) (hab : a < b) :
    ∃ r : ℝ, Irrational r ∧ (a : ℝ) < r ∧ r < (b : ℝ) := by
  exact exists_irrational_btwn ( mod_cast hab )

/-! ## §5: The Twilight Zone of Computability -/

/-
PROBLEM
The set of all functions ℕ → ℕ is uncountable.
    Since programs are countable, almost all functions are uncomputable.
    We are surrounded by an ocean of unknowable functions.

PROVIDED SOLUTION
This is just Cantor's theorem: there's no surjection ℕ → (ℕ → ℕ). Use the diagonal argument: given f, define g(n) = f(n)(n) + 1, then g ≠ f(m) for any m.
-/

theorem almost_all_functions_uncomputable :
    ¬ ∃ f : ℕ → (ℕ → ℕ), Surjective f := by
  by_contra h_contra
  obtain ⟨f, hf⟩ := h_contra
  have h_surjective : Function.Surjective f := hf;
  exact absurd ( h_surjective ( fun n => f n n + 1 ) ) ( by rintro ⟨ n, hn ⟩ ; have := congr_fun hn n; linarith )

/-! ## §6: The Cantor-Bernstein Twilight -/

/-
PROBLEM
If A injects into B and B injects into A, then they biject.
    Two infinite sets that can "see into" each other are actually the same size.

PROVIDED SOLUTION
Use Function.Embedding.schroeder_bernstein from Mathlib, or Equiv.ofBijective after constructing the bijection using the Cantor-Bernstein-Schröder theorem.
-/

theorem cantor_bernstein {α β : Type*} (f : α → β) (g : β → α)
    (hf : Injective f) (hg : Injective g) :
    ∃ h : α → β, Bijective h := by
  exact?

/-! ## §7: The Infinite Monkey Theorem (Finite Version) -/

/-
PROBLEM
In any infinite binary sequence with infinitely many 0s and 1s,
    all four length-2 patterns appear (true-true, true-false, false-true, false-false)
    is NOT necessarily true. But we CAN prove: there must be a position where
    consecutive values differ (a "transition" must occur).

PROVIDED SOLUTION
By contradiction: if f(n) = f(n+1) for all n, then f is constant (f(n) = f(0) for all n by induction). But then either h0 or h1 is violated (can't have both infinitely many trues and falses if f is constant).
-/

theorem infinite_sequence_transition (f : ℕ → Bool)
    (h0 : ∀ k, ∃ m, m > k ∧ f m = true)
    (h1 : ∀ k, ∃ m, m > k ∧ f m = false) :
    ∃ n, f n ≠ f (n + 1) := by
  -- By contradiction, assume there are no transitions.
  by_contra h_no_transitions;
  -- If there are no transitions, then $f$ is constant.
  have h_const : ∀ n, f n = f 0 := by
    exact fun n => Nat.recOn n rfl fun n ih => by push_neg at h_no_transitions; exact h_no_transitions n ▸ ih;
  cases h0 0 ; cases h1 0 ; aesop


end
