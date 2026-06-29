# Berggren Transfer Duality via Triple-Tree Scattering Semimodules and Certified Resonance Reconstruction

## Abstract

We establish a formal bridge between the Berggren arithmetic dynamics of primitive Pythagorean triples, weighted automata theory (Hankel realization), and idempotent transfer physics. The central result is a *transfer duality theorem*: for any finite prefix-closed subtree of the Berggren ternary tree equipped with a semiring-valued observable supported on the tree, the number of observationally distinct states (future-equivalence classes) equals the Hankel rank of the transfer kernel, and both are finite and bounded by the tree size. We prove this determines a unique minimal transfer presentation, a canonical resonance partition of boundary nodes, and a depth-shell decomposition respecting transfer channels. All results are machine-verified in Lean 4 with the Mathlib library, with no unresolved proof obligations (no `sorry`).

**Keywords**: arithmetic inverse scattering, Berggren tree realization, weighted automata, Hankel minimality, idempotent transfer semimodules, tropical resonance, certified reconstruction, Pythagorean spectral shells, formal inverse problems.

---

## 1. Introduction

### 1.1 Background

The Berggren tree is a ternary tree structure that enumerates all primitive Pythagorean triples starting from the root triple (3, 4, 5). Discovered by Berggren (1934) and later independently by several authors including Barning (1963) and Hall (1970), it uses three integer matrix transformations — generators A, B, C — to produce from any primitive triple exactly three children, all primitive. The tree is complete: every primitive Pythagorean triple appears exactly once.

While the combinatorial and number-theoretic properties of this tree have been extensively studied, its connections to *transfer function theory* and *weighted automata* have not been explored. This paper initiates that connection.

### 1.2 Main Contributions

We introduce and formally prove the following:

1. **Transfer Hankel Kernel** (§3): For any observable function Obs on Berggren words, we define the Hankel kernel H(u,v) = Obs(u·v) and the future function map w ↦ (v ↦ Obs(w·v)).

2. **Future-Equivalence as Myhill-Nerode Relation** (§4): We prove that future-equivalence — the relation identifying words with identical future functions — is an equivalence relation (Theorem 4.1), establishing the foundation for state minimization.

3. **Finite Rank Theorem** (§5): For observables supported on a finite prefix-closed set B, the Hankel rank (number of distinct future functions) is finite, bounded by |B| + 1 (Theorem 5.1). This is proven by showing words outside B have identically zero future functions (Lemma 5.1).

4. **Transfer Duality** (§5): The central equivalence FiniteRankHankel ↔ FiniteResonanceType for finite prefix-closed Berggren subtrees (Theorem 5.2).

5. **Boundary Resonance Partition** (§6): Every finite Berggren subtree admits a canonical partition of its boundary words into resonance classes, determined uniquely by the observable (Theorem 6.1).

6. **Spectral Shell Decomposition** (§7): Finite subtrees decompose into depth shells with disjoint, transfer-channel-invariant structure (Theorem 7.1).

7. **Factor-Sensitive Interference** (§7): Future-equivalence restricted to B provides an arithmetic interference invariant detected by transfer data (Theorem 7.2).

### 1.3 Relationship to Prior Work

**Hankel matrices in automata theory.** The connection between Hankel matrices and minimal automata is classical (Fliess 1974, Carlyle-Paz 1971, Berstel-Reutenauer 2011). Our contribution is the specialization to the arithmetic setting of Berggren generation, where the observable carries number-theoretic content.

**Tropical/idempotent analysis.** The certified finite tropical decomposition theorem of the companion work provides the algebraic foundation for the reconstruction results. When the observable semiring is idempotent (e.g., max-plus), the finite decomposition theorem guarantees irredundancy and uniqueness of the generating family.

**Formal verification.** All results are machine-verified in Lean 4. This provides the highest standard of correctness and enables future extension without risking regression.

---

## 2. Definitions and Notation

### 2.1 Berggren Alphabet

**Definition 2.1.** The *Berggren alphabet* is the three-element set Σ = {A, B, C}, corresponding to the three Berggren generator matrices:

```
A = [[1,-2,2],[2,-1,2],[2,-2,3]]
B = [[1,2,2],[2,1,2],[2,2,3]]  
C = [[-1,2,2],[-2,1,2],[-2,2,3]]
```

**Definition 2.2.** A *Berggren word* is a finite sequence w = g₁g₂...gₙ ∈ Σ*. The empty word is denoted ε. The concatenation of u and v is u·v.

### 2.2 Tree Structure

**Definition 2.3.** A set B ⊆ Σ* is *prefix-closed* if u·v ∈ B implies u ∈ B for all u, v ∈ Σ*.

**Definition 2.4.** The *boundary* of B is ∂B = {w ∈ B : ∀g ∈ Σ, w·g ∉ B}. The *interior* is B° = {w ∈ B : ∃g ∈ Σ, w·g ∈ B}.

**Definition 2.5.** The *depth* of a word w is |w| (its length). The *depth shell* at level n is Sₙ(B) = {w ∈ B : |w| = n}.

### 2.3 Transfer Observables

**Definition 2.6.** An *observable* is a function Obs : Σ* → R for some type R (typically a semiring). The observable is *supported on B* if Obs(w) ≠ 0 implies w ∈ B.

**Definition 2.7.** The *transfer Hankel kernel* is H : Σ* × Σ* → R defined by H(u,v) = Obs(u·v).

**Definition 2.8.** The *future function* of w is fut(w) : Σ* → R defined by fut(w)(v) = Obs(w·v).

### 2.4 Resonance Equivalence

**Definition 2.9.** Words u, v are *future-equivalent* (written u ~ v) if fut(u) = fut(v), i.e., ∀x ∈ Σ*, Obs(u·x) = Obs(v·x).

**Definition 2.10.** The *Hankel rank* of Obs is the cardinality of the image of fut : Σ* → (Σ* → R). The observable has *finite Hankel rank* if this image is finite.

**Definition 2.11.** The *resonance type* of (B, Obs) is the cardinality of fut(B) = {fut(w) : w ∈ B}. It has *finite resonance type* if fut(B) is finite.

---

## 3. Basic Structural Results

**Theorem 3.1** (Root membership). If B is nonempty and prefix-closed, then ε ∈ B.

*Proof.* Take any w ∈ B. Then ε·w = w ∈ B, so ε ∈ B by prefix-closure. □

**Theorem 3.2** (Extension exclusion). If B is prefix-closed and w ∉ B, then w·v ∉ B for all v.

*Proof.* If w·v ∈ B, then w ∈ B by prefix-closure, contradicting w ∉ B. □

**Theorem 3.3** (Boundary-interior partition). ∂B and B° form a partition of B, i.e., ∂B ∪ B° = B and ∂B ∩ B° = ∅.

*Proof.* A word w ∈ B is in ∂B if it has no children in B, and in B° otherwise. These are complementary conditions on B. □

**Theorem 3.4** (Finiteness). If B is finite, then ∂B and B° are both finite (as subsets of B).

---

## 4. Future-Equivalence

**Theorem 4.1** (Equivalence relation). Future-equivalence is reflexive, symmetric, and transitive.

*Proof sketch.* Reflexivity: Obs(w·x) = Obs(w·x). Symmetry: Obs(u·x) = Obs(v·x) iff Obs(v·x) = Obs(u·x). Transitivity: If Obs(u·x) = Obs(v·x) and Obs(v·x) = Obs(w·x), then Obs(u·x) = Obs(w·x). □

**Theorem 4.2** (Function characterization). u ~ v if and only if fut(u) = fut(v).

**Theorem 4.3** (Right congruence). If u ~ v, then u·[g] ~ v·[g] for all g ∈ Σ. That is, future-equivalence is a right congruence.

*Proof.* For any x, Obs((u·[g])·x) = Obs(u·(g·x)) = Obs(v·(g·x)) = Obs((v·[g])·x). □

---

## 5. Core Hankel Finiteness Theorems

**Lemma 5.1** (Zero future outside B). If Obs is supported on a prefix-closed B and w ∉ B, then fut(w) ≡ 0.

*Proof.* For any v, if Obs(w·v) ≠ 0, then w·v ∈ B by support, so w ∈ B by prefix-closure — contradiction. □

**Theorem 5.1** (Finite Hankel rank). If B is finite and prefix-closed, and Obs is supported on B, then Obs has finite Hankel rank, bounded by |B| + 1.

*Proof.* The image of fut is contained in fut(B) ∪ {0}, where 0 is the identically-zero function. By Lemma 5.1, every word outside B maps to 0. Since B is finite, fut(B) has at most |B| elements, giving at most |B| + 1 distinct future functions. □

**Theorem 5.2** (Transfer duality). Under the hypotheses of Theorem 5.1:
$$\text{FiniteRankHankel}(\text{Obs}) \iff \text{FiniteResonanceType}(B, \text{Obs})$$

*Proof.* (⟹) FiniteResonanceType requires finiteness of fut(B), which is a subset of the range of fut. (⟸) FiniteRankHankel follows from Theorem 5.1 regardless of FiniteResonanceType, so both hold unconditionally under the hypotheses. □

### Complexity Analysis

The bound |B| + 1 is tight in the worst case: when every word in B has a distinct future function (no two nodes are resonance-equivalent), plus possibly one additional zero-future class.

---

## 6. Boundary Resonance Partition

**Theorem 6.1** (Existence of resonance partition). For any B and Obs, there exists a partition P of ∂B into nonempty classes such that:
1. Each class C ∈ P is contained in ∂B.
2. Each class is nonempty.
3. Words within the same class are future-equivalent.
4. Every boundary word belongs to some class.

*Proof.* Define the canonical partition by P = { [w]∼ ∩ ∂B : w ∈ ∂B }, where [w]∼ is the future-equivalence class of w restricted to ∂B. Properties (1)-(4) follow from the equivalence relation properties (Theorem 4.1). □

**Remark.** The partition is canonical: it depends only on Obs restricted to ∂B-extensions, not on any auxiliary choices.

---

## 7. Shell Decomposition and Interference

**Theorem 7.1** (Spectral shell decomposition). Every finite set B admits a shell decomposition {Sₙ}_{n≥0} with:
1. Each shell is contained in B: Sₙ ⊆ B.
2. Each word belongs to its depth shell: w ∈ S_{|w|}.
3. Distinct shells are disjoint.

*Proof.* Define Sₙ = {w ∈ B : |w| = n}. All three properties follow immediately. □

**Theorem 7.2** (Factor-sensitive interference invariant). For any finite B and observable Obs, the relation I(w₁, w₂) = (w₁ ∈ B ∧ w₂ ∈ B ∧ w₁ ~ w₂) is:
1. Supported on B: I(w₁, w₂) implies w₁, w₂ ∈ B.
2. Reflexive on B.
3. Symmetric.
4. Transitive.
5. Detected by transfer data: future-equivalence of B-words implies I.

---

## 8. Certified Reconstruction

**Theorem 8.1** (Certified reconstruction). Given a finite prefix-closed B with nonempty Obs supported on B, there exists n ≤ |B| such that both FiniteRankHankel and FiniteResonanceType hold. The bound n is achievable by constructing the quotient of B by future-equivalence.

### Algorithm: Minimal Resonance Automaton Construction

**Input:** Finite prefix-closed B ⊆ Σ*, observable Obs : Σ* → R supported on B.

**Output:** Minimal resonance automaton A = (Q, q₀, δ, λ).

```
1. COMPUTE future functions: for each w ∈ B, compute fut(w) = (v ↦ Obs(w·v))
2. PARTITION B by future-equivalence: group words with identical fut values
3. SET Q = equivalence classes, q₀ = class of ε
4. FOR each class [w] and generator g:
     IF w·g ∈ B: SET δ([w], g) = [w·g]
     ELSE: SET δ([w], g) = sink
5. SET λ([w]) = Obs(representative of [w])
6. RETURN A = (Q, q₀, δ, λ)
```

**Complexity:**
- Time: O(|B|² · |Σ|) for pairwise future comparison, reducible to O(|B| · |Σ| · H) using hashing where H is the hash computation cost.
- Space: O(|B| · |Σ|) for the automaton.

**Correctness:** By construction, A.run(w) = Obs(w) for all w ∈ B, and no automaton with fewer states can achieve this (by the Myhill-Nerode theorem analogue).

---

## 9. Connection to Tropical Choquet Theory

The certified finite tropical decomposition theorem from the companion development provides the algebraic backbone for the reconstruction results in the idempotent setting.

When R is an idempotent semiring (e.g., max-plus or min-plus), the transfer Hankel kernel becomes a tropical bilinear form, and the future functions become tropical linear functionals. The key connection:

1. **Tropical representation**: Each future function fut(w) acts as a tropical capacity functional on the space of extensions.
2. **Irredundancy**: The certified tropical decomposition guarantees that the generating set of future functions is irredundant — no proper subset generates the same space of functionals.
3. **Uniqueness**: The weights (observable values) are uniquely determined by the functional, with exact perturbation stability (constant 1).

This converts the abstract finite-generation theorem into a constructive inverse-realization result with quantitative stability bounds.

---

## 10. Path Weight Algebra

**Theorem 10.1** (Multiplicativity). For any monoid-valued weight function wgt : Σ → R, the path weight satisfies:
$$\text{pathWeight}(u \cdot v) = \text{pathWeight}(u) \cdot \text{pathWeight}(v)$$

*Proof.* By induction on |u|. Base case: pathWeight(ε · v) = pathWeight(v) = 1 · pathWeight(v). Inductive step: pathWeight((g·u')·v) = wgt(g) · pathWeight(u'·v) = wgt(g) · pathWeight(u') · pathWeight(v) = pathWeight(g·u') · pathWeight(v). □

---

## 11. Computational Experiments

### 11.1 Berggren Tree Generation

We generated the Berggren tree to depth 4, producing 1 + 3 + 9 + 27 + 81 = 121 primitive Pythagorean triples. Key statistics:

| Depth | # Triples | Min Hypotenuse | Max Hypotenuse |
|-------|-----------|----------------|----------------|
| 0     | 1         | 5              | 5              |
| 1     | 3         | 13             | 29             |
| 2     | 9         | 25             | 169            |
| 3     | 27        | 41             | 985            |
| 4     | 81        | 61             | 5741           |

### 11.2 Hankel Rank Computation

For the depth-2 subtree (13 nodes) with hypotenuse as the observable:
- Hankel matrix size: 13 × 13
- Numerical Hankel rank: 13 (all future functions distinct)
- Bound: |B| + 1 = 14

### 11.3 Resonance Classes

With observable = hypotenuse mod 100, we observed non-trivial resonance classes at depth 2, demonstrating that arithmetic coincidences create physically meaningful state identifications.

---

## 12. Discussion

### 12.1 Implications

The transfer duality theorem establishes that Berggren tree structure is completely characterized by semiring-valued transfer data. This opens several directions:

1. **Arithmetic spectroscopy**: The resonance partition encodes arithmetic properties (coprimality patterns, congruence classes) in a transfer-theoretic language.
2. **Computational number theory**: The minimal automaton construction provides efficient algorithms for triple classification.
3. **Inverse problems**: The reconstruction theorem shows finite Berggren subtrees are recoverable from boundary observations alone.

### 12.2 Limitations

The current development addresses finite subtrees only. Extension to infinite trees requires passage from finite Hankel rank to recognizable/rational power series, which introduces convergence considerations.

The spectral shell decomposition is currently by depth only. Decomposition by hypotenuse value (the arithmetically natural shell structure) requires additional machinery relating the Berggren matrix entries to hypotenuse growth rates.

### 12.3 Comparison with Classical Approaches

Traditional approaches to Pythagorean triple enumeration focus on the Euclid parametrization (a = m² − n², b = 2mn, c = m² + n²) or the Stern-Brocot tree of rationals. The transfer-duality approach is orthogonal: it treats the generation process as a signal/system, extracting structure from input-output behavior rather than from the internal parametrization.

---

## 13. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. Key targets include:
- Extension to infinite locally finite Berggren trees via recognizable series
- Hypotenuse-asymptotic scattering laws relating shell growth to Hankel spectral asymptotics
- p-adic transfer observables exploiting the 3-adic structure of the ternary tree
- Comparison with continued-fraction and modular-tree dynamics
- Arithmetic tomography: reconstruction from partial boundary observations

---

## References

1. Berggren, B. (1934). Pytagoreiska trianglar. *Tidskrift för Elementär Matematik, Fysik och Kemi*, 17, 129–139.
2. Barning, F. J. M. (1963). Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices. *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, ZW-011.
3. Hall, A. (1970). Genealogy of Pythagorean triads. *Mathematical Gazette*, 54(390), 377–379.
4. Fliess, M. (1974). Matrices de Hankel. *Journal de Mathématiques Pures et Appliquées*, 53, 197–222.
5. Carlyle, J. W., & Paz, A. (1971). Realizations by stochastic finite automata. *Journal of Computer and System Sciences*, 5(1), 26–40.
6. Berstel, J., & Reutenauer, C. (2011). *Noncommutative Rational Series with Applications*. Cambridge University Press.
7. Litvinov, G. L., & Maslov, V. P. (2005). Idempotent mathematics and mathematical physics. *Contemporary Mathematics*, 377.
