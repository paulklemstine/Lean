# Summary of changes for run 806b3c66-d830-45e1-9e54-21bfa9ada139
## Completed: The Oracle's Burden — Oracle Hierarchy Formalization

### Lean 4 Proofs (`Computation/OracleBurden.lean`)
All theorems are fully proved (zero `sorry` statements) and verified with clean build. Key results:

1. **`strict_hierarchy`** — Each oracle jump genuinely increases theorem-proving power
2. **`no_collapse`** — The hierarchy PA < PA^H < PA^{H^H} < ... never stabilizes
3. **`truth_invariant`** — All levels share the same set of true sentences
4. **`deep_soundness_gap`** — Consistency is resolved one level up, but soundness is NOT (the central result)
5. **`asymmetry_of_self_knowledge`** — Con(T_n) and Sound(T_n) behave fundamentally differently
6. **`burden_paradox`** — Level n proves n consistency facts but cannot prove its own
7. **`separating_witness_count`** — Between levels m and n, exactly n-m explicit separating witnesses exist
8. **`con_not_provable_below`** — Con(T_n) is not provable at any level ≤ n (depth lower bound)
9. **`jump_hierarchy_order_embedding`** — The oracle hierarchy is order-isomorphic to the Turing jump hierarchy
10. **`information_trichotomy`** — Every sentence is either provable, true-but-unprovable, or false

### Novel Definition: `ReflectiveTheory`
A structure combining provability and truth predicates in one framework, enabling precise formalization of the soundness barrier. This goes beyond the existing `Oracle'` and `OracleHierarchy` structures in the Catalog.

### Conjecture: `exponentialSoundnessGapConjecture`
The complexity of Sound(T_n) in the arithmetical hierarchy grows with n. Testable prediction: for fixed k, Sound(T_n) cannot be expressed as a Π_k sentence when n > k.

### Deliverables
- **`ARTICLE.md`** — Popular science article (Scientific American style) about the ideas, not the verification
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, proofs, algorithms, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with conjectures, tests, and proof strategies
- **`demo.py`** — Numerical demonstrations of hierarchy, burden paradox, and soundness gap
- **`algorithms.py`** — Type-hinted implementations of all algorithms
- **`visualize_hierarchy.py`** — Matplotlib visualization scripts
- **`PACKAGE.json`** — Complete package with 3 interactive HTML demos (Oracle Hierarchy Explorer, Burden Paradox Visualizer, Consistency vs Soundness Gap)