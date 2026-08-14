# The Prime That Cannot Be Cornered

*Why every fast "fingerprint" of a number is blind to its factors — and what that tells us about the limits of factoring*

---

## A number with a secret

Take the number $221$. It is not prime: it is $13 \times 17$. If I hand you $221$ and ask which two primes multiply to give it, you can find them in a moment by trial division. Now imagine I hand you a number with six hundred digits, formed the same way — a product of two enormous primes — and ask the same question. The security of a great deal of the world's digital infrastructure rests on the belief that you cannot answer.

But *why* can't you answer? That is a much harder question than it sounds, and nobody has proved that factoring is hard. What we can do — what mathematicians have been doing for decades — is prove that whole *families* of natural strategies are doomed. Each such proof is called a **barrier**: a theorem saying "this entire style of attack cannot possibly work, so stop looking there."

This article is about a barrier that has now been established for one of the most tempting families of strategies: the cheap fingerprints.

---

## Cheap fingerprints

Suppose you are handed $N$, a product of two unknown primes, and you are only allowed to run computations that are *fast* — fast meaning polynomial in the number of digits of $N$, not in $N$ itself. What kinds of measurements can you take?

Quite a few, actually. Here are the classics:

- **Residues.** You can compute $N \bmod m$ for any small modulus $m$: is $N$ one more than a multiple of $7$? Two more than a multiple of $11$? These are instant.
- **Jacobi symbols.** For a small number $a$, the Jacobi symbol $(a \mid N)$ is a value in $\{-1, 0, +1\}$ that generalizes the question "is $a$ a perfect square modulo $N$?". It can be computed in essentially the time of a gcd — no factorization of $N$ required. It is a genuine, subtle arithmetic invariant, and it is exactly the ingredient that powers the Solovay–Strassen primality test.
- **Greatest common divisors.** You can compute $\gcd(N, c)$ for small $c$, or $\gcd(f(N), N)$ for a polynomial $f$ of your choosing. Euclid's algorithm is famously fast.

Assemble all of these into a single instrument — call it a **battery**. Fix a bound $B$ and read off at once:

$$N \bmod m \quad (1 \le m \le B), \qquad (a \mid N) \quad (1 \le a \le B), \qquad \gcd(N, c) \quad (1 \le c \le B).$$

That is $3B$ numbers, computable in a flash even for a six-hundred-digit $N$: the numerical equivalent of a full blood panel. Surely, one thinks, if you take enough measurements, and take them cleverly enough, the patient's secret must eventually leak out.

It does not. This article is about the theorem that says it never will.

---

## The one thing all these measurements have in common

Here is the observation that unlocks everything. Every single measurement in that battery — every residue, every Jacobi symbol, every small gcd — depends on $N$ **only through the remainder of $N$ upon division by a single fixed number**.

Let

$$L \;=\; 4 \cdot \operatorname{lcm}(1, 2, \dots, B),$$

the least common multiple of everything up to $B$, times four. (The four is there to accommodate the Jacobi symbol, whose behaviour is governed modulo four.) Then:

- $N \bmod m$ is determined by $N \bmod L$, because $m$ divides $L$;
- $\gcd(N, c)$ is determined by $N \bmod L$, because $c$ divides $L$;
- $(a \mid N)$ is determined by $N \bmod L$, because the Jacobi symbol in its *lower* argument is periodic in $N$ with period $4a$, and $4a$ divides $L$.

So the whole elaborate instrument collapses. Everything it can see is a function of the single number $N \bmod L$. Call any such function — any map $f$ with the property that $f(M) = f(N)$ whenever $M$ and $N$ are odd and congruent modulo $L$ — an **observable of modulus $L$**. The battery is a bundle of observables of modulus $L$, and $N \bmod L$ is the finest observable of them all: everything the battery knows, it deduces from that one residue.

This is the crucial reframing. We no longer need to reason about Jacobi symbols and gcds separately, or worry that some ingenious new predicate might do better. Any predicate whatsoever of modulus $L$ — including ones nobody has invented yet — is covered. The question becomes: *how much does $N \bmod L$ tell you about the factors of $N$?*

The answer is: essentially nothing.

---

## The compensating partner

Here is the mechanism, and it is beautifully simple.

Suppose you suspect that a particular prime $p$ divides $N$, and you want to test that suspicion using the battery. Here is a devastating reply: **for essentially any $p$ you name, I can produce a completely different number, built from $p$, that your battery cannot distinguish from $N$.**

The recipe. Let $N_0$ be the target and $p$ your candidate, both coprime to $L$. Working modulo $L$, the number $p$ is invertible, so we may form the residue class

$$r \;=\; N_0 \cdot p^{-1} \pmod L.$$

This class is itself coprime to $L$. Now invoke Dirichlet's theorem on primes in arithmetic progressions — the celebrated result that every arithmetic progression $r, r+L, r+2L, \dots$ whose starting point is coprime to its step contains infinitely many primes. Pick any prime $q$ from that progression. Then

$$p \cdot q \;\equiv\; p \cdot (N_0 p^{-1}) \;\equiv\; N_0 \pmod L.$$

The semiprime $N' = pq$ has *exactly the same residue modulo $L$* as the target $N_0$. Therefore every observable of modulus $L$ returns identical values on $N'$ and $N_0$: the same residues, the same Jacobi symbols, the same gcds, the same everything. And since Dirichlet gives infinitely many such $q$, there are infinitely many such doppelgängers.

**The Class-Wide No-Pinning Lemma.** *Let $L$ be even, let $N_0$ (the target) and $p$ (the candidate factor) both be coprime to $L$. Then there are infinitely many primes $q$ such that every observable of modulus $L$ takes the same value on $pq$ as on $N_0$. Consequently no such battery can ever eliminate the candidate $p$.*

Let's watch it work. Take $B = 12$, so $L = 4 \cdot \operatorname{lcm}(1,\dots,12) = 110{,}880$, and take the target $N_0 = 221 = 13 \times 17$. Suppose you want to test the candidate $p = 19$. The compensating partner is $q = 17519$, and indeed $19 \times 17519 = 332861 \equiv 221 \pmod{110880}$. All thirty-six readings of the level-$12$ battery — twelve residues, twelve Jacobi symbols, twelve gcds — agree exactly on $332861$ and on $221$. Yet $\gcd(221, 332861) = 1$: the two numbers share no factor at all.

Run through every prime candidate below $80$, and the story repeats. Candidate $23$ pairs with $207307$; candidate $47$ with $4723$; candidate $79$ with $85619$. Every one of them survives. The battery, which returns thirty-six numbers, has narrowed the field of possible prime factors of $221$ by exactly nothing.

---

## Which candidates *can* be eliminated?

Not literally nothing — the theorem is sharp, and being sharp is what makes it a theorem rather than a slogan.

There is one way the battery can eliminate a candidate $p$. Suppose $p$ divides the modulus $L$. Then the residue channel modulo $p$ is part of the battery, and it can see whether $p \mid N$. If $N_0$ is not a multiple of $p$, then no number of the form $p \cdot n$ is congruent to $N_0$ modulo $L$, and the candidate $p$ is genuinely ruled out. This is the whole of the exception:

**Exact description of the pinned set.** *For a target $N_0$ coprime to $L$, a prime candidate $p$ admits infinitely many compensating partners if and only if $p$ does not divide $L$. The candidates the battery can eliminate — the **pinned** primes — are exactly the prime divisors of $L$.*

And now the counting. How many primes can divide $L$? Each contributes at least a factor of $2$, so if there are $k$ of them then $2^k \le L$, giving

$$k \;\le\; \log_2 L.$$

For our concrete level-$B$ battery, we can do better still: a prime divides $4\operatorname{lcm}(1,\dots,B)$ exactly when it is $2$ or is at most $B$. So the pinned set at level $B$ is precisely the primes up to $B$, at most $B$ of them.

At $B = 12$, the pinned primes are exactly $2, 3, 5, 7, 11$. Five candidates eliminated. Meanwhile the number of prime candidates that a factoring attack on an $n$-bit semiprime must consider is roughly $\sqrt{N}/\log N$ — an astronomically larger number. The battery removes a handful of pebbles from a mountain. Worse for the attacker: the pinned set *cannot* be enlarged without enlarging $L$, and the number of measurements you must take grows with $L$ too. The instrument can only see further by becoming exponentially larger.

---

## The price of pinning: the sealing bound

Turn the statement around and it becomes a lower bound — a statement about what a *successful* attack would have to cost.

**The sealing bound.** *If a modulus-$L$ battery eliminates $k$ prime candidates, then $2^k \le L$.*

Now consider what a real factoring algorithm needs. To factor a semiprime $N_0 = p_0 q_0$ by ruling candidates out, you must eliminate every prime below $X \approx \sqrt{N_0}$ except the two true factors. There are $\pi(X)$ primes below $X$, so the bound reads

$$L \;\ge\; 2^{\pi(X) - 2}.$$

By the prime number theorem $\pi(X) \approx X/\log X$, so for an $n$-bit semiprime the modulus of any pinning battery must have on the order of $2^{n/2}/n$ *bits*. Not be that large — have that many bits. A number whose description length is exponential in $n$ is not something you can write down, let alone compute with. This is the quantitative meaning of "sealed": pinning a factor by congruence data is not merely difficult, it is a task whose *input description* is exponentially long.

Stated as a slogan for the defence: a battery whose modulus is at most $2^k$ leaves at least $\pi(X) - 2 - k$ prime candidates below $X$ still alive.

---

## From no-pinning to no-factoring

So far the theorem is about candidates. It can be sharpened into an outright impossibility statement about *algorithms*, and here the argument becomes almost cheeky.

Apply the compensating-partner construction twice. Choose four large primes $p_1, q_1, p_2, q_2$, all distinct and all coprime to $L$, in such a way that the two semiprimes $N_1 = p_1 q_1$ and $N_2 = p_2 q_2$ land in the *same* residue class modulo $L$. (Pick $p_1, q_1, p_2$ freely, then use Dirichlet to choose $q_2$ so that $p_2 q_2 \equiv p_1 q_1$.) The two semiprimes are then coprime to each other — they share no prime factor — but every modulus-$L$ observable reads them identically.

Now suppose someone claims to have a factoring rule: a way of taking the battery readout and returning a nontrivial divisor of the input. Feed it $N_1$ and feed it $N_2$. The readouts are identical, so the rule returns the *same number* $d$ in both cases. By assumption $d > 1$ and $d$ divides $N_1$ and $d$ divides $N_2$. So $d$ divides $\gcd(N_1, N_2) = 1$. Contradiction.

**No factoring from congruence data.** *Fix any even modulus $L$ — of any size at all — any observable $f$ of modulus $L$, and any decoding rule $A$. Then $A \circ f$ fails to produce a nontrivial divisor for at least one semiprime coprime to $L$.*

Note what is *not* assumed here. The modulus $L$ need not be small. The decoding rule $A$ need not be computable — it can be an arbitrary function, an oracle, a lookup table of infinite size. The observable $f$ can take values in any set whatsoever. The only assumption is that the data being decoded is a function of $N \bmod L$. That assumption alone is fatal.

---

## Why it was always going to fail: the uniform hash

Underneath the analytic machinery lies a piece of pure group theory so simple it feels like a joke, and it explains the whole phenomenon.

In any group $G$, fix an element $u$ and ask: how many ordered pairs $(x, y)$ satisfy $xy = u$? The answer is $|G|$, no matter which $u$ you chose. The reason is that $x$ can be *anything*, and then $y = x^{-1}u$ is forced. The map $(x,y) \mapsto x$ is a bijection between the factorisations of $u$ and the group itself.

Multiplication in a group is a **perfectly uniform hash**. Every output has exactly the same number of preimages, and every element of the group appears as a first coordinate of a factorisation of every target.

Specialize to the multiplicative group of residues modulo $L$, which has $\varphi(L)$ elements (Euler's totient). Given that a semiprime $N$ lies in a particular residue class $u$, the number of possible classes for its first factor is $\varphi(L)$: *all of them*. The observed class of $N$ places no constraint whatsoever on the class of $p$. And the "no-pinning" theorem is the statement that this class-level freedom survives the passage from residue classes to actual primes — which is precisely what Dirichlet's theorem provides.

There is a converse worth recording, because it shows the data is not literally worthless: the battery *does* determine one thing exactly. If $p$ is a candidate, then any two compensating partners $q, q'$ satisfy $q \equiv q' \pmod L$. That is, once you guess the class of one factor, the class of the other is completely pinned down; the compensation map $x \mapsto u x^{-1}$ is an involution of the unit group swapping the two factor classes. The failure to pin a factor is not an information loss at the level of classes — it is that each class contains infinitely many primes, so knowing the class of $q$ narrows $q$ down not at all.

This is also the deep reason no cleverer predicate will help. All the battery's measurements are **symmetric functions of the pair $(p, q)$** — they see the product, not the operands. A symmetric function cannot break a symmetry. Whatever would distinguish $p$ from $q$ has to be something asymmetric, and no function of $N$ alone is asymmetric in the factors of $N$.

---

## The gcd that isn't there

One more temptation deserves killing, because it is the one everybody tries.

Instead of $\gcd(N, c)$ for small $c$, why not compute $\gcd(f(N), N)$ for some cunningly chosen polynomial $f$? Take $f(x) = 7x^3 + 5x + 12$; take $f(x) = x + k$; take anything. Surely feeding $N$ through a nonlinear map and then measuring its gcd with $N$ extracts something new?

It extracts nothing. For any polynomial $f$ with integer coefficients,

$$\gcd\big(f(N),\, N\big) \;=\; \gcd\big(f(0),\, N\big).$$

The proof takes one line. Write $f(x) = f(0) + x \cdot g(x)$ with $g$ an integer polynomial — always possible, since $f(x) - f(0)$ vanishes at $x = 0$ and hence is divisible by $x$. Then $f(N) = f(0) + N\,g(N)$, and adding a multiple of $N$ never changes a gcd with $N$.

So $\gcd(f(N), N)$ is nothing but $\gcd$ of $N$ with the constant term $f(0)$ — a fixed number chosen before you ever saw $N$. The special case $\gcd(N + k, N) = \gcd(k, N)$ is the one people discover first and are most disappointed by. In particular, $\gcd(7N^3 + 5N + 12, N) = \gcd(12, N)$ for every $N$ in existence. The polynomial was theatre.

---

## What survives

Let me be precise about what has and has not been shown, because the boundary is where the interesting mathematics lives.

**Shown, unconditionally:** any battery of measurements whose values depend only on $N$ modulo a fixed number $L$ is powerless to identify a factor. This holds for every $L$, for arbitrarily powerful decoding, and it covers the whole natural family — residues, Jacobi symbols, small gcds, polynomial gcds, and any predicate that anyone might invent within the class. The number of candidates such a battery can eliminate is at most $\log_2 L$, and eliminating a full search range costs a modulus exponential in the size of the input.

**Not shown, and genuinely open:** the converse. The complementary conjecture in this programme says that any quantity which *does* reveal a factor must necessarily require reading information "sealed" behind a computation of size proportional to $N$ itself. That direction remains unproved, and proving it would be a much bigger deal — it would begin to look like a genuine lower bound for factoring rather than a barrier against one family of attacks.

**Interestingly delicate:** the current no-pinning theorem is *qualitative in size*. Dirichlet supplies infinitely many compensating primes $q$, but says nothing about how large the smallest one is. Could an adversary pin a factor using the *magnitude* of $N$ in addition to its residue — insisting, say, that the compensating semiprime have the same bit-length as the target? Deep results on the least prime in an arithmetic progression (Linnik's theorem, whose exponent is now known to be at most $5$) say the smallest compensating partner is at most about $L^5$, so for the small moduli of a fast battery the doppelgänger is nearly the same size as the target. Making this fully quantitative — demanding that $pq$ land in a prescribed dyadic window — is the natural next theorem.

Beyond congruences, the next frontier is the **Euler-witness battery**: quantities like $a^{(N-1)/2} \bmod N$ for small $a$, which is the ingredient in the Solovay–Strassen test. This is not an observable of any fixed small modulus — the relevant modulus is $N$ itself — so the theorem above does not apply. But the structural reason for failure looks intact: $a^{(N-1)/2} \bmod pq$ is determined by a pair of Legendre symbols glued by the Chinese remainder theorem, and that datum is again symmetric in $p$ and $q$. The conjecture that the Euler-witness battery is also no-pinning is the obvious next target.

---

## The moral

There is a style of thinking in mathematics that deserves more publicity than it gets: proving that a search is hopeless, so that people search somewhere else. A barrier theorem is a map of where the treasure isn't.

What makes this particular barrier satisfying is how completely the difficulty dissolves once the right frame is found. As long as one thinks of a battery as "a big pile of clever tests," it is impossible to reason about — there are always more tests to invent. The moment one notices that every test in the family factors through a single number $N \bmod L$, the entire family becomes a single object, and the single object is transparently blind: the product map on a group is a uniform hash, and Dirichlet's theorem lifts that uniformity from residue classes to primes.

That is the shape of a good impossibility proof. Not a catalogue of failures, but one theorem that explains all of them at once — and the number $221$, sitting there with its two small factors, indistinguishable from a hundred thousand impostors.
