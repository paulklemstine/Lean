/-
# CONVERSE-COST-CURVE, part VIII: the square-root ladder `#{x² = 1} = 2^ω(N)`

Cycle 4 proved the *idempotent* ladder: `ZMod N` carries exactly `2^{ω(N)}`
idempotents, so the W4 definition route is an `ω`-detector and nothing more.
Direction **D6** conjectured the companion statement for the other
factor-revealing local equation, `x² = 1`, whose nontrivial solutions are the
square roots of unity used by Fermat, CFRAC, Pell and Miller–Rabin.  This file
closes it for odd moduli.

* `ConverseCost.sqrtOne_val_dvd` — the arithmetic form of `x² = 1`:
  `m ∣ (v − 1)(v + 1)` for `v = x.val`.
* `ConverseCost.sqrtOne_of_odd_prime_pow` — local rigidity: modulo an odd prime
  power the only square roots of `1` are `±1` (an odd prime cannot divide both
  `v − 1` and `v + 1`, whose difference is `2`).
* `ConverseCost.sqrtOne_card_odd_prime_pow` — hence the local count is `2`.
* `ConverseCost.sqrtOne_card_eq_two_pow_omega` — the ladder
  `#{x : ZMod N // x² = 1} = 2^{ω(N)}` for every odd `N > 0`.
* `ConverseCost.sqrtOne_card_odd_semiprime` — the family instance: an odd
  semiprime has exactly four square roots of unity, two of them nontrivial.
* `ConverseCost.sqrtOne_route_is_omega_detector` — the W3-type counter is
  constant on the odd semiprimes, exactly like the W4 counter: the `Θ(N)` scan
  that *counts* square roots of unity separates nothing.

The content of the route therefore sits in the individual nontrivial roots
(each of which reveals a factor, `ConverseCost.sqrt_congruence_reveals_factor`),
never in how many of them there are.
-/
import Mathlib
import Combinatorics.ConverseCostIdempotentPlane

namespace ConverseCost

open Finset

/-! ## The arithmetic form of `x² = 1` -/

/-- If `x * x = 1` in `ZMod m` with `1 < m`, then `m ∣ (v − 1)(v + 1)` where
`v = x.val`.  Natural subtraction is harmless because `v ≥ 1`. -/
theorem sqrtOne_val_dvd {m : ℕ} [NeZero m] (hm : 1 < m) (x : ZMod m) (h : x * x = 1) :
    m ∣ (x.val - 1) * (x.val + 1) := by
  haveI : Fact (1 < m) := ⟨hm⟩
  haveI : Nontrivial (ZMod m) := ZMod.nontrivial m
  have hx : ((x.val : ℕ) : ZMod m) = x := by simp [ZMod.natCast_val, ZMod.cast_id]
  have hv0 : 0 < x.val := by
    rcases Nat.eq_zero_or_pos x.val with h0 | h0
    · exfalso
      have hx0 : x = 0 := by rw [← hx, h0]; simp
      rw [hx0] at h
      simp at h
    · exact h0
  have hcast : ((x.val * x.val : ℕ) : ZMod m) = ((1 : ℕ) : ZMod m) := by
    push_cast [ZMod.natCast_val, ZMod.cast_id]
    exact h
  have hmod : (1 : ℕ) ≡ x.val * x.val [MOD m] :=
    ((ZMod.natCast_eq_natCast_iff _ _ _).mp hcast).symm
  have hle : 1 ≤ x.val * x.val := Nat.one_le_iff_ne_zero.mpr (by positivity)
  have hd : m ∣ x.val * x.val - 1 := (Nat.modEq_iff_dvd' hle).mp hmod
  obtain ⟨w, hw⟩ : ∃ w, x.val = w + 1 := ⟨x.val - 1, by omega⟩
  have key : (w + 1) * (w + 1) - 1 = w * (w + 2) := by
    have : (w + 1) * (w + 1) = w * (w + 2) + 1 := by ring
    rw [this, Nat.add_sub_cancel]
  rw [hw] at hd ⊢
  simpa [key, Nat.add_sub_cancel] using hd

/-! ## Local rigidity modulo an odd prime power -/

/-- **Local rigidity.**  Modulo an odd prime power the only square roots of `1`
are `1` and `−1`: the prime cannot divide both `v − 1` and `v + 1`, since their
difference is `2`. -/
theorem sqrtOne_of_odd_prime_pow {p n : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hn : 0 < n)
    (x : ZMod (p ^ n)) (h : x * x = 1) : x = 1 ∨ x = -1 := by
  have hm : 1 < p ^ n := Nat.one_lt_pow hn.ne' hp.one_lt
  haveI : NeZero (p ^ n) := ⟨by omega⟩
  haveI : Fact (1 < p ^ n) := ⟨hm⟩
  haveI : Nontrivial (ZMod (p ^ n)) := ZMod.nontrivial _
  have hx : ((x.val : ℕ) : ZMod (p ^ n)) = x := by simp [ZMod.natCast_val, ZMod.cast_id]
  have hvlt : x.val < p ^ n := ZMod.val_lt x
  have hv0 : 0 < x.val := by
    rcases Nat.eq_zero_or_pos x.val with h0 | h0
    · exfalso
      have hx0 : x = 0 := by rw [← hx, h0]; simp
      rw [hx0] at h
      simp at h
    · exact h0
  have hdvd := sqrtOne_val_dvd hm x h
  have hp3 : 3 ≤ p := by
    have := hp.two_le
    omega
  by_cases hp1 : p ∣ (x.val + 1)
  · -- then `p ∤ v − 1`, so `p^n ∣ v + 1` and `v + 1 = p^n`, i.e. `x = −1`
    right
    have hnd : ¬ p ∣ (x.val - 1) := by
      intro hc
      have h2 : p ∣ (x.val + 1) - (x.val - 1) := Nat.dvd_sub hp1 hc
      rw [show (x.val + 1) - (x.val - 1) = 2 by omega] at h2
      have := Nat.le_of_dvd (by norm_num) h2
      omega
    have hcop : Nat.Coprime (p ^ n) (x.val - 1) :=
      Nat.Coprime.pow_left _ ((Nat.Prime.coprime_iff_not_dvd hp).mpr hnd)
    have hd : p ^ n ∣ (x.val + 1) := hcop.dvd_of_dvd_mul_left hdvd
    have hge : p ^ n ≤ x.val + 1 := Nat.le_of_dvd (by omega) hd
    have hveq : x.val = p ^ n - 1 := by omega
    have hneg : ((p ^ n - 1 : ℕ) : ZMod (p ^ n)) = -1 := by
      rw [Nat.cast_sub (by omega), ZMod.natCast_self, Nat.cast_one, zero_sub]
    rw [← hx, hveq, hneg]
  · -- then `p^n ∣ v − 1`, forcing `v = 1`, i.e. `x = 1`
    left
    have hcop : Nat.Coprime (p ^ n) (x.val + 1) :=
      Nat.Coprime.pow_left _ ((Nat.Prime.coprime_iff_not_dvd hp).mpr hp1)
    have hd : p ^ n ∣ (x.val - 1) := hcop.dvd_of_dvd_mul_right hdvd
    have hz : x.val - 1 = 0 := by
      rcases Nat.eq_zero_or_pos (x.val - 1) with h1 | h1
      · exact h1
      · exact absurd (Nat.le_of_dvd h1 hd) (by omega)
    have hv1 : x.val = 1 := by omega
    rw [← hx, hv1, Nat.cast_one]

/-- An odd prime power carries exactly two square roots of unity. -/
theorem sqrtOne_card_odd_prime_pow {p n : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hn : 0 < n) :
    Nat.card {x : ZMod (p ^ n) // x * x = 1} = 2 := by
  have hp3 : 3 ≤ p := by
    have := hp.two_le
    omega
  have hm : 2 < p ^ n := by
    calc 2 < p := by omega
    _ = p ^ 1 := (pow_one p).symm
    _ ≤ p ^ n := Nat.pow_le_pow_right (by omega) hn
  haveI : NeZero (p ^ n) := ⟨by omega⟩
  haveI : Fintype (ZMod (p ^ n)) := ZMod.fintype _
  haveI : Fact (2 < p ^ n) := ⟨hm⟩
  classical
  have hne : (1 : ZMod (p ^ n)) ≠ -1 := fun h => ZMod.neg_one_ne_one h.symm
  have hset : (Finset.univ.filter (fun x : ZMod (p ^ n) => x * x = 1)) = {1, -1} := by
    ext x
    simp only [mem_filter, mem_univ, true_and, Finset.mem_insert, Finset.mem_singleton]
    exact ⟨fun h => sqrtOne_of_odd_prime_pow hp hp2 hn x h,
      by rintro (rfl | rfl) <;> ring⟩
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype, hset,
    Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]

/-! ## The product and CRT steps -/

/-- Square roots of unity multiply across a product of monoids. -/
theorem sqrtOne_card_prod (A B : Type*) [Monoid A] [Monoid B] :
    Nat.card {y : A × B // y * y = 1}
      = Nat.card {a : A // a * a = 1} * Nat.card {b : B // b * b = 1} := by
  have e : {y : A × B // y * y = 1} ≃ {a : A // a * a = 1} × {b : B // b * b = 1} := by
    refine (Equiv.subtypeEquivRight ?_).trans Equiv.subtypeProdEquivProd
    intro y
    exact ⟨fun h => ⟨congrArg Prod.fst h, congrArg Prod.snd h⟩,
      fun h => Prod.ext h.1 h.2⟩
  rw [Nat.card_congr e, Nat.card_prod]

/-- The Chinese remainder isomorphism transports square roots of unity. -/
theorem sqrtOne_card_crt {p q : ℕ} (h : Nat.Coprime p q) :
    Nat.card {x : ZMod (p * q) // x * x = 1}
      = Nat.card {y : ZMod p × ZMod q // y * y = 1} := by
  let e := ZMod.chineseRemainder h
  refine Nat.card_congr (Equiv.subtypeEquiv e.toEquiv ?_)
  intro x
  refine ⟨fun hx => by simpa using congrArg e hx, fun hx => ?_⟩
  have : e (x * x) = e 1 := by simpa using hx
  exact e.injective this

/-! ## The ladder -/

/-- **The square-root ladder.**  For every odd `N > 0` the equation `x² = 1` has
exactly `2^{ω(N)}` solutions in `ZMod N`.

Like the idempotent ladder, the count sees only `ω(N)`: the number of square
roots of unity is blind to which primes occur, so a route that merely *counts*
them cannot separate two semiprimes. -/
theorem sqrtOne_card_eq_two_pow_omega :
    ∀ N : ℕ, 0 < N → Odd N →
      Nat.card {x : ZMod N // x * x = 1} = 2 ^ N.primeFactors.card := by
  intro N
  induction N using Nat.recOnPosPrimePosCoprime with
  | prime_pow p n hp hn =>
      intro _ hodd
      have hp2 : p ≠ 2 := by
        rintro rfl
        have h2 : (2 : ℕ) ∣ 2 ^ n := dvd_pow_self 2 hn.ne'
        rw [Nat.odd_iff] at hodd
        omega
      rw [sqrtOne_card_odd_prime_pow hp hp2 hn, Nat.primeFactors_pow _ hn.ne',
        hp.primeFactors, Finset.card_singleton, pow_one]
  | zero => intro h; exact absurd h (lt_irrefl 0)
  | one =>
      intro _ _
      haveI : Subsingleton {x : ZMod 1 // x * x = 1} :=
        ⟨fun a b => Subtype.ext (Subsingleton.elim _ _)⟩
      have hcard : Nat.card {x : ZMod 1 // x * x = 1} = 1 :=
        Nat.card_eq_one_iff_unique.mpr ⟨inferInstance, ⟨⟨1, by ring⟩⟩⟩
      rw [hcard]
      simp
  | coprime a b ha hb hab iha ihb =>
      intro _ hodd
      have ha0 : 0 < a := by omega
      have hb0 : 0 < b := by omega
      obtain ⟨hoa, hob⟩ := Nat.odd_mul.mp hodd
      rw [sqrtOne_card_crt hab, sqrtOne_card_prod, iha ha0 hoa, ihb hb0 hob,
        Nat.primeFactors_mul ha0.ne' hb0.ne',
        Finset.card_union_of_disjoint (Nat.Coprime.disjoint_primeFactors hab),
        pow_add]

/-- **The family instance.**  An odd semiprime has exactly four square roots of
unity — `±1` and the two nontrivial ones produced by a CRT sign flip. -/
theorem sqrtOne_card_odd_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    Nat.card {x : ZMod (p * q) // x * x = 1} = 4 := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have hp1 : p ≠ 1 := hp.one_lt.ne'
  have hq1 : q ≠ 1 := hq.one_lt.ne'
  have hoddp : Odd p := hp.odd_of_ne_two hp2
  have hoddq : Odd q := hq.odd_of_ne_two hq2
  have hodd : Odd (p * q) := Nat.odd_mul.mpr ⟨hoddp, hoddq⟩
  have hpos : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  rw [sqrtOne_card_eq_two_pow_omega _ hpos hodd,
    Nat.primeFactors_mul hp.pos.ne' hq.pos.ne',
    hp.primeFactors, hq.primeFactors,
    Finset.card_union_of_disjoint (by simpa [hp.primeFactors, hq.primeFactors] using
      Nat.Coprime.disjoint_primeFactors hpq)]
  simp

/-- **The counter is an `ω`-detector.**  Two odd semiprimes with completely
different factorisations have the same number of square roots of unity, so the
`Θ(N)` scan that counts them returns a constant: all factor content of the
square-root route lies in the individual nontrivial roots. -/
theorem sqrtOne_route_is_omega_detector {p q p' q' : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    (hp' : p'.Prime) (hq' : q'.Prime) (hne' : p' ≠ q') (hp2' : p' ≠ 2) (hq2' : q' ≠ 2) :
    Nat.card {x : ZMod (p * q) // x * x = 1}
      = Nat.card {x : ZMod (p' * q') // x * x = 1} := by
  rw [sqrtOne_card_odd_semiprime hp hq hne hp2 hq2,
    sqrtOne_card_odd_semiprime hp' hq' hne' hp2' hq2']

/-- **The route does deliver, one root at a time.**  A square root of unity
other than `±1`, read back as an integer `1 < x < N − 1`, reveals a prime
factor: this is the reveal step of Fermat, CFRAC, Pell and Miller–Rabin, and it
costs a single gcd once the root is in hand. -/
theorem nontrivial_sqrtOne_reveals_factor {p q x : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) (hx1 : 1 < x) (hxN : x < p * q - 1)
    (hdvd : (p * q) ∣ (x * x - 1)) :
    Nat.gcd (x - 1) (p * q) = p ∨ Nat.gcd (x - 1) (p * q) = q := by
  have hpos : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  have hfac : (x - 1) * (x + 1) = x * x - 1 := by
    obtain ⟨w, rfl⟩ : ∃ w, x = w + 1 := ⟨x - 1, by omega⟩
    have h' : (w + 1) * (w + 1) = w * (w + 2) + 1 := by ring
    rw [h', Nat.add_sub_cancel]
    simp
  have hsum : ¬ (p * q) ∣ (x + 1) := by
    intro hc
    have := Nat.le_of_dvd (by omega) hc
    omega
  have hdvd' : (p * q) ∣ (x - 1) * (x + 1) := by rw [hfac]; exact hdvd
  have := sqrt_congruence_reveals_factor (x := x) (y := 1) hp hq hne (by omega)
    (by omega) (by simpa [Nat.add_comm] using hsum) (by simpa [Nat.add_comm] using hdvd')
  simpa using this

/-! ## Lab notes -/

/-- `N = 105 = 3·5·7` is odd with `ω = 3`: eight square roots of unity. -/
example : ((Finset.range 105).filter (fun x => x * x % 105 = 1)).card = 8 := by decide

/-- `N = 35 = 5·7`: four square roots of unity, `1, 6, 29, 34`. -/
example : ((Finset.range 35).filter (fun x => x * x % 35 = 1)) = {1, 6, 29, 34} := by decide

/-- The nontrivial root `6` of `ZMod 35` reveals the factor `5` via `gcd(6−1, 35)`. -/
example : Nat.gcd 5 35 = 5 := by decide

/-- `N = 9 = 3²` has `ω = 1`: only the two trivial roots `1, 8`. -/
example : ((Finset.range 9).filter (fun x => x * x % 9 = 1)).card = 2 := by decide

/-- `N = 45 = 3²·5` has `ω = 2`: four roots, the ladder is blind to the exponent. -/
example : ((Finset.range 45).filter (fun x => x * x % 45 = 1)).card = 4 := by decide

/-- `N = 15 = 3·5`: four roots again, the same value as `N = 35`. -/
example : ((Finset.range 15).filter (fun x => x * x % 15 = 1)).card = 4 := by decide

/-- The ladder fails at `2^k`: `ZMod 8` has four square roots of unity though
`ω(8) = 1` — this is exactly why the theorem is stated for odd moduli. -/
example : ((Finset.range 8).filter (fun x => x * x % 8 = 1)).card = 4 := by decide

end ConverseCost