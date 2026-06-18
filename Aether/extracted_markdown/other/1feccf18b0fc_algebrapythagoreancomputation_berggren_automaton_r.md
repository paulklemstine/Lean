# When Ancient Triangles Meet Modern Machines

## The Hidden Computers Inside Pythagorean Triples

Four thousand years ago, a Babylonian scribe pressed a stylus into wet clay and recorded a table of numbers. Among them were pairs like 119 and 169, 3367 and 4825—numbers that, when squared and added, produced perfect squares. These were Pythagorean triples, solutions to the equation a² + b² = c², and they have captivated mathematicians ever since.

What the Babylonians could not have known is that every one of these triples is a node in an infinite tree—a branching structure where each triple gives birth to exactly three children, which in turn spawn three more, spiraling outward forever through the integers. This tree, discovered by the mathematician Barning in 1963 and popularized by Berggren in 1934, generates every primitive Pythagorean triple exactly once.

Now a new mathematical result reveals something astonishing about this tree: it is not merely a catalog of triangles. It is a computing machine. And the theory that proves this creates an unexpected bridge between one of the oldest objects in mathematics and one of the newest—the theory of finite-state automata.

## Three Magic Matrices

The Berggren tree works through a beautifully simple mechanism. Start with the smallest Pythagorean triple: (3, 4, 5). Now apply one of three transformations—call them A, B, and C. Each is a specific rule for combining the three numbers to produce a new triple:

- **Branch A** turns (3, 4, 5) into (5, 12, 13)
- **Branch B** turns (3, 4, 5) into (21, 20, 29)  
- **Branch C** turns (3, 4, 5) into (15, 8, 17)

Check them yourself: 5² + 12² = 169 = 13². The magic is that these three operations, applied repeatedly in any order, generate every primitive Pythagorean triple without repetition. The triple (3, 4, 5) is the root; (5, 12, 13) is its first child; (7, 24, 25) is its grandchild via the path AA.

Every triple has an address—a word like "ABCA" or "BCCAB"—describing the sequence of branches you follow from the root. This addressing system turns the infinite world of Pythagorean triples into something that looks remarkably like a language, where the "alphabet" consists of three letters and every "word" names a right triangle.

## The Residual Trick

Imagine you're standing at some node in this infinite tree, looking at the subtree below you. The view you see—the pattern of values spreading out beneath your feet—depends on where you're standing. If you step to a different node, the view changes.

Mathematicians call each of these downward views a "residual." The residual at a node captures everything the tree looks like from that point onward. Here's the crucial question: **how many genuinely different views are there?**

For some properties of the tree, the answer is surprisingly small. Consider the simplest possible measurement: is the depth of a node even or odd? From an even-depth node, the view is "even, odd, even, odd..." going down. From an odd-depth node, it's "odd, even, odd, even..." There are exactly two different views—two residuals. No matter how far you travel through the tree, you'll only ever see one of these two patterns below you.

For other properties, the number of views is infinite. The hypotenuse of the triple at each node, for instance, grows without bound, and every node gives a genuinely different downward view. No finite collection of templates can capture all the views.

This distinction—finite versus infinite number of residuals—turns out to be the key that unlocks a profound connection.

## The Machine Inside the Math

In the 1950s and 1960s, computer scientists developed a beautiful theory of finite-state machines—automata that read input symbols one at a time, switching between a fixed set of internal states. These machines are everywhere: they control traffic lights, parse programming languages, search text for patterns. Their power is precisely characterized by a theorem due to Myhill and Nerode: a pattern can be recognized by a finite machine if and only if it generates finitely many residuals.

The new result—the **Berggren Realization Theorem**—proves that this same characterization holds when the input alphabet is the Berggren generators and the "patterns" are arithmetic properties of Pythagorean triples.

Concretely: take any function that assigns a value to each Pythagorean triple (its hypotenuse modulo 7, say, or whether its shortest side is divisible by 3). This function defines a "stream"—a value for every word in the Berggren alphabet. The theorem says:

> **A Berggren stream can be computed by a finite-state machine if and only if it has finitely many distinct residuals.**

Moreover, there is a unique smallest such machine—the *canonical residual automaton*—whose states are exactly the distinct residuals. Any other machine computing the same stream must have at least as many states.

## Why This Matters

This theorem is more than a technical curiosity. It establishes that the Berggren tree—an object from number theory—obeys the same computational laws as formal languages in computer science. The bridge runs in both directions.

**From number theory to computation:** Given an arithmetic property of Pythagorean triples, we can now ask a precise question—does it have finite residual rank? If yes, we can build the smallest possible machine to compute it. If no, we know that no finite machine suffices, no matter how clever its design.

**From computation to number theory:** The finite-state machines we build encode deep structural information about how arithmetic properties propagate through the Berggren tree. The number of states in the minimal machine is an invariant—a kind of "complexity measure" for arithmetic properties of Pythagorean triples.

Consider what this means in practice. The hypotenuse of a Pythagorean triple modulo any fixed number is a finite-rank stream: it can be tracked by a finite machine reading Berggren letters. This machine needs only a handful of states to predict the remainder class of a hypotenuse buried deep in the tree, without ever computing the actual (enormous) numbers involved.

But the raw hypotenuse itself has infinite rank—no finite machine can compute it. This is not surprising (the numbers grow exponentially), but now we have a *proof* that compression to a finite machine is impossible, not merely a practical limitation.

## The Hankel Connection

There is a second, equivalent way to see the theorem, and it connects to a rich tradition in mathematics called the theory of Hankel matrices.

Arrange all Berggren words along both axes of an infinite table, and fill in entry (u, v) with the value of the stream at the concatenated word u·v. This produces the Berggren-Hankel matrix. The theorem shows that the stream is finitely computable if and only if this matrix has "finite rank"—meaning its rows span a finite-dimensional space.

Hankel matrices appear throughout mathematics, from moment problems in probability to Padé approximation in numerical analysis to the realization theory of linear dynamical systems. The Berggren-Hankel matrix is the first Hankel object whose rows and columns are indexed by *arithmetic addresses of Pythagorean triples*. It opens a door between classical linear algebra and Diophantine geometry.

## Building the Machine

The theorem is not merely existential—it is constructive. Given a finite-rank stream, the proof builds the minimal machine explicitly:

1. **Discover residuals:** Explore the tree to find all distinct downward views.
2. **Build states:** Each distinct view becomes a state of the machine.
3. **Wire transitions:** When the machine reads letter A, B, or C, it moves to the state corresponding to the new downward view.
4. **Set outputs:** Each state outputs the stream value at its representative node.

The resulting machine is provably minimal: no other machine computing the same stream can have fewer states. This is not an optimization claim—it is a mathematical theorem with an exact proof.

## A New Field Emerging

What makes this result exciting is not just what it proves, but what it opens. The Berggren tree is just one example of an arithmetically generated tree. Similar structures appear throughout number theory: continued fraction expansions, Stern-Brocot trees, Farey sequences, quadratic form reduction chains. Each generates an infinite tree through finitely many arithmetic operations.

The Berggren Realization Theorem suggests that *all* such trees might admit a finite-state realization theory. If so, we would have a systematic way to determine which arithmetic properties of number-theoretic objects can be tracked by finite machines, and which require inherently infinite computation.

This vision—**Diophantine automata theory**—would unify ideas from number theory, automata theory, symbolic dynamics, and linear systems theory. It would provide tools for:

- **Compressed computation:** Computing properties of enormous integers through small machines instead of explicit arithmetic.
- **Decidability questions:** Determining algorithmically whether a given arithmetic property is finitely trackable.
- **Complexity classification:** Measuring the "automaton complexity" of number-theoretic functions.
- **Certified algorithms:** Building provably correct computational pipelines for arithmetic data.

## The Surprise at the Heart

Perhaps the deepest surprise is philosophical. Pythagorean triples are among the most concrete objects in all of mathematics—they are just triples of whole numbers satisfying an equation. Yet hiding inside their tree structure is a perfect copy of abstract computation theory. The Berggren generators are not just rules for making triangles; they are an input alphabet for a computational machine. The tree is not just a catalog; it is a program.

For four millennia, we have studied Pythagorean triples as objects. This theorem reveals them as processes—as the outputs of finite-state machines reading words in an arithmetic language. The ancient triangles were computing all along. We just needed the right framework to see it.

And now that we can see it, a vast landscape of questions opens before us. Which arithmetic trees admit finite machines? What is the smallest machine for a given number-theoretic property? Can we classify all Diophantine generation mechanisms by their computational rank?

The Babylonian scribe, pressing numbers into clay, was doing something more profound than recording triangles. They were, without knowing it, writing down the output tape of a very old, very beautiful, and very small computing machine.
