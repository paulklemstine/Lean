/-
# The parity gap detects primality exactly

Conjecture A (`ParityGap.exists_permCoeff_ne_zero`) says that for a *prime* modulus the
parity-weighted exponent counter of an injective pair `S, T` never vanishes identically.  This
file proves the exact converse: for every composite modulus the gap **does** close, already for
`n = 2`.  Writing `m = a · b` with `1 < a, b < m` and taking `S = ![0, a]`, `T = ![0, b]`, every
product `S i · T j` vanishes in `ZMod m`, so all permutations share the exponent `0` and the
signed count cancels.

More generally, for any factorisation `m = a · b` the two ideals `(a)` and `(b)` annihilate each
other, so the arithmetic progressions `S i = a · i` and `T j = b · j` close the gap for every
`n ≤ min (a, b)` (`ParityGap.parity_gap_closes_of_factorisation`).

Combining the two directions gives a characterisation of primality purely in terms of the
combinatorics of signed permutation exponents:

  `ZMod m` has a closing parity gap  ⟺  `m` is composite.

Main results: `ParityGap.parity_gap_closes_of_factorisation`,
`ParityGap.parity_gap_closes_of_not_prime`, `ParityGap.parity_gap_closes_iff_not_prime`.
-/

import Mathlib
import Probability.GapQuantitative

open Finset PrimeUncertainty

namespace ParityGap

/-- If every product `S i · T j` vanishes then all permutation exponents are `0`. -/
theorem permExp_eq_zero_of_products_zero {m n : ℕ} (S T : Fin n → ZMod m)
    (h : ∀ i j, S i * T j = 0) (σ : Equiv.Perm (Fin n)) : permExp S T σ = 0 := by
  simp [permExp, h]

/-- **Annihilating progressions close the gap.**  If `m = a · b` then the multiples of `a` and
the multiples of `b` annihilate each other in `ZMod m`, so for every `n` with `2 ≤ n ≤ a` and
`n ≤ b` the injective families `S i = a · i`, `T j = b · j` have identically vanishing
parity-weighted exponent counter. -/
theorem parity_gap_closes_of_factorisation {m a b n : ℕ} (hm : m = a * b) (hn : 2 ≤ n)
    (hna : n ≤ a) (hnb : n ≤ b) :
    ∃ S T : Fin n → ZMod m, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod m, permCoeff S T r = 0 := by
  classical
  have ha : 0 < a := by omega
  have hb : 0 < b := by omega
  refine ⟨fun i => ((a * (i : ℕ) : ℕ) : ZMod m), fun j => ((b * (j : ℕ) : ℕ) : ZMod m),
    ?_, ?_, ?_⟩
  · intro i j hij
    have hlt : ∀ k : Fin n, a * (k : ℕ) < m := by
      intro k
      have : (k : ℕ) < b := lt_of_lt_of_le k.isLt hnb
      calc a * (k : ℕ) < a * b := Nat.mul_lt_mul_of_pos_left this ha
        _ = m := hm.symm
    have := (ZMod.natCast_eq_natCast_iff' _ _ _).mp hij
    rw [Nat.mod_eq_of_lt (hlt i), Nat.mod_eq_of_lt (hlt j)] at this
    exact Fin.ext (Nat.eq_of_mul_eq_mul_left ha this)
  · intro i j hij
    have hlt : ∀ k : Fin n, b * (k : ℕ) < m := by
      intro k
      have : (k : ℕ) < a := lt_of_lt_of_le k.isLt hna
      calc b * (k : ℕ) < b * a := Nat.mul_lt_mul_of_pos_left this hb
        _ = m := by rw [hm]; ring
    have := (ZMod.natCast_eq_natCast_iff' _ _ _).mp hij
    rw [Nat.mod_eq_of_lt (hlt i), Nat.mod_eq_of_lt (hlt j)] at this
    exact Fin.ext (Nat.eq_of_mul_eq_mul_left hb this)
  · intro r
    have hprod : ∀ i j : Fin n,
        ((a * (i : ℕ) : ℕ) : ZMod m) * ((b * (j : ℕ) : ℕ) : ZMod m) = 0 := by
      intro i j
      have : (a * (i : ℕ)) * (b * (j : ℕ)) = m * ((i : ℕ) * (j : ℕ)) := by rw [hm]; ring
      rw [← Nat.cast_mul, this, Nat.cast_mul, ZMod.natCast_self, zero_mul]
    exact permCoeff_eq_zero_of_permExp_const hn _ _ 0
      (permExp_eq_zero_of_products_zero _ _ hprod) r

/-- For a composite modulus the parity gap closes: there are injective `S, T : Fin 2 → ZMod m`
whose parity-weighted exponent counter vanishes at every residue. -/
theorem parity_gap_closes_of_not_prime {m : ℕ} (hm : 2 ≤ m) (hnp : ¬ m.Prime) :
    ∃ S T : Fin 2 → ZMod m, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod m, permCoeff S T r = 0 := by
  obtain ⟨a, hadvd, ha1, ham⟩ := Nat.exists_dvd_of_not_prime2 hm hnp
  obtain ⟨b, hb⟩ := hadvd
  have hb1 : 1 < b := by
    rcases Nat.lt_or_ge b 2 with h | h
    · interval_cases b <;> omega
    · omega
  exact parity_gap_closes_of_factorisation hb le_rfl ha1 hb1

/-- **Primality is exactly the non-closing of the parity gap.**  For a modulus `m ≥ 2` there
exist injective `S, T : Fin 2 → ZMod m` with identically vanishing parity-weighted exponent
counter if and only if `m` is composite. -/
theorem parity_gap_closes_iff_not_prime {m : ℕ} (hm : 2 ≤ m) :
    (∃ S T : Fin 2 → ZMod m, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod m, permCoeff S T r = 0) ↔ ¬ m.Prime := by
  refine ⟨fun ⟨S, T, hS, hT, hzero⟩ hprime => ?_, parity_gap_closes_of_not_prime hm⟩
  haveI : Fact m.Prime := ⟨hprime⟩
  obtain ⟨r, hr⟩ := exists_permCoeff_ne_zero S T hS hT
  exact hr (hzero r)

end ParityGap