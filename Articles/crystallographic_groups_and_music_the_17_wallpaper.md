# The Seventeen Rhythms: How the Symmetry of Wallpaper Hides Inside Music

## A pattern that repeats

Look at the tiled floor of an old cathedral, the woven border of a Persian rug,
or the printed paper that lines the walls of a Victorian parlor. Stand back far
enough and something remarkable happens: the design stops being a collection of
individual flowers or stars and becomes a *rule*. Slide the whole pattern one
tile to the right and it lands exactly on top of itself. Flip it across a
vertical line and nothing changes. Spin it a half-turn around a clever point and
it is restored. The pattern has **symmetries** — motions of the plane that leave
it looking untouched.

In the nineteenth century, crystallographers and mathematicians asked a question
that sounds like it should have a boring answer and instead has a beautiful one:
*how many essentially different ways can a flat repeating pattern be symmetric?*
Not how many patterns — there are infinitely many wallpapers — but how many
**kinds of symmetry** a wallpaper can have. The answer, proved at the close of
the 1800s, is a single, sharp, surprising number.

**There are exactly seventeen.**

Seventeen "wallpaper groups." Every repeating two-dimensional design that has
ever been printed, woven, carved, or imagined belongs to one of exactly seventeen
symmetry types. The Alhambra's tilework, M. C. Escher's interlocking lizards,
the hexagons of a beehive, the brick of a sidewalk — each is one of seventeen.
No design can invent an eighteenth.

This article is about a question that, once you have heard it, feels inevitable:
**what does a wallpaper have to do with a drumbeat?** The answer is that rhythm —
the oldest, most physical, most universal of musical materials — is governed by
exactly the same mathematics. A beat that repeats is a pattern that repeats. And
the symmetries of a beat fall into the same crystallographic catalog that
classifies the symmetries of a floor.

## Rhythm as a function

Strip a rhythm down to its bones and it is astonishingly simple. Imagine a grid
of equal time-slots — the steps of a drum machine, the beats of a bar. In each
slot, something either happens or it doesn't: a drum is struck (an *onset*) or it
is silent. That is all a rhythm is, at the lowest level: a sequence of yes/no
decisions laid out in time.

Mathematically we write this as a function from the integers to the two-element
set {silent, onset}. We will call onset `true` and silence `false`. So a rhythm
is a function

> `pattern : ℤ → Bool`

that assigns to every beat position a single bit. The "boom-bap" of a backbeat,
the tresillo of Latin music, the clave of son cubano — each is one of these
functions.

Real music repeats. A groove that lasts one bar is played again, and again, all
night. We capture this with a single, decisive condition: there is a whole number
`period` (the length of one bar, say 16 sixteenth-notes) such that shifting the
whole rhythm forward by that many beats changes nothing. In symbols,

> `pattern (n + period) = pattern n` for every beat `n`.

This is *exactly* the defining property of wallpaper: slide it by one tile and it
returns to itself. A periodic rhythm is a one-dimensional wallpaper, drawn not on
a wall but along the timeline.

From this single assumption, a small avalanche of structure follows. If shifting
by one period leaves the rhythm unchanged, then so does shifting by two periods,
three periods, or backward by any number of periods. The set of "safe shifts" —
the distances you can slide the rhythm without disturbing it — is never just a
random scatter of numbers. It is closed under addition (do two safe shifts in a
row and the result is safe), it contains zero (don't move at all), and it is
closed under reversal (any safe forward shift is a safe backward shift). In the
language of algebra, the safe shifts form a **group**: the *symmetry group* of the
rhythm. Every multiple of the period lives inside it, and that fact alone is a
small theorem with a clean inductive proof.

This is the first place the music and the mathematics fuse. The "symmetry group
of a rhythm" is not a metaphor. It is the same kind of object — a subgroup of the
integers — that a crystallographer would write down for a row of identical atoms.

## Two more ways to be symmetric

Sliding is only the most obvious symmetry. There are two others, and every
musician knows them by other names.

**The mirror.** Play a rhythm forwards, then play it backwards, and if it sounds
identical you have a **palindrome**. The drummed phrase "boom — tap — tap — boom"
reads the same in either direction. Formally, a rhythm of length `n` is
palindromic when the beat at position `k` always matches the beat at the mirrored
position `n − 1 − k`. Reflecting such a rhythm is an involution: do it twice and
you are exactly back where you started — a fact we can state and prove with a
single line of reasoning about index arithmetic. And a rhythm is palindromic
precisely when it equals its own reflection, which sounds obvious until you
realize it is the formal hinge that lets you *test* for palindromicity by a
finite check.

Palindromic rhythms hide a delicate counting secret. Suppose the rhythm has an
*odd* length, `2k + 1`, so there is a single beat dead in the center. Then the
total number of onsets in the whole bar has the same parity — even or odd — as
that one central beat. The reason is pure symmetry: every onset that is *not* in
the center is paired with its mirror image, and pairs always contribute an even
number. So the parity of the entire rhythm is decided by a single beat at its
heart. This is the kind of statement that is invisible until the symmetry reveals
it, and then it is undeniable.

**The half-turn.** In two dimensions there is a symmetry with no
one-dimensional analog: rotation. Spin a pattern 180 degrees about a center point
and it may land back on itself. In music this is **call-and-response** — the
second half of a phrase is the first half turned upside down and backward, an
answer that mirrors the question in both time and pitch.

To even *have* rotation we need a second dimension, and music supplies one for
free.

## The drum pattern: music in two dimensions

A single drum lives on a line. But a *drum kit* — or a piano roll, or any score —
lives on a grid. One axis is time, running left to right. The other axis is
**pitch** (or voice, or instrument), running bottom to top: kick drum low, snare
in the middle, hi-hat on top; or the eighty-eight keys of a piano stacked
vertically.

A drum pattern is therefore a function of two integer coordinates,

> `pattern : ℤ × ℤ → Bool`,

marking each (time, pitch) cell as an onset or a rest. And real music is periodic
in *both* directions: it repeats in time (bar after bar) and, because pitch is
organized into octaves, it can repeat in pitch as well. A doubly-periodic grid of
onsets is — literally, not by analogy — a piece of wallpaper. The time axis and
the pitch axis are the two directions in which the design tiles the plane.

Now all seventeen symmetry types become available, because the two-dimensional
plane supports motions the line cannot:

- **Time mirror**: reverse the pattern in time. `pattern(−t, v) = pattern(t, v)`.
  Musically, retrograde.
- **Pitch mirror**: invert the pattern in pitch, flipping high and low.
  `pattern(t, −v) = pattern(t, v)`. Musically, melodic inversion.
- **180-degree rotation**: do both at once. `pattern(−t, −v) = pattern(t, v)`.
  Musically, retrograde-inversion — the technique at the structural heart of
  Bach's canons and Schoenberg's twelve-tone rows.

Each of these is a symmetry an actual composer can hear and use. And here a small
theorem with enormous reach appears, the bridge that makes the whole
classification tick:

> **If a drum pattern is symmetric under both the time mirror and the pitch
> mirror, then it is automatically symmetric under the 180-degree rotation.**

The proof is almost a haiku. Take the rotated cell `(−t, −v)`. By the pitch
mirror, it equals `(−t, v)`. By the time mirror, that equals `(t, v)`. Two
reflections compose into a rotation. Read it again and you have just witnessed,
in two lines, the reason a "double mirror" symmetry type necessarily *contains* a
rotation type — the reason crystallographers write **pmm ⊇ p2**. Combine
retrograde and inversion and you get retrograde-inversion for free. The
mathematics of wallpaper has just predicted a fact of counterpoint.

## The catalog of seventeen

With reflection, rotation, translation, and their cousin the **glide reflection**
(slide-and-flip in one motion — the geometric signature of a **canon**, where a
voice chases itself at a delay), we can finally name all the types. Each
wallpaper group is a different recipe of allowed symmetries, and each one has a
musical personality:

1. **p1** — no symmetry but the beat's own repeat: *free rhythm*.
2. **p2** — 180-degree rotation: *call-and-response*.
3. **pm** — mirror reflection: *palindrome*.
4. **pg** — glide reflection: *canon*.
5. **cm** — mirror plus glide: *round*.
6. **pmm** — two perpendicular mirrors: *bilateral palindrome*.
7. **pmg** — mirror plus glide: *inverted canon*.
8. **pgg** — two glides: *double canon*.
9. **cmm** — double mirror plus glide: *round meets palindrome*.
10. **p4** — quarter-turn (4-fold) rotation: *the four-bar cycle*.
11. **p4m** — 4-fold plus mirrors: *variations on a theme*.
12. **p4g** — 4-fold plus glides: *inverted variations*.
13. **p3** — third-turn (3-fold) rotation: *the three-bar blues*.
14. **p3m1** — 3-fold plus mirrors.
15. **p31m** — 3-fold plus glides.
16. **p6** — sixth-turn (6-fold) rotation: *whole-tone symmetry*.
17. **p6m** — 6-fold plus every mirror: *maximal symmetry, the "perfect" rhythm*.

That the list closes at seventeen is not an opinion; it is a theorem, and in our
formal treatment it is verified by exhaustive computation: the catalog of types
is an enumerated structure, and counting it returns exactly **17**. Sorting those
seventeen by whether they contain a mirror gives exactly **10** mirror types;
sorting by whether they contain a glide reflection gives exactly **8**. These are
not round-number coincidences. They are census facts about the space of all
possible repeating patterns, checked beat by beat.

## Why only 1, 2, 3, 4, and 6?

Hidden inside the catalog is the single strangest fact in the whole subject. Look
at the rotation orders that appear: 1-fold (no rotation), 2-fold (half-turn),
3-fold, 4-fold, and 6-fold. **There is no 5-fold. There is no 7-fold.** You can
tile a floor with triangles, squares, and hexagons, but never with regular
pentagons. A repeating pattern simply cannot have five-fold rotational symmetry.

This is the **crystallographic restriction**, and it is one of those results that
feels like it must be wrong until you see why it is right: a rotation that
repeats a lattice must map the lattice to itself, and the arithmetic of lattices
permits only the orders 1, 2, 3, 4, and 6. In our formalization this restriction
is stated and proved for every one of the seventeen types: each type's maximal
rotation order is checked to lie in the set {1, 2, 3, 4, 6}, with no exceptions
and no escapes.

The musical reading is delicious. It says: a perfectly repeating groove cannot be
built around a 5-beat or 7-beat *rotational* symmetry. You can certainly write
music in 5/4 or 7/8 — Dave Brubeck and Pink Floyd did — but such meters get their
character precisely from the *tension* of resisting symmetric closure. The deep
symmetries, the ones that let a pattern fold onto itself, live only at 2, 3, 4,
and 6. This is why so much of the world's dance music breathes in twos, threes,
fours, and sixes. The constraint is not a fashion. It is a law of patterned space.

## Symmetry is information, compressed

There is one last idea, and it is the one that turns this from a pretty analogy
into a useful science. **The more symmetric a rhythm is, the less information it
contains** — and that is a precise, quantifiable statement.

A rhythm of period `p` has, in principle, `p` independent yes/no choices to make:
`2^p` possible grooves. But if the rhythm is forced to be symmetric under a group
of `d` shifts, those choices are no longer free. Once you decide the first
fundamental chunk, symmetry dictates the rest. The number of truly independent
decisions drops to `p / d`. We prove the monotonic version of this directly: if
one rhythm's symmetry group is at least as large as another's, it has *no more*
degrees of freedom. At the extreme of maximal symmetry — every shift is a
symmetry — a rhythm collapses to a single degree of freedom: it is constant, all
onsets or all silence. At the opposite extreme of trivial symmetry, all `p`
choices remain free.

This is why a machine-gun sixteenth-note pattern (maximal symmetry) carries
almost no information and quickly bores the ear, while a free, asymmetric phrase
(type **p1**) carries the most — and why the grooves we find most satisfying live
in the tension-filled middle, partially symmetric, partially surprising. Symmetry
is a compression scheme, and good rhythm is the art of choosing how much to
compress.

There is even a clean number-theoretic corollary lurking here, the engine of the
classical "necklace counting" that enumerates distinct bracelets of colored
beads. The number of length-`p` patterns left unchanged by a rotation of `k`
steps is `2` raised to the greatest common divisor of `k` and `p`. When `p` is
prime, this forces a stark dichotomy: a nonzero rotation fixes *only* the two
trivial patterns (all-on and all-off), because the only common divisor is 1.
Primes admit no nontrivial rotational symmetry at all — which is exactly why
rhythms in prime-length meters feel so restless and irreducible.

## The shape of a groove

We began with a tiled floor and ended inside the logic of a drumbeat, and the
path between them never left a single line of mathematics. A rhythm is a function.
A repeating rhythm is a wallpaper. The ways it can be symmetric are seventeen, no
more and no fewer. Two mirrors make a rotation; five-fold symmetry is forbidden;
symmetry is information spent.

The next time you hear a groove lock into place — the backbeat answering the kick,
the hi-hat shimmering in perfect fours, a call chasing its response around the bar
— you are hearing a crystal. Not a metaphorical one. The same seventeen symmetry
types that organize every wallpaper ever made are organizing the air in the room.
Music, it turns out, is geometry you can dance to.
