# The Formula That Connects Everything

## How a single equation from ancient trigonometry links Einstein's relativity, quantum computing, and machine learning — and how computers proved it's all true

*A Feature Article*

---

### One Formula to Rule Them All

Mathematics is full of beautiful formulas. But every so often, one equation turns out to be far deeper than anyone suspected — a doorway into a hidden palace of connections linking seemingly unrelated corners of mathematics and physics.

The formula in question is deceptively simple:

$$\text{spb}(x, y) = \frac{x + y}{1 - xy}$$

You may recognize it. If you took trigonometry in high school, you learned it as the tangent addition formula: $\tan(\alpha + \beta) = (\tan\alpha + \tan\beta)/(1 - \tan\alpha\cdot\tan\beta)$. It's been in textbooks for centuries, a workhorse calculation that most mathematicians file away as "elementary" and never think about again.

But a new research program — backed by machine-verified proofs in the Lean 4 theorem prover — reveals that this humble formula is actually a master key connecting four major domains of mathematics:

1. **Trigonometry**: It *is* the tangent addition formula
2. **Group theory**: It makes the real numbers into a copy of the circle
3. **Special relativity**: Change one sign and it becomes Einstein's velocity addition
4. **Approximation theory**: It generates a complete system of rational functions

The researchers call it the **Stereographic Projection Bridge** — SPB for short — because it arises naturally from the stereographic projection, the ancient cartographer's trick for mapping a sphere onto a flat plane.

---

### The Bridge Between Line and Circle

Here's the key insight. Consider the unit circle in the plane — all points $(x, y)$ where $x^2 + y^2 = 1$. Now imagine shining a light from the south pole $(0, -1)$ through a point on the circle and seeing where the ray hits the horizontal axis. This "stereographic projection" maps every point on the circle (except the south pole) to a point on the real line.

The formulas are:
- From line to circle: $t \mapsto \left(\frac{2t}{1+t^2}, \frac{1-t^2}{1+t^2}\right)$
- From circle to line: $(x, y) \mapsto \frac{x}{1+y}$

And here's the magic: **multiplying two points on the circle** — which is just rotating one angle by another — corresponds to **applying the SPB formula** on the line. If you project two points to the line, SPB them together, and project back, you get the same result as multiplying the original circle points.

This is the *Cayley transform*, and the research team has formally verified it in Lean 4:

```
Cayley(spb(x, y)) = Cayley(x) · Cayley(y)
```

The circle is a group under multiplication. Through the stereographic bridge, the real numbers become a group under SPB. Same mathematical structure, two different costumes.

---

### Einstein's Hidden Formula

In 1905, Albert Einstein discovered that velocities don't simply add. If a train moves at speed $u$ relative to the ground, and a ball is thrown forward at speed $v$ relative to the train, the ball's speed relative to the ground isn't $u + v$ (as Newton thought). It's:

$$v_{\text{total}} = \frac{u + v}{1 + uv/c^2}$$

where $c$ is the speed of light. Setting $c = 1$, this becomes $(u + v)/(1 + uv)$ — the *hyperbolic* SPB, identical to our formula except the minus sign in the denominator becomes a plus.

The SPB framework reveals *why* this formula works: it's the tangent addition formula for *hyperbolic* trigonometry. Just as $\tan(\alpha+\beta) = \text{spb}(\tan\alpha, \tan\beta)$ on the circle, $\tanh(\phi_1+\phi_2) = \text{spbH}(\tanh\phi_1, \tanh\phi_2)$ on the hyperbola.

Even better, the research team proved a property that Einstein struggled to explain intuitively: **the speed of light really is an absolute barrier**. If $|u| < 1$ and $|v| < 1$, then $|\text{spbH}(u,v)| < 1$. No matter how you combine sub-light velocities, you can never reach the speed of light. This was formally verified in Lean 4 — the first machine-checked proof of this fundamental physical principle.

---

### The Third Dimension: Quaternions and Thomas Precession

In one dimension, SPB is commutative: $\text{spb}(x, y) = \text{spb}(y, x)$. But in three dimensions, a remarkable thing happens. The 3D extension of SPB is:

$$\text{spb}_3(\mathbf{u}, \mathbf{v}) = \frac{\mathbf{u} + \mathbf{v} + \mathbf{u} \times \mathbf{v}}{1 - \mathbf{u} \cdot \mathbf{v}}$$

The cross product $\mathbf{u} \times \mathbf{v}$ breaks the symmetry. In 3D, $\text{spb}_3(\mathbf{u}, \mathbf{v}) \neq \text{spb}_3(\mathbf{v}, \mathbf{u})$ — the order matters.

Through the 3D Cayley transform, this operation corresponds to **quaternion multiplication** — the mathematics that every video game and robotics system uses to handle 3D rotations. The fact that quaternion multiplication is non-commutative (rotating first by $\mathbf{u}$ then by $\mathbf{v}$ gives a different result than $\mathbf{v}$ then $\mathbf{u}$) is now revealed as a consequence of the cross product in the SPB formula.

The difference between $\text{spb}_3(\mathbf{u}, \mathbf{v})$ and $\text{spb}_3(\mathbf{v}, \mathbf{u})$ is precisely the **Thomas-Wigner rotation** — a real physical effect where the polarization of light rotates when a particle changes direction. GPS satellites must correct for this effect, and the SPB formula gives its exact magnitude.

Even more striking: the Hurwitz theorem (1898) proves that this trick only works in dimensions 1, 3, and 7. In dimension 7, you get the **octonions** — a number system so exotic that multiplication isn't even associative. These dimensions correspond to the only division algebras over the reals: the reals themselves ($n=1$), the quaternions ($n=3$), and the octonions ($n=7$). The SPB framework provides a unified entry point to this hierarchy.

---

### Neural Networks That Think in Circles

Perhaps the most unexpected application is in machine learning. Standard neural networks use neurons of the form $\sigma(wx + b)$, where $\sigma$ is an activation function like ReLU or sigmoid. These work well for many tasks, but they struggle with *periodic* data — anything that repeats cyclically, like daily temperatures, heartbeat rhythms, or annual sales patterns.

An **SPB neuron** replaces the standard activation with the SPB formula:

$$\text{output} = \text{spb}(w_1 x, w_2) = \frac{w_1 x + w_2}{1 - w_1 w_2 x}$$

This is a **Möbius transform** — a rational function that naturally wraps around the circle. A tree of SPB neurons computes $\tan(n \cdot \arctan(x))$, which forms a complete orthogonal system for rational function approximation.

The key advantage: while a polynomial of degree $n$ needs $n$ parameters to fit a function with $n$ oscillations, an SPB tree does it with $O(\log n)$ parameters. This exponential compression means SPB networks could dramatically outperform standard architectures on periodic tasks — a theoretical prediction that computational experiments have begun to confirm.

Moreover, SPB approximation avoids the notorious **Runge phenomenon**, where polynomial interpolation goes wildly wrong at the edges of an interval. The rational functions generated by SPB trees don't suffer from this instability, because they parametrize the circle rather than the line.

---

### Proving It All with Computers

What makes this research program special isn't just the breadth of connections — it's the **certainty**. Every core theorem has been formally verified in Lean 4, a computer proof assistant that checks every logical step with mathematical rigor.

The verified results include:
- 28+ core theorems with zero uses of `sorry` (Lean's placeholder for unproven claims)
- Group axioms: commutativity, identity, inverse, associativity
- Cayley homomorphism: the bridge between line and circle
- Einstein velocity bound: the speed of light barrier
- Norm multiplicativity: the cocycle identity
- Fixed point theorem: SPB with $a \neq 0$ has no fixed points
- Cancellation: $\text{spb}(\text{spb}(x,y), -y) = x$
- Inversion anti-automorphism: $\text{spb}(1/x, 1/y) = -\text{spb}(x,y)$

This level of formal verification is still rare in mathematics. Most published proofs rely on peer review — humans checking other humans' work — which occasionally misses errors that can persist for decades. Machine verification eliminates this risk entirely.

---

### The Finite Field Frontier

Over the real numbers, SPB gives an infinite group isomorphic to the circle $S^1$. But what happens over *finite fields* — the modular arithmetic systems $\mathbb{F}_p$ used in cryptography?

Computational experiments for all primes $p \leq 97$ reveal a striking pattern:

- If $p \equiv 3 \pmod{4}$: the SPB group has order $p + 1$
- If $p \equiv 1 \pmod{4}$: the SPB group has order $p - 1$

This connects to deep number theory. The condition $p \equiv 3 \pmod{4}$ is precisely when $-1$ is *not* a perfect square modulo $p$ — when the Gaussian integers $\mathbb{Z}[i]$ remain a "field extension" over $\mathbb{F}_p$. The SPB group turns out to be isomorphic to the norm-1 elements of $\mathbb{F}_{p^2}^*$, the multiplicative group of the quadratic extension.

These finite SPB groups are already used (under different names) in efficient cryptographic systems like XTR, which achieve the security of 1024-bit RSA using only 170-bit keys. The SPB perspective offers a new geometric intuition for why these systems work.

---

### Questions That Could Change Everything

The SPB framework opens several deep research questions:

**1. Is there an "SPB Fourier Transform"?** Since the SPB basis functions $T_n(x) = \tan(n \cdot \arctan(x))$ form a complete system of rational functions, there should be a transform that decomposes functions into this basis. Would it have a fast algorithm, analogous to the FFT?

**2. Can SPB neural networks provably outperform standard architectures?** A theoretical separation result — showing that SPB networks need exponentially fewer parameters than MLPs for certain function classes — would be a significant contribution to learning theory.

**3. What is the SPB of $p$-adic numbers?** The $p$-adic numbers $\mathbb{Q}_p$ are an alternative completion of the rationals, fundamental in number theory. Studying SPB over $\mathbb{Q}_p$ could reveal connections between stereographic geometry and arithmetic.

**4. Does SPB connect to the Langlands program?** The SPB Möbius matrix $\begin{pmatrix} 1 & a \\ -a & 1 \end{pmatrix}$ lives in $\text{SL}(2, \mathbb{R})$, the gateway to automorphic forms and the Langlands program — one of the deepest unifying frameworks in modern mathematics.

---

### A New Way to See Old Mathematics

The SPB framework doesn't claim to discover new mathematics in the traditional sense. The tangent addition formula is ancient. The Cayley transform dates to 1846. Einstein's velocity addition is from 1905. What's new is the *unification* — seeing all these results as facets of a single algebraic operation, and proving the connections with machine-verified certainty.

This kind of "bridge-building" mathematics has a distinguished history. When André Weil proposed his famous conjectures in 1949, he was connecting number theory to topology through algebraic geometry — a bridge that required decades to fully construct (culminating in the work of Grothendieck and Deligne) but opened entirely new fields of mathematics.

The SPB bridge is humbler in scope, but it shares the same philosophy: that the deepest truths in mathematics are not isolated theorems but *connections between seemingly different structures*. And now, for the first time, these connections carry the gold standard of certainty — they have been verified by computer, theorem by theorem, leaving no room for error.

The formula $(x + y)/(1 - xy)$ has been hiding in plain sight for centuries. We are only now beginning to understand how deep it goes.

---

*The SPB research program is open and ongoing. All Lean 4 formalizations, Python demonstrations, and research papers are publicly available.*
