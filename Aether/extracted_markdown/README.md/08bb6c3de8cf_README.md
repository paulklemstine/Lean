# The Road Ahead
## Three New Directions for Pythagorean Factoring

This directory contains the complete research output from the Oracle Council's investigation into extensions of the Berggren tree factoring program.

---

### 📁 Directory Structure

```
RoadAhead/
├── README.md                          ← You are here
├── research_paper.md                  ← Full research paper
├── scientific_american_article.md     ← Popular science article
├── demos/
│   ├── tree_sieve.py                  ← The Tree Sieve algorithm
│   ├── lattice_reduction.py           ← LLL + Berggren hybrid
│   ├── ml_energy.py                   ← Neural energy function
│   └── oracle_council.py             ← The Oracle Council session
├── visuals/
│   ├── generate_plots.py             ← Visualization generator
│   ├── berggren_tree.png             ← Fig 1: The Berggren Tree
│   ├── berggren_tree.svg             ← (vector format)
│   ├── energy_landscape.png          ← Fig 2: Energy Landscape
│   ├── depth_scaling.png             ← Fig 3: Factoring Depth vs N
│   ├── three_roads.png               ← Fig 4: Conceptual diagram
│   ├── smooth_distribution.png       ← Fig 5: Smooth value density
│   └── angle_signal.png              ← Fig 6: Angle vs factor signal
└── notes/
    └── research_notes.md             ← Detailed research notes
```

### 🚀 Quick Start

```bash
# Run the Oracle Council session
python demos/oracle_council.py

# Run individual demos
python demos/tree_sieve.py
python demos/lattice_reduction.py
python demos/ml_energy.py

# Regenerate visualizations
python visuals/generate_plots.py
```

### The Three Roads

1. **🌳 The Tree Sieve** (`demos/tree_sieve.py`): Combines partial Berggren tree relations via Gaussian elimination over GF(2), analogous to the quadratic sieve.

2. **🔷 Lattice Reduction** (`demos/lattice_reduction.py`): Uses LLL to find short vectors in the Berggren lattice, corresponding to small factors.

3. **🧠 Machine Learning** (`demos/ml_energy.py`): Trains a neural network to learn the energy landscape for guiding A* search through the tree.

### Publications

- `research_paper.md` — Full technical paper with theorems, algorithms, and complexity analysis
- `scientific_american_article.md` — Popular science article: "The Ancient Triangle That Could Break Modern Codes"
- `notes/research_notes.md` — Detailed session notes from the Oracle Council
