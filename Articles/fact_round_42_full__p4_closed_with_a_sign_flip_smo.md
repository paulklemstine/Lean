# The Split Set Decides: Why Shrinking the Quadratic Sieve Makes It Slower

*How a tempting shortcut for factoring large numbers turned out to point exactly the wrong way — and what really controls the hunt for smooth numbers.*

---

## A machine for manufacturing squares

Suppose someone hands you a large odd number $N$ — say $N = 103{,}764{,}863$ — and asks for its factors. Trial division is hopeless at cryptographic sizes, so modern methods use a cleverer idea that goes back to Fermat and was turned into a practical algorithm by Carl Pomerance in the early 1980s: the **quadratic sieve**.

The idea runs as follows. If you can find two numbers $x$ and $y$ with

$$x^2 \equiv y^2 \pmod N, \qquad x \not\equiv \pm y \pmod N,$$

then $N$ divides $(x-y)(x+y)$ without dividing either factor, so $\gcd(x-y, N)$ is a proper factor of $N$. The whole game is to *manufacture* such a congruence of squares.

The sieve does it in two stages.

**Stage one: collect relations.** Look at the values of the polynomial

$$f(x) = x^2 - N$$

for $x$ just above $\sqrt N$. These values are fairly small, and now and then one of them factors completely into small primes — primes up to some bound $B$. Such a value is called **$B$-smooth**, and each one is a *relation*. Our example has $x = 10188$:

$$10188^2 - 103{,}764{,}863 = 30{,}481 = 11 \cdot 17 \cdot 163.$$

**Stage two: linear algebra.** Write each relation as a vector of exponents mod 2, one coordinate per prime in the "factor base". A product of relations is a perfect square exactly when its exponent vectors add up to zero mod 2. So we need a linear dependency over the two-element field $\mathbb{F}_2$, and linear algebra promises one as soon as the number of relations is larger than the number of coordinates.

Here is the trade-off every designer of the sieve has to face. Call the number of columns $Q$. More columns mean more relations to collect before the linear algebra is sure to succeed, and a bigger matrix to reduce. So a natural thought follows: **make $Q$ smaller.** Fewer columns, fewer relations needed, less work.

This article is about why that thought is backwards, and about the number-theoretic fact that settles it.

---

## The surprise: paying more for less

A campaign of experiments tested this "shrink $Q$" proposal head-on. The experimenters ran three independent sets of runs: a synthetic model, a model built around the Chinese Remainder Theorem, and a real single-polynomial quadratic sieve. All three used measuring tools that had been independently cross-checked.

One earlier observation held up: the ratio $Q/\pi(B)$, where $\pi(B)$ counts the primes up to $B$, really does correlate with the number of relations needed. The measured correlation was $+0.77$, and it was not an artefact. But it attaches to the wrong cost. What a factoring run actually *pays for* is the number of sieve positions examined, because that is where the computer time goes. Measured in positions, the cost turned out to **fall** as $Q$ grows. It fell monotonically, by factors from $2.4\times$ to $13.1\times$ depending on the design.

> **The design rule.** At a fixed smoothness bound $B$, the paid sieve length *decreases* as the factor base grows. Any proposal that shrinks the factor base in order to shrink the linear algebra is moving the wrong term.

You can watch this happen on a laptop. Take $N = 103{,}764{,}863$ and $B = 400$. The full factor base has $Q = 41$ usable primes. Now pretend you may only use the smallest $q$ of them, and count how many sieve positions you have to scan to collect $q+1$ relations:

| columns $q$ | positions scanned |
|---:|---:|
| 16 | 1,651 |
| 22 | 784 |
| 28 | 747 |
| 34 | 638 |
| 41 | 599 |

The smallest factor base needs fewer relations, yet it costs almost three times as much sieving.

### Why the sign flips

The reason is a mismatch between how the two sides grow. Adding one prime $p$ to a set of primes $S$ raises the number of relations you need by exactly **one**: the target is $|S|+1$. The number of smooth numbers, though, grows **multiplicatively**. Every $S$-smooth number $m \le X/p$ gives a new smooth number $p \cdot m \le X$. Writing $\Psi_S(X)$ for the count of integers in $[1,X]$ whose prime factors all lie in $S$, this gives

$$\Psi_{S\cup\{p\}}(X) \;\ge\; \Psi_S(X) + \Psi_S(X/p).$$

Measure the cost by the work model "positions per guaranteed dependency",

$$\mathrm{work}(S) = \frac{|S| + 1}{\Psi_S(X)}.$$

A short calculation shows that adding $p$ **does not increase the work** as soon as

$$(|S|+1)\cdot \Psi_S(X/p) \;\ge\; \Psi_S(X).$$

This is a very weak condition. Take $S=\{2,3\}$, $X = 100$, $p=5$. There are $\Psi_{\{2,3\}}(100) = 20$ numbers up to 100 built only from 2s and 3s, and $\Psi_{\{2,3\}}(20) = 10$ of them are at most 20. Since $3 \times 10 = 30 \ge 20$, the criterion holds. Indeed $\Psi_{\{2,3,5\}}(100) = 34$, and

$$\mathrm{work}(\{2,3,5\}) = \tfrac{4}{34} \approx 0.118 \;<\; \tfrac{3}{20} = 0.15 = \mathrm{work}(\{2,3\}).$$

One extra column costs $+1$ and buys a multiplicative gain. That is the sign flip in one line.

---

## The density that ignores Dickman

There is a classical way to predict how many smooth numbers to expect. Put $u = \log X / \log B$. The chance that a random integer near $X$ is $B$-smooth is roughly $\rho(u)$, where $\rho$ is the **Dickman function**. It equals 1 on $[0,1]$ and then falls off faster than exponentially: $\rho(2) \approx 0.31$, $\rho(3) \approx 0.049$, $\rho(4)\approx 0.0049$. Run-time analyses of factoring algorithms are built on it.

An earlier round of the same campaign had claimed that "the Dickman density survives measurement". The new experiments refine that claim sharply. When instances are compared at **matched** $u$, the correlation between $\log \rho(u)$ and the measured smooth density is

$$\operatorname{corr}(\log\rho,\ \text{density}) = +0.029,$$

which is essentially zero. The correlation with the split-prime ratio, by contrast, is

$$\operatorname{corr}(Q/\pi(B),\ \text{density}) = +0.882.$$

So Dickman's function correctly describes how the yield depends on $u$, but it is *blind* to the quantity that separates one modulus from another at the same $u$. Two numbers $N_1, N_2$ of the same size, sieved with the same bound $B$, can have very different yields. The deciding factor is how many primes up to $B$ are "friendly" to each $N$.

That claim can be made exact. The number of smooth sieve values in a window $[a,b]$ with $a^2 > N$ satisfies

$$\#\{x\in[a,b] : x^2-N \text{ is } B\text{-smooth}\} \;\le\; \bigl(\lfloor\log_2(b^2-N)\rfloor + 1\bigr)^{Q(N,B)}.$$

The exponent is $Q(N,B)$, **not** $\pi(B)$. A matching lower bound of the same exponential shape also holds: if the product of the primes in $S$ is at most $X$, then $\Psi_S(X) \ge 2^{|S|}$, because every product of distinct primes from $S$ counts. At a fixed size $X$, and hence a fixed $u$, the smooth count is squeezed between two functions that are exponential in the number of usable primes. Nothing else about $B$ enters.

---

## Which primes are "friendly"? Quadratic reciprocity enters

Why do only some primes count? Suppose a prime $r$ divides a sieve value $x^2 - N$. Then

$$x^2 \equiv N \pmod r,$$

so $N$ is a perfect square modulo $r$. If $r$ does not divide $N$, this says exactly that the **Legendre symbol** $(N/r)$ equals $+1$. (The Legendre symbol is $+1$ when $N$ is a nonzero square mod $r$, $-1$ when it is a non-square, and $0$ when $r \mid N$.)

> **Theorem (split-set forcing).** If a prime $r$ with $r \nmid N$ divides some value $x^2 - N$, then $(N/r) = +1$. Conversely, every prime $r$ for which $N$ is a square mod $r$ divides some $x^2 - N$. So the primes up to $B$ that the sieve can ever touch are *exactly* the **admissible** primes: those that divide $N$ (the "ramified" ones) together with those having $(N/r) = +1$ (the "split" ones).

The names come from algebraic number theory. The primes with $(N/r)=+1$ are the ones that split in the quadratic field $\mathbb{Q}(\sqrt N)$. The ones with $(N/r) = -1$, the **inert** primes, never divide any sieve value at all. Roughly half of all primes are inert for a given $N$. For our example $N$:

| $B$ | $\pi(B)$ | $Q(N,B)$ | inert |
|---:|---:|---:|---:|
| 100 | 25 | 13 | 12 |
| 500 | 95 | 49 | 46 |
| 2000 | 303 | 133 | 170 |

The three prime factors of our example relation behave just as the theorem says: $(N/11) = (N/17) = (N/163) = +1$. In the real-sieve experiments, all **2,215 of 2,215** smooth values had prime support inside the split set.

This changes how the "shrink $Q$" proposal should be read. **$Q$ is not a free parameter.** Once you fix the polynomial $x^2 - N$ and the bound $B$, the sieve has already decided which columns exist: precisely the admissible primes, with $Q(N,B) + \#\{\text{inert primes} \le B\} = \pi(B)$. Leaving out admissible primes on purpose does shrink the matrix, but as we saw, it makes the sieve slower.

A second suggestion, which tried to use the Chinese Remainder Theorem to concentrate on a small set of residues, was ruled out twice over: once by enumerating every case, and once by an inequality on the prime-sum function. Since $\theta(R) = \sum_{p\le R}\log p$ must stay below $\ln N$ for the construction to make sense, the fraction $\pi(R)/\pi(B)$ of the factor base it could control tends to zero.

---

## Which way does the inequality point?

The linear-algebra stage hid a quieter confusion. Let $k_{\text{success}}$ be the number of relations you need before some subset of them first multiplies to a square, that is, the length of the shortest linearly dependent run of exponent vectors. A tempting chain of inequalities reads

$$k_{\text{success}} \;\le\; \operatorname{rank} + 1 \;\le\; Q + 1.$$

Is the first step backwards? The answer depends on *which* rank you mean, and both readings are true:

- If "rank" means the rank of the **prefix** of $k$ vectors at the moment it first becomes dependent, then dependence forces $\operatorname{rank} + 1 \le k$. At the first dependence the two sides meet exactly:

$$k_{\text{success}} \;=\; \operatorname{rank}(\text{first } k_{\text{success}} \text{ vectors}) + 1.$$

- If "rank" means the rank of **all** the relations collected, including any past $k_{\text{success}}$, then $k_{\text{success}} \le \operatorname{rank}(M)+1$ holds, because rank can only grow as rows are added.

Either way $k_{\text{success}} \le Q + 1$, and this is sharp: if the first $Q$ relations happen to be the standard basis vectors, the first dependency arrives at exactly $Q + 1$. The bound counts **relations**, though, not **positions**. It says nothing about how long you sieve to *find* those relations. That is why the linear-algebra bound gives no upper bound on the actual work. In experiments the ratio $k_{\text{success}}/Q$ came out near $0.78$, $0.71$ and $0.60$ at $B = 1024$, $2048$ and $4096$. Those values are properties of the instances; the algebra does not fix them.

---

## A bug that hides from honest tests

The campaign also turned up a cautionary tale for anyone who computes. Two rank routines in a widely used computer-algebra library — one general, one that claims to work over $\mathrm{GF}(2)$ — were found to return the rank over the **rationals** when asked for the rank over $\mathbb{F}_2$. Take the incidence matrix of a triangle:

$$T = \begin{pmatrix} 1&1&0\\ 0&1&1\\ 1&0&1\end{pmatrix}.$$

Over $\mathbb{Q}$ it has rank 3. Over $\mathbb{F}_2$ the three rows add up to zero, so the rank is 2. A sieve that trusted the wrong routine would report "no dependency yet" while a perfectly good square sat in its data.

Why did ordinary testing miss this? A clean answer comes from determinants. For a square integer matrix $A$:

- $A$ has full rank over $\mathbb{F}_2$ exactly when $\det A$ is **odd**;
- $A$ has full rank over $\mathbb{Q}$ exactly when $\det A \neq 0$.

> **Theorem (discriminating tests).** A square integer test matrix can tell a "rank over $\mathbb{Q}$" routine apart from a correct "rank over $\mathbb{F}_2$" routine on the full-rank question **if and only if its determinant is a nonzero even integer.**

The triangle has $\det T = 2$, which is why it catches the bug. A test suite made of identity matrices, triangular matrices and singular matrices has only odd or zero determinants, so it would pass the broken routine every time.

The error also runs in one direction only:

$$\operatorname{rank}_{\mathbb{F}_2}(A) \;\le\; \operatorname{rank}_{\mathbb{Q}}(A) \quad\text{for every integer matrix } A.$$

The proof is a small piece of 2-adic reasoning. Suppose some vectors are independent mod 2 but satisfy an integer relation. If every coefficient of that relation is even, divide it by 2; this can be repeated only finitely often. Eventually some coefficient is odd, and the relation reduced mod 2 is a nontrivial mod-2 relation, which contradicts independence. So a rational-rank routine can only *over*-report the $\mathbb{F}_2$-rank, which means it can only *miss* dependencies, never invent them.

The lesson was put into practice: the team deliberately broke routines and checked that their tests caught them (a **mutation test**). In the team's words, without this, "validation passed" is unfalsifiable. The same discipline caught three more silent defects: a modular square-root routine with two bugs, a gcd step that mishandled exponents, and a log-sieve that ignored prime powers. It also caught a problem in the team's own reports. Two sample tables had been re-typed rather than regenerated from the stored records, and 10 of 16 rows matched no stored instance. The aggregate numbers were all exact. The rule that follows is to regenerate tables from primary data, never transcribe them.

---

## The road ahead: large primes

If $Q$ is fixed by the split set and shrinking it only hurts, how can one get past the collapse in yield? The open question now reads: *at a fixed $B$, can one avoid the yield collapse without shrinking the column space?*

One classical channel looks promising, and its algebra is now settled. Keep **partial relations**: sieve values that are smooth apart from a single "large prime" $\ell > B$. One partial on its own is useless, since $\ell$ would need a column of its own. But two partials with the **same** large prime multiply to

$$(s_1\ell)(s_2\ell) = s_1 s_2\,\ell^2,$$

and $\ell^2$ is already a square. So the pair behaves like an ordinary full relation in the **same** $\mathbb{F}_2^Q$ column space.

> **Theorem (large-prime congruence).** Suppose you hold $a$ full relations and $b$ partial relations, and among the partials there are $D$ distinct large primes. If
> $$Q < a + (b - D),$$
> then some nonempty collection of full relations and paired partials multiplies to a perfect square.

A toy example: columns $\{2,3\}$ (so $Q=2$), one full relation $6$, and partials $2\cdot101$, $3\cdot101$, $6\cdot101$. Here $a + (b-D) = 1 + (3-1) = 3 > 2$, and indeed

$$6 \cdot (3\cdot 101)(2\cdot 101) = (6\cdot 101)^2.$$

The question of *cost* thus becomes a **birthday problem**: how fast does the number of collisions $b - D$ grow? Simulations with large primes weighted like $1/\ell$ show the collision count growing roughly quadratically at first (about 1.2 collisions among 50 partials, 19 among 200, nearly 200 among 800). The conjecture for the next step is that the moment $a + (b-D)$ first exceeds $Q$ comes strictly earlier, in sieve positions, than the moment $a$ alone does.

---

## What it all means

The quadratic sieve has been studied for forty years, and at small scale it still holds surprises. Three lessons stand out.

1. **Count the right cost.** Fewer relations are not the same as less work. Positions scanned are what you pay for, and they fall as the factor base grows.
2. **Number theory sets the columns.** Quadratic residues, through the Legendre symbol, fix the factor base before any design choice is made. Smooth yield is governed by how many primes split, a quantity Dickman's $\rho(u)$ cannot see.
3. **Tests must be able to fail.** A test matrix with odd determinant cannot tell a field-of-two rank from a rational rank. Only mutation testing turns "validation passed" into evidence.

None of this produces a faster factoring method, and the authors say so plainly: no new algorithm came out of this, consistent with every earlier round. What it does produce is a clearer map. It shows which levers are real, which point the wrong way, and where the next idea, perhaps a collision of large primes, has room to work.
