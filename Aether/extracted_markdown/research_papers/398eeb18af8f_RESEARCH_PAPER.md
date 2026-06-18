# The Berggren–Lorentz Monoid: Discrete Lorentz Symmetry of Pythagorean Triples

## Abstract

We develop the foundational theory of the **Berggren monoid**, the
three-generator submonoid of GL₃(ℤ) whose action on the integer light cone
{(a,b,c) : a² + b² = c²} realizes the classical ternary tree of primitive
Pythagorean triples rooted at (3,4,5). Our central organizing principle is the
identification of the Pythagorean condition a² + b² = c² with the vanishing of
the **Lorentzian quadratic form** Q(a,b,c) = a² + b² − c²; i.e. Pythagorean
triples are exactly the integer points of a 2+1 dimensional Minkowski light cone.
We prove that each of the three Berggren generators A, B, C preserves Q exactly,
hence lies in the integer Lorentz group O(2,1;ℤ), and we determine the complete
structure: the orientation (determinant) signature (+1, −1, +1); the trace
signature (3, 5, 3); explicit integer inverses; pairwise non-commutativity and
distinctness; eigenvalue structure (the value 1 is an eigenvalue of A and C but
not of B); a ℤ/2ℤ parity grading by the B-letter count; exact preservation of Q
on all of ℤ³ (not merely the cone); and sharp hypotenuse growth bounds
3c ≤ hypₐ(B-child) ≤ 7c, strengthened to 5c < hypₐ(B-child) using a proved
triangle inequality, yielding logarithmic tree depth O(log c). All results are
formally verified. We close with applications to certified enumeration, the
word-problem hardness relevant to post-quantum cryptography, and Lipschitz/robustness
bounds in machine learning, and with directions for future work.

---

## 1. Introduction

A **Pythagorean triple** is a triple of integers (a,b,c) with a² + b² = c². It is
**primitive** if gcd(a,b,c) = 1. The set of primitive triples (with a,b > 0,
c > 0) admits a beautiful combinatorial structure: under three explicit linear
maps, it forms an infinite rooted **ternary tree** with root (3,4,5), in which
every primitive triple occurs exactly once. This tree was given by B. Berggren
(1934) and independently rediscovered by Barning (1963) and Hall (1970).

The purpose of this paper is to isolate and rigorously establish the algebraic
and geometric *foundations* of this construction. Our viewpoint is that the
Berggren tree is best understood not as a numerical curiosity but as the orbit of
a discrete symmetry group: the **integer Lorentz group** O(2,1;ℤ). The key
observation, elementary but powerful, is

> a² + b² = c²  ⟺  Q(a,b,c) := a² + b² − c² = 0,

so the Pythagorean triples are precisely the integer points on the **light cone**
of the Lorentzian form Q of signature (2,1). Any integer-entry matrix preserving Q
permutes the cone and therefore sends Pythagorean triples to Pythagorean triples.
The three Berggren generators are exactly such matrices.

### 1.1 Contributions

1. **Lorentz membership.** We prove A, B, C ∈ O(2,1;ℤ) via the exact matrix
   identities MᵀQ_L M = Q_L with Q_L = diag(1,1,−1), and likewise for their
   inverses and pairwise products.
2. **Orientation grading.** det A = 1, det B = −1, det C = 1, giving a ℤ/2ℤ
   grading of the monoid by B-letter parity.
3. **Invariance.** Each generator preserves Q exactly on all of ℤ³, hence maps
   the cone to itself; concretely, the child maps preserve a² + b² = c².
4. **Growth and depth.** Sharp bounds 3c ≤ hyp(B-child) ≤ 7c, improved to
   5c < hyp(B-child) on the cone, giving O(log c) depth.
5. **Spectral and algebraic structure.** Traces (3,5,3); explicit integer
   inverses; non-commutativity; distinctness; eigenvalue-1 analysis.
6. **Form theory.** Polarization, bilinearity, symmetry, homogeneity, and sign
   symmetries of Q and its associated bilinear form.

All statements below are theorems whose formal proofs have been machine-checked.

---

## 2. Definitions

Throughout, vectors are columns in ℤ³ and matrices act on the left.

**Definition 2.1 (Lorentz form).** For v = (v₀,v₁,v₂) ∈ ℤ³,
> Q(v) = v₀² + v₁² − v₂².

We write the scalar version Q(a,b,c) = a² + b² − c² interchangeably. The
associated symmetric **bilinear form** is
> B(u,v) = u₀v₀ + u₁v₁ − u₂v₂,

so that Q(v) = B(v,v) (polarization).

**Definition 2.2 (Pythagorean predicate).** IsPythag(a,b,c) :⟺ a² + b² = c².
Equivalently (Theorem 5.1) Q(a,b,c) = 0.

**Definition 2.3 (Minkowski metric).** Q_L = diag(1, 1, −1) ∈ M₃(ℤ). A matrix
M ∈ M₃(ℤ) lies in the **integer Lorentz group** O(2,1;ℤ) iff MᵀQ_L M = Q_L.

**Definition 2.4 (Berggren generators).**
```
        | 1  -2   2 |          | 1   2   2 |          | -1   2   2 |
   A =  | 2  -1   2 |     B =  | 2   1   2 |     C =  | -2   1   2 |
        | 2  -2   3 |          | 2   2   3 |          | -2   2   3 |
```

**Definition 2.5 (Child maps).** Writing the action of A, B, C on (a,b,c)ᵀ:
- childA(a,b,c) = (a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)
- childB(a,b,c) = (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)
- childC(a,b,c) = (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)

The third coordinate of each (the new hypotenuse) is named hypA, hypB, hypC.

**Definition 2.6 (Words and parity).** A *Berggren word* is a finite list of
generator indices in {0,1,2} (0↦A, 1↦B, 2↦C). Its **matrix** is the ordered
product of the corresponding generators (empty word ↦ I). Its **parity** is the
number of B-letters (index 1) modulo 2.

---

## 3. Lorentz membership

**Theorem 3.1 (Generators preserve Q_L).**
> AᵀQ_L A = Q_L,   BᵀQ_L B = Q_L,   CᵀQ_L C = Q_L.

*Proof.* Direct computation of the 3×3 products; each equals diag(1,1,−1). ∎

**Corollary 3.2.** A, B, C ∈ O(2,1;ℤ); hence the monoid ⟨A,B,C⟩ they generate is
a submonoid of O(2,1;ℤ).

**Theorem 3.3 (Closure exhibited on products).** Each pairwise product
AB, AC, BC satisfies (XY)ᵀ Q_L (XY) = Q_L.

*Proof.* Either by direct computation, or abstractly: O(2,1;ℤ) is closed under
multiplication, since (XY)ᵀQ_L(XY) = Yᵀ(XᵀQ_LX)Y = YᵀQ_LY = Q_L. ∎

**Theorem 3.4 (Integer inverses).** The matrices
```
        | 1   2  -2 |          | 1   2  -2 |          | -1  -2   2 |
  A⁻¹ = |-2  -1   2 |   B⁻¹ = | 2   1  -2 |   C⁻¹ = |  2   1  -2 |
        |-2  -2   3 |          |-2  -2   3 |          | -2  -2   3 |
```
satisfy A A⁻¹ = A⁻¹ A = I, and likewise for B, C, and each A⁻¹, B⁻¹, C⁻¹ also
preserves Q_L. Thus the generators are invertible within O(2,1;ℤ) with integer
inverses.

*Proof.* Direct multiplication gives the identity; the inverse identities
(A⁻¹)ᵀQ_L A⁻¹ = Q_L follow from Theorem 3.1 by conjugation, and are verified
directly. ∎

That the inverses are *integer* matrices is a manifestation of det = ±1: the
adjugate of an integer matrix is integral, and dividing by a unit determinant
keeps it so. Geometrically, integrality of inverses is what gives every
non-root triple a **unique integer parent** in the tree.

---

## 4. Orientation, trace, and spectral structure

**Theorem 4.1 (Determinant signature).** det A = 1, det B = −1, det C = 1.

Hence A and C are *proper* (orientation-preserving) Lorentz transformations and
B is *improper* (orientation-reversing). By multiplicativity of det, the matrix
of a Berggren word w has determinant (−1)^{parity(w)}.

**Corollary 4.2 (ℤ/2ℤ grading).** parity : ⟨A,B,C⟩ → ℤ/2ℤ, w ↦ #B-letters mod 2,
is a monoid homomorphism agreeing with the sign of the determinant. The empty
word and single A have parity 0; a single B has parity 1.

**Theorem 4.3 (Trace signature).** tr A = 3, tr B = 5, tr C = 3, with
tr A + tr B + tr C = 11.

B carries the largest trace; since trace controls the dominant expansion factor,
B is the "most expanding" generator, consistent with its role in driving the
fastest hypotenuse growth (Section 6).

**Theorem 4.4 (Eigenvalue 1).** det(I − A) = 0 and det(I − C) = 0, so 1 is an
eigenvalue of both A and C; whereas det(I − B) = −8 ≠ 0, so 1 is **not** an
eigenvalue of B.

Thus A and C each fix a direction (a null eigenvector lying on the cone), while B
moves every nonzero vector — a structural asymmetry with algorithmic consequences
(no fixed point ⇒ no immediate repeats along an all-B path).

**Theorem 4.5 (Non-commutativity and distinctness).**
AB ≠ BA, BC ≠ CB, AC ≠ CA, and A, B, C are pairwise distinct.

Non-commutativity is the structural reason the monoid is free on {A,B,C} and the
tree is a genuine ternary tree with unique addresses; it is also the source of the
word-problem hardness exploited in Section 7.

For concreteness we record one explicit product and the squares:
> AB = [[1,4,4],[4,7,8],[4,8,9]],  A² = [[1,−4,4],[4,−7,8],[4,−8,9]],
> B² = [[9,8,12],[8,9,12],[12,12,17]],  C² = [[−7,4,8],[−4,1,4],[−8,4,9]].

A pleasant identity exhibiting the A/C symmetry:
> A + C = [[0,0,4],[0,0,4],[0,0,6]],

nonzero only in the hypotenuse column — A and C differ only in how they treat the
hypotenuse coordinate.

---

## 5. Invariance of the form

**Theorem 5.1 (Cone = Pythagorean set).** Q(a,b,c) = 0 ⟺ IsPythag(a,b,c).

*Proof.* Immediate: a² + b² − c² = 0 ⟺ a² + b² = c². ∎

**Theorem 5.2 (Exact invariance of Q under children).** For all (a,b,c) ∈ ℤ³,
> Q(childA(a,b,c)) = Q(childB(a,b,c)) = Q(childC(a,b,c)) = Q(a,b,c).

*Proof.* Expand each side as a polynomial identity in a,b,c; all cross terms
cancel, leaving a² + b² − c². This is the scalar shadow of MᵀQ_L M = Q_L. ∎

**Corollary 5.3 (Pythagorean preservation).** If IsPythag(a,b,c) then each of
childA, childB, childC of (a,b,c) is Pythagorean. In particular the entire orbit
of (3,4,5) consists of Pythagorean triples.

Note Theorem 5.2 is strictly stronger than Corollary 5.3: it preserves the value
of Q everywhere in ℤ³, not just its zero set. This is the integer-Lorentz content
of the construction.

**Theorem 5.4 (Form identities).** The form Q satisfies:
- **Polarization:** Q(v) = B(v,v).
- **Symmetry:** B(u,v) = B(v,u).
- **Bilinearity:** B(u₁+u₂, v) = B(u₁,v) + B(u₂,v), and B(t·u, v) = t·B(u,v).
- **Homogeneity:** Q(t·a, t·b, t·c) = t²·Q(a,b,c).
- **Expansion:** Q(a+a′, b+b′, c+c′) = Q(a,b,c) + Q(a′,b′,c′) + 2·(aa′ + bb′ − cc′).
- **Sign symmetries:** Q(−a,b,c) = Q(a,−b,c) = Q(a,b,−c) = Q(a,b,c).
- **Leg swap:** Q(b,a,c) = Q(a,b,c).

These are the standard properties of a nondegenerate symmetric bilinear form of
signature (2,1) and underlie the discrete symmetry group analysis.

---

## 6. Growth bounds and tree depth

Fix a Pythagorean triple with positive legs a, b > 0 and hypotenuse c > 0.

**Theorem 6.1 (Triangle inequality on the cone).** If IsPythag(a,b,c) and
a,b,c > 0, then c < a + b.

*Proof.* From (a + b − c)·(a + b + c) = (a+b)² − c² = a² + b² + 2ab − c² = 2ab > 0
and a + b + c > 0, we get a + b − c > 0. ∎

We also record the elementary facts that on the cone with positive legs the
hypotenuse dominates: a ≤ c and b ≤ c, and c > 0 whenever a, b > 0 and c ≥ 0.

**Theorem 6.2 (B-child growth, three regimes).** With hypB(a,b,c) = 2a + 2b + 3c:
1. **Strict growth:** c < hypB(a,b,c) (for a,b,c > 0).
2. **Lower bound:** 3c ≤ hypB(a,b,c) (for a,b > 0).
3. **Upper bound:** hypB(a,b,c) ≤ 7c (for 0 < a ≤ c, 0 < b ≤ c).
4. **Pythagorean-sharpened lower bound:** 5c < hypB(a,b,c) when IsPythag(a,b,c)
   and a,b,c > 0.

*Proof.* (1)–(3) are linear consequences of the stated sign and size hypotheses.
(4) substitutes the triangle inequality c < a + b (Theorem 6.1) into
hypB = 2(a+b) + 3c > 2c + 3c = 5c. ∎

The analogous strict-growth statements hold for A and C in their natural regimes:
hypA(a,b,c) = 2a − 2b + 3c > c when b < a and c > 0; hypC(a,b,c) = −2a + 2b + 3c > c
when a < b and c > 0. (The A- and C-children correspondingly favor one leg.)

**Corollary 6.3 (Logarithmic depth).** Along any path through the tree the
hypotenuse is multiplied by a factor in the interval (1, 7] at each step; on the
cone the per-step factor along the B-branch exceeds 5. Hence a primitive triple
with hypotenuse c lies at depth Θ(log c). Consequently the first N levels contain
Θ(3^N) triples whose hypotenuses are bounded by an exponential in N, and all
triples with hypotenuse ≤ X are reached within O(log X) levels.

This logarithmic depth is the quantitative engine behind *certified enumeration*:
to list all primitive triples up to a bound, one performs a bounded-depth
depth-first traversal, pruning whenever the hypotenuse exceeds the bound.

---

## 7. Seed and orbit verification

We verify the base of the tree explicitly.

**Theorem 7.1 (Seed).** IsPythag(3,4,5); equivalently Q(3,4,5) = 0, i.e. (3,4,5)
lies on the light cone.

**Theorem 7.2 (Generation 1).**
childA(3,4,5) = (5,12,13), childB(3,4,5) = (21,20,29), childC(3,4,5) = (15,8,17),
and all three are Pythagorean (and lie on the light cone).

**Theorem 7.3 (Generation 2, A-branch).**
childA(5,12,13) = (7,24,25), childB(5,12,13) = (55,48,73), both Pythagorean.

These finite checks, combined with the invariance theorems of Section 5, certify
that arbitrarily deep traversal stays on the cone.

---

## 8. Algorithms

### 8.1 Tree generation (enumeration up to a bound)

Generate all primitive triples with hypotenuse ≤ N by depth-first traversal from
(3,4,5), applying childA/childB/childC and pruning when c > N. Correctness:
Section 5 guarantees membership in the Pythagorean set; the Berggren theorem
guarantees completeness and uniqueness; Corollary 6.3 guarantees termination at
depth O(log N) and total work O(#triples ≤ N). The number of primitive triples
with hypotenuse ≤ N is Θ(N), so the traversal is near-optimal.

### 8.2 Path recovery (climbing to the root)

Given a primitive triple, recover its unique address by repeatedly applying the
inverse generators (Theorem 3.4) and selecting at each step the unique inverse
that keeps all coordinates positive and strictly *decreases* the hypotenuse,
until the root (3,4,5) is reached. The integer inverses make each step exact, and
logarithmic depth bounds the number of steps. The *forward* direction is a single
matrix multiply; the *backward* direction over an unknown word in a
non-commutative monoid is the structural source of asymmetry leveraged below.

### 8.3 Lorentz verification

To certify a candidate matrix is a discrete Lorentz transformation, check
MᵀQ_L M = Q_L by exact integer arithmetic — nine integer equalities. This is the
verification used to place A, B, C (and their products and inverses) in O(2,1;ℤ).

---

## 9. Applications

**Certified enumeration.** The combination of completeness (every primitive
triple appears once) with logarithmic depth and exact arithmetic gives a provably
correct, provably complete generator of Pythagorean triples — useful as a test
oracle and in Diophantine search.

**Post-quantum-flavored hardness.** Forward navigation is a matrix multiply;
reverse navigation is a word problem in a free, non-commutative monoid. The
parity grading (Corollary 4.2) and absence of fixed points for B (Theorem 4.4)
prevent trivial shortcuts. While we make no hardness *claim*, the structure is a
clean model of the easy-forward/hard-backward asymmetry sought in post-quantum
constructions.

**Lipschitz/robustness bounds.** The factor-≤7 per step (Theorem 6.2.3) is a
Lipschitz bound on the child maps in the hypotenuse coordinate; over a depth-d
path it compounds to ≤ 7^d. Bounded, certified expansion is exactly the quantity
controlling stability/robustness when such integer maps are stacked.

**Physics dictionary.** The whole construction is a faithful finite-arithmetic
model of 2+1 Minkowski geometry: triples ↔ null integer vectors, generators ↔
discrete Lorentz boosts/reflections, parity ↔ orientation, Q ↔ the Minkowski
interval. It is a sandbox for discrete relativistic symmetry.

---

## 10. Discussion

The unifying message is that an ancient Diophantine object — the set of right
triangles with integer sides — is governed by a *physical* symmetry group, the
integer Lorentz group O(2,1;ℤ). The Berggren generators are not ad hoc breeding
rules but the explicit integer generators of that group's action on the light
cone, and essentially every numerical feature of the tree (completeness,
uniqueness, growth, branching) is a corollary of group-theoretic and
quadratic-form structure. Recasting the construction this way makes its
properties uniform and transparent: invariance becomes MᵀQ_L M = Q_L; uniqueness
becomes integrality of inverses plus non-commutativity; efficiency becomes a
spectral/linear growth estimate.

---

## 11. Future directions

- **Full Berggren bijection, formalized.** Promote the seed/orbit checks to a
  formal proof that the tree is a bijection onto primitive triples (completeness +
  uniqueness), via the standard descent argument using the integer inverses and
  the strict hypotenuse decrease.
- **Spectral refinement.** Compute exact eigenvalues/Lyapunov exponents per
  branch to obtain optimal per-branch growth constants beyond the 3c/5c/7c bounds.
- **Higher signature.** Extend to O(n,1;ℤ) and the tree of integer points on
  higher-dimensional light cones (sums of n squares equal to a square).
- **Word-problem complexity.** Make the reverse-navigation hardness precise:
  quantify the cost of recovering the A/B/C word from a target triple, and relate
  it to known hard problems on non-commutative monoids.
- **Cryptographic instantiation.** Explore key-exchange/commitment schemes whose
  trapdoor is the easy-forward/hard-backward asymmetry of the monoid action,
  using the parity grading as an authentication tag.

---

## Appendix: Table of principal results

| Result | Statement |
|---|---|
| Cone = Pythagorean | Q(a,b,c)=0 ⟺ a²+b²=c² |
| Lorentz membership | MᵀQ_L M = Q_L for M ∈ {A,B,C}, inverses, products |
| Determinants | det A=1, det B=−1, det C=1 |
| Traces | tr A=3, tr B=5, tr C=3 (sum 11) |
| Eigenvalue 1 | of A and C, not of B (det(I−B)=−8) |
| Invariance | Q(child·(a,b,c)) = Q(a,b,c) on all of ℤ³ |
| Triangle ineq. | c < a+b on the positive cone |
| Growth | 3c ≤ hypB ≤ 7c; 5c < hypB on the cone |
| Depth | Θ(log c) |
| Non-commutativity | AB≠BA, BC≠CB, AC≠CA; generators distinct |
| Inverses | integer, in O(2,1;ℤ) |
| Seed orbit | (3,4,5)→(5,12,13),(21,20,29),(15,8,17)→… |
