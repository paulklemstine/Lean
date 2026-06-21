# The Normalization Map as a Natural Transformation into the Probability Simplex

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Novelty

## Abstract

We give a self-contained categorical account of two elementary but ubiquitous
operations on finite weight vectors: $\ell^1$-**normalization**, which sends a
nonnegative weight vector to a probability distribution by dividing by its total
mass, and **pushforward** (marginalization), which transports a weight vector
along a map of index sets by summing fibers. Working over a finite index type
$\iota$ and the standard probability simplex
$\Delta_\iota = \{\, p:\iota\to\mathbb{R} \mid p_i \ge 0,\ \sum_i p_i = 1 \,\}$,
we establish the following. (i) Pushforward is a covariant functor on weight
vectors: it preserves identities and composition, conserves total mass, and
therefore restricts to an endofunctor of the simplex. (ii) Normalization is an
idempotent, scale-invariant retraction of the nonnegative cone onto the simplex
that is the identity on the simplex. (iii) Normalization is a *natural
transformation* relating the pushforward functor on the cone to the pushforward
functor on the simplex: normalizing then marginalizing equals marginalizing then
normalizing. A deliberate design choice — adopting the convention $x/0 = 0$ so
that normalization is a *total* function — renders idempotence and naturality
*unconditional*, with positivity of the total mass needed only for simplex
membership. We give complete proof sketches, a discussion of the role of each
underlying summation identity, applications to statistics, machine learning, and
the renormalization-group philosophy of coarse-graining, and a set of precise
falsifiable conjectures for further development.

---

## 1. Introduction

The act of turning a list of nonnegative scores into a probability distribution
by "dividing by the sum" is one of the most frequently performed computations in
all of quantitative science. It appears as the final softmax-free normalization
layer of classifiers, as the conversion of counts to relative frequencies in
statistics, and as the formation of Gibbs/Boltzmann weights into a probability
measure in physics. Equally ubiquitous is *marginalization*: collapsing a
distribution over fine-grained outcomes into one over coarser categories by
summing the weights that land in each category.

Despite their familiarity, these two operations possess a clean and instructive
categorical structure that is rarely made explicit. The purpose of this paper is
to isolate that structure with full rigor and minimal machinery. Our central
claims are that marginalization is a *functor* and that normalization is a
*natural transformation* with respect to it. The naturality statement — that the
order of "make it a probability" and "change resolution" does not matter — is the
conceptual payoff, and it rests on nothing deeper than mass conservation and the
distributivity of division over finite sums.

Throughout, we fix finite index types and work over $\mathbb{R}$. Mathlib's
`stdSimplex ℝ ι` provides the ambient object. A noteworthy and deliberate
feature of our development is *totality*: by using the convention $x/0 = 0$, the
normalization map is defined on *all* weight vectors, including the degenerate
zero vector, which it sends to itself. This single choice makes the most useful
laws — idempotence and naturality — hold without any positivity hypothesis.

### 1.1 Notation and standing assumptions

Let $\iota, \kappa, \mu$ be finite types (`Fintype`), with $\kappa$ and $\mu$
additionally carrying decidable equality (needed so that the indicator
$[\,f(i)=k\,]$ in the pushforward is computable). A *weight vector* is a function
$v : \iota \to \mathbb{R}$. We write $\sum_i v_i$ for $\sum_{i \in \iota} v_i$
(a finite sum over the full finite type). The **probability simplex** is

$$
\Delta_\iota \;=\; \mathrm{stdSimplex}\,\mathbb{R}\,\iota
\;=\; \Big\{\, p : \iota \to \mathbb{R} \ \Big|\ (\forall i,\ 0 \le p_i)\ \wedge\ \textstyle\sum_i p_i = 1 \,\Big\}.
$$

The **nonnegative cone** is $C_\iota = \{\, v : \iota \to \mathbb{R} \mid \forall i,\ 0 \le v_i \,\}$.

---

## 2. Definitions

**Definition 2.1 (Normalization).**
The $\ell^1$-normalization of a weight vector $v : \iota \to \mathbb{R}$ is the
weight vector

$$
\mathrm{normalize}(v)_i \;=\; \frac{v_i}{\sum_{j} v_j}.
$$

By the convention $x/0 = 0$, this is *total*: when $\sum_j v_j = 0$ (in
particular when $v = 0$), $\mathrm{normalize}(v) = 0$.

**Definition 2.2 (Pushforward / marginalization).**
For a map of index types $f : \iota \to \kappa$ and a weight vector
$v : \iota \to \mathbb{R}$, the pushforward is the weight vector on $\kappa$

$$
\mathrm{pushforward}(f, v)_k \;=\; \sum_{i} \big[\, f(i) = k \,\big]\, v_i
\;=\; \sum_{i \,:\, f(i)=k} v_i,
$$

where $[\,P\,]$ denotes the indicator equal to $1$ when $P$ holds and $0$
otherwise. Equivalently, $\mathrm{pushforward}(f,v)$ is the image measure
(pushforward measure) of the discrete measure with weights $v$ under $f$.

---

## 3. Properties of normalization

We collect the algebraic laws governing $\mathrm{normalize}$. Each is stated as a
theorem with a proof sketch; the names in parentheses are the corresponding formal
results.

**Lemma 3.1 (Sum after normalization; `normalize_sum`).**
For every $v$,
$$
\sum_i \mathrm{normalize}(v)_i \;=\; \frac{\sum_i v_i}{\sum_j v_j}.
$$

*Proof.* Unfold the definition and pull the common denominator $\sum_j v_j$ out of
the finite sum using distributivity of division over a finite sum
(`Finset.sum_div`): $\sum_i (v_i / S) = (\sum_i v_i)/S$ with $S = \sum_j v_j$. $\square$

**Lemma 3.2 (Nonnegativity; `normalize_nonneg`).**
If $v_i \ge 0$ for all $i$, then $\mathrm{normalize}(v)_i \ge 0$ for all $i$.

*Proof.* The numerator $v_i$ is nonnegative by hypothesis and the denominator
$\sum_j v_j$ is a sum of nonnegative terms, hence nonnegative; a quotient of
nonnegatives is nonnegative (`div_nonneg`, `Finset.sum_nonneg`). $\square$

**Theorem 3.3 (Landing in the simplex; `normalize_mem_stdSimplex`).**
If $v_i \ge 0$ for all $i$ and $0 < \sum_j v_j$, then
$\mathrm{normalize}(v) \in \Delta_\iota$.

*Proof.* Nonnegativity of each coordinate is Lemma 3.2. For the sum constraint,
Lemma 3.1 gives $\sum_i \mathrm{normalize}(v)_i = (\sum_i v_i)/(\sum_j v_j) = 1$
since the total is nonzero (`div_self`). Hence the two simplex conditions hold. $\square$

**Theorem 3.4 (Identity on the simplex / retraction; `normalize_id_of_mem`).**
If $p \in \Delta_\iota$ then $\mathrm{normalize}(p) = p$.

*Proof.* Pointwise, $\mathrm{normalize}(p)_i = p_i / \sum_j p_j = p_i / 1 = p_i$,
using the simplex sum constraint $\sum_j p_j = 1$ and $x/1 = x$ (`div_one`). $\square$

**Theorem 3.5 (Idempotence; `normalize_idem`).**
For every $v$ (with no hypotheses),
$\mathrm{normalize}(\mathrm{normalize}(v)) = \mathrm{normalize}(v)$.

*Proof.* Split on whether the total $\sum_j v_j$ vanishes. If it does, then
$\mathrm{normalize}(v) = 0$ (each coordinate is $v_i/0 = 0$), and normalizing the
zero vector again yields $0$; both sides agree. If the total is nonzero, Lemma 3.1
gives $\sum_i \mathrm{normalize}(v)_i = (\sum_i v_i)/(\sum_j v_j) = 1$, so the
inner normalization already lies in the simplex; applying $\mathrm{normalize}$ to a
vector whose coordinates sum to $1$ divides by $1$ and returns it unchanged. Thus
both branches give equality, unconditionally. $\square$

**Theorem 3.6 (Scale invariance / projectivity; `normalize_smul`).**
For every nonzero scalar $c$ and every $v$,
$\mathrm{normalize}(c \cdot v) = \mathrm{normalize}(v)$.

*Proof.* Pointwise,
$\mathrm{normalize}(c\cdot v)_i = (c\,v_i) / \sum_j (c\,v_j) = (c\,v_i)/(c\sum_j v_j)$
by pulling the constant out of the finite sum (`Finset.mul_sum`); the common
nonzero factor $c$ cancels (`mul_div_mul_left`), leaving
$v_i / \sum_j v_j = \mathrm{normalize}(v)_i$. $\square$

Theorems 3.4–3.6 jointly express that $\mathrm{normalize}$ is an idempotent
retraction of the cone onto the simplex that factors through the projectivization
of the cone (it depends only on the ray $\mathbb{R}_{>0}\cdot v$, not on $v$
itself).

---

## 4. Functoriality of pushforward

**Theorem 4.1 (Mass preservation; `pushforward_mass`).**
For every $f : \iota \to \kappa$ and $v$,
$$
\sum_k \mathrm{pushforward}(f, v)_k \;=\; \sum_i v_i.
$$

*Proof.* Expand the definition and exchange the order of the double sum
(`Finset.sum_comm`):
$\sum_k \sum_i [\,f(i)=k\,] v_i = \sum_i \sum_k [\,f(i)=k\,] v_i$. For each fixed
$i$, the inner sum over $k$ has exactly one nonzero term, namely $k = f(i)$,
contributing $v_i$ (`Finset.sum_ite_eq'`). Summing over $i$ gives $\sum_i v_i$. $\square$

**Theorem 4.2 (Identity law; `pushforward_id`).**
For every $v$, $\mathrm{pushforward}(\mathrm{id}, v) = v$.

*Proof.* For each $k$, $\mathrm{pushforward}(\mathrm{id},v)_k = \sum_i [\,i=k\,] v_i = v_k$,
since the one-hot indicator collapses the sum to the single term $i=k$
(`Finset.sum_ite_eq'`). $\square$

**Theorem 4.3 (Composition law; `pushforward_comp`).**
For $f : \iota \to \kappa$ and $g : \kappa \to \mu$ and every $v$,
$$
\mathrm{pushforward}(g \circ f, v) \;=\; \mathrm{pushforward}\big(g, \mathrm{pushforward}(f, v)\big).
$$

*Proof.* Both sides, evaluated at $m \in \mu$, sum $v_i$ over the fiber
$\{ i \mid g(f(i)) = m \}$. On the right, this fiber is reorganized as a disjoint
union over intermediate values $k \in \kappa$ with $g(k) = m$ of the sub-fibers
$\{ i \mid f(i) = k\}$. The bijection $i \mapsto (f(i), i)$ between the fine fiber
and the indexed disjoint union (`Finset.sum_sigma'`, `Finset.sum_bij`) shows the
two sums are equal term by term. $\square$

**Theorem 4.4 (Pushforward preserves the simplex; `pushforward_mem_stdSimplex`).**
If $p \in \Delta_\iota$ then $\mathrm{pushforward}(f, p) \in \Delta_\kappa$.

*Proof.* Each coordinate $\mathrm{pushforward}(f,p)_k = \sum_{i:f(i)=k} p_i$ is a
sum of nonnegative terms, hence nonnegative (`Finset.sum_nonneg`). The total is
preserved by Theorem 4.1, so $\sum_k \mathrm{pushforward}(f,p)_k = \sum_i p_i = 1$.
Both simplex conditions hold. $\square$

Theorems 4.2–4.4 say that $\mathrm{pushforward}$ is a covariant functor on weight
vectors (object map $v \mapsto \mathrm{pushforward}(f,v)$ for each morphism $f$ of
index types) that conserves mass and therefore restricts to an *endofunctor of the
probability simplex*.

---

## 5. The naturality square

**Theorem 5.1 (Naturality of normalization; `normalize_pushforward`).**
For every $f : \iota \to \kappa$ and every $v : \iota \to \mathbb{R}$ (no
hypotheses),
$$
\mathrm{normalize}\big(\mathrm{pushforward}(f, v)\big)
\;=\;
\mathrm{pushforward}\big(f, \mathrm{normalize}(v)\big).
$$

*Proof.* Fix $k \in \kappa$. The left-hand side is
$\mathrm{pushforward}(f,v)_k \big/ \sum_{k'} \mathrm{pushforward}(f,v)_{k'}$.
By mass preservation (Theorem 4.1), the denominator equals $\sum_j v_j$; call it
$S$. So the left side is $\big(\sum_{i:f(i)=k} v_i\big) / S$. The right-hand side is
$\sum_{i:f(i)=k} (v_i / S)$. These are equal by distributivity of division over a
finite sum (`Finset.sum_div`): $\big(\sum_{i} g_i\big)/S = \sum_i (g_i/S)$ applied
to the indicator-weighted summands. The argument is uniform in the degenerate case
$S = 0$, where both sides collapse to $0$. $\square$

The naturality square is the conceptual climax: it states that the diagram

$$
\begin{array}{ccc}
v & \xrightarrow{\ \mathrm{pushforward}(f,-)\ } & \mathrm{pushforward}(f,v) \\[2pt]
\downarrow{\scriptstyle \mathrm{normalize}} & & \downarrow{\scriptstyle \mathrm{normalize}} \\[2pt]
\mathrm{normalize}(v) & \xrightarrow{\ \mathrm{pushforward}(f,-)\ } & \mathrm{pushforward}(f,\mathrm{normalize}(v))
\end{array}
$$

commutes for every morphism $f$. In categorical language, $\mathrm{normalize}$ is
a natural transformation from the pushforward functor on the cone to the
pushforward functor on the simplex.

---

## 6. The role of totality (the $x/0 = 0$ convention)

A central design decision is to make $\mathrm{normalize}$ a *total* function via
the convention that division by zero returns zero. The consequences are sharp and
worth isolating:

- **Idempotence (Theorem 3.5) and naturality (Theorem 5.1) hold unconditionally.**
  In the degenerate case $\sum_j v_j = 0$, both sides of each identity reduce to
  the zero vector, so no positivity hypothesis is required. This is the cleanest
  possible form of these laws.
- **Only simplex membership (Theorem 3.3) requires $0 < \sum_j v_j$.** This is
  *necessary*, not an artifact: the simplex constraint $\sum_i p_i = 1$ can never
  be satisfied by the zero vector, so some nondegeneracy hypothesis is unavoidable
  precisely here and nowhere else.

This separation — totality everywhere, positivity only where the simplex constraint
forces it — is what gives the theory its uniform, hypothesis-light character.

---

## 7. Underlying summation identities

The entire development reduces to a small toolkit of finite-summation identities,
each playing a precise role:

- **`Finset.sum_div`** ($\sum_i (g_i/c) = (\sum_i g_i)/c$): pulls a common
  denominator out of a sum. It powers the mass-$1$ computation (Lemma 3.1,
  Theorem 3.3) and the naturality square (Theorem 5.1).
- **`Finset.sum_comm`** (exchange of summation order): yields mass preservation
  (Theorem 4.1) and underpins composition (Theorem 4.3).
- **`Finset.sum_ite_eq'`** (collapse of a one-hot indicator sum): yields the
  identity law (Theorem 4.2) and the per-index evaluation in mass preservation.
- **`Finset.mul_sum`** and **`mul_div_mul_left`**: cancel a common scalar factor,
  giving scale invariance (Theorem 3.6).
- **`Finset.sum_sigma'` / `Finset.sum_bij`** (reindexing a fibered sum): give the
  composition law (Theorem 4.3).

Notably, after invoking mass preservation, the naturality square reduces to the
single scalar identity $\big(\sum_i g_i\big)/c = \sum_i (g_i/c)$.

---

## 8. Applications

**Machine learning.** Classifier outputs are normalized score vectors. Scale
invariance (Theorem 3.6) characterizes the redundancy of un-normalized logits up
to positive scaling; idempotence (Theorem 3.5) guarantees that repeated
normalization layers are stable. The retraction property (Theorem 3.4) means that
already-normalized probability vectors pass through normalization unchanged.

**Statistics.** Pushforward is the marginal distribution. The naturality law
(Theorem 5.1) is the formal justification for the everyday practice of computing
relative frequencies and forming marginals in either order: aggregate-then-normalize
equals normalize-then-aggregate. Mass preservation (Theorem 4.1) is conservation
of total count under regrouping.

**Statistical physics / renormalization.** Coarse-graining microscopic degrees of
freedom by summing them out is exactly $\mathrm{pushforward}$. Mass preservation
is conservation of probability under coarse-graining; naturality is the statement
that the normalizing partition function transforms consistently, so the
coarse-grained Gibbs measure is the normalization of the coarse-grained weights.

**Category theory and functional programming.** The pair (functor, natural
transformation) is the abstract template for "uniform, choice-free constructions."
Recognizing normalization as natural certifies that it commutes with all
relabelings and coarsenings of the outcome space, not as a coincidence but as a
structural property.

---

## 9. Algorithms

We summarize the two operations as algorithms; both run in linear time in the
number of fine outcomes.

**Algorithm A (Normalize).** Input: weight vector $v$ of length $n$.
Compute $S \leftarrow \sum_i v_i$. If $S = 0$, return the zero vector (totality
convention). Otherwise return $(v_i / S)_i$. Complexity $O(n)$ time, $O(n)$ space.

**Algorithm B (Pushforward).** Input: map $f : \{1,\dots,n\} \to \{1,\dots,m\}$
and weights $v$. Initialize an accumulator $w$ of length $m$ to zero. For each
fine index $i$, add $v_i$ to $w_{f(i)}$. Return $w$. Complexity $O(n + m)$ time,
$O(m)$ space.

Composing the two (in either order) realizes the naturality square and provides a
numerical consistency check (see the accompanying demonstrations).

---

## 10. Discussion and future work

The results above package a piece of universally used arithmetic as a small,
self-certifying categorical theory. The deliberate use of totality keeps the laws
hypothesis-light, and the entire structure rests on elementary finite-sum
identities. We record five precise, falsifiable conjectures for further
development.

**C1. Affineness of normalization on rays through a fixed reference.** For
nonnegative $u, v$ with positive total mass and $t \in [0,1]$,
$\mathrm{normalize}(t\,u + (1-t)\,v)$ lies on the projective segment between
$\mathrm{normalize}(u)$ and $\mathrm{normalize}(v)$: there is $s \in [0,1]$ with
$\mathrm{normalize}(t u + (1-t)v) = s\,\mathrm{normalize}(u) + (1-s)\,\mathrm{normalize}(v)$,
where $s = t\|u\|_1 / (t\|u\|_1 + (1-t)\|v\|_1)$.

**C2. Pushforward of an extreme point is an extreme point.** $\mathrm{pushforward}(f)$
maps vertices (Dirac masses $e_i$) of $\Delta_\iota$ to vertices of $\Delta_\kappa$:
$\mathrm{pushforward}(f, e_i) = e_{f(i)}$. More strongly, pushforward sends extreme
points to extreme points and is affine, hence determined by its action on vertices.

**C3. Contraction under total-variation / $\ell^1$ distance.** Pushforward is
$\ell^1$-nonexpansive on the simplex:
$\sum_k |\mathrm{pushforward}(f,p)_k - \mathrm{pushforward}(f,q)_k| \le \sum_i |p_i - q_i|$
for all $p,q \in \Delta_\iota$ (data-processing inequality for total variation),
with strict contraction iff $f$ is non-injective on the support.

**C4. Naturality extends to entropy/KL.** Shannon entropy satisfies
$H(\mathrm{pushforward}(f,p)) \ge H(p)$ (coarse-graining never decreases entropy),
with equality iff $f$ is injective on $\mathrm{supp}\,p$; dually, KL divergence is
monotone under pushforward:
$\mathrm{KL}(\mathrm{pushforward}(f,p)\,\|\,\mathrm{pushforward}(f,q)) \le \mathrm{KL}(p\|q)$.

**C5. Universal property: normalization as a reflector.** $\mathrm{normalize}$ is
the unit of a reflection (left adjoint) from the nonnegative cone modulo positive
scaling onto the simplex; scale-invariant maps factor uniquely through
$\mathrm{normalize}$. The proved laws `normalize_idem`, `normalize_id_of_mem`, and
`normalize_smul` are the supporting structure.

---

## 11. Conclusion

We have shown that two of the most elementary operations of applied probability —
$\ell^1$-normalization and marginalization — carry a clean categorical structure:
marginalization is a mass-preserving endofunctor of the probability simplex, and
normalization is an idempotent, scale-invariant retraction onto the simplex that is
natural with respect to marginalization. The totality convention $x/0=0$ makes the
key laws unconditional, leaving positivity required only where the simplex
constraint genuinely demands it. The whole theory rests on a handful of finite-sum
identities, yet it crystallizes a structural pattern that recurs across statistics,
machine learning, and statistical physics.
