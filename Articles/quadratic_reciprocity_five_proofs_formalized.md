# The Golden Theorem, Seen From Five Windows

## A puzzle hidden in the remainders

Pick a prime number, say $p = 7$. Now ask a deceptively simple question: which numbers are *perfect squares* when we only care about remainders after dividing by $7$? Squaring $1, 2, 3, 4, 5, 6$ and reducing modulo $7$ gives $1, 4, 2, 2, 4, 1$. So the squares modulo $7$ are exactly $\{1, 2, 4\}$. The other residues, $\{3, 5, 6\}$, are *non-squares*. Half the nonzero residues are squares and half are not — a tidy split that happens for every odd prime.

Mathematicians encode this split with a compact piece of notation, the **Legendre symbol**. For an odd prime $p$ and an integer $a$ not divisible by $p$, we write

$$\left(\frac{a}{p}\right) = \begin{cases} +1 & \text{if } a \text{ is a nonzero square modulo } p, \\ -1 & \text{if } a \text{ is not a square modulo } p. \end{cases}$$

So $\left(\frac{2}{7}\right) = +1$ because $2 \equiv 3^2 \pmod 7$, while $\left(\frac{3}{7}\right) = -1$.

This looks like bookkeeping. But buried inside it is one of the most beautiful and surprising facts in all of mathematics — a fact so admired that Carl Friedrich Gauss called it the **theorema aureum**, the *golden theorem*, and returned to it again and again, producing eight different proofs over his lifetime.

## The astonishing symmetry

Take two distinct odd primes, say $p = 5$ and $q = 13$. Ask two seemingly unrelated questions:

- Is $5$ a square modulo $13$?
- Is $13$ a square modulo $5$?

There is no obvious reason these should have anything to do with each other. The first lives in the arithmetic of $13$; the second in the arithmetic of $5$. And yet **the Law of Quadratic Reciprocity** says their answers are locked together. In its cleanest form:

$$\left(\frac{p}{q}\right)\left(\frac{q}{p}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$

Read that again. The question "is $p$ a square mod $q$?" and the reverse question "is $q$ a square mod $p$?" always give the *same* answer — unless **both** $p$ and $q$ leave remainder $3$ when divided by $4$, in which case the answers are *opposite*. That single exponent, $\frac{p-1}{2}\cdot\frac{q-1}{2}$, is odd precisely when both primes are of the form $4k+3$.

For our example, $5 = 4\cdot1+1$ and $13 = 4\cdot3+1$, so the exponent is even and the two answers agree. Indeed $5 \equiv 25/... $ — checking directly, the squares mod $13$ are $\{1,3,4,9,10,12\}$, which contains none equal to $5$, so $\left(\frac{5}{13}\right)=-1$; and the squares mod $5$ are $\{1,4\}$, and $13\equiv 3$, so $\left(\frac{13}{5}\right)=-1$. Both $-1$: they agree, exactly as the law predicts.

Why should a fact about $13$ know anything about a fact about $5$? This mystery has driven number theory for two centuries. The reciprocity law was the seed from which class field theory, the Langlands program, and much of modern arithmetic grew.

## The two companions

Reciprocity, in its main form, relates two *odd* primes. But two special cases sit slightly apart and deserve their own names — the **supplementary laws**. They answer: when is $-1$ a square modulo $p$, and when is $2$ a square modulo $p$?

**The first supplement.** For every odd prime $p$,

$$\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}}.$$

Unwinding the exponent: $-1$ is a square modulo $p$ exactly when $p \equiv 1 \pmod 4$. This is not a curiosity — it is the arithmetic heart of Fermat's theorem that a prime is a sum of two squares if and only if it is $2$ or leaves remainder $1$ modulo $4$. The number $-1$ having a square root modulo $p$ is what lets $p$ split as $a^2 + b^2$.

**The second supplement.** For every odd prime $p$,

$$\left(\frac{2}{p}\right) = (-1)^{\frac{p^2-1}{8}}.$$

Here the exponent $\frac{p^2-1}{8}$ is always a whole number, and it is even exactly when $p \equiv \pm 1 \pmod 8$. So $2$ is a square modulo $p$ precisely when $p$ leaves remainder $1$ or $7$ when divided by $8$, and a non-square when the remainder is $3$ or $5$. Try $p = 7$: since $7 \equiv 7 \pmod 8$, the law predicts $2$ is a square, and indeed we saw $2 \equiv 3^2 \pmod 7$. Try $p = 5$: since $5 \equiv 5 \pmod 8$, the law predicts a non-square, and indeed $\{1,4\}$ omits $2$.

Both of these compact formulas — the answer to an infinite family of questions, packaged into a single exponent — are established here with complete rigor, and independently of the main reciprocity law.

## Five windows onto one truth

What makes quadratic reciprocity endlessly fascinating is not just that it is true, but that it is true *for so many different reasons*. Gauss's eight proofs were only the beginning; today well over two hundred are known. Each proof is a different window onto the same landscape, and each reveals a feature the others hide.

**Window 1 — Euler's criterion.** The most elementary lens comes from a beautiful fact of Euler: for an odd prime $p$,

$$\left(\frac{a}{p}\right) \equiv a^{\frac{p-1}{2}} \pmod p.$$

Raising $a$ to the power $\frac{p-1}{2}$ acts as a perfect detector: the result is $+1$ if $a$ is a square and $-1$ if it is not. This single congruence is the bedrock on which every other approach rests. In particular, the first supplement drops out immediately: set $a = -1$, and $(-1)^{\frac{p-1}{2}}$ *is* the answer.

**Window 2 — Gauss's lemma and counting.** Gauss's lemma reframes the Legendre symbol as a counting problem. Look at the multiples $a, 2a, 3a, \dots, \frac{p-1}{2}a$ modulo $p$, and count how many land in the "upper half" of the residues (those bigger than $p/2$). If that count is $m$, then $\left(\frac{a}{p}\right) = (-1)^m$. The whole subtlety of whether $a$ is a square is converted into a tally of how often multiplication pushes numbers past the halfway mark. This is the window through which the second supplement is proved here: for $a=2$, one shows the count of multiples $2, 4, 6, \dots$ that exceed $p/2$ has exactly the same parity as $\frac{p^2-1}{8}$, a fact that reduces to a clean check of the residue of $p$ modulo $8$.

**Window 3 — Eisenstein's lattice points.** Gotthold Eisenstein, a student of Gauss, turned the counting of the lemma into geometry. He interpreted the exponent $\frac{p-1}{2}\cdot\frac{q-1}{2}$ as the number of lattice points — points with whole-number coordinates — strictly inside a rectangle, and split them by a diagonal line. Counting the points below the diagonal one way, and above it another way, and noting that together they fill the rectangle, produces the reciprocity exponent almost by inspection. It is arguably the most visual proof ever devised: reciprocity as a matter of dots in a box.

**Window 4 — Gauss sums.** The deepest classical window uses roots of unity. A **Gauss sum** blends the Legendre symbol with the complex exponentials $\zeta^k = e^{2\pi i k/p}$:

$$g = \sum_{k=1}^{p-1} \left(\frac{k}{p}\right)\zeta^{k}.$$

This object has a magical property: its square is $\pm p$, with the sign governed by the first supplement. Feeding this algebraic identity through the arithmetic of the primes $p$ and $q$ inside the same ring of roots of unity forces the reciprocity relation to appear. Gauss sums are the ancestors of $L$-functions and the analytic engine of modern number theory.

**Window 5 — the permutation sign (Zolotarev) and class field theory.** Zolotarev discovered that the Legendre symbol $\left(\frac{a}{p}\right)$ is nothing other than the *sign* of the permutation that multiplication-by-$a$ induces on the residues modulo $p$. Squareness becomes a statement about whether a shuffle is even or odd. Pushed to its natural conclusion, this idea — that reciprocity is about how one arithmetic system sits symmetrically inside another — becomes the founding principle of **class field theory**, where reciprocity laws describe how primes factor in field extensions. From this height, the golden theorem is a shadow cast by a vast structural symmetry.

## Why five proofs, and not one?

A skeptic might ask: once a theorem is proved, why hunt for more proofs? The answer is that in mathematics a proof is not only a certificate of truth; it is a *map of connections*. Each of the five windows links quadratic reciprocity to a different continent of mathematics — elementary congruences, combinatorial counting, lattice geometry, harmonic analysis over finite fields, and the deep symmetries of Galois theory. The fact that all five arrive at the same summit is itself a discovery: it says these continents are secretly one landmass.

The three structurally independent routes emphasized here — cyclotomic Gauss sums, Eisenstein's lattice-point counting, and the parity of the multiplication permutation — are genuinely different arguments, sharing only Euler's criterion as common ground. Their independence matters. It means the golden theorem does not rest on a single clever trick that might one day be undermined; it is overdetermined, cornered from many directions at once.

## The reach of the golden theorem

Quadratic reciprocity is not a museum piece. Deciding whether a number is a square modulo a prime is a computational primitive that appears throughout modern cryptography and algorithmic number theory. Reciprocity, generalized to the Jacobi symbol, lets one compute these answers with astonishing speed — without ever factoring the numbers involved — by a process that mirrors the Euclidean algorithm. Primality tests, the security of certain cryptosystems, and the design of error-correcting codes all lean on this two-hundred-year-old symmetry between primes.

And the story is not finished. The exponents $\frac{p-1}{2}$ and $\frac{p^2-1}{8}$ that govern $-1$ and $2$ are only the first two members of an infinite family: for every small number $d$, the question "is $d$ a square modulo $p$?" is answered by a formula depending only on the remainder of $p$ modulo $4d$. The search for the cleanest unified statement of all these laws — a single functional that simultaneously reads as a Gauss-sum sign, a lattice-point parity, and a permutation sign — is an active frontier.

Two centuries after Gauss christened it golden, quadratic reciprocity remains what it always was: a small, exact, astonishing fact about remainders, radiating outward into nearly every corner of number theory. Five windows, one view — and the view is still expanding.
