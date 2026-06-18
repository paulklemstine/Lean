This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# Pythagorean Photonics Research Project

> **"If light is related to Pythagorean triplets, then light and space must be quantized and have absolute coordinates."**

A comprehensive research investigation into the implications of Pythagorean geometry for the structure of spacetime.

---

## 📁 Project Structure

```
├── README.md                          ← You are here
├── research/                          ← Research notes & team documentation
│   ├── 00_team_charter.md            ← Team structure, hypothesis, research plan
│   ├── 01_literature_and_foundations.md ← Literature review & mathematical background
│   ├── 02_hypothesis_formulation.md   ← Formal hypothesis, predictions, counterarguments
│   └── 03_experiments_and_validation.md ← Experimental results & iteration log
├── demos/                             ← Python computational experiments
│   ├── demo1_pythagorean_triplets.py  ← Triplet generation, density analysis, lattice SVG
│   ├── demo2_lattice_light_propagation.py ← Photon simulation on discrete lattice
│   ├── demo3_dispersion_relation.py   ← Modified dispersion relations (lattice vs continuous)
│   ├── demo4_quantized_spacetime.py   ← 3D Pythagorean quadruples & lattice geometry
│   └── demo5_experimental_bounds.py   ← Predictions vs experimental constraints
├── visuals/                           ← SVG visualizations
│   ├── concept_diagram.svg           ← Logical chain: premise → conclusions
│   ├── lattice_3d_concept.svg        ← 3D lattice with Pythagorean light paths
│   ├── pythagorean_lattice.svg       ← [Generated] 2D Pythagorean lattice points
│   ├── lattice_propagation.svg       ← [Generated] Light propagation paths
│   ├── dispersion_relation.svg       ← [Generated] Continuous vs lattice dispersion
│   └── experimental_bounds.svg       ← [Generated] Predictions vs bounds plot
├── paper/
│   └── pythagorean_photonics.md      ← Full research paper
└── article/
    └── scientific_american_article.md ← Popular science article
```

## 🚀 Quick Start

### Run the demos
```bash
cd demos
python3 demo1_pythagorean_triplets.py    # Generates triplets + SVG
python3 demo2_lattice_light_propagation.py  # Light simulation + SVG
python3 demo3_dispersion_relation.py     # Dispersion analysis + SVG
python3 demo4_quantized_spacetime.py     # 3D lattice analysis
python3 demo5_experimental_bounds.py     # Experimental comparison + SVG
```

### View the visuals
Open any `.svg` file in `visuals/` in a web browser. The hand-crafted SVGs (`concept_diagram.svg`, `lattice_3d_concept.svg`) are always available. The generated SVGs are created by running the demos.

### Read the research
Start with `research/00_team_charter.md` for an overview, then read the paper at `paper/pythagorean_photonics.md`.

---

## 🔬 The Core Argument

1. **Premise**: Light propagation obeys Pythagorean triplet geometry (a² + b² = c², integers only)
2. **Therefore**: Spatial displacements come in integer multiples of a fundamental unit → **space is quantized**
3. **Therefore**: The integer lattice defines preferred directions and positions → **absolute coordinates**

## 🧪 Key Findings

| Finding | Details |
|---------|---------|
| **Triplet density** | Grows as N/(2π) — confirmed computationally up to N = 5000 |
| **3D is viable** | Pythagorean quadruples cover >70% of angular directions for d ≤ 30 |
| **Anisotropy is tiny** | For Planck-scale lattice: Δc/c ~ 10⁻⁵⁷ (far below detectable) |
| **Dispersion suppressed** | Lattice effects at TeV energies: < 10⁻³⁰ deviation |
| **Simple lattice marginal** | Compatible with Michelson-Morley, marginal with Fermi-LAT |

## ⚠️ Disclaimer

This is a **speculative theoretical investigation**, not established physics. The hypothesis is logically consistent and produces testable predictions, but there is currently no direct evidence for discrete spacetime at any scale. The project is intended as an exploration of ideas at the frontier of physics and mathematics.

## 📋 Requirements

- Python 3.6+ (standard library only — no external dependencies)
- A web browser for viewing SVG files
