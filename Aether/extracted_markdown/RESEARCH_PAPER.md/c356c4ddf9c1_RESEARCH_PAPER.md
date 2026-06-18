# Semantic Bundles: A Formal Theory of Meaning Divergence in Isomorphic Structures

## Abstract

We introduce **semantic bundles** — algebraic structures equipped with interpretation maps into semantic spaces — and develop a formal theory distinguishing algebraic from semantic isomorphism. Our central result, the **Separation Theorem**, proves constructively that algebraically isomorphic structures can be semantically non-isomorphic: the notion of "meaning" captured by labeling is irreducible to algebraic structure. We establish that semantic isomorphism strictly refines algebraic isomorphism, characterize when the two coincide (the **Rigidity Theorem**), and introduce computable semantic invariants (diversity, spectrum) that detect semantic structure invisible to algebraic analysis. All results are machine-verified.

**Keywords**: decorated magma, semantic isomorphism, algebraic invariant, rigidity, transfer principle, Burnside orbit counting

---

## 1. Introduction

A fundamental observation in mathematics is that isomorphic structures are "the same" from the viewpoint of abstract algebra. The transfer principle allows us to move results freely between isomorphic objects. Yet mathematicians routinely distinguish between isomorphic structures based on context, interpretation, or "meaning" — consider the difference between ℤ/12ℤ as a model of clock arithmetic versus modular arithmetic in cryptography.

We formalize this distinction by introducing **semantic bundles**: pairs consisting of an algebraic structure and an interpretation function. We then define two levels of equivalence — algebraic isomorphism (ignoring interpretations) and semantic isomorphism (preserving interpretations) — and prove that the gap between them is genuine and irreducible.

### 1.1 Related Work

The transfer principle in model theory (cf. Keisler's ultrapower theorem) establishes that elementarily equivalent structures satisfy the same first-order sentences. Our work shows that semantic content — formalized as a labeling function — lies outside the scope of such transfer. This connects to philosophical work on the "intended interpretation" problem in mathematical structuralism (Benacerraf, Shapiro) and to Hofstadter's work on analogical reasoning in the Copycat architecture, where structural isomorphisms between domains must be augmented with pragmatic "slippage" to capture meaningful analogies.

### 1.2 Contributions

1. **Definition**: The semantic bundle (decorated magma) as a mathematical object.
2. **Separation Theorem**: Constructive proof that AlgIso ≠ SemIso.
3. **Rigidity Theorem**: Complete characterization of when AlgIso = SemIso.
4. **Semantic Invariants**: Diversity and spectrum as computable semantic quantities.
5. **Truth-Meaning Gap**: Formal proof that truth preservation ≠ meaning preservation.
6. **Non-Algebraicity of Diversity**: Proof that semantic diversity is not an algebraic invariant.

---

## 2. Definitions

### 2.1 Decorated Magma

**Definition 2.1** (Decorated Magma). A *decorated magma* over types α and β is a triple (α, ⊕, ℓ) where:
- ⊕ : α × α → α is a binary operation (the *algebraic structure*)
- ℓ : α → β is a function (the *semantic labeling*)

We denote the set of decorated magmas over (α, β) by DM(α, β).

### 2.2 Algebraic and Semantic Isomorphism

**Definition 2.2** (Algebraic Isomorphism). Two decorated magmas D₁ = (α, ⊕₁, ℓ₁) and D₂ = (α, ⊕₂, ℓ₂) are *algebraically isomorphic* if there exists a bijection φ : α ≃ α such that:

    φ(x ⊕₁ y) = φ(x) ⊕₂ φ(y)   for all x, y ∈ α

**Definition 2.3** (Semantic Isomorphism). D₁ and D₂ are *semantically isomorphic* if there exists φ : α ≃ α satisfying both the algebraic condition AND:

    ℓ₁(x) = ℓ₂(φ(x))   for all x ∈ α

### 2.3 Semantic Rigidity

**Definition 2.4** (Semantic Rigidity). A decorated magma D is *semantically rigid* if the identity is the only automorphism of its underlying operation:

    ∀ φ : α ≃ α, (∀ x y, φ(x ⊕ y) = φ(x) ⊕ φ(y)) → φ = id

### 2.4 Semantic Invariants

**Definition 2.5** (Semantic Diversity). For a finite decorated magma D = (α, ⊕, ℓ) with α finite:

    div(D) = |{ℓ(a) : a ∈ α}|

**Definition 2.6** (Semantic Spectrum). The multiset of label frequencies:

    spec(D) = ⟨|ℓ⁻¹(b)| : b ∈ Im(ℓ)⟩

---

## 3. Main Results

### 3.1 The Refinement Theorem

**Theorem 3.1** (Semantic Refinement). *Semantic isomorphism implies algebraic isomorphism.*

*Proof.* If φ witnesses SemIso(D₁, D₂), then in particular φ preserves the operation, witnessing AlgIso(D₁, D₂). □

This establishes SemIso as a refinement of AlgIso. The converse fails:

### 3.2 The Separation Theorem

**Theorem 3.2** (Separation). *There exist decorated magmas D₁, D₂ ∈ DM(Fin 2, Fin 2) such that AlgIso(D₁, D₂) and ¬SemIso(D₁, D₂).*

*Proof sketch.* Let ⊕ = XOR (addition mod 2). Define:
- D₁ = (Fin 2, ⊕, id)
- D₂ = (Fin 2, ⊕, x ↦ 1-x)

**AlgIso**: The identity bijection preserves XOR.

**¬SemIso**: Any automorphism φ of (Fin 2, XOR) must satisfy φ(0) = φ(0 ⊕ 0) = φ(0) ⊕ φ(0) = 0 (since x ⊕ x = 0 in Fin 2). So φ(0) = 0, and since φ is a bijection on {0,1}, we get φ = id. But then ℓ₁(0) = 0 ≠ 1 = ℓ₂(0), contradiction. □

### 3.3 The Rigidity Theorem

**Theorem 3.3** (Rigidity). *Let D₁ be a semantically rigid decorated magma with the same operation as D₂. Then:*
- *SemIso(D₁, D₂) ⟹ ℓ₁ = ℓ₂*
- *ℓ₁ = ℓ₂ ⟹ SemIso(D₁, D₂)*

*Proof.* For the forward direction: if φ witnesses SemIso and D₁.op = D₂.op, then φ is an automorphism of D₁'s operation. By rigidity, φ = id. Then the semantic condition gives ℓ₁ = ℓ₂.

For the reverse: if ℓ₁ = ℓ₂ and ops are equal, the identity witnesses SemIso. □

**Corollary 3.4** (Maximum Diversity for Rigid Structures). *If D₁ is rigid and ℓ₁ ≠ ℓ₂, then ¬SemIso(D₁, D₂).*

### 3.4 Transfer Invariance

**Theorem 3.5** (Transfer). *Any isomorphism-invariant property of operations is preserved by algebraic isomorphism. Formally: if P is an algebraic property such that conjugation by any bijection preserves P, then AlgIso(D₁, D₂) ∧ P(D₁.op) implies P(D₂.op).*

### 3.5 Semantic Properties Do Not Transfer

**Theorem 3.6** (Semantic Non-Transfer). *There exists a semantic property P such that P(D₁) ∧ AlgIso(D₁, D₂) ∧ ¬P(D₂).*

*Proof.* Take P(D) := (D.label(0) = 0). This holds for D_id but fails for D_swap, even though they are algebraically isomorphic. □

### 3.6 The Truth-Meaning Gap

**Theorem 3.7** (Truth Implies Meaning). *Meaning preservation implies truth preservation for any truth predicate.*

**Theorem 3.8** (Truth ≠ Meaning). *There exist D₁, D₂, φ, and a truth predicate where φ is truth-preserving but not meaning-preserving.*

*Proof.* Use D_id, D_swap, φ = id, truth = (fun _ => True). Truth is trivially preserved, but meaning is not (label mismatch at 0). □

### 3.7 Semantic Diversity is Non-Algebraic

**Theorem 3.9** (Non-Algebraicity of Diversity). *Algebraic isomorphism does not preserve semantic diversity: there exist AlgIso(D₁, D₂) with div(D₁) ≠ div(D₂).*

*Proof.* On Fin 2 with the zero operation: D₁ = (const 0, id) has div = 2, while D₂ = (const 0, const 0) has div = 1. They are algebraically isomorphic via the identity. □

### 3.8 Semantic Invariants

**Theorem 3.10** (Diversity Invariance). *Semantic isomorphism preserves semantic diversity.*

**Theorem 3.11** (Spectrum Invariance). *Semantic isomorphism preserves the semantic spectrum.*

*Proof sketch for spectrum.* Given φ witnessing SemIso, we have ℓ₁ = ℓ₂ ∘ φ. Since φ is a bijection, the image multisets of ℓ₁ and ℓ₂ are permutations of each other, and for each label value b, the fibers ℓ₁⁻¹(b) and ℓ₂⁻¹(b) have equal cardinality (as φ maps one bijectively to the other). □

---

## 4. Connection to Oracle Truth Preservation

The catalog contains theorems establishing that oracles preserve truth (`oracle_preserves_truth`, `grav_oracle_preserves_truth`). Our Truth-Meaning Gap (Theorems 3.7-3.8) provides the theoretical framework for understanding these results: an oracle is a truth-preserving map that operates at the structural level. Our results prove that such maps cannot, in general, preserve the semantic content of the structures they act on.

This connects to Hofstadter's Copycat architecture: an analogy-making system must not only find structural correspondences (algebraic isomorphisms) but also evaluate semantic compatibility — whether the labels "make sense" under the correspondence. Our separation theorem proves that this semantic evaluation is a genuinely additional computational task, not reducible to structural matching.

---

## 5. The Isomorphism of Isomorphisms

Given two algebraically isomorphic decorated magmas, the space of algebraic isomorphisms between them forms a torsor for the automorphism group. We further stratify this space by **semantic compatibility**: an algebraic isomorphism φ is semantically compatible if it also preserves labels.

**Definition 5.1** (Semantic Compatibility). An equivalence φ : α ≃ α is semantically compatible with (D₁, D₂) if it preserves both the operation and the labeling.

**Theorem 5.2.** SemIso(D₁, D₂) iff there exists a semantically compatible algebraic isomorphism.

This gives a precise meaning to "isomorphism of isomorphisms": we classify the isomorphisms themselves by their semantic content, creating a higher-order structure on the space of structural correspondences.

---

## 6. Algorithms

### 6.1 Semantic Isomorphism Testing

For finite decorated magmas on n elements:
1. Enumerate all n! permutations (or use graph isomorphism techniques).
2. For each permutation, check operation preservation.
3. For surviving permutations, check label preservation.
4. Report SemIso iff any permutation passes both checks.

Complexity: O(n! · n²) in the naive case, reducible to graph isomorphism complexity via encoding.

### 6.2 Semantic Invariant Computation

Computing diversity and spectrum:
1. Compute Im(ℓ) = {ℓ(a) : a ∈ α}.
2. Diversity = |Im(ℓ)|.
3. For each b ∈ Im(ℓ), compute |ℓ⁻¹(b)|.
4. Spectrum = multiset of these cardinalities.

Complexity: O(n log n) with hash maps.

---

## 7. Future Directions

1. **Complete Semantic Invariants**: Is the spectrum complete? Characterize exactly when two decorated magmas have the same spectrum but are semantically non-isomorphic.

2. **Semantic Bundles over Groups**: When the algebraic structure is a group, the automorphism group acts naturally on labelings. Burnside's lemma gives the number of orbits (= semantically distinct structures). Extend to profinite groups and continuous labelings.

3. **Semantic Entropy**: Define H(D) = log₂(number of semantic equivalence classes of relabelings of D). Study its properties as a measure of "semantic capacity."

4. **Categorical Semantics**: Formalize the category of semantic bundles and study its categorical properties (limits, colimits, adjunctions with the forgetful functor to magmas).

5. **Computational Complexity**: What is the complexity of the semantic isomorphism problem? It reduces to a constrained version of graph isomorphism — is it equivalent, or strictly easier/harder?

---

## 8. Conclusion

The semantic bundle framework provides a precise mathematical answer to the question "when do isomorphic structures mean the same thing?" The answer is: exactly when the isomorphism respects the interpretation, which for rigid structures means exactly when the interpretations are identical. The gap between structure and meaning is not philosophical vagueness but a theorem with a constructive proof.

---

## References

1. Benacerraf, P. (1965). "What Numbers Could Not Be." *The Philosophical Review*, 74(1), 47-73.
2. Hofstadter, D. (1995). *Fluid Concepts and Creative Analogies*. Basic Books.
3. Mac Lane, S. (1998). *Categories for the Working Mathematician*. Springer.
4. The Univalent Foundations Program (2013). *Homotopy Type Theory*. Institute for Advanced Study.
