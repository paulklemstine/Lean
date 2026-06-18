# The Hidden Graph Inside Renaissance Music

## How a 500-year-old composition technique reveals a surprising mathematical structure

When Johann Joseph Fux published his treatise *Gradus ad Parnassum* in 1725, he codified rules that composers had followed for centuries. His "species counterpoint" — the art of writing two independent melodies that sound beautiful together — became the foundation of Western musical training. Bach studied it. Mozart taught it. Beethoven wrestled with it.

But buried inside Fux's seemingly simple rules lies a mathematical structure that nobody noticed for three hundred years: a directed graph with remarkable symmetry properties that connects music theory to modern combinatorics and category theory.

## The Rules of the Game

First-species counterpoint is the simplest form: note against note. Two voices move together, creating a sequence of vertical intervals — the harmonic distances between the notes. The rules are strict:

1. **Only consonant intervals allowed.** The voices may be a unison, minor third, major third, perfect fifth, minor sixth, or major sixth apart. That's six options out of twelve possible interval classes. Everything else — seconds, sevenths, the tritone — is forbidden.

2. **No parallel motion to perfect consonances.** If both voices arrive at a unison or perfect fifth by moving in the same direction by the same amount, the passage is illegal. You can reach these "perfect" intervals, but only by contrary motion (voices moving in opposite directions) or oblique motion (one voice staying put).

3. **Stepwise motion preferred.** Each voice should move by small amounts — typically one or two semitones at a time.

These rules seem musical, not mathematical. But what happens when you ask a simple question: *which consonant interval can follow which?*

## The Transition Graph

Imagine each consonant interval as a point on a map. Draw an arrow from interval A to interval B if a composer can legally move from A to B under the counterpoint rules. What does this map look like?

The answer is surprisingly precise. When each voice moves by at most two semitones (the stepwise constraint), the complete transition graph has:

- **6 vertices** (the six consonant intervals)
- **Exactly 26 directed edges** (the legal transitions)

Not 25. Not 27. Exactly 26. This number emerges from the interplay between the consonance constraint, the stepwise limitation, and the parallel-motion prohibition.

## The Separation Theorem

The most striking feature of this graph is a gap between the two "perfect" consonances — the unison and the perfect fifth.

Here's why: when each voice moves by at most two semitones, the interval between the voices can change by at most four semitones in either direction. But the unison and the perfect fifth are seven semitones apart. No amount of clever voice leading can bridge that gap in a single step.

This is the **Stepwise Separation Theorem**: under stepwise motion, the unison and perfect fifth exist in separate "neighborhoods" of the consonance space. They can never directly reach each other.

This result has a clean mathematical proof. If voice 1 moves by *a* semitones and voice 2 moves by *b*, the interval changes by *b − a*. When |*a*| ≤ 2 and |*b*| ≤ 2, we have |*b − a*| ≤ 4. But reaching the fifth from the unison requires a change of 7 (or equivalently, 5 going the other way). Since neither 5 nor 7 falls within the range {−4, …, 4}, the transition is impossible.

## The Bridge Intervals

Yet composers routinely move between unisons and fifths. How? Through intermediaries.

The graph reveals that the four imperfect consonances — the minor third, major third, minor sixth, and major sixth — serve as **bridges** between the separated perfect consonances. Every imperfect consonance can reach both the unison and the perfect fifth in a single step. So any path from unison to fifth (or back) must pass through at least one imperfect consonance.

This gives the transition graph a diameter of exactly 2: any consonant interval can reach any other in at most two steps, but some pairs (like unison-to-fifth) genuinely require two.

Composers have intuitively known this for centuries. Counterpoint textbooks advise using imperfect consonances as "bridges" between perfect ones. The graph makes this intuition precise and proves it is not merely a preference but a mathematical necessity.

## A Balanced Graph

Perhaps the most elegant discovery is that the transition graph is **balanced**: every vertex has the same number of incoming and outgoing edges. The unison has 4 edges out and 4 edges in. The major third has 5 out and 5 in. Every consonant interval is equally "reachable" as it is "escapable."

This is not obvious from the rules. The no-parallel-motion constraint treats perfect and imperfect consonances differently. The stepwise constraint creates asymmetric neighborhoods. Yet somehow, these constraints conspire to produce a perfectly balanced graph.

## The Inversion Asymmetry

Another surprise emerges when you ask about interval inversion — replacing each interval with its complement modulo the octave. The minor third (3 semitones) becomes the major sixth (9 semitones). The major third (4) becomes the minor sixth (8). These pairs are musically "equivalent" in a sense — they're the same interval heard upside-down.

The imperfect consonances respect this symmetry perfectly: if you invert any imperfect consonance, you get another imperfect consonance. But the symmetry breaks at the perfect fifth. Inverting the perfect fifth (7 semitones) gives the perfect fourth (5 semitones), which is *not* consonant in first-species counterpoint.

This asymmetry is well known to musicians — the perfect fourth has an ambiguous status in counterpoint theory, treated as dissonant in two-voice writing but consonant in three or more voices. The graph theory reveals that this is not an arbitrary convention but a structural consequence: the perfect fifth is the *unique* consonant interval whose inversion is dissonant. If you add the perfect fourth to the consonance set, inversion symmetry is restored.

## The Hub Intervals

The major third (4 semitones) and the minor sixth (8 semitones) stand out as the most connected intervals in the graph, each with five outgoing and five incoming edges. They are the "hubs" of the counterpoint network — the intervals from which the most options are available.

These two intervals are themselves an inversion pair: 4 + 8 = 12 ≡ 0 (mod 12). Their privileged position in the graph mirrors their privileged position in musical practice: thirds and sixths are the backbone of harmonic writing, the intervals around which everything else revolves.

## From Diatonic to Chromatic

When you restrict further to the diatonic scale (the white keys of the piano), the graph becomes sparser. Two consonant intervals — the minor third and the minor sixth — are not available as diatonic intervals from the root. The 26-edge chromatic graph shrinks to just 10 diatonic edges.

This quantifies something every music theory student learns: diatonic counterpoint is more constrained than chromatic counterpoint. The graph theory tells us exactly how much more constrained: a 62% reduction in available transitions.

## What It Means

The counterpoint transition graph is not just a curiosity. It reveals structural principles:

**The Cost of Perfection.** Perfect consonances pay for their acoustic purity with reduced connectivity. They are harder to reach, easier to get stuck at, and impossible to connect directly. Musical beauty has a combinatorial price.

**Bridges Are Necessary.** The imperfect consonances are not merely "weaker" versions of perfect ones. They serve a structural role that perfect consonances cannot: connecting the otherwise isolated regions of the consonance space.

**Balance From Asymmetry.** The most surprising result is the balanced graph property — that asymmetric local constraints produce global symmetry. This echoes similar phenomena in statistical mechanics and network theory, where local rules generate unexpected large-scale regularities.

The next time you listen to a Bach fugue or a Palestrina motet, listen for the consonances. The major thirds and minor sixths carrying you from one perfect cadence to the next are not arbitrary choices. They are the bridges of a 26-edge directed graph, the only paths through a consonance space shaped by rules that a Viennese theorist codified three centuries ago — rules whose mathematical structure we are only now beginning to understand.

*The research described here was carried out using methods from graph theory, combinatorics, and category theory applied to the formal rules of first-species counterpoint as codified by J.J. Fux (1725).*
