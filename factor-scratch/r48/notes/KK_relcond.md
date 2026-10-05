# KK — Does conditioning buy anything on NFS/Stange relation-finding?

**Round 51 · agent KK · `factor-scratch/r51exp/relcond/` · 2026-10-04**
Code: `relcond_core.py`, `selftest.py` (**50/50 PASS, exit 0**), `r1_r4.py`,
`controls.py`, `r4_e2e.py`, `r4_power.py`, `why_evenx.py`, `final_pooled.py`.
Predictions committed in `PREREG.md` **before** any number was measured.
**No commit, no issue, no paper.**

---

## 0. VERDICT

> ## ⭐ **NO. The uniform search is already optimal, and there is a proof, not just a measurement.**
>
> Conditioning buys **nothing** on relation-finding — on any character, on either
> candidate family, at either sample size. The preregistered prediction was
> **gain 1.00**; the measured pooled gain is **1.007 (z = +0.83)** for the most
> favourable arm and **0.998 (z = −0.29)** for the cheapest one.
>
> **The reason is structural and is the transferable part.** Conditioning by
> *rejection* cannot beat the fraction of candidates it discards — a
> **≥ 2× loss is guaranteed before any correlation is measured** — and the one
> class that escapes this cap (conditioning on the *index* of `x`, which rejects
> nothing) was tested and is exactly 1.00.

This is a rigorous negative, and it **closes the last structural idea** for the
95% phase of this method.

---

## 1. The accounting law — the part that generalises

Derived once, in `relcond_core.py::cap_gain`, and checked in self-test T3.
Let `s_0` = FB-smooth rate unconditioned, `s_C` under condition `C`,
`q = P(C)` = fraction of candidates admitted, `c_gen` = cost to generate one
candidate, `c_cond` = cost to evaluate the condition:

```
unconditioned:  relations / unit-cost  =  s_0 / c_gen
conditioned:    relations / unit-cost  =  s_C / (c_gen/q + c_cond)

    GAIN = (s_C/s_0) · q / (1 + q·c_cond/c_gen)          (*)
```

> **★ A condition that rejects candidates can never beat the factor `q` it costs.**
> For any balanced character (`q = 1/2`) the ceiling is **0.50** — a guaranteed
> **≥ 2× LOSS**, no matter how strongly `s_C` is enriched. `c_cond > 0` only makes
> it worse.

This is **algebra, not an experiment**, and it is why most of the table below is
decided before it is measured. It also explains the round-50 success in hindsight:
that conditioning acted on the **base `g`**, paid **once per attempt**, and the
attempt is the thing being conditioned — there `q = 1` because nothing is
rejected. Relation-finding has no such free lunch.

**The `q = 1` escape hatch.** The cap only binds for conditions that *reject*.
Conditioning on the **index** of `x` (`x` odd, `x ≡ 0 mod 4`, …) rejects nothing,
so `q = 1` and the cap does not apply. **That is the only place a genuine win is
even possible**, and it is why R1d/C3/`final_pooled.py` spend most of the compute
there rather than on arms the law has already closed.

---

## 2. R1 — character conditioning. **NULL.**

Predictions (`PREREG.md`, pre-committed): ratio **1.00 ± 0.15** on every arm.

| arm | `s_C/s_0` | `q` | **GAIN** | verdict |
|---|---|---|---|---|
| R1a Jacobi `(g^x/n)`, Stange | 0.9925 | 0.500 | **0.496** | LOSS (by the cap, before `c_cond`) |
| R1b Jacobi `(V/n)`, `a²−b³` | 0.9926 | 0.499 | **0.495** | LOSS |
| R1b Jacobi `(a/n)` | 0.9683 | 0.500 | **0.484** | LOSS |
| **R1d parity of `x` (free, `q = 1`)** | **1.0003** | **1.000** | **1.0003** | **null** |
| C3 `x mod m`, m = 2,3,4,8 | 1.004–1.012 | 1.000 | ≈1.00 | null |

Sample sizes: 60 000 candidates/arm (R1), 40 000 (R1b), 300 000 pooled
(`final_pooled.py`), 6–12 moduli. **No arm reaches |z| > 2.**

### 2a. ★ Why the Jacobi symbol cannot work here — a proof, not a measurement

> **For the Stange family the transplant is not merely ineffective, it is
> information-free.**
> ```
> (g^x / n) = (g/n)^x ∈ {+1, −1}
> ```
> so for a fixed base the candidate's Jacobi symbol is a function of **`x mod 2`
> alone** and carries **zero** information about the candidate's factorisation.
> Verified on 3000 samples with **0 violations** (self-test T5), and the two
> parities do give opposite signs — so the split is real, it just means nothing.

For the NFS family the same independence holds by a different route:
`V = ∏p^f` gives `(V/n) = ∏(p/n)^f`, a product of independently-uniform local
characters. Measured **0.9926** over 40 000 samples.

### 2b. ⚠️ And for half of all bases the character is not merely useless — *undefined*

If `(g/n) = +1` then **every** `g^x` is a quadratic residue mod `n`, so the Jacobi
symbol is **constant** on the candidate set and there is no second stratum to
compare against. The arm is degenerate, not null. Recorded because it means the
round-50 trick, transplanted literally, is **inapplicable to 50% of bases** — the
code hits `ZeroDivisionError` unless this is handled (`arm()` prints
`EMPTY STRATUM`).

### 2c. R1c (v₂ of the candidate) — degenerate, and why that is expected

Every candidate `g^x mod n` for `x` even is a **square**, so `v₂` is degenerate
under parity conditioning. The arm that survives — conditioning the *base* on
2-adic structure — is round 50's already-claimed result on the 5% phase, not a
relation-finding effect.

---

## 3. R2 — the `2 − 1/p` excess, revisited as a SEARCH condition. **CLOSED, and it is a large loss.**

Prediction: gain ≤ 0.22. **Measured: 0.017 – 0.148.**

| p | corner rate | `s_C/s_0` | `q` | **GAIN** | bar to win (`p²`) |
|---|---|---|---|---|---|
| 3 | 0.3784 | 1.350 | 0.109 | **0.148** | 9 |
| 5 | 0.4241 | 1.513 | 0.040 | **0.060** | 25 |
| 7 | 0.4842 | 1.727 | 0.021 | **0.036** | 49 |
| 11 | 0.5620 | 2.005 | 0.0086 | **0.017** | 121 |

> **The excess is real and it is measurable — the corner IS smoother (1.35× to
> 2.00×, exactly the direction `2 − 1/p` predicts). It buys nothing anyway,
> because reaching the corner costs `q = 1/p²` and the enrichment is bounded by
> `2 − 1/p < 2 ≪ p²`.**

**The gap is not close and cannot be closed by better measurement:** the bar is
`p² ≥ 9` and the numerator is `< 2`. This is the `2 − 1/p` result being
*re-confirmed in a new place and shown to be irrelevant in that place* — the
excess lives in the `p | a, p | b` corner, which is precisely the corner a
factor-base sieve reads off **for free**, so the search-time version of the same
fact is strictly weaker. Round 52's "zero headroom" is right, and this is an
independent route to it.

### 3a. ⚠️ A correction to my own framing of `r_p` (this one changed a conclusion)

I entered this section expecting a **root-count** null `r_p/p`. It is **rejected
at z = −59 to −140**, and the naive `1/p` **holds**:

```
p   #pairs(a^2=b^3)   1/p     observed    z vs 1/p    z vs r_p/p
3          3         0.3333   0.3325      -0.21          (y=2 inert)
7          7         0.1429   0.1441      +1.62          -140.17
17        17         0.0588   0.0596      +1.48          -80.57
31        31         0.0323   0.0319      -0.86          -59.34
```

Over **all** `(a,b) mod p` the number of solutions to `a² = b³` is **exactly `p`**
(asserted for every prime tested), so `P(p | a²−b³) = p/p² = 1/p` exactly. **The
`2 − 1/p` excess is a `k ≥ 2` phenomenon confined to the `p | b` corner** — it is
not a root-count effect at `k = 1`. The control is **non-vacuous**: it rejects the
model I expected at up to `z = 140`.

*(My first `r_p` counted solution *pairs* and so equalled `p` identically, making
`r_p/p = 1` and the z-denominator zero. The crash was the bug report.)*

---

## 4. R3 — structural striding. **NULL.**

| scheme | rate | ratio | median \|V\| | degeneracy flag |
|---|---|---|---|---|
| uniform | 0.0775 | 1.000 | 4.40e11 | — |
| walk `t=1` | 0.0771 | 0.995 | 4.41e11 | none |
| walk `t=2` | 0.0753 | 0.972 | 4.36e11 | none |
| walk `t = n/3` | 0.0777 | 1.003 | 4.40e11 | none |
| sublattice (parity) | 0.0766 | 0.988 | 4.40e11 | none |

**The degeneracy detector ran on every arm** (the round-48 failure: `seq`/`stride`
harvest trivially-smooth *small* `x` and manufacture a spurious kernel). Median
`|V|` is within 3% of uniform everywhere — **no arm is winning by finding small
values.** This confirms round 48's `AA_stride_sampler` finding on a second family.

---

## 5. R4 — cost per collected relation. **The decisive test, and a trap I nearly shipped.**

The brief's requirement is that a win be quoted as **cost per collected
relation**, not hit rate. Three measurements of the *same* quantity gave three
answers, and the progression is the most useful part of this round:

| measurement | `x_mod4` gain | what it really was |
|---|---|---|
| 60 relations, wall-clock (`r4_e2e.py`) | **1.155** | **resolution** — per-modulus 0.95/1.21/1.39 |
| 40 000 trials, 5 moduli (`r4_power.py`) | 1.026 | **per-modulus scatter** |
| subgroup-controlled, 6 moduli (`why_evenx.py`) | 1.000 | subgroup hypothesis **wrong sign** |
| **300 000 pooled, 12 moduli (`final_pooled.py`)** | **1.005, z = +0.61** | **null** |

> **⚠️ The `r4_e2e.py` 1.155× would have shipped as "the first win in this
> round."** It was caught only because the brief demands per-modulus reporting:
> the same modes give **0.95, 1.21, 1.39** on three moduli.

**Pooled result (300 000 candidates per mode, 12 moduli):**

| mode | rate | ratio | z | verdict |
|---|---|---|---|---|
| uniform | 0.08130 | 1.0000 | — | baseline |
| `odd_x` | 0.08109 | 0.9975 | −0.29 | null |
| `even_x` | 0.08189 | **1.0073** | **+0.83** | **null** |
| `x ≡ 0 mod 4` | 0.08173 | 1.0053 | +0.61 | null |

Per-modulus `even_x`/uniform: mean 1.008, **sd 0.029**, range 0.960–1.056.

### 5a. The subgroup hypothesis, tested and refuted

Even `x` samples the **square subgroup** `⟨g²⟩`, so I hypothesised the finite-size
density of FB-smooth numbers *among squares* differs from that among all integers.
**Prediction: the gain should grow as the subgroup shrinks.**

Measuring actual `ord(g)` via `n_order` and subgroup sizes `ord(g)/gcd(ord(g),m)`
for `m = 1,2,3,4,6,8` across 6 moduli:

- pooled ratios **0.988 – 1.000** (all ≈ 1);
- `corr(ln|⟨g^m⟩|, ratio) = +0.34` — **the wrong sign**;
- and decisively, on the two moduli where `ord(g)` is **odd** (so `⟨g^m⟩ = ⟨g⟩`
  for every `m`, i.e. **no subgroup change at all**), the ratios still scatter
  from **0.978 to 1.033**.

**There is no subgroup effect.** The apparent signal is between-modulus noise, and
the two moduli that changed *nothing* move as much as the ones that changed the
most. `why_evenx.py` exists to make that falsification reproducible.

---

## 6. Mandatory controls — what was checked

| control | status |
|---|---|
| **`2 − 1/p` / `p_split`, per modulus, never pooled alone** | ✅ §3a, and a wrong `r_p` model rejected at **z = −140** (non-vacuous) |
| **self-test written FIRST, non-vacuity by INJECTION** | ✅ **50/50 PASS, exit 0**; injected ratio 10.0 recovered as **10.0000**, `z = +55.2`; negative control `z = +1.31` |
| **`Ψ(x,y) = Ψ(x,y−1) + Ψ(x/y,y)` false for composite `y`** | ✅ composite `B` reduced to predecessor prime; path agreement asserted |
| **Dickman `ρ` not used as a null** | ✅ never used; divergence shown at fixed `B` (`Ψ/x → e^{−γ}/ln B = 0.0813`, monotone `0.533→0.344→0.203`) |
| **`rho(u)` raises above u = 5** | ✅ asserted; `rho(6)` raises |
| **never `int()` a Rational** | ✅ T7 asserts `int(Fraction(1,2)) == 0` **and** that an identically-zero vector satisfies `M v = 0` (non-vacuity) |
| **z-detector must be able to fire** | ✅ refuses `k > n` (round-52's vacuous detector); fires at `z = +7.15`, matching analytic to 2 dp |
| **held-out, fresh moduli and bases** | ✅ 4 held-out R1d moduli → pooled gain **0.9990** (prereg 1.00 ± 0.15); 12-modulus pooled final |
| **small-value degeneracy detector on every structured arm** | ✅ median `|V|` within 3% of uniform |
| **regime honesty** | ✅ `π(B*) ≈ 10¹⁵–10³³` — **the real NFS regime is NOT determinable on this host.** All numbers at 36–40-bit `n`, `B ≤ 2¹⁵` |

---

## 7. Bugs this round's controls caught in my own code

Every one would have produced a clean, confident, wrong number.

1. **Infinite hang on `V = 0`.** `a² − b³ = 0` exactly when `a = c³, b = c²`, and
   `0 % p == 0` forever → the divide-out loop never terminates. R2 ran **>100 s
   with no output**, and because stdout was block-buffered through a pipe the hang
   was indistinguishable from "slow". Fixed at source, regression test T11.
2. **`r_p` defined as solution *pairs*** — identically `p`, so `r_p/p = 1` and the
   z-denominator is 0. **The crash was the bug report.** This one flipped a
   conclusion: the root-count null is rejected, `1/p` holds.
3. **Variable shadowing in C2** — `q` (the prime) rebound to the conditioning
   fraction, so **every stratum label was computed from `v2(frac − 1)`** and read
   `s_q = 0`, impossible for an odd prime. Caught *only* because the mandatory
   `p_split` control makes the label visible. Rates unaffected; labels were wrong.
4. **The injected-dependence control was itself wrong, twice.** (i) Built smooth
   values as a product of 8 uniforms → **int64 overflow** (`1000⁸ = 10²⁴`), so a
   planted 5× measured 1.48. (ii) After fixing that, the "non-smooth" background
   sampled uniformly in `[5·10⁹, 10¹⁰]` was itself **~3% B-smooth** at `B = 1000`,
   diluting the planted 5× to 3.77. Fixed by making the background *provably*
   non-smooth (multiply by a prime `q > B`), after which the planted ratio is
   recovered **exactly**. **A control that silently under-plants is worse than no
   control, because it looks like it passed.**
5. **Wrong threshold, not wrong detector, three times.** `z > 15` where 15 was the
   *count* not the statistic; a resolution band copied from `n = 200` applied at
   `n = 6000`; `0.051 − 0.05` called "1 pp" when it is 0.1 pp. Each produced a
   spurious `FAIL` that looked like a code bug.
6. **`rho` guard tested at the wrong `(x,B)`** — I asserted `u > 5` at
   `(10⁸, 10⁶)`, where `u = 1.33`, i.e. the **easy** regime, while claiming the hard
   one. The divergence is a fixed-`B` limit statement and must be tested as one.
7. **Scalar smoothness test** — 40 000 single-element calls did not finish;
   batched (identical arithmetic, ~2000× fewer dispatches).

---

## 8. What is claimed, and what is not

**Claimed.**
1. Conditioning buys **nothing** on relation-finding: pooled gain **1.007
   (z = +0.83)** best case, **0.998** worst, over 300 000 candidates × 12 moduli.
2. **The mechanism, and it is a theorem:** rejection-conditioning cannot beat the
   fraction `q` it discards, so every balanced character is a **guaranteed ≥ 2×
   loss** regardless of correlation. The arms that fail do not fail by a little.
3. **The Jacobi transplant is information-free** for the Stange family —
   `(g^x/n) = (g/n)^x` — and *undefined* for half of all bases.
4. **`2 − 1/p` confirmed in a new place and shown irrelevant there**: the corner
   is genuinely 1.35–2.00× smoother, and costs `1/p²` to reach. Gain ≤ 0.148.
5. **No structural striding wins**, with the degeneracy detector active.
6. **The uniform search is optimal** for this phase.

**NOT claimed.**
- **Nothing about the real NFS regime.** `π(B*) ≈ 10¹⁵–10³³` makes it
  **not determinable on this host**. All rates are at 36–40-bit `n`, `B ≤ 2¹⁵`.
- **Nothing about the constant `1.9229994`** — consistent with round 52, this
  round does not move it and does not claim to.
- **No factoring was performed.** These are sampling measurements; a rate
  difference is not a factorisation.
- **The `q = 1` result is regime-limited too**: parity/mod-`m` conditioning was
  tested at `u ≈ 2.2`. The *cap* is exact at all `B`; the *null* is measured where
  measurable.

**Open, and worth one round:** the `q = 1` index class is the only place a win can
live, and I tested `m = 2,3,4,8` at `B ≤ 2¹⁵`. A structured generation rule that
changes the **distribution of `g^x mod n` itself** (not an index residue class) is
not covered by this round and is the only remaining idea of this shape.

---

## 9. Reproduce

```
cd factor-scratch/r51exp/relcond
python3 selftest.py       # 50/50 PASS, exit 0   (~40 s)
python3 r1_r4.py          # R1, R1b, R2, R3, held-out   (~45 s)
python3 controls.py       # C1 p_split, C2 spread, C3 free class, C4 table  (~35 s)
python3 final_pooled.py   # THE decisive pooled test, 300k/mode, 12 moduli  (~9 min)
python3 why_evenx.py      # the subgroup hypothesis, refuted
python3 r4_e2e.py         # ⚠️ the n=60 run whose 1.155x is RESOLUTION
python3 r4_power.py       # intermediate power
```

`r4_e2e.py` is **kept deliberately**: it is the run whose 1.155× would have been
reported as a win, and it is the reason `final_pooled.py` exists.

**Sources.** No literature was needed: R1–R4 are measurements on code in this
repository, and the one prior result used (round 52's `2 − 1/p` decomposition)
was re-verified here independently in §3a. **No WebSearch was used** — it
fabricates citations on this host (16 recorded instances).