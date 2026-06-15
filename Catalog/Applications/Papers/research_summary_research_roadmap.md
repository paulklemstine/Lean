# Compositional Invariant Transfer: Universal Finite Products for Dynamics, Entropy, and Security

## Abstract

We develop a compositional calculus of invariant-bearing transition systems and prove a universal finite product theorem with transfer meta-theorems. The central contribution is a formally verified framework where:
1. Finite indexed products of invariant systems admit the full categorical universal property (existence and uniqueness of mediating morphisms, extensionality).
2. Any subadditive real-valued functional on binary products automatically extends to finite-product subadditivity via induction through structural isomorphisms.
3. Well-founded termination of component systems implies well-founded termination of the product.
4. Security composition bounds (minimum-type) propagate from binary to finite products.

All results are machine-verified with zero use of unproven axioms beyond the standard foundation. The framework serves as a "factory" for compositional theorems: domain-specific bounds in thermodynamics, automata theory, and cryptography arise as one-line instantiations of the meta-theorem.

**Keywords:** categorical products, compositional semantics, invariant transfer, well-founded termination, security composition, tropical algebra

---

## 1. Introduction

### 1.1 Motivation

Compositional reasoning—deriving properties of complex systems from properties of their parts—is fundamental across mathematics and computer science. Despite the universality of this pattern, each domain has developed its own ad hoc composition machinery:

- **Thermodynamics:** Subadditivity of free energy/pressure under tensor products of state spaces [Ruelle 2004].
- **Cryptography:** Hybrid arguments and security reduction chains [Bellare-Rogaway 2006].
- **Automata theory:** Product automaton constructions with synchronization bounds [Volkov 2008].
- **Program verification:** Modular termination proofs via lexicographic/multiset orders [Dershowitz-Manna 1979].

A natural question arises: *is there a single formal framework from which all these domain-specific composition principles can be derived?*

### 1.2 Contributions

We answer affirmatively by developing the theory of **invariant-bearing transition systems** (`InvSystem`) and their finite products. Our contributions are:

1. **Finite product universal property** (Theorem 3.1): For any finite family of systems indexed by a finite type, the concrete product construction satisfies the categorical universal property (β-law, η-law, extensionality).

2. **Invariant transfer meta-theorem** (Theorem 4.1): Any isomorphism-invariant, binary-subadditive functional Φ : InvSystem → ℝ satisfies Φ(∏ᵢ Xᵢ) ≤ Σᵢ Φ(Xᵢ). The additive variant gives equality (Theorem 4.2).

3. **Product termination** (Theorem 5.1): If each component has a well-founded step relation and the index type is nonempty, the synchronous product step relation is well-founded.

4. **Security composition** (Theorem 6.1): For min-type security metrics satisfying binary min-monotonicity, the finite product security is bounded below by the component minimum.

5. **Derived corollaries**: Pressure bounds, entropy additivity, and quantitative security composition fall out as one-line instantiations.

### 1.3 Related Work

**Categorical systems theory.** Fong and Spivak [2019] develop a categorical framework for open systems using operads and decorated cospans. Our approach is more concrete—we work with explicit product constructions rather than abstract limits—but the universal property we prove is the classical one.

**Constructive cryptography.** Maurer [2011] proposes a compositional framework for cryptographic security based on abstract systems and simulators. Our invariant transfer theorem provides the quantitative backbone that such frameworks require.

**Formal verification of cryptography.** Barthe et al. [2009] develop EasyCrypt for machine-checked cryptographic proofs. Our framework operates at a higher level of abstraction, providing meta-theorems that could be instantiated within such tools.

---

## 2. Definitions and Notation

### 2.1 Invariant-Bearing Transition Systems

**Definition 2.1** (InvSystem). An *invariant-bearing transition system* is a quadruple (S, →, φ, mono) where:
- S is a type (the state space),
- → : S → S → Prop is a transition relation,
- φ : S → ℝ is a real-valued invariant,
- mono : ∀ s t, s → t ⟹ φ(t) ≤ φ(s) ensures φ is non-increasing.

**Definition 2.2** (InvHom). A *morphism* f : X → Y between invariant systems is a function f : X.S → Y.S preserving transitions: s →_X t implies f(s) →_Y f(t).

*Remark.* We deliberately omit an invariant-preservation condition from morphisms. This makes projections from products trivially morphisms and simplifies the universal property. The invariant transfer is handled by separate meta-theorems rather than being baked into the morphism notion.

**Definition 2.3** (InvIso). An *isomorphism* X ≅ Y consists of morphisms fwd : X → Y and bwd : Y → X satisfying fwd ∘ bwd = id and bwd ∘ fwd = id.

### 2.2 Products

**Definition 2.4** (Binary Product). For systems X, Y, the product X × Y has:
- State space: X.S × Y.S
- Transition: (s₁, s₂) → (t₁, t₂) iff s₁ →_X t₁ and s₂ →_Y t₂
- Invariant: φ(s₁, s₂) = φ_X(s₁) + φ_Y(s₂)

**Definition 2.5** (Finite Product). For a finite family (Xᵢ)_{i∈ι} with ι finite:
- State space: ∀ i, (Xᵢ).S (dependent function type)
- Transition: s → t iff ∀ i, s(i) →_{Xᵢ} t(i) (synchronous step)
- Invariant: φ(s) = Σᵢ φᵢ(s(i))

---

## 3. Universal Property of Finite Products

### 3.1 Construction

**Definition 3.1.** The *projection* πᵢ : ∏ⱼ Xⱼ → Xᵢ extracts the i-th component: πᵢ(s) = s(i).

**Definition 3.2.** The *lift* ⟨fᵢ⟩ : Z → ∏ᵢ Xᵢ, given morphisms fᵢ : Z → Xᵢ, is defined by ⟨fᵢ⟩(s)(i) = fᵢ(s).

### 3.2 Main Theorem

**Theorem 3.1** (finProd_universal). *For any finite family (Xᵢ)_{i∈ι} and system Z with morphisms fᵢ : Z → Xᵢ, there exists a unique morphism g : Z → ∏ᵢ Xᵢ such that πᵢ ∘ g = fᵢ for all i.*

*Proof sketch.* Existence: take g = ⟨fᵢ⟩. The β-law πᵢ ∘ ⟨fᵢ⟩ = fᵢ is immediate from the definitions. Uniqueness: if g' also satisfies πᵢ ∘ g' = fᵢ, then for any s and i, g'(s)(i) = πᵢ(g'(s)) = fᵢ(s) = ⟨fᵢ⟩(s)(i), so g' = ⟨fᵢ⟩ by function extensionality. □

**Theorem 3.2** (finProd_hom_ext). *Two morphisms g, h : Z → ∏ᵢ Xᵢ are equal iff πᵢ ∘ g = πᵢ ∘ h for all i.*

This extensionality principle is the workhorse for reasoning about product morphisms.

---

## 4. Invariant Transfer Meta-Theorem

### 4.1 Structural Isomorphisms

The inductive argument requires relating the finite product over Fin(n+1) to a binary product.

**Lemma 4.1** (finProdSuccIso). *For X : Fin(n+1) → InvSystem,*
$$\prod_{i \in \text{Fin}(n+1)} X_i \;\cong\; X_0 \times \prod_{j \in \text{Fin}(n)} X_{j+1}$$

**Lemma 4.2** (finProdSingleIso). *For X : Fin 1 → InvSystem,*
$$\prod_{i \in \text{Fin}(1)} X_i \;\cong\; X_0$$

### 4.2 The Subadditive Transfer

**Theorem 4.1** (subadditive_finProd_bound). *Let Φ : InvSystem → ℝ satisfy:*
1. *Binary subadditivity: Φ(X × Y) ≤ Φ(X) + Φ(Y) for all X, Y.*
2. *Isomorphism invariance: X ≅ Y implies Φ(X) = Φ(Y).*

*Then for any n ≥ 1 and X : Fin n → InvSystem:*
$$\Phi\left(\prod_{i=0}^{n-1} X_i\right) \leq \sum_{i=0}^{n-1} \Phi(X_i)$$

*Proof.* By induction on n.

**Base case** (n = 1): By Lemma 4.2, ∏ Xᵢ ≅ X₀. By isomorphism invariance, Φ(∏ Xᵢ) = Φ(X₀) = Σᵢ Φ(Xᵢ).

**Inductive step** (n → n+1): By Lemma 4.1:
$$\Phi\left(\prod_{i=0}^{n} X_i\right) = \Phi\left(X_0 \times \prod_{j=0}^{n-1} X_{j+1}\right) \leq \Phi(X_0) + \Phi\left(\prod_{j=0}^{n-1} X_{j+1}\right) \leq \Phi(X_0) + \sum_{j=0}^{n-1} \Phi(X_{j+1}) = \sum_{i=0}^{n} \Phi(X_i)$$

where the first equality uses isomorphism invariance, the first inequality uses binary subadditivity, and the second inequality uses the inductive hypothesis. □

### 4.3 The Additive Transfer

**Theorem 4.2** (additive_finProd_eq). *Under the same conditions but with binary equality Φ(X × Y) = Φ(X) + Φ(Y), the finite-product bound is an equality:*
$$\Phi\left(\prod_{i=0}^{n-1} X_i\right) = \sum_{i=0}^{n-1} \Phi(X_i)$$

*Proof.* Identical structure with ≤ replaced by =. □

### 4.4 Discussion

The power of Theorems 4.1–4.2 lies in their generality. To apply them, one need only verify:
1. A single binary inequality (or equality) for Φ on products.
2. Isomorphism invariance of Φ (which is automatic for any structurally defined quantity).

All finite-product bounds then follow automatically. This converts what would be n separate inductive proofs into n one-line instantiations.

---

## 5. Well-Founded Termination

**Theorem 5.1** (finProd_step_wf). *If ι is nonempty and each (Xᵢ).step is well-founded, then the synchronous product step on ∏ᵢ Xᵢ is well-founded.*

*Proof.* Fix any i₀ ∈ ι. The product step relation is a subrelation of the pullback of (X_{i₀}).step along projection to component i₀: if ∀i, s(i) →ᵢ t(i), then in particular s(i₀) →_{i₀} t(i₀).

By the subrelation principle, it suffices to show that the pullback relation is well-founded. This follows from InvImage.wf applied to the well-founded relation (X_{i₀}).step.

Concretely: given any set S of product states, its image under projection to component i₀ is a subset of (X_{i₀}).State. By well-foundedness of (X_{i₀}).step, this image has a minimal element m, which lifts to a product-minimal element of S. □

*Remark.* The nonemptiness hypothesis on ι is necessary. For empty ι, the product state space is a singleton and the step relation is total (vacuously), hence not well-founded.

---

## 6. Security Composition

### 6.1 The Min-Bound

**Theorem 6.1** (security_finProd_min). *Let sec : InvSystem → ℝ satisfy:*
1. *Binary min-bound: sec(X × Y) ≥ min(sec(X), sec(Y)).*
2. *Isomorphism invariance: X ≅ Y implies sec(X) = sec(Y).*

*Then for n ≥ 1:*
$$\text{sec}\left(\prod_{i=0}^{n-1} X_i\right) \geq \min_{0 \leq i < n} \text{sec}(X_i)$$

*Proof.* By induction on n, analogous to Theorem 4.1 but with ≥ and min replacing ≤ and +. □

### 6.2 Additive Entropy Security

**Corollary 6.2** (entropy_security_additive). *If security is measured by an additive entropy-based metric (Φ(X × Y) = Φ(X) + Φ(Y)), then:*
$$\Phi\left(\prod_{i=0}^{n-1} X_i\right) = \sum_{i=0}^{n-1} \Phi(X_i)$$

*This models the case of independent entropy sources composing additively.*

---

## 7. Applications

### 7.1 Pressure Bounds in Thermodynamic Formalism

**Corollary 7.1.** If pressure : InvSystem → ℝ is subadditive on binary products and isomorphism-invariant, then:
$$\text{pressure}\left(\prod_{i=0}^{n-1} X_i\right) \leq \sum_{i=0}^{n-1} \text{pressure}(X_i)$$

This is a one-line instantiation of Theorem 4.1 with Φ = pressure.

### 7.2 Cryptographic Hybrid Arguments

The hybrid lemma in cryptographic security proofs states that the distinguishing advantage between the first and last game in a sequence of n hybrids is at most the sum of adjacent advantages. In our framework:
- Each hybrid game Gᵢ is an InvSystem.
- The advantage functional Φ(G) = |Pr[G outputs 1] − 1/2| is subadditive on products.
- Theorem 4.1 gives: total advantage ≤ Σᵢ individual advantage.

### 7.3 Entropy Accumulation

In cryptographic key derivation from multiple independent entropy sources, the total extractable randomness is the sum of individual min-entropies. This is Corollary 6.2 applied to Φ = min-entropy, which is exactly additive on independent products.

### 7.4 Numerical Example

Consider 5 systems with invariant values [3.2, 1.7, 4.5, 2.1, 3.8]:
- Subadditive bound: Φ(∏ Xᵢ) ≤ 3.2 + 1.7 + 4.5 + 2.1 + 3.8 = 15.3
- Min security bound: sec(∏ Xᵢ) ≥ min(3.2, 1.7, 4.5, 2.1, 3.8) = 1.7
- Additive (equality): Φ(∏ Xᵢ) = 15.3

---

## 8. Computational Experiments

We provide Python implementations demonstrating the meta-theorems with concrete numerical examples. See `demo.py` for:
1. Verification of subadditive and additive bounds for random system families.
2. Security min-bound computation for composed cryptographic systems.
3. Visualization of how bounds scale with the number of components.

---

## 9. Discussion

### 9.1 Strengths
- **Universality**: One meta-theorem covers multiple domains.
- **Machine verification**: All proofs are formally verified.
- **Extensibility**: New domain-specific bounds require only verifying binary subadditivity.

### 9.2 Limitations
- **Synchronous products only**: Our current product requires all components to step simultaneously. Asynchronous products (where one component steps while others idle) would require a different well-foundedness argument.
- **No interaction**: The product construction models parallel, non-interacting systems. Feedback and communication channels require traced monoidal structure.

### 9.3 The n = 0 Issue
The subadditive transfer theorem requires n ≥ 1. For n = 0, the empty product is a terminal object (singleton state space), and Φ of the terminal object is not determined by the binary subadditivity hypothesis alone. This is mathematically correct: the empty product is a unit for the monoidal structure, and its Φ-value is a free parameter.

---

## 10. Future Work

See FUTURE_DIRECTIONS.md for detailed breakthrough opportunities. Key priorities:
1. Finite coproducts for adversarial composition.
2. Traced monoidal structure for feedback systems.
3. Entropy-pressure duality via tropicalization.
4. Černý-type synchronization bounds.
5. Compositional security reductions with quantitative loss tracking.

---

## References

1. Bellare, M., Rogaway, P. "The security of triple encryption and a framework for code-based game-playing proofs." EUROCRYPT 2006.
2. Dershowitz, N., Manna, Z. "Proving termination with multiset orderings." CACM 1979.
3. Fong, B., Spivak, D.I. "An invitation to applied category theory." Cambridge 2019.
4. Maurer, U. "Constructive cryptography—a new paradigm for security definitions and proofs." TOSCA 2011.
5. Ruelle, D. "Thermodynamic Formalism." Cambridge 2004.
6. Volkov, M. "Synchronizing automata and the Černý conjecture." LATA 2008.
7. Barthe, G. et al. "Computer-aided security proofs for the working cryptographer." CRYPTO 2011.
