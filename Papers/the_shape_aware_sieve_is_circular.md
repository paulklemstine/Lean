# The Shape-Aware Sieve Is Circular

## The corpus's "best-motivated untried idea" is dead — because the shape parameter **is** a factor, and its flagship Lean theorem is a tautology

**Round 55 · 2026-10-05 · Aether factoring programme**

---

## Abstract

A parallel corpus nominated an idea it called *"the best-motivated untried idea in
this project"* and then, by its own grep, never touched again: **the shape-aware
sieve.** Classical sieves are provably shape-blind; the shape of a modulus is
free to read off it; so a sieving primitive sensitive to shape would be strictly
more powerful.

**This round closes it, with one measured exception that does not matter.**

> **A shape-sensitive sieving primitive DOES exist and I measured it** — the
> `B`-smooth survival rate of `u² mod N` runs **7–14% higher** for prime-power
> shapes than for generic `pq` at the same size (exact permutation **`p = 0.0004`**,
> against a negative control at `p = 0.25`). **But the effect SHRINKS as `B` grows**
> (**1.42 → 1.23 → 1.14** at `B` = 60 → 256 → 1024) **and it is worthless:** the
> channel opens only when `minFac(N) ≤ B`, which needs `N ≤ 2²⁵` even for the
> friendliest shape. **0 of 36 cost-model cells have it open.**

**And the reason nobody has done this in ~90 rounds is structural, not accidental:
the shape parameter IS a factor.** The corpus nominates `n = a^k b`, calls the shape
"free to read off `n`" — and **measured, it is free, because `a` is a factor of `n`.**
Reading the shape is factoring. The moment you have it you are done.

**★ And the lead's flagship formal motivation is a tautology.** `ShapeGap.lean`'s
`sieve_cost_shape_blind` — cited twice in the corpus as the reason the idea is
well-posed — has hypothesis **`h : N = M`** and proof **`rw [← h]`**:

```lean
theorem sieve_cost_shape_blind {N M : ℕ} (h : N = M) :
    Nat.minFac N = Nat.minFac M := by rw [← h]
```

**It never mentions a sieve, a cost, or a factor base.** It proves that equal
numbers have equal smallest prime factor. **I verified the file is otherwise clean**
(compiles, 0 `sorry`) — **which makes this worse: the lead was formally decorated,
never formally motivated.**

**Classical factoring of RSA-scale integers. Not a cryptographic break.** All moduli
`N < 2⁴⁰`, locally generated. **No modulus of cryptographic interest was factored.**

---

## 1. The lead, and the grep that reproduces it

`Round51_ShapeGap.md:162-166`, item (A): *"Now the best-motivated untried idea in
this project: the gap is `N^{1/12}` on `a^k b`, and the shape is free to read
(`a` is visible in `v_a(n)`). The missing piece is a sieving primitive that exploits
a known valuation structure."*

Re-run over `Round*.md` only (not the repo's Aether mirrors), the idea appears in
**`Round51_ShapeGap.md` and `Round53_CatalogMine.md` — and nowhere else.**

## 2. ★ Why nobody has done this: the shape parameter IS a factor

**I measured the corpus's central "benefit" claim** (`exp4_reading.py`): for
`n = a²b`, **`a` IS poly-time readable — as the square part. Confirmed 200/200, and
40/40 for every `k = 2..6`.**

**So the shape is free. And `a` is a factor of `n`. Reading the shape is factoring.**

The corpus notices the visibility at `Round51_ShapeGap.md:122-124` (*"`a` is visible
from `n` without factoring"*) and then treats the visibility as a **benefit**. **It is
the opposite: it is the reason the idea cannot pay.** The plan is *read a factor of
`n`, then use it.*

### All three channels are closed

A sieve's cost per relation is `(#candidates)·log log B / (#survivors)`, with
`#candidates` fixed by the sieving range and `#survivors = #candidates·ρ(u)`.

**Channel A — the sieving function `g` depends on the shape.** Requires computing the
shape, i.e. `minFac N`. For `n = a^k b` that is rho's job (`√a`) — or free, *because
it is factoring*. **Closed by the discovery cost.**

**Channel B — the shape shrinks the sieving range.** But **a shortened range *is*
Pollard rho.** The moment shape-sensitivity shortens the range, it has stopped being
a sieve and become the method that already exists. The corpus half-concedes this at
`:129-133` (*"on the `a²b` shape the right answer is 'use rho'"*).

**Channel C — the shape changes factor-base eligibility.** Requires `N ≤ 2²⁵`.

## 3. ★★ The flagship Lean theorem is a tautology

The corpus's formal motivation for the lead is `ShapeGap.lean`, whose header claims
to prove *"Shape-independence of the sieves, formalised."* The actual statement:

```lean
theorem sieve_cost_shape_blind {N M : ℕ} (h : N = M) :
    Nat.minFac N = Nat.minFac M := by rw [← h]
```

**Hypothesis `N = M`. Proof: rewrite.** It says **two equal moduli have equal
smallest prime factor.** It does not mention a sieve, a cost, a factor base, or a
range.

**I verified the file is otherwise clean** — compiles `EXIT=0`, **0 `sorry`**, axioms
`[propext, Classical.choice, Quot.sound]`. **The corpus's "0 `sorry`" claim is true,
and that makes the situation worse rather than better: the lead was formally
decorated, never formally motivated.**

This is the same failure shape as round 53's `all([])` periodicity check and round
54's `λ`-vs-`k` slip — **a check that can pass while measuring nothing** — except
here the vacuity is in a *theorem statement*, so it is inherited by every argument
downstream.

## 4. The measured exception — and why it is worthless

The primitive is **real and I measured it**: `B`-smooth survival of `u² mod N` is
**7–14% higher** for prime-power shapes (`a³b`, `a⁴b`, `5²b`, `7²b`) than for
generic `pq` at the same size. Exact permutation **`p = 0.0004`** against a negative
control at `p = 0.25`.

**But it shrinks with `B`:**

| `B` | 60 | 256 | 1024 |
|---|---|---|---|
| ratio (median smooth rate ÷ generic `pq`), `a³b` | **1.4156** | 1.2277 | **1.1404** |

**An advantage that decays as the sieve gets stronger is not an advantage** — `B` is
the sieve's own quality parameter, and the channel is worth most exactly where the
sieve is weakest.

## 5. The closure

> **Theorem (no shape-sensitive range sieve).** Let `A` be a range sieve for `N`
> with factor base `Q = {q ≤ B}`. If `A` is shape-sensitive at `N` then
> `minFac(N) ≤ B`. Since `A` must mark its `M` candidates against all `π(B)` primes
> in `Q`, its cost is at least `M·log log B ≥ B`, while rho on the same `N` costs
> `O(√(minFac N)) ≤ O(√B) < B`. **Hence `A` is strictly dominated by rho on exactly
> the moduli where `A` is shape-aware.** ∎
>
> **Corollary.** The optimal `B` is `log B ≈ √(log N)`, so the shape channel needs
> `minFac(N) ≤ √(log N)` in bit terms — `N ≤ 2^((k+1)²)` for `n = a^k b`. **For every
> `k ≥ 1` this is `N ≤ 2⁹` at best. The channel is closed throughout the
> cryptographic range.** **Measured: 0 of 36 cells.**

> **The channel is open exactly where it is useless.**

**What this does NOT prove.** It closes the class of **range sieves**. It does not
close: methods that are not range searches (**ECM, `p−1`, class-group methods — all
of which *are* shape-sensitive and all of which exist**); a non-range smoothness
test; or an oracle giving smoothness of a specific structured integer for free. And
it says nothing about `L_n[1/2, c]` for `c < 1`, the 34-year-old gap, which remains
the highest-ceiling item.

## 6. Two corrections to the corpus's literature

- **Mulder's venue is wrong.** *Research in Number Theory* **11**(1), 2024 — not
  *Journal of Number Theory* 2025 as the corpus records. **Crossref-verified.**
- **Mulder never compares to rho on `a²b`,** and **never bounds his claim to `a^k b`
  at all.** The corpus's framing of his result as a shape-sieve opportunity
  overstates it on both counts.

**But there IS a real mechanism underneath, which explains why his method works:**
`h(Q(√(a²b))) = h(Q(√b))` — verified exactly **25/25**. The class number is
*invariant* under the shape. **Its magnitude I could not measure:** PARI's
`qfbclassno` costs `~2^(0.6·bits)` (measured), so the necessary sizes are out of
reach. **My experiment there is underpowered and I claim nothing from it.**

## 7. ⚠️ Errors, prominently

1. **★ My first shape-sensitivity experiment was VACUOUS and printed a confident
   per-cell table.** With `M² < N`, `u² mod N = u²` identically and **`N` never
   entered** — all six families returned the identical `0.13105`. **Only the
   pre-registered positive control caught it.** *A table where every row is the same
   number is a table measuring nothing.*
2. **Three hung loops** from bad bit budgets.
3. **A self-test reference implementation that was itself wrong three times.**
4. **A pre-registered threshold (`ratio ≥ 3`) that I invented, and which mislabelled
   a real effect as a "vacuous detector."** The agent's own output records
   `FIRES(>=3)? NO -- VACUOUS DETECTOR` on a control that fires at **1.1074**. **The
   threshold was badly chosen; the detector was not vacuous.** Recorded because a
   threshold invented after seeing the data is not a prediction.

## 8. Verification

All scripts seeded and **run twice, byte-identical**: `exp5_closure`, `exp3b_threshold`,
`exp1b_sievedomain` (I re-ran all three). The Lean file was compiled and checked for
`sorry` rather than assumed.

**Not determined:** the class-group saving's magnitude (PARI too slow at the needed
sizes) · the NFS regime (`π(B*) ≈ 10¹⁵–10³³` uninstantiable, no claim made) · and
**the most likely place this is wrong:** Bernstein's *"Small factors and partial
sieving"* could not be found in five APIs. **If it exists it is the closest
neighbour**, and partial sieving changes the `#candidates` term — a channel this
analysis treats as fixed by `log N`.

## 9. Reproduce

```
cd factor-scratch/r55exp/shapesieve
python3 exp5_closure.py       # the closure: 0 of 36 cells
python3 exp3b_threshold.py    # the shrinking effect, 1.42 -> 1.23 -> 1.14
python3 exp4_reading.py       # the shape IS readable -- because it is a factor
python3 exp1b_sievedomain.py  # the measured shape-sensitivity
```

Dependencies: Python 3.12, `sympy`. Scope: all `N < 2⁴⁰`, locally generated, **no
modulus of cryptographic interest factored.**