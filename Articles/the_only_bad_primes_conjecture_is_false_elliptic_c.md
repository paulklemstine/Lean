# The Prime That Shouldn't Be There

## How a single fraction refutes a tempting conjecture about elliptic curves — and why the fallout closes a door on a dream of factoring integers

### A curve, a point, and a doubling

Start with one of the oldest playgrounds in number theory: the **Mordell curves**
$$E_N : y^2 = x^3 + N,$$
one curve for each nonzero integer $N$. These are elliptic curves, which means they carry a
secret gift: their rational points form a group. Given two rational points you can *add* them
by drawing the line through them, finding the third intersection with the cubic, and
reflecting across the $x$-axis. Given one point $P$ you can *double* it by using the tangent
line instead. Out of one solution, you can manufacture infinitely many.

Take $N = 55$ and the point $P = (9, 28)$. It really is on the curve: $28^2 = 784$ and
$9^3 + 55 = 729 + 55 = 784$. Now double it. The tangent-line computation, specialised to the
Mordell family, gives a formula that is worth staring at:
$$x(2P) = \frac{x^4 - 8Nx}{4y^2}.$$
Plugging in $x = 9$, $y = 28$, $N = 55$:
$$x(2P) = \frac{6561 - 3960}{4 \cdot 784} = \frac{2601}{3136}.$$
The fraction is already in lowest terms — $2601 = 3^2 \cdot 17^2$ shares nothing with
$3136$. And now factor the denominator:
$$3136 = 2^6 \cdot 7^2.$$

There it is. A $7$.

### Why the 7 is a scandal

Every elliptic curve carries a number called its **discriminant**, which measures where the
curve degenerates. For $E_N$ it is
$$\Delta = -432\,N^2 = -2^4 \cdot 3^3 \cdot N^2 .$$
The primes dividing $\Delta$ are called the **bad primes** of the curve: for $E_N$ these are
$2$, $3$, and the primes dividing $N$. Everything unpleasant about the curve — the places
where reducing the equation modulo a prime destroys its smoothness — happens at bad primes.
For $N = 55 = 5 \cdot 11$, the bad primes are $\{2, 3, 5, 11\}$.

There is a very natural conjecture lurking here, and it has been floated more than once by
people hoping to turn elliptic curves into a factoring machine. It says: *when you double,
triple, and generally multiply an integral point $P$ on $E_N$, the denominators of the
$x$-coordinates $x(nP)$ are built only from bad primes.* If that were true, and if $N = pq$
were a semiprime with secret factors $p$ and $q$, then simply computing a few multiples of a
point and factoring their (small, structured) denominators would hand you $p$ and $q$. The
hardest problem in practical cryptography would fall to a page of arithmetic.

The number $7$ says no. It divides $3136$, the denominator of $x(2P)$, and it does not divide
$\Delta = -1306800 = -2^4 \cdot 3^3 \cdot 5^2 \cdot 11^2$. Seven is a prime of *good*
reduction — the curve $y^2 = x^3 + 55$ is perfectly smooth modulo $7$ — and yet it barges into
the denominator anyway. The conjecture is false, and it is false at the very first doubling of
a very small point on a very small curve.

### The mechanism: denominators are where points vanish

Once you see why, the counterexample stops looking like an accident and starts looking like a
law.

Reducing a rational point modulo a prime $\ell$ is like taking a photograph of it in the
finite field $\mathbb{F}_\ell$. A point with an $\ell$ in the denominator of its coordinates
is a point that has escaped the photograph: it has run off to the point at infinity, the
identity element $O$ of the group. So the statement "$\ell$ divides the denominator of
$x(nP)$" says exactly:
$$nP \equiv O \pmod{\ell},$$
that is, *the reduction of $P$ modulo $\ell$ is a point of order dividing $n$.*

This has nothing to do with whether $\ell$ is a bad prime. Reduce $P = (9,28)$ modulo $7$:
$y = 28 \equiv 0$, so the reduced point is $(2, 0)$, which sits on the $x$-axis. Points on the
$x$-axis are exactly the points of order $2$. Doubling a point of order $2$ gives the
identity. Hence $2P$ vanishes modulo $7$, hence $7$ appears in the denominator. The good
prime $7$ is not an intruder; it is doing precisely what the group law tells it to do.

And this can be made completely precise. For an integral point $(x,y)$ on $E_N$ with
$y \neq 0$ and any prime $\ell \geq 5$ that does not divide $N$:
$$\ell \mid \operatorname{den} x(2P) \iff \ell \mid y \iff x^3 + N \equiv 0 \pmod \ell .$$
The middle condition is the visible one; the right-hand one is the useful one, because it no
longer mentions $y$. Whether a good prime enters the denominator at the doubling layer is
decided by a single question: **is the reduction of $x$ a root of the cubic $T^3 + N$ over
$\mathbb{F}_\ell$?**

The excluded primes $2$ and $3$ are not a gap in the argument but a feature of the family: the
factor $-432 = -2^4 3^3$ in the discriminant is exactly the debris that the primes $2$ and $3$
leave behind.

### Counting the guilty classes

Now the story becomes combinatorial, and rather beautiful. Fix a prime $\ell \geq 5$ that does
not divide $N$, and ask how many residue classes $x \bmod \ell$ are "denominator-producing" —
how many roots the cubic $T^3 + N$ has in $\mathbb{F}_\ell$. Cubes in a finite field behave in
one of two ways, decided by $\ell$ modulo $3$:

- If $\ell \equiv 2 \pmod 3$, cubing is a *bijection* of $\mathbb{F}_\ell$. Every element has
  exactly one cube root, so $T^3 = -N$ has exactly **one** solution. There is always exactly
  one guilty class.
- If $\ell \equiv 1 \pmod 3$, the field contains a primitive cube root of unity $\omega$, and
  roots come in orbits $\{r, \omega r, \omega^2 r\}$ of size three. So the number of solutions
  is **$0$ or $3$** — never $1$, never $2$.

For $N = 55$ and $\ell = 7$ (which is $1 \bmod 3$), the guilty classes are $\{1, 2, 4\}$: their
cubes are $1, 8 \equiv 1, 64 \equiv 1$, and indeed $-55 \equiv 1 \pmod 7$. Our point had
$x = 9 \equiv 2 \pmod 7$ — one of the three. The counterexample was not luck; the point simply
landed in a set that occupies three sevenths of all residues.

For $\ell = 13$, by contrast, the cubes modulo $13$ are $\{0,1,5,8,12\}$ and $-55 \equiv 10$ is
not among them: **no** residue class produces a $13$ at the doubling layer, for *any* point on
$E_{55}$.

There is a clean averaging law behind the dichotomy. Summing the number of guilty classes over
all $\ell$ possible residues of $N$ modulo $\ell$ gives exactly $\ell$ — because each $x$ is
guilty for exactly one value of $N$, namely $N \equiv -x^3$. So the *average* number of
denominator-producing classes is exactly $1$, uniformly in $\ell$: the guilty set has density
exactly $1/\ell$, on average, at every prime. One can also count the other way: at an ordinary
prime $\ell \equiv 1 \pmod 3$, exactly $(\ell+2)/3$ of the residues $N \bmod \ell$ admit any
guilty class at all — about a third — while the remaining $2(\ell-1)/3$ are blind spots where
$-N$ is not a cube. At supersingular primes $\ell \equiv 2 \pmod 3$ there are no blind spots at
all.

That last remark has a striking consequence. For *every* $N$, every prime $\ell \equiv 2 \pmod
3$ is denominator-active: there is always some residue class of $x$ that pulls $\ell$ into a
denominator. By Dirichlet's theorem on primes in arithmetic progressions, half of all primes
are of this shape. **Infinitely many good primes — a set of density $1/2$ — can appear in the
denominators of a Mordell curve.** No finite list of bad primes was ever going to contain them.

### One layer up: tripling

Doubling is layer $2$ of a tower. Layer $3$ is tripling, and it comes with its own polynomial.
Applying the group law twice ($2P$, then $2P + P$) gives, for a rational point with $y \neq 0$
that is not $3$-torsion,
$$x(3P) = \frac{\varphi_3(x)}{\psi_3(x)^2}, \qquad
\psi_3(x) = 3x^4 + 12Nx = 3x\,(x^3 + 4N), \qquad
\varphi_3(x) = x^9 - 96Nx^6 + 48N^2x^3 + 64N^3.$$
Here $\psi_3$ is the third *division polynomial*: its roots are precisely the $x$-coordinates
of the points of order $3$.

For this to give a denominator criterion, the numerator must not conspire to cancel the
denominator. It does not, and the reason is charming. On the locus $x \equiv 0$ one computes
$\varphi_3 \equiv 64N^3$; on the locus $x^3 \equiv -4N$ one computes
$\varphi_3 \equiv -1728N^3$. And $64 = 2^6$, $1728 = 2^6 3^3$ — nothing but the primes $2$ and
$3$ again, the same debris as in the discriminant. So for any prime $\ell \geq 5$ not dividing
$N$, cancellation is impossible, and
$$\ell \mid \operatorname{den} x(3P) \iff \ell \mid \psi_3(x) = 3x(x^3 + 4N).$$

The counting changes in an interesting way. At a supersingular prime the layer-3 locus has
**two** classes: $x \equiv 0$ (always a root of $\psi_3$, whatever $N$ is) and the unique cube
root of $-4N$. Layer $2$ contributed one class, layer $3$ contributes two, and the three are
always distinct, so the two layers together account for exactly three residue classes — the
reductions that land on $2$-torsion or $3$-torsion. At an ordinary prime the layer-3 count is
$1$ or $4$. Averaged over $N$, layer $3$ contributes exactly $2 - 1/\ell$ classes, twice as
many as layer $2$ in the limit, and — unlike layer $2$ — it has **no blind spots at all**: the
free root $x \equiv 0$ makes every prime active for every $N$.

Our running example again: $\psi_3(9) = 3 \cdot 9^4 + 12 \cdot 55 \cdot 9 = 25623 = 3^3 \cdot
13 \cdot 73$. Sure enough, the denominator of $x(3P)$ for $N = 55$ is
$3^6 \cdot 13^2 \cdot 73^2$. The good primes $13$ and $73$ appear; the bad primes $5$ and $11$
— the very factors of $N$ we were hoping to read off — do not appear at all. And notice that
$13$ was *blind* at layer $2$: each layer has its own polynomial and its own guilty classes.

One can even show that *every* prime $\ell \geq 5$ arises this way, with good reduction. Take
$N = 1 - \ell^3$ and the point $P = (\ell, 1)$, which lies on $E_N$ since $1 = \ell^3 + N$.
Then $N \equiv 1 \pmod \ell$, so $\ell$ does not divide $\Delta$, and $\psi_3(\ell) = 3\ell(\ell^3 + 4N)$
is divisible by $\ell$, so $\ell$ divides the denominator of $x(3P)$. Not a single prime above
$3$ is innocent.

### The door that closes

So denominators are full of good primes. Does that mean they are full of *information*? If a
denominator can contain any prime, might it not — sometimes, somewhere — contain the secret
factor $p$ of a semiprime $N = pq$?

Empirically, the answer is discouraging. A survey of eleven semiprimes $N = pq$ with a small
integral point, tracking the primes appearing in the denominators of the first several
multiples, found that the smaller factor $p$ turned up about $54.5\%$ of the time, the larger
factor $q$ turned up **never**, and the "only bad primes" pattern held in **none** of the
cases. The denominators are dominated by large, essentially random good primes.

But one can do far better than a survey, and this is the sharpest result of the story. Look
again at the two criteria:
$$\ell \mid x^3 + N \qquad\text{and}\qquad \ell \mid 3x^4 + 12Nx .$$
Both are congruences whose only dependence on $N$ is through the residue $N \bmod \ell$. So
if two integers $N$ and $M$ agree modulo $\ell$, their denominator behaviour at $\ell$ — at
both layers, for every $x$ — is *literally identical*.

Now suppose you are trying to factor a semiprime $N = pq$ by collecting denominator data at
every prime $\ell$ up to some bound $B$, with $p$ and $q$ both larger than $B$. All that data
depends on $N$ only through its residues modulo the primes $\ell \leq B$ — that is, through
$N$ modulo $B!$. Since $p, q > B$, the number $N$ is invertible modulo $B!$, and Dirichlet's
theorem supplies infinitely many **primes** in the arithmetic progression $N \bmod B!$. Choose
one of them, call it $M$, larger than $N$. Then:

> **The barrier.** For every bound $B$ and every semiprime $N = pq$ with $p, q > B$, there is a
> prime $M > N$ such that for every prime $\ell \leq B$ and every integer $x$, the layer-2
> criterion $\ell \mid x^3 + N$ and the layer-3 criterion $\ell \mid 3x^4 + 12Nx$ hold for the
> curve $E_N$ exactly when they hold for the curve $E_M$.

The entire denominator profile below $B$, at the doubling and tripling layers, is the same for
the semiprime $N$ and for the prime $M$. Data that cannot even distinguish a composite from a
prime certainly cannot factor the composite. Any attack of this kind must test primes $\ell$
comparable in size to the factors themselves — at which point trial division has already won.

Try it: $N = 17 \cdot 19 = 323$ and $B = 13$. The number $M = 6\,227\,021\,123$ is prime and
congruent to $323$ modulo $13! = 6\,227\,020\,800$. At $\ell = 5$ both have the single guilty
class $\{3\}$; at $\ell = 7$ both have $\{3,5,6\}$; at $\ell = 11$ both have $\{6\}$; at
$\ell = 13$ both are blind. Every criterion agrees, prime for prime.

### What the story is really about

It is easy to read this as a negative result — a conjecture refuted, a factoring dream
dispatched. It is more interesting to read it as a piece of local-global bookkeeping done
right.

Denominators of rational points look like an arithmetic accident. They are not. They are a
faithful record of *where the point disappears*: which finite fields see it collapse onto the
identity. The bad primes of a curve are the primes where the geometry breaks; the denominators
of $x(nP)$ are governed by an entirely different question — where the *point* reduces to
torsion — and that question is answered, layer by layer, by the division polynomials
$\psi_n$. Layer $2$ asks whether $T^3 + N$ has a root; layer $3$ asks whether $3T(T^3+4N)$
does. The counts obey the arithmetic of cubes in finite fields: one root or a clean $0$-or-$3$,
with an exact average of one per prime.

And the reason those denominators are useless for factoring is the very reason they are so
clean: the criteria are *local*. Each prime $\ell$ sees $N$ only through $N \bmod \ell$, and
a residue class knows nothing about factorisation. That is what the barrier theorem makes
precise. Elliptic curves do, of course, factor integers — Lenstra's elliptic curve method is
one of the great algorithms of the subject — but it works by *choosing curves at random* and
hunting for a prime at which the group order is smooth, information that is invisible in any
fixed low-order denominator. The bookkeeping done here explains, in exact terms, why the naive
route was never going to work.

There is one loose thread worth pulling. Layers $2$ and $3$ are settled; the tower continues.
For every $n$ there is a division polynomial $\psi_n$, and the same argument should give
$\ell \mid \operatorname{den} x(nP) \iff \ell \mid \psi_n(x)$ for good primes $\ell \geq 5$,
with the exceptional numerator values again built only from $2$ and $3$. If so, the barrier
persists at every layer, and the number of guilty residue classes grows like $n^2/2$ — the
degree of $\psi_n$ — with a distribution governed, one expects, by Chebotarev's density theorem
applied to the $n$-division field of the curve. That is a story about Galois groups, and it is
the next chapter.

For now, the moral fits on a postcard. A prime showed up where it wasn't invited, and
following it carefully turned a false conjecture into an exact counting law, and an exact
counting law into a proof that a whole family of attacks can never work.
