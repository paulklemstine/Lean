# The Comonotone Repair Distance and the Discordance Mass

### A sharp two-sided comparison between an $\ell^1$ isotonic defect and a pairwise contradiction functional, with applications to regime-uniform signal triage

**Author:** Aristotle
**Date:** 2026-09-10

---

## Abstract

Let $(x, y)$ be a finite population of paired real observations on a key set
$\iota$ with $|\iota| = n$, where $x$ is a *footprint* (an exposure, dose, or
ordering variable) and $y$ is a *rate* (the response of interest). The
population is *comonotone* when $(x_i - x_j)(y_i - y_j) \ge 0$ for all pairs,
and its failure to be comonotone is classically measured by the **discordance
mass**
$$\Delta(x,y) = \sum_{i}\sum_{j}\max\bigl(-(x_i - x_j)(y_i - y_j),\, 0\bigr),$$
a pairwise functional that appears, together with its concordant counterpart
$C(x,y)$, in the unnormalised Hoeffding decomposition of any weighted
covariance.

We introduce and study a geometrically different defect measure, the
**comonotone repair distance**
$$\delta(x,y) = \inf\bigl\{\|d\|_1 : (x,\, y + d)\ \text{is comonotone}\bigr\},$$
the $\ell^1$ distance from the rate vector to the isotonic cone induced by the
footprint. We prove that $\delta$ is well posed, faithful ($\delta = 0$ iff
comonotone), attained, positively homogeneous of degree one in the rates, and
$1$-Lipschitz with respect to the $\ell^1$ metric on rates — a robustness the
discordance mass provably lacks.

Our main result is a **sharp two-sided comparison**: if the distinct footprint
values are $g$-separated and the footprint range is at most $R$, then
$$2\,g\,\delta(x,y) \;\le\; \Delta(x,y) \;\le\; 2\,n\,R\,\delta(x,y),$$
where the left constant $2$ is exactly optimal (attained) and the linear factor
$n$ on the right is unavoidable and correct up to a factor of two. We refute the
naive dimension-free conjecture $\delta^2 \le \Delta \le 2\,\delta\,R$ in both
directions with explicit finite witnesses, identifying the obstruction on the
left as a *degree* obstruction (both functionals are homogeneous of degree one)
and on the right as a *dimension* obstruction (discordance aggregates over
$\Theta(n^2)$ pairs while a single coordinate move may repair all of them).

As an application, we derive a **regime-uniform triage rule** expressed in a
single interpretable population parameter: if the draw probabilities lie in
$[\varepsilon, M]$ with conditioning number $\kappa = M/\varepsilon$, then
$\kappa^2 \cdot 2 n R \delta < C(x,y)$ certifies that the weighted covariance is
strictly positive in *every* such regime, and a Lipschitz argument extends the
certificate to noisily measured rates. Dually, we prove that the repair distance
is a budget line inside the covariance itself:
$2 n^2 \operatorname{wcov} \le C(x,y) - g\,\delta$ under uniform draws.

Finally we prove an **irreducibility theorem**: $\Delta$ is not a function of
$\delta$. Two three-key populations with identical footprints and identical
repair distance $\delta = 1$ have discordance masses $6$ and $2$. Hence the
pairwise data cannot be compressed into any $\ell^1$ repair statistic, the
two-sided comparison cannot be sharpened to an identity, and the fine
combinatorial information genuinely lives in the pairs.

**Keywords:** comonotonicity, isotonic regression, $\ell^1$ projection,
discordance mass, Hoeffding pair identity, weighted covariance, sharp constants,
regime-uniform inference.

---

## 1. Introduction

### 1.1 Two ways to be far from monotone

A population of paired observations tells a *monotone story* when higher
footprint always accompanies higher rate. Formally, on a finite index set
$\iota$ with $n = |\iota|$ elements, and for $x, y : \iota \to \mathbb{R}$, we
say the pair $(i,j)$ is **concordant** when $(x_i - x_j)(y_i - y_j) > 0$,
**discordant** when it is negative, and **tied** when it vanishes. The
population $(x,y)$ is **comonotone** when no pair is discordant:
$$(x_i - x_j)(y_i - y_j) \ \ge\ 0 \qquad \text{for all } i, j \in \iota. \tag{1.1}$$

There are two natural but structurally distinct ways to quantify a failure of
(1.1).

The **combinatorial** way sums the violations. Write
$$D(a,b) \;=\; \max\bigl(-(x_a - x_b)(y_a - y_b),\, 0\bigr) \;\ge\; 0,$$
the *discordance matrix* of the population, which is symmetric
($D(a,b) = D(b,a)$) and vanishes on the diagonal, and set
$$\Delta(x,y) \;=\; \sum_{a \in \iota} \sum_{b \in \iota} D(a,b), \qquad
C(x,y) \;=\; \sum_{a}\sum_{b} \max\bigl((x_a - x_b)(y_a - y_b),\, 0\bigr).$$
These are the **discordance mass** and the **concordance mass**. Both are
nonnegative, both are homogeneous of degree one in $y$ (and in $x$), and
$\Delta(x,y) = 0$ characterises comonotonicity.

The **geometric** way asks for the cost of a fix. Perturb the rates by
$d : \iota \to \mathbb{R}$, paying $\|d\|_1 = \sum_i |d_i|$, and require the
perturbed population $(x, y+d)$ to be comonotone. This is the subject of the
present paper.

### 1.2 Why the comparison matters

The two functionals are not idle curiosities: $C$ and $\Delta$ jointly control
every weighted covariance of the population. Given draw probabilities
$p : \iota \to \mathbb{R}_{\ge 0}$ with $\sum_i p_i = 1$, the weighted
covariance ("the dial")
$$\operatorname{wcov}(p; x, y) \;=\; \sum_i p_i x_i y_i - \Bigl(\sum_i p_i x_i\Bigr)\Bigl(\sum_j p_j y_j\Bigr)$$
admits the classical pair (Hoeffding) representation
$$\operatorname{wcov}(p; x, y) \;=\; \tfrac{1}{2}\sum_i \sum_j p_i p_j\,(x_i - x_j)(y_i - y_j). \tag{1.2}$$
Splitting the summand into positive and negative parts immediately yields, for
$\varepsilon \le p_i \le M$,
$$\tfrac{1}{2}\bigl(\varepsilon^2 C(x,y) - M^2 \Delta(x,y)\bigr) \;\le\; \operatorname{wcov}(p; x, y), \tag{1.3}$$
so that $M^2 \Delta < \varepsilon^2 C$ certifies a positive dial *simultaneously
for every admissible regime*. This is the **triage rule**: a regime-free
sufficient condition for a positive association.

The trouble with the triage rule as stated is that $\Delta$ is a
$\Theta(n^2)$-term functional of the raw pairwise table, awkward to communicate,
and — as we prove in Section 6 — not stable under perturbation of the rates. The
programme of this paper is to replace $\Delta$ in the triage rule by a single
interpretable, stable, geometric parameter, and to determine exactly how much
information is lost in doing so.

### 1.3 Results

Section 2 defines the repair distance and establishes well-posedness,
faithfulness, attainment, homogeneity and Lipschitz stability. Section 3 proves
the upper bound $\Delta \le 2 n R \delta$. Section 4 proves the sharp
dimension-free lower bound $2 g \delta \le \Delta$ by a *disjoint double
charging* argument on the isotonic upper envelope. Section 5 refutes the naive
conjecture in both directions and establishes sharpness of every constant.
Section 6 develops the applications: the single-parameter triage rule, its
robust measured-data version, and the dual statement that the repair distance
caps the dial. Section 7 proves irreducibility. Section 8 discusses algorithms
and open directions.

---

## 2. The comonotone repair distance

Throughout, $\iota$ is a finite index set with $n = |\iota|$, and
$x, y : \iota \to \mathbb{R}$.

**Definition 2.1 (Repair set).** The **repair set** of the population $(x,y)$ is
$$\mathcal{R}(x,y) \;=\; \bigl\{\, d : \iota \to \mathbb{R} \;\bigm|\; (x,\, y + d)\ \text{is comonotone} \,\bigr\}
\;=\; \bigl\{\, d \;\bigm|\; \forall i,j,\ 0 \le (x_i - x_j)\bigl((y_i + d_i) - (y_j + d_j)\bigr) \,\bigr\}.$$

Equivalently, $\mathcal{R}(x,y) = K_x - y$, where
$K_x = \{ z : (x,z)\ \text{comonotone}\}$ is the **isotonic cone** of the
preorder induced by $x$ (a closed convex cone, being an intersection of $n^2$
closed half-spaces through the origin).

**Lemma 2.2 (Nonemptiness).** $d = x - y \in \mathcal{R}(x,y)$.

*Proof.* $(x_i - x_j)\bigl((y_i + x_i - y_i) - (y_j + x_j - y_j)\bigr) = (x_i - x_j)^2 \ge 0$. $\square$

**Definition 2.3 (Comonotone repair distance).**
$$\delta(x,y) \;=\; \inf\bigl\{\, \|d\|_1 \;:\; d \in \mathcal{R}(x,y) \,\bigr\}
\;=\; \operatorname{dist}_{\ell^1}\bigl(y,\, K_x\bigr).$$

By Lemma 2.2 the defining set is nonempty, and it is bounded below by $0$, so
$\delta(x,y)$ is a well-defined nonnegative real. We record the two elementary
directions of the infimum that we use repeatedly.

**Lemma 2.4.** (i) $\delta(x,y) \le \|d\|_1$ for every $d \in \mathcal{R}(x,y)$.
(ii) If $c \le \|d\|_1$ for every $d \in \mathcal{R}(x,y)$, then
$c \le \delta(x,y)$.

### 2.1 Certificates and faithfulness

**Lemma 2.5 (Pair certificate).** If $x_i < x_j$, then
$y_i - y_j \le \delta(x,y)$.

*Proof.* Let $d \in \mathcal{R}(x,y)$. Comonotonicity at the pair $(i,j)$ with
$x_i - x_j < 0$ forces $(y_i + d_i) - (y_j + d_j) \le 0$, i.e.
$y_i - y_j \le d_j - d_i$. Since $d_j - d_i \le |d_i| + |d_j| \le \|d\|_1$
(the two coordinates being distinct, as $x_i \ne x_j$), the bound holds for
every repair, and Lemma 2.4(ii) applies. $\square$

Thus every inverted pair is a lower-bound certificate for the repair cost, and
the size of the inversion is exactly the amount of the certificate. This is the
workhorse for computing $\delta$ on the witness populations below.

**Theorem 2.6 (Faithfulness).** $\delta(x,y) = 0$ if and only if $(x,y)$ is
comonotone.

*Proof.* If $(x,y)$ is comonotone then $d \equiv 0$ is a repair of cost $0$.
Conversely, suppose some pair $(i,j)$ has $(x_i - x_j)(y_i - y_j) < 0$. If
$x_i < x_j$ then $y_j < y_i$, so Lemma 2.5 gives
$0 < y_i - y_j \le \delta(x,y)$; if $x_j < x_i$ the symmetric argument applies;
and $x_i = x_j$ is impossible since the product would vanish. $\square$

### 2.2 Attainment, homogeneity, stability

**Theorem 2.7 (Attainment).** There exists $d^\star \in \mathcal{R}(x,y)$ with
$\|d^\star\|_1 = \delta(x,y)$.

*Proof sketch.* $\mathcal{R}(x,y)$ is closed, being the intersection over all
pairs $(i,j)$ of the closed sets
$\{d : 0 \le (x_i - x_j)((y_i + d_i) - (y_j + d_j))\}$; the map
$d \mapsto \|d\|_1$ is continuous and coercive, since $|d_i| \le \|d\|_1$ for
each $i$. Setting $B = \|x - y\|_1$, Lemma 2.2 shows the infimum is unchanged
when restricted to the intersection of $\mathcal{R}(x,y)$ with the compact ball
$\{d : \|d\|_\infty \le B\}$, which is nonempty and compact; a continuous
function attains its minimum there. $\square$

Consequently $\delta$ is a genuine distance from $y$ to the isotonic cone, not
merely an approach, and every statement below phrased as an infimum may be read
as a minimum.

**Theorem 2.8 (Positive homogeneity).** For $c \ge 0$,
$\delta(x, c\,y) = c\,\delta(x,y)$.

*Proof sketch.* For $c > 0$, the map $d \mapsto c\,d$ is a bijection
$\mathcal{R}(x,y) \to \mathcal{R}(x, c\,y)$ (comonotonicity constraints are
positively homogeneous) and scales the $\ell^1$ cost by $c$; hence the infima
correspond. For $c = 0$ the rates are constant, hence comonotone, and both sides
vanish by Theorem 2.6. $\square$

Since $\Delta(x, c\,y) = c\,\Delta(x,y)$ as well, **both defect functionals are
homogeneous of degree one in the rates**. This single observation will kill the
conjectured lower bound $\delta^2 \le \Delta$ in Section 5.

**Theorem 2.9 (One-sided stability).** For any rate vectors $y, y'$,
$$\delta(x,y) \;\le\; \delta(x,y') + \|y - y'\|_1 .$$

*Proof.* If $d \in \mathcal{R}(x,y')$, then $d + (y' - y) \in \mathcal{R}(x,y)$,
because $y + \bigl(d + (y' - y)\bigr) = y' + d$ is comonotone with $x$ by
hypothesis. The triangle inequality gives
$\|d + (y'-y)\|_1 \le \|d\|_1 + \|y - y'\|_1$, so
$\delta(x,y) - \|y-y'\|_1 \le \|d\|_1$ for every $d \in \mathcal{R}(x,y')$;
Lemma 2.4(ii) concludes. $\square$

**Corollary 2.10 ($1$-Lipschitz).**
$\bigl|\delta(x,y) - \delta(x,y')\bigr| \le \|y - y'\|_1$.

*Proof.* Apply Theorem 2.9 in both directions. $\square$

Corollary 2.10 says the repair distance is a *robust* population statistic:
measurement error of total size $\eta$ perturbs it by at most $\eta$. We show in
Section 6.3 that the discordance mass admits no such estimate, which is the
principal practical argument for the repair distance.

---

## 3. The upper bound: discordance is controlled by repair

**Theorem 3.1 (Upper bound).** Suppose $|x_i - x_j| \le R$ for all $i,j$. Then
$$\Delta(x,y) \;\le\; 2\,n\,R\,\delta(x,y).$$

*Proof.* Fix a repair $d \in \mathcal{R}(x,y)$ and a pair $(i,j)$. Comonotonicity
of $(x, y+d)$ gives
$$0 \;\le\; (x_i - x_j)\bigl((y_i - y_j) + (d_i - d_j)\bigr),$$
so, rearranging,
$$-(x_i - x_j)(y_i - y_j) \;\le\; (x_i - x_j)(d_i - d_j)
\;\le\; |x_i - x_j|\,|d_i - d_j| \;\le\; R\,\bigl(|d_i| + |d_j|\bigr).$$
The right-hand side is nonnegative, so it also dominates $0$, whence
$$D(i,j) \;=\; \max\bigl(-(x_i-x_j)(y_i-y_j),\,0\bigr) \;\le\; R\bigl(|d_i| + |d_j|\bigr).$$
Summing over all ordered pairs and using the elementary identity
$$\sum_{i}\sum_{j}\bigl(|d_i| + |d_j|\bigr) \;=\; 2\,n\,\|d\|_1$$
(each coordinate appears $n$ times in each of the two slots) yields
$\Delta(x,y) \le 2 n R \|d\|_1$. As $d$ was an arbitrary repair, dividing by the
positive constant $2nR$ (the degenerate cases $n = 0$ and $R = 0$ being trivial,
the latter forcing $\Delta = 0$) and taking the infimum gives the claim.
$\square$

Note two features of the argument. First, it is a *pointwise* estimate: each
pair is charged separately, and the total is obtained by summation. Second,
every coordinate $|d_k|$ is charged $2n$ times, once for each pair in which it
appears. This double-counting is precisely the source of the factor $n$, and
Section 5.2 shows it is not an artifact: the factor is genuinely necessary.

---

## 4. The sharp lower bound via the isotonic upper envelope

The lower bound requires a nondegeneracy hypothesis on the footprint, which
holds automatically for any discretely valued exposure variable.

**Definition 4.1 ($g$-separation).** The footprint $x$ is **$g$-separated**
($g > 0$) if $x_i < x_j$ implies $x_j - x_i \ge g$.

Equivalently, the distinct values in the image of $x$ are at mutual distance at
least $g$. Dose levels, grade bands, integer counts and any footprint whose
values are drawn from a fixed finite grid are $g$-separated.

### 4.1 The envelope repair

**Definition 4.2 (Predecessor set and isotonic upper envelope).** For $i \in
\iota$ set
$$P(i) \;=\; \{i\} \cup \{\, j \in \iota : x_j < x_i \,\}, \qquad
\hat y_i \;=\; \max_{j \in P(i)} y_j .$$
$P(i)$ is nonempty (it contains $i$), so $\hat y$ is well defined; $\hat y$ is
the **isotonic upper envelope** of $y$ along $x$.

**Lemma 4.3.** (i) $y_i \le \hat y_i$ for all $i$. (ii) If $x_i < x_k$ then
$\hat y_i \le \hat y_k$. (iii) $(x, \hat y)$ is comonotone.

*Proof.* (i) is immediate from $i \in P(i)$. For (ii), $x_i < x_k$ implies
$P(i) \subseteq P(k)$: indeed $i \in P(k)$, and $x_j < x_i < x_k$ gives
$j \in P(k)$; a maximum over a larger set is larger. For (iii), take $i,j$: if
$x_i < x_j$ then $\hat y_i \le \hat y_j$ by (ii) and the product
$(x_i - x_j)(\hat y_i - \hat y_j)$ is a product of two nonpositive numbers; the
case $x_j < x_i$ is symmetric; and if $x_i = x_j$ the product vanishes.
$\square$

Consequently $d^{\mathrm{env}} = \hat y - y \ge 0$ is an admissible repair, with
$$\delta(x,y) \;\le\; \|d^{\mathrm{env}}\|_1 \;=\; \sum_{b} \bigl(\hat y_b - y_b\bigr). \tag{4.1}$$
Write $\mathrm{cost}(b) = \hat y_b - y_b \ge 0$ for the envelope's expenditure at
key $b$.

### 4.2 Charging: each key pays a distinct column

**Lemma 4.4 (Witness).** For each $b$ choose $w(b) \in P(b)$ realising the
maximum, so $\hat y_b = y_{w(b)}$. If $\mathrm{cost}(b) > 0$, then
$x_{w(b)} < x_b$ and $y_b < y_{w(b)}$; that is, the ordered pair
$\bigl(w(b), b\bigr)$ is discordant.

*Proof.* $\mathrm{cost}(b) > 0$ gives $y_b < \hat y_b = y_{w(b)}$, so
$w(b) \ne b$; hence $w(b) \in P(b) \setminus \{b\}$, which means
$x_{w(b)} < x_b$. $\square$

**Lemma 4.5 (Charge).** Let $x$ be $g$-separated and $\mathrm{cost}(b) > 0$. Then
$$g \cdot \mathrm{cost}(b) \;\le\; D\bigl(w(b),\, b\bigr).$$

*Proof.* By Lemma 4.4, $x_b - x_{w(b)} \ge g$ (by $g$-separation) and
$y_{w(b)} - y_b = \mathrm{cost}(b) > 0$. Therefore
$$D\bigl(w(b), b\bigr) \;=\; -(x_{w(b)} - x_b)(y_{w(b)} - y_b)
\;=\; (x_b - x_{w(b)})\bigl(y_{w(b)} - y_b\bigr) \;\ge\; g \cdot \mathrm{cost}(b). \ \square$$

**Theorem 4.6 (Dimension-free lower bound).** If $x$ is $g$-separated then
$$g\,\delta(x,y) \;\le\; \Delta(x,y).$$

*Proof.* Combining (4.1) with Lemma 4.5, and noting that the inequality
$g\,\mathrm{cost}(b) \le \sum_a D(a,b)$ also holds trivially when
$\mathrm{cost}(b) = 0$ (the right side being a sum of nonnegative terms),
$$g\,\delta(x,y) \;\le\; \sum_b g\,\mathrm{cost}(b) \;\le\; \sum_b \sum_a D(a,b) \;=\; \Delta(x,y),$$
the last equality being the interchange of the two summations. $\square$

The essential point is that the charge for key $b$ lands in **column $b$** of the
discordance matrix; distinct keys therefore consume disjoint columns, so the
charges may be summed with no loss. This is what makes the bound *dimension
free*: unlike Theorem 3.1, no factor of $n$ appears.

### 4.3 Doubling by symmetry

The constant in Theorem 4.6 can be improved by exactly a factor of two, and the
improvement is optimal.

**Theorem 4.7 (Sharp lower bound).** If $x$ is $g$-separated then
$$2\,g\,\delta(x,y) \;\le\; \Delta(x,y).$$

*Proof sketch.* Write $\Delta(x,y) = \sum_{(a,b) \in \iota \times \iota} D(a,b)$
as a sum over ordered pairs. Consider the two families of ordered pairs indexed
by the keys $b$ at which the envelope spends something:
$$\mathcal{F} = \bigl\{\, (w(b), b) \,\bigr\}, \qquad
\mathcal{F}^{\top} = \bigl\{\, (b, w(b)) \,\bigr\}.$$
Each family is *injectively indexed* by $b$ — in $\mathcal{F}$ the second
coordinate is $b$, in $\mathcal{F}^\top$ the first. The two families are
*disjoint*: an overlap $(w(b), b) = (b', w(b'))$ would give $b' = w(b)$ and
$b = w(b')$, hence $x_{b'} = x_{w(b)} < x_b$ and $x_b = x_{w(b')} < x_{b'}$, a
contradiction. Since the discordance matrix is symmetric,
$D(b, w(b)) = D(w(b), b) \ge g\,\mathrm{cost}(b)$ by Lemma 4.5. Summing over
$\mathcal{F} \sqcup \mathcal{F}^\top$ — a set of pairwise distinct index pairs,
all other entries of $D$ being nonnegative — gives
$$2 g \sum_b \mathrm{cost}(b) \;\le\; \sum_{(a,b)} D(a,b) \;=\; \Delta(x,y),$$
and (4.1) finishes the proof. $\square$

**Theorem 4.8 (Optimality of the constant $2$).** The constant $2$ in Theorem
4.7 cannot be increased. For the $1$-separated two-key population
$$x = (0,1), \qquad y = (3,0),$$
one has $\delta = 3$, $g = 1$, $\Delta = 6$, so $2 g \delta = \Delta$: the
inequality is an equality. Consequently, for every $C > 2$ the inequality
$C\,g\,\delta \le \Delta$ fails.

*Proof.* $\Delta$: the only discordant unordered pair is $\{0,1\}$, with
$-(0-1)(3-0) = 3$, counted twice among ordered pairs, so $\Delta = 6$. $\delta$:
the perturbation $d = (-3, 0)$ makes the rates $(0,0)$, which is comonotone with
any footprint, so $\delta \le 3$; and Lemma 2.5 applied to the pair $(0,1)$ with
$x_0 < x_1$ gives $y_0 - y_1 = 3 \le \delta$. $\square$

### 4.4 The two-sided comparison

**Theorem 4.9 (Sharp two-sided comparison).** Let $x$ be $g$-separated with
$|x_i - x_j| \le R$ for all $i,j$, on $n$ keys. Then
$$2\,g\,\delta(x,y) \;\le\; \Delta(x,y) \;\le\; 2\,n\,R\,\delta(x,y).$$
The left constant is attained (Theorem 4.8); the right-hand bound is attained up
to a factor of two (Theorem 5.4) and its factor $n$ cannot be removed (Theorem
5.5).

In particular the two defect functionals are equivalent as *gauges*: each
vanishes exactly when the other does, and each is bounded by a constant multiple
of the other with constants depending only on $g$, $R$ and $n$.

---

## 5. Refutations and sharpness

The literal dimension-free conjecture
$$\delta^2 \;\le\; \Delta \;\le\; 2\,\delta\,R \tag{5.1}$$
is false on both sides. We exhibit the obstructions.

### 5.1 The left inequality fails: a degree obstruction

**Theorem 5.1 (No quadratic lower bound).** The inequality
$\delta(x,y)^2 \le \Delta(x,y)$ does not hold in general. For $x = (0,1)$,
$y = (3,0)$ one has $\delta^2 = 9 > 6 = \Delta$.

**Theorem 5.2 (No superlinear comparison, quantitative).** For every constant
$C$ there exists a population with
$$C \cdot \Delta(x,y) \;<\; \delta(x,y)^2 .$$
Indeed, take $x = (0,1)$ and $y_t = (3t, 0)$ for $t > 0$. By homogeneity
(Theorem 2.8 and the corresponding scaling of $\Delta$),
$$\delta(x, y_t) = 3t, \qquad \Delta(x, y_t) = 6t, \qquad
\frac{\delta^2}{\Delta} = \frac{9t^2}{6t} = \frac{3t}{2} \xrightarrow[t \to \infty]{} \infty .$$

*Discussion.* The failure is structural rather than accidental. Both $\Delta$ and
$\delta$ are positively homogeneous of degree one in the rate vector, while
$\delta^2$ is homogeneous of degree two. No inequality between a degree-two and a
degree-one positive functional can hold on a scaling-closed family unless the
degree-two side vanishes identically. Any correct comparison must therefore be
degree-matched — which is exactly what Theorem 4.9 delivers.

### 5.2 The right inequality fails: a dimension obstruction

**Theorem 5.3 (No dimension-free upper bound).** The inequality
$\Delta \le 2\,\delta\,R$ does not hold in general. For the three-key population
$$x = (0,1,2), \qquad y = (1,0,0),$$
one has $R = 2$, $\delta = 1$, $\Delta = 6 > 4 = 2 \delta R$.

*Proof.* The discordant unordered pairs are $\{0,1\}$ with violation
$-(0-1)(1-0) = 1$ and $\{0,2\}$ with violation $-(0-2)(1-0) = 2$; the pair
$\{1,2\}$ is tied. Doubling for ordered pairs, $\Delta = 2(1+2) = 6$. For
$\delta$: the perturbation $d = (-1, 0, 0)$ makes the rates $(0,0,0)$, so
$\delta \le 1$; and Lemma 2.5 on the pair $(0,1)$ gives $1 \le \delta$. $\square$

The mechanism is transparent: the discordance mass aggregates over
$\Theta(n^2)$ pairs, while an $\ell^1$ repair can neutralise all of them by
moving a *single* coordinate. Scaling this up shows the population-size factor
in Theorem 3.1 is not merely convenient but necessary.

**Definition (Outlier family).** For $m \ge 0$ and $n = m + 2$ keys indexed
$0, \dots, n-1$, set
$$x^{(m)}_i = i, \qquad y^{(m)}_i = \begin{cases} 1, & i = 0,\\ 0, & i \ne 0.\end{cases}$$
The footprint is $1$-separated with range $R = n - 1 = m+1$.

**Theorem 5.4 (Outlier family: exact values, and the upper bound is attained up
to $2$).** For the outlier family,
$$\Delta\bigl(x^{(m)}, y^{(m)}\bigr) = n(n-1) = (m+2)(m+1), \qquad
\delta\bigl(x^{(m)}, y^{(m)}\bigr) = 1,$$
and consequently
$$\Delta \;=\; \tfrac{1}{2}\bigl(2\,n\,R\,\delta\bigr),$$
i.e. the general upper bound of Theorem 3.1 overshoots by exactly a factor of
two on this family.

*Proof sketch.* Discordance: the discordant unordered pairs are exactly
$\{0, j\}$ for $j \ge 1$, with violation $-(0 - j)(1 - 0) = j$; hence
$\Delta = 2\sum_{j=1}^{n-1} j = n(n-1)$. Repair distance: lowering the outlier,
$d = (-1, 0, \dots, 0)$, flattens the rates and is admissible, so $\delta \le 1$;
Lemma 2.5 on the pair $(0,1)$ gives $y_0 - y_1 = 1 \le \delta$. $\square$

**Theorem 5.5 (The population-size factor is necessary).** For every constant
$C$ there is a member of the outlier family with
$$C \cdot R\,\delta \;<\; \Delta .$$
Indeed $\Delta / (R\,\delta) = n(n-1)/(n-1) = n$, which is unbounded. Hence no
inequality of the form $\Delta \le C\,R\,\delta$ holds, and the factor $n$ in
Theorem 3.1 is unavoidable.

---

## 6. Applications: triage, robustness, and the dial

### 6.1 The dial and its pair identity

Let $p : \iota \to \mathbb{R}$ satisfy $\sum_i p_i = 1$, and recall (1.2). Under
the **uniform draw regime** $p_i \equiv 1/n$, the identity takes a particularly
clean unnormalised form.

**Theorem 6.1 (Uniform pair identity).** For $n \ge 1$ and uniform weights,
$$2\,n^2 \cdot \operatorname{wcov}\bigl(p^{\mathrm{unif}}; x, y\bigr) \;=\; C(x,y) - \Delta(x,y).$$

*Proof sketch.* By (1.2) with $p_i = 1/n$,
$\operatorname{wcov} = \tfrac{1}{2n^2}\sum_i\sum_j (x_i - x_j)(y_i - y_j)$, and
splitting each summand into its positive and negative parts gives
$\sum_i\sum_j (x_i - x_j)(y_i - y_j) = C(x,y) - \Delta(x,y)$. $\square$

So the dial reading is literally the concordance/discordance balance of the
population, at the exchange rate $2n^2$.

### 6.2 Triage from a single population parameter

**Theorem 6.2 (Regime-uniform positivity).** Suppose $\sum_i p_i = 1$ and
$\varepsilon \le p_i \le M$ for all $i$, with $\varepsilon > 0$. If
$$M^2\,\Delta(x,y) \;<\; \varepsilon^2\,C(x,y),$$
then $\operatorname{wcov}(p; x, y) > 0$.

*Proof sketch.* Split (1.2) into concordant and discordant contributions. Each
concordant term $p_i p_j (x_i - x_j)(y_i - y_j) \ge \varepsilon^2$ times the
corresponding entry of the concordance matrix; each discordant term is at least
$-M^2$ times the corresponding entry of $D$. Summing gives (1.3), and the
hypothesis makes the right-hand side positive. $\square$

**Theorem 6.3 (Triage from the repair distance).** Under the hypotheses of
Theorem 6.2, with $|x_i - x_j| \le R$ for all $i,j$, the conclusion
$\operatorname{wcov}(p;x,y) > 0$ holds as soon as
$$M^2 \cdot \bigl(2\,n\,R\,\delta(x,y)\bigr) \;<\; \varepsilon^2\, C(x,y),$$
equivalently, writing $\kappa = M/\varepsilon$ for the conditioning number of the
regime,
$$\kappa^2 \cdot 2\,n\,R\,\delta(x,y) \;<\; C(x,y).$$

*Proof.* Theorem 3.1 gives $\Delta \le 2nR\delta$; multiply by $M^2 \ge 0$ and
apply Theorem 6.2. $\square$

This is the promised reformulation: the triage rule now involves the raw
pairwise table only through the single scalar $\delta$ (and the concordance mass
$C$, which is the *budget* being spent). A population that is cheap to repair
cannot be triaged away by any conditioning number: for fixed $C > 0$, the rule
fires for all regimes as soon as $\delta < C/(2 \kappa^2 n R)$.

### 6.3 Robustness: why $\delta$ and not $\Delta$

**Theorem 6.4 (The discordance mass is not Lipschitz).** The estimate
$|\Delta(x,y) - \Delta(x,y')| \le \|y - y'\|_1$ fails: for $x = (0,1)$, comparing
$y = (3,0)$ with the flat vector $y' = (0,0)$ gives $\|y - y'\|_1 = 3$ while
$|\Delta(x,y) - \Delta(x,y')| = 6$. Moreover no universal Lipschitz constant
exists. Stretching the footprint to $x^{(\lambda)} = (0,\lambda)$ and comparing
$y = (3,0)$ with $y' = (2,0)$ keeps the displacement fixed at
$\|y - y'\|_1 = 1$ while
$$\bigl|\Delta(x^{(\lambda)}, y) - \Delta(x^{(\lambda)}, y')\bigr| = 2\lambda
\ \xrightarrow[\lambda \to \infty]{}\ \infty,$$
so the local sensitivity of $\Delta$ to the rates grows without bound with the
scale of the footprint.

By contrast, $\delta$ is $1$-Lipschitz (Corollary 2.10). This is decisive in
practice: the rate vector is measured, not given, and a statistic whose
sensitivity to measurement error grows with the magnitude of the data cannot
support a certificate. The repair distance can, and the certificate is explicit.

**Theorem 6.5 (Robust triage).** Suppose the true rate vector is $y$, the
measured rate vector is $y'$, and the measurement error satisfies
$\|y - y'\|_1 \le \eta$. Under the hypotheses of Theorem 6.3, if
$$M^2 \cdot \Bigl(2\,n\,R\,\bigl(\delta(x, y') + \eta\bigr)\Bigr) \;<\; \varepsilon^2\, C(x,y),$$
then $\operatorname{wcov}(p; x, y) > 0$ for every admissible regime.

*Proof.* Corollary 2.10 gives $\delta(x,y) \le \delta(x,y') + \eta$; substitute
into Theorem 6.3. $\square$

### 6.4 The repair distance is a budget line inside the dial

The lower bound has a dual reading which converts $\delta$ from a bound on
$\Delta$ into a bound on the dial itself.

**Theorem 6.6 (The repair distance caps the dial).** Let $x$ be $g$-separated
and let $p$ be the uniform regime on $n \ge 1$ keys. Then
$$2\,n^2 \operatorname{wcov}(p; x, y) \;\le\; C(x,y) \;-\; g\,\delta(x,y).$$

*Proof.* Theorem 6.1 gives $2n^2\operatorname{wcov} = C - \Delta$, and Theorem
4.6 gives $g\delta \le \Delta$. $\square$

**Corollary 6.7 (A strong dial certifies cheap repair).** Under the same
hypotheses,
$$g\,\delta(x,y) \;\le\; C(x,y) - 2\,n^2 \operatorname{wcov}(p; x, y).$$

Interpreted operationally: the amount of $\ell^1$ repair a population needs is
subtracted, one for one (up to the separation constant $g$), from the largest
dial reading it can possibly produce. The repair distance is not a side
quantity; it is a *budget line* in the dial. Conversely, observing a strong
association is itself a certificate that the underlying data is cheap to make
monotone. Using the sharp Theorem 4.7 instead of Theorem 4.6 doubles the budget
term.

---

## 7. Irreducibility: $\Delta$ is not a function of $\delta$

The two-sided comparison of Theorem 4.9 is tight in its constants, but one might
still hope that $\Delta$ is determined by $\delta$ together with coarse footprint
data. It is not.

**Theorem 7.1 (Irreducibility).** There exist two populations with the *same*
footprint and the *same* comonotone repair distance but different discordance
masses. Explicitly, with $x = (0,1,2)$,
$$y = (1,0,0): \quad \delta = 1,\ \Delta = 6; \qquad
y' = (0,1,0): \quad \delta = 1,\ \Delta = 2 .$$
Hence $\Delta$ is not a function of $\delta$ (even after fixing $x$, $n$, $g$ and
$R$).

*Proof.* The values for $y$ were computed in Theorem 5.3. For $y'$: the only
discordant unordered pair is $\{1,2\}$, with violation $-(1-2)(1-0) = 1$, so
$\Delta = 2$; the pair $\{0,1\}$ is concordant and $\{0,2\}$ is tied. For the
repair distance, $d = (0,-1,0)$ flattens the rates so $\delta \le 1$, and Lemma
2.5 on the pair $(1,2)$ with $x_1 < x_2$ gives $y'_1 - y'_2 = 1 \le \delta$.
$\square$

**Interpretation.** The obstruction is not a defect of the analysis but a fact
about what $\ell^1$ repair can see. A repair records only *how far* rates must
move. The discordance mass additionally records *how many pairs* each misplaced
rate offends — a count that depends on the offending key's position in the
footprint order. An outlier at the extreme of the order is discordant with
everything ($\Theta(n)$ pairs); an inversion between order-neighbours is
discordant with one thing. Both cost one unit of $\ell^1$ repair. The
consequences are threefold:

1. The two-sided comparison of Theorem 4.9 cannot be sharpened into an identity,
   and the ratio $\Delta / \delta$ genuinely varies over the admissible window.
2. No $\ell^1$ repair statistic can replace $\Delta$ in Theorem 6.2 without loss:
   Theorem 6.3 is a *sufficient* criterion, strictly weaker than the exact
   criterion.
3. The pairwise data is **irreducible** in this precise sense — it carries
   information not visible to any $\ell^1$ repair.

A weighted repair cost $\sum_i c_i |d_i|$ with weights $c_i$ depending on the
position of $i$ in the footprint order could in principle recover part of the
missing count; identifying the exact class of repair costs for which the
comparison becomes an identity is an appealing open problem (Section 8.3).

---

## 8. Algorithms and computation

### 8.1 Computing the discordance and concordance masses

Both masses are direct $O(n^2)$ computations over ordered pairs; no cleverness is
needed at the scale where a population is small enough for the triage rule to be
interpretable, and $O(n \log n)$ order-statistics methods (in the spirit of
inversion counting) are available when it is not.

### 8.2 Computing the repair distance

The envelope repair of Section 4 provides an $O(n^2)$ upper bound and a
constructive certificate; the pair certificates of Lemma 2.5 provide an $O(n^2)$
lower bound $\max\{y_i - y_j : x_i < x_j\}$. For $x = (0,1)$ and for the outlier
family these coincide, which is how the exact values above were obtained.

In general the exact value is the optimum of an $\ell^1$ isotonic regression:
$$\delta(x,y) = \min_{z \in K_x} \|y - z\|_1,$$
a linear program in $n$ variables with $O(n^2)$ constraints (reducible to $O(n)$
constraints between consecutive distinct footprint levels). The objective is
piecewise linear on the polyhedral cone $K_x$, so the minimum is attained at a
vertex of the feasible region translated by $y$, and every such vertex has
coordinates drawn from the multiset of observed rates. This yields a finite
search — the *$\ell^1$ isotonic normal form* — and, in the totally ordered case,
a dynamic program over levels and candidate values running in $O(n^2)$ time:
$$F(\ell, v) = \min_{v' \le v} F(\ell - 1, v') \; + \sum_{i \text{ at level } \ell} |y_i - v|,$$
minimised over candidate values $v$ from the sorted rate multiset, with
$F(0,\cdot) \equiv 0$. Making this normal form rigorous is Direction 1 of Section
9.

### 8.3 Certifying triage

Given $(x,y)$, a regime window $[\varepsilon, M]$, and a measurement tolerance
$\eta$, the triage certificate is decided by the following procedure:

1. Compute $R = \max_{i,j}|x_i - x_j|$ and the separation
   $g = \min\{x_j - x_i : x_i < x_j\}$.
2. Compute $C(x,y)$ in $O(n^2)$.
3. Compute (or upper-bound, via the envelope) $\delta(x,y)$.
4. Report **certified** if $(M/\varepsilon)^2 \cdot 2 n R (\delta + \eta) < C$.

An upper bound on $\delta$ suffices at step 3, which is what makes the envelope
construction operationally useful: it is a one-pass, sorting-based computation
that never solves the linear program.

---

## 9. Future directions

**Direction 1 — Exact $\ell^1$ isotonic normal form.** The vertex characterisation
sketched in Section 8.2 is folklore for $\ell^1$ isotonic regression but has not
been established here. Attainment (Theorem 2.7) gives *some* minimiser; the
remaining step is a purely combinatorial vertex argument establishing that some
minimiser has all coordinates drawn from the multiset of observed rates. This
would turn $\delta$ into a *computable* statistic in the strict sense, and enable
decision-procedure-level certification of triage rules on concrete populations.

**Direction 2 — Weighted repair distance and regime-dependent triage.** The
triage rule of Theorem 6.3 is regime-uniform, and the conditioning number enters
as $\kappa^2$. Replacing the $\ell^1$ cost $\sum_i |d_i|$ by the regime-weighted
cost $\sum_i p_i |d_i|$ should reduce this to $\kappa$. The reason to expect this
is that both the discordance mass and the repair cost are charged pair by pair,
so charging each key by its own draw mass keeps the disjoint double-charging
argument of Theorem 4.7 intact while replacing one factor of $\kappa$ by an
exact weight. The double-charging proof is already in the disjoint-family form
required.

**Direction 3 — Which repair costs recover the pairwise data?** Theorem 7.1 shows
the unweighted $\ell^1$ cost loses the "how many pairs are offended" count. It is
natural to ask for the exact class of repair costs $\sum_i c_i |d_i|$ — with
$c_i$ allowed to depend on the rank of $i$ in the footprint order — for which the
two-sided comparison becomes an identity, or for which the resulting triage rule
becomes necessary as well as sufficient. A negative answer (no such cost exists)
would be an even stronger irreducibility theorem.

**Further questions.** (i) A matching *lower* bound on $\Delta$ in terms of $n$,
$R$ and $\delta$ for footprints that are not $g$-separated, using a modulus of
separation instead. (ii) Continuous-population analogues, replacing sums by
integrals against a base measure and the isotonic cone by the cone of
nondecreasing functions, where the envelope construction becomes a running
supremum. (iii) A two-sided comparison for the $\ell^2$ repair distance, where
the envelope is replaced by the pool-adjacent-violators projection and the
charging argument must account for averaging rather than maximisation.

---

## 10. Conclusion

We have introduced the comonotone repair distance $\delta(x,y)$ — the least
$\ell^1$ perturbation of the rates that removes every discordant pair — and
placed it in sharp two-sided relation with the discordance mass:
$$2 g \delta \;\le\; \Delta \;\le\; 2 n R \delta,$$
with the left constant exactly optimal, the right constant sharp up to a factor
of two, and the population-size factor provably necessary. Along the way we
refuted the natural dimension-free conjecture $\delta^2 \le \Delta \le 2\delta R$
in both directions, identifying a degree obstruction and a dimension obstruction
respectively.

The comparison has teeth. It converts the regime-uniform triage criterion for a
positive weighted covariance into a criterion in a single interpretable
population parameter, robust to measurement error because $\delta$ — unlike
$\Delta$ — is $1$-Lipschitz. Dually it exhibits the repair distance as a budget
line inside the covariance: $2n^2\operatorname{wcov} \le C - g\delta$, so every
unit of needed repair is subtracted from the largest achievable signal.

And the comparison has a limit, which we have made precise. Two populations with
the same footprint and the same repair distance can have discordance masses
differing by a factor of three. The pairwise table is not compressible into any
$\ell^1$ repair statistic. What $\delta$ offers is stability and
interpretability; what $\Delta$ retains is the count of offences. Knowing exactly
where one ends and the other begins is, we would argue, the useful part.
