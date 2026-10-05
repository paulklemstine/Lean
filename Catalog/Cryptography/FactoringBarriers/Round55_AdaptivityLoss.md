# Round 55 — adaptivity below `n/4` is a loss, and two-thirds of the premise was a ceiling artefact

**2026-10-05. NO new factoring algorithm. Round 53's "the wall is a distribution, not a
step" is REAL but the effect size was overstated ~3×, and the adaptive rule it suggests
loses by ~23×.**

Paper: **`Papers/adaptivity_below_n_quarter_is_a_loss.md`** (#542).
Code: `factor-scratch/r55exp/adaptive/` (seeded; cost model byte-identical across runs).
**No modulus of cryptographic interest was generated or factored.** All `n ≤ 2^80`.

---

## 1. VERDICT

> **NEGATIVE, AND THE PREMISE COLLAPSES.** The adaptive rule does not beat `n/4`. **And
> two-thirds of the "sub-`n/4` successes" are an artefact of the lattice grid**, not a
> property of the instances.

## 2. ★ THE PREMISE IS A CEILING ARTEFACT

**At `k = n/4`, where Coppersmith GUARANTEES success**, the factored rate is a function of
the **lattice size**:

| `m` (at `k=n/4`) | 4 | 8 | 12 | 16 | 20 | 26 |
|---|---|---|---|---|---|---|
| factored at `n/4`, `n=48`, T=200 | 33.5% | 56.0% | 67.5% | 74.5% | 80.5% | **85.0%** |

**The grid was too small.** Powered churn test (T=300, **two grids interleaved on identical
moduli**, decision rule **≥60% fixed BEFORE running**): **6 of the 9 instances that "needed
fewer than `n/4` bits" are factored at exactly `n/4` once `m=16`.** **Those instances
never needed fewer bits.**

## 3. THE COST KILL IS INDEPENDENT — so the verdict does not rest on (2)

**Cells manufacturing the marginal win cost `5–24×` the mean `n/4` cell — STRUCTURALLY:**
when `X` is larger by `2^j`, the Howgrave–Graham condition `‖h(xX,yY)₂ < n/√ω` must still
hold, forcing a **LARGER** lattice. **The hypothesis's cost model has the sign backwards.**

## 4. ★ AT MATCHED BUDGET THE OPPOSITE MOVE WINS AT **EVERY** BUDGET

| budget (solves) | go below `n/4` | bigger lattice at `n/4` | winner |
|---|---|---|---|
| 1 | 9.0% | **46.5%** | **M, by 5.2×** |
| 5 | 18.5% | **50.5%** | **M, by 2.7×** |
| 20 | 33.0% | **59.0%** | **M, by 1.8×** |
| 81 | 60.5% | 60.5% | tie (grids exhausted) |

**This is not "no win found" — it is "the win that exists is in the OTHER direction."**
**The adaptivity Coppersmith actually licenses is the `(m,t)` axis, not the `k` axis.**

## 5. The genuine tail SHRINKS with `n`

Stripped of the artefact, a real tail remains at `n=48` (**16/200**, CI [5.0%, 12.6%]).
But: **8.0% → 4.0% → 1.0%** across `n=48/64/80`, Fisher **`p = 0.0010`**. **The win moves
AWAY from RSA scale.**

## 6. Controls

POS control **200/200** · vacuity **2.8e-4** (54/194 400), **299× suppressed** · failure
lattices **0/3 693 600** · **every factorisation verified by DIVISION, never by the
solver** · two grids interleaved on **identical** moduli · decision rule fixed before
running · per-cell with Wilson CIs · determinism byte-for-byte at two sizes.

## 7. ⚠️ ERRORS

1. **★★ `sweep.py` WAS UNSEEDED — the entire first sweep was uncitable.** It built a
   `random.Random(SEED)` that `make_instance` **IGNORES**, because `gen_prime` reads the
   **GLOBAL** module. **Two runs shared ZERO instances.** Bad outputs kept as
   `UNSEEDED_sw*.json`. *Same class as round 53's unseeded counts — but here it silently
   invalidated a whole EXPERIMENT rather than one number.*
2. **The brief's `~d+1×` cost model was wrong, and the correction made the negative
   STRONGER** — the real first-bit multiplier is **1.67×**, below the naive 2×.
3. **The grid starvation was found by asking what Coppersmith GUARANTEES and comparing —
   not by any control.** A starved grid produces a perfectly self-consistent table.
4. **⚠️ A cache bug I found on re-run:** `churn.py` writes `churn_n48_T60_k3.json` and then
   **CRASHES on any subsequent run** unless the cache is deleted. Numbers unaffected —
   I recomputed and got **identical** output — but **"printed a clean table" and
   "reproduces" are different claims.**
5. **A guessed Springer ISBN** returned a paper on parallel skeletons. **Discarded.**

## 8. NOT CLAIMED

**The ceiling-artefact fraction is NOT pinned** — the 9-instance cell clears its rule but
gives CI ≈ **[0.30, 0.90]**, so **"two-thirds" is a point estimate, not a tight
measurement.** · Not a closure of Coppersmith (the `n/4` **bound** is untouched; this is
about exploiting per-instance variation). · **`cell.py` was NOT checked against May's
treatment** — *"Solving Problems with Small Roots mod a Divisor"* unreachable (OpenAlex 0,
zbMATH exhausted, Semantic Scholar 429, four 404s); no claim depends on it, but the gap
is named. · **RSA-scale extrapolation declined outright.**
