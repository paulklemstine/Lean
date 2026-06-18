# Summary of changes for run cafd0517-d262-4235-aaad-a013b5812081
# Galois Theory of Cellular Automata: Complete Research Cycle

## Lean 4 Formalization — 12 Theorems, Zero Sorries

The file `Geometry/CellularAutomataGaloisDeep.lean` contains 12 fully-proved theorems extending the Catalog's `CellularAutomataGalois.lean`. All proofs compile with `lean build` and use only standard axioms (propext, Classical.choice, Quot.sound).

### Key Theorems (PEGB for top results):

**1. Centralizer = Reversibility Theorem** (`revGroup_eq_centralizer`)
- **Proof**: The reversibility group (shift-equivariant permutations) equals the centralizer of the shift permutation in the symmetric group. This is the algebraic heart of the Curtis-Hedlund-Lyndon theorem.
- **Example**: For n=3, Rev(3,{0,1}) is a group of order 36 inside S₈ (order 40320).
- **Generalization**: Holds for any finite alphabet α and any period n — reduces reversible CA analysis to standard group theory.
- **Boundary**: Fails for infinite configurations (the full Curtis-Hedlund-Lyndon theorem requires topological conditions).

**2. Prime Orbit Theorem** (`orbit_size_prime`)
- **Proof**: For p prime, every non-constant binary configuration on ℤ/pℤ has a full shift orbit of size p.
- **Example**: For p=5, the 30 non-constant configurations form 6 orbits of size 5 (confirming (2⁵-2)/5 = 6).
- **Generalization**: Connects to Fermat's little theorem — the orbit decomposition IS Fermat in disguise.
- **Boundary**: Fails for composite n, where orbits can have sizes dividing n.

**3. Discrete Liouville Theorem** (`reversible_preserves_weight_distribution`)
- **Proof**: Any bijection on configurations preserves the weight distribution — the discrete analogue of Hamiltonian phase-space volume preservation.
- **Example**: Rule 170 (left shift) maps weight-2 configs to weight-2 configs bijectively.
- **Generalization**: Holds for ANY invariant, not just Hamming weight.
- **Boundary**: Does not imply individual orbits preserve weight (only the distribution).

**4. Galois Connection** (`galois_antitone` + `revGroup_fixes_only_constants`)
- Larger subgroups fix fewer configurations. The full reversibility group fixes only constants.

**5. Complement-Shift Structure** (`shift_complement_commute`, `complement_in_revGroup`)
- Shift and complement commute, generating ℤ/nℤ × ℤ/2ℤ inside the reversibility group.

### Additional theorems:
- `shift_one_implies_all` — Commuting with shift-by-1 suffices for full equivariance
- `shift_fixed_iff_const` — Shift fixed points are exactly constant configurations
- `complement_order_two` — The complement is an involution
- `actOnObservable_mul` — Observable action is a valid group representation
- `revGroup_proper_subgroup` — Reversibility group is proper for n ≥ 2

## Deliverables

| File | Description |
|------|-------------|
| `Geometry/CellularAutomataGaloisDeep.lean` | 12 sorry-free Lean 4 theorems |
| `ARTICLE.md` | Popular-science article (~2500 words) |
| `RESEARCH_PAPER.md` | Full research paper with proof sketches |
| `FUTURE_DIRECTIONS.md` | 5 research directions with conjectures |
| `algorithms.py` | Type-hinted implementations of all algorithms |
| `demo.py` | 7 numerical demonstrations |
| `viz_reversibility_landscape.py` | Reversibility sieve heatmap |
| `viz_group_growth.py` | Group growth comparison plots |
| `PACKAGE.json` | Complete artifact bundle with 3 interactive HTML widgets |

## Cross-Domain Bridges
- **CA → Number Theory**: Orbit counting = necklace counting = Fermat's little theorem
- **CA → Mechanics**: Discrete Liouville theorem (entropy conservation)
- **CA → Galois Theory**: Antitone correspondence between subgroups and fixed-point sets
- **CA → Representation Theory**: Observable action gives a group representation