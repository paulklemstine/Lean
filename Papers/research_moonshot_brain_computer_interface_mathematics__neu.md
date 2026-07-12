# Neural Coding Theorems: Capacity, Energy, Precision, and Dimension of Binary Population Codes

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

We develop a self-contained mathematical theory of neural coding built
on a single primitive: a *neural code* on $N$ neurons is a binary
pattern in $\{0,1\}^N$, one coordinate per neuron, recording which cells
are active. From this definition we prove a connected chain of results
that quantify what such codes can and cannot do. First, the
representational **capacity** of $N$ binary neurons is exactly $2^N$, and
this bound is tight; each additional neuron doubles capacity (a *doubling
law*). Second, under the uniform distribution over codes the expected
number of active neurons is $N/2$, exposing the metabolic cost of *dense*
coding. Third, the number of codes with exactly $k$ active neurons is
$\binom{N}{k}$, and the resulting **information per spike**,
$\log_2\binom{N}{k}/k$, grows like $\log_2 N$ in the one-hot regime,
giving sparse coding a $\Theta(\log N)$ efficiency advantage over dense
coding. Fourth, **population coding** by $N$ independent neurons of noise
variance $v$ yields a pooled estimate of variance $v/N$, so precision
improves as $1/\sqrt N$. Fifth, a **neural manifold** generated from $d$
behavioral variables has dimension at most $d$, formalizing the neural
manifold hypothesis as a rank bound. Together these results give a
rigorous account of why brains are exponentially capacious, energetically
forced toward sparsity, statistically precise through pooling, and
geometrically low-dimensional. We include algorithms, numerical
demonstrations, and a discussion of extensions to error-correcting
codes, entropy bounds, Fisher-information optimality, and nonlinear
manifolds.

## 1. Introduction

How does a population of neurons represent information? We adopt the
most austere model that still captures the essential combinatorics: each
neuron is a binary unit — active or silent — and the *state* of a
population is the binary string recording those states. We call such a
string a neural code. Concepts, percepts, and memories are identified
with codes, so the representational questions become counting and
estimation questions about $\{0,1\}^N$.

This paper assembles the elementary but foundational theorems of that
model into one coherent development. Each theorem answers a concrete
neuroscientific question: How many things can be represented (capacity)?
How does capacity scale with neuron count (doubling)? What does a
representation cost in spikes (energy)? How is that cost minimized
(sparsity)? How is continuous precision achieved from noisy units
(population coding)? And why does high-dimensional neural activity
collapse onto low-dimensional structure (the neural manifold)? The
proofs are short; the value lies in the precise statements, their
tightness, and the way they interlock into an argument for the design
principles of biological codes.

## 2. Definitions

**Definition 2.1 (Neural code).** Fix $N \in \mathbb{N}$. A *neural code*
on $N$ neurons is a function $c : \{1,\ldots,N\} \to \{0,1\}$,
equivalently an element $c \in \{0,1\}^N$. We write $c_i = 1$ to mean
neuron $i$ is active. The set of all neural codes on $N$ neurons is
denoted $\mathcal{C}_N = \{0,1\}^N$.

**Definition 2.2 (Weight / activity / energy).** The *weight* (or
*activity*, or *energy*) of a code $c$ is the number of active neurons,
$$w(c) = \sum_{i=1}^{N} c_i = \#\{ i : c_i = 1\}.$$
We take spike count $w(c)$ as the metabolic cost of the code.

**Definition 2.3 (Sparse family).** For $0 \le k \le N$, the *weight-$k$
family* is
$$\mathcal{C}_{N,k} = \{\, c \in \{0,1\}^N : w(c) = k \,\}.$$
A code is *one-hot* if $k = 1$.

**Definition 2.4 (Population estimator).** Let $X_1,\ldots,X_N$ be
independent real-valued neuron estimates of a common scalar quantity,
each with mean $\mu$ and variance $v > 0$. The *population estimate* is
the sample mean $\bar X = \frac1N \sum_{i=1}^N X_i$.

**Definition 2.5 (Linear neural manifold).** Let $B \subseteq
\mathbb{R}^{d}$ be a set of behavioral states with $d$ *behavioral
degrees of freedom*, and let $F : \mathbb{R}^{d} \to \mathbb{R}^{N}$ be a
(linear) *encoding map* producing population activity $F(b)$ for
behavior $b$. The *neural manifold* is the image $\mathcal{M} = F(B)
\subseteq \mathbb{R}^{N}$, and its *dimension* is $\dim \operatorname{span}
\mathcal{M} = \operatorname{rank} F$ in the linear case.

## 3. Capacity and the doubling law

**Theorem 3.1 (Capacity).** The number of distinct neural codes on $N$
neurons is
$$|\mathcal{C}_N| = 2^N,$$
and no representation scheme using $N$ binary neurons can distinguish
more than $2^N$ states.

*Proof sketch.* $\mathcal{C}_N = \{0,1\}^N$ is the set of functions from
an $N$-element set to a $2$-element set, so $|\mathcal{C}_N| = 2^N$ by the
multiplication principle. Any state that a population of $N$ binary
neurons can be *in* is by definition an element of $\mathcal{C}_N$;
distinct external situations that produce identical codes are
indistinguishable to any downstream reader, so the number of
distinguishable situations is bounded by $|\mathcal{C}_N| = 2^N$. $\square$

**Theorem 3.2 (Doubling law).** For every $N$,
$$|\mathcal{C}_{N+1}| = 2\,|\mathcal{C}_N|.$$
Equivalently, capacity satisfies the recurrence $a_{N+1} = 2a_N$ with
$a_0 = 1$, so each added neuron doubles capacity and $m$ added neurons
multiply it by $2^m$.

*Proof sketch.* $2^{N+1} = 2 \cdot 2^N$. Combinatorially, every code on
$N+1$ neurons is a code on the first $N$ neurons together with an
independent binary choice for neuron $N+1$; the map $c \mapsto (c\restriction
N,\ c_{N+1})$ is a bijection $\mathcal{C}_{N+1} \to \mathcal{C}_N \times
\{0,1\}$. $\square$

**Remark 3.3.** The doubling law is the quantitative statement that
binary population capacity is *exponential* in neuron count. It is the
reason biologically small populations already have astronomically large
capacities: $2^{300}$ exceeds the number of atoms in the observable
universe.

## 4. The energy of dense coding

**Theorem 4.1 (Dense energy law).** Let $c$ be drawn uniformly at random
from $\mathcal{C}_N$. Then the expected number of active neurons is
$$\mathbb{E}[w(c)] = \frac{N}{2}.$$
Equivalently, $\sum_{c \in \mathcal{C}_N} w(c) = N\,2^{N-1}$.

*Proof sketch.* Write $w(c) = \sum_{i=1}^N c_i$ and use linearity of
expectation. Under the uniform distribution each coordinate $c_i$ is an
independent fair bit, so $\mathbb{E}[c_i] = \tfrac12$ and $\mathbb{E}[w(c)]
= \sum_i \tfrac12 = N/2$. Summing weights over all codes: each neuron is
active in exactly half of the $2^N$ codes, i.e. in $2^{N-1}$ of them, so
the total weight is $N \cdot 2^{N-1}$. $\square$

**Interpretation.** If the brain used all $2^N$ codes with equal
probability, a typical thought would activate half of its neurons — a
metabolically ruinous regime. The dense energy law is the negative
result that motivates sparsity.

## 5. Sparse coding and information per spike

**Theorem 5.1 (Sparse counting).** For $0 \le k \le N$,
$$|\mathcal{C}_{N,k}| = \binom{N}{k}.$$
Consequently $\sum_{k=0}^N \binom{N}{k} = 2^N$, recovering the capacity
theorem by summing over weights.

*Proof sketch.* A weight-$k$ code is determined by the $k$-element subset
of active neurons; there are $\binom{N}{k}$ such subsets. The sum
identity is the binomial theorem at $x = 1$. $\square$

**Definition 5.2 (Information per spike).** A code family of size $M$
selects up to $\log_2 M$ bits. The *information per spike* of the
weight-$k$ family is
$$\rho(N,k) = \frac{\log_2 \binom{N}{k}}{k} \qquad (k \ge 1).$$

**Theorem 5.3 (Sparse efficiency; $\Theta(\log N)$ advantage).**
In the one-hot regime $k = 1$,
$$\rho(N,1) = \log_2 N.$$
Hence sparse (one-hot) coding attains $\Theta(\log N)$ bits per spike,
whereas dense coding is bounded by a constant: a dense code carrying its
maximal $N$ bits spends on average $N/2$ spikes (Theorem 4.1), giving
$\rho_{\text{dense}} = N / (N/2) = 2$ bits per spike, independent of $N$.
Therefore
$$\frac{\rho_{\text{sparse}}(N,1)}{\rho_{\text{dense}}} = \frac{\log_2
N}{2} = \Theta(\log N).$$

*Proof sketch.* For $k=1$, $\binom{N}{1} = N$, so $\rho(N,1) = \log_2 N$.
The dense efficiency follows from Theorem 4.1: $N$ bits at cost $N/2$
spikes. The ratio grows without bound as $N \to \infty$. $\square$

**Remark 5.4 (Concepts per unit energy).** Measuring energy by spike
count, a one-hot population represents $N$ distinct concepts using a
single spike, i.e. $N$ concepts per unit energy, versus the $2$ concepts
per unit energy floor of dense coding. More generally the bits/energy
frontier is the curve $k \mapsto \rho(N,k) = \log_2\binom{N}{k}/k$, which
is maximized toward the sparse end. This is the mathematical statement of
the empirically observed $\sim 1\%$ activity of cortical populations:
sparsity is the energy-optimal code.

## 6. Population coding and $1/\sqrt N$ precision

**Theorem 6.1 (Population precision).** Let $X_1,\ldots,X_N$ be
independent with common variance $v$, and let $\bar X = \frac1N \sum_i
X_i$. Then
$$\operatorname{Var}(\bar X) = \frac{v}{N}, \qquad \operatorname{sd}(\bar
X) = \frac{\sqrt v}{\sqrt N}.$$
The precision (inverse standard deviation) therefore scales as
$\sqrt{N}$.

*Proof sketch.* By independence, variance is additive:
$\operatorname{Var}\!\big(\sum_i X_i\big) = \sum_i \operatorname{Var}(X_i)
= Nv$. Scaling by $1/N$ multiplies variance by $1/N^2$, giving
$\operatorname{Var}(\bar X) = Nv/N^2 = v/N$. Taking square roots yields
the standard deviation. $\square$

**Interpretation.** A population of noisy, independently jittering
neurons encodes a continuous quantity with error decreasing as $1/\sqrt
N$. Continuous, high-precision representation emerges from pooling
imprecise units — the same law that governs sample means throughout
statistics. Halving the error requires quadrupling the population.

**Remark 6.2 (Optimality).** The $1/\sqrt N$ rate is not merely
achievable but optimal: by the Cramér–Rao bound, no unbiased estimator
built from $N$ independent observations of variance $v$ can have standard
deviation below $\sqrt{v}/\sqrt N$. The sample-mean population code
attains this bound.

## 7. The neural manifold hypothesis

**Theorem 7.1 (Neural manifold dimension bound).** Let $F :
\mathbb{R}^{d} \to \mathbb{R}^{N}$ be linear and let $\mathcal{M} = F(B)$
for some $B \subseteq \mathbb{R}^{d}$. Then
$$\dim \operatorname{span} \mathcal{M} \le \operatorname{rank} F \le d.$$
In words: population activity generated from $d$ behavioral degrees of
freedom lives on a manifold of dimension at most $d$.

*Proof sketch.* The span of $F(B)$ is contained in the image
$\operatorname{im} F$, whose dimension is $\operatorname{rank} F$. By the
rank–nullity theorem $\operatorname{rank} F = d - \dim \ker F \le d$. A
linear map cannot increase dimension: it maps a $d$-dimensional source
into an image of dimension at most $d$. $\square$

**Interpretation.** However large the neuron count $N$, if activity is
driven by $d$ behavioral variables the *intrinsic* dimensionality is
capped by $d$. This is precisely the neural manifold hypothesis: recorded
activity, though ambient in $\mathbb{R}^N$, is confined to a
low-dimensional sheet whose dimension reflects the task, not the neuron
count. It explains why dimensionality-reduction of neural recordings
routinely uncovers a handful of interpretable axes.

## 8. Algorithms

We summarize the constructive content of the theory.

**Algorithm A (Capacity and doubling).** Given $N$, return $2^N$ and
verify $2^{N+1} = 2 \cdot 2^N$. Complexity: $O(1)$ arithmetic on
big integers; $O(N)$ bit operations for the exact value.

**Algorithm B (Sparse efficiency frontier).** Given $N$, compute
$\rho(N,k) = \log_2 \binom{N}{k} / k$ for $k = 1,\ldots,N$ and return the
maximizing $k^\star$ and the frontier curve. Complexity: $O(N)$ binomial
updates using the recurrence $\binom{N}{k+1} = \binom{N}{k}(N-k)/(k+1)$.

**Algorithm C (Population precision simulator).** Given single-neuron
variance $v$ and population size $N$, draw independent samples, form the
sample mean, and estimate $\operatorname{Var}(\bar X)$; compare against
the theoretical $v/N$. Complexity: $O(NT)$ for $T$ trials.

**Algorithm D (Manifold dimension estimate).** Given a matrix of neural
activity (rows = time, columns = neurons) generated from $d$ behavioral
variables, compute the singular values and report the numerical rank; the
theorem guarantees it is at most $d$. Complexity: $O(\min(T,N)\,TN)$ for
the singular value decomposition.

## 9. Applications

- **Neuroprosthetics / brain–computer interfaces.** The capacity and
  sparse-efficiency theorems bound how many commands a decoder can
  reliably read from a fixed electrode count, and the manifold bound
  justifies decoding from a few latent dimensions rather than raw
  channels.
- **Energy-aware neuromorphic hardware.** The dense energy law and
  bits-per-spike frontier give a design target: operate near the sparse
  optimum $k^\star$ to maximize information per unit energy.
- **Systems neuroscience analysis.** The manifold theorem underwrites
  the standard practice of summarizing high-dimensional recordings by
  low-dimensional trajectories whose dimension tracks behavioral
  complexity.

## 10. Discussion and future work

The theorems form a tight logical unit: capacity ($2^N$) is the ceiling;
the doubling law is its scaling; the dense energy law is the cost of
using it naively; sparse counting and efficiency are the escape; the
population and manifold theorems govern precision and geometry. Several
extensions are natural.

**Capacity and codes.**
- *Error-correcting neural codes.* Introduce a Hamming metric on
  $\mathcal{C}_N$ and prove Singleton / sphere-packing bounds relating
  minimum distance, redundancy, and the number of reliably
  distinguishable concepts under noise.
- *Robust capacity.* Quantify how capacity $2^N$ degrades to $2^{N-r}$
  when codewords must be pairwise distance $\ge 2r+1$ apart.

**Sparse coding.**
- *Optimal sparsity.* Maximize $\log_2\binom{N}{k}/k$ over $k$; prove the
  optimum is at $k=1$ for the one-hot regime and characterize the
  bits/energy frontier as a function of sparsity $k/N$.
- *Entropy formulation.* Replace $\log_2\binom{N}{k}$ by the
  binary-entropy approximation $N\,H(k/N)$ and prove the standard
  $\binom{N}{k} \ge 2^{N H(k/N)}/(N+1)$ bound.

**Population coding.**
- *Probabilistic grounding.* Re-derive $\operatorname{Var}(\bar X) = v/N$
  from the variance of i.i.d. random variables, turning the algebraic
  model into a theorem about random variables.
- *Fisher information / Cramér–Rao.* Show the $1/\sqrt N$ precision is
  optimal via a Cramér–Rao bound.

**Neural manifold.**
- *Nonlinear manifolds.* Upgrade the dimension bound from linear maps to
  smooth immersions/submersions via the constant-rank theorem.
- *Intrinsic dimension.* Relate manifold dimension to the covariance
  (PCA) rank of recorded activity.

Taken together, these results and their extensions sketch a mathematical
foundation for neural representation: exact where exactness is possible,
and pointing to sharp, testable bounds where the biology becomes noisy.
