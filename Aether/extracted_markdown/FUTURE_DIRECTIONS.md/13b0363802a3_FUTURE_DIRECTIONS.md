# Future Directions: Tropical Tree Automata Closure Properties

## Direction 1: Hadamard (Pointwise) Product for General Semirings

**Statement.** Generalize the product closure theorem from ENNReal to an arbitrary commutative semiring `(S, ⊕, ⊗)`. If `A₁, A₂` are weighted tree automata over `S`, then `eval(product A₁ A₂) t = eval A₁ t ⊗ eval A₂ t`.

**Lean signature:**
```lean
theorem WTA.eval_product_semiring
    [CommSemiring S] [CompleteLattice S]
    (A₁ : WTA σ ar Q₁) (A₂ : WTA σ ar Q₂)
    (t : RTree σ ar) :
    eval (productSemiring A₁ A₂) t = eval A₁ t * eval A₂ t
```

**Proof strategy.** The key identity `⨁_{(f₁,f₂)} (g₁(f₁) ⊗ g₂(f₂)) = (⨁_{f₁} g₁(f₁)) ⊗ (⨁_{f₂} g₂(f₂))` requires distributivity of `⊗` over `⨁`. For the tropical semiring (min, +), this is our `iInf_add_iInf_eq_iInf_prod`. For (ℕ, +, ×), this is finite Cauchy products. The framework unifies word automata, tree automata, and semiring parsing.

**Cross-domain significance.** This directly yields verified algorithms for probabilistic context-free grammars (Boolean semiring → recognition; probability semiring → inside algorithm; Viterbi semiring → best parse). It connects automata theory to algebraic approaches to formal language theory (Droste–Kuich–Vogler).

---

## Direction 2: Composition / Relabeling Closure

**Statement.** If `A` is a weighted tree automaton over signature `σ₁` and `B` is a weighted tree transducer from `σ₁` to `σ₂`, then there exists an automaton `C` over `σ₂` such that `eval C t = ⨅_{s : B(s)=t} eval A s + cost_B(s,t)`.

**Lean signature:**
```lean
theorem WTA.composition_closure
    (A : WTA σ₁ ar₁ Q₁)
    (B : WeightedTreeTransducer σ₁ ar₁ σ₂ ar₂ Q₂)
    (t : RTree σ₂ ar₂) :
    ∃ R, ∃ C : WTA σ₂ ar₂ R, ∀ t, C.eval t = ⨅ s ∈ preimage B t, A.eval s + B.cost s t
```

**Proof strategy.** Define a product-like construction where the automaton tracks both the original state and the transducer state. The key difficulty is that tree transducers can copy or delete subtrees, requiring careful handling of linearity.

**Cross-domain significance.** This is the foundation of tree transducer cascades, which model compilation pipelines, program transformations, and syntax-directed translation. Verified composition enables certified compiler optimization chains.

---

## Direction 3: Determinization with Tropical Weights

**Statement.** Every weighted tree automaton over the tropical semiring can be converted to an equivalent deterministic weighted tree automaton (where each tree has a unique run), possibly with an exponential blowup in states.

**Lean signature:**
```lean
theorem WTA.determinization
    [Fintype Q] [DecidableEq Q]
    (A : WTA σ ar Q) :
    ∃ (R : Type) [Fintype R], ∃ B : DeterministicWTA σ ar R,
      ∀ t, B.eval t = A.eval t
```

**Proof strategy.** Use the subset construction: states of the deterministic automaton are functions `Q → ENNReal` (cost vectors). For finite Q, this is `Fintype (Q → ENNReal)`, but practically we track reachable cost vectors. The correctness proof uses induction on trees and shows cost vectors propagate correctly.

**Cross-domain significance.** Determinization is essential for efficient evaluation and intersection with other automata. In parsing, deterministic automata enable linear-time recognition. For neural network verification, deterministic WTA provide canonical representations of tree-structured computation.

---

## Direction 4: Star-Free Characterization and Logic

**Statement.** Characterize which tree series `RTree σ ar → ENNReal` are tropically recognizable in terms of a weighted monadic second-order logic (WMSO) on trees. Show that WMSO-definable tree series are exactly the recognizable ones.

**Lean signature:**
```lean
theorem WTA.Buechi_equiv
    (φ : WMSO σ ar ENNReal)  :
    ∃ Q [Fintype Q], ∃ A : WTA σ ar Q, ∀ t, A.eval t = φ.semantics t

theorem WTA.to_WMSO
    [Fintype Q] (A : WTA σ ar Q) :
    ∃ φ : WMSO σ ar ENNReal, ∀ t, φ.semantics t = A.eval t
```

**Proof strategy.** Follow Droste–Gastin's approach: define weighted MSO formulas, show atomic formulas correspond to single-state automata, and then show closure under the MSO connectives follows from automata closure (conjunction → product, disjunction → union, existential quantification → projection). Our product and union theorems are two of the three needed closure properties.

**Cross-domain significance.** This is the Büchi theorem for weighted trees. It provides a logical characterization of what can be computed by dynamic programming on trees, connecting automata theory to descriptive complexity. Applications include database query optimization and XML schema validation.

---

## Direction 5: Tropical Intersection with Regular Tree Languages

**Statement.** If `A` is a weighted tree automaton and `L` is a regular tree language (given by an unweighted tree automaton), then there exists a weighted tree automaton `A_L` such that `eval A_L t = eval A t` for `t ∈ L` and `eval A_L t = ⊤` for `t ∉ L`.

**Lean signature:**
```lean
theorem WTA.restrict_to_language
    [Fintype Q₁] [Fintype Q₂]
    (A : WTA σ ar Q₁) (L : TreeAutomaton σ ar Q₂) :
    ∃ R, ∃ B : WTA σ ar R,
      ∀ t, B.eval t = if L.accepts t then A.eval t else ⊤
```

**Proof strategy.** This is a variant of the product construction where one component is an unweighted automaton. The product automaton has states `Q₁ × Q₂`; transitions cost `A.delta` when the `Q₂` component is accepting and `⊤` otherwise. This is simpler than the general product and could serve as an introductory example.

**Cross-domain significance.** Intersection with regular languages enables constrained optimization: "find the minimum-cost tree that also satisfies structural constraints." Applications include type-directed program synthesis, grammar-constrained decoding in NLP, and constrained parsing for structured prediction.

---

## Implementation Priorities

1. **Direction 5** (intersection) — Simplest extension, high practical value
2. **Direction 1** (general semirings) — Foundational, enables directions 4
3. **Direction 3** (determinization) — Essential for efficient implementation
4. **Direction 2** (composition) — Enables compiler verification applications
5. **Direction 4** (logic characterization) — Deep theoretical result

## Cross-Cutting Themes

- **Verified dynamic programming:** Each theorem provides a certified algorithm for a class of tree optimization problems.
- **Compositionality:** The closure properties form an algebra of tree cost functions, enabling modular construction of complex cost models.
- **Connection to machine learning:** Tree-structured models (recursive neural networks, tree LSTMs, compositional semantics) can be analyzed and verified through the lens of weighted tree automata.
- **Tropical geometry connection:** The set of cost functions recognizable by WTAs forms a tropical semiring variety, connecting to tropical algebraic geometry.
