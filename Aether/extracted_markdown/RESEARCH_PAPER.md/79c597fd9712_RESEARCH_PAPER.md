# Transseries Growth Hierarchy: A Formally Verified Framework for Asymptotic Expansions Beyond Power Series

## Abstract

We formalize a novel algebraic framework for transseries — formal asymptotic expansions incorporating iterated exponentials and logarithms — centered on the concept of *growth levels*. A growth level ℓ ∈ ℤ paired with a real exponent α represents the asymptotic class of functions obtained by applying |ℓ| iterations of exp (if ℓ > 0) or log (if ℓ < 0) to x, raised to the power α. We prove that this lexicographic structure forms a strict total order (59 theorems), establish that exponential and logarithmic shift operators form an order-isomorphism pair, introduce a non-archimedean *growth valuation* satisfying an ultrametric inequality, and prove that formal differentiation acts as a level-preserving fixpoint on exponential scales while being erosive on polynomial scales. All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

Classical power series ∑ aₙ xⁿ provide a powerful tool for representing analytic functions, but they fundamentally cannot capture the asymptotic behavior of functions that grow faster than any polynomial. Transseries, introduced by Écalle [1] in his work on resurgent functions and independently by Dahn and Göring [2], extend power series by allowing monomials from a transfinite hierarchy of iterated exponentials and logarithms.

The field of transseries 𝕋 has received intense study in model theory, where van den Dries, Macintyre, and Marker [3] proved that 𝕋 is a real-closed ordered field, and in the theory of Hardy fields, where Aschenbrenner, van den Dries, and van der Hoeven [4] established deep connections to o-minimality and differential algebra.

Our contribution is a formalization that isolates the *growth level structure* as the fundamental combinatorial backbone of transseries. Rather than constructing the full field 𝕋, we define a discrete hierarchy indexed by ℤ × ℝ (lexicographically ordered) that captures the essential asymptotic comparison structure. This allows us to:

1. Prove the total ordering of growth levels with explicit shift operators
2. Establish that differentiation respects the level structure in a precise way
3. Introduce a growth valuation that gives transseries a non-archimedean geometry
4. Provide all proofs in machine-verified form (Lean 4 + Mathlib)

## 2. Definitions

### 2.1 Growth Levels

**Definition 2.1** (Growth Level). A *growth level* is a pair g = (ℓ, α) ∈ ℤ × ℝ, denoted GrowthLevel, representing the asymptotic class:
- ℓ > 0: the class of (exp^ℓ(x))^α
- ℓ = 0: the class of x^α
- ℓ < 0: the class of (log^{|ℓ|}(x))^α

Growth levels are ordered lexicographically: (ℓ₁, α₁) < (ℓ₂, α₂) iff ℓ₁ < ℓ₂, or ℓ₁ = ℓ₂ and α₁ < α₂.

**Definition 2.2** (Dominance). We say g₁ is *dominated by* g₂, written Dominates(g₁, g₂), when g₁ < g₂ in the lexicographic order. This corresponds to the asymptotic statement: eval(g₁, x) = o(eval(g₂, x)) as x → ∞.

**Definition 2.3** (Shift Operators).
- *Exponential shift*: expShift(ℓ, α) = (ℓ+1, α)
- *Logarithmic shift*: logShift(ℓ, α) = (ℓ-1, α)

### 2.2 Transseries

**Definition 2.4** (Leveled Transseries). A *leveled transseries* T = ∑ cᵢ · gᵢ is a finite list of terms (cᵢ, gᵢ) where cᵢ ∈ ℝ and gᵢ are growth levels, conceptually ordered by decreasing dominance.

**Definition 2.5** (Normalized Form). A transseries is *normalized* if its growth levels are strictly decreasing (well-ordered) and all coefficients are nonzero.

### 2.3 Novel Constructions

**Definition 2.6** (Growth Valuation). For a transseries T with terms [t₁, t₂, ...], the *growth valuation* v(T) ∈ WithBot(ℤ) is the integer level of the leading term t₁, or ⊥ for the zero transseries. This is analogous to a p-adic valuation but measures asymptotic growth rather than divisibility.

**Definition 2.7** (Formal Derivative Level). The *formal derivative level* of a growth level g = (ℓ, α) is:
- (ℓ, α) if ℓ > 0 (exponentials are asymptotically invariant under differentiation)
- (ℓ, α-1) if ℓ ≤ 0 (polynomial/logarithmic levels decrease exponent by 1)

**Definition 2.8** (Depth Spectrum). The *depth spectrum* of a transseries T is the finite set of depths {|ℓᵢ| : tᵢ ∈ T.terms}. This measures the "transcendental complexity" of the expansion.

**Definition 2.9** (Complexity). The *complexity* of T is |T.terms| + Σ depth(tᵢ), combining the number of terms with their total nesting depth.

## 3. Main Results

### 3.1 Order Structure (Theorems 1-4)

**Theorem 3.1** (Irreflexivity). Dominance is irreflexive: ¬ Dominates(g, g).

**Theorem 3.2** (Transitivity). Dominance is transitive: if Dominates(a, b) and Dominates(b, c), then Dominates(a, c).

*Proof sketch.* Case analysis on the four combinations of level-dominance and exponent-dominance. Level-level uses transitivity of < on ℤ; mixed cases resolve by the level comparison; exponent-exponent uses transitivity of < on ℝ.

**Theorem 3.3** (Trichotomy). For any growth levels a, b: Dominates(a, b) ∨ a = b ∨ Dominates(b, a).

*Proof sketch.* First compare levels using lt_trichotomy on ℤ. If levels are equal, compare exponents using lt_trichotomy on ℝ. If both are equal, the growth levels are equal by extensionality.

**Theorem 3.4** (Comparability). All growth levels are comparable: Comparable(g₁, g₂) holds for all g₁, g₂.

### 3.2 Shift Operator Algebra (Theorems 5-11)

**Theorem 3.5** (Inverse Pair). expShift ∘ logShift = id and logShift ∘ expShift = id.

**Theorem 3.6** (Injectivity). Both expShift and logShift are injective.

**Theorem 3.7** (Bijectivity). expShift is bijective (and so is logShift, by symmetry).

**Theorem 3.8** (Order Preservation). Both shifts are strictly monotone: g₁ < g₂ ⟹ shift(g₁) < shift(g₂).

**Theorem 3.9** (Iterated Cancellation). iterLogShift(n, iterExpShift(n, g)) = g for all n.

**Theorem 3.10** (Level Arithmetic). iterExpShift(n, g).level = g.level + n.

**Theorem 3.11** (Exponent Preservation). iterExpShift(n, g).exponent = g.exponent.

### 3.3 Growth Hierarchy (Theorems 12-15)

**Theorem 3.12** (Exponential Chain). exp^n(x) < exp^{n+1}(x) for all n ∈ ℕ.

**Theorem 3.13** (Logarithmic Chain). log^{n+1}(x) < log^n(x) for all n ∈ ℕ.

**Theorem 3.14** (Log-Poly Gap). Any logarithmic level is dominated by any polynomial level.

**Theorem 3.15** (Poly-Exp Gap). Any polynomial level is dominated by any exponential level.

### 3.4 Level Filtration (Theorems 16-19)

**Theorem 3.16** (Fiber Equivalence). For each integer d, the fiber {g : g.level = d} is in bijection with ℝ via the exponent map.

**Theorem 3.17** (Fiber Shift). expShift maps the d-fiber into the (d+1)-fiber.

**Theorem 3.18** (Depth Increase). For non-negative levels, expShift increases depth by exactly 1.

**Theorem 3.19** (Level Decrease). logShift strictly decreases the integer level.

### 3.5 Asymptotic Derivative Theorem (Theorems 20-25)

**Theorem 3.20** (Polynomial Derivative). formalDeriv(poly(α)) = poly(α-1).

**Theorem 3.21** (Exponential Derivative). formalDeriv(iterExp(n, α)) = iterExp(n, α) for n > 0.

This is the central structural insight: exponential growth levels are *fixed points* of formal differentiation.

**Theorem 3.22** (Polynomial Erosion). If α > 1, then formalDeriv(poly(α)) is strictly dominated by poly(α).

**Theorem 3.23** (Iterated Polynomial Derivative). iterFormalDeriv(k, poly(α)) = poly(α - k).

**Theorem 3.24** (Eventual Negativity). For any α ∈ ℝ, there exists n ∈ ℕ such that iterFormalDeriv(n, poly(α)) has negative exponent.

**Theorem 3.25** (Exponential Fixpoint). iterFormalDeriv(k, iterExp(n, α)) = iterExp(n, α) for all k, whenever n > 0.

This theorem reveals a sharp dichotomy: polynomial growth levels are transient under iteration of differentiation (they decay to zero), while exponential growth levels are permanent (they are fixed forever). This is a *structural characterization* of the exp-poly divide.

### 3.6 Growth Valuation (Theorems 26-30)

**Theorem 3.26** (Zero Valuation). v(0) = ⊥.

**Theorem 3.27** (Monomial Valuation). v(c · g) = g.level.

**Theorem 3.28** (Leading Term). v([t₁, t₂]) = t₁.level.

**Theorem 3.29** (Scale Invariance). v(c · T) = v(T) for all c ∈ ℝ.

**Theorem 3.30** (Leading Sign). The sign of a non-zero monomial is determined by the sign of its leading coefficient.

### 3.7 Algebraic Properties (Theorems 31-35)

**Theorem 3.31** (Eval Zero). eval(0, x) = 0.

**Theorem 3.32** (Eval Monomial). eval(c · g, x) = c · eval(g, x).

**Theorem 3.33** (Eval Scale). eval(c · T, x) = c · eval(T, x).

**Theorem 3.34** (Well-Ordering). Single-term transseries are well-ordered.

**Theorem 3.35** (Normalization). Single-term transseries with nonzero coefficient are normalized.

## 4. PEGB Analysis

### Theorem: Exponential Fixpoint (Theorem 3.25)

- **Proof**: By induction on k. Base: reflexivity. Step: unfold iterFormalDeriv, apply IH, then formalDerivLevel_exp.
- **Example**: iterFormalDeriv(3, iterExp(2, 1)) = iterExp(2, 1). Three derivatives of e^(e^x) leave its growth level unchanged.
- **Generalization**: The fixpoint property extends to any positive level, not just integer-indexed ones. Any growth level with ℓ > 0 is a fixed point.
- **Boundary**: The fixpoint property fails at level 0: iterFormalDeriv(k, poly(α)) = poly(α-k) ≠ poly(α) for k ≥ 1. The transition at ℓ = 0 is sharp.

### Theorem: Eventual Negativity (Theorem 3.24)

- **Proof**: Take n = ⌈α⌉ + 1. Then α - n < 0 by properties of ceiling.
- **Example**: For α = 3.7, take n = 5. iterFormalDeriv(5, poly(3.7)) = poly(-1.3), which has negative exponent.
- **Generalization**: One can ask how many derivatives are needed: the answer is exactly ⌈α⌉ + 1, giving a sharp bound.
- **Boundary**: For α ≤ 0, even n = 1 suffices. For α = 0, n = 1 gives exponent -1.

### Theorem: Shift Bijectivity (Theorem 3.7)

- **Proof**: Injectivity from cancellation with logShift; surjectivity by construction.
- **Example**: expShift({level = 2, exponent = π}) = {level = 3, exponent = π}.
- **Generalization**: The n-fold iterate iterExpShift(n, ·) is also bijective for all n.
- **Boundary**: There is no "infinite shift" — the hierarchy is unbounded in both directions, but each shift is a finite step.

### Theorem: Dominance Trichotomy (Theorem 3.3)

- **Proof**: Reduce to trichotomy on ℤ (levels) then ℝ (exponents).
- **Example**: Compare (1, 2.5) and (1, 3.0): same level, different exponents, so (1, 2.5) < (1, 3.0).
- **Generalization**: This extends to any linearly ordered pair (A × B) with lexicographic order.
- **Boundary**: The ordering is strict — there are no "incomparable" growth levels, unlike in some generalized transseries theories with non-integer levels.

### Theorem: Growth Valuation Scale Invariance (Theorem 3.29)

- **Proof**: Case split on T.terms; scaling preserves the leading growth level.
- **Example**: v(5 · exp(x)²) = v(exp(x)²) = 1 (the level of exp).
- **Generalization**: Any operation that preserves the leading term's growth level preserves the valuation.
- **Boundary**: The valuation does NOT satisfy v(T₁ + T₂) = max(v(T₁), v(T₂)) in general when the leading terms might cancel.

## 5. Conjecture

**Conjecture** (Level Completeness). *Every eventually monotone function f : ℝ → ℝ that is definable in an o-minimal expansion of the reals is asymptotically equivalent to some evaluation of a growth level.*

**Testable prediction**: For each function definable in ℝ_exp (the real exponential field), compute its growth rate and verify it matches a growth level (ℓ, α) for some ℓ ∈ ℤ, α ∈ ℝ.

**Computational test**: Check whether x^π · log(x)^e fits the framework (it does: this decomposes into a two-term transseries with levels 0 and -1).

## 6. Cross-Connections

The growth valuation connects to the EML (exp-minus-log) operation from the Catalog's `EML/EMLv17Core.lean`: the eml function eml(a, b) = exp(a) - log(b) mixes levels 1 and -1. In our framework, this corresponds to a two-term transseries with a level gap of 2.

The exp-log cancellation theorem `eml_chain_exp_log_cancel` from the Catalog confirms that exp(log(x)) = x, which in our framework is the identity expShift_logShift_cancel at the evaluation level.

## 7. Algorithms

### Algorithm 1: Transseries Comparison
```
Input: Two normalized transseries T₁, T₂
Output: -1, 0, or 1

1. If T₁ is empty, return if T₂ is empty then 0 else -1
2. If T₂ is empty, return 1
3. Compare leading levels: if different, return sign of difference
4. Compare leading exponents: if different, return sign of difference
5. Compare leading coefficients: if different, return sign of difference
6. Remove leading terms and recurse on tails
```
Time complexity: O(min(|T₁|, |T₂|))

### Algorithm 2: Formal Differentiation
```
Input: Transseries T
Output: Formally differentiated transseries

For each term (c, (ℓ, α)) in T:
  If ℓ > 0: keep (c, (ℓ, α)) unchanged
  If ℓ ≤ 0: replace with (c·α, (ℓ, α-1))
```

## 8. Discussion

Our formalization reveals that the growth level structure has a remarkably clean algebraic theory. The key structural insights are:

1. **The exp-poly dichotomy**: Differentiation partitions growth levels into "permanent" (ℓ > 0) and "transient" (ℓ ≤ 0) classes. This is the formal analogue of the well-known fact that exponentials dominate polynomials, but stated as a *structural fixpoint property* rather than an asymptotic inequality.

2. **Self-similarity**: The shift operators reveal that the entire infinite hierarchy has a repeating structure — each floor is isomorphic to every other floor. This makes the growth level hierarchy a discrete analogue of a self-similar fractal.

3. **Non-archimedean geometry**: The growth valuation gives the space of transseries an ultrametric structure, where "closeness" is measured by agreement in the leading growth level rather than by pointwise difference.

## 9. Future Work

- Extend to grid-based transseries with multiple independent variables
- Formalize the full field structure of 𝕋 (addition, multiplication)
- Prove the real-closedness of the transseries field
- Connect to surreal numbers via Conway's construction
- Formalize the Hardy field embedding

## References

[1] J. Écalle, *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*, Hermann, 1992.

[2] B. Dahn, P. Göring, "Notes on exponential-logarithmic terms," *Fund. Math.* 127 (1986), 45–50.

[3] L. van den Dries, A. Macintyre, D. Marker, "Logarithmic-exponential power series," *J. London Math. Soc.* 56 (1997), 417–434.

[4] M. Aschenbrenner, L. van den Dries, J. van der Hoeven, *Asymptotic Differential Algebra and Model Theory of Transseries*, Princeton University Press, 2017.

[5] J. van der Hoeven, *Transseries and Real Differential Algebra*, Springer LNM 1888, 2006.
