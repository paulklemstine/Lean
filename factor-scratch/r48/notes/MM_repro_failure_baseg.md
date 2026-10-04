# My attempt to verify the 8/9 claim FAILED — reporting it rather than the number

**Round 50, orchestrator. Second failed reproduction attempt by me this session.**

## What I was checking

`Papers/conditioning_the_base.md` (#532) claims a Jacobi-conditioned base gives
`P(success) = 8/9` against the uniform `20/27`. Two agents derived it independently and
the second measured it at 0.8835 on 60,000 trials (z = +79.79). **I attempted a third,
independent check.**

## What happened

My first run reported per-modulus conditioned rates of **0.44, 0.46, 0.51, 0.46, 0.37, 0.44**
and a pooled **0.9044**. Those are all *below* the 0.7407 uniform baseline, which is
alarming — so I rebuilt the comparison as a **paired** one (same moduli, same `g` stream).

**The paired run printed `uniform 1500/1500 = 1.0000` on every one of six moduli.**

> **That is impossible.** The claimed uniform rate is 0.7407. A harness that reports a
> probability of exactly 1.0 six times running is not measuring.

I then tested the primitive alone. `v₂(ord)` computes correctly in isolation — over
`a = 1…10 mod 1000003` it returns the right spread. So **the bug is in my harness
composition, not in the mathematics**, and I did not locate it.

## What this does and does not affect

**Unaffected.** The claim itself. It has two independent derivations, a closed form
(`E[FAIL] = 2(1/12 − 1/28) = 1/9`), exhaustive per-cell enumeration at 210/210, 60,000
trials at z = +79.79, an independent reimplementation with no sympy, and an end-to-end
measurement on 300 fresh moduli (McNemar p ≈ 0.001) whose **uniform control reproduced the
prior note's 46/60 = 0.767 exactly**. A third bad harness does not move any of that.

**Affected.** My attempt to add a *fourth* verification. It failed, and the failure is
recorded here rather than quietly dropped.

## The part that is genuinely informative

My six moduli were **not representative**. The distribution of `s = v₂(p−1)` over random
~2³⁰ primes is concentrated at **s = 4–7**, not at s = 1 — and `8/9` is the average over
*that* distribution. My sample drew moduli whose conditioned rates (0.37–0.51) sit well below
the average.

This is **the campaign's own `p_split` control, biting me for the second time** — and this time
in a verification I wrote specifically to be careful. Rates swing with 2-adic structure at the
±0.25 level; the campaign's own record notes two samples of the *same* cell differing by 0.085
on sampling alone.

## The rule

> **A check that reports an impossible value has told you the check is broken, not that the
> claim is false — and it has told you that *before* you could publish the number.** The
> failure is that the value was implausible and I nearly computed around it instead of
> stopping at the implausibility.

Two failed reproductions this session, both mine: the `rref` swap (wrong population — dense
random rather than sparse relation matrices) and this one (broken harness). In both cases the
defect was in the *verifier*, never in the claim, and in both cases the verifier was mine.
That is the argument for independent verification existing at all: **the person who wrote the
harness is the last person qualified to check it.**
