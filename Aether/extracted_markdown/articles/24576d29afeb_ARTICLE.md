# When "Cause" Becomes a Walk in a Graph

## The hidden geometry of independence

Imagine you are a doctor staring at a tangle of data. Patients who take a certain
drug recover faster — but they also tend to be younger, wealthier, and more
likely to exercise. Does the drug *cause* recovery, or is it just riding along
with all those other advantages? This is the oldest and hardest question in
science: telling the difference between two things that merely *travel together*
and two things where one *makes the other happen*.

For most of the twentieth century, statisticians answered this question with
suspicion and caution. "Correlation is not causation," they intoned, and left it
there. But in the 1980s a quiet revolution began. A handful of researchers —
Judea Pearl foremost among them — realized that causation has a *shape*. If you
draw the variables of a problem as dots, and draw an arrow from each cause to its
direct effects, you get a diagram called a **causal graph**. And remarkably, the
question "are these two variables independent once I account for those other
ones?" turns out to be answerable by *looking at the picture*. You trace paths.
You see whether information can flow. Causation became geometry.

This article is about a small but beautiful piece of that geometry, made airtight.
The central claim — proven here completely, with no gaps — is that the famous
"laws of independence" that statisticians treat as *axioms*, as starting
assumptions handed down from on high, are not assumptions at all. They are
*theorems*. They fall out, almost for free, from one humble idea: **can you walk
from here to there?**

## Reachability: the simplest question in the world

Strip away the probability, the drugs, the patients. Keep only the picture.

We have a finite set of points — call them vertices — and some of them are joined
by lines, or *edges*. This is an **undirected graph**. "Undirected" just means the
lines have no arrowheads: if there is a line between *x* and *y*, you can travel
along it in either direction. Formally, our object is a symmetric relation: if
*x* is adjacent to *y*, then *y* is adjacent to *x*.

Now pick a set of vertices and color them red. Call this set **Z**. The red
vertices are *forbidden ground* — lava. You are allowed to walk along edges, but
you may never set foot on a red vertex. A legal step goes from a non-red vertex,
across an edge, to another non-red vertex.

This single rule defines everything. We say a vertex *u* can **reach** a vertex
*v* while avoiding *Z* if there is a sequence of legal steps — a walk — leading
from *u* to *v* that never touches the lava. (A vertex trivially reaches itself,
the empty walk.) In the language we use to make this precise, reachability is the
*reflexive-transitive closure* of the legal-step relation: "reflexive" because
you can stay put, "transitive" because you can chain walks end to end.

And now the punchline definition. Take three sets of vertices: **A**, **B**, and
the red set **Z**. We say

> **A is separated from B given Z** — written **A ⊥ B | Z** — when no vertex of A
> can reach any vertex of B without stepping on Z.

That's it. Separation means the red set Z forms a *wall*: every route from the A
country to the B country is blocked. In the causal reading, A ⊥ B | Z says "once
you know the values of the variables in Z, learning about A tells you nothing new
about B." The wall of red vertices is exactly the set of facts you have to hold
fixed to sever the connection.

This is the concrete model. Conditional independence — an abstract, slippery,
probabilistic notion — has been turned into a question a child could check with a
finger and a maze: *can I get from A to B without touching the red squares?*

## The laws that were never laws

In the abstract theory of conditional independence, mathematicians wrote down a
list of rules that any sensible notion of independence "ought" to obey. They are
called the **graphoid axioms**, and they read like commandments:

- **Symmetry.** If A is independent of B given Z, then B is independent of A given Z.
- **Decomposition.** If A is independent of a *combined* set B-and-W given Z, then
  A is independent of B alone given Z.
- **Weak Union.** If A is independent of B-and-W given Z, then A stays independent
  of B even after you move W into the conditioning set: A ⊥ B | (Z ∪ W).
- **Contraction.** If A is independent of B given Z, *and* A is independent of W
  given Z-and-B, then A is independent of the whole combined set B-and-W given Z.

For decades these were *postulated*. You assumed them, the way you assume the
rules of chess, and you built theory on top. The deep results of modern causal
inference — Pearl's celebrated **do-calculus**, the algorithms that decide
whether a causal effect can be estimated from data at all — all lean on these
four rules as a foundation.

The discovery at the heart of this work is that, for the graph picture, *you do
not have to assume them*. Every single one is a provable consequence of facts
about walks. Let us see why, in plain words.

**Symmetry is just reversibility.** Our graph is undirected — every edge can be
walked both ways. So if there is a walk from a vertex in A to a vertex in B
avoiding the lava, you can simply *walk it backwards* to get from B to A avoiding
the same lava. No A-to-B route means no B-to-A route. Symmetry of independence is
nothing more than the symmetry of a hallway: if you can get from the kitchen to
the bedroom, you can get from the bedroom to the kitchen.

**Decomposition is just "a part is no bigger than the whole."** If the red wall
blocks all routes from A to the big country B-and-W, then in particular it blocks
all routes from A to the smaller country B, because B is a piece of B-and-W. A
wall that stops you reaching a city stops you reaching any neighborhood of that
city.

**Weak Union is anti-monotonicity — adding lava only helps the wall.** Moving the
vertices of W into the red set Z can only *destroy* walks, never create them. If
A already could not reach B with the smaller lava set, it certainly cannot reach
B with *more* lava. Painting extra squares red never opens a new path. This is the
single most underrated fact about mazes, and here it is an axiom of independence.

**Contraction is the subtle one — and it needs a real idea.** Here is the
situation. Suppose A cannot reach B avoiding Z. Suppose also that A cannot reach W
avoiding the *larger* forbidden set Z-and-B. We want to conclude that A cannot
reach the combined country B-and-W avoiding Z alone. Suppose, for contradiction,
that there *is* a sneaky walk from some vertex *a* in A to some vertex *t* in
B-and-W, avoiding only Z. If *t* lands in B, we have contradicted the first
assumption immediately. So *t* must land in W. But the walk is allowed to pass
*through* B on its way! That is the catch: the second assumption forbids touching
B, but our sneaky walk might cross B freely.

The resolution is a gem of elementary reasoning we call the **first-hitting
decomposition**. Follow the sneaky walk from *a* and watch for the first moment it
sets foot in B. Two cases. Either it *never* touches B — in which case the whole
walk avoids Z-and-B, reaches a W-vertex, and contradicts the second assumption.
Or it touches B for the first time at some vertex; then the portion *before* that
first touch is a walk from *a* into B, avoiding Z, contradicting the *first*
assumption. Either way, a contradiction. The wall holds.

That little case split — "watch for the first time the walk hits the forbidden
zone" — is the engine of the whole edifice. In the formal development it is
isolated as a stand-alone, reusable lemma about reachability in *any* setting,
divorced from graphs and causes entirely. It is the kind of fact that, once you
see it, you wonder how independence theory ever managed without naming it.

## A fifth law the world of probability cannot keep

Here is where the graph picture reveals itself as *more* than a mere model of
probability — it is, in a precise sense, *better behaved*.

There is a fifth rule, **Composition**, that generic probabilistic independence
*does not satisfy*:

- **Composition.** If A is independent of B given Z, *and* A is independent of W
  given Z, then A is independent of the combined set B-and-W given Z.

This sounds obvious, almost insultingly so. If knowing Z makes A irrelevant to B,
and knowing Z makes A irrelevant to W, surely A is irrelevant to both at once? Yet
in probability this *fails*. The classic counterexample: let B and W be two
independent fair coins, and let A be their *exclusive-or* (their parity). Then A is
independent of B (the parity alone tells you nothing about the first coin), and A
is independent of W (likewise), but A is emphatically *not* independent of the
*pair* (B, W) — given both coins, the parity is completely determined! Two
separate ignorances can combine into perfect knowledge.

But in the graph world this pathology cannot happen. If the red wall blocks every
route from A to B, *and* blocks every route from A to W, then it blocks every
route from A to anything in B-or-W — a route to the combined country is just a
route to one of its parts. Composition holds for graph separation, cleanly and
unconditionally. The exclusive-or trickery has no analogue, because reachability
has no way to "combine" two blocked destinations into an open one.

This is the formal signature of a deep idea: graph separation is a **compositional
graphoid**, a strictly stronger structure than the **semi-graphoid** that bare
probability gives you. The geometry is more rigid than the statistics. When your
independence comes from a *graph* — from genuine causal structure rather than
numerical coincidence — you get an extra law for free.

## Why this matters

It is tempting to dismiss all this as bookkeeping. It is not. The graphoid axioms
are the grammar of causal reasoning. Every algorithm that decides whether you can
estimate the effect of a drug from messy observational data — every theorem in
the do-calculus that tells an epidemiologist "yes, you may adjust for age and
income and that will give you the truth," or "no, this effect is impossible to
recover, go run an experiment" — is built on these rules. To *assume* them is to
build a cathedral on faith. To *prove* them is to pour the foundation in concrete.

And the proof teaches a lesson that radiates outward. The four sacred axioms of
independence are not really about probability at all. They are shadows cast by
three childlike facts about getting from one place to another:

- **Reversibility** of an undirected walk gives you symmetry.
- **Anti-monotonicity** — more obstacles never open new routes — gives you weak
  union and decomposition.
- The **first-hitting** trick — watch where a walk first crosses a line — gives
  you contraction.

There is a recurring joy in mathematics when a tower of abstraction turns out to
rest on something you could explain to a curious ten-year-old with a pencil maze.
Conditional independence sounds forbidding. Causal inference sounds like the
exclusive province of statisticians with thick textbooks. But underneath, when
the picture is drawn honestly, it is all just this: *can you walk from here to
there without stepping on the red squares?* Hold the red squares fixed, and the
two countries they wall apart become, in the deepest sense the data can express,
strangers to one another.

The drug and the recovery; the cause and its effect; the wall of facts you must
hold fixed to tell them apart — it is all reachability, all the way down. And now,
for the graph, we know it not by assumption but by proof.
