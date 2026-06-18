# Summary of changes for run 1aab2a51-8001-4348-90e9-5179697116f7
## Completed: Non-Archimedean Finite Probability Theory

### Files Created

1. **`Catalog/Bridges/NonArchProbability/Defs.lean`** — 325 lines, **0 sorries**, 19 theorems fully proved.
2. **`Catalog/Bridges/NonArchProbability/FUTURE_DIRECTIONS.md`** — 5 falsifiable research conjectures.

### Novel Mathematical Structures

- **`FinProbSpace F n`**: Finite probability space over an arbitrary linearly ordered field `F` with sample space `Fin n`. Requires nonneg weights summing to 1 — Kolmogorov axioms stated purely algebraically.
- **`RegularFinProbSpace F n`**: Regular probability space where every outcome has *strictly positive* weight. Over non-Archimedean fields, regularity is free (use infinitesimal weights), making conditional probability on singletons universally well-defined.
- **`DutchBook F n p`**: Formalization of Dutch book betting strategies (guaranteed-profit collections of stakes against given prices).

### Key Theorems (7 non-trivial, fully proved)

1. **Inclusion-exclusion** (`inclusion_exclusion_two`): P(A ∪ B) = P(A) + P(B) - P(A ∩ B), over any ordered field.

2. **Bayes' theorem** (`bayes_theorem`): P(A|B)·P(B) = P(B|A)·P(A), purely algebraic — works identically over non-Archimedean fields.

3. **Markov inequality** (`markov_ineq`): P(X ≥ t) ≤ E[X]/t for nonneg random variables, proved via weighted sum splitting.

4. **No Dutch Book** (`no_dutch_book`): If weights satisfy probability axioms, no guaranteed-profit betting strategy exists. Proof uses weighted sum contradiction.

5. **Dutch Book existence** (`dutch_book_of_sum_ne_one`): If prices don't sum to 1, an explicit Dutch book is constructed (stakes = ±1 everywhere).

6. **Regular conditional probability** (`regular_condProb_singleton_welldefined`): In a RegularFinProbSpace, P(A|{i}) = 1 if i ∈ A, 0 otherwise — always well-defined.

7. **Tropical bridge** (`prob_weight_power_bound`): When weights are ε^{k(i)} with ε ∈ (0,1), probability is squeezed between ε^{min k} and |A|·ε^{min k}, connecting to tropical (min-plus) probability in the limit.

### PEGB Coverage

Each major theorem includes proof, concrete example (e.g., explicit ℚ-valued probability spaces with rational weights like (1/2, 1/3, 1/6)), generalization direction, and boundary/limit-case analysis in the docstrings.

### Axiom Verification

All theorems depend only on standard axioms: `propext`, `Classical.choice`, `Quot.sound`.

### Central Mathematical Insight

All classical finite probability theorems are purely algebraic — they require only the ordered field axioms, not completeness or the Archimedean property. This means probability theory extends unchanged to fields containing infinitesimals, with the added benefit that every point can carry positive (infinitesimal) weight.