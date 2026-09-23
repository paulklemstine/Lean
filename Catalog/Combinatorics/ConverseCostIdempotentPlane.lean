/-
# CONVERSE-COST-CURVE, part III: the idempotent witness and the square-root route

The W4 witness of the converse-cost experiment counts the solutions of
`x² ≡ x (mod N)`.  The experiment first *excluded* `x = 0` and its own
`count = 4` assertion failed: the trivial idempotent is part of the CRT
structure.  Here the CRT structure is made formal.

* `ConverseCost.idempotent_card` — for a semiprime `N = pq` there are exactly
  `4` idempotents of `ZMod N` (the count that the corrected scan reproduces).
* `ConverseCost.idempotent_count_is_constant` — hence the *count* is the same
  number `4` for every semiprime: the W4 counter carries **zero** bits about
  the factorisation, even though its `Θ(N)` definition route is the most
  expensive in the family.  All of the factor content sits in the *witnesses*,
  not in their number.
* `ConverseCost.idempotent_reveals_factor` — a nontrivial idempotent does reveal
  a factor: `gcd(x, N) ∈ {p, q}` and the cofactor is the other prime.
* `ConverseCost.sqrt_congruence_reveals_factor` — the same phenomenon for the
  square-root (Fermat/continued-fraction/Pell) route: a congruence of squares
  `x² ≡ y² (mod N)` that is not a congruence of the roots reveals a factor.

The reveal steps reuse the catalog's factor-reveal lemma
`ThreeSumReveal.gcd_eq_prime_of_dvd_of_lt`.
-/
import Mathlib
import Shared.ThreeSumFactorReveal

namespace ConverseCost

open Finset

/-! ## Idempotents of a finite field -/

/-- In a field the only idempotents are `0` and `1`. -/
theorem idempotents_field (F : Type*) [Field F] [Fintype F] [DecidableEq F] :
    (Finset.univ.filter (fun x : F => x * x = x)) = {0, 1} := by
  ext x
  simp only [mem_filter, mem_univ, true_and, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro h
    have hx : x * (x - 1) = 0 := by linear_combination h
    rcases mul_eq_zero.mp hx with h1 | h1
    · exact Or.inl h1
    · exact Or.inr (by linear_combination h1)
  · rintro (rfl | rfl) <;> ring

/-- `ZMod p` has exactly two idempotents for `p` prime. -/
theorem idempotent_card_prime {p : ℕ} (hp : p.Prime) :
    Nat.card {x : ZMod p // x * x = x} = 2 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fintype (ZMod p) := ZMod.fintype p
  classical
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype, idempotents_field (ZMod p),
    Finset.card_insert_of_notMem (by simp [zero_ne_one]), Finset.card_singleton]

/-- Idempotents of a product are pairs of idempotents. -/
theorem idempotent_card_prod (A B : Type*) [Mul A] [Mul B] :
    Nat.card {y : A × B // y * y = y}
      = Nat.card {a : A // a * a = a} * Nat.card {b : B // b * b = b} := by
  have e : {y : A × B // y * y = y} ≃ {a : A // a * a = a} × {b : B // b * b = b} := by
    refine (Equiv.subtypeEquivRight ?_).trans Equiv.subtypeProdEquivProd
    intro y
    exact ⟨fun h => ⟨congrArg Prod.fst h, congrArg Prod.snd h⟩,
      fun h => Prod.ext h.1 h.2⟩
  rw [Nat.card_congr e, Nat.card_prod]

/-- The Chinese remainder isomorphism transports idempotents. -/
theorem idempotent_card_crt {p q : ℕ} (h : Nat.Coprime p q) :
    Nat.card {x : ZMod (p * q) // x * x = x}
      = Nat.card {y : ZMod p × ZMod q // y * y = y} := by
  let e := ZMod.chineseRemainder h
  refine Nat.card_congr (Equiv.subtypeEquiv e.toEquiv ?_)
  intro x
  refine ⟨fun hx => by simpa using congrArg e hx, fun hx => ?_⟩
  have : e (x * x) = e x := by simpa using hx
  exact e.injective this

/-! ## W4: exactly four idempotents -/

/-- **W4 closed form.**  A semiprime modulus carries exactly four idempotents
`0, 1, e, 1 - e`; the trivial one `x = 0` is part of the CRT structure and must
not be excluded. -/
theorem idempotent_card {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    Nat.card {x : ZMod (p * q) // x * x = x} = 4 := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  rw [idempotent_card_crt hpq, idempotent_card_prod, idempotent_card_prime hp,
    idempotent_card_prime hq]

/-- **The W4 counter carries no information.**  Two different semiprimes give
the very same witness value `4`: the `Θ(N)` scan that computes the idempotent
*count* returns a constant, so the entire factor content of the route lies in
the idempotents themselves, not in how many there are. -/
theorem idempotent_count_is_constant {p q p' q' : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hne' : p' ≠ q') :
    Nat.card {x : ZMod (p * q) // x * x = x}
      = Nat.card {x : ZMod (p' * q') // x * x = x} := by
  rw [idempotent_card hp hq hne, idempotent_card hp' hq' hne']

/-! ## Nontrivial idempotents and congruences of squares do reveal factors -/

/-- **A nontrivial idempotent reveals a factor.**  If `0 < x < N = pq`, `x ≠ 1`
and `x² ≡ x (mod N)`, then `gcd(x, N)` is one of the two primes, and the
cofactor is the other one. -/
theorem idempotent_reveals_factor {p q x : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) (hx0 : 0 < x) (hx1 : x ≠ 1) (hxN : x < p * q)
    (hidem : (p * q) ∣ x * (x - 1)) :
    Nat.gcd x (p * q) = p ∨ Nat.gcd x (p * q) = q := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have hdp : p ∣ x * (x - 1) := dvd_trans ⟨q, rfl⟩ hidem
  have hdq : q ∣ x * (x - 1) := dvd_trans ⟨p, Nat.mul_comm p q⟩ hidem
  have hxm1 : x - 1 < p * q := by omega
  rcases (Nat.Prime.dvd_mul hp).mp hdp with hpx | hpx <;>
    rcases (Nat.Prime.dvd_mul hq).mp hdq with hqx | hqx
  · -- both primes divide `x`: then `N ∣ x`, impossible for `0 < x < N`
    exfalso
    have : p * q ∣ x := Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq hpx hqx
    exact absurd (Nat.le_of_dvd hx0 this) (not_le.mpr hxN)
  · exact Or.inl (ThreeSumReveal.gcd_eq_prime_of_dvd_of_lt hp hq hx0 hxN hpx)
  · refine Or.inr ?_
    have := ThreeSumReveal.gcd_eq_prime_of_dvd_of_lt hq hp hx0
      (by rwa [Nat.mul_comm q p]) hqx
    rwa [Nat.mul_comm q p] at this
  · -- both primes divide `x - 1`: then `N ∣ x - 1`, forcing `x = 1`
    exfalso
    have hdvd : p * q ∣ x - 1 := Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq hpx hqx
    rcases Nat.eq_zero_or_pos (x - 1) with h | h
    · omega
    · exact absurd (Nat.le_of_dvd h hdvd) (not_le.mpr hxm1)

/-- **The square-root route.**  A congruence of squares `x² ≡ y² (mod N)` whose
difference is a nonzero non-multiple of `N` reveals a factor: this is the shape
produced by Fermat, by the continued-fraction method and by Pell-type relations
(the W3 route).  The cost of *finding* such a congruence is what the experiment
measures; the reveal step itself is one gcd. -/
theorem sqrt_congruence_reveals_factor {p q x y : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) (hyx : y < x) (hlt : x - y < p * q)
    (hsum : ¬ (p * q) ∣ (x + y)) (hdvd : (p * q) ∣ (x - y) * (x + y)) :
    Nat.gcd (x - y) (p * q) = p ∨ Nat.gcd (x - y) (p * q) = q := by
  have hpos : 0 < x - y := by omega
  have hdp : p ∣ (x - y) * (x + y) := dvd_trans ⟨q, rfl⟩ hdvd
  have hdq : q ∣ (x - y) * (x + y) := dvd_trans ⟨p, Nat.mul_comm p q⟩ hdvd
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  rcases (Nat.Prime.dvd_mul hp).mp hdp with hpd | hps <;>
    rcases (Nat.Prime.dvd_mul hq).mp hdq with hqd | hqs
  · -- both divide the difference: `N ∣ x - y`, contradicting `0 < x - y < N`
    exfalso
    have : p * q ∣ x - y := Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq hpd hqd
    exact absurd (Nat.le_of_dvd hpos this) (not_le.mpr hlt)
  · exact Or.inl (ThreeSumReveal.gcd_eq_prime_of_dvd_of_lt hp hq hpos hlt hpd)
  · refine Or.inr ?_
    have := ThreeSumReveal.gcd_eq_prime_of_dvd_of_lt hq hp hpos
      (by rwa [Nat.mul_comm q p]) hqd
    rwa [Nat.mul_comm q p] at this
  · -- both divide the sum: `N ∣ x + y`, excluded by hypothesis
    exact absurd (Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq hps hqs) hsum

/-- The revealed factor immediately gives the full factorisation. -/
theorem reveal_gives_cofactor {p q g : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hg : g = p ∨ g = q) : (p * q) / g = q ∨ (p * q) / g = p := by
  rcases hg with rfl | rfl
  · exact Or.inl (Nat.mul_div_cancel_left q hp.pos)
  · exact Or.inr (by rw [Nat.mul_comm p g]; exact Nat.mul_div_cancel_left p hq.pos)

/-! ## Lab notes -/

/-- `N = 15 = 3·5`: the four idempotents are `0, 1, 6, 10`. -/
example : ((Finset.range 15).filter (fun x => x * x % 15 = x)) = {0, 1, 6, 10} := by decide

/-- `N = 35 = 5·7`: four idempotents again, `0, 1, 15, 21`. -/
example : ((Finset.range 35).filter (fun x => x * x % 35 = x)).card = 4 := by decide

/-- The nontrivial idempotent `6` of `ZMod 15` reveals the factor `3`. -/
example : Nat.gcd 6 15 = 3 := by decide

end ConverseCost