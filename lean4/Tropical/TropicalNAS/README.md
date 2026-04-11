# Tropical NAS at Scale: Deliverables

## Overview

This directory contains all deliverables for the "Tropical NAS at Scale" project, applying the Unified Idempotent-Tropical-Quantum Framework to BERT, GPT, and Vision Transformers with billions of parameters.

## Contents

### Python Demos (`python_demos/`)

| File | Description |
|------|-------------|
| `tropical_nas_bert.py` | BERT family analysis (Tiny through XL), attention tropical limit demo, LogSumExp interpolation |
| `tropical_nas_gpt.py` | GPT family analysis (GPT-2 through GPT-3-175B), causal attention penalty, scaling laws |
| `tropical_nas_vit.py` | Vision Transformer analysis (ViT-Ti through ViT-22B, Swin), patch size analysis, CNN vs ViT comparison |
| `tropical_nas_unified.py` | Cross-architecture comparison on a single tropical expressiveness scale, Pareto frontier, scaling law fits |
| `tropical_annealing_demo.py` | Cooling schedule comparison (logarithmic, geometric, linear), free energy interpolation, Boltzmann concentration |

Run any demo with: `python3 deliverables/python_demos/<filename>.py`

### SVG Visuals (`svg_visuals/`)

| File | Description |
|------|-------------|
| `tropical_nas_architecture.svg` | Main architecture diagram showing BERT/GPT/ViT tropical NAS scoring |
| `five_frontiers_map.svg` | Overview map of all five frontiers with the idempotent core |
| `logsumexp_interpolation.svg` | Visualization of the LogSumExp bridge from mean to max |
| `e8_leech_codes.svg` | E8 → E8×E8 → Leech lattice dimension ladder with code parameters |
| `persistent_homology_tropical.svg` | Persistent homology pipeline as tropical computation |

### Written Deliverables

| File | Description |
|------|-------------|
| `research_paper.md` | Full research paper: "Tropical NAS at Scale" |
| `scientific_american_article.md` | Popular science article: "The Hidden Geometry of AI" |
| `new_applications_brainstorm.md` | 25 new application ideas with priority ranking |

### Lean 4 Proofs

All theorems are in `Bridges/NewDirections/FiveFrontiers.lean` — 60+ verified theorems with zero `sorry` statements. Build with:
```
lake build Bridges.NewDirections.FiveFrontiers
```

## Key Results

- **Tropical NAS evaluates architectures in milliseconds** vs. days/weeks for training-based NAS
- **Causal attention (GPT) loses ~50% tropical rank** compared to bidirectional (BERT)
- **Expressiveness per parameter decreases at scale**, consistent with empirical scaling laws
- **All core theorems are machine-verified** in Lean 4 with Mathlib
