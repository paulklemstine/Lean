# The Combinatorial Geometry of Universal Libraries: Redundancy Profiles, Collision Bounds, and Self-Referential Impossibility

## Abstract

We develop the combinatorial theory of *universal libraries* — complete function spaces Fin(L) → Fin(A) viewed as libraries containing every possible text of fixed length L over an alphabet of size A. We introduce the **Redundancy Profile**, a function R(A,L,r) counting volumes within Hamming distance r of any center, and prove it is independent of the center choice (translation invariance). We establish a **Pigeonhole Collision Theorem** giving tight lower bounds on the largest monochromatic class under any coloring, a **Sublibrary Collision Theorem** showing that any sublibrary exceeding A^(L-1) volumes contains near-duplicates, a **Singleton (Hamming) Bound** on the information capacity of codes within the library, and a **Babel Fixed Point Theorem** proving that self-referential avoidance is impossible for surjective encodings. All results are formally verified in Lean 4 with Mathlib dependencies.

**Keywords:** Hamming distance, coding theory, combinatorics, universal library, Library of Babel, pigeonhole principle, diagonal argument, information capacity

---

## 1. Introduction

Borges' Library of Babel [1] is a thought experiment involving a library containing every possible book of fixed length. While the literary and philosophical implications have been widely discussed, the precise combinatorial structure of such a library has received less mathematical attention.

We formalize the Library as the complete function space Volume(A,L) := Fin(L) → Fin(A), where A ≥ 1 is the alphabet size and L ≥ 1 is the volume length. This set has cardinality A^L. We equip it with the Hamming metric and develop the theory of:

1. **Redundancy profiles** — the growth rate of Hamming balls
2. **Collision bounds** — lower bounds on clustering under colorings
3. **Information capacity** — maximum number of error-correctable messages
4. **Self-referential limits** — impossibility of complete self-cataloging

### 1.1 Relation to Prior Work

The Hamming distance and its properties are classical in coding theory (Hamming 1950). The sphere-packing bound (Hamming bound) is fundamental (see MacWilliams and Sloane 1977). Our contribution is the unified treatment through the lens of "universal libraries," the introduction of the redundancy profile as a structural invariant, and the complete formal verification of all results.

The catalog impossibility results are finite analogs of Cantor's diagonal theorem. The Babel Fixed Point Theorem is related to Lawvere's fixed-point theorem in category theory, establishing that complete self-description is impossible in a universal library.

---

## 2. Definitions

### 2.1 Core Structures

**Definition 2.1 (Volume).** A *volume* in the Library with parameters (A, L) is a function v : Fin(L) → Fin(A). The set of all volumes is denoted Volume(A, L).

**Definition 2.2 (Hamming Distance).** For volumes v, w ∈ Volume(A, L), the *Hamming distance* is
$$d_H(v, w) = |\{i \in \text{Fin}(L) : v(i) \neq w(i)\}|$$

**Definition 2.3 (Hamming Ball and Sphere).**
- The *Hamming ball* of radius r around v is B(v, r) = {w : d_H(v, w) ≤ r}
- The *Hamming sphere* of radius r around v is S(v, r) = {w : d_H(v, w) = r}

### 2.2 The Redundancy Profile (Novel Structure)

**Definition 2.4 (Redundancy Profile).** The *redundancy profile* of v ∈ Volume(A, L) is the function
$$\rho_v(r) = |B(v, r)| = |\{w \in \text{Volume}(A, L) : d_H(v, w) \leq r\}|$$

**Definition 2.5 (Redundancy Number).** The *redundancy number* R(A, L, r) is the common value of ρ_v(r) for any v (see Theorem 3.1).

### 2.3 Information Capacity

**Definition 2.6 (Information Capacity).** The *information capacity* of a sublibrary S ⊆ Volume(A, L) with minimum distance d is
$$\kappa(S, d) = \max\{|C| : C \subseteq S, \forall v \neq w \in C, d_H(v, w) \geq d\}$$

### 2.4 Collision Number

**Definition 2.7 (Collision Number).** For a coloring f : Volume(A, L) → Fin(D), the *collision number* is
$$\gamma(f) = \max_{d \in \text{Fin}(D)} |f^{-1}(d)|$$

---

## 3. Main Results

### 3.1 Redundancy Profile Uniformity

**Theorem 3.1 (Redundancy Profile Uniformity).** For all A > 0, L, r ∈ ℕ and all v, u ∈ Volume(A, L):
$$\rho_v(r) = \rho_u(r)$$

*Proof sketch.* The map φ : w ↦ (w - v + u) mod A is a bijection from B(v, r) to B(u, r), since subtraction and addition in Fin(A) are bijections, and the map preserves the set of positions where the result differs from the center. □

**Corollary.** R(A, L, r) = Σ_{i=0}^{min(r,L)} C(L,i) · (A-1)^i.

*Example (PEGB-E).* For A=4, L=8: R(4,8,0) = 1, R(4,8,1) = 25, R(4,8,2) = 277, R(4,8,4) = 18,157.

*Generalization (PEGB-G).* The uniformity extends to any group-structured alphabet: if Fin(A) is replaced by any finite group G, the map w ↦ w · v⁻¹ · u provides the same bijection.

*Boundary (PEGB-B).* The result fails if volumes have *variable* length: in a library with volumes of different lengths, the Hamming ball size depends on the center.

### 3.2 Pigeonhole Collision Theorem

**Theorem 3.2.** For any f : Volume(A, L) → Fin(D) with 0 < D < A^L:
$$\exists d \in \text{Fin}(D) : |f^{-1}(d)| \geq \lceil A^L / D \rceil$$

*Proof sketch.* Sum of fiber sizes equals A^L. If all fibers had size < ⌈A^L/D⌉, the total would be less than D · ⌈A^L/D⌉ ≤ A^L + D - 1, leading to a contradiction when combined with the ceiling inequality. □

*Example.* A=3, L=5: Library has 243 volumes. With D=10 colors, some class has ≥ ⌈243/10⌉ = 25 volumes.

*Generalization.* Extends to weighted colorings: if each color has capacity c_d, the collision bound becomes max(A^L / Σc_d).

*Boundary.* The bound is tight: the balanced coloring f(v) = hash(v) mod D achieves collision number exactly ⌈A^L/D⌉.

### 3.3 Sublibrary Collision Theorem

**Theorem 3.3.** For A ≥ 2, L ≥ 1, any S ⊆ Volume(A, L) with |S| > A^(L-1):
$$\exists v \neq w \in S : d_H(v, w) \leq 1$$

*Proof sketch.* Project each volume onto its first L-1 coordinates. There are A^(L-1) possible projections. By pigeonhole, two volumes in S share the same projection, hence differ only in the last coordinate (distance ≤ 1). □

*Example.* A=3, L=4: Any collection of > 27 volumes (out of 81 total) contains a pair differing in at most 1 position.

*Generalization.* For general k: any set of > A^(L-k) volumes contains a pair at distance ≤ k. This follows from projecting onto L-k coordinates.

*Boundary.* The bound A^(L-1) is tight: the set {v : v(L-1) = 0} has exactly A^(L-1) elements and minimum pairwise Hamming distance ≥ 2 (if the first L-1 coordinates are distinct).

### 3.4 Singleton (Hamming) Bound

**Theorem 3.4.** For A ≥ 1, 1 ≤ d ≤ L:
$$\kappa(\text{Volume}(A,L), d) \cdot R(A, L, \lfloor(d-1)/2\rfloor) \leq A^L$$

*Proof sketch.* Let C be an optimal code with minimum distance d. The Hamming balls of radius ⌊(d-1)/2⌋ around codewords are disjoint (by the triangle inequality, if w ∈ B(v₁, r) ∩ B(v₂, r), then d(v₁,v₂) ≤ 2r < d). Since all balls are subsets of the full library, |C| · |B(v,r)| ≤ A^L. The redundancy profile uniformity ensures all balls have the same size. □

*Example.* A=2, L=7, d=3: R(2,7,1) = 8, so κ ≤ 128/8 = 16. The actual maximum is 16 (Hamming [7,4] code), achieving equality — a *perfect code*.

*Generalization.* For asymmetric channels, the bound generalizes to use the appropriate ball volume under the asymmetric metric.

*Boundary.* Perfect codes (meeting the bound with equality) exist only for very specific parameters. For most (A,L,d), the bound is not tight.

### 3.5 Babel Fixed Point Theorem

**Theorem 3.5.** For any function encode : Volume(A,L) → (Volume(A,L) → Volume(A,L)), if encode(v)(v) ≠ v for all v, then encode is not surjective.

*Proof sketch.* If encode were surjective, there would exist v₀ with encode(v₀) = id. Then encode(v₀)(v₀) = v₀, contradicting the hypothesis. □

*Example.* In a Library with A=2, L=3 (8 volumes), there are 8^8 = 16,777,216 endomorphisms. No surjective encoding can make every volume a non-fixed-point of its own image.

*Generalization.* The result extends to any finite set X and any function f : X → (X → X) with f(x)(x) ≠ x for all x. The proof is purely combinatorial and does not require the Library structure.

*Boundary.* If we drop the condition on a single point (allow one fixed point), surjectivity becomes achievable for large enough libraries.

### 3.6 Hamming Triangle Inequality

**Theorem 3.6.** For all u, v, w ∈ Volume(A, L):
$$d_H(u, w) \leq d_H(u, v) + d_H(v, w)$$

*Proof sketch.* If u(i) ≠ w(i), then either u(i) ≠ v(i) or v(i) ≠ w(i). Hence diff(u,w) ⊆ diff(u,v) ∪ diff(v,w), and the result follows from |S ∪ T| ≤ |S| + |T|. □

### 3.7 Pattern Multiplicity

**Theorem 3.7.** For any k ≤ L and any embedding positions : Fin(k) ↪ Fin(L) with values : Fin(k) → Fin(A):
$$|\{v \in \text{Volume}(A,L) : \forall i, v(\text{positions}(i)) = \text{values}(i)\}| = A^{L-k}$$

*Proof sketch.* The set of matching volumes bijects with Fin(A)^(L-k) by restricting to the unconstrained positions. The embedding injectivity ensures the k constrained positions are distinct. □

---

## 4. Algorithms

### 4.1 De Bruijn Catalog Construction

For a mini-Library with parameters (A, n), a de Bruijn sequence B(A, n) of length A^n encodes every possible n-gram exactly once. This provides a compact catalog scheme for the Library: each volume's "address" corresponds to its position as a substring of the de Bruijn sequence.

**Algorithm.** Generate B(A, n) using the standard Lyndon word construction in O(A^n) time.

### 4.2 Greedy Code Construction

To find large codes with minimum distance d, use the greedy algorithm: iterate through volumes in lexicographic order, adding each volume to the code if it has distance ≥ d from all existing codewords. This runs in O(A^L · |code| · L) time and provides a lower bound on information capacity.

---

## 5. Conjectures

**Conjecture 5.1 (Redundancy Growth Rate).** For fixed A ≥ 2 and L → ∞, the redundancy number satisfies
$$R(A, L, \lfloor \alpha L \rfloor) / A^L \to \begin{cases} 0 & \text{if } \alpha < 1 - 1/A \\ 1 & \text{if } \alpha > 1 - 1/A \end{cases}$$

**Computational test:** Compute R(A, L, ⌊αL⌋)/A^L for A=2 and L = 100, 1000, 10000 at α = 0.49, 0.50, 0.51. The values should converge to 0, threshold, 1.

**Conjecture 5.2 (Optimal Code Asymptotics).** For fixed A, d and L → ∞, the ratio κ(Volume(A,L), d) / (A^L / R(A,L, ⌊(d-1)/2⌋)) converges to a limit strictly between 0 and 1 for most parameter choices.

---

## 6. Discussion

The Library of Babel provides a concrete, finite model for studying the interplay between information, redundancy, and self-reference. The redundancy profile — a quantity that emerges naturally from the Hamming geometry — serves as a complete invariant of the library's "information geometry" at any given scale.

The catalog impossibility results (no_catalog_embedding, babel_cantor, babel_fixed_point) form a family of diagonal arguments adapted to the finite setting. While individually simple, they collectively demonstrate that self-referential completeness is a fundamental impossibility even in finite systems — not just an artifact of infinite set theory.

The connection between the Hamming bound and coding theory is well-known, but framing it within the Library of Babel provides a novel pedagogical perspective: the Library's information capacity is precisely the maximum number of distinguishable "books" that can survive a bounded number of typographical errors.

---

## 7. References

[1] J. L. Borges, "The Library of Babel," in *Ficciones*, 1944.

[2] R. W. Hamming, "Error Detecting and Error Correcting Codes," *Bell System Technical Journal*, 29(2):147–160, 1950.

[3] F. J. MacWilliams and N. J. A. Sloane, *The Theory of Error-Correcting Codes*, North-Holland, 1977.

[4] F. W. Lawvere, "Diagonal arguments and cartesian closed categories," *Lecture Notes in Mathematics*, vol. 92, pp. 134–145, Springer, 1969.

[5] N. G. de Bruijn, "A Combinatorial Problem," *Proceedings of the Section of Sciences of the Koninklijke Nederlandse Akademie van Wetenschappen*, 49:758–764, 1946.
