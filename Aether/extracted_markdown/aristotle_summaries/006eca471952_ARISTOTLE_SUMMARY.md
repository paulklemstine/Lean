# Summary of changes for run fcbab5b1-9d13-4b4c-a0eb-766b6a691401
## Completed: Global Tightness — Exact Higher-Order State Complexity

### Overview
I formalized the foundational infrastructure for the Global Tightness Conjecture in simply typed lambda calculus, proving that `typeStateBound` is an exact (not merely bounding) complexity invariant at the base arrow type, and establishing the key definitions and lemmas needed for the general theory.

### Lean 4 Formalization (`Catalog/Pythagorean/GlobalTightness.lean`)

**Proved theorems (all with clean axioms — propext, Classical.choice, Quot.sound only):**

1. **`pairwiseDistinct_card_le_ncard`** — The separation lower bound: a finite set of distinct reachable terms provides a cardinality lower bound on canonical quotient size. This is the higher-order analogue of counting distinguishable Myhill-Nerode residuals.

2. **`canonicalQuotientSize_depth_zero`** — At depth 0, every term has exactly 1 reachable state (itself).

3. **`canonicalQuotientSize_witnessBaseArrow`** — The central concrete result: the witness term `w₀ = (λ0.0)((λ1.1)(λ2.2))` has exactly 4 reachable states at depth 2, equaling `typeStateBound(base → base) = 4`. The proof includes:
   - Complete reduction diamond (4 explicit β-steps verified)
   - Classification of ALL reachable states (exactly 4, no others)
   - Cardinality computation via `Set.ncard`

4. **`global_tightness_base`** — Base case: for any type with `typeStateBound = 1`, any closed term achieves the bound at depth 0.

5. **`global_tightness_BB`** — Arrow case at `base → base`: the witness achieves typeStateBound = 4.

6. **`tightness_iterEndTy_1`** — Concrete tightness at `iterEndTy 1 = base → base`.

7. **`typeStateBound_iterEndTy_ge_exp`** — Exponential growth: `2^n ≤ typeStateBound(iterEndTy n)`.

8. **`w₀_reachable_classification`** — Complete classification of the reduction graph of the witness term.

**New definitions introduced:**
- `SaturatesTypeBound` — A term achieves the type state bound
- `EventuallySaturatesTypeBound` — Eventual stabilization at the bound
- `InhabitedType` — Type inhabitation by closed terms

**One remaining sorry:** The general `global_tightness` theorem (for arbitrary inhabited types beyond `base` and `base → base`) requires recursive witness construction for general arrow types — a genuinely deep open problem requiring terms with `(tsb A + 1)(tsb B + 1)` syntactically distinct reachable states.

### Other Deliverables

- **`ARTICLE.md`** — Popular-science article (~2500 words) explaining the research without technical jargon
- **`RESEARCH_PAPER.md`** — Comprehensive research paper with abstract, proofs, algorithms, experiments, and references
- **`FUTURE_DIRECTIONS.md`** — 5 falsifiable scientific hypotheses with structured format (conjectures, tests, impact, proof strategies)
- **`demo.py`** — Interactive demonstration: type selection, witness synthesis, quotient-size vs. depth analysis, exponential growth visualization
- **`algorithms.py`** — Core algorithms: type state bound computation, bounded state set BFS, saturation detection, witness synthesis
- **`applications.py`** — Applications: complexity classification, maximal-term detection, behavioral equivalence testing, resource estimation
- **`PACKAGE.json`** — Complete JSON bundle of all deliverables for web templating