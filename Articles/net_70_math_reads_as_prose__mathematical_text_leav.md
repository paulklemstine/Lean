# The Knee That Refused to Move

## What a machine needs to remember, and what it needs to know

There is a question that quietly governs the cost of running almost every modern
language model, and it sounds deceptively simple: *how much of the past does the
machine actually need to keep?*

When such a system reads text, it stores a compressed record of everything it has
already seen — a running memory of keys. Each new word is predicted by consulting
that memory. But the memory is expensive: it grows with the length of the text and
it dominates the bill. So engineers do the obvious thing. They throw most of it
away. They keep only the $k$ most useful entries and let the rest evaporate.

The natural fear is that discarding memory ruins predictions. The empirical
surprise, seen again and again, is that it mostly doesn't — up to a point. Plot the
fraction of predictions that survive truncation against the budget $k$, and you get
a curve that climbs steeply, then flattens into a plateau. Somewhere on the way up
there is an elbow: the smallest budget at which the truncated system still agrees
with the full one on, say, $98.7\%$ of the positions. Call it the **knee**, written
$k^{*}$. Everything to the right of the knee is money spent on nothing.

The knee is therefore a number with a price tag. And the question that motivates
this article is: *what does the knee depend on?*

## A prediction, and its refutation

Here is the intuition almost everyone has, including the people who ran the
experiment. Different kinds of text should have different knees, and the harder
text should need more memory.

English prose is comparatively easy to predict. Source code is easier still: it is
riddled with boilerplate, closing brackets, repeated identifiers, and syntax so
rigid that the next token is frequently forced. Classical mathematical writing —
the prose of Hardy and Hilbert, argument after argument of interlocking definitions
— is *much* harder. Symbols get defined in one paragraph and used four paragraphs
later. Whether a letter means a group, a measure or a coordinate depends on a
declaration made a long way back. If any domain should demand a long, richly
populated memory, surely it is mathematics.

So the prediction was made in advance, in three parts:

- **P1.** Mathematical text will need a *larger* budget than prose, because of its
  long-range symbolic references.
- **P2.** Failing that, its budget will at least sit somewhere between prose and
  code.
- **P3.** The alternative — that mathematics lands on *exactly* prose's number —
  would be a coincidence too clean to expect.

The measurement, run with an identical harness on all three domains and differing
only in the bytes of text fed in, came back like this. At a context of $512$
tokens, sweeping the budget: $4$ keys retain $90.7\%$ agreement (fail), $8$ keys
$95.9\%$ (fail), $12$ keys $97.9\%$ (fail, and only about one standard error short),
$16$ keys $98.7\%$ — **pass**. At a context of $1024$: $8$ keys $95.2\%$, $12$ keys
$96.5\%$, $16$ keys $97.8\%$ (fail by about one and a half standard errors), $20$ keys
$98.3\%$ — **pass**.

Prose's knees, measured earlier under the same harness, are $16$ at context $512$ and
$20$ at context $1024$.

Identical. Not close — identical, at both contexts.

And yet mathematics is dramatically harder for the model. Its full-model accuracy
is $0.3262$ at context $512$ against prose's $0.4460$, and $0.3418$ at context $1024$
against prose's $0.4612$. That is a gap of $0.1198$ and $0.1194$ respectively: twelve
percentage points of extra difficulty, and *not one extra key*.

P1 is refuted. P3 is confirmed. The verdict earned a name:
**mathematics reads as prose**.

## Two numbers that look related and aren't

The temptation is to call this a fluke of one corpus. The point of the work
described here is that it is not a fluke at all; it is forced by the shape of the
two quantities involved. They are different kinds of statistic, and once you see
which kinds, the coincidence stops being a coincidence.

Strip the experiment down to its combinatorial skeleton. A **workload** is a finite
list of $n$ prediction positions. Each position $i$ carries two pieces of data:

- its **demand** $r_i$, the smallest budget at which the truncated system still
  reproduces the full system's output at that position; and
- its **correctness bit** $c_i$, recording whether the full system's output there
  was actually right.

From these you can read off everything the experiment reports. The **agreement
curve** is
$$A(k) \;=\; \frac{\#\{i : r_i \le k\}}{n},$$
the fraction of positions already served by a budget of $k$. The **knee at gate $g$**
is
$$k^{*}(g) \;=\; \min\{\,k : A(k) \ge g\,\},$$
the cheapest budget clearing the quality bar. And the **accuracy** is
$$\mathrm{acc} \;=\; \frac{\#\{i : c_i\}}{n}.$$

Now stare at those three formulas. The accuracy is built entirely from the bits
$c_i$. The agreement curve — and therefore the knee — is built entirely from the
demands $r_i$. They read *different columns of the same table*.

That observation, once made precise, is a theorem.

> **Multiset Invariance.** If two workloads have the same multiset of demands, they
> have the same agreement curve at every budget, hence the same knee at every gate —
> no matter what their correctness bits, and therefore no matter what their
> accuracies are.

This is exactly the measured verdict, in its exact form: nothing about the sweep can
see difficulty at all. But one might still object that the two columns, though
formally independent, could be *statistically* welded together in real text. So the
work goes one step further and proves that no such welding is possible in principle:

> **Decoupling.** For every position count $n > 0$, every budget $k$, and every
> achievable accuracy value $j/n$ with $0 \le j \le n$, there exists a workload whose
> knee equals $k$ at *every* gate $g \in (0,1]$ and whose accuracy is exactly $j/n$.

The construction is disarmingly simple: make every position demand exactly $k$ keys,
and mark exactly $j$ of them correct. The map from workloads to the pair
(knee curve, accuracy) is *surjective*. Not merely uncorrelated on this sample —
unconstrained. No inequality of the form "harder text needs more keys" can be true,
because every combination of difficulty and budget is realisable.

## Why the knee is so stubborn: it is a quantile

The deeper explanation comes from identifying the knee exactly. Sort the demands
$r_1, \dots, r_n$ into increasing order. Then:

> **The Quantile Identity.** For a workload on $n$ positions and a gate $g$, the knee
> is the $\lceil g n \rceil$-th smallest demand.

The knee is an **order statistic**. Accuracy, by contrast, is a **mean** — of a
completely different variable. And order statistics are famously indifferent to what
happens away from the relevant rank. This gives a sharp, useful criterion:

> **Exact Gate Criterion.** A budget $k$ clears the gate $g$ if and only if the number
> of positions still unserved at $k$ is at most $(1-g)n$.

Everything else follows. From the criterion you get a Markov-type bound: if the
total demand $\sum_i r_i$ is at most $(1-g)\,n\,(k+1)$, then the knee is at most $k$.
A thin tail of hard positions is *sufficient* for a small budget, however dismal the
predictions.

And you get the robustness statement that explains the whole verdict:

> **Perturbation Robustness.** Suppose in one workload the positions unserved at
> budget $k$ number at most $(1-g)n$. Then any second workload whose unserved set at
> budget $k$ is contained in the first's also has knee at most $k$ — however
> catastrophically its accuracy has fallen.

That is the mechanism behind *mathematics reads as prose*. Yes, mathematical text is
harder. The model gets a lot more of it wrong. But being wrong is a property of the
mean of the correctness column; the knee is a quantile of the demand column, and the
tail of that column — the small minority of positions with genuinely long-range
dependence — did not get fatter. Twelve points of accuracy vanished, and the
$\lceil gn \rceil$-th smallest demand did not budge.

Two further invariances close the loop. First, distorting the quality axis by *any*
strictly increasing function $\psi$ (the abstract form of "this domain is uniformly
harder") and transporting the gate along it leaves the knee exactly where it was: the
knee sees only the *order* of the curve, never its values. Second, mixing two corpora
in any proportion traps the resulting knee between the two constituent knees — so
when the constituents agree, as prose and mathematics do at $16$, the mixture agrees
too, and the reported number does not depend on how the corpus was blended.

## From a theorem to a deployment table

The practical payoff is a table with three rows:

| domain | budget at context $512$ |
|---|---|
| prose | $16$ |
| code | $12$ |
| mathematics | $16$ |

with a rigid shift of $+4$ keys when the context doubles to $1024$: prose $16 \to 20$,
mathematics $16 \to 20$. That shift is itself a theorem — if the larger-context curve
is the smaller-context curve translated by $\delta$, then every knee translates by
exactly $\delta$ — and it means the *shape* of the budget curve is a property of the
architecture and the scale, while the *offset* is a property of the domain. Only
code has a different offset.

But a real fleet does not serve every domain from its own tuned cache size; it picks
a handful of standard sizes. This turns the table into a genuinely combinatorial
optimisation problem, and one worth stating carefully.

An entry $b$ **serves** a domain of knee $k$ at waste tolerance $\delta$ when
$k \le b \le k + \delta$: large enough to clear the gate, not so large as to blow the
over-provisioning budget. So an entry is a *point*, a domain is the *interval*
$[k, k+\delta]$, and the number of standard sizes a fleet needs is the minimum number
of points meeting a family of equal-length integer intervals. Four results pin this
down.

**One entry suffices exactly when the spread is small.** A nonempty set $K$ of knees
can be served by a single cache size if and only if
$\max K \le \min K + \delta$. (The witness, when it exists, is $b = \max K$.)

**Separated knees force distinct entries.** If $S$ is a set of knees, pairwise more
than $\delta$ apart, then *every* valid entry set has at least $|S|$ members — because
no single entry can serve two knees separated by more than $\delta$, so the assignment
of knees to serving entries is injective on $S$. This is a packing lower bound.

**Greedy covers cheaply.** If all knees lie in $[a,b]$, then the arithmetic
progression $b,\, b - (\delta+1),\, b - 2(\delta+1), \dots$ serves all of them, using at
most
$$\left\lfloor \frac{b-a}{\delta+1} \right\rfloor + 1$$
entries. (Anchoring the progression at the top matters: an entry must never fall
*below* the knee it serves.)

**And the two bounds meet.** For the extremal configuration — $m$ knees spaced exactly
$\delta+1$ apart — the greedy cover uses $m$ entries and the packing bound demands $m$
entries. The minimum is *exactly* $m$: a clean min–max, packing equals covering, for
this deployment problem. Neither bound can be improved.

Apply all of this to the measured three-domain table, whose knee set is simply
$\{12, 16\}$, with spread $4$. The single-entry criterion says one cache size suffices
precisely when $\delta \ge 4$. So:

- If you can tolerate four keys of waste on the cheapest domain, the *entire* fleet —
  prose, mathematics **and** code — runs from the single entry $16$.
- If you can tolerate three or fewer, two entries are provably necessary, and two are
  always enough: $\{12, 16\}$.

The threshold $\delta = 4$ is not an arbitrary number. It is exactly one scale
increment — the same $+4$ that appears when the context doubles. The operational
sentence "prose and mathematics share one entry, only code shifts" is precisely the
$\delta \le 3$ regime, and the point at which code rejoins the others is the point at
which your waste budget reaches one increment.

## What this really says

The headline is negative and useful: **prediction difficulty and attention sparsity
are independent coordinates.** Knowing that a corpus is hard tells you nothing about
how much memory it needs. This has now been confirmed three times over, and the
mathematics case is the strongest of them, because it is the case where the intuitive
argument for the opposite conclusion was most compelling.

The structural reason is worth carrying away even if you never touch a language
model. Two summary statistics of the same dataset can look like they must be linked —
both plainly measure "how hard is this?" — and be linked by nothing at all, because
one is a *mean of one variable* and the other a *quantile of another*. The only thing
coupling them is that they were computed from the same rows. And that coupling, as
the decoupling theorem shows, carries no information whatsoever.

The results here come with their limits honestly stated. The mathematical corpus is
classical mathematical *prose* — Hardy and Hilbert, running text — not modern
notation-dense typeset mathematics, where the token statistics could plausibly differ.
It is one corpus blend, though the mixing theorem shows the blend ratio does not
matter. It is one model scale and two context lengths. The natural next probes are
therefore: dense modern notation; non-English domains; whether the $+4$ increment
survives to a context of $4096$; and whether the shape holds at a substantially larger
model.

But the shape of the answer is already clear, and it is not the shape anyone expected.
You can hand a machine the hardest prose humans write — the accumulated argumentative
architecture of classical analysis — watch its accuracy collapse by twelve points, and
find that the budget line in your configuration file does not change by a single key.
The knee refused to move. It was never looking at difficulty in the first place.
