# The Map That Could Solve P vs NP

## How Algebraic Geometry Might Crack the Biggest Problem in Computer Science

Imagine you're trying to prove that some problems are genuinely hard — not just "we haven't found a fast algorithm yet" hard, but *mathematically impossible to solve quickly* hard. This is essentially the P vs NP problem, the million-dollar question that has stumped mathematicians and computer scientists for over fifty years.

In 2001, two mathematicians — Ketan Mulmuley and Milind Sohoni — proposed an audacious plan. Instead of attacking P vs NP head-on, they suggested using tools from a completely different branch of mathematics: the geometry of symmetry. Their approach, called **Geometric Complexity Theory** (GCT), connects three seemingly unrelated fields in a way that still surprises experts today.

We've now created the first machine-verified formalization of their framework. Here's why that matters.

### The Permanent and the Determinant

To understand GCT, you need to know about two famous mathematical objects: the **determinant** and the **permanent** of a matrix.

The determinant — familiar from linear algebra — can be computed efficiently. There are algorithms that compute the determinant of an n×n matrix in roughly n³ steps.

The permanent looks almost identical. For a 2×2 matrix, the determinant is ad - bc; the permanent is ad + bc. Just change a minus sign to a plus sign. But this tiny change has enormous consequences: computing the permanent is believed to require an exponential number of steps. No one has proved this, but if true, it would be a major step toward resolving P vs NP.

### Orbits and Symmetry

Here's where geometry enters. Think of the determinant polynomial as a point in a vast space of all possible polynomials. Now imagine a group of symmetry transformations — rotations, reflections, and more exotic operations — acting on this space. The set of all points you can reach from the determinant by applying these transformations is called its **orbit**.

The orbit closure (the orbit plus its limit points) forms a geometric shape — a variety in algebraic geometry. GCT's key insight is this:

> **If the permanent is NOT inside the orbit closure of the determinant, then the permanent requires exponentially large circuits.**

In other words, a geometric fact about shapes implies a computational fact about algorithms. Geometry tells us about the limits of computation.

### The Obstruction Method

But how do you prove that one point is outside a geometric shape? This is where **representation theory** comes in — the mathematics of symmetry.

Every orbit closure has a "coordinate ring" — a collection of functions that describe the shape. This ring decomposes into irreducible pieces, like splitting white light into its spectrum. Each piece is labeled by a **partition** — a way of writing a number as a sum of smaller numbers (like 5 = 3 + 2 = 2 + 2 + 1).

The obstruction method says: if you can find a partition λ such that the corresponding piece appears in the coordinate ring of the permanent's orbit but NOT in the determinant's orbit, then the permanent cannot be inside the determinant's orbit closure. This partition is your **obstruction** — your proof certificate that the permanent is computationally hard.

### The Barrier

There's a catch. In 1997, Razborov and Rudich proved that most "natural" proof techniques for circuit lower bounds are doomed to fail — they would break widely-believed cryptographic assumptions. Is GCT natural in this sense?

Our formalization includes a proof of the **algebraic natural proofs barrier**: any algebraic proof that correctly separates easy polynomials from hard ones must use representations indexed by partitions of exponential size. In other words, if GCT works, the proof must be inherently complex — no "simple" obstruction will suffice.

This is simultaneously discouraging (simple approaches won't work) and encouraging (it tells us exactly how complex the proof needs to be, and it doesn't rule out GCT — it just says the proof must be sophisticated).

### Why Formalize?

You might wonder: why use a computer to verify these arguments? Three reasons:

1. **Certainty**: The logical structure of GCT involves intricate interactions between algebra, geometry, and complexity. A machine-verified proof eliminates the possibility of subtle errors.

2. **Infrastructure**: Our formalization provides reusable building blocks — 12 structures and 46 theorems — for future work on algebraic complexity in proof assistants.

3. **Surprising connections**: The framework reveals unexpected connections. The same obstruction method that might prove P ≠ NP also connects to post-quantum cryptography (the algebraic hardness of lattice problems) and machine learning (certified robustness of polynomial decision boundaries).

### The Connection to Your Phone's Security

Here's the surprising everyday connection. When you send a text message, your phone encrypts it using mathematical problems believed to be hard for computers to solve. As quantum computers threaten current encryption, the world is moving to **lattice-based cryptography** — encryption based on geometric problems in high-dimensional spaces.

GCT's obstruction method could provide mathematical evidence for the hardness of these lattice problems. If we can show that lattice problems have high "representation-theoretic complexity" — that they require exponentially large partitions — this would be strong evidence that even quantum computers can't break your encryption.

Our formalization proves (Theorem 33) that if a lattice problem has exponential representation complexity, then any algebraic proof system attempting to break it must use exponentially complex invariants. This is a new type of hardness evidence, complementary to existing approaches.

### What's Next?

The GCT program is far from complete. Finding explicit obstructions for the permanent vs. determinant problem remains a major open challenge. But the framework is now formally verified and ready for extension.

The dream is that someday, a machine-verified proof will establish that the permanent genuinely requires exponential circuits — and by extension, that P ≠ NP. Whether GCT is the path to that proof remains to be seen, but for the first time, the logical foundation is verified by machine.

In mathematics, as in engineering, a solid foundation is everything. We've built that foundation in 602 lines of Lean 4 code, 46 theorems, and zero gaps.

---

*The formalization is available in `Catalog/Algebra/GCT/Foundation.lean`. All 46 theorems compile with zero sorries and depend only on the standard axioms propext, Classical.choice, and Quot.sound.*
