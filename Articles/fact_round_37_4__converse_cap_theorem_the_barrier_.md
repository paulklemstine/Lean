# The Dial That Promised Too Much

## How a single quadratic curve caps what congruence hints can ever buy a search

There is a very old idea in the folklore of factoring, and it goes something like this. You are hunting for a divisor of a big number $N$. You have no clever algebra, only patience: you will walk through candidate divisors one after another until one of them works. That is the brute-force scan, the humblest algorithm there is.

Now someone hands you a *hint*. Not a factor — nothing so generous — but a congruence condition. "Whatever the factor is," they tell you, "its remainder modulo $M$ lies in this set $K$." Perhaps $K$ is the quadratic residues, perhaps the cubic ones, perhaps a set carved out by some exotic character sum. Half the candidates fall away. Surely — surely — you now go twice as fast?

The answer, it turns out, is no. And not "no, only about $1.9\times$ in practice". The answer is that under the honest accounting of a single-pass scan, such a hint can never buy you more than a factor of

$$\frac{4}{3} = 1.3333\ldots$$

no matter what $M$ is, no matter how the set $K$ is built, no matter how many independent hints you stack on top of each other, and no matter how much *information* the hints technically contain. The bound is exact, it is attained, and it is blind to essentially everything one would hope to exploit.

This article is about that constant, why it is $4/3$ and not $2$, and what the difference between those two numbers actually means.

---

## The one-line model

Strip the situation down. There are $n$ admissible residue classes to search — if the hint lives modulo $M$, then $n = \varphi(M)$, the number of classes coprime to $M$. The class of the sought factor is some $t$, and we assume it is uniformly distributed among the $n$ possibilities: we have no prior reason to prefer one class over another.

A **residue dial** is a subset $K$ of those classes together with a reading: it tells you whether $t \in K$ or not. Its **density** is
$$\theta = \frac{|K|}{n},$$
the fraction of the search space it keeps.

Here is the crucial modelling decision, and everything hinges on it. A scan is a *single pass* through the candidate classes. The dial is allowed to *reorder* them — that is exactly what makes it useful, you put the kept classes first — but a class that has been scheduled is a class you pay for. You cannot un-schedule work. So the dial-aware algorithm does this:

1. Read the dial.
2. Scan the $k = |K|$ kept classes.
3. If the target was not among them, you are back where you started, and you scan the whole space.

The cost, measured in classes examined, is $k$ when $t \in K$, and $n$ when $t \notin K$. Average over the uniform target:

$$\mathbb{E}[\text{cost}] \;=\; \frac{k \cdot k + (n-k)\cdot n}{n} \;=\; n\bigl(1 - \theta + \theta^{2}\bigr).$$

That is the whole derivation. Divide by the unfiltered baseline $n$ and you get the **exact single-pass law**:

$$\boxed{\ \mathrm{Speedup}(\theta) \;=\; \frac{1}{1 - \theta + \theta^{2}}.\ }$$

No approximation, no asymptotics, no hidden constant. It holds for *any* subset of *any* finite class space.

---

## Why $4/3$, and why exactly there

Complete the square:
$$1 - \theta + \theta^{2} \;=\; \Bigl(\theta - \tfrac12\Bigr)^{2} + \tfrac34.$$

The cost can never fall below $3/4$ of the baseline, and it hits $3/4$ at precisely one point, $\theta = 1/2$. Inverting:

> **Universal Cap Theorem.** For every density $\theta$, $\mathrm{Speedup}(\theta) \le 4/3$, with equality if and only if $\theta = 1/2$.

The curve is a genuine hill. It rises strictly on $[0, \tfrac12]$, falls strictly on $[\tfrac12, 1]$, and equals exactly $1$ at both ends — a filter that keeps nothing and a filter that keeps everything are both worthless, which is reassuring, and a filter that keeps a hundredth of the space is *also* nearly worthless, which is not what most people guess.

That last point deserves emphasis, because it is counterintuitive. A very aggressive filter, $\theta = 0.01$, discards $99\%$ of the search space. It looks like a triumph. But in a single-pass scan it buys you
$$\frac{1}{1 - 0.01 + 0.0001} = 1.0102\ldots,$$
a one-percent improvement. The reason is brutal and simple: with probability $0.99$ the target is *not* in your tiny set, you have wasted the pass, and you pay the full price anyway. Aggressive filters are almost always wrong, and being wrong is expensive. Lazy filters are almost always right, but being right about nothing saves nothing. The optimum sits exactly at the balance point, and the balance point is worth $4/3$.

---

## The structure does not matter. At all.

Here is where the result becomes genuinely surprising, and where it stops being a cute exercise.

The law $1/(1-\theta+\theta^2)$ depends on the set $K$ through *one number only*: its cardinality. Two dials of the same size buy exactly the same speedup. This is a triviality once stated, and a bombshell once you consider what it rules out.

> **Structure Blindness.** If $|K| = |L|$, then the two dials have identical speedup — whatever their internal structure. A subgroup, a coset, a union of character fibres, a set produced by a deep reciprocity law, and a set produced by flipping coins all perform identically.

So consider the family of hints one would actually reach for. Fix any *reading* $f$ that assigns to each residue class a symbol — the Legendre symbol, the cubic residue character with its three values, the quintic character with its five, or a tuple of several such readings at once — and keep the classes whose symbol lies in a chosen set $T$. Call this a **symbol dial**. Then:

> **No character content helps.** Every symbol dial obeys the same cap $4/3$, and a symbol dial that keeps exactly half the classes attains it exactly, for *any* reading $f$ and *any* symbol subset $T$.

The cubic case ($3$ symbols) and the quintic case ($5$ symbols) were the ones people hoped would break the pattern: surely mixing character fibres in a clever, unbalanced way beats a plain half-density set? It does not. The mixing is invisible. The law cannot see it. All the arithmetic depth of higher power-residue symbols is compressed, by the scan model, into a single integer — how many classes survive — and then into $4/3$.

---

## Which factor? It doesn't matter — and that's an identity

There is a related folk observation about semiprimes. Suppose $N = pq$ and $N \equiv c \pmod M$. You want to filter on the residue class of a factor. But *which* factor? You do not know which of $p, q$ you will encounter first; you might worry that filtering "for $p$" and filtering "for $q$" are different games with different payoffs.

They are not, and the reason is a one-line symmetry. If $u$ is the class of $p$ and $v$ the class of $q$, then $uv = c$, so
$$v = c \cdot u^{-1}.$$
The map $\sigma_c(u) = c u^{-1}$ is an involution of the group of units modulo $M$ — apply it twice and you are back where you started. It is in particular a bijection, so it preserves cardinalities, so it preserves densities, so it preserves speedups.

> **Which-Factor Blindness.** For any dial $K$ and any semiprime residue $c$, the dial $K$ and its relabelling $\sigma_c(K)$ have exactly the same speedup.

Note the word *exactly*. Empirically this had been observed as an approximate coincidence, a near-symmetry in simulation data. It is not approximate. It is an identity, and it holds for every $M$, every $c$, and every $K$, because it is nothing more than the statement that a bijection does not change how many elements a set has.

---

## Batteries: composing hints is free, and free means worthless

If one dial is capped, stack many. Take dials on pairwise coprime moduli $m_1, m_2, \ldots$ and read them all. The Chinese Remainder Theorem says the composite is precisely the logical AND of the pieces, on the product modulus, and — the key computation —

> **Densities multiply.** The density of a composed battery is the product of the densities of its dials.

And now the trap springs shut. The law depends only on the composite density $\theta = \prod_i \theta_i$, and the cap $4/3$ holds for *every* value of $\theta$. So:

> **Battery Cap.** However many dials a battery contains, on however many moduli, of whatever densities, its speedup is at most $4/3$, and in particular strictly below $2$.

Composition is *free* in the double-edged sense: it costs nothing structurally, and it buys nothing beyond what a single well-chosen dial already buys. In fact it typically buys *less*: each additional dial pushes $\theta$ down toward $0$, i.e. down the far side of the hill toward speedup $1$. A battery of twenty independent half-density dials has composite density $2^{-20}$ and buys a speedup of $1.000001$.

### Two currencies

This is the sharpest way to say what is going on. A dial of density $\theta$ reveals
$$\text{capacity} \;=\; \log_2 \frac{1}{\theta} \ \text{ bits}$$
of information about the target's class. A battery of $n$ half-density dials advertises exactly $n$ bits. That number is unbounded — you can build a battery with a thousand bits of capacity. Measurements on real batteries have reported figures like $12.72$ bits.

The *work* a dial buys, in the same units, is
$$\text{work} \;=\; \log_2 \mathrm{Speedup}(\theta) \ \text{ bits},$$
and the cap says
$$\text{work} \;\le\; \log_2 \tfrac43 \;=\; 0.41504\ldots \ \text{ bits}.$$

So $12.72$ measured capacity bits purchase at most $0.415$ work bits. Worse: as the battery grows, the composite density tends to $0$, the speedup tends back to $1$, and the work bought tends to **zero**. The exchange rate does not merely stall — it collapses. Capacity bits and work bits are different currencies, and there is no bank that will convert one into the other at par.

---

## So where does the number $2$ come from?

Everyone who has met this circle of ideas remembers a barrier of $2$, not $4/3$. That memory is not wrong; it belongs to a *different accounting*, and the honest thing to do is to say exactly which.

**Accounting one — worst-case in phase.** A pass that scans $m$ classes is charged $m$. This is what we did above. Cap: $4/3$, attained at $\theta = 1/2$.

**Accounting two — expected position.** Charge the algorithm the *position* at which it happens to find the target, and let it order the classes freely inside each branch of the dial reading. A blind scan of $n$ classes then costs $(n+1)/2$ on average. A dial-aware scan splits the space into a kept block of size $k$ and a rejected block of size $j$, and, whatever orders it chooses, the total over all targets is at least the two triangular numbers
$$\frac{k(k+1)}{2} + \frac{j(j+1)}{2}.$$
This lower bound — that any injective assignment of distinct positions $1, 2, 3, \ldots$ to $m$ items costs at least $m(m+1)/2$ in total — is what makes the resulting formula a bound over *all* strategies rather than the value of one particular strategy. It gives

$$\mathrm{AvgSpeedup}(k,j) \;=\; \frac{(k+j)(k+j+1)}{k(k+1) + j(j+1)}.$$

And here the barrier is genuinely $2$:

> **Expected-Position Barrier.** For all block sizes, $\mathrm{AvgSpeedup}(k,j) < 2$, strictly. At balanced blocks $k = j = m$ the value is exactly $(2m+1)/(m+1)$, which increases to $2$ but never reaches it.

Two accountings, two constants: $4/3 < 2$. The gap is real and quantifiable — for every $\varepsilon > 0$ some balanced dial beats $2 - \varepsilon$ in the second accounting, while *no* dial ever beats $4/3$ in the first.

There was a temptation, in this work, to report the weaker and more familiar bound "$\le 2$" in the first framing, because that is the number the literature asks about. It would have been true but strictly weaker; asserting equality with $2$ there would have been false. The provable constant in the worst-case-in-phase framing is $4/3$, and the discipline of saying so is the whole point.

---

## More symbols, and the edge of the theorem

What if the dial does not answer yes/no but names one of $r$ blocks, and the algorithm scans blocks in some order until it succeeds? Write $\theta_1, \ldots, \theta_r$ for the block densities, summing to $1$. A target in block $i$ costs $\theta_1 + \cdots + \theta_i$, so the normalised expected cost is
$$C(\theta) = \sum_i \theta_i (\theta_1 + \cdots + \theta_i).$$

A short symmetrisation gives an identity that is worth pausing on:
$$2\,C(\theta) \;=\; \Bigl(\sum_i \theta_i\Bigr)^{2} + \sum_i \theta_i^{2}.$$

The right side is symmetric in the blocks. **The scan order is irrelevant.** Every rearrangement heuristic one might propose — biggest block first, smallest block first, some greedy interleaving — produces exactly the same expected cost. There is no ordering to optimise.

With $\sum \theta_i = 1$, Cauchy–Schwarz gives $\sum \theta_i^2 \ge 1/r$, hence $C \ge (r+1)/(2r)$, hence:

> **The Cap Hierarchy.** An $r$-symbol single-pass dial buys at most $\dfrac{2r}{r+1}$, attained exactly at uniform blocks.

At $r = 2$ this is $4/3$, recovering the binary case. The hierarchy runs $4/3,\ 3/2,\ 8/5,\ 5/3, \ldots$, stays strictly below $2$, and converges to $2$. So $2$ is the limit of these caps and the value of none of them — the second place, after the accounting analysis, where the folklore's favourite number shows up as a supremum rather than a maximum.

Finally, the honest boundary. Everything above assumes the algorithm must *pay* for classes it schedules. Suppose instead the dial's answer lets it **skip** the rejected blocks outright — a full reveal. Then the cost is
$$\sum_i \theta_i^{2},$$
and a balanced $r$-symbol reveal buys exactly $r$. There is no universal cap at all. In the binary case a full reveal buys exactly $2$ — which is, at last, the true source of the folklore's barrier. The $4/3$ is not a theorem about congruence information in the abstract. It is a theorem about *scan-order algorithms*, and the difference between $4/3$ and $r$ is exactly the difference between reordering work and skipping it.

---

## What it all means

Real sieving lives between the two extremes. You can often skip a candidate, but only after paying something to recognise that you may. So the practical constant should be a function of the *skip budget*, interpolating $4/3$ at one end and $r$ at the other — and now that both endpoints sit inside a single framework, that interpolation is a well-posed question rather than a slogan.

There is also a clean profitability corollary hiding in the algebra. The absolute saving of a density-$\theta$ dial is $n(\theta - \theta^2) \le n/4$. So a filter whose reading costs more than a quarter of a full scan can *never* pay for itself, whatever its density and however deep its arithmetic. That is a hard budget line for anyone designing congruence-based pre-filters, and it comes for free from the same completed square.

The larger lesson is about the seduction of information. It is easy to count the bits a filter reveals, watch that number climb as you compose more filters, and conclude that something is being accomplished. The bits are real. The information is genuinely there. But information is not work, and in a single-pass scan the conversion rate between them is bounded by a number smaller than one half of a bit — and it decays to nothing precisely as the information grows.

Four-thirds. Attained at half density, blind to structure, immune to composition, and strictly, permanently, below two.
