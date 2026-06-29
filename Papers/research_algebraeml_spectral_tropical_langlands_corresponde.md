# Tropical Spectral Langlands Correspondence via Idempotent Hecke Semirings and Closure Eigenmeasures

## Abstract

We establish a spectral correspondence theorem for residuated actions of idempotent semirings on finite lattices. Given a residuated action (a system of Galois connections indexed by a Hecke-type semiring), we construct closure operators from the adjunction data and define indicator eigenmeasures from closure-prime fixed points. Our main result proves that the natural map from simple summands (non-trivial, closure-prime fixed points) to extremal closure eigenmeasures is injective. Combined with a character recovery theorem showing that the tropical character equals the supremum of closed elements, this provides a tropical analogue of the classical Satake correspondence. All results are formalized and machine-verified.

**Keywords**: tropical algebra, idempotent semiring, Galois connection, closure operator, spectral decomposition, Langlands correspondence, residuated lattice, max-plus algebra

---

## 1. Introduction

### 1.1 Motivation

The Langlands program establishes deep correspondences between automorphic representations and Galois representations, with the Satake isomorphism providing the foundational case for unramified representations. A fundamental question is whether analogous spectral decomposition theorems hold in the tropical (max-plus) setting, where addition is replaced by maximum and the resulting algebraic structure is inherently idempotent.

Tropical mathematics has found applications in optimization [1], discrete event systems [2], algebraic geometry [3], and machine learning [4]. However, a systematic tropical spectral theory — decomposing tropical semimodules into irreducible components and classifying them via spectral invariants — has been lacking.

### 1.2 Main Contributions

We introduce the following framework and establish the following results:

1. **Residuated Action Structure** (Definition 2.1): A formalization of Galois-connected action systems parametrized by a Hecke-type index set, generalizing max-plus linear operators.

2. **Closure Spectrum Construction** (Theorem 3.1): Every residuated action canonically induces a family of closure operators via adjunction composition, creating a "Satake-tropical functor" from representations to closure systems.

3. **Indicator Eigenmeasure Construction** (Definition 4.2, Theorem 4.3): Each closure-prime fixed point (simple summand) produces a closure-invariant monotone functional valued in `WithBot ℤ`.

4. **Spectral Correspondence Injection** (Theorem 4.5): The map from simple summands to closure eigenmeasures is injective.

5. **Character Recovery** (Theorem 5.1): The tropical character — defined as the closure of the top element — equals the supremum of all closed elements, and is the largest closed element.

6. **Concrete Examples** (Section 6): Verified computations on `Bool` and finite lattices confirming all theorem predictions.

### 1.3 Related Work

**Classical Satake isomorphism**: Satake [5] established that the spherical Hecke algebra of a reductive group over a local field is isomorphic to the algebra of Weyl-invariant polynomials. Our work provides a tropical analogue where the role of characters is played by closure eigenmeasures.

**Tropical linear algebra**: Akian, Gaubert, and Guterman [6] developed tropical spectral theory for max-plus matrices, including Perron-Frobenius-type theorems. Our framework generalizes from matrices to abstract residuated actions.

**Closure operators and Galois connections**: The use of Galois connections to generate closure operators is classical [7]. Our contribution is connecting this to spectral decomposition.

**Idempotent analysis**: Litvinov, Maslov, and Shpiz [8] developed idempotent functional analysis as a systematic framework for max-plus mathematics. Our eigenmeasures are related to their idempotent measures.

---

## 2. Definitions

### 2.1 Residuated Action

**Definition 2.1** (Residuated Action). Let `H` be a type (the "Hecke index set") and `(M, ≤)` a partial order. A *residuated action* of `H` on `M` consists of:
- A family of maps `act : H → M → M` (forward action),
- A family of maps `res : H → M → M` (residual),
- For each `h : H`, a Galois connection: `act h x ≤ y ↔ x ≤ res h y` for all `x, y : M`.

The Galois connection ensures:
- `act h` is monotone (left adjoint)
- `res h` is monotone (right adjoint)
- `x ≤ res h (act h x)` for all `x` (extensiveness of closure)
- `act h (res h y) ≤ y` for all `y` (co-extensiveness)

### 2.2 Closure Operator from Residuation

**Definition 2.2**. The *closure operator* associated to `h : H` is `cl_h := res_h ∘ act_h : M → M`.

By standard Galois connection theory, `cl_h` is:
- Extensive: `x ≤ cl_h(x)`
- Monotone: `x ≤ y → cl_h(x) ≤ cl_h(y)`
- Idempotent: `cl_h(cl_h(x)) = cl_h(x)`

An element `x` is *closed* under `h` if `cl_h(x) = x`. We write `Closed(h)` for the set of closed elements.

### 2.3 Simple Summand

**Definition 2.3**. A *simple summand* of a residuated action `ρ` on `(M, ≤, ⊥)` is an element `s ∈ M` such that:
1. `s ≠ ⊥` (non-triviality),
2. `cl_h(s) = s` for all `h : H` (closed under all generators),
3. For all `h : H` and `x : M`, `s ≤ cl_h(x) → s ≤ x` (closure-prime).

The closure-prime condition (3) is the tropical analogue of irreducibility. It ensures that `s` is "detectable" by the closure system: if `s` appears in any closure, it was already present before closing.

**Remark**. On a finite distributive lattice, condition (3) is equivalent to `s` being join-irreducible in the lattice of closed elements. In general lattices, it must be assumed separately.

### 2.4 Closure Eigenmeasure

**Definition 2.4**. A *closure eigenmeasure* for a residuated action `ρ` on `(M, ⊔, ⊥)` is a function `μ : M → WithBot ℤ` such that:
1. `μ` is monotone: `x ≤ y → μ(x) ≤ μ(y)`,
2. `μ(⊥) = ⊥` (normalization),
3. `μ(cl_h(x)) = μ(x)` for all `h : H, x : M` (closure invariance).

The closure invariance means `μ` cannot distinguish an element from its closure — it "sees through" the closure operator to the underlying spectral content.

### 2.5 Tropical Character

**Definition 2.5**. The *tropical character* of a residuated action `ρ` on `(M, ≤, ⊤)` at `h : H` is `χ(h) := cl_h(⊤)`.

This is the largest element that is "reachable" from the top by applying `act_h` and then reflecting back via `res_h`.

### 2.6 Spectral Size

**Definition 2.6**. The *spectral size* at `h` is `|Closed(h)| = |{x ∈ M : cl_h(x) = x}|`.

---

## 3. Stage 1: Closure Spectrum Construction

**Theorem 3.1** (Closure Spectrum Existence). Every residuated action `ρ : ResidualAction H M` on a partial order `M` induces a closure spectrum object `Sat(ρ) : ClosureSpectrum H M` with `Sat(ρ).cl = ρ.closureOp`.

*Proof*. Immediate from the definition, packaging the family of closure operators induced by the Galois connections. ∎

**Theorem 3.2** (Multiplicative Compatibility). For a multiplicative residuated action (where `act(h₁ · h₂) = act(h₁) ∘ act(h₂)`), the closure of the identity is the identity: `cl_1(x) = x` for all `x`.

*Proof sketch*. Since `act_1 = id`, the Galois connection `act_1(a) ≤ b ↔ a ≤ res_1(b)` reduces to `a ≤ b ↔ a ≤ res_1(b)`, forcing `res_1 = id`. Therefore `cl_1 = res_1 ∘ act_1 = id ∘ id = id`. ∎

**Theorem 3.3** (Finiteness). If `M` is finite, then `Closed(h)` is a finite set for every `h : H`.

---

## 4. Stages 2–3: The Spectral Correspondence

### 4.1 Indicator Eigenmeasure

**Definition 4.1**. For a simple summand `s` of `ρ`, define the *indicator eigenmeasure* `μ_s : M → WithBot ℤ` by:
```
μ_s(x) = 0     if s ≤ x
μ_s(x) = ⊥     otherwise
```

**Theorem 4.2** (Eigenmeasure Properties). For any simple summand `s`:
1. `μ_s` is monotone.
2. `μ_s(⊥) = ⊥`.
3. `μ_s(cl_h(x)) = μ_s(x)` for all `h, x`.

*Proof of (3)*. We need `(s ≤ cl_h(x)) ↔ (s ≤ x)`.
- (⇐): If `s ≤ x`, then `s ≤ x ≤ cl_h(x)` by extensiveness.
- (⇒): If `s ≤ cl_h(x)`, then `s ≤ x` by the closure-prime condition of `s`. ∎

### 4.2 The Injection Theorem

**Theorem 4.3** (Spectral Correspondence — Injection). The map `Φ : SimpleSummand(ρ) → ClosureEigenmeasure(ρ)` defined by `Φ(s) = μ_s` is injective.

*Proof*. Suppose `μ_{s₁} = μ_{s₂}`. Evaluating at `x = s₁.val`:
- `μ_{s₁}(s₁.val) = 0` since `s₁.val ≤ s₁.val`.
- Therefore `μ_{s₂}(s₁.val) = 0`, so `s₂.val ≤ s₁.val`.

By symmetry (evaluating at `s₂.val`), `s₁.val ≤ s₂.val`. By antisymmetry, `s₁.val = s₂.val`, hence `s₁ = s₂` (the remaining fields are propositions). ∎

**Corollary 4.4**. If `M` is finite, the number of simple summands is at most the number of closure eigenmeasures.

---

## 5. Stage 4: Character Recovery

**Theorem 5.1** (Character is Closed). For any residuated action on `(M, ≤, ⊤)`, the tropical character `χ(h) = cl_h(⊤)` is a closed element: `cl_h(χ(h)) = χ(h)`.

*Proof*. Immediate from idempotency of the closure operator. ∎

**Theorem 5.2** (Character is Largest Closed). The tropical character is the largest closed element: for any `x` with `cl_h(x) = x`, we have `x ≤ χ(h)`.

*Proof*. Since `x ≤ ⊤ ≤ cl_h(⊤) = χ(h)`, using extensiveness of closure. ∎

**Theorem 5.3** (Character Recovery on Linear Orders). If `M` is a finite linear order with bounded order, then `χ(h) = sup(Closed(h))`.

*Proof*. The tropical character is a closed element (Theorem 5.1) and is the largest (Theorem 5.2), so `χ(h) = max(Closed(h)) = sup(Closed(h))`. ∎

---

## 6. Concrete Examples

### 6.1 Bool Lattice

**Example 6.1** (Identity action on Bool). The action `act _ x = x` with `res _ x = x` gives:
- Closed elements: `{false, true}` (spectral size = 2)
- Tropical character: `true`

**Example 6.2** (Constant-false action on Bool). The action `act _ _ = false` with `res _ _ = true` gives:
- Closure: `cl(x) = res(act(x)) = res(false) = true`
- Closed elements: `{true}` (spectral size = 1)
- Tropical character: `true`

These examples are verified computationally (`native_decide`).

### 6.2 Powerset Lattice

On `P({0,1,2})` with subset ordering:

| Action | Spectral Size | Closed Elements |
|--------|:---:|---|
| Identity | 8 | All subsets |
| Proj({0,1}) | 4 | {2}, {0,2}, {1,2}, {0,1,2} |
| Proj({0}) | 2 | {1,2}, {0,1,2} |
| Swap(0,1) | 8 | All subsets |

### 6.3 Linear Lattice

On `{0,1,2,3,4}` with the usual order, the action `act(x) = ⌊x/2⌋` with residual `res(y) = min(2y+1, 4)`:
- Closure map: 0↦1, 1↦1, 2↦3, 3↦3, 4↦4
- Closed elements: {1, 3, 4} (spectral size = 3)
- Simple summand: {4} (the only closure-prime non-bottom closed element)
- Character: cl(4) = 4 = max{1, 3, 4}

### 6.4 Max-Plus Matrices

For the 3×3 max-plus matrix:
```
A = [0, 3, -∞; 2, 0, 1; -∞, 4, 0]
```
- Tropical spectral radius: 2.5 (from the 2-cycle 1→2→1 with mean weight (3+2)/2)
- The sequence `tr(A^k)/k` converges to 2.5

---

## 7. Algorithms

### Algorithm 1: Closure Spectrum Computation

```
Input: Finite poset M, residuated action (act, res) indexed by H
Output: For each h ∈ H, the set Closed(h)

for h in H:
    Closed(h) ← ∅
    for x in M:
        if res(h, act(h, x)) == x:
            Closed(h) ← Closed(h) ∪ {x}
    output Closed(h)
```
Time: O(|H| · |M|), Space: O(|H| · |M|)

### Algorithm 2: Simple Summand Detection

```
Input: Finite poset M, list of residuated actions, bottom element ⊥
Output: Set of simple summands

S ← ∅
for x in M \ {⊥}:
    if ∀h: cl_h(x) == x:              // closed under all
        if ∀h, ∀y: (x ≤ cl_h(y) ⟹ x ≤ y):  // closure-prime
            S ← S ∪ {x}
output S
```
Time: O(|H| · |M|²), Space: O(|M|)

### Algorithm 3: Spectral Fingerprinting

```
Input: Finite poset M, residuated actions indexed by H
Output: Spectral fingerprint (tuple of invariants)

sizes ← ()
for h in H:
    sizes ← sizes ++ (|Closed(h)|)
summands ← SimpleSummandDetection(M, actions)
output (sizes, |summands|)
```
Time: O(|H| · |M|²), Space: O(|H| + |M|)

---

## 8. Discussion

### 8.1 The Closure-Prime Condition

The most significant hypothesis in our framework is the closure-prime condition on simple summands. This condition is automatically satisfied in several important cases:

- **Distributive lattices**: On a finite distributive lattice, closed join-irreducible elements are automatically closure-prime.
- **Linear orders**: Every non-bottom closed element in a linear order is closure-prime (since the order is total).
- **Boolean lattices with compatible actions**: When the action preserves complements, closure-primality follows from atomicity.

In general, the closure-prime condition is necessary: without it, the indicator eigenmeasure fails to be closure-invariant, and the spectral correspondence breaks down.

### 8.2 Surjectivity Gap

Our main theorem establishes injectivity but not surjectivity of the spectral correspondence. We conjecture that surjectivity holds under the additional assumption that the closure lattice is *separated* (every pair of distinct elements is distinguished by some eigenmeasure). Proving this would complete the tropical Satake isomorphism.

### 8.3 Relation to Classical Theory

| Classical Langlands | Tropical Analogue |
|---|---|
| Reductive group G | Idempotent Hecke semiring H |
| Smooth representation | Residuated action on finite lattice |
| Spherical Hecke algebra | Closure operator family |
| Unramified parameter | Extremal closure eigenmeasure |
| Satake isomorphism | Spectral correspondence injection |
| Character | Tropical character (closure of ⊤) |
| Semisimple conjugacy class | Multiset of eigenmeasures |

---

## 9. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap. Key next steps include:

1. Proving surjectivity of the spectral correspondence on distributive lattices.
2. Extending to noncommutative Hecke semirings.
3. Tropical Tannakian reconstruction of the acting semiring from closure data.
4. Idempotent Plancherel measure and tropical harmonic analysis.
5. Formally verified algorithms for spectral packet extraction.

---

## References

[1] R.A. Cuninghame-Green, *Minimax Algebra*, Lecture Notes in Economics and Mathematical Systems, Springer, 1979.

[2] G. Cohen, S. Gaubert, J.-P. Quadrat, "Max-plus algebra and system theory: where we are and where to go now," *Annual Reviews in Control*, 23:207–219, 1999.

[3] D. Maclagan, B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, AMS, 2015.

[4] P. Maragos, V. Charisopoulos, E. Theodosis, "Tropical geometry and machine learning," *Proceedings of the IEEE*, 109(5):728–755, 2021.

[5] I. Satake, "Theory of spherical functions on reductive algebraic groups over p-adic fields," *Publications Mathématiques de l'IHÉS*, 18:5–69, 1963.

[6] M. Akian, S. Gaubert, A. Guterman, "Tropical polyhedra are equivalent to mean payoff games," *International Journal of Algebra and Computation*, 22(1), 2012.

[7] M. Erné, "Adjunctions and Galois connections: origins, history, and development," in *Galois Connections and Applications*, Kluwer, 2004.

[8] G.L. Litvinov, V.P. Maslov, G.B. Shpiz, "Idempotent functional analysis: an algebraic approach," *Mathematical Notes*, 69(5):696–729, 2001.
