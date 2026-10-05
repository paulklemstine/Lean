# Lead verification of the Stange Q-kernel result (r112, lead)

**I independently re-ran and re-tested the subagent's central claim. It holds,
and it KILLS a claim this campaign has carried since r48.**

## What the subagent claims

Stange's Q-kernel method factors RSA moduli at ~75–80%, but the rate is the
classical order-finding constant **20/27**, not a property of the Q-kernel.
Success is exactly `v2(ord_p g) != v2(ord_q g)`, and is independent of the kernel
index `h = G/ord(g)` — which is what r48 spent a round refuting H3.1 about.

## What I checked myself

1. **Selftest rerun**: all controls pass independently (T4 positive — the paper's
   own N=62389=701·89 example recovers 701; T6 negative — 200 random inputs
   yield 0/200 invented factors; T7 — 120/120 agreement with the v2-law).
2. **Twice-run determinism**: `runA.json` vs `runB.json` differ **only** in
   timing fields; every count is bit-identical.
3. **The load-bearing claim, my own test**: 50 fresh trials, recomputing the v2-law
   from the reported 2-adic valuations rather than trusting the harness's flag:

   | | |
   |---|---|
   | kernel path verified | 40/50 |
   | v2-law predicted success | 40/50 |
   | **v2-law agrees with outcome** | **50/50** |

   Across mixed bit sizes (22/24/26) and mixed h. The kernel path succeeds
   **exactly** when, and **only** when, the two prime-power orders differ in
   2-adic valuation.

**Conclusion: the linear-algebra phase contributes no success probability.** The
Q-kernel is an expensive way to compute *a* multiple of `ord(g)`; the plain
strip-and-gcd that every order routine already ends with gives the same 20/27.

## One correction to my own verification (recorded)

My first attempt at this test compared the kernel path against a trivial multiple
of `ord(g)` and reported "DISAGREEMENT on 12/50 — kernel may carry information."
**That was my bug**: `one_trial()` draws its own `g` internally, so the two arms
were using different generators and I was comparing different experiments. After
fixing to a like-for-like comparison (the v2-law test above), the agreement is
50/50. Recording this because it is exactly the trap the campaign keeps hitting —
a plausible disagreement that dissolves on inspection, and which I nearly
reported as a finding against the subagent.

## What this kills

The campaign's stored memory says Stange's method is "the first method in 48
rounds" and works at 75%. The 75% is real and reproducible; the **attribution**
is not. The Q-kernel — the paper's novel contribution — is not doing the work.
This should correct the campaign's standing record rather than add to it.

## Limits

- Measured at 20–40-bit moduli only. Nothing here says anything about RSA scale,
  and the r48 regime gap (b capped at ~27 for n=10^20) still stands un-re-measured.
- 50 trials for my own agreement test; the subagent's battery is 135×2 plus a
  200-trial diagnostic.
- This is a NEGATIVE result about attribution, not a refutation of the method's
  correctness. The method factors; the kernel is just not why.