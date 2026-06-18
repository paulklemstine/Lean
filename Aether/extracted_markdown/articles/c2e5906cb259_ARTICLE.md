# Why Can't You Play Two Fifths in a Row? A Mathematical Answer to Music's Oldest Rule

## The Rule That Haunts Every Composition Student

Every student who has ever taken a music theory class knows the rule: *no parallel fifths*. Two voices singing a perfect fifth apart must not both move in the same direction by the same amount. The rule sounds arbitrary. Generations of students have asked *why*—and have been told it's a matter of style, of independence between voices, of aesthetic taste codified in the 18th century by Johann Joseph Fux.

But what if the answer isn't aesthetic at all? What if the prohibition against parallel fifths is woven into the very arithmetic of the twelve-tone scale—a consequence of abstract algebra that medieval musicians discovered intuitively centuries before mathematicians formalized the structures that explain it?

New research reveals that the distinction between "perfect" and "imperfect" consonances in Western music—a distinction older than the printing press—has a precise mathematical characterization hiding in plain sight. The perfect consonances (the unison and the perfect fifth) are *exactly* the consonant intervals whose algebraic order in the twelve-tone cycle is extreme: either trivial or maximal. Every imperfect consonance (thirds and sixths) has an intermediate order. The ancient musical categories are not accidents of culture. They are shadows of group theory.

## Counting to Twelve, Algebraically

To understand the discovery, we need to think about the twelve notes of the chromatic scale not as piano keys but as the numbers 0 through 11, arranged in a circle—a mathematical structure called the cyclic group ℤ/12ℤ. In this circle, every note can be added to every other note, and the results wrap around: 7 + 7 = 14 = 2 (mod 12). This isn't just a cute analogy. It's the foundation of an entire branch of music theory called *pitch-class set theory*, developed by Allen Forte and others in the 1960s.

Now, some numbers in this circle have a special property: if you keep adding them to themselves, you eventually cycle back to zero. The number 3, for instance, generates the sequence 0, 3, 6, 9, 0, 3, 6, 9, ... — it takes 4 steps to return to zero, so we say 3 has *additive order* 4. It generates a subgroup of four elements: {0, 3, 6, 9}, which musicians recognize as the diminished seventh chord.

The number 4 has order 3: it generates {0, 4, 8}, the augmented triad.

The number 7 is different. Keep adding 7: 0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5, 0. It visits *every* note before returning to zero. Its order is 12—it generates the entire group. In music, this is the "circle of fifths," the backbone of Western harmony.

And the number 0? It has order 1. It generates nothing but itself.

## The Theorem

Here is the discovery: among all twelve intervals, exactly six are consonant in strict counterpoint: the unison (0), minor third (3), major third (4), perfect fifth (7), minor sixth (8), and major sixth (9). Medieval theorists divided these six into two classes:

- **Perfect consonances**: unison (0) and perfect fifth (7)
- **Imperfect consonances**: minor third (3), major third (4), minor sixth (8), major sixth (9)

The parallel-motion rule applies only to perfect consonances. And the mathematical characterization is:

> *A consonant interval is perfect if and only if its additive order in ℤ/12ℤ is 1 or 12—that is, if it generates either the trivial subgroup or the entire group.*

The imperfect consonances all have intermediate orders (3 or 4). They generate proper, nontrivial subgroups.

This is not a coincidence. The perfect consonances are the algebraically "extreme" intervals: one does nothing (the unison), the other does everything (the fifth generates all twelve pitch classes). Imperfect consonances inhabit the middle ground, generating interesting but partial structures—the augmented triad and the diminished seventh chord.

## Why the Rule Exists

This explains the parallel-motion prohibition at a structural level. When two voices move in parallel at a perfect fifth, they trace the *same path* through pitch space—one that, by the circle of fifths, eventually reaches every note. The voices aren't independent; they're algebraically redundant. One voice is completely determined by the other.

For imperfect consonances, parallel motion traces a path through only a *subgroup* of pitch classes. The voices explore only part of the musical landscape, leaving room for the other voice to provide genuine harmonic information.

The unison (order 1) is the extreme case: parallel motion at a unison means the voices are literally the same note. Parallel octaves are essentially the same—duplicating a voice rather than adding to the texture.

## The Problem of the Fourth

Music theorists have long puzzled over the perfect fourth. It's the "complement" of the fifth—a fifth upside-down, since 5 + 7 = 12. In isolation, a fourth sounds consonant. Yet in strict counterpoint, Fux treats it as dissonant. Why?

The new framework provides a crisp answer. Consider the *complement map*: negating an interval in ℤ/12ℤ, which swaps an interval with the one that completes it to an octave. This map sends 3 to 9 (minor third to major sixth), 4 to 8 (major third to minor sixth)—it perfectly pairs the imperfect consonances. It also sends 0 to 0 (the unison is self-complementary).

But it sends 7 to 5.

And 5 is *not consonant*.

The perfect fifth is the **unique** consonant interval whose complement is dissonant. This is not a gap in the theory—it's a structural theorem. The consonance set is "almost" closed under complementation, failing at exactly one point: the perfect fifth, the interval that generates the entire chromatic group.

The fourth's ambiguous status isn't a quirk of Fux's pedagogy. It's a mathematical singularity.

## The Diamond Lattice

When we look at which subgroups the consonant intervals generate, a beautiful structure emerges. There are not twelve distinct subgroups but four, arranged in a diamond:

At the bottom sits the trivial subgroup {0}, generated by the unison. Above it, two incomparable subgroups: {0, 3, 6, 9} (the diminished seventh chord, generated by both the minor third and the major sixth) and {0, 4, 8} (the augmented triad, generated by both the major third and the minor sixth). At the top, the complete group ℤ/12ℤ, generated by the perfect fifth.

This diamond is a lattice—a partially ordered set where every pair of elements has a greatest lower bound and a least upper bound. The counterpoint rules, viewed through this lens, are a navigation policy on the diamond: you can move freely among the middle levels, but transitioning to the top or bottom via parallel motion is forbidden.

## Rigidity

One final surprise. The twelve-tone system has symmetries: the automorphisms of ℤ/12ℤ, which are multiplication by units (1, 5, 7, 11). You might expect the consonance set to be preserved by some of these symmetries, the way a square is preserved by certain rotations.

It isn't. Only the identity automorphism preserves {0, 3, 4, 7, 8, 9}. The consonance set is *rigid*—it has no nontrivial algebraic symmetry within the twelve-tone system.

This means the consonance structure cannot be derived from the group structure alone. It's additional data, chosen by acoustics and culture, that sits rigidly within an algebraic framework. The group theory doesn't *create* the consonances—but once they're given, it explains why the rules governing them take the form they do.

## What It Means

This research bridges three fields that rarely talk to each other: music theory, abstract algebra, and category theory. The counterpoint rules of an 18th-century pedagogue turn out to encode the subgroup lattice of a cyclic group. The "problem of the fourth"—debated by theorists for centuries—reduces to a statement about fixed points of an involution. And the entire structure is rigid, unique, irreducible.

For mathematicians, it's a reminder that group theory lurks in unexpected places. For musicians, it's vindication: the rules they learned aren't arbitrary—they reflect deep structural constraints. And for anyone who has ever wondered why two fifths in a row sound wrong, the answer is surprisingly simple.

It's because the fifth generates everything. And a rule that lets you generate everything isn't a rule at all.

---

*This research was conducted using methods from abstract algebra, category theory, and order theory, building on the harmonic music theory foundations established in the Pythagorean/HarmonicMusicTheory research line.*
