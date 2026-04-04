# The Secret Geometry of Prime Numbers

## How Ancient Number Theory Meets Modern Cryptography in Three Dimensions

*By the Quadruple Lattice Research Group*

---

Every time you buy something online, send an encrypted message, or log into your bank account, your security depends on a simple mathematical fact: multiplying two large prime numbers together is easy, but figuring out which two primes were multiplied is extraordinarily hard. This asymmetry is the foundation of RSA encryption, which protects trillions of dollars in transactions every year.

For decades, mathematicians and computer scientists have searched for faster ways to factor large numbers — to split a number like 91 back into its prime components 7 × 13. The fastest known methods work in "sub-exponential" time, meaning they're much better than brute force but still take impractically long for large enough numbers. A truly fast factoring algorithm would upend internet security overnight.

Now, a line of research connecting ancient Greek mathematics to modern lattice theory is exploring whether three-dimensional geometry might offer a shortcut.

### Pythagorean Triples and Trees

You probably remember the Pythagorean theorem from school: a² + b² = c². The most famous example is 3² + 4² = 5², or 9 + 16 = 25. Numbers that satisfy this equation — like (3, 4, 5) — are called *Pythagorean triples*, and they've been studied since at least 1800 BCE, when Babylonian scribes carved them into clay tablets.

What's less well known is that all Pythagorean triples can be organized into a beautiful tree structure, discovered by the Swedish mathematician B. Berggren in 1934. Starting from the "root" triple (3, 4, 5), three simple matrix operations generate every other primitive triple. It's like a family tree where every Pythagorean triple has exactly one parent and three children.

Here's the remarkable connection to factoring: climbing *up* this tree — from child to parent — turns out to be mathematically identical to a classical algorithm from lattice theory called *Gauss reduction*. This is the **Lattice-Tree Correspondence Theorem**, and it tells us something profound: the Pythagorean tree "knows" about factoring.

### From Flat Triangles to 3D Space

But the Pythagorean tree lives in flatland — two dimensions. What happens when we add a third dimension?

A *Pythagorean quadruple* is a set of four numbers satisfying a² + b² + c² = d². For example, 1² + 2² + 2² = 3², or 1 + 4 + 4 = 9. These are the three-dimensional cousins of Pythagorean triples, and they have a fundamentally richer structure.

While triples form a single tree, quadruples cannot be organized into any finite tree at all. Their solution space is two-dimensional rather than one-dimensional, which means they form an infinite forest — infinitely many independent families that no finite set of operations can connect. In the language of physics, triples live on a circle, but quadruples live on a sphere.

### The Quadruple Lattice

This richer structure suggests an intriguing possibility. If factoring in the "flat" world of triples is equivalent to 2D lattice reduction (which gives √N-speed factoring), could the "spatial" world of quadruples enable 3D lattice reduction that's faster?

Here's the construction: given a number N that we want to factor, we build a three-dimensional lattice — a regular grid of points in 3D space — with a special property. Every point (x, y, z) in the lattice satisfies x² + y² + z² ≡ 0 (mod N). If we can find a very short vector in this lattice, its squared length will be a small multiple of N, and the greatest common divisor of that multiplier with N might reveal a factor.

The lattice has volume N², which means Minkowski's theorem (a fundamental result from the geometry of numbers) guarantees the existence of a short vector with length roughly N^{2/3}. Is that short enough to factor N?

### The Honest Answer

Unfortunately, the generic answer is no. The N^{2/3} bound from Minkowski's theorem is actually *worse* than the √N bound that simple trial division achieves. If we're looking for x² + y² + z² = kN with small k, we need the vector length to be about √N, not N^{2/3}.

But here's where it gets interesting. Minkowski's theorem gives a *worst-case* bound for *any* lattice with that volume. Real lattices, especially those with arithmetic structure, can have much shorter vectors than the bound predicts.

Think of it this way: Minkowski tells you that a box of a certain volume must contain a lattice point, but a box with a regular pattern inside it — like one filled with atoms in a crystal — will have points much closer together than a box filled with randomly placed grains of sand.

The lattices we construct from factoring problems have deep arithmetic structure inherited from quadratic residues and sum-of-squares representations. Whether this structure yields shorter-than-expected vectors is an empirical question that can be tested computationally.

### Machine-Checked Mathematics

What sets this research apart is that every mathematical claim has been formally verified using Lean 4, a computer proof assistant. This means a computer has checked every logical step, from the basic definitions to the theorem that our construction really is a lattice and really does satisfy the divisibility property.

Formal verification is like having a tireless, perfectly rigorous referee. It caught, for instance, that the originally proposed set L₄(N) = {(x,y,z) : N² | (x²+y²+z²)} is not actually a lattice at all — it's not closed under addition! The formal proof explicitly constructs a counterexample: in L₄(3), both (2,1,2) and (1,2,2) are members (since 4+1+4 = 9), but their sum (3,3,4) is not (since 9+9+16 = 34, which isn't divisible by 9).

This kind of error — mistaking a quadratic condition for a linear one — is exactly the type of subtle mistake that formal verification excels at catching.

### What Comes Next

The honest bottom line: we don't have a sub-√N factoring algorithm. What we have is:

1. A **correctly constructed** lattice with verified mathematical properties.
2. A **clear theoretical framework** connecting Pythagorean quadruples to factoring.
3. A **concrete experimental program** — build the lattices, reduce them, measure the vectors.

The experiments can be run right now, for any semiprime you choose. The Python code is available, the lattice construction is straightforward, and LLL/BKZ implementations are freely available. If structured lattices have shorter vectors than Minkowski predicts, the data will show it.

Mathematics has a long history of surprises emerging from the intersection of ancient problems and modern tools. The Pythagorean theorem is 4,000 years old. Lattice reduction is 40 years old. Formal verification is perhaps 20 years mature. Whether their intersection yields a new approach to factoring remains to be seen — but the question is precise, testable, and grounded in real mathematics.

And in science, a well-posed question is worth more than a premature answer.

---

*The formal proofs and computational tools described in this article are available as open-source Lean 4 and Python code.*
