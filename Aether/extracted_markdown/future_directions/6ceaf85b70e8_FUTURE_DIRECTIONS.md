# Future Directions: Non-Well-Founded Proof Theory

## Synthesis

This research cycle established the foundations of non-well-founded proof theory — a framework where proofs can reference their own conclusions through ordinal-indexed derivability. The key results are: (1) the derivability operator is monotone, enabling fixed-point constructions via Knaster-Tarski; (2) liar-like formulas force inconsistency, providing a precise diagnosis of paradox; (3) approximation chains are monotonically increasing and convergence is permanent; (4) the space of partial proofs forms a directed-complete partial order.

The most promising cross-domain connection is between non-well-founded proofs and **reflective convergence** (Catalog: `Logic/ReflectiveConvergence.lean`). Both theories study systems that reference themselves and converge to fixed points. The reflective convergence framework uses natural-number ranks on finite-state systems; our framework generalizes to ordinal heights on infinite proof structures. A unification would provide a single theory of "self-referential convergence" spanning from finite automata to proof theory.

The highest breakthrough potential lies in Direction 1 (Ordinal Complexity Bounds), because establishing tight bounds on convergence ordinals would connect non-well-founded proofs to **ordinal analysis** — one of the deepest areas of proof theory. If convergence ordinals track proof-theoretic ordinals of theories, this would provide a new characterization of consistency strength in terms of self-referential convergence speed.

---

### Direction 1: Ordinal Complexity Bounds for Self-Referential Convergence

**Conjecture**: For any propositional formula φ of structural complexity n, if φ has a convergent self-referential proof in an NWFPS with valid axioms, then its convergence ordinal is bounded by ω^n (the n-th power of the first infinite ordinal).

**Test**: Formalize a family of formulas φ_n of increasing complexity (e.g., nested implications P → (P → (P → ... → P))) and compute or bound their convergence ordinals. If convergence ordinals grow faster than ω^n, the conjecture is false. Alternatively, construct explicit self-referential proofs for each φ_n and verify the height bound.

**Impact**: If true, this would connect formula complexity to ordinal analysis, providing a new "complexity measure" for self-referential proofs analogous to the proof-theoretic ordinal of a theory. If false, the failure would reveal which structural features of formulas cause ordinal blow-up.

**Catalog References**: `Logic/NonWellFoundedProofs.lean` (complexity_imp_self, approxChain_monotone), `Logic/StratifiedSelfReference.lean` (iterate_level_stabilizes)

**Proof Strategy**: 
1. Define a canonical self-referential proof for each formula structure (atom, conjunction, implication, negation).
2. Prove height bounds by structural induction on formulas.
3. For the lower bound, construct formulas that require ordinal height at least ω^(n-1).
4. Key lemma: height of modus ponens is max of children's heights, so nested implications contribute additively.

**Domain Bridges**: Logic (ordinal analysis) <-> Computation (recursive function complexity) — convergence ordinals as a complexity measure for self-referential computations.

**Lineage**: Builds on complexity_imp_self and approxChain_monotone from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Coinductive Non-Well-Founded Proof Trees

**Conjecture**: Non-well-founded proof trees, formalized as a coinductive type in Lean 4, admit a bisimulation relation that is a congruence for derivability — i.e., bisimilar proof trees derive the same formulas.

**Test**: Define `CoProofTree` as a coinductive type with constructors for axiom, hypothesis, modus ponens, and self-reference. Define bisimulation. Prove that if two proof trees are bisimilar, they have the same conclusion and the same derivability properties. Test with concrete examples: the two canonical proofs of P → P (one direct, one self-referential) should be bisimilar.

**Impact**: This would provide a *structural* account of proof identity for self-referential proofs, complementing the *ordinal* account in this cycle. It would connect non-well-founded proofs to coalgebra and the theory of infinite data structures, opening the door to categorical proof theory for self-referential systems.

**Catalog References**: `Logic/NonWellFoundedProofs.lean` (NWFProofSystem, approxChain), `Logic/ReflectiveConvergence.lean` (reflective_converges_of_monotone_idempotent)

**Proof Strategy**:
1. Define `CoProofTree` as a coinductive type using Lean 4's `structure` with a `Thunk` or using `Stream'`-like encodings.
2. Define bisimulation as a relation R such that if R(t₁, t₂), then t₁ and t₂ have the same root label and R relates their children pairwise.
3. Prove the congruence property by coinduction.
4. Key challenge: Lean 4 doesn't natively support coinductive types well; may need to encode via greatest fixed points of functors.

**Domain Bridges**: Logic (proof theory) <-> Computation (coinductive types, stream processing) <-> EML (infinite structures in ensemble methods)

**Lineage**: Extends the Scott domain structure (PartialProof) from this cycle to infinite proof objects.

**Ambition**: grand_challenge

---

### Direction 3: Self-Referential Proofs in Arithmetic

**Conjecture**: Every true Σ₁ arithmetic sentence has a convergent self-referential proof of height at most ω in an NWFPS that includes Robinson arithmetic as axioms.

**Test**: Formalize an arithmetic formula language extending the propositional one with quantifiers and natural number terms. Define an NWFPS with Robinson arithmetic axioms. Prove that for specific Σ₁ sentences (e.g., "there exists n such that n² = 4"), a convergent self-referential proof exists at height ≤ ω. Then attempt the general case.

**Impact**: This would show that self-referential proofs capture exactly the computationally verifiable truths at low ordinal heights, providing a proof-theoretic characterization of Σ₁-completeness through self-reference.

**Catalog References**: `Logic/NonWellFoundedProofs.lean` (NWFProofSystem, convergence_of_derivability), `Logic/Completeness.lean`

**Proof Strategy**:
1. Extend Formula to include first-order quantifiers and arithmetic terms.
2. Define NWFPS with Robinson Q axioms.
3. For Σ₁ sentences ∃x.P(x), the witness n provides a proof at finite height; the self-referential wrapping adds at most ω.
4. Key lemma: Σ₁ completeness of Robinson arithmetic (standard result, needs formalization).

**Domain Bridges**: Logic (proof theory) <-> Computation (decidability, halting problem) — self-referential proof convergence as a decidability criterion.

**Lineage**: Extends liar_implies_inconsistency and the consistency analysis from this cycle to richer logical systems.

**Ambition**: extension

---

### Direction 4: Paraconsistent Non-Well-Founded Proofs

**Conjecture**: In a paraconsistent logic (where P ∧ ¬P does not entail ⊥), liar-like formulas have convergent self-referential proofs at height ω, and the resulting system is non-trivial (does not derive every formula).

**Test**: Define a paraconsistent NWFPS by replacing the negation elimination rule with a weaker rule (e.g., relevant implication). Show that liar-like formulas converge in this system. Verify non-triviality by showing that some formula (e.g., ⊥) is not derivable.

**Impact**: This would bridge non-well-founded proof theory with paraconsistent logic (Catalog: `Logic/ParaconsistentParadox.lean`), showing that the "paradox vs. convergence" dichotomy depends on the underlying logic. In classical logic, liar sentences are divergent; in paraconsistent logic, they may converge to a "dialetheia" (true contradiction).

**Catalog References**: `Logic/NonWellFoundedProofs.lean` (isLiarLike, liar_implies_inconsistency), `Catalog/Logic/ParaconsistentParadox.lean` (liar_value_fixed)

**Proof Strategy**:
1. Define a paraconsistent derivability relation that drops explosion (ex falso quodlibet).
2. Show that without explosion, liar-like formulas no longer force inconsistency.
3. Construct an explicit model where the liar has a fixed point at height ω.
4. Prove non-triviality by exhibiting a formula that cannot be derived.

**Domain Bridges**: Logic (proof theory) <-> Logic (paraconsistent logic) <-> Philosophy (dialethism, true contradictions)

**Lineage**: Directly extends liar_implies_inconsistency by removing the negation elimination hypothesis.

**Ambition**: extension

---

### Direction 5: Tropical Proof Complexity and Self-Reference

**Conjecture**: The convergence ordinal of a self-referential proof can be computed as a tropical (min-plus) optimization problem: if proof heights are "costs" and modus ponens takes the max (= tropical sum) of its premises, then the convergence ordinal is the tropical eigenvalue of the dependency graph's adjacency matrix.

**Test**: Formalize the dependency graph of a self-referential proof (nodes = formulas, edges = derivability dependencies). Compute the tropical eigenvalue for small examples (P → P, (P → Q) → (P → Q), liar-like formulas). Verify that the tropical eigenvalue matches the convergence ordinal for convergent cases and is undefined for divergent cases.

**Impact**: This would connect non-well-founded proof theory to tropical mathematics, providing computational tools for analyzing self-referential proofs. Tropical eigenvalues are computable, so this would give an effective decision procedure for convergence classification.

**Catalog References**: `Logic/NonWellFoundedProofs.lean` (derivabilityOp_monotone, approxChain_monotone), `Tropical/` (tropical semiring definitions), `Catalog/Logic/TropicalGodelSentence.lean` (tropical_diagonal_fixed_point)

**Proof Strategy**:
1. Define the dependency graph of a self-referential proof.
2. Assign tropical weights (ordinal heights) to edges.
3. Compute the tropical spectral radius (max cycle mean).
4. Prove: convergence iff the tropical spectral radius is finite.
5. Connect to the existing tropical Gödel sentence work in the Catalog.

**Domain Bridges**: Logic (proof theory) <-> Tropical (min-plus algebra) <-> Computation (graph algorithms) — tropical methods as proof complexity tools.

**Lineage**: Connects this cycle's ordinal analysis with the Catalog's tropical mathematics work, particularly `tropical_diagonal_fixed_point`.

**Ambition**: grand_challenge
