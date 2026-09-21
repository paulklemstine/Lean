# The Curve That Stops at the Ceiling

## How six dials learned almost everything there was to know — and why they could never learn more

Imagine you are handed a very large box of numbered tickets. Each ticket carries a hidden
label — think of it as the ticket's secret identity — and you are not allowed to look at the
label. What you *are* allowed to do is attach measuring instruments to the box. Each
instrument is a **dial**: you feed it a ticket, and it reports a single residue, a number
between $0$ and $m-1$ for some fixed modulus $m$. One dial might report the ticket's value
modulo $31$, another modulo $23$, another modulo $9$.

A single dial is a coarse instrument. It sorts the tickets into $31$ heaps and tells you
nothing about which ticket inside a heap you are holding. But dials can be ganged together
into a **battery**. Read six dials at once and you get a six-tuple of residues — and by the
Chinese Remainder Theorem, if the six moduli are pairwise coprime, that six-tuple is a residue
modulo their product. Six coarse instruments have silently become one very fine instrument.

The question this article is about is deceptively simple:

> As you add dials one at a time, how fast does the battery learn about the hidden label,
> and where does the learning stop?

The answer has three parts, and all three are theorems. The curve **rises**. It rises
**faster than the sum of its parts**, but only under a precise hypothesis that can fail. And
it **stops at a ceiling** — a ceiling that is not a fudge factor or a fitted constant but a
quantity intrinsic to the labels themselves, reached exactly when the battery can tell every
two differently-labelled tickets apart, and not one instant before.

---

## Measuring information by counting

Everything here happens on a **finite population**: a finite set $\Omega$ of individuals —
tickets, integers, pairs of primes, whatever the experiment is made of — with $N = |\Omega|$
members. A **statistic** is any function $f$ from $\Omega$ to some set of readings. A dial is
a statistic whose readings are residues; a label is a statistic whose readings are labels.

The information content of a statistic is measured by *counting*. If $f$ takes the value $a$
on exactly $n_a$ individuals, then the fraction of the population in cell $a$ is $n_a/N$, and
the **entropy** of $f$ is

$$H(f) \;=\; -\sum_{a} \frac{n_a}{N}\,\log\frac{n_a}{N},$$

the sum running over the values $f$ actually takes. There is no probability model here and no
randomness: $H(f)$ is a combinatorial quantity attached to a partition of a finite set. It is
zero when $f$ is constant, and it is at its largest — $\log N$ — when $f$ separates every
individual from every other. Divide by $\log 2$ and you are counting bits instead of nats.

Two statistics read together form a third, the **joint** statistic $x \mapsto (f(x), g(x))$,
and the **mutual information**

$$I(f;g) \;=\; H(f) + H(g) - H(f,g)$$

measures how much the two readings overlap. It is never negative — that is exactly the
statement that $H(f,g) \le H(f) + H(g)$, i.e. that reading two things together is never more
informative than reading them separately and adding — and it is zero precisely when the two
partitions of the population are, cell by cell, in perfect proportion.

The **capacity curve** of a growing battery is now easy to say. Fix a nested chain of
sub-batteries $S_1 \subseteq S_2 \subseteq \cdots \subseteq S_6$ of dials, and fix a label $L$.
Let $K_k$ be the joint reading of the dials in $S_k$ — the tuple of their residues. The curve
is

$$I(k) \;=\; I(K_k \,;\, L),$$

the information the first $k$ dials carry about the label. Against it we set the naive
bookkeeping a laboratory notebook would use: the **sum of the marginals**,
$\sum_{i \in S_k} I(\text{dial } i\,;\,L)$, which is what you would report if you analysed each
dial in isolation and added up the answers. The difference

$$D(k) \;=\; I(k) \;-\; \sum_{i \in S_k} I(\text{dial } i \,;\, L)$$

is the **deficit** — the amount of information that exists only in the combination, and that
single-dial analysis simply cannot see.

---

## What the six-dial experiment saw

Here is the measured curve for a six-dial battery whose conductors are pairwise coprime, with
combined modulus $31 \cdot 23 \cdot 9 \cdot 8 \cdot 5 \cdot 11$, read against a label attached
to a population of pairs. All numbers are in bits.

| dials $k$ | $I(k)$ | $\sum$ marginals | deficit $D(k)$ | ceiling | % of ceiling |
|---|---|---|---|---|---|
| 1 | 1.0011 | 1.0011 | $+0.000$ | — | — |
| 2 | 2.1334 | 2.0020 | $+0.132$ | 4.6063 | 46% |
| 3 | 4.0242 | 2.4777 | $+1.547$ | 6.4947 | 62% |
| 4 | 8.2412 | 3.9120 | $+4.329$ | 9.5434 | 86% |
| 5 | 11.5307 | 5.1591 | $+6.372$ | 11.9557 | 96% |
| **6** | **12.7235** | 5.3650 | $+7.359$ | **12.7726** | **99.6%** |

Three things leap out. The curve climbs steeply and then flattens against the last column.
The additive bookkeeping falls hopelessly behind: at six dials it reports $5.365$ bits where
the battery actually delivers $12.72$, an understatement by a factor of $3.7$. And the deficit
— the size of that understatement — grows at every single step.

The purpose of this article is to explain why each of these is forced, and to be equally
precise about the one place where the pattern is *not* a law.

---

## The ceiling

Start with the flattening, because it is the cleanest.

> **The Ceiling Theorem.** For any statistic $f$ and any label $L$ on a finite population,
> $$I(f;L) \;\le\; H(L).$$

No battery, however many dials you bolt onto it, can read more about the labels than the
labels contain. The proof is one line once you know that a pair is at least as informative as
either of its coordinates: since $f$ is recovered from $(f, L)$ by forgetting the second
coordinate, and coarsening never increases entropy, $H(f) \le H(f, L)$, and substituting into
$I(f;L) = H(f) + H(L) - H(f,L)$ gives the bound.

The same one line tells you exactly what the slack is:

$$H(L) - I(f;L) \;=\; H(f,L) - H(f),$$

which is the **conditional entropy of the label given the reading** — the residual uncertainty
about a ticket's label once you have seen what all your dials say. The ceiling gap is not an
abstract inefficiency. It is ignorance, measured in bits, and it lives inside the cells of the
reading: two tickets with the same six residues but different labels are precisely the
ignorance you have left.

That observation is the content of the next theorem, which is what the phrase *saturates at
the ceiling* actually means.

> **The Saturation Theorem.** $I(f;L) = H(L)$ **if and only if** $f$ determines $L$: whenever
> two individuals give the same reading, they carry the same label. If even one pair of
> individuals with different labels is confused by the battery, then $I(f;L) < H(L)$ strictly.

So the ceiling is not approached asymptotically in some limiting sense — it is a hard
boundary, hit exactly at the moment the battery becomes a perfect classifier and never before.
A measured $99.6\%$ is therefore not "essentially saturated": it is a quantitative statement
that some ambiguity is still there, and the missing $0.049$ bits are the exact average size of
the surviving confusion.

There is even a clean way to bound how much ambiguity that is. Suppose there is some auxiliary
measurement $g$, taking at most $m$ different values, such that the reading together with $g$
pins the label down completely. Then

$$H(L) - I(f;L) \;\le\; \log m.$$

One extra bit of disambiguation means you were at most one bit below the ceiling. With $m=1$
— no extra measurement needed — the bound collapses to exact saturation, recovering the
previous theorem as a special case. This converts a percentage into a statement about
structure: *how ambiguous is the battery, really?*

---

## The curve never goes down

That the curve rises looks obvious — surely more dials cannot mean less information? — and it
is in fact true, but it is *not* obvious, and this is where the mathematics gets interesting.

> **Monotonicity of the Capacity Curve.** If $S \subseteq T$, then
> $I(K_S ; L) \le I(K_T ; L)$: enlarging the battery never decreases the information it
> carries about the label.

For raw entropy this would be trivial: the finer reading has more cells and $H$ is monotone
under refinement. But mutual information is a *difference* of entropies, and differences of
monotone quantities are not monotone. The statement that saves it is a genuinely deeper
inequality:

> **Strong Subadditivity of the Counting Entropy.** For any three statistics $u, v, w$ on a
> finite population,
> $$H(u,v,w) + H(u) \;\le\; H(u,v) + H(u,w).$$

Equivalently — rearranged as $H(w \mid u,v) \le H(w \mid u)$ — knowing more never makes you
more uncertain. This is the analytic engine underneath every monotonicity statement about
growing batteries, and it has a beautiful one-shot proof. Write $n(\cdot)$ for cell counts,
$N$ for the population size, and consider the **conditional product reference**

$$q(a,b,c) \;=\; \frac{n(a,b)\, n(a,c)}{n(a)\, N}.$$

A short computation with marginals shows that the $q(a,b,c)$ sum to exactly $1$ over all
triples: it is a legitimate weight on the cells of the triple reading, the one that pretends
$v$ and $w$ are conditionally independent given $u$. Gibbs' inequality — in the elementary
form $p\log(1/p) \le p\log(1/q) + (q-p)$, which is just $\log t \le t-1$ in disguise — applied
cell by cell and summed, gives strong subadditivity immediately: the log terms reassemble into
$H(u,v) + H(u,w) - H(u)$, and the correction terms $(q - p)$ sum to $1 - 1 = 0$.

From strong subadditivity, monotonicity of the curve follows in three lines. And it is worth
pausing to notice the shape of the conclusion, which is the classical **data processing
principle** in combinatorial dress: if one reading is a function of another — as the joint
reading of a sub-battery is a function of the joint reading of the whole battery, simply by
discarding coordinates — then the coarser reading cannot know more about the label than the
finer one.

---

## Synergy — and its limits

Now the most striking column of the table: the deficit, which grows without ever turning back.
Why should the whole be so much more than the sum of its parts?

> **The Synergy Law.** If two readings $k_1, k_2$ are statistically independent in the
> population — meaning $H(k_1, k_2) = H(k_1) + H(k_2)$, the joint reading being exactly as
> rich as the two separate ones — then
> $$I(k_1 ; L) + I(k_2 ; L) \;\le\; I\big((k_1,k_2) ; L\big).$$

Independent dials never cancel; they can only conspire. And independence is exactly what the
experiment's design buys: with pairwise coprime conductors, the Chinese Remainder Theorem
makes the residues of a uniformly distributed population statistically independent, each dial
carving up the population in a way that is uncorrelated with all the others. The synergy law
turns that arithmetic design decision into an information-theoretic guarantee.

Iterating along the nested chain gives the compounding the table displays:

> **Monotone Deficit (guarded form).** If each newly added dial is statistically independent
> of the joint reading of the dials already present, then
> $D(k) \le D(k+1)$: the deficit never shrinks. Marginal bookkeeping understates a battery
> progressively.

And the last step of the experiment — the jump from $86\%$ to $96\%$ to $99.6\%$ — has its own
sharpened statement: if the new dial carries *no* label information on its own, the old
battery still confuses two differently-labelled individuals, and the enlarged battery
determines the label completely, then the deficit grows **strictly**. Every bit the last dial
contributes is pure synergy — the dial is worthless alone and decisive in company.

Here is the part that deserves the most emphasis, because it is the place where a plausible
empirical pattern turns out not to be a law.

> **The deficit is not always positive, and not always increasing.** Take a population of two
> individuals, a label that distinguishes them, and a battery of *two identical one-bit dials*.
> The joint reading of the two dials is just the one-bit reading, so $I(\text{joint};L) = 1$
> bit, while the additive bookkeeping cheerfully reports $1 + 1 = 2$ bits. The deficit is
> $-1$ bit: strictly negative.

Duplicated instruments make the naive sum *over*-report, not under-report. So the compounding
deficit seen in the six-dial table is not a universal truth about batteries — it is a
consequence of the coprimality of the conductors. Strip out the independence and the
phenomenon reverses sign. That is a good example of why it pays to pin an empirical pattern to
a hypothesis: the theorem tells you precisely which experiments will reproduce the effect and
which will not.

One small but reassuring statement completes the picture: the one-dial sub-battery carries
exactly the information of that dial, no more and no less. The additive column really is what
it claims to be — the sum of the individual experiments, each reproducing its source.

---

## The wall that is exactly zero

The six-dial battery was also asked a different question, and here the answer was a flat,
resounding nothing.

The population in the underlying experiment consists of *pairs* — think of a semiprime $N = pq$
and its two factors. One natural label to try to read is the **which-factor bit**: is the
first factor the smaller of the two? The measurement reported $0.3594$ bits against a
permutation null of $0.3591$, a $z$-score of $+0.11$: no signal whatsoever, the tiny positive
number being nothing but the sparse-table bias that finite samples always produce.

The theorem explains why no amount of extra dials will ever help.

> **The Which-Factor Wall.** Suppose there is an involution $\sigma$ of the population
> ($\sigma(\sigma(x)) = x$) that preserves every dial reading, $k_i(\sigma x) = k_i(x)$ for all
> $i$, but flips the binary label, $W(\sigma x) = \lnot W(x)$. Then **every** sub-battery, of
> **every** size, carries **exactly zero** information about $W$.

The mechanism is transparent once stated. The involution acts inside each cell of the joint
reading — it never moves a ticket to a different cell — and inside each cell it exchanges the
$W = \text{true}$ half with the $W = \text{false}$ half. So every cell is split perfectly
down the middle, and a perfectly balanced split is the definition of carrying no information.
Arithmetically, the cell-splitting identity

$$2\,\varphi(N, m) \;=\; \varphi(N, 2m) + \frac{2m}{N}\log 2, \qquad
\varphi(N,n) = -\frac{n}{N}\log\frac{n}{N},$$

says that halving every cell costs exactly one bit — which is precisely the one bit that $W$
itself carries, so the mutual information $H(K) + H(W) - H(K,W)$ vanishes identically.

This is not a vacuous statement about degenerate configurations. Take the population of
ordered pairs of *distinct* residues modulo $5$, a dial reading the residue of their **sum**,
and the which-factor bit "is the first coordinate the smaller one?". Swapping the coordinates
is an involution; the sum is symmetric, so the dial is untouched; the comparison bit flips.
The dial has strictly positive entropy, the bit carries a full bit of entropy — and the
capacity is exactly $0$.

The moral is worth stating plainly: *symmetric instruments cannot break symmetry*. Any reading
that depends only on symmetric functions of a pair — the sum, the product, the residue of the
product modulo anything — is structurally blind to which factor is which, no matter how many
such readings you take, and no matter how sharply they saturate against every other label.
The measured $0.3594$ was never a faint signal to be amplified by more data. It was noise
around a structural zero.

---

## Why any of this matters

Strip away the arithmetic and what remains is a general lesson about *ensembles of weak
measurements*, which is a situation that occurs everywhere: sensor arrays, genetic markers,
feature sets in machine learning, diagnostic panels in medicine, side-channel traces in
cryptography.

**First**, the ceiling is real and it is computable. There is no point chasing more sensors
once your ensemble is near $H(L)$; what is left is not signal but the entropy of the labels
themselves, and the saturation theorem tells you the only way to close the last gap is to
resolve actual confusions — specific pairs of items your instruments cannot distinguish.

**Second**, evaluating features one at a time can be catastrophically misleading. The
six-dial table understates the battery by a factor of $3.7$, and the understatement grows with
every feature added. A feature-selection procedure that ranks dials by their individual
information would have discarded most of this battery, including — in the sharp version of the
law — a final dial with literally zero information of its own that nevertheless completes the
classifier.

**Third**, the reverse failure is just as real. Correlated or duplicated features make the
same additive bookkeeping *over*-report, and the deficit flips sign. Whether your ensemble
exhibits compounding synergy or double-counting is decided by a single, checkable hypothesis:
independence of each new instrument from everything already measured. Coprime conductors are
one way to guarantee it; in an applied setting you must earn it.

**Fourth**, and perhaps most useful in practice: some questions are *structurally* out of
reach, and no amount of scaling changes that. If your measurements are invariant under a
symmetry that the label is not invariant under, your capacity for that label is exactly zero —
not small, not hard to detect, not a matter of sample size. Recognizing such a symmetry saves
an unbounded amount of wasted computation. Scaling laws have ceilings, and some of those
ceilings are at zero.

The six-dial battery climbed to $99.6\%$ of everything there was to know. It got there by
synergy, which compounding coprimality guaranteed. And there was one question it could not
answer at all, which no seventh dial of the same kind would ever have fixed. All three facts
are theorems — and together they say something quietly satisfying about the limits of
measurement: you can find out how much there is to know, you can find out how fast you are
getting there, and you can find out, before you start, what you will never learn.
