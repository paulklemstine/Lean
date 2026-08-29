# The Arithmetic of Doing Many Things at Once

## How one gigantic number can sift five hundred candidates at a stroke — and why that clever trick still can't break a code

### A sieve made of numbers

Every modern factoring algorithm — the machinery that stands between your bank
details and a determined adversary — spends most of its life doing something
that sounds almost menial. It generates a torrent of integers and asks, over and
over, one question:

> Does this number factor completely into small primes?

A number whose prime factors are all at most some bound $B$ is called
**$B$-smooth**. The number $360 = 2^3 \cdot 3^2 \cdot 5$ is $5$-smooth. The
number $362 = 2 \cdot 181$ is not: $181$ is far too big. Smooth numbers are the
raw material of the quadratic sieve and the number field sieve, because smooth
numbers can be written down as short exponent vectors, and exponent vectors can
be fed to linear algebra, and linear algebra is where a factorization finally
falls out. Everything else in the sieve is a search for enough of them.

So the question "is this smooth?" gets asked billions of times, and its cost is
the algorithm's heartbeat. The obvious way to answer it is the schoolroom way:
take your candidate $n$, and try dividing by $2$, by $3$, by $5$, by $7$, all
the way to $B$. This is **trial division**, and it is honest, simple, and
lonely: each candidate is examined in isolation, and nothing learned about one
helps with the next.

There is a better idea, and its beauty is that it refuses to treat candidates
one at a time.

### One number to test them all

Let $P$ be the product of *every* prime up to $B$:
$$P \;=\; \prod_{p \le B,\; p \text{ prime}} p .$$
For $B = 100$ this is the product of the $25$ primes below $100$ — a number with
about $110$ bits, entirely unremarkable by the standards of a computer.

Here is the observation the whole subject rests on. Suppose $n$ is a positive
integer smaller than $2^t$ — that is, $n$ has at most $t$ bits. Then:

> **The Batch Smoothness Criterion.** $n$ is $B$-smooth **if and only if**
> $n$ divides $P^t$.

Read it in both directions, because both directions matter and they are not
equally easy.

The easy direction is *soundness*. If $n$ divides $P^t$, then every prime $p$
dividing $n$ divides $P^t$, hence (primes being prime) divides $P$, hence is one
of the primes at most $B$. So $n$ is smooth. Nothing subtle.

The other direction is *completeness*, and it is where the bit-length enters.
Suppose $n$ is smooth. Each of its prime powers $p^{e}$ satisfies
$2^{e} \le p^{e} \le n < 2^{t}$, so every exponent $e$ is strictly less than
$t$ — in fact at most $t-1$. Since $P$ contains each small prime exactly once,
$P^t$ contains each of them $t$ times, which is more than enough to swallow
$n$'s exponents. Hence $n \mid P^t$.

That second argument has a shape worth pausing over. It says that a *size* fact
about $n$ (it is smaller than $2^t$) controls an *arithmetic* fact (no exponent
in it can be large), because the smallest possible prime is $2$ and doubling
$t$ times overshoots. It is a currency conversion between bits and exponents.

And the bound is not slack. Take $n = 2^t$, which is as smooth as a number can
be. It divides $P^s$ precisely when $t \le s$: the criterion with any exponent
smaller than the bit length would reject it. Concretely, with $t=1$ the perfectly
smooth number $4$ fails to divide $P^1$ for every bound $B$. The exponent $t$ is
exactly right — not conservative, not adjustable downward.

### Why this is fast

At first sight the criterion looks like a step backwards. $P^t$ is a monstrous
number: for $B = 100$ and $t = 40$ it has some four thousand bits. Who wants to
divide by that?

Nobody does, and nobody has to, and this is the engineering insight due to
Bernstein. You never form $P^t$. Instead:

1. **Build $P$ once, as a product tree.** Put the primes at the leaves,
   multiply in pairs, then multiply the pairs, and so on. The root is $P$. This
   cost is paid a single time for the entire run, no matter how many candidates
   you eventually test.

2. **Push $P$ down a remainder tree over the candidates.** Build a second
   product tree whose leaves are the candidates $n_1, \dots, n_k$; then compute
   $P \bmod (\text{root})$, and cascade the remainders downward. At the bottom
   you hold $P \bmod n_i$ for every $i$ — and crucially each of those is a
   *small* number, no bigger than $n_i$.

3. **Square $e$ times.** Since $n \mid P^t \iff (P \bmod n)^t \equiv 0
   \pmod n$, and since raising to the power $2^e$ is at least as strong as
   raising to the power $t$ whenever $t \le 2^e$, you finish with $e \approx
   \log_2 t$ squarings modulo $n$ — six squarings for $40$-bit candidates.
   Declare $n$ smooth exactly when you reach $0$.

The reduction step is what makes it legal to think about $P^t$ without ever
computing it: reducing $P$ modulo $n$ before exponentiating changes nothing
about the verdict, since $n \mid P^t$ is equivalent to $(P \bmod n)^t \bmod n =
0$. The whole tower of theory collapses into a handful of machine-word
operations per candidate.

One more small comfort. Product trees come in shapes: you can balance them, you
can list the primes in any order, you can build them left-leaning or
right-leaning. Does the answer depend on the shape? No — a product tree always
evaluates to the product of its leaves, whatever its shape, so every arrangement
of the factor base yields the same $P$ and therefore the same verdicts. Two
implementations that disagree on tree shape cannot disagree on smoothness.

### The audit that became a theorem

An experiment comparing batch testing against trial division at $B = 100$ on
$40$-bit candidates ran an exact-match check: on $500$ sampled inputs, the
smooth set found by the batch algorithm was identical to the smooth set found by
per-item trial division. Three variants were compared — the tree version, a
direct version, a vectorized version — and there were zero mismatches out of
$500$ in all three.

That is reassuring, but it is a sample statistic, and sample statistics are
about the samples. The criterion above upgrades it to something stronger:

> **Exactness of the batch filter.** For any finite pool $S$ of positive
> candidates each smaller than $2^t$, the set of members of $S$ that divide
> $P^t$ is *equal* to the set of members of $S$ that pass trial division.

Not "agrees on $500$ of $500$". Equal, on every pool, forever. Disagreement is
not unlikely; it is impossible. This is the difference between testing software
and knowing an algorithm, and it is worth insisting on: the number of possible
$40$-bit candidates is about $10^{12}$, and $500$ of them is not evidence about
the rest.

### And now the disappointment

Correct is not the same as fast, and fast is not the same as *usefully* fast.
Here is where the story turns, and where it becomes an honest piece of
engineering rather than a triumph.

**First: in one accounting, batching always wins.** Model the batch cost as a
one-off setup $A$ (building the factor-base tree) plus a per-candidate cost $c$,
against solo's $s$ per candidate. On a pool of $k$ candidates the relative saving
is
$$1 - \frac{A + ck}{sk} \;=\; \frac{s-c}{s} \;-\; \frac{A}{sk}.$$
Two things follow immediately. The saving strictly increases with $k$ — the
setup gets diluted — and it converges to the ceiling $(s-c)/s$ without ever
reaching it: amortization can erase your setup cost but never your per-candidate
cost. And if the setup is cheap enough that $A < s - c$, there is *no crossover
at all*: batch is already ahead at $k = 1$. That is exactly what was measured,
with batch beating solo at every tested pool size $k \in \{1, 8, 64, 512\}$ and
a best relative gain of $+10.4\%$ at $k = 512$.

**Second: in a more honest accounting, batching eventually loses.** Counting
operations is a fiction, because the operations are not equal. A product tree
over $2^L$ leaves of $w$ machine words each, with schoolbook multiplication,
costs
$$\frac{w^2\left(4^L - 2^L\right)}{2}$$
word operations — the topmost multiplication alone combines two operands each
half the total width, at a cost proportional to the square of the pool size.
That $4^L$ is *quadratic in the pool size*, while solo trial
division stays stubbornly linear. So there is always a pool size past which the
tree alone costs more than all of trial division put together. In a two-parameter
continuous version — batch pays $qk(k-1) + c_1k$, solo pays $s_1k$ — the sign
changes exactly once, at
$$M^{*} \;=\; 1 + \frac{s_1 - c_1}{q},$$
and the measurement puts that crossover at about $1715$ candidates. At $k = 512$
the word model still favours batching; by $k = 4096$ it emphatically does not,
with the measured word-model delta at $k = 512$ swinging to $-62.6$ once
big-integer intermediates are charged properly. The same algorithm, the same
inputs, and the sign of the answer depends on what you agree to call an
operation.

**Third: even a perfect win here would barely matter.** This is the deepest
constraint and the least glamorous. Factoring splits into *finding* candidates
and *testing* them, and in the measured configuration testing accounted for only
$11.56\%$ of the per-factor work. Amdahl's law then says something merciless: if
you replace a phase costing $S$ out of a total $F + S$ with anything costing
$S' \ge 0$, the overall saving is at most $S/(F+S)$. Make testing instantaneous,
free, magical — you still save at most $11.56\%$, and the end-to-end speedup
factor is capped at $1/(1-f) \approx 1.13$. A constant. Not a change of
complexity class; not a threat to anybody's key.

Run that logic backwards and it becomes a measuring instrument. An overall gain
of $+10.4\%$ against a testing share of $11.56\%$ is not a vague "most of the
available headroom" — it *forces* the surviving testing cost to be exactly
$$\frac{S'}{S} = 1 - \frac{0.104}{0.1156} = \frac{29}{289} \approx 10.03\%,$$
a $\approx 9.97\times$ speedup of the testing phase itself. From two aggregate
percentages you recover the phase-level speedup exactly. That is a nice trick to
have: you can audit a claimed phase improvement without ever instrumenting the
phase.

### One formula, both regimes

The flat model and the word model look like two different stories — "bigger
batches always better" versus "bigger batches eventually worse" — but they are
one story with a parameter set to zero.

Cut a long stream of candidates into blocks of size $k$. The per-candidate cost
is
$$\mathrm{cost}(k) \;=\; \frac{A}{k} \;+\; c \;+\; q(k-1),$$
with $A$ the per-block setup, $c$ the flat per-candidate cost, and $q$ the
quadratic big-integer penalty. When $q = 0$ the function is strictly decreasing:
no optimum exists, bigger is always better, and you get the flat model's
monotone win. When $q > 0$, the arithmetic–geometric mean inequality gives
$$\mathrm{cost}(k) \;\ge\; c - q + 2\sqrt{Aq},$$
with equality **if and only if**
$$k^{*} = \sqrt{A/q}.$$
A unique interior optimum, at a square root of a cost ratio. The reported
crossover near $1715$ candidates is a shadow of that square root, not a property
of tree depth or of the factor base. Set $A = 1000$ operations and
$q = 1/1000$, and the optimum sits at exactly $k^{*} = 1000$ candidates — the
right order of magnitude, from two numbers and a square root.

### What the smooth numbers were for

There is a final act, and it explains a zero in the experimental log. Despite
correct and fast smoothness testing, the run split no integers at all: at bit
length $40$ with factor base bound $100$, the count of successful sieve splits
was $0$.

Why? Because smoothness testing is not the goal; it is a supplier. The quadratic
sieve wants a sub-family of relations whose product is a perfect square, and
here the requirement is completely explicit. Let $\pi(B)$ be the number of primes
at most $B$. Then:

> **Relation Quota.** Any family of more than $\pi(B)$ positive $B$-smooth
> numbers contains a nonempty sub-family whose product is a perfect square.

The proof is a pigeonhole over the two-element field. Send each smooth $n$ to
its vector of prime exponents *modulo 2*, a vector in $\mathbb{F}_2^{\pi(B)}$.
There are $2^{\pi(B)}$ possible vectors but more than $\pi(B)$ relations, so by
considering the $2^{\text{(number of relations)}}$ subset sums against only
$2^{\pi(B)}$ possible values, two distinct subsets must have the same sum; their
symmetric difference is a nonempty subset summing to zero. Every exponent in the
product of that sub-family is then even — and a positive integer with all
exponents even is a square. Note that no distinctness is required: repeated
relations are allowed, which matters because a real batch produces duplicates.

For $B = 100$ we have $\pi(100) = 25$, so $26$ smooth relations *guarantee* a
square. The experiment's failure to split was therefore not an algorithmic
failure at all, but a yield failure: the pipeline never reached $26$ usable
relations, because $40$-bit candidates with a bound of $100$ are smooth only
about one time in ten thousand. Making the supplier faster does not help a
factory that never receives its quota of parts.

### The moral

There is a temptation, in computational mathematics, to treat a measured
speedup as a result. This episode argues otherwise, in three movements.

The *correctness* claim deserved to be a theorem, and became one: a criterion
proved exact on its entire input range, sharp in its exponent, indifferent to
tree shape, and stable under the two shortcuts (modular reduction and repeated
squaring) that the implementation actually takes. Five hundred agreeing samples
were a rumour of this; the theorem is the fact.

The *performance* claim turned out to be a calibration, not a law. "Batch wins
at every pool size" is equivalent, in the model, to the inequality $A < s - c$
— a statement about one implementation on one machine, which the word-level
accounting reverses past roughly $1715$ candidates. Both regimes are the single
curve $A/k + c + q(k-1)$, with $q = 0$ or $q > 0$.

And the *significance* claim was bounded before it was made. Testing is
$11.56\%$ of the work; the ceiling is $11.56\%$; the realized $10.4\%$ sits just
under it, exactly as it must. It is honest, useful, well-measured
constant-shaving on standard machinery — and constant-shaving is what most of
computational number theory actually is, most of the time. The interesting part
is that we can now say precisely *how much* shaving was possible, precisely
*where* the sign flips, and precisely *how many* relations you need before the
whole enterprise pays off.

Twenty-six, if your primes stop at a hundred.
