# The Number That Refuses to Split Itself

## Why no formula built out of $N$ alone can ever factor $N$ quickly

Take a number like

$$N = 341371.$$

It has exactly two prime factors, $631$ and $541$, and if you did not already know that, finding them would cost you real work. That single fact — that multiplying is easy and unmultiplying is hard — is the hinge on which most of the world's encrypted traffic swings.

Now here is a question that has occurred, at three in the morning, to almost everyone who has ever thought seriously about factoring. The number $N$ *contains* its factors. Its digits, its residues, its binary expansion — all of it is determined by $p$ and $q$. So why can't we just write down a clever enough formula in $N$, iterate it a few hundred times, and read the factors off?

The answer turns out to be sharper and more beautiful than "nobody has found one yet." There is a structural reason, and it can be stated in a sentence:

> **Any iteration built out of $N$ alone is blind to the very distinction it would need to exploit, and the only event that can ever break its blindness is a coincidence whose expected waiting time is about $N^{1/4}$.**

This article explains that sentence, and the chain of results that turns it into a theorem.

---

## Two rooms and a corridor

Because $N = pq$ with $p$ and $q$ distinct primes, arithmetic modulo $N$ is secretly arithmetic in *two* places at once. The Chinese Remainder Theorem says the ring $\mathbb{Z}/N$ is a product,

$$\mathbb{Z}/N \;\cong\; \mathbb{Z}/p \;\times\; \mathbb{Z}/q,$$

so every number $x$ modulo $N$ is really a *pair* $(x \bmod p,\; x \bmod q)$. Think of two rooms. Every computation you perform mod $N$ is performed simultaneously in both rooms, and you get to see only the shadow that the pair casts on the wall — the residue mod $N$ — never the two rooms separately.

Factoring, in this picture, is the act of learning where the wall between the rooms is.

The only tool we have for that is the Euclidean algorithm: given a number $d$, compute $\gcd(d, N)$. And here is the first result, which is elementary but sets the entire agenda.

**Theorem (The Reveal Criterion).** *Let $N = pq$ with $p \neq q$ prime, and let $d$ be any integer. Then $\gcd(d, N)$ is a nontrivial divisor of $N$ — neither $1$ nor $N$ — if and only if **exactly one** of the two statements "$p$ divides $d$" and "$q$ divides $d$" is true.*

The proof is a three-line argument: $\gcd(d,N)$ divides $N$, so it is one of $1, p, q, N$; it is divisible by $p$ precisely when $p \mid d$, and by $q$ precisely when $q \mid d$; and being strictly between $1$ and $N$ means being divisible by exactly one of them.

But read what it says. A factor appears exactly when the difference $d$ of two quantities is zero *in one room and not the other*. Never when it is zero in both (that gives $\gcd = N$, useless), never when it is zero in neither ($\gcd = 1$, useless). A factoring algorithm of this type is not searching for a number; it is fishing for an **asymmetry**. And the whole difficulty is that everything it is allowed to do is symmetric.

The same statement holds for general $N$, not just semiprimes: $d$ reveals a nontrivial factor of $N$ if and only if some prime factor of $N$ divides $d$ while $N$ itself does not. Reveal $=$ *partial* agreement across the Chinese Remainder decomposition.

---

## Why every honest formula is symmetric

Suppose you build an iteration out of $N$: start from a seed $x_0$ and repeatedly apply some map $f$ assembled from additions, subtractions, multiplications, and constants extracted from $N$'s digits. Pollard's famous $x \mapsto x^2 + 1$ is the canonical example; so is $x \mapsto x + 1$; so is anything you can write down without dividing.

Such an $f$ is an integer polynomial, and integer polynomials have an inescapable property: they **commute with reduction**. Reducing the orbit mod $m$ gives exactly the orbit of the reduced polynomial started at the reduced seed.

**Theorem (Blindness).** *Let $f$ be an integer polynomial and $x_0$ an integer seed. For every modulus $m$, the reduction mod $m$ of the trajectory $x_0, f(x_0), f(f(x_0)), \dots$ is the trajectory of the reduced map $f \bmod m$ started at $x_0 \bmod m$. Consequently, if two maps have coefficients agreeing mod $m$ and two seeds agree mod $m$, their entire trajectories agree mod $m$.*

Nothing in the map "knows" which room it is running in. The map $f$ has one mod-$p$ shadow and one mod-$q$ shadow, and each shadow is computed entirely inside its own room, from data that mentions neither $p$ nor $q$.

Could you cheat by *dividing*? Division is the one operation that behaves differently in the two rooms — inverting a number mod $N$ succeeds or fails depending on whether it shares a factor with $N$. This is exactly the escape hatch, and it slams shut on itself.

**Theorem (Straight-Line Rigidity).** *Fix $N > 1$ and let $e$ be any straight-line program in one variable using $+$, $-$, $\times$, division, and arbitrary integer constants. For every input $x$ modulo $N$, exactly one of the following holds:*

1. *every division in the run succeeds, in which case the whole computation commutes with every ring homomorphism out of $\mathbb{Z}/N$ — in particular with both projections onto the two rooms, so the same program computes both components and no information about the splitting is produced; or*
2. *some division fails, meaning the program has produced an intermediate value $v$ that is not invertible mod $N$ — and then either $v = 0$, or $\gcd(v, N)$ **is** a nontrivial factor of $N$.*

There is no third case. You can escape the blindness only by dividing by something that isn't invertible — and a failed division *is* the factorisation you were trying to compute. The same circularity shows up in its cleanest form as follows: if $e$ is any integer with $N \mid e(e-1)$ but $N \nmid e$ and $N \nmid e - 1$ — that is, a nontrivial idempotent, a genuine separator of the two rooms — then $\gcd(e, N)$ is already a nontrivial factor. **The wall between the rooms *is* the answer.** Anything that can see it has already won, and nothing that hasn't already won can see it.

---

## So what *does* happen? A coincidence, eventually

Put the two theorems together. Along the trajectory of any such iteration, the difference $x_t - x_s$ reveals a factor precisely when the mod-$p$ orbit has returned to an earlier value between times $s$ and $t$ **exclusive-or** the mod-$q$ orbit has. The trajectory has two shadows, each wandering in its own room; a factor pops out at the first moment one shadow closes a loop while the other has not.

This gives an exact identity for the running time. Let $T_p$ be the first time the mod-$p$ shadow revisits a value and $T_q$ the same for mod $q$. Then:

- **nothing** is revealed before $\min(T_p, T_q)$; and
- as soon as $T_p \neq T_q$, a factor **is** revealed at exactly $\min(T_p, T_q)$.

The runtime of the entire family of methods is not a matter of cleverness. It is a statistic of two random-looking walks in rooms of size $p$ and $q$ — rooms whose size you don't know, in a building whose floor plan is the secret you are after.

---

## The birthday law, exactly

How long does a shadow wander before it repeats? This is the classic birthday question, and it can be answered on the nose.

**Theorem (Exact Birthday Law).** *Let $S$ be a set with $n$ elements and fix a starting point $a$. For $T < n$, the number of maps $f : S \to S$ whose orbit prefix $a, f(a), \dots, f^{[T]}(a)$ has no repetition is exactly*

$$(n-1)(n-2)\cdots(n-T) \cdot n^{\,n-T}.$$

*Equivalently, among all $n^n$ maps, the fraction with a collision-free prefix of length $T+1$ is the classical birthday product $\prod_{i=1}^{T}\left(1 - \tfrac{i}{n}\right)$.*

The proof is a fibration argument of some charm. Define a "reset" operation that overwrites the value of $f$ at the last point of the prefix, sending it back to the start. Each fiber of this operation has exactly $n$ members — one for each possible value at that point — and exactly $n - (T+1)$ of them survive one step longer without colliding. Induct.

From the exact product, both tails follow. Above, Weierstrass' inequality gives the Gaussian bound: the collision-free fraction is at most $\exp\!\left(-\tfrac{T(T+1)}{2n}\right)$. Below, it is at least $1 - \tfrac{T(T+1)}{2n}$. So:

- if $T(T+1) \le n$ (roughly $T \le \sqrt{n}$), **at least half** of all maps still haven't collided;
- if $4n \le T(T+1)$ (roughly $T \ge 2\sqrt{n}$), **at most a quarter** still haven't.

The transition happens inside a window of width a constant factor around $\sqrt{n}$. The birthday exponent $1/2$ is sharp from both sides.

That is a statement about *probability*. Sharper still is the statement about the expected time itself. Summing the counting law over all thresholds — a layer-cake identity saying that the total closure time over all maps is precisely the sum of the birthday counts — and then summing the Gaussian tail in blocks of length $\lfloor\sqrt n\rfloor$ (on each of which it decays by the geometric factor $e^{-1/2}$) gives the matching upper bound.

**Theorem (The Average Is $\Theta(\sqrt{n})$).** *Averaged over all $n^n$ maps of an $n$-element set, the first time the orbit repeats a value lies between $\lfloor\sqrt n\rfloor/2$ and $3(\lfloor\sqrt n\rfloor + 1)$.*

And the practical algorithm inherits it. Pollard's rho does not look for the first repeat directly; it runs a tortoise and a hare and waits for them to meet. But a tortoise–hare meeting at time $i$ forces a repetition inside the prefix of length $2i+1$, so any such detector's running time is at least half the first closure time. Averaged over all maps: **at least $\lfloor\sqrt n\rfloor/4$ steps.** Using the hare buys you a constant, never an exponent.

Applied where it matters — the room of size $p \approx \sqrt{N}$ — this reads: a generic iteration needs $\Theta(\sqrt p) = \Theta(N^{1/4})$ steps. And $N^{1/4}$ is *exponential in the number of digits of $N$*.

---

## The complete classification

Every iteration built from $N$ alone falls into one of three regimes, and none of them is fast.

**(a) Generic nonlinear maps.** Their shadows behave like random maps; the closure is a birthday event; cost $\Theta(\sqrt p) \approx N^{1/4}$. This is Pollard rho, and by the theorem above rho is *average-case optimal* in its class.

**(b) Smoothness-dependent maps.** Here the datum is $a^M - 1$, and the reveal criterion becomes: $\gcd(a^M-1, N)$ is a nontrivial factor exactly when $M$ is a multiple of one of the two multiplicative orders of $a$ and not the other. So the first exponent that works is, exactly,

$$M^\ast = \min\big(\mathrm{ord}_p(a),\ \mathrm{ord}_q(a)\big)$$

whenever the two orders differ. This is Pollard's $p-1$ method, and its cost is *precisely* an invariant of the hidden factors. Sometimes it is tiny — for $N = 341371$ and $a = 2$ we have $\mathrm{ord}_{631}(2) = 45$ while $\mathrm{ord}_{541}(2) = 540$, so the reveal time is exactly $45$, reachable in a handful of multiplications. But nothing visible in $N$ tells you that in advance, and for cryptographic $N$ chosen with non-smooth $p-1$ it is astronomically large.

**(c) Structurally simple maps.** At the far extreme sits $x \mapsto x+1$, whose orbit is an arithmetic progression. Its mod-$m$ shadow takes the full $m$ steps to close — the worst possible case. A reveal forces the time gap $t - s$ to be at least $\min(p,q)$, so for balanced semiprimes ($p < q < 2p$) any reveal time $t$ satisfies $N \le 2t^2$, i.e. $t \ge \sqrt{N/2}$. Formally: *for every polynomial bound $c\,(\log_2 N)^k$ there exist balanced semiprimes $N$ on which every revealing pair occurs strictly later than that bound.* And the degenerate limit of "structurally simple" — a map that forgets its input entirely — never reveals anything at all, at any pair of times.

Fast in the middle only by accident; provably slow at the edges; and the middle's speed depends on a secret you don't have.

---

## Watching it happen

The mechanism is not an abstraction; you can watch it fire. Take $N = 341371 = 631 \cdot 541$, the map $x \mapsto x^2+1$, and the seed $2$. The trajectory is $2, 5, 26, 677, 458330, \dots$ (mod $N$). Compute $\gcd(x_t - x_s, N)$ for every pair.

Nothing happens for a long time. The first pair that works is $(s,t) = (23, 36)$, and it hands you $631$ — and *only* $631$, exactly as the exclusive-or criterion demands. Better: one can verify that no pair with $t \le 35$ reveals anything, not by grinding through the gcds, but by checking the *mechanism*: the mod-$631$ and mod-$541$ orbits are both injective up to time $35$, and the structural theorem then forbids any reveal. At time $36$ the mod-$631$ orbit closes; the mod-$541$ one has not; a factor falls out.

And $\sqrt{631} \approx 25.1$. The reveal time $36$ sits right at the birthday scale, not at any polynomial in $\log_2 N \approx 18.4$.

Repeat over a range of sizes and the fingerprint is unmistakable. With $r = t/\sqrt{\min(p,q)}$:

| bits | $p$ | $q$ | first reveal $(s,t)$ | factor | $r$ | $\log_2 t$ |
|---|---|---|---|---|---|---|
| 9 | 509 | 257 | (0, 9) | 509 | 0.56 | 3.17 |
| 11 | 1951 | 1627 | (33, 40) | 1627 | 0.99 | 5.32 |
| 13 | 7789 | 6073 | (21, 81) | 6073 | 1.04 | 6.34 |
| 15 | 30367 | 24517 | (15, 146) | 30367 | 0.93 | 7.19 |
| 17 | 97547 | 115067 | (303, 422) | 97547 | 1.35 | 8.72 |
| 19 | 325081 | 347587 | (423, 523) | 325081 | 0.92 | 9.03 |

The ratio $r$ hovers around $1$ across the whole range while $\log_2 t$ climbs steadily. The reveal time tracks $\sqrt{p}$, i.e. $N^{1/4}$ — exponential in $\log N$. And in every single run, the factor that emerges is exactly the prime whose shadow closed its loop first.

---

## What this is, and what it isn't

This is not a proof that factoring is hard. That question remains gloriously open, and no argument here touches the general-number-field sieve, which uses far more than iteration of a fixed map from $N$, or Shor's algorithm, which uses a different physics.

What it is, is an explanation with the shape of a theorem. It says that a very natural and very tempting family of approaches — *write a formula in $N$, iterate it, take gcds* — is not merely unexplored territory but a closed room. Every member of that family reveals a factor by exactly one mechanism; that mechanism is a birthday coincidence in a space of size $\sqrt{N}$; the expected waiting time for that coincidence is $\Theta(N^{1/4})$ and no cycle-detection trick improves the exponent; and the only way out — dividing by something the two rooms disagree about — requires the answer as its input.

There is something almost aesthetically satisfying in this. The reason $N$ won't tell you its factors is not that it is hiding them cleverly. It is that everything $N$ can say, it says in both rooms at once. To hear the two rooms apart you would need the wall — and the wall is the secret.

The next time someone tells you they have a formula that factors, ask them exactly one question: *what is the first thing your computation does that the two halves of $N$ would disagree about?* Either the answer is "nothing" — and then no formula, however baroque, will help — or it is a division, and their formula already contains its own answer.
