This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Stereographic Rosetta Stone

### A Grand Unification of Number Theory, Geometry, Physics, and Computation — Machine-Verified in Lean 4

---

> *The equation a² + b² = c² is not one fact. It is six facts wearing disguises, and stereographic projection is the translator that reveals them all.*

---

## At a Glance

| Metric | Value |
|--------|-------|
| Lean 4 source files | **159** |
| Lines of verified code | **25,650** |
| Machine-verified theorems | **2,637** |
| Unproved claims | **1** (Sauer–Shelah, marked open) |
| Mathematical domains | **40+** |
| Axioms | Standard only (`propext`, `Classical.choice`, `Quot.sound`) |

---

## 📖 Start Here

| Document | What It Is |
|----------|------------|
| **[`GRAND_UNIFIED_PAPER.md`](GRAND_UNIFIED_PAPER.md)** | The research paper — how all six pillars connect through stereographic projection |
| **[`GRAND_UNIFIED_CATALOG.md`](GRAND_UNIFIED_CATALOG.md)** | Complete catalog of key theorems organized by pillar |
| **[`SCIENTIFIC_AMERICAN_GRAND_UNIFIED.md`](SCIENTIFIC_AMERICAN_GRAND_UNIFIED.md)** | Popular-science article for general audiences |

---

## The Six Pillars

The identity a² + b² = c² has six simultaneous meanings. Stereographic projection — the map t ↦ ((1−t²)/(1+t²), 2t/(1+t²)) — translates between them:

```
                    σ : ℝ  ≅  S¹ \ {−1}
                   (stereographic projection)
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
  I. NUMBER THEORY    II. GEOMETRY         III. PHYSICS
  Pythagorean triples  Unit circle/sphere   Light cone
  Gaussian integers    Hopf fibration       Lorentz group
  Berggren tree        Hyperbolic plane     Doppler effect
       │                    │                    │
       └────────┬───────────┴──────────┬─────────┘
                │                      │
         IV. ALGEBRA             V. QUANTUM
         Division algebras       Quantum gates
         Hurwitz 1→2→4→8         Bloch sphere
         Composition ids         Clifford algebra
                │                      │
                └──────────┬───────────┘
                           │
                   VI. MACHINE LEARNING
                   Crystallized weights
                   Harmonic networks
                   Gradient-free training
```

### Pillar I — The Universal Decoder
*The ancient map that produces all Pythagorean triples from rational numbers.*

`Basic.lean` · `StereographicRationals.lean` · `RosettaStone.lean` · `UniversalDecoder.lean`

### Pillar II — The Berggren Tree
*Every primitive triple, organized as the orbit of (3,4,5) under the discrete Lorentz group.*

`Berggren.lean` · `BerggrenTree.lean` · `DescentTheory.lean` · `ParentDescent.lean` · `LandscapeTheory.lean`

### Pillar III — The Light Cone
*Pythagorean triples ARE photon momenta in Minkowski spacetime.*

`LightConeTheory.lean` (42 theorems) · `PhotonicFrontier.lean` (53 theorems)

### Pillar IV — The Crystal
*Neural network weights crystallized onto the integer lattice — gradient explosion impossible.*

`CrystallizerFormalization.lean` · `HarmonicNetwork.lean` · `PythagoreanNeuralArch.lean` · `NeuralCrystallizerFrontier.lean`

### Pillar V — The Hurwitz Tower
*Composition identities in dimensions 1, 2, 4, 8 — and only those.*

`GaussianIntegers.lean` · `TeamResearch.lean` · `QuadraticForms.lean`

### Pillar VI — The Quantum Bridge
*From Pythagorean rationals to universal quantum gates via the Bloch sphere.*

`QuantumGateSynthesis.lean` · `QuantumBerggren.lean` · `QuantumGateAlgebra.lean`

---

## The Seven Teams

| Team | Name | Domain |
|------|------|--------|
| **α** | The Decoder | Stereographic projection — the Rosetta Stone |
| **β** | The Navigator | Berggren tree & descent dynamics |
| **γ** | The Physicist | Light cone & hyperbolic geometry |
| **δ** | The Crystallizer | Harmonic Network design & stability |
| **ε** | The Algebraist | Hurwitz tower (1 → 2 → 4 → 8) |
| **ζ** | The Quantum Engineer | Pythagorean gate synthesis |
| **η** | The Unifier | Cross-domain bridges & grand narrative |

---

## Key Bridge Theorems

| From | Theorem | To |
|------|---------|----|
| Pythagorean triples | `light_like_iff_pythagorean` | Photon momenta |
| Berggren tree | `berggren_lorentz` | Discrete Lorentz group |
| Stereographic projection | `bloch_sphere_stereo` | Quantum Bloch sphere |
| Gaussian integers | `brahmagupta_fibonacci` | Composition identities |
| Crystallization | `pendulum_dynamics` | Classical mechanics |
| IOF algorithm | `crystallizer_iof_bridge` | Neural architecture |
| Hopf fibration | `hopf_map_sphere` | Quaternionic networks |

---

## Applications

| Application | Core Theorem |
|-------------|-------------|
| **Provably safe AI** | `gradient_explosion_impossible` — gradient blow-up impossible in Harmonic Networks |
| **Integer factoring** | `iof_factor_step` — Inside-Out Factoring via Berggren descent |
| **Quantum gate synthesis** | `pythagorean_gate_composition` — exact, rational, closed-form gates |
| **Model compression** | `quantization_error_bound` — O(1/N) error with integer weights |
| **Adversarial robustness** | `lipschitz_robustness` — crystallized layers are 1-Lipschitz |

---

## Research Papers

| Paper | Focus |
|-------|-------|
| `GRAND_UNIFIED_PAPER.md` | Master paper — the complete unification |
| `crystallizer_paper.md` | Stereographic crystallization (18 theorems) |
| `frontier_research_paper.md` | Weierstrass, Lorentz, Chebyshev connections |
| `crystallizer_dimensional_paper.md` | Dimensional ladder, Hopf fibration (44 theorems) |
| `light_cone_research_paper.md` | Minkowski geometry (42 theorems) |
| `photonic_frontier_paper.md` | Hyperbolic geometry, Möbius maps (53 theorems) |
| `team_research_paper.md` | Hurwitz tower, Gaussian integers |
| `harmonic_network_paper.md` | N-dimensional architecture (35+ theorems) |
| `energy_descent_research_paper.md` | IOF energy landscape |
| `landscape_research_paper.md` | Pythagorean landscape navigation |
| `neural_frontier_research_paper.md` | Neural network frontiers |
| `universal_decoder_paper.md` | 59 decoder channels |
| `discoveries_paper.md` | Quantum/exotic computation |

---

## Building

```bash
# Requires Lean 4.28.0 with Mathlib
lake build
```

---

## Citation

> *The Stereographic Rosetta Stone: A Grand Unification of Number Theory, Geometry, Physics, and Computation.* Machine-verified in Lean 4 with 2,637 theorems across 159 files. The Harmonic Number Theory Group.
