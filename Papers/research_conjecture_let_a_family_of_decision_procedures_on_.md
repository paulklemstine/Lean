# Size-Indexed Landauer Bounds for Finite Boolean Registers

**Aristotle**  
**22 July 2026**

## Abstract

We establish a direct bridge between finite logical information loss and finite-temperature work for complete reset of an $n$-bit Boolean register. The register has exactly $2^n$ states, and reset maps all of them to one state; consequently its cardinality-based information loss is exactly $n$ bits. For a finite ensemble of physical trajectories satisfying a Jarzynski fluctuation condition at positive temperature $T$, with information-loss free-energy change $kTn\log 2$, the expected work obeys the size-indexed Landauer inequality

$$
\mathbb E[W_n]\ge kTn\log 2.
$$

The conclusion is independent of an arbitrary runtime function, making explicit that computational time and irreversible information loss are distinct resources even when both are indexed by input size. We also prove a monotone extension: any lower bound $b(n)$ on discarded bits yields $\mathbb E[W_n]\ge kT b(n)\log 2$. Finally, we obtain the finite-size tail estimate

$$
\Pr\!\left(W_n<kTn\log 2-\xi\right)
\le \exp\!\left(-\frac{\xi}{kT}\right),
$$

which controls rare trajectories that undercut the mean-work threshold. We give computational procedures for evaluating thresholds and tail bounds, numerical examples at room temperature, applications to reversible architecture and memory management, and a discussion of conditional entropy, nonuniform inputs, and correlated sequential erasure.

## 1. Introduction

Logical irreversibility and computational runtime answer different questions. Runtime asks how many transitions are required to obtain an output. Logical irreversibility asks how many input distinctions cannot be reconstructed from the output. A process may run quickly while destroying much information, or run slowly while preserving every intermediate distinction. Nevertheless, discussions of physical computation often blur these resources by treating “efficient computation” as though it directly implied “energetically inexpensive computation.”

The simplest setting in which to separate them is full reset of a finite Boolean register. An $n$-bit register has $2^n$ possible logical states. Complete reset sends every state to one standard state. The number of discarded bits is therefore exactly $n$. This count depends only on the logical map, not on how many clock cycles precede reset.

To obtain a physical work statement, logical counting must be paired with a dynamical assumption. We use a finite-outcome Jarzynski condition. If $W_n$ is the random work of the reset, $\Delta F_n$ is the free-energy change assigned to the discarded information, and $\beta=(kT)^{-1}$, the condition is

$$
\mathbb E\!\left[e^{-\beta(W_n-\Delta F_n)}\right]\le 1.
$$

Convexity then gives the second-law inequality $\mathbb E[W_n]\ge\Delta F_n$. Substituting $\Delta F_n=kTn\log 2$ yields the principal bound.

Three features sharpen the result. First, the bit count is exact rather than asymptotic. Second, the theorem accepts any runtime function and does not use it, so the separation of resources is part of the statement rather than an informal observation. Third, the same fluctuation hypothesis yields an exponential upper bound on low-work events, strengthening expectation-level control.

The paper proceeds from finite combinatorics to fluctuation analysis. Section 2 defines registers, reset, discarded bits, finite probability ensembles, work, and the Jarzynski condition. Section 3 proves the exact information-loss identity. Section 4 establishes the mean-work results. Section 5 derives the tail bound. Section 6 gives algorithms and numerical examples. Sections 7–9 discuss applications, limitations, and extensions.

## 2. Definitions and setting

### 2.1 Boolean registers and reset

For a natural number $n$, let

$$
\mathcal B_n=\{0,1\}^{\{0,1,\ldots,n-1\}}
$$

be the state space of an $n$-bit Boolean register. An element $x\in\mathcal B_n$ assigns one Boolean value to each of the $n$ positions. The empty register $\mathcal B_0$ has one state, as expected from the empty product convention.

**Definition 2.1 (Complete reset).** The complete reset map is the constant function

$$
R_n:\mathcal B_n\longrightarrow\{\ast\},
\qquad R_n(x)=\ast.
$$

Thus every input state reaches the same unique output state.

**Definition 2.2 (Cardinality-based discarded information).** For complete reset, define the number of discarded bits by

$$
D(n)=\log_2|\mathcal B_n|-\log_2|\operatorname{im}(R_n)|.
$$

Since the image consists of one state, the second term is zero. This definition is appropriate for a uniform logical ensemble: all register states are counted equally. For a nonuniform ensemble, Shannon entropy is the natural refinement, discussed in Section 8.

### 2.2 Finite physical trajectories

For each size $n$, let $\Omega_n$ be a finite set of microscopic outcomes or trajectories. Let

$$
p_n:\Omega_n\to[0,1]
$$

satisfy

$$
\sum_{\omega\in\Omega_n}p_n(\omega)=1.
$$

Let $W_n:\Omega_n\to\mathbb R$ be the work performed on the system along a trajectory. Its expected value is

$$
\mathbb E[W_n]=\sum_{\omega\in\Omega_n}p_n(\omega)W_n(\omega).
$$

We take Boltzmann's constant $k>0$ and absolute temperature $T>0$, and write

$$
\beta=\frac{1}{kT}.
$$

The positivity assumptions ensure $\beta>0$ and make all order-preserving steps below valid.

**Definition 2.3 (Information-loss free energy).** The free-energy change associated with complete reset is

$$
\Delta F_n=kT\,D(n)\log 2.
$$

The factor $\log 2$ converts bits, measured with base-two logarithms, into natural-logarithmic thermodynamic units.

**Definition 2.4 (Jarzynski condition).** The size-$n$ physical process satisfies the Jarzynski condition for $\Delta F_n$ if

$$
\sum_{\omega\in\Omega_n}p_n(\omega)
\exp\!\left[-\beta\bigl(W_n(\omega)-\Delta F_n\bigr)\right]
\le 1.
$$

The equality form is standard for idealized driven systems initialized in equilibrium. The weak inequality used here is sufficient and permits additional dissipation. All results are conditional on this relation; finite cardinality alone does not imply a work bound.

### 2.3 Runtime as an independent index

Let

$$
r:\mathbb N\to\mathbb N
$$

be any runtime function. No regularity, monotonicity, or complexity bound is imposed. It may represent the duration of a decision procedure whose memory is subsequently reset. The function is included to make a structural point: the conclusions below hold for every $r$ because their derivation uses information loss and the fluctuation condition, not running time.

## 3. Exact combinatorics of complete reset

**Lemma 3.1 (Register cardinality).** For every natural number $n$, the $n$-bit register has exactly $2^n$ states:

$$
|\mathcal B_n|=2^n.
$$

**Proof sketch.** Each of the $n$ coordinates has two independent choices. The product rule gives $2\cdot2\cdots2=2^n$. Equivalently, induction begins with one empty assignment at $n=0$; adding one coordinate doubles the number of assignments. $\square$

**Theorem 3.2 (Exact discarded-bit count).** Complete reset of an $n$-bit Boolean register discards exactly $n$ bits:

$$
D(n)=n.
$$

**Proof sketch.** By Lemma 3.1, the input state space has cardinality $2^n$. The constant reset map has a one-element image. Therefore

$$
D(n)=\log_2(2^n)-\log_2(1)=n-0=n.
$$

The identity includes $n=0$, where no information and no positive reset cost are asserted. $\square$

The theorem concerns logical distinctions. It should not be read as saying that any state change discards a bit. A bijection $f:\mathcal B_n\to\mathcal B_n$ has full image and is logically reversible; from $f(x)$ one can recover $x$. Complete reset is maximally many-to-one: it merges all $2^n$ alternatives.

## 4. Expected-work inequalities

We first record the analytic step that converts a fluctuation relation into a mean-work inequality.

**Lemma 4.1 (Finite Jarzynski second-law inequality).** Let $\Omega$ be finite, let $p$ be a probability distribution on $\Omega$, let $W:\Omega\to\mathbb R$, let $\beta>0$, and let $\Delta F\in\mathbb R$. If

$$
\sum_{\omega\in\Omega}p(\omega)
 e^{-\beta(W(\omega)-\Delta F)}\le 1,
$$

then

$$
\sum_{\omega\in\Omega}p(\omega)W(\omega)\ge\Delta F.
$$

**Proof sketch.** The function $x\mapsto e^x$ is convex. Jensen's inequality gives

$$
\exp\!\left(
-\beta\left(\sum_{\omega}p(\omega)W(\omega)-\Delta F\right)
\right)
\le
\sum_{\omega}p(\omega)e^{-\beta(W(\omega)-\Delta F)}
\le1.
$$

The exponential is increasing and $e^0=1$, so the exponent is nonpositive. Dividing by the positive number $\beta$ yields the claim. $\square$

**Theorem 4.2 (Size-Indexed Landauer Bound).** Suppose $k>0$ and $T>0$. For every size $n$, let $p_n$ be a probability distribution on a finite outcome space, and let $W_n$ be the trajectory work. Assume the Jarzynski condition holds with

$$
\Delta F_n=kT\,D(n)\log2.
$$

Then, for every runtime function $r:\mathbb N\to\mathbb N$ and every $n$,

$$
\mathbb E[W_n]\ge kTn\log2.
$$

**Proof sketch.** Positivity of $k$ and $T$ gives $\beta=(kT)^{-1}>0$. Apply Lemma 4.1 to obtain $\mathbb E[W_n]\ge\Delta F_n$. Theorem 3.2 gives $D(n)=n$, hence $\Delta F_n=kTn\log2$. The runtime $r$ is arbitrary and is absent from every premise used in the derivation. $\square$

**Corollary 4.3 (One-bit Landauer bound).** Under the assumptions of Theorem 4.2, complete reset of one bit satisfies

$$
\mathbb E[W_1]\ge kT\log2.
$$

**Corollary 4.4 (Additive scaling for full registers).** Under the same assumptions, the threshold for complete reset is additive in register size:

$$
\Delta F_{m+n}=\Delta F_m+\Delta F_n.
$$

**Proof sketch.** Substitute $\Delta F_j=kTj\log2$ and use $m+n$ distributivity. This additivity reflects the uniform Cartesian-product model. For correlated or nonuniform registers, conditional entropy is needed to avoid overcounting. $\square$

The theorem does not assert that all devices attain equality. It supplies a lower bound under a fluctuation condition. Friction, leakage, imperfect control, finite-time driving, and auxiliary resets can all increase actual work.

### 4.1 Lower estimates for discarded information

Exact information loss may be unavailable in a more complex architecture. A certified lower estimate still transfers to work.

**Theorem 4.5 (Discarded-Bits Lower-Bound Theorem).** Under the physical assumptions of Theorem 4.2, let $b:\mathbb N\to\mathbb R$ satisfy

$$
b(n)\le D(n)
$$

for every $n$. Then

$$
\mathbb E[W_n]\ge kT\,b(n)\log2
$$

for every $n$.

**Proof sketch.** Since $2\ge1$, $\log2\ge0$. Since $k,T>0$, also $kT\ge0$. Thus multiplication preserves the assumed inequality:

$$
kT\,b(n)\log2\le kT\,D(n)\log2=\Delta F_n.
$$

Lemma 4.1 gives $\Delta F_n\le\mathbb E[W_n]$; transitivity proves the result. $\square$

This theorem is deliberately one-sided. An underestimate $b(n)$ yields a valid but possibly nonsharp work floor. No conclusion follows from a purported bound that exceeds the actual discarded information.

## 5. Finite-size fluctuation control

Expectation bounds allow individual trajectories below threshold. The same exponential condition quantifies their probability.

**Lemma 5.1 (Exponential low-work tail).** Under the hypotheses of Lemma 4.1, for every real margin $\xi$,

$$
\Pr(W<\Delta F-\xi)\le e^{-\beta\xi}.
$$

**Proof sketch.** Define $Y=e^{-\beta(W-\Delta F)}$, which is nonnegative. On the event $W<\Delta F-\xi$, one has $Y>e^{\beta\xi}$. Therefore Markov's inequality and the Jarzynski condition give

$$
\Pr(W<\Delta F-\xi)
\le \Pr(Y\ge e^{\beta\xi})
\le e^{-\beta\xi}\mathbb E[Y]
\le e^{-\beta\xi}.
$$

Strict and weak event boundaries do not affect the stated upper estimate. $\square$

**Theorem 5.2 (Finite-Size Landauer Violation Bound).** Under the assumptions of Theorem 4.2, for every register size $n$ and real margin $\xi$,

$$
\Pr\!\left(W_n<kTn\log2-\xi\right)
\le
\exp\!\left(-\frac{\xi}{kT}\right).
$$

**Proof sketch.** Apply Lemma 5.1 with $\Delta F=\Delta F_n$ and $\beta=(kT)^{-1}$, then substitute $D(n)=n$ from Theorem 3.2. $\square$

For $\xi>0$, the estimate is informative: the probability bound decays exponentially in the margin measured in units of $kT$. At $\xi=0$, it gives the trivial upper bound one. For $\xi<0$, the right side exceeds one and remains mathematically valid but not probabilistically sharp. Thus practical use naturally focuses on nonnegative margins.

A convenient dimensionless margin is $a=\xi/(kT)$. The bound becomes

$$
\Pr(W_n<kT(n\log2-a))\le e^{-a}.
$$

For $a=1,5,10$, the respective upper bounds are approximately $0.3679$, $0.006738$, and $0.00004540$. These values are independent of $n$; register size shifts the threshold, while the chosen deficit in thermal units controls the tail estimate.

## 6. Computational procedures and numerical examples

### 6.1 Threshold evaluation

Given $n$, $T$, and $k$, the exact logical-state count is $2^n$, the discarded information is $n$ bits, and the work threshold is

$$
L(n,T)=kTn\log2.
$$

The direct numerical algorithm requires constant-time floating-point arithmetic once $n$ is supplied. Computing $2^n$ explicitly is unnecessary for the energy threshold and can be infeasible for large $n$; the logarithmic identity should be used instead. If the exact integer state count is requested, exponentiation by squaring uses $O(\log n)$ integer multiplications, with bit complexity governed by the $n$-bit output.

At room temperature $T=300\,\mathrm K$, taking

$$
k=1.380649\times10^{-23}\,\mathrm{J/K}
$$

gives a one-bit threshold

$$
L(1,300)\approx2.87098\times10^{-21}\,\mathrm J.
$$

Representative complete-reset bounds are:

| Register size $n$ | Logical states | Discarded bits | Minimum mean work at $300\,\mathrm K$ |
|---:|---:|---:|---:|
| $1$ | $2$ | $1$ | $2.871\times10^{-21}\,\mathrm J$ |
| $8$ | $256$ | $8$ | $2.297\times10^{-20}\,\mathrm J$ |
| $64$ | $2^{64}$ | $64$ | $1.837\times10^{-19}\,\mathrm J$ |
| $10^6$ | $2^{10^6}$ | $10^6$ | $2.871\times10^{-15}\,\mathrm J$ |

These are ideal lower bounds, not typical device-consumption estimates.

### 6.2 Tail-bound evaluation

For a margin $\xi\ge0$, compute

$$
q(\xi,T)=e^{-\xi/(kT)}.
$$

Numerically, it is often preferable to specify $\xi=a kT$, in which case $q=e^{-a}$; this avoids underflow in forming very small energy values. Evaluation is constant time for each margin. For a grid of $m$ margins, complexity is $O(m)$ time and $O(m)$ output space, or $O(1)$ auxiliary space when values are streamed.

At $T=300\,\mathrm K$, $kT\approx4.14195\times10^{-21}\,\mathrm J$. A trajectory undercutting the Landauer threshold by $5kT$ has probability at most $e^{-5}\approx0.006738$; a deficit of $10kT$ has probability at most $e^{-10}\approx4.54\times10^{-5}$.

### 6.3 Checking a finite trajectory ensemble

Suppose finite arrays contain probabilities $p_i$ and works $W_i$. A diagnostic procedure first checks $p_i\ge0$ and $\sum_i p_i=1$ within a stated numerical tolerance. It then evaluates

$$
J=\sum_i p_i e^{-\beta(W_i-\Delta F)}.
$$

If $J\le1$, the Jarzynski condition is numerically consistent with the data at that tolerance, and the theoretical inequalities apply to the exact model represented by those values. Direct exponentiation can overflow, so a robust implementation uses a log-sum-exp computation for $\log J$. This algorithm runs in $O(m)$ time for $m$ outcomes and uses $O(1)$ auxiliary storage when streamed.

Numerical checking does not replace the physical assumption: empirical sampling introduces uncertainty, and rounded arrays may not equal the true trajectory distribution. The procedure is best viewed as a transparent illustration and model diagnostic.

## 7. Applications

### 7.1 Memory clearing and secure deletion

Systems often overwrite buffers after processing sensitive material. The result identifies the ideal thermodynamic floor associated with destroying uniformly distributed logical distinctions. A full $n$-bit clear has a linear lower bound in $n$, regardless of whether the preceding encryption, authentication, or search was fast or slow.

This does not mean a software overwrite alone realizes an ideal physical reset; logical layers, caches, storage encoding, and controller state complicate the map. The theorem instead supplies an accounting principle: identify the actual many-to-one physical operation and count the distinctions it destroys.

### 7.2 Reversible computation

A reversible simulation replaces many-to-one intermediate transitions by injective transitions that retain enough history to reconstruct prior configurations. In the finite uniform model, an injection does not reduce logical-state cardinality, so the combinatorial loss can be postponed. If the history tape is later reset, however, that localized operation incurs the corresponding information-loss cost under the fluctuation hypothesis.

The result therefore supports an architectural decomposition: computational difficulty concerns producing the answer, while Landauer cost attaches to the information deliberately discarded. Reversible design does not deny the bound; it changes where the hypothesis of erasure applies.

### 7.3 Low-power and stochastic devices

As devices approach thermal scales, average-work statements alone become incomplete because fluctuations become visible. The finite-size tail theorem offers a direct reliability estimate for trajectories below a chosen threshold. Conversely, observed frequent low-work events beyond the exponential allowance would signal that at least one modeling assumption—free-energy assignment, probability model, temperature calibration, or fluctuation relation—requires revision.

### 7.4 Complexity and thermodynamics

Let a decision procedure have runtime $r(n)$ and clear $n$ unbiased workspace bits. Theorem 4.2 holds for arbitrary $r$. Thus a polynomial runtime hypothesis neither strengthens nor weakens this particular lower bound. Likewise, superpolynomial runtime does not by itself force a larger reset cost. A physically informative complexity theory should therefore track at least two resources: transitions performed and information irreversibly exported.

## 8. Scope, limitations, and generalizations

### 8.1 Uniform versus nonuniform data

Cardinality-based loss treats all $2^n$ states as equally relevant. If input $X$ has distribution $p$, the more precise quantity for reset is Shannon entropy

$$
H(X)=-\sum_x p(x)\log_2 p(x).
$$

For a deterministic map $f$, a natural logical loss is

$$
H(X)-H(f(X)).
$$

A many-to-one map may have large fibers but destroy little probable information if almost all mass lies on states that remain distinguishable. Extending the bridge from cardinality to entropy would capture this distinction.

### 8.2 Retained side information

If a second memory $Y$ remains available and is correlated with $X$, resetting $X$ need not destroy all of $H(X)$. The relevant quantity is conditional entropy

$$
H(X\mid Y)=H(X,Y)-H(Y).
$$

For trivial $Y$, this reduces to $H(X)$; for a perfect copy of $X$, it is zero. A conditional Landauer theorem would therefore distinguish genuine destruction from information merely relocated into side memory.

### 8.3 Sequential erasure and correlations

Adding separate unconditional costs can overcount when erased registers are correlated. The entropy chain rule

$$
H(X_1,\ldots,X_m)=\sum_{j=1}^m H(X_j\mid X_1,\ldots,X_{j-1})
$$

suggests the correct incremental accounting. Exact additivity for independent uniform registers is recovered as a special case.

### 8.4 Finite outcomes and model assumptions

The present setting uses finite trajectory spaces, avoiding measure-theoretic integrability issues. Continuous-state extensions require measurable work functions and exponential integrability. More fundamentally, the Jarzynski condition and the choice $\Delta F=kTD(n)\log2$ are physical premises. The conclusions do not claim that arbitrary logical maps automatically generate those dynamics.

### 8.5 Temperature and sign conventions

The assumption $T>0$ is essential to define a positive inverse temperature in this form. Work is taken as work performed on the system, so positive dissipated work corresponds to the displayed lower bounds. Alternative sign conventions require systematic reversal. The case $n=0$ correctly gives a zero threshold.

## 9. Future research directions

A first extension should replace uniform complete reset by conditional information loss with retained side memory. For a joint memory $(X,Y)$ in which $Y$ is retained, the exact cost should be indexed by $H(X\mid Y)$, recovering the present result when $Y$ is trivial and $X$ is uniform.

Second, nonuniform inputs call for a pushforward-entropy theorem proportional to $H(p)-H(f_*p)$. Such a result would separate algebraically large but unused fibers from many-to-one behavior that destroys likely distinctions.

Third, reversible simulation should be modeled as an injective, clocked transition system with a retained history tape. The computational phase would have zero cardinality loss in the finite model; reset of the history would carry the thermodynamic charge. Quantitative work is needed to control clock, history, and workspace overhead simultaneously.

Fourth, correlated sequential procedures require a conditional-entropy chain rule. Exact addition should emerge under suitable independence assumptions, while data processing should provide inequalities in the general case.

Fifth, complexity classes can be enriched with explicit clocks and compiler overhead. A stable hierarchy collapse could then be asked to produce uniform quantitative simulations rather than extensional inclusions alone.

Finally, cyclic bounded-memory implementations may support a genuine two-resource hierarchy. One seeks computation families with polynomial runtime but superlogarithmic unavoidable entropy export, and other families with long runtime but asymptotically small dissipation per step. The present separation of runtime from reset loss provides the base case for formulating such comparisons without conflating their units.

## 10. Conclusion

Complete reset of an $n$-bit Boolean register merges exactly $2^n$ logical states into one and therefore discards exactly $n$ bits. When a finite-temperature trajectory ensemble satisfies the Jarzynski condition with the corresponding free-energy change, this exact combinatorial identity yields

$$
\mathbb E[W_n]\ge kTn\log2.
$$

Any lower estimate $b(n)$ on discarded bits transfers monotonically to $kT b(n)\log2$. Moreover, trajectories beating the threshold by $\xi$ have probability at most $e^{-\xi/(kT)}$. These statements require no runtime assumption and remain valid for every runtime function.

The resulting picture is precise: time measures the duration or number of computational transitions, while Landauer cost measures irreversible loss of distinguishability. A complete physical account of computation needs both ledgers.