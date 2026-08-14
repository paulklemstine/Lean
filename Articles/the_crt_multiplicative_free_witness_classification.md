# One Number That Knows Both Your Primes

## How nine unrelated-looking experiments turned out to be the same experiment

Take a large number $N$ that you know is the product of exactly two primes, $N = pq$, but whose factors you do not know. This is the situation at the heart of much of modern public-key cryptography: everyone can see $N$; almost nobody can see $p$ and $q$.

Now do something that looks entirely harmless. Count the solutions of the equation
$$x^2 + y^2 \equiv 1 \pmod N,$$
that is, count the points on a "circle" drawn on the $N \times N$ grid of residues. Call that count $C(N)$. It is a single integer — one number, no factorization required to *state* it.

Here is the surprise. If $p$ and $q$ are both $3$ mod $4$, then
$$p + q = C(N) - N - 1 .$$

That single number hands you the sum of the two secret primes. And once you know $s = p+q$ together with $N = pq$, the primes are simply the two roots of
$$x^2 - sx + N = 0,$$
which you can extract in a fraction of a second. Knowing $C(N)$ is knowing the factorization.

Try it. For $N = 21 = 3 \cdot 7$: $C(21) = 32$ and $32 - 21 - 1 = 10 = 3+7$. For $N = 33 = 3 \cdot 11$: $48 - 33 - 1 = 14$. For $N = 57 = 3\cdot 19$: $80 - 57 - 1 = 22$. Every time.

A quantity like this deserves a name. Call it a **free witness**: a single scalar attached to $N$ that silently contains the whole factorization, and that is defined without any reference to $p$ and $q$.

The circle count is not alone. A long list of structurally unrelated constructions turned out to have exactly this property: counts of $k$-th roots of unity modulo $N$, representation numbers of binary quadratic forms, class counts of finite Heisenberg groups, cusp indices of modular curves, minimum distances of Reed–Solomon-like codes, orders of group elements modulo $N$, divisor sums. Nine of them, from nine different corners of mathematics, each found separately, each a small miracle.

This article is about the discovery that they are not nine miracles. They are one.

---

## The anatomy of a free witness

Look again at the circle count and ask *why* it works. The answer has exactly three moving parts.

**Part one: the domain splits.** The set of residues modulo $N = pq$ is not one thing; the Chinese Remainder Theorem says it is two things stacked together. A residue $x$ mod $15$ is the same data as the pair (x mod 3, x mod 5). Draw the residues mod $15$ as a $3 \times 5$ grid:

$$
\begin{array}{c|ccccc}
 & 0 & 1 & 2 & 3 & 4 \\ \hline
0 & 0 & 6 & 12 & 3 & 9\\
1 & 10 & 1 & 7 & 13 & 4\\
2 & 5 & 11 & 2 & 8 & 14
\end{array}
$$

Every residue appears exactly once. The grid *is* the ring of residues mod $15$, in disguise.

**Part two: the thing being counted respects the grid.** Suppose the weight $f(x)$ you are summing over the grid happens to be a product
$$f(x) = A(x \bmod p)\, B(x \bmod q),$$
a function of the row times a function of the column. Then summing over the whole grid factors:
$$\sum_{x = 0}^{pq-1} f(x) = \Big(\sum_{a=0}^{p-1} A(a)\Big)\Big(\sum_{b=0}^{q-1} B(b)\Big).$$
The total is a product of a $p$-thing and a $q$-thing. Call such an $f$ **CRT-multiplicative**. Being a sum of a product of row and column functions is exactly the statement that the grid of values has *rank one*.

**Part three: the local piece is not a polynomial.** The two factors depend on their own prime in a way no polynomial captures. For the circle count the local piece is $p - \chi(-1)$, where $\chi(-1) = \pm 1$ records whether $-1$ is a square mod $p$; for the divisor sum it is $1 + p$; for root-counting it is $\gcd(k, p-1)$; for order-based witnesses it is a multiplicative order. These are arithmetic, not algebraic, functions of $p$.

Put the three together and you get the shape of every witness in the family: a global scalar
$$W(N) = w(p)\, w(q),$$
whose local weight $w$ is non-polynomial. That factorization is the entire mechanism, and everything else follows from it.

---

## The Trace Lemma: only one secret ever leaks

If the mechanism is one mechanism, then the *information* the witnesses carry should also be one thing. It is, and this is the second main result.

Suppose the local weight has the "affine power" shape $w(x) = x^k + c$ with $c \neq 0$ — which covers the majority of the family. Then a two-line computation gives
$$W(N) = (p^k + c)(q^k + c) = (pq)^k + c\,(p^k + q^k) + c^2,$$
so
$$p^k + q^k \;=\; \frac{W(N) - N^k - c^2}{c}.$$

**The Trace Lemma.** *A CRT-multiplicative witness with affine power weight $x^k+c$, $c \neq 0$, hands the observer the power sum $p^k + q^k$, computed from $W(N)$ and $N$ alone.*

For $k=1$ that power sum is the trace $s = p+q$ itself. For $k=2$ it is $p^2+q^2$, and since $(p+q)^2 = p^2+q^2+2N$, this is the trace again, one square root away. In general the power sum plus $N$ pins the pair down: $p$ and $q$ are the roots of $x^2 - sx + N$.

And the pin-down is genuinely airtight, not merely suggestive: *a pair of positive integers is uniquely determined, as an unordered pair, by its sum and its product.* If $p'q' = pq$ and $p'+q' = p+q$ with $p'$ positive, then $\{p', q'\} = \{p, q\}$. So the trace is not "evidence about" the factorization; it *is* the factorization, re-encoded.

The same lemma explains the two other channels appearing in the family. Some witnesses return not the trace but the larger factor $\max(p,q)$; then the other factor is just $N / \max(p,q)$. Others return a residue or an order vector; a residue determines a factor as soon as the modulus exceeds it. Three channels, all complete, all equivalent to knowing one number.

That is the slogan: **every recoverable witness carries exactly one factor-secret coordinate.** Nine experiments, one information channel.

---

## Why the witnesses are never polynomials

If $W(N)$ can be computed by an honest formula in $N$ — a polynomial, say — then factoring is easy and the world's cryptography is over by lunchtime. So it had better not be, and this is where the non-polynomiality of the *local* weight earns its keep.

Here is the argument, and it is prettier than one expects. Suppose some integer polynomial $P$ satisfied $W(pq) = P(pq)$ for all pairs of distinct odd primes, with local weight $w(x) = x^k + c$. Fix one prime, $r = 3$, and let the other prime $q$ range over the infinitely many remaining primes. Then
$$P(3q) = (3^k + c)(q^k + c)$$
holds at infinitely many points, and two polynomials that agree infinitely often are *equal*: we get the polynomial identity $P(3X) = (3^k+c)(X^k+c)$. Do the same with $r=5$: $P(5X) = (5^k+c)(X^k+c)$.

Now evaluate both at $30$. The first identity, at $X = 10$, gives $P(30) = (3^k+c)(10^k+c)$. The second, at $X = 6$, gives $P(30) = (5^k+c)(6^k+c)$. Setting them equal and cancelling the common term $30^k$ leaves
$$c\,(10^k + 3^k) = c\,(6^k + 5^k).$$
Since $c \neq 0$ we would need $10^k + 3^k = 6^k + 5^k$ — and that is false for every $k \geq 1$ ($13 \neq 11$, $109 \neq 61$, $1027 \neq 341$, and in general $10^k$ alone outruns $6^k + 5^k$). Contradiction.

**Rigidity Theorem.** *No integer polynomial in $N$ reproduces such a witness on the odd semiprimes. A non-polynomial local weight forces a non-polynomial global aggregate.*

There is also a cheap version, useful as a one-line falsifier. For any integer polynomial, $a - b$ always divides $P(a) - P(b)$. So a *single* pair of moduli violating that divisibility kills every polynomial formula at once. For the circle count: $C(21) = 32$, $C(15) = 16$, and $21-15 = 6$ does not divide $16$. Done — no polynomial, ever.

---

## A prediction, made and kept

A classification that only organizes what you already found is bookkeeping. A classification that *predicts new members* is a theory. So the family was asked for one.

The recipe says: take any non-polynomial, CRT-multiplicative local weight and you should get a free witness. The most naive candidate imaginable is the divisor power sum
$$\sigma_k(N) = \sum_{d \mid N} d^k .$$
Its local weight at a prime is $\sigma_k(p) = 1 + p^k$: non-polynomial in the sense that matters (it is a function of $p$, not of $N$), and multiplicative across coprime factors. The prediction: $\sigma_k$ with $k \geq 2$ is a free witness that nobody had listed.

It is. For distinct primes,
$$\sigma_k(pq) = (1+p^k)(1+q^k),$$
and therefore
$$p^k + q^k = \sigma_k(N) - N^k - 1 .$$
For $k = 2$ this yields a closed formula for the trace:
$$p + q = \sqrt{\sigma_2(N) + 2N - 1 - N^2}.$$
Check it on $N = 33 = 3 \cdot 11$: $\sigma_2(33) = 1 + 9 + 121 + 1089 = 1220 = 10 \cdot 122$. Then $1220 + 66 - 1 - 1089 = 196$, whose square root is $14 = 3 + 11$. On $N = 77 = 7 \cdot 11$: $\sigma_2(77) = 6100 = 50 \cdot 122$, and $6100 + 154 - 1 - 5929 = 324 = 18^2 = (7+11)^2$.

And the non-polynomiality goes through for every $k \geq 1$, by the rigidity argument above. This is the first member of the family produced by *theory* rather than by search — a falsifiable prediction that was tested and survived.

The exponent condition is sharp, in a pleasingly literal way. At $k = 0$, $\sigma_0(pq) = 4$: the divisor *count* of a semiprime is always four, a constant, which is certainly a polynomial in $N$ and certainly tells you nothing. The classification's hypothesis $k \geq 1$ is not decoration; it is exactly the line between a witness and a triviality.

---

## Where the mechanism stops

Any good classification comes with a boundary: constructions that look like members and are not. Two are now understood precisely, and the second is a correction of the folklore.

**Truncation leaves the class.** Replace the circle count with a *half-plane* count — only tally solutions in the lower half of the residue range — and everything breaks. Concretely, consider the weight on residues mod $15$ that is $1$ when $2(x \bmod 15) < 15$ and $0$ otherwise. Write out its values on the $3 \times 5$ CRT grid:

$$
\begin{array}{c|ccccc}
 & 0 & 1 & 2 & 3 & 4 \\ \hline
0 & 1 & 1 & 0 & 1 & 0\\
1 & 0 & 1 & 1 & 0 & 1\\
2 & 1 & 0 & 1 & 0 & 0
\end{array}
$$

A rank-one grid — the outer product of a row profile and a column profile — must satisfy $f(x) f(y) = f(z) f(w)$ whenever $z$ and $w$ carry the *crossed* coordinates of $x$ and $y$. Take $x=0$, $y=1$, $z=6$, $w=10$: their coordinates are $(0,0), (1,1), (0,1), (1,0)$, a perfect little rectangle. But $f(0)f(1) = 1$ while $f(6)f(10) = 1 \cdot 0 = 0$. Rank-one fails on four points, so the weight does not split, so no product formula exists. Truncation genuinely exits the class — a cut in the *integers* is not a cut in the CRT grid.

This four-point test is not just a necessary condition; over a field, for a weight that never vanishes, it is *exactly* the condition. If every crossed rectangle satisfies $f(x)f(y) = f(z)f(w)$, one can reconstruct the splitting from the two axes of the grid: set $A(a) = f(\mathrm{crt}(a,0))$ and $B(b) = f(\mathrm{crt}(0,b))/f(0)$, and the identity does the rest. So membership in the free-witness class is decided by looking at rectangles — a finite, mechanical check, replacing the case-by-case inspection the family used to require.

**The phase story is subtler than advertised.** It was long said that oscillating witnesses — sums of exponential phases $e^{2\pi i f(y)/N}$ — fail because phases "do not decompose through the CRT", and that only genuine group characters do. That justification is wrong. Phases *do* decompose. Bézout gives integers $u, v$ with $un + vm = 1$, hence $x = (ux)n + (vx)m$ for every $x$, hence
$$e^{2\pi i x / (mn)} = e^{2\pi i (ux)/m}\cdot e^{2\pi i (vx)/n}$$
exactly, with no error term whatsoever.

The real obstruction is not splitting but **locality**. The twist $u$ in that formula is the inverse of $n$ modulo $m$: it depends on the *other* modulus. Modulo $7$, the inverse of $3$ is $5$, while the inverse of $5$ is $3$ — and the two resulting local weights, $y \mapsto 5y$ and $y \mapsto 3y$, are simply different functions of $y$. So a phase witness has a factorization, but its "local" factor at $p$ is secretly a function of $q$ too. It is not a function of one prime alone, and that — not any failure to split — is why it is not a free witness. The classification needs single-prime locality, and phases quietly violate it.

---

## The seal, and what leaks through it

If a free witness is a key to the factorization, what stops the world from just computing one? The answer is deflatingly simple: the closed form $W(N) = w(p)w(q)$ *requires the factors*. Without them, the only route to the number is to enumerate the CRT grid itself — $\Theta(N)$ work, or $\Theta(N^2)$ for a two-dimensional count. The witness costs nothing if you already know the answer, and everything if you do not.

Could a shortcut exist — a formula in the low bits of $N$? Here the mathematics is unexpectedly delicate, and it cuts both ways.

*Nothing leaks below 64.* For every even exponent $2j$ and all odd distinct primes,
$$\sigma_{2j}(N) \equiv 2 + 2N^{2j} \pmod{64}.$$
The reason is a clean 2-adic identity: $\sigma_k(pq) = 2 + 2N^k - (p^k-1)(q^k-1)$, and for odd $p$ one has $8 \mid p^{2j} - 1$, so the correction term is divisible by $64$ and disappears. The low six bits of the witness are therefore an *explicit polynomial in $N$*, carrying no secret at all — and a brute-force scan over hundreds of thousands of semiprimes finds no separating pair below $2^7$, exactly as the theorem demands.

*Seven bits do leak.* At modulus $128$ the picture changes. Take $N_1 = 15 = 3 \cdot 5$ and $N_2 = 527 = 17 \cdot 31$. Then $527 \equiv 15 \pmod{128}$, but $\sigma_2(15) = 260 \equiv 4$ while $\sigma_2(527) = 278980 \equiv 68 \pmod{128}$. Two moduli with the same residue and different witness residues: therefore **no function whatsoever** — polynomial, exotic, or otherwise — of $N \bmod 128$ can compute $\sigma_2(N) \bmod 128$ on odd semiprimes. That is far stronger than ruling out polynomials.

The same pair separates the circle count already at $32$: $C(15) = 16$ and $C(527) = 512 \equiv 0 \pmod{32}$. So the circle count is 2-adically *less* sealed than the divisor witness. Different members of one family, with measurably different amounts of low-order leakage.

---

## A second channel nobody was looking for

The Trace Lemma's slogan — one factor-secret coordinate per witness — turns out to be an artifact of only ever testing on semiprimes.

Push the divisor witness to an arbitrary squarefree modulus: the product formula becomes
$$\sigma_k(N) = \prod_{p \mid N}(1 + p^k),$$
with as many factors as $N$ has primes. Now count powers of two. For an odd prime $p$ and even exponent $2j$, $p^{2j} \equiv 1 \pmod 8$, so $1 + p^{2j} \equiv 2 \pmod 8$: each local factor contributes *exactly one* factor of $2$, never more. Multiply them:

**The $\omega$-channel.** *For odd squarefree $N$ and every $j$, the exponent of $2$ in $\sigma_{2j}(N)$ equals $\omega(N)$, the number of distinct prime factors of $N$.*

The witness counts the primes of $N$, unconditionally, in its own 2-adic valuation. Watch it happen: $\sigma_2(15) = 260 = 2^2 \cdot 65$ and $15$ has two prime factors; $\sigma_2(105) = 13000 = 2^3 \cdot 1625$ and $105 = 3\cdot5\cdot7$ has three; $\sigma_2(1155) = 1586000 = 2^4 \cdot 99125$ for $1155 = 3\cdot5\cdot7\cdot11$; $\sigma_2(15015) = 269620000 = 2^5 \cdot 8425625$ for five primes. Every time.

On semiprimes this reads "the valuation is $2$" — a constant, easily mistaken for noise. In general it is a second, structurally different secret riding in the same scalar: the one-coordinate slogan was never a theorem, but a sample-size effect.

---

## What this buys, and what it does not

Two cautionary notes round out the picture.

Non-CRT-separability does not buy you a closed form. The half-plane count, the family's non-separable black sheep, is not a polynomial in $N$ either: $H(15) = 4$, $H(35) = 6$, and $35 - 15 = 20$ does not divide $2$. Escaping the class is not the same as escaping the barrier.

And the honest limit. Everything above is proved: the product formula, the trace recovery, the rigidity theorem, the four-point characterization of the class, the prediction, the 2-adic seal, the $\omega$-channel. What is *not* proved — what nobody can prove today — is that the $\Theta(N)$ aggregation cost is *necessary*. That claim is equivalent to the hardness of factoring, one of the most famous open problems in the subject. The classification tells you precisely what these nine constructions are and why they behave alike; it does not tell you that no tenth construction sidesteps the cost.

What has changed is the status of the question. Before, one had nine unexplained coincidences and no way to tell whether a new candidate belonged. Now there is a definition (CRT-multiplicative local weight), a test (rank-one on four points, exact over a field), a recovery theorem (the Trace Lemma and its three complete channels), a rigidity theorem, a validated prediction, a sharp boundary, and a measured seal.

Nine miracles have become one mechanism. In mathematics, that is usually the moment just before something else becomes visible.
