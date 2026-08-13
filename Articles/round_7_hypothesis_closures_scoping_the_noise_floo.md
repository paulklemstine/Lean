# The Shape of a Secret: Why Four Beautiful Ideas Fail to Factor a Number

Take two large prime numbers, multiply them together, and publish the answer. That single act — trivial to perform, apparently impossible to undo — is the hinge on which a great deal of modern cryptography turns. The number $N = pq$ is public; the primes $p$ and $q$ are the secret. Everyone can check that $N$ is what it claims to be. Almost nobody can pull it apart.

What makes this asymmetry so strange is that $N$ is *not* hiding its factors in any obvious way. They are right there, in a hundred different disguises. The number $N$ knows how many units it has. It knows which residues are squares. It knows the shape of its own multiplication table. Every one of those facts is, in principle, entangled with $p$ and $q$. So why can't we just *ask*?

This article is about four serious attempts to ask — four different mathematical objects attached to $N$, each of which genuinely does contain the factorization, and each of which, on close inspection, refuses to hand it over. The failures are not embarrassments. They are theorems. And together they trace out a surprisingly crisp boundary: a precise description of *why* the information is present but unreachable.

---

## The setup: a number and its shadow

Fix two distinct primes $p$ and $q$ and set $N = pq$. The world we work in is the ring of integers modulo $N$, written $\mathbb{Z}/N\mathbb{Z}$: the numbers $0, 1, \dots, N-1$ with addition and multiplication wrapped around at $N$.

By the Chinese Remainder Theorem this ring is secretly a *pair* of rings glued together:
$$\mathbb{Z}/N\mathbb{Z} \;\cong\; \mathbb{Z}/p\mathbb{Z} \times \mathbb{Z}/q\mathbb{Z}.$$
Every residue $a$ mod $N$ is really a pair — its shadow mod $p$ and its shadow mod $q$ — and every arithmetic operation acts on the two shadows independently. Somebody who knows $p$ and $q$ can see both shadows. Somebody who knows only $N$ sees only the glued object, never the seam.

Almost everything below is a story about trying to find the seam.

---

## Attempt 1: Ask the squares

Here is a very natural probe. For a prime $p$ and a number $a$ not divisible by $p$, the *Legendre symbol* $(a \mid p)$ is $+1$ if $a$ is a perfect square modulo $p$ and $-1$ if it is not. Exactly half the nonzero residues mod $p$ are squares, so this symbol is a perfectly balanced coin — but a coin whose flips are determined by arithmetic, not chance.

Now, for our composite $N = pq$, each unit $a$ has *two* Legendre symbols, one for each shadow: $(a \mid p)$ and $(a \mid q)$. Individually these are pure gold — knowing $(a \mid p)$ for a few $a$'s is knowing something genuinely about $p$. But we can't compute them, because computing them requires knowing $p$.

What we *can* compute from $N$ alone is their product, the Jacobi symbol $J(a \mid N) = (a\mid p)(a \mid q)$. That is a classical, fast computation — a cousin of the Euclidean algorithm.

So here is the tempting move. Consider the set of residues where the two hidden symbols *agree*:
$$A(N) \;=\; \{\, a \in (\mathbb{Z}/N\mathbb{Z})^\times \;:\; (a\mid p) = (a\mid q) \,\}.$$

Why is this attractive? Because it is *symmetric in exactly the right way*. Any genuine handle on the factorization must eventually break the symmetry between $p$ and $q$ — but many natural quantities do not, and those get discarded early. The agreement set survives that first filter: it is unchanged if you swap the roles of $p$ and $q$, and unchanged under the natural conjugation symmetry of the ring. It is a bona fide invariant of the *unordered* pair $\{p, q\}$. And its definition mentions $p$ and $q$ explicitly, so surely its size should depend on them?

It does not. Here is the first theorem.

> **The Agreement Collapse.** Let $p$ be an odd prime and $q \ne p$ a prime, $N = pq$. Then the agreement set has exactly
> $$|A(N)| \;=\; \frac{\varphi(N)}{2} \;=\; \frac{(p-1)(q-1)}{2}$$
> elements, where $\varphi$ is Euler's totient function. Moreover $A(N)$ is precisely the set of $a$ with $J(a \mid N) = +1$.

The proof is a single elegant move, and it is worth seeing because it explains *why* the collapse is inevitable. Using the Chinese Remainder Theorem, choose a unit $u$ that is a non-square modulo $p$ but is congruent to $1$ modulo $q$. Such a $u$ exists for any odd $p$: pick any non-residue mod $p$, pick $1$ mod $q$, and glue. Now multiply. Since Legendre symbols are multiplicative, $(au \mid p) = -(a\mid p)$ while $(au\mid q) = (a \mid q)$. In other words, multiplying by $u$ flips one symbol and leaves the other alone — so it converts agreement into disagreement and back. Multiplication by $u$ is a bijection of the units, so it puts the agreement set into perfect one-to-one correspondence with its complement. Two equal halves. Exactly $\varphi(N)/2$.

And the second half of the theorem is even more deflating: agreement $(a\mid p) = (a\mid q)$ happens if and only if the product $(a\mid p)(a\mid q)$ equals $+1$ — because both factors are $\pm 1$. But that product *is* the Jacobi symbol, computable from $N$ without knowing anything. The set we thought was a secret window is just the level set of a public function.

This is character orthogonality doing what it always does: an aggregate built from characters that is invariant under all the available symmetries is forced to be a function of the ambient modulus alone. The count $\varphi(N)/2$ knows $\varphi(N)$ — and knowing $\varphi(N)$ is already equivalent to knowing the factorization. The window is a mirror.

---

## Attempt 2: Ask the shape

If numeric probes collapse, try a *shape*. Build a graph.

The **zero-divisor graph** of $\mathbb{Z}/N\mathbb{Z}$ has as vertices all the residues $0 < x < N$ that share a factor with $N$, with an edge between $x \ne y$ whenever $xy \equiv 0 \pmod N$. This is a purely combinatorial object — no numbers designated as "the answer", just dots and lines.

For $N = pq$ the picture is startlingly clean, and completely determined.

> **The Zero-Divisor Graph of a Semiprime.** Let $p \ne q$ be primes and $N = pq$. Then the nonzero zero-divisors split into two *wings*: the nonzero multiples of $p$ below $N$, of which there are $q - 1$, and the nonzero multiples of $q$, of which there are $p - 1$. The wings are disjoint and exhaust the vertex set, so the graph has
> $$|V| = (p-1) + (q-1) = p + q - 2$$
> vertices. Two vertices are adjacent **if and only if** they lie in *different* wings. That is, the graph is the complete bipartite graph $K_{q-1,\,p-1}$.

Each direction of the adjacency statement is a one-line argument. If $x = pa$ and $y = qb$ then $xy = pq\,ab$ is a multiple of $N$: every cross-wing pair is an edge. Conversely if $x$ and $y$ are both multiples of $p$ and $N = pq$ divides $xy$, then in particular $q$ divides $xy$, so $q$ divides one of them — but that residue would then be divisible by both $p$ and $q$, hence by $N$, hence be $0$ or at least $N$; contradiction. So there are no edges inside a wing.

The consequences are immediate and, for a would-be factorer, tantalizing. Every vertex in the $p$-wing has exactly $p - 1$ neighbours (the whole $q$-wing) and every vertex in the $q$-wing has exactly $q - 1$. So:

> **Factor Recovery from Degrees.** For any vertex $x$ of the graph, $\deg(x) + 1$ is a prime factor of $N$.

You do not need the whole graph. You need one vertex and its degree. The factorization is written on the face of every single node.

Here is where the trap closes. Suppose you have a vertex $x$. By definition a vertex is a residue $0 < x < N$ that is *not* coprime to $N$. So $\gcd(x, N)$ is a nontrivial divisor: it is $p$ or $q$.

> **The Circularity.** Exhibiting a single vertex of the zero-divisor graph already exhibits a factor of $N$, via one greatest-common-divisor computation.

The graph does determine $\{p,q\}$ — that is a theorem, not a heuristic. But the vertex set *is* the divisor structure. To draw the graph you must first find its dots, and finding a dot is already winning. In a haystack of $N$ residues there are only $p + q - 2$ dots; finding one by search is trial division wearing a new hat.

This is the sharpest and most instructive of the four closures, because it shows that the failure is not a failure of information. It is a failure of *access*. The structural witness exists; it is simply not cheaper than the thing it witnesses.

There is a further twist. What does the graph actually tell you, as a number? Its vertex count is $p + q - 2$. Add two and you have the *trace* $s = p+q$; together with the *norm* $N = pq$ you get the quadratic
$$X^2 - sX + N = 0,$$
whose two roots are exactly $p$ and $q$. So the combinatorial object, for all its apparent novelty, delivers precisely the same numeric datum — the sum of the primes — that every other successful line of attack delivers. The shape collapses onto the number.

---

## Attempt 3: Ask a random residue — and then ask cleverly

How likely is a blind guess to work? Pick $a$ uniformly at random from $1, \dots, N-1$ and compute $\gcd(a, N)$. You succeed exactly when $a$ is a vertex of the graph above, so your success probability is
$$\frac{p+q-2}{N}.$$

> **The Atomic Uniform Bound.** If $p \le q$, a single uniform query succeeds with probability at most $2/p$.

And how small can that be? By the arithmetic–geometric mean inequality, $(p+q)^2 \ge 4pq = 4N$, with equality only when $p = q$. So the success probability is roughly $2/\sqrt{N}$ at best, when the two primes are balanced — which is exactly how cryptographic moduli are chosen. This is the **noise floor**: a random shot in the dark hits with probability about $N^{-1/2}$, and no amount of cleverness in *choosing the distribution* fixes it, because the target set has only $p + q - 2$ members out of $N$.

Now here is the refinement that this round produced, and it matters.

Consider Pollard's rho walk: start at some $x_0$ and iterate $x \mapsto x^2 + 1 \pmod N$. Measure the *density* of factor-bearing information in the resulting sample set. It is enormously higher than $N^{-1/2}$ — in experiments, essentially $1$. Does that break the noise floor?

No — and the reason is precise. The walk's samples are not independent draws; they are *correlated*, and the correlation is exactly the point.

> **Reduction-Compatibility.** The map $x \mapsto x^2+1$ commutes with reduction modulo any $m$: if $a \equiv b \pmod m$ then $a^2+1 \equiv b^2+1 \pmod m$, and hence all iterates stay congruent. So the walk modulo $N$ *covers* a walk modulo $p$.

> **Guaranteed Collision.** The walk modulo $p$ lives in a set of only $p$ states, so among the first $p+1$ iterates two must coincide modulo $p$. That is pigeonhole, not probability: there exist $i < j \le p$ with $p \mid x_j - x_i$.

> **Extraction.** If a prime $p$ divides $d$ and $q$ does not, then $\gcd(d, pq) = p$ exactly. So any collision mod $p$ that is not simultaneously a collision mod $q$ hands over the factor.

Those three statements, stitched together, are the correctness core of Pollard's rho method — with no randomness hypothesis at all. The density really is high. So why is factoring still hard?

Because of the *aggregation price*. A collision is a statement about a **pair** of samples. To find the pair you must compare them, and comparing all pairs among $T$ samples costs $\binom{T}{2}$ operations. With the pigeonhole guarantee $T = p+1$, that is
$$\binom{p+1}{2} \;\ge\; p,$$
already more than the $p$ trial divisions you were trying to avoid. The unconditional density gain is real and it is paid for in full at the checkout. (The famous $\sqrt{p}$ running time of rho comes not from this unconditional argument but from a birthday-paradox heuristic plus Floyd's cycle-finding trick that avoids explicit pairwise comparison — a known method, not a new escape.)

The lesson is a scoping lesson, and it is the intellectual centre of this whole round: **the noise floor bounds atomic, uniform primitives — a single query drawn from a distribution close to uniform — and it is not a density theorem about correlated or derived samples.** Correlated samples can be dense. They just cost more to read.

---

## Attempt 4: Ask the digits

The last attempt is the most geometric. Write $N$, $p$, and $q$ in base $b$. Multiplication of $p$ and $q$ is a *convolution* of their digit sequences, plus carries. If we introduce a variable $w_{ij} = p_i q_j$ for each pair of digit positions, the digit equations become **linear** in the $w_{ij}$ — and linear equations over the integers define a lattice, where the celebrated LLL algorithm finds short vectors fast. Is the factorization the short vector?

Consider the smallest nontrivial case: two digits each. Write the digit functional
$$\Phi_b(w) \;=\; \sum_{i,j} w_{ij}\, b^{\,i+j},$$
and for digit vectors $u = (u_0,u_1)$, $v=(v_0,v_1)$ write $\langle u \rangle_b = u_0 + u_1 b$ for the number they encode.

> **Faithfulness.** For the rank-one matrix $w = u \otimes v$ (that is, $w_{ij} = u_i v_j$), we have $\Phi_b(u\otimes v) = \langle u\rangle_b \cdot \langle v\rangle_b$. So genuine factorizations of $N$ are exactly the *rank-one* solutions of $\Phi_b(w) = N$.

> **The Discarded Constraint.** A $2\times 2$ matrix is rank one exactly when its determinant vanishes. The determinant is quadratic; the relaxation is linear; so the relaxation cannot see it.

That is not yet fatal — perhaps rank-one solutions happen to be the *shortest* ones. They do not, and here is the reason, which is a single explicit matrix.

> **The Carry Commutator.** Let $C = \begin{pmatrix} 0 & 1 \\ -1 & 0\end{pmatrix}$. Then $\Phi_b(C) = b^{0+1} - b^{1+0} = 0$ for **every** base $b$. Its squared Frobenius norm is $2$ — a constant, independent of $N$.

The matrix $C$ is invisible to the digit functional because the coefficient $b^{i+j}$ depends only on $i+j$, so the linearization cannot distinguish position $(0,1)$ from position $(1,0)$. That degeneracy is precisely the carry information the relaxation threw away. And it is devastating:

> **Non-Isolation.** For every factorization target $u \otimes v$ there is a matrix $w$ with the *same* digit value $\Phi_b(w) = N$, with **nonzero determinant** — hence not a factorization — at squared distance at most $8$ from the target, no matter how large $N$ is.

The construction is a two-line case split: perturb by $C$ or by $2C$. The determinant of $u\otimes v + cC$ is $c(u_0v_1 - u_1v_0) + c^2$, which is a nonzero number for $c = 1$ or for $c = 2$ (both fail only if a single integer is simultaneously $-1$ and $-2$). The perturbation has squared norm $2c^2 \le 8$.

Meanwhile the target itself has squared norm $(u_0^2+u_1^2)(v_0^2+v_1^2)$, which grows with the digits of $p$ and $q$. So the true answer sits inside an $O(1)$-radius cloud of impostors, in a lattice whose typical short vectors are of comparable length — exactly the "target at the Gaussian heuristic" phenomenon the experiments measured. Lattice reduction dutifully returns *a* short vector. There is no reason on earth for it to be the right one.

---

## What the four failures add up to

Four probes: an arithmetic aggregate, a combinatorial shape, a dynamical sampler, a geometric relaxation. Each genuinely contains the factorization. Each is closed, and each is closed for a *different* reason:

1. **The aggregate collapses.** Symmetry is a double-edged sword: an invariant symmetric enough to be well-defined without knowing $p$ and $q$ is symmetric enough to be computable without them. $|A(N)| = \varphi(N)/2$; the set is the Jacobi level set.
2. **The shape is circular.** The zero-divisor graph is exactly $K_{q-1,p-1}$ and its degrees give the factors — but its vertices *are* the factors' multiples, so drawing it presupposes the answer.
3. **The sampler is dense but expensive.** Correlated samples beat the noise floor honestly; the floor was only ever a bound on atomic uniform queries. What they cannot beat is the quadratic cost of the pairwise aggregation needed to cash the density in.
4. **The relaxation is degenerate.** Linearizing the digits creates an explicit constant-norm kernel vector, so the target is never isolated among short vectors.

There is a pleasing final image. Take logarithms of the divisor equation $xy = N$: it becomes $X + Y = \log N$, a straight line. In the min-plus (tropical) world, where "addition" is taking the minimum and "multiplication" is ordinary addition, that line has a corner sitting exactly at $\tfrac{1}{2}\log N$ — the location of $\sqrt N$. Every factor pair of $N$ straddles that corner: if $p \le q$ then $p^2 \le N \le q^2$. The corner is the noise floor made geometric. Every one of the four attempts above was, in its own language, an attempt to walk around the corner rather than through it. None of them made it.

That is not a proof that factoring is hard. Nobody has one, and nobody is close. But it is something valuable and rarer than it sounds: a set of theorems that says exactly *which* good ideas do not work, and exactly *why*. In a field where the space of plausible-sounding attacks is enormous, a precisely-scoped negative result is a map. It tells the next explorer where the cliffs are — and, by elimination, where the unexplored ground still lies.
