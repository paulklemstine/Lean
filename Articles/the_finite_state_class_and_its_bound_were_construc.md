# The Price of Not Knowing: How Much Does a Machine Pay to Learn a Coin?

## A wager about the future of a message

Imagine you have to compress a file — a long string of bits $x = x_1 x_2 \dots x_n$ — and you must commit to your compression scheme *before* you see the file. Somebody else, an adversary with perfect hindsight, gets to look at the file first and then choose the best possible compressor from an agreed-upon catalogue of models. You will lose. The only question is: **by how much?**

That gap is called the **regret**, and it is one of the most quietly beautiful quantities in information theory. It measures the price of ignorance: how many extra bits you must pay simply because you had to guess the model in advance.

Remarkably, the entire answer for a whole family of models is encoded in a single number, an innocuous-looking sum:

$$S \;=\; \sum_{x} \, \sup_{\theta} \, P_\theta(x).$$

Here $x$ runs over all $2^n$ possible files of length $n$, and $\sup_\theta$ means: for each file, take the very best probability the catalogue of models can offer it. This is the **Shtarkov sum**. Its logarithm, $\log S$, is *exactly* the minimax regret — the number of extra nats you pay, in the worst case, against a hindsight-optimal opponent. And once you know $S$, you know everything about the worst case.

This article is about what happens to $S$ when the catalogue of models is the set of **finite-state machines**: little automata with $k$ internal states, each state flipping its own private biased coin. It turns out that the answer has a startlingly clean shape, that it is governed by a *counting* principle rather than an analytic one, and that as the number of states is allowed to grow with the message length, the system undergoes a sharp **phase transition** between "compressible" and "hopeless".

## The tropical trick: a supremum is a sum

Look at that inner supremum again. It is annoying: suprema do not commute with sums, they do not linearise, they resist the usual calculus. But take logarithms and the picture changes completely:

$$\log \sup_\theta P_\theta(x) \;=\; \max_\theta \log P_\theta(x).$$

In **tropical** (or *max-plus*) algebra, one replaces ordinary addition by $\max$ and ordinary multiplication by $+$. Under this dictionary, the expression $\max_\theta \log P_\theta(x)$ is just an *ordinary sum*, taken in the tropical semiring, over the models in the catalogue. And since likelihoods multiply along a sequence, $\log P_\theta(x) = \sum_i \log P_\theta(x_i \mid \text{past})$ is a tropical *product*. In other words:

> The pointwise supremum of a model class is the **tropicalisation** of that class, and the Shtarkov sum is the ordinary mass of the tropicalised object.

This is not merely a change of notation. It tells you what kind of object $S$ is, and therefore what kind of tools should work on it. Tropical objects are combinatorial: they are governed by piecewise-linear geometry, by lattice points, by counting. And so, as we will see, is the Shtarkov sum. Every logarithmic regret bound in the literature — the famous "$\tfrac{d}{2}\log n$ for a $d$-parameter family" — is in the end a *counting* statement in disguise.

## Two levers

Almost everything about Shtarkov sums can be squeezed out of two elementary but extremely flexible principles. Both are about the geometry of the supremum; neither requires any analysis.

**The packing principle (lower bound).** Suppose the models all satisfy $0 \le P_\theta(x) \le 1$. Pick any collection $A$ of files, and for each file $a \in A$ pick your favourite model $f(a)$ for it. Then

$$\sum_{a \in A} P_{f(a)}(a) \;\le\; S.$$

The proof is two lines: each term $P_{f(a)}(a)$ is at most the supremum $\sup_\theta P_\theta(a)$, and summing over $A$ is at most summing over everything. But the consequences are severe. If the catalogue is rich enough that for each of $N$ files there is a model giving that file probability nearly $1$, then $S \gtrsim N$: the regret is at least $\log N$. **Memorisation costs regret.**

**The sufficient-statistic principle (upper bound).** Suppose there is a function $T$ — a *statistic* — computed from the file, and a family $q_y$ of sub-probability measures indexed by the values $y$ of that statistic, such that every model is dominated by the corresponding member:

$$P_\theta(x) \;\le\; q_{T(x)}(x) \qquad \text{for all } \theta, x .$$

Then $S \le \#\{\text{values } T \text{ takes}\}$.

The proof is a fibration. Group the files by the value of $T$; on each fibre, the total mass collected is at most $1$, because $q_y$ is a sub-probability measure and the fibre is only part of the sample space. So each value of the statistic contributes at most one unit, and the whole sum is bounded by the number of values. **The regret is at most the log of the number of distinguishable summaries of the data.**

That single sentence is the entire content of the $\frac{d}{2}\log n$ folklore. A $d$-parameter model class is one whose maximum-likelihood fit depends on the data only through $d$ counts, each in $\{0,1,\dots,n\}$, so the statistic takes about $n^d$ values — and a more careful accounting, weighting each fibre by its true mass rather than by one unit, brings this down to $n^{d/2}$.

## The one-dimensional heart

Before automata, one coin. If a coin with unknown bias $\theta$ comes up heads $a$ times and tails $b$ times, its likelihood is $\theta^a(1-\theta)^b$, and the classical fact is that this is maximised at the *empirical frequency*

$$\hat\theta \;=\; \frac{a}{a+b}, \qquad \text{so} \qquad \theta^a (1-\theta)^b \;\le\; \hat\theta^{\,a} (1-\hat\theta)^{\,b} \quad \text{for all } \theta \in [0,1].$$

You can prove it with calculus, but the honest proof is information-theoretic: take logarithms, use the elementary inequality $\log u \le u - 1$ on the ratios $\theta / \hat\theta$ and $(1-\theta)/(1-\hat\theta)$, and watch the two error terms cancel exactly because $a\hat\theta^{-1}$ and $b(1-\hat\theta)^{-1}$ are both equal to $a+b$. This is Gibbs' inequality in a two-atom disguise. It is the analytic core, and it is the *only* analysis in the whole story.

Notice what this inequality provides: a single "plug-in" model, determined entirely by the counts $(a,b)$, that dominates every model in the catalogue simultaneously. That is precisely the hypothesis of the sufficient-statistic principle.

## Automata that flip coins

Now the models. Fix a deterministic automaton $M$ with $k$ states and a binary alphabet: a start state and a transition rule $\delta(s, b)$ telling the machine where to go after emitting bit $b$ in state $s$. Attach to each state $s$ a Bernoulli parameter $\theta_s \in [0,1]$: whenever the machine finds itself in state $s$, it emits $1$ with probability $\theta_s$ and $0$ with probability $1-\theta_s$, then moves to $\delta(s, b)$.

This is a genuine probability model — the total mass over words of length $n$ is exactly $1$, from any start state and for any parameter vector, as one checks by induction on $n$ (peel off the first symbol, use that the two emission weights in a state sum to $1$). The **finite-state class** is the family of all these sources as $\theta = (\theta_1,\dots,\theta_k)$ ranges over the cube $[0,1]^k$. It is the workhorse model of universal source coding: context-tree sources, Markov chains of any order, and the classical Lempel–Ziv-style models all live inside it.

The crucial structural fact is a **factorisation**. Let $a_s(x)$ be the number of time steps at which the machine, reading $x$, sits in state $s$ and emits a $1$, and $b_s(x)$ the number at which it sits in $s$ and emits a $0$. Because the automaton is deterministic, these counts are functions of $x$ alone, and the likelihood collapses:

$$P_\theta(x) \;=\; \prod_{s=1}^{k} \theta_s^{\,a_s(x)} (1-\theta_s)^{\,b_s(x)}.$$

The sequence has dissolved into a vector of $2k$ counts. Combining this with the one-coin inequality, applied independently in each state, gives the **plug-in domination**: the source whose parameters are the empirical frequencies $\hat\theta_s = a_s/(a_s+b_s)$ assigns $x$ at least as much probability as every other member of the class. In tropical language: *the max-plus envelope of the finite-state class is attained, and it is attained at the empirical model.*

## The counting bound

Now feed this into the sufficient-statistic principle. The dominating model depends on $x$ only through the count vector $\big((a_s(x), b_s(x))\big)_{s=1}^k$, and each count lies in $\{0, 1, \dots, n\}$. So the statistic takes at most $(n+1)^{2k}$ values, and:

> **Theorem (finite-state Shtarkov bound).** For every $k$-state binary automaton $M$ and every $n$,
> $$S_n(M) \;=\; \sum_{x \in \{0,1\}^n} \max_{\theta \in [0,1]^k} P_\theta(x) \;\le\; \big((n+1)^2\big)^{k},$$
> equivalently, the minimax pointwise regret satisfies $\log S_n(M) \le 2k \log(n+1)$.

Two remarks make this sharp-feeling result feel even sharper. First, it is *uniform in the automaton*: the transition structure is completely irrelevant to the bound, only the number of states matters. Second, in the smallest case the accounting can be tightened dramatically. For a one-state (memoryless) machine, the two counts satisfy $a + b = n$, so the second is determined by the first, and the statistic takes only $n+1$ values:

> **Theorem (memoryless bound).** For a single-state machine, $S_n \le n+1$, i.e. the regret of the Bernoulli family is at most $\log(n+1)$.

This is the well-known "half a log per parameter, up to constants" phenomenon: one free parameter, one factor of $n$. (The true value is $S_n \sim \sqrt{\pi n / 2}$, the square-root refinement that a mass-weighted count, rather than a one-unit-per-fibre count, would deliver.)

There is also a free universal cap, valid for any class of sub-probability measures whatsoever: $S_n \le 2^n$, since each of $2^n$ words contributes at most $1$. And a free floor: $S_n \ge 1$, because the class contains at least one probability measure and probability measures have total mass $1$. So always

$$1 \;\le\; S_n(M) \;\le\; \min\left\{ (n+1)^{2k},\; 2^n \right\}.$$

## When the automaton wins: saturation

The counting bound is only useful when $(n+1)^{2k} \ll 2^n$, i.e. when $k = o(n / \log n)$. What if the machine has *more* states than that? Here the packing principle bites, and it bites hard.

Consider the **counter machine** with $n+1$ states, whose state is simply the current time index (capped at $n$): in state $i$ it emits a bit and moves to state $i+1$. Each time step now has its own private coin. Given any target word $z$, set the coin at step $i$ to be a deterministic coin agreeing with $z_i$ — parameter $1$ if $z_i = 1$, parameter $0$ if $z_i = 0$. That source assigns $z$ probability exactly $1$. Every word can be memorised.

Applying the packing principle with $A$ = all $2^n$ words gives $S_n \ge 2^n$; the universal cap gives $S_n \le 2^n$. Hence:

> **Theorem (saturation).** For the counter machine with $n+1$ states, $S_n = 2^n$ exactly, and the minimax regret is $n \log 2$ — the entire message length.

There is no compression at all in the worst case. The catalogue is so rich that hindsight always wins by everything.

## The phase transition

Put the two sides together and let the *state budget* $k(n)$ grow with the block length. Define the **regret rate** as regret per symbol, $\log S_n / n$: this is the per-symbol overhead of universal coding.

- If $k(n)\log(n+1) = o(n)$, then $\log S_n / n \le 2 k(n) \log(n+1) / n \to 0$: the regret rate vanishes.
- If $k(n) = n+1$, then for the counter machine the regret rate is exactly $\log 2$ for every $n \ge 1$ — the largest it can possibly be.

The concrete threshold family $k(n) = \lfloor \sqrt n \rfloor + 1$ falls comfortably on the good side, since $\sqrt n \log n / n \to 0$. So:

> **Theorem (state-budget dichotomy).** Every family of automata with $\lfloor\sqrt n\rfloor + 1$ states has per-symbol minimax redundancy tending to $0$, whereas the counter family with $n+1$ states has per-symbol redundancy exactly $\log 2$ for all $n \ge 1$.

This is a genuine dichotomy, not a matter of constants: on one side the overhead is asymptotically free, on the other side it is *everything*. Unboundedly many states are perfectly compatible with asymptotically optimal compression — you may grow your model complexity like $\sqrt n$, or like $n / \log^2 n$, and still pay nothing per symbol in the limit. But grow it linearly and the model class becomes a lookup table, and a lookup table teaches you nothing.

## The same statement in the language of entropy

There is a second face to all of this, and it is arguably the more suggestive one. Take the plug-in likelihood and take its logarithm. In each state, the maximised factor is

$$\hat\theta_s^{\,a_s}(1-\hat\theta_s)^{\,b_s} \;=\; \exp\big(-(a_s + b_s)\, h(\hat\theta_s)\big), \qquad h(p) = -p\log p - (1-p)\log(1-p),$$

with $h$ the binary entropy function. Multiplying over states, define the **empirical entropy of $x$ relative to $M$**:

$$\hat H_M(x) \;=\; \sum_{s=1}^{k} (a_s(x) + b_s(x))\, h\!\left(\frac{a_s(x)}{a_s(x) + b_s(x)}\right).$$

This is exactly the number of nats the ideal state-conditional code would spend on $x$ if it were allowed to fit its coin biases to $x$ after the fact. And then the supremum over the class is literally $e^{-\hat H_M(x)}$, so the Shtarkov sum is a **partition function**:

$$S_n(M) \;=\; \sum_{x \in \{0,1\}^n} e^{-\hat H_M(x)}.$$

Combined with the counting bound, this yields a Kraft-type inequality for empirical entropies:

> **Theorem (Kraft inequality for empirical entropy).** For every $k$-state automaton and every $n$,
> $$\sum_{x \in \{0,1\}^n} e^{-\hat H_M(x)} \;\le\; \big((n+1)^2\big)^{k}.$$

Read it as a *no-free-lunch* statement. Kraft's inequality says the codeword lengths $\ell(x)$ of any prefix code satisfy $\sum_x e^{-\ell(x)} \le 1$. The empirical entropies $\hat H_M(x)$ are *not* codeword lengths — they cheat, because they are allowed to fit the model to the data. The theorem says the cheat is bounded: the empirical entropies violate Kraft by at most a factor $(n+1)^{2k}$, that is, by at most $2k\log(n+1)$ nats. Fitting your model to your data buys you no more than two logarithms per state. And these entropies are honestly constrained: $0 \le \hat H_M(x) \le n\log 2$, since the visit counts partition $\{0,1,\dots,n-1\}$ and each binary entropy is at most $\log 2$.

## Two structural laws

Finally, two facts that show the Shtarkov sum behaves like a well-bred invariant rather than an accident of the construction.

**Tensorisation.** If two model classes, each with an attained pointwise supremum, are combined independently — the product class assigning $P_i(x)Q_j(y)$ to the pair $(x,y)$ — then the Shtarkov sums multiply:

$$S(P \otimes Q) \;=\; S(P)\, S(Q).$$

Regret is *additive over independent components*. This is the reason regret behaves like a dimension count in the first place; it is also exactly the statement that tropicalisation is multiplicative.

**Monotonicity under refinement.** Say an automaton $M'$ *simulates* $M$ if there is a map $\pi$ from the states of $M'$ onto those of $M$ carrying the start state to the start state and intertwining the transitions, $\pi(\delta'(s,b)) = \delta(\pi(s), b)$. Then every source of $M$ is also a source of $M'$ — pull the parameters back along $\pi$ — so the finer class contains the coarser, and

$$S_n(M) \;\le\; S_n(M').$$

Refining your state space can only increase the regret. Complexity is monotone: you never gain worst-case robustness by giving your model more memory.

**Automata cannot memorise.** Combining the packing principle with the counting bound gives a pigeonhole with teeth. A $k$-state machine can assign probability $1$ to at most $(n+1)^{2k}$ distinct words of length $n$. In particular, whenever $(n+1)^{2k} < 2^n$ — for instance, for a single-state machine and any $n \ge 6$ — there exists a word of length $n$ that *every* parameterisation of the machine assigns probability strictly less than $1$. Small automata, however cleverly wired and however finely tuned, simply do not have the capacity to remember an arbitrary string. Their capacity is $2k\log(n+1)$ nats, and not one nat more.

## Why it matters

The story has a moral that runs well beyond compression. Every act of learning from data involves a hindsight opponent: the model you would have chosen if you had seen the data. The regret is the price of choosing first, and the Shtarkov sum measures that price exactly. What the tropical viewpoint tells us is that this price is fundamentally *combinatorial* — it is the logarithm of the number of distinguishable ways the data can look to your model class, weighted by how much mass each of those looks can absorb.

That is also, essentially, the modern statistician's notion of *effective dimension*, the machine learner's notion of *capacity*, and the coding theorist's notion of *model cost* in minimum description length. Here they all coincide in a single quantity, and both bounds on it come from principles that fit on a postcard: pack, and count.

The state-budget dichotomy is the sharpest illustration. Ask your model class to have $\sqrt n$ moving parts, and in the long run its complexity is free. Ask it to have $n$ moving parts, and it becomes a memory rather than a theory, and the compression — the *understanding* — disappears entirely.

There is a natural next question, and it is a precise one. The counting bound charges one unit of mass per value of the statistic, but the true mass a fibre can carry is only about $n^{-1/2}$ per free parameter — the Gaussian width of a binomial peak. Replacing "one unit per value" by "actual fibre mass" should convert the bound $(n+1)^{2k}$ into a sharp $\Theta(n^{k/2})$, with matching constants. The numerics are unambiguous: for the memoryless class $S_n \approx \sqrt{\pi n / 2}$, and for two states $S_n \approx n$. Half a logarithm per parameter, exactly as folklore insists — and the counting mechanism, once refined, ought to deliver it with nothing more than a Stirling estimate for the central binomial coefficient.
