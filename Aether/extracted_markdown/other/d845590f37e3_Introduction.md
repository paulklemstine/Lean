# Introduction — *The Triangle That Swallowed the Universe*

---

## A Puzzle on the Bathroom Floor

Imagine, if you will, a lazy Saturday morning. You are sitting on the edge of the bathtub, staring at the floor tiles, and a strange thought drifts into your head. The tiles are square — one-inch squares, let us say — and you begin to wonder: *how many different right triangles can you draw on this grid so that all three sides land exactly on grid points and every side has a whole-number length?*

You start with the obvious one. Three squares along one leg, four along the other, five along the hypotenuse. The $3$-$4$-$5$ right triangle — the rope-stretcher's friend, the pharaoh's surveying tool, the oldest known example of the most famous equation in mathematics:

$$a^2 + b^2 = c^2.$$

Check: $9 + 16 = 25$. The two smaller squares tile the largest perfectly, with not a single unit cell left over.

[ILLUSTRATION: A large, beautifully rendered depiction of a right triangle with legs labeled $a = 3$ and $b = 4$ and hypotenuse $c = 5$. On each side, a perfect square grid is drawn: a $3 \times 3$ grid on one leg, a $4 \times 4$ grid on the other, and a $5 \times 5$ grid on the hypotenuse. The $9 + 16 = 25$ unit squares are shaded in two contrasting colours to visually confirm the Pythagorean theorem. In the background, faint bathroom floor tiles extend to the edges of the frame.]

Now you hunt for the next one. After some doodling you find $(5, 12, 13)$: $25 + 144 = 169$. Then $(8, 15, 17)$: $64 + 225 = 289$. Then $(7, 24, 25)$: $49 + 576 = 625$. Each triple satisfies the equation, each gives you a right triangle with purely whole-number sides, and none of them is a mere scaling of any other — they are *primitive*, meaning $a$, $b$, and $c$ share no common factor greater than $1$.

Here is the puzzle that will drive this entire book, and I encourage you to set it down and think before reading on:

> *Can you find* all *of these triples? Is there a systematic catalogue — a master list — that contains every primitive Pythagorean triple exactly once? And if such a list exists, what shape does it have?*

The answer turns out to be one of the most beautiful objects in all of number theory. It is not a list at all. It is a *tree*.

---

## The Tree That Grows Right Triangles

In 1934, a little-known Swedish mathematician named Berggren published a paper containing a remarkable discovery. He showed that starting from the single seed $(3, 4, 5)$ and applying three specific transformations — think of them as three "recipes" — you can grow *every* primitive Pythagorean triple exactly once.

The three recipes look like this. Given any triple $(a, b, c)$, produce three children:

$$\text{Recipe A:}\quad (a - 2b + 2c,\;\; 2a - b + 2c,\;\; 2a - 2b + 3c)$$

$$\text{Recipe B:}\quad (a + 2b + 2c,\;\; 2a + b + 2c,\;\; 2a + 2b + 3c)$$

$$\text{Recipe C:}\quad (-a + 2b + 2c,\;\; -2a + b + 2c,\;\; -2a + 2b + 3c)$$

Apply all three to the root $(3, 4, 5)$ and you get:

$$A: (5, 12, 13), \qquad B: (21, 20, 29), \qquad C: (15, 8, 17).$$

Check each one — they are all Pythagorean, all primitive, and all different. Now apply the three recipes to each of *those* nine children, and to their children, and so on, forever. The result is an infinite ternary tree — every node a right triangle, every right triangle a node — and *no triple ever appears twice*.

[ILLUSTRATION: A large, colourful ternary tree diagram. The root node is labelled $(3, 4, 5)$ and drawn as a small right triangle. Three branches descend to $(5, 12, 13)$, $(21, 20, 29)$, and $(15, 8, 17)$, colour-coded blue, red, and green respectively by which recipe generated them. A third level shows all nine grandchildren, also drawn as tiny right triangles with sides labelled. Curved arrows along each branch are labelled $A$, $B$, or $C$. The tree fans outward in a fractal pattern, with faint further levels disappearing into the background.]

Berggren's paper appeared in a Swedish journal and was largely forgotten for decades, rediscovered independently by multiple authors, and only in recent years recognised for the profound structure it conceals. That structure is the subject of this book.

---

## When Pythagoras Met Einstein

Here is where the story takes its first wild turn. Each of Berggren's three recipes can be written as multiplication by a $3 \times 3$ matrix — a grid of integers. And those three matrices share a startling property. Define the matrix

$$Q = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & -1 \end{pmatrix}$$

and let $B$ be any one of the three Berggren matrices. Then

$$B^{\mathsf{T}}\, Q\, B \;=\; Q.$$

If this equation looks familiar, it should. It is the defining equation of a *Lorentz transformation* — the same symmetry that governs Einstein's special relativity. The matrix $Q$ encodes the Minkowski metric of $(2+1)$-dimensional spacetime, and the condition $B^{\mathsf{T}} Q B = Q$ says that $B$ preserves the spacetime interval. In physics, Lorentz transformations describe how measurements of space and time change between observers moving at different velocities. In number theory, the very same transformations shuffle Pythagorean triples along the branches of the Berggren tree.

The Pythagorean equation $a^2 + b^2 - c^2 = 0$ describes a *cone* in three-dimensional space — the same cone that, in relativity, is called the *light cone*. Every Pythagorean triple is a lattice point on this cone. The Berggren matrices act as discrete Lorentz boosts, hopping from one lattice point to the next without ever leaving the cone's surface. The $3$-$4$-$5$ triangle is, secretly, a frozen beam of light.

[ILLUSTRATION: A two-panel figure. LEFT: A 3D wireframe cone in $(a, b, c)$-space defined by $a^2 + b^2 = c^2$, $c > 0$. Several Pythagorean triples are plotted as bright dots on the cone surface: $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(7,24,25)$. Curved arrows trace the Berggren transformations between them. RIGHT: The same cone drawn in relativistic notation with axes labelled $x$, $y$, $ct$, and a light ray spiralling along its surface. The visual parallel is unmistakable. A caption reads: "Same cone. Different universe."]

---

## The Hyperbolic Mosaic

The surprises compound. The Berggren tree is not merely an algebraic curiosity — it has a *geometry*. If you take the Poincaré disk model of the hyperbolic plane (think of Escher's famous *Circle Limit* woodcuts, where interlocking fish or angels shrink endlessly toward the boundary of a circle) and tile it with regions, one for each node of the Berggren tree, you get a perfect tessellation. Each Pythagorean triple occupies its own curved tile. The three children of a node are its three hyperbolic neighbours. The tree is a *map* of the hyperbolic plane, and the triples grow exponentially in size precisely because area in hyperbolic geometry grows exponentially with distance.

Follow the $B$-branch alone — $(3,4,5) \to (21,20,29) \to (119,120,169) \to (697,696,985) \to \cdots$ — and the hypotenuses obey a Pell recurrence:

$$c_{n+2} = 6\,c_{n+1} - c_n,$$

growing at the rate $(3 + 2\sqrt{2})^n$. This is the signature tempo of hyperbolic expansion — a drumbeat that Lobachevsky and Bolyai would have recognised at once.

[ILLUSTRATION: A large Poincaré disk tessellated by curved hyperbolic regions. The central tile is labelled $(3,4,5)$. The three tiles touching it are labelled $(5,12,13)$, $(21,20,29)$, $(15,8,17)$ in blue, red, and green. Tiles shrink toward the boundary in the characteristic Escher style. The overall effect should evoke *Circle Limit III*, but with number-triples replacing fish.]

---

## Cracking Numbers with Right Triangles

Now comes the practical payoff. Every Pythagorean triple $(a, b, c)$ carries within it a factorisation identity:

$$(c - b)(c + b) = a^2.$$

If you know two *different* triples that share the same leg $a$, you get two different factorisations of $a^2$ — and from those, a simple GCD computation can extract a non-trivial factor of $a$. This is, at heart, the *congruence of squares* method, the algebraic engine powering every modern sub-exponential factoring algorithm from the Quadratic Sieve to the Number Field Sieve:

> If $x^2 \equiv y^2 \pmod{n}$ but $x \not\equiv \pm y \pmod{n}$, then $\gcd(x - y,\, n)$ is a non-trivial factor of $n$.

The Berggren tree gives you a structured, deterministic way to hunt for these congruences. And the hunt gets richer as you climb into higher dimensions. A Pythagorean *quadruple* $(a, b, c, d)$ with $a^2 + b^2 + c^2 = d^2$ provides three independent factoring channels. An *octuplet* — eight integers whose squares sum to zero in the appropriate signature — provides twenty-eight. Each new dimension opens new lines of algebraic attack, and the reason traces back through the Cayley–Dickson hierarchy: from the reals to the complex numbers (two-square identity), to Hamilton's quaternions (four-square identity), to Cayley's octonions (eight-square identity). At each stage you sacrifice an algebraic property — commutativity, then associativity, then the division property itself — but you gain an exponentially richer family of factoring identities.

---

## The Map of the Journey

We began with bathroom tiles and we have ended up, in barely a few pages, brushing against Einstein's spacetime, Escher's hyperbolic mosaics, the security of internet cryptography, and the exotic eight-dimensional world of the octonions. This book tells the whole story, from the very first seed to the outermost frontier, in sixteen chapters and four acts.

**Act I — The Tree and Its Geometry** plants the Berggren tree, reveals its Lorentz symmetry, maps it onto the hyperbolic plane, and develops the shortcuts (matrix powering, inverse descent) that let you navigate it in logarithmic time rather than linear.

**Act II — The Channels** climbs the dimensional ladder from triples to quadruples to octuplets, extracts factoring identities at each level, and asks how a quantum computer might accelerate the search — Grover's algorithm shaves the classical $O(\sqrt{N})$ descent down to $O(N^{1/4})$, a saving of fifty orders of magnitude for a $200$-digit number.

**Act III — The Classics, Revisited** steps back to admire two of the greatest theorems in mathematics — the congruence-of-squares principle that unifies all modern factoring, and Fermat's Last Theorem, which asserts that the equation $a^n + b^n = c^n$ has *no* solutions for $n \geq 3$. Where $n = 2$ gives an infinite tree of solutions, $n = 3$ gives a desert — and proving that desert is truly empty required 358 years and the deepest mathematics of the twentieth century.

**Act IV — The Frontier** ventures into uncharted territory: tropical geometry (where addition becomes $\min$ and multiplication becomes $+$), GCD cascades, higher-dimensional lattice reduction, and the grand structural unification of the integer Lorentz group.

[ILLUSTRATION: A "treasure map" drawn in antique cartographic style. An island is divided into sixteen labelled regions, one per chapter. Act I is a forest of branching trees; Act II is a mountain range with ascending peaks (the Cayley–Dickson tower); Act III is ancient ruins (Fermat, Euclid); Act IV is an uncharted frontier with "Here be Dragons" scrawled near the tropical geometry region. A dotted path winds through all sixteen regions. A compass rose in the corner has $a^2 + b^2 = c^2$ inscribed on it.]

What follows, then, is the story of how a single right triangle — the humblest of geometric figures, the one you can draw with a knotted rope on a muddy riverbank — turns out to encode the symmetries of spacetime, the architecture of hyperbolic space, the factorisation of enormous integers, and the algebraic anatomy of eight-dimensional number systems. It is a story about how simple things contain multitudes, and how the deepest mathematics often hides in the most familiar places.

The $3$-$4$-$5$ triangle swallowed the universe. Let us watch it happen.
