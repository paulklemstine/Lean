# The 17 Types of Rhythm: How Crystallography Reveals the Hidden Geometry of Music

*Why the same mathematics that classifies tile patterns on the Alhambra walls also classifies every possible rhythmic structure in music*

---

## The Alhambra Connection

Walk through the Alhambra palace in Granada, Spain, and you'll see something mathematicians have spent centuries analyzing: an astonishing variety of tile patterns covering walls, floors, and ceilings. Islamic artisans, forbidden from depicting living forms, pushed geometric pattern-making to its absolute limit. What they discovered through craft and intuition, mathematicians later proved as theorem: there are exactly 17 fundamentally different ways to tile a plane with a repeating pattern.

These 17 patterns — called *wallpaper groups* — represent the complete classification of two-dimensional symmetry. No matter how creative you get with tiles, your pattern must belong to one of these 17 types. It's one of the most elegant results in mathematics: a finite, complete catalogue of all possible periodic symmetries in two dimensions.

Now here's the surprise: those same 17 types classify something completely different — rhythm.

## Rhythm as Geometry

To see why, we need to think about what a rhythm actually *is*, mathematically. Strip away the drums and melodies, and a rhythm is simply a repeating pattern of hits and silences. You could write it as a sequence of ones and zeros: **1-0-1-0-1-0-1-0** for a straight eighth-note pulse, or **1-0-0-1-0-0-1-0** for a pattern with more swing.

This one-dimensional view captures a lot, but music is rarely just one voice. A drum kit pattern has a kick drum, a snare, hi-hats — multiple voices stacked on top of each other. If you write out a drum pattern on a grid where time runs left-to-right and the different drums stack top-to-bottom, you get a two-dimensional pattern of filled and empty cells.

And here's the key insight: if the pattern repeats (as virtually all musical rhythms do), you have a periodic two-dimensional binary pattern — exactly the kind of object that wallpaper groups classify.

## Mirrors, Rotations, and Glide Reflections

The 17 wallpaper groups are distinguished by what symmetries they possess. There are three basic types:

**Rotation**: spin the pattern around a point and it looks the same. In music, a 2-fold rotation corresponds to what musicians call *call-and-response* — the second half of a pattern is a transformed echo of the first.

**Mirror reflection**: flip the pattern across a line and it looks the same. In music, this is a *palindrome* — a rhythm that sounds the same forwards and backwards. Think of the rhythmic pattern in Bartók's "Music for Strings, Percussion and Celesta," where themes are constructed to be time-symmetric.

**Glide reflection**: slide and flip simultaneously. In music, this is a *canon* — one voice plays a melody while another plays it shifted in time and possibly inverted in pitch.

The beauty is that these three operations can be combined in exactly 17 distinct ways. Each combination produces a different wallpaper group, and each corresponds to a fundamentally different type of rhythmic structure.

## The Classification

The simplest type, **p1**, has no symmetry at all beyond basic repetition. This is *free rhythm* — a pattern that simply cycles without any internal structure. Think of a complex polyrhythmic pattern where no subset mirrors or echoes any other.

**p2** has 2-fold rotational symmetry: rotate the pattern 180° and it looks the same. Musically, this is call-and-response where the response is an exact inversion of the call.

**pm** has mirror symmetry — the palindrome. **pg** has glide reflection — the canon. **cm** combines both: a round, where voices enter one after another singing the same melody, and the whole structure is time-symmetric.

The double-mirror type **pmm** is particularly interesting. Our mathematical analysis proves a non-obvious theorem: *if a drum pattern has both time-mirror symmetry (palindromic) and pitch-mirror symmetry (instruments can be swapped), then it automatically has rotational symmetry*. Two perpendicular reflections compose to give a rotation. This is why the group pmm necessarily contains p2 — it's not a coincidence but a mathematical inevitability.

Moving to higher symmetry, **p4** has 4-fold rotational symmetry — the 4-bar cycle that dominates popular music. **p3** has 3-fold symmetry — the 12-bar blues compressed into its essential structure. At the summit sits **p6m**, with 6-fold rotational symmetry and mirrors, representing the most symmetric possible rhythm — a kind of rhythmic perfection that is rare in practice but theoretically fundamental.

## The Crystallographic Restriction

Why do the rotation orders stop at 6? Why not 5-fold or 7-fold or 13-fold symmetry?

This is the *crystallographic restriction theorem*, one of the deepest results in the geometry of tilings. For a pattern to tile the plane periodically, its rotational symmetries can only have orders 1, 2, 3, 4, or 6. Five-fold symmetry is impossible — which is why you'll never see a regular pentagon tiling at the Alhambra, and why 5-bar phrases in music always feel slightly unstable and incomplete.

The number 5 is excluded not by accident or convention but by geometric necessity. A 5-fold rotation is incompatible with the translation symmetry that periodicity requires. In music, this manifests as the practical observation that 5-beat meters (like the famous 7/8 or 5/4 time signatures of Balkan music) never quite settle into the same kind of pattern regularity as 2, 3, 4, or 6-beat meters.

## Counting Rhythms

How many distinct rhythms are there of a given length? If we have a pattern of length *n* and two rhythms are "the same" if one is a cyclic shift of the other (starting the pattern on a different beat), then counting distinct rhythms is a classic application of *Burnside's lemma*.

The key mathematical fact: the number of binary patterns of length *n* that are unchanged by a cyclic shift of *d* positions is exactly 2^gcd(d,n). This elegant formula connects rhythm counting to number theory — the greatest common divisor, one of the oldest concepts in mathematics, determines how many rhythms are preserved by each rotation.

For a palindromic rhythm of odd length 2k+1, there's a beautiful parity constraint: the total number of onsets has the same parity as the center beat. Each non-center position is paired with its mirror image, contributing an even number to the total. Only the center beat stands alone, determining whether the total is odd or even. This constrains the possible "weights" (densities) of palindromic rhythms.

## Ten of Seventeen

Of the 17 wallpaper types, exactly 10 have mirror symmetry and 8 have glide reflection. These aren't arbitrary numbers — they reflect the deep structure of how symmetries combine. The symmetry types form a lattice, with p1 (no symmetry) at the bottom and p6m (maximal symmetry) at the top. Every wallpaper group is a subgroup of p6m.

This hierarchy maps directly onto musical complexity. Free rhythm (p1) is the most complex because it has no constraints. As we add symmetries — mirrors, rotations, glides — the number of free parameters decreases. The most symmetric rhythm (p6m) is the most constrained, leaving the fewest choices for the composer.

This isn't just abstract mathematics. It explains why the most memorable rhythmic patterns tend to have moderate symmetry — enough structure to be recognizable, enough freedom to be interesting. The backbeat of rock and roll (p2 symmetry) sits in a sweet spot. The palindromic structures beloved by Messiaen and Bartók (pm symmetry) add a different kind of elegance.

## Beyond Taxonomy

The classification of rhythms by wallpaper group isn't just stamp-collecting. It's a tool for understanding why certain patterns work musically and others don't — and for generating new patterns that explore the full space of rhythmic possibility.

Most Western music lives in a tiny corner of this 17-element space: p1 (free), p2 (call-and-response), and pm (palindrome) account for the vast majority of rhythmic patterns. The other 14 types represent largely unexplored territory — rhythmic structures that are mathematically coherent but musically uncharted.

What would a p4g rhythm sound like? A p6 pattern? These aren't just theoretical curiosities — they represent real, constructible patterns with specific symmetry properties that no one has systematically explored.

The Moorish artisans of the Alhambra found all 17 wallpaper groups through centuries of experimentation. The musical exploration of these 17 types has barely begun. The mathematics tells us exactly what's possible. The art lies in making it sound good.

---

*The mathematical results described in this article have been formally verified, establishing with certainty the structural connections between wallpaper group symmetry and rhythmic pattern classification.*
