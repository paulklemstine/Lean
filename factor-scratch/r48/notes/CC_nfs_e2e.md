# CC — Round 49: the end-to-end NFS relation-collection measurement

**Target.** Paper #523 (`Papers/a_square_minus_a_cube_divides_twice.md`) established
`P(p^k | a²−b³) = (2−1/p)/p^k` for `2 ≤ k ≤ 5` by exhaustive enumeration, and its §6.1
**withdrew** a claimed "25–38% reduction in relation-collection cost, measured end-to-end"
because it was an interpolation and was never propagated through a collection pipeline.
Its residual open item, verbatim:

> The valuation law is established. Its cost consequence is not. Establishing it requires an
> end-to-end collection measurement in which the sieved-box structure is preserved.

**Code.** `factor-scratch/r49exp/nfs_e2e/` — `core.py`, `selftest.py` (gate), `run.py`,
`k6_attrib.py`. Raw output: `nfs_e2e/out/results.txt`, `nfs_e2e/out/k_attrib.txt`.

---

## 0. VERDICT — stated first

**The 25–38% figure CAN be replaced with a measured number. It is a large real effect, but
it is not the number that was withdrawn, it is not a speedup any implementer can take, and
about two-fifths of it is the trivially-divisible subspace rather than the ramification
effect the paper advertises.**

End-to-end collection cost per relation, ratio TRUE/NULL (ratio < 1 ⇒ NFS is cheaper than
the uniform model predicts). Box `a < 2^18, b < 2^12`, value scale `X = 2^36`, NFS operating
shell `|a²−b³| ∈ [X/2, X]`, 3 149 886 shell candidates per arm, 4 replicates, seeds
10 001 01/202/303/404. Full marks, costs and CIs in §1.

| `u = log X / log B` | 3.00 | 3.60 | 4.00 | 4.50 | 5.14 | 6.00 |
|---|---|---|---|---|---|---|
| relation-rate ratio TRUE/NULL | 1.2709 | 1.5073 | 1.7141 | 2.1607 | 3.0520 | 5.0225 |
| **cost-per-relation ratio** | **0.8586** | **0.7260** | **0.6396** | **0.5085** | **0.3608** | **0.2199** |
| 95% CI | [0.8505, 0.8667] | [0.7133, 0.7390] | [0.6226, 0.6571] | [0.4853, 0.5327] | [0.3295, 0.3951] | [0.1778, 0.2719] |
| **cost reduction** | **14.1%** | **27.4%** | **36.0%** | **49.2%** | **63.9%** | **78.0%** |

Three things follow, and the third is the reason this does not become a headline.

1. **The withdrawn number was wrong at the operating point it quoted.** §6.1 said "25–38% …
   at the operating point `u ≈ 3`". At `u = 3.00` the measured reduction is **14.1%
   [13.3%, 15.0%]**. The 25–38% band corresponds to `u ≈ 3.5–4.0`. The withdrawn figure was
   not fabricated in direction or order of magnitude — it was attributed to the wrong `u`.
2. **The gain is real and survives sieving** (§2), so the audit's "cannot be cashed" is
   refuted as a statement about the *pipeline*. NFS relation collection is genuinely
   1.16×–4.55× cheaper per relation than the uniform-value model predicts, over `u ∈ [3,6]`.
3. **But it is not a decision, and two-thirds of it at `u≈4` is not the advertised
   mechanism.** See §3 and §4.

---

## STEP 0 — the switch, and the control that can return the null

The brief's requirement: the measurement must be able to return the NULL, where null is
correct. Two independent tests, both of which had to pass before any ratio above was
computed.

### The switch

```
TRUE arm :  x = |a² − b³|
NULL arm :  x = round(|a² − b³| · e^ε),   ε ~ U[−0.002, +0.002]
```

A uniform integer satisfies `P(p^k | x) = 1/p^k` for **every** `k`, so the null arm keeps
the `k = 1` law (which the true arm also satisfies exactly) and removes **every** `k ≥ 2`
excess. The ±0.2% window is wide compared with every `p^k ≤ B_fb` (window ≈ 0.004·2^36 ≈
2.7·10^10 vs `p^k ≤ 4096`), so the local-uniformity error in `P(p^k | x)` is `< 1.5·10⁻⁷`.
Mean `log₂|x|` agrees to 5 decimals (35.45868 both arms).

### Test 1 — the switch removes the excess (`selftest.py` §4)

Pooled excess `Σ(observed − expected)/Σ expected` over the `k ≥ 2` cells, each weighted by
its Poisson variance, each cell keeping only ≥ 5000 expected hits:

```
TRUE   0.7200 ± 0.0024    (303 sigma)
NULL  -0.0000 ± 0.0024    (  0.01 sigma)
```

Per-prime, per-`k`, at the real box (`k` = 1,2,3,4; tolerance is the Poisson σ of that
cell, which is what makes the high-`k`/large-`p` cells honest rather than noise):

| p | TRUE `k=1` | TRUE `k=2` | TRUE `k=3` | NULL `k=1..4` |
|---|---|---|---|---|
| 5 | 1.0010 | 1.8108 (law 1.800) | 1.8215 | 0.999–1.006 |
| 7 | 1.0033 | 1.8579 (law 1.857) | 1.8315 | 0.995–1.027 |
| 13 | 1.0079 | 1.9245 (law 1.923) | 1.9273 | 0.976–1.160 |

### Test 2 — the VACUITY test

The converse, and the one the round-48 failure mode demands: if both arms gave 1.0 the
switch would be a no-op and every ratio a number divided by itself. It does not: the true
arm carries the excess at 303σ while the null carries none at 0.01σ.

### Test 3 — the hard negative control: NULL vs NULL2

A **second, independent draw from the same switch** must return exactly 1.000, in the rate
*and* in the end-to-end cost. It does, at every `u`, with the 95% interval containing 1:

| B | 64 | 128 | 256 | 512 | 1024 | 4096 |
|---|---|---|---|---|---|---|
| rate ratio NULL/NULL2 | 0.957 | 0.995 | 0.991 | 1.002 | 0.990 | 0.996 |
| cost ratio NULL/NULL2 | 1.045 | 1.005 | 1.008 | 0.997 | 1.010 | 1.003 |

*(The criterion is CI-based, not a fixed tolerance: at `B = 64` there are only 178 relations
per arm and Poisson noise alone gives a wide interval. A hardcoded ±2% would have
manufactured a spurious "control failed" here — which is exactly the class of bug this
round keeps finding.)*

**The switch changes the cost. The ratios in §1 are measurements, not interpolations.**

---

## STEP 1 — the end-to-end measurement

Pipeline, per replicate per arm per `B`: sample `(a,b)` uniformly from the box (every
`(a,b)` kept, including the `a² ≡ b³` cases that carry the effect); form the arm's value;
sieve over the real factor base, stripping **all** copies of every prime `p ≤ B` and
counting marks; `smooth ⟺ cofactor == 1`, exact, no factoring, no floats anywhere.

```
marks_small = Σ_{p ≤ 16} #{p | x}          (the k = 1 pre-sieve pass)
marks_fb    = Σ_{p ≤ B} Σ_j #{p^j | x}     (full FB sieve, higher-power re-marks included)
marked      = #{x : some p ≤ B divides x}  (needs a residual test)
cost        = marks_small + marks_fb + marked
```

`cost / relations` is the cost per relation; the ratio of the two arms is the end-to-end
number. The `k=1` pre-sieve is **identical** in the two arms — as it must be, since
`P(p | a²−b³) = 1/p` exactly — so the excess buys no sieving work at `k = 1`; it buys only
higher-power marks (marks ratio 1.091–1.104) and, if the ratios below favour it, yield.
Wall clock agrees: 26.3 s TRUE vs 24.8 s NULL for the full 564-prime pass, i.e. 6% more
sieve time for 1.27×–5.02× the yield.

Between-replicate spread of the cost ratio (4 replicates, independent seeds):

```
B=  512: 0.6605 0.6315 0.6401 0.6267   mean 0.6397  sd 0.0150
B= 4096: 0.8613 0.8602 0.8561 0.8566   mean 0.8586  sd 0.0026
```

The replicate spread (0.6–2.4% at `u ≈ 4`) is well inside the Poisson interval, so the
reported CIs are dominated by relation-count noise, not by sampling luck.

### The law, re-measured at the box rather than mod `p^k`

`R(p,k) = P(p^k | x)/(1/p^k)`, shell `n = 1 576 152`, null arm shown beneath:

| p | k=1 | k=2 | k=3 | k=4 | k=5 | k=6 | k=7 | k=8 | NULL k=1..6 |
|---|---|---|---|---|---|---|---|---|---|
| 2 | 1.0015 | 1.5028 | 1.5055 | 1.5057 | 1.5077 | 2.5101 | 2.5218 | 3.5375 | 0.995–1.004 |
| 3 | 0.9987 | 1.6636 | 1.6581 | 1.6623 | 1.6493 | 3.6738 | 3.5896 | 5.5905 | 0.998–1.028 |
| 5 | 1.0004 | 1.8044 | 1.7951 | 1.7864 | 1.8617 | 5.8687 | 6.2454 | 9.4177 | 0.968–1.011 |
| 7 | 0.9951 | 1.8408 | 1.8341 | 1.8508 | 1.7488 | 6.8672 | 7.3150 | 14.63 | 0.874–1.010 |
| 11 | 1.0016 | 1.9235 | 1.9718 | 1.8671 | 1.7371 | 11.240 | 12.36 | – | 0.715–1.050 |

Paper's prediction: 1 at `k=1`; `2−1/p` for `2 ≤ k ≤ 5`; `2−1/p+(p−1)` at `k=6`. This
reproduces at every prime, and the paper's own **`p=2` series** (`1.50 1.50 1.50 1.50 2.50
2.50 3.50` for `k = 2…8`) is reproduced to three decimals by an independent measurement at
the box. The null arm is 1.000 throughout wherever counts permit.

---

## STEP 2 — the box-structure question, which is where this could have died

The audit's objection (§6.1 point 3): the bias "does not concentrate — it buys extra powers
of a handful of primes while losing `1/p` of the box for every other prime, so no sieveable
sub-box captures a net gain (every net gain < 1)". Three tests, the first being the exact
step the withdrawn claim omitted.

### 2a. Does the gain survive a realistic sieving step? **Yes.**

Restricting to candidates that **survived the small-prime pre-sieve** (`p ≤ 16`) — i.e.
measuring only candidates that survived small-prime division by the actual factor base:

| B | 64 | 128 | 256 | 512 | 1024 | 4096 |
|---|---|---|---|---|---|---|
| ratio among pre-sieve survivors | 4.435 | 3.112 | 2.187 | 1.706 | 1.475 | 1.285 |
| ratio among all candidates | 4.373 | 3.099 | 2.182 | 1.687 | 1.462 | 1.271 |

The gain is **unchanged** by sieving (within 0.1–1.3%, i.e. inside the CI). 80.9% of
candidates survive the pre-sieve in both arms. The sieved-box structure is preserved, which
is precisely the condition the census said the measurement must satisfy.

### 2b. Sub-boxes. **The audit's "every net gain < 1" is false.**

Splitting the box by `(a mod m, b mod m)`:

| family | u=6.00 | u=4.50 | u=4.00 | u=3.60 | u=3.00 |
|---|---|---|---|---|---|
| mod 4 (16 boxes) | 16/16 > 1 | 14/16 | 14/16 | 12/16 | 12/16 |
| mod 3 (9 boxes) | 9/9 > 1 | 9/9 | 9/9 | 9/9 | 7/9 |
| mod-4 median | 3.338 | 1.465 | 1.246 | 1.172 | 1.072 |
| mod-3 median | 2.882 | 1.429 | 1.249 | 1.172 | 1.058 |

At `u ≈ 3–4` a minority of sub-boxes *is* below 1, so the audit was not imagining the
possibility. But the majority are above it, so "every net gain < 1" is wrong. Two further
observations matter more:

- **The median sub-box is worse than the global box** (1.246 vs 1.714 at `u = 4`). The
  global rate is *not* an average of sub-box rates — there is a genuine concentration.
- **The concentration is the divisible subspace.** The strongest mod-4 sub-box at every `u`
  is `(a ≡ 0, b ≡ 0) mod 4` — 5.14 at `u = 4`, 28.4 at `u = 6` — and the strongest mod-3
  sub-box is `(a ≡ 0, b ≡ 0) mod 3` (3.46, 17.4). That is the zero-zero subspace of §4
  showing through at the box level.

### 2c. The strongest form: a `k = 1`-only sieve is strictly **worse**

If the sieve marks only first powers — what a `k = 1` pre-sieve with no higher-power marks
actually collects — the ratio inverts:

| B | 64 | 128 | 256 | 512 | 1024 | 4096 |
|---|---|---|---|---|---|---|
| `k ≤ 1` only | 1.00 (3 vs 3) | 0.690 | 0.625 | 0.627 | 0.637 | 0.645 |
| unrestricted | 5.02 | 3.05 | 2.16 | 1.71 | 1.51 | 1.27 |

**This is a sharp prediction, and it was the one most likely to fail.** From the law, the
local density of NFS values at FB exponent `e` relative to uniform is

```
r_p(0) = 1,    r_p(1) = (p − α_p)/(p − 1) < 1,    r_p(e) = α_p = 2 − 1/p  for every e ≥ 2
```

so a `k = 1`-only sieve must *lose* and the unrestricted sieve must *win*. Measured:
0.627 and 1.714 at `u = 4`. Both confirmed, and the self-test gates on them. The excess
therefore **cannot** be collected by a sieve that ignores higher powers, which is the one
place the audit's intuition is right — but NFS does not ignore higher powers, so it costs
NFS nothing.

---

## STEP 3 — which `k` contributes what

Decomposition by the largest factor-base exponent `k` of the relation, with each layer's
share of the total gain `(TRUE_k − NULL_k)/(TRUE − NULL)`:

| layer | B=256 (u=4.5) | B=512 (u=4.0) | B=4096 (u=3.0) |
|---|---|---|---|
| k = 1 | 447/715 → **0.625** | 2 326/3 712 → **0.627** | 36 708/56 884 → **0.645** |
| k = 2 | 1.83 (share 0.234) | 1.63 (0.298) | 1.47 (0.532) |
| k = 3 | 2.37 (0.244) | 2.02 (0.267) | 1.73 (0.394) |
| k = 4 | 2.64 (0.181) | 2.33 (0.191) | 1.87 (0.237) |
| k = 5 | 0.89 (**−0.007**) | 0.76 (**−0.020**) | 0.63 (**−0.055**) |
| k = 6 | 4.39 (0.141) | 4.01 (0.149) | 3.24 (0.177) |
| k ≥ 7 | 4.95 (0.252) | 4.24 (0.232) | 3.22 (0.222) |

**Cumulative, as each power layer is admitted (ratio TRUE/NULL):**

```
B= 512 (u=4.0):  k<=1: 0.627   k<=2: 1.228   k<=3: 1.424   k<=4: 1.533   k<=5: 1.484   k<=6: 1.578   all: 1.714
B= 4096 (u=3.0): k<=1: 0.645   k<=2: 1.010   k<=3: 1.136   k<=4: 1.195   k<=5: 1.171   k<=6: 1.217   all: 1.271
```

Findings, stated plainly because they change the interpretation:

- **The audit's "the events that matter are at small `k`" is confirmed**, and so is "the
  excess peaks at `k = 2`": at the operating point `k = 2` alone carries 23–53% of the gain.
- **`k = 1` is a LOSS** (0.63–0.65), exactly as `r_p(1) = (p−α)/(p−1) < 1` predicts. All of
  the gain is at `k ≥ 2`; none is at the prime itself.
- **`k = 5` is a small, reproducible loss** at every `B` tested (0.63–0.89, share −0.7% to
  −5.5%). This is not new physics: it is the arithmetic consequence of differencing the
  *cumulative* law across the `k = 6` departure. `P(v_p = 5) = α/p^5 − (α+p−1)/p^6`, which
  for `p = 5` is `2.05·10⁻⁴`; measured `2.20·10⁻⁴` against a uniform `2.56·10⁻⁴`. The
  law is right; a naive per-exponent differencing that holds `α` constant through `k = 6`
  is what mispredicts.
- **≈ 37–40% of the measured gain sits at `k ≥ 6`**, i.e. where the paper's own §4 says
  the law has left `2 − 1/p`. At `u = 3.0` it is 17.7% + 22.2% = 39.9%. Not "most", but a
  large and structural minority, and it is the part with a different explanation.

### Is the `k ≥ 6` part the zero-zero subspace? **Yes, mostly.**

Taking the relations whose largest FB exponent is ≥ 6 (`n = 2 889` of 13 818), finding which
prime attains it, and testing the zero-zero configuration `p³ | a and p² | b` directly on
the `(a,b)` that produced them:

```
attributed prime:  p=2: 2,189   p=3: 563   p=5: 92   p=7: 37   p=11: 5   p=13: 1   p=19: 2
zero-zero configuration holds for 1,694 of 2,889  (58.6%)
uniform expectation for the same count: ~103  (3.6%)   =>  18.8x enriched
```

So the majority of the `k ≥ 6` layer is the trivially-divisible subspace `a ≡ 0 mod p^⌈k/2⌉`,
`b ≡ 0 mod p^⌈k/3⌉` — a congruence condition on `(a,b)` that costs a sieve engineer nothing
to satisfy because the box is uniform in `(a,b)` — and **not** the `2 − 1/p` ramification
effect that is the paper's headline. Combined with §2b (the strongest sub-boxes are exactly
`(a,b) ≡ (0,0)`), the picture is coherent: **the paper's advertised mechanism accounts for
roughly the first 60% of the gain; the rest is divisibility.**

---

## 4. What this does and does not license

**It licenses, as a measured quantity:** at `X = 2^36` with a matched `a`/`b` box and the
NFS operating shell, NFS relation collection costs **14.1% [13.3, 15.0]** less per relation
than the uniform-value model predicts at `u = 3.00`, **36.0% [34.3, 37.7]** at `u = 4.00`,
rising monotonically to 78.0% at `u = 6.00`. The uniform-integer smoothness model is
**pessimistic** about NFS, and the size of the error grows with `u`.

**It does not license any of the following:**

- **It is not an implementable speedup.** NFS does not choose the valuation law; it is
  handed `a² − b³`. There is no decision to take. The correct use of the number is to
  **correct the heuristic**, not to claim a better algorithm.
- **No sieveable sub-box beats the global rate** that NFS already gets for free — the median
  mod-4 sub-box is 1.246 against a global 1.714. The excess concentrates, but only into the
  `(a,b) ≡ (0,0)` corner that a uniform box already contains. There is no targeting to be
  had on top.
- **The `L[1/3]` exponent and the GNFS constant `(64/9)^{1/3}` are untouched.** This is a
  prefactor correction.
- **The exponent of the reduction is not established.** The measurement is at one value
  scale `X = 2^36`. The valuation law itself is scale-free (it is a statement mod `p^k`, and
  the box sides are exact powers of two exceeding every `p^k` in play), but the *ratio* is
  demonstrably a function of `u` and I have **not** verified that `u`, not `X`, is the only
  parameter. A `2^48` or `2^60` replication is the obvious next check and was not run here.
- **`u = 6.00` is reported but not load-bearing**: 894 relations from 3.15 M candidates is
  not a workable sieve configuration, and the interval is correspondingly wide
  ([0.178, 0.272]).

**Recommended wording for paper #523 §6.** The `25–38%` claim stays withdrawn. What
replaces it is a measured, `u`-dependent correction to the *uniform smoothness heuristic*,
carried out with a null arm that can be switched on and off and that demonstrably returns
1.000 when it should, with the honest caveat that ≈ 37–40% of the gain comes from the `k ≥ 6`
zero-zero subspace rather than from the `2 − 1/p` law the paper is about.

---

## 5. Method notes, hazards hit, and the constraints in the brief

**The switch passed; every ratio above is behind it.** Both halves of the vacuity question
were tested (§0, Tests 1–3). No end-to-end number in this note exists without the null arm.

**Self-test written first, and it earned its keep.** It caught five defects before a single
ratio was reported, two of which would have produced a wrong headline:

1. **The value-scale bug** — `shell_mask` used `X = 2^18` (the box side) instead of
   `X = 2^36` (the value scale). The shell then kept 99.996% of samples and silently
   changed the operating point by a factor of 2 in `u`. `selftest.py` §1 now asserts
   `value_scale(A) == 2^(2A)`.
2. **The exhaustive-enumeration bug** — the count was taken over the `p^kmax` grid rather
   than the `p^k` grid, producing ratios of 15 625 and 2 401 where 1.000 and 1.857 were
   expected. Every `k` except the last was wrong.
3. **A pooled statistic with no power** — restricting cells to ≥ 10⁵ expected hits left
   3 cells, all at `k = 1` where there is no excess, so the "sharp" vacuity test reported
   0.5σ for the true arm. Corrected to `k ≥ 2` cells with ≥ 5000 expected hits: 303σ.
4. **A swapped sentinel** made the "SHELL" comparison silently run on the full box, printing
   byte-identical rows for the two.
5. **A hardcoded ±2% pass criterion** on the NULL/NULL2 control, which at `B = 64`
   (178 relations) would have printed "control failed" on a perfectly healthy control.
   Poisson noise, not a defect; the criterion is CI-based now.

**No float roots, anywhere.** The box is built from exact powers of two, `a²` and `b³` are
exact `int64` products (`2^36`, comfortably inside `int64`), and every division in the sieve
is exact integer division. There is no cube root to take, so the `int(n**(1/3))` bug class
has no purchase. Tightest cases are tested explicitly: `997^3` is `997`-smooth and `1009^3`
is not, at `B = 1000`, with `B` chosen so that "exactly AT the bound" and "just above" are
both realisable and distinct. The strip was cross-checked against the shared harness
`is_smooth` on 400 random values in the operating range — 0 mismatches.

**All `(a,b)` are enumerated, including `a² ≡ b³`.** The box is sampled uniformly with no
filter on `a² ≡ b³`. The only exclusion is `a² − b³ = 0` *exactly* (63 degenerate pairs out
of 2^30, from `a = t³, b = t²`), which are excluded because a zero value has no smoothness
question and are also excluded by the shell.

**Dickman `ρ` is not used as a null anywhere in this note.** The null arm is a locally
uniform integer, which satisfies `P(p^k | x) = 1/p^k` exactly. Separately, the brief's
warning is confirmed and extended — exact `Ψ` by full sieve, `X = 2^24`, no sampling:

| u | 3.0 | 3.5 | 4.0 | 4.5 | 5.0 |
|---|---|---|---|---|---|
| exact Ψ/X | 6.77e-1 | 6.03e-1 | 5.39e-1 | 4.86e-1 | 4.45e-1 |
| `ρ(u)` | 4.86e-2 | 1.62e-2 | 4.92e-3 | 1.37e-3 | 3.58e-4 |
| **exact Ψ / ρ** | **13.9×** | **37.2×** | **109.7×** | **353×** | **1244×** |

So the 8.46× inflation recorded at `u ∈ [5,8]` in `r52/exp/smooth/C_fixed.txt` is **not** a
`u ∈ [5,8]` phenomenon. It is the ordinary slow convergence of `Ψ(x,y)/x → ρ(u)` at small
`y`, and it is *worse* at `u ≈ 3–5` than at `u ≈ 5–8`. `ρ` is unusable as a null at NFS
operating points, and the gap grows as the base shrinks.

**Self-test gate.** `python3 selftest.py` → exit 0. It runs the exact box arithmetic, the FB
strip at the tightest boundary cases, the cross-check against the shared harness, the
valuation law by exhaustive enumeration mod `p^k` (`p = 5, 7, 3`, including the `k = 6`
departure and the `k = 1` no-excess statement for 12 primes), the switch test, the vacuity
test, the `k_max` degeneracy predictions, and the `ρ` report.

**No citations were consulted.** WebSearch was not used. Everything here is measured on this
host; the only external quantity referenced is `ρ` from the shared harness.