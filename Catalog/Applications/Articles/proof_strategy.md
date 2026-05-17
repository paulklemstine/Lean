# The Ancient Triangle Machine That Builds Its Own Random Numbers

## A 2,500-year-old pattern in right triangles may hold the key to a new kind of mathematical randomness

---

Three. Four. Five. Those three numbers form the most famous right triangle in history — the one every carpenter checks with a tape measure, the one every student meets in geometry class. But buried inside that simple triple is a machine. A machine that, when you turn its crank, produces every right triangle with whole-number sides that has ever existed or ever will.

The machine was discovered in 1934 by a Swedish mathematician named Berggren. It works like a family tree: starting from (3, 4, 5), you apply three simple recipes — think of them as "have child A," "have child B," and "have child C" — and you get three new right triangles. Apply the recipes to each of those, and you get nine more. Keep going, and you generate every primitive Pythagorean triple, without repetition, without missing any.

For decades, this was a beautiful curiosity — an elegant proof that Pythagorean triples form an infinite ternary tree. But recently, mathematicians have discovered something far stranger. When you take Berggren's machine and run it on a clock — modular arithmetic, where numbers wrap around after reaching some prime p — the infinite tree collapses into a finite loop. And the shape of that loop turns out to encode deep secrets about randomness itself.

---

## When Infinity Meets the Clock

Imagine a clock with p hours instead of 12. On such a clock, 14 o'clock is the same as 2 o'clock (if p = 12). Now run Berggren's machine on this clock. The triple (3, 4, 5) still satisfies 3² + 4² = 5² on any clock, because 9 + 16 = 25 regardless of how you wrap around. And Berggren's three recipes still produce valid triples on the clock, because they're just multiplication and addition.

But something miraculous happens: since there are only finitely many positions on the clock, the machine must eventually revisit a state it's seen before. The infinite tree becomes a finite graph — a network of points connected by arrows.

The natural question: what does this network look like? Is it a tangled mess, or does it have hidden structure?

The answer is stunning. For every odd prime p, the network has exactly p + 1 vertices — the same number regardless of how tangled the connections might be. These vertices are the "projective isotropic points" of a certain quadratic equation, and they've been studied since the 19th century in the theory of conics over finite fields. But nobody had noticed that Berggren's machine provides a natural way to walk around on them.

---

## The Spectrum of a Network

To understand a network's deep structure, mathematicians look at its *spectrum* — a set of numbers that capture the network's connectivity, much the way musical notes capture the vibrations of a string.

Every network has a largest spectral value (the "fundamental frequency"), which is always predictable from the degree structure. The interesting question is: what's the *second largest* value? This is called the spectral gap, and it controls almost everything important about the network:

- **How fast does mixing happen?** If you start a random walk on the network — hopping from vertex to vertex by following random arrows — the spectral gap tells you how quickly your walk "forgets" where it started. A large gap means fast mixing: after just a few steps, you're essentially at a random vertex.

- **How uniform are neighborhoods?** The spectral gap controls whether different parts of the network look roughly the same or have wild imbalances.

- **How good an expander is it?** Expander graphs — networks where every subset of vertices has many connections to the outside — are the backbone of modern computer science, from error-correcting codes to cryptography. The spectral gap is the gold standard for measuring expansion.

---

## The Mystery Number

Here's where the story takes an unexpected turn. When researchers computed the spectrum of the Berggren network for dozens of primes, a particular number kept appearing as an apparent upper bound: 1/√3, approximately 0.5774.

This number is tantalizing. It's not just any bound — it's the *exact* threshold that would make the Berggren network into what's called a "Ramanujan graph," named after the legendary Indian mathematician Srinivasa Ramanujan. Ramanujan graphs are the best possible expanders: their spectral gap is as large as the laws of mathematics allow.

The first explicit constructions of Ramanujan graphs, by Lubotzky, Phillips, and Sarnak in 1988, were hailed as a breakthrough at the intersection of number theory, group theory, and computer science. Those graphs came from the arithmetic of quaternion algebras — exotic algebraic structures with deep connections to the theory of modular forms.

Could Berggren's machine — born from the humble Pythagorean theorem — be producing Ramanujan graphs too? And if so, through what mechanism?

---

## Inside the Lorentz Group

The key insight comes from physics, of all places. The three Berggren matrices — the recipes that transform one triple into another — turn out to preserve a quantity that physicists call a *Lorentz form*: the expression a² + b² − c².

If you've heard of Einstein's special relativity, you've met this form in disguise. The Lorentz form is the mathematical signature of spacetime geometry, where space and time combine in a way that preserves the "interval" x² + y² − t² (in units where light speed is 1). Berggren's matrices are members of the *Lorentz group* O(2,1) — the same group that governs the symmetries of two-dimensional hyperbolic space.

This connection is not a coincidence. It's the reason Berggren's machine works at all. Pythagorean triples satisfy a² + b² = c², which is the same as saying a² + b² − c² = 0. The Berggren matrices preserve this equation, so they map triples to triples. Over the integers, this gives the infinite tree. Over a finite field, the Lorentz group becomes a finite group, and its action on the "light cone" (the set where a² + b² − c² = 0) creates the orbit graph.

This places the Berggren network squarely in the world of *arithmetic groups acting on algebraic varieties* — the same world that produced the Lubotzky-Phillips-Sarnak Ramanujan graphs. The spectral properties of the network should be controlled by the representation theory of the finite orthogonal group O(2,1; 𝔽_p).

---

## What the Computer Reveals

Rigorous computation for all primes up to 73 reveals a nuanced picture:

1. **The graph always has p + 1 vertices and is always connected.** This is a theorem from algebraic geometry: a non-degenerate conic in projective space over 𝔽_p always has p + 1 rational points.

2. **Most vertices have out-degree 3** (three Berggren children), **but some have out-degree 2** (where two generators collide). This means the graph is *not* exactly (3,2)-biregular as initially conjectured.

3. **The second eigenvalue is consistently below 1/√3**, approaching it more closely for larger primes. For p = 47, the ratio λ₂/(1/√3) reaches 0.982 — tantalizingly close.

4. **The eigenvalue 1/3 appears universally**, arising from the trace of the generators divided by 3. This suggests a deep algebraic origin in the character theory of the orthogonal group.

5. **The dependence on p mod 8** is real but subtle. Different congruence classes show different spectral patterns, consistent with the fact that the quadratic residue structure of 𝔽_p changes with p mod 8.

---

## A Bridge Between Worlds

What makes this discovery exciting is not any single theorem but the *bridge* it builds between domains that rarely talk to each other:

**Number theory** gives us the Pythagorean triples and the Berggren tree — the raw material.

**Algebra** gives us the Lorentz group and its finite-field reductions — the structural explanation for why the machine works.

**Spectral graph theory** gives us the language of eigenvalues and expansion — the tools for measuring how "random" the machine's output is.

**Physics** gives us the geometric intuition of hyperbolic space and Lorentz symmetry — the conceptual framework that ties everything together.

This kind of multi-domain bridge is the hallmark of deep mathematics. The greatest theorems of the 20th century — the proof of Fermat's Last Theorem, the Langlands program, the classification of finite simple groups — all worked by revealing unexpected connections between seemingly unrelated fields.

---

## The Road Ahead

Several profound questions remain open:

**Is the spectral bound exactly 1/√3?** The computational evidence is suggestive but not conclusive. Proving this would require a full decomposition of the permutation representation of O(2,1; 𝔽_p) on isotropic points, identifying exactly which irreducible representations appear and computing the eigenvalue of the Berggren correspondence on each.

**Why does p mod 8 matter?** The answer likely involves the behavior of −1 and 2 as quadratic residues modulo p, which changes at exactly the mod-8 boundaries. When p ≡ 1 (mod 8), both −1 and 2 are squares, giving the orthogonal group extra structure (it splits as a product of simpler groups). This should affect which representations appear in the decomposition.

**Can we build better expanders?** If the Berggren graph really is Ramanujan (or close to it), it provides a new family of efficient expander graphs with only 3 edges per vertex. This is extremely sparse — most known Ramanujan constructions require higher degree — making it potentially useful for applications in networking, coding theory, and cryptography.

**What about other Diophantine equations?** The Berggren construction generalizes: any integer matrix group that preserves a quadratic form can be reduced modulo primes to produce orbit graphs. The spectral theory of these graphs would constitute a "finite arithmetic Langlands program" — a systematic way to extract spectral information from Diophantine geometry.

---

## The Carpenter's Secret

Return for a moment to the carpenter with the tape measure. The triple (3, 4, 5) is the simplest tool for checking right angles — hold three lengths in those proportions, and they *must* form a 90-degree corner. It's a fact as old as the pyramids.

But hidden in that simple fact is a machine that generates all right triangles, a machine that connects to the symmetries of spacetime, and a machine that — when compressed into the finite world of modular arithmetic — appears to produce mathematical randomness of the highest quality. The spectrum of its orbit graph may encode secrets about prime numbers that we're only beginning to understand.

Twenty-five hundred years after Pythagoras, his simplest theorem still has surprises in store.
