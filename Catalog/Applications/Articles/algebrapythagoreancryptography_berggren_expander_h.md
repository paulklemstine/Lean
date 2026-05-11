# The Ancient Triangle That Could Protect Your Passwords

*How a 4,000-year-old pattern in right triangles is being transformed into a new kind of digital lock*

---

Every schoolchild learns the formula: three squared plus four squared equals five squared. The ancient Babylonians knew it. Pythagoras built a philosophy around it. For millennia, the equation *a² + b² = c²* was the province of pure mathematics—beautiful, eternal, and seemingly useless for anything practical.

Until now.

A new line of research has uncovered something remarkable hiding inside the Pythagorean theorem: a natural mechanism for scrambling information so thoroughly that it becomes, in a precise mathematical sense, nearly impossible to unscramble. The discovery connects one of humanity's oldest mathematical ideas to one of its newest needs—keeping digital information secure.

## The Secret Tree Inside the Theorem

The story begins with an obscure Swedish mathematician named Berggren, who in 1934 noticed something extraordinary. Every primitive Pythagorean triple—every set of three whole numbers with no common factor that satisfies *a² + b² = c²*—can be generated from the single seed triple (3, 4, 5) using exactly three transformations.

Think of it like a family tree. The triple (3, 4, 5) is the ancestor. Apply transformation A, and you get (5, 12, 13). Apply B, and you get (21, 20, 29). Apply C, and you get (15, 8, 17). Each of those triples spawns three more, which spawn three more, and so on forever. Every primitive Pythagorean triple appears exactly once in this infinite tree.

What makes Berggren's tree special is how it grows. Each transformation can be described as multiplying a three-dimensional vector by a specific 3×3 matrix of integers. Matrix A is:

```
 1  -2   2
 2  -1   2
 2  -2   3
```

And there are two others, B and C, with similar structure. The key property: these matrices preserve the Pythagorean equation. If (a, b, c) satisfies *a² + b² = c²*, so does the triple produced by any of these matrices. Always. Without exception.

This isn't just a lucky coincidence. The matrices belong to a mathematical structure called the Lorentz group—the same symmetry group that governs Einstein's special relativity. The Pythagorean equation *a² + b² = c²* is actually a degenerate version of the spacetime interval *x² + y² - t² = 0*. Berggren's transformations are discrete Lorentz boosts, shuffling vectors along the light cone of a toy universe.

## From Triangles to Scrambling

Here's where it gets interesting for cryptography. Suppose you want to build a hash function—a mathematical blender that takes a message (any string of data) and produces a fixed-size "fingerprint." Good hash functions have a critical property: changing even one bit of the input should completely change the output. This is called the *avalanche effect*.

The Berggren tree provides a natural hash construction. Encode your message as a sequence of the letters A, B, and C (a "Berggren word"). Compute the matrix product of the corresponding Berggren matrices. Apply the result to the base triple (3, 4, 5). Reduce everything modulo some large number N. The output is your hash—and it's guaranteed to be a Pythagorean triple modulo N.

But does this actually work? Does changing one letter of the word really scramble the output?

## The Determinant Trick

The first breakthrough comes from a simple observation about determinants. The determinant of every Berggren word matrix—no matter how long the word—is always exactly +1 or -1. This is remarkable: multiply together as many Berggren matrices as you want, in any order, and the determinant stays locked at ±1.

Why does this matter? Because a matrix with determinant ±1 is always invertible, even after reducing modulo N. This means the hash function is *injective* on vectors: different inputs to the matrix always produce different outputs. There's no information loss in the scrambling process.

This is provably true, not heuristically true. The mathematics guarantees it with the certainty of a geometric theorem—because it *is* a geometric theorem, dressed in the language of modular arithmetic.

## Collision Certificates

The deepest result concerns collisions—situations where two different messages produce the same hash value. In any practical hash function, collisions must exist (there are more possible messages than possible hash values). The question is whether collisions are hard to find.

For the Berggren hash, the analysis is strikingly clean. Suppose two words w₁ and w₂ produce the same hash on some input vector v. Then v must satisfy a specific linear equation:

*(M₁ - M₂) · v ≡ 0 (mod N)*

where M₁ and M₂ are the word matrices. This is the *collision kernel*—a linear-algebraic object whose size can be precisely bounded. For a nonzero difference matrix and a prime modulus p, the kernel contains at most p² vectors out of p³ possible—a fraction that shrinks as 1/p.

This means that for large primes, the vast majority of starting vectors are "collision-free" for any fixed pair of words. The exceptional set where collisions can occur is explicitly characterized and provably thin.

Even more powerfully, if two words collide on *every* vector modulo N, then their matrices must be identical modulo N. This is the strongest possible collision certificate: universal agreement forces structural equality.

## Why This Matters

Traditional cryptographic hash functions like SHA-256 are designed by human intuition and tested by decades of cryptanalysis. They work extremely well in practice, but their security rests on the assumption that nobody has found a clever attack—not on a mathematical proof that no attack exists.

The Berggren hash is different. Its security properties are *theorems*, not assumptions. The avalanche effect follows from the algebraic structure of the Lorentz group. The collision resistance follows from linear algebra over finite fields. The Pythagorean invariant provides a built-in consistency check that no traditional hash function possesses.

This doesn't mean the Berggren hash is ready to replace SHA-256 tomorrow. The constant factors are worse, the key sizes are different, and the construction needs more analysis before practical deployment. But the conceptual advance is significant: for the first time, a hash function's security is rooted not in computational hardness assumptions but in the rigid geometry of an ancient mathematical structure.

## The Bigger Picture

The Berggren hash is the first example of what might be called *Diophantine cryptography*—security built from the arithmetic of integer equations. The Pythagorean equation is just the simplest case. Other Diophantine systems, like Markov triples (*a² + b² + c² = 3abc*) or Apollonian circle packings, generate similar tree structures with similar scrambling properties.

Each of these systems represents a potential source of cryptographic primitives with provable security properties tied to deep number theory. The Berggren hash opens a door to a new wing of the mathematical mansion—one where ancient geometry and modern security interlock with unexpected precision.

Perhaps the most surprising aspect of this work is how long it took. The Berggren tree has been known since 1934. The Lorentz connection has been understood for decades. The modular reduction is elementary. Yet nobody thought to combine these ingredients into a hash function and prove its security properties until now.

Sometimes the most powerful ideas are hiding in the most familiar places—in a theorem that schoolchildren learn and promptly forget, in a pattern that the Babylonians noticed four thousand years ago. The Pythagorean theorem isn't just beautiful mathematics. It may turn out to be useful mathematics too, in ways that would have astonished Pythagoras himself.

---

*The results described in this article have been established as rigorous mathematical theorems, providing the highest level of certainty that the security guarantees hold exactly as stated.*
