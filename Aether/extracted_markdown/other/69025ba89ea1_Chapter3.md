# Chapter 3 — *Hyperbolic Shortcuts: How Pythagoras Learned to Factor*

---

## The Puzzle of the Broken Square

Here is a party trick. I am thinking of a number whose square is $441$. Without reaching for a calculator, can you split $441$ into two factors — neither of them $1$ or $441$ — in under five seconds?

The secret: $441 = 21^2$, and the number $21$ happens to be the short leg of the Pythagorean triple $(21, 20, 29)$. Watch what the Pythagorean equation gives us for free:

$$(29 - 20)(29 + 20) = 9 \times 49 = 441.$$

And since $9 = 3^2$ and $49 = 7^2$, you read off the prime factorization $21 = 3 \times 7$ without any trial division at all. A parlour miracle — powered by a right triangle.

The algebra behind the trick is almost embarrassingly simple. If $a^2 + b^2 = c^2$, then rearranging gives

$$(c - b)(c + b) = c^2 - b^2 = a^2.$$

Symmetrically, $(c - a)(c + a) = b^2$. Two identities, two "free" factorizations, one for each leg. And neither factor is trivial: whenever $a$, $b$, and $c$ are all positive, we have

$$0 < c - b < c < c + b,$$

so both $c - b$ and $c + b$ lie strictly between $0$ and $a^2$. The factorization always tells you something.

[ILLUSTRATION: A right triangle with legs labeled $a = 21$ and $b = 20$ and hypotenuse $c = 29$. On the hypotenuse-side, the classic Pythagorean square of area $c^2 = 841$ is drawn. On the leg-side, the square of area $a^2 = 441$ is drawn but "cracked" into two rectangular shards of dimensions $9 \times 49$, visually demonstrating $(c - b) \times (c + b) = 9 \times 49 = 441$. The crack runs diagonally, and the two pieces are pulled slightly apart to reveal the factorization.]

This idea is older than it looks. Diophantus of Alexandria, writing in the third century, was obsessed with representing numbers as differences of squares — though he would not have used our algebraic notation. Fermat, fourteen centuries later, turned the same trick into a factoring method: to split a composite number $N$, search for integers $x$ and $y$ such that $N = x^2 - y^2 = (x - y)(x + y)$. Every odd composite number admits such a representation; the difficulty lies in *finding* it. What the Pythagorean equation hands us is a ready-made supply of these representations, indexed by the branches of a very particular tree.

[ILLUSTRATION: A small reference table showing six familiar Pythagorean triples — $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(7,24,25)$, $(21,20,29)$, $(9,40,41)$ — with columns for $a$, $b$, $c$, $c - b$, $c + b$, and the resulting factorization of $a^2$. The column headers are in an elegant serif font; the factorizations are highlighted in color.]

---

## A Photon Walks Into a Right Triangle

Now let us change the lighting entirely. Define a quantity

$$Q(a, b, c) = a^2 + b^2 - c^2.$$

For any Pythagorean triple, $Q = 0$. That is what *being* a Pythagorean triple *means*. But stare at $Q$ long enough and you may feel a prickle of recognition. Physicists have a name for this expression: it is a *Lorentz quadratic form* — the very creature that governs the geometry of spacetime in Einstein's special relativity. In that theory, the "distance" between two events is not $x^2 + y^2 + t^2$ but $x^2 + y^2 - t^2$, with a fateful minus sign in front of time. The surface where this quantity vanishes is the *light cone*, the boundary between what a beam of light can reach and what it cannot.

Our Pythagorean triples, then, are integer points on the null cone — lattice points where $Q$ vanishes. If we write $Q$ as a matrix product,

$$Q(\mathbf{v}) = \mathbf{v}^\top \mathbf{Q}\, \mathbf{v}, \qquad \mathbf{Q} = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & -1 \end{pmatrix},$$

then the Pythagorean equation becomes $\mathbf{v}^\top \mathbf{Q}\, \mathbf{v} = 0$. The Babylonians who carved Plimpton 322 and the physicists who built particle accelerators were studying the same equation, separated by four millennia and a change of notation.

[ILLUSTRATION: A three-dimensional coordinate system with axes $a$, $b$, $c$. A translucent double cone — the null cone defined by $a^2 + b^2 = c^2$ — opens along the $c$-axis. Bright dots on the upper cone's surface mark the Pythagorean triples $(3,4,5)$, $(5,12,13)$, $(21,20,29)$, and $(15,8,17)$. Dashed golden lines connect parent to child according to the Berggren tree, so the tree's branches visibly crawl along the cone's surface. A few dots *off* the cone — say $(2,3,4)$ — float in the interior, labeled with their nonzero $Q$-values.]

Here is the stunning fact. Recall the three Berggren matrices from Chapter 1 — the "magic mirrors" $\mathbf{A}$, $\mathbf{B}$, $\mathbf{C}$ that generate every primitive Pythagorean triple from the root $(3,4,5)$. Each of these matrices satisfies

$$\mathbf{A}^\top \mathbf{Q}\, \mathbf{A} = \mathbf{Q}, \qquad \mathbf{B}^\top \mathbf{Q}\, \mathbf{B} = \mathbf{Q}, \qquad \mathbf{C}^\top \mathbf{Q}\, \mathbf{C} = \mathbf{Q}.$$

This is precisely the defining equation of the *integer Lorentz group* $O(2,1;\mathbb{Z})$ — the group of integer matrices that preserve the Minkowski metric. The Berggren tree is not merely a number-theoretic curiosity. It is a structure embedded in the symmetry group of special relativity.

What does this preservation mean in plain language? It means that for *any* vector $\mathbf{v}$ — not just null vectors — the Berggren matrices leave $Q$ unchanged:

$$Q(\mathbf{A}\,\mathbf{v}) = Q(\mathbf{v}).$$

Since the root $(3,4,5)$ has $Q = 0$, every node produced by any sequence of matrix multiplications also has $Q = 0$. The invariant *propagates*. You could press the three buttons labeled $\mathbf{A}$, $\mathbf{B}$, $\mathbf{C}$ in any order, a billion times, and the gauge reading "$Q = 0$" would never flicker.

[ILLUSTRATION: A flow diagram. A vector $(a,b,c)$ enters a sleek black box labeled "$\mathbf{B}$" from the left. It emerges on the right as $(a + 2b + 2c,\; 2a + b + 2c,\; 2a + 2b + 3c)$. Above the input, a circular gauge reads "$Q = 0$." Above the output, an identical gauge also reads "$Q = 0$." The visual metaphor: $Q$ is a conserved quantity, like energy in physics. A whimsical caption reads: "The meter never lies."]

---

## Hyperbolic Shortcuts, or: How to Skip a Billion Generations

Every primitive Pythagorean triple has a unique postal address in the Berggren tree. The root $(3,4,5)$ has the empty address. The triple $(21,20,29)$ lives at **M** (one step along the middle branch). The triple $(119, 120, 169)$ lives at **MM**. What is the address of $(39, 80, 89)$? Answer: **LM** — go Left, then Middle. You can verify this yourself:

$$\mathbf{A} \begin{pmatrix}3\\4\\5\end{pmatrix} = \begin{pmatrix}5\\12\\13\end{pmatrix}, \qquad \mathbf{B} \begin{pmatrix}5\\12\\13\end{pmatrix} = \begin{pmatrix}39\\80\\89\end{pmatrix}.$$

A *path* is a finite word over the alphabet $\{L, M, R\}$. The triple at address $d_1 d_2 \cdots d_k$ is

$$\mathbf{v}_{d_1 d_2 \cdots d_k} = B_{d_1} \cdot B_{d_2} \cdots B_{d_k} \cdot \begin{pmatrix}3\\4\\5\end{pmatrix},$$

where we write $B_L = \mathbf{A}$, $B_M = \mathbf{B}$, $B_R = \mathbf{C}$. The *path matrix* $P = B_{d_1} B_{d_2} \cdots B_{d_k}$ encodes the entire journey in a single $3 \times 3$ package. And here is the shortcut: for a concatenated path $p \cdot q$, the path matrix is simply the product $P_{p \cdot q} = P_p \cdot P_q$. Composing journeys is just multiplying matrices.

Now suppose you want to visit the triple that is one million levels deep along the middle branch. A naïve traveler would multiply by $\mathbf{B}$ a million times — a million matrix multiplications. But a cunning traveler notices that the path matrix is $\mathbf{B}^{1{,}000{,}000}$, and that matrix powers can be computed by *repeated squaring*:

$$\mathbf{B}^2 = \mathbf{B} \cdot \mathbf{B}, \quad \mathbf{B}^4 = \mathbf{B}^2 \cdot \mathbf{B}^2, \quad \mathbf{B}^8 = \mathbf{B}^4 \cdot \mathbf{B}^4, \quad \ldots$$

Since $1{,}000{,}000 < 2^{20}$, at most $20$ squarings and a handful of extra multiplications suffice. Twenty steps instead of a million. This is the *hyperbolic shortcut*: exponentiating a Lorentz transformation to leap across astronomical depths of the tree in logarithmic time.

The principle is ancient and universal. The Egyptians used a version of it for multiplication (the "Russian peasant" method). The RSA cryptosystem that secures your bank transactions relies on the same idea — fast modular exponentiation. Here, the same trick lets us teleport through the Berggren tree.

And the Lorentz invariance travels with us. For *any* path $p$, no matter how long or tortuous,

$$P_p^\top \, \mathbf{Q} \, P_p = \mathbf{Q}, \qquad |\det P_p| = 1.$$

Every shortcut matrix is itself an integer Lorentz transformation. The symmetry is indestructible.

[ILLUSTRATION: A dramatic "zoom" effect. On the left, the Berggren tree is drawn in fine detail for its first three levels — nine leaf nodes visible. On the right, a glowing wormhole-style tunnel labeled "$\mathbf{B}^{1{,}000{,}000}$" arcs from the root node directly to a distant point marked with a starburst, bypassing all intermediate generations. The intermediate nodes are rendered as a blur of receding dots. Caption: "Twenty multiplications. One million generations."]

---

## The Elevator Going Up

You have been handed the triple $(39, 80, 89)$ and told it lives somewhere in the tree. Can you find your way back to the root? The tree is infinite, and you do not know your address.

The answer is to ride the elevator — the *inverse* Berggren matrices. Since each $B_i$ preserves the Lorentz form and has determinant $\pm 1$, each is invertible over the integers. The inverses are computed by the *Lorentz adjoint* formula:

$$B_i^{-1} = \mathbf{Q}\, B_i^\top\, \mathbf{Q}.$$

This is the number-theoretic shadow of a beautiful fact from physics: the inverse of a Lorentz boost is obtained by flipping the sign of the velocity. Here, the metric $\mathbf{Q}$ plays the role of the Minkowski metric, and transposition plays the role of time-reversal.

The ascent algorithm is simple. Given any primitive triple, try applying each of the three inverse matrices. Exactly one will produce a triple with all-positive entries and a *smaller* hypotenuse. That is your parent. Repeat until you reach $(3, 4, 5)$.

Worked example: start at $(39, 80, 89)$. Apply $\mathbf{A}^{-1}$: you get $(5, 12, 13)$, which is valid (all positive, smaller hypotenuse). Apply $\mathbf{A}^{-1}$ again: you get $(3, 4, 5)$. You have recovered the address **LM** — Left, then Middle — by climbing the tree in reverse.

[ILLUSTRATION: The Berggren tree from Chapter 1, redrawn with upward-pointing arrows in a warm copper color alongside the original downward black arrows. The upward arrows are labeled $\mathbf{A}^{-1}$, $\mathbf{B}^{-1}$, $\mathbf{C}^{-1}$. A highlighted path traces the "elevator ride" from $(39,80,89)$ up through $(5,12,13)$ to the root $(3,4,5)$, glowing like a lit fuse.]

Why does the hypotenuse always shrink on the way up? Because it always *grows* on the way down. For any primitive triple $(a,b,c)$ with positive entries:

- The Left child has hypotenuse $2a - 2b + 3c > c$,
- The Middle child has hypotenuse $2a + 2b + 3c > c$ (obviously — every term is positive),
- The Right child has hypotenuse $-2a + 2b + 3c > c$.

The first and third require a moment's thought — the Pythagorean equation ensures that the seemingly negative terms cannot overwhelm the $3c$. The upshot: the tree grows strictly, every generation bigger than the last. Running the tree backward, the hypotenuse strictly decreases, and since we are in positive integers, the descent must terminate — at $(3,4,5)$.

---

## Chebyshev's Secret Recurrence

The middle branch of the Berggren tree produces the hypotenuse sequence $5, 29, 169, 985, 5741, \ldots$ Stare at it. Do you see the pattern?

Here is a hint: $169 = 6 \times 29 - 5$, and $985 = 6 \times 169 - 29$. The recurrence is

$$c_{n+1} = 6\, c_n - c_{n-1}.$$

This is not a coincidence. The middle-branch matrix $\mathbf{B}$ has a characteristic polynomial whose structure forces a second-order linear recurrence on each coordinate. The name attached to such recurrences is Chebyshev — the great Russian mathematician Pafnuty Chebyshev, whose polynomials arise whenever one studies powers of matrices with a particular trace. Chebyshev polynomials appear in approximation theory, in the design of mechanical linkages, in the distribution of prime numbers, and now — in the hypotenuses of Pythagorean triples marching down the middle branch of an infinite tree.

Note, too, that $169 = 13^2$ — a perfect square hiding among the hypotenuses. This is not an accident but a structural feature of the recurrence, and it connects to the factoring story we are about to complete.

[ILLUSTRATION: A number line stretching to the right, with the middle-branch hypotenuses $5, 29, 169, 985, 5741$ marked at increasing (and visibly accelerating) intervals. Curved arrows arc above the line: each arrow spans from $c_{n-1}$ to $c_{n+1}$, annotated with "$\times 6$" on the forward leg and "$- c_{n-1}$" on the backward leg. The value $169 = 13^2$ is circled and flagged with a small banner reading "perfect square!"]

---

## Cracking Numbers on the Light Cone

We began this chapter with a party trick — factoring $441$ using the triple $(21, 20, 29)$. Let us now see the trick in its full generality.

Suppose you are handed a composite number $N$ and asked to find a nontrivial factor. If you can locate a Pythagorean triple $(a, b, c)$ with $a = N$ (or with $a$ sharing a factor with $N$), then the difference-of-squares identity $(c - b)(c + b) = a^2$ gives you a ready-made factorization of $a^2$. Compute

$$d = \gcd(c - b,\; a).$$

If $1 < d < |a|$, you have found a proper divisor of $a$ — and you did it without any trial division, without any sieve, without testing a single prime. Just a right triangle and a greatest common divisor.

> **The GCD Factoring Principle.** If $a^2 + b^2 = c^2$ with $a > 1$, and if $d = \gcd(c - b,\; a)$ satisfies $1 < d < |a|$, then $d$ is a nontrivial divisor of $a$.

The worked example bears repeating in slow motion. Take the triple $(21, 20, 29)$. Compute $c - b = 29 - 20 = 9$. Compute $\gcd(9, 21) = 3$. Since $1 < 3 < 21$, the number $3$ is a proper divisor of $21$, and we conclude $21 = 3 \times 7$.

[ILLUSTRATION: A visual flowchart. **Input box:** "A composite number $N = 21$." **Arrow** to a box showing the Berggren tree, with the node $(21,20,29)$ highlighted: "Find a Pythagorean triple with leg $= N$." **Arrow** to a computation box: "$c - b = 29 - 20 = 9$." **Arrow** to a GCD box: "$\gcd(9, 21) = 3$." **Arrow** to an **Output box:** "Nontrivial factor: $3$. Therefore $21 = 3 \times 7$." The entire flowchart is set against a faded background image of the null cone from the earlier illustration.]

Of course, not every triple yields a nontrivial GCD — sometimes $\gcd(c - b, a) = 1$ or $= |a|$, and you learn nothing. The art is in choosing the right triple. This is where the Berggren tree earns its keep: it provides a *structured*, *infinite* supply of candidate triples, navigable in logarithmic time via the hyperbolic shortcuts of repeated squaring. If one triple fails to crack your number, you climb back up, descend a different branch, and try again.

The deeper point is that the Berggren tree transforms factoring from a problem of *search* (which primes divide $N$?) into a problem of *navigation* (which branch of the tree yields a useful triple?). The difference-of-squares identity is the engine; the tree is the fuel supply; and the Lorentz invariance guarantees that every node you visit is a legitimate Pythagorean triple, ready to be fed into the GCD machine.

Fermat himself used the difference-of-squares approach to factor large numbers — his method amounts to searching for $x$ and $y$ such that $N = x^2 - y^2$. The modern quadratic sieve and the number field sieve, the most powerful factoring algorithms known, are elaborate descendants of the same algebraic idea. What the Berggren tree adds is *geometry*: a view of the factoring landscape as a tree of lattice points on a light cone in Minkowski space, traversable by Lorentz transformations.

[ILLUSTRATION: A full-page conceptual "map" of the chapter, drawn in the style of an antique cartographic chart. The regions are: "The Broken Square" (lower left, showing the cracked-square diagram), "The Null Cone" (center, a stylized double cone), "Berggren Forest" (upper center, the ternary tree rendered as a forest of branching paths), "The Shortcut Wormhole" (a glowing tunnel connecting distant tree nodes), "The Elevator" (a vertical shaft with upward arrows), "Chebyshev Ridge" (a rising curve labeled with the recurrence), and "The Factoring Forge" (lower right, an anvil with the GCD computation). Dotted paths connect these regions, retracing the chapter's narrative arc. A compass rose in the corner points toward "Chapter 4."]

---

## Through the Wormhole

Let us take one last look at the landscape before moving on.

We began with an ancient identity — $(c-b)(c+b) = a^2$ — that turns every Pythagorean triple into a factoring machine. We discovered that the Berggren matrices, which generate *all* primitive triples from the single seed $(3,4,5)$, are not arbitrary curiosities but elements of the integer Lorentz group, preserving the same quadratic form that governs the geometry of spacetime. We learned to navigate the tree by composing paths, to leap across a billion generations by repeated squaring, and to climb back to the root via inverse matrices obtained from the Lorentz adjoint. We watched the hypotenuse grow monotonically down every branch, discovered Chebyshev's recurrence lurking in the middle branch, and confirmed that no two branches ever bear the same fruit. And we arrived at the punchline: the GCD factoring principle, which cracks composite numbers using nothing but a right triangle and a greatest common divisor.

The amateur's delight in a $3$-$4$-$5$ triangle and the physicist's delight in Lorentz invariance turn out to be the same delight, viewed from opposite ends of a very long telescope. In the next chapter, we will look through that telescope from three different vantage points at once — parametric, geometric, and algebraic — and discover a remarkable convergence of ideas that will take us deeper still into the heart of the Pythagorean mystery.
