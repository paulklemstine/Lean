# The Circle That Refuses to Talk

## A story about counting points, square roots, and the secrets integers keep

### A very old question in modern clothes

Take a whole number $N$ and ask the oldest question in arithmetic: what are its factors? For a number with a thousand digits, nobody knows how to answer quickly. The security of a large fraction of the world's digital infrastructure rests on that ignorance.

Faced with a wall, mathematicians go looking for cracks. Here is the shape of the dream. Suppose you could cook up some *statistic* $S(N)$ — a number attached to $N$ that you can compute directly from $N$ itself, without knowing its factors — and suppose $S(N)$ happened to encode something about the factors. Then you would have a free witness: a cheap computation that tells you something expensive.

This article is about one such candidate statistic, why it looked promising, and the precise mathematical reason it cannot work. The reason turns out to be beautiful, and it is much bigger than the statistic itself. The obstruction is not a clever trick of the particular formula; it is a structural feature of *circles*.

### Counting points on a circle, with signs

Start with a prime $p$ and the circle
$$x^2 + y^2 = 1$$
but interpret $x$ and $y$ not as real numbers, but as residues modulo $p$ — elements of the finite world $\{0, 1, 2, \dots, p-1\}$ where arithmetic wraps around. This finite circle has points, and you can count them: there are $p - 1$ of them when $p \equiv 1 \pmod 4$ and $p+1$ when $p \equiv 3 \pmod 4$. That count is a dial with only two settings; it tells you nothing you didn't already know from $p$ modulo $4$.

So put a *weight* on the points. Modulo a prime, every nonzero residue is either a perfect square (a *quadratic residue*) or it is not, and this dichotomy is recorded by the **Legendre symbol** $\left(\frac{x}{p}\right)$, which equals $+1$ for squares, $-1$ for non-squares, and $0$ for $x = 0$. The extraordinary fact — the first deep theorem of the subject — is that this symbol is *multiplicative*: $\left(\frac{xy}{p}\right) = \left(\frac{x}{p}\right)\left(\frac{y}{p}\right)$. Squares times squares are squares; non-square times non-square is a square.

Now define the **signed circle count**
$$W(p) \;=\; \sum_{\substack{x^2+y^2=1 \\ x, y \bmod p}} \left(\frac{x}{p}\right).$$
Every point on the finite circle votes $+1$ or $-1$ according to whether its $x$-coordinate is a square. The votes should roughly cancel; the question is how much they fail to.

The definition extends verbatim to a *composite* modulus $N$, because the Legendre symbol has a composite cousin, the **Jacobi symbol** $\left(\frac{a}{N}\right)$, defined by multiplying the Legendre symbols of the prime factors of $N$ — and, crucially, computable in a few microseconds from $a$ and $N$ *without factoring $N$*, by a Euclidean algorithm that looks like a signed version of computing a greatest common divisor. That is what makes $W(N)$ a legitimate free witness: anybody can compute it.

Better still, summing over $y$ collapses the double sum. For a fixed $x$, the number of $y$ with $y^2 = 1 - x^2$ is exactly $1 + \left(\frac{1-x^2}{p}\right)$, and so
$$W(N) \;=\; \sum_{x \bmod N} \left(\frac{x - x^3}{N}\right),$$
a single sum over $N$ terms. A cubic polynomial has silently entered the story, and it will matter enormously.

### The first surprise: the statistic factors when $N$ does

Compute $W$ at a few numbers and a pattern jumps out:
$$W(5) = 2, \quad W(17) = -2, \quad W(85) = W(5 \cdot 17) = -4.$$
$$W(13) = -6, \quad W(29) = 10, \quad W(377) = W(13\cdot 29) = -60.$$

**Theorem (Multiplicativity).** *If $m$ and $n$ are coprime odd numbers then $W(mn) = W(m)\,W(n)$.*

The proof is the Chinese Remainder Theorem: residues modulo $mn$ correspond exactly to pairs (residue mod $m$, residue mod $n$), the polynomial $x - x^3$ evaluates coordinatewise, and the Jacobi symbol splits as a product. The sum over a product of moduli therefore literally factors into a product of sums.

This is exhilarating and alarming at once. A quantity anyone can compute from $N$ alone *knows* that $N$ splits — it splits along with it. Surely something must leak.

### The second surprise: two squares

What does $W$ do at a single prime? If $p \equiv 3 \pmod 4$, then $-1$ is not a square modulo $p$, the map $x \mapsto -x$ reverses the sign of every vote, and the whole sum collapses:
$$W(p) = 0 \qquad (p \equiv 3 \bmod 4).$$
So half of all primes are invisible to the statistic, and any $N$ with such a prime factor gives $W(N) = 0$ by multiplicativity.

For $p \equiv 1 \pmod 4$ something far richer happens. Fermat's theorem on sums of two squares says every such prime can be written $p = a^2 + b^2$, essentially uniquely, with $a$ odd and $b$ even. And the signed circle count computes the odd leg:
$$W(p) = 2a, \qquad p = a^2 + b^2, \quad a \text{ odd}.$$
Check it: $13 = 3^2 + 2^2$ and $W(13) = -6$; $173 = 13^2 + 2^2$ and $W(173) = 26$; $101 = 1^2 + 10^2$ and $W(101) = 2$.

Immediately this gives the celebrated *square-root barrier*: since $a^2 \le p$,
$$W(p)^2 \le 4p.$$
This is the smallest case of a phenomenon that governs all of arithmetic geometry — the Weil bound, which says that point counts on curves over finite fields deviate from their expected value by at most a square root of the field size. Our circle-with-a-cubic-weight is secretly an elliptic curve, $y^2 = x^3 - x$, and $W(p)$ is its trace of Frobenius. The square-root barrier is not an accident of a formula; it is a law.

And the law is exactly what kills the dream. If $N = pq$, then $|W(N)| = |W(p)||W(q)| \le 4\sqrt{pq} = 4\sqrt N$. The statistic is a single number of size about $\sqrt N$ — that is, about half as many digits as $N$. Knowing it constrains the pair $(p, q)$, but never determines it. There simply isn't enough room in the answer for the information you want.

The rest of this article is about four ways of making "there isn't enough room" into a theorem — and about discovering that the floor is far more robust than anyone expected.

---

### Crack 1: change the weight, and nothing changes

The Legendre symbol is only one way to weight points. It is a *character*: a function $\psi$ on the nonzero residues, taking complex values, with $\psi(xy) = \psi(x)\psi(y)$. Modulo a prime, the nonzero residues form a cyclic group of order $p - 1$, so there are exactly $p-1$ characters, of every order dividing $p - 1$. The Legendre symbol is the unique one of order $2$. Why not weight the circle by a character of order $3$, or $7$, or $p-1$, and hope for a bigger, more informative signal?

Define
$$W_\psi(p) \;=\; \sum_{x^2+y^2=1} \psi(x).$$
The answer is a clean dichotomy, and it is the central new result of this work.

**Theorem (Odd weights are blind).** *If $\psi(-1) = -1$ — an* odd *character — then $W_\psi(p) = 0$ exactly.*

The proof is the reflection $x \mapsto -x$, which permutes the points of the circle and negates every weight, so the sum equals its own negative. (This is the $p \equiv 3 \pmod 4$ vanishing seen from higher ground: for those primes the Legendre symbol itself is odd.)

**Theorem (Even weights are Jacobi sums).** *If $\psi = \xi^2$ is a square of a character — equivalently, if $\psi$ is even — and $\psi$ is not the trivial character, then*
$$W_{\xi^2}(p) \;=\; J(\xi, \chi) + J(\chi\xi, \chi),$$
*where $\chi$ is the Legendre symbol and $J(\alpha, \beta) = \sum_x \alpha(x)\beta(1-x)$ is a **Jacobi sum**.*

The derivation is a two-step collapse. First, summing away $y$ turns the circle count into $\sum_x \psi(x)\bigl(1 + \chi(1-x^2)\bigr)$. The trivial part $\sum_x \psi(x)$ vanishes because a nontrivial character sums to zero over a full period. Second, the surviving sum $\sum_x \xi(x^2)\chi(1-x^2)$ is a sum over *squares*, and pushing it forward along the squaring map — each value $d$ is hit $1 + \chi(d)$ times — turns it into $\sum_d (1+\chi(d))\,\xi(d)\chi(1-d)$, which is precisely the two Jacobi sums of the statement.

Jacobi sums are among the most classical objects in number theory; Gauss used them to count points on curves a century and a half before Weil. Their defining miracle is that they have *exactly* the size $\sqrt p$:
$$|J(\alpha,\beta)| = \sqrt p$$
whenever $\alpha$, $\beta$ and $\alpha\beta$ are all nontrivial. (One proves this by pairing a Jacobi sum with its complex conjugate, which is the Jacobi sum of the inverse characters, and computing the product to be $p$.)

Put the two theorems together and the consequence is immediate and, at first sight, startling:

**Theorem (The floor is a property of the circle, not the weight).** *For every character $\xi$ other than the trivial one and the Legendre symbol,*
$$\bigl|W_{\xi^2}(p)\bigr| \;\le\; 2\sqrt p,$$
*and every odd weight gives exactly $0$.*

The constant is $2$ — an *absolute* constant. It does not grow with the order of the character. One might have guessed that a character of order $d$ would give a bound like $d\sqrt p$, since $d$ is a natural measure of how complicated the weight is; the truth is that no matter how baroque the weight, the circle only ever produces *two* Jacobi sums, and each is a $\sqrt p$. The search for a better weight is over before it starts: the entire infinite family of character weights lives inside a window of width $4\sqrt p$.

### Crack 2: how far from the floor, exactly?

The bound $W(p)^2 \le 4p$ raises a natural question: how close does the statistic actually get to its ceiling? At $p = 173$ we get $W(173)^2 = 676$ against $4p = 692$ — attainment of $97.7\%$. Is near-attainment common? Can it be understood?

It can, completely, because the *deficiency* has a closed form.

**Theorem (The exact deficiency).** *For $p \equiv 1 \pmod 4$ with $p = a^2+b^2$, $a$ odd, $b$ even, and $W(p) = 2a$:*
$$4p - W(p)^2 \;=\; 4b^2.$$

The proof is one line — substitute $W(p) = 2a$ and $p = a^2+b^2$ — but the consequences are not.

First, because $p$ is prime it is not a perfect square, so $b \ne 0$; and $b$ is even, so $|b| \ge 2$ and $4b^2 \ge 16$. Hence:

**Theorem (A sharper floor).** *For every prime $p \equiv 1 \pmod 4$,*
$$W(p)^2 \;\le\; 4p - 16,$$
*and this is best possible: equality holds at $p = 5$, $13$, $29$, $53$, $173$, $229$, $293, \dots$ — exactly the primes of the form $a^2+4$.*

The famous $97.7\%$ at $p = 173$ is thereby demystified: $173 = 13^2 + 2^2$, the even leg is as small as an even leg can be, and $4 \cdot 173 - 26^2 = 16$ on the nose. Near-attainment is not a mysterious analytic coincidence; it is the statement that $p$ sits just above a perfect square. Asking how often the statistic nearly saturates its bound is *exactly* asking how often a prime has the shape $a^2 + (\text{small})^2$ — a question about primes represented by thin quadratic families, where the tools of sieve theory apply.

### Crack 3: the powers of two, and a conjecture that turned out to be false

Every arithmetic statistic invites the question: what does it look like $2$-adically — how many factors of $2$ does it contain? For our circle count the answer is exact.

Since $W(p) = 2a$ with $a$ *odd*, each prime $p \equiv 1 \pmod 4$ contributes exactly one factor of $2$. Multiplicativity adds up the exponents:

**Theorem (The valuation counts prime factors).** *Let $N$ be squarefree with all prime factors $\equiv 1 \pmod 4$, and let $\omega(N)$ be the number of them. Then $W(N) = 2^{\omega(N)} \cdot (\text{odd})$; that is, the exact power of $2$ dividing $W(N)$ is $2^{\omega(N)}$. In particular, for a semiprime $N = pq$ with both factors $\equiv 1 \pmod 4$, $W(N)$ is divisible by $4$ but not by $8$.*

There is a companion, and it is sharp in the other direction:

**Theorem (Exact vanishing criterion).** *For distinct odd primes $p, q$, the count $W(pq)$ is zero if and only if $p \equiv 3$ or $q \equiv 3 \pmod 4$.*

Now, is this leakage? A first reading says no, and offers a reason: perhaps this $2$-adic content is already visible in $N \bmod 4$, hence public information. That reason is *wrong*, and the counterexample is small and decisive: $21 = 3 \cdot 7$ and $85 = 5 \cdot 17$ are both $\equiv 1 \pmod 4$, yet
$$W(21) = 0, \qquad W(85) = -4.$$
So no function of $N \bmod 4$ can reproduce the $2$-adic content, and indeed no function of $N \bmod 4$ can reproduce $W$ at all. The statistic really does see something beyond the residue of $N$.

What it sees is just not the split. The correct statement of harmlessness is *constancy on the relevant family*: across all semiprimes whose two factors are $\equiv 1 \pmod 4$ — which is precisely the hard case, the case that resists — the power of two is always $4$, never anything else. A witness reading the $2$-adic valuation gets the same answer for every such $N$, and an answer that never varies carries no information about what varies.

There is an even more refined version. Recall Brahmagupta's identity, which says the product of two sums of two squares is again a sum of two squares: $(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2$. Applied to $N = pq$, it produces a two-square representation $N = u^2 + v^2$ with $u$ odd, and the circle count locks onto it:
$$W(N) \equiv 4u \pmod{16}.$$
So the statistic reads off the odd Gaussian coordinate of $N$ modulo $4$. But the Gaussian coordinates of $N$ are an invariant of $N$ itself — they are a property of $N$'s position in the plane of complex whole numbers, not of the way $N$ is built from $p$ and $q$. The statistic reports a *conserved quantity*, faithfully and uselessly.

### Crack 4: nothing about circles was special

The final result explains why every attempt of this kind fails at once. Take *any* integer polynomial $f$ and define
$$S_f(N) \;=\; \sum_{x \bmod N} \left(\frac{f(x)}{N}\right).$$

**Theorem (Universal multiplicativity).** *For every polynomial $f$ and coprime $m, n$: $S_f(mn) = S_f(m)\,S_f(n)$.*

The Chinese Remainder proof never mentioned the circle, or the cubic, or anything else. Multiplicativity is free. It is also, therefore, worthless as evidence of leakage.

What is *not* free is a nonconstant signal — and here the degrees separate dramatically.

**Theorem (Conic weights are constants).** *Let $f(x) = (x-r)(x-s)$ with $r \not\equiv s$ modulo the odd prime $p$. Then $S_f(p) = -1$, regardless of $p$, $r$ and $s$. Consequently $S_f(N) = (-1)^{\omega(N)}$ for squarefree $N$, and $S_f(pq) = +1$ for every semiprime.*

The reason is a classical evaluation of quadratic character sums: $\sum_x \chi\bigl((x-r)(x-s)\bigr)$ equals $p - 1$ if $r \equiv s$, and $-1$ otherwise. A quadratic weight has *no fluctuation at all*. A witness built from any separable conic returns the constant $1$ at every semiprime — it does not merely fail to break the square-root floor, it never gets off the ground.

The contrast with the circle statistic is stark: $W(85) = -4$, not $1$. The $\sqrt N$-sized fluctuation is a genuinely *cubic* phenomenon. Degree $1$ and $2$ give constants; at degree $3$ the geometry changes from a rational curve to an elliptic curve, fluctuation of size $\sqrt p$ appears — and immediately the Weil bound caps it there.

### What the circle teaches

Put the four cracks together and a single picture emerges. Around every conic and every character weight there is a wall at height $\sqrt{p}$, and the wall is built out of the geometry of the curve rather than out of any property of the weight. Change the weight to a character of enormous order: you get two Jacobi sums, each of size exactly $\sqrt p$. Change the polynomial to a conic: you get a constant. Change the modulus to a composite: multiplicativity hands you a product of per-prime terms, each already at the floor. Ask how close to the floor you can get: the answer is an exact Diophantine formula, $4p - W(p)^2 = 4b^2$, that converts an analytic question into one about primes just above squares.

A statistic of size $\sqrt N$ is a number with half the digits of $N$. The factorization of $N$ needs all of them. That gap — between what a cheap character sum can hold and what a factorization requires — is not a temporary state of ignorance. It is the square-root law of curves over finite fields, and the results above show it standing firm in every direction one might push.

There is a consolation, and it is the real prize. In failing to be a cryptographic witness, the signed circle count turned out to be an exact instrument for something else: it computes the odd leg of the two-square decomposition of a prime, its deficiency from the Weil ceiling is four times the square of the other leg, its powers of two count the prime factors of the modulus, and its behaviour under composition is Brahmagupta's identity in disguise. Fermat, Gauss and Jacobi are all in the room. The circle refuses to talk about factorization — but about itself, it is completely eloquent.
