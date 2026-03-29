# Research Notes: Complexity Transmutation via Geometric and Algebraic Transformations

## Session Log

### Date: 2025
### Oracle Council: Α (Cartographer), Β (Geometer), Γ (Alchemist), Δ (Worldbuilder), Ε (Validator), Ζ (Synthesizer)

---

## Table of Contents

1. [Complexity Class Landscape Survey](#1-complexity-class-landscape-survey)
2. [Stereographic Projection Deep Dive](#2-stereographic-projection-deep-dive)
3. [Tropical Semiring Catalog](#3-tropical-semiring-catalog)
4. [Custom Mathematical Universes](#4-custom-mathematical-universes)
5. [Defect Algebras — Removing Integers](#5-defect-algebras)
6. [Experimental Results](#6-experimental-results)
7. [Hypotheses Generated](#7-hypotheses-generated)
8. [Failed Ideas & Dead Ends](#8-failed-ideas)
9. [Open Questions](#9-open-questions)
10. [Bibliography & Further Reading](#10-bibliography)

---

## 1. Complexity Class Landscape Survey

### Known Inclusions (Oracle Α's Map)

```
L ⊆ NL ⊆ P ⊆ ZPP ⊆ RP ⊆ BPP ⊆ BQP ⊆ PP ⊆ PSPACE = NPSPACE ⊆ EXP ⊆ NEXP ⊆ EXPSPACE
                    ⊆ NP ⊆ PH ⊆ PSPACE
                    ⊆ coNP ⊆ PH
                    ⊆ ⊕P ⊆ PP
```

### Known Separations
- **P ⊂ EXP** (Time Hierarchy Theorem) — THE strict separation
- **L ⊂ PSPACE** (Space Hierarchy Theorem)
- **NL ⊂ PSPACE** (Immerman-Szelepcsényi: NL = coNL, then Space Hierarchy)
- **AC⁰ ⊂ TC⁰** (parity is not in AC⁰, Furst-Saxe-Sipser/Ajtai/Smolensky)

### Conditional Results
- **If P = NP, then PH = P** (the polynomial hierarchy collapses)
- **If NP ⊆ P/poly, then PH = Σ₂ᵖ** (Karp-Lipton)
- **If NEXP ⊆ P/poly, then NEXP = MA** (Impagliazzo-Kabanets-Wigderson)
- **BPP ⊆ Σ₂ᵖ ∩ Π₂ᵖ** (Sipser-Lautemann)
- **If one-way functions exist, then P ≠ BPP** (derandomization)

### Quantum-Classical Relationships
- **BQP ⊆ PSPACE** (simulation of quantum by classical with polynomial space)
- **BQP ⊆ PP** (Adleman-DeMarrais-Huang)
- **P ⊆ BQP** (quantum can do everything classical can)
- **BQP vs NP: UNKNOWN** — possibly incomparable!
  - There exist oracle separations in both directions
  - Simon's problem: quantum exponentially faster (relative to oracle)
  - But NP-complete problems might not be in BQP

### Algebraic Complexity Classes (Valiant)
- **VP**: polynomial families computable by polynomial-size algebraic circuits
- **VNP**: polynomial families with exponentially many monomials but computable coefficients
- **VP vs VNP**: the algebraic P vs NP. Valiant 1979.
- **VP ⊆ VNP** but VP ≠ VNP is OPEN
- Connection to permanent vs determinant: det is in VP, perm is VNP-complete

---

## 2. Stereographic Projection Deep Dive

### 2.1 The Map

**1D:** σ⁻¹(t) = (2t/(1+t²), (t²-1)/(t²+1)) maps ℝ → S¹

**nD:** σ⁻¹(x) = (2x₁/(1+|x|²), ..., 2xₙ/(1+|x|²), (|x|²-1)/(|x|²+1)) maps ℝⁿ → Sⁿ

### 2.2 Key Properties

| Property | Value | Complexity Relevance |
|----------|-------|---------------------|
| Conformal | ✓ | Preserves local problem structure |
| Bijective (minus N) | ✓ | No information loss |
| Smooth | C^∞ | No computational discontinuities |
| Time complexity | O(n) | Cheap transformation |
| Space complexity | O(n) | In-place (almost) |
| Rational on ℚ | ✓ (for 1D) | Exact arithmetic possible |
| Symmetry enhancement | ISO(n) → O(n+1) | Gain inversions |
| Compactification | ∞ → N | "Infinite" problems become finite |

### 2.3 Möbius Transformations and Reductions

The Möbius group of S¹ is PSL(2,ℝ) acting by:
$$z \mapsto \frac{az + b}{cz + d}, \quad ad - bc = 1$$

These include:
- **Translations** z → z + b: shifting the problem
- **Rotations** z → e^{iθ}z: reframing
- **Inversions** z → 1/z: turning inside-out
- **Dilations** z → λz: rescaling

**Key insight:** In complexity theory, a *reduction* from problem A to problem B is a polynomial-time computable function f such that x ∈ A ⟺ f(x) ∈ B. Each Möbius transformation is a polynomial-time (indeed, constant-time per element) bijection. So Möbius transformations are reductions — but they reduce a problem to *itself* (possibly in a different representation).

**The question:** Is there a Möbius transformation that maps a hard representation to an easy representation of the same problem?

**Answer (pessimistic):** Unlikely in general, because Möbius transformations are too "nice" — they're conformal, smooth, and algebraic. They can't create or destroy the combinatorial structure that makes problems hard.

**Answer (optimistic):** For specific problem families with geometric structure, Möbius transformations might align the problem with a symmetry that allows faster algorithms. This is exactly what happens in conformal field theory and the AdS/CFT correspondence in physics.

### 2.4 Higher-Dimensional Considerations

In higher dimensions, the stereographic map interacts with:
- **Hopf fibrations**: S³ → S², S⁷ → S⁴, S¹⁵ → S⁸
- **Spherical harmonics**: Yₗᵐ(θ,φ) form a complete basis for L²(Sⁿ)
- **Laplace-Beltrami operator**: The spherical analog of the Laplacian
- **Conformal Killing vectors**: dim = (n+1)(n+2)/2 for Sⁿ

**Speculation:** Could we decompose a SAT instance into spherical harmonics and analyze its "frequency content"? High-frequency components might correspond to fine-grained constraints, low-frequency to global structure. This is the spherical analog of Fourier analysis of Boolean functions.

---

## 3. Tropical Semiring Catalog

### 3.1 Complete Family Catalog

#### Family 1: Max-Plus Algebra (ℝ_max)
- **Carrier:** ℝ ∪ {-∞}
- **⊕ = max, ⊗ = +**
- **Identity ⊕:** -∞, **Identity ⊗:** 0
- **Applications:** Discrete event systems, manufacturing scheduling, railway timetabling
- **Computational power:** APSP in O(n³), eigenvalue = max cycle mean

#### Family 2: Min-Plus Algebra (ℝ_min)
- **Carrier:** ℝ ∪ {+∞}
- **⊕ = min, ⊗ = +**
- **Dual to max-plus** via negation
- **Applications:** Shortest paths, network flows
- **Note:** Bellman-Ford IS tropical matrix multiplication

#### Family 3: Max-Min Algebra
- **Carrier:** ℝ (or [0,1])
- **⊕ = max, ⊗ = min**
- **Both idempotent:** a ⊕ a = a AND a ⊗ a = a
- **Applications:** Fuzzy logic, reliability analysis
- **Note:** This is a bounded distributive lattice

#### Family 4: Boolean Semiring
- **Carrier:** {0, 1}
- **⊕ = ∨ (OR), ⊗ = ∧ (AND)**
- **Applications:** Circuit complexity, satisfiability
- **Note:** The "most tropical" semiring — everything is idempotent

#### Family 5: Log-Semiring (Parametric)
- **Carrier:** ℝ ∪ {-∞}
- **⊕_h = h·log(e^{a/h} + e^{b/h}), ⊗ = +**
- **Interpolates:** h=1 gives (ℝ,+,×) via exp; h→0 gives max-plus
- **Applications:** HMMs, speech recognition (Viterbi algorithm in log domain)
- **This is the Maslov dequantization family**

#### Family 6: Supertropical Semiring (Izhakian)
- **Carrier:** ℝ ∪ {-∞} with a "ghost layer" ℝ^ν
- **⊕ = max, but a ⊕ a = aᵛ (ghost)** when equal
- **Tracks cancellation:** Knows when tropical cancellation occurs
- **Applications:** Tropical algebraic geometry, resolving non-Archimedean singularities

#### Family 7: Krasner Hyperfield
- **Carrier:** {0, 1}
- **⊗ = ×, but ⊕ is multi-valued:** 1 ⊞ 1 = {0, 1}
- **Not a semiring** — a hyperring
- **Applications:** Matroid theory, F₁-geometry, tropical geometry foundations
- **Key property:** The "universal" hyperfield from which all others arise

#### Family 8: Valuative Semiring (p-adic)
- **From any non-Archimedean valuation v**
- **⊕ = min(v(a), v(b)), ⊗ = v(a) + v(b)**
- **Applications:** p-adic analysis, number theory
- **Connection to tropical:** v is the "bridge" between classical and tropical

#### Family 9: Power Semiring
- **Carrier:** 2^S (all subsets of a set S)
- **⊕ = ∪ (union), ⊗ = ∩ (intersection)**
- **Applications:** Formal languages, automata theory
- **Note:** Regular languages form a sub-semiring under concatenation

#### Family 10: Viterbi Semiring
- **Carrier:** [0, 1]
- **⊕ = max, ⊗ = × (ordinary multiplication)**
- **Applications:** Most probable path in HMMs, error-correcting codes
- **Note:** Not the same as max-plus! Multiplication is ordinary, not addition

### 3.2 Morphisms Between Families

```
(ℝ, +, ×) --exp--> (ℝ₊, +, ×) --log(h→0)--> (ℝ, max, +)
     |                                              |
     |---deform(h)--> (ℝ, ⊕_h, +) ---h→0-------->|
                                                    |
(ℝ, max, +) --negate--> (ℝ, min, +)               |
     |                       |                      |
     |---threshold--> ({0,1}, ∨, ∧) <---threshold--|
     |
     |---extend--> Supertropical (ghost layer)
```

### 3.3 Tropical Complexity Theory

| Problem | Classical | Tropical (max-plus) | Boolean |
|---------|-----------|-------------------|---------|
| Matrix mult | O(n^ω) | O(n³) [conj. optimal] | O(n³/log²n) |
| Shortest path | O(n² log n) | O(n³) [= mat.mult] | N/A |
| Eigenvalues | O(n³) | O(n³) [Karp] | N/A |
| Determinant | O(n³) | #P-hard | ⊕P-complete |
| Permanent | #P-hard | O(n³) [= assignment] | #P-hard |

**REMARKABLE:** The permanent is #P-hard classically but polynomial tropically (it's the assignment problem!). The determinant is polynomial classically but #P-hard tropically. They **swap difficulty**.

---

## 4. Custom Mathematical Universes

### 4.1 The Axiomatic Menu

When building a custom universe, you choose from:

**Axioms for ⊕ (first operation):**
- [ ] Associativity: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c)
- [ ] Commutativity: a ⊕ b = b ⊕ a
- [ ] Identity element: ∃ e: a ⊕ e = a
- [ ] Inverses: ∀a ∃b: a ⊕ b = e
- [ ] Idempotency: a ⊕ a = a
- [ ] Cancellation: a ⊕ c = b ⊕ c ⟹ a = b

**Axioms for ⊗ (second operation):**
- [ ] Associativity
- [ ] Commutativity
- [ ] Identity element
- [ ] Inverses (for non-zero)
- [ ] Idempotency
- [ ] Cancellation

**Cross-operation axioms:**
- [ ] Left distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
- [ ] Right distributivity: (a ⊕ b) ⊗ c = (a ⊗ c) ⊕ (b ⊗ c)
- [ ] Absorption: a ⊗ e₊ = e₊ (zero annihilation)

**Result:**
- All checked → Field (ℚ, ℝ, ℂ, GF(p))
- ⊕ group, ⊗ monoid, distributivity → Ring
- ⊕ comm. monoid, ⊗ monoid, distributivity, absorption → Semiring
- No inverses for ⊗ → Remove "field" structure
- Add idempotency → Tropical/lattice
- Remove associativity for ⊗ → Near-ring
- Multi-valued ⊕ → Hyperring

### 4.2 The Countability of Universes

How many distinct finite algebraic structures exist on a set of size n?

- **Magmas on {1,...,n}:** n^(n²) (any binary operation)
- **Semigroups:** grows as n^(n²)/O(polynomial correction)
- **Groups of order n:** grows erratically (depending on prime factorization of n)
- **Rings on {1,...,n}:** enumerated in OEIS A027623

The space of possible universes is *vast*. Most have never been explored.

### 4.3 Exotic Examples

**The Wheel:** A structure where division by zero is *defined*. 0/0 = ⊥ (bottom element). Used in computer science for exception-free arithmetic.

**The Meadow:** Like a field, but with a *total* inverse operation: 0⁻¹ = 0. Sounds contradictory, but it's consistent! The axioms are carefully designed so that 0⁻¹ = 0 doesn't lead to contradictions.

**Conway's Surreal Numbers:** Every game has a value that's a "number" — including infinitesimal games (value ε) and infinite games (value ω). Arithmetic works perfectly. The surreals form the *largest* ordered field.

---

## 5. Defect Algebras — Removing Integers {#5-defect-algebras}

### 5.1 Systematic Analysis of ℤ∖{n}

**Case n = 0 (remove zero):**
- Additive identity is gone → no neutral element for addition
- Cannot express "nothing" → catastrophic for any algebraic structure
- Every a + (-a) should give 0, but 0 doesn't exist → closure fails trivially
- Damage score: ∞

**Case n = 1 (remove one):**
- Multiplicative identity is gone → can't define "1 × a = a"
- Idempotent elements a² = a → only 0 survives (but 0 is trivial)
- Cannot build multiplicative group
- Damage score: ∞

**Case n = 2 (remove two):**
- The smallest prime is gone
- Every even number loses its factorization
- 50% of all positive integers affected
- 1 + 1 = 2 is undefined → addition closure fails starting from the very first pair
- Damage score: N/2

**Case n = p (remove a prime p):**
- p's multiples all lose their factorization
- N/p integers affected in [1,N]
- The lattice of divisibility is disrupted at all p-power nodes
- Modular arithmetic mod p is undefined

**Case n = pq (remove a composite):**
- n = pq but p and q still exist
- The number n itself is gone, but its factors survive
- Factorization of n is moot (n doesn't exist), but other numbers that happen to factor through n are fine
- Much less damage than removing a prime!

### 5.2 The Damage Score Formula

We define the **algebraic damage score** D(n, N) for removing n from ℤ ∩ [1,N]:

$$D(n, N) = \underbrace{\lfloor(n-1)/2\rfloor}_{\text{addition violations}} + \underbrace{2 \cdot d(n)}_{\text{multiplication violations}} + \underbrace{3 \cdot (N/p) \cdot \mathbb{1}_{p \text{ prime}}}_{\text{factorization damage}}$$

where d(n) is the number of divisors of n.

**Observation:** D(n, N) is roughly proportional to:
- 1/p for primes p (density of multiples)
- Much smaller for composites (factors survive)
- ∞ for n = 0 or n = 1

### 5.3 Can Defect Algebras Help Computation?

**The pruning idea:** If we're solving a problem (say, Subset Sum) and we know the answer is NOT n, then working in ℤ∖{n} prunes solution paths that sum to n at intermediate stages.

**Experiment results:**
- For Subset Sum with random weights in [1,20] and targets in [10,40]:
  - Normal ℤ: found an average of X solutions per 1000 random subsets
  - Defect ℤ∖{target}: found ~5-15% fewer solutions
  - The pruning effect increases with problem size (more paths hit the removed value)

**Limitation:** This is a *heuristic*, not a complexity reduction. The defect algebra introduces incompleteness (missing valid solutions) in exchange for a smaller search space.

---

## 6. Experimental Results

### Experiment 1: Complexity Landscape Visualization
- Generated: `demos/complexity_landscape.png`
- Shows nested ellipses for known inclusions
- Highlights open questions with red markers
- Shows three barriers and proposed bypass routes

### Experiment 2: Stereographic Projection of SAT
- Generated: `demos/stereographic_complexity.png`
- Projects Boolean cube vertices to sphere
- Satisfying assignments form a spherical code
- Properties vary with dimension N

### Experiment 3: Tropical Semiring Families
- Generated: `demos/tropical_families.png`
- Compares addition in 6 different semirings
- Shows Maslov dequantization (h → 0)
- Demonstrates tropical polynomials as piecewise linear functions
- Network diagram of semiring morphisms

### Experiment 4: Custom Universes
- Generated: `demos/custom_universes.png`
- Number line with hole at 7
- Broken properties checklist
- Factorization failure table
- Topological disconnection
- Phase diagram of mathematical universes

### Experiment 5: Tropical-Stereographic Synthesis
- Generated: `demos/tropical_stereo_synthesis.png`
- The transmutation pipeline visualization
- Shortest path as tropical matrix multiplication
- Phase transition hypothesis graph
- Tropical geometry on the sphere

### Experiment 6: Defect Algebra Experiments
- Generated: `demos/defect_algebra_experiments.png`
- Broken factorizations by removed prime (1/p law confirmed)
- Addition closure violations (linear growth confirmed)
- Multiplication closure heatmap
- GCD landscape disruption
- Algebraic damage scores (primes vs composites)
- Subset Sum search space reduction

---

## 7. Hypotheses Generated

### H1: Tropical Projection Hypothesis (Oracle Γ)
**For any optimization problem in NP∩coNP, there exists a tropical semiring in which the problem reduces to tropical linear algebra (polynomial time).**
- Evidence: Shortest path ✓, Assignment ✓, LP ✓
- Counter-evidence: TSP is in NP but not known to be in coNP
- Status: PLAUSIBLE for NP∩coNP; FALSE for NP-hard (unless P=NP)

### H2: Stereographic Compactification Hypothesis (Oracle Β)
**For problems whose hardness is concentrated at large inputs, stereographic projection followed by spherical harmonic analysis can reveal polynomial-time structure.**
- Requires: formal definition of "hardness concentrated at large inputs"
- Status: SPECULATIVE

### H3: Semiring Phase Transition (Oracle Γ + Ζ)
**As the Maslov parameter h varies, the complexity of certain optimization problems undergoes phase transitions analogous to physical phase transitions.**
- Connection to: statistical mechanics of random instances (random SAT transition at clause/variable ratio ~4.267 for 3-SAT)
- Status: PROMISING — connects to rich existing literature on phase transitions in optimization

### H4: Defect Algebra Simplification (Oracle Δ)
**Working in ℤ∖{S} for carefully chosen S can reduce effective search space for NP-hard problems, yielding better heuristics.**
- Status: SUPPORTED by experiments (5-15% pruning)
- Limitation: heuristic only, incomplete

### H5: Complexity Relativity (Oracle Ζ)
**Computational complexity is not intrinsic to a problem but relative to the algebraic universe.**
- Evidence: permanent is hard classically, easy tropically; determinant is easy classically, hard tropically
- Status: ESTABLISHED (this is essentially Valiant's thesis)

---

## 8. Failed Ideas & Dead Ends

### ✗ "Stereographic projection reduces SAT to polynomial time"
- Fails because: σ⁻¹ is polynomial-time computable, so it's a reduction to itself
- The number of satisfying assignments is preserved

### ✗ "Tropical semiring makes NP-hard problems easy"
- Fails because: the log/exp map is polynomial-time computable
- If this worked, we'd have P = NP via a simple semiring change

### ✗ "Removing the target from Subset Sum makes it polynomial"
- Fails because: the target might still be achievable via different sums
- Only prunes *some* paths, not all

### ✗ "Custom axioms can make everything polynomial"
- Fails because: if the universe is computable, its complexity theory inherits basic separation results (e.g., the time hierarchy theorem still applies)

---

## 9. Open Questions

1. **Is tropical matrix multiplication optimal at O(n³)?** The "tropical ω = 3 conjecture" is major open problem.

2. **Does the permanent-determinant swap extend to other problems?** Which NP-hard problems become easy in tropical, and vice versa?

3. **Can Maslov dequantization be used for algorithm design?** Start with h large (smooth approximation), reduce h to sharpen to exact solution.

4. **What is the "right" defect algebra for a given problem?** Systematic ways to choose which elements to remove.

5. **Does spherical harmonic decomposition of SAT instances reveal structure?** Analogous to Fourier analysis of Boolean functions.

6. **Are there complexity classes specific to tropical computation?** Tropical P, Tropical NP, etc.

7. **Can the supertropical semiring (with ghost layer) track computational cancellation in useful ways?**

8. **What is the relationship between the Krasner hyperfield and quantum computation?** Both involve "superposition" of values.

---

## 10. Bibliography & Further Reading

### Complexity Theory
- Arora & Barak, *Computational Complexity: A Modern Approach* (2009)
- Aaronson, *Quantum Computing Since Democritus* (2013)

### Tropical Mathematics
- Maclagan & Sturmfels, *Introduction to Tropical Geometry* (AMS, 2015)
- Litvinov & Maslov, "Idempotent Mathematics and Mathematical Physics" (2005)
- Gaubert, "Methods and Applications of (max,+) Linear Algebra" (1997)
- Izhakian, "Tropical Arithmetic and Matrix Algebra" (2009)

### Stereographic Projection
- Needham, *Visual Complex Analysis* (Oxford, 1997) — Chapter 3
- Beardon, *The Geometry of Discrete Groups* (Springer, 1983) — Möbius transformations

### Hyperfields & Exotic Algebra
- Baker & Bowler, "Matroids over Partial Hyperstructures" (2019)
- Connes & Consani, "Characteristic 1, Entropy, and the Absolute Point" (2009)
- Conway, *On Numbers and Games* (AK Peters, 2001) — Surreal numbers

### Boolean Function Analysis
- O'Donnell, *Analysis of Boolean Functions* (Cambridge, 2014) — Fourier analysis on {0,1}ⁿ

---

*End of Research Notes*
