# Summary of changes for run 4967dc35-0310-467d-9ef4-adda90ab3674
## Semantic Bundles: When Isomorphic Structures Diverge in Meaning

### Novel Mathematical Structure
Introduced **Semantic Bundles** (DecoratedMagma) — algebraic structures equipped with interpretation maps into semantic spaces. This captures the precise mathematical content of "meaning" layered on top of algebraic structure.

### Lean 4 Proofs (19 theorems, 0 sorries)
All proofs in `Applications/SemanticBundle.lean` compile cleanly with standard axioms only.

**Key results:**
1. **Separation Theorem** (`separation_theorem`): Constructive proof that algebraically isomorphic structures can be semantically non-isomorphic — using XOR on Fin 2 with two different labelings.
2. **Rigidity Theorem** (`xor_rigid`, `rigid_semIso_implies_same_labels`): For structures with trivial automorphism group, semantic isomorphism reduces to label equality.
3. **Transfer Invariance** (`transfer_invariance`): Structural properties transfer across algebraic isomorphisms.
4. **Semantic Non-Transfer** (`semantic_property_not_transferable`): Semantic properties do NOT transfer — concrete counterexample.
5. **Truth-Meaning Gap** (`meaning_implies_truth`, `truth_not_implies_meaning`): Meaning preservation implies truth preservation, but not conversely.
6. **Non-Algebraicity of Diversity** (`algIso_not_preserves_diversity`): Semantic diversity is genuinely semantic — not preserved by algebraic isomorphism.
7. **Spectrum Invariance** (`semIso_preserves_spectrum`): The semantic spectrum is a complete invariant under semantic isomorphism.
8. **Maximum Diversity** (`rigid_injective_max_diversity`): Rigid structures achieve maximum semantic diversity — every distinct labeling is genuinely different.

### PEGB Coverage (top 3 theorems)
- **Separation Theorem**: Proof (complete), Example (XOR/Fin 2 in demo.py), Generalization (rigid_injective_max_diversity for arbitrary rigid structures), Boundary (same_op_labels_semIso shows when separation fails — same labels).
- **Rigidity Theorem**: Proof (complete), Example (Z/2Z is rigid, Z/3Z is not), Generalization (works for any finite magma), Boundary (algIso_not_preserves_diversity shows what breaks without rigidity).
- **Truth-Meaning Gap**: Proof (complete), Example (D_id → D_swap with trivial truth predicate), Generalization (arbitrary truth predicates), Boundary (meaning_implies_truth shows the one direction that does hold).

### Falsifiable Conjecture
**Semantic Burnside Conjecture**: For cyclic groups Z/nZ with k labels, the orbit count equals (1/φ(n)) · Σ_{d|n} φ(d)·k^{n/d}. Testable by computation for n ≤ 10, k ≤ 5 (see demo.py output for partial verification).

### Cross-Connection
Connected to catalog's `oracle_preserves_truth` and `grav_oracle_preserves_truth` via the Truth-Meaning Gap theorem: oracles preserve truth (structural) but not meaning (semantic).

### Deliverables
- `Applications/SemanticBundle.lean` — 19 fully proved theorems
- `ARTICLE.md` — Popular science article (no mentions of formal verification)
- `RESEARCH_PAPER.md` — Full research paper with proofs, algorithms, references
- `FUTURE_DIRECTIONS.md` — 5 research directions with conjectures, tests, strategies
- `demo.py` — Numerical demonstrations of all key results
- `algorithms.py` — Type-hinted implementations of core algorithms
- `viz_semantic_landscape.py` — Visualization script (matplotlib)
- `PACKAGE.json` — Complete package with 3 interactive HTML widgets