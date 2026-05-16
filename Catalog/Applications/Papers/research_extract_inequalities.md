# Weak Morse Inequalities for Finite Chain Complexes: A Formally Verified Algebraic Framework

## Abstract

We present a complete, machine-verified formalization of the weak Morse inequalities for three-term chain complexes of finite-dimensional vector spaces over an arbitrary field. Our framework extracts the algebraic core of Morse theory — the rank-extraction mechanism by which chain-group dimensions bound homology dimensions — and proves three main results: (1) the weak Morse inequalities in degrees 0, 1, 2; (2) the Euler characteristic identity equating the alternating sum of chain dimensions to that of Betti numbers; and (3) the critical cell inequality βₖ ≤ cₖ for discrete Morse data. We specialize these results to finite 2D polyhedral complexes, obtaining the classical formula V − E + F = β₀ − β₁ + β₂. The formalization is implemented in Lean 4 using the Mathlib library, with all proofs verified without axioms beyond the standard foundational axioms (propext, Classical.choice, Quot.sound). This work provides the first formally verified bridge from homological algebra to discrete Morse theory and topological data analysis.

## 1. Introduction

### 1.1 Motivation

The Morse inequalities, originally proved by Marston Morse in the smooth setting [Morse 1934], relate the topology of a manifold to the critical points of smooth functions defined on it. Their discrete analog, introduced by Forman [Forman 1998, 2002], provides a purely combinatorial framework that has found applications in topological data analysis [Edelsbrunner & Harer 2010], computational topology [Zomorodian 2005], and optimization theory.

Despite their importance, these inequalities have not previously been formalized in a proof assistant. This gap reflects both the complexity of the geometric gradient-flow machinery underlying classical proofs and the absence of sufficient homological algebra infrastructure in formal libraries.

Our key insight is that the Morse inequalities are fundamentally a **rank-extraction theorem** for chain complexes. The geometric content — gradient flows, critical points, Morse functions — serves to produce a chain complex; the inequalities themselves follow from pure linear algebra. By isolating this algebraic core, we obtain a formalization that is both rigorous and modular, interfacing cleanly with future work on persistent homology, discrete Morse theory, and topological optimization.

### 1.2 Contributions

1. **ThreeTermComplex**: A structure encoding finite-dimensional chain complexes C₂ → C₁ → C₀ over an arbitrary field, with definitions of Betti numbers as dimensions of homology quotients.

2. **Weak Morse Inequalities** (Theorems A1–A3): For any three-term complex:
   - β₀ ≤ dim C₀
   - β₁ − β₀ ≤ dim C₁ − dim C₀ (over ℤ)
   - β₂ − β₁ + β₀ = dim C₂ − dim C₁ + dim C₀ (Euler characteristic equality)

3. **Polyhedral Euler Characteristic** (Theorem B): For a finite 2D polyhedral complex with V vertices, E edges, F faces: V − E + F = β₀ − β₁ + β₂.

4. **Discrete Morse Critical Cell Bounds** (Theorem C): Given a discrete Morse datum with critical cell counts c₀, c₁, c₂ and a chain equivalence certificate: βₖ ≤ cₖ for k = 0, 1, 2.

5. **Full machine verification** in Lean 4 with Mathlib, with no sorry's and only standard axioms.

### 1.3 Related Work

Hales et al. [2017] formalized the Kepler conjecture using extensive computational verification. Our work is methodologically similar in spirit: we formalize a foundational result that provides certified bounds.

The Mathlib library [mathlib community 2020] provides extensive infrastructure for linear algebra, including rank-nullity theorems, quotient space dimensions, and finite-dimensional vector space theory. We build directly on this infrastructure.

Forman's discrete Morse theory [Forman 1998] provides the combinatorial framework that motivates our critical cell bounds. Edelsbrunner and Harer [2010] give a comprehensive treatment of persistent homology, which our framework is designed to extend.

## 2. Mathematical Framework

### 2.1 Three-Term Chain Complexes

**Definition 1** (Three-Term Chain Complex). A *three-term chain complex* over a field K consists of finite-dimensional K-vector spaces C₀, C₁, C₂ and K-linear maps d₁: C₁ → C₀ and d₂: C₂ → C₁ satisfying the *chain condition* d₁ ∘ d₂ = 0.

The chain condition ensures that boundaries are cycles:

**Lemma 1.** im(d₂) ⊆ ker(d₁).

*Proof.* For any x ∈ im(d₂), write x = d₂(y). Then d₁(x) = d₁(d₂(y)) = (d₁ ∘ d₂)(y) = 0. □

### 2.2 Homology

**Definition 2** (Betti Numbers). The *Betti numbers* of a three-term complex are:
- β₀ = dim(C₀ / im(d₁)) — the 0th homology dimension
- β₁ = dim(ker(d₁) / im(d₂)) — the 1st homology dimension  
- β₂ = dim(ker(d₂)) — the 2nd homology dimension

The quotient in β₁ is well-defined by Lemma 1: im(d₂) ⊆ ker(d₁), so im(d₂) is a subspace of ker(d₁).

### 2.3 Chain-Group Decomposition

The fundamental algebraic identity underlying all Morse inequalities:

**Theorem 1** (Master Decomposition). For any three-term complex:
- dim C₀ = β₀ + dim B₀
- dim C₁ = β₁ + dim B₁ + dim B₀  
- dim C₂ = β₂ + dim B₁

where B₀ = im(d₁) and B₁ = im(d₂).

*Proof.* Each identity follows from rank-nullity and the quotient dimension formula.

For dim C₀: The quotient C₀/B₀ has dimension β₀, and the inclusion B₀ ↪ C₀ gives dim C₀ = β₀ + dim B₀ by `Submodule.finrank_quotient_add_finrank`.

For dim C₁: Rank-nullity for d₁ gives dim C₁ = dim(ker d₁) + dim(im d₁) = dim(ker d₁) + dim B₀. The quotient ker(d₁)/B₁ has dimension β₁, so dim(ker d₁) = β₁ + dim B₁. A key technical step is showing that dim(B₁ inside ker d₁) = dim B₁, which uses the inclusion B₁ ⊆ ker d₁ (Lemma 1).

For dim C₂: Rank-nullity for d₂ gives dim C₂ = dim(ker d₂) + dim(im d₂) = β₂ + dim B₁. □

### 2.4 Formal Verification of the Comap Dimension Identity

The most technically subtle step is Theorem 1's identity for C₁, specifically the claim that dim(B₁.comap Z₁.subtype) = dim B₁ where Z₁ = ker(d₁). In the formalization, B₁ lives in C₁ while the quotient defining β₁ lives in the submodule Z₁ = ker(d₁). We must pull B₁ back to Z₁ via the comap of the subtype inclusion.

The proof uses `Submodule.finrank_map_subtype_eq` to relate the comap to the original submodule, exploiting the fact that B₁ ≤ Z₁ implies the map is an isomorphism on B₁.

## 3. Main Results

### 3.1 Weak Morse Inequalities

**Theorem 2** (Weak Morse Inequalities). For any three-term complex over a field K:

(a) **Degree 0**: β₀ ≤ dim C₀

(b) **Degree 1**: β₁ − β₀ ≤ dim C₁ − dim C₀ (over ℤ)

(c) **Degree 2** (Euler): β₂ − β₁ + β₀ = dim C₂ − dim C₁ + dim C₀

*Proof.*

(a) Immediate from dim C₀ = β₀ + dim B₀ and dim B₀ ≥ 0.

(b) From the decomposition:
  dim C₁ − dim C₀ = (β₁ + dim B₁ + dim B₀) − (β₀ + dim B₀) = β₁ − β₀ + dim B₁ ≥ β₁ − β₀.

(c) 
  dim C₂ − dim C₁ + dim C₀ = (β₂ + dim B₁) − (β₁ + dim B₁ + dim B₀) + (β₀ + dim B₀)
  = β₂ − β₁ + β₀.

Note that inequality (c) is actually an *equality*, which is stronger than the general Morse inequality pattern. This is because the complex is concentrated in degrees 0, 1, 2 and vanishes above degree 2. □

**Remark.** The degree-2 case being an equality rather than an inequality is the Euler characteristic identity. In higher-dimensional complexes, the top-degree weak Morse inequality would also be an equality, while intermediate degrees give strict inequalities.

### 3.2 Euler Characteristic Identity

**Theorem 3** (Euler Characteristic). For any three-term complex:
  dim C₀ − dim C₁ + dim C₂ = β₀ − β₁ + β₂

This is Theorem 2(c) restated. The proof is a direct consequence of the master decomposition: boundary contributions cancel in the alternating sum.

### 3.3 Polyhedral Euler Characteristic

**Definition 3** (Polyhedral Complex). A *finite 2D polyhedral complex* over K consists of:
- Finite types V (vertices), E (edges), F (faces)
- Linear maps d₁: K^E → K^V and d₂: K^F → K^E
- Chain condition: d₁ ∘ d₂ = 0

The chain groups are free vector spaces K^V, K^E, K^F with dimensions dim K^V = |V|, dim K^E = |E|, dim K^F = |F|.

**Theorem 4** (Polyhedral Euler Characteristic). For any finite 2D polyhedral complex:
  |V| − |E| + |F| = β₀ − β₁ + β₂

*Proof.* Apply Theorem 3 to the underlying three-term complex, using dim K^X = |X| (the finrank of a function space equals the cardinality of the domain). □

### 3.4 Discrete Morse Critical Cell Bounds

**Definition 4** (Discrete Morse Data). A *discrete Morse datum* consists of:
- An original three-term complex (the full complex)
- A Morse complex (the critical-cell complex)
- Critical cell counts c₀, c₁, c₂
- Dimension certificates: dim Mₖ = cₖ for k = 0, 1, 2
- Chain equivalence certificates: βₖ(original) = βₖ(morse) for k = 0, 1, 2

**Theorem 5** (Critical Cell Inequality). For any discrete Morse datum: βₖ ≤ cₖ for k = 0, 1, 2.

*Proof.* By the chain equivalence certificate, βₖ(original) = βₖ(morse). By the weak Morse inequality applied to the Morse complex, βₖ(morse) ≤ dim Mₖ. By the dimension certificate, dim Mₖ = cₖ. □

**Theorem 6** (Euler via Critical Cells). c₀ − c₁ + c₂ = β₀ − β₁ + β₂.

*Proof.* Apply Theorem 3 to the Morse complex, using the dimension and chain equivalence certificates. □

## 4. Algorithms

### 4.1 Computing Betti Numbers

Given explicit matrices for d₁ and d₂, the Betti numbers can be computed as:
- β₀ = dim C₀ − rank(d₁)
- β₁ = dim C₁ − rank(d₁) − rank(d₂)
- β₂ = dim C₂ − rank(d₂)

```
Algorithm: ComputeBettiNumbers(d1, d2)
Input: Matrices d1 (m₁ × n₁), d2 (n₁ × n₂) with d1 · d2 = 0
Output: Betti numbers β₀, β₁, β₂

1. r₁ ← rank(d1)    // via SVD or row reduction
2. r₂ ← rank(d2)
3. β₀ ← m₁ − r₁
4. β₁ ← n₁ − r₁ − r₂
5. β₂ ← n₂ − r₂
6. return (β₀, β₁, β₂)

Time complexity: O(max(m₁n₁², n₁n₂²)) for rank computation
Space complexity: O(m₁n₁ + n₁n₂)
```

### 4.2 Verifying Morse Inequalities

```
Algorithm: VerifyMorseInequalities(d1, d2)
Input: Boundary matrices d1, d2
Output: Boolean indicating whether all weak Morse inequalities hold

1. Verify d1 · d2 = 0
2. (β₀, β₁, β₂) ← ComputeBettiNumbers(d1, d2)
3. (c₀, c₁, c₂) ← (cols(d1), rows(d1), rows(d2))  // chain dimensions
4. Check β₀ ≤ c₀
5. Check β₁ − β₀ ≤ c₁ − c₀
6. Check β₂ − β₁ + β₀ = c₂ − c₁ + c₀
7. return all checks pass

Note: By our theorem, steps 4-6 ALWAYS pass when step 1 succeeds.
```

### 4.3 Discrete Morse Reduction

```
Algorithm: DiscreteMorseReduction(vertices, edges, faces, d1, d2)
Input: Cell sets and boundary matrices
Output: Critical cells and Morse complex

1. Initialize all cells as critical
2. For each edge e:
     For each vertex v incident to e:
       If v is unpaired and e is unpaired:
         Pair (v, e) — both become non-critical
3. For each face f:
     For each edge e incident to f:
       If e is unpaired and f is unpaired:
         Pair (e, f) — both become non-critical
4. Count remaining unpaired cells: c₀, c₁, c₂
5. Construct Morse boundary matrices md1, md2
6. Verify: βₖ(md1, md2) = βₖ(d1, d2)
7. return (c₀, c₁, c₂, md1, md2)
```

## 5. Applications

### 5.1 Topological Data Analysis

The weak Morse inequalities provide certified lower bounds for persistent homology computations. Given a filtered simplicial complex K₀ ⊆ K₁ ⊆ ⋯ ⊆ Kₙ, the Morse inequalities at each filtration level constrain the possible Betti numbers:

β₀(Kᵢ) ≤ |vertices in Kᵢ|

This is trivial but the alternating inequalities are not: they constrain how fast Betti numbers can grow relative to cell counts, providing quality bounds for topological feature detection.

### 5.2 Sensor Network Coverage

A sensor network covering a planar region can be modeled as a 2D polyhedral complex where vertices are sensors, edges connect nearby sensors, and faces represent covered triangular regions. The Euler characteristic formula V − E + F = β₀ − β₁ + β₂ then provides:

- β₀ = number of connected components
- β₁ = number of coverage holes
- β₂ = 0 (typically, for planar networks)

The Morse inequality β₁ ≤ E − V + β₀ gives an upper bound on coverage holes from the network combinatorics alone.

### 5.3 Optimization Landscapes

For a polyhedral loss landscape with V local minima, E saddle connections, and F plateau regions, the Morse inequalities force:

V − E + F = β₀ − β₁ + β₂

Any optimization algorithm must encounter at least β₀ connected components and β₁ non-trivial cycles in the landscape, providing complexity lower bounds.

## 6. Computational Experiments

We implemented the algorithms in Python and verified them on several standard examples.

### 6.1 Test Cases

| Complex | V | E | F | β₀ | β₁ | β₂ | χ | Morse ineqs |
|---------|---|---|---|----|----|----|----|-------------|
| Point | 1 | 0 | 0 | 1 | 0 | 0 | 1 | ✓ |
| Interval | 2 | 1 | 0 | 1 | 0 | 0 | 1 | ✓ |
| Triangle boundary | 3 | 3 | 0 | 1 | 1 | 0 | 0 | ✓ |
| Filled triangle | 3 | 3 | 1 | 1 | 0 | 0 | 1 | ✓ |
| Square boundary | 4 | 4 | 0 | 1 | 1 | 0 | 0 | ✓ |
| Torus (min) | 9 | 27 | 18 | 1 | 2 | 1 | 0 | ✓ |

### 6.2 Verification

For each test case, we verified:
1. The chain condition d₁ · d₂ = 0
2. The Betti numbers via rank computation
3. All three weak Morse inequalities
4. The Euler characteristic identity

All verifications passed, consistent with our theorems.

## 7. Discussion

### 7.1 Significance

Our formalization isolates the algebraic engine of Morse theory in a form that is:

1. **Universal**: works for any field, any chain complex, not tied to specific geometric constructions
2. **Modular**: the three-term complex is a clean interface between geometry and algebra
3. **Machine-verified**: all proofs checked by a proof assistant, eliminating the possibility of error
4. **Extensible**: the framework is designed to extend to filtered complexes, higher dimensions, and cohomological generalizations

### 7.2 Technical Challenges

The main technical challenge was the **comap dimension identity**: showing that pulling back im(d₂) along the inclusion ker(d₁) ↪ C₁ preserves the dimension. This required careful use of Mathlib's submodule API, specifically `Submodule.finrank_map_subtype_eq`, to establish that the comap is isomorphic to the original submodule when the inclusion is injective and the submodule is contained in the target.

A secondary challenge was **natural number subtraction**: the Morse inequalities involve alternating sums, which are awkward over ℕ due to truncating subtraction. We resolved this by stating all alternating inequalities over ℤ, which provides a clean and mathematically natural formulation.

### 7.3 Limitations

Our formalization is limited to three-term complexes (degrees 0, 1, 2). The general Morse inequalities hold for chain complexes of arbitrary length, and extending our framework would require:

1. An inductive/recursive definition of chain complexes of arbitrary length
2. A general alternating sum function
3. An inductive proof of the telescoping identity

These extensions are straightforward mathematically but require additional Lean infrastructure.

## 8. Future Work

1. **Persistent Morse Inequalities**: Extend to filtered chain complexes and prove persistent versions of the Morse inequalities, providing certified bounds on barcode lengths.

2. **General Chain Complexes**: Extend from three-term to n-term complexes using Mathlib's `ChainComplex` API.

3. **Simplicial Complex Interface**: Connect to Mathlib's `SimplicialComplex` type and derive f-vector/Betti number inequalities.

4. **Computational Extraction**: Use Lean's code extraction to produce verified algorithms for Betti number computation.

5. **Cohomological Generalizations**: Develop the dual theory for cochain complexes and prove cohomological Morse inequalities.

## References

- Bott, R. (1988). Morse theory indomitable. *Publ. Math. IHÉS*, 68, 99–114.
- Edelsbrunner, H., & Harer, J. (2010). *Computational Topology: An Introduction*. AMS.
- Forman, R. (1998). Morse theory for cell complexes. *Advances in Mathematics*, 134(1), 90–145.
- Forman, R. (2002). A user's guide to discrete Morse theory. *Séminaire Lotharingien de Combinatoire*, 48, B48c.
- Hatcher, A. (2002). *Algebraic Topology*. Cambridge University Press.
- mathlib community (2020). The Lean mathematical library. *CPP 2020*.
- Morse, M. (1934). *The Calculus of Variations in the Large*. AMS Colloquium Publications.
- Zomorodian, A. (2005). *Topology for Computing*. Cambridge University Press.
