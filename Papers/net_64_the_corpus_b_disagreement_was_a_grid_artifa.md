# Computational evidence — NET-64 (limited-memory / knee axis)

All numbers below were produced by `#eval` inside the project's own Lean
environment (exact rational arithmetic, printed as floats), using the
definitions that the theorems are stated about
(`Catalog/Probability/NET64ProfileTrichotomy.lean`,
`Catalog/Probability/NET64GridArtifact.lean`).  They are *evidence*, not proof;
every claim used in the paper is separately proved in Lean, sorry-free.

## 1. The measured corpus-B row and its two readings

`corpusB` is the retention curve built from the measured NET-64 fine sweep at
`ctx = 2048`, gate `0.98`.

| k | 20 | 24 | 28 | 32 |
|---|----|----|----|----|
| `corpusB k` | 0.979000 | 0.983200 | 0.985300 | 0.986200 |

* least budget clearing the gate: `24`  (`find? (gate ≤ corpusB ·) = some 24`)
* fine grid `{16,20,24,28,32}` points that pass: `[24, 28, 32]` → reading `24`
* coarse grid `{8,16,32,64}` points that pass: `[32, 64]` → reading `32`

So one curve, two readings.  This is the whole content of the verdict
*THE-CORPUS-B-DISAGREEMENT-WAS-A-GRID-ARTIFACT*, and it is proved as
`net64_two_readings_of_one_knee`.

Margins: `0.98 − 0.9790 = 0.0010` below, `0.9832 − 0.98 = 0.0032` above.  Any
corpus within `ε = 0.0009` of this curve has the same knee
(`net64_replication_margin`).

## 2. Harmonic numbers and the dyadic sandwich

The Zipf bound rests on `1 + m/2 ≤ H_{2^m} ≤ 1 + m`.  Evaluated:

| m | `1 + m/2` | `H_{2^m}` | `1 + m` |
|---|-----------|-----------|---------|
| 0 | 1.000 | 1.000000 | 1 |
| 2 | 2.000 | 2.083333 | 3 |
| 5 | 3.500 | 4.058495 | 6 |
| 8 | 5.000 | 6.124345 | 9 |
| 11 | 6.500 | 8.202079 | 12 |

Both inequalities hold at every sampled `m`, with the lower bound the tighter of
the two — which is why the proof of `zipf_knee_gt_two_pow` uses the lower bound
on the denominator and the upper bound on the numerator.

Also `H_24 = 3.775958`, `H_32 = 4.058495`, `H_2048 = 8.202079`.

## 3. Zipf profiles: retention and knee by context

Zipf retention at `ctx = 2048`: `H_k / H_2048`.

| k | 24 | 32 | 512 |
|---|----|----|-----|
| retained | 0.460366 | 0.494813 | 0.831072 |

The measured cell requires `0.9832` at `k = 24`; a Zipf profile delivers `0.46`.

Exact Zipf knee at gate `0.98` along the context ladder (search over all `k`):

| ctx | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 |
|-----|----|----|----|-----|-----|-----|------|------|
| Zipf `k*` | 15 | 30 | 59 | 115 | 227 | 447 | 882 | 1739 |

The Zipf knee is *almost linear* in the context (≈ `0.85 · ctx`), against the
measured `16 → 20 → 24`.  The proved statement is the weaker but rigorous
`32 < k*_Zipf(2048)` (`zipf_knee_2048_gt_32`) plus unboundedness for every gate
(`zipf_knee_unbounded`); the table shows the true gap is far larger than what the
crude dyadic sandwich certifies.

## 4. Truncated geometric profiles

Knee of `geomCurve n` at gate `0.98`, searched directly:

| ctx | 512 | 1024 | 2048 |
|-----|-----|------|------|
| geometric `k*` | 6 | 6 | 6 |

Context-free, as proved in `geom_knee_eq_six` for every `n ≥ 10`.

## 5. Counterexample hunt

* *Could a coarse/fine disagreement ever certify a corpus difference?*  No —
  searched constructions immediately produce curves agreeing at all coarse grid
  points with different true knees (`grid_reading_underdetermines_knee` turns the
  search into a theorem for the whole cell `(16, 32]`).
* *Is uniform closeness of two retention curves enough for equal knees?*  No; the
  `ε`-close pair with knees `1` and `N` in `margin_hypothesis_is_necessary` is an
  explicit counterexample for every `ε > 0`.
* *Is the `+4` per doubling law consistent with either classical profile family?*
  No, in both directions, per §3 and §4 — this is the trichotomy.

## 6. Sequences

The measured chain `16, 20, 24` is the arithmetic progression `4 log₂ ctx − 20`;
no OEIS lookup is meaningful for a three-term arithmetic progression, and none is
claimed.  The Zipf knee sequence `1, 2, 4, 8, 15, 30, 59, 115, 227, 447, 882,
1739` (gate `0.98`, contexts `2^m`) is a gate-dependent computation, not a
catalogued sequence; it was not matched against OEIS.

## 7. Cycle 3: exhaustive check of the sweep-capacity formula

For the capacity question of `Catalog/Probability/NET64SharpSweepCost.lean` the
small cases were checked by **exhaustive search** (brute force over all `s`-point
subsets of `[1, B]`, `B` large enough to contain every candidate, computing for
each the largest `N` it localises at ratio `r`).  The search ran inside the Lean
environment on the project's own `geoSum`, and was afterwards discarded; the
statements it suggested are separately proved, sorry-free.

Ratio `r = 2`:

| points `s` | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| `geoSum 2 s` (proved capacity) | 2 | 6 | 14 | 30 | 62 |
| brute-force maximum `N` | 2 | 6 | 14 | — | — |
| brute-force optimal grid | `{2}` | `{2, 6}` | `{2, 6, 14}` | — | — |

Ratio `r = 3`:

| points `s` | 1 | 2 | 3 |
|------------|---|---|---|
| `geoSum 3 s` | 3 | 12 | 39 |
| brute-force maximum `N` | 3 | 12 | — |
| brute-force optimal grid | `{3}` | `{3, 12}` | — |

Every searched cell agrees with `sweep_capacity_exact`, and in each searched cell
the optimum was attained *only* by the offset geometric grid `geoGrid r s` — the
evidence behind the rigidity conjecture D2′ (which is **not** proved).

Two negative checks, both now theorems:

* the conjectured cycle-2 value `r^{|G|}` is beaten by `{2, 6}`, which localises
  `[1, 6] > [1, 4]` (`D2_conjecture_false`);
* the plain geometric grid `{1, 2, 4, 8}` localises only `[1, 8]`, versus `[1, 30]`
  for `{2, 6, 14, 30}` — offsetting is worth a factor `r/(r-1) · (1 - r^{-s})`.

## 8. Cycles 4–5: rigidity, and the two-sided capacity

**Rigidity (cycle 4).**  The exhaustive search of section 7 already recorded that
in every searched cell the one-sided optimum was attained *only* by the offset
geometric grid.  That observation is now a theorem
(`Catalog/Probability/NET64SweepRigidity.lean`, `sweep_rigidity`), so the entry
"conjecture D2′" of section 7 is superseded: uniqueness holds for every `r ≥ 1`
and every point count.  The search also located the boundary of the phenomenon,
which is likewise now proved (`rigidity_is_sharp_at_capacity`): at `r = 2`,
`s = 2` the capacity `6` is attained only by `{2, 6}`, whereas one budget below
it both `{2, 6}` and `{2, 5}` localise `[1, 5]`.

**Two-sided capacity (cycle 5).**  Before proving anything, the relaxed condition

    ∀ c ∈ [1, N], ∃ g ∈ G, g ≤ r·c ∧ c ≤ r·g

was brute-forced over all `s`-point grids inside `[1, B]` at ratio `2`:

| points `s` | 1 | 2 |
|------------|---|---|
| brute-force maximum `N` | 4 | 20 |
| `geoSum (2²) s` (later proved capacity) | 4 | 20 |

The match suggested the exact formula `geoSum (r²) s = r² + r⁴ + ⋯ + r^{2s}`,
which is now proved in both directions (`twoSided_capacity_exact`), together with
uniqueness of the optimal grid (`twoSided_rigidity`) and the sandwich
`geoSum r (2s−1) < geoSum (r²) s < geoSum r (2s)`
(`twoSided_between_one_sided`).  The value `r^{2s−1}` that the previous cycle's
`future_directions.json` conjectured for this capacity is refuted by the same
data (`8 < 20` at `r = 2, s = 2`) and now by theorem
(`twoSided_conjecture_false`).

Concretely at four points and ratio `2`: the deployment-safe sweep covers
`[1, 30]` with `{2, 6, 14, 30}`, the relaxed sweep covers `[1, 340]` with
`{2, 10, 42, 170}`, and both grids are unique.

As in section 7, the brute-force searches are *evidence only*; every statement
listed above is separately proved and sorry-free.
