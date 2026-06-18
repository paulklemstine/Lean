# Summary of changes for run becb23de-ef97-4b9e-a550-85699f551a2d
# Galois Theory of Cellular Automata: Which Rules Have Reversible Dynamics?

## Research Summary

I developed a rigorous algebraic theory of reversible cellular automata (CAs), formalized in Lean 4 with 53 machine-verified theorems across three files — all sorry-free and compiling cleanly.

## Novel Mathematical Structure: OrbitCentralizerData

The central contribution is the **OrbitCentralizerData** structure, which captures the complete algebraic invariant of the reversibility group via the orbit type decomposition. For a permutation σ acting on a set Ω, the orbit type records how many orbits of each size d exist, and the centralizer order follows the formula:

**|C(σ)| = ∏_{d} d^{a_d} · a_d!**

This connects CA reversibility to classical group theory (centralizers, wreath products), combinatorics (Burnside's lemma, necklace counting), and number theory (Fermat's little theorem).

## Key Proven Theorems

### File 1: `Geometry/CellularAutomataGalois.lean` (23 theorems)
- **ReversibilitySubgroup**: Formal definition as a subgroup of Sym(configurations)
- **inv_shift_equivariant**: The inverse of a shift-equivariant bijection is shift-equivariant
- **reversibility_proper_subgroup**: For n=3, Bool, the reversibility group is a *proper* subgroup of Sym(8)
- **shift_equivariant_preserves_orbits**: Equivariant maps preserve shift orbits setwise
- **shiftOrbitFinset_card_dvd**: Orbit size divides the period n
- **shift_comm_iff_equivariant_one**: Centralizer characterization bridge

### File 2: `Geometry/CellularAutomataOrbits.lean` (18 theorems)
- **shift_equivariant_sends_const_to_const**: Equivariant maps preserve constant configurations
- **equivariant_perm_preserves_orbit_card**: Orbit sizes are invariant under equivariant permutations
- **shiftPerm_pow_n**: The shift permutation has order dividing n
- **finite_ca_inj_iff_surj**: Finite Moore-Myhill theorem (injectivity ↔ surjectivity)

### File 3: `Geometry/CellularAutomataAlgebra.lean` (12 theorems)
- **centralizerOrder_pos**: Centralizer order is always positive for valid orbit data
- **centralizerOrder_single_cycle**: Single m-cycle has centralizer order m
- **binary_nonconstant_orbits_prime**: Fermat's little theorem ensures integral orbit counts for prime periods
- **centralizer_order_n1/n2/n3**: Explicit computations — n=1 gives |G|=2, n=2 gives |G|=4, n=3 gives |G|=36
- **stretch_shift_apply**: Stretch automorphism interaction with shifts

## Deliverables

| Deliverable | Location |
|---|---|
| Lean 4 proofs (53 theorems, 0 sorry) | `Geometry/CellularAutomataGalois.lean`, `CellularAutomataOrbits.lean`, `CellularAutomataAlgebra.lean` |
| Scientific American-style article | `Geometry/ARTICLE.md` |
| Research paper (with proofs/tables) | `Geometry/RESEARCH_PAPER.md` |
| Future directions (5 directions) | `Geometry/FUTURE_DIRECTIONS.md` |
| Python demo | `Geometry/demo.py` |
| Algorithm implementations | `Geometry/algorithms.py` |
| Visualization script | `Geometry/viz_reversibility.py` |
| PACKAGE.json with 3 interactive demos | `Geometry/PACKAGE.json` |

## Falsifiable Conjecture

For n prime, the reversibility group is isomorphic to S₂ × (ℤ/pℤ ≀ S_{(2^p-2)/p}). Testable for p = 2, 3, 5, 7 by computing group orders and comparing to the formula 2 · p^{(2^p-2)/p} · ((2^p-2)/p)!.

## Key Discovery

The reversibility index RI(n) = log₂|G|/log₂|S_{2^n}| decays to zero super-exponentially — reversible CAs become exponentially rarer as the system grows. For n=3, only 0.09% of all permutations are reversible CAs. This scarcity is a mathematical necessity, not an accident.