# Future Directions

## Synthesis

This research establishes a bridge between residual finiteness of free groups and bounded model completeness for algebraic program equivalence. The five directions below extend this bridge along complementary axes: (1) proving the sharp quantitative separation conjecture, (2) formalizing residual finiteness itself, (3) extending to groups with relations, (4) optimizing test suites for practical use, and (5) exploring connections to automata-theoretic methods. Each direction builds on the formally verified infrastructure (evaluation transfer, Cayley embedding, test suite existence) and is designed to be both mathematically deep and computationally testable.

---

## Direction 1: Universal Symmetric-Group Separator Conjecture

**Conjecture.** For the free group F_n on n generators, every pair of distinct reduced words of length ≤ L can be separated by an evaluation into S_{L+1}, i.e., `permSepProfile(Fin n, L) ≤ L + 1` for all L ≥ 2.

**Test.** Exhaustive computation for n = 2 and L ∈ {4, 5, 6, 7}. For each L, enumerate all reduced words of length ≤ L, and for each distinct pair, search for a separating assignment φ : {a,b} → S_{L+1}. Record the fraction of pairs separated and the maximum required degree.

**Impact.** If true, this gives a tight linear bound on the permutation degree needed for bounded separation, implying that program equivalence up to size L is decidable by searching over at most ((L+1)!)^n assignments. This is finite and concrete.

**Catalog References.** `Pythagorean/ResidualFiniteness.lean`: `UniversalSymmSeparatorUpTo`, `universalSymmSeparator_mono`, `freeGroup_perm_separation_bounded`.

**Proof Strategy.** The Stallings automaton construction yields degree L+1 separators for individual words. For pairs, the difference word has length ≤ 2L, giving degree ≤ 2L+1. Improving this to L+1 for pairs requires showing that the Stallings automata for different pairs can be "overlaid" on a shared vertex set of size L+1. This may follow from a refined Stallings folding argument.

**Domain Bridges.** Connects quantitative group theory (growth of separation profile) to computational complexity (decidability bounds) and automata theory (Stallings foldings as NFA constructions).

**Lineage.** Extends the qualitative residual finiteness theorem to a quantitative separation bound.

**Ambition.** Grand challenge — would establish a new quantitative invariant in geometric group theory with direct algorithmic consequences.

---

## Direction 2: Full Formal Verification of Free Group Residual Finiteness

**Conjecture.** The Stallings automaton construction can be fully formalized in Lean 4 + Mathlib, removing the sole `sorry` in the current development.

**Test.** Implement the construction as a Lean definition and verify the path property (the composition of Stallings permutations maps vertex 0 to vertex L for a word of length L). Verify with `#print axioms` that no non-standard axioms are used.

**Impact.** Completes the formal verification chain: all theorems (bounded separation, test suite existence, permutation upgrade) would be fully machine-verified with zero unproved assumptions.

**Catalog References.** `Pythagorean/ResidualFiniteness.lean`: `freeGroup_residuallyFinite`, `freeGroup_finite_separation_bounded`, `finite_test_suite_exists`.

**Proof Strategy.** 
1. Define `stallingsMap : List (α × Bool) → α → Equiv.Perm (Fin (L+1))` using partial permutation extension.
2. Prove a helper lemma: `partialInjExtend` showing that any partial injection on Fin n extends to a full permutation.
3. Prove the path property by induction on the word, tracking the image of vertex 0 through each letter application.
4. Connect to `FreeGroup.lift` via `evalWordList_eq_lift` (proven interactively in our development).

**Domain Bridges.** Formal methods (machine-verified proofs), combinatorial group theory (Stallings automata), and type theory (dependent types for bounded permutations).

**Lineage.** Directly eliminates the one remaining sorry in the current catalog entry.

**Ambition.** Solid extension — well-scoped and achievable with focused effort on Lean formalization.

---

## Direction 3: Extension to Groups with Relations

**Conjecture.** The bounded test suite theorem extends to finitely presented groups G = ⟨α | R⟩ whenever G is residually finite. Specifically, for any residually finite finitely presented group, there exists a finite test suite for bounded-length words.

**Test.** Implement and test for specific groups:
- Braid group B₃ = ⟨σ₁, σ₂ | σ₁σ₂σ₁ = σ₂σ₁σ₂⟩ (residually finite)
- Surface groups π₁(Σ_g) (residually finite by Hempel's theorem)
- Compare test suite sizes between free groups and quotient groups

**Impact.** Extends the testing oracle from free semantics to semantics with algebraic laws (e.g., commutativity of independent operations, braid relations in topological quantum computation).

**Catalog References.** `Pythagorean/ResidualFiniteness.lean`: `eval_eq_iff_mul_inv_eq_one`, `finite_group_separator_to_perm_separator`.

**Proof Strategy.** The evaluation transfer theorem (Theorem 2) and Cayley upgrade (Theorem 5) work for any group, not just free groups. The bounded test suite theorem requires: (a) residual finiteness of G, (b) decidability of the word problem in G (to enumerate distinct elements), and (c) finiteness of the ball of radius L in the Cayley graph.

**Domain Bridges.** Geometric group theory (residual finiteness of various classes), topological quantum computation (braid groups), and knot theory (knot groups).

**Lineage.** Natural generalization of the free-group theory to quotient groups.

**Ambition.** Grand challenge — requires understanding residual finiteness for broad classes of groups.

---

## Direction 4: Optimal Test Suite Compression

**Conjecture.** For the free group on 2 generators and words of length ≤ L, the minimum-size test suite has O(L) tests (rather than the naive O(|S|²) = O(4^L) bound).

**Test.** For L ∈ {1, 2, 3, 4, 5}:
1. Compute the minimum-size test suite by greedy set-cover.
2. Compare with the Stallings-based suite and the brute-force suite.
3. Plot suite size vs. L; fit to polynomial and exponential models.

**Impact.** Practical: a polynomial-size test suite would make bounded algebraic testing feasible for real programs. Theoretical: connects to the set-cover problem and combinatorial optimization.

**Catalog References.** `Pythagorean/ResidualFiniteness.lean`: `TestSuiteCompleteUpTo`, `finite_test_suite_exists`.

**Proof Strategy.** Use the observation that a single permutation evaluation can separate many pairs simultaneously. The Stallings construction for the "hardest" pair may also separate easier pairs. A greedy set-cover algorithm provides a log-factor approximation to the optimal suite.

**Domain Bridges.** Combinatorial optimization (set cover), coding theory (separating codes), and practical software testing (test minimization).

**Lineage.** Directly optimizes the test suite construction from Theorem 3.

**Ambition.** Solid extension with immediate practical applications.

---

## Direction 5: Automata-Theoretic Separation via Stallings Foldings

**Conjecture.** The Stallings folding algorithm produces separating permutation representations of degree at most L+1 for all nontrivial words of length ≤ L, and this bound is tight.

**Test.** 
1. Implement the full Stallings folding algorithm (not just the path construction).
2. For L ∈ {1, ..., 8}, compare the degrees of Stallings-produced separators with the brute-force minimum.
3. Determine whether Stallings foldings always achieve the minimum degree.

**Impact.** Would provide a constructive, polynomial-time algorithm for optimal-degree separation, connecting the algebraic testing framework to automata theory and formal language methods.

**Catalog References.** `Pythagorean/ResidualFiniteness.lean`: `wordLength`, `freeGroup_residuallyFinite`.

**Proof Strategy.** The Stallings folding algorithm takes a finite graph representing a subgroup of the free group and folds it into a minimal immersion. For the subgroup ⟨w⟩ generated by a single word w, the folded graph has at most L+1 vertices (where L = |w|), and the monodromy action gives a permutation representation of degree ≤ L+1 that is nontrivial on w.

**Domain Bridges.** Automata theory (NFA minimization as graph folding), topology (covering spaces of graphs), and formal language theory (regular languages as finite-state actions).

**Lineage.** Provides the constructive and quantitative content underlying the existential residual finiteness theorem.

**Ambition.** Solid extension with deep connections to multiple fields.
