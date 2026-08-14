/-
Round-10 Closures — Part VI: the synthesis.

This file assembles the four round-10 verdicts into one capstone theorem about a semiprime
`N = p * q` built from distinct odd primes, and records the exact place where the classical
uniform hint-free surface ends:

1. **JOINTCLOSURE / barrier 4** — no function of the joint free-witness profile over any
   finite exponent set returns a prime factor (`no_profile_extractor`);
2. **RAINBOWWALK / barrier 8-5** — the smooth-step walk emits no gcd signal at all
   (`smoothWalk_no_nontrivialDivisor`);
3. **Q-BYPASS** — one residue/order coordinate *does* return a prime factor, and the
   coordinate's population is computed exactly by the trace lemma
   (`residue_witness_factors`, `freeWitness_two`);
4. **HINT-AMP** — one external additive hint also returns a prime factor, in closed form
   (`factorFromTrace_eq`), so hint amplification lies outside the framework's scope.

The contrast between (1) on one side and (3), (4) on the other is the formal content of
"the quantum advantage is localised at barrier 4's aggregation, not at the trace lemma".
-/
import Geometry.Round10Closures.QuantumBypass
import Geometry.Round10Closures.RainbowWalk
import Geometry.Round10Closures.HintAmplification

namespace Round10

open FactoringBarriers

/-- **Round-10 capstone.**  For distinct odd primes `p, q`, any finite set `S` of positive
exponents, and any unit seed/step of a smooth-step walk modulo `N = p*q`:

* the joint free-witness profile over `S` supports no factor extractor;
* the walk never produces a nontrivial divisor;
* yet a single residue witness (a nontrivial square root of unity, the coordinate Shor's
  order finding reads off) does produce a prime factor, and there are exactly four square
  roots of unity to choose from;
* and a single external trace hint also produces a prime factor.

Aggregation, not the trace lemma, is the operative barrier. -/
theorem round10_capstone {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hqp : q < p)
    (S : Finset ℕ) (hS : ∀ k ∈ S, 0 < k)
    {x s : ℕ} (hx : Nat.Coprime x (p * q)) (hs : Nat.Coprime s (p * q)) :
    -- (1) barrier 4: no aggregation of the hint-free witness family
    (¬ ∃ F : (ℕ → ℕ) → ℕ, ∀ r : ℕ, r.Prime → q < r → F (profile S (r * q)) = r) ∧
    -- (2) barrier 8/5: the smooth-step walk is sterile
    (∀ t : ℕ, ¬ NontrivialDivisor (p * q) (Nat.gcd (smoothWalk (p * q) x s t) (p * q))) ∧
    -- (3) the residue/order coordinate is sufficient, and its population is exactly four
    (freeWitness (p * q) 2 = 4 ∧
      ∃ a : ℤ, ((p * q : ℕ) : ℤ) ∣ a ^ 2 - 1 ∧
        ¬ ((p * q : ℕ) : ℤ) ∣ (a - 1) ∧ ¬ ((p * q : ℕ) : ℤ) ∣ (a + 1) ∧
        (Int.gcd (a - 1) ((p * q : ℕ) : ℤ) = p ∨ Int.gcd (a - 1) ((p * q : ℕ) : ℤ) = q)) ∧
    -- (4) an external trace hint is amplified to the factorisation in closed form
    factorFromTrace (q * p) (q + p) = q := by
  refine ⟨no_profile_extractor S hS Fact.out, fun t => smoothWalk_no_nontrivialDivisor hx hs t,
    ⟨freeWitness_two p q hpq hp2 hq2, residue_witness_factors hpq hp2 hq2⟩,
    factorFromTrace_eq hqp.le⟩

/-! ## Lab notes (round-10 batch, replicated computationally)

Brute-force counts of `{x ∈ (ZMod N)ˣ : x^k = 1}` against the trace-lemma prediction
`gcd(k, p-1) * gcd(k, q-1)`; the two columns agree in every case, which is the content of
`freeWitness_eq`:

| N       | k = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---------|-------|---|---|---|---|---|---|---|
| 15 = 3·5| 1 | 4 | 1 | 8 | 1 | 4 | 1 | 8 |
| 21 = 3·7| 1 | 4 | 3 | 4 | 1 | 12| 1 | 4 |
| 35 = 5·7| 1 | 4 | 3 | 8 | 1 | 12| 1 | 8 |

Saturating primes for the round-10 exponent set `{6,12,15,20,30,60}` (primes `≡ 1 mod 60`):
`61, 181, 241, 421, 541, 601, 661, …` — an infinite family by Dirichlet
(`exists_saturating_prime`), all with identical joint profiles
(`experiment337_collision` checks the first two by hand).

Smooth-step walk `x ↦ 2x mod 8051` from the seed `3` (note `8051 = 83 · 97`):
values `3, 6, 12, 24, 48, 96, 192, 384, 768, 1536, 3072, 6144, …`, gcd with `8051` equal to
`1` at every step, as forced by `smoothWalk_coprime`.

Hint amplification on `8051`: `factorFromTrace 8051 180 = (180 - sqrt(180² - 4·8051))/2 =
(180 - 14)/2 = 83`.
-/

/-- The lab-notes hint-amplification datum, verified. -/
theorem labnote_hint_8051 : factorFromTrace 8051 180 = 83 := by
  have : (8051 : ℕ) = 83 * 97 := by norm_num
  have h := factorFromTrace_eq (p := 83) (q := 97) (by norm_num)
  norm_num at h
  simpa using h

/-- The lab-notes walk datum, verified: after twelve smooth steps modulo `8051 = 83 · 97`
the walk is still a unit, so the gcd channel is empty. -/
theorem labnote_walk_8051 : Nat.gcd (smoothWalk 8051 3 2 12) 8051 = 1 :=
  smoothWalk_gcd_eq_one (by norm_num) (by norm_num) 12

end Round10