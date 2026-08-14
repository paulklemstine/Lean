import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry
import Physics.PermutationReadoutParityLocalization
import Physics.PermutationReadoutZolotarev
import Physics.PermutationReadoutPrimePower
import Physics.PermutationReadoutZolotarevGeneral

/-!
# The sign of the readout at an even modulus, and the complete sign law

`zolotarev_general` settles the sign of the multiplication permutation
`x ↦ a·x` of `ZMod N` for every **odd** `N`: it is the Jacobi symbol `J(a|N)`.
This file finishes the classification by computing the sign for every **even**
modulus, and packages the two halves into one law valid for all `N`.

The answer is that an even modulus is almost completely parity-dead:

* if `N ≡ 2 (mod 4)` the permutation is **always even**;
* if `4 ∣ N` the permutation is odd exactly when `a ≡ 3 (mod 4)` — i.e. the sign
  is the quadratic character `χ₋₄(a)`, *independently of the odd part of `N`*.

The mechanism: writing `N = 2^s·m` with `m` odd, the strata whose label is
`2^t·j` with `t ≥ 2` and `j > 2` are parity-dead by
`even_totient_div_orderOf_mul`; the labels `j` and `2·j` have equal index
(`idx_two_mul`) and therefore cancel in pairs; and the pure 2-power labels have
even index for `2^t`, `t ≥ 3`, because the group `(ZMod 2^t)ˣ` has exponent
`2^{t−2}`.  What survives is the single stratum with label `4`.

## Main results

* `Physics.PermReadout.orderOf_two_pow_dvd` — exponent bound
  `ord_{2^t}(a) ∣ 2^{t−2}` for odd `a` and `t ≥ 3`.
* `Physics.PermReadout.idx_two_mul` — the doubling law `i_{2j} = i_j`.
* `Physics.PermReadout.idx_two_pow_even` — the pure 2-power strata above `4` are
  parity-dead.
* `Physics.PermReadout.idx_four_parity` — the stratum `4` carries `χ₋₄(a)`.
* `Physics.PermReadout.parity_readout_even` — the sign at an even modulus.
* `Physics.PermReadout.permutation_sign_law` — **the complete law**, for every
  modulus `N ≥ 1` and every `a` coprime to `N`.
-/

namespace Physics.PermReadout

open Finset

section EvenModulus

/-- Lifting the exponent at `2`: for odd `a` the number `a^{2^{n+1}} − 1` is
divisible by `2^{n+3}`. -/
theorem two_pow_dvd_odd_pow_sub_one {a : ℕ} (ha : Odd a) :
    ∀ n : ℕ, (2 : ℤ) ^ (n + 3) ∣ (a : ℤ) ^ (2 ^ (n + 1)) - 1 := by
  intro n
  induction n with
  | zero =>
    obtain ⟨k, hk⟩ := ha
    have hcast : (a : ℤ) = 2 * (k : ℤ) + 1 := by
      rw [hk]; push_cast; ring
    have hfact : (a : ℤ) ^ (2 ^ (0 + 1)) - 1 = 4 * ((k : ℤ) * ((k : ℤ) + 1)) := by
      rw [hcast]; ring
    rw [hfact]
    have hkk : (2 : ℤ) ∣ (k : ℤ) * ((k : ℤ) + 1) := by
      rcases Nat.even_or_odd k with hev | hod
      · obtain ⟨t, ht⟩ := hev
        have hkt : (k : ℤ) = 2 * (t : ℤ) := by rw [ht]; push_cast; ring
        exact ⟨(t : ℤ) * ((k : ℤ) + 1), by rw [hkt]; ring⟩
      · obtain ⟨t, ht⟩ := hod
        have hkt : (k : ℤ) = 2 * (t : ℤ) + 1 := by rw [ht]; push_cast; ring
        exact ⟨(k : ℤ) * ((t : ℤ) + 1), by rw [hkt]; ring⟩
    obtain ⟨u, hu⟩ := hkk
    exact ⟨u, by rw [hu]; norm_num; ring⟩
  | succ n ih =>
    have hsplit : (a : ℤ) ^ (2 ^ (n + 2)) - 1
        = ((a : ℤ) ^ (2 ^ (n + 1)) - 1) * ((a : ℤ) ^ (2 ^ (n + 1)) + 1) := by
      have hpow : (2 : ℕ) ^ (n + 2) = 2 ^ (n + 1) * 2 := by ring
      rw [hpow, pow_mul]
      ring
    have heven : (2 : ℤ) ∣ (a : ℤ) ^ (2 ^ (n + 1)) + 1 := by
      obtain ⟨k, hk⟩ := ha.pow (n := 2 ^ (n + 1))
      refine ⟨(k : ℤ) + 1, ?_⟩
      have hcast : ((a ^ (2 ^ (n + 1)) : ℕ) : ℤ) = 2 * (k : ℤ) + 1 := by
        rw [hk]; push_cast; ring
      push_cast at hcast
      rw [hcast]; ring
    obtain ⟨u, hu⟩ := ih
    obtain ⟨v, hv⟩ := heven
    refine ⟨u * v, ?_⟩
    rw [hsplit, hu, hv]
    ring

/-- **The exponent of `(ZMod 2^t)ˣ`.**  For odd `a` and `t ≥ 3` the order of `a`
modulo `2^t` divides `2^{t−2}`: the 2-adic unit group is not cyclic, and this is
what makes every high 2-power stratum parity-dead. -/
theorem orderOf_two_pow_dvd {a t : ℕ} (ha : Odd a) (ht : 3 ≤ t) :
    orderOf ((a : ZMod (2 ^ t))) ∣ 2 ^ (t - 2) := by
  obtain ⟨n, rfl⟩ : ∃ n, t = n + 3 := ⟨t - 3, by omega⟩
  have hdvd := two_pow_dvd_odd_pow_sub_one ha n
  rw [orderOf_dvd_iff_pow_eq_one, show n + 3 - 2 = n + 1 by omega]
  have hzero : (((a : ℤ) ^ (2 ^ (n + 1)) - 1 : ℤ) : ZMod (2 ^ (n + 3))) = 0 := by
    refine (ZMod.intCast_zmod_eq_zero_iff_dvd _ (2 ^ (n + 3))).mpr ?_
    simpa using hdvd
  push_cast at hzero
  linear_combination (norm := (push_cast; ring_nf)) hzero

/-- The order of an odd residue modulo `2` is trivial. -/
theorem orderOf_two_eq_one {a : ℕ} (ha : Odd a) : orderOf ((a : ZMod 2)) = 1 := by
  refine orderOf_eq_one_iff.mpr ?_
  have hm : a % 2 = 1 := Nat.odd_iff.mp ha
  calc ((a : ℕ) : ZMod 2) = ((a % 2 : ℕ) : ZMod 2) := (ZMod.natCast_mod a 2).symm
    _ = 1 := by rw [hm]; norm_num

@[simp] theorem idx_two {a : ℕ} (ha : Odd a) : idx 2 a = 1 := by
  simp [idx, orderOf_two_eq_one ha]

/-- **The doubling law.**  Attaching a factor `2` to an odd label does not change
the index: the strata `j` and `2·j` always carry the same number of cycles. -/
theorem idx_two_mul {a j : ℕ} (ha : Odd a) (hjodd : Odd j) (hj : j ≠ 0)
    (hcop : Nat.Coprime a j) : idx (2 * j) a = idx j a := by
  haveI : NeZero (2 : ℕ) := ⟨two_ne_zero⟩
  haveI : NeZero j := ⟨hj⟩
  have ha2 : Nat.Coprime a 2 := by
    exact Nat.coprime_two_right.mpr ha
  have hcop2j : Nat.Coprime a (2 * j) := Nat.Coprime.mul_right ha2 hcop
  have h2j : Nat.Coprime 2 j := by
    exact Nat.coprime_two_left.mpr hjodd
  have hkey := totient_div_orderOf_mul (m := 2) (n := j) (a := a) h2j hcop2j
  have h2tot : Nat.totient 2 / orderOf ((a : ZMod 2)) = 1 := by
    simp [orderOf_two_eq_one ha]
  rw [idx, idx, hkey, h2tot, orderOf_two_eq_one ha]
  simp

/-- The pure 2-power strata above `4` are parity-dead. -/
theorem idx_two_pow_even {a t : ℕ} (ha : Odd a) (ht : 3 ≤ t) : idx (2 ^ t) a % 2 = 0 := by
  have hdvd := orderOf_two_pow_dvd ha ht
  obtain ⟨v, hv, hveq⟩ := (Nat.dvd_prime_pow Nat.prime_two).mp hdvd
  have htot : Nat.totient (2 ^ t) = 2 ^ (t - 1) := by
    rw [Nat.totient_prime_pow Nat.prime_two (by omega)]
    simp
  have hidx : idx (2 ^ t) a = 2 ^ (t - 1 - v) := by
    rw [idx, htot, hveq, Nat.pow_div (by omega) (by norm_num)]
  rw [hidx]
  obtain ⟨w, hw⟩ : ∃ w, t - 1 - v = w + 1 := ⟨t - 1 - v - 1, by omega⟩
  rw [hw, pow_succ]
  omega

/-- **The stratum `4` carries the character `χ₋₄`.**  Its index is even exactly
when `a ≡ 1 (mod 4)`. -/
theorem idx_four_parity {a : ℕ} (ha : Odd a) : idx 4 a % 2 = 0 ↔ a % 4 = 1 := by
  have hcast : ((a : ℕ) : ZMod 4) = ((a % 4 : ℕ) : ZMod 4) := (ZMod.natCast_mod a 4).symm
  have hm : a % 2 = 1 := Nat.odd_iff.mp ha
  have h4 : a % 4 = 1 ∨ a % 4 = 3 := by omega
  have htot : Nat.totient 4 = 2 := by decide
  rcases h4 with h | h
  · rw [idx, htot, hcast, h]
    have h1 : ((1 : ℕ) : ZMod 4) = (1 : ZMod 4) := by norm_num
    rw [h1, orderOf_one]
    simp
  · rw [idx, htot, hcast, h]
    have h3 : ((3 : ℕ) : ZMod 4) = (3 : ZMod 4) := by norm_num
    have hord : orderOf ((3 : ZMod 4)) = 2 := by
      haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
      exact orderOf_eq_prime (by decide) (by decide)
    rw [h3, hord]
    simp

/-- Summing a function over the 2-power tower when only the levels `0, 1, 2`
survive: levels `0` and `1` cancel and everything above `2` vanishes. -/
theorem sum_range_tower {F : ℕ → ZMod 2} {c : ZMod 2} (h01 : F 0 + F 1 = 0) (h2 : F 2 = c)
    (hz : ∀ t, 3 ≤ t → F t = 0) : ∀ s, 2 ≤ s → ∑ t ∈ Finset.range (s + 1), F t = c := by
  intro s
  induction s with
  | zero => intro h; omega
  | succ n ih =>
    intro _
    rcases Nat.lt_or_ge n 2 with hn | hn
    · have hn1 : n = 1 := by omega
      subst hn1
      rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one, h2,
        show F 0 + F 1 = 0 from h01, zero_add]
    · rw [Finset.sum_range_succ, ih hn, hz (n + 1) (by omega), add_zero]

/-- **The sign of the readout at an even modulus.**  Writing `N = 2^s·m` with
`m` odd and `s ≥ 1`, the number of transpositions of `x ↦ a·x` on `ZMod N` is
even unless `s ≥ 2` and `a ≡ 3 (mod 4)`.  In particular the odd part of `N` is
completely invisible to the sign. -/
theorem parity_readout_even {N s m a : ℕ} [NeZero N] (hN : N = 2 ^ s * m) (hs : 1 ≤ s)
    (hm : Odd m) (hcop : Nat.Coprime a N) :
    (((N - cycleCount N a : ℕ)) : ZMod 2)
      = if 2 ≤ s then ((idx 4 a : ℕ) : ZMod 2) else 0 := by
  subst hN
  have hm0 : m ≠ 0 := by rintro rfl; simp at hm
  have hcopm : Nat.Coprime a m := hcop.coprime_dvd_right ⟨2 ^ s, by ring⟩
  have ha : Odd a := by
    rcases Nat.even_or_odd a with hev | hod
    · exfalso
      have h2a : (2 : ℕ) ∣ a := hev.two_dvd
      have h2N : (2 : ℕ) ∣ 2 ^ s * m := ⟨2 ^ (s - 1) * m, by
        rw [← mul_assoc, ← pow_succ']
        congr 2
        omega⟩
      have := Nat.Coprime.eq_one_of_dvd (hcop.coprime_dvd_left h2a) h2N
      omega
    · exact hod
  have ha2 : Nat.Coprime a 2 := by exact Nat.coprime_two_right.mpr ha
  have hcop2 : Nat.Coprime (2 ^ s) m := by
    refine Nat.Coprime.pow_left s ?_
    exact Nat.coprime_two_left.mpr hm
  set L := (m.primeFactorsList.map (fun p => ((idx p a : ℕ) : ZMod 2))).sum with hL
  set F : ℕ → ZMod 2 := fun t => ∑ j ∈ m.divisors, ((idx (2 ^ t * j) a : ℕ) : ZMod 2) with hF
  have hFm := sum_idx_divisors (a := a) m hm hcopm
  have hF0 : F 0 = 1 + L := by
    simpa [hF, hL] using hFm
  have hF1 : F 1 = 1 + L := by
    have hcongr : ∀ j ∈ m.divisors,
        ((idx (2 ^ 1 * j) a : ℕ) : ZMod 2) = ((idx j a : ℕ) : ZMod 2) := by
      intro j hj
      have hj0 : j ≠ 0 := (Nat.pos_of_mem_divisors hj).ne'
      have hjdvd : j ∣ m := Nat.dvd_of_mem_divisors hj
      have hcj : Nat.Coprime a j := hcopm.coprime_dvd_right hjdvd
      have hjodd : Odd j := by
        rcases Nat.even_or_odd j with hev | hod
        · exfalso
          have h2m : (2 : ℕ) ∣ m := hev.two_dvd.trans hjdvd
          rw [Nat.odd_iff] at hm
          omega
        · exact hod
      rw [pow_one, idx_two_mul ha hjodd hj0 hcj]
    simp only [hF]
    rw [Finset.sum_congr rfl hcongr]
    simpa [hL] using hFm
  have hFtop : ∀ t, 2 ≤ t → F t = ((idx (2 ^ t) a : ℕ) : ZMod 2) := by
    intro t ht
    have hone : (1 : ℕ) ∈ m.divisors := Nat.one_mem_divisors.mpr hm0
    simp only [hF]
    rw [← Finset.add_sum_erase _ _ hone, mul_one]
    have hrest : ∑ j ∈ m.divisors.erase 1, ((idx (2 ^ t * j) a : ℕ) : ZMod 2) = 0 := by
      refine Finset.sum_eq_zero ?_
      intro j hj
      have hjne : j ≠ 1 := (Finset.mem_erase.mp hj).1
      have hjmem := (Finset.mem_erase.mp hj).2
      have hjdvd : j ∣ m := Nat.dvd_of_mem_divisors hjmem
      have hj0 : j ≠ 0 := (Nat.pos_of_mem_divisors hjmem).ne'
      have hjodd : Odd j := by
        rcases Nat.even_or_odd j with hev | hod
        · exfalso
          have h2m : (2 : ℕ) ∣ m := hev.two_dvd.trans hjdvd
          rw [Nat.odd_iff] at hm
          omega
        · exact hod
      have hj3 : 2 < j := by
        rw [Nat.odd_iff] at hjodd
        omega
      have hcopij : Nat.Coprime (2 ^ t) j :=
        Nat.Coprime.pow_left t (Nat.coprime_two_left.mpr hjodd)
      have hcj : Nat.Coprime a j := hcopm.coprime_dvd_right hjdvd
      have hcopa : Nat.Coprime a (2 ^ t * j) :=
        Nat.Coprime.mul_right (Nat.Coprime.pow_right t ha2) hcj
      have h2t : 2 < 2 ^ t := by
        calc (2 : ℕ) < 2 ^ 2 := by norm_num
          _ ≤ 2 ^ t := Nat.pow_le_pow_right (by norm_num) ht
      haveI : NeZero (2 ^ t) := ⟨by omega⟩
      haveI : NeZero j := ⟨hj0⟩
      have heven : idx (2 ^ t * j) a % 2 = 0 :=
        even_totient_div_orderOf_mul hcopij h2t hj3 hcopa
      exact (natCast_zmod_two_eq_zero_iff _).mpr heven
    rw [hrest, add_zero]
  have hFzero : ∀ t, 3 ≤ t → F t = 0 := by
    intro t ht
    rw [hFtop t (by omega)]
    exact (natCast_zmod_two_eq_zero_iff _).mpr (idx_two_pow_even ha ht)
  have hF4 : F 2 = ((idx 4 a : ℕ) : ZMod 2) := by
    rw [hFtop 2 (by norm_num)]
    norm_num
  -- the total divisor sum, organised along the 2-power tower
  have hsum : ∑ e ∈ (2 ^ s * m).divisors, ((idx e a : ℕ) : ZMod 2)
      = ∑ t ∈ Finset.range (s + 1), F t := by
    rw [sum_divisors_mul_coprime hcop2, Nat.divisors_prime_pow Nat.prime_two, Finset.sum_map]
    rfl
  have h01 : F 0 + F 1 = 0 := by
    rw [hF0, hF1]
    exact CharTwo.add_self_eq_zero _
  have hkey : ∑ t ∈ Finset.range (s + 1), F t = if 2 ≤ s then ((idx 4 a : ℕ) : ZMod 2) else 0 := by
    rcases Nat.lt_or_ge s 2 with hs2 | hs2
    · have hs1 : s = 1 := by omega
      subst hs1
      rw [if_neg (by omega), Finset.sum_range_succ, Finset.sum_range_one]
      exact h01
    · rw [if_pos hs2]
      exact sum_range_tower h01 hF4 hFzero s hs2
  -- assemble
  have hle : cycleCount (2 ^ s * m) a ≤ 2 ^ s * m := by
    have h1 : cycleCount (2 ^ s * m) a ≤ (Finset.univ : Finset (ZMod (2 ^ s * m))).card :=
      Finset.card_image_le
    simpa using h1
  have hcyc : cycleCount (2 ^ s * m) a = ∑ e ∈ (2 ^ s * m).divisors, idx e a := by
    rw [cycleCount_eq_sum hcop]
    simp only [idx]
    exact Nat.sum_div_divisors (2 ^ s * m) (fun e => Nat.totient e / orderOf ((a : ZMod e)))
  have hNzero : (((2 ^ s * m : ℕ)) : ZMod 2) = 0 := by
    refine (natCast_zmod_two_eq_zero_iff _).mpr ?_
    have h2N : (2 : ℕ) ∣ 2 ^ s * m := ⟨2 ^ (s - 1) * m, by
      rw [← mul_assoc, ← pow_succ']
      congr 2
      omega⟩
    omega
  rw [Nat.cast_sub hle, CharTwo.sub_eq_add, hcyc, Nat.cast_sum, hNzero, zero_add, hsum, hkey]

/-- **The complete sign law of the permutation readout.**  For every modulus
`N ≥ 1` and every multiplier `a` coprime to `N`, the permutation `x ↦ a·x` of
`ZMod N` is even if and only if

* `N` is odd and the Jacobi symbol `J(a|N)` is `+1`; or
* `N ≡ 2 (mod 4)`; or
* `4 ∣ N` and `a ≡ 1 (mod 4)`.

In every case the bit is computable in polynomial time from `a` and `N` alone,
without any knowledge of the factorisation: the coarsest global readout of the
stratified cycle spectrum is free. -/
theorem permutation_sign_law {N a : ℕ} [NeZero N] (hcop : Nat.Coprime a N) :
    ((N - cycleCount N a) % 2 = 0
      ↔ (if N % 2 = 1 then jacobiSym (a : ℤ) N = 1 else (4 ∣ N → a % 4 = 1))) := by
  rcases Nat.even_or_odd N with hev | hod
  · -- even modulus
    have hN0 : N ≠ 0 := NeZero.ne N
    set s := N.factorization 2 with hsdef
    set m := N / 2 ^ s with hmdef
    have hsplit : 2 ^ s * m = N := Nat.ordProj_mul_ordCompl_eq_self N 2
    have hs : 1 ≤ s := Nat.Prime.factorization_pos_of_dvd Nat.prime_two hN0 hev.two_dvd
    have hm : Odd m := by
      rcases Nat.even_or_odd m with hev' | hod'
      · exfalso
        have hcop2 : Nat.Coprime 2 m := Nat.coprime_ordCompl Nat.prime_two hN0
        have h2m : (2 : ℕ) ∣ m := hev'.two_dvd
        have := Nat.Coprime.eq_one_of_dvd hcop2 h2m
        omega
      · exact hod'
    have hpar := parity_readout_even hsplit.symm hs hm hcop
    have hNev : N % 2 = 0 := Nat.even_iff.mp hev
    rw [if_neg (by omega)]
    have hle : cycleCount N a ≤ N := by
      have h1 : cycleCount N a ≤ (Finset.univ : Finset (ZMod N)).card := Finset.card_image_le
      simpa using h1
    have ha : Odd a := by
      rcases Nat.even_or_odd a with hev' | hod'
      · exfalso
        have := Nat.Coprime.eq_one_of_dvd (hcop.coprime_dvd_left hev'.two_dvd) hev.two_dvd
        omega
      · exact hod'
    rw [← natCast_zmod_two_eq_zero_iff, hpar]
    by_cases h4 : 2 ≤ s
    · rw [if_pos h4]
      constructor
      · intro hz _
        exact (idx_four_parity ha).mp ((natCast_zmod_two_eq_zero_iff _).mp hz)
      · intro hcon
        have h4N : (4 : ℕ) ∣ N := by
          rw [← hsplit]
          exact Dvd.dvd.mul_right (by
            calc (4 : ℕ) = 2 ^ 2 := by norm_num
              _ ∣ 2 ^ s := pow_dvd_pow 2 h4) m
        exact (natCast_zmod_two_eq_zero_iff _).mpr ((idx_four_parity ha).mpr (hcon h4N))
    · rw [if_neg h4]
      have hs1 : s = 1 := by omega
      refine iff_of_true rfl ?_
      intro h4N
      exfalso
      -- `4 ∣ N` would force `s ≥ 2`
      have h4dvd : (2 : ℕ) ^ 2 ∣ N := by simpa using h4N
      have hle2 : 2 ≤ N.factorization 2 :=
        (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hN0).mp h4dvd
      omega
  · -- odd modulus
    rw [if_pos (Nat.odd_iff.mp hod)]
    exact (zolotarev_general hod hcop).symm

end EvenModulus

end Physics.PermReadout