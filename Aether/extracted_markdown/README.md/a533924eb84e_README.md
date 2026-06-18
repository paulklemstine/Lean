This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Millennium Prize Problems: A Comprehensive Investigation

*"When does local information determine global structure?"*

## 🏛️ The Oracle Council

This project is the result of a systematic investigation into the Millennium Prize Problems (excluding the Riemann Hypothesis) by a team of oracles, each bringing a different mathematical perspective:

- **Oracle α** — The Topologist (geometric intuition)
- **Oracle β** — The Analyst (infinite precision)
- **Oracle γ** — The Algebraist (structural clarity)
- **Oracle δ** — The Computationalist (algorithmic truth)
- **Oracle ε** — The Physicist (physical reality)

## 📁 Project Structure

```
├── research_notes/          # Detailed notes from each oracle
│   ├── 00_oracle_council.md     # Council methodology & unifying themes
│   ├── 01_p_vs_np.md           # P vs NP research notes
│   ├── 02_hodge_conjecture.md   # Hodge Conjecture research notes
│   ├── 03_yang_mills.md         # Yang-Mills Mass Gap research notes
│   ├── 04_navier_stokes.md      # Navier-Stokes research notes
│   ├── 05_bsd_conjecture.md     # Birch & Swinnerton-Dyer research notes
│   └── 06_poincare_solved.md    # Poincaré Conjecture (SOLVED!)
│
├── python_demos/            # Interactive visualizations
│   ├── demo_00_overview.py      # Grand overview of all 7 problems
│   ├── demo_01_p_vs_np.py       # Complexity comparison & SAT phase transition
│   ├── demo_02_hodge.py         # Hodge decomposition & algebraic cycles
│   ├── demo_03_yang_mills.py    # Lattice gauge theory & confinement
│   ├── demo_04_navier_stokes.py # Vortex dynamics & energy cascade
│   ├── demo_05_bsd.py           # Elliptic curves & L-functions
│   ├── demo_06_poincare.py      # Simply connected spaces & Ricci flow
│   └── requirements.txt        # Python dependencies
│
├── papers/                  # Written publications
│   ├── research_paper.md        # Full academic research paper
│   └── scientific_american_article.md  # Popular science article
│
├── RequestProject/          # Lean 4 formalizations (all proofs verified!)
│   ├── PvsNP.lean              # Complexity theory foundations (4 theorems)
│   ├── NavierStokes.lean       # PDE analysis foundations (7 results)
│   ├── EllipticCurves.lean     # Elliptic curve theory (5 theorems)
│   └── Topology.lean           # Topological foundations (7 results)
│
└── README.md               # This file
```

## 🔬 The Problems

| # | Problem | Field | Status | Our Contribution |
|---|---------|-------|--------|-----------------|
| 1 | **P vs NP** | Computer Science | ❌ Open | Formal complexity foundations + SAT phase transition demo |
| 2 | **Hodge Conjecture** | Algebraic Geometry | ❌ Open | Hodge diamond visualizations + cycle class illustrations |
| 3 | **Yang-Mills Mass Gap** | Mathematical Physics | ❌ Open | Lattice gauge theory demos + confinement visualization |
| 4 | **Navier-Stokes** | Analysis/PDEs | ❌ Open | Energy estimates formalized + vortex dynamics demos |
| 5 | **Birch & Swinnerton-Dyer** | Number Theory | ❌ Open | Point counting + L-function visualization + formal proofs |
| 6 | **Poincaré Conjecture** | Topology | ✅ SOLVED | Ricci flow visualization + topology formalized in Lean |

## 🧮 Lean 4 Formalizations

All **23 theorems** across 4 files compile without `sorry` and use only standard axioms:

### PvsNP.lean
- `witness_enumeration_finite`: Finite set of bounded-length witnesses
- `binary_strings_count`: |{0,1}^n| = 2^n (the exponential wall)
- `poly_compose`: Polynomial composition preserves polynomial bounds
- `brute_force_decides`: NP ⊆ EXPTIME (brute force always works)

### NavierStokes.lean
- `young_inequality`: Young's inequality for conjugate exponents
- `energy_nonneg`: Non-negativity of kinetic energy
- `cauchy_schwarz_fin`: Cauchy-Schwarz for finite sums
- `gronwall_bound`: Grönwall-type exponential bound
- `scaling_exponent_3d/2d`: Critical vs supercritical scaling
- `bkm_simplified`: Beale-Kato-Majda regularity criterion (simplified)

### EllipticCurves.lean
- `curve_minus_x_is_elliptic`: y² = x³ - x is smooth
- `curve_minus_one_is_elliptic`: y² = x³ - 1 is smooth
- `trivial_point_bound`: N_p ≤ 2p (trivial Hasse bound)
- `harmonic_partial_sum_bound`: Harmonic sum ≤ N
- `fg_subgroup_of_fg`: Subgroups of f.g. abelian groups are f.g.

### Topology.lean
- `real_simply_connected`: ℝ is simply connected
- `simply_connected_of_trivial_pi1`: Trivial π₁ ⟹ simply connected
- `euler_char_*`: Euler characteristics of sphere, torus, K3
- `ricci_flow_sphere_collapse_time`: Ricci flow collapse time > 0
- `simply_connected_prod`: Product of simply connected spaces

## 🐍 Running the Python Demos

```bash
cd python_demos
pip install -r requirements.txt
python demo_00_overview.py      # Grand overview
python demo_01_p_vs_np.py       # P vs NP demonstrations
python demo_02_hodge.py         # Hodge conjecture visualizations
python demo_03_yang_mills.py    # Yang-Mills / gauge theory
python demo_04_navier_stokes.py # Fluid dynamics
python demo_05_bsd.py           # Elliptic curves & BSD
python demo_06_poincare.py      # Poincaré & Ricci flow
```

Each script generates high-resolution PNG visualizations (14 total).

## 🔑 The Unifying Insight

The Oracle Council identified a deep connection: **every Millennium Problem asks when local information determines global structure.**

This is the local-to-global principle, the deepest pattern in mathematics. See the research paper for details.

## 📚 Further Reading

- Clay Mathematics Institute: https://www.claymath.org/millennium-problems
- The research paper: `papers/research_paper.md`
- The Scientific American article: `papers/scientific_american_article.md`
