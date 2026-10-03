# B_groups — which group other than Z/mZ should a Pollard-style L[1/2] walk use?

**Axis:** replace the elliptic curve group in ECM by another family `G_D`, reachable from
`N` in poly(log N), and check whether `|G|` is materially smoother at *matched order
bit-length* than the EC order.

**Verdict: NO family survives. The elliptic curve survives.**
The class group is the only serious candidate and it fails the second test (cost to reach
p), not the first — and the reason is structural, not numerical.

---

## 0. Hypothesis, stated numerically before running

> There exists a group family `G_D` reachable in poly(log N) time from `N`, whose order
> distribution has a materially higher Dickman probability at matched bit-length than
> `E[rho(2)] ≈ 0.3069` — a larger constant in the L[1/2] exponent, or a heavier
> concentration of very-smooth orders.

**Pre-registered decision rule:** "materially higher" = the 95% CI of the family's
`P(B-smooth)` at u=2 lies strictly above the 95% CI of a matched null measured on this host.
Family **and** cost-to-reach-p must both pass.

---

## 1. The control (this is the part that was nearly got wrong)

### 1.1 One smoothness function, used by every arm

Every number in this note comes from a single function, `_shared/dickman.py: is_smooth(n, B)`,
imported by name. The EC-matched null is produced by the *same module* (`ecm_baseline_smooth_rate`),
so "same harness" is structural, not a promise. It is additionally cross-validated in
`exp/selftest.py` (T4) against `sympy.factorint` and against a pure trial-division oracle on a
shared 800-element set, at the tightest boundaries (T5).

### 1.2 `rho(2) = 0.30685` is a LOWER bound at finite scale — measured here

`exp/selftest.py` T3 counts `Psi(x, sqrt x)/x` exactly by sieve:

| x | 1e5 | 1e6 | 1e7 | 1e8 |
|---|---|---|---|---|
| `Psi(x,√x)/x` | 0.35819 | 0.34430 | 0.33622 | 0.33268 |
| excess over `rho(2)=0.30685` | +0.0513 | +0.0374 | +0.0294 | +0.0258 |

Converges **from above**, monotonically. So quoting 0.3069 as "the" ECM smoothness probability
is imprecise; the baseline must be measured. That is what the rest of this note does.

### 1.3 A recalled Dickman table was wrong, and the self-test caught it

The first draft of `selftest.py` T2 checked `rho` against tabulated values. It **failed at
u=5,6,7** and the self-convergence test showed the *table* was wrong, not the code:
converged `rho(5)=3.5472e-4`, `rho(7)=8.7457e-7`. T2 was rewritten to use only the closed
forms `rho(u)=1-ln u` on `[1,2]` (exact, checked to 1e-9) plus **self-convergence** for u>2.
No Dickman table is trusted anywhere in this note.

---

## 2. The table

All rows at **matched ORDER bit-length**, `B = isqrt(|G|)` exactly (never a float floor).

| family | \|G\| bits | n | P(u=2 smooth) | 95% CI | vs matched null | order even? | **cost to reach p without knowing p** | VERDICT |
|---|---|---|---|---|---|---|---|---|
| **EC baseline** `E(F_p)`, random curve | 26 | 2000 | **0.2645** | [0.246, 0.284] | — | 47.9% | **none needed** (walk mod N, gcd) | survives |
| Cl(√−N), N semiprime — *reachable slice* | 26 | 568 | 0.3521 | [0.314, 0.392] | +0.088 | 100% | walk yields ambiguous form → gcd | **DEAD (§3)** |
| Cl(√−D), D free | 26 | 614 | 0.3925 | [0.355, 0.432] | +0.128 | 93.6% | **impossible** — D is not a function of N | DEAD |
| Cl(√−D), both slices | 26 | 1182 | 0.3731 | [0.346, 0.401] | +0.109 | 96.7% | mixed | DEAD |
| **Cl, PARITY-MATCHED (even arm)** | 26 | 1152 | 0.3672 | [0.340, 0.395] | **+0.0499** (+3.4σ) | 100% (even) | as above | **survives §2, dead §3** |
| Cl, parity-matched (odd arm) | 26 | **43** | 0.4884 | [0.346, 0.632] | +0.2558 | 0% | as above | **insufficient** (n=43) |
| PGL(2,p) = p(p²−1) | 28 | 3000 | 1.0000 | [0.9987, 1.0] | **degenerate** | 100% | **circular** — need p to form F_p | DEAD |
| GL(2,p) | 28 | 3000 | 1.0000 | [0.9987, 1.0] | **degenerate** | 100% | **circular** | DEAD |
| PSL(2,p) | 28 | 3000 | 1.0000 | [0.9987, 1.0] | **degenerate** | 100% | **circular** | DEAD |
| C(D)[3] (3-torsion) | any | — | 1.0 by construction | — | tautology | — | reachable | DEAD (§4) |
| cubic / quartic number fields | — | — | **insufficient** | — | — | — | no poly(log N) construction known | DEAD |
| uniform random integer (null) | 28 | 2000 | 0.2745 | [0.255, 0.294] | — | 49.3% | n/a | n/a |

### 2.1 The smoothness metric is degenerate for PGL(2,p)/GL(2,p) — use largest-prime-factor instead

`P(u=2 smooth) = 1.0000` for PGL(2,p) is **true and useless**: `|PGL(2,p)| = p(p-1)(p+1)`, so
every prime factor is `<= p+1 << |G|^(1/3) < |G|^(1/2) = B`. It is smooth by construction.

The metric that actually drives a rho/BSGS walk is the **largest prime-power factor**.
Measured (`harness.lpf_stats`, median log2, matched at 28-bit group orders):

| group | median log2 largest prime-power factor | implied walk cost |
|---|---|---|
| EC baseline | **16.1** | 2^8.05 |
| PGL(2,p) | **9.2** | 2^4.6 |
| GL(2,p) | (same structural law) | — |

**This is the most interesting raw datum in the note and it must not be over-read.** PGL(2,p)
genuinely has a *much* better smoothness profile than the EC at matched order size. It is
still dead, because F_p does not exist without p. A family can win the smoothness column and
lose the round anyway.

---

## 3. Cost to reach p — the killer requirement

### 3.1 Measured, on this host (`exp/cost_curve.py`, `_cost.log`)

| operation | bits | seconds |
|---|---|---|
| `ellcard(ellinit(v,p))` — build the EC group order | p=64 | 0.264 |
| | p=96 | 0.537 |
| | p=128 | 1.238 |
| | p=160 | 2.243 |
| `qfbclassno(D)` analytic | D=32 | 0.0003 |
| | D=40 | 0.0006 |
| | D=48 | ≥20 (killed) |
| | D=56 | 0.0003 … >20 (bimodal) |
| | D=58 | 0.018 |
| | D=62 | 0.044 |
| | D=64,68,72 | ≥20 (killed) |
| `qfbclassno(D,1)` Buchmann–McCurley | D=40 | 17.8 |
| | D≥48 | ≥20 (killed) |
| **`qfbclassno(-4p)`, p PRIME 80-bit** | | **43.9 s** |

Building the EC order is polynomial and fast. Building a class number is **not**: cost jumps
by four orders of magnitude between D=40 and D=48 bits and is bimodal at D=56 (0.3 ms or
>20 s depending on the individual D — measured, see §3.2). This is why the matched-twin
comparison above had to be run at **26-bit orders**, the largest scale at which class numbers
are obtainable at all here. *This is a limitation of measurement, not of the algorithm —
see §3.4.*

### 3.2 Mechanism, tested not assumed

I hypothesised the cliff was "the analytic class number formula needs a square root mod D,
which is as hard as factoring D". **That hypothesis is REFUTED**: the square root mod a
prime p is fast (`exp((p-1)/2) mod p` = 0.02 ms at 60 bits), yet `qfbclassno(-4p)` at 80 bits
still took **43.9 s**. So the bottleneck is not a modular square root. It is the precision
demanded by `h ≈ sqrt(D)/π · L(1,χ_D)`: recovering the *exact integer* h needs the L-value to
~1/√D, which is exponential in log D. Reported as a measurement, not a proof.

### 3.3 The decisive structural kill (coordinator findings 3–4, adopted)

Independent of any smoothness number:

- BSGS in `Cl(Q(√−kN))` costs `(kN)^(1/4)`, and `(kN)^(1/4) > L[1/2]` for **every k ≥ 1**
  once `N > 5400` (`2√(L ln L) < L ⟺ 4 ln L < L ⟺ L < 8.6`). Even k=1 is too slow.
- `Cl(O_D) mod p` is **trivial** in both cases, so the walk degenerates to SQUFOF at N^(1/4).
- `(D/p)` *is* the factorisation bit; `(D/n) = (D/p)(D/q)` is a product carrying zero bits
  about it.

**So the class group is not merely unlucky on smoothness — it is excluded by the mechanism.**
My §2 result (that it is somewhat smoother, +0.050 parity-matched) is a statement about an
order distribution, and it cannot rescue a family whose walk costs `N^(1/4) > L[1/2]`.

### 3.4 The one place the class group is legitimate

Schnorr–Seysen–Lenstra never needs to *know* h — it collects relations and combines them into
an ambiguous form directly, which is precisely why it avoids the §3.1 cost. Its rigorous
running time is `L_n[1/2, 1]`, structurally better than ECM's `L[1/2, √2]` **because
`|Cl(−4n)| ≈ √n` while `|E(F_p)| ≈ p`** — the win is in the *size of the group*, not in the
smoothness of its order. That is a different axis from the one this note was chartered to test,
and it is closed elsewhere (Lenstra–Pomerance's refutation for large prime-square divisors).

---

## 4. Families that are dead by construction, not by measurement

- **PGL(2,p), GL(2,p), PSL(2,p).** Requires F_p. Forming the group requires the factor you are
  hunting. Circular — the same reason higher-genus Jacobians fail, which is the mechanism the
  literature states explicitly: groups of order ≈p^d with d>1 are worse on smoothness *and*
  need p to exist.
- **C(D)[3].** A power of 3, hence B-smooth for every B ≥ 3: P = 1 is a tautology, not an
  advantage. Its size is what matters and it is bounded by log_3 D.
- **Cubic / quartic number field class groups.** No poly(log N) construction from N known to me.
  Marked **insufficient** rather than assigned a number.

---

## 5. Answer to the parity question

> Did any family show an advantage that survived order-bit-length matching AND parity matching?

**Yes, one — and it is a partial survivor.** The class group survives parity matching:

| arm | class numbers | matched null | delta |
|---|---|---|---|
| EVEN (96.4% of sample, n=1152) | 0.3672 | 0.3173 | **+0.0499 (+3.4σ)** |
| ODD (n=43) | 0.4884 | 0.2326 | +0.2558 — **insufficient**, n=43 |

The unmatched gap was **+0.0966 (+6.8σ)**. **Parity matching removes roughly half of it**
(+0.097 → +0.050). So:

- the residual +0.050 is real at 3.4σ and is consistent with the literature's weak, *heuristic*
  statement that Cohen–Lenstra puts class groups "a bit better" than random at the same size;
- but it is a ~5-percentage-point effect on a probability, i.e. a constant-factor saving of
  about 1.2× in expected curve count — **not** a change to the L-function exponent;
- and it is moot, because §3.3 excludes the family anyway.

**This is the number most deserving of scrutiny, and my scrutiny says: real but small, and
irrelevant to the outcome.** The odd arm is underpowered and must not be quoted.

---

## 6. Bottom line

| | |
|---|---|
| Best matched-scale smoothness found | Cl(√−D), **+0.0499 (+3.4σ)** over a same-bit-length null, parity-matched |
| Did it survive cost-to-reach-p? | **No.** `Cl(O_D) mod p` is trivial; the walk degenerates to SQUFOF at `N^(1/4) > L[1/2]` for all `k ≥ 1`, `N > 5400` |
| Family that survives both tests | **None.** The elliptic curve `E(F_p)` survives, and it survives for a structural reason: it is the only group of order ≈p with an efficient law that is **constructible over Z/NZ without knowing p** |

The general principle the note supports: **the binding constraint is never the smoothness of
the order — it is whether the group exists without the factor.** Every family that wins on
smoothness (PGL(2,p) wins by a factor 2^6.9 in walk cost) loses on constructibility; the one
family that is constructible (the class group) wins only marginally on smoothness and loses on
mechanism.

---

## 7. Reproduction

```
exp/selftest.py        self-test first: iroot at perfect powers, rho closed-form +
                      self-convergence, exact Psi vs rho, is_smooth vs 2 independent
                      implementations on a shared set, tightest B boundaries, Hasse,
                      qfbclassno vs brute-force form counting, PARI call conventions
exp/smooth.py          the single iroot/is_B_smooth; rho by delay-ODE grid
exp/families.py        order samplers per family
exp/harness.py         matched_bucket (RAISES if it cannot match), lpf_stats
exp/cost_curve.py      cost-to-reach-p measurements, subprocess-capped
exp/B_groups_final.py  the matched-scale table
exp/B_parity_match.py  the parity-matched control
exp/harvest_cn.py      class-number harvest (PARI-safe, batch size 1)
lit/LITREPORT.md       999 lines, 274 verbatim quotes, 8 explicit unverified blocks
```

**Honest gaps:** (i) matched-scale comparison is at **26-bit orders**, not 64/96 — forced by
§3.1; the direction of a 26-bit result is not automatically a 96-bit result.
(ii) cubic/quartic class groups: **insufficient**. (iii) the +0.050 residual rests on one
scale; I did not replicate at a second scale. (iv) §3.2's explanation of the class-number
cliff is a measurement plus a hypothesis, not a proof.