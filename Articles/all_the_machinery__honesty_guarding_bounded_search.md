# Counting Your Way to Confidence: The Hidden Arithmetic of Randomised Security

## A proof that almost works

Here is a sentence that appears, in one form or another, in almost every paper on
randomised cryptography:

> *With probability at least $\varepsilon$ over the choice of the random seed, the
> protocol accepts.*

It looks like probability theory. It usually isn't. In the finite world where
cryptography actually lives — a fixed key length, a fixed challenge set, a fixed
number of coin flips — that sentence is a statement about **counting**. There is a
finite bag $\Omega$ of possible random seeds. Some of them make the protocol
accept. The claim is that the good ones make up at least an $\varepsilon$ share of
the bag:

$$\operatorname{frac}_\Omega(\text{accept}) \;=\; \frac{\#\{s \in \Omega : \text{accept}(s)\}}{\#\Omega} \;\ge\; \varepsilon .$$

No measure, no $\sigma$-algebra, no limits — just a fraction of a finite set, an
honest rational number.

This is not a pedantic distinction. The gap between "a probability" and "a fraction
of a finite set" is exactly where a certain class of subtle, embarrassing errors
hides: bounds that are true in the limit but false for the window you actually ran;
inequalities that are correct but so weak they say nothing; and, most insidiously,
statements that are *vacuously* true because somebody forgot that the bag might be
empty.

This article is about the arithmetic layer that closes that gap — a small, sharp
toolkit for reasoning about fractions of finite seed spaces — and about three
places in cryptography where using it changes the answer.

## The bookkeeping layer

Start with the object. Fix a finite set $\Omega$ of seeds and a property $A$ that
each seed either has or doesn't. The **seed fraction** is

$$\operatorname{frac}_\Omega(A) = \frac{|\{s \in \Omega : A(s)\}|}{|\Omega|} \in \mathbb{Q}.$$

It behaves the way you want: it is never negative, never exceeds $1$, it is
monotone (a weaker demand catches more seeds), and it is additive on mutually
exclusive events. Complementation holds: the good share and the bad share sum to
$1$.

Except — and this is the first place the finite world bites — *all* of those
normalisation facts silently assume $\Omega \ne \emptyset$. On an empty seed space
the numerator and the denominator are both zero, and the natural convention
$x/0 = 0$ makes the sure event have fraction $0$ rather than $1$. A security
theorem stated over an empty seed space is not merely uninformative: it is a
theorem that says $0 \ge \varepsilon$, which is *false*, or one whose conclusion is
literally unreachable. So every normalisation statement here carries an explicit
non-emptiness guard. It is one line of hygiene that eliminates an entire genre of
mistake.

Now the structural heart. Real cryptographic arguments almost never care about a
single yes/no event; they care about a **cost**: how many oracle queries, how many
probes, how deep the search went, how many bits of an error vector were wrong. A
cost is a function $c : \Omega \to \mathbb{N}$, and if it is bounded by $B$ on
$\Omega$, then the seed space splits into the $B+1$ *level sets*
$\{c = 0\}, \{c = 1\}, \dots, \{c = B\}$, and:

> **Level-Set Partition Theorem.** If $c(s) \le B$ for every $s \in \Omega$ and
> $\Omega \ne \emptyset$, then
> $$\sum_{i=0}^{B} \operatorname{frac}_\Omega(c = i) = 1.$$

That is the whole of the missing bookkeeping, and it is nothing more than counting
each seed once, in the unique stratum it belongs to, and then dividing by
$|\Omega|$. From it everything else falls out. The share of seeds solved within
$t$ steps is the partial sum $\sum_{i \le t}\operatorname{frac}(c = i)$. Markov's
inequality becomes a one-line consequence: the share of seeds with cost at least
$t$ is at most $\frac{1}{t}\cdot\frac{1}{|\Omega|}\sum_{s}c(s)$. And the average
cost admits the **layer-cake identity**

$$\mathbb{E}[c] \;=\; \sum_{i=0}^{B} i\cdot \operatorname{frac}_\Omega(c = i) \;=\; \sum_{t=1}^{B} \operatorname{frac}_\Omega(c \ge t),$$

the second form being the one that actually gets used: an average is a sum of tail
fractions. Slice the cake horizontally instead of vertically, and hard sums become
easy ones.

## Three places this matters

### 1. Bounded search, and the honest limits of Markov

A bounded search is the workhorse of constructive cryptography: given a seed $s$,
try candidate witnesses $w = 0, 1, 2, \dots$ up to a budget $B$, and stop at the
first one that works. Its cost is the number of probes performed — the index of
the first witness plus one, or the full $B$ if the search runs out of budget.

Three facts are immediate and worth stating because they are what a *guarded*
implementation is guarded by: the cost never exceeds the budget; terminating
strictly inside the budget certifies success; and failure means the cost was
exactly $B$. And there is an honesty statement: if every seed in $\Omega$ really
does carry a witness below the budget, the success fraction is exactly $1$ — not
"overwhelmingly", exactly.

Now for the interesting part. Applying Markov to the search cost gives, with no
assumption whatsoever on the underlying predicate,

$$\operatorname{frac}_\Omega(\text{cost} \ge t) \;\le\; \frac{B}{t}.$$

True, provable, and *useless*. For $t \le B$ the right-hand side is at least $1$,
so it says nothing. For $t > B$ the left-hand side is already $0$, because the cost
can't exceed $B$ in the first place. Markov cannot see the shape of a bounded
search; it only knows the mean, and here the mean is capped by the same constant
that caps everything.

The fix is to look at shape. Suppose a $p$ fraction of seeds are solved on the
*very first probe*. Each such seed costs one probe instead of at most $B$ — a
saving of $B-1$ per seed. Averaging:

> **First-Probe Savings Bound.** For a bounded search with budget $B \ge 1$ on a
> nonempty seed space, the average number of probes is at most
> $$B - (B-1)\cdot \operatorname{frac}_\Omega(\text{first probe succeeds}).$$

This is strictly better than the trivial bound $\mathbb{E} \le B$ whenever the
first-probe fraction is positive, and — unlike Markov — it is sensitive to how the
cost is distributed rather than only to where its mean sits. If half your seeds
succeed immediately with a budget of $100$, the average is at most $50.5$ probes;
Markov, from the same data, offers nothing.

The moral is worth stating plainly, because the literature tends to hide it:
recording that a standard tool gives a weak bound *here*, and saying exactly why,
is more valuable than quietly replacing it with a tool that happens to work.

### 2. Amplification is an identity, not an estimate

Repeat an experiment $k$ times with independent seeds and the failure probability
falls off geometrically. Everyone knows this. What is less often said is that on a
finite seed space it is an **exact equation**, provable by pure counting.

The product seed space is $\Omega^k$, all $|\Omega|^k$ vectors of seeds. The
vectors all of whose coordinates are good are precisely the elements of
$(\text{good})^k$, so their share is $\varepsilon^k$ exactly, where $\varepsilon$
is the one-shot fraction. Complementing:

> **Exact Amplification Theorem.** For a nonempty finite seed space $\Omega$ with
> one-shot success fraction $\varepsilon$, the fraction of $k$-tuples of seeds on
> which at least one repetition succeeds is exactly
> $$1 - (1-\varepsilon)^k.$$

Not "at least". Exactly. And the consequence you want follows immediately: since
$(1-\varepsilon)^k \le 1-\varepsilon$ for $k \ge 1$, the $k$-fold success fraction
is at least the one-shot fraction and increases monotonically toward $1$, with the
shortfall decaying geometrically. Any positive advantage, however tiny, is
amplifiable.

The non-emptiness guard earns its keep here too. The proof complements twice —
once on $\Omega$ to turn "good" into "bad", once on $\Omega^k$ to turn "all bad"
into "at least one good" — and complementation is precisely the law that the
convention $x/0 = 0$ destroys on an empty seed space, where the sure event gets
fraction $0$ instead of $1$. A hypothesis that looks like fussiness is holding up
the argument.

### 3. Sampled monitoring: when the folklore constant is wrong

Here is a security architecture in one sentence. A system runs a process that may
be malicious; a monitor checks and heals it every $k$ time steps; an adversary
attacks constantly. Folklore says: *the system is compromised for a $(k-1)/k$
fraction of the run.* Three of every four steps at $k=4$. Sounds right.

It is right — asymptotically, and only then. Consider the observation window
$\{1, 2, \dots, N\}$. Under the honesty guard that everything the monitor is
willing to restore is itself harmless, one can show the sharp characterisation:
the run is compromised at time $n \ge 1$ **exactly when $n$ is not a checkpoint**,
i.e. exactly when $k \nmid n$. (Both directions matter: the easy one says the
attack succeeds off checkpoints; the other says healing genuinely works *at* them,
and that is what turns a lower bound into an equality.)

Counting checkpoints in the window gives $\lfloor N/k \rfloor$ of them — integer
division, the crucial point — so the compromised fraction is exactly
$(N - \lfloor N/k\rfloor)/N$. Rewriting via $N = k\lfloor N/k\rfloor + (N \bmod k)$:

> **Monitoring-Window Residue Formula.** For a window of length $N \ge 1$ and
> monitoring period $k \ge 1$, the compromised fraction of the run is exactly
> $$\frac{k-1}{k} \;+\; \frac{N \bmod k}{kN}.$$

So the folklore constant is a **lower bound, never an upper bound**, and the
correction is a genuine, computable overshoot caused by the last, truncated
period, which contains no checkpoint. Two immediate corollaries sharpen it:

- **Alignment criterion.** The value $(k-1)/k$ is attained *if and only if* $k$
  divides $N$. Not approximately — exactly, and only then.
- **The $1/N$ envelope.** Since $N \bmod k \le k-1$, the overshoot is at most
  $\frac{k-1}{kN}$, so $(k-1)/k$ is the uniform limit as $N \to \infty$.

Concretely, with $k = 3$: over $N = 6$ steps you are compromised exactly $2/3$ of
the time; over $N = 4$ steps you are compromised $3/4$ of the time. If you
benchmark your monitor on a run that isn't a whole number of periods, you are
measuring a number that is genuinely worse than the constant you'd quote — and the
formula tells you by exactly how much.

There is also a discontinuity worth internalising:

> **Monitoring Dichotomy.** Continuous monitoring ($k = 1$) leaves the compromised
> fraction at exactly $0$. *Any* relaxation to $k \ge 2$ pushes it to at least
> $1/2$.

There is no gentle degradation. You cannot buy back a little performance for a
little risk: the first step away from checking every tick surrenders half the run.

## Rewinding: extracting knowledge from a fraction

The most beautiful application of this arithmetic is in zero-knowledge proofs. In a
two-move protocol, the prover commits with randomness $r$, the verifier sends a
challenge $c$, and the pair either accepts or not. The seed space is the grid
$R \times C$ of all randomness/challenge pairs, and the accepting configuration is
a subset of that grid — think of it as a black-and-white picture.

To *extract* a secret from a prover, one rewinds: find a single row $r$ that
accepts on **two different** challenges. Two accepting transcripts with the same
commitment and different challenges is exactly the data from which a witness can be
computed. So the question becomes purely combinatorial: how black must the picture
be before some row must contain two black cells?

The answer is pigeonhole, and it is sharp:

> **Rewinding Threshold Theorem.** If the accepting fraction of the grid strictly
> exceeds $1/|C|$, then some row accepts two distinct challenges.
>
> **Sharpness.** For any assignment $r \mapsto \varphi(r)$ of a single accepting
> challenge to each row, the accepting fraction is exactly $1/|C|$ and no row has
> two. So the strict inequality cannot be weakened.

A dichotomy at a razor's edge: at exactly $1/|C|$ an adversarial configuration
exists; a hair above, extraction is forced.

But existence of *one* good row is a weak guarantee — an extractor that has to find
a needle is no extractor at all. What one wants is that *many* rows are good. That
is the splitting lemma, and its proof is a two-line application of the averaging
identity that says the global fraction is the average of the row fractions:

> **Heavy-Row Splitting Lemma.** Let $e$ be the global accepting fraction and fix
> $\alpha > 0$. Call a row $\alpha e$-*heavy* if its own accepting fraction is at
> least $\alpha e$. Then the fraction of heavy rows is at least $(1-\alpha)e$.

The proof: split the average of the row fractions into heavy rows and light rows.
Heavy rows contribute at most $1$ each — the trivial bound. Light rows contribute
less than $\alpha e$ each — by definition. So
$e \le (\text{heavy fraction}) + \alpha e$, which rearranges to exactly the claim.
Taking $\alpha = 1/2$ gives the classical form: *at least an $e/2$ fraction of the
rows are $e/2$-heavy.*

Chaining the two results gives the statement an extractor designer actually uses:

> **Quantitative Rewinding.** If the accepting fraction $e$ exceeds $2/|C|$, then a
> positive fraction — at least $e/2$ — of the prover's random tapes admit two
> distinct accepting challenges.

Now the extractor has a strategy: sample random tapes, and after about $2/e$ tries
you expect to land on a heavy one, from which two accepting challenges can be
found. The abstract "some row exists" has become a running algorithm, and the whole
conversion was counting.

## Why the small stuff is the interesting stuff

None of the results here is hard in the sense of requiring a new idea. They are
counting arguments: divide a cardinality by a cardinality, split a sum, apply
pigeonhole. What makes them worth writing down carefully is that they sit at the
exact junction where informal cryptographic reasoning becomes quantitative, and
that junction is where the errors live.

Three of them appeared above, and each is a different species:

- **The vacuous statement.** A bound over a possibly-empty seed space, which the
  $x/0 = 0$ convention silently turns from a theorem into a non-theorem.
- **The weak tool.** Markov applied to a bounded search — perfectly correct,
  perfectly useless, and only visible as useless once you write the bound next to
  the trivial one it was supposed to beat.
- **The folklore constant.** $(k-1)/k$, which is a lower bound presented as an
  equality, off by an explicitly computable $\frac{N \bmod k}{kN}$ on every window
  that isn't period-aligned.

The remedy in each case is the same, and it is not cleverness: it is insisting that
"probability" mean "fraction of a finite set", and then doing the arithmetic to the
end. A ratio of two integers is an object that cannot be waved at. It is either
$2/3$ or it is $3/4$, and the difference — one extra compromised step in four — is
precisely the kind of thing that a security argument is supposed to be about.
