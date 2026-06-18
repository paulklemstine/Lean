# Gravitational Factoring on Pythagorean k-Tuple Trees

A geometric framework for integer factoring using the tree structure of Pythagorean quadruples and higher-dimensional extensions.

## Core Idea

Given a semiprime N = p × q, we search for Pythagorean k-tuples x₁² + x₂² + ... + xₖ = d² where the hypotenuse d is related to N. Each such tuple yields multiple **peel channels**: the identity (d - xⱼ)(d + xⱼ) = Σᵢ≠ⱼ xᵢ² gives factorizations whose GCD with N may reveal p or q.

## Files

### Lean Formalization
- **`Foundations.lean`** — Core theorems: energy functional, peel channel identity, cross-collision, GCD cascade, Euler four-square identity, quaternion norm multiplicativity, dimensional hierarchy
- **`HigherDimensions.lean`** — Higher-dimensional extensions: Brahmagupta-Fibonacci identity, lifting theorems, representation density bounds, octonionic advantage

### Python Demos
- **`demo_gravitational_factoring.py`** — Interactive demonstrations of all factoring methods: quaternion norm factoring, modular sieve, GCD cascade, neural navigation
- **`generate_visuals.py`** — SVG visualization generator

### SVG Visuals (in `visuals/`)
- `quadruple_tree.svg` — The Pythagorean quadruple tree structure
- `peel_channels.svg` — The three peel channels for factor extraction
- `dimensional_hierarchy.svg` — Channel count vs. dimension bar chart
- `energy_landscape.svg` — The factoring energy surface
- `quaternion_factoring.svg` — Quaternion norm factoring diagram
- `cross_collision.svg` — Shared-hypotenuse cross-collision

### Research Documents
- **`research_paper.md`** — Full research paper with formal results
- **`scientific_american_article.md`** — Popular science article
- **`future_research.md`** — Recommended future research directions
- **`applications_brainstorm.md`** — Application ideas and cross-disciplinary connections

## Key Results (Machine-Verified in Lean 4)

| Theorem | Statement |
|---------|-----------|
| `ktuple_peel_channel` | (d - xⱼ)(d + xⱼ) = Σᵢ≠ⱼ xᵢ² |
| `euler_four_square_identity` | Product of two 4-square sums is a 4-square sum |
| `channels_triangular` | 2 × C(k) = k(k+1) |
| `octonionic_advantage` | 36 channels for k=8, 6× quadruples |
| `solving_gives_factor` | Nontrivial GCD ⟹ nontrivial factor |
| `prime_factor_from_square_div` | p prime, p·q | d² ⟹ p | d |

## Running the Demos

```bash
cd Pythagorean/GravitationalFactoring
python3 demo_gravitational_factoring.py    # Run factoring demos
python3 generate_visuals.py                # Generate SVG visuals
```

## The Dimensional Advantage

| Dimension k | Peel Channels | Cross-Collision | Total | Division Algebra |
|-------------|---------------|-----------------|-------|------------------|
| 2 (triples) | 2 | 1 | 3 | ℂ |
| 3 (quadruples) | 3 | 3 | 6 | — |
| 4 (quintuples) | 4 | 6 | 10 | ℍ |
| 8 (9-tuples) | 8 | 28 | 36 | 𝕆 |
