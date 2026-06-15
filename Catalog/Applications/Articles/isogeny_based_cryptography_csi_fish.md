# The Secret Symmetry That Could Save Encryption From Quantum Computers

*How mathematicians are using the hidden structure of elliptic curves to build cryptography that even quantum computers can't crack*

---

In the summer of 2017, a group of cryptographers quietly released a paper that would ripple through the world of cybersecurity. Their creation, called CSIDH (pronounced "sea-side"), proposed a fundamentally new way to exchange secrets over the internet — one that would remain secure even against the terrifying power of quantum computers. But the mathematics behind it reaches back centuries, to one of the most beautiful ideas in all of algebra: the theory of group actions.

## The Quantum Threat

Every time you check your bank balance, send a private message, or make an online purchase, your information is protected by encryption. And nearly all of today's encryption rests on a single mathematical assumption: that certain problems — like factoring enormous numbers into primes — are practically impossible for classical computers to solve.

But quantum computers don't play by classical rules. In 1994, Peter Shor showed that a sufficiently powerful quantum computer could factor any number in polynomial time, shattering the mathematical foundation of RSA, Diffie-Hellman, and elliptic curve cryptography. The race to find "post-quantum" alternatives has been one of the most urgent challenges in modern mathematics.

## Islands in a Sea of Curves

The key idea behind CSIDH comes from the geometry of elliptic curves — smooth, doughnut-shaped objects defined by simple polynomial equations. Over a finite field (arithmetic modulo a prime number), these curves form a rich algebraic landscape. Among them, the *supersingular* curves stand out: they are rare, rigid, and possess an unusually rich internal structure.

Imagine these supersingular curves as islands in a vast ocean. Between certain pairs of islands, there exist bridges called *isogenies* — special maps that preserve the algebraic structure of the curves. What makes this geography remarkable is that these bridges form a highly organized network. The pattern of connections is governed by a hidden symmetry group: the *ideal class group* of an imaginary quadratic number field.

This class group acts on the set of curves the way rotations act on the vertices of a polygon. Every element of the group slides every curve to a different curve, and crucially, this action is both *free* (no curve is fixed by any non-identity element) and *transitive* (you can get from any curve to any other). Mathematicians call such an action a *torsor* — a set that "looks like" the group but has no preferred origin.

## The Handshake Protocol

CSIDH exploits this torsor structure for key exchange. Alice and Bob each choose a secret element of the class group. Alice applies her secret to a publicly known base curve to get her public curve, and Bob does the same. Then Alice applies her secret to Bob's public curve, and Bob applies his to Alice's. Because the class group is *abelian* (its elements commute), both arrive at the same shared curve — their shared secret.

The security rests on the *Group Action Inverse Problem* (GAIP): given two curves connected by an unknown class group element, find that element. This is believed to be hard even for quantum computers, because unlike factoring or discrete logarithms, GAIP has no known efficient quantum algorithm.

## A Deeper Kind of Hardness

One of the most striking properties of GAIP — and one that has now been formally proven — is its *random self-reducibility*. This means that the hardness of GAIP is uniform: if any instance of the problem is hard, then every instance is equally hard.

The proof relies on a beautiful observation. Given a GAIP instance — a pair of curves (E₀, E₁) connected by an unknown element s — one can "rerandomize" it by applying any group element r to both curves, obtaining a new instance (r·E₀, r·E₁). Because the group is abelian, the new instance has exactly the same solution s. This means that if you could solve GAIP on random instances, you could solve it on any specific instance by simply rerandomizing.

This property is rare and valuable in cryptography. It means that the average-case hardness of GAIP equals its worst-case hardness — a guarantee that most cryptographic assumptions lack. It's the difference between knowing that some lock is hard to pick versus knowing that every lock of this design is hard to pick.

## From Identification to Signatures

CSIDH provides key exchange, but modern cryptography needs more: digital signatures. This is where CSI-FiSh enters the picture. CSI-FiSh transforms CSIDH's key exchange into a signature scheme through the *Fiat-Shamir transform*, a general technique that converts interactive identification protocols into non-interactive signatures.

The identification protocol works like a game. The prover (who knows the secret key) makes a random commitment, the verifier sends a random challenge bit, and the prover responds. The key security property is *special soundness*: from two valid transcripts with different challenges on the same commitment, anyone can extract the secret key. This means a cheating prover who doesn't know the secret can succeed with probability at most 1/2.

By running this protocol in parallel — say, 128 times — the cheating probability drops to 2⁻¹²⁸, providing 128-bit security. The signature consists of all 128 commitment-response pairs, with the challenges derived by hashing the message and commitments together.

## The Architecture of Security

The formal verification of these security properties reveals an elegant mathematical architecture. The connector between two curves — the class group element that maps one to the other — satisfies a remarkable algebra. Connectors compose like group elements, invert like inverses, and shift predictably when the action is applied. These connector laws form a complete algebraic toolkit for reasoning about CSIDH security reductions.

For instance, the proof that signature forgery reduces to GAIP works by showing that two valid signatures with different challenge vectors on the same commitments yield the secret key through a simple algebraic extraction. This extraction uses nothing more than the group law and the freeness of the action — no number theory, no analysis, just pure algebra.

## The Road Ahead

CSIDH and CSI-FiSh represent one of the most promising approaches to post-quantum cryptography, but challenges remain. The class group computation needed for parameter selection is itself a hard problem, and the efficiency of CSIDH implementations depends on carefully chosen parameters. Recent work has explored the structure of the isogeny graph — the Cayley graph of the class group action — including its expansion properties and diameter.

A tantalizing conjecture suggests that for the simplest model of the isogeny graph (the cyclic group ℤ/nℤ with generators ±1), the diameter is exactly ⌊n/2⌋. This has been verified computationally for many values of n, but a general proof remains elusive. Understanding the graph-theoretic properties of isogeny graphs is crucial for analyzing the mixing time of random walks, which in turn affects the security of certain isogeny-based protocols.

The decomposition of the class group into cyclic factors — guaranteed by the structure theorem for finite abelian groups — directly determines the key space of CSIDH. With k cyclic factors of orders d₁, ..., dₖ, the class number h = d₁ ··· dₖ satisfies h ≥ 2ᵏ. This exponential growth means that even a modest number of small prime ideals can generate a key space large enough for cryptographic security.

## The Beauty of the Mathematics

What makes isogeny-based cryptography so compelling is not just its resistance to quantum attacks, but the depth and elegance of the mathematics it draws upon. The theory of class groups, developed by Gauss, Dedekind, and Hilbert over more than two centuries, finds a new application in the most modern of settings. The torsor structure, studied by algebraic geometers and number theorists, becomes the foundation for secure communication.

The random self-reducibility of GAIP — the theorem that worst-case equals average-case — is a statement about the deep homogeneity of the isogeny landscape. It says that there are no "easy spots" in the space of GAIP instances, no lucky inputs that a clever algorithm might exploit. Every instance is as hard as every other, a uniformity of difficulty that speaks to the fundamental symmetry of the underlying mathematics.

As the world prepares for the quantum computing era, the ancient mathematics of imaginary quadratic fields and ideal class groups stands ready to protect our digital future. The curves may be abstract, the groups may be invisible, but the security they provide is as real as a locked door.

---

*The research described in this article includes formal mathematical proofs of the random self-reducibility of GAIP, the t-special soundness of CSI-FiSh, and the equivalence between GAIP hardness and one-wayness of the CSIDH map, along with the first formalization of subgroup orbit structure in the isogeny setting.*
