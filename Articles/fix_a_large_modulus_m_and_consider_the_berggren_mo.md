# The Pythagorean Tree Has a Secret, and Arithmetic Modulo $m$ Keeps It

## A tree that contains every right triangle

Start with the most famous right triangle in mathematics: legs $3$ and $4$, hypotenuse $5$. Now apply one of three simple recipes to it. Each recipe takes a triple $(a,b,c)$ of whole numbers and returns a new triple, mixing the three numbers in a fixed linear pattern:

$$B_1(a,b,c) = (a - 2b + 2c,\; 2a - b + 2c,\; 2a - 2b + 3c),$$
$$B_2(a,b,c) = (a + 2b + 2c,\; 2a + b + 2c,\; 2a + 2b + 3c),$$
$$B_3(a,b,c) = (-a + 2b + 2c,\; -2a + b + 2c,\; -2a + 2b + 3c).$$

Feed $(3,4,5)$ into each in turn and you get

$$B_1(3,4,5) = (5,12,13), \qquad B_2(3,4,5) = (21,20,29), \qquad B_3(3,4,5) = (15,8,17).$$

Every one of those is again a right triangle with whole-number sides. This is no accident. Each of the three maps preserves the quantity $a^2 + b^2 - c^2$ exactly — they are *isometries of the Lorentz form*, the same quadratic form that governs special relativity, here restricted to integer points. If you start on the surface $a^2 + b^2 = c^2$, you never leave it.

Keep going. Each of the three new triples has three children of its own, each of those has three, and so on forever. What you build is an infinite, perfectly regular ternary tree. And here is the classical miracle, discovered independently by Barning and by Hall in the 1960s: **this single tree, rooted at $(3,4,5)$, contains every primitive Pythagorean triple exactly once.** No repeats, no omissions. The entire infinitude of coprime right triangles is enumerated by the words in a free monoid on three letters.

That last phrase is the one to hold on to. A *word* is just a finite string of moves, like $B_2 B_1 B_1 B_3$. Reading it right to left and applying the moves to $(3,4,5)$ lands you at a specific triple. Distinct words land at distinct triples. So a Pythagorean triple is, in a precise sense, a *message* written in a three-letter alphabet.

## The message is written in plain sight

Which raises the natural question: given a triple, can you read the message back?

You can. And the way you do it is startlingly cheap. Look at a triple $(a,b,c)$ that you know is a child of something in the tree. Compare $5a$ to $3c$ and to $4c$. That is all:

> **The Move Classifier.** If $5a < 3c$, the last move was $B_1$. Otherwise, if $5a < 4c$, the last move was $B_2$. Otherwise, it was $B_3$.

Check it on the three children of the root. For $(5,12,13)$: $5a = 25$ and $3c = 39$, so $25 < 39$ and the verdict is $B_1$ — correct. For $(21,20,29)$: $5a = 105$, $3c = 87$, so the first test fails; $4c = 116$, and $105 < 116$, so the verdict is $B_2$ — correct. For $(15,8,17)$: $5a = 75$, and both $3c = 51$ and $4c = 68$ are smaller, so the verdict is $B_3$ — correct.

This is not a heuristic that happens to work on small examples. It is exact, always, everywhere in the tree:

> **Theorem (Exactness of the classifier).** Let $(a,b,c)$ be any triple in the tree with all three entries positive, and let $i \in \{1,2,3\}$. Then the classifier applied to $B_i(a,b,c)$ returns exactly $i$.

Why should two crude linear inequalities capture something so structural? The answer lies in Euclid's ancient parametrisation. Every primitive triple can be written as $a = m^2 - n^2$, $b = 2mn$, $c = m^2 + n^2$ for coprime integers $m > n > 0$ of opposite parity. In these coordinates the three Berggren moves have a beautifully simple description on the *pair* $(m,n)$, and the three branches are distinguished by exactly where the ratio $m/n$ sits relative to the thresholds $2$ and $3$. Transporting the tests $m < 2n$, $2n < m < 3n$, $m > 3n$ back to the triple coordinates — using the identity $m/n = \sqrt{(c+a)/(c-a)}$ — turns them into $5a < 3c$, $3c \le 5a < 4c$, and $5a \ge 4c$. The square roots cancel. The transcendental-looking test becomes two integer comparisons.

Once you have the classifier, decoding is a matter of peeling. Each move has an explicit integer inverse (obtained by conjugating the transpose with the diagonal matrix $\operatorname{diag}(1,1,-1)$, a reflection of the Lorentz symmetry). So: classify the last move, undo it, repeat. After $k$ steps you have the whole word, and the triple has shrunk back to $(3,4,5)$.

> **Theorem (Seed recovery over the integers).** There is an algorithm that, given the single triple $B_{i_k}\cdots B_{i_1}(3,4,5)$, outputs the word $i_1 i_2 \cdots i_k$ in $O(k)$ arithmetic operations.

Two comparisons and one matrix–vector product per letter. There are $3^k$ possible words of length $k$, and the algorithm distinguishes among all of them in linear time. It never guesses.

The reason it can't fail is a hidden monotonicity. Every move strictly *increases* the hypotenuse — in fact by a factor between $5$ and $7$. The tree is graded by size, with no collisions between levels, and the classifier reads off which of three well-separated angular sectors the child fell into.

## Now break the ruler

Here is where the story turns. Suppose the observer cannot see $(a,b,c)$ itself. Suppose they only see the three numbers *reduced modulo $m$* — the remainders after dividing by some fixed integer $m$. This is exactly the situation of every real computer: registers are finite, arithmetic wraps around.

At first this looks harmless. All the algebra survives reduction. The moves still act on triples of residues; each is still invertible (the inverse formulas reduce too); the Lorentz form $a^2 + b^2 - c^2$ is still preserved modulo $m$; running the whole dynamical system inside the finite world $(\mathbb{Z}/m)^3$ gives exactly the reduction of what you'd get over the integers. Nothing is lost algebraically.

And the classifier still works — for a while.

> **Theorem (Modular soundness).** Suppose the true hypotenuse $c$ of the observed child satisfies $c < m$. Then lifting the residues to their representatives in $[0,m)$ recovers the true triple, and the classifier returns the true last move.

So as long as nothing has wrapped around, the modular observer is exactly as powerful as the integer observer. The classifier is sound. That hypothesis is not decorative, though, and it is sharp. Take $m = 7$. The triple $(5,12,13) = B_1(3,4,5)$ reduces to $(5,5,6)$. Run the classifier: $5a = 25$, $3c = 18$, $4c = 24$. Both tests fail, and the verdict is $B_3$. Wrong. One wrap-around and the answer flips.

## Counting is destiny

The failure at $m=7$ is a single data point. What happens systematically? The answer is a clean collision between two exponentials — one in the length of the message, one in the size of the window.

There are $3^k$ control words of length $k$. There are at most $m^3$ possible observations, because a state is a triple of residues modulo $m$. If $3^k > m^3$, the pigeonhole principle bites without mercy.

> **Theorem (Information-theoretic impossibility).** If $m^3 < 3^k$, then no function whatsoever of the observed modular state can return the control word. Two distinct words of length $k$ must produce the identical observation.

Note what this rules out. Not "no efficient algorithm" — *no function*. The information simply is not there. An adversary with unlimited computing power, perfect knowledge of the construction, and infinite time cannot recover the word, because two different words genuinely produce the same observation.

The quantitative version is more informative than the bare impossibility:

> **Theorem (Ambiguity bound).** For every $n$ with $m^3 \cdot n < 3^k$, there exists an observed modular state that is consistent with strictly more than $n$ distinct control words of length $k$.

Taking $n$ as large as allowed, some observation has an ambiguity set of size $\Omega(3^k/m^3)$. The modulus is a *polynomial-size* leash on the information; the message space is *exponential*. The best the adversary can do is narrow the field to $\Omega(3^k / \mathrm{poly})$ candidates and then search. That is the promised hardness.

And the bound can be sharpened. The observation is never an arbitrary residue triple — it always lies on the *null cone*, the set of $(a,b,c)$ modulo $m$ with $a^2 + b^2 = c^2$. Moreover, because each move is invertible over the integers, every triple in the tree is *primitive* (its entries share no common factor), so modulo a prime $p$ the observation is never the zero vector. How big is the null cone modulo a prime? A quadratic equation has at most two roots in a field, so once you fix $a$ and $b$ there are at most two choices of $c$ — the cone has at most $2p^2$ points, not $p^3$.

> **Theorem (Sharpened bound for prime moduli).** Modulo a prime $p$, seed recovery of length-$k$ words is impossible as soon as $2p^2 < 3^k$, and the ambiguity is $\Omega(3^k / 2p^2)$.

A whole factor of $p$ better. The adversary's world is one dimension smaller than it looks.

## The extreme case, and a discrete logarithm

The most vivid illustration of information loss is $m = 2$. Modulo $2$, all three Berggren moves are *the identity map* on $(\mathbb{Z}/2)^3$ — you can verify this by checking the eight possible states. Every control word, of every length, produces the identical observation $(1,0,1)$. The dynamics has collapsed to a point. Recovery is not merely hard; there is literally nothing to recover from.

More refined is what happens when the observer is allowed to see the *parent* as well as the child. Then the classifier becomes purely algebraic: just test which of $B_1w$, $B_2w$, $B_3w$ equals the observed child. This works precisely when the three children are pairwise distinct, and the differences are easy to compute:

$$B_1w - B_2w = (-4b, -2b, -4b), \quad B_2w - B_3w = (2a, 4a, 4a), \quad B_1w - B_3w = (2a - 4b,\, 4a - 2b,\, 4a - 4b).$$

So the branching is visible modulo $m$ exactly when $2a$, $2b$, and $2a - 4b$ are all nonzero in $\mathbb{Z}/m$. Under those three conditions the relative classifier is both sound and complete. Modulo $2$ the very first condition fails for every state — which is precisely the collapse described above.

Finally, there is a route to hardness that has nothing to do with counting. Restrict attention to the single-move words: $t$ copies of $B_2$ and nothing else. Iterating one move is the same as raising its matrix to a power, so the observed state after $t$ steps is $B_2^t$ applied to the vector $(3,4,5)$, all modulo $m$. Recovering $t$ from that state is *literally a discrete logarithm problem* for the matrix $B_2$ in $\mathrm{GL}_3(\mathbb{Z}/m)$ — the same shape of problem that underpins Diffie–Hellman key exchange.

> **Theorem (Reduction to discrete logarithm).** Any algorithm that recovers control words of length at most $k$ from modular observations yields, with a single call, an algorithm solving the discrete logarithm for $B_2$ modulo $m$ for exponents up to $k$. (Take the length of the recovered word.)

So seed recovery is at least as hard as this matrix discrete logarithm. And that problem, in turn, is not just hard but *ill-posed* past a point: the $B_2$-orbit of the root must revisit a state within $m^3$ steps, so for $k \ge m^3$ no solver can exist at all.

## The silver ratio in the machine

Why $B_2$? Because its spectrum is beautiful. Its characteristic polynomial factors as

$$\lambda^3 - 5\lambda^2 - 5\lambda + 1 = (\lambda + 1)(\lambda^2 - 6\lambda + 1),$$

and the quadratic factor has roots $3 \pm 2\sqrt{2} = (1 \pm \sqrt{2})^2$ — the *squares of the silver ratio* $1 + \sqrt{2}$. This is the matrix identity $(B_2 + I)(B_2^2 - 6B_2 + I) = 0$, which holds over the integers and therefore modulo every $m$.

The consequences are concrete. Track the $B_2$-orbit of $(3,4,5)$ and set $S_t = a_t + b_t$ (the sum of the legs) and $C_t = c_t$ (the hypotenuse). Then the pair evolves by the $2\times 2$ matrix $\begin{pmatrix} 3 & 4 \\ 2 & 3\end{pmatrix}$, and both sequences satisfy the second-order recurrence

$$x_{t+2} = 6x_{t+1} - x_t,$$

with $S_0 = 7, S_1 = 41, \ldots$ and $C_0 = 5, C_1 = 29, \ldots$. These are the NSW numbers and the Pell half-companions. Better still, they satisfy an exact conic identity for every $t$:

$$S_t^2 - 2C_t^2 = -1.$$

The $B_2$-orbit of the $(3,4,5)$ triangle *is* the ladder of solutions to the negative Pell equation $x^2 - 2y^2 = -1$. And the third eigenvalue, $-1$, is visible too: the two legs of the orbit differ by exactly $(-1)^{t+1}$ — the triangles $(3,4,5)$, $(21,20,29)$, $(119,120,169)$, $(697,696,985)$ alternate between "leg one bigger by one" and "leg two bigger by one." These are the almost-isosceles Pythagorean triangles.

Putting the pieces together: the discrete logarithm hiding inside modular seed recovery is *Pell index-finding*. For odd $m$ and exponents of matching parity, two $B_2$-powers are indistinguishable modulo $m$ if and only if their Pell pairs $(S_t, C_t)$ agree modulo $m$. Recovering the number of steps from a modular observation is the same problem as locating a term of a Pell sequence in its own residue cycle.

## Where the line falls

We now have two theorems pointing in opposite directions, and it is worth stating them side by side.

Growth: every move multiplies the hypotenuse by at most $7$, so a word of length $k$ applied to $(3,4,5)$ produces a hypotenuse of at most $5 \cdot 7^k$. If the modulus is bigger than that, nothing ever wraps, the classifier is sound at every step, and the peeling algorithm works verbatim inside $(\mathbb{Z}/m)^3$.

> **Theorem (Two-sided threshold).** Recovery of a length-$k$ control word from a single state in $(\mathbb{Z}/m)^3$ is
> - **possible** whenever $5 \cdot 7^k < m$, and
> - **impossible** whenever $m^3 < 3^k$.
>
> No modulus satisfies both, so the two regimes are genuinely disjoint.

Between them lies a gap. Writing $m = 7^{\alpha k}$, the phase transition sits somewhere in $\alpha \in [\log 3 / (3\log 7), 1]$, roughly $[0.188, 1]$. Where exactly?

Here is the heuristic that suggests the answer. The bound $5 \cdot 7^k$ is a worst case — it assumes every move is the one that grows the hypotenuse fastest. A *typical* branch grows like the geometric mean of the three per-move factors, not the maximum. Meanwhile the counting obstruction bites when the number of distinguishable states falls below $3^k$. Balancing the two curves suggests

$$\alpha = \frac{\log 3}{\log 7} \approx 0.5646,$$

with a sharp transition: recovery possible for $m \ge 7^{(\alpha + \varepsilon)k}$, impossible for $m \le 7^{(\alpha - \varepsilon)k}$. Proving this remains open.

A second open problem is even cleaner. The reachable set modulo $m$ is contained in the punctured null cone, and we know that cone has at most $2p^2$ points modulo a prime $p$. But the Berggren moves generate an index-two subgroup of the modular orthogonal group of $a^2 + b^2 - c^2$, so the orbit of a primitive null vector should be a single coset — and the count should be forced, not accidental. The conjecture is that the reachable set has cardinality exactly

$$\tfrac{1}{2} m^2 \prod_{p \mid m} \left(1 - p^{-2}\right),$$

precisely *half* the punctured null cone for prime modulus. The missing ingredient is the classical count of zeros of a nondegenerate ternary quadratic form over $\mathbb{F}_p$, which is one substitution $(x,y,z) = (c-a,\, c+a,\, b)$ away from the elementary count of solutions to $xy = z^2$. Establishing it would replace $2p^2$ by $(p^2-1)/2$ in every bound above.

## What the story is really about

Strip away the Pythagorean scenery and the shape of the argument is a lesson in what "hardness" means.

Over the integers, the Berggren system is an *encoder with a perfect decoder*. It maps three-letter words to triples injectively, and the inverse map is two comparisons per letter. As a cipher it would be worthless.

Reduce modulo $m$ and — critically — **nothing about the encoder changes**. The same three matrices, the same invertibility, the same conserved quantity, the same soundness of the classifier on every state that hasn't wrapped. The construction is not "made harder." What changes is the *observer's channel*: they now see through a window of $m^3$ possible values, and $3^k$ messages will not fit through a window of $m^3$ values once $k$ exceeds $3\log_3 m$.

This is a purely information-theoretic obstruction, not a computational one. It is not that the adversary lacks a clever algorithm; the information has been destroyed. That is a stronger and more robust guarantee than most cryptographic hardness, and it comes for free from counting.

Layered on top is a genuinely computational story: even in the regime where the counting bound does not yet apply, the structured sub-family of $B_2$-power words hides a discrete logarithm in $\mathrm{GL}_3(\mathbb{Z}/m)$ — equivalently, a Pell index-finding problem tied to the silver ratio $1 + \sqrt{2}$. That is the same flavour of hardness assumption on which real key exchange rests.

Two exponential curves, $3^k$ and $m^3$, crossing. On one side, a triangle whose ancestry you can read off in linear time. On the other, a residue triple that could have come from exponentially many histories. The ancient $3$–$4$–$5$ triangle, it turns out, has been keeping a modern secret all along.
