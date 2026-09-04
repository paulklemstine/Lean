# Rankings Have a Shape

### A guided tour of the permutohedron, and of what it forbids

---

Suppose you want to know whether two ways of ordering the same $n$ things agree. You could
compare them item by item, or pair by pair, or by how far each item has to move. Statisticians
settled long ago on a particular recipe — Spearman's rank correlation

$$\rho = 1 - \frac{6\sum_i d_i^2}{n^3-n},$$

where $d_i$ is the difference between the two ranks given to item $i$. It returns $1$ for perfect
agreement, $-1$ for perfect reversal, $0$ for no relationship.

That formula looks arbitrary. The $6$, the $n^3-n$ — where do they come from? By the end of this
page you will see that **nothing in it is arbitrary**, that it is forced by the geometry of a
polytope, and that the same geometry hands you a hard, computable limit on what any thresholded
measurement can ever achieve.

---

## 1. One idea: a ranking is a point

Here is the whole trick.

A tie-free ranking of $n$ items assigns each item a distinct number from $0$ to $n-1$. But a list
of $n$ numbers is a point in $n$-dimensional space. So each of the $n!$ possible rankings is a
single point, and their convex hull is a classical object: the **permutohedron** $\Pi_{n-1}$.

For $n=3$ it is a regular hexagon with six corners. For $n=4$, a truncated octahedron with
twenty-four. Neighbouring corners differ by swapping two adjacent ranks; opposite corners are
exact reverses of one another.

Two facts about these corners do all the work, and both are one-liners.

**They all lie on the same hyperplane**, because permuting a list does not change its sum:
$$\sum_i \sigma(i) = 0+1+\cdots+(n-1) = \frac{n(n-1)}{2}.$$

**They all lie on the same sphere**, because permuting does not change the sum of squares either:
$$\sum_i \sigma(i)^2 = \frac{n(n-1)(2n-1)}{6}.$$

The corners are *cospherical*. And for cospherical points, squared distance and inner product are
the same information:
$$\sum_i d_i^2 = 2\Bigl(R - \langle\sigma,\tau\rangle\Bigr),\qquad R = \sum_i \sigma(i)^2.$$

That single identity is the reason a "rank correlation" deserves the name.

<details>
<summary><strong>Click to reveal: why $\rho$ is <em>exactly</em> Pearson's coefficient</strong></summary>

Pearson's correlation of two vectors is their covariance divided by the product of their standard
deviations. Every rank vector has the same mean $\frac{n-1}{2}$ and the same variance
$\frac{n^2-1}{12}$ — again by cosphericity. So the Pearson coefficient of two rank vectors is

$$r = \frac{\frac{1}{n}\langle\sigma,\tau\rangle - \left(\frac{n-1}{2}\right)^2}{\frac{n^2-1}{12}},$$

and substituting $\langle\sigma,\tau\rangle = R - \frac{1}{2}\sum d_i^2$ and simplifying gives
precisely

$$12\Bigl(n\langle\sigma,\tau\rangle - \Bigl(\tfrac{n(n-1)}{2}\Bigr)^2\Bigr) = n^2(n^2-1)\,\rho .$$

So the constant $n^3-n$ is just $12n$ times the variance of a ranking. The recipe is not a
convention; it is the only affine rescaling that makes the statistic a correlation.

If you would like more background, the [permutohedron](https://en.wikipedia.org/wiki/Permutohedron)
and [Spearman's rank correlation coefficient](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient)
are both well documented.

</details>

---

## 2. Play with it: the Ranking Laboratory

Now that rankings are points, let us move around on the polytope and watch the numbers respond.

Rearrange the ranking below by clicking two cells. Three different rulers are tracked
simultaneously — squared travel $\sum d^2$, total travel $F = \sum|d_i|$, and pairwise disorder
(the inversion count) — together with the inequalities that bind them. Try the *reverse* button to
jump to the antipode; try *random adjacent swap* to take one step along an edge.

Two things to look for.

1. **$\sum d^2$ is always even.** Never $1$, never $3$. Try to break it; you cannot.
2. **The dial has a hole.** On the number line at the bottom, the grey ticks are the *only*
   readings that exist. Notice the red band pressed against $\rho = 1$: nothing can land there.

{{interactive_demo:0}}

---

## 3. Why the dial has teeth

The parity you just observed is the key structural fact, and its proof is three lines.

The displacement vector $d = \sigma - \tau$ sums to zero, because both rankings have the same
coordinate sum. And for any integer, $x^2$ and $x$ have the same parity. So

$$\sum_i d_i^2 = \sum_i (d_i^2 - d_i) = \sum_i d_i(d_i - 1),$$

a sum of products of consecutive integers — every term even.

Two distinct rankings therefore satisfy $\sum d^2 \ge 2$, which immediately gives the

> **Rigidity Gap Theorem.** If two rankings differ at all, then
> $$\rho \le 1 - \frac{12}{n^3-n}.$$
> Equivalently, the open interval $\bigl(1 - \frac{12}{n^3-n},\ 1\bigr)$ contains no attainable
> value. A reading in that window certifies that the two rankings are *identical*.

At the other extreme, the reversal is the antipode, and the exact diameter is
$\max \sum d^2 = n(n^2-1)/3$ — so $\rho = -1$ occurs precisely at the diameter of the polytope.

The figure below shows the hexagon $\Pi_2$ alongside the attainable grids for $n = 3$ through $7$,
with the forbidden window shaded.

{{visualization:0}}

<details>
<summary><strong>Click to reveal: the exact diameter, in four lines</strong></summary>

Let $\mathrm{rev}(i) = n-1-i$. For any $\mu$, the identity $\mathrm{rk}(\mathrm{rev}\cdot\mu)(i) = (n-1) - \mathrm{rk}\,\mu(i)$
gives
$$\langle \mathrm{rev}\cdot\mu,\ \mathrm{id}\rangle = (n-1)L - \langle\mu,\mathrm{id}\rangle,\qquad L = \tfrac{n(n-1)}{2}.$$
Since $\langle\cdot,\cdot\rangle \le R$ always (that is just $\sum d^2 \ge 0$), we get
$\langle\mu,\mathrm{id}\rangle \ge (n-1)L - R$, with equality at $\mu = \mathrm{rev}$. Converting back to a
distance, $\sum d^2 = 2(R - \langle\cdot,\cdot\rangle) \le 4R - 2(n-1)L$, and substituting the closed
forms for $L$ and $R$ gives $n(n^2-1)/3$. Right-invariance ($\sum d^2$ depends only on
$\sigma\tau^{-1}$) makes the reduction to the identity harmless.

</details>

---

## 4. Is the dial honest?

Before you read an in-band value as *evidence*, you should know the instrument has no thumb on the
scale. Does a rank correlation against an unrelated ranking average to zero?

Exactly, yes — and the proof is symmetry, not calculation. Fix a position $i$ and add up
$\sigma(i)$ over all $n!$ rankings. Multiplying every ranking on the right by the transposition
$(i\,j)$ permutes the whole group onto itself and turns that total into the total at position $j$.
So the totals are equal: the ensemble is *position-blind*, i.e. the centroid of the permutohedron
is the barycentre. Summing over positions pins the value, and out drops

$$\mathbb{E}\Bigl[\sum_i d_i^2\Bigr] = \frac{n^3-n}{6}, \qquad \sum_{\sigma} \rho(\sigma,\mathrm{id}) = 0.$$

Not asymptotically. Identically, at every finite $n$.

That exactness has a payoff. Because the readings live on a finite grid *and* the null moments are
known exactly, one can build the entire null distribution and read off **exact** critical values —
no normal approximation, no conservatism you cannot quantify. The demonstration below does this by
enumeration and prints the full null distribution.

{{demo:1}}

---

## 5. Three rulers, one verdict

A sceptic could object that squaring the displacements was a choice. Why not measure total travel,
$F = \sum_i |\sigma(i)-\tau(i)|$ — Spearman's **footrule**? Or count *inversions*, the pairs the
two rankings order oppositely?

These are genuinely different measurements, and each has its own personality. The footrule is a
right-invariant metric on the group of rankings and, better, a **length function**: it is
subadditive, $F(\sigma\tau) \le F(\sigma)+F(\tau)$, and a transposition of positions $a$ and $b$
costs exactly $2|a-b|$ — each of the two items travels the same distance in opposite directions.

But they never disagree about a verdict, because they are equivalent up to explicit factors:

$$F \ \le\ \sum d^2 \ \le\ (n-1)F, \qquad F^2 \ \le\ n\sum d^2, \qquad F \ \le\ 2\,\mathrm{inv}.$$

The last of these is the **Diaconis–Graham upper bound**, and it is the one with a genuinely
beautiful proof.

<details>
<summary><strong>Click to reveal: the double-counting proof of $F \le 2\,\mathrm{inv}$</strong></summary>

Fix an item $i$ and let $S = \{j : \sigma(j) < \sigma(i)\}$. Since $\sigma$ is a bijection onto
$\{0,\dots,n-1\}$, exactly $\sigma(i)$ items have a smaller rank, so $|S| = \sigma(i)$. Split $S$
by position: the part sitting to the *right* of $i$ is precisely the set of inversions with $i$ as
left endpoint, and the part to the left has at most $i$ elements. Hence

$$\sigma(i) \le i + \#\{\text{inversions with } i \text{ on the left}\}.$$

Dually, looking at $T = \{j : \sigma(j) > \sigma(i)\}$ with $|T| = n-1-\sigma(i)$,

$$i \le \sigma(i) + \#\{\text{inversions with } i \text{ on the right}\}.$$

Together these sandwich $|\sigma(i)-i|$ below the sum of the two inversion counts at $i$. Sum over
$i$. Grouping the inverted pairs by left endpoint gives $\mathrm{inv}(\sigma)$; grouping by right
endpoint gives $\mathrm{inv}(\sigma)$ again. Total: $F(\sigma) \le 2\,\mathrm{inv}(\sigma)$. $\blacksquare$

The factor $2$ is sharp: an adjacent swap has $F = 2$ and one inversion. It is not always tight:
swapping the ends of a three-element ranking gives $F = 4 < 6 = 2\,\mathrm{inv}$.

</details>

The algorithm below computes all three rulers at once and reports the full certificate. Inversions
are counted in $O(n\log n)$ by merge sort rather than the naive $\Theta(n^2)$.

{{algorithm:1}}

<details>
<summary><strong>Click to reveal: an open problem hiding in plain sight</strong></summary>

There is a companion *lower* bound, also due to Diaconis and Graham:

$$\mathrm{inv}(\sigma) + T(\sigma) \ \le\ F(\sigma),$$

where $T(\sigma)$ is the minimum number of transpositions needed to build $\sigma$. Together with
the upper bound it sandwiches the three most-used ranking metrics within constant factors — a
genuinely useful fact.

It resists the two obvious proofs, and it is instructive *why*. Bubble-sort induction fails
because an adjacent transposition can leave $F$ unchanged while dropping $\mathrm{inv}$ by one, so the
induction has no slack. Per-position charging fails because the number of inversions with $i$ on
the left is *not* bounded by the rightward displacement of $i$: the ranking $[2,3,1,0]$ at $i = 2$
is a witness, with one right-inversion but a *leftward* displacement of $-1$.

A genuinely global argument is needed. The promising reading is structural: $F$, $\mathrm{inv}$ and
$T$ are all length functions on the symmetric group — respectively a metric length, the
[Coxeter length](https://en.wikipedia.org/wiki/Coxeter_group), and the Cayley length — and the
claim is that $F$ dominates the sum of the other two. That smells like a facet inequality of the
permutohedron seen through the Cayley graph. It has been checked exhaustively for every ranking of
up to six items.

</details>

---

## 6. The part with teeth: what a threshold destroys

Here is where the geometry stops being pretty and starts being useful.

In practice a score is not used continuously. A threshold $u$ turns it into a flag: above the cut
you act, below you do not. And that operation does not *perturb* a ranking — it **destroys** one.
Whatever richness the score had, downstream there is only a two-block indicator: $1$ on a flagged
set of size $m$, $0$ elsewhere.

Now ask: how well can a two-block indicator possibly correlate with a full ranking?

The answer needs one observation. A block of $m$ items receives $m$ *distinct* ranks, so its total
rank is at most $(n-1)+(n-2)+\cdots+(n-m)$ and at least $0+1+\cdots+(m-1)$. That is a hard, sharp
bound on the covariance, and dividing by the two standard deviations gives the

> **Block Ceiling Theorem.** If a fraction $p = m/n$ of items is flagged, then for *every*
> statistic and *every* ranking,
> $$r^2 \ \le\ \frac{3m(n-m)}{n^2-1} \ \approx\ 3p(1-p).$$

Nothing about noise. Nothing about sample size. Nothing about the score. A cap.

Drag the threshold in the widget below and watch the ceiling collapse as the flagged fraction
shrinks. Set your own acceptance floor and see exactly which operating points become impossible.

{{interactive_demo:1}}

The next figure makes the sharpness concrete: on the left, the ceiling curve with an acceptance
band drawn on it; on the right, an exhaustive search over every block and every ranking of six
items, showing that the closed-form ceiling is *attained*, not merely an estimate.

{{visualization:1}}

<details>
<summary><strong>Click to reveal: the derivation in full</strong></summary>

Write $L = \frac{n(n-1)}{2}$ for the total rank, and for a block $B$ of size $m$ set
$C_B = n\sum_{i\in B}\sigma(i) - m L$, so that $C_B/n^2$ is the covariance of $\mathbf 1_B$ with the
rank vector.

From the extremal block sums,
$$2C_B \le n\,m(2n-m-1) - m\,n(n-1) = n\,m(n-m),$$
and symmetrically $2C_B \ge -n\,m(n-m)$.

The indicator has variance $m(n-m)/n^2$ and the rank vector has variance $(n^2-1)/12$, so

$$r^2 = \frac{(C_B/n^2)^2}{\frac{m(n-m)}{n^2}\cdot\frac{n^2-1}{12}}
     = \frac{12\,C_B^2}{n^2 m(n-m)(n^2-1)}
     \le \frac{3m(n-m)}{n^2-1}. \qquad\blacksquare$$

Both extremal sums are achieved — put the block on the top or bottom ranks — so the ceiling cannot
be improved.

</details>

---

## 7. Auditing a real operating point

The theorem converts directly into a pre-flight check. Before you tighten a threshold, compute
$\sqrt{3p(1-p)}$ for the resulting flag rate. If it is below your acceptance floor, you already
know the answer, and the experiment is uninformative.

{{algorithm:2}}

Concretely, at a $10\%$ flag rate on a population of $100$ strata the ceiling is exactly

$$r^2 \le \frac{3\cdot 10\cdot 90}{100^2-1} = \frac{2700}{9999} \approx 0.270, \qquad |r| \le 0.520,$$

whereas an acceptance floor of $0.71$ demands $r^2 \ge 0.504$. The band is unreachable. Not
unlikely — unreachable.

| flagged fraction $p$ | ceiling on $\lvert r\rvert$ | verdict against a $0.71$ floor |
|---|---|---|
| $0.50$ | $0.866$ | reachable |
| $0.30$ | $0.794$ | reachable |
| $0.25$ | $0.750$ | reachable |
| $0.21$ | $0.706$ | **impossible** |
| $0.10$ | $0.520$ | **impossible** |
| $0.05$ | $0.377$ | **impossible** |

The crossover is at $p \approx 0.21$: below roughly a one-fifth flag rate, a $0.71$ floor cannot be
met by any method whatsoever.

---

## 8. The story this explains

A calibration study of exactly this kind of dial found a puzzling asymmetry. Varying the population
size over eleven binary orders of magnitude — from about $10^8$ items to $2.7\times 10^{11}$ —
changed nothing: five out of five populations read in band, mean $0.713$ against an anchor of
$0.717$. But tightening the operating threshold degraded *every single* population, systematically,
with the worst reading collapsing to $0.487$.

The geometry says both halves at once.

**Scale does not move the corners of the permutohedron.** The correlation normalises by $n$; the
polytope looks the same at every size. So a scale-only change should be — and was — inert.

**Coarsening collapses them.** Raising the threshold shrinks $p$, which lowers the ceiling, which
at some point passes below the acceptance floor. A worst reading of $0.487$ sitting just under the
$p\approx0.1$ ceiling of $0.520$ is not a sampling fluctuation. It is a measurement pressed against
a wall.

---

## 9. Everything at once

The complete numerical companion below verifies every claim on this page: cosphericity, the chordal
identity, right-invariance, the Pearson identity, parity, the rigidity gap, the exact diameter,
exact unbiasedness, all three metric comparisons, the Diaconis–Graham bound and its sharpness, the
still-open lower bound (checked to $n=7$), and the block ceiling with its exhaustive sharpness
check. Every assertion is exact rational arithmetic.

{{demo:0}}

And for the single most-used computation — an exact reading with a built-in sanity audit:

{{algorithm:0}}

---

## Take-away

A rank correlation on finite data is not a number that arrives from the world. It is a chordal
distance between two corners of a polytope. That polytope quantises the readings, forbids a window
just below $1$, fixes an exact diameter, centres the statistic exactly at zero, makes three
different metrics interchangeable — and, when you coarsen your data with a threshold, hands you a
ceiling you cannot climb over.

Before the next experiment, compute $\sqrt{3p(1-p)}$. The geometry may already have answered.
