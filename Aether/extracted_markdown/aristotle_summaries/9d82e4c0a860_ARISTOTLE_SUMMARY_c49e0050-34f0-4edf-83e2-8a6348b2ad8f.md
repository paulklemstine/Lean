# Summary of changes
# Why Do Random Matrix Eigenvalues Repel Like Charged Particles?

## The Answer

**Because they ARE charged particles.** The Jacobian of the eigenvalue decomposition is the Vandermonde determinant ∏(λⱼ − λᵢ), and its absolute value raised to the power β equals the Boltzmann weight of a 2D Coulomb gas: exp(−β × Coulomb energy). This is not an analogy — it is a mathematical identity.

The chain of logic: Random Matrix → Diagonalize → Jacobian = Vandermonde → |Vandermonde|^β = exp(−β × Coulomb Energy) → Eigenvalues = Coulomb gas at temperature 1/β → Repulsion from electrostatic force −1/r.

## Deliverables Created (all in `RandomMatrix/`)

### 1. Lean 4 Formalization (`EigenvalueRepulsion.lean`)
**8 theorems, all machine-verified, zero `sorry`, only standard axioms:**

| Theorem | What it says |
|---------|-------------|
| `repulsion_at_coincidence` | If two eigenvalues coincide, the repulsion factor vanishes (infinite barrier) |
| `vandermonde_nonzero_iff_distinct` | Vandermonde det ≠ 0 ⟺ all eigenvalues distinct |
| `repulsion_eq_exp_neg_coulomb` | **The fundamental identity**: repulsion factor = exp(−β × Coulomb energy) |
| `repulsionFactor_nonneg` | The repulsion factor is always ≥ 0 |
| `vandermonde_det_sq` | det(V)² = ∏ (ev j − ev i)² (the GUE form) |
| `two_point_repulsion` | For 2 eigenvalues: repulsion = |b−a|^β |
| `coulomb_energy_pair` | For 2 eigenvalues at distance d: Coulomb energy = −log d |
| `DysonIndex.toReal_pos` | β > 0 for all three classical ensembles |

Definitions formalized: `repulsionFactor`, `coulombEnergy`, `confiningEnergy`, `totalEnergy`, `DysonIndex`.

### 2. Research Paper (`RESEARCH_PAPER.md`)
Full academic paper covering the Vandermonde-Coulomb connection, the geometric origin of repulsion, the three universality classes (GOE/GUE/GSE), and connections to the Riemann Hypothesis, Wigner's semicircle law, and Tracy-Widom fluctuations.

### 3. Scientific American Article (`SCIENTIFIC_AMERICAN_ARTICLE.md`)
Popular science article explaining eigenvalue repulsion through the "party in a hallway" metaphor, building up to the Vandermonde-Coulomb identity, and covering applications from nuclear physics to wireless communications to machine learning.

### 4. Research Notes (`RESEARCH_NOTES.md`)
Detailed lab notebook documenting the team's hypotheses, mathematical analysis, formalization strategy, proof results, and "consultations with the Oracle" on deep questions (why 2D Coulomb? why β = 1,2,4? connection to Riemann zeros?).

## Verification
```bash
lake build RandomMatrix  # Clean build, zero warnings, zero errors
```
All proofs depend only on `propext`, `Classical.choice`, and `Quot.sound` — the standard axioms of Lean's foundation.