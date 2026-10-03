# Round 48 — Axis I: Constant-factor improvements and hybrid attacks

**Verdict: the lattice-reduction half of the constant is already at its optimum.
No constant improvement is available from BKZ, and the lattice step is not the
bottleneck anyway. This is a clean negative, measured.**

Everything below was produced on this host by the code in `factor-scratch/r48/exp/`.
No number is quoted from a paper. The two literature figures in the axis brief
(the GNFS constant (64/9)^(1/3) = 1.92299 and Montgomery EUROCRYPT'95 p.118) are
treated as *given by the brief* and are not re-derived or re-measured here.

---

## 0. The self-test came first, and it caught four real bugs

Per the earned rules, the LLL/BKZ implementation was written and certified before
any NFS experiment. `exp/lll_self_test.py` exits 0; the gold standard is
`exp/exactsvp.py`, a **certified** enumerator whose box radius is proved to
contain the true shortest vector (it refuses, returning `None`, rather than
silently truncating).

Certified properties (all PASS, `python3 exp/lll_self_test.py`):

| id | property | result |
|----|----------|--------|
| S1 | our LLL never returns a vector shorter than exact SVP | 40/40 lattices, LLL/SVP ∈ [1.00000000, 1.14946164] |
| S2 | our LLL output is LLL-reduced (independent Lovász + Gram–Schmidt predicate, δ=0.99) | 15/15 |
| S3 | neither our LLL nor fpylll's ever beats exact SVP | 40/40 certifiable lattices |
| S4a | **control:** LLL really reduces (vs the raw basis) at three dimensions | n=8,10,12; mean gain 5.77×, 3.09×, 3.32× |
| S4b | **control:** LLL is genuinely *not* always optimal, so S1 is not vacuous | strictly suboptimal in 1/60 cases, max LLL/SVP 1.0251 |
| S5a | our BKZ never returns a vector shorter than exact SVP | full β sweep |
| S5b | our BKZ is never longer than our LLL (monotone in β) | full β sweep |
| S5c | BKZ(β=n) reaches the exact optimum | ratios 1.0 |
| S6 | **control:** on lattices where LLL is *provably* suboptimal, BKZ strictly improves | 2/6 improved, 1/6 exactly optimal |

Every control runs at multiple parameter values (three dimensions for S4a, a β
sweep for S5, six hard lattices for S6). None is a one-parameter control.

### Bugs the self-test found (all four were mine, not the experiment's)

1. **`delta` was accepted but never used.** The Lovász test was hardcoded to the
   old `0.55` form, so the "LLL" was running at δ≈0.75. Fixed to honour the
   requested δ.
2. **Size-reduction to a fixpoint, not one descending sweep.** A single sweep
   subtracts `q·b_j`, which changes `⟨b_k, b_l⟩` for *every* l, so coefficients
   already fixed get disturbed by later subtractions in the same sweep. Measured
   drift: μ → −0.578 with η = 0.501, a genuine violation, not float noise.
3. **Two different lattices in the differential test.** I compared a float LLL of
   `B` against fpylll's LLL of `round(B)`. And separately, every exact-SVP
   *reference* was computed on the float basis while the reducers ran on the
   rounded basis. Both had to be put on one integer lattice.
4. **Unimodularity.** My first BKZ recovered tour coefficients by float
   pseudoinverse and inserted them without checking; it returned vectors 0.55×
   the exact SVP — provably not the lattice it was given. Fixed by carrying exact
   integer coefficients out of the enumerator.

### Two honest limitations of my own tooling

- **fpylll's BKZ is unusable on this host.** The pruning-strategy table was never
  installed (`BKZ.DEFAULT_STRATEGY` → a nonexistent path); every BKZ entry point
  raises `Cannot open strategies file`, and with no `strategies` argument BKZ is a
  **silent no-op** — it returned byte-identical output for β=2…6 and results
  *worse* than plain LLL. Supplying an empty strategy file segfaults (fpylll
  0.6.4). So all BKZ numbers below are from my own implementation.
- **My BKZ is conservative.** Each tour normalises the first coefficient to ±1,
  which is exactly the condition (`det(T) = c₀`) under which the insertion is a
  unimodular *basis* change. It therefore provably cannot insert an SVP whose
  `c₀ = ±g, g > 1`. This is why S6 is gated on *improvement*, not on exact
  recovery. **C1's conclusion does not rest on my BKZ** — it rests on the
  certified exact-SVP enumerator, which is independent of it.

---

## C1. Lattice reduction past LLL — **NEGATIVE, and the negative is exact**

### Setup

Genuine GNFS relations were produced by a real 2-D sieve: for a monic
`f(x)=x³+c₂x²+c₁x+c₀`, `p` divides the algebraic integer `a−bθ` iff
`a ≡ b·α (mod p)` for a root α of f mod p. Rows of the relation lattice are the
coefficient vectors of `h_i(x) = ∏_p ∏_{r: f(r)≡0 mod p} (x−r)^{e_p}`,
truncated to `2d+1 = 7` coefficients. The lattices are 7-dimensional, which is
small enough to run the **certified exact SVP enumerator directly on them**.

That makes the experiment definitive rather than comparative:

> `LLL(b₁)/exact_SVP(b₁)` is the **total** prize available to *any* block size.
> If it is 1.000, no β can help.

### Result — 40 independent NFS relation lattices

```
LLL(b1)^2 / exact_SVP(b1)^2   over 40 NFS relation lattices:
  min  1.0000000000
  max  1.0000000000
  mean 1.0000000000
  # exactly 1.0 (LLL optimal): 40/40
  # above 1.0 (LLL suboptimal): 0/40

Best BKZ over all beta, per lattice:
  min 1.0000000000   max 1.0000000000
  best speed-up of ||b1|| from ANY block size: 1.0000000000x
```

Configurations spanned N of 32–55 bits, y ∈ {500, 1000, 2000}, and 16/24/32
relations; 119 configurations were attempted and 40 admitted a certified exact SVP
(the rest exceeded the enumeration cap and were **discarded, not silently
approximated**).

**LLL already returns a provably shortest vector on 40 of 40 NFS relation
lattices. BKZ at β = 2…7 changes nothing.**

### Why (mechanism)

This is not luck. The `h_i` have essentially disjoint small-prime supports — a
relation's polynomial is a product of linear factors `(x−r)` over *distinct*
splitting primes — so the rows are close to mutually orthogonal before reduction.
The NFS relation lattice is nearly orthogonal, and LLL is already at its optimum
on such a lattice. The Hermite factor after LLL is tiny (measured 0.00000–0.0154
across the 40 lattices), which is the signature of a lattice with nothing left to
gain.

### What this is worth at 1024 bits

**Zero.** The measured gain from the best possible block size is
`1.0000000000×`, i.e. a **0% wall-clock improvement**. Not 5% — none.

And the ceiling was never high: see C4, where the lattice step is **0.09%** of
the pipeline on this host. Even a hypothetical free lattice step would buy
0.09% of wall-clock at the sizes measured, and *less* at 1024 bits, where sieving
dominates by a far larger margin.

### Honest limitations of C1

- The lattices are 7-dimensional and built from N of 32–55 bits. The full
  1024-bit relation lattice is not constructible on this host. The result is a
  clean negative **at the sizes measured**, and the mechanism (near-orthogonal
  rows) is size-independent, but I have not measured it at 1024 bits.
- Rows are the `h_i` coefficient vectors, i.e. the relation lattice *before* the
  Montgomery `N·F(x)^k` subtraction. I could not get that subtraction to produce
  m-divisible rows (measured **0 of 40** rows divisible by m), so the Montgomery
  normalisation is **not** included. This is a real gap and I flag it rather than
  claim the lattice is the fully normalised Montgomery lattice.

---

## C2. The filtering step — measured cost, and it does not touch the constant

Sieve throughput on this host, box 1200×600 (1.44M pairs), N = 39 bits:

| y | splitting primes | survivors | smooth rate | sec | M pairs/s |
|---|---|---|---|---|---|
| 200 | 32 | 134 | 9.31e-05 | 1.49 | 0.96 |
| 500 | 65 | 432 | 3.00e-04 | 2.52 | 0.57 |
| 1000 | 110 | 890 | 6.18e-04 | 4.09 | 0.35 |
| 2000 | 202 | 1574 | 1.09e-03 | 6.85 | 0.21 |
| 5000 | 440 | 2668 | 1.85e-03 | 15.97 | 0.09 |

Readings:

- Sieve cost is essentially **linear in the number of prime passes** (32 → 440
  primes costs 1.49 s → 15.97 s, a factor 10.7 for a factor 13.75 in primes).
- The smooth rate rises only ~20× over that range while cost rises ~11×: the
  filter is doing real, non-trivially-priced work.
- Sieving to obtain `k` relations is nearly **flat in k** beyond the first few
  (8 → 128 relations: 2.91 s → 3.53 s), because survivors accumulate.

**Pair sieve vs individual sieve vs large-prime variants:** not separated. I did
not implement them and will not quote their relative costs. What the measurement
does establish is that the filter's cost is governed by the prime pass structure
and the smoothness density, neither of which is touched by any choice among those
variants at the level of a lattice constant. A large-prime or individual-sieve
change alters *which* pairs are kept, not the lattice that results, so it cannot
move the lattice-reduction constant measured in C1.

---

## C3. Polynomial choice — the naive objective is **anti-correlated** with yield

Fixed N = 412333899797 (39 bits), fixed sieve (y = 1000, box 600), **only m
varies**, which is the only degree of freedom in choosing f. All f below satisfy
`f(m) = N` exactly (base-m digit construction) and are irreducible over ℚ.

| m | coefficient mass | f (x², x, 1) | relations | rate |
|---|---|---|---|---|
| 6698 | 11616 | (−2492, −6129, −2995) | **1090** | 7.57e-04 |
| 7070 | 6352 | (−1179, −1196, −3977) | 539 | 3.74e-04 |
| 7294 | 4966 | (−456, −2059, −2451) | 476 | 3.31e-04 |
| 7405 | 8824 | (−114, −4978, −3732) | 425 | 2.95e-04 |
| 7443 | 6820 | (0, −635, −6185) | **292** | 2.03e-04 |

**The smallest-coefficient polynomial yields the FEWEST relations.** The largest
mass (11616) yields the most (1090), a factor 3.7. Coefficient mass is not the
objective; on this sample it points the wrong way. (Sample size is 5 — treat the
*sign* as suggestive, the mechanism as the finding.)

The prior round's finding is confirmed and sharpened. A naive polynomial
(`c₀ = N mod m`, other coefficients arbitrary) gave `f = x³ + x² + 2.1e19·x + 1`,
mass 4.3e5, and **zero relations at y = 5000, box 1500** — searched exhaustively.
A *narrow* search for m (a few units around N^(1/3)) gave mass 4.3e5 and **also
zero relations**. Only a **wide** search (6% either side) found usable polynomials
(mass 366–6184).

**So the suboptimality does not cost a constant — it can cost everything.** A
polynomial yielding no relations has infinite cost; no constant-factor saving
elsewhere compensates. And the search for a good f is cheap and effective: the
wide m search is a linear scan over ~2·0.06·N^(1/3) values, each a handful of
integer divisions, and it is *not* efficiently computable by the obvious proxy
(minimise coefficients), which is measurably wrong.

---

## C4. Is the constant even binding? — No; the implementation is

**Relation-lattice dimension is independent of N.** This is the linear-algebra
half of the Montgomery constant, and it does not move:

| N bits | m | relations | lattice | LLL ms |
|---|---|---|---|---|
| 32 | 1117 | 32 | (7,7) | 2.2 |
| 40 | 7441 | 32 | (7,7) | 4.2 |
| 50 | 74503 | 32 | (7,7) | 4.5 |
| 60 | 755219 | 32 | (7,7) | 1.9 |
| 70 | 7592437 | 32 | (7,7) | 1.5 |

The dimension is fixed by `d`, not by the modulus. So Montgomery's `O(n²)`
linear-algebra term is `O(d²)` — constant in N, and small in absolute terms.

**The wall-clock split** (N = 40 bits, y = 1000, box 600):

```
sieve          :   3214.47 ms   (99.91%)
lattice reduce :      2.74 ms   (0.09%)
ratio sieve/reduce = 1171.6x
```

Honest reading: on this host, filtering beats lattice reduction by ~1172×. Sieve
throughput is 0.09–0.96 M pairs/s in numpy. The sieve cost grows with N and with
y; the lattice cost does not grow with N at all. **At 1024 bits the ratio is far
more lopsided than 1172:1**, because sieving grows superlinearly in log N while
the lattice stays ~2.7 ms.

Therefore the ceiling on C1 was doubly low: the lattice step is already optimal
(C1) *and* it is 0.09% of the work (C4).

---

## Overall verdict

| target | outcome |
|---|---|
| C1 BKZ / slide-reduction on the NFS relation lattice | **No gain.** LLL/SVP = 1.0000000000 on 40/40 lattices; best β gives 1.0000000000×. |
| C2 filtering improvement touching the constant | No lattice-side effect; sieve cost governed by prime passes and smoothness density. Variants not separated (not implemented). |
| C3 polynomial choice | Mass minimisation is the **wrong** objective (anti-correlated, 5 samples). Bad f costs everything, not a constant. Optimal f is cheaply findable by wide scan. |
| C4 is the constant binding? | **No.** Sieve/reduce = 1172×; lattice dimension constant in N. |

**The best constant improvement found in this round is 1.0000000000×, i.e. none.**
Worth 0% wall-clock at 1024 bits.

The round's positive result is not a constant — it is that **the constant is not
where the time is**. A 5% shave on 1.92299 would be worth roughly 2× at 1024
bits *if* it were free to collect and *if* the lattice step were the bottleneck.
Measured here, neither holds: the lattice step cannot be improved (C1) and is
0.09% of the pipeline (C4). Effort is better spent on sieving throughput and on
polynomial selection, where C3 shows the current proxy is actively misleading.

## What I did not establish

- No BKZ measurement on a 1024-bit relation lattice (not constructible here).
- The Montgomery `N·F(x)^k` normalisation is absent (0/40 rows m-divisible), so
  C1 is on the relation lattice *before* normalisation.
- Pair sieve vs individual sieve vs large-prime variants not separated.
- **No literature claim is made.** WebSearch fabricates citations on this host and
  publisher sites 403, so I cite nothing. Every number above is from this host,
  with the sample size stated.

## Files

- `exp/exactsvp.py` — certified exact SVP enumerator (gold standard)
- `exp/lll_self_test.py` — self-test, exits 0 (run this first)
- `exp/nfs_lattice.py` — polynomial construction, splitting primes, norms
- `exp/run_c1_old.py` — GNFS sieve + relation finder (used by all experiments)
- `exp/run_c1.py` — per-configuration LLL/BKZ/SVP table
- `exp/run_c1_stats.py` — the 40-lattice statistics (C1 headline)
- `exp/run_c23.py` — C2 and C3 measurements
- `exp/run_c4.py` — C4 implementation-layer breakdown

Reproduce: `cd factor-scratch/r48/exp && python3 lll_self_test.py && python3 run_c1_stats.py && python3 run_c23.py && python3 run_c4.py`
