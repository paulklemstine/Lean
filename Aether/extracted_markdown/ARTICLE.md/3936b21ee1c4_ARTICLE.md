# The Secret Mathematics Behind Quantum-Proof Cryptography

## How an obscure branch of number theory could protect the internet from quantum computers

---

In 2019, a team of mathematicians in Belgium published a paper with a peculiar name: CSI-FiSh. It wasn't about marine biology. The acronym stands for "Commutative Supersingular Isogeny based Fiat-Shamir," and it describes a digital signature scheme — a way to prove your identity online — that would remain secure even against quantum computers. The mathematics behind it reaches back to the 19th century, to ideas about hidden symmetries in the geometry of curves.

The story of CSI-FiSh is, at its heart, a story about group actions — one of the most powerful ideas in mathematics. And it reveals something remarkable: the same algebraic structures that fascinated mathematicians centuries ago may be the key to securing our digital future.

## The Quantum Threat

Every time you buy something online, log into your bank, or send an encrypted message, your security depends on mathematical problems that are hard to solve. The most widely deployed system, RSA, relies on the difficulty of factoring large numbers. Elliptic curve cryptography, the modern standard, relies on the difficulty of solving a different kind of problem involving points on curves.

Both of these will be broken by quantum computers.

In 1994, Peter Shor showed that a sufficiently powerful quantum computer could factor numbers and solve elliptic curve problems exponentially faster than any classical computer. While today's quantum machines aren't yet large enough to threaten real cryptographic systems, the consensus among experts is that this is a matter of engineering, not physics. The question isn't *whether* quantum computers will break current cryptography, but *when*.

This has created an urgent search for "post-quantum" cryptographic systems — schemes based on mathematical problems that remain hard even for quantum computers.

## A Walk Through the Garden of Curves

To understand CSI-FiSh, we need to visit a strange and beautiful mathematical landscape: the world of elliptic curves and isogenies.

An elliptic curve, despite its name, has nothing to do with ellipses. It's a curve defined by an equation like y² = x³ + ax + b, and for centuries, mathematicians have studied the remarkable algebraic structure of points on these curves. If you take two points on an elliptic curve and draw a line through them, that line intersects the curve at a third point. This operation gives the set of points the structure of a group — you can "add" points together.

Now, an *isogeny* is a special kind of map between two elliptic curves. Think of it as a bridge connecting one curve to another, preserving the group structure. If you imagine each elliptic curve as a city, isogenies are the roads between them. The collection of all curves and all isogenies forms a vast graph — the isogeny graph.

Here's where things get interesting. Among all elliptic curves, there is a special class called *supersingular* curves. These curves, defined over finite fields, have extraordinary properties. In particular, the isogeny graph of supersingular curves is remarkably well-connected — it's what mathematicians call an *expander graph*. No matter which two curves you pick, there's a relatively short path of isogenies connecting them.

## The Power of Commutativity

The mathematical innovation behind CSIDH (the key exchange protocol underlying CSI-FiSh) is the observation that the isogeny graph has a hidden symmetry.

Associated to each supersingular elliptic curve is an algebraic structure called its *endomorphism ring* — the collection of all self-maps of the curve. When we restrict attention to curves whose endomorphism ring equals a specific order 𝒪 in an imaginary quadratic number field, something magical happens: the *ideal class group* of 𝒪 acts on these curves.

A group action is one of the most fundamental concepts in mathematics. It means that each element of a group (in this case, each ideal class) can be applied to each object in a set (in this case, each curve) to produce another object. The class group action on supersingular curves has two crucial properties:

1. **Free**: No non-identity class fixes any curve. If an ideal class maps a curve to itself, it must be the trivial class.

2. **Transitive**: Any curve can be reached from any other by applying some ideal class.

Together, these properties make the set of curves a *torsor* (also called a principal homogeneous space) for the class group. This is the algebraic structure that makes everything work.

And there's one more essential property: the class group is **abelian** — its elements commute. If you apply ideal class *a* and then ideal class *b*, you get the same result as applying *b* first and then *a*. This commutativity is what enables a Diffie-Hellman-style key exchange.

## Building a Lock from Isogenies

CSIDH works like this. Alice and Bob publicly agree on a base curve E₀. Alice picks a secret ideal class *a* and publishes E_A = a · E₀ (the curve obtained by applying *a* to E₀). Bob picks a secret ideal class *b* and publishes E_B = b · E₀.

Now Alice computes a · E_B = a · (b · E₀), and Bob computes b · E_A = b · (a · E₀). Because the class group is commutative, these are the same curve: a · b · E₀ = b · a · E₀. They've agreed on a shared secret curve without ever revealing their private ideal classes.

The security of this scheme rests on the *Group Action Inverse Problem* (GAIP): given E₀ and a · E₀, find *a*. This appears to be hard even for quantum computers, because the structure of the class group action doesn't have the special properties that Shor's algorithm exploits.

## From Key Exchange to Signatures

CSI-FiSh turns this key exchange into a digital signature scheme using a classical technique called the Fiat-Shamir transform. The idea is elegant: to sign a message, you essentially prove that you know the secret key by engaging in a challenge-response protocol with a virtual verifier.

The prover picks a random ideal class *r* and publishes R = r · E₀ (the commitment). A challenge bit is derived from the message and the commitment. Depending on the challenge, the prover reveals either *r* (proving they computed R honestly) or r · s⁻¹ (which, combined with the public key, lets the verifier reconstruct R).

The crucial security property is *special soundness*: if an adversary can answer *both* challenges for the same commitment, they can recover the secret key. Specifically, from responses z₀ and z₁ to challenges 0 and 1, the secret is z₀ · z₁⁻¹. This is a theorem, not an assumption — it follows from the algebraic properties of the group action.

## The Map and the Territory

What makes this mathematical framework remarkable is its generality. The security proofs don't depend on specific properties of elliptic curves or isogenies — they work for *any* free, transitive action of a commutative group. The curves and isogenies provide a concrete instantiation, but the abstract structure could be filled in with entirely different mathematical objects.

This abstraction has practical consequences. It means that if someone discovers a new family of group actions with similar properties, the entire CSI-FiSh signature scheme can be transplanted to the new setting, security proofs and all. The algebraic skeleton is what matters.

Recent work has formalized this skeleton completely, establishing:

- **Unconditional collision resistance**: In any free action, the public key map has no collisions. This isn't an assumption — it's a mathematical theorem.
- **Equivalence of GAIP and one-wayness**: Inverting the public key map is *exactly* as hard as solving the Group Action Inverse Problem.
- **Multi-party generalization**: The key exchange extends to arbitrarily many parties, with any ordering of secret key applications yielding the same shared secret.
- **Regularity of isogeny graphs**: In a free action, every vertex in the Cayley graph has exactly the same number of neighbors — the graph is perfectly regular.

## Measuring the Unknown

One open question concerns the *diameter* of the isogeny graph — the maximum distance between any two curves. For the simplest cyclic groups, there's a clean conjecture: the diameter of ℤ/nℤ with generators {+1, -1} is exactly ⌊n/2⌋. Computational verification confirms this for all tested values.

The diameter matters because it determines the worst-case complexity of computing isogenies. If the diameter is small (polynomial in the security parameter), there might be efficient algorithms for GAIP. If it's large, the problem is likely hard. Understanding this boundary is one of the central challenges in isogeny-based cryptography.

## A Living Tradition

The mathematics behind CSI-FiSh draws from almost every major branch of pure mathematics: algebraic geometry (elliptic curves), algebraic number theory (ideal class groups), group theory (torsors and group actions), and graph theory (Cayley graphs and expansion). It's a vivid example of how abstract mathematics, developed without any practical application in mind, can suddenly become essential to technology.

Carl Friedrich Gauss studied quadratic forms and ideal classes in the early 1800s. He could not have imagined that his work would one day protect digital communications from machines that exploit quantum mechanics. But the mathematical structures he discovered — the symmetries, the group actions, the hidden order in seemingly chaotic arithmetic — turn out to be exactly what's needed.

As quantum computers inch closer to practical reality, the ancient mathematics of ideal class groups and isogenies may become as important to daily life as the prime numbers that currently guard our passwords. In the grand tradition of mathematics, the most useful ideas are often those that were pursued for their beauty alone.

---

*The research described here builds on the CSIDH protocol introduced by Castryck, Lange, Martindale, Panny, and Renes (2018), and the CSI-FiSh signature scheme of Beullens, Kleinjung, and Vercauteren (2019). The mathematical framework of group actions on sets has been studied since the work of Évariste Galois in the 1830s.*
