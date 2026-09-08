# Measurable Ceilings for Content-Only Predictors: An ANOVA Anatomy of the Nonlinear Probe Bound

**Author:** Aristotle
**Date:** 2026-09-07

---

## Abstract

Given a finite population of observations, each carrying a discrete *content label* and a real
*response*, we study the supremum of the coefficient of determination $R^2$ over the class of all
predictors that are functions of the label alone. This class contains every "content head" of
every depth, and so a bound on it is a bound on an unbounded hypothesis class. We prove that the
supremum is an attained maximum, equal to the correlation ratio
$\eta^2 = 1 - SS_{\mathrm{within}}/SS_{\mathrm{tot}}$, and we develop its complete anatomy: an
exact analysis-of-variance decomposition $SS_{\mathrm{tot}} = SS_{\mathrm{within}} +
SS_{\mathrm{between}}$; the identification of the optimal content head as an orthogonal projection
(linear, idempotent, self-adjoint), which exhibits the ceiling as a squared cosine and makes the
threshold $\eta^2 = 1/2$ a $45°$ statement; monotonicity of the ceiling under coarsening of the
label map, so that no post-processing of the content can beat the raw content; and exact
characterizations of the two degenerate regimes $\eta^2 = 1$ and $\eta^2 = 0$.

We then turn to the operational question. We show that $SS_{\mathrm{within}}$ can be
*lower-bounded* from repeated labels alone, giving a **pair certificate**: if the observed
squared response gaps of repeated labels sum to more than $SS_{\mathrm{tot}}$, then every content
function has $R^2 < 1/2$. We prove this certificate is *complete* exactly when no label occurs
more than twice — completeness holds at two (with an explicit construction of the witness family),
and fails at three (with an explicit six-observation counterexample of ceiling $0.4386\ldots$ on
which no certificate fires). In the two-per-label design the bound is an identity:
$SS_{\mathrm{within}} = \frac12 \sum_y g_y^2$. We give a dual, Popoviciu-type **refutation
certificate**: small observed within-label ranges force $\eta^2 \ge 1/2$ and exhibit the
conditional mean as a content head attaining it. Three invariance theorems (affine rescaling of
responses, injective relabelling of contents, $k$-fold replication of the population) show the
ceiling is a functional of the empirical (label, response) distribution.

Finally we apply this to a specific conjecture — that for a pooled train/test window population
the ceiling lies below $0.5$, so no content head exceeds $R^2 = 0.5$, and a measured linear
$0.329$ captures more than two thirds of the achievable maximum. We show the conjecture splits
into three claims with three different fates: the "no head exceeds $1/2$" claim is true but
conditional on a measurable certificate; the "$\eta^2 < 0.5$" claim is not a theorem, since a
four-observation family realizes *every* value in $[0,1)$; and the "two thirds" clause is false at
its own boundary ($0.329/0.5 = 0.658 < 2/3$), with exact repair threshold $0.4935$ and salvaged
statement "more than $65\%$". A by-product identifies the within-content sum of squares of the
pooled population with a relational dispersion, yielding an asymmetric trade-off: failure of the
content bound forces the relational deficit to be at most
$\sqrt{B\, SS_{\mathrm{tot}}/(2|W|)}$.

**Keywords:** correlation ratio, analysis of variance, intrinsic ceiling, orthogonal projection,
probe bound, certificate completeness, Popoviciu inequality, pooled populations.

---

## 1. Introduction

### 1.1 The question

A recurring methodological problem in empirical model analysis is the *probe ceiling* question. One
fits a simple predictor — typically linear — from some feature to a target, obtains an $R^2$, and
must then decide whether to invest in a more expressive predictor. The honest form of the question
is: *what is the supremum of $R^2$ over the entire class of predictors that read the same
feature?* If that supremum is close to the value already obtained, further modelling effort is
wasted; if it is far above, a deeper head is worth building.

Searching over models cannot answer this. A failure to find a better model is not evidence that
none exists, and the class of "all functions of the feature" is infinite. What can answer it is a
quantity computed from the data that no predictor can influence.

When the feature is *discrete* — a content label, a token, a key, a category — such a quantity
exists, is classical in the analysis of variance, and is computable without reference to any
hypothesis class. This paper develops that quantity into an operational instrument: an exact
maximum, its geometry, its degenerations, one-sided certificates in both directions, a sharp
completeness theorem for those certificates, and invariance guarantees.

### 1.2 Setting and notation

Fix a finite index set $\iota$ of observations and a finite set $\kappa$ of content labels. The
data are:

- a **content map** $\mathrm{key} : \iota \to \kappa$, and
- a **response** $a : \iota \to \mathbb{R}$.

In the motivating application, an observation is a *window* (a span of context) pooled across
train and test splits, the content label is the discrete key content of that window, and the
response is a measured *importance* of the window to the model's output.

Write:

- $\bar a = \dfrac{1}{|\iota|}\sum_{i} a(i)$, the **grand mean**;
- $SS_{\mathrm{tot}}(a) = \sum_i (a(i) - \bar a)^2$, the **total dispersion**;
- $SSE(a, h) = \sum_i (a(i) - h(i))^2$ for any predictor $h : \iota \to \mathbb{R}$;
- $R^2(a, h) = 1 - SSE(a,h)/SS_{\mathrm{tot}}(a)$;
- $F_y = \{ i \in \iota : \mathrm{key}(i) = y\}$, the **fiber** over the label $y$;
- $\mu(y) = \dfrac{1}{|F_y|}\sum_{i \in F_y} a(i)$, the **conditional mean** (with the convention
  $\mu(y)=0$ when $F_y = \varnothing$; empty fibers contribute nothing to any sum below);
- $SS_{\mathrm{within}} = \sum_{y \in \kappa} \sum_{i \in F_y} \big(a(i)-\mu(y)\big)^2$, the
  **within-content sum of squares**;
- $SS_{\mathrm{between}} = \sum_{y\in\kappa} |F_y| \big(\mu(y) - \bar a\big)^2$, the
  **between-content sum of squares**.

A **content head** is a predictor of the form $i \mapsto f(\mathrm{key}(i))$ for some
$f : \kappa \to \mathbb{R}$. This class is exactly the set of predictors that read the label and
nothing else; it contains every tabulated lookup, every linear probe on any embedding of the
label, and every deep network applied to the label.

Throughout, $SS_{\mathrm{tot}}(a) > 0$ (a constant response has no ceiling to speak of).

### 1.3 Contributions

1. **The ceiling is an exact maximum** (§2): $\eta^2 = 1 - SS_{\mathrm{within}}/SS_{\mathrm{tot}}$
   is the greatest element — not merely an upper bound — of $\{R^2(a, f \circ \mathrm{key})\}$,
   attained by $f = \mu$.
2. **Anatomy** (§3): block Pythagoras, the ANOVA decomposition, the ceiling as the correlation
   ratio $\eta^2$, exact characterizations of the ceiling being $0$ or $1$, and the identification
   of the conditional-mean operator as an orthogonal projection, so that $\eta^2$ is a squared
   cosine and the $1/2$ threshold is the $45°$ line.
3. **Coarsening monotonicity** (§4): no depth stacked on the content can raise the ceiling.
4. **Measurement** (§5): the pair certificate, sound from observables only; and its exact form in
   the two-per-label design.
5. **Sharp completeness** (§6): complete at fiber size $\le 2$; explicitly incomplete at $3$ and
   at $4$.
6. **Dual refutation certificate** (§7): from within-label ranges, with the attaining head.
7. **Invariance** (§8): affine, relabelling, replication.
8. **Non-existence of an a priori bound and application to the conjecture** (§9–§10): a tunable
   family realizing all of $[0,1)$; the three-way verdict on the motivating conjecture; and the
   asymmetric trade-off with the relational programme.

---

## 2. The ceiling as an attained maximum

The starting point is the elementary minimizing property of the mean.

**Lemma 2.1 (Block Pythagoras).** *Let $G$ be a finite index set, $g : G \to \mathbb{R}$, and let
$m = \frac{1}{|G|}\sum_{j \in G} g_j$ (for $G \ne \varnothing$). Then for every $c \in \mathbb{R}$,*
$$\sum_{i \in G} (g_i - c)^2 \;=\; \sum_{i\in G} (g_i - m)^2 \;+\; |G|\,(m-c)^2 .$$

*Proof.* Termwise, $(g_i-c)^2 - (g_i-m)^2 = 2(m-c)g_i + (c^2 - m^2)$. Summing over $G$ and using
$\sum_i g_i = |G| m$ gives $2(m-c)|G|m + |G|(c^2-m^2) = |G|(m-c)^2$. The case $G = \varnothing$ is
trivial. $\square$

Lemma 2.1 says the squared error about *any* constant equals the block's internal dispersion plus
a penalty that is the block size times the squared displacement of the constant from the block
mean. In particular $c = m$ is the unique minimizer, and the identity — not merely the inequality
— is what will let us convert bounds into exact formulas later.

**Theorem 2.2 (Intrinsic ceiling; exact maximum).** *Assume $SS_{\mathrm{tot}}(a) > 0$. Then*
$$\max_{f : \kappa \to \mathbb{R}} R^2\big(a, f\circ\mathrm{key}\big) \;=\; 1 - \frac{SS_{\mathrm{within}}}{SS_{\mathrm{tot}}} \;=:\; \eta^2 ,$$
*with the maximum attained at $f = \mu$. In particular $0 \le \eta^2 \le 1$.*

*Proof sketch.* Partition $\iota$ into fibers. For a content head $f\circ\mathrm{key}$ the squared
error decomposes fiberwise, $SSE = \sum_y \sum_{i\in F_y} (a(i) - f(y))^2$, and by Lemma 2.1 each
inner sum equals $\sum_{i \in F_y}(a(i)-\mu(y))^2 + |F_y|(\mu(y)-f(y))^2 \ge \sum_{i\in F_y}
(a(i)-\mu(y))^2$, with equality iff $f(y) = \mu(y)$ on nonempty fibers. Summing,
$SSE \ge SS_{\mathrm{within}}$ with equality at $f=\mu$. Dividing by $SS_{\mathrm{tot}}$ and
subtracting from $1$ reverses the inequality and gives the claim. Nonnegativity of $\eta^2$ follows
from $SS_{\mathrm{within}} \le SS_{\mathrm{tot}}$ (take $f \equiv \bar a$ in the same inequality),
and $\eta^2 \le 1$ from $SS_{\mathrm{within}} \ge 0$. $\square$

The word *maximum* is the substance: $\eta^2$ is not merely an unattained bound one might hope to
approach, and not merely an upper envelope of a search — it is the value of a specific,
constructible predictor, namely the tabulated conditional mean.

**Corollary 2.3 (Restatement of the $1/2$ threshold).** *$\eta^2 < 1/2$ if and only if
$SS_{\mathrm{tot}} < 2\, SS_{\mathrm{within}}$.*

---

## 3. Anatomy of the ceiling

### 3.1 The decomposition

**Theorem 3.1 (ANOVA decomposition).**
$$SS_{\mathrm{tot}} \;=\; SS_{\mathrm{within}} \;+\; SS_{\mathrm{between}} .$$

*Proof sketch.* Write $SS_{\mathrm{tot}} = \sum_y \sum_{i\in F_y}(a(i)-\bar a)^2$ by partitioning
into fibers, then apply Lemma 2.1 to each fiber with $c = \bar a$, so that the $y$-th term becomes
$\sum_{i\in F_y}(a(i)-\mu(y))^2 + |F_y|(\mu(y)-\bar a)^2$. Summing over $y$ separates into
$SS_{\mathrm{within}} + SS_{\mathrm{between}}$. $\square$

**Corollary 3.2 (The ceiling is the correlation ratio).** *If $SS_{\mathrm{tot}} > 0$ then*
$$\eta^2 \;=\; \frac{SS_{\mathrm{between}}}{SS_{\mathrm{tot}}} .$$

**Corollary 3.3 (The threshold as a comparison of observables).**
*$\eta^2 < 1/2$ if and only if $SS_{\mathrm{between}} < SS_{\mathrm{within}}$.*

Corollary 3.3 is the cleanest statement of the question: is the explainable part of the dispersion
smaller than the unexplainable part? Both quantities are computed from the data with no reference
to any predictor.

### 3.2 The degenerate regimes

**Theorem 3.4 (Ceiling one).** *$SS_{\mathrm{within}} = 0$ if and only if there exists
$f : \kappa \to \mathbb{R}$ with $a(i) = f(\mathrm{key}(i))$ for all $i$. Consequently, when
$SS_{\mathrm{tot}} > 0$, $\eta^2 = 1$ if and only if the response is already a function of the
content.*

*Proof sketch.* If $SS_{\mathrm{within}} = 0$ then every fiber term vanishes; since each is a sum
of squares, every summand vanishes, so $a(i) = \mu(\mathrm{key}(i))$ for all $i$, and $f = \mu$
works. Conversely, if $a = f \circ \mathrm{key}$ then $SSE(a, f\circ\mathrm{key}) = 0$, and
$0 \le SS_{\mathrm{within}} \le SSE = 0$. The consequence follows since $\eta^2 = 1$ iff
$SS_{\mathrm{within}}/SS_{\mathrm{tot}} = 0$ iff $SS_{\mathrm{within}} = 0$. $\square$

An important corollary of Theorem 3.4 is a caveat on measurement. If the content map is
*injective* — every observation has its own label, no repetitions — then trivially
$a = f\circ\mathrm{key}$ for the obvious $f$, so $SS_{\mathrm{within}} = 0$ and the ceiling is
$1$. A ceiling of $1$ is not evidence that a content head will succeed; it is evidence that the
population contains no repetitions and therefore no information about generalization. *Repeated
labels are precisely what make the measurement meaningful*, and the pooling of train and test
windows is exactly the device that produces them.

**Theorem 3.5 (Ceiling zero).** *Assume $SS_{\mathrm{tot}} > 0$. Then $\eta^2 = 0$ if and only if
$\mu(y) = \bar a$ for every label $y$ with $F_y \ne \varnothing$.*

*Proof sketch.* By Corollary 3.2, $\eta^2 = 0$ iff $SS_{\mathrm{between}} = 0$ (the denominator is
nonzero). $SS_{\mathrm{between}}$ is a sum of nonnegative terms $|F_y|(\mu(y)-\bar a)^2$; it
vanishes iff each term does, and the factor $|F_y|$ is nonzero exactly on occupied fibers.
$\square$

The nonemptiness guard is not cosmetic. Labels that never occur have $\mu(y) = 0$ by convention
and are unconstrained; quantifying over all of $\kappa$ would make the characterization false for
any label alphabet with unused symbols.

### 3.3 The optimal head is an orthogonal projection

Let $P$ denote the operator sending a response vector $a$ to its fiberwise average,
$(Pa)(i) = \mu_a(\mathrm{key}(i))$, where $\mu_a$ is the conditional mean of $a$. Give
$\mathbb{R}^\iota$ the inner product $\langle a, b\rangle = \sum_i a(i)b(i)$.

**Theorem 3.6 (Projection).** *$P$ is linear, idempotent and self-adjoint:*

1. $\mu_{a+b} = \mu_a + \mu_b$ and $\mu_{ca} = c\,\mu_a$ (linearity);
2. $P(Pa) = Pa$ (idempotence): averaging an already content-measurable function changes nothing;
3. $\langle Pa, b\rangle = \langle a, Pb\rangle$ (self-adjointness).

*Proof sketch.* (1) is immediate from linearity of the fiber sums and of division by $|F_y|$.
(2) On a fiber $F_y$, the function $i \mapsto \mu_a(\mathrm{key}(i))$ is constant with value
$\mu_a(y)$, so its fiber average is $\mu_a(y)$. (3) The key computation is
$$\sum_i \mu_a(\mathrm{key}(i))\, b(i) \;=\; \sum_y \mu_a(y) \sum_{i \in F_y} b(i) \;=\; \sum_y |F_y|\, \mu_a(y)\,\mu_b(y),$$
using that a fiber sum equals its cardinality times its conditional mean. The right-hand side is
symmetric in $a$ and $b$, hence so is the left. $\square$

Thus $P$ is the orthogonal projection onto the subspace
$$\mathcal{C} = \{ h : \iota \to \mathbb{R} \;:\; h \text{ is constant on fibers} \}$$
of content-measurable functions. Writing $\tilde a = a - \bar a$ for the centred response, the
decomposition of Theorem 3.1 is the Pythagorean identity
$\|\tilde a\|^2 = \|\tilde a - P\tilde a\|^2 + \|P\tilde a\|^2$ (note $P$ fixes constants, so
$P\tilde a = Pa - \bar a$), and therefore
$$\eta^2 \;=\; \frac{\|P\tilde a\|^2}{\|\tilde a\|^2} \;=\; \cos^2 \theta,$$
where $\theta$ is the angle between the centred response and the subspace $\mathcal{C}$. The
threshold $\eta^2 = 1/2$ is exactly $\theta = 45°$: the conjecture under study asserts that the
importance vector makes an angle of more than $45°$ with everything content can express.

Idempotence has a direct methodological reading. If a proposed architecture computes the
conditional mean as an intermediate quantity and then applies further layers to it, those layers
operate inside $\mathcal{C}$, where $P$ is the identity — they can only move away from the optimum.
*Depth applied after the conditional mean gains exactly nothing.*

---

## 4. Coarsening monotonicity: depth cannot help

**Theorem 4.1 (Coarsening).** *Let $g : \kappa \to \kappa'$ be any map and consider the coarsened
content map $g \circ \mathrm{key}$. Then*
$$SS_{\mathrm{within}}(\mathrm{key}) \;\le\; SS_{\mathrm{within}}(g\circ\mathrm{key}),$$
*and hence, when $SS_{\mathrm{tot}} > 0$,*
$$\eta^2(g\circ\mathrm{key}) \;\le\; \eta^2(\mathrm{key}) .$$

*Proof sketch.* The optimal head for the coarsened map, namely $y' \mapsto \mu_{g\circ\mathrm{key}}(y')$,
induces a content head for the original map by precomposition with $g$. By Theorem 2.2 applied to
$\mathrm{key}$, $SS_{\mathrm{within}}(\mathrm{key})$ is a lower bound on the squared error of *any*
$\mathrm{key}$-measurable head, in particular this one, whose squared error is exactly
$SS_{\mathrm{within}}(g\circ\mathrm{key})$. $\square$

The interpretation is the reason this theorem is stated. A "deeper head" in practice does not read
the raw label; it reads a *derived* feature of it — an embedding, a hash bucket, a bottleneck
representation, a learned code. Every such derivation is a map $g$, and Theorem 4.1 says the
resulting ceiling is at most the ceiling of the raw label. The ceiling of the raw content map
dominates the entire tower of architectures built above it. Depth strictly *can* lose here; it can
never win.

---

## 5. Measuring the ceiling without a predictor

Theorem 2.2 makes the ceiling well defined; it does not make it cheap. Computing
$SS_{\mathrm{within}}$ exactly requires all fibers. But *bounding* it requires only repeated
labels, and a bound in the right direction is all a decision needs.

**Lemma 5.1 (One repeated label is evidence).** *Let $i \ne j$ with $\mathrm{key}(i) =
\mathrm{key}(j) = y$. Then*
$$\frac{(a(i)-a(j))^2}{2} \;\le\; \sum_{k \in F_y} \big(a(k)-\mu(y)\big)^2 .$$

*Proof sketch.* The two-element subset $\{i,j\} \subseteq F_y$ contributes
$(a(i)-\mu(y))^2 + (a(j)-\mu(y))^2$ to the fiber sum, and all other summands are nonnegative. For
any real $c$, $(x-c)^2+(y-c)^2 \ge (x-y)^2/2$, since the difference equals
$\frac{1}{2}(x+y-2c)^2 \ge 0$. Apply with $c = \mu(y)$. $\square$

**Theorem 5.2 (Pair lower bound).** *Let $Y \subseteq \kappa$ and let $p, q : \kappa \to \iota$
select, for each $y \in Y$, two distinct observations with $\mathrm{key}(p(y)) = \mathrm{key}(q(y))
= y$. Then*
$$\frac{1}{2}\sum_{y \in Y} \big(a(p(y)) - a(q(y))\big)^2 \;\le\; SS_{\mathrm{within}} .$$

*Proof sketch.* Apply Lemma 5.1 fiberwise and sum over $Y$; the resulting sum of fiber terms is at
most the sum over all of $\kappa$, since the omitted terms are nonnegative. $\square$

**Theorem 5.3 (Pair certificate for the nonlinear ceiling).** *In the setting of Theorem 5.2,
assume $SS_{\mathrm{tot}} > 0$ and the* certificate inequality
$$SS_{\mathrm{tot}} \;<\; \sum_{y \in Y}\big(a(p(y))-a(q(y))\big)^2 .$$
*Then $\eta^2 < 1/2$, and consequently $R^2(a, f\circ\mathrm{key}) < 1/2$ for* every *function
$f : \kappa \to \mathbb{R}$.*

*Proof sketch.* Theorem 5.2 gives $2\,SS_{\mathrm{within}} \ge \sum_y g_y^2 > SS_{\mathrm{tot}}$,
which is Corollary 2.3's criterion for $\eta^2 < 1/2$. The universal claim follows from Theorem
2.2. $\square$

Every quantity appearing in the hypothesis of Theorem 5.3 is an observable: the labels, the
identity of two windows sharing each label, and their measured responses. No model of the
predictor enters. This is the sense in which *the ceiling of the entire nonlinear class can be
measured rather than searched for.*

### 5.1 Exactness in the paired (one-train-one-test) design

**Theorem 5.4 (Two-point fibers are exact).** *If $F_y = \{i, j\}$ with $i \ne j$, then*
$$\sum_{k \in F_y} \big(a(k)-\mu(y)\big)^2 \;=\; \frac{(a(i)-a(j))^2}{2}.$$

*Proof.* $\mu(y) = (a(i)+a(j))/2$, and $(a(i)-\mu)^2 + (a(j)-\mu)^2 = 2\big((a(i)-a(j))/2\big)^2 =
(a(i)-a(j))^2/2$. $\square$

**Theorem 5.5 (Exact measurement).** *Suppose every label $y$ satisfies $F_y = \{p(y), q(y)\}$ with
$p(y) \ne q(y)$ — the canonical pooling in which each key content is seen in exactly two windows,
one train and one test. Then*
$$SS_{\mathrm{within}} \;=\; \frac{1}{2}\sum_{y}\big(a(p(y))-a(q(y))\big)^2 ,$$
*and therefore, when $SS_{\mathrm{tot}} > 0$,*
$$\eta^2 < \tfrac12 \iff SS_{\mathrm{tot}} < \sum_y \big(a(p(y))-a(q(y))\big)^2 .$$

In this design the ceiling of the whole nonlinear class is *literally* half the sum of the observed
importance gaps, and the threshold question is one arithmetic comparison between two numbers read
off the data.

---

## 6. Sharp completeness of the certificate

Theorem 5.3 is *sound*: when the certificate fires, its conclusion holds. The design question is
*completeness*: when $\eta^2 < 1/2$ genuinely holds, must a certificate exist?

### 6.1 Completeness at fiber size two

**Lemma 6.1.** *If $|F_y| \le 1$ then $\sum_{k\in F_y}(a(k)-\mu(y))^2 = 0$.*

(Immediate: an empty fiber contributes nothing, and a singleton's conditional mean is its own
value.)

**Theorem 6.2 (Completeness in the small-fiber regime).** *Assume $SS_{\mathrm{tot}} > 0$ and
$|F_y| \le 2$ for every label $y$. If $\eta^2 < 1/2$, then a firing certificate exists: there are
$Y \subseteq \kappa$ and selections $p, q$ with $\mathrm{key}(p(y)) = \mathrm{key}(q(y)) = y$,
$p(y) \ne q(y)$ for $y \in Y$, and*
$$SS_{\mathrm{tot}} \;<\; \sum_{y\in Y}\big(a(p(y))-a(q(y))\big)^2 .$$

*Proof sketch.* Take $Y = \{y : |F_y| = 2\}$ and, for each such $y$, let $p(y), q(y)$ be the two
distinct members of $F_y$ (a choice; the statement is existential, which is the honest form). By
Lemma 6.1 the labels outside $Y$ contribute nothing to $SS_{\mathrm{within}}$, so by Theorem 5.4
$$SS_{\mathrm{within}} = \sum_{y \in Y} \sum_{k\in F_y}(a(k)-\mu(y))^2 = \frac12\sum_{y\in Y} \big(a(p(y))-a(q(y))\big)^2 .$$
Corollary 2.3 turns $\eta^2 < 1/2$ into $SS_{\mathrm{tot}} < 2\,SS_{\mathrm{within}}$, which is
exactly the certificate inequality. $\square$

Thus in the paired design *measurement and truth coincide*: the certificate fires precisely when
the ceiling is below $1/2$.

### 6.2 Failure at fiber size three

The natural conjecture — that a single gap still sees "enough" of a three-point fiber — is false.

**Theorem 6.3 (Incompleteness at three).** *Consider six observations, two labels, three
observations per label, with responses*
$$\big(-\tfrac{13}{2},\, -\tfrac12,\, -\tfrac12\big) \quad\text{and}\quad \big(-\tfrac32,\, \tfrac92,\, \tfrac92\big).$$
*Then $\bar a = 0$, $SS_{\mathrm{tot}} = 85.5$, the conditional means are $\mp 5/2$,
$SS_{\mathrm{within}} = 48$, and*
$$\eta^2 = 1 - \frac{48}{85.5} = 0.4386\ldots < \tfrac12 ,$$
*yet for every admissible choice of one repeated pair per label,*
$$\sum_{y} \big(a(p(y))-a(q(y))\big)^2 \le 72 < 85.5 = SS_{\mathrm{tot}} ,$$
*so no certificate fires.*

*Proof sketch.* Each fiber has the pattern $(-4, 2, 2)$ around its conditional mean, contributing
$16+4+4 = 24$; hence $SS_{\mathrm{within}} = 48$. The grand mean is zero and the sum of squared
responses is $42.25 + 0.25 + 0.25 + 2.25 + 20.25 + 20.25 = 85.5$. Within a fiber only two distinct
values occur, so a gap is $0$ or $6$, giving squared gap at most $36$ per label and at most $72$
in total; a finite case check over the four sign patterns completes the argument. $\square$

Combining Theorems 6.2 and 6.3: **the completeness threshold is exactly two windows per key
content.**

### 6.3 The mechanism, and a second failure mode

The controlling quantity is the ratio of a fiber's dispersion to its squared diameter. For a
two-point fiber it is exactly $1/2$; for the extremal three-point configuration it is $2/3$; and
for a fiber of $n$ points split evenly at the two ends of its range it grows like $n/4$. A single
gap always reports $1/2$ of the squared diameter. The certificate is therefore *exact* at two and
*lossy* from three on.

The loss can be total.

**Theorem 6.4 (A population where no certificate fires and the ceiling is zero).** *Take four
observations all sharing a single label, with responses $1, -1, 1, -1$. Then $\bar a = 0$,
$SS_{\mathrm{tot}} = 4$, $\mu = 0$, $SS_{\mathrm{within}} = 4$, hence $\eta^2 = 0$. Yet every gap
between two observations has squared value at most $4$, so no one-pair-per-label certificate
satisfies $SS_{\mathrm{tot}} < \sum_y g_y^2$.*

Content explains *nothing at all* in this population, and the certificate is silent. Certificates
are one-sided evidence; soundness must never be read as completeness.

---

## 7. The dual: a measurable refutation

A confirming test alone leaves the conjecture unfalsifiable from data. The dual certificate closes
that gap, and rests on a Popoviciu-type upper bound on dispersion.

**Lemma 7.1 (Range bound).** *If $g_i \in [l, u]$ for all $i$ in a finite set $G$, then*
$$\sum_{i \in G}\big(g_i - \bar g\big)^2 \;\le\; |G| \left(\frac{u-l}{2}\right)^2 ,$$
*where $\bar g$ is the mean over $G$.*

*Proof sketch.* By Lemma 2.1 the mean minimizes, so the left side is at most
$\sum_i (g_i - \frac{l+u}{2})^2$. Each term is at most $\big(\frac{u-l}{2}\big)^2$, since $g_i$ lies
within $\frac{u-l}{2}$ of the interval's midpoint. $\square$

**Theorem 7.2 (Fiberwise range bound).** *If for each label $y$ the observed responses in $F_y$ lie
in $[l_y, u_y]$, then*
$$SS_{\mathrm{within}} \;\le\; \sum_y |F_y|\left(\frac{u_y - l_y}{2}\right)^2 .$$

**Theorem 7.3 (Refutation certificate).** *Assume $SS_{\mathrm{tot}} > 0$ and that the observed
within-label ranges satisfy*
$$\sum_y |F_y|\,(u_y - l_y)^2 \;\le\; 2\, SS_{\mathrm{tot}} .$$
*Then $\eta^2 \ge 1/2$, and moreover the conditional mean is an explicit content head with*
$$R^2\big(a, \mu\circ\mathrm{key}\big) \;\ge\; \tfrac12 .$$

*Proof sketch.* Theorem 7.2 with the factor $1/4$ extracted gives $SS_{\mathrm{within}} \le
\frac14 \sum_y |F_y|(u_y-l_y)^2 \le \frac12 SS_{\mathrm{tot}}$, whence
$\eta^2 = 1 - SS_{\mathrm{within}}/SS_{\mathrm{tot}} \ge 1/2$. The second claim is Theorem 2.2:
the ceiling is attained by $\mu$. $\square$

The hypothesis again involves only observables — fiber sizes and within-label ranges — and a
successful refutation is constructive: it does not merely assert that some deep content head could
reach $R^2 \ge 1/2$, it hands over the tabulated conditional mean, which does.

In the paired design the two certificates are exactly complementary. For a two-point fiber with
gap $g_y$ the range is $u_y - l_y = |g_y|$ and $|F_y| = 2$, so the refutation hypothesis reads
$2\sum_y g_y^2 \le 2\,SS_{\mathrm{tot}}$, i.e. $\sum_y g_y^2 \le SS_{\mathrm{tot}}$ — the exact
negation of the pair certificate's inequality. The pair of tests decides every paired population.

---

## 8. Invariance: the ceiling is a property of the population

A quantity used to make an engineering decision must not depend on the accidents of how the data
were recorded. Three theorems establish that it does not.

**Theorem 8.1 (Affine invariance).** *For $c \ne 0$ and any $b \in \mathbb{R}$, the response
$i \mapsto c\,a(i) + b$ has $SS_{\mathrm{within}}$ and $SS_{\mathrm{tot}}$ both scaled by $c^2$
(and unaffected by $b$), hence the same ceiling:*
$$\eta^2(c\,a + b) = \eta^2(a).$$

*Proof sketch.* Conditional means and the grand mean transform as $m \mapsto cm + b$, so every
deviation scales by $c$ and every squared deviation by $c^2$; the shift cancels in each deviation.
The ratio is then unchanged, using $c^2 \neq 0$. $\square$

Consequently the threshold $0.5$ is dimensionless: it is the same statement whether importance is
measured as attention mass, as a log-count, or after any per-layer renormalization.

**Theorem 8.2 (Relabelling invariance).** *If $g : \kappa \to \kappa'$ is injective and $\kappa$ is
nonempty, then $\eta^2(g\circ\mathrm{key}) = \eta^2(\mathrm{key})$.*

*Proof sketch.* One direction is Theorem 4.1. For the reverse, an injection has a left inverse
$g^{-1}$ on its image, so $\mathrm{key} = g^{-1}\circ(g\circ\mathrm{key})$ is itself a coarsening
of $g \circ \mathrm{key}$; Theorem 4.1 applied in that direction gives the opposite inequality, and
antisymmetry closes the argument. $\square$

So a different tokenizer, or a different hash of the key vector, cannot change the verdict: the
ceiling depends only on the partition of observations into fibers.

**Theorem 8.3 (Replication invariance).** *Let the $k$-fold replicated population ($k \ge 1$)
consist of $k$ copies of every observation, with labels and responses copied. Then both
$SS_{\mathrm{within}}$ and $SS_{\mathrm{tot}}$ are multiplied by $k$, and the ceiling is
unchanged.*

*Proof sketch.* Replication multiplies each fiber's cardinality and each fiber sum by $k$, leaving
conditional means and the grand mean fixed; every squared deviation is then counted $k$ times.
$\square$

Replication invariance rules out the most natural way a measured $SS_{\mathrm{within}}/
SS_{\mathrm{tot}}$ could be an artifact — re-using or resampling windows.

Taken together, the ceiling is a functional of the *empirical distribution* of (label, response)
pairs. The certificate, by contrast, is a functional of a chosen subsample of pairs, which is
precisely why it can be incomplete (§6) and why the two-per-label design is distinguished: there
the subsample is the sample.

---

## 9. No a priori bound: a tunable family

Nothing proved so far bounds the ceiling away from $1$. In fact nothing can.

**Definition 9.1 (The quad family).** Four observations, two labels, each label seen in exactly two
observations. With parameters $c$ (content-informative amplitude) and $d$ (swap amplitude), the
responses are
$$\underbrace{c+d,\; c-d}_{\text{label } 0}, \qquad \underbrace{-c-d,\; -c+d}_{\text{label } 1}.$$

**Theorem 9.2 (Exact ceiling of the family).** *For $(c,d) \ne (0,0)$: $\bar a = 0$,
$SS_{\mathrm{tot}} = 4c^2 + 4d^2$, the conditional means are $\pm c$, $SS_{\mathrm{within}} = 4d^2$,
and*
$$\eta^2 = \frac{c^2}{c^2 + d^2}.$$

**Corollary 9.3 (Every ceiling occurs).** *For every $\rho \in [0,1)$ there is a pooled population
with repeated labels and $SS_{\mathrm{tot}} > 0$ whose ceiling is exactly $\rho$: take
$c = \sqrt{\rho}$, $d = \sqrt{1-\rho}$.*

In particular $\rho = 0.9$ is realized (the ceiling can far exceed $1/2$), $\rho = 0$ is realized
at $c = 0$ (the pure-swap population, in which the two windows sharing a label carry opposite
importances and content explains nothing), and $c/d = 0.7$ realizes $\rho = 0.329$ — the measured
linear value occurring as an entire *ceiling*.

**Corollary 9.4 (Decision procedure in the paired design).** *For the quad family,
$\eta^2 < 1/2 \iff c^2 < d^2$: the ceiling conjecture holds precisely when the context-swap
amplitude dominates the content-informative amplitude.*

The methodological consequence of Corollary 9.3 is decisive. Since every value in $[0,1)$ occurs on
a genuine population of the required shape, **no structural theorem can decide whether the ceiling
is below $1/2$**. Only a measurement can, which is exactly why §5–§7 are the substance of the
result rather than an afterthought.

---

## 10. Application: adjudicating the conjecture

The motivating conjecture, stated for a pooled train/test window population of a fixed model, had
three clauses. We take them in turn.

### 10.1 "The ceiling lies below $0.5$"

**Verdict: not a theorem.** By Corollary 9.3 the ceiling is a free parameter of the population;
there exist pooled populations with repeated key contents and ceiling $0.9$. Any argument
purporting to derive the bound from the structure of pooling alone must be mistaken. The claim is
a *measurement*, and Theorem 5.5 makes it, in the canonical design, a single arithmetic
comparison.

### 10.2 "Hence no content head, however deep, exceeds $R^2 = 0.5$"

**Verdict: true, conditionally, with a measurable condition.** Theorem 5.3 derives it from an
inequality between observables that mentions no predictor; Theorem 2.2 makes the ceiling an exact
maximum, so the conclusion is not merely about the models one happens to try; and Theorem 4.1
shows that composing further depth on any derived content feature can only lower the achievable
$R^2$. The proper way to report this claim is therefore not "we did not find a better head" but
"the observed repeated-content gaps outweigh the total dispersion by such-and-such a margin,
therefore no content head reaches $1/2$".

### 10.3 "The measured $0.329$ captures more than two thirds of the ceiling"

**Verdict: false at the conjecture's own boundary, with an exact repair.**

First, the measured value is a legitimate lower bound for the ceiling: any content head with
$R^2 = 0.329$ certifies $\eta^2 \ge 0.329$ by Theorem 2.2. So the ceiling lies in $[0.329, 1)$, and
under the conjecture in $[0.329, 0.5)$.

Now the arithmetic. At the extreme allowed ceiling $\eta^2 = 0.5$,
$$\frac{0.329}{0.5} = 0.658 \;<\; \frac23 = 0.6667\ldots,$$
so the two-thirds clause fails at the boundary of its own hypothesis.

**Theorem 10.1 (Exact threshold).** *For $\eta^2 > 0$: $0.329/\eta^2 > 2/3$ if and only if
$\eta^2 < 0.4935$.*

**Theorem 10.2 (Salvaged clause).** *If $0 < \eta^2 \le 1/2$ then $0.329/\eta^2 > 0.65$.*

So the conjecture's qualitative point survives — a measured $0.329$ against a ceiling of at most
$0.5$ leaves under $35\%$ of the achievable signal on the table — while its stated constant does
not. The corrected constants are $0.4935$ (threshold for the two-thirds claim) and $65\%$
(guaranteed capture below the $0.5$ ceiling).

### 10.4 The pooled population and the asymmetric trade-off

Let the pooled population have one observation per pair (key content $i$, window $w$), with
importance $a_w(i)$, labelled by the content $i$ (so a fiber is "all windows for one content").
Then the conditional mean over a fiber is the across-window average importance
$\bar a(i) = \frac{1}{|W|}\sum_w a_w(i)$, and the within-content sum of squares is
$$SS_{\mathrm{within}} = \sum_i \sum_w \big(a_w(i) - \bar a(i)\big)^2,$$
which is exactly the *context dispersion* of the companion relational programme: the extent to
which a content's importance varies across contexts.

This identification lets a second bound run in reverse. Let $B$ be a top-set size, $T$ the top-$B$
set of contents by average importance, and $O(w)$ the top-$B$ set within window $w$; let the
*relational deficit* measure the shortfall of the pooled top-set against the per-window top-sets.
An existing bound reads $\text{deficit} \le \sqrt{B \cdot SS_{\mathrm{within}}/|W|}$. Combining with
$\eta^2 \ge 1/2 \iff SS_{\mathrm{within}} \le \frac12 SS_{\mathrm{tot}}$:

**Theorem 10.3 (Asymmetric trade-off).** *If the ceiling conjecture fails on the pooled
population, i.e. $\eta^2 \ge 1/2$, then*
$$\text{relational deficit} \;\le\; \sqrt{\frac{B \cdot SS_{\mathrm{tot}}}{2\,|W|}} .$$

In words: the two research arms cannot both be binding. If a deep content head is worth building
(the content ceiling is high), then the relational deficit is automatically small, and the
relational arm cannot simply inherit the binding role. The programme's dichotomy is not symmetric,
and the asymmetry is quantitative.

---

## 11. Algorithms

Three procedures follow directly, all with complexity linear in the number of observations (after
grouping by label) and requiring no optimization.

**Algorithm A — Exact ceiling.** Group observations by label; accumulate per-fiber count and sum;
compute conditional means; accumulate $SS_{\mathrm{within}}$ and $SS_{\mathrm{tot}}$; return
$1 - SS_{\mathrm{within}}/SS_{\mathrm{tot}}$, and simultaneously $SS_{\mathrm{between}}$ as a
consistency check against Theorem 3.1. Cost $O(n)$ time, $O(|\kappa|)$ space.

**Algorithm B — Pair certificate.** For each label with at least two observations, select the pair
maximizing $|a(i)-a(j)|$ (the fiber's min and max, obtainable in one pass). Sum the squared gaps
and compare with $SS_{\mathrm{tot}}$. The maximizing choice is optimal among one-pair-per-label
certificates, so if this comparison fails no certificate of that form exists. Cost $O(n)$.

**Algorithm C — Refutation certificate.** For each label compute the observed range $u_y - l_y$ and
the fiber size; compare $\sum_y |F_y| (u_y-l_y)^2$ with $2\,SS_{\mathrm{tot}}$. If it passes,
return the tabulated conditional mean as an explicit head with $R^2 \ge 1/2$. Cost $O(n)$.

The three together give a decision procedure that returns one of: *confirmed* (no content head
reaches $1/2$), *refuted* (with an explicit head that does), or *undetermined by certificates* —
and, in the paired design of Theorem 5.5, the third outcome never occurs.

---

## 12. Discussion

### 12.1 What kind of result this is

The theorems fall into two epistemic classes, and keeping them apart is the main methodological
lesson. Theorems 2.2, 3.1–3.6, 4.1, 5.1–5.5, 6.2, 7.1–7.3 and 8.1–8.3 are *unconditional
mathematics*: they hold for every finite population. The conjecture's numerical clause is not of
this kind, and Corollary 9.3 proves that it cannot be — it is a statement about a particular
dataset, decidable only by computing on it.

The value of the mathematics is that it makes that computation *cheap*, *model-free*, *invariant*,
and *two-sided*. Before it, "is a deeper head worth building?" is an open-ended search. After it,
it is a comparison between two sums of squares, with an exact criterion for when the comparison is
conclusive.

### 12.2 Practical guidance

- **Design for repeated contents.** A population with no repetitions has ceiling $1$ (Theorem 3.4)
  and carries no information about achievable $R^2$. Pooling train and test windows is not a
  convenience here; it is what creates the measurement.
- **Prefer exactly two windows per content.** By Theorems 5.5 and 6.2 this design makes the
  certificate exact and complete. Larger fibers are more informative statistically but make the
  simple gap certificate lossy (Theorems 6.3, 6.4) — for those, compute $SS_{\mathrm{within}}$
  exactly by Algorithm A rather than certifying by gaps.
- **Report the ceiling alongside the $R^2$.** A probe $R^2$ without the ceiling is
  uninterpretable: $0.329$ against a ceiling of $0.35$ is near-saturation; against a ceiling of
  $0.9$ it is a large missed opportunity.
- **Do not stack depth on the conditional mean.** Idempotence (Theorem 3.6) says post-processing
  the fiberwise average is a no-op at best, and coarsening (Theorem 4.1) says reading a derived
  feature of the label instead of the label can only lose.

### 12.3 Limitations

The framework is finite and discrete: the content must be a label with genuine repetitions.
Continuous-content analogues require a smoothing or partitioning choice, and by Theorem 4.1 any
such partition yields a *lower* bound on the ceiling of the true content — coarsening is the
direction of loss, which is at least the safe direction for a confirming certificate and the wrong
one for a refuting certificate. The ceiling is also an in-sample quantity: it bounds achievable fit
on the population as recorded, not the generalization error of a head fitted to a subsample. Since
the tabulated conditional mean attaining the ceiling has as many free parameters as there are
labels, the ceiling should be read as *the best possible in-sample fit of the content*, which is
precisely the right object for a "can content explain this?" question and the wrong object for a
generalization claim.

---

## 13. Future directions

**Optimal matching certificates for large fibers.** The completeness threshold is exactly two
(Theorems 6.2, 6.3). For fibers of size $m$, one may certify with a *matching* rather than a single
pair: partition each fiber into disjoint pairs and sum all gaps. What fraction of a fiber's
dispersion does the optimal matching recover as a function of $m$? For $m = 2$ it is $1$; the
extremal three-point configuration suggests the answer decreases and stabilizes, and pinning the
exact constant would give a certificate with a computable and provably optimal loss factor.

**Sharpening the gap between the two certificates.** In the paired design the confirming and
refuting tests are exact negations of each other. For general fiber sizes there is a band of
populations decided by neither. Quantifying the width of that band as a function of the fiber size
profile — and designing a certificate family that closes it — is an open combinatorial
optimization problem.

**The angle formulation.** Theorem 3.6 makes the ceiling a squared cosine. Successive refinements
of the content map generate a nested family of subspaces and hence a nondecreasing sequence of
angles. Understanding the *rate* at which the angle decreases as the content is refined would turn
the ceiling from a single number into a curve, quantifying how much resolution in the content is
worth.

**Stochastic ceilings.** The present ceiling is deterministic and in-sample. A version with
sampling noise — a confidence interval on $\eta^2$ from fiber sizes and within-fiber variances —
would make the $1/2$ threshold a hypothesis test rather than a comparison, which is what a
practitioner with finitely many windows actually needs.

**Beyond squared error.** Everything here rests on the mean minimizing squared error. For absolute
error the minimizer is the median and the analogous "ceiling" is a dispersion about fiber medians;
for general Bregman divergences the conditional mean remains optimal, so the decomposition should
survive with $SS$ replaced by the divergence. Identifying exactly which loss functions admit an
exact within/between split, and hence a measurable ceiling, would extend the instrument well
beyond regression.

---

## 14. Conclusion

For discrete content, the maximum $R^2$ attainable by *any* function of that content is not an
object one must search for. It is the correlation ratio
$\eta^2 = 1 - SS_{\mathrm{within}}/SS_{\mathrm{tot}} = SS_{\mathrm{between}}/SS_{\mathrm{tot}}$,
attained by the tabulated conditional mean, which is the orthogonal projection onto the space of
content-measurable functions; the ceiling is the squared cosine of an angle, and the threshold
$1/2$ is $45°$. It is invariant under rescaling the responses, renaming the contents, and
replicating the population. It cannot be raised by depth. It can be lower-bounded from repeated
labels alone, exactly so when each label occurs twice, and this is precisely the regime in which
gap-based certification is complete. It can be upper-bounded — and hence the whole conjecture
refuted, with an explicit witness head — from within-label ranges alone.

Applied to the conjecture that motivated it, the instrument returns a verdict of unusual
precision: one clause true but conditional on a measurable certificate, one clause not a theorem
at all (every ceiling in $[0,1)$ occurs), and one clause false by four thousandths at its own
boundary, with the exact repair being the constant $0.4935$ and the salvaged guarantee $65\%$.
That is what a ceiling one can measure buys: not a better guess, but the end of guessing.
