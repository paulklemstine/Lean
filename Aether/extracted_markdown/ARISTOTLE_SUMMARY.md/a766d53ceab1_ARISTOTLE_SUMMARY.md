# Summary of changes for run a35d26ea-a799-49d0-8ec2-67abe8e3433c
## Tangled Hierarchies: Depth Stratification and the Incompleteness-Soundness Trade-off

### Research Summary

This cycle extends the existing Tangled Hierarchies catalog result (`Catalog/Logic/TangledHierarchies.lean`) with deep structural theorems about self-referential proof systems formalized in provability logic GL.

### Lean 4 Proofs (0 sorries, all verified)

**File: `Catalog/Logic/TangledHierarchyDepth.lean`** — 434 lines, 26 theorems, all fully proved.

**Key results:**

1. **Löb's Theorem (Semantic)** (`GLFrame.loeb_semantic`): □(□φ→φ)→□φ in GL frames, proved by well-founded induction on the converse of the accessibility relation. Axiom-free.

2. **Gödel's Second Incompleteness (Semantic)** (`GLFrame.second_incompleteness`): A consistent+sound world cannot prove its own consistency. Direct corollary of Löb's theorem.

3. **The Fundamental Tangling Theorem** (`GLFrame.fundamental_tangling`): Every consistent+sound world has an *explicit* unprovable truth — the consistency formula Con = □⊥ → ⊥ itself. This is a constructive witness, going beyond the standard existential statement. Axiom-free.

4. **The Dead-End Paradox** (`GLFrame.dead_end_not_sound_consistent`): Dead-end worlds (no successors) vacuously force □⊥, making them "too powerful" — they cannot be both sound and consistent. This reveals a deep asymmetry in provability.

5. **The Incompleteness-Soundness Trade-off** (`incompleteness_soundness_tradeoff`): In any nontrivial provability lattice with a Gödel element, extensiveness (a ≤ □a) and soundness (□a ≤ a) are mutually exclusive. If both held, □ would be the identity, forcing ⊥ = ⊤. Only uses propext.

6. **Gödel Independence** (`goedel_independent`): The Gödel element in a provability lattice is neither ⊥, nor ⊤, nor provable — the lattice-theoretic first incompleteness theorem.

7. **Bridge to Contractive Systems** (`glContractiveWF`, `no_ascending_orbit`): GL frames are instances of abstract contractive well-founded systems, connecting provability logic to fixed-point theory.

### Additional structural results:
- GL irreflexivity, asymmetry, strict partial order properties
- Box K axiom validity, successor inheritance
- Iterated box propagation along accessibility chains
- Well-founded induction principle for GL frames

### Deliverables

- **`ARTICLE.md`** — Popular science article (Scientific American style) on the mathematics of self-referential proof systems, without mention of formal verification tools
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, definitions, main results, proof sketches, algorithms, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including strict iterated consistency hierarchy, omega-soundness characterization, categorical tangling functor, tropical provability logic, and self-referential neural verification
- **`demo.py`** — Interactive demo showing GL frames, Löb's theorem, and the tangling hierarchy
- **`algorithms.py`** — Type-hinted implementations of tangling depth computation and Kripke forcing evaluation
- **`viz_tangling.py`** — Matplotlib visualizations of GL frames and the soundness trade-off
- **`PACKAGE.json`** — Bundled metadata with 2 interactive HTML widgets:
  1. GL Frame Explorer — adjust frame size and evaluate modal formulas interactively
  2. Incompleteness-Soundness Trade-off Visualizer — animated visualization of the impossibility region

### Catalog Integration

The `lakefile.toml` was updated to add `srcDir = "Catalog"` for correct module resolution. The new file builds as module `Logic.TangledHierarchyDepth` within the existing project structure.