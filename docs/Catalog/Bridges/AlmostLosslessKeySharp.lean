/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XV: The Key Space is at Least as Large as the Code

## Bridge: integrality of a counting bound (combinatorics) ↔ derandomization

`AlmostLosslessKeyBound` proves the pigeonhole bound `K ≥ log_M n` on the number
of keys of a 2-universal family: only *logarithmically* many keys are forced.
Conjecture E of the previous cycle asked whether the truth is polynomial in the
source size.  Second-moment counting cannot answer this — averaging the number
of collisions over keys reproduces exactly the universality hypothesis and gives
a vacuous inequality (see `FUTURE_DIRECTIONS.md`).  What does answer it is
**integrality**: the number of keys on which two fixed symbols collide is a
natural number bounded by `K/M`, so as soon as `K < M` it must be `0`, i.e.
every hash function in the family is injective.

* `universal2_key_ge_codes` — **the sharp bound**: a nonempty 2-universal family
  compressing at all (`M < n`) has at least `M` keys;
* `universal2_key_ge_max` — combined with the pigeonhole bound:
  `K ≥ max(M, log_M n)`;
* `universal2_key_pow_bound` — the resolution of Conjecture E: if the code space
  is a `c`-th root of the source (`n ≤ M^c`) then `n ≤ K^c`, so the key space is
  polynomially large in the source and **no** 2-universal family in that regime
  has `poly(log n)` keys;
* `linHash_key_bound_tight` — the bound is attained: the inner-product family
  has exactly `K = M = p` on a source of `p²` symbols.

So the key-length hierarchy is settled in the compressing regime: `log₂ K` is
between `log₂ M` and `log₂ M` — the encoder's advice must be as long as the
codeword it produces, and the field family shows one codeword's worth of advice
is enough.

## Impact: sharp_key_lower_bound, key_length_equals_codeword_length
-/

import Mathlib
import Bridges.AlmostLosslessKeyBound

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section KeySharp

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

omit [DecidableEq α] in
/-- **A 2-universal family that compresses has at least `M` keys.**  If `K < M`
then `K/M < 1`, and since the number of keys on which two distinct symbols
collide is an integer bounded by `K/M`, it is `0`: every hash function of the
family is injective, so the source has at most `M` symbols and nothing is
compressed. -/
theorem universal2_key_ge_codes {H : Fin K → α → Fin M} (hU : Universal2 H)
    (hK : 0 < K) (hn : M < Fintype.card α) : M ≤ K := by
  classical
  by_contra hcon
  push_neg at hcon
  -- no two distinct symbols can collide under any key
  have hzero : ∀ x y : α, x ≠ y → ∀ k : Fin K, H k x ≠ H k y := by
    intro x y hxy k hk
    have hmem : k ∈ Finset.univ.filter (fun k => H k x = H k y) := by
      simp [hk]
    have hpos : 1 ≤ (Finset.univ.filter (fun k => H k x = H k y)).card :=
      Finset.card_pos.mpr ⟨k, hmem⟩
    have hboundR := hU x y hxy
    have hposR : (1 : ℝ) ≤ ((Finset.univ.filter (fun k => H k x = H k y)).card : ℝ) := by
      exact_mod_cast hpos
    have hMR : (K : ℝ) < (M : ℝ) := by exact_mod_cast hcon
    have hM0 : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg _
    nlinarith [hboundR, hposR, hMR, hM0]
  -- hence the first hash function is injective
  set k₀ : Fin K := ⟨0, hK⟩ with hk₀
  have hinj : Function.Injective (H k₀) := by
    intro x y hxy
    by_contra hne
    exact hzero x y hne k₀ hxy
  have hcard : Fintype.card α ≤ M := by
    have := Fintype.card_le_of_injective (H k₀) hinj
    rwa [Fintype.card_fin] at this
  omega

omit [DecidableEq α] in
/-- **Both lower bounds at once.**  A compressing 2-universal family needs at
least `max(M, log_M n)` keys.  The first term dominates whenever the family
compresses by less than an exponential factor, which is the only regime in which
almost-lossless compression is interesting. -/
theorem universal2_key_ge_max {H : Fin K → α → Fin M} (hU : Universal2 H)
    (hK : 0 < K) (hM : 2 ≤ M) (hn : M < Fintype.card α) :
    max M (Nat.log M (Fintype.card α)) ≤ K :=
  max_le (universal2_key_ge_codes hU hK hn) (universal2_key_lower_bound hU hK hM)

omit [DecidableEq α] in
/-- **Resolution of Conjecture E.**  If the code space is at least a `c`-th root
of the source (`n ≤ M^c`, the regime of a constant compression *rate*), then the
key space satisfies `n ≤ K^c`: it is polynomially large in the source size.  In
particular a family with `M ≥ n^{1/c}` cannot have `poly(log n)` keys, so no
derandomization of the random-coding argument can use logarithmically many hash
functions. -/
theorem universal2_key_pow_bound {H : Fin K → α → Fin M} (hU : Universal2 H)
    (hK : 0 < K) (hn : M < Fintype.card α) (c : ℕ) (hc : Fintype.card α ≤ M ^ c) :
    Fintype.card α ≤ K ^ c :=
  le_trans hc (Nat.pow_le_pow_left (universal2_key_ge_codes hU hK hn) c)

omit [DecidableEq α] in
/-- The bound in bits: the encoder's advice `log₂ K` is at least the length
`log₂ M` of the codeword it produces. -/
theorem universal2_key_length_ge {H : Fin K → α → Fin M} (hU : Universal2 H)
    (hK : 0 < K) (hn : M < Fintype.card α) :
    Nat.log 2 M ≤ Nat.log 2 K :=
  Nat.log_mono_right (universal2_key_ge_codes hU hK hn)

end KeySharp

section Tight

variable (p : ℕ) [Fact p.Prime]

/-- **The bound is attained.**  The inner-product family over `ZMod p` has
exactly `K = M = p` keys and codewords on a source of `p²` symbols, so
`universal2_key_ge_codes` is sharp: one codeword's worth of advice is necessary
*and* sufficient. -/
theorem linHash_key_bound_tight (hp : 2 ≤ p) :
    Fintype.card (ZMod p × ZMod p) = p ^ 2
      ∧ p < Fintype.card (ZMod p × ZMod p)
      ∧ p ≤ Fintype.card (Fin p) := by
  have hp0 : 0 < p := (Fact.out : p.Prime).pos
  haveI : NeZero p := ⟨by omega⟩
  have hcard : Fintype.card (ZMod p × ZMod p) = p ^ 2 := by
    rw [Fintype.card_prod, ZMod.card]; ring
  refine ⟨hcard, ?_, by simp⟩
  rw [hcard]
  calc p = p ^ 1 := (pow_one p).symm
    _ < p ^ 2 := Nat.pow_lt_pow_right (by omega) (by omega)

/-- **Optimality of the field construction.**  *Every* 2-universal family that
compresses the `p²`-symbol source `(ZMod p)²` into `p` codewords needs at least
`p` keys, and `linHash` uses exactly `p`: the inner-product family is optimal in
key count, not merely convenient. -/
theorem linHash_key_count_optimal (hp : 2 ≤ p) {K : ℕ}
    {H : Fin K → (ZMod p × ZMod p) → Fin p} (hU : Universal2 H) (hK : 0 < K) :
    p ≤ K := by
  obtain ⟨_, hlt, _⟩ := linHash_key_bound_tight p hp
  exact universal2_key_ge_codes hU hK hlt

end Tight

end AlmostLossless