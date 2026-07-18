# The Anti-Fibonacci Paradox: How an Exclusion Rule Collapses to One

## A sequence that refuses to begin

The Fibonacci sequence grows from one of mathematics’ most famous local rules: add the two previous terms. Starting with $1,1$, it continues $2,3,5,8,\ldots$. Its neighboring-term ratios settle toward the golden ratio, and its simple recurrence reappears in subjects ranging from population models to computer algorithms.

What happens if we reverse the instruction? Consider the proposed “anti-Fibonacci” rule:

> Start with $A_0=A_1=1$. For each later index, choose the smallest positive integer that is not equal to the sum of the two preceding terms.

At first glance, the word “not” seems to promise a dramatically different sequence—perhaps a greedy escape from Fibonacci growth. One might expect a list such as $1,1,2,4,7,11,16,\ldots$, with each term carefully dodging an additive constraint. Claims of quadratic growth and unusual ratio oscillation might then seem plausible.

But there is a trap hidden in plain language. At each step, the rule forbids only one number: the sum of the previous two terms. Almost every positive integer remains legal. In particular, the smallest positive integer, $1$, remains legal unless the forbidden sum itself is $1$.

That observation settles the entire recurrence.

## The one-number exclusion principle

For nonnegative integers $x$ and $y$, define $L(x,y)$ to be the least positive integer different from $x+y$. There are only two cases:

$$
L(x,y)=
\begin{cases}
2,&x+y=1,\\
1,&x+y\ne 1.
\end{cases}
$$

Why? If $x+y\ne1$, then $1$ is positive, is not forbidden, and is automatically the least legal choice. If $x+y=1$, then $1$ is forbidden and $2$ is the next positive integer. This is not an approximation or a heuristic. It is the exact closed form of the greedy choice.

This tiny lemma is the key to the paradox. Feed it the proposed initial values. Since $A_0+A_1=2$, the forbidden number at the first recurrence step is $2$. The least positive integer different from $2$ is not $2$; it is $1$. Thus $A_2=1$. The same calculation repeats forever: whenever the two preceding values are both $1$, their sum is $2$, so the next value is again $1$.

We therefore obtain the central result.

**Constant-Sequence Theorem.** If $A_0=A_1=1$ and

$$
A_{n+2}=\min\{m\in\mathbb Z_{>0}:m\ne A_{n+1}+A_n\},
$$

then $A_n=1$ for every nonnegative integer $n$.

The proof is a two-step induction. The two base cases are given. If two consecutive terms equal $1$, then their sum is $2$, and the least positive integer unequal to $2$ is $1$. Hence the next term is also $1$.

The proposed sequence does not grow slowly. It does not grow at all.

## Why the advertised prefix cannot arise

The displayed list $1,1,2,4,7,11,16,\ldots$ already conflicts with the literal rule at its third entry. After $1,1$, the single forbidden value is $2$, yet the list chooses exactly $2$. At the following step, even if one accepted that choice, the previous sum would be $3$, while the list chooses $4$ despite $1$ being legal and smaller.

There is another revealing pattern. The displayed values satisfy

$$
1,1,2,4,7,11,16,\ldots
$$

with successive differences

$$
0,1,2,3,4,5,\ldots.
$$

For the shown indices this gives

$$
1+\frac{n(n-1)}{2},
$$

which has leading quadratic coefficient $1/2$, not $1/4$. Thus the prefix, the verbal recurrence, and the proposed asymptotic law point in three different directions. Before asking how fast such an object grows, one must first decide which object is intended.

This is a broadly useful lesson in mathematical modeling. Words such as “avoid,” “new,” and “greedy” often conceal the real state space. Avoid what—one number, all earlier sums, or every value used before? Choose the least candidate among all positive integers, among unused integers, or among integers larger than the previous term? Each interpretation creates a different problem.

## The asymptotic reversal

For the literal sequence, quadratic normalization is immediate. Since $A_n=1$,

$$
\frac{A_n}{n^2}=\frac{1}{n^2}
$$

for every positive $n$. Consequently,

$$
\lim_{n\to\infty}\frac{A_n}{n^2}=0.
$$

The proposed limit $1/4$ is therefore impossible. A sequence cannot converge to two distinct real numbers, and $0\ne1/4$.

The millionth-index computation dramatizes the scale of the discrepancy. At $n=1{,}000{,}000$,

$$
\frac{A_{1{,}000{,}000}}{(1{,}000{,}000)^2}
=\frac{1}{1{,}000{,}000{,}000{,}000}.
$$

That is $10^{-12}$, already extremely close to zero and nowhere near $0.25$.

Neighboring-term ratios are equally uncomplicated. Because every term is positive and equal to $1$,

$$
\frac{A_{n+1}}{A_n}=1
$$

for every $n$. The ratio neither approaches the golden ratio nor oscillates between $1$ and $2$; it is identically $1$.

## A graph hidden inside the collapse

Even a collapsed recurrence can expose an interesting structural bridge. Take the first $n$ time indices as vertices. Connect two distinct indices whenever the values at those times sum to $2$.

Because every value is $1$, every pair of distinct vertices qualifies:

$$
A_i+A_j=1+1=2.
$$

The resulting graph is the complete graph on $n$ vertices. It has exactly

$$
\binom n2=\frac{n(n-1)}2
$$

edges, the largest possible edge count for a simple graph on $n$ vertices.

**Complete-Graph Theorem.** For the sequence generated by the literal exclusion rule, the graph joining distinct indices $i$ and $j$ when $A_i+A_j=2$ is complete. Its edge count is $\binom n2$ on the first $n$ indices.

The proof is one line once the constant-sequence theorem is known: every pair has values $1$ and $1$. This connector is more than decorative. It illustrates a recurring mathematical strategy: turn an additive relation among numbers into adjacency in a graph. For more substantial greedy sequences, graph density, cliques, and forbidden subgraphs can reveal additive structure that is hard to see directly.

Here the additive relation is maximally dense. Every possible edge appears. If a repaired anti-Fibonacci rule produced a genuinely varying sequence, the same graph construction could measure how frequently a target sum occurs.

## What a genuine anti-Fibonacci problem might be

The failure is not in the desire to build an additive-avoidance sequence. The failure is in asking one forbidden value to do more work than it can.

A richer definition could require each new term to be unused and larger than the previous term. It could also forbid the new term from belonging to the set of sums of two earlier values. One possible template is:

$$
B_{n+1}=\min\{m>B_n:m\notin\{B_i+B_j:0\le i,j\le n\}\}.
$$

This is only an example, not a claim that it reproduces the displayed prefix. It makes explicit three ingredients absent from the original wording: the candidate must move forward, all earlier pairwise sums matter, and the forbidden set changes globally rather than containing a single number.

Once a corrected rule is fixed, meaningful questions emerge. Does the sequence exist indefinitely? Is it strictly increasing? What fraction of positive integers does it occupy? How large is the restricted sumset? Does a quadratic normalization converge? Can an associated graph have controlled edge density or forbidden cliques?

The phrase “the complement” would also need clarification. It might mean positive integers not appearing as sequence values, or it might mean integers outside a set of earlier-term sums. Those are different universes, with potentially different densities.

## A five-second test before a million-step experiment

The proposal included a natural computational challenge: generate a million terms and watch the quotient $A_n/n^2$. Such experiments are often excellent guides. Here, however, a semantic check outruns the computer. Ask only what happens after the initial pair. The sum is $2$, so the rule demands the least positive integer other than $2$. That number is $1$. One more step produces exactly the same state, and the future is settled.

This “small-state test” is useful far beyond integer sequences. Before simulating a model, inspect its boundary cases, fixed points, and smallest admissible choices. Greedy systems are especially sensitive because minimization amplifies tiny omissions in a definition. If reuse is permitted, the smallest object may be selected forever. If only one obstacle is removed from an infinite candidate set, the obstacle may have almost no effect.

Computation still has an illuminating role. A short program can implement both the literal recurrence and the closed form, compare them over any requested range, print normalized values, and construct the associated graph. The output makes the theorem visible: every row contains $1$, normalized values decay like $1/n^2$, and an $n$-vertex sum-to-two graph contains all $\binom n2$ possible edges. The experiment is no longer being asked to discover the law; it becomes a transparent demonstration of an exact argument.

## The deeper moral

Mathematical definitions are small programs written in ordinary language. A single quantifier can change their behavior completely. “Not equal to the previous sum” excludes one value. “Not equal to any sum of two earlier terms” excludes a whole evolving set. “Least positive integer” repeatedly pulls the construction back toward $1$ unless additional conditions prevent reuse.

The anti-Fibonacci proposal is therefore valuable precisely because it fails so cleanly. Its apparent complexity evaporates into a two-case minimum. The resulting theorems are exact: the sequence is constant, its quadratic normalization tends to zero, its millionth normalized value is $10^{-12}$, and its sum-to-two graph is complete with $\binom n2$ edges.

Before searching for the golden ratio’s opposite, one must first specify the rules of escape. In this case, the number $1$ does not merely win the race. It is allowed to return to the starting line forever.
