# The Anti-Fibonacci Mirage: What Happens When a Recurrence Avoids One Sum?

The Fibonacci sequence is a machine for turning addition into growth. Begin with two ones, add the latest pair, and the familiar procession appears: $1,1,2,3,5,8,\ldots$. Its neighboring ratios drift toward the golden ratio, $\varphi=(1+\sqrt5)/2$. That convergence has made Fibonacci growth a universal metaphor, appearing in accounts of branching plants, population models, algorithms, and spiraling patterns.

Now reverse the instruction. Instead of choosing the sum of the previous two terms, choose the *smallest positive integer that is not that sum*. This sounds like a recipe for a rebellious “anti-Fibonacci” sequence: a process that dodges the additive command at every step and perhaps develops a new kind of growth.

A proposed example was

$$
1,1,2,4,7,11,16,22,29,\ldots,
$$

accompanied by an alluring story: quadratic growth near $n^2/4$, ratios oscillating between $1$ and $2$, and an additive complement of density zero. But the smallest word in the rule—“smallest”—changes everything. The literal process does not produce that list. In fact, it does not grow at all.

This is not merely a technical correction. It is a lesson about greedy definitions, the difference between avoiding one forbidden value and avoiding a growing forbidden set, and the value of checking the first logical consequence of a rule before studying its asymptotics.

## The trap hidden in “smallest”

Suppose the two previous terms are positive integers $x$ and $y$. Their sum satisfies

$$
x+y\ge 2.
$$

The number $1$ is therefore positive and is certainly not equal to $x+y$. Since no positive integer is smaller than $1$, the smallest positive integer unequal to $x+y$ must be $1$.

That one-line observation settles the recurrence.

**Least-avoidance lemma.** If $x$ and $y$ are positive integers, then the least positive integer $z$ satisfying $z\ne x+y$ is $z=1$.

The proof is immediate: positivity gives $x+y\ge2$, so $1$ is admissible; minimality then forces $z\le1$, while positivity forces $z\ge1$.

Define a literal anti-Fibonacci trajectory to be a sequence $(A_n)_{n\ge0}$ with $A_0=A_1=1$ such that, for every $n\ge0$, the term $A_{n+2}$ is the least positive integer different from $A_n+A_{n+1}$. The lemma applies at every stage. Starting from positive terms, the next term is $1$, so positivity persists forever.

**Classification theorem.** There is exactly one literal anti-Fibonacci trajectory, namely

$$
A_n=1\qquad\text{for every }n\ge0.
$$

An induction proves the statement. The first two terms are $1$. If the relevant predecessors are positive—indeed, if they are both $1$—the least-avoidance lemma makes the next term $1$. Conversely, the constant-one sequence satisfies the rule because $1\ne1+1$ and $1$ is the smallest positive integer.

The proposed ratio oscillation disappears as well. Every consecutive ratio is exactly

$$
\frac{A_{n+1}}{A_n}=\frac11=1.
$$

Even the basic number theory becomes degenerate but clean: every consecutive pair is coprime, since

$$
\gcd(A_{n+1},A_n)=\gcd(1,1)=1.
$$

The sequence avoids the golden ratio not by staging dramatic oscillations, but by refusing to leave home.

## Where the displayed numbers really come from

The list $1,1,2,4,7,11,16,\ldots$ is not random. Look at its successive increases:

$$
0,1,2,3,4,5,\ldots.
$$

Thus the displayed list follows a different and perfectly coherent recurrence. Define $(D_n)_{n\ge0}$ by

$$
D_0=1,\qquad D_{n+1}=D_n+n.
$$

This yields $D_1=1$, $D_2=2$, $D_3=4$, $D_4=7$, and so on. Summing the increments gives an exact triangular-number formula.

**Triangular growth theorem.** For every $n\ge0$,

$$
D_n=1+\frac{n(n-1)}2.
$$

Indeed, the total increase from $D_0$ to $D_n$ is $0+1+\cdots+(n-1)=n(n-1)/2$. Equivalently, one may use induction: adding $n$ to $1+n(n-1)/2$ produces $1+n(n+1)/2$, the formula at index $n+1$.

This identity explains every displayed value, including $D_6=16$ and $D_8=29$. It also identifies the true leading behavior:

$$
D_n=\frac12n^2-\frac12n+1.
$$

Consequently,

$$
\frac{D_n}{n^2}=\frac12-\frac{1}{2n}+\frac1{n^2}\longrightarrow\frac12
$$

as $n\to\infty$. The coefficient is $1/2$, not $1/4$.

## Why a bounded correction cannot rescue the quarter-square law

Perhaps the proposed estimate $D_n=\lfloor n^2/4\rfloor+O(1)$ could survive despite the wrong-looking coefficient? An exact even-index calculation rules this out decisively.

Let

$$
Q(n)=\left\lfloor\frac{n^2}{4}\right\rfloor.
$$

At an even index $n=2k$, there is no rounding ambiguity: $Q(2k)=k^2$. The triangular formula gives

$$
D_{2k}=1+\frac{(2k)(2k-1)}2=2k^2-k+1.
$$

Therefore

$$
D_{2k}=Q(2k)+k(k-1)+1.
$$

**Unbounded-discrepancy theorem.** For every nonnegative constant $C$, there exists an index $n$ such that

$$
Q(n)+C<D_n.
$$

To see this, choose $k$ large enough that $k(k-1)+1>C$ and set $n=2k$. The exact even-index identity gives the desired inequality. Thus no fixed error band can turn the quarter-square model into a valid description of the displayed sequence. The gap itself grows quadratically.

This matters because asymptotic notation can sometimes hide substantial local errors, but it cannot hide the wrong leading coefficient. A term of size $n^2/2$ cannot remain within a bounded distance of one of size $n^2/4$.

## A greedy-algorithm lesson

The central distinction is between avoiding a *singleton* and avoiding a *set that grows*. At each stage of the literal rule, exactly one integer is forbidden: the current sum $A_n+A_{n+1}$. But that sum is at least $2$, leaving the smallest candidate, $1$, untouched. The magnitude of the forbidden number is irrelevant. What controls a least-excluded process is whether the forbidden set covers the small candidates.

This principle appears throughout discrete mathematics and computer science. A greedy scheduler chooses the first available time slot; a graph-coloring routine chooses the least color absent from a neighborhood; a memory allocator chooses the first free block. Forcing such an algorithm upward requires blocking an initial segment of its choices. Excluding one distant option usually has no effect at all.

A genuinely nontrivial anti-additive sequence should therefore forbid many values. One natural redesign is to choose the least positive integer that is not representable as a sum of two distinct earlier selected terms. As the history grows, so does the forbidden sumset. Another version could additionally require new terms to be unused, preventing a constant trajectory. These changes do not merely patch the original rule; they create new mathematical objects whose growth depends on additive structure and the rate at which small integers become forbidden.

The number of forbidden candidates is likely to be more important than their size. If only a bounded number of values are excluded at each step, some small admissible number may repeatedly survive. If a linearly growing family of combinations is excluded, the least admissible value can migrate. That is where questions about density, polynomial growth, and ratio behavior become meaningful.

## Reading a sequence before naming it

There is a broader art to diagnosing a numerical pattern. A short list rarely determines its own law. The values $1,1,2,4,7,11,16$ can be continued in infinitely many ways, so the name attached to them cannot substitute for a definition. Two quick tests are especially revealing.

First, substitute the initial values into the claimed recurrence. With predecessors $1$ and $1$, the forbidden sum is $2$. The least positive integer other than $2$ is $1$, so the claimed next value $2$ fails immediately. This local check is stronger than calculating a million terms from an unrelated generator: it tests whether the generator and definition agree.

Second, inspect finite differences. The displayed values have first differences $0,1,2,3,4,5$, whose differences are constantly $1$. Constant second differences signal a quadratic polynomial, just as constant first differences signal a linear one. This observation points directly to triangular numbers and the coefficient $1/2$.

These tests serve different purposes. Substitution validates a recurrence; differences identify algebraic structure in data. Together they prevent an attractive narrative from outrunning its mathematical object.

The same discipline matters in applications. A scheduling policy described as “choose the first free slot except one prohibited slot” may repeatedly choose the opening slot, even if simulations were built around steadily increasing times. A security protocol, allocation rule, or biological model can likewise behave very differently when “exclude this value” is confused with “exclude all values generated so far.” Boundary cases are not distractions: they often determine the system.

## The counterpoint to Fibonacci, correctly understood

The literal rule was advertised as an opposite of Fibonacci growth. It is an opposite, but not in the anticipated way. Fibonacci repeatedly selects one special sum, and that repeated selection creates exponential structure. The anti-rule rejects only that single sum, but then greedily selects the smallest remaining positive integer. Since $1$ is always available, the process collapses to a fixed point.

Meanwhile, the attractive list $1,1,2,4,7,11,16,\ldots$ has its own identity: it is one plus the sequence of triangular numbers. Its quadratic growth is exact, elementary, and governed by coefficient $1/2$. It neither implements the literal avoidance rule nor shadows $n^2/4$ within bounded error.

The episode offers a productive kind of mathematical failure. A conjecture can be false for a deep reason, or it can be false because its definition quietly says something else. Here the boundary case $1$ exposes the issue immediately. Once that is recognized, two clean theories emerge: a completely classified singleton-avoidance process and an exact triangular increment model.

The next challenge is not to force the original predictions onto either one. It is to formulate an avoidance rule rich enough to support them. Such a redesign could connect greedy algorithms with additive combinatorics: how quickly do earlier pair-sums cover the small integers, how sparse can the selected values become, and what growth laws survive changes in the starting data? Those are genuine open directions because the forbidden landscape expands with the history.

The moral is simple enough to carry beyond this example. Before asking how fast a recursively defined object grows, determine what its rule actually permits at the smallest scale. To make a greedy sequence climb, one must obstruct more than a single rung.