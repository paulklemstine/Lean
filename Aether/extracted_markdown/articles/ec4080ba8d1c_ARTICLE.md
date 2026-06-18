# The Algebra of Shortest Paths: How Tropical Mathematics Could Secure the Post-Quantum Internet

*A mathematical structure from optimization theory offers a radically new approach to cryptography — one that doesn't rely on the factoring problem, discrete logarithms, or lattice geometry.*

---

## A World Without Subtraction

Imagine a world where addition means "pick the smaller number" and multiplication means "add them together." In this world, 3 + 7 = 3 (because 3 is smaller), while 3 × 7 = 10 (because 3 + 7 = 10 in ordinary arithmetic). Subtraction doesn't exist — you can never "undo" taking a minimum. Division is trivial — since multiplication is just addition, dividing is just subtracting.

This isn't a mathematical curiosity. It's called **tropical arithmetic**, named whimsically after the Brazilian mathematician Imre Simon, and it's the natural language of optimization. When a GPS system computes the shortest route from your house to the airport, it's performing tropical matrix multiplication. When a logistics company optimizes package delivery across a network of warehouses, it's computing tropical matrix powers. When a biologist traces the most likely evolutionary pathway between species, the underlying computation is tropical.

Now, a growing community of mathematicians and computer scientists is asking a provocative question: could tropical arithmetic also protect our most sensitive digital communications?

## The Cryptographic Cliff

Modern internet security rests on a handful of mathematical problems that computers find extremely hard to solve. When you check your bank balance online, your browser encrypts the connection using algorithms whose security depends on the difficulty of factoring very large numbers, or computing discrete logarithms in finite groups. These problems have withstood decades of attack by the world's best mathematicians and most powerful supercomputers.

But there's a cliff approaching. Quantum computers, when they reach sufficient scale, will demolish these protections. Peter Shor's quantum algorithm can factor large integers and compute discrete logarithms in polynomial time — shattering the mathematical bedrock of RSA, Diffie-Hellman, and elliptic curve cryptography in one stroke.

The race to develop "post-quantum" cryptography — encryption schemes secure against quantum adversaries — is one of the most urgent challenges in computer science. The National Institute of Standards and Technology (NIST) has been evaluating candidates since 2016, focusing primarily on lattice-based schemes, hash-based signatures, and code-based systems.

But what if there's an entirely different mathematical foundation for security, one that quantum algorithms can't efficiently attack?

## The Shortest Path That's Hard to Trace

Here's the key insight behind tropical cryptography: while computing the shortest path in a network is efficient, *recovering the structure of the network from shortest-path information* is extraordinarily hard.

Consider a network of cities connected by roads with known distances. Given the network, you can efficiently compute the shortest distance between any two cities — that's just tropical matrix multiplication. Computing the shortest distances using roads of exactly *k* legs is tropical matrix powering: raise the adjacency matrix to the *k*-th power.

The tropical matrix power A^k can be computed in O(n³ log k) time using repeated squaring — fast and practical. But here's the puzzle that makes cryptographers excited: given a tropical matrix A and its *k*-th power A^k, recovering the exponent *k* appears to be computationally intractable. This is the **Tropical Discrete Logarithm Problem (TDLP)**, and it's the foundation of tropical Diffie-Hellman key exchange.

## How Tropical Diffie-Hellman Works

Alice and Bob want to establish a shared secret key over a public channel. They agree on a public tropical matrix G — think of it as a public road network. Alice picks a secret number *a* and publishes G^a (the network of *a*-step shortest paths). Bob picks a secret number *b* and publishes G^b.

The magic: Alice can compute (G^b)^a = G^(ba), and Bob can compute (G^a)^b = G^(ab). Since *ab = ba*, they arrive at the same shared key G^(ab). An eavesdropper sees G, G^a, and G^b, but recovering *a* or *b* requires solving the TDLP.

## Beyond Logarithms: The Conjugacy Shield

But there's a vulnerability in the basic scheme. The TDLP can sometimes be broken using a clever shortcut: tropical eigenvalues. Just as classical matrices have eigenvalues that reveal their structure, tropical matrices have a spectral theory based on **minimum cycle means** — the average weight of the lightest cycle in the associated graph.

If a matrix A has tropical eigenvalue λ, then A^k has eigenvalue kλ. So if you can compute eigenvalues efficiently, you can recover *k* by simple division: k = λ(A^k) / λ(A). This attack works whenever the eigenvalue is nonzero and computable.

Enter the **Tropical Conjugacy Problem (TCP)** — a fundamentally harder challenge. Instead of hiding a single scalar exponent, the TCP hides an entire matrix. Given a tropical matrix A, "conjugate" it by a secret invertible matrix S to produce B = S ⊗ A ⊗ S⁻¹. The challenge: given A and B, recover S.

This is exponentially harder than the TDLP for a simple reason: recovering S requires determining n² unknown entries (an entire matrix), not just one number. The key space grows as n! — the number of permutations on n vertices — which exceeds 2^(n/2) for all n ≥ 2. For n = 35, the key space exceeds 2^128, providing 128-bit security.

## A Key Exchange That Hides Everything

The Tropical Conjugacy Key Exchange (TCKE) protocol exploits this hardness:

1. **Public setup**: A generator matrix G is published.
2. **Alice** chooses a secret permutation matrix S_A (and its inverse T_A). She publishes her "conjugated generator" A_pub = S_A ⊗ G ⊗ T_A.
3. **Bob** chooses his own secret permutation S_B (and inverse T_B). He publishes B_pub = S_B ⊗ G ⊗ T_B.
4. **Shared key**: Alice computes S_A ⊗ B_pub ⊗ T_A. Bob computes S_B ⊗ A_pub ⊗ T_B. When their permutations commute, both arrive at the same shared key.

The mathematical proof that this works relies on a beautiful structural result: **conjugation preserves the power structure**. If B = S ⊗ A ⊗ T with S ⊗ T = I, then B^k = S ⊗ A^k ⊗ T for all k. The conjugating matrices "wrap around" any power computation, protecting the internal structure.

## Why Tropical is Different

What makes tropical cryptography genuinely novel — not just another variant of existing schemes?

**No lattice structure.** Lattice-based cryptography, the leading post-quantum approach, relies on the hardness of finding short vectors in high-dimensional lattices. Tropical hardness comes from a completely different source: the combinatorial explosion of paths in weighted directed graphs. There's no known reduction between the two.

**No subtraction.** The min-plus semiring lacks additive inverses — you cannot "undo" a minimum operation. This idempotency (min(a,a) = a, not 2a) breaks the algebraic leverage that quantum Fourier transforms exploit. Shor's algorithm fundamentally relies on the group structure of modular arithmetic; tropical arithmetic isn't a group under addition, so the attack surface is entirely different.

**Natural one-way functions.** The asymmetry between tropical matrix multiplication (O(n³)) and its inversion is inherent, not artificially constructed. Every tropical matrix product represents a shortest-path computation, and recovering a factor from the product requires solving a tropical polynomial system — a problem whose complexity grows super-polynomially.

## What Remains to Be Proven

Tropical cryptography is still in its infancy. Several critical questions remain open:

1. **Is the TDLP truly hard for random matrices?** The eigenvalue attack breaks specific instances. Are there families of matrices for which all known attacks fail?

2. **Can the TCP resist quantum attacks?** While there's no known quantum algorithm that breaks it, a rigorous proof of quantum hardness remains elusive.

3. **What are the right parameters?** For practical deployment, we need concrete security parameters: how large must matrices be for 128-bit, 256-bit security?

4. **Can we build full public-key encryption?** The current schemes provide key exchange. Building encryption, signatures, and zero-knowledge proofs requires more work.

## The Deeper Vision

The significance of tropical cryptography extends beyond any single protocol. It represents a paradigm shift: the idea that the mathematics of *optimization* — shortest paths, minimum costs, efficient routing — can serve as a foundation for *security*. The same structures that power GPS navigation and supply-chain logistics might one day protect our digital lives.

There's a poetic symmetry here. The internet was built on networks, and its security may ultimately depend on the mathematics of networks — not the number theory that currently underpins it, but the tropical geometry that captures the deep structure of paths, cycles, and flows.

The algebra of shortest paths may prove to be the longest-lasting defense we have.

---

*This article describes research on tropical cryptographic primitives formalized in the min-plus semiring framework, building on work by Grigoriev, Shpilrain, and others in tropical geometry and computational algebra.*
