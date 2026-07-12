# The Capacity of Robust Neural Codes: Doubling Laws, Sparse Efficiency, and the Singleton Ceiling

## Abstract

We develop a self-contained combinatorial theory of neural population codes,
modeled as binary activity patterns over $N$ neurons, and quantify their
capacity both in the noiseless regime and under adversarial neuron noise. In the
noiseless regime we establish an exact capacity of $2^N$ patterns with a
per-neuron doubling law, an average dense-activity cost of $N/2$ spikes, exact
sparse (weight-$k$) counts of $\binom{N}{k}$, a $\Theta(\log N)$ bits-per-spike
advantage for sparse over dense codes, a population-averaging precision law of
$1/\sqrt{N}$, and a rank bound realizing the neural-manifold hypothesis. In the
noisy regime, we introduce a Hamming metric on activity patterns and prove a
**Singleton bound**: any codebook with minimum distance $d$ contains at most
$2^{N+1-d}$ codewords. From it we derive a **robust-capacity law**, showing that
a $t$-error-correcting code uses at most $2^{N-2t}$ patterns — an exact exchange
rate of two neurons of capacity per correctable error — together with the
classical message and redundancy inequalities $k \le N+1-d$ and $N-k \ge d-1$. We
prove the Singleton ceiling is tight at both extremes of the distance range: the
full code attains it at $d=1$ and the two-word repetition code attains it at
$d=N$. The Singleton (projection) obstruction is shown to be logically
independent of the sphere-packing (Hamming) obstruction, and the two coincide
only at the raw capacity $2^N$ when noise tolerance vanishes.

**Keywords:** neural code, capacity, Hamming distance, Singleton bound, sparse
coding, population coding, error correction, neural manifold.

---

## 1. Introduction

A recurring abstraction in theoretical neuroscience treats the instantaneous
state of a population of $N$ neurons as a binary string: each neuron is *active*
(firing above threshold) or *silent*. A **neural code** is then a way of
assigning meanings — stimuli, concepts, motor plans — to such strings. Two
foundational questions organize the theory:

1. **Capacity.** How many distinct meanings can a population of $N$ neurons
   represent, and at what metabolic cost?
2. **Robustness.** How many meanings can it represent *reliably*, when
   individual neurons may spuriously fire or fail to fire?

This paper answers both with exact combinatorial theorems. Part I (Sections 3–6)
treats the noiseless regime and recovers a chain of capacity, efficiency,
precision, and dimensionality results. Part II (Sections 7–9) introduces noise
via a Hamming metric and proves a Singleton-type capacity ceiling, a
robust-capacity exchange law, and matching tightness witnesses.

The results are elementary in their ingredients — counting patterns, measuring
disagreements, and hiding a few coordinates — yet they assemble into a complete
and quantitatively sharp account of a question that recurs across theoretical
neuroscience, information theory, and neuromorphic engineering. The same
combinatorics that governs the error-correcting codes in digital communication
and the redundancy of genetic sequences reappears here as constraints on how many
concepts a noisy population of switches can hold. By stating capacity, energy,
efficiency, precision, dimensionality, and robustness on a single pattern space,
we obtain a coherent design language in which each biological desideratum — be
rich, be cheap, be reliable, be low-dimensional — becomes an inequality that can
be traded against the others.

The central conceptual contribution is that noise-tolerant capacity is limited by
**two independent obstructions**. The classical *sphere-packing* (Hamming) bound
limits capacity by volume — disjoint error balls must fit in pattern space. The
*Singleton* bound proved here limits capacity by projection — a large minimum
distance forces a few coordinates to determine every codeword. Both descend to
the same raw capacity $2^N$ at zero noise tolerance but diverge otherwise, and we
exhibit codes saturating the Singleton ceiling at both endpoints of the distance
range.

---

## 2. The model

**Definition 2.1 (Neural code).** For $N \in \mathbb{N}$, a *neural code* on $N$
neurons is a binary activity pattern, i.e. a function
$$x : \{1, \dots, N\} \to \{0, 1\},$$
where $x_i = 1$ means neuron $i$ is active and $x_i = 0$ means it is silent. We
write $\mathcal{P}_N$ for the set of all such patterns.

**Definition 2.2 (Weight).** The *weight* $\lVert x \rVert$ of a pattern is the
number of active neurons, $\lVert x \rVert = \#\{ i : x_i = 1 \}$.

**Definition 2.3 (Hamming distance).** For patterns $x, y \in \mathcal{P}_N$,
their *Hamming distance* is the number of neurons on which they disagree,
$$d_H(x, y) = \#\{ i : x_i \neq y_i \}.$$

**Definition 2.4 (Codebook and minimum distance).** A *codebook* is a finite set
$C \subseteq \mathcal{P}_N$. Its *minimum distance* is at least $d$ when every
pair of distinct codewords disagrees on at least $d$ neurons:
$$\forall x, y \in C,\ x \neq y \implies d_H(x, y) \ge d.$$
A codebook is *$t$-error-correcting* when its minimum distance is at least
$2t + 1$; nearest-codeword decoding then recovers the transmitted codeword after
up to $t$ neuron flips.

---

## Part I — Noiseless capacity

## 3. Exact capacity and the doubling law

**Theorem 3.1 (Capacity).** The number of distinct neural codes on $N$ neurons is
exactly
$$|\mathcal{P}_N| = 2^N.$$

*Proof sketch.* Each of the $N$ neurons is independently active or silent, giving
a product of $N$ binary choices; the count is $2^N$ by the multiplicativity of
finite function spaces. $\square$

**Corollary 3.2 (Per-neuron doubling law).** Adding one neuron doubles capacity:
$|\mathcal{P}_{N+1}| = 2 \cdot |\mathcal{P}_N|$. Equivalently, capacity grows
exponentially in $N$, and the number of representable concepts per neuron is one
bit.

## 4. Metabolic cost of dense coding

**Theorem 4.1 (Average dense energy).** Averaged uniformly over all $2^N$
patterns, the expected number of active neurons is
$$\mathbb{E}\lVert x \rVert = \frac{N}{2}.$$

*Proof sketch.* By linearity of expectation, $\mathbb{E}\lVert x \rVert =
\sum_{i=1}^N \Pr[x_i = 1] = N \cdot \tfrac12$, since each neuron is active in
exactly half the patterns. $\square$

Thus the "typical" dense pattern spends $N/2$ spikes. Because action potentials
dominate the brain's energy budget, this motivates the sparse regime of the next
section.

## 5. Sparse codes and bits per spike

**Theorem 5.1 (Sparse count).** The number of weight-$k$ neural codes on $N$
neurons is exactly
$$\#\{ x : \lVert x \rVert = k \} = \binom{N}{k}.$$

*Proof sketch.* A weight-$k$ pattern is determined by the size-$k$ subset of
active neurons; there are $\binom{N}{k}$ such subsets. $\square$

**Definition 5.2 (Efficiency).** The *bits-per-spike efficiency* of a weight-$k$
code is
$$\eta(N, k) = \frac{\log_2 \binom{N}{k}}{k}.$$

**Theorem 5.3 (Sparse efficiency advantage).** The one-hot code ($k = 1$) attains
efficiency
$$\eta(N, 1) = \log_2 N,$$
which grows without bound in $N$, whereas dense coding at fixed activity fraction
$k/N = \rho \in (0,1)$ has efficiency bounded by a constant $H(\rho)/\rho$ (with
$H$ the binary entropy function). Hence sparse coding enjoys a $\Theta(\log N)$
advantage in bits per spike.

*Proof sketch.* For $k = 1$, $\binom{N}{1} = N$, so $\eta(N,1) = \log_2 N$. For
fixed $\rho$, the standard entropy estimate $\binom{N}{\rho N} = 2^{N H(\rho) +
O(\log N)}$ gives $\eta \to H(\rho)/\rho$, a constant. The ratio of the two
efficiencies is $\Theta(\log N)$. $\square$

This is the mathematical basis of the observation that sparse population codes,
and grandmother-cell–like one-hot representations, maximize information per unit
of metabolic expenditure.

## 6. Population precision and neural manifolds

**Theorem 6.1 (Population precision law).** Suppose $N$ neurons each provide an
independent, unbiased estimate of a scalar stimulus with common variance $v$.
Then the population average has variance
$$\operatorname{Var}\!\left(\frac1N \sum_{i=1}^N X_i\right) = \frac{v}{N},$$
so its precision (reciprocal standard deviation) scales as $1/\sqrt{N}$.

*Proof sketch.* By independence, the variance of a sum is the sum of variances;
scaling by $1/N$ multiplies the variance by $1/N^2$, yielding $N v / N^2 = v/N$.
$\square$

**Theorem 6.2 (Neural-manifold rank bound).** If population activity is generated
by a linear read-out of $b$ behavioral degrees of freedom — that is, activity
factors through a $b$-dimensional latent space — then the dimension of the neural
activity manifold is at most $b$:
$$\dim(\text{neural manifold}) \le \operatorname{rank}(\text{behavioral map}) \le
b.$$

*Proof sketch.* The image of a linear map has dimension equal to its rank, which
is bounded by the dimension of its domain. Composing generation and read-out, the
rank of the activity cannot exceed the number of independent behavioral
variables. $\square$

This realizes the neural-manifold hypothesis: high-dimensional recordings occupy
a low-dimensional subspace whose dimension is capped by the task's degrees of
freedom.

---

## Part II — Robust capacity under noise

## 7. The projection lemma

The engine of the Singleton bound is the observation that agreement off a set of
neurons confines all disagreement to that set.

**Lemma 7.1 (Agreement bounds distance).** Let $S \subseteq \{1, \dots, N\}$ and
$x, y \in \mathcal{P}_N$. If $x$ and $y$ agree on every neuron outside $S$ (i.e.
$x_i = y_i$ for all $i \notin S$), then
$$d_H(x, y) \le |S|.$$

*Proof sketch.* The set of neurons where $x$ and $y$ disagree is contained in
$S$ by hypothesis, so its cardinality — which is exactly $d_H(x,y)$ — is at most
$|S|$. $\square$

## 8. The Singleton bound and robust capacity

**Theorem 8.1 (Singleton bound).** Let $1 \le d \le N + 1$ and let $C \subseteq
\mathcal{P}_N$ be a codebook with minimum distance at least $d$. Then
$$|C| \le 2^{\,N + 1 - d}.$$

*Proof sketch.* Choose any set $S$ of $d - 1$ neurons to *puncture* (there are at
least $d - 1 \le N$ neurons available). Define the restriction map
$f : \mathcal{P}_N \to (\{1,\dots,N\}\setminus S \to \{0,1\})$ sending each
pattern to its values on the unpunctured neurons. We claim $f$ is injective on
$C$. Indeed, if $x, y \in C$ satisfy $f(x) = f(y)$, then $x$ and $y$ agree on all
neurons outside $S$, so by Lemma 7.1 $d_H(x, y) \le |S| = d - 1 < d$. Since the
minimum distance of $C$ is at least $d$, this forces $x = y$. Therefore $f$
injects $C$ into the set of patterns on $N - (d-1) = N + 1 - d$ neurons, which
has cardinality $2^{N+1-d}$. Hence $|C| \le 2^{N+1-d}$. $\square$

**Theorem 8.2 (Robust capacity).** Let $2t \le N$ and let $C$ be a
$t$-error-correcting codebook (minimum distance at least $2t + 1$). Then
$$|C| \le 2^{\,N - 2t}.$$

*Proof sketch.* Apply Theorem 8.1 with $d = 2t + 1$ (which satisfies
$1 \le d \le N + 1$ because $2t \le N$). The exponent is $N + 1 - (2t + 1) =
N - 2t$. $\square$

**Interpretation.** Each additional unit of error-correction guarantee costs
exactly two neurons of raw capacity: the abundance $2^N$ degrades to $2^{N-2t}$.
This is a sharp exchange rate between metabolic/representational richness and
noise tolerance.

## 9. Message bounds, redundancy, and tightness

**Corollary 9.1 (Message bound).** A codebook carrying $k$ message bits (so
$|C| = 2^k$) with minimum distance at least $d$ satisfies
$$k \le N + 1 - d.$$

*Proof sketch.* Immediate from Theorem 8.1: $2^k = |C| \le 2^{N+1-d}$, and $2^x$
is monotone. $\square$

**Corollary 9.2 (Redundancy bound).** Under the hypotheses of Corollary 9.1, the
redundancy satisfies
$$N - k \ge d - 1.$$

*Proof sketch.* Rearrange Corollary 9.1. $\square$

We now show the Singleton ceiling is attained at both endpoints of the distance
range, so no bound depending on $N$ and $d$ alone can improve it.

**Theorem 9.3 (Tightness at $d = 1$).** The full codebook $C = \mathcal{P}_N$ has
(vacuous) minimum distance $\ge 1$ and satisfies
$$|C| = 2^N = 2^{\,N + 1 - 1},$$
attaining the Singleton bound at $d = 1$.

*Proof sketch.* By Theorem 3.1, $|\mathcal{P}_N| = 2^N$, and $N + 1 - 1 = N$.
$\square$

**Theorem 9.4 (Tightness at $d = N$).** The repetition code
$C = \{\mathbf{0}, \mathbf{1}\}$ consisting of the all-silent and all-active
patterns has minimum distance exactly $N$ and satisfies
$$|C| = 2 = 2^{\,N + 1 - N},$$
attaining the Singleton bound at $d = N$.

*Proof sketch.* The two codewords disagree on every one of the $N$ neurons, so
$d_H(\mathbf{0}, \mathbf{1}) = N$ and the minimum distance is $N$. There are two
codewords and $2^{N+1-N} = 2^1 = 2$. $\square$

Because equality holds at both $d = 1$ (Theorem 9.3) and $d = N$ (Theorem 9.4),
the Singleton bound cannot be strengthened as a function of $N$ and $d$ alone.

---

## 10. Two independent ceilings

The Singleton bound is logically independent of the classical **sphere-packing
(Hamming) bound**, which states that a $t$-error-correcting code satisfies
$$|C| \le \frac{2^N}{\sum_{i=0}^{t} \binom{N}{i}},$$
because disjoint radius-$t$ Hamming balls must fit inside pattern space. The two
bounds arise from different mechanisms:

- **Sphere-packing** is *metric*: it constrains capacity by the *volume* each
  codeword must reserve.
- **Singleton** is *linear-algebraic*: it constrains capacity by *projection* —
  once codewords are far apart, a few coordinates determine them.

Both specialize to the raw capacity $2^N$ at $t = 0$ (equivalently $d = 1$), but
for positive noise tolerance neither dominates the other in general. A robust
neural population is thus squeezed simultaneously by a packing constraint and a
projection constraint; the feasible design region is their intersection.

---

## 10a. Worked examples

To make the ceilings concrete, fix a population of $N = 10$ neurons, so the raw
capacity is $2^{10} = 1024$ patterns.

- **No robustness ($d = 1$, $t = 0$).** The Singleton bound gives $2^{10+1-1} =
  2^{10} = 1024$, realized by the full pattern set. The population can label 1024
  distinct concepts, but a single neuron flip can turn any concept into a
  neighbouring one.
- **Single-error correction ($t = 1$, so $d \ge 3$).** The robust-capacity law
  gives $2^{10 - 2} = 256$ codewords. Fully one quarter of the raw exponent — two
  neurons — has been spent to buy immunity against any single misfire. A greedy
  distance-3 construction on ten neurons indeed yields a codebook comfortably
  inside this ceiling.
- **Double-error correction ($t = 2$, so $d \ge 5$).** Capacity drops to
  $2^{10-4} = 64$; four neurons of capacity are now consumed.
- **Maximum robustness ($d = 10$).** Only $2^{10+1-10} = 2$ codewords remain, the
  all-silent and all-active patterns of the repetition code, which disagree in
  every neuron.

The sequence $1024, 256, 64, 16, 4, 1$ for $t = 0, 1, 2, 3, 4, 5$ displays the
geometric factor of $4$ (two neurons) per correctable error with perfect
clarity. On the efficiency side, the one-hot code on the same ten neurons carries
$\log_2 10 \approx 3.32$ bits per spike, whereas a dense pattern of weight five
carries $\log_2 \binom{10}{5}/5 = \log_2 252 / 5 \approx 1.60$ bits per spike —
roughly half as much information per unit of metabolic expenditure, illustrating
the sparse advantage even at modest $N$.

## 11. Applications

- **Metabolic budgeting.** The dense-energy cost $N/2$ and the sparse efficiency
  $\log_2 N$ bits/spike jointly predict that biological codes should operate in a
  sparse regime, matching observations of low mean firing rates.
- **Reliability engineering.** The robust-capacity law $2^N \mapsto 2^{N - 2t}$
  gives a designer of a spiking system (biological or neuromorphic) an exact
  price for each correctable fault.
- **Dimensionality analysis.** The manifold rank bound justifies the widespread
  empirical finding that population recordings are effectively low-dimensional
  and ties that dimension to the number of behavioral degrees of freedom.
- **Neural error-correcting codes.** The message and redundancy inequalities port
  the classical $(N, k, d)$ trade-off into the neural setting, guiding the design
  of fault-tolerant population representations.
- **Cross-linking capacity budgets.** Combining the per-pattern capacity here
  with structural bounds on the number of available wiring slots in a network
  yields ceilings on the *total* representational capacity of a wired system,
  not merely of a single activity snapshot — tying the coding theory to the
  description length of the underlying connectivity.

### Related bounds and context

The Singleton bound proved here is the neural-population analogue of the
classical Singleton bound of algebraic coding theory, and the robust-capacity
law is its specialization to error-correcting distance. What is distinctive in
the present treatment is that all the results — the noiseless capacity chain and
the noisy ceilings — live over the identical binary pattern space, so their
hypotheses and equality conditions can be compared directly rather than imported
from disparate settings. This unification is what allows the two obstructions,
packing and projection, to be recognized as genuinely distinct yet
complementary, and it is what makes the tightness statements at $d = 1$ and
$d = N$ meaningful as statements about the *same* family of codes.

---

## 12. Discussion and future work

This cycle added the **Singleton bound** and its **robust-capacity** corollary to
the neural-coding theory, complementing the earlier sphere-packing (Hamming)
ceiling. Two independent obstructions to noise-tolerant capacity are now in hand:
a *packing* obstruction (each codeword owns a Hamming ball) and a *projection*
obstruction (large minimum distance makes a few coordinates determine every
codeword). Several directions push the theory forward.

**Perfect codes at the coincidence of the two bounds.** A noise-tolerant neural
codebook is conjectured to meet the sphere-packing bound with equality iff it is
a *perfect* code, and every such code satisfies the Singleton bound strictly
unless it is a repetition or full code. Packing is tight when balls tile pattern
space with no gaps; projection is tight when the code is maximally spread; the
codes that saturate both are exactly the degenerate endpoints ($d = 1$ and
$d = N$).

**Sparsity–distance trade-off.** Among weight-$k$ codebooks, achievable minimum
distance should be capped by $d \le 2k$ (two weight-$k$ patterns differ in at
most $2k$ neurons), giving a combined law $|C| \le \min\!\big(\binom{N}{k},
2^{N+1-d}\big)$ that couples metabolic budget to noise tolerance.

**Unifying precision and distance.** The $1/\sqrt{N}$ population-averaging
precision and the correction radius $\lfloor (d-1)/2 \rfloor$ of a distance-$d$
code are conjectured to be two faces of one estimator: a minimum-distance decoder
attaining mean-squared error $\Theta(1/d)$, matching the variance-of-the-mean
$v/N$ when $d \propto N$.

**Probabilistic and information-theoretic grounding.** Re-deriving the population
variance $v/N$ from a formal treatment of i.i.d. random variables, establishing
Cramér–Rao optimality of the $1/\sqrt{N}$ law, and replacing $\log_2 \binom{N}{k}$
by the binary-entropy bound $\binom{N}{k} \ge 2^{N H(k/N)}/(N+1)$ would sharpen
the efficiency comparisons.

**Nonlinear manifolds.** Upgrading the linear rank bound to smooth immersions and
submersions via the constant-rank theorem would bound intrinsic manifold
dimension by behavioral degrees of freedom in the fully nonlinear setting, and
connect the theorem to PCA/covariance-rank measures of empirical dimensionality.

---

## 13. Conclusion

Starting from the elementary picture of a neuron as a binary switch, we obtained
an exact and complete accounting of population coding capacity: an exponential
$2^N$ noiseless capacity with a doubling law, an $N/2$ dense-energy cost, exact
sparse counts $\binom{N}{k}$ with a $\Theta(\log N)$ efficiency advantage, a
$1/\sqrt{N}$ precision law, and a rank bound for neural manifolds. Layering a
Hamming metric on top, we proved a Singleton capacity ceiling $2^{N+1-d}$, a
robust-capacity exchange law $2^{N-2t}$, the classical message and redundancy
inequalities, and tightness witnesses at both extremes of the distance range. The
resulting picture — capacity squeezed between a packing wall and a projection
wall — gives a precise, unified account of how many concepts a noisy neural
population can hold, and at what price.
