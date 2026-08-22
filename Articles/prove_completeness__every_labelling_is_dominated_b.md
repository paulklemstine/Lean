# The Greedy Algorithm That Isn't: Why Dynamic Programming Never Misses

## A promise you make a million times a day

Every time your phone turns a mumbled sentence into text, every time a navigation app quotes you a driving time, every time a spell-checker guesses that "teh" was meant to be "the", the same silent promise is being made:

> *Out of the astronomically many possibilities, this one is the best.*

The number of possibilities really is astronomical. Suppose you are decoding a sequence of $n+1$ sounds, and each sound could be any of $|S|$ phonemes. Then there are $|S|^{n+1}$ candidate transcriptions. With a modest $|S| = 40$ phonemes and a two-second utterance chopped into $20$ frames, that is $40^{20} \approx 10^{32}$ candidates — more than the number of atoms in a human body. No machine will ever look at them all.

And yet the machine answers in milliseconds, and it answers *correctly* — not approximately, not usually, but exactly. The technique that pulls off this trick is **dynamic programming**, invented by Richard Bellman in the 1950s and rediscovered in a dozen guises since: the Viterbi algorithm in communications, Bellman–Ford in routing, Needleman–Wunsch in genomics, the forward–backward algorithm in machine learning.

This article is about the theorem that makes the promise true. It is not the algorithm; the algorithm is a few lines of code that any undergraduate can write. It is the *guarantee*: a proof that the frighteningly cheap thing the algorithm does is exactly as good as the frighteningly expensive thing it refuses to do.

We call that guarantee **completeness**, and it has a memorable one-line statement:

> **Every labelling is dominated by some run of the dynamic program.**

## The setup, in plain terms

Picture a long corridor of rooms, one room per **stage** $0, 1, 2, \dots$. In each room stands the same finite cast of **states** $S$ — think of them as phonemes, or map intersections, or "this nucleotide was inserted / deleted / matched".

A **labelling** is a choice of one state in each room: a function $f$ that assigns to each stage $i$ a state $f(i)$. This is the "candidate transcription", the "route", the "alignment". There are $|S|^{n+1}$ of them up to stage $n$.

Every labelling earns a **score**. You get some points for where you start, and some points for each step you take:

- an initial weight $\mathrm{init}(s)$ for beginning in state $s$;
- a transition weight $\mathrm{step}_i(s,t)$ for moving from state $s$ at stage $i$ to state $t$ at stage $i+1$.

The score of a labelling truncated at stage $n$ is then defined by accumulation:
$$\mathrm{score}(f, 0) = \mathrm{init}(f(0)), \qquad \mathrm{score}(f, n+1) = \mathrm{score}(f, n) + \mathrm{step}_n\!\big(f(n), f(n+1)\big).$$

We call the pair (initial weights, transition weights) a **specification**. Our question is the obvious one: *what is the largest score any labelling can achieve, and which labelling achieves it?*

## Bellman's trick

Bellman's idea is disarmingly simple. Instead of asking about whole labellings, ask about *prefixes ending somewhere specific*. Define the **value function**
$$V(n, s) = \text{the best score of any labelling of stages } 0,\dots,n \text{ that ends in state } s.$$

Then there is a recursion that computes $V$ row by row:
$$V(0, s) = \mathrm{init}(s), \qquad V(n+1, t) = \max_{s \in S}\ \Big( V(n, s) + \mathrm{step}_n(s, t)\Big).$$

That's the whole algorithm. To fill in row $n+1$ you look only at row $n$. Filling in $n$ rows costs $O(n|S|^2)$ arithmetic operations — for our speech example, $20 \times 40^2 = 32{,}000$ additions instead of $10^{32}$.

The recursion is short enough to fit on a napkin, and that is exactly why it deserves suspicion. The definition of $V$ mentions *all* labellings. The recursion mentions *none*. Why should the two agree?

## Two halves of a promise

Any claim that an algorithm "solves" an optimisation problem splits into two independent halves, and it is worth insisting on the distinction, because they fail for different reasons and are proved by different arguments.

**Soundness** — *the algorithm doesn't lie.* Whatever number $V(n,s)$ the recursion prints, there really is a labelling achieving it. Soundness fails when an algorithm is over-optimistic: it reports a route of $12$ minutes that no actual sequence of roads realises.

**Completeness** — *the algorithm doesn't miss.* No labelling anywhere beats what the algorithm found. Completeness fails when an algorithm is myopic: it finds a perfectly real route of $14$ minutes and never notices the $12$-minute one round the corner. This is exactly the failure mode of greedy algorithms, which take the best-looking step at each moment and can be lured into a dead end.

Soundness alone is worthless (an algorithm that always returns "score $0$, do nothing" is sound). Completeness alone is worthless (an algorithm that always returns "score $=\infty$" is complete). You need both, and together they say the value function is *exact*.

## Domination: the algorithm doesn't miss

The completeness half turns out to have a beautifully short proof by induction. Here it is in full.

> **Domination Theorem.** For every labelling $f$ and every stage $n$,
> $$\mathrm{score}(f, n) \le V\big(n, f(n)\big).$$

*Proof.* At stage $0$ the two sides are equal by definition: $\mathrm{score}(f,0) = \mathrm{init}(f(0)) = V(0, f(0))$.

Now suppose the inequality holds at stage $n$. The recursion takes a maximum over all predecessor states, so in particular it beats the one predecessor the labelling $f$ actually used:
$$V(n, s) + \mathrm{step}_n(s,t) \le V(n+1, t) \quad \text{for every } s, t.$$
Combine this with the inductive hypothesis, using only the fact that adding a fixed quantity preserves the order:
$$\mathrm{score}(f, n+1) = \mathrm{score}(f,n) + \mathrm{step}_n(f(n), f(n{+}1)) \le V(n, f(n)) + \mathrm{step}_n(f(n), f(n{+}1)) \le V(n+1, f(n{+}1)).$$
$\square$

Two lines, and a $10^{32}$-fold search has been dispatched. Note what the proof *used*: only that a maximum dominates each of its arguments, and that $x \le y$ implies $x + c \le y + c$. It never used subtraction, never used real numbers, never used positivity of weights.

## Realisability: the algorithm doesn't lie

The other half is a construction rather than an estimate. To show that $V(n,s)$ is actually achieved, we build the optimal labelling by **backtracing**: run the recursion forward to fill the table, then walk backwards, at each stage picking a predecessor state $s$ that attained the maximum defining $V(n+1,t)$.

> **Realisability Theorem.** For every stage $n$ and every state $s$ there is a labelling $f$ with $f(n) = s$ whose score at stage $n$ equals $V(n,s)$ exactly. Moreover $f$ can be chosen so that *every* prefix is optimal too: $\mathrm{score}(f,i) = V(i, f(i))$ for all $i \le n$.

*Proof sketch.* Induct on $n$. At stage $0$, the constant labelling at $s$ works. For $n+1$ and a target state $t$: since $S$ is finite and non-empty, the maximum defining $V(n+1,t)$ is attained at some concrete state $s$. By induction there is an optimal labelling $f$ ending at $s$ at stage $n$; splice $t$ onto its end. The spliced labelling's score at stage $n+1$ is $V(n,s) + \mathrm{step}_n(s,t)$, which is $V(n+1,t)$ by the choice of $s$. $\square$

Put the two theorems together and you get the sharp statement.

> **Exactness.** $V(n,s)$ is the *greatest element* of the set of scores of labellings ending at $s$ — not merely an upper bound, but an attained one.

And the headline result of this work:

> **Completeness Theorem.** For every labelling $f$ and every horizon $n$ there is a run $g$ of the dynamic program with $\mathrm{score}(f,n) \le \mathrm{score}(g,n)$.
>
> **Uniform Completeness.** In fact one single run $g$ works for *all* $f$ simultaneously: the run ending at the state maximising $V(n,\cdot)$ dominates every labelling whatsoever.

## The subtle theorem: optimality is hereditary

There is a third result, and it is the one with real content. Call a labelling a **run** of the dynamic program if all of its prefixes are optimal — that is, $\mathrm{score}(f,i) = V(i, f(i))$ for every $i \le n$. That is the *process* definition: it is what backtracing produces.

Now suppose you are handed a labelling that is merely optimal *at the end*: $\mathrm{score}(f,n) = V(n, f(n))$, with no promise at all about its prefixes. Might it have been sloppy early on and then made up the difference with an unusually lucrative final step?

> **Bellman's Optimality Principle.** No. If a labelling is optimal at its endpoint, then every one of its prefixes is optimal at its own endpoint. Being end-optimal and being a run are the same thing.

*Proof.* Suppose the prefix were strictly suboptimal, $\mathrm{score}(f,n) < V(n, f(n))$. Adding the same final step $c = \mathrm{step}_n(f(n), f(n{+}1))$ to both sides *strictly* preserves the inequality:
$$\mathrm{score}(f,n) + c < V(n, f(n)) + c \le V(n+1, f(n{+}1)),$$
so $\mathrm{score}(f, n+1) < V(n+1, f(n{+}1))$, contradicting end-optimality. Induct downwards. $\square$

The interesting word in that proof is *strictly*. To pass from $x < y$ to $x + c < y + c$ you need the weights to be **cancellative**: adding $c$ must not collapse distinct values together. Real numbers, integers, and rationals are cancellative. Some very useful weight systems are not — and that is not a technicality, as we will see in a moment.

The optimality principle upgrades the whole picture into a clean characterisation:

> **Characterisation of Runs.** A labelling is a run of the dynamic program if and only if it is optimal among all labellings with the same endpoint.

One side of this is the *syntactic* notion (produced by the recursion, step by step) and the other is the *semantic* notion (nothing beats it). Their coincidence is precisely what it means for the algorithm to be right.

## How general is "weight"?

Here is where the story becomes more than a proof of a familiar fact. Notice that nowhere above did a real number appear. What the arguments actually used is:

1. weights can be added, and addition is associative and commutative;
2. weights are linearly ordered;
3. adding a constant preserves the order.

Any structure with those three properties — a linearly ordered commutative monoid — works. And the specialisations are startlingly diverse:

- **Max-plus (longest path).** Real weights, $\max$ for the optimisation. This is the version stated above.
- **Min-plus (shortest path).** Take exactly the same theorems but read the order *upside down*. Maximum becomes minimum, "dominated by" becomes "dominates", and out falls the Bellman–Ford shortest-path theorem, with no new proof required. This kind of free lunch — a theorem and its mirror image from one argument — is the payoff for stating things over an abstract order.
- **Viterbi decoding.** Probabilities under multiplication become log-probabilities under addition; the optimal *path* through a hidden Markov model is a max-plus optimum.
- **Constrained problems.** Here is the interesting one. Adjoin a bottom element $\bot$ meaning "forbidden", with $\bot + w = \bot$ and $\bot$ below everything. Now infeasible transitions can be given weight $\bot$ and the algorithm automatically routes around them. But $\bot$ destroys cancellativity: $\bot + 1 = \bot + 2$ while $1 \ne 2$. The optimality-principle proof above breaks.

## Rescuing the non-cancellative case

The fix is to stop defining a "run" semantically and define it structurally instead. Call a labelling a **backtrace** if at every stage the recursion is realised on the nose:
$$V\big(i, f(i)\big) + \mathrm{step}_i\big(f(i), f(i+1)\big) = V\big(i+1, f(i+1)\big) \qquad \text{for all } i < n.$$

This is *literally what the backtracing loop checks*, and it makes no reference to strict inequalities.

> **Equivalence Theorem.** Over *any* ordered weight monoid — cancellative or not — a labelling is a backtrace if and only if it is a run (all prefixes optimal).
>
> **General Completeness.** Consequently, over any ordered weight monoid, every labelling is dominated by some backtrace, and the value function is still exactly the greatest achievable score.

So the cancellativity hypothesis, which looked essential, was an artefact of the definition. Once runs are defined the way the *program* defines them, it evaporates.

The reward is an immediate treatment of constrained optimisation, including a clean criterion for infeasibility:

> **Infeasibility Criterion.** $V(n,s) = \bot$ if and only if *every* labelling ending at $s$ scores $\bot$ — that is, uses a forbidden ingredient somewhere.

This is completeness in contrapositive dress: the algorithm reporting "impossible" is a *proof* of impossibility, not merely a failure to find something. Anyone who has debugged a constraint solver knows how much comfort that provides.

**A worked example.** Take the maximum-weight independent set problem on a path of five vertices with weights $3, 7, 2, 8, 1$: choose a set of vertices, no two adjacent, of maximum total weight. Model stage $i$ as vertex $i$ and the state as the Boolean "is vertex $i$ selected?". Give the transition from *selected* to *selected* the weight $\bot$, and every other transition the weight of the newly selected vertex (or $0$). The dynamic program returns $15$, realised by the vertex set $\{1, 3\}$ of weights $7$ and $8$. It never enumerates the $2^5$ subsets, and it never needs to be told that adjacency is forbidden in any way other than through the arithmetic of $\bot$.

## Splitting the path: forward meets backward

One more structural result deserves a mention, because it powers a whole family of algorithms. Alongside the forward value $V(k,s)$ ("the best way to *get to* $s$ at stage $k$") define the backward value $B(k,m,s)$ ("the best total weight of $m$ further transitions *starting from* $s$ at stage $k$"), by the mirror-image recursion $B(k,0,s) = 0$ and
$$B(k, m+1, s) = \max_{t\in S}\Big(\mathrm{step}_k(s,t) + B(k+1, m, t)\Big).$$

> **Forward–Backward Decomposition.** For all $k$ and $m$,
> $$\max_{s \in S} V(k+m, s) = \max_{s \in S}\ \Big( V(k, s) + B(k, m, s)\Big).$$

In words: you may cut an optimal path at *any* intermediate stage $k$, and the global optimum is the best over all states of (best way in) $+$ (best way out). This is the identity behind posterior decoding, behind sensitivity analysis ("how much would the optimum change if I forced state $s$ at time $k$?"), and behind the parallel "meet in the middle" implementations of these algorithms.

Its proof is a short but pleasant exercise in exchanging two maxima — the identity $\max_s \max_t = \max_t \max_s$, combined with the distributive law $\big(\max_s a_s\big) + c = \max_s (a_s + c)$, which is exactly the third of our three axioms in disguise.

That distributive law is a hint at deeper structure. If you write $\oplus$ for $\max$ and $\otimes$ for $+$, then $(\oplus, \otimes)$ satisfies all the axioms of a semiring — the **tropical** or max-plus semiring. In that language, the value function is a vector, the transition weights form a matrix, and the recursion is nothing but matrix–vector multiplication. Composing segments of a path becomes matrix multiplication, and the associativity of that multiplication is a tropical Chapman–Kolmogorov identity:
$$W_{k}^{(m_1+m_2+1)}(s,u) = \max_{t \in S}\Big( W_k^{(m_1)}(s,t) + W_{k+m_1+1}^{(m_2)}(t,u) \Big),$$
where $W_k^{(m)}(s,t)$ denotes the optimal weight of $m+1$ consecutive transitions from $s$ at stage $k$ to $t$. Dynamic programming, seen from this height, is linear algebra over a strange but perfectly respectable arithmetic.

## Does it survive contact with reality?

Real weight tables are estimated from data and are therefore wrong. Does exactness matter if the numbers are noisy? Yes, and quantifiably so.

> **Lipschitz Stability.** If two specifications differ by at most $a$ in every initial weight and at most $b$ in every transition weight, then their value functions differ by at most $a + nb$ at horizon $n$.
>
> **Near-Optimality Transfer.** Consequently, a run computed for the perturbed model is within $2(a + nb)$ of the true optimum for the true model.

The proof is again a soft one: a uniform shift of the data shifts the value function by exactly $a + nb$ — the optimum is *equivariant* under adding constants — and monotonicity in the specification does the rest. The error accumulates linearly in the horizon, not exponentially. That is the difference between a method one can deploy and one that is a laboratory curiosity.

## What has actually been shown

Strip away the generality and the moral is this. Dynamic programming looks like a heuristic: it commits to a choice at each stage without looking ahead, which is exactly the sin that makes greedy algorithms fail. It survives because it commits to a choice *for every possible future*, keeping one candidate per state rather than one candidate overall. That is the entire content of the value function, and completeness is the theorem that says the bookkeeping is enough.

Stated once and proved abstractly, the theorem covers longest paths and shortest paths, probabilistic decoding and constrained combinatorial optimisation, exact arithmetic and noisy estimates. The hypotheses that survive the stripping — *add, order, and monotonicity of addition* — are the minimal price of the promise your phone makes a million times a day.

And the hypothesis that did *not* survive is the most interesting part of the story. Cancellativity looked indispensable; it turned out to be an artefact of asking the wrong question. Ask what a run *is* rather than what a run *achieves*, and the requirement disappears — taking with it the last obstacle between the abstract theorem and the constrained problems that practitioners actually solve.
