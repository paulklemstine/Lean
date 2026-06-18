# Future Directions: Tropical Spectral Theory

## 1. Tropical Eigenvalue Formula for General n×n Matrices

The 2×2 eigenvalue formula `tropEigval2(A) = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` generalizes to n×n matrices as the minimum cycle mean: `λ(A) = min_{k=1..n} tr(A^k)/k`, where `tr(A^k)` is the minimum weight length-k closed walk. Our `tropical_trace_eigval_2x2` proves this for n=2; the general case requires showing that walk enumeration through matrix powers captures all directed cycles.

The key insight is that `minPlusMul` composes shortest-path computations, so `(A^k)_{ii}` equals the minimum weight walk from i to i of length exactly k, and the infimum over diagonal entries gives the minimum over all starting vertices. Why now? The associativity proof `minPlus_mul_assoc` provides the algebraic backbone — it shows min-plus matrix powers are well-defined and composable. The next step is proving `minPlusPow_entry_eq_min_walk` by induction on k, which reduces the spectral radius formula to a combinatorial identity over the cycle space of the complete directed graph.

## 2. Tropical Cayley–Hamilton and Matrix Power Stabilization

For an n×n min-plus matrix A with no negative-weight cycles (i.e., `tropEigval(A) ≥ 0`), the Bellman–Ford theorem states that the matrix power sequence A, A², A³, ... stabilizes: A^n = A^(n-1) (after suitable normalization). This is the tropical analog of the Cayley–Hamilton theorem. The conjecture is formalizable: define the normalized power `Ã^k := A^k - k·λ(A)·I` (subtracting the eigenvalue from the diagonal) and prove `Ã^n = Ã^(n-1)` for irreducible matrices.

The key insight is that after subtracting the eigenvalue, all cycle means become non-negative, and the critical graph (cycles achieving mean zero) determines the periodicity of the power sequence. Why now? Our `minPlusMul` and `minPlusPow` definitions provide the infrastructure, and `minPlus_mul_assoc` ensures the power sequence is well-defined. The proof should proceed by showing that paths longer than n must revisit a vertex, and non-negative cycle means ensure the shortest path length stabilizes.

## 3. Tropical Eigenvector Uniqueness and the Critical Graph

For a 2×2 matrix, we exhibited three cases for the eigenvector (cycle case, diag0 case, diag1 case). In general, the eigenvector is unique up to tropical scalar multiplication (adding a constant to all entries) if and only if the critical graph — the subgraph consisting of edges participating in minimum-mean cycles — is strongly connected. The conjecture: formalize the critical graph for n×n matrices and prove that strong connectivity of the critical graph implies the tropical eigenspace has "dimension 1" (i.e., all eigenvectors differ by a tropical scalar).

The key insight is that tropical eigenspaces are classical convex cones, and their dimension equals the number of strongly connected components of the critical graph. Why now? The explicit eigenvector constructions in our three case theorems reveal the pattern: when the 2-cycle (0→1→0) is critical, the eigenvector has a specific off-diagonal structure; when a 1-cycle (self-loop) is critical, the eigenvector has a simpler structure. Generalizing this to track which cycles are critical would yield the full classification.

## 4. Tropical Perron–Frobenius Theorem

The classical Perron–Frobenius theorem states that an irreducible non-negative matrix has a unique maximal eigenvalue with a positive eigenvector. The tropical analog: for an irreducible min-plus matrix (the associated digraph is strongly connected), the tropical eigenvalue `λ = min_{k=1..n} tr(A^k)/k` is achieved by a unique eigenvector up to tropical scaling, and this eigenvector has all finite entries. Our `tropical_eigval_2x2_witness` proves existence for n=2; irreducibility (strong connectivity of the 2-vertex digraph with finite entries) should imply the eigenvector entries are all finite.

The key insight is that irreducibility in the tropical setting means every pair of vertices is connected by a finite-weight path, which forces the eigenvector equation `min_j(A_{ij} + x_j) = λ + x_i` to have a unique solution (up to additive constants) by a contraction mapping argument on the tropical projective space. Why now? The infrastructure of `IsTropicalEigenpair` and the case analysis framework scales naturally to larger matrices. The next concrete step is defining irreducibility (`∀ i j, ∃ k, minPlusPow A k i j < ⊤`) and proving the eigenvector has no infinite entries.

## 5. Tropical Determinant and Optimal Assignment

The tropical determinant of an n×n matrix is `tdet(A) = min_{σ ∈ Sₙ} Σᵢ A_{i,σ(i)}`, which is exactly the optimal assignment (Hungarian algorithm) cost. The conjecture: `tdet(A·B) = tdet(A) + tdet(B)` (the tropical determinant is multiplicative, where tropical multiplication of scalars is ordinary addition). This is a non-trivial combinatorial identity relating optimal assignments in a product to the sum of individual optimal assignments.

The key insight is that the minimum over permutations of a sum can be decomposed using the associativity of min-plus multiplication (`minPlus_mul_assoc`): the (σ,τ)-term of the product determinant telescopes through intermediate vertices. Why now? Our formalization of `minPlusMul` and its associativity provides the exact framework. The proof should use `Finset.inf'` over `Equiv.Perm (Fin n)` and the fact that composing two permutations through intermediate sums gives back the full permutation sum — essentially a tropical Cauchy–Binet identity.
