# The Method That Deserved to Win

## How Euler's beautiful factorisation trick loses a race it was never going to win — and the exact reason why

There is a particular kind of mathematical idea that feels, the moment you meet it, as though it must be important. It is short. It is surprising. It turns a hard problem into a one-line computation. Euler's factorisation method is one of those ideas, and it has been seducing number theorists for two and a half centuries.

Here is the trick. Take a number $N$ and suppose somebody hands you two genuinely different ways of writing it as a sum of two squares:

$$N = a^2 + b^2 = c^2 + d^2.$$

Then compute a single greatest common divisor,

$$\gcd(ad - bc,\; N),$$

and out drops a factor of $N$. Not "usually". Not "with high probability". Always.

Try it. Take $N = 221$. It happens that
$$221 = 5^2 + 14^2 = 10^2 + 11^2.$$
The cross-term is $5 \cdot 11 - 14 \cdot 10 = 55 - 140 = -85$, and $\gcd(85, 221) = 17$. And indeed $221 = 13 \times 17$. The other cross-term, $ad + bc = 55 + 140 = 195$, gives $\gcd(195, 221) = 13$. Two gcds, both prime factors, no searching, no luck.

It is hard not to feel that this ought to be worth something. Factoring integers is the computational problem on which a large fraction of the world's cryptography is balanced. Here is a method that factors *instantly* — provided somebody first hands you the two representations.

That proviso is where the whole story lives. This article is about pricing it honestly: about proving exactly when the input exists, exactly what the algebra does when it does, and exactly how much the "provided somebody first hands you" costs. The answer, in one sentence, is that the combination step is flawless and the search step is fatal — and we can now say *why* the search step is fatal in a form that no clever implementation can dodge.

---

## Part I: The algebra is perfect

Let us first be precise about what "two genuinely different representations" means. If $N = a^2 + b^2$ then also $N = b^2 + a^2$, and swapping the two squares is not new information. So call two representations **essentially distinct** if they differ as unordered pairs: not merely $(c,d) \neq (a,b)$, but also $(d,c) \neq (a,b)$.

**Euler's Extraction Theorem.** *Let $N$ be a positive integer with two essentially distinct representations $N = a^2 + b^2 = c^2 + d^2$ in positive integers. Then*
$$1 < \gcd(ad - bc,\, N) < N.$$
*That is, the cross-term gcd is always a proper, nontrivial divisor.*

Note what the theorem does **not** assume. It says nothing about $N$ being a semiprime, nothing about primality, nothing about smoothness, nothing about the representations being "generic". Any $N$ at all, any two essentially distinct representations at all. The extraction never fails.

The proof rests on two identities discovered in India more than a millennium before Euler. The **Brahmagupta–Fibonacci identities** say that a product of two sums of two squares is again a sum of two squares, in two different ways:
$$(a^2+b^2)(c^2+d^2) = (ac+bd)^2 + (ad-bc)^2 = (ac-bd)^2 + (ad+bc)^2.$$
These are pure algebra — expand both sides. But apply them when $a^2+b^2 = c^2+d^2 = N$ and something remarkable happens: the left-hand side becomes $N^2$, so
$$(ac+bd)^2 + (ad-bc)^2 = N^2.$$
The two cross-quantities $ac+bd$ and $ad-bc$ are the legs of a right triangle with hypotenuse $N$.

Now suppose the extraction *failed*, in the sense that $N$ divided the cross-term $ad-bc$ exactly. Write $ad - bc = Nk$. Then $(ac+bd)^2 + N^2k^2 = N^2$, and since $ac+bd$ is strictly positive (all four parts are), we must have $k = 0$. So $ad = bc$, and then $(ac+bd)^2 = N^2$, so $ac + bd = N = a^2+b^2$.

This is where the key lemma enters — and it is the reason the theorem is unconditional.

**Rigidity Lemma.** *Suppose $a^2+b^2 > 0$, and suppose $ad = bc$ and $ac + bd = a^2 + b^2$. Then $c = a$ and $d = b$.*

Geometrically this is the equality case of the Cauchy–Schwarz inequality, done over the integers. Think of $(a,b)$ and $(c,d)$ as vectors in the plane. The condition $ad = bc$ says the vectors are parallel; the condition $ac + bd = a^2+b^2$ says their dot product equals $|(a,b)|^2$. Parallel plus correctly-normalised forces them to be the *same* vector. The algebraic proof is two lines: from $a \cdot (ac+bd) - b\cdot(ad-bc) = c(a^2+b^2)$ we get $(a^2+b^2)c = (a^2+b^2)a$, hence $c = a$; then $d = b$ follows.

So failure of the extraction forces the two representations to be literally equal — contradicting essential distinctness. A parallel argument, using the *other* Brahmagupta identity, shows that the cross-term is never coprime to $N$ either (that failure mode would force the representations to be equal *after a swap*). Between them, the two identities close both doors, and the gcd is trapped strictly between $1$ and $N$.

The argument is so robust that it survives at the boundary. Nothing really needs the parts to be strictly positive; non-negative is enough. So the degenerate representation $25 = 5^2 + 0^2 = 3^2 + 4^2$ is covered too: $\gcd(5\cdot 4 - 0 \cdot 3, 25) = 5$, right on the nose.

And a lovely corollary falls out for free. If $p$ is prime and had two essentially distinct representations, the theorem would produce a proper divisor of $p$ — impossible. So: **a prime has at most one way of being written as a sum of two squares.** A classical fact, obtained here as a side effect.

---

## Part II: Which numbers are even eligible?

The extraction step is a machine that turns two representations into a factor. Before asking how hard it is to feed the machine, ask a blunter question: for how many numbers does the food exist at all?

For a semiprime $N = pq$ with $p \neq q$ odd primes, the answer is completely rigid, and it depends only on the residues of $p$ and $q$ modulo $4$.

**The Eligibility Dichotomy.** *Let $p \neq q$ be odd primes. Then $pq$ admits two essentially distinct representations as a sum of two positive squares if and only if $p \equiv q \equiv 1 \pmod 4$. In that case there are exactly two — never one, never three.*

Both halves are sharp, and both are worth a moment.

The *negative* half comes from an old obstruction: if a prime $r \equiv 3 \pmod 4$ divides $n$ but $r^2$ does not, then $n$ is not a sum of two squares at all. (Reason: modulo $r$, the equation $a^2 + b^2 \equiv 0$ with $r \nmid b$ would make $-1$ a square mod $r$, which for $r \equiv 3 \pmod 4$ it is not; and if $r$ divides both $a$ and $b$ then $r^2$ divides $n$.) So in the semiprime table, the cells $(1,3)$, $(3,1)$ and $(3,3)$ contribute *zero* representations. Not "few". Zero.

The *positive* half — exactly two, in the $(1,1)$ cell — has a beautiful proof by counting. Fix representations of the primes themselves, $p = e^2 + f^2$ and $q = g^2+h^2$ (these exist and are unique for primes $\equiv 1 \bmod 4$). Now attach to *every* representation $a^2 + b^2 = pq$ a pair of bits:
$$\bigl(\,[\,p \mid af - be\,],\ [\,q \mid ah - bg\,]\,\bigr) \in \{0,1\}^2.$$
Two facts make this work. First, $p$ always divides one of $af - be$ and $af + be$ — because their product is $f^2 \cdot pq - b^2 \cdot p$, a multiple of $p$ — and it never divides both. So the bit is well defined. Second, and this is where the extraction theorem repays its debt: if two representations carry the *same* pair of bits, then $N$ divides their mutual cross-term, and the extraction theorem's own key lemma forces them to be equal. So the bit-map is injective.

Injective into a four-element set. So there are at most four *ordered* positive representations — at most two up to order. And the Brahmagupta identities manufacture exactly four:
$$A = eg+fh, \quad B = eh-fg, \qquad C = eg-fh, \quad D = eh+fg,$$
with $A^2+B^2 = C^2+D^2 = pq$. Upper bound meets lower bound: the count is exactly two.

That elementary $\{0,1\}^2$ is not an accident of bookkeeping. It has a name in disguise. In the **Gaussian integers** $\mathbb{Z}[i]$ — complex numbers with integer real and imaginary parts — the prime $p \equiv 1 \bmod 4$ splits into two conjugate primes $e + fi$ and $e - fi$. And one can show:

**The Class Bit Is a Divisibility.** *For $p = e^2+f^2$ prime and $a^2 + b^2 = pq$,*
$$(e+fi) \mid (a+bi) \ \text{ in } \mathbb{Z}[i] \iff p \mid af - be.$$

So the bit records **which of the two conjugate Gaussian primes above $p$ divides $a + bi$** — a genuinely arithmetic choice, of exactly the kind a Frobenius element makes. Exactly one of the pair divides, always. And once the bit is known, $a + bi$ factors as (a Gaussian prime of norm $p$) times (a Gaussian integer of norm $q$). The four representations are the four independent sign choices; that is the structural reason the count is a power of two.

Now for the number that decides the fate of the method. Primes $\equiv 1 \bmod 4$ and primes $\equiv 3 \bmod 4$ occur with equal density — half each — so if you draw two odd primes at random, the probability that both are $\equiv 1 \bmod 4$ is
$$\tfrac12 \times \tfrac12 = \tfrac14.$$
**Three quarters of semiprimes are simply invisible to Euler's method.** They have no representations at all; there is nothing to search for, nothing to combine. Whatever the method costs, it costs it on only a quarter of the world.

(One can cross-check all of this against the classical counting function. The number of *ordered integer* solutions of $x^2 + y^2 = n$, signs and zeros included, is $r_2(n) = 4\,(d_1(n) - d_3(n))$, the excess of divisors $\equiv 1 \bmod 4$ over those $\equiv 3 \bmod 4$. For $n = 221$: divisors $1, 13, 17, 221$, all $\equiv 1 \bmod 4$, so $r_2 = 16$, which is $4$ ordered-and-signed variants of each of the $2$ unordered representations $\{5,14\}$ and $\{10,11\}$ — $2 \times 8 = 16$. It checks.)

---

## Part III: Deterministic to the last digit

Before the bad news, one more piece of good news, because it is the sharpest thing in the whole story.

The extraction theorem says the gcd is *some* proper divisor. On the canonical pair of representations one can say precisely *which*. With $A, B, C, D$ as above, expand the two cross-terms. They do not merely happen to share a factor with $N$ — they factor completely:

$$AD - BC = 2\,e f\, q, \qquad AD + BC = 2\,g h\, p.$$

These are exact polynomial identities; expand both sides and watch them agree term by term. And since an odd prime $p = e^2+f^2$ divides neither $2$, nor $e$, nor $f$, the gcds are pinned down exactly:

$$\gcd(AD - BC,\, pq) = q, \qquad \gcd(AD + BC,\, pq) = p.$$

Not "a factor". The subtractive cross-term yields $q$ and the additive one yields $p$, every single time — the prime whose representation was *not* consumed by the twist. Work with normalised, non-negative parts and the two branches merge; then which prime emerges is decided purely by the sign of $BC = (eh-fg)(eg-fh)$.

So the combination step of Euler's method is not just correct, and not just unconditional. It is *deterministic*, in the strongest sense available: you can read off, in advance, which prime each of the two gcds will return.

---

## Part IV: The bill

And now the reckoning.

To use the method you must first *find* two representations. The obvious search walks the small part upward — try $a = 1, 2, 3, \dots$ and test whether $N - a^2$ is a perfect square — and stops when it has collected two hits.

Compare this with the classical competitor, **Fermat's difference-of-squares scan**: try $s = \lceil\sqrt N\rceil, \lceil\sqrt N\rceil + 1, \dots$ until $s^2 - N$ is a perfect square, then $N = (s-\sqrt{s^2-N})(s+\sqrt{s^2-N})$. Its behaviour is completely transparent. Write $p + q = 2u$ and $q = p + 2v$, so $u$ is the midpoint and $v$ the half-gap of the two factors. Then
$$u^2 = pq + v^2,$$
so the scan terminates exactly at $s = u$. How long is the walk? A little algebra with $x = \sqrt p$, $y = \sqrt q$ gives the two-sided estimate
$$\frac{(q-p)^2}{8\max(p,q)} \;\le\; \frac{p+q}{2} - \sqrt{pq} \;\le\; \frac{(q-p)^2}{8\sqrt{pq}}.$$
Fermat's scan is *quadratically* short in the imbalance: if the factors are close, it is essentially free. In fact one can name the balance point exactly:

**Fermat halts on the first trial iff the factors are balanced.** *With $p+q = 2u$, $q = p+2v$, $v > 0$: the very first trial value $\lfloor\sqrt{pq}\rfloor + 1$ already equals the target $u$ if and only if $v^2 < 2u$, i.e. if and only if $(q-p)^2 < 4(p+q)$.*

Now the punchline. What does the *representation* search cost on precisely those instances?

**The Quartic Barrier.** *Suppose $N = a^2+b^2 = c^2+d^2$ are two essentially distinct representations. If a search bound $t$ has reached the smaller part of each of them — that is, $t \geq \min(a,b)$ and $t \geq \min(c,d)$ — then*
$$2N < t^4.$$
*Equivalently, the search must run past $(2N)^{1/4}$.*

The proof is three lines and uses nothing at all: no primality, no genericity, no averaging over instances. Sort each representation so $a \le b$ and $c \le d$. Distinct representations must have distinct large parts, so say $d < b$, hence $b \ge d+1$. Then
$$c^2 = b^2 - d^2 + a^2 \ \ge\ (d+1)^2 - d^2 = 2d+1,$$
so $c^4 \ge (2d+1)^2 > 4d^2$. Meanwhile $2N = 2c^2 + 2d^2 \le 4d^2$ because $c \le d$. Chain them: $2N \le 4d^2 < c^4$. Done.

Read that inequality again, because it says something clean and slightly startling: **two distinct representations of the same number cannot both be shallow.** One of them may hug the axis — $221 = 5^2 + 14^2$ has a small part of only $5$ — but the other is then pushed away from it, and the push is quantitative. The larger of the two small parts always exceeds $(2N)^{1/4}$.

The barrier sharpens if the representations are far apart. If the two large parts differ by $k$, the same computation gives
$$2k^2 N < c^4,$$
the gap entering *quadratically*. And so a number with three representations, with strictly decreasing large parts, obeys $8N < a_3^4$ for the shallowest of the three: collecting more representations costs quadratically more depth. There is a complementary arithmetic reason as well — for $N = pq$ the "twisted" parts of the canonical pair satisfy $B^2 + C^2 \ge p + q - 1$, so the second representation is always forced far from the axes.

Put the two halves together and you get the sentence that names this whole investigation.

**Euler Loses on Balanced Instances.** *Let $p \neq q$ be primes $\equiv 1 \bmod 4$ with midpoint $u = (p+q)/2$ and half-gap $v = (q-p)/2$, and suppose the pair is balanced in the exact sense $v^2 < 2u$. Then:*

- *Fermat's difference-of-squares scan succeeds on its **first** trial; while*
- *the two representations of $pq$ exist, are essentially distinct, and **any** search that collects both must run past $(2pq)^{1/4}$ — and Euler's method needs that search twice.*

Concretely: $N = 13 \cdot 17 = 221$. Fermat's first trial is $\lfloor\sqrt{221}\rfloor + 1 = 15$, and $15^2 - 221 = 4 = 2^2$; done in one step. The representation route must find both $221 = 5^2+14^2$ and $221 = 10^2+11^2$, and no search can do so before passing $(442)^{1/4} \approx 4.58$ — in fact it must reach $10$. The gap widens ferociously with size: for $N = 10009 \times 10037 \approx 10^8$, Fermat still halts in one step, while the representation search must grind to depth $4867$.

Measured across a campaign of randomly drawn eligible semiprimes, the pattern is exactly what the theorems predict. A single representation search costs a couple of Fermat scans; Euler needs two of them; and the resulting end-to-end slowdown has a median in the single-digit multiples of Fermat with a long, punishing tail on precisely the balanced instances where Fermat is instantaneous. Only a quarter of instances are eligible at all. Every eligible instance is a loss.

---

## What we learn from a method that loses

There is a temptation to read "Euler loses" as a negative result and file it away. That is the wrong reading.

The value here is that the loss is now *measured and proved*, not merely observed. Three independent facts, each unconditional:

1. **Eligibility is exactly $1/4$**, because it is exactly the $(1 \bmod 4, 1 \bmod 4)$ cell, and there are exactly two representations there — never more, never fewer.
2. **The algebra never fails**, on any input, with the extracted prime determined in advance by an exact identity.
3. **The search can never be shallow**, because two distinct representations of $N$ are separated by a quartic barrier that holds for every $N$ and every pair of representations, with no distributional assumptions whatsoever.

The third is the one that closes the file. A merely empirical cost comparison always invites the objection "but you sampled badly" or "but a cleverer search would do better". The quartic barrier is immune to both. It is a statement about the *geometry of the lattice points on the circle* $x^2 + y^2 = N$: distinct lattice points on that circle repel each other, in a precise sense, and the repulsion sets a floor under any algorithm that wants to see two of them.

That geometric fact is the transferable content: any strategy hoping to catch two lattice points on that circle cheaply is fighting the shape of the circle, not the cleverness of its own implementation.

Euler's method remains what it always was: a two-line miracle that turns a pair of representations into a factorisation with no search and no luck. The miracle is real. It just happens to sit on the far side of a wall we can now measure, in a corner of the integers that occupies exactly one quarter of the map.

Knowing precisely where a beautiful idea stops working is not a consolation prize. It is the result.
