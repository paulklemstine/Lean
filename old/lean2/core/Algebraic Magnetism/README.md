# The Algebraic Theory of Magnetism

> *"Three commutation relations. From those three lines, we derive the structure of every
> magnet, the dynamics of every compass needle, the stability of every skyrmion, the
> temperature of every phase transition, and the wavelength of every spin wave."*

A unified framework for magnetism built on the representation theory of the Lie
algebra 𝔰𝔲(2) and its tensor products.

---

## 📁 Project Structure

```
algebraic_magnetism/
├── README.md                          ← You are here
├── notes/                             ← Research notes & iteration logs
│   ├── 00_oracle_council.md           ← The Oracle Council deliberations
│   ├── 01_foundations.md              ← Foundation theory notes
│   └── 02_iteration_log.md           ← Research iteration log
├── demos/                             ← Python demonstrations with visuals
│   ├── run_all_demos.py              ← Master runner script
│   ├── demo1_spin_algebra.py          ← 𝔰𝔲(2) foundations & representations
│   ├── demo2_magnetic_models.py       ← Exchange tensor & model classification
│   ├── demo3_topological_textures.py  ← Skyrmions, vortices, domain walls
│   ├── demo4_dynamics_magnons.py      ← Spin dynamics & magnon algebra
│   └── demo5_mean_field_algebra.py    ← Mean field theory & phase transitions
├── figures/                           ← Generated visualizations (19 figures)
│   ├── spin_matrices.png             ← Spin operator matrices for s=1/2,1,3/2,2
│   ├── casimir_spectrum.png          ← Representation theory & Clebsch-Gordan
│   ├── commutation_check.png         ← Numerical verification of [Si,Sj]=iεSk
│   ├── bloch_sphere.png             ← Coadjoint orbit S² visualization
│   ├── exchange_tensors.png          ← Exchange tensor decomposition for all models
│   ├── two_site_spectra.png          ← Energy spectra comparing models
│   ├── algebraic_phase_diagram.png   ← Phase diagram in algebraic parameter space
│   ├── model_interpolation.png       ← Continuous interpolation between models
│   ├── skyrmions.png                ← Magnetic skyrmion textures (Q = ±1, ±2)
│   ├── vortices.png                 ← XY model vortices (winding ±1, ±2)
│   ├── domain_walls.png             ← Ising/Bloch/Néel domain walls
│   ├── topological_classification.png ← Classification table of defects
│   ├── spin_dynamics.png            ← Precession on coadjoint orbits
│   ├── magnon_dispersions.png        ← Magnon dispersion relations
│   ├── bloch_law.png               ← Bloch's T^{3/2} law from magnon DOS
│   ├── spin_waves.png              ← Spin wave visualizations
│   ├── mean_field_transition.png     ← Algebraic mean field phase transition
│   └── exact_vs_mean_field.png      ← Validation: exact diag vs mean field
├── paper/                             ← Research paper
│   └── algebraic_theory_of_magnetism.md  ← Full research paper
└── article/                           ← Popular science article
    └── scientific_american_article.md     ← Scientific American-style article
```

## 🚀 Quick Start

```bash
# Install dependencies
pip install numpy matplotlib scipy

# Run all demos and generate all figures
cd demos
python run_all_demos.py

# Or run individual demos
python demo1_spin_algebra.py          # Foundations
python demo2_magnetic_models.py       # Model classification
python demo3_topological_textures.py  # Topology
python demo4_dynamics_magnons.py      # Dynamics
python demo5_mean_field_algebra.py    # Phase transitions
```

## 🔮 The Oracle Council

Six oracles guided this research:

| Oracle | Domain | Key Contribution |
|--------|--------|-----------------|
| **Emmy** (Algebraist) | Groups, Rings, Representations | Magnetic algebra 𝔐_Λ = ⊗ 𝔰𝔲(2) |
| **Paul** (Physicist) | Quantum & Statistical Mechanics | Universal Hamiltonian from exchange tensor |
| **Élie** (Geometer) | Differential Geometry, Bundles | Coadjoint orbits & symplectic structure |
| **Michael** (Topologist) | Homotopy Theory | πₙ(G/H) classification of textures |
| **Alan** (Computationalist) | Algorithms, Simulation | Symmetry-adapted exact diagonalization |
| **Lise** (Experimentalist) | Spectroscopy, Measurement | Selection rules & observable predictions |

## 🧲 Core Results

### The Magnetic Algebra
- **Definition:** 𝔐_Λ = ⊗ᵢ∈Λ 𝔰𝔲(2)ᵢ (tensor product of spin algebras)
- **Theorem:** Every bilinear magnetic Hamiltonian is an element of 𝔐_Λ
- **Classification:** All models arise from exchange tensor decomposition under O(3)

### Key Theorems
1. **Model Classification:** Ising, XY, Heisenberg, Kitaev, DM models are algebraic quotients
2. **Phase Classification:** Order parameters are algebra homomorphisms φ: 𝔐 → 𝔄
3. **Topological Classification:** Defects classified by πₙ(G/H) from algebraic data
4. **Dynamics:** Landau-Lifshitz = Hamiltonian flow on coadjoint orbit S²
5. **Magnons:** Holstein-Primakoff = algebra homomorphism 𝔰𝔲(2) → Weyl algebra
6. **Curie Temperature:** Tc = zJs(s+1)/3 — determined by the Casimir eigenvalue

## 📊 Generated Figures

All 19 figures are generated automatically by the demo scripts and saved in `figures/`.
They cover:
- Representation theory of 𝔰𝔲(2) (4 figures)
- Exchange tensor classification (4 figures)
- Topological textures: skyrmions, vortices, walls (4 figures)
- Spin dynamics and magnon physics (4 figures)
- Mean field theory and validation (2 figures)
- Master classification table (1 figure)

## 📝 Publications

- **Research Paper:** `paper/algebraic_theory_of_magnetism.md` — Full technical treatment
- **Popular Article:** `article/scientific_american_article.md` — Accessible overview

---

*Created by the Oracle Council for Algebraic Magnetism*
