import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry
import Physics.PermutationReadoutZolotarev
import Physics.PermutationReadoutJacobi

/-!
# How much richer is the composite readout? An exact excess formula

The PERMORD claim is that the cycle spectrum on `ZMod (p·q)` is strictly richer
than the unit-group datum `ord_N(a) = lcm(ord_p a, ord_q a)`.  This file
measures the surplus exactly, by comparing the composite readout with the two
prime readouts it is built from.

Writing `i_p = (p−1)/ord_p(a)` and `i_q = (q−1)/ord_q(a)` for the two indices,
the prime readouts have `i_p + 1` and `i_q + 1` cycles, while the composite one
has

`#cycles(pq) = #cycles(p) · #cycles(q) + (gcd(ord_p a, ord_q a) − 1) · i_p · i_q`.

So the cycle count is **supermultiplicative**, and the entire surplus is
governed by a single number: `gcd(ord_p a, ord_q a)`.  This is exactly the
quantity that the lcm hides — `lcm · gcd = ord_p · ord_q` — which makes precise
the sense in which the permutation readout "closes the lcm-blindness loophole":
it adds the gcd, and nothing else.

Conversely the surplus vanishes precisely when the two local orders are coprime,
in which case the composite spectrum is the plain product of the prime spectra
and no new information is available at all.

## Main results

* `Physics.PermReadout.cycleCount_excess` — the exact excess formula.
* `Physics.PermReadout.cycleCount_supermultiplicative` — `#cycles(pq) ≥
  #cycles(p)·#cycles(q)`.
* `Physics.PermReadout.cycleCount_eq_prod_iff_coprime_orders` — equality holds
  iff `gcd(ord_p a, ord_q a) = 1`.
* `Physics.PermReadout.excess_pos_of_primitive` — if `a` is primitive at
  both primes, the surplus is `gcd(p−1, q−1) − 1`, which is at least `1` for
  odd primes: the composite readout is then strictly richer.
-/

namespace Physics.PermReadout

open Finset

section Excess

variable {p q a : ℕ}

/-- Each Legendre index `i_p = (p−1)/ord_p(a)` is positive. -/
theorem index_pos (hp : p.Prime) (hcop : Nat.Coprime a p) :
    0 < (p - 1) / orderOf ((a : ZMod p)) := by
  have h0 : 0 < orderOf ((a : ZMod p)) := orderOf_pos_of_coprime hcop
  obtain ⟨i, hi⟩ := orderOf_dvd_prime_sub_one hp hcop
  have hp1 : 0 < p - 1 := by have := hp.two_le; omega
  rw [hi, Nat.mul_div_cancel_left _ h0]
  rcases Nat.eq_zero_or_pos i with rfl | h
  · simp at hi; omega
  · exact h

/-- **The exact excess formula.**  The composite cycle count exceeds the product
of the two prime cycle counts by `(gcd(ord_p a, ord_q a) − 1) · i_p · i_q`. -/
theorem cycleCount_excess (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    cycleCount (p * q) a
      = cycleCount p a * cycleCount q a
        + (Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) - 1)
            * ((p - 1) / orderOf ((a : ZMod p))) * ((q - 1) / orderOf ((a : ZMod q))) := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hcp : Nat.Coprime a p := Nat.Coprime.coprime_dvd_right ⟨q, rfl⟩ hcop
  have hcq : Nat.Coprime a q := Nat.Coprime.coprime_dvd_right ⟨p, mul_comm p q⟩ hcop
  have hgpos : 0 < Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) :=
    Nat.gcd_pos_of_pos_left _ (orderOf_pos_of_coprime hcp)
  obtain ⟨g, hg⟩ : ∃ g, Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) = g + 1 :=
    ⟨_, (Nat.succ_pred_eq_of_pos hgpos).symm⟩
  rw [cycleCount_semiprime hp hq hpq hcop, totient_div_orderOf_semiprime hp hq hpq hcop,
    cycleCount_prime hp hcp, cycleCount_prime hq hcq, hg]
  simp only [Nat.add_sub_cancel]
  ring

/-- **Supermultiplicativity of the readout.**  Gluing two prime moduli never
loses cycles. -/
theorem cycleCount_supermultiplicative (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    cycleCount p a * cycleCount q a ≤ cycleCount (p * q) a := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  rw [cycleCount_excess hp hq hpq hcop]
  exact Nat.le_add_right _ _

/-- **The surplus is exactly the gcd of the two local orders.**  The composite
readout collapses to the product of the prime readouts precisely when
`ord_p(a)` and `ord_q(a)` are coprime — i.e. precisely when the lcm already
determines the pair. -/
theorem cycleCount_eq_prod_iff_coprime_orders (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    (cycleCount (p * q) a = cycleCount p a * cycleCount q a
      ↔ Nat.Coprime (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q)))) := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hcp : Nat.Coprime a p := Nat.Coprime.coprime_dvd_right ⟨q, rfl⟩ hcop
  have hcq : Nat.Coprime a q := Nat.Coprime.coprime_dvd_right ⟨p, mul_comm p q⟩ hcop
  have hip := index_pos hp hcp
  have hiq := index_pos hq hcq
  have hgpos : 0 < Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) :=
    Nat.gcd_pos_of_pos_left _ (orderOf_pos_of_coprime hcp)
  rw [cycleCount_excess hp hq hpq hcop]
  constructor
  · intro h
    have hz : (Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) - 1)
        * ((p - 1) / orderOf ((a : ZMod p))) * ((q - 1) / orderOf ((a : ZMod q))) = 0 := by
      omega
    have hG : Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) = 1 := by
      rcases Nat.mul_eq_zero.mp hz with h1 | h1
      · rcases Nat.mul_eq_zero.mp h1 with h2 | h2
        · omega
        · omega
      · omega
    exact hG
  · intro h
    have : Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) = 1 := h
    rw [this]
    simp

/-- **The primitive case is always strictly richer.**  If `a` is a primitive
root modulo both odd primes, the surplus is `gcd(p−1, q−1) − 1 ≥ 1`, since
`p − 1` and `q − 1` are both even.  So for the most informative multipliers the
composite spectrum genuinely exceeds the two prime spectra. -/
theorem excess_pos_of_primitive (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hcop : Nat.Coprime a (p * q))
    (hprimp : orderOf ((a : ZMod p)) = p - 1) (hprimq : orderOf ((a : ZMod q)) = q - 1) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    cycleCount p a * cycleCount q a < cycleCount (p * q) a := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hcp : Nat.Coprime a p := Nat.Coprime.coprime_dvd_right ⟨q, rfl⟩ hcop
  have hcq : Nat.Coprime a q := Nat.Coprime.coprime_dvd_right ⟨p, mul_comm p q⟩ hcop
  have hpodd : p % 2 = 1 := hp.eq_two_or_odd.resolve_left hp2
  have hqodd : q % 2 = 1 := hq.eq_two_or_odd.resolve_left hq2
  have hp2' := hp.two_le
  have hq2' := hq.two_le
  have hip := index_pos hp hcp
  have hiq := index_pos hq hcq
  -- both `p−1` and `q−1` are even, hence `2 ∣ gcd(p−1, q−1)`
  have hg2 : 2 ≤ Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) := by
    rw [hprimp, hprimq]
    have h2 : 2 ∣ Nat.gcd (p - 1) (q - 1) := Nat.dvd_gcd (by omega) (by omega)
    have hgpos : 0 < Nat.gcd (p - 1) (q - 1) := Nat.gcd_pos_of_pos_left _ (by omega)
    omega
  rw [cycleCount_excess hp hq hpq hcop]
  have hpos : 0 < (Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) - 1)
      * ((p - 1) / orderOf ((a : ZMod p))) * ((q - 1) / orderOf ((a : ZMod q))) :=
    Nat.mul_pos (Nat.mul_pos (by omega) hip) hiq
  omega

end Excess

end Physics.PermReadout