# Future Directions: Equivariant Impossibility Theory

## Synthesis

The equivariant task framework established in this work provides the first formal language unifying impossibility phenomena across algebra, combinatorics, and social choice theory. The five directions below extend this foundation in complementary ways: two grand-challenge conjectures (Directions 1 and 2) aim to subsume deep topological and algebraic impossibility results within the framework, while three concrete extensions (Directions 3–5) build directly on the formalized theorems to strengthen computational tools, generalize the stabilizer criterion, and connect to noncommutative physics. Together, they constitute a research program that could establish equivariant obstruction theory as a fundamental organizing principle across mathematics.

---

## Direction 1: Topological Equivariant Obstruction — Borsuk-Ulam as an Equivariant Task

**Conjecture:** The Borsuk-Ulam theorem (every continuous map f : Sⁿ → Rⁿ has a point x with f(x) = f(−x)) is an instance of the equivariant task framework extended to continuous group actions with topological admissibility constraints. Specifically, the Z/2Z-action on Sⁿ by the antipodal map generates an equivariant task whose impossibility (no equivariant map Sⁿ → Rⁿ \ {0}) follows from a cohomological obstruction that generalizes our algebraic fixed-point emptiness argument.

**Test:** Formalize the Z/2Z equivariant task on Sⁿ in Lean 4 using Mathlib's topological group action infrastructure. Prove the n = 1 case (which reduces to the intermediate value theorem) as a concrete equivariant task impossibility. If the formalization succeeds, attempt n = 2 using degree theory.

**Impact:** This would demonstrate that equivariant task impossibility extends from discrete algebra to continuous topology, unifying the combinatorial Borsuk-Ulam (Tucker's lemma) with its continuous form under one framework. It would also connect to ham sandwich theorems, necklace splitting, and fair division — each interpretable as equivariant tasks.

**Catalog References:** `Catalog/Speculative/EquivariantImpossibility/Core.lean` (EquivariantTask, fixedpoint_task_impossible_of_free_nontrivial)

**Proof Strategy:** Define a continuous equivariant task structure extending `EquivariantTask` with a topological admissibility condition. The key step is showing that the Z/2Z fixed-point set of the target Rⁿ \ {0} has the wrong homotopy type to admit a section over Sⁿ. Use equivariant cohomology (or its Lean formalization if available) to derive the obstruction class.

**Domain Bridges:** Topology ↔ Combinatorics ↔ Fair Division ↔ Algebraic Topology

**Lineage:** Extends Theorem A (no equivariant constant map) from discrete to continuous groups.

**Ambition:** Grand challenge — would establish equivariant tasks as the natural language for topological fixed-point theory.

**The key insight is** that the algebraic obstruction (empty fixed-point set) we proved for discrete free actions has a topological analogue: the Z/2Z fixed-point set of Rⁿ \ {0} is empty, and this emptiness is detected by equivariant cohomology rather than by elementary set theory. The discrete and continuous cases share the same structural DNA.

**Why now?** Mathlib's topology library has matured to include fundamental group computations, covering spaces, and basic homotopy theory. The n = 1 case of Borsuk-Ulam is within reach of current Lean formalization technology, and success there would provide a template for higher dimensions.

---

## Direction 2: Galois Obstruction — Radical Unsolvability as Equivariant Task Failure

**Conjecture:** The Abel-Ruffini theorem (no radical formula for the general quintic) is equivalent to the non-existence of an equivariant selector for the roots of a polynomial under the Galois group action. Specifically, define an equivariant task where X = coefficient space, Y = root space, and G = Gal(f/Q) acts on both. The task is solvable by radicals iff the Galois group is solvable, which for the general quintic (G = S₅) fails because S₅ is non-solvable.

**Test:** Formalize the relationship between solvable Galois groups and equivariant radical selectors for polynomials of degree ≤ 4 (where radical formulas exist). Verify computationally that S₅ acting on 5-element root sets admits no equivariant "nested radical" selector — model this as a tower of equivariant tasks through normal subgroups.

**Impact:** Would provide the first formal bridge between Galois theory and equivariant task theory, reinterpreting one of the oldest impossibility results in mathematics within a modern unified framework.

**Catalog References:** `Catalog/Speculative/EquivariantImpossibility/Core.lean` (EquivariantTask, no_equivariant_constant_social_choice — analogous structure)

**Proof Strategy:** Model radical extensions as successive equivariant task solutions through the derived series of the Galois group. Each radical extraction is an equivariant section of a cyclic quotient. The tower succeeds iff the group is solvable. Formalize this by defining a "solvability tower" of equivariant tasks and proving it admits a solution iff the group admits a composition series with abelian factors.

**Domain Bridges:** Algebra ↔ Galois Theory ↔ Field Theory ↔ Constructibility

**Lineage:** Extends the social choice theorem (Theorem 3.6) from S_n acting on candidates to S_n acting on polynomial roots.

**Ambition:** Grand challenge — would reinterpret 200 years of Galois theory through equivariant obstruction.

**The key insight is** that a radical formula is precisely an equivariant selector: it takes symmetric functions of the roots (the coefficients) and produces a root in a way that tracks permutations of roots through the radical operations. The obstruction to such a selector — non-solvability of S₅ — is exactly the obstruction to decomposing a free transitive S₅-action into a tower of cyclic equivariant tasks.

**Why now?** Mathlib now includes substantial Galois theory (field extensions, splitting fields, solvable groups). The equivariant task framework provides the missing conceptual bridge to connect these algebraic ingredients into a unified impossibility statement.

---

## Direction 3: Automated Impossibility Detection for Finite Groups

**Conjecture:** The stabilizer criterion (a task on a transitive G-set is solvable iff each orbit representative admits a stabilizer-compatible admissible output) is both necessary and sufficient for equivariant task solvability on finite groups with transitive action. Furthermore, this criterion can be decided in polynomial time in |G| · |X| · |Y|.

**Test:** Implement the criterion and test exhaustively for all transitive actions of groups of order ≤ 12 with target sets of size ≤ 6. Run the brute-force solvability check in parallel and compare. Report any counterexample or confirm the criterion holds for all tested cases. Aim for ≥ 10,000 task instances.

**Impact:** If confirmed, this would provide a polynomial-time decision procedure for equivariant task solvability, replacing exponential brute-force enumeration. This has practical applications in automated symmetry reduction for constraint satisfaction problems.

**Catalog References:** `Catalog/Speculative/EquivariantImpossibility/Core.lean` (EquivariantTask, TaskSolvable); `algorithms.py` (enumerate_equivariant_maps, stabilizer criterion test)

**Proof Strategy:** The forward direction (criterion → solvable) is constructive: given stabilizer-compatible values at representatives, extend equivariantly. The reverse direction (solvable → criterion) follows from restricting a solution to orbit representatives. Formalize both directions in Lean 4 for the finite case using Fintype and DecidableEq.

**Domain Bridges:** Combinatorics ↔ Constraint Satisfaction ↔ Computational Group Theory

**Lineage:** Directly extends the computational experiments in Section 5.3 of the research paper.

**Ambition:** Solid extension — formalizes and proves the computational tool that enables all subsequent testing.

**The key insight is** that equivariant maps on transitive actions are completely determined by their value at one basepoint, and the only constraint is stabilizer compatibility. This reduces an exponential search (|Y|^|X| candidates) to a linear one (|Y| candidates at the basepoint, each checked against |Stab(x₀)| group elements).

**Why now?** The computational infrastructure (algorithms.py, demo.py) is already in place. The formal proof requires only finite group theory ingredients already in Mathlib (Fintype, MulAction, stabilizer).

---

## Direction 4: Equivariant Tasks with Multiple Symmetries — Noncommutative Obstruction

**Conjecture:** When two non-commuting groups G₁ and G₂ both act on a space X, the existence of a map that is simultaneously equivariant with respect to both actions is obstructed whenever the combined symmetry group ⟨G₁, G₂⟩ acts freely. This "noncommutative equivariant obstruction" captures the essence of Heisenberg uncertainty: position translations and momentum translations generate a noncommutative group, and no state can be simultaneously sharp (equivariantly selected) under both.

**Test:** Formalize a finite model: let X = Z/pZ × Z/pZ, with G₁ = Z/pZ acting by horizontal translation and G₂ = Z/pZ acting by vertical translation. Define a "simultaneous localization task" requiring a map that is equivariant under both. Prove this is impossible when p > 1, and connect to the discrete Fourier transform structure.

**Impact:** Would extend equivariant impossibility from single-group obstructions to multi-group obstructions, capturing quantum-mechanical impossibilities within the same algebraic framework.

**Catalog References:** `Catalog/Speculative/EquivariantImpossibility/Core.lean` (no_equivariant_constant_on_free_nontrivial — single-group version)

**Proof Strategy:** Show that simultaneous equivariance under non-commuting translations forces the map to be invariant under the full Heisenberg group (generated by both translations plus their commutator). Since this group acts freely on Z/pZ × Z/pZ (for p prime), Theorem A applies to yield impossibility.

**Domain Bridges:** Abstract Algebra ↔ Quantum Mechanics ↔ Signal Processing ↔ Harmonic Analysis

**Lineage:** Extends Theorem A from single groups to pairs of non-commuting groups.

**Ambition:** Solid extension with grand-challenge potential — the finite model is tractable, but the continuous limit touches deep physics.

**The key insight is** that non-commutativity of symmetries amplifies the equivariant obstruction: while a single cyclic group acting freely on Z/pZ still admits p equivariant self-maps (the translations), requiring equivariance under two non-commuting copies of Z/pZ can reduce this to zero, paralleling the quantum uncertainty principle.

**Why now?** The finite Heisenberg group over Z/pZ is well-studied and small enough for both formal verification and computational experiments. Mathlib includes the necessary finite group theory, and the equivariant task framework is ready to be extended.

---

## Direction 5: Equivariant Impossibility in Machine Learning — Symmetry-Breaking in Neural Architectures

**Conjecture:** Equivariant neural networks (networks whose layers commute with group actions) cannot learn functions that break symmetry — specifically, they cannot approximate constant equivariant maps on free actions. This is a direct machine-learning consequence of Theorem A: an equivariant network is limited to learning equivariant functions, and Theorem A shows that constant functions are not among them when the action is free and nontrivial.

**Test:** Train equivariant neural networks (e.g., using the e3nn library) on regression tasks that require symmetry-breaking outputs. Measure the gap between the target function and the best equivariant approximation. Compare with the theoretical lower bound implied by Theorem A.

**Impact:** Would provide theoretical guarantees about the expressivity limitations of equivariant architectures, guiding architecture design in geometric deep learning. Current practice relies on empirical observation; formal impossibility results would provide principled guidance.

**Catalog References:** `Catalog/Speculative/EquivariantImpossibility/Core.lean` (Theorem A, Theorem C — injectivity of equivariant maps)

**Proof Strategy:** Show that the space of equivariant maps X → X (for a free transitive G-action) is exactly the space of group translations, which is a finite set of measure zero in the space of all maps. Therefore, any non-equivariant target function has a positive approximation error under equivariant networks.

**Domain Bridges:** Pure Mathematics ↔ Machine Learning ↔ Geometric Deep Learning ↔ Representation Theory

**Lineage:** Applies Theorems A and C to the function spaces studied in geometric deep learning.

**Ambition:** Solid extension — connects formal impossibility to practical ML architecture design.

**The key insight is** that equivariant neural networks are constrained to learn from the (typically small) space of equivariant functions, and our theorems precisely characterize what this space contains and what it excludes. This turns abstract impossibility into concrete expressivity bounds for neural architectures.

**Why now?** Equivariant neural networks (SE(3)-transformers, SchNet, MACE) are deployed in drug discovery, materials science, and molecular dynamics. Understanding their theoretical limitations is becoming critical as they are applied to increasingly challenging tasks where symmetry-breaking phenomena (phase transitions, spontaneous symmetry breaking) are physically important.
