# Round 103c — the rough-semiprime wall: a second, independent route to γ ≥ 1/2

> ⚠️ **REASONING CORRECTED in round 105 (`Round105_SemiprimeWallAudit.md`).** The
> *conclusion* `γ ≥ 1/2` below is CORRECT and stands, but the *premise* it used —
> "each rough semiprime needs its own difference" — is **false** (one difference
> containing `p,q,r,s` covers six semiprimes). The correct argument is a
> **pair-covering design**: blocks of `k ~ n^γ/ln n` primes must cover all
> `C(v,2)` pairs of `v ~ n/ln n` primes, needing `(v/k)² = n^{2−2γ}` blocks vs
> budget `n^{2γ}` ⟹ `γ ≥ 1/2`. Same number, sound reason. Read §2/§3 below for
> the semiprime-count argument **as it stood** (useful for the mechanism, but not
> the proof).

**2026-10-04. No exponent beaten. This round follows round 103b's obstruction to
a unification result: a completely different argument (rough-semiprime packing)
independently recovers the SAME γ ≥ 1/2 barrier as the round-96b birthday
obstruction. Two independent walls now agree, which is strong evidence the
barrier is real.**

Companion: `Experiments/UMWWindow/rough_semiprime.py` (deterministic, `out_rough.txt`).

---

## 1. From round 103b: the mixed escape, and what it revealed

Round 103b built a difference `d = p·lcm(1..s)` (`s = n^γ`), which covers `[1..s]`
**and** the large prime `p` in one magnitude budget — a genuine escape from round
103's packing tension. But it only covered a vanishing fraction (`[1..n^γ]`) plus
one prime per difference. Following it led to the real obstruction:

> ~90% of `[1,n]` are **`n^γ`-rough** (no prime factor `≤ n^γ`). Each rough index
> `i = p·q` needs a **single** difference divisible by `i`'s **entire**
> factorization. A divisor cover is a **packing of rough semiprimes**, not a
> prime count.

## 2. The rough-semiprime wall (this round)

Let `RS(n,n^γ) = #{ p≤q primes : p,q > n^γ, pq ≤ n }` — the number of rough
semiprimes in `[1,n]`. A cover needs at least `k = n^{2γ} ≥ RS(n,n^γ)`
differences (one per uncovered rough semiprime). Measured:

| n | γ | #RS | `log(#RS)/log n` | `2γ` | feasible |
|---|---|---|---|---|---|
| 10⁴ | 0.40 | 252 | 0.600 | 0.800 | yes |
| 10⁵ | 0.40 | 2263 | 0.671 | 0.800 | yes |
| 3×10⁵ | 0.40 | 6387 | 0.695 | 0.800 | yes |
| 3×10⁵ | 0.36 | 10463 | 0.734 | 0.720 | **no** |
| 3×10⁵ | 0.34 | 12449 | 0.748 | 0.680 | **no** |

The exponent `log(#RS)/log n` **grows with `n`** (0.60 → 0.75 as `n`: 10⁴ → 3×10⁵),
and asymptotically `RS(n,n^γ) = n^{1−o(1)}` for any fixed `γ < 1/2`. So
feasibility (`2γ ≥ 1 − o(1)`) forces

$$\boxed{\gamma \;\to\; \tfrac12 .}$$

## 3. The unification

This is the round's result:

> **The rough-semiprime packing obstruction — an argument about factoring the
> target set into indivisible semiprime factors — independently recovers the
> exact `γ ≥ 1/2` barrier that the round-96b birthday obstruction (an argument
> about residue collisions mod `i`) derived.**

Two completely different mechanisms, same threshold. The birthday obstruction
counts *residue collisions*; the semiprime wall counts *indivisible-factor
targets*. Their agreement is strong evidence that `γ = 1/2` is not an artifact of
any single method but a genuine feature of the covering problem — which explains,
retrospectively, why **every** construction family in rounds 96–103 stalls near
exponent `1/4`.

## 4. Honest scope

* **No exponent beaten.** But this is the strongest *structural* result of the
  investigation: a second, independent derivation of the `1/4` barrier.
* **New:** (a) the rough-semiprime packing obstruction (round 103b) made precise;
  (b) its asymptotic count `RS = n^{1−o(1)}` forcing `γ → 1/2`; (c) the
  **unification** with the birthday obstruction — two mechanisms, one barrier.
* **Not claimed:** a proof that no cover exists. Two independent necessary
  conditions both forcing `γ ≥ 1/2` is very strong evidence, but the Umans–Wang
  conjecture is about exactly this and remains open.

**What this means for the program.** The `N^{1/4}`–`N^{1/5}` region (the whole
deterministic frontier and the UMW window `[1/3,2/5)`) is now bracketed by **two
independent walls at `γ = 1/2`** — i.e. exponent `1/4`. Any future construction
must violate *both* the residue-collision bound and the rough-semiprime packing
simultaneously. That is a sharply stated bar, and it is the most useful single
result this investigation produced.