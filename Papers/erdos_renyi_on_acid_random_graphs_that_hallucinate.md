# Computational Evidence

## Small-case calculations

For the loopless complete undirected graph on `n` vertices, the indicator adjacency matrix is `J-I`. Its all-ones eigenvector has eigenvalue `n-1`, and every vector whose coordinates sum to zero has eigenvalue `-1`. Multiplication by a fixed complex amplitude `z` therefore gives the spectrum

| size | weighted spectrum |
|---:|:---|
| 2 | `z, -z` |
| 3 | `2z, -z, -z` |
| 4 | `3z, -z, -z, -z` |
| 5 | `4z, -z, -z, -z, -z` |

All eigenvalues lie on the single line `zℝ`, not throughout a disk. At `n = 4`, the eigenvalue `3z` has modulus `3|z|`, exceeding the proposed radius `√4|z| = 2|z|` whenever `z ≠ 0`.

## Counterexample hunt

The universal disk claim fails deterministically for complete loopless realizations once `n ≥ 4`, because `(n-1)|z| > √n|z|`. More fundamentally, every undirected realization has a real symmetric zero-one indicator matrix `B`, and its weighted matrix is exactly `zB`. Thus every transported eigenvalue is a real eigenvalue of `B` multiplied by `z`; no realization can have rotationally distributed eigenvalues unless the scalar phase itself is randomized between realizations.

The claimed i.i.d. entry hypothesis also fails: undirected adjacency imposes `Aᵢⱼ = Aⱼᵢ`. Moreover, an uncentered Bernoulli matrix has a nonzero mean component, so even a directed replacement generally has an eigenvalue on scale `n`, not `√n`.

## Numerical parameter check

For `z = 0.5 + 0.3i`, `|z| = √0.34 ≈ 0.583095`. At `n = 1000`, the proposed radius is approximately `18.44`, whereas the mean-direction scale in a dense uncentered model is approximately `583.10 p`. For example, at `p = 1/2` this is about `291.55`, far outside the proposed disk. This numerical comparison is explanatory only; the exact structural and four-vertex counterexamples are established by the accompanying theorems.

## OEIS search

No OEIS search is applicable: the decisive objects are matrix spectra and norm inequalities rather than a newly observed integer sequence.

## Plot interpretation

A plot of the original undirected model should show points on a rotated line through the origin. A two-dimensional disk becomes a meaningful prediction only for an independently sampled directed model after subtracting its entrywise mean and applying variance normalization.
