# Pythagorean Photonics

## Spacetime as a Discrete Integer Lattice — Machine-Verified in Lean 4

### Core Hypothesis

If light propagates along Pythagorean connections (integer displacements with
integer distances), then spacetime must be a discrete integer lattice with
ternary photon branching and emergent special relativity.

### Project Structure

```
PythagoreanPhotonics/
├── SpacetimeLattice.lean    ← 22 machine-verified theorems (ZERO sorry)
├── README.md                ← This file
├── demos/
│   ├── demo1_pythagorean_triplets.py       ← Triple generation & density law
│   ├── demo2_lattice_light_propagation.py  ← Photon simulation on lattice
│   ├── demo3_dispersion_relation.py        ← Lattice vs continuous dispersion
│   ├── demo4_berggren_tree.py              ← Ternary tree exploration
│   └── demo5_experimental_bounds.py        ← Predictions vs experiments
├── visuals/
│   ├── concept_diagram.svg          ← Logical chain diagram
│   ├── lattice_3d_concept.svg       ← 3-4-5 photon on the lattice
│   ├── pythagorean_lattice.svg      ← [Generated] Lattice point map
│   ├── lattice_propagation.svg      ← [Generated] Light paths
│   ├── dispersion_relation.svg      ← [Generated] Dispersion curves
│   ├── berggren_tree.svg            ← [Generated] Tree structure
│   └── experimental_bounds.svg      ← [Generated] Predictions vs bounds
├── paper/
│   ├── pythagorean_photonics.md     ← Full research paper
│   └── scientific_american_article.md ← Popular science article
└── research/
    ├── 00_omega_council.md          ← 6-oracle review panel
    ├── 01_hypothesis_formulation.md ← Formal hypothesis & iterations
    └── 02_experiments_log.md        ← Complete experiment log
```

### Key Proven Theorems (22 total, all machine-verified)

| # | Theorem | Lean Name |
|---|---------|-----------|
| 1 | ℤ² is discrete | `intLattice2_discrete` |
| 2 | Min lattice distance ≥ 1 | `lattice_min_distance` |
| 3 | (3,4,5) is primitive Pythagorean | `triple_3_4_5` |
| 4 | (5,12,13) is primitive Pythagorean | `triple_5_12_13` |
| 5 | (8,15,17) is primitive Pythagorean | `triple_8_15_17` |
| 6 | Euclid's formula gives triples | `euclid_pythagorean` |
| 7 | Berggren A preserves Pythagorean | `berggren_A_preserves` |
| 8 | Berggren B preserves Pythagorean | `berggren_B_preserves` |
| 9 | Berggren C preserves Pythagorean | `berggren_C_preserves` |
| 10 | All tree triples are Pythagorean | `berggrenTree_all_pythagorean` |
| 11 | Each node has 3 children | `berggren_three_children` |
| 12 | Hypotenuse grows in tree | `berggren_hypotenuse_grows` |
| 13 | Infinitely many triples | `infinitely_many_pythagorean_triples` |
| 14 | Pythagorean = Null cone (iff) | `pythagorean_is_null_cone` |
| 15 | Pythagorean → unit circle point | `pyth_gives_rational_circle_point` |
| 16 | Photon composition (Brahmagupta) | `photon_composition` |
| 17 | Gaussian norm multiplicativity | `gaussian_norm_mult` |
| 18 | Pythagorean set is countable | `pythSet_countable` |
| 19 | Photon reach from triples | `photon_reach_from_triple` |
| 20 | Integer distance from triples | `pyth_integer_distance` |
| 21 | No primitive triple with leg 1 | `no_pyth_triple_leg_one` |
| 22 | Minimum primitive triple c ≥ 5 | `min_primitive_triple` |

### Running the Demos

```bash
cd demos/
python3 demo1_pythagorean_triplets.py    # Generates pythagorean_lattice.svg
python3 demo2_lattice_light_propagation.py  # Generates lattice_propagation.svg
python3 demo3_dispersion_relation.py     # Generates dispersion_relation.svg
python3 demo4_berggren_tree.py           # Generates berggren_tree.svg
python3 demo5_experimental_bounds.py     # Generates experimental_bounds.svg
```

No external dependencies needed — pure Python 3.

### Building the Lean Proofs

```bash
lake build PythagoreanPhotonics
```

Requires Lean 4.28.0 with Mathlib v4.28.0.

### Axioms Used

Only standard logical axioms: `propext`, `Classical.choice`, `Quot.sound`.
No custom axioms, no sorry, no implemented_by.
