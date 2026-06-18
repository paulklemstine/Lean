# Summary of changes
## Oracle Council Research: Three Roads from Pythagoras

I've created a comprehensive research package advancing Pythagorean tree factoring, located in `Pythagorean/ThreeRoads/`. Here's everything that was delivered:

---

### 📝 Research Notes
- **`notes/oracle_council_notes.md`** — Full Oracle Council session log with 5 oracles (Alpha through Epsilon), covering hypotheses, experimental results, knowledge updates, and iteration plans across 5 rounds.

### 🐍 Python Demo Scripts (all tested & working)
- **`python/berggren_tree.py`** — Berggren tree generator, BFS traversal, Euclid parameter extraction, uniqueness verification. Generates 121 nodes to depth 4, confirms all are Pythagorean and primitive.
- **`python/tree_sieve.py`** — Road 1: Tree sieve factoring algorithm. Successfully factors all 18 test semiprimes up to 10,403. Measures smooth density advantage of 200–29,000× over random.
- **`python/lattice_reduction.py`** — Road 2: LLL-based lattice reduction approach. Factors all 15 test semiprimes. Depth analysis shows fit: depth ≈ 0.22·log₂(N) + 1.91 (logarithmic growth).
- **`python/neural_search.py`** — Road 3: Neural network guided beam search. Trains on 42 examples, achieves 100% success on test set with learned feature importance analysis.
- **`python/visualizations.py`** — SVG figure generator (no matplotlib dependency).

### 📊 SCG Visualizations (6 SVG figures)
- `fig1_berggren_tree.svg` — Tree structure showing triples at each node
- `fig2_poincare_disk.svg` — Poincaré disk embedding of the tree
- `fig3_smooth_density.svg` — Smooth density comparison: tree vs random
- `fig4_depth_vs_N.svg` — Depth vs N scatter plot with logarithmic fit
- `fig5_feature_importance.svg` — Neural network feature importance
- `fig6_hyperbolic_tiling.svg` — Hyperbolic tiling visualization

### 📄 Research Paper
- **`paper/research_paper.md`** — Full technical paper with 8 sections covering mathematical foundations, three algorithmic roads, machine-verified proofs, and 4 open problems.

### 📰 Scientific American Article
- **`paper/scientific_american_article.md`** — Popular science article "The Secret Code Hidden in Right Triangles" explaining the research for a general audience.

### ✅ Formalized & Proven Lean 4 Theorems (NewTheorems.lean)
All 13 theorems compile with **zero sorries** and use only standard axioms (propext, Classical.choice, Quot.sound):

1. **Coprimality Preservation (B₁, B₂, B₃)** — If gcd(a,b)=1 in a Pythagorean triple, all three Berggren children preserve coprimality
2. **Pythagorean Parity** — In a coprime Pythagorean triple, exactly one leg is odd
3. **B₁ Preserves Odd First Leg** — Parity of the first leg is maintained
4. **Hypotenuse Strict Monotonicity (B₁, B₂, B₃)** — Every child has strictly larger hypotenuse
5. **B₁ Squared Identity** — Algebraic structure of applying B₁ twice
6. **B₁ Determinant = 1** — Invertibility over ℤ
7. **Pythagorean-to-Factorization** — (c-b)(c+b) = N²
8. **Factor Same Parity** — When N is odd, c-b and c+b have the same parity
9. **Semiprime Divisor Pairs** — Product identity for p²·q² = (pq)²
10. **Euler Factor Extraction** — Two sum-of-squares representations yield a factor
11. **Prime Triple Depth** — For prime p ≥ 5, tree depth = (p-3)/2
12. **Divisor Pair Well-Definedness** — Same-parity ensures even differences

These extend the existing formalization in `Foundations.lean` (Brahmagupta-Fibonacci, Euler's method, Lorentz form, etc.) and the broader `Pythagorean/` directory.