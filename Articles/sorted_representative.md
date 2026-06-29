# The Hidden Mathematics of Musical Motion

## How a Simple Sorting Trick Solves an Impossible Problem in Music Theory

When a pianist plays a C major chord and then moves to F major, something subtle happens. Each finger—each voice—must travel from one note to another. The first finger might slide up five semitones. The second, also five. The third, five again. The total "work" the hand does is fifteen semitones of motion.

But what if the pianist could reassign the voices? What if the bottom voice leapt to the top note, while the top voice dropped to the bottom? Would that cost less total motion, or more?

This question—**what is the minimum total motion to get from one chord to another?**—sits at the heart of a discipline that composers have studied for centuries: *voice leading*. And the mathematical answer, it turns out, connects music theory to shipping logistics, probability theory, and the deep geometry of symmetry.

---

## The Explosion Problem

Here's the difficulty. For a three-note chord, there are 6 possible ways to assign voices. For four notes, there are 24. For ten notes, there are 3,628,800. For a full orchestra of 40 independent parts, the number of possible assignments exceeds the number of atoms in the observable universe.

To find the *minimum* cost voice leading, you'd naively need to check every single one of these assignments. Each one requires adding up all the individual voice displacements. For a modest ensemble, this is computationally hopeless.

Music theorists and composers, of course, have always had intuitions about this. A good voice leading "avoids large leaps" and "moves by contrary or oblique motion." But turning intuition into a precise, efficient algorithm seemed to require wrestling with the combinatorial explosion head-on.

Until someone noticed something that should have been obvious all along.

---

## The Uncrossing Principle

Imagine two voices, one singing a low note and one singing a high note, needing to reach two target pitches. If the low voice is assigned to the *high* target and the high voice to the *low* target, the voice paths cross—like two people trying to swap seats by climbing over each other.

The mathematical fact is stark: **crossed voice paths never help**. If you uncross them—assign the low voice to the low target and the high voice to the high target—the total displacement is always less than or equal to the crossed assignment.

This is not just a musical observation. It is a theorem about absolute value on the number line, sometimes called the *Monge inequality* after the 18th-century French mathematician Gaspard Monge, who studied it in the context of moving piles of earth. For any four numbers where *a ≤ b* and *c ≤ d*:

> |a − c| + |b − d| ≤ |a − d| + |b − c|

The "direct" pairing always beats the "crossed" pairing. Always. No exceptions.

---

## From Two Voices to a Thousand

The genius of the uncrossing principle is that it scales. If you have any voice assignment with *any* crossing—any pair of voices where the lower source is assigned to a higher target than the higher source—you can uncross that pair without increasing the total cost. And the new assignment has strictly fewer crossings.

Keep uncrossing. Every crossing you remove reduces the total number of crossings (which started finite). Eventually, you run out of crossings. What you're left with is the completely uncrossed assignment: the one where you simply **sort both chords from lowest to highest and match them position by position**.

This is the theorem:

> **The optimal voice-leading assignment between any two chords is achieved by sorting both chords and matching sorted positions.**

No search over permutations. No combinatorial explosion. Just sort and compare. An *O(n log n)* algorithm replaces an *O(n!)* search—and it gives the provably optimal answer.

---

## What This Really Means

At first glance, this might seem like a nice algorithmic trick. But its significance runs much deeper.

**It gives chord space a computable geometry.** In the abstract, the space of chords—where two chords are "the same" if one is a rearrangement of the other—is a *quotient space*. Distances in quotient spaces are defined by minimizing over all representatives, which is usually intractable. The sorting theorem says this particular quotient has a *canonical chart*: the Weyl chamber of sorted tuples. And in this chart, the distance is just the ordinary L¹ (city-block) distance.

**It connects music to optimal transport.** The voice-leading cost between two n-note chords is precisely the *Wasserstein-1 distance* (also called the earth mover's distance) between two discrete probability distributions on the pitch line. The sorted matching is the *monotone coupling*—the same construction that appears in everything from image comparison to machine learning to economics. Voice leading, it turns out, is the same mathematical problem as efficiently moving piles of sand.

**It makes the abstract concrete.** Theorists like Dmitri Tymoczko have long argued that the space of chords modulo voice permutation has a rich geometric structure—something like an orbifold, with singular points where notes coincide. The sorting theorem provides the first step in making this geometry computationally explicit: it gives an exact formula for distances, not just an existence proof.

---

## The Deep Structure: Reflections and Chambers

Why does sorting work? There is a beautiful geometric reason.

The symmetric group—the set of all permutations of n objects—acts on the space of n-tuples by rearranging coordinates. The set of sorted (weakly increasing) tuples forms a *fundamental domain* for this action: a wedge-shaped region called a *Weyl chamber* that tiles the full space when you apply all possible permutations.

Each chord lives in exactly one permuted copy of this chamber. The sorted representative is the one that lives in the "standard" chamber. And the theorem says that the distance between two orbits equals the distance between their standard-chamber representatives—measured in the simple L¹ metric.

This is not just about music. The same structure appears whenever a finite group acts on a metric space:

- In crystallography, where the symmetry group of a crystal lattice creates a fundamental domain.
- In the study of eigenvalues, where the Weyl group permutes the eigenvalues of a symmetric matrix.
- In optimization, where symmetry reduction replaces a large search space with a smaller fundamental domain.

The sorting theorem is the simplest instance of a much broader principle: **quotient metrics can sometimes be computed on a canonical slice**.

---

## A Certified Algorithm

What makes this result especially satisfying is that it has been *machine-verified*. Using modern mathematical proof technology, the theorem has been formalized and checked by a computer, line by line. Every step—the Monge inequality, the uncrossing argument, the equivalence between sorting and optimization—has been verified to be logically airtight.

This matters because the theorem is the foundation for computational tools. Any music analysis software, any algorithmic composition system, any chord recommendation engine that uses voice-leading distance can now rely on the sorting algorithm with mathematical certainty. The algorithm is not just fast; it is *certifiably correct*.

The certification also opens the door to building more complex verified tools on top of it. Voice-leading distance can be composed (it satisfies the triangle inequality, also verified) to find shortest paths through chord space, to cluster chords by similarity, or to analyze the smoothness of harmonic progressions.

---

## The Bigger Picture

This work sits at the intersection of several mathematical worlds:

- **Combinatorics**: the rearrangement inequality, which dates back to Hardy, Littlewood, and Pólya in the 1930s.
- **Optimal transport**: the Monge-Kantorovich theory, which has undergone a renaissance in the 21st century thanks to its applications in machine learning and data science.
- **Geometric group theory**: the Coxeter group structure of the symmetric group and its action on Euclidean space.
- **Music theory**: the geometric approach to voice leading pioneered by Tymoczko and others.

The surprise is not that these connections exist—mathematicians have long suspected them—but that they can be made completely rigorous and computationally explicit in a single theorem.

And the theorem itself is just the beginning. The sorted chamber gives us a concrete chart for chord space. The next challenge is to understand geodesics (shortest paths), curvature (how the space bends), and the singular structure at points where notes coincide. The broader vision is to build a complete geometry of musical motion—one where the deep theorems of mathematics illuminate the intuitions that composers have carried for centuries.

Sometimes the deepest mathematics hides in the simplest observation: **if you want to move efficiently, don't cross the streams**.
