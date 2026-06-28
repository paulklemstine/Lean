# Computational Evidence — Inverse Sprugnoli/Riordan Array

All evidence below was produced with Lean `#eval` over exact `ℤ`/`ℚ` arithmetic before
formalisation. It supports the results in `Catalog/Novelty/InverseSprugnoliArray.lean`.

## 1. The array and its numeric inverse

`T_{n,k} = C(n+k, 2k)` (OEIS **A085478**), lower-triangular unipotent:

```
row0: 1
row1: 1 1
row2: 1 3 1
row3: 1 6 5 1
row4: 1 10 15 7 1
```

Inverting `T` row-by-row (`S_{n,k} = δ - Σ_{k≤j<n} T_{n,j} S_{j,k}`) gives `S = T⁻¹`:

```
row0:  1
row1: -1   1
row2:  2  -3   1
row3: -5   9  -5   1
row4: 14 -28  20  -7   1
row5:-42  90 -75  35  -9   1
```

* Column 0: `1, -1, 2, -5, 14, -42 = (-1)^n · Catalan(n)`.
* Subdiagonal `S_{n,n-1}`: `-1, -3, -5, -7, -9 = -(2n-1)`.

## 2. Closed form (curve fit, then exact check)

Both forms matched `S` exactly for all `n,k ≤ 8`:

* rational: `S_{n,k} = (-1)^{n+k} · (2k+1)/(n+k+1) · C(2n, n-k)`;
* integer : `S_{n,k} = (-1)^{n+k} · ( C(2n, n-k) − C(2n, n-k-1) )`  (signed ballot / Catalan
  triangle, OEIS **A053121**).

The integer form needs guards against truncated `ℕ` subtraction: `n-k-1` at `k = n`, and
triangularity `n < k ⇒ S = 0`. The guarded definition is the one formalised.

## 3. Orthogonality (the "inverse array" claim)

Both `T·S = I` and `S·T = I` verified for all `n,k ≤ 8`:
`Σ_j T_{n,j} S_{j,k} = [n=k]` and `Σ_j S_{n,j} T_{j,k} = [n=k]`.

## 4. The crux identity

After trinomial revision the orthogonality sum collapses to one Vandermonde identity,
checked for all `p,m ≤ 8` (holds with **no** side condition):

`Σ_{i=0}^{m} (-1)^i C(p+i, i) C(p, m-i) = (-1)^m`  (OEIS **A033999**, the sign sequence).

## 5. Row-sum spin-offs (cycle 2)

* plain row sums of `S`: `1, 0, 0, 0, …` `= [n=0]` (checked n ≤ 11);
* alternating row sums: `1, -2, 6, -20, 70, -252, … = (-1)^n C(2n, n)` (OEIS **A000984**
  with sign), checked n ≤ 11.

## 6. Counterexample hunt

No counterexamples were found to any claim above within the tested ranges. The single
near-miss was the unguarded integer form failing at the diagonal/`k=n` boundary, which is
a `ℕ`-subtraction artefact, not a mathematical failure — resolved by the guards.
