# Tropical Closure Coding Theory: A Canonical Duality Between Closure Defects and Error-Correcting Syndromes

## Abstract

We establish a structural equivalence between finite closure systems and error-correcting codes over idempotent (tropical) semirings. Given a finite closure system presented by a finite family of Horn implications, we construct a canonical tropical syndrome presentation whose zero locus is exactly the set of closed states (codewords). We prove that the closure operator itself is the optimal nearest-codeword decoder in the insertion-only repair model, achieving unique decoding for all inputs—a property unattainable by classical linear codes. We establish functoriality: closure-preserving morphisms induce syndrome maps that commute with decoding. Finally, we prove a defect separation theorem that serves as a tropical analogue of the Hahn–Banach separation principle. All results are machine-verified in Lean 4 with Mathlib, producing a zero-sorry formalization.

**Keywords:** tropical coding theory, closure systems, idempotent semimodules, syndrome decoding, formal concept analysis, Horn implications, certified decoding, functorial coding theory.

---

## 1. Introduction

### 1.1 Motivation

Error-correcting codes and closure systems are two of the most widely deployed mathematical structures in computer science. Error-correcting codes, introduced by Shannon (1948) and Hamming (1950), protect data against noise by embedding messages into a structured redundancy space. Closure systems, formalized by Birkhoff (1940) and extensively developed in lattice theory, formal concept analysis (Wille, 1982), and database dependency theory (Armstrong, 1974), model consistency constraints: if certain conditions hold, certain consequences must follow.

Despite their conceptual proximity—both involve detecting and correcting deviations from a valid state—these theories have developed independently. Linear codes operate over finite fields, while closure systems are fundamentally nonlinear and order-theoretic. The algebraic machinery of one does not directly apply to the other.

This paper bridges the gap by identifying a precise structural equivalence. The connecting algebraic structure is the *tropical semiring* (ℕ, min, +), and more generally, idempotent semimodules. We show that:

1. Every finite closure system admits a canonical tropical parity presentation (Theorem A).
2. The closure operator is the optimal minimum-cost decoder (Theorem B).
3. Closure morphisms induce functorial syndrome maps (Theorem C).
4. The insertion-only decoding model guarantees unique decoding for all inputs (Theorem D).
5. A defect separation principle provides the tropical analogue of Hahn–Banach separation.

### 1.2 Related Work

**Closure systems and lattice theory.** The theory of closure operators on finite sets is classical (Birkhoff, 1940; Davey & Priestley, 2002). The connection to Horn clauses and implicational bases is well-established (Guigues & Duquenne, 1986; Wild, 1994).

**Tropical mathematics.** Tropical (idempotent) semirings and their modules have been studied extensively (Litvinov, Maslov, & Shpiz, 2001; Gaubert, 1997; Akian, Bapat, & Gaubert, 2006). Applications span optimization, algebraic geometry, and phylogenetics.

**Coding theory.** The algebraic theory of error-correcting codes over finite fields is a mature subject (MacWilliams & Sloane, 1977; Guruswami, Rudra, & Sudan, 2019). Codes over rings and non-field structures have been studied (Hammons et al., 1994), but codes over idempotent semirings are largely unexplored.

**This work.** To our knowledge, this is the first systematic development of a coding theory whose parity-check structure is a tropical/idempotent semimodule derived from a closure system. The closest prior work is the use of lattice codes in communication theory, but those operate in Euclidean space, not over idempotent semirings.

### 1.3 Contributions

- **Definitions:** `ClosureCode`, `Implication`, `ClosurePresentation`, `syndrome`, `tropicalDecode`, `ClosureHom`, `SeparationRegular`, `HellyProperty`.
- **Theorem A (Parity Presentation):** Zero syndrome ↔ closed, for any finite presenting family.
- **Theorem B (Decoder Correctness):** The closure operator is the unique minimum-cost decoder in the insertion-only model.
- **Theorem C (Functoriality):** Closure morphisms induce syndrome maps; decoding commutes with morphisms.
- **Theorem D (Unique Decoding):** Under positive weights, the minimum-cost closed superset is unique.
- **Defect Separation:** Every non-codeword is separated from the code by a violation functional.
- **Full machine verification** in Lean 4 (zero sorry).

---

## 2. Preliminaries and Definitions

### 2.1 Closure Operators

**Definition 2.1 (Closure Code).** A *closure code* on a finite type α is a triple (cl, ≤, α) where cl : 𝒫(α) → 𝒫(α) is:
- **Monotone:** S ⊆ T implies cl(S) ⊆ cl(T)
- **Extensive:** S ⊆ cl(S)
- **Idempotent:** cl(cl(S)) = cl(S)

A set S is *closed* (a *codeword*) if cl(S) = S. The collection of all closed sets forms a complete lattice under inclusion.

**Proposition 2.2.** For any set S:
1. cl(S) is closed.
2. cl(S) is the least closed superset of S.
3. If T is closed and S ⊆ T, then cl(S) ⊆ T.

### 2.2 Horn Implications

**Definition 2.3 (Implication).** An *implication* on α is a pair (A, b) where A ⊆ α is finite (the *premise*) and b ∈ α (the *conclusion*). We write A ⇒ b.

A set x *satisfies* the implication A ⇒ b if A ⊆ x implies b ∈ x.

**Definition 2.4 (Closure Presentation).** A *closure presentation* P is a finite family of implications {(Aᵢ, bᵢ)}ᵢ.

**Definition 2.5 (Presents Closure).** P *presents* a closure code C if:
- **Soundness:** Every closed set satisfies all implications in P.
- **Completeness:** Every set satisfying all implications in P is closed.

### 2.3 Tropical Syndrome

**Definition 2.6 (Violation).** The *violation* of implication (A, b) at set x is:
```
v(A,b)(x) = 1  if A ⊆ x and b ∉ x
             0  otherwise
```

**Definition 2.7 (Syndrome).** The *tropical syndrome* of x with respect to presentation P is:
```
σ_P(x) = Σᵢ v(Aᵢ, bᵢ)(x)
```

### 2.4 Repair Cost and Decoder

**Definition 2.8 (Repair Cost).** For a weight function w : α → ℕ⁺, the *insertion-only repair cost* from x to y is:
```
d_w(x, y) = Σ_{a ∈ y \ x} w(a)
```

**Definition 2.9 (Tropical Decoder).** The *tropical decoder* is:
```
decode(x) = cl(x)
```

---

## 3. Main Results

### 3.1 Theorem A: Canonical Tropical Parity Presentation

**Theorem 3.1 (Parity Presentation).** Let C be a closure code on a finite type α, and P a presentation of C. Then for any set x:
```
x is closed  ⟺  σ_P(x) = 0
```

*Proof sketch.* The syndrome is a sum of non-negative integers. It equals zero iff each summand is zero, iff each violation indicator is zero, iff x satisfies every implication, iff x is closed (by completeness of P). Conversely, if x is closed, every implication is satisfied (by soundness), so every violation is zero. □

This theorem establishes that the family of violation functionals serves as a *tropical parity-check matrix* for the closure code. The syndrome is the tropical analogue of the classical syndrome Hx^T in linear coding theory.

### 3.2 Theorem B: Decoder Correctness

**Theorem 3.2 (Decoder Specification).** For any closure code C, weight function w, and input x:
1. decode(x) is a codeword.
2. x ⊆ decode(x).
3. For every codeword y ⊇ x: d_w(x, decode(x)) ≤ d_w(x, y).

*Proof sketch.* Part 1 follows from idempotence of cl. Part 2 follows from extensiveness. Part 3 follows from the least-closed-superset property: cl(x) ⊆ y for any closed y ⊇ x, so y \ x ⊇ cl(x) \ x, hence d_w(x, y) ≥ d_w(x, cl(x)). □

**Corollary 3.3 (Decoder = Closure).** decode(x) = cl(x).

This is a powerful and elegant result: the closure operator, a purely order-theoretic object, is simultaneously the optimal decoder, an optimization-theoretic object. The two perspectives are not merely compatible—they are identical.

### 3.3 Theorem C: Functoriality

**Definition 3.4 (Closure Morphism).** A *closure morphism* f : C → D between closure codes is a monotone map f : 𝒫(α) → 𝒫(β) such that:
- f maps closed sets to closed sets.
- f(cl_C(x)) = cl_D(f(x)) for all x.

**Theorem 3.5 (Decode Naturality).** For any closure morphism f : C → D:
```
f(decode_C(x)) = decode_D(f(x))
```

*Proof.* Immediate from the commutation condition f ∘ cl_C = cl_D ∘ f. □

**Theorem 3.6 (Syndrome Naturality).** Under compatible presentations, syndromes satisfy a functorial inequality:
```
σ_{P₂}(f(x)) ≤ |P₂| · σ_{P₁}(x)
```
Under exact compatibility, equality holds.

### 3.4 Theorem D: Unique Decoding

**Theorem 3.7 (Unique Decoding).** Let C be a closure code with strictly positive weights w. If y₁, y₂ are both closed, both contain x, and both minimize repair cost, then y₁ = y₂.

*Proof sketch.* Both y₁ and y₂ contain cl(x) (least closed superset property). By monotonicity, d_w(x, cl(x)) ≤ d_w(x, yᵢ). By minimality of yᵢ, d_w(x, yᵢ) ≤ d_w(x, cl(x)). So costs are equal. But cl(x) ⊆ yᵢ with equal costs and positive weights forces yᵢ \ cl(x) = ∅, hence yᵢ = cl(x). □

This theorem shows that closure codes have a remarkable property: *every input has a unique nearest codeword*. In classical coding theory, unique decoding is only guaranteed within a bounded radius (less than half the minimum distance). Closure codes achieve unique decoding *globally* in the insertion-only model.

### 3.5 Defect Separation Theorem

**Theorem 3.8 (Defect Separation).** Let C be a closure code with presentation P. If x is not closed, there exists an implication (A, b) ∈ P such that:
1. v(A,b)(x) > 0 (positive on x)
2. v(A,b)(y) = 0 for every closed y (zero on all codewords)

*Proof sketch.* If x is not closed, then σ_P(x) > 0 (by Theorem A), so some violation is positive. By soundness, that violation is zero on all codewords. □

This is the tropical analogue of the Hahn–Banach separation theorem: non-codewords are separated from the code by violation functionals, just as points outside a convex set are separated by linear functionals.

### 3.6 Certified Decoding

**Theorem 3.9 (Certified Decoding).** For any closure code C with presentation P and input x:
1. σ_P(x) = 0 ⟺ decode(x) = x.
2. σ_P(decode(x)) = 0.

The syndrome serves as a *certificate*: zero syndrome certifies that no repair is needed, and the decoder always produces a zero-syndrome output.

---

## 4. Algorithms

### 4.1 Closure Computation

```
Algorithm: CLOSURE(x, implications)
Input: Set x, list of implications {(Aᵢ, bᵢ)}
Output: cl(x), the least closed superset of x

current ← x
repeat
    changed ← false
    for each (A, b) in implications:
        if A ⊆ current and b ∉ current:
            current ← current ∪ {b}
            changed ← true
until not changed
return current
```

**Complexity:** O(n · m) where n = |α|, m = |implications|. At most n iterations (one element added per iteration), each scanning m implications.

### 4.2 Syndrome Computation

```
Algorithm: SYNDROME(x, implications)
Input: Set x, list of implications {(Aᵢ, bᵢ)}
Output: Total syndrome σ(x)

σ ← 0
for each (A, b) in implications:
    if A ⊆ x and b ∉ x:
        σ ← σ + 1
return σ
```

**Complexity:** O(n · m).

### 4.3 Tropical Decoder

```
Algorithm: DECODE(x, implications)
Input: Set x, list of implications
Output: Nearest codeword = cl(x)

return CLOSURE(x, implications)
```

**Complexity:** O(n · m). Note that this is *linear* in the code description size, far more efficient than brute-force search over all 2ⁿ subsets.

---

## 5. Applications

### 5.1 Knowledge Base Repair

A knowledge base consists of facts and entailment rules. An inconsistent state (where some entailed facts are missing) has positive syndrome. The tropical decoder computes the minimum-cost repair by adding exactly the missing entailed facts.

**Example.** Consider 8 knowledge domains with 5 prerequisite rules. A student who knows {Calculus, Linear Algebra, Probability, Machine Learning} has syndrome 3 (missing Statistics, Optimization, and downstream consequences). The decoder adds the missing topics with minimum total difficulty.

### 5.2 Software Dependency Resolution

Package managers resolve dependencies by computing closures. Each dependency rule (package A requires package B) is an implication. The syndrome counts unresolved dependencies. The decoder (closure) computes the minimum installation set.

### 5.3 Access Control

In hierarchical permission systems, having certain permissions implies having others. An inconsistent permission assignment has positive syndrome. The decoder repairs it by granting the minimum additional permissions.

### 5.4 Formal Concept Analysis

In formal concept analysis, objects have attributes governed by implications. The closure code framework provides error correction for noisy attribute assignments, enabling robust concept learning.

---

## 6. Computational Experiments

We implemented the full tropical closure coding pipeline in Python and tested it on several examples.

### 6.1 Code Parameters

| Code | n | |C| | d | Rate | Implications |
|------|---|-----|---|------|-------------|
| Dependency (6 elements) | 6 | 26 | 1 | 0.783 | 4 |
| Knowledge (8 elements) | 8 | 108 | 1 | 0.844 | 5 |
| Permission (6 elements) | 6 | 11 | 1 | 0.576 | 6 |
| Biology (6 elements) | 6 | 32 | 1 | 0.833 | 5 |

### 6.2 Syndrome Verification

For all codes tested, Theorem A was verified exhaustively: for every subset of the ground set, closed ↔ zero syndrome. No counterexamples were found across a total of 2⁶ + 2⁸ + 2⁶ + 2⁶ = 512 subsets.

### 6.3 Decoder Optimality

For all codes tested with strictly positive weights, Theorem B was verified: the decoder output (closure) always had minimum cost among all closed supersets. Theorem D was verified: the minimum-cost closed superset was always unique.

---

## 7. Discussion

### 7.1 Comparison with Classical Codes

| Property | Linear codes (GF(q)) | Closure codes (tropical) |
|----------|---------------------|--------------------------|
| Codewords | Linear subspace | Closed sets (lattice) |
| Parity check | Matrix over GF(q) | Violation functionals |
| Syndrome | Linear map | Tropical aggregate |
| Decoder | Syndrome table / alg. | Closure operator |
| Unique decoding | Within d/2 radius | Global (insertion model) |
| Algebraic structure | Field | Idempotent semiring |

### 7.2 Limitations

1. **Insertion-only model:** Our decoder only adds elements, never removes them. For the symmetric (Hamming-style) distance, unique decoding requires additional hypotheses.
2. **Minimum distance:** The closure codes we examined have minimum distance 1, which is low. Designing closure codes with larger minimum distance is an important open problem.
3. **Scalability:** Enumerating all codewords is exponential. For practical applications, the iterative closure algorithm (linear time) is the right tool.

### 7.3 Significance

The structural equivalence between closure systems and error-correcting codes is, to our knowledge, new. It opens a bidirectional transfer of techniques:

- **From coding theory to closure theory:** Syndrome decoding, bounded-distance decoding, list decoding, capacity bounds.
- **From closure theory to coding theory:** Lattice structure, implicational bases, concept analysis, Helly-type intersection theorems.

---

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed research roadmaps. Key directions include:

1. Closure MacWilliams identities for tropical weight enumerators.
2. List decoding in closure spaces and tropical Johnson bounds.
3. Cryptographic reconstruction via closure syndrome decoding.
4. Sparse implicational presentations (LDPC analogues) with iterative decoders.
5. Channel capacity theory for closure codes.

---

## 9. References

1. Armstrong, W.W. (1974). Dependency structures of data base relationships. *IFIP Congress*, 580-583.
2. Birkhoff, G. (1940). *Lattice Theory*. AMS Colloquium Publications.
3. Davey, B.A. & Priestley, H.A. (2002). *Introduction to Lattices and Order*. Cambridge University Press.
4. Gaubert, S. (1997). Methods and applications of (max,+) linear algebra. *STACS 97*, LNCS 1200, 261-282.
5. Guigues, J.L. & Duquenne, V. (1986). Famille minimale d'implications informatives résultant d'un tableau de données binaires. *Math. Sci. Humaines*, 95, 5-18.
6. Guruswami, V., Rudra, A., & Sudan, M. (2019). *Essential Coding Theory*.
7. Hammons, A.R. et al. (1994). The Z₄-linearity of Kerdock, Preparata, Goethals, and related codes. *IEEE Trans. Inform. Theory*, 40(2), 301-319.
8. Litvinov, G.L., Maslov, V.P., & Shpiz, G.B. (2001). Idempotent functional analysis: An algebraic approach. *Math. Notes*, 69(5), 696-729.
9. MacWilliams, F.J. & Sloane, N.J.A. (1977). *The Theory of Error-Correcting Codes*. North-Holland.
10. Shannon, C.E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27, 379-423.
11. Wille, R. (1982). Restructuring lattice theory: An approach based on hierarchies of concepts. *Ordered Sets*, NATO ASI Series, 445-470.
12. Wild, M. (1994). A theory of finite closure spaces based on implications. *Advances in Mathematics*, 108, 118-139.
