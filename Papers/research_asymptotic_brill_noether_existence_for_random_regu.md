# Square-Root Certificates for Half-Canonical Brill–Noether Existence on Regular Graphs

## Abstract

We isolate an exact arithmetic mechanism underlying half-canonical Brill–Noether existence on finite graphs. For the Brill–Noether number $\rho(g,r,d)=g-(r+1)(g-d+r)$, specialization to degree $d=g-1$ gives the perfect-square identity $\rho(g,r,g-1)=g-(r+1)^2$. Hence admissible nonnegative ranks are exactly those satisfying $(r+1)^2\le g$. On a connected $k$-regular graph with $n$ vertices, the genus relation $2(g-1)=n(k-2)$ converts this into the intrinsic quadratic criterion $2(r+1)^2\le n(k-2)+2$. We then prove a certificate theorem: a single divisor $D$ satisfying $\deg(D)\le C(g-1)$ and $g\le(C\operatorname{rank}(D)+1)^2$ witnesses scaled existence simultaneously for every half-canonical admissible rank. The theorem is independent of a particular divisor theory and transfers pointwise to families of outcomes, making it suitable as the deterministic connector in a high-probability argument for random regular graphs. We give exact integer algorithms for admissibility and certificate testing, clarify the relationship to list choosability as another universal graph property, and identify the remaining spectral and probabilistic inputs needed for asymptotic random-graph existence.

## 1. Introduction

Divisor theory on graphs translates geometric questions into discrete data. A divisor assigns an integer to each vertex of a finite graph. Its degree is the sum of those integers, and its rank measures the ability of its chip-firing equivalence class to absorb arbitrary effective demands. This theory parallels the divisor theory of algebraic curves while retaining a finite, combinatorial character.

A central numerical guide is the Brill–Noether number

$$
\rho(g,r,d)=g-(r+1)(g-d+r),
$$

where $g$ is genus, $d$ is degree, and $r$ is desired rank. The inequality $\rho(g,r,d)\ge0$ specifies the expected existence region. The present work concerns the half-canonical degree $d=g-1$. At that degree, the two-variable dependence on $d$ and $r$ collapses to an exact square. This observation yields both a transparent description of admissible ranks and a useful logical reduction.

The motivating asymptotic problem is the following. Fix an integer $k\ge5$ and sample a uniformly random simple $k$-regular graph on $n$ vertices, where $n$ tends to infinity through admissible values. Its genus is

$$
g=n\left(\frac{k}{2}-1\right)+1.
$$

One seeks a constant $C_k>0$ such that, with probability tending to $1$, every integer $r\ge0$ satisfying $\rho(g,r,g-1)\ge0$ admits a divisor of degree at most $C_k(g-1)$ and rank at least $r/C_k$. The arithmetic results below do not assert the missing high-probability construction. Rather, they reduce it to a single square-root-rank certificate on each graph. The probabilistic and analytic work can therefore concentrate on producing one witness instead of treating all admissible ranks separately.

There are four principal contributions.

1. The half-canonical Brill–Noether number is identified exactly with $g-(r+1)^2$.
2. For regular graphs, admissibility is rewritten solely in terms of $n$, $k$, and $r$.
3. A single controlled-degree divisor reaching the square-root rank threshold is shown to imply the desired existence statement for every admissible rank.
4. The connector is shown to be pointwise over arbitrary outcome spaces, so any probability bound for certificates transfers immediately to the target property.

The framework is intentionally abstract. “Divisor,” “degree,” and “rank” may refer to chip-firing divisors, divisors on metric graphs, or another setting in which degree and rank take nonnegative integer values. Only the displayed numerical inequalities enter the connector theorem.

## 2. Graphs, divisors, and genus

### 2.1 Finite graphs and regularity

A finite simple graph $G=(V,E)$ has no loops and no multiple edges. Write $n=|V|$ and $m=|E|$. The graph is **$k$-regular** if every vertex is incident with exactly $k$ edges. The handshaking identity then gives

$$
2m=\sum_{v\in V}\deg(v)=nk.
$$

For a finite connected graph, define the **genus** or cycle rank by

$$
g=m-n+1.
$$

It is the dimension of the cycle space and counts independent cycles. Combining the two formulas gives

$$
2(g-1)=2(m-n)=nk-2n=n(k-2).
$$

Thus

$$
g=\frac{n(k-2)}2+1.
$$

The parity condition $nk$ even is necessary for the existence of a $k$-regular graph and guarantees integrality of this expression.

### 2.2 Divisor data

For the arithmetic connector it suffices to begin with a class $\mathcal D$ of divisors and maps

$$
\deg:\mathcal D\to\mathbb N,
\qquad
\operatorname{rank}:\mathcal D\to\mathbb N.
$$

In standard graph divisor theory, a divisor is an integer-valued function on vertices. Its degree is the sum of its coefficients. Chip-firing changes a divisor by an integral graph-Laplacian vector and defines linear equivalence. Rank is then the largest integer $r$ such that subtracting every effective divisor of degree $r$ leaves a class equivalent to an effective divisor. The connector below uses only nonnegative degree and rank, so it applies after restricting attention to suitable divisors.

### 2.3 Brill–Noether number

**Definition 2.1 (Brill–Noether number).** For integers $g$, $r$, and $d$, define

$$
\rho(g,r,d)=g-(r+1)(g-d+r).
$$

For fixed genus and degree, nonnegativity of $\rho$ gives the numerical admissibility condition for rank $r$.

**Definition 2.2 (Half-canonical degree).** The half-canonical degree is $d=g-1$, half of the canonical degree $2g-2$.

The terminology is numerical here; no choice of canonical divisor is required.

## 3. The perfect-square threshold

**Theorem 3.1 (Half-Canonical Square Identity).** For all integers $g$ and $r$,

$$
\rho(g,r,g-1)=g-(r+1)^2.
$$

**Proof sketch.** Substitute $d=g-1$ into the definition. The second factor becomes

$$
g-(g-1)+r=r+1.
$$

The product is therefore $(r+1)(r+1)=(r+1)^2$, proving the identity. $\square$

**Corollary 3.2 (Square Admissibility Criterion).** For nonnegative integers $g$ and $r$,

$$
\rho(g,r,g-1)\ge0
\quad\Longleftrightarrow\quad
(r+1)^2\le g.
$$

**Proof sketch.** By Theorem 3.1, nonnegativity says $g-(r+1)^2\ge0$, which is equivalent to the stated inequality. $\square$

This criterion gives an exact endpoint. Define

$$
r_{\max}(g)=\max\{r\in\mathbb N:(r+1)^2\le g\},
$$

when the set is nonempty. For $g\ge1$,

$$
r_{\max}(g)=\lfloor\sqrt g\rfloor-1
$$

if $g$ is a square, while the universally correct integer expression is

$$
r_{\max}(g)=\lfloor\sqrt g-1\rfloor.
$$

Equivalently, one can avoid real square roots by taking the largest integer $s$ with $s^2\le g$ and setting $r_{\max}=s-1$. There are $\lfloor\sqrt g\rfloor$ admissible ranks when $g$ is a square and, in general, exactly $\lfloor\sqrt g\rfloor$ ranks $r\ge0$ satisfying $r+1\le\sqrt g$.

**Theorem 3.3 (Regular-Graph Quadratic Criterion).** Let $n$, $k$, $g$, and $r$ be nonnegative integers with $g\ge1$ and

$$
2(g-1)=n(k-2).
$$

Then

$$
\rho(g,r,g-1)\ge0
\quad\Longleftrightarrow\quad
2(r+1)^2\le n(k-2)+2.
$$

**Proof sketch.** Corollary 3.2 gives $(r+1)^2\le g$. From the genus identity,

$$
2g=n(k-2)+2.
$$

Multiplying the first inequality by $2$ and substituting for $2g$ yields the right-hand condition. Every step is reversible. $\square$

The theorem removes genus from the decision procedure once $n$ and $k$ are known. It also displays the asymptotic scale

$$
r=O\!\left(\sqrt{n(k-2)}\right).
$$

For fixed $k$, the number of ranks under consideration grows as $\Theta(\sqrt n)$.

## 4. Scaled existence and square-root certificates

We now formulate the universal target and the single-witness hypothesis.

**Definition 4.1 (Scaled Half-Canonical Existence).** Let $g,C\in\mathbb N$. A divisor theory has scaled half-canonical existence with scale $C$ at genus $g$ if, for every $r\in\mathbb N$ satisfying $\rho(g,r,g-1)\ge0$, there exists $D\in\mathcal D$ such that

$$
\deg(D)\le C(g-1)
$$

and

$$
r\le C\operatorname{rank}(D).
$$

The rank inequality is the division-free form of $\operatorname{rank}(D)\ge r/C$. It is preferable over the integers because it avoids rounding conventions.

**Definition 4.2 (Square-Root Rank Certificate).** A divisor $D\in\mathcal D$ is a square-root rank certificate at genus $g$ and scale $C$ if

$$
\deg(D)\le C(g-1)
$$

and

$$
g\le\bigl(C\operatorname{rank}(D)+1\bigr)^2.
$$

The second inequality can be read as

$$
C\operatorname{rank}(D)+1\ge\sqrt g.
$$

The squared form is exact over integers and avoids numerical approximation.

**Theorem 4.3 (Square-Root Certificate Theorem).** If a square-root rank certificate exists at genus $g$ and scale $C$, then scaled half-canonical existence holds at genus $g$ and scale $C$. More strongly, the certificate divisor itself works for every admissible rank.

**Proof sketch.** Let $D$ be the certificate and let $r\ge0$ satisfy $\rho(g,r,g-1)\ge0$. Corollary 3.2 and the certificate inequality give

$$
(r+1)^2\le g\le\bigl(C\operatorname{rank}(D)+1\bigr)^2.
$$

Both $r+1$ and $C\operatorname{rank}(D)+1$ are nonnegative. Since squaring is order-preserving on nonnegative integers,

$$
r+1\le C\operatorname{rank}(D)+1.
$$

Subtracting $1$ gives $r\le C\operatorname{rank}(D)$. The certificate already supplies $\deg(D)\le C(g-1)$, so $D$ satisfies both required inequalities. As $r$ was arbitrary, the universal property follows. $\square$

The theorem is an endpoint principle. Admissibility is monotone in $r$: if a rank is admissible, every smaller nonnegative rank is admissible. Likewise, once the scaled rank of $D$ reaches the maximal endpoint, it dominates all smaller requests. The perfect-square identity makes this monotonicity exact.

### 4.1 Pointwise families and events

Suppose $\Omega$ is any set of outcomes. For each $\omega\in\Omega$, let the genus be $g(\omega)$ and let degree and rank measurements be $\deg_\omega$ and $\operatorname{rank}_\omega$. Fix a common scale $C$.

**Theorem 4.4 (Outcome-Wise Certificate Transfer).** If every $\omega\in\Omega$ admits a divisor $D_\omega$ satisfying

$$
\deg_\omega(D_\omega)\le C(g(\omega)-1)
$$

and

$$
g(\omega)\le\bigl(C\operatorname{rank}_\omega(D_\omega)+1\bigr)^2,
$$

then every outcome has scaled half-canonical existence with the same scale $C$.

**Proof sketch.** Fix an outcome $\omega$. Its hypotheses are exactly those of Theorem 4.3 with the data specialized to $\omega$. Applying that theorem proves the desired property at $\omega$. Since the outcome was arbitrary, the conclusion holds throughout $\Omega$. $\square$

If $\Omega$ carries a probability measure, define the certificate event $A$ and target event $B$. The theorem states $A\subseteq B$, hence

$$
\mathbb P(B)\ge\mathbb P(A).
$$

Therefore $\mathbb P(A_n)\to1$ implies $\mathbb P(B_n)\to1$. No independence assumption is needed; this is simple event containment.

## 5. Exact algorithms

The reductions suggest small, robust computational routines. All use integer arithmetic.

### 5.1 Admissible-rank enumeration

Given $g\ge1$, start at $r=0$ and continue while $(r+1)^2\le g$. This lists precisely the half-canonical admissible ranks by Corollary 3.2.

**Algorithm 5.1 (Square-Threshold Rank Enumeration).** Input a genus $g\ge1$. Initialize an empty list and $r=0$. While $(r+1)^2\le g$, append $r$ and increment $r$. Return the list.

The loop runs $\Theta(\sqrt g)$ times and stores $\Theta(\sqrt g)$ integers. If only the endpoint is needed, integer square root computes it in time polynomial in $\log g$, after which $r_{\max}=\lfloor\sqrt g\rfloor-1$.

### 5.2 Regular-graph computation

Given admissible $n$ and $k$, compute

$$
g=\frac{n(k-2)}2+1.
$$

Parity of $n(k-2)$ should be checked. For an actual $k$-regular graph, this follows from the handshaking constraint. Admissibility may then be tested either by $(r+1)^2\le g$ or directly by

$$
2(r+1)^2\le n(k-2)+2.
$$

The two tests are mathematically identical.

### 5.3 Certificate testing

Given $g$, $C$, and a proposed divisor’s degree $d_D$ and rank $q_D$, check

$$
d_D\le C(g-1)
$$

and

$$
g\le(Cq_D+1)^2.
$$

If both tests pass, all admissible ranks are covered. The test uses a constant number of additions, multiplications, and comparisons. With integer multiplication cost $M(b)$ on $b$-bit numbers, its bit complexity is $O(M(\log g))$ when parameters have size polynomial in $g$.

### 5.4 Numerical example

Take $n=50$ and $k=6$. Then

$$
g=\frac{50\cdot4}{2}+1=101.
$$

The admissible ranks satisfy $(r+1)^2\le101$, hence they are $0,1,\ldots,9$. Let $C=4$, and suppose a divisor has degree $300$ and rank $3$. Its degree bound is

$$
300\le4(101-1)=400,
$$

and its rank threshold is

$$
101\le(4\cdot3+1)^2=169.
$$

It is therefore a certificate. The theorem concludes that, for every $r\in\{0,\ldots,9\}$,

$$
r\le4\cdot3=12,
$$

and the same divisor meets the required degree bound. The numerical values are illustrative; the theorem requires no assumption about how the divisor was found.

## 6. Relation to list choosability

A separate universal notion helps clarify the logical structure.

**Definition 6.1 (List choosability).** Let $G=(V,E)$ be a graph and $q\in\mathbb N$. The graph is $q$-choosable if, for every assignment $L$ that gives each vertex $v$ a finite set $L(v)$ of at least $q$ allowed natural-number colors, there exists a choice $c(v)\in L(v)$ for each vertex such that $c(u)\ne c(v)$ whenever $u$ and $v$ are adjacent.

Choosability quantifies universally over list assignments and existentially over compatible colorings. Scaled half-canonical existence quantifies universally over admissible ranks and existentially over divisors. The Square-Root Certificate Theorem reveals additional monotonic structure in the latter: one extremal witness answers all rank requests. No analogous reduction for arbitrary list assignments is asserted. The comparison instead highlights a useful design question for graph algorithms: can a universally quantified family of demands be replaced by a monotone endpoint certificate?

## 7. Application to random regular graphs

Fix $k\ge5$. For each admissible $n$, let $G_n$ be uniformly distributed over simple $k$-regular graphs on $n$ vertices. Every such graph has

$$
g_n=\frac{n(k-2)}2+1=n\left(\frac{k}{2}-1\right)+1.
$$

The desired asymptotic property asks for a constant $C_k>0$ such that, with probability tending to $1$, every $r\ge0$ satisfying

$$
(r+1)^2\le g_n
$$

has a divisor $D$ with

$$
\deg(D)\le C_k(g_n-1),
\qquad
r\le C_k\operatorname{rank}(D).
$$

By Theorem 4.3, it is sufficient to establish with high probability the existence of one divisor satisfying

$$
\deg(D)\le C_k(g_n-1),
\qquad
g_n\le\bigl(C_k\operatorname{rank}(D)+1\bigr)^2.
$$

Equivalently, up to the exact integer offset, the required witness has rank at least $\sqrt{g_n}/C_k$ and degree $O_k(g_n)$. Because $g_n=\Theta_k(n)$, the target rank is $\Theta_k(\sqrt n)$.

A plausible pipeline is as follows. Expansion or a spectral gap controls a graph-Laplacian energy geometry. This control bounds a covering radius for an associated lattice or fundamental domain. A covering-radius estimate is converted into a chip-firing rank lower bound for a divisor of controlled degree. The resulting divisor becomes the square-root certificate, and event containment transfers the high-probability estimate to all admissible ranks.

The arithmetic connector deliberately does not conflate these stages. In particular, it does not claim that expansion alone supplies the certificate without an explicit theorem relating expansion, covering radius, and divisor rank. Nor does it supply a value of $C_k$. Those are substantive analytic tasks remaining for the random-graph program.

## 8. Structural consequences and boundary behavior

The square criterion gives several immediate consequences worth recording.

**Proposition 8.1 (Monotonicity in genus).** If rank $r$ is half-canonical admissible at genus $g$, then it remains admissible at every genus $g'\ge g$.

**Proof sketch.** Admissibility at $g$ is $(r+1)^2\le g$. Combining this with $g\le g'$ gives $(r+1)^2\le g'$, which is admissibility at $g'$. $\square$

**Proposition 8.2 (Initial-Interval Property).** If $r$ is half-canonical admissible at genus $g$, then every integer $s$ with $0\le s\le r$ is also admissible.

**Proof sketch.** Nonnegativity gives $s+1\le r+1$. Squaring preserves the inequality, and $(r+1)^2\le g$ completes the argument. $\square$

**Proposition 8.3 (Perfect-Square Jump Law).** As genus increases by one, the number of admissible nonnegative ranks changes only when the new genus is a perfect square. If $g=t^2$, the newly admitted rank is $t-1$.

**Proof sketch.** A rank $r$ first becomes admissible at genus $(r+1)^2$. Thus entry points are exactly positive perfect squares, and at $t^2$ the entering rank satisfies $r+1=t$. $\square$

These statements expose the discrete geometry behind the threshold. The lattice point $r+1$ moves along the nonnegative number line, while genus supplies a squared radius. The admissible set is the intersection of the integer lattice with the interval $[1,\sqrt g]$, shifted down by one.

There is also a quantitative sensitivity law for certificates. If a divisor rank rises from $q$ to $q+1$ at fixed scale $C$, the largest genus directly covered by the squared-rank inequality rises by

$$
\bigl(C(q+1)+1\bigr)^2-(Cq+1)^2
=2C(Cq+1)+C^2.
$$

Thus an additive rank improvement can produce a genus gain linear in $q$ and quadratic in $C$. Conversely, at fixed genus, the minimal integer rank required of a certificate is the least $q\ge0$ satisfying $Cq+1\ge\sqrt g$. Exact computation may use

$$
q_{\min}=\max\left\{0,\left\lceil\frac{\lceil\sqrt g\rceil-1}{C}\right\rceil\right\}.
$$

The ceiling reflects that the certificate must dominate $\sqrt g$, whereas admissibility uses the floor below $\sqrt g$. This distinction matters near nonsquare genera.

Finally, the certificate theorem is stable under strengthening. If $D$ is a certificate at scale $C$ and a second divisor $D'$ has no larger degree and no smaller rank, then $D'$ is also a certificate. Likewise, any stronger analytic estimate implying the two certificate inequalities can be substituted without changing the arithmetic argument. This modularity is the main reason to separate certificate construction from rank propagation.

## 9. Discussion

The half-canonical degree is distinguished by exact algebra. At a general degree $d$, admissibility reads

$$
g\ge(r+1)(g-d+r),
$$

whose two factors are not equal. At $d=g-1$, they coincide and produce a square. The resulting threshold has three benefits.

First, it is transparent: admissible ranks are a contiguous interval determined by $\sqrt g$. Second, it is computationally stable: every test can be performed with exact integer squares. Third, it is compositional: any method producing the certificate inequalities can be connected to the universal existence conclusion without reopening the Brill–Noether calculation.

The same divisor serving all ranks is stronger than the bare statement, which allows a different divisor for each $r$. This strengthening costs nothing because the endpoint inequality already dominates the full admissible interval. It may also simplify constructions: an analytic argument can optimize one object rather than coordinate a family.

The scale $C$ appears in both degree and rank. Increasing $C$ relaxes both inequalities: it allows a larger degree budget and amplifies the rank of the witness. The smallest workable constant therefore captures a joint efficiency tradeoff. Optimizing it requires detailed information about the chosen divisor theory and graph family; the connector remains valid for any natural-number $C$.

The restriction to nonnegative rank is essential to the monotone square-root argument as stated. This is also the range relevant to the existence question. The hypothesis $g\ge1$ in the regular-graph criterion ensures natural-number subtraction behaves as intended and corresponds to graphs with at least one cycle. For $k\ge5$ and nontrivial regular graphs, this is automatic.

## 10. Future work

The next mathematical objective is to construct, with high probability for random $k$-regular graphs, a divisor $D$ with

$$
\deg(D)\le C_k(g-1)
$$

and

$$
g\le(C_k\operatorname{rank}(D)+1)^2.
$$

Five steps naturally organize this program.

1. Develop the genus identity $2(g-1)=n(k-2)$ directly from the handshaking lemma for finite connected simple regular graphs.
2. Relate the graph Laplacian’s energy pairing and covering radius to an explicit lower bound on chip-firing divisor rank.
3. Derive the covering-radius estimate from a Cheeger inequality, an edge-expansion hypothesis, or a spectral-gap hypothesis.
4. Combine that deterministic estimate with a high-probability expansion theorem for random regular graphs.
5. Optimize $C_k$, keeping analytic optimization separate from the exact half-canonical arithmetic.

A further direction is to search for comparable endpoint reductions at degrees near $g-1$. There the Brill–Noether expression is no longer a perfect square, but it remains quadratic in $r$. Completing the square may yield approximate certificates with controlled error terms. Another direction is algorithmic: given a concrete graph, construct rather than merely test a certificate, perhaps through lattice reduction, potential minimization, or randomized chip-firing searches.

## 11. Conclusion

At half-canonical degree, the Brill–Noether number obeys the exact identity

$$
\rho(g,r,g-1)=g-(r+1)^2.
$$

For regular graphs this becomes the size-valency criterion

$$
2(r+1)^2\le n(k-2)+2.
$$

Most importantly, a single divisor satisfying

$$
\deg(D)\le C(g-1),
\qquad
g\le(C\operatorname{rank}(D)+1)^2
$$

proves scaled existence for every admissible rank. This deterministic endpoint certificate transfers pointwise to arbitrary families and therefore through high-probability events. It separates an exact arithmetic core from the analytic challenge of building high-rank divisors on expanding random regular graphs, reducing a square-root-sized family of existence demands to one witness.