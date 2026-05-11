# The Secret Code Hidden in Right Triangles

## A discovery about ancient geometry reveals a new way to think about digital security

Every schoolchild learns that a triangle with sides 3, 4, and 5 has a perfect right angle. This fact — that 3² + 4² = 5² — was known to the Babylonians four thousand years ago. But what most people don't know is that all such "Pythagorean triples" form an infinite family tree, and that this tree conceals mathematical structure so precise, so rigid, that it could reshape how we think about keeping secrets.

## An Infinite Family Tree

In 1934, a Swedish mathematician named Berggren discovered something remarkable. Starting from the triple (3, 4, 5), you can generate every possible primitive right triangle using just three simple transformations — call them A, B, and C. Apply transformation A to (3, 4, 5) and you get (5, 12, 13). Apply B and you get (21, 20, 29). Apply C and you get (15, 8, 17). Each of these can be transformed again, and again, producing an infinite ternary tree that contains every primitive Pythagorean triple exactly once.

Think of it like a genealogy: (3, 4, 5) is the ancestor, and every right triangle with whole-number sides is a descendant, reachable by following a unique path through the tree. The path is a sequence of choices — A, B, or C at each step — like a word in a three-letter alphabet. The word "ABC" leads to the triple (187, 84, 205). The word "CBA" leads to (115, 252, 277). Different words always lead to different triples.

This is mathematically beautiful, but it also suggests a tantalizing possibility: what if you could use these words as secret keys, and the triples they produce as public identifiers?

## Compressing a Triangle into a Fingerprint

Here's where the story takes an unexpected turn into the world of number theory.

Every whole number carries hidden information about which primes divide it, and how many times. The number 12, for instance, is divisible by 2 three times (12 = 2² × 3) and by 3 once. Mathematicians call this the "p-adic valuation" — it measures the depth of divisibility by each prime.

Now imagine taking a Pythagorean triple like (5, 12, 13) and recording two kinds of data about it:

**The height:** the largest coordinate (in this case, 13).

**The valuation fingerprint:** how many times each coordinate is divisible by 2 and by 3.

For (5, 12, 13), the 2-adic fingerprint is (0, 2, 0) — meaning 5 is odd, 12 is divisible by 4 (twice by 2), and 13 is odd. The 3-adic fingerprint is (0, 1, 0).

This compressed data is what mathematicians in this new research call the "tropical observable" of the triple — a term borrowed from a branch of geometry where addition becomes maximum and multiplication becomes addition. It's a kind of arithmetic photograph: not the full triple, but a highly informative shadow of it.

The fundamental question is: **Can you recover the original triple — and therefore the secret word — from this shadow alone?**

## The Rigidity Principle

The answer, proved rigorously in recent work, is a startling dichotomy.

For any given depth in the Berggren tree, every tropical observable value falls into exactly one of two categories:

1. **Rigid:** The observable came from exactly one word. The shadow uniquely identifies the triple. There is no ambiguity.

2. **Collision-bearing:** Two or more words produce the same observable. But — and this is crucial — the colliding words can be explicitly identified and packaged into a mathematical certificate of ambiguity.

There is no third possibility. Every observable is either a perfect identifier or comes with a proof that it fails to be one.

This is not a vague statistical claim. It is a theorem — a logically airtight statement with a machine-checkable proof. At each depth of the tree, you can enumerate every observable, classify it as rigid or collision-bearing, and if it collides, extract the exact pair of words responsible.

## The Power of Augmentation

But the story doesn't end with collisions. The researchers discovered that by enriching the observable with additional modular data — specifically, the remainders when the coordinates are divided by 5 and 7 — the collisions essentially vanish.

Computational experiments show this dramatically. At depth 3 in the Berggren tree, there are 40 words and one collision under the basic observable (two different words produce triples with the same height and valuation fingerprint: (187, 84, 205) from "ABC" and (133, 156, 205) from "CCB"). But when you augment the observable with mod-5 and mod-7 residues, the collision disappears. At every tested depth up to 5, the augmented observable is perfectly injective — zero collisions.

The formal theorem captures this cleanly: there exists an "exceptional set" of observable values where collisions persist, and outside this set, every augmented observable determines a unique word. The exceptional set is finite and explicitly computable at each depth. In practice, it appears to be empty.

## Why This Matters Beyond Mathematics

The structure here is precisely what cryptographers dream about.

In modern digital security, many systems depend on mathematical functions that are easy to compute in one direction but hard to reverse. You can multiply two large prime numbers instantly, but factoring the result back into primes takes astronomical effort. This asymmetry is the foundation of internet commerce, secure messaging, and digital signatures.

The Berggren tree offers something subtly different: a function where the *nature* of the difficulty is classified in advance. Rather than hoping that inversion is hard for most inputs, you can *prove* which inputs are uniquely invertible and which are ambiguous. And for the ambiguous cases, you get a certificate — a compact mathematical proof that the ambiguity exists.

This is the difference between a lock whose mechanism you trust but don't understand, and a lock that comes with a complete blueprint showing exactly where it's strong and where it could be picked.

In the language of computer science, this is "proof-carrying cryptanalysis." The system doesn't just resist attack — it certifies the precise conditions under which it could fail.

## The Tropical Connection

The name "tropical" in this context comes from a beautiful correspondence between ordinary arithmetic and a simplified version where maximum replaces addition and addition replaces multiplication. This "tropical arithmetic" is the mathematics of optimization, logistics, and network flows. It governs how fastest paths combine in networks and how costs propagate through supply chains.

The p-adic valuations that form the core of the observable are precisely the bridge: they translate multiplicative number theory (how primes divide numbers) into additive, tropical-style data (how deep the divisibility goes). This is why the observable is called "tropical" — it lives naturally in the world where maximum and addition are the fundamental operations.

The Berggren tree, seen through this tropical lens, becomes a geometric object. The set of all observable values forms a kind of discrete landscape, and the question of rigidity versus collision becomes a question about the shape of this landscape — where it has peaks (rigid points) and where it has saddles (collision points).

## A New Kind of Structure

What makes this work unusual in the history of mathematics is the combination it achieves. Number theory, geometry, algebra, and the theory of computation are typically studied in isolation. Here they merge:

- **Number theory** provides the Pythagorean triples and p-adic valuations.
- **Algebra** provides the free monoid of words and the matrix group action.
- **Tropical geometry** provides the observables and the stratification.
- **Computer science** provides the notion of decidability and certificates.

The result is neither purely theoretical nor purely computational. It is a *verified algorithm* — a procedure that not only computes the classification but also proves it correct, step by step, in a way that any skeptic can check mechanically.

## The Road Ahead

Several profound questions remain open.

First: as the depth grows, does the exceptional set — the collision-bearing observables — shrink relative to the total number of observables? Computational evidence strongly suggests yes, but a proof would establish that the Berggren tree is "generically rigid" in a precise sense.

Second: can this framework be transported to other mathematical trees? The Markoff tree, which encodes solutions to x² + y² + z² = 3xyz, has a similar structure but much deeper mysteries — including a famous unsolved conjecture about uniqueness. Tropical observables might shed new light.

Third: what is the computational cost of the certified inversion? Can it be done efficiently, or does it inherently require exponential effort? The answer would connect number theory to complexity theory in a new way.

And finally: can a working cryptographic protocol be built on this foundation? The ingredients are all present — a trapdoor function, a notion of security, and a mechanism for certified ambiguity. Whether they can be assembled into a practical system is the engineering challenge that beckons.

## The Oldest Problem, the Newest Tool

It is a remarkable fact that Pythagorean triples — among the oldest objects in all of mathematics — continue to reveal new structure when examined with modern tools. Four thousand years after Babylonian scribes cataloged right triangles on clay tablets, the arithmetic of x² + y² = z² is still yielding surprises.

The Berggren tree turns these ancient objects into a dynamical system. Tropical observables compress that system into decidable shadows. And the rigidity theorem transforms vague intuitions about uniqueness into precise, verified, actionable mathematics.

In a world increasingly dependent on mathematical guarantees for security and trust, this kind of rigorous classification — where ambiguity is not hidden but certified — may be exactly what we need.
