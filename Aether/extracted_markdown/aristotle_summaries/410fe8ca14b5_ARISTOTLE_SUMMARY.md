# Summary of changes for run 449df1e4-735a-4270-8192-1d5bf4072cff
## Completed Deliverables

### 1. Formally Verified Mathematics (Lean 4) — Zero Sorries

Three Lean files under `Speculative/Dixon/`, all compiling with no `sorry` and using only standard axioms:

**`Defs.lean`** — Core infrastructure:
- `closureFinset`: Computable subgroup closure function using iterative fixpoint
- `genFullBool`: Efficient BFS-based Boolean generation test using HashSets
- `countGenPairs`: Computable count of generating pairs
- `closureFinset_eq_univ_iff`: Proved equivalence between `closureFinset s = Finset.univ` and `Subgroup.closure ↑s = ⊤`, establishing the correctness bridge between computation and mathematics
- Supporting lemmas: `go_monotone`, `go_subset_closure`, `go_fixpoint`, `closureFinset_closed_mul`, `closureFinset_closed_inv`

**`Computation.lean`** — Certified generation probabilities (Theorems A & B):
- `card_genPairs_perm_fin_4 : countGenPairs 4 = 216` (via `native_decide`)
- `generationProbability_perm_fin_4 : ... = 3/8`
- `card_genPairs_perm_fin_5 : countGenPairs 5 = 6840` (via `native_decide`)
- `generationProbability_perm_fin_5 : ... = 19/40`
- Also: S₂ (p = 3/4) and S₃ (p = 1/2)

**`Obstruction.lean`** — Subgroup obstruction theory (Theorems C, D, E):
- `intransitive_obstruction_term`: The key algebraic identity C(n,k)·(k!(n-k)!/n!)² = 1/C(n,k)
- `intransitive_obstruction_le_four_over_n`: For n ≥ 5, Σ 1/C(n,k) ≤ 4/n
- `intransitive_tail_le_const_over_n_sq`: ∃ C, ∀ n ≥ 4, tail sum ≤ C/n² (with C = 20)
- `choose_ge_choose_two`: Binomial monotonicity for k ≤ n/2
- `choose_two_eq`: C(n,2) = n(n-1)/2
- `point_stabilizer_term`: 1/C(n,1) = 1/n

### 2. ARTICLE.md — Popular science article (~2200 words)
"The Surprisingly High Odds of Random Symmetry" — explains generation probability through the metaphor of card shuffling, covering the exact results, the obstruction framework, point-stabilizer dominance, and applications to cryptography and Galois theory. No mention of proof assistants.

### 3. RESEARCH_PAPER.md — Comprehensive research paper (~3500 words)
Full academic treatment with abstract, introduction, definitions, main results with proof sketches, algorithms with pseudocode and complexity analysis, computational experiments with tables, applications, and references.

### 4. Python Code
- **demo.py** — Demonstrates verified results, obstruction identity verification, 4/n bound checks, and point-stabilizer dominance ratios
- **algorithms.py** — Implements BFS closure, exact enumeration, obstruction bounds, dominance analysis, and subgroup classification with full docstrings
- **applications.py** — Random generation algorithms, cryptographic key analysis, Galois group heuristics, and statistical testing

### 5. FUTURE_DIRECTIONS.md — Five falsifiable hypotheses
- **A**: Tight bound 1/n + 3/n² for the obstruction sum
- **B**: Transitive non-alternating obstruction is O(1/n²)
- **C**: Multi-generator point-stabilizer formula with O(1/n^{r-1}) scaling
- **D**: Computational reach to S₇ via optimized algorithms
- **E**: Extension to alternating groups with parity correction

### 6. PACKAGE.json — Complete JSON bundle of all artifacts