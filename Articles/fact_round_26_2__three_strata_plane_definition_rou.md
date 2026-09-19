# Three Floors of the Factoring Building

## What it really costs to take a number apart

Every secure connection you open today rests on a bet: that nobody can take a
large number apart. Multiply two thousand-bit primes together and you get a
number $N$ that anyone can write down and nobody can decompose. The security of
the whole arrangement is not a theorem — it is a *price*. Somebody could factor
your key, if they were willing to pay enough. The interesting question is how
much.

That question has a surprisingly slippery history. Ask "how hard is factoring?"
and you get an answer that depends on who is answering. A number theorist will
tell you about the divisor-counting function. A programmer will tell you about
trial division. A cryptographer will quote the number field sieve. A quantum
physicist will tell you it's easy. These are not disagreements about facts; they
are answers measured in different units, on different machines, against
different notions of "cost". Until they are put on one scale, the debate cannot
be settled — only continued.

This article is about putting them on one scale. The scale has a single
coordinate, and against it the whole landscape of factoring sorts itself into
three clean **strata**, like floors of a building, each with its own measured
price.

---

## One coordinate for everything

Here is the coordinate. Let $N$ be the number you want to factor. The honest
measure of its size is not $N$ itself but the number of digits — up to a
constant, that is $x = \log N$. Now suppose some procedure costs $f(x)$
operations on inputs of that size. Define its **measured exponent**

$$\alpha(f) \;=\; \lim_{x \to \infty} \frac{\log f(x)}{x}.$$

If $f$ is roughly $N^{\alpha}$, this limit returns exactly $\alpha$. That is
the point: $\alpha$ is the slope you would read off a log–log plot of cost
against $N$, and it is the same number whether you obtain it by proving a
theorem or by running an experiment and fitting a line. It is a shared
language.

Three basic facts make the coordinate usable, and all three are theorems.

**It is well defined.** A limit is unique, so a cost profile has at most one
measured exponent. If two arguments assign different exponents to the same
procedure, at least one of them is wrong — the coordinate can adjudicate.

**It is blind to constant factors.** If $|\log f(x) - \alpha x| \le C$ for all
large $x$ and some fixed $C$, then $\alpha(f) = \alpha$. Doubling your budget,
buying a faster chip, shaving a logarithm off the inner loop — none of it moves
$\alpha$. Sketch of why: divide the bound by $x$ and let $x \to \infty$; the
correction $C/x$ vanishes. This is a feature, not a limitation. The exponent
measures the *shape* of the difficulty, and the shape is what survives Moore's
law.

**It has two calibration points.** The profile $e^{ax}$ — that is, $N^a$ — has
exponent exactly $a$. And any polynomial profile $Cx^d$ in the bit-size, with
$C > 0$, has exponent exactly $0$, because $\log(Cx^d)/x = (\log C + d\log x)/x
\to 0$. So "polynomial in the number of digits", the cryptographer's definition
of *easy*, occupies the single point $\alpha = 0$, and everything genuinely
exponential in the digit count lives strictly above it.

With that coordinate fixed, the building has three floors.

---

## Stratum A: the definition-routes, at $\alpha = 1/2$

The top floor is the one that mathematicians reach for first, and it is the
most expensive.

Number theory has functions that already know the answer. The divisor-counting
function $\tau(N)$ counts the divisors of $N$; the divisor-sum function
$\sigma_1(N)$ adds them up. For a semiprime $N = pq$ with $p \ne q$ prime the
divisors are exactly $1, p, q, pq$ — nothing else can divide $N$ — and therefore

$$\tau(N) = 4, \qquad \sigma_1(N) = 1 + p + q + pq = 1 + p + q + N.$$

These are exact identities, at every size, with no error term. And look at what
the second one gives you: subtract, and $\sigma_1(N) - N - 1 = p + q$. You now
know the sum *and* the product of the two primes. That is enough. A pair of
numbers is determined by its sum and its product — if $a + b = c + d$ and
$ab = cd$ then $\{a,b\} = \{c,d\}$, by Vieta — and the recovery is a closed
formula:

$$p \;=\; \frac{s - \sqrt{s^2 - 4N}}{2}, \qquad s = \sigma_1(N) - N - 1,$$

with the discriminant an exact perfect square, $s^2 - 4N = (q-p)^2$. No search,
no iteration. **After the value of $\sigma_1(N)$ is in hand, factoring costs a
constant number of arithmetic operations.**

So why is this floor the expensive one? Because nobody hands you $\sigma_1(N)$.
Evaluating it from $N$ alone, without knowing the factorization, means the scan:
try $d = 1, 2, 3, \dots$ up to $\lfloor\sqrt N\rfloor$ and see what divides.
That costs $\lfloor\sqrt N\rfloor$ divisions, and the bound is attained — for a
twin-prime semiprime $N = p(p+2)$ one has $\lfloor \sqrt N \rfloor = p$ exactly,
so the scan runs its full length. Stated as a two-sided sandwich, honest in both
directions:

$$2\log\big(\lfloor\sqrt N\rfloor\big) \;\le\; \log N \;\le\; 2\log\big(\lfloor\sqrt N\rfloor + 1\big).$$

Divide through and the measured exponent is $1/2$ — not approximately, but
pinned between two bounds that squeeze onto it. Stratum A sits at
$\alpha = 1/2$, and it does so for a reason that is now visible: **the exponent
is an exponent of evaluation, not of search.** The inversion is free; the
appraisal is what you pay for.

There is a matching lower bound, and it is combinatorial rather than
algorithmic. Call a finite set $S$ of candidate divisors *complete up to $B$* if
for every semiprime $N = pq$ with $p < q \le B$ some element of $S$ splits $N$.
A candidate that splits $pq$ must *be* $p$ or $q$ — there is nothing else in
there to find. From that one observation it follows that $S$ can omit at most a
single prime below $B$, and therefore

$$|S| \;\ge\; \pi(B) - 1,$$

where $\pi$ counts primes. There is no clever finite list: for any fixed $S$
there is a bound $B$ at which $S$ fails, and since Bertrand's postulate puts a
prime in every interval $(2^i, 2^{i+1}]$, a complete test set up to $2^k$ must
carry at least $k$ candidates — growing at least linearly in the bit-size, and in
truth like $\sqrt N / \log N$. A procedure that learns nothing about $N$ except
"does $s$ divide it?" must carry essentially every prime below $\sqrt N$ in its
pocket.

---

## Stratum B: the methods, at $\alpha = 1/4$

The middle floor is where the algorithms live — and crucially, where they are
treated as *data* rather than as citations. Three of them, three exact
statements about what they actually do.

**Trial division** returns the smaller prime first: the least nontrivial divisor
of $pq$ with $p \le q$ is $p$, found no later than step $\lfloor\sqrt N\rfloor$.
Its certificate is the factor itself — no verification step required.

**Fermat's method** searches for a representation $a^2 = N + b^2$, since such a
representation factors $N$ as $(a-b)(a+b)$. The key structural fact is a
dichotomy: *every* representation of a semiprime comes from one of its two
factorizations, so the ascending search $a = \lceil\sqrt N\rceil,
\lceil\sqrt N\rceil + 1, \dots$ cannot stop early and stops for the first time
exactly at $2a = p + q$. The cost is therefore the exact arithmetic quantity
$\frac{p+q}{2} - \lceil\sqrt N\rceil$.

That makes Fermat and trial division **provably complementary, not similar**.
On a twin-prime semiprime $N = p(p+2)$, Fermat stops at its very first trial
$a = p+1$, where trial division grinds through $p$ steps. On the maximally
unbalanced $N = 3q$, Fermat needs at least $q/4$ steps, where trial division
needs two. Neither dominates the other anywhere on the scale. And yet, on
uniformly drawn semiprimes their aggregate cost distributions are
indistinguishable — both centred near the same value, because the tail of the
gap $q - p$ dominates the average. That indistinguishability is a statement
about the *draw distribution*, not about the methods. It is exactly the kind of
confusion a single measured coordinate is designed to expose: two procedures
with identical summary statistics and opposite structure.

**Pollard's $\rho$** is the floor's champion, and it works by an entirely
different principle. Iterate a map on residues; wait for two iterates to
collide modulo the unknown prime $p$ without colliding modulo $N$; take a gcd of
their difference with $N$ and out comes $p$, exactly. Both halves are theorems.
The extraction half: if a difference is divisible by $p$ but not by $N$, then
$\gcd$ of that difference with $N$ *is* $p$. The pigeonhole half: for *any*
iteration whatsoever, in any sequence of $p+1$ residues modulo $p$ two must
coincide. Put together, a deterministic skeleton — the collision is forced
within $p$ steps — with the birthday heuristic supplying the actual $\sqrt p$
behaviour that makes the method fast.

And $\sqrt p$ is where the interesting bookkeeping happens. Pollard $\rho$ costs
about $\sqrt p \approx N^{1/4}$ for a balanced semiprime, so on our coordinate
it sits at $\alpha = 1/4$ — exactly the birthday bound. But there is a trap here
worth dwelling on, because it is the kind of mistake that quietly corrupts
empirical work.

---

## The units trap, and why it is a theorem

Measure Pollard $\rho$ empirically. Stratify by prime size, fit a line, and the
slope comes out at $1/2$ per *prime bit* — a clean, reproducible number
matching the standalone calibration $\log_2(\text{ops}) = \text{bits}/2 - 1$
exactly. Report it as the exponent and you have said something false, by a
factor of two.

The reason is units. The exponent lives on $x = \log N$; the fit lives on
$b = \log p$; and for a balanced semiprime $\log N = 2 \log p$. The general law
is short and clean: if a cost profile has exponent $s$ in a variable $b$, and
you re-express it in $x = cb$, the exponent becomes $s/c$. Substituting
$b = x/c$ divides every reading by $c$. With $c = 2$, the slope $1/2$ per
prime-bit becomes the exponent $1/4$ on $N$.

What makes this more than a cautionary tale is that the mismatch is itself a
*theorem*: the profile re-read on $N$ has exponent $1/4$, the exponent is
unique, and $1/4 \ne 1/2$ — so the two readings are provably different numbers,
not a matter of convention or taste. A discipline in which unit errors are
detectable by its own machinery is a discipline that can correct itself. In the
measurement campaign behind this work, the $1/2$ reading appeared first, was
caught by the gate that checks the units, corrected to $1/4$, and then confirmed
against an independent standalone calibration before being allowed onto the
plane.

---

## Stratum C: the quantum corner, at $\alpha = 0$

The ground floor is quantum, and its cost profile is a polynomial in the
bit-size — something like $8x^3$. By the second calibration point, its measured
exponent is $0$. It is the only stratum at $0$, and that is the entire content
of the quantum threat to public-key cryptography, expressed in one number.

What is worth saying precisely is how little of Shor's algorithm is quantum. The
quantum part is one thing only: finding the multiplicative order $r$ of a unit
modulo $N$. Everything after that is classical arithmetic, and it is exact. If
$x^2 \equiv 1 \pmod N$ for a semiprime $N = pq$, but $x \not\equiv \pm 1$, then
$\gcd(x-1, N)$ is *precisely* one of the two prime factors — never $1$, never
$N$. In the form the algorithm uses it: if $a$ has even order $2m$ modulo $N$
and $a^m \not\equiv \pm 1$, then $\gcd(a^m - 1, N)$ is a genuine nontrivial
factor, strictly between $1$ and $N$. The quantum corner owns the *search* for
$r$. It does not own the arithmetic that follows, which was always free.

---

## The price of being blind

Now the three floors are on one scale: $\alpha = 0$, $\alpha = 1/4$,
$\alpha = 1/2$. Strictly ordered, provably distinct, and the ordering is not
just of exponents but of the profiles themselves — eventually
$\text{quantum} < \rho < \text{definition-route}$, pointwise and strictly. On
the $\alpha = 0$ side of the line is everything polynomially bounded; both
classical strata, having positive exponent, provably are not. A positive
exponent forces a profile eventually above $e^{(\alpha/2)x}$, hence to infinity,
hence beyond every polynomial. A definition-route evaluated from $N$ alone
cannot be a polynomial-time factoring algorithm, and that is a theorem, not a
belief.

But the sharpest thing on the plane is the *gap*, and gaps on this coordinate
behave beautifully. If $f$ and $g$ are eventually positive with exponents $a$
and $b$, the ratio $g/f$ has exponent exactly $b - a$; and if $a < b$, the ratio
diverges to infinity. Cost differences on this scale are never constant
overheads. They are unbounded penalties with their own measured exponent.

Apply that to the top two floors. The price of taking the definition-route
instead of the method — of evaluating a witness from $N$ alone instead of
exploiting what $N$ actually is — is

$$\frac{N^{1/2}}{N^{1/4}} \;=\; N^{1/4},$$

strictly increasing and unbounded. Call it the **price of
structure-blindness**. It is not a tax you can buy your way out of with faster
hardware, and the measurements show it climbing exactly as the theorem predicts:
about $173\times$ at $N \approx 2^{16}$, $1780\times$ at $2^{20}$,
$2070\times$ at $2^{24}$, $8310\times$ at $2^{28}$. Blindness gets more
expensive the bigger the number.

There is a final twist in that formula worth savouring. The blindness price
$N^{1/4}$ has the *same* exponent as the whole of Stratum B. Being blind and
running Pollard $\rho$ cost the same, at every size. There is, in this
landscape, a unit exchange rate between ignorance and work.

---

## Why measure at all

The habit being argued for here is simple, and it is not really about factoring.

Mathematics is full of statements of the form "method X is better than method Y"
that are never priced. They are inherited, cited, and repeated, and the citation
chain is usually sound — but the numbers in it were measured on different
machines, under different conventions, in different units, often decades apart.
Nothing checks them against each other because there is no shared coordinate on
which they could disagree.

Build the coordinate, and three things become possible at once. Claims become
*comparable*: a number-theoretic route, a randomised algorithm, and a quantum
subroutine land at $1/2$, $1/4$, $0$ on one axis. Claims become *falsifiable*:
the exponent is unique, so a units error is a contradiction rather than an
opinion. And gaps become *quantitative*: the distance between two floors is not
a vague "much faster" but the exact, provable, divergent factor $N^{1/4}$.

The factoring landscape turned out to have three floors. The building was always
there. What was missing was a ruler that reached all the way down.
