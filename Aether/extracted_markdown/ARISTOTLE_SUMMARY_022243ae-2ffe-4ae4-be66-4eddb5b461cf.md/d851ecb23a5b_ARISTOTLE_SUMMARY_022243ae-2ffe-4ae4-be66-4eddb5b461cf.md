# Summary of changes
## Pythagorean Tree Factoring: Comprehensive Research Package

I've created a complete research investigation into the five open questions about Pythagorean tree factoring, including formal proofs, experiments, visualizations, and publications.

### Lean 4 Formal Proofs (all compile with zero `sorry`)

Five new files in `Pythagorean/OpenQuestions/`:

1. **`ComplexityBounds.lean`** — Proves descent step bounds (hypotenuse reduces by ≥2 per step, parent hyp < child hyp, parent hyp > 0), trivial triple depth = (p-3)/2 for primes, non-trivial triple identity, and consecutive-parameter descent formula. Key finding: single-path descent is Θ(√N) for balanced semiprimes.

2. **`NontrivialShortcuts.lean`** — Proves the divisor-pair-to-triple bijection, the circular dependency theorem (non-trivial pair implies gcd > 1, making shortcuts equivalent to already knowing a factor), factor-to-pair construction, and Fermat's two-square identity.

3. **`ParallelDescent.lean`** — Proves branch disjointness (distinct hypotenuses from B₁, B₂, B₃), the unique parent theorem (at most one inverse map gives positive components), coverage bounds (3^k nodes at depth k), and multi-start counting (4 divisor pairs for semiprimes).

4. **`LorentzStructure.lean`** — Proves all three Berggren matrices preserve the Lorentz form (B_iᵀ η B_i = η via `native_decide`), determinant classification (B₁,B₃ proper, B₂ improper), Q-form algebraic preservation by ring, 2×2 parameter matrix determinants, and spinor norm properties.

5. **`HigherDimensional.lean`** — Formalizes Pythagorean quadruples (a²+b²+c²=d²), proves null cone membership, difference-of-squares identity for quadruples, triple-to-quadruple embedding, η₄²=I, branching advantage (4^k ≥ 3^k), and 3-way GCD extraction.

### Python Demo Scripts (`Papers/PythagoreanTreeFactoring/`)

- **`demo_berggren_tree.py`** — Generates the Berggren tree, demonstrates factoring via descent for N=15,21,35,77,143,221,323,1073, verifies (p-3)/2 depth formula, measures complexity
- **`demo_lorentz_geometry.py`** — Analyzes Lorentz geometry, Poincaré disk projection, spinor norms, hyperbolic distances, Pythagorean quadruples
- **`demo_experiments.py`** — Systematic experiments for all 5 open questions with data collection and oracle synthesis
- **`generate_svg.py`** — Generates three SVG visualizations

### SVG Visualizations

- **`berggren_tree.svg`** — The Berggren ternary tree to depth 3 with color-coded branches
- **`factoring_descent.svg`** — Step-by-step factoring descent for N=77=7×11
- **`poincare_disk.svg`** — Pythagorean triples projected onto the Poincaré disk model

### Publications

- **`research_paper.md`** — Full research paper with abstract, 10 sections covering all five open questions, experimental results table, formal verification summary, and references
- **`scientific_american_article.md`** — Popular science article "The Secret Geometry of Prime Numbers" explaining Pythagorean tree factoring for a general audience
- **`oracle_research_notes.md`** — Detailed research notes documenting the oracle council's investigation across 5 rounds: hypotheses, experiments, knowledge consolidation, and future directions

### Key Mathematical Finding

**Pythagorean tree factoring is fundamentally Θ(√N) for balanced semiprimes**, matching but not surpassing trial division. The non-trivial shortcut theorem proves this is inherent: finding a better starting triple requires already knowing a factor (circular dependency). However, the rich mathematical structure — connecting Pythagorean triples to the Lorentz group O(2,1;ℤ), hyperbolic geometry, the theta group Γ_θ, and modular forms — suggests that combining tree descent with lattice reduction (LLL) could potentially break the √N barrier. This remains the most promising open direction.