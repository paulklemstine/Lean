# Future Research Directions

## Synthesis

The confluence theorem for the 9-rule tensor distributivity fragment establishes a foundation for certified symbolic computation with tensor expressions. The polynomial interpretation measure, critical pair analysis, and canonical normalization algorithm form a reusable toolkit that can be extended along multiple axes: richer algebraic theories, different computational domains, and deeper connections to category theory and complexity theory. The following five directions build directly on the proven theorems and push toward both practical applications and fundamental mathematical understanding.

---

## Direction 1: Full Ring Coherence for Tensor Calculi

**Conjecture:** The tensor rewrite system can be extended to include matrix associativity `(AB)v → A(Bv)`, dot product commutativity `⟨v,w⟩ → ⟨w,v⟩` (for symmetric bilinear forms), and scalar commutativity `a·b → b·a`, while maintaining confluence modulo AC of all commutative operations — provided the rules are oriented by a suitable lexicographic path ordering.

**Test:** Extend the Python BFS tool to include the additional rules. Enumerate all terms of depth ≤ 4 with the extended system and check whether all terminal forms are AC-equivalent. A single pair of non-AC-equivalent terminal forms refutes the conjecture.

**Impact:** Full ring coherence would extend the certified simplifier from a distributivity fragment to a complete decision procedure for tensor ring identities, applicable to any scientific computing compiler.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (root local confluence, critical pair analysis), `Catalog/Pythagorean/TensorSortedRewrite.lean` (one-step soundness).

**Proof Strategy:** Design a lexicographic path ordering that orients all new rules. The critical pair space grows quadratically with the number of rules but remains finite. Use the polynomial interpretation framework with adjusted weights.

**Domain Bridges:** Compiler optimization (GCC/LLVM tensor intrinsics), automated theorem proving (E-unification modulo AC).

**Lineage:** Direct extension of the 9-rule system proved confluent in this work.

**Ambition:** Grand challenge — full coherence for typed tensor languages would be a fundamental result in algebraic rewriting theory.

**The key insight is** that the polynomial interpretation with variables mapped to 3 already handles multiplicative-additive interaction; extending to associativity requires only that the new rules preserve the multiplicative structure of the interpretation.

**Why now?** The formalization infrastructure (polynomial interpretation, contextual closure, AC-equivalence) is now in place. The critical pair methodology scales to larger rule sets — the bottleneck is enumeration, not proof technique.

---

## Direction 2: Quantum Circuit Rewriting via Tensor Network Confluence

**Conjecture:** The ZX-calculus rewrite rules for quantum circuits, when restricted to the spider-fusion and distribution fragment, satisfy confluence modulo the symmetry group of the underlying graph — yielding unique canonical circuit representations up to wire permutation.

**Test:** Implement ZX-calculus rules as a term rewriting system. Enumerate all circuits on ≤ 4 qubits with ≤ 6 gates. Check confluence by BFS. Compare canonical forms with known circuit identities.

**Impact:** A confluent ZX-calculus fragment would provide a certified quantum circuit optimizer — critical for near-term quantum computing where gate counts must be minimized.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (confluence methodology), specifically the polynomial interpretation technique for proving termination.

**Proof Strategy:** Define a "tensor potential" for ZX-diagrams analogous to `distPotential`. The spider-fusion rules decrease the number of spiders (nodes), providing a natural termination argument. Critical pairs arise from overlapping spider fusions.

**Domain Bridges:** Quantum computing (circuit optimization), topological quantum field theory (cobordism categories), categorical quantum mechanics.

**Lineage:** The tensor distributivity fragment is a classical (non-quantum) analogue of tensor network contraction. The methodology transfers directly.

**Ambition:** Grand challenge — confluence for ZX-calculus would be a breakthrough in both quantum computing and categorical rewriting theory.

**The key insight is** that spider fusion in the ZX-calculus is structurally analogous to distributivity in tensor algebra: both push operations "outward" through a graph/tree structure, and both admit polynomial interpretation measures.

**Why now?** Quantum circuit optimization is an active engineering bottleneck. The formal methods developed here — measure design, critical pair enumeration, modular confluence — are directly applicable to ZX-calculus fragments.

---

## Direction 3: Polynomial Complexity Bounds for Normalization Length

**Conjecture:** There exists a polynomial P(n) = O(n²) such that for every term t of size n, every maximal rewrite sequence from t has length at most P(n).

**Test:** Exhaustively enumerate all terms of size ≤ 12. For each, compute ALL maximal rewrite sequences by DFS. Plot (size, max_length) and fit polynomial models. A single family with super-polynomial growth refutes the conjecture.

**Impact:** A polynomial bound would establish that canonical normalization is efficiently computable, not just terminating. This transforms the theoretical confluence result into a practical complexity guarantee.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (`distPotential`, `rewrite1_decreases`).

**Proof Strategy:** The current exponential bound comes from the multiplicative structure of `distPotential` (products of subterm potentials). A tighter analysis might use an additive measure that counts "active redexes" weighted by depth, avoiding the multiplicative blowup. Alternatively, amortized analysis could show that the total work across all positions is bounded.

**Domain Bridges:** Computational complexity (implicit computational complexity), compiler optimization (optimization pass scheduling).

**Lineage:** Builds directly on the termination proof via `distPotential`.

**Ambition:** Solid extension — a tight complexity bound would be publishable and practically useful, though not paradigm-shifting.

**The key insight is** that while `distPotential` can be exponential, the actual number of rewrite steps might be much smaller because each rule eliminates a specific structural pattern, and patterns don't regenerate as fast as the multiplicative measure suggests.

**Why now?** The BFS infrastructure in `demo.py` already generates the data. The question is now empirically testable, and a formal proof would follow from the right measure design.

---

## Direction 4: Proof-Theoretic Normalization via Cut Elimination

**Conjecture:** The tensor rewrite system corresponds to a fragment of a sequent calculus for multiplicative-additive linear logic, and confluence modulo AC corresponds to a cut-elimination theorem where the "cut-free" normal forms are unique up to the exchange rule.

**Test:** Define a sequent calculus whose formulas are tensor sort annotations and whose inference rules correspond to the 9 rewrite rules. Verify that cut elimination in this calculus produces the same normal forms as the rewrite system. Check on at least 20 test sequents.

**Impact:** This would connect tensor simplification to the deep structure of linear logic, opening paths to resource-aware compilation and substructural type theory.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (unique normal forms, ACEq).

**Proof Strategy:** Map each rewrite rule to a cut-reduction step. The polynomial interpretation becomes a "cut rank" measure. Critical pairs correspond to commuting conversions in the sequent calculus. The AC-equivalence corresponds to the exchange rule.

**Domain Bridges:** Proof theory (linear logic, cut elimination), programming language theory (resource types), categorical semantics (star-autonomous categories).

**Lineage:** The distributivity rules are the term-level counterpart of the multiplicative-additive distribution rule in linear logic.

**Ambition:** Grand challenge — a precise Curry-Howard correspondence for tensor rewriting would bridge symbolic computation and proof theory in a novel way.

**The key insight is** that the 9 rewrite rules are exactly the computational content of the distributivity axiom in linear logic: they describe how multiplicative connectives (tensor, par) interact with additive connectives (plus, with).

**Why now?** Linear logic has been connected to quantum computing and resource management, but its computational aspects for continuous mathematics (tensors, linear algebra) remain unexplored. The formalized confluence theorem provides the first rigorous anchor.

---

## Direction 5: Automatic Differentiation via Rewriting

**Conjecture:** The chain rule for automatic differentiation, when formulated as a rewrite system on expression graphs, satisfies confluence modulo commutativity of addition — yielding unique gradient expressions regardless of the order of differentiation.

**Test:** Implement forward-mode and reverse-mode AD as rewrite systems on a simple expression language (polynomials + elementary functions). Enumerate all differentiation orders for expressions with ≤ 5 operations. Check that all resulting gradient expressions are AC-equivalent.

**Impact:** Confluence for AD rewriting would provide formal correctness guarantees for automatic differentiation — a cornerstone of modern machine learning and scientific computing.

**Catalog References:** `Catalog/Pythagorean/TensorConfluence.lean` (polynomial interpretation for termination, critical pair methodology).

**Proof Strategy:** The chain rule `d/dx[f(g(x))] = f'(g(x)) · g'(x)` is a distributivity-like rule. The sum rule `d/dx[f + g] = df + dg` is our Rule 1 analogue. Design a `distPotential` variant where differentiation depth serves as the multiplicative component.

**Domain Bridges:** Machine learning (backpropagation correctness), scientific computing (sensitivity analysis), numerical analysis (finite differences vs. AD).

**Lineage:** Direct application of the confluence methodology to a different but structurally similar rewrite system.

**Ambition:** Solid extension with high practical impact — AD correctness is a major concern in production ML systems.

**The key insight is** that the interaction between the chain rule and the sum rule creates critical pairs structurally identical to our CP1 (distribution of a "multiplicative" operation over an "additive" one), and the same joining strategy applies.

**Why now?** Automatic differentiation frameworks (JAX, PyTorch) are used in critical applications but lack formal correctness proofs. The rewriting methodology from this work directly applies to their core transformations.
