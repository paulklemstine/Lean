# The Number That Refuses to Talk About Itself

## A closed corner in the search for hidden structure in factorization

There is a particular kind of frustration that only shows up in number theory.
You have an integer $N$. You know — because you built it that way — that it is
the product of two large primes, $N = pq$. Every bit of information about $p$
and $q$ is *in there*, encoded perfectly, unambiguously. And yet the integer
sits on the page like a stone, telling you nothing.

So you try to make it talk. You poke it. You take $N+1$, or $N-1$, or $N^2+1$.
You factor those instead. Surely, you think, some shadow of $p$ and $q$ must
fall across these neighbours — after all, they are only one step away from $N$.

This article is about why that hope is not merely unfulfilled, but
*mathematically prohibited*, and about the exact shape of the prohibition. The
punchline is a classification theorem: we can say precisely which "derived
moduli" are capable of leaking a factor, precisely which are not, and — this is
the satisfying part — the dividing line is a single number, the constant term.

---

## Derived moduli: the idea

Fix a polynomial $f$ with integer coefficients. Feed it your semiprime. The
output
$$M = f(N)$$
is what we will call a **derived modulus**. The natural candidates are the ones
anybody would try first:
$$N-1,\quad N+1,\quad N^2+1,\quad N^2+N+1,\quad 2N-1,\quad 2N+1 .$$
The third-from-last is the third cyclotomic polynomial $\Phi_3(N)$, which has a
distinguished pedigree: it is the polynomial whose roots are the primitive cube
roots of unity, and it shows up all over algebraic number theory. If any
"nearby" modulus were going to be arithmetically informative, one of these six
would be it.

The hope is concrete and testable. Compute some invariant of $M$ — its least
prime factor, its number of prime factors, its class number, whatever — and ask
whether that number correlates with something about the factorization of $N$:
with $p$ itself, with $p+q$, or, most tellingly, with the *gap* $|p-q|$.

Why the gap? Because $p+q$ and $p$ are both roughly determined by $N$: for a
balanced semiprime, $p \approx \sqrt N$, so any statistic that merely tracks the
size of $N$ will look correlated with $p$ across a wide batch of test cases.
That correlation is an illusion — a confound. The gap $|p-q|$ is the honest
coordinate: it varies *within* the fiber of semiprimes of a given size. If a
derived-modulus invariant contains genuine factor information, it must move with
$|p-q|$.

It does not. Across the tested batches, the correlation between derived-modulus
invariants and $|p-q|$ sits comfortably inside the permutation null — the
distribution you get by shuffling the labels at random. Observed correlations
topped out around $0.26$; the 95th percentile of the null was $0.29$–$0.31$. The
signal is indistinguishable from noise. Meanwhile the correlation with $N$
itself was enormous, $0.66$ to $0.95$: the invariant is a function of $N$, and
of nothing finer.

The rest of this article explains why that had to happen.

---

## One line of algebra

Here is the entire mechanism, and it fits on one line. For any polynomial $f$
with integer coefficients and any integers $a, b$,
$$a - b \ \big|\ f(a) - f(b).$$
This is the most elementary fact about polynomials over $\mathbb{Z}$: expand
$f(a) - f(b)$ term by term and factor $a^k - b^k = (a-b)(a^{k-1} + \cdots +
b^{k-1})$ out of each piece.

Now set $b = 0$. You get
$$N \ \big|\ f(N) - f(0).$$

Stare at that for a second, because everything follows. The derived modulus
$f(N)$ and the original $N$ differ, modulo $N$, by exactly the constant term
$f(0)$. So whatever the two of them share, they shared it before $N$ ever
entered the picture:

> **Frozen-Overlap Theorem.** For every integer polynomial $f$ and every integer
> $N$,
> $$\gcd\bigl(N,\ f(N)\bigr) = \gcd\bigl(N,\ f(0)\bigr).$$

The proof is immediate: any common divisor of $N$ and $f(N)$ divides $f(N) -
(f(N) - f(0)) = f(0)$, and conversely. The overlap between a number and its
polynomial derived modulus is *frozen at the constant term*, uniformly in $N$.
It does not know that $N$ is a semiprime. It does not know $p$. It does not
grow, drift, or fluctuate. It is a constant of the apparatus.

For our six candidates, $f(0) = -1$ or $+1$ in every case. Hence:

> $\gcd(N, N-1) = \gcd(N, N+1) = \gcd(N, N^2+1) = \gcd(N, N^2+N+1) =
> \gcd(N, 2N \pm 1) = 1$ for **every** integer $N$. No exceptions, no "generic
> $N$" caveat.

The experiment's first empirical finding — the derived moduli share nothing with
$N$ — is not a statistical observation. It is a theorem with a two-line proof.

---

## The exact dividing line: transparency

The one-line argument suggests a definition. Call a polynomial $f$
**transparent** if its constant term is a unit, $f(0) = \pm 1$. The claim is
that transparency is *exactly* the condition for invisibility:

> **Classification of Transparent Moduli.** For an integer polynomial $f$, the
> derived modulus $f(N)$ is coprime to $N$ for *every* integer $N$ if and only
> if $f(0) = \pm 1$.

One direction is the frozen-overlap theorem. The other direction is what makes
this a classification rather than a one-sided barrier, and it is charming: if
$f$ is *not* transparent, we can name the $N$ that betrays it. If $f(0) = 0$,
take $N = 2$; then $2 \mid f(2) - f(0) = f(2)$, so the gcd is at least $2$. If
$f(0) \neq 0$ and $|f(0)| \geq 2$, let $r$ be the smallest prime dividing
$f(0)$, and take $N = r$. Then $r \mid f(r) - f(0)$ and $r \mid f(0)$, so
$r \mid f(r)$, and $\gcd(r, f(r)) \geq r > 1$.

Note what the counterexample looks like. The leak happens at $N = r$, a prime
divisor of $f(0)$ — a *finite, known-in-advance* list of bad inputs, computable
from $f$ alone, with no reference whatsoever to the factorization of $N$. Even
the failure of the barrier is uninformative.

---

## Closing the loophole: no combination escapes

At this point a skeptic has an obvious move. Fine, they say: each of your six
moduli individually is transparent. But what about *combinations*? Multiply them
together. Substitute $N \mapsto 2N$ first, or $N \mapsto N^k$. Iterate. Surely
somewhere in that infinite zoo of constructions there is one that sees a factor.

There is not, and the reason is structural: transparency is preserved by exactly
the operations the skeptic has available.

> **Closure Theorem.** The transparent polynomials form a multiplicative monoid:
> $1$ is transparent, and if $f$ and $g$ are transparent so is $fg$ (because
> $(fg)(0) = f(0)g(0) = \pm 1$). Moreover, if $f$ is transparent and $g$ is any
> polynomial with zero constant term, then $f \circ g$ is transparent (because
> $(f\circ g)(0) = f(g(0)) = f(0)$).

Products, arbitrary finite products, and substitutions $N \mapsto 2N$,
$N \mapsto N^k$, $N \mapsto N^2 + N$ — all of them stay inside the transparent
monoid. Consequently:

> Every modulus obtained from the six by taking products and substituting any
> constant-term-free polynomial is coprime to $N$ for every $N$. In particular
> the "everything at once" modulus
> $$(N-1)(N+1)(N^2+1)(N^2+N+1)(2N-1)(2N+1)$$
> is coprime to $N$ for every integer $N$, and so is any iterate such as
> $(2N)^2+1$.

There is even a clean composition law that makes this transparent (so to speak):
$$\gcd\bigl(N,\ f(g(N))\bigr) = \gcd\bigl(N,\ f(g(0))\bigr).$$
The whole overlap is decided by the two constants $g(0)$ and $f$ evaluated
there. The corner is closed.

---

## Two moduli are no better than one

Another natural hope: maybe no single derived modulus helps, but two of them
*jointly* pin down something. Compare $N^2+1$ and $\Phi_3(N)$; look at what they
have in common; extract a signal from the cross-talk.

Here classical elimination theory delivers a crisp answer, via the **resultant**
$\mathrm{Res}(f,g)$ — the determinant of the Sylvester matrix of $f$ and $g$,
which is nonzero exactly when $f$ and $g$ have no common root. The key fact is
the Sylvester–Bézout identity: there exist integer polynomials $u, v$ with
$$u(X) f(X) + v(X) g(X) = \mathrm{Res}(f,g),$$
a *constant*. Evaluate at $N$:

> **Resultant Law.** For integer polynomials $f, g$, not both constant, and
> every integer $N$,
> $$\gcd\bigl(f(N),\ g(N)\bigr) \ \big|\ \mathrm{Res}(f,g).$$
> Hence the overlap of any two polynomial derived moduli is bounded by a
> constant depending only on the pair of polynomials, never on $N$.

For the six candidates the resultants are tiny. Any two distinct members of the
family share a factor of at most $7$, for every integer $N$ — and the bounds are
sharp: $\gcd(2^2+1,\ 2\cdot 2+1) = 5$ at $N=2$, and $\gcd(4-1,\ 4^2+4+1) = 3$ at
$N=4$. Extend this to a whole finite family and you get a single constant $B$
bounding every pairwise overlap for every $N$. A multi-modulus attack has
$O(1)$ shared arithmetic to work with, uniformly in $N$. There is nothing there
to amplify.

---

## The spectrum belongs to the apparatus, not the state

The sharpest and prettiest result is of a completely different flavour. Forget
gcds. Ask instead: *which primes can ever appear* in a derived modulus?

> **Spectrum Theorem.** For a prime $p$:
> - $p$ divides $N^2+1$ for some integer $N$ $\iff$ $p = 2$ or $p \equiv 1
>   \pmod 4$;
> - $p$ divides $N^2+N+1$ for some integer $N$ $\iff$ $p = 3$ or $p \equiv 1
>   \pmod 3$.

The forward directions are order computations. If $p \mid N^2+1$ with $p$ odd,
then $N^2 \equiv -1$, so $N^4 \equiv 1$ and $N^2 \not\equiv 1$: the
multiplicative order of $N$ modulo $p$ is exactly $4$, so $4 \mid p-1$. Same
argument mod $3$: if $p \mid N^2+N+1$ and $p \neq 3$, then $N^3 \equiv 1$ and
$N \not\equiv 1$, so the order is exactly $3$ and $3 \mid p-1$. The converses are
existence statements from the theory of cyclotomic fields: a prime $\equiv 1
\bmod 4$ has a square root of $-1$; a prime $\equiv 1 \bmod 3$ has a primitive
cube root of unity.

These two sets are the **split primes** of $\mathbb{Q}(i)$ and
$\mathbb{Q}(\zeta_3)$ respectively. And here is what matters: they are *fixed
sets*. The prime spectrum of the modulus $N^2+1$, as $N$ ranges over all
integers, is one and the same arithmetic progression, determined by the
polynomial and nothing else.

If you like the physics analogy — and this whole story has one — the derived
modulus is an **observable** whose spectrum is a property of the *apparatus*
(the polynomial $f$), never of the *state* (the number $N$). It is a
superselection rule. You cannot resolve the internal degeneracy of $N$ — its
factorization fiber — using an operator that lives in the algebra generated by
$N$ itself.

The rule has a striking cryptographic consequence. A **Blum integer** is a
semiprime $N = pq$ with $p \equiv q \equiv 3 \pmod 4$ — a standard choice in
cryptography. By the spectrum theorem, such a $p$ can never divide $M^2 + 1$ for
*any* integer $M$ whatsoever. The factors of a Blum integer are excluded from
the modulus $N^2+1$ by pure congruence, an obstruction of a completely different
nature from the gcd barrier, and a strictly stronger one.

---

## Why factoring the derived modulus doesn't help either

There is one more escape route to seal. Suppose you actually factor $M = N^2+1$
completely. That's a hard computation, but suppose you do it. You now hold a
list of large primes. Do they help?

No, and for two reasons that fit together perfectly.

**They are fresh.** A Euclid-style argument shows the prime support is infinite:
given any finite set $S$ of primes, one can produce an $N$ for which $f(N)$ has
a prime factor outside $S$ (build $N$ divisible by everything in $S$; then
$f(N) \equiv f(0) = \pm 1$ modulo each of them, so none of them divides $f(N)$,
while $|f(N)| > 1$ forces a new prime). So factoring derived moduli requires
primes of unbounded size — the derived problem is not easier, it is a *fresh*
factorization problem of comparable difficulty.

**They are useless.** By the very same congruence $f(N) \equiv f(0) \bmod N$,
any prime $q$ dividing $f(N)$ for a transparent $f$ does *not* divide $N$.

Together: the prime support of $N^2+1$ is infinite, and no prime in it ever
divides the corresponding $N$. You do hard work; you get primes; the primes are
guaranteed to be the wrong ones.

And a final degeneracy, almost comic in its bluntness: for odd $N$, both $N-1$
and $N+1$ are even, so the "least prime factor" invariant of either is $2$ —
constant on the entire input class, carrying exactly zero bits. Even $N^2+1$
suffers: for odd $N$ one has $N^2+1 \equiv 2 \pmod 8$, so again the least prime
factor is $2$ and the $2$-adic valuation is exactly $1$. Three of the six
"invariants" were constants all along.

---

## Where the barrier ends

A no-go theorem is only as interesting as its boundary. So: what property of
polynomials is actually doing the work?

Exactly one. Call a map $F : \mathbb{Z} \to \mathbb{Z}$ **congruence-
transporting** if
$$a \equiv b \pmod m \ \Longrightarrow\ F(a) \equiv F(b) \pmod m,$$
equivalently $a - b \mid F(a) - F(b)$. Polynomials transport congruences; so do
sums, differences, products, and *compositions* of transporting maps — they form
a subring of $\mathbb{Z}^{\mathbb{Z}}$ closed under composition. And the whole
story above holds verbatim for this class:

> **Transport Barrier.** If $F$ transports congruences then $\gcd(N, F(N)) =
> \gcd(N, F(0))$ for every $N$, and $F(N)$ is coprime to $N$ for every $N$ if
> and only if $F(0) = \pm 1$.

Now the punchline. Consider the **exponential** modulus $F(N) = 2^N - 1$. Is it
in the class? No: $6 - 0 = 6$ does not divide $F(6) - F(0) = 63 - 0 = 63$. And
the barrier genuinely fails outside the class:

- Every multiple of $6$ shares the prime $3$ with $2^N - 1$, so infinitely many
  $N$ satisfy $\gcd(N, 2^N-1) > 1$ — compare with the polynomial case, where
  only finitely many primes can *ever* be shared.
- Better: $\gcd(253,\ 2^{253} - 1) = 23$, and $253 = 11 \cdot 23$. The
  exponential derived modulus **factors the semiprime**.

The mechanism is transparent once you see it: $p \mid 2^N - 1$ exactly when the
multiplicative order of $2$ modulo $p$ divides $N$. For $p = 23$ that order is
$11$, and $11 \mid 253$. So the exponential modulus leaks precisely when a
factor's order happens to divide $N$ — an event with no polynomial analogue,
because it depends on $N$'s *value* rather than on its residue.

This is not a factoring algorithm — the "leaky" $N$ form a sparse, structured
set. But it is exactly what a sharp no-go theorem needs: proof that the
polynomial hypothesis is doing real work.

---

## The frontier, measured

If derived moduli cannot help, what *could*? Only an **external hint**: a number
$h$, supplied from outside, that happens to share a prime with $N$. Then
$\gcd(N, h)$ hands you a factor.

How lucky do you need to be? Among the $pq$ residues
$h \in \{0, 1, \dots, N-1\}$, precisely
$$p + q - 1$$
share a prime with $N = pq$ — that is, $N$ minus Euler's totient
$\varphi(N) = (p-1)(q-1)$. Everything else returns $\gcd = 1$. If both prime
factors exceed $B$, the density of useful hints is
$$\frac{p+q-1}{pq} \ \leq\ \frac{2}{B},$$
which for cryptographic sizes is astronomically small. The gcd attack has
exactly four possible outcomes — $1$, $p$, $q$, or $N$ — and returns $p$ exactly
when $p \mid h$ and $q \nmid h$; the full factorization then follows as
$q = N/\gcd(N,h)$.

Derived moduli, we have proven, always land on the useless side of this
frontier. They are not unlucky hints; they are *guaranteed-trivial* hints, by
theorem, for every $N$ at once.

---

## What was actually learned

The experiment set out to test a hypothesis and refuted it. That is a good day's
work, but the refutation turned out to be far more interesting than a negative
statistical result, because the mathematics behind it is an exact classification
rather than a heuristic barrier:

1. A polynomial derived modulus is universally invisible to $N$ **iff** its
   constant term is a unit — and when it isn't, the leak occurs at an explicit,
   factorization-independent list of inputs.
2. The invisible polynomials form a monoid closed under products and
   substitution, so no combination of derived moduli escapes.
3. Any two derived moduli overlap in a divisor of their resultant: a constant,
   uniform in $N$.
4. The prime spectrum of a derived modulus is a fixed set of split primes
   determined by the polynomial's splitting field — a property of the apparatus,
   not the state.
5. The barrier holds for every congruence-transporting map and provably fails
   just outside that class, witnessed by $\gcd(253, 2^{253}-1) = 23$.
6. The only surviving route — an external hint sharing a prime with $N$ — has
   density at most $2/B$.

The moral is one that recurs whenever someone tries to extract hidden structure
from an object by making a simple new object out of it: *a function of $N$ is a
function of $N$.* Coarse-graining never refines. If your observable is built
from $N$ by operations that respect congruences, it lives in the algebra
generated by $N$, and the factorization fiber — the genuinely hidden data — is
invisible to everything in that algebra.

To see past $N$, you need information that did not come from $N$. That is not a
gap in our cleverness. It is a theorem.
