# Composable Theorem Transfer: A Formal Framework for Cross-Domain Certificate Transport

## Abstract

We present a formally verified framework for compositional transfer of certified properties across chains of theory morphisms. Given a category of research theories — types equipped with ℕ-valued invariants — and structure-preserving morphisms between them, we define a notion of *predicate preservation* and prove that it is closed under composition. This yields a calculus of *certified transfers*: reusable, composable combinators that transport proof-bearing properties from one mathematical domain to another without reproving from scratch. We instantiate the framework with concrete theories (Height, Cell, Dimension, Stability, Capacity) drawn from an existing catalog of cross-domain bridges, demonstrating end-to-end certified property transport through four-step pipelines. All results are machine-verified with zero uses of `sorry`.

**Keywords**: theorem transport, certified abstraction, functorial semantics, cross-domain synthesis, proof reuse, predicate preservation

## 1. Introduction

### 1.1 Motivation

Modern mathematics and computer science are replete with structural analogies: generalization bounds in machine learning resemble covering number estimates in combinatorics; Myhill-Nerode congruences in automata theory mirror state compression in quantum verification; spectral gaps in graph theory control clustering behavior that parallels hierarchical structures in cryptographic protocols.

Despite these apparent connections, transferring a theorem from one domain to another typically requires reproving it from scratch. Each field has its own definitions, notation, and accumulated infrastructure. The cost of translation is often comparable to the cost of the original proof.

We address this problem by constructing a *compositional* framework for certified theorem transport. The key contributions are:

1. **PreservesProperty**: A formal predicate capturing when a theory morphism transports one certified property to another.
2. **Composition theorem**: If φ preserves P ⇒ Q and ψ preserves Q ⇒ R, then φ;ψ preserves P ⇒ R.
3. **CertifiedTransfer**: A bundled structure combining a morphism with its preservation witness, equipped with composition, identity, and associativity.
4. **Concrete instantiations**: End-to-end certified transport through multi-step pipelines of catalog theories.

### 1.2 Related Work

The idea of transporting mathematical structure across morphisms is classical in category theory. Functors preserve composition and identities; natural transformations relate different translation strategies. Our framework can be viewed as a lightweight instantiation of these ideas, specialized to the setting where:
- Objects are types with ℕ-valued invariants
- Morphisms are monotone maps
- The "functor" acts on predicates via pushforward

More closely related is the work on *transfer principles* in model theory (Abraham Robinson, 1960s), where statements true in one structure are transferred to another via elementary embeddings. Our setting is simpler (no first-order syntax) but compositional in a way that classical transfer principles are not.

In the formal verification community, *parametricity* and *abstraction theorems* (Reynolds, 1983; Wadler, 1989) transfer properties across type abstractions. Our work can be seen as an analogous development for mathematical theories rather than programming language types.

## 2. Definitions and Notation

### 2.1 Research Theories

A **research theory** T consists of:
- A carrier type `T.Carrier : Type`
- An invariant function `T.Inv : T.Carrier → ℕ`

The invariant measures "depth," "complexity," "dimension," or any other quantitative certificate relevant to the domain.

### 2.2 Theory Morphisms

A **theory morphism** φ : T₁ → T₂ consists of:
- A function `φ.toFun : T₁.Carrier → T₂.Carrier`
- A monotonicity witness `φ.monotone_inv : ∀ x, T₁.Inv x ≤ T₂.Inv (φ.toFun x)`

Morphisms compose associatively with a two-sided identity (established in prior work in `TheoryMorphisms.lean`).

### 2.3 Predicate Preservation

**Definition 2.1** (PreservesProperty). A theory morphism φ : T₁ → T₂ *preserves* predicate P to Q (written `PreservesProperty φ P Q`) if:

```
∀ x : T₁.Carrier, P x → Q (φ.toFun x)
```

**Definition 2.2** (CertifiedTransfer). A *certified transfer* from (T₁, P) to (T₂, Q) is a pair (φ, h) where φ : TheoryHom T₁ T₂ and h : PreservesProperty φ P Q.

### 2.4 Depth Predicates

**Definition 2.3** (HasDepthAtLeast). For a theory T and n : ℕ, we define:
```
HasDepthAtLeast T n x ≡ n ≤ T.Inv x
```

## 3. Main Results

### 3.1 The Composition Theorem

**Theorem 3.1** (TheoryHom.preserves_comp). Let φ : T₁ → T₂ and ψ : T₂ → T₃ be theory morphisms, and let P, Q, R be predicates on T₁.Carrier, T₂.Carrier, T₃.Carrier respectively. If φ preserves P ⇒ Q and ψ preserves Q ⇒ R, then the composite morphism φ;ψ preserves P ⇒ R.

*Proof sketch*: Fix x : T₁.Carrier with P x. By the preservation hypothesis for φ, we obtain Q (φ.toFun x). By the preservation hypothesis for ψ applied to φ.toFun x, we obtain R (ψ.toFun (φ.toFun x)). Since (φ;ψ).toFun = ψ.toFun ∘ φ.toFun by definition, this gives R ((φ;ψ).toFun x). □

**Theorem 3.2** (TheoryHom.transport_theorem_comp). The Set.MapsTo variant: if φ maps S₁ into S₂ and ψ maps S₂ into S₃, then φ;ψ maps S₁ into S₃.

*Proof*: Immediate from MapsTo composition. □

### 3.2 Identity and Variance Laws

**Theorem 3.3** (TheoryHom.preserves_id). The identity morphism preserves any predicate P to itself.

**Theorem 3.4** (PreservesProperty.weaken_source). If φ preserves P ⇒ Q and P' implies P, then φ preserves P' ⇒ Q. (Contravariance in source.)

**Theorem 3.5** (PreservesProperty.strengthen_target). If φ preserves P ⇒ Q and Q implies Q', then φ preserves P ⇒ Q'. (Covariance in target.)

These laws establish that PreservesProperty behaves as a profunctor in the source and target predicate arguments.

### 3.3 Bundled Composition

**Definition 3.6** (CertifiedTransfer.comp). The composition of certified transfers:
```
(T₁, P) →ct₁ (T₂, Q) →ct₂ (T₃, R)  ⟹  (T₁, P) →ct₁;ct₂ (T₃, R)
```

**Theorem 3.7** (CertifiedTransfer.comp_assoc). Composition of certified transfers is associative (on underlying functions):
```
((ct₁ ∘ ct₂) ∘ ct₃).hom.toFun = (ct₁ ∘ (ct₂ ∘ ct₃)).hom.toFun
```

### 3.4 Depth Preservation

**Theorem 3.8** (TheoryHom.preserves_depth). Every theory morphism preserves HasDepthAtLeast n for all n.

*Proof*: From the monotonicity witness φ.monotone_inv: if n ≤ T₁.Inv x, then n ≤ T₁.Inv x ≤ T₂.Inv (φ.toFun x). □

**Corollary 3.9** (depth_transfer_comp). Depth-n certificates survive arbitrary chains of morphism composition.

### 3.5 Pushforward and Functoriality

**Definition 3.10** (TheoryHom.pushforward). The pushforward of P along φ:
```
φ.pushforward P y ≡ ∃ x, P x ∧ φ.toFun x = y
```

**Theorem 3.11** (TheoryHom.preserves_pushforward). Every morphism preserves P to its own pushforward.

**Theorem 3.12** (TheoryHom.pushforward_comp_subset). The pushforward of a composition refines the iterated pushforward:
```
(φ;ψ).pushforward P y → ψ.pushforward (φ.pushforward P) y
```

### 3.6 Existential Transport

**Theorem 3.13** (CertifiedTransfer.transport_exists). If there exists a P-certified object in T₁, then there exists a Q-certified object in T₂.

**Theorem 3.14** (transported_certified_property). The flagship instantiation: given morphisms φ, ψ and an object x with P x, plus preservation witnesses for φ and ψ, the composite image satisfies R.

## 4. Catalog Instantiations

### 4.1 Theory Instances

We work with five concrete theories from the existing catalog:

| Theory | Carrier | Invariant | Domain |
|--------|---------|-----------|--------|
| HeightTheory | ℕ | id | Arithmetic complexity |
| CellTheory | ℕ | n·(n+1) | Combinatorial cell decomposition |
| DimensionTheory | ℕ | n+1 | Geometric dimension |
| StabilityTheory | ℕ | id | Contraction stability |
| CapacityTheory | ℕ | id | Closure capacity |

### 4.2 Concrete Bridges

- **heightToCellMorphism**: Height → Cell, toFun = id, monotonicity: h ≤ h·(h+1)
- **heightToDimension**: Height → Dimension, toFun = id, monotonicity: h ≤ h+1
- **dimensionToStability**: Dimension → Stability, toFun = n ↦ n+1
- **stabilityToCapacity**: Stability → Capacity, toFun = id

### 4.3 Verified Transfer Results

**Theorem 4.1** (height_to_cell_preserves). The height-to-cell morphism preserves ArithmeticallySignificant (h ≥ 2) to NontrivialCellComplexity (h·(h+1) ≥ 2).

**Theorem 4.2** (pipeline_preserves_depth2). The Height → Dimension → Stability pipeline preserves depth-2 certificates.

**Theorem 4.3** (dual_path_transfer). For any n, both the height→cell and height→stability paths preserve depth-n certificates.

**Theorem 4.4** (three_theory_chain_transfer). The full Height → Stability → Capacity chain preserves all depth-n certificates.

**Theorem 4.5** (height5_cell_transfer). Concrete instantiation: height 5 maps to nontrivial cell complexity 30.

**Theorem 4.6** (height3_pipeline_transfer). Concrete instantiation: height 3 maps to stability depth ≥ 2 through the full pipeline.

## 5. Algorithms

### 5.1 Bridge Composition Algorithm

```
Algorithm: ComposeTransfer
Input: CertifiedTransfer ct₁ : (T₁, P) → (T₂, Q)
       CertifiedTransfer ct₂ : (T₂, Q) → (T₃, R)
Output: CertifiedTransfer : (T₁, P) → (T₃, R)

1. Compose underlying morphisms: φ := ct₁.hom ; ct₂.hom
2. Compose preservation witnesses:
   For any x with P(x):
     a. Apply ct₁.preserves(x) to get Q(ct₁.hom.toFun(x))
     b. Apply ct₂.preserves(ct₁.hom.toFun(x)) to get R(φ.toFun(x))
3. Return (φ, composed_witness)
```

**Time complexity**: O(1) for composition construction. The cost of *evaluating* the composed morphism on an object is the sum of the costs of the individual morphisms.

### 5.2 Chain Search Algorithm (Proposed)

```
Algorithm: FindTransferChain
Input: Source theory T_s, target theory T_t, predicate P, catalog of bridges
Output: CertifiedTransfer from (T_s, P) to (T_t, Q) for some Q, or ⊥

1. Build directed graph G where nodes are theories, edges are bridges
2. BFS/DFS from T_s to T_t in G
3. If path found: compose all bridges along the path
4. Compute pushforward predicate Q along the composed morphism
5. Return the CertifiedTransfer
```

**Time complexity**: O(|V| + |E|) for path search, O(k) for k-step composition.

## 6. Discussion

### 6.1 Strengths

The framework achieves genuine compositionality: each certified bridge, once verified, can be combined with any compatible bridge without additional proof effort. This transforms the catalog of domain-specific results into a network where new connections arise combinatorially.

The certification requirement ensures soundness. Unlike informal analogies, every property transfer is backed by a machine-checkable proof chain.

### 6.2 Limitations

The ℕ-valued invariant is a deliberate simplification. Many natural domain invariants are real-valued, lattice-valued, or live in more complex ordered structures. Extending to ℝ-valued or lattice-valued invariants is straightforward in principle but requires additional Mathlib infrastructure for ordered maps.

The current catalog of concrete theories uses ℕ as the carrier type for all instances. This demonstrates the framework's mechanics but understates its intended generality. A mature deployment would use rich domain-specific carrier types (e.g., neural network architectures, automata, algebraic varieties) with genuinely informative invariants.

### 6.3 Connection to Category Theory

The framework constitutes a category where:
- Objects are pairs (T, P) of a research theory and a predicate
- Morphisms are CertifiedTransfers
- Composition is CertifiedTransfer.comp
- Identity is CertifiedTransfer.id

Associativity and identity laws hold definitionally (on underlying functions), as verified formally.

## 7. Future Work

1. **Category of Research Theories**: Prove full categorical laws including isomorphisms and equivalences.
2. **Adjoint Transport**: Identify Galois connections between theories enabling bidirectional transfer.
3. **Automated Bridge Search**: Formalize graph-theoretic path search over theory catalogs.
4. **Invariant Compression**: Connect to Nerode minimization, spectral rank reduction, and network pruning.
5. **Robustness Logic**: Define modal logics for properties stable under classes of morphisms.

## 8. References

1. S. Mac Lane. *Categories for the Working Mathematician*. Springer, 1971.
2. J. Reynolds. "Types, Abstraction and Parametric Polymorphism." *IFIP*, 1983.
3. P. Wadler. "Theorems for free!" *FPCA*, 1989.
4. A. Robinson. *Introduction to Model Theory and the Metamathematics of Algebra*. North-Holland, 1963.
