# The Comb That Cannot Be Combed: Why Shor's Algorithm Refuses to Be Imitated

## A quantum advantage under siege

For thirty years, one algorithm has carried the weight of an entire industry's
anxiety. Shor's algorithm factors large integers — the arithmetic task whose
presumed hardness stands between the world's encrypted traffic and everyone who
would like to read it — in time polynomial in the number of digits, using a
machine that does not yet exist at scale.

The natural response of a theoretician is not to build the machine but to ask
whether it is really needed. This is the **de-quantization** program, and it has
an impressive record. Quantum recommendation systems, quantum principal
component analysis, quantum linear-system solvers for low-rank data: one by one,
these advertised exponential speedups have been matched by classical algorithms
that mimic the quantum machine's *sampling access* to the data and reproduce its
output distribution. The lesson has been consistent: when the quantum state is
*compressible* — low rank, sparse, concentrated — a classical algorithm can
usually sneak in behind it.

So: can Shor be de-quantized?

This article reports a negative answer, and — more interestingly — a *reason*.
The obstruction is not a vague appeal to complexity conjectures. It is a
concrete, computable structure inside the algorithm, and every de-quantization
strategy one can propose collides with the same wall. The wall has a name in
this program: **Barrier IV**, the seal on aggregation. And the object that
enforces it is a comb.

## What Shor actually computes

Strip away the quantum mechanics and the algorithm has one job. Given a modulus
$N$ to be factored, and a base $b$ coprime to it, find the **multiplicative
order** of $b$: the smallest $r \ge 1$ with
$$b^r \equiv 1 \pmod N.$$

Once you know $r$, factoring is a formality, and this is elementary. Suppose $r$
is even and $b^{r/2} \not\equiv -1 \pmod N$. Then $x = b^{r/2}$ satisfies
$x^2 \equiv 1$, but $x \not\equiv \pm 1$: it is a *nontrivial square root of
unity*. And such a root always splits the modulus:

> **Splitting Theorem.** If $x^2 \equiv 1 \pmod N$ with $N > 1$ but
> $x \not\equiv 1$ and $x \not\equiv -1$, then $\gcd(x-1, N)$ is a nontrivial
> divisor of $N$: $1 < \gcd(x-1,N) < N$.

The proof is two lines. If the gcd were $1$, then $N$ would be coprime to $x-1$
and would have to divide the other factor of $x^2 - 1 = (x-1)(x+1)$, forcing
$x \equiv -1$. If the gcd were $N$, then $N \mid x - 1$, forcing $x \equiv 1$.
Both are excluded, so the gcd sits strictly in between. With $N = 15$ and
$b = 2$, the order is $r = 4$, so $x = 2^2 = 4$, and $\gcd(3, 15) = 3$: the
factor drops out. With $N = 21$ and $b = 2$, the order is $6$, $x = 2^3 = 8$, and
$\gcd(7,21) = 7$.

So the entire cryptographic drama is compressed into a single number, $r$. Shor's
quantum circuit is a device for extracting it.

## The comb

Here is the state that does the work. The circuit puts a first register into
uniform superposition over $\{0, 1, \dots, Q-1\}$, computes $b^x \bmod N$ into a
second register, and measures the second register. Whatever value it happens to
see, the first register collapses onto exactly those $x$ producing that value —
and since $b^x$ depends only on $x$ modulo $r$, those $x$ form an **arithmetic
progression of spacing $r$**:
$$x_0,\quad x_0 + r,\quad x_0 + 2r,\quad \dots$$

A row of evenly spaced teeth. A comb. The hidden order $r$ is its tooth spacing,
and the whole problem is to measure that spacing without being able to see the
teeth.

The quantum circuit's answer is the Fourier transform, and the arithmetic is
exact. Assume for cleanliness that $r$ divides the grid size $Q$. Then the
transform of the comb at frequency $y$ is a complete geometric sum:

> **Exact Spectrum of the Comb.** For $r \mid Q$ and any frequency $y$,
> $$\sum_{j=0}^{Q/r - 1} e^{2\pi i\, j r y / Q} \;=\;
> \begin{cases} Q/r, & \text{if } (Q/r) \mid y,\\[2pt] 0, & \text{otherwise.}\end{cases}$$

There is no approximation here, no leakage, no tail. The transform of a comb of
spacing $r$ is a comb of spacing $Q/r$ — and nothing else. The frequencies that
carry information are exactly the multiples of $Q/r$, and inside the window
$\{0,\dots,Q-1\}$ there are exactly $r$ of them.

That last sentence is the crux of everything that follows.

> **The Peak Count Is the Secret.** For $r \mid Q$ the comb's spectrum has exactly
> $r$ nonzero frequencies in $\{0,\dots,Q-1\}$, and the measurement distribution
> puts mass exactly $1/r$ on each of them.

Take $Q = 16$ and $r = 4$: the peaks are $\{0, 4, 8, 12\}$ — four of them, each
with probability $1/4$. Take $Q = 12$ and $r = 3$: the peaks are $\{0,4,8\}$.
The number you are trying to learn is not encoded in the *position* of any single
peak; it is the *number of peaks*, and the *height* of each. You cannot read it
off from a corner of the picture. You have to see the whole picture at once.

## Flatness is the enemy of compression

Why should this be hard for a classical computer? Because classical simulations
of quantum states survive on compressibility, and this distribution has none.

The measurement distribution is perfectly **flat**: $r$ outcomes, each of
probability $1/r$. Its Shannon entropy is exactly $\log r$ — the maximum possible
for $r$ outcomes. There is no dominant peak to keep and no negligible tail to
discard. Every tooth matters equally.

This can be made quantitative and unforgiving. Suppose a classical algorithm
produces some surrogate distribution $D$ supported on at most $k$ outcomes — a
low-rank sketch, a sparse approximation, a truncated tensor network, anything
whose description size you have budgeted. How close can it get?

> **Incompressibility Theorem.** If $D$ is supported on at most $k$ points, then
> the total variation distance between $D$ and the true output distribution is at
> least
> $$1 - \frac{k}{r},$$
> and this bound is attained.

The proof fits in a sentence: the surrogate misses at least $r - k$ of the peaks,
and those peaks carry probability $(r-k)/r$ under the truth and zero under the
surrogate; total variation dominates the discrepancy on any event. Sharpness
comes from putting mass $1/k$ on $k$ of the peaks and nothing elsewhere.

Now put real numbers in. For a $2048$-bit modulus the order $r$ is typically
astronomically large, while any classical algorithm we would call efficient has
$k = \mathrm{poly}(\log N)$. Then $k/r$ is not small — it is *invisible*, and
the distance is $1 - o(1)$: the surrogate and the truth are as far apart as two
probability distributions can be. A classical sketch of Shor's output is not a
slightly degraded copy. It is a different object entirely.

The same rigidity shows up on the quantum side of the ledger. The
pre-measurement state, viewed as a matrix across the cut between the two
registers, has rank exactly $r$ — and its rows are orthonormal, so all $r$
Schmidt coefficients are equal and the entanglement spectrum is as flat as the
measurement distribution. Matrix-product-state simulation, the workhorse for
classically emulating quantum circuits, requires a bond dimension at least the
rank. Contrapositive:

> **The Tensor-Network Route Closes.** If the order-finding state admits any
> bipartite decomposition of rank at most $k$, then $r \le k$.

A polynomial bond dimension therefore forces a polynomially small order — which
is precisely the regime where a classical computer could have found $r$ by brute
force anyway. Low-rank emulation works exactly when it is not needed.

## The distance between two secrets

The sharpest way to see the seal is to ask what a *single* classical sampler can
possibly do. It does not know $r$ — that is the whole point — so it must emit
one fixed distribution and hope. How badly does that hurt?

Exactly this badly:

> **Exact Distance Between Combs.** Let $r_1 \le r_2$ both divide $Q$. The total
> variation distance between the two output distributions is
> $$\mathrm{TV}(P_{r_1}, P_{r_2}) \;=\; 1 - \frac{\gcd(r_1,r_2)}{r_2}.$$

Not a bound — an identity. The two combs share exactly $\gcd(r_1,r_2)$ peaks
(the peaks of the gcd), and the arithmetic of the overlap does the rest. On the
grid $Q = 48$, the orders $3$ and $16$ produce distributions at distance exactly
$1 - 1/16 = 15/16$. They are almost mutually singular.

And now the triangle inequality does something lovely. If two candidate outputs
are far from each other, no third distribution can be close to both:

> **Every Sampler Is Far From Something.** For any distribution $D$ whatsoever,
> $$\max\big(\mathrm{TV}(D, P_{r_1}),\, \mathrm{TV}(D, P_{r_2})\big)
> \;\ge\; \tfrac{1}{2}\Big(1 - \tfrac{\gcd(r_1,r_2)}{r_2}\Big).$$

For coprime orders this is $\frac{1}{2}(1 - 1/r_2)$, converging to $1/2$. That is
the famous "$\mathrm{TV} \ge 0.5$" figure of de-quantization experiments — not as
an empirical observation from a simulation run, but as an identity with an exact
constant.

With more candidates the seal tightens by pigeonhole. Consider $k$ pairwise
coprime candidate orders, all at least $R$. Their peak sets meet only at the
trivial frequency $0$ — because if a frequency were a common peak of two coprime
orders it would have to be a multiple of $Q$ itself, hence outside the window.
So each candidate puts mass $\ge 1 - 1/R$ on its *own* private set of
frequencies, and these $k$ sets are disjoint. A single distribution has only
total mass $1$ to spread over $k$ disjoint targets, so it must starve one of
them:

> **No Order-Free Sampler.** For $k$ pairwise coprime candidate orders, each at
> least $R$ and each dividing $Q$, every distribution $D$ satisfies
> $\mathrm{TV}(D, P_{r_i}) \ge 1 - 1/R - 1/k$ for at least one candidate $i$.

Mass conservation, nothing more. And it says that sampling the output of order
finding already requires knowing the order.

## The free probe that tells you nothing

There is one more route worth walking, because it looks like a loophole and
turns out to be the barrier in its purest form.

There is a completely free classical observation available. For any $t$, compute
$\gcd(b^t - 1, N)$ — one modular exponentiation, $O(\log t)$ multiplications.
This *probe* answers a clean question:
$$N \mid b^t - 1 \iff r \mid t.$$
A perfect divisibility oracle for the hidden order, at negligible cost. Surely
one can bootstrap from that?

One cannot, and the reason is stark. Every probe below the order returns
`false` — if $r \mid t$ and $0 < t$ then $t \ge r$. So the entire answer vector
on $\{1,\dots,r-1\}$ is *constant*. It contains literally zero bits of
information about $r$; the oracle sits in silence until you happen to hit a
multiple of the answer. Formally, $r$ is the least positive $t$ at which the
probe fires, and there is an adversary argument:

> **Extraction Needs a Query as Large as the Order.** Let $A$ be any procedure
> whose output depends only on the probe answers at a finite query set $T$ of
> positive integers. If $A$ correctly returns the order in both of two cases
> $r \ne s$, then $T$ contains a query $t \ge \min(r,s)$.

Because if every query were smaller than both, the two answer vectors would be
identical — all `false` — and $A$ would return the same number in both cases.
A second, information-theoretic bound squeezes from the other side: a procedure
reading $|T|$ probe bits can distinguish at most $2^{|T|}$ candidate orders, so
identifying $r$ among $n$ possibilities requires at least $\log_2 n$ queries. The
probe channel is therefore pinched from both directions: you need
$\Omega(\log r)$ bits, and at least one query must have magnitude $\Omega(r)$.
Baby-step/giant-step improves the naive $\Theta(r)$ walk to $\Theta(\sqrt r)$ —
still exponential in the bit length.

Is this seal vacuous? Could it be that the large orders never occur? No: for
every $r \ge 2$, the base $2$ has order exactly $r$ modulo the Mersenne number
$2^r - 1$. Every scale is realised by an honest instance.

The one genuine escape is real but circular. If you already know a multiple $L$
of $r$ *together with its factorization*, then $r$ is the least divisor of $L$
passing the probe, and you can find it quickly. For an RSA modulus the natural
choice is $L = \lambda(N)$, the Carmichael function — whose computation is
itself equivalent to factoring $N$. The door is unlocked from the inside only.

## Aliasing: the grid does not save you

A last idea: perhaps sampling on a *mismatched* grid, where $r \nmid Q$, blurs
the structure in some exploitable way. It does blur it — against you. On a grid
of size $Q$, the visible peak structure is that of $\gcd(r, Q)$, and if $r$ does
not divide $Q$ then
$$2\gcd(r,Q) \le r.$$
Mismatch destroys at least one bit of the order immediately; and in the extreme
case $\gcd(r,Q) = 1$ the only visible peak is the trivial frequency $0$, so the
sample carries no information about $r$ at all. Aliasing is not a resource.

## The verdict

Assemble the pieces and they interlock. For one and the same order-finding
instance: no probe below $r$ says anything; the state's rank across the register
cut is exactly $r$; every $k$-sparse surrogate distribution is at distance
$\ge 1 - k/r$ from the truth; the true distribution is flat with entropy
$\log r$; and the moment you know $r$, a single gcd factors $N$.

That last clause turns the analysis into an equivalence. In the other direction,
the classical post-processing that converts a sample into an order is provably
unambiguous. Two distinct fractions with denominators $r, r'$ are separated by at
least $1/(rr')$ — the Farey separation — so a real number determines *at most
one* reduced fraction with denominator $\le R$ to accuracy $1/(2R^2)$. Hence
continued-fraction post-processing of a sampled frequency returns *the* order,
not a competitor. A polynomial-time classical sampler of Shor's output
distribution would therefore be a polynomial-time factoring algorithm outright.

**De-quantizing Shor is not easier than factoring. It is factoring.**

And the reason is now a structural statement rather than a slogan. The
factor-revealing information lives in $r$; $r$ parameterizes an incompressible
object — rank exactly $r$, spectrum perfectly flat, $r$ equal peaks at spacing
$Q/r$; observation of that object can be free, but *extraction* costs
$\Theta(r)$, and no classical aggregation of polynomially many local
observations reproduces it.

There is a pleasing irony here. Quantum computing's greatest triumph survives
precisely because its central object is the most boring distribution
imaginable — a flat one. All the de-quantization successes of the last decade
exploited structure: low rank, concentration, decay. Shor's algorithm offers
none. It exposes exactly $\log r$ nats of information, spread perfectly evenly
across $r$ equally weighted teeth, and demands that you take them all at once or
not at all. The quantum Fourier transform does exactly that, in superposition,
in one shot.

The de-quantization frontier for order finding is closed, and the quantum
exception stands — now maximally bounded, and understood.
