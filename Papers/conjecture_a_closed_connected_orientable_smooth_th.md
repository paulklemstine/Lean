# Computational evidence (cycle 1, thread th_16c8d9ad)

All numbers below were produced by direct floating-point / integer computation
*before* the corresponding Lean proofs were written; each item is now backed by a
theorem in `Catalog/Shared/`.

## 1. Quantitative rigidity of almost-Hopf fibres

Setup: `p = (z,w)`, `q = (z',w')` random unit vectors of `ℂ²` (200 000 samples,
Gaussian then normalized); `hopfDist` = Euclidean distance of the Hopf images in
`ℝ³`; `fibreDist = min_{|u|=1} ‖p − u q‖ = √(2 − 2|⟪p,q⟫|)`.

| quantity | measured maximum | conjectured/proved bound |
|---|---|---|
| `fibreDist / √hopfDist` | 0.99789 | ≤ 1 (`hopf_sqrt_stability`) |
| `fibreDist / hopfDist`  | 0.70562 | ≤ 1/√2 = 0.70711 (`hopf_linear_stability`, sharp) |

The linear ratio approaches `1/√2` only near the orthogonal configuration
(`⟪p,q⟫ = 0`), which is exactly the extremal case isolated in
`hopf_linear_constant_sharp`; for nearby pairs the ratio tends to `1/2`.

Exact identity spot check (random pair):
`hopfDistSq = 0.063841892972028**46**`,
`fibreDistSq·(4 − fibreDistSq) = 0.063841892972028**44**` — agreement to machine
precision, later proved exactly in `hopfDistSq_eq_fibre_identity`.

**Conclusion drawn before formalization:** the conjectured square-root modulus is
true but *not* optimal; the true modulus is linear.

## 2. Areas of Hopf-invariant flat tori `T r`

`area(T r) = 4π² r √(1−r²)` (later proved as `area_eq`):

| `r` | area |
|---|---|
| 0.01 | 0.3948 |
| 0.10 | 3.9281 |
| 0.25 | 9.5562 |
| 0.50 | 17.0947 |
| 0.7071 (Clifford) | **19.7392 = 2π²** |
| 0.90 | 15.4874 |

The Clifford value is the *largest*, and the areas tend to `0` as `r → 0`.  This
is a counterexample hunt that succeeded: the conjectured minimality fails, and
the corrected statement (unique maximality) is what got formalized
(`clifford_unique_maximizer`, `not_cliffordMinimizesArea`).

## 3. Metabolizers of cyclic linking forms

Brute-force search over all subgroups of `ℤ/n` for a self-annihilating subgroup
of the linking form `ℓ(x,y) = x y / n`, `1 ≤ n ≤ 20`:

```
n :  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
     Y  -  -  Y  -  -  -  -  Y  -  -  -  -  -  -  Y  -  -  -  -
```

Metabolizers occur exactly at `n ∈ {1, 4, 9, 16}` — the perfect squares (OEIS
A000290: 0, 1, 4, 9, 16, 25, …).  This is precisely the content of
`exists_metabolizer_iff_isSquare`.  No counterexample was found in the range
tested, and the proof shows none exists.
