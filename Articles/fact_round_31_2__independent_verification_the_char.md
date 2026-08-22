# One Bit, and Not a Bit More

## What a prime number is allowed to tell you about a cubic equation

Take the humblest interesting cubic polynomial with integer coefficients that refuses to factor:

$$f(x) = x^3 + x + 1.$$

Over the rational numbers it is irreducible — no linear factor, no rational root. But modulo a prime $p$ it can, and usually does, break apart. Modulo $2$, for instance, $f$ stays irreducible. Modulo $5$ it factors as $(x+2)(x^2+3x+3)$: one root and one irreducible quadratic. Modulo $59$ it splits into three distinct linear factors. Three behaviours, three "splitting types", which we label by the degrees of the factors:

- **`111`** — three linear factors, $f$ splits completely;
- **`12`** — one linear and one quadratic factor;
- **`3`** — irreducible, $f$ stays whole.

Run through the primes and a striking regularity appears. The type `12` occurs about half the time; the type `3` about a third of the time; the rare, beautiful case `111` about one time in six. These are not empirical accidents. They are the **Chebotarev densities**, and they are dictated by a single group: the Galois group of $f$, which for $x^3+x+1$ is the full symmetric group $S_3$ on three letters, of order $6$. Its six elements come in three conjugacy classes — the identity (one element), the three transpositions, and the two three-cycles — and the fraction of primes with a given splitting type is exactly the fraction of the group occupied by the corresponding class:

$$\Pr[\texttt{111}] = \tfrac16, \qquad \Pr[\texttt{12}] = \tfrac12, \qquad \Pr[\texttt{3}] = \tfrac13.$$

So the splitting type of a random prime is a random variable $T$ with those three probabilities. How *unpredictable* is it? Information theory gives the answer in bits. Shannon's entropy of a distribution $(p_i)$ is $H = -\sum_i p_i \log_2 p_i$, and here

$$H(T) = -\tfrac16\log_2\tfrac16 - \tfrac12\log_2\tfrac12 - \tfrac13\log_2\tfrac13 = \tfrac23 + \tfrac{\log_2 3}{2} = 1.4591\ldots \text{ bits}.$$

A prime carries roughly one and a half bits of surprise about how the cubic will factor.

## The shortcut that almost works

Now for the classical shortcut. The discriminant of $x^3+x+1$ is $-31$. A theorem going back to the nineteenth century says that the parity of the factorization is legible from a *quadratic character*: the Legendre symbol $\left(\frac{-31}{p}\right)$, which is $+1$ or $-1$ according to whether $-31$ is a square modulo $p$. Concretely,

$$\left(\tfrac{-31}{p}\right) = \begin{cases} -1 & \text{if } p \text{ has type } \texttt{12},\\ +1 & \text{if } p \text{ has type } \texttt{111} \text{ or } \texttt{3}.\end{cases}$$

The reason is pure group theory: the Frobenius element attached to $p$ is a permutation of the three roots, and the Legendre symbol is precisely its **sign**. Transpositions are odd; the identity and the three-cycles are even.

What makes this shortcut so appealing is that the Legendre symbol is *cheap*. By quadratic reciprocity, $\left(\frac{-31}{p}\right)$ depends only on the residue of $p$ modulo $31$. You do not need to factor anything; you need a lookup table with $30$ entries. So here is the question this article is about:

> **How much of the $1.4591$ bits of splitting-type entropy can you buy with a lookup table?**

The answer, and it is exact, is: **one bit. Never more, never less.**

## Measuring the leak

The right measuring instrument is **mutual information**. If $T$ is the splitting type and $S$ is the sign — the Legendre symbol — then

$$I(T;S) = H(T) - H(T \mid S),$$

the amount by which knowing $S$ reduces your uncertainty about $T$. Compute the second term. Conditioned on $S = -1$ (odd Frobenius, probability $1/2$) the type is *certainly* `12`: no uncertainty at all, zero bits. Conditioned on $S = +1$ (even Frobenius, probability $1/2$) the type is `111` with conditional probability $\tfrac{1/6}{1/2} = \tfrac13$ and `3` with conditional probability $\tfrac{1/3}{1/2} = \tfrac23$. That residual coin is biased $1:2$, and its entropy is the binary entropy $H(\tfrac13,\tfrac23) = \log_2 3 - \tfrac23$. Averaging,

$$H(T \mid S) = \tfrac12 \cdot 0 + \tfrac12\left(\log_2 3 - \tfrac23\right) = \frac{\log_2 3}{2} - \frac13 = 0.4591\ldots \text{ bits}.$$

And now the subtraction, which is the whole story:

$$I(T;S) = \left(\tfrac23 + \tfrac{\log_2 3}{2}\right) - \left(\tfrac{\log_2 3}{2} - \tfrac13\right) = \frac23 + \frac13 = \boxed{1} \text{ bit exactly.}$$

The irrational parts cancel. Two transcendental-looking quantities, $1.4591\ldots$ and $0.4591\ldots$, differ by a perfect integer. That is not a numerical coincidence waiting to be explained away at the tenth decimal place; it is an identity, and it has a one-line reason.

## Why the answer is exactly one

The reason is a symmetry that information theory hands us for free: mutual information is symmetric, $I(T;S) = I(S;T)$. So instead of asking the hard question — *how much does the character tell you about the type?* — we may ask the easy one: *how much does the type tell you about the character?* And the answer to the easy question is **everything**, because the sign is a function of the cycle type. Knowing that $p$ has type `12` tells you the sign is $-1$; knowing it is `111` or `3` tells you the sign is $+1$. There is no residual uncertainty: $H(S \mid T) = 0$.

Therefore

$$I(T;S) = I(S;T) = H(S) - H(S\mid T) = H(S) - 0 = H(S).$$

And $H(S)$ is the entropy of a **fair** coin, because exactly half of $S_3$ is even: three of the six elements are transpositions. A fair binary read-out carries exactly one bit. Done.

That argument used nothing about $31$, nothing about cubics, nothing about primes. It used two facts: the character is a function of the class, and the character is balanced. This is why the theorem generalizes so violently.

## The abelian ceiling

Here is the general statement. Let $G$ be any finite group — think of it as the Galois group of some number field, with the uniform (Chebotarev) measure on its elements. Let $\chi : G \to C$ be any surjective homomorphism onto a finite **abelian** group $C$. Then:

**Theorem (Exact visible information).** *The Frobenius conjugacy class and the character $\chi$ share exactly $\log_2 |C|$ bits:*
$$I(\text{class};\chi) = \log_2|C|.$$

Two ingredients, mirroring the $S_3$ argument. First, a homomorphism into an abelian group is automatically a *class function*: if $y = cxc^{-1}$ then $\chi(y) = \chi(c)\chi(x)\chi(c)^{-1} = \chi(x)$ because $C$ commutes. So the conjugacy class always determines $\chi$, and the conditional entropy $H(\chi \mid \text{class})$ vanishes — no hypothesis required. Second, every fibre of a surjective homomorphism is a coset of its kernel, hence has exactly $|G|/|C|$ elements, so $\chi$ is perfectly balanced and $H(\chi) = \log_2|C|$. Subtract, and the theorem falls out.

**Theorem (The ceiling).** *Let $w$ be any read-out that is a function of $\chi$ — that is, $w = u \circ \chi$ for some map $u$. Then*
$$I(\text{class};w) \le \log_2|C|,$$
*and the bound is attained by $\chi$ itself.*

The proof is a two-step squeeze: mutual information never exceeds the entropy of either variable, $I(\text{class};w) \le H(w)$, and post-processing cannot manufacture entropy, $H(u\circ \chi) \le H(\chi) = \log_2|C|$.

Why does this deserve the name *ceiling*? Because of what "visible in the residue $p \bmod N$" means. Class field theory says, in essence, that the read-outs of the Frobenius that are congruence conditions on $p$ are precisely the read-outs that factor through the **abelianization** $G^{\mathrm{ab}} = G/[G,G]$ — the largest abelian quotient of $G$. The ceiling theorem then reads:

> **No congruence condition on $p$, of any modulus, can reveal more than $\log_2|G^{\mathrm{ab}}|$ bits about how $p$ factors.**

For $x^3+x+1$ we have $G = S_3$ and $G^{\mathrm{ab}} = C_2$, of order $2$. So the ceiling is $\log_2 2 = 1$ bit, and the Legendre symbol already attains it. There is no cleverer congruence, no larger modulus, no unnoticed pattern. The lookup table is optimal, and it captures $1$ of the $1.4591$ available bits — about $68.5\%$ of the entropy. The rest,

$$H(T \mid S) = H(T) - \log_2|G^{\mathrm{ab}}| = 0.4591\ldots \text{ bits},$$

is **locked behind the non-abelian structure of $S_3$**. It is not that we have failed to find the pattern; there is provably no pattern of that kind to find. To learn whether an even prime-Frobenius is the identity or a three-cycle, you must actually do arithmetic — factor the polynomial, or count points — because no amount of staring at $p \bmod 31$, or $p \bmod$ anything, will tell you.

## The dichotomy, and a sanity check

The theorem has a bright mirror image. If $G$ is itself abelian, take $\chi$ to be the identity map: it is surjective onto $C = G$, and the theorem gives $I = \log_2|G|$, the *entire* entropy of the Frobenius. An abelian field hides nothing. The classic example is $x^2+x+1$, or any cyclotomic field: knowing $p$ modulo the conductor tells you exactly how $p$ factors, with no residue left over. Quadratic reciprocity, in this light, is the statement that a quadratic field's splitting behaviour is *entirely* a congruence condition.

So the landscape is sharp:

| Galois group $G$ | $G^{\mathrm{ab}}$ | bits visible in a residue | bits hidden |
|---|---|---|---|
| $C_2$, $C_3$, any abelian | $G$ | $\log_2 \lvert G \rvert$ — everything | $0$ |
| $S_3$ (our cubic) | $C_2$ | $1$ | $0.4591\ldots$ |
| $S_4$, $S_5$, any $S_n$ | $C_2$ | $1$ | $H(T) - 1$, growing |
| $A_5$, any perfect group | trivial | $0$ | everything |

The middle rows are the interesting ones. For every symmetric group $S_n$ with $n \ge 2$, the sign character is surjective and balanced and a function of the cycle type, so the same computation gives **exactly one bit**, while the total cycle-type entropy $H(T)$ grows without bound as $n$ increases. The fraction of the arithmetic that is congruence-visible tends to zero. Quartic and quintic fields with full symmetric Galois group are, informationally speaking, almost entirely opaque to reciprocity laws — and yet each of them leaks exactly one clean bit, no more.

Finally, a word on a phenomenon that at first looks like a bug. If you scan residues $r \bmod 31$ and record the splitting types of primes $p \equiv r$, you find that some residue classes host **more than one splitting type**: the same residue produces both `111` primes and `3` primes. Fifteen of the thirty classes behave this way. Is the character failing?

No — this is exactly the theorem in visible form. The character separates *even* from *odd*, and nothing else. The fifteen residue classes with $\left(\frac{-31}{p}\right)=+1$ are the even ones, and inside the even class the split between the identity ($1$ element) and the three-cycles ($2$ elements) is $1:2$ *uniformly*, independently of the residue. Mixed-type residues are not noise; they are the fingerprint of the $0.4591$ hidden bits. A scan that found *pure* residue classes throughout would have contradicted the theorem.

## Why it matters

The result is a small, sharp instance of a very large theme: **abelian mathematics is computable, non-abelian mathematics is not — and you can put a number on the gap.**

Class field theory, the crowning achievement of early twentieth-century number theory, describes abelian extensions of number fields completely in terms of congruences. The Langlands program is, among other things, the enormous ongoing effort to say something comparable about the non-abelian case, where congruences are known to be insufficient. The theorem above quantifies *how* insufficient, in bits, and does so exactly rather than asymptotically: the total information is $H(T)$, the congruence-accessible part is precisely $\log_2|G^{\mathrm{ab}}|$, and the difference is a hard, provable floor on what any reciprocity law of abelian type can deliver.

There is a practical flavour to it too. Algorithms that test primes for a splitting condition often use the cheap Legendre symbol as a pre-filter before running an expensive polynomial factorization. The theorem says exactly how much work the filter can save: one bit of the $1.4591$, and it is optimal — no smarter congruence pre-filter exists. Conversely, it says that any algorithm needing the full splitting type must, on the even half of the primes, perform genuine algebra.

And there is something quietly satisfying in the arithmetic itself. Two entropies that look irrational, $1.4591\ldots$ and $0.4591\ldots$, and whose decimal expansions are governed by $\log_2 3$, are forced by an abstract symmetry to differ by exactly $1$. The $\log_2 3$'s cancel because they *must*: they measure the same hidden $1:2$ coin on both sides of the ledger. What survives the cancellation is the size of an abelian quotient — a single integer, $|G^{\mathrm{ab}}| = 2$ — and its logarithm is the number of bits the world is willing to show you.
