# The Shape of a Spreadsheet

## What topology knows about missing data that statistics doesn't

Every data scientist has met the same enemy: the blank cell. A customer survey where half the respondents skipped the income question. A clinical trial where the third blood panel never got run. A merged corporate database where the European division records temperature in Celsius, the American one in Fahrenheit, and nobody wrote it down.

The standard response is statistical. Fill the blanks with the column average. Or find the nearest similar rows and borrow from them. Or build a model of each column given the others and iterate. These methods work, more or less, and they all share a hidden assumption: that the missing entry is a *number to be estimated*.

There is another way to look at a blank cell, and it comes from an unlikely place — the branch of mathematics invented to study how local information assembles into global information. In that language, a table with holes in it is not an incomplete measurement. It is a **partial section of a sheaf**, and the question "can I fill this in?" becomes a question about geometry: *does this local data glue?*

This article is about what happens when you take that reframing completely seriously and follow it to the end. The answer turns out to be surprising in both directions. Some of the things people hoped were true are flatly false — and provably so. And the thing that *is* true is far more beautiful than the thing that was hoped for: the real obstruction to integrating data is not a missing rate at all. It is a **topological invariant of how your data sources overlap**.

---

## Gluing: the oldest idea in the book

Start with a picture. Imagine a map of the world assembled from overlapping regional charts. Each chart is correct on its own patch. When two charts overlap, they had better agree on the overlap — otherwise the coastline will have a kink where you tape them together. If every pair of charts agrees where they meet, you can tape the whole atlas into one seamless global map. That principle — *local data agreeing on overlaps assembles into global data* — is the **sheaf condition**, and it is the organizing idea of a large part of modern geometry.

Now the translation. Let a database have $n$ columns (the features) and $k$ rows (the records), with entries in some alphabet of size $q$. Think of the set of columns as the space. Each row $j$ is a chart: it is defined on the set $U_j$ of columns where its entry is *observed*, and blank elsewhere. A row is a local section, defined over its own patch of the column space. The whole database is a family of local sections over the cover $\{U_1, \dots, U_k\}$.

A **global section** is a complete record $g$ assigning a value $g(c)$ to every column $c$, agreeing with every row wherever that row is observed. The database is **gluable** when at least one global section exists — when the blanks can be filled in consistently.

Here is the first theorem, and it is the one that gets the whole machine running.

> **Gluing Theorem.** A database is gluable if and only if its rows are pairwise consistent: for every column $c$ and every pair of rows $j, j'$ that both observe $c$, the two observed values are equal.

There is no higher obstruction. You do not need to check triples of rows, or quadruples. Pairwise agreement on overlaps is *exactly* gluability. And when the database does glue, one can count exactly how much freedom remains:

> **Section Counting Theorem.** If a database over an alphabet of size $q$ is pairwise consistent, then its set of global sections has exactly $q^{\,u}$ elements, where $u$ is the number of columns observed by *no* row.

The sheaf-theoretic degrees of freedom sit precisely at the totally blank columns. Every column that anybody observed is pinned down; every column nobody observed is completely free. That is a clean and slightly humbling statement: from the sheaf's point of view, a column observed once is as good as a column observed a thousand times.

---

## Three conjectures walk into a bar

The reframing suggests three natural conjectures, and it is worth being honest about how they fared, because the failures are more instructive than a smooth confirmation would have been.

**Conjecture 1.** *The probability that a random database with missing rate $r$ glues is $(1-r)^{C}$ for some combinatorial exponent $C$ counting overlapping constraints — so consistency becomes exponentially unlikely as data gets denser.*

**Conjecture 2.** *Filling blanks by finding the nearest global section beats mean imputation and nearest-neighbour imputation.*

**Conjecture 3.** *Data imputation is a sheaf cohomology problem.*

Conjecture 1 is false, and it is false in the most decisive way available: the true probability law can be computed **exactly**, in closed form, and it is not of that shape. Not for any exponent, not even approximately.

Conjecture 2 is false too, for a reason that is almost funny: for the plain data sheaf, mean imputation *is* sheaf imputation. They agree identically. You cannot beat a method you are secretly already using.

Conjecture 3 is the interesting one. It is true — but only in degree zero, and only for raw records. Push it into degree one, where cohomology actually lives, and the raw data sheaf gives you nothing: its first cohomology vanishes for every possible cover. Yet if you change what you are gluing — from *records* to the *calibrations* between data sources — a genuine, nonvanishing, unfixable obstruction appears, and it is a topological invariant. That is where the real theory is.

Let us take these in turn.

---

## The exact law, and why the missing rate helps

Set up the random model precisely. Each of the $nk$ cells is independently missing with probability $r$; each observed cell carries an independent value drawn uniformly from an alphabet of size $q$. By the Gluing Theorem, the database is a section exactly when, in every column, all the observed entries coincide.

Because cells are independent, the event factorizes over columns. If a column has $j$ observed entries, they all agree with probability $q^{1-j}$ (and with probability $1$ when $j \le 1$). Summing over the $2^k$ possible observation patterns and evaluating the resulting binomial sum in closed form gives:

> **Exact Sheaf Probability Law.** Write $A = r + \frac{1-r}{q}$. Then
> $$P(\text{sheaf}) = \Big( q A^k - (q-1)\, r^k \Big)^{n}.$$

Call the bracketed quantity the **base**, $\beta(k,q,r)$. Three features of this formula demolish the conjecture at once.

First, the exponent is $n$, the number of *columns* — not a binomial coefficient, not $\binom{n}{k}$, nothing combinatorial. Columns are independent trials; each one is a coin flip with success probability $\beta$, and the probability that all $n$ succeed is $\beta^n$. The formula is exponential in the number of features, and there is no room for anything else in the exponent.

Second, and more startling: **the base is increasing in $r$**. The more data you are missing, the *more likely* your database glues. Once you see it, it is obvious — a missing cell is not a constraint waiting to be satisfied, it is a constraint that has been *deleted*. Blanks cannot disagree with each other. In the limit $r \to 1$ everything is blank and everything glues trivially, while at $r = 0$ every cell is present and the probability of universal agreement is $q^{n(1-k)}$, which for $k, q \ge 2$ is exponentially small. The conjectured law $(1-r)^C$ has the sign of the dependence exactly backwards.

Third, a formal impossibility: **no exponent $C$ whatsoever makes $P(\text{sheaf}) = (1-r)^C$ hold on the whole range $r \in [0,1]$.** At $r = 0$ the right-hand side is $1$ while the left-hand side is $q^{n(1-k)} < 1$. One point suffices to kill every candidate exponent.

This is not a refutation that leaves a hole behind. The exact law is *stronger* than the conjecture would have been, and it comes with moments. Let $N$ be the number of global sections — the size of the space of consistent completions. Then

$$\mathbb{E}[N] = (q A^k)^n, \qquad \mathbb{E}[N^2] = \big(q A^k + (q^2-q) r^k\big)^n.$$

The second moment factorizes too, for a pretty structural reason: a column with at least one observation admits *at most one* completion, so there $N$ is a $0/1$ variable and $N^2 = N$; only totally blank columns contribute the extra factor. The two moments pincer the law from both sides, $\mathbb{E}[N]^2/\mathbb{E}[N^2] \le P \le \mathbb{E}[N]$, with the lower bound an *equality* at both $r=0$ and $r=1$.

---

## Finding the right difficulty parameter

The exact law answers "what is the probability", but it does not immediately say "what makes a database hard". For that you want a single scalar knob. The search for it produced the sharpest result of the whole story.

Expand the failure probability $1 - \beta$ binomially, writing $p = 1-r$ for the observation rate. A column with $j$ observed entries occurs with probability $\binom{k}{j} p^j r^{k-j}$ and fails to be consistent with probability $1 - q^{1-j}$. Summing:

> **Weighted Tail Identity.** For every $k$ and every $q \ge 1$,
> $$1 - \beta(k,q,r) \;=\; \sum_{j \ge 2} \binom{k}{j} p^{\,j} r^{\,k-j}\left(1 - q^{\,1-j}\right).$$

The $j = 0$ and $j = 1$ terms cancel *identically* — a column with zero or one observation can never be inconsistent. Only patterns with at least two observations can break anything. And now look at the weights $1 - q^{1-j}$: for every $j \ge 2$ they lie in the interval $[1 - 1/q,\, 1]$. Strip them out and what remains is a pure binomial tail:

$$\mathrm{tail}(k,r) \;=\; \Pr\big[\mathrm{Bin}(k, 1-r) \ge 2\big] \;=\; 1 - r^k - k(1-r) r^{k-1},$$

the probability that at least two of the $k$ rows observe a given column. The weights being confined to $[1-1/q, 1]$ gives immediately:

> **Tail Sandwich Theorem.** For $q \ge 1$ and $r \in [0,1]$,
> $$\left(1 - \tfrac{1}{q}\right)\cdot \mathrm{tail}(k,r) \;\le\; 1 - \beta(k,q,r) \;\le\; \mathrm{tail}(k,r).$$

The two sides differ only by the factor $1 - 1/q$, which is at least $1/2$ whenever $q \ge 2$. So the per-column failure probability is *the binomial tail, up to an absolute constant*. Nothing finer than the tail is needed, and nothing coarser will do.

Raise to the $n$-th power and the whole law is trapped:

$$\big(1 - \mathrm{tail}\big)^n \;\le\; P(\text{sheaf}) \;\le\; \Big(1 - \big(1-\tfrac1q\big)\mathrm{tail}\Big)^n,$$

and hence $P(\text{sheaf}) \le \exp\!\big(-n(1-\tfrac1q)\,\mathrm{tail}\big)$ and $P(\text{sheaf}) \ge 1 - n\cdot\mathrm{tail}$. These two bounds pincer a genuine phase transition. When $n \cdot \mathrm{tail}(k,r) \to 0$ the probability tends to $1$; when $n\cdot \mathrm{tail}(k,r) \to \infty$ it tends to $0$. **The difficulty parameter of a random database is $n \cdot \mathrm{tail}(k,r)$, and the threshold sits at $n\cdot\mathrm{tail}(k,r) \asymp 1$.**

Where did the binomial coefficient of the original conjecture go? It was not spurious — it was *misplaced*. A union bound over the $\binom{k}{2}$ pairs of rows gives $1 - \beta \le \binom{k}{2}(1-\tfrac1q)(1-r)^2$, which is an exact equality when $k=2$: for two rows, $P(\text{sheaf}) = \big(1 - (1-\tfrac1q)(1-r)^2\big)^n$ on the nose. And in the other direction $\mathrm{tail} \ge \binom{k}{2}(1-r)^2 r^{k-2}$. So the pair count is sharp in the sparse regime, to within a factor $r^{k-2}$. The binomial coefficient counts *pairs of rows*, it appears as a linear factor rather than an exponent, and it multiplies $(1-r)^2$ rather than $(1-r)$. Every ingredient of the guess was present; every one was in the wrong slot.

It is worth recording what the tail is *not*. In the dense regime — $k$ large, $r$ fixed strictly between $0$ and $1$ — the quantity $k^2(1-r)^2$ blows up while the tail saturates near $1$. Any claim that the difficulty is "$k^2(1-r)^2$" needs a truncation at $1$ to survive; the honest statement is the one in terms of the tail itself.

---

## Where the topology hides

Now for the part that changes how you should think about data integration.

Cohomology is the machinery that measures the failure of local-to-global gluing. Its degree-zero part records the global sections; its degree-one part records the obstructions — the compatible local families that *cannot* be glued. If imputation were truly a cohomological problem, that first cohomology group is where the action would be.

It is not. For the data sheaf — records, restriction maps given by forgetting columns — one can build the full Čech complex of an arbitrary finite cover and compute both groups:

> **Acyclicity Theorem.** For the data sheaf on any finite cover of the column set by observed supports, $H^0$ is the space of complete records, of dimension $n$; and $H^1 = 0$ for **every** cover.

The data sheaf is *flasque*: any local record extends to a global one, by the crude expedient of choosing, for each column, one index that observes it. Flasque sheaves are acyclic. So the slogan "imputation is a sheaf cohomology problem" is a true but empty statement: it is true in degree $0$, where cohomology is just "the answer", and in degree $1$, where cohomology would be informative, the group is identically zero. **No cohomological quantity can measure imputation difficulty for raw records.** The only obstruction is pairwise disagreement, which the Gluing Theorem already handed us.

Change the coefficients, though, and everything comes alive.

In practice, the hard part of merging databases is rarely a blank cell. It is that Source A and Source B use different units, different baselines, different instrument calibrations. What you observe on the overlap of two sources is not the data but the *offset* between them: $t_{AB}$, the additive correction that reconciles them. The question is whether these pairwise offsets can be explained by per-source recalibrations: is there an $s_A$ for each source with $s_A - s_B = t_{AB}$ for every overlapping pair?

This is a cohomology problem with teeth. Take three sources $A, B, C$, pairwise overlapping, with no common triple overlap. Then:

> **Holonomy Criterion.** A family of pairwise offsets on a three-source cycle is realizable by per-source recalibrations if and only if its **holonomy** $t_{AB} + t_{BC} + t_{CA}$ vanishes.

And so the offset family $(1, 0, 0)$ — a single unit discrepancy between $A$ and $B$, perfect agreement everywhere else — is *unfixable*. Every pairwise comparison is individually consistent; no assignment of per-source corrections reconciles them all. The obstruction space here has dimension exactly $1$: the first cohomology of a circle.

The general theorem is the payoff. Model the integration problem as a finite multigraph — the **nerve** — with a vertex for each source and an edge for each recorded overlap. Then:

> **Nerve Betti Theorem.** For an arbitrary finite family of pairwise overlaps, over any field and in any characteristic,
> $$\dim H^1 \;+\; \#\{\text{sources}\} \;=\; \#\{\text{overlaps}\} \;+\; \#\{\text{connected components}\},$$
> that is, $\dim H^1 = b_1(\text{nerve}) = |E| - |V| + c$, the first Betti number of the overlap graph.

The number of independent unfixable inconsistencies in a multi-source integration problem is a **topological invariant of the overlap pattern**. It does not depend on the missing rate. It does not depend on the number of features. It depends only on how many independent cycles your sources form when you draw the graph of which ones you compared.

The corollaries are practical advice in disguise. $H^1 = 0$ if and only if the nerve is a **forest**: compare your sources along a spanning tree and calibration is always solvable. A star topology — one reference source, everyone else compared only to it — has $\dim H^1 = 0$; it never obstructs. An $m$-cycle has $\dim H^1 = 1$ for every $m$. And a "theta" pattern — two sources compared through three independent overlaps — has $\dim H^1 = 2$: **redundant comparisons, not missing data, create obstructions.** Every extra comparison beyond a spanning tree is an extra chance for your data to be inconsistent in a way no recalibration can fix.

One final twist. Suppose you also have genuine *triple* overlaps, regions where three sources all see the same records. Such an overlap imposes $t_{AB} + t_{BC} = t_{AC}$: the offset along the diagonal must equal the composite along the two sides. Adding these turns on a second layer of the complex, and the rank formula becomes

$$\dim H^1 + \#\{\text{sources}\} + \operatorname{rank} d^1 \;=\; \#\{\text{overlaps}\} + \#\{\text{components}\},$$

whence $\dim H^1 \le b_1$, with equality exactly when the second coboundary has rank zero. **Triple overlaps can only destroy obstructions, never create them.** The sharpest instance: the three-source cycle with $\dim H^1 = 1$, the one with the unfixable $(1,0,0)$ discrepancy, has its obstruction *annihilated* the moment you fill in the triangle. The cohomology really is that of the nerve *complex*, not of its one-dimensional skeleton — and the operational lesson is that finding one shared record across all three sources is worth more than any amount of pairwise reconciliation.

---

## What to take away

The sheaf framing of missing data does not deliver a better imputation algorithm for ordinary tables. It delivers something better: a proof that for ordinary tables there is nothing to deliver. Gluing is exactly pairwise consistency; the completions are counted by the blank columns; mean imputation already computes the sheaf answer; and the cohomology vanishes identically.

What the framing does deliver is the correct probabilistic law — $P(\text{sheaf}) = (qA^k - (q-1)r^k)^n$, exponential in the feature count and *increasing* in the missing rate — together with the identification of $n \cdot \Pr[\mathrm{Bin}(k, 1-r) \ge 2]$ as the one parameter that governs the phase transition, sandwiched between two bounds a constant factor apart.

And it delivers the real theorem, the one nobody was looking for: when you integrate data from many sources, the number of irreconcilable inconsistencies you can suffer is the first Betti number of the graph of your comparisons. That is not a statistical statement. It is a statement about the shape of your data pipeline — and it says, concretely, that the way to build a pipeline that can always be calibrated is to make its comparison graph a tree, or else to go find the triple overlaps that fill in its cycles.

The blank cell, it turns out, was never the interesting hole.
