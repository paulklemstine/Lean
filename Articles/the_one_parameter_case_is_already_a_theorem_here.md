# The Polynomial That Refuses to Grow

## How a two-dimensional box of lattice points explains why the coefficients of a famous family of polynomials are only ever $-1$, $0$, or $1$

### A polynomial with a personality

Take the number $1$ and ask: which polynomials with whole-number coefficients have roots that are *roots of unity*, the complex numbers $z$ with $z^n = 1$? These numbers sit at the vertices of a regular $n$-gon on the unit circle, and they are the quiet backbone of an enormous amount of mathematics — Fourier analysis, error-correcting codes, the arithmetic of number fields, the discrete logarithm problems behind cryptography.

For each $n$ there is exactly one polynomial that is "the" minimal record of the $n$-gon: the **$n$-th cyclotomic polynomial** $\Phi_n(X)$, whose roots are precisely the *primitive* $n$-th roots of unity — the ones that generate all the others. Together they factor the simplest polynomial there is:
$$X^n - 1 \;=\; \prod_{d \mid n} \Phi_d(X).$$

Here are the first few:
$$\Phi_1 = X-1,\quad \Phi_2 = X+1, \quad \Phi_3 = X^2+X+1,\quad \Phi_4 = X^2+1,$$
$$\Phi_6 = X^2 - X + 1, \qquad \Phi_{12} = X^4 - X^2 + 1 .$$

Stare at these for a while and something starts to look suspicious. Every single coefficient is $-1$, $0$, or $1$. Keep computing — $\Phi_{35}$, $\Phi_{77}$, $\Phi_{143}$ — and the pattern holds. It holds for such a long time that when nineteenth-century computers (that is, people) first tabulated these polynomials, several of them conjectured that it holds always.

It does not. The first counterexample is $\Phi_{105}$, where the coefficient of $X^7$ is $-2$. And $105 = 3 \cdot 5 \cdot 7$ is the smallest number that is a product of three distinct odd primes. That coincidence is the whole story, and this article is about why.

We will call $\Phi_n$, viewed as a signed sequence of coefficients, the **$\pm$-frame of order $n$**. The question we want to answer is stark and quantitative:

> **How negative can a coefficient of the $\pm$-frame get?**

### One parameter: the easy theorem

If $n = p$ is prime, the answer is immediate. Since $X^p - 1 = (X-1)\Phi_p(X)$ and dividing out gives a geometric series,
$$\Phi_p(X) = 1 + X + X^2 + \cdots + X^{p-1}.$$
Every coefficient is $0$ or $1$. In particular every coefficient is at least $-1$. There is nothing to prove beyond the division; the frame is a solid block of $+1$'s with no signs at all. Call this the **one-parameter theorem**: for $p$ prime and any $k$, the coefficient of $X^k$ in $\Phi_p$ is $0$ or $1$, hence $\ge -1$.

The interesting question is what happens when you turn on a second parameter.

### Two parameters, and a geometric trick

Let $p \ne q$ be two distinct primes, and consider the $\pm$-frame of order $pq$. Now signs appear. For $p=3$, $q=5$:
$$\Phi_{15}(X) = 1 - X + X^3 - X^4 + X^5 - X^7 + X^8.$$
Minus signs, plus signs, gaps. It looks unruly. The claim — **Migotti's theorem** — is that despite the mess, every coefficient is $-1$, $0$, or $1$, and the negative excursions never go below $-1$.

The proof we will give does something that feels almost like cheating: it turns the question into a picture. Consider the polynomial
$$G_{p,q}(X) \;=\; \Bigl(\sum_{i=0}^{q-1} X^{ip}\Bigr)\Bigl(\sum_{j=0}^{p-1} X^{jq}\Bigr),$$
the product of two truncated geometric series, one stepping by $p$ and one stepping by $q$. Call it the **frame geometry**. Multiply it out: a term of the product is $X^{ip} \cdot X^{jq} = X^{ip+jq}$, so

> **the coefficient of $X^n$ in $G_{p,q}$ counts the pairs of whole numbers $(i,j)$ with $0 \le i < q$, $0 \le j < p$ and $ip + jq = n$.**

That is a statement about **integer points in a two-dimensional region**: the count of lattice points where the straight line $ip + jq = n$ crosses the rectangular box $[0,q) \times [0,p)$. We will call that rectangle the **balance box**.

Now the key geometric fact, and it is genuinely elementary:

> **Lattice-point uniqueness.** If $p$ and $q$ are coprime and $q > 0$, then the line $ip + jq = n$ meets the balance box in *at most one* point. Precisely: if $ip + jq = i'p + j'q$ with $0 \le i, i' < q$, then $i = i'$ and $j = j'$.

*Why.* Suppose without loss of generality $i \le i'$. Rearranging, $(i'-i)p = (j - j')q$, so $q$ divides $(i'-i)p$; since $\gcd(p,q)=1$, $q$ divides $i'-i$. But $0 \le i'-i < q$, so the only multiple of $q$ available is $0$: $i = i'$. Cancelling then forces $j = j'$. That is the entire argument — a divisibility step and an inequality. The width of the box in the $i$-direction is exactly $q$, one notch too small for a second solution to fit.

So every coefficient of $G_{p,q}$ is $0$ or $1$: the frame geometry is a *pure indicator*, recording for each exponent $n$ whether or not the line through $n$ hits the box.

### The bridge: a closed formula

The second half of the argument connects $G_{p,q}$ back to the $\pm$-frame. Two identities do it. The first is pure algebra: since $\sum_{i<q} X^{ip} = \sum_{i<q}(X^p)^i$ telescopes against $X^p - 1$,
$$(X^p - 1)(X^q - 1)\, G_{p,q}(X) \;=\; \bigl(X^{pq} - 1\bigr)^2 .$$
The second is the divisor factorisation of $X^{pq}-1$. Since $p$ and $q$ are distinct primes, the divisors of $pq$ are exactly $1, p, q, pq$, so
$$X^{pq} - 1 = \Phi_1 \Phi_p \Phi_q \Phi_{pq} = (X-1)\,\Phi_p\,\Phi_q\,\Phi_{pq},$$
and using $(X-1)\Phi_p = X^p-1$, $(X-1)\Phi_q = X^q - 1$ this becomes
$$(X^p-1)(X^q-1)\,\Phi_{pq}(X) = (X-1)\bigl(X^{pq}-1\bigr).$$
Cancel the common factor $(X^p-1)(X^q-1)$ from the two displayed identities and you get the **closed formula**:
$$\boxed{\;\Phi_{pq}(X)\cdot\bigl(X^{pq}-1\bigr) \;=\; (X-1)\cdot G_{p,q}(X).\;}$$

Read off coefficients. On the right, multiplying by $X-1$ takes the coefficient sequence to its *successive differences*. On the left, multiplying by $X^{pq}-1$ leaves the low-order coefficients (below $X^{pq}$) untouched except for a sign. The upshot is beautifully simple: for every exponent $n+1 < pq$,
$$\Phi_{pq}\text{'s coefficient at } X^{n+1} \;=\; g(n+1) - g(n),$$
where $g(m)$ is the lattice-point count — that is, $0$ or $1$. A difference of two numbers each in $\{0,1\}$ lies in $\{-1,0,1\}$. Above $X^{pq}$ there is nothing to check: the degree of $\Phi_{pq}$ is $(p-1)(q-1)$, comfortably below $pq$, so all higher coefficients vanish.

**Migotti's theorem is proved.** Every coefficient of $\Phi_{pq}$ lies in $\{-1,0,1\}$; in particular each is at least $-1$ and at most $1$.

Look at what has happened. A question about a polynomial of degree $(p-1)(q-1)$ — which for, say, $p=101$, $q=103$ has $10200$ coefficients — became a question about whether a line can pass through two points of a rectangle. The rectangle is too thin. That's the theorem.

### The frame reads a numerical semigroup

The indicator $g$ has a name in another part of mathematics. Below $pq$, having a lattice point in the box on the line $ip+jq = n$ is *exactly the same* as being able to write $n = ip + jq$ with $i,j \ge 0$ at all — the box constraints are automatic once $n < pq$. So $g$ is the indicator function of the **numerical semigroup** $\langle p, q\rangle$: the set of amounts of money you can pay exactly using coins of denomination $p$ and $q$.

This is the Chicken McNugget problem in disguise. With coins of $3$ and $5$ you can pay $0,3,5,6,8,9,10,\ldots$ but never $1,2,4,7$; the largest impossible amount is the **Frobenius number** $pq - p - q$, here $15-3-5 = 7$.

Now the sign pattern of the $\pm$-frame becomes fully transparent:
$$\text{coefficient at } X^{n+1} \;=\; [\,n+1 \in \langle p,q\rangle\,] \;-\; [\,n \in \langle p,q\rangle\,].$$
A coefficient is $+1$ exactly where the semigroup *starts* a run, $-1$ exactly where it *ends* one, and $0$ in the interior of runs and gaps. The $\pm$-frame is a derivative — an edge detector applied to the coin-payment pattern.

Test it on $p=3$, $q=5$. The payable amounts up to $8$ are $0,3,5,6,8$. Runs begin at $0,3,5,8$ and end after $0,3,6$; so coefficients $+1$ at $0,3,5,8$, and $-1$ at $1,4,7$ — and indeed
$$\Phi_{15} = 1 - X + X^3 - X^4 + X^5 - X^7 + X^8.$$
The $-1$ at $X^7$ is precisely the Frobenius number showing itself: $7$ cannot be paid with $3$'s and $5$'s while $6$ can. So the bound $-1$ is **attained**, not merely respected.

In fact it is attained for *every* pair of distinct primes, and the reason is the cheapest possible: $0$ is always payable (pay nothing) and $1$ never is (both coins cost at least $2$). Hence the coefficient of $X^1$ in $\Phi_{pq}$ is $0 - 1 = -1$, always. So $-1$ is the exact minimum of the set of coefficient values of $\Phi_{pq}$: it is a value that occurs, and no value occurs below it.

### Three structural corollaries, all from the same box

Once the frame is understood as the derivative of a semigroup indicator, several classical facts fall out as geometry.

**Balance.** Evaluating the frame at $X = 1$ gives $\Phi_{pq}(1) = 1$ (as $pq$ is not a prime power). So the coefficients sum to exactly $1$: since they are all $-1$, $0$, or $1$, the $+1$'s outnumber the $-1$'s by *exactly one*. A telescoping sum of $\pm 1$ edge markers, ending one run ahead — the polynomial is a balanced signed frame with a single unit of surplus.

**Sylvester's symmetry.** For every $n$ between $0$ and the Frobenius number $F = pq-p-q$, exactly one of $n$ and $F-n$ is payable. (If both were, adding the representations would express $F$ itself, contradiction; and a short argument shows at least one always is.) Reflection about $F/2$ swaps payable with unpayable. Consequently the lattice-point counts satisfy
$$g(n) + g(F-n) = 1 \qquad (0 \le n \le F),$$
and exactly **half** of the exponents $0,1,\ldots,(p-1)(q-1)-1$ are gaps: the gap count is $(p-1)(q-1)/2$. This is Sylvester's classical theorem on numerical semigroups, here read directly off the balance box.

**Palindromicity.** Feeding the reflection $g(n)+g(F-n)=1$ through the closed formula shows that $\Phi_{pq}$ is self-reciprocal: with $D = (p-1)(q-1)$ its degree,
$$\text{coefficient at } X^k \;=\; \text{coefficient at } X^{D-k} \qquad (0 \le k \le D).$$
The frame reads the same forwards and backwards. Check on $\Phi_{15}$: $1,-1,0,1,-1,1,0,-1,1$ — a palindrome.

### Where the argument breaks, exactly

Good theorems come with a sharp boundary, and here the boundary is visible. The single load-bearing hypothesis in the entire development is that $p$ and $q$ be **coprime** — that is what makes the line hit the box at most once. Drop it and the mechanism dies immediately.

Take steps $2$ and $4$. The line $2i + 4j = 4$ meets the box $[0,4) \times [0,2)$ in **two** points: $(i,j) = (2,0)$ and $(i,j) = (0,1)$. So the frame geometry $G_{2,4}$ has the coefficient $2$ at $X^4$, and the difference-of-indicators argument cannot possibly deliver values in $\{-1,0,1\}$. Coprimality is not a convenience of the proof; it is the exact frontier of the phenomenon.

### And with three parameters?

This tells us precisely where to expect Migotti's bound to fail: not for coprimality reasons — $3,5,7$ are pairwise coprime — but for **dimensional** ones. The three-parameter analogue of the frame geometry involves a *box in three dimensions*, $[0,\cdot)\times[0,\cdot)\times[0,\cdot)$, and the constraint is now that a **plane** $ip + jq + kr = n$ should meet it in at most one point. Planes are much roomier than lines. A two-dimensional plane slicing a three-dimensional box will generically catch several lattice points, and the excess multiplicity is exactly what the coefficient records.

That is the structural reason $\Phi_{105}$ manages a $-2$: the ternary geometry of $3, 5, 7$ admits configurations in which the counting function jumps by two, and no thinness argument excludes them. And once one extra point is possible, no bound at all survives: it is known that the coefficients of cyclotomic polynomials are, as $n$ ranges over all integers, *unbounded* in both directions — you can find a cyclotomic polynomial with a coefficient smaller than any prescribed number. The natural quantitative conjecture in the present framework is that already three prime parameters suffice: for every $M \ge 1$ there should exist distinct primes $p<q<r$ and an exponent $k$ with the coefficient of $X^k$ in $\Phi_{pqr}$ at most $-M$, the deficit measured exactly by lattice-point multiplicity on planes through the three-dimensional box.

### Why any of this matters

Cyclotomic polynomials are not ornamental. They are the multiplication tables of roots of unity, and so they appear wherever periodicity is factored:

* **Factoring and primality.** Special-purpose factoring methods and primality certificates exploit factorisations of $a^n - 1$, whose pieces are cyclotomic values. Knowing that the coefficients of $\Phi_{pq}$ are tiny means these polynomials can be evaluated with no coefficient growth — a real advantage in fixed-precision arithmetic.
* **Coding theory.** The generator polynomials of cyclic and BCH codes are products of cyclotomic factors over finite fields; the integral structure above controls what happens when you lift or reduce them.
* **Lattice cryptography.** Modern post-quantum schemes live in rings $\mathbb{Z}[X]/(\Phi_n(X))$. Small coefficients of $\Phi_n$ mean small "expansion factors" when you multiply and reduce — a property with direct consequences for noise growth in encryption schemes. That is one reason such schemes overwhelmingly choose $n$ a power of two, where $\Phi_n(X) = X^{n/2}+1$ is as small as a polynomial gets.
* **The coin problem.** The dictionary above runs both ways: statements about frame coefficients are statements about which amounts of money are payable, and Sylvester's half-of-everything gap count is a theorem in that language.

But the deepest reason to like this argument is aesthetic. The question "how negative can a coefficient be?" has, on its face, nothing to do with geometry. The closed formula converts it — losslessly — into "how many integer points can a line have inside a $q \times p$ rectangle?" And then the answer is *one*, because the rectangle is one unit too thin, and $\gcd(p,q)=1$ means the line's steps are too coarse to land twice.

A polynomial refuses to grow because a box is narrow. That is a good day's work for mathematics.
