# Beyond Power Series: A Number System Where "Exp Beats Everything" Becomes Arithmetic

## The trouble with infinity-flavored algebra

Every student of calculus eventually internalizes a small piece of folklore: as $x$ grows
without bound, the exponential function $e^x$ outpaces every power of $x$. Plot $x^{10}$ and
$e^x$ on the same axes and, for a while, the polynomial wins by a mile. But wait long enough
and the exponential surges past it, never to be caught. We say $x^{10} = o(e^x)$, read "little-o
of $e^x$": the ratio $x^{10}/e^x$ collapses to zero.

This is more than a curiosity. It is the opening line of a vast, strangely beautiful story about
how functions *grow*. Logarithms crawl. Powers stride. Exponentials sprint. Iterated
exponentials — $e^{e^x}$ and beyond — accelerate into regimes so violent that no ordinary
notation can keep up. Mathematicians have a name for the functions built by composing exponentials,
logarithms, and ordinary algebra: the **exp-log** functions, or in the language of this work,
**EML functions** (Exp, Multiply, Log).

Here is the problem. Power series — those infinite sums $a_0 + a_1 x + a_2 x^2 + \cdots$ — are
the workhorse tool for understanding functions near a point. But power series are hopeless at
infinity, and they are utterly blind to the difference between $e^x$ and $e^{e^x}$. They simply
do not contain the vocabulary. If you want a *calculus of growth rates* — a formal system in which
"$e^x$ beats $x^{10}$" is not a limit you have to recompute every time but a fixed, structural fact
you can do arithmetic with — you need something bigger.

That something is the field of **transseries**.

## What is a transseries?

Imagine generalizing a power series in two directions at once. First, allow real exponents, not just
integer ones: $x^{1/2}$, $x^{\pi}$, $x^{-3.7}$ are all fair game. Second, and more radically, allow
the "variables" themselves to be exponentials and logarithms of $x$. A single **transmonomial** is a
formal product

$$
(e^{e^x})^{a_2}\cdot (e^x)^{a_1}\cdot x^{a_0}\cdot (\log x)^{a_{-1}}\cdot (\log\log x)^{a_{-2}}\cdots
$$

where only finitely many of the real exponents $a_h$ are nonzero. The integer $h$ is the **tower
height**: $h=1$ is $e^x$, $h=0$ is plain $x$, $h=-1$ is $\log x$, $h=2$ is $e^{e^x}$, and so on. A
**transseries** is a (possibly infinite, but well-organized) formal sum of such transmonomials with
real coefficients, for example

$$
e^x + 3x^2 - \tfrac{1}{2}x + 7 + \frac{1}{\log x} + \frac{4}{x} + \cdots
$$

Transseries were developed by analysts and logicians — Écalle, van der Hoeven, Aschenbrenner, van den
Dries, and others — precisely to give the asymptotic behavior of EML functions a home. And the central
miracle is that this enormous collection of formal objects is not a chaotic zoo. It is a **field**: you
can add, subtract, multiply, and — crucially — divide transseries, and the usual laws of arithmetic
hold. Even better, it is an **ordered** field, and its order is exactly asymptotic dominance.

This article describes a rigorous, machine-checked construction of the transseries field for a single
exp/log tower with real powers, together with three landmark facts: that the transmonomials are
ordered so that *higher towers always dominate*, that this order genuinely models real-analytic
growth, and that a transseries is *uniquely determined by its asymptotic expansion*.

## Building the field out of Hahn series

How do you turn a wishful pile of formal sums into an honest field? The key technology is a
construction due to Hans Hahn from 1907: the **Hahn series**. Fix an ordered abelian group $\Gamma$
of "exponents." A Hahn series with coefficients in a field $K$ is a formal sum

$$
\sum_{\gamma \in \Gamma} c_\gamma\, t^{\gamma}, \qquad c_\gamma \in K,
$$

subject to one decisive condition: the set of $\gamma$ where $c_\gamma \neq 0$ must be
**well-ordered**. Well-orderedness is the structural backbone that makes infinite multiplication and,
remarkably, *division* well-defined. Hahn's theorem says that if $K$ is a field and $\Gamma$ is an
ordered group, then these series form a field.

The trick, then, is to choose the right exponent group $\Gamma$. For transseries, the exponents are
the transmonomials. A transmonomial is determined by its finite list of real exponents
$(\ldots, a_{-1}, a_0, a_1, \ldots)$ indexed by tower height. That is exactly a **finitely supported
function from the integers to the reals**, written $\mathbb{Z} \to_{0} \mathbb{R}$. To capture the
asymptotic ordering — "higher tower wins" — we equip this group with the **lexicographic order**: to
compare two transmonomials, look at the most significant tower height where they differ and compare the
exponents there.

The construction crystallizes into two definitions:

$$
\textbf{TransMono} := \mathrm{Lex}(\mathbb{Z} \to_{0} \mathbb{R}),
\qquad
\textbf{TSeries} := \mathrm{HahnSeries}(\textbf{TransMono}, \mathbb{R}).
$$

The first is the lexicographically ordered group of transmonomials; the second is the Hahn-series field
built over it. Because the underlying group is a linearly ordered abelian group and the coefficient ring
$\mathbb{R}$ is a field, Hahn's theorem hands us the headline structural result for free: **the
transseries form a field.** Addition, multiplication, and division all make sense, and $1 \neq 0$, so the
field is genuinely nontrivial.

A single transmonomial of height $h$ and exponent $a$ is written $\mathrm{mono}(h, a)$; the corresponding
one-term transseries with coefficient $1$ is $\mathrm{term}(h, a)$. With these in hand, every formal
growth-rate object we care about is an element of an honest algebraic field.

## The order *is* asymptotic dominance

A field is only half the story. The soul of transseries is that their order encodes growth. We need to
know, formally, that bigger-in-the-field means faster-growing-at-infinity. Three theorems pin this down.

**Higher towers dominate.** The first result states that a transmonomial of strictly *higher* tower
height — with a positive exponent — dominates any transmonomial of lower height, no matter how large the
lower one's exponent. In symbols, if $h < h'$ and $a' > 0$, then

$$
\mathrm{mono}(h, a) \;<\; \mathrm{mono}(h', a').
$$

This is the formal heartbeat of the whole theory. It says $e^{e^x}$ beats every power of $e^x$, that
$e^x$ beats every power of $x$, and that $x$ beats every power of $\log x$ — all at once, as a single
clean statement about the lexicographic order. The proof is not a numerical limit; it is a structural
comparison at the most significant differing coordinate of the exponent group.

**Within a tower, bigger exponent dominates.** At a fixed tower height, the order reduces to the
familiar one: if $a < a'$ then $\mathrm{mono}(h, a) < \mathrm{mono}(h, a')$. So $x^2$ beats $x$, and
$(e^x)^5$ beats $(e^x)^3$, exactly as intuition demands.

**Exp beats *every* power.** The crowning special case deserves its own billing. For *every* real
exponent $a$ — including absurdly large ones like $a = 10^{100}$ —

$$
\mathrm{mono}(0, a) \;<\; \mathrm{mono}(1, 1),
\qquad\text{i.e.}\qquad x^{a} \;\prec\; e^{x}.
$$

No power-series valuation can express this. A Laurent or Puiseux series can only "see" finitely many
orders of growth at a time; the statement "$e^x$ dominates $x^a$ for *all* real $a$ simultaneously" is
precisely what forces us out of power series and into transseries. It is the defining feature of the
larger universe.

## Grounding the formalism in real analysis

A skeptic might object: these are formal symbols pushed around by a lexicographic rule. Why should we
believe the order has anything to do with actual functions? The construction answers this by tying the
formal order back to honest little-o statements about real functions.

First, **exp dominates every polynomial**: for every natural number $n$,

$$
x^{n} \;=\; o(e^{x}) \quad\text{as } x \to +\infty.
$$

The ratio $x^n / e^x \to 0$. This is the analytic shadow of "exp beats every power."

Second, **iterated exponentials dominate powers of exponentials**: for every $n$,

$$
(e^{x})^{n} \;=\; o\!\left(e^{e^{x}}\right) \quad\text{as } x \to +\infty.
$$

The double exponential outraces any fixed power of the single exponential. This is the analytic shadow of
"a height-2 monomial dominates every height-1 monomial." With these in place, the abstract order is no
empty game: each step up the lexicographic ladder corresponds to a real, verifiable acceleration of
growth.

## Uniqueness: a transseries is its expansion

The final pillar is a uniqueness principle, and it is the most philosophically satisfying. Two
transseries are said to **agree to all orders** if their difference is asymptotically smaller than
*every* transmonomial — smaller than $1/x$, smaller than $1/x^2$, smaller than $1/(e^x)$, smaller than
everything the system can name. The **asymptotic comparison theorem** states:

> If two transseries agree to all orders, they are equal.

Formally, writing the relation as $\mathrm{AgreeToAllOrders}(a, b)$,

$$
\mathrm{AgreeToAllOrders}(a, b) \iff a = b.
$$

There is no "hidden remainder," no infinitesimal ghost lurking below all detectable orders. The
asymptotic expansion of a transseries determines it completely. The proof rests on a feature of the Hahn
valuation: the only "size" strictly above every transmonomial is the symbol $\top$ ("infinitely small"),
and that size is attained by exactly one element — zero. So if the difference is smaller than everything,
the difference is zero.

This relation, it turns out, is an honest **equivalence relation** — reflexive, symmetric, transitive —
because it *is* equality in disguise. And its contrapositive is just as illuminating: every nonzero
transseries fails to agree-to-all-orders with $0$, which is to say every nonzero transseries has a
genuine, detectable leading term. There are no invisible elements.

## Connecting the rigorous field to a working catalog

Finally, the construction builds a bridge to a more hands-on, combinatorial notion of transmonomial — one
that simply records a level (positive for iterated exponentials, negative for iterated logarithms) and a
real exponent, with an ad-hoc "dominance" rule. The bridge theorem shows that, for transmonomials with
positive exponents, this homespun dominance relation coincides *exactly* with the lexicographic order of
the rigorous Hahn-series group. The combinatorial bookkeeping and the deep algebra are two views of the
same object.

There is a subtlety worth savoring here, because it is the kind of detail that separates a careful theory
from a sloppy one. The correspondence *requires* positive exponents. With a negative exponent at the
dominant level — think $(e^x)^{-1}$, which *shrinks* to zero — the naive "level-first" rule disagrees with
true growth order. The rigorous construction does not paper over this; it makes the positivity hypothesis
explicit and load-bearing.

## Why this matters

Transseries are not an idle generalization. They are the natural setting for **asymptotic analysis**: the
art of describing how solutions of differential equations, integrals, and recurrences behave in extreme
regimes. They underpin model theory's spectacular results on the field of "logarithmic-exponential" series
and connect to Conway's surreal numbers, to o-minimality, and to the resurgence theory used in modern
physics to tame divergent perturbation expansions.

What the construction described here delivers is a foundation made of stone rather than sand: a fully
rigorous, ordered, non-power-series field in which the everyday miracle "exp beats everything" is no longer
a limit to be recomputed but a permanent fact of arithmetic — and in which an asymptotic expansion is not
an approximation to a function but, in the formal world, *is* the function. From this base, the longer
program reaches toward real-closedness (square roots and odd-degree roots of every transseries),
truncation-closed subfields tailored to actual EML expansions, and ultimately an expansion map sending each
EML germ to its transseries with a guarantee of uniqueness. The first stones are laid; the cathedral of
growth has its foundation.
