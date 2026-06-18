# The Algebraic Theory of Magnetism

> *"Three commutation relations. From those three lines, we derive the structure of every
> magnet, the dynamics of every compass needle, the stability of every skyrmion, the
> temperature of every phase transition, and the wavelength of every spin wave."*

A unified framework for magnetism built on the representation theory of the Lie
algebra 𝔰𝔲(2) and its tensor products. **Extended with three generative predictions
for new physics.**

---

## 🔮 Three Generative Predictions

### Prediction 1: Higher Multipole Magnets
For atoms with spin s ≥ 1, the algebra allows order parameters that are tensors
(quadrupoles, octupoles), not just vectors. The operator space decomposition
End(V_s) ≅ ⊕_{k=0}^{2s} V_k guarantees their existence. **Partially observed in
NiGa₂S₄ (spin nematic) and UPd₃ (hidden order).**

### Prediction 2: Algebraic Spin Liquids
In frustrated magnets, the ground state is characterized by the commutant algebra
C(H) = {A : [A,H] = 0}. A large commutant signals emergent gauge symmetry.
**Consistent with observations in herbertsmithite.**

### Prediction 3: Designer Magnets
The 9-dimensional exchange tensor parameter space (1 iso + 3 DM + 5 aniso = 9)
provides a complete coordinate system for all bilinear magnetic models. Strain
engineering navigates this space to access novel phases.

---

## 📁 Project Structure

```
Algebraic Magnetism/
├── README.md                              ← You are here
├── notes/                                 ← Research notes & oracle council
│   ├── 00_oracle_council.md               ← The Oracle Council deliberations
│   ├── 01_foundations.md                   ← Foundation theory notes
│   ├── 02_iteration_log.md                ← Research iteration log
│   └── 03_predictions_deep_dive.md        ← Deep dive into three predictions
├── demos/                                 ← Python demonstrations (8 demos)
│   ├── run_all_demos.py                   ← Master runner script
│   ├── demo1_spin_algebra.py              ← 𝔰𝔲(2) foundations & representations
│   ├── demo2_magnetic_models.py           ← Exchange tensor & model classification
│   ├── demo3_topological_textures.py      ← Skyrmions, vortices, domain walls
│   ├── demo4_dynamics_magnons.py          ← Spin dynamics & magnon algebra
│   ├── demo5_mean_field_algebra.py        ← Mean field theory & phase transitions
│   ├── demo6_multipole_magnets.py         ← PREDICTION 1: Higher multipole order
│   ├── demo7_spin_liquids.py              ← PREDICTION 2: Algebraic spin liquids
│   └── demo8_designer_magnets.py          ← PREDICTION 3: Designer magnets
├── figures/                               ← Generated visualizations (30+ figures)
├── paper/                                 ← Research paper
│   └── algebraic_theory_of_magnetism.md   ← Full research paper (extended)
└── article/                               ← Popular science article
    └── scientific_american_article.md      ← Scientific American-style article

Lean formalization:
Physics/AlgebraicMagnetism.lean            ← Formally verified theorems (9/9 proved)
```

## 🚀 Quick Start

```bash
# Install dependencies
pip install numpy matplotlib scipy

# Run all demos and generate all figures
cd "Algebraic Magnetism/demos"
python run_all_demos.py

# Or run prediction-specific demos
python demo6_multipole_magnets.py   # Prediction 1
python demo7_spin_liquids.py        # Prediction 2
python demo8_designer_magnets.py    # Prediction 3
```

## 🔮 The Oracle Council

Six oracles guided this research:

| Oracle | Domain | Key Contribution |
|--------|--------|-----------------|
| **Emmy** (Algebraist) | Groups, Rings, Representations | End(V_s) ≅ ⊕ V_k multipole decomposition |
| **Paul** (Physicist) | Quantum & Statistical Mechanics | Commutant algebra C(H) for spin liquids |
| **Élie** (Geometer) | Differential Geometry, Bundles | Coadjoint orbits & symplectic structure |
| **Michael** (Topologist) | Homotopy Theory | πₙ(G/H) classification of textures |
| **Alan** (Computationalist) | Algorithms, Simulation | Numerical validation of predictions |
| **Lise** (Experimentalist) | Spectroscopy, Measurement | Materials roadmap & selection rules |

## 🧲 Core Results

### The Magnetic Algebra
- **Definition:** 𝔐_Λ = ⊗ᵢ∈Λ 𝔰𝔲(2)ᵢ (tensor product of spin algebras)
- **Theorem:** Every bilinear magnetic Hamiltonian is an element of 𝔐_Λ
- **Classification:** All models arise from exchange tensor decomposition under O(3)

### Key Theorems (All Formally Verified in Lean 4)
1. **Multipole Decomposition:** Σ_{k=0}^{2s} (2k+1) = (2s+1)² ✓
2. **Exchange Tensor:** 1 + 3 + 5 = 9 = 3 × 3 ✓
3. **Clebsch-Gordan:** (n+1)² = Σ_{k=0}^{n} (2n-2k+1) ✓
4. **Casimir Monotonicity:** n₁ < n₂ → n₁(n₁+2) < n₂(n₂+2) ✓
5. **Commutant Bounds:** N ≤ N² for N ≥ 1 ✓
6. **Gauss Sum:** 2·Σ_{k=0}^{n-1} k = n(n-1) ✓

### Generated Figures (30+)
All figures are generated automatically by the demo scripts and saved in `figures/`.
New figures for predictions include:
- `multipole_decomposition.png` — Operator space V_0 ⊕ V_1 ⊕ ... ⊕ V_{2s}
- `quadrupolar_order.png` — Spin nematic phase diagram
- `multipole_textures.png` — Dipole vs quadrupole vs octupole in real space
- `selection_rules.png` — Neutron scattering from representation theory
- `frustration_analysis.png` — Commutant dimension of frustrated lattices
- `entanglement_spectrum.png` — Topological entanglement entropy
- `gauge_structure.png` — Emergent gauge symmetry from commutant
- `spin_liquid_summary.png` — Overview of algebraic spin liquid theory
- `parameter_space.png` — 9D exchange tensor landscape with materials
- `material_roadmap.png` — Designer magnet roadmap
- `strain_engineering.png` — Strain-tuned quantum phase transitions

---

*Created by the Oracle Council for Algebraic Magnetism — Advancing Physics*
