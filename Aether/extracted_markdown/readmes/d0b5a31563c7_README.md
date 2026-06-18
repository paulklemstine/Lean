This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Algebraic Theory of Physics

> *Physics is Algebra. Algebra is Physics.*

A comprehensive exploration of the thesis that all of fundamental physics emerges from algebraic structures, centered on Connes' spectral triple **(A, H, D)**.

## Project Structure

```
├── notes/                          # Oracle Council research notes
│   ├── 00_oracle_council.md        # Full deliberations of the 7 oracles
│   ├── 01_pillar_observable_algebras.md  # C*-algebras and quantum observables
│   ├── 02_pillar_symmetry_algebras.md    # Lie algebras and particle physics
│   └── 03_pillar_spacetime_algebra.md    # Clifford algebras and spacetime
│
├── demos/                          # Python demo scripts with visualizations
│   ├── demo1_bloch_sphere.py       # Qubit as C*-algebra M₂(ℂ)
│   ├── demo2_lie_algebras.py       # SU(3) and the Eightfold Way
│   ├── demo3_clifford_algebra.py   # Clifford algebra Cl(1,3) and spacetime
│   ├── demo4_spectral_triple.py    # Spectral triples and the Standard Model
│   └── demo5_unification.py        # Grand unification diagram + timeline
│
├── figures/                        # Generated visualizations (PNG)
│   ├── demo1_bloch_sphere.png
│   ├── demo2_lie_algebras.png
│   ├── demo3_clifford_algebra.png
│   ├── demo4_spectral_triple.png
│   ├── demo5_unification.png
│   └── demo5_timeline.png
│
├── paper/                          # Research paper
│   └── algebraic_theory_of_physics.md
│
├── article/                        # Scientific American article
│   └── scientific_american_article.md
│
└── RequestProject/                 # Lean 4 formalizations
    └── AlgebraicPhysics.lean       # 17 proven theorems (0 sorry!)
```

## The Five Pillars

| Pillar | Structure | Physics |
|--------|-----------|---------|
| **I. Observable Algebras** | C*-algebras | Quantum observables, states, measurement |
| **II. Symmetry Algebras** | Lie algebras | Conservation laws, particle classification |
| **III. Spacetime Algebras** | Clifford algebras | Dirac equation, spinors, relativity |
| **IV. Gauge Algebras** | Connections on bundles | Electromagnetic, weak, strong forces |
| **V. Categorical Algebras** | Monoidal categories | Composition of physical processes |

## The Central Thesis

Every physical theory is a **spectral triple (A, H, D)**:
- **A** (algebra) = what can be observed
- **H** (Hilbert space) = what can exist
- **D** (Dirac operator) = how things change and how far apart they are

The Standard Model + Gravity emerges from:
- A = C∞(M) ⊗ (ℂ ⊕ ℍ ⊕ M₃(ℂ))
- The spectral action **S = Tr(f(D/Λ)) + ⟨ψ, Dψ⟩**

## Lean Formalization

17 theorems proven in Lean 4 with Mathlib, including:
- Lie bracket antisymmetry, Jacobi identity, self-annihilation
- Star algebra properties (involutivity, anti-multiplicativity)
- Clifford algebra defining relation (v² = Q(v)) and anticommutator
- Commutator Jacobi identity and double commutator expansion
- Lie homomorphism bracket preservation
- Linear map composition associativity

All proofs are machine-verified with zero `sorry` statements.

## Running the Demos

```bash
pip install matplotlib numpy
python demos/demo1_bloch_sphere.py
python demos/demo2_lie_algebras.py
python demos/demo3_clifford_algebra.py
python demos/demo4_spectral_triple.py
python demos/demo5_unification.py
```

## Building the Lean Proofs

```bash
lake build RequestProject.AlgebraicPhysics
```
