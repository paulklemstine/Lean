# Counting Without Counting: How Symmetry Turns Factorials into Geometry

## The mystery of the dividing factorial

Open any book on combinatorics — the mathematics of counting — and you will quickly meet two
ways of packaging an infinite list of numbers into a single object. The first is the
*ordinary generating function*: given a sequence of counts $a_0, a_1, a_2, \dots$, you write
the formal series

$$ a_0 + a_1 X + a_2 X^2 + a_3 X^3 + \cdots $$

The second, used whenever the things being counted carry *labels*, is the *exponential
generating function* (EGF):

$$ a_0 + a_1 X + \frac{a_2}{2!} X^2 + \frac{a_3}{3!} X^3 + \cdots
   \;=\; \sum_{n \ge 0} \frac{a_n}{n!} X^n. $$

The strange thing is the division by $n!$. Why, when counting labelled structures, do we
divide each count by the number of ways to permute the labels? Generations of students have
been told that the factorials are there "to make the algebra work out" — that they are a
bookkeeping convenience, a normalization that makes products of series behave well. The honest
answer, the one this article is about, is far more beautiful: **the factorial is not a
normalization. It is a measurement of symmetry, and the EGF is secretly counting structures in
a richer world where symmetric objects count for less than rigid ones.**

This is the idea of *homotopy cardinality*, and it transforms the EGF from an algebraic trick
into a geometric statement. By the end of this article you will see exactly why the number
$e^x = \sum_n x^n/n!$ is the generating function for sets, why $1/(1-x)$ is the generating
function for orderings, and why these two facts are really statements about how much symmetry
those objects possess.

## Structures, labels, and the act of relabelling

Let us be concrete. A *combinatorial species* is, informally, a rule $F$ that takes a finite
set of labels — say the labels $\{1, 2, \dots, n\}$ — and produces a finite set $F[n]$ of
"structures" built on those labels. The examples to keep in mind:

- The **species of sets**, written $E$. On any label set there is exactly *one* structure: the
  set itself, with no extra decoration. So $E[n]$ has exactly one element, for every $n$.
- The **species of linear orders**, written $L$. A structure here is a way of lining the labels
  up in a row, first to last. There are $n!$ such arrangements of $n$ labels, so $L[n]$ has
  $n!$ elements.

The crucial extra ingredient — the thing that makes a species more than just a sequence of
numbers — is that you can *relabel*. If you have a structure on the labels $\{1,2,3\}$ and you
permute those labels (say swap $1$ and $2$), you get another structure of the same kind. So the
symmetric group $S_n$, the group of all $n!$ permutations of $n$ labels, *acts* on the set
$F[n]$. Mathematically this is recorded as a homomorphism

$$ S_n \longrightarrow \mathrm{Perm}(F[n]), $$

sending each relabelling of the inputs to the corresponding shuffle of the structures. This
action is the soul of the theory. It is what we will measure.

In the formalization underlying this article, a species is exactly this data: a family of
finite types $\mathrm{obj}(n) = F[n]$, each one finite, together with a group homomorphism
$\mathrm{act}(n) : S_n \to \mathrm{Perm}(F[n])$ encoding relabelling.

## When are two structures "the same"?

Here is the conceptual fork in the road. Suppose I hand you two structures on the labels
$\{1,2,3\}$. When should we regard them as the same?

- A **strict** combinatorialist says: only if they are literally equal.
- A **symmetry-aware** combinatorialist says: if one can be turned into the other by relabelling
  — that is, if they lie in the same *orbit* of the $S_n$ action.

The second viewpoint groups the structures into *isomorphism classes* (orbits). But it does
something subtler too. When you forget the distinction between relabelled copies, you must keep
track of *how much symmetry was lost in the forgetting*. A structure that is fixed by many
relabellings — that has a large *symmetry group*, or *stabilizer* — is a "fat" point in the
quotient; a structure with no symmetry at all is a "thin", rigid point.

The object that remembers both the orbits *and* their symmetries is called the **action
groupoid**, written

$$ F[n] /\!\!/ S_n. $$

You can picture it as the set of structures, with the orbits as its connected components, but
where each component is "weighted" by the symmetry of its members. The right way to measure the
*size* of such a weighted object is not to count its points, but to compute its **homotopy
cardinality**.

## Homotopy cardinality: counting where symmetry costs you

The homotopy cardinality of a finite groupoid is a single rational number defined by

$$ |\mathcal{G}| \;=\; \sum_{[x]} \frac{1}{|\mathrm{Aut}(x)|}, $$

a sum over isomorphism classes (one representative $x$ each) of the reciprocal of the size of
the automorphism group of $x$. The slogan is: **a point with $k$ symmetries counts as $1/k$ of
a point.** A perfectly rigid object, with only the trivial symmetry, counts as a full point. An
object fixed by a group of $1000$ relabellings counts as a thousandth of a point.

This may look exotic, but it is precisely the right notion in countless settings — from the
mass formula for quadratic forms, to the Euler characteristics of moduli spaces ("stacks") in
geometry, to the partition functions of physics where states are weighted by the inverse of
their gauge symmetry. The number $1/|\mathrm{Aut}|$ is the universal "symmetry discount."

Now we can state the first main theorem, the bridge between this homotopy-theoretic counting
and ordinary division. For a finite group $G$ acting on a finite set $X$, the action groupoid
$X /\!\!/ G$ has a wonderfully simple homotopy cardinality:

> **Theorem (Homotopy cardinality of an action groupoid).** For a finite group $G$ acting on a
> finite set $X$,
> $$ \big| X /\!\!/ G \big| \;=\; \sum_{\text{orbits } \omega} \frac{1}{|\mathrm{Stab}(\omega)|}
>    \;=\; \frac{|X|}{|G|}. $$

Read that twice. The left-hand side is the subtle, symmetry-weighted sum over isomorphism
classes. The right-hand side is the naïve ratio of the size of $X$ to the size of $G$ — the kind
of "average" you might write down without thinking about it. The theorem says they are
*equal*. This is the homotopy-theoretic upgrade of one of the first theorems anyone learns in
group theory, the **orbit–stabilizer theorem**, which states that for any structure $x$,

$$ |\text{orbit of } x| \times |\mathrm{Stab}(x)| = |G|. $$

Dividing through, each orbit contributes $1/|\mathrm{Stab}| = |\text{orbit}|/|G|$, and summing
the orbit sizes simply rebuilds the whole set $X$. The symmetry discounts conspire, orbit by
orbit, to reassemble the clean fraction $|X|/|G|$.

## The factorial, unmasked

Apply this to a species. Take the relabelling action of $S_n$ — which has exactly $n!$ elements
— on the structure set $F[n]$. The theorem instantly gives

> **Theorem (Action-groupoid cardinality of a species).**
> $$ \big| F[n] /\!\!/ S_n \big| \;=\; \frac{|F[n]|}{n!}. $$

And there it is — the dividing factorial of the exponential generating function, standing
revealed. The expression $|F[n]|/n!$, the $n$-th coefficient of the EGF, is *not* a normalized
count. It is the **homotopy cardinality of the groupoid of $F$-structures up to relabelling**.
Combining this with the definition of the EGF yields the central identity of the whole program:

> **Theorem (The EGF is the homotopy-cardinality generating function).** For every species $F$,
> the $n$-th coefficient of its exponential generating function equals the homotopy cardinality
> of the action groupoid:
> $$ [X^n]\, \mathrm{EGF}(F) \;=\; \frac{|F[n]|}{n!} \;=\; \big| F[n] /\!\!/ S_n \big|. $$

The $1/n!$ is the reciprocal order of the symmetry group being quotiented out. The exponential
generating function is, coefficient by coefficient, *counting structures in the symmetry-aware
world* — weighting each isomorphism class by the inverse of its symmetry. The factorials were
never bookkeeping. They were geometry all along.

## Two famous series, two faces of symmetry

The payoff is two of the most familiar generating functions in mathematics, each now carrying a
crisp homotopy-theoretic meaning.

**The species of sets and the number $e$.** Recall that $E[n]$ has exactly one structure. The
relabelling group $S_n$ shuffles that single structure trivially — it cannot move the one point
anywhere, so *every* one of the $n!$ permutations fixes it. The lone isomorphism class has the
*entire* symmetric group as its automorphism group. Its symmetry discount is therefore $1/n!$,
and

$$ \big| E[n] /\!\!/ S_n \big| = \frac{1}{n!}. $$

Summing these over all $n$ gives $\sum_n X^n/n!$ — the power series for the exponential function
$e^X$. So the equation "the species of sets has EGF $e^X$" becomes the statement: **a set is a
maximally symmetric object; it has the full symmetric group as its automorphisms, and so it
counts for only $1/n!$ of a point.** That tiny weight, summed up, is the exponential.

**The species of linear orders and the geometric series.** Now $L[n]$ has $n!$ structures — all
the ways to line the labels up. Relabelling acts on these orderings, and here something special
happens: the action is *free and transitive*. Any ordering can be turned into any other by a
unique relabelling. In the language of symmetry, $L[n]$ is a **torsor** for $S_n$: it looks
exactly like the group itself, but with no preferred starting point. There is a single orbit
(all orderings are isomorphic), and the symmetry group of any one ordering is *trivial* — only
the identity relabelling fixes a given arrangement. So

$$ \big| L[n] /\!\!/ S_n \big| = \frac{n!}{n!} = 1. $$

Each $n$ contributes a clean $1$, giving $\sum_n X^n = 1/(1-X)$, the geometric series. The
homotopy meaning: **an ordering is a perfectly rigid object — it has no symmetry, so it counts
as a full point.** The torsor's homotopy quotient is "contractible," a single honest point, for
every $n$. That is why orderings are counted by the simplest series of all.

Set this pair side by side and the whole philosophy snaps into focus. Sets and orderings have
the *same number* of underlying labels but live at opposite extremes of symmetry: the set is
maximally symmetric (discount $1/n!$, giving $e^X$), the ordering is maximally rigid (discount
$1$, giving $1/(1-X)$). The exponential and the geometric series — two of the most important
functions in all of mathematics — are the two poles of a single symmetry spectrum.

## Why this matters beyond the bookkeeping

It is tempting to dismiss this as a pretty re-interpretation of something we already knew. But
reframings like this are how mathematics makes progress, because they tell you *which
generalizations are natural*.

Once you see the EGF as a homotopy cardinality, the algebraic laws of generating functions stop
looking like coincidences. Adding two species (a disjoint choice between an $F$-structure and a
$G$-structure) adds their EGFs — because homotopy cardinality is additive over disjoint unions
of groupoids. Multiplying two EGFs corresponds to the *product* of species (splitting the labels
into two groups, putting an $F$-structure on one and a $G$-structure on the other) — because
homotopy cardinality is *multiplicative* over products of groupoids. The exponential generating
function is, in this light, a **symmetric monoidal functor** from the world of finite groupoids
to the rational numbers: it converts the categorical operations of "combine independently" and
"choose between" into ordinary multiplication and addition. The companion formalizations make
this precise, showing the EGF is in fact a ring isomorphism from counting sequences (under
binomial convolution) to formal power series.

The same circle of ideas reaches far outside enumerative combinatorics:

- In **algebraic geometry**, spaces with symmetry (orbifolds and stacks) are measured by exactly
  this kind of weighted Euler characteristic; moduli problems are routinely counted "up to
  automorphism."
- In **physics**, the partition functions of gauge theories weight field configurations by the
  inverse order of their symmetry group — the same $1/|\mathrm{Aut}|$ factor, where it is called
  dividing by the gauge volume.
- In **number theory**, the Smith–Minkowski–Siegel mass formula counts lattices weighted by the
  reciprocal of their automorphism groups, a homotopy cardinality in disguise.

In every one of these, the principle is the same one we extracted from the humble exponential
generating function: *symmetric things should count for less.* The reciprocal of the symmetry
group is the universal currency of "how much" a structure contributes.

## A single picture to carry away

If you remember one thing, let it be this chain of equalities, true for every labelled
structure $F$:

$$ \underbrace{\frac{a_n}{n!}}_{\text{the EGF coefficient}}
   \;=\; \underbrace{\frac{|F[n]|}{n!}}_{\text{structures per relabelling}}
   \;=\; \underbrace{\sum_{[x]} \frac{1}{|\mathrm{Aut}(x)|}}_{\text{symmetry-weighted count}}
   \;=\; \big| F[n] /\!\!/ S_n \big|. $$

The first expression is what every calculus student computes mechanically. The last is a piece
of homotopy theory: the size of a space of structures where symmetry is a measurable, and where
symmetric objects are gracefully discounted. They are the same number. The factorial in the
denominator of $e^x$ was never an accident of algebra — it was symmetry, all along, asking to be
seen.
