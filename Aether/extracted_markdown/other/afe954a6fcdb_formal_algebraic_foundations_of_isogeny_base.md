# The Hidden Algebra Behind Post-Quantum Cryptography

## How mathematicians are using abstract symmetry to build codes that even quantum computers can't crack

In 2017, the National Institute of Standards and Technology issued an urgent call. Quantum computers, long a theoretical curiosity, were advancing rapidly enough to threaten the mathematical foundations of internet security. RSA, Diffie-Hellman, elliptic curve cryptography — the protocols that safeguard every online transaction — all rely on problems that a sufficiently powerful quantum computer could solve in minutes. NIST needed replacements. It needed *post-quantum* cryptography.

Among the candidates that emerged was a family of schemes built on one of the most beautiful objects in modern algebra: the *isogeny graph* of supersingular elliptic curves. These protocols — CSIDH, CSI-FiSh, and their descendants — don't rely on factoring large numbers or computing discrete logarithms. Instead, they derive their security from the difficulty of navigating a vast, symmetric, deeply connected mathematical labyrinth.

## The Labyrinth of Curves

Imagine a landscape populated by elliptic curves — the smooth, doughnut-shaped surfaces that mathematicians have studied since the 19th century. Not all elliptic curves are created equal. A special class called *supersingular* curves, defined over finite fields, forms a tightly interconnected network. Each curve connects to its neighbors through *isogenies* — structure-preserving maps that transform one curve into another while respecting the underlying arithmetic.

This network is the isogeny graph, and it possesses a remarkable property: it looks the same from every vertex. Mathematically, a large symmetry group — the *class group* of an imaginary quadratic order — acts on the set of curves, shuffling them around like a perfectly balanced deck of cards. Every curve can reach every other curve. No curve is special. The group action is *free* and *transitive*: each group element moves every curve to a unique destination, and any two curves are connected by exactly one group element.

This is what mathematicians call a *torsor*, or principal homogeneous space. It's the algebraic equivalent of a perfectly uniform labyrinth where every path looks the same, where there are no landmarks, where the only way to know your location is to remember exactly how you got there.

## Three Properties, One Protocol

The CSIDH key exchange protocol, proposed in 2018 by Castryck, Lange, Martindale, Panny, and Renes, distills the cryptographic potential of this labyrinth into three algebraic properties:

**Freeness**: If a group element fixes any curve, it must be the identity. This means the "public key map" — which takes a secret group element and produces a public curve — is injective. No two secrets produce the same public key.

**Transitivity**: Any curve can be reached from any other. This means the public key map is also surjective. Every curve is somebody's public key.

**Commutativity**: The class group is abelian — the order of operations doesn't matter. This is what makes key exchange possible. Alice applies her secret to Bob's public curve, Bob applies his secret to Alice's public curve, and they arrive at the same shared secret.

These three properties — freeness, transitivity, commutativity — are sufficient for a complete cryptographic ecosystem. Key exchange, digital signatures, commitment schemes, and identification protocols all follow from this abstract trinity.

## The Connector and the Inverse Problem

At the heart of every security argument is a single object: the *connector*. Given any two curves *x* and *y* in the torsor, there exists a unique group element *g* that maps *x* to *y*. Computing this connector — the *Group Action Inverse Problem* (GAIP) — is believed to be hard, even for quantum computers.

The connector satisfies elegant algebraic identities. It composes like a path: the connector from *x* to *z* equals the product of the connector from *y* to *z* and the connector from *x* to *y*. It inverts cleanly: the connector from *y* to *x* is the inverse of the connector from *x* to *y*. And it satisfies a beautiful *triangle identity*: for any three curves *x*, *y*, *z*, the product of the three connectors around the triangle equals the identity element.

These are the cocycle conditions of Čech cohomology, appearing naturally in a cryptographic context. The connector is a 1-cocycle for the group action, and its algebraic properties are precisely what make security proofs work.

## The Twist: An Unexpected Involution

Supersingular curves carry an additional piece of structure that has no analogue in classical Diffie-Hellman: the *quadratic twist*. Every curve has a "mirror image" obtained by negating a certain coordinate. This twist is an involution — applying it twice returns to the original curve — and it interacts with the class group action in a precise, beautiful way: twisting a curve and then applying a group element gives the same result as applying the *inverse* group element and then twisting.

This twist-action compatibility has deep consequences. It means the connector between two twisted curves is the *inverse* of the connector between the original curves. The twist "reverses the direction" of the group action. This property is crucial for several advanced protocols and for understanding the security landscape of isogeny-based cryptography.

## Beyond Key Exchange: Commitments and Signatures

The group action structure supports far more than key exchange. A *commitment scheme* — the cryptographic equivalent of a sealed envelope — can be built directly from the torsor. To commit to a message, choose a random group element and publish two curves derived from the message and the randomness. The binding property — that you can't change the message after committing — reduces directly to the hardness of GAIP.

Digital signatures follow from an identification scheme called CSI-FiSh (Class group actions with Isogenies, using the Fiat-Shamir heuristic). A prover demonstrates knowledge of a secret key through a challenge-response protocol. The crucial property is *special soundness*: from any two accepting conversations with different challenges, an extractor can compute the secret key. This is a deep algebraic fact, not a computational one — it follows directly from freeness and the uniqueness of the connector.

## The Vectorization Problem

A natural question arises: is GAIP the *hardest* problem one can build from this structure? The answer appears to be no. The *vectorization problem* — given three curves *x₀*, *a·x₀*, *b·x₀*, compute *(a·b)·x₀* without knowing *a* or *b* — is the group-action analogue of the computational Diffie-Hellman problem. Solving GAIP immediately solves vectorization (compute the connectors, multiply, act), but the converse is not known to hold.

This creates a hierarchy of hardness assumptions, paralleling the well-known hierarchy in classical cryptography (discrete log → CDH → DDH). The *decisional* variant — distinguishing *(a·b)·x₀* from a random curve — sits at the top, providing the strongest security guarantees but also the strongest assumptions.

## A Labyrinth That Expands

Perhaps the most remarkable property of the isogeny graph is that it is an *expander graph* — in fact, a Ramanujan graph, the best possible expander. This means that random walks on the graph mix rapidly, reaching a near-uniform distribution in just a logarithmic number of steps. The expansion property is what makes the computational problems hard: there are no shortcuts through the labyrinth, no clusters of nearby curves that an algorithm could exploit.

The Cayley graph diameter — the maximum distance between any two vertices — is precisely ⌊n/2⌋ for the cyclic group ℤ/nℤ. This simple fact, verified computationally for dozens of group orders, illustrates a deeper principle: the labyrinth is as connected as it could possibly be, with every vertex reachable in the minimum possible number of steps.

## The Road Ahead

Isogeny-based cryptography sits at a fascinating intersection of algebraic number theory, graph theory, and computational complexity. The class group — an object studied by Gauss, Dedekind, and Hilbert for purely mathematical reasons — turns out to encode exactly the properties needed for post-quantum security.

Open questions abound. What is the true quantum complexity of GAIP? Can the vectorization problem be separated from GAIP? Does the Ramanujan property of isogeny graphs provide provable quantum lower bounds? These questions connect post-quantum cryptography to some of the deepest problems in mathematics, from the Riemann hypothesis (which controls the size of class groups) to the theory of automorphic forms (which explains the expansion properties of the graph).

The algebraic foundations are now firmly in place, verified by machine and tested against computation. What remains is to understand how deep the labyrinth truly goes — and whether any algorithm, classical or quantum, can find its way through.
