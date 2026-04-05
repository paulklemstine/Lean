import Mathlib

/-!
# 🌀 The Twilight Zone Theorems

## The Liminal Space Between the Finite and the Infinite

"You're traveling through another dimension, a dimension not only of sight
and sound but of mind." — Rod Serling

The Twilight Zone of mathematics is the boundary between:
- Finite and infinite
- Decidable and undecidable
- Constructive and non-constructive
- Computable and uncomputable

These theorems live in that liminal space, revealing truths that feel
impossible but are rigorously proven.

## Key Results Formalized

1. ℕ and ℤ are equinumerous (Hilbert's Hotel)
2. The uncountability of the reals
3. The power set is always strictly larger
4. The axiom of choice gives sections
5. Russell's paradox and the liar paradox
6. Rationals and irrationals are perfectly interwoven
-/

open Set Function

noncomputable section

/-! ## §1: The Twilight Zone of Cardinality -/

/-
PROBLEM
ℕ and ℤ have the same cardinality — the first twilight zone result.
    An infinite hotel has room for infinitely many more guests.

PROVIDED SOLUTION
Use the standard bijection between ℤ and ℕ. In Mathlib, Int.equivNat or similar might exist. Or construct explicitly: map n ≥ 0 to 2n, map n < 0 to 2|n|-1. Actually just use Cardinal.mk_int and show the types have the same cardinality, or use Equiv.intEquivNat and extract the bijective function.
-/
theorem hilbert_hotel : ∃ f : ℤ → ℕ, Bijective f := by
  exact ⟨ _, Equiv.bijective ( Classical.arbitrary _ ) ⟩

/-
PROBLEM
No surjection from ℕ to ℝ — the reals live in a higher twilight zone.

PROVIDED SOLUTION
ℝ is uncountable. Use Cardinal.not_countable_real or mk_real, or the fact that Set.Countable implies... Actually the simplest is to use the fact that ℝ has strictly larger cardinality than ℕ. In Mathlib, Cardinal.lt_aleph0 and similar. Or use not_countable (Set.univ : Set ℝ) combined with countable_range.
-/
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
theorem power_set_strictly_larger (α : Type*) :
    ¬ ∃ f : α → Set α, Surjective f := by
  intro h;
  haveI := h.choose_spec;
  convert Cardinal.mk_le_of_surjective this;
  simp +decide [ Cardinal.mk_real ];
  exact Cardinal.cantor _

/-! ## §2: The Twilight Zone of Choice -/

/-
PROBLEM
The axiom of choice is equivalent to: every surjection has a right inverse.
    We prove the easy direction: choice gives sections.

PROVIDED SOLUTION
Use Classical.choice to pick a preimage for each b. Define g(b) = Classical.choose (hf b). Then f(g(b)) = b by Classical.choose_spec. Use funext to show f ∘ g = id.
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
theorem rationals_dense (x y : ℝ) (hxy : x < y) :
    ∃ q : ℚ, x < (q : ℝ) ∧ (q : ℝ) < y := by
  exact exists_rat_btwn hxy

/-
PROBLEM
Between any two rationals lies an irrational.
    The irrationals are also dense. The two worlds are perfectly interwoven.

PROVIDED SOLUTION
Take r = (a + b) / 2 + √2 * ε for small enough ε, or more simply: the interval (a, b) is uncountable (as it's homeomorphic to ℝ) while ℚ is countable, so there must be irrationals in (a, b). More constructively: a + (b-a)/√2 works. Or use that a < a + (b-a) * (1/√2) < b and show this is irrational.
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