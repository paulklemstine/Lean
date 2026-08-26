# Why One Experiment Can't Settle a Few-Percent Question

### A guided tour of cluster overdispersion, resolution floors, and the sign flip that killed an anomaly

---

## 1. The rumour, and how it died

A large computational search sweeps over Pythagorean-type configurations. For each of $m$ moduli
it samples pairs and counts *hits*. Two streams run side by side: a **candidate** stream drawn
from a structured arithmetic family, and a deliberately structureless **control**. If nothing
interesting is happening, the pooled ratio

$$r \;=\; \frac{\sum_i x_i}{\sum_i y_i}$$

sits at $1$.

For three rounds it did not. The point estimates were $0.9468$, $0.988$, $0.9623$ — a few percent
*below* $1$, each with a confidence interval that excluded $1$. A deficit was starting to look
real.

Then an audit found that all three legs descended from a single random stream. A fresh seed was
commissioned as an arbiter: $128$ clusters, $6\times10^{5}$ pairs each, $76.8$ million pairs.

| cut | candidate | control | $r$ | 95% interval |
|---|---|---|---|---|
| primary | $2598$ | $2252$ | $\mathbf{1.1536}$ | $[1.0540,\,1.2611]$ |
| looser | $40617$ | $38594$ | $\mathbf{1.0524}$ | $[1.0051,\,1.1016]$ |

A **surplus**. Not a smaller deficit — the opposite sign.

> **The punchline of this page.** Directional disagreement is a strictly stronger refutation than
> numerical disagreement, and it can be established with one line of probability. And the reason
> a single run of $77$ million pairs could never have settled the question in the first place is a
> theorem about the *shape* of the data, not about its volume.

---

## 2. First idea: two intervals cannot both be right

Suppose two runs claim to estimate the same unknown $\rho$, each reporting an interval that covers
$\rho$ with probability at least $1-\alpha$. Let $A$ and $B$ be the two coverage events. If the
intervals are **disjoint** — one strictly below $1$, one strictly above — then $A$ and $B$ are
disjoint events, so

$$2(1-\alpha) \;\le\; \mathbb{P}(A) + \mathbb{P}(B) \;=\; \mathbb{P}(A\cup B) \;\le\; 1 ,$$

forcing $\alpha \ge 1/2$. For nominal $95\%$ intervals ($\alpha = 0.05$) that is simply false.

Play with it. Drag the two intervals apart and watch the claim collapse; drag them back together
and watch the objection evaporate.

{{interactive_demo:1}}

<details>
<summary><b>Click to reveal the formal statement and proof</b></summary>

**Theorem (Coverage incompatibility).** Let $A, B$ be disjoint events in a probability space with
$\mathbb{P}(A) \ge 1-\alpha$ and $\mathbb{P}(B)\ge 1-\alpha$. Then $1 \le 2\alpha$.

*Proof.* Disjointness gives $\mathbb{P}(A\cup B) = \mathbb{P}(A)+\mathbb{P}(B) \ge 2(1-\alpha)$;
monotonicity gives $\mathbb{P}(A\cup B) \le \mathbb{P}(\Omega) = 1$. Combine. $\blacksquare$

**Theorem (Multi-run sign-partition bound).** If $A_1,\dots,A_s$ are pairwise disjoint with
$\mathbb{P}(A_i)\ge 1-\alpha$ for each $i$, then $s(1-\alpha)\le 1$, i.e. $\alpha \ge 1 - 1/s$.

*Proof.* $\mathbb{P}(\bigcup_i A_i) = \sum_i \mathbb{P}(A_i) \ge s(1-\alpha)$ and the union sits
inside $\Omega$. $\blacksquare$

Three features make this the right tool. It is **assumption-light** — no normality, no
independence between runs, only countable additivity. It is **sign-based**, so no widening of both
intervals repairs it while keeping $1$ excluded. And it is **symmetric**: it names no guilty party,
so the honest response is to bank *nothing*, in either direction. The arbiter's surplus is not
promoted to a new anomaly.

</details>

Note also a scale diagnostic visible in the table above: $40617/38594 < 2598/2252$. The apparent
effect *shrinks* as the cut is loosened and the counts grow. Scale-stable arithmetic deviations do
not behave like that; fluctuations do.

---

## 3. Second idea: the counts arrive in lumps

The hits are not one homogeneous pile. They come in **clusters**, one per modulus, and the clusters
are wildly uneven. In the arbiter run the three biggest candidate clusters carried $600$, $561$ and
$540$ hits, against a control maximum of $359$.

Write $x_1,\dots,x_m$ for the per-cluster counts, $S = \sum_i x_i$, $\bar x = S/m$, and define the
**relative cluster dispersion**

$$\mathrm{rsd}(x) \;=\; \frac{\sqrt{\sum_i (x_i-\bar x)^2}}{S}.$$

Then comes the inequality that governs everything: for **every** cluster $j$,

$$\frac{x_j}{S} \;-\; \frac{1}{m} \;\le\; \mathrm{rsd}(x).$$

If one cluster carries a share $f$ of the hits, your one-run relative resolution can never beat
$f - 1/m$. Since the bootstrap resamples *clusters*, sampling harder *within* clusters does nothing
at all.

Sweep the profile in the laboratory below. Push the top-cluster share up, add a heavy tail, change
the number of clusters, and watch the certified floor chase the true dispersion — and watch a
simulated bootstrap converge onto the closed form.

{{interactive_demo:0}}

<details>
<summary><b>Click to reveal the proof of the floor (it is three lines)</b></summary>

**Theorem (Resolution floor).** For $S = \sum_i x_i > 0$, $m$ clusters and any $j$,
$x_j/S - 1/m \le \mathrm{rsd}(x)$.

*Proof.* The single term $(x_j-\bar x)^2$ is one of the nonnegative summands of
$\sum_i (x_i-\bar x)^2$, so $(x_j-\bar x)^2 \le \sum_i (x_i-\bar x)^2$. Taking square roots and
using $t \le |t| = \sqrt{t^2}$,
$$x_j - \bar x \;\le\; \sqrt{\textstyle\sum_i (x_i-\bar x)^2}.$$
Divide by $S > 0$ and note $(x_j - S/m)/S = x_j/S - 1/m$. $\blacksquare$

**Corollary (Dominant cluster).** If $x_j \ge (1-\delta)S$, then $\mathrm{rsd}(x) \ge 1-\delta-1/m$.

**At the recorded profile:** $m = 128$, top cluster $600$, total $40617$, so the floor is
$600/40617 - 1/128 \approx 0.00696$, while the reported half-width was
$(1.1016-1.0051)/2 \approx 0.048$ — more than twice the floor. The interval was *not* narrower than
the cluster structure permits. That audit item closes cleanly.

</details>

---

## 4. But is $\mathrm{rsd}$ the *right* quantity?

A fair objection: $\mathrm{rsd}$ looks like a convenient formula. Why should a theorem about it
constrain the interval that was actually printed?

Because of an exact identity. Model a **resample** as an index vector $f$ of length $n$ drawn
uniformly from the $m$ clusters, with all $m^n$ vectors equally likely. Then for a *centred* vector
$d$ (one with $\sum_i d_i = 0$),

$$m\sum_f \Bigl(\sum_k d_{f(k)}\Bigr)^{2} \;=\; n\,m^{\,n}\sum_i d_i^{2},$$

and specialising to $n = m$ draws of the actual counts gives

$$\frac{1}{m^m}\sum_f \bigl(T^\ast(f) - S\bigr)^2 \;=\; \sum_i (x_i - \bar x)^2 .$$

So the bootstrap variance of the resampled total is *exactly* $\sum_i (x_i-\bar x)^2$, and
$\mathrm{rsd}$ is *exactly* the relative bootstrap standard error. The floor constrains the very
object the round reported.

<details>
<summary><b>Click to reveal the induction (the cross terms are the whole trick)</b></summary>

First, a lemma: for centred $d$, $\sum_f \sum_k d_{f(k)} = 0$ for every $n$. Induct, splitting a
resample of length $n+1$ into its first draw $a$ and a tail $f'$: the tail sums to $0$ by
hypothesis, leaving $m^n \sum_a d_a = 0$.

Now the second moment. With $D = \sum_i d_i^2$ and $Q_n = \sum_f (\sum_k d_{f(k)})^2$, the same
split and the expansion
$$\Bigl(d_a + \sum_k d_{f'(k)}\Bigr)^{2} = d_a^{2} + 2 d_a \sum_k d_{f'(k)} + \Bigl(\sum_k d_{f'(k)}\Bigr)^{2}$$
gives three contributions: $m^n D$ from the first, **zero** from the cross term (by the lemma), and
$m\,Q_n$ from the third. Hence $Q_{n+1} = m^n D + m Q_n$, and multiplying by $m$ and applying
$mQ_n = n m^n D$ yields $mQ_{n+1} = (n+1)m^{n+1}D$. $\blacksquare$

Dividing by $m\cdot m^n$: the resampled total of a centred vector has variance $n$ times the
population variance — the textbook formula, obtained here by pure counting.

Read more on the resampling scheme itself:
[the nonparametric bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_%28statistics%29) and
[cluster sampling design effects](https://en.wikipedia.org/wiki/Design_effect).

</details>

Here is the algorithm that produced the reported intervals, in full:

{{algorithm:0}}

and here is the audit that checks such an interval against its own structural floor:

{{algorithm:1}}

---

## 5. Third idea: the lumpiness is *in the triangles*

One could still hope the uneven profile is a sampler artefact. It is not. Cluster by hypotenuse:
let $H(c)$ be the set of ordered pairs of positive legs $(a,b)$ with $a^2+b^2=c^2$. For $c=5$ this
is $\{(3,4),(4,3)\}$. But:

> **Theorem (Unbounded hypotenuse multiplicity).** For every $k$ there is a hypotenuse $c$ with
> $|H(c)| \ge k$.

The witness is explicit and rather pretty:
$$C_k \;=\; \prod_{v=0}^{k-1}\bigl((v+2)^2+1\bigr).$$

Explore it. Type a hypotenuse and see its whole cluster; slide the construction depth $k$ and watch
the certified bound and the true multiplicity diverge; watch the two-cluster resolution floor climb.

{{interactive_demo:2}}

<details>
<summary><b>Click to reveal the construction and the distinctness argument</b></summary>

For every integer $\mu \ge 2$, $(\mu^2-1)^2 + (2\mu)^2 = (\mu^2+1)^2$. Put $\mu = v+2$ and write
$L(v) = v^2+4v+3$, $h(v)=v^2+4v+5$, so $L(v)^2 + (2(v+2))^2 = h(v)^2$ and $h(v)=L(v)+2$.

The map $v\mapsto h(v)$ is injective: $h(a)=h(b)$ gives $(a-b)(a+b+4)=0$ and the second factor is
positive.

Each $h(v)$ divides $C_k$, so $t_v = C_k/h(v)$ is a positive integer, and
$\Phi(v) = (L(v)t_v,\; 2(v+2)t_v)$ satisfies $\Phi(v)^2$-sum $= h(v)^2t_v^2 = C_k^2$, with both
coordinates between $1$ and $C_k$ (using $2(v+2)\le h(v)$, which is $(v+1)^2 \ge 0$).

Distinctness: if $\Phi(a)=\Phi(b)$ with common first coordinate $A$, then $Ah(a)=L(a)C_k$ and
$Ah(b)=L(b)C_k$; subtracting and substituting $h = L+2$ gives $(A-C_k)(h(a)-h(b))=0$. Injectivity of
$h$ forces $A = C_k$, contradicting $A = L(a)t_a < h(a)t_a = C_k$. $\blacksquare$

**The bound badly undershoots.** $C_3 = 5\cdot 10\cdot 17 = 850$ is certified to carry $3$ hits and
actually carries $14$, because the true count is multiplicative in the primes
$\equiv 1 \pmod 4$ dividing $C_k$ — see
[sums of two squares](https://en.wikipedia.org/wiki/Sum_of_two_squares_theorem) — while the scaled
family sees only one primitive triple per factor.

</details>

Combining the two theorems gives the boldest statement of the round.

> **Theorem (Near-half floor).** For every $\varepsilon > 0$ there are two distinct hypotenuses
> whose genuine hit clusters form a two-cluster family with relative resolution floor at least
> $\tfrac12 - \varepsilon$.

Pair a monster cluster of size $h$ with $|H(5)| = 2$; the floor is
$h/(h+2) - 1/2 = 1/2 - 2/(h+2) \to 1/2$. **Clustered Pythagorean search admits no universal
averaging bound.** No statement of the form "sample enough pairs and the relative error drops below
$\delta$" can hold uniformly over cluster profiles.

Here is the witness generator and the exact multiplicity count:

{{algorithm:2}}

And here is the whole picture at a glance — raw multiplicities, the witness family, and the climb
toward $1/2$:

{{visualization:1}}

---

## 6. Seeing the floor bite

The floor is not an abstraction. This figure shows the recorded profile, the floor tracking the
true dispersion as the top-cluster share is swept, and the bootstrap distribution widening as the
profile skews — with the pair count held fixed throughout.

{{visualization:0}}

---

## 7. The way out: pooling, and its limits

If one run cannot resolve the question, several might. Independent runs with variances $v_i$ combine
by inverse-variance weighting to
$$V = \Bigl(\sum_i v_i^{-1}\Bigr)^{-1},$$
which is at most the smallest single $v_i$ (pooling never hurts) and equals exactly $\sigma^2/k$
when all $k$ runs share a variance $\sigma^2$.

The recorded half-width corresponds to a one-run standard error of about $0.025$, so three genuinely
distinct seeds pool to $\sqrt{0.025^2/3} \approx 0.0144 < 0.02$ — the declared target.

<details>
<summary><b>Click to reveal why pooling is not a licence to reopen the gate</b></summary>

The multi-run bound of §2 adds a burden that no amount of pooling discharges. If the new seeds again
disagree in sign, pooling their estimates is not merely uninformative — it is *illegitimate*, because
pairwise-incompatible intervals falsify the coverage assumption that inverse-variance weighting
rests on. Any reopening of the gate must **explain** the sign flip between seed families, not
out-vote it.

There is a second, structural limit. Pooling divides the *variance* by $k$, but the per-run floor
$\max_j x_j/S - 1/m$ does not move. If the floor alone already exceeds the precision you need, then
the only lever left is the number of independent seeds — and that scales as $k \sim
(\mathrm{floor}/\mathrm{target})^2$, which becomes hopeless fast.

</details>

Try the design calculator: pick a profile and a target effect, and see how many seeds you would
need — and when the answer is "no realistic number".

{{demo:1}}

---

## 8. Two alarms that dissolved

**A formatting ghost.** A value equal to $3.38\times10^{-5}$ was printed with five-decimal
formatting as `0.00003`, appearing to fall outside its interval. It does not; truncation moved it.
Formally: there exist $lo < x < hi$ with $\lfloor 10^5 x\rfloor/10^5 < lo$ — take $lo = 0.000031$,
$x = 0.0000338$, $hi = 0.000035$. A displayed exclusion is not evidence, and recomputation from raw
counts reproduced the value exactly.

**Reproducibility.** An independent $4000$-replicate rebootstrap from the persisted raw counts
returned $[1.0540,\,1.2611]$ against the stored $[1.0541,\,1.2686]$: agreement to three decimals on
the lower limit, within Monte-Carlo error on the upper.

---

## 9. Run everything

The complete numerical companion: the mediant envelope, the exhaustive bootstrap identity check over
all $m^m$ resamples for small $m$, the floor at the recorded profile, the hypotenuse witnesses, the
near-half floor, the sign-flip audit, pooling, and the truncation artefact.

{{demo:0}}

---

## 10. What a good null looks like

It is tempting to read this round as a failure: three papers of accumulating evidence, erased by one
fresh seed. That is the wrong reading.

Before, "the search sees no deviation from randomness" was an assertion. Now it comes with contour
lines: a proof that the reported error bars match the cluster structure; a proof that the cluster
structure is intrinsic to Pythagorean arithmetic rather than an artefact of the sampler; a proof
that in the worst case no single run can beat a near-$50\%$ relative resolution; and an exact
identity showing that the bootstrap in use is precisely the object those floors constrain.

The honesty arc — bank, downgrade, null with an independence audit, clean rejection by sign flip —
is the real result. The strongest thing you can say about a scientific pipeline is not that it finds
effects. It is that it can kill its own.
