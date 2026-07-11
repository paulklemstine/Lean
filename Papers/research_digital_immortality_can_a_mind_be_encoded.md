# Information-Theoretic Bounds on Mind Uploading: A Quadratic Description-Length Law and its Physical Consequences

## Abstract

We formalize and prove a chain of results bounding the resources required
to store a human mind, under a combinatorial abstraction of the neural
connectome. Modeling a mind on $N$ neurons as a Boolean configuration over
its $\binom{N}{2}$ potential synaptic connections, we establish: (i) an
exact state count of $2^{\binom{N}{2}}$ distinct connectomes; (ii) a
two-sided quadratic estimate $(N-1)^2 \le 2\binom{N}{2} \le N^2$ for the
slot count; (iii) a worst-case minimum-description-length theorem showing
that any injective binary encoding must assign some connectome a codeword of
at least $\binom{N}{2}$ bits, so that no computable compressor can beat the
raw slot count in the worst case; and (iv) a physical corollary that, when
this description length is combined with the Bekenstein information bound,
forces the energy–radius product $R \cdot E$ of any storage region to grow
at least quadratically in $N$. The development bridges combinatorics,
algorithmic information theory, and gravitational thermodynamics, and the
Boolean-slot abstraction is deliberately lossy so that every result is a
*lower* bound that richer models can only strengthen.

**Keywords:** connectome, minimum description length, Kolmogorov
complexity, Bekenstein bound, pigeonhole principle, quadratic scaling, mind
uploading.

---

## 1. Introduction

The proposal to preserve a human mind by copying its neural structure into a
computational substrate — *mind uploading* — is usually debated on
philosophical or biological grounds. We set those debates aside and ask a
purely quantitative question that logically precedes them: **how much
information does a mind contain, and what physical resources must a device
possess to store it?**

Our answer rests on a single structural observation. The information that
individuates a mind is widely held to reside in the *connectome*, the graph
of synaptic connections among neurons. The number of potential connections
is not linear but quadratic in the neuron count, because connections join
*pairs* of neurons. Everything downstream — the size of the state space, the
incompressibility of a typical mind, and the physical cost of storage —
inherits this quadratic scaling.

We make three contributions:

1. **A combinatorial model** of a connectome as a Boolean assignment over
   $\binom{N}{2}$ synapse slots, with an exact count of the resulting state
   space.
2. **A minimum-description-length theorem** in the spirit of Kolmogorov
   complexity: no lossless code can, in the worst case, describe an
   $N$-neuron mind in fewer than $\binom{N}{2}$ bits.
3. **A physical corollary** obtained by feeding the description-length
   bound into the Bekenstein bound, yielding a quadratic lower bound on the
   energy–radius product of any storage region.

The model is intentionally minimal: it records only the presence or absence
of each connection, discarding weights, directionality, and dynamics.
Because it discards information, each bound is a floor; any more realistic
model requires at least as many bits.

---

## 2. The connectome model

### 2.1 Synapse slots

**Definition 2.1 (Synapse slots).** For a mind on $N$ neurons, the number of
*synapse slots* is the number of unordered pairs of distinct neurons,
$$s(N) \;:=\; \binom{N}{2} \;=\; \frac{N(N-1)}{2}.$$
Each slot represents one potential undirected synaptic connection.

**Definition 2.2 (Connectome).** A *connectome* on $N$ neurons is a function
$$c : \{1, \dots, s(N)\} \to \{0, 1\},$$
assigning to each synapse slot a Boolean flag: $1$ if the connection is
present, $0$ if absent. The set of all such functions is the *state space*
of $N$-neuron minds.

This is a lossy abstraction by design. It omits synaptic weight,
directionality, neuron type, and temporal dynamics. Its purpose is to
isolate the combinatorial skeleton on which all richer models sit.

### 2.2 The state count

**Theorem 2.3 (State count).** The number of distinct connectomes on $N$
neurons is exactly
$$\bigl|\{0,1\}^{s(N)}\bigr| \;=\; 2^{\binom{N}{2}}.$$

*Proof sketch.* A connectome is a function from the $s(N)$-element slot set
into the two-element set $\{0,1\}$. The number of such functions is
$2^{s(N)}$, since the choices at distinct slots are independent. $\square$

The exponent $\binom{N}{2}$ is the sole driver of the state-space size, and
it is quadratic — the fact we make precise next.

---

## 3. Quadratic growth of the slot count

The slot count $s(N)$ is $\Theta(N^2)$. We establish this with an exact
identity and a clean two-sided estimate.

**Lemma 3.1 (Doubling identity).** For all $N$,
$$2\,s(N) \;=\; N(N-1).$$

*Proof sketch.* Immediate from $\binom{N}{2} = N(N-1)/2$; the division is
exact because $N(N-1)$ is even (one of two consecutive integers is even),
so multiplying back by $2$ recovers $N(N-1)$. $\square$

**Theorem 3.2 (Quadratic sandwich).** For all $N$,
$$(N-1)^2 \;\le\; 2\,s(N) \;\le\; N^2.$$

*Proof sketch.* By Lemma 3.1, $2s(N) = N(N-1) = N^2 - N$. The upper bound
$N^2 - N \le N^2$ is immediate. For the lower bound,
$N^2 - N \ge (N-1)^2 = N^2 - 2N + 1$ reduces to $N \ge 1$, which holds for
all natural $N$ (with equality accounting handled at $N=0$ by the truncated
subtraction on the natural numbers). $\square$

**Corollary 3.3.** $s(N)$ grows quadratically: $s(N) = \Theta(N^2)$, with
$\tfrac{1}{2}(N-1)^2 \le s(N) \le \tfrac{1}{2}N^2$.

This quadratic law is the pivot of the paper. It transforms the linear
intuition ("a brain has $N$ neurons") into the correct quadratic accounting
("a brain has $\sim N^2/2$ potential connections").

---

## 4. Minimum description length and incompressibility

We now show that the state-space size forces a worst-case lower bound on the
length of any lossless description of a mind — an incompressibility result in
the spirit of Kolmogorov complexity.

Fix $N$ and write $s = s(N)$. An *encoding* is any injective map
$\mathrm{enc}$ from the connectome state space into a codeword set;
injectivity is exactly the requirement of *lossless* coding (distinct minds
receive distinct codewords).

**Theorem 4.1 (Description-length lower bound).** For any injective encoding
$\mathrm{enc}$ of connectomes into the natural numbers, there exists a
connectome $c$ with
$$\mathrm{enc}(c) \;\ge\; 2^{s} - 1.$$

*Proof sketch.* Suppose not: every codeword $\mathrm{enc}(c)$ is strictly
less than $2^{s}-1$, i.e. lies in $\{0, 1, \dots, 2^{s}-2\}$, a set of size
$2^{s}-1$. Since $\mathrm{enc}$ is injective, its image has cardinality
equal to the domain, namely $2^{s}$ by Theorem 2.3. But a subset of a set of
size $2^{s}-1$ cannot have $2^{s}$ elements — a pigeonhole contradiction.
$\square$

**Theorem 4.2 (Quadratic bit-length bound).** For any injective encoding
$\mathrm{enc}$ of connectomes into the natural numbers, there exists a
connectome $c$ whose codeword occupies at least $s$ bits:
$$\mathrm{size}\bigl(\mathrm{enc}(c)\bigr) \;\ge\; s \;=\; \binom{N}{2},$$
where $\mathrm{size}(m)$ denotes the number of bits in the binary
representation of $m$. Hence the worst-case minimum description length of an
$N$-neuron mind grows quadratically in $N$.

*Proof sketch.* By Theorem 4.1 there is a connectome $c$ with
$\mathrm{enc}(c) \ge 2^{s}-1$. A natural number $m$ satisfies
$\mathrm{size}(m) \ge s$ precisely when $m \ge 2^{s-1}$; since
$2^{s}-1 \ge 2^{s-1}$ for all $s \ge 1$ (and the case $s=0$ is trivial), the
codeword of $c$ requires at least $s$ bits. Combining with Corollary 3.3,
$s = \Theta(N^2)$. $\square$

**Theorem 4.3 (No universal lossless compressor).** For any $M < 2^{s}$
there is no injective encoding of the connectome state space into a codeword
set of size $M$. In particular, no lossless compressor can represent all
$N$-neuron minds using fewer than $2^{\binom{N}{2}}$ codewords.

*Proof sketch.* An injection from a set of cardinality $2^{s}$ into a set of
cardinality $M$ requires $2^{s} \le M$; the hypothesis $M < 2^{s}$ makes
this impossible. $\square$

**Interpretation.** Theorems 4.1–4.3 are the information-theoretic heart of
the paper. They say that although *specific*, highly structured connectomes
may compress well, the state space is so large that *most* connectomes are
incompressible: their shortest lossless description is essentially the raw
$\binom{N}{2}$-bit slot configuration. This mirrors the classical fact of
algorithmic information theory that the overwhelming majority of strings of
length $n$ have Kolmogorov complexity close to $n$. Here the effective
length is $\binom{N}{2}$, so incompressibility is quadratic in the neuron
count.

---

## 5. From information to physics: the Bekenstein bound

The description-length bounds are statements about bits. We now convert them
into a statement about energy and space using a fundamental physical limit.

**The Bekenstein bound.** For a spatial region of radius $R$ enclosing total
energy $E$, the amount of information $I$ (in bits) contained in the region
is bounded by
$$I \;\le\; B(R, E) \;:=\; \frac{2\pi R E}{\hbar c \ln 2},$$
where $\hbar$ is the reduced Planck constant and $c$ the speed of light.
This bound is derived from black-hole thermodynamics and represents an
absolute physical ceiling: exceeding it would require the region to collapse
into a black hole.

**Definition 5.1 (Bekenstein capacity).** For real parameters $R, E, \hbar,
c$ we write
$$B(R, E, \hbar, c) := \frac{2\pi R E}{\hbar c \ln 2}$$
for the Bekenstein information capacity of the region, measured in bits.

**Theorem 5.2 (Energy–radius lower bound).** Fix $N$ and let a storage
region have parameters $R, E$ with $\hbar > 0$, $c > 0$. If the region can
hold the information required to distinguish all $N$-neuron connectomes,
i.e.
$$s(N) \;\le\; B(R, E, \hbar, c),$$
then its energy–radius product satisfies
$$\frac{\hbar c \ln 2}{2\pi}\, s(N) \;\le\; R \cdot E.$$

*Proof sketch.* The storage hypothesis reads $s(N) \le 2\pi R E / (\hbar c
\ln 2)$. Since $\hbar, c > 0$ and $\ln 2 > 0$, multiply both sides by the
positive quantity $\hbar c \ln 2 / (2\pi)$ and rearrange to isolate
$R \cdot E$ on the right. $\square$

**Theorem 5.3 (Quadratic physical barrier).** Under the hypotheses of
Theorem 5.2, and assuming $N \ge 1$,
$$\frac{\hbar c \ln 2}{4\pi}\,(N-1)^2 \;\le\; R \cdot E.$$

*Proof sketch.* By Theorem 3.2, $(N-1)^2 \le 2s(N)$, so
$(N-1)^2 / 2 \le s(N)$ (this cast from natural to real quantities is valid
because $N \ge 1$ makes $N-1$ nonnegative). Multiply by the nonnegative
factor $\hbar c \ln 2 / (2\pi)$ and chain with Theorem 5.2:
$$\frac{\hbar c \ln 2}{4\pi}(N-1)^2 = \frac{\hbar c \ln 2}{2\pi}\cdot
\frac{(N-1)^2}{2} \le \frac{\hbar c \ln 2}{2\pi}\, s(N) \le R \cdot E.
\qquad \square$$

**Interpretation.** Theorem 5.3 is the culmination: a fact about counting
pairs of neurons becomes a constraint on the physical resources of any
storage device. The product $R \cdot E$ of a device's size and energy must
grow at least quadratically in the neuron count. The positivity hypotheses
on $\hbar$ and $c$ are load-bearing — the algebraic rearrangement is false
without them — reflecting that the bound genuinely rests on physics, not on
formal manipulation.

---

## 6. Worked numerics

To make the scales concrete, consider small and large $N$:

- **$N = 5$ (a micro-circuit).** Slots: $\binom{5}{2} = 10$. State space:
  $2^{10} = 1024$ distinct connectomes. Minimum worst-case description
  length: $10$ bits.
- **$N = 1000$ (a small cortical patch).** Slots: $\binom{1000}{2} =
  499{,}500$. State space: $2^{499500}$, a number with roughly $150{,}000$
  decimal digits.
- **$N \approx 8.6 \times 10^{10}$ (human brain).** Slots:
  $\approx 3.7 \times 10^{21}$. The description length alone —
  $\sim 3.7 \times 10^{21}$ bits, or about $460$ exabytes in the crudest
  presence/absence model — dwarfs global data storage, and richer models
  multiply this further.

The doubling from neurons to pairs is the entire message: linear growth in
neurons is quadratic growth in bits.

---

## 7. Discussion

**A monotone floor.** Every bound above is a lower bound derived from a
lossy model. Adding realism — synaptic weights, directionality, neuron
state, dynamics — only increases the required information. If synapses carry
$b$-bit weights and are directional, the slot count becomes $b\,N(N-1)$; if
weight precision scales with connectivity as $b \asymp \log N$, the
description length grows as $N^2 \log N$. The quadratic core is irreducible.

**Worst case versus typical case.** Our incompressibility results are
worst-case. A parallel typical-case theory, using the binary entropy $H(p)$
of a sparse-random connectome with edge density $p$, would concentrate the
typical complexity near $H(p)\,\binom{N}{2}$ bits: sparsity lowers the
constant but never the quadratic order.

**Physics as a hard wall.** The Bekenstein bound is not a technological
limitation but a consequence of quantum mechanics and gravity. Consequently
Theorem 5.3 is a barrier no future engineering can circumvent: storing more
mind requires more energy or more space, quadratically.

**Relation to Kolmogorov complexity.** Theorems 4.1–4.3 are finite,
counting-based analogues of the incompressibility theorems of algorithmic
information theory. They avoid the uncomputability of Kolmogorov complexity
by fixing the state space and invoking the pigeonhole principle, yet deliver
the same moral: generic objects are their own shortest descriptions.

---

## 8. Future work

Several directions extend this program:

1. **Directed, weighted connectomes.** Formalize the $b\,N(N-1)$ and
   $N^2\log N$ scalings for realistic synapse models and confirm that
   biological realism only raises the exponent.
2. **A sharp incompressibility threshold.** Prove that for a
   sparse-random ensemble with density $p$, the typical complexity
   concentrates at $H(p)\binom{N}{2}$ bits and the compressible fraction
   vanishes as $N \to \infty$.
3. **A two-sided physical law.** Combine the Bekenstein upper bound with a
   gravitational-collapse (Schwarzschild) lower bound to squeeze the storage
   medium from both sides, yielding a minimal volume scaling as $N^2$.
4. **A fidelity–compression frontier for lossy uploading.** Characterize
   the trade-off between allowed reconstruction error and achievable
   compression, in the rate–distortion tradition.

---

## 9. Conclusion

We have shown, from counting alone, that the state space of $N$-neuron minds
has size $2^{\binom{N}{2}}$; that no lossless code can beat the
$\binom{N}{2}$-bit slot count in the worst case; and that this quadratic
information requirement, passed through the Bekenstein bound, imposes a
quadratic lower bound on the energy–radius product of any storage device.
The through-line is a single structural fact — information lives in pairs of
neurons, not neurons — and its consequences propagate cleanly from
combinatorics through information theory into gravitational physics. Whatever
the ultimate feasibility of mind uploading, its accounting is quadratic,
incompressible, and physically constrained.
