# The Easy Way Back: What the Collatz Map Teaches Us About Cryptography

The Collatz map is famous for making arithmetic look unpredictable. Start with a positive integer. If it is even, divide it by two; if it is odd, triple it and add one. Repeat. A starting value may plunge, surge, and wander before apparently reaching $1$. The assertion that every positive starting value eventually does so is the Collatz conjecture, one of the most accessible unsolved problems in mathematics.

That air of unpredictability naturally invites a cryptographic thought. Modern cryptography often relies on a task that is easy in one direction and hard in the other. Multiplying two large primes is easy; recovering them from their product appears hard. Iterating a turbulent arithmetic rule is also easy. Could the endpoint of a long Collatz walk hide its starting point?

The answer for the unrestricted Collatz map is a decisive no. The reason is not a subtle attack, a faster search, or a weakness visible only on special machines. It is a one-line route backward that works for every target and every number of steps. Moreover, the map contains infinitely many explicit collisions: distinct inputs that merge immediately and can never be separated by further iteration.

This negative result is useful. It identifies exactly what a future dynamical cryptosystem would need to change.

## The map and the proposal

For a nonnegative integer $n$, define

$$
T(n)=
\begin{cases}
n/2, & \text{if $n$ is even},\\
3n+1, & \text{if $n$ is odd}.
\end{cases}
$$

Write $T^a(n)$ for the result of applying $T$ exactly $a$ times, with $T^0(n)=n$. The proposed cryptographic function is therefore

$$
F_a(n)=T^a(n),
$$

where the depth $a$ plays the role of a security parameter. Forward evaluation takes exactly $a$ elementary Collatz steps. The hoped-for asymmetry was that, given $a$ and $y=F_a(n)$, recovering some suitable $n$ would require exploring a rapidly branching reverse tree.

At first glance that reverse tree looks awkward. An output may have an even predecessor, an odd predecessor, both, or—under additional restrictions—neither. But one predecessor never disappears.

## The universal backward lane

Every nonnegative integer $y$ has the predecessor $2y$, because

$$
T(2y)=y.
$$

The number $2y$ is even, so the map simply halves it. Apply the same observation repeatedly. The number $2^a y$ follows an all-even trajectory:

$$
2^a y\longmapsto 2^{a-1}y\longmapsto\cdots\longmapsto 2y\longmapsto y.
$$

This gives the central inversion theorem.

**Explicit Inversion Theorem.** For every pair of nonnegative integers $a$ and $y$,

$$
T^a(2^a y)=y.
$$

The proof is induction on $a$. The case $a=0$ is immediate. If the identity holds at depth $a$, then the first step from $2^{a+1}y=2(2^a y)$ halves the input to $2^a y$, after which the remaining $a$ steps reach $y$.

Thus an inverter does not search at all. Given $(a,y)$, it returns

$$
I_a(y)=2^a y.
$$

Using ordinary binary arithmetic, this is especially simple: multiplying by $2^a$ appends $a$ zero bits. The output has $a$ more bits than $y$, up to the usual convention for zero, and can be produced in time linear in the output length. The proposed exponential reverse search is bypassed rather than accelerated.

The same construction has a useful compositional law:

$$
I_{a+b}(y)=I_a(I_b(y)).
$$

Indeed, both sides equal $2^{a+b}y$. In mathematical language, $I_a$ is a right inverse, or section, of $F_a$: first apply $I_a$, then $F_a$, and every target returns unchanged. It follows at once that every iterate $F_a$ is surjective. Every nonnegative integer is an output, at every depth.

Surjectivity by itself does not destroy one-wayness; many cryptographic permutations are surjective. The fatal fact is the efficient, explicit section. In the unrestricted inversion problem, a valid preimage is always available by a shift in binary notation.

## Collisions hiding in plain sight

A collision is a pair $x\ne z$ with the same image. The Collatz map has an infinite family of them. For every nonnegative integer $k$, consider

$$
x_k=2k+1,\qquad z_k=12k+8.
$$

The first number is odd and the second is even. Their images are

$$
T(2k+1)=3(2k+1)+1=6k+4
$$

and

$$
T(12k+8)=\frac{12k+8}{2}=6k+4.
$$

The inputs are distinct because the equation $2k+1=12k+8$ would imply $10k=-7$, impossible for a nonnegative integer. We therefore obtain the following result.

**Parameterized Collision Theorem.** For every $k\ge 0$, the distinct integers $2k+1$ and $12k+8$ have the same one-step Collatz image.

The smallest example is striking:

$$
T(1)=4=T(8).
$$

Once two trajectories meet, deterministic iteration keeps them together. If $T(x)=T(z)$, then for every $b\ge 0$,

$$
T^{b+1}(x)=T^b(T(x))=T^b(T(z))=T^{b+1}(z).
$$

Hence the collision is not washed away by longer iteration. It persists forever.

**Persistent Collision Theorem.** For every positive depth $a$, there are distinct nonnegative integers with equal images under $T^a$. In particular, $1$ and $8$ collide under every positive iterate.

It follows that no positive iterate is injective. More importantly for hashing, an adversary does not need to discover a collision by chance. The formulas above manufacture infinitely many collisions, and any of them survives every common suffix of Collatz steps. Longer iteration cannot turn the raw family $F_a$ into a collision-resistant hash.

## Why the Collatz conjecture does not help

The Collatz conjecture concerns the forward fate of positive integers: each orbit is predicted eventually to reach $1$. The inversion problem asks a different question: given a target and an exact depth, can one find a point that lands there after that many steps?

These issues are logically separate. Even if every positive orbit converges, the all-even reverse lane remains intact. For every $a$ and $y$, the number $2^a y$ still lands on $y$ after exactly $a$ steps. The inverter neither uses nor challenges convergence.

This distinction is a recurring lesson in cryptography. Apparent disorder in typical forward trajectories does not imply computational hardness. A system can look turbulent while retaining a hidden structural shortcut. Hardness must be tied to a precise input distribution, output encoding, size restriction, and computational task—not to visual complexity alone.

## What exactly has been ruled out?

The conclusion is sharp rather than sweeping.

**Unrestricted Cryptographic Obstruction.** At every positive depth $a$, the raw function $F_a(n)=T^a(n)$ has both of the following properties:

1. every target $y$ has the explicit preimage $2^a y$;
2. distinct inputs collide, for example $F_a(1)=F_a(8)$.

Consequently, unrestricted iteration cannot supply the proposed one-way function, because inversion has an explicit total algorithm. It also cannot supply the proposed collision-resistant raw hash family, because collisions are explicit and persistent.

This does not prove that every cryptographic design inspired by Collatz dynamics must fail. The canonical preimage grows with $a$. If inputs are required to stay inside a fixed bit-length interval, then $2^a y$ may be inadmissible. Likewise, a carefully designed domain separator might exclude the known odd-even collision families. Such modifications define new problems, and their security would need new arguments.

## A better research program

Negative results can be design tools. Here, the formulas identify two precise interfaces that must be redesigned: which reverse points count as valid answers, and which inputs are permitted to meet. That is far more informative than observing that a collection of experiments looks random or difficult. It turns a vague security hope into a checklist of mathematical obligations.

The obstruction points toward four concrete directions.

First, study **length-preserving inversion**. Sample a $b$-bit input and require the recovered preimage to have the same bit length. The universal answer $2^a y$ may then lie outside the permitted interval. Reverse odd steps, divisibility by three, and parity constraints become genuinely relevant.

Second, measure the **entropy of reverse parity words**. A reverse trajectory can be described by choices of even and odd branches, but most words fail arithmetic congruence tests. Counting admissible words may reveal average-case structure that forward convergence cannot provide.

Third, investigate **domain separation and compression**. Any candidate must eliminate the whole family

$$
T(2k+1)=T(12k+8),
$$

not merely hide a few small examples. The persistent family is an adversarial test suite for proposed constructions.

Fourth, abstract the lesson beyond Collatz. Whenever an iterated dynamical system has an efficiently computable section at every depth, unrestricted inversion is easy. Whenever it has an efficiently parameterized collision stable under iteration, its raw iterates cannot be collision resistant. These are general structural warning signs.

There is also a practical lesson about the meaning of “inversion.” An attacker usually need not recover the particular secret input that produced an observed output; finding any accepted preimage can be enough. The canonical answer $2^a y$ may be unrelated to the original input, but it satisfies the unrestricted verification equation exactly. A security definition that intends otherwise must say so—for example, by requiring an answer in the original sampling interval. Precision in the game changes the mathematics.

The bit-level viewpoint removes one final illusion. Although $2^a$ grows exponentially as an ordinary number, writing $2^a y$ in binary does not require exponentially many symbols. It shifts the digits of $y$ left by $a$ places. Numeric magnitude is not computational cost; representation length is. This distinction is fundamental throughout modern cryptography.

The most valuable outcome of testing a cryptographic idea is not always a new cipher. Sometimes it is a clean impossibility result that replaces intuition with architecture. The Collatz map still guards its famous forward mystery. But as an unrestricted one-way function, it leaves the back door wide open: double once for each requested reverse step, and walk straight through.
