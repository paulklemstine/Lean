# The Secret Frequencies of Pythagoras

## How the tree of right triangles hums at a pitch set by the primes — and what that has to do with breaking codes

### A tree grown from one triangle

Everybody meets $3^2 + 4^2 = 5^2$ in school and then forgets about it. Almost nobody is told the astonishing fact that lies one step further on: **every** right triangle with whole-number sides grows out of that one, by a completely mechanical rule.

Write a triple $(a,b,c)$ with $a^2 + b^2 = c^2$ as a column of three numbers, and hit it with one of these three matrices:

$$
M_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},
\qquad
M_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},
\qquad
M_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}.
$$

Start with $(3,4,5)$. The first matrix gives $(5,12,13)$. The second gives $(21,20,29)$. The third gives $(15,8,17)$. Every one of them is again a right triangle with integer sides, with no common factor. Repeat, and you get an infinite ternary tree containing every primitive Pythagorean triple exactly once — a perfect, lossless catalogue of a set of numbers that Euclid already cared about.

The reason the trick works is a piece of geometry hiding in plain sight. The condition $a^2 + b^2 = c^2$ says that the vector $(a,b,c)$ is *null* for the quadratic form
$$Q(a,b,c) = a^2 + b^2 - c^2,$$
which is precisely the form of Minkowski spacetime in two space dimensions and one time dimension. And each of the three matrices satisfies
$$M_i^{\mathsf T} \, \mathrm{diag}(1,1,-1) \, M_i = \mathrm{diag}(1,1,-1);$$
they are **Lorentz transformations with integer entries**. Pythagorean triples are the integer light rays of a toy universe, and the Berggren tree is what you get by bouncing one light ray around with a fixed set of integer boosts. That is why triples go to triples: it is not a computational coincidence, it is a symmetry.

This article is about a question that seems, at first, to have nothing to do with any of that: *what happens to the tree when you look at it modulo a prime?* The answer turns out to be surprisingly sharp, surprisingly musical, and — for one of the three matrices — surprisingly useful for taking numbers apart.

---

### Two matrices that go nowhere, and one that sings

The first thing to do with a matrix is to look at its eigenvalues. Here the three generators split into two utterly different species.

For $M_1$ and $M_3$, the characteristic polynomial is
$$\det(X I - M_1) = \det(X I - M_3) = (X-1)^3.$$
All three eigenvalues equal $1$. Such a matrix is called **unipotent**: it is the identity plus something nilpotent. And indeed $(M_1 - I)^3 = 0$ while $(M_1 - I)^2 \neq 0$, so the nilpotent part is as large as a $3\times 3$ matrix allows. The consequence is that powers of $M_1$ do not grow exponentially, they grow *polynomially*, and one can write them down exactly:
$$
M_1^{\,k} = \begin{pmatrix} 1 & -2k & 2k \\ 2k & 1-2k^2 & 2k^2 \\ 2k & -2k^2 & 1 + 2k^2 \end{pmatrix},
\qquad
M_3^{\,k} = \begin{pmatrix} 1-2k^2 & 2k & 2k^2 \\ -2k & 1 & 2k \\ -2k^2 & 2k & 1+2k^2 \end{pmatrix}.
$$
Every entry is a quadratic polynomial in the step number $k$. Nothing oscillates. Nothing resonates.

For $M_2$ the story is completely different:
$$\det(X I - M_2) = (X+1)\,(X^2 - 6X + 1).$$
The quadratic factor has roots
$$3 \pm 2\sqrt{2} = (1 \pm \sqrt2)^2,$$
the square of the **silver ratio** $1 + \sqrt2$ — the fundamental unit of the ring $\mathbb{Z}[\sqrt2]$, and the number governing the Pell equation $x^2 - 2y^2 = 1$. The two roots multiply to $1$: one expands, the other contracts at exactly the reciprocal rate. Together with the eigenvalue $-1$ this makes $M_2$ a **hyperbolic** Lorentz boost with a built-in reflection. It stretches spacetime along one null direction by a factor $3 + 2\sqrt 2 \approx 5.828$ and squeezes the other by the same factor. That is why the triples along the $M_2$ branch — $(3,4,5)$, $(21,20,29)$, $(119,120,169)$, … — grow geometrically.

So the tree of Pythagorean triples has two kinds of branches: **drifting** ones (polynomial, unipotent) and **oscillating** ones (exponential, hyperbolic). The whole story that follows is about what these two behaviours become when the world is made finite.

---

### Making the world finite: resonance

Reduce everything modulo a prime $p$. Now the matrices live in a finite group, so every one of them has a finite order: some power returns to the identity. Call the least such exponent the **resonant frequency** of that generator at $p$ — the number of steps after which the dynamics comes back into phase.

For the unipotent branches the answer is disappointing, and provably so. Modulo any odd number $m$ one has
$$M_1^{\,k} \equiv I \pmod m \iff m \mid k,$$
and identically for $M_3$. So the resonant frequency of a unipotent branch **is the modulus itself**, never a proper divisor of it. You can read this straight off the closed form: $M_1^k - I$ has entries $\pm 2k$ and $\pm 2k^2$, and for odd $m$ these vanish mod $m$ exactly when $m \mid k$.

For the hyperbolic branch the answer is the heart of the matter. Modulo $p$, the matrix $M_2$ is conjugate (by an explicit integer matrix of determinant $2$) to a block-diagonal matrix with the $2\times 2$ block
$$U = \begin{pmatrix} 3 & 2 \\ 4 & 3\end{pmatrix}$$
and the scalar $-1$. This $U$ is nothing but the number $3 + 2\sqrt2$ wearing a matrix costume: write $U = 3 I + S$ with $S = \begin{pmatrix}0&2\\4&0\end{pmatrix}$, and check $S^2 = 8I$, so $S$ literally *is* $\sqrt 8 = 2\sqrt 2$.

Now apply the Frobenius map, the "raise everything to the $p$-th power" operation that governs all of finite-field arithmetic. Because raising a sum to the $p$-th power in characteristic $p$ distributes across the sum,
$$U^p = 3I + 8^{(p-1)/2} S.$$
The number $8^{(p-1)/2} = (2^{(p-1)/2})^3$ is the Legendre symbol of $2$ modulo $p$ — it equals $+1$ or $-1$, nothing else. Which one, is decided by one of the oldest and prettiest facts in number theory, the second supplement to quadratic reciprocity: **$2$ is a square modulo $p$ exactly when $p \equiv \pm 1 \pmod 8$.**

That single bit of information sets the pitch of the entire hyperbolic branch:

> **Hyperbolic Resonance Theorem.** Let $p$ be an odd prime. If $p \equiv \pm 1 \pmod 8$ then $M_2^{\,p-1} \equiv I \pmod p$. If $p \equiv \pm 3 \pmod 8$ then $M_2^{\,p+1} \equiv I \pmod p$. In either case $M_2^{\,p^2-1} \equiv I \pmod p$.

When $8^{(p-1)/2} = 1$, the Frobenius fixes $U$, so $U^p = U$ and $U^{p-1} = I$: the eigenvalues live *inside* $\mathbb{F}_p$ and behave like ordinary units, whose orders divide $p-1$. When $8^{(p-1)/2} = -1$, the Frobenius flips $\sqrt 2$ to $-\sqrt 2$, so $U^p = U^{-1}$ (concretely, $U^p = 6I - U$, which is the inverse of $U$ because $U(6I - U) = I$), hence $U^{p+1} = I$: the eigenvalues live in the quadratic extension $\mathbb{F}_{p^2}$ and lie on its norm-one circle, whose order is $p+1$.

That is the whole phenomenon. **The prime chooses the frequency, and it chooses it by its residue modulo $8$.** One can even say exactly how sharp the bound is:

> **Order Formula.** For an odd prime $p$, $M_2^{\,k} \equiv I \pmod p$ if and only if $U^k = I$ in $\mathbb{F}_p$ *and* $k$ is even; consequently the exact order of $M_2$ modulo $p$ equals $\mathrm{lcm}\bigl(2,\ \mathrm{ord}_p(U)\bigr)$.

The extra factor of $2$ is the price of the eigenvalue $-1$, the reflection built into the boost.

And the split-versus-inert alternative is visible directly in the spectrum:

> **Spectral Dichotomy.** A scalar $\lambda$ is an eigenvalue of $M_2$ modulo $p$ — meaning some nonzero vector over $\mathbb{F}_p$ is scaled by $\lambda$ — if and only if $(\lambda + 1)(\lambda^2 - 6\lambda + 1) = 0$. The quadratic factor has a root in $\mathbb{F}_p$ if and only if $2$ is a square modulo $p$. Hence for $p \equiv \pm 1 \pmod 8$ there are three distinct eigenvalues $-1, 3+2\sqrt2, 3-2\sqrt2$ in $\mathbb{F}_p$, while for $p \equiv \pm 3 \pmod 8$ the *only* eigenvalue in $\mathbb{F}_p$ is $-1$ and the hyperbolic pair hides in $\mathbb{F}_{p^2}$.

So "the resonant frequency of $p$" is not a metaphor stapled onto the algebra: it is literally read off the spectrum. Split spectrum $\Leftrightarrow$ frequency $p-1$. Inert spectrum $\Leftrightarrow$ frequency $p+1$.

---

### Frequencies that don't line up

Here is where cryptography walks in.

Take an RSA-style modulus $N = pq$, a product of two large primes that nobody is supposed to be able to separate. Run the Berggren generator $M_2$ modulo $N$. By the Chinese Remainder Theorem, a power of $M_2$ is the identity modulo $N$ exactly when it is the identity modulo $p$ **and** modulo $q$. In the language above: the modulus $N$ is silent only when *both* of its prime frequencies are in phase.

But now suppose we can find a step count $k$ at which $p$ is in resonance and $q$ is not. Then $M_2^k - I$, computed over the integers, is divisible entrywise by $p$, while at least one entry is *not* divisible by $q$. Take the greatest common divisor of that entry with $N$: divisible by $p$, not by $q$, and a divisor of $pq$ — so it is exactly $p$.

> **Resonance Factorization Theorem.** Let $N = pq$ with $p, q$ prime. If $k$ is an exponent with $M_2^{\,k} \equiv I \pmod p$ but $M_2^{\,k} \not\equiv I \pmod q$, then some entry $x$ of the integer matrix $M_2^{\,k} - I$ satisfies $\gcd(x, N) = p$ exactly. In particular, whenever the canonical resonant exponent of $p$ — namely $p^2-1$, or sharply $p \mp 1$ according to $p \bmod 8$ — is not also a resonance of $q$, the Berggren generator splits $N$.

A worked example, small enough to check by hand. Take $N = 15 = 3 \cdot 5$. Since $3 \equiv 3 \pmod 8$, the frequency of $3$ is $3+1 = 4$; the frequency of $5$ is $5 + 1 = 6$. Compute
$$M_2^4 - I = \begin{pmatrix} 288 & 288 & 408 \\ 288 & 288 & 408 \\ 408 & 408 & 576\end{pmatrix}.$$
Every entry is divisible by $3$, none by $5$, and $\gcd(288,15) = 3$. The tree has told us how to factor $15$.

A more respectable example: the textbook RSA modulus $N = 3233 = 53 \cdot 61$. Now $53 \equiv 5 \pmod 8$, so the frequency of $53$ is $54$, while $61 \equiv 5 \pmod 8$ gives $61$ the frequency $62$. At step $k = 54$ the matrix $M_2^{54}$ is the identity modulo $53$ but not modulo $61$, and the greatest common divisor of any entry of $M_2^{54} - I$ with $3233$ comes out to exactly $53$.

There is an honest converse, and it deserves to be stated as loudly as the theorem:

> **Alignment Barrier.** If the exponent $k$ happens to be a resonance of the *whole* modulus $N$ — that is, if the two prime frequencies coincide at $k$ — then every greatest common divisor the method can compute equals $N$ itself, and nothing is learned.

Modulo $15$, the frequencies $4$ and $6$ align at their least common multiple $12$: at $k=12$ every entry of $M_2^{12}-I$ is divisible by $15$ and the gcd is the useless divisor $N$. **Misalignment is not a convenience of the method; it is the entire mechanism.** This is exactly why the search has to walk through exponents one prime power at a time rather than jumping to a big one.

And this is also the moment to be candid about what has and has not been achieved. This is not a break of RSA. What the theorem gives is a rigorous, exactly-analysed member of the family that contains Pollard's $p-1$ method and Williams' $p+1$ method: it succeeds quickly precisely when one of the quantities $p-1$ or $p+1$ has only small prime factors. Real RSA primes are chosen so that neither does. What is genuinely new here is the *source* of the method — the Pythagorean tree — and the fact that the Berggren generator covers both the $p-1$ and the $p+1$ case in a single matrix, with the residue of $p$ modulo $8$ automatically selecting which. Nature does the case analysis for you.

Which brings us to the third matrix, and to a negative result that is arguably the most interesting finding of all.

---

### Why two branches of the tree are useless — provably

We saw that $M_1^k - I$ has entries only $0$, $\pm 2k$, $\pm 2k^2$. Suppose you tried to run the same gcd trick on the unipotent branch, hoping some entry would share a factor with $N$. For odd $N$, any such gcd divides $\gcd(k^2, N)$, and hence:

> **Unipotent Factoring Barrier.** Any prime that a unipotent branch of the Berggren tree ever reveals as a divisor of an odd modulus $N$ must already divide the exponent $k$ you used. The unipotent branch carries no factoring information whatsoever.

You would have to already know a prime factor of $N$ in order to see it. This is a proof of futility, and it makes a structural point: of the three generators of the tree of right triangles, **exactly one carries arithmetic information about the modulus**, and it is the hyperbolic one. Resonance requires oscillation. A drifting motion has nothing to be in or out of phase with.

---

### A Lucas sequence hiding in the tree

There is a final gift. The traces of the powers of $M_2$,
$$t(k) = \mathrm{tr}\bigl(M_2^{\,k}\bigr) = (3+2\sqrt2)^k + (3-2\sqrt2)^k + (-1)^k,$$
form an integer sequence
$$3,\ 5,\ 35,\ 197,\ 1155,\ 6725,\ 39203,\ 228485,\ 1331715,\ 7761797,\ \dots$$
obeying the three-term recurrence dictated by the characteristic polynomial,
$$t(k+3) = 5\,t(k+2) + 5\,t(k+1) - t(k).$$
So each term costs two multiplications by $5$ and a subtraction, and $t(n) \bmod n$ can be computed for any $n$ in linear time (and, with matrix exponentiation, in logarithmic time).

Why care? Because the Frobenius argument that produced the resonance theorem also produces a congruence:

> **Berggren–Lucas Congruence.** For every odd prime $p$, $\ t(p) \equiv 5 \pmod p$. Note that $5 = t(1) = \mathrm{tr}(M_2)$: the Frobenius fixes the trace.

Its contrapositive is a primality test in the Fermat–Lucas family: if $n$ is odd and $t(n) \not\equiv 5 \pmod n$, then $n$ is composite, no factorisation required. For instance $t(9) = 7\,761\,797 \equiv 8 \pmod 9$, which certifies that $9$ is composite. Among the odd composites below $400$, the test convicts $118$ of $122$; the four escapees are $35$, $119$, $169$ and $385$ — the first Berggren pseudoprimes. Whether the strengthened two-sided version of the test (adding the condition $t(n+1) \equiv t(n-1) \bmod n$) admits any composite at all is an open question of exactly the flavour of the famous Baillie–PSW problem, and a counterexample would be a single explicit odd number.

---

### The shape of the idea

Step back and look at what has happened. We began with a piece of Greek geometry, noticed that it is secretly Lorentzian, and found that the generators of its symmetry come in two flavours: shear and boost. We then reduced the picture modulo a prime, where "boost" turns into "rotation of a finite circle" and the circle's circumference is $p-1$ or $p+1$ — a choice made by the ancient question of whether $2$ is a perfect square modulo $p$. Because two different primes generically choose different circumferences, a single integer matrix, iterated the right number of times, can hear the difference between them, and that difference is enough to pull a semiprime apart.

The three ingredients — a geometric object (right triangles), an algebraic one (units of $\mathbb{Z}[\sqrt2]$), and an arithmetic one (quadratic reciprocity) — are each older than modern cryptography by centuries or millennia. What links them is the very modern idea that *the spectrum of an operator is a frequency*, and that arithmetic makes different primes sing at different pitches. Listen carefully enough to a triangle, and it will tell you about the primes.

---

### Summary of results

- **Spectral classification.** $M_1$ and $M_3$ have characteristic polynomial $(X-1)^3$ with $(M_i - I)^3 = 0$ and $(M_i-I)^2 \neq 0$; $M_2$ has characteristic polynomial $(X+1)(X^2-6X+1)$, with hyperbolic eigenvalues $3 \pm 2\sqrt 2 = (1\pm\sqrt2)^{\pm 2}$, the square of the silver ratio, a unit of norm $1$ in $\mathbb{Z}[\sqrt 2]$.
- **Lorentz structure.** All three generators satisfy $M^{\mathsf T}\mathrm{diag}(1,1,-1)M = \mathrm{diag}(1,1,-1)$ over any commutative ring, hence map Pythagorean triples to Pythagorean triples, over $\mathbb{Z}$ and modulo any $N$.
- **Unipotent resonance and barrier.** $M_1^k \equiv I \pmod m$ iff $m \mid k$ for odd $m$, so the order is exactly $m$; every gcd from this branch divides $\gcd(k^2,m)$, so it yields no factoring advantage.
- **Hyperbolic resonance.** For odd $p$: $M_2^{p-1}\equiv I$ if $p \equiv \pm1 \pmod 8$, $M_2^{p+1}\equiv I$ if $p\equiv\pm3\pmod 8$, and always $M_2^{p^2-1}\equiv I$; exactly, $\mathrm{ord}_p(M_2) = \mathrm{lcm}(2,\mathrm{ord}_p(U))$ for $U = \left(\begin{smallmatrix}3&2\\4&3\end{smallmatrix}\right)$.
- **Spectral dichotomy.** $\lambda$ is an eigenvalue of $M_2$ mod $p$ iff $(\lambda+1)(\lambda^2-6\lambda+1)=0$; the quadratic splits in $\mathbb{F}_p$ iff $2$ is a square mod $p$ iff $p \equiv \pm 1 \pmod 8$ — the split/inert dichotomy *is* the $p-1$ versus $p+1$ frequency dichotomy.
- **Factorization.** A resonance of $p$ that is not a resonance of $q$ produces an entry of $M_2^k - I$ whose gcd with $N = pq$ is exactly $p$; conversely, an exponent in resonance with all of $N$ produces only the trivial gcd $N$.
- **Trace sequence.** $t(k) = \mathrm{tr}(M_2^k)$ satisfies $t(k+3) = 5t(k+2)+5t(k+1)-t(k)$ with $t(0..3) = 3,5,35,197$, and $t(p)\equiv 5 \pmod p$ for every odd prime $p$, giving a linear-time compositeness test.
