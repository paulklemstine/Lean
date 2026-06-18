# Research Notes: Tropical Semiring Approaches to Integer Factoring

## Session Log & Oracle Council

### The Oracle Council

We convene a panel of research oracles, each contributing a distinct perspective:

1. **Oracle of Algebra** — Expert in tropical semirings, min-plus algebra, and algebraic structures
2. **Oracle of Geometry** — Expert in tropical geometry, Newton polytopes, amoebas
3. **Oracle of Algorithms** — Expert in computational complexity, factoring algorithms (QS, NFS, ECM)
4. **Oracle of Number Theory** — Expert in p-adic valuations, divisor lattices, multiplicative functions
5. **Oracle of Optimization** — Expert in shortest-path problems, linear programming, combinatorial optimization

---

## Phase 1: Foundations & Literature Review

### What is a Tropical Semiring?

The **tropical semiring** (also called the **min-plus algebra**) is the algebraic structure (ℝ ∪ {+∞}, ⊕, ⊗) where:
- **Tropical addition**: a ⊕ b = min(a, b)
- **Tropical multiplication**: a ⊗ b = a + b
- **Additive identity**: +∞ (since min(a, +∞) = a)
- **Multiplicative identity**: 0 (since a + 0 = a)

There is also the **max-plus** variant where ⊕ = max, with additive identity −∞.

**Key properties:**
- Commutative semiring (no additive inverses!)
- Idempotent addition: a ⊕ a = a
- Tropical polynomials are piecewise-linear functions
- Tropical roots = breakpoints of the piecewise-linear graph

### The Fundamental Logarithmic Bridge

**Key Observation (Oracle of Algebra):** The logarithm map creates a semiring homomorphism from (ℝ₊, ×, +) to the max-plus tropical semiring:
- log(a · b) = log(a) + log(b) = log(a) ⊗ log(b) ✓
- But log(a + b) ≠ min(log(a), log(b)) in general ✗

This partial homomorphism is the starting point. Multiplication becomes tropical multiplication, but addition does not tropicalize cleanly. **This asymmetry is precisely what makes the factoring problem interesting in the tropical setting** — factoring N = p · q is "easy" tropically (log N = log p ⊗ log q), but *finding* p and q requires understanding additive structure that tropical algebra obscures.

### Existing Literature Connections

1. **Viro's patchworking** (2000s): Tropical geometry provides combinatorial shadows of algebraic geometry. Tropical curves approximate classical curves.
2. **Shortest path algorithms**: Tropical matrix multiplication computes all-pairs shortest paths (Floyd-Warshall is tropical matrix powering).
3. **Tropical spectral theory**: Tropical eigenvalues of matrices (Gaubert, 1992; Akian, Bapat, Gaubert 2006).
4. **Newton polygon method**: Classical connection between Newton polygons and p-adic valuations of roots.
5. **Litvinov's idempotent mathematics** (2005): "Dequantization" — tropical math as classical math at Planck constant → 0.

**Gap identified**: No published work directly applies tropical methods to integer factoring as a computational problem. This is genuinely novel territory.

---

## Phase 2: Hypothesis Generation

### Hypothesis 1: Tropical Polynomial Root Encoding (Oracle of Geometry)

**Idea**: Construct a tropical polynomial whose "roots" (breakpoints) encode divisors of N.

**Construction**: Given N, define:
```
T_N(x) = trop_min over k=0..N of { v_N(k) + k·x }
```
where v_N(k) encodes divisibility information.

If we set v_N(k) = −log(gcd(k, N)), then the tropical polynomial's breakpoint structure reflects the divisor lattice of N.

**Prediction**: The slopes of the piecewise-linear segments of T_N correspond to divisors of N.

**Status**: PROMISING — needs computational validation.

### Hypothesis 2: Tropical Eigenvalue Factoring (Oracle of Algebra + Algorithms)

**Idea**: Construct a matrix M_N from N such that the tropical eigenvalues of M_N reveal the prime factors.

**Background**: A tropical eigenvalue λ of matrix A satisfies:
A ⊗ x = λ ⊗ x (i.e., min_j(A_{ij} + x_j) = λ + x_i for all i)

The tropical eigenvalues are related to the minimum mean cycle weight in the associated directed graph.

**Construction**: Build an n×n matrix where entries encode relationships mod potential factors. The critical cycles in the associated graph correspond to actual factors.

**Status**: SPECULATIVE — interesting graph-theoretic reformulation.

### Hypothesis 3: Tropical Convolution Sieve (Oracle of Number Theory)

**Idea**: Express the factoring problem as a tropical (min-plus) convolution and exploit FFT-like algorithms for tropical convolution.

**Background**: Standard convolution: (f * g)(n) = Σ_{k} f(k)·g(n−k)
Tropical convolution: (f ⊕ g)(n) = min_k { f(k) + g(n−k) }

Define indicator-like functions in the tropical world:
- f(k) = 0 if k is "interesting", +∞ otherwise

Then tropical convolution finds pairs (a, b) with a + b = n where both are "interesting."

**Connection to factoring**: If we work in log-space, finding p·q = N becomes finding log(p) + log(q) = log(N), which is a tropical convolution problem!

**Status**: PROMISING — but the search space is still exponential without additional structure.

### Hypothesis 4: Tropical Geometry of the Factor Variety (Oracle of Geometry)

**Idea**: The equation xy = N defines a hyperbola in ℝ². Its tropicalization is a piecewise-linear curve. Integer points on this tropical curve correspond to factorizations.

**Tropicalization**: The tropical hyperbola Trop(xy − N) has a specific combinatorial structure — it's the corner locus of min(x + y, log N), which is the line x + y = log N in tropical coordinates, with rays extending to infinity.

**Key insight**: Integer lattice points near this tropical curve correspond to approximate factorizations. Refined tropical lifting (from tropical solutions to classical solutions) could guide factor search.

**Status**: INTERESTING — connects to lattice-based methods.

### Hypothesis 5: Valuation-Based Tropical Filtering (Oracle of Number Theory)

**Idea**: Use p-adic valuations as a tropical coordinate system. For each small prime p, v_p(N) gives a coordinate. The factorization N = a·b implies v_p(a) + v_p(b) = v_p(N) for all p.

**Tropical formulation**: In the tropical semiring, this is: v_p(a) ⊗ v_p(b) = v_p(N) (since ⊗ is +).

**Filtering**: For each candidate factor a, compute its valuation vector (v_2(a), v_3(a), v_5(a), ...). The tropical constraint v_p(a) ≤ v_p(N) for all p immediately restricts the search space.

**Status**: ESTABLISHED technique (essentially smooth number sieving), but the tropical language provides cleaner formulation.

---

## Phase 3: Experimental Design

### Experiment 1: Tropical Polynomial Breakpoint Analysis
- Construct T_N(x) for semiprimes N = p·q
- Compute breakpoints numerically
- Check if breakpoints correspond to log(p), log(q)
- Test for N = 15, 21, 35, 77, 143, 221, 1147, 10403

### Experiment 2: Tropical Eigenvalue Computation
- Build adjacency matrices from N using modular arithmetic
- Compute tropical eigenvalues (minimum mean cycle weight)
- Check correlation with prime factors
- Compare with classical eigenvalue methods

### Experiment 3: Tropical Convolution Search
- Implement (min, +) convolution
- Define appropriate indicator functions in log-space
- Benchmark against trial division
- Analyze complexity

### Experiment 4: Tropical Curve Lattice Point Enumeration
- Tropicalize the factor hyperbola xy = N
- Enumerate lattice points near the tropical curve
- Measure how tropical geometry constrains the search

### Experiment 5: Visualization Suite
- Tropical polynomial landscapes for various N
- Tropical eigenvalue spectra
- Factor lattice tropical embeddings
- Comparison heatmaps

---

## Phase 4: Results & Analysis

*(Populated by experimental code — see demos/)*

### Key Finding 1: Tropical Polynomial Structure
The tropical polynomial T_N(x) = min_d|N { −log(d) + x·log(N/d) } has breakpoints precisely at:
x_d = (log(d₁) − log(d₂)) / (log(N/d₂) − log(N/d₁))
for consecutive divisors d₁, d₂.

For a semiprime N = pq (p < q), the dominant breakpoints occur at positions related to log(p)/log(q), encoding the factor ratio.

### Key Finding 2: Min-Plus Convolution
The tropical convolution approach correctly identifies factors but has complexity O(√N) — equivalent to trial division. However, the tropical formulation reveals *structural* information: the convolution's "landscape" has a valley at the true factors, suggesting gradient-based tropical optimization could improve search.

### Key Finding 3: Tropical Eigenvalue Correlation
For specially constructed circulant-like matrices mod N, tropical eigenvalues show statistical correlation with factor sizes. Not a practical algorithm, but a genuine structural connection.

### Key Finding 4: The Tropical Newton Polygon Insight
**Most promising result**: The Newton polygon of the polynomial f(x) = x² − (p+q)x + N (whose roots are the factors p, q) has a tropical counterpart. The tropical roots of the tropicalization are:
- min(0, s+x, log(N)+2x) where s = log(p+q)
- Breakpoints at x = −s and x = (s − log N)
- These give log(q) − log(p) (the factor gap in log-space)

This means: **if we could estimate p+q tropically, we could factor N**. This connects to Fermat's method (N = ((p+q)/2)² − ((q−p)/2)²) through a tropical lens.

---

## Phase 5: Assessment & Conclusions

### What works:
1. Tropical algebra provides a clean *language* for factoring — log-space is natural
2. Tropical polynomials encode divisor structure in their breakpoints
3. The tropical Newton polygon beautifully reformulates the Fermat connection
4. Tropical convolution correctly frames the sum-of-logs constraint
5. Visualizations reveal geometric structure invisible in standard formulations

### What doesn't work (yet):
1. No tropical method achieves sub-exponential factoring on its own
2. Tropical eigenvalue methods are heuristic, not provably correct
3. The lack of additive inverses in tropical semirings limits algebraic manipulation
4. Tropical convolution search is fundamentally O(√N) without additional tricks

### Open questions:
1. Can tropical algebraic geometry's "lifting" theorems (Kapranov's theorem, structure theorem for tropical varieties) provide certified factor bounds?
2. Can tropical spectral theory on Cayley graphs of ℤ/Nℤ detect multiplicative structure?
3. Is there a tropical analogue of the number field sieve's polynomial selection step that could improve the NFS?
4. Can quantum tropical algorithms (tropical semiring operations on quantum computers) provide speedup?

### Honest assessment:
This research direction is **theoretically beautiful** and provides **genuine new perspectives** on factoring, but has **not yet produced a practical algorithmic improvement**. The most promising avenue is using tropical geometry to guide polynomial selection in existing methods (NFS, GNFS), where the tropical "skeleton" of the factor polynomial could optimize sieving.

---

## References

1. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
2. Mikhalkin, G. (2005). Enumerative tropical algebraic geometry in ℝ². *J. Amer. Math. Soc.*, 18(2), 313-377.
3. Akian, M., Bapat, R., & Gaubert, S. (2006). Max-plus algebra. In *Handbook of Linear Algebra*.
4. Litvinov, G. L. (2007). The Maslov dequantization, idempotent and tropical mathematics. *J. Math. Sci.*, 140(3), 349-386.
5. Viro, O. (2010). Hyperfields for tropical geometry I. *arXiv:1006.3034*.
6. Lenstra, H. W. (1987). Factoring integers with elliptic curves. *Annals of Math.*, 126(3), 649-673.
7. Pomerance, C. (1996). A tale of two sieves. *Notices of the AMS*, 43(12), 1473-1485.
