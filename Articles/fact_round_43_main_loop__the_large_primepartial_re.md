# The Large Prime That Wasn't a Loophole

*How a one-line argument from 18th-century number theory closes a tempting shortcut in the quadratic sieve*

---

## A factoring machine and its bookkeeping

Every time your browser opens a secure connection, it relies on a quiet bet: that nobody can quickly split a large number $N$ into its two prime factors. The best algorithms for attacking that bet are *sieves*. The oldest practical one, the **quadratic sieve**, works from a simple observation. If you can find two numbers $X$ and $Y$ with

$$X^2 \equiv Y^2 \pmod N, \qquad X \not\equiv \pm Y \pmod N,$$

then $\gcd(X - Y, N)$ is a proper factor of $N$. The hard part is producing such a pair of squares.

The quadratic sieve does it by assembling the squares from smaller pieces. Take integers $c$ a little above $\sqrt N$ and look at

$$f(c) = c^2 - N.$$

Because $c$ is close to $\sqrt N$, the number $f(c)$ is small, roughly $2c\cdot(c-\sqrt N)$, which is far smaller than $N$ itself. Small numbers are much more likely to be **smooth**, meaning that all of their prime factors lie below some bound $B$. Every smooth value is recorded as a **relation**:

$$c^2 \equiv f(c) = p_1^{e_1} p_2^{e_2} \cdots p_k^{e_k} \pmod N .$$

Now the algorithm turns into linear algebra. Write down each relation's exponents *modulo 2*. That gives a row of zeros and ones, with one column for each prime that may occur. Once you have more rows than columns, some nonempty set of rows must add up to zero modulo 2. Multiply those relations together. Every prime then appears to an even power on the right-hand side, so the right-hand side is a perfect square $Y^2$, and the left-hand side is the square $X^2$ of the product of the $c$'s. The required congruence appears.

So the cost of the whole method comes down to one comparison: **how many rows can you harvest, against how many columns do you have to beat?**

## Not every prime gets a column

Here the method has a feature that newcomers often find surprising. Not every prime below $B$ gets a column. A prime $r$ can divide some $f(c) = c^2 - N$ only if

$$c^2 \equiv N \pmod r,$$

that is, only if $N$ is a perfect square modulo $r$. In the language Legendre introduced in 1798, the **Legendre symbol** $\left(\frac{N}{r}\right)$ is $+1$ when $N$ is a nonzero square modulo the odd prime $r$, $-1$ when it is not, and $0$ when $r$ divides $N$. Number theorists call the primes with symbol $+1$ **split**, those with $-1$ **inert**, and those with $0$ **ramified**. The names come from how $r$ behaves in the quadratic field $\mathbb{Q}(\sqrt N)$.

Inert primes are invisible to the sieve. They never divide a single value of $f$. Roughly half of all primes are inert, so the factor base, the set of columns, consists of the primes up to $B$ at which $N$ is a square. Call this the **split set**, and write $Q(B)$ for its size.

You can count this exactly. For an odd prime $r$, the number of residues $c$ modulo $r$ for which $r$ divides $c^2 - N$ is

$$\#\{c \bmod r : r \mid c^2 - N\} \;=\; 1 + \left(\frac{N}{r}\right).$$

That is two hits per period for a split prime, one for a ramified prime, and zero for an inert prime. The sieve's footprint on the primes is governed entirely by the Legendre symbol.

## The tempting loophole

The split set therefore ties the method to $N$: the columns are fixed once $N$ and $B$ are chosen. A natural question for anyone tuning the algorithm is whether that tie can be cut. Can the number of columns be decoupled from the split set, so that the column count becomes a free design parameter?

One well-known trick looks like it might do exactly that. It is the **large-prime variant**, also called the method of *partial relations*. Most values $f(c)$ are not smooth. Some come close, though: they factor as

$$f(c) = (\text{a } B\text{-smooth number}) \times r,$$

where $r$ is a single prime between $B$ and some larger bound $L$. The plain sieve throws such a value away. The large-prime variant keeps it as a **partial relation**, and the leftover prime $r$ becomes a new kind of column. These primes lie above the factor-base bound and were never put on the list of split primes. The hope is that they come from outside the split set, giving a fresh supply of columns that the split condition does not constrain.

## The one-line refutation

The hope fails, and the reason fits in a single line.

> **If a prime $r$ divides $c^2 - N$, then $N \equiv c^2 \pmod r$, so $N$ is a square modulo $r$. If moreover $r \nmid N$, then $\left(\frac{N}{r}\right) = +1$.**

The size of $r$ plays no role, and neither does the fact that $r$ lies above $B$. The large prime of a partial relation divides a value of $f$, so it is a split prime. The large-prime variant draws its new columns from the same split set, extended up to $L$. It does not escape that set.

The argument is so short that it barely needs symbols. Still, it is worth seeing in a real case. Take

$$N = 15\,916\,539\,906\,629, \qquad c = 3\,989\,570 .$$

Then $c^2 - N = 128\,878\,271$, which turns out to be a prime. So this is a partial relation in its purest form: the smooth part is $1$, and the whole value is a single large prime. Check the symbol: $N \bmod 128\,878\,271$ equals $73\,438\,129$, and so does $c^2 \bmod 128\,878\,271$. The two residues agree, as they must, and $\left(\frac{N}{128\,878\,271}\right) = +1$. Scanning the first $400$ values of $f(c)$ above $\sqrt N$ and factoring each one completely produces $996$ odd prime divisors, some above three billion. All of them are split. Not one is inert.

## Large primes cannot be cherry-picked either

Someone might try a cleverer move: choose the large primes carefully, keeping only those that somehow dodge the split condition. Quadratic reciprocity, the "golden theorem" that Gauss proved in 1796, rules this out. For a positive integer $N$, whether an odd prime $r$ is split depends only on the residue of $r$ modulo $4N$. Formally: if $r$ and $r'$ are odd primes with $r \equiv r' \pmod{4N}$, and $r \nmid N$ divides some value of $f$, then $r'$ also divides some value of $f$.

The split primes therefore form a union of whole residue classes modulo $4N$, and, when $N$ is not a perfect square, exactly half of the classes coprime to $4N$ are split. For the toy case $N = 15$, the split classes modulo $60$ are

$$\{1, 7, 11, 17, 43, 49, 53, 59\},$$

and the inert classes are $\{13, 19, 23, 29, 31, 37, 41, 47\}$. Every large prime that ever appears in a partial relation lies in one of the eight split classes. Splitness is a fixed arithmetic property of the residue class, so no choice of large primes can avoid it.

## How many columns does the variant really add?

Count the columns of the matrix of partial relations. Each column is a prime factor of some value $f(c)$ below $L$, so each one lies in the split set up to $L$. Hence:

- **The columns of any large-prime relation matrix lie inside the split set up to $L$.** This holds with one large prime per relation, two, or any number. There are at most $Q(L)$ of them.
- **One large prime strictly enlarges the split set in use.** If some prime $r$ with $B < r \le L$ divides a value, then $Q(B) < Q(L)$.
- **The added columns are exactly the split primes between $B$ and $L$.** In formulas, $Q(L) = Q(B) + \#\{\text{split primes in } (B, L]\}$. The inert primes in that range contribute nothing.

So the large-prime variant, considered as a matrix of partial relations, does not decouple the column count from the split set. It enlarges the very split set it was meant to escape.

## The twist: the large primes then cancel

The story has one more turn. It sharpens the conclusion instead of reversing it.

A single partial relation is not useful on its own, because its large prime $r$ appears to an odd power and cannot be cancelled by anything in the factor base. The trick is to wait for a **collision**. If two partial relations share the same large prime,

$$c_1^2 - N = s_1 r, \qquad c_2^2 - N = s_2 r,$$

then their product

$$(c_1 c_2)^2 \equiv s_1 s_2\, r^2 \pmod N$$

contains $r$ squared. Modulo 2 the large prime disappears. What is left is an ordinary relation built only from small split primes. Collisions are guaranteed by the pigeonhole principle once the number of partial relations exceeds the number of distinct large primes they can take.

This gives a precise bound on the final linear algebra. **If you have more than $Q(B)$ such combined pairs, then some nonempty subset of them multiplies to a perfect square.** The large primes cancel completely, so the final matrix over $\mathbb{F}_2$ still has exactly $Q(B)$ columns, however large $L$ is.

In summary:

1. In the bookkeeping of partial relations, every large prime is a split prime, so the large-prime variant adds split-prime columns instead of decoupling from them.
2. In the final matrix, those columns cancel, and the column count stays $Q(B)$.

Neither stage decouples the column count from the split set. What the large-prime variant really does is give **more rows for the same sieving effort**. It is a row-yield accelerator, and a good one, which is why practical implementations use it. It does not provide the column-side escape route that a designer trying to tame the split set would want.

A toy run makes this concrete. For $N = 1\,000\,000\,016\,000\,000\,063$ with $B = 4000$ and $L = 400\,000$, sieving $120\,000$ values of $c$ around $\sqrt N$ yields $326$ full relations and $3288$ partial relations involving $2757$ distinct large primes. None of these large primes is inert. Pairing the partials gives $531$ extra combined relations, so the final matrix has $857$ rows against $277$ columns: $Q(B) = 276$ split primes plus one column for the sign. A dependency among just three rows then produces

$$N = 1\,000\,000\,007 \times 1\,000\,000\,009 .$$

## Why such a small observation matters

The argument takes one line. Why does it deserve an article?

The reason is that research programs are mostly made of decisions about where *not* to look. The quadratic sieve offers several knobs that might, in principle, change how its cost scales: large primes, the use of many polynomials, and adaptive choices of the bound $B$. Exploring each one carefully can take weeks of experiments. An argument that settles one of them before any search starts is very valuable. It shows that the large-prime channel cannot decouple the column count, because its large primes are split primes by construction, and it leaves the other two channels open.

The argument also shows how much structure is hidden in the simple polynomial $c^2 - N$. Everything that divides it is governed by one arithmetic invariant, the Legendre symbol $\left(\frac{N}{r}\right)$. That invariant also fixes the hit counts ($1 + \left(\frac{N}{r}\right)$ per period), satisfies Euler's criterion $N^{(r-1)/2} \equiv 1 \pmod r$ at every large prime, and depends only on $r$ modulo $4N$. The same holds for the multiple-polynomial versions of the sieve: for any quadratic polynomial $ax^2 + bx + c$ with discriminant $D = b^2 - 4ac$, every prime $r \nmid D$ that divides one of its values satisfies $\left(\frac{D}{r}\right) = +1$.

## Looking ahead

Closing one door makes the others easier to see. The fact that large primes are split also suggests some new predictions.

- **A doubled birthday rate.** Collisions among large primes behave like the birthday paradox. The relevant pool is the split primes in $(B, L]$, about half of all primes there, not every prime. So the expected number of collisions among $m$ partial relations should be close to $m^2 / \bigl(2(Q(L) - Q(B))\bigr)$. That is roughly twice the naive estimate. A simple random simulation with $m = 60$ draws from the $8721$ split primes in $(2000, 200\,000]$, for the $N$ above, gives about $0.22$ collisions on average, against $0.10$ when drawing from all $17\,681$ primes. Whether real partial relations follow this law is still a conjecture.
- **Equidistribution in split classes.** Large primes should spread evenly over the $\varphi(4N)/2$ split residue classes modulo $4N$, as Dirichlet's theorem on primes in progressions suggests.
- **Cycles of double large primes.** Allowing two large primes per relation turns the bookkeeping into a graph whose vertices are split primes. Each independent cycle should yield a relation supported on the $Q(B)$ small columns.
- **Adaptive bounds.** If the bound $B$ is allowed to grow during the run, the final column count should be fixed by the largest bound used. Any schedule would then be dominated by its endpoint.

Each of these starts from the same observation: a prime that divides $c^2 - N$ cannot avoid being split.
