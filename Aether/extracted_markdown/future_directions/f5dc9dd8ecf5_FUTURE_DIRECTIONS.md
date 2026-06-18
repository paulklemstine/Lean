# Future Directions

## Synthesis

This research cycle established the **Signal Collision Algebra (SCA)** as a novel algebraic framework for proving computational universality of cellular automata. The central insight — that universality reduces to three algebraic properties (NAND, fanout, crossing) of signal collisions — connects cellular automata theory to abstract algebra and circuit complexity in a way that has not been previously formalized.

The cycle produced 14 formally verified theorems, including the main circuit simulation theorem (linear overhead), GoL SCA completeness, product closure, morphism bounds, and concrete GoL dynamics results (empty board fixed point, isolated cell death). The one remaining open theorem — constructive NAND completeness (building a NAND circuit for an arbitrary Boolean function) — reveals a gap between classical existence and constructive exhibition that is itself mathematically interesting.

The most promising cross-domain connection is between the SCA framework and the existing Berggren orbit Turing completeness results in the Catalog (`Pythagorean/BerggrenCA.lean`). Both use signal-based computation on structured lattices, but the Berggren work operates on tree-structured addresses while the SCA framework operates on ℤ². A unified framework could capture universality across diverse geometric substrates.

---

### Direction 1: SCA Classification of Elementary Cellular Automata

**Conjecture**: Among the 256 elementary (1D, 2-state, radius-1) cellular automata, exactly 4 rules admit complete Signal Collision Algebras: Rules 110, 54, 124, and 137 (up to left-right/complement symmetry).

**Test**: For each of the 88 equivalence classes of elementary CA rules, attempt to construct a complete 1D SCA. For rules known to be non-universal (e.g., rules with additive structure like Rule 90), prove that no complete SCA exists by showing the signal collision structure is too constrained. For Rule 110 (known to be universal), construct the SCA explicitly.

**Impact**: If confirmed, this would provide the first algebraic classification of universality for elementary CAs, complementing the computational complexity approach of Cook (2004). If false, the counterexample would reveal a CA that is universal through a mechanism other than signal collisions — a fundamentally new type of computation.

**Catalog References**: `Novelty/CellularAutomata/Defs.lean`, `Novelty/CellularAutomata/Theorems.lean`

**Proof Strategy**: Define a 1D SCA variant (signals have scalar velocity on ℤ). For each candidate rule, enumerate possible signal types (periodic traveling patterns up to period 20). Check collision outcomes computationally. For the impossibility direction, prove that rules with certain symmetries (e.g., additive rules over GF(2)) cannot have NAND-type collisions because all collisions are linear.

**Domain Bridges**: Novelty (SCA framework) <-> Tropical (automata theory in `Tropical/CA/Defs.lean`)

**Lineage**: Extends the SCA framework from this cycle (2D → 1D specialization).

**Ambition**: grand_challenge

---

### Direction 2: SCA Complexity Classes — Collision Depth vs. Circuit Depth

**Conjecture**: The *collision depth* of a Boolean function f in a given SCA (minimum number of sequential collisions needed to compute f) equals the NAND circuit depth of f up to a multiplicative constant depending only on the SCA's wire delay.

**Test**: For specific Boolean functions with known circuit depth (e.g., parity has depth Θ(log n), majority has depth Θ(log n)), compute the collision depth in the GoL SCA and verify the relationship. If the conjecture holds, the constant should be exactly (wireDelay + 1) = 5 for GoL.

**Impact**: This would establish SCA complexity as a faithful representation of circuit complexity, justifying the use of collision algebras as a complexity-theoretic tool. If false, it would reveal that geometric constraints of signal propagation introduce a computational overhead beyond what circuit theory predicts — a new complexity-theoretic phenomenon.

**Catalog References**: `Novelty/CellularAutomata/Theorems.lean` (simulation_overhead_linear, chain_circuit_needs_linear_time)

**Proof Strategy**: Upper bound: use the layout construction from `complete_sca_simulates_circuits` (already proven). Lower bound: extend `chain_circuit_needs_linear_time` to arbitrary circuits by showing that the causality constraints in the layout correspond exactly to the critical path in the circuit DAG. The key lemma: for any layout, the total time is at least (wireDelay + 1) × circuit_depth.

**Domain Bridges**: Novelty (SCA) <-> Computation (complexity theory in `Computation/GravityOracle.lean`)

**Lineage**: Direct extension of simulation overhead results from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical SCA — Signal Algebras over Min-Plus Semirings

**Conjecture**: There exists a natural "tropicalization" of Signal Collision Algebras where Boolean values are replaced by elements of the tropical semiring (ℝ ∪ {∞}, min, +), and NAND is replaced by the tropical analogue min(a, b) + c for a constant c. A tropical SCA with the min-gate, tropical-fanout, and tropical-crossing primitives can simulate tropical circuits (min-plus matrix multiplication chains) with linear overhead.

**Test**: Define a tropical SCA structure with the same signal types as GoL but with tropical collision rules. Construct a tropical circuit for min-plus matrix multiplication of two 2×2 matrices and simulate it through the tropical SCA. Verify the overhead bound computationally.

**Impact**: This would create a bridge between cellular automata theory and tropical geometry/optimization, connecting to the existing tropical research thread (`Tropical/TropicalDeepResearch.lean`). The Turing simulation width bound in the Catalog could be reinterpreted as a tropical SCA overhead bound. If the tropicalization fails, it would reveal a fundamental difference between Boolean and tropical computation in the CA setting.

**Catalog References**: `Tropical/TropicalDeepResearch.lean` (turing_simulation_width_bound), `Novelty/CellularAutomata/Defs.lean`

**Proof Strategy**: Replace `Bool` with `WithTop ℝ` (reals with infinity) in the SCA definition. Replace NAND's `¬(a ∧ b)` with `min(a, b) + delay_cost`. Prove that tropical circuits (min-plus expressions) can be simulated with the same layout construction, noting that the causality constraints are identical. The key challenge is defining what "tropical completeness" means — likely min, addition, and a constant (analogous to NAND being functionally complete for Boolean logic).

**Domain Bridges**: Novelty (SCA) <-> Tropical (min-plus algebra) <-> Algebra (semiring theory)

**Lineage**: Builds on SCA framework from this cycle + tropical research thread in Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Constructive NAND Completeness via Shannon Decomposition

**Conjecture**: Every Boolean function f : {0,1}^n → {0,1} with n ≥ 1 can be realized by a NAND circuit with at most 3n · 2^n gates, constructively (no use of `Classical.choice`), via iterated Shannon decomposition.

**Test**: Formalize the Shannon decomposition circuit builder in Lean 4: `f(x₁, ..., xₙ) = (x₁ ∧ f(1, x₂, ..., xₙ)) ∨ (¬x₁ ∧ f(0, x₂, ..., xₙ))`. Each Shannon step reduces the number of variables by 1 and introduces O(n) NAND gates (for AND, OR, NOT). The base case (n = 0) requires only a constant circuit. Verify the gate count bound.

**Impact**: This would close the one remaining sorry in the current formalization (`nand_universal`), making the GoL computational universality theorem fully machine-verified. It would also provide an explicit, constructive proof of functional completeness of NAND — a result that is folklore but rarely formalized constructively.

**Catalog References**: `Novelty/CellularAutomata/Theorems.lean` (nand_universal, passthrough_eval, not_circuit_eval)

**Proof Strategy**: Define a recursive `BoolCircuit` builder by induction on n. For n = 1, enumerate the 4 possible functions and exhibit circuits for each. For n+1, use Shannon decomposition: build circuits for f(1, ·) and f(0, ·) by recursion, then combine using AND/OR/NOT subcircuits (each built from a constant number of NAND gates). The key challenge is defining circuit concatenation — appending one circuit's gates to another while adjusting wire indices.

**Domain Bridges**: Novelty (SCA framework) <-> Logic (constructive mathematics)

**Lineage**: Directly addresses the open sorry from this cycle.

**Ambition**: extension

---

### Direction 5: SCA Morphisms and Simulation Preorders

**Conjecture**: The class of complete SCAs, ordered by the existence of SCA morphisms, forms a preorder that is dense: between any two complete SCAs with |signals₁| < |signals₂|, there exists a complete SCA with intermediate signal count.

**Test**: Construct a family of complete SCAs indexed by natural numbers: SCA_n has exactly n+3 signal types (3 base types from GoL plus n auxiliary types). Show that for each n, there exists an SCA morphism from SCA_n to SCA_{n+1} but not vice versa.

**Impact**: This would reveal the fine structure of computational universality — not all universal CAs are created equal, and the SCA morphism preorder captures their relative complexity. If the density conjecture fails, there would be "gaps" in the universality hierarchy, suggesting discrete phase transitions in computational capability.

**Catalog References**: `Novelty/CellularAutomata/Theorems.lean` (SCAMorphism, sca_morphism_card_le, product_complete)

**Proof Strategy**: Use the product construction (already proven to preserve completeness) to build SCA_n = GoL_SCA × {aux_1, ..., aux_n}. The morphism from SCA_n to SCA_{n+1} is the natural inclusion. The non-existence of a reverse morphism follows from the signal count inequality (`sca_morphism_card_le`). Density follows from the product construction's ability to add one signal type at a time.

**Domain Bridges**: Novelty (SCA) <-> Algebra (preorder theory, lattice theory)

**Lineage**: Extends morphism and product results from this cycle.

**Ambition**: extension
