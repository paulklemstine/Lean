/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XI: How Much Randomness Does the Encoder Need?

## Bridge: pigeonhole (combinatorics) ↔ universal hashing (algebra)
##         ↔ derandomization (complexity)

Every achievability theorem of this development starts from a 2-universal family
`H : Fin K → α → Fin M` and *derandomizes* it (`exists_good_key`): the encoder
only has to store one key, i.e. `log₂ K` bits of advice.  Conjecture 5 of the
previous cycle asked how small `K` can be.  Here we prove a hard limit, and it
is the pigeonhole principle again — now applied to the **key space** rather than
to the code space:

* `universal2_card_le_pow` — a 2-universal family with `M ≥ 2` and at least one
  key, on a domain of size `n`, satisfies `n ≤ M^K`;
* `universal2_key_lower_bound` — equivalently `K ≥ log_M n`: the number of keys
  must grow at least logarithmically in the source size, so no constant-size
  family of hash functions can be universal on an unbounded source;
* `linHash_key_bound_sharp_order` — the explicit field family of
  `AlmostLosslessLinearHash` has `K = p` keys on a domain of size `p²`, meeting
  the bound `n ≤ M^K` with room to spare while using only `log₂ p` bits of
  advice: **half** the bits of the message it compresses.

The moral for Monte-Carlo compression: randomness cannot be eliminated, but
`log₂ K` bits of it always suffice, and the field construction already achieves
`log₂ K = ½ log₂ n`.

## Impact: key_space_lower_bound, derandomization_limits
-/

import Mathlib
import Bridges.AlmostLosslessLinearHash

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section KeyBound

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

omit [DecidableEq α] in
/-- **Pigeonhole in the key space.**  If a family of `K` hash functions into `M ≥ 2`
values is 2-universal, then the source cannot have more than `M^K` symbols:
otherwise two symbols would have identical hash vectors and would therefore
collide under *every* key, contradicting universality. -/
theorem universal2_card_le_pow {H : Fin K → α → Fin M} (hU : Universal2 H)
    (hK : 0 < K) (hM : 2 ≤ M) : Fintype.card α ≤ M ^ K := by
  by_contra hcon
  push_neg at hcon
  have hcards : Fintype.card (Fin K → Fin M) < Fintype.card α := by
    rw [Fintype.card_fun, Fintype.card_fin, Fintype.card_fin]
    exact hcon
  obtain ⟨x, y, hxy, hf⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun x : α => fun k : Fin K => H k x) hcards
  have hall : (Finset.univ.filter (fun k => H k x = H k y)) = Finset.univ := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
    exact congrFun hf k
  have hbound := hU x y hxy
  rw [hall, Finset.card_univ, Fintype.card_fin] at hbound
  -- `K · M ≤ K` with `M ≥ 2` forces `K ≤ 0`
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  have hMR : (2 : ℝ) ≤ M := by exact_mod_cast hM
  nlinarith [hbound, hKR, hMR]

omit [DecidableEq α] in
/-- **Key-space lower bound.**  A 2-universal family on a source of `n` symbols
with `M ≥ 2` codewords needs at least `log_M n` keys; equivalently the encoder
must be able to name `log₂ n / log₂ M` distinct hash functions.  Randomness
cannot be removed from Monte-Carlo compression, only compressed. -/
theorem universal2_key_lower_bound {H : Fin K → α → Fin M} (hU : Universal2 H)
    (hK : 0 < K) (hM : 2 ≤ M) : Nat.log M (Fintype.card α) ≤ K := by
  have h := universal2_card_le_pow hU hK hM
  rcases Nat.eq_zero_or_pos (Fintype.card α) with h0 | hpos
  · simp [h0]
  · have : Nat.log M (Fintype.card α) ≤ Nat.log M (M ^ K) := Nat.log_mono_right h
    rwa [Nat.log_pow (by omega)] at this

end KeyBound

section Explicit

variable (p : ℕ) [Fact p.Prime]

/-- The explicit field family meets the key-space bound comfortably: it has
`K = p` keys on a domain of `p²` symbols with `M = p` codewords, so
`|α| = p² ≤ p^p` as soon as `p ≥ 2`, and the advice is `log₂ p` bits — half the
`2 log₂ p` bits of a raw source symbol. -/
theorem linHash_key_bound_sharp_order (hp : 2 ≤ p) :
    Fintype.card (ZMod p × ZMod p) = p ^ 2
      ∧ Fintype.card (ZMod p × ZMod p) ≤ p ^ p := by
  have hcard : Fintype.card (ZMod p × ZMod p) = p ^ 2 := by
    have hp0 : 0 < p := (Fact.out : p.Prime).pos
    haveI : NeZero p := ⟨by omega⟩
    rw [Fintype.card_prod, ZMod.card]
    ring
  refine ⟨hcard, ?_⟩
  rw [hcard]
  exact Nat.pow_le_pow_right (by omega) hp

end Explicit

end AlmostLossless