# Closure-Circuit Duality: Canonical Residual Bases and Monotone Circuit Reconstruction

## Abstract

We establish a duality between finite closure systems and monotone Boolean circuits. Given any closure operator on a finite type with bounded dependency rank, we prove the existence of a unique *canonical residual basis* — the collection of all minimal support sets for each element — and show that this basis yields a monotone DNF circuit that computes the closure operator exactly. The main theorem, which we call the Finite Closure-Circuit Duality, packages the existence, correctness, and uniqueness of this canonical representation into a single statement. All results have been machine-verified in the Lean 4 proof assistant using the Mathlib library. We discuss applications to database theory, circuit complexity, and the emerging connection between closure systems and the geometry of neural network loss landscapes.

**Keywords:** closure operators, monotone circuits, canonical basis, residual generators, DNF reconstruction, formal verification

---

## 1. Introduction

Closure operators are among the most ubiquitous structures in mathematics. They arise in topology (topological closure), algebra (subalgebra generation), logic (deductive closure), database theory (attribute closure under functional dependencies), and combinatorics (matroid closure). Despite this universality, a fundamental structural question has received surprisingly little attention in the formal verification literature: *given a closure operator on a finite domain, what is its minimal canonical description, and how does that description relate to computation?*

This paper answers both questions. We prove that every closure operator on a finite type admits a unique canonical residual basis — a finite collection of *(target, support)* pairs capturing the minimal reasons for membership in the closure — and that this basis can be mechanically compiled into a monotone Boolean circuit in disjunctive normal form (DNF) that computes the closure exactly.

The uniqueness result is analogous to the Myhill-Nerode theorem for regular languages: just as every regular language has a unique minimal deterministic automaton, every finite closure operator has a unique minimal residual basis. We make this analogy precise through the notion of *residual equivalence*, an equivalence relation on elements that identifies those with identical closure profiles.

### 1.1 Contributions

1. **Minimal support theory** (§4): We prove that every element in a closure (applied to a finite set) has a minimal support, and characterize closure membership via the existence of such supports.
2. **Canonical basis existence and uniqueness** (§5): We construct the canonical residual basis and prove it is the unique basis satisfying the minimality and completeness conditions.
3. **Circuit reconstruction** (§6): We define monotone Boolean circuits, prove evaluation monotonicity, and construct a DNF circuit that provably computes the closure.
4. **Main duality theorem** (§7): We combine all results into a single duality statement with existence, correctness, and uniqueness.
5. **Full formal verification** (§8): All results are machine-checked in Lean 4 with Mathlib.

### 1.2 Related Work

The connection between closure systems and implications has a long history in formal concept analysis (FCA), where the *canonical basis* of Duquenne and Guigues (1986) plays a central role. Our canonical residual basis differs from the Duquenne-Guigues basis in that we work at the level of individual element supports rather than set implications, making the connection to circuits more direct.

Monotone circuit complexity has been extensively studied since Razborov's superpolynomial lower bounds (1985). Our work does not address lower bounds but instead establishes an *exact correspondence* between closure operators and monotone DNF circuits.

The application to neural network optimization landscapes is motivated by recent work connecting loss landscape topology to learning dynamics, including the study of mode connectivity, basin volume estimation, and the role of symmetry in creating equivalent minima.

---

## 2. Preliminaries

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). A *closure operator* on a type α is a function cl : 𝒫(α) → 𝒫(α) satisfying:
- *Extensivity:* S ⊆ cl(S) for all S
- *Monotonicity:* S ⊆ T implies cl(S) ⊆ cl(T)
- *Idempotency:* cl(cl(S)) = cl(S) for all S

This is formalized in `IsClosureOperator` at @file[Catalog/Bridges/ClosureCircuitDuality.lean].

### 2.2 Closure Presentations

**Definition 2.2** (Closure Presentation). A *closure presentation* is a finite set P of rules (A, x) where A is a finite set of premises and x is a conclusion element. A set S is *closed under P* if for every rule (A, x) ∈ P with A ⊆ S, we have x ∈ S.

**Definition 2.3** (Generated Closure). The closure of S under presentation P is the intersection of all closed supersets of S:

$$\text{cl}_P(S) = \bigcap \{ T \supseteq S \mid T \text{ is closed under } P \}$$

This is `GeneratedClosure` in the formalization.

**Definition 2.4** (Bounded Rank). A closure operator cl has *rank bounded by r* if there exists a presentation P such that every rule has at most r premises and P generates cl.

### 2.3 Residual Equivalence

**Definition 2.5** (Residual Equivalence). Two elements x, y are *residually equivalent* under cl if for every set S, x ∈ cl(S) ↔ y ∈ cl(S). This is an equivalence relation (`residualEquivalent_equiv` in the formalization).

---

## 3. Generated Closures Are Closure Operators

**Theorem 3.1** (`generatedClosure_isClosureOperator`). For any closure presentation P, the generated closure cl_P is a closure operator.

*Proof sketch.* Extensivity is immediate from the definition as an intersection of supersets. Monotonicity follows because if S ⊆ T, then every closed superset of T is also a closed superset of S, so the intersection for T is taken over a subset of the sets for S. Idempotency requires showing that cl_P(S) is itself closed under P — which follows by "pushing the quantifier through the intersection" — and then applying the fact that cl_P(cl_P(S)) is the smallest closed superset of cl_P(S), which is cl_P(S) itself. □

The formal proof decomposes this into three lemmas:
- `generatedClosure_extensive` (extensivity)
- `generatedClosure_monotone` (monotonicity)  
- `generatedClosure_idempotent` (idempotency, requiring `generatedClosure_closedUnder`)

---

## 4. Minimal Support Theory

### 4.1 Minimal Supports

**Definition 4.1** (Minimal Support). A finite set A is a *minimal support* for element x under cl if:
1. x ∈ cl(A), and
2. For every proper subset B ⊂ A, x ∉ cl(B).

This is `IsMinimalSupport` in the formalization.

**Theorem 4.2** (`minimal_support_exists`). Let cl be a closure operator and let x ∈ cl(S) for some finite set S. Then there exists A ⊆ S such that A is a minimal support for x.

*Proof sketch.* By well-founded induction on the cardinality of finite subsets. Given x ∈ cl(S), either S is already a minimal support (no proper subset generates x), or there exists a proper subset S' ⊂ S with x ∈ cl(S'). In the latter case, recurse on S'. Since finite sets cannot decrease indefinitely in cardinality, the process terminates. □

This is a Noetherian descent argument. The formal proof uses `Finset.strongInduction` to perform strong induction on finite sets.

### 4.2 Closure Characterization

**Theorem 4.3** (`closure_iff_contains_minimal_support`). For a closure operator cl, element x, and set S:

$$x \in \text{cl}(S) \iff \exists A \in \text{minSupp}(x),\; A \subseteq S$$

where minSupp(x) is the set of all minimal supports for x.

*Proof sketch.* (⇒) If x ∈ cl(S) and S is finite (as it is in the finite-type setting), Theorem 4.2 gives a minimal support A ⊆ S. Since A ⊆ S, we have A ⊆ S as required. (⇐) If A is a minimal support with A ⊆ S, then x ∈ cl(A) ⊆ cl(S) by monotonicity. □

---

## 5. The Canonical Residual Basis

### 5.1 Construction

**Definition 5.1** (Residual Generator). A *residual generator* is a pair g = (target, support) consisting of a target element and a finite support set.

**Definition 5.2** (Canonical Basis). The *canonical residual basis* of cl is:

$$\mathcal{B}(cl) = \{ (x, A) \mid A \in \text{minSupp}(x) \}$$

the set of all residual generators where A is a minimal support for x.

**Definition 5.3** (Canonical Basis Property). A set B of residual generators is a *canonical basis* for cl if:
1. Every g ∈ B has a minimal support: IsMinimalSupport(cl, g.target, g.support).
2. For all x and S: x ∈ cl(S) ↔ ∃ g ∈ B such that g.target = x and g.support ⊆ S.

### 5.2 Existence

**Theorem 5.4** (`canonical_basis_is_basis`). The canonical residual basis 𝓑(cl) satisfies the canonical basis property.

*Proof sketch.* Condition (1) holds by construction — every generator in 𝓑(cl) is a minimal support by definition. Condition (2) follows directly from Theorem 4.3 by translating between the minimal support formulation and the generator formulation. □

### 5.3 Uniqueness

**Theorem 5.5** (`canonical_basis_unique`). If B₁ and B₂ are both canonical bases for cl, then B₁ = B₂.

*Proof sketch.* It suffices to show B₁ ⊆ B₂ (the reverse is symmetric). Let g ∈ B₁. Since g.target ∈ cl(g.support) (by minimality), the canonical basis property of B₂ gives some g' ∈ B₂ with g'.target = g.target and g'.support ⊆ g.support. But g' is also a minimal support (by the basis property of B₂), and g.support is a minimal support (by the basis property of B₁). Since g'.support ⊆ g.support and both are minimal supports for the same target, we must have g'.support = g.support — otherwise g.support would have a proper subset generating the target, contradicting its minimality. Thus g' = g ∈ B₂. □

**Corollary 5.6** (`closure_basis_canonical`). For every closure operator cl, there exists a *unique* canonical residual basis: ∃! B, IsCanonicalBasis cl B.

---

## 6. Monotone Circuit Reconstruction

### 6.1 Monotone Circuits

**Definition 6.1** (Monotone Circuit). A *monotone Boolean circuit* over α is defined inductively:
- `input(a)`: an input gate for element a
- `top` / `bot`: constant true / false
- `conj(c₁, c₂)`: AND of two subcircuits
- `disj(c₁, c₂)`: OR of two subcircuits

Evaluation on a set S is defined recursively: `input(a)` checks a ∈ S, `conj` takes the conjunction, `disj` takes the disjunction.

**Theorem 6.2** (`MonotoneCircuit.eval_mono`). Evaluation is monotone: if c evaluates to true on S and S ⊆ T, then c evaluates to true on T.

*Proof.* Structural induction on circuits. □

### 6.2 DNF Construction

The reconstruction algorithm builds, for each target element x, a circuit:

$$C(x) = \bigvee_{A \in \text{minSupp}(x)} \bigwedge_{a \in A} \text{input}(a)$$

This is `reconstructClosureCircuit` in the formalization. The conjunction builder `conjOfList` and disjunction builder `disjOfList` are defined with correctness lemmas:

- `conjOfList_eval`: conjunction evaluates to true iff all inputs are present
- `disjOfList_eval`: disjunction evaluates to true iff some subcircuit evaluates to true

### 6.3 Correctness

**Theorem 6.3** (`reconstructed_circuit_correct`). The reconstructed circuit correctly computes the closure: for all x and S,

$$C(x) \text{ evaluates to true on } S \iff x \in \text{cl}(S)$$

*Proof sketch.* Unfolding the definitions, the circuit evaluates to true iff there exists a minimal support A for x with A ⊆ S. By Theorem 4.3, this is equivalent to x ∈ cl(S). □

---

## 7. The Main Duality Theorem

**Theorem 7.1** (`finite_closure_duality`). Let cl be a closure operator on a finite type α with rank bounded by r. Then there exist:
1. A canonical residual basis B satisfying the basis property,
2. A monotone closure circuit C computing cl exactly,

such that B is the unique canonical basis (any other basis B' with the same properties equals B).

*Proof.* Take B = 𝓑(cl) and C = the reconstructed circuit. Apply Theorems 5.4, 6.3, and 5.5. □

This theorem establishes a formal duality:

| **Algebraic Side** | **Computational Side** |
|---|---|
| Closure operator | Monotone circuit family |
| Minimal support | AND gate (conjunction) |
| Support disjunction | OR gate (disjunction) |
| Canonical basis | Minimal DNF representation |
| Uniqueness | Canonical form |

---

## 8. Formal Verification

All theorems in this paper have been formally verified in Lean 4 using the Mathlib library. The formalization resides in a single file at @file[Catalog/Bridges/ClosureCircuitDuality.lean] and consists of approximately 380 lines.

### 8.1 Formalization Structure

| **Component** | **Lines** | **Key Declarations** |
|---|---|---|
| Core definitions | §1-3 | `IsClosureOperator`, `ClosurePresentation`, `ResidualGenerator` |
| Closure generation | §7 | `generatedClosure_isClosureOperator` |
| Minimal support theory | §8 | `minimal_support_exists`, `closure_iff_contains_minimal_support` |
| Canonical basis | §9 | `canonical_basis_is_basis`, `canonical_basis_unique`, `closure_basis_canonical` |
| Circuit theory | §5-6,10 | `MonotoneCircuit`, `eval_mono`, `reconstructed_circuit_correct` |
| Main duality | §11 | `finite_closure_duality` |

### 8.2 Proof Techniques

The formal proofs employ a variety of techniques:
- **Well-founded induction** (`Finset.strongInduction`) for minimal support existence
- **Set-theoretic reasoning** (intersections, membership) for closure properties
- **Structural induction** on the `MonotoneCircuit` inductive type for monotonicity
- **Extensionality** (`Finset.ext`) for basis uniqueness, combined with minimality arguments
- **Classical logic** (via `Classical.propDecidable`) for decidability of minimal support predicates

---

## 9. Applications

### 9.1 Database Theory

In relational database theory, functional dependencies {A₁, ..., Aₖ} → B define a closure operator on attributes. The canonical residual basis extracts the minimal set of functional dependencies — the *canonical cover* — and the DNF circuit provides a direct query-answering mechanism for attribute closure computation.

### 9.2 Circuit Complexity

The reconstruction theorem provides an *upper bound* on the monotone DNF complexity of any closure-definable Boolean function. If the closure has rank r and operates on n elements, the circuit size is bounded by the total size of all minimal supports, which is at most O(n · nʳ) = O(nʳ⁺¹). For low-rank closures (r = O(1)), this gives polynomial-size circuits.

### 9.3 Formal Concept Analysis

In FCA, the canonical basis corresponds to the set of *pseudo-intents* — the minimal non-closed sets that generate all implications. Our residual basis provides a finer decomposition at the element level, which may be more suitable for incremental computation.

### 9.4 Neural Network Optimization

The closure-circuit duality provides foundational infrastructure for studying descent basin structure in neural network loss landscapes. If one defines a closure operator where cl(S) represents the set of parameter configurations reachable from initializations in S via gradient descent, then:
- The canonical basis describes the minimal sets of initializations that access each basin
- The monotone circuit provides a decision procedure for basin membership
- The uniqueness theorem guarantees this description is canonical

---

## 10. Discussion and Future Work

### 10.1 Toward Discrete Morse Inequalities

The basin-counting application naturally extends to discrete Morse theory. The descent system infrastructure — particularly the Lyapunov function framework — provides the non-cycling machinery needed for discrete gradient flows. Formalizing Forman's weak Morse inequality (critical k-cells bounded below by k-th Betti number) would connect basin counting to topological invariants.

### 10.2 Fisher Information as a Descent Generator

The conjecture motivating this work connects the Fisher information metric on neural network parameter spaces to basin structure. Natural gradient descent θ ↦ θ − I(θ)⁻¹ ∇L(θ) satisfies the strict descent condition when the loss has isolated critical points, with the KL divergence as a natural Lyapunov function. This would give concrete constructions of descent systems from statistical data.

### 10.3 Quantum Deformation of Basin Counting

A natural extension is to define quantum basin numbers Q(q) by weighting gradient flow paths by e^{−q·length} and checking whether the resulting deformation satisfies the WDVV associativity equations. If so, this would provide strong evidence for a connection between basin structure and Gromov-Witten invariants.

### 10.4 Equivariant Basin Counting

When the loss landscape has symmetries (as is typical in neural networks due to weight permutation symmetries), equivariant basin counting via Burnside's lemma could reduce the effective number of distinct basins, connecting representation theory to optimization landscape analysis.

---

## References

1. Duquenne, V. and Guigues, J.-L. (1986). Famille minimale d'implications informatives résultant d'un tableau de données binaires. *Mathématiques et Sciences Humaines*, 95:5–18.

2. Razborov, A.A. (1985). Lower bounds on the monotone complexity of some Boolean functions. *Doklady Akademii Nauk SSSR*, 281(4):798–801.

3. Forman, R. (1998). Morse theory for cell complexes. *Advances in Mathematics*, 134(1):90–145.

4. Amari, S. (1998). Natural gradient works efficiently in learning. *Neural Computation*, 10(2):251–276.

5. Ganter, B. and Wille, R. (1999). *Formal Concept Analysis: Mathematical Foundations*. Springer.

---

*The complete machine-verified formalization is available at @file[Catalog/Bridges/ClosureCircuitDuality.lean].*
