# Summary of changes for run 66acbf80-12ed-4d87-b0d2-2c8483bdaefa
## Completed: Symmetric Group Generation Probability — Formal Theory

### Lean 4 Formalization (`Catalog/Algebra/SymmetricGroupGeneration/Core.lean`)

A single, self-contained Lean file with **zero `sorry`s** and all proofs verified against standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Contains:

**Novel definitions:**
- `preservesFinset` — permutation preserves a finset
- `pairPreservesFinset` — pair preservation
- `generatesSymm` — two permutations generate S_n
- `permPreservingFinset` / `pairsPreservingFinset` — counting finsets
- `evenPairCount`, `probBothEvenReal`, `recipBinomialSum` — probability objects

**Fully proved theorems (10 total, no sorry):**

1. **`card_perms_preserving_finset`** — The number of permutations preserving a fixed k-element subset is k!·(n−k)!. Proved via explicit bijection with Perm(A) × Perm(Aᶜ).

2. **`card_pairs_preserving_finset`** — The pair count is (k!·(n−k)!)².

3. **`card_alternatingGroup_eq`** — |A_n| = n!/2 for n ≥ 2.

4. **`even_pair_not_generates`** — Even pairs cannot generate S_n.

5. **`prob_both_even_eq_quarter`** — P(both even) = 1/4 for n ≥ 2.

6. **`generation_probability_le_three_quarters`** — P_n ≤ 3/4 for n ≥ 2 (sharp upper bound).

7. **`choose_ge_choose_two`** — C(n,k) ≥ C(n,2) for 2 ≤ k ≤ n−2.

8. **`nontransitivity_obstruction_edge_dominated`** — ∑ C(n,k)⁻¹ ≤ 2/n + (n−3)/C(n,2). **Cross-domain theorem** connecting to Boolean isoperimetry.

9. **`binomial_recip_sum_le_refined`** — ∑ C(n,k)⁻¹ ≤ 2/n + 2/(n−1).

10. **`binomial_recip_sum_le_four_div_n`** — ∑ C(n,k)⁻¹ ≤ 4/n for n ≥ 4.

Plus structural lemmas: `preservesFinset_mul`, `preservesFinset_one`, `preservesFinset_inv`, `recip_binom_edge_eq`.

**Conjecture** (in docstring): Residual proper transitive probability ≤ 3/n² for n ≥ 8, with explicit computational test instructions.

### Other Deliverables

- **ARTICLE.md** — 2500-word popular science article explaining why two random shuffles almost always generate all possible arrangements, the 3/4 limit, parity obstruction, and connections to cryptography and network science.

- **RESEARCH_PAPER.md** — Comprehensive research paper with abstract, full theorem statements, proof sketches, algorithm pseudocode with complexity analysis, computational experiments, and references.

- **FUTURE_DIRECTIONS.md** — Five falsifiable conjectures: (1) Residual bound δ_n ≤ 3/n², (2) monotone convergence of P_n, (3) A_n generation probability → 1, (4) exponential decay of primitive obstructions, (5) three generators achieve P → 1.

- **demo.py** — Exact enumeration for small n, Monte Carlo estimation, binomial bound verification, residual conjecture testing.

- **algorithms.py** — Implementations of subset preservation counting, reciprocal binomial sum computation, orbit-based transitivity test, Dixon decomposition, and fast generation heuristic.

- **applications.py** — PRNG quality testing, card shuffling analysis, random Cayley graph generation, bias detection via subset preservation statistics.

- **PACKAGE.json** — Complete JSON data package bundling all content.