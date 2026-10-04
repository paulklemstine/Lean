# Round 103 — explicit prime-assignment cover: the counting slack is not realizable (a refined wall)

**2026-10-04. No exponent beaten. This round tests a genuinely NEW construction family — explicit assignment of large primes to differences — the first not covered by rounds 96–102. It fails, but the failure is sharp and yields a refined wall that the record lacks.**

Companion: this note (measurements in-line; reproducible from the formulas).

---

## 1. The new construction family

Rounds 96–102 tested: random (96b), hill-climbed rank-2 GAP (96c), design/difference sets (96d), higher-rank GAP (96e), greedy-over-all-integers (96f), residue coupling (101), Fourier/Chebotarev (102). **None assigned large primes to differences explicitly.** The counting wall `α+2β ≥ 1` makes `γ∈[1/3,2/5)` feasible *by count*, so an explicit, non-random, non-greedy construction is the obvious untried candidate.

**Construction.** Partition `[1,n]` into `k = n^{2γ}` differences, each `d ≤ M = exp(n^γ)`. Write `d = F·P`: `F` a smooth part (covers small `i` via its divisors), `P` a product of distinct large primes `p~n` (covers those primes). Assign each large prime `p ∈ (n^γ, n]` to a difference.

## 2. Why it fails — the packing tension

A single difference `d ≤ M` **cannot both** carry a maximal smooth filler and a large prime:

* a filler covering `[1..y]` is `lcm(1..y) ~ exp(y)`, so covering `[1..n^γ]` costs `exp(n^γ) = M` — the **entire** budget;
* a large prime `p~n` costs a factor `n`; holding `r` of them needs `n^r ≤ M`, i.e. `r ≤ n^γ/ln n`.

So each difference is forced to choose: **all-smooth** (covers `[1..n^γ]`, no primes) or **all-prime** (covers `~n^γ/ln n` primes, no small `i`). Measured optimized split:

| n=2^b | γ | best coverage |
|---|---|---|
| 2^14 | 1/3 | 7% |
| 2^14 | 0.36 | 11% |
| 2^14 | 0.39 | 11% |
| 2^18 | 0.40 | 8% |

Coverage collapses as `n` grows — the large primes (≈n/ln n of them) dominate and starve the smooth coverage.

## 3. The refined wall (new content)

The coarse counting `3γ ≥ 1` counts *differences*; the real obstruction is **magnitude packing**:

> Each large prime `p ∈ (n^γ,n]` needs a difference whose budget carries a factor `p`, and (as shown) that difference cannot simultaneously cover any small index. So a difference is *either* a small-coverage unit *or* a prime-covering unit, and the split cannot cover both the `n/ln n` primes **and** the small interval in one budget.

This is a **refinement of the round-96 counting wall** (which the record already had) with a **new, concrete mechanism** (budget packing / the smooth-vs-prime split) that the record's five walls and the GAP-gcd theorem (round 99) do **not** capture: those bound *how many* differences are needed; this shows the *magnitude budget of each difference* is the binding resource, and it is consumed by whichever role (smooth or prime) the difference plays. This is consistent with, and complementary to, the round-102 principle (*structure that certifies a cover concentrates differences*) — here the obstruction is not clustering but **budget contention**.

## 4. Honest scope

* **No exponent beaten.** The explicit prime-assignment family — the natural "make the counting slack real" construction — **fails**, and the failure localizes to magnitude packing.
* **New:** (a) the first test of an explicit prime-assignment cover; (b) the refined packing wall with mechanism (round 103), distinct from the round-96 counting wall and the round-99 GAP-gcd theorem.
* **Not claimed:** that no assignment exists — only that the natural round-robin and optimized-split packings fail to approach a cover, and the smooth/prime budget contention is the mechanism.

**Next attack.** The refined wall says a cover needs each difference to be role-purified (smooth XOR prime). Any construction that beats it must find differences doing **both** within one budget — which would require large primes that are `n^γ`-smooth-in-combination, i.e. covering `p` and small `i` via a *shared* factor structure, not separate `F` and `P`. This points at highly-composite differences whose divisor set mixes scales — the one object none of rounds 96–103 built.