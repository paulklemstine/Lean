# When Databases Form a Sheaf

### A guided tour of gluing, thresholds, and the topology of data integration

---

Every table you have ever worked with has holes in it. The usual reflex is to treat a blank cell as a number to be estimated. This page is about a different reflex, borrowed from geometry: treat the table as **local information that may or may not assemble into global information**.

That single shift turns imputation into a question about *gluing*, and gluing is the defining property of a **sheaf**. By the end of this page you will know exactly three things:

1. **When a table can be filled in**, and how many ways there are to do it.
2. **How likely** a randomly-holed table is to be fillable — an exact formula, with a surprise in the sign.
3. **Where the real obstruction to integrating data lives** — and it is not in the holes at all. It is a *topological invariant* of how your data sources overlap.

Let's begin by playing.

---

## Part 1 · The gluing sandbox

Picture a world map assembled from overlapping regional charts. Each chart is right on its own patch. Where two charts overlap they had better agree, or the coastline will kink when you tape them together. If every pair agrees on its overlap, the whole atlas glues into one seamless map.

Now translate. Let the **columns** of a table be the space. Each **row** is a chart: defined on the set of columns where its entry is observed, blank elsewhere. A **global section** is a complete record agreeing with every row wherever that row speaks. A table **glues** when a global section exists.

Click cells in the sandbox below. Watch what makes gluing succeed and fail.

{{interactive_demo:0}}

<details>
<summary><b>The Gluing Theorem — statement and proof</b></summary>

> **Theorem (Gluing = pairwise consistency).** A table glues if and only if for every column $c$ and every pair of rows $j,j'$ that both observe $c$, the observed values are equal.

*Proof.* ($\Rightarrow$) If $g$ is a global section and $D(j,c)=v$, $D(j',c)=v'$, then $v=g(c)=v'$.

($\Leftarrow$) Define $g(c)$ to be the common observed value in column $c$ if any row observes $c$, and an arbitrary alphabet element otherwise. Pairwise consistency makes this well defined, and by construction $g$ agrees with every row. $\blacksquare$

The content is what is *absent*: no condition on triples, quadruples, or anything higher. Agreement on pairwise overlaps is exactly gluability. This is the combinatorial shadow of a deeper fact we will meet in Part 4 — the data sheaf is **acyclic**.
</details>

<details>
<summary><b>Counting the completions — where the freedom lives</b></summary>

> **Theorem (Section counting).** If a table over an alphabet of size $q$ is pairwise consistent, its set of global sections has exactly $q^{\,u}$ elements, where $u$ is the number of columns observed by *no* row.

*Proof.* The section set is a **product** set: it is $\prod_c \mathrm{Val}(c)$, where $\mathrm{Val}(c)$ is the set of values compatible with column $c$. An unobserved column has $\mathrm{Val}(c)$ equal to the whole alphabet, of size $q$; an observed column has all observed entries equal to a single $v$, so $\mathrm{Val}(c)=\{v\}$. Multiply. $\blacksquare$

A slightly humbling corollary: **a column observed once is as pinned down as a column observed a thousand times.** From the sheaf's point of view, repeat observations buy consistency risk, not information.
</details>

Try the **"mask a ground truth"** button several times. It always glues — at any missing rate. That is a theorem too: *masking never breaks the sheaf condition*, because every observed entry of a column is a copy of the same underlying value. Keep this in mind; it is about to demolish a very plausible conjecture.

---

## Part 2 · A conjecture, and what actually happens

Here is the guess that started this investigation:

> *The probability that a random table with missing rate $r$ glues is $(1-r)^{C}$, where $C$ counts overlapping constraints. Consistency becomes exponentially unlikely as constraints pile up.*

It is wrong in every particular — and the way it is wrong is more interesting than the way it might have been right.

Set up the random model honestly. Each of the $nk$ cells is independently missing with probability $r$; each observed cell carries an independent value drawn uniformly from an alphabet of size $q$. Then the event "the table glues" factorizes over columns, because cells are independent and the Gluing Theorem is a *columnwise* condition.

<details>
<summary><b>Deriving the exact law</b></summary>

A column with exactly $j$ observed entries occurs with probability $\binom{k}{j}(1-r)^j r^{k-j}$, and its entries all agree with probability $q^{1-j}$ (and with probability $1$ when $j\le1$). Summing over all $2^k$ observation patterns and using the identity
$$\sum_{S\subseteq[k]} a^{|S|}b^{\,k-|S|} = (a+b)^{k}$$
with $a=(1-r)/q$ and $b=r$ evaluates the per-column probability to $q\big(r+\tfrac{1-r}{q}\big)^{k}$ — except that this over-counts the empty pattern, whose true weight is $r^k$ rather than $q\,r^k$. Correcting that single term gives the closed form.

> **Theorem (Exact law).** Write $A = r + \frac{1-r}{q}$ and $\beta = qA^{k}-(q-1)r^{k}$. Then
> $$P(\text{sheaf}) = \beta^{\,n}.$$

The exponent is $n$, the number of *columns*. No binomial coefficient appears anywhere.
</details>

Now drag the missing-rate slider in the panel on the right of the sandbox above, or study panel (c) of the phase diagram below. The probability **increases** with $r$.

Once you see why, it is obvious: a missing cell is not a constraint waiting to be satisfied — it is a constraint that has been *deleted*. **Blanks cannot disagree with each other.** At $r=1$ everything is blank and everything glues; at $r=0$ every cell is present and the probability of universal agreement is $q^{\,n(1-k)}$, exponentially small.

And that gives a one-line impossibility proof: at $r=0$ the true value is $q^{n(1-k)}<1$ while $(1-r)^C=1$ for *every* exponent $C$. A single point kills the entire conjectured family.

{{visualization:0}}

Panel (b) is the punchline of the next section, so let us earn it.

---

## Part 3 · Finding the one number that matters

The exact law tells you *how likely*. It does not immediately tell you *what makes a table hard*. For that you want a single scalar knob — a difficulty parameter.

<details>
<summary><b>Step 1: the failure probability is a weighted binomial tail</b></summary>

Expand the failure probability $1-\beta$ binomially, writing $p=1-r$:

> **Theorem (Weighted tail identity).**
> $$1-\beta(k,q,r) = \sum_{j\ge 2}\binom{k}{j}p^{\,j}r^{\,k-j}\big(1-q^{\,1-j}\big).$$

*Proof.* Expand $\beta = \sum_{j}\binom{k}{j}p^{j}r^{k-j}q^{1-j} - (q-1)r^{k}$ and subtract from $1 = \sum_j \binom{k}{j}p^j r^{k-j}$ termwise. The $j=1$ terms cancel *identically*, because $q\cdot q^{-1}=1$; the $j=0$ term $r^k(1-q)$ is cancelled exactly by the correction $+(q-1)r^k$. Only $j\ge2$ survives. $\blacksquare$

The interpretation is exact and pleasing: **only observation patterns with at least two observed rows can break the sheaf condition**, and such a pattern breaks it with probability precisely $1-q^{1-j}$.
</details>

<details>
<summary><b>Step 2: the weights are trapped, so the tail is the answer</b></summary>

For every $j\ge2$ we have $q^{1-j}=q\cdot q^{-j}\le q\cdot q^{-2}=1/q$, and of course $q^{1-j}\ge0$. So all the weights $1-q^{1-j}$ lie in the interval $[1-\tfrac1q,\,1]$. Strip them out and what remains is a pure binomial tail:
$$\mathrm{tail}(k,r) = \Pr\big[\mathrm{Bin}(k,1-r)\ge 2\big] = 1-r^{k}-k(1-r)r^{\,k-1},$$
the probability that **at least two of the $k$ rows observe a given column**.

> **Theorem (Tail sandwich).** $\big(1-\tfrac1q\big)\mathrm{tail}(k,r) \;\le\; 1-\beta(k,q,r) \;\le\; \mathrm{tail}(k,r).$

The two sides differ only by the factor $1-1/q$, which is at least $1/2$ for $q\ge2$ and tends to $1$ for large alphabets. So the tail determines the failure probability **up to an absolute constant**, and nothing finer than the tail is needed.
</details>

Raising the sandwich to the $n$-th power traps the whole law, and gives a genuine phase transition:

$$P(\text{sheaf}) \le \exp\!\Big(-n\big(1-\tfrac1q\big)\mathrm{tail}(k,r)\Big), \qquad P(\text{sheaf}) \ge 1 - n\cdot\mathrm{tail}(k,r).$$

> **The difficulty parameter of a random database is $\;n\cdot\mathrm{tail}(k,r)$, and the transition happens at $n\cdot\mathrm{tail}(k,r)\asymp 1$.**

Panel (b) of the figure above is the visual proof: curves for wildly different $k$, $n$ and $r$ all **collapse onto a single band** when plotted against $n\cdot\mathrm{tail}$.

<details>
<summary><b>Where the binomial coefficient of the original conjecture actually belongs</b></summary>

It was not spurious — it was *misplaced*. A column fails exactly when some pair of rows is observed with different values, so a union bound over the $\binom{k}{2}$ pairs gives
$$1-\beta \;\le\; \binom{k}{2}\Big(1-\frac1q\Big)(1-r)^{2},$$
and this is an **equality when $k=2$**: for two rows, $P(\text{sheaf}) = \big(1-(1-\tfrac1q)(1-r)^2\big)^n$ exactly. In the other direction, $\mathrm{tail}\ge\binom{k}{2}(1-r)^2 r^{k-2}$.

So the binomial coefficient counts *pairs of rows*, appears as a *linear factor* rather than an exponent, and multiplies $(1-r)^2$ rather than $(1-r)$. Every ingredient of the guess was present; every one was in the wrong slot.

A caution worth internalizing: in the **dense** regime ($k$ large, $r$ fixed in $(0,1)$) the tail saturates near $1$ while $k^2(1-r)^2$ diverges. Any statement of the form "difficulty $\asymp nk^2(1-r)^2$" needs a truncation at $1$ to survive. The honest, uniformly valid statement is the sandwich, in terms of the tail itself.
</details>

The algorithm that turns all of this into numbers:

{{algorithm:1}}

And here is the experimental confirmation, including a Monte-Carlo check against the closed form and an empirical location of the half point:

{{demo:2}}

---

## Part 4 · The disappointment that points the way

We now come to the question that motivated the whole sheaf framing: **is imputation a cohomology problem?**

Cohomology is the machinery that measures failure of local-to-global gluing. Degree zero records the global sections; degree one records the *obstructions* — compatible local families that cannot be glued. If imputation were cohomological, $H^1$ is where the action would be.

It isn't.

<details>
<summary><b>The Acyclicity Theorem: the data sheaf has no obstructions at all</b></summary>

Work over a field, with the linear data sheaf $\mathcal{F}(V)=\{f:\text{columns}\to\Bbbk \mid f \text{ vanishes off } V\}$, and build the Čech complex of an arbitrary finite cover $U_1,\dots,U_k$ of the column set.

> **Theorem.** $H^0$ is the space of complete records, of dimension $n$; and $H^1=0$ for **every** cover.

*Proof of the vanishing.* The data sheaf is *flasque*: sections extend by zero. Concretely, choose for each column $c$ an index $\sigma(c)$ with $c\in U_{\sigma(c)}$. Given a cocycle $(t_{jj'})$, set $s_j(c) = t_{\sigma(c)\,j}(c)$ for $c\in U_j$ and $0$ otherwise. The cocycle relation gives $s_{j'}-s_j = t_{jj'}$ on overlaps, so every cocycle is a coboundary. $\blacksquare$

So "imputation is a sheaf cohomology problem" is true only in degree $0$ — where cohomology is just "the answer" — and in degree $1$, where it would be informative, the group vanishes identically. **No cohomological quantity can measure imputation difficulty for raw records.**
</details>

<details>
<summary><b>And sheaf imputation cannot beat mean imputation, either</b></summary>

> **Theorem.** For a real-valued table that glues, column-mean imputation returns *exactly* the sheaf value.

*Proof.* On gluable data every observed entry of a column equals the same $v$, so their mean is $v$. $\blacksquare$

Not "mean imputation is competitive" — **mean imputation *is* sheaf imputation**. You cannot beat a method you are secretly already using. Any advantage for a sheaf-based method must come from a sheaf with nontrivial restriction maps.

The measurement, in two regimes:

{{demo:1}}
</details>

Two negative results in a row. But look closely at *why* they are negative: both hinge on the coefficients being **raw records**, where a section over an overlap is just the common value. Change what you are gluing, and everything comes alive.

---

## Part 5 · The real theorem: obstruction is a Betti number

In practice, the hard part of merging databases is rarely a blank cell. It is that Source A records temperature in Celsius and Source B in Fahrenheit; that instrument 3 drifted; that the European division uses a different baseline. What you observe on the overlap of two sources is not the data but the **offset** $t_{AB}$ between them.

The question becomes: can these pairwise offsets be explained by per-source recalibrations? Is there an $s_A$ for each source with
$$s_A - s_B = t_{AB} \quad\text{for every recorded overlap?}$$

This is a cohomology problem with teeth. Build a comparison graph in the laboratory below and find out for yourself.

{{interactive_demo:1}}

Start with the **3-cycle preset** and the offsets $(1,0,0)$: a single unit discrepancy between two sources, perfect agreement everywhere else. It is **unfixable**. Every pairwise comparison is individually consistent; no assignment of per-source corrections reconciles them all.

<details>
<summary><b>The Holonomy Criterion</b></summary>

> **Theorem.** For three sources overlapping pairwise (with empty triple overlap), a family of offsets $(t_{01},t_{12},t_{20})$ is realizable by per-source recalibrations if and only if its **holonomy** vanishes:
> $$t_{01}+t_{12}+t_{20}=0.$$

*Proof.* Necessity: the sum $(s_0-s_1)+(s_1-s_2)+(s_2-s_0)$ telescopes to $0$. Sufficiency: set $s_0=0$, $s_1=-t_{01}$, $s_2=-t_{01}-t_{12}$; the remaining equation is exactly the holonomy condition. $\blacksquare$

The obstruction space is one-dimensional: the first cohomology of a circle. You have found the topology hiding in your data pipeline.
</details>

Now try the **star**, the **path**, the **6-cycle**, and the **theta**. Notice the pattern. The general theorem is the payoff of the entire investigation.

> **Nerve Betti Theorem.** Model the integration problem as a finite multigraph — the **nerve** — with a vertex for each source and an edge for each recorded overlap. Then over any field, in any characteristic,
> $$\dim H^{1} + \#\{\text{sources}\} = \#\{\text{overlaps}\} + \#\{\text{connected components}\},$$
> that is, $\dim H^{1} = b_1(\text{nerve}) = |E| - |V| + c$, the first Betti number of the overlap graph.

<details>
<summary><b>Proof, in two steps</b></summary>

*Step 1 (the kernel).* A recalibration $s$ is invisible on all overlaps exactly when it is constant along every overlap, hence constant on every class of the equivalence relation generated by the overlaps. Pulling back along the quotient map is an injective linear map from $\Bbbk^{c}$ onto $\ker d^0$, so $\dim\ker d^0 = c$ and $\operatorname{rank} d^0 = |V|-c$.

*Step 2 (rank–nullity).* $\dim H^1 = \dim C^1 - \operatorname{rank} d^0 - \operatorname{rank} d^1 = |E| - (|V|-c) - 0$. $\blacksquare$

No finiteness or characteristic assumption on the field is used, and multiple overlaps between the same pair are allowed — indeed they *raise* the obstruction dimension.
</details>

**The number of independent unfixable inconsistencies in a multi-source integration problem is a topological invariant of the comparison pattern.** It does not depend on the missing rate. It does not depend on the number of features. It depends only on how many independent cycles your sources form when you draw the graph of which ones you compared.

{{visualization:1}}

The corollaries are practical advice in disguise:

- $H^1=0$ **if and only if the nerve is a forest.** Compare your sources along a spanning tree and calibration is *always* solvable, whatever the offsets turn out to be.
- A **star** — one reference standard, everyone compared only to it — has $b_1=0$ by construction. This is why reference-standard architectures work.
- A **cycle** of any length $m$ has $\dim H^1 = 1$: exactly one holonomy.
- The **theta** graph — two sources compared through three independent overlaps — has $\dim H^1=2$. **Redundant comparisons, not missing data, create obstructions.** Every comparison beyond a spanning tree is a fresh opportunity for irreparable inconsistency.

Here is the algorithm that computes the obstruction and, when it is nonzero, hands you an explicit certificate of which loop is to blame:

{{algorithm:2}}

---

## Part 6 · One final twist: filling the triangle

Suppose some triples of sources genuinely share records — a region where A, B and C all see the same rows. That imposes a new relation: the offset along the diagonal must equal the composite along the two sides,
$$t_{AB} + t_{BC} = t_{AC}.$$

In the laboratory above, load the 3-cycle and press **"fill all triangles"**. The obstruction drops to zero.

<details>
<summary><b>The refined rank formula</b></summary>

Collecting the triple-overlap relations defines a second coboundary $d^1$. Genuine recalibrations satisfy these relations automatically, so $d^1\circ d^0=0$ and we have a complex. Since $\operatorname{rank} d^0 = |V|-c$ is unchanged by the extra layer:

> **Theorem.** $\dim H^{1} + |V| + \operatorname{rank} d^{1} = |E| + c$, and therefore
> $$\dim H^{1} \le b_1(\text{nerve graph}),$$
> with equality exactly when $\operatorname{rank} d^1 = 0$.

**Triple overlaps can only destroy obstructions, never create them.** For the filled triangle, $|E|=|V|=3$, $c=1$ and $\operatorname{rank} d^1=1$, so $\dim H^1 = 3+1-3-1 = 0$: the holonomy obstruction is annihilated.

The relevant cohomology is that of the nerve **complex**, not of its one-dimensional skeleton. Operationally: *one record shared by all three sources is worth more than any amount of pairwise reconciliation.*
</details>

---

## Part 7 · Everything at once

The complete numerical companion — gluing and counting, the exact law against exhaustive enumeration and Monte Carlo, the moments and their two-sided bounds, the weighted tail identity, the threshold, and the nerve computations with holonomy certificates:

{{demo:0}}

And the two remaining algorithms — the linear-time gluability certificate, and the calibration solver:

{{algorithm:0}}

{{algorithm:3}}

---

## What to take away

The sheaf framing of missing data does not deliver a better imputation algorithm for ordinary tables. It delivers something better: a **proof that for ordinary tables there is nothing to deliver**. Gluing is exactly pairwise consistency; the completions are counted by the blank columns; mean imputation already computes the sheaf answer; and the cohomology vanishes identically. Knowing that, you can stop looking.

What the framing *does* deliver is the correct probabilistic law — exponential in the feature count and *increasing* in the missing rate — together with the identification of $n\cdot\Pr[\mathrm{Bin}(k,1-r)\ge2]$ as the one parameter that governs the phase transition.

And it delivers the theorem nobody was looking for: when you integrate data from many sources, **the number of irreconcilable inconsistencies you can suffer is the first Betti number of the graph of your comparisons.** That is not a statistical statement. It is a statement about the shape of your data pipeline — and it says, concretely, that the way to build a pipeline that can always be calibrated is to make its comparison graph a tree, or else to go find the triple overlaps that fill in its cycles.

The blank cell, it turns out, was never the interesting hole.

---

### Going further

- [Sheaf (mathematics)](https://en.wikipedia.org/wiki/Sheaf_(mathematics)) — the general framework of local-to-global data.
- [Čech cohomology](https://en.wikipedia.org/wiki/%C4%8Cech_cohomology) — how the obstruction groups are built from a cover.
- [Nerve of a covering](https://en.wikipedia.org/wiki/Nerve_complex) — the simplicial complex whose Betti numbers appear above.
- [Betti number](https://en.wikipedia.org/wiki/Betti_number) — counting independent cycles.
- [Binomial distribution](https://en.wikipedia.org/wiki/Binomial_distribution) — the tail $\Pr[\mathrm{Bin}(k,p)\ge2]$ that turned out to be the difficulty parameter.
- [Second moment method](https://en.wikipedia.org/wiki/Second_moment_method) — the source of the matching lower bound on the sheaf probability.
- [Imputation (statistics)](https://en.wikipedia.org/wiki/Imputation_(statistics)) — the classical view the sheaf picture is measured against.
