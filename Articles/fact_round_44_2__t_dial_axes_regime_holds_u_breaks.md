# The Hexagon That Knows Your Threshold

## How the geometry of a many-sided polytope explains why a monitoring dial holds in one direction and shatters in another

---

### A dial, two knobs, and a puzzle

Imagine you run a large system — a search engine, a fraud filter, a diagnostic pipeline — and you have a score $T$ that is supposed to predict something you care about: a failure rate, a click rate, a disease. You cannot check every case, so you do what statisticians have done for a century: you rank everything by $T$, rank everything by the outcome, and ask how well the two orderings agree. The classical answer is **Spearman's rank correlation**,

$$\rho = 1 - \frac{6\sum_i d_i^2}{n^3-n},$$

where $d_i$ is the difference between the two ranks assigned to item $i$, and $n$ is the number of items. A value of $\rho$ near $1$ means the orderings agree; $0$ means no relationship; $-1$ means one is exactly the reverse of the other.

Suppose you have decided, in advance, that the system is healthy when $\rho$ falls in the band $[0.71,\ 0.76]$. Now you have two knobs. The first is **scale**: how big is the population you measure on? The second is **threshold**: your score is continuous, but downstream you act on it only by flagging cases above some cut $u$.

Here is what a careful calibration study found. Turning the first knob does nothing bad. Across five independent populations whose sizes span more than eleven binary orders of magnitude — from about $10^8$ items to about $2.7\times 10^{11}$ — the dial stayed in band every single time, with an average reading of $0.713$, statistically indistinguishable from the $0.717$ anchor value. The regime holds.

Turning the second knob is a catastrophe. Raising the cut from $u=2.5$ to $u=3.5$ degraded the reading on *every* population tested — five out of five, with one collapsing to $0.487$, and the average falling clean through the floor of the band.

The obvious reading is "tighter thresholds are noisier". That reading is wrong, and the reason it is wrong is **geometry**.

---

### Rankings are the corners of a polytope

Here is the change of viewpoint that makes everything else fall into place.

A ranking of $n$ items is just a permutation: a list of the numbers $0, 1, 2, \dots, n-1$ in some order. But a list of $n$ numbers is also a *point in $n$-dimensional space*. So each of the $n!$ possible rankings is a single point, and the convex hull of all of them is a beautiful classical object called the **permutohedron** $\Pi_{n-1}$.

For $n=3$ it is a regular hexagon. Its six corners are the six orderings of $\{0,1,2\}$. For $n=4$ it is a truncated octahedron with $24$ corners. In general it is an $(n-1)$-dimensional polytope with $n!$ vertices, one per ranking.

Two facts about these vertices are elementary, and they do all the work.

**Every vertex lies on a common hyperplane.** No matter how you permute, the coordinates always sum to the same thing:
$$\sum_i \sigma(i) = 0 + 1 + \cdots + (n-1) = \frac{n(n-1)}{2}.$$

**Every vertex lies on a common sphere.** The squared length is also permutation-blind:
$$\sum_i \sigma(i)^2 = \frac{n(n-1)(2n-1)}{6}.$$

So the $n!$ rankings are not scattered anywhere in space: they are *cospherical*, sitting on one sphere inside one flat slice. And now watch what happens to Spearman's statistic. Write $R = \sum_i \sigma(i)^2$ for that common squared radius. Then

$$\sum_i d_i^2 = \sum_i (\sigma(i)-\tau(i))^2 = 2\Bigl(R - \langle \sigma,\tau\rangle\Bigr).$$

The raw Spearman statistic is an *affine function of the inner product* of the two rank vectors. That is exactly the condition under which a squared distance behaves like a correlation — and indeed one can verify the exact identity

$$12\left(n\,\langle\sigma,\tau\rangle - \Bigl(\tfrac{n(n-1)}{2}\Bigr)^{2}\right) = n^2(n^2-1)\,\rho,$$

which says, in plain language: **Spearman's $\rho$ is precisely the Pearson correlation coefficient of the two rank vectors.** The strange-looking $1 - 6\sum d^2/(n^3-n)$ formula is not a convention; it is forced. Cospherical points have no choice.

---

### The dial has teeth

Once you know rankings are the corners of a polytope, you know something the continuous formula hides: **the dial cannot read every number.** It reads only the finitely many values realised by pairs of corners.

How coarse is the grid? Coarser than you would guess near the top. The displacement vector $d = \sigma - \tau$ between two vertices always sums to zero, and since $x^2$ and $x$ have the same parity, the quantity $\sum d_i^2$ is always **even**. There is no pair of rankings at squared distance $1$ — or $3$, or $5$. So if two rankings differ at all, they differ by at least $2$, and therefore

$$\rho \le 1 - \frac{12}{n^3-n}.$$

This is a **rigidity gap**. The open interval
$$\left(1 - \frac{12}{n^3-n},\ \ 1\right)$$
is *empty of possible readings*. If your dial ever shows a number in that window, you have not measured a strong correlation — you have measured perfect agreement, and something is wrong with your arithmetic. The gap is tiny for large $n$ (it scales like $12/n^3$), but it is not zero, and it makes precise the sense in which "almost perfect" is a discrete, not a continuous, notion.

The other extreme is equally rigid. Which corner is furthest from which? The answer is the obvious one, and it can be proved from cosphericity alone: the **reversal** ranking is the antipode. It maximises $\sum d^2$ over all pairs, and the exact diameter is
$$\max_{\sigma,\tau} \sum_i d_i^2 = \frac{n(n^2-1)}{3}.$$
A reading of exactly $-1$ occurs if and only if the two rankings realise this diameter — a genuinely geometric characterisation of "perfectly reversed".

For the hexagon $n=3$ one can list all $36$ vertex pairs and see the whole story at a glance: the only squared distances that occur are $0$, $2$, $6$, and $8$. Odd values are absent, as parity demands, and the diameter $8 = 3(3^2-1)/3$ is achieved exactly by opposite corners.

---

### Is the dial honest? An exact zero

Before you can read an in-band value of $0.717$ as *evidence*, you need to know the dial has no thumb on the scale — that a Spearman correlation against an unrelated ranking averages to zero. Not approximately, not asymptotically: exactly.

It does, and the proof is a one-line symmetry argument rather than a computation. Fix a position $i$ and add up the rank $\sigma(i)$ over all $n!$ permutations. Now swap positions $i$ and $j$: right-multiplying every permutation by the transposition $(i\,j)$ shuffles the group $S_n$ onto itself, and turns the total at position $i$ into the total at position $j$. So those totals are equal — the ensemble is *position-blind*, which is to say the centroid of the permutohedron is the barycentre $\left(\frac{n-1}{2},\dots,\frac{n-1}{2}\right)$. Summing over positions pins the common value, and out drops the exact first moment

$$\mathbb{E}\left[\sum_i d_i^2\right] = \frac{n^3-n}{6}, \qquad\text{hence}\qquad \sum_{\sigma \in S_n} \rho(\sigma, \mathrm{id}) = 0.$$

The normalisation $1 - 6\sum d^2/(n^3-n)$ is exactly the one that centres the statistic. For the hexagon: the six corners give $\sum d^2$ totalling $24$, mean $4$, mean $\rho$ zero. And an immediate corollary — trivial but worth stating, because it is the thing a grid column is silently assuming — is that both signs must occur: no ensemble of rankings is uniformly positively correlated with a fixed one.

---

### Three rulers, one verdict

A sceptic could object that Spearman's $\sum d^2$ is an arbitrary choice. Why square the displacements? Why not measure disagreement by total *travel*,
$$F(\sigma,\tau) = \sum_i |\sigma(i)-\tau(i)|,$$
a statistic known as **Spearman's footrule**? Or by *pairwise disorder* — the number of **inversions**, i.e. pairs $i<j$ that the two rankings order oppositely?

These are genuinely different rulers. The footrule is a bona fide metric on the group of rankings: it is symmetric, it vanishes only when the rankings coincide, it satisfies the triangle inequality, and it is *right-invariant* — relabelling the items does not change it. Better still, the map $\sigma \mapsto F(\sigma,\mathrm{id})$ is **subadditive**, $F(\sigma\tau) \le F(\sigma) + F(\tau)$, which makes it a *length function* in the sense of geometric group theory: it measures how many "units of scrambling" a permutation costs. Swapping two items in positions $a$ and $b$ costs exactly $2|a-b|$ — the two items each travel the same distance in opposite directions.

Do the three rulers ever disagree about whether a system is healthy? No, and this is the point. They are equivalent up to explicit, computable factors:

$$F \ \le\ \sum d^2 \ \le\ (n-1)\,F, \qquad F^2 \ \le\ n \sum d^2 .$$

The left inequality is the schoolchild's fact that $|x| \le x^2$ for integers. The right one says no single displacement exceeds $n-1$. The last is Cauchy–Schwarz.

And the bridge to pairwise disorder is a classical gem, the **Diaconis–Graham upper bound**:
$$F(\sigma,\mathrm{id}) \ \le\ 2\,\mathrm{inv}(\sigma).$$
Its proof is a lovely piece of double counting. If item $i$ must move $\sigma(i)-i$ places to the right, then at least that many items sitting to its right carry smaller ranks — each one is an inversion with $i$ on the left. Dually, an item moving $i-\sigma(i)$ places to the left is the right endpoint of at least that many inversions. Add the two accounts up over all positions; each account totals the inversion number (once counted by left endpoint, once by right), so the total travel is at most $2\,\mathrm{inv}$. The factor $2$ is best possible: for an adjacent swap the travel is $2$ and the inversion count is $1$. Chaining with the earlier comparison gives a purely combinatorial bound on the Euclidean reading, $\sum d^2 \le 2(n-1)\,\mathrm{inv}(\sigma)$.

The moral for the practitioner is blunt: **a band violation in one metric is a band violation in all three.** There is no clever change of ruler that rescues a failing operating point.

---

### Why the threshold knob breaks the dial

Now the payoff. Why does raising $u$ from $2.5$ to $3.5$ destroy the correlation on every population, systematically, rather than randomly?

Because a threshold does not perturb a ranking. It *destroys* one. Above the cut you flag; below, you do not. The rich, $n!$-valued object collapses into a **two-block variable**: an indicator that is $1$ on a set $B$ of size $m$ and $0$ elsewhere. And the correlation between a two-block variable and a full ranking is capped by the geometry of the permutohedron alone.

Here is why. A block of size $m$ can carry, at most, the $m$ largest ranks, and at least the $m$ smallest:
$$\frac{m(m-1)}{2} \ \le\ \sum_{i \in B}\sigma(i)\ \le\ \frac{m(2n-m-1)}{2}.$$
Both endpoints are attained — the top block under the identity ranking hits the upper one exactly. Feeding this into the covariance between the indicator and the ranks gives the sharp two-sided bound $|{\rm Cov}| \le \tfrac{1}{2}\, p(1-p)\,n$ in unnormalised form, and after dividing by the standard deviations — the indicator has variance $p(1-p)$ with $p=m/n$, and a rank vector has variance $(n^2-1)/12$ — one arrives at the **block ceiling**:

$$\boxed{\ r^2 \ \le\ \frac{3m(n-m)}{n^2-1}\ \approx\ 3p(1-p).\ }$$

This ceiling has nothing to do with the score, nothing to do with noise, nothing to do with sample size. It is a hard cap that holds for *every* statistic and *every* ranking. And it bites hard:

| flagged fraction $p$ | ceiling on $\lvert r\rvert$ |
|---|---|
| $0.50$ | $0.866$ |
| $0.30$ | $0.794$ |
| $0.20$ | $0.693$ |
| $0.10$ | $0.520$ |
| $0.05$ | $0.377$ |

A pre-registered floor of $0.71$ is *already unreachable* once the flagged fraction drops below about one fifth. At a $10\%$ flag rate on a population of $100$ strata the ceiling is exactly $2700/9999 \approx 0.270$ in squared terms, so $|r| \le 0.520$ — and the observed deep breach at $0.487$ sits comfortably under it.

That is the whole explanation. Raising $u$ shrinks the flagged fraction; shrinking the flagged fraction lowers the ceiling; and at some point the ceiling passes below the floor of the acceptance band. The measurement did not become noisy. **It became impossible.** No amount of averaging over seeds, no larger population, no better score can recover the band at that operating point — the failure is structural, and it is visible in advance from $p$ alone.

---

### What is still open

One beautiful piece of the picture remains unproved. Diaconis and Graham's theorem has a *lower* half as well:
$$\mathrm{inv}(\sigma) + T(\sigma) \ \le\ F(\sigma,\mathrm{id}),$$
where $T(\sigma)$ is the minimum number of transpositions needed to build $\sigma$ (equivalently, the number of moved items minus the number of cycles among them). Together with the upper bound this sandwiches three of the most-used metrics on rankings within constant factors of each other — a genuinely useful fact.

The obvious proofs fail for identifiable reasons. Bubble-sort induction stalls because an adjacent transposition can leave the footrule unchanged while dropping the inversion count by one. Per-position charging stalls because the number of inversions with $i$ on the left is *not* bounded by the rightward displacement of $i$ — the ranking $[2,3,1,0]$ at position $2$ is a witness. A global argument is needed, and the natural candidate is to read the inequality as a statement about competing *length functions* on the symmetric group: the footrule dominates the sum of the Coxeter length (inversions) and the Cayley length (transpositions), which suggests looking for it among the facet inequalities of the permutohedron itself. The inequality has been checked exhaustively for every ranking of up to six items.

---

### The lesson

There is a habit of mind that treats a correlation coefficient as a real number arriving from the world, to be compared against a threshold. The permutohedron says otherwise. On finite, tie-free data a rank correlation is a *chordal distance between two corners of a polytope*: it lives on a quantised grid, it has an exact diameter, it has a forbidden window just below $1$, it averages to exactly zero, and — the operationally decisive point — the moment you coarsen your data by thresholding it, the polytope hands you a ceiling that no method can climb over.

Before you tighten a threshold, compute $\sqrt{3p(1-p)}$. If it is below your band, no experiment is needed. The geometry has already told you the answer.
