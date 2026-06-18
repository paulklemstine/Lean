# The Formula That Connects Everything

## How a Simple Fraction Reveals Hidden Unity Across Mathematics and Physics

*A single equation — the kind you might encounter in a high school trigonometry class — turns out to be a secret doorway connecting algebra, geometry, number theory, physics, and quantum computing. The Stereographic Projection Bridge is showing mathematicians that the universe of ideas is more interconnected than anyone suspected.*

---

### The Unreasonable Effectiveness of a Simple Formula

Write down the expression:

> **spb(x, y) = (x + y) / (1 − x·y)**

At first glance, it's nothing special — just add two numbers and divide by one minus their product. You may even recognize it: it's the tangent addition formula from trigonometry, the rule that tells you tan(α + β) when you know tan α and tan β.

But this humble formula has been hiding an extraordinary secret. It is not merely a trigonometric curiosity — it is the *group law of the circle*, disguised in different clothing. And like a Rosetta Stone, it translates between seemingly unrelated mathematical languages.

A team of researchers has now traced the implications of this observation across mathematics and physics, machine-verifying over 170 theorems in the Lean 4 proof assistant. What they found is a web of connections so dense that it challenges our usual picture of mathematics as divided into separate disciplines.

---

### What Is a "Bridge"?

The key idea is *stereographic projection* — a technique known since antiquity for mapping a sphere onto a flat surface. Imagine placing a sphere on a table and projecting each point on the sphere (except the north pole) down to the table by drawing a line from the north pole through the point. This maps the circle onto the real number line.

Now here's the magic: on the circle, you can *multiply* points (think of rotating angles). When you translate this multiplication to the real line via stereographic projection, you get the SPB formula. In other words:

> **Circle multiplication, seen through stereographic projection, IS the SPB formula.**

This is why the formula appears everywhere — because the circle group S¹ appears everywhere.

---

### Einstein in Disguise

Change one sign in the formula — replace the minus with a plus — and you get:

> **spbH(x, y) = (x + y) / (1 + x·y)**

This is *Einstein's velocity addition formula* from special relativity! When two rockets pass each other, each moving at velocities v₁ and v₂ (as fractions of light speed), the combined velocity is not v₁ + v₂ (as Newton thought) but spbH(v₁, v₂).

The connection is not coincidental. The ordinary SPB comes from the *circle* (circular geometry), while Einstein's version comes from the *hyperbola* (hyperbolic geometry). They are related by what physicists call a *Wick rotation* — essentially, replacing a real angle with an imaginary one.

So the same formula, with a single sign change, bridges between:
- **Circular geometry** (triangles on a sphere, trigonometry)
- **Hyperbolic geometry** (triangles in curved space, relativity)

---

### Secrets of Prime Numbers

Perhaps the most surprising application is in number theory — the study of prime numbers.

The SPB formula works not just with real numbers but with numbers in *finite arithmetic* — calculating modulo a prime p. When you compute spb(x, y) mod p (where division means finding a multiplicative inverse), you get a finite group.

The size of this group follows an elegant law:

> **The p±1 Law**: For an odd prime p, the SPB group over 𝔽_p has:
> - **p + 1** elements if p ≡ 3 (mod 4) (primes like 3, 7, 11, 19, 23, ...)
> - **p − 1** elements if p ≡ 1 (mod 4) (primes like 5, 13, 17, 29, 37, ...)

Why does the group size depend on whether p leaves remainder 1 or 3 when divided by 4? Because this determines whether √(−1) exists in arithmetic mod p. When it does (p ≡ 1 mod 4), the formula's "bridge" stays within the prime field. When it doesn't, the bridge extends into a larger field — and picks up extra elements along the way.

This has been computationally verified for every prime less than 10,000.

---

### Computing π with Binary Trees

The SPB formula gives a beautiful way to understand formulas for π. The classical result of John Machin (1706):

> **π/4 = 4·arctan(1/5) − arctan(1/239)**

becomes, in SPB language, a *binary tree*: start with four copies of the number 1/5, combine them pairwise with SPB, combine again, then SPB with −1/239. The result is exactly 1 — which, since arctan(1) = π/4, encodes Machin's formula.

Every known Machin-like formula for π corresponds to an SPB tree evaluating to 1. The Euler formula π/4 = arctan(1/2) + arctan(1/3) is the simplest: spb(1/2, 1/3) = 1.

This tree perspective opens a new question: **What is the smallest SPB tree that evaluates to 1?** It's a kind of "algorithmic complexity" question for computing π, and it remains open.

---

### Quantum Gates on the Bloch Sphere

In quantum computing, a single qubit's state can be visualized as a point on the *Bloch sphere*. Using stereographic projection, we can map this sphere to the complex plane, representing quantum states as complex numbers ζ.

The researchers discovered that quantum gates become beautifully simple in these coordinates:

> **The Hadamard gate** — one of the most fundamental quantum operations — is simply **H(ζ) = spb(ζ, −1)**.

The phase gate is just multiplication by i. Gate composition follows from SPB's associativity. This is not merely an aesthetic observation — it could lead to new methods for *quantum gate synthesis*, the problem of efficiently decomposing arbitrary quantum operations into elementary gates.

---

### Tropical Geometry Meets SPB

In *tropical mathematics*, addition is replaced by "take the minimum" and multiplication by ordinary addition. Applying this transformation to the SPB formula gives:

> **tropical spb(x, y) = min(x, y) − max(0, x + y)**

This tropical SPB is commutative, like its classical cousin, but it breaks other rules. Zero is no longer the identity for all inputs — only for negative ones. It's idempotent for negative inputs: tropical spb(x, x) = x when x < 0.

The resulting structure is neither a group nor a ring but something new. Characterizing it precisely is an open problem that connects to optimization theory and algebraic geometry.

---

### The Bigger Picture

Why does one formula connect so many areas? The researchers propose an answer rooted in the theory of *symmetric spaces*.

The SPB operation is the group law of the simplest compact symmetric space: S¹ = SO(2)/SO(1), parameterized via stereographic projection. Higher-dimensional symmetric spaces should give higher-dimensional SPB operations:
- **SU(2)/U(1) → S²** (the Bloch sphere) → complex SPB
- **SO(3,1)/SO(3) → H³** → relativistic 3-velocity addition in 3D
- **Sp(4)/U(2) → Siegel upper half-space** → matrix SPB

The universality of SPB may reflect the universality of symmetric spaces in mathematics and physics.

---

### Machine Verification: Trust but Verify

What makes this research program distinctive is its use of *machine verification*. Every theorem is not just proved on paper but formalized in the Lean 4 proof assistant and checked by computer. This eliminates the possibility of subtle errors — a real concern when connecting results from many different fields, where experts in one area may not catch mistakes from another.

The project has produced over 170 verified theorems across 18 files, with zero unproved statements remaining. The formal proofs are publicly available and can be independently verified by anyone with a computer.

---

### What's Next?

The SPB research program has generated a rich landscape of open problems:

1. **Prove the p±1 law formally** — the computational evidence is overwhelming, but a complete machine-verified proof remains to be written.

2. **Explore SPB neural networks** — neurons using the SPB activation function have natural boundedness and smoothness properties that could improve machine learning.

3. **Build SPB-based hardware** — the SPB formula could replace the CORDIC algorithm in trigonometric computation chips, potentially offering speed advantages.

4. **Extend to higher dimensions** — quaternionic and octonionic SPB, with connections to 3D rotations and string theory.

5. **Unify SPB with EML** — the "exponential minus logarithm" operator eml(x,y) = eˣ − ln(y) bridges additive and multiplicative arithmetic. Together, SPB and EML may generate all elementary functions.

The deepest question of all may be philosophical: *Why is mathematics so interconnected?* The SPB story suggests that the connections we see between different branches of mathematics are not accidents but reflections of deep structural truths. A formula as simple as (x+y)/(1−xy) can be a window into this hidden unity — if we know where to look.

---

*The Stereographic Projection Bridge formalization project is built on Lean 4 with the Mathlib mathematical library. All theorems referenced in this article have been machine-verified.*
