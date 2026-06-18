# Future Directions: Non-Well-Founded Proof Theory

## Synthesis

This research cycle established the formal foundations of non-well-founded proof theory: an inductive type for self-referential proof trees, ordinal height measures, fixed-point semantics via Kleene iteration, and a surprising bridge to tropical geometry. The most significant discovery is that the algebraic structure of proof heights (min for selection, plus for composition) naturally forms a tropical semiring, connecting proof complexity to the rapidly growing field of tropical algebraic geometry.

The most promising cross-domain connection is the **tropical proof height bridge**. Tropical geometry has powerful tools for studying piecewise-linear structures — Newton polytopes, tropical curves, tropical intersection theory — that have never been applied to proof complexity. If the "tropical variety" of a proof system (the set of achievable proof height vectors) can be computed explicitly, it would provide a geometric characterization of a proof system's deductive power, potentially relating to classical complexity-theoretic questions about proof length and circuit depth.

The cycle's results connect to the broader Catalog through the fixed-point constructions in `Bridges/EMLClosureCore.lean` (fixed_point_construction_bound) and `Bridges/HolographicProofRenormalization.lean` (exists_fixed_point_on_orbit_with_bound), as well as the tropical proof semantics in `Speculative/AutoResearch/Bridges/TropicalProofSemantics.lean`. The self-reference theory connects to the guarded fixpoint work in `Logic/GuardedFixpoint.lean` and the self-referential theories in `Logic/SelfReferentialTheories.lean`. Future work should leverage these existing formalizations as building blocks for deeper results.

---

### Direction 1: Coinductive Non-Well-Founded Proofs and Transfinite Heights

**Conjecture**: The space of coinductive (truly infinite) proof trees, equipped with the bisimulation equivalence and ordinal height function extended to transfinite ordinals, is a Scott domain where valid NWF proofs correspond to compact elements and the liar-type sentences are precisely the non-compact points.

**Test**: Formalize coinductive proof trees in Lean 4 using `CoInductive` or stream-based encodings. Construct a proof tree of height ω (the first infinite ordinal) by iterating the identity proof construction infinitely, and prove it is a valid NWF proof. Then show that the liar sentence's infinite unfolding (`selfRef(p, selfRef(p, selfRef(p, ...)))` with bottom at every level) does NOT converge in the Scott topology.

**Impact**: If true, this provides a complete topological characterization of valid vs. invalid self-reference. If false (e.g., if all infinite proof trees are non-compact), it means the finite-height theory captures all interesting phenomena and the coinductive extension adds no new valid proofs.

**Catalog References**: `Logic/GuardedFixpoint.lean` (guardedLfp_fixed, finite_unfoldings_imp_guardedTrace_eq), `Logic/SelfReferentialTheories.lean` (SelfReferentialConsciousness)

**Proof Strategy**: Use the guarded fixpoint machinery from `Logic/GuardedFixpoint.lean` — specifically the `GuardedOrder'` class with ω-chain completeness and the `guardedLfp_fixed` theorem — to construct the Scott domain. Define compactness via finite approximation: a proof tree is compact iff it has a finite approximant that contains all its information. Prove that `selfRef(p, axiom_(p))` is compact (approximated by itself) while the liar unfolding is not (each finite truncation loses information).

**Domain Bridges**: Logic <-> Computation (domain theory), Logic <-> Topology (Scott domains)

**Lineage**: Builds on `Speculative/NonWellFoundedProofs/Core.lean` (this cycle) and `Logic/GuardedFixpoint.lean` (existing catalog)

**Ambition**: grand_challenge

---

### Direction 2: Tropical Proof Complexity and Algebraic Geometry

**Conjecture**: For a proof system with n axioms and m deduction rules, the tropical variety of achievable proof height vectors is a tropical polytope in ℝⁿ with at most 2^m vertices, and the shortest proof of any theorem can be found in polynomial time by tropical linear programming.

**Test**: Implement tropical polytope computation for concrete proof systems with 5–10 axioms and 10–20 rules. Compare the tropical shortest-proof computation to exhaustive search. If they disagree, the conjecture is false. If they agree and the tropical computation is polynomial-time, the conjecture provides an efficient proof search algorithm.

**Impact**: If true, this gives a polynomial-time algorithm for optimal proof search in bounded proof systems — a major result connecting tropical geometry to automated reasoning. If false, it reveals where the tropical structure breaks down, which is itself interesting (possibly at non-linear deduction rules).

**Catalog References**: `Speculative/AutoResearch/Bridges/TropicalProofSemantics.lean` (derivable_implies_prime_valid), `Tropical/` directory (various tropical algebra results)

**Proof Strategy**: First, formalize the notion of a "proof height vector" — for each proof system, the function mapping propositions to their shortest proof height. Show this is a tropical linear combination of the axiom height vectors. Then prove the vertex bound using combinatorics of rule applications. The tropical linear programming step uses existing results from tropical optimization theory (Butkovič 2010).

**Domain Bridges**: Logic <-> Tropical Geometry, Computation <-> Algebraic Geometry

**Lineage**: Builds on `TropicalProofHeight` and `tropMul_tropAdd_distrib` from this cycle

**Ambition**: grand_challenge

---

### Direction 3: Self-Reference Elimination Theorem

**Conjecture**: Every valid NWF proof tree with self-reference depth d > 0 can be transformed into a valid proof tree with self-reference depth 0 (i.e., a well-founded proof), provided the proof system has enough axioms. Formally: for any valid `selfRef(p, t)`, there exists a valid `t'` with `t'.conclusion = some p` and `selfRefDepth(t') = 0`.

**Test**: Attempt to prove this in Lean 4 by constructing the elimination procedure. The key step is showing that `selfRef(p, axiom_(p))` can be replaced by `axiom_(p)` directly (since axiom_(p) is valid and has the same conclusion), and that more complex self-references can be unrolled by induction on self-reference depth.

**Impact**: If true, self-referential proofs are merely a notational convenience — they add no deductive power beyond well-founded proofs. This would be a "normalization theorem" for NWF proofs, analogous to cut-elimination in sequent calculus. If false, it identifies propositions that *essentially require* self-reference, which would be a striking discovery.

**Catalog References**: `Speculative/NonWellFoundedProofs/Core.lean` (selfRefEliminable, selfRefDepth_le_depth, depth_zero_no_selfref)

**Proof Strategy**: Induction on self-reference depth. Base case (d = 1): `selfRef(p, axiom_(p))` → `axiom_(p)`. Inductive case: for `selfRef(p, t)` where `t` has self-reference depth d - 1, first apply the induction hypothesis to eliminate self-references in `t`, then eliminate the outer self-reference. The key lemma needed is that if `t.conclusion = some p` and `t` is valid, then adding `p` as an axiom doesn't change the deductive closure.

**Domain Bridges**: Logic <-> Algebra (normalization theory)

**Lineage**: Directly extends `selfRefEliminable` conjecture from this cycle

**Ambition**: extension

---

### Direction 4: Contraction Maps and Proof Convergence Rates

**Conjecture**: For a proof contraction with contraction factor r = p/q (where 0 < p < q), the Kleene iterates converge to the fixed point with error bounded by r^n × ‖step(⊥)‖ after n iterations, and this bound is tight (achieved by some proof system).

**Test**: Formalize the contraction convergence bound in Lean 4. Construct explicit proof systems achieving the bound for various contraction factors (1/2, 2/3, 3/4). Prove the bound is tight by constructing a witness achieving equality.

**Impact**: If true, this gives precise convergence rate guarantees for self-referential proof evaluation, with applications to recursive program verification (where self-referential programs correspond to NWF proofs of their own correctness). The tightness result would show the bound cannot be improved.

**Catalog References**: `FINAL/Bridges/EMLClosureCore.lean` (fixed_point_construction_bound), `FINAL/Bridges/HolographicProofRenormalization.lean` (exists_fixed_point_on_orbit_with_bound)

**Proof Strategy**: Adapt the fixed-point construction bound from `EMLClosureCore.lean`, which bounds the number of iterations needed for closure operators. The key adaptation is replacing the abstract closure operator with our concrete `ProofContraction` structure and relating the contraction factor to the convergence rate. Use the Banach fixed-point theorem framework from Mathlib.

**Domain Bridges**: Logic <-> Analysis (metric fixed-point theory), Logic <-> Computer Science (recursive programs)

**Lineage**: Builds on `ProofContraction` structure from this cycle and `fixed_point_construction_bound` from EML closure theory

**Ambition**: extension

---

### Direction 5: NWF Proofs and Neural Reasoning Verification

**Conjecture**: The circular reasoning patterns produced by transformer-based language models can be classified as valid or invalid NWF proofs, and the validity rate correlates with the model's reasoning accuracy on independent benchmarks.

**Test**: Extract argument graphs from 100 chain-of-thought reasoning traces from a language model. Convert each to an NWF proof tree. Compute ordinal heights, self-reference depths, and validity. Measure correlation between NWF validity rate and final answer correctness.

**Impact**: If the correlation is strong (r > 0.5), NWF proof theory provides a formal framework for evaluating AI reasoning quality without ground-truth answers. If weak, it suggests that circular reasoning in LLMs is fundamentally different from mathematical self-reference, which is itself an interesting negative result.

**Catalog References**: `MachineLearning/` directory (machine learning formalization), `Logic/SelfReferentialTheories.lean` (QuineSystem, SelfJustifyingSystem)

**Proof Strategy**: This is primarily an empirical direction. The formal component involves proving that the NWF validity classifier is decidable (which follows from our `DecidablePred IsValidNWF` instance) and that it can be computed in linear time in the proof tree size. The empirical component requires implementing the classifier in Python and running it on LLM outputs.

**Domain Bridges**: Logic <-> MachineLearning, Computation <-> AI

**Lineage**: Extends the cross-domain bridge between proof theory and machine learning identified in the Catalog structural analysis

**Ambition**: extension
