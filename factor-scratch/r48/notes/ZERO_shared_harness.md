# Round 48 — shared measurement harness, and the three bugs it caught

**The orchestrator's own note. Every axis in this round shares one smoothness function,
because a matched-twin control is meaningless if the candidates and the baseline use
different implementations.**

File: `_shared/dickman.py`. Run `python3 dickman.py` — must print ALL SELFTESTS PASS.

## What it provides

- `rho(u)` — Dickman rho, via RK4 on a uniform grid with linear interpolation.
  Known table values verified: rho(1.5)=0.5945, rho(2)=0.3069, rho(3)=0.04861,
  rho(4)=0.004911.
- `is_smooth(n, B)` — **exact** B-smoothness. No float comparison anywhere.
- `largest_prime_factor(n)` — exact.
- `ecm_baseline_smooth_rate(bitlen, B, trials)` — the matched-scale null.

## Why exactness is a discipline, not a preference

The round-47 lesson was `int(n**(1/3))` understating `floor(n^(1/3))` at every perfect
cube, which manufactured a fake "rigorous refutation" that was then committed and
published. The self-test therefore probes the **tightest** cases, not representative
ones: `is_smooth(997**3, 997)` must be True and `is_smooth(1009**3, 997)` must be False —
a prime one step above the bound. Those two lines catch the entire bug class.

## The three bugs the self-test caught (all mine, all before any agent used the harness)

1. **`rho(0)` returned 0 instead of 1.** The guard was `if u <= 0`, but rho is defined
   as 1 on `[0,1]` and 0 only on `u < 0`.

2. **`is_smooth(1009**3, 997)` returned True — a false positive.** In `_all_prime_factors_le`
   the code iterated `factorint(...).values()`, which are the **EXPONENTS**, not the
   primes. So `1009^3` was judged 997-smooth because its exponent `3 <= 997`. This is
   the worst bug in the set: it inflates every smoothness rate toward 1, i.e. it
   manufactures exactly the "my candidate group is smoother than ECM" result the round
   is looking for. The fix carries an explicit warning comment, because the natural
   "simplification" re-breaks it.

3. **My own test was wrong.** `lpf(12*35*11) == 35` — but 35 is not prime; the correct
   value is 11. A test that fails because the test is wrong is as corrosive as one that
   fails because the code is wrong.

## The calibration caught bug 2 as a 1000-sigma signal

The null harness — does a uniform integer reproduce Dickman? — is the load-bearing part.
With bug 2 present it reported:

| setting | measured | rho(u) | deviation |
|---|---|---|---|
| 48b, B=2^14 | 0.2517 | 0.0191 | **107 sigma** |
| 48b, B=2^10 | 0.4828 | 0.0006 | **1228 sigma** |
| 32b, B=2^8 | 0.3538 | 0.0049 | **315 sigma** |

After the fix:

| setting | measured | rho(u) | deviation |
|---|---|---|---|
| 48b, B=2^14 | 0.0220 | 0.0191 | 1.34 sigma |
| 48b, B=2^10 | 0.0005 | 0.0006 | 0.30 sigma |
| 32b, B=2^8 | 0.0065 | 0.0049 | 1.43 sigma |

**The lesson worth carrying: the failure was loud, but only because the null existed.**
A smoothness counter with no null harness would have silently reported those inflated
rates as a discovery. Note also that the calibration is at *moderate* size (32-48 bits) on
purpose — Dickman's theorem is asymptotic, so smaller is both a better test of the theory
and affordable; the first version at 64 bits/2^20 was ~1.5e9 trial-division steps.

## A methodological note: I misdiagnosed this harness twice

The harness timed out (exit 124) twice. The first time I blamed `is_smooth` for
trial-dividing 64-bit numbers up to B=2^20 and "fixed" it with a primality early-exit —
which was **wrong**; that fix was harmless but addressed nothing. The actual cause was
`rho` integrating with h=1e-6 and calling `rho(t-1)` at each of ~3e6 steps, so the LRU
cache filled with millions of distinct floats.

**Two timeouts, two confident wrong diagnoses, and the second was a "fix" I shipped
before measuring.** The discipline that would have caught it: when a thing times out,
measure where the time goes *before* theorising. The 3-second version of this file —
profile the hot loop first — would have found it immediately.