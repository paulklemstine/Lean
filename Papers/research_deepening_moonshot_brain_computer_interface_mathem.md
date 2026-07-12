# Error-Correcting Neural Codes and the Sphere-Packing Bound for Binary Neural Populations

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

We develop a self-contained theory of information capacity for populations of
binary (firing/silent) neurons under the demand of noise tolerance. Modeling a
*neural code* on $N$ neurons as a binary activity pattern in $\{0,1\}^N$, we
first establish the raw representational capacity: exactly $2^N$ distinct
patterns are available. We then ask how much of this capacity survives when the
population must decode reliably in the presence of misfiring neurons. Introducing
the Hamming distance as the natural measure of confusability, we define a
$t$-error-correcting codebook as a finite set of patterns any two of which are at
distance at least $2t+1$. Our central result is the **sphere-packing (Hamming)
bound**: for any such codebook $C$ on $N$ neurons,

$$|C|\cdot\sum_{k=0}^{t}\binom{N}{k}\;\le\;2^N.$$

The proof rests on three elementary but structurally important facts: (i) the
number of patterns of a given weight is a binomial coefficient, and these
partition the $2^N$ patterns; (ii) Hamming balls are translation invariant under
neuron-wise exclusive-or, so a ball of radius $r$ has volume
$\sum_{k=0}^{r}\binom{N}{k}$ independent of its center; and (iii) the radius-$t$
balls around the codewords of a $t$-error-correcting code are pairwise disjoint,
by the triangle inequality. The bound subsumes the raw capacity result as its
$t=0$ special case and, for single-error correction ($t=1$), yields the concrete
capacity ceiling $|C|\cdot(N+1)\le 2^N$. We discuss the interpretation of these
results as quantitative constraints on distributed population coding in the
brain, present numerical illustrations, and outline extensions (Gilbert–Varshamov
lower bounds, the Singleton bound, perfect codes) that bracket and refine the
optimal code size.

**Keywords:** neural code, Hamming distance, sphere-packing bound, Hamming bound,
error-correcting code, population coding, binomial coefficients, information
capacity.

---

## 1. Introduction

A recurring question at the interface of neuroscience and information theory is
how much information a population of neurons can represent. In the coarsest
useful abstraction, each neuron is a binary unit — firing ($1$) or silent ($0$) —
and the instantaneous state of $N$ neurons is a pattern in the Boolean cube
$\{0,1\}^N$. The number of such patterns is $2^N$, and this is the *raw
capacity*: an idealized upper limit on the number of mutually distinguishable
states a binary population can occupy.

Raw capacity, however, presumes noiseless readout. Biological neurons are
unreliable: they drop spikes, fire spuriously, and are subject to metabolic and
synaptic fluctuation. If a code assigns meaning to two patterns that differ in a
single neuron, then a single misfire converts one meaning into another with no
possibility of recovery. A code that is robust to up to $t$ simultaneous neuron
faults must therefore keep its meaningful patterns well separated. Making this
precise leads directly into the classical theory of error-correcting codes, and
in particular to the sphere-packing (Hamming) bound, which limits how many
well-separated codewords can coexist.

The purpose of this paper is to give a clean, fully explicit development of this
bound in the language of neural populations, together with its two most important
corollaries: the recovery of the raw capacity $2^N$ in the noiseless limit, and
the exact price $|C|\le 2^N/(N+1)$ of single-error correction. Every definition,
lemma, and theorem is stated inline in elementary terms; the arguments require
nothing beyond finite counting, a symmetry of the Boolean cube, and the triangle
inequality for Hamming distance.

### 1.1 Contributions

1. A precise model of noise-tolerant neural coding: codebooks with a minimum
   Hamming-distance constraint (Section 3).
2. A partition-by-weight count showing that patterns of weight $k$ number
   $\binom{N}{k}$ and sum to $2^N$ (Section 4).
3. A proof that Hamming balls are translation invariant and hence have a
   center-independent volume $\sum_{k=0}^{r}\binom{N}{k}$ (Section 5).
4. The sphere-packing bound $|C|\cdot\sum_{k=0}^{t}\binom{N}{k}\le 2^N$
   (Section 6), with the raw-capacity and single-error corollaries (Section 7).
5. Numerical evidence and interpretation for population coding (Sections 8–9).

---

## 2. Preliminaries and notation

Throughout, $N$ denotes the number of neurons and $t$ a nonnegative integer
error-tolerance parameter. We write $\binom{N}{k}$ for the binomial coefficient
(the number of $k$-element subsets of an $N$-element set), with the convention
$\binom{N}{k}=0$ for $k>N$. We write $|S|$ for the cardinality of a finite set
$S$ and $[N]=\{0,1,\dots,N-1\}$ for the index set of neurons.

**Definition 2.1 (Neural code).** A *neural code* on $N$ neurons is a function
$c:[N]\to\{0,1\}$ assigning to each neuron a binary state ($1$ = firing, $0$ =
silent). Equivalently it is an element of the Boolean cube $\{0,1\}^N$. We write
$\mathcal{P}_N=\{0,1\}^N$ for the set of all patterns.

**Definition 2.2 (Silent pattern).** The *silent* pattern $\mathbf{0}\in
\mathcal{P}_N$ is the constant function $\mathbf{0}(i)=0$ for all $i$.

**Definition 2.3 (Weight).** The *weight* of a pattern $c$, written $w(c)$, is
the number of firing neurons, $w(c)=\bigl|\{i\in[N]: c(i)=1\}\bigr|$.

**Definition 2.4 (Hamming distance).** For patterns $x,y\in\mathcal{P}_N$, the
*Hamming distance* $d_H(x,y)$ is the number of neurons on which they disagree,
$d_H(x,y)=\bigl|\{i\in[N]: x(i)\ne y(i)\}\bigr|$.

The Hamming distance is a metric on $\mathcal{P}_N$: it is nonnegative,
symmetric, vanishes exactly when $x=y$, and satisfies the **triangle
inequality** $d_H(x,z)\le d_H(x,y)+d_H(y,z)$. It counts precisely the number of
single-neuron flips required to transform $x$ into $y$, which is why it is the
correct model of noise: if a transmitted pattern is corrupted by $m$ misfiring
neurons, the received pattern is at Hamming distance exactly $m$ from the
original.

---

## 3. Model: noise-tolerant codebooks

**Definition 3.1 (Codebook).** A *codebook* is a finite set $C\subseteq
\mathcal{P}_N$ of patterns. Its elements are called *codewords*; they are the
patterns to which the population assigns meaning.

**Definition 3.2 ($t$-error-correcting codebook).** A codebook $C$ *corrects $t$
errors* if any two distinct codewords are at Hamming distance at least $2t+1$:
$$\forall\, x,y\in C,\ x\ne y \implies d_H(x,y)\ge 2t+1.$$

**Proposition 3.3 (Decodability).** If $C$ corrects $t$ errors and a codeword
$x\in C$ is transmitted and corrupted by at most $t$ neuron flips, producing a
received pattern $z$ with $d_H(x,z)\le t$, then $x$ is the unique codeword
nearest to $z$; nearest-codeword decoding recovers $x$.

*Proof.* Let $y\in C$ with $y\ne x$. By the triangle inequality and the minimum
distance, $2t+1\le d_H(x,y)\le d_H(x,z)+d_H(z,y)\le t + d_H(z,y)$, so
$d_H(z,y)\ge t+1 > t \ge d_H(x,z)$. Thus $x$ is strictly closer to $z$ than any
other codeword. $\square$

This proposition is the operational justification of Definition 3.2: the minimum
distance $2t+1$ is exactly the condition under which up to $t$ simultaneous
neuron faults can always be corrected.

---

## 4. Raw capacity and the weight partition

**Theorem 4.1 (Raw capacity).** The number of neural codes on $N$ neurons is
$|\mathcal{P}_N| = 2^N$.

*Proof.* Each of the $N$ neurons is independently assigned one of two states, so
the number of patterns is $2\cdot 2\cdots 2 = 2^N$. $\square$

**Lemma 4.2 (Distance from silence equals weight).** For every pattern $c$,
$d_H(\mathbf{0},c)=w(c)$.

*Proof.* The silent pattern disagrees with $c$ exactly on the neurons where
$c(i)=1$, and there are $w(c)$ of them. $\square$

**Theorem 4.3 (Sparse count).** For each $0\le k\le N$, the number of patterns of
weight exactly $k$ is $\binom{N}{k}$:
$$\bigl|\{c\in\mathcal{P}_N: w(c)=k\}\bigr| = \binom{N}{k}.$$

*Proof.* A pattern of weight $k$ is determined by the choice of which $k$ of the
$N$ neurons fire; there are $\binom{N}{k}$ such choices, and this correspondence
between weight-$k$ patterns and $k$-element subsets of $[N]$ is a bijection.
$\square$

**Corollary 4.4 (Weight partition).** The patterns partition by weight, giving
$$\sum_{k=0}^{N}\binom{N}{k} = 2^N.$$

*Proof.* Every pattern has a unique weight in $\{0,1,\dots,N\}$, so summing the
sparse counts of Theorem 4.3 over all weights counts every pattern exactly once,
yielding $|\mathcal{P}_N| = 2^N$ by Theorem 4.1. $\square$

This is the classical binomial identity for row $N$ of Pascal's triangle, here
obtained as a partition of the pattern space.

---

## 5. Hamming balls and their volume

**Definition 5.1 (Hamming ball).** For a pattern $c$ and radius $r\ge 0$, the
*Hamming ball* is $B(c,r)=\{x\in\mathcal{P}_N: d_H(c,x)\le r\}$: the set of
patterns obtainable from $c$ by flipping at most $r$ neurons — equivalently, the
patterns that could be *received* if $c$ is transmitted through a channel that
flips at most $r$ neurons.

**Lemma 5.2 (Translation invariance).** For any patterns $c,x$,
$$d_H(c,x) = d_H\bigl(\mathbf{0},\, c\oplus x\bigr),$$
where $c\oplus x$ denotes the neuron-wise exclusive-or (the pattern that fires
exactly where $c$ and $x$ disagree).

*Proof.* Both sides count the neurons on which $c$ and $x$ differ: $c\oplus x$
fires exactly at those neurons, and its distance from silence is its weight,
which is that same count. $\square$

**Theorem 5.3 (Center independence).** For any center $c$ and radius $r$,
$$|B(c,r)| = |B(\mathbf{0},r)|.$$

*Proof.* The map $x\mapsto c\oplus x$ is a bijection of $\mathcal{P}_N$ (it is
its own inverse), and by Lemma 5.2 it carries $B(c,r)$ onto $B(\mathbf{0},r)$
bijectively, since $d_H(c,x)\le r \iff d_H(\mathbf{0}, c\oplus x)\le r$. Hence
the two balls have equal cardinality. $\square$

The map $x \mapsto c \oplus x$ is a rigid translation of the Boolean cube (an
isometry of the Hamming metric); Theorem 5.3 says all Hamming balls of a given
radius are congruent.

**Theorem 5.4 (Ball volume).** For any center $c$ and radius $r$,
$$|B(c,r)| = \sum_{k=0}^{r}\binom{N}{k}.$$
We denote this common volume $V(N,r)=\sum_{k=0}^{r}\binom{N}{k}$.

*Proof.* By Theorem 5.3 it suffices to count $B(\mathbf{0},r)$. By Lemma 4.2 a
pattern $x$ lies in $B(\mathbf{0},r)$ iff $w(x)\le r$, so $B(\mathbf{0},r)$ is
the disjoint union over $k=0,\dots,r$ of the weight-$k$ patterns. By Theorem 4.3
the $k$-th part has size $\binom{N}{k}$, and summing gives
$\sum_{k=0}^{r}\binom{N}{k}$. $\square$

Two sanity checks: $V(N,0)=\binom{N}{0}=1$ (a radius-zero ball is a single
point), and $V(N,N)=\sum_{k=0}^{N}\binom{N}{k}=2^N$ (a radius-$N$ ball is the
whole cube), consistent with Corollary 4.4.

---

## 6. The sphere-packing bound

**Lemma 6.1 (Disjoint balls).** Let $C$ correct $t$ errors. Then the radius-$t$
balls $\{B(c,t):c\in C\}$ are pairwise disjoint.

*Proof.* Suppose $z\in B(x,t)\cap B(y,t)$ with $x,y\in C$, $x\ne y$. Then
$d_H(x,z)\le t$ and $d_H(y,z)\le t$, so by the triangle inequality (and symmetry)
$d_H(x,y)\le d_H(x,z)+d_H(z,y)\le 2t$. This contradicts $d_H(x,y)\ge 2t+1$.
Hence no such $z$ exists and the balls are disjoint. $\square$

**Theorem 6.2 (Sphere-packing / Hamming bound).** Let $C$ be a codebook on $N$
neurons that corrects $t$ errors. Then
$$|C|\cdot\sum_{k=0}^{t}\binom{N}{k}\;\le\;2^N.$$

*Proof.* By Lemma 6.1 the balls $B(c,t)$ for $c\in C$ are pairwise disjoint, so
the cardinality of their union is the sum of their cardinalities:
$$\Bigl|\bigcup_{c\in C}B(c,t)\Bigr| = \sum_{c\in C}|B(c,t)| = \sum_{c\in C}V(N,t) = |C|\cdot V(N,t),$$
using Theorem 5.4 for the common volume $V(N,t)=\sum_{k=0}^{t}\binom{N}{k}$. The
union is a subset of the full pattern space $\mathcal{P}_N$, which has $2^N$
elements by Theorem 4.1, so
$$|C|\cdot\sum_{k=0}^{t}\binom{N}{k} = \Bigl|\bigcup_{c\in C}B(c,t)\Bigr| \le 2^N. \qquad\square$$

The proof is the exact "spheres packed in a box" argument: $|C|$ disjoint balls,
each of volume $V(N,t)$, fit inside a universe of $2^N$ patterns, so their total
volume is at most $2^N$.

---

## 7. Consequences

**Corollary 7.1 (Recovery of raw capacity).** For $t=0$, Theorem 6.2 reads
$|C|\cdot\binom{N}{0}=|C|\le 2^N$. Every codebook — with or without a distance
constraint — has at most $2^N$ codewords, recovering Theorem 4.1 as the
zero-noise special case.

**Corollary 7.2 (Price of single-error correction).** If $C$ corrects a single
error (equivalently, any two distinct codewords differ in at least $3$ neurons),
then with $t=1$ the ball volume is $V(N,1)=\binom{N}{0}+\binom{N}{1}=N+1$, so
$$|C|\cdot(N+1)\le 2^N, \qquad\text{equivalently}\qquad |C|\le\frac{2^N}{N+1}.$$

Thus single-error robustness reduces the usable capacity by a factor of at least
$N+1$ relative to the raw $2^N$. More generally, the *rate* of a $t$-error code,
$R=\tfrac1N\log_2|C|$, satisfies
$$R\le 1-\frac1N\log_2\!\sum_{k=0}^{t}\binom{N}{k},$$
a quantitative statement of the capacity–robustness trade-off.

---

## 8. Numerical illustration

The following table lists the single-error ceiling $2^N/(N+1)$ and the
double-error ceiling $2^N/V(N,2)$ with $V(N,2)=1+N+\binom{N}{2}$.

| $N$ | $2^N$ | $V(N,1)=N{+}1$ | $2^N/(N{+}1)$ | $V(N,2)$ | $2^N/V(N,2)$ |
|----:|------:|---------------:|--------------:|---------:|-------------:|
| 3   | 8     | 4              | 2.00          | 7        | 1.14         |
| 7   | 128   | 8              | 16.00         | 29       | 4.41         |
| 15  | 32768 | 16             | 2048.00       | 121      | 270.8        |
| 31  | $2^{31}$ | 32          | 67108864      | 497      | 4.32e6       |

The row $N=7$ is special: the ceiling $2^7/8=16$ is an integer and is *attained*
by the Hamming$(7,4)$ code, a single-error-correcting codebook with exactly $16$
codewords. Codes meeting the sphere-packing bound with equality are called
**perfect**: their radius-$t$ balls tile the entire cube with no leftover
patterns. Perfect codes are rare; the Hamming codes (single-error) and the binary
Golay code are the principal examples.

---

## 9. Interpretation for population coding

The sphere-packing bound recasts a biological intuition as a theorem. Empirically
the brain favors *distributed* population codes over fragile single-neuron
("grandmother cell") representations. In our framework a distributed code is one
whose codewords differ in many neurons, i.e. one with large minimum Hamming
distance — which is exactly the error-correction condition. The bound then makes
the trade explicit: to tolerate $t$ simultaneous faults, each concept must claim
a private Hamming ball of volume $V(N,t)$, and only $2^N/V(N,t)$ such balls fit.
A population cannot be simultaneously maximally expressive (using all $2^N$
patterns) and maximally robust; the exchange rate is a sum of binomial
coefficients. This is the same geometry that governs engineered communication
channels, applied to the substrate of neural tissue.

---

## 10. Discussion and future work

The bound proved here is an *upper* bound on codebook size. Several natural
directions refine and complement it:

- **Gilbert–Varshamov lower bound.** A greedy/maximal-code argument shows the
  existence of a $t$-error-correcting codebook with $|C|\ge 2^N/V(N,2t)$,
  bracketing the optimal size between two explicit binomial expressions.
- **Singleton bound.** Projecting codewords onto $N-d+1$ coordinates is injective
  when the minimum distance is $d$, giving $|C|\le 2^{N-d+1}$; codes meeting it
  with equality are the MDS (maximum-distance-separable) neural codes.
- **Perfect codes.** Characterizing the equality case and confirming that the
  Hamming$(7,4)$ code is perfect connects the table of Section 8 to an exact
  tiling of the Boolean cube.
- **Plotkin and linear-programming bounds** sharpen the picture in the high-noise
  regime $d>N/2$, where the sphere-packing bound is loose.
- **Metric structure.** Treating the pattern space as a genuine metric space lets
  one reuse general ball-counting machinery uniformly.
- **Energy-optimal robust codes.** Combining the distance constraint with
  sparse-coding energy costs and description-length bounds would characterize
  codes that are simultaneously robust and metabolically efficient.

---

## 11. Conclusion

Starting from the model of a neural code as a binary pattern on $N$ neurons, we
established that the raw representational capacity is $2^N$, and that demanding
robustness to $t$ neuron misfires compresses the usable capacity to at most
$2^N/\sum_{k=0}^{t}\binom{N}{k}$ via the sphere-packing bound. The argument is
elementary — a weight partition, a translation symmetry of the Boolean cube, and
the triangle inequality — yet it captures a fundamental limit: in any noisy
binary substrate, expressiveness and reliability are traded against one another
at a rate set by the volume of a Hamming ball. The raw capacity $2^N$ is the
$t=0$ shadow of this deeper geometric law.
