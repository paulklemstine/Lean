# The Knob That Only an Oracle Can Turn

*Why the best setting for a factoring algorithm really does change from number to number — and why, for all practical purposes, that does not help.*

---

## A dial on the factoring machine

Imagine a machine that breaks large numbers into their prime factors. You feed in a number $N$ that is secretly the product of two primes of about the same size — a *balanced semiprime*, the kind of number that sits at the heart of RSA-style cryptography — and the machine grinds away until it hands you back $p$ and $q$ with $N = pq$.

The machine we are talking about is the **quadratic sieve**, for decades one of the fastest general-purpose factoring methods for numbers up to roughly a hundred digits. It has a dial on the front, labelled $B$, the **smoothness bound**. Turning the dial changes how the machine works, and therefore how long it takes.

The natural question every engineer asks of every dial is: *where should I set it?* And the natural follow-up, once you notice that the best setting seems to differ from job to job, is: *can I set it automatically, job by job, and save time?*

This article tells the story of an experiment that asked exactly that question — 1,800 real runs of the quadratic sieve on 120 different 41-bit semiprimes — and of the handful of clean mathematical facts that explain its answer. The answer is a crisp, slightly paradoxical **no**: the per-number optimum is genuinely real, but it is *oracle-only*. You can only find it by already knowing the result.

## How the sieve spends its time

To see what the dial does, we need a cartoon of the algorithm.

The quadratic sieve looks at values of the polynomial $f(x) = (x + \lceil\sqrt N\,\rceil)^2 - N$ for many consecutive integers $x$ in an interval $[0, M)$. It is hunting for values that are **$B$-smooth** — values whose prime factors are all at most $B$. Collect enough smooth values and a bit of linear algebra over the two-element field stitches them into a congruence of squares $X^2 \equiv Y^2 \pmod N$, from which a factor of $N$ falls out with good probability.

The primes that can ever divide $f(x)$ form the **factor base**. Here number theory immediately cuts the work in half: an odd prime $p$ can divide $f(x)$ only if $N$ is a *quadratic residue* modulo $p$, that is, only if $N$ has a square root mod $p$. Roughly half of all primes pass this test; we call them the **split primes** and write $Q$ for how many there are below $B$.

The "sieve" part is the clever trick. Rather than test each $f(x)$ for divisibility, you note that $p$ divides $f(x)$ precisely when $x$ lands in certain residue classes modulo $p$ — the **root classes**. For each root class you march through the interval in steps of $p$, touching every position it hits. Each such touch is one elementary operation. We call the total number of these operations the **paid touch**: it is the actual work the machine does.

### Fact one: every odd prime brings exactly two roots

How many root classes does a split prime have? The answer is a classical fact that we state precisely:

> **Two-roots lemma.** If $p$ is an odd prime and $a$ is a nonzero square modulo $p$, then the congruence $x^2 \equiv a \pmod p$ has exactly two solutions.

The reason is short. If $r^2 \equiv a$, then $(-r)^2 \equiv a$ too, and $r \not\equiv -r$ because that would force $2r \equiv 0$, impossible when $p$ is odd and $r \not\equiv 0$. Conversely, if $x^2 \equiv r^2$ then $p$ divides $(x - r)(x + r)$, and since $p$ is prime it divides one of the two factors. So the solutions are exactly $r$ and $-r$.

The prime $2$ is the odd one out: it contributes a single root class.

### Fact two: a root class touches about $M/p$ positions

A residue class $r \bmod p$ meets the interval $[0, M)$ in either $\lfloor M/p \rfloor$ or $\lfloor M/p \rfloor + 1$ positions — the latter exactly when $r < M \bmod p$. In particular

$$\left|\,\#\{x \in [0,M) : x \equiv r \!\!\pmod p\} - \frac{M}{p}\,\right| \le 1 .$$

### Putting them together: the price of a sieve, to the operation

Add up over the factor base $S$: two classes for each odd prime, one for the prime $2$, each class costing $M/p$ up to an error of one. The result is a closed form for the work, with a guaranteed error bar:

$$\left|\ \text{paid touch} \;-\; \Bigl(2M \sum_{p \in S,\ p \text{ odd}} \frac1p \;+\; \frac M2\Bigr)\right| \;\le\; 2|S| - 1 .$$

That error bar is tiny. In the experiment, $M = 150{,}000$ and the factor bases ranged from a couple of dozen to about a thousand primes; the formula matched the counted operations with a **maximum relative deviation of $2 \times 10^{-4}$**. The relative error shrinks like $|S|/M$, so the closed form is not a heuristic but a theorem with a quantified margin. This mattered: it certified that the experiment was pricing the *real* work of the sieve rather than a convenient proxy.

## The dial in action

Turning up $B$ has two competing effects. A larger factor base means more numbers count as smooth, so you need fewer sieve passes per useful relation. But it also means more columns in the final linear-algebra matrix, more relations you must collect, and more primes to march through the interval. Somewhere in between sits a sweet spot.

The experiment ran every one of 120 validated 41-bit balanced semiprimes at **fifteen** settings of the dial, a ladder of values from $B = 150$ up to $B = 19{,}000$, with the interval length $M$ held fixed. For each number it recorded the paid work at each $B$, and asked which $B$ was cheapest.

**The answer moved all over the place.** For some numbers the best setting was the very bottom of the ladder, $B^{*} = 150$; for others it was the very top, $B^{*} = 19{,}000$. The median was $4{,}800$. The best dial position is genuinely instance-dependent.

## The oracle's prize

Suppose a helpful oracle whispered, for each number, its personal best $B^{*}$. How much would you save compared with simply setting the dial once to the best single value? (On the training data that best single value was $B = 9{,}600$.)

The answer: the oracle's total work is **$0.9533$ times** that of the best fixed dial — a saving of about 4.7%, or $0.0478$ in natural-log units. The saving is extremely consistent: it beats the fixed dial on $102$ of $120$ numbers, ties on $18$, and **loses on none**, with a $t$-statistic of $-11.6$.

That "loses on none" is not luck; it is a logical necessity. Picking the minimum over a set of options can never do worse than picking any particular option. Mathematically:

> **Oracle dominance.** For every instance and every ladder value $b$, the oracle cost $\min_{b'} c(i, b')$ is at most $c(i, b)$.

And there is a sharp converse: the oracle gains *nothing* over a fixed value $b$ exactly when $b$ is optimal for every single instance at once. So a strict improvement on even one of the 120 numbers — let alone 102 — is mathematical proof that the instances disagree about the best dial.

So far, so encouraging. The variation is real, and harnessing it would be worth almost five percent.

## The catch: you can't read the oracle's mind

An oracle is not an algorithm. A practical rule has to choose $B$ from things you can compute about $N$ *before* you have done the sieving — cheap, *free features*. The experiment tried two natural candidates, trained on 60 numbers and tested on 60 held-out ones:

- A **stratified rule** that groups numbers by a feature counting their small split primes and picks the best $B$ for each group. On the held-out half: $1.0047\times$ — no better than the fixed dial, statistically a wash ($t = +1.12$).
- A **regression rule** predicting the best $B$ from several free features. On the held-out half: $1.0290\times$ — *significantly worse* than the fixed dial ($t = +3.04$).
- Meanwhile the oracle, on that same held-out half, would have achieved $0.9590\times$.

Why? Compare the size of the prize to the size of the noise. The total prize is $0.0478$ log units. But the instance-to-instance scatter that the free features *cannot* explain — the held-out residual standard deviation — is $0.536$. The **signal-to-noise ratio is $0.0478 / 0.536 \approx 0.089$**. The best dial position varies, but it varies in a way that free features simply do not see.

### Why a clever rule can lose to a dumb one

It seems paradoxical that a learned rule could do worse than doing nothing clever at all. Mathematics resolves the paradox in two steps.

First, *in-sample*, richer features can never hurt. If one feature refines another — knowing the first tells you the second — then the best rule reading the finer feature does at least as well on the training data. Training-set performance always flatters complexity.

Second, *out-of-sample*, all bets are off. Here is a two-instance example that makes the point concrete. On the training set, the costs are

| | dial low | dial high |
|---|---|---|
| instance A | $1$ | $0.9$ |
| instance B | $1$ | $1.2$ |

The best fixed dial is "low", total $2$ (versus $2.1$ for "high"). The rule "use high for A-type, low for B-type" scores $0.9 + 1 = 1.9$ — strictly better, and the best possible. But on a test set where the A-type instance now costs $1.5$ on "high" and $1$ on "low", and the B-type costs $1$ either way, the same rule costs $2.5$, while the humble fixed dial costs $2$. The learned rule strictly wins on training and strictly loses on test. This is exactly the shape of the $1.029\times$ regression result: it learned noise.

### The exact criterion

There is an even sharper way to say when a feature can help. Group the instances by the value of the feature — mathematicians call these groups the *fibres* of the feature. Then the very best rule reading that feature simply picks, in each fibre, the dial value that minimises that fibre's total cost; no learning algorithm, however sophisticated, can beat this. And the gain of that best rule over a fixed dial $b$ is precisely the sum, over the fibres, of how much worse $b$ is than each fibre's own optimum.

> **Zero-gain criterion.** A free feature yields no improvement whatsoever over the fixed dial $b$ if and only if $b$ is simultaneously the best choice in every fibre of the feature.

This turns implementability into a property of the data, not of the learner. The oracle's 102 strict wins show that *individual numbers* disagree about the best $B$; the wash of free rules shows that *the fibres* — the groups a free feature can distinguish — essentially agree. The disagreement lives below the resolution of anything you can compute cheaply.

## The second door that turned out to be a wall

The experiment noticed one more striking regularity. Within each instance, as $B$ climbs the ladder, the logarithm of the split-prime count $Q$ moves in lockstep with the logarithm of the factor-base size $m$: the measured slope was

$$\frac{d \log Q}{d \log m} = 0.99718 \pm 0.03722,$$

across all 120 numbers (range $0.923$ to $1.094$). One might hope to set $B$ to move $Q$ and $m$ independently — to "decouple" them. The data say no.

But here honesty demands a caveat, and it is one of the nicer lessons of the project. That near-perfect slope is not a deep empirical discovery; it is largely **bookkeeping**. If the factor base consists of the $Q$ split primes plus a fixed handful $c$ of special columns (such as the sign $-1$ and the prime $2$), then $m = Q + c$, and calculus gives

$$\frac{d\log Q}{d\log m} \;=\; \frac{m}{m - c} \;=\; 1 + \frac{c}{Q}.$$

Better still, every secant slope between two dial settings is trapped between $1$ and $1 + c/Q_1$, where $Q_1$ is the smaller split count. As $Q$ grows into the hundreds the slope is squeezed to within about one percent of $1$. So the measured $0.997$ is a consistency check — confirmation that the instrument reads what it should — rather than independent evidence. (The small scatter on either side of $1$ reflects the fact that the proportion of primes that split for a given $N$ fluctuates as $B$ moves, hovering around one half.)

## What this teaches

The story has a satisfying moral that reaches well beyond factoring.

**A real effect is not the same as a usable effect.** Per-instance optima exist all over engineering: the best learning rate for a particular training run, the best compiler flag for a particular program, the best dose for a particular patient. Hindsight always finds them, and hindsight never loses — that is a theorem, not a finding. The only question that matters is whether the information needed to find them is available *beforehand*, and that question is answered entirely by whether the groups you can distinguish disagree about the optimum.

**Price the real work.** The closed-form identity for paid touch, with its guaranteed $2|S| - 1$ error bar, is what made the whole experiment trustworthy: every conclusion is drawn about actual sieve operations.

**Be suspicious of perfect correlations.** A slope of $0.997$ looks like a law of nature; on inspection it is mostly the definition of $m$.

For the single-polynomial quadratic sieve, then, the adaptive-$B$ door is closed: the dial's per-number sweet spot is a post-hoc artifact of knowing the answer. The remaining open door in this family is the *multi-polynomial* sieve, which switches between many polynomials and shortens each sieving interval. There the closed form for the work becomes $k$ copies of the familiar expression plus a cost for each switch — and only that switching cost, so far unpriced, could possibly let $Q$ and $m$ part ways.

The dial is real. The sweet spot is real. But only an oracle can find it in time.
