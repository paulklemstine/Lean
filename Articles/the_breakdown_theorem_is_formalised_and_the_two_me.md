# Half the Data Can Lie: The Exact Robustness of the Median

## A number that refuses to move

Suppose you are measuring something delicate — the fraction of a signal that lands in one of three detector channels, say — and you repeat the measurement sixteen times. Sixteen numbers come back, all clustered near $0.36$. Then someone tells you that some of your detectors were miscalibrated. Not all of them. Some.

How many of your sixteen numbers can be wrong — *arbitrarily* wrong, replaced by nonsense, by $10^{9}$, by $-10^{9}$, by whatever an adversary chooses — before your summary of the data becomes meaningless?

If your summary is the **average**, the answer is brutal: **one**. A single corrupted entry, pushed far enough, drags the mean anywhere you like. The average has no defence at all, and having a thousand honest measurements instead of sixteen does not help; one liar still wins.

If your summary is the **median**, the answer is as good as it could possibly be: **seven**. Seven of your sixteen numbers may be replaced by anything whatsoever, and the median of the corrupted sample is still guaranteed to lie between $0.32$ and $0.41$ — between the smallest and largest of your *honest* readings. And seven is not a cautious estimate. At eight, the guarantee collapses completely: an adversary who controls eight of your sixteen readings can make the median of the sample equal to *any rational number they name*.

This article is about that sharp edge — why it sits exactly where it does, why nothing can be better, and why the same number keeps appearing from three completely different directions.

## What "the median" actually means

Sorting and picking the middle is a fine mental image, but it hides a subtlety that matters here. When the sample size $n$ is even there is no single middle; there is a gap. So we use the definition that does not need a tie-breaking convention at all.

> **Definition (median).** A number $m$ is a *median* of a dataset $x_1,\dots,x_n$ if at least half of the entries are $\le m$ and at least half are $\ge m$; that is,
> $$n \le 2\,\#\{i : x_i \le m\} \quad\text{and}\quad n \le 2\,\#\{i : m \le x_i\}.$$

For odd $n$ this pins down exactly one number. For even $n$ it carves out an interval — for the sixteen measurements we will meet below, every $m$ in $[0.36,\,0.37]$ is a median, and $0.365$ is the midpoint of that interval. That interval is the honest state of affairs, and it is worth insisting on: every theorem below is stated for *every* median of the contaminated sample, so no guarantee is smuggled in through a convention about which endpoint to pick.

## The adversary, made precise

We need a way of saying "at most $k$ entries were tampered with". The natural one is borrowed from the theory of error-correcting codes.

> **Definition (contamination distance).** For two datasets $x = (x_1,\dots,x_n)$ and $y = (y_1,\dots,y_n)$ of the same length, let $d_H(x,y)$ be the number of positions $i$ with $x_i \ne y_i$.

This is the **Hamming distance**: how many coordinates the adversary had to touch. A *$k$-contamination* of $x$ is any $y$ of the same length with $d_H(x,y) \le k$. Nothing is assumed about *how* the corrupted entries were chosen — they can depend on all the honest data, they can be chosen adversarially and with full knowledge of your estimator. That is the point.

## The one-line reason the median survives

Everything rests on an observation so simple it barely looks like mathematics.

> **Counting Stability Lemma.** For any yes/no property $P$ of numbers and any two datasets $x,y$ of the same length,
> $$\#\{i : P(y_i)\} \le \#\{i : P(x_i)\} + d_H(x,y).$$

In words: changing $d$ entries can create at most $d$ new witnesses of any property, and destroy at most $d$ old ones. The proof is an induction on the length of the list — at each coordinate, either the two entries agree (and the counts move together) or they differ (and the count can shift by one, paid for by the distance). No analysis, no order statistics, no sorting. It is pure bookkeeping.

Now watch it do all the work. Let $y$ be a $d$-contamination of $x$, and let $m$ be *any* median of the contaminated sample $y$. By definition, at least half of $y$ lies at or below $m$:
$$n \le 2\,\#\{i : y_i \le m\}.$$
Feed the property "$\le m$" into the Counting Stability Lemma:
$$n \le 2\,\#\{i : x_i \le m\} + 2d.$$

> **Quantitative Robustness.** If $y$ is at Hamming distance $d$ from $x$ and $m$ is any median of $y$, then
> $$n \le 2\,\#\{i : x_i \le m\} + 2d \qquad\text{and}\qquad n \le 2\,\#\{i : m \le x_i\} + 2d.$$

And now the punchline. Suppose $2d < n$. Then the right-hand side forces $\#\{i : x_i \le m\} > 0$: **at least one genuine, untouched data point lies at or below $m$**. Symmetrically, at least one genuine data point lies at or above $m$. The median of the corrupted sample is sandwiched between two real observations.

> **Breakdown Half.** If $2k < n$, then for every $k$-contamination $y$ of $x$ and every median $m$ of $y$ there exist honest entries $x_i \le m \le x_j$. Consequently, if all honest data lie in $[a,b]$, then $m \in [a,b]$.

That is the whole robustness theorem. It fits in a paragraph, it uses no continuity, no distributional assumption, no asymptotics, and it holds for every sample size.

## The other half: why seven, and not eight

A robustness theorem with no matching sharpness statement is a half-truth; it might just be a weak argument. So we ask the adversary to attack.

Take the dataset $x$, take any target value $t$ you like, and simply overwrite the first $k$ entries of $x$ with $t$. Call the result $x^{(k,t)}$. It differs from $x$ in at most $k$ positions, so it is a legal $k$-contamination. Now count: at least $k$ of its entries equal $t$, hence at least $k$ entries are $\le t$ and at least $k$ entries are $\ge t$. If $n \le 2k$, both median conditions are satisfied outright.

> **Sharpness Half.** If $k \le n \le 2k$, then for every rational $t$ the dataset $x^{(k,t)}$ is a $k$-contamination of $x$ and $t$ is a median of it.

No cleverness required. Once the adversary owns half the sample, they own the median. And these two halves fit together with no gap between them:

> **Breakdown Theorem.** For a non-empty dataset $x$ of length $n$ and a budget $k$, the following are equivalent:
> 1. there is a bound $B$ such that every median of every $k$-contamination of $x$ satisfies $|m| \le B$;
> 2. $2k < n$.
>
> Hence the **breakdown number** of the median — the least budget at which the guarantee fails — is exactly
> $$k^\star = \left\lceil \tfrac{n}{2} \right\rceil = \left\lfloor \tfrac{n+1}{2} \right\rfloor.$$

For $n = 16$ that is $8$; for $n=8$ it is $4$. Expressed as a fraction of the sample, the **breakdown point** is $1/2$: asymptotically, the median tolerates *half* of everything being false.

The contrast with the mean is not a matter of degree. Given any proposed bound $B$, replace a single entry $x_1$ by
$$c = n\big(|B| + 1\big) - \sum_{i \ge 2} x_i,$$
and the mean of the result is exactly $|B|+1 > B$. One entry, any bound, any sample size.

> **The Mean Breaks at One.** The breakdown number of the sample mean is $1$, for every non-empty dataset.

## Could something cleverer beat the median?

Half seems like a natural barrier — with more than half the data corrupted, the "corrupted" entries are arguably the real dataset and yours are the outliers — but "seems natural" is not a theorem. Here is the theorem.

Call an estimator $T$ (any rule that turns a dataset into a number) **translation equivariant** if shifting every observation shifts the answer by the same amount:
$$T(x_1+c,\dots,x_n+c) = T(x_1,\dots,x_n) + c \quad\text{for all } c.$$
Every reasonable *location* estimator has this property — the mean, the median, trimmed means, the midrange, maximum-likelihood location estimates. It just says the estimator doesn't care where you put the origin.

> **Universal Breakdown Ceiling.** Let $T$ be any translation-equivariant estimator and let $x$ be any non-empty dataset of length $n$. If $2k \ge n$, then $T$ is unbounded under budget $k$: no bound $B$ survives every $k$-contamination.

The proof is a beautiful piece of sleight of hand — a *shear*. Split the sample at position $m = n-k$. Build two contaminated datasets:

- $y$: leave the first $m$ entries alone, add $c$ to each of the last $n-m$;
- $z$: subtract $c$ from each of the first $m$ entries, leave the last $n-m$ alone.

The first touches $n - m = k$ positions; the second touches $m = n - k \le k$ positions (this is exactly where $2k \ge n$ is used, and it is used nowhere else). So both are legal $k$-contaminations of $x$. But look at them side by side: $y$ is obtained from $z$ by adding $c$ to *every* coordinate. Equivariance therefore forces
$$T(y) = T(z) + c.$$
Two data sets the adversary can reach from the same honest sample, whose estimates are forced to differ by $c$ — and $c$ was ours to choose. Take $c = 2|B|+1$ and no bound $B$ can cover both. The estimator is broken, whatever it was.

So $\lceil n/2 \rceil$ is not just the median's number: it is a ceiling over the entire universe of equivariant location estimators, and the median sits on it.

One might still object that our set-valued median is not an estimator in the strict sense. It is easy to fix: the **lower sample median**, the $\lceil n/2\rceil$-th smallest observation, is a genuine single-valued function, it really is a median in the sense above, it is translation equivariant (sorting commutes with a monotone shift), and its breakdown number is exactly $\lceil n/2\rceil$. The ceiling is attained by an honest, computable rule.

## The full landscape: every quantile has a number

Why the *middle* order statistic, though? Here the picture becomes very pretty. For $0 \le j < n$, let $T_j(x)$ denote the $j$-th smallest observation ($0$-indexed), so $T_0$ is the minimum and $T_{n-1}$ the maximum.

> **Order-Statistic Breakdown Profile.** The breakdown number of $T_j$ is exactly
> $$\beta(j) = \min\,(j+1,\; n-j).$$

The reason is a pair of *converse sandwich* facts: if at least $j+1$ observations lie $\le t$, then $T_j \le t$; and if at least $n-j$ observations lie $\ge t$, then $T_j \ge t$. These let you read a bound on an order statistic off a mere count — which is what makes the attack constructive: to destroy $T_j$ from below, flood $j+1$ positions with a hugely negative value; to destroy it from above, flood $n-j$ positions with a hugely positive one. The adversary takes whichever is cheaper, and cannot do better than that.

The function $\beta(j) = \min(j+1, n-j)$ is a discrete **tent**: it climbs by one at each step from $\beta(0)=1$ at the sample minimum, peaks in the middle, and descends to $\beta(n-1)=1$ at the maximum. Its maximum over $j$ is $\lceil n/2 \rceil$, attained at $j = \lfloor (n-1)/2 \rfloor$ — the median index, and only there (up to the two-way tie when $n$ is even).

So the extremes of the sample are exactly as fragile as the mean — breakdown number $1$ — and robustness increases monotonically as you walk inward, hitting its ceiling precisely at the middle. The median is not merely a good choice among the quantiles; it is the unique maximiser of a concave profile.

## The same number, hiding in coding theory

Here is the third appearance of $\lceil n/2 \rceil$, and the one that suggests something structural is going on.

Forget statistics for a moment and think like a communications engineer. You transmit a codeword and the channel flips at most $k$ symbols. When can the receiver still identify what was sent? The classical answer: unique decoding is possible exactly when $2k < d$, where $d$ is the minimum Hamming distance between codewords. If $2k \ge d$, two codewords have a common "corrupted" neighbourhood and the receiver cannot tell them apart.

Now consider the tiniest possible code: the two-word code $\{x,\; x + c\}$, where $x + c$ means adding the constant $c$ to every coordinate of the sample. If $c \ne 0$, adding $c$ changes *every* coordinate, so the minimum distance of this code is
$$d_H(x,\, x+c) = n.$$

> **Confusability Criterion.** For $c \ne 0$, there exists a single dataset $w$ within Hamming distance $k$ of both $x$ and $x+c$ if and only if $n \le 2k$.

One direction is the triangle inequality for the Hamming metric: $n = d_H(x, x+c) \le d_H(x,w) + d_H(w, x+c) \le 2k$. The other is an explicit construction: shift the first $n-k$ coordinates by $c$, leave the rest, and the resulting word is within $k$ of both hypotheses.

Compare that with the breakdown criterion — the median is bounded under budget $k$ if and only if $2k < n$ — and the two are the *same inequality*.

> **Bridge Theorem.** For a non-empty sample $x$ and any non-zero shift $c$: the median breaks down under budget $k$ **if and only if** the two-word translation code $\{x, x+c\}$ fails unique decoding at radius $k$.

The statistical breakdown point and the coding-theoretic decoding radius are not analogous. They are literally the same combinatorial quantity, computed by the same inequality. Robust statistics, viewed this way, is the theory of decoding a location parameter from a corrupted transmission — and the median is the decoder that achieves the channel's information-theoretic limit.

Three independent structures — an order-statistic tent, an equivariance shear, and a Hamming minimum distance — all place the threshold at $2k = n$. That triple coincidence is the real content of the theory.

## Back to the detectors

Let us finish where we started, with actual numbers. Two runs of a three-channel measurement produced count triples $(a,b,c)$, and the recorded statistic is the normalised first channel $a/(a+b+c)$.

The sixteen-sample run gave triples $(37,41,22), (35,43,22), (38,40,22), (36,42,22), (34,44,22), (39,39,22), (33,45,22), (40,38,22), (36,41,23), (37,40,23), (35,42,23), (38,39,23), (34,43,23), (39,38,23), (41,37,22), (32,46,22)$ — every triple summing to $100$, so the normalised readings are
$$0.37,\,0.35,\,0.38,\,0.36,\,0.34,\,0.39,\,0.33,\,0.40,\,0.36,\,0.37,\,0.35,\,0.38,\,0.34,\,0.39,\,0.41,\,0.32.$$
The eight-sample run is the first eight of these. Both have median interval midpoint
$$m = \tfrac{73}{200} = 0.365.$$

The theory now speaks in concrete terms:

- **Sixteen samples.** Up to $7$ of the $16$ readings may be replaced by arbitrary values, and every median of the resulting data still lies in $[0.32,\, 0.41]$ — inside the range of the honest measurements. At $8$ the guarantee is gone: eight substitutions install any prescribed value as the median. The breakdown number is exactly $8$; the breakdown point is $8/16 = 1/2$.
- **Eight samples.** Up to $3$ corrupted readings keep every median inside $[0.33,\, 0.40]$; four corrupted readings install any value at all. Breakdown number exactly $4$, breakdown point $1/2$.
- **No alternative helps.** On these very datasets, *no* translation-equivariant estimator survives eight (respectively four) corrupted readings. The median's seven (respectively three) is not just good; it is maximal.
- **The extremes are worthless.** On the sixteen-sample run, the sample minimum $0.32$ and the sample maximum $0.41$ each have breakdown number $1$ — precisely as fragile as the mean.

Notice the shape of these statements. They are not "with high probability", not "asymptotically", not "under a Gaussian model". They are absolute, finite-sample, worst-case guarantees about specific lists of numbers, valid against an adversary who knows everything.

## Why this matters beyond detectors

The breakdown point is the crudest robustness measure there is — it asks only "when does the estimate become completely uninformative?" — and that crudeness is its strength. It requires no probabilistic model, and it answers precisely the question a practitioner facing corrupted data wants answered.

The same $1/2$ barrier shows up all over modern computation. In federated and distributed learning, a server aggregating gradient updates from many devices, some of which may be compromised, cannot in general tolerate half the devices being adversarial — and coordinate-wise median aggregation is a standard defence precisely because it attains the barrier. In sensor fusion, in blockchain-style consensus over reported values, in outlier-resistant regression, the same threshold governs the same tug-of-war: below half, the honest majority still constrains the answer; at half, the two hypotheses become indistinguishable and no rule can separate them.

The proofs above tell you *why* the barrier is at a half, in three languages at once: because the tent function $\min(j+1, n-j)$ peaks in the middle; because an equivariance shear can be paid for out of the budget exactly when $2k \ge n$; and because a global translation moves all $n$ coordinates, giving the translation code minimum distance $n$ and unique-decoding radius $n/2$.

The median, in other words, is not a compromise or a rule of thumb. It is an optimal decoder, and half is the capacity of the channel.
