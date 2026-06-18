
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: The phantom number of a topology τ is the minimum cardinality of a set of strict
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Phantom Topologies

## 1. Phantom Number Computation for Finite Lattices

The phantom number of a topology τ is the minimum cardinality of a set of strictly finer topologies whose consensus (intersection of open set families) recovers τ. For finite topological spaces, this becomes a purely combinatorial problem on the lattice of topologies.

**Conjecture:** For a finite type X with |X| = n, the phantom number of the indiscrete topology on X equals 2 for all n ≥ 2. More generally, for any non-discrete topology τ on a finite set, the phantom number is at most n − 1.

The key insight is that our `complementary_consensus_eq_top` theorem already shows phantom number ≤ 2 for indiscrete topologies using complementary singleton-set pairs. The upper bound for general topologies should follow from the anti-isomorphism between the lattice of topologies on X and the lattice of preorders on X, where covering relations in the preorder lattice correspond to "atomic refinements" of the topology. Each such refinement adds exactly one new open set, and sufficiently many complementary refinements should reconstruct any target topology.

**Why now?** The `singletonSetTopology` construction and `complementary_consensus_eq_top` provide a concrete template for building phantom pairs. Extending this to general pairs of atoms in the topology lattice is a natural next step that requires only finite lattice combinatorics, which Mathlib supports well via `Fintype` and `Finset`.

## 2. Sorgenfrey Line as a Canonical Phantom Pair for ℝ

The standard topology on ℝ is the consensus of the lower-limit (Sorgenfrey) topology (basis: half-open intervals [a, b)) and the upper-limit topology (basis: half-open intervals (a, b]). This is because [a, b) ∩ (a, b] = (a, b) for a < b.

**Conjecture:** The Sorgenfrey pair constitutes a phantom representation of the standard topology on ℝ, and moreover this representation is *minimal* in the sense that no single strictly finer topology has consensus equal to the standard topology.

The key insight is that the standard topology on ℝ is connected, but neither the Sorgenfrey topology nor the upper-limit topology is connected (they are both totally disconnected). The consensus of a single totally disconnected refinement cannot recover a connected topology, so at least 2 observers are needed. This suggests the phantom number of the standard topology on ℝ is exactly 2.

**Why now?** Our framework provides the definition of `IsPhantomRepresentation` and the consensus characterization theorem. Mathlib has extensive coverage of the order topology on ℝ and the Sorgenfrey line is definable using `TopologicalSpace.generateOpen` with half-open intervals. The main work is proving the consensus identity, which reduces to the interval identity [a,b) ∩ (a,b] = (a,b).

## 3. Phantom Functoriality and Sheaf Structure

Our `consensus_pullback_surjective` theorem shows that the consensus construction is functorial: surjective maps of observer spaces preserve the consensus. This suggests a deeper categorical structure.

**Conjecture:** The assignment O ↦ {phantom systems on X indexed by O} extends to a functor from the category of sets (with surjections) to the lattice of topologies on X. Moreover, if the observer space O carries its own topology and the map o ↦ T(o) is "continuous" (the set of observers for whom a fixed set U is open is itself open in O), then the consensus topology is determined by a sheaf on O, and the consensus equals the global sections of this sheaf.

The key insight is that the consensus construction `∀ o, IsOpen_o(U)` is formally identical to the "global sections" functor applied to the presheaf o ↦ {open sets of T(o)}. The pullback surjectivity theorem we proved is the first structural property needed for sheafification. The sheaf condition would correspond to a locality axiom: if U is "locally open" (open for all observers in a covering family), then U is consensus-open.

**Why now?** The `consensus_pullback_surjective` and `consensus_pullback_le` theorems establish the basic functorial behavior. Mathlib's sheaf theory (in `Mathlib.Topology.Sheaves`) provides the categorical infrastructure. The main gap is formalizing the continuity condition on observer assignments and verifying the sheaf axioms.

## 4. Rigidity Spectrum: Classifying Topologies by Phantom Number

Our results establish two extremes: discrete topologies have phantom number ∞ (no representation exists), while indiscrete topologies on nontrivial types have phantom number 2. What happens in between?

**Conjecture:** For a topological space (X, τ), the phantom number is finite if and only if τ is not T₁. Equivalently, T₁ spaces are "phantom-rigid" (cannot be reconstructed from strictly finer observers), while non-T₁ spaces always admit finite phantom representations.

The key insight is that in a T₁ space, every singleton is closed, so the topology is "close to discrete" in a precise sense. The lattice of topologies finer than a T₁ topology has a very different structure from the lattice above a non-T₁ topology: in the T₁ case, refinements tend to be "independent" (adding one open set doesn't constrain others), making it impossible for a finite set of refinements to have consensus exactly τ. In the non-T₁ case, the failure of T₁ provides "dependent" pairs of points that can be leveraged to build phantom pairs, generalizing our complementary singleton construction.

**Why now?** The `singletonSetTopology_lt_top` and `complementary_consensus_eq_top` theorems provide the template for the non-T₁ direction. For the T₁ direction, the key tool would be Mathlib's `T1Space` class and the characterization of T₁ topologies as those where singletons are closed. Testing this conjecture on small finite spaces (|X| = 3, 4) would be computationally feasible using `Fintype` and `DecidableEq`.

## 5. Phantom Entropy: Information-Theoretic Measures of Topological Complexity

The phantom number measures the minimum number of "perspectives" needed to reconstruct a topology. This suggests an information-theoretic interpretation: each observer carries partial information about the topology, and the phantom number measures the minimum information redundancy needed for exact reconstruction.

**Conjecture:** Define the *phantom entropy* of a topology τ as the infimum of H(P) over all phantom representations P, where H(P) = log₂(|O|) for a finite observer set O. Then for finite topological spaces, the phantom entropy equals log₂ of the width of the interval [τ, ⊥] in the topology lattice (i.e., the maximum number of pairwise incomparable topologies strictly between τ and discrete).

The key insight is that each observer in a phantom representation contributes an independent "direction" of refinement, and the number of such independent directions is bounded by the width of the refinement interval. This connects phantom topology to antichain theory in finite lattices, where the width equals the maximum antichain size by Dilworth's theorem.

**Why now?** Our formalization provides the first rigorous framework for studying phantom representations. Computing phantom entropy for small finite types (|X| ≤ 4) is feasible using Lean's `native_decide` or `Fintype.card` machinery, which would provide concrete data to test and refine the conjecture before attempting a general proof.

**Concept description**: # Future Directions: Phantom Topologies

## 1. Phantom Number Computation for Finite Lattices

The phantom number of a topology τ is the minimum cardinality of a set of strictly finer topologies whose consensus (intersection of open set families) recovers τ. For finite topological spaces, this becomes a purely combinatorial problem on the lattice of topologies.

**Conjecture:** For a finite type X with |X| = n, the phantom number of the indiscrete topology on X equals 2 for all n ≥ 2. More generally, for any non-discrete topology τ on a finite set, the phantom number is at most n − 1.

The key insight is that our `complementary_consensus_eq_top` theorem already shows phantom number ≤ 2 for indiscrete topologies using complementary singleton-set pairs. The upper bound for general topologies should follow from the anti-isomorphism between the lattice of topologies on X and the lattice of preorders on X, where covering relations in the preorder lattice correspond to "atomic refinements" of the topology. Each such refinement adds exactly one new open set, and sufficiently many complementary refinements should reconstruct any target topology.

**Why now?** The `singletonSetTopology` construction and `complementary_consensus_eq_top` provide a concrete template for building phantom pairs. Extending this to general pairs of atoms in the topology lattice is a natural next step that requires only finite lattice combinatorics, which Mathlib supports well via `Fintype` and `Finset`.

## 2. Sorgenfrey Line as a Canonical Phantom Pair for ℝ

The standard topology on ℝ is the consensus of the lower-limit (Sorgenfrey) topology (basis: half-open intervals [a, b)) and the upper-limit topology (basis: half-open intervals (a, b]). This is because [a, b) ∩ (a, b] = (a, b) for a < b.

**Conjecture:** The Sorgenfrey pair constitutes a phantom representation of the standard topology on ℝ, and moreover this representation is *minimal* in the sense that no single strictly finer topology has consensus equal to the standard topology.

The key insight is that the standard topology on ℝ is connected, but neither the Sorgenfrey topology nor the upper-limit topology is connected (they are both totally disconnected). The consensus of a single totally disconnected refinement cannot recover a connected topology, so at least 2 observers are needed. This suggests the phantom number of the standard topology on ℝ is exactly 2.

**Why now?** Our framework provides the definition of `IsPhantomRepresentation` and the consensus characterization theorem. Mathlib has extensive coverage of the order topology on ℝ and the Sorgenfrey line is definable using `TopologicalSpace.generateOpen` with half-open intervals. The main work is proving the consensus identity, which reduces to the interval identity [a,b) ∩ (a,b] = (a,b).

## 3. Phantom Functoriality and Sheaf Structure

Our `consensus_pullback_surjective` theorem shows that the consensus construction is functorial: surjective maps of observer spaces preserve the consensus. This suggests a deeper categorical structure.

**Conjecture:** The assignment O ↦ {phantom systems on X indexed by O} extends to a functor from the category of sets (with surjections) to the lattice of topologies on X. Moreover, if the observer space O carries its own topology and the map o ↦ T(o) is "continuous" (the set of observers for whom a fixed set U is open is itself open in O), then the consensus topology is determined by a sheaf on O, and the consensus equals the global sections of this sheaf.

The key insight is that the consensus construction `∀ o, IsOpen_o(U)` is formally identical to the "global sections" functor applied to the presheaf o ↦ {open sets of T(o)}. The pullback surjectivity theorem we proved is the first structural property needed for sheafification. The sheaf condition would correspond to a locality axiom: if U is "locally open" (open for all observers in a covering family), then U is consensus-open.

**Why now?** The `consensus_pullback_surjective` and `consensus_pullback_le` theorems establish the basic functorial behavior. Mathlib's sheaf theory (in `Mathlib.Topology.Sheaves`) provides the categorical infrastructure. The main gap is formalizing the continuity condition on observer assignments and verifying the sheaf axioms.

## 4. Rigidity Spectrum: Classifying Topologies by Phantom Number

Our results establish two extremes: discrete topologies have phantom number ∞ (no representation exists), while indiscrete topologies on nontrivial types have phantom number 2. What happens in between?

**Conjecture:** For a topological space (X, τ), the phantom number is finite if and only if τ is not T₁. Equivalently, T₁ spaces are "phantom-rigid" (cannot be reconstructed from strictly finer observers), while non-T₁ spaces always admit finite phantom representations.

The key insight is that in a T₁ space, every singleton is closed, so the topology is "close to discrete" in a precise sense. The lattice of topologies finer than a T₁ topology has a very different structure from the lattice above a non-T₁ topology: in the T₁ case, refinements tend to be "independent" (adding one open set doesn't constrain others), making it impossible for a finite set of refinements to have consensus exactly τ. In the non-T₁ case, the failure of T₁ provides "dependent" pairs of points that can be leveraged to build phantom pairs, generalizing our complementary singleton construction.

**Why now?** The `singletonSetTopology_lt_top` and `complementary_consensus_eq_top` theorems provide the template for the non-T₁ direction. For the T₁ direction, the key tool would be Mathlib's `T1Space` class and the characterization of T₁ topologies as those where singletons are closed. Testing this conjecture on small finite spaces (|X| = 3, 4) would be computationally feasible using `Fintype` and `DecidableEq`.

## 5. Phantom Entropy: Information-Theoretic Measures of Topological Complexity

The phantom number measures the minimum number of "perspectives" needed to reconstruct a topology. This suggests an information-theoretic interpretation: each observer carries partial information about the topology, and the phantom number measures the minimum information redundancy needed for exact reconstruction.

**Conjecture:** Define the *phantom entropy* of a topology τ as the infimum of H(P) over all phantom representations P, where H(P) = log₂(|O|) for a finite observer set O. Then for finite topological spaces, the phantom entropy equals log₂ of the width of the interval [τ, ⊥] in the topology lattice (i.e., the maximum number of pairwise incomparable topologies strictly between τ and discrete).

The key insight is that each observer in a phantom representation contributes an independent "direction" of refinement, and the number of such independent directions is bounded by the width of the refinement interval. This connects phantom topology to antichain theory in finite lattices, where the width equals the maximum antichain size by Dilworth's theorem.

**Why now?** Our formalization provides the first rigorous framework for studying phantom representations. Computing phantom entropy for small finite types (|X| ≤ 4) is feasible using Lean's `native_decide` or `Fintype.card` machinery, which would provide concrete data to test and refine the conjecture before attempting a general proof.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
