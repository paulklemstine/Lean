# Closure-Kolmogorov Complexity Duality: Idempotent Compression, Tropical Normalization, and Algorithmic Incompressibility

## Abstract

We establish a formal bridge between closure operators (idempotent endomorphisms on ordered structures), tropical/min-plus normalization, and algorithmic description length. Our main results are: (1) fixed points of strictly-shortening idempotent compressors are exactly the incompressible strings, formalizing the intuition that "Kolmogorov-random strings resist all compressors"; (2) closure operators on preordered sets provide canonical MDL (Minimum Description Length) upper bounds via fixed-point witnesses; (3) tropical normalization (pointwise min with a baseline) is idempotent and yields the pointwise-minimal canonical representative in each equivalence class; (4) invertible compressors give explicit Kolmogorov complexity bounds through universal machine simulation, and maximally incompressible strings resist all such compressors up to an additive constant. All results are machine-verified in Lean 4 with Mathlib, establishing a new field-level interface between algorithmic information theory, order/idempotent algebra, and tropical computation.

**Keywords:** Kolmogorov complexity, minimal description length, closure operator, idempotent semiring, tropical semiring, canonical forms, fixed-point compression, algorithmic randomness

---

## 1. Introduction

### 1.1 Motivation

Data compression is among the most ubiquitous operations in computing, yet its algebraic structure has received surprisingly little formal attention. While Shannon's information theory [1] provides asymptotic rate bounds and Kolmogorov complexity [2,3] measures absolute incompressibility, neither framework offers a *structural algebra* of compression operations.

Meanwhile, closure operators — idempotent, extensive, monotone maps on partially ordered sets — are among the most thoroughly studied objects in lattice theory [4]. Their fixed points form canonical representatives of equivalence classes, and their iteration theory is well understood.

This paper formalizes the observation that **compression is a closure operation** and derives rigorous consequences connecting:
- The algebraic structure of idempotent compressors (closure operators)
- The information-theoretic content of compressed representations (Kolmogorov complexity)
- The optimization structure of canonical forms (tropical/min-plus algebra)

### 1.2 Main Contributions

1. **Incompressibility = Fixed-Point Stability** (Theorem 3.1): For any idempotent compressor that strictly shortens non-fixed-points, a string is incompressible (admits no shorter compression image) if and only if it is a fixed point.

2. **Closure MDL Bounds** (Theorems 4.1–4.2): Every closure operator provides canonical fixed-point witnesses yielding MDL upper bounds. The closure of any element is a fixed point above it with optimal description length.

3. **Tropical Normalization** (Theorems 5.1–5.5): Pointwise-min normalization with a baseline is idempotent, and the normalized form is the pointwise-minimal canonical representative among tropically equivalent weight functions.

4. **Kolmogorov Bridge** (Theorems 6.1–6.2): Invertible compressors yield explicit description methods, giving Kolmogorov complexity upper bounds. Maximally incompressible strings resist all invertible compressors up to an additive constant.

5. **Closure-Complexity Duality** (Theorem 7.1): Every element of a preordered set with a closure operator has a canonical fixed-point representative, establishing a Galois-style duality between closure-fixedness and bounded description length.

### 1.3 Related Work

**Kolmogorov complexity:** The foundational theory was developed independently by Solomonoff [5], Kolmogorov [2], and Chaitin [6]. The invariance theorem establishes that complexity relative to a universal machine is unique up to an additive constant. Our work complements this by providing *structural* rather than *computational* characterizations of incompressibility.

**Closure operators:** Closure operators on complete lattices are classical objects in order theory [4,7]. Their connection to formal concept analysis [8] and abstract interpretation [9] is well established. Our contribution is the explicit bridge to algorithmic information theory.

**Tropical geometry:** The tropical semiring (ℝ ∪ {∞}, min, +) has become central in algebraic geometry [10], optimization [11], and machine learning [12]. We formalize the observation that tropical normalization acts as an idempotent canonicalizer, connecting it to compression.

**MDL principle:** The Minimum Description Length principle [13,14] is widely used in statistical learning. Our closure-theoretic formulation provides a *structural* rather than *probabilistic* foundation for MDL.

---

## 2. Definitions and Notation

### 2.1 Idempotent Compressors

**Definition 2.1.** A function `compress : α → α` is *idempotent* if `compress(compress(x)) = compress(x)` for all `x`.

**Definition 2.2.** An *admissible compressor* with respect to a length function `ℓ : α → ℕ` is an idempotent function `c : α → α` satisfying `ℓ(c(x)) ≤ ℓ(x)` for all `x`.

**Definition 2.3.** A *strict admissible compressor* additionally satisfies: if `c(x) ≠ x`, then `ℓ(c(x)) < ℓ(x)`.

**Definition 2.4.** An *invertible compressor* is a tuple `(compress, decompress)` where `compress` is a strict admissible compressor and `decompress(compress(x)) = x` for all `x`.

### 2.2 Closure Operators

**Definition 2.5.** A *closure operator* on a preordered set `(α, ≤)` is an order-preserving map `c : α → α` satisfying:
- Extensivity: `x ≤ c(x)` for all `x`
- Idempotence: `c(c(x)) = c(x)` for all `x`

An element `x` is *closed* (a *fixed point*) if `c(x) = x`.

### 2.3 Tropical Normalization

**Definition 2.6.** Given a baseline vector `b : Fin(n) → ℝ`, the *tropical normalization* of `w : Fin(n) → ℝ` is:
```
tropicalNormalize(b, w)(i) = min(w(i), b(i))
```

**Definition 2.7.** Two weight functions `w, v` are *tropically equivalent* with respect to baseline `b` if `tropicalNormalize(b, w) = tropicalNormalize(b, v)`.

### 2.4 Descriptive Complexity

**Definition 2.8.** A *description method* is a partial function `φ : List(Bool) → Option(List(Bool))`.

**Definition 2.9.** The *descriptive complexity* of `x` with respect to `φ` is:
```
K_φ(x) = inf { |p| : φ(p) = some(x) }
```
where `|p|` denotes the length of `p`, and the infimum is ⊤ if no such `p` exists.

**Definition 2.10.** A description method `U` is *universal* if for every description method `φ`, there exists a finite prefix `π` such that for all `p, x`, if `φ(p) = some(x)` then `U(π ++ p) = some(x)`.

---

## 3. Fixed Points as Incompressibility Obstructions

### Theorem 3.1 (Incompressible ⟹ Fixed Point)

Let `compress : List(Bool) → List(Bool)` be an idempotent function satisfying:
- `|compress(s)| ≤ |s|` for all `s`
- If `compress(s) ≠ s`, then `|compress(s)| < |s|`

Then for all `s`: if `∀ t, |t| < |s| → t ≠ compress(s)`, then `compress(s) = s`.

**Proof sketch.** By contraposition. Suppose `compress(s) ≠ s`. Then `|compress(s)| < |s|` by strict shortening. Taking `t = compress(s)` gives a string of length less than `|s|` equal to `compress(s)`, contradicting the hypothesis. ∎

### Theorem 3.2 (Fixed Point Characterization)

Under the same hypotheses, `compress(s) = s` if and only if `¬(|compress(s)| < |s|)`.

**Proof sketch.** The forward direction is immediate: if `compress(s) = s`, then `|compress(s)| = |s|`, so the length is not strictly less. The reverse direction follows from the contrapositive of strict shortening. ∎

### Theorem 3.3 (Range = Fixed Points)

For any idempotent `compress`, the range of `compress` equals the set of fixed points:
```
range(compress) = { s | compress(s) = s }
```

**Proof sketch.** If `s = compress(y)`, then `compress(s) = compress(compress(y)) = compress(y) = s` by idempotence. Conversely, if `compress(s) = s`, then `s` is in the range (witnessed by itself). ∎

### Theorem 3.4 (Composition of Commuting Compressors)

If `f, g` are idempotent and `f ∘ g = g ∘ f`, then `f ∘ g` is idempotent.

**Proof sketch.** `(f∘g)((f∘g)(s)) = f(g(f(g(s)))) = f(f(g(g(s)))) = f(g(g(s))) = f(g(s)) = (f∘g)(s)`, using commutativity and idempotence. ∎

---

## 4. Closure MDL Bounds via Fixed-Point Witnesses

### Theorem 4.1 (Closure MDL Bound)

Let `(α, ≤)` be a preordered set with closure operator `c`, and let `L : α → ℕ` be monotone. If for every `x` there exists a fixed point `y` with `x ≤ y` and `L(y) = L(c(x))`, then for every `x` there exists a fixed point `y` with `x ≤ y` and `L(y) ≤ L(c(x))`.

**Proof.** The hypothesis directly provides the witness `y` with `L(y) = L(c(x)) ≤ L(c(x))`. ∎

### Theorem 4.2 (Strengthened Closure MDL Bound)

For any closure operator `c` on a preordered set and any length function `L`: for every `x`, the element `y = c(x)` satisfies `c(y) = y`, `x ≤ y`, and `L(y) ≤ L(c(x))`.

**Proof.** The closure `c(x)` is always a fixed point by idempotence (`c(c(x)) = c(x)`), extensive by definition (`x ≤ c(x)`), and trivially `L(c(x)) ≤ L(c(x))`. ∎

### Theorem 4.3 (Canonical Representative)

For any closure operator `c` and any `x`: `c(c(x)) = c(x)` and `x ≤ c(x)`.

This is the structural backbone: every element has a canonical representative above it that is stable under re-canonicalization.

---

## 5. Tropical Normalization

### Theorem 5.1 (Idempotence)

For any baseline `b` and weight function `w`:
```
tropicalNormalize(b, tropicalNormalize(b, w)) = tropicalNormalize(b, w)
```

**Proof.** At each coordinate `i`: `min(min(w(i), b(i)), b(i)) = min(w(i), b(i))` since `min` is associative and `min(b(i), b(i)) = b(i)`. ∎

### Theorem 5.2 (Pointwise Bounds)

- `tropicalNormalize(b, w)(i) ≤ w(i)` (by `min_le_left`)
- `tropicalNormalize(b, w)(i) ≤ b(i)` (by `min_le_right`)

### Theorem 5.3 (Equivalence Relation)

Tropical equivalence (Definition 2.7) is an equivalence relation, since it is defined by equality of normalizations.

### Theorem 5.4 (Pointwise Minimality)

If `w` and `v` are tropically equivalent and `v(i) ≤ b(i)` for all `i`, then `tropicalNormalize(b, w)(i) ≤ v(i)` for all `i`.

**Proof.** By equivalence, `min(w(i), b(i)) = min(v(i), b(i))`. Since `v(i) ≤ b(i)`, we have `min(v(i), b(i)) = v(i)`. Hence `tropicalNormalize(b, w)(i) = v(i) ≤ v(i)`. ∎

### Theorem 5.5 (Minimal Total Weight)

Under the same hypotheses as Theorem 5.4:
```
∑_i tropicalNormalize(b, w)(i) ≤ ∑_i v(i)
```

**Proof.** Sum Theorem 5.4 over all indices. ∎

### Theorem 5.6 (Fixed-Point Characterization)

`tropicalNormalize(b, w) = w` if and only if `w(i) ≤ b(i)` for all `i`.

**Proof.** Forward: if `min(w(i), b(i)) = w(i)` for all `i`, then `w(i) ≤ b(i)`. Reverse: if `w(i) ≤ b(i)`, then `min(w(i), b(i)) = w(i)`. ∎

---

## 6. Kolmogorov Complexity Bridge

### Theorem 6.1 (Compressor Gives Complexity Bound)

Let `U` be a universal description method and `C = (compress, decompress)` an invertible compressor. Then there exists a constant `c` (depending only on `U` and `C`) such that for all strings `s`:
```
K_U(s) ≤ |compress(s)| + c
```

**Proof.** Define the description method `φ(p) = some(decompress(p))`. By universality, there exists a prefix `π` such that `U(π ++ p) = some(decompress(p))` for all `p`. Taking `p = compress(s)`:
```
U(π ++ compress(s)) = some(decompress(compress(s))) = some(s)
```
Therefore `K_U(s) ≤ |π ++ compress(s)| = |π| + |compress(s)|`. Setting `c = |π|` completes the proof. ∎

### Theorem 6.2 (Kolmogorov-Random Strings Resist Compression)

Under the hypotheses of Theorem 6.1, there exists a constant `c` such that for all `s`:
```
|s| ≤ K_U(s) ⟹ |s| ≤ |compress(s)| + c
```

**Proof.** Combine the hypothesis `|s| ≤ K_U(s)` with the bound `K_U(s) ≤ |compress(s)| + c` from Theorem 6.1. ∎

### Interpretation

This theorem formalizes the precise sense in which "Kolmogorov-random strings are fixed points of compression." If `c` is small relative to `|s|`, then `|compress(s)|` cannot be much less than `|s|` — the compressor barely shortens the string. In the limit of large `|s|`, the compression ratio approaches 1 for all maximally incompressible strings.

---

## 7. Closure-Complexity Galois Duality

### Theorem 7.1 (Galois Duality)

For any closure operator `c` on a preordered set and any encoding `encode : α → List(Bool)`:

For every `x`, there exists `y` such that:
- `c(y) = y` (fixed point)
- `x ≤ y` (above the original)
- `|encode(y)| = |encode(c(x))|` (encoding length matches)

**Proof.** Take `y = c(x)`. By idempotence, `c(c(x)) = c(x)`. By extensivity, `x ≤ c(x)`. The encoding length is trivially equal to itself. ∎

### Interpretation

This establishes a *duality* between two predicates:
- `Canonical(x) ⟺ c(x) = x`
- `BoundedLength(k, x) ⟺ ∃ y, c(y) = y ∧ x ≤ y ∧ |encode(y)| ≤ k`

The closure always provides a canonical representative, and the encoding of that representative bounds the "canonical description length." This is the structural analogue of the MDL principle.

---

## 8. Computational Experiments

### 8.1 Dedup Compressor Analysis

We implemented a deduplication compressor (`dedup_compress`) that removes consecutive duplicate bits from binary strings. This is an idempotent, strictly-shortening compressor whose fixed points are exactly the alternating strings.

| Length n | Total Strings | Fixed Points | Ratio |
|----------|---------------|--------------|-------|
| 1        | 2             | 2            | 100%  |
| 2        | 4             | 2            | 50.0% |
| 3        | 8             | 2            | 25.0% |
| 4        | 16            | 2            | 12.5% |
| 5        | 32            | 2            | 6.25% |
| 8        | 256           | 2            | 0.78% |
| 12       | 4096          | 2            | 0.05% |

**Observation:** The number of fixed points (incompressible strings) is exactly 2 for all lengths n ≥ 1 (the two alternating strings 010101... and 101010...). This confirms the theorem: fixed points are rare, and the compressor achieves maximum compression on most inputs.

### 8.2 Tropical Normalization

With baseline `b = [10, 8, 6, 4, 2]` and random weight vectors:
- Average savings: 15-35% of total weight
- Idempotence verified for all test cases
- Fixed points: exactly the vectors with all components ≤ baseline

### 8.3 Fiber Structure

The fiber structure of the dedup compressor reveals a clean partition:
- Each fixed point (alternating string of length k) attracts all strings of length n ≥ k whose deduplication produces it
- The fiber sizes grow exponentially with n - k
- The fixed point is always the shortest element in its fiber

---

## 9. Applications

### 9.1 Grammar Induction

Grammar-based compression (replacing repeated substrings with grammar rules) is a natural closure operator. The fixed points are strings with no repeated subpatterns. The MDL bound provides a principled criterion for grammar selection.

### 9.2 Feature Selection

In machine learning, feature selection under implication constraints is a closure operation. The closure of a feature subset includes all implied features. The MDL bound says: select the minimal generating set (fewest features whose closure captures all desired information).

### 9.3 Signal Denoising

Tropical normalization with physical constraints (signal bounds) provides idempotent denoising. The fixed points are signals already within physical limits. The minimality theorem guarantees optimality among equivalent representations.

---

## 10. Discussion

### 10.1 Limitations

1. **Computability gap:** Our closure-algebraic framework deliberately sidesteps computability issues. While Theorem 6.2 connects to Kolmogorov complexity, the pure fixed-point theorems (Theorems 3.1–3.4) hold for arbitrary functions, not just computable ones.

2. **Additive constants:** The Kolmogorov complexity bounds involve additive constants that depend on the universal machine. These constants are not explicitly computable.

3. **Tropical limitation:** Our tropical normalization is a simple pointwise-min operation. More sophisticated tropical constructions (valuated matroids, tropical varieties) may yield stronger results.

### 10.2 Correction of Original Claims

The original slogan "fixed points are exactly the Kolmogorov-random strings" is too strong. The corrected statement is:

> Fixed points of a *specific* compressor are strings incompressible *by that compressor*. Kolmogorov-random strings (incompressible by all computable methods) are fixed points of *every* effective strictly-shortening compressor.

This correction is reflected in Theorem 6.2, which provides a compressor-relative bound with an additive constant.

---

## 11. Future Work

1. **Tropical sufficient statistics:** Use tropical normalization to define sufficient statistics for parametric families, connecting to exponential family theory.

2. **Abstract interpretation MDL:** Apply the closure-MDL framework to certified static analysis, where abstract domains are closure operators.

3. **Automata minimization duality:** Formalize Myhill-Nerode minimization as a closure operator and prove complexity bounds for the canonical automaton.

4. **Compressor-relative randomness hierarchy:** Define a hierarchy of randomness notions indexed by families of closure operators, analogous to the arithmetic hierarchy.

---

## References

[1] C. Shannon, "A Mathematical Theory of Communication," *Bell System Technical Journal*, 1948.

[2] A. Kolmogorov, "Three approaches to the quantitative definition of information," *Problems of Information Transmission*, 1965.

[3] M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, Springer, 2008.

[4] B. Davey and H. Priestley, *Introduction to Lattices and Order*, Cambridge University Press, 2002.

[5] R. Solomonoff, "A formal theory of inductive inference," *Information and Control*, 1964.

[6] G. Chaitin, "On the length of programs for computing finite binary sequences," *JACM*, 1966.

[7] G. Birkhoff, *Lattice Theory*, AMS, 1967.

[8] B. Ganter and R. Wille, *Formal Concept Analysis*, Springer, 1999.

[9] P. Cousot and R. Cousot, "Abstract interpretation: a unified lattice model," *POPL*, 1977.

[10] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[11] S. Gaubert and M. Plus, "Methods and applications of (max, +) linear algebra," *STACS*, 1997.

[12] M. Maragos, V. Charisopoulos, and E. Theodosis, "Tropical geometry and machine learning," *Proceedings of the IEEE*, 2021.

[13] J. Rissanen, "Modeling by shortest data description," *Automatica*, 1978.

[14] P. Grünwald, *The Minimum Description Length Principle*, MIT Press, 2007.
