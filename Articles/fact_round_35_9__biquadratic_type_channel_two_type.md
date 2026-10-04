# Two Doors and a Clock with 24 Hours: The Polynomial That Hides Nothing

*How a single quartic, $x^4 - 10x^2 + 1$, behaves with perfect predictability across all the primes, and why a simple symmetry makes one natural question about it impossible to answer.*

---

## A polynomial with a secret identity

Take the number $\sqrt{2} + \sqrt{3}$. It is irrational, but not hopelessly so. Square it and you get $5 + 2\sqrt{6}$. Subtract $5$, square again, and the last square root goes away: $(x^2 - 5)^2 = 24$, which expands to

$$x^4 - 10x^2 + 1 = 0.$$

So $\sqrt2+\sqrt3$ is a root of a modest quartic with integer coefficients. The other three roots come from flipping signs: $\sqrt2-\sqrt3$, $-\sqrt2+\sqrt3$ and $-\sqrt2-\sqrt3$. Mathematicians call the number system these roots generate, $\mathbb{Q}(\sqrt2,\sqrt3)$, a *biquadratic field*. It is built from two independent square roots. Its symmetries are the four ways of choosing a sign for $\sqrt2$ and a sign for $\sqrt3$, so the symmetry group is the "Klein four-group" $V_4$: two independent switches, each of which can be on or off.

None of this looks remarkable yet. The interesting part starts when we stop working over the rational numbers and start working over the primes.

## Asking a polynomial a question at every prime

Pick a prime $p$ and do arithmetic "on a clock with $p$ hours", so that numbers wrap around after $p$. Every integer polynomial makes sense on this clock, and we can ask a concrete question: **how many hours $x$ on the $p$-hour clock satisfy $x^4 - 10x^2 + 1 \equiv 0 \pmod p$?**

A quartic could in principle have $0$, $1$, $2$, $3$ or $4$ roots. Here are a few primes:

- $p = 5$: try $x = 0,1,2,3,4$. The values are $1, 2, 2, 2, 2$ modulo $5$. **No roots.**
- $p = 7$: again no root on the clock.
- $p = 23$: **four roots**, namely $x = 2, 11, 12, 21$. For instance $2^4 - 10\cdot 2^2 + 1 = -23 \equiv 0 \pmod{23}$.
- $p = 47$ and $p = 73$: four roots again. Every other prime below $47$ has none.

What you never see is $1$, $2$ or $3$ roots. The polynomial either has all four roots or none at all. This is the first theorem of the story.

> **Theorem (Only two types).** For every prime $p \ge 5$, the polynomial $x^4 - 10x^2 + 1$ has exactly $4$ roots modulo $p$ if $p \equiv 1$ or $p \equiv 23 \pmod{24}$, and no roots otherwise.

So the behaviour at $p$ is decided by a different clock, one with **24 hours**. Reduce $p$ modulo $24$. If the answer is $1$ or $23$, the polynomial splits completely. If it is any of the other six possible values ($5, 7, 11, 13, 17, 19$), there are no roots.

## Why 24? Two switches, two clocks

The proof is short enough to tell completely, and it explains the two-switch structure.

First, a piece of algebra that works in any number system where $2 \ne 0$. Write the general biquadratic quartic as

$$B_{a,b}(x) = x^4 - 2(a+b)x^2 + (a-b)^2,$$

so that $x^4-10x^2+1$ is the case $a=2$, $b=3$. The quartic can be rearranged as a difference of squares in three different ways, one for each of the square roots $\sqrt a$, $\sqrt b$, $\sqrt{ab}$:

$$B_{a,b}(x) = (x^2 + a - b)^2 - 4a\,x^2 = (x^2 - a + b)^2 - 4b\,x^2 = (x^2 - a - b)^2 - 4ab.$$

Now suppose $x$ is a root. Then $x \neq 0$ when $a \neq b$, and the first rearrangement says $4a x^2$ is a perfect square, so $a$ itself is a square, namely the square of $(x^2 + a - b)/(2x)$. The second rearrangement shows in the same way that $b$ is a square. Conversely, if $a = \alpha^2$ and $b = \beta^2$, the four numbers $\pm\alpha\pm\beta$ are roots, and they are all different. So:

> **The root criterion.** Over any field in which $2 \neq 0$, and for $a \neq b$, the quartic $B_{a,b}$ has a root exactly when *both* $a$ and $b$ are perfect squares. In that case its roots are precisely $\pm\alpha\pm\beta$. Over a finite field with $a, b$ nonzero it therefore has either $4$ roots or $0$ roots, and nothing in between.

That explains the all-or-nothing behaviour. For our polynomial, the two switches are the questions "is $2$ a square modulo $p$?" and "is $3$ a square modulo $p$?". There is a root only when both switches are on.

Number theory answered both questions centuries ago with the *law of quadratic reciprocity* and its supplements:

- $2$ is a square modulo $p$ exactly when $p \equiv \pm1 \pmod 8$, so the first switch runs on an 8-hour clock;
- $3$ is a square modulo $p$ exactly when $p \equiv \pm1 \pmod{12}$, so the second switch runs on a 12-hour clock.

Both are on precisely when $p \equiv \pm 1 \pmod{24}$, and $24$ is the least common multiple of $8$ and $12$. That proves the theorem.

Could a smaller clock do the job? No. The primes $7$ and $23$ agree modulo $8$ (and so modulo $1$, $2$ and $4$) but have different types. The primes $13$ and $73$ agree modulo $12$ (and so modulo $3$ and $6$) but also have different types. Every proper divisor of $24$ divides $8$ or $12$, so **no proper divisor of 24 determines the type**. In the language of algebraic number theory, $24$ is exactly the *conductor* of $\mathbb{Q}(\sqrt2,\sqrt3)$.

## Broken everywhere, whole overall

One more fact deserves a moment because it surprises almost everyone the first time.

When the polynomial has no roots modulo $p$, it does not stay in one piece. It still splits into **two quadratic factors**. The reason is that among $2$, $3$ and $6 = 2 \cdot 3$, at least one is always a square modulo $p$: if neither $2$ nor $3$ is a square, their product is (two "minus signs" in the Legendre symbol multiply to a plus). Each of the three difference-of-squares rearrangements above then becomes a factorisation into two quadratics. This holds modulo $2$ and $3$ as well, so the quartic is reducible modulo **every** prime.

Over the rational numbers, however, it is irreducible. A direct computation rules out an integer root and rules out a factorisation into two integer quadratics, which would require $u^2 = 12$ or $u^2 = 8$ for some integer $u$. Gauss's lemma then carries this over to the rationals.

> **Local–global contrast.** The polynomial $x^4 - 10x^2 + 1$ is irreducible over $\mathbb{Q}$, yet it factors into two monic quadratics modulo every prime.

Group theory explains it. A quartic stays irreducible modulo $p$ only if some symmetry permutes all four roots in a single 4-cycle. The Klein group consists of two independent sign switches, and every one of its elements has order at most $2$, so it contains no 4-cycle. The pattern "4 roots, or two quadratic factors" is what you get when every symmetry squares to the identity.

## Measuring predictability in bits

So far this is classical number theory, told carefully. The new part is the bookkeeping. It treats the prime as a *message source* and the residue $p \bmod 24$ as a *side channel*, and measures in Claude Shannon's units of information how much the channel reveals.

Call the type of a prime $T(p)$: either "split" (4 roots) or "not split" (two quadratics). How uncertain is $T$? By Dirichlet's theorem on primes in arithmetic progressions, the primes spread out evenly over the eight residues $1,5,7,11,13,17,19,23$ modulo $24$. Two of the eight give "split", so in the long run a quarter of all primes split. The Shannon entropy of a coin that comes up heads with probability $1/4$ is

$$H(T) = h\!\left(\tfrac14\right) = \tfrac14\log_2 4 + \tfrac34 \log_2 \tfrac43 = 2 - \tfrac34\log_2 3 \approx 0.8113 \text{ bits.}$$

This exact closed form is the first quantitative result. Pinning the decimal down rigorously takes an estimate of $\log_2 3$, and two integer inequalities do it: $2^{84} < 3^{53}$ gives $\log_2 3 > 84/53$, and $3^{306} < 2^{485}$ gives $\log_2 3 < 485/306$. Together they give

$$0.8109 < H(T) < 0.8114.$$

In a computational experiment over a large finite set of primes, the measured entropy was $0.8074$ bits. It lies strictly below the theoretical limit, which means the sample contained slightly fewer split primes than a quarter, as finite samples sometimes do. The exact formula tells us where that number is heading.

### Full pinning

How much of those $0.81$ bits does the residue $p \bmod 24$ reveal? **All of it.** Mutual information $I(T; p \bmod 24)$ measures how far knowing the residue reduces the uncertainty about $T$. Since the type is a *function* of the residue, knowing the residue leaves no uncertainty, and

$$I(T;\ p \bmod 24) = H(T).$$

This is not just a limiting statement. It holds on **every** finite set of primes $p \ge 5$, whatever the sample, because the type is a deterministic function of $p \bmod 24$ for every individual prime. Every bit of uncertainty about how the polynomial factors is "pinned" by a single clock reading.

## Two primes at once: what a product reveals

Now let us make the game harder, in a direction that will sound familiar to anyone who has heard of public-key cryptography. Suppose we are given a semiprime $N = pq$, a product of two primes, but not the primes themselves. We can compute $N \bmod 24$. What does that tell us about the pair of types $(T(p), T(q))$?

Here the arithmetic of the 24-hour clock does something charming. Every one of the eight unit residues squares to $1$ modulo $24$: $5^2 = 25$, $7^2 = 49$, $11^2 = 121$, all $\equiv 1$. So the group of residues is again a collection of independent switches, $(\mathbb{Z}/24)^\times \cong C_2 \times C_2 \times C_2$. Fix the residue $c = N \bmod 24$. Exactly eight ordered pairs of residues $(p \bmod 24, q \bmod 24)$ multiply to $c$. Those eight pairs come in two kinds.

- If $c$ is $1$ or $23$, the pairs are "both split or both not". Two of the eight pairs are split–split and six are not–not, so the leftover uncertainty about the type pair is again $h(1/4)$.
- If $c$ is one of the other six residues, exactly one factor splits in four of the eight pairs (two pairs each way round), and neither does in the other four. The leftover uncertainty is $1.5$ bits.

The type pair carries $2h(1/4) = 4 - \tfrac32\log_2 3$ bits in total. Subtracting the average leftover uncertainty gives an exact formula:

> **Semiprime pair channel.** At the level of residue classes, the residue $N = pq \bmod 24$ carries exactly
> $$I\big((T(p),T(q));\ N \bmod 24\big) = \tfrac{19}{8} - \tfrac{21}{16}\log_2 3 \approx 0.2947 \text{ bits}$$
> about the pair of types.

The finite-sample experiment measured $0.2909$, close to the limit, as you would expect. The exact value is certified to lie between $0.2943$ and $0.2951$.

## The question that cannot be answered

Now the most striking result. Restrict attention to *mixed* semiprimes, where exactly one of the two primes splits. Ask the simplest possible question: **which one?** Is it $p$ or $q$?

The answer is one bit of genuine uncertainty. Among mixed pairs, "the first factor splits" and "the second factor splits" are exactly balanced. And the residue $N \bmod 24$ carries **exactly zero** bits about it. The experiment found $0.0001$ bits, which is numerical dust.

The reason has nothing to do with primes or reciprocity. It is a symmetry argument, and it works far more generally.

> **The swap-symmetry law.** Suppose a finite population carries a yes/no label $g$ and a side observation $k$. Suppose there is a reshuffling $\sigma$ of the population that (i) undoes itself when applied twice, (ii) leaves the observation $k$ unchanged, and (iii) always flips the label $g$. Then the observation carries **zero** information about the label: $I(g; k) = 0$.

The proof is short. Inside any group of individuals sharing the same observation, the reshuffling is a perfect matching between the "yes" individuals and the "no" individuals. So every such group is exactly half yes and half no. Learning the observation therefore leaves you at a fair coin flip, exactly where you started, and the label still carries one full bit.

For semiprimes, the reshuffling is simply **swapping the two factors**, $(p, q) \mapsto (q, p)$. Swapping twice changes nothing. Since multiplication is commutative, $pq = qp$, so $N \bmod 24$ is unchanged. And for a mixed pair, the swap turns "the first factor splits" into "the second factor splits". All three conditions hold, so the which-factor information is exactly zero. This is not because the question is trivial: the label is a full, honest bit. The residue is simply blind to it, and commutativity of multiplication is the reason.

## What the clock tells us, and what it cannot

Step back and look at the picture as a whole.

1. One algebraic identity, the threefold difference of squares, reduces the factorisation of a quartic to two yes/no questions. The answer is "four roots or none", over any field where $2\neq0$.
2. Quadratic reciprocity puts those two questions on clocks of $8$ and $12$ hours. Together they run on a 24-hour clock, and no smaller clock works.
3. Information theory turns this into exact numbers: $2 - \tfrac34\log_2 3$ bits of uncertainty per prime, all of it revealed by $p \bmod 24$; $\tfrac{19}{8} - \tfrac{21}{16}\log_2 3$ bits revealed about a pair of primes by their product; and exactly $0$ bits about which of the two is the special one.
4. The last zero comes from a symmetry law that needs no arithmetic at all, so it will apply verbatim to every other polynomial and every other modulus where the same swap argument goes through.

There is a pleasant moral for anyone who thinks about side channels in cryptography. An observation can reveal a great deal about the *unordered* contents of a secret and still be provably silent about its *order*, whenever the observation is symmetric. The 24-hour clock knows how many of your two primes are special. It can never know which one.

The same reasoning points to a family of further questions. Every field $\mathbb{Q}(\sqrt a,\sqrt b)$ should have its own clock, built from the least common multiple of the conductors of $\mathbb{Q}(\sqrt a)$ and $\mathbb{Q}(\sqrt b)$, and every one of them should have the same $h(1/4)$ bits of type entropy. Fields with three, four or more independent square roots should obey a closed-form pair-channel law, with $n = 2^k$ classes in place of four. The two doors and the 24-hour clock are the first case of what looks like a general and orderly theory.
