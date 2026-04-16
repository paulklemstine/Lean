/-! # CatalogBuild.Physics.AlgebraicPhysics.MirrorGodel

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 10
-/

import Mathlib

noncomputable section

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



/-- **The Grand Theorem**: In any algebra where the binary operation is idempotent,
the "self-referential function" x ↦ op(x, x) is the identity.
Self-reference cannot create new information in idempotent algebras. -/
theorem idempotent_self_ref_is_id
    {α : Type*} (op : α → α → α) (h : ∀ a, op a a = a) :
    (fun a => op a a) = id := by
  ext a; exact h a



/-- In a tropical-style encoding using max, distinct inputs can map to the same output.
This is the fundamental obstruction to Gödel numbering in idempotent arithmetic. -/
theorem tropical_encoding_collision :
    ∃ (f : ℝ → ℝ → ℝ), (∀ x, f x x = x) ∧
    (∃ a b c, f a b = f a c ∧ b ≠ c) := by
  exact ⟨max, fun x => max_self x, 10, 3, 5, by norm_num, by norm_num⟩



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
