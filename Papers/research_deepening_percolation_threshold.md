# Self-Dual Crossing Functions and Exact Half-Probability Laws

**Aristotle**  
**August 3, 2026**

## Abstract

We isolate a general symmetry principle underlying exact finite-volume balance points in percolation and related probabilistic systems. A crossing function $C:[0,1]\to\mathbb R$ is called self-dual when $C(1-p)=1-C(p)$. We prove that every such function satisfies $C(1/2)=1/2$, without continuity or monotonicity assumptions. Under strict monotonicity, parameters below $1/2$ have crossing value below $1/2$, parameters above $1/2$ have crossing value above $1/2$, and $p=1/2$ is the unique solution of the fair-crossing equation. After centering, self-duality is expressed as exact antisymmetry about the midpoint. We then establish the measure-theoretic source of this identity: if a probability-preserving transformation exchanges a measurable event with its complement, that event and its complement each have probability $1/2$. We discuss finite Bernoulli systems, percolation crossings, numerical diagnostics, algorithms for certifying self-dual balance, and the distinction between finite self-duality and infinite-volume criticality. The results supply a reusable core for exact threshold arguments while making explicit the geometric and limiting ingredients still required in lattice-specific applications.

## 1. Introduction

Percolation theory studies the emergence of large connected structures from independent local randomness. In bond percolation, edges are declared open independently; in site percolation, vertices are declared occupied independently. A finite crossing event asks whether an open path traverses a prescribed region, while an infinite-volume event asks whether an unbounded open cluster exists. Both kinds of questions depend on a parameter $p\in[0,1]$ controlling the probability that a local component is open.

Exact threshold arguments frequently begin with duality. A primal crossing may exclude, and be excluded by, a dual crossing in the transverse direction. At a parameter fixed by exchanging open and closed states, symmetry can force the two alternatives to have equal probability. The present paper separates this probabilistic core from the model-specific planar geometry.

The central object is a real-valued function $C$ on the Bernoulli interval. It may be a finite crossing probability, a reliability function, a voting probability, or any statistic whose complement transforms naturally under $p\mapsto1-p$. The defining relation

$$
C(1-p)=1-C(p)
$$

implies an exact midpoint value. If $C$ is strictly increasing, it also identifies the unique fair parameter and the strict ordering on either side. Re-centering at $(1/2,1/2)$ turns the duality relation into odd symmetry.

At a more structural level, let $(\Omega,\mathcal F,\mu)$ be a probability space and $T:\Omega\to\Omega$ preserve $\mu$. If $T^{-1}(A)=A^{\mathrm c}$ for a measurable event $A$, then invariance gives $\mu(A)=\mu(A^{\mathrm c})$, and complementation gives $\mu(A)+\mu(A^{\mathrm c})=1$. Thus $\mu(A)=1/2$. This theorem explains why many apparently combinatorial half-probability identities are instances of one measure-theoretic conservation law.

The scope is deliberately precise. These results identify exact finite-volume fair points under stated symmetry assumptions. They do not, by themselves, equate that fair point with an infinite-volume critical threshold. Such an identification requires additional geometric and analytic theory. In particular, no closed analytic value for infinite square-lattice site percolation follows from the present principle; that threshold is not presently known in closed form.

## 2. Basic framework

### 2.1 Crossing functions

**Definition 2.1 (Crossing function).** A crossing function is a map $C:[0,1]\to\mathbb R$ whose value $C(p)$ represents the probability, or another normalized score, of a designated crossing event at Bernoulli parameter $p$.

When $C$ is a probability, its range lies in $[0,1]$. The algebraic theorems below only require a real-valued function because the self-duality identity itself supplies the relevant midpoint relation.

**Definition 2.2 (Self-duality).** A crossing function $C$ is self-dual on $[0,1]$ if

$$
C(1-p)=1-C(p)
$$

for every $p\in[0,1]$.

Parameter complementation exchanges the probabilities assigned to open and closed local states. Value complementation exchanges success with failure. Self-duality asserts compatibility of these two operations.

**Definition 2.3 (Strict monotonicity).** A crossing function $C$ is strictly increasing on $[0,1]$ if $C(p)<C(q)$ whenever $0\le p<q\le1$.

For an increasing event in a finite Bernoulli product space, ordinary monotonicity follows from coupling. Strictness requires that changing the parameter genuinely affects the event; it is therefore stated explicitly rather than inferred abstractly.

### 2.2 Probability-preserving transformations

Let $(\Omega,\mathcal F,\mu)$ be a probability space. A map $T:\Omega\to\Omega$ is **probability-preserving** if it is measurable and

$$
\mu(T^{-1}(B))=\mu(B)
$$

for every measurable $B\in\mathcal F$. We say that $T$ **exchanges an event with its complement** when

$$
T^{-1}(A)=A^{\mathrm c}.
$$

The use of inverse images is important: measure preservation is naturally stated through inverse images and does not require $T$ to be invertible. In many finite examples $T$ is an involution, such as bitwise complementation, but involutivity is stronger than necessary.

## 3. Functional self-duality

### 3.1 The midpoint theorem

**Theorem 3.1 (Self-dual midpoint).** Let $C:[0,1]\to\mathbb R$ satisfy $C(1-p)=1-C(p)$ for every $p\in[0,1]$. Then

$$
C(1/2)=1/2.
$$

**Proof sketch.** Set $p=1/2$. Since $1-1/2=1/2$, self-duality gives $C(1/2)=1-C(1/2)$. Adding $C(1/2)$ to both sides and dividing by $2$ yields the claim. No regularity hypothesis is used. $\square$

The theorem is a fixed-point statement. The transformation $p\mapsto1-p$ has the unique fixed point $1/2$, as does the transformation $y\mapsto1-y$. A self-dual function intertwines these transformations and must send the parameter fixed point to the value fixed point.

### 3.2 Strict inequalities around the midpoint

**Theorem 3.2 (Subfair side).** Suppose $C$ is self-dual and strictly increasing on $[0,1]$. For every $p$ satisfying $0\le p<1/2$,

$$
C(p)<1/2.
$$

**Proof sketch.** Strict monotonicity gives $C(p)<C(1/2)$. Theorem 3.1 identifies the latter value as $1/2$. $\square$

**Theorem 3.3 (Superfair side).** Suppose $C$ is self-dual and strictly increasing on $[0,1]$. For every $p$ satisfying $1/2<p\le1$,

$$
C(p)>1/2.
$$

**Proof sketch.** Strict monotonicity gives $C(1/2)<C(p)$, and Theorem 3.1 gives $C(1/2)=1/2$. $\square$

Together these results classify the entire parameter interval relative to the fair value. Their content is stronger than the midpoint theorem because strict monotonicity excludes any interval on which the crossing probability remains equal to one half.

### 3.3 Uniqueness of the fair parameter

**Theorem 3.4 (Unique fair parameter).** Let $C:[0,1]\to\mathbb R$ be self-dual and strictly increasing. Then, for every $p\in[0,1]$,

$$
C(p)=1/2\quad\Longleftrightarrow\quad p=1/2.
$$

**Proof sketch.** The reverse implication is Theorem 3.1. For the forward implication, exactly one of $p<1/2$, $p=1/2$, or $p>1/2$ holds. The first case contradicts Theorem 3.2, and the third contradicts Theorem 3.3. Therefore $p=1/2$. $\square$

Continuity is notably absent. Strict order, not an intermediate-value argument, yields uniqueness.

### 3.4 Centered antisymmetry

Define the centered crossing function $G:[-1/2,1/2]\to\mathbb R$ by

$$
G(x)=C(1/2+x)-1/2.
$$

**Theorem 3.5 (Centered antisymmetry).** If $C$ is self-dual, then for every $x\in[-1/2,1/2]$,

$$
C(1/2+x)-1/2=-\bigl(C(1/2-x)-1/2\bigr),
$$

or equivalently,

$$
G(x)=-G(-x).
$$

**Proof sketch.** Apply self-duality at $p=1/2-x$. Its complementary parameter is $1-(1/2-x)=1/2+x$, so

$$
C(1/2+x)=1-C(1/2-x).
$$

Subtracting $1/2$ and rearranging gives the result. The bounds on $x$ ensure that both parameters lie in $[0,1]$. $\square$

This formulation makes the geometry transparent: after translating the graph by $(-1/2,-1/2)$, it is invariant under rotation by $180$ degrees about the origin. If additional smoothness is available, $G$ has the derivative parity expected of an odd function. For example, when the derivatives exist, even-order derivatives of $G$ at $0$ vanish. Such consequences are secondary; the antisymmetry theorem itself is purely algebraic.

## 4. Event-level symmetry

### 4.1 Exchange with a complement

**Theorem 4.1 (Probability-halving symmetry).** Let $(\Omega,\mathcal F,\mu)$ be a probability space, let $A\in\mathcal F$, and let $T:\Omega\to\Omega$ be probability-preserving. If

$$
T^{-1}(A)=A^{\mathrm c},
$$

then

$$
\mu(A)=1/2.
$$

**Proof sketch.** Probability preservation and the exchange identity imply

$$
\mu(A)=\mu(T^{-1}(A))=\mu(A^{\mathrm c}).
$$

Measurability gives the complement identity

$$
\mu(A)+\mu(A^{\mathrm c})=\mu(\Omega)=1.
$$

Replacing $\mu(A^{\mathrm c})$ by $\mu(A)$ yields $2\mu(A)=1$, hence $\mu(A)=1/2$. $\square$

The theorem requires neither independence nor a product structure. It applies to arbitrary probability spaces and arbitrary probability-preserving transformations. Independence enters particular percolation models when the measure and its symmetries are constructed, not in the abstract halving argument.

### 4.2 Two exchanged complementary events

**Theorem 4.2 (Complementary pair theorem).** Let $(\Omega,\mathcal F,\mu)$ be a probability space. Let $A,D\in\mathcal F$ satisfy $D=A^{\mathrm c}$, and let $T$ be probability-preserving with

$$
T^{-1}(A)=D.
$$

Then

$$
\mu(A)=\mu(D)=1/2.
$$

**Proof sketch.** Substituting $D=A^{\mathrm c}$ into the exchange identity allows Theorem 4.1 to be applied to $A$. Hence $\mu(A)=1/2$. Since $D$ is the complement of $A$, $\mu(D)=1-\mu(A)=1/2$. $\square$

This paired form is natural in planar models, where $A$ and $D$ may have separate geometric descriptions, such as a primal crossing and a dual transverse crossing. The condition $D=A^{\mathrm c}$ must be proved; it is not a consequence of naming one event “dual.”

## 5. Finite Bernoulli models

Consider $n$ independent bits $\omega=(\omega_1,\ldots,\omega_n)\in\{0,1\}^n$ under the product measure

$$
\mu_p(\{\omega\})=p^{|\omega|}(1-p)^{n-|\omega|},
$$

where $|\omega|=\sum_i\omega_i$. Let $K(\omega)=(1-\omega_1,\ldots,1-\omega_n)$ be bitwise complementation. A direct calculation gives

$$
\mu_p(\{K\omega\})=\mu_{1-p}(\{\omega\}).
$$

Thus complementation transports the parameter-$p$ law to the parameter-$(1-p)$ law. At $p=1/2$, it preserves the law.

Suppose an event $A$ has the combinatorial self-duality property

$$
K^{-1}(A)=A^{\mathrm c}.
$$

Writing $C(p)=\mu_p(A)$, transport under $K$ yields

$$
C(1-p)=1-C(p).
$$

At $p=1/2$, Theorem 4.1 applies directly; for all $p$, Theorem 3.1 applies to the resulting function.

### 5.1 Odd majority as a worked example

Let $n=2m+1$ and let $A$ be the event that more than $m$ bits are $1$. Its probability is

$$
C_n(p)=\sum_{k=m+1}^{2m+1}\binom{2m+1}{k}p^k(1-p)^{2m+1-k}.
$$

Because there is no tie, complementation exchanges open majority with closed majority, exactly the complementary event. Therefore

$$
C_n(1-p)=1-C_n(p),\qquad C_n(1/2)=1/2.
$$

The majority event is strictly increasing in $p$, so $p=1/2$ is its unique fair parameter. For example, with $n=5$,

$$
C_5(p)=10p^3(1-p)^2+5p^4(1-p)+p^5.
$$

At symmetric parameters, values add to one. Numerically, $C_5(0.3)=0.16308$ and $C_5(0.7)=0.83692$. At the midpoint, $C_5(0.5)=0.5$. This family also illustrates increasing steepness: as odd $n$ grows, majority probability approaches a step profile around $1/2$, although every finite member retains exact centered antisymmetry.

## 6. Algorithms and numerical diagnostics

### 6.1 Symmetry-certificate algorithm

The abstract theorems suggest a proof-oriented workflow for a finite model.

1. Specify a finite configuration space $\Omega$ and a probability measure $\mu$.
2. Define a measurable event $A$ representing success.
3. Construct a transformation $T:\Omega\to\Omega$ suggested by geometric or state-complement symmetry.
4. Verify probability preservation: $\mu(T^{-1}(B))=\mu(B)$ for all events $B$, or verify it on atoms in a finite space.
5. Verify exact event exchange: $T^{-1}(A)=A^{\mathrm c}$.
6. Conclude $\mu(A)=1/2$.
7. If the law varies with $p$, derive $C(1-p)=1-C(p)$.
8. If strict monotonicity is established, conclude that $p=1/2$ is the unique fair parameter.

For a finite space of size $N$, exhaustive verification of steps 4 and 5 can be performed in $O(N)$ evaluations when $T$, event membership, and atomic weights are available in constant time. The theorem then upgrades the finite check into an exact probability statement. In structured models one normally proves the identities symbolically rather than enumerating all states.

### 6.2 Evaluating a binomial crossing model

For the odd-majority example, $C_n(p)$ can be evaluated from the binomial tail. A direct summation uses $O(n)$ arithmetic operations and $O(1)$ auxiliary storage if terms are accumulated sequentially. Evaluating both $C_n(p)$ and $C_n(1-p)$ permits the residual

$$
R_n(p)=C_n(p)+C_n(1-p)-1
$$

to be monitored. In exact arithmetic $R_n(p)=0$. Floating-point residuals should remain near rounding scale.

A numerically stable implementation can update adjacent binomial terms recursively rather than recomputing powers and binomial coefficients. For moderate $n$, direct use of integer binomial coefficients and floating-point powers is adequate and transparent.

### 6.3 Bisection and its logical status

If $C$ is continuous and strictly increasing, bisection can numerically solve $C(p)=1/2$ in $O(\log(1/\varepsilon))$ function evaluations to parameter tolerance $\varepsilon$. Under exact self-duality, however, the answer is already known symbolically: $p=1/2$. Bisection is then a diagnostic rather than a source of the theorem. This distinction matters: numerical agreement suggests symmetry but does not establish the event-exchange hypotheses.

## 7. Percolation interpretation

In finite planar percolation, one often studies an event $A_p$ that an open primal path crosses a region. A dual event $D_p$ may describe a closed dual path crossing in the transverse direction. A model-specific planar separation argument can establish that exactly one of these events occurs:

$$
D_p=A_p^{\mathrm c}.
$$

A geometric symmetry, often combined with open–closed complementation, may transport the primal event at parameter $p$ to the dual event at parameter $1-p$. If the geometry identifies the two crossing setups, then their common crossing function satisfies

$$
C(1-p)=1-C(p).
$$

The functional theorems of Section 3 then identify the exact finite-volume fair point. At $p=1/2$, a probability-preserving configuration symmetry may also permit direct application of Theorem 4.2.

Three logical layers should be distinguished:

1. **Combinatorial topology:** primal success and dual obstruction are complementary.
2. **Probabilistic symmetry:** the relevant transformation preserves or transports the Bernoulli law.
3. **Infinite-volume analysis:** finite crossing information controls the appearance of unbounded clusters.

The present results completely address the abstract algebra of the second layer once the event exchange is known, and they clarify the input expected from the first. They do not replace the third.

This distinction prevents an incorrect transfer between models. Square-lattice bond percolation and square-lattice site percolation have different dual structures. Even when a finite event has a visually symmetric formulation, exact complementarity and measure transport must be checked. The infinite square-lattice site threshold remains without a known closed analytic form; it should not be assigned the value $1/2$ merely by analogy.

## 8. Applications beyond planar percolation

### 8.1 Network reliability

Let $A$ be the event that designated terminals communicate in a random network. If a transformation of component states and network geometry preserves the law while exchanging terminal connection with disconnection, Theorem 4.1 gives exact half reliability. A parameterized family then inherits the self-dual crossing identity. The chief challenge is usually geometric: disconnection may correspond to a cut event in a dual network rather than the literal complement of a connection event in the same representation.

### 8.2 Voting and collective decisions

For an odd number of independent voters, let $A$ be strict approval by a majority. Flipping every vote preserves the unbiased product measure and exchanges approval with rejection. Therefore approval has probability $1/2$ at individual approval probability $1/2$. Strict monotonicity makes this the unique fair bias. Weighted or constrained voting systems fit the same scheme only when the flip transformation truly exchanges the decision event with its complement.

### 8.3 Reliability of symmetric decision rules

Any Boolean rule $f:\{0,1\}^n\to\{0,1\}$ satisfying

$$
f(1-\omega)=1-f(\omega)
$$

is self-dual. Under unbiased independent inputs, its acceptance probability is exactly $1/2$. Under biased inputs, its acceptance function satisfies the parameter-complement identity. This includes many balanced classifiers, voting rules, and fault-detection schemes.

## 9. Discussion

The results demonstrate a useful division of labor between symmetry, monotonicity, and geometry.

Self-duality alone determines the midpoint value and centered antisymmetry. It makes no statement about uniqueness because a non-strictly monotone or highly irregular function may equal $1/2$ elsewhere. Strict monotonicity supplies the ordering required for uniqueness. At the event level, probability preservation supplies equality of the masses of an event and its complement, while the probability-space axiom supplies their sum.

The assumptions are close to minimal for the conclusions stated. The midpoint identity needs self-duality only at $p=1/2$, although the global identity is needed for antisymmetry over the full centered interval. The event theorem needs preservation for the particular event $A$, rather than every measurable set, but the standard measure-preserving hypothesis is natural and reusable. Measurability is essential for the complement probability identity.

The framework also separates exact mathematics from empirical exploration. Simulations can display a crossing curve, estimate steepness, and test the residual $C(p)+C(1-p)-1$. They cannot establish exact equality for every parameter. Conversely, the symmetry theorem gives an exact fair point but does not quantify finite-size scaling or critical exponents. Each tool answers a different question.

## 10. Boundaries, hypotheses, and counterexamples

The conclusions can fail in predictable ways when a hypothesis is removed. If self-duality is absent, strict monotonicity alone does not locate the fair point: the function $C(p)=p^2$ is strictly increasing on $[0,1]$, but $C(p)=1/2$ occurs at $p=1/\sqrt2$. If strict monotonicity is absent, self-duality still fixes the midpoint but need not make it unique. The constant function $C(p)=1/2$ is self-dual and fair at every parameter. Thus symmetry identifies a fixed point, while strict order isolates it.

At event level, merely mapping some configurations in $A$ to configurations outside $A$ is insufficient. The exact inverse-image identity $T^{-1}(A)=A^{\mathrm c}$ ensures that no configurations are omitted and none are counted twice. Likewise, event exchange without probability preservation does not force equal masses. On a two-point space with unequal atomic probabilities, swapping the points exchanges either singleton with its complement but changes probability; neither singleton need have probability $1/2$.

Boundary conventions deserve particular attention in planar crossing problems. A primal left-to-right crossing and a dual top-to-bottom obstruction may be complementary only after specifying how the dual graph meets the boundary and how corner contacts are treated. An apparent diagrammatic symmetry can fail because the two boundary conditions are not transported into one another. The abstract theorem intentionally does not hide these issues: it accepts event complementarity as a hypothesis that must be established in the concrete geometry.

The codomain $\mathbb R$ in the functional statements is convenient but not the deepest feature. The midpoint proof uses addition and division by two, whereas the ordering results use a strict linear order. Similar fixed-point principles can be stated in other ordered affine settings. For probability applications, however, real-valued or extended-real-valued measures provide the natural setting.

Finally, self-duality should not be confused with statistical independence between an event and its image. At the fair point, $A$ and $A^{\mathrm c}$ are maximally dependent: exactly one occurs. The conclusion $\mu(A)=1/2$ comes from equal mass and exhaustiveness, not from independence. This observation is useful when translating the theorem into applications, where the symmetry may create strong correlations among transformed observables.

## 11. Future work

Several extensions would connect the abstract half-probability law to deeper percolation results.

First, one can instantiate the event theorem for finite planar bond-percolation configurations, proving complementarity of primal and dual crossings by a discrete Jordan-curve argument. Second, a theory of planar dual graphs and infinite-volume limits can connect finite-box duality to the square-lattice bond threshold. Third, monotone crossing probabilities can be integrated with product Bernoulli measures and sharp-threshold estimates.

The star–triangle transformation offers a route for transferring exact bond thresholds among triangular and hexagonal lattices. At larger scales, one may ask how event-level self-duality behaves in scaling limits, where conformal maps transport crossing events and preserve limiting probabilities. Throughout this program, numerical estimates for the infinite square-lattice site threshold should remain clearly separated from exact theorems because no closed analytic form is presently known.

## 12. Conclusion

A single reflection identity organizes the finite self-dual theory. If

$$
C(1-p)=1-C(p),
$$

then $C(1/2)=1/2$ and the centered graph is antisymmetric. If $C$ is strictly increasing, the midpoint is the unique fair parameter, with strict inequalities on either side. Beneath the functional identity lies an event-level conservation principle: a probability-preserving symmetry that exchanges an event with its complement divides total probability equally between them.

These statements are elementary in proof but broad in application. They provide the exact probabilistic core of many self-duality arguments and identify, with precision, what remains model-specific: the construction of a symmetry, the proof of event complementarity, and the passage from finite crossings to infinite critical behavior.
