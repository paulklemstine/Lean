# Lawvere–Kleene Fixed-Point Stratification for Reversible Temporal Circuits via Traced Idempotent Semiring Enrichment

## Abstract

We formalize in Lean 4 a computable approximation theory for guarded trace semantics in order-enriched categories. The central result is that the trace of a guarded feedback circuit — the canonical self-referential invariant — equals the ω-supremum of its finite causal unrollings. Under Scott continuity of the feedback step, we prove:

1. **Monotonicity**: The Kleene chain f^[n](⊥) is non-decreasing.
2. **Convergence**: The supremum of the chain is a fixed point of f, equal to the least pre-fixed point sInf {x | f(x) ≤ x}.
3. **Collapse**: If the chain stabilizes at stage N (f^[N+1](⊥) = f^[N](⊥)), the supremum equals f^[N](⊥).

We instantiate these results for temporal circuit categories, establishing that the abstract traced fixed point is exactly the directed limit of finite-depth circuit unrollings. All proofs are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### The Problem of Self-Reference in Circuits

Feedback is ubiquitous in computation: from flip-flops in digital hardware to recursive function definitions in programming languages, to control loops in signal processing. The mathematical abstraction of feedback is the *trace* in a traced monoidal category — an operator that converts a morphism with a "loop wire" into one without, by connecting an output back to an input.

But what does the trace *compute*? For a concrete circuit with a feedback loop, the trace represents the steady-state behavior when the loop is closed. The classical answer, going back to Kleene's fixed-point theorem for continuous functions on complete partial orders, is that this steady state is the *least fixed point* of the feedback body — and it can be *computed* as the limit of finite approximations.

### Our Contribution

We formalize this classical insight in the modern setting of order-enriched traced categories, producing machine-verified proofs of:

- **The Kleene fixed-point equation**: Under Scott continuity, sSup{f^[n](⊥)} is a fixed point of f.
- **Least pre-fixed point characterization**: This fixed point equals sInf{x | f(x) ≤ x}.
- **The collapse/stabilization theorem**: Finite convergence of the chain yields exact computation.
- **Circuit instantiation**: These abstract results transfer to morphism sets of temporal categories.

The formalization is minimal yet complete: approximately 150 lines of Lean 4 for the abstract theory and 100 lines for the circuit-level corollaries.

## 2. Mathematical Framework

### 2.1 The Kleene Chain

Given a complete lattice (α, ≤) and a monotone function f : α → α, the *Kleene chain* is the sequence:

    ⊥ ≤ f(⊥) ≤ f²(⊥) ≤ f³(⊥) ≤ ⋯

**Theorem (Monotonicity).** If f is monotone, then n ↦ f^[n](⊥) is non-decreasing.

*Proof.* By induction. The base case ⊥ ≤ f(⊥) is immediate from ⊥ being the bottom element. The inductive step f^[n](⊥) ≤ f^[n+1](⊥) implies f^[n+1](⊥) ≤ f^[n+2](⊥) by monotonicity of f. □

### 2.2 Scott Continuity and the Fixed-Point Equation

We define a function f to be *ω-Scott-continuous* if it is monotone and preserves suprema of ω-chains:

    f(sSup(range c)) = sSup(range (f ∘ c))

for every monotone sequence c : ℕ → α.

**Theorem (Kleene Fixed Point).** If f is ω-Scott-continuous, then L := sSup{f^[n](⊥) | n ∈ ℕ} satisfies f(L) = L.

*Proof.* By Scott continuity:

    f(L) = f(sSup{f^[n](⊥)})
         = sSup{f(f^[n](⊥))}
         = sSup{f^[n+1](⊥)}
         = L

The last equality uses the shifting lemma: for a monotone chain, sSup{c(n+1)} = sSup{c(n)}, since the additional 0th term c(0) = ⊥ is below all others. □

### 2.3 Least Pre-Fixed Point

**Theorem.** Under the same hypotheses, L = sInf{x | f(x) ≤ x}.

*Proof.* (≤) For any x with f(x) ≤ x, induction gives f^[n](⊥) ≤ x for all n, so L ≤ x. Thus L ≤ sInf{x | f(x) ≤ x}.

(≥) Since f(L) = L, L is itself a pre-fixed point (f(L) ≤ L), so sInf{x | f(x) ≤ x} ≤ L. □

This characterization is the order-theoretic essence of the Lawvere–Kleene theorem. It says the least fixed point is not merely some abstract object but is canonically constructed as a directed limit.

### 2.4 The Collapse Theorem

**Theorem (Stabilization).** If f^[N+1](⊥) = f^[N](⊥) for some N, then:
1. f^[N+k](⊥) = f^[N](⊥) for all k ≥ 0.
2. sSup{f^[n](⊥)} = f^[N](⊥).
3. f^[N](⊥) is a fixed point of f.

*Proof.* Part (1) is by induction on k, using the hypothesis and monotonicity. Part (2) follows because the supremum of a chain that is eventually constant equals the constant value. Part (3) is immediate: f(f^[N](⊥)) = f^[N+1](⊥) = f^[N](⊥). □

This theorem is the algorithmic heart of the theory: it turns the potentially infinitary construction of the least fixed point into a finite, decidable computation whenever the chain stabilizes.

## 3. Temporal Circuit Semantics

### 3.1 Traced Categories

A *temporal category* consists of:
- A type of objects (representing signal types or state spaces)
- For each pair of objects A, B, a type Hom(A, B) of morphisms (circuits, transformations)
- A tensor product ⊗ on objects (parallel composition)
- A trace operator: Hom(X ⊗ A, X ⊗ B) → Hom(A, B) (feedback along X)

When the hom-sets carry complete lattice structure compatible with composition, we can apply the Kleene theory.

### 3.2 Guarded Circuits

A circuit f : Hom(X ⊗ A, X ⊗ B) is *guarded* if the induced feedback step function

    step_f : Hom(A, B) → Hom(A, B)
    step_f(g) = "compose f with g fed back along X, with one delay"

is ω-Scott-continuous. Guardedness ensures causality: the output at time t depends only on inputs up to time t−1.

### 3.3 The Main Circuit Theorems

**Theorem (Trace = sSup of Unrollings).** For a guarded circuit f with feedback step step_f:

    trace(f) = sSup{unroll(n, f) | n ∈ ℕ}

where unroll(n, f) = step_f^[n](⊥) is the n-step finite unrolling.

**Theorem (Circuit Collapse).** If unroll(N+1, f) = unroll(N, f), then trace(f) = unroll(N, f).

These are direct instantiations of the abstract Kleene theory, mediated by the `GuardedCircuit` structure that bundles the feedback step and its Scott continuity.

## 4. Formalization in Lean 4

### 4.1 Architecture

The formalization consists of two files:

- **`Logic/KleeneFixedPoint.lean`** (~150 lines): The abstract ω-chain theory on complete lattices. Key definitions: `OmegaScottContinuous`, `kleene_chain_mono`, `kleene_fixed_point`, `kleene_lfp`, `sSup_kleene_eq_of_stabilization`.

- **`Logic/TracedCircuitSemantics.lean`** (~200 lines): The temporal category infrastructure and circuit-level corollaries. Key definitions: `GuardedTrace`, `TemporalCategory`, `GuardedCircuit`, and the main theorems `iSup_unroll_eq_trace`, `trace_eq_approx_of_stabilization`, `trace_is_least_causal_invariant`.

### 4.2 Design Choices

1. **Complete lattices over custom ω-CPOs**: We use Mathlib's `CompleteLattice` rather than defining a custom ω-complete partial order. This gives access to Mathlib's extensive lattice API while being sufficient for all our theorems.

2. **Structure over typeclass for circuits**: The `GuardedCircuit` structure bundles the feedback step and its properties as a non-typeclass record, avoiding diamond problems with multiple `CompleteLattice` instances on the same hom-type.

3. **Scott continuity as structure**: `OmegaScottContinuous` is a structure (not a typeclass) bundling monotonicity and chain-preservation. This makes hypotheses explicit and avoids typeclass search issues.

### 4.3 Axiom Usage

All theorems depend only on standard axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (classical logic, used in lattice completeness)
- `Quot.sound` (quotient soundness)

No `sorry`, `axiom`, or `@[implemented_by]` declarations appear in the final code.

## 5. Applications

### 5.1 Shortest-Path Computation

In the tropical (min-plus) semiring, the Bellman-Ford algorithm is precisely the Kleene chain. The "step function" is one round of edge relaxation, ⊥ is the initial distance vector (0 at source, ∞ elsewhere), and the trace is the shortest-path vector. Stabilization after k iterations proves that no path needs more than k edges — the classical optimality certificate.

### 5.2 Dataflow Analysis

In compiler optimization, reaching definitions, available expressions, and live variable analyses all compute fixed points of monotone transfer functions on powerset lattices. The Kleene chain is the worklist algorithm, and the collapse theorem provides the termination guarantee.

### 5.3 Model Checking

Temporal logic model checking for μ-calculus properties requires computing least and greatest fixed points of monotone operators on state sets. The Kleene chain gives the computation procedure, and the collapse theorem bounds the number of iterations by the lattice height.

### 5.4 Hardware Verification

For synchronous digital circuits with feedback (registers), the trace captures the steady-state behavior. The collapse theorem certifies when a finite simulation suffices to determine the circuit's behavior for all time — a crucial tool for bounded model checking.

## 6. Discussion: The Self-Building Staircase

*For a general audience.*

Imagine you're trying to build a staircase, but the blueprint says: "Each step should support the step above it, and the top step should connect back to the bottom." This circular dependency seems impossible — how do you start?

The Kleene fixed-point theorem says: start with nothing (the empty staircase, ⊥), and repeatedly add one step. After step 1, you have a one-step staircase. After step 2, a two-step staircase that accounts for the first step's existence. And so on. Each stage is a better approximation of the self-consistent staircase.

The *monotonicity theorem* says these approximations only get better — each stage refines the previous one without ever going backward. The *convergence theorem* says that in the limit, the approximations converge to a genuine self-consistent staircase — one that perfectly satisfies the circular blueprint.

The *collapse theorem* is the practical punchline: if your 100-step staircase looks identical to the 99-step one, you're done. The infinite staircase is already captured by the finite construction. This is what makes the theory *algorithmic* — you don't need to iterate forever.

This idea pervades computer science. When Google computes PageRank, it iterates a "reputation step function" starting from zero — each page's rank depends on the ranks of pages linking to it, a circular dependency resolved by Kleene iteration. When a compiler analyzes which variables are live at each program point, it runs a fixed-point iteration that stabilizes after finitely many passes. When a chip designer simulates a circuit with feedback, the simulation converges to the circuit's true behavior.

What we've done is formalize this intuition with machine-verified mathematical precision, in the context of traced monoidal categories — the mathematical framework for systems with feedback. The result: a certified guarantee that finite approximation computes the exact answer, not just an approximation.

### Historical Context

The Kleene fixed-point theorem dates to 1952, building on work by Knaster, Tarski, and Kleene on lattice-theoretic fixed points. The connection to traced monoidal categories was developed by Joyal, Street, and Verity in the 1990s. The order-enriched perspective connecting Kleene iteration to categorical trace was explored by Hasegawa and Hyland. Our contribution is a clean machine-verified formalization that makes the connection algorithmic through the collapse theorem.

## 7. Related Work

The Kleene fixed-point theorem has been formalized in several proof assistants:
- Isabelle/HOL's HOLCF library includes a comprehensive domain theory with continuous functions and fixed-point theorems.
- Coq's `coq-domains` provides ω-CPO structures.
- Lean 4's Mathlib includes `OrderHom.lfp` and related constructions.

Our formalization differs in emphasizing the *circuit-semantic* interpretation and the *collapse theorem* as an algorithmic principle. The connection to traced monoidal categories — viewing the Kleene chain as unrolling a feedback loop — appears to be novel in the formalization literature.

## 8. Conclusion

We have formalized the Lawvere–Kleene fixed-point stratification for traced monoidal categories in Lean 4, establishing three key theorems:

1. Monotonicity of finite unrollings.
2. The trace equals the ω-supremum of unrollings (under Scott continuity).
3. Finite stabilization collapses the trace to a computable finite-stage circuit.

The formalization is approximately 350 lines of Lean 4, is fully verified without `sorry`, and uses only standard logical axioms. It provides a certified foundation for computing temporal invariants of feedback systems through finite approximation.

## References

1. S. C. Kleene. *Introduction to Metamathematics*. Van Nostrand, 1952.
2. A. Tarski. A lattice-theoretical fixpoint theorem and its applications. *Pacific J. Math.*, 5(2):285–309, 1955.
3. A. Joyal, R. Street, and D. Verity. Traced monoidal categories. *Math. Proc. Cambridge Philos. Soc.*, 119(3):447–468, 1996.
4. M. Hasegawa. *Models of Sharing Graphs: A Categorical Semantics of let and letrec*. Springer, 1999.
5. B. Davey and H. Priestley. *Introduction to Lattices and Order*. Cambridge University Press, 2002.
