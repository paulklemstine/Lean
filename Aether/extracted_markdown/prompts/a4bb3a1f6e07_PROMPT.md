
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

**Title**: Extend the integration deficiency framework to a full Shannon entropy formalizat
**Domain**: Algebra
**Mathematical framing**: # Future Directions: Qualia Integration and Lattice-Theoretic Consciousness

## 1. Shannon Entropy on Finite Lattices

Extend the integration deficiency framework to a full Shannon entropy formalization
for finite probability distributions. Define `H(X) = -∑ p(x) log p(x)` for
distributions on finite types and prove the chain rule `H(X,Y) = H(X) + H(Y|X)`,
non-negativity, and the data processing inequality.

**The key insight is** that Mathlib's existing `Real.log` and `Finset.sum` API
provides the computational substrate, but the concavity proofs for the entropy
function require careful handling of the `0 * log 0 = 0` convention.

**Why now?** Shannon entropy is not yet formalized in Mathlib (as of v4.28.0).
A correct formalization would unlock formalization of IIT's Φ measure and
information-theoretic proofs across multiple domains. The `total_weight_bound`
theorem from this cycle provides the template for bounding entropy sums.

## 2. Constructive Knaster-Tarski with Convergence Rate Analysis

The `iterateBot_reaches_fixedPoint` theorem establishes convergence in at most
`card α` steps. Generalize this to lattices with a height function, proving
convergence in `height(L)` steps rather than `card(L)`. For distributive lattices,
this can be exponentially smaller.

**The key insight is** that the convergence rate depends on the longest chain in
the lattice, not its cardinality. A lattice of subsets of an n-element set has
`2^n` elements but height `n+1`, giving an exponential improvement.

**Why now?** The `mono_seq_stabilizes` pigeonhole argument generalizes directly
to chain-length arguments via `Set.Finite.chain_length_le`. This would connect
our observer fixed-point theory to computational complexity bounds for
iterative algorithms on lattices.

## 3. Metric Fixed Points for Contractive Observers

Extend the `Observer` framework from finite types to metric spaces. Prove that
a contractive observer (where `d(observe(s₁), observe(s₂)) ≤ k · d(s₁, s₂)`
for `k < 1`) has a unique fixed point, and that the trajectory converges to it
at geometric rate. This is Banach's fixed-point theorem applied to self-observation.

**The key insight is** that the observer trajectory in the metric case converges
to a unique "self-consistent state," unlike the finite case where the trajectory
merely cycles. This formalizes the philosophical distinction between
"oscillating awareness" and "stable consciousness."

**Why now?** Mathlib has `Contracting.efixedPoint` and related API. The
`observer_cycle_perpetuates` theorem from this cycle provides the structural
template; the metric version replaces pigeonhole with geometric convergence.

## 4. Zombie Separation: Internal Complexity Measures

The `zombie_theorem` shows that functionally equivalent systems can differ in
state space size. Strengthen this to show that for *any* computable internal
complexity measure `μ : Type* → ℕ`, there exist functionally equivalent systems
with arbitrarily different `μ` values. Concretely, conjecture: for any `n : ℕ`,
there exist functionally equivalent systems where one has integration `0` and the
other has integration `≥ n`.

**The key insight is** that the `state_space_inflation` theorem can be iterated
to produce systems with state spaces of any desired cardinality, all functionally
equivalent to the original. If `μ` is monotone in state space size (as natural
complexity measures are), this gives arbitrary separation.

**Why now?** The `state_space_inflation` proof gives the construction explicitly.
Formalizing the iteration requires showing that `(S × T₁) × T₂ ≃ S × (T₁ × T₂)`
preserves functional equivalence, which is a straightforward application of
`Equiv.prodAssoc`.

## 5. Partition Lattice Integration and IIT's Φ

Define the partition lattice `Part(n)` of a finite set `Fin n` using Mathlib's
`Setoid` or `Finpartition`. Define "integrated information" Φ(π) for a partition π
as the minimum over all bipartitions of the mutual information across the cut.
Prove that Φ is zero iff the system decomposes as independent parts, and that
the partition minimizing Φ (the "minimum information partition") exists by
compactness of the finite partition lattice.

**The key insight is** that Φ is a function from the finite lattice of partitions
to ℝ≥0, and the existence of its minimum is just `Finset.exists_min_image` applied
to the (finite) set of bipartitions. The hard part is defining mutual information;
see Direction 1.

**Why now?** This cycle's `integrationDeficiency` provides the Boolean version
(0 or 1). The full version requires Shannon entropy (Direction 1) but the
lattice-theoretic structure — minimum over bipartitions in a finite set — is
already formalizable with current Mathlib API.

**Concept description**: # Future Directions: Qualia Integration and Lattice-Theoretic Consciousness

## 1. Shannon Entropy on Finite Lattices

Extend the integration deficiency framework to a full Shannon entropy formalization
for finite probability distributions. Define `H(X) = -∑ p(x) log p(x)` for
distributions on finite types and prove the chain rule `H(X,Y) = H(X) + H(Y|X)`,
non-negativity, and the data processing inequality.

**The key insight is** that Mathlib's existing `Real.log` and `Finset.sum` API
provides the computational substrate, but the concavity proofs for the entropy
function require careful handling of the `0 * log 0 = 0` convention.

**Why now?** Shannon entropy is not yet formalized in Mathlib (as of v4.28.0).
A correct formalization would unlock formalization of IIT's Φ measure and
information-theoretic proofs across multiple domains. The `total_weight_bound`
theorem from this cycle provides the template for bounding entropy sums.

## 2. Constructive Knaster-Tarski with Convergence Rate Analysis

The `iterateBot_reaches_fixedPoint` theorem establishes convergence in at most
`card α` steps. Generalize this to lattices with a height function, proving
convergence in `height(L)` steps rather than `card(L)`. For distributive lattices,
this can be exponentially smaller.

**The key insight is** that the convergence rate depends on the longest chain in
the lattice, not its cardinality. A lattice of subsets of an n-element set has
`2^n` elements but height `n+1`, giving an exponential improvement.

**Why now?** The `mono_seq_stabilizes` pigeonhole argument generalizes directly
to chain-length arguments via `Set.Finite.chain_length_le`. This would connect
our observer fixed-point theory to computational complexity bounds for
iterative algorithms on lattices.

## 3. Metric Fixed Points for Contractive Observers

Extend the `Observer` framework from finite types to metric spaces. Prove that
a contractive observer (where `d(observe(s₁), observe(s₂)) ≤ k · d(s₁, s₂)`
for `k < 1`) has a unique fixed point, and that the trajectory converges to it
at geometric rate. This is Banach's fixed-point theorem applied to self-observation.

**The key insight is** that the observer trajectory in the metric case converges
to a unique "self-consistent state," unlike the finite case where the trajectory
merely cycles. This formalizes the philosophical distinction between
"oscillating awareness" and "stable consciousness."

**Why now?** Mathlib has `Contracting.efixedPoint` and related API. The
`observer_cycle_perpetuates` theorem from this cycle provides the structural
template; the metric version replaces pigeonhole with geometric convergence.

## 4. Zombie Separation: Internal Complexity Measures

The `zombie_theorem` shows that functionally equivalent systems can differ in
state space size. Strengthen this to show that for *any* computable internal
complexity measure `μ : Type* → ℕ`, there exist functionally equivalent systems
with arbitrarily different `μ` values. Concretely, conjecture: for any `n : ℕ`,
there exist functionally equivalent systems where one has integration `0` and the
other has integration `≥ n`.

**The key insight is** that the `state_space_inflation` theorem can be iterated
to produce systems with state spaces of any desired cardinality, all functionally
equivalent to the original. If `μ` is monotone in state space size (as natural
complexity measures are), this gives arbitrary separation.

**Why now?** The `state_space_inflation` proof gives the construction explicitly.
Formalizing the iteration requires showing that `(S × T₁) × T₂ ≃ S × (T₁ × T₂)`
preserves functional equivalence, which is a straightforward application of
`Equiv.prodAssoc`.

## 5. Partition Lattice Integration and IIT's Φ

Define the partition lattice `Part(n)` of a finite set `Fin n` using Mathlib's
`Setoid` or `Finpartition`. Define "integrated information" Φ(π) for a partition π
as the minimum over all bipartitions of the mutual information across the cut.
Prove that Φ is zero iff the system decomposes as independent parts, and that
the partition minimizing Φ (the "minimum information partition") exists by
compactness of the finite partition lattice.

**The key insight is** that Φ is a function from the finite lattice of partitions
to ℝ≥0, and the existence of its minimum is just `Finset.exists_min_image` applied
to the (finite) set of bipartitions. The hard part is defining mutual information;
see Direction 1.

**Why now?** This cycle's `integrationDeficiency` provides the Boolean version
(0 or 1). The full version requires Shannon entropy (Direction 1) but the
lattice-theoretic structure — minimum over bipartitions in a finite set — is
already formalizable with current Mathlib API.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Algebra
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
