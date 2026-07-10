# The Topological Kernel of Social Choice: What Borsuk–Ulam Does and Does Not Say About Arrow's Theorem

## Abstract

A recurring slogan in mathematical folklore asserts that Arrow's impossibility
theorem is a corollary of the Borsuk–Ulam theorem, and that consequently every
continuous social choice function is either discontinuous or dictatorial. We
examine this claim rigorously and in two directions. First, we isolate the
*genuine topological kernel* of the picture: the one-dimensional Borsuk–Ulam
theorem, which states that a continuous $2\pi$-periodic function
$f:\mathbb{R}\to\mathbb{R}$ admits an antipodal coincidence $f(x)=f(x+\pi)$, and
whose social-choice reading is that no continuous, periodic scoring rule can
strictly prefer every opinion to its antipode. Second, we give an explicit
*disproof* of the over-strong conjecture: for every $n\ge 2$ the arithmetic mean
is a continuous, unanimous (Pareto), anonymous, monotone, translation-invariant,
and non-dictatorial aggregation rule on the contractible domain $\mathbb{R}^n$.
This refutes "continuous $\Rightarrow$ dictatorial." We conclude by identifying
the correct topological statements — Chichilnisky's impossibility theorem for
aggregation on spheres and Baryshnikov's topological derivation of Arrow's
discrete theorem — and explain precisely why the domain's topology, rather than
the act of voting, is the seat of the obstruction.

## 1. Introduction

Two impossibility theorems anchor two different disciplines. In economics,
Arrow's theorem (1951) states that when there are at least three alternatives,
no rule aggregating individual rankings into a social ranking can simultaneously
satisfy unanimity (Pareto), independence of irrelevant alternatives (IIA), and
non-dictatorship. In topology, the Borsuk–Ulam theorem states that any continuous
map $f:S^n\to\mathbb{R}^n$ identifies a pair of antipodes,
$f(x)=f(-x)$.

The conjecture under examination proposes a bridge: encode preference profiles
over $n$ alternatives as points on a "preference sphere" $S^{n-1}$, with
antipodal points representing reversed preferences; let
$f:S^{n-1}\to\mathbb{R}^{n-1}$ report the social preference; and invoke
Borsuk–Ulam to force $f(x)=f(-x)$, a coincidence that supposedly contradicts
Pareto efficiency. The proposed upshot is a slogan — *any social choice function
on $n$ alternatives is either discontinuous or dictatorial* — and a grand thesis:
*social choice is topology; Arrow's impossibility is a theorem about spheres.*

Our contribution is to separate the true from the false with complete precision.

- **Part I (Section 3).** We prove the one-dimensional Borsuk–Ulam theorem and
  derive its faithful social-choice reading. This is the honest kernel of the
  "contradiction with Pareto" the slogan invokes, correctly restricted to the
  setting where it actually holds.
- **Part II (Section 4).** We disprove the strong conjecture by exhibiting an
  explicit continuous, unanimous, anonymous, monotone, translation-invariant,
  non-dictatorial aggregator — the mean — on a contractible domain.
- **Section 5** situates the honest thesis relative to Chichilnisky's and
  Baryshnikov's theorems and explains the role of domain topology.

The overarching finding is a clean dichotomy: **the Borsuk–Ulam obstruction
requires a non-contractible domain (a sphere); on a contractible domain the
obstruction vanishes and fair continuous aggregation exists.**

## 2. Preliminaries and definitions

Throughout, "continuous" refers to the usual Euclidean topology.

**Definition 2.1 (Periodic function on the circle).** A function
$f:\mathbb{R}\to\mathbb{R}$ is *$2\pi$-periodic* if $f(x+2\pi)=f(x)$ for all
$x$. Such an $f$ is precisely a function on the circle $S^1=\mathbb{R}/2\pi\mathbb{Z}$;
if in addition $f$ is continuous it is a continuous map $S^1\to\mathbb{R}^1$.
The *antipode* of the point $x\in S^1$ is $x+\pi$ (a half-turn).

**Definition 2.2 (Aggregation rule).** Fix $n\ge 1$ agents. Model each agent's
opinion as a real number (a position on a one-dimensional spectrum). An
*aggregation rule* is a map $F:\mathbb{R}^n\to\mathbb{R}$, written
$F(p_1,\dots,p_n)$ where $p_i$ is agent $i$'s position.

**Definition 2.3 (Axioms for an aggregation rule).** An aggregation rule $F$ is:

- *Continuous* if it is continuous as a map $\mathbb{R}^n\to\mathbb{R}$;
- *Unanimous (Pareto)* if $F(c,c,\dots,c)=c$ for every constant $c$;
- *Anonymous* if $F(p_{\sigma(1)},\dots,p_{\sigma(n)})=F(p_1,\dots,p_n)$ for every
  permutation $\sigma$ of the agents;
- *Monotone* if $p_i\le q_i$ for all $i$ implies $F(p)\le F(q)$;
- *Translation-invariant* if $F(p_1+c,\dots,p_n+c)=F(p_1,\dots,p_n)+c$ for every
  constant $c$;
- *Dictatorial* if there exists an agent $i$ with $F(p)=p_i$ for all profiles $p$;
  *non-dictatorial* otherwise.

**Definition 2.4 (Arithmetic mean rule).** The *mean aggregator* is
$$\operatorname{avg}_n(p) \;=\; \frac{1}{n}\sum_{i=1}^{n} p_i.$$

## 3. Part I: the one-dimensional Borsuk–Ulam theorem and its social-choice reading

### 3.1 The theorem

**Theorem 3.1 (One-dimensional Borsuk–Ulam).** *Let $f:\mathbb{R}\to\mathbb{R}$ be
continuous and $2\pi$-periodic. Then there exists $x$ with $f(x)=f(x+\pi)$.*

*Proof.* Define the antipodal difference
$$g(x)=f(x)-f(x+\pi).$$
Then $g$ is continuous as a difference of continuous functions (the second is
$f$ precomposed with the continuous shift $x\mapsto x+\pi$). Using
$2\pi$-periodicity,
$$g(x+\pi)=f(x+\pi)-f(x+2\pi)=f(x+\pi)-f(x)=-g(x),$$
so $g$ is odd under the half-turn; in particular $g(0)=-g(\pi)$. Thus $g(0)$ and
$g(\pi)$ have opposite signs (or are both zero). If both are zero we are done at
$x=0$; otherwise $g$ takes a positive and a negative value on the interval
$[0,\pi]$, and by the Intermediate Value Theorem there is $c\in[0,\pi]$ with
$g(c)=0$, i.e. $f(c)=f(c+\pi)$. $\blacksquare$

This is the complete topological engine in its lowest dimension. Every
higher-dimensional Borsuk–Ulam theorem generalizes the same principle — an
antipodally odd continuous map must vanish — through more sophisticated
algebraic-topological machinery (degree theory, the ham-sandwich theorem, the
Lusternik–Schnirelmann covering theorem).

### 3.2 The faithful social-choice reading

Interpret the circle $S^1$ as a space of opinions, with $x$ and $x+\pi$ opposite
stances, and let $f(x)$ be a continuous "social score" assigned to stance $x$.
The slogan's "clash with Pareto efficiency" is the desire to strictly prefer
every stance to its antipode. Theorem 3.1 forbids this.

**Theorem 3.2 (No strictly antipodal preference).** *Let $f:\mathbb{R}\to\mathbb{R}$
be continuous and $2\pi$-periodic. Then it is not the case that $f(x+\pi)<f(x)$
for all $x$; symmetrically, it is not the case that $f(x)<f(x+\pi)$ for all $x$.*

*Proof.* Suppose $f(x+\pi)<f(x)$ for all $x$. By Theorem 3.1 there is an $x_0$
with $f(x_0)=f(x_0+\pi)$, contradicting the strict inequality at $x_0$. The
symmetric statement is identical with the inequality reversed. $\blacksquare$

Theorem 3.2 is the *correct* and defensible remnant of the informal
"Borsuk–Ulam contradicts Pareto" argument: on a circular (non-contractible)
opinion space, no continuous rule can strictly break every antipodal tie. It is
an honest impossibility — but note carefully what it needs: a *periodic* score,
i.e. a genuinely circular domain.

## 4. Part II: disproof of "continuous implies dictatorial"

The strong conjecture claims that continuity of an aggregation rule forces
dictatorship. We refute it on a contractible domain, where no Borsuk–Ulam-type
obstruction exists. All statements below concern the mean aggregator
$\operatorname{avg}_n$ of Definition 2.4.

**Lemma 4.1 (Unanimity/Pareto).** *For $n\ge 1$ and any constant $c$,
$\operatorname{avg}_n(c,\dots,c)=c$.*

*Proof.* $\frac{1}{n}\sum_{i=1}^n c=\frac{nc}{n}=c$. $\blacksquare$

**Lemma 4.2 (Anonymity).** *For any permutation $\sigma$ of the $n$ agents and
any profile $p$, $\operatorname{avg}_n(p\circ\sigma)=\operatorname{avg}_n(p)$.*

*Proof.* A permutation merely reindexes the summands, and finite sums are
invariant under reindexing: $\sum_i p_{\sigma(i)}=\sum_i p_i$. Dividing by $n$
gives the claim. $\blacksquare$

**Lemma 4.3 (Continuity).** *The map $\operatorname{avg}_n:\mathbb{R}^n\to\mathbb{R}$
is continuous.*

*Proof.* It is a finite sum of coordinate projections (each continuous) scaled
by the constant $1/n$; sums and scalar multiples of continuous functions are
continuous. $\blacksquare$

**Lemma 4.4 (Monotonicity / strong Pareto).** *If $p_i\le q_i$ for all $i$, then
$\operatorname{avg}_n(p)\le\operatorname{avg}_n(q)$.*

*Proof.* Sums preserve the coordinatewise order, $\sum_i p_i\le\sum_i q_i$, and
dividing by the positive constant $n$ preserves the inequality. $\blacksquare$

**Lemma 4.5 (Translation invariance).** *For $n\ge 1$, any profile $p$, and any
constant $c$, $\operatorname{avg}_n(p_1+c,\dots,p_n+c)=\operatorname{avg}_n(p)+c$.*

*Proof.* $\frac{1}{n}\sum_i (p_i+c)=\frac{1}{n}\big(\sum_i p_i + nc\big)
=\operatorname{avg}_n(p)+c$. $\blacksquare$

**Lemma 4.6 (Non-dictatorship).** *For $n\ge 2$ there is no agent $i$ with
$\operatorname{avg}_n(p)=p_i$ for all profiles $p$.*

*Proof.* Fix any candidate dictator $i$. Consider the profile $p$ with $p_i=0$
and $p_j=1$ for all $j\ne i$. Then
$$\operatorname{avg}_n(p)=\frac{0+(n-1)\cdot 1}{n}=\frac{n-1}{n}.$$
Since $n\ge 2$, we have $0<\frac{n-1}{n}<1$, so in particular
$\operatorname{avg}_n(p)\ne 0=p_i$. Hence $i$ is not a dictator. As $i$ was
arbitrary, no dictator exists. $\blacksquare$

Assembling the lemmas yields the disproof.

**Theorem 4.7 (Continuous non-dictatorial aggregator exists).** *For every
$n\ge 2$ there exists an aggregation rule $F:\mathbb{R}^n\to\mathbb{R}$ that is
simultaneously continuous, unanimous (Pareto), anonymous, monotone,
translation-invariant, and non-dictatorial.*

*Proof.* Take $F=\operatorname{avg}_n$. Continuity is Lemma 4.3, unanimity is
Lemma 4.1, anonymity is Lemma 4.2, monotonicity is Lemma 4.4, translation
invariance is Lemma 4.5, and non-dictatorship is Lemma 4.6. $\blacksquare$

**Corollary 4.8.** *The conjecture "any social choice function on $n$
alternatives is either discontinuous or dictatorial" is false.*

*Proof.* For $n\ge 2$, Theorem 4.7 provides a rule that is both continuous and
non-dictatorial. $\blacksquare$

## 5. Discussion: where the topology actually lives

Two independent reasons explain why the literal slogan fails, and together they
locate the genuine mathematical content.

**5.1 Domain topology is the seat of the obstruction.** Borsuk–Ulam produces a
coincidence only on a *non-contractible* space — a sphere, which cannot be
continuously shrunk to a point. The proof of Theorem 3.1 depends essentially on
periodicity, i.e. on the circle's topology. If the opinion domain is
*contractible* (a line, an interval, a simplex of von Neumann–Morgenstern
utilities, or any convex set), there is no antipodal structure and no
obstruction; Theorem 4.7 exhibits a fully fair continuous rule. The correct
slogan is therefore not "continuous $\Rightarrow$ dictatorial" but rather:

> Continuous, anonymous, unanimous aggregation is obstructed exactly when the
> opinion space is non-contractible (spherical); on a contractible domain it is
> freely available.

**5.2 Discrete versus continuous.** Arrow's theorem concerns aggregation of
*discrete linear orders* subject to Independence of Irrelevant Alternatives.
There is no ambient topology and no continuity hypothesis in Arrow's setting, so
a continuity-based argument cannot literally be Arrow's theorem. The two live in
different categories: one topological, one order-theoretic and combinatorial.

**5.3 The correct topological theorems.** The genuine topological impossibility
is **Chichilnisky's theorem**: there is no continuous, anonymous,
unanimity-respecting aggregation map $(S^1)^k\to S^1$ (more generally
$(S^n)^k\to S^n$). Here the domain and codomain are honestly spheres, and the
obstruction is real — its proof uses the homotopy/degree invariants that
Borsuk–Ulam also exploits. Later, **Baryshnikov (1993)** gave a genuinely
topological *derivation of Arrow's discrete theorem* by constructing a
nerve/CW-complex model of the preference data and invoking obstructions of
Borsuk–Ulam type on that model. Thus the honest form of the mission's thesis is:

> Topological obstructions of Borsuk–Ulam type govern aggregation on spheres, and
> Arrow's discrete theorem can be *recovered* through a geometric (nerve) encoding
> of ranked preferences — but Arrow's theorem is not a one-line corollary of
> Borsuk–Ulam, and continuity by itself never implies dictatorship.

## 6. Algorithms

We record two elementary but instructive algorithms used to demonstrate the
results numerically.

**Algorithm A (Antipodal coincidence search).** Given a continuous $2\pi$-periodic
$f$ sampled on a grid, locate an approximate antipodal coincidence by finding a
sign change of $g(x)=f(x)-f(x+\pi)$ on $[0,\pi]$ and bisecting to a zero. This
constructively realizes Theorem 3.1.

**Algorithm B (Fairness audit of the mean).** Given the mean aggregator, verify
each Arrow-style axiom empirically: sample random profiles to check
unanimity, anonymity (under random permutations), monotonicity (under random
non-negative perturbations), translation invariance, and, for each agent,
exhibit the witness profile of Lemma 4.6 certifying non-dictatorship.

## 7. Applications

- **Interpreting impossibility results.** The analysis clarifies a common
  category error: the enemy of fair aggregation is the *shape of the opinion
  space*, not the presence of voting. Practitioners choosing between spatial and
  ordinal models of preference should know which regime carries a topological
  obstruction.
- **Design of aggregation mechanisms.** On contractible domains (spectra,
  budgets, resource allocations), continuous fair rules like the mean, medians,
  and other means are legitimately available; impossibility folklore does not
  apply.
- **Pedagogy of topology.** The one-dimensional Borsuk–Ulam theorem, via the odd
  difference function and the Intermediate Value Theorem, is a self-contained
  entry point to algebraic topology with a vivid interpretation.

## 8. Future directions

- Formalize Chichilnisky's theorem for $(S^1)^k\to S^1$ and connect it to the
  one-dimensional kernel proved here.
- Develop the nerve/CW model behind Baryshnikov's derivation and make the
  discrete-to-topological bridge fully explicit.
- Explore intermediate domains (e.g. spaces that are neither spheres nor
  contractible) and classify precisely which admit continuous fair aggregation as
  a function of their homotopy type.

## 9. Conclusion

The slogan "Arrow's impossibility is Borsuk–Ulam" is, taken literally, incorrect,
and its derived claim "continuous $\Rightarrow$ dictatorial" is false — the mean
is a standing counterexample for all $n\ge 2$. Yet the topological viewpoint is
vindicated in its honest form: the one-dimensional Borsuk–Ulam theorem genuinely
forbids strictly antipodal continuous preferences on a circle, and richer
topological obstructions (Chichilnisky, Baryshnikov) govern aggregation on
spheres and even reach back to Arrow's discrete theorem through a geometric
encoding. Social choice really is topology — provided one remembers that the
decisive variable is the *shape of the space of opinions*, not the ballot.
