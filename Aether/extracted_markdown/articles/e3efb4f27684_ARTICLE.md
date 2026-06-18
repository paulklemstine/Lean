# The Shape of Sameness: When "Equal" Becomes a Journey

## A circle, a counter, and the question of identity

Take a piece of string and tie its ends together. You now hold a loop. Trace
your finger around it once, twice, three times — or go the other way. Something
quietly profound is happening: each way of running around the loop is *different*,
yet they all live on the very same circle. You cannot smooth a double loop into
a single loop without cutting the string. The number of times you wind around,
counted with a sign for direction, is a genuine, indestructible invariant.

That single observation — that *how* you go around a circle carries real
information — is the seed of one of the most surprising mathematical movements
of the last two decades: **Homotopy Type Theory**, or HoTT. Its radical claim is
that the everyday notion of "equals" is far richer than the flat, yes-or-no
relation we learned in school. In HoTT, to say two things are equal is to
exhibit a *path* between them, and there can be many genuinely different paths.
Equality has shape.

This article tells the story of a small, self-contained mathematical
construction that captures the heart of that idea and ties it back to the
classical mathematics most of us already trust. We will meet a strict ladder of
"how complicated can sameness get," a counter that turns loops into integers, a
principle that says "equivalent things are interchangeable," and a precise
accounting of how the great foundational systems of mathematics relate in
strength. Every result below is stated exactly; nothing is hidden behind a
reference.

## The ladder of complexity: truncation levels

Mathematicians eventually noticed that mathematical objects come with a built-in
"dimension of sameness." Consider four rungs of a ladder:

- **Contractible** objects are those with essentially *one* point — and not just
  one point, but one point with no interesting way of being equal to itself. A
  single dot. There is nothing to say.
- **Propositions** are objects where any two points are equal. A true/false
  statement: once it's true, all proofs of it are interchangeable. There may be
  a point, but there's no choice in it.
- **Sets** are objects where equality between points is itself a proposition:
  two elements are either equal or not, with no further structure. The whole numbers
  form a set. This is the world of classical mathematics.
- **Groupoids** are objects where equality *itself* carries structure — where two
  proofs that "a equals b" can themselves be unequal in interesting ways. The
  circle is the first creature that lives genuinely at this level.

We can package this ladder cleanly. Define a **truncation level** to be simply a
natural number index, with the dictionary: contractible = 0, proposition = 1,
set = 2, groupoid = 3, and in general "n-truncated" = n + 2. Order them by their
index. The first theorem of our story is the bedrock fact that *this ladder
really is a ladder* — every rung is strictly above the last:

> **The Truncation Hierarchy is Strict.** Contractible < Proposition < Set <
> Groupoid. There is no collapsing; each level of complexity is genuinely new.

It looks almost too simple to deserve a name. But its content is conceptual: it
records, as a formal mathematical fact, that the dimensions of sameness do not
secretly coincide. The ladder also behaves: stepping up one rung (the successor
operation) always strictly increases the level, and being "at most as complex
as" is transitive, so the rungs really form an order.

## Turning loops into numbers

Now we return to our circle and make the finger-tracing precise. Imagine
recording a trip around the loop as a string of instructions: at each step you
either go **forward** (write `true`) or **backward** (write `false`). A whole
loop is then just a list of booleans — a *formal loop*. The empty list is
standing still: the trivial loop.

To each such word we attach its **winding number**: start a counter at zero,
read the instructions left to right, add one for every forward step, subtract one
for every backward step. The final count is the net number of times you wound
around the circle.

This little counter has three beautiful properties, and together they say
something deep.

> **Additivity (concatenation law).** If you run loop A and then loop B, the
> winding number of the combined journey is the sum of the two winding numbers:
> winding(A then B) = winding(A) + winding(B).

> **Inversion (reverse law).** If you run a loop backwards — flipping every
> forward step to backward and vice versa — the winding number flips sign:
> winding(reverse of A) = −winding(A).

> **Surjectivity.** *Every* integer is achieved. For each whole number n, there
> is a loop whose winding number is exactly n: wind n times forward if n is
> positive, n times backward if negative, or stand still for zero.

Read those three statements again with a group theorist's eye. Concatenation of
loops is an operation; the trivial loop is an identity; reversing gives inverses;
and addition shows the operation matches the integers. What we have built, in
miniature, is the statement that **the fundamental group of the circle is the
integers** — written π₁(S¹) ≅ ℤ. This is a cornerstone of algebraic topology,
and in HoTT it becomes a statement about *paths and their structure* rather than
about continuous deformations. The winding number is the dictionary translating
geometry into arithmetic. The fact that it is additive, sign-reversing, and onto
is exactly the fact that loops on a circle, up to deformation, *are* the
integers.

There is a complementary fact at the bottom of the ladder. A space can be so
rigid that it has *no* interesting loops at all. Call a point rigid if the only
structure-preserving self-map fixing it is the identity. Then:

> **Triviality for rigid spaces.** If a point a in a space is rigid, every loop
> at a is the identity loop. Its fundamental group is trivial.

So the circle is interesting precisely because it is *not* rigid — you can rotate
it — while a discrete jumble of isolated points has nothing to wind around. The
contrast is the whole point: topology is the study of which spaces let you go
around.

## "Equivalent things are interchangeable": univalence

The beating heart of Homotopy Type Theory is a principle named **univalence**,
introduced by the Fields Medalist Vladimir Voevodsky. Stated as a slogan:
*equivalent structures may be identified.* If two mathematical objects are
interchangeable — if there is a perfect back-and-forth dictionary between them —
then univalence declares them *equal*, and anything true of one is automatically
true of the other.

We capture a working model of this principle abstractly. A **univalence model**
consists of a collection of "type names," an interpretation sending each name to
an actual object, and an equivalence relation on names with one crucial
guarantee: *whenever two names are related, their interpretations admit a perfect
back-and-forth translation* (an equivalence). The relation is reflexive,
symmetric, and transitive — the minimal honest bookkeeping for "is the same as."

Two consequences fall out immediately, and they are exactly the dividends
mathematicians cherish about univalence.

> **Equivalence preserves cardinality.** In a univalence model, if two type
> names are related, their interpretations have the same number of elements.

This is the formal echo of the everyday move "they're the same up to renaming, so
of course they have the same size." Under univalence you don't have to *prove*
that invariants transfer — they transfer for free, because the objects are
literally equal.

> **Function extensionality from univalence.** If two functions are equivalent at
> every input — pointwise interchangeable — then their outputs are interchangeable
> everywhere.

Function extensionality is the principle that two functions agreeing on all
inputs are the same function. It sounds obvious, but in a bare constructive
foundation it must be *assumed* or *derived*. One of univalence's celebrated
gifts is that it *implies* function extensionality; our model makes that
implication concrete.

## Counting the finite worlds

To see equivalence at its most tangible, descend to the finite. Write `Fin n` for
the standard n-element set {0, 1, …, n−1}. When are two such sets interchangeable?

> **Finite univalence.** There is a perfect back-and-forth translation between
> `Fin m` and `Fin n` if and only if m = n.

In other words, the *only* invariant of a finite set is its size, and that
invariant is faithful: same size means interchangeable, different size means
genuinely different. This is the cleanest possible illustration of the univalent
philosophy — the "name" of a finite world is its cardinality, full stop.

Closely related is a characterization of *what it means* to be a perfect
translation in the first place:

> **Equivalences are exactly the maps with unique fibers.** A function is a
> bijection if and only if every target value is hit by exactly one source value.

This recasts the abstract notion of equivalence as something you can check by
hand: look at each output, count the inputs that map to it, and confirm the count
is always exactly one.

## The structure identity principle

The grand payoff of this circle of ideas is what HoTT calls the **structure
identity principle**: isomorphic structures are equal, so any construction
respecting the structure transports along the isomorphism. We see a crisp finite
instance: take finite groups packaged together with the data of an equivalence
between their underlying sets that respects the group operation. Such
"equivalences of finite groups" *compose* — chain a translation from G to H with
one from H to K and you get a faithful translation from G to K.

> **Transitivity of structure equivalence.** Equivalences of finite group
> structures compose to give equivalences. Sameness of structure is a transitive
> relation: if G is the same as H, and H is the same as K, then G is the same as K.

That transitivity is precisely what licenses mathematicians to speak of "*the*"
group of a given type, or "*the*" finite set of a given size, without ever
worrying which concrete copy they hold. The structure identity principle is the
formal permission slip for the everyday phrase "without loss of generality, up to
isomorphism."

## How the great foundations relate

Finally, the construction zooms all the way out to ask: how do the rival
foundational systems of mathematics stack up against one another? We model a
**foundational system** as a record carrying a name, a numeric *consistency
strength*, and three feature flags — is it constructive? does it have univalence?
does it admit the axiom of choice? Five systems are catalogued:

- **ZFC** (classical set theory): strength 100, non-constructive, has choice.
- **MLTT** (Martin-Löf type theory): strength 80, constructive, no univalence.
- **HoTT** (homotopy type theory): strength 100, constructive, has univalence.
- **HoTT + LEM** (with the law of excluded middle): strength 100, classical, has choice.
- **CIC** (the calculus of inductive constructions): strength 90, constructive.

Ordering systems by strength, several facts emerge that mirror the real
mathematical landscape:

> **MLTT embeds in HoTT.** Martin-Löf type theory is interpretable in homotopy
> type theory — HoTT extends MLTT by *adding* univalence (MLTT has none, HoTT
> has it) without losing strength.

> **HoTT is equiconsistent with ZFC.** The two share the same consistency
> strength: HoTT is exactly as trustworthy as classical set theory, no more and
> no less. So if you believe ZFC is consistent, you must believe HoTT is too.

> **Consistency transfers upward.** If a weaker system is consistent (positive
> strength) and a stronger system contains it, the stronger system is consistent
> as well.

The upshot is reassuring and precise: the constructive, univalent universe of
HoTT is not some exotic gamble. It stands on exactly the same consistency
footing as the set theory that has underwritten mathematics for a century, while
offering a genuinely richer, shape-aware notion of equality.

## Why it matters

Strip away the formalism and a single idea remains: **identity is not flat**. The
number of ways two things can be "the same" is itself a mathematical object worth
studying. On a circle, those ways are counted by the integers. On a finite set,
there is exactly one way for each matching of sizes. Across foundations, the
ways translate cleanly enough that we can declare equiconsistency.

This shape-aware view of sameness is not a curiosity. It underlies modern proof
assistants, where verifying that two programs are "the same" or that two data
structures are interchangeable is a daily, load-bearing task. It feeds back into
algebraic topology, where the winding number we built by hand is the first entry
in an infinite catalogue of invariants. And it offers working mathematicians the
long-wished-for guarantee that "up to isomorphism" can be made literal, rigorous,
and automatic.

The circle, it turns out, was never just a circle. It was the first hint that
even the word *equal* has a hidden geometry — and that the journey from one thing
to another is as real as the things themselves.
