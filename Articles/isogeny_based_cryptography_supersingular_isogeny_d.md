# The Lock That Was Picked: How Mathematicians Broke the Quantum-Proof Code

## A seemingly unbreakable cryptographic system, inspired by the deep geometry of elliptic curves, was spectacularly cracked in 2022 — and the story reveals profound truths about mathematical security.

---

In the summer of 2022, two Belgian mathematicians shattered what many believed to be one of the most promising shields against quantum computers. Wouter Castryck and Thomas Decru, working at KU Leuven, published a short paper showing that the Supersingular Isogeny Diffie-Hellman key exchange — SIDH for short — could be broken in about an hour on a standard laptop. The system had been under development for over a decade. Hundreds of millions of dollars in research had flowed into isogeny-based cryptography. And then, in a few pages of breathtaking mathematics, it was over.

The story of SIDH's rise and fall is more than a tale of cryptographic failure. It is a window into how abstract mathematics — the kind most people would never encounter — directly shapes the digital infrastructure of modern civilization. And the vulnerability that killed SIDH teaches a lesson that resonates far beyond mathematics: sometimes, giving away too much information, even information that seems harmless, can be fatal.

### The Quantum Threat

To understand why SIDH existed, you need to understand the looming crisis in cryptography. Most of the encryption protecting the internet — your bank transactions, your medical records, your private messages — relies on mathematical problems that are hard for classical computers but easy for quantum ones. RSA encryption, for example, depends on the difficulty of factoring large numbers. Elliptic curve cryptography relies on the discrete logarithm problem. Both would fall instantly to a sufficiently large quantum computer running Shor's algorithm.

The race to build quantum computers is accelerating. While we don't yet have machines large enough to crack real-world encryption, the consensus among cryptographers is that it's a matter of when, not if. This has sparked an urgent search for "post-quantum" cryptographic systems — encryption methods that remain secure even against quantum adversaries.

### Islands in a Sea of Numbers

SIDH was born from one of the most beautiful areas of mathematics: the theory of elliptic curves. An elliptic curve is defined by a simple equation — something like y² = x³ + ax + b — but the geometry and algebra that emerge from these equations are staggeringly rich. Elliptic curves have connections to number theory, algebraic geometry, and even string theory.

Among all elliptic curves defined over finite fields, there is a special class called *supersingular* curves. These are curves whose endomorphism ring — roughly, the collection of all symmetries of the curve — is unusually large. Over a prime field, there are approximately p/12 supersingular curves, where p is the characteristic.

Now here's where it gets interesting. You can draw a *graph* connecting these supersingular curves. Two curves are connected by an edge if there exists an *isogeny* between them — a special kind of map that preserves the group structure. For a fixed prime ℓ, the resulting ℓ-isogeny graph has remarkable properties: it is a *Ramanujan graph*, meaning it has optimal expansion properties. Random walks on this graph mix rapidly, reaching a near-uniform distribution in just O(log p) steps.

Think of the supersingular isogeny graph as a vast, tangled network of islands connected by bridges. Each island is a curve, each bridge is an isogeny. The graph is so well-connected that starting from any island and taking random bridges, you quickly lose track of where you started. This property — the near-impossibility of tracing your path backward through the maze — was the foundation of SIDH's security.

### The Key Exchange

The SIDH protocol, proposed by Luca De Feo, David Jao, and Jérôme Plût in 2011, works like this. Alice and Bob start at the same island (the same starting curve E₀). Alice picks a secret path through the 2-isogeny part of the graph, arriving at some curve E_A. Bob picks a secret path through the 3-isogeny part, arriving at E_B. They exchange their destinations publicly.

Then comes the clever part. Alice uses her secret to compute a new curve from Bob's public curve, and Bob does the same with Alice's public curve. The deep mathematical fact — the commutativity of the two group actions — guarantees that they both arrive at the same final curve. The j-invariant of this curve is their shared secret.

An eavesdropper sees only the starting curve and the two public curves. To recover the secret, they would need to find the path connecting two islands in the isogeny graph — the *isogeny path problem*. For properly chosen parameters, the best known algorithms required exponential time, even on a quantum computer.

### The Fatal Gift

But SIDH had a secret vulnerability, hidden in plain sight. To make the protocol work, Alice and Bob needed to exchange more than just their public curves. Alice also had to reveal *where she sent Bob's torsion points* — specific points on the curve that generate the kernel of Bob's isogeny.

This auxiliary data — φ_A(P_B), φ_A(Q_B), and φ_A(P_B - Q_B) — seemed harmless. After all, it was just three points on a curve. But these three points carried within them the ghost of Alice's secret path, encoded in a form that could be extracted by someone who knew where to look.

The analogy is striking: imagine a spy who must pass through a series of locked rooms to reach a secret vault. Even if no one can follow the spy through the rooms, if the spy is required to report what happened to certain objects in each room, a clever observer might be able to reconstruct the entire route.

### The Breakthrough

Castryck and Decru found that clever observer. Their insight was to *lift the problem to a higher dimension*. Instead of working with elliptic curves (dimension 1), they embedded the problem into the world of abelian surfaces (dimension 2).

The key was a theorem by Ernst Kani from 1997. Kani showed that certain pairs of endomorphisms of an elliptic curve whose degrees satisfy a particular identity can be used to construct a (2,2)-isogeny of the product E × E. Castryck and Decru realized that Alice's torsion data provided exactly the information needed to set up Kani's construction.

The coprimality of 2^eA and 3^eB — the very structure that made SIDH work — became its undoing. Because gcd(2^eA, 3^eB) = 1, each step in the decomposition of the product isogeny was uniquely determined. The (2,2)-isogeny could be factored step by step, like peeling layers off an onion, until Alice's secret isogeny was fully revealed.

The attack runs in polynomial time. For the parameters proposed for standardization, it takes about an hour on a laptop.

### The Deeper Lesson

The fall of SIDH reveals a fundamental tension in cryptographic design. The protocol needed torsion point data for correctness — without it, Bob couldn't compute his half of the shared secret. But this same data created a mathematical "back door" that an attacker could exploit.

Remarkably, protocols that do *not* reveal torsion point data — like CSIDH, which uses the full class group action — remain unbroken. The isogeny path problem, without auxiliary information, appears to be genuinely hard. The Deuring correspondence, which connects isogenies to quaternion algebras, suggests that the hardness is deeply rooted in the arithmetic of orders in quaternion algebras — one of the most impenetrable areas of algebraic number theory.

The quaternion connection is itself fascinating. Every supersingular elliptic curve has an endomorphism ring that forms a maximal order in a quaternion algebra B_{p,∞}. Finding an isogeny between two curves is equivalent to finding a connecting ideal between two such orders. This is the *quaternion isogeny path problem*, and its hardness is believed to be comparable to the isogeny path problem itself.

### What Survives

The story of SIDH is not a story of defeat for isogeny-based cryptography. It is a story of refinement. The mathematics of supersingular isogeny graphs — their Ramanujan expansion, their connection to quaternion algebras, their rich algebraic structure — remains as beautiful and useful as ever. New protocols like SQISign, which use the Deuring correspondence directly, have emerged as promising alternatives.

The Castryck-Decru attack also illustrates the power of Euler's four-square identity, which underpins the multiplicativity of the quaternion norm. This identity, known since the 18th century, connects the composition of isogenies to quaternion multiplication. It is the algebraic engine that makes the Deuring correspondence work.

Perhaps the deepest lesson is about the nature of mathematical security. In cryptography, security is not a static property — it is a dynamic relationship between the information you reveal and the problems you force an attacker to solve. SIDH revealed too much. The curves were strong; the bridges were impassable; but the spy had to report too many details about the journey, and a brilliant pair of mathematicians knew how to read the report.

The search for quantum-resistant cryptography continues, guided by the same abstract mathematics that built SIDH and the same abstract mathematics that broke it. In the end, our digital security rests on the deepest structures of number theory — structures that mathematicians have been exploring for centuries and that still hold countless surprises.

---

*The supersingular isogeny graph, with its optimal expansion and deep connections to quaternion algebras, remains one of the most remarkable objects in modern mathematics — a Ramanujan graph that mixes the concrete world of finite field arithmetic with the abstract heights of algebraic number theory.*
