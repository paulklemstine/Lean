# The Last Two Layers Are One Thing

### A guided tour of tropical epistasis — why two components that are each free can cost a fortune together

---

## 0 · A cable-cutting parable

You own a bridge with a hundred cables. An engineer tests them one at a time. She
cuts cable 22: the deck sags by $0.03$ mm. Negligible. She reattaches it, cuts
cable 23: $0.03$ mm. Also negligible. She files a report recommending both be
replaced with cheaper wire.

Then somebody cuts both at once and the deck drops by $0.42$ mm — **seven times
the sum of the two individual measurements.**

Nothing about her arithmetic was wrong. What was wrong was the assumption that
arithmetic *applied*: that the damage from two cuts is the sum of the damage from
each. This page is about why that assumption fails, exactly when it fails, and
what mathematical object controls the failure. Our bridge will be a trained
$24$-layer neural network, but as you will see, the mathematics does not care.

By the end you will be able to answer three questions precisely:

1. **What kind of object is an ablation-cost profile?** (Answer: an arbitrary
   monotone function — and *nothing more* is guaranteed.)
2. **What distinguishes a co-adapted pair from an ordinary one?** (Answer: it is a
   *minimal hitting set* of the network's near-optimal computation routes.)
3. **When is per-component budgeting actually safe?** (Answer: exactly when backup
   routes can be *merged* — a local, checkable exchange property.)

---

## 1 · The measurement that started it

Take a trained transformer of depth $24$. Impose a sparsification budget on one
layer at a time — keep only the $k = 16$ largest components of its attention
structure — and measure the held-out accuracy lost. No retraining; the surgery is
done and the patient is graded immediately.

Doing this one layer at a time gives the **solo cost profile**:

$$c(\{0\}) = 0.13,\quad c(\{1\}) = 0.12,\quad c(\{10\}) = c(\{11\}) = 0.14,$$
$$c(\{12\}) = 0.57,\quad c(\{15\}) = 0.22,\quad c(\{21\}) = 0.13,\quad c(\{22\}) = c(\{23\}) = 0.03.$$

Layer $12$ is the expensive one; the last two layers are the two cheapest in the
network. If you had a bit budget to distribute, the solo profile says
unambiguously where to economize: at the very end.

Now prune pairs. Six arms, each compared against the sum of its members' solo
costs:

| arm | layers | joint cost | $\sum$ solo | ratio | class |
|---|---|---|---|---|---|
| **tail** | $22, 23$ | **$0.42$** | **$0.06$** | **$7.00\times$** | **super-additive** |
| bulk | $12, 15$ | $0.60$ | $0.79$ | $0.76\times$ | sub-additive |
| front | $0, 1$ | $0.25$ | $0.25$ | $1.00\times$ | exactly additive |
| mid | $10, 11$ | $0.40$ | $0.28$ | $1.43\times$ | super-additive |
| cross | $22, 12$ | $0.59$ | $0.60$ | $0.98\times$ | sub-additive |
| **tail triple** | $21, 22, 23$ | **$0.76$** | **$0.19$** | **$4.00\times$** | **super-additive** |

Read that slowly. The tail pair has the *smallest* solo sum of any arm and the
*largest* blow-up factor. The two layers you would most confidently sacrifice
individually are the two you must least sacrifice together. And this is not a
general law about pruning — the bulk and cross pairs are *sub*-additive, and the
front pair is additive to the last digit. **All three regimes coexist inside one
network.**

{{visualization:0}}

---

## 2 · The key move: loss is a minimum, not a sum

Everything that follows rests on one change of viewpoint.

Stop thinking of the network's loss as a *sum of contributions*. Think of it as a
**minimum over routes**.

Picture the network not as a stack of layers but as a bundle of **computation
paths**. Each path is one way of getting an input to a correct answer. A path
does not use every layer's fine structure; it depends on some subset of layers,
its **support**. And each path, if the network ends up relying on it, produces
some loss.

Prune a set $S$ of layers. Every path whose support touches $S$ is destroyed —
its route has been paved over. The network falls back on the best of whatever
survives:

$$\mathrm{netLoss}(S) \;=\; \min\{\,\mathrm{loss}(i) \;:\; \mathrm{supp}(i) \cap S = \emptyset\,\},$$

and the **cost** of the ablation is the increase in that minimum,

$$\mathrm{cost}(S) \;=\; \mathrm{netLoss}(S) - \mathrm{netLoss}(\emptyset).$$

We always include a **fallback path** using no layers at all — a fully lobotomized
network still emits something — so the minimum is never over an empty set.

That expression is not incidentally a minimum. In **tropical arithmetic** — the
min-plus semiring, where "addition" $\oplus$ means taking a minimum and
"multiplication" $\odot$ means ordinary addition — it is literally a **sum**:

$$\mathrm{netLoss}(S) = \bigoplus_{i \ \text{survives}} \mathrm{loss}(i).$$

The persistent intuition that "damage adds up" is the intuition of the *wrong
semiring*. Delete two terms from a $+$-sum and you remove exactly two
contributions, independently. Delete two terms from a $\min$ and you may remove
nothing at all, or everything — depending entirely on what lies underneath.

<details>
<summary><b>The two facts that always hold (and the only two)</b></summary>

From the definition alone, two properties are immediate and they are the *only*
universal ones:

- **Normalization.** $\mathrm{cost}(\emptyset) = 0$ — pruning nothing costs
  nothing.
- **Monotonicity.** If $S \subseteq T$ then $\mathrm{cost}(S) \le \mathrm{cost}(T)$
  — pruning more can only hurt. (Proof: every survivor of $T$ is a survivor of
  $S$, so the minimum over the smaller family is at least as large.)

Section 5 shows that *nothing else* is guaranteed. Hold on to that.

</details>

---

## 3 · Play with it: the ablation laboratory

Time to get your hands on the object. Below is a live route family whose ablation
costs reproduce the measured table exactly. Click layers to prune them and watch
routes die, the minimum jump, and the arithmetic break.

**Things to try, in order:**

1. Click layer $22$ alone. Cost $3$ (hundredths of a point). Look at the route
   panel: the surviving best route is *"backup for layer 22 — routes through
   23."* That is the whole story in one line.
2. Click layer $23$ alone. Cost $3$, and the best survivor is the mirror-image
   route through layer $22$.
3. Now click both. Both of those backups die simultaneously and the network drops
   to a route costing $42$. **Each layer was free precisely because the other one
   was covering for it.**
4. Compare with the front pair $\{0, 1\}$: two independent backups, two
   independent deaths, costs simply add.
5. Slide the tolerance $\varepsilon$ in panel 3 and watch the hitting-set
   equivalence hold at every setting.

{{interactive_demo:0}}

<details>
<summary><b>The three-route cartoon behind everything</b></summary>

Strip the model to its bones. Three paths:

- path $P$, cheap, using only layer $22$;
- path $Q$, equally cheap, using only layer $23$;
- path $R$, the fallback, expensive, using no layer.

Prune $22$: $P$ dies, $Q$ survives and is just as good — cost zero. Prune $23$:
$Q$ dies, $P$ survives — cost zero. Prune both: $P$ and $Q$ die together and the
network falls all the way to $R$ — cost everything.

The solo measurement of layer $22$ did not measure layer $22$. It measured *the
availability of layer $23$*. In a system whose behaviour is a minimum over
alternatives, a single-component test tells you about the **alternatives**, not
about the component.

</details>

---

## 4 · Co-adaptation, stated as a theorem

The cartoon suggests that a super-additive pair must back each other up. That is
not merely suggestive — it is forced.

> **Co-adaptation theorem.** Suppose two layers $a$ and $b$ each cost at most
> $\varepsilon$ on their own, but pruning both costs more than $\varepsilon$. Then
> there exists a near-optimal path that avoids $a$ but *uses* $b$, and a
> near-optimal path that avoids $b$ but *uses* $a$.
>
> If moreover both solo costs are exactly zero, those two paths are exactly
> optimal.

Every backup for one member necessarily routes through the other, and nothing
else backs either of them up. That is the precise sense in which the pair is not
two components but one.

<details>
<summary><b>Proof (two lines)</b></summary>

Let $p$ be the path realizing the post-ablation minimum after pruning $\{a\}$.
Then $p$ avoids $a$, and since $\mathrm{cost}(\{a\}) \le \varepsilon$, $p$ is
$\varepsilon$-near-optimal. Because the *pair* is expensive, the ablation
$\{a, b\}$ must destroy $p$ (Section 6 makes this step precise) — and since $p$
avoids $a$, it must use $b$. Swap the roles of $a$ and $b$ for the second
path. $\blacksquare$

</details>

---

## 5 · The bad news: monotone is all you get

At this point one hopes for a *repair*. Maybe not additivity, but sub-additivity?
Or a bounded blow-up factor, so that per-layer budgets can be trusted with a
safety margin? There is no such law, and this is the sharpest negative result in
the subject.

> **Representation theorem.** A function $c$ assigning a number to each set of
> layers is the ablation-cost profile of some route family **if and only if**
> $c(\emptyset) = 0$ and $c$ is monotone.

Monotonicity is the *only* constraint. Every pattern of joint costs whatsoever
that respects "more pruning cannot help" is realized by an actual route family.

<details>
<summary><b>The construction (it is beautifully simple)</b></summary>

Given the desired profile $c$, index the paths by subsets $A$ of layers. Let the
path indexed by $A$ have support $A$ and loss $c(A^{c})$ — the cost of pruning
everything $A$ does *not* protect.

Then path $A$ survives pruning $S$ exactly when $A \cap S = \emptyset$, i.e. when
$S \subseteq A^{c}$. The path $A = S^{c}$ survives and has loss exactly $c(S)$; and
monotonicity says every other survivor has loss $c(A^{c}) \ge c(S)$. So the
minimum is $c(S)$ on the nose. $\blacksquare$

</details>

Three consequences, each realizable inside the model:

- **Unbounded super-additivity.** For any two layers and any target $r > 0$ there
  is a route family in which each layer costs *exactly zero* alone and the pair
  costs exactly $r$. The blow-up ratio is not $7$, or $70$; it is infinite.
- **Sub-additivity too.** "Any pruning at all costs one point" is monotone: two
  layers each costing a full point cost only one point together.
- **And exact additivity, in one special case.** If damage is **modular** — each
  layer $i$ carries a fixed penalty $\varphi(i) \ge 0$ and $c(S) = \sum_{i \in S}
  \varphi(i)$ — then disjoint sets have exactly additive costs and *all* epistasis
  vanishes.

So: **epistasis is precisely the failure of the loss landscape to be modular.**
"Is this network's budget additive?" is not a question about scale or training
quality. It is the question of whether the tropical loss landscape happens to be
modular — and generically it is not.

How generic? The following Monte-Carlo study samples random *realizable* profiles
and counts what happens.

{{demo:1}}

---

## 6 · The combinatorial heart: epistasis is a hitting-set number

Now the theorem that explains *which* pairs blow up, and it converts a question
about numbers into a question about hypergraphs.

Fix a tolerance $\varepsilon \ge 0$ and call a path **near-optimal** if its loss is
within $\varepsilon$ of the unpruned optimum. These are the routes good enough
that, if any one of them survives, you never notice the surgery.

> **Hitting-set characterization.** Pruning a set $S$ costs more than
> $\varepsilon$ **if and only if** $S$ meets the support of every near-optimal
> path — that is, if and only if $S$ is a **transversal** (hitting set) of the
> near-optimal path hypergraph.

<details>
<summary><b>Proof (two lines in each direction)</b></summary>

($\Rightarrow$, contrapositive.) If some near-optimal path survives $S$, its loss
bounds the post-ablation minimum from above, so the cost is at most $\varepsilon$.

($\Leftarrow$.) If the cost exceeds $\varepsilon$, then the path actually realizing
the post-ablation minimum is worse than $\varepsilon$ — and so is every other
survivor, since it is the minimum. Hence no near-optimal path survived: $S$ hit
them all. $\blacksquare$

</details>

This immediately defines the number the whole subject is about:

$$\mathrm{epiOrder}(\varepsilon) \;=\; \min\{\,|S| : \mathrm{cost}(S) > \varepsilon\,\} \;=\; \text{transversal number of the near-optimal hypergraph}.$$

Below that order everything is affordable, and the minimum is attained by some set
of exactly that size. And there is a criterion needing no search at all:

> **Order-two criterion.** If $\varepsilon \ge 0$, every single layer satisfies
> $\mathrm{cost}(\{i\}) \le \varepsilon$, and some pair satisfies
> $\mathrm{cost}(\{a,b\}) > \varepsilon$, then $\mathrm{epiOrder}(\varepsilon) = 2$
> exactly.

That is the invariant separating the tail pair from the front pair, and it is
worth stating twice:

- the **tail pair** is a **minimal size-two transversal** — no single layer hits
  every near-optimal route, but the pair does;
- the **front pair** is a **union of two independent size-one transversals**, each
  covering its own family of routes — which is exactly why its costs add.

The picture below makes this concrete: on the left, the incidence matrix of the
near-optimal routes with candidate ablations tested against it; on the right, the
cost surface over all subsets of the tail triple, showing the *flat, flat, cliff*
signature of a coordinated unit.

{{visualization:1}}

**Nor is $2$ special.** For *any* block $K$ of $k$ layers there is a route family
in which every collection of fewer than $k$ layers is completely free and the
block itself is costly: its epistasis order is exactly $k$. Co-adapted units of
every width are realizable. Whether deeper networks actually grow wider ones is
the central empirical question this raises.

{{algorithm:2}}

---

## 7 · The correct bookkeeping: interactions of every order

If joint costs are not sums of solo costs, what *are* they sums of? There is a
clean, complete, and classical answer: the **Möbius transform** on the lattice of
subsets.

For a cost profile $c$, define the **pure interaction** of a set $A$ of layers as
the alternating sum

$$m(A) \;=\; \sum_{B \subseteq A} (-1)^{|A \setminus B|}\, c(B).$$

> **Inversion theorem.** For every set $S$ of layers, $\;c(S) = \sum_{A \subseteq
> S} m(A)$.

Every joint ablation cost splits, uniquely, into a sum of pure interactions of all
orders. And the low orders are exactly what we have been measuring:

- **Order 1**: $m(\{i\}) = c(\{i\})$ — the solo cost.
- **Order 2**: $m(\{a,b\}) = c(\{a,b\}) - c(\{a\}) - c(\{b\})$ — **this is the
  epistasis.** The number an experiment reports as "joint minus sum of solos" is
  not an ad-hoc diagnostic; it is the second Möbius coefficient of the profile.
- **Order 3**: the genuine three-way term.

> **Compounding law.** The excess of a triple ablation over its solo sum is
> $$c(\{a,b,d\}) - \big(c(\{a\})+c(\{b\})+c(\{d\})\big) = m(\{a,b\}) + m(\{a,d\}) + m(\{b,d\}) + m(\{a,b,d\}).$$

Apply it to the measured tail triple, in hundredths of a point. Solo costs $13, 3,
3$ — total $19$. Three pairwise epistases $29, 29, 36$ — total $94$. Third-order
term: $-37$. And $19 + 94 - 37 = 76$: the measured $0.76$ points, to the digit.

**That negative sign is the interesting part.** The pairwise interactions
*over*-count: the tail's co-adaptation is genuinely a pairwise phenomenon that
**saturates**. Adding layer $21$ makes things worse, but not as much worse as
naive pair-stacking predicts. The unit has a size, and the size is two. This is
falsifiable: in a deeper network, if the co-adapted core widens to three layers,
this coefficient should turn positive.

You can watch the spectrum live in panel 5 of the laboratory above. Here is the
transform itself, computed in $O(k \cdot 2^{k})$ by the subset butterfly rather
than $O(3^{k})$ naively:

{{algorithm:1}}

<details>
<summary><b>Where else this decomposition appears</b></summary>

The Möbius transform on a Boolean lattice is a classical object. In
[cooperative game theory](https://en.wikipedia.org/wiki/Cooperative_game_theory)
it gives the *Harsanyi dividends* of a characteristic function — the value created
by each coalition over and above its sub-coalitions. In
[Boolean function analysis](https://en.wikipedia.org/wiki/Analysis_of_Boolean_functions)
it gives the coefficients of the multilinear extension. And in genetics the
second-order coefficient is literally called *epistasis*, which is where we
borrowed the word: two genes each silent on their own can be jointly lethal, for
exactly the reason developed here — fitness is a best-available-pathway quantity,
and a knockout is expensive precisely when it hits every viable pathway. See
[epistasis](https://en.wikipedia.org/wiki/Epistasis) and
[synthetic lethality](https://en.wikipedia.org/wiki/Synthetic_lethality).

</details>

---

## 8 · When there *is* no epistasis: the merge axiom

The negative results say no additivity law holds in general. So an additivity law
must come from extra structure. Which structure, exactly? There is a clean
answer: a single two-route exchange property.

Call a route family **mergeable** if any two routes admit a common refinement:
for every pair of routes $p, q$ there is a route $r$ with

$$\mathrm{supp}(r) \subseteq \mathrm{supp}(p) \cap \mathrm{supp}(q), \qquad \mathrm{loss}(r) \le \max\big(\mathrm{loss}(p), \mathrm{loss}(q)\big).$$

In words: whatever two backup routes can achieve separately, some route depending
only on the layers *both* of them need can achieve as well. **No capability lives
in the disagreement between two routes.**

> **Merge theorem.** In a mergeable family, for all layer sets $S$ and $T$,
> $$\mathrm{cost}(S \cup T) \le \max\big(\mathrm{cost}(S), \mathrm{cost}(T)\big).$$

Not merely sub-additive — bounded by the *maximum*.

> **Corollary — per-layer budgeting is safe.** In a mergeable family the cost of
> pruning *any* set of layers is at most the largest solo cost among its members.

A *local*, pairwise-checkable exchange property upgrades, by induction, to a
global bound over the entire Boolean lattice of $2^{L}$ subsets at once. That
bound is precisely the licence to do per-layer accounting.

<details>
<summary><b>Proof of the merge theorem, and the obstruction it dualizes to</b></summary>

Take the optimal survivor $p$ after pruning $S$ and the optimal survivor $q$ after
pruning $T$, and merge them into $r$. Since $\mathrm{supp}(r) \subseteq
\mathrm{supp}(p)$ and $p$ avoids $S$, $r$ avoids $S$; likewise $r$ avoids $T$. So
$r$ survives $S \cup T$, and
$$\mathrm{netLoss}(S \cup T) \le \mathrm{loss}(r) \le \max(\mathrm{loss}(p), \mathrm{loss}(q)) = \max(\mathrm{netLoss}(S), \mathrm{netLoss}(T)).$$
Subtract the baseline. $\blacksquare$

Run it backwards and you get a certificate. A single super-additive pair proves
mergeability fails — and one extracts the explicit obstruction: **two optimal
backup routes, one avoiding $S$ and one avoiding $T$, such that every route
depending only on the layers both of them need is strictly worse than both.** The
network stores a capability located exactly in the disagreement between two
routes, and no local repair recovers it.

That is "co-adapted during pretraining", stated as mathematics.

</details>

The algorithm below certifies mergeability, computes the smallest slack $\delta$
under which a family is *approximately* mergeable, and extracts the explicit
obstruction from a super-additive pair.

{{algorithm:3}}

---

## 9 · Putting it together

Everything above is realized by one explicit finite object: a twenty-route family
on twenty-four layers whose ablation costs are exactly the measured table. Run it
and every verdict of the experiment becomes a computation you can check.

{{algorithm:0}}

{{demo:0}}

---

## 10 · What to do about it

The prescription falls out of the mathematics, and it is unglamorous and exact.
Per-layer budget accounting is valid *precisely* under the merge axiom; the tail
pair certifies that the merge axiom fails; therefore per-layer accounting is
invalid for the tail.

> **Treat the last two layers as one unit for bits and budgets. Never
> differentiate between its members.**

For the sub-additive bulk and cross arms, per-layer accounting is conservative and
safe — the theory tells you where you may be lazy as well as where you may not.

More broadly, the hitting-set characterization suggests how to find these units
without combinatorial explosion. Searching all $2^{24}$ subsets is out of the
question; but co-adapted units are *minimal transversals* of a hypergraph, and
hypergraph covering structure can be inferred from $O(L^{2})$ pairwise
measurements plus a fit. The conjecture worth testing next is that in a depth-$L$
transformer these units are **contiguous** — intervals of layers — so that the
near-optimal route hypergraph is the union of "all-of-a-block" edges for some
partition of the depth into intervals. The theory guarantees minimal transversals
of any size are realizable; the open question is whether the realized ones are
blocks.

---

## 11 · Coda: this is not about neural networks

The engineer's report was not wrong about cable $22$. It was wrong about what a
measurement of cable $22$ *measures*.

Wherever performance is "the best available route" rather than "the sum of the
parts", the same three theorems apply: monotonicity is the only universal law;
additivity is a special structure, not a default; and the failure of additivity is
a hitting-set number. Supply chains with redundant suppliers. Power grids with
alternative transmission lines. Biological pathways with compensating genes.
Distributed systems with failover.

In every one of them, a component can look worthless one at a time and be
priceless as a set — because a single-component test in a min-plus world measures
the alternatives, not the component.

What the last two layers of a trained network turned out to be, then, is a minimal
size-two transversal of their own near-optimal route family. Cut one and the other
covers. Cut both and there is nothing underneath.
