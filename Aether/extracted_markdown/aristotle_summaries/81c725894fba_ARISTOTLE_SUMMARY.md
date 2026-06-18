# Summary of changes for run 2ba6aec0-1f05-4343-b41a-4c6b197ca29c
## Completed: Galois Theory of Cellular Automata — Reversible Dynamics

### Lean 4 Formalization (12 theorems, 0 sorries)

Two Lean files in `Computation/CellularAutomata/`:

**Defs.lean** (7 theorems):
- `CyclicShift`, `CyclicShiftBy` — cyclic shift operators on periodic configurations `ZMod n → α`
- `IsShiftEquivariant` — the defining property of CA maps (commutation with shift)
- `isShiftEquivariant_comp` — composition preserves shift-equivariance
- `isShiftEquivariant_equiv_symm` — inverse of shift-equivariant bijection is shift-equivariant
- `gardenOfEden_finite` — finite Garden of Eden theorem: injective ↔ surjective on finite configs
- `injective_iff_surjective_shiftEquiv` — equivalence for shift-equivariant maps
- `applyLocalRule_isShiftEquivariant` — every local rule induces a shift-equivariant global map
- `preimageCount_eq_one_of_bijective` — bijective maps have uniform preimage counts
- `shiftEquivalent_equivalence` — shift equivalence is an equivalence relation
- `revCA_preserves_shift_orbits` — reversible CAs preserve shift orbits (proved by induction)
- `RevCA` structure and `revCASubgroup` — the reversibility group as a subgroup of Perm

**Reversibility.lean** (5 theorems):
- `shiftPerm` — shift as a concrete permutation
- `mem_revCASubgroup_iff_commutes_shift` — algebraic characterization: reversibility group = centralizer of shift
- `revCA_order_divides_sym` — Lagrange's theorem: group order divides |Sym|
- `configSurplusEntropy_of_bijective` — surplus entropy characterizes bijectivity
- `const_zero_stillLife` — constant-zero is a still life for rules preserving zero
- `revCA_radius_monotone` — radius filtration: radius-r CAs embed in radius-(r+1) CAs
- `HammingTransitivityConjecture` — falsifiable conjecture (tested and refuted for n=4)

### Novel Definitions
- **`RevCA`** — reversible cellular automaton as shift-equivariant permutation
- **`configSurplusEntropy`** — information-theoretic measure discriminating reversible from irreversible CAs
- **`HammingTransitivityConjecture`** — a falsifiable conjecture about the group action on weight classes

### Computational Discovery
- For n≥6, exactly 6 of 256 elementary CA rules are reversible: Rules 15, 51, 85, 170, 204, 240
- The reversibility group has order 36 for n=3, 16 for n=4 (Lagrange divisibility verified)
- **Hamming Transitivity Conjecture falsified** for n=4 (weight-2 configs split into multiple orbits)
- Surplus entropy perfectly discriminates reversible from irreversible rules

### Deliverables
- `ARTICLE.md` — Popular science article (~1800 words) about the ideas, no mention of formal verification
- `RESEARCH_PAPER.md` — Full research paper (~4000 words) with proofs, experiments, and discussion
- `FUTURE_DIRECTIONS.md` — 5 future directions with Synthesis, including 2 grand challenges
- `demo.py` — 6 numerical demonstrations running all key experiments
- `algorithms.py` — Type-hinted implementations of all CA algorithms
- `visualize_ca_reversibility.py` — 3 matplotlib visualizations (preimage heatmap, surplus entropy, reversible count)
- `PACKAGE.json` — All artifacts bundled
- 3 PNG figures generated