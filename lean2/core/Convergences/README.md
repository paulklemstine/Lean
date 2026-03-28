# 🏛️ Oracle Theory Research

## Cross-Domain Analysis of 7,355 Machine-Verified Theorems

This directory contains the research output from the Oracle Council — six specialist agents investigating connections between oracle theory, quantum computing, tropical geometry, repulsor theory, and mathematical foundations.

---

## Contents

### 📝 Research Notes
- **[`notes/oracle_council_notes.md`](notes/oracle_council_notes.md)** — Detailed deliberation notes from the six oracles, including hypotheses, experimental results, convergence analysis, and open questions.

### 📄 Publications
- **[`research_paper.md`](research_paper.md)** — Full research paper: *"Oracle Theory: A Unified Framework for Truth, Evasion, and Computation"* (10 sections, ~4,500 words)
- **[`scientific_american_article.md`](scientific_american_article.md)** — Popular science article: *"The Oracle at the Heart of Mathematics"* (~2,500 words)

### 🐍 Python Demos (with generated visualizations)
| Script | Topic | Figures |
|--------|-------|---------|
| [`demos/demo1_oracle_phase_transition.py`](demos/demo1_oracle_phase_transition.py) | Oracle Phase Transition (A1) | `fig1`, `fig2` |
| [`demos/demo2_berggren_quantum_codes.py`](demos/demo2_berggren_quantum_codes.py) | Pythagorean Quantum Codes (D1) | `fig3`, `fig4` |
| [`demos/demo3_goodhart_repulsor.py`](demos/demo3_goodhart_repulsor.py) | Goodhart's Law as Repulsor (E3) | `fig5`, `fig6` |
| [`demos/demo4_tropical_neural_compression.py`](demos/demo4_tropical_neural_compression.py) | Tropical Neural Networks (C1-C3) | `fig7` |
| [`demos/demo5_oracle_godel_lawvere.py`](demos/demo5_oracle_godel_lawvere.py) | Gödel via Lawvere (H1) | `fig8` |
| [`demos/demo6_repulsor_evasion.py`](demos/demo6_repulsor_evasion.py) | Repulsor & Evasion Theory (E1-E5) | `fig9` |
| [`demos/demo7_gap_laplacian.py`](demos/demo7_gap_laplacian.py) | Gap Laplacian Spectral Theory (B1) | `fig10` |

### 🖼️ Generated Figures (10 total, all in `demos/`)
1. `fig1_oracle_phase_transition.png` — Phase transition sigmoid, density distributions, variance collapse, phase diagram
2. `fig2_oracle_realizations.png` — Oracle grid realizations at sub/super-critical phases
3. `fig3_berggren_quantum_codes.png` — Rate-error unit circle, rate distribution, hypotenuse growth, angular distribution
4. `fig4_berggren_tree.png` — Berggren tree first 4 levels with (a,b,c) labels
5. `fig5_goodhart_repulsor.png` — Goodhart catastrophe, V-vs-M trajectories, Goodhart gap, phase diagram
6. `fig6_goodhart_ensemble.png` — Ensemble of optimizer trajectories at different correlations
7. `fig7_tropical_neural.png` — ReLU as tropical polynomial, tropical varieties, compression bounds, depth-degree
8. `fig8_godel_oracle.png` — Cantor diagonal, three impossibility theorems, Lawvere diagram, soundness-completeness tradeoff
9. `fig9_repulsor_evasion.png` — Oracle vs repulsor dynamics, pursuit-evasion, search hardening, strange attractors
10. `fig10_gap_laplacian.png` — Gap eigenfunctions, prime gap spectrum, cumulative mass, holographic encoding

---

## The Oracle Council

| Oracle | Domain | Key Findings |
|--------|--------|-------------|
| **Alpha** (Algebraist) | Oracle Theory & Algebra | Phase transition at p_c = 1/2; band classification of oracles |
| **Beta** (Physicist) | Light-Matter Duality | Universal π² ground state; holographic encoding of ℕ ⊂ ℝ |
| **Gamma** (Topologist) | Tropical Geometry & Neural Nets | ReLU = tropical polynomial; √L proof compression |
| **Delta** (Quantum) | Quantum-Pythagorean Bridge | Berggren tree parametrizes quantum codes; R² + E² = 1 |
| **Epsilon** (Evader) | Repulsor Theory | Goodhart's Law formalized; diagonal evasion engine |
| **Zeta** (Meta) | Foundations & Information | Cantor + Gödel + Turing = Lawvere's theorem |

## Three Convergence Points

1. **The Idempotent Universe**: O² = O unifies truth, measurement, and computation
2. **The Discrete-Continuous Bridge**: ℕ ⊂ ℝ is the holographic principle for mathematics
3. **The Evasion-Correction Duality**: a² + b² = c² unifies error correction and Goodhart's Law

## Running the Demos

```bash
pip install numpy matplotlib sympy
cd Research/demos
python3 demo1_oracle_phase_transition.py  # generates fig1, fig2
python3 demo2_berggren_quantum_codes.py   # generates fig3, fig4
python3 demo3_goodhart_repulsor.py        # generates fig5, fig6
python3 demo4_tropical_neural_compression.py  # generates fig7
python3 demo5_oracle_godel_lawvere.py     # generates fig8
python3 demo6_repulsor_evasion.py         # generates fig9
python3 demo7_gap_laplacian.py            # generates fig10
```
