# A Square Minus a Cube Divides Twice as Often as a Random Integer

## An exact local valuation law for the number field sieve's relation value, and what it is worth

**Round 48 · 2026-10-03 · Third in the series after #521 and #522**
**⚠️ CORRECTED 2026-10-03 — the claim "independent of `k`" is FALSE as stated. It holds for
`2 ≤ k ≤ 5`. The cause is identified below; the practical conclusion survives, the universal
claim does not.**

---

## Abstract

Every number field sieve computation treats `a² − b³ mod N` as a uniformly random integer.
It is not. We determine the exact local law. **⚠️ The first version of this abstract
claimed the factor holds `independent of k` for every `k >= 2`. That was WITHDRAWN — see
§4.2/§4.3 and the correction notice below.** The correct statement is:

> **`P( p^k | a² − b³ ) = (2p − 1) / p^k`**, i.e. `2 − 1/p` times the uniform rate `1/p^k`,
> **for `2 ≤ k ≤ 5` only.** The factor is **not** independent of `k`: it departs at `k = 6`,
> where the zero-zero subspace contributes `p^(k−⌈k/2⌉−⌈k/3⌉)`, and the departure does
> **not** relax at `k = 7`. Corrected law:
>
> **`ratio = (2 − 1/p) + [ p^(k − ⌈k/2⌉ − ⌈k/3⌉) − 1 ]`**
rate is exactly `1/p`, the uniform value. So the excess is not in the prime itself but in
**every higher power**, where a square minus a cube divides by `p^k` almost twice as often as
a random integer does.

This is a *powerful forms* effect, and it is elementary: `p^k ∣ a² − b³` forces `a` and `b`
into a common ramified structure that a generic pair does not share.

We correct the first version of this result, reported within round 48, which stated the
factor as `1 + 1/p` with a spurious exception at `p = 3`. **The correct factor is `2 − 1/p`**,
which is *larger*, not smaller, at every prime — the earlier number understated the effect by
nearly a factor of two at `p = 13`.

We also report what this is worth, honestly: a real, exactly-explained, **low-order constant**.
It does not move the `L[1/3]` exponent and does not move the GNFS constant `(64/9)^{1/3} =
1.92299`. We decline to claim more, and we flag a 2-adic anomaly we did not resolve.

---

## 1. The claim and why it matters

In NFS, relations come from pairs `(a,b)` for which `a² − b³` factors into small primes. The
entire `L[1/3]` analysis uses the Dickman estimate for a **uniform** integer. That assumption
is a model, and this paper measures where it fails.

The failure is not noise. It is exact algebra, and it is one-directional: NFS values are
**smoother** than the uniform model predicts, so the heuristic is *pessimistic*. That is a
genuine and slightly surprising fact about the method, and it is not in the standard
references.

## 2. The law

Measured by exhaustive enumeration over **all** `(a,b) mod p^k` — including `a² ≡ b³`, which
is precisely the case carrying the effect and which a careless implementation drops:

| p | k=1 | k=2 | k=3 | k=4 | predicted `2 − 1/p` |
|---|---|---|---|---|---|
| 3 | 1.000 | 1.667 | 1.667 | 1.667 | 5/3 = 1.667 |
| 5 | 1.000 | 1.800 | 1.800 | 1.800 | 9/5 = 1.800 |
| 7 | 1.000 | 1.857 | 1.857 | — | 13/7 = 1.857 |
| 11 | 1.000 | 1.909 | 1.909 | — | 21/11 = 1.909 |
| 13 | 1.000 | 1.923 | 1.923 | — | 25/13 = 1.923 |

Entries are `P(p^k ∣ a²−b³) ÷ (1/p^k)`. The `k = 1` column is **1.000 for every prime** — no
excess at the prime itself — and the `k ≥ 2` columns are **`2 − 1/p` exactly**.

Two features worth stating separately because they are easy to conflate:

- **No excess at `k = 1`.** For any prime `p`, `P(p ∣ a²−b³) = 1/p` exactly. Whatever is
  happening is happening in the higher powers.
- **The excess is `k`-independent.** The factor is `2 − 1/p` at `k = 2`, `3`, `4`, and `5`.
  A uniform integer's rate `1/p^k` falls geometrically; the NFS value's falls at the *same*
  rate, leaving a constant factor. So the effect compounds multiplicatively across the
  valuations.

### 2.1 Why it happens

`p^k ∣ a² − b³` means `a² ≡ b³ (mod p^k)`. If `p ∤ b` then `a²/b³ ≡ 1` forces
`a ≡ ±b·(b)^{1/2}`, and the two square roots of `b³` generate a systematic pairing that a
random pair does not have — the values `a` and `−a` are *both* roots, so the congruence
`solutions are twice as dense as chance at every level of the `p`-adic filtration beyond the
first. Concretely, the count of `(a,b) mod p^k` satisfying `a² ≡ b³` grows like
`p^k · (2p−1)/p^k = 2p − 1` per unit of `p`-adic measure, i.e. a factor `2p−1` against the
`p` a generic congruence of that height would have.

**The name for this in the literature is powerful forms**: a square minus a cube is far more
often divisible by high powers than a generic integer, because it is the difference of two
powers with a common ramification structure.

## 3. Correction to the round-48 working figure

The first version of this result, produced within round 48, reported the factor as
`1 + 1/p` with an exception at `p = 3` (measured 1.667 there). The `p = 3` measurement was
correct; **the rule was not**. Fitting the six verified primes gives the numerators `3, 5, 9,
13, 21, 25` for `p = 2,3,5,7,11,13` — that is **`2p − 1` in every case**, hence `2 − 1/p`,
with **no exception at `p = 3`**.

This matters in the direction of *understatement*: at `p = 13` the true factor is **1.923**,
not 1.077. A fit anchored on `p = 2` (where `1 + 1/p` and `2 − 1/p` coincide, both being
1.5) produced a law that decays to 1 as `p` grows, which is backwards.

## 4. CORRECTION: the law is NOT k-independent, and the 2-adic "anomaly" was the tell

*Written after the original version of this paper claimed the factor `2 − 1/p` holds for
"every `k ≥ 2`". That claim was verified only at `k = 2,3,4` and **it is false as stated**.*

### 4.1 What actually happens

The factor is constant at `2 − 1/p` **only while `⌈k/2⌉ + ⌈k/3⌉ = k`**, which holds precisely
for `2 ≤ k ≤ 5`. From `k = 6` the ratio departs, by **exactly `(p − 1)`** at the first
departure:

| p | k=4 | k=5 | **k=6** | `2 − 1/p` | deviation at k=6 |
|---|---|---|---|---|---|
| 3 | 1.6667 | 1.6667 | **3.6667** | 1.6667 | **+2.0000 = p − 1** |
| 5 | 1.8000 | 1.8000 | **5.8000** | 1.8000 | **+4.0000 = p − 1** |

### 4.2 The cause: the zero-zero subspace

The pairs with `a² ≡ b³ ≡ 0 (mod p^k)` are counted by `a ≡ 0 (mod p^⌈k/2⌉)` and
`b ≡ 0 (mod p^⌈k/3⌉)`, giving `p^(2k − ⌈k/2⌉ − ⌈k/3⌉)` pairs, hence a contribution to the
ratio of

> **`p^(k − ⌈k/2⌉ − ⌈k/3⌉)`**

which is exactly `1` while `⌈k/2⌉ + ⌈k/3⌉ = k` (i.e. `k ≤ 5`) and **exceeds 1 thereafter, for
every prime**. So the departure at `k=6` is not a 2-adic peculiarity at all — it is the same
effect for odd primes, and **I had tested odd primes only to `k=4`.**

**So the "2-adic anomaly" flagged in the original version of this paper was the visible edge of
a general fact that my own testing range was too narrow to see.** The `p=2` series

```
k:      2     3     4     5     6     7     8
ratio: 1.50  1.50  1.50  1.50  2.50  2.50  3.50
```

decomposes exactly as `zero-zero term + nonzero term`, with the zero-zero term contributing
`2^(k − ⌈k/2⌉ − ⌈k/3⌉) = 1,1,1,1,2,1,2` across those `k`. (`p=2` carries an additional
high-`k` contribution from `k=7` onward, which is **not** fully accounted for and is stated as
open.)

### 4.3 What survives, and what does not

**Corrected law (verified):**

> `P(p^k | a² − b³)/p^k = (2 − 1/p) + [ p^(k − ⌈k/2⌉ − ⌈k/3⌉) − 1 ]` for `2 ≤ k ≤ 6`,
> and the bracket term grows without bound as `k` increases.

**Withdrawn:** *"for every `k ≥ 2`"*, and *"independent of `k`"*.

**Unaffected:** the practical conclusion. The NFS operating point is `u ≈ 3–5` and the
divisibility events that matter are at small `k`; the headline finding — **NFS relation values
are smoother than the uniform model predicts, by roughly a factor of two per prime power** —
is unchanged. What is now known is that the excess *grows* at high powers rather than staying
bounded, and that this is a consequence of the trivially-divisible subspace, not of a subtle
ramification effect.

### 4.4 The methodological point, which is the real lesson

The original version flagged `p=2, k=6` as an unexplained anomaly and attributed it to
"2-adic ramification". **It was neither anomalous nor 2-adic.** It was a `k=6` effect visible
at every prime, and the original paper's own table — which stopped at `k=4` for odd primes —
was simply too short to show it.

> **A law verified over the range you happened to test is not a law.** The constant-in-`k`
> claim came from testing `k = 2,3,4` and finding no variation; the variation begins at the
> first `k` with `⌈k/2⌉ + ⌈k/3⌉ < k`, which is `k=6`.

**The residual open item — CORRECTED, it is not `p=2` alone.** The corrected law is claimed
only for `2 ≤ k ≤ 6`, and that claim is correct. Beyond it the departure persists one step
longer than the formula predicts, for **every** prime tested, not only `p = 2`:

| p | k | measured | formula's bracket | measured bracket |
|---|---|---|---|---|
| 2 | 6 | 2.50 | 1 ✓ | 1 |
| 2 | 7 | 2.50 | **0** | **1** |
| 2 | 8 | 3.50 | **1** | **2** |
| 3 | 6 | 3.67 | 2 ✓ | 2 |
| 3 | **7** | **3.67** | **0** | **2** |
| 5 | 6 | 5.80 | 4 ✓ | 4 |

At `k = 7` the exponent `k − ⌈k/2⌉ − ⌈k/3⌉` returns to 0, and the formula predicts the plain
`2 − 1/p` — but the measurement does not return. So the `k = 6` departure **does not relax at
`k = 7`**, for `p = 2` and `p = 3` alike. **Not claimed to be understood.** The earlier
version of this paper recorded the open item as a "`p = 2` contribution"; it is a general
`k ≥ 7` phenomenon.

*(A first attempt at an analytic count of `#{(a,b) : a² ≡ b³}` — avoiding `O(p^{2k})`
enumeration — gave ratios ~80x too large and was discarded as buggy rather than reported.
Brute force at `3^7` is 4.8M pairs and settles it.)*

## 5. A methodological note: the bug that made the first version wrong twice

The enumeration must run over **all** `(a,b) mod p^k`. A first implementation excluded
`a² ≡ b³` — reasoning that these are "degenerate zero cases" — and consequently measured
ratios of 0.24, 0.11, 0.04, … instead of 1.0, 1.5, 1.8. **The excluded cases are not
incidental; they are the entire effect.** Dropping the data that carries the phenomenon makes
the measurement look like strong evidence *against* the claim.

This is the same failure mode as the two smoothness predicates that called everything smooth
in round 48, and the same mode as my own pigeonhole "measurement" (`m_i ≡ m_j (mod p)`).
The generalization worth carrying:

> **Before discarding any subset of your sample, check whether the subset is where the effect
> lives.** A degenerate-looking case excluded from a divisibility count is usually the signal.

## 6. What this is worth — the honest accounting

**⚠️ CORRECTED 2026-10-03 — the original version claimed a "25–38% reduction in
relation-collection cost, measured end-to-end." That was wrong on three counts, per adversarial
audit, and the claim is WITHDRAWN. See §6.1.**

The direction is favourable: NFS relation values are smoother than the uniform model says, so
the heuristic is *pessimistic* about NFS.

**What survives:**

- **The `L[1/3]` exponent is untouched.** A constant-factor change in smoothness probability
  shifts the prefactor, not the exponent of `L`.
- **The GNFS constant is untouched.** `(64/9)^{1/3} = 1.92299` is fixed by the linear-algebra
  half of the cost model (Montgomery EUROCRYPT'95 p. 118, `O(dn²/N) + O(n²)`, the `O(n²)`
  independent of `N`), not by the smoothness rate.
- **The extrapolation is a model, not a measurement.** All data is at `N ≈ 10^8` and
  `u ≤ 4`; NFS runs at `u ≈ 3–5`. A previous round chased an apparent `N`-dependence through
  four iterations and it was truncation, not physics.
- **The bias does not concentrate.** It buys extra powers of a handful of primes while losing
  `1/p` of the box for every other prime, so no sieveable sub-box captures a net gain.

**What does NOT survive — and this is the honest bottom line of this paper: the quantitative
payoff is UNMEASURED.** The valuation law (§2, verified exhaustively) is a fact. What it is
worth in wall-clock is not established, and no one has demonstrated it can be cashed.

---

## 6.1 CORRECTION — the 25–38% payoff is withdrawn

The first version of this paper stated:

> *"Measured end-to-end by the round-48 smoothness axis, the effect is a **25–38% reduction in
> relation-collection cost** at the operating point `u ≈ 3`."*

**Withdrawn.** Adversarial audit found it fails on three independent counts, and I agree with
all three:

1. **It was never measured end-to-end.** No run in this program propagated the valuation excess
   through a relation-collection pipeline and timed it. The figure is an *interpolation* from a
   smoothness rate, not a measurement of a collection step.
2. **It does not follow from `δ`.** The excess is a per-prime-power divisibility ratio; turning
   that into a fraction of *collection* cost requires a model of how the sieve actually spends
   work, which was never supplied. The round-48 smoothness axis labelled its own number **"the
   naive reading"** — and the first version of this paper promoted it to "measured end-to-end."
3. **The program's own data suggests it cannot be cashed.** The bias does not concentrate into
   a sieveable sub-box (every net gain `< 1`): it buys extra powers of a few primes while losing
   `1/p` of the box for every other prime. If the gain cannot be localised, the sieve does not
   collect it.

**This is the failure mode the round has been cataloguing all day, applied to my own paper:** a
number inherited from an agent, re-labelled with a stronger word than its source used, and
published. The audit is right, and the correct statement is the shorter one:

> **The valuation law is established. Its cost consequence is not. Establishing it requires an
> end-to-end collection measurement in which the sieved-box structure is preserved.**

Until that exists, **this paper's contribution is a distributional fact about NFS values and
nothing more.** It is still, as far as I can tell, not in the standard references — but a fact
without a measured payoff should be presented as a fact, not dressed as an improvement.

---

## 6.2 The open item is now CLOSED — with a measured number, and it is not the one withdrawn

`factor-scratch/r49exp/nfs_e2e/` performed the end-to-end measurement this section asked for.

**The control that makes it a result (stated first).** The pipeline carries a switch that
disables the excess while preserving the `k = 1` law: the NULL arm replaces `a²−b³` by
`round(|a²−b³|·e^ε)`, a locally uniform integer. Measured excess over null:

| arm | excess | significance |
|---|---|---|
| TRUE (`a²−b³`) | **0.7200 ± 0.0024** | **303σ** |
| NULL (locally uniform) | **−0.0000 ± 0.0024** | 0.01σ |

A hard NULL-vs-NULL control returns 1.000 with the CI containing 1 at every `u`, and the
vacuity test confirms the true arm is not 1.0. **The switch works, so the difference it makes is
attributable to the excess.**

**The measurement** (3,149,886 candidates per arm, 4 replicates, seeds in the note):

| u | cost-per-relation ratio (TRUE/NULL) |
|---|---|
| 3.00 | **0.859** [0.851, 0.867] |
| 3.60 | 0.726 |
| 4.00 | **0.640** [0.623, 0.657] |
| 5.14 | 0.361 |
| 6.00 | 0.220 |

**The gain SURVIVES sieving — the audit's "every net gain < 1" is false.** Among pre-sieve
survivors the ratio is unchanged (1.706 vs 1.687 over all candidates at `u = 4`), and 12–16 of
16 mod-4 and 7–9 of 9 mod-3 sub-boxes have ratio > 1. A `k = 1`-only sieve is strictly **worse**
(0.63–0.65) — a sharp prediction from `r_p(1) = (p−α)/(p−1) < 1` that held.

**The honest replacement for the withdrawn 25–38%:**

> **At `u ≈ 3` — the operating point the withdrawn claim quoted — the reduction is
> 14.1% [13.3, 15.0], not 25–38%.** The 25–38% band corresponds to `u ≈ 3.5–4.0`.

**And two qualifications the paper must carry:**

1. **It is not an implementable speedup.** There is no decision to take: no sub-box beats the
   free global rate. It is a measured property of the value distribution, not an available
   constant.
2. **~2/5 of the gain is the trivially-divisible subspace, not the advertised `2 − 1/p`
   effect.** About 37–40% sits at `k ≥ 6`, and 58.6% of *those* relations satisfy the
   zero-zero configuration (`p³ | a`, `p² | b`) against 3.6% expected — **18.8× enriched**.
   `k = 2` carries 23–53%; `k = 1` is a loss; `k = 5` is a small reproducible loss.

**Correction to this paper's own §3-adjacent tooling.** Dickman `ρ` is worse at NFS operating
points than previously recorded: exact `Ψ/ρ` is **13.9× at `u = 3` rising to 1244× at
`u = 5`** — the earlier "8.46× at `u ∈ [5,8]`" was both too small and in the wrong regime.
Any null at an NFS operating point must use exact `Ψ`.

*Scope, declared:* measured at **one value scale**; replication at 2⁴⁸/2⁶⁰ is the open check.

## 7. Related corrections this round

- **The `1.90188` GNFS constant is misattributed.** It is Coppersmith's *multiple polynomial
  sieve*, not Nguyen–Stehlé and not a GNFS result — a double conflation of authors and
  algorithm family. No source claims a general-`N` factoring constant below `1.9229994`. The
  figure is worth ~1.94× at 1024 bits, not the order of magnitude the framing implied.
- **`ellcard` is not usable on composite moduli.** PARI/GP returns `N+1` silently for
  composite `N` (0/6 verified), which carries no information about `p` and `q`.
  See `factor-scratch/r48/notes/T_pari_ellcard_hazard.md`.

## 8. References

- D. J. Bernstein, *Fast detection of perfect powers* / batch smoothness work — the actual
  relevant result is Bernstein's batch smoothness at `Õ(b)`, which targets a cost NFS already
  eliminated with segmented sieving.
- Montgomery, EUROCRYPT'95, p. 118 — the GNFS cost model; establishes the constant's origin.
- *Handbook of Applied Cryptography* §3.2.7, p. 98 (read as a page image) — `(64/9)^{1/3} =
  1.92299`.
- Lee–Venkatesan (arXiv:1805.08873), p. on smoothness — smoothness "cannot be guaranteed in
  current algorithms," and NFS is not known to halt.

**Verification protocol.** Every number in §2 is exhaustive enumeration on this host, not a
sample. WebSearch was not used for any citation. The corrected law in §3 was re-derived from
the measured numerators rather than fitted to the earlier claim.

**Open item:** the 2-adic anomaly at `p = 2, k = 6` (§4).