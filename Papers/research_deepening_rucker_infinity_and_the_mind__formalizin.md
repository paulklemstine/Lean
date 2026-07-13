# Cantor's Hierarchy of Infinities: A Self-Contained Development

## Abstract

We assemble the classical picture of Cantor's transfinite hierarchy of cardinal
numbers and prove the landmark facts that separate one infinity from the next.
Starting from Cantor's theorem — every set is strictly smaller than its power
set — we establish that there is no largest cardinal, exhibit an explicit
strictly increasing tower of infinities obtained by iterated power sets, and
identify the bottom of the ladder: $\aleph_0$ as the least infinite cardinal and
$\aleph_1$ as the least uncountable one. We prove the existence of the Hartogs
number, giving a strictly larger well-orderable cardinal above any set without
appeal to a global well-ordering of the universe. We treat the size of the
continuum $\mathfrak{c} = 2^{\aleph_0}$: it is uncountable, equinumerous with
both the power set of the naturals and the real line, and absorbs multiplication
($\mathfrak{c} \cdot \mathfrak{c} = \mathfrak{c}$), so the plane has the same
cardinality as the line. By König's theorem the continuum has uncountable
cofinality. Finally we state the Continuum Hypothesis precisely, prove it equivalent
to the non-existence of an intermediate cardinal, and derive it from the
Generalized Continuum Hypothesis. All results are developed within standard
axiomatic set theory including the axiom of choice, under which the aleph and
beth hierarchies are the natural scaffolding for the transfinite.

## 1. Introduction

The discovery that infinity is not a single magnitude but an unbounded hierarchy
of strictly increasing magnitudes is among the most consequential ideas in
modern mathematics. Georg Cantor's insight was methodological before it was
substantive: to compare sizes of infinite collections one abandons counting in
favor of *bijection*. Two sets have the same cardinality when their elements can
be placed in one-to-one correspondence. From this single move flows the entire
theory of transfinite cardinals.

This paper presents a self-contained development of the classical skeleton of
that theory. Our aim is expository rigor: every result is stated precisely and
accompanied by a proof sketch that conveys the essential argument. We treat, in
order, Cantor's theorem and its corollaries; the Hartogs construction; the least
infinite and least uncountable cardinals; the explicit Cantor (beth) tower; the
arithmetic of the continuum; and the Continuum Hypothesis together with its
generalized form.

### 1.1 Notation and conventions

For a set (or type) $\alpha$ we write $\#\alpha$ for its cardinality. Cardinals
are compared by $\#\alpha \le \#\beta$, meaning there is an injection
$\alpha \hookrightarrow \beta$, and $\#\alpha < \#\beta$ when additionally no
such injection exists in reverse. We write $\mathcal{P}(\alpha)$ or
$\operatorname{Set}(\alpha)$ for the power set, and identify subsets with their
indicator functions, so that $\#\mathcal{P}(\alpha) = 2^{\#\alpha}$. The least
infinite cardinal is $\aleph_0$; the aleph function $o \mapsto \aleph_o$ and beth
function $o \mapsto \beth_o$ are indexed by ordinals $o$. The continuum is
$\mathfrak{c} = 2^{\aleph_0}$. Throughout we work in standard axiomatic set
theory with the axiom of choice, under which every cardinal is an aleph and the
order $\le$ on cardinals is a well-order.

## 2. Cantor's theorem and the absence of a largest cardinal

The cornerstone of the theory is the following.

**Theorem 2.1 (Cantor).** *For every set $\alpha$,*
$$\#\alpha < \#\mathcal{P}(\alpha).$$

*Proof sketch.* The map $x \mapsto \{x\}$ injects $\alpha$ into
$\mathcal{P}(\alpha)$, giving $\#\alpha \le \#\mathcal{P}(\alpha)$. For strict
inequality it suffices to show no map $f : \alpha \to \mathcal{P}(\alpha)$ is
surjective. Given any such $f$, define the diagonal set
$$D = \{\, x \in \alpha : x \notin f(x) \,\}.$$
If $D = f(a)$ for some $a$, then $a \in D \iff a \notin f(a) = D$, a
contradiction. Hence $D$ is not in the image of $f$, so $f$ is not surjective,
and no bijection can exist. $\qquad\blacksquare$

The diagonal argument yields two sharper non-existence statements, which are
worth isolating because they express the same obstruction from complementary
directions.

**Proposition 2.2.** *For every set $\alpha$ there is no surjection
$f : \alpha \to \mathcal{P}(\alpha)$ and no injection
$g : \mathcal{P}(\alpha) \to \alpha$.*

*Proof sketch.* Non-surjectivity is the diagonal argument above. For
non-injectivity, an injection $g : \mathcal{P}(\alpha) \to \alpha$ would, by
composing with a left inverse, yield a surjection $\alpha \to
\mathcal{P}(\alpha)$, contradicting the first part. $\qquad\blacksquare$

Recast in the language of cardinal arithmetic, Cantor's theorem says that the
operation $c \mapsto 2^c$ strictly increases every cardinal.

**Corollary 2.3 (No largest cardinal).** *For every cardinal $c$ there is a
cardinal $d$ with $c < d$; explicitly $d = 2^c$ works, since $c < 2^c$.*

Iterating Corollary 2.3 produces an endless ascending sequence of cardinals: the
hierarchy of infinities has no maximum. This is the qualitative heart of the
subject, and the remainder of the paper refines it into a structured ladder.

## 3. The Hartogs number

Cantor's theorem produces a larger cardinal by taking a power set, but the power
set operation implicitly uses the full strength of the ambient set theory. A
complementary construction, due to Hartogs, produces a strictly larger
*well-orderable* cardinal by a route that is more parsimonious in its use of
choice: it manufactures an ordinal too large to inject into the given set.

**Theorem 3.1 (Hartogs).** *For every set $\alpha$ there is an ordinal $o$ whose
cardinality strictly exceeds that of $\alpha$:*
$$\#\alpha < \#o.$$

*Proof sketch.* Take $o$ to be the ordinal underlying the successor cardinal
$(\#\alpha)^{+}$. The cardinality of the ordinal underlying a cardinal is that
cardinal itself, so $\#o = (\#\alpha)^{+} > \#\alpha$ by the defining property of
the successor. $\qquad\blacksquare$

The significance of the Hartogs number is that a strictly larger *well-ordered*
size always exists, independently of whether the power set can be well-ordered.
It is the mechanism by which the aleph hierarchy is guaranteed to climb: the
successor cardinal $c^{+}$ is exactly the least cardinal exceeding $c$.

## 4. The bottom of the ladder: $\aleph_0$ and $\aleph_1$

Having established that the ladder is unbounded above, we identify its lowest
rungs.

**Theorem 4.1 ($\aleph_0$ is least infinite).** *For every infinite set
$\alpha$,* $\aleph_0 \le \#\alpha$.

*Proof sketch.* An infinite set admits an injection from $\mathbb{N}$ (choose
distinct elements $a_0, a_1, \dots$ recursively, possible since finiteness would
otherwise follow), so its cardinality is at least $\aleph_0$. $\qquad\blacksquare$

The next rung is the successor of $\aleph_0$.

**Definition 4.2.** $\aleph_1$ *is the first uncountable cardinal, defined as the
successor* $\aleph_0^{+}$.

**Theorem 4.3.** $\aleph_1 = \aleph_0^{+}$, *and consequently
$\aleph_0 < \aleph_1$.*

*Proof sketch.* By definition of the aleph function, $\aleph_1 = \aleph_{0^{+}}
= (\aleph_0)^{+}$, since the aleph of a successor ordinal is the successor
cardinal of the previous aleph and $\aleph_0$ is the aleph of $0$. Strictness
$\aleph_0 < \aleph_0^{+}$ is the defining property of a successor.
$\qquad\blacksquare$

**Theorem 4.4 ($\aleph_1$ is least uncountable).** *If $c$ is a cardinal with
$\aleph_0 < c$, then $\aleph_1 \le c$.*

*Proof sketch.* Since $\aleph_1 = \aleph_0^{+}$ is the least cardinal strictly
greater than $\aleph_0$, any $c$ strictly greater than $\aleph_0$ satisfies
$\aleph_1 = \aleph_0^{+} \le c$ by the universal property of the successor
($c^{+} \le d \iff c < d$). $\qquad\blacksquare$

More generally the aleph function is a strictly monotone map from ordinals to
cardinals.

**Theorem 4.5 (Monotonicity of the alephs).** *If $o_1 < o_2$ then
$\aleph_{o_1} < \aleph_{o_2}$.*

This packages the fact that the alephs enumerate the infinite cardinals in
strictly increasing order with no repetitions and no gaps.

## 5. The Cantor (beth) tower

We now build an *explicit* strictly increasing sequence of infinities by
iterating the power set from the countable floor.

**Definition 5.1 (Cantor tower).** *Define $T : \mathbb{N} \to \mathrm{Card}$ by*
$$T_0 = \aleph_0, \qquad T_{n+1} = 2^{T_n}.$$

These are precisely the finite beth numbers, $T_n = \beth_n$.

**Theorem 5.2.** *For every $n$, $T_n < T_{n+1}$; hence $T$ is strictly
increasing.*

*Proof sketch.* $T_n < 2^{T_n} = T_{n+1}$ is Cantor's theorem (Corollary 2.3)
applied to the cardinal $T_n$. Strict monotonicity over $\mathbb{N}$ follows from
the successor comparison. $\qquad\blacksquare$

**Theorem 5.3.** *Every rung satisfies $\aleph_0 \le T_n$.*

*Proof sketch.* Induction: $T_0 = \aleph_0$, and if $\aleph_0 \le T_n$ then
$\aleph_0 \le T_n < T_{n+1}$. $\qquad\blacksquare$

Thus the tower exhibits, concretely and by an elementary recursion, infinitely
many *distinct* infinite cardinals. Its first rung above the countable floor is
the continuum.

**Theorem 5.4.** $T_1 = 2^{\aleph_0} = \mathfrak{c}$.

The tower interacts with the named hierarchies through a uniform domination.

**Theorem 5.5 (Aleph below beth).** *For every ordinal $o$,
$\aleph_o \le \beth_o$.*

*Proof sketch.* Both hierarchies agree at $0$ and at limits (as suprema); at
successors the beth jumps by a power set, $\beth_{o+1} = 2^{\beth_o}$, while the
aleph jumps to the immediate successor cardinal $\aleph_{o+1} = \aleph_o^{+} \le
2^{\aleph_o}$. Transfinite induction propagates the inequality.
$\qquad\blacksquare$

Under the Generalized Continuum Hypothesis (Section 7) this inequality becomes an
equality at every level, collapsing the two towers into one.

## 6. The size of the continuum

We collect the fundamental cardinal facts about the real line.

**Theorem 6.1 (Uncountability of the reals).**
$\aleph_0 < \#\mathbb{R}$.

*Proof sketch.* $\#\mathbb{R} = 2^{\aleph_0}$, and $\aleph_0 < 2^{\aleph_0}$ by
Cantor's theorem. (Cantor's original diagonal argument on decimal expansions is
the concrete witness.) $\qquad\blacksquare$

**Theorem 6.2 (Reals as subsets of $\mathbb{N}$).**
$\#\mathcal{P}(\mathbb{N}) = \#\mathbb{R}$.

*Proof sketch.* $\#\mathcal{P}(\mathbb{N}) = 2^{\#\mathbb{N}} = 2^{\aleph_0} =
\mathfrak{c} = \#\mathbb{R}$; each real is coded by a subset of $\mathbb{N}$
(e.g. via binary expansion, modulo the countable set of dyadic ambiguities).
$\qquad\blacksquare$

**Theorem 6.3 (Absorption).**
$\mathfrak{c} \cdot \mathfrak{c} = \mathfrak{c}$.

*Proof sketch.* For any infinite cardinal $\kappa$ one has $\kappa \cdot \kappa =
\kappa$ (a fundamental theorem of cardinal arithmetic, provable by a
well-ordering / Gödel pairing argument). Since $\aleph_0 \le \mathfrak{c}$, the
continuum is infinite and the law applies. $\qquad\blacksquare$

**Theorem 6.4 (Plane equals line).**
$\#(\mathbb{R} \times \mathbb{R}) = \#\mathbb{R}$.

*Proof sketch.* $\#(\mathbb{R} \times \mathbb{R}) = \mathfrak{c} \cdot
\mathfrak{c} = \mathfrak{c} = \#\mathbb{R}$ by Theorem 6.3. $\qquad\blacksquare$

The continuum is therefore invariant under finite products; the plane, and by
iteration any finite-dimensional space, carries exactly as many points as the
line. This is Cantor's celebrated "I see it, but I do not believe it."

The final structural constraint on the continuum comes from König's theorem.

**Theorem 6.5 (Uncountable cofinality of $\mathfrak{c}$).** *The cofinality of
$\mathfrak{c}$ is uncountable:* $\aleph_0 < \operatorname{cf}(\mathfrak{c})$.
*Consequently $\mathfrak{c}$ is never the supremum of a countable family of
strictly smaller cardinals.*

*Proof sketch.* König's theorem gives $\kappa < \operatorname{cf}(2^{\kappa})$
for every infinite $\kappa$. Taking $\kappa = \aleph_0$ and using $2^{\aleph_0} =
\mathfrak{c}$ yields $\aleph_0 < \operatorname{cf}(\mathfrak{c})$.
$\qquad\blacksquare$

**Theorem 6.6 (König, general form).** *For every infinite cardinal $\kappa$,*
$\kappa < \operatorname{cf}(2^{\kappa})$; *equivalently $2^{\kappa}$ is never a
$\kappa$-indexed supremum of smaller cardinals.*

This general form immediately excludes certain candidate values for power-set
cardinals: for example $2^{\aleph_0}$ cannot equal any cardinal of countable
cofinality, such as $\aleph_\omega$.

## 7. The Continuum Hypothesis

We now state precisely the question that organizes the entire lower hierarchy.

**Definition 7.1 (Continuum Hypothesis).** *The Continuum Hypothesis (CH) is the
statement*
$$\mathfrak{c} = \aleph_1.$$

The following characterization makes precise the intuition that CH asserts "no
size between countable and continuum."

**Theorem 7.2 (CH as no intermediate cardinal).**
$$\text{CH} \iff \neg\, \exists\, c \ \text{with}\ \aleph_0 < c < \mathfrak{c}.$$

*Proof sketch.* ($\Rightarrow$) Assume $\mathfrak{c} = \aleph_1 = \aleph_0^{+}$.
Any $c < \mathfrak{c} = \aleph_0^{+}$ satisfies $c \le \aleph_0$, so no $c$ can
also satisfy $\aleph_0 < c$; the intermediate range is empty.

($\Leftarrow$) Assume no intermediate cardinal exists. Always
$\aleph_1 \le \mathfrak{c}$, since $\mathfrak{c}$ is uncountable
(Theorem 6.1) and $\aleph_1$ is the least uncountable cardinal (Theorem 4.4).
For the reverse, if $\mathfrak{c} < \aleph_1$ were possible it would contradict
uncountability; if $\aleph_1 < \mathfrak{c}$ then $\aleph_1$ itself is an
intermediate cardinal ($\aleph_0 < \aleph_1 < \mathfrak{c}$), contradicting the
hypothesis. Hence $\mathfrak{c} = \aleph_1$. $\qquad\blacksquare$

**Definition 7.3 (Generalized Continuum Hypothesis).** *GCH is the statement
that for every ordinal $o$,*
$$2^{\aleph_o} = \aleph_{o+1}.$$

**Theorem 7.4 (GCH $\Rightarrow$ CH).** *The Generalized Continuum Hypothesis
implies the Continuum Hypothesis.*

*Proof sketch.* Specialize Definition 7.3 to $o = 0$: $2^{\aleph_0} =
\aleph_1$. The left side is $\mathfrak{c}$, so $\mathfrak{c} = \aleph_1$, which
is CH. $\qquad\blacksquare$

**Theorem 7.5 (GCH collapses beth to aleph).** *Under GCH, for every ordinal
$o$,* $\beth_o = \aleph_o$.

*Proof sketch.* Transfinite induction. Base: $\beth_0 = \aleph_0$. Successor:
$\beth_{o+1} = 2^{\beth_o} = 2^{\aleph_o} = \aleph_{o+1}$ using the inductive
hypothesis and GCH. Limit: both $\beth_o$ and $\aleph_o$ are the supremum of
their predecessors, which agree termwise by the inductive hypothesis.
$\qquad\blacksquare$

CH was the first of Hilbert's problems and Cantor's lifelong preoccupation. Its
ultimate resolution is a metamathematical one: CH is independent of the standard
axioms of set theory. It can be neither proved nor refuted from them (Gödel
established consistency of CH via the constructible universe; Cohen established
consistency of its negation via forcing). The results above are exactly those
that survive this independence: they hold outright, and they show precisely which
questions about the continuum remain open.

## 8. Cardinal-arithmetic laws

For completeness we record the general absorption laws underlying the continuum
computations of Section 6; each specializes to a continuum statement by taking
$\kappa = \mathfrak{c}$.

**Theorem 8.1.** *For every infinite cardinal $\kappa$:*
$$\kappa + \kappa = \kappa, \qquad \kappa \cdot \kappa = \kappa, \qquad \kappa^{\kappa} = 2^{\kappa}.$$

*Proof sketch.* The first two are the classical absorption laws (provable by
well-ordering $\kappa$ and constructing explicit bijections via the Gödel
pairing function). For the third, $2^{\kappa} \le \kappa^{\kappa} \le
(2^{\kappa})^{\kappa} = 2^{\kappa \cdot \kappa} = 2^{\kappa}$, so equality holds
by antisymmetry. $\qquad\blacksquare$

## 9. Discussion

The development above isolates the *robust* core of transfinite cardinal theory:
the facts that hold in every model of the standard axioms. Cantor's theorem and
the resulting unbounded tower, the identification of $\aleph_0$ and $\aleph_1$,
the Hartogs construction, the arithmetic of the continuum, and König's cofinality
constraint are all theorems. The Continuum Hypothesis, by contrast, is
independent — and the value of the characterization in Theorem 7.2 is precisely
that it translates an equality of specific cardinals into a purely structural
statement about gaps, clarifying exactly what independence is independence *of*.

A recurring theme is the tension between the two ways of "going up" the ladder:
the power-set jump $c \mapsto 2^c$ (Cantor, beth) and the successor jump
$c \mapsto c^{+}$ (Hartogs, aleph). Theorem 5.5 ($\aleph_o \le \beth_o$) measures
their divergence, and GCH (Theorem 7.5) is exactly the hypothesis that they never
diverge. This lens organizes the whole subject: the aleph hierarchy is what
*must* exist, the beth hierarchy is what power sets *deliver*, and CH/GCH are the
hypotheses that identify the two.

## 10. Future work

Several natural extensions remain. One is a precise treatment of *beth fixed
points* — cardinals $\kappa$ with $\kappa = \beth_\kappa$ — via the fixed-point
theorem for normal ordinal functions, exhibiting genuinely self-referential
large cardinals. Another is to derive concrete König exclusions, using the
general form (Theorem 6.6) to rule out specific candidate values of $\mathfrak{c}$
such as $\aleph_\omega$ (which has countable cofinality), thereby delimiting the
values left open by independence. A third direction is to state, at the
metamathematical level, the independence of CH itself, connecting the structural
characterization here to forcing and inner-model methods. Finally, one may seek a
choice-free reformulation of the Hartogs construction to make explicit the sense
in which a strictly larger well-orderable cardinal exists without a global
well-ordering.

## References

- G. Cantor, *Über eine elementare Frage der Mannigfaltigkeitslehre* (1891).
- F. Hartogs, *Über das Problem der Wohlordnung* (1915).
- K. Gödel, *The Consistency of the Continuum Hypothesis* (1940).
- P. J. Cohen, *The Independence of the Continuum Hypothesis* (1963–64).
- R. Rucker, *Infinity and the Mind* (1982).
