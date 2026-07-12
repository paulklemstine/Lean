import Mathlib

/-!
# Negabinary: Unique Integer Representation in Base `-2`

This file develops arithmetic in the **negative base** `-2` ("negabinary") from
first principles and proves the central structural theorem of the system:

> **Every integer has a unique representation in base `-2` using digits `0` and `1`.**

Unlike ordinary base `b > 1`, which represents only the non-negative integers, the
negative base `-2` represents **all** of `ℤ` — positive and negative — with the
same two digits `{0, 1}` and *without a sign*.  This is the phenomenon that makes
negative bases attractive as "alien number systems".

A representation is a finite list of bits `l : List Bool` (least significant first).
Its value is the Horner-form evaluation
`nvalue (b :: bs) = digit b + (-2) * nvalue bs`, i.e. `∑ᵢ dᵢ · (-2)ⁱ`.

The canonical representations are those with no leading zero in the top position
(`Canonical`, "the list does not end in `false`").  The main theorem
`negabinary_unique_rep` states that the map from canonical bit lists to `ℤ` is a
bijection: every integer is the value of exactly one canonical list.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  In base `-2`, the two digits `{0,1}` should
  suffice to name *every* integer, including the negatives, uniquely — no sign bit,
  no separate treatment of `n < 0`.  Bold form: the value map on canonical bit
  lists is a bijection with all of `ℤ`.
* **Experiment (Experimenter).**  Evaluation is Horner's rule with multiplier
  `-2`.  Uniqueness is proved by structural induction: the least-significant bit is
  forced by the parity `nvalue (b :: bs) ≡ digit b (mod 2)`, and the remainder
  `nvalue bs` is then determined.  Existence is by strong induction along the
  measure `mu` (a `ℤ ≃ ℕ` interleaving) which the base-`-2` successor map strictly
  decreases.
* **Analysis (Analyst).**  The proof needs NO cardinality, surjectivity, or
  bijection lemma from the library.  The subtlety of negative bases lives entirely
  in the termination measure `mu`: naive `|n|` does **not** decrease (`-1 ↦ 1`), so
  a genuine interleaving of the two half-lines is required.
* **Critique (Critic).**  Canonicality is essential: without the "no trailing
  `false`" condition, `[]`, `[false]`, `[false,false]`, ... all have value `0`, so
  representations are not unique.  The empty list is canonical and represents `0`.
  The parity argument is not vacuous: `nvalue_eq_zero_of_canonical` shows the value
  map is injective *including* at `0`.
* **Synthesis (PI).**  `negabinary_unique_rep : ∀ n : ℤ, ∃! l, Canonical l ∧
  nvalue l = n` packages existence + uniqueness into a single bijection statement,
  realizing base `-2` as a signless positional system for all of `ℤ`.
-/

namespace Negabinary

/-- The integer value of a single negabinary digit. -/
def digit (b : Bool) : ℤ := if b then 1 else 0

/-- The value of a negabinary bit list (least-significant bit first), evaluated by
Horner's rule with base `-2`: `nvalue (b :: bs) = digit b + (-2) * nvalue bs`. -/
def nvalue : List Bool → ℤ
  | [] => 0
  | b :: bs => digit b + (-2) * nvalue bs

/-- A bit list is **canonical** if it does not end in a `false` (leading-zero-free
in the most significant position). The empty list is canonical. -/
def Canonical (l : List Bool) : Prop := l.getLast? ≠ some false

/-- Interleaving measure `ℤ → ℕ` (`0 ↦ 0`, `1 ↦ 1`, `-1 ↦ 2`, `2 ↦ 3`, ...).
The base-`-2` successor step strictly decreases this measure, giving termination
for the existence proof. -/
def mu (n : ℤ) : ℕ := (if 0 < n then 2 * n - 1 else -2 * n).toNat

@[simp] theorem nvalue_nil : nvalue [] = 0 := rfl

theorem nvalue_cons (b : Bool) (bs : List Bool) :
    nvalue (b :: bs) = digit b + (-2) * nvalue bs := rfl

theorem digit_inj {a b : Bool} (h : digit a = digit b) : a = b := by
  cases a <;> cases b <;> simp_all [digit]

/-
The least-significant bit is forced by the parity of the value.
-/
theorem nvalue_cons_emod (b : Bool) (bs : List Bool) :
    nvalue (b :: bs) % 2 = digit b := by
  by_cases hb : b = Bool.true <;> simp +decide [nvalue_cons, hb]

@[simp] theorem canonical_nil : Canonical [] := by
  simp [Canonical]

/-
Every tail of a canonical list is canonical.
-/
theorem canonical_tail {a : Bool} {as : List Bool} (h : Canonical (a :: as)) :
    Canonical as := by
  cases as <;> simp_all +decide [ Canonical ]

/-
A canonical list with value `0` must be empty: the value map is injective at
`0`.
-/
theorem nvalue_eq_zero_of_canonical :
    ∀ {l : List Bool}, Canonical l → nvalue l = 0 → l = [] := by
  intro l;
  induction' l with b l ih;
  · tauto;
  · grind +locals

/-
**Uniqueness.** Two canonical bit lists with equal negabinary value are equal.
-/
theorem nvalue_injective :
    ∀ {l₁ l₂ : List Bool}, Canonical l₁ → Canonical l₂ →
      nvalue l₁ = nvalue l₂ → l₁ = l₂ := by
  intros l₁ l₂ hl₁ hl₂ hval;
  induction' l₁ with a as ih generalizing l₂ <;> induction' l₂ with b bs ih' <;> simp_all +decide;
  · grind +suggestions;
  · grind +suggestions;
  · grind +suggestions

/-
The measure `mu` strictly decreases under the base-`-2` successor step
`n ↦ (n % 2 - n) / 2`. Stated in the form used by the existence induction.
-/
theorem mu_step_lt {n : ℤ} (hn : n ≠ 0) :
    mu ((n % 2 - n) / 2) < mu n := by
  unfold mu;
  split_ifs <;> omega

/-
**Existence.** Every integer is the value of some canonical bit list.
-/
theorem exists_canonical (n : ℤ) : ∃ l : List Bool, Canonical l ∧ nvalue l = n := by
  induction' h : mu n using Nat.strong_induction_on with N ih generalizing n;
  by_cases hn : n = 0;
  · exact ⟨ [ ], by simp +decide [ hn ] ⟩;
  · obtain ⟨l', hl'⟩ : ∃ l' : List Bool, Canonical l' ∧ nvalue l' = (n % 2 - n) / 2 := by
      exact ih _ ( by simpa [ h ] using mu_step_lt hn ) _ rfl;
    refine' ⟨ ( decide ( n % 2 = 1 ) ) :: l', _, _ ⟩ <;> simp_all +decide [ Canonical ];
    · cases l' <;> simp_all +decide [ List.getLast? ];
      omega;
    · grind +locals

/-
**Main theorem: unique representation in base `-2`.**
Every integer is the negabinary value of exactly one canonical bit list. Thus the
digits `{0,1}` of base `-2` name every integer — positive, negative, and zero —
uniquely and without a sign.
-/
theorem negabinary_unique_rep (n : ℤ) :
    ∃! l : List Bool, Canonical l ∧ nvalue l = n := by
  -- By `exists_canonical`, we obtain a canonical list `l` with `nvalue l = n`.
  obtain ⟨l, hcanon, hv⟩ := exists_canonical n
  use l
  simp [hcanon, hv];
  exact fun y hy hy' => nvalue_injective hy hcanon <| hy'.trans hv.symm

end Negabinary