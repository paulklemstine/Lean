This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# RequestProject — Consolidated Structure

This project contains formalized mathematics across 20 thematic directories.

## Directory Structure

| Directory | Files | Description |
|-----------|-------|-------------|
| `Algebra/` | 23 | Abstract algebra, linear algebra, representation theory, geometric algebra, division algebras, Cayley-Dickson constructions |
| `Analysis/` | 12 | Real/complex analysis, functional analysis, harmonic analysis, spectral theory, differential equations, optimization |
| `CategoryTheory/` | 5 | Category theory, homological algebra, algebraic K-theory |
| `Combinatorics/` | 8 | Graph theory, Ramsey theory, extremal combinatorics, matroid theory, game theory, Sauer-Shelah |
| `Exploration/` | 39 | Research explorations, moonshot hypotheses, cross-domain synthesis, frontier research, millennium problems |
| `Factoring/` | 11 | Integer factorization methods, inside-out factoring, Fermat factoring, ECDLP |
| `Foundations/` | 43 | Core definitions, foundational theorems, universal solvers, coherence theory, entanglement, holographic proofs |
| `Information/` | 15 | Information theory, entropy, compression, coding theory, cryptography, search theory |
| `Logic/` | 8 | Set theory, model theory, descriptive set theory, computability, complexity theory, P vs NP |
| `Neural/` | 6 | Neural network compilation, LLM formalization, neural architecture search |
| `NumberTheory/` | 19 | Prime theory, Fermat's Last Theorem, congruent numbers, arithmetic geometry, algebraic number theory, Montgomery pair correlation |
| `Oracle/` | 45 | Oracle theory, meta-oracles, universal oracles, spectral oracles, algorithmic oracles |
| `Photon/` | 13 | Photon universe encoding, photon networks, photonic frontier research |
| `Physics/` | 19 | Gravitomagnetism, light cones, GEM equations, repulsor theory, CMB landscape, timeline gravity |
| `Probability/` | 5 | Probability theory, measure theory, stochastic processes, ergodic theory |
| `Pythagorean/` | 25 | Pythagorean triples/quadruples, Berggren tree, descent theory, sum-of-squares filtering |
| `Quantum/` | 25 | Quantum gates, circuits, foundations, simulation, quantum-Berggren connections, quantum type theory |
| `Stereographic/` | 15 | Stereographic projection, inverse stereographic maps, Möbius covariance, antipodal charts |
| `Topology/` | 11 | General/algebraic topology, differential geometry, symplectic geometry, knot theory, Hodge theory |
| `Tropical/` | 26 | Tropical geometry/semirings, tropical oracle formalization, tropical neural network compilation |
| **Total** | **373** | |

## Building

```bash
lake build  # builds all targets
lake build Algebra  # builds only the Algebra library
lake build NumberTheory.FLT4  # builds a single module
```

## Changes from Consolidation

- **Organized** 375 root-level files into 20 thematic subdirectories
- **Removed** 2 duplicate files (`AntipodalChart (2).lean`, `UniversalOracleTeam (2).lean`)
- **Fixed** 21 broken cross-file imports (commented out references to non-existent module paths)
- **Updated** `lakefile.toml` to use directory-based `lean_lib` entries with glob patterns
