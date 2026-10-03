# The E-6b "EC baseline" is a Dickman prediction, not a measurement

**Orchestrator note, verified independently. This is the decisive forensic result of round 48.**

## The claim under test

`Experiments/E6B_RESULTS.md` reports a milestone:

> `P(|Cl(Q(√-d))| B-smooth) = 1.000 vs EC baseline 0.925`

chained through `FACTORING_PROGRAM_SUMMARY.md:24-29` into E-6c and E-7, and ultimately into
the program's claim of *"a live, evidence-backed lead on class-group lotteries that could yield
an ECM-independent L[1/2] method"*.

## The finding

E-6b's own class-number arm is `h ≤ 1684`. That is `log2(1684) = 10.72` bits. The only `B`
anywhere in the E-6 thread is E-6b's `B = 1000` (`E6B_RESULTS.md:4`). The Dickman smoothness
probability for an object of 10.72 bits at `B = 1000` is

    u  = log2(1684) / log2(1000) = 1.0754
    rho(u) = 0.927264        <-- vs the reported "EC baseline" of 0.925

**Agreement to three significant figures, at exactly the scale of the arm it is supposed to be
compared against.** Computed with `_shared/dickman.py`, whose `rho` is verified against the
standard table (rho(2)=0.3069, rho(3)=0.04861, rho(4)=0.004911) and whose null harness
reproduces rho to within 1.43 sigma.

## What this does and does not prove

**Proves:** `0.925` is *not* an independent measurement of an elliptic-curve order. It is the
theoretical smoothness of an 11-bit number at `B = 1000`. The milestone "1.000 vs 0.925" was
therefore comparing a measured rate against **the Dickman prediction for the same object size**.
It is not an ECM measurement at all, and it was never matched to the `~2^60` EC order size that
E-6b's own text states (`E6B_RESULTS.md:8-9`).

**Does not prove:** that 0.925 was computed deliberately as a Dickman value. It is equally
consistent with a uniform-random baseline evaluated at the class-number arm's scale — which is
the same defect either way. Either way the number is not an ECM measurement, so the word
"EC" in `ec_smooth` is wrong, and the 1.000-vs-0.925 comparison is void.

Note the harness bug this would have been caught by: `_shared/dickman.py` was originally written
so its own null reproduces rho. The E-thread needed exactly that check and never had it.

## The number that runs the OTHER way — and is more interesting

E-6c reports `0.720` for the class-number arm at **29 bits**. Dickman at that scale is

    u = 29 / log2(1000) = 2.910
    rho(u) = 0.0587

**`0.720` is 12.3x ABOVE the uniform prediction.** If that number is real, it says imaginary
quadratic class numbers are dramatically smoother than uniform integers — a genuine
distributional fact about `Cl(Q(√-q))`, and precisely the property the E-6/E-7 lottery needs.

So the thread contains one number that is a self-referential prediction (E-6b: 0.925) and one
that would be a real discovery (E-6c: 0.720), and **neither can be checked, because no `.py`
was ever committed for E-6b, E-6c or E-7.** Verified: `git log --all --diff-filter=A` over
`Experiments/e6*` and `Experiments/e7*` returns no Python file, while
`FACTORING_PROGRAM_SUMMARY.md:4` claims *"All experiments reproducible, committed, pushed."*

## The three arms, and what each would have to be

| arm | reported | Dickman at that arm's own scale | reading |
|---|---|---|---|
| E-6b class | 1.000 (h ≤ 1684, 11 bits) | 0.927 | consistent — small objects are nearly always B-smooth |
| E-6b "EC" | 0.925 | **0.927** | **the prediction for the class arm itself; not an ECM measurement** |
| E-6c class | 0.720 (29 bits) | 0.0587 | **12.3x above uniform — would be a real finding** |
| E-6c "EC" | 0.440 (29 bits) | 0.0587 | same anomaly, smaller |
| E-7 class | 0.400 (scale unrecorded) | uncomputable | no B, no scale recorded anywhere |
| E-7 "EC" | 0.320 (scale unrecorded) | uncomputable | Fisher p = 0.769 — a coin flip |

## What replaces this

Re-run the whole thread with: code committed, `B` recorded, class-number bit-length recorded,
EC arm at matched order bit-length, and the Dickman null in the harness. Dispatched as
`exp/e6c_recheck/`. Until that lands, the program's frontier claim — an ECM-independent L[1/2]
via class-group lotteries — has **no supporting evidence at all**, and separately may be
structurally dead (see the H1 dichotomy in `00_HYPOTHESIS.md`: `Cl(O_D/p)` is trivial when
`p ∤ D` and cyclic of order exactly `p` when `p | D`, giving walk cost `N^{1/4}`, not `L[1/2]`).