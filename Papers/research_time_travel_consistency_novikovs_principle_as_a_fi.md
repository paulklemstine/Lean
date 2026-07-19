# Time Travel Consistency: Novikov’s Principle as a Fixed-Point Theorem

**Aristotle**  
**July 19, 2026**

## Abstract

A closed causal circuit converts the usual initial-value description of dynamics into a boundary-value problem: the state returning from one circuit must equal the state entering it. This paper formulates that requirement as a fixed-point equation and gives a precise sufficient mechanism for Novikov self-consistency. If the one-circuit return map is a contraction on a nonempty complete metric state space, then a unique self-consistent boundary state exists. Every iterated traversal converges to that state, and the one-step consistency defect yields an explicit a posteriori error bound. The construction is specialized to real polynomial return maps on complete invariant domains and to affine feedback, for which the consistent state is explicit. A finite-state analogue is also established. Counterexamples—real quadratic feedback $x\mapsto x^2+1$ and Boolean negation—show that neither polynomiality nor the mere existence of a causal rule guarantees consistency. The results distinguish algebraic solvability, dynamical stability, and physical domain invariance, and provide a quantitative framework for interpreting causal consistency as stable feedback.

## 1. Introduction

Discussions of time travel often present consistency as a prohibition: events on a closed causal curve must somehow be prevented from contradicting themselves. A mathematical model permits a more economical formulation. Cut a closed causal circuit at a chosen hypersurface, record the state $x$ crossing the cut, evolve it once around the circuit, and compare the returning state with the original one. If the complete round-trip evolution is $F$, then the boundary data are consistent exactly when

$$
F(x)=x.
$$

The consistency question is therefore a fixed-point problem. The reformulation is elementary, but it exposes the hypotheses needed for a rigorous existence theorem. A general self-map can have no fixed point, one fixed point, or many. Consequently, no unrestricted conclusion follows merely from calling $F$ a causal law. Even requiring $F$ to be polynomial is insufficient over the real numbers.

The central structural condition studied here is strict contraction. If the state space has a metric and one traversal reduces all pairwise distances by a uniform factor $K<1$, repeated traversal progressively erases dependence on the initial boundary proposal. On a complete space, the resulting sequence converges; contraction then forces the limit to close the loop. The same geometry proves uniqueness and supplies an operational error estimate.

The paper makes five principal claims. First, Novikov consistency is exactly fixed-point existence for the one-circuit map. Second, contraction on a nonempty complete metric space gives a unique consistent state. Third, this state globally attracts all iterates. Fourth, the observable residual $d(x,F(x))$ bounds the unknown error $d(x,x_\ast)$. Fifth, a polynomial return law inherits these conclusions on any nonempty complete invariant domain where its restriction is contractive. An explicit affine family and two counterexamples delineate the result.

These theorems are conditional mathematical statements. They do not assert the physical existence of closed timelike curves, prescribe a spacetime metric, or derive a return map from field equations. Rather, they identify a transparent mechanism by which a modeled causal loop is self-consistent and dynamically stable.

## 2. Causal boundary-value problems

### 2.1 One-circuit dynamics

Let $X$ be a set of admissible boundary states. A **causal boundary-value problem** on $X$ consists of a return map

$$
F:X\to X,
$$

where $F(x)$ is the state obtained after the boundary state $x$ completes one full causal circuit. The state may encode any data needed to make the round-trip evolution deterministic: particle positions and momenta, field data, memory registers, control settings, or a coarse-grained observable.

A state $x\in X$ is a **self-consistent boundary state** if

$$
F(x)=x.
$$

The boundary-value problem is **Novikov-consistent** if at least one self-consistent boundary state exists.

This terminology immediately gives the first proposition.

**Proposition 2.1 (Fixed-point characterization).** A causal boundary-value problem with return map $F:X\to X$ is Novikov-consistent if and only if $F$ has a fixed point.

**Proof sketch.** By definition, Novikov consistency means that some $x\in X$ returns with exactly the same boundary value, which is the equation $F(x)=x$. This is precisely the definition of a fixed point. No additional dynamical or physical assumption is hidden in the equivalence. $\square$

The proposition is definitional, but it is conceptually useful. It separates the semantic interpretation of consistency from the mathematical task of proving fixed-point existence.

### 2.2 Metric structure and contraction

To compare candidate histories, suppose $X$ is equipped with a metric $d$. A map $F:X\to X$ is a **contraction with factor $K$** if $0\le K<1$ and

$$
d(F(x),F(y))\le Kd(x,y)
$$

for all $x,y\in X$.

The condition is global and uniform. It says that one complete traversal reduces every discrepancy by at least the same fractional amount. Induction gives

$$
d(F^n(x),F^n(y))\le K^n d(x,y),
$$

where $F^n$ denotes $n$ successive traversals.

A metric space is **complete** if every Cauchy sequence converges to a point of that space. Completeness is indispensable when the consistent state is constructed as a limit: it ensures that progressively compatible boundary proposals do not converge to a missing, inadmissible state.

## 3. The Novikov–Banach consistency theorem

**Theorem 3.1 (Existence and uniqueness under contraction).** Let $(X,d)$ be a nonempty complete metric space. Let $F:X\to X$ be a contraction with factor $K$, where $0\le K<1$. Then there exists exactly one $x_\ast\in X$ such that

$$
F(x_\ast)=x_\ast.
$$

Equivalently, the associated causal boundary-value problem has exactly one self-consistent history.

**Proof sketch.** Choose any $x_0\in X$ and define $x_{n+1}=F(x_n)$. Contraction yields

$$
d(x_{n+1},x_n)\le K^n d(x_1,x_0).
$$

For $m>n$, the triangle inequality and the geometric series give

$$
d(x_m,x_n)
\le \sum_{j=n}^{m-1}d(x_{j+1},x_j)
\le \frac{K^n}{1-K}d(x_1,x_0).
$$

The right-hand side tends to zero, so $(x_n)$ is Cauchy. Completeness gives a limit $x_\ast\in X$. Since every contraction is Lipschitz continuous,

$$
F(x_\ast)=F\left(\lim_{n\to\infty}x_n\right)
=\lim_{n\to\infty}F(x_n)
=\lim_{n\to\infty}x_{n+1}=x_\ast.
$$

For uniqueness, suppose $x_\ast$ and $y_\ast$ are fixed. Then

$$
d(x_\ast,y_\ast)
=d(F(x_\ast),F(y_\ast))
\le Kd(x_\ast,y_\ast).
$$

Because $K<1$, this forces $d(x_\ast,y_\ast)=0$, hence $x_\ast=y_\ast$. $\square$

The theorem upgrades a consistency postulate into a consequence of dissipative round-trip dynamics. Each traversal reduces sensitivity to the proposed boundary history, while completeness ensures that the limiting proposal remains admissible.

### 3.1 Global attraction

The construction in the proof already contains a dynamical conclusion.

**Theorem 3.2 (Global attraction).** Under the hypotheses of Theorem 3.1, for every initial boundary state $x_0\in X$,

$$
\lim_{n\to\infty}F^n(x_0)=x_\ast,
$$

where $x_\ast$ is the unique self-consistent state.

**Proof sketch.** Since $F(x_\ast)=x_\ast$, repeated application of the contraction inequality gives

$$
d(F^n(x_0),x_\ast)
=d(F^n(x_0),F^n(x_\ast))
\le K^n d(x_0,x_\ast).
$$

As $K^n\to0$, the iterates converge to $x_\ast$. $\square$

Thus consistency is not merely solvability of an isolated equation. It is asymptotically selected from every initial proposal. The factor $K$ controls the worst-case geometric convergence rate.

### 3.2 A posteriori certification

In applications, the exact fixed point may be unknown. A proposed state can nevertheless be tested by comparing it with the state returned after one circuit.

Define the **consistency defect** or **residual** of $x$ by

$$
r(x)=d(x,F(x)).
$$

**Theorem 3.3 (A posteriori consistency error).** Under the hypotheses of Theorem 3.1, every $x\in X$ satisfies

$$
d(x,x_\ast)\le \frac{d(x,F(x))}{1-K}.
$$

**Proof sketch.** Insert $F(x)$ between $x$ and $x_\ast$ and use $F(x_\ast)=x_\ast$:

$$
\begin{aligned}
d(x,x_\ast)
&\le d(x,F(x))+d(F(x),x_\ast)\\
&=d(x,F(x))+d(F(x),F(x_\ast))\\
&\le d(x,F(x))+Kd(x,x_\ast).
\end{aligned}
$$

Move the final term to the left and divide by $1-K>0$. $\square$

This estimate turns an exact but potentially inaccessible equality into a quantitative observable. If a one-circuit experiment returns a state within $\varepsilon$ of the input, then the input lies within $\varepsilon/(1-K)$ of the unique consistent history. The estimate also explains ill-conditioning near $K=1$: weak contraction amplifies residual uncertainty.

A related forward estimate follows from the proof of Theorem 3.1:

$$
d(F^n(x_0),x_\ast)
\le \frac{K^n}{1-K}d(x_0,F(x_0)).
$$

It permits a stopping rule using only the initial or current one-step defect.

## 4. Polynomial return maps on physical domains

### 4.1 Why the domain is part of the model

Let $p\in\mathbb R[t]$ be a real polynomial. It defines a return law $F(x)=p(x)$, but the physically admissible states may occupy only a subset $S\subseteq\mathbb R$. The restriction to $S$ is meaningful as a closed causal evolution only when

$$
p(S)\subseteq S.
$$

Such an $S$ is called an **invariant domain**. Without invariance, iteration may leave the state space after one circuit. If $S$ is complete under the inherited Euclidean metric—for example, if $S$ is a closed subset of $\mathbb R$—limits of admissible Cauchy sequences remain admissible.

**Theorem 4.1 (Polynomial consistency on a complete invariant domain).** Let $p$ be a real polynomial and let $S\subseteq\mathbb R$ be nonempty and complete under the Euclidean metric. Assume that $p(S)\subseteq S$ and that there is a constant $K$ with $0\le K<1$ such that

$$
|p(x)-p(y)|\le K|x-y|
$$

for all $x,y\in S$. Then there exists exactly one $x_\ast\in S$ satisfying

$$
p(x_\ast)=x_\ast.
$$

Moreover, every iteration $x_{n+1}=p(x_n)$ begun in $S$ converges to $x_\ast$, and

$$
|x-x_\ast|\le \frac{|x-p(x)|}{1-K}
$$

for every $x\in S$.

**Proof sketch.** Regard $p$ as a self-map of the metric space $S$. Invariance makes the restriction well-defined, completeness and nonemptiness provide the geometric setting, and the displayed inequality makes the restriction a contraction. Theorems 3.1–3.3 apply directly. $\square$

Polynomiality is therefore not the source of consistency; it is a modeling class within which invariance and contraction can be checked. A common sufficient condition on a closed interval $S=[L,U]$ is

$$
p([L,U])\subseteq[L,U]
\quad\text{and}\quad
\sup_{x\in[L,U]}|p'(x)|\le K<1.
$$

The mean value theorem then yields the required Lipschitz inequality. This derivative criterion is sufficient, not necessary, and it must hold on the proposed invariant domain.

### 4.2 Affine feedback

The simplest polynomial case is the affine map

$$
F(x)=ax+b.
$$

**Theorem 4.2 (Explicit affine consistency).** If $a,b\in\mathbb R$ and $|a|<1$, then the affine causal return law $F(x)=ax+b$ has exactly one self-consistent state, namely

$$
x_\ast=\frac{b}{1-a}.
$$

For every $x_0\in\mathbb R$, its iterates satisfy

$$
F^n(x_0)=x_\ast+a^n(x_0-x_\ast),
$$

and therefore converge geometrically to $x_\ast$.

**Proof sketch.** The identity

$$
|F(x)-F(y)|=|a|\,|x-y|
$$

shows that $F$ is a contraction with factor $|a|$. Solving $ax+b=x$ gives $x_\ast=b/(1-a)$; the denominator is nonzero because $|a|<1$. Subtracting the fixed-point equation from the recurrence gives $x_{n+1}-x_\ast=a(x_n-x_\ast)$, and induction produces the iteration formula. $\square$

**Example 4.3.** For

$$
F(x)=\frac12x+3,
$$

the unique consistent state is $x_\ast=6$. Starting at $x_0=0$ gives

$$
0,\ 3,\ 4.5,\ 5.25,\ 5.625,\ldots,
$$

while starting at $x_0=20$ gives

$$
20,\ 13,\ 9.5,\ 7.75,\ 6.875,\ldots.
$$

In both cases the distance to $6$ is halved on every circuit. At the trial state $x=5.625$, the residual is

$$
|x-F(x)|=|5.625-5.8125|=0.1875.
$$

The a posteriori theorem gives

$$
|x-6|\le \frac{0.1875}{1-0.5}=0.375,
$$

which is exact in this example.

## 5. Finite state spaces

Not every causal model is continuous. A message may be encoded by a finite alphabet, or a coarse-grained system may have finitely many states.

**Theorem 5.1 (Finite strict-contraction consistency).** Let $(X,d)$ be a nonempty finite metric space and let $F:X\to X$ satisfy

$$
d(F(x),F(y))\le Kd(x,y)
$$

for all $x,y\in X$, where $K<1$. Then $F$ has exactly one fixed point.

**Proof sketch.** Begin from any $x_0$. Because $X$ is finite, the orbit $x_0,F(x_0),F^2(x_0),\ldots$ eventually repeats and hence enters a periodic cycle. If the cycle had length greater than one, choose two distinct corresponding points on it. Repeated traversal around the cycle would return that pair to itself while strict contraction would reduce their positive distance by a factor strictly below one, a contradiction. Thus the eventual cycle is a fixed point. If two fixed points existed, their positive distance would likewise be strictly reduced while remaining unchanged. $\square$

Finiteness supplies completeness automatically, but the elementary orbit argument makes the mechanism transparent. Strict contraction excludes every nontrivial recurrent pattern.

## 6. Counterexamples and sharp boundaries

### 6.1 A polynomial without a real consistent state

**Proposition 6.1 (Quadratic inconsistency).** The polynomial return law

$$
F(x)=x^2+1
$$

has no self-consistent state in $\mathbb R$.

**Proof.** A fixed point would satisfy

$$
x^2+1=x,
$$

or $x^2-x+1=0$. Completing the square gives

$$
\left(x-\frac12\right)^2+\frac34=0,
$$

whose left-hand side is strictly positive for every real $x$. Equivalently, the discriminant is $-3$. $\square$

This example disproves the unrestricted assertion that polynomial causal maps always admit consistent real histories. It also illustrates why an invariant contractive domain cannot exist for this map: such a domain would force a fixed point by Theorem 4.1.

### 6.2 Boolean negation

Let $X=\{\mathrm{false},\mathrm{true}\}$ and define $F(b)=\neg b$.

**Proposition 6.2 (Boolean grandfather paradox).** Boolean negation has no self-consistent state.

**Proof.** Negation sends false to true and true to false, so neither state satisfies $F(b)=b$. $\square$

With the discrete metric, the two distinct states have distance $1$, and negation preserves that distance. Its best Lipschitz factor is $1$, not a number below $1$. The example therefore lies exactly outside the strict-contraction regime and forms a two-cycle rather than a fixed point.

### 6.3 What each hypothesis contributes

The examples distinguish several logically separate requirements:

1. **A return law is not enough.** Boolean negation is deterministic but inconsistent.
2. **Polynomiality is not enough.** The map $x\mapsto x^2+1$ has no real fixed point.
3. **Nonemptiness is necessary.** An empty admissible domain contains no history.
4. **Invariance is necessary for restricted dynamics.** If $F(S)\nsubseteq S$, repeated traversal does not define a self-map of the proposed physical domain.
5. **Completeness retains limits.** A contraction on an incomplete space may converge toward a missing boundary point.
6. **Strict contraction supplies uniqueness and attraction.** Without it, a map may have several fixed points, neutral cycles, or no fixed point.

Strict contraction is sufficient rather than necessary. The identity map has fixed points but contraction factor $1$; other maps may possess stable fixed points only on local basins. The present theorem identifies a robust global regime, not the full taxonomy of consistent causal laws.

## 7. Algorithms and numerical certification

### 7.1 Fixed-point iteration

Given a return map $F$, a known contraction factor $K<1$, and an initial state $x_0$, compute

$$
x_{n+1}=F(x_n).
$$

Stop when

$$
\frac{d(x_n,F(x_n))}{1-K}\le \varepsilon.
$$

Theorem 3.3 then certifies that $d(x_n,x_\ast)\le\varepsilon$. Each iteration requires one evaluation of $F$ and one distance computation. If these cost $C_F$ and $C_d$, respectively, then $n$ steps cost $O(n(C_F+C_d))$ and require $O(1)$ state storage when only the current iterate is retained.

For an a priori iteration count, Theorem 3.2 gives

$$
K^n d(x_0,x_\ast)\le\varepsilon.
$$

Because $x_\ast$ is usually unknown, the residual form is more practical. Using the initial residual yields

$$
d(x_n,x_\ast)
\le \frac{K^n}{1-K}d(x_0,F(x_0)).
$$

Thus it suffices, for $0<K<1$, to choose

$$
n\ge
\frac{\log\!\left(\varepsilon(1-K)/d(x_0,F(x_0))\right)}{\log K},
$$

with the inequality interpreted carefully because $\log K<0$.

### 7.2 Polynomial-domain screening

For a polynomial on an interval $[L,U]$, a computational pipeline can check sufficient conditions:

1. bound $p([L,U])$ and verify it lies in $[L,U]$;
2. bound $|p'(x)|$ on the interval by $K<1$;
3. run fixed-point iteration from any $x_0\in[L,U]$;
4. report both the approximation and the certificate $|x_n-p(x_n)|/(1-K)$.

Exact verification of polynomial range and derivative bounds can use critical points, interval arithmetic, or certified optimization. Sampling alone illustrates behavior but cannot establish the global hypotheses. Once valid bounds are available, the convergence and error conclusions follow independently of the starting point.

### 7.3 Paradox detection in finite models

For a finite map represented as a table, fixed points can be found by scanning all states and testing $F(x)=x$, with $O(|X|)$ map evaluations. Orbit tracing additionally reveals cycles. Under a known strict contraction, Theorem 5.1 guarantees that the scan will find exactly one fixed point; without contraction, a fixed-point-free cycle such as Boolean negation is possible.

## 8. Applications and interpretation

### 8.1 Boundary conditions on closed causal circuits

The return-map abstraction compresses all local dynamics into one Poincaré-like map across a chosen cut. A fixed point is boundary data compatible with an entire closed history. In a detailed physical model, constructing $F$ would require solving local evolution equations around the loop; the present results then apply to the induced map if its metric properties can be established.

### 8.2 Control and iterative correction

The same equations describe ordinary feedback systems. A controller maps an incoming error state to the next-cycle error. If the closed-loop map contracts, a unique equilibrium exists and globally attracts trajectories. The residual theorem becomes a stopping criterion or calibration certificate. The causal-loop vocabulary emphasizes boundary closure, while control theory emphasizes stabilization; mathematically, both use the same fixed-point geometry.

### 8.3 Recurrent computation and networks

Recurrent models, equilibrium networks, and mutually dependent agents often seek states satisfying $F(x)=x$. Contractivity prevents multiple incompatible equilibria and makes naive iteration reliable. In this broader setting, the “consistent history” is an equilibrium representation rather than a literal trip through time.

### 8.4 Robustness and observability

The a posteriori estimate is especially important because exact consistency is an equality and therefore appears fragile. Under contraction, it is not fragile: a small residual guarantees a nearby exact solution. The factor $(1-K)^{-1}$ is the condition number of this guarantee. Strongly contractive loops are robustly interpretable; nearly neutral loops require finer measurements.

## 9. Discussion

The fixed-point framing resolves one version of the consistency problem while clarifying its limits. The Novikov principle becomes a theorem only after dynamical assumptions are supplied. Global contraction is a particularly strong and intelligible assumption because it yields four conclusions simultaneously: existence, uniqueness, global attraction, and quantitative certification.

The polynomial theorem demonstrates the importance of domain-sensitive statements. A polynomial formula by itself says little about fixed-point existence. The relevant object is a polynomial self-map of a nonempty complete invariant domain, together with a contraction estimate on that domain. This distinction parallels standard modeling practice: physical constraints are part of the system, not an afterthought.

The counterexamples are not pathologies. The quadratic map exhibits algebraic nonexistence over the reals, while Boolean negation exhibits a finite, perfectly deterministic two-cycle. Together they show that causal determinism and causal consistency are distinct. They also reveal two ways the global theorem can fail: an equation may have no root, or iteration may perpetually alternate rather than damp differences.

Several cautions remain. First, a return map assumes deterministic one-circuit evolution; noisy or set-valued dynamics require invariant distributions or multivalued fixed-point methods. Second, the choice of metric matters because contractivity is metric-dependent. Third, global contraction can be much stronger than physical stability near a particular fixed point. Local derivative conditions may select a consistent history within one basin while other basins support different histories. Finally, an abstract boundary map does not replace spacetime dynamics; it is an interface through which those dynamics can be analyzed.

## 10. Future work

A natural next step is a local-basin principle for polynomial feedback. If a polynomial preserves a closed interval and has a fixed point with derivative magnitude below one, the immediate basin should support convergence to that locally unique consistent history even when the map is not globally contractive. Critical and repelling periodic points may organize basin boundaries.

One-parameter polynomial families invite a bifurcation classification. Changes in the number of fixed points should occur where $p(x)-x$ has a multiple real root, whereas changes in stability occur where $|p'(x)|=1$ at a fixed point. These are related but distinct discriminant loci.

Robustness under perturbation of the return law is another direct extension. If $F$ and $G$ have a shared contraction factor $K<1$ and unique fixed points $x_F$ and $x_G$, one expects a bound of the form

$$
d(x_F,x_G)\le
\frac{\sup_x d(F(x),G(x))}{1-K}.
$$

This would convert uncertainty in the causal law into uncertainty in the selected history.

For stochastic loops, a state should be replaced by a probability law and the return map by a Markov operator. Contraction in Wasserstein distance is expected to yield a unique invariant law and geometric convergence of every initial distribution, with deterministic fixed points appearing as Dirac measures.

Finally, coupled causal loops lead to product-state return maps. Spectral or block-contraction criteria could relate the strength of each local feedback channel to global consistency, allowing weakly coupled networks of loops to be treated without requiring every component to contract independently.

## 11. Conclusion

A causal loop is consistent when its one-circuit return map reproduces its boundary state. On a nonempty complete metric state space, strict contraction guarantees exactly one such state. It also guarantees that all iterated boundary proposals converge to it and that the measurable one-step defect bounds the distance to exact consistency by the factor $(1-K)^{-1}$. Real polynomial maps inherit the result on complete invariant domains where they contract, and affine maps with $|a|<1$ provide an explicit family with fixed point $b/(1-a)$. Finite strict contractions satisfy the same uniqueness principle.

The hypotheses mark a genuine boundary. The polynomial $x\mapsto x^2+1$ has no real fixed point, and Boolean negation has no fixed state. Thus neither a causal rule nor a polynomial causal rule entails consistency by itself. What converts the Novikov principle from a narrative demand into a mathematical consequence is stable feedback: a geometry in which each circuit shrinks disagreement until one closed history remains.
