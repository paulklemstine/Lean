# An Exact, Convexity-Free Contraction Principle for Idempotent Large Deviations

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Tropical / Idempotent Probability

## Abstract

We develop a large-deviation theory for max-plus (idempotent) probability measures
on finite types and prove an exact **contraction principle**, the idempotent
analogue of the classical contraction principle of large-deviation theory. In the
idempotent setting a probability law is a weight function $w : X \to \mathbb{R}$
with $\max_x w(x) = 0$ and $w \le 0$; its rate function is $I_X(x) = -w(x) \ge 0$,
and the deviation cost of an event $A$ is $\min_{x\in A} I_X(x)$. We show that this
furnishes a *sharp* large-deviation principle valid for every finite law without
any limiting procedure. Building on it, given a surjection $T : X \to Y$ we define
the push-forward law $w_Y(y) = \max_{x : T(x)=y} w(x)$ and prove (i) the
push-forward of an idempotent probability is an idempotent probability; (ii) its
rate function is the fiber-wise infimum $I_Y(y) = \min_{x : T(x)=y} I_X(x)$; and
(iii) the deviation cost of any non-empty event $B \subseteq Y$ equals the cost of
its preimage, $\min_{y\in B} I_Y(y) = \min_{x \in T^{-1}(B)} I_X(x)$, equivalently
$\mu_Y(B) = \mu_X(T^{-1}(B))$. The argument is purely order-theoretic and requires
no convexity. We contrast this with the Legendre–Fenchel half of the idempotent
Cramér program, which is genuinely convexity-sensitive: we exhibit an explicit
non-convex law on three points whose double Legendre–Fenchel transform
underestimates the rate function by exactly $2$. All results are formally verified.

---

## 1. Introduction

Classical large-deviation theory quantifies the exponentially small probabilities
of rare events. For a sequence of empirical means $S_n/n$ of i.i.d. random
variables, Cramér's theorem states
$$\lim_{n\to\infty}\tfrac1n \log \mathbb{P}\!\left(\tfrac{S_n}{n}\in A\right) = -\inf_{a\in A} I(a),$$
where the rate function $I$ is the Legendre–Fenchel transform of the cumulant
generating function $\Lambda(\lambda) = \log \mathbb{E}[e^{\lambda X}]$. Two
structural pillars support the theory: the **contraction principle**, which
transports a large-deviation principle through a continuous map by infimizing the
rate over fibers, and **Cramér duality**, which identifies the rate function as a
convex conjugate.

Maslov's idempotent analysis replaces the field operations $(+,\times)$ by the
max-plus semiring operations $(\max, +)$, realized as the zero-temperature
("dequantization") limit of ordinary probability under the map $p \mapsto \lim_{T\to 0} T\log p$.
Under this limit, summation collapses to maximization and the entire apparatus of
large deviations becomes an *exact*, finite calculus. The purpose of this paper is
to carry the two structural pillars of Cramér's program into the idempotent world
and to isolate precisely which one depends on convexity.

Our main contribution is an exact, convexity-free **idempotent contraction
principle** (Section 4). Its core is a single order-theoretic identity — that a
minimum over a preimage equals the minimum over the base of the fiber-wise minima
— which we isolate as Lemma `inf'_fiber_eq`. We complement it (Section 5) with a
sharp counterexample showing that the dual half of the program genuinely fails
without convexity, with an exactly computed duality gap.

All definitions and theorems below are formalized in Lean 4 / Mathlib; we cite the
formal names throughout and give mathematical proof sketches rather than formal
scripts.

---

## 2. The idempotent probability framework

Throughout, $X$ and $Y$ denote finite, non-empty types.

**Definition 1 (`MaxPlusMeasure`).** A *max-plus measure* on $X$ is a function
$w : X \to \mathbb{R}$ assigning a real weight to each outcome. The measure of a
non-empty event $A \subseteq X$ is $\mu(A) = \max_{x\in A} w(x)$.

**Definition 2 (`IsTropicalProbability`).** A max-plus measure $w$ is a *tropical
(idempotent) probability* if
$$\max_{x\in X} w(x) = 0 \qquad\text{and}\qquad w(x) \le 0 \text{ for all } x.$$
The first condition is the idempotent normalization (the "total mass" is the
multiplicative unit $0$); the second says every outcome is at most as likely as the
most likely one.

**Definition 3 (`maxPlusIntegral`).** The *max-plus integral* of an observable
$f : X \to \mathbb{R}$ against $w$ is
$$\int^{\!+} f\,dw \;=\; \max_{x\in X}\bigl(f(x) + w(x)\bigr).$$
It is monotone in $f$, satisfies the shift identity $\int^{\!+}(f+c) = \int^{\!+} f + c$,
and (`maxPlusIntegral_attained`) attains its value at a concrete maximizer
$x_0 \in X$ with $\int^{\!+} f\,dw = f(x_0)+w(x_0)$.

**Definition 4 (`idempotentRate`).** The *rate function* of a max-plus measure is
$$I_X(x) \;=\; -w(x).$$
For a tropical probability, $I_X \ge 0$ and $\min_x I_X(x) = 0$: the rate is a
non-negative deviation cost vanishing at the most likely outcome(s).

The reading is dictated by dequantization: $w(x) = \lim_{T\to 0} T\log p_T(x)$
plays the role of $-I_X(x)$, so events of cost $I$ have idempotent "probability"
$e^{-I/T}$ as $T \to 0$. The **deviation cost** of an event $A$ is
$$\mathrm{cost}(A) \;=\; -\mu(A) \;=\; -\max_{x\in A} w(x) \;=\; \min_{x\in A} I_X(x).$$

### 2.1 The sharp idempotent large-deviation principle

**Theorem 1 (Sharp idempotent LDP, `idempotent_ldp_sharp`).** For every max-plus
measure $w$ and every non-empty event $A \subseteq X$,
$$-\max_{x\in A} w(x) \;=\; \min_{x\in A} I_X(x).$$

*Proof sketch.* Both sides are the negation of the same finite optimum:
$\min_{x\in A} I_X(x) = \min_{x\in A}(-w(x)) = -\max_{x\in A} w(x)$. Formally one
proves the two inequalities by `le_antisymm`; the maximizer exists because $A$ is a
non-empty finite set (`Finset.exists_max_image`). $\square$

The content is conceptual rather than computational: the *exact* deviation cost of
a rare event equals the minimum cost over the ways it can occur, with no $\log$,
no $\exp$, and no $n\to\infty$ limit. In classical large deviations this is only an
asymptotic statement; idempotency removes the smoothing and makes it an identity.
Theorem 1 is the engine behind the contraction principle of Section 4.

---

## 3. The idempotent Cramér structure

**Definition 5 (`idempotentCGF`).** The *idempotent cumulant generating function*
of an observable $\mathrm{val} : X \to \mathbb{R}$ under $w$ is
$$\Lambda(\lambda) \;=\; \int^{\!+}(\lambda\cdot\mathrm{val})\,dw \;=\; \max_{x\in X}\bigl(\lambda\,\mathrm{val}(x) + w(x)\bigr).$$

This is the idempotent analogue of $\tfrac1n\log\mathbb{E}[e^{\lambda S_n}]$. We
record the structural facts that mirror the classical theory; all are formally
verified.

**Theorem 2 (Convexity, `idempotentCGF_convex`).** $\Lambda$ is convex on
$\mathbb{R}$. *Sketch.* $\Lambda$ is a finite pointwise maximum of the affine maps
$\lambda \mapsto \lambda\,\mathrm{val}(x) + w(x)$, hence convex. $\square$

**Theorem 3 (Additivity under independence, `idempotentCGF_add`).** For the product
law $w_1\boxplus w_2$ on $X\times Y$ with weight $(x,y)\mapsto w_1(x)+w_2(y)$ and
the additive observable $(x,y)\mapsto \mathrm{val}_X(x)+\mathrm{val}_Y(y)$,
$$\Lambda_{X\times Y}(\lambda) = \Lambda_X(\lambda) + \Lambda_Y(\lambda).$$
*Sketch.* A finite maximum of a separable function over a product splits as the sum
of the marginal maxima (`sup'_prod_add`). This is the idempotent echo of
$\mathbb{E}[e^{\lambda(X+Y)}]=\mathbb{E}[e^{\lambda X}]\,\mathbb{E}[e^{\lambda Y}]$
for independent $X,Y$. $\square$

**Theorem 4 (Random-walk scaling, `idempotentCGF_walk`).** For the $n$-step
max-plus random walk with path weight $\omega\mapsto \sum_{i} w(\omega_i)$ and total
displacement $S_n(\omega)=\sum_i \mathrm{val}(\omega_i)$,
$$\Lambda_n(\lambda) \;=\; n\,\Lambda(\lambda).$$
*Sketch.* The maximum of a coordinate-separable sum over a function space
$\mathrm{Fin}\,n \to X$ is the sum of the per-coordinate maxima (`sup'_pi_sum`);
each coordinate contributes $\Lambda(\lambda)$. $\square$

**Theorem 5 (Idempotent Chernoff bound, `idempotent_chernoff`).** For $\lambda\ge0$
and any $x$ with $\mathrm{val}(x)\ge a$,
$$w(x) \;\le\; \Lambda(\lambda) - \lambda a.$$
*Sketch.* $\lambda\,\mathrm{val}(x)+w(x) \le \Lambda(\lambda)$ by definition of the
max; since $\lambda\ge0$ and $\mathrm{val}(x)\ge a$, $\lambda a \le \lambda\,\mathrm{val}(x)$,
and rearranging gives the bound. Optimizing over $\lambda$ recovers the classical
exponential-tail estimate. $\square$

### 3.1 Legendre–Fenchel duality (the convexity-sensitive half)

**Lemma 6 (Fenchel–Young, `fenchel_young_rate`).** For all $\lambda$ and $x$,
$\lambda\,\mathrm{val}(x) - \Lambda(\lambda) \le I_X(x)$.

**Definition 6 (`lfBiconj`).** The Legendre–Fenchel biconjugate of the rate
function at level $a$ is
$$I^{**}(a) \;=\; \sup_{\lambda\in\mathbb{R}} \bigl(\lambda a - \Lambda(\lambda)\bigr).$$

**Theorem 7 (Weak duality, `lfBiconj_le_rate`).** $I^{**}(\mathrm{val}(x)) \le I_X(x)$
for all $x$. *Sketch.* Take the supremum over $\lambda$ of Lemma 6. $\square$

**Theorem 8 (Cramér equality under support, `lfBiconj_eq_rate_of_support`).** If a
supporting line exists at $x$ — a slope $\lambda$ with $I_X(x) = \lambda\,\mathrm{val}(x)-\Lambda(\lambda)$
— then $I^{**}(\mathrm{val}(x)) = I_X(x)$.

Theorem 8 makes equality conditional on convex support. Section 5 shows the
condition is genuinely necessary.

---

## 4. The idempotent contraction principle (main results)

Fix a surjection $T : X \to Y$ between finite non-empty types and a tropical
probability $w$ on $X$ with rate $I_X$.

**Definition 7 (`fiber`, `preimageEvent`).** For $y\in Y$ the *fiber* is
$T^{-1}(y) = \{x\in X : T(x)=y\}$; for an event $B\subseteq Y$ the *preimage event*
is $T^{-1}(B) = \{x\in X : T(x)\in B\}$. When $T$ is surjective every fiber is
non-empty (`fiber_nonempty`), so all infima below are well-defined; this is where
surjectivity is load-bearing.

**Lemma 9 (Fibration of the preimage, `preimageEvent_eq_biUnion`).**
$T^{-1}(B) = \bigcup_{y\in B} T^{-1}(y)$, the disjoint union of the fibers over $B$.

**Lemma 10 (Fibration identity for finite infima, `inf'_fiber_eq`).** For any
$f : X\to\mathbb{R}$, any surjection $T$, and any non-empty $B\subseteq Y$,
$$\min_{x\in T^{-1}(B)} f(x) \;=\; \min_{y\in B}\;\Bigl(\min_{x\in T^{-1}(y)} f(x)\Bigr).$$
*Sketch.* By Lemma 9 the index set $T^{-1}(B)$ is the union of fibers over $B$;
the claim is then the instance `Finset.inf'_biUnion` of the general fact that a
minimum over a union of blocks equals the minimum over blocks of the within-block
minima. This is the order-theoretic heart of the contraction principle, and it uses
no convexity, no metric, and no probabilistic structure. $\square$

**Definition 8 (`pushforwardMeasure`).** The *push-forward* of $w$ along $T$ is the
max-plus measure on $Y$ with
$$w_Y(y) \;=\; \max_{x \,:\, T(x)=y} w(x).$$
Every $x$ lies in the fiber over $T(x)$, so $w(x) \le w_Y(T(x))$
(`le_pushforward_weight`).

**Theorem 11 (Push-forward of a probability, `pushforwardMeasure_isProb`).** If $w$
is a tropical probability on $X$, then $w_Y$ is a tropical probability on $Y$.

*Proof sketch.* *Non-positivity:* each fiber maximum is a maximum of values
$w(x)\le 0$, hence $\le 0$. *Normalization:* surjectivity makes the fibers partition
$X$, so $\max_{y\in Y} w_Y(y) = \max_{y}\max_{x: T(x)=y} w(x) = \max_{x\in X} w(x) = 0$.
Concretely, choosing a global maximizer $x_0$ of $w$ (which has $w(x_0)=0$) shows
$w_Y(T(x_0)) \ge 0$, while non-positivity gives the reverse. $\square$

**Theorem 12 (Contraction of the rate function, `pushforward_rate`).** The rate
function of the push-forward is the fiber-wise minimum of $I_X$:
$$I_Y(y) \;=\; \min_{x \,:\, T(x)=y} I_X(x).$$
*Proof sketch.* By definition $I_Y(y) = -w_Y(y) = -\max_{x: T(x)=y} w(x)$. Applying
the sharp idempotent LDP (Theorem 1) to the non-empty fiber $A = T^{-1}(y)$ turns
this into $\min_{x\in T^{-1}(y)}(-w(x)) = \min_{x\in T^{-1}(y)} I_X(x)$. $\square$

**Theorem 13 (Idempotent contraction principle — rate form, `idempotent_contraction`).**
For every non-empty event $B\subseteq Y$,
$$\min_{y\in B} I_Y(y) \;=\; \min_{x\in T^{-1}(B)} I_X(x).$$

*Proof sketch.* Substitute the contraction of the rate function (Theorem 12) into
the left-hand side:
$$\min_{y\in B} I_Y(y) \;=\; \min_{y\in B}\Bigl(\min_{x\in T^{-1}(y)} I_X(x)\Bigr).$$
By the fibration identity (Lemma 10) the right-hand side equals
$\min_{x\in T^{-1}(B)} I_X(x)$. $\square$

**Theorem 14 (Idempotent contraction principle — measure/cost form,
`idempotent_contraction_measure`).** For every non-empty event $B\subseteq Y$,
$$\mu_Y(B) \;=\; \mu_X\bigl(T^{-1}(B)\bigr), \qquad\text{equivalently}\qquad -\mu_Y(B) = -\mu_X(T^{-1}(B)).$$
*Sketch.* Negate Theorem 13 and use $\mu(A) = -\mathrm{cost}(A)$ (the sharp LDP,
Theorem 1) on both $B$ and $T^{-1}(B)$. $\square$

**Remark (no convexity).** Theorems 11–14 use only the lattice/order structure of
the reals and the partition-into-fibers property of a surjection. No convexity,
metric, or differentiability hypothesis appears anywhere. This is the precise sense
in which the contraction half of the idempotent Cramér program is convexity-free,
in sharp contrast to the duality half of Section 5.

### 4.1 A fully worked example

We instantiate Theorems 11–14 on a small but non-injective summary map so that the
bookkeeping can be checked by hand. Let the detailed space be
$X = \{a,b,c,d,e\}$ with weights
$$w(a)=0,\quad w(b)=-1,\quad w(c)=-3,\quad w(d)=-2,\quad w(e)=-5,$$
so $w$ is a tropical probability ($\max w = 0$, $w\le0$) and the detailed rate is
$I_X = (0,1,3,2,5)$. Let the observed space be $Y = \{0,1,2\}$ with the surjection
$$T(a)=0,\ T(b)=0,\ T(c)=1,\ T(d)=1,\ T(e)=2,$$
so the fibers are $T^{-1}(0)=\{a,b\}$, $T^{-1}(1)=\{c,d\}$, $T^{-1}(2)=\{e\}$.

The push-forward weights (Definition 8) are the fiber maxima
$$w_Y(0)=\max(0,-1)=0,\quad w_Y(1)=\max(-3,-2)=-2,\quad w_Y(2)=-5,$$
so $\max_y w_Y(y)=0$ and $w_Y\le0$: the push-forward is a tropical probability,
confirming Theorem 11. Its rate is $I_Y=(0,2,5)$, and indeed each value is the
fiber-wise minimum of $I_X$ — $\min(0,1)=0$, $\min(3,2)=2$, $\min(5)=5$ — exactly
as Theorem 12 asserts.

Now test the contraction principle (Theorem 13) on the event $B=\{1,2\}$. Upstairs
its cost is $\min(I_Y(1),I_Y(2))=\min(2,5)=2$. Its preimage is
$T^{-1}(B)=\{c,d,e\}$, whose cost downstairs is $\min(I_X(c),I_X(d),I_X(e))=\min(3,2,5)=2$.
The two agree, and the measure form (Theorem 14) reads
$\mu_Y(B)=\max(-2,-5)=-2=\max(-3,-2,-5)=\mu_X(T^{-1}(B))$. The same identity holds
for each of the seven non-empty subsets of $Y$ — an exhaustive numerical check is
included in the accompanying demonstration code. The cheapest way to deviate into
an observed event, computed upstairs, is always exactly the cheapest microscopic
way to realize it, computed downstairs.

---

## 5. The Legendre–Fenchel duality gap (sharpness of Theorem 8)

To show the convexity hypothesis in Theorem 8 is essential, we exhibit an explicit
non-convex idempotent law and compute its duality gap exactly.

**Construction (`gapVal`, `gapMeasure`).** On $X = \{0,1,2\}$ take the observable
$\mathrm{val}(i)=i$ and the weights
$$w = (0,\,-2,\,0), \qquad\text{so}\qquad I_X = (0,\,2,\,0).$$
This $w$ is a tropical probability (`gapMeasure_isProb`): $\max w = 0$ and $w\le0$.

**Non-convexity (`gapRate_nonconvex`).** The midpoint value exceeds the average of
the endpoint values,
$$\tfrac{I_X(0)+I_X(2)}{2} = 0 \;<\; 2 = I_X(1),$$
so $I_X$ is a spike above the chord joining its endpoints — the antithesis of
convex.

**Key bound (`gap_lam_le_cgf`).** The cumulant generating function is
$\Lambda(\lambda) = \max(0,\,\lambda - 2,\,2\lambda)$, and one checks
$\lambda \le \Lambda(\lambda)$ for every $\lambda$ (use $x=2$ when $\lambda\ge0$ and
$x=0$ when $\lambda<0$). Consequently $\lambda\cdot 1 - \Lambda(\lambda) \le 0$ for
every slope: no supporting line can rise to the tip of the spike at
$\mathrm{val}=1$.

**Theorem 15 (Biconjugate collapses the spike, `gap_lfBiconj_mid`).**
$I^{**}(\mathrm{val}(1)) = 0$. *Sketch.* By the key bound every admissible value
$\lambda\cdot 1 - \Lambda(\lambda)$ is $\le 0$, and the value $0$ is attained at
$\lambda=0$ (where $\Lambda(0)=0$); hence the supremum is exactly $0$. $\square$

**Theorem 16 (Strict duality gap, `strict_duality_gap`; value `duality_gap_value`).**
$$I^{**}(\mathrm{val}(1)) = 0 \;<\; 2 = I_X(1), \qquad I_X(1) - I^{**}(\mathrm{val}(1)) = 2.$$

The gap of $2$ equals the height of the non-convex spike above its chord: the
double Legendre–Fenchel transform replaces the rate function by its convex lower
envelope, flattening the spike to the chord value $0$. This refutes the
over-general conjecture that the double transform always recovers the idempotent
rate function and shows the supporting-line hypothesis of Theorem 8 is necessary —
and never vacuous.

---

## 6. Discussion: a clean split of Cramér's program

Sections 4 and 5 together isolate the structural anatomy of the idempotent Cramér
program. It splits into two halves of opposite character:

- **Convexity-free half (contraction).** Transporting a large-deviation principle
  through a summary map $T$ is *exact* and requires only order structure. The
  push-forward of a probability is a probability (Theorem 11), its rate contracts
  fiber-wise (Theorem 12), and the cost of an event equals the cost of its preimage
  (Theorems 13–14). The single load-bearing fact is the fibration identity
  (Lemma 10).

- **Convexity-sensitive half (duality).** Recovering the rate function as a convex
  conjugate holds only under a supporting-line/convexity hypothesis (Theorem 8) and
  fails by an exactly computable amount otherwise (Theorem 16).

The dividing line is conceptually clean: convexity entered the theory solely
through the Legendre transform, and the contraction principle never touches it.
This is invisible in the classical theory, where both halves are entangled in the
same limiting estimates; idempotency dissolves the entanglement and lays the two
mechanisms bare.

### 6.1 Applications

Max-plus models govern worst-case and dominant-term phenomena: makespan in parallel
pipelines (finish time = max over stages, cost adds along a path), shortest/longest
paths in weighted networks (min-plus dual), zero-temperature limits in statistical
mechanics, and hard-max scoring in machine learning. In each case the contraction
principle answers a recurring question — how the worst-case cost of an *observed*
(summary-level) event relates to the worst-case cost of the *detailed* events
behind it — with the exact answer "they are equal," plus the explicit fiber-wise
recipe $I_Y(y) = \min_{x: T(x)=y} I_X(x)$ for the summary-level cost.

---

### 6.2 Relation to the classical contraction principle

In the classical theory the contraction principle states that if $\{\mu_n\}$ obeys a
large-deviation principle with rate $I_X$ and $T$ is continuous, then $\{T_*\mu_n\}$
obeys one with rate $I_Y(y) = \inf_{x : T(x)=y} I_X(x)$. The proof requires a
two-sided argument: a lower bound from open sets and an upper bound from compact
sets, both surviving the $n\to\infty$ limit, together with regularity hypotheses on
$T$ and the rate function. The idempotent counterpart proved here (Theorems 11–14)
dispenses with all of this. There is no sequence, no topology beyond the finite
discrete one, and no limit; the fiber-wise infimum formula for the rate is not an
asymptotic conclusion but a direct computation, and the event-cost identity is an
equality rather than a matching pair of bounds. The price of this simplicity is
that the idempotent law is itself the dequantized object: it already encodes the
$n\to\infty$ scaling through the linearity of the random-walk CGF (Theorem 4), so
the contraction principle operates one level up, on the limiting rate structure
directly.

### 6.3 Formalization notes

All statements are mechanically checked. The framework lives on finite, non-empty
types, with events represented as non-empty finite sets so that maxima and minima
are attained and the rate function is everywhere finite. Surjectivity of $T$ is the
only genuine hypothesis of the contraction theorems; it guarantees non-empty fibers,
without which the fiber-wise minimum would be a minimum over an empty set. The proof
of the central Lemma 10 is an instance of the general identity that an extremum over
a union of blocks equals the extremum over blocks of within-block extrema, and the
sharp LDP (Theorem 1) is what converts maxima of weights into minima of rates at
each step. No step appeals to numerical decision procedures for the general
theorems; only the explicit three-point duality-gap example is computed concretely.

## 7. Future work

This development extends a formalized idempotent large-deviation theory. Two natural
directions stand out.

**Idempotent Varadhan integral lemma.** Conjecturally, for any bounded observable
$\varphi$, the max-plus integral equals $\sup_x(\varphi(x)-I(x))$, with the supremum
attained exactly at the full-support points of an exponential tilt of the law. The
idempotent setting should turn Varadhan's asymptotic
$\lim \tfrac1n \log\int e^{n\varphi}\,d\mu_n = \sup(\varphi - I)$ into an exact,
attained identity.

**Functoriality of contraction.** For surjections $T : X\to Y$ and $S : Y\to Z$, the
push-forwards should compose, $(S\circ T)_* = S_* \circ T_*$, with the contracted
rate satisfying $I_Z(z) = \min_{y : S(y)=z} I_Y(y) = \min_{x : (S\circ T)(x)=z} I_X(x)$.
Since the fibration identity is associative under fiber refinement, the idempotent
contraction principle should be a functor from finite types-with-rate to itself,
transporting rate functions along any finite computation graph.

---

## 8. Conclusion

We have proved an exact, convexity-free contraction principle for idempotent
large deviations: the deviation cost of any observed event equals the cost of its
preimage under a summary map, with the transported rate function given by the
fiber-wise minimum. The companion duality-gap example pins down exactly where the
convex half of Cramér's program fails, by exactly the height of a non-convex spike.
Together they give a complete, formally verified, and conceptually transparent
account of the two structural pillars of large-deviation theory in the idempotent
world.
