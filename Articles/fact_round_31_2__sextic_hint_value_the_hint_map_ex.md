# The Hint That Grows When You Multiply

*How much can a single remainder tell you about the hidden primes inside a number? The answer turns out to be exact: it is a fixed number of bits, and it follows a strangely simple arithmetic law.*

---

## A game with a sealed envelope

Here is a game. I choose two large primes $p$ and $q$, multiply them, and hand you the product $N = pq$. The primes stay in a sealed envelope. This is the basic situation of modern public-key cryptography: multiplying is easy, and undoing the multiplication is believed to be hard.

You are not asked to factor $N$. Your task is smaller. Each prime has a small "fingerprint" that describes how it behaves inside a certain number system. You want to guess the *pair* of fingerprints of the two hidden primes. You don't need to know which fingerprint belongs to which prime, only the unordered pair.

You get two kinds of help. The **weak clue** is the remainder of $N$ when divided by a small prime, say $13$. The **strong clue** is the remainders of $p$ and $q$ themselves when divided by $13$. The strong clue needs a peek inside the envelope. The weak clue is available to anyone.

The **hint value** is the answer to one question: *how much more does the strong clue tell you than the weak clue?* It is measured in bits, the unit of information. One bit is the answer to a single fair yes-or-no question.

An experimental series of such "information batteries" estimated this hint value numerically for a sequence of number systems of increasing size. Its thirty-first round reached a field of degree $6$ and reported a hint of about $+1.6407$ bits. That was the first time the series had gone beyond degree five. The new work gets the exact answer:

$$\text{hint value} \;=\; \log_2 3 + \tfrac{1}{18} \;\approx\; 1.64052 \text{ bits}.$$

It then explains where that number comes from, and finds a general law for how hint values combine. The law is short enough to fit on a postcard.

## Fingerprints of primes: how primes split

To see what the fingerprints are, we need one idea from number theory: primes can *split*.

In ordinary whole numbers a prime is indivisible. But mathematicians routinely work in larger number systems, where you can also use numbers like $\sqrt{2}$ or $\cos(2\pi/13)$. In such a system an ordinary prime may break apart into several pieces, the way white light breaks into colours in a prism. The way it breaks is its **splitting type**.

The number system in round 31 is written $\mathbb{Q}(\zeta_{13})^+$. It is built from the real number $\cos(2\pi/13)$ and has "degree" $6$, meaning it is six-dimensional over the rationals. Its symmetries form a cyclic group of order six. Picture the six positions of a clock hand that can only point at the hours $0, 2, 4, 6, 8, 10$. In such a field, every prime $p$ other than $13$ has a **residue degree**, and it is always $1$, $2$, $3$ or $6$. The residue degree is the prime's fingerprint.

Here is the useful fact. The fingerprint depends only on the remainder $p \bmod 13$. Write that remainder as a power of a fixed generator $g$ of the nonzero remainders mod $13$ (for example $g = 2$), so that $p \equiv g^{a} \pmod{13}$. Then the fingerprint is the *order* of $a$ when you count modulo $6$:

$$T(a) = \frac{6}{\gcd(a, 6)}.$$

So the exponent $a = 0$ gives type $1$, $a = 3$ gives type $2$, $a = 2, 4$ give type $3$, and $a = 1, 5$ give type $6$.

This turns a question about primes into a question about a **clock with $n$ hours**. Each prime corresponds to a random hour $a$ on the clock. Its fingerprint is how many steps of size $a$ it takes to get back to $12$ o'clock. Multiplying primes corresponds to *adding* hours, because exponents add when powers multiply. So the weak clue, $N \bmod 13$, is just the sum $a + b$ on the clock. The strong clue is the pair $(a, b)$ itself.

## What the weak clue gives away

Now the game is completely concrete. Pick two random hours $a$ and $b$ on a six-hour clock. The label is the unordered pair $\{T(a), T(b)\}$. The weak clue is $a + b \bmod 6$.

The strong clue reveals the label completely, so the extra information it carries equals the uncertainty that is *left over* once you know the weak clue. In the language of information theory this is the conditional entropy of the label given $N$. Counting all $144$ ordered pairs of unit remainders mod $13$ gives three exact numbers:

* the label carries $2\log_2 3 - \tfrac{1}{18} \approx 3.1144$ bits in total;
* the weak clue $N$ reveals $\log_2 3 - \tfrac19 \approx 1.4739$ bits of it;
* so the hint value is the difference, $\log_2 3 + \tfrac1{18} \approx 1.6405$ bits.

The experiment had reported $1.4704$, $3.1110$ and $1.6407$. Those were finite-sample estimates, close to the truth but not equal to it. The reported hint is about $2 \times 10^{-4}$ bits too high. The reported total is about $3 \times 10^{-3}$ bits too low.

The hint value is exact because of a clean count. Group the $144$ pairs by the combination (label, $N$). You get exactly $12$ groups of size $2$, $26$ groups of size $4$ and $2$ groups of size $8$. Everything else is arithmetic with logarithms of $2$ and $3$.

## Two dials that each do the whole job

Round 31 also asked a finer question. Suppose you get the weak clue together with *one* more number: either the **sum** $s = p + q \bmod 13$ or the **gap** $d = p - q \bmod 13$. How much does each "dial" add?

Each dial alone gives you *the whole hint*. There is nothing left for the second dial to add.

The sum dial works for a reason every high-school student knows. If you know the product $pq$ and the sum $p + q$, then $p$ and $q$ are the two roots of

$$X^2 - sX + N = 0.$$

This is Vieta's formula, and it holds in arithmetic modulo $13$ just as it does over the real numbers. So you know the pair $\{p, q\}$ up to order, which is all the label needs.

The gap dial is more delicate. Knowing $pq$ and $p - q$ fixes the pair only up to the flip $(p, q) \mapsto (-q, -p)$. The flipped pair has the same product and the same gap. So why does the gap dial still pin down the fingerprint pair? Because the field $\mathbb{Q}(\zeta_{13})^+$ is **real**, and in a real cyclotomic field a prime's residue degree does not depend on the sign of its remainder: $u$ and $-u$ always have the same fingerprint. The flip changes the primes but not their fingerprints.

In the vocabulary of information decomposition, the two dials are *perfectly redundant*. Their "synergy" is

$$\text{synergy} = -\left(\log_2 3 + \tfrac1{18}\right),$$

which sits exactly on the theoretical floor $-\min(\text{sum hint}, \text{gap hint})$. It is also comfortably below the ceiling of one bit. The experiment described this as "walls clean," and the exact values confirm it.

For comparison, the sum dial *without* the product is much weaker. It carries only

$$2\log_2 3 + \tfrac{29}{36} - \tfrac{11}{12}\log_2 11 \approx 0.804 \text{ bits}.$$

A $\log_2 11$ appears because one sum value ($s = 0$) is hit by $12$ pairs, while every other value is hit by $11$.

## The hint map: one number for every clock

Nothing in the clock picture needs the number $6$. For every clock size $n$ we can define the **hint map** $h(n)$. Pick two random hours $a, b$ on an $n$-hour clock, and let $h(n)$ be the uncertainty that remains about $\{T(a), T(b)\}$ once $a + b$ is known. Here $T(a) = n / \gcd(a, n)$.

The first few values are exact:

| clock size $n$ | $h(n)$ (bits) | decimal |
|---|---|---|
| $2$ | $\tfrac12$ | $0.5000$ |
| $3$ | $\log_2 3 - \tfrac23$ | $0.9183$ |
| $4$ | $\tfrac98$ | $1.1250$ |
| $5$ | $\log_2 5 - \tfrac{12}{25}\log_2 3 - \tfrac{16}{25}$ | $0.9211$ |
| $6$ | $\log_2 3 + \tfrac1{18}$ | $1.6405$ |

This is the sense in which *the hint extends beyond degree five*. The degree-6 value is larger than every earlier one. But the map does not simply grow: $h(5)$ is *smaller* than $h(4)$. The exact order is

$$h(2) < h(3) < h(5) < h(4) < h(6).$$

Some bounds always hold. The hint is never negative. It never exceeds the total uncertainty of the label. And it never exceeds $\log_2 n$, because each value of $a + b$ is produced by exactly $n$ ordered pairs, and you cannot be more uncertain than a uniform choice among $n$ options.

## The postcard law

Why is $6$ so generous? Because $6 = 2 \times 3$, and a six-hour clock *is* a two-hour clock and a three-hour clock running side by side. This is the **Chinese Remainder Theorem**: knowing an hour mod $6$ is the same as knowing it mod $2$ and mod $3$. The fingerprints combine too. The order of $a$ mod $6$ is the product of its orders mod $2$ and mod $3$.

If information simply added, we would expect $h(6) = h(2) + h(3)$. It doesn't:

$$h(6) - h(2) - h(3) = \left(\log_2 3 + \tfrac1{18}\right) - \tfrac12 - \left(\log_2 3 - \tfrac23\right) = \tfrac29.$$

There is an extra $2/9$ of a bit. The main new theorem says this extra amount is not an accident. It follows a universal rule.

> **The CRT Defect Law.** Let $\delta(n)$ be the probability that two random hours on an $n$-hour clock have *different* fingerprints. Then for any two clock sizes $m$ and $n$ with no common factor,
> $$h(mn) = h(m) + h(n) + \delta(m)\,\delta(n).$$

At $6 = 2 \times 3$: $\delta(2) = \tfrac12$ and $\delta(3) = \tfrac49$, so the defect is $\tfrac12 \cdot \tfrac49 = \tfrac29$, exactly as observed. It also works at $10$, $12$, $15$ and at every other coprime product. Since $\delta(n) > 0$ whenever $n \ge 2$ (the hours $0$ and $1$ always have different fingerprints), the inequality is strict. **Every composite clock built from coprime pieces carries strictly more hint than its pieces put together.**

## Where the extra information hides

The proof is short, and it rests on one idea about forgetting order.

Take any random pair of readings $(x, y)$ drawn independently from the same distribution. Now forget which came first and keep only the unordered pair $\{x, y\}$. How much information did you lose? Exactly this much:

$$H(\{x, y\}) = H(x, y) - \Pr(x \neq y).$$

The reason is simple. When $x = y$, forgetting the order loses nothing, because there was no order to forget. When $x \ne y$, the unordered pair corresponds to exactly two equally likely ordered pairs, so forgetting the order loses exactly one bit. On average you lose one bit times the probability that the two readings differ.

With this in hand, the law comes from sorting quantities into those that add and those that don't:

1. **The fingerprint entropy adds.** A fingerprint mod $mn$ is a fingerprint mod $m$ together with a fingerprint mod $n$, and those two are independent.
2. **What the weak clue reveals adds.** The weak clue mod $mn$ splits the same way, into a clue mod $m$ and a clue mod $n$. And forgetting order costs the weak clue nothing extra, because swapping $p$ and $q$ does not change $N$.
3. **Only the order correction fails to add.** The total label uncertainty is twice the fingerprint entropy minus $\delta$. Fingerprints mod $mn$ agree exactly when they agree mod $m$ *and* mod $n$. So the probabilities of agreement multiply: $1 - \delta(mn) = (1 - \delta(m))(1 - \delta(n))$. Expanding gives

$$\delta(m) + \delta(n) - \delta(mn) = \delta(m)\,\delta(n).$$

So the whole defect is the probability that the two hidden primes are *doubly distinct*: different fingerprints in the mod-$m$ view **and** in the mod-$n$ view. On that event the combined clock loses one bit of order information, where the two small clocks would together have "lost" two. That difference is where the extra hint comes from.

## A bonus from counting

The distinctness probability has a closed form. On an $n$-hour clock, the number of hours with fingerprint exactly $d$ is Euler's totient $\varphi(d)$. So the number of pairs with *equal* fingerprints is $\sum_{d \mid n} \varphi(d)^2$, and

$$\delta(n) = 1 - \frac{1}{n^2}\sum_{d \mid n} \varphi(d)^2.$$

For example, $\delta(6) = 1 - \tfrac{1 + 1 + 4 + 4}{36} = \tfrac{13}{18}$.

Combining this with the multiplication rule $1 - \delta(mn) = (1 - \delta(m))(1 - \delta(n))$ proves that the arithmetic function $n \mapsto \sum_{d\mid n}\varphi(d)^2$ is *multiplicative*. Number theorists usually get this from Dirichlet convolution. Here it falls out of an information-theory argument about unordered pairs of primes.

## Why a physicist might care

"Hint values," "dials," "synergy" and "redundancy" are the vocabulary of *information decomposition*. Neuroscientists and physicists use it to ask how several sensors share knowledge about one hidden source. Such decompositions are usually estimated from data and argued over. Here is a rare case where every term is an exact closed form: each is built from $\log_2 3$, $\log_2 5$, $\log_2 11$ and small fractions. The redundancy floor is hit exactly, and there is a structural reason for it: Vieta's formula plus the reality of a field.

The CRT defect law also shows a general pattern. When a system splits into independent parts, most information measures add. The exception is any quantity built on *forgetting order*, that is, on treating two particles or two primes as indistinguishable. Such a quantity picks up a correction equal to the probability that the parts are distinguishable in both components at once. Physicists will recognise this from the entropy of identical particles: symmetrising a two-particle state costs one bit exactly when the particles are in different states.

## What comes next

Several conjectures are open, supported by computation but not yet proved.

* **Prime clocks.** For a prime $q$, only two fingerprints occur ($1$ and $q$). Computation up to $q = 19$ agrees to twelve digits with
  $$h(q) = \frac{q-1}{q}\, H_b\!\left(\tfrac2q\right) + \frac1q\, H_b\!\left(\tfrac1q\right),$$
  where $H_b$ is the binary entropy function. This would mean the hint at prime rungs slowly fades to zero. Combined with the defect law, prime *powers* would then be the only remaining unknowns in the whole hint map.
* **Every conductor.** The same hint value $h(n)$ appears to arise for the degree-$n$ subfield of *every* prime cyclotomic field $\mathbb{Q}(\zeta_f)$. Computations for $f = 7, 11, 13, 17$ match perfectly. For $f = 13$, $n = 6$ this is now a theorem.
* **Reality and the gap dial.** In non-real fields the flip $(p, q) \mapsto (-q, -p)$ *does* change fingerprints, and the gap dial falls short. For example, in the degree-4 subfield of $\mathbb{Q}(\zeta_{13})$ it carries only $0.5$ of the $1.125$ available bits. The conjecture is that the gap dial pins the label exactly when the field is real.

For round 31 the result is settled: the exact hint at degree six is $\log_2 3 + \tfrac1{18}$ bits, and every coprime composite degree carries an extra $\delta(m)\delta(n)$ bits beyond its parts.
