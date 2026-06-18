# Closure-Growth Separation: A Formally Verified Foundation for Neural Proof Mining

## Abstract

We present a formally verified mathematical framework for distinguishing proof-search
policies based on the growth dynamics of their iterated closures. Starting from abstract
definitions of preclosure operators (monotone + extensive set transformers) and closure
operators (additionally idempotent), we develop a theory of **closure filtrations** and
prove that any divergence between two policies' filtrations produces a **finite
distinguishing witness** — a concrete proof state reachable by one policy but not the
other. All theorems are machine-verified in Lean 4 with Mathlib, and instantiated for the
EML (Exponential-Minus-Log) closure from computational density theory. The framework
provides the mathematical grammar for thermodynamic proof complexity and trainable policy
separation.

## 1. Introduction

### 1.1 Motivation

Neural theorem provers learn proof-search strategies from data, but the fundamental
question remains: **when are two proof strategies provably different?** If two neural
policies explore the same proof states in the same order, they are indistinguishable for
training purposes. But if one policy can reach a proof state that the other cannot —
within finitely many steps — then that state becomes a **training signal**: a concrete
example where the policies diverge.

This paper formalizes this intuition precisely. We model each proof-search policy as a
**set transformer** `F : Set α → Set α` that takes a set of currently reachable proof
states and expands it by one step of search. The **closure filtration**

$$S = F^{[0]}(S) \subseteq F^{[1]}(S) \subseteq F^{[2]}(S) \subseteq \cdots$$

captures the cumulative reach of the policy from seed set `S`. Two policies are
**separable** when their filtrations diverge at some finite stage.

### 1.2 Contributions

1. **Formal definitions** of `SetMono`, `IsPreclosureOp`, `IsClosureOp`, and `closureIter`
   as a reusable Lean 4 library for closure dynamics on sets.

2. **Stabilization theorem** (`closureIter_stabilizes`): idempotent closure operators
   reach equilibrium in one step, so `C^{[n+1]}(S) = C(S)` for all `n`. This means
   "entropy rate is zero" for genuine closure operators.

3. **Finite witness extraction** (`finite_witness_of_stage_separation`): if the
   `F`-filtration is not contained in the `G`-filtration at any stage, there exists a
   concrete element `x` and stage `n` witnessing the separation.

4. **Entropy-rate separation** (`finite_witness_of_eventual_growth_gap`): if `G` is
   eventually strictly contained in `F` at every stage, a finite witness exists.

5. **Fixed-point invariance** (`closure_fixed_points_are_iterative_invariants`): fixed
   points of closure operators are stable under all iterates.

6. **EML instantiation**: the full EML closure is proved to be a genuine closure operator
   (extensive, monotone, idempotent), connecting the abstract theory to concrete
   computational semantics.

## 2. Mathematical Framework

### 2.1 Preclosure and Closure Operators

Let `α` be a type of proof states. A **set transformer** is a function `C : Set α → Set α`.

**Definition 1** (SetMono). `C` is *monotone* if `S ⊆ T` implies `C(S) ⊆ C(T)`.

**Definition 2** (IsPreclosureOp). `F` is a *preclosure operator* if:
- (Extensive) `S ⊆ F(S)` for all `S`, and
- (Monotone) `F` is monotone.

**Definition 3** (IsClosureOp). `C` is a *closure operator* if it is a preclosure
operator and additionally:
- (Idempotent) `C(C(S)) = C(S)` for all `S`.

The distinction between preclosure and closure is the heart of the theory:
- **Preclosure operators** model single-step policy expansions. They can grow the
  reachable set indefinitely.
- **Closure operators** model semantic saturation. Once the closure is applied, further
  applications add nothing.

### 2.2 Closure Iteration

**Definition 4** (closureIter). The `n`-fold iterate of `C` is defined by
`closureIter C n = C^[n]`, using `Nat.iterate`.

**Theorem 1** (closureIter_mono). If `C` is monotone, then `C^{[n]}` is monotone for all `n`.

*Proof.* By induction on `n`. The base case is trivial. For the step,
`C^{[n+1]}(S) = C(C^{[n]}(S)) ⊆ C(C^{[n]}(T))` by monotonicity of `C` and the
inductive hypothesis. ∎

**Theorem 2** (subset_closureIter_succ). For a preclosure operator `F`,
the filtration is increasing: `F^{[n]}(S) ⊆ F^{[n+1]}(S)`.

*Proof.* By induction on `n`, using extensivity at the base and monotonicity at the step. ∎

### 2.3 Stabilization

**Theorem 3** (closureIter_stabilizes). For a closure operator `C`,
`C^{[n+1]}(S) = C(S)` for all `n ≥ 0`.

*Proof.* By induction on `n`. Base: `C^{[1]}(S) = C(S)`. Step:
`C^{[n+2]}(S) = C(C^{[n+1]}(S)) = C(C(S)) = C(S)` by the inductive hypothesis
and idempotence. ∎

This theorem has a striking interpretation: **for a genuine closure operator, all the
"action" happens in the first step.** The closure filtration collapses immediately.
Any nontrivial growth must come from a preclosure operator — one that is not yet
idempotent.

### 2.4 Witness Extraction

**Theorem 4** (finite_witness_of_stage_separation). Let `F`, `G` be preclosure operators.
If there exists `n` such that `F^{[n]}(S) ⊄ G^{[n]}(S)`, then there exist `n` and `x`
with `x ∈ F^{[n]}(S)` and `x ∉ G^{[n]}(S)`.

*Proof.* Immediate from the definition of non-subset: `A ⊄ B` iff `∃ x, x ∈ A ∧ x ∉ B`. ∎

While elementary, this theorem is the exact formal extraction principle needed for
neural proof mining. The witness `x` is a **concrete training example** that
distinguishes the two policies.

**Theorem 5** (finite_witness_of_eventual_growth_gap). If `G^{[n]}(S) ⊂ F^{[n]}(S)`
for all sufficiently large `n` (the policies exhibit an eventual growth gap), then a
finite separating witness exists.

*Proof.* From the eventual strict inclusion at the threshold `N`, extract a witness
from `F^{[N]}(S) \setminus G^{[N]}(S)` using `Set.exists_of_ssubset`. ∎

### 2.5 Fixed-Point Invariance

**Theorem 6** (closure_fixed_points_are_iterative_invariants). If `C(S) = S` for a
closure operator `C`, then `C^{[n]}(S) = S` for all `n`.

*Proof.* By induction: `C^{[n+1]}(S) = C(C^{[n]}(S)) = C(S) = S`. ∎

This says: **a proof strategy that is already closed under the semantic operator is
permanently stable.** It cannot be improved or degraded by further closure applications.
In machine learning terms, a fixed point is an invariant policy that has "converged."

## 3. EML Closure Instantiation

### 3.1 The EML Operation

The EML (Exponential-Minus-Log) operation is defined by:

$$\text{EMLd}(a, b) = e^a - \ln b$$

This operation arises in computational density theory as a fundamental building block
for compositional transformations.

### 3.2 Depth-Indexed Closure

The EML closure at depth `n` starts from a seed set `S` and iteratively adjoins all
values obtainable by applying EMLd to pairs of existing elements:

- `EMLClosure'(0, S) = S`
- `EMLClosure'(n+1, S) = EMLClosure'(n, S) ∪ {EMLd(a,b) | a, b ∈ EMLClosure'(n, S)}`

The full closure is `fullEMLClosure'(S) = ⋃_n EMLClosure'(n, S)`.

### 3.3 Closure Properties

**Theorem 7** (fullEMLClosure'_isClosureOp). `fullEMLClosure'` is a closure operator.

The proof requires establishing three properties:
1. **Extensivity**: `S ⊆ fullEMLClosure'(S)` — immediate since `EMLClosure'(0, S) = S`.
2. **Monotonicity**: if `S ⊆ T` then `fullEMLClosure'(S) ⊆ fullEMLClosure'(T)` —
   by induction on depth, using monotonicity of EMLClosure' in the seed set.
3. **Idempotence**: `fullEMLClosure'(fullEMLClosure'(S)) = fullEMLClosure'(S)` — the key
   lemma shows that `EMLClosure'(n, fullEMLClosure'(S)) ⊆ fullEMLClosure'(S)` by
   induction: if `a, b ∈ fullEMLClosure'(S)`, they come from finite depths `m₁, m₂`,
   so `EMLd(a,b) ∈ EMLClosure'(max(m₁,m₂) + 1, S) ⊆ fullEMLClosure'(S)`.

### 3.4 Consequences

From the abstract theory, we immediately derive:

- **fullEMLClosure'_iter_stabilizes**: `closureIter fullEMLClosure' (n+1) S = fullEMLClosure' S`
- **fullEMLClosure'_fixed_iterative_invariant**: if `fullEMLClosure' S = S` then
  `closureIter fullEMLClosure' n S = S` for all `n`

## 4. Applications

### 4.1 Curriculum Generation for Neural Theorem Provers

The finite witness theorem provides an algorithmic recipe for generating training data:

1. **Define** two proof-search policies as preclosure operators `F` and `G`.
2. **Iterate** both from a common seed set of proof states.
3. **Extract** a witness `x` at the first stage where the filtrations diverge.
4. **Train** the weaker policy to reach `x`, using the stronger policy's trajectory as a demonstration.

This is exactly the **counterexample-guided training** paradigm, but now with a formal
mathematical guarantee that the witness exists whenever the policies are genuinely
different.

### 4.2 Benchmark Generation

The separation theorem also generates benchmarks: given a collection of policies, the
pairwise witnesses form a **distinguishing test suite**. A policy that passes all tests
in the suite is at least as powerful as all the policies in the collection.

### 4.3 Proof Complexity Classes

The growth rate of the closure filtration defines a natural complexity measure:
- **Constant growth** (closure operators): problems solvable by semantic saturation.
- **Linear growth**: problems requiring step-by-step exploration.
- **Exponential growth**: problems requiring deep combinatorial search.

This gives a formal framework for classifying theorem-proving difficulty by the
closure-growth complexity of the required policy.

## 5. Discussion: Making Thermodynamics Precise

### For a General Audience

Imagine you're exploring a maze. At each step, you can see new rooms. A "preclosure
operator" is like an exploration strategy: from the rooms you've seen, it shows you which
new rooms you can reach next. The **closure filtration** is the expanding map of all rooms
you've discovered after 1 step, 2 steps, 3 steps, and so on.

Now imagine two explorers with different strategies. Our main theorem says: **if one
explorer eventually sees strictly more of the maze than the other, there must be a
specific room — a concrete, identifiable location — that one explorer can find but the
other cannot.** This room is the "witness" of their difference.

For AI systems that prove mathematical theorems, this is powerful. It means that whenever
two proof-search strategies are genuinely different, we can extract a concrete example
that demonstrates the difference. That example becomes a training signal: "here's a proof
state your strategy misses — learn to reach it."

The "thermodynamic" language comes from an analogy with physics. In thermodynamics,
entropy measures how much disorder (or information) a system has. The "entropy rate" of
a closure filtration measures how fast new proof states are discovered. A genuine closure
operator has zero entropy rate — it reaches equilibrium instantly. Any real growth must
come from a preclosure operator that hasn't yet saturated. This is the formal version of
the intuition that "learning happens in the transient phase, not at equilibrium."

### Connection to Existing Work

The theory of closure operators has a long history in mathematics, from Kuratowski's
axioms in topology (1922) to the extensive work in lattice theory, formal concept
analysis, and abstract interpretation. Our contribution is not the closure operator
concept itself, but its application to **proof-search policy comparison** with a focus
on extracting finite, actionable witnesses.

The connection to Lawvere's enriched category theory is aspirational: in future work,
we aim to equip the space of proof states with a generalized metric (a Lawvere metric)
and study non-expansive closure operators, connecting to the theory of fixed points
in enriched categories.

## 6. Formal Verification

All theorems in this paper are machine-verified in Lean 4 (v4.28.0) with Mathlib.
The formalization consists of approximately 320 lines of Lean code, organized as:

1. **Abstract theory** (~170 lines): definitions and theorems about `SetMono`,
   `IsPreclosureOp`, `IsClosureOp`, `closureIter`, witness extraction, and fixed-point
   invariance. This is completely independent of the EML instantiation.

2. **EML instantiation** (~120 lines): definitions of `EMLd'`, `EMLClosure'`, and
   `fullEMLClosure'`, with proofs that `fullEMLClosure'` is a genuine closure operator.

The formalization uses only standard axioms (`propext`, `Classical.choice`, `Quot.sound`)
and contains no `sorry` statements.

## 7. Conclusion

We have established a formally verified mathematical framework for separating
proof-search policies based on closure-growth dynamics. The key results are:

- Idempotent closure operators stabilize immediately (zero entropy rate).
- Any filtration divergence yields a finite separating witness.
- The EML closure is a genuine closure operator, connecting abstract theory to
  computational semantics.

These results provide the mathematical foundation for a new approach to neural proof
mining: using closure-growth analysis to generate training curricula, benchmarks, and
complexity classifications for automated theorem proving.

## References

1. K. Kuratowski, "Sur l'opération Ā de l'Analysis Situs," *Fundamenta Mathematicae*,
   vol. 3, pp. 182–199, 1922.

2. F. W. Lawvere, "Metric spaces, generalized logic, and closed categories,"
   *Rendiconti del Seminario Matematico e Fisico di Milano*, vol. 43, pp. 135–166, 1973.

3. B. A. Davey and H. A. Priestley, *Introduction to Lattices and Order*, 2nd ed.,
   Cambridge University Press, 2002.

4. P. Cousot and R. Cousot, "Abstract interpretation: a unified lattice model for static
   analysis of programs by construction or approximation of fixpoints," *POPL*, 1977.
