# The Many Pasts of a Chaotic Present

## One number, exponentially many histories

Imagine being handed a single number between zero and one and being told that it is the present state of a perfectly deterministic system. The rule governing the system is known exactly. Can you reconstruct its past?

For the full-strength logistic map, the answer is both precise and unsettling. The rule is

$$
L(x)=4x(1-x), \qquad 0\le x\le 1.
$$

Starting from a seed $x$, one repeatedly applies $L$ to obtain $x,L(x),L^2(x),\ldots$. Here $L^n$ means that the rule has been applied $n$ times. This tiny quadratic formula is one of the classic models of chaos. It stretches the interval, folds it at its midpoint, and repeats. Nearby starting points can soon produce dramatically different trajectories.

But sensitivity to initial conditions is only half the story. Looking backward reveals another kind of uncertainty: every ordinary present state has an exponentially large family of exact pasts.

**Exact Fiber Cardinality Theorem.** Fix an integer $n\ge 0$ and a target $y$ with $0<y<1$. Among seeds $x$ in the open interval $(0,1)$, exactly $2^n$ satisfy

$$
L^n(x)=y.
$$

This is not merely a lower bound obtained by displaying many examples. It is a complete classification. Every possible $n$-step past arises from a binary sequence of choices, and two different sequences always produce different seeds.

## The fold that creates two pasts

The graph of $L$ is a downward-opening parabola. It begins at $0$, rises to $1$ at $x=1/2$, and returns to $0$ at $x=1$. The left and right halves mirror each other. Consequently, every horizontal line at a height $y$ strictly between $0$ and $1$ meets the parabola twice.

Solving $4x(1-x)=y$ gives two inverse branches:

$$
B_0(y)=\frac{1-\sqrt{1-y}}{2},
\qquad
B_1(y)=\frac{1+\sqrt{1-y}}{2}.
$$

The first branch lands below the midpoint and the second above it:

$$
0<B_0(y)<\frac12<B_1(y)<1.
$$

Both return to the same target:

$$
L(B_0(y))=y=L(B_1(y)).
$$

Thus one observed state has two one-step predecessors. Each of those predecessors, being interior, again has two predecessors. After two backward steps there are four candidates; after three, eight; after $n$, one expects $2^n$.

Expectation is not proof, however. A branching picture can overcount if different paths later collide, and it can undercount if the proposed branches fail to capture some solutions. The heart of the theorem is that neither problem occurs in the open interval.

## Reading a binary address backward

Let a binary word be

$$
\varepsilon=(\varepsilon_1,\ldots,\varepsilon_n),
\qquad \varepsilon_j\in\{0,1\}.
$$

Starting at $y$, decode the word by applying its inverse branches recursively:

$$
D_{()}(y)=y,
$$

and

$$
D_{(\varepsilon_1,\ldots,\varepsilon_n)}(y)
=B_{\varepsilon_1}\!\left(D_{(\varepsilon_2,\ldots,\varepsilon_n)}(y)\right).
$$

The order is meaningful: the first symbol records whether the original seed lies on the lower or upper side of the parabola, while the remaining symbols describe the earlier choices needed to reach the intermediate state.

Every intermediate decoded value remains strictly between $0$ and $1$. Applying $L$ cancels the outer inverse branch, and repeating this cancellation $n$ times proves

$$
L^n(D_\varepsilon(y))=y.
$$

So all $2^n$ binary words yield valid seeds. The construction is also an algorithm: to enumerate every exact past, list all binary words of length $n$ and decode each one with $n$ square-root operations.

## Why no two addresses collide

Suppose two words decode to the same seed. Apply $L$ once. The first inverse operation disappears, leaving decoded values associated with the two shortened words. By induction, the tails of the words must agree.

It remains to recover the first symbol. That symbol is visible geometrically. If it is $0$, the decoded seed lies below $1/2$; if it is $1$, the seed lies above $1/2$. The same number cannot lie strictly on both sides. Hence the first symbols agree as well, and the entire words are identical.

This establishes injectivity: distinct binary addresses determine distinct real seeds. The strict inequalities matter. At the critical value, branches can meet, but an interior target keeps every backward stage away from the problematic boundary and critical collisions.

## Why there are no hidden pasts

The converse is equally important. Take any interior seed $x$ satisfying $L^n(x)=y$. Its immediate image $L(x)$ is an interior $(n-1)$-step predecessor of $y$. By repeating this reasoning, the orbit remains in the interior at every stage relevant to the reconstruction.

Now solve the first equation. Since $L(x)$ is known and $x$ lies in $(0,1)$, the quadratic formula says that $x$ must equal either

$$
B_0(L(x)) \quad\text{or}\quad B_1(L(x)).
$$

That choice supplies the first bit. Apply the same argument to $L(x)$ to obtain the next bit, and continue. After $n$ stages, the original seed has been assigned a binary word and is exactly its decoded value. Every seed in the fiber therefore appears in the constructed list.

Together, existence, uniqueness, and exhaustion give a bijection

$$
\{0,1\}^n
\longleftrightarrow
\{x\in(0,1):L^n(x)=y\}.
$$

Since the set of binary words has size $2^n$, the fiber has size $2^n$.

## A small numerical journey

Choose $y=0.7$. Its two immediate predecessors are approximately

$$
B_0(0.7)\approx 0.2261387,
\qquad
B_1(0.7)\approx 0.7738613.
$$

They are reflections across $1/2$, as the identity $B_1(y)=1-B_0(y)$ predicts. Going backward once more produces four seeds. Going backward six steps produces $64$. Each seed follows a different itinerary through the lower and upper halves of the interval, yet all arrive exactly at $0.7$ after six forward iterations.

Numerical arithmetic adds a practical caveat. In exact real arithmetic these values are distinct. On a computer, rounding may merge close branches. That is not a contradiction; it is a new finite-precision phenomenon layered on top of the exact theorem. The mathematical tree has $2^n$ leaves, while a finite grid may identify several leaves as the same stored number.

## Determinism without reversibility

The result clarifies an often-misunderstood feature of chaos. Forward evolution is deterministic: one seed produces one next state. Backward evolution is not single-valued because the map folds the interval. Each step erases one bit of branch information—whether the previous state lay below or above $1/2$.

After $n$ steps, an interior observation has lost exactly $n$ such bits. Recovering a past requires supplying a binary itinerary of length $n$. The count $2^n$ is therefore not an accidental feature of a quadratic equation; it is the combinatorial signature of repeated folding.

This distinction matters whenever a nonlinear dynamical system is used for inference or security. If an observer sees only a later exact state, that observation alone cannot identify the initial seed: there are exactly $2^n$ compatible interior seeds after $n$ transitions. Any prediction depending only on the observed suffix must treat those histories identically. Yet one should not leap from ambiguity to cryptographic safety. Finite precision, side information, parameter leakage, and output design can all destroy the idealized symmetry.

## The boundary of the theorem

The assumptions $0<y<1$ are essential. At $y=1$, the two inverse branches coincide at $1/2$ because $\sqrt{1-y}=0$. At $y=0$, inverse images reach the endpoints $0$ and $1$, outside the open interval used in the theorem. The complete binary tree therefore degenerates at boundary targets.

This explains why the proof continually protects interiority. It is not technical decoration; it is the condition that keeps both branches alive and separated. A future boundary classification should count the collisions explicitly rather than pretending the interior formula still applies.

## Hidden angles beneath the square roots

The logistic map at parameter $4$ has a trigonometric face. If

$$
x=\sin^2\theta,
$$

then

$$
L(x)=4\sin^2\theta\cos^2\theta=\sin^2(2\theta).
$$

Forward iteration doubles an angle, while backward iteration halves it and chooses among signs and shifts. This viewpoint suggests a closed formula for every binary address in terms of angles such as

$$
\sin^2\!\left(\frac{\pm\theta+k\pi}{2^n}\right).
$$

The inverse-branch theorem already supplies the exact tree that such a formula must index. Establishing a unique conversion between branch words and angular residues would turn the recursive description into a closed one.

The same change of variables points toward deeper statistical behavior. Uniform angles induce the arcsine density

$$
\frac{1}{\pi\sqrt{x(1-x)}}
$$

on $(0,1)$, suggesting why that density is invariant under the dynamics and why the average exponential separation rate is tied to $\log 2$.

## Beyond a list of roots

One could approach the equation $L^n(x)=y$ by expanding the iterate. Because each composition doubles the polynomial degree, $L^n(x)-y$ has degree $2^n$. That observation hints at the final count, but degree alone is not enough: it counts complex roots with multiplicity and does not guarantee that every root is real, distinct, or inside $(0,1)$.

The inverse-tree description supplies exactly what the degree argument lacks. It constructs $2^n$ real interior solutions, gives each one a meaningful binary label, proves that the labels never collide, and proves that no other interior solutions exist. Instead of confronting one enormous polynomial, it solves the same problem through $n$ transparent quadratic choices. The method exposes not only how many roots there are, but also why they are there and how to compute each one.

This distinction is useful in applications. A mere cardinality says how much ambiguity exists. A branch address says which itinerary produced a candidate, allows candidates to be generated without polynomial expansion, and reveals the precise piece of information erased at each forward step.

## A complete answer to a backward question

The central achievement is a sharp answer to a simple question: how many exact interior histories lead to a given interior present? For the map $L(x)=4x(1-x)$, after $n$ steps the answer is always exactly $2^n$.

The proof mirrors the dynamics. The quadratic fold creates two explicit inverse branches. Binary words compose them into candidate histories. The midpoint separates different first choices, proving uniqueness. The quadratic formula assigns a choice to every possible history, proving completeness.

A chaotic present does not merely conceal its past vaguely. In this system, it conceals it with exact exponential precision.