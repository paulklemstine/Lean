# Chapter 3 — *Hyperbolic Shortcuts: How Pythagoras Learned to Factor*

---

## The Puzzle of the Broken Square

Here is a party trick that will make you the envy of every mental-arithmetic enthusiast at the dinner table. I am thinking of a number whose square is $441$. Without touching a calculator, can you split $441$ into two factors — *neither of them* $1$ or $441$ — in under five seconds?

The secret ingredient is a right triangle. If you happen to know that $441 = 21^2$, and that $21$ appears as a leg in the Pythagorean triple $(21, 20, 29)$, the factorization falls out like a coin from behind your ear:

$$(29 - 20)(29 + 20) = 9 \times 49 = 441 = 21^2.$$

And from $9 = 3^2$ and $49 = 7^2$, you read off $21 = 3 \times 7$. A parlour miracle!

The trick rests on a fact so simple that it hardly seems worth stating, yet so powerful that it echoes across twenty-five centuries of number theory:

> **Theorem (Difference-of-Squares Factorization).** If $a^2 + b^2 = c^2$, then
> $$(c - b)(c + b) = a^2, \qquad (c - a)(c + a) = b^2.$$

The proof is one line of algebra. Expand the left side: $(c - b)(c + b) = c^2 - b^2$. But $c^2 = a^2 + b^2$, so $c^2 - b^2 = a^2$. That is all. The second identity follows by symmetry. What makes this more than a tautology is the observation that for any Pythagorean triple with strictly positive entries, neither factor is trivial:

$$0 < c - b < c < c + b, \qquad \text{whenever } a > 0,\ b > 0,\ c > 0.$$

Why? The hypotenuse $c$ is always the largest side of a right triangle, so $c > b$ (giving $c - b > 0$), and $c + b$ is obviously positive. The two factors carve $a^2$ into a genuinely interesting product — not the boring $1 \times a^2$, but something that can reveal the internal structure of $a$.

[ILLUSTRATION: A right triangle with legs labeled $a = 21$ and $b = 20$ and hypotenuse $c = 29$. Around the triangle, three squares are drawn on each side in the classic Pythagorean theorem diagram. The square on leg $a$ is visually "cracked" into two rectangular pieces of dimensions $(c - b) \times (c + b) = 9 \times 49$, showing the factorization. The crack line runs horizontally across the square, and the two rectangles are shaded in contrasting warm colors.]

Let us run through a few more examples to feel the trick in our fingers:

| $a$ | $b$ | $c$ | $c - b$ | $c + b$ | Factorization of $a^2$ | Revealed factors |
|-----|-----|-----|---------|---------|------------------------|-----------------|
| $3$ | $4$ | $5$ | $1$ | $9$ | $1 \times 9 = 9$ | (trivial) |
| $5$ | $12$ | $13$ | $1$ | $25$ | $1 \times 25 = 25$ | (trivial) |
| $8$ | $15$ | $17$ | $2$ | $32$ | $2 \times 32 = 64$ | $\gcd(2, 8) = 2$ |
| $7$ | $24$ | $25$ | $1$ | $49$ | $1 \times 49 = 49$ | (trivial) |
| $21$ | $20$ | $29$ | $9$ | $49$ | $9 \times 49 = 441$ | $\gcd(9, 21) = 3$ |
| $20$ | $21$ | $29$ | $8$ | $50$ | $8 \times 50 = 400$ | $\gcd(8, 20) = 4$ |

Notice that the trick does not always produce a nontrivial factor — sometimes $c - b = 1$, and we learn nothing new. The art lies in choosing the *right* triple. And as we shall see, the Berggren tree from Chapters 1 and 2 gives us an inexhaustible supply of candidates to try.

The ancient Greeks knew all about differences of squares. Diophantus of Alexandria, in his *Arithmetica* (circa 250 CE), repeatedly exploited the identity $c^2 - b^2 = (c-b)(c+b)$ to solve indeterminate equations. Fourteen centuries later, Pierre de Fermat — scribbling in the margins of his own copy of the *Arithmetica* — elevated this idea to a general method for factoring integers. Fermat's insight was that if you can write a number $N$ as a difference of two squares, $N = x^2 - y^2$, then you immediately get a factorization $N = (x - y)(x + y)$. The Pythagorean identity is just a special case of this principle — but a beautifully structured special case, because the Berggren tree hands us an infinite, organized catalogue of such decompositions.

---

## The Light-Cone in the Living Room

What does a right triangle have in common with a photon?

More than you might think. In Chapter 1, we met the Lorentz quadratic form $Q(a, b, c) = a^2 + b^2 - c^2$ and observed that Pythagorean triples are exactly the integer points where $Q$ vanishes. We also met the three Berggren matrices $\mathbf{A}$, $\mathbf{B}$, $\mathbf{C}$ (which I will henceforth call $B_1$, $B_2$, $B_3$ — the notation is cleaner, and I want all three to look like siblings):

$$B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}.$$

In this chapter, I want to push deeper into the connection with physics. The form $Q$ can be written as a matrix sandwich:

$$Q(\mathbf{v}) = \mathbf{v}^\top \mathbf{Q}\, \mathbf{v}, \qquad \mathbf{Q} = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & -1 \end{pmatrix}.$$

The matrix $\mathbf{Q}$ is the *Minkowski metric* of $2+1$-dimensional spacetime. In Einstein's special relativity, $a$ and $b$ would be spatial coordinates and $c$ would be time (or vice versa, depending on your sign convention), and the surfaces where $Q = 0$ form the *light cone* — the boundary between events that a photon can reach and events that are forever inaccessible. Pythagorean triples are integer points *on* the light cone. They are, if you like, lattice-dwelling photons.

Now here is the stunning fact — the reason I dragged a photon into a chapter about number theory. Each Berggren matrix satisfies:

$$B_i^\top \, \mathbf{Q} \, B_i = \mathbf{Q}, \qquad i = 1, 2, 3.$$

This is exactly the defining equation for a *Lorentz transformation* — a symmetry of spacetime that preserves the speed of light. In the language of group theory, each $B_i$ belongs to the *integer Lorentz group* $O(2,1;\mathbb{Z})$: the collection of all $3 \times 3$ integer matrices that preserve the Minkowski metric.

[ILLUSTRATION: A three-dimensional coordinate system with axes $a$, $b$, $c$. A double cone (the "light cone") defined by $a^2 + b^2 = c^2$ opens upward and downward along the $c$-axis. Several Pythagorean triples are plotted as glowing lattice points on the surface of the upper cone: $(3,4,5)$, $(5,12,13)$, $(21,20,29)$, $(15,8,17)$. Dashed lines connect parent to child according to the Berggren tree, showing the tree edges living on the cone's surface. The cone is rendered with a slight translucency so the lattice structure is visible through it.]

Let me verify the identity for $B_2$ — the calculation is instructive and not as bad as it looks. If $\mathbf{v} = (a, b, c)^\top$, then $B_2 \mathbf{v} = (a + 2b + 2c,\; 2a + b + 2c,\; 2a + 2b + 3c)^\top$. Compute the Lorentz form of the output:

$$(a + 2b + 2c)^2 + (2a + b + 2c)^2 - (2a + 2b + 3c)^2.$$

Expand each square, collect terms, and — after a page of algebra that I will mercifully spare you — everything collapses to $a^2 + b^2 - c^2$. The form is *invariant*. What goes in as $Q(\mathbf{v})$ comes out as $Q(\mathbf{v})$, unchanged.

The physical interpretation is irresistible. A Lorentz transformation is what happens when you switch from one inertial reference frame to another — from a physicist standing still to one riding a rocket. The laws of physics (Maxwell's equations, the speed of light) look the same in both frames. Here, the Berggren matrices are the "rockets," the Pythagorean triples are the "photons," and the invariance of $Q$ is the "constancy of the speed of light." Minkowski would have been delighted.

[ILLUSTRATION: A whimsical cartoon of a photon — drawn as a small glowing orb with sunglasses and a confident grin — standing at a blackboard. On the blackboard is written the equation $B_i^\top \mathbf{Q}\, B_i = \mathbf{Q}$. The photon is tapping the equation with a pointer. Caption: "Even light obeys the Berggren matrices."]

---

## The Invariant That Refuses to Change

Imagine a machine with three buttons — labeled **L**, **M**, and **R** — sitting on your desk. You start by entering the triple $(3, 4, 5)$. Each time you press a button, the machine scrambles your input through a complicated formula (corresponding to $B_1$, $B_2$, or $B_3$). You press **M**. The display reads $(21, 20, 29)$. You press **L**. The display now reads $(39, 80, 89)$. You press **R**, then **M**, then **L**, then **R** again. The numbers grow large, the formulas are opaque — but through it all, one quantity never budges:

$$Q(a, b, c) = a^2 + b^2 - c^2 = 0.$$

Always zero. No matter how many buttons you press, in whatever order. The Lorentz form is a *conserved quantity*, like energy in a closed system. It passes through every transformation unscathed because each Berggren matrix individually preserves it:

$$Q\bigl(B_i \mathbf{v}\bigr) = Q(\mathbf{v}), \quad \text{for all } \mathbf{v} \in \mathbb{Z}^3, \quad i = 1, 2, 3.$$

This is the engine of the Berggren tree. The root $(3, 4, 5)$ is a null vector — $Q = 0$. Each child is obtained by applying a $Q$-preserving transformation. Therefore every child is also a null vector. And every grandchild. And every great-grandchild, out to infinity. The Pythagorean property *propagates* through the tree, carried by the invariance of the Lorentz form.

[ILLUSTRATION: A flow diagram showing a vector $(a, b, c)$ entering a sleek "black box" labeled $B_2$, emerging as $(a + 2b + 2c,\; 2a + b + 2c,\; 2a + 2b + 3c)$. Above the input, a circular gauge — like a fuel gauge in a car — reads "$Q = 0$." Above the output, an identical gauge also reads "$Q = 0$." The visual metaphor: the Lorentz form is a conserved quantity that no Berggren transformation can alter.]

---

## Paths, Addresses, and the Art of Navigation

Every primitive Pythagorean triple has a unique postal address in the Berggren tree. The address of $(3, 4, 5)$ is the empty word — it lives at the root. The address of $(21, 20, 29)$ is simply **M**. The address of $(5, 12, 13)$ is **L**. And the address of $(39, 80, 89)$?

The honest way to find out is to work *backwards* — applying the inverse Berggren matrices (which we will meet properly in a moment) to $(39, 80, 89)$ and seeing which one yields a valid parent with a smaller hypotenuse. When we try $B_1^{-1}$, out pops $(21, 20, 29)$ — all entries positive, hypotenuse smaller. That is the parent. And we already know that $(21, 20, 29)$ lives at address **M**. So $(39, 80, 89)$ was produced from $(21, 20, 29)$ by applying $B_1$ — the Left branch. Its full address is therefore **ML**: go Middle from the root to $(21, 20, 29)$, then Left to reach $(39, 80, 89)$.

Let us verify. Apply $B_1$ to $(21, 20, 29)$: the first coordinate is $1 \cdot 21 - 2 \cdot 20 + 2 \cdot 29 = 21 - 40 + 58 = 39$. The second is $2 \cdot 21 - 1 \cdot 20 + 2 \cdot 29 = 42 - 20 + 58 = 80$. The third is $2 \cdot 21 - 2 \cdot 20 + 3 \cdot 29 = 42 - 40 + 87 = 89$. Indeed: $B_1 \cdot (21, 20, 29)^\top = (39, 80, 89)^\top$. The postal service delivers.

The principle is now clear:

> **Every primitive Pythagorean triple has a unique address** — a finite sequence of directions $d_1, d_2, \ldots, d_k$ from the alphabet $\{L, M, R\}$ — and the triple at that address is obtained by multiplying the Berggren matrices along the path:

$$\mathbf{v}_{d_1 d_2 \cdots d_k} = B_{d_1} \cdot B_{d_2} \cdots B_{d_k} \cdot \begin{pmatrix}3\\4\\5\end{pmatrix}.$$

Define the *path matrix* $P = B_{d_1} B_{d_2} \cdots B_{d_k}$. Then the key **shortcut theorem** says: the path matrix for a concatenated address $p \cdot q$ (first follow $p$, then $q$) is simply the product of the individual path matrices:

$$P_{p \cdot q} = P_p \cdot P_q.$$

This is just the associativity of matrix multiplication — but its consequences are profound.

[ILLUSTRATION: A map-style diagram of the Berggren tree's first three levels, drawn as a network of roads connecting small towns. Each "town" (node) has a signpost displaying its Pythagorean triple. Each "road" (edge) is labeled L, M, or R. The route from the root $(3,4,5)$ through the Middle branch to $(21,20,29)$ and then Left to $(39,80,89)$ is highlighted in red, showing the "postal route" to address **ML**.]

---

## Hyperbolic Shortcuts, or: How to Skip a Billion Generations

Suppose you want to visit the triple that is $1{,}000{,}000$ levels deep in the middle branch of the Berggren tree. A naïve traveler would multiply by $B_2$ a million times. But a cunning mathematician can get there in about $20$ matrix multiplications. How?

The shortcut theorem tells us that the path matrix for $k$ consecutive Middle steps is simply $B_2^k$. And $B_2^k$ can be computed by *repeated squaring*:

$$B_2^2 = B_2 \cdot B_2, \quad B_2^4 = B_2^2 \cdot B_2^2, \quad B_2^8 = B_2^4 \cdot B_2^4, \quad \ldots$$

Since $1{,}000{,}000 < 2^{20}$, we need at most $20$ squarings and multiplications to assemble $B_2^{1{,}000{,}000}$ from its binary representation. A million steps, collapsed into twenty. This is the "hyperbolic shortcut": exponentiating a Lorentz transformation to leap across astronomical depths of the tree in logarithmic time.

The idea of repeated squaring is one of the oldest and most versatile tricks in all of computation. The ancient Egyptians used a version of it for multiplication (the "Russian peasant" method). Modern cryptographic systems — RSA, Diffie-Hellman, elliptic curve cryptography — rely on it for modular exponentiation. Here it takes on a geometric flavor: we are exponentiating a *Lorentz boost*, leaping along the light cone in ever-larger jumps.

And the Lorentz invariance comes along for the ride. For *any* path $p$ of any length, the path matrix $P_p$ satisfies:

$$P_p^\top \, \mathbf{Q} \, P_p = \mathbf{Q}, \qquad |\det P_p| = 1.$$

Every shortcut matrix is itself an integer Lorentz transformation. You can leap a billion generations and still land on the light cone.

[ILLUSTRATION: A dramatic "zoom" effect. On the left, the top of the Berggren tree is shown in full detail (three levels, with nodes and labels). On the right, a telescope or wormhole graphic shows a single sweeping arrow labeled "$B_2^{1{,}000{,}000}$" jumping from the root directly to a node astronomically far down the middle branch, bypassing all intermediate nodes. The intermediate nodes are shown as a blur of receding dots. The arrow is drawn in a curved, glowing "hyperspace jump" style.]

---

## The Elevator Going Up

You have been handed the triple $(65, 72, 97)$ and told it lives somewhere in the Berggren tree. Can you find your way back to the root $(3, 4, 5)$? The catch: you do not know your address, and the tree is infinite in every direction but up.

The key is to run the Berggren matrices in reverse. Since each $B_i$ is an integer Lorentz transformation with $|\det B_i| = 1$, each one has an integer inverse. The three inverse matrices are:

$$B_1^{-1} = \begin{pmatrix} 1 & 2 & -2 \\ -2 & -1 & 2 \\ -2 & -2 & 3 \end{pmatrix}, \quad B_2^{-1} = \begin{pmatrix} 1 & 2 & -2 \\ 2 & 1 & -2 \\ -2 & -2 & 3 \end{pmatrix}, \quad B_3^{-1} = \begin{pmatrix} -1 & -2 & 2 \\ 2 & 1 & -2 \\ -2 & -2 & 3 \end{pmatrix}.$$

These arise from a beautiful formula — the *Lorentz adjoint*:

$$B_i^{-1} = \mathbf{Q} \, B_i^\top \, \mathbf{Q}.$$

This is the number-theoretic analogue of a fact from special relativity: the inverse of a Lorentz boost is obtained by "flipping the sign of the velocity." Here, the metric $\mathbf{Q}$ plays the role of the Minkowski metric, transposition plays the role of time-reversal, and the double conjugation $\mathbf{Q}(\cdot)\mathbf{Q}$ implements the sign flip. Physics and number theory, speaking the same language again.

**The Ascent Algorithm.** Given any primitive Pythagorean triple, try applying each of the three inverse matrices. Exactly one will produce a triple with all-positive entries and a *smaller* hypotenuse. That is your parent. Repeat until you reach $(3, 4, 5)$, and read off your address in reverse.

[ILLUSTRATION: The Berggren tree from the earlier illustration, but now with upward-pointing arrows drawn in a warm contrasting color (gold or amber), labeled $B_1^{-1}$, $B_2^{-1}$, $B_3^{-1}$ at each junction. A highlighted path shows the "elevator ride" from a node deep in the tree back up through intermediate nodes to the root $(3,4,5)$. The upward arrows form a golden thread through the tree.]

---

## Why the Hypotenuse Always Grows

Here is a reassuring fact about the Berggren tree: once you leave the root, you can *never* return to a smaller hypotenuse by going deeper. The tree only grows. But how fast?

For any primitive triple $(a, b, c)$ with positive entries, the hypotenuse of each child is:

- **Left branch ($B_1$):** $c' = 2a - 2b + 3c$
- **Middle branch ($B_2$):** $c' = 2a + 2b + 3c$
- **Right branch ($B_3$):** $c' = -2a + 2b + 3c$

The middle branch is the easiest to analyze — all three terms are positive, so $c' = 2a + 2b + 3c > 3c > c$. The hypotenuse more than triples at every step. The left and right branches require a moment's thought. For the right branch: $c' = -2a + 2b + 3c = 3c + 2(b - a)$. Since $c > 0$ and $c^2 = a^2 + b^2 > a^2$, we have $c > a$ (the hypotenuse exceeds each leg), so $c' > 3c - 2c = c$. A similar argument handles the left branch. In every case, the hypotenuse strictly increases.

This monotonicity is what makes the ascent algorithm terminate: at each step, the hypotenuse shrinks, so eventually we must reach the minimum — the root $(3, 4, 5)$.

---

## Chebyshev's Secret Recurrence

The middle branch of the Berggren tree produces the hypotenuse sequence $5, 29, 169, 985, 5741, \ldots$ Can you spot the pattern?

Here is a hint: $169 = 6 \times 29 - 5$, and $985 = 6 \times 169 - 29$, and $5741 = 6 \times 985 - 169$. The hypotenuses satisfy a *second-order linear recurrence*:

$$c_{n+1} = 6\, c_n - c_{n-1}.$$

This is not a coincidence — it is a consequence of the matrix structure. When you repeatedly apply the same matrix $B_2$, the sequence of hypotenuses (or any fixed coordinate) satisfies a linear recurrence whose coefficients are determined by the characteristic polynomial of $B_2$. And the name for the polynomials that arise from such recurrences is *Chebyshev polynomials* — named for the great Russian mathematician Pafnuty Chebyshev (1821–1894), who encountered them in the study of mechanical linkages and prime number distribution, two subjects that could hardly seem more different.

Note an intriguing fact: $169 = 13^2$. The third hypotenuse in the middle branch is a perfect square! This is not an accident — it connects to deep questions about which Pythagorean triples have square hypotenuses, and thus to the factoring trick with which we began.

[ILLUSTRATION: A number line showing the middle-branch hypotenuses $5, 29, 169, 985, 5741$ as points, with curved arrows above connecting consecutive triples. Each arrow is annotated: "$\times 6$" pointing forward and "$-1 \times$" pointing backward, illustrating the recurrence $c_{n+1} = 6c_n - c_{n-1}$. The number $169 = 13^2$ is circled and marked with a star.]

---

## No Two Branches Bear the Same Fruit

In a well-designed filing system, no document should appear in two drawers at once. The Berggren tree is nature's filing system for primitive Pythagorean triples. Can two different branches ever produce the same triple?

The answer is *never*, and the reason is pleasingly elementary. Consider the hypotenuses produced by $B_1$ and $B_2$ from the same parent $(a, b, c)$:

$$B_1: \quad c' = 2a - 2b + 3c, \qquad B_2: \quad c'' = 2a + 2b + 3c.$$

Their difference is $c'' - c' = 4b$, and since $b > 0$ for any genuine Pythagorean triple, the two hypotenuses are always distinct. Similarly, $B_1$ and $B_3$ produce hypotenuses differing by $4(a - b) + 4b = 4a$... well, let me be more careful. The hypotenuse from $B_3$ is $-2a + 2b + 3c$. Compare with $B_1$'s hypotenuse $2a - 2b + 3c$: the difference is $4a - 4b$, which is nonzero whenever $a \neq b$. And comparing $B_2$ and $B_3$: the difference is $(2a + 2b + 3c) - (-2a + 2b + 3c) = 4a > 0$. So all three children of any given parent have distinct hypotenuses — and since the hypotenuse strictly increases at each generation, no triple can appear at two different depths.

This local disjointness is the engine behind the great global theorem (proved by Berggren in 1934 and rediscovered by Hall in 1970): *every primitive Pythagorean triple appears exactly once in the tree*. A complete, duplicate-free enumeration of an infinite set — achieved by three $3 \times 3$ matrices and a single seed.

[ILLUSTRATION: Three "branches" of the Berggren tree drawn as three separate sub-trees side by side, each rooted at $(3,4,5)$. The Left branch is drawn in red, the Middle in blue, and the Right in green. A magnifying glass hovers over the junction, with a "no duplicates" symbol — a circle with a diagonal line through two overlapping triple-labels — confirming that no triple appears in more than one branch.]

---

## Cracking Numbers on the Light Cone

Now we arrive at the punchline — the moment when all the threads of this chapter braid together.

Recall the difference-of-squares identity from the opening section: if $(a, b, c)$ is a Pythagorean triple, then $(c - b)(c + b) = a^2$. Suppose $a$ is composite — say $a = pq$ — and we want to discover a factor. Compute:

$$d = \gcd(c - b,\; a).$$

If $d$ is nontrivial — if $1 < d < |a|$ — then $d$ is a proper divisor of $a$. We have factored $a$ using nothing but a right triangle and a greatest common divisor.

> **Theorem (GCD Factoring).** If $a^2 + b^2 = c^2$ with $a > 1$, and if $d = \gcd(c - b,\; a)$ satisfies $1 < d < |a|$, then $d$ is a nontrivial divisor of $a$.

The proof is almost too simple. Since $d \mid (c - b)$ and $d \mid a$, we have $d \mid a$, so $d$ is a divisor of $a$. The condition $1 < d < |a|$ makes it nontrivial. That is all.

Let us watch this theorem in action. Take the triple $(21, 20, 29)$:

$$c - b = 29 - 20 = 9, \qquad \gcd(9, 21) = 3.$$

Since $1 < 3 < 21$, we have discovered that $3$ divides $21$ — and hence $21 = 3 \times 7$.

[ILLUSTRATION: A visually appealing "proof without words" display. At the top, the triple $(21, 20, 29)$ is shown inside a right triangle. An arrow points to the computation $29 - 20 = 9$. Another arrow points to $\gcd(9, 21) = 3$. A final arrow points to the conclusion $21 = 3 \times 7$. The steps are connected by flowing curves, and the whole display is framed in an ornate border, like a mathematical certificate.]

Here is the deeper point. The Berggren tree gives us an inexhaustible, *structured* supply of Pythagorean triples. If we are handed a number $N$ to factor, we can search the tree for a triple whose leg equals $N$ (or a multiple of $N$), and then apply the GCD trick. The tree is our database, the difference-of-squares identity is our query, and the greatest common divisor is our extractor.

Of course, not every triple yields a nontrivial GCD. Sometimes $\gcd(c - b, a) = 1$, and the trick tells us nothing we did not already know. The art is in choosing the right triple — and this connects to deep questions about quadratic residues, smooth numbers, and the distribution of primes. Fermat's original factoring method is a special case of this idea; the quadratic sieve and the number field sieve — the most powerful factoring algorithms known today — are sophisticated descendants of it.

[ILLUSTRATION: A flowchart-style diagram. **Input:** a composite number $N$ inside a hexagonal box. **Step 1:** Find a Pythagorean triple $(a, b, c)$ with $a = N$ (or $a$ related to $N$), drawing from the Berggren tree shown as a ghostly background image. **Step 2:** Compute $c - b$ and $c + b$ (shown in rectangular computation boxes). **Step 3:** Compute $\gcd(c - b, N)$ (shown in a diamond decision box). **Output:** either "nontrivial factor found!" (green exit) or "try another triple" (red loop back to Step 1). The flowchart is drawn in a clean, modern infographic style.]

---

## Through the Wormhole

Let us stand back and survey the landscape.

We began with a broken square — the ancient identity $(c - b)(c + b) = a^2$ — and discovered that a right triangle can crack open a composite number like a nutshell. We revisited the Berggren matrices from Chapters 1 and 2 and saw that they are not merely number-theoretic curiosities; they are *integer Lorentz transformations*, members of the symmetry group that governs the geometry of spacetime. The invariance of the Lorentz form $Q = a^2 + b^2 - c^2$ is the engine that keeps the tree Pythagorean at every node, and the "hyperbolic shortcuts" — repeated squaring of Lorentz boosts — let us leap across billions of generations in logarithmic time. The inverse matrices, obtained by the Lorentz adjoint formula $B^{-1} = \mathbf{Q} B^\top \mathbf{Q}$, let us climb back up the tree to the root, recovering any triple's unique address. The hypotenuse grows monotonically at every step — most dramatically along the middle branch, whose hypotenuses satisfy the Chebyshev recurrence $c_{n+1} = 6c_n - c_{n-1}$. And no two branches ever bear the same fruit: the tree is a complete, duplicate-free catalogue of all primitive Pythagorean triples.

The punchline tied it all together: the difference-of-squares identity, combined with the GCD, turns any Pythagorean triple into a potential factoring machine. The Berggren tree is the supply chain; the Lorentz form is the quality guarantee; and the greatest common divisor is the extraction tool.

We began this book by planting a tree of right triangles and ended the last chapter by discovering that the tree, for all its beauty, is a two-dimensional dead end — provably unable to factor large numbers faster than $\Theta(\sqrt{N})$. In this chapter, we have seen that the *same tree* encodes a richer structure: the symmetry group of spacetime, a conserved quadratic form, and a factoring algorithm as old as Fermat. The mathematics grows more tangled and more beautiful at every turn.

The amateur's delight in a $3$-$4$-$5$ triangle and the physicist's delight in Lorentz invariance turn out to be the same delight, viewed from different ends of a very long telescope.

[ILLUSTRATION: A full-page "map" of the entire chapter's conceptual landscape, drawn in the style of a medieval *mappa mundi* or a fantasy-novel treasure map. The regions are labeled: "The Broken Square" (a cracked stone square at the bottom left), "The Light Cone" (a glowing double cone in the center), "The Berggren Forest" (a dense ternary tree spreading across the upper left), "Shortcut Wormhole" (a spiraling tunnel connecting distant nodes), "The Elevator" (a golden ladder ascending through the tree), "Chebyshev Ridge" (a mountain range with peaks at $5, 29, 169, 985$), and "The Factoring Forge" (a blacksmith's workshop at the far right, where GCDs are hammered out on an anvil). Paths connect these regions, retracing the chapter's narrative arc. A compass rose in the corner points toward "Chapter 4."]

---

### Puzzles for the Reader

> **Puzzle 1.** Use the difference-of-squares identity to factor $a^2$ for the triple $(33, 56, 65)$. Does $\gcd(c - b, a)$ produce a nontrivial factor of $33$?

> **Puzzle 2.** Verify that the Berggren matrix $B_1$ satisfies $B_1^\top \mathbf{Q}\, B_1 = \mathbf{Q}$ by direct matrix multiplication. (Hint: you need to compute $B_1^\top$ first, then multiply three $3 \times 3$ matrices. It is tedious but enlightening.)

> **Puzzle 3.** The middle-branch hypotenuses satisfy $c_{n+1} = 6c_n - c_{n-1}$, with $c_0 = 5$ and $c_1 = 29$. Compute $c_4$ and $c_5$. Is $c_4$ a perfect square?

> **Puzzle 4.** Starting from the triple $(77, 36, 85)$, use the ascent algorithm (try each $B_i^{-1}$ and keep the one that gives all-positive entries with a smaller hypotenuse) to climb back to the root. What is the address of $(77, 36, 85)$?

> **Puzzle 5.** The triple $(9, 40, 41)$ gives $c - b = 1$. Why does the GCD trick fail here? What does this tell you about the structure of the number $9$?

> **Puzzle 6.** Compute $\det(B_1)$, $\det(B_2)$, and $\det(B_3)$. Which of the three Berggren matrices are "proper" Lorentz transformations (determinant $+1$) and which are "improper" (determinant $-1$)?
