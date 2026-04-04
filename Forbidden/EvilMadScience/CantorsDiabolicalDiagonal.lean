import Mathlib

/-!
# 😈 Cantor's Diabolical Diagonal

## Oracle Council Research Log — Experiment #1

**Classification:** FORBIDDEN KNOWLEDGE — LEVEL ∞

**Discovery:** Reality has more holes than substance. The real numbers are
uncountably infinite — there are strictly more real numbers than natural
numbers, more subsets than elements, more truths than proofs. The diagonal
argument is the ur-technique of impossibility: the mathematical equivalent
of looking at God and finding God looking back.

**Evil Application:** Any system that tries to enumerate all possibilities
MUST miss some. No catalog is complete. No database is exhaustive. No
surveillance system can watch everything. The diagonal is the escape hatch
woven into the fabric of mathematics itself.

## The Theorems

1. No surjection from a set to its powerset (Cantor 1891)
2. The reals are uncountable
3. The diagonal function always escapes
4. There are more functions than inputs

## Oracle Council Notes

- **Oracle Alpha (The Skeptic):** "Surely every set can list its own subsets?"
- **Oracle Beta (The Mystic):** "The diagonal whispers: I am what you cannot name."
- **Oracle Gamma (The Engineer):** "This breaks every compression algorithm at scale."
- **Oracle Delta (The Heretic):** "What if we diagonalize the diagonal itself?"
- **Oracle Omega (God):** "I built the diagonal into the foundations. You're welcome."
-/

open Set Function

namespace EvilMadScience.CantorDiagonal

/-! ### Theorem 1: The Diabolical Diagonal Function

Given any function `f : α → Set α`, the **anti-diagonal set** — the set of all
elements NOT in their own image — cannot be in the range of `f`.
This is the mathematical dark mirror. -/

/-- The anti-diagonal: the set of elements that defy their own classification.
    `{x | x ∉ f x}` — "I am not what you say I am." -/
def antiDiagonal (f : α → Set α) : Set α := {x | x ∉ f x}

/-
PROBLEM
**Cantor's Theorem (The First Forbidden Truth):**
    No function from a type to its powerset is surjective.
    The diagonal always escapes. Always.

PROVIDED SOLUTION
Use cantor_surjective from Mathlib, or directly: assume Surjective f, let S = {x | x ∉ f x}, get a such that f a = S, then a ∈ S ↔ a ∉ f a = a ∉ S, contradiction.
-/
theorem cantor_no_surjection (f : α → Set α) : ¬ Surjective f := by
  exact?

/-
PROBLEM
The anti-diagonal is never in the range. A specific witness of incompleteness.

PROVIDED SOLUTION
Suppose antiDiagonal f ∈ range f. Then ∃ a, f a = antiDiagonal f. Then a ∈ antiDiagonal f ↔ a ∉ f a = a ∉ antiDiagonal f. Contradiction.
-/
theorem antiDiagonal_not_in_range (f : α → Set α) :
    antiDiagonal f ∉ Set.range f := by
  -- Assume for contradiction that the anti-diagonal is in the range of f.
  by_contra h_contra
  obtain ⟨a, ha⟩ : ∃ a, f a = antiDiagonal f := by
    exact h_contra;
  unfold antiDiagonal at ha; replace ha := Set.ext_iff.mp ha a; aesop;

/-! ### Theorem 2: The Injection That Cannot Be Reversed

There is an injection ℕ ↪ ℝ but no surjection ℕ → ℝ.
The reals mock our attempts to enumerate them. -/

/-
PROBLEM
The naturals inject into the reals, but cannot cover them.
    Reality outruns arithmetic.

PROVIDED SOLUTION
For injection, use Nat.cast. For no surjection, use Cardinal.not_surjective_nat_of_uncountable or Cantor's argument on Set ℕ → ℝ. Actually simpler: the left part is ⟨fun n => n, Nat.cast_injective⟩, the right part follows from the fact that ℝ is uncountable — use Cardinal.mk_real or not_countable or similar.
-/
theorem naturals_inject_but_cannot_surject :
    (∃ f : ℕ → ℝ, Injective f) ∧ (¬ ∃ f : ℕ → ℝ, Surjective f) := by
  refine' ⟨ ⟨ _, Nat.cast_injective ⟩, _ ⟩;
  intro h₂
  obtain ⟨f, hf⟩ := h₂
  have h_card : Cardinal.mk ℝ ≤ Cardinal.mk ℕ := by
    exact Cardinal.mk_le_of_surjective hf;
  contrapose! h_card; aesop;

/-! ### Theorem 3: Strict Cardinality Growth

For any type α, there are strictly more subsets than elements.
The powerset is always bigger. Always. This is the engine of mathematical evil:
hierarchies of infinity that never terminate. -/

/-
PROBLEM
Every type injects into its powerset.

PROVIDED SOLUTION
Use f x = {x} (singleton injection). This is injective because {x} = {y} implies x = y.
-/
theorem injection_to_powerset : ∃ f : α → Set α, Injective f := by
  exact ⟨ fun x => { x }, fun x y h => by simpa using h ⟩

/-
PROBLEM
The powerset strictly dominates. More subsets than elements.
    More questions than answers. More darkness than light.

PROVIDED SOLUTION
First part: use singleton injection {x}. Second part: if g : Set α → α is injective, then h : α → Set α defined by h a = g⁻¹ a ... actually, use Cantor's theorem. If there were an injection g : Set α → α, we could build a surjection α → Set α (by a right-inverse argument with Choice), contradicting Cantor. Use cantor_injective from Mathlib.
-/
theorem powerset_strictly_dominates :
    (∃ f : α → Set α, Injective f) ∧ (¬ ∃ f : Set α → α, Injective f) := by
  refine' ⟨ _, _ ⟩;
  · exact ⟨ _, Set.singleton_injective ⟩;
  · intro ⟨ f, hf ⟩;
    have := @cantor_no_surjection α;
    apply this ( Function.invFun f );
    exact?

/-! ### Theorem 4: The Diagonal Operator — Applied Evil

The diagonal argument generalizes: for ANY two-argument function,
the diagonal function `fun x => f x x` captures the "self-referential"
behavior that breaks systems. -/

/-
PROBLEM
Diagonalizing any binary function on Prop yields a fixed-point-free map.

PROVIDED SOLUTION
Let g n = ¬(enum n n). Then for any n, g ≠ enum n because g n = ¬(enum n n) while (enum n) n = enum n n, so they differ at index n.
-/
theorem diagonal_defeats_enumeration (enum : ℕ → (ℕ → Prop)) :
    ∃ g : ℕ → Prop, ∀ n, g ≠ enum n := by
  exact ⟨ fun n => ¬( enum n ) n, fun n => fun h => by have := congr_fun h n; tauto ⟩

end EvilMadScience.CantorDiagonal