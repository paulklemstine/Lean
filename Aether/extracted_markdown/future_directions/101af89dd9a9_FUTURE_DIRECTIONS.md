# Future Directions: The Tropical Determinant and the Assignment Problem

The file `TropicalDeterminant.lean` formalizes the tropical (min-plus) determinant
`tropDet A = min over permutations σ of ∑ᵢ A i (σ i)` over `WithTop ℤ`, i.e. the
optimal value of the linear assignment problem. We proved: a lower-bound lemma
(`tropDet_le_permSum`), the tropical Hadamard / row-minimum bound
(`tropDet_hadamard`), submultiplicativity (`tropDet_submul`), transpose invariance
(`tropDet_transpose`), full row/column-permutation invariance
(`tropDet_row_col_perm`), and the zero-diagonal/nonnegative characterization
(`tropDet_zero_diag_eq_zero`). The directions below extend this nucleus.

## 1. The Hadamard gap and tropical rank-1 matrices

`tropDet_hadamard` proves `∑ᵢ minⱼ A i j ≤ tropDet A`; call the difference the
*Hadamard gap*. We conjecture that the gap is exactly zero precisely when `A` is a
tropical rank-1 matrix, i.e. when there exist `u v : Fin n → WithTop ℤ` with
`A i j = u i + v j` for all finite entries — equivalently, when the LP relaxation
of the assignment problem is already integral/tight at a single column-min selection.

**The key insight is** that tightness of the row-minimum bound forces a single
permutation to simultaneously realize every row minimum, which is possible without
collision exactly for the additively-separable (rank-1) matrices. **Why now?** Both
sides of the gap are already formalized (`tropDet`, `tropDet_hadamard`) and the
rank-1 form `(i,j) ↦ u i + v j` already appears in `Catalog/Tropical/Basic.lean`
(`IsTropFactorization`), so the statement can be assembled from existing pieces.

## 2. Strict multiplicativity over a supertropical / ghost layer

`tropDet_submul` is an *inequality* `tropDet (A⊗B) ≤ tropDet A + tropDet B`. In a
supertropical semiring, where each element carries a "ghost" bit recording whether a
minimum is achieved uniquely, we conjecture the inequality upgrades to an equality
`sdet (A⊗B) = sdet A + sdet B` exactly when the optimal permutations for `A` and `B`
compose without collision.

**The key insight is** that our proof of `tropDet_submul` constructs the witness
permutation `σ.trans τ` explicitly, so the gap between the two sides is the failure
of `σ` and `τ` to be jointly optimal — a quantity the ghost layer is designed to
track. **Why now?** The explicit witness in the existing proof makes the equality
condition computable; only the (small) supertropical scalar layer needs to be added.

## 3. Tropical Cauchy–Binet for rectangular cost matrices

Extend `tropDet` to the minimum-cost *partial* assignment of `k` rows of an `n × m`
matrix, and conjecture a tropical Cauchy–Binet identity: the min-cost `k`-assignment
of `A⊗B` equals the minimum, over `k`-subsets `S`, of (min-cost assignment of the
`k×|S|` block of `A`) + (min-cost assignment of the `|S|×k` block of `B`).

**The key insight is** that the single-permutation reindexing used in
`tropDet_submul` becomes a sum over intermediate index *subsets*, exactly mirroring
the classical Cauchy–Binet expansion of `det(AB)` over `k`-subsets. **Why now?** The
square case `tropDet_submul` is the `k = n = m` specialization, so the proof skeleton
(choose optimal partial assignments, reindex, recombine) is already validated.

## 4. The tropical Birkhoff polytope and its vertices

`tropDet_zero_diag_eq_zero` shows that nonnegative matrices with zero diagonal have
`tropDet = 0`, and `tropDet_row_col_perm` exhibits an `Sₙ × Sₙ` symmetry. Define the
tropical Birkhoff set `B_n = { A : entries ≥ 0, tropDet A = 0 }` and conjecture it is
closed under tropical convex combination `(c ⊙ A) ⊕ (d ⊙ B) = min(c + A, d + B)` with
`min(c,d) = 0`, and that its tropical vertices are exactly the `n!` permutation
matrices (`0` on a permutation pattern, `⊤` elsewhere).

**The key insight is** that membership `tropDet A = 0` is preserved by entrywise min
because submultiplicativity controls the determinant of combinations, while the
permutation-matrix vertices are the `tropDet_row_col_perm` orbit of the tropical
identity. **Why now?** Every ingredient — `tropDet`, the symmetry action, and the
zero-diagonal membership criterion — is now proved, so only the convexity-closure
lemma remains.

## 5. From determinant to spectrum: minimum mean cycle weight

The tropical *eigenvalue* `λ*(A) = min over cyclic permutations of (1/length)·cycle
weight` is the minimum mean cycle weight of the weighted digraph of `A`. Restricting
`permSum` from arbitrary permutations to single cycles and normalizing by length
yields `λ*`. We conjecture a spectral submultiplicativity
`λ*(A⊗B) ≤ λ*(A) + λ*(B)` and that for matrices with `tropDet A = 0` and nonnegative
entries (Direction 4) one has `λ*(A) = 0`.

**The key insight is** that a permutation decomposes into disjoint cycles, so
`permSum A σ` is the sum of cycle weights; the determinant optimum and the
mean-cycle optimum are governed by the *same* combinatorial program, and the
cycle-decomposition reindexing is the per-cycle analogue of the global reindexing in
`tropDet_submul`. **Why now?** `permSum` and its reindexing lemmas are in place, and
cycle decomposition of `Equiv.Perm` is available in Mathlib, making the restriction
from permutations to cycles a direct next step toward tropical spectral theory.
