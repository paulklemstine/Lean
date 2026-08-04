/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Merkle–Damgård construction

The Merkle–Damgård transform builds a hash function on arbitrary block lists out
of a fixed-input-length compression function `f : State → Block → State`, by
iterating `f` from an initialization vector.

This file records two basic facts:

* `compression_collision_of_card` — a compression function that consumes at least
  one bit of input (`1 < #Block`) is *never* injective: by pigeonhole two distinct
  pairs `(s, b) ≠ (s', b')` collide.  This is the reason a fixed hash function can
  never be an injective extractor.
* `collision_extends` — the Merkle–Damgård transform is collision preserving: a
  collision in the compression function yields a collision of the full hash on
  block lists sharing a common suffix.
-/

namespace Cryptography.MerkleDamgard

variable {State Block : Type*}

/-- The Merkle–Damgård iterated hash: fold the compression function `f` over the
list of message blocks, starting from the state `iv`. -/
def hash (f : State → Block → State) (iv : State) : List Block → State
  | [] => iv
  | b :: bs => hash f (f iv b) bs

@[simp] theorem hash_nil (f : State → Block → State) (iv : State) :
    hash f iv [] = iv := rfl

@[simp] theorem hash_cons (f : State → Block → State) (iv : State) (b : Block)
    (bs : List Block) : hash f iv (b :: bs) = hash f (f iv b) bs := rfl

/-- The hash of a concatenation is the hash of the suffix started from the state
reached after the prefix. -/
theorem hash_append (f : State → Block → State) (iv : State) (bs cs : List Block) :
    hash f iv (bs ++ cs) = hash f (hash f iv bs) cs := by
  induction bs generalizing iv with
  | nil => simp
  | cons b bs ih => simp [ih]

/-- **Pigeonhole collision.**  A compression function `f : State → Block → State`
whose block alphabet has more than one element is never injective: there are two
distinct pairs with the same image. -/
theorem compression_collision_of_card [Fintype State] [Fintype Block] [Nonempty State]
    (hB : 1 < Fintype.card Block) (f : State → Block → State) :
    ∃ (s : State) (b : Block) (s' : State) (b' : Block),
      (s, b) ≠ (s', b') ∧ f s b = f s' b' := by
  have hcard : Fintype.card State < Fintype.card (State × Block) := by
    rw [Fintype.card_prod]
    have hS : 0 < Fintype.card State := Fintype.card_pos
    nlinarith [hS, hB]
  obtain ⟨x, y, hne, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun sb : State × Block => f sb.1 sb.2) hcard
  exact ⟨x.1, x.2, y.1, y.2, by simpa using hne, heq⟩

/-- **Collision preservation.**  A collision of the compression function at a
common state gives a collision of the Merkle–Damgård hash: appending any common
suffix keeps the outputs equal, while the messages stay distinct. -/
theorem collision_extends (f : State → Block → State) (iv : State) {b b' : Block}
    (hcol : f iv b = f iv b') (cs : List Block) :
    hash f iv (b :: cs) = hash f iv (b' :: cs) := by
  simp [hash_cons, hcol]

/-- Consequently, no fixed compression function over a nontrivial block alphabet
is injective as a map on (state, block) pairs. -/
theorem not_injective_compression [Fintype State] [Fintype Block] [Nonempty State]
    (hB : 1 < Fintype.card Block) (f : State → Block → State) :
    ¬ Function.Injective (fun sb : State × Block => f sb.1 sb.2) := by
  obtain ⟨s, b, s', b', hne, heq⟩ := compression_collision_of_card hB f
  intro hinj
  exact hne (hinj heq)

end Cryptography.MerkleDamgard