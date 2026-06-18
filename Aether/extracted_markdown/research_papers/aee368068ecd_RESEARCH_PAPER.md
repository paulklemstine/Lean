# The Berggren Tree as a Free Semigroup Action: Formal Proofs of Preservation, Monotonicity, and Injectivity

## Abstract

We present a complete formal verification of the structural properties of the Berggren tree of primitive Pythagorean triples. Starting from the classical three-generator construction, we prove that (1) each generator preserves the Pythagorean property, primitivity, and positivity; (2) the generators lie in the integer Lorentz group O(2,1;ℤ) with determinants ±1; (3) the hypotenuse grows strictly under every generator; (4) each generator acts as a bijection on ℤ³ with explicit integer inverses; and (5) the word action on the root triple (3,4,5) is injective — distinct generator sequences produce distinct primitive triples. Together, these results establish the Berggren tree as a certified free semigroup action on the integer light cone, providing a canonical coding of all primitive Pythagorean triples and a verified enumeration algorithm.

## 1. Introduction

### 1.1 Background

The equation a² + b² = c² has been studied since antiquity. The complete parametrization of primitive solutions (those with gcd(a,b,c) = 1) has been known since Euclid: every such triple takes the form (m²−n², 2mn, m²+n²) for coprime m > n > 0 of opposite parity, up to swapping legs.

In 1934, Berggren discovered that all primitive Pythagorean triples can be generated from (3,4,5) by iterating three linear transformations, each given by a 3×3 integer matrix. This construction produces an infinite ternary tree with no repetitions — a fact proved by Barning (1963) and Hall (1970), though the original proofs were not machine-verified.

### 1.2 Contributions

We provide the first complete formal verification of the Berggren tree's structural properties, establishing:

1. **Preservation (Theorem A):** Each generator maps Berggren-primitive triples (Pythagorean, coprime legs, all positive) to Berggren-primitive triples.

2. **Determinant structure (Theorem D):** The generator matrices have determinants 1, −1, 1 respectively, and all lie in O(2,1;ℤ).

3. **Monotonicity (Theorem E):** The hypotenuse strictly increases under every generator.

4. **Injectivity (Theorem C):** The map from Berggren words to primitive triples is injective.

5. **Auxiliary results:** Forward-inverse cancellation for all generators, generator injectivity, finiteness of fixed-hypotenuse triple sets, and word action properties.

### 1.3 Related Work

Previous formalizations of Pythagorean triple theory in proof assistants have focused on the Euclid parametrization and basic properties. To our knowledge, this is the first formalization treating the Berggren tree as a dynamical system and proving word injectivity.

## 2. Definitions and Notation

### 2.1 Core Predicates

**Definition 2.1 (Pythagorean triple).** A triple (a,b,c) ∈ ℤ³ is *Pythagorean* if a² + b² = c².

**Definition 2.2 (Primitive Pythagorean triple).** A Pythagorean triple is *primitive* if gcd(a,b) = 1.

**Definition 2.3 (Berggren-primitive).** A triple is *Berggren-primitive* if it is a primitive Pythagorean triple with a > 0, b > 0, c > 0.

**Remark.** The condition gcd(a,b) = 1 implies gcd(a,b,c) = 1 for Pythagorean triples, since any common factor of a and b also divides c.

### 2.2 Berggren Generators

The three Berggren generators are defined by:

```
bergA(a,b,c) = (a − 2b + 2c,  2a − b + 2c,  2a − 2b + 3c)
bergB(a,b,c) = (a + 2b + 2c,  2a + b + 2c,  2a + 2b + 3c)
bergC(a,b,c) = (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)
```

In matrix form:

```
A = [1  -2  2]    B = [1  2  2]    C = [-1  2  2]
    [2  -1  2]        [2  1  2]        [-2  1  2]
    [2  -2  3]        [2  2  3]        [-2  2  3]
```

Their inverses:

```
A⁻¹ = [1   2  -2]    B⁻¹ = [1   2  -2]    C⁻¹ = [-1  -2   2]
      [-2  -1   2]          [2   1  -2]           [2    1  -2]
      [-2  -2   3]          [-2  -2   3]           [-2  -2   3]
```

### 2.3 Berggren Words

A *Berggren word* is a finite sequence w = g₁g₂...gₙ where each gᵢ ∈ {A, B, C}. The *word action* on a triple t is defined recursively:

```
applyWord([], t) = t
applyWord(g :: w, t) = applyWord(w, applyGen(g, t))
```

The *depth* of w is its length |w|.

### 2.4 Lorentz Form

The *Lorentz form* Q(a,b,c) = a² + b² − c² satisfies Q = 0 for Pythagorean triples. The *Lorentz metric matrix* is Q_L = diag(1, 1, −1).

## 3. Main Results

### 3.1 Theorem A: Preservation of Berggren-Primitivity

**Theorem 3.1.** For each generator G ∈ {A, B, C}, if (a,b,c) is Berggren-primitive, then G(a,b,c) is Berggren-primitive.

*Proof sketch.* The proof decomposes into three parts:

1. **Pythagorean preservation:** Direct algebraic verification that a'² + b'² = c'² whenever a² + b² = c². This is proved by expanding and using nlinarith.

2. **Positivity preservation:** Using the fact that a < c and b < c for positive Pythagorean triples, verify that all three coordinates of the child are positive. For generator B, this is immediate since all coefficients are positive. For A and C, the bounds a < c and b < c are essential.

3. **Primitivity preservation (hardest part):** Suppose prime p divides both legs of the child. Since the child is Pythagorean, p divides its hypotenuse (by the lemma: d | a and d | b implies d | c). Using the inverse transformation formulas, express the parent legs as ℤ-linear combinations of the child coordinates. Since p divides all child coordinates, it divides both parent legs — contradicting gcd(a,b) = 1.

### 3.2 Theorem D: Determinant Structure

**Theorem 3.2.** det(A) = 1, det(B) = −1, det(C) = 1.

**Theorem 3.3.** For each G ∈ {A, B, C}, Gᵀ Q_L G = Q_L (Lorentz form preservation).

*Proof.* Both are verified by direct matrix computation (native_decide).

**Corollary.** All generators lie in O(2,1;ℤ), the integer orthogonal group of the Lorentz form.

### 3.3 Theorem E: Hypotenuse Strict Growth

**Theorem 3.4.** If (a,b,c) is Berggren-primitive and (a',b',c') = G(a,b,c) for any G ∈ {A,B,C}, then c < c'.

*Proof sketch.* For generator B: c' = 2a + 2b + 3c > c since a, b > 0. For generators A and C: c' = 2a − 2b + 3c (resp. −2a + 2b + 3c), which exceeds c because a < c and b < c (from the Pythagorean constraint with positive legs).

**Corollary 3.5.** For any word w of depth d, the hypotenuse of applyWord(w, root) is at least d + 5.

**Corollary 3.6.** The depth of a triple's word encoding is bounded by its hypotenuse.

### 3.4 Theorem C: Word Injectivity

**Theorem 3.7.** The function w ↦ applyWord(w, root) is injective on Berggren words.

*Proof sketch.* We prove the stronger statement: for any Berggren-primitive triple t, the function w ↦ applyWord(w, t) is injective. The proof proceeds by well-founded induction on the words.

**Base cases:** If w₁ = [] and w₂ = g :: w₂', then applyWord(w₁, t) = t while applyWord(w₂, t) has strictly larger hypotenuse (by Theorem E), so they differ.

**Inductive case:** If w₁ = g₁ :: w₁' and w₂ = g₂ :: w₂':

- If g₁ = g₂: the equality applyWord(w₁', applyGen(g₁, t)) = applyWord(w₂', applyGen(g₁, t)) reduces to w₁' = w₂' by induction (since applyGen(g₁, t) is Berggren-primitive).

- If g₁ ≠ g₂: we show this leads to contradiction. The key insight (discovered during the formal proof search) is that for any Berggren-primitive triples t₁ and t₂, if applyGen(g₁, t₁) = applyGen(g₂, t₂), then g₁ = g₂. This is proved by examining the coordinate formulas: for different generators, the resulting triples satisfy different linear inequalities that cannot be simultaneously satisfied.

### 3.5 Auxiliary Results

**Theorem 3.8 (Forward-inverse cancellation).** For each G ∈ {A,B,C} and all (a,b,c) ∈ ℤ³:
G⁻¹(G(a,b,c)) = (a,b,c) and G(G⁻¹(a,b,c)) = (a,b,c).

**Theorem 3.9 (Generator injectivity).** Each G is a bijection on ℤ³.

**Theorem 3.10 (Distinct children).** For positive (a,b,c), the triples A(a,b,c), B(a,b,c), C(a,b,c) are pairwise distinct.

**Theorem 3.11 (Finiteness).** For fixed c, the set {(a,b) ∈ ℤ² : a² + b² = c²} is finite.

## 4. Algorithms

### 4.1 Certified BFS Enumeration

```
Algorithm: ENUMERATE_TRIPLES(max_c)
Input: maximum hypotenuse max_c
Output: all primitive Pythagorean triples with c ≤ max_c

queue ← [(3, 4, 5)]
result ← []
while queue is not empty:
    (a, b, c) ← dequeue(queue)
    if c > max_c: continue
    append (a, b, c) to result
    for G in {A, B, C}:
        (a', b', c') ← G(a, b, c)
        if c' ≤ max_c:
            enqueue(queue, (a', b', c'))
return result
```

**Correctness:** By Theorem A, every output is Berggren-primitive. By Theorem C, no output is duplicated. By the (classical) completeness of the Berggren tree, every primitive triple appears.

**Complexity:** O(N) time and space, where N is the number of primitive triples with c ≤ max_c. By classical estimates, N ≈ max_c/(2π).

### 4.2 Canonical Word Recovery

```
Algorithm: FIND_WORD(a, b, c)
Input: Berggren-primitive triple (a, b, c)
Output: unique Berggren word w such that applyWord(w, root) = (a, b, c)

word ← []
while (a, b, c) ≠ (3, 4, 5):
    for G⁻¹ in {A⁻¹, B⁻¹, C⁻¹}:
        (a', b', c') ← G⁻¹(a, b, c)
        if a' > 0 and b' > 0 and c' > 0 and gcd(a', b') = 1:
            prepend G to word
            (a, b, c) ← (a', b', c')
            break
return word
```

**Correctness:** By Theorem E, each step strictly decreases the hypotenuse, so termination is guaranteed. By the unique parent property, exactly one inverse gives a valid predecessor.

**Complexity:** O(log c) iterations (depth bounded by hypotenuse).

## 5. Computational Experiments

### 5.1 Triple Counts by Depth

| Depth | # Triples | Min Hyp | Max Hyp |
|-------|-----------|---------|---------|
| 0     | 1         | 5       | 5       |
| 1     | 3         | 13      | 29      |
| 2     | 9         | 25      | 169     |
| 3     | 27        | 41      | 985     |
| 4     | 81        | 61      | 5741    |
| 5     | 243       | 85      | 33461   |

### 5.2 Hypotenuse-Bounded Counts

| max_c | # Triples | Ratio to max_c/(2π) |
|-------|-----------|---------------------|
| 50    | 7         | 0.880               |
| 100   | 16        | 1.005               |
| 500   | 80        | 1.005               |
| 1000  | 158       | 0.993               |
| 5000  | 792       | 0.995               |

The counts closely match the asymptotic formula N(x) ~ x/(2π), confirming the classical density estimate.

### 5.3 Hypotenuse Multiplicity

The number of primitive triples sharing a hypotenuse c depends on c's prime factorization. If c = p₁^e₁ · p₂^e₂ · ... where each pᵢ ≡ 1 (mod 4), the multiplicity is 2^(k-1) where k is the number of distinct primes (counting ordered pairs (a,b) with a > 0, b > 0).

Examples:
- c = 5 (one prime ≡ 1 mod 4): 2^0 = 1 unordered pair
- c = 65 = 5·13 (two primes): 2^1 = 2 unordered pairs
- c = 1105 = 5·13·17 (three primes): 2^2 = 4 unordered pairs

## 6. Discussion

### 6.1 The Berggren Tree as a Dynamical System

Our results establish the Berggren tree as a certified arithmetic dynamical system with the following properties:

- **Free action:** The word-to-triple map is injective (Theorem C).
- **Orbit preservation:** The action preserves the light cone Q = 0 and the primitivity condition (Theorem A).
- **Monotonicity:** The hypotenuse serves as a strict Lyapunov function (Theorem E).
- **Group-theoretic embedding:** The generators lie in O(2,1;ℤ) (Theorem D).

### 6.2 Connections to Lorentzian Geometry

The equation a² + b² = c² defines the integer light cone for signature (2,1). The Berggren generators are discrete Lorentz transformations preserving this cone. This perspective connects Pythagorean triples to:

- **Thin orbit theory:** The Berggren semigroup has infinite index in O(2,1;ℤ), making it a "thin" subgroup.
- **Spectral theory:** The trace of the generators (3, 5, 3) determines their spectral properties and growth rates.
- **Apollonian packings:** Similar tree structures arise from generators in O(3,1;ℤ) acting on Descartes quadruples.

### 6.3 Limitations

Our formal proof of word injectivity establishes that different words produce different triples, but does not directly prove that *every* primitive triple is reachable (completeness). The completeness result requires the Euclid parametrization and a descent argument, which we leave for future formalization.

## 7. Future Work

1. Formalize the completeness direction: every Berggren-primitive triple lies in the tree.
2. Establish exponential growth bounds for hypotenuse vs. depth.
3. Formalize the fixed-hypotenuse multiplicity formula using Gaussian integer factorization.
4. Extend the framework to Apollonian circle packings and other thin orbit problems.
5. Develop formally verified algorithms for searching triples with specific arithmetic properties.

## References

1. Berggren, B. (1934). "Pytagoreiska trianglar." *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.
2. Barning, F.J.M. (1963). "Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices." *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, ZW-011.
3. Hall, A. (1970). "Genealogy of Pythagorean triads." *The Mathematical Gazette*, 54(390), 377–379.
4. Romik, D. (2008). "The dynamics of Pythagorean triples." *Transactions of the American Mathematical Society*, 360(11), 6045–6064.
5. Price, H.L. (2008). "The Pythagorean Tree: A New Species." *arXiv:0809.4324*.
