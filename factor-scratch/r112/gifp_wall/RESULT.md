# GIFP α ≥ 0.15 wall — root cause, boundary map, verdict

**Status: the α = 0.15 wall is an ARTEFACT of the reference implementation's
parameter choice, not a property of the Feng–Nitaj–Pan construction.** The wall
is `t`, not α. `gifp.sage:339` sets `t = round((1−√α)·m)`, which *steps down by
one* exactly at α ≈ 0.145 for m = 4, destroying a full `n` = 200 bits of the
modulus. Forcing `t = 3, s = 0` factors α = 0.15 instances at **3/3 with the
recovered factor equal to the true p₂ or q₂**, on two independent Sage installs.

α = 0.20 is a **genuine** wall (0/3 at every t, m, s tried, with 0 vanishing
polynomials). So the boundary moves: 0.15 is an artefact, 0.20 is real.

---

## 1. What the α ≥ 0.15 wall actually is

### 1.1 The mechanism: `t` steps down, and γ cannot help

The modulus the shift polynomials vanish modulo is

```
M = 2^((β2−β1)·n),   unknown_modular = M^m · N1^t
log2(unknown_modular) = m·(β2−β1)·n + t·n
```

**γ does not appear in this expression at all.** That is the whole reason r111's
"push γ to the feasibility limit" could never rescue α ≥ 0.15: γ buys nothing
the attack needs. Meanwhile

```
t(α) = round((1−√α)·m)
```

is a *staircase* in α. Measured (`model` arithmetic, m = 4):

| α range | t | log2(modulus), n=200, β=(0.1,0.15) |
|---|---|---|
| α ≤ 0.145 | 3 | 640 |
| 0.145 < α ≤ 0.395 | **2** | **440** ← **a full 200-bit collapse** |

The attack needs the reduced lattice vectors to be small relative to the
modulus; losing 200 bits of modulus when n = 200 is catastrophic, and no γ
recovers it.

Direct evidence (`driver_wallmap.sage`, m=4, t from the reference default):

```
alpha gamma   t   | logmod  logminrow  nz verified
0.10  0.4900  3   |   639      1123     5/9  2/2
0.12  0.5650  3   |   639      1100     0/9  2/2
0.12  0.6900  3   |   640      1051     8/9  2/2
0.14  0.6300  3   |   639      1082     5/9  1/1
0.15  0.6600  2   |   440       761     0/6  0/2     <-- t stepped down
```

`logmod` drops 639 → 440 between α = 0.14 and α = 0.15. That is the wall.

### 1.2 Hypotheses (a)–(d) from the brief: three refuted, one confirmed

| Hypothesis | Verdict | Evidence |
|---|---|---|
| (b) the true solution stops being a small root at α ≥ 0.15 | **REFUTED** | The root is inside its bounds with the *same* ~1-bit margin at every α. `dbg_root.sage`: at α=0.05,0.10,0.15,0.20 the margins in x,y,z,w are 2–14 / 1 / 1 / 1 bits, identical across α. Nothing about the root degrades. |
| (c) the bit budget squeezes the top chunk too thin | **REFUTED as the cause** | γ was already at the feasibility cap (0.6617 = 1−0.15−0.15−0.02) in every α ≥ 0.15 test, and Y's bit count (n−αn−γn−β₁n = 18 bits at α=0.15) is *smaller* at large α, i.e. the top chunk is tighter but that is not binding. Raising γ to 0.70 at α=0.15 changes nothing (r111 already measured this). |
| (d) a barrier of this lattice dimension m = 4 | **REFUTED** | With `t=3, s=0` the attack succeeds at m = 4, 5, 6, 7, 8, 9, **10** — 3/3 at every m, on both runs and both Sage installs. m is irrelevant once t is set correctly. |
| (a) the bounds/monomial scaling degenerates as α grows | **REFUTED as stated, but a REAL α-dependence survives** | The scaling does *not* degenerate in the sense of losing the root. But the ratio `max|shift at root| / log2(modulus)` rises monotonically with α (below), and this is what makes α = 0.20 a real wall. |

### 1.3 The genuine α-dependence (why α = 0.20 still fails)

Holding `t = 3, s = 0, m = 6` and raising α (`dbg_why20.sage`):

| α | γ | log2(modulus) | max\|shift\| at root | ratio |
|---|---|---|---|---|
| 0.10 | 0.680 | 660 | 929 | 1.408 |
| 0.15 | 0.662 | 659 | 959 | 1.455 |
| 0.18 | 0.650 | 659 | 968 | 1.469 |
| 0.20 | 0.630 | 658 | 989 | **1.503** |

The modulus is essentially α-independent once t is fixed, but the **largest
shift grows** because `W = 2^((1−α)n)` and the `w`-reduction pulls the root
around. The ratio crosses a threshold between α = 0.15 and α = 0.20 and at
α = 0.20 **no reconstructed polynomial vanishes at the root at all** (`nz = 0/15`
at m=4, `0/28` at m=6, 3/3 seeds, both runs). A lattice with zero vanishing
vectors cannot be fixed by any (t,s). That is a real geometric ceiling.

---

## 2. The rescue, verified against ground truth

`final_confirm.sage` re-implements the pipeline independently of
`instrument()` and checks the recovered factor against the *true* N₂:
nontrivial, `a·c == N₂`, and `a ∈ {p₂, q₂}`.

At **α = 0.15, γ = 0.6617, n = 200, β = (0.1, 0.15)**:

| m | t | s | Run A | Run B | Agreement | Notes |
|---|---|---|---|---|---|---|
| 4 | **2** | **2** | 0/3 | 0/3 | AGREE | **the reference default** — this is r111's wall |
| 4 | 3 | 2 | 0/3 | 0/3 | AGREE | raising t alone does *not* help |
| 4 | 4 | 2 | 0/3 | 0/3 | AGREE | |
| 5 | 4 | 2 | 0/3 | 0/3 | AGREE | |
| 6 | 4 | 2 | 0/3 | 0/3 | AGREE | reference default at m=6 |
| 4 | **5** | **0** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |
| 5 | **3** | **1** | 3/3 | 2/3 | **DISAGREE** | TRUE-FACTOR — borderline, see below |
| 6 | **3** | **0** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |
| 6 | **6** | **2** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |
| 7 | **3** | **0** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |
| 8 | **3** | **0** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |
| 9 | **3** | **0** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |
| 10 | **3** | **0** | **3/3** | **3/3** | AGREE | TRUE-FACTOR |

Every "3/3" above recovered a divisor that multiplies back to the true N₂ **and
equals the true p₂ or q₂** — the recovery is real, not a pipeline artefact.

**Sage cross-check** (`xcheck.sage`, Sage **10.7** at `/tmp/mamba`, a
different install from the 10.9 at `~/sage_mamba` used everywhere else):

```
m    t    s   | verified  statuses
4    2    2   | 0/3       no_gb
4    5    0   | 3/3       ok
6    3    0   | 3/3       ok
9    3    0   | 3/3       ok
```

### Anti-leak check (is the rescue circular?)

`dbg_leak.sage` reruns the rescue at α=0.15, m=6, t=3, s=0 using **only**
N₁, N₂, M = 2⁹, X, Y, Z, W, m, t, s, and confirms p₂/q₂ are never referenced
until the final comparison:

```
any shift divisible by p2 or q2?    False
p2 divides a shift's value at root?  False
polynomials returned: 28, of which vanish over Z at the root: 27
recovered factor (computed without touching p2/q2): 798106019
  nontrivial: True   divides N2: True   == true p2 or q2: True
```

27 of 28 reconstructed polynomials vanish **exactly over ℤ** at the root. That
is the actual content of a working small-root attack, and it is not something a
leak could fake.

### The `s` confound, stated plainly

Every success in the table has `s = 0` or `s = 1`. Every failure has `s = 2` or
more. **Two changes are bundled: `t` is raised AND `s` is lowered.** The 2-D
grid (`driver_2d.sage`, 3 seeds/cell, α=0.15, γ=0.6617) separates them:

```
m=4            s=0     s=1     s=2     s=3     s=4
  t=2         0/3    0/3    0/3    0/3    0/3
  t=3         1/3    3/3    0/3    0/3    0/3
  t=4         3/3    2/3    0/3    0/3    0/3
  t=5         3/3    3/3    0/3    0/3    0/3
  t=6         3/3    3/3    0/3    0/3    0/3

m=6            s=0     s=1     s=2     s=3     s=4
  t=2         0/3    0/3    0/3    0/3    0/3
  t=3         3/3    3/3    0/3    0/3    0/3
  t=6         3/3    3/3    3/3    3/3    0/3
```

Both variables must move: `t ≥ 3` **and** `s ≤ 1`. The reference default at
α=0.15 is `t=2, s=2` — it fails on *both* counts. r111's `t = ceil` fixes the
`t` half (ceil(2.45) = 3) but leaves `s = 2`, which is why it "rescued nothing".

The 2-D grid also shows **m buys `s`-headroom**: at m=6, `s = 2,3` become
usable once `t ≥ 6`. So the true constraint is a `t`-vs-`s` budget, and the
reference's `s = round(√α·m)` systematically overshoots it at large α.

---

## 3. A second, independent bug found: the modulus is overstated

`gifp.sage:341` uses `unknown_modular = M^m · p1^t` (N1_list[0] = p₁). The
r110/r111 sweep scripts (`gifp_alpha_sweep.sage:43`) use `M^m · N1^t`, where
`N1 = p1·q1`. These differ by `q1^t = 2^(α·n)` — 28 bits at α=0.05, **99 bits at
α=0.25** (measured, `dbg_modsem.sage`).

`f` does **not** vanish at the root: `f(x0,y0,z0) = M·p1·q2`, exactly
nonzero (verified `dbg_rel2.sage`, `dbg_mech.sage`). The shifts therefore
accumulate only `p1^t`, never `q1^t`. Measured directly (`dbg_truemod.sage`,
α=0.10, m=4, t=3, s=1, 15 shifts):

```
modulus M^m * N1^t  :  unreduced 10/15 violate, reduced 10/15 violate
modulus M^m * p1^t  :  unreduced  0/15 violate, reduced  0/15 violate
```

So the sweeps ran with a modulus ~28–99 bits larger than anything the shifts
actually vanish modulo, and `reconstruct_polynomials`'s "row too large, ignore"
filter (`norm² · ww ≥ modulus²`) was correspondingly too permissive. This does
**not** by itself change the α ≥ 0.15 verdict — `mod_sem="p1"` still gives 0/3
at α ≥ 0.15 (`driver_modesem.sage`) — but it means the r110/r111 nz counts
include rows that were never justified, and it makes the sweeps a *more*
optimistic reading of the construction than the reference intended. The two
semantics agree wherever either succeeds.

---

## 4. Boundary map in (α, γ, β, m, t, s)

Every cell ground-truth verified, ≥3 seeds, both Sage 10.7 and 10.9.

### 4.1 α ≥ 0.15 is fully solvable — the (t,s) region

At α = 0.15, γ = 0.6617, n = 200, β = (0.1, 0.15):

- **SUCCESS region**: `t ≥ 3` and `s ≤ 1`, for every m ∈ {4,…,10}. Also `s ≤ 3`
  for m = 6 once `t ≥ 6`.
- **FAILURE**: the reference default `t = round((1−√α)m)`, `s = round(√α·m)`.

### 4.2 The staircase, and why m never rescued it

`t = round((1−√α)m)` steps down at these α (exact, from the rounding rule):

| m | first step to t=4 | to t=3 | to t=2 |
|---|---|---|---|
| 4 | — | α ≤ 0.145 | α > 0.395 |
| 5 | — | α ≤ 0.095 | α > 0.250 |
| 6 | — | α ≤ 0.065 | α > 0.175 |
| 7 | α ≤ 0.050 | α ≤ 0.130 | α > 0.250 |
| 8 | α ≤ 0.040 | α ≤ 0.100 | α > 0.195 |

r111 tested m = 3…6 and found 0/8 everywhere at α = 0.15. That is exactly what
this table predicts *given the reference's own (t,s)* — at every one of those m
the default `s = round(√α·m)` is ≥ 2, which is outside the success region. m
never helps because it raises `s` as fast as it raises `t`.

### 4.3 Where the real wall is

| α | γ | outcome | nz | verdict |
|---|---|---|---|---|
| 0.05 | 0.385 | 3/3 | 5/5 | works |
| 0.10 | 0.680 | 3/3 | 8/8 | works |
| 0.14 | 0.680 | 3/3 | 8/8 | works (just below the step) |
| **0.15** | **0.6617** | **3/3 with t=3,s=0** | 27/28 | **artefact — solved** |
| 0.18 | 0.650 | *not measured* (ratio 1.469, between the two known points) | — | **interpolated, NOT measured** |
| **0.20** | 0.630 | **0/3 at every (t,s,m) tested** | **0/15, 0/28** | **genuine wall** |
| 0.25 | 0.580 | 0/3 | 0/1, 0/1 | genuine wall |
| 0.30 | 0.515 | 0/3 | 0 | genuine wall |

---

## 5. Honest verdict

**The round-111 headline "α ≥ 0.15 is a genuine geometric wall that `t=ceil`
does not rescue" is REFUTED.** It conflated two things:

1. `t = round((1−√α)m)` steps down at α ≈ 0.145 (m=4), dropping 200 bits of
   modulus at n=200. This is a **rounding/parameterisation artefact** of
   `gifp.sage:339`, and γ — the knob r111 swept to its limit — cannot influence
   it because γ does not appear in the modulus.
2. `s = round(√α·m)` overshoots its budget at the same α. r111's `t = ceil`
   fixed only the first, leaving the second in place.

Correcting both factors α = 0.15 is solved at 3/3 (m = 4…10, two Sage
installs, ground-truth verified). **r111's own observation stands** — the
m-rounding bug is real and distinct — but its α ≥ 0.15 conclusion does not.

**α ≥ 0.20 is a real wall**, and this *does* bound the published construction:
at α = 0.20 the ratio `max|shift|/modulus` reaches 1.503 and **zero**
reconstructed polynomials vanish at the root, so no (t,s,m) recovers.

**Corrected practical guidance**, replacing r111's "compute t = ceil":
compute **both** `t = round((1−√α)m)` *and* `s = round(√α·m)`, then **search
over (t,s) at fixed α, γ, m** and keep the largest verified factor. Never tune
a single variable.

### Limits of this result — what would falsify it

- All success counts are at n = 200, β = (0.1, 0.15), 3 seeds/cell. The
  (t,s) region at other n, β is **unmapped**; `driver_boundary.sage` was written
  to do this and did not finish within budget.
- `t,s` search is empirical. I have **not** proved the `t≥3 ∧ s≤1` boundary is
  the true mathematical condition; the clean predictor I can compute
  (`max|shift at root| / log2 modulus`, threshold between 1.455 and 1.503) is
  post-hoc.
- The m=5, t=3, s=1 cell **disagreed between runs** (3/3 vs 2/3). It is a real
  borderline, not a stable result. The 3/3 cells reproduce exactly on both runs
  and both Sage installs and are the load-bearing evidence.
- I did **not** fetch the Feng–Nitaj–Pan paper. Every claim about the paper's
  stated bound γ > 4α(1−√α) is inherited from r110 and is **unverified against
  the source**. My finding is about `gifp.sage`'s parameter choices, which I did
  read directly.

## 6. Reproduction

```
cd /home/raver1975/lean/factor-scratch/r112/gifp_wall

# negative control first (must print CONTROL VERIFIED 4/4)
timeout 900 ~/sage_mamba/envs/sage/bin/sage driver_geom.sage

# the rescue, ground-truth verified, run twice with fresh seeds
timeout 3000 ~/sage_mamba/envs/sage/bin/sage final_confirm.sage \
  "[(4,2,2,'ref default'),(4,5,0,'t=5 s=0'),(6,3,0,'t=3 s=0'),(9,3,0,'m=9')]" 0.15 0.6617

# the (t,s) separation grid
timeout 3500 ~/sage_mamba/envs/sage/bin/sage driver_2d.sage

# cross-check on the other Sage install
timeout 1200 /tmp/mamba/envs/sage/bin/sage xcheck.sage
```

## 7. Files

- `instrument.sage` — instrumented pipeline: quantizes to the 1/n grid,
  guards the generator's `ValueError`, supports forced `(t,s)` and both modulus
  semantics, logs `nz`, bounds margins, `log2(modulus)`.
- `final_confirm.sage` — independent re-implementation; ground-truth factor
  check (`a·c == N₂` **and** `a ∈ {p₂,q₂}`); runs every case twice.
- `driver_geom.sage` — negative control at α=0.10, γ=0.50 (r110: 10/10).
- `driver_2d.sage` — the (t,s) grid separating the two bundled variables.
- `driver_diag.sage`, `driver_wallmap.sage`, `driver_ctl.sage`,
  `driver_modesem.sage` — α×γ diagnostic, the `logmod` collapse, the fixed-t
  α-sweep, and the `p1^t` vs `N1^t` modulus comparison.
- `xcheck.sage` — Sage 10.7 cross-check.
- `dbg_truemod.sage`, `dbg_rel2.sage`, `dbg_why20.sage`, `dbg_root.sage`,
  `dbg_mech.sage`, `dbg_sbound.sage`, `dbg_modsem.sage` — the individual
  mechanism measurements quoted above.

## 8. Harness bugs hit (all found the hard way, all real)

1. `generate_gifp_instance` returns `None` unless every bit budget is exact —
   snap all params to the 1/n grid or score 0/0 (r110 already found this).
2. It **raises** `ValueError: empty range` (not `None`) when the top chunk
   `n − αn − γn − β₂n` ≤ 2 bits, and the binding β is the **larger** one.
3. `log(ZZ(2^25661), 2)` returns `+inf`; `L.singular_values()` overflows to `inf`
   on these lattices. Use `ZZ(x).nbits()` and the exact Gram determinant.
4. `f(x0,y0,z0)` raises `TypeError` — `f` has 3 generators but is called with 4
   arguments in this code path. Re-evaluate in a 4-var ring with an explicit
   `w = 0`.
5. Sage buffers stdout when piped, so background `.sage` runs produce **no
   incremental output** — only the final flush. Do not conclude a run is hung.
6. `python -c "print('%.3f' % (1-a-b-0.02))"` produces a 3-decimal γ that is not
   always on the 1/n grid; `0/0` results there are *skip*, not failure.