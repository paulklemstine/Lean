# Future Directions: Spectral Embedding and Lorentzian Geometry

## Synthesis

The spectral embedding construction $A \mapsto P_A(t, x) = t^2 \cdot Q_A(x)$ reveals that Lorentzian polynomial geometry serves as a *universal language for matrix inertia*. This opens a two-way bridge: matrix spectral problems can be studied through polynomial techniques, and polynomial recognition questions gain new hardness sources from spectral theory. The five directions below explore this bridge in complementary ways — from extending the basic construction to higher inertia indices and tensors, through sparse combinatorial optimization, to deep connections with quantum information and relativistic geometry. Each direction is designed to be independently testable while contributing to a unified vision: **the Lorentzian cone as the natural geometric home for spectral constraints.**

---

## Direction 1: Higher Inertia Indices via Iterated Spectral Embedding

**Conjecture:** For each $k \geq 1$ and $n \geq k$, there exists an explicit homogeneous polynomial $P_A^{(k)}$ of degree $2k+2$ in $n + k$ variables such that all degree-2 leaves of $P_A^{(k)}$ have Lorentzian-signature Hessian if and only if $A$ has at most $k$ positive eigenvalues.

**Test:** For $k = 2$, construct a degree-6 polynomial $P_A^{(2)}(t_1, t_2, x_1, \ldots, x_n) = t_1^2 t_2^2 \cdot Q_A(x)$ and verify computationally on random $5 \times 5$ matrices whether the leaf conditions detect "at most 2 positive eigenvalues." Run 10,000 random trials; a single counterexample falsifies.

**Impact:** This would give a complete polynomial hierarchy for matrix inertia constraints, connecting Lorentzian geometry to the full lattice of inertia cones used in semidefinite optimization.

**Catalog References:** `Bridges/LorentzianRecognition.lean` (Hessian leaf infrastructure), `Bridges/SpectralEmbeddingLorentzian.lean` (base case $k=1$).

**Proof Strategy:** The key insight is that each additional auxiliary variable $t_j$ introduces one more "free" positive direction in the leaf Hessian, so $k$ auxiliary variables allow $k$ positive eigenvalues to pass through while blocking the $(k+1)$-th. Prove by induction on $k$, reducing to the $k=1$ case via iterated block extension.

**Domain Bridges:** Semidefinite programming (rank-$k$ constraints), algebraic geometry (determinantal varieties), complexity theory (higher-rank matrix problems).

**Lineage:** Direct extension of `spectral_embed` construction; builds on `blockZeroExtend_atMostOne_iff`.

**Ambition:** Grand challenge — requires new theory of "multi-Lorentzian" polynomials.

---

## Direction 2: Tensor Spectral Embedding

**Conjecture:** For a symmetric tensor $T \in \mathrm{Sym}^3(\mathbb{R}^n)$, there exists a homogeneous polynomial $P_T$ such that the Lorentzian leaf conditions on $P_T$ detect whether the associated cubic form has a "Lorentzian-type" signature (at most one positive direction in every hyperplane section's Hessian).

**Test:** Implement the construction for $3 \times 3 \times 3$ symmetric tensors. Generate 1,000 random tensors, compute the leaf conditions, and compare with direct cubic form analysis. Search for a clean signature condition that the Lorentzian leaves characterize.

**Impact:** This would extend spectral embedding from linear algebra to multilinear algebra, connecting Lorentzian polynomials to tensor decomposition, algebraic complexity, and quantum entanglement measures.

**Catalog References:** `Bridges/SpectralEmbeddingLorentzian.lean` (matrix case), `Pythagorean/LorentzianHardness.lean` (leaf counting for arbitrary degree).

**Proof Strategy:** The key insight is that for cubic forms, "Lorentzian signature" should be reformulated as: every hyperplane section of the form has a Hessian with at most one positive eigenvalue. The embedding $P_T(t, x) = t \cdot C_T(x)$ (degree $1 + 3 = 4$) makes the Hessian of the $\partial/\partial t$ leaf equal to the Hessian of $C_T$. **Why now?** The matrix case is proved, providing the template; tensor Hessians are matrices and fall under the existing theory.

**Domain Bridges:** Quantum information (multipartite entanglement), algebraic complexity (tensor rank), geometric measure theory (curvature of algebraic varieties).

**Lineage:** Generalization from order-2 tensors (matrices) to order-3.

**Ambition:** Grand challenge — tensor eigenvalue theory is far less developed than matrix theory.

---

## Direction 3: Sparse Universal Spectral Templates

**Conjecture:** There exists a universal quartic template $\mathcal{T}$ with only $O(n^2)$ monomials such that $\mathcal{T}(A)$ is Lorentzian if and only if $A$ has at most one positive eigenvalue, and the template has support contained in a fixed combinatorial structure independent of $A$.

**Test:** For each $n \in \{2, 3, 4, 5\}$, enumerate all possible quartic templates with support size $\leq Cn^2$ for small constant $C$. For each template, test the Lorentzian equivalence on 100 random symmetric matrices. Report the sparsest template that passes all tests.

**Impact:** Sparse templates would enable faster Lorentzian recognition and potentially yield combinatorial certificates for spectral properties, connecting to matroid theory and tropical geometry.

**Catalog References:** `Bridges/SpectralEmbeddingLorentzian.lean` (construction has $n^2$ nonzero coefficients), `Pythagorean/LorentzianHardness.lean` (lower bounds on leaf count).

**Proof Strategy:** The key insight is that the current construction $P_A = t^2 Q_A(x)$ already has $O(n^2)$ monomials and is the sparsest possible (matching the input size). The question is whether a *different* template can achieve the same equivalence with fewer monomials by exploiting algebraic identities. **Why now?** The exact equivalence is proved, so the optimization question is well-posed.

**Domain Bridges:** Tropical geometry (sparse polynomial theory), matroid theory (basis exchange), compressed sensing (sparse recovery from linear measurements).

**Lineage:** Optimization of `spectral_embed` construction.

**Ambition:** Solid extension — concrete and testable.

---

## Direction 4: Hardness of Approximate Lorentzian Recognition via Spectral Embedding

**Conjecture:** For any $\epsilon > 0$, distinguishing between "all leaves have Hessian with 0 positive eigenvalues" and "some leaf has Hessian with $\geq 2$ positive eigenvalues" for degree-$d$ polynomials in $n$ variables requires $\Omega(n^{d/2 - 1})$ Hessian evaluations, even when the coefficients are promised to be $\epsilon$-close to integers.

**Test:** Implement a reduction from the matrix "1-vs-2 positive eigenvalue" distinguishing problem (known to require $\Omega(n)$ queries in the matrix-vector product model) to Lorentzian leaf checking. Measure the query complexity empirically for $n \in \{10, 20, 50, 100\}$ and degrees $d \in \{4, 6, 8\}$.

**Impact:** This would establish the first *unconditional* lower bounds for Lorentzian recognition in terms of spectral complexity, potentially separating polynomial-time recognition from exponential-time recognition for varying degree.

**Catalog References:** `Pythagorean/LorentzianHardness.lean` (`multiindex_count_exponential_lower`), `Bridges/SpectralEmbeddingLorentzian.lean` (`two_pos_obstruction`).

**Proof Strategy:** The key insight is that the spectral embedding converts eigenvalue distinguishing into leaf checking, so lower bounds for eigenvalue problems transfer to Lorentzian recognition. **Why now?** The spectral embedding provides the first formal reduction; prior work had only upper bounds.

**Domain Bridges:** Computational complexity (query complexity, communication complexity), numerical linear algebra (eigenvalue algorithms), property testing (sublinear algorithms).

**Lineage:** Combines `LorentzianHardness` lower bounds with `SpectralEmbedding` reduction.

**Ambition:** Grand challenge — connecting spectral complexity to algebraic recognition complexity.

---

## Direction 5: Relativistic Energy Forms and Lorentzian Causal Structure

**Conjecture:** For a Lorentzian metric $g$ on an $n$-dimensional spacetime manifold, the energy-momentum tensor $T_{\mu\nu}$ satisfies the dominant energy condition if and only if a suitable spectral embedding $P_{T+g}$ has all Lorentzian leaves, where the matrix $A = T + \lambda g$ for an appropriate shift $\lambda$ ensures at most one positive eigenvalue.

**Test:** Compute spectral embeddings for energy-momentum tensors of standard solutions (Schwarzschild, Kerr, FLRW cosmologies). Verify that the dominant energy condition corresponds exactly to the Lorentzian leaf condition. Test on 100 randomly perturbed metrics near each standard solution.

**Impact:** This would connect Lorentzian polynomial theory (named for its signature condition) to actual Lorentzian geometry in general relativity, creating a new certification framework for energy conditions in mathematical physics.

**Catalog References:** `Bridges/SpectralEmbeddingLorentzian.lean` (spectral embedding for general symmetric matrices), `Bridges/LorentzianRecognition.lean` (Hessian signature analysis).

**Proof Strategy:** The key insight is that the dominant energy condition is equivalent to $T_{\mu\nu}$ having a specific inertia profile relative to $g_{\mu\nu}$. The spectral embedding converts this to a polynomial condition that can be checked algorithmically. **Why now?** Energy conditions are traditionally checked pointwise; the spectral embedding provides a global algebraic certificate.

**Domain Bridges:** General relativity (energy conditions, Penrose singularity theorems), mathematical physics (causal structure), differential geometry (Lorentzian manifolds), PDE theory (hyperbolic equations).

**Lineage:** Application of `spectral_embed` to physics; connects the "Lorentzian" naming to actual Lorentzian geometry.

**Ambition:** Grand challenge — requires bridging formal mathematics with physics.
