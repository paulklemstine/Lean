# The Wall With No Room to Spare

### How a one-line counting argument pins a number-theory conjecture exactly against its limit — and why an earlier reading of that limit was wrong

---

Imagine you are handed the numbers $1, 2, 3, \dots, n$ and asked to "catch" every one of them. To catch a number $i$ you must produce an integer that $i$ divides. That is easy if you are allowed one enormous integer: the least common multiple of $1, 2, \dots, n$ catches everything at once. The challenge is to catch all of $1,\dots,n$ using integers that are *not* enormous, while spending as few "moves" as possible.

That is the puzzle behind a conjecture in a recent paper by Umans and Wang (arXiv:2511.10851). Their version has a particular twist: the integers you get to use are not chosen freely. They are the **differences** between two small sets of numbers. This article explains what the conjecture asks, where its natural limit lies, why that limit was at one point misread, and why the parameter point everyone cares about sits *exactly* on the limit, with no room to spare.

---

## 1. The game: catching numbers with differences

Choose two finite sets of positive integers, $S$ and $T$. From them, form every difference $s - t$ with $s \in S$, $t \in T$. If $S$ has $a$ elements and $T$ has $b$ elements, you get up to $a \cdot b$ differences. That is many numbers bought with only $a + b$ choices.

> **The $n$-divisor property.** The pair $(S,T)$ has the *$n$-divisor property* if every integer $i$ with $1 \le i \le n$ divides at least one nonzero difference $s - t$.

Here is a tiny example. Take $S = \{7, 9\}$ and $T = \{1, 2\}$. The positive differences are $6, 5, 8, 7$. Every $i$ from $1$ to $8$ divides one of them: $1,2,3,6$ divide $6$; $4$ and $8$ divide $8$; $5$ divides $5$; $7$ divides $7$. So this pair has the $8$-divisor property, and its largest element is $9$. An exhaustive search over all pairs of two-element sets shows that $9$ is the smallest possible largest element for $n = 8$.

Two things cost us: the **size** of the sets ($|S|$ and $|T|$) and the **magnitude** of their elements. Umans and Wang measure both on a sliding scale in $n$:

> **The $(\alpha,\beta)$-Divisor Conjecture.** For infinitely many $n$ there exist sets $S, T$ of positive integers whose differences have the $n$-divisor property, such that
> 1. every element of $S$ and $T$ is at most $e^{n^{\alpha}}$, and
> 2. $|S|, |T| \le n^{\beta}$.

The conjecture is really a family of conjectures, one for each pair $(\alpha, \beta)$. The pair that matters for the authors' application is $\alpha = \beta = \tfrac13$: sets with about $n^{1/3}$ elements, each element having about $n^{1/3}$ digits. In their paper that parameter point is what would carry an algorithmic exponent from $\tfrac15$ down to $\tfrac16$.

So the question is which pairs $(\alpha,\beta)$ are possible at all.

---

## 2. Where is the wall?

Some pairs are clearly impossible. If both sets are tiny and their elements are small, the differences are too few and too small to catch everything up to $n$. The boundary between "maybe" and "impossible" is a **counting wall**, and it is worth getting exactly right.

At one point this wall was recorded as $\alpha + \beta \le 1$, with the trivial construction placed on that line. That is the wrong boundary. The correct statement, which is also the one in the original paper, is

$$
\boxed{\;\alpha \;\ge\; 1 - 2\beta\;}
$$

and the easy, trivial construction achieves $\alpha = 1 - \beta + o(1)$. The two lines are different, and the gap between them is exactly the open problem.

The argument for the wall is short enough to give in full.

**Step 1: everything divides the product.** Suppose $(S,T)$ catches every $i \le n$. Multiply together all the positive differences $s - t$ and call the result $P$. Each $i \le n$ divides one factor of $P$, so it divides $P$. A number divisible by each of $1, \dots, n$ is divisible by their least common multiple:

$$
\operatorname{lcm}(1, 2, \dots, n) \ \text{ divides } \ P.
$$

This is sharper than it first looks. It is not enough to catch every *prime* up to $n$. Every *prime power* up to $n$ must be caught too: $8$, $9$, $16$, $25$, and so on.

**Step 2: the product is not too big.** If every element of $S$ is at most $M$, then every positive difference is less than $M$. There are at most $|S|\cdot|T|$ of them, so

$$
P \le M^{|S|\cdot|T|}.
$$

**Step 3: the lcm is big.** The least common multiple of $1,\dots,n$ grows exponentially. A classical elementary way to see this uses the central binomial coefficient $\binom{2m}{m}$. Every prime power dividing $\binom{2m}{m}$ is at most $2m$, so $\binom{2m}{m}$ divides $\operatorname{lcm}(1,\dots,2m)$. And $\binom{2m}{m}$ is the largest of the $2m+1$ terms in the binomial expansion of $(1+1)^{2m} = 4^m$, so it is at least $4^m/(2m+1)$. Combining the three steps gives the **finite wall**:

$$
4^{\lfloor n/2 \rfloor} \;\le\; (n+1)\, M^{|S|\cdot|T|}.
$$

**Step 4: take logarithms.** Put $M = e^{n^\alpha}$ and $|S|,|T| \le n^\beta$. Then the right side has logarithm at most $\log(n+1) + n^{\alpha + 2\beta}$, while the left side is roughly $n \log 2$:

$$
(n-1)\log 2 \;\le\; \log(n+1) + n^{\alpha+2\beta}.
$$

If $\alpha + 2\beta < 1$, the right side grows like a power of $n$ smaller than $1$, and the left side grows linearly. So for large $n$ the inequality fails. Since the conjecture asks for *infinitely many* $n$, we must have $\alpha + 2\beta \ge 1$, which is the wall.

The "2" in front of $\beta$ is the point of the whole correction. It comes from the fact that two sets of size $n^\beta$ produce $n^{2\beta}$ differences. Reading the wall as $\alpha + \beta \le 1$ loses this factor, and with it the structure of the problem.

---

## 3. Zero slack

Now substitute the parameters that matter, $\beta = \tfrac13$:

$$
1 - 2\beta \;=\; 1 - \tfrac23 \;=\; \tfrac13 \;=\; \alpha .
$$

The target point $(\alpha,\beta) = (\tfrac13,\tfrac13)$ lies **exactly on the wall**. Lower $\alpha$ by any fixed amount below $\tfrac13$ and the counting argument rules the conjecture out completely. There is no slack at all.

This explains something about the application. The exponent $\tfrac16$ that the conjecture would deliver is not an arbitrary number that a cleverer construction might beat. It is a **floor** imposed by counting. Any method that goes through difference sets in this way cannot do better than the wall allows, and at $\tfrac13,\tfrac13$ the wall is reached with equality.

To feel the tightness, put numbers in the logarithmic inequality. At $\alpha=\beta=\tfrac13$ it reads $(n-1)\log 2 \le \log(n+1) + n$, which holds comfortably: at $n=1000$ the left side is about $692$ and the right side about $1007$. Shrink the exponent sum to $\alpha + 2\beta = 0.9$ and the right side becomes $\log(n+1) + n^{0.9}$. Already at $n = 100$ it loses ($68.6$ against $67.7$), and the gap only widens from there.

---

## 4. The trivial construction, and why it is *almost* optimal

How close can one get to the wall without any cleverness? Here is the easy construction.

Cut $1, 2, \dots, n$ into consecutive blocks of length $b$. For each block, multiply its numbers together and add $1$. Let $S$ be the set of these "block product plus one" numbers, and let $T = \{1\}$. Each difference $s - 1$ is a block product, so every $i$ divides the difference coming from its own block. The construction uses about $n/b$ elements in $S$, and each is at most $1 + n^b$.

Choose $b \approx n^{1-\beta}$. Then $|S| \approx n^\beta$, and the elements have logarithm about $n^{1-\beta}\log n$. That gives $\alpha = 1 - \beta + o(1)$, the "trivial" exponent.

Here is a useful observation. The wall really only involves the product $|S|\cdot|T|$ and the logarithm $\log M$. In the trivial construction,

$$
|S|\cdot|T|\cdot \log M \;\approx\; \frac{n}{b}\cdot 1 \cdot b\log n \;=\; n \log n,
$$

which is the wall's requirement $n\log 2$, up to a factor of $\log n$. **For lopsided sets, the counting wall is essentially tight.**

The conjecture asks for something harder. It wants the same efficiency from **balanced** sets, $|S| = |T| = n^\beta$, so that the product $|S|\cdot|T|$ becomes $n^{2\beta}$ rather than $n^{\beta}$. The difficulty is that the $n^{2\beta}$ differences are far from independent. They satisfy relations such as

$$
(s_1 - t_1) - (s_1 - t_2) \;=\; (s_2 - t_1) - (s_2 - t_2),
$$

so a table of $|S|\cdot|T|$ differences has only $|S| + |T| - 1$ real degrees of freedom. The open question can be put in one sentence: *can divisibility make as good use of these tightly structured differences as it makes of freely chosen numbers?*

---

## 5. A sanity check at the smallest scale

Is the wall $\operatorname{lcm}(1,\dots,n) \le M^{|S|\cdot|T|}$ ever met exactly? Yes, in the simplest case. When $S$ and $T$ each have a single element, the lone difference $s - t$ must be a positive multiple of $\operatorname{lcm}(1,\dots,n)$. Since $t \ge 1$, the smallest possible $s$ is exactly

$$
\operatorname{lcm}(1,\dots,n) + 1 .
$$

For $n = 10$ that is $2521$. The wall says $M \ge 2520$, and the true optimum is $2521$, so the wall is tight.

For two-element sets the wall predicts $M \gtrsim \operatorname{lcm}(1,\dots,n)^{1/4}$. A brute-force search for $n \le 10$ finds optimal covers within a factor of $3$ of this bound. For example, $n=10$ needs $M = 21$, achieved by $S=\{17,21\}$, $T=\{1,3\}$, against a predicted floor of about $7.1$. Small evidence, but consistent with the wall being the true obstacle.

---

## 6. A tempting shortcut that proves nothing

Umans and Wang's toolkit includes a lemma built on the Chinese Remainder Theorem. Let $U$ be the product of the primes up to $n$, and split it into pairwise coprime factors $U = U_1 \cdots U_\ell$. One can then find an arithmetic progression $b + c, b + 2c, \dots, b + \ell c$ whose $i$-th term is divisible by $U_i$. The paper gives an exact congruence criterion for when this works.

It is easy to run this and be impressed. A computer quickly finds, for many ways of splitting the primorial in two, a **two-term** progression containing a multiple of every prime up to $n$. For $n = 10$ the progression $20, 21$ already does it ($2$ and $5$ divide $20$; $3$ and $7$ divide $21$).

But this is no evidence of anything, and the reason is instructive. The Chinese Remainder Theorem gives such a progression for **any** step $c$ and **any** coprime split, and it even works with **one** term: the primorial itself is a one-term progression divisible by every prime. Hitting the primes is cheap. All the real content lies in how *large* $b$ and $c$ must be. The divisor property also needs every $i \le n$, prime powers included, to be caught by the *differences* of two small sets, not by a few progression terms.

The paper's companion obstruction makes this precise. Suppose that for every list of positive integers $A_1, \dots, A_\ell$, each at most $M$, there were numbers $A'_1, \dots, A'_{\ell'}$ in arithmetic progression, each at most $M'$, such that every $A_i$ divides some $A'_j$. Then either $\ell' \ge M^{\Omega(1)}$ or $M' \ge M^{\log\log M}$. In plain words, **generic** inputs cannot be handled cheaply. Only specially structured factorizations of the smooth number $U$ have any chance.

---

## 7. And randomness does not help either

One might hope to stumble on a good pair $(S,T)$ at random. Experiments say no. Draw $S$ and $T$ at random with $|S| = |T| \approx n^{1/3}$ and elements up to $e^{n^{1/3}}$, for $n = 64, 128, 256, 512$. A full cover never appears, and the fraction of $\{1,\dots,n\}$ that gets caught slides downward, from roughly $39\%$ to roughly $27\%$, as $n$ grows. Greedy searches likewise fail to produce a complete cover.

This is not evidence against the conjecture. Sitting exactly on a counting wall, a construction has no waste to spare, and random sets waste a lot: a typical number has few small divisors, so random differences catch only the easy $i$. Any successful construction will have to be **structured**.

---

## 8. Where this leaves us

Here is the state of play, stated precisely.

- **Proved:** if for infinitely many $n$ there are sets $S,T$ with the $n$-divisor property, elements at most $e^{n^\alpha}$ and sizes at most $n^\beta$, then $\alpha \ge 1 - 2\beta$. In finite form, $4^{\lfloor n/2\rfloor} \le (n+1)M^{|S||T|}$, and more sharply $\operatorname{lcm}(1,\dots,n) \le M^{|S||T|}$.
- **Proved:** the trivial block construction achieves $\alpha = 1 - \beta + o(1)$, and it is within a $\log n$ factor of the wall once $|T| = 1$.
- **Proved:** for one-element sets the optimum is exactly $\operatorname{lcm}(1,\dots,n)+1$.
- **Proved:** the Chinese-Remainder core of the progression lemma. For pairwise coprime moduli $U_0, \dots, U_{\ell-1}$ and any step $c$ there is a start $b$ with $U_i \mid b + (i+1)c$ for every $i$.
- **Open:** for infinitely many $n$, construct structured sets $S, T$ with $|S|, |T| \le n^{1/3}$ and elements at most $e^{n^{1/3}}$ whose differences catch every $i \le n$.

The conjecture lives on a knife's edge. Its target sits on the counting wall with zero slack, the easy construction misses by a factor of $n^{1/3}$ in the exponent, and the whole gap is a question about **balance**: whether a rank-one table of differences can be made to work as efficiently as a list of free numbers. Nobody yet knows. But the wall is now in the right place, and that tells us exactly where to look.
