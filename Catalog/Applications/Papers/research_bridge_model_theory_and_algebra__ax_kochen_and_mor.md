# Bridge: Model Theory and Algebra — Ax-Kochen and Morley's Theorem

## Abstract

We present a formal development bridging the model-theoretic and algebraic infrastructure in Lean 4's Mathlib library. Our main contributions are: (1) a proof that complete first-order theories force elementary equivalence of all models, filling a gap between Mathlib's existing `Theory.IsComplete` and `ElementarilyEquivalent` APIs; (2) a proof that elementary equivalence preserves the model relation, establishing the fundamental transfer principle; (3) a proof that κ-categorical theories (under standard conditions) yield elementarily equivalent models, linking categoricity to semantic agreement via the Łoś-Vaught test; and (4) complementary results including the boundary theorem that incomplete satisfiable theories admit models disagreeing on some sentence, and uniqueness of henselian root lifts. These results form the formal backbone required for a machine-checked treatment of the Ax-Kochen-Ershov transfer principle and Morley's categoricity theorem.

**Keywords:** model theory, elementary equivalence, completeness, categoricity, henselian local rings, Ax-Kochen, Morley, formal verification

---

## 1. Introduction

Model theory and algebra have enjoyed one of the most productive cross-pollinations in twentieth-century mathematics. The Ax-Kochen-Ershov theorem [1, 2, 14] demonstrated that the first-order theory of a henselian valued field is determined by the theories of its residue field and value group—a result that resolved long-standing questions about p-adic fields. Morley's categoricity theorem [12] showed that a countable theory categorical in one uncountable cardinal is categorical in all uncountable cardinals, inaugurating the classification theory of models that Shelah would later develop into a vast edifice [15].

Despite the maturity of both model theory and formal mathematics libraries, the precise formal connections between completeness, elementary equivalence, categoricity, and henselian algebra had not been established in Lean 4's Mathlib. This paper describes a formalization that bridges these concepts, producing machine-checked proofs of the core linking theorems.

### 1.1 Contributions

Our formalization (see @file[Bridges/AxKochenMorleyBridge.lean]) establishes four main results:

1. **Completeness implies elementary equivalence** (Theorem 3.1): Any two nonempty models of a complete theory are elementarily equivalent.

2. **Elementary equivalence preserves models** (Theorem 3.2): If M ≡_L N and M ⊨ T, then N ⊨ T.

3. **Categoricity implies elementary equivalence** (Theorem 3.3): Under standard conditions (κ infinite, |L| ≤ κ, only infinite models), κ-categorical theories have pairwise elementarily equivalent models.

4. **Boundary result for incomplete theories** (Theorem 3.4): A satisfiable incomplete theory admits models that disagree on some sentence.

Additionally, we establish uniqueness of henselian root lifts for simple roots, complementing the existence direction of Hensel's lemma.

### 1.2 Related Work

The model-theoretic results we formalize are classical; see Marker [11] or Hodges [7] for textbook treatments. The Ax-Kochen-Ershov theorem was proved independently by Ax-Kochen [1, 2] and Ershov [14]. Morley's theorem [12] was later re-proved and extended by Baldwin-Lachlan [3] and Shelah [15].

In the formalization landscape, Mathlib contains extensive first-order model theory infrastructure due to work by Gavin, Schlösser, and others, including `Theory.IsComplete`, `ElementarilyEquivalent`, `Cardinal.Categorical`, the Łoś-Vaught test (`Categorical.isComplete`), and `completeTheory`. Our contribution is the formal *glue* connecting these components.

Henselian local rings are formalized in Mathlib following the treatment of Wedhorn [16], with the key property `HenselianLocalRing` ensuring existence of root lifts. Our uniqueness result fills the complementary gap.

---

## 2. Preliminaries

### 2.1 First-Order Logic in Mathlib

We work within Mathlib's `FirstOrder.Language` framework. A first-order language `L : Language.{u, v}` specifies function and relation symbols. An `L.Theory` is a set of `L.Sentence`s. A structure `M` models a theory `T`, written `M ⊨ T`, when every sentence in `T` is satisfied by `M`.

**Definition 2.1** (Elementary Equivalence). Two L-structures M and N are *elementarily equivalent*, written `L.ElementarilyEquivalent M N`, if they satisfy exactly the same L-sentences:

$$M \equiv_L N \iff \forall \varphi \in \mathrm{Sent}(L),\; M \models \varphi \Leftrightarrow N \models \varphi$$

In Mathlib, this is defined as equality of complete theories: `L.ElementarilyEquivalent M N ↔ L.completeTheory M = L.completeTheory N`, which is shown equivalent to the sentence-level characterization via `elementarilyEquivalent_iff`.

**Definition 2.2** (Completeness). A theory `T` is *complete* if it is satisfiable and for every sentence φ, either `T ⊨ᵇ φ` or `T ⊨ᵇ ¬φ`. In Mathlib: `T.IsComplete`.

**Definition 2.3** (Categoricity). A theory `T` is *κ-categorical* if all models of `T` of cardinality κ are isomorphic. In Mathlib: `κ.Categorical T`.

### 2.2 Henselian Local Rings

A local ring R with maximal ideal 𝔪 is *henselian* if every monic polynomial f ∈ R[X] that has a simple root modulo 𝔪 has a root in R lifting that approximate root. In Mathlib, this is captured by the class `HenselianLocalRing R`, which provides:

```
∀ (f : R[X]), f.Monic → ∀ (a₀ : R), f.eval a₀ ∈ maximalIdeal R →
  IsUnit (f.derivative.eval a₀) → ∃ a : R, f.IsRoot a ∧ (a - a₀) ∈ maximalIdeal R
```

### 2.3 Universe Considerations

Mathlib's `Theory.ModelsBoundedFormula` quantifies over models at a specific universe level. Our results are stated at universe `Type` (universe 0) to match the universe at which `Theory.IsComplete` is defined, avoiding universe polymorphism complications.

---

## 3. Main Results

### 3.1 Theorem 1: Complete Theories Yield Elementarily Equivalent Models

**Theorem 3.1** (`Theory.IsComplete.models_elementarilyEquivalent` in @file[Bridges/AxKochenMorleyBridge.lean]).
*Let L be a first-order language and T an L-theory. If T is complete, then any two nonempty models M, N of T are elementarily equivalent: M ≡_L N.*

*Proof sketch.* Let φ be an arbitrary L-sentence. Since T is complete, either T ⊨ᵇ φ or T ⊨ᵇ ¬φ.

**Case 1:** T ⊨ᵇ φ. By the semantic consequence relation, every model of T satisfies φ. In particular, both M ⊨ φ and N ⊨ φ. Hence (M ⊨ φ) ↔ (N ⊨ φ).

**Case 2:** T ⊨ᵇ ¬φ. By the same reasoning, neither M nor N satisfies φ. Again (M ⊨ φ) ↔ (N ⊨ φ).

Since φ was arbitrary, M and N agree on all sentences, so M ≡_L N. □

Two helper lemmas (`ModelsBoundedFormula.realize_of_model` and `ModelsBoundedFormula.not_realize_of_model_not`) mediate between Mathlib's bounded semantic consequence `T ⊨ᵇ φ` and the concrete realization `M ⊨ φ`.

**Corollary 3.1.1** (`models_agree_on_sentences`). Under the same hypotheses, for every sentence φ: (M ⊨ φ) ↔ (N ⊨ φ).

**Example 3.1.2.** The complete theory of any nonempty structure is complete (`completeTheory.isComplete`), confirming that the hypothesis is non-vacuous.

### 3.2 Theorem 2: Elementary Equivalence Preserves Models

**Theorem 3.2** (`elementarilyEquivalent_preserves_model` in @file[Bridges/AxKochenMorleyBridge.lean]).
*Let M and N be L-structures with M ≡_L N. If M ⊨ T, then N ⊨ T.*

*Proof sketch.* By `Theory.model_iff`, M ⊨ T means every φ ∈ T is realized by M. By `elementarilyEquivalent_iff`, M and N agree on all sentences. For each φ ∈ T, since M ⊨ φ, we have N ⊨ φ by elementary equivalence. Hence N ⊨ T. □

This result is the formal statement of the *transfer principle*: elementary equivalence is a sufficient condition for propagating all first-order properties.

**Corollary 3.2.1.** If N ≡ M, then N is a model of the complete theory Th(M).

**Corollary 3.2.2** (`elementarilyEquivalent_preserves_model_subset`). Elementary equivalence preserves model-hood for any subtheory of Th(M).

**Proposition 3.2.3** (`elementarilyEquivalent_symm`). Elementary equivalence is symmetric: M ≡_L N implies N ≡_L M. (In Mathlib's formulation, this is simply symmetry of equality on complete theories.)

### 3.3 Theorem 3: Categoricity Implies Elementary Equivalence

**Theorem 3.3** (`Categorical.models_elementarilyEquivalent` in @file[Bridges/AxKochenMorleyBridge.lean]).
*Let T be an L-theory and κ an infinite cardinal with |L| ≤ κ. Suppose T is κ-categorical, satisfiable, and has only infinite models. Then any two nonempty models of T are elementarily equivalent.*

*Proof sketch.* The proof chains two results:

1. **Łoś-Vaught test** (`Cardinal.Categorical.isComplete`): Under the given hypotheses, T is complete.
2. **Theorem 3.1**: Complete theories have elementarily equivalent models.

The Łoś-Vaught test is the classical result that a satisfiable theory with no finite models that is κ-categorical for some infinite κ ≥ |L| must be complete. The key idea is that if T were incomplete, there would exist a sentence φ with T ∪ {φ} and T ∪ {¬φ} both satisfiable. By Löwenheim-Skolem, both would have models of cardinality κ, contradicting κ-categoricity. □

This theorem is the formal entry point to Morley's program: it shows that categorical theories are semantically rigid.

### 3.4 Theorem 4: Incomplete Theories Have Disagreeing Models

**Theorem 3.4** (`Theory.incomplete_has_disagreeing_models` in @file[Bridges/AxKochenMorleyBridge.lean]).
*If T is satisfiable but not complete, then there exists a sentence φ and models M, N of T such that M ⊨ φ and ¬(N ⊨ φ).*

*Proof sketch.* Since T is not complete but is satisfiable, there exists a sentence φ such that neither T ⊨ᵇ φ nor T ⊨ᵇ ¬φ. The failure of T ⊨ᵇ φ means there exists a model M₀ of T with ¬(M₀ ⊨ φ), and the failure of T ⊨ᵇ ¬φ means there exists a model M₁ of T with M₁ ⊨ φ. These are the desired disagreeing models. □

This is the contrapositive of Theorem 3.1: completeness is not merely sufficient but *necessary* for elementary equivalence of all models.

### 3.5 Henselian Root Uniqueness

**Theorem 3.5** (`HenselianLocalRing.root_unique_of_simple`, referenced in @file[Bridges/AxKochenMorleyBridge.lean]).
*Let R be a henselian local ring with maximal ideal 𝔪, f ∈ R[X] monic, and a₀ ∈ R an approximate root (f(a₀) ∈ 𝔪) with f'(a₀) a unit. If a and b are both roots of f with a ≡ a₀ (mod 𝔪) and b ≡ a₀ (mod 𝔪), then a = b.*

This uniqueness result complements the existence guarantee of `HenselianLocalRing`. Together, they establish that simple roots lift *uniquely*, which is essential for the back-and-forth arguments in the Ax-Kochen-Ershov theory.

---

## 4. The Composition: From Categoricity to Transfer

The four main theorems compose into a pipeline that connects counting-theoretic conditions to algebraic consequences:

```
κ-Categoricity ──[Łoś-Vaught]──▶ Completeness ──[Thm 3.1]──▶ Elem. Equiv.
                                                                    │
                                                              [Thm 3.2]
                                                                    │
                                                                    ▼
                                                            Model Transfer
```

**Application to Ax-Kochen-Ershov.** The theory of henselian valued fields of equicharacteristic zero with fixed residue field theory and value group theory is complete (this is the content of the Ax-Kochen-Ershov theorem). By Theorem 3.1, any two such valued fields are elementarily equivalent. By Theorem 3.2, first-order properties transfer between them.

**Concrete instance.** For all but finitely many primes p, the p-adic field ℚₚ and the Laurent series field 𝔽ₚ((t)) are henselian valued fields with the same residue field (𝔽ₚ) and value group (ℤ). The Ax-Kochen theorem asserts that they are elementarily equivalent, so any first-order property of one holds for the other.

**Application to Morley's theorem.** Theorem 3.3 shows that κ-categoricity implies all models are elementarily equivalent—the first step in Morley's proof. The full Morley theorem proceeds by showing that uncountable categoricity forces the absence of Vaughtian pairs, which forces every model to be prime over a strongly minimal set, which forces categoricity at all uncountable cardinals.

---

## 5. Discussion

### 5.1 What Is New

While all four main theorems are well-known classically, none had been formalized in Lean 4's Mathlib prior to this work. The key novelty is the *bridge character* of the results: they connect existing but disjoint Mathlib APIs (`IsComplete`, `ElementarilyEquivalent`, `Categorical`, `HenselianLocalRing`) into a coherent pipeline.

Specifically:

- **Theorem 3.1** fills a surprising gap: Mathlib had both `Theory.IsComplete` and `ElementarilyEquivalent` but no theorem connecting them. This is arguably the most fundamental result in model theory, and its absence meant that the completeness API was essentially disconnected from the semantic equivalence API.

- **Theorem 3.2** formalizes the transfer principle that underpins virtually all applications of model theory to algebra. While conceptually simple, its formal statement requires careful handling of the `Theory.model_iff` and `elementarilyEquivalent_iff` interfaces.

- **Theorem 3.3** chains the Łoś-Vaught test (already in Mathlib as `Cardinal.Categorical.isComplete`) with Theorem 3.1, demonstrating that the composition of existing results with new bridge theorems yields powerful consequences.

- **Theorem 3.4** provides the essential converse direction, showing that completeness is *necessary* for universal elementary equivalence, not merely sufficient.

### 5.2 Universe Issues

A significant technical challenge in the formalization is Mathlib's universe polymorphism. `Theory.IsComplete` is defined using `ModelsBoundedFormula` at a specific universe level, requiring careful universe management. Our helper lemmas (`realize_of_model`, `not_realize_of_model_not`) serve as universe-aware adaptors.

The universe constraint means our main theorems are stated for `Type`-valued models (universe 0). This is a deliberate design choice: the alternative—universe-polymorphic statements—would require additional assumptions about universe lifting that would complicate the statements without adding mathematical content. The key mathematical arguments are universe-independent; only the formal interface requires universe specificity.

### 5.3 Relationship to the Ax-Kochen-Ershov Program

The theorems formalized here constitute the *model-theoretic infrastructure* needed for the Ax-Kochen-Ershov theorem, but not the theorem itself. The full AKE theorem requires:

1. **A first-order language for valued fields**: extending the ring language with a valuation symbol or a divisibility predicate. This is a definitional task that builds on Mathlib's `FirstOrder.Language`.

2. **Completeness of the theory of henselian valued fields of equicharacteristic zero**: this is the core content of AKE, and uses the model-completeness of algebraically closed valued fields (a deep result requiring significant infrastructure).

3. **Application of our Theorem 3.1**: once completeness is established, elementary equivalence of models follows immediately from our bridge theorem.

Our henselian root uniqueness result (Theorem 3.5) addresses step 2 at the algebraic level, providing the key property that makes the back-and-forth argument work.

### 5.4 Relationship to Morley's Theorem

Similarly, our Theorem 3.3 is the *entry point* to Morley's categoricity theorem, not the full result. The full Morley theorem requires:

1. **Strongly minimal sets**: definable sets with no proper infinite/co-infinite definable subsets. These control the geometry of models of uncountably categorical theories.

2. **Vaughtian pairs**: pairs of models (M, N) with M ≺ N (elementary extension) and some definable set D with D(M) = D(N) but M ≠ N. The absence of Vaughtian pairs is the key structural property forced by uncountable categoricity.

3. **Baldwin-Lachlan characterization**: a countable complete theory is uncountably categorical iff it has no Vaughtian pairs and every model is prime over a strongly minimal set.

Our Theorem 3.3 establishes the first step: categoricity implies all models are elementarily equivalent (via completeness). The remaining steps require substantial new formalization.

### 5.5 Limitations

Our formalization establishes the formal scaffolding but does not yet include:

- The full Ax-Kochen-Ershov theorem (which requires defining valued fields as first-order structures).
- The full Morley categoricity theorem (which requires strongly minimal sets and Morley rank).
- The multivariate Hensel's lemma (which requires Jacobian determinants over local rings).

These are identified as concrete future directions.

---

## 6. Algorithms and Computation

While the core results are purely logical, they suggest algorithmic perspectives and computational implementations.

### 6.1 Theory Completeness Test

Given a finitely axiomatizable theory T and a decision procedure for T ⊨ᵇ φ, test completeness by checking the decision for a generating set of sentences. If T is complete, Theorem 3.1 guarantees all models are elementarily equivalent, enabling model-theoretic transfer.

In practice, completeness is often established via quantifier elimination: if every formula in the language L is equivalent modulo T to a quantifier-free formula, and T is complete for quantifier-free sentences (which can be checked by enumeration in many cases), then T is complete. Examples include the theory of dense linear orders without endpoints (DLO), the theory of algebraically closed fields of fixed characteristic (ACF_p), and the theory of real closed fields (RCF).

### 6.2 Henselian Root Refinement (Newton-Hensel Lifting)

Given a monic polynomial f over a henselian local ring R, an approximate root a₀ with f(a₀) ∈ 𝔪 and f'(a₀) a unit, iteratively compute a_{n+1} = aₙ − f(aₙ)/f'(aₙ). The sequence converges 𝔪-adically to the unique exact root guaranteed by Theorem 3.5.

The convergence rate is quadratic in the 𝔪-adic valuation: if v(f(aₙ)) ≥ 2ⁿ, then v(f(a_{n+1})) ≥ 2^{n+1}. This is the p-adic analogue of Newton's method, and the quadratic convergence means that the number of correct p-adic digits doubles at each step. In the integers modulo p^k, this translates to: starting from a root modulo p, after k steps we have a root modulo p^{2^k}.

### 6.3 Computational Complexity of Transfer

The transfer principle (Theorem 3.2) does not, in general, provide an effective procedure for transferring *proofs* between models—only the *truth* of sentences is preserved. However, in specific cases where quantifier elimination is effective (as in ACF, RCF, or p-adically closed fields), the transfer can be made computationally explicit, yielding decision procedures for one structure based on those for another.

This has practical applications in computer algebra systems, where questions about p-adic fields can sometimes be answered more efficiently by transferring to Laurent series fields and using the simpler arithmetic of formal power series.

---

## 7. Future Work

1. **Full Morley categoricity theorem:** Formalize strongly minimal sets, Vaughtian pairs, and the Baldwin-Lachlan characterization to complete the proof that categoricity at one uncountable cardinal implies categoricity at all.

2. **Ax-Kochen transfer for p-adic fields:** Define valued fields as first-order structures and formally prove that ℚₚ ≡ 𝔽ₚ((t)) for almost all p.

3. **Multivariate Hensel's lemma:** Extend the univariate uniqueness result to systems of equations using Jacobian determinants.

4. **Morley rank and degree:** Formalize the ordinal-valued rank on definable sets that controls the structure of models of uncountably categorical theories.

5. **Connections to stability theory:** Bridge from categoricity to Shelah's stability classification, formalizing the unstable formula hierarchy.

---

## References

[1] J. Ax and S. Kochen, "Diophantine problems over local fields I," *Amer. J. Math.*, vol. 87, pp. 605–630, 1965.

[2] J. Ax and S. Kochen, "Diophantine problems over local fields III," *Ann. of Math.*, vol. 83, pp. 437–456, 1966.

[3] J.T. Baldwin and A.H. Lachlan, "On strongly minimal sets," *J. Symbolic Logic*, vol. 36, pp. 79–96, 1971.

[7] W. Hodges, *A Shorter Model Theory*, Cambridge University Press, 1997.

[11] D. Marker, *Model Theory: An Introduction*, Springer, 2002.

[12] M. Morley, "Categoricity in power," *Trans. Amer. Math. Soc.*, vol. 114, pp. 514–538, 1965.

[14] Yu.L. Ershov, "On the elementary theory of maximal normed fields," *Dokl. Akad. Nauk SSSR*, vol. 165, pp. 21–23, 1965.

[15] S. Shelah, *Classification Theory and the Number of Non-Isomorphic Models*, 2nd ed., North-Holland, 1990.

[16] T. Wedhorn, *Adic Spaces*, lecture notes, 2012.
