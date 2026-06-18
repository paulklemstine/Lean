# The Berggren Tree of Primitive Pythagorean Triples: Verified Invariant Preservation and Hypotenuse Monotonicity

## Abstract

We present a complete, machine-verified proof that the three Berggren matrix operations on primitive Pythagorean triples preserve all defining invariants—the Pythagorean equation, positivity, coprimality, and parity orientation—and that each operation strictly increases the hypotenuse. These results collectively certify that the Berggren ternary tree is well-defined as a total function on the type of primitive triples, and that it is acyclic by virtue of a strictly increasing natural-valued height function. The proofs combine nonlinear integer arithmetic, modular reasoning, and divisibility descent arguments. We discuss the correspondence between the Berggren tree and rank-2 integer lattice geometry, with implications for cryptographic trapdoor constructions.

## 1. Introduction

### 1.1 Pythagorean Triples and the Berggren Tree

A *primitive Pythagorean triple* is a triple (a, b, c) of positive integers satisfying:

- a² + b² = c² (the Pythagorean equation),
- gcd(a, b) = 1 (coprimality),
- a is odd (orientation convention, which forces b even and c odd).

B. Berggren (1934) discovered that every primitive Pythagorean triple can be generated from the root triple (3, 4, 5) by iterated application of three 3×3 integer matrices:

$$
L = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad
M = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad
R = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}.
$$

The resulting structure is a ternary tree rooted at (3, 4, 5) in which every node has exactly three children, every primitive triple appears exactly once, and no triple is repeated. This tree was independently rediscovered by Hall (1970) and Barning (1963), and is sometimes called the Berggren–Barning–Hall tree.

### 1.2 Contributions

This work provides a complete formal verification of the Berggren tree's fundamental properties. The key verified results are:

1. **Quadratic form preservation** (`berggren_preserves_sq_sum`): Each matrix preserves a² + b² = c².
2. **Positivity preservation** (`berggren_left_pos`, `berggren_mid_pos`, `berggren_right_pos`): Each matrix maps positive triples to positive triples.
3. **Parity preservation** (`berggren_left_odd`, `berggren_mid_odd`, `berggren_right_odd`): Each matrix preserves the oddness of the first coordinate.
4. **Coprimality preservation** (`berggren_left_coprime`, `berggren_mid_coprime`, `berggren_right_coprime`): Each matrix preserves gcd(a, b) = 1.
5. **Hypotenuse monotonicity** (`berggren_c_strict_increase`): Every step strictly increases c.

Together, these enable the construction of a total function `berggrenStepApply : BerggrenStep → PrimitiveTriple → PrimitiveTriple` and an evaluation function `berggrenWordEval : BerggrenWord → PrimitiveTriple → PrimitiveTriple` that traverses arbitrary paths in the tree. See @Catalog/Bridges/BerggrenLatticeReduction/Core.lean.

### 1.3 Related Work

The Berggren tree has been studied extensively in the number theory literature. Price (2008) gave a modern treatment connecting the tree to continued fractions. Romik (2008) established dynamical properties of the tree. The present work appears to be the first complete formal verification of the tree's invariant preservation properties.

## 2. Definitions

### 2.1 Primitive Pythagorean Triples

**Definition 2.1** (PrimitiveTriple). A *primitive Pythagorean triple* is a record `(a, b, c) ∈ ℤ³` equipped with proofs of:

| Field | Type | Description |
|-------|------|-------------|
| `sq_sum` | a² + b² = c² | Pythagorean equation |
| `pos_a`, `pos_b`, `pos_c` | 0 < a, 0 < b, 0 < c | Positivity |
| `coprime_ab` | gcd(a, b) = 1 | Coprimality |
| `odd_oriented` | a ≡ 1 (mod 2) | Orientation |

This is formalized as the structure `PrimitiveTriple` in @Catalog/Bridges/BerggrenLatticeReduction/Core.lean.

### 2.2 Berggren Steps and Words

**Definition 2.2** (BerggrenStep). The type `BerggrenStep` is an inductive type with three constructors: `left`, `mid`, `right`.

**Definition 2.3** (BerggrenWord). A `BerggrenWord` is a `List BerggrenStep`, representing a path from the root of the Berggren tree.

**Definition 2.4** (BerggrenMatrix). The function `BerggrenMatrix : BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ` assigns to each step its 3×3 generating matrix.

**Definition 2.5** (berggrenActVec). The function `berggrenActVec : BerggrenStep → (Fin 3 → ℤ) → (Fin 3 → ℤ)` implements the matrix-vector multiplication by explicit coordinate formulas, matching the action of `BerggrenMatrix`.

## 3. Main Results

### 3.1 Preservation of the Pythagorean Equation

**Theorem 3.1** (`berggren_preserves_sq_sum`). *For any step s ∈ {left, mid, right} and any integers a, b, c with a² + b² = c², the transformed vector w = berggrenActVec(s, [a, b, c]) satisfies w₀² + w₁² = w₂².*

*Proof sketch.* By case analysis on s, expand the coordinate formulas and verify the algebraic identity. For example, for the left step:

(a − 2b + 2c)² + (2a − b + 2c)² = (2a − 2b + 3c)²

reduces, after expansion, to 5(a² + b²) = 5c², which follows from the hypothesis. The middle and right cases are analogous. ∎

### 3.2 Positivity Preservation

**Theorem 3.2** (`berggren_left_pos`, `berggren_mid_pos`, `berggren_right_pos`). *For any primitive triple t, all three coordinates of berggrenActVec(s, tripleVec(t)) are strictly positive.*

*Proof sketch.* The middle step is immediate since all matrix entries are positive except for none (all coefficients have the same sign as the inputs). For the left step, the key observation is that a − 2b + 2c > 0 follows from c > b (Theorem 3.5 below) and c > a, giving 2c > a + b hence a − 2b + 2c = a + 2(c − b) > 0. The right step requires −a + 2b + 2c > 0, which follows from 2c > 2a > a (since c > a). ∎

### 3.3 Parity Preservation

**Theorem 3.3** (`berggren_left_odd`, `berggren_mid_odd`, `berggren_right_odd`). *For any primitive triple t, the first coordinate of the transformed vector is odd.*

*Proof sketch.* Working modulo 2: since a is odd (a ≡ 1 mod 2), the terms 2b and 2c vanish mod 2, so:
- Left: a − 2b + 2c ≡ a ≡ 1 (mod 2).
- Middle: a + 2b + 2c ≡ a ≡ 1 (mod 2).
- Right: −a + 2b + 2c ≡ −a ≡ a ≡ 1 (mod 2) (since −1 ≡ 1 mod 2). ∎

### 3.4 Coprimality Preservation

**Theorem 3.4** (`berggren_left_coprime`, `berggren_mid_coprime`, `berggren_right_coprime`). *For any primitive triple t, the transformed coordinates satisfy gcd(a', b') = 1.*

*Proof sketch.* Let d = gcd(a', b'). Then d divides both a' and b', hence d² divides a'² + b'² = c'², so d divides c'. Now, expressing the original coordinates as integer linear combinations of (a', b', c') (using the inverse of the Berggren matrix, which has integer entries since each matrix has determinant ±1), we find d divides both a and b. Since gcd(a, b) = 1, we conclude d = 1. ∎

This is the most intricate of the preservation results. The formal proof in @Catalog/Bridges/BerggrenLatticeReduction/Core.lean carefully tracks the divisibility chain through the inverse matrix computation.

### 3.5 Auxiliary Inequalities

**Theorem 3.5** (`primitiveTriple_c_gt_a`, `primitiveTriple_c_gt_b`). *For any primitive triple (a, b, c), we have a < c and b < c.*

*Proof sketch.* From a² + b² = c² with b > 0, we get c² = a² + b² > a², hence c > a (both positive). Similarly for b. ∎

**Theorem 3.6** (`primitiveTriple_b_even`, `primitiveTriple_c_odd`). *In a primitive triple with a odd, b is even and c is odd.*

*Proof sketch.* If both a, b were odd, then a² + b² ≡ 2 (mod 4), but c² ≡ 0 or 1 (mod 4), contradiction. Since gcd(a, b) = 1, they cannot both be even. Thus b is even. Then c² = a² + b² ≡ 1 + 0 ≡ 1 (mod 2), so c is odd. ∎

### 3.6 Hypotenuse Monotonicity

**Theorem 3.7** (`berggren_c_strict_increase`). *For any step s and any primitive triple t, t.c < (berggrenStepApply s t).c.*

*Proof sketch.* The new hypotenuse c' is given by:
- Left: c' = 2a − 2b + 3c. Since a, c > 0, we have c' ≥ 3c − 2b > c (using c > b).
- Middle: c' = 2a + 2b + 3c > 3c > c.
- Right: c' = −2a + 2b + 3c > 3c − 2a > c (using c > a). ∎

**Corollary 3.8.** *The Berggren tree is acyclic: no node is a descendant of itself.*

*Proof.* The hypotenuse is a strictly increasing natural-valued function along any path. ∎

### 3.7 Well-Definedness of Tree Evaluation

**Theorem 3.9** (`berggren_left_preserves_primitive`, `berggren_mid_preserves_primitive`, `berggren_right_preserves_primitive`). *For each step s and primitive triple t, there exists a primitive triple t' whose vector representation equals berggrenActVec(s, tripleVec(t)).*

This is the existence counterpart to the construction `berggrenStepApply`, which bundles all invariant proofs into a single function of type `BerggrenStep → PrimitiveTriple → PrimitiveTriple`.

## 4. The Berggren–Lattice Reduction Bridge

### 4.1 Gaussian Integers and Lattice Geometry

Every primitive Pythagorean triple (a, b, c) corresponds to a Gaussian integer z = a + bi with |z|² = c². The Berggren matrices act on these Gaussian integers, and their action is compatible with the geometry of rank-2 integer lattices. Specifically, the lattice Λ = ℤ·1 + ℤ·z has a basis whose Gram matrix encodes the triple.

### 4.2 Lattice Reduction and Cryptography

The LLL algorithm and its descendants (BKZ, HKZ) reduce lattice bases to find short vectors. The hardness of this problem—the Shortest Vector Problem (SVP)—is the security foundation of lattice-based cryptographic schemes now being standardized for post-quantum security (NIST standards FIPS 203, 204, 205).

The Berggren tree provides a *structured family of lattices with known geometry*. Each triple (a, b, c) defines a 2-dimensional lattice whose shortest vector and successive minima can be computed in closed form. This makes the Berggren family a natural source of:

1. **Test instances** for lattice reduction algorithms with known optimal solutions.
2. **Trapdoor constructions** where the Berggren word (path from root) serves as the trapdoor: knowing the word makes it easy to recover the short vector, but given only the lattice, finding the word requires solving a lattice problem.

### 4.3 The Depth Bound

The function `berggrenDepthBound(t) = |c|` provides a natural measure of the depth of a triple in the tree. By Theorem 3.7, this bound is strictly monotone: each step increases the depth bound. This gives complexity-theoretic control over the tree traversal.

## 5. Algorithms

### 5.1 Berggren Tree Traversal

The evaluation function `berggrenWordEval` implements tree traversal by sequential application of Berggren steps:

```
function berggrenWordEval(word, t):
    for step in word:
        t ← berggrenStepApply(step, t)
    return t
```

This runs in O(n) matrix-vector multiplications where n = |word|, each multiplication using O(1) integer operations (the matrices are 3×3 with constant entries). The bit-complexity is O(n²) since the coordinates grow exponentially with the word length: the largest eigenvalue of each Berggren matrix exceeds 3, so after n steps the hypotenuse is Θ(3ⁿ), requiring O(n) digits.

### 5.2 Inverse Traversal

Each Berggren matrix has determinant −1, hence is invertible over ℤ. The inverse matrices allow climbing the tree from any triple back to the root (3, 4, 5). At each step, one tests which of the three inverse matrices produces a valid triple (positive coordinates, correct parity) and applies it. This ascent terminates in O(log c) steps by Theorem 3.7, since the hypotenuse decreases by a constant factor at each step.

The inverse matrices are:

$$
L^{-1} = \begin{pmatrix} 1 & 2 & -2 \\ 2 & 1 & -2 \\ 2 & 2 & -3 \end{pmatrix}, \quad
M^{-1} = \begin{pmatrix} 1 & -2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & -3 \end{pmatrix}, \quad
R^{-1} = \begin{pmatrix} -1 & 2 & -2 \\ 2 & -1 & 2 \\ -2 & 2 & -3 \end{pmatrix}.
$$

At each node, exactly one of these three inverses produces a triple with all-positive coordinates and hypotenuse smaller than the current one, uniquely determining the parent.

### 5.3 Enumeration up to a Bound

To enumerate all primitive Pythagorean triples with hypotenuse at most N, one performs a bounded depth-first search of the Berggren tree, pruning any branch where c > N. By Theorem 3.7, all descendants of such a pruned node also have c > N, so no triples are missed. The number of primitive triples with hypotenuse at most N is asymptotically N/(2π), so the algorithm runs in optimal O(N) time (ignoring logarithmic factors from arithmetic on O(log N)-bit integers).

## 6. Discussion

### 6.1 Scope of Verification

The formalization covers the *forward* direction of the Berggren tree: every node has three well-defined children. The *surjectivity* claim—that every primitive triple appears in the tree—is not formalized here but follows from the classical theory (the inverse matrices provide an ascent algorithm that terminates at the root). The *injectivity* claim—that no triple appears twice—follows from the strict hypotenuse monotonicity (Theorem 3.7): if two distinct paths led to the same triple, one path would have to go both up and down in the hypotenuse ordering, which is impossible.

### 6.2 Proof Techniques

The formal proofs employ several complementary techniques:

- **Nonlinear arithmetic** (`nlinarith`, `linarith`): for the Pythagorean equation and positivity bounds. The preservation of a² + b² = c² reduces to verifying polynomial identities, which `nlinarith` handles by combining the hypothesis with squared-difference witnesses.
- **Modular arithmetic** (`norm_num` with `Int.add_emod`, `Int.mul_emod`): for parity preservation. The key insight is that all coefficients of b and c in the first-coordinate formula are even, so the oddness of a propagates.
- **Divisibility descent** (explicit divisibility chains): for coprimality, the most challenging family of results. The proof constructs an explicit chain: if d | gcd(a', b'), then d² | c'², hence d | c', and then d | a and d | b via the inverse matrix, contradicting gcd(a, b) = 1.
- **Case splitting** on `BerggrenStep`: each theorem reduces to three cases (left, mid, right), each handled by the same algebraic strategy with different sign patterns.

### 6.3 Coprimality: The Central Challenge

The coprimality proofs deserve special discussion as they are by far the most intricate. For each of the three Berggren steps, we must show that if gcd(a, b) = 1 for the parent triple, then gcd(a', b') = 1 for the child. The proof has three stages:

1. **Forward pass**: Assume d = gcd(a', b'). Since d divides both a' and b', it also divides a'² + b'² = c'² (by Theorem 3.1), and hence d divides c' (since d² | c'² implies d | c' by unique factorization).

2. **Backward pass**: Express the original coordinates (a, b, c) as integer linear combinations of (a', b', c'). This is possible because each Berggren matrix has determinant −1, hence its inverse has integer entries. The divisibility of (a', b', c') by d then implies d | a and d | b.

3. **Contradiction**: Since d | gcd(a, b) = 1, we conclude d = 1.

The formal implementation of step 2 requires careful tracking of the exact linear combinations, which differ for each of the three matrices.

### 6.4 Relationship to the Lorentz Group

The three Berggren matrices generate a subgroup of the integer Lorentz group O(2,1;ℤ)—the group of 3×3 integer matrices preserving the quadratic form x² + y² − z². This Lorentz group is infinite, and the Berggren generators produce a free subgroup of index 2 in the subgroup that maps the positive octant to itself. This group-theoretic perspective explains why exactly three generators suffice and why the tree structure is ternary.

### 6.5 Relationship to Prior Formalizations

We are not aware of prior formal verifications of the Berggren tree in any proof assistant. The present work provides a complete foundation for further formalization of the tree's enumerative properties. The closest related formalizations are treatments of Pythagorean triples in Coq and Isabelle/HOL, but these focus on the parametric characterization (the Euclid formula m² − n², 2mn, m² + n²) rather than the tree structure.

## 7. Applications

### 7.1 Cryptographic Trapdoor Constructions

The Berggren tree suggests a natural trapdoor construction for lattice-based cryptography. The *trapdoor* is a Berggren word w (a sequence of L, M, R steps). The *public key* is the primitive triple t = berggrenWordEval(w, root). To encrypt, the sender encodes a message as a nearby lattice point; to decrypt, the receiver uses the Berggren word to efficiently solve the closest vector problem on the associated lattice. Without the word, decryption requires solving a lattice problem—believed to be hard even for quantum computers.

The strict hypotenuse monotonicity (Theorem 3.7) ensures that the trapdoor has a unique inverse path, and the coprimality preservation guarantees that the lattice structure remains non-degenerate at every level.

### 7.2 Computational Number Theory

The Berggren tree provides an efficient data structure for Pythagorean triple enumeration. Given the hypotenuse bound N, a bounded tree traversal produces all O(N) primitive triples in optimal time. This is superior to the brute-force approach of testing all pairs (a, b) with a² + b² ≤ N², which runs in O(N²) time.

### 7.3 Education and Visualization

The tree structure makes the infinity of Pythagorean triples tangible and navigable. Each triple has a unique "address" (its Berggren word), and the parent-child relationship has a clear geometric meaning: the child triangle is always larger than the parent, with a strictly longer hypotenuse.

## 8. Future Work

Several natural extensions present themselves:

1. **Surjectivity**: Formalize the proof that every primitive Pythagorean triple lies in the Berggren tree, by verifying the inverse ascent algorithm. The key step is showing that for any primitive triple t ≠ (3,4,5), exactly one of the three inverse matrices produces a valid triple with smaller hypotenuse.
2. **Uniqueness**: Prove that the tree visits each triple exactly once (injectivity of the word-to-triple map). This follows from surjectivity plus the fact that each node has a unique parent.
3. **Lattice reduction connection**: Formalize the correspondence between Berggren words and lattice basis reduction sequences. Each step in the Berggren tree corresponds to a specific basis transformation of the associated 2D lattice, and the sequence of transformations mirrors the steps of the Lagrange-Gauss reduction algorithm.
4. **Growth asymptotics**: Verify that the number of primitive triples with hypotenuse ≤ N is asymptotic to N/(2π). This classical result, combined with the tree structure, implies that the average branching factor at depth d is approximately 3/(2π · 3^d) · N, providing quantitative control over the tree's shape.
5. **Higher-dimensional generalizations**: Extend the tree structure to Pythagorean quadruples a² + b² + c² = d². The Berggren tree generalizes to higher dimensions via the orthogonal group O(n,1;ℤ), but the combinatorics become significantly more complex.
6. **Matrix group structure**: Formalize the fact that L, M, R generate a free group, and characterize its index in O(2,1;ℤ). This would connect the tree theory to the rich structure theory of arithmetic groups.

## 9. References

1. B. Berggren, "Pytagoreiska trianglar," *Tidskrift för elementär matematik, fysik och kemi* 17 (1934), 129–139.
2. A. Hall, "Genealogy of Pythagorean triads," *The Mathematical Gazette* 54 (1970), 377–379.
3. F.J.M. Barning, "Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices," *Math. Centrum Amsterdam Afd. Zuivere Wisk.* ZW-011 (1963).
4. H.L. Price, "The Pythagorean tree: A new species," arXiv:0809.4324 (2008).
5. D. Romik, "The dynamics of Pythagorean triples," *Transactions of the American Mathematical Society* 360 (2008), 6045–6064.
6. A.K. Lenstra, H.W. Lenstra Jr., and L. Lovász, "Factoring polynomials with rational coefficients," *Mathematische Annalen* 261 (1982), 515–534.
