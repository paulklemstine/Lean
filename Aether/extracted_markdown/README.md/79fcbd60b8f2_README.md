This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# Lean 4 Formalization Library

A comprehensive collection of Lean 4 formalizations spanning pure mathematics, theoretical physics, computer science, and speculative research.

## Statistics

- **Total files**: 654 Lean source files
- **Total theorems/lemmas**: ~11,595
- **Categories**: 18
- **Proof assistant**: Lean 4.28.0
- **Library**: Mathlib v4.28.0

## Organized Theorem Directory

All theorems and files are organized in the [`Theorems/`](Theorems/) directory, categorized by mathematical domain. Each category contains:

- **Individual source files** — the original Lean files
- **`_Consolidated.lean`** — a single merged file combining all theorems in that category

See [`Theorems/CATALOG.md`](Theorems/CATALOG.md) for the full catalog with file counts, theorem counts, and directory mapping.

### Categories at a Glance

| Category | Files | Theorems | Highlights |
|----------|------:|--------:|------------|
| [Algebra](Theorems/Algebra/) | 27 | 357 | Lagrange's theorem, Galois theory, Cayley-Dickson, Langlands |
| [Analysis](Theorems/Analysis/) | 12 | 104 | Real/complex analysis, spectral theory, Fourier |
| [Applications](Theorems/Applications/) | 33 | 360 | DeFi/AMM, neural networks, prediction, planning |
| [CategoryTheory](Theorems/CategoryTheory/) | 5 | 28 | Yoneda, adjunctions, K-theory |
| [Combinatorics](Theorems/Combinatorics/) | 8 | 72 | Ramsey, Sauer-Shelah, matroids |
| [Exploration](Theorems/Exploration/) | 128 | 2,220 | Cross-domain synthesis, speculative theories |
| [Factoring](Theorems/Factoring/) | 18 | 315 | IOF, Fermat, A*, quaternion methods |
| [Foundations](Theorems/Foundations/) | 58 | 910 | Holographic proofs, universal solvers, Gödel |
| [Geometry](Theorems/Geometry/) | 92 | 1,793 | Pythagorean trees, stereographic projection |
| [InformationTheory](Theorems/InformationTheory/) | 16 | 238 | Entropy, coding, cryptography, ZK proofs |
| [Logic](Theorems/Logic/) | 8 | 83 | Set theory, model theory, P vs NP |
| [NumberTheory](Theorems/NumberTheory/) | 30 | 335 | Primes, FLT, Riemann, elliptic curves |
| [OracleTheory](Theorems/OracleTheory/) | 76 | 1,459 | Meta-oracle, spectral oracle, God oracle |
| [Physics](Theorems/Physics/) | 47 | 1,140 | GEM, spacetime, photon theory, cosmology |
| [Probability](Theorems/Probability/) | 6 | 36 | Measure theory, stochastic processes |
| [Quantum](Theorems/Quantum/) | 46 | 1,002 | Gates, circuits, error correction, crypto attacks |
| [Topology](Theorems/Topology/) | 11 | 120 | Knot theory, Hodge theory, symplectic |
| [TropicalGeometry](Theorems/TropicalGeometry/) | 33 | 1,023 | Tropical semirings, NN compilation |

## Building

```bash
lake build
```

## Original Source Directories

The original source directories are preserved alongside the organized `Theorems/` directory for reference. See `Theorems/CATALOG.md` for the mapping from original directories to new categories.
