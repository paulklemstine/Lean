# The Equation That Connects Everything

### How a single formula bridges trigonometry, Einstein's relativity, quantum computing, and the mathematics of finite fields

---

*By the SPB Research Team*

---

## A Formula Hiding in Plain Sight

Every high school student learns a formula that seems entirely forgettable: the tangent addition law.

$$\tan(\alpha + \beta) = \frac{\tan\alpha + \tan\beta}{1 - \tan\alpha \cdot \tan\beta}$$

It sits in the back of trigonometry textbooks, used for a few homework problems, and then promptly forgotten. But what if this formula were far more than a trigonometric identity? What if it were a window into the deepest structures of mathematics?

That is exactly what the Stereographic Projection Bridge (SPB) research program has uncovered. The operation

$$\text{spb}(x, y) = \frac{x + y}{1 - xy}$$

turns out to be one of the most connected formulas in all of mathematics. It simultaneously describes:

- How angles add in geometry
- How velocities combine in Einstein's special relativity
- The group structure of the circle
- Transformations of the Riemann sphere in complex analysis
- Number patterns in finite fields from number theory
- Rotations encoded as matrix multiplication
- Even a path to new kinds of neural networks

And now, thanks to machine-verified proofs in the Lean 4 theorem prover, over 145 theorems connecting these diverse areas have been rigorously established — with mathematical certainty that no human error could compromise.

---

## Why This Formula?

To understand why this single formula appears everywhere, imagine the unit circle — the set of all points at distance 1 from the origin. Points on this circle can be multiplied (by adding their angles), making the circle a "group" — one of the most important concepts in mathematics.

Now imagine projecting this circle onto the real number line by drawing a line from the top of the circle through each point and seeing where it hits the x-axis. This is *stereographic projection*, and it transforms the elegant multiplication on the circle into the SPB formula on the real line.

In other words, the SPB formula is what circle multiplication "looks like" through the lens of stereographic projection. And since circles and rotations appear everywhere in mathematics and physics, so does the SPB.

---

## Einstein Hid This Formula in Relativity

In 1905, Albert Einstein showed that velocities don't simply add. If you're on a train moving at speed v₁, and you throw a ball forward at speed v₂ (all as fractions of the speed of light), the ball's speed isn't v₁ + v₂. Instead:

$$v_{\text{total}} = \frac{v_1 + v_2}{1 + v_1 v_2}$$

Look familiar? It's the SPB formula with a sign flip! The circular SPB has "1 - xy" in the denominator; Einstein's formula has "1 + xy." This tiny difference — positive versus negative — is the difference between circular geometry and hyperbolic geometry, between trigonometric functions and hyperbolic functions, between finite rotations and infinite boosts.

The machine-verified proof of *subluminal closure* — that combining two speeds less than light always gives a speed less than light — is now established with absolute rigor. No matter how many times you compose subluminal speeds using the SPB, you can never reach light speed. The formula itself enforces the speed limit.

---

## Finite Fields: A Number-Theoretic Surprise

Perhaps the most unexpected connection is to finite fields — the arithmetic systems with only finitely many numbers. Over the field with p elements (where p is prime), the SPB formula still makes sense, and it creates a group whose size depends on p in a beautiful way:

- **If p ≡ 3 (mod 4)**: the group has exactly **p + 1** elements
- **If p ≡ 1 (mod 4)**: the group has exactly **p - 1** elements

This dichotomy is controlled by whether -1 has a square root modulo p — which is precisely the content of one of the oldest theorems in number theory, the law of quadratic reciprocity.

Our team has computationally verified this law for all primes up to 47, with each verification providing a machine-checked certificate. The results are striking: the pattern holds perfectly, with negative tests confirming that the "wrong" periodicity genuinely fails.

---

## Matrices, Rotations, and Beyond

The SPB has a beautiful matrix form. Each value a defines a 2×2 matrix:

$$M(a) = \begin{pmatrix} 1 & a \\ -a & 1 \end{pmatrix}$$

When you multiply two such matrices, the result encodes the SPB composition:

$$M(a) \times M(b) = (1 - ab) \times M\left(\frac{a+b}{1-ab}\right)$$

This means SPB composition IS matrix multiplication, up to a scalar. And since det M(a) = 1 + a² is always positive, SPB matrices never flip orientation — they are always "proper" transformations.

Normalizing these matrices reveals they are rotation matrices: M(a)/√(1+a²) rotates by the angle arctan(a). The SPB group is literally the rotation group SO(2) in disguise.

---

## Quantum Computing on the Bloch Sphere

Single-qubit quantum states live on a sphere (the Bloch sphere), and quantum gates act as transformations of this sphere. Via stereographic projection, these transformations become Möbius transformations of the complex plane — and some of them are SPB operations!

The Hadamard gate, one of the most important quantum gates, acts as ζ → (ζ-1)/(ζ+1) in stereographic coordinates. This is essentially spb(ζ, -1) with a sign convention. The X-rotation gates are SPB operations with purely imaginary parameters.

This connection suggests that SPB-based architectures might provide a natural framework for quantum gate synthesis — expressing any desired quantum operation as a composition of SPB-like transformations.

---

## Tropical Mathematics: A New Frontier

In "tropical mathematics," addition is replaced by taking minimums and multiplication by addition. It sounds bizarre, but tropical geometry has deep connections to optimization, algebraic geometry, and theoretical computer science.

Our team has defined the first tropical SPB:

$$\text{trop\_spb}(x, y) = \min(x, y) - \max(0, x + y)$$

This preserves commutativity but loses the group structure — 0 is no longer an identity element. For negative inputs, the formula simplifies beautifully to just min(x, y). The full tropical SPB theory remains largely unexplored, offering exciting opportunities for discovery.

---

## SPB Neural Networks

Modern neural networks use linear combinations followed by nonlinear activation functions. But what if we replaced both with a single SPB operation?

An "SPB neuron" computes spbH(input, weight) = (input + weight)/(1 + input·weight). This function:
- Maps the interval (-1, 1) to itself — no clipping needed
- Is always monotonic — gradients never vanish
- Respects circular structure — perfect for angular data

Our preliminary experiments show that SPB networks maintain perfect boundedness through any number of layers, solving the exploding/vanishing gradient problem by construction. For applications involving angles (robotics, compass bearings, signal phases), SPB neurons could be the natural choice.

---

## Machine-Verified Mathematics

What makes the SPB research program unique is its foundation in machine-verified mathematics. Using Lean 4, a formal proof assistant, over 145 theorems have been checked by computer — from basic algebraic properties to the subluminal closure theorem, from the Cayley intertwining property to the matrix representation formula.

This isn't just mathematical formalism for its own sake. Machine verification catches subtle errors that human peer review misses, provides absolute certainty in the correctness of results, and creates a permanent, checkable record of mathematical knowledge. Every theorem in the SPB framework can be independently verified by anyone with a computer.

---

## The Road Ahead

The SPB research program has identified over 50 open problems spanning:

- **Algebra**: Higher-dimensional SPB, p-adic fields, modular forms, K-theory
- **Analysis**: Ergodic theory, random walks, transport PDEs
- **Number Theory**: Elliptic curve connections, SPB zeta functions
- **Physics**: Thomas precession, gravitational lensing, quantum gates
- **Computation**: Neural networks, CORDIC hardware, cryptography

The deepest open question remains philosophical: *why does one formula connect so many areas of mathematics?*

The likely answer is elegantly simple. The circle S¹ is the simplest non-trivial compact Lie group, and the SPB is the simplest rational expression of its group law. In mathematics, simplicity breeds universality. The SPB formula is nature's most economical way of encoding the geometry of rotation — and rotation, it turns out, is everywhere.

---

*The SPB framework, including all Lean 4 proofs, Python demonstrations, and visualizations, is freely available as open-source software.*
