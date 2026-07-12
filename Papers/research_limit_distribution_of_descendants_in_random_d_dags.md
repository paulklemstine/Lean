# The Limit Distribution of Descendants in Random $d$-DAGs

## Abstract

We study the number of descendants of a founding vertex in the random recursive
directed acyclic graph (DAG) $G_n$ of out-degree $d \ge 2$, in which each vertex
$v > d$ attaches to $d$ distinct earlier vertices chosen uniformly at random. The
central object is the descendant count $|D_n|$, and the central phenomenon is that,
after rescaling by $n^{1/d}$, it converges in distribution to a Gamma law with
shape $d$ and rate $1$:
$$\frac{|D_n|}{n^{1/d}} \xrightarrow{\;d\;} \mathrm{Gamma}(d, 1).$$
We isolate and rigorously establish the two analytic pillars of this statement.
First, we analyze the **mean-growth product** $P_n(a) = \prod_{k=1}^n (1 + a/k)$
that governs the expected descendant count with $a = 1/d$: we prove its exact
closed form $P_n(a) = \Gamma(n+1+a)/(\Gamma(1+a)\,n!)$ and the scaling limit
$P_n(a)/n^a \to 1/\Gamma(1+a)$, which pins the normalization exponent to exactly
$1/d$. Second, we develop the **Gamma$(d,1)$ target distribution**: we verify that
its density integrates to one, compute its $p$-th moment $\Gamma(d+p)/\Gamma(d)$,
establish the moment recurrence $m_{p+1} = (d+p)m_p$, identify the integer moments
as rising factorials $\prod_{i<k}(d+i)$, and derive mean $= d$ and variance $= d$.
Together these results supply the scaling and the moment characterization on which
the method-of-moments proof of the limit law rests. The boundary case $d = 1$
(the random recursive tree) is treated separately: $P_n(1) = n+1$ exactly, giving
linear descendant growth with exponent $1 = 1/d|_{d=1}$.

**Keywords:** random recursive DAG, descendant count, Gamma distribution, Gamma
function, method of moments, rising factorial, scaling limit, random recursive
tree.

## 1. Introduction

Growing random structures — networks in which vertices arrive sequentially and
attach to existing vertices according to a fixed rule — are a cornerstone of
modern applied probability. They model citation graphs, hyperlink structures,
biological lineages, package-dependency ecosystems, and the spread of information.
A recurring theme is *universality*: microscopically simple attachment rules
generate macroscopically robust limit laws that do not depend on incidental
details.

This paper concerns one such limit law. Consider the **random recursive
$d$-DAG** $G_n$ on vertex set $\{1, \dots, n\}$ with out-degree $d \ge 2$: each
vertex $v > d$ selects $d$ distinct earlier vertices uniformly at random and
directs an edge to each. Since edges always point toward smaller labels, the graph
is acyclic. Fixing a founding vertex, the **descendant set** $D_n$ consists of all
vertices whose ancestry traces back to the founder, and $|D_n|$ is its cardinality.

The governing result (Janson, 2023) states that
$$\frac{|D_n|}{n^{1/d}} \xrightarrow{\;d\;} \mathrm{Gamma}(d, 1), \qquad n \to \infty,$$
where $\mathrm{Gamma}(d,1)$ is the Gamma distribution with shape $d$ and rate $1$.
Two ingredients underlie any proof of such a statement: the correct *normalizing
sequence* (here $n^{1/d}$), and a *characterization of the limit* strong enough to
identify it uniquely (here, its moments). This paper establishes both ingredients
rigorously and self-containedly.

The paper is organized as follows. Section 2 fixes definitions. Section 3 analyzes
the mean-growth product and proves the scaling exponent is exactly $1/d$. Section
4 develops the Gamma$(d,1)$ target distribution and its complete moment structure.
Section 5 treats the boundary case $d = 1$. Section 6 discusses how the pieces
combine via the method of moments. Section 7 gives applications and future
directions.

## 2. Definitions and preliminaries

Throughout, $\Gamma$ denotes the Euler Gamma function,
$$\Gamma(s) = \int_0^\infty e^{-x}\, x^{s-1}\, dx \qquad (s > 0),$$
which satisfies the functional equation $\Gamma(s+1) = s\,\Gamma(s)$ and
interpolates the factorial: $\Gamma(m+1) = m!$ for $m \in \mathbb{N}$. We write
$x^a = \exp(a \ln x)$ for the real power ($x > 0$, $a \in \mathbb{R}$).

**Definition 2.1 (Mean-growth product).** For $a \in \mathbb{R}$ and $n \in
\mathbb{N}$,
$$P_n(a) = \prod_{k=1}^{n}\left(1 + \frac{a}{k}\right),$$
with the empty-product convention $P_0(a) = 1$.

The relevance of $P_n(a)$ is that with $a = 1/d$ it captures the expected size of
the descendant set in $G_n$: each new vertex contributes a multiplicative factor
$1 + a/k$ to the running expectation, reflecting the probability that it attaches,
through one of its $d$ uniform parents, to the founder's current descendant set.

**Definition 2.2 (Gamma$(d,1)$ density).** For shape $d > 0$, the Gamma$(d,1)$
probability density on $(0,\infty)$ is
$$f_d(x) = \frac{e^{-x}\, x^{\,d-1}}{\Gamma(d)}.$$

**Definition 2.3 (Gamma moment).** For $d > 0$ and $p \ge 0$, the $p$-th moment of
the Gamma$(d,1)$ law is
$$m_d(p) = \frac{\Gamma(d+p)}{\Gamma(d)}.$$

We will show (Theorem 4.2) that $m_d(p)$ is indeed $\int_0^\infty x^p f_d(x)\,dx$,
justifying the name.

## 3. The mean-growth product and the scaling exponent

We first record the recursive structure of the product.

**Lemma 3.1 (Recurrence).** For all $a \in \mathbb{R}$ and $n \in \mathbb{N}$,
$$P_{n+1}(a) = P_n(a)\cdot\left(1 + \frac{a}{n+1}\right).$$

*Proof.* Immediate by peeling off the top factor $k = n+1$ from the product over
$k \in \{1,\dots,n+1\}$. $\qquad\blacksquare$

**Theorem 3.2 (Exact closed form).** For $a \ge 0$ and $n \in \mathbb{N}$,
$$P_n(a) = \frac{\Gamma(n+1+a)}{\Gamma(1+a)\, n!}.$$

*Proof.* Induct on $n$. For $n = 0$ both sides equal $1$, since $\Gamma(1+a)/
(\Gamma(1+a)\cdot 0!) = 1$. Assume the identity for $n$. By Lemma 3.1,
$$P_{n+1}(a) = \frac{\Gamma(n+1+a)}{\Gamma(1+a)\,n!}\cdot\frac{n+1+a}{n+1}.$$
Using the functional equation in the form $\Gamma(n+2+a) = (n+1+a)\,\Gamma(n+1+a)$
and $(n+1)! = (n+1)\,n!$, the right-hand side becomes $\Gamma(n+2+a)/
(\Gamma(1+a)\,(n+1)!)$, completing the induction. $\qquad\blacksquare$

The closed form links $P_n$ to the classical Gamma approximating sequence. Recall
that Euler's limit representation of the Gamma function proceeds through
$$\gamma_a(n) = \frac{n^a\, n!}{\prod_{j=0}^{n}(a+j)}, \qquad \gamma_a(n) \to \Gamma(a),$$
a sequence which converges to $\Gamma(a)$ as $n \to \infty$ for $a > 0$.

**Lemma 3.3 (Link to the Gamma sequence).** For $a > 0$ and $n \ge 1$,
$$P_n(a) = \frac{n^a}{a\,\gamma_a(n)}.$$

*Proof.* Writing each factor as $1 + a/k = (a+k)/k$ gives
$P_n(a) = \left(\prod_{k=1}^n (a+k)\right)/n!$. Since $\prod_{j=0}^{n}(a+j) =
a\prod_{k=1}^{n}(a+k)$, we have $\prod_{k=1}^n (a+k) = \tfrac1a\prod_{j=0}^n(a+j)
= \tfrac1a\cdot n^a n!/\gamma_a(n)$. Dividing by $n!$ yields the claim.
$\qquad\blacksquare$

**Theorem 3.4 (Scaling limit).** For $a > 0$,
$$\frac{P_n(a)}{n^{a}} \longrightarrow \frac{1}{\Gamma(1+a)} \qquad (n \to \infty).$$

*Proof.* By Lemma 3.3, for $n \ge 1$,
$$\frac{P_n(a)}{n^a} = \frac{1}{a\,\gamma_a(n)}.$$
As $n \to \infty$, $\gamma_a(n) \to \Gamma(a)$, so the right-hand side tends to
$1/(a\,\Gamma(a))$. The functional equation gives $a\,\Gamma(a) = \Gamma(a+1) =
\Gamma(1+a)$, whence the limit is $1/\Gamma(1+a)$. $\qquad\blacksquare$

**Corollary 3.5 ($d$-DAG normalization).** For out-degree $d \ge 1$, setting $a =
1/d$,
$$\frac{P_n(1/d)}{n^{1/d}} \longrightarrow \frac{1}{\Gamma(1 + 1/d)}.$$

*Proof.* Apply Theorem 3.4 with $a = 1/d > 0$. $\qquad\blacksquare$

Corollary 3.5 identifies the normalization exponent as exactly $1/d$ and the
multiplicative constant as $1/\Gamma(1 + 1/d)$. This is precisely the sequence
$n^{1/d}$ appearing in the descendant limit law, and it explains why descendant
growth is *sublinear* for $d \ge 2$: the larger the out-degree, the smaller the
exponent, and the more diluted any single lineage becomes.

## 4. The Gamma target distribution and its moments

We now turn to the limit distribution itself.

**Theorem 4.1 (Normalization).** For $d > 0$, the density $f_d$ integrates to one:
$$\int_0^\infty f_d(x)\,dx = 1.$$

*Proof.* By definition $\int_0^\infty f_d(x)\,dx = \frac{1}{\Gamma(d)}\int_0^\infty
x^{d-1}e^{-x}\,dx$. The remaining integral is exactly $\Gamma(d)$ by the integral
definition of the Gamma function, so the value is $\Gamma(d)/\Gamma(d) = 1$. (Here
$f_d \ge 0$ on $(0,\infty)$ because each factor $e^{-x}$, $x^{d-1}$, and
$1/\Gamma(d)$ is nonnegative for $d > 0$.) $\qquad\blacksquare$

**Theorem 4.2 (Moment formula).** For $d > 0$ and $p \ge 0$,
$$\int_0^\infty x^p\, f_d(x)\,dx = \frac{\Gamma(d+p)}{\Gamma(d)} = m_d(p).$$

*Proof.* Compute
$$\int_0^\infty x^p\,\frac{e^{-x}x^{d-1}}{\Gamma(d)}\,dx
= \frac{1}{\Gamma(d)}\int_0^\infty e^{-x}\, x^{\,(d+p)-1}\,dx
= \frac{\Gamma(d+p)}{\Gamma(d)},$$
where the middle integral is $\Gamma(d+p)$ by the integral definition (valid since
$d + p > 0$), after combining $x^p \cdot x^{d-1} = x^{(d+p)-1}$.
$\qquad\blacksquare$

**Corollary 4.3 (Zeroth moment).** $m_d(0) = 1$.

*Proof.* $m_d(0) = \Gamma(d)/\Gamma(d) = 1$. Consistent with Theorem 4.1.
$\qquad\blacksquare$

**Theorem 4.4 (Moment recurrence).** For $d > 0$ and $p \ge 0$,
$$m_d(p+1) = (d+p)\,m_d(p).$$

*Proof.* Using $\Gamma(d+p+1) = (d+p)\,\Gamma(d+p)$,
$$m_d(p+1) = \frac{\Gamma(d+p+1)}{\Gamma(d)} = (d+p)\,\frac{\Gamma(d+p)}{\Gamma(d)}
= (d+p)\,m_d(p). \qquad\blacksquare$$

This recurrence is the analytic heart of the method-of-moments proof: it is the
exact relation that the moments of any Gamma$(d,1)$ limit must satisfy, and it is
what the combinatorial recursion of the DAG reproduces on the discrete side.

**Theorem 4.5 (Integer moments are rising factorials).** For $d > 0$ and $k \in
\mathbb{N}$,
$$m_d(k) = \prod_{i=0}^{k-1}(d+i) = d\,(d+1)\cdots(d+k-1).$$

*Proof.* Induct on $k$. For $k = 0$ the empty product is $1 = m_d(0)$ by Corollary
4.3. Assuming $m_d(k) = \prod_{i<k}(d+i)$, Theorem 4.4 gives $m_d(k+1) =
(d+k)\,m_d(k) = (d+k)\prod_{i<k}(d+i) = \prod_{i<k+1}(d+i)$. $\qquad\blacksquare$

**Corollary 4.6 (Mean, second moment, variance).** For $d > 0$:
$$m_d(1) = d, \qquad m_d(2) = d(d+1), \qquad m_d(2) - m_d(1)^2 = d.$$

*Proof.* From Theorem 4.5, $m_d(1) = d$ and $m_d(2) = d(d+1)$. Hence the variance
is $d(d+1) - d^2 = d$. $\qquad\blacksquare$

Thus the Gamma$(d,1)$ law has mean and variance both equal to the shape parameter
$d$ — a compact signature that also pins down the first two moments of the
descendant count $|D_n|/n^{1/d}$ in the limit.

## 5. The boundary case: random recursive trees ($d = 1$)

When $d = 1$, every vertex has a single parent and $G_n$ becomes a tree — the
classical random recursive tree. The mean-growth product is taken with $a = 1$.

**Theorem 5.1 (Exact tree product).** For all $n \in \mathbb{N}$,
$$P_n(1) = \prod_{k=1}^{n}\left(1 + \frac1k\right) = n+1.$$

*Proof.* Induct on $n$; the base case $P_0(1) = 1$ holds. For the step, Lemma 3.1
gives $P_{n+1}(1) = (n+1)\bigl(1 + \tfrac{1}{n+1}\bigr) = (n+1) + 1 = n+2$.
Equivalently, the product telescopes: $\prod_{k=1}^n \tfrac{k+1}{k} = \tfrac{n+1}{1}$.
$\qquad\blacksquare$

**Theorem 5.2 (Linear scaling).** $P_n(1)/n \to 1$ as $n \to \infty$.

*Proof.* By Theorem 5.1, $P_n(1)/n = (n+1)/n = 1 + 1/n \to 1$. $\qquad\blacksquare$

The scaling exponent is thus $1$, which is exactly the value $1/d$ takes at $d =
1$. Notably, this is also consistent with Corollary 3.5: at $a = 1$ we would get
$P_n(1)/n \to 1/\Gamma(2) = 1$, matching Theorem 5.2. The boundary case therefore
fits the general framework seamlessly, even though the qualitative behavior
(linear growth, rather than the sublinear $n^{1/d}$ of $d \ge 2$) is distinct.

## 6. Assembling the limit law via the method of moments

The two developments above are the analytic pillars of the descendant limit
theorem. We sketch how they combine.

1. **Scaling.** Corollary 3.5 fixes the normalization: $\mathbb{E}|D_n|$ is
   asymptotically proportional to $P_n(1/d) \sim n^{1/d}/\Gamma(1+1/d)$, so
   dividing $|D_n|$ by $n^{1/d}$ produces a quantity of order one. Any nontrivial
   limit must live on this scale.

2. **Moment convergence.** One shows that for each fixed $k \in \mathbb{N}$,
   $$\mathbb{E}\!\left[\left(\frac{|D_n|}{n^{1/d}}\right)^{k}\right]
   \longrightarrow \prod_{i=0}^{k-1}(d+i) = \frac{\Gamma(d+k)}{\Gamma(d)}.$$
   The right-hand side is the integer moment of Gamma$(d,1)$ from Theorem 4.5. The
   recurrence of Theorem 4.4 is exactly the relation the discrete factorial moments
   of $|D_n|$ satisfy asymptotically, which is why the rising-factorial pattern
   emerges.

3. **Moment determinacy.** The Gamma distribution is *determined by its moments*:
   its moment sequence $\Gamma(d+k)/\Gamma(d)$ does not grow so fast as to admit a
   second distribution with the same moments (Carleman's condition holds; more
   simply, the moment generating function is finite in a neighborhood of the
   origin). Hence convergence of all moments upgrades to convergence in
   distribution, yielding
   $$\frac{|D_n|}{n^{1/d}} \xrightarrow{\;d\;} \mathrm{Gamma}(d,1).$$

Steps 1 and the moment computation of step 2's target — the entire analytic
scaffolding on the limit side — are what we have established. What remains to fully
close the loop is the combinatorial estimate of the *discrete* moments of $|D_n|$
and a formal moment-determinacy criterion; these are outlined as future work.

## 7. Applications, discussion, and future work

**Applications.** The random recursive $d$-DAG is a natural model wherever new
entities attach to a fixed number of predecessors: citation networks (a paper
cites $d$ references), software dependency graphs (a module imports $d$ libraries),
and phylogenetic or genealogical branching. In each setting, $|D_n|$ measures the
*downstream influence* of an early entity. The result says this influence grows
like $n^{1/d}$ with Gamma-distributed fluctuations, so the out-degree $d$ alone
controls both the growth rate ($1/d$) and the shape of the fluctuation law
(shape $d$).

**Discussion.** Two features are worth emphasizing. First, the appearance of
$n^{1/d}$ — genuinely sublinear for $d \ge 2$ — quantifies how requiring more
parents *dilutes* the reach of any single founder. Second, the coincidence that
both the scaling exponent's reciprocal and the Gamma shape equal $d$ reflects a
single underlying structural constant; it is the out-degree that is written twice
into the answer.

**Future work.**

1. *The random model.* Define $G_n$ as a probability measure, define $D_n$, and
   prove that $\mathbb{E}|D_n|$ solves the recurrence whose solution is $P_n(1/d)$
   up to constants, connecting the product analyzed here to the actual expectation.

2. *Method of moments.* Prove $\mathbb{E}[(|D_n|/n^{1/d})^k] \to \Gamma(d+k)/
   \Gamma(d)$ for all $k$ and invoke a moment-determinacy criterion. The limit-side
   moments are fully in hand here.

3. *Moment determinacy.* Formalize Carleman's condition (or the simpler
   analytic-MGF criterion, which Gamma satisfies); such a "moments determine a law"
   theorem is reusable well beyond this problem.

4. *Random recursive trees ($d=1$).* With $P_n(1) = n+1$ and linear scaling now
   established, the remaining step is the limit law for the fluctuations.

5. *Sharper asymptotics.* Establish the second-order expansion $P_n(a) =
   \frac{n^a}{\Gamma(1+a)}\bigl(1 + O(1/n)\bigr)$.

## References

- S. Janson, *Random recursive trees and preferential attachment trees are random
  split trees* and related work on descendant distributions in random recursive
  DAGs (2023).
- M. Drmota, *Random Trees: An Interplay between Combinatorics and Probability*,
  Springer, 2009.
- E. Artin, *The Gamma Function*, Holt, Rinehart and Winston, 1964.
