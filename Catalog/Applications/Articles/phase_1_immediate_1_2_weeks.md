# The Hidden Geometry of Harmony

## How mathematicians proved that music obeys the same laws as shipping routes and city planning

---

When a choir moves from one chord to the next, something remarkable happens—something that composers have intuited for centuries but never quite pinned down. Each voice slides up or down by some number of steps, and the total "effort" of that motion has a precise mathematical structure. It turns out that this structure is identical to the geometry that governs optimal shipping routes, warehouse logistics, and even the way sand piles redistribute themselves. The connection is not a metaphor. It is a theorem.

### The Shortest Path Between Two Harmonies

Imagine you are arranging a piece for four singers—soprano, alto, tenor, and bass. You have written a C major chord, and you need to move to an F major chord. The question every composition student learns to ask is: *How do I move the voices as little as possible?*

But there is a subtlety. You don't actually care which singer lands on which note—you just want *some* assignment of the four new notes to the four voices that minimizes total motion. If the soprano was on middle C and needs to reach the F above, that's a jump of five semitones. But maybe a different voice should take that F instead. The optimal solution requires checking every possible assignment of notes to voices and picking the cheapest one.

For four voices, there are 24 possible assignments—the 24 permutations of four objects. For five voices, 120. For a full orchestra section, the number explodes into the millions. Yet the mathematical structure of this problem is beautiful, because it turns out that the cheapest assignment always has a canonical form: **sort the voices and match them in order**.

This is not obvious. Consider a chord where the voices are scrambled—the soprano is playing a low note and the bass is singing high. Intuitively, you might think some clever crossing of voices could save effort. The theorem says no. Sort both chords from lowest to highest, match first to first, second to second, and so on. That is always optimal. Always.

### A Map of Musical Space

This result has a profound consequence. It means that the cost of moving between any two chords defines a *distance*—in the precise mathematical sense. Distances have rules. The most fundamental is the **triangle inequality**: the direct distance from A to C is never longer than going from A to B and then from B to C.

In musical terms: if you know the effort of moving from a C major chord to an F major chord, and the effort of moving from F major to G dominant seventh, then the effort of jumping directly from C major to G dominant seventh is *at most* the sum of those two steps. This sounds almost trivially obvious, but proving it rigorously requires careful mathematics—composing two optimal voice assignments and showing the result is still nearly optimal.

Once you have a distance, you have a geometry. Musical chords become points in a space, and voice-leading cost becomes the ruler that measures how far apart they are. You can draw maps. You can find shortest paths. You can ask: what is the *diameter* of this space? What is the farthest apart two chords can be?

Computational experiments on a corpus of 60 common chord types (major, minor, dominant seventh, major seventh, minor seventh, across all 12 keys) reveal a rich landscape. The minimum nonzero cost is just 1 semitone—adjacent chords that differ by a single half-step in one voice. The maximum cost is over 40 semitones. The average is around 17. The space is *connected*: you can reach any chord from any other through a sequence of small voice-leading steps.

### An Ancient Intuition, Precisely

Composers have always known that some chord progressions feel "smooth" and others feel "jarring." The I–IV–V–I cadence in classical harmony moves through chords that are close together in voice-leading distance. The deceptive cadence, V–vi, works partly because the two chords are surprisingly close—only a few semitones of total motion separate them.

What is new is the mathematical rigor. The triangle inequality is not a rule of thumb; it is a *theorem* with a complete proof. The sorted matching optimality is not a heuristic; it is a *theorem*. And these theorems hold not just for four voices, but for any number of voices. The proofs work for 2 voices, 4 voices, 40 voices, or 4,000.

This generality matters because it connects music theory to a much larger mathematical universe.

### The Shipping Connection

In the 1780s, the French mathematician Gaspard Monge posed a problem: given a pile of earth and a hole to fill, what is the cheapest way to move the dirt? Each shovelful has a source location and a destination, and the cost of moving it depends on the distance. Monge showed that the optimal transport plan has a beautiful structure—it never crosses itself. If one shovelful goes from left to right, no other shovelful should go from right to left past it.

The voice-leading problem is Monge's problem in disguise. The "earth" is the pitch material of the source chord. The "hole" is the target chord. Each voice carries a shovelful of pitch from one location to another. And the uncrossing theorem—the same result Monge discovered for dirt—tells us that sorted matching is optimal for voices too.

This is why the formal proofs include a result called the "uncrossing lemma." It says: if two voice assignments cross (one voice goes up while another goes down past it), you can always uncross them without increasing the total cost. This atomic operation, applied repeatedly, transforms any matching into the sorted one while never making things worse.

### Tropical Geometry and Min-Plus Algebra

There is an even deeper connection lurking here. In a branch of mathematics called **tropical geometry**, the usual operations of addition and multiplication are replaced by minimum and addition. In this "tropicalized" world, the shortest path through a network becomes a simple algebraic expression, and the triangle inequality is not just a property of distances—it is the fundamental *axiom* of the entire algebraic system.

The voice-leading cost sits naturally in this tropical framework. A chord progression is a path through harmonic space. The total cost of the path is the sum of step costs—which is exactly a tropical product. The triangle inequality says that the direct tropical path is never longer than any detour. This makes voice-leading cost a tropical metric, and chord space becomes a tropical geometric object.

This is not just abstract elegance. Tropical methods have found applications in phylogenetics (the mathematics of evolutionary trees), auction theory, machine learning, and combinatorial optimization. The fact that musical harmony speaks the same tropical language suggests that algorithms developed for these fields could be imported directly into computational music theory—and vice versa.

### What the Computer Proved

The results described here have been formally verified by computer—not just tested on examples, but *proved* with mathematical certainty. The proofs handle every possible chord, every possible number of voices, and every possible permutation. They use no approximations, no numerical estimates, no statistical sampling. They are absolute.

The key results verified include:

1. **Triangle inequality** for n-voice voice-leading cost, for any number of voices n.
2. **Permutation invariance**: relabeling which singer sings which note never changes the cost.
3. **Sorted matching optimality**: when both chords are sorted, the identity assignment is optimal.
4. **Uncrossing lemma**: crossing voice assignments always costs at least as much as uncrossed ones.
5. **Tropical path bounds**: the endpoint cost of any chord progression is bounded by the sum of step costs.
6. **Zero-cost characterization**: two chords have cost zero if and only if they are rearrangements of each other.

These proofs required several hundred lines of formal reasoning, carefully managing the interaction between permutation groups, integer arithmetic, absolute values, and finite optimization.

### The Road Ahead

This work opens several research directions. One is to build certified algorithms for voice-leading search—programs that not only find the optimal progression but *prove* they have found it. Another is to study the global geometry of chord space: its curvature, its symmetries, its natural coordinates.

Perhaps the most exciting direction is the connection to machine learning. Modern AI systems for music composition typically learn voice-leading rules from data, with no guarantee that their output respects mathematical constraints. A formally verified cost geometry could provide *hard constraints* that guarantee smooth voice leading, integrating mathematical rigor with neural creativity.

There is also a deeper philosophical point. Music is often described as the most abstract of the arts—pure pattern without material substance. Yet the mathematics of voice leading is identical to the mathematics of physical transport, resource allocation, and network optimization. Harmony is not just beautiful. It is *efficient*. And the proof of that efficiency is now a theorem.

---

*The research described in this article establishes a formally verified mathematical framework for voice-leading cost on finite chord spaces, proving the triangle inequality, permutation invariance, and sorted matching optimality for arbitrary numbers of voices. The work connects classical music theory to discrete optimal transport, tropical geometry, and combinatorial optimization.*
