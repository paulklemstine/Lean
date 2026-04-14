# Consolidated Theorem Catalog

This directory contains a **deduplicated, reorganized, self-contained** copy of all 1,024 unique Lean files
from the project, organized into a clean category hierarchy.

## What was done

1. **Scanned** all 1,075 Lean files across 38 top-level directories
2. **Identified** 33 groups of exact-duplicate files (51 redundant copies)
3. **Removed duplicates** — keeping the canonical (shortest-path) copy of each
4. **Reorganized** the remaining 1,024 unique files into 75 consolidated categories
5. **Fixed imports** — all internal cross-references updated to use `Catalog.*` module paths,
   making the Catalog fully self-contained (no imports from old directory structure)
6. **Integrated into build** — added as a `lean_lib` target in `lakefile.toml`
7. **Generated** a master catalog (`CATALOG.md` at project root) with full statistics,
   duplicate report, and per-file declaration listings
8. **Generated** a declaration name index (`DECLARATION_INDEX.md` in this directory)
   listing all 19,614 unique declaration names alphabetically

## Directory Structure

```
Catalog/
├── Algebra/           — Foundations, DivisionAlgebras, LinearAlgebra, RepresentationTheory, Advanced
├── Analysis/          — Core analysis, inequalities, functional analysis, spectral theory
├── Best/              — Curated "best of" formalizations
├── Bridges/           — Cross-domain bridges, Langlands connections
├── CategoryTheory/    — Category theory foundations and Langlands program
├── Combinatorics/     — Combinatorial structures and counting
├── ComplexityTheory/  — Computational complexity
├── Computation/       — Factoring, Fibonacci, OctonionGates, Oracles
├── Cryptography/      — Core, Ethereum, Factoring, QuantumSecurity, ZeroKnowledge
├── EML/               — Emergent mathematical language research
├── FutureResearch/    — Future research directions and open questions
├── Geometry/          — Stereographic, PAdic, SphericalUniverse
├── InformationTheory/ — Information theory, coding theory, compression
├── Logic/             — Foundations, formalization, computability, set theory
├── MachineLearning/   — Consciousness, Neural, Prediction, QuantumTransformer, Sheffer
├── NeuralCompilation/ — Neural compilation formalization
├── NumberTheory/      — Core, Diophantine, Factoring, IntegerEnergy, RiemannHypothesis
├── Physics/           — AlgebraicPhysics, ArithmeticPhotons, Classical, Quantum, Spacetime
├── Probability/       — Probability theory and random matrices
├── Pythagorean/       — Core theory, tree factoring, quadruples, modular forms, QDF
├── ShefferAI/         — Sheffer stroke AI formalization
├── Speculative/       — ArithmeticUniverse, Consciousness, IdempotentCollapse, Millennium, etc.
├── Topology/          — Topological foundations and applications
└── Tropical/          — Core tropical geometry, cryptography, Langlands, neural networks
```

## Build Integration

The Catalog is registered as a Lean library in `lakefile.toml` and can be built with:

```bash
lake build Catalog
```

All imports within the Catalog use `Catalog.*` module paths, so the Catalog is
fully self-contained and does not depend on the original scattered directory structure.

## Key Files

- **`../CATALOG.md`** — Full master catalog with statistics, duplicate report, and declaration listings
- **`DECLARATION_INDEX.md`** — Alphabetical index of all 19,614 declaration names
- **`README.md`** — This file

## Statistics

| Metric | Count |
|--------|-------|
| Unique Lean files | 1,024 |
| Total declarations | 24,509 |
| Theorems & lemmas | 18,705 |
| Definitions | 4,957 |
| Structures/classes/inductives | 843 |
| Lines of Lean code | 212,535 |
| Categories | 75 |
