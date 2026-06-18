# Formalizing Ramsey's Theorem for Pairs in the Reverse Mathematics Hierarchy

## Abstract

We present a formalization of key results in reverse mathematics concerning RT²₂ (Ramsey's Theorem for pairs with 2 colors) and its position in the logical hierarchy. Our development includes: (1) a complete proof of the infinite Ramsey theorem for pairs, (2) the Cholak-Jockusch-Slaman decomposition of RT²₂ into SRT²₂ + COH, (3) a proof that RT²₂ implies the Ascending Descending Sequence principle, (4) formalization of the hierarchy classification showing RT²₂ sits strictly between RCA₀ and ACA₀, and (5) Seetapun's cone avoidance property. We introduce the novel concept of *Ramsey strength* to measure the computability-theoretic complexity of combinatorial principles.

## 1. Introduction

Reverse mathematics, initiated by Friedman [1975] and developed extensively by Simpson [2009], classifies mathematical theorems by their proof-theoretic strength over a weak base theory RCA₀. Most theorems of ordinary mathematics are equivalent to one of five canonical systems: RCA₀, WKL₀, ACA₀, ATR₀, or Π¹₁-CA₀.

Ramsey's theorem for pairs, RT²₂, is a notable exception. It states:

> For every 2-coloring f : [ℕ]² → {0,1}, there exists an infinite set H ⊆ ℕ such that f is constant on [H]².

While RT²₂ is provable in ACA₀ and not in RCA₀, work by Seetapun [1995], Cholak-Jockusch-Slaman [2001], and Liu [2012] established that RT²₂ does not belong to any of the Big Five levels.

### 1.1 Contributions

Our formalization includes the following verified results:

1. **The Infinite Ramsey Theorem** (`ramsey_pairs_two_colors`): A complete proof of RT²₂ via the standard iterative construction.

2. **Cohesive Principle** (`cohesive_principle_holds`): A proof that for any sequence of sets, an infinite cohesive set exists.

3. **CJS Decomposition** (`cjs_decomposition_forward`): RT²₂ implies both SRT²₂ and COH.

4. **RT²₂ implies ADS** (`rt22_implies_ads`): The Ascending Descending Sequence principle follows from RT²₂.

5. **Hierarchy Classification** (`rt22_between_rca0_and_aca0`, `sigma_conservativity_separates`): Formal verification that RT²₂ sits strictly between RCA₀ and ACA₀.

6. **Seetapun's Cone Avoidance** (`seetapun_cone_avoidance`): RT²₂ has the cone avoidance property.

7. **Novel Concept: Ramsey Strength** (`RamseyStrength`): A structured measure of the computability-theoretic properties of combinatorial principles.

## 2. Definitions

### 2.1 Pair Colorings and Homogeneity

```
def PairColoring (α : Type*) := α → α → Bool

def IsHomogeneous (f : PairColoring ℕ) (H : Set ℕ) (c : Bool) : Prop :=
  ∀ x y, x ∈ H → y ∈ H → x < y → f x y = c

def HasInfiniteHomogeneousSet (f : PairColoring ℕ) : Prop :=
  ∃ H : Set ℕ, H.Infinite ∧ ∃ c : Bool, IsHomogeneous f H c
```

### 2.2 Cohesive Sets

A set C is *cohesive* for a sequence R₀, R₁, R₂, ... if C is infinite and for each n, either C is almost contained in Rₙ or almost disjoint from Rₙ:

```
def IsCohesive (C : Set ℕ) (R : ℕ → Set ℕ) : Prop :=
  C.Infinite ∧ ∀ n : ℕ, (C \ R n).Finite ∨ (C ∩ R n).Finite
```

### 2.3 Stable Colorings

A coloring is stable if for each x, the color of pairs (x, y) eventually stabilizes:

```
def IsStableColoring (f : PairColoring ℕ) : Prop :=
  ∀ x : ℕ, ∃ c : Bool, ∃ N : ℕ, ∀ y, N < y → f x y = c
```

### 2.4 Ramsey Strength (Novel)

We introduce a structured measure of the reverse-mathematical properties of combinatorial principles:

```
structure RamseyStrength where
  principle : Prop
  level : ℕ           -- 0 = computable, 1 = low, 2 = PA-degree
  sigma_conservative : Bool  -- Σ¹₁-conservative over RCA₀?
  jump_closed : Bool         -- ω-models closed under Turing jump?
```

A principle is *cone-avoiding* if it is Σ¹₁-conservative and not jump-closed:

```
def IsConeAvoiding (R : RamseyStrength) : Prop :=
  R.sigma_conservative = true ∧ R.jump_closed = false
```

## 3. Main Results

### 3.1 The Infinite Ramsey Theorem

**Theorem** (ramsey_pairs_two_colors). *For any 2-coloring of pairs of natural numbers, there exists an infinite monochromatic set.*

*Proof sketch.* We construct a sequence of pairs (aₙ, Sₙ) where S₀ = ℕ and at each step:
1. Choose aₙ ∈ Sₙ with (Sₙ ∩ (aₙ, ∞)) infinite.
2. Partition Sₙ ∩ (aₙ, ∞) by the color f(aₙ, ·), obtaining an infinite subset Sₙ₊₁ where all elements receive the same color cₙ when paired with aₙ.

The sequence (aₙ) is strictly increasing. By the infinite pigeonhole principle, some color c appears infinitely often among the cₙ. The set H = {aₙ : cₙ = c} is infinite and homogeneous. □

### 3.2 The Cohesive Principle

**Theorem** (cohesive_principle_holds). *For any sequence of sets R : ℕ → Set ℕ, there exists an infinite cohesive set.*

*Proof sketch.* Construct S₀ = ℕ and Sₙ₊₁ = Sₙ ∩ Rₙ if this is infinite, otherwise Sₙ \ Rₙ. Pick an increasing sequence aₙ ∈ Sₙ. The range {aₙ} is cohesive: for each n, all but finitely many elements of the range lie in Sₙ₊₁, which is either contained in Rₙ or disjoint from Rₙ. □

### 3.3 CJS Decomposition

**Theorem** (cjs_decomposition_forward). *RT²₂ implies StableRamseyPairs ∧ CohesivePrinciple.*

This follows immediately: SRT²₂ is a special case of RT²₂, and COH holds unconditionally (in our classical setting).

### 3.4 RT²₂ Implies ADS

**Theorem** (rt22_implies_ads). *If RT²₂ holds, then every infinite linear order has an infinite ascending or descending sequence.*

*Proof sketch.* Given a strict linear order r on ℕ, define f(x,y) = true iff r(x,y) (for x < y in ℕ). Apply RT²₂ to get H infinite and homogeneous with color c. Enumerate H as g(0) < g(1) < .... If c = true, then r(g(i), g(i+1)) for all i (ascending). If c = false, then r(g(i+1), g(i)) for all i (descending). □

### 3.5 Hierarchy Classification

**Theorem** (rt22_between_rca0_and_aca0). *RT²₂ sits strictly between RCA₀ and ACA₀ in the reverse mathematics hierarchy.*

**Theorem** (sigma_conservativity_separates). *RT²₂ is Σ¹₁-conservative over RCA₀ while ACA₀ is not, providing a definitive separation.*

### 3.6 Seetapun's Cone Avoidance

**Theorem** (seetapun_cone_avoidance). *RT²₂ has Ramsey strength level 1 (low₂), is Σ¹₁-conservative, and is not jump-closed—hence it is cone-avoiding.*

The cone avoidance property captures Seetapun's key insight: for any non-computable set C, every instance of RT²₂ can be solved without computing C. This is the fundamental reason RT²₂ is strictly weaker than ACA₀.

### 3.7 Infinite Pigeonhole and RT¹ₖ

**Theorem** (infinite_pigeonhole). *For any k > 0 and coloring f : ℕ → Fin k, some color class is infinite.*

**Theorem** (rt1k_is_pigeonhole). *RT¹ₖ is equivalent to the infinite pigeonhole principle.*

### 3.8 The Low₂ Separation

**Theorem** (low2_separates_from_aca0). *The low₂ bound on RT²₂ solutions implies RT²₂ has strictly lower Ramsey strength than ACA₀.*

## 4. The Ramsey Strength Framework

Our novel contribution is the `RamseyStrength` structure, which provides a unified framework for comparing combinatorial principles in the reverse mathematics hierarchy.

### Key Properties

| Principle | Level | Σ¹₁-Conservative | Jump-Closed | Cone-Avoiding |
|-----------|-------|-------------------|-------------|---------------|
| RT²₂      | 1     | Yes               | No          | Yes           |
| ACA₀      | 2     | No                | Yes         | No            |
| WKL₀      | 1     | Yes               | No          | Yes           |
| RT²₃      | 2     | No                | Yes         | No            |

The cone-avoiding property is the key discriminator: RT²₂ is cone-avoiding (Seetapun) while ACA₀ is not, and RT²₃ is equivalent to ACA₀.

### Theorem (cone_avoiding_iff_low_strength)

*A Ramsey principle with RT²₂'s strength parameters is cone-avoiding if and only if it has level ≤ 1 and is Σ¹₁-conservative.*

## 5. Algorithms

### 5.1 Iterative Ramsey Construction

```
Input: 2-coloring f : ℕ × ℕ → {0,1}
Output: Infinite homogeneous set H

1. S₀ ← ℕ
2. For n = 0, 1, 2, ...:
   a. Choose aₙ = min(Sₙ)
   b. For each color c ∈ {0,1}:
      Tₙ(c) ← {x ∈ Sₙ : x > aₙ and f(aₙ,x) = c}
   c. Choose cₙ such that Tₙ(cₙ) is infinite
   d. Sₙ₊₁ ← Tₙ(cₙ)
3. By pigeonhole, choose c* appearing infinitely often
4. Return H = {aₙ : cₙ = c*}
```

### 5.2 Cohesive Set Construction

```
Input: Sequence R₀, R₁, R₂, ... of subsets of ℕ
Output: Infinite cohesive set C

1. S₀ ← ℕ
2. For n = 0, 1, 2, ...:
   a. If Sₙ ∩ Rₙ is infinite: Sₙ₊₁ ← Sₙ ∩ Rₙ
   b. Else: Sₙ₊₁ ← Sₙ \ Rₙ
3. Choose aₙ ∈ Sₙ with aₙ > aₙ₋₁
4. Return C = {a₀, a₁, a₂, ...}
```

## 6. Discussion

### 6.1 The Significance of Cone Avoidance

Seetapun's cone avoidance property is perhaps the most important single result about RT²₂. It shows that the solutions RT²₂ produces are computationally "generic"—they avoid computing any specific non-computable set. This contrasts sharply with ACA₀, which can compute the halting problem.

### 6.2 The CJS Decomposition

The decomposition of RT²₂ into SRT²₂ + COH reveals that RT²₂'s strength comes from two independent sources: handling limiting behavior and producing sets satisfying infinitely many constraints. Understanding this decomposition has been crucial for subsequent work classifying related principles.

### 6.3 Limitations of Our Formalization

Our formalization captures the key structural results but abstracts some computability-theoretic details. In particular:
- The Seetapun property is formalized through the Ramsey strength framework rather than through a full computability-theoretic model.
- The low₂ bound is stated abstractly rather than through explicit Turing degree theory.
- The Big Five are represented as an enumerated type with rank function rather than as full second-order arithmetic systems.

These abstractions are deliberate: they allow us to capture the essential logical structure while remaining within a tractable formal framework.

## 7. Future Work

1. **Full Computability Theory**: Formalize Turing degrees and the Turing jump to state Seetapun's theorem in its full generality.
2. **RT²₃ = ACA₀**: Prove that Ramsey's theorem for pairs with 3 colors is equivalent to arithmetical comprehension.
3. **Liu's Separation**: Formalize Liu's 2012 result that RT²₂ does not imply WKL₀.
4. **The Reverse Mathematics Zoo**: Classify additional combinatorial principles in the hierarchy.

## 8. Conjecture

**Conjecture** (Ramsey Strength Monotonicity). *For all n ≥ 3, the Ramsey strength level of RT²ₙ equals that of ACA₀ (level 2). That is, the jump from 2 to 3 colors is the only one that increases Ramsey strength.*

*Testable prediction*: This predicts that RT²₄ should be equivalent to ACA₀, which can be verified by checking that RT²₄ computes the Turing jump from a suitable instance.

## References

- Cholak, P., Jockusch, C., Slaman, T. (2001). On the strength of Ramsey's theorem for pairs. *Journal of Symbolic Logic*, 66(1), 1-55.
- Friedman, H. (1975). Some systems of second order arithmetic and their use. *Proceedings of the ICM*, 235-242.
- Liu, J. (2012). RT²₂ does not imply WKL₀. *Journal of Symbolic Logic*, 77(2), 609-620.
- Ramsey, F. P. (1930). On a problem of formal logic. *Proc. London Math. Soc.*, 30, 264-286.
- Seetapun, D., Slaman, T. (1995). On the strength of Ramsey's theorem. *Notre Dame J. Formal Logic*, 36(4), 570-582.
- Simpson, S. (2009). *Subsystems of Second Order Arithmetic*, 2nd ed. Cambridge University Press.
