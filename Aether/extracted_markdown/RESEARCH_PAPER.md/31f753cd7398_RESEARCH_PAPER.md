# Non-Abelian Arithmetic Phase Classification: The Abelianization Principle and Its Obstructions

## Abstract

We develop a formal theory of arithmetic phase classification for finite groups, centered on the *order profile* — the function mapping each positive integer n to the number of group elements whose order divides n. We prove that the order profile is a group isomorphism invariant and use it to establish that the dihedral group D₄ and the quaternion group Q₈ are non-isomorphic despite having isomorphic abelianizations. We introduce the concept of *p-perfectness* and prove that groups of order coprime to a prime p are p-perfect, establishing conditions under which the abelianization captures all p-torsion information. We prove that the order profile of a direct product decomposes multiplicatively and that groups of odd order have exactly one involution. All main results are machine-verified in Lean 4 with Mathlib. We discuss applications to lattice gauge theory, topological phase classification, and cryptographic group selection.

**Keywords:** finite groups, abelianization, torsion invariants, order profile, involution count, non-isomorphism, group homology, formal verification

## 1. Introduction

### 1.1 Motivation

The abelianization G^ab = G/[G,G] of a group G is one of the most fundamental invariants in algebra. It captures the "commutative shadow" of G — the quotient by the commutator subgroup that forces all elements to commute. For many applications in algebraic topology, number theory, and physics, the abelianization provides sufficient information about the group's arithmetic structure.

However, the abelianization is a lossy projection: it discards all information carried by the commutator subgroup [G,G]. A natural question arises: *when does the abelianization capture all arithmetically relevant information, and when does it fail?*

This paper addresses this question through the lens of *torsion invariants*. We introduce the **order profile** — a complete record of how many group elements satisfy g^n = 1 for each n — and show that it provides a strictly finer invariant than the abelianization for non-abelian groups.

### 1.2 Main Results

1. **Order Profile Invariance** (Theorem 3.1): The order profile is preserved by group isomorphisms, providing a necessary condition for isomorphism.

2. **D₄ ≇ Q₈ Theorem** (Theorem 4.1): The dihedral group D₄ and the quaternion group Q₈ are non-isomorphic, proved by showing they have different involution counts (6 vs 2).

3. **p-Perfect Coprimality** (Theorem 5.1): If gcd(p, |G|) = 1, then G is p-perfect — no non-identity element has order p.

4. **Odd-Order Involution Theorem** (Theorem 6.1): Groups of odd order have exactly one involution (the identity).

5. **Product Formula** (Theorem 7.1): The order profile of a direct product decomposes multiplicatively.

6. **Torsion Detection** (Theorem 8.1): p-perfectness is detectable from the order profile — it transfers between groups with matching profiles.

### 1.3 Related Work

The study of involution counts traces back to Frobenius and Schur (1906), who related the involution count to the sum of Frobenius-Schur indicators over irreducible representations. Our work connects this classical result to modern questions in arithmetic phase classification and topological quantum field theory.

The non-isomorphism of D₄ and Q₈ is well-known (see e.g., Dummit and Foote, §2.1), but our proof via the order profile invariant provides a systematic framework that generalizes to arbitrary groups. The connection to the Lyndon-Hochschild-Serre spectral sequence for identifying when abelianization suffices was suggested by the work of Brown (1982) on group cohomology.

## 2. Definitions and Notation

### 2.1 The Order Profile

**Definition 2.1** (Order Profile). For a finite group G, the *order profile* at n ∈ ℕ is:

    OrderProfile_G(n) = |{g ∈ G : g^n = 1}|

The *involution count* is InvCount(G) = OrderProfile_G(2).

**Definition 2.2** (Arithmetic Torsion Invariant). The full arithmetic torsion invariant of G is the structure (profile, |G|) where profile : ℕ → ℕ is the order profile function, satisfying:
- profile(0) = |G| (since g⁰ = 1 for all g)
- If m | n, then profile(m) ≤ profile(n) (divisibility monotonicity)

### 2.2 p-Perfectness

**Definition 2.3** (p-Perfect). A finite group G is *p-perfect* for a prime p if:

    ∀g ∈ G, g^p = 1 ⟹ g = 1

Equivalently, G has no element of order p.

### 2.3 Phase Class

**Definition 2.4** (Phase Class). The *arithmetic phase class* of a finite group G is the pair (|G^ab|, T_G) where T_G is the arithmetic torsion invariant.

## 3. The Order Profile as an Invariant

**Theorem 3.1** (Isomorphism Invariance). If φ : G → H is a group isomorphism, then OrderProfile_G(n) = OrderProfile_H(n) for all n ∈ ℕ.

*Proof.* We exhibit a bijection between the sets S_G = {g ∈ G : g^n = 1} and S_H = {h ∈ H : h^n = 1}. The restriction of φ to S_G maps into S_H because φ(g^n) = φ(g)^n = φ(1) = 1. Injectivity follows from the injectivity of φ. Surjectivity follows because for any h ∈ S_H, the element g = φ⁻¹(h) satisfies g^n = φ⁻¹(h)^n = φ⁻¹(h^n) = φ⁻¹(1) = 1. □

**Corollary 3.2.** The order profile determines the group order: if G and H have the same order profile, then |G| = |H|.

*Proof.* OrderProfile_G(0) = |G| and OrderProfile_H(0) = |H|. □

**Theorem 3.3** (Lagrange Profile). OrderProfile_G(|G|) = |G| for any finite group G.

*Proof.* By Lagrange's theorem, the order of every element divides |G|, so g^{|G|} = 1 for all g ∈ G. □

**Theorem 3.4** (Monotonicity). If m | n, then OrderProfile_G(m) ≤ OrderProfile_G(n).

*Proof.* If g^m = 1 and n = mk, then g^n = g^{mk} = (g^m)^k = 1^k = 1. □

## 4. The D₄ vs Q₈ Counterexample

### 4.1 The Groups

The dihedral group D₄ (order 8) consists of rotations r⁰, r¹, r², r³ and reflections sr⁰, sr¹, sr², sr³ with multiplication rules derived from r⁴ = s² = 1 and srs⁻¹ = r⁻¹.

The quaternion group Q₈ (order 8) consists of {±1, ±i, ±j, ±k} with Hamilton's multiplication rules i² = j² = k² = ijk = -1.

Both groups have abelianization Z/2 × Z/2.

### 4.2 Involution Counts

**Theorem 4.1** (D₄ ≇ Q₈). The dihedral group D₄ is not isomorphic to the quaternion group Q₈.

*Proof.* We compute:
- InvCount(D₄) = 6: the involutions are {1, r², sr⁰, sr¹, sr², sr³}
- InvCount(Q₈) = 2: the involutions are {1, -1}

Since 6 ≠ 2 and the involution count is an isomorphism invariant (Theorem 3.1 at n = 2), D₄ ≇ Q₈. □

### 4.3 Complete Order Profile Comparison

| n | D₄ | Q₈ | Match? |
|---|----|----|--------|
| 1 | 1  | 1  | ✓      |
| 2 | 6  | 2  | ✗      |
| 3 | 1  | 1  | ✓      |
| 4 | 8  | 8  | ✓      |

The profile at n = 2 is the unique distinguisher at small values. This confirms that the abelianization Z/2 × Z/2 is insufficient: it "sees" the agreement at n = 4 but misses the disagreement at n = 2.

### 4.4 The Frobenius-Schur Explanation

The Frobenius-Schur theorem provides a representation-theoretic explanation. Both D₄ and Q₈ have 5 irreducible representations: four 1-dimensional and one 2-dimensional. For D₄, the 2D representation is real (Frobenius-Schur indicator ν = +1), contributing +2 to the involution count. For Q₈, the 2D representation is quaternionic (ν = -1), contributing -2. The sum 1+1+1+1+2 = 6 for D₄ versus 1+1+1+1-2 = 2 for Q₈.

## 5. p-Perfect Groups

**Theorem 5.1** (Coprime p-Perfectness). Let G be a finite group and p a prime with p ∤ |G|. Then G is p-perfect.

*Proof.* By contradiction. If g ≠ 1 satisfies g^p = 1, then ord(g) | p. Since p is prime, ord(g) = p. By Lagrange's theorem, p = ord(g) divides |G|, contradicting p ∤ |G|. □

**Corollary 5.2.** If p ∤ |G|, then OrderProfile_G(p) = 1.

*Proof.* By Theorem 5.1, the only element with g^p = 1 is the identity. □

**Computational Examples:**
- D₄ is 3-perfect (|D₄| = 8, 3 ∤ 8)
- Q₈ is 3-perfect (|Q₈| = 8, 3 ∤ 8)
- Neither D₄ nor Q₈ is 2-perfect (both have elements of order 2)

## 6. The Involution Parity Theorem

**Theorem 6.1** (Odd-Order Involution Theorem). If |G| is odd, then InvCount(G) = 1.

*Proof.* This is a special case of Corollary 5.2 with p = 2: if 2 ∤ |G|, then OrderProfile_G(2) = 1. □

This theorem connects group theory to number-theoretic parity. It implies that the involution count is a non-trivial invariant only for groups of even order. For odd-order groups, the abelianization captures all 2-torsion information vacuously (there is none to capture).

## 7. The Product Formula

**Theorem 7.1** (Product Decomposition). For finite groups G and H:

    OrderProfile_{G×H}(n) = OrderProfile_G(n) · OrderProfile_H(n)

*Proof.* The key observation is that (g,h)^n = (g^n, h^n) in a direct product. Therefore (g,h)^n = (1,1) if and only if g^n = 1 and h^n = 1. The set {(g,h) ∈ G×H : (g,h)^n = 1} is the Cartesian product of {g ∈ G : g^n = 1} and {h ∈ H : h^n = 1}, so its cardinality is the product of the individual cardinalities. □

**Application.** For the abelianization Z/2 × Z/2:

    OrderProfile_{Z/2×Z/2}(2) = OrderProfile_{Z/2}(2)² = 2² = 4

But InvCount(D₄) = 6 ≠ 4 and InvCount(Q₈) = 2 ≠ 4. This gives another proof that neither D₄ nor Q₈ is isomorphic to Z/2 × Z/2, and hence neither is abelian.

## 8. Torsion Detection Transfer

**Theorem 8.1** (Torsion Detection). Let G and H be finite groups with OrderProfile_G(p) = OrderProfile_H(p) for a prime p. If G is p-perfect, then H is p-perfect.

*Proof.* If G is p-perfect, then OrderProfile_G(p) = 1 (only the identity satisfies g^p = 1). By assumption, OrderProfile_H(p) = 1. The singleton filter set {h ∈ H : h^p = 1} = {a} for some a. Since 1^p = 1, we have 1 ∈ the filter set, so a = 1. For any h with h^p = 1, we have h ∈ {1}, so h = 1. □

## 9. Algorithms

### 9.1 Order Profile Computation

**Algorithm 1**: ComputeOrderProfile(G, max_n)

```
Input: Finite group G (as multiplication table), max_n ∈ ℕ
Output: profile : {0, ..., max_n} → ℕ

1. For each g ∈ G, compute ord(g) by repeated multiplication
2. For n = 0 to max_n:
     profile[n] = |{g ∈ G : ord(g) divides n}|
3. Return profile
```

**Complexity:** Time O(|G|² + |G|·max_n), Space O(|G| + max_n).

### 9.2 p-Perfectness Test

**Algorithm 2**: IsPPerfect(G, p)

```
Input: Finite group G, prime p
Output: Boolean

1. For each g ∈ G \ {1}:
     if g^p = 1 and ord(g) = p: return False
2. Return True
```

**Complexity:** Time O(|G|·p), Space O(1).

### 9.3 Phase Classification

**Algorithm 3**: ClassifyPhase(G)

```
Input: Finite group G
Output: PhaseClass

1. Compute order_dist = {ord(g) : g ∈ G} with multiplicities
2. Compute profile = ComputeOrderProfile(G, |G|)
3. Compute inv_count = profile[2]
4. Check is_abelian = ∀g,h ∈ G: gh = hg
5. Return (|G|, is_abelian, profile, inv_count, order_dist)
```

## 10. Computational Experiments

### 10.1 Order Profile Data

We computed order profiles for all groups of order ≤ 24 constructible from our library:

| Group | Order | Involutions | Element Order Distribution |
|-------|-------|-------------|----------------------------|
| Z/6   | 6     | 2           | {1:1, 2:1, 3:2, 6:2}      |
| S₃    | 6     | 4           | {1:1, 2:3, 3:2}            |
| Z/8   | 8     | 2           | {1:1, 2:1, 4:2, 8:4}      |
| D₄    | 8     | 6           | {1:1, 2:5, 4:2}            |
| Q₈    | 8     | 2           | {1:1, 2:1, 4:6}            |
| A₄    | 12    | 4           | {1:1, 2:3, 3:8}            |
| S₄    | 24    | 10          | {1:1, 2:9, 3:8, 4:6}      |

### 10.2 Involution Ratio as Security Metric

The ratio InvCount(G)/|G| measures the "involution density":

| Group | InvCount(G)/|G| |
|-------|-----------------|
| Z/8   | 0.25            |
| Q₈    | 0.25            |
| D₄    | 0.75            |
| S₃    | 0.67            |
| S₄    | 0.42            |

Groups with lower involution density have less exploitable algebraic structure for square-root attacks in cryptographic applications.

## 11. Applications

### 11.1 Lattice Gauge Theory

In Hamiltonian lattice gauge theory with gauge group G, the topological order of the confined phase is related to the group homology H₂(G; ℤ). Our results show that gauge theories with D₄ and Q₈ gauge groups have different topological orders despite their identical abelianizations. The involution count provides a computable proxy for this distinction.

### 11.2 Symmetry-Protected Topological Phases

SPT phases with symmetry group G are classified by H²(G; U(1)). The difference between D₄ and Q₈ SPT classifications demonstrates that the "naive" approach of classifying SPT phases by the abelianization alone is insufficient for non-abelian symmetry groups.

### 11.3 Cryptographic Group Selection

The involution density InvCount(G)/|G| provides a measure of algebraic attack surface for group-based cryptographic protocols. Q₈ achieves the minimal involution density among non-cyclic groups of order 8, making it the optimal choice for protocols sensitive to square-root attacks.

## 12. Discussion and Open Questions

### 12.1 The Obstruction Theory

The full obstruction to abelianization capturing torsion information should live in the Lyndon-Hochschild-Serre spectral sequence for the extension 1 → [G,G] → G → G^ab → 1. The E² page has E²_{s,t} = H_s(G^ab; H_t([G,G]; ℤ)). When [G,G] is p-perfect, the p-primary part of H₁([G,G]) vanishes, and the spectral sequence suggests that the p-torsion in H_n(G) comes from H_n(G^ab). Formalizing this spectral sequence argument in Lean requires significantly more infrastructure than currently available in Mathlib.

### 12.2 Open Problem: Derived Abelianization

Is there a functorial construction Ab_n(G) (a "derived abelianization") such that:
1. Ab₁(G) = G^ab (the usual abelianization)
2. Ab_n(G) captures all torsion information in H_k(G; ℤ) for k ≤ n
3. Ab_n(G) is computable for finitely presented groups

Such a construction would systematize the process of recovering the information lost by abelianization.

### 12.3 Computational Completeness

**Open Question:** Does the full order profile (at all n ∈ ℕ) determine the isomorphism class of a finite group? The answer is known to be *no* in general — there exist non-isomorphic groups with identical order profiles — but characterizing when this happens remains open.

## 13. Future Work

1. **Spectral sequence formalization**: Develop the Lyndon-Hochschild-Serre spectral sequence in Lean/Mathlib to formalize the obstruction theory.

2. **Higher homology computation**: Implement algorithms for computing H_n(G; ℤ) for finite groups given by presentation and verify the homological predictions computationally.

3. **Classification up to order 64**: Extend the computational experiments to all groups of order ≤ 64 using the GAP system, testing the supersolvable completeness conjecture.

4. **Non-abelian Iwasawa theory**: Investigate whether the order profile has a p-adic analog relevant to Iwasawa theory for non-abelian extensions.

## References

1. K. S. Brown, *Cohomology of Groups*, Graduate Texts in Mathematics 87, Springer, 1982.

2. C. W. Curtis and I. Reiner, *Methods of Representation Theory*, Wiley, 1981.

3. D. S. Dummit and R. M. Foote, *Abstract Algebra*, 3rd edition, Wiley, 2004.

4. G. Frobenius and I. Schur, "Über die reellen Darstellungen der endlichen Gruppen," *Sitzungsberichte der Königlich Preussischen Akademie der Wissenschaften zu Berlin*, 1906, pp. 186–208.

5. A. Fröhlich, *Galois Module Structure of Algebraic Integers*, Ergebnisse der Mathematik und ihrer Grenzgebiete, Springer, 1983.

6. R. C. Lyndon, "The cohomology theory of group extensions," *Duke Math. J.*, 15 (1948), pp. 271–292.

7. G. P. Hochschild and J.-P. Serre, "Cohomology of group extensions," *Trans. Amer. Math. Soc.*, 74 (1953), pp. 110–134.

8. The mathlib Community, *Mathlib: a unified library of mathematics formalized*, *Journal of Automated Reasoning*, 2024.
