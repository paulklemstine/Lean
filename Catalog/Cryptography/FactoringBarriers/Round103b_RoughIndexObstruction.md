# Round 103b — the mixed-difference escape, and the true obstruction: rough indices

**2026-10-04. No exponent beaten. This note follows round 103's "next attack" to its
end: build a difference that does BOTH roles (covers a large prime AND small
integers) in one budget. The escape WORKS at the level it predicts — and exposes
the real obstruction, which is deeper than the counting wall.**

---

## 1. The mixed-difference escape (works!)

Round 103 showed `d = F·P` (smooth `F` × large-prime product `P`) splits the
magnitude budget, so one difference can't cover both small integers and a large
prime. The **escape**: use `d = p · lcm(1..s)` with `s = n^γ`. Its magnitude is

$$\ln d \;=\; \ln p + \ln\operatorname{lcm}(1..s) \;\approx\; \ln n + s \;\le\; 2\,n^\gamma,$$

well within `M = exp(n^γ)`. Its divisors cover **`[1..s]` AND `p` (and all small
multiples of `p`)** — **both roles in one difference**. This genuinely escapes
round 103's packing tension.

## 2. Why it still doesn't close the cover

Each mixed difference covers `[1..s]` (only `s = n^γ` indices) plus **one** large
prime. Measured coverage (analytic, `n = 2^b`):

| n | γ=1/3 | γ=0.40 |
|---|---|---|
| 2^16 | 2% | 9% |
| 2^32 | 0% | 1% |
| 2^40 | 0% | 0% |

Coverage **collapses with `n`**, because `[1..s]` is a vanishing fraction of `[1,n]`
and one-prime-per-difference doesn't scale to `π(n)` targets.

## 3. The TRUE obstruction: rough indices (deeper than the counting wall)

My "cover the primes and we're done" instinct was wrong. The hard targets are not
the primes — they are the **rough (smooth-free) indices**:

> An index `i ∈ [1,n]` is `n^γ`-**rough** if no prime `≤ n^γ` divides it. By
> Dickman, the fraction of `n^γ`-smooth integers up to `n` is
> `ρ(n^{1−γ})`; at `γ=1/3` that is `ρ(2.67) ≈ 0.1`, so **~90% of `[1,n]` is rough**.

Every rough `i` (typically a semiprime `i = p·q` or a prime power, with **all**
prime factors `> n^γ`) can only be covered by a single difference divisible by
**the entire factorization of `i`**. So a cover is not a *prime-counting* problem
(count the `n/ln n` primes) — it is a **packing problem over the rough
semiprimes**: each difference must simultaneously carry several large primes whose
product still divides a target `i ≤ n`, all within one magnitude budget.

> **This is the deepest obstruction identified.** The counting wall `α+2β ≥ 1`
> (round 96), the GAP-gcd reduction (round 99), the packing tension (round 103),
> and the Fourier/design negatives (rounds 96d, 102) all live at the level of
> **how many differences** or **how they spread**. None of them captures this:
> ~90% of the targets are rough, and each needs a difference absorbing *all* its
> large prime factors simultaneously. That simultaneous-absorption constraint —
> not the difference count — is what a real construction must solve.

## 4. Honest scope

* **No exponent beaten.** The mixed-difference escape is valid but insufficient:
  it covers small integers + one prime per difference, missing the rough
  semiprimes that dominate `[1,n]`.
* **New:** (a) a working one-difference "both-roles" escape (beats round 103's
  packing tension); (b) identification of the **rough-index obstruction** as the
  true, deeper wall — a semiprime-packing problem, not a counting problem.
* **Not claimed:** that no cover exists. Only that every family tried (random,
  hill-climbed, design, higher-rank GAP, greedy, residue, Fourier, prime-
  assignment, mixed) fails on the rough-index simultaneous-absorption constraint.

**Next attack.** A construction must build differences whose **divisor set
contains rough semiprimes** — i.e. differences of the form `p·q·(small)` with `p,q`
large, whose magnitude `p·q ≲ n ≪ exp(n^γ)` leaves budget for a small filler. The
natural target is a **multi-scale highly-composite difference** whose divisors hit
both isolated rough primes AND rough semiprimes. Whether such a family can be
constructed (not just counted) is the open problem this investigation now isolates
precisely.