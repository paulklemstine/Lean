# When Light Meets Number Theory: The Hidden Mathematics of Discrete Spacetime

*How an ancient equation about squares connects photons, topology, and the deepest program in modern mathematics*

---

**Imagine a universe where space and time come in indivisible chunks — tiny integer-sized pixels rather than a smooth continuum.** In such a world, a beam of light wouldn't glide along a silky curve. Instead, each photon would hop from one lattice point to the next, constrained by the same geometry Einstein described, but living on a grid.

What kind of mathematics would govern this discrete light? The answer turns out to be hiding in plain sight — in an equation that ancient Greek mathematicians would have recognized.

## An Old Equation with a New Identity

You probably remember the Pythagorean theorem: $a^2 + b^2 = c^2$. Its whole-number solutions — like $(3, 4, 5)$ and $(5, 12, 13)$ — have been studied for over 4,000 years, appearing on Babylonian clay tablets dating to 1800 BCE.

Now add one more dimension:

$$a^2 + b^2 + c^2 = d^2$$

This is the Pythagorean quadruple equation. Solutions include $(1, 2, 2, 3)$ — check it: $1 + 4 + 4 = 9$ — and $(2, 3, 6, 7)$, where $4 + 9 + 36 = 49$. So far, so elementary.

But here's the twist. Move the $d^2$ to the other side:

$$a^2 + b^2 + c^2 - d^2 = 0$$

This is no longer just an equation about numbers. It's the equation of the **light cone** in Einstein's spacetime — the surface separating the reachable future from the inaccessible elsewhere, with $a, b, c$ as space coordinates and $d$ as time. Every solution is a direction that light can travel.

Integer solutions to this equation are what we call **arithmetic photons**: discrete light rays on a lattice universe.

## Five Surprising Bridges

What makes arithmetic photons so remarkable is not the equation itself — it's how many different areas of mathematics they secretly connect. Our research has identified five "bridges" linking seemingly unrelated fields through this single equation.

### Bridge 1: From Gauss to Einstein

The great German mathematician Carl Friedrich Gauss spent years studying which numbers can be written as sums of three squares. His results — involving deep ideas about algebraic number fields and "class numbers" — turn out to be exactly the tools you need to count arithmetic photons at each energy level.

The number of photons at energy $d$ is $r_3(d^2)$: the number of ways to write $d^2$ as a sum of three squares. Gauss showed this connects to the arithmetic of imaginary quadratic fields — abstract algebraic structures that seemed to have nothing to do with physics.

### Bridge 2: The Hopf Connection

In the 1930s, topologist Heinz Hopf discovered a beautiful mapping from a 3-dimensional sphere to a 2-dimensional sphere ($S^3 \to S^2$) that became one of the foundational objects in algebraic topology. This "Hopf fibration" shows that the 3-sphere can be decomposed into circles, each sitting over a point on the 2-sphere.

Incredibly, the standard formula for generating Pythagorean quadruples from four parameters $(m, n, p, q)$ IS the Hopf map, restricted to integers. Each quadruple corresponds to a rational point on the sphere, and the parameters producing the same direction form a Hopf fiber. The topology of photon directions is the topology of the Hopf bundle.

### Bridge 3: Quaternion Composition

In 1843, William Rowan Hamilton carved the equations $i^2 = j^2 = k^2 = ijk = -1$ into a bridge in Dublin, inventing the quaternions — a four-dimensional number system where multiplication isn't commutative ($ij = k$ but $ji = -k$).

The Euler four-square identity — that a product of two sums of four squares is again a sum of four squares — is simply the statement that quaternion norm is multiplicative: $|q_1 \cdot q_2| = |q_1| \cdot |q_2|$. This gives arithmetic photons a composition law, inherited from quaternion multiplication.

### Bridge 4: Every Number Gets to Play

Here's a contrast that reveals how rich the four-variable equation is. For the original Pythagorean triples $a^2 + b^2 = c^2$, only certain numbers $c$ can be the hypotenuse — you need at least one prime factor congruent to 1 modulo 4 (like 5, 13, or 17). The number 6, for instance, is never a hypotenuse.

But for quadruples, every positive integer $d$ is a hypotenuse. Always. The proof is elegant: $d^2$ modulo 8 can only be 0, 1, or 4 — never 7. And Legendre showed that a number is a sum of three squares precisely when it's not of the form $4^a(8b + 7)$. Since $d^2$ avoids this forbidden form, it's always expressible as $a^2 + b^2 + c^2$.

### Bridge 5: The Deepest Program in Mathematics

This is where things get truly profound. The function $r_3(n)$ — counting how many ways $n$ is a sum of three squares — turns out to be the Fourier coefficient of a **modular form**: the cube of the Jacobi theta function $\theta_3(q)^3$, which has a very specific weight ($3/2$) and level (4).

In 1973, Goro Shimura discovered a correspondence that lifts modular forms of half-integral weight (like $3/2$) to modular forms of integral weight (like 2). This Shimura lift places the photon counting function squarely within the **Langlands program** — widely considered the deepest and most ambitious program in modern mathematics, connecting number theory, algebra, geometry, and analysis through a grand web of L-functions and automorphic representations.

In other words: counting integer points on a sphere is connected, through a chain of deep theorems, to the same mathematical structures that Andrew Wiles used to prove Fermat's Last Theorem.

## Machine-Verified Mathematics

One distinctive aspect of this research is its use of **formal verification**. We proved the core theorems using Lean 4, a programming language that doubles as a proof assistant. Every logical step is checked by a computer, leaving no room for error.

This matters because the bridges between arithmetic photons and other areas rest on precise algebraic identities and structural connections. The computer verified, for instance, that the Hopf map always produces valid Pythagorean quadruples, that quaternion norm is multiplicative, that $d^2$ is never $7 \pmod{8}$, and that null vectors sum to null vectors only when they're Minkowski-orthogonal.

In total, approximately 450 lines of formal proof were produced across three files, covering 50+ theorems — all compiling without any unproven assumptions.

## The Dark Matter of Integer Spacetime

One of our computational findings echoes real physics in a surprising way. If you pick a random integer 4-vector $(a, b, c, d)$ with components up to some bound $N$, what fraction will be arithmetic photons?

Almost none.

The photon fraction decays as $1/N^2$. At $N = 20$, only about 0.02% of integer vectors land on the light cone. The vast majority are "timelike" (massive particles) or "spacelike" (forbidden tachyons). In the integer universe, photons are vanishingly rare — a kind of arithmetical dark matter problem, where most of the "mass" of the lattice is tied up in non-photonic vectors.

## Why This Matters

The arithmetic photon paradigm isn't just a mathematical curiosity. It touches on real questions at the frontier of physics and mathematics:

**For physics**: Multiple approaches to quantum gravity — including loop quantum gravity and causal set theory — propose that spacetime is fundamentally discrete. If so, the propagation of light literally becomes a number theory problem. Understanding which lattice vectors are null, and how many there are, could constrain models of discrete spacetime.

**For mathematics**: The connection to the Langlands program suggests that the humble equation $a^2 + b^2 + c^2 = d^2$ sits at a nexus point connecting vast swaths of modern mathematics. Every advance in the Langlands program potentially tells us something new about photon counting, and vice versa.

**For quantum information**: The rational points on the sphere $S^2$ that arise from arithmetic photons are the same rational points on the Bloch sphere — the fundamental state space of a quantum bit. The Clifford group, which generates "easy" quantum computation, preserves these rational points. There may be deep connections between arithmetic photon geometry and quantum error correction waiting to be discovered.

## What We Don't Know

Several tantalizing questions remain open:

- Is the "photon graph" connected? If you connect lattice points whenever their displacement is a Pythagorean quadruple, can you always find a path between any two points?
- What happens in higher dimensions? The equations $\sum_{i=1}^{n-1} x_i^2 = x_n^2$ define light cones in arbitrary dimensions, but the algebraic structures change dramatically (octonions in $7{+}1$ dimensions, for instance).
- Can the Shimura lift of $\theta_3^3$ be made fully explicit — producing concrete weight-2 eigenforms whose L-functions we can study in detail?

## A Number-Theoretic Universe?

Perhaps the most provocative implication of the arithmetic photon paradigm is philosophical. If a universe on a lattice has physics governed by theorems about sums of squares, class numbers, and modular forms, then the distinction between "physics" and "number theory" dissolves.

In such a universe, the speed of light isn't a physical constant — it's a mathematical one, built into the quadratic form. Lorentz invariance isn't a symmetry of nature — it's a symmetry of integer arithmetic. And the deep structures of the Langlands program aren't abstract mathematical constructs — they're the operating system of reality.

We may not live in such a universe. But the fact that a single equation, known since antiquity, connects so many of the deepest ideas in modern mathematics is itself a kind of light — illuminating hidden connections in the landscape of human knowledge.

---

*The formal proofs, computational visualizations, and full research paper are available in the project repository.*
