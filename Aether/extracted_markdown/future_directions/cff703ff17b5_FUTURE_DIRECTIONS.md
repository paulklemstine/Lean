# Future Directions: Tensor Distributivity Rewriting

## Synthesis

The confluence modulo AC result for the 9-rule tensor distributivity fragment opens a systematic research program connecting term rewriting theory, algebraic computing, and formal verification. The proven termination via polynomial interpretation and the unique normal form theorem (conditional on local confluence) establish the foundation. The five directions below build on this foundation in complementary ways: two push the algebraic theory deeper, one connects to compiler optimization, one to categorical semantics, and one to quantum computing. Together, they chart a path from a specific tensor normalization result toward a general theory of certified canonical computation in algebraic structures.

---

## Direction 1: Complete Formalization of Local Confluence via Automated Critical Pair Analysis

**Conjecture:** The 9-rule distributivity fragment has exactly 4 genuine critical pairs (R1∩R2, R1∩R3, R6∩R7, R7∩R8), all joinable modulo AC. Furthermore, the local confluence proof can be fully automated by a certified critical pair checker that enumerates overlaps, constructs joining sequences, and verifies AC-equivalence.

**Test:** Implement a Lean 4 tactic that, given an inductive rewrite relation and an AC-equivalence specification, automatically proves local confluence by enumerating critical pairs and constructing explicit joining paths. Test on the 9-rule system. The tactic should either produce a proof term or report a genuine counterexample.

**Impact:** Eliminates the largest remaining sorry in the formalization. More importantly, creates reusable infrastructure: any new rule added to the system can be automatically checked for confluence, enabling rapid extension of the verified normalizer.

**Catalog References:** `Speculative/AutoResearch/TensorConfluence.lean` — `local_confluence_mod_AC`, `Rewrite1`, `DeepRewrite`, `JoinableModAC`

**Proof Strategy:** Encode the critical pair enumeration as a computable function on `Rewrite1` constructors. For each pair, generate the overlap term, compute both rewrite paths, and verify joinability either by exact equality or by an AC-equivalence decision procedure (flatten-sort-compare on addition nodes).

**Domain Bridges:** Automated theorem proving, SMT-based rewriting, certified compiler verification

**Lineage:** Direct continuation of the current work. The critical pair analysis is 90% done informally; formalization requires encoding the case analysis as a tactic.

**The key insight is** that the critical pair space for a finite, sort-disciplined rewrite system is enumerable and checkable, turning a proof obligation into a computation.

**Why now?** The infrastructure (DeepRewrite, DeepRewriteStar lifts, ACEq, JoinableModAC) is fully formalized. Only the case analysis and AC-checking remain.

**Ambition:** solid_extension

---

## Direction 2: Polynomial Complexity Bounds on Normalization Length

**Conjecture:** For every term t of size n, every maximal rewrite sequence has length O(n²). More precisely, the normalization length is bounded by the number of "distributivity redexes" times the depth, which is at most quadratic.

**Test:** Enumerate all terms of depth ≤ 6 with 3 scalar, 3 vector, and 2 matrix variables. For each term, compute all maximal rewrite sequences by BFS. Record the maximum length and compare against n² and n³ bounds. A single family with super-polynomial growth pattern would refute the conjecture.

**Impact:** Transforms the normalizer from "eventually terminates" to "terminates in polynomial time." This is the difference between a theoretical tool and a practical one — polynomial bounds enable the normalizer to be used inside compiler optimization passes with guaranteed performance.

**Catalog References:** `Speculative/AutoResearch/TensorConfluence.lean` — `distPotential`, `rewrite_sequence_bounded`, `distPotential_le_exp`

**Proof Strategy:** Refine the distributivity potential into a two-component measure: (redex count, weighted depth). Show that each rewrite step either decreases the redex count or, if the redex count is preserved, decreases the weighted depth. Since both components are polynomial in n, the total length is polynomial.

**Domain Bridges:** Computational complexity, compiler optimization, algorithm design

**Lineage:** Extends `rewrite_sequence_bounded` (which gives dp(t) as a bound) and `distPotential_le_exp` (which gives 3^n as an upper bound on dp).

**The key insight is** that the distributivity potential, while exponentially large in the worst case, decreases by at least 1 at each step, and the *number of redexes* (which is at most quadratic in term size) provides a tighter bound on the actual reduction length.

**Why now?** The exponential bound dp ≤ 3^n is already proved. Tightening it to polynomial requires a more refined analysis that's now feasible given the structural understanding of the rewrite rules.

**Ambition:** solid_extension

---

## Direction 3: Certified Tensor Optimization Passes for Scientific Compilers

**Conjecture:** The canonical normalization algorithm, when integrated into a tensor compiler (e.g., for PyTorch, TensorFlow, or JAX), produces optimized computation graphs that are semantically equivalent to the input, with the equivalence certified by a machine-checked proof.

**Test:** Implement a proof-producing normalizer that, given a tensor expression, outputs both the normal form and a sequence of rewrite steps constituting a formal proof of equivalence. Integrate with a tensor compiler IR and verify on 100 benchmark expressions from real ML workloads.

**Impact:** Bridges the gap between verified mathematics and practical software engineering. A certified tensor simplifier would be the first formally verified optimization pass for scientific computing that handles distributivity, bilinearity, and scalar extraction.

**Catalog References:** `Speculative/AutoResearch/TensorConfluence.lean` — `normalizeCanon`, `normOnce`, `DeepRewriteStar` congruence lifts; `Pythagorean/TensorSortedRewrite.lean` — `tensorRewrite_sound`, `sortEq_of_reflTransGen`

**Proof Strategy:** Compose the existing one-step soundness theorems (`tensorRewrite_sound` from the base file) with the multi-step soundness lift (`sortEq_of_reflTransGen`) and the normalization algorithm. The compiler pass becomes: (1) parse to TensorExpr, (2) normalize, (3) emit optimized code, (4) emit proof certificate.

**Domain Bridges:** Compiler construction, program verification, scientific computing, machine learning infrastructure

**Lineage:** Builds directly on both the rewriting theory (this file) and the semantic soundness (TensorSortedRewrite.lean).

**The key insight is** that each rewrite step already has a verified soundness proof, so the normalization trace IS the proof certificate — no additional verification is needed.

**Why now?** The one-step soundness infrastructure exists. The normalization algorithm exists. Connecting them requires only composing existing pieces.

**Ambition:** solid_extension

---

## Direction 4: Coherence Theorems for Monoidal-Distributive Categories

**Conjecture:** The confluence theorem for the tensor distributivity fragment is a special case of a general coherence theorem for freely generated semiring-enriched monoidal categories. Specifically: in any category with a bilinear monoidal product distributing over a commutative monoid structure, all diagrams built from distributivity, bilinearity, and scalar action commute up to the monoidal AC-equivalence.

**Test:** Formalize the categorical framework: define a "distributive monoidal category" with the appropriate universal property. State the coherence theorem as: "every two natural transformations from the same source to the same target, built from the structural morphisms, are equal." Prove it for the free case using the rewriting confluence result as a decision procedure.

**Impact:** This would be a new coherence theorem in category theory, proved by computational methods (rewriting) rather than traditional diagrammatic arguments. It would establish that the tensor normalization result is not ad hoc but an instance of a deep structural phenomenon.

**Catalog References:** `Speculative/AutoResearch/TensorConfluence.lean` — `unique_normal_form_mod_AC`, `ACEq`, `IsNormal`

**Proof Strategy:** Model tensor expressions as morphisms in the free distributive monoidal category. Show that the rewriting relation preserves the categorical structure and that normal forms correspond to canonical morphisms. Confluence then translates directly to coherence.

**Domain Bridges:** Category theory, algebraic topology, higher algebra, theoretical computer science (typed lambda calculi)

**Lineage:** Extends the connection between rewriting and coherence explored by Lafont (1995) and Mimram (2014).

**The key insight is** that the 9 rewrite rules are exactly the structural morphisms of a distributive monoidal category, and confluence IS coherence in this setting.

**Why now?** The concrete confluence result provides the necessary computational foundation. Categorical coherence via rewriting is a known technique but has not been applied to this specific algebraic fragment.

**Ambition:** grand_challenge

---

## Direction 5: Confluence of Quantum Circuit Rewriting via Tensor Distribution

**Conjecture:** The distributivity fragment, suitably extended to handle tensor products (⊗) and direct sums (⊕) of Hilbert spaces, yields a confluent rewrite system for quantum circuit simplification. Specifically: distributing controlled gates over superpositions of basis states produces canonical circuit forms that are unique up to the ordering of independent gates.

**Test:** Extend the 9-rule system with rules for:
- `CNOT (|ψ⟩ ⊕ |φ⟩) → CNOT |ψ⟩ ⊕ CNOT |φ⟩` (linearity of unitaries)
- `(U ⊗ V)(|ψ⟩ ⊗ |φ⟩) → U|ψ⟩ ⊗ V|φ⟩` (tensor product distributivity)
Check termination and confluence on all 2-qubit circuits up to depth 6.

**Impact:** Confluent rewriting for quantum circuits would enable deterministic circuit optimization — a major open problem in quantum compilation. Current quantum compilers use heuristic rewriting that can produce different outputs depending on scheduling, leading to non-reproducible quantum computations.

**Catalog References:** `Speculative/AutoResearch/TensorConfluence.lean` — entire framework (distPotential, DeepRewrite, ACEq, unique normal forms)

**Proof Strategy:** Adapt the polynomial interpretation to handle tensor products (dp(a ⊗ b) = dp(a) · dp(b)). The key challenge is that quantum circuits have additional structure (unitarity, no-cloning) that constrains which distributivity rules apply. Analyze the extended critical pair space and prove joinability.

**Domain Bridges:** Quantum computing, quantum error correction, photonic computing, quantum machine learning

**Lineage:** Connects the tensor distributivity work to quantum circuit optimization [Amy et al. 2014, Nam et al. 2018] and the ZX-calculus [Coecke & Duncan 2011].

**The key insight is** that quantum gates are linear operators, so the distributivity rules that apply to classical tensor expressions also apply to quantum circuits — but the sort discipline and unitarity constraints may simplify the critical pair analysis.

**Why now?** Quantum hardware is reaching the scale where circuit optimization matters for real computations. A formally verified, confluent simplifier would be a competitive advantage for quantum software stacks.

**Ambition:** grand_challenge
