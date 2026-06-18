# Pythagorean Tree Factoring — Research Notes

## Oracle Council Brainstorming Session

### Team Composition
- **Alpha (Number Theory)**: Divisor-triple bijection, Euclid parametrization
- **Beta (Algebra/Geometry)**: Spectral analysis, hyperbolic embeddings, theta group
- **Gamma (Computation)**: Python implementations, benchmarking, neural search
- **Delta (Formalization)**: Lean 4 proofs, machine verification
- **Epsilon (Synthesis)**: Paper writing, visualization, cross-cutting insights

---

## Hypothesis Registry

### H1: Smooth Density Persistence (STATUS: OPEN)
**Hypothesis**: The Berggren tree sieve produces B-smooth numbers at rates bounded below by C(B) > 1 times the Dickman prediction, for all tree depths.

**Evidence FOR**:
- Depth 5 experiments: 12× at B=10, 2× at B=50
- Structural: B₁/B₃ branches have polynomial growth (eigenvalue 1)
- The gap identity c²−2ab = (a−b)² constrains sieve values

**Evidence AGAINST**:
- Advantage appears to decrease with larger B (expected?)
- No theoretical proof of persistence
- Only tested to depth 6 (~364 triples)

**Next experiments**:
- Test to depth 10+ (requires efficient computation)
- Track advantage as function of depth for fixed B
- Analyze B₁-only and B₃-only subtrees separately

### H2: Logarithmic Depth Growth (STATUS: SUPPORTED, R²=0.91)
**Hypothesis**: The depth of the canonical triple for prime N is O(log N).

**Evidence**:
- Linear regression on primes 3–47: depth ≈ 10.15·ln(N) − 19.34
- R² = 0.91 (strong fit)

**Limitations**:
- Only tested for small primes (up to ~50)
- Canonical triple is the "easy" one — what about non-trivial triples?

### H3: Polynomial-Time CVP on Berggren Lattice (STATUS: SPECULATIVE)
**Hypothesis**: The closest-vector problem on the Berggren lattice is solvable in poly(log N) time.

**Evidence**:
- Unimodularity (det = ±1) of all Berggren matrices
- Connection to theta group Γ_θ (well-understood fundamental domain)
- Log-depth growth suggests short paths exist

**Obstacles**:
- General CVP is NP-hard
- No known polynomial-time algorithm even for special lattices of this type
- The tree is a free monoid, not a group (no inverses at the triple level)

### H4: Neural Generalization Barrier (STATUS: CONFIRMED)
**Hypothesis**: Neural branch predictors cannot generalize to significantly larger N than training data.

**Evidence**:
- ~15% improvement on in-distribution data
- Performance degrades to random for out-of-distribution N
- Consistent with: if NN could factor, P ≠ NP would be violated

---

## Key Discoveries

### Discovery 1: The Spectral Asymmetry
B₁ and B₃ have characteristic polynomial (x−1)³ — triple eigenvalue 1. This means paths purely along B₁ or B₃ grow *polynomially*, not exponentially. Only B₂ has spectral radius > 1.

**Implication**: Most paths in the tree (2/3 of branches at each level) grow slowly. This is why the tree produces so many smooth numbers — the slow-growing branches dominate the population.

**Formally verified**: `B1_char_poly_factored`, `B2_char_poly_factored`, `spectral_radius_B2_equation`

### Discovery 2: The √2 Irrationality Connection
The strict bound 2ab < c² follows from the irrationality of √2. If 2ab = c², then the gap (a−b)² = 0, so a = b. Then c² = 2a², giving c/a = √2 — contradiction.

**Formally verified**: `leg_product_bound` in AdvancedTheorems.lean

### Discovery 3: Theta Group Connection
M₃ = T² is directly a generator of the theta group Γ_θ = ⟨S, T²⟩ ⊂ PSL(2,ℤ). This connects the Berggren tree to:
- Jacobi theta functions
- Modular forms of half-integer weight
- The arithmetic of quadratic forms

**Significance**: If the theta group connection makes the CVP tractable, factoring would be polynomial-time.

### Discovery 4: The Tree Sieve Identity
For every triple (a, b, c) with a = N: (c−b) | N² and (c+b) | N². So gcd(c−b, N) and gcd(c+b, N) may reveal factors.

**Formally verified**: `tree_sieve_value_divides`, `tree_sieve_complement_divides`

---

## Experimental Log

### Experiment Set 1: Tree Structure (completed)
- Generated tree to depth 6: 1,093 triples
- Hypotenuse range: [5, 3,281,765]
- B₁ branch at depth 6: hyp range [61–large]
- B₃ branch at depth 6: hyp range [101–large]
- B₂ branch: grows ~3.73× per level (matches spectral radius)

### Experiment Set 2: Factoring Benchmark (completed)
- 12 semiprimes tested: 100% success
- Largest: 10,403 = 101 × 103
- Average time: <1ms
- All found via GCD of sieve values

### Experiment Set 3: Smooth Density (completed)
- At B=10, tree density ~39.5% vs random ~3.3% (12× advantage)
- At B=100, tree density ~97.8% vs random ~57.9% (~2× advantage)
- Advantage decreases with B (expected: for large B, everything is smooth)

### Experiment Set 4: Depth Growth (completed)
- Regression: depth ≈ 10.15·ln(N) − 19.34, R² = 0.91
- Tested primes 3 through 47

### Experiment Set 5: Neural Search (completed)
- 12→16→8→3 feedforward network
- ~15% improvement over random for small N
- GCD features ~45% of learned importance

---

## Iteration Plan

### Phase 1 (COMPLETED): Foundations
- [x] Divisor-triple bijection (Lean 4)
- [x] Berggren preservation theorems (Lean 4)
- [x] Spectral analysis (Lean 4)
- [x] Matrix injectivity (Lean 4)
- [x] Python implementations
- [x] SVG visualizations

### Phase 2 (CURRENT): Scaling Analysis
- [ ] Test tree sieve on larger numbers (10⁶–10⁹)
- [ ] Smooth density at depth 10+
- [ ] Depth growth for primes up to 10⁴
- [ ] LLL reduction on Berggren lattice

### Phase 3 (FUTURE): Algorithmic Development
- [ ] Combined tree sieve + lattice reduction
- [ ] Adaptive depth strategy (follow B₁/B₃ for smoothness)
- [ ] Quantify smooth density advantage theoretically
- [ ] Connection to continued fractions

### Phase 4 (ASPIRATIONAL): Complexity Results
- [ ] Prove or disprove smooth density persistence
- [ ] Analyze CVP complexity on theta-group lattices
- [ ] Relate tree sieve complexity to L-notation
- [ ] Quantum tree walk algorithms

---

## Open Questions for Future Investigation

1. **Is there an efficient inverse map?** Given a target triple, can we compute the Berggren path in poly-time?

2. **How does smooth density scale with depth?** Is C(B, d) increasing, decreasing, or oscillating?

3. **Can we exploit both B₁ and B₃ polynomial growth simultaneously?** Paths that mix B₁ and B₃ (avoiding B₂) grow slowly — how slowly?

4. **What is the distribution of primes along B₁-pure paths?** Since growth is polynomial, the density of primes might be analyzable.

5. **Connection to sum-of-squares representations?** Every prime p ≡ 1 (mod 4) has a unique sum-of-squares representation. How does this relate to Berggren tree position?

6. **Can the Poincaré disk model give us a distance metric for guided search?** Hyperbolic distance between current triple and target might guide branch selection better than the neural network.

7. **What about non-primitive triples?** The tree generates only primitive triples. Can we extend the sieve to include scaled triples (ka, kb, kc)?

---

## Bibliography Notes

- Berggren (1934): Original paper, in Swedish. Discovered the ternary tree independently of Barning.
- Barning (1963): Independent rediscovery, Dutch. More accessible paper.
- Hall (1970): "Genealogy of Pythagorean triads" — coined the genealogical metaphor.
- Price (2008): Modern treatment connecting to hyperbolic geometry.
- Romik (2008): "The dynamics of Pythagorean triples" — continued fraction connection.
