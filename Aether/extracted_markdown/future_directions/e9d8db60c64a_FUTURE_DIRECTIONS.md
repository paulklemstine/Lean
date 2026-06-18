# Future Directions: Non-Well-Founded Proofs

## Synthesis

This research cycle established a rigorous framework for self-referential proofs by introducing the **Proof Convergence Domain** — a complete lattice equipped with a contractive deduction operator and consistency metric. The key discovery is that the boundary between valid and invalid self-reference is quantified precisely by the consistency metric: valid proofs have CM < 1, the liar paradox sits at CM = 1, and well-founded proofs have CM = 0. This provides a complete topological characterization of proof validity.

The most surprising result is **unbounded compression**: self-referential proofs can be arbitrarily deeper than their well-founded kernels, establishing that self-reference is not merely a convenience but provides genuine structural economy. Combined with the tropical semiring structure on proof heights, this opens a direct connection to optimization theory — proof search becomes a tropical linear programming problem.

The highest-breakthrough-potential direction is **Direction 1 (Coinductive Proof Towers)**, which would extend our finite inductive framework to genuinely infinite proof trees, capturing the full power of non-well-founded reasoning. This requires coinductive types and would connect to domain theory and denotational semantics. The **tropical proof variety** direction (Direction 3) has the most immediate practical impact for automated theorem proving.

---

### Direction 1: Coinductive Proof Towers and Scott Domain Structure

**Conjecture**: The type of non-well-founded proof trees, defined coinductively as `codata CoNWFTree = ax(p) | mp(CoNWFTree, CoNWFTree, p, q) | selfRef(p, CoNWFTree) | bot`, admits a Scott domain structure where directed sets of finite approximations converge to unique infinite proof trees. The consistency metric extends to a continuous function on this Scott domain, and the set {t : CoNWFTree | CM(t) < 1} is Scott-open.

**Test**: Define CoNWFTree as a greatest fixed point in Lean 4 (using coinductive types or quotient types). Construct an infinite proof tree as the limit of the sequence nestedSR(p, n) as n → ∞. Compute its consistency metric. If the limit exists and has CM = 1 (as a supremum of (2^n - 1)/2^n), this proves that infinite self-reference is precisely on the boundary of validity — neither valid nor invalid, but a limit point of valid proofs.

**Impact**: If the Scott domain structure exists, it provides a denotational semantics for self-referential proofs, analogous to Scott's semantics for recursive programs. This would establish proof theory as a branch of domain theory, opening up 50 years of domain-theoretic machinery for proof search and verification.

**Catalog References**: `ProofConvergenceDomain` (Applications/NWFP/Core.lean), `fixed_point_unique_under_theory_separation` (Bridges/ProofStoneCechDynamics.lean)

**Proof Strategy**: 
1. Define CoNWFTree as a quotient of countable sequences of NWFTree under a prefix equivalence
2. Define the information ordering: t ⊑ s iff t is an approximation of s (structurally)
3. Prove the ordering forms a dcpo (directed-complete partial order)
4. Extend CM to the coinductive type using the metric completion
5. Prove {CM < 1} is Scott-open using the fact that CM is continuous

**Domain Bridges**: Proof theory ↔ Domain theory (via Scott domains), Self-reference ↔ Recursion theory (via fixed points of continuous operators)

**Lineage**: Builds on the ProofConvergenceDomain structure and the consistency metric from this cycle's Core.lean

**Ambition**: grand_challenge

---

### Direction 2: Semantic Soundness and Self-Reference Necessity

**Conjecture**: There exists a proof system S (a set of axioms and inference rules formalized as a ProofSystem in our framework) and a proposition p such that p has a valid 1-convergent NWF proof in S but has no valid 0-convergent proof in S. In other words, self-reference is sometimes *necessary* — there exist truths that can only be proved circularly.

**Test**: Construct S as a system where the only axiom schema involves self-reference: axiom(p) requires a prior proof of p → p (which needs selfRef). Try to prove that the identity proof selfRef(p, ax(p)) cannot be replaced by any tree of depth 0. Computationally: enumerate all depth-k well-founded proofs for increasing k and check whether any proves p in the system.

**Impact**: If true, this establishes a new kind of incompleteness: not Gödelian (some truths are unprovable) but *structural* (some truths require self-reference). This would have implications for automated theorem proving — proof search algorithms would need to explore circular reasoning paths, not just well-founded ones.

**Catalog References**: `classical_not_self_sound_with_paradox` (Logic/ParadoxSelfSoundness.lean), `identity_valid` (Applications/NWFP/Core.lean), `zero_convergent_iff_wf` (Applications/NWFP/Core.lean)

**Proof Strategy**:
1. Define a minimal proof system where all axioms are of the form selfRef(p, inner)
2. Prove that wfKernel of these axioms produces ax(p), which is not in the axiom set
3. Show that no finite well-founded proof tree can close the gap
4. Formalize this as a separation result between k-convergent classes

**Domain Bridges**: Proof theory ↔ Computability theory (via proof search decidability), Logic ↔ Complexity theory (via proof length bounds)

**Lineage**: Builds on kConvergent, zero_convergent_iff_wf, and identity_one_convergent from this cycle

**Ambition**: grand_challenge

---

### Direction 3: Tropical Proof Varieties and Optimal Proof Search

**Conjecture**: For a proof system with n propositions, the set of achievable proof height vectors h = (h₁, ..., hₙ) ∈ (WithTop ℕ)ⁿ (where hᵢ is the minimum proof height for proposition i) forms a tropical variety — the tropical zero set of a system of tropical polynomials determined by the proof system's inference rules.

**Test**: For a small proof system (3-5 propositions, 2-3 inference rules), compute the achievable height vectors explicitly and check whether they are the tropical zero set of the polynomials induced by the inference rules. Specifically, for each rule "from p with height h₁ and q with height h₂, derive r with height max(h₁, h₂) + 1", the corresponding tropical polynomial is min(h₁ + h₂) ⊕ hᵣ.

**Impact**: If true, this transforms proof search from a combinatorial problem to an algebraic geometry problem. Tropical Gröbner basis algorithms could then be applied to find optimal proofs — the shortest proof of any proposition — in polynomial time for systems with bounded tropical degree.

**Catalog References**: `TPH.tmul_tadd_distrib` (Applications/NWFP/Core.lean), `self_reasoning_fixed_point` (Tropical/TropicalSelfReasoning.lean)

**Proof Strategy**:
1. Formalize the proof system as a set of tropical polynomial equations
2. Show that the set of achievable height vectors satisfies these equations
3. Show that any solution to the equations is achievable (completeness)
4. Connect to tropical Gröbner basis theory for algorithmic implications

**Domain Bridges**: Proof theory ↔ Tropical geometry (via semiring structure), Optimization ↔ Logic (via shortest proof = tropical LP)

**Lineage**: Builds on the TPH tropical semiring from this cycle and tropical results in Tropical/TropicalSelfReasoning.lean

**Ambition**: extension

---

### Direction 4: Consistency Metric as a Sheaf Cohomology Invariant

**Conjecture**: The consistency metric CM : NWFTree → [0, 1] extends to a sheaf on the Grothendieck topology of proof tree covers, and the non-trivial cohomology classes H¹(CM) classify distinct types of self-reference. Specifically, H¹ = 0 characterizes well-founded proof systems, and H¹ ≠ 0 detects essential self-reference.

**Test**: Define a category of proof trees with morphisms given by "proof refinement" (replacing sub-trees with more detailed proofs). Define a presheaf sending each proof tree to its consistency metric interval [0, CM(t)]. Check whether the sheaf condition holds and compute H¹ for simple examples (identity proof, nested self-reference, mutual self-reference).

**Impact**: This would connect proof theory to algebraic topology in a deep way, potentially allowing topological invariants to detect structural properties of proof systems. The cohomological perspective could reveal hidden symmetries in proof systems that are invisible at the tree level.

**Catalog References**: `consistencyMetric_valid_lt_one` (Applications/NWFP/Core.lean), `fixed_point_unique_under_theory_separation` (Bridges/ProofStoneCechDynamics.lean)

**Proof Strategy**:
1. Define the category of proof trees and the Grothendieck topology
2. Construct the CM presheaf and verify the sheaf condition
3. Compute H⁰ and H¹ for specific proof systems
4. Relate H¹ ≠ 0 to the existence of essential self-reference (proofs that cannot be well-foundedly decomposed)

**Domain Bridges**: Proof theory ↔ Algebraic topology (via sheaf cohomology), Logic ↔ Geometry (via Grothendieck topologies on proof categories)

**Lineage**: Builds on the consistency metric and stratification theorem from this cycle

**Ambition**: grand_challenge

---

### Direction 5: Mutual Self-Reference and Proof Graphs

**Conjecture**: Extending NWFTree to allow mutual self-reference (multiple propositions referencing each other simultaneously) yields a strictly more expressive proof system. Formally: there exists a system of propositions (p₁, ..., pₙ) with a valid mutually self-referential proof that cannot be decomposed into a sequence of individually self-referential proofs.

**Test**: Define a proof graph type where nodes can reference any other node (not just their parent). Construct a mutual proof where p₁ assumes p₂ and p₂ assumes p₁, with both being axioms of each other. Check whether this can be factored into two independent selfRef proofs.

**Impact**: If mutual self-reference is strictly more powerful, it establishes a hierarchy of self-referential proof systems: well-founded ⊂ individually self-referential ⊂ mutually self-referential ⊂ ... This hierarchy could parallel the arithmetic hierarchy in computability theory, providing a new classification of logical systems.

**Catalog References**: `nestedSR_valid` (Applications/NWFP/Core.lean), `compose_valid` (Applications/NWFP/Core.lean)

**Proof Strategy**:
1. Define a ProofGraph type with labeled edges allowing mutual reference
2. Define validity and consistency metric for proof graphs
3. Prove that every NWFTree embeds into a ProofGraph
4. Construct a mutually self-referential proof and show it cannot be linearized
5. Establish a strict hierarchy of self-reference levels

**Domain Bridges**: Proof theory ↔ Graph theory (via proof graphs), Logic ↔ Fixed-point theory (via simultaneous fixed points)

**Lineage**: Builds on the NWFTree framework and kConvergent stratification from this cycle

**Ambition**: extension
