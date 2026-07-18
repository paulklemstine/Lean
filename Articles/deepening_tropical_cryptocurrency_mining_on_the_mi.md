# The Hash with an Escape Route

## Why min-plus arithmetic cannot hide a high-dimensional message behind too few numbers

Cryptocurrency mining is often described as a lottery played with enormous quantities of electricity. A miner repeatedly changes a nonce—a disposable number inside a candidate block—and evaluates a cryptographic hash. The winning nonce is one whose digest falls below a target. The crucial feature of an ordinary cryptographic hash is not that it looks complicated, but that no useful route through its input space is supposed to remain visible. Tiny changes should scramble the output, preimages should be difficult to find, and collisions should resist deliberate construction.

Now imagine replacing that machinery with a much simpler kind of arithmetic: tropical, or min-plus, arithmetic. In the min-plus world, “addition” means taking a minimum, while “multiplication” means ordinary addition. This algebra appears naturally in shortest-path problems, scheduling, transportation, and discrete-event systems. A path is assembled by adding edge lengths, and competing paths are compared by taking their minimum. It is elegant, useful, and computationally transparent.

That transparency is exactly what makes a basic min-plus digest unsuitable as a cryptographic hash.

Let a message be a real vector

$$
m=(m_1,\ldots,m_k)\in\mathbb{R}^k,
$$

and let a key be another real vector $h=(h_1,\ldots,h_k)$. Define one tropical hash component by

$$
T_h(m)=\min_{1\le i\le k}(m_i+h_i).
$$

The output is the cheapest of $k$ adjusted coordinates. To make a longer digest, choose $r$ keys $h^{(1)},\ldots,h^{(r)}$ and report

$$
D(m)=\bigl(T_{h^{(1)}}(m),\ldots,T_{h^{(r)}}(m)\bigr)\in\mathbb{R}^r.
$$

At first sight, several parallel minima might seem to offer protection. Each component views the message through a different key. Perhaps enough such views could tangle the message coordinates together. The central result shows a sharp structural failure whenever the digest has fewer components than the message has coordinates.

## One witness per output

Every minimum has a witness. For the $j$th digest component, choose an index $p_j$ satisfying

$$
m_{p_j}+h^{(j)}_{p_j}=T_{h^{(j)}}(m).
$$

There may be ties, so this witness need not be unique. That does not matter: choose one witness for each component. The resulting list $p_1,\ldots,p_r$ contains at most $r$ message coordinates.

If $r<k$, at least one coordinate $q$ is missing from the list. This is only the pigeonhole principle, but it exposes the entire weakness. Increase that unused coordinate by any amount $d\ge 0$, producing

$$
m(d)=(m_1,\ldots,m_{q-1},m_q+d,m_{q+1},\ldots,m_k).
$$

For every digest component, its chosen witness $p_j$ is untouched. Its value remains exactly the old minimum. Meanwhile, the only changed candidate, at coordinate $q$, has increased, so it cannot create a smaller minimum. Thus no component changes.

This yields the **Universal Collision-Ray Theorem**: for every family of $r$ min-plus keys on $k$ coordinates with $r<k$, and for every message $m\in\mathbb{R}^k$, there is a coordinate $q$ such that

$$
D(m(d))=D(m)\qquad\text{for every }d\ge 0.
$$

This is stronger than saying that a collision exists somewhere. The collision passes through every message. It is explicit. It extends without bound. And it requires no special choice of keys.

For every $d>0$, the altered message is genuinely different because its $q$th coordinate changes from $m_q$ to $m_q+d$. So the theorem immediately gives the **Positive-Ray Collision Result**: every positive point on the ray is a distinct message with the original digest.

There is more. If $d$ and $e$ are distinct positive numbers, then $m_q+d\ne m_q+e$, hence $m(d)\ne m(e)$. Therefore the map $d\mapsto m(d)$ is injective on the positive half-line. The **Injective Collision-Ray Result** says that every digest fiber—the set of all messages sharing one output—contains a one-to-one copy of $(0,\infty)$. Each fiber is not merely non-singleton or infinite in an abstract sense; it contains a continuously parameterized, unbounded family of collisions.

## A small example

Take $k=4$ message coordinates and $r=2$ digest components. Let

$$
m=(3,1,4,2),
$$

with keys

$$
h^{(1)}=(0,2,-1,3),\qquad h^{(2)}=(4,0,2,-2).
$$

For the first component, the adjusted values are

$$
(3,3,3,5),
$$

so we may choose coordinate $1$ as a minimizing witness. For the second they are

$$
(7,1,6,0),
$$

so coordinate $4$ is a minimizing witness. Coordinates $2$ and $3$ are unused by these choices. Choose $q=3$. Replacing $m_3=4$ by $4+d$ leaves the first component at $3$ and the second at $0$ for every $d\ge 0$. The messages

$$
(3,1,5,2),\quad (3,1,14,2),\quad (3,1,1004,2)
$$

all have digest $(3,0)$.

The example also illustrates why ties cause no difficulty. The first component has three minimizers, but preserving just one of them is enough. A minimum survives whenever at least one old witness survives and no modified candidate moves downward.

## The geometry behind the failure

A digest partitions $\mathbb{R}^k$ into fibers. For a conventional security intuition, one might hope these fibers are difficult to navigate or consist of isolated, elusive points. Min-plus fibers instead inherit polyhedral geometry. Each statement that coordinate $i$ realizes a minimum can be written as linear inequalities:

$$
m_i+h_i\le m_\ell+h_\ell\qquad\text{for all }\ell.
$$

Once active minimizing coordinates are selected, the message lies in a region cut out by such inequalities. The collision ray is a recession direction of that region: one can travel forever in that direction without leaving the fiber.

The theorem does not depend on numerical coincidences, randomness, or weak keys. It is driven by a mismatch of dimensions. Each output component needs only one coordinate to certify its minimum. With $r$ outputs, one can protect at most $r$ chosen coordinates. If $k>r$, some coordinate escapes all certificates.

This offers a useful engineering rule: parallel repetition does not automatically repair a structurally lossy primitive. Adding more tropical components helps only by consuming coordinates, one witness at a time. As long as the number of outputs remains below the input dimension, an escape route is guaranteed.

## Mining becomes navigation, not guessing

Suppose a tropical mining puzzle asks for a nonce-dependent message whose digest satisfies a target condition. The theorem does not by itself solve every nonce-restricted puzzle: a real message coordinate may not be freely adjustable if the nonce format allows only certain strings or bounded integers. But it identifies exactly where any difficulty must come from.

In the unrestricted model, the digest itself supplies no collision resistance. Once a minimizing witness for each component has been found—an operation requiring inspection of the adjusted coordinates—an unused coordinate can be identified and increased. For dense arrays, computing all $r$ minima takes $O(rk)$ arithmetic comparisons. Marking one witness per component and finding an unmarked coordinate takes $O(r+k)$ additional work. Producing any requested collision point then takes constant time if a message is represented with a single-coordinate update, or $O(k)$ time if the whole vector is copied.

In other words, the basic attack is not a probabilistic search. It is a deterministic certificate-and-escape algorithm.

Real cryptocurrency systems impose highly structured binary encodings and use hash functions designed to destroy algebraic visibility. A min-plus digest is better understood as an optimization summary than as a cryptographic compressor. It reports winning costs, not a scrambled fingerprint. Using it as a hash confuses two different virtues: efficient optimization and adversarial unpredictability.

## What the theorem does—and does not—say

The assumptions matter. Messages here range over all of $\mathbb{R}^k$, so the selected coordinate can always be increased. If coordinates are restricted to a bounded alphabet such as $\{0,1,\ldots,B\}$, the chosen coordinate may already equal $B$. Then the guaranteed ray can hit the boundary immediately. The right finite question involves available slack and the spread of the keys.

The strict inequality $r<k$ also matters. When $r\ge k$, the pigeonhole argument no longer guarantees an unused coordinate. This does not prove security in that regime; it merely removes this universal obstruction. Special keys, ties, or other degeneracies may still create collisions.

Nor does the one-ray result claim that a fiber has only one escape direction. Often several coordinates can be increased, perhaps simultaneously. The theorem guarantees at least one direction by selecting one witness per output. Determining the full recession cone requires understanding the combinatorics of all active minimizers. A natural expectation is that generic fibers possess about $k-r$ independent recession directions, but establishing the exact dimension requires a finer argument.

## A lesson beyond tropical hashing

The proof is short because the obstruction is conceptual. Whenever an output is assembled from local winners, ask how many input coordinates those winners can cover. If each of $r$ measurements can be certified by one untouched feature, then a $k$-dimensional input with $k>r$ may retain invisible directions.

This pattern appears in optimization summaries, winner-take-all networks, scheduling statistics, and systems built from minima or maxima. Such maps can be excellent for answering “what is the cheapest option?” while being poor at answering “which input produced this output?” Their fibers naturally contain flats, cones, and rays.

The tropical setting makes that geometry unusually clear. A single minimum turns a cloud of data into one winning value. A family of minima records several winners. But unless enough outputs collectively control all coordinates, some part of the message remains free to drift.

For tropical cryptocurrency, that drift is fatal to collision resistance. Every message comes with an escape route; every output fiber contains an unbounded continuum of distinct messages; and the route can be found by a simple deterministic scan. The min-plus semiring is powerful precisely because it reveals shortest paths. Here it reveals one path too many: a straight road through the hash, along which the digest never changes.
