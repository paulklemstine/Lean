# Future Directions: Semiconjugacy Orbit Arithmetic

This document outlines concrete breakthrough research opportunities opened by the formal theory of orbit transport through semiconjugacies developed in `Bridges/SemiconjOrbitArithmetic/Core.lean`.

---

## 1. Cycle Quotient Theorem

**Target theorem:** Define an equivalence relation on a finite type by *eventual coalescence* (two points are equivalent if their orbits eventually merge), and prove that semiconjugacy descends to the quotient — i.e., the induced map on equivalence classes is well-defined and semiconjugates the induced dynamics.

```
theorem Semiconj.quotient_descend [Finite α] [Finite β]
    (hsc : Semiconj h f g)
    (R : Setoid α := eventualCoalescenceSetoid f)
    (S : Setoid β := eventualCoalescenceSetoid g) :
    ∃ h' : Quotient R → Quotient S,
      Semiconj h' (Quotient.map' f _) (Quotient.map' g _)
```

**Dependencies:** Formalization of eventual coalescence setoid; proof that `f` respects the setoid; quotient map construction.

**Significance:** This would make semiconjugacy a functor on the category of finite dynamical systems modulo eventual equivalence — the algebraic foundation for state-space reduction in model checking and symbolic dynamics.

---

## 2. Period-Counting Inequality Under Finite Fibers

**Target theorem:** For a surjective semiconjugacy `h : α → β` between finite dynamical systems, the number of distinct cycle lengths in the `g`-dynamics is at most the number of distinct cycle lengths in the `f`-dynamics. More precisely, every cycle length appearing in `g` divides some cycle length appearing in `f`.

```
theorem Semiconj.cycle_lengths_image_subset [Fintype α] [Fintype β]
    (hsc : Semiconj h f g) (hsurj : Surjective h) :
    {Function.minimalPeriod g y | y ∈ periodicPts g} ⊆
      {d | ∃ n ∈ {Function.minimalPeriod f x | x ∈ periodicPts f}, d ∣ n}
```

**Dependencies:** `minimalPeriod_image_dvd` (proved); finiteness of periodic point sets on finite types; surjectivity to ensure all `g`-cycles are hit.

**Significance:** This gives a combinatorial refinement of orbit transport — not just "periods divide" but "the spectrum of cycle lengths contracts under factor maps." This connects to zeta-function comparisons in symbolic dynamics, where the periodic-point counting function `p_n(f) = |Fix(f^n)|` satisfies `p_n(g) ≤ p_n(f)` for surjective semiconjugacies.

---

## 3. Entropy-Shadow Prototype: Periodic-Point Growth Monotonicity

**Target theorem:** On finite state spaces, define the periodic-point counting sequence `p_n(f) = |{x : α | IsPeriodicPt f n x}|` and prove that for any surjective semiconjugacy, `p_n(g) ≤ p_n(f)` for all `n`.

```
theorem Semiconj.periodicPt_card_le [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (hsc : Semiconj h f g) (hsurj : Surjective h) (n : ℕ) :
    Fintype.card {y : β // IsPeriodicPt g n y} ≤ Fintype.card {x : α // IsPeriodicPt f n x}
```

**Dependencies:** `mapsTo_periodicPts_n` (proved); surjectivity; Fintype.card monotonicity under surjective maps restricted to subtypes.

**Significance:** This is the finite-state prototype of topological entropy monotonicity under factor maps (`h_top(g) ≤ h_top(f)`). In symbolic dynamics, topological entropy equals `lim (1/n) log p_n(f)`, so bounding `p_n` is the key step. Formalizing this creates a path toward machine-checked entropy bounds — relevant to information theory, ergodic theory, and cryptographic security analysis.

---

## 4. Functional Graph Condensation Theorem

**Target theorem:** Formalize finite dynamical systems as functional digraphs (each vertex has out-degree exactly 1). Prove that a semiconjugacy induces a graph homomorphism that maps cycles to cycles and preserves the tree-of-cycles structure (the condensation DAG).

```
structure FunctionalDigraph (α : Type*) [Fintype α] where
  next : α → α

def FunctionalDigraph.scc_condensation (G : FunctionalDigraph α) : ...

theorem Semiconj.induces_condensation_morphism [Fintype α] [Fintype β]
    (hsc : Semiconj h f g) :
    ∃ h_cond : G_f.condensation → G_g.condensation,
      CondensationMorphism h_cond
```

**Dependencies:** Formalization of strongly connected components for functional digraphs; condensation DAG construction; the `isPeriodicPt_image` and `minimalPeriod_image_dvd` theorems (proved).

**Significance:** This bridges discrete dynamics with graph theory. Every finite deterministic automaton is a functional digraph; semiconjugacy becomes a simulation relation. The condensation theorem would give a formal foundation for abstract interpretation in program verification — proving that abstracting a state machine preserves reachability and liveness properties at the SCC level.

---

## 5. Cryptographic Observable-Period Bound

**Target theorem:** Combine the finite-orbit collision theorem (`exists_iterate_image_eq_of_finite`) with `minimalPeriod_image_dvd` to prove that the observable period of a cryptographic state machine is bounded by internal orbit statistics.

```
theorem Semiconj.observable_period_bound [Fintype β]
    (hsc : Semiconj h f g)
    (x : α) (hx : x ∈ periodicPts f) :
    minimalPeriod g (h x) ≤ Fintype.card β ∧
    minimalPeriod g (h x) ∣ minimalPeriod f x
```

**Dependencies:** `minimalPeriod_image_dvd` (proved); `minimalPeriod_le_card` from Mathlib; `exists_iterate_image_eq_of_finite` (proved).

**Significance:** In cryptography, an attacker observing a compressed view of an internal PRNG state can detect periodicity no later than the state-space size of the observable. Combined with divisibility, this means the observable period is tightly constrained: it divides the internal period AND is bounded by `|β|`. This gives formal security bounds on pseudorandom generators viewed through lossy channels — directly applicable to stream cipher analysis, hash function collision bounds, and post-quantum cryptographic protocol verification.

---

## Cross-Cutting Research Themes

### Toward a Semiconjugacy Category
The theorems proved here suggest organizing finite dynamical systems into a category where morphisms are semiconjugacies. The period-divisibility theorem becomes a functor from this category to the poset of divisibility lattices. Formalizing this categorical structure would enable compositional reasoning about chains of abstractions.

### Tropical Dynamics Connection
Semiconjugacy to a system on a tropical semiring (where dynamics becomes piecewise-linear) could provide a "tropicalization of dynamics" — preserving cycle structure while simplifying the algebra. The `minimalPeriod_image_dvd` theorem would ensure that tropical shadows faithfully reflect the period spectrum.

### Machine Learning State Compression
Neural networks with recurrent architectures exhibit discrete dynamics on quantized state spaces. A trained encoder that semiconjugates the recurrent dynamics to a lower-dimensional representation is guaranteed (by our theorems) to preserve periodic attractors up to period divisibility. This provides formal guarantees for representation learning in dynamical systems.
