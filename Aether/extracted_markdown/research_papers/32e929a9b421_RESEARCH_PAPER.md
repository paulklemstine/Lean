# The Mega-Sphere: Inverse Limits, Bernoulli Alignment, and Characteristic Polynomials of the Sphere Tower

## Abstract

We construct the *Mega-Sphere*, an algebraic object defined as the inverse limit of a tower of truncated integer-coefficient sequences, whose projections at level *n* encode data associated to the *n*-sphere Sⁿ. We develop the theory of ℕ-indexed inverse systems from first principles, proving the universal property (existence and uniqueness of the lift) and functoriality (composition of morphisms induces composition on limits). We establish the Euler characteristic formula χ(Sⁿ) = 1 + (−1)ⁿ and prove closed-form partial sum identities. We define the *Bernoulli-sphere weight function* BSW(n) = B'_n · (1 + (−1)ⁿ), prove its universal vanishing at odd dimensions, and compute the cumulative Bernoulli-sphere invariant. We show that the characteristic polynomial pₙ(X) = Xⁿ + (−1)ⁿ is monic of degree *n* for *n* ≥ 1 and that evaluation at 1 recovers the Euler characteristic. The Mega-Sphere is shown to be isomorphic to the space of integer sequences (via an explicit bijection), and we prove that the *Euler encoding* — the element recording all sphere Euler characteristics — has infinite support and escapes every finite filtration level. All results are machine-verified in Lean 4 with Mathlib.

**Keywords:** Inverse limits, Euler characteristic, Bernoulli numbers, sphere tower, characteristic polynomials, formal verification

---

## 1. Introduction

The family of spheres {S⁰, S¹, S², ...} is among the most fundamental objects in topology. Each sphere Sⁿ has well-known topological invariants: its Euler characteristic χ(Sⁿ), its homology groups, and its cohomology ring. While these invariants are computed dimension-by-dimension, a natural question arises: is there a single algebraic object that encodes the data of all spheres simultaneously?

We answer this affirmatively by constructing the **Mega-Sphere**, defined as the inverse limit of a tower of truncated coefficient sequences:

$$\cdots \to \mathbb{Z}^{n+1} \to \mathbb{Z}^n \to \cdots \to \mathbb{Z}^2 \to \mathbb{Z}$$

where the bonding map from level *n*+1 to level *n* drops the last coordinate. The inverse limit is the space of compatible families — equivalently, the space of infinite integer sequences.

### 1.1 Contributions

1. **Inverse limit theory** (§2): We develop ℕ-indexed inverse systems, their limits, morphisms, and functoriality from scratch, proving the universal property and composition laws.

2. **Sphere Euler characteristic** (§3): We prove χ(Sⁿ) = 1 + (−1)ⁿ, establish the recurrence χ(Sⁿ⁺¹) = 2 − χ(Sⁿ), and derive the partial sum formula ∑_{i<2k+1} χ(Sⁱ) = 2k+2.

3. **Bernoulli-sphere alignment** (§4): We define the Sphere Spectrum structure and the Bernoulli-sphere weight BSW(n) = B'_n · (1 + (−1)ⁿ), proving its vanishing at odd dimensions and the even reduction BSW(2k) = 2·B'_{2k}.

4. **Characteristic polynomials** (§5): We define pₙ(X) = Xⁿ + (−1)ⁿ, prove it is monic of degree *n*, and show pₙ(1) = χ(Sⁿ).

5. **Mega-Sphere structure** (§6): We construct the Mega-Sphere, prove it is isomorphic to ℤ^ℕ via explicit bijection, define the dimensional filtration, and show the Euler encoding escapes every finite level.

---

## 2. Inverse Systems and Limits

### 2.1 Definitions

**Definition 2.1** (NatInverseSystem). An *ℕ-indexed inverse system* over a family of types F : ℕ → Type is a collection of bonding maps bond_n : F(n+1) → F(n) for each n ∈ ℕ.

**Definition 2.2** (NatInverseLimit). The *inverse limit* lim←F is the subtype:
```
{ f : Πn, F(n) | ∀n, bond_n(f(n+1)) = f(n) }
```

**Definition 2.3** (Projection). For x ∈ lim←F, the *n-th projection* is π_n(x) = x.val(n).

### 2.2 Universal Property

**Theorem 2.4** (Lift). Given a type X and a compatible family f_n : X → F(n) satisfying bond_n ∘ f_{n+1} = f_n, there exists a unique map lift : X → lim←F such that π_n ∘ lift = f_n.

*Proof.* Define lift(x) = ⟨λn. f_n(x), compatibility⟩. Uniqueness follows from extensionality: if g also satisfies π_n ∘ g = f_n, then for all x and n, g(x).proj(n) = f_n(x) = lift(x).proj(n), so g(x) = lift(x) by Subtype.ext. □

**Theorem 2.5** (Extensionality). x = y in lim←F if and only if π_n(x) = π_n(y) for all n.

### 2.3 Morphisms and Functoriality

**Definition 2.6** (Morphism). A morphism φ : (F,S) → (G,T) consists of component maps φ_n : F(n) → G(n) satisfying T.bond_n ∘ φ_{n+1} = φ_n ∘ S.bond_n.

**Theorem 2.7** (Functoriality). A morphism φ induces a map φ* : lim←F → lim←G defined by φ*(f)(n) = φ_n(f(n)), and:
- (id)* = id (identity preservation)
- (ψ ∘ φ)* = ψ* ∘ φ* (composition preservation)

*Proof.* The compatibility of φ* follows from the compatibility of φ and f. The identity and composition laws follow by extensionality and function composition. □

---

## 3. Sphere Euler Characteristics

### 3.1 The Euler Characteristic Formula

**Definition 3.1.** χ(Sⁿ) := 1 + (−1)ⁿ.

This agrees with the topological Euler characteristic: the standard CW structure on Sⁿ has one 0-cell and one n-cell, giving χ = 1 + (−1)ⁿ.

**Theorem 3.2.** χ(S^{2k}) = 2 and χ(S^{2k+1}) = 0 for all k ∈ ℕ.

*Proof.* (−1)^{2k} = ((−1)²)^k = 1, so χ(S^{2k}) = 1+1 = 2. Similarly (−1)^{2k+1} = −1, giving χ(S^{2k+1}) = 0. □

**Theorem 3.3** (Recurrence). χ(Sⁿ⁺¹) = 2 − χ(Sⁿ).

*Proof.* χ(Sⁿ⁺¹) = 1 + (−1)^{n+1} = 1 − (−1)ⁿ = 2 − (1 + (−1)ⁿ) = 2 − χ(Sⁿ). □

### 3.2 Partial Sums

**Theorem 3.4.** ∑_{i=0}^{2k} χ(Sⁱ) = 2k + 2 for all k ≥ 0.

*Proof.* By induction on k. For k=0: χ(S⁰) = 2 = 2·0+2. For the step:
∑_{i≤2(k+1)} χ(Sⁱ) = ∑_{i≤2k} χ(Sⁱ) + χ(S^{2k+1}) + χ(S^{2k+2}) = (2k+2) + 0 + 2 = 2(k+1)+2. □

---

## 4. The Bernoulli-Sphere Alignment

### 4.1 The Sphere Spectrum

**Definition 4.1** (SphereSpectrum). A *Sphere Spectrum* is a triple (eulerWeight, bernoulliMod, odd_vanishing) where:
- eulerWeight(n) = 1 + (−1)ⁿ
- bernoulliMod(n) = B'_n · eulerWeight(n)
- eulerWeight(2k+1) = 0 for all k

This structure packages the parity alignment between Euler characteristics and Bernoulli numbers into a single algebraic object.

### 4.2 The Bernoulli-Sphere Weight

**Definition 4.2.** BSW(n) := B'_n · (1 + (−1)ⁿ), where B'_n is the n-th Bernoulli number.

**Theorem 4.3** (Odd vanishing). BSW(2k+1) = 0 for all k.

*Proof.* (−1)^{2k+1} = −1, so 1 + (−1)^{2k+1} = 0, making the product zero regardless of B'_{2k+1}. □

**Theorem 4.4** (Even reduction). BSW(2k) = 2·B'_{2k}.

*Proof.* (−1)^{2k} = 1, so BSW(2k) = B'_{2k} · (1+1) = 2·B'_{2k}. □

### 4.3 The Cumulative Invariant

**Definition 4.5.** BSI(N) := ∑_{k=0}^N BSW(k).

**Theorem 4.6.** BSI(2N+1) = BSI(2N) (odd-step invariance).

**Theorem 4.7.** BSI(0) = 2.

The first few values of BSI(2k):
| k | BSI(2k) | Decimal |
|---|---------|---------|
| 0 | 2 | 2.000 |
| 1 | 7/3 | 2.333 |
| 2 | 34/15 | 2.267 |
| 3 | 81/35 | 2.314 |
| 4 | 236/105 | 2.248 |

### 4.4 Growth Analysis (Falsified Conjecture)

**Conjecture 4.8** (Falsified). |BSI(2N)| ≤ C·N² for some constant C.

This conjecture is **false** because BSW(2k) = 2·B'_{2k} and the Bernoulli numbers grow super-exponentially: |B'_{2n}| ~ 4√(πn)(n/(πe))^{2n}. The cumulative sum is eventually dominated by the largest term, which grows far faster than any polynomial.

---

## 5. Characteristic Polynomials

### 5.1 Definition and Basic Properties

**Definition 5.1.** pₙ(X) := Xⁿ + (−1)ⁿ ∈ ℤ[X].

**Theorem 5.2.** pₙ(1) = χ(Sⁿ) for all n.

**Theorem 5.3.** For n ≥ 1, pₙ is monic of degree n.

*Proof.* The leading term is Xⁿ with coefficient 1 (monic). Since n ≥ 1, the degree of the constant term (−1)ⁿ is 0 < n, so natDeg(pₙ) = n. □

### 5.2 Root Structure

The roots of pₙ are the n-th roots of (−1)^{n+1}:
- For even n: roots of Xⁿ = −1, giving e^{i(2k+1)π/n} for k = 0, ..., n−1
- For odd n: roots of Xⁿ = 1, giving e^{2ikπ/n} for k = 0, ..., n−1

All roots lie on the unit circle |z| = 1, and they become equidistributed as n → ∞.

---

## 6. The Mega-Sphere

### 6.1 Construction

**Definition 6.1** (megaSphereSystem). The inverse system with F(n) = Fin(n+1) → ℤ and bond_n(f)(i) = f(castSucc(i)).

**Definition 6.2** (MegaSphere). MegaSphere := lim← megaSphereSystem.

### 6.2 Isomorphism with ℤ^ℕ

**Theorem 6.3.** The maps ofSeq : (ℕ → ℤ) → MegaSphere and toSeq : MegaSphere → (ℕ → ℤ) form an isomorphism.

*Proof.* ofSeq_toSeq shows toSeq ∘ ofSeq = id. toSeq_injective shows toSeq is injective. Together with the explicit construction, this gives a bijection. □

### 6.3 Filtration

**Definition 6.4.** filtration(n) := { x ∈ MegaSphere | ∀k > n, toSeq(x)(k) = 0 }.

**Theorem 6.5** (Monotonicity). m ≤ n implies filtration(m) ⊆ filtration(n).

### 6.4 The Euler Encoding

**Definition 6.6.** eulerEncoding := ofSeq(λn. χ(Sⁿ)).

**Theorem 6.7.** eulerEncoding ∉ filtration(n) for all n.

*Proof.* For any n, take k = 2(n+1) > n. Then eulerEncoding.toSeq(k) = χ(S^{2(n+1)}) = 2 ≠ 0. □

---

## 7. Discussion

### 7.1 Categorical Perspective

The Mega-Sphere construction instantiates the categorical inverse limit for a specific diagram. The universal property (Theorem 2.4) and functoriality (Theorem 2.7) show that lim← is a well-behaved functor from the category of ℕ-indexed inverse systems to Type.

### 7.2 Relationship to p-adic Integers

Our construction parallels the p-adic integers ℤ_p = lim← ℤ/pⁿℤ. Both are inverse limits of finite truncations. The key difference is that our bonding maps (dropping the last coefficient) are "forgetful" rather than "reducing modulo p."

### 7.3 The Parity Phenomenon

The simultaneous vanishing of BSW at odd indices arises from two independent mathematical facts: (1) χ(Sⁿ) = 0 for odd n (topology), and (2) B'_k = 0 for odd k ≥ 3 (number theory). Their product BSW vanishes for a "redundant" reason — either factor alone would suffice. This over-determined vanishing suggests a deeper structural connection.

---

## 8. Future Work

1. **Ring structure on the Mega-Sphere**: Can pointwise multiplication (Hadamard product) on sequences be given topological meaning?

2. **Homological enrichment**: Replace ℤ-valued sequences with graded abelian groups to encode full homology data.

3. **Connection to the J-homomorphism**: The denominators of Bernoulli numbers appear in the image of J in stable homotopy groups of spheres. Can the Bernoulli-sphere invariant be related to stable homotopy invariants?

4. **Tropical geometry**: The parity pattern suggests a tropical analogue where the Mega-Sphere lives over the tropical semiring.

---

## References

1. Atiyah, M.F., Hirzebruch, F. (1961). Vector bundles and homogeneous spaces. Proc. Symposia in Pure Mathematics, 3, 7-38.

2. Serre, J.-P. (1953). Groupes d'homotopie et classes de groupes abéliens. Annals of Mathematics, 58(2), 258-294.

3. Kervaire, M.A., Milnor, J.W. (1963). Groups of homotopy spheres: I. Annals of Mathematics, 77(3), 504-537.

4. Adams, J.F. (1966). On the groups J(X)—IV. Topology, 5(1), 21-71.

5. Mathlib Contributors (2024). Mathlib: The Lean 4 Mathematical Library. https://github.com/leanprover-community/mathlib4
