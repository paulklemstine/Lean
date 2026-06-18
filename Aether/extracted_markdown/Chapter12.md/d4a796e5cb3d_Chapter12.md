# Chapter 12 — *The Fourth Dimension of Pythagoras: How Quadruples Crack Numbers*

> *"Three dimensions are merely an invitation. Four is where the magic starts."*

---

## A Puzzle in Four Parts

I have four wooden blocks in front of me, labelled $1$, $2$, $2$, and $3$. I square each number, add the first three results, and compare with the fourth:

$$1^2 + 2^2 + 2^2 = 1 + 4 + 4 = 9 = 3^2.$$

A perfect match. The sum of three squares equals the square of the fourth. Is this a happy coincidence, or the first clue in a detective story that stretches from ancient geometry into the frontier of modern cryptography?

Here is your opening puzzle, and I encourage you to set this book down and wrestle with it before reading on:

> *Find four positive integers $(a, b, c, d)$ such that $a^2 + b^2 + c^2 = d^2$ and $d = 9$. There are (at least) two solutions. Can you find both?*

If you discovered $(1, 4, 8, 9)$ — since $1 + 16 + 64 = 81 = 9^2$ — congratulations. If you also found $(4, 4, 7, 9)$ — since $16 + 16 + 49 = 81$ — you have a sharp eye indeed. Hold on to both of these; they will become weapons later.

A four-tuple of integers $(a, b, c, d)$ satisfying

$$a^2 + b^2 + c^2 = d^2$$

is called a *Pythagorean quadruple*. If the classical Pythagorean triple $a^2 + b^2 = c^2$ describes a right triangle in the flat plane, then a Pythagorean quadruple describes something grander: a diagonal of a rectangular box in three-dimensional space, or — if you tilt your head just right — a point on the surface of a *sphere* in four-dimensional space. The integer solutions to $a^2 + b^2 + c^2 = d^2$ are the lattice points sitting exactly on the four-dimensional hypersphere of radius $d$.

Here is a small gallery of primitive Pythagorean quadruples — those with no common factor shared among all four entries — sorted by the hypotenuse $d$:

| $a$ | $b$ | $c$ | $d$ | Check |
|-----|-----|-----|-----|-------|
| 1   | 2   | 2   | 3   | $1+4+4=9$ |
| 2   | 3   | 6   | 7   | $4+9+36=49$ |
| 1   | 4   | 8   | 9   | $1+16+64=81$ |
| 4   | 4   | 7   | 9   | $16+16+49=81$ |
| 2   | 6   | 9   | 11  | $4+36+81=121$ |
| 6   | 6   | 7   | 11  | $36+36+49=121$ |
| 3   | 4   | 12  | 13  | $9+16+144=169$ |
| 2   | 10  | 11  | 15  | $4+100+121=225$ |
| 1   | 12  | 12  | 17  | $1+144+144=289$ |
| 8   | 9   | 12  | 17  | $64+81+144=289$ |

[ILLUSTRATION: A beautifully arranged table of the first 15–20 primitive Pythagorean quadruples, sorted by $d$, displayed inside a stylised four-dimensional hypercube wireframe. Each quadruple is a point on the surface of the hypersphere, with dotted lines radiating from the origin to each lattice point.]

Stare at the table and notice two things. First, some values of $d$ appear more than once — both $d = 9$ and $d = 11$ admit two distinct representations. Second, the entries seem to have no tidy pattern; they sprout unpredictably, like mushrooms after rain. Yet behind this apparent chaos lies a rigid algebraic structure, and that structure turns out to be a *factoring engine*.

The historical pedigree runs deep. Euler investigated sums of three squares in the 1750s; Jacobi proved stunning formulas for counting representations in the 1830s; Lagrange's celebrated four-square theorem — every positive integer is a sum of four squares — lurks just around the corner. But our focus today is different. We will use quadruples not to *represent* numbers, but to *crack them open*.

[ILLUSTRATION: Side-by-side comparison. Left: a right triangle inscribed on a flat grid, labelled $a^2 + b^2 = c^2$, representing a classical Pythagorean triple. Right: a tetrahedron-like projection of a point on a 3-sphere, with three mutually perpendicular "leg" axes and the hypotenuse $d$ drawn as the radial distance from the origin, representing $a^2 + b^2 + c^2 = d^2$. The visual emphasises the leap from two dimensions to three (and implicitly four).]

---

## The Magician's Bridge

Here is a parlour trick that would have delighted Euler. Take the quadruple $(2, 3, 6, 7)$ and perform a single algebraic rearrangement:

$$a^2 + b^2 = d^2 - c^2 = (d - c)(d + c).$$

With our numbers: $4 + 9 = 49 - 36 = (7 - 6)(7 + 6) = 1 \times 13 = 13$. We have just expressed the number $13$ — a prime! — as a *product of two factors* derived purely from the geometry of a four-dimensional lattice point.

This is the **difference-of-squares identity** for Pythagorean quadruples, and it is the bridge between geometry and arithmetic:

$$\boxed{a^2 + b^2 = (d - c)(d + c).}$$

The proof is one line: since $a^2 + b^2 + c^2 = d^2$, we subtract $c^2$ from both sides and factor the right. The simplicity of the proof is inversely proportional to its power.

Why should you care? Because *every* modern factoring algorithm — the Quadratic Sieve, the Number Field Sieve, the methods that underpin the security of your bank account — boils down, at its mathematical heart, to finding a "difference of squares." Pythagorean quadruples *hand you one for free.*

[ILLUSTRATION: A "bridge" diagram. On the left bank stands a sphere labelled "$a^2 + b^2 + c^2 = d^2$" (Geometry). On the right bank stands a multiplication sign between two parenthetical expressions $(d-c)$ and $(d+c)$ (Arithmetic). The bridge itself is drawn as a stone arch formed by the equals sign. Below the arch, a river flows carrying the symbols $a^2 + b^2$ on its current.]

Let us see this bridge in action with our two quadruples sharing $d = 9$:

- From $(1, 4, 8, 9)$: $(9 - 8)(9 + 8) = 1 \times 17 = 17$. Check: $1 + 16 = 17$. ✓
- From $(4, 4, 7, 9)$: $(9 - 7)(9 + 7) = 2 \times 16 = 32$. Check: $16 + 16 = 32$. ✓

Same hypotenuse, wildly different factoring behaviour! The first quadruple produces a trivial factorisation ($1 \times 17$), while the second produces a rich one ($2 \times 16$). This asymmetry — the fact that different representations of the same number yield different factorisations — is the seed of a powerful method. But we need more machinery before we can harvest it.

---

## The Master Key

I now hand you four dials labelled $m$, $n$, $p$, and $q$. Turn them to any integer settings you like, and I will hand you a valid Pythagorean quadruple — *guaranteed*. Here is the machine:

$$\begin{aligned}
a &= m^2 + n^2 - p^2 - q^2, \\[4pt]
b &= 2(mq + np), \\[4pt]
c &= 2(nq - mp), \\[4pt]
d &= m^2 + n^2 + p^2 + q^2.
\end{aligned}$$

Try $m = 1$, $n = 1$, $p = 1$, $q = 0$. Then $a = 1 + 1 - 1 - 0 = 1$, $b = 2(0 + 1) = 2$, $c = 2(0 - 1) = -2$, $d = 1 + 1 + 1 + 0 = 3$. Taking absolute values: $(1, 2, 2, 3)$ — our very first quadruple! The machine works.

[ILLUSTRATION: A "quadruple machine" drawn as a vintage brass-and-mahogany mechanical device with four labelled input dials ($m$, $n$, $p$, $q$) on the left and four output displays ($a$, $b$, $c$, $d$) on the right. Ornate gear trains connect inputs to outputs, with tiny placards beside each gear showing the parametric formulas. A worked example ($m=1, n=1, p=1, q=0$) is traced through the machine with arrows, producing the output $(1, 2, 2, 3)$.]

Why does it always work? Expand $a^2 + b^2 + c^2$ and $d^2$ and watch the algebra conspire. Every cross-term in $a^2 + b^2 + c^2$ cancels its partner, and what remains is $(m^2 + n^2 + p^2 + q^2)^2 = d^2$. It is a satisfying exercise in bookkeeping — not deep, but airtight.

The hypotenuse reveals a beautiful inner structure:

$$d = (m^2 + n^2) + (p^2 + q^2).$$

The hypotenuse is a *sum of two sums-of-two-squares*. This is precisely the decomposition that Euler exploited in the eighteenth century to factor large numbers. The four parameters $(m, n, p, q)$ look suspiciously like the components of a *quaternion* — Hamilton's four-dimensional generalisation of complex numbers — and the resemblance is no accident. We are glimpsing the deep algebraic structure that governs multiplication in four dimensions.

[ILLUSTRATION: A number-line diagram showing $d$ as a segment, decomposed into two coloured sub-segments: $m^2 + n^2$ (shaded blue) and $p^2 + q^2$ (shaded red). Each sub-segment is further subdivided into its two square components ($m^2$ and $n^2$ in lighter and darker blue; $p^2$ and $q^2$ in lighter and darker red), with numerical labels for a specific example.]

---

## The Collision Detector

Now we arrive at the heart of the chapter. Recall that $81 = 9^2$ can be written as a sum of three squares in two different ways:

$$81 = 1^2 + 4^2 + 8^2 = 4^2 + 4^2 + 7^2.$$

Is this an accident — or a weapon?

It is a weapon. When two Pythagorean quadruples share the same hypotenuse $d$, their components must satisfy a rigid algebraic relationship. If $(a_1, b_1, c_1, d)$ and $(a_2, b_2, c_2, d)$ are both valid quadruples, then subtracting one equation from the other gives:

$$(c_1^2 - c_2^2) = (a_2^2 - a_1^2) + (b_2^2 - b_1^2),$$

or in its lethal factored form:

$$(c_1 - c_2)(c_1 + c_2) = (a_2 - a_1)(a_2 + a_1) + (b_2 - b_1)(b_2 + b_1).$$

The word "collision" is apt. In cryptography, a *collision* occurs when two different inputs produce the same output — and finding collisions is the engine of attack. Here, two different triples of squares "collide" at the same target $d^2$, and the collision identity extracts arithmetic information about $d$.

[ILLUSTRATION: Two different winding paths on a hilly landscape converge on the same hilltop labelled $d^2 = 81$. Path 1 is labelled with the components $(1, 4, 8)$ and Path 2 with $(4, 4, 7)$. Where the paths meet at the summit, a magnifying glass reveals the number $15$ at the junction, and the prime factor $3$ escapes like a firefly into the night air.]

Let us verify with $d = 9$. Our two quadruples are $(1, 4, 8, 9)$ and $(4, 4, 7, 9)$:

$$(8 - 7)(8 + 7) = 1 \times 15 = 15,$$
$$(4^2 - 1^2) + (4^2 - 4^2) = 15 + 0 = 15. \quad \checkmark$$

Now here is the payoff: $\gcd(15, 81) = 3$. From the collision of two representations, we have extracted a *non-trivial factor* of $81 = 3^4$. The number has been cracked.

---

## Stretching the Quadruple

Before we go further, a brief but important observation. If $(1, 2, 2, 3)$ is a Pythagorean quadruple, then so is $(10, 20, 20, 30)$ — just multiply everything by $10$. Trivial? Perhaps. But this "trivial" observation has teeth.

The **Scaling Lemma** says: if $(a, b, c, d)$ satisfies $a^2 + b^2 + c^2 = d^2$, then for any integer $k$,

$$(ka)^2 + (kb)^2 + (kc)^2 = k^2(a^2 + b^2 + c^2) = k^2 d^2 = (kd)^2.$$

Any common factor $g = \gcd(a, b, c, d)$ can therefore be extracted, reducing us to a *primitive* quadruple where no such common factor exists. Conversely, if $d$ is composite, we can sometimes *engineer* a scaled quadruple that leaks information about $d$'s factors.

[ILLUSTRATION: A small tetrahedron labelled $(1, 2, 2, 3)$ next to a geometrically similar but larger tetrahedron $(3, 6, 6, 9)$ obtained by scaling by $k = 3$. Dotted lines connect corresponding vertices to show the similarity. A label reads $\gcd(3, 6, 6, 9) = 3$.]

---

## The Imaginary Witness

In 1832, Carl Friedrich Gauss published a revolutionary paper on what he called "complex integers" — numbers of the form $a + bi$, where $a$ and $b$ are ordinary integers and $i = \sqrt{-1}$. He showed that these *Gaussian integers* possess their own arithmetic of primes and factors, as rich and intricate as the arithmetic of the counting numbers. What Gauss could not have anticipated is that his invention would become a *factoring weapon* through Pythagorean quadruples, two centuries later.

The *norm* of a Gaussian integer $z = a + bi$ is

$$N(z) = |z|^2 = a^2 + b^2.$$

Now recall the difference-of-squares identity: $a^2 + b^2 = (d - c)(d + c)$. In the language of Gaussian integers, this becomes:

$$N(a + bi) = (a + bi)(a - bi) = (d - c)(d + c).$$

The same number — $a^2 + b^2$ — has been factored in *two different number systems*. On the left, it splits into conjugate Gaussian integers; on the right, into a pair of ordinary integers. Comparing these two factorisations is exactly the trick Euler used to prove special cases of Fermat's theorems, and it is the technique that modern algebraic number theory has elevated into a general-purpose engine.

[ILLUSTRATION: The Gaussian integer plane (complex plane with integer grid points). A vector from the origin to the point $(a, b) = (2, 3)$ is drawn, with a square of area $13$ constructed on it. Beside it, a rectangle of dimensions $1 \times 13$ (since $d - c = 1$, $d + c = 13$ for the quadruple $(2, 3, 6, 7)$) is drawn with the same area, shaded identically. An equals sign connects the two shapes, and the caption reads: "Same area, different shapes — same number, different factorisations."]

Think of it geometrically. The Gaussian integer $a + bi$ is a vector in the plane. Its norm $a^2 + b^2$ is the area of the square built on that vector. The factoring identity says: the area of that square equals the area of the rectangle with sides $(d - c)$ and $(d + c)$. Two shapes, same area — two factorisations, same number. And where two factorisations meet, factors are revealed.

---

## The Prime Inquisitor

We have accumulated a toolbox of identities. Now we sharpen them into a blade.

Suppose a prime $p$ divides the product $(d - c)(d + c) = a^2 + b^2$. Then by Euclid's Lemma — that ancient, indispensable lever — $p$ must divide at least one of the two factors:

$$p \mid (d - c)(d + c) \quad \Longrightarrow \quad p \mid (d - c) \quad \text{or} \quad p \mid (d + c).$$

[ILLUSTRATION: A lever diagram in the style of Archimedes. A beam balances on a triangular fulcrum labelled "Euclid's Lemma." On the left end sits the product $(d-c)(d+c)$; on the right, a prime $p$ exerts force. Two arrows branch from $p$ toward the two factors, labelled "must divide this one… or that one." The background shows a Mediterranean harbour, a nod to Syracuse.]

Now notice: if $p$ divides *both* $(d - c)$ and $(d + c)$, then it divides their sum $(d - c) + (d + c) = 2d$ and their difference $(d + c) - (d - c) = 2c$. So either $p$ divides $d$ — which is what we want — or $p = 2$ and we learn something about the parity of the components.

Here is a worked example. From the quadruple $(2, 3, 6, 7)$: $a^2 + b^2 = 13$, which is prime. So $13 \mid (7 - 6) = 1$ or $13 \mid (7 + 6) = 13$. The latter holds, and $\gcd(13, 7) = 1$ — confirming that $7$ is coprime to $13$ and therefore (in this case) prime.

For a *composite* hypotenuse, the game changes. If $d = 15$ and we find a quadruple where $a^2 + b^2$ contains a factor $p$ with $1 < p < 15$, and if $p \mid (d - c)$ or $p \mid (d + c)$, we can compute $\gcd(p, d)$ and potentially extract a non-trivial factor of $15$. The prime divisor dichotomy is the *lever* that pries open the factorisation of $d$.

---

## The Mod Squad

Quick: can $7^2 + 7^2 + 7^2$ be a perfect square? Compute: $49 + 49 + 49 = 147$. Is $147$ a perfect square? No — $12^2 = 144$ and $13^2 = 169$, so $147$ falls in the gap. But *why* not? Is there a deeper obstruction than mere numerical bad luck?

There is, and it lives in the world of modular arithmetic. Every perfect square satisfies

$$n^2 \equiv 0 \text{ or } 1 \pmod{4}.$$

(Check: $0^2 = 0$, $1^2 = 1$, $2^2 = 4 \equiv 0$, $3^2 = 9 \equiv 1$.) Therefore $a^2 + b^2 + c^2$ modulo $4$ can only take the values $0, 1, 2,$ or $3$ — but since $d^2 \equiv 0$ or $1 \pmod{4}$, the sum $a^2 + b^2 + c^2$ is forced to be $\equiv 0$ or $1 \pmod{4}$ as well. The residue $3 \pmod{4}$ is *forbidden*.

Now $7^2 + 7^2 + 7^2 = 3 \times 49 \equiv 3 \times 1 = 3 \pmod{4}$. The mod $4$ obstruction catches it red-handed.

[ILLUSTRATION: A $4 \times 4$ grid where rows represent values of $a^2 \bmod 4$ (labelled $0$ and $1$) and columns represent $b^2 \bmod 4$. Each cell is subdivided for $c^2 \bmod 4$. Cells where the sum $\equiv 0$ or $1 \pmod{4}$ are shaded green (valid); cells with sum $\equiv 2$ or $3$ are shaded red (forbidden). The checkerboard pattern reveals the hidden structure of modular constraints on Pythagorean quadruples.]

This is a shadow of a much deeper theorem. Legendre proved that a positive integer $n$ is a sum of three squares if and only if $n$ is *not* of the form $4^k(8m + 7)$. This classical result constrains which integers can appear as $d^2$ — and therefore which hypotenuses $d$ are amenable to the quadruple method.

When all four components $a, b, c, d$ are even, we can write $a = 2a'$, $b = 2b'$, $c = 2c'$, $d = 2d'$, and the equation descends:

$$a'^2 + b'^2 + c'^2 = d'^2.$$

The quadruple shrinks by a factor of two, and we can repeat until at least one component is odd. This "even descent" is the mod $2$ analogue of extracting common factors, and it ensures that the primitive quadruples — the irreducible building blocks — always have at least one odd component.

---

## The Number Cruncher's Workbench

The mathematician's motto: *trust, but verify.* Let us roll up our sleeves, sharpen our pencils, and put every theorem in this chapter to the test.

**Difference-of-squares check:**

| Quadruple | $(d-c)(d+c)$ | $a^2 + b^2$ | Match? |
|-----------|---------------|-------------|--------|
| $(1,2,2,3)$ | $(1)(5) = 5$ | $1 + 4 = 5$ | ✓ |
| $(2,3,6,7)$ | $(1)(13) = 13$ | $4 + 9 = 13$ | ✓ |
| $(1,4,8,9)$ | $(1)(17) = 17$ | $1 + 16 = 17$ | ✓ |
| $(4,4,7,9)$ | $(2)(16) = 32$ | $16 + 16 = 32$ | ✓ |

**Parametric reconstruction:** For the quadruple $(2, 3, 6, 7)$, set $m = 1$, $n = 1$, $p = 0$, $q = 1$. Then:

$$a = 1 + 1 - 0 - 1 = 1, \quad b = 2(1 + 0) = 2, \quad c = 2(1 - 0) = 2, \quad d = 1 + 1 + 0 + 1 = 3.$$

Hmm — that gives $(1, 2, 2, 3)$, not $(2, 3, 6, 7)$. Try $m = 1$, $n = 1$, $p = 1$, $q = 1$:

$$a = 1 + 1 - 1 - 1 = 0, \quad b = 2(1 + 1) = 4, \quad c = 2(1 - 1) = 0, \quad d = 4.$$

That gives $(0, 4, 0, 4)$ — trivial. The quadruple $(2, 3, 6, 7)$ requires $m = 2$, $n = 1$, $p = 1$, $q = 1$:

$$a = 4 + 1 - 1 - 1 = 3, \quad b = 2(2 + 1) = 6, \quad c = 2(1 - 2) = -2, \quad d = 4 + 1 + 1 + 1 = 7.$$

So the machine produces $(3, 6, -2, 7)$, which — after rearranging and taking absolute values — is $(2, 3, 6, 7)$. ✓ The parametric machine generates every quadruple, but sometimes in disguise.

**Gaussian norm:** For $(2, 3, 6, 7)$, the Gaussian integer is $2 + 3i$ with norm $4 + 9 = 13 = (7 - 6)(7 + 6)$. ✓

[ILLUSTRATION: A "workbench" scene: a wooden desk scattered with papers showing the four main quadruples, pencils, and a magnifying glass hovering over the collision identity. A chalkboard in the background displays the parametric machine. On the desk sits a vintage mechanical calculator — a Curta or Brunsviga — whose display reads "GCD = 3".]

---

### Challenges for the Reader

I leave you with eight puzzles, arranged from aperitif to entrée:

1. Find a Pythagorean quadruple with $d = 15$ and use it to extract a non-trivial factor of $15$.
2. Find *two* quadruples with $d = 21$ and apply the collision theorem. What factor emerges?
3. Verify the parametric formula for $m = 2$, $n = 1$, $p = 1$, $q = 1$ and confirm that $a^2 + b^2 + c^2 = d^2$.
4. Prove that no Pythagorean quadruple exists with $a = b = c$ and $d$ prime. *(Hint: think modulo $3$.)*
5. Find the smallest $d$ admitting three or more distinct primitive quadruples.
6. Use the Gaussian-integer bridge to show that $5 = (2 + i)(2 - i)$, and connect this to a quadruple with $a^2 + b^2 = 5$.
7. Determine all $d \le 20$ for which at least one Pythagorean quadruple exists.
8. *(Open)* Is there an efficient algorithm to enumerate all primitive Pythagorean quadruples with hypotenuse $d$ in time polynomial in $\log d$?

[ILLUSTRATION: A histogram showing the number of primitive Pythagorean quadruples for each value of $d$ from $1$ to $50$. Bars are colour-coded: blue for prime $d$, red for composite $d$. The visual reveals that composite values of $d$ tend to admit more representations — the very asymmetry that makes the quadruple factoring method possible.]

---

The theorems of this chapter are not merely curiosities. They constitute a *bridge* — a stone arch over a deep river — between the ancient world of Pythagorean number theory and the modern world of cryptographic factoring. The difference-of-squares identity converts geometry into arithmetic. The parametric machine generates an inexhaustible supply of quadruples. The collision theorem weaponises multiple representations. And the Gaussian integers fuse it all together through the alchemy of imaginary numbers.

In the next chapter, we will cross that bridge and construct a full *GCD cascade* — a systematic procedure for extracting factors from multiple colliding representations. The quadruples we have met today will become the ammunition; the cascade will be the cannon.

But for now, pick up your pencil, choose a hypotenuse, and start hunting for quadruples. The fourth dimension is waiting.
