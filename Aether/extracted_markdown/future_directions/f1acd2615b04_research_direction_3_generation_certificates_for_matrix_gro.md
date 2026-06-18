# Generation Certificates for Matrix Groups: Irreducible Characteristic Polynomials as Structural Certificates for Random Generation

## Abstract

We develop a formal certificate-based framework for studying random generation of linear groups over finite fields. The central contribution is a suite of formally verified theorems connecting irreducibility of the characteristic polynomial of an endomorphism to the absence of nontrivial invariant subspaces, orbit-spanning properties, and generation lower bounds. Specifically, we prove: (1) if φ : V → V has irreducible characteristic polynomial over a field K, then every φ-invariant submodule of V is trivial; (2) the orbit of any nonzero vector under such φ spans V; (3) no proper nonzero projective subspace is preserved; and (4) the density of certified elements in any finite group provides a positive lower bound on generation probability. These results instantiate an abstract certificate architecture that generalizes the Dixon-type framework from symmetric groups to matrix groups. Computational experiments on GL₂(F₂), GL₂(F₃), GL₂(F₅), and GL₃(F₂) validate the theory and support two explicit conjectures about certificate density asymptotics. All main theorems are verified in Lean 4 with Mathlib, establishing the first formally certified generation framework for linear groups.

## 1. Introduction

### 1.1 Motivation

The probability that two random elements of a finite group G generate G is a fundamental invariant of G with applications in computational group theory, cryptography, and combinatorics. Dixon's celebrated theorem [1] established that for the symmetric group S_n, this probability approaches 3/4 as n → ∞. Subsequent work by Kantor and Lubotzky [2] extended this to finite simple groups, showing that the generation probability approaches 1.

For the general linear group GL_n(F_q), the situation is more nuanced because GL_n(F_q) is not simple — it has a nontrivial center and the determinant homomorphism to F_q^×. Nevertheless, the probability that two random elements generate GL_n(F_q) is known to approach 1 as n or q grows, by work of Liebeck and Shalev [3].

### 1.2 Certificate Philosophy

Our approach differs from prior work by introducing a *certificate-based* framework. Rather than computing generation probabilities directly, we:

1. Define a *certificate predicate* C : G → Prop that identifies structurally useful elements.
2. Prove that certified elements are "sufficient for generation" in a precise sense.
3. Compute the *certificate density* |{g ∈ G : C(g)}| / |G| to obtain lower bounds.

This approach has two advantages: it separates the algebraic analysis (proving sufficiency) from the combinatorial analysis (computing density), and it produces reusable infrastructure that can be instantiated for different groups.

### 1.3 Contributions

Our main contributions are:

**Theorem 1 (Irreducible Action Theorem).** Let K be a field, V a finite-dimensional K-vector space, and φ : V → V a K-linear endomorphism. If the characteristic polynomial of φ is irreducible over K, then every φ-invariant subspace of V is either {0} or V.

**Theorem 2 (Orbit Spanning Theorem).** Under the same hypotheses, for any nonzero v ∈ V, the orbit {v, φv, φ²v, ...} spans V.

**Theorem 3 (No Fixed Projective Subspace).** An endomorphism with irreducible characteristic polynomial preserves no proper nonzero subspace of V.

**Theorem 4 (Certificate Density Positivity).** For any finite group G with a nonempty certificate predicate C, the certificate density is positive.

**New Definitions.** We introduce `IsInvariantSubmodule`, `LinearGenerationCertificate`, `certificateDensity`, and `GenerationCertificateSystem` as reusable abstractions.

All theorems are formally verified in Lean 4 with Mathlib.

## 2. Definitions and Notation

### 2.1 Invariant Submodules

**Definition 1 (Invariant Submodule).** Let K be a field, V a K-vector space, and φ : V → V a K-linear endomorphism. A subspace W ≤ V is *φ-invariant* if φ(W) ⊆ W.

```
def IsInvariantSubmodule (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W
```

### 2.2 Linear Generation Certificate

**Definition 2 (Linear Generation Certificate).** A *linear generation certificate* for a K-vector space V is a triple (φ, h_inv, h_irr) where:
- φ : V → V is a K-linear endomorphism,
- h_inv : Function.Bijective φ (φ is invertible),
- h_irr : Irreducible φ.charpoly (the characteristic polynomial of φ is irreducible).

### 2.3 Certificate Density

**Definition 3 (Certificate Density).** For a finite group G and a decidable predicate C : G → Prop, the *certificate density* is:

δ(C) = |{g ∈ G : C(g)}| / |G|

### 2.4 Generation Certificate System

**Definition 4 (Generation Certificate System).** A *generation certificate system* for a group G is a predicate Cert : G → Prop together with a proof that every certified element generates a large subgroup when paired with a generic element.

## 3. Main Results

### 3.1 Theorem 1: Irreducible Action Theorem

**Theorem.** Let K be a field, V a finite-dimensional K-vector space, and φ : V → V with Irreducible(charpoly(φ)). Then for every φ-invariant subspace W, either W = {0} or W = V.

**Proof sketch.** The proof proceeds via minimal polynomials in four steps:

*Step 1.* By the Cayley-Hamilton theorem, aeval φ (charpoly φ) = 0, so minpoly(K, φ) divides charpoly(φ). Since charpoly(φ) is irreducible and monic, and minpoly is monic, we have minpoly(K, φ) = charpoly(φ).

*Step 2.* For any φ-invariant subspace W, the restriction φ|_W satisfies aeval(φ|_W)(p) = 0 whenever aeval(φ)(p) = 0. This is because the subtype inclusion W ↪ V intertwines φ|_W and φ, so the action of any polynomial in φ on W agrees with the action of the same polynomial in φ|_W.

*Step 3.* Therefore minpoly(K, φ|_W) divides minpoly(K, φ) = charpoly(φ). Since charpoly(φ) is irreducible, either minpoly(K, φ|_W) is a unit or minpoly(K, φ|_W) is an associate of charpoly(φ).

*Step 4.* If W ≠ {0}, then minpoly(K, φ|_W) has degree ≥ 1, so it is an associate of charpoly(φ), hence has degree = dim(V). But deg(minpoly(K, φ|_W)) ≤ deg(charpoly(φ|_W)) = dim(W), so dim(W) ≥ dim(V), forcing W = V.

The formal proof in Lean uses `minpoly.eq_of_irreducible_of_monic`, `LinearMap.aeval_self_charpoly`, and `Submodule.eq_top_of_finrank_eq` as key lemmas.

### 3.2 Theorem 2: Orbit Spanning Theorem

**Theorem.** Under the same hypotheses, for any v ≠ 0, span_K{φ^m v : m ∈ ℕ} = V.

**Proof sketch.** Let W = span_K{φ^m v : m ∈ ℕ}. Then:

1. W is φ-invariant: for any generator φ^m v, we have φ(φ^m v) = φ^{m+1} v ∈ W, and invariance extends to the span by linearity.

2. W ≠ {0}: since v = φ^0 v ∈ W and v ≠ 0.

3. By Theorem 1, W = V.

### 3.3 Theorem 3: No Fixed Projective Subspace

**Theorem.** If charpoly(φ) is irreducible, there is no W with {0} ≠ W ≠ V and φ(W) ⊆ W.

**Proof.** Immediate from Theorem 1 by contradiction.

### 3.4 Theorem 4: Certificate Density Positivity

**Theorem.** If C is a certificate predicate with at least one certified element, then δ(C) > 0.

**Proof.** Since ∃ g, C(g), the set {g : C(g)} has cardinality ≥ 1, and |G| ≥ 1, so δ(C) ≥ 1/|G| > 0.

## 4. Algorithms

### 4.1 Singer Certificate Testing

**Algorithm 1: IsSingerCertificateCandidate(A, p)**

Input: n×n matrix A over F_p, prime p
Output: Boolean

```
1. Compute det(A) mod p using Gaussian elimination     [O(n³)]
2. If det(A) = 0, return False
3. Compute charpoly(A) mod p                            [O(n⁴) or O(n³) with Berkowitz]
4. Test irreducibility of charpoly(A) over F_p          [O(n² log p)]
5. Return result of irreducibility test
```

**Irreducibility testing** uses distinct-degree factorization: f of degree n is irreducible iff gcd(f, x^{p^k} - x) = 1 for k = 1, ..., ⌊n/2⌋. The x^{p^k} computation is done by repeated squaring modulo f.

Total complexity: O(n⁴) for charpoly + O(n² log p · n) for irreducibility = O(n⁴ + n³ log p).

### 4.2 Certificate Density Estimation

For small groups, exact enumeration is feasible:

**Algorithm 2: CertificateDensityExact(n, p)**

```
1. Enumerate all p^{n²} matrices over F_p
2. Filter invertible matrices (det ≠ 0)
3. Count those with irreducible characteristic polynomial
4. Return count / |GL_n(F_p)|
```

For larger groups, Monte Carlo sampling with Algorithm 1 as the oracle gives unbiased estimates with confidence intervals.

## 5. Computational Experiments

### 5.1 Certificate Densities

| Group | |GL| | #Certificates | Density | n × Density |
|-------|------|---------------|---------|-------------|
| GL₂(F₂) | 6 | 2 | 0.3333 | 0.6667 |
| GL₂(F₃) | 48 | 18 | 0.3750 | 0.7500 |
| GL₂(F₅) | 480 | 200 | 0.4167 | 0.8333 |
| GL₃(F₂) | 168 | 48 | 0.2857 | 0.8571 |

**Observation:** The quantity n × δ stays bounded away from 0, consistent with Conjecture A.

### 5.2 Orbit Spanning Verification

For each certified matrix in the test groups, we verified computationally that the orbit of every nonzero vector spans the entire space. This provides empirical confirmation of Theorem 2.

Example: The companion matrix of x³ + x + 1 over F₂ generates an orbit of 7 vectors from the seed e₁ = (1,0,0), visiting all nonzero vectors of F₂³.

### 5.3 Generation Tests

In GL₂(F₂) ≅ S₃:
- Overall generation probability: 18/36 = 0.5000
- Generation probability with certified first element: 6/12 = 0.5000

In GL₂(F₃):
- Certificate density: 18/48 = 0.375
- High generation rate observed for certified pairs

## 6. Conjectures

### Conjecture A (Certificate Density Lower Bound)

For fixed prime q and increasing n,
$$\frac{|\{A \in GL_n(F_q) : \text{charpoly}(A) \text{ irreducible}\}|}{|GL_n(F_q)|} \geq \frac{c_q}{n}$$
for some constant c_q > 0.

**Evidence:** The prime polynomial theorem states that the fraction of monic irreducible polynomials of degree n over F_q is (1/n)(1 + O(q^{-n/2})). Our computational data shows the certificate density tracks this closely.

**Test:** Compute densities for n = 2, 3, 4, 5 and various q; verify n × density stays bounded below.

### Conjecture B (Certificate Sufficiency)

For random g, h ∈ GL_n(F_q), if g has irreducible characteristic polynomial and det(h) is a primitive element of F_q^×, then Pr[⟨g,h⟩ = GL_n(F_q)] ≥ 1 - O(q⁻¹).

**Rationale:** The irreducibility certificate on g ensures ⟨g⟩ acts irreducibly, while the primitive determinant condition on h ensures the generated subgroup surjects onto F_q^× via the determinant map.

## 7. Cross-Domain Connections

### 7.1 Finite Geometry

Theorem 3 has a direct geometric interpretation: a Singer cycle in GL_n(F_q) acts on the projective space PG(n-1, q) without fixing any proper subspace. This means the corresponding collineation group is *maximally transitive* on projective points. Computationally, we verified that the Singer cycle for GL₃(F₂) acts on the Fano plane PG(2,2) by visiting all 7 points in a single orbit.

### 7.2 Coding Theory

Theorem 2 connects to cyclic code construction. The orbit {v, Av, A²v, ...} of a nonzero vector under a Singer cycle produces a cyclic spanning family that can serve as the generator matrix of a cyclic code. The spanning property guarantees maximum rate.

### 7.3 Cryptography

Singer cycles correspond to multiplication by primitive elements of F_{q^n} when viewed through the companion matrix representation. This connects to:
- Discrete logarithm structure in finite field extensions
- Pseudorandom orbit generation for stream ciphers
- Black-box group recognition algorithms

### 7.4 LFSR Sequences

The companion matrix of an irreducible polynomial of degree n over F_q generates a linear feedback shift register of maximal period q^n - 1. Our Theorem 2 provides the formal justification: the orbit spans F_q^n, so the LFSR state sequence visits all nonzero states.

## 8. Discussion

### 8.1 Comparison with Symmetric Group Framework

The certificate framework for matrix groups mirrors the structure of the symmetric-group framework developed in the companion file `SymmGroupGen/Basic.lean`:

| Feature | Symmetric Group | Linear Group |
|---------|----------------|--------------|
| Group | S_n | GL_n(F_q) |
| Certificate | Full cycle | Irreducible charpoly |
| Obstruction | Proper subset preservation | Proper subspace preservation |
| Density | ~1/n (derangement-type) | ~1/n (prime poly theorem) |
| Cross-domain | Boolean isoperimetry | Projective geometry |

### 8.2 Limitations

1. We do not prove the full generation theorem: that a certified element paired with a generic complement generates GL_n(F_q). This would require deep results on maximal subgroups of GL_n(F_q).

2. The certificate density lower bound (Conjecture A) is stated but not proved. Proving it would require adapting the prime polynomial theorem to the specific distribution of characteristic polynomials in GL_n(F_q).

3. The computational experiments are limited to small groups. Extending to larger groups would require sampling-based approaches rather than exhaustive enumeration.

### 8.3 Formal Verification

All main theorems are verified in Lean 4 with Mathlib. The proof of Theorem 1 uses:
- Cayley-Hamilton (`LinearMap.aeval_self_charpoly`)
- Minimal polynomial theory (`minpoly.eq_of_irreducible_of_monic`, `minpoly.dvd`)
- Submodule dimension theory (`Submodule.eq_top_of_finrank_eq`)

The formalization required developing auxiliary infrastructure for transferring polynomial annihilation to restrictions (`aeval_restrict_eq_zero`) and for minimal polynomial divisibility under restriction (`minpoly_restrict_dvd`).

## 9. Future Work

1. **Prove Conjecture A** by adapting the prime polynomial theorem to GL_n(F_q).
2. **Extend to SL_n, Sp_{2n}, O_n** by defining appropriate certificates for each family.
3. **Implement certified random generation** algorithms with formal correctness guarantees.
4. **Connect to Aschbacher's theorem** on maximal subgroups to prove full generation sufficiency.
5. **Develop the coding-theoretic applications** of orbit spanning for concrete code constructions.

## References

[1] J.D. Dixon. The probability of generating the symmetric group. *Math. Z.* 110 (1969), 199–205.

[2] W.M. Kantor and A. Lubotzky. The probability of generating a finite classical group. *Geom. Dedicata* 36 (1990), 67–87.

[3] M.W. Liebeck and A. Shalev. The probability of generating a finite simple group. *Geom. Dedicata* 56 (1995), 103–113.

[4] J. Singer. A theorem in finite projective geometry and some applications to number theory. *Trans. Amer. Math. Soc.* 43 (1938), 377–385.

[5] B. Huppert. *Endliche Gruppen I*. Springer, 1967.

[6] P.M. Neumann and C.E. Praeger. A recognition algorithm for special linear groups. *Bull. Austral. Math. Soc.* 46 (1992), 445–467.
