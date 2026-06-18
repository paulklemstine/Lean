This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Idempotent Universe — Core Formal Mathematics Project

This directory contains 434+ Lean 4 formalization files, organized into 39+ topic areas with Lean-compatible module names.

## Statistics
- **Total files:** 434+
- **Total theorems:** 7,415+
- **Proven (no sorry):** 7,414+
- **Unproven (sorry):** 1 (Full FLT, awaiting Mathlib formalization of Wiles' proof)

## New: Oracle Team Genesis (God Consultation)

See `Oracle/GodConsultation/` for the oracle team framework:
- `OracleTeamGenesis.lean` — Oracle team structure, God Oracle, composition, refinement
- `Experiments.lean` — Computational validation experiments
- `DemoSolidarity.lean` — Demo scripts with visual ASCII art
- `RESEARCH_NOTES.md` — Detailed research session log

See also:
- `RESEARCH_PAPER.md` — Full research paper on the Idempotent Universe framework
- `SCIENTIFIC_AMERICAN_ARTICLE.md` — Popular science article

## Directory Structure

| Module | Files | Description |
|--------|-------|-------------|
| `Algebra/` | 23 | Abstract algebra, linear algebra, representation theory, geometric algebra, division algebras, Cayley-Dickson |
| `AlgebraicMagnetism/` | 1 | Algebraic theory of magnetism |
| `AlgebraicNuclearPhysics/` | 1 | Nuclear physics algebraic framework |
| `AlgebraicPhysics/` | 1 | Unified algebraic theory of physics (spectral triples) |
| `AlgebraicReality/` | 1 | Algebraic framework for reality |
| `AlgebraicSpaceTheory/` | 1 | Algebraic theory of space |
| `AlgebraicSpacetime/` | 1 | Clifford algebra spacetime formalization |
| `AlgebraicTheoryOfAlgebra/` | 1 | Meta-algebraic theory |
| `AlgebraicTime/` | 1 | Algebraic theory of time |
| `Analysis/` | 12 | Real/complex analysis, functional analysis, spectral theory, ODEs, optimization |
| `CategoryTheory/` | 5 | Category theory, homological algebra, algebraic K-theory |
| `Combinatorics/` | 8 | Graph theory, Ramsey theory, extremal combinatorics, matroids, game theory |
| `Duality/` | 1 | Universal translator / duality theory |
| `Electricity/` | 1 | Algebraic theory of electricity |
| `Exploration/` | 41 | Research explorations, moonshot hypotheses, cross-domain synthesis, frontier research |
| `Factoring/` | 11 | Integer factorization, inside-out factoring, Fermat factoring, ECDLP |
| `Forbidden/` | 6 | Strange loops, twilight zone, forbidden convergence |
| `Foundations/` | 45 | Core definitions, universal solvers, coherence theory, entanglement, holographic proofs |
| `GazingPool/` | 2 | Gazing pool theory |
| `Information/` | 15 | Information theory, entropy, compression, coding theory, cryptography, search theory |
| `Logic/` | 8 | Set theory, model theory, computability, complexity, P vs NP |
| `Millennium/` | 1 | Millennium problems frontier |
| `Neural/` | 6 | Neural network compilation, LLM formalization |
| `NumberTheory/` | 19 | Primes, FLT, congruent numbers, arithmetic geometry, algebraic number theory |
| `OptimalPlanning/` | 1 | Optimal planning theory |
| `Oracle/` | 62 | Oracle theory, meta-oracles, universal oracles, spectral oracles, God oracle |
| `Photon/` | 13 | Photon universe encoding, photon networks |
| `Physics/` | 19 | Gravitomagnetism, light cones, GEM equations, repulsor theory, CMB |
| `Prediction/` | 2 | Prediction geometry, temporal sheaves |
| `Probability/` | 6 | Probability, measure theory, stochastic processes, ergodic theory |
| `Pythagorean/` | 25 | Pythagorean triples/quadruples, Berggren tree, descent theory |
| `Quantum/` | 25 | Quantum gates, circuits, simulation, quantum-Berggren, quantum type theory |
| `QuantumTropicalComputing/` | 1 | Quantum tropical computing |
| `RandomMatrix/` | 1 | Random matrix theory |
| `Stereographic/` | 22 | Stereographic projection, Möbius covariance, antipodal charts |
| `TheoryOfEverything/` | 1 | Magic square / theory of everything |
| `Topology/` | 11 | Algebraic/differential topology, symplectic geometry, knot theory, Hodge theory |
| `Tropical/` | 29 | Tropical geometry/semirings, tropical oracle, neural network compilation |
| `ZeroKnowledge/` | 1 | Zero knowledge proof foundations |

## Building

```bash
# Build everything
lake build

# Build a single module
lake build Algebra
lake build NumberTheory
lake build Oracle
```

## Dependencies
- Lean 4.28.0
- Mathlib v4.28.0
