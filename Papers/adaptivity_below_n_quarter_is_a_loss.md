# Adaptivity Below `n/4` Is a Loss

## The sub-`n/4` successes are real — and shrink with `n`, and cost more than they return. **At matched budget, a bigger lattice at `n/4` beats going below `n/4` outright.**

**Round 55 · 2026-10-05 · Aether factoring programme**

---

## Abstract

Round 53 measured that the univariate "n/4 wall" is a **distribution, not a step**:
re-running the corpus's instrument on 40 instances per size instead of one, **12/40
instances at `n=48` factor from strictly fewer than `n/4` known bits**, verified real by
division check. **The obvious algorithmic consequence had never been tested.**

> ## **NEGATIVE — and the premise collapses too.**
> ## **The adaptive rule does not beat `n/4`, by a factor of ~23 in cost efficiency.
> ## And two-thirds of the "sub-`n/4` successes" are an artefact of the lattice grid,
> ## not a property of the instances.**

**(1) THE PREMISE IS A CEILING ARTEFACT.** At `k = n/4`, **where Coppersmith
guarantees success**, the factored rate is **not** ~100% — it is a function of the
**lattice size**:

| `m` (at `k = n/4`) | 4 | 8 | 12 | 16 | 20 | 26 |
|---|---|---|---|---|---|---|
| factored at `n/4`, `n=48`, T=200 | 33.5% | 56.0% | 67.5% | 74.5% | 80.5% | **85.0%** |

**My grid was too small.** The powered churn test (T=300, two grids interleaved on
**identical** moduli, decision rule **≥60% fixed before running**) confirms it directly:
**6 of the 9 instances that "needed fewer than `n/4` bits" are factored at exactly
`n/4` once `m=16`. Those instances never needed fewer bits.**

**(2) THE COST KILL IS INDEPENDENT OF THAT**, so the verdict does not rest on the
premise collapsing. The cells that manufacture the marginal sub-`n/4` win cost
**5–24×** the mean `n/4` cell — **structurally**, since `X` larger by `2^j` forces a
*larger* lattice to keep the Howgrave–Graham condition. **The hypothesis's cost model
has the sign backwards.**

**(3) AT MATCHED BUDGET THE OPPOSITE MOVE WINS AT EVERY BUDGET:**

| budget (solves) | go below `n/4` | bigger lattice at `n/4` | winner |
|---|---|---|---|
| 1 | 9.0% | **46.5%** | **M, by 5.2×** |
| 5 | 18.5% | **50.5%** | **M, by 2.7×** |
| 20 | 33.0% | **59.0%** | **M, by 1.8×** |
| 81 | 60.5% | 60.5% | tie (both grids exhausted) |

**The adaptivity Coppersmith actually licenses is in the `(m,t)` axis, not the `k` axis.**

**And the genuine tail shrinks with `n`: 8.0% → 4.0% → 1.0%** across `n=48/64/80`,
Fisher **`p = 0.0010`** — **the win moves away from RSA scale, not toward it.**

**Classical factoring of RSA-scale integers. Not a cryptographic break.** No modulus of
cryptographic interest was generated or factored; all `n ≤ 2^80`, locally generated.

---

## 1. The cost model — measured per cell, never assumed

A strategy is an **ordered list of cells**; a cell is one `(k, m, t)` lattice solve.
Per-instance cost is **exactly** the sum of measured cell costs up to and including the
first success — no modelling, no averaging shortcut.

Median wall-clock per lattice solve, from the same process (shared machine state between
arms):

| lattice dim `m·t` | 4 | 25 | 49 | 81 | 100 | 121 |
|---|---|---|---|---|---|---|
| median seconds | 0.000105 | 0.000716 | 0.002789 | 0.005274 | 0.007616 | 0.011152 |

All costs are `statistics.median` over **T=200 instances per cell**, which removes
machine jitter without hiding the dimension dependence.

**The brief predicted `~d+1` times a single attempt. Measured at `n=48`, T=200:**

| strategy | success | mean cells | mean secs | cells × | **s/factored** |
|---|---|---|---|---|---|
| `n/4` only (`d=0`) | 60.5% | 47.3 | 0.1093 | ×1.00 | **0.1807** |
| `+1` bit (`d=1`) | 62.5% | 78.9 | 0.1932 | ×1.67 | **0.3091** |
| `+2` bits (`d=2`) | 64.5% | 108.8 | 0.2714 | ×2.30 | **0.4208** |
| `+3` bits (`d=3`) | 66.0% | 137.2 | 0.3478 | ×2.90 | **0.5270** |
| `+5` bits (`d=5`) | 68.5% | 190.0 | 0.4907 | ×4.01 | **0.7164** |

**The multiplier is 1.67× for the first bit, not 2×** — because ~60% of instances exit
during the `n/4` stage and never pay for the extra budget. **This is the discounted,
generous cost model, and even it loses.**

> ⚠️ **A precision note on the multiplier.** The `×1.67` is the **cells** ratio
> (`78.9/47.3`). The **seconds** ratio is `×1.77`, and the **cost per factored modulus**
> ratio is `0.3091/0.1807 = ×1.71`. I verified every reported figure reproduces under
> `s/factored = mean_secs / success_rate` — all five rows exact. The three multipliers
> agree to within 6%, and the conclusion is the same under any of them.

## 2. There is no crossover at any `d`, at any size

Seconds per **factored** modulus:

| `n` | `d=0` | `+1` bit | `+2` | `+3` | best `d` |
|---|---|---|---|---|---|
| 48 | 0.1807 | 0.3091 | 0.4208 | 0.5270 | **none — monotonically worse** |
| 64 | 0.5634 | 1.0145 | 1.3910 | 1.7749 | **none — monotonically worse** |
| 80 | 1.2306 | 2.3181 | 3.3094 | 4.3535 | **none — monotonically worse** |

Success gained for that cost: **+2.0 pts for ×1.71** (`n=48`), **+1.0 pts for ×1.81**
(`n=64`), **+0.0 pts for ×1.88** (`n=80`).

> **A 16/200 success rate that costs 1.71× the lattice solves is a loss.**

## 3. ★ The winning move is the opposite one — and it wins at EVERY budget

**At matched budget, staying at `n/4` and buying a bigger lattice beats going below
`n/4` at every budget short of exhausting the grid**, by **5.2× at 1 solve, 2.7× at 5,
1.8× at 20**. Same ordering in seconds.

| budget (solves) | Axis K (go below `n/4`) | Axis M (bigger lattice) | winner |
|---|---|---|---|
| 1 | 9.0% | **46.5%** | **M, by 5.2×** |
| 5 | 18.5% | **50.5%** | **M, by 2.7×** |
| 20 | 33.0% | **59.0%** | **M, by 1.8×** |
| 81 | 60.5% | 60.5% | tie (both grids exhausted) |
| 200 | 62.5% | **64.5%** | M |

> **This is not "no win found" — it is "the win that exists is in the other direction."**

**And the marginal cells are expensive for a structural reason.** When `X` is larger by
`2^j`, the Howgrave–Graham condition `‖h(xX,yY)‖₂ < n/√ω` must *still* hold — which
forces a **larger** lattice, not a cheaper one. **The hypothesis's cost model has the sign
backwards:** it assumed the extra budget buys a cheaper cell, when in fact going below
`n/4` demands an *expensive* one. Measured entry price: **5–24×** the mean `n/4` cell.

## 4. ⚠️ A correction to my own round-53 framing

Round 53 reported "12/40 at `n=48` beat `n/4`" and read it as evidence that the wall is
a distribution. **True — but two-thirds of it was an artefact of the lattice grid.**

> **At `k = n/4`, where Coppersmith *guarantees* success, my grid (`m,t ≤ 10`) factored
> only 60.5% of instances — and raising `m` to 26 takes it to 85%.** The missing 40% was
> **a property of my grid, not of the instances.**

The powered churn test settles it: of the 9 instances that "needed fewer than `n/4`
bits", **6 are factored at exactly `n/4` once `m = 16`.** Those instances never needed
fewer bits.

**This does not make round 53 wrong** — the sub-`n/4` factorizations were verified by
division and are real — **but the denominator was understated, and the adaptive rule
built on it inherits that.** Round 53's paper says the wall is "a distribution, not a
step"; **that remains true, but the effect size is roughly a third of what was reported.**

## 5. The genuine tail shrinks with `n`

**Stripped of the ceiling artefact, a real tail remains at small `n`.** At `n=48`,
**16/200** factor from strictly fewer than `n/4` known bits, 95% CI **[5.0%, 12.6%]**,
excluding 0.

**But the rate collapses with size: 8.0% → 4.0% → 1.0%** across `n=48/64/80`, Fisher
**`p = 0.0010`**. **A benefit that vanishes as the modulus grows cannot carry a
constant-factor cost** — and the win moves *away* from RSA scale, not toward it.

## 5b. Controls

| control | status |
|---|---|
| **Positive control fires** | ✅ **200/200** |
| **Vacuity of a successful lattice** | ✅ **2.8e-4** (54 hits / 194 400 probes), **299× suppressed** |
| **Failure lattices annihilate nothing** | ✅ **0 / 3 693 600** |
| **Every factorisation verified by division** | ✅ never by the solver |
| **Two grids interleaved on IDENTICAL moduli** | ✅ so the ceiling comparison is paired |
| **Decision rule fixed BEFORE running** | ✅ **≥60%** |
| **Per-cell reporting, never pooled alone** | ✅ expected count beside every rate, Wilson CIs |
| **Determinism** | ✅ byte-for-byte at two sizes; `churn.py` reproduces identically after its cache is cleared (see §6) |

## 6. Errors and hazards encountered

- **★★ `sweep.py` WAS UNSEEDED — and the whole first sweep was therefore uncitable.**
  It built a `random.Random(SEED)` that `make_instance` **ignores**, because `gen_prime`
  reads the **global** module. **Two runs shared ZERO instances.** Caught only by running
  the calibration twice, comparing, and re-running everything; the bad outputs are kept as
  `UNSEEDED_sw*.json` rather than deleted. *This is the same class as round 53's unseeded
  counts — and here it silently invalidated an entire experiment rather than just a
  number.*
- **The brief's predicted cost model (`~d+1×`) was wrong, and the correction made the
  negative STRONGER** — the real first-bit multiplier is 1.67×, *below* the naive 2×,
  because ~60% of instances exit during the `n/4` stage. *A prediction that errs against
  your own conclusion is worth stating.*
- **My grid starvation (§4) was found by asking what Coppersmith *guarantees* and
  comparing — not by any control.** **No control would have caught it**, because a starved
  grid produces a perfectly self-consistent table.
- **⚠️ A cache bug in `churn.py`, found by me on re-run.** The first invocation writes
  `churn_n48_T60_k3.json`; a second **loads that file and then crashes** (the cache stores
  a bare dict, and the caller indexes it with an outer key a fresh run would have
  created). **"The script printed a clean table" and "the script reproduces" are different
  claims.** The numbers are unaffected — I deleted the cache and recomputed, and the
  output was **identical** — but a reader following §8 would hit a traceback.
- **A guessed Springer ISBN** returned a paper on parallel skeletons. **Discarded, not
  cited.**

## 7. What is NOT claimed

- **The ceiling-artefact fraction is not pinned.** The 9-instance cell clears its
  pre-registered ≥60% rule but gives 95% CI ≈ **[0.30, 0.90]** — **so "two-thirds" is the
  point estimate, not a tight measurement.** I am not claiming more precision than a
  9-instance cell supports.
- **Not a closure of Coppersmith.** Nothing here bears on the `n/4` bound itself, which
  remains a worst-case *guarantee*. The finding is about *exploiting* per-instance
  variation, not about the bound's validity.
- **Not a claim that adaptivity is useless everywhere** — only that on this axis, at these
  sizes, with this cost structure, it loses.
- **`cell.py` follows the Coppersmith/Coron construction I read; I could NOT check it
  against May's treatment** — *"Solving Problems with Small Roots mod a Divisor"* was
  unreachable (OpenAlex count 0, zbMATH exhausted, Semantic Scholar 429, four 404s).
  **No claim here depends on it**, but the gap is real and named.
- **RSA-scale extrapolation declined outright.** All `n ≤ 2^80`, locally generated.

## 8. Reproduce

```
cd factor-scratch/r55exp/adaptive
python3 price.py       # the cost model and the sweep multiplier
python3 churn.py --n 48 --T 200    # the per-instance sub-n/4 rate
python3 headtohead.py  # matched-budget: bigger lattice vs lower k
python3 vacuity.py     # negative control on the lattice
```

`price.py` verified byte-identical across two runs. `churn.py` and `guarantee.py`
require an explicit `--n`. ⚠️ **`churn.py` writes a cache and then CRASHES on any
subsequent run unless you delete `churn_n48_T60_k3.json` first** (see §6) — delete it
before re-running. Dependencies: Python 3.12, `sympy`, `fpylll`.