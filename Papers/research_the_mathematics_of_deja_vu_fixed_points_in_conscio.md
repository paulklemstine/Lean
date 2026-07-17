# The Mathematics of Déjà Vu: Periodic Recurrence, Interval Dynamics, and Tropical Spectral Drift

**Aristotle**  
**July 17, 2026**

## Abstract

We develop a self-contained mathematical framework for interpreting déjà vu as recurrence in a discrete dynamical system. A state is periodic when it returns after a positive number of updates, and has exact period $p$ when no earlier positive return occurs. We prove that every positive multiple of a return time is again a return time, that recurrence is preserved by semiconjugate observation maps, and that exact period $3$ yields three pairwise distinct orbit states. For the logistic family $L_r(x)=rx(1-x)$, we establish invariance of the unit interval for $0\le r\le4$, providing a sound domain for numerical experiments near the period-three window at $r=3.83$. We also prove a sharp cautionary result: the continuous contraction $x\mapsto x/2$ has only the periodic point $0$, so continuity on an interval does not imply density of periodic points. Finally, in min-plus dynamics we show that a tropical eigenstate with eigenvalue $\lambda$ evolves by additive drift $k\lambda$ after $k$ steps; eigenvalue zero is therefore equivalent to a fixed state and implies recurrence at every positive time. These results distinguish topological recurrence, exact periodicity, observed recurrence, and probabilistic incidence. In particular, a reported lifetime incidence cannot be equated with a density of periodic points without a measure, an observation horizon, and a tolerance model.

## 1. Introduction

Déjà vu is naturally described as a return: the present seems to coincide with something already experienced. The psychological phenomenon is complex, but the mathematical structure of return can be isolated without pretending that a scalar map is a complete model of consciousness. Let a state space $S$ represent possible cognitive configurations, and let $f:S\to S$ represent one step of evolution. The orbit of $s\in S$ is

$$
s,\ f(s),\ f^2(s),\ldots.
$$

A recurrence occurs when an iterate equals the starting state. This elementary definition immediately raises several distinct questions. Does one return force further returns? Is recurrence visible after coarse observation? What does “period three” guarantee? Does continuity force recurrent states to be common? How should an empirical incidence over people be compared with a property of points? Can recurrence be read from spectral data in a nonclassical linear system?

The answers form a coherent but deliberately guarded theory. Some conclusions are universal and require no topology: return times repeat at positive multiples, semiconjugacy transports periodicity, and exact period three creates three distinct states. Other conclusions depend on the setting. The logistic family preserves $[0,1]$ only in an appropriate parameter range. Density of periodic points is not a consequence of continuity; a contraction supplies a complete counterexample. In tropical dynamics, recurrence appears spectrally as cancellation of additive drift.

This framework is relevant beyond a cognitive metaphor. Recurrence is central in control, symbolic dynamics, scheduling, network timing, and finite-state observation. Semiconjugacy formalizes how a reduced model inherits genuine returns. Min-plus algebra models synchronization and shortest-path timing, where eigenvalues encode long-run cycle time. The same mathematical distinctions—exact versus approximate return, hidden versus observed state, topological versus probabilistic prevalence—are indispensable in each setting.

We make no claim that the logistic parameter $r=3.83$ can be inferred from a reported lifetime incidence near $70\%$. Such a calibration is undefined until distributions, observation windows, and return tolerances are specified. Nor do we infer density of periodic points from continuity. Instead, we identify the precise valid core and formulate algorithms that demonstrate it numerically.

## 2. Discrete recurrence

### 2.1 State evolution and iterates

Let $S$ be a nonempty set and $f:S\to S$ a self-map. Define $f^0$ to be the identity and recursively define $f^{n+1}=f\circ f^n$. Thus $f^n(s)$ is the state reached after $n$ updates.

**Definition 2.1 (Periodic state).** A state $s\in S$ is periodic if there exists an integer $n>0$ such that

$$
f^n(s)=s.
$$

Any such $n$ is a return time. This definition does not require that $n$ be minimal.

**Definition 2.2 (Exact period).** A state $s\in S$ has exact period $p$ if $p>0$, $f^p(s)=s$, and

$$
f^q(s)\ne s\qquad\text{for every integer }q\text{ with }0<q<p.
$$

The exact period is the first positive return time. A fixed point has exact period $1$, even though every positive integer is also a return time.

### 2.2 Arithmetic of return times

**Theorem 2.3 (Positive multiples of a return time).** Let $p>0$ and suppose $f^p(s)=s$. Then, for every integer $k>0$,

$$
f^{pk}(s)=s.
$$

**Proof sketch.** Induct on $k$. The case $k=1$ is the hypothesis. If $f^{pk}(s)=s$, the iterate addition law gives

$$
f^{p(k+1)}(s)=f^p(f^{pk}(s))=f^p(s)=s.
$$

Therefore all positive multiples of $p$ are return times. $\square$

This theorem is universal: it uses neither topology nor algebraic structure on $S$. It also has an observational implication. A list of observed returns at times $p,2p,3p$ need not represent three independent recurrence mechanisms; all may arise from a single fundamental period.

### 2.3 Exact period three

**Theorem 2.4 (Distinctness of an exact three-cycle).** If $s$ has exact period $3$, then

$$
s\ne f(s),\qquad f(s)\ne f^2(s),\qquad f^2(s)\ne s.
$$

Consequently, the orbit segment $s,f(s),f^2(s)$ consists of three pairwise distinct states and repeats cyclically.

**Proof sketch.** The equality $s=f(s)$ would give a return at time $1$. The equality $f^2(s)=s$ would give a return at time $2$. Finally, if $f(s)=f^2(s)$, applying $f$ gives $f^2(s)=f^3(s)=s$, again producing a return at time $2$. Each alternative contradicts exactness. $\square$

The adjective “exact” cannot be omitted. The equation $f^3(s)=s$ alone allows fixed points and therefore does not certify three distinct stages.

## 3. Observation maps and transported recurrence

A scientific observer rarely has access to a complete state. Let $S$ be a hidden state space, $T$ an observed state space, $f:S\to S$ the hidden dynamics, $g:T\to T$ the observed dynamics, and $h:S\to T$ an observation map.

**Definition 3.1 (Semiconjugacy).** The map $h$ semiconjugates $f$ to $g$ when

$$
h\circ f=g\circ h.
$$

Equivalently, $h(f(s))=g(h(s))$ for all $s\in S$. Unlike a conjugacy, a semiconjugacy need not be invertible. It may merge several hidden states into one observation.

**Lemma 3.2 (Iterated semiconjugacy).** If $h\circ f=g\circ h$, then for every integer $n\ge0$,

$$
h\circ f^n=g^n\circ h.
$$

**Proof sketch.** Induct on $n$. The identity is immediate for $n=0$. For the induction step, commute one additional application of $f$ through $h$ and use the induction hypothesis. $\square$

**Theorem 3.3 (Transport of periodicity).** If $h$ semiconjugates $f$ to $g$ and $s$ is periodic under $f$, then $h(s)$ is periodic under $g$. More precisely, every return time of $s$ is a return time of $h(s)$.

**Proof sketch.** Choose $n>0$ with $f^n(s)=s$. By Lemma 3.2,

$$
g^n(h(s))=h(f^n(s))=h(s).
$$

Thus $h(s)$ returns after $n$ observed updates. $\square$

The theorem is one-directional. If $h$ is many-to-one, the equality $g^n(h(s))=h(s)$ only implies $h(f^n(s))=h(s)$, not $f^n(s)=s$. Coarse observation can therefore preserve a genuine hidden recurrence but can also create an apparent recurrence by identifying distinct hidden states. Any empirical model of déjà vu must state which direction it intends: recurrence of the underlying state, recurrence of an observable, or merely approximate similarity of observations.

## 4. The logistic family as a recurrence laboratory

### 4.1 Definition and invariant domain

For a real parameter $r$, define the logistic map

$$
L_r(x)=rx(1-x).
$$

The unit interval is the natural state domain in population-style interpretations and in numerical studies.

**Theorem 4.1 (Invariance of the unit interval).** If $0\le r\le4$ and $x\in[0,1]$, then $L_r(x)\in[0,1]$.

**Proof sketch.** Since $r\ge0$, $x\ge0$, and $1-x\ge0$, we have $L_r(x)\ge0$. Completing the square gives

$$
x(1-x)=\frac14-\left(x-\frac12\right)^2\le\frac14.
$$

Hence

$$
L_r(x)\le \frac r4\le1.
$$

Both bounds follow. $\square$

The theorem guarantees that exact arithmetic never sends an initial point in $[0,1]$ outside that interval when $r\in[0,4]$. Floating-point implementations should still tolerate tiny roundoff errors.

### 4.2 Numerical exploration at $r=3.83$

The value $r=3.83$ lies in a period-three window of the logistic family. A practical exploration begins with several initial states in $(0,1)$, discards a long transient, and inspects blocks of three consecutive values. If an attracting three-cycle dominates the selected basin, values separated by three updates approach one another.

A useful numerical statistic is the lag-three residual

$$
R_3(x;N)=\left|L_r^{N+3}(x)-L_r^N(x)\right|.
$$

Small residuals after a large burn-in support approximate period-three behavior. They do not establish an exact orbit, and they do not imply that all initial conditions have the same asymptotic behavior. A stronger computer-assisted argument would choose three rational intervals $I_0,I_1,I_2$ and prove

$$
L_r(I_0)\subseteq I_1,\qquad L_r(I_1)\subseteq I_2,\qquad L_r(I_2)\subseteq I_0,
$$

as well as a uniform contraction bound for the third iterate on each interval. The present results motivate that program but do not replace it.

### 4.3 Period three and chaos: scope of inference

Classical interval dynamics contains strong theorems linking an exact period-three orbit with a rich hierarchy of periods and Li–Yorke chaos. Those conclusions depend on their full interval-map hypotheses and precise definitions. The results developed here prove only the universal exact-cycle certificate and the invariant interval needed for logistic experiments. They do not derive uncountably many scrambled trajectories, nor do they claim that all continuous maps have dense periodic points.

This boundary is mathematically substantive. An attracting period-three window can exhibit stable local cycling even while other global claims require separate analysis. Periodic attraction, topological mixing, dense periodic points, and Li–Yorke scrambling are related but inequivalent properties.

## 5. Continuity does not imply dense periodicity

### 5.1 Density

**Definition 5.1 (Dense subset).** A subset $P\subseteq\mathbb R$ is dense in $\mathbb R$ if every nonempty open interval intersects $P$. Equivalently, every real point is a limit of points from $P$.

Continuity controls nearby outputs of nearby inputs. It does not, by itself, force trajectories to stretch across a space.

### 5.2 The contraction counterexample

Define $C:\mathbb R\to\mathbb R$ by

$$
C(x)=\frac x2.
$$

The map is continuous, and direct induction yields

$$
C^n(x)=\frac{x}{2^n}.
$$

**Theorem 5.2 (Periodic points of the half-map).** A real number $x$ is periodic under $C(x)=x/2$ if and only if $x=0$.

**Proof sketch.** If $C^n(x)=x$ for some $n>0$, then $x/2^n=x$, or

$$
(2^n-1)x=0.
$$

Because $2^n-1>0$, it follows that $x=0$. Conversely, $C(0)=0$, so $0$ is periodic. $\square$

**Corollary 5.3 (Failure of density under continuity).** There exists a continuous self-map of an interval whose periodic points are not dense. In particular, $C$ restricted to any invariant interval containing $0$, such as $[0,1]$, has periodic set $\{0\}$, which is not dense.

**Proof sketch.** The set $\{0\}$ misses every open interval contained in $(0,1]$, for example $(1/2,1)$. $\square$

The counterexample rejects the proposition that continuity alone makes recurrence ubiquitous. Additional hypotheses must exclude contraction into a small attracting set and enforce sufficient orbit dispersion. Candidate conditions include topological transitivity or mixing, but each proposed theorem must be stated and proved with care.

## 6. Topological prevalence versus empirical incidence

A claim that a certain proportion of people report déjà vu is a probability statement over a sampled population and an observation protocol. A claim that periodic points are dense is a topological statement. Neither determines the other.

First, density has no inherent percentage. The rationals are dense in $\mathbb R$ but have Lebesgue measure zero. Second, a probability depends on a measure. The same set of states can have probability zero, intermediate probability, or one under different distributions. Third, exact recurrence is an infinite-precision equality, while experiments observe finite time series with noise and finite resolution.

A measure-calibrated recurrence model should specify:

1. a probability distribution $\mu$ over initial states;
2. a distribution $\rho$ over dynamical parameters;
3. an observation horizon $N$;
4. a tolerance $\varepsilon>0$;
5. an observation map $h$ and a metric $d$ on observed states.

One may then define the finite-horizon approximate-recurrence event

$$
E_{N,\varepsilon}=\left\{(r,x):\exists n\in\{1,\ldots,N\},\ d\bigl(h(L_r^n(x)),h(x)\bigr)<\varepsilon\right\}.
$$

Its modeled incidence is

$$
\mathbb P(E_{N,\varepsilon})
=\int\!\int \mathbf 1_{E_{N,\varepsilon}}(r,x)\,d\mu(x)\,d\rho(r).
$$

Only a quantity of this kind can be compared coherently with a population incidence. Even then, identifiability is a separate issue: many combinations of $\mu$, $\rho$, $N$, $\varepsilon$, and $h$ may yield the same probability. Consequently, the parameter $r=3.83$ cannot be inferred from a $70\%$ statistic without much more structure.

## 7. Tropical spectral dynamics

### 7.1 Min-plus matrix action

Let $A=(A_{ij})$ be an $n\times n$ real matrix, with $n>0$, and let $v\in\mathbb R^n$. The min-plus matrix-vector action is

$$
(T_Av)_i=\min_{1\le j\le n}(A_{ij}+v_j).
$$

This operation is nonlinear in ordinary arithmetic but linear over the min-plus semiring. It appears in shortest-path problems, discrete-event systems, scheduling, and synchronization.

A basic symmetry is translation equivariance.

**Lemma 7.1 (Uniform-shift equivariance).** For every scalar $c$,

$$
T_A(v+c\mathbf 1)=T_A(v)+c\mathbf 1.
$$

**Proof sketch.** For each coordinate $i$,

$$
\min_j(A_{ij}+v_j+c)=\min_j(A_{ij}+v_j)+c.
$$

The same $c$ factors out of every minimum. $\square$

### 7.2 Tropical eigenpairs and drift

**Definition 7.2 (Tropical eigenpair).** A scalar-vector pair $(\lambda,v)$ is a tropical eigenpair of $A$ if

$$
T_Av=v+\lambda\mathbf 1.
$$

The eigenvalue $\lambda$ measures additive displacement per update along the all-ones direction.

**Theorem 7.3 (Iterated tropical eigenstate).** If $(\lambda,v)$ is a tropical eigenpair, then for every integer $k\ge0$,

$$
T_A^k(v)=v+k\lambda\mathbf 1.
$$

**Proof sketch.** The claim is immediate for $k=0$. Assume it holds at $k$. By Lemma 7.1 and the eigenpair equation,

$$
T_A^{k+1}(v)=T_A(v+k\lambda\mathbf 1)
=T_A(v)+k\lambda\mathbf 1
=v+(k+1)\lambda\mathbf 1.
$$

Induction completes the proof. $\square$

This formula is exact, not asymptotic. The orbit of an eigenstate is constrained to a line parallel to $\mathbf 1$.

**Theorem 7.4 (Zero eigenvalue and fixed state).** A vector $v$ forms a tropical eigenpair with eigenvalue $0$ if and only if

$$
T_Av=v.
$$

**Proof sketch.** Substitute $\lambda=0$ into the defining equation $T_Av=v+\lambda\mathbf 1$. $\square$

**Corollary 7.5 (Zero-drift recurrence).** If $(0,v)$ is a tropical eigenpair, then $v$ is periodic under $T_A$. In fact,

$$
T_A^k(v)=v
$$

for every positive integer $k$.

**Proof sketch.** Apply Theorem 7.3 with $\lambda=0$. $\square$

For $\lambda\ne0$, literal recurrence is impossible along this eigen-orbit because $v+k\lambda\mathbf 1\ne v$ for $k>0$. In tropical projective space, however, vectors differing by a uniform shift are identified, so every tropical eigenstate is projectively fixed. This separates absolute recurrence from recurrence of relative coordinate differences.

### 7.3 Example

Consider

$$
A=\begin{pmatrix}0&2\\1&0\end{pmatrix},
\qquad
v=\begin{pmatrix}0\\0\end{pmatrix}.
$$

Then

$$
T_Av=
\begin{pmatrix}
\min(0,2)\\
\min(1,0)
\end{pmatrix}
=
\begin{pmatrix}0\\0\end{pmatrix}=v.
$$

Thus $(0,v)$ is a tropical eigenpair and $v$ returns at every positive time. If instead a matrix and vector satisfy $T_Av=v+2\mathbf 1$, then the exact iterate formula gives $T_A^k(v)=v+2k\mathbf 1$.

## 8. Algorithms and numerical methodology

### 8.1 Orbit and recurrence scan

Given a map $f$, initial state $x_0$, horizon $N$, and tolerance $\varepsilon$, compute $x_{n+1}=f(x_n)$ and search for pairs $i<j$ satisfying $|x_j-x_i|<\varepsilon$. A direct all-pairs scan costs $O(N^2)$ time and $O(N)$ memory. If only return to the initial state is sought, the cost falls to $O(N)$ time and $O(1)$ additional memory. Approximate equality should never be reported as exact periodicity.

### 8.2 Exact-period candidate test

To test a numerical candidate for period $p$, compare $f^p(x)$ with $x$ and separately reject smaller lags $1\le q<p$. The test is tolerance-dependent and can be fooled by transients or rounding. For an attracting orbit, one first burns in the trajectory and then evaluates phase-separated residuals.

### 8.3 Min-plus iteration

A dense min-plus matrix-vector update evaluates $n$ candidate values in each of $n$ rows, requiring $O(n^2)$ time and $O(n)$ output memory. Repeating for $k$ steps costs $O(kn^2)$. For a known eigenpair, Theorem 7.3 reduces evaluation of the $k$th state to adding $k\lambda$ to each coordinate, requiring only $O(n)$ time.

## 9. Applications and interpretation

The recurrence framework applies whenever a system and its observations evolve compatibly. In neuroscience, $h$ may map a high-dimensional neural state to a reported category. In control, $h$ may extract a sensor output. In symbolic dynamics, it may assign labels to regions. The semiconjugacy theorem guarantees that a true hidden return remains a return after compatible observation, while warning that observed return need not lift to the hidden state.

The logistic map serves as a low-dimensional model for testing concepts rather than as a literal neural law. Its invariant interval, parameter-dependent periodic windows, and sensitivity make it a useful laboratory for distinguishing exact cycles, attracting cycles, and chaotic behavior.

Tropical dynamics contributes a complementary perspective. In synchronization networks, uniform additive drift can represent the passage of global time while relative timings remain unchanged. A tropical eigenvector is then projectively recurrent even when its absolute coordinates drift. Zero eigenvalue removes that global drift and produces literal recurrence. This distinction may guide models in which a cognitive pattern repeats up to a changing baseline.

## 10. Discussion

The principal positive results form a compact hierarchy. The return-multiple theorem describes the arithmetic closure of observed return times. The semiconjugacy theorem explains which recurrences survive coarse descriptions. The exact-three-cycle theorem certifies three distinct stages. The logistic invariant-interval theorem ensures a bounded domain for a canonical nonlinear example. The tropical drift theorem turns repeated nonlinear updates of an eigenstate into an explicit linear formula, with zero drift exactly characterizing fixed-state recurrence.

The contraction counterexample is equally central. It demonstrates that continuity is too weak to yield dense periodicity. Any argument for widespread recurrent states must identify an additional dispersive mechanism. This guards against transforming an evocative analogy into a false universal theorem.

There are also important distinctions among notions of “common.” Topological density means every neighborhood contains a point of the set. Measure-theoretic prevalence means the set has large probability or measure. Empirical incidence means a fraction of sampled subjects meet an operational criterion. None of these notions is interchangeable without explicit bridging assumptions.

## 11. Future work

A first direction is measure-calibrated recurrence incidence. One should fix distributions of parameters and initial states, a finite horizon, a tolerance, and an observation map, then study identifiability from population-level recurrence rates.

A second direction is a tropical spectral criterion for exact projective cycles. The iterate theorem suggests separating uniform eigenvalue drift from cycling in the quotient by the all-ones direction.

A third direction is a guarded density theorem for interval maps: determine checkable hypotheses stronger than continuity under which periodic points are dense, and construct counterexamples when each hypothesis is removed.

A fourth direction is quantitative certification at $r=3.83$. Rational interval enclosures for three orbit phases, together with derivative bounds for $L_r^3$, could establish a robust attracting three-cycle over a certified parameter interval.

A fifth direction concerns recurrence observables under many-to-one maps. One should characterize which statistics are preserved, inflated, or erased by coarse observation.

## 12. Conclusion

Modeling déjà vu as recurrence yields exact mathematics only when the relevant notion of return is stated carefully. Periodic states return at all positive multiples of a return time; exact period three entails three distinct states; and semiconjugacy transports recurrence from hidden dynamics to observations. The logistic family provides an invariant interval for $0\le r\le4$, but continuity alone does not imply dense periodicity, as the contraction $x\mapsto x/2$ proves. In min-plus dynamics, tropical eigenstates evolve by uniform additive drift, and zero drift is precisely fixed-state recurrence.

These results replace the claim that déjà vu is inevitable with a more productive conclusion: recurrence has universal structural laws, but its prevalence depends on dynamics, observation, topology, and probability. A scientifically meaningful account must specify all four.