# Future Directions: Operadic Rewriting and Homotopical Completion

## Synthesis

This research cycle established the operadic foundation of higher-order rewriting: the substitution category of the STLC forms a colored operad (via `SubstitutionOperad`), parallel substitution satisfies the interchange law (`interchange_law`), confluent systems have unique normal forms (`normal_form_unique`), and the Koszulity prediction links linear lambda terms to bar construction homology (`koszulity_arity_one/two/three`, `eulerChar_additive`). These results create a three-way bridge: **rewriting theory ↔ operadic algebra ↔ homotopical algebra**. The next cycle should push this bridge in five directions: (1) prove the Koszulity conjecture for all arities, (2) formalize the full model structure on operads, (3) connect to homotopy type theory, (4) build computational tools for operadic completion, and (5) explore quantum topology connections through computational TQFTs. Each direction builds directly on the formalized infrastructure and tests a specific mathematical prediction.

---

## Direction 1: Prove the Koszulity Conjecture

**Conjecture:** The STLC substitution operad is Koszul: |χ(n)| = linearTermCount(n) for all n > 0.

**Test:** Formalize the bar construction as a chain complex of graded spaces, compute its homology for arities 4–8, and verify triviality above degree 0. A single non-trivial homology class would disprove the conjecture.

**Impact:** If true, Koszulity provides a complete description of the STLC operad's homotopical properties: the bar construction computes the Koszul dual (the linear lambda calculus), and the cobar construction gives a minimal resolution. This would yield new termination criteria for higher-order completion and connect type theory to homological algebra.

**Catalog References:** `OperadicRewriting/Main.lean` (`koszulityConjecture`, `koszulEulerChar`, `linearTermCount`, `eulerChar_additive`)

**Proof Strategy:** Use the quadratic presentation of the STLC operad (generators are application and abstraction, relations are β-reduction). Compute the bar differential explicitly for small arities using the operadic composition formula. Show acyclicity by constructing a contracting homotopy, following Loday-Vallette's method for quadratic operads.

**Domain Bridges:** Homological algebra (bar construction), combinatorics (linear term enumeration), representation theory (operadic Schur functors).

**Lineage:** Extends `koszulity_arity_one/two/three` from verified instances to a general proof.

**Ambition:** Grand challenge — a proof would be a significant contribution to operadic algebra, providing the first Koszulity result for a type-theoretic operad.

---

## Direction 2: Model Structure on Colored Operads

**Conjecture:** There exists a cofibrantly generated model structure on the category of colored operads (with fixed colors ℕ) where:
- Weak equivalences are operad morphisms inducing equivalences on algebras.
- Cofibrant objects are operads with confluent, terminating presentation.
- The cofibrant replacement of `STLCOperad / β` is `STLCOperad_R*` (the completed system).

**Test:** Formalize the generating cofibrations and trivial cofibrations. Verify the lifting property for the SubstitutionOperad against a specific test diagram. Concretely: construct a lifting for the diagram arising from the β-rule critical pair.

**Impact:** This would provide the first formalization of a model structure on operads, connecting abstract homotopy theory to concrete rewriting algorithms. It would give a rigorous foundation for "completion as cofibrant replacement."

**Catalog References:** `OperadicRewriting/Main.lean` (`ColoredOperad`, `OperadMorphism`, `normal_form_unique`, `completion_preserves_theory`), `Catalog/Bridges/Catalog/Pythagorean/HigherOrderCompletion.lean` (`compSubst_assoc`)

**Proof Strategy:** Follow Berger-Moerdijk's construction of model structures on operads, adapted to the colored case. Use the interchange law (`interchange_law`) to verify the pushout-product axiom. The key technical step is showing that the operadic bar construction preserves cofibrations.

**Domain Bridges:** Model categories (Quillen), categorical homotopy theory (∞-categories), algebraic K-theory.

**Lineage:** Extends `SubstitutionOperad` and `operadMorphism_comp_assoc` with model-categorical structure.

**Ambition:** Grand challenge — would be a major formalization achievement connecting multiple areas of mathematics.

---

## Direction 3: Symmetric Group Action and Linear Logic

**Conjecture:** The substitution operad has a natural symmetric group action given by variable permutations, making it a symmetric colored operad. The Koszul dual symmetric operad is the operad for linear STLC.

**Test:** Formalize the action of Sₙ on substitutions by permuting variable indices. Verify the equivariance axioms for operadic composition. Show that the Koszul dual operations at arity n form a representation of Sₙ isomorphic to the regular representation restricted to linear terms.

**Impact:** Connects Koszul duality to **linear logic** (Girard, 1987): the Koszul dual of intuitionistic type theory IS linear type theory. This provides an algebraic-topological proof of the correspondence between intuitionistic and linear logic.

**Catalog References:** `OperadicRewriting/Main.lean` (`IsLinearTerm`, `identity_is_linear`, `app_combinator_linear`, `composition_combinator_linear`)

**Proof Strategy:** Define `SymAction : Equiv.Perm (Fin n) → Subst → Subst` using `rename`. Verify equivariance by structural induction, using `rename_comp` and `subst_rename`. The key insight: linearity is equivalent to the substitution being equivariant under the alternating subgroup.

**Domain Bridges:** Representation theory (symmetric group representations), linear logic (Girard), combinatorial species (Joyal).

**Lineage:** Extends `interchange_law` with symmetric group structure; extends `IsLinearTerm` with representation-theoretic interpretation.

**Ambition:** Solid extension — the symmetric action is well-understood mathematically; the challenge is formalization.

---

## Direction 4: Computational Operadic Completion

**Conjecture:** There exists a polynomial-time algorithm for computing operadic composition of substitutions that exploits the interchange law to achieve better parallelism than naive sequential composition.

**Test:** Implement the algorithm in Python. Benchmark against naive composition for substitutions of size 100–10000. Measure speedup from parallelism enabled by the interchange law. Target: ≥ 2x speedup on 4 cores.

**Impact:** Practical improvement to term rewriting engines used in proof assistants and compilers. The interchange law provides a mathematical guarantee that certain compositions can be parallelized without affecting the result.

**Catalog References:** `OperadicRewriting/Main.lean` (`interchange_law`, `compFinSubst`, `operadicComp`, `compFinSubst_length`)

**Proof Strategy:** Formalize the parallel composition algorithm using `parallelSubst` and the interchange law. Prove correctness by showing the parallel algorithm produces the same result as sequential composition. Verify the length preservation property `compFinSubst_length`.

**Domain Bridges:** Parallel computing, compiler optimization, term rewriting implementation.

**Lineage:** Builds directly on `interchange_law` and `operadicComp`.

**Ambition:** Solid extension — the algorithm is straightforward; the contribution is the formal correctness proof and benchmark.

---

## Direction 5: Computational TQFT from Lambda Calculus

**Conjecture:** The STLC operad, viewed through the Atiyah-Segal formalism, defines a "computational TQFT" where:
- Objects (colors) are types
- Morphisms (operations) are programs
- The partition function counts normal forms
- The state space at each boundary is the type's denotational semantics

**Test:** For simple types up to depth 3, compute the partition function (= number of normal forms) and verify it matches the categorical trace of the identity functor on the corresponding finite category. Concretely: for type (α → α) → (α → α), verify that the number of normal forms equals the number of Church numerals up to βη-equivalence.

**Impact:** Would establish a precise mathematical connection between programming language theory and topological quantum field theory, potentially yielding new invariants of programs through topological methods.

**Catalog References:** `OperadicRewriting/Main.lean` (`ColoredOperad`, `SubstitutionOperad`, `koszulEulerChar`), `Catalog/Bridges/Catalog/Pythagorean/HigherOrderCompletion.lean` (STLC term structure)

**Proof Strategy:** Define the cobordism category whose objects are lists of types and whose morphisms are typing derivations. Show this satisfies the Atiyah-Segal axioms using the substitution operad structure. The key insight: the interchange law corresponds to the tensor product axiom of TQFT.

**Domain Bridges:** Topological quantum field theory (Atiyah-Segal), quantum computing (categorical quantum mechanics), knot theory (Jones polynomial via operator algebras).

**Lineage:** Extends `SubstitutionOperad` with TQFT structure; extends `koszulEulerChar` as partition function.

**Ambition:** Grand challenge — highly speculative but would be paradigm-shifting if successful. The key risk is that the finite-dimensional structure of STLC may not carry enough topological information for a non-trivial TQFT.
