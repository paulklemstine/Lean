# Four Fields, One Answer: Why Every Cube-Root Equation Knows the Same Secret

*How a one-bit message hidden inside the prime numbers turned out to be not a coincidence, but a law.*

---

## A measurement that refused to vary

Imagine you are running a laboratory whose instruments are prime numbers. You feed each prime $p$ into a machine, and the machine prints a single small number. You never see $p$ itself, only the printout. Then you ask a question from information theory: how much does the printout tell me about $p$?

That is the experiment behind this story. The machine is a simple one. Fix an integer $c$, say $c = 7$, and look at the equation

$$x^3 = c.$$

Instead of solving it over the real numbers, where there is always exactly one real cube root, solve it in **clock arithmetic modulo $p$**, the finite world of remainders $\{0, 1, \dots, p-1\}$ where you add and multiply and then keep only the remainder after dividing by $p$. In that world the equation can have no solutions, one solution, or three solutions. The machine prints that count. Call it the **type** of $p$ and write it $T(p)$.

For $c = 7$ the first few printouts go like this:

- $p = 5$: the only cube root of $7$ modulo $5$ is $x = 3$, since $3^3 = 27 \equiv 2 \equiv 7 \pmod 5$. So $T(5) = 1$.
- $p = 13$: the nonzero cubes modulo $13$ are only $1, 5, 8, 12$. Seven is not among them, so $T(13) = 0$.
- $p = 19$: here $4^3$, $6^3$ and $9^3$ are all congruent to $7$ modulo $19$. So $T(19) = 3$.

Now the question: what does the type know about the prime? Researchers measured one specific thing, namely how much the type reveals about $p$ **modulo 3**, that is, whether $p$ leaves remainder $1$ or $2$ on division by $3$. They measured it with the standard ruler of information theory, the **mutual information** $I(p \bmod 3;\, T)$, over all primes below $1000$.

The answer came out as $1.0000$ in normalised form. The type revealed *everything* about $p \bmod 3$.

Then they did it again with a different equation, $x^3 = 2$. The same answer. Then $x^3 = 3$, then $x^3 = 5$. The same answer every time. The equation $x^3 = 7$ was the fourth such experiment, and it came with a new discriminant, $-1323$. Four different number fields, four different fingerprints, one answer.

When nature hands you the same number four times, you have two choices. You can run a fifth experiment. Or you can ask *why*. This article is about the *why*, and about the pleasant fact that once you find it, there is nothing left to measure.

---

## A crash course in information

Mutual information needs only two ideas.

The **entropy** $H(X)$ of a random quantity $X$ measures, in bits, how uncertain you are about it. A fair coin has entropy exactly $1$ bit. A coin that always lands heads has entropy $0$. In general, if $X$ takes values with probabilities $q_1, q_2, \dots$, then

$$H(X) = -\sum_i q_i \log_2 q_i.$$

The **mutual information** between $X$ and $Y$ is the amount of uncertainty about $X$ that disappears once you learn $Y$:

$$I(X; Y) = H(X) + H(Y) - H(X, Y).$$

If $Y$ tells you nothing about $X$, this is $0$. If $Y$ tells you everything, so that $X$ can be computed from $Y$, then $I(X;Y) = H(X)$: all of $X$'s uncertainty is wiped out.

In our laboratory, the "random quantity" is a prime drawn uniformly from some finite list, such as all primes below $1000$. Then $p \bmod 3$ is a coin with sides $1$ and $2$, and the type $T$ is a three-sided die with faces $0$, $1$ and $3$.

---

## The law behind the number

Here is the fact that makes the measurement inevitable.

> **The Type-Channel Law.** Let $c$ be any integer and let $p$ be any prime that does not divide $3c$. Then $x^3 = c$ has exactly one solution modulo $p$ if and only if $p \equiv 2 \pmod 3$. When $p \equiv 1 \pmod 3$, it has either no solutions or three.

The proof fits on a napkin. The nonzero remainders modulo $p$ form a **cyclic group** of size $p - 1$: there is a single element $g$ whose powers $g, g^2, \dots, g^{p-1}$ run through all of them. Cubing, $x \mapsto x^3$, is then a map from this group to itself.

- If $3$ does **not** divide $p - 1$, which for a prime $p \ne 3$ means $p \equiv 2 \pmod 3$, then cubing is a bijection. Every nonzero $c$ has exactly one cube root.
- If $3$ **does** divide $p - 1$, which means $p \equiv 1 \pmod 3$, then there are three cube roots of unity: three numbers whose cube is $1$. Cubing collapses them to a single value, so it is three-to-one. Any $c$ that has a cube root then has exactly three, and a $c$ that is not a cube has none.

That is all. The count $1$ can only occur when $p \equiv 2$, and it always occurs then.

The condition "$p$ does not divide $3c$" matters. If $p$ divides $c$, the equation becomes $x^3 = 0$ modulo $p$, which has the single root $0$ whatever $p$ is. For $c = 7$ and $p = 7$ this gives $T = 1$ although $7 \equiv 1 \pmod 3$. At $p = 3$, the equation $x^3 = 7$ becomes $(x-1)^3 = 0$, again one root, although $3$ is not $2$ modulo $3$. These **ramified** primes are exactly where the law breaks, and they are exactly the primes the experiment excluded.

The law gives a decoding rule, the same for every $c$:

$$\text{if } T = 1, \text{ guess } p \equiv 2; \qquad \text{if } T \in \{0, 3\}, \text{ guess } p \equiv 1.$$

This rule never fails at an unramified prime. It does not care whether $c$ is $2$, $3$, $5$, $7$, or $1{,}000{,}003$. **Four fields, one answer** is really *every pure cubic field, one decoder*.

The actual counts for $x^3 = 7$ over the $166$ unramified primes below $1000$ show it at a glance:

| | $T = 0$ | $T = 1$ | $T = 3$ |
|---|---|---|---|
| $p \equiv 1 \pmod 3$ | $54$ | $0$ | $25$ |
| $p \equiv 2 \pmod 3$ | $0$ | $87$ | $0$ |

The two zeros in the top row and the two zeros in the bottom row are the whole law. Each column lies in a single row.

---

## "Exactly 1.0000": what it does and does not mean

Now for a quiet correction that turns out to be the most interesting part.

The headline said $I(p \bmod 3; T) = 1.0000$ *exactly*. But look again at the table. There are $79$ primes congruent to $1$ and $87$ congruent to $2$. That coin is slightly unfair, so its entropy is not quite one bit:

$$H(p \bmod 3) = 0.99832\ldots \text{ bits}.$$

Since the type determines $p \bmod 3$, the mutual information equals this entropy, so $I = 0.99832\ldots$ as well. It is not $1$. What *is* exactly $1$ is the ratio

$$\frac{I(p \bmod 3;\, T)}{H(p \bmod 3)} = 1.$$

This is the precise content of the experiment, and it follows from a general principle.

> **The Pinning Theorem.** On any finite sample, if a quantity $f$ can be computed from another quantity $g$, then $I(f; g) = H(f)$ exactly.

The reason is short. If $f$ is a function of $g$, then knowing the pair $(f, g)$ is the same as knowing $g$ alone, so $H(f, g) = H(g)$, and the formula for mutual information collapses to $H(f)$. Renaming the values of a variable without merging any of them does not change its entropy, and that fact does the work.

Combined with the type-channel law, it yields:

> **The Sample Law.** For every integer $c$ and every finite collection of primes not dividing $3c$, $I(p \bmod 3;\, T) = H(p \bmod 3)$.

So the four experiments were never going to disagree. Nor was a fifth, or a thousandth. The measured value "1.0000" is the entropy of a nearly-fair coin, rounded to four places, and it is *exactly* one bit only when the sample happens to be perfectly balanced. For example, the four primes $5, 11, 13, 19$ contain two of each residue class. For $x^3 = 7$ their types are $1, 1, 0, 3$, and on this little sample the mutual information is exactly one bit, with no rounding at all.

This is a useful lesson in reading numbers. An exact identity was hiding behind an approximate measurement, and the identity is more informative than the measurement: it tells you the normalised value is $1$ for *every* sample, balanced or not.

---

## The deeper reason: three roots, six shuffles

Why should a cube-root equation care about $p \bmod 3$ at all? The answer comes from Galois theory, and it explains why the balanced value of exactly one bit is the "true" value.

The three complex roots of $x^3 - 7$ are $\sqrt[3]{7}$, $\omega\sqrt[3]{7}$ and $\omega^2\sqrt[3]{7}$, where $\omega$ is a primitive cube root of unity. The symmetries of these roots form the group $S_3$ of all six permutations of three objects. To each unramified prime $p$, arithmetic attaches a particular permutation, the **Frobenius element**, and two facts connect it to our experiment:

1. The number of roots of $x^3 - 7$ modulo $p$ equals the number of roots the Frobenius permutation **fixes**.
2. The **sign** of the Frobenius permutation (even or odd) records how $p$ behaves in the smaller field generated by $\omega = \frac{-1 + \sqrt{-3}}{2}$. That behaviour is decided by $p \bmod 3$: even if $p \equiv 1$, odd if $p \equiv 2$.

Now just look at $S_3$:

| permutation type | how many | fixed points | sign |
|---|---|---|---|
| identity | $1$ | $3$ | even |
| transposition | $3$ | $1$ | odd |
| 3-cycle | $2$ | $0$ | even |

In $S_3$, **a permutation is odd exactly when it fixes one point**. That is the type-channel law, seen from the group's side.

The **Chebotarev density theorem**, a large-scale equidistribution law for primes, says that Frobenius elements are spread over $S_3$ in proportion to these class sizes: in the long run, $1/6$ of primes split completely, $1/2$ have one root, and $1/3$ have none. So the idealised experiment is: pick one of the six permutations uniformly at random and ask how much its fixed-point count tells you about its sign. Here the coin is perfectly fair, three even and three odd, and the answer is

$$I(\text{sign};\ \#\text{Fix}) = 1 \text{ bit exactly}.$$

This is the one bit the experiment was reaching for. Finite samples of primes hover near the Chebotarev proportions, and the measured value hovers just below it.

---

## The type knows more than it's telling

There is one more twist. The type is a three-valued quantity, and one bit does not use it up. In the $S_3$ model its entropy is

$$H(\#\text{Fix}) = \tfrac16\log_2 6 + \tfrac12 \log_2 2 + \tfrac13 \log_2 3 = \frac23 + \frac{\log_2 3}{2} \approx 1.459 \text{ bits}.$$

The leftover,

$$H(T) - I = \frac{\log_2 3}{2} - \frac13 \approx 0.459 \text{ bits},$$

is strictly positive. It is more than $5/12$, because $2^3 < 3^2$ forces $\log_2 3 > 3/2$. That leftover is the information that separates "split completely" from "no roots" among primes $\equiv 1 \pmod 3$. The primes $13$ and $19$ are both $1$ modulo $3$, but $x^3 = 7$ has no roots modulo $13$ and three roots modulo $19$. The type is a strictly *finer* description of the prime than its residue modulo $3$.

That finer information follows its own clean law, visible when you fix the prime and vary $c$ instead. For any finite field of size $q$ with $q \equiv 1 \pmod 3$, **exactly one third** of the nonzero constants $c$ make $x^3 - c$ split into three roots, and **exactly two thirds** leave it irreducible, with no roots at all. That $1 : 2$ ratio is the ratio of the identity to the two 3-cycles inside the even permutations of $S_3$. Chebotarev's proportions appear here as an exact count, with no limits needed.

---

## Where the magic stops

A good law comes with its boundaries clearly marked, and this one has three.

**Ramified primes.** As we saw, $p = 3$ and primes dividing $c$ break the law. For $x^3 = 7$ both $p = 3$ and $p = 7$ give exactly one root, although neither is $2$ modulo $3$.

**Higher exponents.** The same cyclic-group argument shows that for any prime exponent $\ell$ and $c \ne 0$, the equation $x^\ell = c$ has exactly one solution in a field of size $q$ if and only if $\ell$ does not divide $q - 1$. But for $\ell = 5$ the type no longer pins down $p \bmod 5$. The equation $x^5 = 2$ has exactly one root modulo $7$ and exactly one root modulo $13$, yet $7 \equiv 2$ and $13 \equiv 3 \pmod 5$. The type only detects whether $p \equiv 1 \pmod \ell$. That single yes/no bit is *all* of $p \bmod \ell$ only when there are just two nonzero residues, which happens only for $\ell = 3$. The number three is special here.

**Non-pure cubics.** It would be tempting to say "every cubic with symmetry group $S_3$ obeys the $p \bmod 3$ law". It doesn't. The cubic $x^3 - x - 1$, with discriminant $-23$ and full $S_3$ symmetry, has exactly one root modulo $5$ and exactly one root modulo $7$, although $5 \equiv 2$ and $7 \equiv 1 \pmod 3$. For a general cubic, the type tracks whether the discriminant is a square modulo $p$, not $p \bmod 3$. The pure cubics $x^3 - c$ are special because their discriminant is $-27c^2$, and whether that is a square modulo $p$ depends only on whether $-3$ is, which is decided by $p \bmod 3$.

---

## The moral

The story began with a number that kept coming out the same, and the temptation was to keep measuring. The better move was to find the reason, and the reason turned out to be a few lines of group theory: cubing is a bijection on a cyclic group exactly when $3$ does not divide its order. From that one fact, and the observation that information is preserved under relabelling, come the whole chain of results:

- the **Type-Channel Law** ($T = 1 \iff p \equiv 2 \bmod 3$, for every $c$);
- a **universal decoder** that works for every pure cubic;
- the **Sample Law** ($I = H(p \bmod 3)$ on every sample, so the normalised value is exactly $1$);
- the **exact one bit** on balanced samples and in the $S_3$ model;
- the **strict gap** of $\tfrac{\log_2 3}{2} - \tfrac13$ bits that the type holds beyond $p \bmod 3$;
- and sharp **counterexamples** showing where each claim stops.

The four fields gave one answer because there was only ever one question: *what is the sign of the Frobenius permutation?* For a pure cubic, that sign is $p \bmod 3$, and the root count always reveals it.
