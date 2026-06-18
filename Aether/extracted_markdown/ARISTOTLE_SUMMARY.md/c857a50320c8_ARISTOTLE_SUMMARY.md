# Summary of changes for run b3a74cee-6ee2-4138-b354-fe0702ee22fe
## Quantum Hamiltonian Complexity: Completed Formalization

Created two fully verified Lean 4 files (zero `sorry`, zero errors) in `Catalog/Computation/QuantumHamiltonian/`:

### File 1: `PromiseProblem.lean` (216 lines)
Formalizes promise problems — the natural framework for quantum complexity classes.

**Definitions:**
- `PromiseProblem` — structure with disjoint yes/no predicates
- `PromiseReduction` — many-one promise reductions
- `GapPromiseProblem` — promise problems with explicit gap thresholds

**Theorems (all fully proved with PEGB):**
1. `ofDecision_promiseSet` — decision problems embed as full-promise problems
2. `complement_complement` — complementation is involutive
3. `PromiseReduction.comp` — reductions compose (preorder structure)
4. `complementMap` — reductions respect complementation
5. `gap_pos'` — promise gaps are always positive
6. `gap_scale` — gaps scale linearly under threshold scaling
7. `gap_amplification_bound` — (1-δ)^n ≤ (1-δ/2)^n for gap amplification

### File 2: `SpectralGap.lean` (300 lines)
Formalizes spectral theory for local Hamiltonians — the mathematical core of Kitaev's QMA-completeness proof.

**Definitions:**
- `Matrix.IsPosSemidefC` / `Matrix.IsPosDef'` — PSD/PD for complex matrices
- `quadraticForm'` / `energyExpectation` — Hamiltonian energy ⟨v|H|v⟩
- `LocalHamiltonian` — sum-of-PSD-terms structure
- `localHamiltonianPromise` — Local Hamiltonian as promise problem with gap (a,b)

**Theorems (all fully proved with PEGB):**
1. `zero_isPosSemidefC` — zero matrix is PSD
2. `isPosSemidefC_add` / `isPosSemidefC_finset_sum` — PSD is closed under sums
3. `isPosSemidefC_nonneg_real_smul` — PSD is closed under nonneg scaling
4. `energyExpectation_nonneg_of_posSemidefC` — PSD implies nonneg energy
5. `energyExpectation_pos_of_posDefC` — PD implies strictly positive energy
6. `energyExpectation_add` / `energyExpectation_finset_sum` — energy is additive
7. **`frustration_free`** — zero-energy ground states satisfy ALL local constraints
8. **`frustration_free_approx`** — approximate version: each term ≤ total energy
9. **`energy_monotone_of_posSemidefC_add`** — adding PSD raises energy (penalty lemma)
10. **`energy_monotone_of_psd_le`** — energy monotone in PSD order
11. `localHamiltonianPromise` — Local Hamiltonian problem is a well-defined promise problem
12. `frustration_free_local` — frustration-free characterization for local Hamiltonians

All proofs use only standard axioms (propext, Classical.choice, Quot.sound). Both files include FUTURE DIRECTIONS sections with 5 falsifiable conjectures each.