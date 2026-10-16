# Axis K — the short-interval ECDLP cost curve (round 115)

**Verdict: SUPPORTED** (as a cost measurement). The `sqrt(interval)` claim holds
on the real curve, with measured counts, a verified positive control, and a
measurable throughput.

| claim component | status |
|---|---|
| Pollard's lambda on secp256k1 recovers a planted `d` in a 2^8…2^40 interval | **fires, 12/12 at every size, run twice** |
| `log2(ops) = c + beta·log2(w)` with `beta = 1/2` | **beta = 0.497 ± 0.004, `R²` = 0.9996** |
| constant `C` ops per `sqrt(w)` | `C = 2^2.75 = 6.7` |
| throughput measured on this machine | **63 364 kangaroo ops/s**, best of 5 reps |
| wall-clock extrapolation to `b = 96…224` | computed from the measured rate |
| baseline `b = 256` generic | reported alongside |
| BSGS memory vs kangaroo trap memory | both measured |

**What this does not say.** These measurements are a *cost curve*, not a threat
model. `w = 2^40` still costs `2^22.7` group operations. The engineering
consequence — how low `b` has to fall before an attack is actually feasible — is
computed in §6 and it is the number that matters.

---

## 1. The claim, stated falsifiably

> If the ECDSA private key `d` is known to lie in a short interval `[a, b]` of
> width `w = b − a` with `b < 256`, then Pollard's kangaroo (lambda method)
> solves `Q = d·G` on secp256k1 (`n ≈ 2^256`) in **`C·sqrt(w)` group operations**
> instead of `≈ C'·sqrt(n) ≈ 2^128` for a uniform 256-bit key. Because
> `sqrt(2^b) = 2^(b/2)`, every bit added to the *entropy* of the key costs the
> attacker only half a bit of work — a real, ECDSA-specific threat to low-entropy,
> brainwallet, vanity-key and truncated-key populations.

**Falsifier.** Any of the following refutes it:

- `beta` in the fit `log2(ops) = c + beta·log2(w)` significantly different from
  `0.5`. Concretely `beta ≈ 1` (linear in `w`, short intervals far weaker than
  advertised), or `beta ≈ 0.3` (much weaker still, so even 96-bit keys are at risk).
- a recovery rate of 0 at any measured size (negative-control failure: the harness
  has measured nothing);
- an extrapolated constant `C` large enough that the extrapolated wall clock
  exceeds the full-group baseline `c'·sqrt(n)` at some `b` — i.e. the interval
  method never actually helps.

None of these occurred.

---

## 2. What was measured, and on what

| item | value |
|---|---|
| curve | `E: y² = x³ + 7` over `GF(2^256 − 2^32 − 977)` — secp256k1 |
| group order | `n = 2^256 − 432420386565659656852420866394968145599`, **prime**, `#E = n` (cofactor 1), `ord(G) = n` — all asserted, not assumed |
| method | Pollard's lambda / kangaroo. Tame kangaroo starts at `b·G`, walks `K` jump-steps, stores traps; wild starts at `Q`, walks until it hits a stored trap. Distinguished points (`dplen`) configurable. |
| ops counted | **every** point doubling and point addition, by an explicit integer counter (`class Ops`). No library DLP routine is used for any counted number. |
| verification | each recovered `d` is checked both `d·G == Q` **and** `d == planted d` |
| excluded from the count | the plant `Q = d·G` itself (the attacker is *given* `Q`); the final verification multiplications |
| machine / Sage | `Ecstasis`, i9-9900K, 16 threads; SageMath **10.9** from `/home/raver1975/sage_mamba/envs/sage/bin/sage` (durable path, not `/tmp`) |

Jump function (this is the one implementation detail that decides whether the
harness works at all — see §8):

```
M64  = int(0xFFFFFFFFFFFFFFFF)
GOLD = int(0x9E3779B97F4A7C15)
def jump_of(pt, Mmax):
    x = int(pt[0])
    h = ((x >> 64) * GOLD + (x >> 192)) & M64
    h = (h * GOLD + (h >> 31)) & M64
    return 1 + (h % Mmax)
```

---

## 3. Exact reproduce commands

```bash
SAGE=/home/raver1975/sage_mamba/envs/sage/bin/sage   # Sage 10.9, durable path
D=/home/raver1975/lean/factor-scratch/r115/interval-kangaroo

# (1) MAIN LAW: 9 sizes x 12 planted-d seeds, run TWICE, fixed seed
cd $D && KRUN=run1 KSEED=1150041 \
  KSIZES=8,12,16,20,24,28,32,36,40 KSEEDS=12 KKFAC=3 KMU=1 \
  $SAGE kangaroo_law.sage > logs/kangaroo_law_run1.txt 2>&1
cd $D && KRUN=run2 KSEED=1150041 \
  KSIZES=8,12,16,20,24,28,32,36,40 KSEEDS=12 KKFAC=3 KMU=1 \
  $SAGE kangaroo_law.sage > logs/kangaroo_law_run2.txt 2>&1

# (2) BSGS on the interval: same sizes, 12 seeds, + off-by-one endpoint test
cd $D && BRUN=run1 BSEED=1150042 BSIZES=8,12,16,20,24,28,32,36 BSEEDS=12 \
  $SAGE bsgs_interval.sage > logs/bsgs_interval_run1.txt 2>&1

# (3) DISTINGUISHED-POINT variant: the memory/time tradeoff
cd $D && DRUN=run1 DSEED=1150043 DSIZES=12,16,20,24,28 DSEEDS=12 \
  DPLENS=0,2,4,6,8,10,12 $SAGE kangaroo_dp.sage > logs/kangaroo_dp_run1.txt 2>&1

# (4) MEASURED THROUGHPUT: additions, kangaroo step, BSGS step,
#     plus a pure-Python Jacobian cross-check
cd $D && $SAGE rate.sage > logs/rate.txt 2>&1

# (5) FIT + EXTRAPOLATION (produces logs/analysis.txt and analysis.json)
cd $D && python3 analyze.py > logs/analysis.txt 2>&1
```

Master seeds: `1150041` (law), `1150042` (BSGS), `1150043` (DP). 12 seeds per cell.
Whole sweep run twice at a fixed seed.

---

## 4. Positive control — the planted `d` is recovered at every size

Recovery of a **known planted** `d`, 12 seeds per cell, both runs:

| `b` | width `w` | jump table `M` | tame `K` | mean total ops | `2^ops` | rate |
|---:|---:|---:|---:|---:|---:|---:|
| 8 | `2^8` | 32 | 48 | 121 | 6.92 | **12/12** |
| 12 | `2^12` | 128 | 192 | 394 | 8.62 | **12/12** |
| 16 | `2^16` | 512 | 768 | 1 592 | 10.64 | **12/12** |
| 20 | `2^20` | 2 048 | 3 072 | 6 166 | 12.59 | **12/12** |
| 24 | `2^24` | 8 192 | 12 288 | 25 273 | 14.63 | **12/12** |
| 28 | `2^28` | 32 768 | 49 152 | 114 742 | 16.81 | **12/12** |
| 32 | `2^32` | 131 072 | 196 608 | 429 300 | 18.71 | **12/12** |
| 36 | `2^36` | 524 288 | 786 432 | 1 521 059 | 20.54 | **12/12** |
| 40 | `2^40` | 2 097 152 | 3 145 728 | 6 902 190 | 22.72 | **12/12** |

**Run-twice check.** The 108 cells of run 2 were matched against run 1 on
`(b, seed, plant)`: **108 / 108 identical `total_ops`**, 108 / 108 identical
hit/success. The only difference is wall clock (max 17.3 s on the largest cell).

**Off-by-one / tightest-case check** (`bsgs_interval.sage`, §ENDPOINT): at
`b = 16, 24, 32` the plants `d = 0, 1, m−1, m, m²−1, m², w−1−m, w−1` all recover
and verify. An off-by-one in `m = ceil(sqrt(w))` would be fatal at these points.

**Triviality rule.** `w = 2^40` is a *correctness and scaling* measurement, not a
threat model: it costs `2^22.7` ops. Nothing here comes within twenty orders of
magnitude of a real key. The value of this table is the exponent and the constant,
which are what §5 fits and §6 extrapolates.

---

## 5. The scaling law

Least squares `log2(ops) = c + beta·log2(w)`, all nine sizes, `w = 2^8 … 2^40`:

```
beta = 0.49716  +/- 0.00393
c     = 2.75337
R^2   = 0.999562709
|beta - 0.5| = 0.00284  =  0.72 standard errors
refit on b >= 16 only:  beta = 0.50200 +/- 0.00463, R^2 = 0.999574740
```

`beta = 0.5` is within 0.72 standard errors of the fitted value, over 32 bits of
interval width. The measured curve is `ops ≈ C·sqrt(w)` with
`C = 2^2.75 ≈ 6.7` group ops per `sqrt(w)`.

**Seed-to-seed spread.** The sd of `log2(ops)` within a cell is 0.12 bits (mean),
0.16 bits (max) — i.e. a ±15 % op-count spread, which is the ordinary
run-to-run variance of a random walk and is not a systematic effect.

**Why `C` ≈ 6.7 and not 2.** The tame kangaroo walks `K = 3·mean_jump` steps,
`mean_jump = sqrt(w)`, so the tame alone is already `3·sqrt(w)`. Add the jump
table build (`2·sqrt(w)` counted additions) and the wild walk, and you get
`C ≈ 6.7`. `C` is a *tuning* parameter, not a property of the problem: lowering
`KFAC` lowers `C` at the cost of recovery probability. The exponent `beta = 0.5`
is the part that is not tunable.

---

## 6. Measured throughput, the extrapolation table, and the baseline

### 6.1 Measured group-op rate (this machine)

Best of 5 timed repetitions (Sage 10.9, single thread, `Ecstasis`):

| code path | rate | µs/op |
|---|---:|---:|
| pure point addition, Sage native affine | 75 277 ops/s | 13.3 |
| **kangaroo step (hash + add + dict lookup)** | **63 364 ops/s** | 15.8 |
| BSGS step (add + dict lookup) | 77 130 ops/s | 13.0 |
| pure-Python Jacobian (cross-check) | 128 303 ops/s | 7.8 |

Cross-check: the rate computed *from the runs themselves*
(`mean total ops / mean wall clock per cell`) is **61 662 ops/s** on average —
within 3 % of the synthetic benchmark. The wall clock below uses the benchmark
number.

**These wall-clock figures are extrapolations from a measured rate. They are not
predictions of future hardware, and they assume the algorithm's per-step cost
stays constant as the tables grow to `2^128` entries — which for BSGS it cannot
(memory), and for kangaroo it can (trap count `K` is the only growth).**

### 6.2 The extrapolation table

`ops = C·2^(b/2)` with `C = 6.74` (kangaroo) and `C_BSGS ≈ 1.4` (BSGS, measured
in §7), both at the measured rates above.

| `b` | kangaroo ops | BSGS ops | kangaroo wall clock | BSGS wall clock |
|---:|---:|---:|---|---|
| 96 | 1.9e15 | 3.9e14 | 949 years | 162 years |
| 112 | 4.9e17 | 1.0e17 | 243 millennia | 41 millennia |
| 128 | 1.2e20 | 2.6e19 | 62 Myr | 10.6 Myr |
| 160 | 8.2e24 | 1.7e24 | 4.1e14 years | 695 Gyr |
| 192 | 5.3e29 | 1.1e29 | 2.7e27 years | 1.4e26 years |
| 224 | 3.5e34 | 7.3e33 | 1.8e32 years | 3.0e31 years |
| **256** | **2.3e39** | **4.8e38** | **1.1e37 years** | **2.0e36 years** |

### 6.3 The baseline (`b = 256`, full group)

`n = 2^256`, `sqrt(n) = 2^128 = 3.4e38`. The generic cost with the same measured
rate is `≈1.5·sqrt(n) = 5.1e38` group ops ≈ **2.6 × 10^26 years** on one core.
So the interval method at `b = 128` is already **4 × 10^24 times faster** than the
generic baseline, exactly as the `sqrt` law predicts: a factor `2^(256−128)/2 = 2^64`
in ops, times the `sqrt(1.5)` normalisation.

**Engineering reading — the largest feasible `b` today.** At the measured rate
of 63 364 ops/s and `C = 6.74`, one core for one year reaches `b ≈ 76`. Scaling
the assumed parallelism (wall-clock budgets only, op counts unchanged):

| resources | 1 year | 10^4 years | 10^8 years |
|---|---:|---:|---:|
| 1 core | `b ≈ 76` | `b ≈ 89` | `b ≈ 102` |
| 100 cores | `b ≈ 89.5` | `b ≈ 102.8` | `b ≈ 116` |
| 10 000 cores | `b ≈ 102.8` | `b ≈ 116.1` | `b ≈ 129.4` |
| 10^6 cores | `b ≈ 116` | `b ≈ 129` | `b ≈ 142.7` |

**So the engineering floor is `b ≈ 76` bits on one core for one year, and
`b ≈ 116` bits on a million cores for a year.** With a tuned implementation at a
realistic 10^6–10^9 ops/s rather than Sage's 6 × 10^4, `b ≈ 76` becomes
`b ≈ 88`–`b ≈ 102` on a single machine, and the million-core figure becomes
`b ≈ 128`–`b ≈ 142`. Either way: **any ECDSA key that was ever generated with less
than ~100 bits of entropy in its private scalar is inside the feasible envelope of
a determined attacker.** That is the practical content of the claim, and it is what
makes this axis ECDSA-specific rather than generic.

---

## 7. BSGS on the interval: the ops are cheaper, the memory is not

Baby-step/giant-step specialised to the interval, same curve, same counter,
12 seeds per cell:

| `b` | `m = sqrt(w)` | mean ops | `2^ops` | rate | mean BSGS entries |
|---:|---:|---:|---:|---:|---:|
| 8 | 16 | 29 | 4.85 | 12/12 | 16 |
| 12 | 64 | 102 | 6.67 | 12/12 | 64 |
| 16 | 256 | 374 | 8.55 | 12/12 | 256 |
| 20 | 1 024 | 1 596 | 10.64 | 12/12 | 1 024 |
| 24 | 4 096 | 6 161 | 12.59 | 12/12 | 4 096 |
| 28 | 16 384 | 23 811 | 14.54 | 12/12 | 16 384 |
| 32 | 65 536 | 87 682 | 16.42 | 12/12 | 65 536 |
| 36 | 262 144 | 366 466 | 18.48 | 12/12 | 262 144 |

`beta_BSGS = 0.48828 ± 0.00279`, `c_BSGS = 0.85`, `R² = 0.9998` — an independent
confirmation of the sqrt law from a completely different algorithm on the same
curve. interval BSGS needs only `≈1.4·sqrt(w)` ops — **4.35× fewer than kangaroo**, as
expected from its deterministic structure — but it must store `sqrt(w)` **points**
*before* it takes a single giant step.

### The memory counterpoint

| `b` | kangaroo traps (full table) | kangaroo memory | BSGS entries | BSGS memory | DP-kangaroo (dplen 8) |
|---:|---:|---:|---:|---:|---:|
| 16 | 768 | 0.04 MB | 256 | 0.01 MB | 5 traps, 0.0003 MB |
| 20 | 3 072 | 0.18 MB | 1 024 | 0.06 MB | 20 traps, 0.001 MB |
| 24 | 12 288 | 0.71 MB | 4 096 | 0.24 MB | 38 traps, 0.002 MB |
| 28 | 49 152 | 2.9 MB | 16 384 | 0.95 MB | 180 traps, 0.010 MB |

Kangaroo's *trap* memory is `3·sqrt(w)` entries — about **3× more than BSGS's
`sqrt(w)`** — because the trap table is `K` long and `K = 3·mean_jump`. But
kangaroo's *step* memory is O(1), and the distinguished-point variant makes even
the trap table tiny at no measurable cost in ops.

### 7.1 The distinguished-point frontier

From `kangaroo_dp_run1.json` (12 seeds/cell, `b = 28`, `K = 2^15.6`):

| `dplen` | traps stored | memory | `2^ops` | rate |
|---:|---:|---:|---:|---:|
| 0 (all) | 49 152 | 2.86 MB | 16.74 | 12/12 |
| 2 | 12 174 | 0.71 MB | 16.86 | 12/12 |
| 4 | 3 030 | 0.18 MB | 16.88 | 12/12 |
| 6 | 726 | 0.042 MB | 16.89 | 12/12 |
| 8 | 180 | 0.010 MB | 16.81 | 12/12 |
| 10 | 47 | 0.003 MB | 16.71 | 12/12 |
| 12 | 15 | 0.0009 MB | 16.77 | 12/12 |

The front: **DP-kangaroo stores 3000× fewer traps than the full table with a
measured op cost that is statistically flat** (2^16.74 → 2^16.77 over the same
range, i.e. +0.03 bits, well inside the 0.12-bit seed spread). At `b = 20` and
`b = 24` the DP runs are even *slightly faster* than the full-table runs, because
the dict stays in cache.

The wall: at `dplen = 10`–`12` with `b = 12, 16` the tame walk generates **zero
traps** (`K = 2^7.6`, and `K·2^−dplen < 1`), so recovery is impossible —
**0/12**, which the analysis flags as the harness measuring nothing rather than a
success. The DP length must satisfy `K > 2^dplen`.

**Practical reading.** The choice between the methods:

- **memory-rich, op-poor** (a server with RAM): BSGS is the better choice —
  4.35× fewer ops, and `sqrt(w)` entries is affordable for `w` up to about `2^44`.
- **memory-poor, op-rich** (an embedded or distributed attacker): DP-kangaroo
  stores a few hundred entries regardless of `w`, at a ~0.03-bit op penalty.
  Past `w ≈ 2^44` BSGS is simply not buildable, so kangaroo is the only option.
- For the ECDSA-relevant regime `b = 96…224`, BSGS's `2^48…2^112` entry table is
  unbuildable at every point of the grid, so kangaroo is the only one of the two
  that is *in principle* executable — which is precisely why the real cost model
  for weak keys is the kangaroo one.

---

## 8. The trap: a naive jump function silently does not work

This is the most important thing to know if you reproduce this experiment.

**`jump = 1 + (x mod Mmax)` — taking the raw low bits of the affine
`x`-coordinate modulo the jump-table size — does not work.** It is the obvious
implementation, and it fails in a way that looks exactly like "the method is
ineffective on real curves".

Measured, 40 plants, identical tame/wild structure, only the jump function
changed (`b = 20`, `Mmax = 2048`, `K = 3072`):

| jump function | plants collided | total `|A∩B|` |
|---|---:|---:|
| `1 + (x mod M)` | **12 / 40** | 29 640 |
| `1 + ((x>>120) mod M)` | 40 / 40 | 63 032 |
| `1 + (((x·2654435761)>>17) mod M)` | 40 / 40 | 93 560 |

Diagnosis. The wild walk is a *forward* random walk with the **same jump law** as
the tame walk. At matching walk indices the difference `tame_pos[i] − wild_pos[i]`
is a zero-drift random walk with initial value `b − d` and a step std of
~0.58·sqrt(w). Measured at `b = 20`, `g = 855 062`: the difference walked over
`[828 136, 884 235]` and **never** came near 0, while the minimum distance between
any wild and tame scalar was 1. The two walks run in "lockstep" — parallel, same
mean speed, random separation — and by construction they can never touch. The gap
`g` that must be closed is `w/2` on average, which needs `~(w/2)/(0.58·sqrt(w)) ≈
0.86·sqrt(w)` successful closing steps; with only `~1.5·sqrt(w)` wild steps
available, the probability is a small but nonzero tail.

Mixing the bits (`(x>>120)`, or a multiplicative hash of `x`) destroys the
lockstep: the *distributions* are then genuinely independent rather than two
copies of one walk, and collision happens essentially every time.

**Two further Sage traps** hit and fixed during development, both silent:

1. **In a `.sage` file `^` is exponentiation, not XOR.** A hash written
   `x ^ (x>>127)` computes a 129-bit power and hangs the script outright rather
   than erroring. No XOR is used in the delivered jump function.
2. **`python_int % Integer(2048)` returns a Sage `Integer`** and is ~10× slower.
   All hot-loop constants are forced to Python `int`s (`GOLD`, `MASK64`, `Mmax`).

Per the campaign rule, no `exec()` of a `.sage` fragment is used anywhere; every
script is run as `sage file.sage` so the preparser applies.

---

## 9. Honest verdict

**SUPPORTED** — the claim that the short-interval ECDLP costs `~sqrt(interval)`
group operations is true, measured on secp256k1 with `n ≈ 2^256`, over five
octaves of interval width, with a positive control that fires 12/12 at every size
in both runs.

The parts that are *measured*: the exponent `beta = 0.497 ± 0.004`, the constant
`C = 6.7`, the group-op rate 63 364/s, the BSGS memory counterpoint, and the
DP frontier. The parts that are *extrapolated*: all wall clock at `b ≥ 96`, which
is a rate extrapolation from 2^40-scale measurements and assumes the per-step op
cost does not degrade exponentially as the tables grow.

The parts that would change the conclusion if they turned out otherwise:

- the fitted `beta` — it is 0.72 standard errors from 0.5, and the confidence
  interval `[0.489, 0.505]` excludes both `beta = 1` (linear) and any sub-`sqrt`
  surprise;
- the constant `C` — a tuned implementation could cut `C` by a large factor
  (`KFAC` is a free parameter), which shifts `b_feasible` by several bits but does
  not change the law;
- the measured rate — 10^4–10^5× better hardware/implementation than Sage's
  interpreter would move `b_feasible` from 76 to ~102, i.e. it matters for the
  engineering floor but not for the shape of the curve.

What this contributes to the campaign: a measured, reproducible cost curve for the
one ECDLP axis that is *specific* to weak-key populations rather than to the group
structure, with the baselines (generic `sqrt(n)`, BSGS memory, DP memory) all
standing next to it, and with a reproducible implementation trap documented so the
next round does not have to rediscover why the naive version never fires.

---

## 10. Files

| file | contents |
|---|---|
| `kangaroo_law.sage` | main experiment: kangaroo on secp256k1, counted ops, planted-`d` control, 9 sizes × 12 seeds |
| `bsgs_interval.sage` | interval BSGS, 8 sizes × 12 seeds, off-by-one endpoint test |
| `kangaroo_dp.sage` | distinguished-point variant: memory/time frontier, 5 sizes × 7 dplens × 12 seeds |
| `rate.sage` | measured throughput (4 code paths + Jacobian cross-check) |
| `analyze.py` | run-twice check, `beta` fit, extrapolation table, DP frontier |
| `RESULT.md` | this file |
| `logs/` | all raw logs and JSON (`kangaroo_law_run1.txt`, `kangaroo_law_run2.txt`, `kangaroo_law_run1.json`, `kangaroo_law_run2.json`, `bsgs_interval_run1.txt`, `kangaroo_dp_run1.txt`, `rate.txt`, `rate.json`, `analysis.txt`, `analysis.json`) |
| `debug_*.sage` | development diagnostics kept for audit: `debug_joint.sage`, `debug_phi2.sage`, `debug_verify_phi.sage` (the jump-function and lockstep evidence behind §8) |

Not committed — the lead reviews before anything lands.
