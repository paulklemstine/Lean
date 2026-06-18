# Chapter 12 — *The Fourth Dimension of Pythagoras: How Quadruples Crack Numbers*

---

## A Puzzle in Four Parts

Here are four wooden blocks. Carved into their faces are the numbers $1$, $2$, $2$, and $3$. Square them: $1$, $4$, $4$, $9$. Add the first three: $1 + 4 + 4 = 9$. Compare with the last: $9 = 3^2$. A perfect match — the sum of three squares equals the fourth square.

A coincidence? Try another set: $(2, 3, 6, 7)$. Check: $4 + 9 + 36 = 49 = 7^2$. There it is again.

Now here is your opening puzzle, and I invite you to set this book aside for five minutes with a pencil:

> *Find two different quartets of positive integers $(a, b, c, d)$ such that $a^2 + b^2 + c^2 = d^2$ and $d = 9$.*

There are exactly two solutions (up to rearranging $a$, $b$, $c$): one is $(1, 4, 8, 9)$ and the other is $(4, 4, 7, 9)$. Verify them: $1 + 16 + 64 = 81 = 9^2$, and $16 + 16 + 49 = 81 = 9^2$. Both roads lead to $81$.

Keep those two quartets in your pocket. They will be the key exhibits in a detective story about how the geometry of four-dimensional space can prise a number apart into its prime factors.

A four-tuple $(a, b, c, d)$ of integers satisfying

$$a^2 + b^2 + c^2 = d^2$$

is called a *Pythagorean quadruple*. Where the classical Pythagorean triple $(a, b, c)$ satisfying $a^2 + b^2 = c^2$ describes a right triangle in the plane, a quadruple describes something grander: a point on a *sphere* in four-dimensional space. The integer $d$ is the radius — the four-dimensional "hypotenuse" — and the triple $(a, b, c)$ marks a lattice point on the sphere of radius $d$ centred at the origin of $\mathbb{Z}^3$. Every such lattice point is a gate into the arithmetic of $d$.

Here, for your browsing pleasure, is a gallery of small primitive quadruples (those with $\gcd(a, b, c, d) = 1$), sorted by hypotenuse:

| $a$ | $b$ | $c$ | $d$ |
|-----|-----|-----|-----|
| 1   | 2   | 2   | 3   |
| 2   | 3   | 6   | 7   |
| 1   | 4   | 8   | 9   |
| 4   | 4   | 7   | 9   |
| 1   | 2   | 10  | 10* |
| 2   | 6   | 9   | 11  |
| 6   | 6   | 7   | 11  |
| 3   | 4   | 12  | 13  |
| 2   | 5   | 14  | 15  |
| 1   | 10  | 10  | 15* |
| 10  | 10  | 5   | 15* |
| 2   | 10  | 11  | 15  |

(*Some entries have $\gcd > 1$; they are included for illustration.)

Stare at that table and a pattern begins to emerge — or rather, a conspicuous *absence* of pattern. The quadruples scatter unpredictably, yet they are bound by iron laws of algebra. The rest of this chapter is devoted to uncovering those laws, and to showing how they forge a surprising bridge from ancient geometry to the modern art of factoring large numbers.

[ILLUSTRATION: A beautifully arranged table of the first 15–20 primitive Pythagorean quadruples, sorted by $d$, displayed inside a stylised four-dimensional hypercube wireframe. Each quadruple is a point on the surface of the hypersphere, with dotted lines radiating from the origin to each lattice point. The wireframe is drawn in thin silver lines, the lattice points as glowing coloured spheres.]

[ILLUSTRATION: Side-by-side comparison. Left: a right triangle inscribed on a flat integer grid, legs $a$ and $b$, hypotenuse $c$, representing $a^2+b^2=c^2$. Right: a tetrahedron-like projection of a point on a 3-sphere, with three "leg" axes drawn in perspective and the hypotenuse $d$ shown as the radial distance from the origin. Both diagrams share the same visual style, emphasising the dimensional jump from two legs to three.]

---

## The Magician's Bridge

"I can factor $13$," announces the magician, "using nothing but the Pythagorean theorem in four dimensions." She writes the quadruple $(2, 3, 6, 7)$ on the blackboard and performs a single algebraic flourish:

$$d^2 - c^2 = a^2 + b^2.$$

Since $d^2 - c^2$ factors as a difference of squares, we have

$$(d - c)(d + c) = a^2 + b^2.$$

For our quadruple: $(7 - 6)(7 + 6) = 1 \times 13 = 13 = 4 + 9 = 2^2 + 3^2$. The number $13$ has been *expressed* as both a product and a sum of two squares, and the quadruple handed us this factoring identity on a silver tray.

This is the *Magician's Bridge*, and it is the single most important identity in this chapter:

$$(d - c)(d + c) = a^2 + b^2.$$

It links the *geometric* world (the sphere $a^2 + b^2 + c^2 = d^2$) to the *arithmetic* world (the factoring of $a^2 + b^2$ into two integer pieces). Every Pythagorean quadruple, no matter how large, crosses this bridge automatically.

Let us test it on the two quadruples sharing hypotenuse $d = 9$:

- **Quadruple $(1, 4, 8, 9)$:** $(9 - 8)(9 + 8) = 1 \times 17 = 17 = 1 + 16 = 1^2 + 4^2$. The factor pair is $1$ and $17$ — not terribly useful for cracking $9$, since $17$ is coprime to $9$.

- **Quadruple $(4, 4, 7, 9)$:** $(9 - 7)(9 + 7) = 2 \times 16 = 32 = 16 + 16 = 4^2 + 4^2$. The factor pair is $2$ and $16$, and $\gcd(16, 9) = 1$ while $\gcd(2, 9) = 1$ as well. But notice: $32 = 2^5$, and this *different* factoring behaviour from the same hypotenuse is itself a clue.

Same hypotenuse, wildly different bridge crossings! The art of factoring via quadruples lies in choosing — or engineering — the *right* quadruple.

[ILLUSTRATION: A stone-arch bridge spanning a river. On the left bank, a sphere labelled "$a^2 + b^2 + c^2 = d^2$" with the word GEOMETRY. On the right bank, a multiplication sign between two parenthetical expressions $(d-c)$ and $(d+c)$ with the word ARITHMETIC. The bridge's keystone is a large equals sign. Below the arch, water flows carrying the symbols $a^2 + b^2$ like leaves on a current.]

---

## The Master Key

Now for the conjurer's real trick. I will give you four knobs — label them $m$, $n$, $p$, $q$ — and a machine. Turn the knobs to any integer settings you like, and the machine will produce a valid Pythagorean quadruple. *Guaranteed.*

The machine's blueprint:

$$\boxed{\begin{aligned}
a &= m^2 + n^2 - p^2 - q^2, \\
b &= 2(mq + np), \\
c &= 2(nq - mp), \\
d &= m^2 + n^2 + p^2 + q^2.
\end{aligned}}$$

Try it with $m = 1$, $n = 1$, $p = 1$, $q = 0$:

$$a = 1 + 1 - 1 - 0 = 1, \quad b = 2(0 + 1) = 2, \quad c = 2(0 - 1) = -2, \quad d = 1 + 1 + 1 + 0 = 3.$$

The quadruple $(1, 2, -2, 3)$ — and since we care about squares, the sign of $c$ is irrelevant: $(1, 2, 2, 3)$. Our very first example, rebuilt from the machine.

Why does this always work? Expand $a^2 + b^2 + c^2$ and $d^2$ separately. Both reduce, after a page of honest bookkeeping, to $(m^2 + n^2 + p^2 + q^2)^2$. The identity is algebraic, universal, unbreakable.

But there is a deeper revelation hiding inside the hypotenuse. Look at $d$:

$$d = (m^2 + n^2) + (p^2 + q^2).$$

The hypotenuse is the sum of *two sums of two squares* — a decomposition that Euler would have recognised instantly as the key to his own factoring methods. Each parenthetical group, $(m^2 + n^2)$ and $(p^2 + q^2)$, is the *norm* of a complex integer — a Gaussian integer, in fact. The four knobs $(m, n, p, q)$ are suspiciously reminiscent of quaternion components, and the resemblance is no accident: the parametric machine *is* quaternion arithmetic in disguise. We will return to this theme, but for now, note the exquisite structure: the machine does not merely generate quadruples, it *decomposes the hypotenuse* into arithmetic building blocks.

[ILLUSTRATION: A vintage brass-and-wood mechanical device with four labelled input dials ($m$, $n$, $p$, $q$) on the left and four output displays ($a$, $b$, $c$, $d$) on the right. Intricate gear trains connect inputs to outputs, with tiny placards showing the parametric formulas beside each gear chain. A worked example — $m=1, n=1, p=1, q=0$ producing $(1, 2, -2, 3)$ — is shown via arrows tracing through the machine in red ink.]

[ILLUSTRATION: A number line showing $d$ as a segment, subdivided into two coloured regions: a blue segment of length $m^2 + n^2$ and a red segment of length $p^2 + q^2$. Each coloured segment is further subdivided into its two square components ($m^2$ and $n^2$ in blue; $p^2$ and $q^2$ in red), shown with thin internal dividers.]

---

## The Collision Detector

Now we reach the most dramatic act. Recall that $81$ can be written as a sum of three squares in two different ways:

$$81 = 1^2 + 4^2 + 8^2 = 4^2 + 4^2 + 7^2.$$

Is this an accident — or a weapon?

It is a weapon. When two Pythagorean quadruples share the same hypotenuse $d$, their components must satisfy a *collision identity*. If $(a_1, b_1, c_1, d)$ and $(a_2, b_2, c_2, d)$ are both quadruples, then subtracting one defining equation from the other yields:

$$a_1^2 - a_2^2 + b_1^2 - b_2^2 = c_2^2 - c_1^2,$$

or, factoring every term as a difference of squares:

$$(a_1 - a_2)(a_1 + a_2) + (b_1 - b_2)(b_1 + b_2) = (c_2 - c_1)(c_2 + c_1).$$

This is the *collision theorem*, and the word "collision" is chosen with care. In cryptography, a *collision* occurs when two different inputs produce the same output — a phenomenon exploited in birthday attacks, hash-based factoring, and the quadratic sieve. Here, two different triples $(a_1, b_1, c_1)$ and $(a_2, b_2, c_2)$ "collide" at the same $d^2$, and the collision leaks algebraic information.

Let us test it with $d = 9$, using the quadruples $(1, 4, 8, 9)$ and $(4, 4, 7, 9)$:

$$(1 - 4)(1 + 4) + (4 - 4)(4 + 4) = (-3)(5) + (0)(8) = -15.$$

$$(7 - 8)(7 + 8) = (-1)(15) = -15. \quad \checkmark$$

Both sides equal $-15$. Now compute $\gcd(15, 81) = \gcd(15, 81) = 3$. We have extracted a factor of $81 = 3^4$.

The collision does not merely verify an identity — it *produces divisibility information*. The cross-differences, filtered through the greatest common divisor, act as a sieve that catches prime factors.

[ILLUSTRATION: Two winding paths ascending a hillside, converging at a summit labelled $d^2 = 81$. Path 1 is labelled with components $(1, 4, 8)$ and Path 2 with $(4, 4, 7)$. At the junction where the paths meet, a magnifying glass hovers, revealing the number $15$ inscribed on the ground. Tiny glowing fireflies labelled "$3$" escape from the magnifying glass into the night air — the prime factor, liberated by the collision.]

---

## Stretching the Quadruple

Before we go further, a moment of housekeeping. If $(1, 2, 2, 3)$ is a Pythagorean quadruple, then so is $(10, 20, 20, 30)$ — just multiply every component by $10$. The algebra is immediate:

$$(ka)^2 + (kb)^2 + (kc)^2 = k^2(a^2 + b^2 + c^2) = k^2 d^2 = (kd)^2.$$

This *scaling lemma* is obvious, but its consequences are not. Any common factor $g = \gcd(a, b, c, d)$ can be divided out, reducing to a *primitive* quadruple — one with no shared factor. Conversely, if $d$ is composite, one can sometimes *construct* a scaled quadruple that reveals a factor. The interplay between primitive and scaled quadruples is the arithmetic analogue of similar triangles in geometry: same shape, different size, and the ratio of sizes carries information.

[ILLUSTRATION: A small translucent tetrahedron labelled $(1, 2, 2, 3)$ next to a geometrically similar but three-times-larger tetrahedron labelled $(3, 6, 6, 9)$, with dotted lines connecting corresponding vertices. A label between them reads "$k = 3$, $\gcd = 3$." The scaling relationship is visually emphasised by nested outlines.]

---

## The Imaginary Witness

In 1832, Carl Friedrich Gauss published a paper that would reshape number theory forever. He introduced the *Gaussian integers* — numbers of the form $a + bi$, where $a$ and $b$ are ordinary integers and $i = \sqrt{-1}$ — and showed that they possess their own universe of primes, divisors, and unique factorisation.

The *norm* of a Gaussian integer $z = a + bi$ is the squared modulus:

$$N(z) = |z|^2 = a^2 + b^2.$$

Now look at the Magician's Bridge once more:

$$a^2 + b^2 = (d - c)(d + c).$$

The left side is the norm of the Gaussian integer $a + bi$. The right side is a factoring of that norm into two ordinary integers. But in the Gaussian world, the norm factors *differently*:

$$a^2 + b^2 = (a + bi)(a - bi).$$

We now have *two* factorisations of the same number: $(a + bi)(a - bi)$ in the Gaussian integers, and $(d - c)(d + c)$ in the ordinary integers. Comparing them — asking which Gaussian primes divide which ordinary factors — is *exactly* the technique Euler used to prove special cases of Fermat's theorems, and it remains the beating heart of algebraic number theory today.

Consider the quadruple $(2, 3, 6, 7)$. The Gaussian norm is $N(2 + 3i) = 4 + 9 = 13$. The bridge gives $(7 - 6)(7 + 6) = 1 \times 13$. In the Gaussian integers, $13 = (2 + 3i)(2 - 3i)$. Since $13$ is a Gaussian prime (up to units and associates), the two factorisations are compatible — $13$ cannot be split further. But for a composite value of $a^2 + b^2$, the Gaussian factorisation can *reveal structure* invisible to ordinary arithmetic.

There is a beautiful geometric way to see this. The Gaussian integer $a + bi$ is a vector in the plane. Its norm $a^2 + b^2$ is the area of a square built on that vector. The bridge identity says: *this square has the same area as the rectangle with sides $(d - c)$ and $(d + c)$*. Same area, different shape — and the relationship between the two shapes encodes the factoring of $d$.

[ILLUSTRATION: The Gaussian integer plane (complex plane with integer grid). A vector from the origin to the point $(2, 3)$ is drawn, with a tilted square of side $\sqrt{13}$ constructed on the vector (area $= 13$), shaded in light blue. Beside it, a rectangle of dimensions $1 \times 13$ (from the bridge identity with $d - c = 1$, $d + c = 13$) is drawn with the same area, shaded in light gold. A large equals sign connects the two shapes.]

---

## The Prime Inquisitor

"I am thinking of two numbers," says the inquisitor. "Their sum is $2d$ and their difference is $2c$. A prime $p$ divides their product. What can you deduce?"

The answer is Euclid's Lemma, one of the oldest and sharpest tools in all of number theory: if a prime divides a product, it must divide at least one of the factors. Therefore:

$$p \mid (d - c)(d + c) \quad \Longrightarrow \quad p \mid (d - c) \;\;\text{or}\;\; p \mid (d + c).$$

And from this single deduction, a cascade follows. If $p$ divides *both* $(d - c)$ and $(d + c)$, then it divides their sum $(d - c) + (d + c) = 2d$ and their difference $(d + c) - (d - c) = 2c$. This is the *lever* — Euclid's lever — that pries open the factorisation of $d$.

Consider the quadruple $(2, 3, 6, 7)$ again. We have $a^2 + b^2 = 13$, which is prime. So $13 \mid (7 - 6) = 1$ or $13 \mid (7 + 6) = 13$. The latter holds, and $\gcd(13, 7) = 1$ confirms that $7$ is coprime to $13$ — a roundabout but rigorous verification that $7$ is prime.

Now imagine $d$ is *composite* — say $d = 15$. If we can find a quadruple $(a, b, c, 15)$ such that $a^2 + b^2$ has a prime factor $p$ satisfying $1 < \gcd(d \pm c,\, d) < d$, we have extracted a non-trivial factor of $15$. The quadruple is a *factoring oracle*: feed it a composite number, and — if you choose the right quadruple — it whispers a factor in your ear.

[ILLUSTRATION: A lever diagram in the style of Archimedes. A beam balances on a triangular fulcrum labelled "Euclid's Lemma." On the left end of the beam sits the product $(d-c)(d+c)$; on the right end, a glowing prime $p$. Two arrows branch from $p$: one pointing to $(d-c)$ labelled "divides this?", the other to $(d+c)$ labelled "or this?" The two branches lead to separate paths, each terminating in a box reading "$\gcd$ with $d$".]

---

## The Mod Squad

One final constraint, elegant and essential. Can *any* integer $d$ appear as the hypotenuse of a Pythagorean quadruple? Not quite — arithmetic imposes a gate.

Quick: can $7^2 + 7^2 + 7^2$ be a perfect square? Compute: $49 + 49 + 49 = 147$. Is $147$ a perfect square? No — $12^2 = 144$, $13^2 = 169$. The square root of $147$ falls in the gap. But *why*?

The key is modular arithmetic. Every perfect square satisfies

$$n^2 \equiv 0 \;\text{or}\; 1 \pmod{4}.$$

Therefore $a^2 + b^2 + c^2 \pmod{4}$ can be at most $0 + 0 + 0 = 0$, at most $1 + 1 + 1 = 3$. For this sum to equal $d^2 \pmod{4}$, which is $0$ or $1$, the sum $a^2 + b^2 + c^2$ modulo $4$ must also be $0$ or $1$. The value $3 \pmod{4}$ for the sum is *forbidden* unless one of the squares contributes $0$ — which constrains the parity pattern of $(a, b, c)$.

Legendre proved a magnificent theorem: a positive integer $n$ is representable as a sum of three squares if and only if $n$ is *not* of the form $4^k(8m + 7)$. Since $d^2$ is a perfect square, this constrains which values of $d$ can serve as hypotenuses. The mod $4$ wall is real, and it filters the landscape of Pythagorean quadruples with ruthless efficiency.

There is also a *descent* principle at work. If all four components $a, b, c, d$ are even, write $a = 2a'$, $b = 2b'$, $c = 2c'$, $d = 2d'$. Then $a'^2 + b'^2 + c'^2 = d'^2$ — the quadruple "descends" to a smaller one, like a fractal zoom. Every even quadruple shelters a primitive one inside it.

[ILLUSTRATION: A $4 \times 4$ grid where rows represent values of $a^2 \bmod 4$ (labelled $0$ and $1$) and columns represent $b^2 \bmod 4$ (also $0$ and $1$). Each cell is subdivided into two mini-cells for $c^2 \bmod 4 \in \{0, 1\}$. Cells where the sum $\equiv 0$ or $1 \pmod{4}$ are shaded green (valid); cells with sum $\equiv 2$ or $3$ are shaded red (forbidden). The resulting checkerboard pattern reveals the modular obstruction at a glance.]

---

## The Number Cruncher's Workbench

The mathematician's motto is *trust, but verify*. Let us now roll up our sleeves and put every theorem to the test with our four specimen quadruples.

**Difference of squares.** For $(2, 3, 6, 7)$: $(7-6)(7+6) = 13 = 4 + 9$. $\checkmark$ For $(1, 4, 8, 9)$: $(9-8)(9+8) = 17 = 1 + 16$. $\checkmark$ For $(4, 4, 7, 9)$: $(9-7)(9+7) = 32 = 16 + 16$. $\checkmark$

**Parametric reconstruction.** The quadruple $(1, 2, 2, 3)$ arises from $(m, n, p, q) = (1, 1, 1, 0)$. The quadruple $(2, 3, 6, 7)$ arises from $(m, n, p, q) = (1, 1, 1, 1)$: check $a = 1+1-1-1 = 0$… hmm, that gives $(0, 4, 0, 4)$. Try $(m, n, p, q) = (2, 1, 1, 1)$: $a = 4+1-1-1 = 3$, $b = 2(2+1) = 6$, $c = 2(1-2) = -2$, $d = 4+1+1+1 = 7$. That gives $(3, 6, -2, 7)$, i.e., $(2, 3, 6, 7)$ after reordering and sign adjustment. $\checkmark$

**Collision check** for $d = 9$. From the two quadruples $(1, 4, 8, 9)$ and $(4, 4, 7, 9)$: $(1-4)(1+4) + (4-4)(4+4) = -15 + 0 = -15$, and $(7-8)(7+8) = -15$. $\checkmark$

**Gaussian norms.** $N(1 + 4i) = 1 + 16 = 17 = (9-8)(9+8)$. $\checkmark$ $N(4 + 4i) = 16 + 16 = 32 = (9-7)(9+7)$. $\checkmark$

Everything checks out. The theorems are not merely beautiful — they are *correct*, and correctness in mathematics is the only beauty that endures.

---

### Challenges for the Reader

1. Find a Pythagorean quadruple with $d = 15$ and use the bridge identity to extract a factor of $15$.

2. Find *two* quadruples sharing $d = 21$ and apply the collision theorem.

3. Verify the parametric formula for $m = 2$, $n = 1$, $p = 1$, $q = 1$, and identify the resulting quadruple.

4. Prove that no Pythagorean quadruple exists with $a = b = c$ and $d$ prime. (*Hint*: consider the equation modulo $3$.)

5. Find the smallest $d$ that admits three or more distinct primitive quadruples.

6. Use the Gaussian-integer bridge to show $5 = (2 + i)(2 - i)$, and connect this to a quadruple where $a^2 + b^2 = 5$.

7. Determine all $d \le 20$ for which at least one Pythagorean quadruple exists.

8. *(Open)* Is there an efficient algorithm to enumerate all primitive Pythagorean quadruples with hypotenuse $d$ in time polynomial in $\log d$?

[ILLUSTRATION: A wooden desk scattered with papers showing the four main quadruples, sharpened pencils, and a magnifying glass hovering over the collision identity. In the background, a chalkboard displays the parametric machine. On one corner of the desk sits a vintage mechanical calculator — a nod to the era of hand computation — whose display reads "GCD = 3". A histogram tacked to the wall shows the number of primitive quadruples for each $d$ from $1$ to $50$, with bars colour-coded blue for prime $d$ and red for composite $d$, revealing that composite values tend to have more representations.]

---

The theorems of this chapter are not mere curiosities. They constitute a *bridge* — sturdy, ancient, and astonishingly practical — between the world of Pythagorean geometry and the modern art of integer factorisation. Every quadruple is a potential factoring oracle; every collision, a leaked secret. In the next chapter, we will cross the bridge in earnest and construct a *GCD cascade*: a systematic procedure for extracting factors from multiple colliding representations, assembling the detective's clues into an airtight case against composite numbers.

The fourth dimension of Pythagoras, it turns out, is not merely a mathematical conceit. It is a weapon — and we have only begun to sharpen it.
