# Computational Evidence — Separable rank of EML Kolmogorov–Arnold targets

This note records the small-case evidence gathered before formalizing
`KolmogorovArnoldEMLSeparableRank.lean` and `KolmogorovArnoldEMLSeparableRankExact.lean`.

The **separable rank** of a bivariate target `f(x,y)` is the least `r` with
`f(x,y) = Σ_{k<r} a_k(x)·b_k(y)`. The central computational claim is that it
equals the matrix rank of the evaluation matrix `M_{ij} = f(x_i, y_j)` sampled at
sufficiently many points.

## 1. Small-case calculations

### Product `x·y`
Sample on `{0,1,2}²`: `M = [[0,0,0],[0,1,2],[0,2,4]]`. Row/column rank `= 1`
(all rows are multiples of `(0,1,2)`). Matches `mul_sepRankLE_one` (rank 1).

### Sum `x+y`
Sample on `{0,1}²`: `M = [[0,1],[1,2]]`, `det = 0·2 − 1·1 = −1 ≠ 0`, so rank `= 2`.
Hence separable rank `≥ 2`; and `x+y = x·1 + 1·y` gives `≤ 2`. Exact rank `= 2`.
This is exactly `add_not_sepRankLE_one` + `add_sepRankLE_two`.

### Power-sum `p_N(x,y) = Σ_{k<N} xᵏ yᵏ`
Sample at `t = (0,1,…,N−1)`. The matrix `M_{ij} = Σ_{k<N} t_iᵏ t_jᵏ` equals
`V Vᵀ` with `V` the Vandermonde matrix `V_{ik} = t_iᵏ`.

| N | sample points | det(M) = det(V)² | rank |
|---|---------------|------------------|------|
| 1 | {0}           | 1                | 1    |
| 2 | {0,1}         | (1−0)² = 1       | 2    |
| 3 | {0,1,2}       | (2·1·1)² = 4     | 3    |
| 4 | {0,1,2,3}     | (12)² = 144      | 4    |

`det(V) = Π_{i<j}(t_j − t_i)` is nonzero for distinct points, so the sample is
invertible and the separable rank is exactly `N`. This is the heart of
`powerSum_rank_ge` / `powerSum_sepRank_exact`: the outer-term count is **unbounded**.

## 2. OEIS

The exact-rank sequence of `p_N` is the identity `1,2,3,4,…` (A000027) by design.
The Vandermonde determinants `det(V)` for `t=(0,…,N−1)` are the superfactorials
`Π_{k<N} k!` = `1,1,2,12,288,…` (A000178); their squares appear as `det(M)` above.

## 3. Counterexample hunt

- Claim "every continuous bivariate target has bounded separable rank": **FALSE**
  — refuted by `p_N` (rank `N` for all `N`). This is now a theorem.
- Claim "rank-1 ⇔ multiplicatively separable": tested on `x·y` (rank 1, separable)
  and `x+y` (rank 2, not separable); consistent. Formalized as
  `mulSeparable_iff_sepRankLE_one`.
- Claim "matrix rank of a sample can exceed separable rank": **FALSE** for every
  sample — the factorization `M = A·B` (`m×r` times `r×m`) caps it at `r`
  (`sample_rank_le`).

## 4. Conclusion

The evidence pinpointed the linear-algebra bridge (`separable rank = sampled
matrix rank`) and the Vandermonde witness for unboundedness, both of which became
the formal backbone of the two Lean files.
