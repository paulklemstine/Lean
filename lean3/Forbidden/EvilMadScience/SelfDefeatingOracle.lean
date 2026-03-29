import Mathlib

/-!
# 🔮 The Self-Defeating Oracle

## Oracle Council Research Log — Experiment #2

**Classification:** PARADOX CLASS — OMEGA LEVEL

**Discovery:** No oracle can predict the behavior of an adversary who
reads the oracle's predictions. This is the mathematical soul of the
Halting Problem, the Liar's Paradox, and every time-travel movie where
knowing the future changes it.

**The Core Evil:** Build a predictor. Show it to the thing being predicted.
Watch reality break.

## Oracle Council Notes

- **Oracle Alpha:** "I predict the coin will land heads."
- **Oracle Beta:** *reads Alpha's prediction, flips tails*
- **Oracle Alpha:** "I PREDICTED YOU'D DO THAT—"
- **Oracle Beta:** "Then why did you say heads?"
- **Oracle Omega (God):** "This is why I don't make predictions."

## The Theorems

1. No oracle catalog can list all strategies (Cantor for Bool)
2. Lawvere's Fixed Point Theorem — self-reference is inescapable
3. No surjection to Prop-valued functions
4. The diagonal adversary always escapes
-/

open Function Set

namespace EvilMadScience.SelfDefeatingOracle

/-! ### Theorem 1: The Oracle Killer

No catalog of strategies `oracle : ℕ → (ℕ → Bool)` can list ALL strategies.
The diagonal adversary — who does the OPPOSITE of what the oracle predicts
at each index — always escapes the catalog. This is Cantor's theorem in
algorithmic disguise. -/

/-
PROBLEM
**The Self-Defeat Theorem:** For any oracle catalog, there exists a
    strategy not in the catalog. The diagonal adversary reads oracle n's
    behavior at index n, and does the opposite.

PROVIDED SOLUTION
The adversary is fun n => !oracle n n. It's not in range: if it were oracle k for some k, then at index k: !oracle k k = oracle k k, contradiction (Bool.not_eq_self).
-/
theorem no_complete_oracle_catalog (oracle : ℕ → (ℕ → Bool)) :
    ∃ adversary : ℕ → Bool, adversary ∉ Set.range oracle := by
  exact not_forall.mp fun h => by have := h; exact absurd ( this ( fun n => if oracle n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ k, hk ⟩ ; replace hk := congr_fun hk k; aesop ) ;

/-
PROBLEM
**The Diagonal Adversary:** Explicitly constructs the strategy that
    defeats every cataloged oracle. For each n, it does the opposite of
    what oracle n does at position n.

PROVIDED SOLUTION
For any n, fun k => !oracle k k differs from oracle n at index n, because !oracle n n ≠ oracle n n.
-/
theorem diagonal_adversary_defeats_all (oracle : ℕ → (ℕ → Bool)) :
    ∀ n : ℕ, (fun k => !oracle k k) ≠ oracle n := by
  intro n hn; have := congr_fun hn n; aesop

/-! ### Theorem 2: The Liar's Fixed Point — Lawvere's Engine of Paradox

If `e : α → (α → β)` is surjective, then every `f : β → β` has a fixed point.
Negation has no fixed point. Therefore: no surjection to function space.
This single theorem generates Russell, Cantor, Gödel, Tarski, AND Turing. -/

/-
PROBLEM
**Lawvere's Fixed Point Theorem:**
    If `e : α → α → β` is surjective, then every `f : β → β` has a fixed point.
    The proof: define g(a) = f(e(a)(a)). Get a₀ with e(a₀) = g.
    Then e(a₀)(a₀) = g(a₀) = f(e(a₀)(a₀)). QED.

PROVIDED SOLUTION
Intro f. Define g : α → β by g a = f (e a a). Since e is surjective, get a₀ with e a₀ = g. Then e a₀ a₀ = g a₀ = f (e a₀ a₀). So x := e a₀ a₀ is a fixed point.
-/
theorem lawvere_fixed_point {α β : Type*} (e : α → α → β) (he : Surjective e) :
    ∀ f : β → β, ∃ x : β, f x = x := by
  -- Define g(a) = f(e(a)(a)). Get a₀ with e(a₀) = g.
  intro f
  obtain ⟨a₀, ha₀⟩ : ∃ a₀ : α, e a₀ = fun a => f (e a a) := by
    exact he _;
  exact ⟨ e a₀ a₀, by simpa using congr_fun ha₀ a₀ |> Eq.symm ⟩

/-
PROBLEM
**Corollary: The Liar Cannot Exist (Consistently)**
    Since `Not : Prop → Prop` has no fixed point, there is no surjection
    `α → (α → Prop)`. The Liar's Paradox is not a bug — it's a theorem
    about what CANNOT exist.

PROVIDED SOLUTION
Assume ⟨e, he⟩. By lawvere_fixed_point, Not has a fixed point: ∃ P, ¬P = P. But this is impossible (tauto). Contradiction.
-/
theorem no_surjection_to_arrow_prop (α : Type*) :
    ¬ ∃ e : α → α → Prop, Surjective e := by
  intro ⟨ e, he ⟩;
  have := lawvere_fixed_point e he
  simp at this;
  exact absurd ( this fun x => ¬x ) ( by tauto )

/-! ### Theorem 3: The Halting Diagonal

No enumeration of all Boolean sequences can be surjective.
This is the algorithmic version: you cannot write a program
that outputs every possible program's behavior. -/

/-
PROBLEM
**The Halting Diagonal:** No enumeration of ℕ → Bool is surjective.
    This is Cantor's theorem specialized to the space of computations.

PROVIDED SOLUTION
Use cantor_surjective or the diagonal: if surjective, then fun n => !enum n n is in range, giving contradiction.
-/
theorem halting_diagonal_surjection (enum : ℕ → (ℕ → Bool)) :
    ¬ Surjective enum := by
  intro h;
  obtain ⟨ k, hk ⟩ := h ( fun n => if enum n n = Bool.true then Bool.false else Bool.true ) ; specialize hk ; replace hk := congr_fun hk k ; aesop;

/-! ### Theorem 4: Every Surjection Creates a Fixed Point Trap

The constructive core: given a surjection, we can COMPUTE
the fixed point. Evil is not just possible — it's computable. -/

/-
PROBLEM
Given a surjection `e`, the diagonal trick explicitly constructs
    the fixed point of any endofunction. Evil has a recipe.

PROVIDED SOLUTION
Same as lawvere_fixed_point. Use lawvere_fixed_point e he f.
-/
theorem constructive_fixed_point {α β : Type*} (e : α → α → β)
    (he : Surjective e) (f : β → β) :
    ∃ b : β, f b = b := by
  exact?

end EvilMadScience.SelfDefeatingOracle