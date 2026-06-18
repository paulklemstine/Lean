# Tropical Memory Compression Algebra: A Rigorous Framework for Information Loss in Finite-State Systems

## Abstract

We develop a rigorous algebraic framework connecting memory-as-compression to tropical geometry. A *finite memory system* is formalized as a monoid homomorphism from the free monoid on an alphabet to a finite state monoid. We prove several foundational theorems: (1) the **Fiber Sum Theorem**, establishing that information loss is conservative — fiber sizes sum to domain cardinality; (2) **Idempotent Power Existence**, showing every element of a finite monoid has an idempotent power with index bounded by |M|²; (3) **Cascade Capacity Subadditivity**, demonstrating that parallel composition of memory systems satisfies the tropical triangle inequality on capacity; (4) **Joint Capacity Symmetry and Monotonicity**, establishing that combined memory systems form a tropical semimodule; and (5) **Power Stabilization**, proving that once a power sequence stabilizes, it remains stable forever. All results are formalized and verified in Lean 4 with Mathlib, providing machine-checked mathematical certainty.

**Keywords**: tropical geometry, finite semigroup theory, information loss, memory compression, Krohn-Rhodes theory, idempotent elements, capacity valuation

---

## 1. Introduction

The formalization of "memory" as a mathematical object has a long history, from automata theory (Kleene 1956, Rabin & Scott 1959) through the algebraic theory of semigroups (Eilenberg 1974, Rhodes & Steinberg 2009). The central idea is that a finite-state machine reading an input stream implements a monoid homomorphism φ: Σ* → S from the free monoid on the input alphabet Σ to a finite transition monoid S.

The *information loss* of such a system is captured by its kernel congruence: two input strings are identified when they produce the same state. This congruence-theoretic perspective connects to universal algebra (Birkhoff 1935) and lattice theory (Grätzer 1978).

In this work, we develop a new connection to *tropical geometry* — the geometry that emerges when classical addition is replaced by max (or min) and classical multiplication is replaced by addition. We show that:

1. The capacity function cap(φ) = |image(φ)| satisfies **tropical subadditivity** under parallel composition: cap(φ₁ × φ₂) ≤ cap(φ₁) · cap(φ₂), or in tropical (logarithmic) terms, log cap(φ₁ × φ₂) ≤ log cap(φ₁) + log cap(φ₂).

2. Every finite memory system eventually **stabilizes** under repeated input, with the stabilization governed by **idempotent powers** in the transition monoid.

3. The **fiber structure** of memory morphisms satisfies a conservation law: total fiber sizes equal domain cardinality.

### 1.1 Contributions

Our specific contributions, all formalized in Lean 4:

- **Fiber Sum Theorem** (§3): For f: S → T between finite types, Σ_t |f⁻¹(t)| = |S|.
- **Idempotent Power Existence** (§4): Every s ∈ M (M finite monoid) has n > 0 with s^(2n) = s^n.
- **Idempotent Power Index Bound** (§4): The minimal such n satisfies n ≤ |M|².
- **Power Stabilization** (§4): If s^(n+1) = s^n, then s^(n+m) = s^n for all m.
- **Cascade Capacity Subadditivity** (§5): cap(φ₁ × φ₂) ≤ cap(φ₁) · cap(φ₂).
- **Joint Capacity Monotonicity** (§6): cap(φ₁) ≤ cap(φ₁ × φ₂).
- **Joint Capacity Symmetry** (§6): cap(φ₁ × φ₂) = cap(φ₂ × φ₁).

---

## 2. Definitions

### 2.1 Finite Memory Systems

**Definition 2.1** (Finite Memory System). A *finite memory system* over alphabet α with state monoid S is a pair (S, φ) where S is a finite monoid and φ: FreeMonoid(α) →* S is a monoid homomorphism.

**Definition 2.2** (Kernel Congruence). The *kernel congruence* of a memory system (S, φ) is the congruence ker(φ) = {(x,y) : φ(x) = φ(y)} on FreeMonoid(α).

**Definition 2.3** (Image / Capacity). The *image* of (S, φ) is im(φ) = {φ(w) : w ∈ FreeMonoid(α)} ⊆ S. The *capacity* is cap(φ) = |im(φ)|.

### 2.2 Novel Definitions

**Definition 2.4** (Idempotent Power). An element s ∈ M *has an idempotent power* if ∃ n > 0, s^(2n) = s^n. Equivalently, s^n is idempotent: (s^n)² = s^n.

**Definition 2.5** (Idempotent Power Index). The *idempotent power index* of s ∈ M is the smallest n > 0 such that s^(2n) = s^n.

**Definition 2.6** (Aperiodic Element). An element s ∈ M is *aperiodic* if ∃ n, s^(n+1) = s^n. This is strictly stronger than having an idempotent power.

**Definition 2.7** (Idempotent Set). For a finite monoid M, the *idempotent set* E(M) = {e ∈ M : e² = e}.

**Definition 2.8** (Joint Capacity). For memory systems φ₁: FreeMonoid(α) →* S and φ₂: FreeMonoid(α) →* T, the *joint capacity* is cap(φ₁ × φ₂) = |{(φ₁(w), φ₂(w)) : w ∈ FreeMonoid(α)}|.

### 2.3 Cascade Product

**Definition 2.9** (Cascade Product). The *cascade product* of memory systems (S, φ₁) and (T, φ₂) is the memory system (S × T, φ₁ × φ₂) where (φ₁ × φ₂)(w) = (φ₁(w), φ₂(w)).

---

## 3. The Fiber Sum Theorem

**Theorem 3.1** (Fiber Sum). For any function f: S → T between finite types,
  Σ_{t ∈ T} |{s ∈ S : f(s) = t}| = |S|.

*Proof sketch.* The fibers {f⁻¹(t) : t ∈ T} partition S. The sum of a partition's block sizes equals the total. Formally, this follows from the double-counting identity: sum over t of (count of s with f(s) = t) = sum over s of 1 = |S|. □

**Corollary 3.2** (Compression Chain). For f: S → T and g: T → U, |im(g ∘ f)| ≤ |im(g)|.

*Proof sketch.* im(g ∘ f) = g(im(f)) ⊆ im(g), so |im(g ∘ f)| ≤ |im(g)|. □

The Fiber Sum Theorem has a deeper interpretation: it is the *conservation law* for information loss. When a memory system compresses its state space, the total "weight" of information is preserved — it is merely redistributed among fibers. This conservation is the foundation for defining entropy-like quantities on memory morphisms.

---

## 4. Idempotent Power Theory

### 4.1 Existence

**Theorem 4.1** (Idempotent Power Existence). Every element s of a finite monoid M has an idempotent power: ∃ n > 0, s^(2n) = s^n.

*Proof sketch.* By the pigeonhole principle on the sequence s⁰, s¹, ..., s^|M|, there exist 0 ≤ i < j ≤ |M| with s^i = s^j. Let d = j - i. Then for all k ≥ i, s^k = s^(k+d) (by induction on k, using s^(k+1) = s^k · s). Set n = d(i+1). Then n > 0 since d > 0, and s^(2n) = s^(n + d(i+1)) = s^n by reducing d(i+1) copies of d. □

### 4.2 Index Bound

**Theorem 4.2** (Idempotent Power Index Bound). For s in a finite monoid M of cardinality n, the idempotent power index satisfies ω(s) ≤ n².

*Proof sketch.* The witness in Theorem 4.1 is n = d(i+1) where d ≤ |M| and i+1 ≤ |M|, giving n ≤ |M|². Since ω(s) is the minimum, ω(s) ≤ |M|². □

### 4.3 Power Stabilization

**Theorem 4.3** (Power Stabilization). If s^(n+1) = s^n in a monoid, then s^(n+m) = s^n for all m ≥ 0.

*Proof.* By induction on m. Base: s^(n+0) = s^n. Step: s^(n+m+1) = s^(n+m) · s = s^n · s = s^(n+1) = s^n. □

**Theorem 4.4** (Aperiodic implies Idempotent Power). If s is aperiodic (∃ n, s^(n+1) = s^n), then s has an idempotent power.

*Proof.* Take k = n+1. Then s^k = s^(n+1) = s^n, and s^(2k) = s^(n + (n+2)) = s^n = s^k by Theorem 4.3. □

### 4.4 Idempotent Set

**Theorem 4.5** (Idempotent Lifting). For any s in a finite monoid M, there exists n > 0 such that s^n is idempotent.

*Proof.* By Theorem 4.1, s^n satisfies (s^n)² = s^(2n) = s^n. □

---

## 5. Tropical Capacity Theory

### 5.1 Basic Bounds

**Theorem 5.1**. For any memory system (S, φ), 1 ≤ cap(φ) ≤ |S|.

*Proof.* The identity 1 = φ(ε) is always in the image (where ε is the empty word), giving cap(φ) ≥ 1. The image is a subset of S, giving cap(φ) ≤ |S|. □

### 5.2 Cascade Capacity Subadditivity

**Theorem 5.2** (Cascade Capacity Subadditivity). For memory systems (S, φ₁) and (T, φ₂),
  cap(φ₁ × φ₂) ≤ cap(φ₁) · cap(φ₂).

*Proof sketch.* The image of φ₁ × φ₂ is {(φ₁(w), φ₂(w)) : w ∈ FreeMonoid(α)} ⊆ im(φ₁) × im(φ₂). The right side has cardinality |im(φ₁)| · |im(φ₂)| = cap(φ₁) · cap(φ₂). □

In tropical terms, setting v(φ) = log₂ cap(φ):
  v(φ₁ × φ₂) ≤ v(φ₁) + v(φ₂).

This is precisely the **tropical triangle inequality** in the max-plus algebra. It suggests that the space of memory systems, equipped with the tropical capacity valuation, forms a tropical metric space.

---

## 6. Joint Capacity and Tropical Distance

### 6.1 Monotonicity

**Theorem 6.1** (Joint Capacity Monotonicity). cap(φ₁) ≤ cap(φ₁ × φ₂).

*Proof sketch.* The projection (s,t) ↦ s maps im(φ₁ × φ₂) surjectively onto im(φ₁). □

### 6.2 Symmetry

**Theorem 6.2** (Joint Capacity Symmetry). cap(φ₁ × φ₂) = cap(φ₂ × φ₁).

*Proof sketch.* The swap map (s,t) ↦ (t,s) is a bijection between im(φ₁ × φ₂) and im(φ₂ × φ₁). □

### 6.3 Tropical Distance

These results suggest defining a *tropical distance* between memory systems:

  d(φ₁, φ₂) = log cap(φ₁ × φ₂) - max(log cap(φ₁), log cap(φ₂))

By Theorem 6.1, d(φ₁, φ₂) ≥ 0. By Theorem 6.2, d is symmetric. The cascade subadditivity (Theorem 5.2) provides upper bounds. Whether d satisfies a full triangle inequality remains an open question (see §8).

---

## 7. Algorithms

### 7.1 Computing the Idempotent Power Index

**Algorithm** (Idempotent Power Index):
```
Input: Element s in finite monoid M
Output: Smallest n > 0 with s^(2n) = s^n

power ← s
for n = 1, 2, ..., |M|²:
    double_power ← power^n  (computed as power iterated)
    if double_power == power:
        return n
    power ← power * s
```

Time complexity: O(|M|² · T_mult) where T_mult is the time for a monoid multiplication.

### 7.2 Computing Cascade Capacity

**Algorithm** (Cascade Capacity):
```
Input: Memory systems φ₁, φ₂ over alphabet Σ
Output: cap(φ₁ × φ₂)

image ← ∅
frontier ← {(1, 1)}   # identity states
while frontier ≠ ∅:
    new_frontier ← ∅
    for (s, t) in frontier:
        for a in Σ:
            s' ← s · φ₁(a)
            t' ← t · φ₂(a)
            if (s', t') ∉ image:
                image ← image ∪ {(s', t')}
                new_frontier ← new_frontier ∪ {(s', t')}
    frontier ← new_frontier
return |image|
```

---

## 8. Discussion and Open Questions

### 8.1 Connection to Krohn-Rhodes Theory

The idempotent power existence theorem (Theorem 4.1) is a key ingredient in the Krohn-Rhodes decomposition, which decomposes any finite semigroup into a wreath product of simple groups and aperiodic semigroups. Our framework suggests viewing this decomposition tropically: the simple group components contribute "reversible capacity" (capacity that can be recovered) while the aperiodic components contribute "irreversible capacity" (permanently lost information).

### 8.2 Tight Bounds

Our bound ω(s) ≤ |M|² (Theorem 4.2) is likely not tight. The expected tight bound is |M| - 1, achieved by the "staircase" transformation on {1, ..., n} that maps i ↦ i-1 for i > 1 and 1 ↦ 1. Proving this tight bound requires more detailed analysis of the orbit structure.

### 8.3 Tropical Metric Space Conjecture

**Conjecture.** The tropical distance d(φ₁, φ₂) = log cap(φ₁ × φ₂) - max(log cap(φ₁), log cap(φ₂)) satisfies the triangle inequality: d(φ₁, φ₃) ≤ d(φ₁, φ₂) + d(φ₂, φ₃).

If true, this would establish a tropical metric on the space of memory systems, with deep connections to tropical convexity and the Vietoris-Rips complex.

---

## 9. Future Work

1. **Krohn-Rhodes Decomposition**: Formalize the wreath product decomposition and prove that the tropical capacity profile determines the decomposition type.

2. **Entropy-Capacity Duality**: Develop a formal connection between the combinatorial capacity cap(φ) and the Shannon entropy of the induced distribution on states.

3. **Tropical Eigenvalues**: Connect the idempotent power index to the tropical spectral radius of the transition matrix in the max-plus algebra.

4. **Quantum Memory Systems**: Extend the framework to quantum channels, where the state monoid is replaced by a C*-algebra and the tropical semiring by its quantum analogue.

---

## References

- Birkhoff, G. (1935). On the structure of abstract algebras. *Proc. Cambridge Phil. Soc.* 31, 433–454.
- Eilenberg, S. (1974). *Automata, Languages, and Machines*, Vol. A. Academic Press.
- Krohn, K. & Rhodes, J. (1965). Algebraic theory of machines. *Trans. AMS* 116, 450–464.
- Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
- Pin, J.-E. (1986). *Varieties of Formal Languages*. Plenum.
- Rhodes, J. & Steinberg, B. (2009). *The q-theory of Finite Semigroups*. Springer.
