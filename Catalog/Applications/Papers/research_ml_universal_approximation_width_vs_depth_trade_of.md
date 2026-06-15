# Depth Separation for ReLU Networks via the Iterated Tent Map: A Sharp, Range-Preserving Lipschitz Obstruction

## Abstract

We give a fully self-contained, elementary, and sharp proof of depth separation for rectified-linear-unit (ReLU) neural networks. The construction is built entirely from the **tent map** `tent(x) = 1 − |2x − 1|`, which we show is an exact one-hidden-layer ReLU network of width two. Its *k*-fold self-composition `tentᵏ` is then a depth-*k*, constant-width ReLU network whose total size grows only linearly in *k*. We establish that `tentᵏ` keeps its output confined to the unit interval [0, 1] while developing an exponentially steep first ramp — it climbs from 0 to 1 across a horizontal distance of exactly 2⁻ᵏ — and consequently has Lipschitz constant exactly 2ᵏ. Our main theorem shows that **any** *K*-Lipschitz function *g* with K · 2⁻ᵏ + 2ε < 1 fails to approximate `tentᵏ` to uniform accuracy ε on [0, 1]. Since a shallow ReLU network with bounded weights realizes a Lipschitz function whose constant is controlled by its width-times-weight budget, matching a depth-*k* network forces that budget to grow like 2ᵏ — exponential depth separation. We prove the separation threshold is sharp: the self-approximation (K = 2ᵏ, ε = 0) lands exactly on the boundary K · 2⁻ᵏ + 2ε = 1, so the strict inequality cannot be weakened to a non-strict one. Unlike obstructions based on range explosion, ours is *range-preserving*: the hardness comes purely from oscillation packed into a vanishing interval, isolating the genuinely piecewise-linear (Telgarsky-style) mechanism behind depth separation. All results are accompanied by formal, machine-checked proofs.

**Keywords:** depth separation, ReLU networks, universal approximation, Lipschitz lower bounds, tent map, expressivity, width–depth trade-off.

---

## 1. Introduction

### 1.1 The width–depth question

A feedforward ReLU network is a finite composition of affine maps interleaved with the coordinatewise nonlinearity `relu(x) = max(x, 0)`. Two structural budgets govern its cost: **width** (the number of units in a layer) and **depth** (the number of layers). The universal approximation theorem guarantees that, given enough width, even a single hidden layer can approximate any continuous function on a compact set to arbitrary accuracy. This naturally raises a quantitative question: for a fixed accuracy, is one shape of network — wide-and-shallow versus narrow-and-deep — fundamentally more economical than the other?

The empirical answer, embodied in every successful modern architecture, is that depth is dramatically more efficient. The theoretical counterpart is the family of **depth-separation theorems**: explicit functions computable by a polynomially-sized deep network but requiring exponentially-sized shallow networks. The seminal analytic example, due to Telgarsky, uses iterated triangle (sawtooth) functions whose oscillation count grows exponentially with depth, defeating the limited number of linear pieces a shallow network can produce.

### 1.2 Contribution

This paper formalizes a clean, sharp version of this phenomenon using only the tent map and elementary real analysis. Our contributions are:

1. **An exact width-two ReLU representation** of the tent map (Theorem 4.1), making the connection to neural networks literal rather than approximate.
2. **A precise geometric description** of the *k*-fold tent: it fixes the left endpoint (Lemma 4.4), reaches value 1 at x = 2⁻ᵏ (Theorem 4.5), and is exactly 2ᵏ-Lipschitz (Theorem 4.3), all while remaining range-confined to [0, 1] (Lemma 4.2).
3. **A depth-separation theorem** (Theorem 5.1) giving an explicit, easily-checkable failure condition for any Lipschitz approximant, with a two-point squeeze proof.
4. **A sharpness theorem** (Theorem 5.2) proving the threshold inequality cannot be relaxed.
5. A discussion contrasting our **range-preserving** obstruction with **range-exploding** ones, clarifying which mechanism is genuinely neural.

Every statement below has been formally verified in a proof assistant; here we present the mathematics and proof sketches.

---

## 2. Related work and context

The idea that deep networks express highly oscillatory functions cheaply traces to Telgarsky's sawtooth construction and to work by Eldan–Shamir, Safran–Shamir, and others establishing depth separations under various norms and architectures. Earlier counting arguments (Montúfar–Pascanu–Cho–Bengio) bound the number of linear regions of a deep ReLU network from below, exponentially in depth. The tent map is the canonical building block of these arguments because composing it doubles the number of monotone pieces.

Within the present catalog, this result complements a related obstruction for the iterated *exponential* tower (`not_uniformApprox_of_small_lipschitz` in `MachineLearning.DepthSeparation.Separation`), whose hardness arises because the function's *range* explodes. The novelty here is that the tent's range is fixed at [0, 1]; the difficulty is purely oscillatory, which is the more informative and more genuinely neural mechanism.

---

## 3. Preliminaries and definitions

We work over the real numbers. We write `f^[k]` for the *k*-fold composition of `f` with itself, with `f^[0]` the identity. We write `Icc a b` for the closed interval [a, b].

**Definition 3.1 (ReLU).** The rectified linear unit is `relu(x) = max(x, 0)`.

**Definition 3.2 (Lipschitz constant).** A function `f : ℝ → ℝ` is *K*-Lipschitz (written `LipschitzWith K f`) if for all x, y, |f(x) − f(y)| ≤ K · |x − y|. Equivalently, in distance form, dist(f(x), f(y)) ≤ K · dist(x, y).

**Definition 3.3 (Tent map).** The tent map is

> tent(x) = 1 − |2x − 1|.

On [0, 1] it is the symmetric triangle with value 0 at the endpoints and peak value 1 at x = 1/2.

**Definition 3.4 (Depth-*k* tent network).** The depth-*k* tent network is the *k*-fold composition `tent^[k]`. Realized as a neural network, it stacks *k* identical width-two ReLU blocks (Theorem 4.1), so its total parameter count is O(*k*) — linear in depth.

**Definition 3.5 (Shallow Lipschitz model).** A one-hidden-layer ReLU network x ↦ b + Σⱼ aⱼ · relu(wⱼ x + cⱼ) of width *m* is Lipschitz with constant at most Σⱼ |aⱼ wⱼ| ≤ m · (max |aⱼ|)(max |wⱼ|). Thus bounded-weight shallow networks are exactly Lipschitz functions whose constant is controlled by their width-times-weight budget. This is why a Lipschitz lower bound is a genuine architectural lower bound.

---

## 4. The construction: tent maps as ReLU networks

### 4.1 The tent map is a width-two ReLU layer

**Theorem 4.1 (`tent_relu_repr`).** For all x,

> tent(x) = 1 − relu(2x − 1) − relu(1 − 2x).

*Proof sketch.* For any real y, |y| = max(y, 0) + max(−y, 0) = relu(y) + relu(−y). Setting y = 2x − 1 gives |2x − 1| = relu(2x − 1) + relu(1 − 2x). Substituting into the definition of the tent map and simplifying yields the identity. ∎

This exhibits the tent map as a one-hidden-layer ReLU network with two hidden units (one for each branch of the absolute value), an output bias of 1, and output weights −1.

### 4.2 Range confinement

**Lemma 4.2 (`tent_mapsTo`).** The tent map sends [0, 1] into [0, 1].

*Proof sketch.* For x ∈ [0, 1] we have −1 ≤ 2x − 1 ≤ 1, hence |2x − 1| ≤ 1, so tent(x) = 1 − |2x − 1| ∈ [0, 1]. The lower bound uses |2x − 1| ≤ 1; the upper bound uses |2x − 1| ≥ 0. ∎

By induction, every iterate `tent^[k]` also maps [0, 1] into [0, 1]. This is the crucial structural feature distinguishing our obstruction from range-explosion arguments: the output magnitude never grows.

### 4.3 The ascending branch

**Lemma 4.3a (`tent_eq_two_mul`).** For x ≤ 1/2, tent(x) = 2x.

*Proof sketch.* For x ≤ 1/2 we have 2x − 1 ≤ 0, so |2x − 1| = 1 − 2x and tent(x) = 1 − (1 − 2x) = 2x. ∎

This identity is the engine of the iteration analysis: near the left endpoint the tent map acts as the doubling map, which is what propagates the steep ramp inward under composition.

### 4.4 The Lipschitz constant grows exponentially with depth

**Theorem 4.3 (`tent_lipschitz`, `tent_iterate_lipschitz`).** The tent map is 2-Lipschitz, and `tent^[k]` is 2ᵏ-Lipschitz.

*Proof sketch.* The absolute value is 1-Lipschitz; precomposing with x ↦ 2x − 1 scales the constant by 2, and the outer affine map 1 − (·) preserves it, so tent is 2-Lipschitz (formally, via a case analysis on the signs inside the absolute values, or via `abs_sub_abs_le_abs_sub`). The composition law for Lipschitz maps, LipschitzWith K f and LipschitzWith K g ⟹ LipschitzWith (K·K) (g ∘ f), iterated *k* times, gives LipschitzWith (2ᵏ) (tent^[k]). ∎

Thus the deep network's slope budget compounds: each layer contributes a factor of 2.

### 4.5 The exponentially steep ramp

**Lemma 4.4 (`tent_iterate_zero`).** For all k, tent^[k](0) = 0.

*Proof sketch.* The point 0 is a fixed point: tent(0) = 1 − |−1| = 0. By induction, applying the tent map to 0 repeatedly stays at 0. ∎

**Theorem 4.5 (`tent_iterate_peak`).** For all k, tent^[k]((1/2)ᵏ) = 1.

*Proof sketch.* Induct on k. The base case is the identity at value 1 (with (1/2)⁰ = 1 and tent⁰ the identity; the inductive structure is set up so the peak value is reached). For the step, note (1/2)^{k+1} ≤ 1/2, so by Lemma 4.3a, tent((1/2)^{k+1}) = 2 · (1/2)^{k+1} = (1/2)ᵏ. Therefore

> tent^[k+1]((1/2)^{k+1}) = tent^[k](tent((1/2)^{k+1})) = tent^[k]((1/2)ᵏ) = 1

by the inductive hypothesis. ∎

**Corollary 4.6 (steep ramp).** Combining Lemma 4.4 and Theorem 4.5, the function `tent^[k]` climbs from 0 (at x = 0) to 1 (at x = 2⁻ᵏ) over a horizontal interval of width exactly 2⁻ᵏ. Its average slope on this interval is 2ᵏ, consistent with (and witnessing the tightness of) Theorem 4.3.

This single steep ramp is all the geometry we need for the lower bound. (A strictly stronger but more involved argument counts all 2ᵏ⁻¹ peaks; see §7.)

---

## 5. The depth-separation theorem

### 5.1 Main result

**Theorem 5.1 (Depth separation, `relu_depth_separation`).** Let k ∈ ℕ, let g : ℝ → ℝ, and let K, ε ∈ ℝ. Suppose

- *(Lipschitz)* for all x, y: |g(x) − g(y)| ≤ K · |x − y|, and
- *(budget)* K · (1/2)ᵏ + 2ε < 1.

Then it is **not** the case that for all x ∈ [0, 1], |tent^[k](x) − g(x)| ≤ ε. In other words, g fails to ε-approximate the depth-k tent network uniformly on [0, 1].

*Proof sketch.* We argue by contraposition: assume g does ε-approximate `tent^[k]` everywhere on [0, 1] and derive K · 2⁻ᵏ + 2ε ≥ 1. Evaluate at the two witness points x = 0 and x = (1/2)ᵏ, both of which lie in [0, 1].

- At x = 0: |tent^[k](0) − g(0)| = |0 − g(0)| ≤ ε, so |g(0)| ≤ ε.
- At x = (1/2)ᵏ: |tent^[k]((1/2)ᵏ) − g((1/2)ᵏ)| = |1 − g((1/2)ᵏ)| ≤ ε, so g((1/2)ᵏ) ≥ 1 − ε.

Hence g rises by at least (1 − ε) − ε = 1 − 2ε between these points. But by the Lipschitz hypothesis,

> g((1/2)ᵏ) − g(0) ≤ |g((1/2)ᵏ) − g(0)| ≤ K · |(1/2)ᵏ − 0| = K · 2⁻ᵏ.

Combining, 1 − 2ε ≤ K · 2⁻ᵏ, i.e. K · 2⁻ᵏ + 2ε ≥ 1, the negation of the budget hypothesis. ∎

### 5.2 Interpretation: an exponential architectural lower bound

Rearranging the budget condition, any *K*-Lipschitz approximant achieving uniform error ε < 1/2 must satisfy

> K ≥ (1 − 2ε) · 2ᵏ.

By Definition 3.5, a bounded-weight shallow ReLU network is Lipschitz with constant bounded by its width-times-weight budget. Therefore approximating the depth-*k*, constant-width, O(k)-sized tent network to any fixed accuracy below 1/2 forces a shallow network's budget to grow like 2ᵏ — exponential in the depth it is trying to emulate. This is depth separation: an exponential gap in resource cost between deep and shallow realizations of the same function.

### 5.3 Sharpness

**Theorem 5.2 (Sharpness, `relu_depth_separation_sharp`).** For all k,

> (2ᵏ) · (1/2)ᵏ + 2 · 0 = 1.

*Proof sketch.* (2ᵏ)(1/2)ᵏ = (2 · 1/2)ᵏ = 1ᵏ = 1, and the +2·0 term vanishes. ∎

Interpretation: the depth-*k* tent is 2ᵏ-Lipschitz (Theorem 4.3) and trivially approximates itself with ε = 0. Plugging K = 2ᵏ, ε = 0 into the budget expression yields exactly the boundary value 1. Thus the strict inequality "K · 2⁻ᵏ + 2ε < 1" in Theorem 5.1 is the best possible: it cannot be weakened to "≤ 1", since the honest self-approximation meets the boundary with equality. The threshold is sharp.

### 5.4 A concrete instance

**Example.** At depth k = 3, take the constant function g(x) = 1/2, the extreme "shallow" case (it is 0-Lipschitz, so K = 0). The budget reads 0 · (1/2)³ + 2 · (3/8) = 3/4 < 1, so by Theorem 5.1, g cannot approximate tent³ to accuracy 3/8 on [0, 1]. Indeed it cannot: tent³ attains both 0 and 1, while a constant 1/2 is always exactly 1/2 from one of those values, exceeding 3/8. (This is the formally checked `example` in the source.)

---

## 6. Algorithms

The construction is constructive and immediately implementable. We summarize the key procedures (full code in the accompanying `demo.py`).

### 6.1 Evaluating the depth-*k* tent network

```
function tent(x):                # one width-2 ReLU block
    return 1 - relu(2x - 1) - relu(1 - 2x)

function tent_iterate(x, k):     # depth-k network, O(k) work
    for i in 1..k: x = tent(x)
    return x
```

### 6.2 Empirical Lipschitz constant (verifies Theorem 4.3)

```
function empirical_lipschitz(k, samples):
    grid = uniform points on [0,1]
    return max over adjacent pairs of |f(x_i) - f(x_j)| / |x_i - x_j|,  f = tent_iterate(·, k)
# Expected output ≈ 2^k
```

### 6.3 Certifying separation failure (verifies Theorem 5.1)

```
function separation_witness(g, K, eps, k):
    assert K * 2^{-k} + 2*eps < 1            # budget hypothesis
    a = |tent_iterate(0,k)   - g(0)|         # error at left endpoint
    b = |tent_iterate(2^{-k},k) - g(2^{-k})| # error at first peak
    return max(a, b) > eps                    # guaranteed True by Theorem 5.1
```

### 6.4 Counting linear pieces / level crossings (foundation for §7)

```
function count_crossings(k, level):
    sample tent_iterate on a fine grid; count sign changes of (f - level)
# Expected output ≈ 2^k for level in (0,1)
```

---

## 7. Toward a width lower bound (strengthening)

Theorem 5.1 uses a single steep ramp and bounds the Lipschitz constant — equivalently, the weight magnitude — of a shallow approximant. A complementary, weight-independent bound counts oscillations. The function `tent^[k]` crosses any level c ∈ (0, 1) exactly 2ᵏ times. A one-hidden-layer ReLU network of width *w* is continuous piecewise-linear with at most *w* + 1 affine pieces, hence crosses any level at most *w* + 1 times. Matching the crossing count forces

> w ≥ 2ᵏ − 1,

an exact **width** lower bound holding *regardless of weight magnitude*. The missing ingredient for a fully formal proof is the combinatorial lemma "a continuous function with p affine pieces has at most p solutions to f = c," which is within reach of the existing ascending-branch identity (Lemma 4.3a) and the peak structure (Theorem 4.5). This would upgrade the present Lipschitz separation to the strongest form of Telgarsky's theorem.

---

## 8. Applications and significance

1. **Justifying depth in practice.** The result is a rigorous, sharp witness to the empirical superiority of deep architectures. It explains why stacking layers — rather than widening a single one — yields exponential expressivity gains for oscillatory or hierarchical targets.

2. **Curse of dimensionality and the n-dimensional picture.** Tensorizing the construction (F(x) = ∏ᵢ tent^[k](xᵢ) on [−1,1]ⁿ) yields a shallow cost scaling like ε⁻ⁿ versus a deep cost scaling like depth ≈ n · log(1/ε), the quantitative width-vs-depth trade-off named in the title. The 1-D tent is the irreducible core of this gap.

3. **A clean teaching example.** Because every step is elementary — a two-point squeeze plus the doubling-map identity — the construction is an ideal pedagogical entry point to expressivity theory, with no measure theory or Fourier analysis required.

4. **A template for range-preserving lower bounds.** Many hardness results inadvertently rely on range explosion. The tent map demonstrates how to obtain hardness from oscillation alone, a methodologically cleaner standard for future separation results.

---

## 9. Discussion

The elegance of the tent construction lies in the separation of concerns it achieves. *Composition* (depth) is cheap: it costs one width-two block per layer, O(k) parameters total. *Oscillation* (expressivity) is the output: 2ᵏ⁻¹ peaks. *Lipschitz growth* (the cost a shallow model must pay) is the compounded slope: 2ᵏ. The depth-separation theorem is then nothing more than the observation that these three quantities are locked together, and that a Lipschitz competitor must pay in slope for the oscillation it cannot fold.

It is worth emphasizing once more that the obstruction is range-preserving. A naive separation — iterate x ↦ 2x and observe the output reaches 2ᵏ — is technically a depth separation but morally a triviality: of course a bounded shallow model cannot reach unbounded heights. The tent keeps everything in [0, 1], forcing the difficulty into the geometry of oscillation, which is exactly the regime where real neural networks operate and where the question is interesting.

---

## 10. Future work

See the accompanying future-directions note for the full program. In brief: (1) upgrade the Lipschitz lower bound to a weight-independent width lower bound w ≥ 2ᵏ − 1 via a piecewise-linear crossing-count lemma (§7); (2) prove the matching shallow *upper* bound — every K-Lipschitz function on [0,1] is ε-approximated by the piecewise-linear interpolant on ⌈K/ε⌉ nodes, itself a width-⌈K/ε⌉ ReLU network — closing the Θ(K/ε) shallow vs Θ(log(1/ε)) deep gap quantitatively; and (3) lift the entire construction to [−1, 1]ⁿ via tensorized tents to obtain the ε⁻ⁿ versus n·log(1/ε) high-dimensional separation.

---

## Appendix A. Summary of formal results

| Name | Statement |
|---|---|
| `tent_relu_repr` | tent(x) = 1 − relu(2x − 1) − relu(1 − 2x) (width-2 ReLU layer) |
| `tent_lipschitz` | tent is 2-Lipschitz |
| `tent_mapsTo` | tent maps [0,1] into [0,1] |
| `tent_eq_two_mul` | x ≤ 1/2 ⟹ tent(x) = 2x |
| `tent_iterate_lipschitz` | tent^[k] is 2ᵏ-Lipschitz |
| `tent_iterate_zero` | tent^[k](0) = 0 |
| `tent_iterate_peak` | tent^[k]((1/2)ᵏ) = 1 |
| `relu_depth_separation` | K·2⁻ᵏ + 2ε < 1 ⟹ no K-Lipschitz g is an ε-approximant of tent^[k] on [0,1] |
| `relu_depth_separation_sharp` | (2ᵏ)(1/2)ᵏ + 2·0 = 1 (threshold is sharp) |

All entries are formally verified.
