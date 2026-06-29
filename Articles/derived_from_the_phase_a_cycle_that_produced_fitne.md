# When the Fittest Theory Isn't the Simplest: A Cautionary Tale from the Evolution of Mathematics

## Mathematics as a living thing

Imagine the great edifice of mathematics not as a static cathedral of eternal truths, but as a living ecosystem. New ideas are born, compete for attention, mate, and sometimes go extinct. Some theories — like the axioms of arithmetic or the foundations of set theory — are tremendously *fit*: they connect to everything, they let us prove an enormous amount with very little, and they keep reproducing across generations of mathematicians. Others are sterile curiosities that never catch on.

This biological metaphor is more than poetry. If we are willing to attach numbers to "how fit is a theory," we can ask sharp, falsifiable questions. Which theories survive? Is there a "carrying capacity" for foundational ideas? Is there a final, all-conquering "theory of everything," or does mathematics keep climbing forever?

To make this concrete, suppose we measure the **fitness** of a theory $T$ by a simple formula:

$$f(T) = \frac{\text{connections}(T)\cdot\text{proofDensity}(T)}{\text{axiomCount}(T)}.$$

In words: a theory is fit when it links to many other ideas (its *connections*), when it proves a lot per unit of effort (its *proof density*), and when it does so on a slender foundation (a small *axiom count*). Reward the prolific and the parsimonious; penalize the bloated.

A tempting story now writes itself. The fittest theories, surely, are the *simplest* — the ones built from the leanest set of assumptions, the ones that cannot be decomposed into smaller pieces. Call such an irreducible theory **primitive**: nothing smaller sits properly inside it. The intuition is seductive: evolution rewards economy, economy means irreducibility, so *the apex of fitness must be primitive.*

This article is about why that beautiful story is **false** — and about the surprisingly small example that proves it.

## The claim, stated precisely

Let us write down the conjecture that we want to test. We work with a collection of theories carrying three pieces of structure.

First, a **sub-theory order**: we write $S \sqsubset T$ to mean "$S$ is a *proper sub-theory* of $T$" — $S$ is genuinely contained in the larger theory $T$. Second, a **rank** assigning each theory a natural number $\text{rank}(T)$, measuring its structural complexity or depth. Third, the **fitness** value $f(T) \in \mathbb{Q}$ above.

From these we define several notions:

- A theory $T$ is **primitive** if there is no $S$ with $S \sqsubset T$: nothing sits properly inside it, so it cannot be broken into smaller parts.
- A theory $T$ has **maximal fitness** if no theory beats it: $f(U) \le f(T)$ for every $U$.
- A theory $T$ is **rank-minimal among maximal-fitness theories** if it has maximal fitness and, among all maximal-fitness theories, none has smaller rank.
- A **mutation** from $S$ to $T$ is a proper extension that strictly improves fitness: $S \sqsubset T$ and $f(S) < f(T)$. A theory is **terminal** if it admits no fitness-increasing mutation — evolution has nowhere left to climb.

Two reasonable-sounding structural assumptions are usually invoked to support the conjecture:

1. **Extension monotonicity.** Climbing the sub-theory order never hurts fitness: if $S \sqsubset T$ then $f(S) \le f(T)$.
2. **Well-founded rank descent.** Going *down* the sub-theory order strictly decreases rank: if $S \sqsubset T$ then $\text{rank}(S) < \text{rank}(T)$. This guarantees there are no infinite descending chains — you cannot keep finding smaller and smaller sub-theories forever.

The proposed theorem, the one we will refute, is:

> **Every maximal-fitness limit theory is primitive and rank-minimal.**

The proof strategy people reach for is: "Fitness only goes up as you extend (monotonicity), and rank bottoms out (well-foundedness), so the fittest thing must sit at the bottom — it must be irreducible." It *sounds* airtight.

## The two-theory universe that breaks it

Here is the whole counterexample. It needs exactly **two** theories. Call them $\mathsf{base}$ and $\mathsf{ext}$ ("extension"). The entire structure is:

- **Order:** $\mathsf{base} \sqsubset \mathsf{ext}$, and nothing else. So $\mathsf{base}$ is a proper sub-theory of $\mathsf{ext}$, but $\mathsf{ext}$ is not a sub-theory of anything.
- **Rank:** $\text{rank}(\mathsf{base}) = 0$, $\text{rank}(\mathsf{ext}) = 1$.
- **Traits:** both theories have proof density $1$ and axiom count $1$. Their connections differ: $\text{connections}(\mathsf{base}) = 1$, while $\text{connections}(\mathsf{ext}) = 2$.

Plugging into the fitness formula $f(T) = \text{connections}(T)\cdot\text{proofDensity}(T)/\text{axiomCount}(T)$:

$$f(\mathsf{base}) = \frac{1 \cdot 1}{1} = 1, \qquad f(\mathsf{ext}) = \frac{2 \cdot 1}{1} = 2.$$

That is the entire model. Now watch every hypothesis of the conjecture come true — and the conclusion fail.

**Extension monotonicity holds.** The only proper-sub edge is $\mathsf{base} \sqsubset \mathsf{ext}$, and indeed $f(\mathsf{base}) = 1 \le 2 = f(\mathsf{ext})$. Climbing the order helped. ✓

**Well-founded rank descent holds.** The only edge $\mathsf{base} \sqsubset \mathsf{ext}$ has $\text{rank}(\mathsf{base}) = 0 < 1 = \text{rank}(\mathsf{ext})$. Descent strictly drops rank, so there are no infinite descending chains. ✓

**$\mathsf{ext}$ has maximal fitness.** Its fitness $2$ is at least that of every theory: $f(\mathsf{base}) = 1 \le 2$ and $f(\mathsf{ext}) = 2 \le 2$. Nobody beats $\mathsf{ext}$. ✓

**$\mathsf{ext}$ is rank-minimal among maximal-fitness theories.** Which theories are maximal-fitness? Only $\mathsf{ext}$: $\mathsf{base}$ cannot be maximal because $f(\mathsf{ext}) = 2 > 1 = f(\mathsf{base})$. With a single maximal-fitness theory, it is trivially the one of smallest rank. ✓

**$\mathsf{ext}$ is terminal.** A fitness-increasing mutation out of $\mathsf{ext}$ would need some $U$ with $\mathsf{ext} \sqsubset U$. But $\mathsf{ext}$ sits at the top of the order — nothing properly extends it — so no such $U$ exists. Evolution has reached a fixed point. ✓

And yet:

**$\mathsf{ext}$ is NOT primitive.** By the very definition of primitivity, $\mathsf{ext}$ would have to have no proper sub-theory. But $\mathsf{base} \sqsubset \mathsf{ext}$! The fittest, rank-minimal, terminal theory in our universe is *reducible*. ✗

So we have produced a theory $T = \mathsf{ext}$ that is simultaneously of maximal fitness, rank-minimal among maximal-fitness theories, and terminal — **yet fails to be primitive.** The conjecture is refuted. Formally:

$$\exists\, T:\quad \text{MaxFitness}(T)\ \wedge\ \text{RankMinimalAmongMax}(T)\ \wedge\ \text{Terminal}(T)\ \wedge\ \lnot\,\text{Primitive}(T).$$

## Why the "obvious" proof was wrong

The failure is instructive, and once you see it you can never un-see it. The proposed proof confused two completely different kinds of optimality:

- **Terminality is *local*.** It says: from where I stand, there is no uphill step. It is a statement about my immediate neighborhood in the order.
- **Primitivity is *global*.** It says: I am at the very bottom of the order, with nothing beneath me at all.

A mountaineer standing on a high plateau may find no step that climbs higher — they are at a *local* optimum of altitude. That tells them nothing about whether they are standing on bedrock or on a tall stack of geological strata. Our $\mathsf{ext}$ is exactly such a plateau: the fittest place around, but resting squarely on top of $\mathsf{base}$.

The deeper lesson concerns the *direction* of the relationship between fitness and the sub-theory order. The conjecture quietly assumed that being smaller correlates with being fitter — that economy at the bottom of the order would pull the optimum down to a primitive base. But extension monotonicity says the *opposite*: it lets fitness *grow* as you extend upward. With fitness and the order pointing the same way, the optimum drifts to the top, not the bottom — straight to a non-primitive theory. The two hypotheses, monotonicity and well-founded descent, simply do not constrain the optimum's *reducibility* at all.

## What it would take to repair the claim

The counterexample is not merely destructive; it tells us precisely what is missing. The conjecture would become *true* if we flip the offending inequality — if we demand **parsimony** instead of extension monotonicity:

$$S \sqsubset T \ \Longrightarrow\ f(T) \le f(S).$$

Now smaller theories are *at least as fit*, so the search for maximal fitness is pulled *downward*, toward the irreducible base — and a maximal-fitness terminal theory genuinely must be primitive. In our two-theory world, parsimony would force $f(\mathsf{ext}) \le f(\mathsf{base})$, dethroning $\mathsf{ext}$ and crowning the primitive $\mathsf{base}$. Same landscape, opposite inequality, opposite conclusion. The single sign of one comparison is the whole ballgame.

## Why a tiny example matters so much

There is an old discipline in mathematics of refuting grand claims with the smallest possible object. A single irrational number sinks the Pythagorean dream of a rational universe; a single non-planar graph anchors a whole theory of obstructions. Here, two theories and a fraction or two suffice to topple an appealing principle about the evolution of knowledge.

The economy is the point. Because the counterexample uses only finite arithmetic over the rationals, every claim can be checked by exhaustive case analysis — no hidden assumptions, no appeals to intuition, no risk that the refutation secretly smuggles in the very thing it denies. When the model has two elements, "for all theories $U$" means "check $\mathsf{base}$, then check $\mathsf{ext}$," and you are done.

More importantly, the example sharpens our questions. Having seen that monotonicity and well-foundedness are *insufficient* for primitivity, we know exactly which dial to turn: the alignment between fitness and the sub-theory order. We can now state the corrected, parsimony-based theorem with confidence rather than hope, and we can reuse this very two-theory landscape as a regression test for any future framework claiming to derive irreducibility from optimality.

## The bigger picture

The fantasy of a single, simplest, fittest "final theory" sitting at the irreducible base of all mathematics is just that — a fantasy, at least under the structural assumptions people most often invoke. Evolution, whether of organisms or of ideas, does not automatically drive systems toward minimal complexity. It drives them toward whatever the fitness landscape rewards — and if the landscape rewards rich, well-connected, *extended* structures, then the survivors will be exactly that: rich, extended, and decidedly *not* primitive.

That is not a defeat for the project of understanding mathematics as an evolving ecosystem. It is a correction, and corrections are how the ecosystem itself advances. The fittest idea standing at the end of this story is not the simplest one. It is the more honest one: that local optima and global structure are different things, and that conflating them — however natural the temptation — leads us astray. A two-element universe was all it took to make the point permanent.
