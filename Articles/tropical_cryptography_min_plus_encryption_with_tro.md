# The Secret Life of Shortest Paths: Why "Tropical" Cryptography Isn't as Safe as It Looks

## A different kind of arithmetic

Imagine an arithmetic in which addition and multiplication are not the operations you learned in school. Instead, "adding" two numbers means *taking the smaller of them*, and "multiplying" two numbers means *adding them in the ordinary sense*. This strange-sounding system is called the **tropical semiring** (or **min-plus algebra**), and despite its playful name — coined in honor of the Brazilian mathematician Imre Simon — it is a serious and beautiful piece of mathematics with deep connections to optimization, geometry, and computer science.

To keep the two worlds straight, we write $\oplus$ for tropical addition and $\otimes$ for tropical multiplication:

$$
x \oplus y = \min(x, y), \qquad x \otimes y = x + y.
$$

The numbers themselves are the integers together with an extra symbol $\infty$, which plays the role of a "zero" for this arithmetic: $\min(x, \infty) = x$, just as $x + 0 = x$ in ordinary arithmetic. And the ordinary number $0$ plays the role of the tropical "one," because $x \otimes 0 = x + 0 = x$.

Why would anyone bother with such a thing? Because it turns hard combinatorial questions into clean algebraic ones. The single most important example is **shortest paths**. If you weight the roads of a map and want the cheapest route between two cities, you are — without knowing it — doing tropical arithmetic. Every time you compare two routes you take a *minimum* (tropical addition); every time you extend a route by one more road you *add* a distance (tropical multiplication). This is the secret that makes the tropical world tick, and, as we will see, it is also the secret that unravels a tempting idea for building codes.

## A tempting idea: encryption from the tropics

Modern cryptography rests on **one-way functions**: computations that are easy to perform but effectively impossible to reverse. The most famous example underlies the Diffie–Hellman key exchange, which lets two strangers, Alice and Bob, agree on a shared secret over a public channel that everyone can hear. Its security rests on the *discrete logarithm problem*: given a number $g$ and a power $g^k$, it is believed to be very hard to recover the exponent $k$.

In the last decade, researchers asked a natural question: could we replace ordinary numbers with **tropical matrices** and get a new, possibly quantum-resistant, cryptosystem? The plan is seductively simple. Fix a public tropical matrix $A$. Alice secretly picks an exponent $a$ and publishes the tropical power $A^{\otimes a}$; Bob secretly picks $b$ and publishes $A^{\otimes b}$. Each then raises the other's matrix to their own secret exponent, and both arrive at the same shared key $A^{\otimes ab}$. An eavesdropper who sees $A$, $A^{\otimes a}$, and $A^{\otimes b}$ would — so the hope goes — be unable to recover the secret exponents.

Computing a tropical matrix power is genuinely cheap: by repeated squaring one reaches $A^{\otimes k}$ in about $\log k$ matrix multiplications, so the honest parties do only $O(n^3 \log k)$ arithmetic. The entire security of the scheme therefore hinges on one question, the **tropical discrete logarithm problem (TDLP)**:

> Given the public matrix $A$ and one of its tropical powers $B = A^{\otimes k}$, recover the exponent $k$.

Is this really hard? This article tells the story of two theorems that answer the question — and the answer is not comforting for the would-be cryptographer.

## Tropical matrices *are* shortest paths

First we need to understand what a tropical matrix power actually *computes*. Ordinary matrix multiplication combines rows and columns using $+$ and $\times$. Tropical matrix multiplication does the same bookkeeping but with $\oplus = \min$ and $\otimes = +$:

$$
(A \otimes B)_{ij} = \min_{\ell}\bigl(A_{i\ell} + B_{\ell j}\bigr).
$$

Read this out loud: to get from $i$ to $j$ in two steps, try every intermediate stop $\ell$, add the cost of the first leg to the cost of the second, and keep the cheapest total. That is exactly the recursive definition of a shortest two-step route in a weighted graph whose adjacency matrix is $A$.

The first of our two theorems says this pattern holds at every power, not just the second. It is completely general — it holds in *any* arithmetic where you have an "add" and a "multiply" satisfying the usual distributive laws — and only afterward do we specialize to the tropics.

**Theorem 1 (Powers count walks).** *Let $A$ be an $n \times n$ matrix over any commutative semiring, indexed by a set $V$ of vertices. Then the $(i,j)$ entry of the $k$-th power is a sum over all length-$k$ walks from $i$ to $j$:*
$$
\bigl(A^{k}\bigr)_{ij} = \sum_{\substack{p_0, p_1, \ldots, p_k \\ p_0 = i,\; p_k = j}} \ \prod_{t=0}^{k-1} A_{p_t\, p_{t+1}}.
$$
*Here a "walk" is any sequence of $k+1$ vertices starting at $i$ and ending at $j$, and the product runs over the $k$ edges it traverses.*

In ordinary arithmetic this is the familiar fact that the powers of an adjacency matrix count paths. But translate the sum and product into tropical language — turn each $\sum$ into a $\min$ and each $\prod$ into a $+$ — and it becomes something far more evocative:

$$
\bigl(A^{\otimes k}\bigr)_{ij} = \min_{\text{length-}k\text{ walks } i \to j} \ \sum_{t=0}^{k-1} A_{p_t\, p_{t+1}}.
$$

**The $(i,j)$ entry of the $k$-th tropical power is the minimum total weight of a $k$-step walk from $i$ to $j$.** This is precisely the identity at the heart of the classical Bellman–Ford and Floyd–Warshall shortest-path algorithms. A tropical matrix power is not an abstract object at all — it is a table of shortest $k$-step distances.

This already sounds an alarm. An eavesdropper facing $B = A^{\otimes k}$ is not staring at random noise; they are staring at a shortest-path table, and shortest-path structure is exactly what a century of algorithmic graph theory knows how to exploit.

## The fatal leak: eigenvalues that add up

The second theorem delivers the decisive blow. To state it we need the tropical analogue of an eigenvalue. In ordinary linear algebra, $\lambda$ is an eigenvalue of $A$ with eigenvector $v$ when $A v = \lambda v$. Tropically, the same equation reads

$$
A \otimes v = \lambda \otimes v, \qquad \text{that is,} \qquad \min_{j}\bigl(A_{ij} + v_j\bigr) = \lambda + v_i \ \text{ for every } i.
$$

Here $\lambda$ is a single number — the **tropical eigenvalue** — and $v$ is the corresponding eigenvector. Geometrically, $\lambda$ measures the "cost per step" of cycling through the graph forever along the most efficient loop; it is the minimum cycle mean.

Now watch what happens when we take powers. If $A \otimes v = \lambda \otimes v$, then applying $A$ again gives $A^{\otimes 2} \otimes v = \lambda \otimes \lambda \otimes v$, and in general the eigenvector survives every power while the eigenvalue simply repeats. In tropical language, "repeating $\lambda$ $k$ times under $\otimes$" means *adding $\lambda$ to itself $k$ times* — ordinary multiplication. That is the content of our second theorem.

**Theorem 2 (Tropical eigenvalues are additive under powering).** *Suppose $v$ is a tropical eigenvector of $A$ with eigenvalue $\lambda$, so that $A \otimes v = \lambda \otimes v$. Then for every exponent $k$, the same $v$ is a tropical eigenvector of $A^{\otimes k}$, and its eigenvalue is*
$$
\lambda\bigl(A^{\otimes k}\bigr) = k \cdot \lambda(A).
$$
*(In ordinary numbers: the min-plus eigenvalue of the $k$-th power is exactly $k$ times the min-plus eigenvalue of $A$.)*

This is where the discrete logarithm dies. The whole point of a discrete-logarithm-style problem is that the exponent $k$ should be buried, recoverable only by brute force. But Theorem 2 hands the attacker a linear equation. The eigenvalue $\lambda(A)$ of the public matrix can be computed quickly — it is the minimum cycle mean of a weighted graph, obtainable by classical algorithms such as Karp's. The eigenvalue $\lambda(B)$ of the intercepted power $B = A^{\otimes k}$ can be computed just as quickly. And then the secret exponent falls out of a single division:

$$
k = \frac{\lambda\bigl(A^{\otimes k}\bigr)}{\lambda(A)}, \qquad \text{provided } \lambda(A) \neq 0.
$$

No brute force, no quantum computer, no clever number theory — just two shortest-path computations and one division. The would-be one-way function leaks the secret through its spectrum.

## Where the danger hides — and where it doesn't

The attack has one visible loophole: it requires $\lambda(A) \neq 0$ in the tropical sense (that is, the minimum cycle mean must be a genuine finite nonzero number, not $\infty$). If the public matrix is engineered so that its tropical eigenvalue vanishes or is undefined, the division above becomes meaningless and this particular attack stalls.

But that observation is a warning, not a rescue. It tells us that *any* tropical scheme hoping to be secure must actively avoid the entire family of matrices with usable eigenvalues — and Theorems 1 and 2 together show just how much structure a tropical power carries even when the eigenvalue trick is blocked. The shortest-path identity of Theorem 1 means the public data $B = A^{\otimes k}$ still encodes a rich combinatorial object that shortest-path and cycle-detection algorithms can pick apart. Historically, this is exactly what has happened: the earliest tropical Diffie–Hellman proposals were broken, patched with random perturbations, and broken again. Our two theorems explain *why* at the structural level: the tropical world is transparent to the very algorithms — shortest paths, minimum cycle means — that gave it life.

## The moral of the story

There is a lovely irony here. The tropical semiring is powerful *precisely because* it linearizes optimization: shortest paths, scheduling problems, and dynamic programming all become matrix algebra. That same linearization is poison for cryptography, whose lifeblood is the *absence* of exploitable structure. A good one-way function must look like chaos; a tropical matrix power looks like a shortest-path table with an eigenvalue stamped on its forehead.

The two theorems in this article draw a bright line between three mathematical worlds that rarely meet in the same sentence:

- **Linear algebra** (matrix powers),
- **Combinatorial optimization** (shortest walks in weighted graphs), and
- **Spectral theory** (eigenvalues and cycle means).

Theorem 1 fuses the first two: a matrix power *is* a catalogue of walks, and tropically a catalogue of shortest walks. Theorem 2 fuses the first and third: taking powers multiplies the tropical eigenvalue, turning an exponent into a simple linear coefficient.

For the cryptographer, the lesson is sobering but valuable: min-plus algebra, in its raw form, is the wrong soil for a one-way function, because its beautiful transparency is exactly the property an attacker needs. For the mathematician, the lesson is exhilarating: the same handful of ideas that route packets across the internet and schedule trains through a network also decide, in a single elegant stroke, the fate of a cryptographic dream. Sometimes the deepest security question is really a question about shortest paths — and the tropics answer it in the open.
