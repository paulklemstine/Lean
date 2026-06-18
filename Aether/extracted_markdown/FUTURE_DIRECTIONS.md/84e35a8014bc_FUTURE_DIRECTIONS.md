# Future Directions — Reduced Laplacians, Critical Groups & the Kirchhoff Bridge

These notes seed the next research cycle building on
`Catalog/Pythagorean/TropicalBridge/NeronComponent/CriticalGroup.lean`.

## Synthesis

This cycle replaced an orphaned, non-compiling bridge file (whose `Defs.lean`
dependency was entirely absent) with a **self-contained, fully-proved algebraic
core** for the tropical-Jacobian / Néron-component-group correspondence. The
central object is the *reduced graph Laplacian* `L_red` — delete one row and
column of a symmetric, zero-row-sum, nonpositive-off-diagonal integer matrix.
We proved its structural backbone (symmetry, zero column sums, constants in the
kernel), its analytic backbone (positive semidefiniteness ⇒ `det L_red ≥ 0`),
and — the conceptual payoff — that the *critical group* (the cokernel of the
matrix, a.k.a. tropical Jacobian / sandpile / Néron component group) has order
exactly `|det|` in the rank-one case, realized end-to-end on the genus-2 theta
graph as `ZMod 3`.

The structural insight that emerged is that the entire bridge factors through
**two independent pillars**: an *order-theoretic* pillar (PSD over ℝ, forcing
nonnegativity of the determinant — this genuinely needs the detour through ℝ,
since there is no PSD order theory over ℤ) and a *lattice-quotient* pillar (the
cokernel `(V→ℤ)/im(L)` as a finite abelian group, where the determinant
reappears as the index of a sublattice). The rank-one case already exposes the
clean mechanism: identify the image lattice `d·ℤ` inside `ℤ`, then quote
`Int.quotientZMultiplesEquivZMod`. The general case is "just" the Smith-normal-
form upgrade of this single move.

What failed / was deliberately deferred: the *general* `|coker| = |det|` and the
*vertex-independence* of the cokernel (Theorem 1/2 in the legacy `Theorems.lean`)
were not attempted as proofs this cycle because they require either a Smith
normal form development over ℤ or the all-minors matrix-tree theorem. We instead
nailed the rank-one anchor and the PSD determinant bound, which are the load-
bearing lemmas every higher result will call. The legacy `Theorems.lean` remains
broken (missing `Defs.lean`); our file is intended as its compiling replacement.

## Results Summary

- `reducedLaplacian_transpose`: proved — the reduced Laplacian of a symmetric matrix is symmetric (well-definedness of the construction).
- `colSum_zero_of_isSymm_rowSum_zero`: proved — symmetry promotes zero row sums to zero column sums (needed for the PSD quadratic-form identity).
- `laplacian_mulVec_const`: proved — constant vectors lie in the kernel, so the cokernel sees only degree-zero data (the divisor-class picture).
- `reducedLaplacian_det_nonneg`: proved — `det L_red ≥ 0` via positive semidefiniteness of the edge-sum quadratic form; the analytic anchor of Kirchhoff.
- `cokernel_one_equiv_zmod`: proved — the critical group of `[d]` is `ZMod |d|`; the lattice-quotient anchor.
- `cokernel_one_card`: proved — `|critical group of [d]| = |det [d]| = |d|`; the Kirchhoff bridge in rank one (hypothesis `d ≠ 0` proved unnecessary).
- `cycleGraph3_det_reduced`, `completeGraph4_det_reduced`, `bananaGraph_det_reduced`, `thetaGraph_det_reduced`: proved — concrete spanning-tree counts (3, 16, n, 3).
- `thetaGraph_criticalGroup_card`: proved — the tropical Jacobian of the genus-2 theta graph has order 3, matching `det L_red`.

## Research Directions

### Direction 1: Vertex-independence of the reduced determinant (all-minors matrix-tree)
**Hypothesis**: For every symmetric integer matrix `L` with zero row sums (hence zero column sums) and any two vertices `v₁ v₂`, `det (reducedLaplacian L v₁) = det (reducedLaplacian L v₂)`.
**Test**: Prove it via the adjugate: from zero row and column sums one gets `det L = 0`, so `L * adjugate L = 0` and `adjugate L * L = 0`; deduce all entries of `adjugate L` are equal, and identify the diagonal entry `adjugate L i i` with `det (reducedLaplacian L i)`. Refute by a counterexample search over small non-symmetric or nonzero-row-sum matrices to delimit the hypotheses.
**Why now**: We already have `colSum_zero_of_isSymm_rowSum_zero` (the zero-column-sum half) and a clean `reducedLaplacian` as a `submatrix`; the missing piece is purely the adjugate bookkeeping, for which Mathlib has `Matrix.mul_adjugate` / `Matrix.adjugate_mul`. The key insight is that *equal cofactors* is exactly the statement "the deleted vertex doesn't matter," upgrading the determinant identity to a canonical isomorphism of critical groups.
**If true**: The critical group becomes a genuine *graph* invariant, independent of the grounding choice — the determinant version of legacy Theorem 1.
**If false**: The failure would pinpoint exactly which hypothesis (symmetry vs. zero sums) the canonicity rests on, sharpening the definition of "tropical Jacobian."

### Direction 2: General Kirchhoff `|coker| = |det|` via Smith normal form
**Hypothesis**: For any `A : Matrix (Fin n) (Fin n) ℤ` with `A.det ≠ 0`, `Nat.card ((Fin n → ℤ) ⧸ (LinearMap.range A.mulVecLin).toAddSubgroup) = A.det.natAbs`.
**Test**: Develop (or locate in Mathlib) Smith normal form for integer matrices: write `A = U * D * V` with `U, V ∈ GL_n(ℤ)` and `D` diagonal with entries the invariant factors `dᵢ`; then the cokernel is `⊕ᵢ ZMod |dᵢ|` and `∏ |dᵢ| = |det A|`. Our `cokernel_one_equiv_zmod` is exactly the `n = 1` base case to splice in.
**Why now**: We have proven the rank-one anchor and have the cokernel definition in place. The key insight is that the cokernel cardinality is *multiplicative across a block/diagonal decomposition*, so the whole theorem reduces to (a) invariance under `GL_n(ℤ)` change of basis and (b) the diagonal case, which iterates the rank-one lemma.
**If true**: Completes legacy Theorem 2 and turns `reducedLaplacian` into an *executable* invariant: `|Φ_J| = det L_red` for arbitrary finite graphs.
**If false** (e.g. an off-by-sign or `det = 0` edge case): It would reveal where the finiteness of the critical group actually fails (precisely when `det = 0`, i.e. disconnected graphs), clarifying the connectivity hypothesis.

### Direction 3: Smith-normal-form structure theorem for the critical group
**Hypothesis**: For any `A : Matrix (Fin n) (Fin n) ℤ` there exist `k` and invariant factors `d : Fin k → ℤ` (all nonzero) with `(Fin n → ℤ) ⧸ im A ≃+ ⊕ᵢ ZMod |dᵢ|` and `d i ∣ d (i+1)`.
**Test**: Build the isomorphism from the SNF of Direction 2, then prove the divisibility chain from the gcd characterization of invariant factors (`dᵢ = (gcd of i×i minors) / (gcd of (i−1)×(i−1) minors)`).
**Why now**: Direction 2 produces the diagonal `D`; this direction only adds the *canonical* invariant-factor normalization. The key insight is that the divisibility chain is what makes the decomposition canonical (independent of `U, V`), which is the algebraic shadow of vertex-independence (Direction 1).
**If true**: Gives the full classification (legacy Theorem 3) and a decision procedure for *isomorphism* of two critical groups, not merely equal order.
**If false**: A breakdown would localize to the minors-gcd computation, exposing which graphs have "non-cyclic" Jacobians.

### Direction 4: Baker–Norine divisor model and chip-firing
**Hypothesis**: The cokernel `(V→ℤ)/im(L)` restricted to degree-zero classes is isomorphic to `Div⁰(Γ)/Prin(Γ)` (degree-zero divisors modulo principal divisors), and chip-firing moves generate exactly `im(L)`.
**Test**: Define `Div(Γ) := V → ℤ`, `degree := ∑`, `Prin(Γ) := im(L)`; prove `laplacian_mulVec_const`-style that principal divisors have degree zero (already have the kernel half), then exhibit the degree-zero quotient as the critical group. Cross-link to `ChipFiringCorrespondence.lean` in the same folder, which already defines `chipFire` and `principalDivisor`.
**Why now**: `laplacian_mulVec_const` plus the sibling `ChipFiringCorrespondence.lean` (which proves `chipFire_eq_laplacian_action` and `principalDivisor_degree_zero`) provide both ends of the bridge. The key insight is that "constants in the kernel" is precisely the statement that the *grounding* of the reduced Laplacian is the choice of a basepoint divisor — connecting our Section 2 lemmas to the combinatorial Baker–Norine theory already in the catalog.
**If true**: Unifies the linear-algebra (cokernel) and combinatorial (chip-firing) presentations of the tropical Jacobian into one verified pipeline.
**If false**: Would expose a degree/normalization mismatch between the two catalog formalizations, a valuable correction for downstream files.

### Direction 5: Cokernel of a diagonal/block matrix as a product of `ZMod`
**Hypothesis**: For `D` diagonal with entries `d : Fin n → ℤ`, `(Fin n → ℤ) ⧸ im D ≃+ ⊕ᵢ ZMod |dᵢ|`, and hence `Nat.card = ∏ᵢ |dᵢ|` when all `dᵢ ≠ 0`.
**Test**: Iterate `cokernel_one_equiv_zmod` across coordinates using `QuotientAddGroup` of a `Pi` type; this is a strict, low-risk generalization of the rank-one lemma and a direct stepping stone to Direction 2.
**Why now**: It is the smallest non-trivial extension of what we already proved and isolates the "multiplicativity" mechanism away from the harder `GL_n(ℤ)` invariance. The key insight is that the cokernel functor turns *direct sums of matrices into direct sums of groups*, so the diagonal case is pure bookkeeping over the proven rank-one anchor.
**If true**: Supplies the diagonal half of Smith normal form for free, de-risking Direction 2.
**If false**: A failure here (e.g. a `Pi`-quotient vs. `⊕` subtlety) would be a pure formalization lesson about how Mathlib models finite product quotients.
