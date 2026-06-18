# Future Directions: Sparse Matrix Structure Preservation

## Synthesis

The row-sparsity budget theorem opens a program of **quantitative rewrite semantics**: assigning computable structural invariants to symbolic expressions and proving their preservation under algebraic transformation. Row sparsity is the first invariant in this program. The directions below extend along two axes: (1) richer structural invariants (bandwidth, block sparsity, hierarchical structure) and (2) richer algebraic calculi (matrix multiplication, tensor contractions, nonlinear operations). Together, these axes converge on a vision of *certified structural compilation* for scientific computing, where every optimization pass carries a machine-verified certificate that the output preserves the locality, sparsity, and hierarchical structure of the input. The cross-domain bridges—to graph theory, PDE discretization, quantum simulation, and probabilistic combinatorics—ensure that the formal results translate into impact across computational science.

---

## Direction 1: Bandwidth-Aware Rewrite Budgets

**Conjecture.** There exists a syntactic quantity `bandwidthBudget : TTerm .mat → ℕ` such that if all matrix variables have bandwidth ≤ b, then evalMat(t) has bandwidth ≤ bandwidthBudget(t) · b. The bandwidth budget is preserved by the distributive rewrite rules.

**Test.** Define bandwidthBudget identically to matLeafCount (since addition of banded matrices can only widen the band, and scalar multiplication preserves it). Generate 10,000 random banded matrices with bandwidth 5 and random terms of depth 4. Verify that the observed bandwidth never exceeds bandwidthBudget(t) · b. Refine the budget if the bound is not tight.

**Impact.** Bandwidth bounds directly control the cost of banded solvers (O(n · b²) for Cholesky). A certified bandwidth budget enables provably optimal memory allocation for banded storage formats and guarantees asymptotic solver performance.

**Catalog References.** `Catalog/Pythagorean/SparseMatrixStructure.lean` — Theorem 3 (evalMat_rowSparse_bound), Theorem 4 (rewrite_preserves_matLeafCount).

**Proof Strategy.** Define bandwidth as max{|i - j| : A[i,j] ≠ 0}. Prove that bandwidth(A + B) ≤ max(bandwidth(A), bandwidth(B)) (not sum!), which is tighter than the row-sparsity analog. The budget should be max over leaves rather than sum. Use induction on TTerm .mat with the max lemma.

**Domain Bridges.** PDE discretization (banded matrices from finite differences), signal processing (Toeplitz structure), quantum chemistry (localized orbitals).

**Lineage.** Extends the row-sparsity framework of Direction 3 to a complementary structural invariant.

**Ambition.** Solid extension — the proof strategy is clear and the bound is likely tight.

---

## Direction 2: Support Intersection and Matrix-Matrix Multiplication

**Conjecture.** For a calculus extended with matrix-matrix multiplication, there exists a function `fillBudget : TTerm .mat → ℕ² → ℕ` such that if all matrix variables are row-s-sparse and column-t-sparse, then evalMat(t) is row-fillBudget(t, (s,t))-sparse. The fill budget satisfies fillBudget(mulMat A B, (s,t)) ≤ s · t.

**Test.** Implement matrix-matrix multiplication in the AST. Generate random s-row-sparse, t-column-sparse matrices and verify the bound on 5,000 random terms of depth 3. Check whether s · t is tight or whether a subquadratic bound holds in practice.

**Impact.** This is the hard case for sparsity analysis. Matrix-matrix multiplication is the primary source of fill-in in sparse computation (e.g., Gaussian elimination, Schur complement computation). A certified fill budget would directly impact sparse direct solver verification and tensor compiler optimization.

**Catalog References.** `Catalog/Pythagorean/SparseMatrixStructure.lean` — all theorems (as the starting point for the extension).

**Proof Strategy.** The key insight is that (AB)[i,j] = Σ_k A[i,k] · B[k,j], so row support of AB at row i is the union of column supports of B over k ∈ rowSupport(A, i). This gives |rowSupport(AB, i)| ≤ |rowSupport(A, i)| · max_k |colSupport(B, k)|. Define column sparsity symmetrically and track both row and column sparsity through the term.

**Domain Bridges.** Sparse direct solvers (fill-in prediction), database query optimization (join selectivity), tensor network contraction (bond dimension growth).

**Lineage.** Grand challenge extension of the current framework to the most important missing operation.

**Ambition.** Grand challenge — the interaction between row and column sparsity under multiplication is fundamentally harder than the additive case.

---

## Direction 3: Probabilistic Support Growth and Collision Analysis

**Conjecture.** For random row-s-sparse matrices with entries drawn uniformly from {1, ..., n}, the expected maximum row support of the sum of k independent matrices is Θ(min(n, k·s · (1 - (1-1/n)^{ks}))), exhibiting a coupon-collector transition from linear growth to saturation.

**Test.** Generate 10,000 instances with n = 100, s = 5, k ranging from 1 to 50. For each k, compute the average and maximum observed row support. Fit the coupon-collector model and measure the L² error between predicted and observed curves. The conjecture fails if the error exceeds 5%.

**Impact.** Average-case bounds complement worst-case bounds for practical applications. In many scientific computing settings, matrix sparsity patterns are "random enough" that the worst-case bound is overly conservative. A probabilistic bound enables tighter memory allocation and better performance prediction.

**Catalog References.** `Catalog/Pythagorean/SparseMatrixStructure.lean` — Theorem 1 (RowSparse.add), Theorem 6 (rowSupport_add_eq_of_disjoint).

**Proof Strategy.** The key insight is that column indices of independent sparse matrices act like balls thrown into n bins. The expected number of distinct columns occupied after k·s throws is n · (1 - (1-1/n)^{ks}), which transitions from ≈ks (for ks ≪ n) to ≈n (for ks ≫ n). Formalize using the birthday paradox / coupon collector framework. The hard part is making this rigorous for non-uniform distributions.

**Domain Bridges.** Random graph theory (Erdős-Rényi degree distributions), hashing (collision analysis), communication complexity (message passing on random graphs).

**Lineage.** Bridges the formal worst-case analysis to probabilistic combinatorics, creating a new interface between symbolic algebra and random models.

**Ambition.** Grand challenge — requires new formalization of probabilistic combinatorics in Lean.

---

## Direction 4: Block Sparsity and Hierarchical Matrices

**Conjecture.** For a block-partitioned matrix with block size b, define block-row-sparsity as the number of nonzero blocks per block-row. There exists a syntactic budget `blockLeafCount` such that evalMat(t) has block-row-sparsity ≤ blockLeafCount(t) · s_block, where s_block is the base block-row-sparsity.

**Test.** Partition 100×100 matrices into 10×10 blocks. Generate random block-sparse matrices with at most 3 nonzero blocks per block-row. Verify the budget on 1,000 random terms of depth 3.

**Impact.** Block sparsity is the native structure of domain decomposition methods, block Jacobi preconditioners, and hierarchical matrices (H-matrices). A certified block-sparsity budget enables verified compilation for hierarchical linear algebra libraries.

**Catalog References.** `Catalog/Pythagorean/SparseMatrixStructure.lean` — Theorem 3 (structural recursion pattern), Definition of matLeafCount.

**Proof Strategy.** The key insight is that block sparsity is isomorphic to scalar sparsity at a coarser granularity. Define RowSparse at the block level and apply the existing theorem structure. The main technical challenge is handling the interaction between block boundaries and the addition/scalar multiplication operations.

**Domain Bridges.** Domain decomposition (block structure from mesh partitioning), hierarchical matrices (H/H²-matrices), multigrid methods (level-dependent block structure).

**Lineage.** Direct generalization of scalar row-sparsity to block row-sparsity.

**Ambition.** Solid extension — the proof architecture directly transfers.

---

## Direction 5: Certified Sparse Compilation for Tensor DSLs

**Conjecture.** The row-sparsity budget can be implemented as a static analysis pass in a tensor algebra DSL (e.g., an MLIR dialect), providing compile-time guarantees on output sparsity and enabling verified CSR storage pre-allocation.

**Test.** Implement a prototype MLIR pass that: (1) computes matLeafCount for each matrix-valued intermediate, (2) propagates sparsity bounds through the computation graph, (3) inserts verified allocation bounds for CSR output buffers. Measure the gap between predicted and actual allocation on 10 benchmark sparse linear algebra kernels (SpMV, SpMM, SDDMM).

**Impact.** This bridges formal mathematics to systems engineering. Verified sparsity bounds eliminate a class of runtime buffer overflow bugs in sparse computation and enable aggressive memory optimization without sacrificing correctness.

**Catalog References.** `Catalog/Pythagorean/SparseMatrixStructure.lean` — Theorem 5 (normalize_rowSparse_bound), all supporting infrastructure.

**Proof Strategy.** The key insight is that the leaf count is a *compositional static analysis*: it can be computed bottom-up in a single pass over the computation graph, with constant cost per node. The verification reduces to showing that the MLIR pass correctly implements matLeafCount and that the CSR allocation uses the predicted bound.

**Domain Bridges.** Compiler verification (certified optimization passes), high-performance computing (memory management), database query optimization (cardinality estimation for joins).

**Lineage.** Applied engineering realization of the formal mathematical framework.

**Ambition.** Solid extension with high practical impact — the mathematics is done, the engineering is the remaining challenge.
