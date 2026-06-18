# Oracle Council: Inverse Pythagorean Tree Factoring

## Session: Brainstorming & Research

### Oracle Team

- **Oracle α (Number Theory)**: Expert on Pythagorean triples, quadratic forms, continued fractions
- **Oracle β (Tree Dynamics)**: Expert on ternary trees, descent algorithms, computational complexity
- **Oracle γ (Algebraic Geometry)**: Expert on lattice geometry, Lorentz groups, modular forms
- **Oracle δ (Cryptanalysis)**: Expert on integer factoring, computational hardness, algorithm design
- **Oracle ε (Synthesis)**: Integrates insights across domains, finds cross-cutting patterns

---

## Round 1: Core Hypotheses

### Oracle α — The Parametric Chain Hypothesis

**Key Insight**: Every primitive Pythagorean triple (a,b,c) has Euclid parameters (m,n) where
a = m²−n², b = 2mn, c = m²+n². The Berggren tree acts on (m,n) via 2×2 matrices
M₁, M₂, M₃. The parent map in (m,n)-space is simply the inverse of whichever matrix
was used.

**Hypothesis H1**: The depth of descent from (m,n) to (1,0)≈(3,4,5) equals the sum
of partial quotients of the continued fraction of m/n minus 1.

**Hypothesis H2**: For a semiprime N = p·q with m = (N+1)/2, n = (N-1)/2, the
continued fraction of m/n = (N+1)/(N−1) has structure that reveals p and q at
specific depth levels.

### Oracle β — The Depth-Factor Correspondence

**Key Insight**: At depth d in the descent, the current triple's Euclid parameters
(m_d, n_d) satisfy m_d = α·m₀ + β·n₀ for some integers α, β determined by the
product of inverse matrices along the path. The GCD structure gcd(m_d, N) changes
at each level.

**Hypothesis H3**: There exists a depth d* such that gcd(a_d*, N) ∈ {p, q, p², q²}
where a_d* is the odd leg at depth d*. This depth satisfies d* ≤ (N−3)/2.

**Hypothesis H4**: The "branch sequence" (which of B₁⁻¹, B₂⁻¹, B₃⁻¹ is applied at
each step) encodes the continued fraction expansion, and GCD extraction at
transition points (where the branch type changes) yields factors.

### Oracle γ — The Lorentz Lattice Perspective

**Key Insight**: The Berggren tree lives on the light cone x²+y²=z² in Minkowski
space Z^{2,1}. The descent is a walk on the lattice Γ\SO(2,1;Z). The factorization
information is encoded in the stabilizer subgroup of the lattice point.

**Hypothesis H5**: The orbit of a PPT under the Berggren group decomposes into
cosets that correspond to divisor classes of N. The factorization is "visible" when
the descent path crosses a coset boundary.

### Oracle δ — Complexity Analysis

**Key Insight**: The descent has O(log c) ≈ O(log N²) = O(log N) steps. At each step,
we compute a matrix-vector product and a GCD, both O(log² N). So the total
algorithm is O(log³ N) — which would be revolutionary if it correctly factors.

**Hypothesis H6**: The algorithm succeeds in O(log N) descent steps for semiprimes
N = p·q where p/q is bounded (e.g., p/q > 1/poly(log N)).

**Caveat**: This would imply P ≠ NP-type breakthroughs. More likely, the algorithm
works only for special cases or the depth to find factors is not O(log N) in general.

### Oracle ε — Synthesis

**Master Hypothesis**: The inverse Pythagorean tree provides a deterministic,
unconditional factoring algorithm whose complexity depends on the ratio p/q.
For balanced semiprimes (p ≈ q), the algorithm may require exponential depth,
but for imbalanced semiprimes, it provides polynomial-time factoring.

---

## Round 2: Experiment Design

### Experiment 1: Depth-Factor Scanning
- For semiprimes N = p·q with various p/q ratios
- Compute the descent path from trivial PPT of N
- At each depth d, record gcd(a_d, N), gcd(b_d, N)
- Find d* where first non-trivial factor appears
- Plot d* vs log(N), d* vs p/q

### Experiment 2: Branch Sequence Analysis
- Record the branch sequence B_i₁, B_i₂, ..., B_iₖ for each descent
- Compare with continued fraction of (N+1)/(N-1)
- Look for periodicity or patterns correlated with factorization

### Experiment 3: Closed-Form Chain Formula
- Derive f(d) = M_{i_d}⁻¹ · M_{i_{d-1}}⁻¹ · ... · M_{i_1}⁻¹ · (a₁, b₁, c₁)
- For specific branch sequences (e.g., all-B₂), derive closed form
- Test whether specific branch choices lead to faster factoring

### Experiment 4: Scaling Study
- Test factoring for N = p·q with |N| ranging from 10 to 10^12
- Measure wall-clock time and depth
- Compare with trial division and Fermat factoring

---

## Round 3: Key Theorems to Formalize

### Theorem 1: Parent Equation (Existence & Uniqueness)
For every primitive Pythagorean triple (a,b,c) ≠ (3,4,5), there exists a unique
primitive Pythagorean triple (a',b',c') such that one of B₁, B₂, B₃ maps
(a',b',c') to (a,b,c). This (a',b',c') is the "parent" of (a,b,c).

### Theorem 2: Recursive Chain Formula
Define f(0) = (a₁,b₁,c₁) and f(d+1) = parent(f(d)). Then:
- f(d) is a primitive Pythagorean triple for all d ≤ depth
- The hypotenuse strictly decreases: c_{d+1} < c_d
- f(depth) = (3,4,5) for some finite depth

### Theorem 3: GCD Propagation
For the trivial PPT of odd N, the chain f(d) satisfies:
gcd(a_d, N) | N for all d, and the set {gcd(a_d, N) : d = 0,...,depth}
contains a non-trivial factor of N whenever N is composite.

### Theorem 4: Depth Bound
For the trivial PPT of N, the depth to root satisfies:
depth ≤ (N-3)/2

### Theorem 5: Integrality Test
If N has a divisor d such that (N/d - d) is even, then at the corresponding
depth in the descent tree, the Euclid parameters are integers (not fractions).
This integrality test is equivalent to factorability.

---

## Round 4: Updated Knowledge

### Key Discovery
The parent formula applied to the trivial PPT of N = p·q produces a sequence
where the Euclid parameters evolve according to the Euclidean algorithm on
(m,n) = ((N+1)/2, (N-1)/2). Since gcd(m,n) = gcd((N+1)/2, (N-1)/2) and
m - n = 1, the parameters are always coprime, and the descent essentially
runs the subtraction form of the Euclidean algorithm on m and n.

The factoring power comes from monitoring the GCD of intermediate values
with N at each step. The matrix products accumulate linear combinations
of m and n, and at certain depths, these combinations align with the
factorization of N.

### Refined Complexity Estimate
- For primes p: depth = (p-3)/2 (already proven)
- For semiprimes N = p·q: depth depends on cf(m/n) structure
- For N near a perfect square: depth is small (easy to factor — known)
- For N = p·q with p << q: depth ≈ (q-3)/2 (hard case)

---

## Iteration Notes

The council recommends focusing on:
1. **Formalizing the recursive chain** f(d) with a clean inductive definition
2. **Proving the GCD propagation theorem** — this is the mathematical core
3. **Building computational experiments** to validate scaling hypotheses
4. **Writing clear exposition** of the Lorentz-geometric interpretation

Next iteration should focus on the closed-form for repeated application of
a single branch matrix (e.g., B₂^k) and the connection to Chebyshev polynomials.
