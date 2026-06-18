# Future Directions: Closure–Matroid Duality and Dependency Geometry

## 1. Duality Between Qualified Sets and Cocircuit-Style Forbidden Sets

**Status:** Formulation ready, proof infrastructure available.

The qualified sets of a dependency presentation form the "positive" side of an access structure. The complementary "negative" side — sets that are *forbidden* from spanning — should correspond to cocircuits or coflats of the dual matroid. Formalizing this duality would complete the cryptographic picture:

- **Qualified sets** ↔ sets that can reconstruct a secret
- **Forbidden sets** ↔ sets from which no information leaks
- **Cocircuits** ↔ minimal forbidden sets (minimal information barriers)

**Concrete next step:** Define the dual closure system `cl*(A) = ground \ cl(ground \ A)`, prove it satisfies exchange, and show its circuits are the cocircuits of the primal system. Prove that qualified sets of the primal are exactly the complements of coindependent sets.

## 2. Tropical Information Measures on Dependency Semimodules

**Status:** Conceptual framework clear, formalization requires tropical algebra infrastructure.

The rank function of an exchange closure system behaves like a "tropical entropy" — it is submodular, monotone, and bounded. The idempotent (min-plus) semiring structure of tropical algebra provides a natural algebraic syntax for dependency geometry:

- **Rank** = tropical cost of generation (min-cost spanning)
- **Circuits** = tropical minimal supports (analogous to tropical varieties)
- **Closure** = idempotent saturation

**Concrete next step:** Define a tropical semiring-valued rank function on the dependency presentation, prove it satisfies the (tropical) submodularity inequality, and show that tropical rank equals matroid rank in the finitary case. Explore connections to tropical convexity and tropical linear algebra.

## 3. Representability Criteria over Specific Idempotent Semirings

**Status:** Open problem, high impact.

Not all matroids are representable over a given field. The dependency presentation framework raises a parallel question: which exchange closure systems are representable as dependency semimodules over a *specific* idempotent semiring (e.g., the Boolean semiring, the tropical semiring, the max-plus semiring)?

**Concrete next step:** Characterize which matroids of rank ≤ 4 are representable over the Boolean semiring (where dependencies are Boolean vectors). Connect to the theory of forbidden minors. Show that graphic matroids are always Boolean-representable.

## 4. Categorical Reconstruction and Functoriality

**Status:** Structure theorems proved, functoriality requires category-theoretic infrastructure.

The round-trip theorem (closure → presentation → closure = original) is a *set-level* equivalence. Upgrading this to a *functorial* equivalence would:

- Make the construction natural with respect to matroid morphisms
- Connect to Tannakian reconstruction principles (as in the existing `TannakaClosureReconstruction.lean`)
- Enable transport of structure along matroid minors and duality

**Concrete next step:** Define a category of exchange closure systems (morphisms = closure-preserving maps), a category of dependency presentations (morphisms = support-preserving carrier maps), and prove the canonical presentation functor is an equivalence of categories. Connect to the reconstruction functor already formalized in the project.

## 5. Probabilistic and Entropy-Weighted Extensions

**Status:** Conceptual, connects to information theory.

The idealized closure rank counts *how many* elements span a set. In real-world applications (randomness extraction, noisy ML), the relevant quantity is *how much information* is needed — entropy, not cardinality. Extending the framework to entropy-weighted closures would:

- Replace `r(A) = min |B|` with `r(A) = min H(B)` for entropy H
- Connect to the extractor literature (min-entropy, Rényi entropy)
- Provide certified entropy-loss bounds for secret sharing and feature extraction

**Concrete next step:** Define an entropy-weighted rank function, prove it satisfies a relaxed version of the matroid axioms (polymatroid axioms), and show that the closure-from-entropy-rank characterization still holds. Connect to the Shannon entropy inequalities and the Ingleton inequality.

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Cocircuit duality | Medium | High | Current formalization |
| 2. Tropical measures | Medium | Medium | Tropical semiring library |
| 3. Representability | Hard | Very High | Minor theory |
| 4. Functoriality | Medium | High | Category theory library |
| 5. Entropy extensions | Hard | Very High | Probability/measure theory |

**Recommended order:** 1 → 4 → 2 → 3 → 5

Directions 1 and 4 build directly on the current formalization and would produce publishable results quickly. Direction 2 leverages the existing tropical algebra in the project catalog. Directions 3 and 5 are deeper research programs that open new mathematical territory.
