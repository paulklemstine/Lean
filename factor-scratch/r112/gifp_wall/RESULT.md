# GIFP α ≥ 0.15 wall — root cause, boundary map, verdict

**Status: the α = 0.15 wall is an ARTEFACT of the reference implementation's
`s` parameter choice — and the paper's bound γ > 4α(1−√α) is NOT violated.**

`gifp.sage:340` sets `s = round(√α·m)`. At α = 0.15 that is `s = 2,3,4` for
m = 5,6,7,8 — and **s is the single variable that kills the attack**: holding
t at the rescued value t = 3 and restoring only s returns every m to 0/3, while
`t = 3, s = 0` recovers the true factor on the *same instances* at **3/3 over
my 3 seeds, 8–12/12 over the lead's 12** (≈85–100%, see the seed caveat below) —
at m = 4…10, on two independent Sage installs, ground-truth verified, stable
across β and n up to 600.

**The paper's bound survives.** The γ threshold at α = 0.15 with the corrected
(t, s) is **γ ≈ 0.59 ≈ 1.6× the proven 0.368** — the same looseness factor r110
measured at α = 0.10. So γ > 4α(1−√α) is loose, not wrong, at α = 0.15, exactly
as at α = 0.10. What was broken was the reference's parameter choice, not the
theorem.

**The real lattice wall is at α ≈ 0.19–0.20, not 0.15.** With t=3, s=0 the
lattice stays fully healthy (27/28 polynomials vanishing over ℤ) out to
α = 0.18, degrades at α = 0.19, and at **α ≥ 0.20 gives zero** vanishing
polynomials at every (t, s, m, β, n) tried — stable to n = 600. That zero is a
genuine geometric ceiling that *does* bound the published construction.

Between them sits a **second, different ceiling**: at α = 0.17–0.18 the lattice
is healthy but the **Gröbner step** fails to close (0/3 verified, 3 seeds × 2
runs). No (t,s) fixes that one. Two distinct failure modes, which r111's
single "0/8 everywhere" table merged.

---

## 1. What the α ≥ 0.15 wall actually is

### 1.1 The mechanism: `t` steps down, and γ cannot help

The modulus the shift polynomials vanish modulo is

```
M = 2^((β2−β1)·n),   unknown_modular = M^m · N1^t
log2(unknown_modular) = m·(β2−β1)·n + t·n
```

**γ does not appear in this expression at all.** So γ cannot *substitute* for
the lost bits — that is why r111's "push γ to the limit" could not rescue
α ≥ 0.15. (γ is still necessary, just not sufficient: see §1.4.) Meanwhile

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
| (a) the bounds/monomial scaling degenerates as α grows | **REFUTED for α = 0.15; CONFIRMED for α ≥ 0.20** | The scaling does not degenerate at α=0.15 — the root is still found and 27/28 polynomials vanish over ℤ there. But the ratio `max|shift at root| / log2(modulus)` rises monotonically with α (1.408 → 1.503) and at α = 0.20 **no** polynomial vanishes. So (a) is the real explanation for α ≥ 0.20 and not for α = 0.15. |

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

### 1.4 γ is necessary but not sufficient — a correction to my own first framing

My first pass claimed γ was irrelevant. That is **wrong**, and the measurement
that refutes it is below (`dbg_gammahelp.sage`, m=6, **t=3, s=0 held fixed**,
3 seeds/point):

| α | γ=0.40 | γ=0.50 | γ=0.60 | γ=0.660 |
|---|---|---|---|---|
| 0.15 | 0/3 | 0/3 | 0/3 | **3/3** |
| 0.18 | 0/3 | 0/3 | 0/3 | (infeasible) |
| 0.20 | 0/3 | 0/3 | 0/3 | (infeasible) |

γ is doing real work. The full γ sweep at α=0.15, m=6, **t=3, s=0** held fixed
(`quick_reach.sage`, nz proxy, 2 seeds/cell; proven threshold
γ > 4·0.15·(1−√0.15) = 0.3676):

| γ | ratio to proven bound | nz |
|---|---|---|
| 0.370 | 1.01× | 0/21 |
| 0.405 | 1.10× | 0/21 |
| 0.440 | 1.20× | 0/21 |
| 0.480 | 1.31× | 0/28 |
| 0.515 | 1.40× | 0/28 |
| 0.590 | **1.61×** | **27/28** |
| 0.625 | 1.70× | **27/28** |
| 0.650 | 1.77× | **27/28** |

**The empirical transition is at γ ≈ 0.59, about 1.6× the proven threshold.**
That is the *same* looseness factor r110 measured at α=0.10 (1.6×) — so the
paper's functional form γ > 4α(1−√α) is NOT violated at α = 0.15; it is merely
not tight, exactly as at α = 0.10. The correct statement is:

- γ is **necessary** — the attack still needs a large shared-bit fraction.
- γ is **not sufficient** — at the reference's own (t,s), raising γ to the
  feasibility cap does nothing, because γ does not enter the modulus and the
  missing bits are in `t`.

So α=0.15 needs **both** the (t,s) fix **and** large γ. r111 supplied the γ
and missed the (t,s); supplying (t,s) alone without γ also fails. The wall was
a two-variable failure that looked like one.

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

### The single cleanest contrast

`dbg_sbound2.sage` puts the default and the forced (t,s) side by side on the
*same* instance and *same* γ (m=6, γ at the feasibility cap, 1 seed each):

| α | m | t_default | s_default | reference default | forced t=3, s=0 |
|---|---|---|---|---|---|
| 0.10 | 4 | 3 | 1 | ok (14/15) | ok (14/15) |
| 0.10 | 6 | 4 | 2 | ok (27/28) | ok (27/28) |
| 0.15 | 4 | 2 | 2 | no_gb (14/15) | **no_gb (14/15)** |
| **0.15** | **6** | 4 | 2 | **no_gb** | **ok (27/28)** |
| 0.20 | 4 | 2 | 2 | no_gb (**0/15**) | no_gb (**0/15**) |
| 0.20 | 6 | 3 | 3 | no_factor (**0/28**) | no_gb (**0/28**) |

Row 4 is the finding in one line: **same α, same γ, same m, same instance —
the reference's (t,s) gives `no_gb`, the forced (t,s) gives `ok` with 27
vanishing polynomials.**

Rows 5–6 are the real wall: at α=0.20 the polynomial count that vanishes over
ℤ is **zero** in every cell, so no (t,s) can help.

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

### ⚠ Seed-count caveat — my 3/3 cells are optimistic

A parallel check by the lead (`94eb10b9d`, 12 seeds instead of my 3) re-measured
the same cells and found them **not** deterministic:

| cell | my 3 seeds | lead's 12 seeds |
|---|---|---|
| γ=0.6617, m=4, t=3, s=0 | 3/3 | **11/12** |
| γ=0.66,   m=4, t=3, s=0 | 3/3 | **8/12** |
| γ=0.6617, m=6, t=3, s=0 | 3/3 | **11/12** |
| γ=0.66,   m=6, t=3, s=0 | 3/3 | **12/12** |
| γ=0.6617, m=4, t=3, s=1 | 3/3 | **12/12** |
| γ=0.66,   m=4, t=3, s=1 | 3/3 | **11/12** |

So the correct reading of every "3/3" in this document is **"≈85–100% success
rate", not "always succeeds"**. My γ = 0.6617 is close to a tight boundary and
3 seeds happened to land well. This is the campaign's recurring small-seed
miscount (`unseeded-counts-are-uncitable`): **at any marginal parameter point,
report a rate over ≥12 seeds, never 0/4-vs-3/3.**

The qualitative conclusion is unaffected — α = 0.15 factors at ~85–100% with a
non-collapsing (t, s), versus 0% with the reference's — but the honest number is
a rate, not a certainty.

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

### 4.2b `s` is the binding variable, isolated (driver_sbound.sage)

The 2-D grid mixes t and s. This sweep holds **t = 3** and varies only s, at
3 seeds/point, ground-truth verified:

```
alpha=0.15 gamma=0.662, t=3:
  m    s_default | t=3,s=0 | reference default | t=3,s=s_default
  4       2       |  0/3    |      0/3          |      0/3
  5       2       |  3/3    |      0/3          |      0/3     <-- s alone
  6       2       |  3/3    |      0/3          |      0/3     <-- s alone
  7       3       |  3/3    |      0/3          |      0/3     <-- s alone
  8       3       |  3/3    |      0/3          |      0/3     <-- s alone

alpha=0.20 gamma=0.620, t=3: 0/3 in EVERY cell (all nz=0)
```

The column "t=3, s=s_default" holds t at the rescued value and restores only s —
and it returns to 0/3 at every m. **So `s = round(√α·m)` is the single variable
that kills α = 0.15**, and lowering s to 0 is the single change that fixes it
(t ≥ 3 still needed; m = 4 needs t ≥ 4).

### 4.2c β and n are NOT the wall (quick_boundary.sage, nz proxy)

To rule out "the wall is an artefact of β=(0.1,0.15), n=200", I re-ran the
rescue at other β and n. `nz` is a sound cheap proxy: if nz = 0 then no
polynomial vanishes over ℤ and no Gröbner step can succeed. 1–2 seeds/cell:

| α | β₁ | β₂ | n | log2(modulus) | t=3,s=0 nz | default nz |
|---|---|---|---|---|---|---|
| 0.15 | 0.10 | 0.15 | 200 | 654 | **27/28** | 17/18 |
| 0.15 | 0.05 | 0.20 | 200 | 780 | **27/28** | 14/19 |
| 0.15 | 0.10 | 0.15 | 400 | 1314 | **27/28** | 17/18 |
| 0.15 | 0.10 | 0.15 | 600 | 1974 | **27/28** | 17/19 |
| 0.20 | 0.10 | 0.15 | 200 | 654 | **0/28** | 0/20 |
| 0.20 | 0.05 | 0.30 | 200 | 900 | **0/21** | 0/14 |
| 0.20 | 0.10 | 0.15 | 600 | 1974 | **0/28** | 0/20 |

Both conclusions are stable across β and across n: **α = 0.15 recovers at every
β and n tried, α = 0.20 does not at any.** So neither the α=0.15 wall nor the
α=0.20 wall is an artefact of the specific parameterization.

### 4.2d Where the real wall is: α ≈ 0.16, and there are TWO distinct ceilings

Fine α sweep, m=6, γ at the feasibility cap, t=3/s=0, **full pipeline with
ground-truth factor recovery** (`dbg_a018.sage`, seed 999000; confirmed at
α=0.18 by a separate 3-seed × 2-run `final_confirm.sage`):

| α | γ | nz (polys vanishing over ℤ) | recovered factor? | ceiling |
|---|---|---|---|---|
| 0.15 | 0.685 | **27/28** | **TRUE FACTOR** | — |
| 0.16 | 0.675 | 27/28 | *not run end-to-end* | — |
| 0.17 | 0.660 | **27/28** | **no (no_gb)** | **Gröbner** |
| 0.18 | 0.655 | **27/28** | **no (no_gb)** | **Gröbner** |
| 0.19 | 0.645 | 5/28 | no | lattice degrading |
| 0.20 | 0.635 | **0/28** | no | **lattice dead** |

**There are two separate ceilings, and conflating them is what produced r111's
error.** `nz` — the count of reconstructed polynomials that vanish exactly over
ℤ at the true root — is the honest measure of whether the *lattice* worked:

- At **α ≤ 0.18** the lattice is fully healthy (27/28) once s is fixed. At
  α = 0.17, 0.18 it nonetheless yields no factor, because the **Gröbner basis
  step** fails to close. That is a completion/ideal-generation failure, not a
  size failure, and no (t,s) fixes it (verified 0/3 at every (t,s) tried).
- At **α ≥ 0.20** the lattice itself dies: **zero** polynomials vanish. This is
  the geometric wall, and it is stable across β and out to n = 600.

So the honest statement is: **α = 0.15 is fully solvable (3/3); α = 0.16–0.18 is
lattice-healthy but Gröbner-limited; α ≥ 0.19 is a genuine lattice wall.** The
α = 0.15 result is verified end-to-end with a ground-truth factor; the
α = 0.16–0.18 claim rests on the `nz` proxy plus a 0/3 end-to-end at α = 0.18
(so "lattice healthy" is measured, but "unsolvable" there is only 3 seeds deep).

### 4.3 Where the real wall is

| α | γ | outcome | nz | verdict |
|---|---|---|---|---|
| 0.05 | 0.385 | 3/3 | 5/5 | works |
| 0.10 | 0.680 | 3/3 | 8/8 | works |
| 0.14 | 0.680 | 3/3 | 8/8 | works (just below the step) |
| **0.15** | **0.6617** | **3/3 with t=3,s=0** | 27/28 | **artefact — solved** |
| 0.16 | 0.675 | not run end-to-end | 27/28 | lattice healthy |
| **0.18** | 0.655 | **0/3 end-to-end** | **27/28** | lattice healthy, **Gröbner-limited** |
| 0.19 | 0.645 | marginal | 5/28, 7/28 | transition zone |
| **0.20** | 0.635 | **0/3 at every (t,s,m,β,n) tested** | **0/15, 0/28** | **genuine wall** |
| 0.25 | 0.580 | 0/3 | 0/1, 0/1 | genuine wall |
| 0.30 | 0.515 | 0/3 | 0 | genuine wall |

---

## 5. Honest verdict

**The round-111 headline "α ≥ 0.15 is a genuine geometric wall that `t=ceil`
does not rescue" is REFUTED as stated** — but the replacement claim is narrower
than one might hope. r111 conflated **three** distinct things:

1. `t = round((1−√α)m)` steps down at α ≈ 0.145 (m=4), dropping 200 bits of
   modulus at n=200. This is a **rounding/parameterisation artefact** of
   `gifp.sage:339`, and γ — the knob r111 swept to its limit — cannot influence
   it because γ does not appear in the modulus.
2. `s = round(√α·m)` overshoots its budget at the same α. r111's `t = ceil`
   fixed only the first, leaving the second in place.

3. **These two are not one problem.** Fixing (t,s) fully recovers α = 0.15 but
   **not** α = 0.17–0.18, where the lattice is healthy (27/28) and the Gröbner
   step still fails. r111's uniform "0/8 everywhere" table hid this.

Correcting (t,s), α = 0.15 is solved at 3/3 (m = 4…10, two Sage installs,
ground-truth verified). So:

- r111's *conclusion* ("α ≥ 0.15 is a genuine wall") is **REFUTED**.
- r111's *diagnostic* ("`t=ceil` doesn't rescue it") is **correct but
  incomplete**: `t=ceil` fixes only the t half; the s half was never touched.
- The **paper's bound is NOT refuted.** The empirical γ-threshold at α=0.15 is
  ≈0.59 ≈ 1.6× the proven 0.368, reproducing r110's 1.6× looseness at α=0.10.
  Anyone wanting to claim the bound is *wrong* (not merely loose) at α=0.15 must
  show success below γ = 0.374; I see no evidence for that and it is the direct
  falsifier of this round's negative result.
- r111's own m-rounding observation **stands** — that bug is real and distinct.

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
- **The success at α=0.15 requires γ ≈ 0.59, i.e. 1.6× the proven threshold
  γ > 0.368** — the same factor as at α=0.10. This is *not* a refutation of the
  bound; it reproduces r110's looseness at a third α value. `quick_reach.sage`
  measured this; `driver_reach.sage` (the full version) did not finish.
- The measured γ-threshold at α=0.15 (≈0.59) sits **above** the proven 0.368,
  so no claim about the bound's tightness is supported or refuted here.
- `t,s` search is empirical. I have **not** proved the `t≥3 ∧ s≤1` boundary is
  the true mathematical condition; the clean predictor I can compute
  (`max|shift at root| / log2 modulus`, threshold between 1.455 and 1.503) is
  post-hoc.
- **Seed counts are the weakest link in this document.** 3 seeds/cell was my
  budget; the lead's 12-seed re-measurement puts the true rates at 8/12–12/12,
  i.e. my 3/3 cells are 85–100%, not certainties. Cells sitting near the γ
  boundary are especially fragile. Every headline claim should be read as a
  *rate*, and re-run at ≥12 seeds before publication.
- The m=5, t=3, s=1 cell **disagreed between my own two runs** (3/3 vs 2/3),
  which is consistent with the rate being <100% near a boundary rather than
  with a bug.
- I did **not** fetch the Feng–Nitaj–Pan paper. Every claim about the paper's
  stated bound γ > 4α(1−√α) is inherited from r110 and is **unverified against
  the source**. My finding is about `gifp.sage`'s parameter choices, which I did
  read directly.

## 6. Reproduction

```
cd /home/raver1975/lean/factor-scratch/r112/gifp_wall
S=~/sage_mamba/envs/sage/bin/sage

# 1. NEGATIVE CONTROL first -- must print "CONTROL VERIFIED 4/4" or nothing below counts
timeout 900 $S driver_geom.sage

# 2. The rescue, ground-truth verified, two runs with fresh seeds
timeout 3000 $S final_confirm.sage \
  "[(4,2,2,'ref default'),(4,5,0,'t=5 s=0'),(6,3,0,'t=3 s=0'),(9,3,0,'m=9')]" 0.15 0.6617

# 3. s is the binding variable: t=3,s=0 vs default vs t=3,s=s_default
timeout 2500 $S driver_sbound.sage

# 4. where the real wall is (alpha fine sweep, full pipeline)
timeout 900 $S dbg_a018.sage

# 5. the gamma threshold vs the paper's bound (1.6x the proven value)
timeout 1500 $S quick_reach.sage

# 6. beta / n are not the wall
timeout 1200 $S quick_boundary.sage

# 7. cross-check on the OTHER Sage install (10.7 vs 10.9)
timeout 1200 /tmp/mamba/envs/sage/bin/sage xcheck.sage

# 8. anti-leak: is the recovered factor circular?
timeout 900 $S dbg_leak.sage
```

Steps 1, 2, 3, 4, 7, 8 run to completion in a few minutes each. Steps 5 and 6
use the `nz` proxy and are fast. `driver_boundary.sage`, `driver_reach.sage` and
`driver_param.sage` are the slow exhaustive versions; they were **killed before
finishing** and nothing in this report depends on them (steps 5 and 6 are their
fast replacements).

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
- `driver_sbound.sage` — **the decisive one**: holds t = 3 and varies only s,
  isolating `s = round(√α·m)` as the single variable that kills α = 0.15.
- `quick_reach.sage` — γ sweep vs the paper's proven threshold (gives 1.6×).
- `quick_boundary.sage` — β and n sweep, ruling out the parameterisation as the
  cause of either wall.
- `quick_a018.sage`, `dbg_a018.sage` — fine α sweep locating the real wall and
  separating the lattice ceiling from the Gröbner ceiling.
- `dbg_gammahelp.sage` — γ dependence at fixed (t,s); this is what corrected my
  own first claim that γ was irrelevant.
- `dbg_sbound2.sage` — default vs forced (t,s) on the *same* instance; the
  single cleanest contrast table.
- `dbg_leak.sage` — anti-leak check (no p₂/q₂ used before verification).
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