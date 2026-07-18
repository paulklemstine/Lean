# Tropical Cryptocurrency: Mining on the Min-Plus Semiring

## When “addition” means choosing the smaller number

Cryptographic hashing is usually presented as a digital blender. Feed it a message, and a thicket of bitwise operations turns that message into an apparently patternless fingerprint. Change one bit, and the fingerprint should change unpredictably. Running the blender forward is easy; reversing it or finding two inputs with the same output should be forbiddingly hard.

Tropical mathematics begins from a different instinct. Instead of making arithmetic more complicated, it changes two of its most familiar operations. In the **min-plus semiring**, tropical addition is the minimum,

$$
a\oplus b=\min(a,b),
$$

while tropical multiplication is ordinary addition,

$$
a\otimes b=a+b.
$$

This arithmetic appears naturally in shortest paths, scheduling, logistics, dynamic programming, and discrete-event systems. If route lengths are combined in series, they add; if several routes compete, the shortest wins. Tropical algebra packages that optimization logic into an algebraic language.

That makes a provocative cryptocurrency thought experiment possible: could mining be based on tropical optimization rather than conventional bit mixing? Consider a message with $k$ real coordinates,

$$
m=(m_1,\ldots,m_k),
$$

and a key

$$
h=(h_1,\ldots,h_k).
$$

Define the single-key tropical hash by

$$
T_h(m)=\min_{1\le i\le k}(m_i+h_i).
$$

It can be evaluated in one scan through the coordinates, so its running time is $O(k)$. At first glance, inversion might seem to require discovering which coordinate supplied the hidden minimum. Perhaps that search could resemble a shortest-path problem. Perhaps adding a second independent key could suppress collisions.

The mathematics gives a sharp answer: neither hope survives for unrestricted real messages. The failure is not a subtle statistical weakness. It is written directly into the geometry of the minimum.

## The exact anatomy of an output

Suppose the hash output is $y$. What must the message satisfy? Since $y$ is the minimum of the $k$ values $m_i+h_i$, every one of those values must lie at or above $y$, and at least one must equal $y$. Conversely, those two conditions clearly force the minimum to be $y$.

This is the **Exact Fiber Theorem**:

> For any nonempty finite message and any real key, $T_h(m)=y$ if and only if $y\le m_i+h_i$ for every coordinate $i$, and $m_p+h_p=y$ for at least one coordinate $p$.

The set of all messages producing $y$ is called the **fiber** over $y$. Solving the inequalities gives an especially transparent description:

$$
m_i\ge y-h_i\quad\text{for every }i,
$$

with equality in at least one coordinate. Thus the fiber is the boundary formed by selected faces of the translated orthant

$$
\prod_{i=1}^k [y-h_i,\infty).
$$

This picture changes the computational story completely. Inversion is not an exponential hunt through tropical paths. A preimage can be written down immediately:

$$
m_i=y-h_i\qquad(1\le i\le k).
$$

Then every coordinate sum is exactly $y$, so their minimum is $y$. This yields the **Canonical Preimage Theorem**: every real target has an explicit preimage. Consequently, the map $T_h:\mathbb{R}^k\to\mathbb{R}$ is surjective for every key $h$.

The construction takes $O(k)$ arithmetic operations, the same asymptotic cost as evaluating the hash. For this model, forward computation is easy and inversion is equally easy. The proposed one-way property therefore fails at the most basic level.

## Why collisions are everywhere

A collision consists of two different messages with the same output. Tropical minima create such messages in abundance.

Choose a coordinate $p$ that attains the minimum. Now select another coordinate $q\ne p$ and increase $m_q$ by any amount $d\ge0$. The winning value at $p$ is untouched. The altered value at $q$ can only rise, so it cannot create a new value below the old minimum. Every other coordinate is unchanged. Therefore the hash remains exactly the same.

This is the **Inactive-Coordinate Update Principle**:

> If $m_p+h_p=T_h(m)$ and $q\ne p$, then replacing $m_q$ by $m_q+d$ for any $d\ge0$ leaves $T_h(m)$ unchanged.

The word “inactive” is revealing. A minimum records a winner but forgets almost everything about the losing coordinates. Once one coordinate certifies the output, many others may move through whole rays without leaving the fiber. Information is not scrambled; it is discarded.

## Two keys do not create diffusion

A natural repair is to use two independent keys $h$ and $h'$ and return the ordered pair

$$
T_{h,h'}^{(2)}(m)=\left(\min_i(m_i+h_i),\ \min_i(m_i+h'_i)\right).
$$

One might hope that a coordinate invisible to the first component would be exposed by the second. In dimension at least three, however, two minima can protect at most two chosen witnesses.

Pick $p$ attaining the first minimum and $r$ attaining the second. When $k\ge3$, there is a coordinate $q$ different from both $p$ and $r$; if $p=r$, there are even more choices. Increase $m_q$ by $1$. The witness $p$ still fixes the first output, and the witness $r$ still fixes the second. The message changed, but neither output did.

Hence the **Universal Two-Key Collision Theorem** states:

> For every dimension $k\ge3$, every pair of real keys $h,h'$, and every message $m\in\mathbb{R}^k$, there exists a distinct message $m'$ with $T_{h,h'}^{(2)}(m')=T_{h,h'}^{(2)}(m)$.

The theorem is deterministic. It does not say collisions occur with high probability, or after many trials, or for unlucky keys. It says every starting message has a collision for every pair of keys. Moreover, the proof gives an algorithm: scan each key to locate one minimizing coordinate, choose a third coordinate, and raise it. The work is $O(k)$.

This refutes the proposed estimate that two-key collision resistance might approach $1-O(1/k)$. In the unrestricted real-vector model, no probabilistic qualification is needed: universal collisions occur whenever $k\ge3$.

## A smooth shape made from sharp corners

Tropical hashing still possesses elegant optimization geometry. For two coordinates, define

$$
f(x_0,x_1)=\min(x_0,x_1).
$$

For vectors $v,w\in\mathbb{R}^2$ and $t\in[0,1]$, the **Pairwise Concavity Theorem** states

$$
\min\big((1-t)v_0+tw_0,(1-t)v_1+tw_1\big)
\ge (1-t)\min(v_0,v_1)+t\min(w_0,w_1).
$$

In words, the minimum of two affine coordinate functions is concave along every line segment. A direct proof chooses whichever coordinate is smaller at each endpoint: both interpolated coordinates lie above the corresponding interpolation of the endpoint minima, so their minimum does too.

Concavity is valuable in optimization, but it is not cryptographic diffusion. Here it coexists with broad flat directions and collision rays. That distinction matters. A function may be geometrically structured, computationally convenient, and useful for shortest-path reasoning while being entirely unsuitable as a hash.

## A small example with a large warning

Take the message $m=(8,1,6,3,10)$ and two keys $h=(0,7,2,9,4)$ and $h'=(6,3,8,0,5)$. For the first key, the shifted values are

$$
(8,8,8,12,14),
$$

so the first output is $8$. For the second key they are

$$
(14,4,14,3,15),
$$

so the second output is $3$. The fourth coordinate witnesses the second minimum, while the first or third can witness the first. Choose the second coordinate as a free direction and increase it from $1$ to $101$. The first list changes only from $8$ to $108$ at that location; the value $8$ still survives elsewhere. The second list changes from $4$ to $104$ there; the value $3$ still survives at the fourth coordinate. The output pair remains $(8,3)$.

This example is not a lucky collision found by sampling. It is one visible instance of the general construction. The increment could be $1$, $100$, or a million, giving infinitely many distinct messages on the same collision ray. Random testing might report a striking empirical collision rate, but the theorem explains more: a collision can be manufactured from every input by preserving witnesses and moving an unused coordinate.

## Mining as mathematics—after redesign

The negative result does not make tropical cryptocurrency a dead idea. It identifies the precise obstacle a serious design must overcome. Independent coordinatewise minima do not couple the message coordinates. Each output component remembers only an active witness, and untouched coordinates remain free to move.

A better construction would need constraints or circuit layers that make coordinates interact. Messages might be restricted to a discrete alphabet; nonce changes might be tied together by linear or graph constraints; or nonlinear tropical circuits might repeatedly reuse coordinates so that changing one entry propagates to several active comparisons. In those settings, hardness—if it appears—would come from coupling, not from taking a minimum.

This is a useful lesson beyond cryptography. Optimization primitives often compress information by reporting an optimum while forgetting the alternatives. That is exactly what makes them efficient summaries, but it can be fatal when unpredictability and collision resistance are required. The minimum is an excellent answer to “which route is shortest?” It is a poor answer to “what was the entire network?”

Tropical mining therefore offers a compelling design principle in reverse. Before asking whether a new arithmetic can power a cryptocurrency, first map its fibers: characterize every input with the same output, find their unbounded directions, and test whether extra outputs truly create diffusion. Here that analysis is complete. Every scalar target has an immediate preimage, and every two-key message in dimension at least three lies on a collision path.

Mining can still be mathematics. But secure mining cannot merely rename an optimization minimum as a hash. It must build a mechanism in which the mathematics preserves difficulty rather than erasing information.