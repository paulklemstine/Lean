# Formalized Transseries: Growth Scales, Asymptotic Dominance, and EML Connections

## Abstract

We present a formalization of the theory of transseries growth levels and asymptotic dominance hierarchies in Lean 4 with Mathlib. We introduce the **Growth Scale**, a novel mathematical structure that organizes asymptotic growth rates into a totally ordered hierarchy indexed by *depth* (the number of nested exponentials) and *exponent* (the power within each depth level). We prove that this structure admits a strict linear order, that exponential and logarithmic shifts act as order-preserving automorphisms, and that the depth filtration provides a canonical decomposition. We establish key asymptotic dominance results: exp(x^α) dominates any polynomial, double exponentials dominate single exponentials, and exponential and polynomial growth are never asymptotically equivalent. We connect this framework to the EML (exp-minus-log) operation, showing that EML naturally raises the growth level and that polynomial-level EML inputs produce exponential-level outputs. All results are machine-verified in Lean 4.

## 1. Introduction

### 1.1 Motivation

Transseries, introduced by Écalle [1] and further developed by van den Dries, Macintyre, and Marker [2], extend formal power series by incorporating iterated exponentials and logarithms. They provide a complete framework for describing the asymptotic behavior of solutions to differential equations, generating functions in combinatorics, and perturbative expansions in physics.

The full theory of transseries is formidably complex, involving well-ordered support sets, generalized power series, and intricate algebraic constructions. Our approach focuses on a foundational piece: the **growth level hierarchy**, which organizes the basic building blocks (transmonomials) of transseries into a totally ordered structure.

### 1.2 Contributions

1. **Novel structure: The Growth Scale.** We define `GrowthLevel` as a pair (depth, exponent) ∈ ℤ × ℝ with lexicographic ordering, and `GrowthScale` as a nonempty subset of growth levels. This captures the complete hierarchy of asymptotic rates.

2. **Total order theorem.** We prove that growth levels form a strict linear order (trichotomy, irreflexivity, transitivity).

3. **Exp-log duality.** We prove that the exponential shift `g ↦ (g.depth + 1, g.exponent)` and logarithmic shift `g ↦ (g.depth - 1, g.exponent)` are inverse order-preserving maps, forming a ℤ-action on the growth scale.

4. **Asymptotic dominance results.** We prove:
   - exp(x) dominates x^n for any n (polynomial level < exponential level)
   - x^α dominates (log x)^β (logarithmic level < polynomial level)
   - exp(exp(x)) dominates exp(x^α) (depth 2 > depth 1)
   - exp(x^α) dominates x^n (general exp-vs-poly)
   - exp(x) and x^n are never asymptotically equivalent

5. **EML connection.** We define an EML growth operation and prove it always raises the growth level, with polynomial inputs producing exponential outputs.

6. **Depth filtration.** We prove the growth levels decompose into depth-indexed layers, each order-isomorphic to ℝ.

### 1.3 Related Work

The theory of transseries has been extensively studied in the context of Hardy fields [3], surreal numbers [4], and differential algebra [5]. Our formalization focuses on the foundational ordering structure rather than the full algebraic theory. To our knowledge, this is the first machine-verified formalization of the transseries growth hierarchy and its asymptotic dominance properties.

## 2. Definitions

### 2.1 Growth Levels

**Definition 1** (Growth Level). A *growth level* is a pair g = (d, α) where d ∈ ℤ is the *depth* and α ∈ ℝ is the *exponent*. Intuitively:
- d = 0, α = n: the transmonomial x^n (polynomial growth)
- d = 1, α = 1: the transmonomial e^x (single exponential)
- d = 2, α = 1: the transmonomial e^{e^x} (double exponential)
- d = -1, α = 1: the transmonomial log(x) (logarithmic)
- d = k, α: the transmonomial exp^{(k)}(x^α) for k > 0, log^{(-k)}(x^α) for k < 0

**Definition 2** (Lexicographic Order). For growth levels a = (d_a, α_a) and b = (d_b, α_b), we define a < b iff d_a < d_b, or d_a = d_b and α_a < α_b. This corresponds to asymptotic dominance: higher depth means fundamentally faster growth.

**Definition 3** (Exponential Shift). The exponential shift exp↑ maps (d, α) to (d+1, α), corresponding to applying one more layer of exponentiation.

**Definition 4** (Logarithmic Shift). The logarithmic shift log↓ maps (d, α) to (d-1, α), corresponding to applying one logarithm.

### 2.2 Transmonomials

**Definition 5** (Transmonomial). A *transmonomial* is a triple (level, eval, eval_pos) where level is a growth level, eval : ℝ → ℝ is the evaluation function, and eval_pos certifies that eval(x) > 0 for all x > 1.

We construct concrete transmonomials:
- polyMonomial(α) with level (0, α) and eval(x) = x^α
- expMonomial(α) with level (1, α) and eval(x) = exp(x^α)  
- logMonomial(α) with level (-1, α) and eval(x) = (log x)^α

### 2.3 Asymptotic Relations

**Definition 6** (Asymptotic Dominance). f asymptotically dominates g, written f ≫ g, if f(x)/g(x) → ∞ as x → ∞.

**Definition 7** (Asymptotic Equivalence). f is asymptotically equivalent to g, written f ~ g, if f(x)/g(x) → 1 as x → ∞.

### 2.4 Growth Scales

**Definition 8** (Growth Scale). A *growth scale* is a nonempty set of growth levels. Key examples:
- polyScale: all levels with depth 0 (polynomial growth rates)
- expScale: all levels with depth ≥ 0 (polynomial and exponential)
- fullScale: all growth levels (the complete transseries hierarchy)

### 2.5 EML Growth Operation

**Definition 9** (EML Growth Operation). For growth levels g₁, g₂, the EML growth operation combines exp↑(g₁) and log↓(g₂), selecting the dominant one (by depth, then by exponent).

## 3. Main Results

### 3.1 Total Order on Growth Levels

**Theorem 1** (Trichotomy). For any growth levels a, b: exactly one of a < b, a = b, or b < a holds.

*Proof sketch.* By trichotomy on ℤ for depths. If depths are equal, by trichotomy on ℝ for exponents. □

**Theorem 2** (Transitivity). The growth level ordering is transitive.

**Theorem 3** (Irreflexivity). No growth level is strictly less than itself.

**Theorem 4** (Antisymmetry). If ¬(b < a) and ¬(a < b), then a = b.

These four theorems establish that growth levels form a strict linear order.

### 3.2 Exp-Log Duality

**Theorem 5** (Exp-Log Cancellation). For any growth level g: exp↑(log↓(g)) = g and log↓(exp↑(g)) = g.

**Theorem 6** (Order Preservation). Both exp↑ and log↓ are strictly order-preserving: if a < b, then exp↑(a) < exp↑(b) and log↓(a) < log↓(b).

**Theorem 7** (Iterated Shift). The iterated exponential shift g ↦ (d + n, α) is a ℤ-action: shift by 0 is identity, and shift by m then n equals shift by m + n.

**Theorem 8** (Composition). Double exponential shift increases depth by 2: exp↑(exp↑(g)) = (d + 2, α).

### 3.3 Asymptotic Dominance Hierarchy

**Theorem 9** (Exp Dominates Poly). For any n ∈ ℕ: exp(x)/x^n → ∞ as x → ∞.

*Proof.* Direct application of `Real.tendsto_exp_div_pow_atTop`. □

**Theorem 10** (Poly Dominates Log). For any α, β > 0: x^α/(log x)^β → ∞ as x → ∞.

*Proof.* Substitute y = log x, reducing to exp(αy)/y^β → ∞, which follows from Theorem 9. □

**Theorem 11** (Double Exp Dominates Single). For any α > 0: exp(exp(x))/exp(x^α) → ∞.

*Proof.* The ratio equals exp(exp(x) - x^α). Since exp(x) - x^α → ∞ (exponential dominates polynomial), the result follows. □

**Theorem 12** (General Exp vs Poly). For any α > 0 and n ∈ ℕ: exp(x^α)/x^n → ∞.

*Proof.* Substitute y = x^α, then exp(y)/y^{n/α} → ∞ by the dominance of exponentials over powers. □

**Theorem 13** (Non-Equivalence). For n ≥ 1: exp(x) and x^n are never asymptotically equivalent.

*Proof.* If they were equivalent, exp(x)/x^n → 1 ∈ nhds(1). But by Theorem 9, exp(x)/x^n → ∞. Since atTop and nhds(1) are disjoint neighborhoods, this is a contradiction. □

### 3.4 Asymptotic Properties of Relations

**Theorem 14** (Transitivity of Dominance). Asymptotic dominance is transitive: if f ≫ g and g ≫ h (with g, h eventually positive), then f ≫ h.

*Proof.* f/h = (f/g)·(g/h), and the product of two quantities tending to ∞ tends to ∞. □

**Theorem 15** (Reflexivity of Equivalence). f ~ f whenever f is eventually nonzero.

**Theorem 16** (Symmetry of Equivalence). If f ~ g (with g eventually nonzero), then g ~ f.

### 3.5 EML Connection

**Theorem 17** (EML Raises Level). For any growth levels g₁, g₂: g₁.depth ≤ emlGrowthOp(g₁, g₂).depth.

*Proof.* In all branches of the EML operation, the result has depth at least g₁.depth + 1 (the exp-shifted depth) or g₂.depth - 1 (the log-shifted depth, which is ≥ g₁.depth + 1 in the branches where it's selected). □

**Theorem 18** (Poly-to-Exp). For polynomial-level inputs (depth 0): emlGrowthOp((0, α), (0, β)).depth = 1.

*Proof.* The exp shift of (0, α) has depth 1, while the log shift of (0, β) has depth -1. Since 1 > -1, the first branch is taken. □

### 3.6 Depth Filtration

**Theorem 19** (Filtration Decomposition). Within each depth level d, the ordering reduces to the natural ordering on exponents: for a, b with depth d, a < b iff α_a < α_b.

**Theorem 20** (Shift Maps Filtration). exp↑ maps the depth-d layer bijectively to the depth-(d+1) layer.

**Theorem 21** (Exhaustivity). Every growth level belongs to exactly one depth layer.

### 3.7 Scale Hierarchy

**Theorem 22** (Scale Containment). polyScale ⊆ expScale ⊆ fullScale, with strict containment.

**Theorem 23** (Exp Not Polynomial). The growth level (1, 1) (representing e^x) is not in polyScale.

## 4. The PEGB Framework

### Theorem 13 (Exp-Poly Non-Equivalence) — PEGB Analysis

**Proof**: Complete formal proof via contradiction between Filter.Tendsto to atTop (from dominance) and Filter.Tendsto to nhds 1 (from equivalence assumption).

**Example**: exp(x)/x² at x = 10: e^{10}/100 ≈ 220.26. At x = 100: e^{100}/10000 ≈ 2.69 × 10^{39}. The ratio explodes, confirming non-equivalence.

**Generalization**: For any f with AsympDominates f g and any c ≠ 0, ¬AsympEquiv f g. The argument generalizes: asymptotic dominance and asymptotic equivalence are mutually exclusive (when both are defined).

**Boundary**: For n = 0, x^0 = 1, and exp(x)/1 → ∞, so exp and constants are also non-equivalent. The boundary case n = 0 was excluded from our statement (hn : 1 ≤ n) but the result holds trivially by dominance.

### Theorem 11 (Double Exp Dominates Single) — PEGB Analysis

**Proof**: Reduction to Theorem 9 via exp(exp(x) - x^α) and the dominance of exp over polynomials.

**Example**: At x = 5: exp(exp(5)) / exp(5^1) ≈ exp(148.41) / exp(5) = exp(143.41) ≈ 10^{62}.

**Generalization**: For any k ≥ 1, exp^{(k+1)}(x) dominates exp^{(k)}(x^α). This follows by induction on k.

**Boundary**: When α = 0, exp(x^0) = exp(1) = e, a constant, so exp(exp(x))/e → ∞ trivially. Our theorem requires α > 0.

### Theorem 18 (EML Poly-to-Exp) — PEGB Analysis

**Proof**: Direct computation: exp shift has depth 1, log shift has depth -1, branch selects exp shift.

**Example**: emlGrowthOp((0, 2), (0, 3)) = (1, 2). The EML of x² and x³ has growth level exp(x²), dominated by the exponential part.

**Generalization**: For inputs at depth d, emlGrowthOp produces output at depth at least d + 1. The exponential always dominates the logarithm.

**Boundary**: If g₁ is at very negative depth (deep logarithmic), the log shift of g₂ might dominate. But even then, the result depth ≥ g₁.depth, so the level never decreases.

## 5. Conjecture

**Conjecture** (Depth Gap Conjecture). For any growth level g = (d, α) with d ≥ 1 and α > 0, and any N ∈ ℕ, there exists x₀ such that for all x > x₀:

  eval_g(x) > eval_{(d-1, N)}(x)

where eval_g is the canonical evaluation of the transmonomial at level g. In other words, the asymptotic gap between adjacent depth levels is unbounded—a single exponential layer creates a gap that no finite power can bridge.

**Computational Test**: Evaluate exp(x^α) / x^N for various α, N, and large x. If the ratio ever stabilizes or decreases for all α > 0 and some fixed N, the conjecture is false.

## 6. Discussion

### 6.1 Significance

Our formalization captures the essential ordering structure of transseries in a machine-verified framework. The key insight is that the growth level hierarchy—a simple lexicographic order on ℤ × ℝ—encodes the full asymptotic dominance structure, with exponential and logarithmic shifts acting as order-preserving automorphisms.

### 6.2 Connection to Hardy Fields

The growth levels can be seen as a discrete invariant of elements of a Hardy field. In a Hardy field, every element has a well-defined growth rate, and our depth parameter corresponds to the "exponential height" of the element—the number of times one must take logarithms to reduce to polynomial growth.

### 6.3 EML as Growth Level Operator

The connection to EML operations reveals that the exp-minus-log construction is fundamentally a *depth-increasing* operation. This has implications for the expressiveness of EML-based function approximation: each application of EML can access one additional level of the growth hierarchy.

### 6.4 Limitations

Our formalization focuses on the ordering structure and does not yet include the full algebraic theory (field operations on transseries) or the connection to differential algebra. The Transmonomial structure bundles a growth level with an arbitrary evaluation function, and the asymptotic dominance results are proved for specific constructions rather than abstractly for all transmonomials at a given level.

## 7. Future Work

1. Formalize the field operations (addition and multiplication) on transseries, making the ring structure explicit.
2. Prove that the transseries field is real-closed.
3. Extend the growth scale to include transfinite depths (ω-exponentials).
4. Formalize the connection to resurgence and Borel summation.
5. Prove the asymptotic uniqueness theorem in full generality.

## References

[1] J. Écalle, *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*, Hermann, 1992.

[2] L. van den Dries, A. Macintyre, D. Marker, "Logarithmic-exponential power series," *J. London Math. Soc.*, 56(3):417–434, 1997.

[3] M. Boshernitzan, "Hardy fields and existence of transexponential functions," *Aequationes Math.*, 30:258–280, 1986.

[4] H. Gonshor, *An Introduction to the Theory of Surreal Numbers*, Cambridge University Press, 1986.

[5] M. Aschenbrenner, L. van den Dries, J. van der Hoeven, *Asymptotic Differential Algebra and Model Theory of Transseries*, Princeton University Press, 2017.
