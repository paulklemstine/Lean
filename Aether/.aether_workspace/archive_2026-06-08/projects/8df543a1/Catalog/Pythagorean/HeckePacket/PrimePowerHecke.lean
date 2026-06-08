/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.HeckePacket.Defs

/-!
# Prime-Power Hecke Relation

This file proves the Hecke multiplication formula for prime powers:
for a normalized unramified Hecke eigenpacket,

$$a(p^s) \cdot a(p^t) = \sum_{i=0}^{\min(s,t)} p^i \cdot a(p^{s+t-2i})$$

This is derived from the prime-power recursion by induction on `s` (with `s ≤ t`).

## Proof Strategy

1. First prove a rearranged form of the recursion:
   `a(p) * a(p^n) = a(p^{n+1}) + p * a(p^{n-1})` for `n ≥ 1`.
2. Prove the formula for `s ≤ t` by induction on `s`.
3. Derive the general formula using commutativity and `min` symmetry.
-/

open Finset BigOperators Nat

namespace UnramifiedHeckePacket

set_option maxHeartbeats 800000

variable {R : Type*} [CommRing R] (pkt : UnramifiedHeckePacket R)

/-- Rearranged prime-power recursion: `a(p) * a(p^{n+1}) = a(p^{n+2}) + p * a(p^n)`.
This is the "upward" form of the three-term recurrence. -/
theorem coeff_prime_mul_succ {p : ℕ} (hp : Nat.Prime p) (n : ℕ) :
    pkt.a p * pkt.a (p ^ (n + 1)) = pkt.a (p ^ (n + 2)) + (p : R) * pkt.a (p ^ n) := by
  have h := pkt.coeff_prime_power_rec (p := p) (r := n) hp
  rw [h]; ring

/-
The Hecke prime-power formula for `s ≤ t`:

`a(p^s) * a(p^t) = ∑_{i=0}^{s} p^i * a(p^{s+t-2i})`

Proved by induction on `s`.
-/
theorem coeff_hecke_prime_powers_le
    {p : ℕ} (hp : Nat.Prime p) :
    ∀ (s t : ℕ), s ≤ t →
      pkt.a (p ^ s) * pkt.a (p ^ t) =
        ∑ i ∈ Finset.range (s + 1),
          (p : R) ^ i * pkt.a (p ^ (s + t - 2 * i)) := by
  -- We proceed by strong induction on `s`.
  intro s t hst
  induction' s using Nat.strong_induction_on with s ih generalizing t;
  rcases s with ( _ | _ | s ) <;> simp_all +decide [ Finset.sum_range_succ' ];
  · rw [ pkt.a_one, one_mul ];
  · convert coeff_prime_mul_succ pkt hp ( t - 1 ) using 1 <;> cases t <;> simp_all +decide [ Nat.succ_eq_add_one, add_comm, add_left_comm, add_assoc ];
  · -- Apply the prime-power recursion to rewrite `a(p^{s+2})` in terms of `a(p^{s+1})` and `a(p^s)`.
    have h_rec : pkt.a (p ^ (s + 2)) = pkt.a p * pkt.a (p ^ (s + 1)) - (p : R) * pkt.a (p ^ s) := by
      exact pkt.prime_power_rec p s hp;
    have h_ind_step : pkt.a p * (∑ k ∈ Finset.range (s + 1), p ^ (k + 1) * pkt.a (p ^ (s + 1 + t - 2 * (k + 1))) + pkt.a (p ^ (s + 1 + t))) - p * (∑ k ∈ Finset.range s, p ^ (k + 1) * pkt.a (p ^ (s + t - 2 * (k + 1))) + pkt.a (p ^ (s + t))) = ∑ k ∈ Finset.range (s + 2), p ^ (k + 1) * pkt.a (p ^ (s + 2 + t - 2 * (k + 1))) + pkt.a (p ^ (s + 2 + t)) := by
      have h_ind_step : pkt.a p * (∑ k ∈ Finset.range (s + 1), p ^ (k + 1) * pkt.a (p ^ (s + 1 + t - 2 * (k + 1)))) = ∑ k ∈ Finset.range (s + 1), p ^ (k + 1) * (pkt.a (p ^ (s + 2 + t - 2 * (k + 1))) + p * pkt.a (p ^ (s + t - 2 * (k + 1)))) := by
        rw [ Finset.mul_sum _ _ _ ];
        refine' Finset.sum_congr rfl fun i hi => _;
        rw [ show s + 2 + t - 2 * ( i + 1 ) = ( s + 1 + t - 2 * ( i + 1 ) ) + 1 by rw [ tsub_add_eq_add_tsub ( by linarith [ Finset.mem_range.mp hi ] ) ] ; ring ] ; simp +decide [ mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, pow_succ' ] ; ring;
        rw [ show 1 + s + t - ( 2 + i * 2 ) = ( s + t - ( 2 + i * 2 ) ) + 1 by rw [ tsub_add_eq_add_tsub ( by linarith [ Finset.mem_range.mp hi ] ) ] ; ring ] ; simp +decide [ pow_succ', mul_assoc, mul_comm, mul_left_comm, hp.ne_zero ] ; ring;
        have := coeff_prime_mul_succ pkt hp ( s + t - ( 2 + i * 2 ) ) ; simp_all +decide [ pow_succ', mul_assoc, mul_comm, mul_left_comm ] ; ring;
      simp_all +decide [ Finset.sum_range_succ, mul_add, add_mul, pow_succ', mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
      rw [ show s + 2 + t = s + 1 + t + 1 by ring, show s + t = s + 1 + t - 1 by omega ] ; simp +decide [ pow_succ', mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ] ; ring;
      rw [ show 1 + s + t - ( 3 + s * 2 ) = s + t - ( 2 + s * 2 ) by omega ] ; ring;
      rw [ show p ^ 2 * p ^ s * p ^ t = p * p ^ s * p ^ t * p by ring ] ; rw [ show pkt.a ( p * p ^ s * p ^ t * p ) = pkt.a p * pkt.a ( p * p ^ s * p ^ t ) - p * pkt.a ( p ^ s * p ^ t ) by
                                                                                convert pkt.prime_power_rec p ( s + t ) hp using 1 ; ring;
                                                                                ring ] ; ring;
    convert h_ind_step using 1;
    · rw [ ← ih _ le_rfl _ ( by linarith ), ← ih _ ( by linarith ) _ ( by linarith ) ];
      rw [ ← mul_assoc, ← mul_assoc, ← sub_mul, h_rec ];
    · simp +decide [ Finset.sum_range_succ', pow_succ', mul_assoc, mul_left_comm, mul_add, add_assoc ]

/-
**Prime-power Hecke relation** (general form).

For any prime `p` and exponents `s, t`, the product of prime-power
coefficients decomposes as:

`a(p^s) · a(p^t) = ∑_{i=0}^{min(s,t)} p^i · a(p^{s+t-2i})`
-/
theorem coeff_hecke_relation_prime_powers
    {p : ℕ} (hp : Nat.Prime p) (s t : ℕ) :
    pkt.a (p ^ s) * pkt.a (p ^ t) =
      ∑ i ∈ Finset.range (min s t + 1),
        (p : R) ^ i * pkt.a (p ^ (s + t - 2 * i)) := by
  cases le_total s t <;> simp_all +decide [ UnramifiedHeckePacket.coeff_hecke_prime_powers_le ];
  convert UnramifiedHeckePacket.coeff_hecke_prime_powers_le pkt hp t s ‹_› using 1 ; ring;
  ac_rfl

end UnramifiedHeckePacket