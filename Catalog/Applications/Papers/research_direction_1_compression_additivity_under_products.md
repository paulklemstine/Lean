# Compression Complexity Is Sub-Additive Under Categorical Products of Finite Presheaf Models

## Abstract

We develop a formal theory of compression complexity for finite presheaf models under categorical products. Given a finite presheaf model M — a finite category of objects with finite fibers and restriction maps — the compression complexity κ(M) is the minimum number of probe objects needed to separate all fiber elements by their restriction signatures. We prove three structural theorems: (1) **Sub-additivity**: κ(M₁ × M₂) ≤ κ(M₁) + κ(M₂); (2) **Lower bound**: max(κ(M₁), κ(M₂)) ≤ κ(M₁ × M₂); and (3) **Conditional additivity**: κ(M₁ × M₂) = κ(M₁) + κ(M₂) under a probe independence hypothesis. We also establish a cross-domain bridge to zero-error information theory by proving that the distinguishability cardinality — the number of observationally distinct states — is multiplicative under products. All results are formalized and verified in the Lean 4 proof assistant with the Mathlib library. Computational experiments reveal that universal additivity fails: the compression defect δ(M₁, M₂) = κ(M₁) + κ(M₂) − κ(M₁ × M₂) can be strictly positive, opening a defect theory of observational interaction.

## 1. Introduction

### 1.1 Motivation

How many measurements do you need to identify the state of a system? This question lies at the intersection of category theory, information theory, and combinatorial optimization. In the presheaf-theoretic framework, a system's state space is encoded as a *finite presheaf model*: a finite collection of objects, each carrying a finite set of possible states (fibers), connected by restriction maps that project global states to local observations.

The *compression complexity* κ(M) of such a model is the minimum number of probe objects whose combined observations suffice to distinguish all states at every fiber. This invariant was introduced as a quantitative refinement of the Yoneda embedding principle: while the full Yoneda lemma says all objects together separate morphisms, κ measures how few suffice.

A natural question arises when considering *independent systems*: if M₁ and M₂ model independent subsystems, what is κ(M₁ × M₂)? Does the complexity add, like entropy for independent random variables? Or can joint observation compress beyond the sum, like channel coding?

### 1.2 Contributions

We establish the following results:

1. **Sub-additivity** (Theorem 1): κ(M₁ × M₂) ≤ κ(M₁) + κ(M₂) for all finite presheaf models, whenever both factors are probe-separable and have nonempty object sets.

2. **Lower bound** (Theorem 3): max(κ(M₁), κ(M₂)) ≤ κ(M₁ × M₂), showing that product cannot erase the complexity of either factor.

3. **Conditional additivity** (Theorem 2): Under a *probe independence* hypothesis — that every separating family on the product has size ≥ κ(M₁) + κ(M₂) — exact additivity holds.

4. **Multiplicativity of distinguishability** (Theorem 4): The number of observationally distinct states at a product object equals the product of the individual counts, bridging to zero-error channel capacity.

5. **Compression defect**: We define δ(M₁, M₂) = κ(M₁) + κ(M₂) − κ(M₁ × M₂) and prove it is well-defined and non-negative.

6. **Computational evidence**: We implement exhaustive enumeration of small models and show that universal additivity fails — there exist model pairs with δ > 0.

### 1.3 Related Work

The compression complexity framework builds on:
- **Probe complexity of finite categories** (Defs.lean), which defines probe families for morphism separation in categories.
- **Topos-level compression** (ToposCompressionDefs.lean), which defines fiber-level separation for presheaf-like structures.
- **Morita invariance** (ToposCompressionInvariant.lean), which shows κ is invariant under compression-compatible equivalences.

Our product theory extends these foundations in a new direction: structural behavior under the categorical product operation.

## 2. Definitions and Notation

### 2.1 Finite Presheaf Models

**Definition 1** (FinitePresheafModel). A *finite presheaf model* M = (Ob, Fib, res) consists of:
- A finite type Ob of objects
- A family Fib : Ob → Type of finite fibers (each Fib(Y) is a finite type with decidable equality)
- Restriction maps res : ∀ Y Z, Fib(Y) → Fib(Z)

**Definition 2** (Probe Family). A *probe family* is a finite subset P ⊆ Ob.

**Definition 3** (Probe Signature). For s ∈ Fib(Y) and probe family P, the *probe signature* is:
σ_P(Y, s) = (res(Y, Z)(s))_{Z ∈ P}

**Definition 4** (Separating Family). P *separates* M if σ_P(Y, ·) is injective for every Y ∈ Ob.

**Definition 5** (Compression Complexity). κ(M) = min{|P| : P separates M}.

### 2.2 Product Model

**Definition 6** (Product). For models M₁ = (Ob₁, Fib₁, res₁) and M₂ = (Ob₂, Fib₂, res₂), the *product model* M₁ × M₂ = (Ob₁ × Ob₂, Fib, res) where:
- Fib(Y₁, Y₂) = Fib₁(Y₁) × Fib₂(Y₂)
- res((Y₁,Y₂), (Z₁,Z₂))(s₁, s₂) = (res₁(Y₁,Z₁)(s₁), res₂(Y₂,Z₂)(s₂))

### 2.3 Distinguishability

**Definition 7** (Probe Indistinguishability). Sections s, t ∈ Fib(Y) are *probe-indistinguishable* if res(Y,Z)(s) = res(Y,Z)(t) for all Z ∈ Ob.

**Definition 8** (Distinguishability Cardinality). d(M, Y) = |Fib(Y) / ∼| where ∼ is probe indistinguishability.

## 3. Main Results

### 3.1 Theorem 1: Sub-Additivity

**Theorem** (compression_prod_le). *For finite presheaf models M₁, M₂ with M₁.IsSeparable, M₂.IsSeparable, and nonempty object sets:*
$$κ(M_1 × M_2) ≤ κ(M_1) + κ(M_2)$$

**Proof sketch.** Let P₁, P₂ be optimal separating families for M₁, M₂ with |P₁| = κ(M₁), |P₂| = κ(M₂). Pick basepoints b₁ ∈ Ob₁, b₂ ∈ Ob₂. Define the *product probe family*:

Q = {(z₁, b₂) : z₁ ∈ P₁} ∪ {(b₁, z₂) : z₂ ∈ P₂}

Then |Q| ≤ |P₁| + |P₂| (union bound). To show Q separates M₁ × M₂: given (s₁,s₂) ≠ (t₁,t₂) at (Y₁,Y₂), either s₁ ≠ t₁ or s₂ ≠ t₂.

- If s₁ ≠ t₁: since P₁ separates M₁, some z₁ ∈ P₁ distinguishes s₁ from t₁. The probe (z₁, b₂) ∈ Q then distinguishes (s₁,s₂) from (t₁,t₂) in the product via the first component.
- If s₂ ≠ t₂: symmetric argument using P₂.

By minimality of κ, we conclude κ(M₁ × M₂) ≤ |Q| ≤ κ(M₁) + κ(M₂). □

### 3.2 Theorem 3: Lower Bounds

**Theorem** (compression_le_prod_left). κ(M₁) ≤ κ(M₁ × M₂).

**Proof sketch.** Let P be an optimal separating family for M₁ × M₂ with |P| = κ(M₁ × M₂). Define the *slice family* π₁(P) = {fst(p) : p ∈ P} ⊆ Ob₁. Then |π₁(P)| ≤ |P|.

Claim: π₁(P) separates M₁. Given s₁ ≠ t₁ ∈ Fib₁(Y₁), fix any s₂ ∈ Fib₂(b₂). Then (s₁, s₂) ≠ (t₁, s₂) in the product fiber. Since P separates the product, some (Z₁, Z₂) ∈ P distinguishes them:
res((Y₁,b₂), (Z₁,Z₂))(s₁,s₂) ≠ res((Y₁,b₂), (Z₁,Z₂))(t₁,s₂)

This means (res₁(Y₁,Z₁)(s₁), res₂(b₂,Z₂)(s₂)) ≠ (res₁(Y₁,Z₁)(t₁), res₂(b₂,Z₂)(s₂)), so res₁(Y₁,Z₁)(s₁) ≠ res₁(Y₁,Z₁)(t₁). Since Z₁ = fst(Z₁,Z₂) ∈ π₁(P), the slice family distinguishes s₁ from t₁.

Therefore κ(M₁) ≤ |π₁(P)| ≤ |P| = κ(M₁ × M₂). □

**Corollary** (max_le_compression_prod). max(κ(M₁), κ(M₂)) ≤ κ(M₁ × M₂).

### 3.3 Theorem 2: Conditional Additivity

**Definition 9** (ProbeIndependent). M₁ and M₂ are *probe-independent* if every separating family P for M₁ × M₂ satisfies |P| ≥ κ(M₁) + κ(M₂).

**Theorem** (compression_prod_eq_of_independent). *Under probe independence:*
$$κ(M_1 × M_2) = κ(M_1) + κ(M_2)$$

**Proof.** The ≤ direction is sub-additivity. For ≥: let P be optimal for M₁ × M₂ with |P| = κ(M₁ × M₂). By probe independence, κ(M₁) + κ(M₂) ≤ |P| = κ(M₁ × M₂). □

### 3.4 Theorem 4: Multiplicativity of Distinguishability

**Theorem** (probeIndistinguishable_prod_iff). *Sections (s₁,s₂) and (t₁,t₂) are probe-indistinguishable in M₁ × M₂ iff s₁ ∼ t₁ in M₁ and s₂ ∼ t₂ in M₂.*

**Theorem** (distinguishabilityCardAt_prod).
$$d(M_1 × M_2, (Y_1, Y_2)) = d(M_1, Y_1) \cdot d(M_2, Y_2)$$

**Proof sketch.** By the product characterization of indistinguishability, the quotient Fib(Y₁,Y₂)/∼ is in bijection with (Fib₁(Y₁)/∼₁) × (Fib₂(Y₂)/∼₂). The bijection maps ⟦(s₁,s₂)⟧ ↦ (⟦s₁⟧, ⟦s₂⟧). Well-definedness, injectivity, and surjectivity all follow from the iff characterization. Cardinality follows by Fintype.card_congr and Fintype.card_prod. □

**Cross-domain significance.** This is the presheaf-theoretic incarnation of the principle that independent channels have multiplicative capacity. In the language of zero-error information theory:
- Presheaf model ↔ observational channel
- Product model ↔ independent channel use
- d(M, Y) ↔ zero-error capacity at output Y
- Multiplicativity ↔ capacity is additive under tensor product

## 4. Algorithms

### 4.1 Computing κ(M)

**Algorithm 1: Exhaustive Search**

```
Input: FinitePresheafModel M = (Ob, Fib, res)
Output: κ(M)

for k = 0 to |Ob|:
    for each k-subset P ⊆ Ob:
        if P separates M:
            return k
return |Ob|
```

**Complexity.** Time: O(2^n · n · F_max) where n = |Ob|, F_max = max|Fib(Y)|. Space: O(F_max · n).

### 4.2 Product Construction

**Algorithm 2: Product Model**

```
Input: M₁ = (Ob₁, Fib₁, res₁), M₂ = (Ob₂, Fib₂, res₂)
Output: M₁ × M₂

Ob_prod = Ob₁ × Ob₂
for (y₁, y₂) in Ob_prod:
    Fib_prod(y₁,y₂) = Fib₁(y₁) × Fib₂(y₂)
    for (z₁, z₂) in Ob_prod:
        res_prod((y₁,y₂), (z₁,z₂))(s₁,s₂) = (res₁(y₁,z₁)(s₁), res₂(y₂,z₂)(s₂))
return (Ob_prod, Fib_prod, res_prod)
```

**Complexity.** Time: O(n₁·n₂·(n₁·n₂ + F₁·F₂)). Space: O(n₁²·n₂²·F₁·F₂).

## 5. Computational Experiments

### 5.1 Enumeration Results

We enumerate presheaf models with up to 3 objects and fiber sizes up to 3, generating identity models (res(Y,Y) = id, res(Y,Z) = const), constant models (|Fib(Y)| = 1), and full-separation models (cyclic permutation restrictions).

| Model | |Ob| | Fiber sizes | κ |
|-------|------|-------------|---|
| Const(1) | 1 | [1] | 0 |
| Const(2) | 2 | [1,1] | 0 |
| Const(3) | 3 | [1,1,1] | 0 |
| Id(2,2) | 2 | [2,2] | 2 |
| Id(2,3) | 2 | [3,3] | 2 |
| Id(3,2) | 3 | [2,2,2] | 3 |
| Full(2,2) | 2 | [2,2] | 1 |
| Full(3,2) | 3 | [2,2,2] | 1 |

### 5.2 Product Analysis

Key findings from pairwise product analysis:

1. **Sub-additivity always holds** ✓ — verified for all test pairs.
2. **Lower bound always holds** ✓ — verified for all test pairs.
3. **Universal additivity fails** ✗ — defect > 0 observed.

Representative results:

| M₁ | M₂ | κ₁ | κ₂ | κ(M₁×M₂) | δ |
|----|----|----|----|-----------|----|
| Const(2) | Id(2,2) | 0 | 2 | 2 | 0 |
| Id(2,2) | Id(2,2) | 2 | 2 | 2 | 2 |
| Id(2,2) | Full(2,2) | 2 | 1 | 2 | 1 |
| Full(2,2) | Full(2,2) | 1 | 1 | 1 | 1 |

### 5.3 Defect Analysis

The identity models exhibit the largest defects: Id(n,k) × Id(n,k) has defect = n (since κ(M₁ × M₂) = n while κ(M₁) + κ(M₂) = 2n). This occurs because the product's diagonal probes can simultaneously separate both factors.

## 6. Discussion

### 6.1 Why Additivity Fails

The failure of universal additivity is structurally meaningful, not pathological. When restriction maps have "shared structure" between objects — for instance, when all restriction maps to a common probe object agree — a single probe in the product can simultaneously witness information from both factors. This phenomenon parallels the failure of Shannon capacity additivity for general channels and the failure of dimensional additivity for exotic topological spaces.

### 6.2 The Defect as an Invariant

The compression defect δ(M₁, M₂) = κ(M₁) + κ(M₂) − κ(M₁ × M₂) is itself an interesting invariant. It measures the "interaction information" between two models under joint observation. Our theorem compressionDefect_eq establishes its well-definedness: κ(M₁ × M₂) + δ(M₁, M₂) = κ(M₁) + κ(M₂).

### 6.3 Distinguishability and Information Theory

The multiplicativity theorem for distinguishability cardinality (Theorem 4) is the clean structural fact underlying the entire theory. It says that observational capacity composes multiplicatively — exactly as for independent channels. The gap between multiplicative distinguishability and sub-additive compression complexity is the compression-theoretic analogue of the gap between Shannon entropy and Rényi entropy in classical information theory.

## 7. Future Work

1. **Defect classification**: Characterize which model pairs have δ = 0 (probe independence).
2. **Graph-theoretic bridge**: Express κ as a graph invariant of the confusability graph.
3. **Asymptotic additivity**: Prove or disprove lim κ(M^{×n})/n = κ(M).
4. **K-theoretic framework**: Lift κ to a homomorphism on the Grothendieck group K₀.
5. **Computational complexity**: Determine whether computing κ is NP-hard.

See FUTURE_DIRECTIONS.md for detailed conjectures with tests.

## 8. Formal Verification

All main theorems are formalized in Lean 4 with the Mathlib library:

- `Pythagorean/ProbeComplexity/CompressionProduct.lean` — all product theorems
- `Pythagorean/ProbeComplexity/ToposCompressionDefs.lean` — base definitions

The proofs use no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`.

## References

1. Mac Lane, S. & Moerdijk, I. *Sheaves in Geometry and Logic*. Springer, 1992.
2. Shannon, C. E. "The zero error capacity of a noisy channel." *IRE Trans. Inform. Theory*, 1956.
3. Lovász, L. "On the Shannon capacity of a graph." *IEEE Trans. Inform. Theory*, 1979.
4. Mathlib contributors. *Mathlib4: The math library for Lean 4*. https://github.com/leanprover-community/mathlib4
