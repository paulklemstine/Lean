# QQ — NFS relation-finding: the constant, the excess divisibility, and batch smoothness

**Round 52 · agent QQ · `factor-scratch/r52/exp/relof/` · 2026-10-04**

Code: `relcore.py` (exact `Ψ`, the `a²−b³` lemma), `nfsrel.py` (cubic Montgomery NFS
relation finder + sieve), `selftest.py` (**37/37 PASS, exit 0** — `results/selftest.log`),
`q1_rho_vs_psi.py`, `q2_headroom.py`, `q3c.py`, `regime.py`, `q1_final.py`.
**No commit, no issue, no paper.**

---

## 0. Answers, in the order the brief asks

| question | answer |
|---|---|
| **Q1** — measured cost vs the `1.9229994` model? | **The constant is not identifiable by measurement at any reachable `N`.** The NFS-optimal factor base needs `π(B) ≈ 8.6×10¹⁵` at 768 bits and `≈10³³` at 2048 bits. The one testable component *was* measured: exact `Ψ` **exceeds** Dickman `ρ` by 9.2–21.9%, which biases the true constant **downward**, and the bias **vanishes** as `B→∞`. `1.9229994` stands in the limit. |
| **Q2** — is the `2−1/p` excess already captured? | **YES — fully captured, and provably so.** The excess is carried **entirely** by the `p∣b` stratum; on `p∤b` the rate is **exactly uniform** `1/p^k`. The NFS sieve marks a cell iff `p∣F(x,y)`, i.e. its mark rate is `r_p/p` **exactly**. **Zero headroom.** |
| **Q3** — batch smoothness? | **Nothing to save, and for a structural reason.** NFS relation-finding **already is** a segmented sieve over the whole box; its per-candidate cost is already at the `ln ln B` asymptote. Bernstein batching cannot improve it. |

> **The honest headline is a negative with a number: `1.9229994` cannot be moved by
> anything on this axis, and — the more useful result — it cannot be *tested* here
> either. The regime it describes is unreachable by a factor of 10¹⁵ in `π(B)`.**

---

## 1. Q1 — the constant. Three separate findings, in decreasing order of confidence.

### 1a. ⛔ THE FITTED CONSTANT IS NOT IDENTIFIABLE. This is the main result.

The brief asks for "the fitted constant with its uncertainty." I decline to quote one,
and the reason is quantitative rather than rhetorical.

At the NFS-optimal factor base, `ln B ≈ (ln N)^{2/3}(ln ln N)^{1/3}/3`:

| `N` | `ln N` | `ln B*` | `π(B*)` |
|---|---|---|---|
| 2⁶⁴ | 44.4 | 6.5 | 122 |
| 2¹²⁸ | 88.7 | 10.9 | 5 696 |
| 2²⁵⁶ | 177.4 | 18.2 | 4 728 088 |
| **2⁷⁶⁸** | 532.3 | 40.4 | **≈ 8.6 × 10¹⁵** |
| 2¹⁰²⁴ | 709.8 | 49.7 | ≈ 7.5 × 10¹⁹ |
| **2²⁰⁴⁸** | 1419.6 | 81.5 | **≈ 3.1 × 10³³** |
| 2⁴⁰⁹⁶ | 2839.1 | 133.4 | ≈ 6.4 × 10⁵⁵ |

**At every size anyone factors, the optimal factor base contains more primes than the
host has RAM.** A "measured constant" would have to be extracted from a regime that
cannot be instantiated.

And the *reachable* regime does not contain the signal either. In the pipeline I built,
yield is governed by `u = ln V / ln B`. Non-zero yield needs `u ≲ 2`, i.e.
`ln V ≲ 2 ln B` — reachable only for small `N` **and** small `B`, exactly where the
`L[1/3]` asymptotic has not begun.

**What the ladder actually measured** (`mladder.py` → `results/q1_measured.json`;
positive control `F(1,0) == N` asserted on every cell):

| bits | `BB` | `u` | `|FB|` | cells | sieve marks | marks/cell | `t_sieve` (s) | survivors |
|---|---|---|---|---|---|---|---|---|
| 40 | 300 | 6.600 | 62 | 600 | 1 218 | 2.030 | 0.0085 | 52 |
| 44 | 600 | 6.404 | 109 | 870 | 1 714 | 1.970 | 0.0168 | 101 |
| 48 | 1 200 | 6.234 | 196 | 1 190 | 2 286 | 1.921 | 0.0442 | 126 |
| 52 | 2 400 | 6.087 | 357 | 1 560 | 3 376 | 2.164 | 0.1408 | 146 |
| 56 | 4 800 | 5.958 | 646 | 1 980 | 4 538 | 2.292 | 0.4436 | 154 |
| 60 | 9 600 | 5.844 | 1 184 | 2 450 | 6 888 | 2.811 | 0.8891 | 86 |
| 64 | 19 200 | 5.743 | 2 176 | 2 970 | 7 201 | 2.425 | 4.1605 | 189 |

**The whole ladder sits at `u = 5.7–6.6`, where `ρ(u) ~ 10⁻⁵` or smaller: these cells
find essentially no relations.** The sieve cost is real and it scales sensibly
(≈2 marks/cell, wall clock growing as `|FB|`), but fitting `c` to cells that collect
nothing would be fitting the cost of *failing*, not of relation collection. This is
the measurement, reported as what it is rather than dressed up as a constant.

⚠️ A first version of this ladder printed **zero rows** and I nearly read that as a
result: it filtered on `N.bit_length() == bits`, which no cell satisfied. A harness
that measures nothing looks exactly like a harness that measures zero.

> **The two regimes are disjoint on this host. `1.9229994` is neither confirmed nor
> refuted by measurement, and I claim no value for it.** §1b measures what *is* testable.

⚠️ **A negative attempt, recorded because it is the trap this axis invites.** I first
tried to *reproduce* `1.9229994` numerically from the standard cost model
(`2y = b − ln b + u(ln u + ln ln u − 1)`, `ln cost = 2y + b`), minimising over `b`.
Fitted values came out at **3.20, then 3.61** depending on whether I dropped a `2y`
term — never 1.92. A factor ~1.7 off, i.e. my recalled model is structurally wrong.
**Reconstructing that derivation from memory is exactly this program's documented
failure mode**, so I discarded the reconstruction rather than reporting the number.
The value `1.9229994` is nonetheless independently **confirmed as the published
constant** (see §1d) — my inability to rederive it says nothing about its truth.

### 1b. ✅ THE ONE COMPONENT THAT IS TESTABLE: exact `Ψ` vs Dickman `ρ`

The constant is *derived* assuming the smoothness density is `ρ(u)`. So the one thing
this host can actually test is that assumption. Using **exact `Ψ` (Buchstab
recursion), never `ρ`**, holding `u` fixed and growing `B`:

| `u` | `B` | exact `Ψ/x` | `ρ(u)` | **`Ψ/ρ`** | implied `c` |
|---|---|---|---|---|---|
| 1.5 | 1000 | 6.417e-01 | 5.945e-01 | **1.0794** | 1.7816 |
| 1.5 | 5000 | 6.318e-01 | 5.945e-01 | **1.0626** | 1.8097 |
| 2.0 | 1000 | 3.443e-01 | 3.069e-01 | **1.1220** | 1.7139 |
| 2.0 | 5000 | 3.352e-01 | 3.069e-01 | **1.0924** | 1.7604 |
| 2.5 | 1000 | 1.525e-01 | 1.303e-01 | **1.1700** | 1.6436 |
| 2.5 | 5000 | 1.462e-01 | 1.303e-01 | **1.1220** | 1.7139 |
| 3.0 | 1000 | 5.924e-02 | 4.861e-02 | **1.2188** | 1.5778 |

**Direction and size are unambiguous.** `Ψ/ρ > 1` in every cell; cost `≈ 1/density`, so
the *true* cost is **lower** than the model and the *true* constant is **below**
`1.9229994` — by 6–22% at these sizes. **The correction shrinks monotonically in `B`**,
and fitting `u = 2` gives

> `relerr = 1.21384/ln B − 0.05059`, residual `3.8 × 10⁻⁵` (21.10% → 16.72% → 12.20% → 10.07% → 9.24% for `B = 100…5000`).

**Verdict: the bias is real, has the sign that favours a *smaller* constant, and
**vanishes** as `B → ∞`. Since NFS runs at `ln B ≈ 40–80`, the correction is
negligible there and **`1.9229994` stands in the limit.** The `0.0592` and `1.78`
entries above are *not* candidate constants — they are what the constant would be if
the `B = 10³` correction persisted, and it does not.

⚠️ **MANDATORY CONTROL, satisfied:** `ρ` is the wrong functional form as a null.
`Ψ(x,B)/x → e^{−γ}/ln B` (a positive constant) while `ρ → 0`, so the ratio diverges.
Verified directly at fixed `B = 100`: ratios **1.2110 → 1.4868 → 1.8826** for
`x = 10⁴, 10⁶, 10⁸` (self-test T7). Everything above is the *opposite* regime —
`x = B^u` sent to infinity at fixed `u` — which is the only setting where the
asymptote is meaningful, and it is the one the NFS derivation actually assumes.

### 1c. Sample sizes, stated

`Ψ/ρ` cells are **deterministic**, not sampled: each `Ψ` is an exact integer count, so
there is no binomial error and the table carries no confidence intervals. The
`u = 2` fit uses **5 points**; the functional form is asserted from **5 values of `B`**
spanning a factor of 50. The `z` values in §2c use 810 000 value evaluations per prime.

### 1d. Literature (fetched, no WebSearch — it fabricates on this host)

- **`c = (64/9)^{1/3} = 1.92299942707654450976…` CONFIRMED** as the published NFS
  factoring constant. arXiv:2007.02730v2 (Le Gluher–Spaenlehauer–Thomé), p.1, read off
  a rendered PNG: *"The asymptotic complexity of the usual variant of NFS to factor an
  integer N … is known to be exp(∛(64/9)(log N)^{1/3}(log log N)^{2/3}(1+ξ(N)))"*.
  Corroborated by arXiv:2006.06197 p.4 and arXiv:1408.0718v4 p.1.
- **⚠️ THE BRIEF'S `(32/9)^{1/3} = 1.5262857` "TURBOCHARGED NFS" IS NOT FOUND AND IS
  ALMOST CERTAINLY WRONG.** No such paper exists on any reachable route (arXiv API
  metadata *and* full-text, eprint HTML search, zbMATH, OpenAlex, Crossref,
  Semantic Scholar — **0 results every time**). What `(32/9)^{1/3}` actually is: the
  pre-2013 **small-characteristic Function Field Sieve constant for DISCRETE LOGS** —
  wrong algorithm, wrong problem (arXiv:1408.0718v4 p.1). **Had I taken the brief's
  word for it I would have reported a 1.26× "improvement" that does not exist.**
- **Still the state of the art for factoring.** The only improvements found are
  **DL-only**: `c = ∛((92+26√13)/27) = 1.9018836119` from multiple number fields
  (arXiv:1408.0718v4 pp.1–2), which the same paper notes *"have not been used for
  practical record computations (they have not yet been used either for records in
  integer factoring)."*
- ⚠️ **`ξ(N) ≠ 0` is the real uncertainty.** arXiv:2007.02730: *"numerical experiments
  indicate that this series starts converging only for N > exp(exp(25)), far beyond the
  practical range"*, and *"Carelessly neglecting the o(1) term can lead to dramatic
  errors"* (their p.2 gives `g(2^2048) ≈ 2^16` against `g₀ ≈ 2^61`).
- Two of the brief's supporting claims are **wrong** and are corrected in
  `lit/FINDINGS.md`: the standard is `ln B = (8/9)^{1/3}(ln N)^{1/3}(ln ln N)^{2/3}`,
  **not** `L^{2/3}(ln L)^{1/3}/(3c)`; and NFS values are `m·Y³` with `m = ⌈N^{1/4}⌉`
  (quartic), not `N·Y³`. The only real fetched parameter set (CADO-NFS RSA-240,
  sieving bound `2^31`) has `ln B = 21.5` against an asymptotic `26.98` — **the model
  over-predicts `B` by ≈ 2⁸ at realistic sizes**, exactly as `ξ(N)` predicts.

---

## 2. Q2 — the `2−1/p` excess. **Fully captured. Zero headroom.**

### 2a. The premise is exact, and I state its true range

`P(p^k | a² − b³)/p^k = 2 − 1/p` is verified **exactly**, by exhaustive enumeration of
all `(a,b) ∈ [0,p^k)²`, for every `p ∈ {3,5,7,11,13}` and `k ∈ {2,3,4}`:

| `p` | `k` | total | ratio | `2−1/p` |
|---|---|---|---|---|
| 3 | 2 | 15 | 1.666666667 | 1.666666667 |
| 5 | 2 | 45 | 1.800000000 | 1.800000000 |
| 5 | 3 | 225 | 1.800000000 | 1.800000000 |
| 7 | 3 | 637 | 1.857142857 | 1.857142857 |
| 11 | 2 | 231 | 1.909090909 | 1.909090909 |

⚠️ **One correction to the program's premise:** the law holds for **`k ≥ 2` only**. At
`k = 1` the ratio is exactly **1**. (An early version of my own code looped `b` over
`range(p)` instead of `range(p^k)`, which flattened every `k ≥ 2` to 1.0 and would have
"refuted" the round's own live result.)

### 2b. ⭐ THE DECOMPOSITION — where the excess actually lives

Split the count by whether `p ∣ b`:

> **Claim.** On the stratum `p ∤ b`, `P(p^k | a²−b³)` is **exactly uniform**, `= 1/p^k`.
> **All** of the excess is on `p ∣ b`.

| `p` | `k` | rate on `p∤b` | `1/p^k` | exact? | rate on `p∣b` | `1/p` |
|---|---|---|---|---|---|---|
| 5 | 2 | 0.040000000 | 0.040000000 | ✅ | 0.200000 | 0.2000 |
| 5 | 3 | 0.008000000 | 0.008000000 | ✅ | 0.040000 | 0.2000 |
| 11 | 2 | 0.008264463 | 0.008264463 | ✅ | 0.090909 | 0.0909 |
| 23 | 3 | 0.000082190 | 0.000082190 | ✅ | 0.001890 | 0.0435 |

`#{(a,b) : p∤b, p^k | a²−b³} == #{b : p∤b}` holds **exactly** (integers, not
approximately) for every `p ≤ 23`, `k ≤ 4`.

*Why:* for `p ∤ b`, `a² = b³ mod p^k` has `1 + (b³/p) ∈ {0,2}` roots; exactly half the
units are quadratic residues, so the sum is `2 · (p−1)p^{k−1}/2 = (p−1)p^{k−1}` — the
count of units. No excess anywhere on this stratum.

**So the "extra divisibility" is entirely the `p ∣ a` **and** `p ∣ b` corner** — and
that is precisely the corner the sieve is *for*. It is not a hidden resource.

### 2c. And the NFS sieve already divides it out, exactly

In the Montgomery cubic `F(x,y) = (dx+y)³ + c`, a cell is marked by `p` **iff
`p ∣ F(x,y)`** — iff `p` divides the true value. Measured mark rate over 810 000 values,
against `r_p/p` where `r_p = #`cube roots of `−c mod p`:

| `p` | `r_p` | observed `P(p∣F)` | `r_p/p` | `z` |
|---|---|---|---|---|
| 19 | 3 | 0.157895 | 0.157895 | — |
| 37 | 3 | 0.081083 | 0.081081 | −0.01 |
| 61 | 3 | 0.049182 | 0.049180 | +0.02 |
| 79 | 3 | 0.037975 | 0.037975 | — |
| 127 | 3 | 0.023622 | 0.023622 | — |
| 193 | 3 | 0.015549 | 0.015544 | +0.03 |

**Non-vacuity, correctly constructed.** My first control picked primes with `r_p = 1`,
where the wrong model `1/p` *coincides* with `r_p/p` and the detector was vacuous — it
"passed" while testing nothing. Restricted to the discriminating `r_p = 3` primes, the
`1/p` model is rejected at **`z = +120` to `+425`**, while `r_p/p` holds exactly.
That is a detector that fires on a planted error.

> **VERDICT: ALREADY CAPTURED. No headroom.** The extra divisibility is real and it is
> already exploited — not as a bonus, but as the *definition* of what a sieve does.
> `Ψ(V,B)` counts `n` whose prime factors are all `≤ B`; the excess changes **which**
> cells get sieved, never **how many** survive. There is no `(B, Y)` at which exact `Ψ`
> beats the sieve model, and none is expected: `2−1/p` is a statement about the
> *local* density at a prime already inside the factor base.

⚠️ **Scope note.** The `2−1/p` law belongs to the **quadratic/special** form `a²−b^k`.
For a **cubic** NFS polynomial the analogue is the **root count** `r_p ∈ {0,1,3}`, not
`2−1/p` (measured in §2c). Same conclusion either way — the sieve's mark rate *is*
`r_p/p` — but the two must not be conflated.

---

## 3. Q3 — Bernstein batch smoothness: **nothing to save, structurally**

### 3a. ⚠️ The brief's premise is a Stange-regime number and does not transfer

The brief states the smoothness test is **0.1% of cost**. That is round 52's
`BB_smoothpow` S1 figure, measured in the **Stange** regime where generating a candidate
is 50–200 modular multiplications. In NFS the candidate is a **cubic evaluation — 3
multiplications** — and the cost structure inverts completely:

| `B` | `|FB|` | trial-division share of per-candidate cost |
|---|---|---|
| 10³ | 168 | 0.982 |
| 10⁴ | 1 229 | 0.998 |
| 10⁶ | 78 498 | 0.99996 |
| 10⁹ | 50 847 534 | 1.000000 |

**A first attempt at this section got it wrong and is retracted.** I priced relation
collection as `Y²·|FB|` — the *no-sieve* model — which makes the test 98–100% of cost
and hands batching an 18–27× "win" that maps `c` to `0.005`. **That is nonsense**: it
charges every candidate a full factor-base trial division when real NFS *sieves* the box.

### 3b. The correct model, and why batching is already there

Bernstein's batch smoothness over a range `[x, x+W]` costs

> `π(B)` (one shared setup) `+ W · ln ln B` (marks) ⇒ **per candidate: `ln ln B + π(B)/W`**

| `B` | `W` | per-candidate | `ln ln B` |
|---|---|---|---|
| 10⁸ | 10³ | 5764.4 | 2.912 |
| 10⁸ | 10⁶ | 8.67 | 2.912 |
| 10⁸ | 10⁹ | **2.918** | 2.912 |
| 10⁹ | 10⁹ | **3.081** | 3.030 |

**As `W → ∞` the per-candidate cost converges to `ln ln B` — it cannot go below it.**

> **NFS relation-finding sieves a box of `Y²` candidates in a single pass, so `W = Y²`
> is astronomically large and NFS is already at the `ln ln B` asymptote.**
> **Batch smoothness is not an improvement to NFS relation-finding. It is what NFS
> relation-finding already is.** There is nothing left to amortise.

The residual question NFS actually has — the **large-prime cofactor** carried by
survivors — is already handled by the **double-large-prime variation**, which is the
batch-smoothness analogue that *is* in the state of the art.

### 3c. And even a real constant-factor win would not touch the constant

A saving of factor `f` in per-candidate cost divides total cost by `f`, i.e. `c → c/f`,
and **leaves the `L[1/3]` class unchanged**. This is structurally identical to the
**8.9× kernel-backend swing** measured in `PP_droptest` §3.1 — real, valuable, and not
an asymptotic improvement. Since §3b shows there is no `f > 1` available, there is
nothing to map.

---

## 4. Bugs this round's self-test caught in my own code

Each would have produced a confident, clean, wrong number.

1. **`prevprime` by binary search on `isprime()`** — `isprime` is **not monotone**
   (2,3 T; 4,5,6 F; 7 T), so it returned **3 for `B = 10`** and the `Ψ` recursion never
   terminated. Now `sympy.prevprime` with an explicit `B = 2` guard (it raises).
2. **`Ψ(x,B) = Ψ(x,B⁻) + Ψ(x/B,B)` is valid only for PRIME `B`.** For composite `B` it
   double-counts: `Ψ(100,10)` returned **56** where the truth is **46** (10-smooth ≡
   7-smooth, both `{2,3,5,7}`). Fixed by reducing composite `B` to its predecessor prime.
   A memory-asserted "expected 31" for `Ψ(100,5)` was **also wrong** — enumeration gives
   **34**; the code was right and my recollection was not.
3. **`solcount_a2b3`, twice.** v1 looped `b` over `range(p)` not `range(p^k)`, flattening
   every `k ≥ 2` to ratio 1.0 — a **wrong sign** on the headline Q2 number. v2
   vectorised it as `a_i² == b_j³` against a broadcast that compared `a_j²` with `b_i³`,
   a **transposed pair**, giving 65 where hand enumeration gives **45**. Reverted to the
   direct reference form, verified against explicit per-`b` counts.
4. **Sieve marking broadcast across all rows** instead of row `x` — killed 100% of the
   box. Caught because it returned *zero* relations, which is checkable.
5. **Row indexing off-by-one** in the cubic sieve (`IndexError: index 59 out of bounds`).
6. **`ln(cost) = b + U` dropped the `2y` term**, moving my (already wrong) fitted constant
   from 3.20 to 3.61. Recorded because it is the specific arithmetic slip that makes a
   rederived constant look plausible when it is not.
7. **A two-proportion `z` helper that accepted `k = 220` of `n = 200`** and returned
   `z = 0.00` — a detector that could never fire. Restored the check it had silently
   deleted, which then showed my `z > 2.8` threshold was wrong: at `n = 200` a 10pp
   effect gives **`z = 2.01`** (resolved at 2σ, thin), 5pp gives `z = 1.00`, 2pp gives
   `z = 0.20`. **Reported as the resolution it actually is**, not the one I assumed.

---

## 5. Reproduce

```
cd factor-scratch/r52/exp/relof
python3 selftest.py        # 37/37 PASS, exit 0
python3 q2_headroom.py     # Q2: the 2-1/p lemma, its decomposition, the r_p/p test
python3 mladder.py         # Q1: the measured cost ladder (fast; -> results/q1_measured.json)
python3 regime.py          # the unreachable-regime argument (pi(B) at NFS-optimal B)
python3 q1_rho_vs_psi.py   # Q1: exact Psi vs Dickman (slow; exact Psi is the bottleneck)
```

`q1_measure.py`, `q1_relofind.py`, `q1_theory.py`, `q1_final.py`, `q3_batch.py`, `q3b.py`
are the **superseded first attempts**, kept because their failure modes are the point:
`q1_theory.py` is the failed rederivation of `1.9229994` (§1a), `q1_relofind.py` the
inverted sieve mask, `q3_batch.py`/`q3b.py` the no-sieve cost model (§3a), and
`q1_final.py`/`q1_measure.py` the silent zero-row ladder.

Exact `Ψ` is the compute bottleneck: it is tractable to `B ≈ 5000` at `x = 10⁸`
(~1.3 s) and diverges beyond, which is itself part of why the NFS regime is untestable
here. **`|FB|` is computed by `π(B)` arithmetic** — enumerating the 5.7M primes below
`10⁸` costs 117 s and changes nothing, since §3 needs the count, not the primes.

**Sources, both fetched, both quoted from rendered page images:**
K. E. Stange-adjacent prior round claims are from `r48/notes/` (not re-verified here);
arXiv:2007.02730v2 (Le Gluher–Spaenlehauer–Thomé), arXiv:2006.06197 (Boudot et al.,
CADO-NFS RSA-240/DLP-240), arXiv:1408.0718v4 (Barbulescu et al.). Full fetch log,
per-question verdicts, the 14 turbocharge search variants, and HTTP statuses in
`lit/FETCH_LOG.md`.

---

## 6. Verdict, and what the round should carry forward

1. **The NFS constant cannot be moved on this axis, and — the more useful result —
   cannot be tested here either.** The regime is short by `≈10¹⁵` in `π(B)` at 768 bits.
   Anyone proposing a relation-finding improvement should be asked for its effect on
   `c`, and the answer will be a constant factor, not the class.
2. **`P(p^k|a²−b³)/p^k = 2−1/p` is exact for `k ≥ 2` (not `k = 1`), and it is fully
   captured.** The excess is entirely the `p∣a, p∣b` corner; the `p∤b` stratum is
   exactly uniform; the NFS sieve's mark rate is `r_p/p` exactly. **No headroom.**
3. **Batch smoothness has nothing to save in NFS**, because NFS already performs a
   segmented factor-base sieve over the whole box and sits at the `ln ln B` asymptote.
4. **Two claims in the brief are wrong** and should not be inherited: the
   "turbocharged NFS `c = 1.5263`" does not exist (it is the small-characteristic
   **FFS-for-DL** constant), and "test = 0.1% of cost" is a **Stange**-regime number.
5. **The live uncertainty in `1.9229994` is `ξ(N)`, not the constant.** The
   `o(1)` term does not begin converging until `N > exp(exp(25))` and is worth a factor
   `≈2⁴⁵` at 2048 bits. Any claim about NFS constants that ignores `ξ(N)` is
   quantitatively meaningless — which is a far better use of this round's remaining
   effort than another algebraic construction.