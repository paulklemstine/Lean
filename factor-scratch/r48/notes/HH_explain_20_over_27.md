# Where 20/27 comes from — closing a puzzle I left open myself

**Round 48/49, orchestrator. `_shared/explain_20_over_27.py`.**

## The open item

I verified that the Stange method's success probability is **exactly `20/27`** (measured
0.73325, −1.08σ from 0.740741), **refuted my own derivation of `2/3`** (+8.93σ), and then wrote
in `notes/X_verify_20_over_27.md`:

> **"The mechanism producing 20/27 remains UNEXPLAINED — measured and confirmed, not derived.
> Stated rather than papered over, because a measured constant with an unknown origin is still
> a correct number and a plausible derivation would not be."**

That is now closed.

## The derivation

Success ⟺ `v₂(ord_p g) ≠ v₂(ord_q g)`. The law of `v₂(ord_p g)` depends on `s := v₂(p−1)`:

- In a cyclic group of order `m = 2^s·u` with `g = a^j` uniform, `v₂(ord g) = s − min(s, v₂(j))`,
  with `P(v₂(j)=i) = 2^{-(i+1)}` for `i < s` and `P(j ≡ 0 mod 2^s) = 2^{-s}`.
- For random primes, `s` itself is geometric: **`P(s = j) = 2^{-j}`, `j ≥ 1`.**

> ### ⚠️ FATAL CORRECTION (2026-10-03, adversarial audit `KK_audit_amendments.md`)
>
> **The first version of this note stated `P(s = j) = 2^{-(j+1)}`. That law has total mass
> 0.5, not 1.0 — it was never a probability law.** Measured over 216,815 primes below 3·10⁶:
> `P(s=1) = 0.500574`, `P(s=2) = 0.250038`, `P(s=3) = 0.124604` — that is `2^{-j}`, not
> `2^{-(j+1)}`.
>
> **With the wrong law the sum converges to `5/27`, not `20/27`** (exactly, in rational
> arithmetic; `20/27 = 4 × 5/27`). And the code papered over this with an **undeclared
> renormalisation** — dividing the truncated mass — a step this note never mentioned.
>
> **An undeclared renormalisation is precisely what let a factor-2 error in the law pass as
> confirmation of a prettier constant.** It is the same shape as the round's standing failure
> modes: something silently patching something else.
>
> **The fix is simpler than the error.** With `P(s=j) = 2^{-j}` the weight vector has mass
> exactly 1, **no renormalisation is needed**, and the sum is `20/27` with no residual:
>
> | `S_max` | sum (no renormalisation) | deficit vs 20/27 |
> |---|---|---|
> | 10 | 0.738791006583 | −1.95×10⁻³ |
> | 20 | 0.740738833397 | −1.91×10⁻⁶ |
> | 40 | 0.740740740739 | −1.82×10⁻¹² |
> | 60 | 0.740740740741 | **−1.73×10⁻¹⁸** |
>
> **So `20/27` is correct and now derived without a fudge.** The derivation is real; the
> published version of it was not.
>
> A lesson worth keeping, and it is the sharpest one this round has produced:
>
> > **A renormalisation is an assertion that your quantity does not sum to its natural value.
> > If you need one, the quantity is usually wrong — find out which, and write the
> > renormalisation down.**

Averaging `P(v₂(ord_p g) ≠ v₂(ord_q g))` over the joint law of `(s_p, s_q)`:

| s_p \ s_q | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| 1 | 0.5000 | 0.7500 | 0.8750 | 0.9375 | 0.9688 | 0.9844 |
| 2 | 0.7500 | 0.6250 | 0.8125 | 0.9062 | 0.9531 | 0.9766 |
| 3 | 0.8750 | 0.8125 | 0.6562 | 0.8281 | 0.9141 | 0.9570 |

> **AVERAGE = 20/27 exactly** (under the corrected law; see the box above)
>
> **The constant is fully explained.** It is not `20/27` by coincidence of notation; it is the
`P(v₂(ord_p g) ≠ v₂(ord_q g))` for two random odd primes, and the closed form of that average is
`20/27`.

## Is the truncation an artefact? No — checked directly

The average is computed as a truncated, renormalised sum over `s_p, s_q ≤ S_max`. I used
`S_max = 12`, which carries a truncation error. **A truncation artefact matching `20/27` to
four digits would have been a serious problem with this result**, so it was checked:

| `S_max` | value | error vs 20/27 |
|---|---|---|
| 6 | 0.73286488 | −7.88×10⁻³ |
| 8 | 0.73873581 | −2.00×10⁻³ |
| 10 | 0.74023607 | −5.05×10⁻⁴ |
| **12 (wrong law + renorm)** | **0.74061428** | −1.26×10⁻⁴ **(SUPERSEDED — see the FATAL box)** |
| 16 | 0.74073283 | −7.91×10⁻⁶ |
| 20 | 0.74074025 | −4.94×10⁻⁷ |
| 24 | 0.74074071 | −3.09×10⁻⁸ |
| 30 | 0.74074074 | **−4.83×10⁻¹⁰** |

Monotone and geometric — **but this table was computed under the WRONG law with a
renormalisation**, so it is retained only as a record of what I first computed, not as evidence.
It remains true that a truncation artefact would drift or oscillate; it does not rule out the
defect above, which was a wrong summand rather than a bad cut-off. The corrected computation
needs no truncation caveat at all.

## My refuted derivation was wrong TWICE, and the self-test caught the second error

1. **Wrong law.** I used `P(v₂(ord) = k) = 2^{-(k+1)}` — which holds **only** when `s = 1`, i.e.
   `p ≡ 3 (mod 4)`. Random primes are `≡ 3 (mod 4)` only half the time.
2. **Wrong even in that case.** For `s = 1` the distribution is **truncated** to `{0,1}` with
   probability `1/2` each, so `P(unequal) = 2·(1/2)(1/2) = 1/2`, **not `2/3`**. I had summed an
   infinite geometric series that does not apply.

**The second error was caught only because the self-test asserted `P(unequal | s_p = s_q = 1) =
2/3` and the code returned `0.500000`.** Had I written the test to match my expectation instead
of the arithmetic, I would have published a third wrong derivation — and this one would have
looked more respectable than the first, because it is closer to correct.

## What this does and does not change

**Unchanged.** The 20/27 constant, the optimality bound of paper #525, and every measured rate
— all of which were computed against the empirical rate, not against a derivation. Deriving the
constant explains where it comes from; it retroactively justifies nothing that depended on it.

**Changed.** The census entry that said the mechanism was unexplained now has an explanation, and
papers #523/#524 can state the constant as a *derived* quantity rather than a measured-and-hoped-
for one.

## The lesson, which is the third instance today

A derivation that fails a self-test is worth more than a derivation that is never tested. Both of
my wrong derivations were caught by something other than care: the first by an agent's
recomputation, the second by an assertion in my own test. In both cases the *asymmetry* was the
tell — `s = 1` was assumed to be the general case.

**Standing rule, now earned three times today:**

> **Before averaging over a distribution, check what you have conditioned on.** `s = 1` was true
> for half the primes and I treated it as true for both. The other two instances were a
> uniformity assumption on `a²−b³` (k=1) and a parity assumption (E-7). In every case the error
> was the same: an unconditional-looking step applied inside a conditioned regime.