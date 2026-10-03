# Stride sampling: a real saving on the one method that factors — and a hypothesis of mine that was wrong

**Orchestrator note, 2026-10-03. `_shared/stride_sampler.py`.**

## The target

Stange's relation finder (`exp/stange/stange.py::find_relations`) has two samplers:

| sampler | candidate generation | cost per candidate |
|---|---|---|
| `random` | `pow(g, x, n)`, `x` uniform in `[1,n)` | **O(log x) multiplications** |
| `seq` | `r = (r·g) % n`, `x = 1,2,3,…` | **ONE multiplication** |

That matters: the round-48 baseline measured **exp/rel = 22 at 2²⁰ rising to 26,213 at 2⁴⁰**.
If the cost per candidate can be cut from `O(log x)` to `O(1)` without changing the sampling
population, that is a straight multiplier on the method's whole budget.

**But `seq` was rejected, and correctly** — round 48 recorded that consecutive `x` gives
`g^(x+1) = g·g^x`, so the relation vectors satisfy finite differences and **84%/55% of the
`α_t` came out exactly zero**: a spurious kernel that looks like a high hit rate.

## Hypothesis (mine, and it was WRONG)

> Stride sampling — `x = 1, 1+s, 1+2s, …` with `r ← r·g^s` — keeps the one-multiply cost
> while breaking the consecutive structure.

**Refuted.** The degeneracy is not consecutiveness.

## The right discriminator — and why my first self-test was useless

My first attempt compared supports of consecutive relation vectors. It returned 0.00 even for
`seq`, i.e. it could not detect the known-bad case. **My self-test failed, which is the only
reason I noticed.** (Third time today I have tested the wrong quantity — see
`V_repeat_of_the_vacuous_measurement.md`.)

The correct discriminator is the **Dickman model itself**:

> A sampler that finds `B`-smooth values *faster than `ρ(u)` predicts* is not sampling the
> population — it is exploiting a degenerate corner of the candidate sequence.

Measured at `n ≈ 2³³`, `B = 2¹⁷`, where `ρ(u) = 0.3561` predicts **2.81 trials/relation**:

| sampler | trials/rel | vs Dickman |
|---|---|---|
| `random` | 2.6 | **1.09×** — sound |
| `seq`, `s=1` | 1.0 | **2.81×** — degenerate |
| `stride`, `s=2` | 1.0 | **2.81×** — same degeneracy |
| `stride`, `s=7` | 1.4 | 1.98× |

**Striding does not help at all.** The cause is not that `x` values are consecutive — it is
that **`g^x mod n` is small whenever `x` is small** (`g¹ = 2`, `g² = 4`, … up to `x ≈ 20`), and
those trivially-smooth candidates are what `seq` was harvesting. A stride does not change the
size of the early candidates.

## The repair, and it works

Start `x` at a value where `g^x mod n` is **full size**, then stride:

| `x₀` | s=1 | s=2 | s=8 |
|---|---|---|---|
| `1` (broken) | 2.81× | 2.81× | 1.53× |
| `2²⁰` | 1.16× | 1.30× | 1.12× |
| **`n/4`** | **0.84×** | 0.75× | **0.96×** |
| **`n/2`** | **1.20×** | 1.12× | **1.20×** |

**At `x₀ ≈ n/4`–`n/2` the ratio is ≈1 — the sampler draws the population — while costing one
multiplication per candidate instead of a full `pow`.** That is the degenerate-free version of
the cheap sampler, and it is the only configuration that earns the saving.

## What is claimed, and what is not

**Claimed.** A diagnostic: *the `seq` degeneracy is small-`x`, not consecutiveness.* This is
supported by the mechanism (`g^x` small for small `x`) and by the fact that striding at `x₀ = 1`
reproduces the degeneracy exactly (2.81×) while `x₀ = n/4` does not.

**Claimed.** The repair direction: start at full-size `x₀`, stride freely, keep one multiply
per candidate.

**NOT claimed, and these are substantial:**
- **No speedup has been measured.** I measured *trials per relation*, not multiplications, and
  a trial in the `random` sampler is a full `pow` while in a strided sampler it is a multiply.
  The conversion factor is the whole point and I have not measured it end to end.
- **It has not been shown to FACTOR.** 12 relations is not a factor extraction. The `α_t`
  kernel must be checked for degeneracy *after* the repair — my repair removes the small-`x`
  corner, but whether the resulting kernel is clean is untested.
- **n = 12 relations, one `n`, one seed.** Ratios of 0.75–1.20 are consistent with noise.
- **B = 2¹⁷ at a 33-bit `n`**, i.e. far easier than any realistic NFS setting, where the cost
  explosion (26,213 exp/rel at 2⁴⁰) is where the saving would actually matter.

## Next step for whoever picks this up

Port the repair into `exp/stange/stange.py::find_relations` as a fourth sampler
(`sampler="stride_full"`, taking `x0` and `s`), then:
1. count **multiplications**, not trials, for `random` vs `stride_full`;
2. run the **kernel** and check `α_t = 0` rate against the `seq` baseline — the repair must be
   shown to produce a non-degenerate kernel, not merely a plausible smoothness rate;
3. **actually factor**, at `n` large enough that the cost matters;
4. verify on fresh instances not used for tuning.

A clean result here would be a genuine, if modest, algorithmic improvement to the only
construction this program has found in 48 rounds. An unclean one is another documented
negative, and given the round's record that is equally worth having.