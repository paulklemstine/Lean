This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# Factoring Through Division Algebra Norms

A unified framework for integer factorization using Pythagorean tuples in dimensions 1, 2, 4, and 8 — the four normed division algebras (ℝ, ℂ, ℍ, 𝕆).

## Project Structure

```
├── RequestProject/
│   └── NormHierarchy.lean     # Lean 4 formalization (15 theorems, 0 sorry)
├── papers/
│   ├── research_paper.md      # Full research paper
│   ├── scientific_american_article.md   # Popular science article
│   └── applications.md        # Applications brainstorm (10 domains)
├── demos/
│   ├── factoring_demo.py      # Interactive factoring demo (dims 2, 4, 8)
│   └── representation_density.py  # r_k(N) analysis with modular form formulas
├── visuals/
│   ├── factoring_sphere_dim2.svg    # Collision on the factoring circle
│   ├── dimension_hierarchy.svg      # The four division algebras compared
│   ├── collision_mechanism.svg      # How collision-based factoring works
│   ├── channel_growth.svg           # Channel count growth by dimension
│   └── e8_and_modular.svg          # Three speculative research directions
└── README.md
```

## Formally Verified Theorems

All 15 theorems compile with zero `sorry` statements in Lean 4.28.0 + Mathlib:

| Theorem | Description |
|---------|-------------|
| `brahmagupta_fibonacci_identity` | (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)² |
| `brahmagupta_fibonacci_identity'` | (a²+b²)(c²+d²) = (ac+bd)²+(ad-bc)² |
| `two_composition_equality` | Both BF forms are equal |
| `euler_four_square_identity` | 4-square composition identity |
| `collision_norm_identity` | Two reps of N → rep of N² |
| `collision_product_identity` | (a-c)(a+c) = (d-b)(d+b) |
| `peel_identity_dim2` | Factoring channel for dim 2 |
| `peel_identity_dim4` | Factoring channel for dim 4 |
| `quaternion_norm_mul` | Quaternion norm multiplicativity |
| `hypotenuse_gt_leg` | Descent termination guarantee |
| `nontrivial_divisor_composite` | Nontrivial divisor ⟹ composite |
| `collision_opportunity_count` | k·C(m,2) ≥ k channels |
| `gcd_cascade_divides` | GCD of cross-term divides N |
| `cross_term_sq_le_N_sq` | |ad-bc| ≤ N bound |
| `degen_eight_square_identity` | 8-square composition (octonions) |

## Running the Demos

```bash
# Interactive factoring demo
python3 demos/factoring_demo.py

# Factor a specific number
python3 demos/factoring_demo.py 85

# Representation density analysis
python3 demos/representation_density.py
```

## Building the Lean Proofs

```bash
lake build RequestProject.NormHierarchy
```

## Three Speculative Research Directions

1. **Quantum collision-finding**: Can restricted quantum computers exploit sphere geometry better than Shor's group-theoretic approach?
2. **E₈ lattice shortcuts**: Do the 240 root vectors of E₈ provide structured descent directions for octonion factoring?
3. **Modular form prediction**: Can theta function coefficients guide representation selection for more productive collisions?

See `papers/research_paper.md` for detailed analysis of each direction.
