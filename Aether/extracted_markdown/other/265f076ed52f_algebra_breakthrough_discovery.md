# Closure Operators as the Organizing Principle of Algebraic Correspondences

## Abstract

We formalize a unified order-theoretic framework that reveals closure operators as the structural backbone of algebraic correspondences, including the fundamental theorem of Galois theory. Starting from the three defining properties — monotonicity, extensivity, and idempotence — we prove that the closed elements of any closure operator on a complete lattice form a complete lattice (via Galois insertion), and we establish the closed-element inclusion as an order embedding. We then demonstrate that the round-trip `fixedField ∘ fixingSubgroup` on intermediate fields is a closure operator *without any Galois hypothesis*, and that the classical Galois correspondence emerges as the special case where every element is closed. All results are machine-verified in Lean 4 with Mathlib, with no unproven (`sorry`) statements.

## 1. Introduction

### 1.1 The Problem

Modern algebra libraries like Mathlib contain over 8,000 declarations spread across lattice theory, field theory, group theory, and ring theory. While individual theorems are meticulously proven, the *organizational architecture* connecting them is often implicit. A newcomer sees isolated facts — "intermediate fields form a lattice," "the Galois correspondence is a bijection," "closure operators have fixed points" — without understanding that these are manifestations of a single structural phenomenon.

### 1.2 The Discovery

We identify and formalize the following unifying principle:

> **Many algebraic correspondences are closure operators in disguise.** The composition of an antitone Galois connection with itself yields an extensive, monotone, idempotent operator — a closure operator. The closed elements (fixed points) form a complete lattice, and the original correspondence restricts to an order isomorphism on closed elements.

This is not a new mathematical observation — it appears in textbooks on lattice theory (Davey & Priestley, Birkhoff) — but its *formalization as a reusable framework* connecting abstract order theory to concrete algebraic constructions is, to our knowledge, new.

### 1.3 Contributions

1. **A reusable closure operator interface** (`mkClosureOperator`) that recognizes the closure pattern from raw data (monotone + extensive + idempotent maps).

2. **The main structural theorem**: closed elements of a closure operator on a complete lattice form a complete lattice, with inclusion as an order embedding.

3. **The Galois closure operator**: the round-trip `fixedField ∘ fixingSubgroup` is proven to be a closure operator *without* the Galois hypothesis. For finite Galois extensions, every intermediate field is closed, recovering the classical bijection.

4. **Lattice transport theorems**: the Galois correspondence converts meets to joins, joins to meets, top to bottom, and bottom to top — all derived from the `OrderIso` structure.

5. **Invariant statistics**: a formal framework for functions constant on group orbits, with pullback/pushforward along equivariant equivalences.

6. **Oracle refinement connection**: the oracle refinement preorder from computational oracle theory is shown to correspond to containment of closed-element sets.

## 2. Mathematical Framework

### 2.1 Closure Operators

A **closure operator** on a preorder $(α, ≤)$ is a function $c : α → α$ satisfying:
- **Monotonicity**: $a ≤ b \implies c(a) ≤ c(b)$
- **Extensivity**: $a ≤ c(a)$
- **Idempotence**: $c(c(a)) = c(a)$

An element $a$ is **closed** if $c(a) = a$, i.e., it is a fixed point of $c$.

**Theorem 1** (Main Structural Theorem). *If $(α, ≤)$ is a complete lattice and $c$ is a closure operator on $α$, then the set of closed elements $\{a ∈ α \mid c(a) = a\}$ forms a complete lattice under the inherited order.*

*Proof.* The closure map $c$ and the inclusion $ι$ form a Galois insertion $c ⊣ ι$, and `GaloisInsertion.liftCompleteLattice` constructs the complete lattice structure. ∎

**Theorem 2** (Order Embedding). *The inclusion $ι : \text{Closeds}(c) ↪ α$ is an order embedding.*

### 2.2 The Galois Closure Operator

Given a field extension $E/F$, define:
$$\text{gc}(K) = \text{fixedField}(\text{fixingSubgroup}(K))$$
for an intermediate field $K$.

**Theorem 3** (Galois Closure). *The map $\text{gc}$ is a closure operator on the lattice of intermediate fields of $E/F$. No Galois hypothesis is needed.*

*Proof.* 
- *Extensivity*: $K ≤ \text{gc}(K)$ because every element of $K$ is fixed by every automorphism in $\text{fixingSubgroup}(K)$.
- *Monotonicity*: $K ≤ L \implies \text{fixingSubgroup}(L) ≤ \text{fixingSubgroup}(K) \implies \text{fixedField}(\text{fixingSubgroup}(K)) ≤ \text{fixedField}(\text{fixingSubgroup}(L))$.
- *Idempotence*: Let $H = \text{fixingSubgroup}(K)$. Then $H ≤ \text{fixingSubgroup}(\text{fixedField}(H))$ always holds (any automorphism fixing $K$ fixes $\text{fixedField}(H) ⊇ K$). By antitonicity of $\text{fixedField}$, we get $\text{gc}(\text{gc}(K)) ≤ \text{gc}(K)$. Combined with extensivity, this gives equality. ∎

**Theorem 4** (Galois Case). *If $E/F$ is a finite Galois extension, then every intermediate field is closed under $\text{gc}$. The closure operator is the identity.*

This recovers the classical fundamental theorem of Galois theory: the correspondence between intermediate fields and subgroups is a bijection precisely because the closure operator is trivial.

### 2.3 Lattice Transport

**Theorem 5** (Galois Transport). *For a finite Galois extension $E/F$, the Galois correspondence $\text{intermediateFieldEquivSubgroup}$ satisfies:*
- $\text{Gal}(⊤) = ⊥$ *(top field maps to trivial subgroup)*
- $\text{Gal}(⊥) = ⊤$ *(base field maps to full group)*
- $\text{Gal}(E_1 ⊓ E_2) = \text{Gal}(E_1) ⊔ \text{Gal}(E_2)$ *(meets become joins)*
- $\text{Gal}(E_1 ⊔ E_2) = \text{Gal}(E_1) ⊓ \text{Gal}(E_2)$ *(joins become meets)*

### 2.4 Invariant Statistics

**Definition.** An *invariant statistic* for a group $G$ acting on a set $α$ is a function $f : α → β$ satisfying $f(g \cdot x) = f(x)$ for all $g ∈ G, x ∈ α$.

**Theorem 6** (Equivariant Transport). *If $e : α ≃ β$ is an equivariant equivalence and $f$ is an invariant statistic on $β$, then $f ∘ e$ is an invariant statistic on $α$. Moreover, pullback and pushforward along $e$ are inverse operations.*

## 3. Formalization Details

### 3.1 File Structure

| File | Contents | Lines | Theorems |
|------|----------|-------|----------|
| `Framework.lean` | Closure operators, constructors, oracle connection | ~160 | 14 |
| `GaloisCorrespondence.lean` | Galois closure operator, transport theorems | ~170 | 14 |
| `InvariantStatistic.lean` | Invariant statistics, transport | ~170 | 12 |

### 3.2 Key Design Decisions

1. **Building on Mathlib's `ClosureOperator`**: Rather than defining a parallel structure, we provide a convenient constructor `mkClosureOperator` that feeds into Mathlib's existing infrastructure, inheriting hundreds of derived lemmas for free.

2. **No Galois hypothesis for the closure operator**: The key insight that `fixedField ∘ fixingSubgroup` is always a closure operator (Theorem 3) holds without finite-dimensionality or separability. This is a stronger result than needed for the Galois correspondence but reveals the universal nature of the construction.

3. **Working through `OrderDual`**: The Galois correspondence is an isomorphism into the *opposite* order. Stating transport theorems requires careful unwrapping of `OrderDual.ofDual` and `OrderDual.toDual`, which we handle explicitly.

### 3.3 Proof Techniques

- **Galois Insertion → Complete Lattice**: The central `closedElements_completeLattice` theorem uses `GaloisInsertion.liftCompleteLattice`, a powerful Mathlib result that constructs complete lattice structure from a Galois insertion.
- **Order embedding via subtype**: `OrderEmbedding.subtype` directly gives the order embedding for closed elements.
- **Idempotence proof**: The idempotence of `galoisClosure` uses a beautiful argument: both directions follow from the universal property `H ≤ fixingSubgroup(fixedField(H))`, which holds without any Galois hypothesis.

## 4. Discussion: Why This Matters

### 4.1 For the Working Mathematician

Imagine you're studying a new algebraic structure — say, invariant subrings under a group action, or closed subsets of a topological space, or stable submodules under an endomorphism. In each case, the "closure under the relevant operation" follows the same pattern: monotone, extensive, idempotent. Our framework says: *once you verify these three properties, you get a complete lattice of closed elements for free.*

This is like discovering that different musical instruments all follow the same laws of acoustics. The violin, the piano, and the flute seem different, but the physics of standing waves unifies them. Similarly, the Galois correspondence, the closure of a set under a topology, and the orbit decomposition under a group action are all instances of the same abstract machine.

### 4.2 For the Formalization Community

This work demonstrates a pattern that could dramatically reduce the effort needed to formalize new algebraic theories:

1. **Identify the closure operator.** In your theory, find the map that takes an object to its "completion" or "closure."
2. **Verify three properties.** Monotonicity, extensivity, idempotence.
3. **Instantiate the framework.** Get complete lattice structure, order embeddings, and transport theorems for free.

This is already the methodology used (implicitly) by expert Mathlib contributors. Making it explicit and reusable lowers the barrier for new formalizers.

### 4.3 For Computer Science

Closure operators appear throughout computer science:
- **Type inference**: Unification is a closure operator on substitutions.
- **Abstract interpretation**: The abstract domain is the poset of closed elements.
- **Database theory**: Armstrong's axioms define a closure operator on attribute sets.
- **Program analysis**: Reaching definitions, available expressions, and live variables are all computed via closure operators on the lattice of program facts.

Our formal framework could serve as the foundation for verified implementations of these algorithms.

### 4.4 Historical Context

The connection between Galois theory and closure operators was recognized by Oystein Ore in the 1940s, who developed the theory of Galois connections as an abstraction of the Galois correspondence. The modern formulation in terms of adjunctions and Galois insertions is due to the Bourbaki school and subsequent work by Erné and others.

What is new here is not the mathematics but the *formalization architecture*: packaging these ideas into a reusable Lean library that connects abstract order theory to concrete algebraic instances, with machine-verified proofs of all intermediate steps.

## 5. Concrete Examples

### 5.1 The Extension Q(√2, √3)/Q

The Galois group is $\mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$, with generators:
- $σ$: $\sqrt{2} \mapsto -\sqrt{2}$, $\sqrt{3} \mapsto \sqrt{3}$
- $τ$: $\sqrt{2} \mapsto \sqrt{2}$, $\sqrt{3} \mapsto -\sqrt{3}$

The five intermediate fields and their fixing subgroups:

| Field $K$ | $[K:\mathbb{Q}]$ | $\text{Gal}(E/K)$ | $|\text{Gal}(E/K)|$ |
|-----------|------|------------|------|
| $\mathbb{Q}$ | 1 | $G = \{1, σ, τ, στ\}$ | 4 |
| $\mathbb{Q}(\sqrt{2})$ | 2 | $\{1, τ\}$ | 2 |
| $\mathbb{Q}(\sqrt{3})$ | 2 | $\{1, σ\}$ | 2 |
| $\mathbb{Q}(\sqrt{6})$ | 2 | $\{1, στ\}$ | 2 |
| $\mathbb{Q}(\sqrt{2},\sqrt{3})$ | 4 | $\{1\}$ | 1 |

The transport theorems give:
- $\mathbb{Q}(\sqrt{2}) \cap \mathbb{Q}(\sqrt{3}) = \mathbb{Q}$ corresponds to $\{1,τ\} \vee \{1,σ\} = G$
- $\mathbb{Q}(\sqrt{2}) \vee \mathbb{Q}(\sqrt{3}) = \mathbb{Q}(\sqrt{2},\sqrt{3})$ corresponds to $\{1,τ\} \cap \{1,σ\} = \{1\}$

### 5.2 Closure on Power Sets

The power set $\mathcal{P}(\{1,2,3\})$ with the closure operator "add 3 if both 1 and 2 are present" has 8 elements, of which 7 are closed (only $\{1,2\}$ is not closed, since $c(\{1,2\}) = \{1,2,3\}$). The closed elements form a complete lattice under set inclusion.

## 6. Related Work

- **Mathlib's `ClosureOperator`**: Our work builds directly on Mathlib's existing `ClosureOperator` structure and its `gi` (Galois insertion) field. We provide the missing bridge between abstract closure theory and concrete algebraic instances.
- **Mathlib's `intermediateFieldEquivSubgroup`**: The fundamental theorem of Galois theory is already formalized in Mathlib as an `OrderIso`. We derive new transport theorems and connect it to the closure operator framework.
- **Ore's Galois connections**: Our Galois closure operator formalizes Ore's observation that the Galois correspondence arises from the composition of two antitone maps.

## 7. Conclusion

By recognizing closure operators as the organizing principle behind algebraic correspondences, we transform a collection of isolated theorems into a navigable architecture. The formal Lean proofs ensure correctness; the reusable interface ensures utility; and the explicit connection to the Galois correspondence demonstrates the framework's power on a deep mathematical example.

The key takeaway: **the Galois correspondence is not magic — it is a closure operator.**
