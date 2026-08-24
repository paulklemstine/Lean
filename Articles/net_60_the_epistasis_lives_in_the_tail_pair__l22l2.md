# The Last Two Layers Are One Thing

## A story about pruning, minima, and the arithmetic of what breaks together

Suppose you own a bridge with a hundred cables. You want to save money, so you
hire an engineer to test them. She cuts cable 22 and measures: the bridge sags by
three hundredths of a millimetre. Negligible. She reattaches it, cuts cable 23,
measures again: three hundredths of a millimetre. Also negligible. She writes in
her report that cables 22 and 23 are the two least important cables on the
bridge, and recommends replacing both with cheaper wire.

Then somebody cuts both at once and the deck drops by forty-two hundredths of a
millimetre — seven times the sum of the two individual measurements.

Nothing about the engineer's arithmetic was wrong. What was wrong was the
assumption that the arithmetic *applied*: that the damage caused by two cuts is
the sum of the damage caused by each. This article is about why that assumption
fails, when it fails, and what mathematical object controls the failure. The
setting is not bridges but the internal layers of a large trained language
network — though, as we will see, the mathematics does not care which.

---

## The measurement

Take a trained transformer with twenty-four layers. Impose a sparsification
budget on one layer at a time: keep only the $k = 16$ largest components of its
attention structure and discard the rest. Then measure how much accuracy the
whole network loses on a held-out benchmark. Nothing is retrained.

One layer at a time gives a *solo cost profile*. Most layers are cheap. Layer
$22$ costs $0.03$ points, layer $23$ costs $0.03$ points; layer $12$ costs $0.57$
— nearly twenty times as much. If you had a bit budget to distribute, the solo
profile says unambiguously where to economize: at the very end.

Then prune pairs. Six arms, each compared against the sum of its members' solo
costs:

| arm | layers pruned | joint cost | sum of solo costs | verdict |
|---|---|---|---|---|
| tail | $22, 23$ | $\mathbf{0.42}$ | $\mathbf{0.06}$ | **super-additive, $7\times$** |
| bulk | $12, 15$ | $0.60$ | $0.79$ | sub-additive |
| front | $0, 1$ | $0.25$ | $0.25$ | exactly additive |
| mid | $10, 11$ | $0.40$ | $0.28$ | super-additive, $1.4\times$ |
| cross | $22, 12$ | $0.59$ | $0.60$ | sub-additive |
| tail triple | $21, 22, 23$ | $\mathbf{0.76}$ | $\mathbf{0.19}$ | **super-additive, $4\times$** |

Read that table slowly. The tail pair has the *smallest* solo sum of any arm and
the *largest* blow-up factor: the two layers you would most confidently sacrifice
individually are the two you must least sacrifice together. Nor is this a general
law about pruning — the bulk and cross pairs are *sub*-additive, and the front
pair is additive to the last digit. All three regimes coexist in one network, so
the pre-registered hypothesis that ablation costs are essentially additive is
false in three of six arms, in both directions.

So what *is* the right arithmetic?

---

## Loss as a minimum, not a sum

The move that makes everything else work is to stop thinking of the network's
loss as a sum of contributions and start thinking of it as a **minimum over
routes**.

Picture the network not as a stack of layers but as a bundle of *computation
paths*. Each path is one way the network can get an input to a correct answer. A
path does not use every layer's fine structure; it depends on some subset of
layers, which we call its **support**. And each path, if it is the one the
network ends up relying on, produces some loss.

Now prune a set $S$ of layers. Every path whose support touches $S$ is destroyed
— its route has been paved over. The network falls back on the best of whatever
survives. So the loss after pruning $S$ is

$$\mathrm{netLoss}(S) \;=\; \min\{\,\mathrm{loss}(i) \;:\; \mathrm{supp}(i) \cap S = \emptyset\,\}.$$

And the **cost** of pruning $S$ is the increase in that minimum:

$$\mathrm{cost}(S) = \mathrm{netLoss}(S) - \mathrm{netLoss}(\emptyset).$$

We always include one *fallback path* using no layers at all — a fully lobotomized
network still emits something — so the minimum is never over an empty set.

Two facts follow immediately, and they are the only universal facts there are.
Pruning more can only hurt: if $S \subseteq T$ then $\mathrm{cost}(S) \le
\mathrm{cost}(T)$. And pruning nothing costs nothing: $\mathrm{cost}(\emptyset) = 0$.

The minimum is not incidental. In **tropical arithmetic** — the min-plus
semiring, where "addition" means taking a minimum and "multiplication" means
ordinary addition — that formula is literally a *sum*. Everything below is a
statement about how tropical sums respond to having terms deleted, and ordinary
arithmetic misleads us because we are, without noticing, computing in the wrong
semiring.

---

## Why minima are not additive

Removing two terms from a sum removes exactly their two contributions,
independently. Removing two terms from a minimum can do nothing at all, or
something catastrophic, depending entirely on what lies *underneath* them.

Take three paths: $P$, cheap, using only layer $22$; $Q$, equally cheap, using
only layer $23$; and the expensive fallback $R$, using no layers. Prune layer
$22$ and $P$ dies, but $Q$ survives and is just as good — cost zero. Prune layer
$23$ instead and $P$ covers for $Q$ — cost zero. Prune both and the network drops
all the way to $R$ — cost everything.

Each layer was individually free precisely *because the other one was there to
cover for it*. The solo measurement did not measure the importance of layer $22$;
it measured the availability of layer $23$. That is why we call the pair
**co-adapted**: it is not two components, it is one.

We can prove this intuition is forced, not merely suggestive. **Co-adaptation
theorem.** *Suppose two layers $a$ and $b$ each cost at most $\varepsilon$ on
their own, but pruning both costs more than $\varepsilon$. Then there exists a
near-optimal path that avoids $a$ but uses $b$, and a near-optimal path that
avoids $b$ but uses $a$.* In other words, every backup for one of them
necessarily routes through the other, and nothing else backs either of them up.
The sketch is two lines: the path realizing the cheap solo cost of $a$ is
near-optimal and misses $a$; since the pair is expensive, that path must be
destroyed when both are pruned, so it must use $b$. Symmetrically for $b$.

---

## The bad news: monotone is all you get

At this point one hopes for a *repair* — some weaker law, maybe sub-additivity,
maybe a bounded blow-up factor, that lets per-layer budgets be trusted with a
safety margin. There is no such law. This is a theorem, and it is the sharpest
negative result in the subject.

**Representation theorem.** *A function $c$ assigning a number to each set of
layers is the pruning-cost profile of some path system if and only if
$c(\emptyset) = 0$ and $c$ is monotone ($S \subseteq T \Rightarrow c(S) \le
c(T)$).*

One direction we already have. For the other, one constructs a path system
directly out of the desired profile: index the paths by subsets $A$ of layers,
let path $A$ have support $A$, and give it the loss $c(A^{c})$ — the cost of
pruning everything $A$ does *not* protect. Then path $A$ survives pruning $S$
exactly when $S$ avoids $A$, i.e. when $S \subseteq A^{c}$, and monotonicity makes
$c(S)$ the smallest surviving loss. The profile is reproduced on the nose.

The consequence is stark. **Monotonicity is the only constraint.** Any pattern of
joint costs whatsoever that respects "more pruning cannot help" is realized by an
actual path system. In particular:

- **Unbounded super-additivity.** For any two layers and any target $r > 0$ there
  is a path system in which each layer costs *exactly zero* alone and the pair
  costs exactly $r$ — take the monotone profile charging $r$ as soon as both are
  gone. The blow-up ratio is not $7$, or $70$; it is infinite.
- **Sub-additivity too.** "Any pruning at all costs one point" is also monotone:
  two layers each costing a full point cost only one point together.
- **And exact additivity, in one special case.** If damage is *modular* — each
  layer $i$ carries a fixed penalty $\varphi(i) \ge 0$ and $c(S) = \sum_{i \in S}
  \varphi(i)$ — then disjoint sets have exactly additive costs and all epistasis
  vanishes.

So epistasis is *precisely the failure of the loss landscape to be modular*. The
question "is this network's pruning budget additive?" is not a question about how
big the network is or how well it was trained. It is the question of whether its
tropical loss landscape happens to be modular, and generically it is not.

---

## The right bookkeeping: interactions of every order

If joint costs are not sums of solo costs, what are they sums of? There is a
clean and complete answer, and it is a piece of classical combinatorics — the
**Möbius transform** on the lattice of subsets.

For a cost profile $c$, define the *pure interaction* of a set $A$ of layers as

$$m(A) \;=\; \sum_{B \subseteq A} (-1)^{|A \setminus B|}\, c(B),$$

an alternating sum over all sub-collections. Then:

**Inversion theorem.** *For every set $S$ of layers, $\;c(S) = \sum_{A \subseteq
S} m(A)$.*

Every joint ablation cost splits, uniquely, into a sum of pure interactions of all
orders. The proof is an induction on $S$: adding one fresh layer $x$ turns the
transform at $A \cup \{x\}$ into the difference between the transform of the
$x$-shifted profile and the transform of the profile itself, and the two halves of
the power sum telescope.

The low orders are exactly the quantities we have been measuring:

- **Order 1**: $m(\{i\}) = c(\{i\})$ — the solo cost.
- **Order 2**: $m(\{a,b\}) = c(\{a,b\}) - c(\{a\}) - c(\{b\})$ — *this is the
  epistasis*. The number the experiment reports as "joint minus sum of solos" is
  not an ad-hoc diagnostic; it is the second Möbius coefficient of the cost
  profile.
- **Order 3**: $m(\{a,b,d\}) = c(\{a,b,d\}) - c(\{a,b\}) - c(\{a,d\}) - c(\{b,d\})
  + c(\{a\}) + c(\{b\}) + c(\{d\})$.

And this yields the exact law governing triples:

**Compounding law.** *The excess of a triple ablation over its solo sum equals the
sum of its three pairwise epistases plus one genuinely third-order term:*
$$c(\{a,b,d\}) - \big(c(\{a\})+c(\{b\})+c(\{d\})\big) = m(\{a,b\}) + m(\{a,d\}) + m(\{b,d\}) + m(\{a,b,d\}).$$

Apply this to the measured tail triple, in hundredths of a point. The solo costs
are $13, 3, 3$, total $19$. The three pairwise epistases are $29, 29, 36$, total
$94$. And the third-order term is $-37$. Sum: $19 + 94 - 37 = 76$ — the measured
$0.76$ points, to the digit.

That negative third-order term is the interesting part. The pairwise interactions
*over*-count: the tail's co-adaptation is genuinely a pairwise phenomenon that
saturates. Adding layer $21$ makes things worse, but not as much worse as naive
pair-stacking predicts. The unit has a size, and the size is two.

---

## The combinatorial heart: epistasis is a hitting-set problem

Here is the structural theorem that explains *which* pairs blow up, and it turns
a question about numbers into a question about hypergraphs.

Fix a tolerance $\varepsilon \ge 0$ and call a path **near-optimal** if its loss is
within $\varepsilon$ of the unpruned optimum. These are the routes good enough
that, if any of them survives, you never notice the surgery.

**Hitting-set characterization.** *Pruning a set $S$ costs more than $\varepsilon$
if and only if $S$ meets the support of every near-optimal path* — that is, if and
only if $S$ is a **transversal** (hitting set) of the near-optimal path hypergraph.

The proof is a two-line argument in each direction. If some near-optimal path
survives, its loss bounds the post-pruning minimum, so the cost is at most
$\varepsilon$. Conversely, if the cost exceeds $\varepsilon$, then the path that
actually realizes the post-pruning minimum is worse than $\varepsilon$, and so is
every other survivor — meaning no near-optimal path survives, i.e. $S$ hits them
all.

This is a complete change of subject. "Is this ablation expensive?" is a covering
question. And it immediately defines the number that the whole paper is really
about:

$$\mathrm{epiOrder}(\varepsilon) = \text{the smallest size of an expensive set} = \text{the transversal number of the near-optimal hypergraph}.$$

Below that order everything is affordable; the minimum is attained by some set of
exactly that size. And when every single layer is cheap but some pair is not, the
epistasis order is exactly $2$ — meaning the near-optimal hypergraph has no
single vertex hitting all its edges, but does have a pair that does.

That is the precise sense of the paper's title. **The tail pair is a minimal
size-two transversal.** The front pair, by contrast, is a union of two independent
size-one transversals, which is why it merely adds. The distinction between "these
two layers add up" and "these two layers are one unit" is the distinction between
a union of two small hitting sets and a single irreducible one.

Nor is $2$ special. For *any* block $K$ of $k$ layers there is a path system in
which every collection of fewer than $k$ layers is completely free and the block
itself is costly: its epistasis order is exactly $k$. Co-adapted units of every
width are tropically realizable. Whether deeper networks actually grow wider ones
is the empirical question this raises.

---

## When there is no epistasis: the merge axiom

The negative results say no additivity law holds *in general*. So an additivity
law can only come from extra structure. Which structure, exactly? There is a
clean answer, a single exchange property.

Call a path system **mergeable** if any two paths admit a common refinement: for
every pair of paths $p, q$ there is a path $r$ whose support lies inside
$\mathrm{supp}(p) \cap \mathrm{supp}(q)$ and whose loss is no worse than the worse
of the two. In words: whatever two backup routes can achieve separately, some
route depending only on the layers *both* of them need can achieve as well. There
is no capability that lives in the disagreement between two routes.

**Merge theorem.** *In a mergeable system, for all layer sets $S$ and $T$,*
$$\mathrm{cost}(S \cup T) \le \max\big(\mathrm{cost}(S), \mathrm{cost}(T)\big).$$

Not merely sub-additive — bounded by the *maximum*. The proof is short: take the
optimal survivor $p$ after pruning $S$ and the optimal survivor $q$ after pruning
$T$, merge them into $r$; since $\mathrm{supp}(r)$ sits inside both supports, $r$
survives pruning $S \cup T$, and its loss is at most the worse of the two minima.

Two corollaries make this a practical criterion. First, mergeability implies no
super-additive pair exists anywhere in the system: epistasis is everywhere
non-positive. Second, and this is what a budgeting engineer wants, **per-layer
budgets are safe**: in a mergeable system the cost of pruning *any* set of layers
is at most the largest solo cost among its members. A local two-path exchange
property upgrades, by induction, to a global bound over the entire Boolean lattice
of subsets at once.

Run this backwards and you get a certificate. A single super-additive pair proves
mergeability fails — and one can extract the explicit obstruction: two optimal
backup routes, one avoiding $S$ and one avoiding $T$, such that *every* route
depending only on the layers both of them need is strictly worse than both. The
network has a capability that lives exactly in the disagreement between two
routes, and no amount of local repair recovers it.

That is what "co-adapted during pretraining" means, stated as mathematics. The
last two layers of the measured network do not admit a merge. Their backups
cannot be combined. And so the network's tail is not two prunable components with
small individual price tags; it is one component whose price tag is $0.42$ points
and which happens to be spelled with two layer indices.

---

## What to do about it

The prescription is unglamorous and exact: **treat the tail as one unit for bits
and budgets — never differentiate between its members.** Per-layer accounting is
valid precisely when the merge axiom holds, and the tail pair certifies that it
does not.

The hitting-set characterization also suggests how to find such units without
combinatorial explosion. Searching all $2^{L}$ subsets of a twenty-four-layer
network is hopeless; but co-adapted units are *minimal transversals* of a
hypergraph, and covering structure can be inferred from $O(L^{2})$ pairwise
measurements plus a fit. The conjecture worth testing next is that these units
are *contiguous* — intervals of layers — so that the near-optimal path hypergraph
is the union of "all-of-a-block" edges for some partition of the depth. The
theory guarantees minimal transversals of any size are realizable; whether the
realized ones are blocks is open.

---

## Coda

The engineer's report was not wrong about cable $22$. It was wrong about what a
measurement of cable $22$ measures. In a system whose behaviour is a minimum over
alternatives, a single-component test tells you about the *alternatives*, not
about the component. Cable $22$ was cheap because cable $23$ was intact.

That confusion is not special to bridges or neural networks. It appears wherever
performance is "the best available route" rather than "the sum of the parts":
supply chains with redundant suppliers, power grids with alternative transmission
lines, biological pathways with compensating genes — the word *epistasis* is
borrowed from genetics, where two genes each silent alone can be jointly lethal
for exactly this reason. In all of them the same theorems apply.

What the last two layers of a trained network turned out to be is a minimal
size-two transversal of their own near-optimal path family. Cut one and the other
covers. Cut both and there is nothing underneath.
