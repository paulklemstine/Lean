# Isomorphisms of Meaning: When Structures Collide

## Two things that are the same — and yet are not

Imagine two objects that are, by every measurement you are allowed to make,
*identical*. Weigh them, spin them, probe them with every instrument in your
laboratory: every reading agrees, down to the last decimal. And yet the two
objects are not the same. They sit in different places. They touch different
things. If you asked them to do a job, they would move different parts of the
world.

This is not a paradox from science fiction. It is an everyday feature of
mathematics, and it turns out to have a crisp, provable shape. There is a
difference between what a structure *is*, abstractly, and what a structure
*means*, concretely — and that difference can be made exact. This article is
about that split, which we will call the split between **truth** and
**meaning**, and about a single mechanism that produces it in two very
different corners of mathematics: the symmetries of a set, and the arithmetic of
divisibility.

## Symmetries, and the symmetries of symmetries

Start with something small. Take a set of three objects — call them $0$, $1$,
and $2$. A *symmetry* of this set is a way of shuffling the three objects so that
each ends up in exactly one place: a permutation. There are six of them,
including the "do nothing" shuffle.

Now suppose someone hands you a second three-element set — say the colors red,
green, and blue — and a dictionary that translates between the two: $0
\leftrightarrow \text{red}$, $1 \leftrightarrow \text{green}$, $2 \leftrightarrow
\text{blue}$. This dictionary is what mathematicians call an *equivalence*, or an
*isomorphism*: a perfect, reversible correspondence.

Here is the beautiful part. That single dictionary automatically translates not
just the objects but the *symmetries themselves*. If you have a shuffle of $\{0,
1, 2\}$, you can push it through the dictionary and get a shuffle of $\{\text{red},
\text{green}, \text{blue}\}$: relabel the inputs, apply the shuffle, relabel the
outputs. This gives a perfect correspondence between the six symmetries of the
first set and the six symmetries of the second. It is an isomorphism — but an
isomorphism *between the two groups of isomorphisms*. An **isomorphism of
isomorphisms**.

Write $e$ for the dictionary and, for any symmetry $f$, write $\Phi_e(f)$ for the
translated symmetry. This translation behaves exactly as a good translation
should: it respects composition. If you translate first through a dictionary $e$
and then through a second dictionary $e'$, the result is the same as translating
once through the combined dictionary $e$-then-$e'$. In symbols,

$$\Phi_{e' \circ e}(f) = \Phi_{e'}\big(\Phi_e(f)\big).$$

Nothing is lost, nothing is scrambled, at any stage. The translation of
symmetries is *functorial* — it plays nicely with chaining dictionaries
together. This is the sense in which the isomorphism of isomorphisms is not an
accident but a structural, universal feature.

## What survives translation: truth

Once you can translate symmetries, you can ask: **what stays the same?**

Every symmetry has an *order* — the number of times you must repeat it before
everything returns to where it started. A simple swap of two objects has order
$2$: do it twice and you are back to the beginning. A three-way rotation has
order $3$. Translation through any dictionary preserves the order exactly:

$$\text{order}\big(\Phi_e(f)\big) = \text{order}(f).$$

Every symmetry also has a *parity*, or *sign*: it is either "even" or "odd",
depending on whether it can be built from an even or odd number of simple swaps.
Parity, too, survives translation untouched. And every symmetry disturbs a
certain *number* of points — its "support size", the count of objects that
actually move. Translation relabels *which* points move, but never changes *how
many*:

$$\#\,\text{support}\big(\Phi_e(f)\big) = \#\,\text{support}(f).$$

Finally, and most sweepingly, every finite symmetry has a *cycle type*: the list
of the lengths of the cycles it breaks into. (A shuffle that swaps two points and
fixes a third has cycle type "one 2-cycle"; a full three-way rotation has cycle
type "one 3-cycle".) Cycle type is the master invariant: two symmetries have the
same cycle type exactly when one can be obtained from the other by relabeling. It
is preserved by translation as a matter of course.

These invariant quantities — order, parity, support size, cycle type — are what
we call **truth**. They are the properties that belong to a symmetry *as an
abstract object*, blind to the names of the points it acts on. They are exactly
the things that any dictionary carries across faithfully. A theorem about truth
is a theorem you can prove once and transport everywhere.

## What does not survive: meaning

Now for the twist that gives this article its title.

Consider two specific symmetries of $\{0, 1, 2\}$. The first swaps $0$ and $1$,
leaving $2$ alone. The second swaps $1$ and $2$, leaving $0$ alone. Call them
$(0\ 1)$ and $(1\ 2)$.

Compare them by every measure of truth we have:

- **Cycle type?** Both are a single swap of two points. Identical.
- **Order?** Both have order $2$. Identical.
- **Parity?** Both are single swaps, hence odd. Identical.
- **Support size?** Both move exactly two points. Identical.

By every relabeling-invariant property — by *all the truth there is* — these two
symmetries are indistinguishable. No measurement made inside the abstract group
of symmetries can tell them apart. And yet:

$$(0\ 1) \neq (1\ 2).$$

They are *different symmetries*. The first moves the points $\{0, 1\}$; the
second moves the points $\{1, 2\}$. Their supports are different sets. They *do*
different things to the concrete world of labeled objects.

This is the collision. Two objects agree on every abstract invariant — same cycle
type, same order, same sign, same support size — and are nonetheless not equal.
The thing that separates them is not any property of the *structure*. It is only
the concrete choice of *labels*: which specific points get moved. We call this
residue **meaning**. Truth is what the isomorphism preserves; meaning is what the
isomorphism is free to move around.

Formally, the collision is the statement that there exist two symmetries $f$ and
$g$ of a three-point set with

$$\text{cycleType}(f) = \text{cycleType}(g), \quad \text{order}(f) =
\text{order}(g), \quad \text{sign}(f) = \text{sign}(g),$$

and yet $f \neq g$ with different supports. It is not a trick of weak
measurements: cycle type is the *complete* invariant, the most refined
relabeling-blind description possible. When even the complete invariant cannot
separate two objects, no invariant can. The gap between truth and meaning is
therefore not a defect of our instruments. It is real, and it is irreducible.

## The same phenomenon in the world of numbers

Here is why this is more than a curiosity about tiny sets. The very same
mechanism appears, unchanged, in pure number theory.

Consider sequences of whole numbers $u_1, u_2, u_3, \dots$ that respect
divisibility in the strongest possible way. Call a sequence a **strong
divisibility sequence** if the greatest common divisor of two of its terms is
always the term at the greatest common divisor of the indices:

$$\gcd(u_m, u_n) = u_{\gcd(m, n)}.$$

This is a structural law. It says the sequence is a faithful "meaning-morphism"
of the arithmetic of divisibility: it carries the gcd operation on indices to the
gcd operation on values. A sequence obeying it automatically satisfies a striking
consequence — whenever an index $m$ divides an index $n$, the term $u_m$ divides
the term $u_n$:

$$m \mid n \ \Longrightarrow\ u_m \mid u_n.$$

Now, two famous sequences obey this same law. The first is the **Fibonacci
sequence** $1, 1, 2, 3, 5, 8, 13, \dots$, where each term is the sum of the two
before it. The second is the **Mersenne sequence** $u_n = 2^n - 1$, giving $1, 3,
7, 15, 31, \dots$. Both are strong divisibility sequences. Both therefore obey
the identical divisibility law: for Fibonacci, $F_m \mid F_n$ whenever $m \mid n$;
for Mersenne, $(2^m - 1) \mid (2^n - 1)$ whenever $m \mid n$. Their *structural
behavior is the same*.

And yet they are not the same sequence. At index $3$, Fibonacci gives $2$ while
Mersenne gives $2^3 - 1 = 7$. So

$$F \neq (n \mapsto 2^n - 1)$$

as functions, even though both satisfy — word for word — the same structural law
and the same divisibility implication. This is exactly the three-point collision
again, translated into arithmetic. The shared structural law is the *truth*; the
actual numerical values are the *meaning*; and the truth does not pin down the
meaning.

## The unifying idea

Strip away the specifics and one mechanism remains. In both stories there is an
acting isomorphism — a relabeling of a set, or an admissible transformation of a
number sequence. **Truth** is the part of an object that this isomorphism holds
fixed: its orbit of invariants (order, sign, support size, cycle type; the
gcd-preservation law). **Meaning** is the residual freedom the isomorphism leaves
untouched: which concrete points move, which concrete numbers appear.

An isomorphism of isomorphisms transports every truth *faithfully* — that is what
"isomorphism" guarantees — while remaining perfectly free to permute meaning.
Consequently, isomorphic structures can, and generically do, carry different
meanings that no invariant of the structure can ever detect. The smallest
example lives on three points; the same shape reappears among the deepest
sequences in number theory.

## Why it matters

There is a long tradition, from philosophy to the study of how minds recognize
analogies, of asking whether "same structure" means "same thing". Systems that
reason by analogy — spotting that one situation is *like* another — implicitly
bet that structure carries meaning across. The collision result is a precise
warning that the bet has a boundary. Two situations can share every structural
invariant and still differ in what they concretely do. Structure travels
perfectly; meaning does not always come along for the ride.

That boundary is not a failure. It is where the interesting mathematics lives.
The number of distinct meanings that share a single truth is, in the finite case,
exactly the size of a symmetry orbit — a quantity you can *count*. So the gap
between truth and meaning is not vague at all: it is a measurable, countable
thing, born from the freedom of isomorphisms to relabel the world while leaving
its structure intact. When structures collide, they do not break. They simply
reveal that being *the same* and being *identical* were never quite the same
question.
