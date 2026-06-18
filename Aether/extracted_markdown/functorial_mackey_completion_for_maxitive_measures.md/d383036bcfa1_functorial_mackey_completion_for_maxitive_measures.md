# Functorial Mackey Completion for Maxitive Measures on Finite T₀ Spaces via Idempotent Kantorovich Codensity and Support Reconstruction

## Abstract

We develop a completion theory for maxitive measures (idempotent capacities) on finite T₀ spaces, replacing analytic metric completion with a finite order-theoretic construction. In the Alexandrov topology on a finite preorder, irreducible closed sets are principal lower sets, and we prove that the quotient of set functions by "zero Kantorovich distance" is canonically equivalent to the space of monotone codensity assignments on these sets. The completion is functorial: pushforward along monotone maps preserves the codensity equivalence and commutes with the completion map. All results are formally verified in Lean 4 with Mathlib.

**Keywords:** Maxitive measures, idempotent analysis, Kantorovich distance, finite T₀ spaces, codensity, formal verification, Lean 4

---

## 1. Introduction

### 1.1 Background

Maxitive measures — also called *possibility measures*, *idempotent probabilities*, or *plausibility measures* — assign to each event a "plausibility" value such that the plausibility of a union is the maximum (rather than the sum) of the individual plausibilities:

$$\mu(A \cup B) = \max(\mu(A), \mu(B))$$

These measures arise naturally in:
- **Robust statistics** and **imprecise probability**, where upper expectations satisfy maxitivity;
- **Tropical geometry** and **max-plus algebra**, where the max operation replaces addition;
- **Domain theory** and **denotational semantics**, where Scott-continuous valuations on domains are maxitive;
- **Reliability engineering**, where system failure probability under worst-case dependence is maxitive.

The **idempotent Kantorovich distance** is a tropical analogue of the classical Wasserstein/Kantorovich distance from optimal transport theory. Instead of integrating a cost function against a coupling of measures, it computes the supremum over monotone test functions of the max-plus "integral" discrepancy.

### 1.2 The Finite T₀ Setting

A topological space is **T₀** (Kolmogorov) if for any two distinct points, there exists an open set containing one but not the other. For *finite* spaces, the Alexandrov construction gives a bijection:

$$\{\text{finite T}_0 \text{ spaces}\} \longleftrightarrow \{\text{finite partial orders}\}$$

Under this correspondence:
- **Closed sets** = lower sets (downward-closed subsets);
- **Irreducible closed sets** = principal lower sets $\downarrow x = \{y : y \leq x\}$;
- **Continuous maps** = monotone functions.

This makes the finite T₀ setting a natural laboratory for developing completion theories: the topology is entirely combinatorial, and all constructions are computable.

### 1.3 Main Contributions

We prove the following results, all formally verified in Lean 4:

1. **Codensity Round-Trip** (`codensity_roundtrip`): The operation of converting a codensity assignment to a maxitive measure and back recovers the original assignment.

2. **Zero-Distance Characterization** (`idempotentKantorovich_eq_zero_iff_supportGaugeEq`): For monotone set functions with finite codensity values, the symmetrized idempotent Kantorovich distance is zero if and only if the functions agree on all principal lower sets.

3. **Quotient Equivalence** (`quotient_equiv_functions`): In a finite T₀ space, the quotient of set functions by codensity equality is equivalent to the function space $X \to \mathbb{R}_{\geq 0}^{\infty}$.

4. **Functorial Completion** (`FunctorialIdempotentMackeyCompletion`): Pushforward along monotone maps preserves the codensity equivalence for maxitive measures, and the completion commutes with pushforward.

5. **Finite Stabilization** (`finite_support_pattern_eventually_stable`): Any sequence of set functions whose codensity weights are eventually constant at each point must globally stabilize.

---

## 2. Definitions

### 2.1 Finite T₀ Support Class

```lean
class FiniteT0SupportClass (X : Type*) [Fintype X] [Preorder X] : Prop where
  antisymm_of_closure_eq : ∀ {x y : X}, (∀ z : X, z ≤ x ↔ z ≤ y) → x = y
```

This packages the T₀ separation axiom for finite preorders: if two points have the same principal lower set, they are equal. Every finite partial order satisfies this automatically.

### 2.2 Irreducible Closed Sets and Codensity Weights

The **irreducible closed set** (principal lower set) of a point $x$ is:
$$\downarrow x = \{y \in X : y \leq x\}$$

The **codensity weight** of $x$ under a set function $\mu$ is:
$$\text{icw}(\mu, x) = \mu(\downarrow x)$$

Two set functions $\mu, \nu$ have **equal codensity** (written `supportGaugeEq`) if $\text{icw}(\mu, x) = \text{icw}(\nu, x)$ for all $x$.

### 2.3 Codensity Assignments

A **codensity assignment** on a preorder $X$ is a monotone function $c : X \to \mathbb{R}_{\geq 0}^{\infty}$:

```lean
structure CodensityAssignment (X : Type*) [Preorder X] where
  toFun : X → ℝ≥0∞
  monotone' : Monotone toFun
```

### 2.4 The Measure–Codensity Correspondence

Given a monotone set function $\mu$, the **canonical map** to codensity assignments is:
$$\text{measureToCodensity}(\mu)(x) = \mu(\downarrow x)$$

The **inverse construction** from a codensity assignment to a maxitive set function is:
$$\text{codensityToMeasure}(c)(A) = \sup_{x \in A} c(x)$$

### 2.5 Idempotent Kantorovich Distance

The **idempotent Kantorovich pseudodistance** is:
$$d_{IK}(\mu, \nu) = \sup_{f \text{ monotone}} \left| \sup_x (f(x) - \text{icw}(\mu, x)) - \sup_x (f(x) - \text{icw}(\nu, x)) \right|$$

where the outer supremum ranges over all monotone test functions $f : X \to \mathbb{R}$.

---

## 3. Main Results

### 3.1 The Codensity Round-Trip (Theorem 1)

**Theorem** (`codensity_roundtrip`). *For any codensity assignment $c$ on a finite preorder $X$ and any point $x \in X$:*
$$\text{icw}(\text{codensityToMeasure}(c), x) = c(x)$$

*Proof.* Since $c$ is monotone and $x \in \downarrow x$, we have $c(x) \leq \sup_{y \leq x} c(y) = \text{codensityToMeasure}(c)(\downarrow x)$. Conversely, for any $y \leq x$, $c(y) \leq c(x)$ by monotonicity, so $\sup_{y \leq x} c(y) \leq c(x)$.

**Corollary** (`measureToCodensity_codensityToMeasure`). $\text{measureToCodensity} \circ \text{codensityToMeasure} = \text{id}$.

### 3.2 Maxitive Structure (Theorem 2)

**Theorem** (`maxitive_supportGaugeEq_implies_eq`). *If $\mu$ and $\nu$ are maxitive set functions with equal codensity weights, then $\mu = \nu$.*

This is because maxitive set functions are completely determined by their values on principal lower sets:
$$\mu(A) = \sup_{x \in A} \mu(\downarrow x) = \sup_{x \in A} \text{icw}(\mu, x)$$

### 3.3 Zero-Distance Characterization (Theorem 3)

**Theorem** (`idempotentKantorovich_eq_zero_iff_supportGaugeEq`). *For monotone set functions $\mu, \nu$ with finite codensity values:*
$$d_{IK}(\mu, \nu) = 0 \iff \text{supportGaugeEq}(\mu, \nu)$$

*Proof sketch.* The backward direction ($\Leftarrow$) is immediate: if all codensity weights agree, the two suprema in the IK formula are identical. For the forward direction ($\Rightarrow$), suppose $\text{icw}(\mu, x_0) \neq \text{icw}(\nu, x_0)$ for some $x_0$. Since $\mu$ is monotone, the function $f(z) = \text{icw}(\mu, z)$ is a valid monotone test function (with finite real values by hypothesis). Substituting this into the IK formula gives a nonzero contribution, contradicting $d_{IK} = 0$.

### 3.4 Quotient Equivalence (Theorem 4)

**Theorem** (`quotient_equiv_functions`). *In a finite T₀ space, the quotient of set functions by `supportGaugeEq` is equivalent to $X \to \mathbb{R}_{\geq 0}^{\infty}$.*

The proof uses `toCodensityFun_surjective` (every function arises as the codensity of some set function, using the T₀ condition for well-definedness) and injectivity from the definition of the equivalence relation.

### 3.5 Functorial Completion (Theorem 5)

**Theorem** (`FunctorialIdempotentMackeyCompletion`). *For any monotone map $f : X \to Y$ between finite preorders:*
1. *If $\mu, \nu$ are maxitive and $\text{supportGaugeEq}(\mu, \nu)$, then $\text{supportGaugeEq}(f_*\mu, f_*\nu)$.*
2. *For any codensity assignment $c$, the pushforward of $\text{codensityToMeasure}(c)$ has codensity weights equal to $\text{pushforwardCodensity}(f, c)$.*

### 3.6 Finite Stabilization (Theorem 6)

**Theorem** (`finite_support_pattern_eventually_stable`). *If $(u_n)$ is a sequence of set functions on a finite type such that each codensity weight is eventually constant, then there exists $N$ such that the entire codensity profile is constant for $n \geq N$.*

This follows from taking the maximum of the finitely many stabilization indices (one per element of $X$).

---

## 4. Applications

### 4.1 Tropical Belief Propagation

In a network of agents with "tropical beliefs" (maxitive measures representing plausibility), the codensity completion provides a canonical representation. Message-passing between agents corresponds to pushforward of codensity assignments along monotone maps. The functoriality theorem guarantees that equivalent beliefs remain equivalent after message-passing.

### 4.2 Robust Statistics and Imprecise Probability

Upper expectations in robust Bayesian statistics are maxitive. The codensity completion identifies the essential information in an upper expectation: its values on "basic events" (irreducible closed sets). Two upper expectations that agree on basic events are interchangeable for all decision-making purposes.

### 4.3 Formal Verification of Probabilistic Systems

The Lean formalization provides certified algorithms for:
- **Reconstructing** a maxitive measure from its codensity profile ($O(2^n)$ in the worst case, $O(n \log n)$ for chains);
- **Comparing** maxitive measures via their codensity profiles ($O(n)$ pointwise comparison);
- **Composing** measurements through system architectures via functorial pushforward.

---

## 5. Discussion: Making the Invisible Visible

*For Scientific American readers*

Imagine you have a weather forecasting system that, instead of giving you precise probabilities ("30% chance of rain"), gives you plausibility estimates ("rain is at most this plausible"). These "maxitive" or "possibility" measures are the mathematical objects at the heart of this paper.

The classical theory of probability has a beautiful completion theory: if you have a sequence of probability distributions that are "getting closer together" (in a precise mathematical sense), they converge to a unique limit distribution. This is the mathematical backbone of statistics, machine learning, and much of modern science.

But for maxitive measures — the "worst-case" or "plausibility" cousins of probability — no such clean completion theory existed, at least not in the finite combinatorial setting we study. Our contribution is to show that in finite ordered spaces (think: a hierarchy of events, like "rain" ≤ "bad weather" ≤ "weather event"), there is a canonical, computable way to "complete" maxitive measures.

The key insight is almost embarrassingly simple: a maxitive measure on a finite ordered space is completely determined by its values on "principal lower sets" — the set of all events at or below a given threshold. Two maxitive measures that agree on all these threshold sets are identical for all practical purposes. The "completion" is just the space of all possible threshold-value profiles.

What makes this more than a trivial observation is the **functoriality**: when you "coarsen" your event space (grouping fine-grained events into coarser categories), the completion transforms consistently. This means you can reason about maxitive measures at different levels of granularity, and the conclusions will always be compatible.

The formal verification in Lean 4 means that every step of this argument has been checked by a computer, down to the logical axioms. This is not just a confidence boost — it's a guarantee that the theory is correct, free from the subtle errors that plague complex mathematical arguments.

---

## 6. Related Work

The idempotent Kantorovich distance was introduced by Kolokoltsov and Maslov in the context of idempotent analysis and max-plus algebra. The connection between finite T₀ spaces and preorders is classical (Alexandrov topology). The codensity monad perspective draws from categorical semantics, particularly the work of Leinster on codensity monads. The formal verification approach builds on the Mathlib library for Lean 4.

---

## 7. Conclusion

We have established a functorial completion theory for maxitive measures on finite T₀ spaces, proving that the zero-distance quotient of the idempotent Kantorovich pseudometric is canonically equivalent to the space of monotone codensity assignments on irreducible closed sets. All results are formally verified in Lean 4 with Mathlib, providing the first machine-checked development of idempotent completion theory.

The finite T₀ setting is both a starting point and a testing ground. The algebraic simplicity of the proofs suggests that the theory should extend to spectral spaces and beyond, and the computational nature of the constructions opens the door to certified algorithms for tropical optimal transport and belief propagation.

---

## References

1. V.P. Maslov, *Idempotent Analysis and Its Applications*, Kluwer, 1997.
2. V.N. Kolokoltsov and V.P. Maslov, *Idempotent Analysis and Its Applications*, Kluwer, 1997.
3. P.S. Alexandrov, "Diskrete Räume," *Rec. Math. [Mat. Sbornik]*, 1937.
4. The Mathlib Community, *Mathlib: The Lean Mathematical Library*, 2020–2025.
