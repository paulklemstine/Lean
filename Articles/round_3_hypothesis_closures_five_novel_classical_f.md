# Five Ways Not to Factor a Number

*How coding theory, braids, parity oracles, average-case statistics, and game theory all fail to break the integer-factoring barrier — and what their failure teaches us.*

---

## The oldest hard problem

Take two primes, say $p = 1{,}009$ and $q = 4{,}051$, and multiply them: $N = 4{,}087{,}459$. That took a fraction of a second. Now hand a stranger only $4{,}087{,}459$ and ask for $p$ and $q$. They can do it — but only by *searching*, and the search gets brutally expensive as the primes grow. Scale them to six hundred digits each and the search outlives the sun.

That asymmetry — trivial to multiply, apparently impossible to reverse — is the load-bearing wall of modern digital life.

There is no proof that the wall is solid. There is only the accumulated evidence of decades of failed attempts. So a natural research program suggests itself: instead of hunting for a fast factoring algorithm, hunt for *reasons every attempt fails*. Collect the failures, and see whether they all fail the same way.

This article reports on five such attempts, drawn from five unrelated corners of mathematics — error-correcting codes, the braid group, divisor parity, probabilistic average-case analysis, and multi-player game theory. Each one looked, at first, like it might slip past the wall. All five turned out to fail, and — this is the interesting part — **all five fail for one of exactly two reasons.**

---

## The two reasons

Before the five stories, here are the two morals, stated up front.

**Moral 1: The Chinese Remainder Theorem splits everything.** When $N = pq$ with $p \ne q$ prime, the ring of integers modulo $N$ is not one object; it is secretly a *pair* of objects glued together, $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$, as rings. Every structure you build over $\mathbb{Z}/N$ — a code, a matrix group, a polynomial — therefore splits into a mod-$p$ half and a mod-$q$ half, and every numerical invariant you extract is really a *function of the two prime-level invariants*. So if you can compute it, you have learned something about $p$ and $q$ separately — and that *is* factoring. The invariant is not a shortcut; it is the destination wearing a disguise. Call such a quantity a **free witness**: free, because it certifies the factorization instantly once you have it; a witness, because getting it is not free at all.

**Moral 2: Congruence data is blind.** The other tempting shortcut is a *statistic of $N$ alone* — something cheap like $N \bmod 8$, a Jacobi symbol, a digit pattern — that predicts something about $p$ and $q$. Every such statistic is determined by $N \bmod m$ for some fixed modulus $m$. And Dirichlet's classical theorem on primes in arithmetic progressions delivers the fatal blow: every residue class $a \bmod m$ with $a$ coprime to $m$ contains infinitely many primes. Pack them together and you find, in a *single* class, two semiprimes $N_1 = p_1 r_1$ and $N_2 = p_2 r_2$ that are **coprime to each other**. A function seeing only the class cannot tell them apart, so whatever divisor it names divides at most one of them. Congruence data cannot name a factor. Ever.

Now the five stories.

---

## Story 1: The code whose shape betrays a prime

Reed–Solomon codes are why a scratched CD still plays and why deep-space probes can whisper across the solar system. The recipe: take polynomials of degree less than $k$, evaluate each at every point of a finite field, and call the resulting vectors your codewords. The *minimum distance* — the smallest number of nonzero coordinates any nonzero codeword has — controls how many errors you can correct; over a field of size $n$ it is the famous $n - (k-1)$.

The tempting move: run the same recipe over $\mathbb{Z}/N$, where $N = pq$ is *not* a field. Define
$$C_k(N) \;=\; \{\,(f(0), f(1), \dots, f(N-1)) \;:\; f \in (\mathbb{Z}/N)[x],\ \deg f < k \,\}.$$
What is the minimum distance now?

The answer, and it is exact:

> **Minimum-Distance Theorem.** Let $N = pq$ with $p < q$ distinct primes and let $1 \le k \le p$. Every nonzero polynomial of degree at most $k$ produces a codeword of Hamming weight at least $N - k\max(p,q)$, and some codeword attains that bound exactly. Hence the minimum distance of the code of degree-$\le k$ polynomials is precisely
> $$d = N - k\cdot\max(p,q).$$

Stare at that formula. The minimum distance of the code *contains the larger prime factor as a summand*. Take $k=1$: then $\max(p,q) = N - d$, and dividing, $\min(p,q) = N/(N-d)$. **The minimum distance is the factorization.**

Why is the formula true? The upper half is the Chinese Remainder Theorem doing its work. A point $x$ where the codeword vanishes maps to a pair: a root of $f \bmod p$ and a root of $f \bmod q$. The map $x \mapsto (x \bmod p,\ x \bmod q)$ is injective, so the zero set of $f$ injects into the *product* of the two prime-level root sets. Over a field a nonzero polynomial has at most $\deg f$ roots, so one factor of that product has size at most $\deg f$ and the other at most $\max(p,q)$. Multiply, then subtract from $N$.

The lower half — the bound is *attained* — is an explicit construction. Consider
$$f(x) \;=\; q \cdot x(x-1)(x-2)\cdots(x-k+1).$$
Modulo $q$ this is identically zero (the leading constant kills it); modulo $p$ it has the $k$ roots $0, 1, \dots, k-1$. So the codeword vanishes at exactly those $x$ whose residue mod $p$ lies in $\{0, \dots, k-1\}$ — that is, on $k$ full residue classes mod $p$, each containing exactly $q$ points of $\mathbb{Z}/N$. Total: exactly $kq = k\max(p,q)$ zeros. The bound is tight, and the witness is a single line of algebra.

So the code's most fundamental invariant is a free witness: computing it requires either knowing $p$ and $q$, or brute-force searching a codeword space of size $N^k$. There is no third way in sight.

---

## Story 2: The parity oracle you cannot afford to query

Here is a primitive designed to be as weak as possible while still touching the factorization. Fix a modulus $m$; for each residue $a$, ask a single bit:
$$P(N, m, a) \;=\; \#\{\, d : d \text{ a proper divisor of } N,\ d \equiv a \bmod m \,\} \bmod 2.$$
Just a parity. Surely a parity bit is too coarse to be dangerous?

It is not. For a semiprime $N = pq$ with $p \ne q$, the proper divisors are exactly $1$, $p$, and $q$. So as $a$ runs over $0, \dots, m-1$, the bit is $1$ on exactly the three classes $1$, $p$, $q$ mod $m$ (assuming those are distinct) and $0$ everywhere else:

> **Support Theorem.** If $1$, $p$, $q$ are pairwise incongruent mod $m$, then $\{a \in \{0,\dots,m-1\} : P(N,m,a) = 1\}$ equals $\{1 \bmod m,\ p \bmod m,\ q \bmod m\}$, a set of exactly three elements. Deleting the class $1 \bmod m$ — which is known a priori — returns exactly $\{p \bmod m,\ q \bmod m\}$.

The oracle is a factorization certificate modulo $m$: query enough moduli, reassemble by the Chinese Remainder Theorem, and you have $p$ and $q$.

But count the cost. The informative classes number three out of $m$ — a needle in a haystack. And the closure is a classic adversary construction:

> **Indistinguishability Theorem.** Let $N = pq$ and $N' = p'q'$ be two semiprimes, both non-degenerate mod $m$. On any set $Q$ of queries that avoids the (at most six) marked classes of the two numbers, the oracle returns *identical* transcripts: $P(N,m,a) = P(N',m,a)$ for every $a \in Q$.

An algorithm that has not hit a marked class has learned nothing at all — it cannot distinguish $N$ from a completely different semiprime. Since the marked classes are a $6/m$-density target, any deterministic strategy needs $\Omega(m)$ queries in the worst case; and each individual query is itself a divisor enumeration, which is factoring. The primitive is closed twice over.

And when the pattern *fails*, it fails for an honest reason:

> **Collision Theorem.** If $p \equiv q \pmod m$ (with neither congruent to $1$), the two factor classes coincide, their contributions cancel in the parity, and the support collapses to the single class $\{1 \bmod m\}$.

The failures are exactly the merged-class cases — genuinely unresolvable, not artifacts of a weak argument. For $N = 15$ and $m = 7$ the support is $\{1,3,5\}$ and the factors pop out; for $m = 2$, since $3 \equiv 5 \equiv 1$, everything merges and the support is just $\{1\}$.

---

## Story 3: Braids that are secretly just clocks

Nearly every failed attack on factoring lives in a *commutative* world — modular arithmetic, quadratic forms, abelian class groups. A recurring hope is that genuine **non-commutativity** is the missing ingredient, and braid groups are the natural place to look: tangles of strands, where the order of crossings matters.

The three-strand braid group $B_3$ has generators $\sigma_1, \sigma_2$ subject to the single relation $\sigma_1\sigma_2\sigma_1 = \sigma_2\sigma_1\sigma_2$. Its reduced Burau representation, specialized at a parameter $a$, sends
$$\sigma_1 \longmapsto \begin{pmatrix} -a & 1 \\ 0 & 1\end{pmatrix}, \qquad \sigma_2 \longmapsto \begin{pmatrix} 1 & 0 \\ a & -a\end{pmatrix}.$$
These matrices genuinely satisfy the braid relation, by direct multiplication, so this is an honest non-abelian picture. Take $a$ to be a unit modulo $N$ and you get a subgroup $H_a = \langle r(\sigma_1), r(\sigma_2)\rangle$ of the invertible $2\times 2$ matrices over $\mathbb{Z}/N$, whose size ought to encode something new about $N$.

It encodes something, all right. Set $B = r(\sigma_1)r(\sigma_2) = \begin{pmatrix} 0 & -a \\ a & -a \end{pmatrix}$, the image of $\sigma_1\sigma_2$. A short computation gives the key identity:

> **Full-Twist Theorem.** $B^3 = a^3 \cdot I$. The full twist $\Delta^2 = (\sigma_1\sigma_2)^3$, which generates the centre of $B_3$, maps to the scalar matrix $a^3 I$.

From this, everything collapses:

> **Braid-Order Theorem.** For a unit $a$ in a nontrivial commutative ring, $B^n = I$ if and only if $3 \mid n$ *and* $a^n = 1$. Consequently the order of $B$ is exactly
> $$\operatorname{ord}(B) \;=\; \operatorname{lcm}\!\left(3,\ \operatorname{ord}(a)\right).$$

The "only if" direction is a lovely little argument. Write $n = 3s + t$ with $t \in \{0,1,2\}$; the identity $B^{3s} = a^{3s} I$ peels off the cube part, leaving $B^n = a^{3s} B^{t}$. Since $a$ is a unit, $B^n = I$ forces the upper-right entry of $B^t$ to vanish. But that entry is $-a$ when $t = 1$ and $a^2$ when $t = 2$ — both nonzero for a unit. So $t = 0$, i.e. $3 \mid n$; and then $a^n I = I$ gives $a^n = 1$.

The consequences are immediate and fatal. The order $\operatorname{ord}(a)$ divides the braid order, and the braid order divides $3\operatorname{ord}(a)$ — the two problems are the same problem up to a factor of three. And by Lagrange's theorem applied to $\sigma_1\sigma_2$ inside $H_a$, the quantity $\operatorname{lcm}(3, \operatorname{ord}(a))$ divides the *group order* $|H_a|$: even the coarsest invariant of the braid image is an order-finding measurement.

Order-finding modulo a semiprime is the classical dead end, because the order splits by the Chinese Remainder Theorem:

> **Order-Splitting Theorem.** For coprime $p, q$ and any $a$ modulo $pq$,
> $$\operatorname{ord}_{pq}(a) \;=\; \operatorname{lcm}\!\left(\operatorname{ord}_p(a),\ \operatorname{ord}_q(a)\right).$$

The braid order is therefore $\operatorname{lcm}(3, \operatorname{ord}_p(a), \operatorname{ord}_q(a))$: exactly the object Pollard's $p-1$ method chases classically and Shor's algorithm computes quantumly. There is one genuinely non-commutative wrinkle — modulo $21$, both $a = 2$ and $a = 5$ have $\operatorname{lcm}(\operatorname{ord}_3, \operatorname{ord}_7) = 6$, yet $|H_2| = 336$ while $|H_5| = 24$, because the group order sees the *individual* prime-level orders. The extra sensitivity is real, and useless: it is sensitivity to precisely the data you would need to factor in the first place.

Non-abelian structure does not escape. The braid picture is a faithful repackaging of the clock.

---

## Story 4: There is no lucky family

Perhaps we are asking too much. Perhaps no algorithm factors *every* semiprime quickly, but a large, easily recognizable family — say $99\%$ of them — succumbs. Spot membership from $N$ alone and you have broken factoring in practice without breaking it in theory.

Fast subfamilies certainly exist. If $p$ and $q$ are close, Fermat's method finds them almost instantly; if $p - 1$ has only small prime factors, Pollard's $p-1$ wins. But both are properties of $p$ and $q$ — you cannot check them without already knowing the answer. Is there a family recognizable from $N$ itself?

No, and the proof is Dirichlet's theorem wielded as a weapon.

> **Class-Population Theorem.** Fix a modulus $m$, a target residue $a$ that is a unit mod $m$, and *any* prime $p$ invertible mod $m$. Then for every bound $B$ there is a prime $r > B$ with $r > p$ such that the semiprime $N = pr$ satisfies $N \equiv a \pmod m$ and $\operatorname{minFac}(N) = p$.

Read that carefully: the class $a \bmod m$ contains semiprimes with *whatever smallest factor you like*. Two corollaries drop out: within a single class, the smallest prime factor is unbounded, and so is the factor gap $|p - q|$. The "Fermat-easy" family is invisible to congruence data, as is every family defined by the size of the smaller factor.

This matches the experimental picture exactly. Across a sample of semiprimes, the number of steps Pollard's $\rho$ takes shows no dependence whatsoever on $N \bmod 4$, $N \bmod 8$, or the Jacobi symbol $(2/N)$. Meanwhile the genuinely fast subfamily, small $|p - q|$, is dramatically faster — and completely invisible from $N$.

The sharpest form of the obstruction is the central meta-theorem:

> **Free-Witness Meta-Theorem.** Call an integer invariant $I$ *congruence-determined* modulo $m$ if $I(N)$ depends only on $N \bmod m$. Call $I$ *factor-revealing* beyond $B$ if $I(N)$ is a nontrivial divisor of $N$ for every semiprime $N > B$. Then for every $m > 1$, no invariant is both.

The proof is the two-coprime-semiprimes construction of Moral 2: the invariant returns one number $d$ for both $N_1$ and $N_2$, and $d$ would have to divide two coprime numbers. And the hypothesis is not vacuous on the revealing side — the least-prime-factor map is factor-revealing — so the obstruction lands squarely on congruence-determination. Even a *list* of guesses does not help:

> **Bounded-List Theorem.** Fix $m > 1$, a length bound $k$, and a threshold $B$. If $S : \mathbb{Z}/m \to$ (finite sets of integers) satisfies $|S(a)| \le k$ for every $a$, then some semiprime $N > B$ has no nontrivial divisor at all inside $S(N \bmod m)$.

Pigeonhole with teeth: build $k+1$ pairwise-coprime semiprimes in the class $1 \bmod m$ by drawing $2(k+1)$ primes in increasing blocks. Each would need its own element of the common list $S(1)$, since coprimality means no candidate serves two of them — so $|S(1)| \ge k+1$. A congruence-determined candidate list must be *unboundedly* long, which is to say it is not a shortcut.

---

## Story 5: The game whose equilibrium is the answer

The last attempt is the most philosophically pointed. Recast factoring as a game and hope that equilibrium-finding — a well-studied problem with its own toolkit — cracks it.

**The divisor congestion game.** Given $N$, each player picks a bid $d \in \{2, \dots, N-1\}$ and receives payoff
$$w(d) \;=\; \begin{cases} N/d & \text{if } d \mid N, \\ -N & \text{otherwise.}\end{cases}$$
Divisors pay well, small divisors best; non-divisors are punished. The solution is exactly what you would hope for, and exactly what you would fear:

> **Equilibrium Theorem.** Let $N$ be composite. Among admissible bids $2 \le d < N$, the least prime factor $\operatorname{minFac}(N)$ is a best response, and for $N = pq$ with $p < q$ it is the *unique* best response. Reading off the equilibrium bid $d$ and its payoff $w(d)$ yields the complete factorization: $N = d \cdot w(d)$, with $d$ prime.

So the equilibrium exists, is unique, and *is* the factorization. That is not a win; that is the definition of circularity. Three facts pin down why the game gives no leverage. A single payoff query is a divisibility test in disguise — $w(d) \ge 0$ if and only if $d \mid N$ — so an agent computing best responses is running trial division by another name. The payoff landscape is exactly *flat* away from the divisors: if neither $d$ nor $e$ divides $N$ then $w(d) = w(e) = -N$, so there is no gradient, no slope, nothing for a hill-climber to climb — a featureless plateau of size $N$ with a handful of invisible pits. And since the equilibrium bid is $\operatorname{minFac}(N)$, which is not congruence-determined by the meta-theorem above, no cheap residue-level shortcut finds it either.

Verification is easy; discovery is the whole problem. The game is a *poly-time-checkable restatement* of factoring — the game-theoretic way of saying "the answer is the answer."

---

## What five failures add up to

Line the stories up and the pattern is unmistakable. A Reed–Solomon minimum distance, a braid-group order, a divisor-parity support, an equilibrium bid — four objects from four disjoint areas of mathematics, each turning out to *be* the factorization rather than a route to it, each reachable only at cost $\Omega(N)$ or worse, each cheap only once you already have $p$ and $q$.

The structural cause is always the same splitting. $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$ means an invariant over $\mathbb{Z}/N$ is a pair of prime-level invariants in a trench coat; extracting it means separating the pair, and separating the pair means factoring. This "free-witness" phenomenon has now been seen in six structurally distinct settings — norm counts, group-order counts, quadratic-form counts, group-class counts, modular indices, and now code distances — always with the same shape. On the other side, the escape through cheap statistics of $N$ is closed by Dirichlet: residue classes are *rich* enough to contain every factorization profile, including coprime twins, so a blind statistic stays blind whether it outputs one guess or a bounded list.

Neither moral proves that factoring is hard — that remains open, and nothing here rules out a genuinely new idea. What the five closures do is map the terrain. If your new idea builds an algebraic invariant over $\mathbb{Z}/N$, expect the splitting to convert it into a free witness; if it reads a statistic off $N$, expect Dirichlet to blind it. Anything that escapes must dodge *both*.

Every genuinely new mathematical idea deserves to be tested against factoring, and most will fail. Knowing precisely *how* they fail is what turns a graveyard of attempts into a map — and a map is what you need before you can find the road out.
