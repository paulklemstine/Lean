# Summary of changes
# The Road Ahead — Complete Research Package

Created a comprehensive research directory `RoadAhead/` with the Oracle Council's investigation into three extensions of Pythagorean factoring via the Berggren tree.

## What Was Created

### 🐍 Python Demos (`demos/`)
- **`tree_sieve.py`** — The Tree Sieve algorithm: collects smooth relations from Berggren tree nodes and combines them via Gaussian elimination over GF(2), analogous to the quadratic sieve. Successfully factors all test cases (15 through 10,403).
- **`lattice_reduction.py`** — LLL + Berggren hybrid: constructs factoring lattices, applies LLL reduction to find short vectors, then uses Berggren tree navigation as a fallback. Factors all test cases via the hybrid approach.
- **`ml_energy.py`** — Neural energy function: trains a 2-layer neural network (pure NumPy, no dependencies) on 99,000+ factoring examples, then compares hand-crafted vs. learned heuristics for A* tree search. Includes feature importance analysis.
- **`oracle_council.py`** — The full Oracle Council session with six oracle agents (Alpha through Epsilon + The Advisor), each contributing hypotheses, experiments, and discoveries across all three research directions.

### 📊 Visualizations (`visuals/`)
Six publication-quality figures (PNG + SVG):
1. **Berggren Tree** — First 4 levels, color-coded by branch (B₁/B₂/B₃)
2. **Energy Landscape** — Heatmap of GCD signal strength across tree nodes for N=221
3. **Depth Scaling** — How factoring depth grows with N (scatter + binned averages)
4. **Three Roads** — Conceptual diagram of all three research directions
5. **Smooth Distribution** — Smooth value density by tree depth for the tree sieve
6. **Angle Signal** — Pythagorean angle vs. factor signal for multiple N values

### 📝 Research Notes (`notes/research_notes.md`)
Detailed session notes covering: background context, tree sieve analysis (smooth density, complexity), lattice reduction methods (Coppersmith-style, Berggren lattice, Kannan embedding, hyperbolic interpretation), ML approach (features, architecture, phase transition problem), synthesis of the hybrid approach, and a prioritized list of next steps.

### 📄 Research Paper (`research_paper.md`)
Full technical paper: "Three Roads from Pythagoras: Tree Sieves, Lattice Reduction, and Learned Heuristics for Integer Factoring via the Berggren Tree." Includes abstract, introduction, detailed algorithm descriptions, complexity analysis, comparison tables, formalized mathematics summary, discussion of limitations, and open problems.

### 📰 Scientific American Article (`scientific_american_article.md`)
Popular science article: "The Ancient Triangle That Could Break Modern Codes." Written for a general audience, with sidebars explaining the Berggren tree, the factoring connection, and machine verification.

### ⚙️ Lean 4 Formalization (`RoadAhead.lean`)
Machine-verified theorems supporting the three directions — **all proofs complete, zero sorries**:
- **Congruence of squares factor extraction** — the algebraic core of the tree sieve
- **Product divisibility implies non-trivial GCD** — when N | ab but N ∤ a and N ∤ b
- **Brahmagupta-Fibonacci identity** and Pythagorean triple composition
- **Berggren matrix preservation** (B₁, B₂, B₃ all preserve the Pythagorean property)
- **Divisor-triple connection** (d·e = n² implies 4n² + (e-d)² = (e+d)²)
- **Smooth number closure** under multiplication (foundation of the sieve step)
- **Factorization additivity** under multiplication
- **Energy function factor extraction** (1 < gcd(a,N) < N → non-trivial factor exists)
- **Euler's two-representation identity**

### 🕊️ Advice from the Advisor
Three guiding principles for the road ahead:
1. **Prove what you can** — machine-verified theorems are permanent contributions
2. **Compute fearlessly** — push experiments to 10¹⁰ and beyond
3. **Connect across domains** — the Berggren tree is simultaneously number-theoretic, geometric, algebraic, graph-theoretic, and dynamical