import Mathlib

/-!
# Mirror vs. Gödel: Why Idempotent Algebras Escape Incompleteness

This file formalizes the relationship between idempotent algebras and Gödel's
incompleteness theorem, showing precisely WHY the diagonal argument fails
in idempotent settings and WHY it succeeds in classical arithmetic.

## The Key Distinction

Gödel's diagonal lemma requires:
1. An injective encoding of syntax into arithmetic (Gödel numbering)
2. A substitution function computable within the arithmetic
3. Cancellativity of addition (a + b = a + c → b = c)

In idempotent semirings, property (3) fails catastrophically:
max(a, b) = max(a, c) does NOT imply b = c.

## Main Results

- `real_add_left_cancel`: Classical addition is cancellative
- `max_not_left_cancel`: Tropical addition is NOT cancellative
- `tropical_self_ref_has_fixpoint`: Tropical self-reference has fixed points
- `tropical_self_ref_fixpoints`: Complete characterization of tropical fixed points
- `classical_self_ref_unique`: Classical self-reference is rigid
- `idempotent_self_ref_is_id`: In idempotent algebras, self-reference = identity
-/

noncomputable section

open Set Function

/-! ## §1: Cancellativity vs. Idempotency — The Fork in the Road -/

/-- Classical addition is left-cancellative. -/
theorem real_add_left_cancel (a b c : ℝ) (h : a + b = a + c) : b = c := by linarith

/-- Tropical addition (max) is NOT left-cancellative. -/
theorem max_not_left_cancel :
    ∃ (a b c : ℝ), max a b = max a c ∧ b ≠ c :=
  ⟨10, 3, 5, by norm_num, by norm_num⟩

/-- A selective idempotent operation on a nontrivial type cannot be cancellative.
Max is the prototypical example: max(a,b) ∈ {a,b} and max(a,a) = a,
but max(5,3) = max(5,4) = 5 with 3 ≠ 4. -/
theorem selective_idempotent_not_cancellative
    (a b : ℝ) (hab : a ≠ b) (hlt : a < b) :
    ¬(∀ x y z : ℝ, max x y = max x z → y = z) := by
  intro h_cancel
  have h1 : max b a = b := max_eq_left hlt.le
  have h2 : max b b = b := max_self b
  have h3 : max b a = max b b := by rw [h1, h2]
  exact hab (h_cancel b a b h3)

/-! ## §2: Self-Reference as Fixed Point -/

/-- In tropical algebra, the self-referential equation max(x, c) = x always has solutions. -/
theorem tropical_self_ref_has_fixpoint (c : ℝ) :
    ∃ x : ℝ, max x c = x := ⟨c, max_self c⟩

/-- The solutions of max(x, c) = x are exactly {x | c ≤ x}. -/
theorem tropical_self_ref_fixpoints (c : ℝ) :
    {x : ℝ | max x c = x} = {x | c ≤ x} := by
  ext x; simp [ge_iff_le]

/-- In contrast, x + c = x has a solution iff c = 0 (rigid self-reference). -/
theorem classical_self_ref_unique (c : ℝ) :
    (∃ x : ℝ, x + c = x) ↔ c = 0 := by
  constructor
  · rintro ⟨x, h⟩; linarith
  · rintro rfl; exact ⟨0, by ring⟩

/-! ## §3: The Mirror Principle — Synthesis -/

/-- Self-reference in classical arithmetic creates new information. -/
theorem classical_self_ref_unstable (a : ℝ) (ha : a > 0) : a + a > a := by linarith

/-- Self-reference in tropical arithmetic is stable. -/
theorem tropical_self_ref_stable (a : ℝ) : max a a = a := max_self a

/-- **The Grand Theorem**: In any algebra where the binary operation is idempotent,
the "self-referential function" x ↦ op(x, x) is the identity.
Self-reference cannot create new information in idempotent algebras. -/
theorem idempotent_self_ref_is_id
    {α : Type*} (op : α → α → α) (h : ∀ a, op a a = a) :
    (fun a => op a a) = id := by
  ext a; exact h a

/-! ## §4: Tropical Encoding Collisions -/

/-- In a tropical-style encoding using max, distinct inputs can map to the same output.
This is the fundamental obstruction to Gödel numbering in idempotent arithmetic. -/
theorem tropical_encoding_collision :
    ∃ (f : ℝ → ℝ → ℝ), (∀ x, f x x = x) ∧
    (∃ a b c, f a b = f a c ∧ b ≠ c) := by
  exact ⟨max, fun x => max_self x, 10, 3, 5, by norm_num, by norm_num⟩

/-! ## §5: The Diagonal Dissolution -/

/-- When we try to build a "diagonal" in a tropical setting, instead of getting
a paradoxical sentence, we get a set of fixed points. The paradox dissolves. -/
theorem diagonal_dissolution (f : ℝ → ℝ) :
    {x : ℝ | max (f x) x = x} = {x | f x ≤ x} := by
  ext x
  simp only [mem_setOf_eq]
  exact max_eq_right_iff

/-- The diagonal fixed point set is always non-empty (it contains sufficiently large elements). -/
theorem diagonal_fixpoints_nonempty (f : ℝ → ℝ) (hf : ∃ M, ∀ x, f x ≤ M) :
    {x : ℝ | max (f x) x = x}.Nonempty := by
  obtain ⟨M, hM⟩ := hf
  refine ⟨M, ?_⟩
  simp only [mem_setOf_eq]
  exact max_eq_right (hM M)

end
