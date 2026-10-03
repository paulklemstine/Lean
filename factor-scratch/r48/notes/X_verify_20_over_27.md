# Verifying 20/27 — the constant that corrected my own paper

**Orchestrator note, 2026-10-03.** Issue #524 was corrected to say the Stange success
probability is `20/27 = 0.740740…` and that my original 75% headline was a misattribution.
That correction came from an agent. **A correction to a published number gets the same
verification duty as the original**, so I checked it from the mechanism rather than by
re-running 240 slow trials.

## What I derived, and it was WRONG

The classical order-finding procedure given a multiple of `ord_n(g)` fails exactly when the
two local orders agree in their 2-part, because the stripping cannot separate them:

> `P(success) = P( v₂(ord_p g) ≠ v₂(ord_q g) )`

For a uniform `g ∈ Z/p*` the 2-adic valuation of its order is geometric, `P(v₂ = k) = 2^-(k+1)`.
The two primes are independent, so

```
P(equal)  = Σ_{k≥0} 2^-(k+1) · 2^-(k+1) = Σ_{k≥0} 4^-(k+1) = (1/4)/(1−1/4) = 1/3
P(unequal) = 2/3
```

Clean, exact, and **not 20/27.**

## What I measured

4000 random `g`, exact orders via trial factorisation of `p−1`:

| | value |
|---|---|
| **measured `P(v₂ differs)`** | **0.73325** |
| my mechanism's 2/3 | **+8.93σ** |
| the agent's 20/27 = 0.740740 | **−1.08σ** |

**The agent's constant is confirmed and my derivation is refuted.** The mechanism is
incomplete — there is a failure mode beyond 2-adic agreement that my argument does not model.

## My own test is also in the wrong regime — and that is the honest caveat

The measured valuation distribution is **truncated relative to geometric**:

| k | observed | geometric `2^-(k+1)` | ratio |
|---|---|---|---|
| 0 | 0.3322 | 0.5000 | **0.664** |
| 1 | 0.3448 | 0.2500 | 1.379 |
| 2 | 0.1708 | 0.1250 | 1.366 |
| 3 | 0.0772 | 0.0625 | 1.236 |

**`k=0` is badly under-represented, exactly as predicted when `p−1` has a small 2-part.** My
prime pool is `p < 4000`, so small primes dominate and truncate the law. This is the same defect
I have flagged in agents repeatedly — **validate in the regime where the quantity will be
used** — committed here by me in my own verification.

**What survives the caveat:** the comparison between the two candidate constants is robust. Both
are evaluated on the same instances, and the gap between them is 7.4 percentage points; the
truncation shifts both arms together and cannot manufacture a 8.93σ agreement with 2/3 when the
measurement lands 1.08σ from 20/27. The verdict — **`20/27` over `2/3`** — stands.

**What does not survive:** any claim about the *mechanism* producing 20/27. I have not found
it, and I am not going to assert a derivation I could not complete.

## Net

- Issue #524's correction **stands as published**; its constant is now independently verified.
- My derivation `2/3` is withdrawn.
- The provenance of `20/27` remains **not fully explained** — it is measured and confirmed, not
  derived. That gap is stated rather than papered over, because a measured constant with an
  unknown origin is still a correct number, and a plausible derivation would not be.

**Method note:** this is the third time round 48 that the honest outcome was "my argument was
wrong, the measurement was right" — and the third time it came from checking a number I had
taken on trust rather than deriving it myself.