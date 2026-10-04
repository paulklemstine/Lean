# Round 57 — the NFS sign is a group homomorphism, so the fraction is `0` or `1/2`, and my `0.4795` was a sampling artefact

**2026-10-03. Rounds 55–56 measured a non-trivial fraction of `0.4795` against
a theoretical `1/2`, and I could not explain the gap. This round explains it:
the measurement was biased. Uniform sampling on the kernel gives exactly `1/2`.**

Empirical: `_scratch/r57/kernel_sampling.py`.

---

## 1. The structure I should have seen first

Let `n = pq` and let `(xᵢ, yᵢ)`, `i ∈ Ι`, be the NFS relations: `xᵢ² ≡ yᵢ
(mod n)` with `yᵢ` `B`-smooth. For `S ⊆ Ι` write

```
X_S = ∏_{i∈S} xᵢ (mod n),     y_S = ∏_{i∈S} yᵢ.
```

When every prime occurs to even exponent in `y_S` we get `y_S = Z_S²`, hence
`X_S² ≡ Z_S² (mod n)` — a congruence of squares, **non-trivial iff
`X_S ≢ ±Z_S (mod n)`**.

The subsets with all parities vanishing form the **`F₂` kernel `K`** of the
relation matrix — an additive group under symmetric difference ⊕. Define
`φ(S) = 0` if the congruence is trivial, `1` otherwise.

**Then `φ : K → ℤ/2` is a group homomorphism.** Two ingredients:

1. `X_S · X_T = X_{S⊕T} · (∏_{i∈S∩T} xᵢ)²` — the symmetric-difference
   correction is a **square** modulo `n`.
2. Every `yᵢ` is a unit mod `n` (its prime factors are `< p, q`), so `Z_S` is
   well defined.

Modulo squares, the sign is exactly what triviality quotients out — so
`φ(S ⊕ T) = φ(S) ⊕ φ(T)`. **Verified directly: 60/60 random triples agree.**

## 2. The consequence

A homomorphism to `ℤ/2` has an **index-2 kernel** (or is trivial). Therefore:

> **Uniformly sampling from `K` gives non-trivial with probability exactly `1/2`,
> or exactly `0` — never anything in between.**

This is why the repo's Round 47 empirical note said the fraction is *"exactly 1/2
or 0, never 3/4"*. It is not an empirical regularity; it is **forced by the group
structure**. No amount of number theory can produce `3/4`.

## 3. The measurement, corrected

Rounds 55–56 sampled in **arrival order** (Gaussian elimination order), which is
*not* uniform on `K`. Sampling uniformly from a kernel basis instead:

| bits | `B` | `dim K` | samples | non-trivial | fraction | z vs 1/2 |
|---|---|---|---|---|---|---|
| 16 | 200 | 325 | 400 | 189 | 0.4725 | −1.10 |
| 16 | 400 | 558 | 400 | 198 | 0.4950 | −0.20 |
| 16 | 800 | 991 | 400 | 201 | 0.5025 | +0.10 |
| 18 | 200 | 326 | 400 | 207 | 0.5175 | +0.70 |
| 18 | 400 | 558 | 400 | 203 | 0.5075 | +0.30 |
| 18 | 800 | 1006 | 400 | 202 | 0.5050 | +0.20 |
| 20 | 200 | 325 | 400 | 197 | 0.4925 | −0.30 |
| 20 | 400 | 567 | 400 | 200 | 0.5000 | +0.00 |
| 20 | 800 | 1046 | 400 | 194 | 0.4850 | −0.60 |

**Pooled: 1791/3600 = 0.4975, z = −0.30, p = 0.76.**

| sampling | fraction | z |
|---|---|---|
| arrival order (R55–56) | 0.4795 | −4.79 |
| **uniform on `K` (this round)** | **0.4975** | **−0.30** |

Per-configuration `z ∈ [−1.10, +0.70]`, **no trend in size or `B`** — exactly as
the homomorphism predicts. **Round 56's "flat offset of ≈ −0.022 of unknown
origin" was an artefact of the sampling scheme.** I should have suspected this
in Round 56 rather than listing three mechanisms I had no way to distinguish.

## 4. A third bug, in the new instrument

The first version of this round's script **printed nothing at all** — every cell
took the "too few relations" branch. Cause: `kernel_basis` returned the **pivot**
combinations (one per pivot row) instead of the **dependencies** (combinations
reducing to the zero vector). Only the latter are kernel elements. Every sample
then had a non-square `Y_S`, and the run silently reported zero results.

Same failure mode as Rounds 55 and 56: **an instrument that produces nothing is
reported as "nothing found" rather than "broken."** Three rounds, three
instruments, three silent failures. The only reason each was caught is that I
printed a diagnostic that was obviously impossible (`0.000` fraction; empty
table). I now check that first, before interpreting any output.

---

## 5. What this establishes, and what it does not

**Establishes:**
- The non-trivial congruences form a **coset of index 2** in `K` (or there are
  none). The fraction is `0` or exactly `1/2`; `3/4` is impossible. Direct
  homomorphism check: 60/60.
- **The expected number of kernel draws per factor is 2**, with no further
  hypothesis — provided non-triviality occurs at all.
- Lee–Venkatesan Conj. 7.1 is an **index question** ("is `φ` onto?"), not a
  distributional one. That is a sharper formulation of the open problem.

**Does not establish:**
- That `φ` is onto for the NFS relation matrices of arbitrary `n`. **That is
  exactly Conj. 7.1**, and it remains open. If `φ` is trivial the fraction is
  `0`, which is consistent with everything measured here.

**Not machine-checked.** I began a Lean file for the index-two statement, hit
nine errors, and **deleted it rather than ship something I had not verified**.
The three verified files (`LehmanPairs`, `APCoverReduction`, `ShapeGap`) remain
at 0 errors / 0 `sorry`. The homomorphism claim above rests on the stated
argument and the 60/60 empirical check, not on a proof assistant. Labelling it
that way is the honest record.

---

## 6. Verdict

**No new factoring algorithm. No improved bound.** Round 57 adds an algebraic
explanation for an anomaly I could not previously account for, and retracts
Round 56's "unknown-origin offset."

**Standing frontier after eight rounds.** Closed: order subroutine (R50),
small-factor test (R52), `L[1/2,c<1]` (R53), prime enumeration (R54),
deterministic practicality (R54), consecutive-AP covers and `k=ab` re-indexing
(R49/R51), ECM substitution (R52). Open: **non-triviality** (now an index
question, and empirically at the theoretical value) and **the Lehman pair count**
(equivalent to factoring).

I will not do an eighth round of instrument-level measurement on this quantity.
The remaining question — is `φ` onto? — is a proof about one specific map, and
that needs mathematics rather than sampling.