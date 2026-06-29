# The Mathematical Uncanny Valley: Trust Dynamics in Proof Evaluation

## Abstract

We introduce and formally verify a mathematical model of the "uncanny valley" phenomenon in proof evaluation. By analogy with Mori's uncanny valley in robotics, we conjecture and prove that trust in mathematical proofs is non-monotone in rigor level: informal intuitions and fully formal proofs are trusted, while "almost rigorous" proofs with small gaps trigger disproportionate suspicion. We define the **suspicion function** S(r) = r²(1-r), model trust as U(r) = r - αS(r) where α is the community's suspicion sensitivity, and prove five main results: (1) the suspicion function is bounded by 4/27 on [0,1], achieved at r = 2/3; (2) for α > 4, the trust model exhibits the valley phenomenon; (3) the threshold α = 4 is sharp; (4) continuous valley functions have interior minima; and (5) the valley is universal across all suspicion functions satisfying mild conditions. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: proof evaluation, trust dynamics, uncanny valley, epistemic barriers, formal verification, mathematical sociology

---

## 1. Introduction

The evaluation of mathematical proofs is typically treated as a binary process: a proof is either correct or incorrect. However, in practice, mathematicians routinely evaluate arguments at varying levels of rigor, from informal sketches to machine-verified formal proofs. This evaluation is not merely logical but also psychological — a mathematician's confidence in an argument depends not just on its logical content but on its *presentation* of rigor.

We propose that this trust dynamic exhibits a non-monotone pattern analogous to Mori's uncanny valley in robotics [Mori, 1970]. Specifically:

1. **Low rigor** (informal sketches): Moderate trust. The argument is understood as a guide to the key ideas, not a claim of completeness.
2. **High rigor** (formal proofs): High trust. The argument has been thoroughly checked.
3. **Intermediate rigor** (almost-rigorous proofs): Low trust. The argument claims completeness but fails to deliver it, triggering heightened scrutiny.

This pattern — trust that increases, then decreases, then increases again — defines the **mathematical uncanny valley**.

### 1.1 Related Work

The uncanny valley hypothesis originated in robotics [Mori, 1970] and has been studied extensively in human-robot interaction [MacDorman & Ishiguro, 2006]. Extensions to other domains include the uncanny valley of the mind [Gray & Wegner, 2012] and the uncanny valley in virtual characters [Tinwell, 2014].

In mathematics, related observations appear in the literature on mathematical practice. Lakatos [1976] described the dialectical process by which proofs are refined through counterexamples. De Millo, Lipton, and Perlis [1979] argued that mathematical proofs are social processes, not formal objects. More recently, Hales [2014] discussed how the formal verification of the Kepler conjecture resolved persistent doubts about the original proof.

The specific observation that "almost-right" proofs face disproportionate skepticism appears anecdotally throughout mathematics but has not, to our knowledge, been formalized.

### 1.2 Contributions

We make the following contributions:

1. **Novel mathematical model**: We introduce the suspicion function S(r) = r²(1-r) and the valley trust model U(r) = r - αS(r), providing a precise framework for the uncanny valley in proof evaluation.

2. **Sharp threshold theorem**: We prove that the critical suspicion sensitivity α = 4 is a sharp threshold: below it, trust is monotone in rigor; above it, the uncanny valley appears.

3. **Universal epistemic barrier**: We prove that the valley phenomenon is not specific to our model but arises universally for any trust model with suspicion penalty.

4. **Interior minimum theorem**: We prove that the minimum trust level always occurs at an interior rigor level, never at the extremes.

5. **Formal verification**: All results are verified in Lean 4 with Mathlib, providing the highest level of mathematical certainty.

---

## 2. Definitions

### 2.1 The Suspicion Function

**Definition 2.1** (Suspicion Function). The *suspicion function* S : [0,1] → ℝ is defined by:

$$S(r) = r^2(1-r)$$

The factor r² represents the *expectation of rigor*: a proof at high rigor level creates strong expectations of completeness. The factor (1-r) represents the *incompleteness*: the gap between claimed and actual rigor. Their product captures the key dynamic — suspicion is maximized when both expectation and incompleteness are significant.

### 2.2 The Valley Trust Model

**Definition 2.2** (Valley Trust Model). For suspicion sensitivity α ≥ 0, the *valley trust model* U_α : [0,1] → ℝ is:

$$U_\alpha(r) = r - \alpha \cdot S(r) = r - \alpha r^2(1-r)$$

The term r represents the *raw rigor contribution* — more rigorous arguments carry more information. The term αS(r) is the *suspicion penalty* — the trust deficit caused by gaps in an apparently rigorous argument.

### 2.3 The Valley Property

**Definition 2.3** (HasValley). A function f : ℝ → ℝ has the *valley property* on (a,b) if:

$$a < b \quad \text{and} \quad \exists x \in (a,b), \quad f(x) < f(a) \wedge f(x) < f(b)$$

This formalizes the essential shape of the uncanny valley: the function dips below both endpoint values at some interior point.

### 2.4 The Epistemic Barrier

**Definition 2.4** (Epistemic Barrier). An *epistemic barrier* is a triple (p, h, w) where:
- p ∈ (0,1) is the peak rigor level (where suspicion is maximal)
- h > 0 is the barrier height (maximum trust deficit)
- w > 0 is the barrier width (range of affected rigor levels)

### 2.5 Valley Depth

**Definition 2.5** (Valley Depth). The *valley depth* of f at point x relative to endpoints a, b is:

$$D(f, a, b, x) = \min(f(a), f(b)) - f(x)$$

Positive depth indicates that f(x) is below both endpoints — the valley is present.

---

## 3. Main Results

### 3.1 The Suspicion Peak Theorem

**Theorem 3.1** (Suspicion Bound). For all r ∈ [0,1]:

$$S(r) = r^2(1-r) \leq \frac{4}{27}$$

with equality at r = 2/3.

*Proof sketch*. By the AM-GM inequality applied to the triple (r/2, r/2, 1-r):

$$\frac{r}{2} \cdot \frac{r}{2} \cdot (1-r) \leq \left(\frac{r/2 + r/2 + (1-r)}{3}\right)^3 = \frac{1}{27}$$

Multiplying by 4 gives S(r) ≤ 4/27. Equality holds when r/2 = 1-r, i.e., r = 2/3. ∎

*Interpretation*. The maximum suspicion is 4/27 ≈ 0.148, occurring at rigor level 2/3. This means the most suspicious proofs are those that are about two-thirds rigorous — detailed enough to create strong expectations but with a significant remaining gap of 1/3.

### 3.2 Valley Existence

**Theorem 3.2** (Valley Existence). For α > 4, the valley trust model U_α has the valley property on (0,1):

$$\exists r \in (0,1), \quad U_\alpha(r) < U_\alpha(0) = 0 \quad \text{and} \quad U_\alpha(r) < U_\alpha(1) = 1$$

*Proof sketch*. The witness is r = 1/2. We compute:

$$U_\alpha(1/2) = 1/2 - \alpha \cdot (1/4) \cdot (1/2) = 1/2 - \alpha/8$$

For α > 4, this gives U_α(1/2) < 1/2 - 4/8 = 0 = U_α(0). Also U_α(1/2) < 0 < 1 = U_α(1). ∎

*Interpretation*. When α > 4, a proof at rigor level 1/2 is trusted *less than no proof at all*. The suspicion penalty from the visible gaps overwhelms the information content of the rigorous parts.

### 3.3 Sharp Threshold

**Theorem 3.3** (Sharp Threshold). For 0 ≤ α ≤ 4, the valley trust model is nonnegative on [0,1]:

$$\forall r \in [0,1], \quad U_\alpha(r) \geq 0$$

*Proof sketch*. We need r ≥ αr²(1-r) for r ∈ [0,1]. For r = 0, this is trivial. For r > 0, dividing by r gives 1 ≥ αr(1-r). Since r(1-r) ≤ 1/4 (from (2r-1)² ≥ 0) and α ≤ 4, we get αr(1-r) ≤ 4 · 1/4 = 1. ∎

*Interpretation*. Theorems 3.2 and 3.3 together show that α = 4 is a **phase transition** for the trust model. Below α = 4, the mathematical community is forgiving enough that more rigor always helps. Above α = 4, the uncanny valley appears. The critical sensitivity α = 4 is the reciprocal of the maximum of r(1-r), reflecting the geometric structure of the unit interval.

### 3.4 Valley Depth Monotonicity

**Theorem 3.4** (Monotonicity in α). For α₁ ≤ α₂ and r ∈ [0,1]:

$$U_{\alpha_2}(r) \leq U_{\alpha_1}(r)$$

*Proof sketch*. The difference U_{α₁}(r) - U_{α₂}(r) = (α₂ - α₁) · S(r) ≥ 0 since α₂ ≥ α₁ and S(r) ≥ 0 on [0,1]. ∎

*Interpretation*. As a mathematical community becomes more sophisticated in detecting errors (higher α), the uncanny valley gets deeper. Expert communities pay a higher cost for near-misses.

### 3.5 Interior Minimum Theorem

**Theorem 3.5** (Interior Minimum). Let f : [0,1] → ℝ be continuous with the valley property on (0,1). Then f attains its minimum on [0,1] at an interior point:

$$\exists x \in (0,1), \quad \forall y \in [0,1], \quad f(x) \leq f(y)$$

*Proof sketch*. By the Extreme Value Theorem (compactness of [0,1] and continuity of f), f attains its minimum at some x₀ ∈ [0,1]. By the valley property, there exists z ∈ (0,1) with f(z) < f(0) and f(z) < f(1). Since f(x₀) ≤ f(z) < f(0), we have x₀ ≠ 0. Since f(x₀) ≤ f(z) < f(1), we have x₀ ≠ 1. Thus x₀ ∈ (0,1). ∎

*Interpretation*. The minimum trust level necessarily occurs at an intermediate rigor level. One cannot reach the bottom of the uncanny valley by being either completely informal or completely formal. This is a topological consequence of the valley shape.

### 3.6 The Epistemic Barrier Theorem

**Theorem 3.6** (Universal Epistemic Barrier). Let S : [0,1] → ℝ be any function with S(0) = S(1) = 0, S ≥ 0 on [0,1], and max S = M > 0. If αM > 1, then:

$$\exists r \in (0,1), \quad r - \alpha S(r) < 0$$

*Proof sketch*. Let r₀ be where S(r₀) = M. Since S(0) = S(1) = 0 and M > 0, we have r₀ ∈ (0,1). Then r₀ - αS(r₀) = r₀ - αM < 1 - αM < 0 since r₀ < 1 and αM > 1. ∎

*Interpretation*. This is the most general result: the uncanny valley appears for **any** suspicion function, not just S(r) = r²(1-r). The only requirements are: suspicion vanishes at zero rigor and full rigor, is nonneg in between, and the sensitivity parameter is large enough. The threshold is αM > 1, or equivalently α > 1/M.

---

## 4. Algorithms

### 4.1 Valley Detection Algorithm

Given a trust function U : [0,1] → ℝ sampled at n points, detect whether the uncanny valley is present:

```
VALLEY-DETECT(U, n):
  samples ← [U(i/n) for i = 0..n]
  left_val ← samples[0]
  right_val ← samples[n]
  threshold ← min(left_val, right_val)
  for i = 1 to n-1:
    if samples[i] < threshold:
      return VALLEY_FOUND at rigor i/n
  return NO_VALLEY
```

### 4.2 Optimal Suspicion Sensitivity Estimation

Given empirical trust data {(rᵢ, tᵢ)}ᵢ, estimate the suspicion sensitivity α:

```
ESTIMATE-ALPHA(data):
  α ← minimize Σᵢ (tᵢ - U_α(rᵢ))² over α ≥ 0
  return α
```

This is a one-parameter least-squares problem with closed-form solution:

$$\hat{\alpha} = \frac{\sum_i (r_i - t_i) \cdot S(r_i)}{\sum_i S(r_i)^2}$$

---

## 5. Discussion

### 5.1 The Phase Transition at α = 4

The sharp threshold at α = 4 is perhaps the most striking result. It implies that whether the uncanny valley exists is not a matter of degree but a **phase transition**. Below the critical sensitivity, the mathematical landscape is benign: more effort always leads to more trust. Above it, the landscape develops a valley that deepens monotonically with sensitivity.

The critical value 4 = 1/max{r(1-r)} has a geometric interpretation. The function r(1-r) measures the "exposure" of a proof at rigor level r — the product of rigor and incompleteness. The maximum exposure 1/4 occurs at r = 1/2. The critical α is the reciprocal of this maximum exposure.

### 5.2 Connection to Bayesian Updating

The valley model can be interpreted in a Bayesian framework. A mathematician's prior belief about proof correctness is updated by observing the rigor level. An informal argument carries low prior weight but also low evidence of error. A nearly-complete argument carries high prior weight but provides strong evidence of a potential error (the gap itself becomes informative).

In this framework, the suspicion function S(r) = r²(1-r) arises naturally as the product of the prior weight r² and the error signal (1-r).

### 5.3 Implications for Mathematical Practice

Our results suggest several practical implications:

1. **The "all or nothing" principle**: Mathematicians should either present informal sketches (low r) or complete proofs (high r), avoiding the valley of intermediate rigor.

2. **Audience-dependent rigor**: The optimal rigor level depends on α, which varies by audience. Expert audiences have higher α and deeper valleys.

3. **The cost of formal verification**: The valley model explains the value of formal verification: it moves proofs from the valley (r ≈ 0.9) to the peak (r = 1), crossing the steepest part of the trust curve.

### 5.4 Limitations

Our model has several limitations:

1. **Single parameter**: The rigor level r is one-dimensional, while real proofs have complex multi-dimensional structures.
2. **Specific functional form**: The choice S(r) = r²(1-r) is motivated but not uniquely determined.
3. **No empirical calibration**: The model predictions await systematic empirical testing.
4. **Static model**: Real trust is updated dynamically as mathematicians engage with an argument.

---

## 6. Conjectures and Future Work

### 6.1 Open Conjecture: Optimal Valley Location

**Conjecture 6.1**. For the valley model U_α with α > 4, the rigor level rmin that minimizes U_α satisfies:

$$r_{\min} = \frac{1 - \sqrt{1 - 3/\alpha}}{3}$$

This follows from setting U'_α(r) = 0, i.e., 1 - α(2r - 3r²) = 0, giving 3αr² - 2αr + 1 = 0 with the smaller root as the minimum.

**Test**: For α = 12, the formula predicts rmin = (1 - √(3/4))/3 ≈ 0.045. Numerically minimize U₁₂ and compare.

### 6.2 Multi-dimensional Extension

Real proofs have multiple dimensions of rigor: logical structure, computational verification, generality of hypotheses, etc. A multi-dimensional valley model U(r₁, ..., rₙ) may exhibit valley *surfaces* rather than valley *points*.

### 6.3 Dynamic Trust Model

In practice, trust is updated as a mathematician reads through a proof. A dynamic model U(r, t) where t is the "reading progress" could capture how early gaps affect evaluation of later arguments.

---

## 7. Formal Verification

All theorems in this paper are formalized and verified in Lean 4 with Mathlib. The formalization comprises:

- 5 definitions (suspicionFn, valleyModel, HasValley, EpistemicBarrier, valleyDepth)
- 10 theorems, all proved without `sorry`
- Clean axiom usage (only propext, Classical.choice, Quot.sound)

The formalization serves as both a verification of our results and a demonstration of the paper's thesis: fully formal proofs (r = 1) inspire the highest confidence.

---

## References

1. Mori, M. (1970). The uncanny valley. *Energy*, 7(4), 33-35.
2. MacDorman, K. F., & Ishiguro, H. (2006). The uncanny advantage of using androids in cognitive and social science research. *Interaction Studies*, 7(3), 297-337.
3. Gray, K., & Wegner, D. M. (2012). Feeling robots and human zombies: Mind perception and the uncanny valley. *Cognition*, 125(1), 125-130.
4. Lakatos, I. (1976). *Proofs and Refutations*. Cambridge University Press.
5. De Millo, R. A., Lipton, R. J., & Perlis, A. J. (1979). Social processes and proofs of theorems and programs. *Communications of the ACM*, 22(5), 271-280.
6. Hales, T. C. (2014). *Dense Sphere Packings: A Blueprint for Formal Proofs*. Cambridge University Press.
7. Tinwell, A. (2014). *The Uncanny Valley in Games and Animation*. CRC Press.
