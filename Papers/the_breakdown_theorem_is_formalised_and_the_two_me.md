# Half the Data Can Lie: A Guided Tour of the Breakdown Theorem for the Median

*Sixteen measurements. Some of them are wrong. How many can be wrong before your
summary of them becomes meaningless?*

---

## 1. The question, in one picture

You have repeated a delicate measurement sixteen times. Every reading came back
near $0.365$. Then you learn that some of your detectors were miscalibrated —
not all of them, some — and you have no idea which.

If you summarise the data by its **average**, the answer is bleak: a *single*
corrupted reading, pushed far enough, drags the average anywhere at all. If you
summarise by the **median**, you can lose *seven of sixteen* readings to an
omniscient adversary and still be guaranteed an answer between $0.32$ and $0.41$.

Play the adversary yourself. Slide the budget up, choose what to write into the
corrupted slots, and watch the green median line refuse to move — until the
budget hits eight, at which point it goes wherever you want.

{{interactive_demo:0}}

> **Try this.** Set the budget to $7$ and flood downward: the median slides to
> $0.32$ and stops dead at the lower edge of the honest data. Now set the budget
> to $8$: it leaves the picture entirely. Nothing gradual happens in between.
> That cliff, at exactly half the sample, is what this page is about.

---

## 2. What "median" means when the sample size is even

Sorting and picking the middle is a fine mental image, but with an even number of
observations there is no single middle. So we use the definition that needs no
tie-breaking convention at all.

> **Definition.** A number $m$ is a **median** of a dataset $x_1,\dots,x_n$ if at
> least half the entries are $\le m$ and at least half are $\ge m$:
> $$n \le 2\,\#\{i : x_i \le m\} \qquad\text{and}\qquad n \le 2\,\#\{i : m \le x_i\}.$$

For odd $n$ this pins down one number. For even $n$ it carves out an interval —
for the sixteen readings above, every $m \in [0.36, 0.37]$ qualifies, and $0.365$
is its midpoint. Every guarantee below is stated for *every* median of the
corrupted sample, so nothing is hidden in a convention about which endpoint to
pick.

<details>
<summary>Why insist on the interval rather than just averaging the two middle values?</summary>

Because a robustness theorem that only covers one particular tie-breaking rule is
much weaker than it looks: an adversary attacking a different implementation of
"the median" would fall outside its scope. Quantifying over all medians makes the
guarantee implementation-independent. Later on we will also exhibit a specific
single-valued rule — the *lower sample median*, the $\lceil n/2\rceil$-th smallest
observation — and show it inherits the optimal guarantee, so nothing is lost.
</details>

---

## 3. The adversary, made precise

The natural way to say "at most $k$ entries were tampered with" is borrowed from
the theory of [error-correcting codes](https://en.wikipedia.org/wiki/Hamming_distance).

> **Definition.** For datasets $x$ and $y$ of the same length, the **Hamming
> distance** $d_H(x,y)$ is the number of positions where they differ. A
> **$k$-contamination** of $x$ is any $y$ of the same length with $d_H(x,y)\le k$.

Nothing is assumed about *how* the corrupted values are chosen. The adversary may
see all the honest data, may know exactly which estimator you plan to use, and may
substitute any numbers at all. No probability distribution appears anywhere.

---

## 4. The one-line reason the median survives

Everything rests on an observation so simple it barely looks like mathematics.

> **Counting Stability Lemma.** For any yes/no property $P$ and any two datasets
> $x, y$ of the same length,
> $$\#\{i : P(y_i)\} \;\le\; \#\{i : P(x_i)\} + d_H(x,y).$$

Changing $d$ entries can create at most $d$ new witnesses of any property, and
destroy at most $d$ old ones. That is the entire mathematical content of the
robustness half.

<details>
<summary>Click to reveal the proof, and how it instantly gives the theorem</summary>

**Proof.** Induct on the length. Empty lists: both sides are $0$. Otherwise
compare the first entries. If $x_1 = y_1$ the head contributes equally to both
counts and $0$ to the distance, so the induction hypothesis carries through. If
$x_1 \ne y_1$ the head contributes at most $1$ to the left count and exactly $1$
to the distance, which pays for it. $\blacksquare$

**Now the consequence.** Let $y$ be a $d$-contamination of $x$ and let $m$ be any
median of $y$. By definition $n \le 2\#\{i : y_i \le m\}$. Feeding the property
"$\le m$" into the lemma,
$$n \;\le\; 2\,\#\{i : x_i \le m\} + 2d.$$
If $2d < n$ this forces $\#\{i : x_i \le m\} > 0$: **at least one genuine,
untouched observation lies at or below $m$**. Symmetrically at least one lies at
or above it. So the corrupted median is sandwiched between two real data points,
and therefore lies inside any interval containing the honest data.

That is the whole robustness theorem — no continuity, no distributional
assumption, no asymptotics, valid at every sample size.
</details>

> **Breakdown Half.** If $2k < n$, then for every $k$-contamination $y$ of $x$ and
> every median $m$ of $y$ there are honest entries with $x_i \le m \le x_j$. In
> particular, if all honest data lie in $[a,b]$, then $m \in [a,b]$.

The matching attack is even easier. Overwrite the first $k$ entries with any target
$t$. The corrupted sample then contains at least $k$ copies of $t$, so at least $k$
entries are $\le t$ and at least $k$ are $\ge t$. If $n \le 2k$, both median
conditions hold outright.

> **Sharpness Half.** If $k \le n \le 2k$, then for *every* rational $t$ there is a
> $k$-contamination of $x$ having $t$ as a median.

The two halves meet with no gap:

> **Breakdown Theorem.** The median of a non-empty dataset of length $n$ is bounded
> under contamination budget $k$ **if and only if** $2k < n$. Hence its **breakdown
> number** — the least budget at which the guarantee fails — is exactly
> $\lceil n/2 \rceil$, and its breakdown point is $1/2$.

By contrast, replacing a single entry $x_1$ of an $n$-point sample by
$c = n(|B|+1) - \sum_{i\ge2} x_i$ makes the mean exactly $|B|+1$, beating any
bound $B$ you name. **The breakdown number of the mean is $1$, for every sample
size.**

{{visualization:1}}

---

## 5. Is the median special, or is every quantile like this?

Neither, and the truth is prettier than both. Let $T_j$ denote the $j$-th smallest
observation ($0$-indexed), so $T_0$ is the minimum and $T_{n-1}$ the maximum.

> **Order-Statistic Breakdown Profile.** The breakdown number of $T_j$ is exactly
> $$\beta(j) = \min(j+1,\; n-j).$$

This is a discrete **tent**: it starts at $\beta(0) = 1$ (the sample minimum is as
fragile as the mean), climbs by one at each step inwards, peaks in the middle, and
descends symmetrically. Its maximum over $j$ is $\lceil n/2 \rceil$, attained at
the median index $j = \lfloor (n-1)/2 \rfloor$ and only there, up to the two-way
tie when $n$ is even.

Explore the tent for yourself — change $n$ and watch the peak move.

{{interactive_demo:1}}

<details>
<summary>Click to reveal why the profile is exactly min(j+1, n−j)</summary>

Two *converse* counting facts do all the work:

- if at least $j+1$ observations are $\le t$, then $T_j \le t$;
- if at least $n-j$ observations are $\ge t$, then $T_j \ge t$.

These read a bound on an order statistic off a mere **count**, which makes the
attack constructive without ever sorting anything. To destroy $T_j$ from below,
flood $j+1$ positions with a hugely negative value; to destroy it from above, flood
$n-j$ positions with a hugely positive one. The adversary takes whichever is
cheaper, giving the upper bound $\beta(j)$.

For the matching robustness statement, suppose the budget $k$ is smaller than both
$j+1$ and $n-j$. Applying the counting stability lemma to the sorted-sample bounds
$\#\{i : y_i \le T_j(y)\}\ge j+1$ and $\#\{i : T_j(y) \le y_i\}\ge n-j$ transports
them back to the honest sample at a cost of $k$ each, leaving both counts strictly
positive — so $T_j(y)$ is again sandwiched between honest observations.
</details>

{{visualization:0}}

You can compute this whole landscape for a real dataset in one sort:

{{algorithm:1}}

---

## 6. Could a cleverer estimator beat the median?

No — and the proof is a beautiful piece of sleight of hand.

Call an estimator $T$ **translation equivariant** if shifting every observation by
$c$ shifts the answer by $c$: $T(x+c) = T(x) + c$. Every reasonable *location*
estimator has this property. It just says the estimator does not care where you
put the origin.

> **Universal Breakdown Ceiling.** If $2k \ge n$, then *every* translation-equivariant
> estimator is unbounded under budget $k$. Hence no equivariant estimator has
> breakdown number above $\lceil n/2 \rceil$ — the value the median already attains.

<details>
<summary>Click to reveal the shear argument</summary>

Fix a candidate bound $B$, set $c = 2|B|+1$, split the sample at $m = n-k$, and
build two contaminated datasets:

- $y$: leave the first $m$ entries alone, add $c$ to each of the last $n-m$;
- $z$: subtract $c$ from each of the first $m$ entries, leave the last $n-m$ alone.

The first touches $n-m = k$ positions. The second touches $m = n-k \le k$ positions
— and *this* is the only place the hypothesis $2k \ge n$ is used. So both are legal
$k$-contaminations of the same honest sample.

But look at them side by side: $y$ is $z$ with $c$ added to *every* coordinate.
Equivariance therefore forces
$$T(y) = T(z) + c.$$
Two datasets the adversary can reach from the same starting point, whose estimates
are forced to differ by $c$ — and $c$ was ours to choose. No bound covers both.
$\blacksquare$

One might object that our set-valued median is not an estimator in the strict
sense. It is easy to fix: the **lower sample median**, the $\lceil n/2\rceil$-th
smallest observation, is a genuine function, really is a median in the sense above,
is translation equivariant (sorting commutes with a monotone shift), and has
breakdown number exactly $\lceil n/2\rceil$. The ceiling is attained by an honest,
computable rule.
</details>

---

## 7. The same number, hiding in coding theory

Here is the third appearance of $\lceil n/2 \rceil$, and the one that suggests
something structural is going on.

A [communications engineer](https://en.wikipedia.org/wiki/Decoding_methods) knows
that unique decoding is possible exactly when $2k < d$, where $d$ is the minimum
Hamming distance between codewords. Consider the tiniest possible code: the
two-word code $\{x,\; x + c\}$, where $x + c$ adds the constant $c$ to every
coordinate. If $c \ne 0$, *every* coordinate changes, so the minimum distance is
exactly $n$.

> **Confusability Criterion.** For $c \ne 0$, there is a single dataset within
> Hamming distance $k$ of both $x$ and $x+c$ **if and only if** $n \le 2k$.

One direction is the triangle inequality: $n = d_H(x,x+c) \le d_H(x,w) + d_H(w,x+c)
\le 2k$. The other is explicit: shift the first $n-k$ coordinates by $c$ and leave
the rest.

Compare this with the breakdown criterion — bounded if and only if $2k<n$ — and the
two are the *same inequality*.

> **Bridge Theorem.** The median breaks down under budget $k$ **if and only if** the
> two-word translation code $\{x, x+c\}$ fails unique decoding at radius $k$.

The statistical breakdown point and the coding-theoretic decoding radius are not
analogous. They are literally the same integer, computed by the same inequality.
The picture below shows the two readings of the same split of the sample.

{{visualization:2}}

{{algorithm:2}}

---

## 8. One structure, three disguises

| Structure | What is being split | Threshold condition |
|---|---|---|
| Order-statistic tent | low tail of size $j+1$ vs. high tail of size $n-j$ | $\min(j+1,\,n-j)\le \lceil n/2\rceil$ |
| Equivariance shear | head of size $m$ vs. tail of size $n-m$, translated apart | $\min(m,\,n-m)\le k$, i.e. $2k \ge n$ |
| Hamming distance | prefix corrupted towards $x$ vs. suffix towards $x+c$ | $d_H(x,x+c) = n \le 2k$ |

In all three the binding constraint is $\min(m,\,n-m) \le k$, whose maximum over
$m$ occurs at $m = \lceil n/2\rceil$. The threshold is a fact about the pigeonhole
geometry of splitting a finite set in two — which is why the answer is a half, and
why it is the *same* half every time.

---

## 9. Certified analysis of a real dataset

The theory is entirely constructive: for any dataset and budget you can produce
either a robustness certificate (an interval that provably traps every contaminated
median, plus the counting witness) or an explicit attack that installs whatever
value you like.

{{algorithm:0}}

And here is the full battery of checks on the two measured runs — sixteen readings
and eight readings, both with median $0.365$, both with breakdown point exactly
$1/2$:

{{demo:0}}

---

## 10. Why this matters beyond one experiment

The breakdown point asks only "when does the estimate stop carrying any
information?" That crudeness is its strength: it needs no model, and it answers
exactly the question a practitioner facing corrupted data wants answered.

The same $1/2$ barrier shows up throughout modern computation. In
[Byzantine-robust distributed learning](https://en.wikipedia.org/wiki/Byzantine_fault),
a server aggregating updates from many devices — some possibly compromised —
cannot in general tolerate half of them being adversarial, and coordinate-wise
median aggregation is a standard defence precisely because it attains the barrier.
The same threshold governs robust sensor fusion and consensus over reported
numerical values.

What the arguments above add is the *reason* the barrier is at a half, in three
languages at once: because the tent $\min(j+1,n-j)$ peaks in the middle; because an
equivariance shear becomes affordable exactly when $2k \ge n$; and because a global
translation moves all $n$ coordinates, giving the translation code minimum distance
$n$ and unique-decoding radius $n/2$.

The median is not a compromise or a rule of thumb. It is an optimal decoder, and
half is the capacity of the channel.

---

### Open threads

- **Weighted quantile mixtures.** Is the breakdown number of a weighted average of
  order statistics simply the tent profile evaluated at the extreme indices its
  weights touch? If so, the trimmed mean, the Winsorised mean, the midhinge and the
  Tukey trimean all fall out of one theorem.
- **Other symmetry groups.** Replace translations by an arbitrary group acting
  coordinatewise: is the breakdown number then capped by half the minimum Hamming
  distance of the group orbit? That would give a scale-equivariance ceiling for
  dispersion estimators such as the median absolute deviation.
- **Hierarchical aggregation.** A median of block medians is cheaper to compute and
  strictly less robust: capturing a majority within a majority of blocks costs about
  $n/4$ rather than $n/2$. Exactly how much robustness does blocking cost, and which
  block sizes minimise the loss?
