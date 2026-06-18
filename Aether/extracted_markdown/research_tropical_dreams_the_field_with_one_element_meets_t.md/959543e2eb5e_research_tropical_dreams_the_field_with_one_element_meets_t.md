# The F₁-Tropical Duality: Formalizing the Field with One Element via Tropical Geometry

## Abstract

We formalize the deep connection between the hypothetical "field with one element" F₁ and tropical geometry. We introduce the notion of a **TropicalF1Algebra** — a set equipped with an idempotent commutative "addition" (tropical addition = min) and a commutative "multiplication" (tropical multiplication = +), with an absorbing zero and a multiplicative unit, subject to distributivity. We prove that this structure naturally gives rise to a partial order (meet-semilattice), that the canonical example `(WithTop ℕ, min, +)` satisfies all axioms, and that the F₁-induced order agrees with the standard order. We establish the polytope-vertex correspondence (F₁-points = vertices), the base change theorem (F₁-rank is preserved under extension to ℤ), and the Betti number formula (F₁-Betti numbers = binomial coefficients). All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: field with one element, tropical geometry, F₁-algebra, idempotent semiring, toric variety, lattice polytope, tropical polynomial, corner locus

---

## 1. Introduction

### 1.1 The Field with One Element

The "field with one element" F₁ is a hypothetical algebraic object that has been the subject of speculation since Tits (1957). While no field with one element exists in the classical sense, the *category* of F₁-modules (= pointed sets) and F₁-algebras (= commutative monoids with absorbing zero) is well-defined and has been studied extensively by Deitmar (2005), Connes-Consani (2010), and others.

The key motivation is the observation that formulas in algebraic geometry over F_q often have meaningful limits as q → 1. For instance, the Gaussian binomial coefficient [n choose k]_q converges to the ordinary binomial coefficient C(n,k) as q → 1, and |GL_n(F_q)| / (q-1)^n converges to n! as q → 1.

### 1.2 Tropical Geometry

Tropical geometry replaces the standard arithmetic operations (+, ×) with (min, +), yielding the **tropical semiring** (ℝ ∪ {∞}, min, +). This transforms algebraic varieties into piecewise-linear objects: polynomial curves become graphs of piecewise-linear functions, and their zero sets become polyhedral complexes.

### 1.3 The Connection

The central observation is that tropical addition (min) is **idempotent**: a ⊕ a = a. This is the algebraic signature of "characteristic 1" — in a field with one element, the only scalar multiple of any element is itself. We formalize this connection through a novel algebraic structure and prove the resulting correspondence theorems.

---

## 2. The TropicalF1Algebra Structure

### 2.1 Definition

**Definition 2.1** (TropicalF1Algebra). A *TropicalF1Algebra* over a type α is a tuple (⊕, ⊗, 0, 1) where:
- (α, ⊕) is an idempotent commutative monoid with identity 0
- (α, ⊗) is a commutative monoid with identity 1
- ⊗ distributes over ⊕: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
- 0 is absorbing for ⊗: 0 ⊗ a = 0

The idempotency axiom `∀ a, a ⊕ a = a` is the defining characteristic that distinguishes F₁-algebras from ordinary semirings.

### 2.2 The Canonical Example

**Theorem 2.2**. The type `WithTop ℕ` (= ℕ ∪ {∞}) forms a TropicalF1Algebra with:
- ⊕ = min (tropical addition)
- ⊗ = + (tropical multiplication)  
- 0 = ⊤ (infinity, the absorbing element)
- 1 = 0 (the additive identity of ℕ)

*Proof.* The key non-trivial axiom is distributivity: `a + min(b, c) = min(a + b, a + c)`. This holds because addition in WithTop ℕ is monotone with respect to the natural order. ∎

### 2.3 The F₁-Order

**Definition 2.3**. The *F₁-order* on a TropicalF1Algebra is defined by: a ≤ b iff a ⊕ b = a.

**Theorem 2.4** (F₁-Order Properties).
1. ≤ is reflexive (from idempotency: a ⊕ a = a)
2. ≤ is antisymmetric (from commutativity)
3. ≤ is transitive (from associativity)
4. ⊕ computes meets: a ⊕ b ≤ a and a ⊕ b ≤ b

*Proof.* 
- Reflexivity: a ⊕ a = a by idempotency.
- Antisymmetry: If a ⊕ b = a and b ⊕ a = b, then a = a ⊕ b = b ⊕ a = b.
- Transitivity: If a ⊕ b = a and b ⊕ c = b, then a ⊕ c = (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c) = a ⊕ b = a.
- Meet property: (a ⊕ b) ⊕ a = a ⊕ (b ⊕ a) = a ⊕ (a ⊕ b) = (a ⊕ a) ⊕ b = a ⊕ b. ∎

**Theorem 2.5** (Order Agreement). For `WithTop ℕ`, the F₁-order agrees with the standard order: `min a b = a ↔ a ≤ b`.

---

## 3. Tropical Convex Hulls and F₁-Spans

### 3.1 Tropical Linear Combinations

**Definition 3.1**. A *tropical linear combination* over an F₁-algebra A with generators from a set S is an expression ⊕_{i} (w_i ⊗ s_i) where s_i ∈ S and w_i ∈ A. The *tropical span* of S is the set of all such combinations.

**Theorem 3.2**. The zero element is always in the tropical span (via the empty combination).

### 3.2 Connection to Classical Convex Hulls

In the WithTop ℕ instance, a tropical linear combination ⊕_i (w_i ⊗ s_i) = min_i (w_i + s_i) computes the lower envelope of translated copies of the generators. This is precisely the tropical analogue of a convex combination.

---

## 4. The Polytope Correspondence

### 4.1 Lattice Polytopes and F₁-Points

**Definition 4.1**. A *lattice polytope* P in ℤⁿ is given by a finite nonempty set of vertices.

**Definition 4.2**. The *F₁-points* of P are its vertices: F₁(P) = vertices(P).

**Theorem 4.3** (Vertex-Lattice Point Inequality). |F₁(P)| ≤ |P ∩ ℤⁿ|.

This reflects the geometric fact that vertices are a subset of lattice points.

### 4.2 The Normal Fan and Euler Characteristic

**Definition 4.4**. The *normal fan* Σ(P) of a polytope P has one maximal cone per vertex of P.

**Theorem 4.5** (Euler Characteristic = F₁-Points). For the toric variety X(Σ) associated to a complete fan Σ = Σ(P):
  χ(X(Σ)) = |maximal cones of Σ| = |vertices(P)| = |F₁(P)|

### 4.3 Base Change

**Theorem 4.6** (Base Change Preserves Rank). The free F₁-module of rank r base-changes to a free ℤ-module of rank r: rk_{F₁}(F₁^r) = rk_ℤ(ℤ^r) = r.

---

## 5. Tropical Polynomials

### 5.1 Evaluation and Corner Loci

**Definition 5.1**. A *tropical polynomial* with coefficients c₀, ..., c_{n-1} ∈ WithTop ℕ evaluates at x as:
  f(x) = inf_i (c_i + i · x)

**Definition 5.2**. The *corner locus* of f is the set of points where the infimum is achieved by at least two distinct terms.

**Theorem 5.3**. The all-⊤ polynomial evaluates to ⊤ everywhere (the zero polynomial is identically zero).

**Theorem 5.4**. A constant polynomial evaluates to its constant: if f has one term c₀, then f(x) = c₀.

---

## 6. F₁-Betti Numbers

### 6.1 Definition

**Definition 6.1**. The *F₁-Betti number* β_k of a simplicial complex Σ is the number of k-dimensional faces (faces with k+1 vertices).

**Definition 6.2**. The *tropical Euler characteristic* is χ_{F₁}(Σ) = Σ_k (-1)^k β_k.

### 6.2 The Binomial Theorem

**Theorem 6.3** (F₁-Betti = Binomial). For the complete simplicial complex on n+1 vertices:
  β_k = C(n+1, k+1)

*Proof.* The k-dimensional faces are exactly the (k+1)-element subsets of the vertex set {0, 1, ..., n}. The number of such subsets is C(n+1, k+1). ∎

This connects the F₁-Betti numbers to the classical Betti numbers of projective space ℙⁿ, which are all 1 (one in each even dimension). The complete simplicial complex is the "F₁-model" of ℙⁿ, and its face counts encode the full combinatorial structure.

---

## 7. Monotonicity of Tropical Scaling

**Theorem 7.1** (Scaling Preserves Order). In the WithTop ℕ tropical F₁-algebra, if a ≤ b then c ⊗ a ≤ c ⊗ b for all c.

*Proof.* Since a ≤ b means min(a,b) = a, and c + (·) is monotone in WithTop ℕ, we have min(c+a, c+b) = c+a, i.e., c ⊗ a ≤ c ⊗ b. ∎

This theorem is fundamental for tropical convexity: it ensures that the tropical span is closed under "translation" (tropical scaling), making the tropical convex hull well-defined.

---

## 8. Discussion

### 8.1 Significance

Our formalization provides the first machine-verified treatment of the F₁-tropical correspondence. The key contributions are:

1. **Novel structure**: The `TropicalF1Algebra` captures the essence of F₁-geometry in a clean, axiom-based framework.
2. **Order-theoretic bridge**: The proof that idempotent addition induces a meet-semilattice connects F₁-algebra to order theory and lattice theory.
3. **Polytope correspondence**: The vertex = F₁-point identification gives a rigorous foundation for the intuition that "F₁-geometry is combinatorics."
4. **Binomial formula**: The F₁-Betti = binomial result connects face counting to the combinatorics of projective space.

### 8.2 Falsifiable Conjecture

**Conjecture 8.1** (Tropical Fundamental Theorem). A tropical polynomial of degree n in one variable has at most n corner points (points in the corner locus where distinct terms achieve the minimum).

This is the tropical analogue of the fundamental theorem of algebra. It should follow from the fact that the lower envelope of n+1 linear functions with distinct slopes has at most n breakpoints, but a formal proof requires careful handling of the WithTop ℕ arithmetic.

**Test**: For the tropical polynomial f(x) = min(a₀, a₁ + x, a₂ + 2x) with generic coefficients, verify that there are exactly 2 corner points.

---

## 9. Future Work

1. **Full categorical equivalence**: Prove that the category of finitely generated TropicalF1Algebras is equivalent to the category of commutative monoids with absorbing zero.

2. **Tropical scheme theory**: Define F₁-schemes as locally monoided spaces and prove the base change functor to ℤ-schemes recovers toric varieties.

3. **Zeta functions**: Define the F₁-zeta function ζ_{F₁}(X, s) and prove it specializes to the Hasse-Weil zeta function after base change.

4. **Tropical homology**: Define tropical (co)homology groups and prove they compute the F₁-Betti numbers.

---

## References

1. Connes, A. and Consani, C. "Schemes over F₁ and zeta functions." *Compositio Math.* 146 (2010), 1383–1415.
2. Deitmar, A. "Schemes over F₁." *Number fields and function fields — two parallel worlds.* Birkhäuser, 2005, 87–100.
3. Lorscheid, O. "The geometry of blueprints." *Adv. Math.* 229 (2012), 1804–1846.
4. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
5. Tits, J. "Sur les analogues algébriques des groupes semi-simples complexes." *Colloque d'algèbre supérieure* (1957), 261–289.
6. Mikhalkin, G. "Tropical geometry and its applications." *Proceedings of the ICM* (2006), Vol. II, 827–852.
