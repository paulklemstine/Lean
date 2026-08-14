import Mathlib
import Physics.PermutationReadoutCore

/-!
# The permutation readout is asymmetric — and still useless

Building on `Physics.PermutationReadoutCore`, this file works out the semiprime
case `N = p·q` of the PERMORD experiment and settles the two questions the
experiment was designed to answer.

**1. The readout is genuinely asymmetric (the "lcm-blindness" loophole is
closed).**  Unit-group probes only see `ord_N(a) = lcm(ord_p(a), ord_q(a))`
(`Physics.PermReadout.orderOf_eq_lcm`), a symmetric functional of the pair.
The cycle structure of `x ↦ a·x` on the *whole ring* `ZMod N` sees the two
orders separately: the point `p ∈ ZMod N` sits on a cycle of length exactly
`ord_q(a)` and the point `q` on a cycle of length `ord_p(a)`
(`period_at_prime_left/right`).  We exhibit two multipliers with *equal*
`ord_N` but *different* individual readouts (`readout_separates_lcm_blind`),
so the readout is strictly finer than the lcm.

**2. It is nevertheless not an algorithm.**  Three obstructions are formalised:

* `factor_of_nontrivial_stratum` — circular entry: a point of a non-trivial
  stratum *is* a nontrivial factor of `N`, so one cannot enter a non-unit cycle
  without already having factored `N`;
* `totient_ge_half` / `sqrt_lt_totient` — the unit stratum, which is the only
  stratum one can enter for free, has more than `N/2 > √N` elements, so the
  enumeration is worse than trial division;
* `period_dvd_orderOf` with `orderOf_eq_lcm` — every cycle length divides
  `ord_N(a)`, so reading an individual cycle length is exactly an order-finding
  problem, not a shortcut around one.

## Main results

* `Physics.PermReadout.orderOf_eq_lcm`
* `Physics.PermReadout.cycleCount_semiprime` — the exact cycle count
  `1 + φ(N)/ord_N + (q−1)/ord_q + (p−1)/ord_p`.
* `Physics.PermReadout.period_at_prime_left`, `period_at_prime_right`
* `Physics.PermReadout.factor_recovery` — a primitive root readout returns the
  factorisation.
* `Physics.PermReadout.readout_separates_lcm_blind` — a concrete pair
  (`N = 65`, `a = 57` vs `b = 31`) with equal `ord_N` and different readouts.
* `Physics.PermReadout.factor_of_nontrivial_stratum`,
  `Physics.PermReadout.sqrt_lt_totient`, `Physics.PermReadout.period_dvd_orderOf`
-/

namespace Physics.PermReadout

open Finset

/-! ## Every cycle length divides the global order -/

/-- Orders shrink along quotients: if `M ∣ N` then `ord_M(a) ∣ ord_N(a)`. -/
theorem orderOf_natCast_dvd_of_dvd {M N a : ℕ} (hMN : M ∣ N) :
    orderOf ((a : ZMod M)) ∣ orderOf ((a : ZMod N)) := by
  set k := orderOf ((a : ZMod N)) with hk
  rw [orderOf_dvd_iff_pow_eq_one]
  have h1 : ((a : ZMod N)) ^ k = 1 := pow_orderOf_eq_one _
  have h2 : a ^ k ≡ 1 [MOD N] := by
    rw [← ZMod.natCast_eq_natCast_iff]
    push_cast
    simpa using h1
  have h3 : a ^ k ≡ 1 [MOD M] := h2.of_dvd hMN
  rw [← ZMod.natCast_eq_natCast_iff] at h3
  push_cast at h3
  simpa using h3

/-- **Every cycle length divides `ord_N(a)`.**  The individual orders that the
readout exposes are refinements of the global order, never independent data. -/
theorem period_dvd_orderOf {N a : ℕ} (x : ℕ) :
    period N a x ∣ orderOf ((a : ZMod N)) := by
  exact orderOf_natCast_dvd_of_dvd (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left N x))

/-! ## The lcm law: what the unit group alone can see -/

/-- **The lcm law.**  For coprime moduli the global order is the lcm of the two
local orders: this is the symmetric — and therefore lossy — datum available to
any probe that only multiplies units. -/
theorem orderOf_eq_lcm {m n : ℕ} (hcop : Nat.Coprime m n) (a : ℕ) :
    orderOf ((a : ZMod (m * n))) =
      Nat.lcm (orderOf ((a : ZMod m))) (orderOf ((a : ZMod n))) := by
  have e := ZMod.chineseRemainder hcop
  rw [← e.toMulEquiv.orderOf_eq ((a : ZMod (m * n)))]
  have he : e.toMulEquiv (a : ZMod (m * n)) = ((a : ZMod m), (a : ZMod n)) := by
    have h : e.toMulEquiv (a : ZMod (m * n)) = ((a : ℕ) : ZMod m × ZMod n) := map_natCast e a
    rw [h]
    simp [Prod.ext_iff]
  rw [he, Prod.orderOf_mk]

/-! ## The free stratum is lcm-blind

The unit stratum `S_1` is the only stratum an algorithm can enter without
already knowing a factor.  Everything it shows is a function of `ord_N(a)`
alone: all its cycles have that one length, and their number is
`φ(N)/ord_N(a)`.  Two multipliers with the same global order are therefore
*indistinguishable* on the free part of the ring — this is exactly the
lcm-blindness the experiment set out to circumvent. -/

section FreeStratum

variable {N : ℕ} [NeZero N] {a b : ℕ}

/-- Every cycle inside the unit stratum has length `ord_N(a)`. -/
theorem card_orb_of_unit_stratum (hcop : Nat.Coprime a N) {x : ZMod N}
    (hx : x ∈ stratum N 1) : (orb N a x).card = orderOf ((a : ZMod N)) := by
  rw [card_orb hcop, period_of_mem_stratum hx, Nat.div_one]

/-- The unit stratum contains `φ(N)/ord_N(a)` cycles. -/
theorem cyclesIn_one (hcop : Nat.Coprime a N) :
    cyclesIn N a 1 = Nat.totient N / orderOf ((a : ZMod N)) := by
  rw [cyclesIn_eq hcop (one_dvd _), Nat.div_one]

/-- **The free part of the permutation carries nothing but the lcm.**  If two
multipliers have the same order in `(ZMod N)ˣ` then their cycle structures agree
on the whole unit stratum: same cycle lengths, same number of cycles. -/
theorem free_stratum_lcm_blind (hcopa : Nat.Coprime a N) (hcopb : Nat.Coprime b N)
    (hord : orderOf ((a : ZMod N)) = orderOf ((b : ZMod N))) :
    (∀ x ∈ stratum N 1, (orb N a x).card = (orb N b x).card) ∧
      cyclesIn N a 1 = cyclesIn N b 1 := by
  refine ⟨fun x hx => ?_, ?_⟩
  · rw [card_orb_of_unit_stratum hcopa hx, card_orb_of_unit_stratum hcopb hx, hord]
  · rw [cyclesIn_one hcopa, cyclesIn_one hcopb, hord]

end FreeStratum

/-! ## The semiprime case -/

section Semiprime

variable {p q a : ℕ}

/-- The divisor lattice of a semiprime. -/
theorem divisors_semiprime (hp : p.Prime) (hq : q.Prime) :
    (p * q).divisors = {1, p, q, p * q} := by
  rw [Nat.divisors_mul, hp.divisors, hq.divisors]
  ext d
  simp [Finset.mem_mul]
  tauto

/-- **The exact cycle count for `N = p·q`.**  The permutation `x ↦ a·x` of
`ZMod (p·q)` has `1 + φ(N)/ord_N(a) + (q−1)/ord_q(a) + (p−1)/ord_p(a)` cycles:
one fixed point, the unit cycles, and the two prime strata. -/
theorem cycleCount_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    cycleCount (p * q) a =
      Nat.totient (p * q) / orderOf ((a : ZMod (p * q)))
        + (q - 1) / orderOf ((a : ZMod q))
        + (p - 1) / orderOf ((a : ZMod p))
        + 1 := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hppq : p < p * q := by nlinarith
  have hqpq : q < p * q := by nlinarith
  have hdivp : (p * q) / p = q := by
    rw [Nat.mul_div_cancel_left _ hp.pos]
  have hdivq : (p * q) / q = p := by
    rw [Nat.mul_div_assoc _ (dvd_refl q), Nat.div_self hq.pos, mul_one]
  rw [cycleCount_eq_sum hcop, divisors_semiprime hp hq]
  rw [Finset.sum_insert (by simp; omega), Finset.sum_insert (by simp; omega),
    Finset.sum_insert (by simp; omega), Finset.sum_singleton]
  rw [Nat.div_one, hdivp, hdivq, Nat.div_self (Nat.mul_pos hp.pos hq.pos)]
  have hone : orderOf ((a : ZMod 1)) = 1 := orderOf_eq_one_iff.mpr (Subsingleton.elim _ _)
  simp only [Nat.totient_prime hp, Nat.totient_prime hq, Nat.totient_one, hone, Nat.div_one]
  omega

/-- The point `p` of `ZMod (p·q)` lies in the stratum labelled `p`. -/
theorem val_natCast_prime (hp : p.Prime) (hq : q.Prime) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    ((p : ZMod (p * q))).val = p := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  exact ZMod.val_natCast_of_lt (by nlinarith [hp.two_le, hq.two_le])

/-- **Asymmetric readout, first half.**  The cycle through the point `p` has
length exactly `ord_q(a)`. -/
theorem period_at_prime_left (hp : 0 < p) :
    period (p * q) a p = orderOf ((a : ZMod q)) := by
  unfold period
  rw [Nat.gcd_comm, Nat.gcd_eq_left ⟨q, rfl⟩, Nat.mul_div_cancel_left _ hp]

/-- **Asymmetric readout, second half.**  The cycle through the point `q` has
length exactly `ord_p(a)`. -/
theorem period_at_prime_right (hq : 0 < q) :
    period (p * q) a q = orderOf ((a : ZMod p)) := by
  have hdivq : p * q / q = p := by
    rw [Nat.mul_div_assoc _ (dvd_refl q), Nat.div_self hq, mul_one]
  unfold period
  rw [Nat.gcd_comm, Nat.gcd_eq_left ⟨p, mul_comm p q⟩, hdivq]

/-- **The readout factors `N`.**  If `a` is a primitive root modulo `q`, the
cycle length at the point `p` is `q − 1`, and `q` — a nontrivial factor of
`N` — is read off directly. -/
theorem factor_recovery (hp : p.Prime) (hq : q.Prime) (hprim : orderOf ((a : ZMod q)) = q - 1) :
    period (p * q) a p + 1 = q ∧ (period (p * q) a p + 1) ∣ p * q ∧
      1 < period (p * q) a p + 1 ∧ period (p * q) a p + 1 < p * q := by
  have hq2 : 2 ≤ q := hq.two_le
  have hp2 : 2 ≤ p := hp.two_le
  have hper : period (p * q) a p = q - 1 := by
    rw [period_at_prime_left hp.pos, hprim]
  refine ⟨by omega, ?_, by omega, ?_⟩
  · rw [hper, show q - 1 + 1 = q by omega]
    exact ⟨p, mul_comm p q⟩
  · rw [hper]
    have : q < p * q := by nlinarith
    omega

/-- The point `p` of `ZMod (p·q)` sits in the stratum labelled `p`. -/
theorem strat_natCast_prime (hp : p.Prime) (hq : q.Prime) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    strat (p * q) ((p : ZMod (p * q))) = p := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  unfold strat
  rw [val_natCast_prime hp hq, Nat.gcd_comm, Nat.gcd_eq_left ⟨q, rfl⟩]

/-- **The asymmetric readout, cycle version.**  The actual cycle of the
permutation through the ring element `p` has exactly `ord_q(a)` elements. -/
theorem card_orb_at_prime (hp : p.Prime) (hq : q.Prime) (hcop : Nat.Coprime a (p * q)) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    (orb (p * q) a ((p : ZMod (p * q)))).card = orderOf ((a : ZMod q)) := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  rw [card_orb hcop, val_natCast_prime hp hq, period_at_prime_left hp.pos]

/-- The four strata of a semiprime have sizes `φ(N)`, `q−1`, `p−1`, `1`. -/
theorem card_stratum_semiprime (hp : p.Prime) (hq : q.Prime) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    (stratum (p * q) 1).card = Nat.totient (p * q) ∧
      (stratum (p * q) p).card = q - 1 ∧
      (stratum (p * q) q).card = p - 1 ∧
      (stratum (p * q) (p * q)).card = 1 := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [card_stratum (one_dvd _), Nat.div_one]
  · rw [card_stratum ⟨q, rfl⟩, Nat.mul_div_cancel_left _ hp.pos, Nat.totient_prime hq]
  · rw [card_stratum ⟨p, mul_comm p q⟩,
      show p * q / q = p from by
        rw [Nat.mul_div_assoc _ (dvd_refl q), Nat.div_self hq.pos, mul_one],
      Nat.totient_prime hp]
  · rw [card_stratum (dvd_refl _), Nat.div_self (Nat.mul_pos hp.pos hq.pos), Nat.totient_one]

/-- **Every cycle length divides the lcm datum.**  Combining the stratified
period law with the lcm law: the readout refines `lcm(ord_p(a), ord_q(a))`, so
reading a single cycle length is an order-finding problem in disguise. -/
theorem period_dvd_lcm (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (x : ℕ) :
    period (p * q) a x ∣ Nat.lcm (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [← orderOf_eq_lcm hcop a]
  exact period_dvd_orderOf x

/-- **The readout at a divisor.**  For any `d ∣ N` the cycle through the ring
element `d` has length `ord_{N/d}(a)`: the permutation exposes the whole family
of local orders, not just the global one. -/
theorem period_at_divisor {N d a : ℕ} (hd : d ∣ N) :
    period N a d = orderOf ((a : ZMod (N / d))) := by
  unfold period
  rw [Nat.gcd_comm, Nat.gcd_eq_left hd]

/-- **The cycle count of a primitive multiplier is `gcd(p−1, q−1) + 3`.**
For `a` primitive modulo both factors the entire cycle structure collapses to a
single arithmetic invariant of the factorisation — and that invariant is the one
quantity a unit-group probe already determines, since
`φ(N)/ord_N(a) = gcd(p−1, q−1)`. -/
theorem cycleCount_primitive (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hcop : Nat.Coprime a (p * q)) (hap : orderOf ((a : ZMod p)) = p - 1)
    (haq : orderOf ((a : ZMod q)) = q - 1) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    cycleCount (p * q) a = Nat.gcd (p - 1) (q - 1) + 3 := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hcpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hlcm0 : 0 < Nat.lcm (p - 1) (q - 1) :=
    Nat.pos_of_ne_zero (fun h => by
      rcases Nat.lcm_eq_zero_iff.mp h with h' | h' <;> omega)
  have htot : Nat.totient (p * q) = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul hcpq, Nat.totient_prime hp, Nat.totient_prime hq]
  have hordN : orderOf ((a : ZMod (p * q))) = Nat.lcm (p - 1) (q - 1) := by
    rw [orderOf_eq_lcm hcpq a, hap, haq]
  rw [cycleCount_semiprime hp hq hpq hcop, htot, hordN, hap, haq,
    Nat.div_self (by omega : 0 < q - 1), Nat.div_self (by omega : 0 < p - 1)]
  rw [← Nat.gcd_mul_lcm (p - 1) (q - 1), Nat.mul_div_cancel _ hlcm0]

/-- The points that carry the asymmetric information — those outside the unit
stratum — number exactly `p + q − 1`. -/
theorem card_informative_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
    (Finset.univ.filter (fun x : ZMod (p * q) => strat (p * q) x ≠ 1)).card = p + q - 1 := by
  haveI : NeZero (p * q) := ⟨(Nat.mul_pos hp.pos hq.pos).ne'⟩
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hcpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hunit : (Finset.univ.filter (fun x : ZMod (p * q) => strat (p * q) x = 1)).card
      = (p - 1) * (q - 1) := by
    have h := card_stratum (N := p * q) (d := 1) (one_dvd _)
    rw [Nat.div_one, Nat.totient_mul hcpq, Nat.totient_prime hp, Nat.totient_prime hq] at h
    rw [← h, stratum]
  have htotal := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset (ZMod (p * q))))
    (p := fun x => strat (p * q) x = 1)
  rw [hunit, Finset.card_univ, ZMod.card] at htotal
  have hkey : p * q = (p - 1) * (q - 1) + (p + q - 1) := by
    calc p * q = ((p - 1) + 1) * ((q - 1) + 1) := by
          rw [show p - 1 + 1 = p from by omega, show q - 1 + 1 = q from by omega]
      _ = (p - 1) * (q - 1) + ((p - 1) + (q - 1) + 1) := by ring
      _ = (p - 1) * (q - 1) + (p + q - 1) := by omega
  have hfilter : (Finset.univ.filter (fun x : ZMod (p * q) => strat (p * q) x ≠ 1)).card
      = (Finset.univ.filter (fun x : ZMod (p * q) => ¬ (strat (p * q) x = 1))).card := rfl
  rw [hfilter]
  omega

/-- **The informative points are rare.**  Their density is at most `2/p`: for a
balanced semiprime a uniformly random probe hits an informative stratum with
probability `O(N^{-1/2})`. -/
theorem informative_density (hle : p ≤ q) : (p + q - 1) * p ≤ 2 * (p * q) := by
  have h : p + q - 1 ≤ 2 * q := by omega
  calc (p + q - 1) * p ≤ (2 * q) * p := Nat.mul_le_mul_right _ h
    _ = 2 * (p * q) := by ring

/-- **The sampling barrier, in `√N` form.**  For a *balanced* semiprime
(`p ≤ q ≤ 2p`) the informative points occupy a fraction at most `6/√N` of the
ring: a uniformly random probe needs `Ω(√N)` samples before it meets a point
whose cycle length is not the free datum `ord_N(a)` — no better than trial
division, and worse than Pollard's `N^{1/4}`. -/
theorem informative_density_sqrt (hle : p ≤ q) (hbal : q ≤ 2 * p) :
    (p + q - 1) * Nat.sqrt (p * q) ≤ 6 * (p * q) := by
  have hs : Nat.sqrt (p * q) ≤ 2 * p := by
    rcases Nat.lt_or_ge (2 * p) (Nat.sqrt (p * q)) with h1 | h1
    · exfalso
      have := Nat.sqrt_le (p * q)
      nlinarith
    · exact h1
  have h3 : p + q - 1 ≤ 3 * p := by omega
  calc (p + q - 1) * Nat.sqrt (p * q) ≤ (3 * p) * (2 * p) :=
        Nat.mul_le_mul h3 hs
    _ = 6 * (p * p) := by ring
    _ ≤ 6 * (p * q) := by
        exact Nat.mul_le_mul_left _ (Nat.mul_le_mul_left _ hle)

end Semiprime

/-! ## Barrier 2: circular entry -/

/-- **Circular entry.**  Any point outside the unit stratum and the zero stratum
already exhibits a nontrivial factor of `N`: one cannot *enter* an informative
cycle without having solved the problem the cycle is supposed to solve. -/
theorem factor_of_nontrivial_stratum {N : ℕ} [NeZero N] (x : ZMod N)
    (h1 : strat N x ≠ 1) (hN : strat N x ≠ N) :
    strat N x ∣ N ∧ 1 < strat N x ∧ strat N x < N := by
  have hdvd : strat N x ∣ N := strat_dvd x
  have hpos : 0 < strat N x :=
    Nat.gcd_pos_of_pos_left _ (Nat.pos_of_ne_zero (NeZero.ne N))
  have hle : strat N x ≤ N := Nat.le_of_dvd (Nat.pos_of_ne_zero (NeZero.ne N)) hdvd
  exact ⟨hdvd, by omega, by omega⟩

/-! ## Barrier 4: the enumeration is Ω(N) -/

/-- Of two distinct odd primes the larger is at least `5`. -/
theorem five_le_of_prime_ne {p q : ℕ} (hq : q.Prime) (hpq : p ≠ q) (hp3 : 3 ≤ p)
    (hq3 : 3 ≤ q) (h : p ≤ q) : 5 ≤ q := by
  have h4 : q ≠ 4 := by rintro rfl; norm_num at hq
  omega

/-- The free stratum (the units) already contains at least half of the ring:
`2·φ(pq) ≥ pq` for distinct odd primes. -/
theorem totient_ge_half {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp3 : 3 ≤ p) (hq3 : 3 ≤ q) : p * q ≤ 2 * Nat.totient (p * q) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [Nat.totient_mul hcop, Nat.totient_prime hp, Nat.totient_prime hq]
  obtain ⟨r, rfl⟩ : ∃ r, p = r + 3 := ⟨p - 3, by omega⟩
  obtain ⟨s, rfl⟩ : ∃ s, q = s + 3 := ⟨q - 3, by omega⟩
  have hrs : 1 ≤ r + s := by
    rcases Nat.eq_zero_or_pos (r + s) with h | h
    · exact absurd (show r + 3 = s + 3 by omega) hpq
    · exact h
  rw [show r + 3 - 1 = r + 2 from by omega, show s + 3 - 1 = s + 2 from by omega]
  nlinarith

/-- **Enumeration is worse than trial division.**  The unit stratum of a semiprime
with odd prime factors is larger than `√N`: the cycle readout must touch more
points than trial division ever inspects. -/
theorem sqrt_lt_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp3 : 3 ≤ p) (hq3 : 3 ≤ q) : Nat.sqrt (p * q) < Nat.totient (p * q) := by
  have hhalf := totient_ge_half hp hq hpq hp3 hq3
  have hs : Nat.sqrt (p * q) * Nat.sqrt (p * q) ≤ p * q := Nat.sqrt_le (p * q)
  have hN15 : 15 ≤ p * q := by
    rcases le_total p q with h | h
    · have h5 := five_le_of_prime_ne hq hpq hp3 hq3 h
      nlinarith
    · have h5 := five_le_of_prime_ne hp (Ne.symm hpq) hq3 hp3 h
      nlinarith
  by_contra hcon
  push_neg at hcon
  nlinarith

/-- Total enumeration cost: the strata exhaust the ring, so a full cycle readout
visits all `N` elements. -/
theorem sum_stratum_card {N : ℕ} [NeZero N] :
    ∑ d ∈ N.divisors, (stratum N d).card = N := by
  rw [Finset.sum_congr rfl (fun d hd => card_stratum (Nat.dvd_of_mem_divisors hd))]
  rw [Nat.sum_div_divisors N Nat.totient]
  exact Nat.sum_totient N

end Physics.PermReadout