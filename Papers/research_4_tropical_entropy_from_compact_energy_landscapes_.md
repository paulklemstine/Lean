# Compact Tropical Entropy: Topological Foundations for Zero-Temperature Information Theory

## Abstract

We develop a rigorous theory of tropical partition functions on compact topological spaces, replacing the finite minima of combinatorial tropical mathematics with order-theoretic infima governed by compactness and lower semicontinuity. We define the tropical partition function as the infimum of the range of an energy function on a compact space, prove that it is attained for lower semicontinuous energies (via the topological extreme value theorem), and establish a complete package of structural laws: translation invariance, monotonicity, surjective pullback invariance, and a tropical data processing inequality. All results are machine-verified, constituting the first formalization of topological tropical information theory. The framework provides a rigorous mathematical foundation for zero-temperature statistical mechanics, idempotent analysis, and optimization on compact state spaces.

## 1. Introduction

### 1.1 Motivation

Tropical mathematics—the algebra obtained by replacing addition with minimum and multiplication with addition—has emerged as a fundamental tool across combinatorics, algebraic geometry, optimization, and theoretical computer science. In the tropical semiring (ℝ ∪ {+∞}, min, +), the tropical partition function of a finite set S with energy function E : S → ℝ is simply min_{x ∈ S} E(x), the minimum energy.

This finite tropical partition function satisfies elegant structural properties: translation invariance (shifting all energies shifts the partition function), monotonicity (lower energies yield lower partition functions), and a data processing inequality (coarse-graining cannot improve the minimum). These properties mirror, in the zero-temperature limit, the corresponding properties of the classical statistical mechanical partition function Z = Σ_x exp(-βE(x)).

A natural question arises: do these structural properties survive the passage from finite sets to infinite topological spaces? This is not merely a routine generalization. The infimum of a function on an arbitrary set may not be attained, the order-theoretic sInf may not behave well without boundedness assumptions, and the relationship between topological structure and extremal properties requires careful treatment.

### 1.2 Contributions

We resolve this question affirmatively for compact topological spaces with lower semicontinuous energy functions. Our contributions are:

1. **Definition** of the compact tropical partition function Z_trop(X, E) = sInf(range E) for a compact space X with energy E : X → ℝ.

2. **Attainment theorem**: For lower semicontinuous E on a nonempty compact X, there exists x₀ ∈ X with E(x₀) = Z_trop(X, E). This converts the abstract infimum into an achieved minimum.

3. **Complete structural theory**: Translation invariance, monotonicity, surjective pullback invariance, and the tropical data processing inequality, all proved for compact spaces.

4. **Machine verification**: All definitions and theorems are formalized and verified in the Lean 4 theorem prover with the Mathlib library, ensuring absolute correctness.

### 1.3 Related Work

**Tropical geometry**: Mikhalkin (2005), Itenberg-Mikhalkin-Shustin (2009), and Maclagan-Sturmfels (2015) developed tropical algebraic geometry, but primarily in combinatorial and polyhedral settings without topological-analytic foundations for partition functions.

**Idempotent analysis**: Maslov (1987), Kolokoltsov-Maslov (1997), and Litvinov (2007) developed idempotent (dequantized) analysis, including idempotent measures and integrals. Our work can be viewed as a rigorous formalization of idempotent integration on compact spaces.

**Semicontinuous optimization**: The existence of minima for lower semicontinuous functions on compact sets is classical (Weierstrass). Our contribution is embedding this in the tropical-algebraic framework and proving the full structural theory.

**Information-theoretic inequalities**: The classical data processing inequality (Cover-Thomas, 2006) states that mutual information cannot increase under processing. Our tropical data processing inequality is the zero-temperature analogue.

## 2. Definitions and Notation

### 2.1 Setup

Let (X, τ) be a topological space. We say X is **compact** if every open cover has a finite subcover. A function E : X → ℝ is **lower semicontinuous** (lsc) if for every a ∈ ℝ, the sublevel set {x ∈ X : E(x) ≤ a} is closed, equivalently, if for every x ∈ X and every net x_α → x, we have E(x) ≤ lim inf E(x_α).

### 2.2 The Tropical Partition Function

**Definition 2.1** (Tropical Partition Function). Let X be a compact topological space and E : X → ℝ an energy function. The *tropical partition function* is

    Z_trop(X, E) := sInf(range E) = inf{E(x) : x ∈ X}

where sInf denotes the infimum in the conditionally complete lattice ℝ.

**Remark 2.2.** The definition uses sInf (= csInf in Mathlib), which for ℝ is the standard infimum when the set is nonempty and bounded below, and yields a junk value otherwise. Our theorems carry hypotheses ensuring well-behavedness.

### 2.3 Auxiliary Facts

**Lemma 2.3** (Bounded Below). If X is a nonempty compact space and E : X → ℝ is lower semicontinuous, then range E is bounded below.

*Proof.* The image E(X) = E '' univ, and univ is compact (X is a compact space). By Mathlib's `LowerSemicontinuousOn.bddBelow_of_isCompact`, a lower semicontinuous function has bounded-below image on a compact set.

**Lemma 2.4** (Range Nonempty). If X is nonempty, then range E is nonempty.

*Proof.* Immediate from the nonemptiness of X.

## 3. Main Results

### 3.1 Existence of Minimizers

**Theorem 3.1** (Extreme Value Theorem for LSC Functions). Let X be a nonempty compact topological space and E : X → ℝ a lower semicontinuous function. Then there exists x₀ ∈ X such that E(x₀) ≤ E(x) for all x ∈ X.

*Proof sketch.* Apply the Mathlib theorem `LowerSemicontinuousOn.exists_isMinOn` to the set s = X (= univ), which is compact (isCompact_univ) and nonempty. The lower semicontinuity on univ follows from global lower semicontinuity. The result yields x₀ ∈ univ with IsMinOn E univ x₀, which unfolds to ∀ x ∈ univ, E(x₀) ≤ E(x), hence ∀ x, E(x₀) ≤ E(x). □

**Theorem 3.2** (Attainment). Under the hypotheses of Theorem 3.1, there exists x₀ ∈ X with E(x₀) = Z_trop(X, E).

*Proof sketch.* Let x₀ be the minimizer from Theorem 3.1. Then:
- E(x₀) ≤ Z_trop(X, E): Since E(x₀) ≤ E(x) for all x, E(x₀) is a lower bound for range E, so E(x₀) ≤ sInf(range E) by le_csInf.
- Z_trop(X, E) ≤ E(x₀): Since E(x₀) ∈ range E and range E is bounded below, csInf_le gives sInf(range E) ≤ E(x₀).
- By antisymmetry, E(x₀) = Z_trop(X, E). □

### 3.2 Order-Theoretic Characterization

**Theorem 3.3** (Lower Bound Property). For any x ∈ X, Z_trop(X, E) ≤ E(x), provided E is lower semicontinuous.

*Proof.* Apply csInf_le to E(x) ∈ range E, using bounded-below from Lemma 2.3. □

**Theorem 3.4** (Greatest Lower Bound). If a ≤ E(x) for all x ∈ X, then a ≤ Z_trop(X, E).

*Proof.* Apply le_csInf to the nonempty range E. For any b ∈ range E, write b = E(x) for some x, then a ≤ E(x) = b. □

**Theorem 3.5** (Universal Characterization). Z_trop(X, E) ≤ a if and only if there exists x ∈ X with E(x) ≤ a.

*Proof.* Forward: by attainment (Theorem 3.2), the minimizer satisfies E(x₀) = Z_trop ≤ a. Backward: Z_trop ≤ E(x) ≤ a by Theorem 3.3. □

### 3.3 Structural Laws

**Theorem 3.6** (Translation Invariance). For any constant c ∈ ℝ,

    Z_trop(X, E + c) = Z_trop(X, E) + c

where (E + c)(x) = E(x) + c.

*Proof sketch.* Both inequalities are established:
- (≤): The minimizer x₀ of E satisfies (E + c)(x₀) = E(x₀) + c = Z_trop(X, E) + c, so Z_trop(X, E + c) ≤ Z_trop(X, E) + c by csInf_le.
- (≥): For any x, Z_trop(X, E) + c = sInf(range E) + c ≤ E(x) + c = (E + c)(x), so Z_trop(X, E) + c ≤ sInf(range(E + c)) by le_csInf.

Note: E + c is lower semicontinuous when E is, since adding a continuous function preserves lsc. □

**Theorem 3.7** (Monotonicity). If E(x) ≤ F(x) for all x ∈ X, and E is lower semicontinuous, then

    Z_trop(X, E) ≤ Z_trop(X, F)

*Proof.* For any F(x) ∈ range F, we have Z_trop(X, E) ≤ E(x) ≤ F(x) by Theorem 3.3 and the hypothesis. So Z_trop(X, E) is a lower bound for range F, giving Z_trop(X, E) ≤ sInf(range F) by le_csInf. □

**Theorem 3.8** (Surjective Pullback Invariance). Let f : Y → X be a surjection between nonempty compact spaces. Then

    Z_trop(Y, E ∘ f) = Z_trop(X, E)

*Proof.* The key observation is that range(E ∘ f) = range E when f is surjective:
- (⊆): If z ∈ range(E ∘ f), then z = E(f(y)) for some y, so z = E(f(y)) ∈ range E.
- (⊇): If z ∈ range E, then z = E(x) for some x. By surjectivity, x = f(y) for some y, so z = E(f(y)) ∈ range(E ∘ f).
Since the ranges are equal, their infima are equal. □

### 3.4 Data Processing Inequality

**Theorem 3.9** (Tropical Data Processing). Let f : X → Y be a map between nonempty compact spaces, E : X → ℝ and F : Y → ℝ lower semicontinuous energy functions satisfying F(f(x)) ≤ E(x) for all x ∈ X. Then

    Z_trop(Y, F) ≤ Z_trop(X, E)

*Proof.* For any E(x) ∈ range E:
- Z_trop(Y, F) = sInf(range F) ≤ F(f(x)) (by csInf_le, since F(f(x)) ∈ range F)
- F(f(x)) ≤ E(x) (by hypothesis)

So Z_trop(Y, F) ≤ E(x) for all x. By le_csInf applied to range E, Z_trop(Y, F) ≤ sInf(range E) = Z_trop(X, E). □

**Interpretation.** The hypothesis F(f(x)) ≤ E(x) says that the observed energy at f(x) is at most the latent energy at x — the observation channel can only reduce apparent energy. The conclusion says the observed system's ground-state energy is at most the latent system's. Coarse-graining cannot increase the minimum achievable energy.

## 4. Algorithms

### 4.1 Computing the Tropical Partition Function

For practical computation, the tropical partition function reduces to global minimization:

```
Algorithm: TropicalPartition(E, X)
Input: Energy function E, compact domain X (discretized to grid)
Output: Z_trop ≈ inf E(x)
1. Discretize X into grid points x₁, ..., x_N
2. Evaluate E(x_i) for each grid point
3. Return min{E(x₁), ..., E(x_N)}
```

**Complexity:** O(N) evaluations of E, where N is the grid size. For d-dimensional X with grid spacing h, N = O(h^{-d}).

### 4.2 Verifying Structural Laws Computationally

```
Algorithm: VerifyTranslationInvariance(E, X, c)
Input: Energy E, domain X, constant c
Output: Boolean (does Z_trop(E+c) ≈ Z_trop(E) + c?)
1. Compute Z₁ = TropicalPartition(E, X)
2. Compute Z₂ = TropicalPartition(E + c, X)
3. Return |Z₂ - (Z₁ + c)| < ε
```

## 5. Applications

### 5.1 Neural Network Loss Landscapes

Consider a neural network with parameter space Θ ⊆ ℝ^d (bounded, hence compactifiable) and loss function L : Θ → ℝ (typically continuous, hence lsc). The tropical partition function Z_trop(Θ, L) is the global minimum loss.

The monotonicity theorem (3.7) immediately gives: if architecture A has loss L_A ≤ L_B pointwise compared to architecture B, then the best achievable loss of A is at most that of B. The data processing inequality (3.9) gives: if we observe the network through a compression map (e.g., quantization), the apparent minimum loss can only decrease.

### 5.2 Ground State Selection in Physics

In statistical mechanics, the partition function at inverse temperature β is Z_β = Σ_x exp(-βE(x)). The free energy is F_β = -(1/β) log Z_β. As β → ∞ (zero temperature):

    lim_{β→∞} F_β = min_x E(x) = Z_trop(X, E)

Our attainment theorem guarantees that this ground-state energy is achieved by some configuration, provided the state space is compact and E is lower semicontinuous.

### 5.3 Optimal Transport

In the Kantorovich formulation of optimal transport between measures μ on X and ν on Y, the cost of transport is:

    inf_{π ∈ Π(μ,ν)} ∫ c(x,y) dπ(x,y)

For discrete measures, this is a linear program. In the tropical limit (where the cost is minimized rather than averaged), this becomes min_{(x,y) ∈ supp(π)} c(x,y), the minimum cost of any matching. Our framework provides the structural theory for this quantity.

## 6. Computational Experiments

We implemented the tropical partition function and its structural laws in Python, verifying them on several energy landscapes:

### 6.1 Quadratic Energy on [0, 1]

E(x) = (x - 0.3)², X = [0, 1].
- Z_trop = 0.0 (attained at x₀ = 0.3)
- Translation: Z_trop(E + 5) = 5.0 = Z_trop(E) + 5 ✓
- Monotonicity: E(x) ≤ E(x) + 0.1 implies Z_trop(E) ≤ Z_trop(E + 0.1) ✓

### 6.2 Multi-Modal Energy

E(x) = min(|x - 0.2|, |x - 0.7|), X = [0, 1].
- Z_trop = 0.0 (attained at x₀ ∈ {0.2, 0.7})
- Pullback invariance: Under f(x) = x/2 (surjective onto [0, 0.5]), the pulled-back minimum matches

### 6.3 Data Processing

E(x, y) = x² + y², F(y) = y² (projection onto y-axis).
- F(f(x,y)) = y² ≤ x² + y² = E(x,y) ✓
- Z_trop(F) = 0 ≤ 0 = Z_trop(E) ✓

## 7. Discussion

### 7.1 The Role of Lower Semicontinuity

Lower semicontinuity is essential for the attainment theorem and for the well-behavedness of sInf. Without it, the infimum of the range may not be achieved (consider E(x) = 1/x on (0, 1], which has inf = 0 but never achieves it) or the range may not be bounded below (consider arbitrary discontinuous functions on compact spaces).

The hypothesis appears in our theorems wherever boundedness below is needed. For the surjective pullback theorem (3.8), no semicontinuity is needed because the equality of ranges is purely set-theoretic.

### 7.2 Comparison with Classical Information Theory

| Property | Classical (Shannon) | Tropical (This Work) |
|----------|-------------------|---------------------|
| Partition function | Σ exp(-βE) | min E |
| Entropy | -Σ p log p | min E |
| Data processing | I(X;Z) ≤ I(X;Y) | Z_trop(Y,F) ≤ Z_trop(X,E) |
| Shift invariance | F_β(E+c) = F_β(E) + c | Z_trop(E+c) = Z_trop(E) + c |
| Temperature | β > 0 | β = ∞ |

### 7.3 Limitations

1. Our data processing inequality gives only one direction (≤). The equality case (when does coarse-graining preserve the minimum exactly?) requires fiber-by-fiber analysis not yet formalized.
2. We do not treat conditional tropical entropy or tropical mutual information, which would require product space constructions.
3. The relationship to Maslov's idempotent measure theory is conceptual but not formally established.

## 8. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. Key priorities include:
1. Tropical mutual information on compact product spaces
2. Lower semicontinuity of fiberwise infima for exact data processing equalities
3. Convergence of classical partition functions to the tropical one (Varadhan's lemma)
4. Tropical Bellman operators and connections to optimal control
5. Formalization on compact tropical varieties with piecewise-linear energies

## 9. References

1. I. Simon, "Recognizable sets with multiplicities in the tropical semiring," *MFCS* (1988).
2. V. P. Maslov, *Méthodes opératorielles*, Mir (1987).
3. V. N. Kolokoltsov and V. P. Maslov, *Idempotent Analysis and Its Applications*, Kluwer (1997).
4. G. L. Litvinov, "The Maslov dequantization, idempotent and tropical mathematics," *J. Math. Sci.* 140 (2007).
5. D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS (2015).
6. G. Mikhalkin, "Enumerative tropical algebraic geometry in ℝ²," *J. Amer. Math. Soc.* 18 (2005).
7. T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley (2006).
8. S. R. S. Varadhan, "Asymptotic probabilities and differential equations," *Comm. Pure Appl. Math.* 19 (1966).
9. The Mathlib Community, *Mathlib: a unified library of mathematics formalized in Lean 4*, https://github.com/leanprover-community/mathlib4.
