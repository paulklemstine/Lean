# Future Directions: Tropical Curry–Howard and Idempotent Proof Theory

## 1. Extend Cost Semantics to `ℝ≥0∞` and Continuous Tropical Semirings

**Goal**: Generalize the current `Nat`-valued cost semantics to extended non-negative reals (`ℝ≥0∞ = [0, ∞]`), enabling:
- **Unreachable proofs**: Infinite cost represents logical impossibility or resource-unconstrained derivations.
- **Continuous optimization**: Fractional costs model probabilistic or weighted proofs.
- **Tropical analytic semantics**: Connect to the theory of tropical power series and Maslov dequantization.

**Proof Strategy**: Replace `Nat` in `cost` with `ℝ≥0∞` (Mathlib's `ENNReal`). The key challenge is that `min` over `ℝ≥0∞` is still idempotent, but `+` has infinity-absorption: `∞ + x = ∞`. This creates a richer normal form theory where unreachable subproofs propagate. The distributivity law `a + min(b,c) = min(a+b, a+c)` holds in `ENNReal`, so the current proof architecture transfers. Strong normalization may need a different interpretation (ordinal-valued or lexicographic).

**Cross-Domain**: Links to Litvinov's dequantization program, tropical probability (log-sum-exp limits), and max-plus control theory.

---

## 2. Sequent Calculus with Typed Tropical Proofs

**Goal**: Build a simply-typed sequent calculus whose cut elimination maps homomorphically into the current min-plus core.

**Concrete Plan**:
1. Define types `TropType := Base | Arrow TropType TropType | Tensor TropType TropType | With TropType TropType`.
2. Define typed proof terms with a typing judgment `⊢ Γ ⊢ t : A` where contexts carry cost annotations.
3. Define typed cut elimination as typed `TropStep`.
4. Prove a **typing preservation** theorem: typed reductions project to `TropStep` on the erased term.
5. Prove the **subformula property**: normal proofs only use subformulas of the conclusion.

This would establish that the tropical Curry–Howard correspondence is not just a term calculus but a full logic with propositions, contexts, and structural rules — where every structural operation has a cost.

**Hypothesis**: The `With` connective (additive conjunction in linear logic) corresponds exactly to `tmin`, and `Tensor` to `tplus`. This would connect tropical proof theory to linear logic resource semantics.

---

## 3. Graph-Theoretic Representation: Tropical Proofs as Dynamic Programs

**Goal**: Prove a representation theorem: tropical proof terms biject with finite acyclic dynamic programs (weighted DAGs with source and sink).

**Concrete Construction**:
1. Define `WeightedDAG` as a finite directed acyclic graph with edge weights in `Nat` and designated source/sink vertices.
2. Define `encodePaths : WeightedDAG → TropProof` that encodes all source-to-sink paths as a `tmin` of `tplus`-chains.
3. Define `decodeToProg : TropProof → WeightedDAG` that recovers a canonical DAG from a normal form.
4. Prove: `cost (normalize (encodePaths G)) = shortestPathWeight G`.

**Key Lemma**: The normalization process on encoded DAGs simulates Bellman–Ford relaxation steps. Each `tmin_idem` collapse corresponds to discarding a dominated path. Each distribution step corresponds to edge relaxation.

**Impact**: This would make the tropical normalizer a *certified shortest-path algorithm* under Curry–Howard, directly connecting proof theory to algorithm verification.

---

## 4. Tropical Proof Complexity Invariants

**Goal**: Develop proof complexity measures that are invariant under reduction, measuring the "intrinsic complexity" of a proof beyond its cost.

**Concrete Definitions**:
1. **Min-depth**: The maximum nesting depth of `tmin` in a term. Measures the "branching complexity" of a proof search.
2. **Cut-rank**: The maximum nesting depth of `cut` in a term. Measures the logical depth of the argument.
3. **Tropical width**: The number of distinct atoms reachable by expanding all `tmin` branches. Measures the "search space size."

**Theorems to Prove**:
- Normalization weakly decreases min-depth (idempotent collapse removes redundant branches).
- Cut-rank may increase under distribution but is bounded by the product of the original cut-rank and min-depth.
- Tropical width is preserved by cost-preserving reductions and characterizes the "effective dimension" of the proof.

**Connection to Tropical Geometry**: The tropical width corresponds to the number of vertices of the tropical hypersurface associated with the proof's cost polynomial. This links proof complexity to polyhedral combinatorics.

---

## 5. Weighted Automata and Viterbi Decoding Connection

**Goal**: Interpret tropical proof terms as weighted finite automata and show that normalization computes the Viterbi (most-likely-path) decoding.

**Concrete Plan**:
1. Define a weighted finite automaton (WFA) type with states, transitions, and `Nat` weights.
2. Define `encodeWFA : WFA → TropProof` that encodes the accepting computation tree of a WFA as a tropical proof term.
3. Prove: `cost (normalize (encodeWFA A w)) = viterbiCost A w` where `w` is an input word.

**Why This Matters**: The Viterbi algorithm is the workhorse of speech recognition, bioinformatics (sequence alignment), and error-correcting codes. Showing that it is an instance of tropical proof normalization would:
- Provide a logical foundation for Viterbi-style algorithms.
- Enable correctness certificates: a normalized proof term IS a verified Viterbi trace.
- Suggest new Viterbi-like algorithms by exploring different proof reduction strategies.

**Hypothesis**: Different reduction strategies (leftmost-outermost, rightmost-innermost, parallel) correspond to different dynamic programming evaluation orders (forward, backward, divide-and-conquer), all producing the same optimal cost by confluence.

---

## Cross-Cutting Research Program: Idempotent Proof Theory

All five directions above are facets of a single research program: **idempotent proof theory**, the systematic study of proof systems whose logical connectives satisfy idempotent laws.

The central thesis is:

> Idempotent connectives turn proof normalization into optimization, because duplicate derivations collapse into canonical representatives.

This thesis should be testable across multiple logical systems:
- **Tropical (min-plus)**: `min` is idempotent → normalization = shortest path.
- **Boolean (and/or)**: `and`, `or` are idempotent → normalization = SAT solving.
- **Lattice-valued logic**: `meet`, `join` are idempotent → normalization = fixpoint computation.
- **Quantale semantics**: The general algebraic framework unifying all of the above.

Each of these should yield its own canonical normalization theorem, connected by functorial translations between the corresponding proof calculi. Formalizing this hierarchy in a proof assistant would establish idempotent proof theory as a new subfield at the intersection of proof theory, algebra, and algorithm design.
