# Future Directions: Yoneda-Bisimulation Correspondence

## Synthesis

The Yoneda-Bisimulation Correspondence reveals that the most fundamental principle in category theory — the Yoneda lemma — directly produces the canonical equivalence of concurrent systems. This opens five interconnected research directions: (1) completing the formal correspondence for non-deterministic image-finite systems via Hennessy-Milner completeness, (2) lifting the correspondence to enriched categories to capture probabilistic and quantum bisimulation, (3) developing the topos-theoretic semantics of process logics through the internal logic of presheaf categories, (4) connecting bisimulation cohomology to higher-dimensional concurrent phenomena, and (5) applying the categorical framework to causal and distributed systems via bicategorical Yoneda extensionality. Each direction builds on the formalized infrastructure (LTS, bisimulation, HM logic, nerve construction) and extends the central insight — *naturality is zigzag* — into new mathematical and computational domains.

---

## Direction 1: Hennessy-Milner Completeness via Finite Distinguishing Formulas

**Conjecture:** For image-finite LTS, HM-equivalence is a bisimulation. Specifically: if `s` and `t` are HM-equivalent, and `s →[a] s'`, then there exists `t'` with `t →[a] t'` and `HMEquiv s' t'`. The key step is constructing the finite conjunction `⋀_{t' ∈ succs(t,a)} φ_{t'}` of distinguishing formulas.

**Test:** Formalize the proof using `Finset`-valued successor functions. For each non-HM-equivalent pair `(s', t')`, choose a distinguishing formula `φ_{t'}`. Form the finite conjunction. Show that `s ⊨ ⟨a⟩(⋀ φ_{t'})` but no `a`-successor of `t` satisfies `⋀ φ_{t'}`, contradicting HM-equivalence of `s` and `t`. Verify on all LTS with ≤ 6 states over `Act = {a, b}`.

**Impact:** Completes the formal Yoneda-Bisimulation Correspondence for the standard (non-deterministic, image-finite) case. This is the most immediate and high-value extension.

**Catalog References:** `Pythagorean/YonedaBisimulation/Correspondence.lean` — builds directly on `bisimilar_implies_hm_equiv` and `hm_box_iff`.

**Proof Strategy:** Define `ImageFinite P` as providing `Finset`-valued successor functions. Use Finset.sup to construct the conjunction. The well-foundedness argument uses the fact that distinguishing formulas have bounded depth (equal to the partition refinement depth).

**Domain Bridges:** Connects to partition refinement algorithms (Paige-Tarjan), decidability theory for modal logics, and automata-theoretic verification.

**Lineage:** Hennessy-Milner (1985), Stirling (1995), Sangiorgi (2011).

**Ambition:** Solid extension — completes a known result in a new formal framework. ★★★☆☆

---

## Direction 2: Enriched Nerve Presheaves for Probabilistic and Quantum Bisimulation

**Conjecture:** For probabilistic LTS (where transitions carry probability distributions), the nerve presheaf takes values in the category of measurable spaces rather than sets. Natural isomorphism in this enriched presheaf category recovers *probabilistic bisimulation* (Larsen-Skou equivalence). For quantum LTS (transitions are completely positive maps), the presheaf takes values in the category of operator spaces, and naturality recovers *quantum bisimulation*.

**Test:** Formalize probabilistic LTS with `State → Act → State → ℝ≥0∞` transition kernels. Define the enriched nerve as a measurable-space-valued functor. Verify that natural isomorphism of enriched nerves equals probabilistic bisimulation for all 3-state Markov chains over `Act = {a, b}`. For the quantum case, verify for 2-qubit systems with Pauli channel transitions.

**Impact:** Unifies three major notions of process equivalence (classical, probabilistic, quantum) under a single categorical umbrella. Would resolve the longstanding question of whether there is a "natural" notion of quantum bisimulation.

**Catalog References:** `Pythagorean/YonedaBisimulation/Defs.lean` — generalizes `LTS` and `nervePresheaf` to enriched settings.

**Proof Strategy:** Use Mathlib's measure theory library for the probabilistic case. For quantum, build on the operator algebra infrastructure. The key step is showing that enriched naturality squares encode the lifting conditions of probabilistic/quantum bisimulation.

**Domain Bridges:** Probability theory, quantum information, operator algebras, monoidal categories.

**Lineage:** Larsen-Skou (1991), Feng et al. (2012), Abramsky (2005).

**Ambition:** Grand challenge — paradigm-shifting unification. ★★★★★

---

## Direction 3: Internal Logic of the Presheaf Topos as Temporal Logic

**Conjecture:** The subobject classifier Ω of the presheaf topos `PSh(Exp_Act)` encodes temporal properties of LTS. Specifically, the internal Heyting algebra structure of Ω recovers the modal operators of Hennessy-Milner logic (⟨a⟩ and [a]) as left and right adjoints of the pullback functor along the experiment extension morphisms. The internal logic of `PSh(Exp_Act)` is a temporal logic where "future" corresponds to trace extension and "past" corresponds to trace truncation.

**Test:** Compute the subobject classifier explicitly for `Act = {a}` (single action). Verify that the subobjects of the nerve presheaf correspond exactly to sets of states closed under HM-definable properties. Check that the internal implication in Ω recovers the "unless" operator of temporal logic for all 4-state LTS.

**Impact:** Would provide a foundational semantics for temporal/modal logics via topos theory, potentially unifying CTL*, the modal μ-calculus, and Hennessy-Milner logic in a single framework.

**Catalog References:** `Pythagorean/YonedaBisimulation/Correspondence.lean` — extends `HMFormula` and `HMSatisfies` to the topos-internal logic.

**Proof Strategy:** Use Mathlib's category theory library to construct the presheaf topos. Compute the subobject classifier as the presheaf of sieves. Show that the diamond modality corresponds to the left adjoint of pullback along the one-step extension.

**Domain Bridges:** Topos theory, temporal logic, model checking, sheaf cohomology.

**Lineage:** Johnstone (2002), Goldblatt (1984), Awodey (2010).

**Ambition:** Grand challenge — paradigm-shifting. ★★★★★

---

## Direction 4: Bisimulation Cohomology

**Conjecture:** The nerve presheaf `N(P)` has cohomology groups `Hⁿ(N(P))` (sheaf cohomology on the experiment category). `H⁰` is the set of connected components of the bisimulation equivalence classes. `H¹` classifies "higher bisimulations" — equivalences that agree on single-step experiments but disagree on two-step coherence. These higher groups detect obstructions to extending partial bisimulations.

**Test:** Compute `H⁰` and `H¹` for all 3-state LTS over `Act = {a}`. Verify that `H⁰` counts bisimulation equivalence classes. Check whether `H¹ ≠ 0` for any non-bisimilar pair that is single-step equivalent (same one-step traces from each state).

**Impact:** Would introduce cohomological invariants for concurrent systems, potentially leading to "higher-dimensional" model checking that detects subtle behavioral differences missed by standard bisimulation.

**Catalog References:** `Pythagorean/YonedaBisimulation/Defs.lean` — uses `nervePresheaf` and `TraceAccepted`.

**Proof Strategy:** Define a Grothendieck topology on `Exp_Act` with covering sieves generated by finite trace decompositions. Compute sheaf cohomology using Čech methods. Interpret `H¹` as the obstruction to gluing local bisimulations.

**Domain Bridges:** Algebraic topology, sheaf theory, homological algebra, computational topology.

**Lineage:** Grothendieck (1957), Quillen (1973), Grandis (2003).

**Ambition:** Speculative but testable. ★★★★☆

---

## Direction 5: Bicategorical Yoneda for Causal Bisimulation

**Conjecture:** For concurrent systems with independence relations (event structures, pomset languages), the category of experiments acquires a 2-categorical structure: two traces related by an independence-induced permutation give a 2-morphism. Bicategorical Yoneda extensionality — natural isomorphism of 2-presheaves — recovers *causal bisimulation* (history-preserving bisimulation), which is strictly finer than interleaving bisimulation.

**Test:** Define a 3-process concurrent system with actions `{a, b, c}` where `a ∥ b` (independent) but `a ; c` and `b ; c` (causally dependent). Compute the 2-nerve presheaf. Verify that two pomset-equivalent processes have isomorphic 2-nerves, while two interleaving-equivalent but causally-different processes have non-isomorphic 2-nerves. A single example suffices to validate.

**Impact:** Would provide the correct categorical framework for verification of distributed systems where causal ordering matters (e.g., consensus protocols, distributed databases).

**Catalog References:** `Pythagorean/YonedaBisimulation/Defs.lean` — generalizes `Exp Act` from a 1-category to a 2-category, and `IsBisimulation` to the causal setting.

**Proof Strategy:** Define independence relations on `Act`. Build the 2-category of pomsets as a quotient of `FreeCategory(Discrete Act)` by independence equivalences. Show that 2-naturality encodes both the zigzag condition and the causal coherence condition.

**Domain Bridges:** Concurrency theory (true concurrency), 2-category theory, distributed systems verification, event structures.

**Lineage:** Winskel (1987), Nielsen-Plotkin-Winskel (1981), Leinster (2004).

**Ambition:** Grand challenge. ★★★★★
