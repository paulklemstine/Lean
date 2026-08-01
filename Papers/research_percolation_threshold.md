# Local Self-Duality and Moment Methods for Percolation Thresholds

**Aristotle**  
**August 1, 2026**

## Abstract

We give a self-contained analysis of the elementary threshold calculation on a triangular face and place it within the general probabilistic machinery used to study random discrete structures. For three independent Bernoulli sites of density $p$, the probability that at least two are open is

$$
C(p)=p^3+3p^2(1-p)=3p^2-2p^3.
$$

We prove complement duality $C(1-p)=1-C(p)$, bounds $0\le C(p)\le1$ on the Bernoulli interval, and the sharp trichotomy $C(p)<1/2$, $C(p)=1/2$, or $C(p)>1/2$ according as $p<1/2$, $p=1/2$, or $p>1/2$. Hence $p=1/2$ is the unique local self-dual parameter. The probability that three vertices of a triangular face are connected by independent open bonds is the identical polynomial, although this local identity does not equate the infinite site and bond models. We then develop a finite independent-edge probability space, prove normalization, fixed-pattern independence, the union bound, expected-count identities, a first-moment criterion, and a second-moment criterion for appearance with high probability. We explain exactly which additional planar, sharp-threshold, and limiting arguments are needed to turn local self-duality into an infinite-volume theorem. In particular, the exact triangular-site threshold and square-bond threshold are distinguished from the square-site threshold, for which no accepted closed analytic form is known. We conclude with an algorithmic treatment and a roadmap toward conformal invariance and $\mathrm{SLE}_6$.

## 1. Introduction

Percolation studies connectivity in a random medium. Given a lattice or finite graph, one independently declares elementary objects open with probability $p$ and closed with probability $1-p$. In **site percolation** the randomized objects are vertices; in **bond percolation** they are edges. The principal global observable is whether open objects support a path across a large region or an infinite connected cluster.

For an infinite transitive lattice, the critical parameter is informally the boundary between a subcritical regime without an infinite open cluster and a supercritical regime with one. A standard definition is

$$
p_c=\inf\{p\in[0,1]:\Pr_p(\text{an infinite open cluster exists})>0\}.
$$

Exact critical probabilities are exceptional. They usually require a local symmetry to nominate a candidate, planar topology to relate complementary crossing events, and probabilistic estimates to prove that the candidate is the actual infinite-volume threshold. Confusing the first step with the entire argument is a persistent source of incorrect threshold claims.

This paper isolates the exact finite calculation supplied by one triangular face. The result is complete at that scale: the crossing polynomial has an exact complement symmetry and a unique fair parameter. It is also the local algebra associated with the exact triangular-lattice site threshold $p_c=1/2$. We emphasize, however, that the finite calculation is not by itself a proof of that infinite-lattice theorem.

The motivating square-site question illustrates the importance of this boundary. Bond percolation on the square lattice has exact threshold $1/2$, whereas site percolation on the square lattice has a numerically established critical value near $0.592746$ and no accepted closed exact expression. Site and bond models must retain distinct sample spaces, even when a small motif gives coincident formulas.

The second part of the paper develops finite first- and second-moment methods. These results are not specific to one lattice. They provide the reusable probabilistic engine behind many threshold arguments: the first moment proves nonappearance when expected counts vanish, and the second moment proves appearance when the mean diverges while variance remains controlled.

## 2. Bernoulli configurations and local events

### 2.1 Site and bond percolation

Let $G=(V,E)$ be a finite or locally finite graph. In site percolation with parameter $p\in[0,1]$, each $v\in V$ receives an independent Bernoulli state: open with probability $p$ and closed otherwise. An open site path is a graph path all of whose vertices are open.

In bond percolation, each $e\in E$ is independently open with probability $p$. An open bond path is a path all of whose edges are open. The vertex and edge configuration spaces differ, and no general equality between their critical parameters follows from planar duality or local counting alone.

### 2.2 The triangular site event

Consider three independent sites placed at the vertices of a triangular face. Define the **local site-crossing event** to occur when at least two of the three sites are open. This majority event is the smallest odd Bernoulli system with a nontrivial complement symmetry.

**Definition 2.1 (Triangular site-crossing polynomial).** For $p\in\mathbb R$, define

$$
C(p)=p^3+3p^2(1-p).
$$

For $p\in[0,1]$, this is the probability that at least two among three independent Bernoulli sites are open.

**Proposition 2.2 (Cubic form).** For every real $p$,

$$
C(p)=3p^2-2p^3.
$$

**Proof sketch.** Expand the second term:

$$
p^3+3p^2(1-p)=p^3+3p^2-3p^3=3p^2-2p^3.
$$

The probabilistic derivation separates the four successful configurations. One has three open sites and mass $p^3$. The other three have exactly two open sites, each with mass $p^2(1-p)$.

**Proposition 2.3 (Probability bounds).** If $0\le p\le1$, then

$$
0\le C(p)\le1.
$$

**Proof sketch.** Both $p^3$ and $3p^2(1-p)$ are nonnegative, proving the lower bound. For the upper bound one may either sum the four complementary configuration masses directly or use complement duality from the next theorem: $C(p)=1-C(1-p)$, while $C(1-p)\ge0$.

## 3. Complement duality and uniqueness of the fair point

**Theorem 3.1 (Exact complement duality).** For every real $p$,

$$
C(1-p)=1-C(p).
$$

**Proof sketch.** Complementing each of three site states transforms parameter $p$ into $1-p$. Because three is odd, a configuration with at least two open sites becomes one with at most one open site, exactly the complementary event. Algebraically, substitute $1-p$ into $3p^2-2p^3$ and expand.

**Corollary 3.2 (Fairness at one half).**

$$
C\left(\frac12\right)=\frac12.
$$

**Proof sketch.** The complement map fixes $p=1/2$, so Theorem 3.1 yields $C(1/2)=1-C(1/2)$. Alternatively, direct substitution gives $3/4-1/4=1/2$.

Fairness at a self-complementary point does not by itself prove uniqueness. Here uniqueness follows from an exact sign factorization.

**Lemma 3.3 (Sign factorization).** For every real $p$,

$$
C(p)-\frac12=(2p-1)\left(p(1-p)+\frac12\right).
$$

**Proof sketch.** Expand the right-hand side to obtain $3p^2-2p^3-1/2$. If $0\le p\le1$, then $p(1-p)\ge0$, so the second factor is at least $1/2$ and therefore strictly positive.

**Theorem 3.4 (Local threshold trichotomy).** Let $0\le p\le1$. Then

$$
C(p)<\frac12 \quad\Longleftrightarrow\quad p<\frac12,
$$

$$
C(p)=\frac12 \quad\Longleftrightarrow\quad p=\frac12,
$$

and

$$
C(p)>\frac12 \quad\Longleftrightarrow\quad p>\frac12.
$$

**Proof sketch.** On $[0,1]$, the second factor in Lemma 3.3 is positive. Hence $C(p)-1/2$ and $2p-1$ have the same sign.

**Definition 3.5 (Local triangular criticality).** A parameter $p$ is locally critical for the triangular site event if

$$
0\le p\le1
$$

and

$$
C(p)=\frac12.
$$

**Theorem 3.6 (Unique local self-dual parameter).** A real parameter is locally critical for the triangular site event if and only if

$$
p=\frac12.
$$

This theorem concerns the fairness of one face. The adjective “local” is essential: it does not define or determine an infinite-lattice critical probability without additional results.

A derivative gives a complementary view. Since

$$
C'(p)=6p(1-p),
$$

$C$ is strictly increasing on $(0,1)$. The factorization proof is stronger for present purposes because it simultaneously identifies the exact sign relative to $1/2$.

## 4. Bond spanning on a triangular face

Place independent Bernoulli bonds on the three edges of a triangle. Define the **bond-spanning event** to occur when all three vertices lie in one connected component. This happens precisely when at least two edges are open.

**Definition 4.1 (Triangular bond-spanning polynomial).**

$$
B(p)=3p^2(1-p)+p^3.
$$

**Theorem 4.2 (One-face site–bond identity).** For every real $p$,

$$
B(p)=C(p)=3p^2-2p^3.
$$

**Proof sketch.** In the bond experiment there are three successful configurations with exactly two open edges and one with all three open. Their total mass is identical to the site majority count.

**Corollary 4.3 (Unique fair bond parameter).** If $0\le p\le1$, then

$$
B(p)=\frac12 \quad\Longleftrightarrow\quad p=\frac12.
$$

Theorem 4.2 is local and combinatorial. It does not identify site and bond measures on an extended lattice. Adjacent triangular faces share sites and edges in different ways, so gluing faces produces different global dependency and connectivity structures.

## 5. A finite independent-edge probability space

Moment methods are most transparent in an elementary finite model. Let $A$ be a finite set of $N$ potential edges. A configuration is a subset $S\subseteq A$. Under independent inclusion with probability $p$, assign mass

$$
\mu_p(S)=p^{|S|}(1-p)^{N-|S|}.
$$

For an event $\mathcal E\subseteq 2^A$, define

$$
\Pr_p(\mathcal E)=\sum_{S\in\mathcal E}\mu_p(S).
$$

**Proposition 5.1 (Nonnegativity and normalization).** If $0\le p\le1$, then $\mu_p(S)\ge0$ for every configuration $S$, and

$$
\sum_{S\subseteq A}\mu_p(S)=1.
$$

**Proof sketch.** Nonnegativity follows from the signs of $p$ and $1-p$. Group configurations by cardinality and apply the binomial theorem:

$$
\sum_{k=0}^N\binom Nk p^k(1-p)^{N-k}=(p+1-p)^N=1.
$$

**Theorem 5.2 (Fixed-pattern independence).** For any fixed $T\subseteq A$,

$$
\Pr_p(T\subseteq S)=p^{|T|}.
$$

**Proof sketch.** Every edge of $T$ must be present, contributing $p^{|T|}$. The edges in $A\setminus T$ are unconstrained. Summing over their configurations gives

$$
\sum_{R\subseteq A\setminus T}p^{|R|}(1-p)^{N-|T|-|R|}=1.
$$

Multiplication by $p^{|T|}$ gives the result.

## 6. Union bounds and the first moment

**Theorem 6.1 (Finite union bound).** For a finite family of events $\mathcal E_i$,

$$
\Pr_p\left(\bigcup_i\mathcal E_i\right)\le\sum_i\Pr_p(\mathcal E_i).
$$

**Proof sketch.** Every configuration in the union contributes its nonnegative mass at least once to the right-hand side. Configurations lying in several events are counted repeatedly, explaining why the relation is an inequality.

Let $\mathcal T$ be a finite family of target edge sets. For a configuration $S$, define the pattern count

$$
X_{\mathcal T}(S)=|\{T\in\mathcal T:T\subseteq S\}|.
$$

For any real random variable $X$ on configurations, define

$$
\mathbb E_p[X]=\sum_{S\subseteq A}\mu_p(S)X(S).
$$

**Theorem 6.2 (Expected pattern count).**

$$
\mathbb E_p[X_{\mathcal T}]=\sum_{T\in\mathcal T}p^{|T|}.
$$

**Proof sketch.** Write the count as a sum of indicators:

$$
X_{\mathcal T}(S)=\sum_{T\in\mathcal T}\mathbf 1_{\{T\subseteq S\}}.
$$

Interchange the two finite sums, use linearity of expectation, and apply Theorem 5.2 to each indicator.

**Theorem 6.3 (First-moment appearance bound).**

$$
\Pr_p(X_{\mathcal T}>0)\le\sum_{T\in\mathcal T}p^{|T|}
=\mathbb E_p[X_{\mathcal T}].
$$

**Proof sketch.** The event $X_{\mathcal T}>0$ is the union, over $T\in\mathcal T$, of the events $T\subseteq S$. Apply Theorems 6.1 and 5.2.

**Corollary 6.4 (First-moment vanishing criterion).** For a sequence of finite systems and target families, if

$$
\mathbb E[X_n]\longrightarrow0,
$$

then

$$
\Pr(X_n>0)\longrightarrow0.
$$

Thus a pattern disappears with high probability whenever its expected count vanishes.

## 7. Variance and the second moment

For a real random variable $X$, define

$$
\operatorname{Var}_p(X)=\mathbb E_p\left[(X-\mathbb E_p[X])^2\right].
$$

**Theorem 7.1 (Zero-event second-moment inequality).** If $0\le p\le1$ and $\mathbb E_p[X]\ne0$, then

$$
\Pr_p(X=0)\le
\frac{\operatorname{Var}_p(X)}{\mathbb E_p[X]^2}.
$$

**Proof sketch.** On the event $X=0$,

$$
(X-\mathbb E_p[X])^2=\mathbb E_p[X]^2.
$$

The variance is a sum of nonnegative terms, so retaining only configurations where $X=0$ yields

$$
\operatorname{Var}_p(X)
\ge \mathbb E_p[X]^2\Pr_p(X=0).
$$

Divide by the positive square of the mean.

**Lemma 7.2 (Analytic squeeze).** Let $E_n$, $V_n$, and $q_n$ be real sequences satisfying

$$
0\le q_n\le\frac{V_n}{E_n^2},
$$

$$
E_n\longrightarrow+\infty,
$$

and, for a fixed constant $K$,

$$
V_n\le K E_n.
$$

Then $q_n\to0$.

**Proof sketch.** The assumptions imply

$$
0\le q_n\le\frac{K}{E_n},
$$

and the upper bound tends to zero.

**Theorem 7.3 (Second-moment appearance criterion).** Let $X_n$ be random variables on a sequence of finite independent-edge spaces. Suppose their means $E_n$ are nonzero and satisfy

$$
E_n=\mathbb E[X_n]\longrightarrow+\infty.
$$

Suppose also that their variances $V_n$ satisfy

$$
V_n=\operatorname{Var}(X_n)\le K E_n
$$

for one constant $K$. Then

$$
\Pr(X_n=0)\longrightarrow0.
$$

Equivalently, $X_n\ne0$ with probability tending to one.

**Proof sketch.** Apply Theorem 7.1 to each $X_n$ and then Lemma 7.2. The result captures the standard second-moment strategy for subgraph counts: a diverging expected count forces actual appearance provided overlaps do not make the variance too large.

The first and second moments address opposite sides of a threshold. When the expected count tends to zero, no witness appears with high probability. When it diverges and fluctuations are sufficiently controlled, at least one witness appears with high probability. Establishing a sharp threshold often consists of choosing the correct witnesses and proving matching estimates around one scale.

## 8. Algorithms and numerical experiments

### 8.1 Exact evaluation of the local polynomial

The local algorithm evaluates

$$
C(p)=3p^2-2p^3
$$

using a constant number of arithmetic operations. Its time and auxiliary-space complexity are both $O(1)$. It can also enumerate all $2^3=8$ configurations, summing $p^k(1-p)^{3-k}$ over those with $k\ge2$. Enumeration is useful as an audit of the combinatorial interpretation, though unnecessary for efficiency.

A useful computational checklist for sampled values $p\in[0,1]$ is

$$
C(p)=B(p),
$$

$$
C(1-p)=1-C(p),
$$

and

$$
\operatorname{sign}(C(p)-1/2)=\operatorname{sign}(p-1/2).
$$

### 8.2 Exact finite pattern enumeration

For $N$ possible edges, exact enumeration visits all $2^N$ configurations. For each configuration it computes the number of target patterns contained in it, then accumulates total mass, mean, variance, and zero-event probability. If there are $m$ patterns and subset checks cost $O(N)$ in a direct representation, the worst-case time is $O(2^N mN)$ and storage can remain $O(mN)$ by streaming configurations.

This exponential method is intended for small examples and validation. In structured families, expectation should instead be computed through

$$
\sum_{T\in\mathcal T}p^{|T|},
$$

and variance through overlap classes of pairs $(T,U)$. Grouping by $|T\cap U|$ often converts exponential enumeration into a polynomial or closed-form calculation.

### 8.3 Monte Carlo

For larger finite regions, simulation estimates crossing probabilities. Generate independent Bernoulli states, test the crossing event with breadth-first search or union–find, and average its indicator over $M$ trials. The standard error of a Bernoulli estimate is at most $1/(2\sqrt M)$. Simulation can locate a transition numerically but cannot establish a closed exact threshold.

## 9. From local symmetry to infinite-volume criticality

The local theorem supplies a candidate parameter and exact finite identities. To prove the infinite triangular-site threshold, one needs a chain of additional results.

First, define finite triangular and hexagonal patches with marked boundary arcs, together with primal open paths and appropriate closed dual or matching paths. Establish a deterministic planar alternative: an open crossing excludes, and is complemented by, the corresponding closed crossing.

Second, put Bernoulli product measures on these finite configurations and prove monotonicity of increasing crossing events. Couplings using shared uniform random variables provide a standard route: if $p\le q$, every site open at level $p$ is also open at level $q$.

Third, derive scale-uniform crossing estimates. Local self-duality gives balance in symmetric domains, but transferring that balance across aspect ratios requires gluing and correlation inequalities.

Fourth, prove sharpness. Russo-type differentiation relates the derivative of an increasing-event probability to the expected number of pivotal sites. Sharp-threshold estimates then show that crossing probabilities move rapidly away from criticality.

Fifth, pass to infinite volume through increasing exhaustion and compactness. Subcritical decay rules out infinite clusters below the candidate; supercritical crossings and gluing produce an infinite cluster above it.

Only after these steps does local self-duality become an exact infinite-volume threshold theorem.

The model distinctions are decisive:

1. For triangular-lattice site percolation, the exact critical probability is $1/2$.
2. For square-lattice bond percolation, planar bond duality yields the exact critical probability $1/2$.
3. For square-lattice site percolation, the accepted threshold is numerical, approximately $0.592746$, and no closed analytic form is known.

Therefore the triangular polynomial cannot be transplanted to square-site percolation. Doing so would conflate different geometries and different randomized objects.

## 10. Conformal invariance

At criticality in two dimensions, macroscopic crossing laws can become insensitive to lattice scale and transform naturally under conformal maps. The conjectural and, in central settings, established picture is that when mesh size tends to zero, discrete interfaces converge to random continuous curves. For critical triangular-site percolation, the relevant interface law is $\mathrm{SLE}_6$.

A complete mathematical connection requires substantially more than local duality. One must define discrete exploration paths, prove tightness of their laws, identify every subsequential limit, establish the domain Markov property and conformal covariance, and control boundary behavior. Crossing events must be transported between domains in a measurable way, and convergence must be strong enough to pass probabilities to the limit.

The local identity at $p=1/2$ remains conceptually important: it selects the parameter where open and closed states are balanced. Conformal invariance describes the geometry that emerges after this balance is propagated across arbitrarily many scales.

## 11. Discussion and future work

The exact achievement is deliberately finite but structurally informative. The cubic $3p^2-2p^3$ is simultaneously a majority probability, a complement-symmetric map of the unit interval, and the one-face spanning probability for triangular bonds. Its unique fair point is fixed by complementation and certified by a positive-factor argument.

The moment framework broadens the perspective. In a finite independent-edge system, normalization is a binomial identity; fixed-pattern probabilities are powers of $p$; expected counts are sums of those powers; union bounds turn small expectations into absence; and variance bounds turn robustly large expectations into presence. These tools are elementary enough to be stated without measure-theoretic machinery yet general enough to underlie random-graph and percolation thresholds.

Several directions follow naturally:

- Construct finite planar patches and prove primal/dual crossing alternatives.
- Develop monotone couplings and correlation inequalities for site and bond product measures.
- Formalize matching-lattice transformations without identifying distinct sample spaces.
- Establish pivotal-site differentiation and sharp-threshold estimates.
- Complete an increasing-exhaustion argument for the triangular-site threshold.
- Treat square-bond duality independently.
- Define and rigorously bound the square-site threshold rather than postulating an unsupported exact formula.
- Build scaling-limit and $\mathrm{SLE}_6$ machinery to connect critical crossings with conformal invariance.

## 12. Scope and interpretive safeguards

The word “threshold” is used at several levels, and these should not be conflated. The equation $C(p)=1/2$ defines a fairness point for one specified finite event. A finite-size crossing threshold may instead be the value at which a rectangle-crossing probability reaches a chosen quantile. An infinite-volume critical probability is defined through the existence of an infinite cluster. These quantities can be related by theorems, but they are not synonymous by definition.

Likewise, polynomial equality does not imply model equivalence. The equality $B(p)=C(p)$ follows because both one-face events count successful subsets of size two or three among three Bernoulli objects. It supplies no measure-preserving correspondence between site configurations and bond configurations on an extended lattice. Any global comparison must explicitly describe how paths, boundaries, and probabilities are transported.

Finally, numerical evidence and exact proof serve different roles. Exact enumeration can certify a finite formula once all configurations are included. Monte Carlo can explore larger systems and estimate transition locations with quantified sampling error. Neither a plotted crossing nor a high-precision decimal alone supplies an analytic expression. For square-site percolation, the responsible conclusion is therefore a numerical threshold estimate together with rigorous bounds—not a conjectural closed form presented as established fact.

These safeguards are mathematically productive. They isolate the precise missing lemmas and prevent a local symmetry from being asked to carry global conclusions that require topology, correlation estimates, and limits.

## 13. Conclusion

For a triangular face, the local crossing law is exact:

$$
C(p)=3p^2-2p^3,
$$

$$
C(1-p)=1-C(p),
$$

and

$$
C(p)=\frac12\quad\Longleftrightarrow\quad p=\frac12
$$

for $p\in[0,1]$. The analogous one-face bond-spanning probability is identical. These statements completely settle the local self-duality calculation.

They also clarify what remains. Infinite-volume criticality requires planar topology, probabilistic sharpness, and limiting arguments; conformal invariance requires a further scaling-limit theory. The square-site threshold cannot be assigned a closed expression by analogy. The correct conclusion is both exact and restrained: local triangular symmetry identifies a unique fair parameter, while global threshold theorems demand the full architecture of percolation theory.
