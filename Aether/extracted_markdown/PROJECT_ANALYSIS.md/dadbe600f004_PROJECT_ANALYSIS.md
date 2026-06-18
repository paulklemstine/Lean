# Project Analysis: Biggest Unsolved Questions

## Project Overview

This is a massive Lean 4 formalization project containing **682 Lean files** (~139,500 lines of code) spanning 17 top-level directories covering algebra, analysis, category theory, combinatorics, computation, cryptography, geometry, information theory, logic/foundations, machine learning, number theory, physics, probability, topology, tropical geometry, and speculative/exploratory mathematics.

The project is remarkably clean: **only 1 actual `sorry` exists in the codebase** (the rest are in comments). The vast majority of theorems are fully machine-verified.

---

## The Single Unsolved Proof in Code

### 1. Fermat's Last Theorem (Full) — `NumberTheory/NumberTheory__FermatLastTheorem.lean:172`

```lean
theorem fermat_last_theorem_full : FermatLastTheorem' := by
  sorry
```

**What it states:** For all n ≥ 3, there are no positive integers a, b, c with aⁿ + bⁿ = cⁿ.

**What IS proved:** The cases n = 3 (Euler) and n = 4 (Fermat's infinite descent) are fully verified, as is the reduction to prime exponents. Only the general case remains sorry'd.

**Why it's open:** The full proof (Wiles-Taylor, 1995) requires modularity of elliptic curves, Galois representations, and deformation theory — none of which are in Mathlib yet. The Lean formalization of Wiles' proof is an ongoing multi-year community project. This is the single hardest open formalization challenge in the entire project.

**Difficulty: Extreme** — This is effectively waiting on a major Mathlib infrastructure project, not something solvable by a single proof attempt.

---

## Major Open Mathematical Questions Explored (Without Sorry)

The project formalizes *partial results* and *surrounding infrastructure* for many famous open problems. While these don't have `sorry` in code (they prove what they can and state the rest as definitions/structures), they represent the intellectual frontiers of the project:

### 2. Millennium Prize Problems

The project has extensive files exploring all seven Millennium Problems:

- **P vs NP** (`Logic_and_Foundations/Logic__PvsNP.lean`, `Speculative_and_Exploratory/Millennium__PvsNP.lean`) — SAT satisfiability examples, search space bounds, but no separation result.
- **Riemann Hypothesis** (`NumberTheory/RiemannHypothesis__RiemannHypothesis.lean`, `NumberTheory/IntegerEnergy__RiemannConnection.lean`) — Zeta partial sums, prime counting verification, Euler product factors, but no proof of RH.
- **Birch and Swinnerton-Dyer Conjecture** (`CategoryTheory/LanglandsProgram__LFunctions.lean`, `Speculative_and_Exploratory/Millennium__EllipticCurves.lean`) — L-function infrastructure, elliptic curve torsion points, but BSD itself is stated as a structure field, not proved.
- **Yang-Mills Existence and Mass Gap** (`Speculative_and_Exploratory/Exploration__MillenniumProblems.lean`) — Basic matrix eigenvalue results only.
- **Navier-Stokes** (`Speculative_and_Exploratory/Millennium__NavierStokes.lean`) — Sobolev exponent calculations, dimensional analysis.
- **Hodge Conjecture** — Genus calculations for plane curves, Betti numbers.
- **Poincaré Conjecture** (solved by Perelman) — Euler characteristic calculations, surface classification.

### 3. Pythagorean Tree Factoring — Open Problems 7.1–7.5

A major research thread (`Pythagorean/` directory, 30+ files) explores using the Berggren tree of Pythagorean triples for integer factoring:

- **Open Problem 7.1:** Can the tree sieve break the exponential barrier? (Partial: leg product bounds proved)
- **Open Problem 7.2:** Is there a shortcut through hyperbolic space? (Partial: Berggren lattice structural properties)
- **Open Problem 7.4:** Relation to existing factoring algorithms (Partial: quadratic sieve connection formalized)
- **Complexity bounds, nontrivial shortcuts, parallel descent, Lorentz structure exploitation, higher-dimensional generalization** — all have dedicated files with partial results.

### 4. Langlands Program

(`CategoryTheory/LanglandsProgram__*.lean`) — L-function infrastructure, Hecke eigenvalues, Selberg class axioms, symmetric power functoriality status tracking. The Langlands reciprocity conjecture itself is not formally stated as a theorem.

### 5. Goldbach Conjecture

Verified for small cases (4–20) via explicit witness construction. The general conjecture is not stated or attempted.

### 6. Twin Prime Conjecture

Prime gap bounds and Bertrand's postulate consequences proved, but the twin prime conjecture itself is not attempted.

### 7. Collatz Conjecture

Base cases verified computationally. The general conjecture is explored but not formally stated as a theorem to prove.

### 8. ABC Conjecture

Quality bound examples computed. The conjecture itself is not formally attempted.

---

## Speculative/Exploratory Open Directions

### 9. Tropical Geometry for Neural Network Compilation
(`Tropical/` — 20+ files) — Extensive formalization of tropical semirings and their application to neural network compilation, LLM conversion, and oracle research. Many structural theorems proved, but the core question of whether tropical methods yield practical ML compilation advantages remains open.

### 10. Arithmetic Photons & Discrete Spacetime
(`Physics/ArithmeticPhotons__OpenQuestions.lean`) — Four open questions about photon graphs:
1. Is the photon graph connected?
2. Do photon directions equidistribute?  
3. What is the quantum version?
4. Can we hear the shape of discrete spacetime?
Parity constraints and spatial connectivity results proved; full answers remain open.

### 11. Channel 5 Sedenion Conjectures
(`Algebra/Algebra__Channel5Sedenions.lean`) — Four new conjectures about OAM-cusp correspondence, Channel 5 signatures, interference patterns, and sedenion-Standard Model connections.

### 12. Gazing Pool Conjecture — RESOLVED ✓
(`Speculative_and_Exploratory/GazingPool__GazingPoolOpenQuestions.lean`) — Six open questions posed and all resolved, including the main conjecture that every gazing pool on a finite type has a periodic point (proved via the pigeonhole principle).

---

## Summary: Ranked by Significance

| Rank | Problem | Status | File(s) |
|------|---------|--------|---------|
| 1 | **Fermat's Last Theorem (full)** | `sorry` in code | `NumberTheory/NumberTheory__FermatLastTheorem.lean` |
| 2 | **Riemann Hypothesis** | Partial results only | `NumberTheory/RiemannHypothesis__*.lean` |
| 3 | **P vs NP** | Examples only | `Logic_and_Foundations/Logic__PvsNP.lean` |
| 4 | **BSD Conjecture** | Infrastructure only | `CategoryTheory/LanglandsProgram__LFunctions.lean` |
| 5 | **Langlands Reciprocity** | Infrastructure only | `CategoryTheory/LanglandsProgram__*.lean` |
| 6 | **Pythagorean Tree Factoring** | Partial results | `Pythagorean/Pythagorean__ThreeRoads__*.lean` |
| 7 | **Yang-Mills / Navier-Stokes** | Dimensional analysis only | `Speculative_and_Exploratory/Millennium__*.lean` |
| 8 | **Goldbach / Twin Primes / Collatz** | Small cases only | `Speculative_and_Exploratory/Millennium__MillenniumFrontier.lean` |
| 9 | **Tropical NN Compilation** | Structural theory | `Tropical/` directory |
| 10 | **Arithmetic Photon Questions** | Partial answers | `Physics/ArithmeticPhotons__OpenQuestions.lean` |

**Bottom line:** The project is exceptionally well-maintained with only one `sorry` — Fermat's Last Theorem for general n — which depends on the ongoing community formalization of Wiles' proof. All other "open questions" are famous unsolved mathematical problems where the project correctly formalizes partial results and surrounding infrastructure rather than claiming proofs.
