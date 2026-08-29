# The Compass That Knows Too Much

## A half-bit of information about factoring, and why nobody can ever collect it

There is a particular kind of disappointment familiar to anyone who has hunted for structure in
hard problems. You build a detector. The detector lights up — the signal clean, reproducible,
statistically overwhelming. And then, slowly, you realize the detector is wired to the answer.

This is the story of one such detector, and of the theorems that finally explained exactly how
much it knew, exactly why it knew it, and exactly why the knowledge is unreachable.

---

## Fermat's compass

Start with the oldest idea in factoring. You are handed an odd number $N$ and told it is the
product of two odd primes, $N = pq$. You want $p$ and $q$.

Pierre de Fermat's observation, from the 1640s, is that any such factorisation is secretly a
difference of two squares. Set

$$a = \frac{p+q}{2}, \qquad h = \frac{q-p}{2}.$$

Both are whole numbers, because $p$ and $q$ are both odd. And then

$$a^2 - h^2 = \left(\frac{p+q}{2}\right)^2 - \left(\frac{q-p}{2}\right)^2 = pq = N.$$

So factoring $N$ amounts to finding a square $a^2$ such that $a^2 - N$ is *also* a square.
Fermat's method simply walks: start at $a = \lceil \sqrt N \rceil$, the smallest candidate that
could possibly work, and increment, checking each time whether $a^2 - N$ is a perfect square.
When it is, you have $h$, and $p = a - h$, $q = a + h$ fall out immediately.

How long does the walk take? Exactly as long as the distance from your starting point to $a$
itself. Define the **Fermat gap** of the factorisation:

$$d(N) \;=\; \frac{p+q}{2} \;-\; \lfloor \sqrt N \rfloor .$$

This single number *is* the cost of the walk. It measures imbalance: when $p$ and $q$ are nearly
equal, $\frac{p+q}{2}$ sits just barely above $\sqrt N$ and $d$ is tiny; when they are wildly
unbalanced, $d$ explodes. Fermat's method is fast exactly on the numbers whose factors are close
together — which is why nobody generates RSA keys that way.

The gap is a genuine compass needle: it points, and the distance it points is the work you must
do. The question that occupies us is: **can you read the needle without already knowing where it
points?**

---

## The detector, and the 0.48 bits

Here is the experiment that started the trouble. Fix a threshold $B$ and define a one-bit
**navigation sensor**:

$$s_B(N) \;=\; \mathbf{1}\{\,d(N) \le B\,\}.$$

The sensor says "yes" if the Fermat walk would finish within $B$ steps. On a laboratory
population of odd semiprimes, this one bit was measured against $b_1$ — the lowest bit of a
hidden target quantity — and found to carry

$$I\bigl(\mathbf{1}\{d \le B\};\, b_1\bigr) \;=\; 0.479797 \text{ bits}$$

at the peak threshold $B = 22758$, where the sensor fires on $20.53\%$ of the population. Nearly
half a bit: a fair coin carries one, so this is a serious instrument, not noise. The measurement
reproduced to the last digit across an independent regeneration, and a second, freshly-seeded
population put the peak at the very same threshold with an even higher $0.4948$ bits.

So the signal is real. Is it *usable*? A sensor is merely an oracle unless some procedure can
compute it. So: build policies. Give each a budget of $295$ distinct information-bearing queries
from a fixed menu — residues, magnitude probes, combinations thereof — all computable from $N$
alone, with no peeking at $p$ or $q$. Fit them on a labelled training split, then measure how
much of the sensor's $0.48$ bits each recovers at test time.

The answer, credited leniently by pooling the whole population together, was $0.167$–$0.172$
bits: about $34$–$36\%$ of the peak, and only on one of the two seeds. Credited strictly — that
is, comparing policies against the sensor *inside* bands of similar magnitude $\log N$, so a
policy cannot win merely by noticing that big numbers behave differently from small ones — the
answer was:

**Zero. For every policy. On both seeds.**

A pooled $z$-score of $+118$ collapsed to $z \le 2.3$ within magnitude strata. The lenient
signal was not the sensor at all; it was the population's own size structure leaking through, a
base-rate channel manufactured by how the test set was built. Meanwhile the oracle itself,
evaluated within those same strata, carried $0.3634$–$0.3687$ bits — **$73.5$–$76.8\%$ of the
peak** — while the best policy managed at most $0.0018$ bits, a quarter of one percent of it.

That gap — three quarters of the peak, present in the oracle, absent from every policy — is the
subject of this article.

---

## Theorem 1: the needle is the answer

The first result says something blunt: the Fermat gap does not merely *correlate* with the
factorisation. It *is* the factorisation, in disguise.

> **Circularity Theorem.** Let $p \le q$ be odd, and let $N = pq$ with Fermat gap
> $d = \frac{p+q}{2} - \lfloor \sqrt N\rfloor$. Then
> $$p = \bigl(\lfloor\sqrt N\rfloor + d\bigr) - \Bigl\lfloor\sqrt{\bigl(\lfloor\sqrt N\rfloor+d\bigr)^2 - N}\Bigr\rfloor, \qquad
> q = \bigl(\lfloor\sqrt N\rfloor + d\bigr) + \Bigl\lfloor\sqrt{\bigl(\lfloor\sqrt N\rfloor+d\bigr)^2 - N}\Bigr\rfloor.$$
> That is: from $N$ and the single number $d$, two integer square roots recover both prime
> factors exactly.

The proof is three lines of algebra. Write $q = p + 2h$. Then $\frac{p+q}{2} = p+h$, and the
definition of the gap gives $\lfloor\sqrt N\rfloor + d = p + h$ exactly. Substituting,
$(p+h)^2 - N = (p+h)^2 - p(p+2h) = h^2$, whose integer square root is $h$ on the nose. So the
formulas return $(p+h) - h = p$ and $(p+h) + h = q$. Done.

This is what a "circularity barrier" means, stated precisely. The sensor is not a clever
heuristic that happens to track factoring: knowing its underlying statistic is *logically
equivalent* to knowing the factorisation. The needle is welded to the destination.

And the *thresholded* form is barely weaker. Given a black box answering "is $d \le B$?" for
every $B$, the least $B$ it accepts is $d$ itself — one binary search away — and Theorem 1 then
hands you the factors.

> **Oracle-to-Factoring Reduction.** Any oracle answering $\mathbf{1}\{d \le B\}$ for all
> thresholds $B$ determines the complete factorisation of $N$.

A half-bit sensor that implies a factoring algorithm was never going to be realizable by a
lightweight query policy. The measurement did not find a leak in the wall; it found a mirror.

---

## Theorem 2: the price is the gap, exactly

The second result prices the one channel that *does* realize the sensor honestly — the geometric
one, Fermat's walk itself.

Say a **scan of budget $k$ hits** $N$ if some probe $a \in \{\lfloor\sqrt N\rfloor, \ldots,
\lfloor\sqrt N\rfloor + k\}$ has $a^2 - N$ a perfect square $b^2$, with the split nontrivial
($a - b > 1$; without this guard the useless representation
$N = \left(\frac{N+1}{2}\right)^2 - \left(\frac{N-1}{2}\right)^2$ makes every odd number a "hit"
at astronomical cost).

> **Budget Law.** For $N = pq$ with $p \le q$ odd primes, a Fermat scan of budget $k$ hits $N$
> **if and only if** $d(N) \le k$.

The "if" direction is the substitution above: at $a = \lfloor\sqrt N\rfloor + d$ the remainder
is exactly $h^2$. The "only if" direction is the interesting one: the scan *cannot get lucky
early*. Any hit produces a factorisation $N = (a-b)(a+b)$ into two factors both exceeding $1$;
since $N$ is a semiprime, the only such factorisation is $\{p, q\}$, forcing
$a = \frac{p+q}{2}$ and hence the probe index to be exactly $d$.

So the sensor is realizable — at price exactly $B$ probes, never one cheaper. The experiment's
menu allowed $295$ queries; the sensor's threshold was $22758$. That ratio is the whole story:
the channel that *can* read the sensor was priced at $77$ times the available budget.

Here is a concrete inhabitant of that gulf, checkable by hand:

$$N = 955277 \times 1044727 = 998{,}003{,}674{,}379, \qquad \lfloor\sqrt N\rfloor = 999001,
\qquad d(N) = 1000002 - 999001 = 1001.$$

The sensor fires on this number: $1001 \le 22758$. A $295$-query Fermat scan misses it entirely:
$1001 > 295$. The sensor says "close"; the affordable procedure says "nothing here." A single
number, sitting squarely in the unreachable window.

---

## Theorem 3: residues see nothing at all

The laboratory's best policies leaned heavily on residue features: *what is $N$ modulo $L$?* The
measured residue-only signal was $0.0008$–$0.0032$ bits — indistinguishable from zero, but a
measurement is a measurement, and measurements have error bars.

It turns out no error bars are needed. The residue channel is not *approximately* blind; it is
*exactly* blind, for every modulus, at every threshold, on every population.

> **Residue Blindness.** For every modulus $L \ne 0$ and every threshold $B$ there exist odd
> primes $p, q_1, q_2$ such that $pq_1 \equiv pq_2 \pmod L$, yet $d(pq_1) \le B < d(pq_2)$.
> Consequently every policy that is a function of $N \bmod L$ alone errs on at least one of
> $pq_1$, $pq_2$.

The construction is delightfully cheap. Take a prime $p > L$ (so $p$ is coprime to $L$) and let
$q_1 = p$. The square $N_1 = p^2$ has $\frac{p+p}{2} = p = \sqrt{N_1}$ exactly, so its gap is
$0$ — the sensor fires. Now Dirichlet's theorem on primes in arithmetic progressions supplies a
second prime $q_2 \equiv p \pmod L$ as large as we like; choosing it far enough out makes
$\frac{p+q_2}{2}$ overshoot $\sqrt{pq_2}$ by more than $B$, so the sensor is silent. But
$pq_1 = p \cdot p \equiv p \cdot q_2 = pq_2 \pmod L$: the two numbers are congruent and the
sensor disagrees on them. Any residue-reading policy returns the same answer on both, so it is
wrong on one.

Since reading several moduli at once is reading their least common multiple, this defeats any
finite family of moduli. The measured "$0.0008$ bits" was not a small signal — it was sampling
noise around a theorem.

---

## Theorem 4: what "percentage realized" actually means

The experiment reported percentages: "$34\%$ realized leniently, $0\%$ strictly." But percentage
of *what*? Mutual information is not additive in a way that makes "$34\%$ of a sensor" a
well-posed quantity. The resolution is to stop asking about information and start asking about
*error*.

Fix a finite population $P$, a target $s : P \to \{0,1\}$ (the sensor), and a **statistic**
$T : P \to \kappa$ — the complete summary of everything a policy is permitted to read. A policy
is then just a function $f : \kappa \to \{0,1\}$, and its error is the number of population
members where $f(T(i)) \ne s(i)$.

> **Exact Crediting Law.** The minimum error over all $T$-measurable policies equals
> $$\mathrm{irr}(P,T,s) \;=\; \sum_{c\,\in\,T(P)} \min\bigl(\#\{i : T(i) = c,\ s(i)=1\},\ \#\{i : T(i)=c,\ s(i)=0\}\bigr),$$
> the sum over $T$-classes of the *minority count* in each class. The minimum is attained by the
> class-wise majority vote.

Both halves are elementary and both matter. The lower bound comes from decomposing the error
fibrewise over classes: within a class $f$ is constant, so it errs on either all the $1$s or all
the $0$s — at least the minority, either way. Attainment comes from writing the optimal policy
down: predict, in each class, whichever label is more common. Because the bound is *attained*,
"zero realization" cannot be an artefact of a weak argument.

And now the strict-crediting verdict becomes a theorem rather than a table entry:

> **Balanced Strata Give Exactly Zero.** If every class of $T$ contains equally many $1$s and
> $0$s, then the minimum error of any $T$-measurable policy is exactly $|P|/2$ — coin-flipping.
> The statistic realizes precisely none of the target.

This is the content of the collapse from $z = +118$ pooled to $z \le 2.3$ within strata. Pooling
merges classes with different base rates, and a policy that learns nothing about the sensor can
still profit from guessing those rates. Refine until each class is balanced and the profit
vanishes identically. *Pooling changes the target, not the information.*

---

## Theorem 5: cleverness doesn't help

One objection survives all of the above. The strongest laboratory policies were **adaptive**:
they chose each query in the light of previous answers, like a game of twenty questions. Maybe
adaptivity finds structure that static feature vectors miss?

Model an adaptive policy honestly, as a decision tree: internal nodes are queries drawn from a
menu $M$ of yes/no functions of the sample, edges are answers, leaves are verdicts.

> **Adaptivity Buys Nothing.** If two samples $i, j$ agree on *every* query in the menu $M$,
> then every decision tree built from queries in $M$ — of any depth, however it was fitted —
> returns the same verdict on $i$ and on $j$.

The proof is a two-line induction, and its brevity is the point. At the root both samples answer
the query identically, so both descend into the same subtree; apply the induction hypothesis.
Indistinguishability propagates through every branch. Combined with Theorem 3's colliding pair,
this closes the loop: *no adaptive residue policy of any depth matches the navigation sensor.*
Note the quantifier order — the pair is chosen **before** the tree, and defeats all trees at once.

There is also a capacity reading. A tree of depth $k$ has at most $2^k$ leaves — an easy
induction. So a depth-$k$ adaptive policy is exactly a $T$-measurable policy for a statistic with
at most $2^k$ classes, and the Exact Crediting Law applies verbatim. Adaptivity buys resolution,
not information; against an indistinguishable pair, resolution is worthless.

---

## Theorem 6: the sensor is really about divisors

Drop the assumption that $N$ is a semiprime. What is the scan cost of an *arbitrary* odd $N$?
The answer is not about primes at all.

> **Divisor-Lattice Navigation Law.** For odd $N$, a Fermat scan of budget $k$ hits $N$ if and
> only if $N$ has a divisor $e$ with $1 < e < N$ and $\frac{e + N/e}{2} \le \lfloor\sqrt N\rfloor + k$.
> Equivalently, the true scan cost is
> $$\mathrm{cost}(N) \;=\; \min_{\substack{e \mid N \\ 1 < e < N}} \left(\frac{e + N/e}{2} - \lfloor\sqrt N\rfloor\right),$$
> a minimum over the entire divisor lattice.

The mechanism is a bijection: nontrivial divisor pairs $(e, N/e)$ correspond exactly to
nontrivial Fermat representations, via $a = \frac{e + N/e}{2}$, $b = \frac{N/e - e}{2}$. On a
semiprime the lattice has exactly one nontrivial pair, and the minimum collapses to the Fermat
gap of Theorem 2. On a highly composite number there are many pairs and the nearest one to
$\sqrt N$ wins — so richly composite numbers are *easier* to navigate. In fact, since
$e \mapsto \frac{e+N/e}{2}$ is decreasing for $e \le \sqrt N$, the winner is always the largest
divisor below $\sqrt N$, never the smallest prime factor.

There is even a parity-free version. For even $N$ the divisor-pair midpoint need not be an
integer (take $N = 12$, $e = 3$). Doubling repairs it: scan $4N$ instead, with the guard
tightened to $a - b > 2$, and the same characterisation holds for *every* positive $N$.

This is what makes the circularity structural rather than incidental. The sensor is a functional
of $N$'s divisor lattice, and reading it means knowing the lattice.

---

## Theorem 7: the honest limit

One number in the experimental report deserves scepticism, and the report flagged it: the hit
rate of $0.2053$. Is it plausible that one in five semiprimes is Fermat-close?

No — and the reason is a counting argument requiring no sieve theory and no unproven hypotheses.

> **Fermat-Close Density Bound.** Fix $B$. The integers $N \le X$ admitting a factorisation
> $N = pq$ with $p \le q$ odd and Fermat gap at most $B$ number at most
> $$\bigl(\lfloor\sqrt X\rfloor + B + 1\bigr)\cdot\Bigl(\bigl\lfloor\sqrt{2B(\lfloor\sqrt X\rfloor+B)}\bigr\rfloor + 1\Bigr) \;=\; O\!\left(\sqrt B \cdot X^{3/4}\right).$$
> Hence the density of Fermat-close integers below $X$ is $O(\sqrt B \cdot X^{-1/4}) \to 0$.

The argument is a parameter count. Every such $N$ is $a^2 - h^2$ with $a = \frac{p+q}{2}$ and
$h = \frac{q-p}{2}$, and $(a,h) \mapsto a^2 - h^2$ is a function, so it suffices to count
admissible pairs. The gap condition gives $a \le \lfloor\sqrt X\rfloor + B$, which is
$O(\sqrt X)$ choices. Squaring $a \le \lfloor\sqrt N\rfloor + B$ gives
$h^2 = a^2 - N \le 2B\lfloor\sqrt N\rfloor + B^2$, so $h = O(\sqrt{B}\,X^{1/4})$. Multiply:
$O(\sqrt B \cdot X^{3/4})$ pairs, hence at most that many values.

Two parameters of sizes $X^{1/2}$ and $X^{1/4}$: that is the whole content. The bound counts a
superset — all differences of squares, not merely the semiprimes — which only strengthens it.
So a hit rate of $20.53\%$ cannot persist. It is a property of a particular finite population,
one whose construction coupled the sizes of $p$ and $q$. The roughly $24\%$ "between-strata"
slice that lenient crediting picked up is therefore a fact about the sampling design, not about
semiprimes in general. The theorem converts an honest caveat into a proved limitation.

---

## What the gap actually is

Put the pieces together and the $0.48$-bit peak decomposes cleanly, with each piece named by a
theorem.

Roughly three quarters of it — the $73.5$–$76.8\%$ measured as within-strata geometric excess —
is *genuine geometry*: the position of $\frac{p+q}{2}$ relative to $\sqrt N$. By the Budget Law
that information is realizable, at a price of exactly $B$ probes and never cheaper. With
$B = 22758$ against a menu of $295$ queries, the price exceeds the budget by a factor of $77$.
It is not hidden; it is merely expensive.

The remaining quarter is *population prior*: the size-ratio coupling of the sample, which the
Density Bound shows cannot survive to large $X$. It is real in the lab and unreal in the limit.

And the residue channel, which is what the affordable policies actually read, carries nothing at
all — not approximately nothing, but exactly nothing, at every modulus, adaptive or not.

The accounting is therefore stark. The sensor is a compass whose needle is soldered to the
destination: reading it is factoring. The gap between what it knows and what any $N$-computable
policy can know is not a gap in the experimenters' cleverness. It is the distance between a
question and its own answer.

---

## Why this is worth knowing

It would be easy to file this under "negative result" and move on. That undersells it.

First, the barrier is now *quantified*. "Circularity" was the informal explanation for why
factoring heuristics that dazzle in the laboratory refuse to become algorithms: the feature you
measured depended on the secret. Here it is a number — three quarters of the peak provably
unreachable, the remaining quarter provably an artefact.

Second, the Exact Crediting Law is reusable far beyond factoring. Whenever someone claims a
model has "realized $x\%$ of an oracle," the honest question is: what statistic may the model
read, and what is the sum of the class minorities under it? The answer is a closed form with an
explicit optimal predictor, and it turns the difference between pooled and stratified evaluation
into a theorem rather than a methodological argument. Pooled evaluation lets a model bank the
base rate; stratified evaluation does not. That distinction is the whole distance between a
$34\%$ headline and a $0\%$ reality.

Third, the divisor-lattice picture is a generalisation waiting to be explored. Fermat's method,
seen correctly, is not a factoring algorithm for near-square semiprimes; it is a proximity
search in the divisor lattice, its cost the distance from $\sqrt N$ to the nearest divisor-pair
midpoint — and none of the lattice questions this raises need the number to be a semiprime.

The compass, in the end, was working perfectly. It simply pointed at itself.
