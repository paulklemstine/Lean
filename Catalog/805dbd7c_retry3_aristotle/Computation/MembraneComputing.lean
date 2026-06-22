import Mathlib

/-!
# Membrane Computing: Duplication vs. Conservation

This file gives a minimal model of object rewriting in membrane (P-)systems.

A *configuration* is a multiset of objects, and an *object rule* maps each object to
the multiset of objects it produces in one parallel rewriting step.  We compare two
qualitatively different kinds of rules:

* the **duplicating** rule `dupRule`, which turns each object into two copies, and
* **conservative** rules, which preserve the number of objects (each object produces
  exactly one object).

The main result `dup_vs_conservative` shows that, starting from any nonempty
configuration, the duplicating system eventually overtakes any conservative system in
total object count: the population under duplication grows like `2^k`, while a
conservative system keeps a constant population.
-/

namespace MembraneComputing

open Multiset

variable {α : Type*}

/-- A configuration of a membrane system is a multiset of objects. -/
abbrev Config (α : Type*) := Multiset α

/-- An object rewriting rule sends each object to the multiset of objects it produces. -/
abbrev ObjRule (α : Type*) := α → Multiset α

/-- One parallel rewriting step: rewrite every object using the rule and collect the
results. -/
def step (r : ObjRule α) (c : Config α) : Config α := c.bind r

/-- Iterate `step` `k` times. -/
def steps (r : ObjRule α) : Nat → Config α → Config α
  | 0, c => c
  | k + 1, c => step r (steps r k c)

@[simp] lemma steps_zero (r : ObjRule α) (c : Config α) : steps r 0 c = c := rfl

lemma steps_succ (r : ObjRule α) (k : Nat) (c : Config α) :
    steps r (k + 1) c = step r (steps r k c) := rfl

/-- The duplicating rule: each object is replaced by two copies of itself. -/
def dupRule : ObjRule α := fun a => a ::ₘ a ::ₘ 0

/-- The duplicating rule produces two objects for each input object. -/
lemma card_dupRule (a : α) : Multiset.card (dupRule a) = 2 := rfl

/-- A single duplicating step doubles the number of objects. -/
lemma card_step_dup (c : Config α) :
    Multiset.card (step dupRule c) = 2 * Multiset.card c := by
  unfold step
  induction c using Multiset.induction with
  | empty => simp
  | cons a m ih =>
    rw [Multiset.cons_bind, Multiset.card_add, ih, card_dupRule, Multiset.card_cons]
    ring

/-- A single duplicating step on a nonempty configuration strictly increases the
number of objects. -/
lemma card_step_dup_strict (c : Config α) (hc : 1 ≤ Multiset.card c) :
    Multiset.card c < Multiset.card (step dupRule c) := by
  rw [card_step_dup]; omega

/-- After `k` duplicating steps the number of objects is multiplied by `2^k`. -/
lemma card_steps_dup (k : Nat) (c : Config α) :
    Multiset.card (steps dupRule k c) = 2 ^ k * Multiset.card c := by
  induction k with
  | zero => simp
  | succ n ih => rw [steps_succ, card_step_dup, ih]; ring

/-- A rule is *conservative* when every object produces exactly one object, so the total
object count is preserved. -/
def Conservative (r : ObjRule α) : Prop := ∀ a, Multiset.card (r a) = 1

/-- A single step of a conservative rule preserves the number of objects. -/
theorem card_step_conservative (r : ObjRule α) (h : Conservative r) (c : Config α) :
    Multiset.card (step r c) = Multiset.card c := by
  unfold step
  induction c using Multiset.induction with
  | empty => simp
  | cons a m ih =>
    rw [Multiset.cons_bind, Multiset.card_add, ih, h a, Multiset.card_cons]
    omega

/-- Iterating a conservative rule preserves the number of objects. -/
theorem card_steps_conservative (r : ObjRule α) (h : Conservative r) (k : Nat)
    (c : Config α) : Multiset.card (steps r k c) = Multiset.card c := by
  induction k with
  | zero => simp
  | succ n ih => rw [steps_succ, card_step_conservative r h, ih]

/-- For every natural number `n` there is a power of two exceeding it. -/
lemma exists_pow_two_gt (n : Nat) : ∃ k, 2 ^ k > n := by
  induction n with
  | zero => exact ⟨0, by norm_num⟩
  | succ m ih =>
    obtain ⟨k, hk⟩ := ih
    exact ⟨k + 1, by rw [pow_succ]; omega⟩

/-- **Duplication overtakes conservation.**

Starting from any nonempty configuration `c_d`, the duplicating system eventually has
strictly more objects than any conservative system started from any configuration
`c_c`. -/
theorem dup_vs_conservative (c_d : Config α) (hc : 1 ≤ Multiset.card c_d)
    (c_c : Config α) (r : ObjRule α) (h : Conservative r) :
    ∃ k, Multiset.card (steps dupRule k c_d) > Multiset.card (steps r k c_c) := by
  obtain ⟨k, hk⟩ := exists_pow_two_gt (Multiset.card c_c)
  refine ⟨k, ?_⟩
  rw [card_steps_dup, card_steps_conservative r h]
  calc Multiset.card c_c < 2 ^ k := hk
    _ = 2 ^ k * 1 := by ring
    _ ≤ 2 ^ k * Multiset.card c_d := Nat.mul_le_mul_left _ hc

end MembraneComputing