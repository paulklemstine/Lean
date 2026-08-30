# The Tree That Cannot See Half the Primes

## A beautiful factoring idea, and the exact reason it fails

Every so often a mathematical idea is so pretty that it *deserves* to work. Here is one of them.

Take the right triangles with whole-number sides — $3,4,5$; $5,12,13$; $8,15,17$; $20,21,29$. Number theorists call the side triples *Pythagorean*, and a triple is *primitive* when the three numbers share no common factor. There are infinitely many, and they are not scattered at random. They form a perfect infinite ternary tree.

The tree was described by B. Berggren in 1934 and rediscovered several times since. Its root is $(3,4,5)$. Each node $(a,b,c)$ has exactly three children, produced by three fixed integer matrices:

$$
B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},\quad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},\quad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}.
$$

Apply $B_1$ to $(3,4,5)$ and you get $(5,12,13)$; apply $B_2$ and you get $(21,20,29)$; apply $B_3$ and you get $(15,8,17)$. Every primitive triple appears exactly once, at exactly one address in the tree. Nothing is missed, nothing is repeated. It is one of the tidiest infinite catalogues in elementary number theory.

Now here is the temptation. Suppose you want to factor a large number $N = pq$, the kind that guards a bank connection. The matrices above have tiny entries — every one of them is $\pm 1$, $\pm 2$ or $3$ — so you can walk the tree *modulo $N$* using nothing but additions and subtractions. No multiplication, no division, no modular exponentiation. You get a fast, cheap, deterministic stream of numbers $c_1, c_2, c_3, \dots$: the hypotenuses of the tree, reduced mod $N$. At each one you compute $\gcd(c_i, N)$. If some hypotenuse happens to share a factor with $N$, the gcd hands you $p$ or $q$ and you have broken the modulus.

This is called a *dive*. It costs almost nothing per node. It is completely deterministic. And it looks, at first glance, exactly like the kind of structured random walk that made Pollard's rho method famous.

It does not work. This article explains, in precise terms, three separate reasons why — and each reason turns out to be a theorem, not an accident of implementation.

---

## Reason one: the arithmetic is right, but the accounting is wrong

Suppose, generously, that the mod-$N$ hypotenuse stream behaved like a perfect random number generator. How good would the dive be then?

Start by counting how many residues are worth hitting. A residue $x$ modulo $N$ *reveals* a factor when $\gcd(x, N)$ is a nontrivial divisor of $N$ — neither $1$ nor $N$. A short argument identifies the non-revealing residues exactly: they are $0$ together with the units. Hence the count of revealing residues below $N$ is

$$
N - 1 - \varphi(N),
$$

where $\varphi$ is Euler's totient. For a semiprime $N = pq$ with $p \ne q$, since $\varphi(pq) = (p-1)(q-1)$, this collapses to a strikingly simple number:

$$
\#\{\text{revealing residues mod } pq\} = p + q - 2.
$$

Try it: modulo $15 = 3 \cdot 5$ the revealing residues are $\{3, 5, 6, 9, 10, 12\}$ — six of them, and $3 + 5 - 2 = 6$. Exactly.

So the chance that one random residue reveals a factor is $(p+q-2)/pq$. When $p \le q$ this is very close to $1/p$: the *smaller* prime dominates. To have a decent chance of success you need about $p$ tries.

That is trial division's cost. Not $\sqrt{p}$ — the square root that makes Pollard's rho a real algorithm — but $p$ itself.

This is provable, not merely heuristic. Model a dive as follows: it visits $t$ nodes, receiving $t$ residues mod $N$, and it gcd-tests those in some chosen subset $S$ of positions. Then, out of the $N^t$ possible value streams, the number on which the dive succeeds is *exactly*

$$
\left(N^{|S|} - (N - r)^{|S|}\right) \cdot N^{\,t - |S|}, \qquad r = p + q - 2.
$$

From this closed form a convexity estimate gives a clean threshold theorem:

> **Trial-division scaling.** For $N = pq$ with $p \le q$ prime, any inspection schedule with $4|S| < p$ succeeds on strictly fewer than half of all value streams.

Contrapositively: *constant success probability costs $\Omega(p)$ inspected nodes.* If you write the running time as $p_{\min}^{\alpha}$, then $\alpha = 1$. No walk in this model can have $\alpha = 1/2$.

The experimental measurement, over two hundred independent dives on random semiprimes, came back at

$$
\alpha = 1.007 \pm 0.088,
$$

with the node count at first success sitting at about $0.89\,p_{\min}$. Theory and measurement agree to the third decimal place. The tree walk is trial division wearing a very elegant costume — and at matched compute it runs about eleven times *slower* than plain trial division, because each node costs several matrix additions where trial division costs one remainder.

---

## Reason two: no amount of cleverness helps

Faced with a slow search, the natural instinct is to steer it. Prefer nodes whose residues fall in promising classes. Reorder the traversal breadth-first instead of depth-first. Prioritise branches by some learned score. Surely *guidance* buys something?

Look again at the exact count above. The number of successful streams depends on the schedule $S$ **only through $|S|$**. Two schedules that inspect the same number of nodes succeed on precisely the same number of streams — not approximately, not on average, but as an identity between integers:

> **The guidance null.** If $|S| = |T|$ then the dive with schedule $S$ and the dive with schedule $T$ succeed on exactly the same number of value streams.

There is no room here for a heuristic to live. Any ordering rule, any priority queue, any residue-class preference, any traversal shape: at a fixed node budget they are all the identical algorithm, statistically speaking. This is the sharpest possible form of a *null result*.

And it explains something that had been badly misleading. Early measurements of guided dives reported improvements at $z$-scores of $12$ to $24$ — apparently overwhelming evidence. The theorem says those improvements cannot exist. The resolution is that the control was wrong: simply randomising the *order* in which nodes were visited, with no guidance at all, produced its own spurious $z = 21.8$. The signal was an artefact of traversal shape, not of the heuristic. Once the comparison is properly paired, every honest $z$-score falls below $2$ in absolute value. The pre-registered null was confirmed.

---

## Reason three: the tree is structurally blind

The first two reasons apply to *any* value-testing walk. The third is special to this tree, and it is the sharpest of the three.

Here is the fact. **Every prime that divides the hypotenuse of a primitive Pythagorean triple is congruent to $1$ modulo $4$.**

Check it on the small cases: $5$, $13$, $17$, $29$, $25 = 5^2$, $37$, $41$, $53$, $61$, $65 = 5 \cdot 13$, $73$, $85 = 5 \cdot 17$. Every prime factor in sight is $5, 13, 17, 29, 37, 41, 53, 61, 73$ — all $1$ mod $4$. Never $3$, never $7$, never $11$, never $19$.

The proof is three lines of the right kind. Let $a^2 + b^2 = c^2$ be primitive and let $p$ be a prime dividing $c$.

1. $p$ is odd. If $c$ were even, then examining $a^2 + b^2 = c^2$ modulo $4$ forces $a$ and $b$ both even, contradicting primitivity.
2. $p$ divides neither leg. If $p \mid a$, then from $b^2 = c^2 - a^2$ we get $p \mid b^2$, hence $p \mid b$ — and then $p$ is a common divisor of $a$, $b$, $c$, again contradicting primitivity.
3. Therefore, modulo $p$, we have $a^2 \equiv -b^2$ with $b$ invertible, so $(ab^{-1})^2 \equiv -1$. Thus $-1$ is a square modulo $p$ — and by a classical criterion of Euler that happens precisely when $p \equiv 1 \pmod 4$.

The last step is the whole story. The quadratic form $x^2 + y^2$ is *anisotropic* modulo any prime $p \equiv 3 \pmod 4$: over such a prime, the only way to have $x^2 + y^2 \equiv 0$ is $x \equiv y \equiv 0$. The Pythagorean cone simply has no nonzero points there. So a prime $p \equiv 3 \pmod 4$ can never divide the hypotenuse of a primitive triple.

Now transport that to the dive. Every node of the Berggren tree is a primitive triple. So:

> **Blum-integer immunity.** Let $N = pq$ with $p \equiv q \equiv 3 \pmod 4$. Then for every node of the tree, at every depth, $\gcd(c, N) = 1$.

Those $N$ are the *Blum integers* — exactly the moduli used in Rabin encryption and in the Blum–Blum–Shub generator, and a positive-density share of RSA-like moduli. On them, the hypotenuse dive conveys literally zero information about the factorisation. You may traverse two hundred thousand nodes, two hundred million, or the entire infinite tree; the gcd is $1$ every single time. It is not that the search is slow. There is nothing there to find.

Even one bad prime is enough to cripple it. If merely $p \equiv 3 \pmod 4$, the dive's gcd is always $1$ or $q$: the factor $p$ is structurally unreachable. Counting the residue classes, the dive can reach only $p - 1$ of the $p + q - 2$ revealing classes. Projecting the tree modulo $N$ *loses* hit density; it does not create it. The measured deficit — the orbit under-samples factor-revealing residues by roughly a factor of five compared with random Pythagorean points — has this congruence law as a large part of its cause.

And the blindness is genuinely a property of the *hypotenuse*, not of the search. On $N = 65 = 5 \cdot 13$, where both primes are $1$ mod $4$, the dive splits $N$ at depth two: the node reached by $B_3$ then $B_2$ has hypotenuse $85$, and $\gcd(85, 65) = 5$. The legs, meanwhile, are unconstrained — the child $(5,12,13)$ of the root already has a leg divisible by $3$ — so a leg-based dive escapes the congruence obstruction, though it remains trial-division-class by the counting theorems above.

---

## Why rho wins, unconditionally

The last piece is a direct comparison. Pollard's rho does not test *values*; it tests *pairs*. And a pair test on this same stream is provably better.

If two of your residues $x < y$ below $N = pq$ satisfy $x \equiv y \pmod p$, then $\gcd(y - x, N)$ is exactly $p$ — not merely nontrivial, but the prime itself. So the relevant question is not "did I hit a revealing residue?" but "did I hit a collision modulo $p$?" — and collisions are governed by the birthday paradox.

Counting the collision-free streams (they inject into the pairs consisting of an injection $\{1,\dots,t\} \hookrightarrow \mathbb{Z}/p$ together with a free choice of quotient) and applying a falling-factorial estimate yields:

> **Birthday success bound.** Let $N = pq$ with $p, q$ prime, $p \ge 5$, and take a budget of $t = 2m$ nodes with $p \le m^2$ and $t^2 \le q$. Then the pair test succeeds on at least $30\%$ of all value streams.

Put the two theorems side by side at the *same* node budget $t \approx 2\sqrt{p}$:

- every value-testing schedule succeeds on **fewer than half** the streams (indeed, its success is negligible, since $4t \ll p$);
- the pair test succeeds on **at least three tenths** of them.

For a concrete instance, take $N = 101 \cdot 487 = 49{,}187$ and a budget of $22$ nodes. Every gcd-dive schedule whatsoever falls under one half; the pair test clears thirty percent. The exponents are $p$ versus $\sqrt{p}$, and that gap only widens.

---

## What the failure teaches

It is worth being clear about what has been established. The Berggren tree really is collision-free as a traversal: two hundred thousand nodes, on every modulus tested, with no repeated state. It really is multiplication-free. Its orbit really is confined to a couple of residue classes — about $99.75\%$ of it lives in two histogram classes. Everything attractive about the proposal is true.

And none of it helps, for reasons that compose into a complete account: the hit density is $1/p_{\min}$, so the scaling exponent is $1$; the success count is a function of the budget alone, so guidance is impossible; and the hypotenuse carries a congruence law that erases half the primes outright.

The third reason is the one with a future. The $1 \bmod 4$ law is not really about Pythagoras. It is the statement that a particular binary quadratic form is anisotropic at half the primes. That suggests a general principle: let a finitely generated group preserve an integral ternary quadratic form of signature $(2,1)$, acting on an orbit of primitive points, and let $\lambda$ be a nonzero linear functional. If the form restricted to $\ker \lambda$ is definite, then the primes dividing $\lambda$ on the orbit should be confined to a set of density at most $1/2$, cut out by splitting conditions in a fixed field. The Pythagorean case is $Q = x^2 + y^2 - z^2$ with $\lambda = z$.

If that principle holds in general, then *every* "factor by walking a hyperbolic orbit tree" proposal inherits an unconditional blind spot on half of all primes, and a whole genre of attractive ideas is closed with a single theorem. If it fails, the counterexample is a functional whose divisor primes are unrestricted — which would be the first genuinely promising candidate for a tree dive that is not null.

Either way, the elegance of the Berggren tree survives intact. It just does not know anything about your secret keys, and now we can say exactly why.
