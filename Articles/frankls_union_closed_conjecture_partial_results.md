# The Half-Full Glass: A Forty-Year-Old Puzzle About Combining Things

## A deceptively simple question

Imagine you run a club. The club is fussy about its committees. There is one
unbreakable rule: if committee $A$ exists and committee $B$ exists, then the
*merged* committee $A \cup B$ — the group you get by throwing everyone from both
committees into one room — must also be an official committee. Mathematicians
call a collection of sets obeying this rule **union-closed**.

Now here is the puzzle. Look across all the committees. Is there always some
single person who sits on at least *half* of them?

It feels like it must be true. The merging rule keeps pulling people together,
and once a popular person appears in a few committees, every merge tends to drag
them along into more. Surely *somebody* ends up on half the list.

This is **Frankl's union-closed sets conjecture**, posed by Péter Frankl in
1979. More than four decades later, despite enormous effort, nobody knows
whether it is true in general. It is one of those rare problems a curious child
can understand but the world's best combinatorialists cannot crack. In 2022 a
spectacular breakthrough by Justin Gilmer showed that *some* element always
appears in at least about 38% of the sets — a constant later pushed past
$1\!-\!\tfrac{1}{\varphi}\approx 0.382$ by several groups — but the clean,
intuitive **one-half** remains out of reach.

This article tells the story of the conjecture and walks through a cluster of
results that have been pinned down with complete certainty: a slick
counting trick that settles the easiest case, a full proof for tiny universes, a
hidden lattice lurking inside every union-closed family, and an exact "perfect
balance" identity at the heart of an information-theoretic attack.

## Saying it precisely

Let us fix the vocabulary, because the whole subject lives or dies on precision.

A **family** $F$ is just a finite collection of finite sets. The family is
**union-closed** if
$$A \cup B \in F \quad\text{whenever } A \in F \text{ and } B \in F.$$
An element $x$ is **abundant** in $F$ if it belongs to at least half of the
members:
$$2\cdot |\{A \in F : x \in A\}| \;\ge\; |F|.$$
Frankl's conjecture says: *every union-closed family that contains at least one
nonempty set has an abundant element.* (The nonempty caveat just rules out the
silly family $\{\varnothing\}$, which contains no elements at all.)

That's it. No calculus, no topology — just sets, unions, and counting. And yet.

## The one case everyone can prove: singletons

There is exactly one situation where the conjecture falls in a single line of
reasoning, and it is worth savoring because it reveals *why* the rest is hard.

Suppose your family happens to contain a **singleton** — a one-element set
$\{a\}$. Then $a$ is abundant. Here is the entire argument.

Split the family into two piles: the members that *contain* $a$, and the members
that *avoid* $a$. We want to show the "contains" pile is at least as big as the
"avoids" pile. So take any set $A$ that avoids $a$ and send it to
$$A \;\longmapsto\; A \cup \{a\}.$$
Because the family is union-closed and both $A$ and $\{a\}$ are members, the
result $A \cup \{a\}$ is again a member — and it obviously contains $a$. This map
is **injective**: if $A \cup \{a\} = B \cup \{a\}$ and neither $A$ nor $B$ had
$a$ to begin with, then $A = B$. So we have tucked every $a$-avoiding set neatly
inside the $a$-containing sets, one for one, with none colliding. The "contains"
pile wins. Element $a$ sits in at least half the family. Done.

This is the formalized result **`frankl_singleton`**, and the picture to keep in
mind is a perfect matching: each set without $a$ is paired with its partner that
has $a$ bolted on.

Why doesn't this finish the whole conjecture? Because *not every* union-closed
family contains a singleton. The moment the smallest set has two elements,
the trick breaks: the map $A \mapsto A \cup \{a,b\}$ can fold two different sets
onto the same image, and the clean one-for-one matching collapses. Worse, a
tempting fix — "the element in the smallest set is always abundant" — is simply
**false**. Sarvate and Renaud built explicit union-closed families whose
smallest set is a doubleton in which *neither* of its two elements is abundant.
That counterexample is a warning sign nailed to the door: there is no cheap local
shortcut. The conjecture has global teeth.

## Every union-closed family is secretly a lattice

Step back and look at a union-closed family not as a list but as a *structure*.
Order the members by inclusion: $A$ sits below $B$ if $A \subseteq B$. Because
any two members can be merged into a member, this ordered set has a beautiful
property — it is a **join-semilattice**, where "join" means union.

In fact something even tidier is true. Take a nonempty union-closed family and
merge *everything* together: form the grand union $U$ of all its members. Two
facts hold simultaneously.

1. $U$ is itself a member of the family.
2. Every member is contained in $U$.

In other words, $U$ is the unique **greatest element** — the top of the whole
structure. The first fact is not obvious: it says that even though $U$ is built
by unioning possibly many sets, union-closure (applied repeatedly) guarantees the
final result never escapes the family. This is the content of the formalized
lemmas **`sup_mem`** (the top belongs to the family) and **`sup_id_isGreatest`**
(it dominates everything).

Why care? Because it relocates the conjecture into the language of **lattice
theory**, one of the great organizing frameworks of algebra. A union-closed
family is not a random heap of sets; it is a finite lattice with a top element.
Frankl's conjecture then becomes a statement about the architecture of finite
lattices — about how "popularity" must concentrate somewhere in any structure
built by merging. That reframing is more than cosmetic: it lets one import tools
from order theory, and it suggests precise generalizations, such as whether the
top element's *join-irreducible lower covers* must lie below half the lattice.

## Settling the small cases completely

When a conjecture resists a general proof, mathematicians test it relentlessly on
small instances — both to hunt for counterexamples and to build intuition. For
union-closed families this has been pushed remarkably far: by combining clever
structural reductions with raw computation, the conjecture is now known to hold
whenever the family has at most **50** members (a result of Bošnjak and
Marković), and whenever the underlying universe is small.

Here we nail down, with total certainty, the case of a **three-element
universe**: a ground set with just three points, say $\{0, 1, 2\}$. There are
only $2^3 = 8$ possible subsets, and therefore $2^8 = 256$ possible families. One
might be tempted to simply check all $256$ by brute force, but that is both
inelegant and computationally awkward. Instead the proof uses the structure we
have already built.

Split into two clean cases.

- **The family contains a singleton.** Then we are instantly done by the matching
  argument `frankl_singleton`: the singleton's element is abundant.
- **The family contains no singleton.** This residual world is genuinely finite
  and small, and a careful exhaustive check confirms that an abundant element
  still always exists. This is the verified statement
  **`frankl_fin3_no_singleton`**.

Stitching the two cases together gives the theorem **`frankl_fin_three`**: *every
union-closed family on a three-element universe with a nonempty member has an
abundant element belonging to one of its sets.* The two-case split is the whole
point — it isolates the single place where union-closure does real work (the
singleton matching) from the part that is mere finite bookkeeping. A small Python
search confirms the same fact: of the $120$ union-closed families on three points
that contain a nonempty set, **every single one** has an abundant element, with
zero exceptions.

## Reimer's balance: information theory enters

The most surprising modern angle on Frankl's conjecture comes from **information
theory**. In 2003 David Reimer proved a theorem not about the most popular
element but about the *average size* of the sets in a union-closed family:
$$\text{average member size} \;\ge\; \tfrac{1}{2}\log_2 |F|.$$
Read that again. It says union-closed families cannot be made of tiny sets:
if you have many members, the typical member must be reasonably large. The proof
uses **entropy** — the same quantity that measures information content in data
compression — together with a deep combinatorial inequality of Shearer. It is
this entropic circle of ideas that Gilmer detonated in 2022 to get the first
constant-fraction bound on the conjecture itself.

A natural question for any inequality is: *when is it tight?* When does average
size exactly equal $\tfrac{1}{2}\log_2 |F|$, with not a hair to spare? The answer
is the most symmetric object imaginable: the **full Boolean cube**, the family of
*all* subsets of an $n$-element set. There you have $|F| = 2^n$ members, so
$\tfrac12 \log_2 |F| = n/2$, and the claim is that the average subset of an
$n$-set has size exactly $n/2$.

And this — the exact equality case — can be proven without a single logarithm or
shred of entropy, by an old and gorgeous trick called **double counting**. Ask:
across all $2^n$ subsets of $\{1,\dots,n\}$, what is the total number of
elements, summed over every subset? Count it two ways.

- **By subsets:** it is $\sum_{A} |A|$, the thing we want.
- **By points:** fix a point, say point $1$. In how many subsets does it appear?
  Exactly half of them — $2^{n-1}$ — because the other $n-1$ points are free to be
  in or out. The same holds for every point. So the grand total is
  $n \cdot 2^{n-1}$.

Equating the two counts gives the clean identity
$$\sum_{A \subseteq \{1,\dots,n\}} |A| \;=\; n \cdot 2^{n-1},$$
verified as **`sum_card_powerset`**. Combined with the obvious count
$|F| = 2^n$ (the lemma **`card_powerset_univ`**), it yields the headline
**`reimer_tight_cube`**:
$$2 \cdot \sum_{A \subseteq \{1,\dots,n\}} |A| \;=\; n \cdot 2^{\,n},$$
an equality of plain whole numbers. Divide through: the average size is exactly
$n/2 = \tfrac12 \log_2(2^n)$. Reimer's inequality is tight, and the Boolean cube
is the witness — proven exactly, integer to integer, no rounding, no analysis.

The little numerical table tells the story at a glance: for $n = 0,1,2,\dots,7$
the quantity $2\sum_A |A|$ marches $0, 2, 8, 24, 64, 160, 384, 896$, matching
$n\cdot 2^n$ every time, and the average sizes are precisely
$0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5$.

## Why the equality case matters

It might seem modest to prove only when an inequality is *tight*, rather than the
inequality itself. But equality cases are the skeleton keys of mathematics.
Knowing exactly which object saturates a bound tells you what an optimal proof
must "feel," and it supplies the certificate you need to later prove the full
inequality *with* its characterization of extremes. The double-counting identity
here is, in a precise sense, what an entropy proof of Reimer's theorem
reproduces in the limit — the asymptotic shadow of an exact combinatorial fact.
Pinning down the shadow's source is real progress.

## The state of play

So where does this leave the grand conjecture? Honestly: still open, still
tantalizing. What we have are firm footholds.

- **Singletons** are completely understood: a one-element member forces
  abundance, via a perfect matching (`frankl_singleton`).
- **Structure** is in hand: every union-closed family is a finite lattice with a
  guaranteed top element (`sup_mem`, `sup_id_isGreatest`), recasting the
  conjecture in the language of order theory.
- **Small worlds** are conquered: the three-element universe is fully verified
  (`frankl_fin_three`), and the conjecture is known up to families of size 50.
- **The entropic frontier** has its equality case nailed: the Boolean cube
  exactly saturates Reimer's average-size bound (`reimer_tight_cube`).

Each result is a different face of the same gem. The matching argument is
combinatorial; the lattice is algebraic; the small-universe proof is partly
computational; the cube identity is information-theoretic. That a problem so
plainly stated should reach into matchings, lattices, computation, and entropy is
exactly why it has captivated mathematicians for two generations.

The glass, we strongly suspect, is always at least half full — there is always
someone on half the committees. Proving it remains one of the most charming
unsolved challenges in all of combinatorics. The footholds above are where the
next climber will plant their feet.
