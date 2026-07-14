import Mathlib

/-!
# Quantitative Independence: The Boolean Cube of Branches

Direction 5 of the research programme.  Fix `n` mutually independent atomic
assertions.  A **branch** of the multiverse is a truth assignment to the atoms,
`Branch n := Fin n → Bool`, and there are exactly `2 ^ n` of them.  A **sentence**
is a Boolean combination of the atoms, i.e. a function `Sentence n := Branch n →
Bool`, and there are exactly `2 ^ (2 ^ n)` of them.

A sentence is **valid** if it holds on every branch, **refutable** if it holds on
none, and **independent** (undecidable in the multiverse) otherwise.  We prove:

* `card_branches`  — there are `2 ^ n` branches;
* `card_sentences` — there are `2 ^ (2 ^ n)` sentences;
* `settled_eq_pair` — the *settled* sentences are exactly the two constants;
* `card_settled`   — hence exactly `2` sentences are settled;
* `card_independent` — exactly `2 ^ (2 ^ n) - 2` sentences are independent;
* `independent_ratio_tendsto_one` — the proportion of independent sentences tends
  to `1` as `n → ∞`.

So *independence is generic*: undecidability is the typical case among Boolean
combinations of independent atoms, not the exception.
-/

namespace Multiverse

/-- A branch of the multiverse: a truth assignment to the `n` atomic assertions. -/
abbrev Branch (n : ℕ) := Fin n → Bool

/-- A sentence: a Boolean combination of the atoms, viewed as a map from branches
to truth values. -/
abbrev Sentence (n : ℕ) := Branch n → Bool

/-- A sentence is **valid** when it holds on every branch. -/
def IsValid {n : ℕ} (s : Sentence n) : Prop := ∀ b, s b = true

/-- A sentence is **refutable** when it holds on no branch. -/
def IsRefutable {n : ℕ} (s : Sentence n) : Prop := ∀ b, s b = false

instance {n : ℕ} (s : Sentence n) : Decidable (IsValid s) :=
  inferInstanceAs (Decidable (∀ b, s b = true))

instance {n : ℕ} (s : Sentence n) : Decidable (IsRefutable s) :=
  inferInstanceAs (Decidable (∀ b, s b = false))

/-- The Finset of *settled* (valid or refutable) sentences. -/
def settled (n : ℕ) : Finset (Sentence n) :=
  Finset.univ.filter (fun s => IsValid s ∨ IsRefutable s)

/-- The Finset of *independent* sentences: neither valid nor refutable. -/
def independent (n : ℕ) : Finset (Sentence n) := (settled n)ᶜ

/-
There are exactly `2 ^ n` branches over `n` atoms.
-/
theorem card_branches (n : ℕ) : Fintype.card (Branch n) = 2 ^ n := by
  norm_num

/-
There are exactly `2 ^ (2 ^ n)` sentences over `n` atoms.
-/
theorem card_sentences (n : ℕ) : Fintype.card (Sentence n) = 2 ^ (2 ^ n) := by
  convert Fintype.card_fun;
  convert card_branches n |> Eq.symm

/-
The settled sentences are exactly the two constant functions
`fun _ => true` and `fun _ => false`.
-/
theorem settled_eq_pair (n : ℕ) :
    settled n = {(fun _ => true), (fun _ => false)} := by
  ext s; simp [settled];
  unfold IsValid IsRefutable; aesop;

/-
Exactly two sentences are settled.
-/
theorem card_settled (n : ℕ) : (settled n).card = 2 := by
  convert Finset.card_pair ?_;
  convert settled_eq_pair n;
  cases n <;> simp +decide [ funext_iff ]

/-
Exactly `2 ^ (2 ^ n) - 2` sentences are independent.
-/
theorem card_independent (n : ℕ) : (independent n).card = 2 ^ (2 ^ n) - 2 := by
  rw [ ← card_sentences, ← card_settled ];
  rw [ ← Finset.card_compl ];
  rfl

/-
**Independence is generic.**  The proportion of independent sentences among
all sentences tends to `1` as the number of atoms grows.
-/
theorem independent_ratio_tendsto_one :
    Filter.Tendsto
      (fun n => ((independent n).card : ℝ) / (Fintype.card (Sentence n) : ℝ))
      Filter.atTop (nhds 1) := by
  -- Rewrite the ratio using `card_independent n` and `card_sentences n`.
  have h_ratio : ∀ n, ((independent n).card : ℝ) / ((Fintype.card (Sentence n)) : ℝ) = 1 - 2 / (2 : ℝ) ^ (2 ^ n) := by
    intro n
    have hle : (2 : ℕ) ≤ 2 ^ (2 ^ n) := by
      calc (2 : ℕ) = 2 ^ 1 := by norm_num
        _ ≤ 2 ^ (2 ^ n) := Nat.pow_le_pow_right (by norm_num) (Nat.one_le_two_pow)
    rw [card_independent, card_sentences, Nat.cast_sub hle]
    push_cast
    field_simp
  simpa only [ h_ratio ] using le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two |> Filter.Tendsto.comp <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) <| by norm_num;

end Multiverse