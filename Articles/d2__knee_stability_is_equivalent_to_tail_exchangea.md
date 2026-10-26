# One Histogram Is Enough: Why Knees and Tails Tell the Same Story

*A simple duality between "how big must the threshold be?" and "how many items are above it?" turns an expensive sweep into a single count.*

---

## The question behind the sweep

Imagine you run a service that receives a batch of jobs, and each job has a *demand*: a whole number measuring how much of some resource it needs. It might be tokens in a document, memory for a request, minutes for a repair, or seats for a booking. You must pick a capacity threshold $t$. Any job whose demand is bigger than $t$ overflows: it gets truncated, rejected, or sent somewhere expensive.

You can afford a few overflows, though not many. Call the number of overflows you will tolerate the **gate**, and write it $g$. The natural engineering question is then:

> *What is the smallest threshold that lets through all but at most $g$ jobs?*

That smallest threshold is what we call the **knee** at gate $g$. Plot the knee against the gate and you get a falling staircase. With no tolerance ($g = 0$) the knee is the largest demand. With more tolerance, the knee drops step by step until, once the gate is as large as the whole batch, it reaches zero.

Practitioners often want to compare two collections of demands, say two corpora, two months of traffic, or two languages, by asking whether they have the same knees. The obvious way to answer is a **sweep**: pick several gates, compute the knee of each collection at each gate, and compare. When every cell in a grid of experiments needs its own sweep, the cost adds up quickly.

The results described here show that the sweep is unnecessary. Everything the knees can tell you is already in one object you can compute in a single pass: the **tail histogram**.

---

## Two ways of looking at the same pile

Write the collection of demands as $D$. Repeats are allowed, so $D$ is a *multiset*. There are two natural functions to attach to it.

**The tail.** For a threshold $t$, let
$$\mathrm{tail}_D(t) = \#\{\, d \in D : d > t \,\}$$
be the number of demands that are *strictly larger* than $t$, counted with multiplicity. This is the upper-tail counting function. Statisticians would recognise it as an unnormalised survival function. It can only go down as $t$ grows, and it reaches zero once $t$ is at least the largest demand.

**The knee.** For a gate $g$, let
$$\mathrm{knee}_D(g) = \min\{\, t \ge 0 : \mathrm{tail}_D(t) \le g \,\}$$
be the least threshold that at most $g$ demands exceed. Such a threshold always exists, because the largest demand is one.

Take a concrete batch,
$$D = \{7, 5, 5, 3, 1, 0\}.$$
Its tail at thresholds $t = 0, 1, 2, \dots, 7$ is
$$5,\ 4,\ 4,\ 3,\ 3,\ 1,\ 1,\ 0,$$
and its knee at gates $g = 0, 1, 2, \dots, 7$ is
$$7,\ 5,\ 5,\ 3,\ 1,\ 0,\ 0,\ 0.$$

The second list is just the batch sorted from largest to smallest, padded with zeros. That is the first key fact.

---

## The knee is an order statistic

> **Theorem (order statistic).** The knee at gate $g$ is the $g$-th entry, counting from $0$, of the demands listed in decreasing order. When $g$ is at least the number of demands, the knee is $0$.

The reason is simple. Suppose the largest few demands are $7, 5, 5$. A threshold of $5$ is exceeded only by the $7$, so it works at gate $1$. A threshold of $4$ is exceeded by $7, 5, 5$, which is too many. So the knee at gate $1$ is the second-largest demand.

So the "knee" is not a mysterious feature of a curve. It is the demand that sits at rank $g$ from the top. A comparison of knees across several gates is a comparison of order statistics across a range of ranks.

---

## A perfect two-way switch

The deeper structural fact is a two-way switch between the two functions. For every gate $g$ and every threshold $t$:

$$\boxed{\ \mathrm{knee}_D(g) \le t \iff \mathrm{tail}_D(t) \le g\ }$$

In words: *the threshold $t$ is at least the knee at gate $g$ exactly when at most $g$ demands exceed $t$.* Mathematicians call this kind of relationship a **Galois connection**. The same pattern links a cumulative distribution function to its quantile function, and the floor function to the inclusion of the integers in the reals.

The switch has a strong consequence. Each function can be recovered from the other. If you know every tail value, you can work out every knee: the knee at $g$ is the first $t$ where the tail falls to $g$ or below. If you know every knee, you know every tail: the tail at $t$ is the number of gates whose knee is still above $t$. Neither function contains any information the other lacks.

---

## The main theorem: knees agree exactly when tails agree

This brings us to the main question. Suppose two collections $D$ and $D'$ have *the same knee at every gate*. What does that say about them?

> **Theorem (knee stability equals tail exchangeability).** For two finite multisets of non-negative integers $D$ and $D'$, the following are equivalent:
>
> 1. $\mathrm{knee}_D(g) = \mathrm{knee}_{D'}(g)$ for every gate $g$;
> 2. $\mathrm{tail}_D(t) = \mathrm{tail}_{D'}(t)$ for every threshold $t$;
> 3. $D$ and $D'$ contain exactly the same **positive** demands, with the same multiplicities.

Statements 1 and 2 are equivalent by the two-way switch. To get from 2 to 3, notice that the tail drops by exactly the number of demands equal to $k+1$ as $t$ moves from $k$ to $k+1$:
$$\mathrm{tail}_D(k) = \mathrm{tail}_D(k+1) + \#\{d \in D : d = k+1\}.$$
So the histogram is the *discrete derivative* of the tail. Equal tails give equal histograms at every positive value.

There is one subtlety, and it shows why care pays off. A demand of $0$ never exceeds any threshold $t \ge 0$, so it is invisible to every tail and every knee. The collections $\{4, 2, 2\}$ and $\{0, 2, 4, 0, 2\}$ have identical knees at every gate even though they are different multisets. The tempting slogan "equal knees if and only if equal data" is therefore **false** as stated. The correct version says *equal positive data*. When every demand is positive, which is the usual situation, it really does reduce to plain equality of the multisets.

### You don't even need all the gates

A knee at a gate that is at least as large as the whole collection is automatically $0$. So a finite check is enough:

> **Theorem (finite sweep).** $D$ and $D'$ have equal knees at every gate as soon as they have equal knees at the gates $g = 0, 1, \dots, \max(|D|, |D'|) - 1$.

---

## Windows of gates and bands of counts

In practice nobody cares about every gate. You might care about gates $10$ through $19$, the regime where "a handful of overflows is fine". Can the histogram still decide the question when you only want the knees to agree on a **window** of gates?

The answer is yes, and the formula is a pleasant surprise. Define the clamp of a count $x$ to the band $[a, a+w]$:
$$\mathrm{clamp}_{[a,a+w]}(x) = \min\big(\max(x, a),\ a+w\big).$$
Values below $a$ are pushed up to $a$, values above $a+w$ are pushed down to $a+w$, and values inside the band are left alone.

> **Theorem (window).** Two collections have equal knees at every gate $g$ with $a \le g < a + w$ if and only if, at every threshold $t$,
> $$\mathrm{clamp}_{[a,a+w]}\big(\mathrm{tail}_D(t)\big) = \mathrm{clamp}_{[a,a+w]}\big(\mathrm{tail}_{D'}(t)\big).$$

Equivalently, when the window is non-empty, at each threshold the two tails must:

* agree on whether they are **at or below** $a$,
* agree on whether they are **at or above** $a + w$, and
* be exactly **equal** whenever they lie strictly between $a$ and $a + w$.

So a window of $w$ gates corresponds to a band of counts one unit wider, $[a, a+w]$. Inside the band the tails must match exactly. Outside it, only the side matters.

For example, take $D = \{9, 6, 4, 2\}$ and $D' = \{8, 6, 4, 1, 1\}$. Their knee profiles are $9, 6, 4, 2, 0$ and $8, 6, 4, 1, 1$. They disagree at gates $0$, $3$ and $4$ but agree on the window of gates $1$ and $2$. Clamping both tails to the band $[1, 3]$ gives the same sequence $3, 3, 3, 3, 2, 2, 1, 1, 1, 1$ for both collections, as the theorem predicts.

### Beware the obvious guess

The "obvious" version of the window statement is wrong. It says that the knees agree on gates $a$ through $b$ exactly when the tails agree whenever the count lies in $[a, b]$. Take $D = \{3\}$, $D' = \{2\}$, and the single gate $1$. Both knees are $0$, because one overflow is allowed and there is only one demand. Yet at threshold $t = 2$ the tail of $D$ is $1$, which lies in $[1,1]$, while the tail of $D'$ is $0$. The naive band condition fails even though the knees agree.

The fix is the clamp. Counts at the *edge* of the band only need to land on the same side, not to be equal. This is the kind of off-by-one trap that is easy to miss in an informal argument and that a careful statement rules out.

---

## Stability: what happens when data is noisy?

Real collections are never exactly equal, so the most useful results are quantitative. The same two-way switch gives a precise, loss-free conversion between "tails are close" and "knees are close".

> **Theorem (gate shift).** For any shift $k \ge 0$, the following are equivalent:
>
> * for every gate $g$, $\ \mathrm{knee}_{D'}(g + k) \le \mathrm{knee}_D(g)$;
> * for every threshold $t$, $\ \mathrm{tail}_{D'}(t) \le \mathrm{tail}_D(t) + k$.

So if the two tails never differ by more than $k$ in either direction, each knee profile is sandwiched by the other, shifted by $k$ gates:
$$\mathrm{knee}_{D}(g + k) \le \mathrm{knee}_{D'}(g) \quad\text{and}\quad \mathrm{knee}_{D'}(g + k) \le \mathrm{knee}_{D}(g).$$

Two practical corollaries follow.

* **Contamination.** If you add a collection $E$ of extra demands, knees can only go up, and by no more than $|E|$ gates:
  $$\mathrm{knee}_D(g) \le \mathrm{knee}_{D+E}(g), \qquad \mathrm{knee}_{D+E}(g + |E|) \le \mathrm{knee}_D(g).$$
* **Pooling.** When two collections are merged, tails simply add: $\mathrm{tail}_{D+E} = \mathrm{tail}_D + \mathrm{tail}_E$. On the knee side this gives
  $$\max\big(\mathrm{knee}_D(g), \mathrm{knee}_E(g)\big) \le \mathrm{knee}_{D+E}(g), \qquad \mathrm{knee}_{D+E}(g+h) \le \max\big(\mathrm{knee}_D(g), \mathrm{knee}_E(h)\big).$$

---

## A picture from the 19th century

All of this has a classical picture behind it. Draw the demands as rows of boxes, longest row first. This is the **Ferrers diagram** familiar from the theory of integer partitions. For $D = \{5, 3, 3, 1\}$:

```
#####     knee at gate 0 = 5
###       knee at gate 1 = 3
###       knee at gate 2 = 3
#         knee at gate 3 = 1
```

The **rows** have lengths equal to the knees. The **columns** have heights $4, 3, 3, 1, 1$, and these are exactly the tail values at $t = 0, 1, 2, 3, 4$. Knees and tails are *conjugate partitions*: the same diagram read across or down. Two identities follow at once:
$$\mathrm{tail}_D(t) = \#\{\, g < |D| : \mathrm{knee}_D(g) > t \,\}, \qquad \mathrm{knee}_D(g) = \#\{\, t < \max D : \mathrm{tail}_D(t) > g \,\}.$$
Counting the boxes both ways gives the **area identity**:
$$\sum_{g=0}^{|D|-1} \mathrm{knee}_D(g) = \sum_{d \in D} d.$$
The knees always add up to the total demand.

---

## Why this matters

The practical message is that **a single tail histogram per collection is a sufficient statistic for every knee question**:

* Do two collections have identical knees? Compare their positive histograms.
* Do they agree on a window of gates? Clamp their tails to the matching band and compare.
* How far apart can their knees be? Take the largest gap between their tails. That gap bounds the gate shift, with no loss.

A histogram costs one pass over the data. It can be built in pieces and added up, since tails of pooled collections simply add. It can be stored compactly and reused for any gate window chosen later. Work that used to need a full sweep of knee computations for every cell of an experimental grid now needs one count per collection. This makes larger collections, and collections with fewer documents, affordable to analyse.

The idea underneath is old and simple. A threshold and a count of exceedances are two sides of one Galois connection, and an order statistic is the inverse of a counting function. Seeing the knee this way turns a property that seemed to need many measurements into one that a single count already settles.

---

## Where next?

Several natural extensions remain open:

* **A metric.** The gate-shift theorem already implies that the smallest gate shift making each knee profile dominate the other equals the largest gap between the tails. Developing this number into a full Kolmogorov-type distance between collections, with its triangle inequality and normalised versions, would give one figure per pair of collections that bounds every knee discrepancy.
* **Weights.** When demands carry real-valued weights, the same switch should hold for weighted tails, which matters when items count by size rather than by number.
* **Sampling.** If a subsample's tail is uniformly close to the scaled population tail, the gate-shift theorem converts that into a knee guarantee with no extra loss.
* **Pooling.** Since tails add under merging, knee profiles of a large collection could be assembled from histograms of its shards.

Each of these follows the pattern of this article. Translate the question about knees into a question about tails, answer it there where the arithmetic is easy, and translate back.
