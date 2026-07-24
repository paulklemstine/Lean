# Computational Evidence: fixed-amplitude complex-weighted undirected graphs

This note records the small-case checks that motivated the deepened spectral results
for the fixed-amplitude model, in which every present edge of an undirected graph
carries one common complex weight `z`, so the weighted adjacency matrix is `z · B`
with `B` the real symmetric zero-one indicator of the edge relation.

## 1. Spectrum lies on a single complex line

Because `B` is real symmetric, its eigenvalues `μ₁, …, μₙ` are real, and the
eigenvalues of `z · B` are exactly `z·μ₁, …, z·μₙ`.  All of them lie on the line
`ℝ·z` through the origin.  Sample checks (paths, cycles, complete graphs):

| graph      | eigenvalues of `B`                  | eigenvalues of `z·B`         |
|------------|-------------------------------------|------------------------------|
| `P₃` (path)| `-√2, 0, √2`                        | `-√2 z, 0, √2 z`             |
| `C₄` (cycle)| `2, 0, 0, -2`                      | `2z, 0, 0, -2z`              |
| `K₄`       | `3, -1, -1, -1`                     | `3z, -z, -z, -z`             |

Every listed value is a real multiple of `z`; nothing fills a two-dimensional
region.  This is the exact opposite of the circular-law heuristic and is the content
of the line-locking theorem.

## 2. The complete-graph outlier vs. the √n heuristic

For `Kₙ` the all-ones vector is an eigenvector with eigenvalue `(n-1)z`.  Comparing
its modulus `(n-1)‖z‖` to the naive radius `√n·‖z‖`:

| n | n-1 | √n ≈ | (n-1) > √n ? |
|---|-----|------|--------------|
| 2 | 1   | 1.41 | no           |
| 3 | 2   | 1.73 | yes          |
| 4 | 3   | 2.00 | yes          |
| 5 | 4   | 2.24 | yes          |

The strict inequality `(n-1) > √n` is equivalent to `n² - 3n + 1 > 0`, which holds
for all `n ≥ 3` and fails at `n = 2`.  Thus the mean-direction eigenvalue escapes the
`√n` disk from `n = 3` onward; the four-vertex example in the base development is
representative, not an artifact of small order.

## 3. Reality of the Rayleigh quotient (sanity checks)

For a Hermitian `A` and any nonzero `v`, the quotient `⟨v, A v⟩` was checked to be
real on random `2×2` and `3×3` Hermitian samples (imaginary parts vanish to machine
precision), consistent with the exact identity `⟨v, A v⟩ = ⟨A v, v⟩`.  This underlies
the proof that abstract eigenvalues of a Hermitian matrix are real, which in turn
forces `λ/z ∈ ℝ` for every eigenvalue `λ` of `z·B`.

## Counterexample hunt

No counterexample to line-locking was found for symmetric edge relations, as
expected.  Breaking symmetry (directed edges, `B ≠ Bᵀ`) or using per-edge independent
phases destroys the scalar-Hermitian factorization and does allow genuinely
two-dimensional spectra — this is precisely the boundary recorded in the
future-directions note.
