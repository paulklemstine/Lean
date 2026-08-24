# The P vs NP of Cooking

## What a soufflé knows about the hardest problem in computer science

There is a moment, familiar to anyone who has ever cooked, that contains a deep
theorem. You have spent forty minutes on a soufflé. It is in the oven. You cannot
see whether it has risen, and the one thing that would tell you — opening the door,
cutting it — is the one thing that would ruin it. You wait. You hope. And when you
finally look, you learn the answer all at once, or not at all.

Compare that with a salad. You glance at it. One wilted leaf and you know. The
verdict costs you a single look.

The difference between these two experiences is not culinary temperament. It is
mathematics, and it is the same mathematics that underlies the most famous open
problem in computer science: the question of whether *finding* a solution is
fundamentally harder than *checking* one. In the kitchen, that question has an
exact and — remarkably — a *provable* answer. This article is about what happens
when you take the joke seriously.

---

## Recipes as algorithms

Start with the obvious observation: a recipe is an algorithm. It takes inputs
(ingredients), performs operations (chop, fold, bake), and produces an output
(dinner). The natural complexity-theoretic question follows immediately.

Let $R$ be a recipe. Define its **cooking time** $C(R)$ to be the work needed to
produce the dish, and its **verification time** $V(R)$ to be the work needed to
determine whether the dish is good. Is $C(R) > V(R)$? Is checking cheaper than
doing?

Stated that loosely, the question is unanswerable, because "work" means nothing
until you say what a unit of work is. So we make a choice — the same choice that
complexity theorists make when they want theorems instead of conjectures. We
measure everything in **probes**.

A pantry of $n$ ingredients is described by a vector $x = (x_1, \dots, x_n)$ of
bits: each ingredient is fresh or spoiled, whipped or flat, folded or beaten. A
**dish** is a rule $f$ that reads the pantry and returns a verdict, $f(x) \in
\{\text{good}, \text{bad}\}$. Cooking means handling every ingredient, so

$$C(R) = n.$$

Tasting is more interesting. A **tasting strategy** is an adaptive procedure: you
probe one ingredient of the finished dish, see the result, and — crucially — use
what you learned to decide what to probe next. Eventually you announce a verdict.
The cost of a strategy is the number of probes it needs in the worst case, and

$$V(R) = \min\{\text{depth of } T : T \text{ always announces } f\text{'s verdict}\}.$$

This is the decision-tree model, and it is the rare corner of complexity theory
where the big separations are not conjectures. They are theorems.

---

## Tasting is never slower than cooking

The first thing to prove is the one everybody assumes. There is always a brute-force
taster: probe ingredient 1, then 2, then 3, all the way to $n$; by the end you know
the entire pantry, so you know the verdict. Hence

$$V(R) \le C(R) \quad \text{for every recipe.}$$

Checking is never harder than doing. Good — the model has not embarrassed itself.

The second thing to prove is the universal *lower* bound, and it is the workhorse
for everything that follows. Call ingredient $i$ **pivotal** at pantry $x$ if
swapping that one ingredient — and nothing else — flips the verdict. The set of
pivotal ingredients at $x$ is the *sensitivity* of the dish there.

> **Sensitivity Lower Bound.** For every dish $f$ and every pantry $x$, the number
> of pivotal ingredients at $x$ is at most $V(R)$.

The reason is a lovely one-line argument that mathematicians call the *path lemma*.
Run your optimal tasting strategy on $x$; it probes some set of ingredients, at most
$V(R)$ of them. Now suppose some pivotal ingredient $i$ was never probed. Then flip
it. The taster, replaying its probes, sees exactly the same answers it saw before —
it never looked at $i$ — so it delivers exactly the same verdict. But $i$ was
pivotal: the true verdict changed. The taster is wrong. Contradiction. So every
pivotal ingredient gets probed, and there cannot be more of them than there are
probes. $\square$

That single argument is enough to compute the verification cost of essentially every
dish in this article.

---

## Three dishes

**The salad.** Suppose the dish is good exactly when ingredient $i$ is fresh, and
nothing else matters. One probe suffices, and one probe is necessary (a zero-probe
strategy always says the same thing, and this dish does not). So $V = 1$, while
$C = n$. The ratio $C/V = n$ is as extreme as it gets.

**The spoiled-ingredient test.** Now let the dish be bad as soon as *any* single
ingredient is spoiled — the logical OR. Here something delightful happens. If the
dish really is bad, there is a one-probe *proof*: the guilty ingredient. Point at
it, taste it, done. No matter how large $n$ is, badness has a one-bite certificate.

But suppose nothing is spoiled. Then every ingredient is pivotal — spoil any one of
them and the verdict flips — so the sensitivity bound gives $V \ge n$, and combined
with $V \le C = n$ we get $V = n$ exactly.

This is the whole of P versus NP, in a bowl. A *hint* — a garnish pointing at the
guilty ingredient — reduces verification from $n$ probes to $1$. Without the hint,
you must check everything. And here, unlike in the world of Turing machines, this is
not a conjecture:

> **Kitchen P ≠ NP.** For $n \ge 2$, the spoiled-ingredient dish admits a one-probe
> certificate at every bad pantry, yet every deterministic taster requires all $n$
> probes. Verification-with-a-hint is unboundedly faster than verification without
> one.

**The soufflé.** Finally, the dish whose verdict is the *parity* of the pantry: it
rises exactly when an odd number of the $n$ critical steps went right. Parity is the
canonical no-partial-information function, and it behaves exactly like a soufflé.
Flip any ingredient at any pantry and the verdict flips: every ingredient is pivotal
*everywhere*. So $V = n$ — the soufflé is **evasive**, meaning you must probe every
single thing.

Worse, the hint does not help either. A certificate is a set of probes that already
pins the verdict, no matter what the unprobed ingredients turn out to be. For the
soufflé, every certificate at every pantry is the *entire* pantry.

> **Soufflé Theorem.** For the parity dish, every certificate at every pantry is the
> whole pantry. Neither a proof of goodness nor a proof of badness can be shorter
> than a full cook.

This is the honest, provable version of the folklore claim that "soufflé verification
is co-NP-hard." No thermodynamics, no Navier–Stokes — just the combinatorial fact
that the soufflé is hard to verify from *both* sides, which the spoiled-ingredient
dish is not. And one more small theorem confirms the intuition that started this
article: a dish can be judged with zero probes if and only if its verdict was decided
before you cooked. **You cannot tell whether the soufflé rose without cutting into
it.**

---

## The conjecture, and why it is backwards

The original guess ran: quick recipes satisfy $C = V$, hard recipes satisfy $C \gg
V$. It is a natural guess. It is also, in this model, *exactly wrong* — the
inequality runs the other way, and the theorems say so.

Consider the tunable family of dishes: for each $k \le n$, let $f_k$ be the parity of
the *first $k$* ingredients. The pivotal ingredients of $f_k$ are precisely those
first $k$, at every pantry, so the sensitivity bound gives $V \ge k$; and since $f_k$
ignores the rest, $k$ probes suffice. Hence

$$V(f_k) = k, \qquad \frac{C}{V} = \frac{n}{k}.$$

> **Spectrum Theorem.** Every value $k \in \{0, 1, \dots, n\}$ occurs as the exact
> verification cost of a dish on $n$ ingredients, and consequently every ratio
> $C/V = n/k$ in the range $[1, n]$ is realised by an actual recipe.

Now look at the endpoints. $C/V = 1$ — the "break-even" recipe — happens exactly when
$V = n$, which is to say exactly for the *evasive* dishes: the soufflés, the hardest
dishes there are. And $C/V = n$, the maximal gap, is achieved by the salad, the
easiest dish there is.

> **Inversion Theorem.** A non-trivial dish satisfies $C(R) = V(R)$ if and only if it
> is evasive, i.e. maximally hard to verify.

The intuition that misled us is a confusion between *absolute* and *relative* cost.
Salads are cheap to taste in absolute terms; that is exactly why tasting them is a
much better deal than cooking them, and why their ratio is huge. Soufflés are
expensive to taste; tasting one is no bargain at all relative to making one, so their
ratio is $1$. The ratio measures the *discount* verification buys you, and hard
dishes offer no discount.

The same inversion propagates to whole menus. If you run a restaurant with a finite
menu of non-trivial dishes and you measure the aggregate ratio — total cooking time
over total tasting time — then the menu breaks even if and only if *every single dish
on it* is evasive. One salad is enough to tip the whole restaurant off the boundary.

The concept that started this project proposed a test: classify a hundred recipes by
their $C/V$ ratio. Here is that test, carried out exactly. Take $n = 100$ ingredients
and the hundred dishes $f_1, \dots, f_{100}$. Recipe $k$ has cook time $100$ and taste
time $k$, so the ratios sweep the full range from $100$ (a single probe) down to $1$
(the evasive soufflé). Aggregating, the total cook time is $100 \times 100 = 10{,}000$
and the total taste time is $1 + 2 + \dots + 100 = 5050$, so the menu ratio is

$$\frac{10000}{5050} = \frac{200}{101} \approx 1.98.$$

Not $50$, the average of the individual ratios — barely $2$. The reason is that the
aggregate weights each dish by its *verification* work, and the hard dishes dominate
that sum. A menu with a handful of soufflés on it is, in aggregate, nearly break-even
no matter how many salads you add. Any working chef could have told you this.

---

## Almost every recipe is a soufflé

So salads exist and soufflés exist. Which is typical?

Count. A dish on $n$ ingredients is an assignment of a verdict to each of the $2^n$
pantries, so there are $2^{2^n}$ dishes — a staggering number even for $n = 16$.

How many are *quick*? Start at the bottom: a dish tastable in one probe is a
constant, a single-ingredient salad, or the complement of one; there are at most
$2n+2$ of these. For the general count, use a structure theorem: any dish tastable in
$d+1$ probes either has a predetermined verdict or is "probe some ingredient $i$, then
follow one of two dishes each tastable in $d$ probes." Writing $c_d$ for the number of
$d$-quick dishes, this gives the recursion

$$c_{d+1} \le 2 + n \cdot c_d^2,$$

which unwinds to $c_d \le (6n)^{2^d}$. This grows doubly exponentially — but in $d$,
not in $n$. Against $2^{2^n}$ it is nothing.

> **Generic Hardness.** Whenever $2 \cdot (6n)^{2^d} \le 2^{2^n}$, at least half of all
> dishes on $n$ ingredients require more than $d$ probes. Concretely, with sixteen
> ingredients, at least half of all $2^{65536}$ dishes cannot be verified with seven
> probes.

Quick recipes are not merely rare. Against the space of all possible dishes they are
a vanishing accident. The recipes we actually cook — the ones with structure, with
shortcuts, with tell-tale signs — are drawn from an infinitesimal, highly special
corner of the space. Culinary tradition is a compression algorithm for that corner.

---

## Deciding what to taste next

Here is a dish with three ingredients: *if the sauce is on, judge by the fish;
otherwise judge by the soup.* Call it the multiplexer.

An adaptive taster handles it in two probes: taste the sauce, and then — depending on
what you found — taste the fish or the soup. Two probes, always.

Now forbid adaptivity. You must commit to a fixed checklist in advance and taste
exactly those items, whatever you find. How long must the checklist be? All three
items. Every ingredient is pivotal somewhere: the sauce matters when fish and soup
disagree, the fish matters when the sauce is on, the soup when it is off. And a fixed
checklist must contain every ingredient that ever matters, or there will be a pantry
where the unlisted ingredient decides the verdict behind your back.

> **Adaptivity Gap.** The multiplexer requires a nonadaptive checklist of all three
> ingredients but is tasted adaptively with two probes.

This is the kitchen's version of a genuine phenomenon in query complexity: deciding
what to look at next, in the light of what you just found, is strictly more powerful
than deciding in advance. It is why a good cook tastes as they go.

---

## When both proofs are short

We have seen dishes with short proofs of badness (the spoiled-ingredient test) and
dishes with short proofs of nothing (the soufflé). What about a dish with short
proofs *both* ways — every good pantry has a compact certificate of goodness, and
every bad pantry a compact certificate of badness? Must such a dish then be quick to
taste outright, with no hint at all?

The answer is yes, at a price.

> **Certificate Product Theorem.** If every bad pantry has a badness certificate of at
> most $k$ probes and every good pantry has a goodness certificate of at most $m$
> probes, then there is a deterministic adaptive tasting strategy using at most $k
> \cdot m$ probes. In particular, if every verdict has a $c$-probe proof, the dish can
> be tasted outright with $c^2$ probes.

This is the kitchen's statement that $\mathrm{NP} \cap \mathrm{co}\text{-}\mathrm{NP}$
collapses into $\mathrm{P}$ — up to squaring. The proof is a small gem. Its heart is
the observation that a proof of goodness and a proof of badness must **overlap**: if
$S$ certifies "good" at one pantry and $T$ certifies "bad" at another, and $S \cap T$
were empty, you could build a hybrid pantry agreeing with the first on $S$ and the
second on $T$, and it would have to be both good and bad at once.

That overlap is the engine of the strategy. Pick any good pantry and taste its entire
goodness certificate — at most $m$ probes. Whatever you find, the overlap lemma
guarantees that every remaining badness certificate has lost at least one ingredient:
its budget has dropped from $k$ to $k-1$. Recurse. After $k$ rounds of at most $m$
probes each you have spent at most $km$ probes and the badness budget has hit zero,
which means the verdict is forced. That is the whole proof.

The bound is exactly tight where it should be. For the spoiled-ingredient dish, badness
costs one probe and goodness costs $n$, and $1 \cdot n = n$ is precisely the true
verification cost. For the soufflé both certificate costs are $n$, so the theorem only
promises $n^2$ while the truth is $n$ — the theorem is powerless there, as it must be,
because there is nothing to gain.

---

## What the kitchen taught us

Three things survive from all of this, and they are not jokes.

**First**, the analogy is exact once you fix the model. "Cooking versus tasting" is
"input length versus query complexity," and in that model the separation between
verification with and without a hint is not conjectural — it is a theorem, provable in
a page, about a bowl of possibly-spoiled ingredients.

**Second**, the natural intuition about ratios is backwards, and the mathematics is
merciless about it. Break-even recipes are the hardest ones, not the easiest. Whenever
a heuristic and a theorem disagree, it is worth finding out which of the two is
confused; here it was the heuristic, and the error was a mix-up between absolute cost
and relative discount.

**Third**, hardness is the norm and structure is the exception. Almost every
conceivable dish is a soufflé: opaque, evasive, unwilling to reveal anything until you
have examined everything. The recipes we actually cook are the tiny, structured
minority that lets us take shortcuts — a bubbling edge, a golden top, a smell. The
craft of cooking, like the craft of algorithm design, consists almost entirely of
staying inside that minority.

And when you do stray outside it, when you find yourself standing in front of the oven
with no way to know except to look — that is not impatience. That is a lower bound.
