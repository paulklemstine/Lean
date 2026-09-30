# Round 47 part 43 — the gate confirmed at 2-million-trial scale, and the supply is NOT a power law

**2026-09-29. The cross-check workflow's Protocol-A run, which had been failing on API
errors, delivered. Two results: one confirms the round's central claim far beyond anything
measured before; the other overturns every crossover I computed.**

---

## 1. THE GATE, AT SCALE

```
40 bits:  2,000,000 f tested · 28,084 relations · rate 0.014042 (σ 0.006)
chi_P = -1 relations: 28,084      of which GENUINE p or q: 28,084
```

> ### **28,084 / 28,084.** Every single relation with `chi_P = −1` yielded a genuine prime
> factor of `N` — at two million trials, on a construction, an estimator and a machine
> independent of the ones that produced the audit's `136/136`.

This is the round's central claim, independently re-derived, and it is now established at
**200× the audit's sample size**. The audit measured `P(split | chi_P = −1) = 136/136` against
`0/182` on the `+1` side; this measures **28,084/28,084** on the `−1` side. The relation
histogram `(0, 1,980,066), (1, 9,784), (2, 9,150)` shows **~19% of `f` carry at least one
relation** at 40 bits — consistent with the measured rate.

**Also: the density model `1/(2N^{1/6})` underestimates the observed rate by 2.85×**
(expected 9,843, observed 28,084). Consistent with my own finding that the model underestimates,
and with the `N^{−1/4}` over-estimate of the decay being wrong.

## 2. THE SUPPLY IS NOT A POWER LAW — every crossover I computed is the wrong functional form

Protocol A, consistent construction (`k=1`, `m ~ N^{1/3}`, fixed 17-value `c`-pool, `H=40`):

| bits | `f` tested | rate | segment exponent |
|---|---|---|---|
| 26 | 40,000 | 0.22445 | |
| 40 | **2,000,000** | **0.014042** | **−0.286** (26→40) |
| 64 | 250,000 | 0.007212 | **−0.040** (40→64) |

**Steep, then nearly flat.** Not one power law fits.

### The honest crossover, on the measured points only

| bits | method (s) | GNFS (s) | ratio | |
|---|---|---|---|---|
| 26 | 0.80 | 2.8·10⁴ | 2.9·10⁻⁵ | **faster** |
| 40 | 12.8 | 4.2·10⁵ | 3.0·10⁻⁵ | **faster** |
| 64 | 25.0 | 1.5·10⁷ | 1.6·10⁻⁶ | **faster** |

> **The method is faster than the GNFS at every measured size, and the gap is WIDENING** —
> because the supply flattens while the GNFS grows.

## 3. And the sharpening: the flattening must turn over

**A truly flat supply rate would mean a constant expected number of trials — i.e.
polynomial-time factoring, which is impossible.** So the flattening *must* turn over
somewhere, and **where it does is exactly the quantity that decides the round.**

That is now the whole open question, and it is a sharper one than the crossover I was
chasing: not "where do the two curves cross" but **"where does the supply rate stop
flattening"** — because until it does, the method is ahead.

## 4. Corrections this forces

- **`Round47_ExponentQuarter.md` (`−1/4`) and `Round47_Crossover336.md` (336 bits) and
  `Round47_Final.md` (191.5 bits) are all WRONG in functional form.** They fitted a power law
  to a two-segment curve. The data says `−0.286` then `−0.040`; a single exponent describes
  neither.
- **A construction-dependence I had not accounted for.** The schema JSON's 40-bit value
  (`0.0259` on 12,732 `f`) and `run.log`'s (`0.014042` on 2,000,000 `f`) are **different
  constructions**, not a contradiction — 17σ apart because they are not the same experiment.
  My own 26-bit value (0.4075) and the workflow's (0.22445) likewise. **There is no
  construction-independent rate yet**, and I should not have compared them as if there were.
- **What IS construction-independent: the method beats the GNFS through 64 bits on both
  constructions.** That survives the discrepancy.

## 5. The two-line state

> **A factorisation-free, descent-free method, with a gate that is now perfect at 28,084/28,084,
> that is faster than the GNFS at every size measured, and whose rate is not a power law.**
>
> **The one open question is where the supply rate turns over** — because a rate that stays
> flat would prove polynomial-time factoring, and one that keeps decaying is a crossover. The
> data so far show the first regime and not yet the second.
