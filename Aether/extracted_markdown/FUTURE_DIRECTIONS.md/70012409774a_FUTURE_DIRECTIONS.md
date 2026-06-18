# Future Directions: Self-Avoiding Walks, Tropical Geometry, and Fekete's Lemma

## Synthesis

This cycle established a complete formal proof chain connecting three mathematical domains: (1) combinatorial submultiplicativity of self-avoiding walk counts, (2) Fekete-type bounds from real analysis that guarantee the existence of the connective constant, and (3) tropical convergence criteria that characterize when the SAW generating function converges in piecewise-linear terms. The key bridge result shows that the generating function $\sum c_n x^n$ converges for $x < 1/\mu$ if and only if the tropical parameter satisfies $\log x < -\log \mu$, unifying the classical analytic and tropical geometric perspectives.

Additionally, the irrationality of the Nienhuis constant $\sqrt{2+\sqrt{2}}$ was established via its minimal polynomial $x^4 - 4x^2 + 2 = 0$, which has no rational roots. This connects to the tropical algebra infrastructure through the tropicalization of this polynomial. The most promising cross-domain connections from this cycle are: (a) using the Fekete decomposition theorem as a quantitative tool for bounding growth rates on specific lattices, and (b) extending the tropical convergence framework to multi-variable generating functions relevant to lattice models in statistical mechanics.

The highest breakthrough potential lies in Direction 1 (discrete holomorphicity), which would formalize the mathematical core of the Duminil-Copin–Smirnov theorem. However, Direction 2 (quantitative Fekete bounds) offers the most tractable next step, building directly on the `fekete_decomposition` and `subadditive_mul_bound` theorems proved in this cycle.

---

### Direction 1: Discrete Holomorphicity of the Parafermionic Observable

**Conjecture**: The parafermionic observable $F(z) = \sum_{\omega: a \to z} x_c^{|\omega|} e^{-i(5/8)\theta(\omega)}$, defined as a sum over self-avoiding walks from boundary vertex $a$ to medial vertex $z$ on the hexagonal lattice, satisfies the discrete Cauchy-Riemann equations on the medial lattice when $x_c = 1/\sqrt{2+\sqrt{2}}$.

**Test**: Define the medial lattice of a finite hexagonal domain (e.g., a 3×3 hexagonal patch) as a planar graph in Lean. Enumerate all SAWs on this small domain. Compute the parafermionic observable numerically at the critical fugacity and verify the discrete Cauchy-Riemann equations hold to machine precision. Then formalize the algebraic identity that makes the discrete CR equations exact (not approximate) at the critical point.

**Impact**: If formalized, this would provide a machine-verified proof of the exact value of the hexagonal lattice connective constant, which is one of the deepest results in combinatorial probability. It would be the first fully formal proof of the Duminil-Copin–Smirnov theorem.

**Catalog References**: `Bridges/SAWTropical/NienhuisConstant.lean` (nienhuis_minimal_poly, nienhuis_irrational), `Bridges/SAWTropical/SubadditiveSeq.lean` (submult_growth_rate_le, growth_rate_le_c1)

**Proof Strategy**: 
1. Define the hexagonal lattice and its medial lattice as a graph structure.
2. Define the winding angle function $\theta(\omega)$ for a path on the medial lattice.
3. Define the parafermionic observable as a complex-valued function on medial vertices.
4. State the discrete Cauchy-Riemann equations: for each interior medial face with vertices $v_1, v_2, v_3$, the sum $F(v_1) + e^{2\pi i/3} F(v_2) + e^{4\pi i/3} F(v_3) = 0$.
5. Show this reduces to an algebraic identity involving $x_c = 1/\sqrt{2+\sqrt{2}}$ and the winding angles.
6. Verify the algebraic identity using the minimal polynomial $x_c^4 - 4x_c^2 + 2 = 0$ (already proved as nienhuis_minimal_poly).

**Domain Bridges**: Combinatorial graph theory (SAW enumeration) <-> Complex analysis (discrete holomorphicity) <-> Algebraic number theory (minimal polynomial of $x_c$)

**Lineage**: Builds on nienhuis_minimal_poly and nienhuis_irrational from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative Fekete Bounds for Lattice Connective Constants

**Conjecture**: For the square lattice with SAW counts $c_n$, the Fekete decomposition $c_n \leq c_d^{\lfloor n/d \rfloor} \cdot c_{n \bmod d}$ combined with exact computation of $c_1, \ldots, c_{30}$ (known values) gives a rigorous upper bound $\mu \leq 2.6792$ that improves on the trivial bound $\mu \leq c_1 = 4$.

**Test**: Implement the Fekete bound computation in Python using known SAW counts for the square lattice (available up to $c_{79}$ in the literature). Verify the bounds numerically. Then formalize the bound in Lean by instantiating `fekete_decomposition` with specific computed values.

**Impact**: This would provide the first formally verified nontrivial bounds on the square lattice connective constant. While the numerical value $\mu \approx 2.63816$ is well-established empirically, rigorous bounds are much harder to establish. The Fekete approach gives an elementary upper bound; combining it with bridge decomposition techniques could give matching lower bounds.

**Catalog References**: `Bridges/SAWTropical/SubadditiveSeq.lean` (fekete_decomposition, subadditive_mul_bound, submult_growth_rate_le)

**Proof Strategy**:
1. Define the square lattice SAW counting function $c: \mathbb{N}^+ \to \mathbb{N}$ with exact values for small $n$.
2. Prove $c_n$ is submultiplicative (requires formalizing the concatenation argument).
3. Instantiate the Fekete decomposition with $d = 10$ (or larger) to get $\mu \leq c_{10}^{1/10}$.
4. Compute $c_{10}^{1/10}$ rigorously using interval arithmetic.
5. Compare with numerical estimates and discuss the gap.

**Domain Bridges**: Combinatorial enumeration (SAW counts) <-> Real analysis (Fekete bounds) <-> Computational mathematics (interval arithmetic)

**Lineage**: Direct extension of fekete_decomposition and submult_upper_bound proved in this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Spectral Theory for Transfer Matrices

**Conjecture**: The connective constant $\mu$ of a lattice equals the tropical spectral radius (maximum tropical eigenvalue) of the tropical transfer matrix $T$ obtained by tropicalizing the classical SAW transfer matrix. That is, $\log \mu = \max_v \lim_{n \to \infty} (T^{\odot n})_{1,v} / n$, where $\odot$ denotes tropical matrix multiplication (replace $+$ with $\max$, $\times$ with $+$).

**Test**: For a narrow strip of the square lattice (width 2 or 3), construct the classical transfer matrix explicitly, tropicalize it, and compute the tropical spectral radius. Compare with the known connective constant. If they agree for narrow strips, attempt a formal proof for general width.

**Impact**: This would establish a new computational paradigm for connective constants: instead of computing eigenvalues of exponentially large matrices (classical approach), one would compute tropical eigenvalues, which reduce to finding shortest/longest paths in weighted digraphs. This could make formerly intractable computations accessible, particularly for three-dimensional lattices.

**Catalog References**: `Bridges/SAWTropical/TropicalConvergence.lean` (tropical_convergent_of_lt_neg_growth, tropical_divergent_of_gt_neg_growth), potentially `Tropical.SpectralCryptanalysis` from the Catalog.

**Proof Strategy**:
1. Define tropical matrices and tropical matrix multiplication in Lean.
2. Define the tropical spectral radius as the asymptotic growth rate of iterated tropical matrix power.
3. Construct the SAW transfer matrix for a strip of width $w$: rows/columns indexed by boundary configurations, entries counting walks across one column.
4. Show the tropicalized transfer matrix encodes $\log c_n$ growth rates.
5. Apply submultiplicativity to connect the tropical spectral radius to the connective constant.

**Domain Bridges**: Tropical algebra (max-plus matrices) <-> Linear algebra (spectral theory) <-> Statistical mechanics (transfer matrices)

**Lineage**: Builds on tropical convergence framework from this cycle and potentially on Catalog's tropical algebra infrastructure.

**Ambition**: grand_challenge

---

### Direction 4: Multi-Variable Tropical Generating Functions for Lattice Models

**Conjecture**: The multi-variable generating function $f(x, y) = \sum_{m,n} c_{m,n} x^m y^n$ for SAWs on a lattice with $m$ horizontal and $n$ vertical steps has a tropical amoeba (the complement of the convergence region in log-coordinates) whose boundary is a tropical curve encoding the directional connective constants $\mu(\theta) = \lim_{n} c_{\lfloor n\cos\theta \rfloor, \lfloor n\sin\theta \rfloor}^{1/n}$.

**Test**: Compute the multi-variable SAW counts $c_{m,n}$ for small $m, n$ on the square lattice. Plot the convergence region of the generating function in $(\log|x|, \log|y|)$ coordinates. Compare the boundary with the predicted tropical curve.

**Impact**: This would connect SAW theory to the rich structure of tropical amoebas, potentially providing new tools for studying anisotropic polymer models. The shape of the amoeba encodes directional growth rates, which are physically meaningful for polymers under directional stress.

**Catalog References**: `Bridges/SAWTropical/TropicalConvergence.lean` (full tropical convergence framework), potentially `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`

**Proof Strategy**:
1. Define multi-variable tropical valuations: $v: \mathbb{N}^2 \to \mathbb{R}$ with subadditivity in each coordinate.
2. Define the multi-variable tropical power series and convergence region.
3. Establish that the convergence region is a convex set in $\mathbb{R}^2$ (from subadditivity).
4. Show the boundary is piecewise-linear under appropriate conditions (tropical curve structure).
5. Connect to the directional connective constants via a multi-dimensional Fekete argument.

**Domain Bridges**: Tropical geometry (amoebas, tropical curves) <-> Combinatorics (multi-variable SAW counts) <-> Polymer physics (anisotropic models)

**Lineage**: Extension of the one-variable tropical convergence framework to multiple variables.

**Ambition**: extension

---

### Direction 5: Eisenstein Irreducibility and Connective Constant Algebraicity

**Conjecture**: The minimal polynomial $x^4 - 4x^2 + 2$ of $\sqrt{2+\sqrt{2}}$ is irreducible over $\mathbb{Q}$ by Eisenstein's criterion at $p = 2$ (after a suitable substitution), confirming that the Nienhuis constant has exact algebraic degree 4 over $\mathbb{Q}$. Moreover, for any lattice whose connective constant $\mu$ is algebraic, the degree of the minimal polynomial of $\mu$ provides a lower bound on the "tropical complexity" of the lattice.

**Test**: Formalize Eisenstein's criterion for irreducibility in Lean (check if it already exists in Mathlib). Apply it to prove irreducibility of $x^4 - 4x^2 + 2$. Alternatively, prove irreducibility directly by showing the polynomial has no factorization into lower-degree polynomials with rational coefficients. Then define "tropical complexity" and verify the conjecture for the hexagonal lattice (degree 4) vs. simpler lattices.

**Impact**: This would provide a finer algebraic invariant for lattices than the connective constant alone. The question of whether the square lattice connective constant is algebraic or transcendental is open—if transcendental, this would imply infinite "tropical complexity" and fundamentally different structural properties from the hexagonal lattice.

**Catalog References**: `Bridges/SAWTropical/NienhuisConstant.lean` (nienhuis_minimal_poly, no_rational_roots_of_nienhuis_poly)

**Proof Strategy**:
1. Check Mathlib for Eisenstein's criterion (likely exists as `Polynomial.Irreducible.eisenstein`).
2. Apply to $x^4 - 4x^2 + 2$ at $p = 2$: the constant term $2$ is divisible by $2$ but not $4$, and the leading coefficient $1$ is not divisible by $2$. (Need to verify the middle coefficients: $-4$ is divisible by $2$, $0$ is divisible by $2$.)
3. Alternatively, show directly that the polynomial has no rational roots (already done) and no factorization as a product of two quadratics over $\mathbb{Q}$.
4. Define "tropical complexity" as the algebraic degree of the connective constant and explore its properties.

**Domain Bridges**: Algebraic number theory (irreducibility, algebraic degree) <-> Tropical geometry (tropical complexity) <-> Lattice combinatorics (connective constants)

**Lineage**: Builds on nienhuis_minimal_poly and no_rational_roots_of_nienhuis_poly from this cycle.

**Ambition**: extension
