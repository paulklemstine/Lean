# Computational Evidence — Spectral Free-Witness (heat-kernel order recovery)

All computations below were run inside Lean 4 (`#eval`, `Float` arithmetic, IEEE double
precision) before and while the formal proofs were written.  They are *evidence*, not
proof; every claim that appears as a theorem in `Catalog/Algebra/SpectralFreeWitness*.lean`
is separately machine-checked with no `sorry` and no `native_decide`.

Notation (matching the Lean files):

* `λ_k = (1/(M+1)) Σ_{t=0}^{M} cos(2π k 2^t / r)`  (`dyadicEigen r M k`)
* `μ_k = (1 + λ_k)/2`  (`lazyEigen r M k`)
* `p_n(e) = (1/r) Σ_{k<r} μ_k^n`  (`heatReturn r M n`)

## 1. Reproduction of the reported experiment (HKW-VERIFIED)

`N = 143, 221, 899`, orders `r = 60, 15, 24, 48, 140, 420`, `M = ⌈log₂ N⌉`,
`n = 8 (M+1)²`:

| r | M | n | p_n(e) | 1/p_n(e) | round(1/p_n(e)) |
|---|---|---|--------|----------|-----------------|
| 60 | 8 | 648 | 0.0166667 | 60.000000 | **60** |
| 15 | 8 | 648 | 0.0666667 | 15.000000 | **15** |
| 24 | 8 | 648 | 0.0416667 | 24.000000 | **24** |
| 48 | 8 | 648 | 0.0208333 | 48.000000 | **48** |
| 140 | 10 | 968 | 0.0071429 | 140.000000 | **140** |
| 420 | 10 | 968 | 0.0023810 | 420.000000 | **420** |

The residual `p_n(e) − 1/r` is below `10⁻¹⁸` in all six cases (i.e. it is 0 to double
precision), far inside the proved bound `1/(4N²) ≈ 1.2·10⁻⁵` for `N = 143`.

**Deviation from the source note.** At the *minimal* step count `n = 2(M+1)²` the source
reports only partial recovery.  In our runs all six cases already recover exactly at
`n = 2(M+1)²`.  The formal theorem is stated at the conservative `n = 8(M+1)²`, which we
prove always suffices (`heat_kernel_order_recovery`).

## 2. Doubling lemma — exhaustive check

For every `2 ≤ r ≤ 201`, every `1 ≤ x < r`, and `M = ⌊log₂ r⌋ + 1`, we searched for a
counterexample to "some `t ≤ M` has `2^t x mod r` in the far arc `[r/4, 3r/4]`".
Result: **no counterexamples** (empty list).  This is now the theorem
`exists_dyadic_quarter`, proved for all `r, x, M` with `r ≤ 2^M`.

## 3. Spectral gap: proved bound vs. observed maximum

Largest nontrivial half-lazy eigenvalue `max_{k≠0} μ_k`, versus the proved bound
`1 − 1/(2(M+1))`:

| r | M | max μ_k | proved bound | (1−max μ_k)·2(M+1) |
|---|---|---------|--------------|--------------------|
| 15 | 8 | 0.60631 | 0.94444 | 7.09 |
| 60 | 8 | 0.88889 | 0.94444 | 2.00 |
| 255 | 8 | 0.81089 | 0.94444 | 3.40 |
| 1023 | 10 | 0.84559 | 0.95455 | 3.40 |

The bound always holds, with slack; the normalised deficiency `(1−μ)·2(M+1)` stays
bounded, i.e. the gap is genuinely of order `1/M`, not larger.

## 4. Sharpness on the Mersenne family `r = 2^M − 1`, `k = 1`

`(1 − λ₁)·(M+1)`:

| M | 4 | 6 | 8 | 10 | 12 | 16 | 20 |
|---|---|---|---|----|----|----|----|
| value | 3.5865 | 3.4337 | 3.4039 | 3.3969 | 3.3952 | 3.39469 | 3.39465 |

The sequence converges rapidly to a constant `c* ≈ 3.3946`.  This confirms the proved
statement `λ₁ ≥ 1 − 106/(M+1)` (`dyadicEigen_mersenne_ge`) and shows the gap is
`Θ(1/M)`: the true constant is ≈ 3.39, our proved constant 106 is loose but of the
right shape.  (The looseness comes from using `cos x ≥ 1 − x²/2` on *all* frequencies,
including the top ones where the bound is far from tight.)

## 5. Global minimum of the spectral deficiency

`D(M) = min_{2 ≤ r ≤ 2^M} min_{1 ≤ k < r} Σ_{t=0}^{M} (1 − cos(2π k 2^t / r))`:

| M | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|
| D(M) | 2.0 | 2.0 | 2.0 | 2.0 | 2.0 | 2.0 | 2.0 |

minimiser always `(r, k) = (2, 1)`.  Our theorem proves `D(M) ≥ 1` (one term with
`cos ≤ 0` contributes at least 1).  The data suggest the sharp constant is exactly `2`,
which would halve the mixing constant.  This is Conjecture C1 in `FUTURE_DIRECTIONS.md`.

## 6. OEIS

No new integer sequence is produced by this work: the quantities involved
(`⌊log₂ N⌋ + 1`, `8(M+1)²`, orders `ord_N(b)`) are standard, so no OEIS lookup applies.
