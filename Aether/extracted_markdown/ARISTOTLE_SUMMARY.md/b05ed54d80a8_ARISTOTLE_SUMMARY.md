# Summary of changes for run fa57b20b-504d-4f7b-a610-169cfd445135
# Galois Theory of Cellular Automata: Reversibility Groups and Orbital Structure

## Lean 4 Formalization (Geometry/CellularAutomataGalois.lean)
**27 theorems, 0 sorries, fully verified.** Key results:

### Novel Structure: CA Galois Correspondence
A formal Galois connection between subgroups of the reversibility group and families of shift-invariant subsets of configuration space — analogous to the classical Galois correspondence (subgroups ↔ intermediate fields), but in a dynamical context. Includes:
- `invariantSets` — the family of H-invariant shift-invariant sets
- `stabilizerSubgroup` — the stabilizer subgroup of a family of sets (with finiteness-based inverse closure proof)
- `invariantSets_antitone` — larger subgroups have fewer invariant sets (Galois connection property)

### Main Theorems (PEGB Coverage)

1. **`reversibility_eq_centralizer`** — The reversibility group equals the centralizer of the shift permutation. This is the algebraic heart: commuting with one shift generator implies commuting with all shifts (proved by ℕ-induction lifted to ℤ/nℤ).
   - *Proof*: Full formal proof via `shiftEquivariant_comm_shift` + `comm_shift_shiftEquivariant`
   - *Example*: n=3 binary gives centralizer of order 36 in Sym(8)
   - *Generalization*: Holds for any finite alphabet and any period
   - *Boundary*: `reversibility_proper_subgroup` — Rev ≠ Sym for n=3

2. **`orbit_image_eq_orbit`** — Shift-equivariant permutations map orbits to orbits: e(O(c)) = O(e(c)).
   - *Proof*: Double inclusion using shift-equivariance
   - *Example*: Complement maps orbit {000} to orbit {111}
   - *Generalization*: `reversibility_descends_to_orbits` — well-defined action on orbit space
   - *Boundary*: Individual orbits are NOT preserved by the full group (complement swaps orbits)

3. **`card_fixedConfigs_bool`** — Exactly 2 constant (shift-fixed) binary configurations for any period.
   - *Proof*: Characterization of fixed configs as constant functions + counting
   - *Example*: {000...0, 111...1} for any n
   - *Generalization*: For alphabet of size k, exactly k fixed configs
   - *Boundary*: `fixedConfigs_preserved` — reversible CAs must map constants to constants

4. **`swap_not_equivariant`** — Concrete boundary: swapping configs from different orbits breaks shift-equivariance.

5. **`const_map_not_bijective`** — Shift-equivariance alone is insufficient for reversibility (bijectivity needed).

### Falsifiable Conjecture
The reversibility group Rev(n, {0,1}) has the wreath product structure Rev ≅ Π_{d|n} (ℤ/dℤ ≀ S_{m_d}). **Testable prediction**: For n=3, Rev ≅ S₂ × (ℤ/3ℤ ≀ S₂) with |Rev| = 36.

### Cross-Connection
Builds on `reversible_iff_bijective` from `Tropical/HashInversion.lean` and connects to the existing `Catalog/Geometry/CellularAutomataGalois.lean` framework.

## Computational Verification (demo.py)
- Enumerates all 256 elementary CA rules, identifies the 6 reversible ones: Rules 15, 51, 85, 170, 204, 240
- Computes centralizer orders via the cycle type formula for n=1..8
- Verifies the super-exponential collapse of |Rev|/|Sym| (ratio goes from 1 at n=1 to ~10⁻⁷⁵ at n=6)
- Confirms fixed point count = 2 for all n
- Demonstrates orbit preservation under complement

## Deliverables
- **Geometry/CellularAutomataGalois.lean** — 460-line sorry-free Lean 4 formalization
- **ARTICLE.md** — Popular-science article on the ideas (no mention of proof assistants)
- **RESEARCH_PAPER.md** — Technical paper with proofs, algorithms, tables
- **FUTURE_DIRECTIONS.md** — 5 research directions including wreath product structure and higher-dimensional CAs
- **demo.py** — Computational demonstrations
- **algorithms.py** — Type-hinted implementations
- **visualize_orbits.py** — Matplotlib visualization
- **PACKAGE.json** — Bundle with 2 interactive HTML widgets (orbit explorer + CA rule explorer)