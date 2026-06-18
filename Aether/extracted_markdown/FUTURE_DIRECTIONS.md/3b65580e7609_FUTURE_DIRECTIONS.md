# Future Directions: Hennessy–Milner Completeness and Beyond

## Synthesis

The Hennessy–Milner completeness theorem for image-finite LTS establishes the fundamental interface between modal logic and behavioral equivalence. The verified proof architecture—finite conjunctions as logical separators, the transfer property via contradiction, and the algorithmic bridge to partition refinement—opens five interconnected research directions spanning modal depth bounds, algorithmic verification, coalgebraic generalization, characteristic formulas, and decidability theory.

These directions form a coherent research program: Direction 1 (depth bounds) provides the complexity analysis that makes Direction 2 (verified algorithms) practical; Direction 3 (coalgebra) generalizes the framework that Direction 4 (characteristic formulas) instantiates; and Direction 5 (decidability) provides the theoretical foundation for all computational applications.

Each direction builds directly on the formalized catalog theorems and is stated with sufficient precision to be falsifiable through computation or further formalization.

---

## Direction 1: Modal Depth Bounds via Refinement Rank

**Conjecture**: For every finite image-finite LTS M and non-bisimilar states s, t, there exists an HM distinguishing formula of modal depth at most the partition refinement stabilization depth of (M, s, t).

**Test**: Exhaustive computation over all LTS with |State| ≤ 8 and |Act| = 2. For each non-bisimilar pair, compute (a) the minimum modal depth of a distinguishing formula by brute-force enumeration, and (b) the partition refinement stabilization depth. Verify that (a) ≤ (b) in all cases.

**Impact**: This would give a tight, efficiently computable upper bound on the "logical complexity" of behavioral distinctions. It would connect the proof-theoretic content of the Hennessy–Milner theorem to the algorithmic complexity of partition refinement, enabling complexity-aware model checking.

**Catalog References**:
- `Catalog/HennessyMilner.lean`: `modalDepth`, `exists_finitary_separator`, `hm_equiv_transfer_of_imageFinite`
- `Catalog/Pythagorean/YonedaBisimulation/Correspondence.lean`: `bisimilar_implies_hm_equiv`

**Proof Strategy**: The separator construction in the transfer proof builds formulas of depth ≤ 1 + max(depth of sub-separators). By induction aligned with the partition refinement rounds, each round corresponds to at most one additional modal depth. The key lemma is that states distinguished at refinement round k are distinguishable by formulas of depth ≤ k.

**Domain Bridges**: Computational complexity theory (relating logical depth to algorithmic rounds); automata theory (connecting formula depth to Büchi automaton size).

**Lineage**: Hennessy–Milner [1985] → Stirling [2001] depth analysis → Paige–Tarjan [1987] algorithmic complexity.

**Ambition**: Medium-high. The conjecture is widely believed but has not been formally verified. A proof would establish a certified complexity bridge between logic and algorithms.

---

## Direction 2: Verified Paige–Tarjan Partition Refinement

**Conjecture**: The Paige–Tarjan partition refinement algorithm can be formalized in Lean 4 with a verified correctness proof showing that its output is the coarsest bisimulation-stable partition, with certified O(|Act| · |→| · log|S|) complexity.

**Test**: Implement the algorithm in Lean 4 with explicit complexity annotations. Verify correctness on benchmark LTS (VLTS benchmark suite). Compare output with the naive partition refinement formalized in `algorithms.py`.

**Impact**: A verified minimization algorithm would enable certified state-space reduction in model checking pipelines. Combined with the Hennessy–Milner theorem, it would provide end-to-end verification that the minimized system preserves all HM-expressible properties.

**Catalog References**:
- `Catalog/HennessyMilner.lean`: `hm_equiv_is_bisimulation_of_imageFinite`, `separator_induces_distinction`
- `Catalog/Pythagorean/YonedaBisimulation/Properties.lean`: `bisimUnion_is_bisimulation`

**Proof Strategy**: Define a `PartitionState` type tracking the current partition and a `refine_step` function. Prove that each step preserves soundness (all states in the same block are bisimilar in the final partition) and that termination follows from the strict decrease of partition cardinality.

**Domain Bridges**: Software verification (certified compilation of reactive systems); hardware verification (minimization of circuit models).

**Lineage**: Paige–Tarjan [1987] → Fernandez [1990] adaptation for CCS → present formalization.

**Ambition**: High. This is an engineering-heavy direction requiring careful treatment of data structures and complexity.

---

## Direction 3: Coalgebraic Generalization to Finite Powerset Functor

**Conjecture**: The Hennessy–Milner completeness theorem generalizes to coalgebras for the labeled finite powerset functor P_f(−)^Act, where the modal logic is the Moss predicate lifting logic, and the finite conjunction construction works uniformly for any finitary functor.

**Test**: Define the finite powerset functor in Lean 4. Formalize the Moss cover modality. Instantiate the general completeness theorem to recover the HM theorem as a special case. Verify that the finite conjunction construction from `listConj` lifts to the general setting.

**Impact**: A coalgebraic generalization would unify the HM theorem with similar results for probabilistic systems (Larsen–Skou), weighted systems, and game-theoretic models. It would establish the formalized framework as a foundation for multi-domain behavioral equivalence theory.

**Catalog References**:
- `Catalog/HennessyMilner.lean`: `listConj`, `satisfies_listConj_iff`, `ImageFiniteLTS`
- `Catalog/Pythagorean/YonedaBisimulation/Defs.lean`: `LTS`, `IsBisimulation`

**Proof Strategy**: Replace `LTS` with a coalgebra structure `State → F(State)` for a functor F. Define Moss-style modalities as predicate liftings. Show that image-finiteness corresponds to F preserving finite sets. The finite conjunction construction generalizes to predicate lifting composition over finite supports.

**Domain Bridges**: Category theory (functorial semantics); probability theory (probabilistic bisimulation via distribution functors).

**Lineage**: Rutten [2000] universal coalgebra → Pattinson [2003] coalgebraic modal logic → Schröder [2008] expressiveness.

**Ambition**: Grand challenge. This would transform the formalization from a specific result about LTS into a general framework for behavioral equivalence across mathematical domains.

---

## Direction 4: Characteristic Formulas for Finite Image-Finite LTS

**Conjecture**: Every state s in a finite image-finite LTS admits a characteristic HM formula φ_s such that t ⊨ φ_s if and only if t ~ s, with modal depth bounded by the number of partition refinement rounds.

**Test**: For all LTS with |State| ≤ 6 and |Act| = 2, construct characteristic formulas by depth-bounded search and verify that they exactly characterize bisimulation classes. Measure formula size and depth as a function of system size.

**Impact**: Characteristic formulas would enable "explainable verification": instead of a yes/no answer to bisimilarity, provide a human-readable formula explaining *why* two states are equivalent (they satisfy the same characteristic formula) or different (one fails the other's characteristic formula).

**Catalog References**:
- `Catalog/HennessyMilner.lean`: `exists_finitary_separator`, `hm_equiv_iff_bisimilar_of_imageFinite`, `modalDepth`

**Proof Strategy**: Define characteristic formulas recursively: φ_s = ⋀_a [a](⋁_{s'∈succs(s,a)} φ_{s'}) ∧ ⋀_a ⟨a⟩(⋁_{s'∈succs(s,a)} φ_{s'}). The depth bound follows from the partition refinement analysis of Direction 1. Correctness follows from the Hennessy–Milner theorem: φ_s exactly captures the HM-equivalence class of s.

**Domain Bridges**: Explainable AI (human-readable behavioral certificates); software testing (generating distinguishing test cases from formulas).

**Lineage**: Aceto–Ingólfsdóttir [1999] characteristic formulas → Cleaveland [1990] concurrency workbench.

**Ambition**: Medium. The construction is well-understood classically; the challenge is the formal verification and depth analysis.

---

## Direction 5: Decidability of HM-Equivalence for Finite Systems

**Conjecture**: For finite-state image-finite LTS, HM-equivalence is decidable, with decision complexity matching partition refinement (O(|Act| · |→| · log|S|)).

**Test**: Formalize a decision procedure in Lean 4 as a `DecidableRel (HMEquiv M.toLTS M.toLTS)` instance for finite M. Verify that it agrees with partition refinement on all LTS with |State| ≤ 10.

**Impact**: A verified decision procedure would complete the pipeline from specification to verified checking. Combined with the Hennessy–Milner theorem, it would provide a formally certified tool for bisimilarity checking in finite-state systems.

**Catalog References**:
- `Catalog/HennessyMilner.lean`: `hm_equiv_iff_bisimilar_of_imageFinite`, `ImageFiniteLTS`
- `Catalog/Pythagorean/YonedaBisimulation/Properties.lean`: `bisimilar_refl`, `bisimilar_symm`, `bisimilar_trans`

**Proof Strategy**: For finite M, partition refinement terminates in ≤ |S| rounds. The final partition determines bisimilarity. Using `hm_equiv_iff_bisimilar_of_imageFinite`, decidability of bisimilarity implies decidability of HM-equivalence.

**Domain Bridges**: Complexity theory (P-completeness of bisimulation checking); database theory (bisimulation-based XML query optimization).

**Lineage**: Kanellakis–Smolka [1990] decidability of bisimulation → Groote–Vaandrager [2005] branching bisimulation.

**Ambition**: Medium. The result is well-known; the formalization challenge is bridging the algorithm-theory gap in Lean 4's type theory.
