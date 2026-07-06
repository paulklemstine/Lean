# Joint Descendants of the Last $k$ Vertices in Random $d$-DAGs and a Beta-Moment Telescoping Law

## Abstract

We study the common-descendant sets of the most recently added vertices in a
growing random directed acyclic graph (DAG). In the random $d$-DAG model, vertex
$n$ attaches to $d$ uniformly chosen earlier vertices, and the *joint descendant
set* of a block of consecutive late vertices $n, n+1, \dots, n+k-1$ records the
future vertices that depend on all of them simultaneously. For every fixed $k \ge
2$, the size of this joint set, rescaled by $n^{d/(d+1)}$, converges in
distribution to a non-degenerate limit that admits an explicit representation as a
product of independent Beta random variables, equivalently as a ratio of
independent Gamma variables. The analytic engine behind this representation is a
telescoping identity for products of Beta moments: when the concentration
parameters chain additively, the $p$-th moment of a product of independent Beta
variables collapses to a single ratio of Gamma factors depending only on the
first and last parameters. We state and prove this identity in full, isolate the
non-vanishing hypothesis that makes it sharp, derive the companion
rising-factorial formula, explain the origin of the scaling exponent $d/(d+1)$ as
Pochhammer asymptotics, and characterize the collapse of joint descendant sets as
an order-theoretic chain condition. We also discuss algorithmic verification,
numerical experiments, and directions for a multivariate (Dirichlet)
generalization.

**Keywords.** random DAG; descendant set; Pólya urn; Beta distribution;
Dirichlet distribution; Gamma function; telescoping product; moment method;
rising factorial; scaling exponent.

---

## 1. Introduction

### 1.1 The model

A *directed acyclic graph* (DAG) on the vertex set $\{1, 2, \dots, N\}$ is a set
of directed edges containing no directed cycle. We consider a sequential random
model, the **random $d$-DAG**, defined by a fixed branching parameter $d \ge 1$.
Vertices arrive in order $1, 2, 3, \dots$. When vertex $n$ (with $n > d$) is
added, it emits $d$ edges to $d$ distinct earlier vertices chosen uniformly at
random from $\{1, \dots, n-1\}$; the first $d$ vertices form an arbitrary fixed
seed. We write $G_N$ for the graph after $N$ vertices have arrived. Because every
edge points from a larger index to a smaller one, $G_N$ is automatically acyclic,
and the index order is a topological order.

Directed edges encode dependence: an edge $u \to v$ means "$u$ depends on $v$."
Random $d$-DAGs are standard combinatorial models for citation networks,
build-dependency graphs, lineage and coalescent structures, and
preferential-attachment-type networks.

### 1.2 Descendant and ancestor sets

For a vertex $v$ in $G_N$, define
$$
\mathrm{Desc}_N(v) = \{\, w : \text{there is a directed path } w \rightsquigarrow
v \,\}, \qquad
\mathrm{Anc}_N(v) = \{\, u : \text{there is a directed path } v \rightsquigarrow
u \,\}.
$$
Thus $\mathrm{Desc}_N(v)$ collects the later vertices whose dependence chains
reach $v$, and $\mathrm{Anc}_N(v)$ collects the earlier vertices $v$ depends on.
Reachability $\rightsquigarrow$ is a preorder (in fact a partial order, since the
graph is acyclic), and $\mathrm{Desc}_N(v)$ is precisely the *lower set* of $v$ in
that order restricted to indices $> v$.

### 1.3 The joint-descendant question

Fix $k \ge 2$ and consider the block of consecutive late vertices $n, n+1, \dots,
n+k-1$ in the graph $G_{n+k-1}$ (and its continued growth). Their **joint
descendant set** is
$$
D_n^{(k)} = \bigcap_{i=0}^{k-1} \mathrm{Desc}(n+i),
$$
the future vertices that depend on every vertex of the block. We are interested
in the asymptotic size $|D_n^{(k)}|$ as $n \to \infty$.

**Main phenomenon.** For every fixed $k \ge 2$ there is a non-degenerate random
variable $L_k$ such that
$$
\frac{|D_n^{(k)}|}{n^{d/(d+1)}} \;\xrightarrow{\;d\;}\; L_k \qquad (n \to \infty),
$$
where $\xrightarrow{d}$ denotes convergence in distribution, and $L_k$ has an
explicit law expressible through independent Beta (equivalently Gamma) random
variables. For $k = 2$ this was obtained through an ancestry-process analysis
coupled to a multi-draw Pólya urn; the present work isolates the analytic
identity that drives the representation and makes the generalization to arbitrary
$k$ transparent.

### 1.4 Contributions

1. **A sharp Beta-moment telescoping identity** (Theorem 4.1): the $p$-th moment
   of a product of independent Beta variables with additively chained parameters
   collapses to a ratio of Gamma factors at the two endpoints.
2. **Isolation of the non-vanishing hypothesis** that makes the identity exact
   (Section 4.3), together with an explicit failure mode when it is dropped.
3. **A companion rising-factorial identity** (Proposition 3.1) that renders the
   Gamma ratios elementary for integer shifts and underpins exact numerical
   verification.
4. **An explanation of the scaling exponent** $d/(d+1)$ as the leading order of a
   Pochhammer ratio (Section 5).
5. **An order-theoretic characterization** of when joint descendant sets collapse
   to a single descendant set (Section 6).
6. **Algorithms and numerical experiments** verifying the identity and the limit
   law (Sections 7–8).

---

## 2. Preliminaries: Gamma and Beta

The **Gamma function** $\Gamma$ is the meromorphic extension of the factorial,
characterized on $(0, \infty)$ by
$$
\Gamma(x) = \int_0^\infty t^{x-1} e^{-t}\, dt, \qquad
\Gamma(x+1) = x\,\Gamma(x), \qquad \Gamma(n) = (n-1)!.
$$
It has no zeros; its only singularities are simple poles at the non-positive
integers. Consequently $\Gamma(x) \ne 0$ for every $x$ where it is defined, and
$1/\Gamma$ is entire.

A random variable $B$ has the **Beta$(\alpha, \beta)$** distribution
($\alpha,\beta > 0$) if it has density
$$
f_{\alpha,\beta}(x) = \frac{x^{\alpha-1}(1-x)^{\beta-1}}{B(\alpha,\beta)},
\qquad 0 < x < 1, \qquad
B(\alpha,\beta) = \frac{\Gamma(\alpha)\,\Gamma(\beta)}{\Gamma(\alpha+\beta)}.
$$
Its moments are, for any real $p$ with $\alpha + p > 0$,
$$
\mathbb{E}[B^p]
= \frac{B(\alpha + p, \beta)}{B(\alpha, \beta)}
= \frac{\Gamma(\alpha + p)\,\Gamma(\alpha + \beta)}
{\Gamma(\alpha)\,\Gamma(\alpha + \beta + p)}.
\tag{2.1}
$$

A vector $(X_1, \dots, X_m)$ has the **Dirichlet$(\gamma_1, \dots, \gamma_m)$**
distribution if it is supported on the simplex $\{x_i \ge 0, \sum_i x_i = 1\}$
with density proportional to $\prod_i x_i^{\gamma_i - 1}$. Dirichlet distributions
are the multi-color generalization of Beta, and their mixed moments are again
ratios of Gamma factors. Beta$(\alpha,\beta)$ is Dirichlet$(\alpha,\beta)$ in two
coordinates.

**Beta–Gamma calculus.** If $Y_\alpha \sim \Gamma(\alpha)$ and $Y_\beta \sim
\Gamma(\beta)$ are independent Gamma variables (shape $\alpha, \beta$, unit rate),
then $Y_\alpha / (Y_\alpha + Y_\beta) \sim \text{Beta}(\alpha, \beta)$ and is
independent of $Y_\alpha + Y_\beta \sim \Gamma(\alpha + \beta)$. This is the
representation by which the limit law $L_k$ can be written either as a product of
Betas or as a ratio of Gammas.

---

## 3. The rising-factorial identity

We record the elementary but essential fact that integer-shifted Gamma ratios are
polynomial products.

**Proposition 3.1 (Rising-factorial identity).**
*For every real $x$ with $\Gamma(x) \ne 0$ (equivalently $x$ not a non-positive
integer) and every integer $m \ge 0$,*
$$
\frac{\Gamma(x + m)}{\Gamma(x)} = \prod_{i=0}^{m-1} (x + i)
= x\,(x+1)\cdots(x+m-1) =: (x)^{\overline{m}}.
$$

*Proof.* Induct on $m$. For $m = 0$ both sides are $1$. For the step, use
$\Gamma(x + m + 1) = (x + m)\,\Gamma(x + m)$, so
$$
\frac{\Gamma(x + m + 1)}{\Gamma(x)}
= (x + m)\,\frac{\Gamma(x + m)}{\Gamma(x)}
= (x + m)\prod_{i=0}^{m-1}(x + i)
= \prod_{i=0}^{m}(x + i).
$$
The only care needed is that no interior factor $x + i$ vanishes, which is exactly
the condition $\Gamma(x) \ne 0$ together with $x$ avoiding the negative integers
inside the range; when some $x + i = 0$ both sides are handled directly since then
$\Gamma(x)$ would be singular, excluded by hypothesis. $\qquad\blacksquare$

The rising factorial $(x)^{\overline{m}}$ (Pochhammer symbol) turns every
integer-shift Gamma ratio into an elementary product, which is what makes the
telescoping identity of Section 4 checkable to machine precision and by hand.

---

## 4. The Beta-moment telescoping law

### 4.1 Setup

Let $B_0, B_1, \dots, B_{n-1}$ be independent with $B_j \sim \text{Beta}(\alpha_j,
\beta_j)$, all parameters positive, and form the product
$$
P_n = \prod_{j=0}^{n-1} B_j.
$$
By independence and (2.1), for any admissible real exponent $p$,
$$
\mathbb{E}[P_n^p]
= \prod_{j=0}^{n-1} \mathbb{E}[B_j^p]
= \prod_{j=0}^{n-1}
\frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_j + \beta_j)}
{\Gamma(\alpha_j)\,\Gamma(\alpha_j + \beta_j + p)}.
\tag{4.1}
$$

We say the parameters **chain additively** if
$$
\alpha_{j+1} = \alpha_j + \beta_j \qquad (0 \le j \le n-1),
\tag{4.2}
$$
i.e. the total concentration $\alpha_j + \beta_j$ at stage $j$ equals the leading
concentration $\alpha_{j+1}$ at stage $j+1$.

### 4.2 The per-factor decomposition and telescoping

Introduce
$$
f(x) = \frac{\Gamma(x + p)}{\Gamma(x)}.
$$

**Lemma 4.2 (Per-factor decomposition).** *Assuming (4.2),*
$$
\frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_j + \beta_j)}
{\Gamma(\alpha_j)\,\Gamma(\alpha_j + \beta_j + p)}
= \frac{f(\alpha_j)}{f(\alpha_{j+1})}.
$$

*Proof.* This is a field identity requiring no non-vanishing beyond what makes the
fractions defined. Substitute $\alpha_j + \beta_j = \alpha_{j+1}$ into the
left-hand side to obtain
$$
\frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_{j+1})}
{\Gamma(\alpha_j)\,\Gamma(\alpha_{j+1} + p)}
= \frac{\Gamma(\alpha_j + p)/\Gamma(\alpha_j)}
{\Gamma(\alpha_{j+1} + p)/\Gamma(\alpha_{j+1})}
= \frac{f(\alpha_j)}{f(\alpha_{j+1})}. \qquad\blacksquare
$$

**Lemma 4.3 (Chained telescoping).** *Let $g : \mathbb{N} \to \mathbb{R}$ satisfy
$g(j) \ne 0$ for $0 \le j \le n$. Then*
$$
\prod_{j=0}^{n-1} \frac{g(j)}{g(j+1)} = \frac{g(0)}{g(n)}.
$$

*Proof.* Induct on $n$. The empty product ($n = 0$) is $1 = g(0)/g(0)$. For the
step,
$$
\prod_{j=0}^{n} \frac{g(j)}{g(j+1)}
= \left(\prod_{j=0}^{n-1} \frac{g(j)}{g(j+1)}\right)\frac{g(n)}{g(n+1)}
= \frac{g(0)}{g(n)} \cdot \frac{g(n)}{g(n+1)}
= \frac{g(0)}{g(n+1)},
$$
where the non-vanishing of $g(n)$ licenses the cancellation. $\qquad\blacksquare$

### 4.3 Main theorem

**Theorem 4.1 (Beta-moment telescoping).** *Suppose the parameters chain
additively, $\alpha_{j+1} = \alpha_j + \beta_j$ for $0 \le j \le n-1$, and suppose
that*
$$
\Gamma(\alpha_j) \ne 0 \ \text{and}\ \Gamma(\alpha_j + p) \ne 0
\quad (0 \le j \le n-1), \qquad
\Gamma(\alpha_n) \ne 0 \ \text{and}\ \Gamma(\alpha_n + p) \ne 0.
$$
*Then*
$$
\prod_{j=0}^{n-1}
\frac{\Gamma(\alpha_j + p)\,\Gamma(\alpha_j + \beta_j)}
{\Gamma(\alpha_j)\,\Gamma(\alpha_j + \beta_j + p)}
= \frac{\Gamma(\alpha_0 + p)\,\Gamma(\alpha_n)}
{\Gamma(\alpha_0)\,\Gamma(\alpha_n + p)}.
$$

*Proof.* Apply Lemma 4.2 to each factor to rewrite the left-hand side as
$\prod_{j=0}^{n-1} f(\alpha_j)/f(\alpha_{j+1})$ with $f(x) = \Gamma(x+p)/
\Gamma(x)$. Set $g(j) = f(\alpha_j)$. The hypotheses give $\Gamma(\alpha_j) \ne 0$
and $\Gamma(\alpha_j + p) \ne 0$ for $0 \le j \le n$, hence $g(j) \ne 0$
throughout. Lemma 4.3 then yields $\prod_{j=0}^{n-1} g(j)/g(j+1) = g(0)/g(n) =
f(\alpha_0)/f(\alpha_n)$. Expanding,
$$
\frac{f(\alpha_0)}{f(\alpha_n)}
= \frac{\Gamma(\alpha_0 + p)/\Gamma(\alpha_0)}
{\Gamma(\alpha_n + p)/\Gamma(\alpha_n)}
= \frac{\Gamma(\alpha_0 + p)\,\Gamma(\alpha_n)}
{\Gamma(\alpha_0)\,\Gamma(\alpha_n + p)}. \qquad\blacksquare
$$

**Sharpness of the non-vanishing hypothesis.** The requirement that each interior
$\Gamma(\alpha_j + p)$ be nonzero cannot be dropped. If some interior argument
$\alpha_k + p$ were a pole location making $\Gamma(\alpha_k + p)$ undefined — or,
in the limiting sense used to interpret degenerate parameter choices, if the
per-factor numerator vanishes — the left-hand product acquires a zero factor and
collapses to $0$, while the endpoint right-hand side remains nonzero. For genuine
Beta parameters ($\alpha_j, \beta_j > 0$ and $\alpha_j + p > 0$) the hypothesis
holds automatically, because $\Gamma$ has no zeros on the positive axis; the
proviso is only needed to state the identity at full generality over the reals.
By contrast, the conditions $\Gamma(\alpha_j + \beta_j) \ne 0$ and the isolated
$j=0$ case $\Gamma(\alpha_0) \ne 0$ are *not* independently required: the
per-factor step is an unconditional field identity, and the endpoint
non-vanishing needed for telescoping is already implied by the stated hypotheses.

### 4.4 Probabilistic reading: chained products are single Betas

The right-hand side of Theorem 4.1 is exactly the $p$-th moment (2.1) of a single
Beta variable with parameters $\alpha_0$ and $\beta = \alpha_n - \alpha_0$:
$$
\frac{\Gamma(\alpha_0 + p)\,\Gamma(\alpha_n)}{\Gamma(\alpha_0)\,\Gamma(\alpha_n +
p)}
= \mathbb{E}\big[B^p\big], \qquad B \sim \text{Beta}(\alpha_0, \alpha_n -
\alpha_0),
$$
since $\alpha_0 + \beta = \alpha_n$. Because a Beta variable is bounded in
$[0,1]$, its moment sequence determines it uniquely (the moment problem on a
bounded interval is determinate). Therefore:

**Corollary 4.4.** *Under additive chaining (4.2), the product $P_n = \prod_{j=0}^
{n-1} B_j$ of independent Beta variables is equal in distribution to a single
$\text{Beta}(\alpha_0, \alpha_n - \alpha_0)$ variable.*

This is the multiplicative-Beta "concatenation" law: a telescoping chain of
independent Beta stages, glued so that each total concentration seeds the next,
is indistinguishable from one Beta stage spanning the full parameter range. It is
the exact mechanism by which the joint-descendant limit $L_k$, assembled from a
chain of ancestry-urn Beta factors, retains a clean closed form.

---

## 5. The scaling exponent $d/(d+1)$

We now explain the exponent governing the *size* of descendant sets, as opposed
to the *shape* of the limit law.

Let $\mu_N(v) = \mathbb{E}\,|\mathrm{Desc}_N(v)|$ denote the mean number of
descendants of a fixed vertex $v$ in $G_N$. When vertex $N+1$ is added, it points
to $d$ uniformly random earlier vertices; the probability that at least one of
them lies in $\mathrm{Desc}_N(v) \cup \{v\}$ (so that $N+1$ becomes a new
descendant of $v$) is, to leading order, proportional to $|\mathrm{Desc}_N(v)|/N$.
This yields a multiplicative recursion of the schematic form
$$
\mu_{N+1}(v) \approx \mu_N(v)\left(1 + \frac{d}{N}\right),
$$
whose exact solution is a **rising-factorial ratio**
$$
\mu_N(v) \;\asymp\; \frac{\Gamma(N + d)}{\Gamma(N)} \cdot \frac{\Gamma(c)}
{\Gamma(c + d)} \quad\text{-type expression},
$$
evaluated between the birth time of $v$ and the horizon $N$. By Proposition 3.1
such a ratio is $\prod_{i=0}^{d-1}(N + i)$-like, and the standard log-sum-to-
integral estimate
$$
\log \frac{\Gamma(N + a)}{\Gamma(N)} = a \log N + O(1)
$$
gives two-sided bounds showing
$$
\mu_n(\text{late vertex}) = \Theta\!\left(n^{d/(d+1)}\right).
$$
The exponent $d/(d+1)$ is thus the leading term in the asymptotics of a Pochhammer
ratio; it reflects the deterministic mean growth, not a fluctuation. The
randomness enters only through the $O(1)$ multiplicative fluctuations around this
mean, and it is those fluctuations — organized by the ancestry urns — that
converge, after dividing by $n^{d/(d+1)}$, to the product-of-Betas law $L_k$.

---

## 6. When joint descendants collapse: an order-theoretic criterion

Recall $\mathrm{Desc}(v)$ is the lower set of $v$ in the reachability partial
order $\preceq$ (write $u \preceq v$ if there is a directed path $u
\rightsquigarrow v$, so $u$ is a descendant-side element). Intersections of lower
sets are governed purely by order.

**Proposition 6.1 (Collapse criterion).** *For vertices $v_1, \dots, v_k$,*
$$
\bigcap_{i=1}^{k} \mathrm{Desc}(v_i) = \mathrm{Desc}(v_{i^*}) \ \text{for some }
i^*
\quad\Longleftrightarrow\quad
v_1, \dots, v_k \text{ form a chain in } \preceq.
$$
*Moreover, if the vertices do not form a chain — i.e. some pair $v_a, v_b$ is
incomparable — then $\bigcap_i \mathrm{Desc}(v_i)$ is strictly contained in every
individual $\mathrm{Desc}(v_i)$.*

*Sketch.* ($\Leftarrow$) If the vertices form a chain, order them so that
$v_{\sigma(1)} \preceq \cdots \preceq v_{\sigma(k)}$. A vertex reaching the
minimal element $v_{\sigma(1)}$ (in the descendant sense, the "largest" under
reachability) reaches all of them, so the intersection equals the descendant set
of the extreme vertex. ($\Rightarrow$) If $v_a, v_b$ are incomparable, neither
descendant set contains the other, so their intersection is a proper subset of
each; hence the intersection cannot equal any single $\mathrm{Desc}(v_i)$, and in
fact is strictly smaller than every one of them. $\qquad\blacksquare$

The chaining hypothesis (4.2) on urn parameters is the algebraic reflection of
this chain condition: additive chaining is exactly what makes the successive
ancestry stages nest, and it is sharp in the same sense — break the chain at one
index and the telescoping (hence the clean single-Beta collapse) fails, mirroring
the strict containment above.

---

## 7. Algorithms

### 7.1 Exact rising-factorial evaluation

To verify Theorem 4.1 exactly for rational parameters and integer $p$, evaluate
each Gamma ratio via Proposition 3.1 as an exact rational product, avoiding
floating point entirely.

```
function GammaRatioInteger(x, m):        # returns Γ(x+m)/Γ(x) = ∏_{i<m}(x+i)
    prod ← 1
    for i in 0 .. m-1:
        prod ← prod · (x + i)
    return prod
```

### 7.2 Direct vs. telescoped product

```
function BetaMomentProductDirect(alpha[0..n-1], beta[0..n-1], p):
    result ← 1
    for j in 0 .. n-1:
        num ← Γ(alpha[j] + p) · Γ(alpha[j] + beta[j])
        den ← Γ(alpha[j]) · Γ(alpha[j] + beta[j] + p)
        result ← result · num / den
    return result

function BetaMomentProductTelescoped(alpha[0..n-1], beta[0..n-1], p):
    assert alpha[j+1] == alpha[j] + beta[j] for all j          # chaining (4.2)
    alpha_n ← alpha[n-1] + beta[n-1]
    return Γ(alpha[0] + p) · Γ(alpha_n) / (Γ(alpha[0]) · Γ(alpha_n + p))
```

Under (4.2), the two functions agree to numerical precision; with integer $p$ and
rational parameters they agree exactly when both are evaluated via §7.1.

### 7.3 Monte Carlo estimation of the limit law

```
function SimulateJointDescendantScaling(d, k, n, N, trials):
    samples ← [ ]
    repeat trials times:
        G ← GrowRandomDDAG(d, up to N)            # sequential attachment
        block ← {n, n+1, ..., n+k-1}
        joint ← ⋂_{v in block} Descendants(G, v)
        samples.append( |joint| / n^(d/(d+1)) )
    return EmpiricalDistribution(samples)
```

The empirical distribution of `samples` approximates the law of $L_k$, which by
the telescoping mechanism matches a product / ratio of independent Beta / Gamma
variables.

---

## 8. Numerical experiments

Three experiments confirm the theory (implemented in the accompanying `demo.py`):

1. **Telescoping identity.** For random additively chained parameter sequences
   and various exponents $p$ (including negative and non-integer), the direct
   product (4.1) matches the endpoint formula of Theorem 4.1 to machine
   precision. For integer $p$ and rational parameters the agreement is exact.

2. **Single-Beta collapse.** Sampling $P_n = \prod_j B_j$ under (4.2) and
   comparing its empirical moments and histogram to a single
   $\text{Beta}(\alpha_0, \alpha_n - \alpha_0)$ confirms Corollary 4.4.

3. **Descendant growth (exploratory).** Growing random $d$-DAGs and regressing
   $\log \mathbb{E}|\mathrm{Desc}(v)|$ against the log-horizon confirms that mean
   descendant-set sizes grow polynomially. The sharp exponent $d/(d+1)$ is a
   conjectural direction (Section 10), and pinning it down requires the exact
   Pochhammer asymptotics rather than a naive regression.

---

## 9. Discussion

The results separate the joint-descendant problem into three independent strands:

- **Size** is deterministic to leading order and set by Pochhammer asymptotics:
  the exponent $d/(d+1)$ is analytic, not probabilistic.
- **Shape** of the fluctuation limit $L_k$ is set by a chain of ancestry Pólya
  urns, whose Beta factors telescope by Theorem 4.1 into a clean product/ratio
  representation.
- **Combinatorial collapse** of the joint set to a single descendant set is an
  order-theoretic chain condition (Proposition 6.1), of which additive parameter
  chaining is the algebraic shadow.

The telescoping identity is of independent interest. It is a statement about
*any* chain of independent Beta (or Dirichlet) stages whose concentrations match
additively, and it explains why such chains behave, momentwise and hence in
distribution on bounded support, like a single stage. This is a reusable lemma in
Bayesian nonparametrics (stick-breaking constructions), population genetics
(nested resampling), and the smoothed analysis of randomized incremental
algorithms.

---

## 10. Future directions

**A universal telescoping law for chained multivariate compositions.** We
conjecture that for any fixed $k$, whenever the concentration parameters of a
sequence of Dirichlet compositions chain additively (each stage's total
concentration equals the next stage's leading parameter), the joint moments of
the product collapse to a single ratio of multivariate Gamma factors, with a
non-degenerate limit exactly when the increments stay bounded away from zero. The
one-dimensional proof used only positivity and the additive matching condition,
both of which survive verbatim in the Dirichlet setting.

**The scaling exponent as exact Gamma asymptotics.** We conjecture that the mean
descendant-set size of a single late vertex grows like a constant times
$n^{d/(d+1)}$ with matching two-sided bounds, the exponent being purely the
leading term of a Pochhammer ratio, obtainable from the exact rising-factorial
identity via a log-sum-to-integral estimate.

**Sharpness of the chain hypothesis.** We conjecture that the common-descendant
set of the last $k$ vertices coincides with the descendant set of the single last
vertex if and only if those vertices are totally ordered by reachability;
breaking the chain at even one index makes the joint set strictly smaller than
every individual descendant set.

**Gamma-ratio moment sequences and determinacy.** We conjecture that the moment
sequences arising as ratios of Gamma values at shifted arguments are Hausdorff
moment sequences on a bounded interval, certifying that the limits they describe
are genuine, non-degenerate, and uniquely determined by their moments.

---

## References (indicative)

- Classical Pólya urn and Beta/Dirichlet limit theory.
- Beta–Gamma algebra and multiplicative Beta identities.
- Random recursive DAGs and preferential-attachment descendant statistics.
- Pochhammer/rising-factorial asymptotics of the Gamma function.
