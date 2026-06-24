# When Doubling a Network Doesn't Create New Symmetries

## A puzzle about mirrors

Imagine you build a model of a molecule, a circuit, or a social network out of
beads and string. The *symmetries* of that model are all the ways you can pick it
up, shuffle the beads around, and set it back down so that it looks exactly as it
did before — every string still connects the same pair of beads. Mathematicians
call the collection of all such symmetries the **automorphism group** of the
network. It is one of the most informative fingerprints a network has: highly
symmetric networks behave very differently from lopsided ones, and the size of
the symmetry group controls everything from how fast information mixes across the
network to how hard it is to tell two networks apart.

Now play a simple game. Take your network and make *two copies* of it — a "top"
copy and a "bottom" copy. Then rewire: erase every connection inside each copy,
and instead connect a top bead to a bottom bead exactly when the two
corresponding beads were connected in the original. You have built what is called
the **bipartite double cover**, or equivalently the *tensor product with $K_2$*,
where $K_2$ is the simplest possible two-vertex graph: just two points joined by
an edge.

Here is the puzzle. The doubled network obviously inherits all the symmetries of
the original — whatever you could do to the single copy, you can do
simultaneously to both copies. And it has one brand-new symmetry that the
original never had: you can *swap the top and bottom copies wholesale*. So the
doubled network always has at least twice as many symmetries as the original.

The question that has occupied graph theorists for years is whether it can ever
have *more* than that. When the doubled network's symmetries are **exactly** the
old ones plus the single top–bottom swap — no surprises, no extra hidden
shuffles — the original network is called **stable**. When new, unexpected
symmetries appear out of nowhere, the network is **unstable**. Stability is the
statement that doubling is "honest": it doesn't smuggle in symmetry you didn't
ask for.

This article is about a clean, fully rigorous account of stability for a
beautiful and important family of networks — the **Cayley digraphs of abelian
groups** — and about exactly *why* one innocent-looking condition, that the group
has **odd order**, turns out to be the hinge on which everything swings.

## Networks built from arithmetic

The networks we care about are not random tangles of string. They are built from
*groups*, the algebraic objects that encode symmetry and addition.

Take any finite commutative ("abelian") group $G$ — think of the integers modulo
$n$, written $\mathbb{Z}/n$, where you add and wrap around like the hours on a
clock. Choose a set $S$ of "allowed steps" inside $G$, called the **connection
set**. Now build a directed network, the **Cayley digraph** $\mathrm{Cay}(G,S)$,
as follows: the beads are the elements of $G$, and you draw an arrow from $g$ to
$h$ precisely when the step from $g$ to $h$ is allowed — that is, when

$$h - g \in S.$$

In the formal development this adjacency rule is the definition `cayAdj`: there
is an arc $g \to h$ exactly when $h - g \in S$.

A tiny example: let $G = \mathbb{Z}/5$ (the numbers $0,1,2,3,4$ with clock
arithmetic) and let the allowed step be "add 1," so $S = \{1\}$. Then the
arrows are $0 \to 1 \to 2 \to 3 \to 4 \to 0$: a single directed pentagon, a
five-hour clock. Cayley digraphs are everywhere — they are the abstract
backbone of cyclic codes, the wiring diagrams of efficient parallel computers,
and the natural picture of "addition as motion."

When we double a Cayley digraph, the result lives on pairs $(g, a)$, where $g$
is an element of the group and $a$ is one of two labels — "top" or "bottom,"
which we model as the two Boolean values `true` and `false`. The doubled
adjacency rule, called `dcAdj`, says there is an arrow from $(g,a)$ to $(h,b)$
exactly when

$$h - g \in S \quad\text{and}\quad a \neq b.$$

The first clause is the original Cayley rule; the second clause, $a \neq b$,
forces every arrow to cross between the two copies — that is what makes the
construction the *bipartite* double cover.

## What a symmetry really is

To make the puzzle precise we need to say what a symmetry of a directed network
*is*. It is a way of relabelling the beads — formally a permutation $\sigma$ of
the vertex set — that preserves every arrow and every non-arrow. In symbols, for
all vertices $a$ and $b$,

$$\text{there is an arc } \sigma(a) \to \sigma(b) \iff \text{there is an arc } a \to b.$$

The set of all such relabellings forms a group: you can undo a symmetry, and you
can compose two symmetries to get a third. In the formal development this is
captured by `AutRel`, which takes any adjacency relation and returns the group of
all permutations that preserve it, sitting inside the group of *all* permutations
of the vertices.

The two-vertex graph $K_2$ has exactly two symmetries: leave the points alone, or
swap them. So the symmetries of $K_2$ are the permutations of a two-element set —
there are precisely two of them. These are the "top–bottom swaps" we met earlier.

## The expected symmetries always fit

Now we can state the heart of the matter. Given a symmetry $\sigma$ of the
original Cayley digraph and a symmetry $\pi$ of $K_2$ (either "keep" or "swap"),
we can build a symmetry of the doubled network in the obvious way: apply $\sigma$
to the group coordinate and $\pi$ to the top/bottom label, independently. This
combined relabelling is the **product permutation**, and the recipe
$(\sigma, \pi) \mapsto \sigma \times \pi$ is a group homomorphism called
`expectedHom` — it packages up *all* the symmetries we already knew the doubled
network must have.

The first rigorous result is that this recipe really does land inside the
symmetry group of the doubled network. This is the lemma `prodCongr_mem`:

> **Product symmetries are genuine.** If $\sigma$ is a symmetry of
> $\mathrm{Cay}(G,S)$ and $\pi$ is *any* permutation of the two layers, then the
> product permutation $\sigma \times \pi$ is a symmetry of the doubled network.

Notice how cheap this is: the layer permutation $\pi$ is allowed to be *anything*;
no special structure of the group is needed.

The first main theorem is that this packaging is **lossless** — different
expected symmetries always give different symmetries of the double cover. This is
`expectedHom_injective`:

> **Main theorem (the expected symmetries always embed).** For *every* finite
> abelian group $G$ and *every* connection set $S$, the map `expectedHom` is
> injective. Distinct pairs $(\sigma,\pi)$ produce distinct symmetries
> $\sigma \times \pi$ of the doubled network.

The proof is a small gem of "evaluate at the right place." Suppose two pairs
$(\sigma, \pi)$ and $(\sigma', \pi')$ produce the same doubled symmetry. Feed the
doubled symmetry the vertex $(g, \text{bottom})$: the group coordinate of the
output reveals $\sigma(g) = \sigma'(g)$, and since $g$ was arbitrary, $\sigma =
\sigma'$. Then feed it $(0, b)$, where $0$ is the group's identity element: the
label coordinate of the output reveals $\pi(b) = \pi'(b)$, so $\pi = \pi'$. The
only subtlety — quietly important — is that we needed an actual vertex to plug
in, the identity $0$, in order to *see* the layer permutation at all. With no base
point, the top/bottom information would be invisible.

What this theorem buys us is a hard, universal lower bound: **the doubled network
always has at least twice as many symmetries as the original.** Stability is the
assertion that this lower bound is also an upper bound — that there is nothing
else. Injectivity is the easy, always-true half; the hard half is to rule out
surprises.

## The double of a Cayley network is still a Cayley network

Before tackling the hard half, there is a structural surprise that makes the
whole theory tractable. You might expect that doubling takes you outside the
world of Cayley digraphs into some wilder species. It does not.

The doubled network is *itself* a Cayley digraph — over a slightly bigger group.
Specifically, glue a two-element group $\mathbb{Z}/2$ onto $G$ to form the
product group $G \times \mathbb{Z}/2$, and use the connection set consisting of
all pairs $(s, 1)$ with $s \in S$ — in the formal development this set is
`dcConn`. Then:

> **Structural theorem (the double cover is Cayley).** The doubled network of
> $\mathrm{Cay}(G,S)$ is isomorphic to the Cayley digraph of $G \times
> \mathbb{Z}/2$ with connection set $\{(s,1) : s \in S\}$.

This is the content of `dcCayleyIso`. The isomorphism is almost embarrassingly
simple: keep the group coordinate untouched and translate the Boolean label into
$\mathbb{Z}/2$ by sending "bottom" to $0$ and "top" to $1$ (the dictionary
`boolEquivZMod2`). Under this dictionary, "the labels differ" becomes "the
$\mathbb{Z}/2$ coordinates differ by $1$," which is exactly the condition built
into the new connection set.

Why does this matter? Because it says the doubling operation is a *closed* one:
it never escapes the class of abelian Cayley digraphs. You can double, and double
again, and stay in the same well-understood universe — which opens the door to
inductive and structural attacks on the open problems, and to direct computer
verification on small groups.

## Why "odd order" is the secret ingredient

Now to the deepest part of the story: a precise reason that odd-sized groups
behave so much better than even-sized ones.

A doubled network could, in principle, have an extra "diagonal" symmetry — one
that mixes the two layers in a *position-dependent* way, swapping top and bottom
for some beads but not others, rather than swapping all of them at once. Such a
rogue symmetry is exactly what stability forbids. The crucial observation is that
manufacturing one of these layer-mixing symmetries requires the group to contain
an **involution**: a nonzero element $g$ that is its own negative, i.e. that
satisfies

$$g + g = 0, \qquad g \neq 0.$$

In the clock group $\mathbb{Z}/6$, for instance, the element $3$ is an
involution, because $3 + 3 = 6 = 0$. Involutions are precisely the elements of
order two, and they are the raw material from which the unwanted, instability-
causing symmetries are forged.

Here is the punchline, the lemma `odd_no_involution`:

> **Odd groups have no involutions.** In a finite abelian group whose number of
> elements is odd, the only solution of $g + g = 0$ is $g = 0$.

The reason is a one-line consequence of Lagrange's theorem from group theory: in
a group with an odd number of elements, no element can have order two, because an
order-two element would generate a two-element subgroup, and the size of a
subgroup must divide the size of the whole group — but $2$ does not divide an odd
number. No involutions means no raw material for a diagonal symmetry, and that is
exactly why odd order is the natural home of stability.

The same lemma reveals why odd order genuinely **cannot be dropped**. In an
even-order group, an involution exists, and from it one can write down an
explicit rogue symmetry of the doubled network — a single transposition,
`tau` in the formal development, that mixes the layers and is not one of the
expected symmetries. That explicit witness *disproves* stability for the
even-order case, showing the odd hypothesis is not a convenience but a necessity.

There is one more ingredient the full conjecture needs, beyond odd order:
**twin-freeness**. Two vertices are *twins* if they have exactly the same set of
neighbours; a network with twins has obvious extra symmetries (swap the twins)
that can leak into the double cover and break stability for reasons having
nothing to do with the group. So the clean statement excludes them. The formal
development names this hypothesis `TwinFree`.

## The conjecture, stated honestly

Putting the pieces together, the conjecture at the centre of this circle of ideas
— due to Hujdurović, Mitrović, and Morris — reads:

> **Every connected, twin-free Cayley digraph of a finite abelian group of odd
> order is stable.** Equivalently, for such networks the embedding of expected
> symmetries, `expectedHom`, is not merely injective but *onto* — every symmetry
> of the doubled network is one of the expected ones.

It is worth being scrupulous about what is settled and what is open. The easy,
universal half — that the expected symmetries always embed faithfully — is fully
established (`expectedHom_injective`), giving the guaranteed factor-of-two. The
structural reduction that keeps doubling inside the Cayley world is established
(`dcCayleyIso`). The arithmetic obstruction is pinned down exactly:
odd-order groups have no involutions (`odd_no_involution`), and even-order groups
have an explicit instability witness. What remains open is the *surjectivity* —
the combinatorial heart that says no other symmetry can exist. That is the hard
half, and it is genuinely unsolved.

## Why anyone should care

Stability is not a curiosity confined to graph theory. The bipartite double cover
is one of the most-used constructions across mathematics and its applications. In
**coding theory**, doubling a Cayley graph of a cyclic group is a way of building
new codes from old, and the symmetry group governs the code's error-correcting
behaviour; stability tells you the new code has no accidental symmetries that
would weaken it. In **the study of expander graphs and random walks** — the
networks behind fast mixing, randomized algorithms, and robust communication —
the automorphism group constrains the spectrum, and knowing it is exactly twice
as big after doubling pins down how the doubled walk behaves. In the
**graph isomorphism problem**, stable graphs are precisely the ones for which the
double cover gives away no extra information, a fact used to calibrate algorithms
that test whether two networks are secretly the same.

Underneath all of these is a single, satisfying idea: *doubling should be
honest.* When you build two coupled copies of a structured system, the only new
symmetry should be the obvious one — swap the copies. The theorems here make that
intuition exact for arithmetic networks, show precisely which numbers (the odd
ones) make it true, and show with an explicit counterexample which numbers (the
even ones) make it fail. The phrase "odd is stable, even is suspect" turns out to
be not a slogan but a theorem-in-waiting, already half proved and resting on a
fact a child could check: you cannot split an odd number of things into pairs.
