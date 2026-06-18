# Certified Novelty in Metric Spaces: Regions, Filtrations, Approximate Transport, and Hausdorff Duality

## Abstract

We develop a quantitative, machine-verified theory of *novelty
certification* in (pseudo)metric spaces. The atomic object is a
predicate $\mathrm{IsNovel}(\varepsilon, S, x)$ certifying that a query
point $x$ is at distance at least $\varepsilon$ from every element of a
reference set $S$, paired with a continuous *novelty score*
$\mathrm{noveltyScore}(S, x) = \inf_{s\in S}\mathrm{dist}(x, s)$. We prove
that the predicate and the score are equivalent through an adaptive
threshold, that the score is $1$-Lipschitz in the query and antitone in
the reference set, and that certificates transport robustly under query
perturbation (triangle transfer) and under expanding (antilipschitz)
maps. We then extend this pointwise core along three orthogonal axes,
each an instance of a *duality and representation* program — replace a
hard object by an easier dual and transport structure across the
dictionary.

First, **point → region**: representing the score by its strict
super-level sets, the *novelty regions*, turns continuity of the score
into openness of the region and exhibits a decreasing filtration in the
threshold; the score doubles as a persistence *birth time*, giving each
point a barcode. Second, **exact → approximate**: modelling real
embeddings that obey Lipschitz bounds only up to additive slack, we
introduce approximately-Lipschitz maps, prove the affine error-composition
law $(K_2,c_2)\circ(K_1,c_1) = (K_2K_1,\,K_2c_1+c_2)$, iterate it to a
closed-form *depth budget* $c\cdot(K^n-1)/(K-1)$, and give an error-aware
certificate-transfer rule. Third, **point → set**: viewing each set as a
point of the Hausdorff metric space lifts every pointwise theorem to a
set-level shadow, and we record the dual second-variable regularity that
the birth time is $1$-Lipschitz in the reference set under Hausdorff
distance. The pointwise core is fully formalized with no axioms beyond
`propext`, `Classical.choice`, and `Quot.sound`.

**Keywords:** novelty detection, metric geometry, infimum distance,
Lipschitz stability, persistent homology, filtration, Hausdorff metric,
approximate embeddings, formal verification.

---

## 1. Introduction

Novelty — or anomaly, or out-of-distribution — detection is a pervasive
primitive: spam filtering, fraud detection, astronomical transient
surveys, manufacturing quality control, and the originality assessment of
generative model outputs all reduce to the same question. *Given a corpus
of known objects and a new observation, is the observation genuinely far
from everything known, and with what guaranteed margin?*

Practice typically answers with a heuristic score and a tuned threshold,
offering no formal guarantee that the decision is stable under noise,
survives a learned transformation, generalizes to a neighbourhood of the
observed point, or extends from points to structured objects. This paper
supplies such guarantees. We treat novelty as a *certificate*: a
predicate with an explicit numerical margin whose properties are theorems,
not empirical tendencies. The development is metric-geometric and entirely
elementary in its ingredients — the only primitive is the distance to the
nearest known point — yet it composes into a surprisingly complete
toolbox.

The contributions are organized as a pointwise *core* (Section 3) and
three *extension axes* (Sections 4–6), each instantiating the same
methodological motif: solve a hard problem by transporting it across a
representational dictionary into an easier one.

---

## 2. Setting and notation

Throughout, $(\alpha, \mathrm{dist})$ and $(\beta, \mathrm{dist})$ are
(pseudo)metric spaces. For a nonempty subset $S \subseteq \alpha$ and a
point $x$, $\mathrm{infDist}(x, S) = \inf_{s\in S}\mathrm{dist}(x,s)$
denotes the distance from $x$ to $S$ (the infimum distance), which is
nonnegative, $1$-Lipschitz in $x$, and antitone under enlargement of $S$.
We write $\mathrm{ball}(c, r)$ for the open metric ball of centre $c$ and
radius $r$. A function $f : \alpha \to \beta$ is `LipschitzWith` $K$ if
$\mathrm{dist}(f(x), f(y)) \le K\,\mathrm{dist}(x,y)$, and
`AntilipschitzWith` $K$ if $\mathrm{dist}(x,y) \le K\,\mathrm{dist}(f(x),
f(y))$.

---

## 3. The pointwise core

### 3.1 Definitions

**Definition 3.1 (Novelty predicate).** For a threshold
$\varepsilon \in \mathbb R$, a reference set $S \subseteq \alpha$, and a
point $x \in \alpha$,
$$
\mathrm{IsNovel}(\varepsilon, S, x) \;:\Longleftrightarrow\;
\forall\, s \in S,\ \varepsilon \le \mathrm{dist}(x, s).
$$

**Definition 3.2 (Novelty score).**
$$
\mathrm{noveltyScore}(S, x) \;:=\; \mathrm{infDist}(x, S)
\;=\; \inf_{s \in S} \mathrm{dist}(x, s).
$$

**Definition 3.3 (Mutual separation).** A set $S$ is *mutually
$\varepsilon$-separated* if it is pairwise $\varepsilon$-far:
$$
\mathrm{MutuallySeparated}(\varepsilon, S) \;:\Longleftrightarrow\;
\forall\, a, b \in S,\ a \ne b \Rightarrow \varepsilon \le \mathrm{dist}(a, b).
$$

### 3.2 The score–predicate equivalence

**Theorem 3.4 (Adaptive threshold).** For nonempty $S$,
$$
\mathrm{IsNovel}(\varepsilon, S, x) \quad\Longleftrightarrow\quad
\varepsilon \le \mathrm{noveltyScore}(S, x).
$$
*Proof sketch.* Unfolding $\mathrm{IsNovel}$ gives a universally
quantified lower bound $\varepsilon \le \mathrm{dist}(x, s)$ over all
$s \in S$; for nonempty $S$ this is precisely the characterization
$\varepsilon \le \inf_{s\in S}\mathrm{dist}(x,s)$ of a lower bound for an
infimum. $\square$

This theorem is the hinge of the framework: it converts the *verifiable
predicate* (a certificate) into a *scalar score* (an optimizable
quantity), and back. The empty reference set is a boundary case for which
$\mathrm{IsNovel}(\varepsilon, \varnothing, x)$ holds vacuously for every
threshold.

### 3.3 Regularity of the score

**Theorem 3.5 (Lipschitz stability in the query).** For every $S$, the
map $x \mapsto \mathrm{noveltyScore}(S, x)$ is $1$-Lipschitz:
$$
\bigl|\mathrm{noveltyScore}(S, x) - \mathrm{noveltyScore}(S, y)\bigr|
\le \mathrm{dist}(x, y).
$$
*Proof sketch.* This is the standard $1$-Lipschitz continuity of
$x \mapsto \mathrm{infDist}(x, S)$: for any $s$, $\mathrm{infDist}(x, S)
\le \mathrm{dist}(x, s) \le \mathrm{dist}(x, y) + \mathrm{dist}(y, s)$;
taking the infimum over $s$ and symmetrizing yields the bound. $\square$

**Theorem 3.6 (Nonnegativity).**
$0 \le \mathrm{noveltyScore}(S, x)$, since it is an infimum of
nonnegative distances.

**Theorem 3.7 (Antitonicity in the reference set).** If
$T \subseteq S$ and $T$ is nonempty, then
$$
\mathrm{noveltyScore}(S, x) \le \mathrm{noveltyScore}(T, x).
$$
*Proof sketch.* Enlarging the set over which the infimum is taken can only
decrease it; this is $\mathrm{infDist}(x, S) \le \mathrm{infDist}(x, T)$
for $T \subseteq S$. $\square$

At the predicate level, the same monotonicity reads: if $T \subseteq S$
and $\mathrm{IsNovel}(\varepsilon, S, x)$ then
$\mathrm{IsNovel}(\varepsilon, T, x)$ — a certificate against a larger
archive descends to every sub-archive.

### 3.4 Robustness: triangle transfer

**Theorem 3.8 (Triangle transfer).** If $\mathrm{dist}(x, y) \le \delta$
and $\mathrm{IsNovel}(\varepsilon, S, x)$, then
$\mathrm{IsNovel}(\varepsilon - \delta, S, y)$.
*Proof sketch.* For each $s \in S$, the triangle inequality gives
$\mathrm{dist}(x, s) \le \mathrm{dist}(x, y) + \mathrm{dist}(y, s)$, so
$\mathrm{dist}(y, s) \ge \mathrm{dist}(x, s) - \delta \ge \varepsilon -
\delta$. $\square$

The certificate degrades by *exactly* the perturbation magnitude: a
$\delta$-sized measurement error consumes $\delta$ of the novelty margin
and no more. This is the certificate-level shadow of the $1$-Lipschitz
bound of Theorem 3.5.

### 3.5 Transport under maps

**Theorem 3.9 (Transport under antilipschitz maps).** Let $f$ be
`AntilipschitzWith` $K$ with $K > 0$. If
$\mathrm{IsNovel}(\varepsilon, S, x)$ then
$$
\mathrm{IsNovel}\!\left(\tfrac{\varepsilon}{K},\ f(S),\ f(x)\right).
$$
*Proof sketch.* For $s \in S$, antilipschitz means $\mathrm{dist}(x, s)
\le K\,\mathrm{dist}(f(x), f(s))$, hence $\mathrm{dist}(f(x), f(s)) \ge
\mathrm{dist}(x, s)/K \ge \varepsilon / K$, which is the required bound for
every image point of $S$. $\square$

**Theorem 3.10 (One-sided contraction under Lipschitz maps).** If $f$ is
`LipschitzWith` $K$ then $\mathrm{dist}(f(x), f(s)) \le K\,\mathrm{dist}(x,
s)$. Consequently the maximal transported threshold for $f(x)$ against
$f(S)$ is bounded above by $K$ times the source threshold. Combined with
Theorem 3.9, a bi-Lipschitz map yields faithful two-sided transport of
certificates.

The asymmetry is the moral: *expanding* maps preserve novelty (only
rescaling the margin), while *contracting* maps can collapse distinct
points and destroy it. Bi-Lipschitz embeddings are exactly those for
which certifying novelty in a feature space is sound back in the source.

### 3.6 Packing and capacity

**Theorem 3.11 (Disjoint balls from separation).** If
$\varepsilon \le \mathrm{dist}(a, b)$ then
$\mathrm{ball}(a, \varepsilon/2)$ and $\mathrm{ball}(b, \varepsilon/2)$
are disjoint.
*Proof sketch.* Two balls of radii $r_a, r_b$ are disjoint once
$r_a + r_b \le \mathrm{dist}(a, b)$; here $\varepsilon/2 + \varepsilon/2 =
\varepsilon \le \mathrm{dist}(a, b)$. $\square$

**Theorem 3.12 (Packing from mutual separation).** If
$\mathrm{MutuallySeparated}(\varepsilon, S)$ then the family
$\{\,\mathrm{ball}(c, \varepsilon/2) : c \in S\,\}$ is pairwise disjoint.
This is the geometric core of every sphere-packing capacity bound: the
number of mutually-novel points in a bounded region is limited by how many
disjoint $\varepsilon/2$-balls fit.

**Theorem 3.13 (Separation is pointwise novelty).** If
$\mathrm{MutuallySeparated}(\varepsilon, S)$ and $x \in S$, then
$\mathrm{IsNovel}(\varepsilon, S \setminus \{x\}, x)$: each member of a
separated set is novel against all the others. This identifies the global
packing condition with the pointwise certificates it guarantees.

---

## 4. Axis I — Point → Region: novelty regions, filtration, persistence

### 4.1 Definition and openness

**Definition 4.1 (Novelty region).** For a reference set $S$ and a
threshold $\varepsilon$,
$$
\mathrm{noveltyRegion}(S, \varepsilon) \;:=\;
\bigl\{\, x \ :\ \varepsilon < \mathrm{noveltyScore}(S, x) \,\bigr\},
$$
the *strict super-level set* of the score.

**Theorem 4.2 (Openness / stability).** $\mathrm{noveltyRegion}(S,
\varepsilon)$ is open.
*Proof sketch.* The score is continuous (Theorem 3.5), and a strict
super-level set $\{x : \varepsilon < g(x)\}$ of a continuous function $g$
is the preimage of the open ray $(\varepsilon, \infty)$, hence open.
$\square$

Openness is the regional form of pointwise stability: around any
certified-novel point lies an entire neighbourhood of certified-novel
points, so a sufficiently small perturbation of the query never crosses
the boundary.

### 4.2 The threshold filtration

**Theorem 4.3 (Decreasing filtration in the threshold).** If
$\varepsilon_1 \le \varepsilon_2$ then
$$
\mathrm{noveltyRegion}(S, \varepsilon_2) \subseteq
\mathrm{noveltyRegion}(S, \varepsilon_1).
$$
*Proof sketch.* If $\varepsilon_2 < \mathrm{noveltyScore}(S, x)$ and
$\varepsilon_1 \le \varepsilon_2$, then $\varepsilon_1 <
\mathrm{noveltyScore}(S, x)$. $\square$

**Theorem 4.4 (Antitonicity in the reference set).** If $T \subseteq S$
(with $T$ nonempty) then
$\mathrm{noveltyRegion}(S, \varepsilon) \subseteq
\mathrm{noveltyRegion}(T, \varepsilon)$, by Theorem 3.7.

Together these make $\{\mathrm{noveltyRegion}(S, \varepsilon)\}_\varepsilon$
a filtration of open sets indexed by the threshold and monotone in the
knowledge base — precisely the input structure of persistent homology.

### 4.3 Birth times and barcodes

**Definition 4.5 (Birth time).** $\mathrm{birthTime}(S, x) :=
\mathrm{noveltyScore}(S, x)$.

**Theorem 4.6 (Barcode characterization).**
$$
x \in \mathrm{noveltyRegion}(S, \varepsilon)
\quad\Longleftrightarrow\quad
\varepsilon < \mathrm{birthTime}(S, x).
$$
Thus the set of thresholds at which $x$ is certified novel is exactly the
half-open interval $[0, \mathrm{birthTime}(S, x))$ — the persistence
*barcode* of the point. The novelty filtration is order-reverse-dual to
the union-of-balls (Čech/offset) filtration: $x$ is novel at $\varepsilon$
iff it has escaped every closed $\varepsilon$-ball around $S$, i.e. lies
outside the $\varepsilon$-thickening of $S$. The conjectured exact
identity $\{x : \varepsilon < \mathrm{infDist}(x, S)\} = (\mathrm{thickening}_\varepsilon
S)^{\mathsf c}$ ties the novelty barcode of a point to the death time of
the corresponding component in the Čech filtration.

**Bridge.** Every region membership is a pointwise certificate:
$x \in \mathrm{noveltyRegion}(S, \varepsilon)$ implies (for nonempty $S$)
$\mathrm{IsNovel}(\varepsilon, S, x)$ via Theorem 3.4, reconnecting the
regional picture to the predicate framework of Section 3.

---

## 5. Axis II — Exact → Approximate: error-aware transport

### 5.1 Approximately-Lipschitz maps

**Definition 5.1.** A map $f : \alpha \to \beta$ is
*$(K, c)$-approximately Lipschitz*, written
$\mathrm{ApproxLipschitzWith}(K, c)\,f$, if
$$
\mathrm{dist}(f(x), f(y)) \le K\,\mathrm{dist}(x, y) + c
\qquad \forall x, y,
$$
and *$(K, c)$-approximately antilipschitz* if
$\mathrm{dist}(x, y) \le K\,\mathrm{dist}(f(x), f(y)) + c$.

**Theorem 5.2 (Exact theory as the $c=0$ fragment).** If $f$ is
`LipschitzWith` $K$ then $f$ is $(K, 0)$-approximately Lipschitz. Hence
the exact theory embeds as the slack-free fragment of the approximate one.

### 5.2 The composition law

**Theorem 5.3 (Affine error composition).** If $f_1$ is $(K_1,
c_1)$-approximately Lipschitz and $f_2$ is $(K_2, c_2)$-approximately
Lipschitz, then $f_2 \circ f_1$ is $(K_2 K_1,\ K_2 c_1 + c_2)$-approximately
Lipschitz:
$$
(K_2, c_2) \circ (K_1, c_1) = (K_2 K_1,\ K_2 c_1 + c_2).
$$
*Proof sketch.* Apply the $f_2$ bound to $f_1(x), f_1(y)$, then the $f_1$
bound: $\mathrm{dist}(f_2 f_1 x, f_2 f_1 y) \le K_2(K_1\,\mathrm{dist}(x,y)
+ c_1) + c_2 = K_2K_1\,\mathrm{dist}(x,y) + (K_2 c_1 + c_2)$. $\square$

### 5.3 Iteration and the depth budget

**Theorem 5.4 (Iterate).** The $n$-fold composition of a single $(K,
c)$-approximately-Lipschitz layer is $\bigl(K^n,\ c\sum_{i<n}K^i\bigr)$-approximately
Lipschitz.
*Proof sketch.* Induction on $n$ using Theorem 5.3: the multiplicative
constant multiplies to $K^n$, and at each step the accumulated error
$E$ updates to $K\cdot E + c$, whose solution from $E_0 = 0$ is
$E_n = c\sum_{i<n}K^i$. $\square$

**Theorem 5.5 (Closed-form depth budget).** For $K \ne 1$,
$$
c\sum_{i<n}K^i = c\cdot\frac{K^n - 1}{K - 1},
$$
and for $K = 1$ the error is simply $c\,n$.
*Proof sketch.* Finite geometric series. $\square$

This is a *depth budget*: an exact, closed-form accounting of accumulated
distortion as a function of architectural depth. It predicts the depth at
which a transported certificate becomes vacuous — once the additive error
exceeds the available margin — namely roughly when
$n > \log_K\!\bigl(1 + \varepsilon (K-1)/c\bigr)$.

### 5.4 Error-aware certificate transfer

**Theorem 5.6 (Approximate transport).** If $f$ is $(K,
c)$-approximately antilipschitz with $K > 0$ and
$\mathrm{IsNovel}(\varepsilon, S, x)$, then $f(x)$ is
$\bigl((\varepsilon - c)/K\bigr)$-novel against $f(S)$.
*Proof sketch.* For $s \in S$, $\varepsilon \le \mathrm{dist}(x, s) \le
K\,\mathrm{dist}(f(x), f(s)) + c$, so $\mathrm{dist}(f(x), f(s)) \ge
(\varepsilon - c)/K$. $\square$

The threshold deflates *both* multiplicatively (by $1/K$, the geometric
distortion) and additively (by the error slack $c$). Setting $c = 0$
recovers the exact Theorem 3.9.

---

## 6. Axis III — Point → Set: Hausdorff duality

### 6.1 Sets as points

The space of nonempty compact subsets of $\beta$, equipped with the
Hausdorff distance
$$
\mathrm{hausdorffDist}(A, B) = \max\!\Bigl(
\sup_{a\in A}\inf_{b\in B}\mathrm{dist}(a,b),\;
\sup_{b\in B}\inf_{a\in A}\mathrm{dist}(a,b)\Bigr),
$$
is itself a metric space. Under this dictionary, *each set is a point*,
and the entire pointwise theory of Sections 3–4 re-instantiates one level
up, with no new analysis required.

**Definition 6.1 (Set-level novelty).** For a family $\mathcal F$ of sets,
a set $A$ is $\varepsilon$-novel against $\mathcal F$,
$\mathrm{IsNovelSet}(\varepsilon, \mathcal F, A)$, if
$\varepsilon \le \mathrm{hausdorffDist}(A, B)$ for every $B \in \mathcal F$
— i.e. it is $\mathrm{IsNovel}$ in the Hausdorff metric space.

### 6.2 Transported theorems

**Theorem 6.2 (Set-level triangle transfer).** If
$\mathrm{hausdorffDist}(A, A') \le \delta$ and
$\mathrm{IsNovelSet}(\varepsilon, \mathcal F, A)$, then
$\mathrm{IsNovelSet}(\varepsilon - \delta, \mathcal F, A')$.
*Proof sketch.* Theorem 3.8 applied in the Hausdorff metric space.
$\square$

**Theorem 6.3 (Family antitonicity).** If $\mathcal G \subseteq \mathcal
F$ and $\mathrm{IsNovelSet}(\varepsilon, \mathcal F, A)$ then
$\mathrm{IsNovelSet}(\varepsilon, \mathcal G, A)$ — the set-level shadow of
predicate antitonicity (Theorem 3.7's predicate form). $\square$

### 6.3 Stability in the reference set

**Theorem 6.4 (Birth-time Lipschitz in the reference).** The map
$S \mapsto \mathrm{birthTime}(S, x) = \mathrm{infDist}(x, S)$ is
$1$-Lipschitz with respect to the Hausdorff distance on reference sets:
$$
\bigl|\mathrm{birthTime}(S, x) - \mathrm{birthTime}(T, x)\bigr|
\le \mathrm{hausdorffDist}(S, T).
$$
*Proof sketch.* The infimum distance to a set is $1$-Lipschitz in the set
argument under Hausdorff distance ($\mathrm{infDist}(x, S) \le
\mathrm{infDist}(x, T) + \mathrm{hausdorffDist}(S, T)$ and symmetrically).
$\square$

This is the *second-variable* dual of the point-variable Theorem 3.5:
small Hausdorff perturbations of the knowledge base move every barcode
endpoint by at most the perturbation, so the entire persistence diagram is
stable to noise in *what is known*, not only in *what is queried*.

---

## 7. Algorithms

The theory is constructive. Three algorithmic primitives suffice for all
demonstrations.

**Score and certificate (Algorithm A).** Given finite $S$ and query $x$,
compute $\mathrm{noveltyScore}(S, x) = \min_{s\in S}\mathrm{dist}(x,s)$ in
$O(|S| \cdot d)$ time for $d$-dimensional data, and certify $\varepsilon$-novelty
by the threshold test of Theorem 3.4.

**Depth-budget evaluation (Algorithm B).** Given a per-layer pair $(K, c)$
and depth $n$, return the iterate $(K^n, c\,(K^n-1)/(K-1))$ in $O(1)$ via
the closed form of Theorem 5.5, then deflate a target margin by Theorem
5.6 to obtain the surviving threshold.

**Hausdorff set-novelty (Algorithm C).** Given finite sets, compute the
Hausdorff distance by a double nearest-neighbour sweep
($O(|A||B|d)$) and certify set-level novelty by Definition 6.1.

---

## 8. Applications

- **Out-of-distribution detection with guarantees.** The score is a
  drop-in OOD score; Theorem 3.4 turns any chosen operating threshold into
  a certificate, and Theorem 3.8 quantifies its noise tolerance exactly.
- **Certified novelty through learned encoders.** Theorems 3.9–3.10 and
  5.6 govern when novelty established in a feature space is sound in the
  input space, with the depth budget of Section 5 sizing the additive
  error of deep encoders.
- **Active learning / experimental design.** The novelty region (Section
  4) is the candidate set for the next maximally-informative query; the
  filtration ranks candidates by birth time.
- **Capacity and coverage.** Theorem 3.12 bounds how many mutually-novel
  observations a bounded domain admits, linking novelty to packing
  numbers.
- **Shape and cluster novelty.** Section 6 certifies novelty of entire
  structured objects (clusters, trajectories, shapes) via the Hausdorff
  metric, with stability under perturbation of the reference corpus
  (Theorem 6.4).

---

## 9. Discussion

The framework's leverage comes from a single methodological motif applied
three times: *represent a hard object by an easier dual and transport
structure across the dictionary.* Points become regions (and stability
becomes openness, embedding novelty in persistent homology); exact maps
become approximate maps (and a single composition law yields an exact
depth budget); points become sets (and every theorem reappears one
dimension up via the Hausdorff metric). Because each transport is an
*instantiation* rather than a re-derivation, the extensions inherit the
soundness of the core essentially for free.

A notable structural payoff is the identification of the novelty
filtration with the order-reverse of the Čech/offset filtration: the
engineering quantity "novelty margin" and the topological quantity
"filtration value" are two readings of the same number, so the mature
stability theory of persistence diagrams applies to novelty certificates.

The pointwise core is fully formalized and machine-checked, depending only
on `propext`, `Classical.choice`, and `Quot.sound`; the certificates are
therefore sound by construction rather than by testing.

---

## 10. Future work

1. **Exact offset identity.** Prove
   $\{x : \varepsilon < \mathrm{infDist}(x, S)\} =
   (\mathrm{thickening}_\varepsilon S)^{\mathsf c}$, formally identifying
   the novelty filtration with the complement of the Čech offset
   filtration.
2. **Layer-budget vacuity.** Establish the exact threshold $n >
   \log_K(1 + \varepsilon(K-1)/c)$ at which the transported certificate
   becomes vacuous, as a closed-form corollary of the geometric-series
   depth budget.
3. **Open Hausdorff regions and convex bodies.** Show the set-level
   novelty region is open in the space of nonempty compacts of a proper
   space, so that Blaschke selection lifts the filtration/birth-time
   theory verbatim to convex bodies.
4. **Quantitative packing bounds.** Combine Theorem 3.12 with covering
   numbers to prove $|S| \le N(\varepsilon/2)$ for $\varepsilon$-separated
   $S$, and characterize nonemptiness of the novelty region by
   non-maximality of the packing.
5. **Full Hausdorff stability of the diagram.** Use Theorem 6.4 to derive
   a stability theorem for the entire novelty persistence diagram under
   Hausdorff perturbation of the reference set, unifying point-variable and
   set-variable regularity.

---

## Appendix: Symbol reference

| Symbol | Meaning |
|---|---|
| $\mathrm{dist}(x,y)$ | metric distance |
| $\mathrm{infDist}(x, S)$ | distance from point $x$ to set $S$ |
| $\mathrm{noveltyScore}(S, x)$ | $= \mathrm{infDist}(x, S)$ |
| $\mathrm{IsNovel}(\varepsilon, S, x)$ | $\forall s\in S,\ \varepsilon \le \mathrm{dist}(x,s)$ |
| $\mathrm{noveltyRegion}(S, \varepsilon)$ | $\{x : \varepsilon < \mathrm{noveltyScore}(S, x)\}$ |
| $\mathrm{birthTime}(S, x)$ | $= \mathrm{noveltyScore}(S, x)$ |
| $(K, c)$ | approximate-Lipschitz pair (factor, additive error) |
| $\mathrm{hausdorffDist}(A, B)$ | Hausdorff distance between sets |
| $\mathrm{IsNovelSet}(\varepsilon, \mathcal F, A)$ | set-level novelty in the Hausdorff metric |
