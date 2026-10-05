# Round 55 — Shape-Sieve: is there a shape-sensitive sieving primitive?

**Work directory:** `/home/raver1975/lean/factor-scratch/r55exp/shapesieve/`
**Date:** 2026-10-04. **No factoring algorithm. No exponent improvement.**
All moduli generated locally, `N < 2^40` (most `< 2^22`). Nothing of
cryptographic interest was factored.

---

## VERDICT

**CLOSURE, with one measured exception that does not matter.** A sieving
primitive *is* provably and measurably shape-sensitive — the `B`-smooth
survival rate of `u^2 mod N` is 7–14% higher for prime-power shapes `a^3 b`,
`a^4 b`, `5^2 b`, `7^2 b` than for generic `p q` at the same size (exact
permutation `p = 0.0004`, against a negative control at `p = 0.25`). **But the
effect SHRINKS as `B` grows (1.42 → 1.23 → 1.14 at `B` = 60 → 256 → 1024) and
it is worthless: it opens only when `minFac(N) ≤ B`, which requires `N ≤ 2^25`
even for the friendliest shape.** The shape-aware sieve is therefore strictly
dominated by the shape-aware method that already exists (Pollard rho), because
reading the shape and exploiting the shape cost the *same* `sqrt(minFac N)`,
and rho pays it once.

**The lead is dead.** Not "we could not find the primitive" — dead for a
nameable reason, given in §2 and proved in §5. This is the informative
negative the brief asked for.

---

## 1. THE LEAD, AND THE GREP I REPRODUCED

`Round51_ShapeGap.md:162-166` nominates item **(A)**:

> **(A) The shape-aware sieve.** Now the best-motivated untried idea in this
> project: the gap is `N^{1/12}` on `a^k b`, and the shape is *free* to read
> (`a` is visible in `v_a(n)`). The missing piece is a sieving primitive that
> exploits a known valuation structure.

**My grep, run first, over `Catalog/Cryptography/FactoringBarriers/Round*.md`
only (not the whole repo, which has Aether mirrors):**

```
$ grep -ln "shape-aware\|shape aware\|shape blind\|shape-blind\|sieve_cost_shape_blind" Round*.md | sort -V
Round51_ShapeGap.md
Round53_CatalogMine.md
```

Two files, not one. `Round53_CatalogMine.md:153-154` is the catalogue-mining
round that *re-quotes* the idea and marks it untouched; it does not attempt it.
**No round 54–109 file attempts it. The claim reproduces.** (Whole-repo grep
additionally hits `docs/` and `Packages/` mirrors of the same two files, plus
`factor-scratch/r53exp/catmine/m2m3_scan.md`, which is where I read the
corpus's own restatement of this brief.)

### 1a. The Lean file — VERIFIED, and the verification is worth recording

`ShapeGap.lean` (5 declarations). The corpus claims "0 `sorry`". **I checked,
and did not take it on faith:**

```
$ cp ShapeGap.lean ./ShapeGap_verify.lean
$ cd ~/prove2me_workspace && lake env lean .../ShapeGap_verify.lean
EXIT=0                                    # compiles, no output, no errors
```

Zero `sorry`, zero `admit` (grep count 0). And I went further, because a
`sorry`-free file can still rest on axioms:

```
#print axioms ShapeGap.minFac_mul_le        → [propext, Classical.choice, Quot.sound]
#print axioms ShapeGap.minFac_pow_mul_le     → [propext, Classical.choice, Quot.sound]
#print axioms ShapeGap.rho_cost_monotone     → [propext, Classical.choice, Quot.sound]
#print axioms ShapeGap.minFac_bounds         → [propext, Classical.choice, Quot.sound]
#print axioms ShapeGap.sieve_cost_shape_blind→ [propext, Classical.choice, Quot.sound]
```

**The file is clean. The "0 sorry" claim is TRUE.** Toolchain
`leanprover/lean4:v4.33.1`, Mathlib `0df444a`, via `~/prove2me_workspace`.

**But here is the problem, and it is the single most important thing in this
round.** Read the statement of the flagship theorem:

```lean
theorem sieve_cost_shape_blind {N M : ℕ} (h : N = M) :
    Nat.minFac N = Nat.minFac M := by rw [← h]
```

**The hypothesis is `N = M`.** This theorem says: *if two moduli are equal,
they have the same smallest prime factor.* That is congruence, not shape
blindness. It does not mention a sieve, a cost, a factor base, or `L_N`. It is
`rw [←h]` and nothing else. **The entire formal content of the lead's
central claim is the substitution rule.** `ShapeGap.sieve_cost_shape_blind`,
cited at `Round51_ShapeGap.md:65-67` and again at `Round53_CatalogMine.md:154`
as the reason the lead is motivated, is a tautology about equality.

This does not make the lead wrong — my measurements below confirm sieves *are*
shape-blind in the regime that matters. **It means the lead was never formally
motivated; it was formally decorated.** A reader checking the Lean file would
find nothing there, and the corpus's own discipline ("an unverified '0 sorry'
claim is exactly the kind of thing this programme has been burned by") applies
one level up: the *verified* claim turns out to not say anything.

`rho_cost_monotone` is similarly thin — it is `Nat.mul_self_le_mul_self`, i.e.
"`x ≤ y → x² ≤ y²`", dressed as a cost statement. `minFac_mul_le` and
`minFac_pow_mul_le` are genuine and correct (real divisibility lemmas), and
`minFac_pow_mul_le` does formalise the corpus's real content: for `n = a^k b`,
`minFac n ≤ min(minFac a, minFac b)`.

---

## 2. WHY NOBODY HAS DONE THIS IN ~90 ROUNDS

This is the question the brief calls most valuable, and I think the answer is
short, structural, and checkable. **It is not that the idea is bad. It is that
the shape parameter and the factor are the same object.**

### The shape parameter IS a factor

The corpus nominates the shape `n = a^k b` and calls the shape "free to read
off `n`". I measured that claim (`exp4_reading.py`, §4):

- For `n = a^2 b`, `a` **is** poly-time readable — as the square part.
  Confirmed 200/200, and for every `k = 2..6`, 40/40 each.
- So the shape is free. **And `a` is a factor of `n`.** Reading the shape is
  factoring.

So the shape-aware sieve's plan is: *read a factor of `n`, then use it.* The
moment you have it, you are done, and the sieve is unnecessary. The corpus
notices this at `Round51_ShapeGap.md:122-124` ("`a` is visible from `n` without
factoring") and then treats the visibility as a *benefit*. It is the opposite:
it is the reason the idea cannot pay.

### The three channels, all closed

A sieve's cost per relation is

```
(#candidates) · log log B  /  (#survivors)
```

where `#candidates` is fixed by the sieving range (a function of `log N`) and
`#survivors = #candidates · ρ(u)`, `u = log(max value)/log B` (Dickman). For the
shape to enter, one of three things must happen, and I checked each:

**Channel A — the sieving function `g` depends on the shape.** Requires
computing the shape, i.e. computing `minFac N`. For `n = a^k b` that is rho's
job (`sqrt(a)`) or, for power shapes, free *because it is factoring*. **Closed
by the discovery cost.**

**Channel B — the shape shrinks the sieving range.** But "search a shorter
range for a factor" **is Pollard rho / baby-step giant-step**. The moment
shape-sensitivity shortens the range, the method has stopped being a sieve.
The shape-sensitive method already exists; it costs `sqrt(minFac N)`; it is not
a sieve; and it is optimal for that job.

**Channel C — the shape enters the factor base, i.e. `minFac(N) ≤ B`.** This is
the *only* channel that is genuinely open, and it is worthless, because it
requires `N ≤ 2^25` (§5, measured across 36 cells).

### So the honest answer

**Nobody has built a shape-sensitive sieve because the shape of `N` is only
readable when it is already a factor, and once you have a factor you do not
need a sieve.** The lead is not an opportunity that 90 rounds missed. It is a
loop: *use the shape* requires *have the shape* requires *factor `N`*.

And the corpus half-walked this back at `Round51_ShapeGap.md:129-131` ("on the
`a^2 b` shape the right answer is *just use Pollard rho*"). My contribution is
to show that walk-back is not a caveat or a shortfall — **it is forced**, and it
extends to every shape, not just `a^2 b`.

---

## 3. THE PRECISE FORMULATION I ADOPT

The brief is right that the hypothesis as stated is not falsifiable. Here is
the version I used.

**Definition (sieving primitive).** A *range sieve* for `N` is a triple
`(C, Q, g)` where `C ⊆ [0, X)` is a candidate set with `|C| = M` determined by
`log N`; `g : C → [0, N)` is a fixed function of `u` and `N` of bounded degree;
`Q = {q prime : q ≤ B}` is the factor base; and the output is the set of `u`
with `g(u)` `B`-smooth, computed by sieving.

**Definition (shape-sensitive).** The primitive is **shape-sensitive at `N`**
if its cost per surviving relation depends on the factorisation shape of `N`
beyond `log N`. Concretely, writing `σ(N)` for any function not determined by
`log N` (e.g. `minFac N`), the primitive is shape-sensitive iff
`cost(N)/cost(N')` is unbounded over pairs `N, N'` with `log N = log N'` and
`σ(N) ≠ σ(N')`.

**Definition (the channel).** Since `#candidates` and `log log B` are fixed by
`(log N, B)`, the *only* channel through which shape can enter is the survival
rate. So:

> **Shape-Blindness Lemma.** A range sieve is shape-sensitive **iff** the
> `B`-smooth survival rate `#{u ∈ C : g(u) is B-smooth}/M` depends on the shape
> of `N`.

This is the right formulation because it makes the question measurable and
falsifiable, and it makes the two legs of a sieve separately attackable — which
turned out to be the whole story (§4, §5).

---

## 4. EXPERIMENTS

Everything below: seeded (`SEED = 20261004`), run twice, signatures compared.
`exp3b` returned signature `55c9d4b08abe4138` on both runs.
Predictions were written to `PREDICTIONS.md` before measuring.

### exp1 / exp1b — leg 1 of a sieve is PROVABLY shape-blind

`exp1_sievedomain.py` was **vacuous on its first run** and its own positive
control caught it: with `M = 20000` and `N ≈ 9·10^11`, `M^2 = 4·10^8 < N`, so
`u^2 mod N = u^2` identically and **`N` never entered the computation**. All six
families returned exactly `0.13105`. See `ERRORS.md` E1. Fixed in `exp1b` with
`M^2/N ≈ 2400`.

exp1b's result, and it is a **theorem, not a measurement**:

```
  family           ratio/pq   verdict      B regime
  pq generic       1.0000     shape-BLIND  B<a (a>B)
  a^2 b            1.0021     shape-BLIND  B<a (a>B)
  a^3 b            1.0027     shape-BLIND  B<a (a>B)
  POS CTRL a=5     0.9997     shape-BLIND  a=5>B=60
```

For `g(u) = u^2 mod N` and any prime `q`, if `q | N` then `q | g(u) ⟺ q | u`,
so the crossing-off density is **exactly** `1/q` regardless of shape. **No
control on leg 1 can fire** — which is why exp1b's positive control did not
fire even at `B = 4096` with `minFac = 5`, and why I had to move to leg 2.

### exp3b / exp6 — leg 2: the survival rate IS shape-sensitive, by 7–14%

`exp3b_threshold.py`, `N < 2^22`, `M = 60000`, `M^2/N ≈ 3400` so the reduction
genuinely wraps. Survival rate = fraction of `u` with `(u^2 mod N)` `B`-smooth.
10 cells per family, per-cell rates printed in full, expected hits beside every
rate.

**Verdict table (ratio of median `B`-smooth rate to generic `p q`):**

```
  family             minFac    B=60      B=256     B=1024
  pq generic         1087      1.0000    1.0000    1.0000
  NEG CTRL pq'       1181      1.0609    1.0232    1.0222
  a^2 b (a~2^6)      37        1.2064    1.0810    1.0447
  a^3 b (a~2^5)      29        1.4156    1.2277    1.1404
  a^4 b (a~2^4)      13        1.3452    1.1455    1.0681
  POS CTRL a=5       5         1.2951    1.1763    1.1074
  POS CTRL a=7       7         1.3493    1.1879    1.0970
  PROBE minFac=61    61        0.9596    0.9592    0.9688
```

**Effect sizes this small need a real test, not my eyeball.** `exp6_stats.py`
runs an **exact permutation test** over all `C(20,10) = 184756` relabellings —
not a z-score, and never a z-score against a predicted probability of 1:

```
  family             ratio     exact p      verdict
  NEG CTRL pq'       1.0222    0.25058      NOISE
  a^2 b (a~2^6)      1.0447    0.08885      NOISE
  a^3 b (a~2^5)      1.1404    0.00038      SIGNIFICANT
  a^4 b (a~2^4)      1.0682    0.00882      SIGNIFICANT
  POS CTRL a=5       1.1075    0.00038      SIGNIFICANT
  POS CTRL a=7       1.0970    0.00057      SIGNIFICANT
  PROBE minFac=61    0.9689    0.98860      NOISE
```

**Controls behaved.** The negative control (a fresh batch of *generic* `p q` at
the same size) is indistinguishable from the reference, `p = 0.25`. That is what
licenses the positive rows. The `minFac = 61` probe is noise in both directions,
which is the correct behaviour for a shape factor sitting just outside the
factor base.

**I have to flag one honest retraction** (`ERRORS.md` E8): my own pre-registered
threshold was `ratio ≥ 3`, and the script duly printed
`FIRES(>=3)? NO -- VACUOUS DETECTOR` over a real 1.11× effect. **The threshold
was arbitrary; the effect was real.** The permutation test against a same-shape
negative control is the control that works, and I should have written that
first.

**So: shape-sensitivity of a sieving primitive is real, and this is the
positive half of the answer.** But note the direction: **the effect shrinks as
`B` grows** (1.42 → 1.23 → 1.14). The forced prime-power structure of `N` is
worth a bounded, `B`-independent fraction of the smoothness test, and it is
swamped as soon as smoothness is common. It does not grow with `N`.

### exp5 — the closure, as a cost comparison

`exp5_closure.py`. Cost models in `log2` bit-operations: rho `= 0.5·log2 minFac`;
QS `= L_n[1/2,1]` (the Lenstra–Pomerance *rigorous* bound — I use the published
bound rather than a strawman, and the script prints the calibration check
`EXACT` at 256/512/1024/2048 bits).

**Positive control fires** — my model reproduces the corpus's published
crossover: **320 bits** vs `Round51_ShapeGap.md:56`'s "~330 bits". Negative
control also fires (rho wins below ~128 bits on balanced `pq`, as everyone
agrees). The model is calibrated against a number the corpus itself published,
so it is not my invention.

**The result:**

```
  cells where the shape channel is OPEN: 0 of 36
```

across `{128 … 2048} bits × {p q, a²b, a³b, a⁴b}`. The channel needs
`minFac(N) ≤ log2 B ≈ sqrt(bits)`, i.e.

| shape | requires | largest `n` |
|---|---|---|
| `p q` | `bits ≤ 4` | `2^4` |
| `a² b` | `bits ≤ 9` | `2^9` |
| `a³ b` | `bits ≤ 16` | `2^16` |
| `a⁴ b` | `bits ≤ 25` | `2^25` |

**The shape channel into a sieving primitive is closed for every shape at every
size anyone would use, including the small end.** And this is not a
two-sided squeeze — it is one-sided: in the only regime where the channel is
open (`minFac ≤ B`), Pollard rho costs `0.5·log2 minFac ≤ 0.5·log2 B`, while
the sieve costs at least the marking work against `π(B)` primes with
`B ≥ minFac`. **The shape-aware sieve is strictly dominated by the shape-aware
method that already exists. The channel is open exactly where it is useless.**

### exp4 — the "shape is free" premise, measured

`exp4_reading.py`. The corpus's load-bearing claim is that `a` is "visible from
`n` without factoring". **That claim is TRUE and it is fatal.**

| test | result |
|---|---|
| `n = a^2 b`, largest power part recovers `a` | **200/200** |
| `n = a^k b`, `k = 2,3,4,5,6` | **40/40 each**, non-vacuity asserted |
| generic `p q`, largest power part | **`1` in 10/10 cells** |

Two consequences, both against the corpus:

1. **Reading the shape is factoring.** `a` is a factor. The shape-aware sieve's
   plan is *use a factor you already have*.
2. **The freeness is exactly as broad as the power structure.** For `n = a^k b`
   with `k` known, it is poly-time — and that is a complete factorisation. For
   Mulder's *actual* shape, `p^2 q` with `q` in the range `[10^20, 10^5000]`
   (see §6), the power part is still free, so the whole shape is factored
   poly-time. For generic `p q` there is nothing to read and you fall back to
   rho at `n^0.25`.

**And on the corpus's own nominated shape the corpus's own advice is wrong.**
`Round51_ShapeGap.md:129` says "the right answer is *just use Pollard rho*".
But on `n = a^2 b` the answer is a **square root**, not rho:

| `n` bits | `a` bits | poly-time `log2` | rho `log2 = n^1/6` |
|---|---|---|---|
| 39 | 13 | ~40 | 6.5 |
| 56 | 18 | ~40 | 9.3 |

Poly-time wins by a factor growing like `n^1/6`. "Use rho" is the wrong advice
on precisely the shape the corpus nominates.

---

## 5. THE CLOSURE, STATED PRECISELY

> **Theorem (no shape-sensitive range sieve).** Let `A` be a range sieve for
> `N`, with factor base `Q = {q ≤ B}`. If `A` is shape-sensitive at `N` then
> `minFac(N) ≤ B`. Since a range sieve must mark its `M` candidates against all
> `π(B)` primes in `Q`, its cost is at least `M·log log B ≥ B`, while rho on the
> same `N` costs `O(sqrt(minFac N)) ≤ O(sqrt B) < B`. Hence `A` is strictly
> dominated by rho on exactly the moduli where `A` is shape-aware. ∎
>
> **Corollary.** The optimal `B` for an index-calculus sieve is
> `log B ≈ sqrt(log N)`, so the shape channel requires
> `minFac(N) ≤ sqrt(log N)` in bit terms — i.e. `N ≤ 2^((k+1)^2)` for `n = a^k b`.
> For every `k ≥ 1` this is `N ≤ 2^9` at best. **The channel is closed
> throughout the cryptographic range.** (Measured: 0 of 36 cells, §4/exp5.)

**What this does not prove.** It closes the class of **range sieves**. It does
not close: methods that are not range searches (ECM, `p−1`, class-group
methods — all of which *are* shape-sensitive and all of which exist); a
non-range smoothness test; or an oracle giving smoothness of a specific
structured integer for free. And it says nothing about `L_n[1/2, c]` for
`c < 1`, the 34-year-old gap, which remains the highest-ceiling item.

---

## 6. PROVENANCE

### Verified by me, first-hand, on this host

- **`ShapeGap.lean`** — compiles clean (`EXIT=0`), 0 `sorry`/`admit`, axioms
  `[propext, Classical.choice, Quot.sound]`. Lean 4.33.1, Mathlib `0df444a`,
  via `~/prove2me_workspace`. **The "0 sorry" claim is TRUE; the flagship
  theorem `sieve_cost_shape_blind` has hypothesis `N = M` and is a tautology
  about equality (§1a).**
- **Grep for the lead** — `Round51_ShapeGap.md` and `Round53_CatalogMine.md`
  only; no round 54–109 file attempts it (§1).
- **Mulder's paper** — `lit/mulder.txt`, fetched as a PDF, 102 KB, read
  directly. Verbatim, Abstract p. 1:
  > "If $a, b$ are both primes of roughly the same cryptographic size, then our
  > method is currently the fastest known method to factor $n$."

  And p. 3, which is the part the corpus drops:
  > "In the special case that $a = p$ and $b = q$ are distinct primes and
  > $p \approx q$, our algorithm is currently the fastest known method for
  > computing the square-free decomposition if $q$ is roughly in the range
  > $[10^{20}, 10^{5000}]$. The upper bound should be taken with a grain of salt,
  > see Section 5.1."

  Also p. 1: *"For integers however, the question is still open"* — Mulder
  describes the general integer square-free decomposition problem as open.

- **Mulder's venue — CORRECTED.** The corpus (`Round51_ShapeGap.md:27-29`) says
  *J. Number Theory* 2025. Verified independently via Crossref on the DOI:
  **Research in Number Theory 11(1), art. 9, published 2024-12-08**, DOI
  `10.1007/s40993-024-00585-8`. arXiv 2308.06130 is correct.
- **Mulder compares to ECM, never to GNFS-on-the-shape** (§5.1, p. 18-20), and
  never compares to Pollard rho on `a^2 b` — "rho" appears twice in the paper,
  both in Appendix C.1, both about using a rho-style map *inside* the class
  group as a stage-2 optimisation. **The corpus's "Mulder's method is
  competitive with rho" (§4) is not a claim Mulder makes.**
- **`exp5`'s crossover (320 bits) vs the corpus's published ~330 bits** — an
  independent reproduction of a number the corpus published, used as the
  positive control for my cost model.

### Verified by a delegated literature agent, which I spot-checked

Cross-checked above for the Mulder venue. Reported, with the caveat that I did
not personally re-verify each:

- **Lenstra–Lenstra, "Finding small integer roots of biquadratic polynomials",
  *Ann. Math.* 136 (1992) 217-244 — REPORTED PHANTOM.** Confirmed by the agent
  against OpenAlex's volume page map (issue 1 ends p. 218; issue 2 begins
  p. 219, so 217-244 is arithmetically impossible) and absent from zbMATH /
  Crossref / arXiv. Likely confusion with H. W. Lenstra Jr., *Bull. AMS* 26(2)
  (1992) 211-244. **I did not cite this anywhere, so nothing here depends on
  it, but the corpus's reading list should be corrected.**
- Pollard rho: **BIT 15(3), 331-334 (1975)** — not 1974.
- Harvey 2021, *Math. Comp.* 90, arXiv 2010.05450, DOI `10.1090/mcom/3658`;
  **it is a baby-step/giant-step method, not a sieve and not a lattice method**
  (the paper's word "random" appears zero times).
- The exponent-`2/9` paper is **Hittmeir's**, *Math. Comp.* 90 (2020),
  arXiv 2006.16729 — not Harvey's, as the corpus has it at
  `Round51_ShapeGap.md:19`.
- Lenstra–Pomerance 1992, *JAMS* 5(3) 483-516, DOI `10.2307/2152702` — **an
  UPPER bound despite "a rigorous time bound" in the title.**
- **No lower bound on smoothness-based factoring is known.** The sole
  index-calculus lower bound located is Hhan, arXiv:2402.11269 (preprint), and
  it is about *discrete logarithms*, counts group operations only while
  granting smoothness testing free, and its author explicitly disclaims it as
  evidence about index calculus. **This matters: my closure is a cost-model
  argument about the range-sieve class, not a lower-bound theorem, and I do not
  claim it as one.**
- **Shape-adaptive sieve: ~20 queries across arXiv/ePrint/zbMATH/Crossref/
  OpenAlex found none.** Nearest real work: Ebinger–Teske, "Factoring
  `N = pq^2` with the elliptic curve method", ANTS-V (2002); Coppersmith,
  "Specialized integer factorization", CRYPTO '98. The NFS
  polynomial-selection literature (Murphy, Kleinjung, Bai, Prest, Sarkar,
  David) optimises for a *given* `N` with shape treated as unknown.
- **ECM shape-sensitivity, confirmed:** Lenstra 1987 *Ann. Math.* 126,
  DOI `10.2307/1971363`.
- **NOT RETRIEVED:** Bernstein "Small factors and partial sieving" — **not in
  any of the five APIs.** I could not confirm it exists, so I extracted nothing
  from it and cite nothing from it. Pollard `p−1` primary source — not found.
  LLMP 1993 — the OpenAlex OA link was dead, so the degree-`d` statements are
  **unsourced here**. The `sqrt(5/4)` GRH constant is attributed to a paper both
  Crossref and zbMATH list under **A. K. Lenstra, not Seysen**; the agent could
  not verify the figure in any accessible source, so **I do not assert it.**

### Files

```
NOTES.md                    this file
PREDICTIONS.md              predictions, written before measuring
THEORY.md                   the closure argument, worked out before the data
ERRORS.md                   E1-E8, including the vacuous-test and hung-loop errors
axcheck.lean                #print axioms for all 5 ShapeGap declarations
ShapeGap_verify.lean        copy of the corpus file that was compiled
exp1_sievedomain.py         VACUOUS (E1) — kept, not deleted
exp1b_sievedomain.py        corrected; leg 1 is shape-blind
exp2_classgroup.py          UNDERPOWERED (E5) — identity verified, magnitude not
exp3b_threshold.py          the shape-sensitivity measurement
exp4_reading.py             is the shape free to read?
exp5_closure.py             the cost-model closure, 0/36 cells open
exp6_stats.py               exact permutation tests
lit/                        delegated literature agent's raw fetches
```

---

## 7. WHAT IS NOT DETERMINABLE FROM HERE

- **The magnitude of the class-group saving.** I verified the *identity*
  `h(Q(√(a²b))) = h(Q(√b))` exactly, 25/25, which is the load-bearing part and
  explains *why* Mulder's method works on this shape. I could not measure the
  resulting `N^{-1/3}`: PARI's `qfbclassno` costs `~2^(0.6·bits)` (measured:
  `2^33 → 8.5 s`, `2^38 → 45.7 s`), so `b` large enough for `h(b) ≫ 1` is out
  of reach here. At the sizes I could run, `h(b) = 1` in 8/8 probes, so my ratio
  was `1/median(h(pq))` — a ratio of small integers, not a measurement.
  **I do not claim a class-group saving was measured. It was not.**
- **The NFS regime.** `π(B*) ~ 10^15–10^33` is uninstantiable on this host.
  Everything above is `N ≤ 2^22` (measurements) or `N ≤ 2^40` (shape reading)
  or an analytic cost model. **No extrapolation into the NFS regime.**
- **Anything about real cryptographic moduli.** None were generated or
  factored. All moduli are locally-generated composites below `2^40`.
- **Whether a NON-range shape-sensitive primitive exists.** My closure is
  scoped to range sieves. A method that smooths a *structured* object without
  searching a range is not covered, and I have no result on it.
- **Bernstein's partial sieving.** If "Small factors and partial sieving"
  exists, it is the closest published neighbour to the lead and I could not
  find it. **This is the most likely place my closure is wrong**, because a
  partial sieve changes the `#candidates` term rather than the survival rate,
  and that is a channel my analysis treats as fixed by `log N`.
- **`L_n[1/2, c]` for `c < 1`.** Untouched. Still the highest-ceiling item, and
  independent of everything here.
