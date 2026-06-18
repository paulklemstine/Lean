# Summary of changes for run 85331137-65e1-4487-8dc2-65d1fd50bc24
## Oracle Approximation Theory: Ramanujan Oracles and Non-Computability

### Research Summary

This research cycle established a rigorous mathematical framework for studying "Ramanujan-style" oracle approximation — the question of how well finite collections of decision procedures can approximate the space of all mathematical truths.

### Novel Mathematical Structure: Oracle Deficiency Profile

The **Oracle Deficiency Profile** `DP(O, d)` is a graded invariant that measures, for an oracle set `O` and tolerance level `d`, how many truth assignments in the Boolean hypercube `{0,1}^n` remain uncovered by any oracle's Hamming ball. This captures the "approximation gap" between finite decision procedures and the full space of mathematical truths, providing a quantitative framework for discussing mathematical difficulty and surprise.

### Lean 4 Formalization: 17 Verified Theorems (0 sorries)

File: `Speculative/RamanujanOracle.lean` — fully verified, no sorry statements, clean axioms (only propext, Classical.choice, Quot.sound).

**Key definitions:**
- `hammingDist` — Hamming distance on `Fin n → Bool`
- `hammingBall` — Closed Hamming ball in Boolean hypercube  
- `oracleCoverage` — Union of Hamming balls around oracle set
- `deficiencyProfile` — Number of uncovered truth assignments (novel)
- `OracleApproxTower` — Hierarchical oracle structure with antitone tolerances (novel)
- `minOracleDist`, `maxDeficientTruth` — Constructive diagonal escape tools

**Key theorems:**
1. **Oracle Insufficiency Theorem** (`oracle_insufficiency`): If coverage cardinality < 2^n, uncovered truth assignments exist. Core pigeonhole argument.
2. **Deficiency Profile Antitonicity** (`deficiencyProfile_antitone`): More tolerance → less deficiency.
3. **Oracle Antitonicity** (`deficiencyProfile_antitone_oracles`): More oracles → less deficiency.
4. **Full Tolerance** (`deficiencyProfile_full_tolerance`): At tolerance n, deficiency = 0.
5. **Exponential Gap** (`exponential_gap`): At tolerance 0, deficiency ≥ 2^n − |O|.
6. **Non-Approximability Growth** (`nonapprox_growth`): For |O| < 2^n, deficiency is positive.
7. **Diagonal Escape** (`diagonal_escape`): There always exists a truth assignment differing from every oracle.
8. **Tower Monotonicity** (`OracleApproxTower.cumulativeOracles_mono`): Cumulative oracle sets grow with tower level.

Plus 9 foundational lemmas on Hamming distance and ball properties.

### Deliverables

- **ARTICLE.md** — Popular science article (~2000 words) about the mathematics of mathematical intuition
- **RESEARCH_PAPER.md** — Full research paper with abstract, definitions, theorems, PEGB analysis, algorithms, and discussion
- **FUTURE_DIRECTIONS.md** — 5 research directions including a grand challenge connecting deficiency profiles to the arithmetic hierarchy
- **demo.py** — 6 numerical demonstrations with verified outputs
- **algorithms.py** — 9 type-hinted algorithm implementations with doctests
- **3 visualization scripts** — Deficiency heatmap, exponential gap, Hamming landscape
- **PACKAGE.json** — Complete bundle with 3 interactive HTML widgets (Oracle Deficiency Explorer, Hamming Ball Visualizer, Insufficiency Threshold Calculator)

### Falsifiable Conjecture

**Ramanujan Non-Computability Conjecture**: For any computable enumeration of total Boolean functions and any ε < 1/2, the deficiency profile at tolerance ⌊εn⌋ is eventually positive. Testable by computing deficiency profiles for specific program enumerations at small n.