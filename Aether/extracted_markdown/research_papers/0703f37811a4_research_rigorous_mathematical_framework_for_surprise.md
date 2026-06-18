# Tropical Surprise Theory: A Max-Plus Framework for Incongruity

## Abstract

We develop a rigorous mathematical framework for *surprise* — the cognitive response to expectation violation — grounded in tropical (max-plus) algebra and information theory. The framework introduces three interconnected structures: (1) surprise spaces, where surprise is measured as metric distance from expectation; (2) the surprise spectrum, a novel algebraic structure capturing the distribution of surprise values; and (3) narrative chains, stochastic models of sequential surprise delivery. We prove seven main theorems: the geometric convergence of repeated surprise, Jensen's inequality for surprise, the entropy maximization bound, KL non-negativity (Gibbs' inequality), the novelty-familiarity duality bound, the refinement entropy increase theorem, and the spectral bound relating total to maximum surprise. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords**: tropical algebra, surprise theory, Shannon entropy, KL divergence, convexity, max-plus semiring, narrative chains

---

## 1. Introduction

The mathematical study of surprise dates to Shannon's foundational work on information theory (1948), where the "surprise" or "information content" of an event with probability $p$ is defined as $-\log p$. This definition captures the intuition that rare events are more surprising, and that the surprise of independent events is additive.

However, Shannon's framework treats surprise as a static quantity associated with individual events. It does not address the dynamic aspects of surprise — how surprise evolves over time, how it decays with repetition, or how it is optimized in sequential narrative structures like jokes, stories, and musical compositions.

This paper develops a comprehensive mathematical framework for surprise that addresses these gaps. Our approach synthesizes three mathematical traditions:

1. **Metric geometry**: We model the space of possible outcomes as a metric space, with surprise measured as distance from the expected outcome.

2. **Tropical algebra**: The max-plus semiring $(ℝ, \max, +)$ provides the natural algebraic structure for surprise, where max selects the most surprising interpretation and + composes independent surprises.

3. **Information theory**: Shannon entropy, KL divergence, and the convexity of surprise connect our framework to the classical theory.

### 1.1 Main Results

Our main contributions are:

- **Surprise Decay Theorem** (Theorem 3.1): Repeated exposure causes geometric surprise decay, and the total lifetime surprise converges to $s_0 / (1 - r)$.

- **Jensen's Surprise Inequality** (Theorem 4.1): The convexity of $-\log$ implies that ambiguity reduces surprise.

- **Entropy Maximization** (Theorem 5.1): Shannon entropy is bounded by $\log n$, achieved by the uniform distribution.

- **KL Non-negativity** (Theorem 7.1): The Kullback-Leibler divergence is non-negative (Gibbs' inequality).

- **Novelty-Familiarity Duality** (Theorem 8.1): The product $p \cdot (-\log p) \leq 1/e$ for all $p \in (0, 1]$.

- **Refinement Entropy Increase** (Theorem 9.1): Splitting an outcome into sub-outcomes strictly increases entropy.

- **Spectral Bound** (Theorem 6.1): Total surprise is bounded by cardinality times maximum surprise.

---

## 2. Definitions

### 2.1 Surprise Spaces

**Definition 2.1** (Surprise Space). A *surprise space* is a pair $(α, e)$ where $α$ is a pseudo-metric space and $e ∈ α$ is a distinguished "expected" element. The *surprise value* of $x ∈ α$ is $σ(x) = d(x, e)$.

**Definition 2.2** (Information-Theoretic Surprise). For an event with probability $p > 0$, the *information-theoretic surprise* is $I(p) = -\log_2(p)$.

### 2.2 Surprise Spectrum

**Definition 2.3** (Surprise Spectrum). A *surprise spectrum* over a finite type $α$ is a function $w : α → ℝ_{\geq 0}$ assigning non-negative surprise weights to each outcome. The *total surprise* is $T = \sum_a w(a)$, and the *maximum surprise* (tropical sum) is $M = \max_a w(a)$.

This is a novel concept. The surprise spectrum captures the full distribution of surprise values, not just the expected surprise (entropy) or the maximum surprise. It forms a tropical module: the max operation is the tropical sum, and scaling by a positive constant is the action.

### 2.3 Narrative Chains

**Definition 2.4** (Narrative Chain). A *narrative chain* of order $n$ is a row-stochastic matrix $P \in ℝ^{n \times n}$ with $P_{ij} \geq 0$ and $\sum_j P_{ij} = 1$. The *conditional entropy* from state $i$ is $H(i) = -\sum_j P_{ij} \log P_{ij}$.

### 2.4 KL Divergence

**Definition 2.5** (KL Divergence). For probability distributions $p, q$ on a finite set of size $n$, the *Kullback-Leibler divergence* is $D_{KL}(p \| q) = \sum_i p_i \log(p_i / q_i)$.

---

## 3. Surprise Decay Under Repetition

**Theorem 3.1** (Surprise Decay and Convergence). Let $s_0 > 0$ be the initial surprise and $r \in [0, 1)$ the decay rate. Then:

(a) The surprise after $n$ repetitions is $s(n) = s_0 r^n$, which is monotone non-increasing.

(b) The sequence $(s(n))_{n \geq 0}$ is summable, and $\sum_{n=0}^{\infty} s(n) = s_0 (1 - r)^{-1}$.

*Proof sketch.* Part (a) follows from $r \leq 1$ implying $r^{n+1} \leq r^n$ and the non-negativity of $s_0$. Part (b) is the geometric series formula. The formal proof uses `summable_geometric_of_lt_one` and `tsum_geometric_of_lt_one` from Mathlib. □

**Corollary 3.2.** Novelty is a finite resource: no joke can deliver more than $s_0 / (1 - r)$ total surprise across all repetitions.

---

## 4. Jensen's Surprise Inequality

**Theorem 4.1** (Convexity of Surprise). The function $f(p) = -\log p$ is convex on $(0, \infty)$. Consequently, for any $p, q > 0$ and $t \in [0, 1]$:
$$-\log(tp + (1-t)q) \leq -t \log p - (1-t) \log q$$

*Proof sketch.* The convexity of $-\log$ follows from the strict concavity of $\log$ on $(0, \infty)$ (proved via the second derivative $-1/x^2 < 0$). The inequality is then a direct application of the definition of convexity. The formal proof uses `strictConcaveOn_log_Ioi` from Mathlib and negates. □

**Interpretation.** Averaging over interpretations reduces surprise. The most surprising response to ambiguity is to commit to a single interpretation — which is precisely what effective comedy does.

---

## 5. Entropy Maximization

**Theorem 5.1** (Entropy Bound). For any probability distribution $p = (p_1, \ldots, p_n)$ with all $p_i > 0$ and $\sum p_i = 1$:
$$H(p) = -\sum_{i=1}^n p_i \log p_i \leq \log n$$

Equality holds if and only if $p$ is the uniform distribution.

*Proof sketch.* Apply Jensen's inequality to the concave function $\log$ with weights $p_i$ and arguments $1/p_i$:
$$\sum p_i \log(1/p_i) \leq \log\left(\sum p_i \cdot \frac{1}{p_i}\right) = \log(n)$$

The formal proof constructs this argument using `ConcaveOn.le_map_sum` applied to `strictConcaveOn_log_Ioi`. □

---

## 6. The Surprise Spectrum

**Theorem 6.1** (Spectral Bound). For any surprise spectrum $w$ on a finite nonempty type $α$:
$$\sum_a w(a) \leq |α| \cdot \max_a w(a)$$

**Theorem 6.2** (Average-Max Inequality). The average surprise never exceeds the maximum:
$$\frac{1}{|α|} \sum_a w(a) \leq \max_a w(a)$$

**Theorem 6.3** (Spectrum Witness). The maximum surprise is always attained:
$$\exists a^* : w(a^*) = \max_a w(a) \wedge \forall b : w(b) \leq w(a^*)$$

*Proof sketch.* Theorem 6.1 follows from replacing each weight with the maximum. Theorem 6.2 divides both sides by $|α|$. Theorem 6.3 uses the finite supremum attainment lemma. □

**Remark.** The spectral bound connects to tropical algebra: the total surprise (classical sum) is bounded by the product (in the tropical sense: the sum of the cardinality and the tropical sum/max).

---

## 7. KL Divergence

**Theorem 7.1** (Gibbs' Inequality). For probability distributions $p, q$ on $\{1, \ldots, n\}$ with all entries positive:
$$D_{KL}(p \| q) \geq 0$$

*Proof sketch.* Use the fundamental inequality $\log x \leq x - 1$ for all $x > 0$. Applied to $x = q_i / p_i$:
$$\log(q_i/p_i) \leq q_i/p_i - 1$$
Multiplying by $p_i$ and summing:
$$\sum p_i \log(q_i/p_i) \leq \sum q_i - \sum p_i = 0$$
Since $D_{KL}(p \| q) = -\sum p_i \log(q_i/p_i)$, we get $D_{KL}(p \| q) \geq 0$. □

**Theorem 7.2** (KL Self-Divergence). $D_{KL}(p \| p) = 0$ for any distribution $p$.

---

## 8. Novelty-Familiarity Duality

**Theorem 8.1** (Novelty-Familiarity Bound). For all $p \in (0, 1]$:
$$p \cdot (-\log p) \leq \frac{1}{e}$$

*Proof sketch.* The function $f(p) = -p \log p$ has $f'(p) = -\log p - 1 = 0$ at $p = 1/e$, and $f''(p) = -1/p < 0$, so $p = 1/e$ is a global maximum on $(0, 1]$. The maximum value is $(1/e) \cdot 1 = 1/e$. The formal proof uses the inequality $\log x \leq x - 1$ applied to $x = 1/(ep)$, then algebraic manipulation with `nlinarith`. □

**Interpretation.** Events with probability $1/e \approx 0.37$ maximize the surprise-familiarity product. This is the "sweet spot" where events are common enough to be recognized but rare enough to be surprising.

---

## 9. Refinement and Entropy Increase

**Theorem 9.1** (Refinement Increases Entropy). If $p_1, p_2 > 0$ and $p = p_1 + p_2$, then:
$$-p \log p \leq -p_1 \log p_1 - p_2 \log p_2$$

*Proof sketch.* Since $p = p_1 + p_2 \geq p_1$ and $p \geq p_2$, we have $\log p \geq \log p_1$ and $\log p \geq \log p_2$. Therefore:
$$p_1 \log p_1 + p_2 \log p_2 \leq p_1 \log p + p_2 \log p = (p_1 + p_2) \log p = p \log p$$
Negating gives the result. □

**Interpretation.** Refining an outcome (adding more specific sub-possibilities) always increases the potential for surprise. This explains why specificity enhances humor and narrative impact.

---

## 10. Narrative Chains

**Theorem 10.1** (Conditional Entropy Non-negativity). For a narrative chain $M$ with all-positive transitions, the conditional entropy from any state $i$ is non-negative: $H(i) \geq 0$.

**Theorem 10.2** (Conditional Entropy Bound). $H(i) \leq \log n$ for all states $i$.

*Proof sketch.* Non-negativity follows because each term $-P_{ij} \log P_{ij}$ is non-negative when $0 < P_{ij} \leq 1$. The upper bound follows from Theorem 5.1 applied to the row $(P_{i1}, \ldots, P_{in})$. □

---

## 11. The Tropical Structure

The surprise framework naturally forms a tropical (max-plus) algebraic structure:

- **Tropical sum** $a \oplus b = \max(a, b)$: selects the most surprising interpretation.
- **Tropical product** $a \odot b = a + b$: composes independent surprises.

**Theorem 11.1** (Max-Plus Distributivity). $\max(a, b) + c = \max(a + c, b + c)$.

**Theorem 11.2** (Surprise Dominance). $\max(a, b) \geq (a + b) / 2$.

**Theorem 11.3** (Surprise Additivity). $I(pq) = I(p) + I(q)$ for independent events.

These three results establish that the tropical semiring is the natural algebraic setting for surprise theory: max selects the funniest interpretation, addition composes independent surprises, and distributivity ensures consistency.

---

## 12. Algorithms

### 12.1 Optimal Surprise Allocation

Given a budget of total surprise $T$ to distribute across $n$ jokes, the entropy-maximizing allocation is the uniform distribution $s_i = T/n$. This follows from the entropy maximization theorem (Theorem 5.1) applied to the "surprise distribution" normalized to probabilities.

### 12.2 Surprise Decay Prediction

For a joke with initial surprise $s_0$ and estimated decay rate $r$, the total lifetime value is $s_0/(1-r)$. The half-life (number of repetitions to reduce surprise by half) is $n_{1/2} = -\log 2 / \log r$.

### 12.3 Novelty-Familiarity Optimization

To maximize impact $p \cdot I(p)$, set $p = 1/e$. In practical terms, structure jokes so that the punchline type occurs about 37% of the time in the audience's mental model.

---

## 13. Discussion

### 13.1 Connections to Existing Work

Our framework connects to several established mathematical traditions:

- **Shannon's information theory** (1948): Our information-theoretic surprise $I(p) = -\log p$ is Shannon's "surprisal." Our entropy bound (Theorem 5.1) is a reformulation of Shannon's maximum entropy principle.

- **Tropical geometry**: The max-plus algebra on surprise values connects to the tropical semiring studied in algebraic geometry and optimization. The surprise spectrum is a tropical module.

- **Incongruity-resolution theory** (Suls 1972): The framework formalizes the observation that humor = incongruity - resolution through metric distance.

### 13.2 Limitations

The framework assumes:
- A fixed metric on the outcome space (the "comedy universe" is predetermined).
- Multiplicative decay (repeated exposure always reduces surprise by a fixed fraction).
- Independence of surprises in the composition theorem.

Real cognitive surprise likely involves non-stationary metrics, variable decay rates, and complex interactions between sequential surprises.

### 13.3 Falsifiable Predictions

**Conjecture 13.1** (Optimal Callback Spacing). In a comedy routine of length $L$ jokes, the optimal number of callbacks (repeated references) to a running gag is approximately $\lceil \log_r(1/2) \rceil$, where $r$ is the audience-specific decay rate. This predicts that callbacks should be spaced further apart for audiences with faster decay rates (more sophisticated audiences).

This conjecture is testable: measure surprise responses (e.g., galvanic skin response, laugh intensity) across multiple repetitions of a joke element and fit the geometric decay model to estimate $r$. Then verify that actual professional comedy routines space callbacks optimally with respect to the estimated $r$.

---

## 14. Future Work

1. **Tropical Hilbert spaces**: Extend the surprise spectrum to an inner product structure, where $\langle w_1, w_2 \rangle = \max_a (w_1(a) + w_2(a))$ measures comedic compatibility.

2. **Spectral theory of narrative chains**: Study the eigenvalues of narrative transition matrices and their relationship to emotional trajectories.

3. **Non-commutative surprise**: Model situations where the order of surprises matters (setup-punchline ordering effects).

4. **Continuous narrative flows**: Replace discrete narrative chains with continuous-time Markov processes and study the resulting entropy rate.

---

## References

1. Shannon, C.E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27(3), 379–423.

2. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.

3. Cover, T.M. & Thomas, J.A. (2006). *Elements of Information Theory*. 2nd ed. Wiley.

4. Suls, J.M. (1972). A two-stage model for the appreciation of jokes and cartoons. In *The Psychology of Humor*, Academic Press.

5. Hurley, M.M., Dennett, D.C., & Adams, R.B. (2011). *Inside Jokes: Using Humor to Reverse-Engineer the Mind*. MIT Press.
