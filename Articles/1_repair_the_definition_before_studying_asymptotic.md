# The Rule That Refuses to Add Up

## How a small repair turns a collapsed sequence into a living mathematical object

A number sequence is a machine built from words. Change one word, and the machine may produce a completely different landscape. Leave one condition vague, and it may not run at all.

Consider the familiar game of building an integer sequence one term at a time. We begin at $1$. At every stage we want the next number to avoid additive coincidences with the past. The attractive intuition is simple: choose the smallest new number that cannot be made by adding two numbers already seen. Such rules belong to the world of greedy mathematics, where each move is the least move currently allowed. Greedy constructions appear in scheduling, data compression, network design, coding theory, and additive combinatorics. Their local decisions can create unexpectedly rigid global patterns.

But there is a trap. An informal rule that excludes only one specially selected sum does not necessarily express global additive avoidance. It may merely forbid a single integer at each step. Worse, a rule that does not explicitly require growth can repeatedly choose $1$, collapsing the intended construction into a constant sequence. Before asking how fast a sequence grows, one must first make sure the definition actually defines the sequence one has in mind.

The repaired rule studied here makes every quantifier explicit.

Start with $a_0=1$. Suppose $a_0,a_1,\ldots,a_n$ have been chosen. Form the **prior pair-sum set**

$$
P_n=\{a_i+a_j:0\le i\le n,\ 0\le j\le n\}.
$$

The same index may be used twice, so $2a_i=a_i+a_i$ is included. A positive integer $z$ is **admissible after time $n$** if

$$
a_n<z \qquad\text{and}\qquad z\notin P_n.
$$

The next term $a_{n+1}$ is the least admissible integer. Thus the sequence must move forward, and every sum of two values seen so far is forbidden.

This modest repair transforms the problem. The first question is no longer a speculative asymptotic question. It is more basic: does an admissible next term always exist?

## The escape hatch at $2a_n+1$

Assume the finite history is nondecreasing, so every earlier value is at most $a_n$. Then every prior pair sum is bounded by

$$
a_i+a_j\le 2a_n.
$$

The number $2a_n+1$ lies just beyond this entire forbidden region. It is larger than $a_n$, and it cannot equal any prior pair sum. Therefore it is admissible.

This gives the **Successor Existence Theorem**: for every finite nondecreasing history, a least admissible successor exists, and that successor is at most $2a_n+1$.

The proof has two layers. First, $2a_n+1$ is an explicit witness, so the admissible set is nonempty. Second, every nonempty set of natural numbers has a least element. The greedy choice therefore exists. Since it is no larger than any admissible candidate, it is no larger than the witness $2a_n+1$.

The argument is elementary, but its role is fundamental. A recursive prescription is meaningful only if every stage can be completed. The witness $2a_n+1$ is an escape hatch that remains available no matter how complicated the earlier sumset becomes.

## Four consequences of the repaired rule

The repaired construction immediately supports four clean conclusions.

First comes the **Strict Growth Theorem**: every trajectory obeying the repaired rule is strictly increasing. Indeed, admissibility itself requires $a_n<a_{n+1}$ at every step. Chaining these inequalities gives $a_i<a_j$ whenever $i<j$.

Second is the **Chronological Additive-Avoidance Theorem**. If $i<k$ and $j<k$, then

$$
a_i+a_j\ne a_k.
$$

To see why, write $k=n+1$. When $a_k$ was selected, both $a_i$ and $a_j$ already belonged to the history, so their sum lay in $P_n$. The selection rule expressly excluded that sum. Repeated summands are allowed: the theorem also forbids $2a_i=a_k$ whenever $i<k$.

The word “chronological” matters. The claim compares a later value with sums of values available before it was chosen. It does not say that no equation $a_i+a_j=a_k$ can ever be written with the alleged sum appearing earlier than one of its summands. Because the sequence is positive and increasing, many such reversed configurations are automatically impossible, but chronology is the exact content supplied by the rule.

Third is the **One-Step Growth-Ceiling Theorem**:

$$
a_{n+1}\le 2a_n+1
$$

for every $n$. Strict growth tells us that all earlier values are at most $a_n$. The escape-hatch argument makes $2a_n+1$ admissible. Greedy minimality then says that the chosen successor can be no larger. This bound does not identify the exact sequence, but it prevents a single step from exploding without limit.

Fourth is a bridge to extremal combinatorics. Among the first $N$ indices, call an ordered triple $(i,j,k)$ a **chronological additive triple** if

$$
i<k,\qquad j<k,\qquad a_i+a_j=a_k.
$$

Think of the indices as vertices of a directed three-uniform hypergraph and these triples as hyperedges. The **Empty Additive Hypergraph Theorem** says that this hypergraph has no edges for any $N$. This is simply the additive-avoidance theorem viewed through a different lens, yet the translation is useful. It converts a statement about values into an extremal statement about a combinatorial structure.

## A prefix that cannot belong

A proposed pattern can look persuasive while violating the rule at the earliest possible moment. Consider the displayed list

$$
1,1,2,4,7,11,\ldots,
$$

whose terms follow the triangular-number expression

$$
1+\frac{n(n-1)}2
$$

when indexing begins at $n=0$. This list cannot satisfy the repaired rule.

There are two immediate obstructions. The strict-growth requirement already rules out the repeated initial values $1,1$. Moreover, once two initial ones are present, the next displayed value $2$ equals $1+1$, exactly the kind of prior pair sum the repaired rule forbids. This yields the **Prefix Incompatibility Theorem**: the displayed triangular list is not a trajectory of the globally additive-avoiding greedy rule.

This is not a technical nuisance. It is a diagnostic result. It tells us that three appealing ingredients—the displayed prefix, strict forward motion, and avoidance of every earlier pair sum—cannot all describe the same object. One must decide which mathematical idea is intended before discussing density or asymptotic coefficients.

## Running the greedy machine

The rule is easy to simulate. Given the current finite list, compute all pair sums, begin testing integers immediately above the last term, and stop at the first candidate absent from the forbidden set.

Starting from $1$, the forbidden sum is $2$, so the least admissible successor is $3$. With history $1,3$, the pair sums are $2,4,6$, so the least candidate above $3$ that avoids them is $5$. Continuing gives

$$
1,3,5,7,9,11,\ldots
$$

in every finite experiment. This strongly suggests the exact formula $a_n=2n+1$. The present results do not promote that observation to a theorem; they deliberately establish only what follows from the general existence and avoidance arguments. Still, the experiment points toward a short parity induction: sums of two odd values are even, while the even number immediately above the current odd value is forbidden because it equals $1+a_n$. The next odd number is then the least admissible candidate. That exact classification is a natural next theorem.

A direct implementation using a set of pair sums takes quadratic work in the number of generated terms if the sumset is maintained incrementally: adding a new term creates only linearly many new sums. A simpler implementation that rebuilds all sums at every stage costs cubic time overall. The mathematics therefore offers both a theorem and a practical design lesson: store the evolving obstruction set rather than recomputing history from scratch.

## Why this miniature problem matters

Global additive avoidance is a tiny model of a broad phenomenon: local prohibitions shaping global structure. In communication systems, one chooses codewords to avoid confusable combinations. In sparse sensing, one designs sets with controlled additive collisions. In scheduling, a greedy algorithm repeatedly takes the earliest feasible option while respecting all previous constraints. In graph theory, forbidden arithmetic relations become forbidden edges or hyperedges.

The sequence also illustrates the difference between local and global exclusion. Forbidding one current sum is weak; forbidding the whole restricted sumset $P_n$ is strong. The latter grows with the history and remembers every pairwise interaction. Yet the construction never gets trapped, because monotonicity compresses all those interactions beneath one numerical ceiling, $2a_n$.

There is also a lesson about density. Before asking for “the density of the complement,” one must specify the universe and the set being complemented. Is it the complement of the sequence values among positive integers? Or the complement of the prior pair-sum set? These are distinct objects. The first measures how frequently selected values occur; the second measures how much of the number line remains locally admissible. A sentence that conflates them can hide an entirely different problem.

## The road ahead

Several directions now become concrete. The first is exact classification: prove or refute that the trajectory from $1$ is precisely the odd positive integers. The second changes the initial value and asks whether the sequence eventually enters an arithmetic progression. The third forbids sums of $r$ earlier terms rather than two, testing whether residue classes still organize the motion.

One can also soften greediness. If each chosen successor stays within a bounded distance of the least admissible one, must chronological additive triples remain sparse? The exact rule produces an empty additive hypergraph, the extremal endpoint of such a stability theory. Finally, one can investigate a density dichotomy governed by sum-free residue classes in finite cyclic groups, linking this elementary recurrence to structural additive combinatorics.

All of those questions depend on getting the starting object right. The central achievement here is therefore conceptual as much as numerical: define the candidate set, state every exclusion, require the intended direction of motion, and prove that the next step exists. Once those foundations are in place, the sequence stops being a verbal puzzle and becomes a robust mathematical machine—one that advances forever, never lands on an earlier pair sum, grows by at most a doubling plus one, and leaves behind an additive hypergraph with no edges at all.
