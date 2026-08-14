import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry

/-!
# Zolotarev parity: the cycle count already knows the Legendre symbol

For a prime modulus the permutation `x ↦ a·x` of `ZMod p` has `1 + (p−1)/ord_p(a)`
cycles, and the parity of `p − #cycles` — the parity that determines the sign of
the permutation — is exactly the quadratic character of `a`.  This is Zolotarev's
lemma, proved here in a sign-free form directly from the cycle count computed by
the stratification law.

The consequence for the PERMORD programme is a sharpening of the "no new
information" verdict: the coarsest possible readout of the cycle structure,
namely the parity of the number of cycles, is *already* a polynomial-time
computable quantity (Euler's criterion), so no attack can extract secret
structure from it.

## Main results

* `Physics.PermReadout.cycleCount_prime` — `#cycles = (p−1)/ord_p(a) + 1`.
* `Physics.PermReadout.isSquare_iff_even_index` — `a` is a square mod `p` iff
  the index `(p−1)/ord_p(a)` is even.
* `Physics.PermReadout.zolotarev_parity` — `a` is a square mod `p` iff
  `p − #cycles` is even.
-/

namespace Physics.PermReadout

open Finset

section Zolotarev

variable {p a : ℕ}

/-- The cycle count for a prime modulus: one fixed point and `(p−1)/ord_p(a)`
cycles of length `ord_p(a)`. -/
theorem cycleCount_prime (hp : p.Prime) (hcop : Nat.Coprime a p) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    cycleCount p a = (p - 1) / orderOf ((a : ZMod p)) + 1 := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  have hone : orderOf ((a : ZMod 1)) = 1 := orderOf_eq_one_iff.mpr (Subsingleton.elim _ _)
  rw [cycleCount_eq_sum hcop, hp.divisors,
    Finset.sum_insert (by simp [hp.ne_one.symm]), Finset.sum_singleton,
    Nat.div_one, Nat.div_self hp.pos, Nat.totient_prime hp, Nat.totient_one, hone,
    Nat.div_one]

/-- An elementary parity lemma: `L ∣ (L·m)/2` exactly when `m` is even. -/
theorem dvd_half_mul_iff_even {L m : ℕ} (hL0 : 0 < L) (hev : (L * m) % 2 = 0) :
    L ∣ (L * m) / 2 ↔ m % 2 = 0 := by
  rcases Nat.even_or_odd m with hm | hm
  · obtain ⟨t, ht⟩ := hm
    have hmt : m = 2 * t := by omega
    subst hmt
    rw [show L * (2 * t) = 2 * (L * t) from by ring,
      Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    exact ⟨fun _ => by omega, fun _ => ⟨t, rfl⟩⟩
  · obtain ⟨t, ht⟩ := hm
    have hmodd : m % 2 = 1 := by omega
    have hLeven : Even L := by
      rcases (Nat.even_mul).mp (Nat.even_iff.mpr hev) with h | h
      · exact h
      · exact absurd (Nat.even_iff.mp h) (by omega)
    obtain ⟨s, hs⟩ := hLeven
    have hs2 : L = 2 * s := by omega
    have hs0 : 0 < s := by omega
    rw [show L * m = 2 * (s * m) from by rw [hs2]; ring,
      Nat.mul_div_cancel_left _ (by norm_num : 0 < 2), hs2]
    constructor
    · intro hdvd
      exfalso
      have h2 : (2 : ℕ) ∣ m := (Nat.mul_dvd_mul_iff_left hs0).mp
        (by rw [show s * 2 = 2 * s from by ring]; exact hdvd)
      omega
    · intro h
      omega

/-- **Euler's criterion in index form.**  `a` is a quadratic residue modulo the
odd prime `p` exactly when the index `(p−1)/ord_p(a)` is even. -/
theorem isSquare_iff_even_index (hp : p.Prime) (hodd : p ≠ 2) (hcop : Nat.Coprime a p) :
    IsSquare ((a : ZMod p)) ↔ (p - 1) / orderOf ((a : ZMod p)) % 2 = 0 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  have hp2 : 2 ≤ p := hp.two_le
  have hpodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h
    · exact absurd h hodd
    · exact h
  have hane : ((a : ZMod p)) ≠ 0 := by
    intro h
    have hdvd : p ∣ a := (ZMod.natCast_eq_zero_iff a p).mp h
    have : p = 1 := Nat.Coprime.eq_one_of_dvd hcop.symm hdvd
    omega
  set L := orderOf ((a : ZMod p)) with hL
  have hL0 : 0 < L := by
    obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a p).mpr hcop
    rw [hL, ← hu, orderOf_units]
    exact (isOfFinOrder_of_finite u).orderOf_pos
  have hLdvd : L ∣ p - 1 := by
    rw [hL, orderOf_dvd_iff_pow_eq_one]
    exact ZMod.pow_card_sub_one_eq_one hane
  obtain ⟨m, hm⟩ := hLdvd
  have hev : (L * m) % 2 = 0 := by omega
  have hhalf : p / 2 = (p - 1) / 2 := by omega
  rw [ZMod.euler_criterion p hane, ← orderOf_dvd_iff_pow_eq_one, ← hL, hhalf, hm,
    Nat.mul_div_cancel_left _ hL0]
  exact dvd_half_mul_iff_even hL0 hev

/-- **Zolotarev parity.**  For an odd prime modulus, `a` is a quadratic residue
if and only if `p − #cycles` is even — i.e. iff the permutation `x ↦ a·x` of
`ZMod p` is even.  The coarsest bit of the cycle readout is the Legendre
symbol, a quantity computable in polynomial time. -/
theorem zolotarev_parity (hp : p.Prime) (hodd : p ≠ 2) (hcop : Nat.Coprime a p) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    (IsSquare ((a : ZMod p)) ↔ (p - cycleCount p a) % 2 = 0) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  have hpodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h
    · exact absurd h hodd
    · exact h
  have hc := cycleCount_prime hp hcop
  have hle : (p - 1) / orderOf ((a : ZMod p)) ≤ p - 1 := Nat.div_le_self _ _
  rw [isSquare_iff_even_index hp hodd hcop, hc]
  omega

end Zolotarev

end Physics.PermReadout