# Computational Evidence — Balla's conjecture for `α = 1/3`

Target: `N_{1/3}(d) ≤ max{28, 2(d − 1)}`, where `N_{1/3}(d)` is the maximum number
of equiangular lines in `ℝ^d` with common angle `arccos(1/3)`.

## 1. The bound `max{28, 2(d−1)}` across dimensions

| `d` | `2(d−1)` | `max{28, 2(d−1)}` |
|----:|---------:|------------------:|
| 2   | 2        | 28                |
| 7   | 12       | 28                |
| 14  | 26       | 28                |
| 15  | 28       | 28                |
| 16  | 30       | 30                |
| 100 | 198      | 198               |

Reading: the constant `28` dominates for `d ≤ 15`; from `d ≥ 15` the linear term
`2(d − 1)` takes over, the switch point being `2(d − 1) = 28`, i.e. `d = 15`.
Lemmens–Seidel (1973) established `N_{1/3}(d) = 2(d−1)` for all `d ≥ 15` and
`N_{1/3}(d) = 28` for `7 ≤ d ≤ 14`; the value `28` is attained already at `d = 7`.

## 2. The two constants, structurally

* `28 = 7 · 8 / 2 = C(8, 2)` is **Gerzon's absolute bound** `d(d+1)/2` evaluated at
  `d = 7`. A set of `28` equiangular `1/3`-lines exists in `ℝ^7` (related to the
  `E_7`/`576`-cell and the `28` bitangents of a plane quartic). This is why our
  file proves the sharp absolute bound `m ≤ C(d+1, 2)` and specialises it to
  `m ≤ 28` at `d = 7`.
* `2(d − 1)` is the **linear (pillar) bound**: it equals `d + (d − 2)`, i.e.
  `d` plus a multiplicity `μ = d − 2` of the smallest Seidel eigenvalue `−3`.
  Our `line_count_le` proves the exact identity `m ≤ d + μ` with
  `μ = nullity(S + 3I)`.

## 3. Seidel reformulation sanity check (`α = 1/3`)

For unit vectors with `⟨vᵢ,vⱼ⟩ = ±1/3`, `G = I + (1/3) S` with `S` a `0/±1`
symmetric matrix.

* `K₂` witness: `S = [[0,1],[1,0]]`, eigenvalues `{1, −1}`; `G` eigenvalues
  `{1 + 1/3, 1 − 1/3} = {4/3, 2/3} > 0`, so `G ≻ 0` and `m = 2 ≤ d` for any `d ≥ 2`.
* Regular simplex of `4` lines in `ℝ³` (pairwise inner product `−1/3`, so
  `|⟨·,·⟩| = 1/3`): `S = I − J` (4×4), with eigenvalues `−3` (multiplicity `1`,
  the all-ones eigenvector) and `1` (multiplicity `3`). Then `S + 3I` has
  eigenvalues `0` (once) and `4` (thrice), so `nullity(S + 3I) = 1`. The bridge
  `line_count_le` gives `m = 4 ≤ d + nullity = 3 + 1 = 4` — **tight**. Note the
  smallest Seidel eigenvalue is exactly `−3 = −1/α`, saturating `S ⪰ −3I`.

Every inequality our theorems assert is consistent with these hand computations.

## 4. Counterexample hunt

No counterexample is expected: the target is a proved theorem in the literature.
Our contribution is the *linear-algebraic core* (the absolute bound `m ≤ C(d+1,2)`,
the Seidel positivity `S ⪰ −3I`, and the reduction `m ≤ d + μ`), each verified
symbolically for all `d, m` rather than sampled. The remaining gap to the full
`max{28, 2(d−1)}` bound is the multiplicity estimate `μ`, discussed in
`FUTURE_DIRECTIONS.md`.

## 5. Related integer sequences

* Gerzon's absolute bound `C(d+1, 2) = d(d+1)/2` is the triangular-number
  sequence **A000217** (`1, 3, 6, 10, 15, 21, 28, …`); the value `28` appears at
  `d = 7`, which is the source of the constant in `max{28, 2(d−1)}`.
* The eventual linear regime `2(d−1) = 2, 4, 6, …` is the even numbers **A005843**.

These two sequences — triangular numbers (absolute/spectral bound) and even numbers
(pillar/linear bound) — are exactly the two competing terms of the target.
