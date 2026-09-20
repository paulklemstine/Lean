# The Algorithms That Never Look at the Number

## Why the best factoring methods are blind to the thing they are factoring

Pick a number with a thousand digits. Hand it to a computer and ask: what are its prime
factors? This is the question modern cryptography is built on — and the question that,
for forty years, has driven some of the most beautiful algorithm design in mathematics.

Here is a fact about that question that sounds, at first hearing, impossible.

Suppose your thousand-digit number happens to have a small prime factor, say
$p = 4093$. Two of the standard tools — Pollard's *rho* method and the *elliptic curve
method* — will find that factor in roughly the same number of steps whether the number
you hand them has ten digits or ten thousand. Not "roughly the same up to a logarithm."
The same. The other 996 digits of the number are, as far as the cost of the search is
concerned, *invisible*.

We call this phenomenon **method locality**: a factoring method is *factor-local* when
its cost is a function of the prime it happens to be hunting, and not of the number it
is looking inside. The purpose of this article is to explain why locality happens, to
say exactly which methods have it, and — perhaps most interestingly — to prove a
theorem saying that a large and natural class of methods *cannot possibly* have it.

---

## What "cost" means

To say anything precise we need a notion of cost that fits all the methods at once.

Pollard's rho method works like this. Fix a simple map, say $f(x) = x^2 + 1$, and a
starting value $x_0 = 2$. Iterate it, always reducing modulo the number $N$ you want to
factor:
$$x_{n+1} = x_n^2 + 1 \pmod N.$$
You now have a walk in the finite set $\mathbb{Z}/N$. Because the set is finite, the
walk must eventually revisit a value it has already seen — it enters a cycle, a shape
that (when drawn) looks like the Greek letter $\rho$, which is where the name comes
from.

The cost of such a search is its **collision time**: the first index $n$ at which the
state $x_n$ equals some strictly earlier state $x_i$, $i < n$. Every search of this
kind has a collision time, and the pigeonhole principle gives an immediate ceiling: a
walk through a state space of size $c$ collides no later than step $c$.

That is the definition on which everything below rests. It is deliberately crude — it
counts state updates, not machine cycles — but it is the right granularity, because it
is exactly the quantity that turns out to obey clean theorems.

---

## The shadow

Now the central idea, and it is almost embarrassingly simple once seen.

Suppose $N = p \cdot q$, with $p$ the prime we are hunting. Alongside the real walk
modulo $N$, imagine a *shadow* walk: at every step, take the current state and reduce
it modulo $p$. The shadow lives in $\mathbb{Z}/p$, a far smaller space.

The key observation is that **the shadow of the walk is itself a walk of the same
kind**. Reduction modulo $p$ is a ring homomorphism $\mathbb{Z}/N \to \mathbb{Z}/p$: it
respects addition and multiplication. And the rho step $x \mapsto x^2 + 1$ is built out
of nothing but addition and multiplication. So reducing and then stepping gives the
same answer as stepping and then reducing. Iterating, one gets the

> **Shadow Theorem.** *Let $p \mid N$, let $f$ be any polynomial with integer
> coefficients, and let the state sequence modulo $N$ be $x_n = f^{(n)}(x_0)$. Then for
> every $n$, the reduction of $x_n$ modulo $p$ equals the $n$-th iterate of $f$ from
> $x_0$ computed entirely inside $\mathbb{Z}/p$.*

The shadow of a run modulo $N$ is, term for term, the run modulo $p$. The cofactor $q$
never entered the computation of the shadow, so it cannot affect it. That single
sentence is the whole mechanism of factor locality, and it has three immediate
consequences.

**Cofactor flatness.** The cost of the rho method — measured as the collision time of
the mod-$p$ shadow, which is what actually reveals the factor — depends only on $p$,
the polynomial, and the seed. Two runs with the same prime $p$ and different cofactors
$q$ and $q'$ have *identical* cost. Not approximately: exactly, ratio $1$.

**Factor boundedness.** Since the shadow lives in a space of size $p$, pigeonhole
bounds the cost by $p$, whatever $N$ is. A prime of $14$ bits can never cost more than
$16384$ steps, even inside a number with a million digits.

**Reveal.** When the shadow closes strictly earlier than the full walk does, the two
colliding states are congruent modulo $p$ but *different* modulo $N$. Their difference
is therefore a nonzero multiple of $p$ that is not a multiple of $N$ — so the greatest
common divisor of that difference with $N$ is a genuine, nontrivial, proper factor of
$N$, divisible by $p$. This is the exact moment the method wins, and the statement above
is a theorem, not a heuristic: whenever the shadow is strictly faster, a factor comes
out.

---

## How fast is the shadow?

Locality says the cost is a function of $p$ alone; it does not by itself say the
function is small. The famous answer — the reason anyone uses the rho method — is the
*birthday* phenomenon. If the $k$ successive states behaved like independent uniform
draws from $\mathbb{Z}/p$, the probability that they are all distinct would be
$$\prod_{i=0}^{k-1}\left(1 - \frac{i}{p}\right) \le \exp\!\left(-\frac{k(k-1)}{2p}\right),$$
an inequality that follows from $1 - t \le e^{-t}$ applied term by term. The bound
crosses $1/2$ at around $k \approx 1.18\sqrt{p}$: the expected cost is on the order of
$\sqrt{p}$, not $p$. At $p = 4093$ the bound already certifies that $76$ steps suffice
to make a collision more likely than not.

This is a model, and honesty requires two remarks about it. First, the model is not a
theorem about any particular map: there exist state updates with no birthday gain at
all. The successor map $x \mapsto x + 1$ modulo $p$, for instance, visits every residue
before repeating, so its collision time is exactly $p$ — the pigeonhole bound is
attained, and *no* speed-up occurs. Locality is a structural property; the square-root
speed-up is a probabilistic bonus that the quadratic map happens to enjoy.

Second, one can simply check the prediction. For $f(x) = x^2 + 1$ and $x_0 = 2$:

| prime $p$ | $\sqrt{p}$ | actual collision time |
|---|---|---|
| $1009$ | $31.8$ | $49$ |
| $4093$ | $64.0$ | $70$ |

Both sit comfortably inside the birthday window $2\sqrt{p}$. These are not fitted
estimates; they are exact counts of exact orbits — at $p = 4093$ the first $70$ states
are pairwise distinct and state $70$ reproduces state $53$.

---

## The method that *does* read the number

Against this, consider the most obvious factoring algorithm in the world: trial
division. Test $2$, then $3$, then $4$, and so on until something divides.

Its cost is $\mathrm{minFac}(N) - 1$, one test for each candidate strictly below the
least prime factor, all of which genuinely fail. Two clean statements follow. On the
stratum where the hunted prime $p$ is the least prime factor of $N = pq$, the cost is
*exactly* $p - 1$ — perfectly linear in $p$, and the linearity is not asymptotic but an
identity: the ratio of the cost at $p$ to the cost at $p'$ is exactly
$(p-1)/(p'-1)$. And for any prime factor $p$ of $N$ at all, the cost is at most
$p - 1$, so trial division *is* factor bounded.

But it is not factor local, and one line kills it. Hold the hunted prime fixed at
$p = 4093$. With cofactor $q = 3$ the number is $12279$, whose least factor is $3$, so
the cost is $2$. With cofactor $q = 4093$ the number is $4093^2$ and the cost is
$4092$. Same factor, same target, costs differing by a factor of two thousand,
entirely because of a change in the cofactor. Trial division tracks the modulus.

The gap this opens against the rho method widens with $p$, and can be certified rather
than estimated: against the same targets, rho is at least $20$ times cheaper at
$p = 1009$ and at least $58$ times cheaper at $p = 4093$.

---

## Locality is not luck: two structure theorems

So far we have one family that is local and one method that is not. What separates
them? Two theorems, pointing in opposite directions, answer this completely.

### Naturality forces locality

Call a state update **uniform** if it is defined by the same formula simultaneously for
every commutative ring — a rule that makes sense in $\mathbb{Z}/N$ and in $\mathbb{Z}/p$
and in any other ring, and that commutes with every ring homomorphism between them.
Polynomial maps are uniform. The exponentiation step $x \mapsto x^k$ behind the
$p-1$ method is uniform. Essentially every classical "iterate something algebraic"
method is uniform.

> **Locality-from-Naturality Theorem.** *Every uniform method is cofactor flat — its
> cost against a prime $p$ is the same for all cofactors — and its cost is at most $p$.*

The proof is the Shadow Theorem again, with "polynomial" replaced by "natural
transformation": uniformity is precisely the hypothesis needed to make reduction
commute with the step, and once the shadow of the mod-$N$ run is the mod-$p$ run, the
cofactor has nowhere to enter. So locality is not a coincidence discovered
experimentally in two algorithms; it is a corollary of an algebraic property that those
algorithms were designed to have for entirely different reasons.

### Reading the modulus forbids locality

Now the converse, which is the sharper half. Call a cost model **modulus-determined**
if its ledger never consults the prime being hunted — the cost is a function of $N$
alone. Trial division is the archetype: it does not know, and cannot know, which factor
it will hit.

> **Rigidity Theorem.** *A cost model that is both modulus-determined and cofactor flat
> is constant on composites: it assigns the same cost to every product $a \cdot b$ of
> positive integers.*

The proof is a three-line shuffle, and it is worth seeing because it explains the
phenomenon rather than merely certifying it. Take two composites $ab$ and $cd$. By
flatness applied to the factor $a$, the cost at $ab$ equals the cost at $a \cdot (cd)$.
That product is also $(cd) \cdot a$; by flatness applied to the factor $cd$, its cost
equals the cost at $(cd) \cdot 1 = cd$. Modulus-determinedness is what licenses the
re-labelling at each step. Hence $\mathrm{cost}(ab) = \mathrm{cost}(cd)$.

The consequence is severe: **no non-constant method that reads only the modulus can be
factor-local.** Trial division's failure needs no counterexample; it is forced. And
symmetrically, the rho method's cost is provably *not* modulus-determined — it costs
$1$ step at $p = 3$ and $70$ at $p = 4093$ — which is exactly the licence it needs to be
flat.

Together these two theorems close the plane. A ledger that reads the factor can be
flat, and if it is natural it must be. A ledger that reads only the modulus can be flat
only by being trivial. There is no third option.

---

## Elliptic curves, and a wall that was never there

The elliptic curve method is the modern champion among factor-local methods, and it
fits the same picture, though its ledger looks different. Stage 1 of the method picks a
random curve, computes the enormous scalar $k(B) = \mathrm{lcm}(1,2,\dots,B)$, and
multiplies a point by it. Success modulo $p$ happens when $k(B)$ annihilates the point
in the group of the curve over $\mathbb{Z}/p$ — a group whose order $m$ lies, by Hasse's
theorem, within $2\sqrt{p}$ of $p$.

Modulo $N = pq$ the point lives in a product of two such groups, of orders $m$ (the
$p$-side) and $m'$ (the $q$-side). Counting exactly: out of the $m \cdot m'$ joint
states, the number whose $p$-coordinate is annihilated by $k$ is $\gcd(m,k)\cdot m'$, so
the success rate is
$$\frac{\gcd(m,k)\, m'}{m\, m'} = \frac{\gcd(m,k)}{m}.$$
The cofactor's group order $m'$ cancels *identically*. The stage-1 success rate is a
function of the factor and the smoothness bound only — locality again, arrived at by
counting instead of by naturality. The expected number of curves, $m/\gcd(m,k(B))$, is
bounded by the Hasse ceiling $p + 3 + 2\lfloor\sqrt{p}\rfloor$, a function of $p$ alone,
and it never increases when $B$ increases.

That last clause deserves emphasis, because it settles an apparent paradox. It was once
reported that pushing $B$ past the top of the Hasse window produces a "wall" at which
every curve degenerates and the method dies. The truth is the reverse: past that point
$k(B)$ annihilates the whole group, so *one curve suffices* — the expected curve count
is exactly $1$.

Where, then, does the wall sentence come from? From bookkeeping. Model a two-prime run
by a pair of residues, one per prime, and separate four outcomes according to which
coordinates degenerate. Their counts are exact products:

- both sides degenerate ("dead", the guarded inversion returns $N$): $\gcd(m_p,k)\gcd(m_q,k)$;
- only the $p$-side: $\gcd(m_p,k)\,(m_q - \gcd(m_q,k))$ — the factor $p$ is revealed;
- only the $q$-side: $(m_p - \gcd(m_p,k))\gcd(m_q,k)$;
- neither: $(m_p - \gcd(m_p,k))(m_q - \gcd(m_q,k))$;

and these four blocks sum to $m_p m_q$, accounting for every trial. Adding the two
middle blocks gives the exact number of trials that expose a proper factor. It is zero
exactly when the bound covers *both* group orders — so a genuine wall does exist, and it
sits at $\max(p,q)$, governed by the *larger* prime. While the $q$-side stays inert, the
reveal count is monotone increasing in $B$: nothing wall-shaped can happen at
$\min(p,q)$.

The smallest witness of the real wall is charmingly small: two groups of order $2$. At
$B = 1$ both trials reveal a factor; at $B = 2$ neither does, because the bound has
covered both orders.

The reported wall, by contrast, is a *misfiling*. Think of a ledger as a map from the
firing pattern — which of the two coordinates degenerated — to a recorded outcome. The
four-way separated ledger is injective: distinct patterns get distinct records. The
ledger that files any $p$-side degeneracy as a "death" is not injective, and on the one
pattern that matters — $p$-side fires, $q$-side inert, which is the pattern produced
exactly in the regime where the wall was reported — the faithful ledger records
"factor $p$ found" while the conflating ledger records "dead". The wall sentence is the
image of that single conflation.

There is a genuine subtlety here that the separation is designed to expose: the
$p$-found channel alone is *not* monotone in $B$. With group orders $4$ and $6$, raising
$B$ from $2$ to $3$ takes the $p$-found count from $8$ to $0$. Nothing failed — those
eight trials moved into the "dead" block when the $q$-side started firing too. Channel
counts redistribute; only the separated ledger lets you see it.

---

## What locality means

Step back. The practical reading is familiar to anyone who has run a factorization: you
do not choose a method by the size of $N$, you choose it by the size of the factor you
hope is hiding inside. Rho for factors up to fifteen digits or so, elliptic curves up to
forty or fifty, and only then the sieve methods whose cost genuinely is a function of
$N$. What the theorems above supply is the reason this rule of thumb is a *law*: the
first two methods are natural in the ring, and naturality is cofactor flatness.

The cryptographic reading is the contrapositive. A modulus is safe not because it is
large but because its factors are large. A $2048$-bit modulus with a $60$-bit prime
inside it is not a $2048$-bit problem; it is a $60$-bit problem wearing a costume, and
the elliptic curve method will strip the costume off in an afternoon. Locality is the
theorem behind every key-generation routine's insistence on balanced primes.

And the structural reading is the one that seems most likely to keep giving. Cost
models, in this framework, are not just numbers attached to algorithms: they are
*ledgers*, maps from what a run can see to what it can record. The Rigidity Theorem says
a ledger that refuses to look at the factor buys triviality. The faithfulness analysis
says a ledger that conflates two outcomes can manufacture a phenomenon — a wall — that
does not exist. In both cases the mathematics of the algorithm turned out to be
inseparable from the mathematics of its accounting.

That, in the end, is the lesson worth carrying away. The methods that win are the ones
that never look at the number. And the claims that mislead are the ones whose ledgers
never look closely enough.
