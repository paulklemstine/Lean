import Mathlib

/-!
# Anti-Mathematics III: Negating the Axiom of Foundation

**Mission.** *Anti-Mathematics: What if all axioms were negated?*  This file treats
the negation of the **Axiom of Foundation (Regularity)**.

## The claim

In the pure Ackermann model of `AckermannModel.lean`, membership is well-founded
(`AckermannModel.foundation_wf`).  Negating Foundation means allowing a
**non-well-founded** membership — in the extreme, a *Quine atom* `Ω = {Ω}`, a set
that is its own unique element.  We build an explicit universe realising this:

  `W = Option ℕ`,   with the genuine Ackermann sets `some n` sitting alongside one
extra object `Ω = none` whose sole member is itself.

We prove, as a chain of fully verified results:

* `genuine_foundation` — on the genuine Ackermann sets membership is still
  well-founded (the contrast baseline);
* `omega_self_mem` — the Quine atom satisfies `Ω ∈ Ω`;
* `omega_mem_iff` — `Ω`'s only member is `Ω` (so `Ω = {Ω}`);
* `not_mem_self_genuine` — genuine sets never contain themselves;
* `regularity_fails` — the nonempty set `Ω` has **no** `∈`-minimal member, so the
  Axiom of Regularity fails;
* `anti_foundation` (main theorem) — membership in `W` is **not** well-founded.

The atom is still cleanly separated from the genuine sets (`omega_distinct`), so
this is a controlled failure of Foundation, not a collapse of the whole universe.
-/

namespace AntiMath

/-- Ackermann membership on `ℕ` (as in `AckermannModel.lean`). -/
def Mem (a b : ℕ) : Prop := b.testBit a

/-- Membership strictly decreases the Ackermann code. -/
theorem mem_lt {a b : ℕ} (h : Mem a b) : a < b :=
  lt_of_lt_of_le (Nat.lt_two_pow_self) (Nat.ge_two_pow_of_testBit h)

/-- **Foundation for the genuine sets.**  On `ℕ` with Ackermann membership the
relation is well-founded — the baseline that anti-Foundation deliberately breaks. -/
theorem genuine_foundation : WellFounded Mem :=
  Subrelation.wf (fun h => mem_lt h) (invImage id Nat.lt_wfRel).wf

/-- The anti-founded universe: the genuine Ackermann sets `some n` together with a
single extra object `Ω = none`. -/
abbrev W := Option ℕ

/-- The **Quine atom** `Ω = {Ω}`. -/
def Omega : W := none

/-- Membership in the anti-founded universe.  Genuine sets `some m ∈ some n` behave
via Ackermann membership; the atom `Ω = none` has exactly one member, itself, and
belongs to nothing else. -/
def WMem : W → W → Prop
  | some m, some n => Mem m n
  | none, none => True
  | _, _ => False

@[inherit_doc] scoped infix:50 " ∈w " => WMem

/-- **The Quine atom is a member of itself.** -/
theorem omega_self_mem : Omega ∈w Omega := trivial

/-- **`Ω`'s only member is `Ω`**, i.e. `Ω = {Ω}`. -/
theorem omega_mem_iff (x : W) : x ∈w Omega ↔ x = Omega := by
  cases x <;> simp [WMem, Omega]

/-- Genuine sets never contain themselves. -/
theorem not_mem_self_genuine (n : ℕ) : ¬ (some n ∈w some n) := by
  intro h; exact absurd (mem_lt h) (lt_irrefl n)

/-- The atom `Ω` is distinguishable from every genuine set: no genuine `some n` has
exactly the same members as `Ω`.  So Extensionality is *not* what fails here. -/
theorem omega_distinct (n : ℕ) : ¬ (∀ x, x ∈w Omega ↔ x ∈w some n) := by
  intro h
  have := h none
  simp [WMem, Omega] at this

/-- **Regularity fails.**  The nonempty set `Ω` has no `∈`-minimal member: its only
member is `Ω` itself, and `Ω ∈ Ω`, so no member is disjoint from `Ω`. -/
theorem regularity_fails :
    ¬ ∃ m, m ∈w Omega ∧ ∀ x, x ∈w Omega → ¬ (x ∈w m) := by
  rintro ⟨m, hm, hmin⟩
  rw [omega_mem_iff] at hm
  subst hm
  exact hmin Omega omega_self_mem omega_self_mem

/-- **Anti-Foundation — the main theorem.**  Membership in the universe `W` is
**not** well-founded: the self-loop `Ω ∈ Ω` yields an infinite descending
`∈`-chain, so the Axiom of Foundation fails. -/
theorem anti_foundation : ¬ WellFounded WMem := by
  intro hwf
  have key : ∀ x, Acc WMem x → ¬ WMem x x := by
    intro x hx
    induction hx with
    | intro y hy ih => intro hself; exact ih y hself hself
  exact key Omega (hwf.apply Omega) omega_self_mem

end AntiMath