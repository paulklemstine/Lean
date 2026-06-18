# Summary of changes for run 9820ff3c-e63a-4c87-a6ca-e1e79ba5a7ea
## Completed: Subgroup Thermodynamics — Phase Transitions in Random Generation

### Formally Verified Mathematics (Lean 4)

**File:** `Catalog/Pythagorean/SubgroupPressure.lean` — 8 theorems, 0 sorries, compiles cleanly.

**New definition introduced:**
- `subgroupPairPressure G ι H` — the partition-function invariant `∑ i, [G : H i]⁻²` that governs random generation probability.

**Theorems proved (all machine-verified, standard axioms only):**

1. **`card_sq_div_eq_index_inv_sq`** — Key identity connecting subgroup cardinality to index: `(|H|/|G|)² = [G:H]⁻²`.

2. **`natCard_subgroupPairs`** — The number of pairs in a subgroup equals the square of its cardinality.

3. **`nongeneratingPairCount_le_sum_card`** — Union bound: nongenerating pair count ≤ sum of squared subgroup cardinalities.

4. **`nongeneratingPairProb_le_pressure`** ★ — **Sieve Inequality**: If every nongenerating pair lies in some member of the family, then P(nongeneration) ≤ pressure. This is the bridge from group theory to statistical mechanics.

5. **`subgroupPairPressure_le_card_div_sq`** ★ — **Upper bound (energy dominance)**: If all indices ≥ D, then pressure ≤ |ι|/D².

6. **`subgroupPairPressure_ge_card_div_sq`** ★ — **Lower bound (entropy dominance)**: If all indices ≤ d, then pressure ≥ |ι|/d².

7. **`subgroupPairPressure_prod`** ★ — **Product factorization**: pressure(G×K, F×E) = pressure(G,F) · pressure(K,E). The exact multiplicative law of a partition function.

8. **`log_pressure_prod_eq_add`** ★ — **Free energy additivity**: log(pressure) is additive for product families, connecting to statistical mechanics (F = -log Z is additive for independent systems).

### Other Deliverables

- **`ARTICLE.md`** — Popular science article (~2500 words) explaining the phase transition discovery through the lens of shuffling cards and statistical mechanics.

- **`RESEARCH_PAPER.md`** — Full research paper (~4000 words) with abstract, definitions, theorem statements with proof sketches, computational experiments, cross-domain connections (statistical physics, coding theory, information theory), and references.

- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format: full wreath product analysis, universality of critical exponents, pressure for almost simple groups, large deviation principles, and subgroup coverings as codes.

- **`demo.py`** — Comprehensive demonstration computing pressure, free energy, and Monte Carlo generation probability for S_n and S_k^m families with km ≤ 12. Verifies product factorization and free energy additivity numerically. Identifies phase transition regions.

- **`algorithms.py`** — Certified pressure computation algorithms with `SubgroupData`, `PressureResult` dataclasses, product factorization shortcut, and block-defect pressure formula.

- **`applications.py`** — Four applications: cryptographic key generation security, network block redundancy, entropy-energy phase diagrams, and coding theory connections.

- **3 visualization scripts** (`viz_phase_heatmap.py`, `viz_pressure_curves.py`, `viz_entropy_energy.py`) — matplotlib plots showing the phase transition heatmap, pressure growth curves, and entropy-energy competition.

- **`interactive_pressure.html`** — Interactive slider-based pressure explorer with real-time visualization.

- **`PACKAGE.json`** — Complete JSON data package bundling all artifacts.