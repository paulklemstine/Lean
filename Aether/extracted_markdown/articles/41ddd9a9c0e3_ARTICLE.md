# When Democracy Curves: The Hidden Geometry of Voting

## A paradox older than you think

Imagine three friends — Ana, Ben, and Cleo — deciding where to spend a weekend.
The three candidate destinations are the **A**lps, the **B**each, and a **C**ity.
Each friend ranks the three honestly:

- Ana likes the Alps best, then the Beach, then the City: **A > B > C**.
- Ben likes the Beach best, then the City, then the Alps: **B > C > A**.
- Cleo likes the City best, then the Alps, then the Beach: **C > A > B**.

Now they vote, two destinations at a time, by simple majority.

- *Alps vs. Beach?* Ana and Cleo both prefer the Alps to the Beach. **Alps win.**
- *Beach vs. City?* Ana and Ben both prefer the Beach to the City. **Beach wins.**
- *City vs. Alps?* Ben and Cleo both prefer the City to the Alps. **City wins.**

So the Alps beat the Beach, the Beach beats the City — and the City beats the
Alps. The group, made of three perfectly rational individuals, has produced an
*irrational* whole: a preference that runs in a circle. There is no "best"
choice. Whatever the friends pick, a two-thirds majority would rather have
something else.

This is the **Condorcet paradox**, discovered by the Marquis de Condorcet in
1785. It is not a trick of phrasing or a failure of arithmetic. It is a
structural feature of collective choice — and in 1951 the economist Kenneth
Arrow turned it into one of the most famous impossibility theorems in all of
social science. Arrow proved, roughly, that *no* voting rule can simultaneously
satisfy a short list of utterly reasonable fairness requirements unless it is a
dictatorship: a rule that always copies one fixed person's ranking.

For seventy years we have known Arrow's theorem is true. The question this
article is about is different and stranger: **what does the paradox *look* like?**
And the surprising answer, which we made fully rigorous, is that it looks like
**curvature** — the same mathematical quantity that distinguishes a flat sheet
of paper from the surface of a globe.

## Flatness, curvature, and walking in circles

Here is the geometric intuition. Take a flat tabletop and a pencil pointing
north. Slide the pencil — never rotating it — all the way around the edge of the
table and back to where it started. It still points north. Nothing happened.

Now do the same on the surface of the Earth. Start at the North Pole with your
pencil pointing toward London. Walk straight down to the equator. Turn and walk
a quarter of the way around the equator. Then walk straight back up to the Pole.
You return to your exact starting point — but your pencil is now pointing 90°
away from where it started, toward, say, New York. You never rotated it. The
*surface itself* twisted it for you.

That twist-after-a-round-trip is called **holonomy**, and the local quantity
that produces it is **curvature**. A flat space has zero curvature and no
holonomy: round trips change nothing. A curved space has nonzero curvature, and
loops come back twisted.

Now look again at our three friends. Walking "Alps → Beach → City → back to
Alps" is a loop. On a flat preference space, going around the loop by majority
rule should bring you home to a consistent ranking. Instead it twists: each step
is a majority win, but the round trip reverses you. **The Condorcet cycle is
holonomy. The paradox is curvature.** Society's preferences live on a curved
surface, and Arrow's theorem is the statement that you cannot iron the curvature
out without flattening everyone's voice into one person's.

This article describes a complete, machine-checked formalization of that idea —
turning the metaphor "voting paradoxes are curvature" into precise definitions
and proved theorems.

## Making the metaphor exact

To do real mathematics with the analogy, we first need to say exactly what the
"preference space" is and what "curvature" means on it.

**Rankings and profiles.** With *n* alternatives, a single voter's opinion is a
*strict ranking* — a way of putting the alternatives in order with no ties. With
*k* voters, a **preference profile** is just a list of *k* such rankings, one per
voter. The whole space of possible profiles is the arena; each individual
profile is a "point" in it.

**The majority margin.** For any two alternatives *a* and *b*, count how many
voters prefer *a* to *b* and subtract how many prefer *b* to *a*. Call this the
**majority margin** from *a* to *b*. It is positive when *a* wins the head-to-head,
negative when it loses, and it is naturally **antisymmetric**: the margin from
*a* to *b* is exactly the negative of the margin from *b* to *a*. (We proved
this; it is the discrete echo of "a gradient points one way or the other, never
both.") We also proved the margin can never exceed the number of voters in size —
a "bounded geometry" guarantee — and that if *everyone* prefers *a* to *b*, the
margin is maximal, equal to the full electorate.

**The majority tournament.** Draw an arrow from *a* to *b* whenever *a* beats *b*
by strict majority. With an odd number of voters there are never ties, so every
pair of alternatives gets exactly one arrow. The resulting structure — a complete
collection of one-way arrows — is called a **tournament**. It is the social
"connection" that tells you, locally, which way preference flows between any two
options.

**Condorcet curvature.** Here is the key definition. The **Condorcet curvature**
of a profile is simply *the number of directed three-cycles in its majority
tournament* — the number of triples *(a, b, c)* with *a* beating *b*, *b*
beating *c*, and *c* beating *a*. Each such triple is a little loop that comes
back twisted: a Condorcet cycle. Curvature zero means no loops twist — the space
is **flat**. Positive curvature means at least one loop twists — the space is
**curved**.

This is not a vague analogy bolted on afterward. It is a single, completely
explicit count, and from it everything follows.

## The theorems

With the definitions in place, we proved a tightly connected chain of results.
We state them in plain language; each one is a fully verified theorem.

**1. Flat means consistent (and curved means cyclic).**
A tournament is *transitive* — meaning "if *a* beats *b* and *b* beats *c*, then
*a* beats *c*", the hallmark of a sensible ranking — **if and only if** it has no
three-cycle. In curvature language: *a preference space is flat exactly when it
admits a coherent social ranking.* We proved both directions. Vanishing curvature
forces global consistency; the tiniest bit of curvature (one three-cycle)
destroys it. This is the discrete twin of the classical differential-geometry
fact that vanishing curvature implies trivial holonomy.

**2. Curvature is exactly the obstruction.**
We proved that **Condorcet curvature equals zero if and only if there is no
majority cycle at all**, and, conversely, that **positive curvature guarantees
the existence of a cycle** *(a, b, c)* you can point to explicitly. Curvature is
therefore not a loose summary statistic — it is *the* precise obstruction to
having a well-defined collective will. When it vanishes, majority rule itself
delivers a clean, transitive social ordering with no dictator in sight: flat
spaces support democracy.

**3. Unanimity is the flat limit.**
When all voters share the same ranking, the curvature is zero. We proved it.
Geometrically this is the most natural fact in the world — *a single point has no
curvature.* If everyone agrees, every loop is trivial, and majority rule simply
echoes the shared opinion. Agreement is the perfectly flat horizon of the
preference space.

**4. The Condorcet paradox is genuine curvature.**
The three friends from our opening are not a fluke. We proved there exists a
profile with strictly positive curvature — the classical paradox realizes a
nonzero three-cycle count. So the preference space genuinely curves: both flat
profiles and curved profiles exist, and curvature is a real, two-sided invariant
of the configuration, not something that is secretly always zero.

**5. The surprise: "curved everywhere" is impossible.**
Here the project turned up something genuinely clarifying. A natural way to try
to recover Arrow's impossibility theorem in this language is to hypothesize that
the curvature is positive *on every profile* and conclude that any fair rule must
be a dictatorship. We examined exactly that statement — and proved that **its
hypothesis can never hold.** Because the unanimous profile is always available,
and is always flat, *no* preference space can have positive curvature everywhere.
The "positive curvature everywhere" assumption is self-contradictory.

This is not a defect in Arrow's theorem; it is a sharpening of *where the
difficulty lives.* Curvature is not a global background property of the rules. It
is a feature of *which profiles voters actually bring.* The right question is
never "is the space curved everywhere?" — it can't be — but "is it curved on the
admissible profiles that can really occur?" The lesson is exactly the geometric
one: holonomy is computed over the loops that actually bound, not over every loop
you can imagine.

## A potential beneath the surface

The most beautiful consequence is a **cohomological** reading — a fancy word for
a simple, satisfying picture. In physics, a force field is "conservative" when it
is the gradient of a potential energy: you can assign every point a single number,
and the force always pushes from high to low. Round trips in such a field cost
nothing; the field is flat.

The same dichotomy governs voting. We proved that a majority tournament is
transitive (flat) **if and only if** its arrows are the "downhill" directions of
a single integer-valued *potential* assigned to the alternatives. Concretely,
that potential is the **Copeland score** — how many head-to-head contests each
alternative wins minus how many it loses. When the space is flat, *a* beats *b*
exactly when *a* has the higher Copeland score, for every pair. Society behaves
*as if* it were maximizing one shared quantity, a genuine "social utility."

And when the space is curved? Then **no such potential can exist.** A three-cycle
is precisely the obstruction to writing the majority margins as differences of a
potential — the discrete curl that no gradient can produce. This is the exact
discrete analogue of "a field with nonzero curl is not the gradient of any
potential." Arrow's impossibility, recast: the search for a single social-welfare
number is the search for a potential, and Condorcet curvature is the topological
obstruction standing in its way.

Our companion program enumerates all 216 three-voter, three-alternative profiles
and confirms the trichotomy with no exceptions: a profile is flat, exactly when
its majority tournament is transitive, exactly when the Copeland potential
reproduces the majority order. About 94% of these small profiles turn out flat;
the curved 6% are the Condorcet paradox and its relabelings.

## Why measure politics with curvature?

Beyond elegance, this reframing buys real conceptual leverage.

**It separates two questions that are usually tangled.** Arrow's theorem is often
heard as "fair voting is impossible." The curvature picture says something more
precise: *fair voting is impossible only to the extent that the preference space
is curved on the profiles that occur.* Flat regions of the space — places where
voters' opinions are aligned enough — support perfectly fair, non-dictatorial
aggregation by plain majority rule. Politics is hard exactly where the geometry
bends.

**It tells you where to look for escape routes.** Decades of social-choice theory
have searched for "domain restrictions" that dodge Arrow — most famously
*single-peaked* preferences, where voters agree on a left-to-right spectrum and
each simply has a favorite point on it. In our language these are candidate *flat
domains.* The framework makes the program crisp: characterize the admissible
profile sets on which curvature vanishes, and you have characterized exactly
where consensus is geometrically possible.

**It connects social choice to a vast mathematical toolkit.** Curvature,
holonomy, potentials, coboundaries, curl — these are the load-bearing concepts of
geometry and topology, developed over two centuries. Showing that voting paradoxes
*are* curvature, in a precise and proved sense, opens a dictionary between the two
fields. Quantities like the **Kendall tau distance** — the number of pairwise
disagreements between two rankings, which we proved behaves like a proper
distance (symmetric, zero only from a ranking to itself) — start to look like
genuine geodesic distances on the preference manifold, raising sharp, testable
questions linking how polarized an electorate is to how curved its choices become.

## The shape of disagreement

There is a deeper reason this matters. We are used to thinking of disagreement as
a matter of *degree* — people are a little apart, or a lot apart, on some line.
The curvature picture says disagreement also has a *shape.* Three people can each
be perfectly reasonable, pairwise close, and yet collectively trapped in a loop
that no ranking can untangle. That trap is not in any one of them. It is in the
*geometry of the space they form together.*

A flat world is one where preferences can be laid out on a single axis and a
clear collective will emerges. A curved world is one where the very act of
combining honest opinions produces something none of the participants holds — a
circular, self-defeating "will of the group." Both worlds are mathematically
real, both arise from ordinary voters, and the boundary between them is measured
by a single integer: the number of cycles, the curvature.

Condorcet glimpsed the loop in 1785. Arrow proved it was unavoidable in 1951.
What this work adds is a way to *see* it — not as a paradox to be explained away,
but as the curvature of the space democracy lives in, now stated with the full
precision of formal mathematics and checked, line by line, by machine.

The next time a group of reasonable people argues itself in circles, you will
know exactly what is happening. The discussion isn't broken. The space is just
curved.
