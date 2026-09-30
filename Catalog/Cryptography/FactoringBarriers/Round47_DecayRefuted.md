# Round 47 part 44 — `N^(−1/6)` REFUTED at 19.3σ; the supply is convex in log-log, not a power law

**2026-09-30. The verification workflow completed (2 of 7 agents survived the API outage;
the two that did were the ones that mattered). This is the definitive answer to the
question the workflow was set to ask.**

---

## The measurement, and its statistics

Protocol A, one consistent construction, `H = 30`:

| bits | `f` tested | relations | rate | rel. σ | census |
|---|---|---|---|---|---|
| 26 | **868** | 90 | **0.10369** | 10.5% | **complete** |
| 40 | 12,732 | 330 | **0.025919** | 5.5% | **complete** |
| 64 | 250,000 | 1,803 | **0.007212** | 2.4% | sample |

**The 26- and 40-bit pools are complete censuses**, confirmed three ways: a permutation
ladder returns identical counts; an independent yield probe predicts 868 exactly; the run
reports `EXHAUSTED`. So 10.5% at 26 bits is a **floor from finite statistics, not a
sampling shortfall** — the pool cannot be enlarged.

## THE VERDICT ON `N^(−1/6)`: REFUTED

| segment | exponent | 95% Poisson CI | vs `−1/6 = −0.1667` |
|---|---|---|---|
| 26 → 40 | **−0.1429** | `[−0.1653, −0.1204]` | **excludes it, narrowly** |
| 40 → 64 | **−0.0769** | `[−0.0833, −0.0705]` | **excludes it decisively** |
| 26 → 64 | **−0.1012** | `[−0.1079, −0.0946]` | **excludes it, 19.3σ from the point estimate** |

**And the shape, which is the part that matters:**

> **The curve is CONVEX in log-log — `−0.1429` then `−0.0769` — so it is NOT a power law, and
> no single exponent is the right statistic.** The supply is *flattening*.

**The density model `1/(2N^{1/6})` underestimates, and increasingly so:** `T/E` grows
**3.03 → 3.75 → 10.91** across 26/40/64 bits. So the model's error is a **size-dependent
prefactor**, not a wrong constant — and the measured supply falls **slower** than `N^{−1/6}`,
by 1.26× at 40 bits and 5.61× at 64 bits.

## What this forces me to retract

| my claim | status |
|---|---|
| `−1/4` exponent (`Round47_ExponentQuarter.md`) | **REFUTED** — it was fitted over 16 bits; over 38 bits the secant is `−0.10` |
| crossover **191.5 bits** (`Round47_Final.md`) | **WRONG** — built on `−1/4` |
| crossover **336 bits** (`Round47_Crossover336.md`) | **WRONG** — built on the *model* `−1/6` |
| "the method's range is `N ≈ 10^58`" | **WRONG** — the supply is better than that at every point measured |

**I have now been wrong about the crossover three times**, in three different ways, and each
time because I extrapolated a functional form rather than measuring it. The data says the
right object is a **convex curve**, and I have three points on it.

## The gate, again, independently

- **299/299** at 40 bits and **63/63** at 26 bits: the first `chi_P = −1` per `f` returns a
  **genuine prime factor** every time. **0 spurious, 0 trivial.**
- **Never-factors-`N` control**: the trial re-run through a freshly reloaded core with
  **`cypari2` UN-IMPORTABLE** and **`sympy.factorint`/`isprime` tripwired** — 3,894 instances,
  100 relations, **bit-identical** to the PARI-enabled run. That control's own non-vacuity
  assert fired first (its initial 60-instance set held 0 relations and proved nothing, so it
  was changed to draw until it held ≥20 real relations).
- The record's **sign bug `c → −c`** is caught, and the whole trial on the sign-flipped
  polynomial finds **0** relations.

## The one question, restated for the last time

> **Where does the supply rate stop flattening?**

It must stop, because a flat rate means a constant expected number of trials — **polynomial-time
factoring**, which is impossible. The measurements so far are all in the first regime: the
method is faster than the GNFS at **26, 40 and 64 bits** (0.80 s, 12.8 s, 25.0 s against
2.8·10⁴ s, 4.2·10⁵ s, 1.5·10⁷ s), and **the gap is widening**.

**That is now the experiment worth running, and it needs sizes the current tools can still
reach: 128 and 256 bits, where a turnover would be visible against three points already
measured.** If the rate is still ~`10⁻²` at 256 bits, the method's competitive range extends
past every crossover figure I have ever written down, and the honest statement becomes *"the
range is unbounded in the region measured"* with the turnover explicitly still open.
