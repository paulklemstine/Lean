import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry

/-!
# Parity localization: only prime-power strata can carry a sign

The semiprime analysis showed that the unit stratum of `ZMod (p·q)` contributes
an *even* number of cycles, so that the whole permutation sign is carried by the
two prime strata.  That was not an accident of semiprimes.  This file proves the
general statement:

> if the modulus `m·n` splits into two coprime factors, both larger than `2`,
> then the number of unit cycles `φ(mn)/ord_{mn}(a)` is even, and multiplication
> by any unit is an **even permutation** of the unit group.

The mechanism is the index identity

`φ(mn)/ord_{mn}(a) = (φ(m)/ord_m a) · (φ(n)/ord_n a) · gcd(ord_m a, ord_n a)`,

together with the observation that if both indices are odd then both local
orders must be even (because `φ(m)` and `φ(n)` are), so their gcd is even.

For the PERMORD programme this localizes the sign information exactly:  the only
strata of `ZMod N` that can contribute to the permutation sign are those whose
label `N/d` is a prime power (or `1`, `2`, `4`).  Everything else is parity-dead,
so the sign — the cheapest global readout — sees only the prime-power skeleton
of `N`, which is precisely what the Jacobi symbol already encodes.

## Main results

* `Physics.PermReadout.orderOf_dvd_totient` — `ord_N(a) ∣ φ(N)` for `a` coprime
  to `N`.
* `Physics.PermReadout.totient_div_orderOf_mul` — the index identity for an
  arbitrary coprime splitting.
* `Physics.PermReadout.even_totient_div_orderOf_mul` — the unit-cycle count of a
  two-factor modulus is even.
* `Physics.PermReadout.unit_stratum_even_permutation` — multiplication by a unit
  is an even permutation of the unit stratum whenever `N` has two coprime
  factors `> 2`.
-/

namespace Physics.PermReadout

section Localization

variable {m n a : ℕ}

/-- The multiplicative order of a residue coprime to `N` divides `φ(N)`. -/
theorem orderOf_dvd_totient [NeZero n] (hcop : Nat.Coprime a n) :
    orderOf ((a : ZMod n)) ∣ Nat.totient n := by
  obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a n).mpr hcop
  have hcard : Fintype.card (ZMod n)ˣ = Nat.totient n := ZMod.card_units_eq_totient n
  calc orderOf ((a : ZMod n)) = orderOf u := by rw [← hu, orderOf_units]
    _ ∣ Fintype.card (ZMod n)ˣ := orderOf_dvd_card
    _ = Nat.totient n := hcard

/-- The multiplicative order of a residue coprime to the modulus is positive. -/
theorem orderOf_pos_of_coprime (hcop : Nat.Coprime a n) :
    0 < orderOf ((a : ZMod n)) := by
  obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a n).mpr hcop
  rw [← hu, orderOf_units]
  exact (isOfFinOrder_of_finite u).orderOf_pos

/-- **The index identity for an arbitrary coprime splitting.**  The number of
unit cycles of the product modulus is the product of the two local index numbers
times the gcd of the two local orders. -/
theorem totient_div_orderOf_mul [NeZero m] [NeZero n] (hmn : Nat.Coprime m n)
    (hcop : Nat.Coprime a (m * n)) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    Nat.totient (m * n) / orderOf ((a : ZMod (m * n)))
      = (Nat.totient m / orderOf ((a : ZMod m))) * (Nat.totient n / orderOf ((a : ZMod n)))
          * Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n))) := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  have hcm : Nat.Coprime a m := Nat.Coprime.coprime_dvd_right ⟨n, rfl⟩ hcop
  have hcn : Nat.Coprime a n := Nat.Coprime.coprime_dvd_right ⟨m, mul_comm m n⟩ hcop
  set Lm := orderOf ((a : ZMod m)) with hLm
  set Ln := orderOf ((a : ZMod n)) with hLn
  have hLm0 : 0 < Lm := orderOf_pos_of_coprime hcm
  have hLn0 : 0 < Ln := orderOf_pos_of_coprime hcn
  obtain ⟨im, him⟩ := orderOf_dvd_totient hcm
  obtain ⟨inn, hin⟩ := orderOf_dvd_totient hcn
  have hlcm0 : 0 < Nat.lcm Lm Ln := Nat.pos_of_ne_zero (by
    intro h
    rcases Nat.lcm_eq_zero_iff.mp h with h | h <;> omega)
  have hkey : Nat.totient (m * n) = Nat.lcm Lm Ln * (im * inn * Nat.gcd Lm Ln) := by
    have hgl : Nat.gcd Lm Ln * Nat.lcm Lm Ln = Lm * Ln := Nat.gcd_mul_lcm Lm Ln
    calc Nat.totient (m * n) = Nat.totient m * Nat.totient n := Nat.totient_mul hmn
      _ = (Lm * im) * (Ln * inn) := by rw [him, hin]
      _ = (Nat.gcd Lm Ln * Nat.lcm Lm Ln) * (im * inn) := by rw [hgl]; ring
      _ = Nat.lcm Lm Ln * (im * inn * Nat.gcd Lm Ln) := by ring
  have hime : Nat.totient m / Lm = im := by rw [him, Nat.mul_div_cancel_left _ hLm0]
  have hine : Nat.totient n / Ln = inn := by rw [hin, Nat.mul_div_cancel_left _ hLn0]
  rw [orderOf_eq_lcm hmn a, ← hLm, ← hLn, hkey, Nat.mul_div_cancel_left _ hlcm0, hime, hine]

/-- **Parity localization.**  If the modulus splits into two coprime factors,
both bigger than `2`, then the number of unit cycles is even. -/
theorem even_totient_div_orderOf_mul [NeZero m] [NeZero n] (hmn : Nat.Coprime m n)
    (hm : 2 < m) (hn : 2 < n) (hcop : Nat.Coprime a (m * n)) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    Nat.totient (m * n) / orderOf ((a : ZMod (m * n))) % 2 = 0 := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  have hcm : Nat.Coprime a m := Nat.Coprime.coprime_dvd_right ⟨n, rfl⟩ hcop
  have hcn : Nat.Coprime a n := Nat.Coprime.coprime_dvd_right ⟨m, mul_comm m n⟩ hcop
  have hLm0 : 0 < orderOf ((a : ZMod m)) := orderOf_pos_of_coprime hcm
  have hLn0 : 0 < orderOf ((a : ZMod n)) := orderOf_pos_of_coprime hcn
  obtain ⟨im, him⟩ := orderOf_dvd_totient hcm
  obtain ⟨inn, hin⟩ := orderOf_dvd_totient hcn
  have hime : Nat.totient m / orderOf ((a : ZMod m)) = im := by
    rw [him, Nat.mul_div_cancel_left _ hLm0]
  have hine : Nat.totient n / orderOf ((a : ZMod n)) = inn := by
    rw [hin, Nat.mul_div_cancel_left _ hLn0]
  have htm : Nat.totient m % 2 = 0 := Nat.even_iff.mp (Nat.totient_even hm)
  have htn : Nat.totient n % 2 = 0 := Nat.even_iff.mp (Nat.totient_even hn)
  rw [totient_div_orderOf_mul hmn hcop, hime, hine]
  rcases Nat.even_or_odd im with hei | hoi
  · obtain ⟨t, ht⟩ := hei
    have : im * inn * Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n)))
        = 2 * (t * inn * Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n)))) := by
      rw [ht]; ring
    omega
  rcases Nat.even_or_odd inn with hej | hoj
  · obtain ⟨t, ht⟩ := hej
    have : im * inn * Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n)))
        = 2 * (im * t * Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n)))) := by
      rw [ht]; ring
    omega
  · -- both indices odd forces both orders even
    have hLmev : orderOf ((a : ZMod m)) % 2 = 0 := by
      rcases Nat.even_or_odd (orderOf ((a : ZMod m))) with h | h
      · exact Nat.even_iff.mp h
      · exfalso
        obtain ⟨s, hs⟩ := h
        obtain ⟨t, ht⟩ := hoi
        rw [hs, ht] at him
        have : (2 * s + 1) * (2 * t + 1) = 2 * (2 * s * t + s + t) + 1 := by ring
        omega
    have hLnev : orderOf ((a : ZMod n)) % 2 = 0 := by
      rcases Nat.even_or_odd (orderOf ((a : ZMod n))) with h | h
      · exact Nat.even_iff.mp h
      · exfalso
        obtain ⟨s, hs⟩ := h
        obtain ⟨t, ht⟩ := hoj
        rw [hs, ht] at hin
        have : (2 * s + 1) * (2 * t + 1) = 2 * (2 * s * t + s + t) + 1 := by ring
        omega
    obtain ⟨g, hgg⟩ : (2 : ℕ) ∣ Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n))) :=
      Nat.dvd_gcd (by omega) (by omega)
    have : im * inn * Nat.gcd (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n)))
        = 2 * (im * inn * g) := by rw [hgg]; ring
    omega

/-- **Multiplication is an even permutation of the unit group** as soon as the
modulus has two coprime factors `> 2`.  Indeed `φ(mn)` is even and the number of
unit cycles is even, so the number of transpositions `φ(mn) − #unit cycles` is
even.  Only prime-power moduli can produce an odd unit permutation — which is
exactly the domain of the Legendre/Jacobi symbol. -/
theorem unit_stratum_even_permutation [NeZero m] [NeZero n] (hmn : Nat.Coprime m n)
    (hm : 2 < m) (hn : 2 < n) (hcop : Nat.Coprime a (m * n)) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    (Nat.totient (m * n) - Nat.totient (m * n) / orderOf ((a : ZMod (m * n)))) % 2 = 0 := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  have hcycles := even_totient_div_orderOf_mul hmn hm hn hcop
  have hle : Nat.totient (m * n) / orderOf ((a : ZMod (m * n))) ≤ Nat.totient (m * n) :=
    Nat.div_le_self _ _
  have htot : Nat.totient (m * n) % 2 = 0 :=
    Nat.even_iff.mp (Nat.totient_even (by nlinarith))
  omega

end Localization

end Physics.PermReadout