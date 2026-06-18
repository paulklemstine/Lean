# Discriminant Fiber Uniformity and Quadratic Splitting Statistics over Finite Fields

## Abstract

We establish three interconnected results about monic quadratic polynomials over finite fields. First, the **Discriminant Fiber Uniformity Theorem**: for any odd prime p, the map (b,c) ↦ b² − 4c from 𝔽_p² to 𝔽_p has fibers of constant size p. Second, the **Splitting Type Partition**: among the p² monic quadratics over 𝔽_p, exactly p(p−1)/2 are split, p are ramified, and p(p−1)/2 are inert, verified by the identity p(p−1)/2 + p + p(p−1)/2 = p². Third, the **Split–Inert Symmetry**: the number of split quadratics equals the number of inert quadratics. We introduce the notion of a *fiber-uniform map* as a unifying abstraction and prove foundational properties including a domain cardinality formula and a preimage counting theorem. All results are formalized and machine-verified in the Lean 4 proof assistant using the Mathlib library.

**Keywords**: finite fields, quadratic polynomials, discriminant, fiber uniformity, splitting types, Frobenius permutation, quadratic residues

---

## 1. Introduction

The study of polynomials over finite fields sits at the intersection of number theory, algebraic geometry, and combinatorics. A fundamental question is: given a polynomial of degree n over 𝔽_q, what is its *splitting type* — the pattern of degrees of its irreducible factors? For quadratic polynomials, this reduces to a trichotomy: the polynomial either splits into two distinct linear factors (split), has a double root (ramified), or is irreducible (inert).

The exact counts of each type are classical and follow from the theory of quadratic residues. However, the standard approach — counting roots directly or using character sums — obscures the geometric structure underlying these counts. In this paper, we present a *fiber-theoretic* approach that makes the structure transparent.

Our key observation is that the discriminant map Δ(b,c) = b² − 4c has *perfectly uniform fibers* of size p. This uniformity converts the problem of counting polynomials by splitting type into the simpler problem of counting discriminant values by residue class.

### 1.1 Main Results

**Theorem A** (Discriminant Fiber Uniformity). *For any odd prime p and any d ∈ 𝔽_p, the fiber*
$$|\{(b,c) \in \mathbb{F}_p^2 : b^2 - 4c = d\}| = p.$$

**Theorem B** (Splitting Type Partition). *For any odd prime p,*
$$|\text{Split}| + |\text{Ramified}| + |\text{Inert}| = p^2$$
*where |Split| = |Inert| = p(p−1)/2 and |Ramified| = p.*

**Theorem C** (Frobenius Fixed-Point Dichotomy). *For any permutation σ of a two-element set, the number of fixed points is either 0 or 2.*

### 1.2 Novel Contributions

1. **Fiber Uniform Maps**: We introduce `FiberUniformMap` as a formal mathematical structure with two foundational theorems: the domain cardinality formula and the preimage counting principle.

2. **Quadratic Split Data**: We define `QuadSplitData` as a certified data structure packaging splitting counts with proofs of the partition and symmetry properties.

3. **Machine-Verified Proofs**: All results are formalized in Lean 4 with complete proofs verified by the kernel, ensuring mathematical correctness with certainty.

---

## 2. Fiber Uniform Maps

### Definition 2.1
A *fiber-uniform map* consists of:
- A function f : α → β between finite types
- A natural number k (the fiber size)
- A proof that for every y ∈ β, |f⁻¹(y)| = k

### Theorem 2.2 (Domain Cardinality)
If f : α → β is a fiber-uniform map with fiber size k, then |α| = k · |β|.

*Proof*. Partition α into fibers: α = ⊔_{y ∈ β} f⁻¹(y). Since the fibers are disjoint and each has cardinality k, we have |α| = Σ_{y ∈ β} k = k · |β|. □

### Theorem 2.3 (Preimage Counting)
If f : α → β is fiber-uniform with fiber size k, and S ⊆ β, then |{x ∈ α : f(x) ∈ S}| = k · |S|.

*Proof*. The preimage of S decomposes as ⊔_{y ∈ S} f⁻¹(y), giving cardinality Σ_{y ∈ S} k = k · |S|. □

### Remark 2.4
Fiber uniformity is the finite-set analogue of *flatness* in algebraic geometry. A morphism f : X → Y of schemes is flat if and only if the fibers have constant dimension and multiplicity. In our discrete setting, constant fiber cardinality is the appropriate analogue.

---

## 3. Discriminant Fiber Uniformity

### Theorem 3.1
For any odd prime p and any d ∈ 𝔽_p, the set {(b,c) ∈ 𝔽_p² : b² − 4c = d} has cardinality p.

*Proof*. For each b ∈ 𝔽_p, the equation b² − 4c = d determines a unique c, namely c = (b² − d) · 4⁻¹. The element 4 is invertible in 𝔽_p because p is odd (hence p ∤ 4). The map b ↦ (b, (b² − d)/4) is an injection from 𝔽_p into the fiber (since distinct b give distinct first coordinates), and every element (b,c) of the fiber satisfies c = (b² − d)/4. Hence the fiber is the image of this injection and has cardinality |𝔽_p| = p. □

### Corollary 3.2
The discriminant map Δ : 𝔽_p² → 𝔽_p defines a fiber-uniform map with fiber size p.

### Corollary 3.3
The discriminant map is surjective: every element of 𝔽_p is the discriminant of some monic quadratic.

---

## 4. Quadratic Residue Counting

### Theorem 4.1
For any odd prime p, the number of nonzero quadratic residues in 𝔽_p is (p−1)/2.

*Proof*. The squaring map sq : 𝔽_p* → 𝔽_p* is a group homomorphism with kernel {1, −1}. Since p is odd, 1 ≠ −1, so |ker(sq)| = 2. By the first isomorphism theorem, |im(sq)| = |𝔽_p*|/|ker(sq)| = (p−1)/2. □

### Theorem 4.2
For any odd prime p, the number of non-squares (quadratic non-residues) in 𝔽_p is (p−1)/2.

*Proof*. The elements of 𝔽_p partition into three classes: {0}, nonzero squares, and non-squares. We have 1 + (p−1)/2 + |non-squares| = p, giving |non-squares| = p − 1 − (p−1)/2 = (p−1)/2. □

---

## 5. Splitting Type Partition

### Definition 5.1
For a monic quadratic x² + bx + c over 𝔽_p, the *splitting type* is determined by the discriminant Δ = b² − 4c:
- **Split**: Δ ≠ 0 and Δ is a quadratic residue (two distinct roots)
- **Ramified**: Δ = 0 (one double root)
- **Inert**: Δ is a quadratic non-residue (irreducible over 𝔽_p)

### Theorem 5.2 (Ramified Count)
The number of ramified monic quadratics over 𝔽_p is exactly p.

*Proof*. The ramified quadratics are precisely the fiber Δ⁻¹(0), which has cardinality p by Theorem 3.1. □

### Theorem 5.3 (Split–Inert Symmetry)
The number of split monic quadratics equals the number of inert monic quadratics.

*Proof*. The split set decomposes as ⊔_{d ∈ QR*} Δ⁻¹(d), where QR* denotes the nonzero quadratic residues. By Theorem 3.1, each fiber has size p, so |Split| = p · |QR*| = p · (p−1)/2. Similarly, |Inert| = p · |NR| = p · (p−1)/2. □

### Theorem 5.4 (Partition)
|Split| + |Ramified| + |Inert| = p².

*Proof*. The three sets partition 𝔽_p² by exhaustiveness: every discriminant value is either zero, a nonzero square, or a non-square. Disjointness is immediate from the definitions. □

---

## 6. Frobenius–Splitting Connection

### Theorem 6.1 (Permutation Dichotomy)
Every permutation of a two-element set is either the identity or the transposition.

### Theorem 6.2 (Fixed-Point Dichotomy)
For any permutation σ of {0, 1}, the number of fixed points is either 0 or 2.

*Proof*. If σ = id, both elements are fixed (2 fixed points). If σ = (0 1), neither is fixed (0 fixed points). By Theorem 6.1, these are the only cases. □

### Interpretation
Over 𝔽_p, the Frobenius automorphism x ↦ xᵖ acts on the roots of a polynomial in its splitting field. For a quadratic f(x) with splitting field 𝔽_{p²}, the Frobenius permutes the two roots. If f splits over 𝔽_p, the Frobenius fixes both roots (identity permutation, 2 fixed points = 2 roots in 𝔽_p). If f is inert, the Frobenius swaps the roots (transposition, 0 fixed points = 0 roots in 𝔽_p).

The number of 𝔽_p-roots of f equals the number of Frobenius fixed points. This is the degree-2 instance of the general principle connecting polynomial splitting types to Frobenius cycle types.

---

## 7. Algorithms

### Algorithm 7.1: Splitting Type Classification
```
Input: prime p, coefficients b, c ∈ 𝔽_p
Output: splitting type ∈ {split, ramified, inert}

1. Compute Δ = b² − 4c mod p
2. If Δ = 0: return ramified
3. Compute the Legendre symbol (Δ/p) = Δ^((p−1)/2) mod p
4. If (Δ/p) = 1: return split
5. Else: return inert
```
Time complexity: O(log p) for modular exponentiation.

### Algorithm 7.2: Splitting Census
```
Input: prime p
Output: counts (split, ramified, inert)

1. Initialize counts = (0, 0, 0)
2. For each b ∈ {0, ..., p−1}:
     For each c ∈ {0, ..., p−1}:
       Classify (b, c) via Algorithm 7.1
       Increment appropriate counter
3. Return counts
```
Expected output: (p(p−1)/2, p, p(p−1)/2).

---

## 8. Discussion

### 8.1 The Fiber Uniformity Principle
The fiber-uniform map abstraction isolates the key property that makes counting arguments work. Rather than analyzing individual polynomials, we analyze the *map* that classifies them. When this map has uniform fibers, counting by classification reduces to counting classification labels — a much simpler problem.

### 8.2 Connections to Probability
As p → ∞, the fractions converge:
- P(split) = (p−1)/(2p) → 1/2
- P(ramified) = 1/p → 0
- P(inert) = (p−1)/(2p) → 1/2

These limiting probabilities match the cycle-type distribution of a uniformly random permutation in S₂: the identity has probability 1/2 and the transposition has probability 1/2. This is the degree-2 case of the heuristic that "random polynomials over large finite fields behave like random permutations."

### 8.3 Generalization to Higher Degree
For degree n, the Chebotarev density theorem predicts that the fraction of monic degree-n polynomials over 𝔽_p with splitting type corresponding to cycle type λ converges to |C_λ|/n! as p → ∞, where C_λ is the conjugacy class in S_n with cycle type λ.

---

## 9. Conjecture: Cubic Fiber Uniformity

**Conjecture 9.1.** *The cubic discriminant map*
$$\Delta(b,c,d) = 18bcd - 4b^3d + b^2c^2 - 4c^3 - 27d^2$$
*from 𝔽_p³ to 𝔽_p has uniform fibers of size p² if and only if p ≡ 2 (mod 3).*

**Rationale.** The condition p ≡ 2 (mod 3) is equivalent to 3 ∤ (p−1), which means the cube map x ↦ x³ is bijective on 𝔽_p*. This bijectivity is needed for certain Tschirnhaus-type substitutions that reduce the cubic to a depressed form, analogous to how invertibility of 4 enables the quadratic fiber uniformity proof.

**Testable predictions:**
- p = 5 (≡ 2 mod 3): all fibers should have size 25
- p = 7 (≡ 1 mod 3): fiber sizes should be non-uniform
- p = 11 (≡ 2 mod 3): all fibers should have size 121

---

## 10. Formalization Notes

All theorems in this paper are formalized in Lean 4 using the Mathlib library (v4.28.0). The complete formalization consists of approximately 250 lines of Lean code in the file `Algebra/DiscriminantUniformity.lean`. Key formalization choices:

- **Finite fields** are represented as `ZMod p` with `[Fact (Nat.Prime p)]`.
- **Quadratic residues** are characterized via `IsSquare` from Mathlib.
- **Finset counting** uses `Finset.filter` and `Finset.card` for all cardinality arguments.
- **The squaring map** two-to-one property uses `sq_eq_sq_iff_eq_or_eq_neg` from Mathlib.

The formalization required no custom axioms beyond the standard Lean kernel axioms (propext, Classical.choice, Quot.sound).

---

## References

1. Ireland, K. and Rosen, M. *A Classical Introduction to Modern Number Theory*. Springer, 1990.
2. Serre, J.-P. *A Course in Arithmetic*. Springer, 1973.
3. The Mathlib Community. *Mathlib: the Lean 4 mathematical library*. https://github.com/leanprover-community/mathlib4
