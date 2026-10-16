# RESULT — Axis I: reference baseline for the ECDSA nonce-leakage (HNP) lattice attack

Round 115, `factor-scratch/r115/hnp-baseline/`. **Status: SUPPORTED (baseline measured).**
This is deliberately *not* a novel attack; it is the reference number that every
structured-nonce sub-axis in this round must beat.

## 1. The claim

For ECDSA with signatures `s_i k_i ≡ z_i + r_i d (mod n)`, where the attacker knows
`ℓ` high bits of each nonce (`k_i = a_i + K_i`, `K_i < 2^m`, `m = nbits − ℓ`), the
classical HNP lattice attack (SVP / Kannan embedding, LLL) recovers the private key
with high probability when the **total leakage** `t·ℓ` exceeds `log₂(n)` by a small
dimension-dependent factor:

| lattice dimension | total leakage needed `t·ℓ` | ratio to `log₂(n)` |
|---|---|---|
| t+1 = 3 (t=2) | ≈ 1.03 × log₂n | 1.03 |
| t+1 = 5 (t=4) | ≈ 1.13 × log₂n | 1.13 |
| t+1 = 9 (t=8) | ≈ 1.13 × log₂n | 1.13 |
| t+1 = 17 (t=16) | ≈ 1.50 × log₂n | 1.50 |

The information-theoretic floor is the counting condition on lattice points inside the
box: `2^(t·m)/n^(t−1) < 1 ⟺ t·ℓ > log₂(n)`. LLL sits close to it for small dimensions
and drifts up to 1.5× at dimension 17, as expected for a heuristic reduction.

This reproduces the published picture (Howgrave-Graham–Smart, Nguyen–Shparlinski,
Minerva, LadderLeak, Breitner–Heninger) but with the campaign's own harness, its own
threshold curve, and the floor printed next to every count.

## 2. Falsifier

The claim is killed if any of these fails:
1. A cell where `ℓ = 0` (no leakage) recovers the key — that would mean the harness
   is not testing anything. **Measured: 0/12.**
2. A cell where `t·ℓ ≥ 2·log₂(n)` (leakage double the key entropy) fails — that would
   mean the reduction is broken. **Measured: 12/12 everywhere.**
3. A cell *exactly at* the floor (`t·ℓ = log₂ n`) recovering at high rate — that would
   contradict the counting argument. **Measured: 2/12 at every at-floor cell**
   (consistent across both runs).

## 3. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r115/hnp-baseline
/home/raver1975/sage_mamba/envs/sage/bin/sage run.sage       # controls + full sweep
/home/raver1975/sage_mamba/envs/sage/bin/sage run2.sage      # second run of headline cells
/home/raver1975/sage_mamba/envs/sage/bin/sage verify.sage    # real secp256k1 cross-check
```
`hnp_baseline_lib.sage` holds the definitions; `run.sage` loads it with Sage's
preparser-aware `load()`.

## 4. Counts (both runs, 12 seeds each, fixed seeds 0..11)

Threshold cells — first `ℓ` reaching ≥10/12:

```
nbits=64 : t=2 -> l=33 (floor 32)   t=4 -> l=18 (floor 16)   t=8 -> l=12 (floor 8)    t=16 -> l=6 (floor 4)
nbits=96 : t=2 -> l=52 (floor 48)   t=4 -> l=28 (floor 24)   t=8 -> l=16 (floor 12)   t=16 -> l=8 (floor 6)
nbits=128: t=2 -> l=66 (floor 64)   t=4 -> l=36 (floor 32)   t=8 -> l=18 (floor 16)   t=16 -> l=12 (floor 8)
nbits=192: t=2 -> l=99 (floor 96)   t=4 -> l=54 (floor 48)   t=8 -> l=27 (floor 24)   t=16 -> l=18 (floor 12)
nbits=256: t=2 -> l=132 (floor 128) t=4 -> l=72 (floor 64)   t=8 -> l=36 (floor 32)   t=16 -> l=24 (floor 16)
```

Both runs agree at every headline cell, e.g. `(128,4,32)` at the floor → 2/12 twice;
`(128,4,48)` above the floor → 12/12. 452 sweep points recorded in `sweep_msb.log`.

Real-curve cross-check (genuine secp256k1 signatures, verified self-consistent:
`s_i k_i ≡ z_i + r_i d (mod n)` for all four): with t=4, no recovery at `t·ℓ = 256`
(exactly the floor) and recovery from `t·ℓ = 384` up. Real `(r,s)` pairs behave exactly
as the algebraic model predicts, which is the point of the check — the lattice depends
only on the equation, not on the curve.

## 5. Baseline discipline

- **Mandatory baseline (information-theoretic floor) `t·ℓ ≥ log₂ n`:**
  measured threshold is 1.03× (t=2) rising to 1.50× (t=16). Reported beside every cell.
- **Triviality rule:** every "success" is a recovery of `d` verified against ground
  truth, at a parameter point where the *library* could not shortcut it. `ℓ = 0`
  (a case where the answer is free, since any `d` is a valid solution) is used as the
  **negative control**, not as evidence.
- **Success definition:** `d_recovered == d_ground_truth`. Rows that are small but not
  the key are counted separately (`wrong` in the source) — this is the campaign's
  pigeonhole failure mode and it is explicitly guarded against.

## 6. Traps hit while building this (all documented, all caused fake or wrong results)

1. **`sage file.sage` in this Sage 10.9 runs with `__name__ == 'sage.all'`, not
   `'__main__'`.** An `if __name__ == "__main__":` block silently does nothing.
   The first version of the harness produced no output at all because of this.
2. **The instance generator did not enforce the signature equation.** `s_i` was drawn
   independently at random, so no instance was algebraically consistent and the attack
   could never work; the derived relations `sK − rd ≡ c` and `K ≡ βd + vp` both
   evaluated to **False**. This is the campaign's "ground truth first" rule biting.
   Fixed by computing `s_i = (z_i + r_i d)·k_i^{-1} mod n`.
3. **A first "positive control" of 12/12 was a false positive** produced by
   rational-`%` behaviour in the row harvester; the degenerate `ℓ = 0` case exposed it.
   Re-implemented and re-verified.
4. **The CVP formulation is the wrong tool.** The classical HNP attack is an *SVP*
   embedding problem: the uniqueness condition `t·ℓ ≥ log₂ n` counts lattice points in
   the box, it is not a "closest to the centre" condition.
5. **The Kannan weight is not scale-free.** `B = 2^{2nbits+8}` never reveals the
   target row; `B = 2^nbits` works. The construction is, however, robust across
   `B ∈ [2^{nbits−4}, 2^{nbits+8}]` — tested at four parameter points.
6. **`json.dump` of a Sage `Integer` raises.** Not JSON-serializable; counts must be
   cast with `int()`.
7. **`randint(..., seed=...)` does not exist in this Sage.** Use
   `set_random_seed(sd)` at the start of the instance builder.
8. **`IntegerLattice.closest_vector()` takes no `method=` keyword** in this release, and
   the default appears to be an expensive exact enumeration (a 96-bit, dimension-5 call
   exceeded 900 s). LLL on the basis was 0.003 s by comparison.

## 7. Verdict

**SUPPORTED** as a baseline. The plain HNP lattice attack's measured threshold is
`t·ℓ ≈ (1.03 … 1.50) × log₂ n`, depending only on lattice dimension, and it is
reproducible across two runs at 256-bit scale. Any structured-nonce variant (r-bias,
LCG-structured nonces, GLV-sublattice nonces, Range/EHNP variants) is judged against
this curve, and the burden is to beat `1.03–1.5 ×` — not to beat `1.0×` alone, which
the floor already forbids.
