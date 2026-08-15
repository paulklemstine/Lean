# The Prime That Shouldn't Be There

## How a plausible guess about elliptic curves — and a tempting route to factoring — collapses on a five-line computation

### A cryptographer's daydream

Every modern public-key system rests on the same asymmetry: multiplying two large primes $p$ and $q$ is easy, and recovering them from the product $N = pq$ is hard. Any scheme that leaks a factor of $N$ from an innocent-looking computation would be a catastrophe for cryptography — and a triumph for number theory. So people look. They look in strange corners.

One of the strangest and most attractive corners is the family of **Mordell curves**
$$E_N : y^2 = x^3 + N .$$

These are among the oldest studied cubic curves. The set of rational solutions $(x,y) \in \mathbb{Q}^2$, together with a point at infinity $O$, forms an abelian group: given two rational points you can draw the line through them, intersect it with the cubic, and reflect the third intersection point across the $x$-axis. That geometric recipe is a *group law*, and it lets you compute $2P$, $4P$, $8P$, and so on from a single rational starting point $P$.

Here is where the daydream begins. When you add points, the coordinates become fractions, and the denominators explode. Take $N = 55 = 5 \cdot 11$ and the point $P = (9, 28)$, which sits on $E_{55}$ because $28^2 = 784 = 9^3 + 55$. Doubling it gives
$$x(2P) = \frac{9^4 - 8 \cdot 55 \cdot 9}{4(9^3 + 55)} = \frac{2601}{3136},$$
already a four-digit denominator. Iterate three more times and the denominator has 274 digits. Those denominators are enormous integers manufactured by an arithmetic engine that has $N$ built into it. Surely — the daydream goes — the primes hiding inside them must be primes that $N$ knows about.

There is even a principled version of the guess. Every elliptic curve carries a **discriminant** $\Delta$, an integer measuring where the curve degenerates. For $E_N$ it is
$$\Delta = -432\,N^2 = -2^4 \cdot 3^3 \cdot N^2 .$$
The primes dividing $\Delta$ — for $N = pq$, exactly the set $\{2, 3, p, q\}$ — are the primes of **bad reduction**: reduce the curve modulo one of them and the smooth cubic acquires a singularity. Every other prime is a prime of **good reduction**, where the curve stays a perfectly healthy elliptic curve over a finite field.

**The "only bad primes" conjecture.** *For $E_N$ with $N = pq$ and any rational point $P$, every prime dividing the denominator of $x(nP)$ lies in $\{2, 3, p, q\}$.*

If that were true it would be a factoring algorithm. Compute $2P$, take the denominator, strip the powers of $2$ and $3$, and read off $p$ or $q$. RSA would be dead by lunchtime.

It is false. And it fails at the very first doubling of the very example above.

### The counterexample

$$3136 = 2^6 \cdot 7^2 .$$

There it is. The denominator of $x(2P)$ for $N = 55$, $P = (9,28)$ contains the prime $7$. And $7$ divides neither $6$ nor $55$, hence not $\Delta = -432 \cdot 55^2$: it is a prime of **good** reduction. Worse for the daydream, neither $5$ nor $11$ — the two primes we actually wanted — appears anywhere in $3136$. The greatest common divisor $\gcd(3136, 55)$ equals $1$. The denominator is arithmetically rich and completely silent about the factorisation of $N$.

This is not a fluke of one curve. Try $N = 33 = 3 \cdot 11$ with $P = (-2, 5)$: doubling gives $x(2P) = 136/25$, and the denominator $25 = 5^2$ consists entirely of the good prime $5$, again coprime to $N$.

And the failure is not sporadic but *systematic*. Here is an infinite family of counterexamples that can be written down in one line. For any prime $\ell \ge 5$, set
$$N = \ell^2 - 1, \qquad P = (1, \ell),$$
which lies on $E_N$ since $\ell^2 = 1^3 + (\ell^2 - 1)$. The doubling formula gives
$$x(2P) = \frac{1 - 8(\ell^2-1)}{4(1 + \ell^2 - 1)} = \frac{9 - 8\ell^2}{4\ell^2},$$
and one checks that this fraction is already in lowest terms (any common factor would divide $(9-8\ell^2) + 2 \cdot 4\ell^2 = 9$, forcing $3 \mid \ell$). So the denominator is exactly $4\ell^2$: the only odd prime in it is $\ell$ itself — a prime of good reduction, since $\ell$ divides neither $6$ nor $\ell^2 - 1$. Meanwhile $N = (\ell-1)(\ell+1)$ has plenty of odd prime factors, and **not one of them** divides $4\ell^2$. The conjecture fails for every prime $\ell \ge 5$, and since distinct primes give distinct $N$, there are infinitely many $N$ for which it fails.

For $\ell = 7$: $N = 48$, $P = (1,7)$, $x(2P) = -383/196$, and $196 = 2^2 \cdot 7^2$. The denominator broadcasts $7$, loudly and permanently — and says nothing about $48 = 2^4 \cdot 3$ beyond the trivial prime $2$.

### Why the guess was doomed

A counterexample refutes; a mechanism explains. Once you see the mechanism, the surprise flips: the astonishing thing would have been for the conjecture to hold.

The first structural fact is that denominators on a Mordell curve have a rigid shape.

**The square–cube theorem.** *If $(x,y)$ is a rational point on $y^2 = x^3 + N$ with $N$ an integer, then the reduced denominators satisfy $\mathrm{den}(y)^2 = \mathrm{den}(x)^3$. Consequently there is a positive integer $e$ with*
$$\mathrm{den}(x) = e^2, \qquad \mathrm{den}(y) = e^3 .$$

The proof is a one-liner if you know one fact about fractions: the denominator of a power is the power of the denominator, and adding an integer changes nothing. From $y^2 = x^3 + N$ we get $\mathrm{den}(y)^2 = \mathrm{den}(x)^3$ immediately; a little bookkeeping with unique factorisation then produces the integer $e$. Every rational point looks like $(a/e^2,\, b/e^3)$, and substituting turns the curve into the integral identity
$$b^2 = a^3 + N e^6 .$$
Sure enough, $3136 = 56^2$ and $25 = 5^2$ and $4\ell^2 = (2\ell)^2$ — every denominator we have seen is a perfect square, as it must be.

The second fact is the real explanation. What does it *mean* for a prime $\ell$ to appear in a denominator? Write the point as $(a/e^2, b/e^3)$ in lowest terms and try to reduce it modulo $\ell$.

**The reduction dichotomy.** *For a rational point $(x,y)$ on $E_N$ and any prime $\ell$: if $\ell \nmid \mathrm{den}(x)$ the point reduces to an honest affine point of the curve over the field $\mathbb{F}_\ell$ with $\ell$ elements; if $\ell \mid \mathrm{den}(x)$ no such reduction exists — the point reduces to the point at infinity $O$. In short, $\ell$ divides the denominator exactly when $P$ lies in the kernel of reduction at $\ell$.*

Read that criterion again and notice what is *not* in it. There is no discriminant. There is no mention of good or bad reduction. The condition "$\ell$ divides a denominator" is a statement about **where the point sits**, not about **where the curve is sick**. A prime enters a denominator when the point happens to become the identity modulo that prime — and for a point of infinite order, reduction modulo $\ell$ lands in a finite group, so *some* multiple of $P$ must hit the identity. Every good prime is therefore a denominator prime waiting for its turn.

The "only bad primes" conjecture confused two different sets of primes: the primes where the *curve* degenerates, and the primes where the *point* degenerates. Nothing ties them together.

### The counterexample machine

Once the mechanism is visible, counterexamples can be mass-produced. The doubling formula for an integral point $(x,y)$ on $y^2 = x^3 + N$ can be rewritten, using $x^3 + N = y^2$, as
$$x(2P) = \frac{x^4 - 8Nx}{4y^2} .$$
The denominator is $4y^2$ — it is built out of $y$, not out of $N$. So suppose some prime $\ell$ divides $y$ but not $6N$. Does $\ell$ survive into the reduced fraction? Only if it misses the numerator, and the numerator factors as
$$x^4 - 8Nx = x(x^3 - 8N) = x(y^2 - 9N).$$
If $\ell \mid y$ and $\ell \nmid 6N$, then $\ell \nmid x$ (else $\ell$ would divide $y^2 - x^3 = N$) and $\ell \nmid y^2 - 9N$ (else $\ell \mid 9N$, again impossible). So $\ell$ divides the denominator and not the numerator, and it survives.

**The counterexample criterion.** *Let $(x,y)$ be an integral point on $E_N$ with $y \neq 0$, and let $\ell$ be any prime dividing $y$ but not $6N$. Then $\ell$ — a prime of good reduction — divides the denominator of $x(2P)$, and the "only bad primes" conjecture fails for $(N,P)$.*

For $N = 55$, $P = (9,28)$: $28 = 2^2 \cdot 7$ and $7 \nmid 330$, so $7$ must appear. For $N = 33$, $P = (-2,5)$: $5 \mid 5$ and $5 \nmid 198$, so $5$ must appear. For the family: $\ell \mid \ell$ and $\ell \nmid 6(\ell^2-1)$. All three examples are the same theorem, applied three times.

And this is why the conjecture fails *all the time*. To find a counterexample you need an integral point whose $y$-coordinate has a prime factor coprime to $6N$ — which is to say, you need $y$ to be something other than a product of $2$s, $3$s, and factors of $N$. Almost every integral point on almost every Mordell curve qualifies.

### Once in, never out

There is a final twist that turns the refutation into something sharper. The intruder prime does not merely visit — it moves in permanently, with a fixed exponent.

**Persistence.** *If a prime $\ell$ divides the denominator of $x(P)$, it divides the denominator of $x(2P)$, hence of $x(2^nP)$ for every $n$.* The reason: the kernel of reduction at $\ell$ is a subgroup, and subgroups are closed under doubling.

**Rigidity of the exponent.** *For an odd prime $\ell$ already present, doubling leaves the $\ell$-adic multiplicity of the denominator exactly unchanged. For $\ell = 2$, doubling increases it by exactly $2$. And a good prime $\ell$ not yet present enters the denominator of $x(2P)$ with multiplicity exactly $2\,v_\ell(\mathrm{num}\, y)$ — in particular it enters if and only if it divides the numerator of $y$.*

This is the elementary shadow of a deep fact: near a prime $\ell$, the kernel of reduction is a formal group in which multiplication by $2$ is an isomorphism when $\ell$ is odd, but strictly deepens the filtration when $\ell = 2$, the residue characteristic of the multiplier.

Watch it happen. Starting from $P = (9,28)$ on $E_{55}$, the denominators of $x(2^nP)$ factor as
$$n=1:\ 2^6 \cdot 7^2, \qquad n=2:\ 2^8 \cdot 7^2 \cdot 827^2 \cdot 1583^2, \qquad n=3:\ 2^{10} \cdot 7^2 \cdot 827^2 \cdot 1583^2 \cdot 125017^2 \cdots$$
The exponent of $2$ climbs by exactly $2$ each step, as predicted. The good prime $7$ is frozen at exponent $2$ forever, as predicted. New good primes — $827$, $1583$, $125017$ — arrive with exponent $2$ and never leave, as predicted. And $5$ and $11$, the two primes we came for, are nowhere to be seen.

### The barrier

The last observation is the one that matters for cryptography. Run the experiment across many semiprimes $N = pq$ with a small integral point, and follow the first few doublings: in a survey of $25$ such curves, the conjecture held for **none** of them; the larger prime $q$ appeared in a denominator in **zero** cases; and even the smaller prime $p$ showed up only $40\%$ of the time — typically when $p$ was $2$ or $3$, which one knew already.

There is a structural reason the primes of $N$ are so shy. A prime $r \mid N$ divides a denominator only if the point becomes the identity modulo $r$ — but $r$ is a prime of *bad* reduction, so the fibre there is a singular cubic, and for squarefree $N$ it is a cuspidal cubic whose smooth part is the additive group. That group is uniquely $2$-divisible: it contains no element of order $2$, so a doubling orbit can never *reach* the identity there unless it started there. The factorisation of $N$ is not merely hidden; it is protected by the geometry of the bad fibre.

So the denominators of a Mordell curve do broadcast primes, prolifically, permanently, and with perfectly predictable multiplicities. They just broadcast the wrong ones. What the sequence of denominators knows is the arithmetic of the *point* — which good primes it happens to be congruent to zero at — and that data is a function of $N$ as a single number, not of its factorisation.

This is the shape of most factoring "near-misses". Something in the construction generates a rich stream of arithmetic information; a factor of $N$ would fall out if only the information were *about* $p$ and $q$; and a closer look reveals that the mechanism producing the information never consults the factorisation at all. Here that closer look is completely explicit: denominators are squares $e^2$; a prime divides $e$ exactly when the point vanishes modulo that prime; and vanishing modulo $\ell$ has nothing to do with $\ell$ dividing $\Delta$.

The daydream is over — but what replaces it is better than the guess. We now know exactly which primes appear in these denominators, exactly when they appear, exactly with what multiplicity, and exactly why they never go away. The intruder $7$ in $3136$ is not an anomaly to be explained away. It is the whole theory, visible in four digits.
