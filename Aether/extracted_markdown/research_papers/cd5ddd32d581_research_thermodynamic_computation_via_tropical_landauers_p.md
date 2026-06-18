# Tropical Thermodynamics of Computation: A Formally Verified Framework

## Abstract

We present a formally verified mathematical framework connecting Landauer's principle of irreversible computation, tropical (min-plus) algebra, and circuit complexity theory. Working in Lean 4 with Mathlib, we prove three classes of theorems: (1) a fiber-counting Landauer bound establishing that any function whose fibers all have size ≥ m incurs an entropy defect of at least log m; (2) a free-energy/depth correspondence showing that the min-plus free energy of a tropical circuit equals its depth; and (3) bridge theorems connecting information erasure costs to circuit free energy through thermodynamic normalization. The framework provides a unified algebraic language in which computational irreversibility is literally an energy lower bound, and tropical circuit complexity becomes a thermodynamic invariant. All theorems are machine-verified with no axioms beyond the standard Lean foundations.

**Keywords:** Landauer principle, tropical algebra, circuit complexity, free energy, information erasure, formal verification, min-plus semiring

---

## 1. Introduction

### 1.1 Background and Motivation

Landauer's principle (1961) establishes that erasing one bit of information in a computational device requires dissipating at least *kT* ln 2 of energy, where *k* is Boltzmann's constant and *T* is the temperature [1]. This fundamental connection between information processing and thermodynamics has been experimentally confirmed [2] and extends to quantum systems [3].

Independently, tropical (min-plus) algebra has emerged as a powerful tool in optimization, algebraic geometry, and mathematical physics [4, 5]. The tropical semiring (ℝ ∪ {∞}, min, +) replaces conventional addition with minimization and conventional multiplication with addition. This structure naturally arises as the "zero-temperature limit" of statistical mechanics: when the partition function Z = Σᵢ exp(−βEᵢ) is dominated by its ground state as β → ∞, the log-partition function −β⁻¹ log Z converges to min{Eᵢ}, which is a tropical expression.

Circuit complexity theory measures computational difficulty through circuit depth (the longest sequential chain of operations) and circuit size (total number of gates). Proving lower bounds on circuit depth remains one of the central challenges in theoretical computer science.

### 1.2 Contributions

This paper establishes a precise, machine-verified bridge among these three domains:

1. **Tropical Landauer Theorem** (Theorem 3.1): For a map f: α → β between finite types with [Nonempty α], if every fiber {x | f(x) = y} has cardinality ≥ m (m ≥ 2), then log m ≤ log|α| − log|range(f)|. This is the sharp tropical analogue of Landauer's principle.

2. **Free Energy = Depth Theorem** (Theorem 4.1): For tropical circuits with sequential composition (costs add), parallel composition (costs take max), and unit-cost gates, the min-plus free energy equals the circuit depth.

3. **Bridge Theorems** (Section 5): Erasure operations incur both entropy cost (≥ log 2) and free energy cost (≥ 1 unit), establishing that irreversible computation requires nonzero thermodynamic resources in both the information-theoretic and circuit-complexity senses.

All results are formalized in Lean 4 with the Mathlib library, depending only on the standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

Bennett [6] established that reversible computation can be performed with zero energy dissipation, extending Landauer's framework. The connection between tropical algebra and statistical mechanics has been explored by Litvinov [7] and Maslov [8]. Allender [9] has studied connections between computational complexity and Kolmogorov complexity with thermodynamic motivations. Our contribution is to make these connections precise, compositional, and machine-verified.

---

## 2. Definitions and Notation

### 2.1 Tropical Entropy

**Definition 2.1** (Tropical Entropy). For n ∈ ℕ, the tropical entropy is

    Hₜ(n) = log(n)

using the natural logarithm, with the convention log(0) = 0 (following the Lean/Mathlib convention for Real.log).

**Proposition 2.1** (Monotonicity). For a ≤ b, Hₜ(a) ≤ Hₜ(b).

*Proof.* Case analysis: if a = 0, then Hₜ(0) = 0 ≤ Hₜ(b) (since log is nonneg on [1,∞) and 0 when b = 0). If a > 0, by monotonicity of log on positive reals.

### 2.2 Entropy Defect

**Definition 2.2** (Entropy Defect). For a function f: α → β between finite types, the entropy defect is

    Δ(f) = log|α| − log|range(f)|

**Proposition 2.2**. For any f: α → β between finite types, Δ(f) ≥ 0.

*Proof.* Since |range(f)| ≤ |α| (a finite map cannot have more outputs than inputs), log|range(f)| ≤ log|α| by monotonicity.

### 2.3 Tropical Circuit Model

**Definition 2.3** (Tropical Circuit). The type of tropical circuits is defined inductively:

```
TropicalCircuit ::=
  | input                           -- identity, zero cost
  | gate(C : TropicalCircuit)       -- one computational step
  | seq(A B : TropicalCircuit)      -- sequential composition
  | par(A B : TropicalCircuit)      -- parallel composition
```

**Definition 2.4** (Depth).
```
depth(input)  = 0
depth(gate C) = depth(C) + 1
depth(seq A B) = depth(A) + depth(B)
depth(par A B) = max(depth(A), depth(B))
```

**Definition 2.5** (Min-Plus Free Energy).
```
FE(input)  = 0
FE(gate C) = FE(C) + 1
FE(seq A B) = FE(A) + FE(B)
FE(par A B) = max(FE(A), FE(B))
```

### 2.4 Thermodynamic Cost

**Definition 2.6** (Landauer Cost). For Boltzmann constant k, temperature T, and map f: α → β:

    LC(k, T, f) = k · T · (log|α| − log|range(f)|)

**Definition 2.7** (Thermal Landauer Cost). For domain size n and range size r:

    TLC(k, T, n, r) = k · T · (log(n) − log(r))

---

## 3. The Tropical Landauer Theorem

### 3.1 Fiber-Counting Lemma

**Lemma 3.1** (Fiber-Counting Inequality). Let f: α → β be a function between finite types, and let m ≥ 1. If every y ∈ range(f) satisfies |{x ∈ α | f(x) = y}| ≥ m, then

    |range(f)| · m ≤ |α|

*Proof sketch.* The fibers {x | f(x) = y} for y ∈ range(f) are pairwise disjoint and their union is all of α. Therefore:

    |α| = Σ_{y ∈ range(f)} |{x | f(x) = y}| ≥ Σ_{y ∈ range(f)} m = |range(f)| · m

The formal proof uses Fintype.card and Finset summation. □

### 3.2 Main Theorem

**Theorem 3.1** (Tropical Landauer Principle — Uniform Fiber Version). Let f: α → β be a function between finite types with α nonempty. If m ≥ 2 and every fiber of f has cardinality ≥ m, then:

    log(m) ≤ log|α| − log|range(f)|

*Proof sketch.* From Lemma 3.1, |range(f)| · m ≤ |α|. Since α is nonempty, range(f) is nonempty, so |range(f)| ≥ 1 > 0. Since m ≥ 2 > 0, we can write:

    m ≤ |α| / |range(f)|

Taking logarithms (valid since both sides are positive):

    log(m) ≤ log(|α| / |range(f)|) = log|α| − log|range(f)|

The formal proof uses Real.log_div and le_div_iff₀ to convert the multiplicative inequality to a logarithmic one. □

**Corollary 3.1** (Binary Landauer Bound). If every fiber of f has size ≥ 2, then log 2 ≤ Δ(f).

*Proof.* Instantiate Theorem 3.1 with m = 2. □

### 3.3 Thermodynamic Normalization

**Theorem 3.2** (Thermal Landauer Cost Nonnegativity). For k ≥ 0, T ≥ 0, and r ≤ n:

    0 ≤ TLC(k, T, n, r)

*Proof.* Since r ≤ n, log(r) ≤ log(n) by monotonicity of log on nonneg reals. Hence log(n) − log(r) ≥ 0, and multiplication by k · T ≥ 0 preserves the inequality. □

**Theorem 3.3** (Thermal Binary Landauer Bound). Under the hypotheses of Corollary 3.1:

    k · T · log 2 ≤ LC(k, T, f)

*Proof.* Multiply the bound from Corollary 3.1 by k · T ≥ 0. □

---

## 4. Free Energy = Depth

### 4.1 Inductive Circuit Model

**Theorem 4.1** (Free Energy = Depth). For every tropical circuit C:

    FE(C) = depth(C)

*Proof.* By structural induction on C.

- **Base case** (input): FE(input) = 0 = depth(input). ✓
- **Gate case**: FE(gate C) = FE(C) + 1 = depth(C) + 1 = depth(gate C) by IH. ✓
- **Sequential case**: FE(seq A B) = FE(A) + FE(B) = depth(A) + depth(B) = depth(seq A B) by IH. ✓
- **Parallel case**: FE(par A B) = max(FE(A), FE(B)) = max(depth(A), depth(B)) = depth(par A B) by IH. ✓

The formal proof casts ℕ to ℝ using Nat.cast properties (Nat.cast_add, Nat.cast_max). □

**Corollary 4.1** (Free Energy Nonnegativity). FE(C) ≥ 0 for all C.

**Corollary 4.2** (Erasure Free Energy Bound). FE(gate C) ≥ 1 for all C.

**Corollary 4.3** (Depth Bound Transfer). If k ≤ depth(C), then k ≤ FE(C).

### 4.2 Layered Circuit Model

**Definition 4.1** (Layered Free Energy). For a circuit represented as a list of layers (each a list of gate operations):

```
LFE([]) = 0
LFE(L :: Cs) = (if L = [] then 0 else 1) + LFE(Cs)
```

**Theorem 4.2** (Layered Free Energy = Active Depth). If every layer in C is nonempty:

    LFE(C) = |C|     (the number of layers)

*Proof.* By induction on the list. Base case: LFE([]) = 0 = |[]|. Inductive step: LFE(L :: Cs) = 1 + LFE(Cs) = 1 + |Cs| = |L :: Cs|, using the hypothesis that L ≠ []. □

---

## 5. Bridge Theorems

### 5.1 Information-Theoretic Bridge

**Theorem 5.1** (Shannon = Tropical for Uniform Distributions). For a uniform distribution on n outcomes:

    H_Shannon(Uniform(n)) = Hₜ(n) = log(n)

This is a definitional equality: the Shannon entropy of the uniform distribution on n elements is Σᵢ (1/n) log(n) = log(n).

### 5.2 Thermodynamic Bridge

**Theorem 5.2** (Tropical Bridge). For a nonempty finite type α, a function f: α → β with all fibers of size ≥ 2, and any tropical circuit C:

    log 2 ≤ Δ(f)   and   1 ≤ FE(gate C)

Both the information erasure cost and the circuit free energy cost are simultaneously positive for irreversible computations.

**Theorem 5.3** (Circuit Thermal Cost Lower Bound). For k ≥ 0, T ≥ 0:

    k · T ≤ k · T · FE(gate C)

*Proof.* Since FE(gate C) ≥ 1, multiply both sides by k · T ≥ 0. □

### 5.3 Multi-Erasure Scaling

**Theorem 5.4** (Multi-Erasure Free Energy). For every n ∈ ℕ, there exists a circuit C with FE(C) = n.

*Proof.* By induction: C₀ = input (FE = 0), Cₙ₊₁ = gate(Cₙ) (FE = n + 1). □

---

## 6. Computational Experiments

### 6.1 Landauer Bound Verification

We computationally verify the Landauer bound for several families of functions:

| Function | Domain | Range | Min Fiber | Δ(f) | Bound log(m) | Satisfied? |
|----------|--------|-------|-----------|------|--------------|------------|
| f(x) = 0 (constant) | {0,1} | {0} | 2 | 0.6931 | 0.6931 | ✓ (tight) |
| f(x) = x mod 2 | {0,...,3} | {0,1} | 2 | 0.6931 | 0.6931 | ✓ (tight) |
| f(x) = x mod 3 | {0,...,8} | {0,1,2} | 3 | 1.0986 | 1.0986 | ✓ (tight) |
| Binary AND | {0,...,3} | {0,1} | 1 | 0.6931 | 0 | ✓ (non-uniform) |
| Full erasure | {0,...,1023} | {0} | 1024 | 6.9315 | 6.9315 | ✓ (tight) |

The bound is tight when all fibers have exactly the same size m, confirming that the uniform-fiber theorem gives the optimal constant.

### 6.2 Circuit Free Energy Verification

| Circuit | Depth | Free Energy | FE = Depth? |
|---------|-------|-------------|-------------|
| input | 0 | 0.0 | ✓ |
| gate(input) | 1 | 1.0 | ✓ |
| seq(gate, gate) | 2 | 2.0 | ✓ |
| par(gate, gate) | 1 | 1.0 | ✓ |
| gate³(input) | 3 | 3.0 | ✓ |
| seq(gate, par(gate, gate)) | 2 | 2.0 | ✓ |

### 6.3 Thermodynamic Cost at Physical Temperatures

| Operation | T = 300 K | T = 4 K | T = 15 mK |
|-----------|-----------|---------|-----------|
| 1-bit erase | 2.87 × 10⁻²¹ J | 3.83 × 10⁻²³ J | 1.43 × 10⁻²⁵ J |
| 10-bit erase | 2.87 × 10⁻²⁰ J | 3.83 × 10⁻²² J | 1.43 × 10⁻²⁴ J |
| 1 KB erase | 2.35 × 10⁻¹⁷ J | 3.13 × 10⁻¹⁹ J | 1.17 × 10⁻²¹ J |

---

## 7. Discussion

### 7.1 Significance

The framework establishes three key identities:

1. **Tropical entropy = max-entropy information**: Hₜ(n) = log(n) is the Shannon entropy of the uniform distribution, making tropical entropy the worst-case information measure.

2. **Free energy = circuit depth**: In the min-plus algebra, the compositional free energy of a circuit exactly equals its depth, making circuit complexity a thermodynamic invariant.

3. **Information erasure = thermodynamic cost**: The Landauer bound, in tropical form, is a counting inequality (|range| · m ≤ |domain|) that converts to a logarithmic inequality and then to a physical energy bound.

### 7.2 Limitations

The current framework has several limitations:

- **Unit-cost model**: The free energy = depth equality holds for unit-cost gates. Non-uniform gate costs would give free energy ≥ depth (lower bound) but not necessarily equality.
- **Static analysis**: The framework treats functions and circuits as static objects, not dynamic processes. A full thermodynamic treatment would require time-dependent analysis.
- **Classical only**: The framework addresses classical computation. Extension to quantum circuits requires additional structure (density matrices, von Neumann entropy).

### 7.3 Relation to Existing Work

The fiber-counting approach to Landauer's principle is, to our knowledge, new in the formal verification literature. The free-energy/depth correspondence is folklore in the tropical geometry community but has not previously been formalized or connected to Landauer's principle in a machine-verified framework.

---

## 8. Future Work

1. **Tropical mutual information**: Define I_t(f, g) for pairs of maps and prove a tropical data processing inequality.
2. **Reversibility characterization**: Prove Δ(f) = 0 iff f is injective (for nonempty finite domains).
3. **Weighted gate energies**: Generalize to non-uniform gate costs and prove lower bounds for specific Boolean functions.
4. **Categorical semantics**: Define a symmetric monoidal category of thermodynamic processes enriched over the tropical semiring.
5. **Entropy comparison theorems**: Prove H_Shannon ≤ H_tropical ≤ log(dim) for finite-dimensional systems.

---

## References

[1] R. Landauer, "Irreversibility and Heat Generation in the Computing Process," *IBM J. Res. Dev.*, vol. 5, no. 3, pp. 183–191, 1961.

[2] A. Bérut et al., "Experimental verification of Landauer's principle linking information and thermodynamics," *Nature*, vol. 483, pp. 187–189, 2012.

[3] K. Maruyama, F. Nori, and V. Vedral, "The physics of Maxwell's demon and information," *Rev. Mod. Phys.*, vol. 81, pp. 1–23, 2009.

[4] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[5] G. Mikhalkin, "Enumerative tropical algebraic geometry in ℝ²," *J. Amer. Math. Soc.*, vol. 18, pp. 313–377, 2005.

[6] C. H. Bennett, "Logical Reversibility of Computation," *IBM J. Res. Dev.*, vol. 17, no. 6, pp. 525–532, 1973.

[7] G. L. Litvinov, "The Maslov dequantization, idempotent and tropical mathematics," *J. Math. Sci.*, vol. 140, no. 3, pp. 349–386, 2007.

[8] V. P. Maslov, "On a new principle of superposition for optimization problems," *Russ. Math. Surv.*, vol. 42, no. 3, pp. 43–54, 1987.

[9] E. Allender, "The complexity of complexity," in *Computability and Complexity*, Springer, 2017, pp. 79–94.

---

## Appendix A: Complete Lean 4 Theorem Statements

The following theorems are formally verified in Lean 4 with Mathlib:

```lean
-- Tropical entropy monotonicity
theorem tropical_entropy_monotone {a b : ℕ} (h : a ≤ b) :
    tropicalEntropy a ≤ tropicalEntropy b

-- Fiber-counting inequality (combinatorial heart)
theorem card_range_mul_fiber_le
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (m : ℕ) (hm : 1 ≤ m)
    (hfiber : ∀ y ∈ Set.range f, m ≤ Fintype.card {x : α // f x = y}) :
    Fintype.card (Set.range f) * m ≤ Fintype.card α

-- Tropical Landauer principle
theorem tropical_landauer_uniform_fiber
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) (m : ℕ) (hm : 2 ≤ m)
    (hfiber : ∀ y ∈ Set.range f, m ≤ Fintype.card {x : α // f x = y}) :
    Real.log m ≤ Real.log (Fintype.card α) - Real.log (Fintype.card (Set.range f))

-- Free Energy = Depth
theorem TropicalCircuit.freeEnergy_eq_depth (C : TropicalCircuit) :
    C.freeEnergy = (C.depth : ℝ)

-- Layered model
theorem layeredFreeEnergy_eq_depth
    {α : Type*} (C : List (List α))
    (hactive : ∀ L ∈ C, L ≠ []) :
    layeredFreeEnergy C = C.length

-- Bridge theorem
theorem tropical_bridge
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) (C : TropicalCircuit)
    (hfiber : ∀ y ∈ Set.range f, 2 ≤ Fintype.card {x : α // f x = y}) :
    Real.log 2 ≤ entropyDefect f ∧ 1 ≤ (TropicalCircuit.gate C).freeEnergy
```

All proofs depend only on axioms: propext, Classical.choice, Quot.sound.
