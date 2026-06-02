# Tropical Memory Compression Algebra: Algebraic Foundations of Memory as Structured Forgetting

## Abstract

We develop the algebraic theory of memory systems viewed as monoid homomorphisms from free monoids to finite monoids, establishing a formal connection to tropical algebra. A memory system φ : FreeMonoid(α) →* S compresses infinite experience streams into finite state representations. We prove: (1) any such system over ≥ 2 symbols is necessarily lossy; (2) information loss forms a congruence that propagates through composition; (3) the cascade (parallel) product of memory systems satisfies a tropical subadditivity law for capacity; (4) post-composition monotonically increases information loss; (5) repeated stimulation eventually produces idempotent memory states. We introduce the *memory spectrum*, a novel invariant measuring the rate at which a memory system explores its state space, and prove its fundamental properties. All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: memory compression, monoid homomorphism, congruence lattice, tropical algebra, free monoid, idempotent stabilization, memory spectrum

---

## 1. Introduction

The question "What is a memory?" admits many answers depending on the discipline. In neuroscience, memory involves synaptic plasticity and neural circuits. In computer science, it involves storage and retrieval algorithms. In information theory, it involves channel capacity and rate-distortion tradeoffs.

We propose a purely algebraic answer: **a memory system is a monoid homomorphism from a free monoid to a finite monoid**. This definition captures the essential structure while abstracting away implementation details:

- The **free monoid** FreeMonoid(α) = List(α) represents the space of all possible experience sequences over alphabet α. Concatenation represents temporal succession.
- The **target monoid** S represents the finite state space. Its monoid operation represents how states compose.
- The **homomorphism** φ : FreeMonoid(α) →* S encodes the compression map, preserving sequential structure.

This framework connects to classical automata theory — the syntactic monoid of a regular language is precisely the image of such a homomorphism — while providing a fresh perspective through the lens of tropical algebra.

### 1.1 Main Contributions

1. **Compression Theorem** (Theorem 3.1): We prove that any memory system over ≥ 2 symbols must be lossy, and that the information loss has congruence structure.

2. **Cascade Product Theory** (Section 4): We formalize the parallel composition of memory systems, proving it satisfies a universal property (Theorem 4.3) and establishing capacity bounds that exhibit tropical subadditivity (Theorems 5.1–5.2).

3. **Tropical Monotonicity** (Theorem 6.1): Post-composition with any monoid homomorphism can only increase information loss. In tropical (logarithmic) terms, the capacity valuation is monotone.

4. **Memory Spectrum** (Definition 7.1): We introduce a novel invariant — the sequence spectrum(k) = |{φ(w) : |w| ≤ k}| — and prove its fundamental properties: base case, monotonicity, and boundedness.

5. **Idempotent Stabilization** (Theorem 8.1): We prove that in any finite monoid, every element admits a positive power that is idempotent, and apply this to show that repeated stimulation of a memory system eventually stabilizes.

All results are machine-verified in Lean 4 using the Mathlib library.

---

## 2. Preliminaries

### 2.1 Free Monoids

The **free monoid** on alphabet α, denoted FreeMonoid(α), is the type of finite lists over α equipped with list concatenation as the monoid operation and the empty list as identity. When |α| ≥ 2, FreeMonoid(α) is infinite (proven via the injection n ↦ aⁿ for any fixed a ∈ α).

### 2.2 Congruences

A **congruence** on a monoid M is an equivalence relation ~ such that x ~ y and x' ~ y' imply xx' ~ yy'. The **kernel congruence** of a homomorphism f : M →* N is defined by Con.ker(f) with x ~ y iff f(x) = f(y). The set of all congruences on M forms a complete lattice.

### 2.3 Tropical Semirings

The **tropical semiring** (ℝ ∪ {∞}, min, +) replaces addition with minimum and multiplication with addition. Tropical algebra naturally arises when taking logarithms of multiplicative structures, converting products to sums and bounds to min/max operations.

---

## 3. Memory Systems and the Compression Theorem

**Definition 3.1** (Memory System). A *memory system* over alphabet α with state space S is a structure:

```
MemorySystem(α, S) = { encode : FreeMonoid(α) →* S }
```

where S is a finite monoid.

**Definition 3.2** (Information Loss Congruence). The *information loss congruence* of a memory system φ is Con.ker(φ.encode), identifying experience streams that produce the same state.

**Theorem 3.1** (Compression). For |α| ≥ 2 and S finite, every memory system φ : FreeMonoid(α) →* S is lossy (non-injective).

*Proof sketch.* FreeMonoid(α) is infinite (via n ↦ aⁿ for a ∈ α). By the pigeonhole principle, an injection from an infinite set to a finite set cannot exist. □

**Corollary 3.2**. The information loss congruence of any memory system over ≥ 2 symbols is non-trivial.

---

## 4. Cascade Product and Universal Property

**Definition 4.1** (Cascade Product). The *cascade product* of memory systems φ₁ : FreeMonoid(α) →* S and φ₂ : FreeMonoid(α) →* T is:

```
cascadeProduct(φ₁, φ₂) = MonoidHom.prod(φ₁.encode, φ₂.encode) : FreeMonoid(α) →* S × T
```

**Theorem 4.1** (Congruence Characterization). Two words x, y are identified by the cascade product iff they are identified by *both* components:

```
Con.ker(cascade) x y  ↔  Con.ker(φ₁) x y ∧ Con.ker(φ₂) x y
```

**Theorem 4.2** (Refinement). The cascade product refines each component:
- Con.ker(cascade) ≤ Con.ker(φ₁)
- Con.ker(cascade) ≤ Con.ker(φ₂)

**Theorem 4.3** (Universality). If a memory system φ₃ refines both φ₁ and φ₂ (i.e., Con.ker(φ₃) ≤ Con.ker(φ₁) and Con.ker(φ₃) ≤ Con.ker(φ₂)), then φ₃ refines the cascade:

```
Con.ker(φ₃) ≤ Con.ker(cascadeProduct(φ₁, φ₂))
```

This establishes the cascade product as the categorical product in the category of memory systems over fixed alphabet α, ordered by congruence refinement.

---

## 5. Tropical Capacity Bounds

**Definition 5.1** (Memory Image). The *memory image* of a memory system φ is:

```
memoryImage(φ) = { s ∈ S | ∃ w ∈ FreeMonoid(α), φ(w) = s }
```

**Theorem 5.1** (Cascade Capacity Upper Bound — Tropical Subadditivity).

```
|image(cascade(φ₁, φ₂))| ≤ |image(φ₁)| × |image(φ₂)|
```

In tropical (logarithmic) terms: log|R₁₂| ≤ log|R₁| + log|R₂|, which is the tropical subadditivity law.

*Proof sketch.* The image of the cascade is contained in image(φ₁) × image(φ₂), since any reachable pair (s, t) must have both s reachable by φ₁ and t reachable by φ₂. The result follows from |A × B| = |A| · |B| and monotonicity of cardinality. □

**Theorem 5.2** (Cascade Capacity Lower Bound).

```
|image(φ₁)| ≤ |image(cascade(φ₁, φ₂))|
```

*Proof sketch.* The projection π₁ : S × T → S maps image(cascade) surjectively onto image(φ₁). By card_image_le, |image(φ₁)| ≤ |image(cascade)|. □

**Corollary 5.3**. Combined: |image(φ₁)| ≤ |image(cascade)| ≤ |image(φ₁)| · |image(φ₂)|.

---

## 6. Tropical Monotonicity

**Theorem 6.1** (Tropical Image Monotonicity). If f : S →* T is a monoid homomorphism and mem₂ = f ∘ mem₁, then:

```
|image(mem₂)| ≤ |image(mem₁)|
```

*Proof.* We show image(mem₂) = f(image(mem₁)), which follows from f ∘ mem₁ = mem₂. Then |f(A)| ≤ |A| for any Finset A. □

This theorem has a natural tropical interpretation: the valuation v(φ) = log|image(φ)| is monotonically non-increasing under post-composition. In the tropical semiring, this is a contraction property.

**Theorem 6.2** (Composition Monotonicity). For any memory system φ and monoid homomorphism f : S →* T:

```
Con.ker(φ) ≤ Con.ker(f ∘ φ)
```

Post-composition can only increase information loss.

---

## 7. The Memory Spectrum

**Definition 7.1** (Memory Spectrum). The *cumulative memory spectrum* of a memory system φ at depth k is:

```
spectrum(φ, k) = { s ∈ S | ∃ w ∈ FreeMonoid(α), |w| ≤ k ∧ φ(w) = s }
```

This measures the "exploration rate" of the memory system — how quickly it visits new states.

**Theorem 7.1** (Base Case). spectrum(φ, 0) = {1}. At depth zero, only the identity state is reachable (via the empty word).

**Theorem 7.2** (Monotonicity). For j ≤ k, spectrum(φ, j) ⊆ spectrum(φ, k).

**Theorem 7.3** (Boundedness). |spectrum(φ, k)| ≤ |S| for all k.

**Conjecture 7.4** (Spectral Stabilization). The spectrum stabilizes by depth |S| - 1:
```
spectrum(φ, |S| - 1) = image(φ)
```

We have verified this computationally for small cases (k=2, m=4) but a general proof remains open.

---

## 8. Idempotent Stabilization

**Theorem 8.1** (Idempotent Power). For any element s of a finite monoid S, there exists n > 0 such that s^(2n) = s^n. Equivalently, s^n is idempotent.

*Proof sketch.* By the pigeonhole principle, the sequence s, s², s³, ... in the finite set S must contain repeats: s^i = s^j for some i < j. Let p = j - i. Then for any m ≥ i, s^(m+p) = s^m. Choose n appropriately so that s^(2n) = s^n by multiple applications of this periodicity. □

**Theorem 8.2** (Memory Idempotent Stabilization). For any memory system φ and input symbol a ∈ α, there exists n > 0 such that:

```
φ(aⁿ)² = φ(aⁿ)     (equivalently: φ(a²ⁿ) = φ(aⁿ))
```

*Proof.* Apply Theorem 8.1 to s = φ(of(a)) and use the homomorphism property. □

---

## 9. Morphisms and Duality

**Definition 9.1** (Memory Morphism). A *memory morphism* from (α, S, φ₁) to (α, T, φ₂) is a monoid homomorphism f : S →* T such that f ∘ φ₁.encode = φ₂.encode.

**Theorem 9.1** (Forgetting Monotonicity). A memory morphism implies the target forgets at least as much as the source:

```
Con.ker(φ₁) ≤ Con.ker(φ₂)
```

**Theorem 9.2** (Congruence-State Duality). Two words are congruent iff they encode to the same state — this is definitional but establishes the fundamental duality between the congruence (what is forgotten) and the image (what is remembered).

---

## 10. Extremal Memory Systems

**The Trivial Memory**: Maps everything to the unit — total amnesia. Its congruence identifies all experience streams.

**The Identity Memory**: (On a free monoid viewed as a state space — infinite, so not a valid memory system.) The identity congruence ⊥ is the finest possible. Every valid memory system's congruence lies between ⊥ and ⊤ in the congruence lattice.

---

## 11. Algorithms

### 11.1 Memory Spectrum Computation

```
Input: Memory system φ (given by generator images), alphabet size k, depth d
Output: spectrum(0), spectrum(1), ..., spectrum(d)

1. Initialize S₀ = {1}  (identity state)
2. For i = 1 to d:
     Sᵢ = Sᵢ₋₁ ∪ { sᵢ₋₁ · φ(a) : sᵢ₋₁ ∈ Sᵢ₋₁, a ∈ α }
     spectrum(i) = |Sᵢ|
3. Return spectrum sequence
```

Time complexity: O(d · |S| · k) where each step generates at most k · |Sᵢ₋₁| new candidates.

### 11.2 Cascade Composition

```
Input: Memory systems φ₁ : α →* S, φ₂ : α →* T
Output: Cascade product φ₁ × φ₂ : α →* S × T

1. For each generator a ∈ α:
     (φ₁ × φ₂)(a) = (φ₁(a), φ₂(a))
2. Extend to all words by multiplication
```

### 11.3 Idempotent Detection

```
Input: Element s in finite monoid S
Output: Smallest n > 0 with s^(2n) = s^n

1. Compute powers s, s², s³, ... tracking visited states
2. When s^i = s^j (i < j), let p = j - i
3. Find smallest n > 0 with n ≡ i mod p and n ≥ i
4. Return n
```

---

## 12. Discussion

### 12.1 Connection to Automata Theory

Our memory systems are precisely the transition monoids of deterministic finite automata. The information loss congruence is the syntactic congruence, and the memory image is the syntactic monoid. This connection is well-known, but our tropical perspective is new: viewing capacity as a tropical valuation connects automata theory to tropical geometry.

### 12.2 Connection to Information Theory

The memory capacity |image(φ)| corresponds to log₂|image(φ)| bits of information. The tropical subadditivity of cascade capacity is analogous to the subadditivity of entropy: H(X,Y) ≤ H(X) + H(Y). The tropical monotonicity theorem is analogous to the data processing inequality: post-processing cannot increase mutual information.

### 12.3 Connection to Tropical Geometry

The congruence lattice of FreeMonoid(α) has a natural tropical structure. The meet of congruences (remembering the union) and join (forgetting the union) correspond to tropical operations. The memory spectrum, viewed as a function spectrum : ℕ → ℕ, traces a path in a tropical space. The stabilization of this path corresponds to reaching a tropical fixed point.

---

## 13. Future Work

1. **Krohn-Rhodes Decomposition**: Decompose memory systems into irreducible components (simple groups and aperiodic monoids). This would classify all possible "atoms of forgetting."

2. **Spectral Stabilization Conjecture**: Prove that the memory spectrum stabilizes by depth |S| - 1.

3. **Tropical Geometry of the Congruence Lattice**: Formalize the tropical structure of the congruence lattice and connect it to tropical varieties.

4. **Quantum Memory Systems**: Extend the framework to quantum channels, where the state space is a matrix algebra and the homomorphism property becomes a completely positive map condition.

5. **Dynamic Memory Allocation**: Allow the state space to grow, modeling memory systems that can allocate new states. This breaks the finite monoid assumption and requires new algebraic tools.

---

## References

1. Eilenberg, S. *Automata, Languages, and Machines*, Vol. B. Academic Press, 1976.
2. Krohn, K. and Rhodes, J. "Algebraic theory of machines." *Trans. AMS* 116 (1965): 450–464.
3. Pin, J.-E. "Syntactic semigroups." In *Handbook of Formal Languages*, Vol. 1, Springer, 1997.
4. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
5. Cover, T. M. and Thomas, J. A. *Elements of Information Theory*. Wiley, 2006.
