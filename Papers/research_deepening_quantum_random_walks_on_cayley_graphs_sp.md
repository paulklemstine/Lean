# Exact Cesàro Equilibria for Periodic Quantum Walks

**Aristotle**  
**20 July 2026**

## Abstract

Periodic quantum dynamics creates a basic obstruction to ordinary mixing: a localized state returns infinitely often and therefore cannot converge pointwise to a distinct uniform distribution. This paper establishes the complementary positive result for empirical, or Cesàro, mixing. For any periodic sequence in a commutative additive space, the sum over $q$ complete periods is exactly $q$ times the one-period sum. Consequently, for a finite-order quantum evolution $U$ satisfying $U^k=I$, the empirical Born probability at every state over any positive number of complete periods is exactly its one-period average. Uniform mixing along all complete-period observation windows is therefore equivalent to a finite condition on a single period. When this condition holds, the usual convergence statement follows with zero finite-time error along those windows: the sequence of averages is constant, not merely convergent. We present the algebraic argument, its specialization to finite Cayley graphs, computational algorithms, examples separating periodicity from uniformity, and implications for spectral analysis, experimental sampling, and extensions to incomplete windows and decoherent dynamics.

## 1. Introduction

Random walks turn local motion into global statistics. In a classical walk, repeated stochastic updates often suppress memory of the initial state. Under standard irreducibility and aperiodicity assumptions, the distribution approaches a stationary law, and on a regular finite graph that law is uniform. Spectral gaps then quantify the rate of approach.

Quantum walks replace stochastic evolution by unitary evolution. Their amplitudes interfere, while their observed probabilities are obtained by taking squared moduli. Unitarity preserves information and produces recurrence rather than dissipation. In the finite-order case, the evolution returns exactly after a fixed number of steps. A localized initial state consequently reappears forever, preventing the instantaneous probability distribution from approaching a different stationary law.

This failure does not eliminate every meaningful notion of equilibrium. One may average the observed distributions through time. Such Cesàro averaging is natural experimentally, where a histogram is assembled from repeated observation times, and mathematically, where oscillatory terms often cancel under averaging. The central result of this paper is particularly strong for finite-order dynamics: averaging over complete periods entails no limiting approximation. Every positive collection of complete periods has exactly the same empirical distribution as one period.

The argument has two layers. The algebraic layer concerns an arbitrary periodic sequence with values in a commutative additive system. Its complete-block sum consists of repeated copies of one period. The probabilistic layer applies this identity vertex by vertex to Born probabilities. This separation clarifies which assumptions do real work. The block identity requires neither a graph nor a Hilbert space. The quantum specialization requires only that finite-order evolution makes each Born-probability sequence periodic. Uniformity is an additional finite criterion, not an automatic consequence of periodicity.

The practical conclusion is that a potentially infinite mixing question reduces to a finite orbit computation. If a period has length $k$ on a state space of size $m$, one needs only the $mk$ probabilities from one period. Longer complete-block simulations are redundant.

## 2. Mathematical setting

### 2.1 Finite state spaces and Cayley graphs

Let $G$ be a finite set. In the principal combinatorial application, $G$ is a finite group and a generating set $S\subseteq G$ defines a Cayley graph: vertices are group elements, and a directed edge joins $g$ to $sg$ for each $s\in S$. The complete-block results do not rely on the group structure, but Cayley graphs supply symmetry and a natural setting for spectral questions.

Let $\mathcal H=\ell^2(G)$ be the Hilbert space of complex-valued functions on $G$, with inner product

$$
\langle \phi,\psi\rangle=\sum_{x\in G}\overline{\phi(x)}\psi(x).
$$

A normalized state $\psi\in\mathcal H$ satisfies

$$
\sum_{x\in G}|\psi(x)|^2=1.
$$

A quantum evolution is represented by a unitary operator $U:\mathcal H\to\mathcal H$. Starting from $\psi_0$, the state at time $n\in\mathbb N$ is

$$
\psi_n=U^n\psi_0.
$$

### 2.2 Born probabilities

**Definition 2.1 (Born probability).** For $x\in G$ and $n\in\mathbb N$, the probability of observing the walk at $x$ at time $n$ is

$$
p_n(x)=|\psi_n(x)|^2=|(U^n\psi_0)(x)|^2.
$$

For every $n$, normalization gives $p_n(x)\ge 0$ and

$$
\sum_{x\in G}p_n(x)=1.
$$

Thus $p_n$ is a probability distribution on $G$.

### 2.3 Finite-order dynamics

**Definition 2.2 (Finite-order evolution).** The evolution has finite order with period $k>0$ if

$$
U^k=I.
$$

The integer $k$ need not be the least positive period. From $U^k=I$ it follows that

$$
U^{n+k}=U^nU^k=U^n
$$

for every $n$. Hence $\psi_{n+k}=\psi_n$ and

$$
p_{n+k}(x)=p_n(x)
$$

for every $x\in G$. Each coordinate probability is therefore a real-valued periodic sequence.

### 2.4 Cesàro means and uniformity

**Definition 2.3 (Cesàro mean).** For a real sequence $f:\mathbb N\to\mathbb R$ and $N>0$, its empirical mean through time $N-1$ is

$$
C_N(f)=\frac{1}{N}\sum_{n=0}^{N-1}f(n).
$$

For a walk, define the empirical distribution $\overline p_N$ by

$$
\overline p_N(x)=C_N(n\mapsto p_n(x))
=\frac{1}{N}\sum_{n=0}^{N-1}p_n(x).
$$

Because it is an average of probability distributions, $\overline p_N$ is again a probability distribution.

**Definition 2.4 (Uniform distribution).** On a finite nonempty set $G$, the uniform probability is

$$
u_G(x)=\frac{1}{|G|}
$$

for every $x\in G$.

**Definition 2.5 (Uniform complete-block mixing).** A period-$k$ walk mixes uniformly along complete blocks if for every positive integer $q$,

$$
\overline p_{qk}=\nu_G.
$$

This is deliberately distinct from instantaneous mixing, which would ask whether $p_n\to\nu_G$ as $n\to\infty$.

## 3. The algebra of complete periods

The engine of the theory is independent of probability.

**Theorem 3.1 (Complete-block summation).** Let $E$ be a commutative additive monoid, let $f:\mathbb N\to E$, and suppose that

$$
f(n+k)=f(n)
$$

for every $n\in\mathbb N$. Then for every $q\in\mathbb N$,

$$
\sum_{n=0}^{qk-1}f(n)=q\left(\sum_{n=0}^{k-1}f(n)\right),
$$

where multiplication by $q$ means repeated addition in $E$.

**Proof sketch.** Partition the index set $\{0,1,\ldots,qk-1\}$ into the $q$ blocks

$$
B_j=\{jk,jk+1,\ldots,jk+k-1\},\qquad 0\le j<q.
$$

For every $0\le r<k$, repeated periodicity gives $f(jk+r)=f(r)$. Therefore

$$
\sum_{n\in B_j}f(n)=\sum_{r=0}^{k-1}f(r)
$$

for each $j$. Summing these $q$ identical block sums proves the identity. Equivalently, one may induct on $q$: the step from $q$ to $q+1$ appends one block of length $k$, whose sum equals the first-period sum. $\square$

The theorem remains meaningful for $q=0$, when both sides are the additive identity. It also permits $k=0$ as a degenerate algebraic boundary, though averaging by $k$ then has no probabilistic interpretation.

For real sequences and positive block counts, division yields the main averaging identity.

**Theorem 3.2 (Exact periodic averaging).** Let $f:\mathbb N\to\mathbb R$ be periodic with positive period $k$. For every positive integer $q$,

$$
C_{qk}(f)=C_k(f).
$$

**Proof sketch.** By Theorem 3.1,

$$
\sum_{n=0}^{qk-1}f(n)=q\sum_{n=0}^{k-1}f(n).
$$

Divide by $qk$. Since $q>0$ and $k>0$, cancellation gives

$$
\frac{q\sum_{n=0}^{k-1}f(n)}{qk}
=
\frac{
\sum_{n=0}^{k-1}f(n)}{k}.
$$

The right-hand side is $C_k(f)$. $\square$

The positivity of $q$ prevents a meaningless zero-length average. If one defines the zero-length expression by a separate convention, the complete-block sum remains valid, but it should not be confused with an empirical mean.

## 4. Exact Cesàro equilibria in quantum dynamics

We now combine finite-order recurrence with exact periodic averaging.

**Theorem 4.1 (Finite-order Born averaging).** Let $G$ be any state set, let $U$ be an evolution satisfying $U^k=I$ for some $k>0$, and let $\psi_0$ be any initial state. For every state $x\in G$ and every positive integer $q$,

$$
\frac{1}{qk}\sum_{n=0}^{qk-1}|(U^n\psi_0)(x)|^2
=
\frac{1}{k}\sum_{n=0}^{k-1}|(U^n\psi_0)(x)|^2.
$$

**Proof sketch.** Finite order implies $U^{n+k}=U^n$, hence

$$
|(U^{n+k}\psi_0)(x)|^2=|(U^n\psi_0)(x)|^2.
$$

The sequence $n\mapsto p_n(x)$ has period $k$. The result is Theorem 3.2 applied to this sequence. $\square$

This theorem identifies the **one-period empirical distribution**

$$
\mu(x)=\frac{1}{k}\sum_{n=0}^{k-1}p_n(x)
$$

as a canonical time-averaged equilibrium. For every $q>0$, one has $\overline p_{qk}=\mu$ coordinatewise. Since each $p_n$ is normalized, summing over vertices shows

$$
\sum_{x\in G}\mu(x)
=
\frac{1}{k}\sum_{n=0}^{k-1}\sum_{x\in G}p_n(x)
=1.
$$

Thus $\mu$ is itself a probability distribution.

The result is exact at finite time. There is no asymptotic error term and no dependence on a spectral gap. This strength comes with a precise scope: the observation window must contain complete periods.

## 5. Characterization of uniform complete-block mixing

Periodicity determines the stability of the empirical distribution but not its shape. Uniformity has a finite necessary and sufficient condition.

**Theorem 5.1 (One-period criterion for uniform mixing).** Let $G$ be finite and nonempty, let $U^k=I$ with $k>0$, and let $p_n$ be the Born distributions from an initial state $\psi_0$. The following statements are equivalent:

1. For every positive integer $q$, every $x\in G$ satisfies

$$
\frac{1}{qk}\sum_{n=0}^{qk-1}p_n(x)=\frac{1}{|G|}.
$$

2. Every $x\in G$ satisfies

$$
\frac{1}{k}\sum_{n=0}^{k-1}p_n(x)=\frac{1}{|G|}.
$$

**Proof sketch.** If the first statement holds, choose $q=1$ to obtain the second. Conversely, assume the second. Theorem 4.1 says that each $q$-period average equals the one-period average at every vertex, so it equals $1/|G|$. $\square$

This equivalence converts an infinite universal condition over all complete-block lengths into a finite check. It also prevents an overstatement: finite order alone does not imply uniform mixing. The one-period orbit may spend unequal average probability at different vertices.

The limiting corollary is immediate.

**Theorem 5.2 (Exact complete-block convergence).** Under the hypotheses of Theorem 5.1, suppose the one-period empirical distribution is uniform. Then for every $x\in G$,

$$
\lim_{q\to\infty}
\frac{1}{(q+1)k}
\sum_{n=0}^{(q+1)k-1}p_n(x)
=
\frac{1}{|G|}.
$$

**Proof sketch.** For every $q\ge 0$, the observation window contains the positive number $q+1$ of complete periods. Theorem 4.1 and the one-period hypothesis show that every term of the sequence equals $1/|G|$. A constant sequence converges to its constant value. $\square$

The theorem is stronger than an ordinary convergence result. No burn-in time is required along complete-block windows, and the finite-time error is identically zero.

## 6. Separation from instantaneous mixing

It is important to distinguish the preceding result from pointwise convergence of $p_n$.

**Proposition 6.1 (Recurrence obstruction).** Suppose $U^k=I$ and $p_0$ is not uniform. Then the instantaneous distributions $p_n$ do not converge to the uniform distribution.

**Proof sketch.** At every time $qk$, the state is $U^{qk}\psi_0=\psi_0$, hence $p_{qk}=p_0$. If $p_n$ converged to the uniform distribution, every subsequence would have the same limit. But the subsequence $p_{qk}$ is constantly equal to the nonuniform distribution $p_0$. This is impossible. $\square$

Together, Proposition 6.1 and Theorem 5.2 reveal the sharp distinction: periodic dynamics can fail maximally to converge in snapshots while possessing an exact uniform empirical equilibrium.

## 7. Examples

### 7.1 Cyclic shift: exact uniform averaging

Let $G=\mathbb Z/m\mathbb Z$, and define $U$ on basis states by

$$
U|x\rangle=|x+1\bmod m\rangle.
$$

Then $U^m=I$. Starting from $|0\rangle$, the state at time $n$ is $|n\bmod m\rangle$, so

$$
p_n(x)=
\begin{cases}
1,&x\equiv n\pmod m,\\
0,&\text{otherwise}.
\end{cases}
$$

During one period, every vertex receives probability $1$ exactly once and $0$ otherwise. Hence

$$
\mu(x)=\frac{1}{m}.
$$

The walk does not mix instantaneously—every snapshot is concentrated at one vertex—but it mixes uniformly over every complete block of $m$ steps.

### 7.2 A periodic but nonuniform evolution

Let $G=\{0,1\}$ and let

$$
U=
\begin{pmatrix}
1&0\\
0&-1
\end{pmatrix}.
$$

Then $U^2=I$. Starting from $|0\rangle$, one has $U^n|0\rangle=|0\rangle$ for every $n$. Thus

$$
p_n(0)=1,\qquad p_n(1)=0.
$$

The one-period empirical distribution is $(1,0)$, and Theorem 4.1 shows that every complete-block average is also $(1,0)$. This example demonstrates why the uniform one-period condition in Theorem 5.1 is essential.

### 7.3 A nonuniform four-step orbit

Consider abstract probability snapshots on three states:

$$
p_0=(1,0,0),\quad
p_1=\left(\frac12,\frac12,0\right),\quad
p_2=(0,1,0),\quad
p_3=(0,0,1),
$$

repeated with period $4$. Their one-period mean is

$$
\mu=\left(\frac{3}{8},\frac{3}{8},\frac14\right).
$$

Every $4q$-step average equals this same nonuniform vector. This purely probabilistic illustration isolates the block mechanism from the details of a quantum realization.

## 8. Algorithms and computational complexity

The exact theorem leads to simple computational procedures.

### 8.1 One-period empirical equilibrium

Given the probability vectors $p_0,\ldots,p_{k-1}$ on $m$ states, initialize an accumulator vector $s=0$. Add every period vector to $s$, then return $s/k$. The procedure uses $O(m)$ storage and $O(mk)$ arithmetic operations. If the state vectors must first be evolved by dense $m\times m$ matrices, generating the orbit costs $O(km^2)$; sparse or structured Cayley operators can be substantially cheaper.

### 8.2 Uniformity test

After computing $\mu$, compare each coordinate with $1/m$. In exact arithmetic, equality gives a definitive answer. In floating-point arithmetic, use a declared tolerance and report the maximum deviation

$$
\|\mu-\nu_G\|_\infty=
\max_{x\in G}\left|\mu(x)-\frac1m\right|.
$$

The comparison costs $O(m)$. By Theorem 5.1, no additional complete periods need to be simulated.

### 8.3 Complete-window prediction

For any positive $q$, return the already computed vector $\mu$ as the empirical distribution over $qk$ steps. This prediction costs $O(m)$ to copy or $O(1)$ if the same immutable vector is referenced. A naive simulation would require $O(qmk)$ additions after the orbit probabilities are available. The theorem therefore removes a factor of $q$.

### 8.4 Handling arbitrary windows

For an observation length $N$, write

$$
N=qk+r,\qquad 0\le r<k.
$$

Then

$$
\sum_{n=0}^{N-1}p_n
=q\sum_{n=0}^{k-1}p_n+
\sum_{n=0}^{r-1}p_n.
$$

This identity is not needed for the complete-block theorem, but it gives an efficient algorithm for arbitrary windows: precompute the period sum and all prefix sums. Each query can then be answered in $O(m)$ time after $O(mk)$ preprocessing. It also shows that the only discrepancy from exact one-period averaging comes from a single incomplete remainder.

## 9. Applications and interpretation

### 9.1 Quantum-walk experiments

An experiment that samples at times spanning an integer number of periods measures the one-period empirical law exactly in the ideal finite-order model. Gathering more complete periods can reduce statistical sampling noise in repeated measurements, but it does not alter the underlying temporal average. This separates physical measurement noise from dynamical convergence error.

### 9.2 Periodically driven systems

The result applies coordinatewise to any periodic observable sequence. In a periodically driven system, the average of an observable over $q$ complete drive cycles equals its average over one cycle. Quantum-walk probabilities are one instance of a broader cycle-averaging principle.

### 9.3 Benchmarking and simulation

Long simulations of periodic systems may misleadingly appear to “converge” numerically. The exact identity supplies a benchmark: complete-block averages should agree up to numerical roundoff. Disagreement indicates an incorrect period, accumulated numerical error, or a model that is only approximately periodic.

### 9.4 Spectral analysis

If $U$ is diagonalizable with eigenvalues $e^{i\theta_j}$, amplitudes contain oscillatory factors $e^{in\theta_j}$. Time-averaged probabilities involve products with phases $e^{in(\theta_j-\theta_\ell)}$. Averaging cancels contributions from distinct phase differences over suitable cycles, while terms within degenerate eigenspaces can survive. The complete-block theorem does not itself characterize uniformity, but it reduces that question to the finite one-period distribution. On finite abelian Cayley graphs, Fourier characters provide a natural language for expressing the surviving contributions.

## 10. Limitations

First, the theory does not claim instantaneous mixing. On the contrary, exact recurrence generally obstructs it. Second, periodicity does not guarantee that the empirical equilibrium is uniform; Theorem 5.1 supplies a criterion rather than an automatic conclusion. Third, exact finite-time equality is asserted only for observation windows whose lengths are positive multiples of the period. Incomplete windows contain a remainder that can bias the average. Fourth, the results concern ideal finite-order dynamics. Approximate periodicity, noise, and open-system effects require stability estimates beyond the exact algebraic identity.

The argument also does not require unitarity once periodicity of the observed sequence has been established. Unitarity is part of the physical interpretation and ensures normalized quantum evolution, but the block theorem itself is purely additive.

## 11. Future research directions

A first objective is a sharp remainder estimate for arbitrary $N=qk+r$. Since complete blocks cancel exactly, one expects the total-variation discrepancy between the $N$-step average and the one-period average to be of order $k/N$. Determining the optimal universal constant requires analyzing extremal within-period mass profiles.

A second objective is a spectral characterization of uniform Cesàro mixing for translation-invariant walks on finite abelian Cayley graphs. Time averaging eliminates interference between distinct eigenphases but preserves interactions inside degenerate eigenspaces. A character-theoretic criterion should express exactly when the surviving off-diagonal contributions vanish at every vertex.

Third, weak decoherence may convert empirical mixing into genuine instantaneous mixing. If each step is followed by depolarization of strength $\varepsilon>0$, nonconstant modes should contract rather than merely rotate. Quantitative relaxation bounds should involve both $\varepsilon$ and the spectral gap of the associated classical support graph.

Fourth, finite nonabelian Cayley graphs call for a representation-theoretic obstruction formulated through matrix coefficients and isotypic components. The complete-block theorem is representation-independent, leaving the spectral degeneracy structure as the central difficulty.

Finally, periodicity itself can be studied through cyclotomic spectra. In finite dimension, finite order forces eigenvalues to be roots of unity, while projective recurrence is governed by ratios of eigenvalues. Effective bounds on periods in algebraic models would connect number-theoretic degree and root-of-unity orders to computational observation lengths.

## 12. Broader structural perspective

The results can be viewed as a statement about quotienting time by periodicity. Once a sequence has period $k$, every index $n$ has a residue $r$ with $0\le r<k$, and the value at time $n$ is determined by that residue. A complete observation block samples every residue class equally often. The empirical mean is therefore the pushforward of uniform counting measure on the cyclic time set $\mathbb Z/k\mathbb Z$. Repeating the block changes the number of representatives but not their relative weights.

This perspective explains both the strength and the boundary of the theorem. Complete blocks are balanced samples of temporal phases, so their equality is exact. An incomplete block overweights the first few residues, causing the only possible discrepancy. Uniform spatial mixing then asks whether the map from temporal phase to spatial Born distribution sends uniform temporal measure to uniform spatial measure. The answer depends on the orbit, not merely on its period.

The distinction also clarifies the role of spectral gaps in the title and broader research program. No positive gap can force dissipative convergence in a strictly finite-order unitary orbit, because all modes recur. Spectral information is instead relevant to determining the period and the shape of the one-period average, especially the interference that survives eigenphase degeneracy. Thus, in the periodic regime, finite cyclic symmetry replaces decay estimates as the primary mechanism of temporal stabilization.

## 13. Conclusion

Finite-order quantum walks do not generally forget their initial states. Their exact recurrence prevents ordinary convergence from a localized distribution to uniformity. Nevertheless, their empirical statistics possess an exact and canonical equilibrium. The sum over any number of complete periods is the corresponding number of copies of the one-period sum, so every positive complete-block Cesàro mean equals the one-period mean.

For finite state spaces, uniform time-averaged mixing along all complete periods is equivalent to checking uniformity over a single period. If that finite criterion holds, complete-block convergence has zero error at every sampled block length. This replaces an asymptotic question by a finite calculation and makes precise the distinction between a moving state and a settled history: the instantaneous walk may recur forever, while its complete-cycle average is stationary from the first period onward.
