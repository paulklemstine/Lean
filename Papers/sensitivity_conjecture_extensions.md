# Computational Evidence — Huang's signed adjacency matrices `Aₙ`

Recursive definition (Huang 2019):

```
A₀ = (0)              (the 1×1 zero matrix)
A_{n+1} = ⎡ Aₙ   I ⎤
          ⎣ I   -Aₙ⎦
```

`Aₙ` is a `2ⁿ × 2ⁿ` matrix whose nonzero entries are `±1`, supported exactly on the
edges of the `n`-cube `Qₙ` (it is a *signed* hypercube adjacency matrix).

## 1. Small cases of the spectral identity `Aₙ² = n·I`

**n = 1.**
```
A₁ = ⎡0 1⎤     A₁² = ⎡1 0⎤ = 1·I   ✓
     ⎣1 0⎦           ⎣0 1⎦
```

**n = 2.**
```
     ⎡ 0  1 | 1  0⎤
     ⎢ 1  0 | 0  1⎥
A₂ = ⎢-----+-----⎥
     ⎢ 1  0 | 0 -1⎥
     ⎣ 0  1 |-1  0⎦
```
Direct multiplication gives `A₂² = 2·I` (each diagonal entry `= 0²+1²+1²+0² = 2`,
off-diagonal entries cancel).  ✓

**n = 3.** `A₃` is `8×8`; `A₃² = 3·I` (checked by the block recursion:
top-left block `= A₂² + I = 2I + I = 3I`, etc.).  ✓

These confirm the induction step used in `Asign_sq`: the diagonal blocks become
`nI + I = (n+1)I` and the off-diagonal blocks are `Aₙ − Aₙ = 0`.

## 2. Trace and eigenvalue balance

`trace Aₙ = 0` for all `n` (verified: `trace A₁ = 0`, `trace A₂ = 0`).  Combined with
`Aₙ² = nI`, the eigenvalues are `±√n`, and zero trace forces them to occur with **equal
multiplicity** `2^{n-1}`.

| n | eigenvalues | multiplicities |
|---|-------------|----------------|
| 1 | ±1         | 1, 1           |
| 2 | ±√2        | 2, 2           |
| 3 | ±√3        | 4, 4           |

## 3. Determinant check `(det Aₙ)² = n^(2ⁿ)`

| n | 2ⁿ | (det Aₙ)² = n^(2ⁿ) | det Aₙ |
|---|----|--------------------|--------|
| 1 | 2  | 1² = 1             | −1     |
| 2 | 4  | 2⁴ = 16            | ±4     |
| 3 | 8  | 3⁸ = 6561          | ±81    |

Matches `Asign_det_sq`.

## 4. Row support = degree (n-regularity)

Row `v` of `Aₙ` has exactly `n` nonzero (`±1`) entries, so `∑_w (Aₙ v w)² = n`.  This is
the `n`-regularity of `Qₙ`: each vertex has `n` neighbours (toggling one of `n`
coordinates).  Cross-checked combinatorially in `HypercubeRegularity.lean` against the
catalog `DaisyCube` model, where neighbours of `A` are `{A ∆ {i} : i ∈ Fin n}`.

## 5. Counterexample hunt

- Is `Aₙ² = nI` ever violated?  No, for `n ≤ 3` (exhaustive), and the induction proves all `n`.
- Are entries ever outside `{−1,0,1}`?  No — the recursion only ever places `Aₙ`, `I`,
  `−Aₙ` blocks.
- Could a vertex have degree ≠ n?  No — every row has exactly `n` nonzero entries.

No counterexamples found; all universal claims survived and are formalized with 0 sorries.
