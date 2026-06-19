# The Theorems That Hold Up the Sky

## Why some ideas carry the weight of a thousand others — and yet take only a line to prove

Imagine the whole of mathematics as a vast cathedral. Up in the vaults are the
showpieces: the deep theorems, the famous conjectures, the results that win
prizes. They are spectacular, and they are heavy — their proofs run for hundreds
of pages. But a cathedral is not held up by its ceiling frescoes. It is held up
by a handful of load-bearing stones near the floor, modest blocks that almost no
visitor ever looks at, each one quietly carrying the weight of everything above
it.

This article is about those stones. In mathematics they have a curious double
life: they are *foundational* — almost everything rests on them — and yet they
are *cheap* — their proofs are short, sometimes a single line. We will call them
**anti-gravity theorems**, because they seem to defy a natural intuition. We
expect that the more a result matters, the harder it should be to prove. The
anti-gravity theorems break that expectation. They support an enormous amount of
structure while weighing almost nothing themselves.

The surprise of this story is not just that such theorems exist. It is that, once
you make the idea precise, you can *prove things about them* — clean, exact laws
governing how mathematical weight is distributed across a body of knowledge. And
it is that one of the most tempting guesses about them — a tidy "10% law" — turns
out to be flatly false, and provably so.

---

## Weighing a theorem

To do any of this we first need a way to put a theorem on a scale.

Picture a formal library — a collection of theorems, where each theorem is
proved using some of the others. Draw an arrow from theorem `a` to theorem `b`
whenever `a`'s proof *uses* `b`. Because you can never (on pain of circular
reasoning) use a result to prove itself, these arrows never form a loop. The
picture is a **directed acyclic graph** — a DAG. This is the dependency graph of
mathematics, and every formal library, every textbook, every proof assistant's
internal record is exactly such a graph.

Now we can define weight. The **gravitational weight** of a theorem `b` is the
number of *other* theorems that depend on it:

> **weight(b) = the number of theorems `a` such that `a` depends on `b`.**

A lemma used in one place has weight 1. A workhorse used a hundred times has
weight 100. The commutative law, the triangle inequality, the fact that zero
times anything is zero — these have astronomical weight. They are the
load-bearing stones.

This single definition already behaves beautifully, and its good behavior is the
first thing we can prove rigorously.

---

## Law 1: Weight flows downhill

Here is the first structural law, which in the formal development is the theorem
called **`weight_lt_of_dep`**:

> **If theorem `a` depends on theorem `b`, then weight(a) < weight(b).**

In words: *dependency strictly increases weight.* The thing you lean on is always
heavier than you.

Why is it true? Suppose `a` depends on `b`. Then anything that depends on `a`
also, transitively, depends on `b` — if your proof uses `a`, and `a`'s proof uses
`b`, then your proof ultimately rests on `b` too. So every theorem counted in
weight(a) is also counted in weight(b). But there is at least one extra theorem
in `b`'s count that is not in `a`'s: namely `a` itself. So `b` carries strictly
more than `a`. The inequality is strict, every single time.

This has a lovely consequence. Weight is not just a number; it is a *ruler for
depth*. Because weight strictly decreases as you climb up the dependency ladder
(toward the flashy theorems) and strictly increases as you descend (toward the
foundations), it ranks the entire library by how deep a result sits. The
foundational stones automatically float to the top of the weight ranking. You
never have to *decide* what is fundamental — the arithmetic of dependency decides
for you.

---

## Law 2: Nothing is created, nothing is destroyed

The second law is a conservation principle, formalized as **`sum_weight_eq`**.
Add up the weights of *every* theorem in the library. What do you get?

> **The sum of all weights equals the total number of dependency pairs in the
> library.**

This is the mathematician's version of the handshaking lemma. Every time one
theorem leans on another, that single act of leaning contributes exactly `+1` to
exactly one theorem's weight — the one being leaned on. So the grand total of all
weight in the cathedral is simply the total number of "leanings." Nothing leaks.
Weight is a conserved quantity, perfectly accounted for by the bare count of
dependencies.

This turns a vague, global feeling — "this field has a lot of interconnection" —
into a hard number. The amount of total weight in a library *is* the amount of
dependency in it. They are the same quantity, viewed from two angles.

---

## Law 3: Somebody always carries more than their share

Conservation has teeth. Once you know the total weight equals the total number of
dependency pairs, a counting argument — the pigeonhole principle — forces an
unavoidable conclusion, formalized as **`exists_weight_ge_average`**:

> **In any library, some theorem has weight at least the average.**

If there are `n` theorems and `D` dependency pairs, the average weight is `D/n`,
and at least one theorem must meet or beat it. You cannot build a body of
mathematics in which every result is equally, modestly important. Interconnection
*concentrates*. The moment you have any appreciable density of dependency — say,
more dependency pairs than theorems — somebody is carrying a genuinely heavy load.
There is always a load-bearing stone.

This is the precise sense in which foundational theorems are not an accident or a
matter of taste. They are *forced* by the arithmetic of how proofs connect.

---

## The fan: a guaranteed anti-gravity theorem

So far we have talked about weight. The other half of "anti-gravity" is the
*short proof*. A theorem is **anti-gravity** if it combines the two: high weight
(many dependents) and low proof length (cheap to establish).

> **A theorem is anti-gravity if its weight is at least some threshold τ while its
> proof length is at most some small bound ℓ.**

Do such theorems have to exist? It is easy to build one on purpose. Consider the
**fan**: a single root theorem `r`, and `n` separate theorems each of which uses
`r` and nothing else. Picture a hub with `n` spokes. The root's weight is exactly
`n` — every spoke depends on it — so by making `n` large we make `r` as heavy as
we like. Yet `r` itself sits at the bottom with a one-line proof. The fan is a
machine for manufacturing anti-gravity: arbitrarily high weight, fixed tiny cost.

The fan shows anti-gravity theorems are not exotic. You can always arrange for
one. But arranging for one is different from claiming they are *common*. That
distinction is where the story takes its sharpest turn.

---

## The 10% law that wasn't

A seductive conjecture hangs over this whole subject: that anti-gravity theorems
make up some fixed, universal fraction of any mathematical library — the
prediction was a clean **10%**. It would be wonderful if true. It would mean
mathematics has a kind of constant "load-bearing density," a fingerprint shared
across algebra, geometry, logic, everything.

It is false. And we can prove it is false, twice over, from opposite directions.

**The discrete library.** Take a collection of theorems with *no* dependencies at
all — a pile of unrelated facts, no arrows. Every weight is zero. Nothing meets
any positive threshold. The fraction of anti-gravity theorems is exactly **0%**.
So much for a universal floor.

**The chain.** Now go to the other extreme. Take a single tower:
`t₀` depends on `t₁` depends on `t₂` … all the way up to `tₖ`, each result
standing on the one below. This is a library of `k + 1` theorems. By Law 1, weight
climbs steadily as you descend the tower, and a precise count — the theorem
**`chain_antigravity_card`** — shows that exactly `k` of the `k + 1` theorems clear
the anti-gravity bar. The fraction is `k / (k + 1)`. As the tower grows tall, that
fraction climbs toward **100%**.

So the anti-gravity fraction is not a constant of nature. It is not 10%, and it is
not anything else fixed. The discrete library pins it at 0; the chain drives it to
1; and everything in between is achievable. The fraction is a property of *the
shape of the library*, not of mathematics itself. The tidy universal law
dissolves on contact with two of the simplest examples imaginable.

This is, in its own way, the most valuable result of the whole investigation.
Refuting a clean conjecture is not a failure; it is information. It tells us
exactly what kind of statement *could* be true instead.

---

## What survives, and what comes next

Strip away the conjecture that didn't hold, and look at what remains standing.
Three exact laws:

- **Weight flows downhill** (`weight_lt_of_dep`): every dependency strictly
  increases the weight of the thing depended upon, so weight ranks the whole
  library by depth.
- **Weight is conserved** (`sum_weight_eq`): total weight equals total
  dependency, exactly.
- **Someone always carries the load** (`exists_weight_ge_average`): the average is
  always attained, so heavy foundational theorems are mathematically forced.

And one constructive guarantee — the **fan** — showing that anti-gravity theorems
can always be produced, together with the twin counterexamples that kill the 10%
law.

These results reframe the original question. Instead of asking "what fraction of
theorems are anti-gravity?" (a question with no universal answer), we should ask
how the fraction depends on a *threshold*. Because the three examples already span
the entire range from 0 to 1, the right object of study is not a magic constant
but a **phase transition**: as you raise the weight threshold, the fraction of
theorems that still qualify must fall off, and the interesting science is in *how*
it falls off and *where* the transition sits.

There is more to chase. Law 1 says weight is a strictly decreasing ruler, which
suggests it should *bound the length of the longest dependency chain* — the
deepest result can be no deeper than the weight of the stone it ultimately rests
on. And Law 2's conservation principle hints at a "heavy tail": if a library has
at least as many dependency pairs as theorems, then not only does *someone* carry
an above-average load, but a *positive fraction* of the library must be
load-bearing. These are the natural next theorems, and the framework that proved
the first three is already shaped to reach them.

---

## The quiet stones

Step back from the formalism and the picture is human. Every field has its
unsung load-bearing results — the change-of-variables formula, the snake lemma,
the union bound — that no one frames on a wall but that everything quietly rests
on. We tend to celebrate the heavy theorems at the top of the cathedral, the ones
whose proofs are feats of endurance. But the anti-gravity stones are arguably more
remarkable: they do the most work for the least effort. A single line of proof,
holding up the sky.

What this investigation gives us is a way to *see* them — to weigh a theorem by
its dependents, to watch weight flow downhill and pool at the foundations, and to
prove that those foundations must exist. The grand conjecture, that they always
make up a tidy 10%, turned out to be a mirage. But the deeper truth is sturdier
and more interesting: the load-bearing stones are not a fixed fraction of the
building. They are wherever the architecture decides to put its weight — and the
architecture, we can now prove, always puts it somewhere.
