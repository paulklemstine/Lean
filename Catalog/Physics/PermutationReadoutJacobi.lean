import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry
import Physics.PermutationReadoutParityLocalization
import Physics.PermutationReadoutZolotarev

/-!
# The composite parity bit of the readout is the Jacobi symbol

The previous file showed that for a prime modulus the parity of the number of
cycles of `x ↦ a·x` is the Legendre symbol (Zolotarev's lemma).  Here we push
this to the semiprime case `N = p·q`, which is the case of cryptographic
interest, and obtain the sharpest possible negative result for the PERMORD
programme:

> the sign of the permutation `x ↦ a·x` of `ZMod (p·q)` — i.e. the single bit
> `(N − #cycles) mod 2` distilled from the whole cycle spectrum — equals the
> Jacobi symbol `J(a | N)`, which is computable in polynomial time *without*
> knowing the factorisation.

So although the cycle spectrum as a whole is a strictly richer object than
`ord_N(a)` (it separates `ord_p(a)` from `ord_q(a)`, cf.
`Physics.PermReadout.cycle_lengths_eq_iff_local_orders_eq`), its cheapest global
summary leaks nothing at all: it is a function the adversary can already
evaluate.  The asymmetry lives strictly inside the `O(N)` enumeration.

The arithmetic heart of the proof is `even_totient_div_orderOf_semiprime`: the
unit stratum always contributes an *even* number of transpositions, because
`φ(N)/ord_N(a) = i_p · i_q · gcd(ord_p a, ord_q a)` and this product is even
whenever `p` and `q` are odd.  The two prime strata therefore carry the whole
parity, and each carries its own Legendre symbol.

## Main results

* `Physics.PermReadout.totient_div_orderOf_semiprime` — the exact identity
  `φ(pq)/ord_N(a) = gcd(ord_p a, ord_q a) · i_p · i_q`.
* `Physics.PermReadout.even_totient_div_orderOf_semiprime` — that number is even.
* `Physics.PermReadout.parity_cycleCount_semiprime` — `N − #cycles ≡ i_p + i_q`.
* `Physics.PermReadout.jacobi_readout_parity` — `J(a|N) = 1 ↔ N − #cycles` even.
* `Physics.PermReadout.parity_bit_is_free` — packaged verdict: the parity bit of
  the readout agrees with the Jacobi symbol, a factorisation-free quantity.
-/

namespace Physics.PermReadout

open Finset

section Jacobi

variable {p q a : ℕ}

/-- The multiplicative order of `a` modulo a prime `p` divides `p − 1`. -/
theorem orderOf_dvd_prime_sub_one (hp : p.Prime) (hcop : Nat.Coprime a p) :
    orderOf ((a : ZMod p)) ∣ p - 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hane : ((a : ZMod p)) ≠ 0 := by
    intro h
    have hdvd : p ∣ a := (ZMod.natCast_eq_zero_iff a p).mp h
    have : p = 1 := Nat.Coprime.eq_one_of_dvd hcop.symm hdvd
    exact hp.ne_one this
  rw [orderOf_dvd_iff_pow_eq_one]
  exact ZMod.pow_card_sub_one_eq_one hane

/-- **The size of the unit stratum's cycle set.**  Writing `i_p = (p−1)/ord_p a`
and `i_q = (q−1)/ord_q a` for the two indices, the number of unit cycles is
`gcd(ord_p a, ord_q a) · i_p · i_q`. -/
theorem totient_div_orderOf_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    Nat.totient (p * q) / orderOf ((a : ZMod (p * q)))
      = Nat.gcd (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q)))
          * ((p - 1) / orderOf ((a : ZMod p))) * ((q - 1) / orderOf ((a : ZMod q))) := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  rw [totient_div_orderOf_mul ((Nat.coprime_primes hp hq).mpr hpq) hcop,
    Nat.totient_prime hp, Nat.totient_prime hq]
  ring

/-- **The unit stratum is parity-neutral.**  For distinct odd primes the number
of unit cycles `φ(N)/ord_N(a)` is even: if both indices are odd then both local
orders are even (since `p−1` and `q−1` are), so their gcd is even. -/
theorem even_totient_div_orderOf_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    Nat.totient (p * q) / orderOf ((a : ZMod (p * q))) % 2 = 0 := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hp3 : 2 < p := lt_of_le_of_ne hp.two_le (fun h => hp2 h.symm)
  have hq3 : 2 < q := lt_of_le_of_ne hq.two_le (fun h => hq2 h.symm)
  exact even_totient_div_orderOf_mul ((Nat.coprime_primes hp hq).mpr hpq) hp3 hq3 hcop

/-- **Parity of the readout.**  `N − #cycles`, the number of transpositions in
the permutation `x ↦ a·x`, has the same parity as `i_p + i_q`, the sum of the
two Legendre indices.  The unit stratum drops out entirely. -/
theorem parity_cycleCount_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    (p * q - cycleCount (p * q) a) % 2
      = ((p - 1) / orderOf ((a : ZMod p)) + (q - 1) / orderOf ((a : ZMod q))) % 2 := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  have hp2' := hp.two_le
  have hq2' := hq.two_le
  have hpodd : p % 2 = 1 := hp.eq_two_or_odd.resolve_left hp2
  have hqodd : q % 2 = 1 := hq.eq_two_or_odd.resolve_left hq2
  have hcount := cycleCount_semiprime hp hq hpq hcop
  have hTev := even_totient_div_orderOf_semiprime hp hq hpq hp2 hq2 hcop
  -- bounds so that the truncated subtraction is honest
  have hTle : Nat.totient (p * q) / orderOf ((a : ZMod (p * q))) ≤ (p - 1) * (q - 1) := by
    have h1 : Nat.totient (p * q) = (p - 1) * (q - 1) := by
      rw [Nat.totient_mul ((Nat.coprime_primes hp hq).mpr hpq), Nat.totient_prime hp,
        Nat.totient_prime hq]
    calc Nat.totient (p * q) / orderOf ((a : ZMod (p * q))) ≤ Nat.totient (p * q) :=
          Nat.div_le_self _ _
      _ = (p - 1) * (q - 1) := h1
  have hipl : (p - 1) / orderOf ((a : ZMod p)) ≤ p - 1 := Nat.div_le_self _ _
  have hiql : (q - 1) / orderOf ((a : ZMod q)) ≤ q - 1 := Nat.div_le_self _ _
  have hexp : (p - 1) * (q - 1) + (p - 1) + (q - 1) + 1 = p * q := by
    obtain ⟨P, rfl⟩ : ∃ P, p = P + 1 := ⟨p - 1, by omega⟩
    obtain ⟨Q, rfl⟩ : ∃ Q, q = Q + 1 := ⟨q - 1, by omega⟩
    simp only [Nat.add_sub_cancel]
    ring
  have hpqodd : (p * q) % 2 = 1 := by
    obtain ⟨P, hP⟩ : ∃ P, p = 2 * P + 1 := ⟨p / 2, by omega⟩
    obtain ⟨Q, hQ⟩ : ∃ Q, q = 2 * Q + 1 := ⟨q / 2, by omega⟩
    have : p * q = 2 * (2 * P * Q + P + Q) + 1 := by rw [hP, hQ]; ring
    omega
  omega

/-- `J(a|N) = 1` exactly when `a` has the same quadratic character modulo both
prime factors.  This is the multiplicativity of the Jacobi symbol in its lower
argument, combined with Euler's criterion at each prime. -/
theorem jacobiSym_eq_one_iff_same_character (hp : p.Prime) (hq : q.Prime)
    (hcop : Nat.Coprime a (p * q)) :
    jacobiSym (a : ℤ) (p * q) = 1 ↔ (IsSquare ((a : ZMod p)) ↔ IsSquare ((a : ZMod q))) := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hcp : Nat.Coprime a p := Nat.Coprime.coprime_dvd_right ⟨q, rfl⟩ hcop
  have hcq : Nat.Coprime a q := Nat.Coprime.coprime_dvd_right ⟨p, mul_comm p q⟩ hcop
  have hcastp : ((a : ℤ) : ZMod p) = ((a : ℕ) : ZMod p) := by push_cast; ring
  have hcastq : ((a : ℤ) : ZMod q) = ((a : ℕ) : ZMod q) := by push_cast; ring
  have hpne : ((a : ℤ) : ZMod p) ≠ 0 := by
    rw [hcastp]
    intro h
    exact hp.ne_one (Nat.Coprime.eq_one_of_dvd hcp.symm ((ZMod.natCast_eq_zero_iff a p).mp h))
  have hqne : ((a : ℤ) : ZMod q) ≠ 0 := by
    rw [hcastq]
    intro h
    exact hq.ne_one (Nat.Coprime.eq_one_of_dvd hcq.symm ((ZMod.natCast_eq_zero_iff a q).mp h))
  have hsplit : jacobiSym (a : ℤ) (p * q)
      = legendreSym p (a : ℤ) * legendreSym q (a : ℤ) := by
    rw [jacobiSym.mul_right, jacobiSym.legendreSym.to_jacobiSym,
      jacobiSym.legendreSym.to_jacobiSym]
  have hpsq : legendreSym p (a : ℤ) = 1 ↔ IsSquare ((a : ℕ) : ZMod p) := by
    rw [legendreSym.eq_one_iff p hpne, hcastp]
  have hqsq : legendreSym q (a : ℤ) = 1 ↔ IsSquare ((a : ℕ) : ZMod q) := by
    rw [legendreSym.eq_one_iff q hqne, hcastq]
  have hpv := legendreSym.eq_one_or_neg_one (p := p) hpne
  have hqv := legendreSym.eq_one_or_neg_one (p := q) hqne
  rw [hsplit]
  by_cases hsp : IsSquare ((a : ℕ) : ZMod p) <;> by_cases hsq : IsSquare ((a : ℕ) : ZMod q)
  · rw [hpsq.mpr hsp, hqsq.mpr hsq]
    simp [hsp, hsq]
  · have h2 : legendreSym q (a : ℤ) = -1 := hqv.resolve_left (fun h => hsq (hqsq.mp h))
    rw [hpsq.mpr hsp, h2]
    simp [hsp, hsq]
  · have h1 : legendreSym p (a : ℤ) = -1 := hpv.resolve_left (fun h => hsp (hpsq.mp h))
    rw [hqsq.mpr hsq, h1]
    simp [hsp, hsq]
  · have h1 : legendreSym p (a : ℤ) = -1 := hpv.resolve_left (fun h => hsp (hpsq.mp h))
    have h2 : legendreSym q (a : ℤ) = -1 := hqv.resolve_left (fun h => hsq (hqsq.mp h))
    rw [h1, h2]
    simp [hsp, hsq]

/-- **The parity bit of the cycle readout is the Jacobi symbol.**  For a
semiprime modulus with distinct odd prime factors and `a` coprime to `N`, the
permutation `x ↦ a·x` of `ZMod N` is an even permutation exactly when
`J(a | N) = 1`.  Since the Jacobi symbol is computable in polynomial time from
`a` and `N` alone, the coarsest global summary of the asymmetric cycle spectrum
carries no information about the factorisation. -/
theorem jacobi_readout_parity (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    (jacobiSym (a : ℤ) (p * q) = 1 ↔ (p * q - cycleCount (p * q) a) % 2 = 0) := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  have hcp : Nat.Coprime a p := Nat.Coprime.coprime_dvd_right ⟨q, rfl⟩ hcop
  have hcq : Nat.Coprime a q := Nat.Coprime.coprime_dvd_right ⟨p, mul_comm p q⟩ hcop
  rw [jacobiSym_eq_one_iff_same_character hp hq hcop,
    parity_cycleCount_semiprime hp hq hpq hp2 hq2 hcop,
    isSquare_iff_even_index hp hp2 hcp, isSquare_iff_even_index hq hq2 hcq]
  omega

/-- **Packaged verdict.**  The single-bit summary of the cycle readout is a
factorisation-free quantity: it is determined by the Jacobi symbol, which any
adversary can evaluate without knowing `p` and `q`.  Consequently two moduli /
bases with the same Jacobi symbol are indistinguishable at the level of the
permutation sign, no matter how asymmetric their full cycle spectra are. -/
theorem parity_bit_is_free {p' q' b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hcop : Nat.Coprime a (p * q))
    (hp' : p'.Prime) (hq' : q'.Prime) (hpq' : p' ≠ q')
    (hp2' : p' ≠ 2) (hq2' : q' ≠ 2) (hcop' : Nat.Coprime b (p' * q'))
    (hj : jacobiSym (a : ℤ) (p * q) = jacobiSym (b : ℤ) (p' * q')) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    haveI : NeZero (p' * q') := ⟨(Nat.mul_pos hp'.pos hq'.pos).ne'⟩
    ((p * q - cycleCount (p * q) a) % 2 = 0 ↔
      (p' * q' - cycleCount (p' * q') b) % 2 = 0) := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  haveI : NeZero (p' * q') := ⟨(Nat.mul_pos hp'.pos hq'.pos).ne'⟩
  rw [← jacobi_readout_parity hp hq hpq hp2 hq2 hcop,
    ← jacobi_readout_parity hp' hq' hpq' hp2' hq2' hcop', hj]

end Jacobi

end Physics.PermReadout