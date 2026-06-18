# Tropical Renormalization of Theorem Space: Universality Classes via Depth-Graded Flows

## Abstract

We develop a mathematical framework for studying the macroscopic organization of formal proof structures through renormalization group methods adapted from statistical physics. Working in the setting of *closure flows* — types equipped with commuting closure and step operators — we introduce *depth-graded flows*, where a natural number-valued depth function is non-increasing under the step map. Our main results are:

1. **Strict Depth Convergence**: In any contractive depth-graded flow (where non-fixed points strictly decrease in depth), every element stabilizes within `depth(x)` steps.

2. **The Merging Principle**: Flow morphisms — the natural categorical morphisms of closure flows — map universality classes into universality classes. Surjective morphisms (coarse-grainings) can only merge classes, never split them.

3. **Spectral Monotonicity**: The spectral width (maximum depth) of a finite flow cannot increase under surjective depth-non-increasing morphisms.

4. **Tropical Classification**: In the concrete tropical depth flow on ℕ × ℕ with step `(d, r) ↦ (d-1, r)`, universality classes are completely classified by the second coordinate (type label). Depth is the irrelevant coordinate washed out by renormalization.

5. **Fixed-Point Universality**: In contractive flows, asymptotic congruence is equivalent to having a common iterate, establishing that fixed points of the flow completely determine the universality class structure.

All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: renormalization group, universality classes, tropical algebra, closure flows, proof complexity, categorical dynamics

---

## 1. Introduction

### 1.1 Motivation

The renormalization group (RG) is one of the most powerful conceptual tools in theoretical physics, providing a systematic framework for understanding how macroscopic behavior emerges from microscopic interactions. The central insight — that coarse-graining a system reveals which details are relevant and which are not — has applications far beyond its origins in quantum field theory and statistical mechanics.

In this paper, we apply renormalization group ideas to the study of formal mathematical proofs. The key observation is that proofs possess a natural notion of scale: their *depth*, defined as the length of the longest chain of logical dependencies from axioms to conclusion. Coarse-graining operations — which collapse layers of intermediate lemmas — reduce depth while preserving higher-level logical structure.

### 1.2 Related Work

The connection between renormalization and logical/computational structures has been explored from several angles:

- **Closure operators in lattice theory** provide the algebraic foundation for our framework. The connection between closure operators and Galois connections is classical.
- **Tropical (max-plus) algebra** provides the natural arithmetic for depth-based complexity measures, as depth satisfies max-plus composition rules.
- **Proof complexity theory** studies the resources required for formal proofs, but typically focuses on lower bounds rather than structural classification.

### 1.3 Contributions

Our main contributions are:
- A formal categorical framework (closure flows, flow morphisms) suitable for studying renormalization of proof structures
- Quantitative convergence results (strict depth convergence) with explicit bounds
- A complete classification theorem for a concrete tropical model
- Machine-verified proofs of all results in Lean 4

---

## 2. Definitions

### 2.1 Closure Flows

**Definition 2.1** (Closure Flow). A *closure flow* on a type α consists of two operations `cl, step : α → α` satisfying the commutativity condition `step(cl(x)) = cl(step(x))` for all x.

The *cl* operation models "taking the observable content" of a proof (its external interface), while *step* models one level of coarse-graining.

**Definition 2.2** (Iterate). The iterate `cfIterate(n, x)` is defined recursively:
- `cfIterate(0, x) = x`
- `cfIterate(n+1, x) = step(cfIterate(n, x))`

**Definition 2.3** (Asymptotic Congruence). Elements x, y are *asymptotically congruent* (`ACong x y`) if there exists N such that `cfIterate(n, x) = cfIterate(n, y)` for all n ≥ N.

**Proposition 2.4**. Asymptotic congruence is an equivalence relation. ∎

**Definition 2.5** (Universality Class). The universality class of x is the set `{y | ACong x y}`.

**Definition 2.6** (Stabilization). An element x *stabilizes at step N* if `cfIterate(n+1, x) = cfIterate(n, x)` for all n ≥ N.

### 2.2 Depth-Graded Flows

**Definition 2.7** (Depth-Graded Flow). A *depth-graded closure flow* is a closure flow equipped with a function `depth : α → ℕ` such that:
- `depth(step(x)) ≤ depth(x)` for all x
- `depth(cl(x)) ≤ depth(x)` for all x

**Lemma 2.8** (Depth Monotonicity). `depth(cfIterate(n, x)) ≤ depth(x)` for all n.

*Proof.* Immediate induction using `step_depth_le`. ∎

### 2.3 Flow Morphisms

**Definition 2.9** (Flow Morphism). A *flow morphism* `f : α → β` between closure flows satisfies:
- `f(step(x)) = step(f(x))` for all x
- `f(cl(x)) = cl(f(x))` for all x

**Proposition 2.10**. Flow morphisms form a category with composition and identity.

**Definition 2.11** (Coarse-Graining). A *coarse-graining* is a surjective flow morphism.

### 2.4 Contractivity

**Definition 2.12** (Contractive Flow). A depth-graded flow is *contractive* if `depth(step(x)) < depth(x)` whenever `step(x) ≠ x`.

---

## 3. Main Results

### 3.1 Strict Depth Convergence

**Theorem 3.1** (Strict Depth Convergence). In a contractive depth-graded flow, every element x stabilizes within `depth(x)` steps.

*Proof sketch.* By induction on depth. If `depth(x) = 0`, then step cannot strictly decrease depth, so x must be a fixed point. If `depth(x) = k + 1`, either x is already a fixed point (and stabilizes immediately), or `depth(step(x)) ≤ k`, and by the induction hypothesis, `step(x)` stabilizes within k steps, so x stabilizes within k + 1 steps. ∎

**Corollary 3.2.** In a contractive flow, every element reaches a fixed point.

### 3.2 The Merging Principle

**Theorem 3.3** (Preservation of ACong). If f is a flow morphism and `ACong x y`, then `ACong (f(x)) (f(y))`.

*Proof sketch.* The key step is that `f(cfIterate(n, x)) = cfIterate(n, f(x))` (preservation of iteration), which follows by induction using the step-intertwining property. Then `cfIterate(n, x) = cfIterate(n, y)` implies `cfIterate(n, f(x)) = cfIterate(n, f(y))`. ∎

**Theorem 3.4** (Merging Principle). For any flow morphism f and element x, `f(univClass(x)) ⊆ univClass(f(x))`.

*Proof.* Direct consequence of Theorem 3.3. ∎

**Theorem 3.5** (Surjective Class Cover). For any surjective flow morphism f and target element b, there exists a preimage a with `f(a) = b` and `f(univClass(a)) ⊆ univClass(b)`.

### 3.3 Spectral Monotonicity

**Theorem 3.6** (Spectral Monotonicity). If f : α → β is a surjective flow morphism between finite depth-graded flows with `depth(f(x)) ≤ depth(x)` for all x, then `spectralWidth(β) ≤ spectralWidth(α)`.

*Proof sketch.* The spectral width of β is the maximum of `depth(b)` over b ∈ β. For each b, pick a preimage a with `f(a) = b`. Then `depth(b) = depth(f(a)) ≤ depth(a) ≤ spectralWidth(α)`. ∎

### 3.4 Tropical Classification

**Theorem 3.7** (Tropical Iterate Formula). In the tropical depth flow on ℕ × ℕ with `step(d, r) = (d - 1, r)`, we have `cfIterate(n, (d, r)) = (d - n, r)` where subtraction is truncating.

**Theorem 3.8** (Tropical Stabilization). Elements with depth d stabilize by step d.

**Theorem 3.9** (Tropical Classification). `ACong((d₁, r₁), (d₂, r₂))` if and only if `r₁ = r₂`.

*Proof sketch.* Forward: for large n, `(d₁ - n, r₁) = (d₂ - n, r₂)` implies `r₁ = r₂` from the second coordinate. Backward: if `r₁ = r₂`, take `N = max(d₁, d₂)`; for n ≥ N, both first coordinates are 0. ∎

### 3.5 Fixed-Point Universality

**Theorem 3.10** (Fixed-Point Determines Class). In a contractive flow, `ACong x y` if and only if there exists N with `cfIterate(N, x) = cfIterate(N, y)`.

*Proof sketch.* Forward direction: take N from the definition of ACong. Backward: given `cfIterate(N, x) = cfIterate(N, y)`, induction on n ≥ N using `cfIterate_add` shows all subsequent iterates agree. ∎

---

## 4. The Tropical Depth Model in Detail

### 4.1 Physical Interpretation

The tropical depth flow provides a concrete model of proof renormalization. A pair `(d, r)` represents a proof with:
- `d`: proof depth (number of layers of logical dependency)
- `r`: type label (structural invariant — e.g., algebraic, topological, combinatorial)

The step function `(d, r) ↦ (d - 1, r)` models collapsing the outermost layer of the proof. After d steps, the depth reaches zero and the proof has been fully coarsened to its essential type.

### 4.2 Connection to Tropical Algebra

The depth function satisfies max-plus properties. When composing proofs (combining a proof of depth d₁ with one of depth d₂ to produce a proof of depth max(d₁, d₂) + 1), the depth behaves tropically: it respects the max-plus semiring structure. This connects the renormalization framework to tropical spectral theory, where the maximum cycle mean governs asymptotic growth rates — just as the type label governs the asymptotic universality class.

### 4.3 Universality Classes

The classification theorem (Theorem 3.9) reveals that the tropical depth flow has exactly as many universality classes as there are type labels. This gives a precise sense in which "proof complexity" (measured by depth) is irrelevant to the fundamental classification of proofs — only the structural type matters.

---

## 5. Algorithms

### 5.1 Computing Universality Classes

Given a finite contractive flow (a finite set with a step function satisfying the contractivity condition), the universality classes can be computed by:

1. For each element x, iterate step until reaching a fixed point.
2. Two elements are in the same class iff they reach the same fixed point.

This runs in O(n · D) time where n is the number of elements and D is the maximum depth.

### 5.2 Computing the Depth Spectrum

The depth spectrum of a finite flow is computed by evaluating the depth function on all elements and sorting. This is O(n log n).

---

## 6. Conjecture: Spectral Rigidity

**Conjecture 6.1** (Spectral Rigidity). For contractive flows on Fin(n) with the same depth multiset, the number of fixed points (= universality classes) is the same.

**Computational Test**: Enumerate all contractive step functions on Fin(4) with depth d(i) = i. For each pair of such functions with the same depth spectrum, check whether they have the same number of fixed points.

**Status**: Open. The conjecture has a simple but non-obvious structure: the depth spectrum constrains the fixed-point count, but it is unclear whether it determines it uniquely.

---

## 7. Discussion

### 7.1 Categorical Perspective

The flow morphisms we define form a category CFlow, and the universality quotient construction defines a functor from CFlow to Set. The merging principle is the statement that this functor is well-defined on morphisms. This connects our work to the broader program of categorical renormalization.

### 7.2 Limitations

Our current framework treats depth as the sole relevant scale. In practice, proofs have multiple notions of complexity (depth, width, reuse count, etc.), and a full renormalization theory should incorporate all of them. The depth-graded framework is a natural starting point because depth provides a well-ordering that guarantees convergence.

### 7.3 Connection to Existing Work

The `ClosureFlow` framework in the Catalog (`Bridges/RenormalizationUniversality.lean`) provides the foundation on which our work builds. Our contributions add:
- Depth-graded convergence with explicit bounds
- The categorical morphism theory (flow morphisms, composition, functoriality)
- A concrete tropical model with complete classification
- The spectral monotonicity theorem

---

## 8. Future Work

1. **Multi-scale renormalization**: Extend the depth-graded framework to handle multiple complexity measures simultaneously.
2. **Empirical validation**: Apply the framework to actual proof libraries (e.g., Mathlib) and compute universality classes empirically.
3. **Categorical universality**: Connect flow morphisms to the broader categorical framework of natural transformations and adjunctions.
4. **Spectral rigidity**: Resolve Conjecture 6.1 either by proof or counterexample.

---

## References

1. K. Wilson, "The renormalization group and critical phenomena," *Rev. Mod. Phys.* 55 (1983), 583-600.
2. R.A. Cuninghame-Green, *Minimax Algebra*, Lecture Notes in Economics and Mathematical Systems 166, Springer, 1979.
3. R.M. Karp, "A characterization of the minimum cycle mean in a digraph," *Discrete Math.* 23 (1978), 309-311.
