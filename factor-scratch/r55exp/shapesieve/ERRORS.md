# ERRORS LOG — shapesieve round 55

## E1 (FIXED BEFORE IT MATTERED) — exp1_sievedomain.py was VACUOUS, and its own
## positive control caught it.

**What I wrote.** `exp1_sievedomain.py` computed, for moduli in six shape
families, the survival rate

    surv(N) = #{ u < M : gcd(u^2 mod N, P_B) = 1 },   B = 60, M = 20000

and reported the median survival rate per family. Prediction: identical across
shapes (shape-blind).

**What happened.** ALL SIX families returned *exactly* 2621/20000 = 0.13105,
including the positive control `2^12 * m` which I had predicted would fire
loudly. The mean, min, max and sd were all identical to 5 decimal places. The
script printed a confident per-cell table.

**Root cause.** `M^2 = 4*10^8` while `N ~ 9*10^11`. So for every single
`u < M` we had `u^2 < N`, hence `u^2 mod N = u^2` **identically**. The modulus
`N` never entered the computation at all. The statistic degenerated to

    surv = #{ u < M : gcd(u, P_B) = 1 } = M * prod_{q<=B} (1 - 1/q)

which is a constant: `0.13378` predicted by the Mertens product vs `0.13105`
observed. **I was measuring the Mertens product and calling it a shape test.**

**Why the control is what saved me.** I had built `POS CTRL 2^12*m` with the
stated purpose "this detector MUST fire; if it does not, exp1 measures
nothing", and it did not fire. That is the only reason this was caught before
being written up. A version without that control would have produced a
beautiful, clean, entirely empty "CONFIRMED: SIEVES ARE SHAPE-BLIND" table.

**The lesson, which is the actual finding of this round's method:** a
shape-blindness experiment must have `M^2 >> N`, i.e. the sieved quantity must
genuinely wrap around the modulus. Otherwise "shape-blind" is trivially true
because the shape is not in the room. This is the same failure mode as
`Harness That Works Is Not A Harness That Measures` in this project's memory.

**Fix.** `exp1b_sievedomain.py`: `N ~ 2^24`, `M = 200000`, so `M/N^{1/2} ~ 50`
and the reduction genuinely bites. Positive control re-run. Underpowered cells
labelled.

## E2 — exp2 first run asserted the wrong bit bound.
`assert 2**37 < N_shape < 2**41` with `a,b` drawn as 13-bit primes gave
`N_shape.bit_length() == 37`, i.e. `2**37` is not `< 2**37`. The assert was
`>` where it should have been `>=`, or the primes were one bit small. Changed
to an interval check on `.bit_length()` and to sampling fresh primes until the
bit lengths match within 1. Not load-bearing — it aborted before any
computation.

## E3 — exp3 (first version) HUNG on `smooth_set`. Cause: B = 16384 with
N = 2^26 enumerates ~10^7 smooth numbers by multiplicative closure, and the
Python-level `frontier` list grows without bound. Fixed by capping B at 1024,
dropping N to 2^22, and adding an explicit `RuntimeError` guard
(`len(frontier) > 3_000_000`) so the hang becomes a loud failure. Two silent
zero-byte output files were the only symptom; caught by checking `wc -l` rather
than trusting the absence of an error.

## E4 — exp4 P4.2 printed VACUOUS ROWS THAT READ "PASS". See ERRORS.md below.

## E5 — exp2_classgroup.py IS UNDERPOWERED AND ITS POSITIVE CONTROL DOES NOT
## FIRE. Reported honestly rather than spun.
Symptom: P2.2 printed `observed/predicted = 14.520   FIRES (<<1)? False`.
Root cause, diagnosed directly: for the sampled `b ~ 2^10` prime, the class
number `h(Q(sqrt b))` was **1 in 8 of 8 probes**. That is expected — the class
number of a real quadratic field is `~ sqrt(D) * L(1,chi)/pi`, and at
`sqrt(2^10) ~ 32` the expected value is O(1), so `h = 1` almost always. The
ratio `h(shape)/h(generic)` therefore collapses to `1 / median(h(pq))`, i.e. to
`1/2` — a **ratio of small integers**, not a measurement of a `N^{-1/3}` effect.

This is the exact "below ~20 expected events, label the row UNDERPOWERED"
failure: my script printed `per-cell expected events: 25 cells, all >20. not
underpowered.` That check counted SAMPLES, not the EVENTS PER CELL, and the
events per cell (a class number of order 1) is 1. **The underpowered check was
itself vacuous** — it is the E1 failure mode recurring inside the guard rail
that was supposed to prevent it.

To do exp2 properly one needs `b` large enough that `h(b) >> 1`, i.e. `b` of
several hundred bits, where `qfbclassno` costs ~2^(0.6 * bits) — measured on
this host: 2^33 discriminant -> 8.5 s, 2^38 -> 45.7 s. So `b ~ 2^300` is
hopeless here. **exp2 is NOT DETERMINABLE ON THIS HOST.** The identity
`h(Q(sqrt(a^2 b))) = h(Q(sqrt b))` is still exactly verified (25/25), and that
identity is the load-bearing part; but the *magnitude* of the class-group saving
is not measured, and I do not claim it.

## E6 — exp3b hung in `build()` for 20+ minutes. The bit budget was on the
## wrong quantity, and the family accepted 0 draws in 60 tries.
`g_a2b` drew `a = rp(6), b = rp(16)`; `g_a4b` drew `a = rp(5), b = rp(17)`. I
budgeted `a_bits + b_bits = 22` against a 20-22 bit target, forgetting that the
PRODUCT is `k*a_bits + b_bits`: `a^2*b` is 34 bits and `a^4*b` is 37 bits, both
far above the window. Measured acceptance: **g_a2b 0/60, g_a4b 0/60**. The
`while len(lst) < want` loop therefore spun forever on a generator that can
never produce an acceptable draw.

Two structural fixes, not cosmetic ones:
  (a) budget on the product, verified by measurement before use;
  (b) **a hard iteration cap** in `add()` that raises
      `"the bit budget is impossible, NOT a slow sample"`. This is the third
      time a silent hang has cost me time in this round (E3, E6, and the exp3
      smooth-set blow-up). The cap converts a hang into a loud failure.

## E7 — `smooth_flag_slow`, my own SELF-TEST reference, was WRONG THREE TIMES
and each bug looked like a hang. Found only by running it and watching.
  (1) stripped one prime factor per iteration -> needed ~20 passes;
  (2) `spf[1]` left at 0, so `spf[v//p]` returned 0 and `0 > B` forever;
  (3) **the real one**: for `v = p^2` with `p > B`, `p[m] = spf[v//p] = spf[p] = p`
      -- the value does NOT decrease. Confirmed empirically: 27359 values still
      stuck after 200 iterations, headed by `v = 3721 = 61^2`.
The lesson I want recorded: **the self-test I wrote to catch a bug in the fast
path was itself the buggy thing**, and it would have silently "passed" had it
not been slow enough to notice. Replaced with a direct definition
("v is B-smooth iff no prime > B divides it") that has no such failure mode.
The self-test now agrees exactly at B = 60, 256, 1024 on [0, 2^19).

## E8 — my own P3b.2 threshold was arbitrary and the check printed
## "VACUOUS DETECTOR" over a REAL effect.
I wrote "POS CTRL must show ratio >= 3". Measured: 1.11 at B = 1024. The
script printed `FIRES(>=3)? NO -- VACUOUS DETECTOR` and my own text called the
detector vacuous. But the effect is real -- it was my threshold that was
arbitrary. exp6 replaces the eyeball test with an EXACT permutation test
(184756 relabellings) against a negative control, and the verdict flips:
a^3 b p = 0.00038, POS CTRL a=5 p = 0.00038, NEG CTRL p = 0.25 (noise).
**A threshold I invented is not a control.** The permutation test against a
same-shape negative control is.
