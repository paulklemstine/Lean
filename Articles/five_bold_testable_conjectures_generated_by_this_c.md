# The Fractions That Refuse to Talk

## What the denominators of an elliptic curve know — and what they will never tell you

### A curve, a point, and a runaway fraction

Fix a whole number $N$ and look at the equation

$$y^2 = x^3 + N.$$

This is a *Mordell curve*, named after Louis Mordell, who in the 1920s proved one of the great structural theorems about such equations: their rational solutions form a finitely generated group. Concretely, the curve carries an addition law. Given two rational points on it, draw the line through them, find the third intersection point with the cubic, and reflect it across the $x$-axis. The result is again a rational point. Add a point to itself — using the tangent line instead of a secant — and you get its double.

Take $N = 55$. The point $P = (9, 28)$ sits on the curve, since $28^2 = 784 = 729 + 55 = 9^3 + 55$. Both coordinates are integers, as clean as one could hope. Now double it. The tangent-line recipe gives

$$2P = \left(\tfrac{2601}{3136},\ \tfrac{-73727}{175616}\right).$$

The integrality is gone at the first step. Double again and it gets worse:

$$4P = \left(\tfrac{1309141}{175616},\ \dots\right)\ \text{doubled} \ \Longrightarrow\ x(4P) = \frac{-35249882584054239}{21498536380459264}.$$

That denominator is not random noise. Factor it:

$$21498536380459264 = 2^8 \cdot 7^2 \cdot 827^2 \cdot 1583^2.$$

Three odd primes appear, each squared: $7$, $827$, $1583$. Where did $827$ come from? Nothing in the input — not $55$, not $9$, not $28$ — has $827$ anywhere near it. And yet iterating a completely deterministic geometric construction, twice, conjured it into existence.

This is the phenomenon this article is about. **Doubling and redoubling a point on an elliptic curve is a prime-manufacturing machine.** Understanding exactly which primes it manufactures, and how often, is a question that sits at the crossroads of elliptic curves, quadratic reciprocity, and — because manufacturing primes sounds suspiciously useful — cryptography.

### Denominators are where points fall off the edge of the world

The first thing to understand is *why* denominators encode primes at all.

Fix a prime $\ell$. Reduce the whole curve modulo $\ell$: the equation $y^2 = x^3 + N$ makes perfect sense over the finite field with $\ell$ elements, and (as long as $\ell$ does not divide $6N$) it defines a perfectly good elliptic curve there, with its own finite group of points. Reduction is a group homomorphism: the mod-$\ell$ reduction of a sum is the sum of the reductions.

A rational point whose coordinates have $\ell$ in the denominator has nowhere to land in the finite world — except at the group's identity element, the "point at infinity". So:

> **A prime $\ell$ divides the denominator of $x(nP)$ precisely when the reduction of $P$ modulo $\ell$ is a point of order dividing $n$ in the mod-$\ell$ group.**

Denominator primes are exactly the primes at which the point $P$, viewed modulo $\ell$, happens to be $n$-torsion. The fraction blows up exactly where the arithmetic collapses.

That reformulation makes the question finite and combinatorial. Torsion of order dividing $n$ is cut out by a classical family of polynomials, the **division polynomials** $\psi_n$. For the Mordell family they are strikingly simple:

- $\psi_2 = 2y$, whose square is $4(x^3+N)$;
- $\psi_3 = 3x^4 + 12Nx = 3x(x^3 + 4N)$;
- $\psi_4 = 4y\,(x^6 + 20Nx^3 - 8N^2)$.

So the question "which primes appear in the denominator at step $n$?" becomes "which primes divide $\psi_n$ evaluated at our point?" — a question about polynomial congruences, entirely elementary to state.

### The catch: cancellation

There is one serious obstruction to that clean picture. The $x$-coordinate of $nP$ is a ratio $\varphi_n/\psi_n^2$ of two polynomials in $x$. A prime dividing $\psi_n^2$ shows up in the denominator only if it *does not also* divide the numerator $\varphi_n$ — otherwise the fraction cancels and the prime silently disappears.

So one must prove a **non-cancellation theorem**: on the locus where $\psi_n$ vanishes, the numerator $\varphi_n$ never does. And there is a beautiful pattern in how this works out. At the doubling layer, the numerator is $x^4 - 8Nx$, and on the locus $x^3 \equiv -N$ it collapses to $-9Nx$. At the tripling layer, the two branches of $\psi_3 = 0$ give numerator values $64N^3$ and $-1728N^3$. And the fourth layer — computed here for the first time — gives

$$\varphi_4 \equiv -3^8 N^5 x \quad\text{on the branch } x^3 \equiv -N, \qquad \varphi_4 \equiv -2^6 3^2\, N\,(x^4-8Nx)(x^3+N)^3 \quad\text{on the new branch.}$$

Look at the constants: $9 = 3^2$, $64 = 2^6$, $1728 = 2^6 3^3$, $3^8 = 6561$, $576 = 2^6 3^2$. Every single exceptional constant is built out of the primes $2$ and $3$ alone. This is not a coincidence: $2$ and $3$ are precisely the primes dividing the discriminant $-432N^2$ of the Mordell family, the primes where the curve's geometry degenerates. Away from them, nothing cancels. This is why every theorem in this story carries the hypothesis $\ell \ge 5$ — and why, once you impose it, the criterion becomes exact.

### The fourth layer, and the identity that makes it work

The engine of the quadrupling layer is a polynomial identity that holds in any commutative ring:

$$\boxed{\ (x^4 - 8Nx)^3 + 64N\,(x^3+N)^3 = (x^6 + 20Nx^3 - 8N^2)^2.\ }$$

Read it slowly. The $x$-coordinate of $2P$ is $X = (x^4 - 8Nx)/\bigl(4(x^3+N)\bigr)$. If you want to double *again*, you need to know $X^3 + N$ — the square of the $y$-coordinate of $2P$. Divide the identity by $64(x^3+N)^3$ and that is exactly what you get:

$$X^3 + N = \frac{\bigl(x^6 + 20Nx^3 - 8N^2\bigr)^2}{64\,(x^3+N)^3}.$$

The numerator is a perfect square. That is the whole reason the fourth division polynomial of a Mordell curve factors as $4y$ times a sextic: the sextic $S(x) = x^6 + 20Nx^3 - 8N^2$ *is* the square root, handed to us by the identity.

From there everything follows mechanically. Doubling twice gives the explicit quadrupling formula

$$x(4P) = \frac{(x^4-8Nx)\bigl((x^4-8Nx)^3 - 512N(x^3+N)^3\bigr)}{16\,(x^3+N)\,S(x)^2},$$

and combined with non-cancellation one gets the clean statement:

> **Layer-4 criterion.** For an integral point $P = (x,y)$ on $y^2 = x^3+N$ that is neither $2$- nor $4$-torsion, and any prime $\ell \ge 5$ not dividing $N$:
> $$\ell \mid \text{denominator of } x(4P) \iff \ell \mid (x^3+N)\bigl(x^6+20Nx^3-8N^2\bigr).$$

For $N = 55$, $x = 9$: the right-hand quantity is $2^4 \cdot 7^2 \cdot 827 \cdot 1583$. There are our three primes, predicted from a single polynomial evaluation with no elliptic-curve arithmetic at all.

### Counting: where the pattern breaks

Now for the surprise.

Fix a prime $\ell \ge 5$ and ask a purely statistical question: over all possible curves in the family — that is, over all $\ell$ residue classes of $N$ modulo $\ell$ — how many pairs (class of $N$, class of $x$) are *denominator-producing* at a given layer? Call this the **layer total**.

The earlier layers gave beautifully clean answers:

- **Layer 2** (criterion $x^3 + N \equiv 0$): total exactly $\ell$. Reason: for each $x$ there is exactly one $N$ making the congruence hold, namely $N \equiv -x^3$.
- **Layer 3** (criterion $3x(x^3+4N) \equiv 0$): total exactly $2\ell - 1$. Two factors, each contributing $\ell$, overlapping in one point.

Both criteria are of *Kummer type*: solve for $N$ and you get one answer. Each irreducible factor of the division polynomial contributes exactly $\ell$. The natural extrapolation — which had been advanced as a precise conjecture — is that the layer-$n$ total should always be

$$(\text{number of irreducible factors of } \psi_n)\cdot \ell + O(1).$$

At layer 4 the locus is $(x^3+N)\cdot S(x)$ with $S$ irreducible: two factors, so the prediction is $2\ell + O(1)$.

**The prediction is false.** The layer-4 total is

$$\sum_{N \bmod \ell} \#\{x \bmod \ell : \ell \mid \Psi_4\} = \begin{cases} 3\ell - 2 & \text{if } 3 \text{ is a square modulo } \ell,\\[2pt] \ell & \text{if } 3 \text{ is not a square modulo } \ell.\end{cases}$$

Both regimes are theorems, and both occur infinitely often. Concretely, the totals at $\ell = 7, 13, 19$ are $7$, $37$, $19$ — slopes $1$, roughly $3$, and $1$. No single slope $k$ with a bounded error can accommodate that; the conjecture is dead.

Why does it fail? Because the sextic $S$ is not of Kummer type. Fix $x = t \ne 0$ and ask how many $N$ make $S$ vanish. That is a *quadratic* condition on $N$, not a linear one:

$$t^6 + 20Nt^3 - 8N^2 = 0 \iff (4N - 5t^3)^2 = 27\,t^6.$$

Completing the square turns the question into: **is $27$ a square modulo $\ell$?** Since $27 = 3^3$, this is the same as asking whether $3$ is a square. If it is, every nonzero $t$ carries two values of $N$; if not, none at all. The fibres are of size $2$ or $0$ rather than always $1$, and the total inherits the dichotomy.

By quadratic reciprocity, $3$ is a square modulo $\ell$ exactly when $\ell \equiv \pm 1 \pmod{12}$. So the layer-4 count is governed by the splitting behaviour of $\ell$ in the field $\mathbb{Q}(\sqrt{3})$ — a Frobenius condition, a Chebotarev phenomenon. The "number of irreducible factors" heuristic was measuring the wrong thing: what matters is not how many factors the division polynomial has, but the *average fibre size* of each factor, and only Kummer factors have average fibre size $1$ on the nose. Amusingly, the two values $3\ell - 2$ and $\ell$ each occur half the time, so their *average* is $2\ell$ — precisely the discredited prediction. The conjecture was right about the mean and wrong about everything else.

### The residues that stay dark

There is a second, subtler question: not *how many* $(N, x)$ pairs produce denominators, but *which values of $N$* produce any at all.

At layer 2 the answer is a cubic-residue condition. The criterion $x^3 \equiv -N$ is solvable exactly when $-N$ is a cube modulo $\ell$. When $\ell \equiv 1 \pmod 3$ the cubes form only a third of the nonzero residues, so a full $2(\ell-1)/3$ of the classes of $N$ are **blind**: for those curves, $\ell$ can never appear in a doubling denominator.

Layer 3 breaks the blindness immediately, because $\psi_3 = 3x(x^3+4N)$ has the *free root* $x \equiv 0$, valid for every $N$ whatsoever. So layer 3 is active everywhere.

What about layer 4? Naively one might expect that adding a brand-new sextic factor can only help. It does not. The theorem is:

> **Layer 4 activates exactly the residues layer 2 activates.** For any prime $\ell \ge 5$, the layer-4 locus is nonempty over a class $N$ if and only if the layer-2 locus is. Blind residues stay blind.

The proof is a lovely piece of algebra. Suppose the sextic has a root $t \ne 0$ modulo $\ell$. Then, as above, $g := (4N - 5t^3)/(3t^3)$ satisfies $g^2 = 3$, and $4N = t^3(5 + 3g)$. Now use the identity in $\mathbb{Q}(\sqrt3)$:

$$\left(\frac{-1-\sqrt3}{2}\right)^{3} = -\frac{5 + 3\sqrt3}{4}.$$

So $-N = \left(\frac{-1-g}{2}\cdot t\right)^3$ — the sextic has secretly handed us a cube root of $-N$, which is precisely what layer 2 needed. The new factor contains a *hidden cube*. It can never see a class that the old factor could not.

So along the tower $n = 2, 3, 4$, activity is not monotone: layer 2 is partially blind, layer 3 is universally active, layer 4 relapses to exactly layer 2's field of vision. The tower does not simply accumulate information.

### And now, the barrier

Here is where the story acquires teeth beyond pure curiosity.

Suppose $N = pq$ is a semiprime, the kind of number whose factorization underpins RSA-style cryptography. Elliptic curves are, after all, the basis of a real factoring algorithm — Lenstra's method finds $p$ precisely by detecting the moment when a point's coordinates become non-invertible modulo $N$. Since denominator primes are so richly structured, might they leak information about $p$ and $q$?

The answer, provably, is no — at least through the first four layers:

> **Barrier theorem.** For every bound $B$ and every semiprime $N = pq$ whose prime factors both exceed $B$, there is a prime $M > N$ such that for every prime $\ell \le B$ and every integer $x$, the layer-2, layer-3 and layer-4 divisibility criteria give *identical answers* for $N$ and for $M$.

The proof is short and inevitable. All three criteria are given by polynomials with integer coefficients in $N$ — at layer 4,

$$\Psi_4(N,x) = (x^3+N)(x^6+20Nx^3-8N^2) = x^9 + 21Nx^6 + 12N^2x^3 - 8N^3.$$

Any such polynomial condition depends on $N$ only through $N \bmod \ell$. So a single congruence $M \equiv N \pmod{B!}$ synchronises *all* small primes and *all* three layers at once — and Dirichlet's theorem on primes in arithmetic progressions guarantees such a prime $M$ exists, as large as we like.

The consequence: an adversary who could read off the entire small-prime denominator profile of the curve $y^2 = x^3 + pq$, at layers $2$, $3$ and $4$, would learn literally nothing distinguishing it from the profile of $y^2 = x^3 + M$ for a *prime* $M$. Not "it would be computationally hard to extract the factorization" — the information is simply not there. The prime-manufacturing machine is exquisitely productive and completely discreet.

### What the fourth layer taught us

Three lessons, each of which survives being stated without a single formula.

**First, structure is robust.** The prediction that the exceptional constants blocking cancellation should always be built from $2$ and $3$ — the discriminant primes of the family — held up at the first layer where it could genuinely have failed, and where the relevant division polynomial factor is no longer of the simple Kummer shape. The constants that appeared, $3^8$ and $2^63^2$, are exactly of the predicted type.

**Second, counting is deeper than factoring.** The naive extrapolation from layers 2 and 3 — count the irreducible factors, multiply by $\ell$ — is refuted. The truth involves a quadratic character, and hence Frobenius elements and Chebotarev densities. The correct general conjecture is that the layer-$n$ total equals a *class function of the Frobenius at $\ell$*, times $\ell$, plus a bounded error; layer 4 is its first non-trivial instance, with class function taking the value $3$ or $1$ according to the splitting of $\ell$ in $\mathbb{Q}(\sqrt3)$.

**Third, information can be structurally absent.** The barrier is not a computational hardness assumption but a theorem: within this window, two arithmetically very different curves are indistinguishable.

There is something pleasing in the way these three fit together. A single geometric operation — draw a tangent, take the third intersection, reflect — performed four times over, produces primes out of thin air, obeys a reciprocity law nobody put in by hand, and keeps a secret it was never told to keep.

The natural next question is layer $5$: the fifth division polynomial has degree $12$ in $x$, factors that are neither Kummer nor quadratic-in-$N$, and a Frobenius class function that, if the picture is right, should be readable off the splitting of $\ell$ in a genuinely non-abelian field. That is where the story goes next.
