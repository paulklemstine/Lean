/-
# TRACEPROFILE I — the exact low-bit law of the trace

Phase A research file (Novelty domain), Paper 50 / Experiment 385.

Setting: `N = p * q` is a semiprime with odd factors, and `s = p + q` is its
*trace* (the minimal factor-bearing symmetric witness: the pair `(N, s)` already
determines `{p, q}`, see `Novelty.GCDMomentTraceWitness`).

The experiment reported an *exact* low-bit relation
`s₁ = 1 - N₁` (bit 1 of the trace is the complement of bit 1 of the modulus),
verified on 300000/300000 sampled pairs, together with the observation that the
next bit relation `s₂ ≠ N₂` only holds with probability ≈ 0.754.

This file proves the exact statement, in the sharp form

`p + q + p*q ≡ 3 (mod 4)`   for all odd `p, q`,

derives the bit form `s % 4 = 2 ↔ N % 4 = 1`, shows that the relation is
*deterministic in `N` alone* (so the visible bit carries **no** information about
the factorisation), and proves that the analogous relation modulo `8` is **false**
by exhibiting two odd pairs with the same `N % 8` but different `s % 8`.

## Main results

* `odd_mul_add_mod_four` — the exact law `(p + q + p*q) % 4 = 3`.
* `trace_mod_four_eq` — the bit form: `s % 4 = 2` iff `N % 4 = 1`, else `s % 4 = 0`.
* `trace_low_bit_eq_one_sub` — `s₁ = 1 - N₁` verbatim, with
  `N₁ = (N / 2) % 2`-style bit extraction replaced by `Nat.testBit`.
* `trace_mod_four_determined_by_N` — the bit is a function of `N % 4` alone, hence
  carries zero information about `(p, q)` beyond `N`.
* `trace_mod_eight_not_determined` — sharpness: no such exact law at bit 2.
-/

import Mathlib

namespace Novelty.TraceProfile

/-! ## The exact low-bit law -/

/-- **Exact low-bit theorem (sharp form).**  For odd `p` and `q`,
`p + q + p*q ≡ 3 (mod 4)`.  Equivalently `4 ∣ (p+1)*(q+1)`. -/
theorem odd_mul_add_mod_four {p q : ℕ} (hp : Odd p) (hq : Odd q) :
    (p + q + p * q) % 4 = 3 := by
  obtain ⟨a, rfl⟩ := hp
  obtain ⟨b, rfl⟩ := hq
  have : (2 * a + 1) + (2 * b + 1) + (2 * a + 1) * (2 * b + 1)
      = 4 * (a + b + a * b) + 3 := by ring
  omega

/-- The trace `s = p + q` of an odd semiprime is even. -/
theorem trace_even {p q : ℕ} (hp : Odd p) (hq : Odd q) : (p + q) % 2 = 0 := by
  obtain ⟨a, rfl⟩ := hp; obtain ⟨b, rfl⟩ := hq; omega

/-- **Bit form.**  `s % 4 = 2` exactly when `N % 4 = 1`, and `s % 4 = 0` exactly
when `N % 4 = 3`.  (Odd `N` has `N % 4 ∈ {1,3}`.) -/
theorem trace_mod_four_eq {p q : ℕ} (hp : Odd p) (hq : Odd q) :
    (p + q) % 4 = if (p * q) % 4 = 1 then 2 else 0 := by
  have h := odd_mul_add_mod_four hp hq
  have hpq : Odd (p * q) := hp.mul hq
  obtain ⟨c, hc⟩ := hpq
  have h4 : (p * q) % 4 = 1 ∨ (p * q) % 4 = 3 := by omega
  rcases h4 with h4 | h4 <;> simp [h4] <;> omega

/-- **`s₁ = 1 - N₁` verbatim**, in terms of binary digits: bit 1 of the trace is
the complement of bit 1 of the modulus. -/
theorem trace_low_bit_eq_one_sub {p q : ℕ} (hp : Odd p) (hq : Odd q) :
    ((p + q) / 2) % 2 = 1 - ((p * q) / 2) % 2 := by
  have h := odd_mul_add_mod_four hp hq
  have hpq : Odd (p * q) := hp.mul hq
  obtain ⟨c, hc⟩ := hpq
  omega

/-- The same statement with Mathlib's `Nat.testBit`. -/
theorem trace_testBit_one {p q : ℕ} (hp : Odd p) (hq : Odd q) :
    (p + q).testBit 1 = !((p * q).testBit 1) := by
  have h := trace_low_bit_eq_one_sub hp hq
  have h1 : (p + q).testBit 1 = decide (((p + q) / 2) % 2 = 1) :=
    Nat.testBit_eq_decide_div_mod_eq
  have h2 : (p * q).testBit 1 = decide (((p * q) / 2) % 2 = 1) :=
    Nat.testBit_eq_decide_div_mod_eq
  have hb1 : ((p + q) / 2) % 2 = 0 ∨ ((p + q) / 2) % 2 = 1 := by omega
  have hb2 : ((p * q) / 2) % 2 = 0 ∨ ((p * q) / 2) % 2 = 1 := by omega
  rcases hb1 with h3 | h3 <;> rcases hb2 with h4 | h4 <;>
    simp [h1, h2, h3, h4] <;> omega

/-! ## The visible bit is a function of `N` alone -/

/-- **Zero marginal information.**  The exact low bit of the trace is determined by
`N % 4`: two odd factorisations with the same modulus residue have the same trace
residue.  Hence the one exactly-visible low bit is *not* a leak about `(p,q)`. -/
theorem trace_mod_four_determined_by_N {p q p' q' : ℕ}
    (hp : Odd p) (hq : Odd q) (hp' : Odd p') (hq' : Odd q')
    (h : (p * q) % 4 = (p' * q') % 4) :
    (p + q) % 4 = (p' + q') % 4 := by
  rw [trace_mod_four_eq hp hq, trace_mod_four_eq hp' hq', h]

/-! ## Sharpness: the law does not extend to the next bit -/

/-- **Sharpness at bit 2.**  There are two odd pairs with the *same* `N % 8` but
*different* `s % 8`; so no exact relation `s₂ = f (N₂)` can hold.  (Experimentally
`s₂ ≠ N₂` only with probability 0.754.) -/
theorem trace_mod_eight_not_determined :
    ∃ p q p' q' : ℕ, Odd p ∧ Odd q ∧ Odd p' ∧ Odd q' ∧
      (p * q) % 8 = (p' * q') % 8 ∧ (p + q) % 8 ≠ (p' + q') % 8 := by
  refine ⟨3, 3, 5, 13, ⟨1, rfl⟩, ⟨1, rfl⟩, ⟨2, rfl⟩, ⟨6, rfl⟩, by norm_num, by norm_num⟩

/-- **Quantitative companion (the 3/4 law).**  In the uniform model over odd
residues mod `8` — which is all that `s % 8` and `N % 8` depend on — bit 2 of the
trace differs from bit 2 of the modulus for `12` of the `16` residue pairs, i.e.
with probability `3/4`.  The experiment measured `0.754`. -/
theorem trace_bit_two_disagrees_three_quarters :
    4 * (((Finset.range 8 ×ˢ Finset.range 8).filter
        (fun z => z.1 % 2 = 1 ∧ z.2 % 2 = 1 ∧
          ((z.1 + z.2) % 8) / 4 ≠ ((z.1 * z.2) % 8) / 4)).card)
      = 3 * (((Finset.range 8 ×ˢ Finset.range 8).filter
          (fun z => z.1 % 2 = 1 ∧ z.2 % 2 = 1)).card) := by
  decide

end Novelty.TraceProfile