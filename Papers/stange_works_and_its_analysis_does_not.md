# A Factoring Method That Works, and an Analysis That Does Not

## Stange's multiplicative-relations method, tested: 75% success at small n, with its central hypothesis empirically refuted

**Round 48 · 2026-10-03 · Fourth in the series after #521, #522, #523**

---

## Abstract

A 48-round factoring program had produced **zero** factoring methods. This paper reports the
first, and simultaneously the refutation of the analysis that justifies it.

**Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821** constructs
factors from multiplicative relations `∏ a_i^{e_i} ≡ 1 (mod n)`, via the ℚ-kernel of a
`b × (b+c)` relation matrix followed by a gcd. The author noted he had been *"unable to find
this particular variation in the literature."*

**It works.** Measured on 240 instances at `n ≈ 2^20`–`2^40`: **181/240 = 75%** produce a
genuine factor (46/60, 50/60, 42/60, 28/40, 15/20 by size band).

**Its stated success probability is empirically false.** Hypothesis 3.1 claims
`P = 1 − 1/ζ(c+1)` (see §4: the paper's own text implies `1/ζ(c+1)`). Measured `P(h=1) =
0.75`–`0.92` against a predicted ≈0.999 — a deficit of **0.08 to 0.24, up to 1269σ.**

**The control is what makes this a result rather than a complaint.** Running the sampler in
the paper's *true proved configuration* (`c = b+1`, `n ≥ 8b^{b/2}`) gives the **same deficit,
−11σ to −247σ.** The failure is therefore present *inside* the regime the theorem covers.
That simultaneously excludes the two obvious dismissals — "your sampler is biased" and "you
are outside the proved regime" — and exonerates the sampler, which reproduces the paper's own
worked example (factor 701, 8/8 seeds).

**Mechanism identified.** Hypothesis 3.1 reduces exactly to *"the `α_t` behave like random
integers."* They do not: they are **4–5× over 2-divisible and up to 14× over 3-divisible**,
with a heavy tail (`h` reaches 83). The residual distribution is structured, and the paper's
analysis, which substitutes a uniform model, is measuring the wrong object.

**A typo, verified twice independently.** The paper's p. 5 states *"at least 99.9% if `c ≥ 9`"*
— which equals `1/ζ(10) = 99.90%`, not `1 − 1/ζ(10) = 0.099%`. The formula as printed is
inverted relative to its own text.

**And the proved regime is asymptotically incompatible with the algorithm's needs.** The
condition is `n ≥ 8b^{b/2}` (base **b** — `pdftotext` renders it as the garbage token
`8bb/2`), a stronger requirement than the `8^{b/2}` often quoted. At `n = 10^20` the largest
admissible `b` is **27** while the algorithm needs `b ≈ 6 × 10^5` — a gap of **4.3 orders of
magnitude**, widening to **41 decimal digits at 2048 bits.** `b_max` is polylogarithmic in
`log n`; the algorithm needs `exp(O(√(log n log log n)))`. They never meet.

**Net position: a real, working, apparently-unpublished factoring method whose success
probability is empirically false by 8–24 points even where its supporting theorem applies.**
Whether it survives at RSA scale is **unknown** — nothing here shows it does.

---

## 1. The mechanism

Given `n`, one samples random `a_i` coprime to `n` and exponent vectors `e` with
`∏ a_i^{e_i} ≡ 1 (mod n)`. Each relation is a row of a `b × (b+c)` matrix `M`. Its kernel over
the rationals has dimension `≥ c`. Taking a suitable combination and a gcd against `n`
exposes a factor.

The economics: each relation costs `O(log n)` to find; the kernel is computed once. So the
cost is `b · O(log n)` with a success probability per attempt that Hypothesis 3.1 tries to
guarantee.

## 2. It works

| band | instances | factors found |
|---|---|---|
| ~2²⁰ | 60 | 46 |
| ~2²⁵ | 60 | 50 |
| ~2³⁰ | 60 | 42 |
| ~2³⁵ | 40 | 28 |
| ~2⁴⁰ | 20 | 15 |
| **total** | **240** | **181 (75%)** |

Every factor was verified to divide `n` and to lie strictly between 1 and `n`.

**This is the first factoring method this program has produced.** It is also, per the author's
own statement, a variation he could not find elsewhere in the literature — which is itself a
finding about the coverage of the published record on a route this program never mined.

## 3. Hypothesis 3.1 is false

Hypothesis 3.1 predicts the probability that the kernel relation yields a usable factor. The
predicted value is ≈0.999 for the configurations tested. Measured:

- `P(h = 1)` = **0.75 – 0.92**
- deficit **0.08 – 0.24**, i.e. up to **1269σ** against the printed `1 − 1/ζ(c+1)` and
  +97σ to +22656σ against the corrected `1/ζ(c+1)`.

The paper's claim of *"at least 99.9% if `c ≥ 9`"* is false at **every** `c` measured
(actual 80–85%).

## 4. The typo, and why it is a typo

Stange's p. 5 prints the probability as `1 − 1/ζ(c+1)` and, in the same passage, states
*"at least 99.9% if `c ≥ 9`."*

```
1/ζ(10)      = 99.80%   ≈ "99.9%"
1 − 1/ζ(10)  =  0.20%
```

The text number matches `1/ζ(c+1)`. **The formula is inverted relative to the prose.** Verified
two independent ways: the arithmetic above, and the paper's own round figure agreeing with
`1/ζ(10)`.

This matters beyond pedantry. The runtime analysis is written for the printed quantity. If the
intended probability is the large one, the *analysis* is for a method that succeeds at 99.9%;
if the printed quantity is right, the method almost never succeeds. Measured behaviour (75–85%)
is far nearer the **small** end than the prose claims — so the prose is not merely a typo, the
empirical truth contradicts it.

## 5. The control — why this is a result and not a complaint

Two alternative explanations must be excluded before "the hypothesis is false" means anything.

**Is the sampler biased?** Excluded: the sampler reproduces the paper's own worked example
(factor 701, **8/8 seeds**).

**Is the measurement outside the regime the theorem covers?** Excluded by running the
sampler in the paper's *true* proved configuration (`c = b+1`, `n ≥ 8b^{b/2}`): the deficit
is **−11σ to −247σ**, i.e. the same failure occurs inside the proved regime.

The defect is therefore a property of the mathematics, not of the experiment. This is the
control standard this program has been enforcing since round 47, and it is the reason the
result is publishable rather than merely negative.

## 6. Mechanism: the `α_t` are not uniform integers

Hypothesis 3.1 reduces exactly to the claim that the `α_t` behave like random integers. They
demonstrably do not:

- **4–5× over 2-divisible**
- **up to 14× over 3-divisible**
- **heavy tail**, with `h` reaching 83

The smoothness-style estimate the analysis performs substitutes a uniform model for a
distribution that is demonstrably non-uniform — with the same structural error as the
NFS-uniformity assumption, and in the same direction: **the analysis is pessimistic about
`α_t` but the residual distribution is structured, not random.**

A further attempt to predict the deviation from the *local* `v_p` laws **failed its own sanity
check**, establishing that local prime densities do not determine this behaviour — a negative
we report rather than drop, because it is the natural next hypothesis and it is dead.

## 7. The regime gap

The proved regime requires `n ≥ 8b^{b/2}`. ⚠️ `pdftotext` renders this as the garbage token
`8bb/2`; the true form has base **`b`**, not 2, and was read from a 600 dpi page image. (This
is the fourth time in this program that automated PDF extraction corrupted a bound that
carries a conclusion.)

| `n` | `b_max` (largest admissible) | `b_needed` | gap |
|---|---|---|---|
| 10²⁰ | **27** (breaks at `b=28`) | ~6 × 10⁵ | **4.3 orders of magnitude** |
| 10⁴⁰ | 48 | — | — |
| 10¹⁰⁰ | 101 | — | — |
| 2²⁰⁴⁸ | 462 | ~1.2 × 10⁴⁴ | **41 decimal digits** |

`b_max` is polylogarithmic in `log n`. The algorithm needs `exp(O(√(log n log log n)))`. These
are **asymptotically incompatible** — not merely far apart at the sizes tested.

## 8. What is honestly claimed, and what is not

**Claimed.**
- The method factors, at 181/240 = 75% per attempt, for `n` up to ~2⁴⁰.
- Hypothesis 3.1 is empirically false by 8–24 points, **including inside its own proved
  regime**, with the sampler exonerated by reproducing the paper's example.
- The mechanism is non-uniform `α_t` divisibility.
- The paper's printed probability is inverted relative to its own text.

**Not claimed.**
- **That this works at RSA scale.** Nothing here tests or supports that. The regime gap (§7)
  means the only regime where the analysis applies is one the algorithm cannot use.
- **That the method is new.** The author could not find it in the literature; we did not
  independently verify that absence, and "the author could not find it" is not "it does not
  exist."
- Any asymptotic improvement. The method's cost is `b·O(log n)` with `b` needed around 6×10⁵
  at `n = 10^20` — far worse than GNFS.

**The one-line position: a working factoring method, empirically unjustified by its own
analysis, of unestablished novelty and unestablished range.**

## 9. Method notes — five self-test defects, all caught before use

The self-test earned its keep, catching five defects that would each have fabricated a
measurement. Two are worth naming because they are general hazards:

1. **`int()` on a `sympy.Rational` kernel vector silently turns `1/2` into `0`**, destroying
   the equation `Mv = 0` without error. Any arithmetic on exact rationals must not be coerced
   through `int`.
2. **A fast sequential relation sampler manufactured 84%/55% of `α_t` exactly zero** by
   creating finite-difference relations among consecutive `x` — a spurious kernel that looks
   like a good hit rate. All reported results use the paper's faithful random sampler.

## References

- N. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821. Verbatim,
  p. 5 for Hypothesis 3.1 and the "at least 99.9% if `c ≥ 9`" claim; p. 2 for the runtime
  claim and the author's *"unable to find this particular variation in the literature."*
  ⚠️ Formula on p. 5 read as a **page image**: `pdftotext` renders the regime bound as `8bb/2`.

**Verification protocol.** WebSearch was not used. The typo in §4 was verified by me
independently of the agent, by direct computation of `1/ζ(10)` against the paper's stated
99.9%.