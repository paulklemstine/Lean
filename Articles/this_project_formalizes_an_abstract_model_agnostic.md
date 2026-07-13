# The Many Worlds of Mathematics — and the Surprising Arithmetic of "Maybe"

## A question with no answer

In 1878, Georg Cantor asked a question so simple a schoolchild could state it and
so deep it would help reshape the foundations of mathematics. He had just proved
that infinities come in different sizes: the counting numbers $1, 2, 3, \dots$
form the *smallest* infinity, and the points on a line form a strictly *larger*
one. His question — the **Continuum Hypothesis**, or CH — was whether there is
any size of infinity *in between*.

For most mathematical questions, we expect a definite answer, even if it is hard
to find. Is there an even number that is not the sum of two primes? Nobody knows,
but we believe there is a fact of the matter. Cantor's question turned out to be
different, and stranger. In 1940 Kurt Gödel showed that you can never *disprove*
CH from the standard axioms of set theory. In 1963 Paul Cohen showed you can
never *prove* it either, inventing along the way a revolutionary technique called
**forcing**. Put together: from the accepted rules of mathematics, the Continuum
Hypothesis is neither true nor false. It is **independent**.

What are we to make of a mathematical statement that has no truth value? One
influential answer comes from the logician Joel David Hamkins, whose **set-theoretic
multiverse** view holds that there is no single universe of sets in which such
questions must be settled. Instead there are *many* mathematical universes,
equally legitimate, and CH is simply true in some of them and false in others.
Asking "is CH *really* true?" is, on this view, like asking whether a chess move
is legal without first saying which game we are playing.

This article tells two stories woven together. The first makes the multiverse
picture precise and proves, cleanly, that "there is no true CH." The second is a
genuine surprise: the logic of *possibility* and *necessity* across these many
worlds turns out to be **arithmetic** — but a strange arithmetic in which adding
means *taking the minimum* and multiplying means *ordinary addition*. This
"min-plus" algebra is the same one engineers use to find shortest paths in
networks and to decode noisy signals. The bridge between Cantor's infinities and
GPS routing is the heart of what follows.

## Building a multiverse from scratch

To reason carefully we strip the multiverse down to its bare bones. A
**multiverse** consists of three things: a nonempty collection of *universes*, a
supply of *statements* whose truth may vary from universe to universe, and a
*truth relation* telling us, for each universe $u$ and statement $s$, whether "$s$
holds in $u$." That is all. We deliberately say nothing about what a universe
"really is"; we only track where each statement holds.

On this skeleton, five notions capture every shade of truth a statement can have:

- $s$ is **multiverse-true** if it holds in *every* universe;
- $s$ is **multiverse-false** if it holds in *no* universe;
- $s$ is **possibly true** if it holds in *at least one* universe;
- $s$ is **independent** if it holds somewhere *and* fails somewhere;
- $s$ is **undetermined** if it is neither multiverse-true nor multiverse-false.

The first structural fact is a small gem that says exactly what independence
*means*:

> **Independence Theorem.** A statement is independent across the multiverse if and
> only if it is undetermined — that is, it has no multiverse-wide truth value.

The proof is a short logical two-step. If $s$ holds somewhere and fails somewhere,
then the witness where it fails stops it from being multiverse-true, and the
witness where it holds stops it from being multiverse-false; so it is
undetermined. Conversely, if $s$ is not multiverse-true then it must fail
somewhere, and if it is not multiverse-false then it must hold somewhere — which
is precisely independence. The theorem is the formal heart of the slogan: *for a
genuinely independent statement, the question of its truth is meaningless until
you name a universe.*

## A concrete sky with three worlds

Abstraction is safe but bloodless, so we pin down an explicit multiverse with just
three universes, each a landmark from real set theory:

- **$L$**, Gödel's *constructible universe* — the most parsimonious world, where
  the Continuum Hypothesis holds and the principle "$V=L$" (every set is
  constructible) is true, but there are no large cardinals;
- **a Cohen extension** — the world Cohen built by forcing, where CH *fails*;
- **a measurable-cardinal universe** — a richer world containing a *large
  cardinal*, where CH holds but $V=L$ fails.

Every one of these worlds satisfies the base axioms of set theory (ZFC). Recording
which statements hold where in a simple truth table, we can prove, with complete
rigor:

- **ZFC is multiverse-true** — it holds in all three worlds;
- **CH is independent**, hence undetermined: true in $L$ and in the measurable
  universe, false in the Cohen extension. There is *no true CH*;
- **$V=L$ is independent**, and so is **the existence of a large cardinal**;
- **ZFC, by contrast, is determined** — it is not undetermined, showing the
  framework distinguishes settled statements from genuinely open ones;
- **$V=L$ and large cardinals are incompatible in every single world**: no one
  universe can host both. ($L$ is too thin for large cardinals; a measurable
  cardinal is too rich to satisfy $V=L$.)

## Why forcing *guarantees* there is no answer

The concrete table shows CH is independent *in this particular multiverse*. But
Hamkins' view rests on a structural principle: the multiverse is **closed under
forcing**. Cohen's technique lets us pass from any universe to an extension in
which a chosen independent statement flips its truth value. We capture exactly
this: a statement $s$ is **forcing-closed** if from *every* universe there is
another universe — its forcing extension — in which the truth value of $s$ is the
*opposite* of what it was.

This single hypothesis is enough to settle everything:

> **Forcing Theorem.** If a statement is forcing-closed, then it is undetermined:
> it can be neither multiverse-true nor multiverse-false.

The reason is almost tautological once stated. Pick any universe. Forcing hands us
a second universe disagreeing with the first about $s$. So $s$ holds somewhere and
fails somewhere — it is independent, and by the Independence Theorem, undetermined.
This is the precise mathematical content of "there is no true CH": not a survey of
worlds we happen to have built, but a consequence of closure under forcing itself.
And indeed CH *is* forcing-closed in our concrete sky, while ZFC provably is *not*
— you cannot force away an axiom that holds everywhere.

## The twist: possibility and necessity are arithmetic

Now the story turns. Look again at our two most basic modes of truth:

- *possibly true* = holds in **some** universe = a logical **OR** across worlds;
- *multiverse-true* = holds in **every** universe = a logical **AND** across worlds.

We are quantifying — running an OR and an AND — over a finite collection of
worlds. The surprise is that these logical operations are secretly *sums and
products* in a different number system.

Consider the **tropical** (or **min-plus**) semiring. Its elements are numbers
together with a symbol $\infty$; its "addition" $\oplus$ is *taking the minimum*,
and its "multiplication" $\odot$ is *ordinary addition*. This peculiar arithmetic
is the native language of optimization: the cheapest route through a network is a
tropical matrix product, and the most likely sequence of hidden states in a signal
is found by tropical dynamic programming (the Viterbi algorithm).

Now translate truth into tropical numbers with a single dictionary:

$$
\text{true} \;\longmapsto\; 1_{\text{trop}} = 0, \qquad
\text{false} \;\longmapsto\; 0_{\text{trop}} = \infty .
$$

(The names look inverted because in tropical algebra the *multiplicative unit* is
the number $0$ and the *additive unit* is $\infty$.) The magic is that this
dictionary is a **semiring homomorphism** — it respects the operations exactly:

$$
\|a \text{ OR } b\| = \|a\| \oplus \|b\| = \min(\|a\|,\|b\|), \qquad
\|a \text{ AND } b\| = \|a\| \odot \|b\| = \|a\| + \|b\| .
$$

Both are one-line checks over the four Boolean cases, but the consequence is
sweeping. Summing (tropically) over all worlds is just iterated OR; multiplying
(tropically) over all worlds is iterated AND. Therefore:

> **Bridge Theorem.** Over a finite multiverse, a statement is *possibly true* if
> and only if the tropical **sum** of its truth values equals $1$, and it is
> *multiverse-true* if and only if the tropical **product** of its truth values
> equals $1$.

Existence becomes a **min**; universality becomes a **sum**. And independence
acquires a crisp fingerprint. For the Continuum Hypothesis over our three worlds,
the tropical sum is $1$ (so CH is possible) while the tropical product is *not*
$1$ (so CH is not necessary):

$$
\underbrace{\textstyle\bigoplus_u \|CH\|_u = 1}_{\text{possible}}
\qquad\text{and}\qquad
\underbrace{\textstyle\bigodot_u \|CH\|_u \neq 1}_{\text{not necessary}} .
$$

This mismatch — *sum equals one, product does not* — is exactly what independence
looks like when you photograph it with tropical algebra. By contrast ZFC, being
true everywhere, has *both* its tropical sum and tropical product equal to $1$.

## Putting a price on possibility

Once logic has become arithmetic, we can do more than register yes/no answers — we
can attach *costs*. Suppose each universe carries a real number: the "price" of
reaching it, perhaps the length of the forcing construction needed to build it, or
a measure-theoretic weight. Give a world the tropical value equal to its cost when
the statement holds there, and $\infty$ when it fails. The same two big operators
now compute optimization problems:

- the **tropical sum** returns the *cheapest witnessing universe* — the least-cost
  world in which the statement is true. This is precisely a shortest-path
  computation, a Viterbi reading of "possible";
- the **tropical product** returns the *total cost* of a statement true
  everywhere — the aggregate budget of a necessity.

We can prove the cheapest cost is genuinely *attained*: whenever a statement is
possible, there is an actual world realizing the minimal cost, and it is cheapest
among all witnesses. Lowering costs never raises the minimum (cheaper edges,
cheaper path). And the original black-and-white theory reappears as the *zero-cost
slice*: set every price to $0$ and the weighted picture collapses back to the
Boolean bridge, with "possible" and "necessary" reduced to the pure question of
whether the cheapest cost is finite.

In our three-world sky, if $L$ is free, the Cohen extension costs one step of
forcing, and the measurable universe is expensive, then the cheapest witness of
the Continuum Hypothesis is the zero-cost ground model $L$ — yet CH remains *not*
multiverse-true, because it still fails in the Cohen extension. Possibility has
acquired a *magnitude*, not merely a truth value.

## Why this is more than a curiosity

The pleasure here is not just aesthetic. Reframing quantification over worlds as
min-plus arithmetic imports an entire toolkit. Modal logic's "necessarily" and
"possibly" ($\Box$ and $\Diamond$) become tropical matrix operations, so that
iterating a modality is iterating a matrix, and "eventually reachable" becomes the
tropical analogue of a matrix's Kleene star — the very computation that powers
shortest-path algorithms. Independence stops being a bare impossibility result and
becomes a *number*: the price of the cheapest world where a statement is true,
weighed against the price of the cheapest world where it is false.

Cantor's question about the sizes of infinity led, through Gödel and Cohen, to the
discovery that some mathematical questions have no universe-independent answer. The
multiverse view embraces that plurality; the tropical bridge measures it. Between
the abstract heavens of set theory and the concrete arithmetic of shortest paths
runs a single thread — and pulling on it turns "maybe" from a shrug into a
calculation.
