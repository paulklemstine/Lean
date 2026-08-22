# Computational Evidence

Numerical checks made *before* formalising, to make sure the constants and
inequalities used in `Catalog/NumberTheory/AlephOneSurfaceHausdorff.lean` and
`Catalog/NumberTheory/TransfiniteDimensionCeiling.lean` are true and sharp enough.
All numbers below were produced with `#eval` inside Lean (Float arithmetic); they
are *evidence*, not proof — the corresponding statements are proved in the Lean
files with exact arithmetic.

## 1. The tail estimate constant

The surface lives in the `ℓ²`-box `∏ᵢ [0, 2^{-i}]`.  The truncation error at level
`N` satisfies `‖x − trunc_N x‖² ≤ T(N) := Σ_{i≥N} 4^{-i} = (4/3)·4^{-N}`.
In the Lean proof we replace `T(N)` by the coarser but pointwise-provable bound
`B(N) := 2·2^{-N}` (obtained from `4^{-i} ≤ 2^{-N}·2^{-i}` for `i ≥ N`, which
avoids any geometric-tail reindexing).  Check that `T ≤ B`:

| N | T(N) = (4/3)·4^{-N} | B(N) = 2·2^{-N} | T ≤ B |
|---|---------------------|-----------------|-------|
| 0 | 1.333333 | 2.000000 | true |
| 1 | 0.333333 | 1.000000 | true |
| 2 | 0.083333 | 0.500000 | true |
| 3 | 0.020833 | 0.250000 | true |
| 4 | 0.005208 | 0.125000 | true |
| 5 | 0.001302 | 0.062500 | true |
| 6 | 0.000326 | 0.031250 | true |
| 7 | 0.000081 | 0.015625 | true |
| 8 | 0.000020 | 0.007812 | true |

The uniform error actually used in the continuity proof is `√B(N)`:

| N | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| √B(N) | 1.4142 | 1.0000 | 0.7071 | 0.5000 | 0.3536 | 0.2500 | 0.1768 | 0.1250 | 0.0884 |

Decay is geometric with ratio `1/√2`, so the truncations converge uniformly and the
tautological map from the product box to `ℓ²` is continuous.  Formalised as
`AlephOneHausdorff.boxTrunc_tail_estimate` and `boxToElltwo_continuous`.

## 2. Square-summability of the box

`Σ_{i<30} 4^{-i} = 1.333333`, already equal to `4/3` to six digits: every point of
the box has `ℓ²`-norm at most `√(4/3) ≈ 1.1547`, confirming `Memℓp y 2`
(`AlephOneHausdorff.memlp_of_boxSet`) and that the box is bounded.

## 3. The dimension spectrum of arithmetic surfaces

For `S ⊆ ℕ`, `dimH (surfaceOf S) = sup S`.  Truncated at 60, the largest prime is
`59`, so the truncated prime surface has dimension `59`; letting the truncation grow
the dimension is unbounded exactly because the primes are.  This is the finite
shadow of `AlephOneHausdorff.primeSurface_transfiniteDimensional`.

## 4. Counterexample hunt

Two "obvious" strengthenings were tested and discarded before any Lean effort:

* *"`dimH` can equal a cardinal."*  Rejected on type grounds: `dimH : Set X → ℝ≥0∞`.
  Instead we proved the structural obstruction
  `TransfiniteDimensionCeiling.no_aleph_one_dimension_hierarchy`: even an
  `ℵ₁`-indexed increasing hierarchy of dimensions is impossible, because a
  well-founded subset of `ℝ≥0∞` is countable (each gap swallows a distinct
  rational).
* *"The surface is compact, like the Hilbert cube containing it."*  False: the
  diagonal point `(2^{-i})_i` has all truncations in cells but lies in none, and
  numerically its distance to the `N`-th cell is exactly `√T(N) → 0`.  Formalised
  as `AlephOneHausdorff.alephSurface_not_isCompact`.

## 5. Cube sizes inside a ball (cycles 6–7)

To certify `dimH (ball x r) = ⊤` we insert, for each `n`, a flat `n`-cube of side
`s(n) = r / (2(√n + 1))` into `ball x r`; the sup-norm bound `‖slab n y‖ ≤ √n ‖y‖`
gives `√n · s(n) ≤ r/2 < r`. Sample values for `r = 1`:

| `n` | `s(n) = 1/(2(√n+1))` | `√n · s(n)` (must be `< 1`) |
|-----|----------------------|-----------------------------|
| 1   | 0.25000              | 0.25000                     |
| 4   | 0.16667              | 0.33333                     |
| 16  | 0.10000              | 0.40000                     |
| 100 | 0.04545              | 0.45455                     |
| 10⁴ | 0.00495              | 0.49505                     |

The product increases to the limit `r/2 = 0.5` and never reaches it, which is the
numerical content of `AlephOneHausdorff.le_dimH_ball`: arbitrarily high finite
dimensions fit inside *every* ball, but the witnesses shrink like `r/(2√n)`.

* *"A set of transfinite dimension must be topologically large."*  Refuted: the
  surface is σ-compact and its closure is the compact Hilbert box, which by Riesz has
  empty interior — so the surface is nowhere dense and meagre
  (`AlephOneHausdorff.isMeagre_alephSurface`), while every ball has dimension `⊤`.
