# Why the Punchline Always Exists (But the Expected Ending Might Not)

## A mathematician's anatomy of a joke

Every joke is a small betrayal.

You are told a story. As it unfolds, your mind quietly does what minds do: it narrows. Out of all the ways the sentence could end, you settle on one — the *expected resolution*. Then the last word arrives and detonates the wrong meaning. The gap between where you were standing and where you land is the laugh.

That description is old — it is essentially the *incongruity theory* of humor — but it has always been metaphorical. Can you *measure* the gap? And if you can, does the measurement obey laws?

Yes to both, and the laws are surprisingly rigid. There is exactly one sensible way to measure comic surprise, up to a choice of unit. That measurement satisfies an exact combination rule when you fuse two jokes, and is stable under paraphrase with a sharp constant. And the central slogan — *the punchline is a colimit, the expected ending is a limit* — turns out to be literally true, in a sense that explains why jokes work at all: the punchline is guaranteed to exist, while the expected ending is not. Along the way, one appealing conjecture gets refuted, and then repaired.

---

## Step one: what is a setup?

Strip a joke down to its logical skeleton. A setup is not a story; it is a *cloud of possible readings*. "A horse walks into a bar" admits the reading where a literal horse enters a literal tavern, the reading where "bar" is a courtroom, the reading where "horse" is a person's nickname, and so on. Each reading sits somewhere on a line of interpretive plausibility: the mundane reading near one end, the outlandish one far away.

So model a **setup** $S$ as a nonempty finite set of real numbers, $S \subset \mathbb{R}$, each number being the position of one available reading on that interpretive line. Setups are ordered by **refinement**: $S \le T$ means $S \subseteq T$, "$T$ is the same joke told so that more readings are audible." Refinement makes setups into a category — objects are setups, and there is exactly one arrow $S \to T$ whenever $S \le T$. (Categories where there is at most one arrow between any two objects are called *thin*; a thin category is just a partially ordered set wearing a different hat.)

The **surprise**, or humor, of a setup is the spread of its readings:

$$H(S) \;=\; \max S - \min S.$$

Two readings that sit almost on top of each other — a pun, where the second meaning is a small step from the first — give $H$ close to $0$. A setup where one reading is mundane and another is wildly remote — absurdism — gives $H$ large. The definition is simple, which is why the first thing to ask is whether it was a *choice*.

---

## Step two: the measurement is forced

Suppose you did not want to commit to a formula. Suppose you only wanted to write down what any reasonable measure of comic surprise must satisfy, and see what survives.

Here is a minimal list. A **humor scale** assigns a number $V(m, M)$ to each pair of extreme readings $m \le M$, subject to three demands.

1. **Position blindness.** A joke is not funnier for being told about bigger numbers: $V(m + c,\, M + c) = V(m, M)$ for every shift $c$. Only the *gap* between readings matters, not where on the interpretive line the gap sits.
2. **Staged telling.** If you tell a joke in two consecutive stages — first stretching the audience's reading from $a$ to $b$, then from $b$ to $c$ — the surprises add: $V(a,b) + V(b,c) = V(a,c)$ whenever $a \le b \le c$.
3. **Monotonicity.** Widening the gap cannot reduce the surprise: if $a \le b \le c$ then $V(a,b) \le V(a,c)$.

**Uniqueness Theorem.** *Every humor scale has the form*
$$V(m, M) = c \cdot (M - m), \qquad c = V(0,1) \ge 0 .$$
*Two humor scales that agree on the unit gap agree everywhere. In particular, the theory has exactly one degree of freedom: the choice of unit.*

So the range formula was not a modelling choice. Position blindness plus staged additivity plus monotonicity pin it down completely. The proof is a functional-equation argument: setting $g(t) = V(0,t)$, the first two axioms force $g(s+t) = g(s) + g(t)$ for nonnegative $s,t$, and the third makes $g$ monotone. A monotone solution of that Cauchy equation on $[0,\infty)$ must be linear — one shows first that $g(ks) = k\,g(s)$ for whole numbers $k$, hence $g(k/n) = g(1)\,k/n$ for rationals, then sandwiches an arbitrary $t$ between $\lfloor nt\rfloor/n$ and $(\lfloor nt\rfloor + 1)/n$ and lets $n$ grow.

Monotonicity is load-bearing. Drop it, and pathological solutions of the Cauchy equation — built from a basis for $\mathbb{R}$ over the rationals — give wildly discontinuous "humor scales" with nothing to do with the range. Comedy, like measurement generally, needs an order axiom to stay sane.

---

## Step three: fusing two jokes obeys an exact law

Comedians combine jokes: a callback fuses a new setup with an old one, sharing a reading. What happens to the surprise?

Write $S \cup T$ for the *joint* setup (both jokes told at once, all readings audible) and $S \cap T$ for the *shared* setup (the readings the two have in common). Assume they share at least one reading, so $S \cap T \ne \varnothing$.

**Submodularity.** *For setups sharing a reading,*
$$H(S \cup T) + H(S \cap T) \;\le\; H(S) + H(T).$$

This is the exact combination law, and it is stronger than the obvious statement. Since $H(S \cap T) \ge 0$ always, submodularity immediately yields **subadditivity**, $H(S \cup T) \le H(S) + H(T)$: a callback can never be funnier than the sum of its parts. But submodularity says more — it quantifies the shortfall. The amount by which the joint joke falls short of the sum of its pieces is at least the surprise already present in their overlap. Comic material shared between two jokes is *counted once*, not twice; the overlap is a discount, and submodularity is the receipt.

The proof is a short case analysis on which setup contributes the overall maximum and minimum, using $\min S \le \min (S\cap T) \le \max(S \cap T) \le \max S$ (and likewise for $T$) together with $\max(A,B) + \min(A,B) = A + B$. One more inequality is worth naming: $H(S \cap T) \le H(S \cup T)$. Fusing never loses surprise; restricting to common ground never gains it.

---

## Step four: the punchline is a colimit — and that is why it always exists

Now the categorical heart of the matter.

In category theory, two dual constructions describe how objects combine. A **product** of $S$ and $T$ is the universal object mapping *into* both — the largest common part, the greatest lower bound. A **coproduct** is the universal object that both map *into* — the smallest thing containing both, the least upper bound. Products are the simplest kind of *limit*; coproducts are the simplest kind of *colimit*.

The slogan of this programme is that the audience's expected resolution is a limit (a consensus, a greatest common reading) and the punchline is a colimit (a fusion, the smallest world in which every reading is simultaneously alive). Both halves are theorems.

**Colimits always exist.** *For any two setups $S, T$, the joint setup $S \cup T$ is their coproduct: the inclusions $S \hookrightarrow S \cup T \hookleftarrow T$ are universal, since any setup containing both $S$ and $T$ contains their union, and in a thin category the mediating arrow is automatically unique.*

**Limits can fail to exist.** *If $S$ and $T$ share no reading — $S \cap T = \varnothing$ — then $S$ and $T$ have **no** product in the category of setups.*

The second statement is where the slogan earns its keep. Why can there be no product? A product would be a setup $P$ with maps into both $S$ and $T$, i.e. $P \subseteq S$ and $P \subseteq T$; so $P \subseteq S \cap T = \varnothing$. But setups are *nonempty* by definition — a joke with no available readings is not a joke — so no such $P$ exists. The would-be limit is empty, and emptiness is not an option.

Read that back into comedy. When two frames share nothing at all, there is no common ground, no consensus reading, no "expected resolution" — the limit is genuinely absent. But there is *always* a fusion: the joint world in which both frames coexist. That is the punchline. Humor is a colimit because the colimit is the construction that never fails. It also explains the asymmetry of comic failure: a joke can be dull, but it cannot lack a punchline. What it can lack is the expectation.

---

## Step five: universality, and a conjecture that dies

The original conjecture was seductive: *the funniest jokes are the universal ones*. In categorical language, fix a setup $S$ and consider all jokes built over it, bounded by some ambient universe $U$ of admissible readings. This forms a category $\mathrm{Joke}(S, U)$: objects are setups $T$ with $S \le T \le U$, arrows are refinements. A joke is **universal** if it is *terminal* — if every other joke over the same setup admits a unique refinement into it.

Half of the conjecture is not merely true, it is true for a trivial and beautiful reason.

**Terminal objects maximise everything.** *Let $\mathcal{C}$ be any category and $F : \mathcal{C} \to \mathbb{R}$ any functor into the real line viewed as a category (one arrow $x \to y$ exactly when $x \le y$). If $T$ is terminal, then $F(X) \le F(T)$ for every object $X$.*

The proof is one line: terminality provides an arrow $X \to T$, functoriality turns it into an arrow $F(X) \to F(T)$, and an arrow in $\mathbb{R}$ *is* the inequality $F(X) \le F(T)$. Dually, initial objects minimise every real-valued functor. Since surprise is a monotone functor on refinements, we get for free: **universal jokes are the funniest**, and moreover **any two universal jokes over the same setup have exactly the same surprise**, so "the humor of the universal joke" is a well-defined invariant.

Now the converse. Is maximal humor enough to make a joke universal? No.

**The converse is false.** *Take $S = \{0, 1\}$ — a two-reading joke, a pun — and $T = \{0, \tfrac12, 1\}$, the same joke with one extra reading in the middle. Then $S \subsetneq T$ but $H(S) = H(T) = 1$. Consequently, in the category of jokes over $\{0,1\}$ bounded by $\{0,\tfrac12,1\}$, the object $\{0,1\}$ has maximal humor while being strictly non-terminal.*

The failure is structural, not a fluke. Surprise sees only the two extreme readings. Every refinement that adds *interior* readings — a nuance, an extra layer, a second-order pun sitting between the literal and the absurd — changes the joke and leaves the measurement untouched. Maximal surprise is attained not at a single object but across a whole upward-closed family of them.

---

## Step six: repairing the conjecture

A refuted conjecture is an invitation to find the right quotient.

Define the **hull** of a setup to be the pair of its extreme readings, $\mathrm{hull}(S) = (\min S, \max S)$, thought of as an interpretive *interval*, ordered by inclusion. Hulls form a category too, refinement maps to inclusion, and surprise obviously factors: $H(S)$ is just the length of $\mathrm{hull}(S)$.

The key lemma says the hull captures *exactly* the blindness of the invariant, no more and no less.

**Exactly what surprise reflects.** *If $S \le T$, then $H(S) = H(T)$ if and only if $\mathrm{hull}(S) = \mathrm{hull}(T)$.*

(Why: along a refinement, $\min T \le \min S \le \max S \le \max T$; if the two lengths agree, both inequalities must be equalities.)

Call a joke **hull-universal** if its hull contains the hull of every other joke over the same setup — that is, if it is terminal *after* collapsing hull-equivalent jokes. Terminality descends to hull-universality, so this is a genuine weakening. And now:

**The universality conjecture, repaired.** *For jokes over a fixed setup inside an ambient universe, a joke has maximal humor **if and only if** it is hull-universal.*

So "funniest = universal" was false on the nose and true after localisation. The counterexample was not a defect in the humor invariant; it was a mismatch of resolution between an invariant that sees intervals and a category that sees sets. Once the category is coarsened to the level the invariant can actually perceive, the equivalence snaps into place. The hull quotient is non-degenerate — $\{0,1\}$ and $\{0,\tfrac12,1\}$ are distinct jokes with identical hulls — which is precisely why the localisation was necessary.

---

## Step seven: is any of this measurable?

A quantity that cannot survive rewording is useless for experiments. Two facts make surprise experimentally respectable.

First, **surprise is a diameter**: $H(S)$ is exactly $\operatorname{diam}(S)$, the diameter of $S$ as a subset of the metric space $\mathbb{R}$. This is not a coincidence of one dimension; it means the whole theory lifts to an arbitrary metric space of readings, with $H(s) = \operatorname{diam}(s)$, and both monotonicity and the subadditivity law generalise verbatim. If you would rather embed readings in a high-dimensional semantic space than on a line, nothing breaks.

Second, **surprise is stable**. Measure the distance between two setups by the Hausdorff distance $d_H$ — the standard way to say two clouds of points are close. Then

$$\bigl| \operatorname{diam}(S) - \operatorname{diam}(T) \bigr| \;\le\; 2\, d_H(S, T),$$

so surprise is $2$-Lipschitz. Specialised to rewording, this is the **paraphrase bound**: if a rewording moves every reading by at most $\varepsilon$, the measured humor changes by at most $2\varepsilon$. And the constant $2$ is sharp — the map $x \mapsto 3x - 1$ moves each of the readings $\{0,1\}$ by exactly $1$, sending the setup to $\{-1, 2\}$ and the humor from $1$ to $3$, a change of exactly $2\varepsilon$.

---

## Step eight: does it correlate with laughter?

Here the theory has to be honest about its limits, and the honesty is the most interesting part.

Given a finite sample of jokes with measured humor $H_i$ and human funniness rating $R_i$, the natural claim is that the empirical covariance
$$\operatorname{Cov}(H, R) \;=\; \frac{1}{n}\sum_i H_i R_i - \Bigl(\frac{1}{n}\sum_i H_i\Bigr)\Bigl(\frac{1}{n}\sum_i R_i\Bigr)$$
is positive: funnier jokes are more surprising. Is that a theorem?

**No.** There is a two-joke dataset with strictly negative covariance — take humors $0, 1$ and ratings $1, 0$. Nothing in the categorical structure forbids an audience from preferring the tamer joke.

What *is* a theorem is the guarded version:

**Correlation under monovariance.** *If the ratings monovary with the humors across the sample — meaning that whenever one joke is rated above another, it is not less surprising — then $\operatorname{Cov}(H,R) \ge 0$.*

This is Chebyshev's sum inequality in disguise. It draws the line precisely: correlation is a property *of the data*, not a consequence of the algebra. The category theory tells you what surprise *is* and how it *combines*; whether people laugh at it is an empirical fact that must be assumed or measured, never derived.

A hundred-joke test suite makes this concrete. Let the $i$-th joke have setup $\{0, i\}$, so $H(J_i) = i$ exactly, and let ratings follow a saturating model $R_i = \min(i, 50)$ — reflecting the ceiling every rating scale eventually hits. This is monotone, hence monovariant, hence the covariance is nonnegative.

But the saturating model hints at something the linear theory cannot capture. Real rating curves are not monotone; they are inverted U's. A little incongruity is delightful, a lot is bewildering. Numerical exploration of synthetic datasets shows the phenomenon vividly: below a surprise threshold, humor and rating correlate at about $+0.97$; above it, at about $-0.97$; pooled together, the correlation collapses to about $+0.04$. (These are figures from simulated data, illustrating the shape of the effect rather than measuring humans.) A naïve global correlation study of comic surprise would find *nothing* — not because the effect is absent but because it changes sign.

The conjecture this suggests is elegant: an inverted-U rating curve is exactly what a *concave* utility applied to a *submodular* surprise valuation must look like. If so, the celebrated inverted-U of arousal psychology is not a fact about people at all; it is a theorem about concavity, and the location of the peak is a computable feature of the valuation.

---

## What the mathematics actually says about comedy

Four claims remain, each of them earned.

**The measurement is not arbitrary.** Ask only that comic surprise ignore absolute position, accumulate across stages, and grow with divergence, and you have already written down the range formula — up to a unit.

**Fusion has a discount.** Combining overlapping jokes obeys an exact submodular law; shared material is counted once.

**The punchline is the construction that cannot fail.** Coproducts of setups always exist; products need not. When two frames share nothing, there is no expected resolution to subvert — but there is always a world in which both are true at once, and that world is the punchline.

**Universality is sufficient, not necessary — until you look at the right resolution.** Terminal jokes maximise every real-valued invariant, so universality certifies maximal surprise. The converse is false, because surprise cannot see interior readings; pass to the hull quotient and it becomes true.

There is something fitting in that last point. The mathematics of jokes is defeated, at first, by exactly the thing that makes jokes hard to analyse: all the interesting nuance lives in the middle, between the literal reading and the absurd one, and the crude measurement of the gap can't see any of it. The repair is not to abandon the measurement, but to be precise about what it is blind to.

Which is, more or less, what a good comedy critic does.
