import Mathlib

/-!
# Anti-Mathematics I: Negating the Axiom of Infinity

**Mission.** *Anti-Mathematics: What if all axioms were negated?* — systematically
negate the ZFC axioms and study the resulting theories.  This file treats the
negation of the **Axiom of Infinity**.

## The claim

Negating Infinity (while keeping the other axioms) yields the theory of
**hereditarily finite sets** `HF`.  We build an explicit, fully verified model of
`HF` — the *Ackermann model* — and prove inside it:

* **Extensionality** (`extensionality`)
* **Empty set** (`empty_set`, `not_mem_zero`)
* **Pairing** (`pairing`)
* **Binary union** (`binUnion`) and the full **Union** axiom (`union`)
* **Power Set** (`powerSet`), via the bitwise **subset** characterisation (`subset_iff`)
* **Foundation / Regularity** (`foundation_wf`, `regularity`, `not_mem_self`)
* and, crucially, **the negation of Infinity** (`anti_infinity`): *no set is
  inductive.*

## The model

The carrier is `ℕ`.  Ackermann's coding reads a natural number `b` as the finite
set of positions of the `1`s in its binary expansion:

  `a ∈ b  :⟺  the a-th binary digit of b is 1  :⟺  Nat.testBit b a`.

Every natural number thus *is* a hereditarily finite set, and this is a bijection
between `ℕ` and `HF`.  The whole development is a chain of results, each building on
the previous ones, culminating in `anti_infinity`.
-/

namespace AntiMath

/-- **Ackermann membership**: `a ∈ₐ b` iff the `a`-th binary digit of `b` is `1`. -/
def Mem (a b : ℕ) : Prop := b.testBit a

@[inherit_doc] scoped infix:50 " ∈ₐ " => Mem

instance (a : ℕ) : DecidablePred (fun x => Mem x a) := fun x => by
  unfold Mem; infer_instance

/-- The empty set: nothing is a member of `0`. -/
theorem not_mem_zero (a : ℕ) : ¬ (a ∈ₐ 0) := by simp [Mem]

/-- **Extensionality** holds in the Ackermann model: sets with the same members
are equal. -/
theorem extensionality {a b : ℕ} (h : ∀ x, x ∈ₐ a ↔ x ∈ₐ b) : a = b := by
  apply Nat.eq_of_testBit_eq; intro i; simpa [Mem] using (h i)

/-- Membership strictly decreases the code: `a ∈ₐ b → a < b`.  This single
arithmetical fact powers Foundation and, later, the failure of Infinity. -/
theorem mem_lt {a b : ℕ} (h : a ∈ₐ b) : a < b :=
  lt_of_lt_of_le (Nat.lt_two_pow_self) (Nat.ge_two_pow_of_testBit h)

/-- No set is a member of itself. -/
theorem not_mem_self (a : ℕ) : ¬ (a ∈ₐ a) := fun h => (lt_irrefl a) (mem_lt h)

/-- **Foundation** in its sharpest form: membership is a well-founded relation. -/
theorem foundation_wf : WellFounded Mem :=
  Subrelation.wf (fun h => mem_lt h) (invImage id Nat.lt_wfRel).wf

/-- `adjoin a b` is the set `b ∪ {a}`, obtained by turning on bit `a` of `b`. -/
def adjoin (a b : ℕ) : ℕ := b ||| 2 ^ a

/-- Characterisation of membership in `adjoin a b`. -/
theorem mem_adjoin {x a b : ℕ} : x ∈ₐ (adjoin a b) ↔ x = a ∨ x ∈ₐ b := by
  simp only [Mem, adjoin, Nat.testBit_or, Nat.testBit_two_pow]
  constructor
  · rintro h; rcases (Bool.or_eq_true _ _).mp h with h | h
    · exact Or.inr h
    · exact Or.inl (by simpa [eq_comm] using h)
  · rintro (rfl | h)
    · simp
    · rw [h]; simp

/-- **Empty set axiom.** -/
theorem empty_set : ∃ e, ∀ x, ¬ (x ∈ₐ e) := ⟨0, not_mem_zero⟩

/-- **Pairing axiom**: for any `a`, `b` there is a set whose members are exactly
`a` and `b`. -/
theorem pairing (a b : ℕ) : ∃ p, ∀ x, x ∈ₐ p ↔ x = a ∨ x = b := by
  refine ⟨adjoin a (adjoin b 0), fun x => ?_⟩
  simp only [mem_adjoin]
  constructor
  · rintro (rfl | rfl | h)
    · exact Or.inl rfl
    · exact Or.inr rfl
    · exact absurd h (by simp [Mem])
  · rintro (rfl | rfl)
    · exact Or.inl rfl
    · exact Or.inr (Or.inl rfl)

/-- **Union** (binary form `a ∪ b`): membership is bitwise `or`. -/
theorem binUnion (a b : ℕ) : ∃ u, ∀ x, x ∈ₐ u ↔ x ∈ₐ a ∨ x ∈ₐ b := by
  refine ⟨a ||| b, fun x => ?_⟩; simp [Mem, Nat.testBit_or]

/-- **Regularity / Foundation** in element form: every nonempty set has an
`∈ₐ`-minimal member. -/
theorem regularity {a : ℕ} (ha : a ≠ 0) :
    ∃ m, m ∈ₐ a ∧ ∀ x, x ∈ₐ a → ¬ (x ∈ₐ m) := by
  have hex : ∃ n, n ∈ₐ a := by
    by_contra h; push_neg at h
    exact ha (Nat.eq_of_testBit_eq (fun i => by simpa [Mem] using h i))
  classical
  refine ⟨Nat.find hex, Nat.find_spec hex, fun x hx hxm => ?_⟩
  exact Nat.find_min hex (mem_lt hxm) hx

/-- **Subset relation** in bit form: `x ⊆ a` (every member of `x` is a member of
`a`) is exactly the bitmask condition `x &&& a = x`. -/
theorem subset_iff (x a : ℕ) : (∀ z, z ∈ₐ x → z ∈ₐ a) ↔ x &&& a = x := by
  refine' ⟨ fun h => _, fun h z hz => _ ⟩;
  · refine' Nat.eq_of_testBit_eq fun i => _;
    by_cases hi : x.testBit i <;> simp_all +decide [ Mem ];
  · grind +locals

/-- **Union axiom** (`⋃ a`): for any set `a` there is a set whose members are
exactly the members of members of `a`. -/
theorem union (a : ℕ) : ∃ u, ∀ x, x ∈ₐ u ↔ ∃ b, b ∈ₐ a ∧ x ∈ₐ b := by
  -- Let's consider the list of numbers less than `a` that are in `a`.
  set L := (List.range a).filter (fun b => a.testBit b);
  -- By definition of `L`, we know that `x ∈ₐ u` if and only if there exists `b ∈ L` such that `x ∈ₐ b`.
  have hL : ∀ x, (List.foldr (· ||| ·) 0 L).testBit x ↔ ∃ b ∈ L, b.testBit x := by
    induction L <;> simp_all +decide [ Nat.testBit_or ];
  simp +zetaDelta at *;
  exact ⟨ _, fun x => by rw [ show Mem x _ = _ from rfl, show Mem x _ = _ from rfl ] ; exact hL x |> Iff.trans <| ⟨ fun ⟨ b, hb₁, hb₂ ⟩ => ⟨ b, hb₁.2, hb₂ ⟩, fun ⟨ b, hb₁, hb₂ ⟩ => ⟨ b, ⟨ Nat.lt_of_not_ge fun hb₃ => by have := mem_lt hb₁; linarith, hb₁ ⟩, hb₂ ⟩ ⟩ ⟩

/-- **Power Set axiom** (`𝒫 a`): for any set `a` there is a set whose members are
exactly the subsets of `a`. -/
theorem powerSet (a : ℕ) : ∃ p, ∀ x, x ∈ₐ p ↔ ∀ z, z ∈ₐ x → z ∈ₐ a := by
  -- By definition of `Mem`, we know that `z ∈ₐ a` means `a.testBit z`. So it suffices to build `p` with `x ∈ₐ p ↔ x &&& a = x`.
  suffices h_pow : ∃ p : ℕ, ∀ x, (p.testBit x = true ↔ x &&& a = x) by
    convert h_pow using 6
    exact subset_iff _ a
  -- Construct the power set as an OR of `2^x` over all subsets `x <= a`.
  use (List.range (a + 1)).foldr (fun x acc => acc ||| if x &&& a = x then 2 ^ x else 0) 0;
  intro x
  have h_foldr : ∀ L : List ℕ, (List.foldr (fun x acc => acc ||| (if x &&& a = x then 2^x else 0)) 0 L).testBit x = (List.any L (fun y => y = x ∧ y &&& a = y)) := by
    intro L;
    induction L <;> simp_all +decide [ Nat.testBit_or ];
    grind;
  by_cases hx : x < a + 1 <;> simp_all +decide [ List.any_eq_true ];
  exact fun h => absurd h ( by exact ne_of_lt ( lt_of_le_of_lt ( Nat.and_le_right ) hx ) )

/-- The von Neumann successor `a ∪ {a}` inside the model. -/
def succ (a : ℕ) : ℕ := adjoin a a

theorem mem_succ {x a : ℕ} : x ∈ₐ (succ a) ↔ x = a ∨ x ∈ₐ a := mem_adjoin

theorem self_mem_succ (a : ℕ) : a ∈ₐ (succ a) := mem_succ.mpr (Or.inl rfl)

/-- The successor is strictly larger than its argument. -/
theorem lt_succ (a : ℕ) : a < succ a := mem_lt (self_mem_succ a)

/-- The von Neumann numerals `∅, {∅}, {∅,{∅}}, …` represented in the model. -/
def numeral : ℕ → ℕ
  | 0 => 0
  | n + 1 => succ (numeral n)

/-- The `n`-th numeral codes a number at least `n`; hence the numerals are
unbounded. -/
theorem numeral_ge (n : ℕ) : n ≤ numeral n := by
  induction n with
  | zero => simp [numeral]
  | succ k ih => have := lt_succ (numeral k); simp only [numeral]; omega

/-- **Anti-Infinity — the main theorem.**  In the Ackermann model *no set is
inductive*: there is no `I` that contains the empty set (`0`) and is closed under
the successor operation.  Equivalently, the Axiom of Infinity **fails**, so the
model realises `ZF − Infinity + ¬Infinity`, i.e. the hereditarily finite sets.

Proof: an inductive `I` would contain every numeral `numeral n`, forcing
`numeral n < I` for all `n`; but `n ≤ numeral n`, so `I < I`, absurd. -/
theorem anti_infinity :
    ¬ ∃ I : ℕ, (0 ∈ₐ I) ∧ ∀ x, x ∈ₐ I → (succ x) ∈ₐ I := by
  rintro ⟨I, h0, hcl⟩
  have hmem : ∀ n, numeral n ∈ₐ I := by
    intro n; induction n with
    | zero => simpa [numeral] using h0
    | succ k ih => simpa [numeral] using hcl _ ih
  have hlt : numeral I < I := mem_lt (hmem I)
  have := numeral_ge I
  omega

end AntiMath