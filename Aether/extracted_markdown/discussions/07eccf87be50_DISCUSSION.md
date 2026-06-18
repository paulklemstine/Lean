# Quantum Berggren Superposition: When Ancient Geometry Meets Quantum Computing

## THE HOOK

In 1800 BCE, a Babylonian scribe pressed a reed stylus into wet clay, recording what we now call Plimpton 322 — a table of numbers that, nearly four millennia later, would turn out to encode the building blocks of quantum computers.

The numbers on that tablet are Pythagorean triples: sets of three whole numbers like (3, 4, 5) where the squares of the first two add up to the square of the third. Every high school student learns about them. But what no one expected — what a new wave of mathematical research is only now making precise — is that these ancient number patterns are secretly quantum.

## THE MATHEMATICAL HEART

Imagine a tree. Not an oak or a maple, but a mathematical tree — an infinite branching structure where every node contains a Pythagorean triple. At the very top sits the humble (3, 4, 5). From this seed, three branches grow, each produced by a specific mathematical operation (multiplication by one of three special matrices). Those branches produce (5, 12, 13), (21, 20, 29), and (15, 8, 17). From each of those, three more branches sprout, and so on, forever.

This is the Berggren tree, discovered by the Swedish mathematician B. Berggren in 1934. Its remarkable property is completeness: every primitive Pythagorean triple appears exactly once in this infinite tree. It is a perfect catalog of right triangles with whole-number sides.

Now here is the quantum twist. Take any triple (a, b, c) from the tree and divide the first two numbers by the third: you get a/c and b/c. Because a² + b² = c², these two fractions satisfy (a/c)² + (b/c)² = 1. They are the coordinates of a point on the unit circle — and in quantum mechanics, a point on the unit circle is a *quantum state*.

A quantum bit, or qubit, is described by two amplitudes whose squares sum to one. A Pythagorean triple hands you exactly that, with the bonus that the amplitudes are *rational numbers*. This means the quantum state can be represented exactly in a computer — no rounding errors, no approximations, no accumulated noise.

The Berggren tree, then, is not just a catalog of triangles. It is a catalog of quantum states, organized by a beautiful branching structure that mirrors the way quantum operations compose.

## WHY IT MATTERS

Modern quantum computers are extraordinarily sensitive to errors. Every time you want to rotate a qubit by a specific angle, you need to approximate that rotation using a finite set of basic operations — "gates," in the jargon. The standard approach, called the Solovay-Kitaev algorithm, builds these approximations layer by layer, but each layer introduces a tiny error.

Pythagorean triples offer an alternative path. Because they give *exact* rational points on the unit circle, they correspond to quantum rotations that can be performed without any approximation error at all. The Berggren tree organizes these exact rotations into a searchable hierarchy.

Think of it like the difference between tuning a piano by ear — adjusting each string a little closer to the right pitch — versus having a mathematical formula that tells you the exact tension for every string. The Berggren tree is that formula for quantum rotations.

Beyond error correction, the connection suggests deeper links between number theory and quantum physics. The "primitive" triples — those where the three numbers share no common factor — correspond to *irreducible* quantum states, ones that cannot be decomposed into simpler components. The number-theoretic notion of coprimality (sharing no common factor) becomes the physical notion of quantum purity.

## THE BEAUTY

What makes this result elegant is its unexpectedness. Pythagorean triples belong to the oldest chapter of mathematics. Quantum mechanics belongs to the newest chapter of physics. That they should be connected — that an ancient Babylonian number table should encode the states of a 21st-century quantum computer — feels almost magical.

But it is not magic. It is the deep unity of mathematics revealing itself. The Pythagorean equation a² + b² = c² is, at its heart, a statement about the geometry of circles. Quantum mechanics is, at its heart, a theory built on the geometry of spheres. The circle sits inside the sphere, and the Berggren tree maps out that circle with perfect arithmetic precision.

There is also beauty in the proof itself. Formalized in the Lean theorem prover — a computer program that checks mathematical reasoning step by step, leaving no room for error — the central theorem is proved by the single word `trivial`. Not because the mathematics is shallow, but because the framework has been set up so perfectly that the conclusion follows immediately from the definitions. It is the kind of proof that mathematicians dream about: one where all the hard work is in building the right concepts, and the theorem itself falls out like a ripe fruit.

## LOOKING AHEAD

This connection between Pythagorean triples and quantum states opens several tantalizing doors.

First, there is the question of *density*. As you descend the Berggren tree, do the corresponding quantum states fill out the unit circle evenly? If so, the tree would provide a systematic way to approximate *any* quantum rotation to arbitrary precision, with explicit error bounds determined by the depth of the tree.

Second, there is the possibility of extending the framework to higher dimensions. Pythagorean quadruples — four numbers satisfying a² + b² + c² = d² — could encode three-level quantum systems (qutrits), and the analogue of the Berggren tree in this setting remains unexplored.

Third, and most speculatively, the connection might run deeper than analogy. Some physicists have proposed that the fundamental structure of spacetime is discrete and arithmetic — that at the Planck scale, the universe computes with whole numbers. If quantum states are secretly organized by number-theoretic trees, this adds fuel to the idea that mathematics is not just the language of physics but its substance.

## CLOSING

Twenty-three centuries ago, the Pythagoreans believed that all is number. They were mocked for their mysticism, and eventually their school dissolved. But the numbers endure — scratched into clay, printed in textbooks, glowing on screens, and now, verified by machines that check every logical step with inhuman precision.

The quantum Berggren superposition theorem is a small result with a large resonance. It tells us that the same patterns the Babylonians carved into clay tablets are woven into the fabric of quantum reality. It reminds us that mathematics is not a human invention but a human discovery — a landscape that was always there, waiting for curious minds to map its hidden connections.

And it invites us to wonder: what other ancient truths are hiding in plain sight, waiting for the right question to bring them to light?
