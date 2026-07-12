import Mathlib

/-!
# Anti-Mathematics IV: The ZF schemas survive the negation of Infinity

**Mission.** *Anti-Mathematics: What if all axioms were negated?*  Negating the
**Axiom of Infinity** (while keeping the rest of ZF) produces the theory of the
**hereditarily finite sets** `HF`.  The Ackermann model realises it: the carrier is
`ℕ`, and `a ∈ₐ b :⟺ Nat.testBit b a` reads a number as the finite set of positions
of the `1`s in its binary expansion.

The companion file established the finite ZF *axioms* (Empty, Pairing, Union,
Power Set, Foundation) and the negation of Infinity in this model.  This file
proves that the two ZF **axiom schemas** — **Separation** and **Replacement** —
also hold, together with the **∈-Induction** (set-induction) schema that powers
recursion over the hereditarily finite universe.

So `HF = ZF − Infinity + ¬Infinity` is a *complete* set theory in the Ackermann
model: every ZF axiom other than Infinity holds, and Infinity provably fails.

## Results

* `set_induction` — the ∈-Induction / foundation-induction schema.
* `separation` — the Separation (Aussonderung) schema, for every decidable predicate.
* `replacement` — the Replacement schema, for every (meta-)function `F : ℕ → ℕ`.

The schema witnesses are built explicitly as bitmasks: a finite `or`-fold of the
relevant powers of two over the members of the input set.
-/

namespace AntiMath.Schemas

/-- **Ackermann membership**: `a ∈ₐ b` iff the `a`-th binary digit of `b` is `1`. -/
def Mem (a b : ℕ) : Prop := b.testBit a

@[inherit_doc] scoped infix:50 " ∈ₐ " => Mem

instance (a : ℕ) : DecidablePred (fun x => Mem x a) := fun x => by
  unfold Mem; infer_instance

/-- Membership strictly decreases the Ackermann code: `a ∈ₐ b → a < b`. -/
theorem mem_lt {a b : ℕ} (h : a ∈ₐ b) : a < b :=
  lt_of_lt_of_le (Nat.lt_two_pow_self) (Nat.ge_two_pow_of_testBit h)

/-- **∈-Induction (set-induction) schema.**  To prove `P` of every set it suffices
to prove `P a` from the assumption that `P` holds of all members of `a`.  This is
the constructive heart of foundation and licenses recursion over `HF`. -/
theorem set_induction {P : ℕ → Prop} (h : ∀ a, (∀ x, x ∈ₐ a → P x) → P a) (a : ℕ) :
    P a := by
  induction a using Nat.strong_induction_on with
  | _ a ih => exact h a (fun x hx => ih x (mem_lt hx))

/-- Bit `z` of an `or`-fold of `if q y then 2 ^ y else 0` over `L` is on exactly
when some `y ∈ L` equals `z` and satisfies `q`. -/
theorem fold_testBit_pos (q : ℕ → Prop) [DecidablePred q] (z : ℕ) : ∀ L : List ℕ,
    (List.foldr (fun y acc => acc ||| (if q y then 2 ^ y else 0)) 0 L).testBit z
      = (L.any (fun y => decide (y = z) && decide (q y))) := by
  intro L
  induction L with
  | nil => simp
  | cons a t ih =>
    simp only [List.foldr_cons, Nat.testBit_or, List.any_cons, ih]
    by_cases hqa : q a
    · by_cases hax : a = z
      · subst hax; simp [hqa]
      · simp [hqa, hax]
    · simp [hqa]

/-- Bit `z` of an `or`-fold of `if q y then 2 ^ (g y) else 0` over `L` is on exactly
when some `y ∈ L` satisfies `q` and has `g y = z`. -/
theorem fold_testBit_img (q : ℕ → Prop) [DecidablePred q] (g : ℕ → ℕ) (z : ℕ) :
    ∀ L : List ℕ,
    (List.foldr (fun y acc => acc ||| (if q y then 2 ^ (g y) else 0)) 0 L).testBit z
      = (L.any (fun y => decide (q y) && decide (g y = z))) := by
  intro L
  induction L with
  | nil => simp
  | cons a t ih =>
    simp only [List.foldr_cons, Nat.testBit_or, List.any_cons, ih]
    by_cases hqa : q a
    · by_cases hax : g a = z
      · subst hax; simp [hqa]
      · simp [hqa, hax]
    · simp [hqa]

/-- **Separation (Aussonderung) schema.**  For any set `a` and any decidable
predicate `p`, the subclass `{x ∈ a | p x}` is a set of the model. -/
theorem separation (p : ℕ → Prop) [DecidablePred p] (a : ℕ) :
    ∃ s, ∀ x, x ∈ₐ s ↔ x ∈ₐ a ∧ p x := by
  refine ⟨(List.range a).foldr
      (fun y acc => acc ||| if (a.testBit y ∧ p y) then 2 ^ y else 0) 0, fun x => ?_⟩
  simp only [Mem]
  rw [fold_testBit_pos (fun y => a.testBit y ∧ p y) x]
  simp only [List.any_eq_true, List.mem_range, Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨y, _, rfl, hy, hp⟩; exact ⟨hy, hp⟩
  · rintro ⟨hx, hp⟩; exact ⟨x, mem_lt hx, rfl, hx, hp⟩

/-- **Replacement schema.**  The image `{F x | x ∈ a}` of any set `a` under any
(meta-)function `F : ℕ → ℕ` is again a set of the model. -/
theorem replacement (F : ℕ → ℕ) (a : ℕ) :
    ∃ s, ∀ y, y ∈ₐ s ↔ ∃ x, x ∈ₐ a ∧ y = F x := by
  refine ⟨(List.range a).foldr
      (fun x acc => acc ||| if a.testBit x then 2 ^ (F x) else 0) 0, fun y => ?_⟩
  simp only [Mem]
  rw [fold_testBit_img (fun x => a.testBit x) F y]
  simp only [List.any_eq_true, List.mem_range, Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨x, _, hx, hFx⟩; exact ⟨x, hx, hFx.symm⟩
  · rintro ⟨x, hx, rfl⟩; exact ⟨x, mem_lt hx, hx, rfl⟩

end AntiMath.Schemas