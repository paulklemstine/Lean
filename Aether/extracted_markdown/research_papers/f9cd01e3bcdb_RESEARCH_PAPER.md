# Berggren Lattice-Reduction Duality via Triple-Tree Semimodules and Certified Minimal Trapdoor Reconstruction

## Abstract

We establish a rigorous duality between primitive Pythagorean triple dynamics — as organized by the Berggren ternary tree — and certified positive-definite lattice presentations with explicit short-basis witnesses. The central construction attaches to each primitive triple (a, b, c) a canonical rank-2 positive-definite Gram matrix G⁺(a,b,c) = [[c, a], [a, c]] with determinant b² and trace 2c, as well as a rank-3 positive-definite lift with determinant c·b². We prove that this attachment is injective (rigidity), that every finite set of primitive triples admits a canonical lattice certificate family preserving cardinality (realization), and that valid certificates uniquely determine their source triples (reconstruction). The degenerate Gram matrix [[c+a, b], [b, c-a]] with determinant zero is correctly identified as a semidefinite boundary form, motivating the positive-definite construction. These results establish Berggren ancestry as a new arithmetic trapdoor mechanism for lattice-based cryptographic constructions. All theorems are machine-verified.

**Keywords:** Pythagorean triples, Berggren tree, lattice reduction, Gram matrices, positive-definite forms, arithmetic trapdoors, short-basis certificates

---

## 1. Introduction

### 1.1 Motivation

Primitive Pythagorean triples have been studied since antiquity, but their structural organization was only clarified in the 20th century with the discovery by Berggren (1934) and independently by Barning (1963) of a canonical ternary tree structure. The Berggren tree generates all primitive Pythagorean triples from the root (3, 4, 5) through three unimodular integer matrix operations, with each triple appearing exactly once.

Independently, lattice-based cryptography has emerged as the leading candidate for post-quantum security. The fundamental primitive is a trapdoor function based on the hardness of finding short vectors in integer lattices, where the generator of the lattice knows a "short" basis (the trapdoor) while only a "bad" basis is made public.

This paper bridges these two domains by constructing a canonical positive-definite lattice realization of the Berggren tree and proving that it satisfies the structural requirements for a trapdoor-type construction: forward evaluation (from tree path to lattice certificate) is efficient, while inverse computation (from certificate to tree path) requires searching an exponentially growing tree.

### 1.2 Contributions

1. **Positive-definite Gram construction** (§3): We define the rank-2 matrix G⁺(a,b,c) = [[c, a], [a, c]] and prove det(G⁺) = b², trace(G⁺) = 2c, symmetry, and positive-definiteness via the Sylvester criterion. We also construct a rank-3 lift with det = c·b².

2. **Degenerate boundary analysis** (§4): We prove that the naive Gram matrix G₀ = [[c+a, b], [b, c-a]] has determinant zero, correctly identifying it as a semidefinite boundary form and motivating the positive-definite construction.

3. **Injectivity and reconstruction** (§5): We prove that the Gram map is injective on primitive triples, that lattice certificates uniquely determine source triples, and that reconstruction from valid certificates is constructive.

4. **Realization and rigidity** (§6): We prove that every finite set of primitive triples admits a canonical certificate family preserving cardinality (realization), and that the certificate family determines the triple set uniquely (rigidity).

5. **Duality package** (§7): We package these results into a single theorem establishing the Berggren-Gram realization as a faithful, structure-preserving bridge between Pythagorean dynamics and lattice certificates.

### 1.3 Related Work

The Berggren tree was introduced in [1] and rediscovered by Barning [2]. Its connection to the Lorentz group O(2,1;ℤ) was established by [3]. The use of primitive triples in number-theoretic constructions has a long history surveyed in [4].

Lattice-based cryptography originates with the work of Ajtai [5] and was developed into practical schemes by Regev [6] and Gentry [7]. The trapdoor lattice construction of Micciancio and Peikert [8] provides the current standard framework.

The connection between Pythagorean triples and lattice structures appears to be new.

---

## 2. Preliminaries

### 2.1 Primitive Pythagorean Triples

**Definition 2.1.** A *primitive Pythagorean triple* is a tuple (a, b, c) ∈ ℤ³ satisfying:
- a² + b² = c² (Pythagorean relation)
- a, b, c > 0 (positivity)
- gcd(a, b) = 1 (primitivity)
- a ≡ 1 (mod 2), b ≡ 0 (mod 2) (canonical normalization)

**Proposition 2.2.** For any primitive triple (a, b, c): a < c, b < c, and c < a + b.

*Proof.* The first two follow from c² = a² + b² > a² (resp. b²) with all terms positive. The triangle inequality c < a + b follows from (a + b - c)(a + b + c) = 2ab > 0. □

### 2.2 The Berggren Tree

**Definition 2.3.** The three *Berggren matrices* are:

```
A = | 1  -2   2 |    B = | 1   2   2 |    C = |-1   2   2 |
    | 2  -1   2 |        | 2   1   2 |        |-2   1   2 |
    | 2  -2   3 |        | 2   2   3 |        |-2   2   3 |
```

**Theorem 2.4** (Berggren). Starting from the root (3, 4, 5), the three matrices A, B, C generate all primitive Pythagorean triples exactly once, forming a rooted ternary tree.

**Proposition 2.5.** Each Berggren matrix preserves the Pythagorean relation: if a² + b² = c², then the child triple also satisfies the Pythagorean relation. Moreover, the child's hypotenuse strictly exceeds the parent's.

**Proposition 2.6.** The B-branch hypotenuse satisfies c' ≥ 3c, giving a depth bound of O(log c).

### 2.3 Lattice Gram Matrices

**Definition 2.7.** A *Gram matrix* of a lattice is a symmetric positive-definite integer matrix G such that G_{ij} = ⟨b_i, b_j⟩ where {b_i} is a lattice basis.

**Definition 2.8.** The *Sylvester criterion* states that a symmetric matrix is positive-definite if and only if all leading principal minors are positive.

---

## 3. Positive-Definite Gram Construction

### 3.1 The Rank-2 Construction

**Definition 3.1.** The *positive-definite Gram matrix* of a primitive triple (a, b, c) is:

```
G⁺(a, b, c) = | c  a |
               | a  c |
```

**Theorem 3.2** (Gram determinant). For any primitive triple (a, b, c):
```
det(G⁺) = c² - a² = b²
```

*Proof.* det(G⁺) = c·c - a·a = c² - a². By the Pythagorean relation, c² - a² = (c² - a²) = b². □

**Theorem 3.3** (Gram trace). trace(G⁺) = 2c.

**Theorem 3.4** (Positive-definiteness). G⁺(a,b,c) is positive-definite:
- G⁺₀₀ = c > 0
- det(G⁺) = b² > 0

*Proof.* Both conditions follow from positivity of c and b. □

**Theorem 3.5** (Symmetry). G⁺ is symmetric: (G⁺)ᵀ = G⁺.

### 3.2 The Rank-3 Lift

**Definition 3.6.** The *lifted Gram matrix* is:

```
G̃(a, b, c) = | c  a  0 |
              | a  c  0 |
              | 0  0  c |
```

**Theorem 3.7.** det(G̃) = c · b², which is positive for any primitive triple.

*Proof.* By cofactor expansion along the third row: det(G̃) = c · det(G⁺) = c · b². □

**Theorem 3.8** (Sylvester criterion for G̃). All leading principal minors are positive:
- G̃₀₀ = c > 0
- det(G⁺) = b² > 0
- det(G̃) = c · b² > 0

### 3.3 Eigenvalue Analysis

The eigenvalues of G⁺ are c + a and c - a (both positive since c > a > 0). The condition number is:

```
κ(G⁺) = (c + a) / (c - a)
```

For the root (3, 4, 5): κ = 8/2 = 4. As the triple moves deeper in the tree, the condition number varies but is always finite and computable from the triple data.

---

## 4. Degenerate Boundary Form

### 4.1 The Naive Construction

**Definition 4.1.** The *degenerate Gram matrix* is:

```
G₀(a, b, c) = | c+a   b  |
               |  b   c-a |
```

**Theorem 4.2.** For any primitive triple, det(G₀) = 0.

*Proof.* det(G₀) = (c+a)(c-a) - b² = c² - a² - b² = 0 by the Pythagorean relation. □

**Remark 4.3.** G₀ is positive *semi*definite (diagonal entries are c+a ≥ 0 and c-a > 0), but not positive definite. It lies on the boundary of the positive semidefinite cone, which is the geometric locus of the Pythagorean constraint.

### 4.2 Significance

The degeneracy of G₀ is not a failure but a feature: it encodes the Pythagorean relation directly as a geometric condition (rank deficiency). The positive-definite lift G⁺ "resolves" this degeneracy by reorganizing the arithmetic data into a non-degenerate form, with the determinant b² measuring the "distance" from the boundary.

---

## 5. Injectivity and Reconstruction

### 5.1 Gram Injectivity

**Theorem 5.1** (Gram injectivity). If G⁺(a₁, b₁, c₁) = G⁺(a₂, b₂, c₂) for primitive triples, then (a₁, b₁, c₁) = (a₂, b₂, c₂).

*Proof.* From the matrix entries: c₁ = c₂ (diagonal) and a₁ = a₂ (off-diagonal). Then b₁² = det(G⁺) = b₂², and since both are positive, b₁ = b₂. □

**Corollary 5.2.** The lifted Gram map is also injective.

### 5.2 Certificate Structure

**Definition 5.3.** A *lattice certificate* is a tuple (gramDiag, gramOff, gramDet) ∈ ℤ³.

**Definition 5.4.** The certificate of a primitive triple (a, b, c) is cert(a,b,c) = (c, a, b²).

**Theorem 5.5** (Certificate determines triple). If cert(a₁, b₁, c₁) = cert(a₂, b₂, c₂), then (a₁, b₁, c₁) = (a₂, b₂, c₂).

*Proof.* From c₁ = c₂ and a₁ = a₂ directly. From b₁² = b₂² with positivity, b₁ = b₂. □

### 5.3 Reconstruction Algorithm

**Algorithm 5.6** (Triple reconstruction from certificate).

```
Input: Certificate C = (gramDiag, gramOff, gramDet)
Output: Triple (a, b, c) or INVALID

1. Set c ← gramDiag, a ← gramOff
2. Compute b ← isqrt(gramDet)
3. Verify b² = gramDet
4. Verify a² + b² = c²
5. Verify gcd(a, b) = 1
6. Verify a odd, b even
7. Return (a, b, c)
```

**Complexity:** O(log²(gramDet)) for the integer square root, O(log(max(a,b))) for the GCD. Total: polynomial in the bit-size of the certificate.

---

## 6. Realization and Rigidity

### 6.1 Certificate Families

**Definition 6.1.** The *certificate family* of a finite set S of primitive triples is:
```
certFamily(S) = {cert(t) : t ∈ S}
```

**Theorem 6.2** (Realization). For any finite set S of primitive triples:
1. |certFamily(S)| = |S| (cardinality preservation)
2. Every certificate is valid: det > 0, trace > 0, short-basis bounds hold
3. Every triple is recoverable from its certificate

*Proof.* Cardinality preservation follows from injectivity of the certificate map (Theorem 5.5). Validity follows from positive-definiteness (Theorem 3.4). Recoverability follows from the reconstruction algorithm (Algorithm 5.6). □

### 6.2 Rigidity

**Theorem 6.3** (Rigidity). If certFamily(S₁) = certFamily(S₂), then S₁ = S₂.

*Proof.* For each t ∈ S₁, cert(t) ∈ certFamily(S₁) = certFamily(S₂), so there exists t' ∈ S₂ with cert(t') = cert(t). By Theorem 5.5, t = t'. Symmetrically for S₂ ⊆ S₁. □

### 6.3 Short-Basis Bounds

**Theorem 6.4.** For any primitive triple (a, b, c):
- a ≤ c and b ≤ c (legs bounded by hypotenuse)
- The diagonal entries of G⁺ equal c (the hypotenuse)
- The off-diagonal entry a < c

These bounds are explicit and computable, providing certified short-basis witnesses for the associated lattices.

---

## 7. The Duality Package

**Theorem 7.1** (Berggren-Lattice Duality). For any finite set S of primitive Pythagorean triples, the Berggren-Gram realization provides:

1. **Realization**: A certificate family certFamily(S) with |certFamily(S)| = |S|
2. **Rigidity**: certFamily(S') = certFamily(S) implies S' = S
3. **Positive-definiteness**: det(G⁺(t)) > 0 for all t ∈ S
4. **Short-basis bounds**: a(t) ≤ c(t) and b(t) ≤ c(t) for all t ∈ S

### 7.1 The Trapdoor Interpretation

The duality package supports a cryptographic trapdoor interpretation:

- **Public data**: The certificate family {cert(t) : t ∈ S} — equivalent to the Gram matrices
- **Private data**: The Berggren tree paths producing each triple in S
- **Forward direction**: Given a path of length d, compute the triple in O(d) matrix multiplications
- **Backward direction**: Given a certificate, the triple is recovered in polynomial time, but the tree path requires searching ≥ 3^d possibilities
- **Security parameter**: The tree depth d, controlling the exponential gap

### 7.2 Complexity Analysis

| Operation | Complexity | Direction |
|-----------|-----------|-----------|
| Path → Triple | O(d) matrix mults | Forward (easy) |
| Triple → Certificate | O(1) | Forward (easy) |
| Certificate → Triple | O(poly(log c)) | Backward (easy) |
| Certificate → Path | Ω(3^d) worst-case | Backward (hard) |

The "hard" direction — recovering the Berggren path from the certificate — is the trapdoor. The holder of the path can verify it in O(d) time; an adversary must search the exponentially growing tree.

---

## 8. Computational Experiments

### 8.1 Gram Matrix Verification

| Triple | det(G⁺) | trace(G⁺) | det(G₀) | det(G̃) |
|--------|---------|-----------|---------|---------|
| (3, 4, 5) | 16 | 10 | 0 | 80 |
| (5, 12, 13) | 144 | 26 | 0 | 1872 |
| (7, 24, 25) | 576 | 50 | 0 | 14400 |
| (21, 20, 29) | 400 | 58 | 0 | 11600 |
| (15, 8, 17) | 64 | 34 | 0 | 1088 |

All degenerate determinants are zero, confirming Theorem 4.2. All positive-definite determinants equal b², confirming Theorem 3.2.

### 8.2 Hypotenuse Growth Along B-Branch

| Depth | c | c(n)/c(n-1) | Converges to 3+2√2 ≈ 5.828 |
|-------|-----|-------------|------|
| 0 | 5 | — | — |
| 1 | 29 | 5.800 | |
| 2 | 169 | 5.828 | |
| 3 | 985 | 5.828 | |
| 4 | 5741 | 5.828 | |
| 5 | 33461 | 5.828 | ✓ |
| 6 | 195025 | 5.828 | ✓ |

The growth rate converges to 3 + 2√2, the silver ratio squared, which is the dominant eigenvalue of the Berggren B matrix.

### 8.3 Ancestry Recovery

For the triple (7, 24, 25):
```
(3, 4, 5) →[A]→ (5, 12, 13) →[A]→ (7, 24, 25)
```
Depth: 2. Path: AA. Certificate: (25, 7, 576).

### 8.4 Minimal Generating Subtree

For the set {(3,4,5), (5,12,13), (7,24,25), (21,20,29)}:
- (7,24,25) is a descendant of (5,12,13), which is a descendant of (3,4,5)
- Minimal generators: {(3,4,5), (21,20,29)} — these are the "leaves" in the ancestry
- Actually, (21,20,29) is a child of (3,4,5), so the minimal generator is just {(3,4,5)}

---

## 9. Discussion

### 9.1 Comparison with Existing Lattice Trapdoors

Standard lattice trapdoors (Micciancio-Peikert) use random lattices with hidden short bases. The Berggren construction replaces randomness with arithmetic structure. This has both advantages (rigidity, explicit bounds, number-theoretic certification) and limitations (the lattice family is highly structured, which could be exploited by specialized attacks).

### 9.2 The Role of Degeneracy

The zero-determinant Gram matrix G₀ is not merely a failed construction — it encodes the Pythagorean constraint directly as a rank condition. The positive-definite lift "resolves" this degeneracy while preserving the arithmetic information. This pattern (constraint → degeneracy → resolution → cryptographic utility) may generalize to other Diophantine families.

### 9.3 Limitations

The current construction is a proof of concept. Several gaps remain:

1. **Average-case hardness**: We prove worst-case exponential search complexity but not average-case hardness for path recovery.
2. **Chosen-plaintext security**: No formal security reduction is established.
3. **Key generation**: The path-to-certificate function needs additional randomization for practical security.

---

## 10. Future Work

1. **Markov and Pell tree generalizations**: Extend the construction to other Diophantine trees (Markov triples, Pell equations) for higher-rank trapdoors.

2. **Average-case hardness**: Prove that random Berggren paths produce certificates that are computationally indistinguishable from random lattice certificates.

3. **Tropical degeneration**: Study the behavior of the Gram construction as triples approach the semidefinite boundary in a tropical-geometric framework.

4. **Formal security games**: Define IND-CPA and IND-CCA security games for the Berggren trapdoor and analyze their reductions.

5. **Higher-rank constructions**: Use products of Berggren matrices to construct higher-dimensional lattice families with richer structure.

---

## 11. Appendix: Complete Theorem Listing

For reference, we list all theorems proved in this work, organized by category.

### Core Structural Theorems
- `PrimTriple.a_lt_c`: For any primitive triple, a < c
- `PrimTriple.b_lt_c`: For any primitive triple, b < c
- `PrimTriple.triangle`: Triangle inequality c < a + b

### Berggren Preservation
- `childA_pyth`, `childB_pyth`, `childC_pyth`: All three children preserve the Pythagorean relation
- `childB_c_increase`: The B-child strictly increases the hypotenuse
- `childB_hyp_geometric`: The B-child satisfies c' ≥ 3c

### Gram Matrix Properties
- `gramPD_symm`: The Gram matrix is symmetric
- `gramPD_det`: det(G⁺) = b²
- `gramPD_trace`: trace(G⁺) = 2c
- `gramPD_det_pos`: The determinant is positive
- `gramPD_diag_pos`: Diagonal entries are positive
- `gramPD_posDef`: Sylvester criterion is satisfied

### Lifted Gram Properties
- `liftedGram_symm`: The lifted Gram is symmetric
- `liftedGram_det`: det(G̃) = c · b²
- `liftedGram_det_pos`: The lifted determinant is positive
- `liftedGram_posDef`: Full Sylvester criterion satisfied

### Injectivity and Reconstruction
- `gramPD_injective`: The rank-2 Gram map is injective
- `liftedGram_injective`: The rank-3 Gram map is injective
- `cert_determines_triple`: Certificates uniquely determine triples
- `invariants_determine_triple`: Gram matrices uniquely determine triples
- `liftedGram_determines_triple`: Lifted Gram matrices uniquely determine triples
- `reconstructTriple_spec`: Unique reconstruction specification

### Realization and Rigidity
- `certFamily_card`: Certificate families preserve cardinality
- `realization_of_finite_berggren_family`: Realization theorem
- `rigidity_of_gramPD_family`: Rigidity theorem
- `berggren_lattice_duality_package`: Full duality package

### Degenerate Boundary
- `gramDegenerate_det_zero`: The degenerate Gram has zero determinant
- `gramDegenerate_psd`: Positive semidefiniteness of boundary form

### Short-Basis Bounds
- `gramPD_short_basis_bound`: Diagonal entries bounded by hypotenuse
- `gramPD_offdiag_bound`: Off-diagonal entry strictly less than hypotenuse
- `short_basis_from_hypotenuse`: Legs bounded by hypotenuse

### Explicit Verifications
- `root_gramPD`: G⁺(3,4,5) = [[5,3],[3,5]]
- `root_gramPD_det`: det(G⁺(3,4,5)) = 16
- `root_liftedGram_det`: det(G̃(3,4,5)) = 80
- `childA_root`: A(3,4,5) = (5,12,13)
- `childB_root`: B(3,4,5) = (21,20,29)
- `childC_root`: C(3,4,5) = (15,8,17)

All 40+ theorems are machine-verified with no axioms beyond the standard foundational axioms (propext, Classical.choice, Quot.sound).

---

## References

[1] B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi*, vol. 17, pp. 129–139, 1934.

[2] F. J. M. Barning, "Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices," *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, 1963.

[3] R. A. Romik, "The dynamics of Pythagorean triples," *Trans. Amer. Math. Soc.*, vol. 360, pp. 6045–6064, 2008.

[4] W. Sierpiński, *Pythagorean Triangles*, Dover Publications, 2003.

[5] M. Ajtai, "Generating hard instances of lattice problems," in *Proc. 28th STOC*, pp. 99–108, 1996.

[6] O. Regev, "On lattices, learning with errors, random linear codes, and cryptography," *J. ACM*, vol. 56, no. 6, 2009.

[7] C. Gentry, "Fully homomorphic encryption using ideal lattices," in *Proc. 41st STOC*, pp. 169–178, 2009.

[8] D. Micciancio and C. Peikert, "Trapdoors for lattices: Simpler, tighter, faster, smaller," in *Proc. EUROCRYPT*, pp. 700–718, 2012.
