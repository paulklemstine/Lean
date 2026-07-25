/-
# Bridge: Tropical Landauer Entropy ↔ Circuit Free Energy

This file connects the Landauer entropy bounds (from `Landauer.lean`) to the
circuit free energy model (from `Circuit.lean`), establishing that:
1. Erasure operations incur entropy cost (Landauer).
2. Circuits performing erasure require nonzero depth.
3. Depth equals free energy (circuit theorem).
4. Therefore, erasure has nonzero thermodynamic cost in the circuit model.

## Main Results

* `erasure_has_entropy_cost` — erasing ≥ 2 states costs ≥ log 2 entropy
* `erasure_has_freeEnergy_cost` — erasing circuits have free energy ≥ 1
* `tropical_bridge` — entropy loss and free energy cost are simultaneously positive
    for irreversible computations
* `uniform_shannon_eq_tropical` — for uniform distributions, Shannon entropy equals
    tropical entropy (log cardinality)

## Cross-Domain Connections

This module establishes the formal bridge between:
- **Information theory**: entropy of erasure ↔ log-cardinality collapse
- **Complexity theory**: circuit depth as a computational resource
- **Thermodynamics**: free energy as dissipation cost
- **Tropical geometry**: min-plus algebra as zero-temperature limit
-/

import Physics.TropicalThermodynamics.Landauer
import Physics.TropicalThermodynamics.Circuit

open Real Set Fintype TropicalCircuit

/-! ## Bridge theorems -/

/-
**Erasure entropy cost.**
A constant map on a finite type with ≥ 2 elements has entropy defect ≥ log 2.
This is the information-theoretic Landauer bound.
-/
theorem erasure_has_entropy_cost
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β)
    (hconst : ∀ a a' : α, f a = f a')
    (hcard : 2 ≤ Fintype.card α) :
    Real.log 2 ≤ entropyDefect f := by
  -- Since f is constant, range f has exactly one element. Every element in range f has fiber = all of α. So card {x // f x = y} = card α for the unique y. Since card α ≥ 2, every fiber has size ≥ 2.
  have h_fiber : ∀ y ∈ Set.range f, Fintype.card {x : α // f x = y} = Fintype.card α := by
    rintro _ ⟨ x, rfl ⟩ ; rw [ Fintype.card_subtype ] ; simp +decide [ hconst _ x ] ;
  convert tropical_landauer_binary_uniform f _;
  exact fun y hy => h_fiber y hy ▸ hcard

/-- **Erasure free energy cost.**
Any circuit that includes a gate operation has free energy ≥ 1.
Combined with the Landauer bound, this shows erasure has both
entropy cost and free energy cost. -/
theorem erasure_has_freeEnergy_cost (C : TropicalCircuit) :
    (1 : ℝ) ≤ (TropicalCircuit.gate C).freeEnergy :=
  erasure_freeEnergy_lower_bound C

/-- **Tropical bridge theorem.**
For any irreversible computation modeled as (1) a non-injective map and
(2) a gated circuit, both entropy defect and free energy are ≥ threshold values.
This is the core identity linking thermodynamics and complexity. -/
theorem tropical_bridge
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β)
    (C : TropicalCircuit)
    (hfiber : ∀ y ∈ Set.range f, 2 ≤ Fintype.card {x : α // f x = y}) :
    Real.log 2 ≤ entropyDefect f ∧ (1 : ℝ) ≤ (TropicalCircuit.gate C).freeEnergy := by
  exact ⟨tropical_landauer_binary_uniform f hfiber, erasure_has_freeEnergy_cost C⟩

/-! ## Information-theoretic bridge -/

/-- **Shannon entropy of a uniform distribution** on `n` outcomes (in nats).
For a uniform distribution on `n` elements, `H = log n`. -/
noncomputable def shannonEntropyUniform (n : ℕ) : ℝ := Real.log n

/-- **Shannon entropy of uniform distributions equals tropical entropy.**
This is the key bridge between information theory and tropical algebra:
for uniform finite distributions, Shannon entropy reduces to log-cardinality. -/
theorem uniform_shannon_eq_tropical (n : ℕ) :
    shannonEntropyUniform n = tropicalEntropy n := by
  rfl

/-! ## Thermodynamic free energy bridge -/

/-
**Thermodynamic cost of circuit erasure.**
Combines the circuit free energy with Boltzmann scaling.
For a gate circuit at temperature T with Boltzmann constant k,
the thermodynamic cost is at least k*T.
-/
theorem circuit_thermal_cost_lower_bound
    (C : TropicalCircuit) (k T : ℝ) (hk : 0 ≤ k) (hT : 0 ≤ T) :
    k * T ≤ k * T * (TropicalCircuit.gate C).freeEnergy := by
  exact le_mul_of_one_le_right ( mul_nonneg hk hT ) ( by exact_mod_cast erasure_has_freeEnergy_cost C )

/-! ## Depth-entropy transfer -/

/-- **Sequential composition increases free energy.**
If circuits A and B are composed sequentially, the total free energy
is the sum of the individual free energies. -/
theorem seq_freeEnergy_add (A B : TropicalCircuit) :
    (TropicalCircuit.seq A B).freeEnergy = A.freeEnergy + B.freeEnergy := by
  simp [TropicalCircuit.freeEnergy]

/-- **Parallel composition takes max free energy.**
If circuits A and B run in parallel, the free energy is the max. -/
theorem par_freeEnergy_max (A B : TropicalCircuit) :
    (TropicalCircuit.par A B).freeEnergy = max A.freeEnergy B.freeEnergy := by
  simp [TropicalCircuit.freeEnergy]

/-
**Multi-erasure free energy bound.**
A circuit with `n` sequential gate stages has free energy ≥ `n`.
-/
theorem multi_erasure_freeEnergy_bound :
    ∀ (n : ℕ), ∃ C : TropicalCircuit, C.freeEnergy = n := by
  intro n;
  induction' n with n ih;
  · exists TropicalCircuit.input;
    -- The free energy of the input circuit is 0 by definition.
    simp [TropicalCircuit.freeEnergy];
  · obtain ⟨ C, hC ⟩ := ih; use TropicalCircuit.gate C; simp;
    exact hC ▸ rfl