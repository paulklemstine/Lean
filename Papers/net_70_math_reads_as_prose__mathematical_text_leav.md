# The Knee That Refused to Move

### A guided tour of budget–quality curves, order statistics, and the deployment table they generate

---

## 0. The question, in one paragraph

A sequential predictor reading text keeps a memory of everything it has already seen.
That memory is the dominant cost of running it, so in practice we throw most of it
away and keep only the $k$ most useful entries. Sweep $k$, record how often the
truncated predictor still reproduces the untruncated one, and you get a curve that
climbs and then flattens. The elbow — the **knee** $k^{*}$ — is the smallest budget
that still clears a quality bar $g$. It is the number that goes into the
configuration file.

This page is about a single measurement and the theorem hiding behind it. Classical
mathematical text is *twelve percentage points harder to predict* than English prose.
Its knee is **exactly the same number**.

---

## 1. Meet the objects

Three definitions carry the whole story. Read them once; the widget below will make
them concrete.

> **Workload.** A finite family of $n$ prediction positions. Position $i$ carries a
> **demand** $r_i$ — the smallest budget at which the truncated predictor still
> reproduces the full predictor's output there — and a **correctness bit** $c_i$,
> recording whether the full predictor was right.
>
> **Agreement curve.** $A(k) = \#\{i : r_i \le k\}\,/\,n$, the fraction of positions
> already served by budget $k$.
>
> **Knee and accuracy.** $k^{*}(g) = \min\{k : A(k) \ge g\}$ and
> $\mathrm{acc} = \#\{i : c_i\}/n$.

Notice what just happened. The knee reads the $r_i$ column. The accuracy reads the
$c_i$ column. They are computed from the same table and share not one input.

<details>
<summary><b>Why the knee is well behaved: a Galois adjunction</b></summary>

For a monotone curve $A$ whose gate is reachable,
$$k^{*}(A,g) \le k \quad\Longleftrightarrow\quad g \le A(k).$$
The forward direction is attainment plus monotonicity ($g \le A(k^{*}) \le A(k)$); the
backward direction is minimality of the infimum. The knee is therefore the *left
adjoint* of the curve, and every monotonicity fact you might want — the knee grows
with the gate, shrinks when the curve improves — is an instance of this one statement.
It is also exactly the predicate monotonicity that makes binary search over a sweep
correct. See [Galois connection](https://en.wikipedia.org/wiki/Galois_connection) for
the general notion.
</details>

---

## 2. The measurement

{{visualization:0}}

The left panel is the sweep. Mathematics fails at $4$, $8$ and $12$ keys ($0.907$,
$0.959$, $0.979$) and passes at $16$ with $0.987$. Prose's knee, measured earlier
under an identical harness, is also $16$. Double the context to $1024$ and both move
to $20$ — a rigid $+4$.

The right panel is the difficulty. $0.4460$ for prose against $0.3262$ for
mathematics: a gap of $0.1198$, and not one extra key.

<details>
<summary><b>Why the knee is stated on an interval of gates, not at one gate</b></summary>

A knee reported at a single hand-picked gate is unfalsifiable — you cannot tell
whether the gate was chosen to produce the number. The honest object is the whole
interval on which the answer is constant: here $(0.979, 0.987]$ at context $512$ and
$(0.978, 0.983]$ at context $1024$. These **overlap** in $(0.979, 0.983]$, so one
single gate certifies both cells and the reported $+4$ increment is not an artefact of
using different gates at different context lengths.
</details>

---

## 3. Play with it

Now make the claim yours. Drag the gate and watch the knee walk across the sweep. Then
drag the *accuracy* slider — which rewrites the correctness bits — and watch nothing
else move at all. Panel two shows why; panel three shows what it buys you.

{{interactive_demo:0}}

Three things to try:

1. **Set the gate anywhere in $(0.979, 0.983]$** and switch between prose and
   mathematics. The knee is $16$ both times, whatever the accuracy slider says.
2. **In panel two, push the perturbation slider.** You are sending the demands of the
   hardest positions to infinity — simulating a domain full of long-range references.
   The rank marker holds still until the perturbed count crosses the slack
   $(1-g)n$, and only then does the knee jump.
3. **In panel three, slide the tolerance $\delta$ from 0 upward.** Find the exact
   value at which the three domains stop needing two cache sizes.

---

## 4. Why it cannot move: the knee is an order statistic

Here is the theorem the widget is illustrating.

> **Quantile identity.** On $n$ positions at gate $g$, the knee is the
> $\lceil g n \rceil$-th smallest demand.

An **order statistic** — not an average. Accuracy, by contrast, is a mean of a
different variable entirely. Order statistics are famously indifferent to what happens
away from the relevant rank, and that indifference is the whole verdict.

> **Exact gate criterion.** A budget $k$ clears the gate $g$ if and only if the number
> of positions still unserved at $k$ is at most $(1-g)n$.

> **Perturbation robustness.** If at budget $k$ the unserved positions of one workload
> number at most $(1-g)n$, then any workload whose unserved set at $k$ is contained in
> the first's also has knee at most $k$ — however catastrophically its accuracy fell.

So: mathematical text may well contain more long-range references than prose. What the
data say is that the *count* of positions depending on them stayed under the slack. At
$g \approx 0.98$ that slack is about $2\%$ of positions, which is exactly the regime
those references live in.

<details>
<summary><b>Proof sketch of the quantile identity</b></summary>

Write $N(k) = \#\{i : r_i \le k\}$, so $A(k) = N(k)/n$. Then
$$g \le \frac{N(k)}{n} \iff g n \le N(k) \iff \lceil g n \rceil \le N(k),$$
the last equivalence because $N(k)$ is an integer. The set of budgets clearing the gate
is therefore literally the same set as the set of budgets serving at least
$\lceil gn\rceil$ positions, and the two infima coincide. The exact gate criterion
follows by substituting $N(k) = n - T(k)$ where $T(k)$ is the unserved tail, and
clearing denominators.
</details>

<details>
<summary><b>A cruder but useful corollary: a Markov bound</b></summary>

Each unserved position at budget $k$ contributes at least $k+1$ to the total demand.
Hence if $\sum_i r_i \le (1-g)\,n\,(k+1)$ then the tail is at most $(1-g)n$ and the
knee is at most $k$: informally $k^{*} \lesssim \bar r/(1-g)$ where $\bar r$ is the
*mean* demand. This is loose — it uses only one moment — but it needs nothing but the
average, and it makes the message concrete: a thin demand tail is *sufficient* for a
small budget, no matter how hard the text is to predict. See
[Markov's inequality](https://en.wikipedia.org/wiki/Markov%27s_inequality).
</details>

---

## 5. The strongest form: difficulty and budget are free coordinates

One might still object that although the two columns are formally independent, real
text could weld them together. It cannot, and here is why.

> **Decoupling theorem.** For every position count $n > 0$, every budget $k$, and
> every achievable accuracy $j/n$, there is a workload whose knee equals $k$ at *every*
> gate $g \in (0,1]$ and whose accuracy is exactly $j/n$.

The construction is a single line: make every position demand exactly $k$, and mark
exactly $j$ of them correct. The map from workloads to (knee curve, accuracy) is
**surjective**. Therefore no inequality of the form "harder text needs more keys" can
be a theorem — every combination is realised.

Two further invariances finish the job. Distorting the quality axis by *any* strictly
increasing function (the abstract form of "this domain is uniformly harder"), with the
gate transported along, leaves the knee fixed: the knee reads only the *order* of the
curve, never its values. And mixing two corpora in any proportion traps the mixture's
knee between the constituents' — so when prose and mathematics both sit at $16$, every
blend sits at $16$ too, and the mixing ratio drops out of the argument.

---

## 6. Extracting the knee from real, noisy data

Measured sweeps are not perfectly monotone. The context-$512$ sweep records $0.989$ at
budget $20$ and $0.988$ at budget $24$ — a dip well inside one standard error. The
principled repair is the running maximum, and after it the adjunction of §1 licenses a
binary search.

{{algorithm:0}}

And here is the discipline that makes a knee claim falsifiable: report the whole
interval of gates on which the answer is constant, and check that the intervals at two
context lengths overlap before you claim an increment.

{{algorithm:1}}

---

## 7. From a theorem to a deployment table

A fleet does not tune a cache size per domain; it picks a handful of standard sizes.
Formalise that and something pretty happens.

> An entry $b$ **serves** a domain of knee $k$ at waste tolerance $\delta$ when
> $k \le b \le k+\delta$: big enough to clear the gate, not wasteful by more than
> $\delta$ keys.

So an entry is a *point*, a domain is the *interval* $[k, k+\delta]$, and the number of
standard sizes you need is the minimum number of points meeting a family of
equal-length integer intervals — a classical
[hitting set](https://en.wikipedia.org/wiki/Set_cover_problem) question, in the one
regime where it is exactly solvable.

{{visualization:1}}

Four facts pin it down.

- **One entry suffices** exactly when $\max K \le \min K + \delta$; the witness is
  $b = \max K$.
- **Separated knees force distinct entries**: if knees are pairwise more than $\delta$
  apart, no entry serves two of them, so every entry set is at least that large.
- **Greedy covers cheaply**: knees inside $[a,b]$ are served by the progression
  $b,\, b-(\delta+1),\, b-2(\delta+1), \dots$, of size
  $\lfloor (b-a)/(\delta+1)\rfloor + 1$.
- **The bounds meet**: for $m$ knees spaced exactly $\delta+1$ apart, the minimum is
  *exactly* $m$. Packing equals covering; neither bound can be improved.

<details>
<summary><b>Why the greedy progression is anchored at the top</b></summary>

An entry must never fall *below* the knee it serves — a cache too small fails the
quality gate outright, which is a correctness failure, not a waste failure. The
tolerance is one-sided, so the progression must be counted downward from the largest
knee, not upward from the smallest. Given $k \in [a,b]$, write $b - k = q(\delta+1)+s$
with $0 \le s < \delta+1$; the entry $b - (\delta+1)q = k+s$ then satisfies
$k \le k+s \le k+\delta$ exactly.
</details>

{{algorithm:2}}

Apply it to the measured table — $\text{prose} \mapsto 16$, $\text{code} \mapsto 12$,
$\text{mathematics} \mapsto 16$, so the knee set is $\{12,16\}$ with spread $4$:

- $\delta \le 3$: **two** entries are provably necessary and $\{12,16\}$ suffices.
  Prose and mathematics share one; only code shifts.
- $\delta \ge 4$: the whole fleet runs from the **single** entry $16$.

And $4$ is not an arbitrary threshold — it is exactly one scale increment, the same
$+4$ by which every knee moves when the context doubles.

---

## 8. Check everything yourself

Every number on this page is recomputed from scratch below, in exact rational
arithmetic: the knees and their gate windows, the multiset invariance, the
surjectivity construction, the quantile identity, the tail criterion, the
perturbation experiment, the mixture stability, and the entry covers — including a
randomised check that greedy covering and packing agree on two hundred random knee
sets.

{{demo:0}}

---

## 9. What to take away

Two summary statistics of the same dataset can look like they must be linked — both
plainly measure "how hard is this?" — and be linked by nothing at all, because one is
a **mean of one variable** and the other a **quantile of another**. The only thing
coupling them is that they were computed over the same rows, and that coupling carries
no information.

The limits are worth stating as plainly as the result. The corpus here is classical
mathematical *prose*, not modern notation-dense typeset mathematics; it is one blend
(though the mixing theorem shows the blend does not matter), one model scale, two
context lengths. Whether the $+4$ increment survives to context $4096$, whether dense
notation behaves differently, and whether non-English domains follow the same shape are
measurements still to be made — not corollaries.

But the shape of the answer is already clear. Hand a machine the hardest prose humans
write, watch its accuracy fall twelve points, and the budget line in your configuration
file does not change by a single key. The knee was never looking at difficulty.
