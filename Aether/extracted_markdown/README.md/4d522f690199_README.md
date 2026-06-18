# Inverse Pythagorean Tree Factoring: A Comprehensive Research Package

## Overview

This package contains the complete research output from investigating four frontier
questions about factoring integers via descent in the Berggren Pythagorean triple tree.

## Directory Structure

```
InverseTreeFactoring/
├── README.md                          ← This file
├── ChainFactoring.lean               ← Original chain factoring formalization
│
├── JumpAhead.lean                    ← Q1: Jump-ahead acceleration (Lean 4, proven)
├── QuantumGrover.lean                ← Q2: Quantum Grover speedup (Lean 4, proven)
├── ContinuedFractions.lean           ← Q3: CF connections (Lean 4, proven)
├── LorentzConnections.lean           ← Q4: Lorentz group structure (Lean 4, proven)
│
├── Python/
│   ├── inverse_tree_factoring.py     ← Core algorithm + jump-ahead demo
│   ├── quantum_grover_simulation.py  ← Grover oracle simulation
│   ├── continued_fraction_analysis.py ← CF vs descent path analysis
│   └── lorentz_analysis.py           ← Eigenvalue & boost parameter analysis
│
├── Visuals/
│   ├── generate_visuals.py           ← SVG figure generator
│   ├── fig1_berggren_tree.svg        ← The Berggren tree (4 levels)
│   ├── fig2_descent_path.svg         ← Descent path for N=77
│   ├── fig3_hypotenuse_decay.svg     ← Hypotenuse decay curves
│   ├── fig4_depth_scatter.svg        ← d* vs min(p,q) scatter
│   ├── fig5_klein_disk.svg           ← Klein disk geodesic trace
│   └── fig6_branch_patterns.svg      ← Branch sequence patterns
│
├── Research/
│   └── OracleCouncilNotes.md         ← Research brainstorming & iteration log
│
└── Papers/
    ├── ResearchPaper.md              ← Full research paper
    └── ScientificAmericanArticle.md  ← Popular science article
```

## Lean 4 Theorems Proved (No Sorry)

### JumpAhead.lean — Question 1: Acceleration
| Theorem | Statement |
|---------|-----------|
| `descent_composition` | k-step descent = single matrix composition |
| `invBranch_preserves_pyth` | Each branch preserves Pythagorean property |
| `descentChain_preserves_pyth` | Full chain preserves Pythagorean property |
| `all_branches_same_hyp` | All branches produce same hypotenuse formula |
| `parent_hyp_strictly_less` | Parent hypotenuse < child hypotenuse |
| `parent_hyp_pos'` | Parent hypotenuse > 0 |
| `descent_depth_bound` | Parent hypotenuse ≤ c - 1 |
| `lorentz_form_preserved` | Lorentz form invariant under each branch |
| `lorentz_form_zero_descent` | Lorentz form = 0 at every descent level |
| `gcd_factor_extraction` | GCD reveals nontrivial factor of N |

### QuantumGrover.lean — Question 2: Quantum Version
| Theorem | Statement |
|---------|-----------|
| `grover_query_bound` | Grover uses O(√(S/M)) queries |
| `quantum_balanced_complexity` | √d* ≤ √p for d* ≤ p |
| `branches_12_exclusive` | Branches 1,2 mutually exclusive |
| `branches_13_exclusive` | Branches 1,3 mutually exclusive |
| `branches_23_exclusive` | Branches 2,3 mutually exclusive |
| `descent_is_deterministic` | At most one branch valid at each step |

### ContinuedFractions.lean — Question 3: CF Connection
| Theorem | Statement |
|---------|-----------|
| `cfM1_det` | det(M₁) = 1 |
| `cfM2_det` | det(M₂) = -1 |
| `cfM3_det` | det(M₃) = 1 |
| `M3_is_T_squared` | M₃ = T² (direct CF connection!) |
| `cfM1_inv_correct` | M₁ · M₁⁻¹ = I |
| `cfM3_inv_correct` | M₃ · M₃⁻¹ = I |
| `ST2S_explicit` | S·T²·S computed explicitly |
| `cfM1_squared` | M₁² = [[3,-2],[2,-1]] |
| `M3_action` | M₃ · (m,n) = (m+2n, n) |
| `M1_action` | M₁ · (m,n) = (2m-n, m) |
| `root_euclid_params` | Root (3,4,5) has params (2,1) |
| `trivial_euclid_params` | Trivial triple: m-n = 1 |
| `trivial_diff_of_squares` | m² - n² = N |

### LorentzConnections.lean — Question 4: Lorentz Group
| Theorem | Statement |
|---------|-----------|
| `LB1_preserves_lorentz` | B₁ᵀQB₁ = Q |
| `LB2_preserves_lorentz` | B₂ᵀQB₂ = Q |
| `LB3_preserves_lorentz` | B₃ᵀQB₃ = Q |
| `LBinv1_preserves_lorentz` | B₁⁻¹ preserves Lorentz form |
| `LBinv1_is_inverse` | B₁·B₁⁻¹ = I |
| `Q_squared_is_identity` | Q² = I |
| `LBinv1_formula` | B₁⁻¹ = Q·B₁ᵀ·Q |
| `LB1_det`, `LB2_det`, `LB3_det` | Determinants: 1, -1, 1 |
| `eigenvalue_product` | 3² - 2·2² = 1 (Pell equation) |
| `char_poly_identity` | (x-1)(x²-6x+1) = x³-7x²+7x-1 |
| `lorentz_bilinear_self_zero` | Q(v,v) = 0 on Pythagorean triples |
| `lorentz_descent_contracts` | 0 < c' < c at each step |
| `lorentz_cross_term` | Cross-form = -2(c-b)² |
| `depth_upper_bound` | c' ≤ c - 1 |

## Key Findings

1. **Jump-ahead is formally correct** but offers limited practical speedup because
   branch runs are short (typically 1-3 identical consecutive branches).

2. **Quantum Grover** gives O(√min(p,q)) = O(N^{1/4}) for balanced semiprimes —
   matching Pollard's rho. The descent is deterministic, so quantum parallelism
   over branches doesn't help.

3. **M₃ = T²** directly connects the Berggren tree to continued fractions via
   the SL(2,ℤ) generator T. The theta group Γ_θ (index-3 in SL(2,ℤ)) captures
   the tree's algebraic structure.

4. **Lorentz eigenvalues** 3 ± 2√2 satisfy the Pell equation x² - 2y² = 1,
   connecting the descent rate to classical number theory. The cross-Lorentz
   form between parent and child equals -2(c-b)², not zero.

## Running the Python Scripts

```bash
cd Python/
python3 inverse_tree_factoring.py        # Core demo
python3 inverse_tree_factoring.py 2537    # Factor a specific number
python3 continued_fraction_analysis.py    # CF analysis
python3 lorentz_analysis.py              # Lorentz/eigenvalue analysis
python3 quantum_grover_simulation.py      # Grover simulation (needs numpy)

cd ../Visuals/
python3 generate_visuals.py              # Generate all SVG figures
```

## Building the Lean Proofs

```bash
lake build Pythagorean.InverseTreeFactoring.JumpAhead
lake build Pythagorean.InverseTreeFactoring.QuantumGrover
lake build Pythagorean.InverseTreeFactoring.ContinuedFractions
lake build Pythagorean.InverseTreeFactoring.LorentzConnections
```

All files compile with zero sorry and only standard axioms.
