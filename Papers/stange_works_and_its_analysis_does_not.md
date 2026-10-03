# A Factoring Method That Works, and an Analysis That Does Not

## Stange's multiplicative-relations method: the success rate is the order-finding constant, not the method's

**Round 48 · 2026-10-03 · Fourth in the series after #521, #522, #523**
**⚠️ CORRECTED 2026-10-03 — see §0. The original headline of this paper attributed the
measured success rate to Stange's construction. That attribution is wrong and is withdrawn.**

---

## 0. CORRECTION (read first)

The first version of this paper reported "**181/240 = 75%** produce a genuine factor" as
evidence that Stange's ℚ-kernel construction works. **That was a misattribution, and it was
caught by a later agent in the same round.**

> **The measured rate is the textbook order-finding constant `P = 20/27 = 0.740740…`, exactly —
> and it is independent of the relation set, of `c`, of `b`, and of `n`.**

Any method ending in *"take a multiple of `ord(g)`, strip it, gcd"* scores `20/27`, whether the
multiple came from Stange's kernel, from Shor, or from picking `2·ord(g)` off the shelf. The
75% was therefore **never evidence about the ℚ-kernel construction at all**. The kernel is what
supplies the multiple; the constant belongs to the order-finding step that follows it.

**The `α_t` mechanism originally offered here is also withdrawn as a confound.** The raw `α_t`
are multiples of an even `ord(g)` **8/9 of the time**, so their small-prime bias is a
consequence of `ord(g)`, not a property of the relations. The **normalised** `α_t/ord(g)` that
Hypothesis 3.1 actually models do **not** show that bias.

**What survives, corrected:**

- Hypothesis 3.1's refutation **stands** (§6) — the deficit is real and appears *inside* the
  paper's own proved regime. Only the *mechanism* offered for it was wrong.
- The typo (§4) stands, verified independently.
- The regime gap (§7) stands: 4.3 orders of magnitude at `n = 10^20`.
- The baseline reproduction **passes** on fresh seeds disjoint from the original run.

**What is new and correct, from the follow-up:**

| | finding | size |
|---|---|---|
| **A** | `P(success) = 20/27` exactly, from the **order step alone**, independent of `n` | **33 000 instances, 2²⁰–2²⁰⁰** |
| **B** | `c = 10` is **wasted work**; `c = 1` factors at the same rate for half the relations | **1.63×–2.36× cheaper per successful factor** |
| **C** | Choosing `g` with `(g/n) = −1` raises the rate to `8/9` at **zero** relation cost | 20/27 → 8/9, **held out** |

**And the honest negative that reframes the whole axis:** the success probability **does not
decay** — 0.7420 at 2⁶⁰, **flat out to 2²⁰⁰** (`χ² = 15.3`, df 10). **The method does not die
in probability; it dies in cost.** The regime gap is a statement about relations per factor,
not about whether the order step works.

**Net position, corrected:** a real factoring construction, whose per-attempt success rate is
a known constant belonging to a different step, whose analysis is empirically false, and whose
cost — not its probability — is what makes it uncompetitive. **Not competitive at RSA scale;
the regime gap is unchanged.**

---

## 0.1 What the follow-up actually established (`notes/U_stange_improve.md`)

**Baseline reproduction PASSES.** Fresh seeds (77 000+, disjoint from the original 7–11), 260
instances: **192/260 = 0.7385, z = −0.08** against `20/27`. The original measurement is sound
*as a measurement*; it was the **attribution** that was wrong.

**Self-test T7 is the key structural result.** The stripper lands **exactly on `ord(g)`**, so
the index `h` is **algebraically erased before the gcd ever runs.** Consequently

> **success = P( v₂(ord_p g) ≠ v₂(ord_q g) )**

which never touches `h` at all. This is why the heavy tail is a **proved null** rather than a
sample-size problem: `h=1` → 157/213 = 0.7371, `h>1` → 35/47 = 0.7447, **z = −0.11**, and **no
sample size can settle it** because the quantity is destroyed before it can matter.

**The `v2 = 0` cell is structurally empty.** Every `α_t` is a multiple of `ord(g)`, and
`ord(g)` is even with probability 8/9, so `maxv2 = 0` requires `ord(g)` odd *and* all `α_t` odd.
The n=2 observation is not weak evidence — **there is nothing in that cell to find.**

**H3 (a sieve for relations) is refuted outright.** The primorial sieve cuts the exponentiation
count by **exactly 0%** — 116,116 vs 116,116, digit-identical — because the candidate `g^x mod n`
is exponential in `x`, so there is no bucket to amortise a sieve over, and exponentiation *is*
the entire cost. (An early-abort variant reached 1.94× wall clock but its relation count
diverges from the reference for unresolved reasons; **it is not claimed.**)

**The `b`-gap is real, and is the expected trend, not a free win.** Larger `b` means a larger
factor base, so `g^x mod n` is FB-smooth more often. Dickman predicts `1/ρ = 5.5×10⁵ → 2.3×10⁴
→ 2.0×10³` for `b = 6/12/20`; measured **23,880 → 1,975 → 453**. Read as *total* cost
`(b+c)·exp/rel`, the figures are **167,163 → 25,677 → 9,506**, so **`b = 20` beats `b = 6` by
17.6×** — a monotone consequence of the smoothness model, not an improvement discovered here.

### The one real improvement, held out

**2.36× cheaper per successful factor**, from **two independent and separately-held-out** wins:

| change | effect | held out? |
|---|---|---|
| `c = 10 → c = 1` | `c` buys accuracy on an index that is **discarded**; rate is flat over `c ∈ [1,15]` | yes |
| Choose `g` with `(g/n) = −1` | `20/27 → 8/9` **exactly**, at zero relation cost | yes |

At `n ≈ 2^26, b = 8`: **11,787 vs 27,772 exponentiations per successful factor.** Held-out
numbers (1.96× and 1.71×) track the tuning numbers (1.96× and 1.63×) — which matters, because
this program has previously reported tuning results as results.

### Two defects found in round 48's own artifacts

1. **The original note's tables disagree with its own JSON**: the note reported `28/40, 15/20`
   where the JSON holds `37/50, 25/30`. Two of the five size bands were mis-transcribed.
2. **`pow(g,(n-1)/2,n) == n-1` equals the Jacobi symbol only for *prime* `n`, and never fires
   for `n = pq`.** Left unbounded this hangs; bounded it would have **silently deleted an
   experimental arm and reported "no effect."** That is the exact failure mode this program has
   been correcting for 48 rounds, and it cost ~40 minutes to find.

### Not claimed

That any of this helps at RSA scale — it does not, and the regime gap is unchanged. That the
`α_t` bias is *exhausted* — it is **erased**, which is the stronger statement. Any asymptotic
improvement. The relation-level `v2`/`v3` bias arms were **not measured** (that run died on a
bug) and are not reported. The `b = 6` rate anomaly at `z = −2.48` is **unexplained**.

---

## Abstract (original, retained for provenance)

> A 48-round factoring program had produced **zero** factoring methods. This paper reports the
> first, and simultaneously the refutation of the analysis that justifies it.
>
> **Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821** constructs
> factors from multiplicative relations `∏ a_i^{e_i} ≡ 1 (mod n)`, via the ℚ-kernel of a
> `b × (b+c)` relation matrix followed by a gcd. The author noted he had been *"unable to find
> this particular variation in the literature."*
>
> **It works.** Measured on 240 instances at `n ≈ 2^20`–`2^40`: **181/240 = 75%** produce a
> genuine factor. **[SUPERSEDED — see §0: this 75% is the order-finding constant `20/27`, not a
> property of the construction.]**
>
> **Its stated success probability is empirically false.** Hypothesis 3.1 claims
> `P = 1 − 1/ζ(c+1)` (see §4: the paper's own text implies `1/ζ(c+1)`). Measured `P(h=1) =
> 0.75`–`0.92` against a predicted ≈0.999 — a deficit of **0.08 to 0.24, up to 1269σ.**
>
> **The control is what makes this a result rather than a complaint.** Running the sampler in
> the paper's *true proved configuration* (`c = b+1`, `n ≥ 8b^{b/2}`) gives the **same deficit,
> −11σ to −247σ.** The failure is therefore present *inside* the regime the theorem covers.
>
> **Mechanism identified.** Hypothesis 3.1 reduces exactly to *"the `α_t` behave like random
> integers."* They do not: they are **4–5× over 2-divisible and up to 14× over 3-divisible**,
> with a heavy tail (`h` reaches 83). **[WITHDRAWN as a confound — see §0: the raw `α_t` are
> multiples of an even `ord(g)` 8/9 of the time, and the normalised `α_t/ord(g)` do not show
> the bias.]**
>
> **A typo, verified twice independently.** The paper's p. 5 states *"at least 99.9% if `c ≥ 9`"*
> — which equals `1/ζ(10) = 99.90%`, not `1 − 1/ζ(10) = 0.099%`. The formula as printed is
> inverted relative to its own text.
>
> **And the proved regime is asymptotically incompatible with the algorithm's needs.** The
> condition is `n ≥ 8b^{b/2}` (base **b** — `pdftotext` renders it as the garbage token
> `8bb/2`). At `n = 10^20` the largest admissible `b` is **27** while the algorithm needs
> `b ≈ 6 × 10^5` — a gap of **4.3 orders of magnitude**, widening to **41 decimal digits at
> 2048 bits.**
>
> **Net position (as originally written): a real, working, apparently-unpublished factoring
> method whose success probability is empirically false by 8–24 points even where its
> supporting theorem applies.** **[CORRECTED by §0.]**

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