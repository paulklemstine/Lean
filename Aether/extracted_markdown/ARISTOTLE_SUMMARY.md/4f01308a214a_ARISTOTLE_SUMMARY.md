# Summary of changes for run f90415a4-5f24-4c23-9676-2070ff49c7a1
## Completed: Product Formula for Probe Complexity κ

### Formally Verified Mathematics (Lean 4)

**File: `Pythagorean/ProbeComplexity/ProductFormula.lean`** (273 lines, zero `sorry`, clean build)

All theorems are fully machine-verified with only standard axioms (propext, Classical.choice, Quot.sound).

#### Main Theorems Proved:

1. **Product Upper Bound** (`probeComplexity_prod_le`):
   `κ(C × D) ≤ κ(C) · |Ob(D)| + κ(D) · |Ob(C)|`
   — The first compositional law for probe complexity. Proved constructively via lifted-probe families.

2. **Thin-Factor Bound** (`probeComplexity_prod_thin_left_le`):
   If C is thin, `κ(C × D) ≤ κ(D) · |Ob(C)|`
   — When one factor has no nondeterminism, the bound simplifies.

3. **Discrete-Factor Lower Bound** (`probeComplexity_prod_discrete_right_lb`):
   If C has a parallel pair and D is strictly discrete, `|Ob(D)| ≤ κ(C × D)`
   — Each discrete fiber requires its own probe, giving a tight lower bound.

4. **Max-Law Refutation** (`max_lt_probeComplexity_prod`):
   Under explicit hypotheses, `max(κ(C), κ(D)) < κ(C × D)`
   — Proves the naïve max-law is structurally wrong, with gap growing without bound.

#### Key Intermediate Lemmas:
- `prod_hom_eq_iff` — Morphism equality in products is componentwise
- `left_lift_separates` / `right_lift_separates` — Lifted probes separate coordinate differences
- `buildProductSeparatingFamily_isSeparating` — The constructed family is separating
- `card_buildProductSeparatingFamily_le` — Cardinality bound for the construction

#### New Definitions:
- `LiftLeftProbes` / `LiftRightProbes` — Probe lifting constructions
- `NonThinWitness'` — Existence of a genuine parallel pair
- `IsStrictlyDiscrete` — Categories with only identity morphisms
- `buildProductSeparatingFamily` — Verified constructive algorithm

### Python Deliverables

- **`demo.py`**: Computes κ for 7 test categories and all 49 products, verifying the upper bound in every case and exhibiting 8 max-law violations. Highlights the canonical counterexample Par(2) × Disc(2).

- **`algorithms.py`**: Implements exact κ computation (brute-force), product family construction, and the upper bound formula with full docstrings and complexity analysis.

- **`applications.py`**: Demonstrates applications to test suite design, channel discrimination, covering design optimization, and compositional complexity estimation.

### Documentation

- **`ARTICLE.md`**: Popular science article (~2000 words) explaining the discovery accessibly.
- **`RESEARCH_PAPER.md`**: Full research paper with proofs, algorithms, experiments, and references.
- **`FUTURE_DIRECTIONS.md`**: Five falsifiable conjectures (thin-factor exactness, coproduct formula, iterated product asymptotics, hypergraph reformulation, optimal sharing criterion).
- **`PACKAGE.json`**: Complete JSON data package for web templating.