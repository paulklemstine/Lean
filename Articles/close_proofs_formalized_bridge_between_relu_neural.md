# The Fractal Shape of a Proof

## When mathematics becomes a maze

Imagine you are standing at the entrance of an enormous hedge maze. At every
junction the path splits into several corridors. Some of those corridors
eventually lead to the treasure at the center; others wander off into dead
ends. You cannot see the whole maze at once — you only know, at each junction,
how many corridors there are and, somehow, how many of them are "good."

This is, in a surprisingly literal sense, what happens inside a machine that
searches for mathematical proofs. A proof is a chain of small, justified
steps. At each step the machine faces a choice: which rule, which lemma, which
rewriting to apply next. Most choices lead nowhere. A few lead, eventually, to
a complete proof. The collection of all "good" choices forms a hidden skeleton
buried inside an astronomically large tree of possibilities.

The question this article is about is deceptively simple: **how big is that
skeleton, and what does its size tell us about how hard a theorem is to
prove?**

The answer turns out to be a single number — a *dimension* — and it behaves
exactly like the fractal dimensions that describe coastlines, snowflakes, and
the branching of lungs. We will see that proof difficulty has a geometry, that
this geometry has a sharp phase transition, and that the same number can be
read either as a fractal dimension or as a ratio of informational entropies.
Every claim below has been checked, line by line, by a computer that does not
accept hand-waving.

## A maze made of branches

Let us strip the maze down to its mathematical bones. Picture a tree in which:

- every junction splits into exactly **b** corridors (think of `b` as the
  number of tactics or rules the prover could try), and
- out of those `b` corridors, exactly **k** of them are "alive" — they belong
  to at least one path that eventually reaches a valid proof.

We descend to depth **d**, the length of the proof we are hunting for. This
clean object is what we call a **branching search model**, defined by the three
numbers `b`, `k`, `d` together with the natural sanity conditions that there
are at least two corridors to choose between (`b ≥ 2`), at least one of them is
alive (`k ≥ 1`), and you cannot have more good corridors than corridors
(`k ≤ b`).

Two counts fall out immediately. The number of *all* paths of length `d` — every
possible proof attempt — is

$$\text{total leaves} = b^{\,d},$$

while the number of paths that actually work is

$$\text{successful leaves} = k^{\,d}.$$

Both grow explosively with depth. The drama is entirely in the *race* between
them.

## The dimension of difficulty

Here is the central definition. The **search dimension** of a problem with
branching factor `b` and survival count `k` is

$$D \;=\; \frac{\log k}{\log b}.$$

Why this formula? Because it is the box-counting (Hausdorff) dimension of the
set of winning paths, viewed as a fractal living on the "boundary" of the
infinite tree. The boundary carries a natural notion of distance — two infinite
paths are close if they agree for a long initial stretch — and under that
metric the winning set is a self-similar Cantor-like dust whose dimension is
precisely `log k / log b`. You do not need to take that geometry on faith; the
arithmetic of the formula already tells the whole story.

Look at the two extremes.

- If only **one** corridor is ever alive (`k = 1`), the proof is forced: there
  is a unique road to the treasure. Then `log 1 = 0`, so `D = 0`. A
  zero-dimensional fractal is a single point — exactly the lone proof path.
  This is the theorem `searchDim_unique`: for any branching factor,
  `SearchDimension b 1 = 0`.

- If **every** corridor is alive (`k = b`), then any sequence of choices is a
  proof; the theorem is trivial. Now `log b / log b = 1`, so `D = 1`. A
  one-dimensional "fractal" fills the whole boundary line. This is
  `searchDim_full`: `SearchDimension b b = 1`.

Everything interesting happens in between. The dimension always lands in the
closed interval `[0, 1]`: it is never negative (`searchDim_nonneg`) and never
exceeds one (`searchDim_le_one`). So proof difficulty has a universal,
dimensionless scale. A theorem with `D = 0.9` is, in this precise sense, *easy*
— nine-tenths of the way to trivial. A theorem with `D = 0.05` is a needle in a
cosmic haystack.

## Easier means bigger

The scale behaves the way intuition demands. If you discover more ways to prove
something — if more corridors come alive — the search can only get easier, and
the dimension can only go up. Formally, fixing the branching factor `b`, the
dimension is *monotone* in the survival count: whenever `k₁ ≤ k₂`, we have
`SearchDimension b k₁ ≤ SearchDimension b k₂` (`searchDim_mono`). More routes
to success, higher dimension, lower difficulty. There are no paradoxes hiding
in the definition.

## A sharp line in the sand

Now comes the most striking feature: a **phase transition**. There is a single,
razor-thin boundary that separates two qualitatively different worlds, and the
dimension detects it exactly.

The theorem `critical_threshold` states:

$$D = 1 \quad\Longleftrightarrow\quad k = b.$$

The dimension hits its ceiling of `1` *if and only if* every corridor is alive.
The instant even one corridor dies — the moment `k` drops to `b - 1` — the
dimension falls strictly below `1`. Its companion `subcritical_iff` says the
same thing from the other side:

$$D < 1 \quad\Longleftrightarrow\quad k < b.$$

We call `k < b` the **subcritical phase**. It is the realm of genuine search,
where most choices are wrong and the prover must be clever. The line `k = b` is
the **critical threshold**, the only place where brute force always works.

This is not a soft, gradual change. It is a true on/off switch sitting at the
top of the scale, and proving that it is exactly an "if and only if" — that
nothing else can push the dimension to `1` — required the genuine injectivity
of the logarithm on the positive reals.

## Why subcritical search is doomed without cleverness

In the subcritical world, the gap between good paths and all paths is not just
present — it *widens relentlessly* with depth. Two results make this concrete.

First, the raw count: when `k < b`, the number of successful paths is strictly
smaller than the number of total paths at every nonzero depth,
`k^d < b^d` (`subcritical_decay`). The winning set is exponentially sparse.

Second, and more telling, the *odds get worse with every extra step you take*.
Compare the success ratio at depth `d` with the success ratio at depth `d + 1`.
The theorem `decay_ratio_worsens` proves the inequality

$$k^{\,d+1}\, b^{\,d} \;<\; k^{\,d}\, b^{\,d+1},$$

which is just the cross-multiplied way of saying that the fraction of good paths
shrinks as you go deeper. A long proof in a subcritical problem is not merely
hard; it is *harder than the sum of its steps*, because the haystack outgrows
the needle at every level. This is the mathematical signature of why deep
proofs feel disproportionately difficult.

## The same number, told as information

Fractals are one language; information theory is another. Remarkably, the search
dimension is fluent in both.

Define the **search entropy** as the logarithm of the number of winning paths,
`SearchEntropy = log(k^d)`, and the **full-tree entropy** as the logarithm of
the total number of paths, `FullTreeEntropy = log(b^d)`. These are the
Shannon-style information contents of "a successful proof" and "any proof
attempt" respectively.

The **entropy–dimension bridge** (`entropy_dimension_bridge`) states that their
ratio is *exactly* the search dimension:

$$\frac{\text{SearchEntropy}}{\text{FullTreeEntropy}} \;=\; \frac{\log(k^d)}{\log(b^d)} \;=\; \frac{\log k}{\log b} \;=\; D.$$

The depth `d` cancels cleanly — the dimension is a depth-independent, intrinsic
property of the problem. So `D` is simultaneously a geometric quantity (a
Hausdorff dimension) and an informational one (a fraction of total entropy that
is "useful"). That two such different intuitions land on the same number is the
kind of coincidence that signals you have found a real invariant.

There is a dual reading of the leftover information. The quantity `log b − log k`
is the number of bits you must supply, per step, to pin down a winning path
among all paths. The theorem `dimension_info_rate` rewrites it as

$$\log b - \log k \;=\; \log b \,\cdot\, (1 - D).$$

So `1 − D` is the *fraction of each decision that is genuine search*, and `D` is
the fraction that comes for free. At the critical threshold `D = 1`, the search
cost per step is zero — every choice is free. Deep in the subcritical regime,
`1 − D` approaches `1` and almost every bit must be earned. And this information
cost accumulates with perfect linearity across depth: the total information to
specify a length-`d` winning path is exactly `d` times the per-step cost
(`info_content_decomposition`).

## Stacking searches end to end

Real proofs are modular: you prove a lemma, then use it inside a larger
argument. The framework models this as a **composed search** — run one
branching search of shape `(b₁, k₁, d₁)` and then, from its successful frontier,
run a second of shape `(b₂, k₂, d₂)`.

The total number of paths multiplies, `b₁^{d₁} · b₂^{d₂}`, and so does the
number of winning paths, `k₁^{d₁} · k₂^{d₂}`. The natural guarantee — that you
cannot win more often than you try — holds exactly: the successful paths never
exceed the total space (`ComposedSearch.bound`). And in the language of
information, the entropies simply *add*:

$$\log\!\big(k_1^{\,d_1}\, k_2^{\,d_2}\big) \;=\; d_1 \log k_1 + d_2 \log k_2$$

(`same_branching_composition`). Difficulty composes additively in bits, just as
energy or action does in physics — a clean accounting principle for building
big proofs out of small ones.

## Why this matters beyond the maze

It is tempting to dismiss all this as a cute reframing, but the payoff is
real. By assigning every theorem a number in `[0, 1]`, the search dimension
gives us:

- **A difficulty thermometer.** Empirically estimate `b` (how many tactics
  apply) and `k` (how many lead anywhere) and you get a calibrated,
  scale-free measure of how hard a goal is — comparable across domains, proof
  lengths, and provers.
- **A budgeting principle.** Because information cost is `log b · (1 − D)` per
  step and accumulates linearly, you can predict the search effort a deep goal
  will demand *before* committing to it.
- **A design target.** Anything that increases `k` — better lemma libraries,
  smarter heuristics, redundant proof strategies — provably raises `D` and
  lowers difficulty. The monotonicity theorem turns "add more good options"
  from folklore into a guarantee.
- **A bridge.** The same invariant is a fractal dimension to a geometer and an
  entropy ratio to an information theorist. That dual citizenship is what lets
  ideas flow between fields.

The deepest lesson is the phase transition. Search is fundamentally a
subcritical activity: the interesting theorems are precisely the ones where
`k < b`, where most roads are wrong and the winning set is an exponentially thin
fractal dust. The dimension `D` measures, on a universal scale, just how thin
that dust is — and tells you, in advance, how much cleverness the hunt for the
treasure will require.

The next time a machine announces it has found a proof, remember what it really
did: it walked into a maze of size `b^d`, navigated to a fractal of size `k^d`,
and emerged carrying a single thread of dimension `log k / log b` out of the
labyrinth.
