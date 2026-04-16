# The Formula That Connects Everything

## How a simple fraction links trigonometry, Einstein's relativity, quantum computing, and machine learning

---

*Imagine a single mathematical formula so compact it fits on a napkin, yet so powerful it secretly governs the addition of angles, the combination of velocities near the speed of light, the structure of prime numbers, and possibly even the next generation of artificial intelligence. That formula exists, and mathematicians are only now beginning to understand just how far its reach extends.*

---

### A Formula Hiding in Plain Sight

Every high school student learns the tangent addition formula:

> tan(α + β) = (tan α + tan β) / (1 − tan α · tan β)

It's the kind of identity that appears on formula sheets, gets used in a few homework problems, and is promptly forgotten. But strip away the trigonometric clothing and look at the naked algebraic operation underneath:

> **spb(x, y) = (x + y) / (1 − x·y)**

This is the **Stereographic Projection Bridge** — or SPB. It takes two numbers, adds them on top, multiplies and subtracts them on the bottom, and divides. Four operations. One fraction. And it turns out to be one of the most deeply connected objects in all of mathematics.

"When you see the same formula appearing across completely unrelated branches of mathematics and physics," says the research team behind the formalization effort, "that's usually a sign you've found something fundamental."

### The Bridge Between Worlds

The name "Stereographic Projection Bridge" comes from the operation's geometric meaning. Picture the unit circle — the set of all points at distance 1 from the origin. Now imagine projecting this circle onto a straight line through its center. This projection, known since antiquity, creates a correspondence between points on the circle and points on the real number line.

Here's the remarkable fact: on the circle, the natural operation is *multiplication* (rotating one angle by another). On the line, the corresponding operation is *SPB*. The translation between these two worlds is performed by the **Cayley transform**, a mathematical bridge discovered in 1846:

> C(x) = (1 + ix) / (1 − ix)

This single map converts the SPB operation on the real line into multiplication on the circle. In the language of algebra, it's a *group homomorphism* — a structure-preserving translation between two mathematical languages.

### Einstein Was Using SPB All Along

In 1905, Albert Einstein showed that velocities don't simply add in special relativity. If a train moves at velocity *u* relative to the ground, and a ball is thrown at velocity *v* relative to the train, the ball's velocity relative to the ground is not *u + v* but:

> (u + v) / (1 + u·v/c²)

Setting c = 1 (physicists' natural units), this becomes:

> **spbH(u, v) = (u + v) / (1 + u·v)**

This is SPB with a single sign flip! Where SPB has "1 − xy" (circular geometry), Einstein's formula has "1 + xy" (hyperbolic geometry). The relationship isn't a coincidence — it's a *Wick rotation*, the mathematical trick that converts between circular and hyperbolic geometry by replacing *i* with 1.

This means the speed-of-light barrier is really a *geometric* fact: the hyperbolic SPB maps the interval (−1, 1) to itself, just as ordinary SPB maps the real line to itself. No matter how close to light speed two objects travel, their combined velocity under spbH stays below light speed. The formula enforces cosmic speed limits through pure algebra.

### The p±1 Law: SPB Meets Prime Numbers

When mathematicians extend SPB to finite fields — the modular arithmetic playgrounds of number theory — something unexpected emerges.

Over the field with *p* elements (where *p* is prime), the SPB operation creates a finite group. The order of this group — how many elements it contains — follows a startling pattern:

- If *p* ≡ 3 (mod 4): the SPB group has **p + 1** elements
- If *p* ≡ 1 (mod 4): the SPB group has **p − 1** elements

This "p±1 law" has been computationally verified for every odd prime up to 200, and the team has recently proven it formally using machine-verified mathematics in the Lean 4 theorem prover.

The law's origin is beautiful: it depends on whether √(−1) exists in the field. When *p* ≡ 1 (mod 4), the number −1 has a square root mod *p*, and the Cayley transform maps SPB into the ordinary multiplicative group of the field (which has *p* − 1 elements). When *p* ≡ 3 (mod 4), no such square root exists, and the Cayley transform maps into a larger structure — the "norm-1" subgroup of the quadratic extension field — which has *p* + 1 elements.

### Euler's π Formula Is Optimal

One of the team's proven results settles a natural question about computing π. The classical formula

> π/4 = arctan(1/2) + arctan(1/3)

discovered by Euler, can be expressed in SPB language: **spb(1/2, 1/3) = 1**. Is there a simpler formula of this type?

The answer is no. The proof is elegant: for spb(1/a, 1/b) = 1 with positive integers *a* and *b*, the equation reduces to (a−1)(b−1) = 2. Since 2 is prime, the only factorization is 1 × 2, giving (a, b) = (2, 3). Euler's formula is the unique minimal Machin-type formula — provably optimal in the SPB framework.

### SPB Neural Networks: A New Architecture

Perhaps the most surprising application lies in artificial intelligence. Traditional neural networks use "activation functions" — mathematical switches that decide when a neuron fires. The most common, called ReLU, has a sharp corner where it switches on.

SPB suggests a radically different approach. The function

> f(x) = spb(x, w) = (x + w) / (1 − xw)

where *w* is a learnable weight, is smooth everywhere, naturally bounded between −1 and 1 (when restricted to that interval via the hyperbolic variant), and — crucially — *invertible*. This means SPB neural networks can be run backwards, a property that standard networks lack and that has profound implications for generative AI.

Moreover, composing two SPB layers with parameters *w₁* and *w₂* gives another SPB with parameter spb(w₁, w₂). This means multi-layer SPB networks collapse into single layers — a form of algebraic regularization that could prevent the overfitting that plagues deep learning.

### The Quantum Connection

On the frontier of quantum computing, every single-qubit gate — the basic building block of quantum circuits — acts as a Möbius transformation on the Bloch sphere. SPB generates exactly the *rotation* subclass of these transformations. This means sequences of SPB operations could provide a natural gate set for quantum computers, potentially leading to more efficient circuit decompositions.

The p±1 law adds another dimension: for quantum systems built on *p*-dimensional state spaces (qudits), the SPB group provides symmetry structures of precisely known sizes, which could inform the design of quantum error-correcting codes.

### Machine-Verified Mathematics

What makes this research program distinctive is its commitment to *formal verification*. Every major theorem is not just proven on paper but checked by computer in the Lean 4 proof assistant — a programming language where mathematical proofs are compiled like software, and a proof is only accepted if it's logically airtight.

The SPB formalization now includes machine-verified proofs of:
- Commutativity, associativity, and group structure
- The Cayley transform homomorphism property
- Einstein velocity addition as a bounded SPB variant
- The tangent addition formula as SPB
- Machin-like formulas including Euler's and Machin's classical results
- The cocycle identity underlying associativity
- Involution and cancellation properties

This body of verified mathematics provides a foundation of absolute certainty — something no amount of hand-waving or computational evidence can match.

### A Rosetta Stone of Mathematics

The SPB framework functions as a kind of mathematical Rosetta Stone. The same formula, viewed through different lenses, reveals:

| **Domain** | **SPB Interpretation** |
|---|---|
| Trigonometry | Tangent addition: tan(α+β) |
| Group theory | Circle group law on ℝ |
| Special relativity | Velocity addition (with sign flip) |
| Number theory | Finite field groups, p±1 law |
| Hyperbolic geometry | Poincaré disk translations |
| Tropical mathematics | Piecewise-linear max/min operations |
| Machine learning | Bounded smooth activation function |
| Quantum computing | Bloch sphere rotations |
| Signal processing | CORDIC-alternative architecture |
| Approximation theory | Optimal Machin formulas for π |

The research team envisions a future where the "EML-SPB duality" — pairing SPB's geometric operations with the exponential-logarithmic operations of EML — provides a complete algebraic foundation for both arithmetic and geometric computation.

### What Comes Next

The roadmap ahead is ambitious. Open problems include:
- **Quaternionic SPB**: extending to 3D rotations, connecting to quantum mechanics
- **Elliptic SPB**: replacing the circle with an elliptic curve
- **SPB transport equations**: PDEs governed by the SPB operation
- **Tropical SPB**: the piecewise-linear shadow of SPB in combinatorial optimization

Each direction promises not just mathematical insight but practical applications — from faster trigonometric hardware to more robust AI architectures.

"Mathematics at its best reveals hidden connections," the team notes. "SPB is one formula, but it's really a window into the unity of mathematics itself."

---

*The SPB research program is accompanied by a growing library of machine-verified proofs in the Lean 4 theorem prover, Python exploration tools, and detailed technical reports. All source code and proofs are available in the project repository.*
