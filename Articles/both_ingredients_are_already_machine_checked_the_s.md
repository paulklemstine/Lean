# The Price of Being Ready for Anything

## How much does a code pay for not knowing the source?

Imagine you have been hired to compress a stream of data — say, the readings of a
sensor that emits one of $m$ possible symbols every second. If you knew the exact
statistical law of the sensor, information theory would tell you precisely what to
do: assign to each possible message $x$ a codeword of length $\log_2 (1/p(x))$ bits,
and you would be optimal, on average, and no scheme could beat you.

But you do not know the law. You know only that it belongs to some *family* — the
sensor is biased, but you do not know the bias; the text is English, but you do not
know the letter frequencies; the neural network was trained, but you do not know
the weights. You must pick one code, once and for all, and it must work well no
matter which member of the family turns out to be the truth.

That extra cost — the number of bits you pay *per message* for your ignorance — is
called the **redundancy**, or the **price of universality**. This article is about
a single, surprisingly rigid quantity that governs it, and about what happens at the
extremes.

## Shtarkov's sum

Fix a finite set $\mathcal{X}$ of possible messages and a family of probability
laws $\{p_\theta\}_{\theta \in \Theta}$ on it — call this a *source class*. Suppose
you commit to a code that assigns message $x$ a length of about $\log_2(1/q(x))$
bits for some distribution $q$ of your choosing. Your **regret** on a particular
message $x$, compared with the best-in-hindsight member of the family, is

$$\log_2 \frac{\sup_\theta p_\theta(x)}{q(x)}.$$

You want to make the *worst* regret over all messages as small as possible. There
is a beautiful and completely explicit answer, discovered by Yuri Shtarkov: the
optimal $q$ is obtained by *normalising the best-in-hindsight likelihood*,

$$q^\star(x) \;=\; \frac{\sup_\theta p_\theta(x)}{C_S}, \qquad
C_S \;=\; \sum_{x \in \mathcal{X}} \sup_\theta p_\theta(x),$$

and the resulting minimax regret is exactly $\log_2 C_S$ bits — the same for every
message, which is why it is minimax optimal. The number

$$C_S \;=\; \sum_{x} \sup_{\theta} p_\theta(x)$$

is the **Shtarkov sum** of the class. It is one number, it is a sum of maxima of
likelihoods, and it contains the entire worst-case story of the family.

Two bounds are immediate. Since each $p_\theta$ sums to $1$ and the maximum is at
least any single term, $C_S \ge 1$: universality is never free of charge, except
possibly in the degenerate case. And since the maximum is at most the sum, if the
family is finite with $k = |\Theta|$ members then $C_S \le k$: you never pay more
than $\log_2 k$ bits, the cost of simply *writing down which source it was* before
compressing.

So $1 \le C_S \le k$: between free and "name the source". The natural question —
and the subject of this article — is: **when exactly do you sit at each end, and
how far from an endpoint are you when you miss it?**

## A conservation law

The key turns out to be an exact identity that upgrades the inequality
$C_S \le k$ into a bookkeeping statement. Define the **overlap** of the class,

$$\Omega \;=\; \sum_{x}\Big(\sum_{\theta} p_\theta(x) \;-\; \max_\theta p_\theta(x)\Big).$$

Every term is non-negative, so $\Omega \ge 0$; it measures the probability mass the
sources *share*, the mass that is not claimed by the single most enthusiastic source
at each message. Then, summing over $x$ and swapping the order of summation:

> **Conservation Law.** For a class of $k$ sources on a finite message space,
> $$C_S + \Omega = k.$$

The proof fits in a line: $\sum_x \max_\theta p_\theta(x) + \sum_x(\sum_\theta p_\theta(x) - \max_\theta p_\theta(x)) = \sum_\theta \sum_x p_\theta(x) = k$. But this
one line reorganises everything. The price of universality and the overlap of the
family are two halves of a fixed budget of $k$. Every rigidity statement below is
really a statement about $\Omega$.

## The two extremes, made rigid

**Maximal price.** $C_S = k$ if and only if $\Omega = 0$, i.e. if and only if the
sources are **mutually singular**: no message has positive probability under two
different members. Equivalently — and this is the working criterion — there is a
family of pairwise disjoint sets $\mathrm{supp}(\theta) \subseteq \mathcal{X}$ with
$p_\theta(\mathrm{supp}(\theta)) = 1$ for each $\theta$. Only when the sources live
on disjoint worlds do you genuinely have to spend $\log_2 k$ bits naming which world
you are in. And the converse has teeth: a *single* message shared by two sources,
with positive probability under both, already forces $C_S < k$ strictly.

**Zero price.** $C_S = 1$ if and only if all the sources are the same law. This is
the other rigid endpoint. Any genuine disagreement — one message on which two
members assign different probabilities — makes $C_S > 1$, so universality costs a
strictly positive number of bits. There is no free lunch and no near-free lunch by
accident.

## The price of a pair *is* a distance

For a class of exactly two sources $p$ and $q$, something exact happens. Using
$\max(a,b) = \tfrac{1}{2}(a + b + |a-b|)$ and summing:

> **Two-Source Formula.** $C_S = 1 + d_{\mathrm{TV}}(p,q)$, where
> $d_{\mathrm{TV}}(p,q) = \frac{1}{2}\sum_x |p(x) - q(x)|$ is the total variation
> distance.

This is a small gem. The price of universality of a pair is *literally* the
statistical distance between its members, interpolating continuously between the two
rigid endpoints: at $d_{\mathrm{TV}} = 0$ the laws coincide and $C_S = 1$; at
$d_{\mathrm{TV}} = 1$ they are singular and $C_S = 2$. Redundancy is
distinguishability.

For larger classes the identity becomes a sandwich. On one side, restricting to any
two members can only lower the Shtarkov sum, so

$$1 + \max_{\theta \ne \theta'} d_{\mathrm{TV}}(p_\theta,p_{\theta'}) \;\le\; C_S;$$

pairwise separation is a lower bound on the price. On the other side, comparing
everything with a fixed reference member $\theta_0$ and using
$p_\theta(x) \le p_{\theta_0}(x) + (p_\theta(x)-p_{\theta_0}(x))_+$ gives

$$C_S \;\le\; 1 + \sum_{\theta} d_{\mathrm{TV}}(p_\theta, p_{\theta_0}).$$

And near the *top* end there is a stability statement: for any two distinct members,

$$C_S \;\le\; k - 1 + d_{\mathrm{TV}}(p_\theta, p_{\theta'}).$$

One close pair — two sources you cannot tell apart — is enough to pull the whole
class away from the maximal price, by an amount equal to their affinity
$1 - d_{\mathrm{TV}}$. This quantifies the rigidity theorem: not only does
$d_{\mathrm{TV}}=1$ characterise the extreme case, but being $\varepsilon$ away from
singular costs you $\varepsilon$ off the maximum. A summed version says more: the
total affinity over all ordered pairs of distinct sources is bounded by
$k(k-1)\,\Omega$, so the deficiency $k - C_S$ controls the *average* pairwise
affinity of the family, not just the best pair.

## Tying the knot: why blocks are cheaper than the sum of their parts

Now the payoff. Real universal coding does not compress a single symbol; it
compresses a long block, and the whole point is that one unknown parameter governs
*all* the symbols. What does the Shtarkov sum do under such a *tied product*?

Given two message spaces $\mathcal{X}_1$, $\mathcal{X}_2$ and two families indexed
by the **same** parameter set, the tied product is the family on
$\mathcal{X}_1\times\mathcal{X}_2$ with
$p_\theta(x_1,x_2) = p^{(1)}_\theta(x_1)\,p^{(2)}_\theta(x_2)$ — the same $\theta$
in both factors. Pointwise,

$$\max_\theta p^{(1)}_\theta(x_1)p^{(2)}_\theta(x_2)
\;\le\; \Big(\max_\theta p^{(1)}_\theta(x_1)\Big)\Big(\max_\theta p^{(2)}_\theta(x_2)\Big),$$

because one $\theta$ has to serve both factors. Summing gives *submultiplicativity*:
$C_S(\text{tied}) \le C_S^{(1)}\cdot C_S^{(2)}$, which in bits says the price of
universality is **subadditive** in block length — precisely the hypothesis of
Fekete's lemma, so the per-symbol price converges.

But when is the inequality an equality? Since the whole thing is a sum of pointwise
inequalities, equality holds if and only if every one of them is tight:

> **Equality Criterion.** $C_S(\text{tied}) = C_S^{(1)} C_S^{(2)}$ if and only if
> for every pair of block outcomes $(x_1,x_2)$ there exists a *single* parameter
> $\theta$ maximising the likelihood of $x_1$ in the first block **and** the
> likelihood of $x_2$ in the second block simultaneously.

A **common maximiser** for every pair — that is the exact condition for tying to buy
you nothing. It is a clean criterion, and it is checkable.

## Cashing it in: the memoryless source

Take the workhorse of universal coding. The alphabet is a finite set $\mathcal{A}$
with $m = |\mathcal{A}| \ge 2$ letters; the parameter is a probability vector
$\theta$ on $\mathcal{A}$ (a point of the simplex); the source of block length $n$
emits $n$ letters independently, so
$p_\theta(x_1\ldots x_n) = \prod_i \theta(x_i)$.

Two facts, and then the punchline.

*Fact one: at length one the price is maximal.* For a single symbol $a$, the point
mass at $a$ gives it likelihood $1$, so the best-in-hindsight likelihood of every
one-symbol message is $1$ and $C_S(1) = m$. In other words, at $n = 1$ the
memoryless family sits exactly at the *upper* rigid endpoint: it is as expensive as
naming the letter. (It is, after all, the class of point masses in disguise, and
those are mutually singular.)

*Fact two: no common maximiser, quantitatively.* Consider the two constant blocks
$aa\ldots a$ (length $n_1$) and $bb\ldots b$ (length $n_2$) for two distinct letters
$a \ne b$. Separately, each has best-in-hindsight likelihood exactly $1$, achieved
only by the corresponding point mass. But a probability vector cannot put mass $1$
on two different letters, so there is no common maximiser — and the inequality must
be strict. Better, we can quantify the failure. For any $\theta$,

$$\theta(a)^{n_1}\theta(b)^{n_2} \;\le\; \theta(a)\,\theta(b) \;\le\; \frac{1}{4},$$

using $\theta(a),\theta(b) \in [0,1]$, $n_1,n_2 \ge 1$, and $\theta(a) + \theta(b) \le 1$
with the arithmetic–geometric mean inequality. So the tied likelihood envelope at
this one pair of outcomes is at most $\tfrac14$, while the product of the separate
envelopes is $1$. A deficit of $3/4$ at a single message.

This quantitative form is what makes the argument work at all. The abstract
"no common maximiser" criterion needs a maximiser to *exist*, which requires a
finite parameter set — and the simplex is not finite. Replacing "no maximiser is
shared" by "the envelope is quantitatively deficient" transfers the whole argument
from finite to continuous families. That trade is the technical heart of the matter.

Putting the two facts together — and noting that a block of length $n_1+n_2$ *is*
the tied product of its two sub-blocks, no information lost in the relabelling —
we get:

> **Strict Subadditivity.** For an alphabet with at least two letters and any
> $n_1, n_2 \ge 1$,
> $$C_S(n_1+n_2) \;<\; C_S(n_1)\cdot C_S(n_2),$$
> equivalently, in bits, the minimax regret is *strictly* subadditive:
> $\log_2 C_S(n_1+n_2) < \log_2 C_S(n_1) + \log_2 C_S(n_2)$.

And by induction from $C_S(1) = m$:

> **Compounding Gain.** For every $n \ge 2$, $C_S(n) < m^n$.

## What this actually says

The bound $C_S(n) < m^n$ is a comparison between two ways of describing a length-$n$
message. The right-hand side is what you would pay if every symbol carried its own
free parameter: $n$ independent copies of the length-one problem, each at the maximal
price $m$. The left-hand side is what you actually pay when the same $\theta$ drives
every symbol.

The theorem says the second is *always* strictly cheaper, at every length, and the
gain compounds: it is picked up afresh at every split. That is the qualitative
engine behind the celebrated asymptotics of universal coding — for the memoryless
class the minimax regret is $\frac{m-1}{2}\log_2 n + O(1)$ bits, logarithmic in
block length rather than linear. The exponential price $m^n$ of "one parameter per
symbol" collapses to a polynomial one precisely because the blocks are *tied*.

How big is the gain? For the binary alphabet, the exact Shtarkov sums (obtained by
grouping messages into *types*, i.e. by the number of ones, and evaluating
$C_S(n)=\sum_{k=0}^n \binom{n}{k}(k/n)^k((n-k)/n)^{n-k}$) begin

| $n$ | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| $C_S(n)$ | $2$ | $5/2$ | $26/9$ | $103/32$ | $2194/625$ |
| $2^n$ | $2$ | $4$ | $8$ | $16$ | $32$ |

Already at $n = 2$ the tied price is a factor $1.6$ below the untied one; at $n = 5$
the factor is over $9$; and it keeps growing, because $C_S(n)$ grows like $\sqrt{n}$
while $2^n$ grows exponentially. The strict inequality proved here is thus true but
far from tight — which is itself the invitation: the conservation law
$C_S + \Omega = k$, the total-variation identities, and the equality criterion for
tying together form a toolkit for *quantifying* how far below the maximum a family
sits, and the sharp constants remain to be found.

## The moral

Redundancy is not a mysterious overhead. It is a single sum of pointwise maxima,
constrained by a conservation law, and the two ends of its range are rigid: maximal
price means mutual singularity, zero price means the family is a single point. For
two sources it is literally a distance. And when a family is built by sharing a
parameter across blocks — which is what every real statistical model does — that
sharing always buys you something, strictly, at every split.

The price of being ready for anything is real, but the more you tie your hands, the
less you pay.
