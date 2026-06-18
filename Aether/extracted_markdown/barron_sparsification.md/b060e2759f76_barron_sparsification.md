# Quantitative Sparsification for Finite Activation Algebras: A Formally Verified Barron-Type Theory

## Abstract

We develop a formally verified quantitative sparsification theory for the EML (Expression Meta-Language) approximation framework, working on finite domains. Our results upgrade existing qualitative density theorems (Stone–Weierstrass type) to explicit finite-width approximation rates. We prove three main theorems in Lean 4:

1. **Constructive Maurey Lemma** (finite domain): Any convex combination of m atoms bounded by B on a domain of size n can be approximated by a uniform average of W atoms with ℓ₂² error ≤ nB²/W (hence sup-norm error ≤ B√(n/W)).

2. **Greedy Sparsification Theorem**: Under a one-step norm-reduction hypothesis (HasGreedyStep), iterating W times produces an approximant with error ≤ R₀·(1 − 1/C)^W, achieving exponential convergence.

3. **Two-Stage Universal Approximation**: Composing a quantitative Stone–Weierstrass oracle with either sparsification method yields total error ≤ ε₁(N) + ε₂(W), where N controls algebraic approximation quality and W controls width.

All proofs are machine-verified with no `sorry` and use only standard axioms (propext, Classical.choice, Quot.sound).

---

## 1. Introduction

### 1.1 Context: From Density to Complexity

Universal approximation theorems — asserting that certain function classes are dense in continuous functions — have been central to theoretical machine learning since the foundational works of Cybenko (1989) and Hornik, Stinchcombe, and White (1989). However, density is a purely qualitative statement: it says *some* finite approximation exists without specifying *how many terms* are needed for a given accuracy.

The quantitative question — "What is the approximation rate as a function of width?" — was first addressed by Barron (1993), who showed that functions with bounded Fourier moment can be approximated by single-hidden-layer neural networks with O(1/√W) error in L₂ norm, where W is the width. This Barron-type theory bridges the gap between "can approximate" and "can approximate efficiently."

### 1.2 Our Contribution

We develop a complete, formally verified quantitative sparsification theory within the EML framework. Our approach has three distinguishing features:

**Finite-domain formalization.** We work on X = Fin n (or any finite nonempty type) with the explicit sup norm `supNorm f = max_x |f(x)|`. This avoids topological overhead (compact spaces, uniform convergence) while capturing the full combinatorial structure of the sparsification argument.

**Constructive Maurey argument.** Rather than using probabilistic sampling, we give a fully constructive proof of the Maurey lemma via one-step greedy selection in ℓ₂. Each step selects the atom minimizing the updated ℓ₂ error, and the cross-term in the variance expansion vanishes because f equals its own convex decomposition.

**Machine verification.** All results are verified in Lean 4 with Mathlib, providing the highest standard of mathematical certainty. The formalization comprises approximately 700 lines across four files, with proofs that compose cleanly.

---

## 2. Mathematical Framework

### 2.1 Definitions

Fix a finite nonempty type X with |X| = n. Functions f : X → ℝ live in the n-dimensional space ℝⁿ, equipped with:

- **Sup norm:** ‖f‖∞ = max_{x ∈ X} |f(x)|
- **Squared ℓ₂ norm:** ‖f‖₂² = Σ_{x ∈ X} f(x)²

These satisfy ‖f‖∞ ≤ ‖f‖₂ (since max ≤ sqrt of sum of nonneg terms).

An **atomic family** is a predicate IsAtom : (X → ℝ) → Prop with a **uniform bound** B: every atom g satisfies |g(x)| ≤ B for all x.

A function f has an **atomic representation** with bound B and ℓ¹ budget M if:

$$f(x) = \sum_i a_i g_i(x), \quad |g_i(x)| \le B, \quad \sum_i |a_i| \le M$$

### 2.2 Normalization: Signed to Convex

Any atomic representation f = Σ aᵢ gᵢ with L = Σ|aᵢ| > 0 can be normalized:

$$f = L \cdot \sum_i \mu_i h_i$$

where μᵢ = |aᵢ|/L ≥ 0, Σ μᵢ = 1, and hᵢ = sign(aᵢ)·gᵢ still satisfies |hᵢ(x)| ≤ B. This reduces the general signed case to convex combinations, which are the natural setting for the Maurey argument.

---

## 3. Main Results

### 3.1 Theorem 1: Constructive Maurey Lemma

**Theorem** (`maurey_constructive_l2sq`). *Let μ₁,...,μₘ ≥ 0 with Σ μᵢ = 1, and let g₁,...,gₘ : X → ℝ with |gᵢ(x)| ≤ B. For any W ≥ 1, there exist indices j₁,...,j_W such that*

$$\left\| \sum_i \mu_i g_i - \frac{1}{W}\sum_{k=1}^W g_{j_k} \right\|_2^2 \le \frac{n B^2}{W}$$

*Consequently (by ‖·‖∞ ≤ ‖·‖₂):*

$$\left\| \sum_i \mu_i g_i - \frac{1}{W}\sum_{k=1}^W g_{j_k} \right\|_\infty \le B\sqrt{\frac{n}{W}}$$

**Proof strategy.** The proof is by induction on W, using a one-step greedy selection lemma. At each step k, given a current average u of k atoms with ‖f − u‖₂² ≤ E, we select an atom g_{j₀} such that

$$\left\|f - \left(\frac{k}{k+1} u + \frac{1}{k+1} g_{j_0}\right)\right\|_2^2 \le \left(\frac{k}{k+1}\right)^2 E + \frac{nB^2}{(k+1)^2}$$

The key identity: for the convex combination f = Σ μᵢ gᵢ, the cross-term in the variance expansion vanishes:

$$\sum_i \mu_i (f(x) - g_i(x)) = f(x) - f(x) = 0$$

This yields Σᵢ μᵢ (f(x) − gᵢ(x))² ≤ B² (the "variance" of atoms around their mean), and the one-step bound follows. By induction, E_W ≤ nB²/W.

### 3.2 Theorem 2: Greedy Exponential Decay

**Theorem** (`greedy_iteration`). *Let HasGreedyStep(IsAtom, C) hold for C > 1, meaning: for any residual r with ‖r‖∞ ≤ R, there exists an atom g with ‖r − (R/C)g‖∞ ≤ R(1 − 1/C). Then for any f with ‖f‖∞ ≤ R₀, iterating W times yields an approximant q with*

$$\|f - q\|_\infty \le R_0 \cdot \left(1 - \frac{1}{C}\right)^W$$

**Proof.** Direct induction on W. The base case W = 0 is trivial. For the inductive step, apply HasGreedyStep to the current residual and multiply the geometric factor.

**Corollary** (`eml_atomic_greedy_exponential`). *For f with atomic representation (bound B, budget M):*

$$\|f - q_W\|_\infty \le BM \cdot \left(1 - \frac{1}{C}\right)^W$$

### 3.3 Theorem 3: Two-Stage Universal Approximation

**Theorem** (`eml_two_stage_universal_approx_greedy`). *Given:*
- *A Stone–Weierstrass oracle producing, for each f and parameter N, an approximant p with ‖f − p‖∞ ≤ stoneRate(N) and an atomic representation of p with budget barronBudget(N)*
- *The greedy step property HasGreedyStep(IsAtom, C)*

*Then for any f, N, W, there exists q with:*

$$\|f - q\|_\infty \le \text{stoneRate}(N) + B \cdot \text{barronBudget}(N) \cdot \left(1 - \frac{1}{C}\right)^W$$

**Proof.** Apply the Stone–Weierstrass oracle to get p, sparsify p using the greedy theorem, and combine by the triangle inequality.

---

## 4. Rate Analysis

### 4.1 Maurey Rate

The Maurey bound M·B·√(n/W) has three factors:
- **M (ℓ¹ budget):** Controls the "complexity" of the target function within the atomic hull
- **B (atom bound):** The uniform pointwise bound on atoms. For bounded activations (sigmoid, tanh), B = 1
- **√(n/W) (sampling rate):** The √n factor reflects dimensionality; for fixed n, the rate is O(1/√W)

### 4.2 Greedy Rate

The greedy bound R₀·(1 − 1/C)^W achieves exponential decay, far superior to the polynomial Maurey rate. However, it requires the stronger HasGreedyStep hypothesis. The constant C governs convergence speed: C = 2 gives 2^{−W} decay.

### 4.3 Two-Stage Tradeoff

The two-stage bound reveals an approximation–complexity tradeoff:
- Increasing N improves Stone–Weierstrass accuracy but may increase M(N)
- Increasing W improves sparsification
- The optimal (N*, W*) balances these effects

---

## 5. Formalization Architecture

The Lean formalization is organized in four files:

| File | Lines | Content |
|------|-------|---------|
| `EML/BarronDefs.lean` | ~120 | Core definitions, sup norm lemmas |
| `EML/BarronGreedy.lean` | ~100 | Greedy iteration theorems |
| `EML/BarronMaurey.lean` | ~320 | Maurey lemma with helpers |
| `EML/BarronTwoStage.lean` | ~120 | Two-stage composition |

Key design decisions:
- **Finite domain first:** Working on `[Fintype X] [Nonempty X]` avoids topological complications
- **Constructive proofs:** The Maurey lemma uses greedy selection, not probabilistic sampling
- **Modular helpers:** Variance identity, cross-term vanishing, and weighted averaging are separate reusable lemmas

---

## 6. Applications

### 6.1 Neural Network Compression

A single-hidden-layer neural network f(x) = Σ aᵢ σ(wᵢ·x + bᵢ) with bounded activation σ is an atomic combination. The Maurey theorem guarantees:

> *Any width-m network can be compressed to width W with error ≤ (Σ|aᵢ|)·B·√(n/W), independent of m.*

### 6.2 Kernel Method Approximation

In kernel methods, f(x) = Σ αᵢ K(xᵢ, x) is an atomic combination with atoms K(xᵢ, ·). Our theorems bound Nyström-type approximation errors.

### 6.3 EML Algebra Generators

In the EML framework, algebraic generators serve as atoms. The sparsification theorems convert qualitative density results into quantitative width bounds for EML expression trees.

---

## 7. Discussion: Making Density Theorems Practical

Imagine you're an architect designing a building. Someone tells you: "With enough bricks, you can build any shape." That's a density theorem — reassuring, but not very helpful. What you need to know is: "How many bricks for a building of this size and accuracy?"

Our work answers this question for mathematical approximation. In machine learning, neural networks can approximate any continuous function — that's universal approximation. But this is like saying "enough bricks suffice." Our sparsification theorems say: "W neurons suffice, and the error is at most this formula."

The key insight comes from statistics. To estimate the average height in a city, you don't measure everyone. A sample of W people gives error proportional to 1/√W — the Central Limit Theorem. Our Maurey lemma applies this principle to function approximation: a "sample" of W neurons from a large network approximates the original with error O(1/√W).

What makes our work distinctive is *machine verification*. Every claim is checked by the Lean theorem prover — no hidden assumptions, no overlooked edge cases. This matters for safety-critical applications where approximate guarantees aren't sufficient.

The greedy rate offers a stronger guarantee for structured problems: when the atom family satisfies a norm-reduction property, each added neuron reduces the error by a fixed fraction, giving exponential convergence. This connects to classical nonlinear approximation theory.

These finite-domain results are a stepping stone toward continuous-domain Barron space theory. The algebraic structure — variance decomposition, cross-term vanishing, one-step minimization — carries over to infinite-dimensional Hilbert spaces.

---

## 8. Future Directions

1. **Continuous compact domains:** Extend from Fin n to general compact Hausdorff spaces
2. **Barron space completion:** Define the Barron space as closure of the atomic hull
3. **Optimal rates:** Prove lower bounds for the √n factor in sup norm
4. **Concrete EML instantiation:** Verify HasGreedyStep for specific EML generators
5. **Training convergence:** Connect sparsification to gradient descent convergence

---

## References

- A. Barron, "Universal approximation bounds for superpositions of a sigmoidal function," *IEEE Trans. Information Theory*, vol. 39, no. 3, pp. 930–945, 1993.
- B. Maurey, "Théorèmes de factorisation pour les opérateurs linéaires à valeurs dans les espaces Lp," *Astérisque*, vol. 11, 1974.
- G. Pisier, "Remarques sur un résultat non publié de B. Maurey," *Séminaire d'Analyse Fonctionnelle*, 1981.
- G. Cybenko, "Approximation by superpositions of a sigmoidal function," *Mathematics of Control, Signals and Systems*, vol. 2, no. 4, pp. 303–314, 1989.
