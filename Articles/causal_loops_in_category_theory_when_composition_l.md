# When Composition Loops Back: The Secret Life of Parentheses

## A rule everyone breaks

Ask anyone who has survived a grade-school arithmetic class, and they will tell you that
$(2 \times 3) \times 5$ and $2 \times (3 \times 5)$ are "the same thing." Both equal $30$.
The parentheses, we are taught, don't matter. This is the **associative law**, and it is
so deeply woven into our intuition that we barely notice it. We write $2 \times 3 \times 5$
without a second thought, trusting that no matter how we group the multiplications, we land
in the same place.

But look more carefully. $(2 \times 3) \times 5$ and $2 \times (3 \times 5)$ describe two
*different procedures*. In the first, you multiply $2$ and $3$ first, then scale by $5$. In
the second, you multiply $3$ and $5$ first, then scale by $2$. The final *number* is the
same — but the *recipe* is not. The associative law is a statement that two genuinely
different computations happen to agree on their output.

What if we refuse to sweep that difference under the rug? What if we insist on keeping
track of *how* things were grouped — treating $(a \cdot b) \cdot c$ and $a \cdot (b \cdot c)$
as distinct objects, connected not by an equals sign but by a reversible *transformation*
that says "you may re-bracket freely, and here is the canonical way to do it"?

This is not idle philosophy. It is the doorway into one of the most powerful ideas in
modern mathematics: the theory of **higher categories**, where equations are upgraded to
*isomorphisms*, and the crucial question becomes not "are these equal?" but "are the ways
of proving them equal, themselves consistent?" This article tells the story of a small,
completely explicit world — a world built out of nothing but parentheses — that captures
the whole phenomenon in miniature.

## Parentheses as objects

Let us fix an alphabet of symbols; call them letters $a, b, c, \dots$. A **parenthesization**
is any way of forming a product from a string of these letters by inserting a full set of
nested brackets. From the two letters $a, b$ we can build only $(a \cdot b)$. From three
letters $a, b, c$ we can build exactly two:
$$
(a \cdot b) \cdot c \qquad\text{and}\qquad a \cdot (b \cdot c).
$$
From four letters we can build five; from five, fourteen; in general the number of
parenthesizations of $n+1$ letters is the famous $n$-th **Catalan number**. These objects
are naturally pictured as **binary trees**: a parenthesization is a rooted tree whose
leaves, read left to right, spell out the underlying word, and whose internal branchings
record each multiplication. The letter-string with the brackets stripped away — the
sequence of leaves — we call the **underlying word**. The map that sends a tree to its
underlying word is the act of *forgetting how you grouped*; we call it **flattening**.

Two trees can flatten to the same word while looking completely different:
$(a \cdot b) \cdot c$ and $a \cdot (b \cdot c)$ both flatten to $abc$. This is the whole
point. We will build a mathematical universe in which these two trees are *distinct
inhabitants* — not equal — yet joined by a canonical, reversible bridge.

## A universe with reversible bridges

Here is the universe, stated precisely. Its **objects** are the parenthesization trees.
Between two trees $s$ and $t$ we declare that there is a **transformation** (a "morphism,"
in the language of category theory) precisely when $s$ and $t$ flatten to the *same word* —
and when there is such a transformation, there is exactly *one*. In symbols, a morphism
$s \to t$ is nothing more than a witness to the equation
$$
\text{flatten}(s) = \text{flatten}(t).
$$
You may compose transformations by chaining equalities (if $s$ and $t$ share a word, and
$t$ and $u$ share a word, then so do $s$ and $u$), and every object has an identity
transformation to itself (every word equals itself). This makes our universe a bona fide
**category**.

It has two striking features. First, it is **thin**: between any two objects there is *at
most one* transformation. There is never any ambiguity about *how* to re-bracket — only
about *whether* you can. Second, it is a **groupoid**: every transformation is reversible.
If you can re-bracket $s$ into $t$, you can always re-bracket back. Together these say
something vivid — the collection of all bracketings of a given word forms a perfectly
rigid web in which any two nodes are joined by a unique two-way bridge. This web is the
concrete face of what one might call a *causal loop*: composition that circles around and
returns, always, to where it began.

## Multiplication that fails — on purpose

Now we install a product on this universe. Given two trees $s$ and $t$, their **tensor
product** $s \otimes t$ is simply the tree that grafts $s$ and $t$ under a common root — in
symbols, the formal bracketing $(s \cdot t)$. The empty tree serves as the **unit**: tensoring
with it changes nothing about the underlying word.

And here comes the crucial, deliberate failure. Consider three trees $a, b, c$. Form
$(a \otimes b) \otimes c$ and $a \otimes (b \otimes c)$. As *trees*, these are genuinely
different objects — one branches left at the top, the other branches right. They are **not
equal**. A short structural argument confirms it: if they were the same tree, one of them
would have to contain itself as a proper subtree, which is impossible for a finite tree.
This is our headline result:

> **Associativity fails on the nose.** For any trees $a, b, c$, the two bracketings
> $(a \otimes b) \otimes c$ and $a \otimes (b \otimes c)$ are distinct objects. In
> particular, the product on parenthesization trees is *not* strictly associative.

Yet — and this is the whole magic — the two objects flatten to the *same word*,
$\text{flatten}(a)\,\text{flatten}(b)\,\text{flatten}(c)$, because concatenating lists is
associative even when bracketing trees is not. So there is a unique reversible bridge
between them:

> **The associator.** There is a canonical isomorphism
> $$
> \alpha_{a,b,c}\colon (a \otimes b) \otimes c \;\xrightarrow{\;\cong\;}\; a \otimes (b \otimes c),
> $$
> and it is the *unique* isomorphism between these two objects.

The product is not associative, but its failure is *controlled*: repaired everywhere by a
canonical, invertible transformation. This is exactly the structure that category theorists
call a **monoidal category** — a product that is associative "up to coherent isomorphism"
rather than on the nose.

## Coherence, and why here it is free

The moment you replace an *equation* with an *isomorphism*, a new danger appears. With four
factors $w, x, y, z$ there are five ways to fully bracket the product, and you can travel
between them along the associator in more than one way. Mac Lane's celebrated **pentagon
identity** demands that the two natural routes around the pentagon of five bracketings
*agree*. A companion **triangle identity** governs how the unit interacts with the associator.
Without these coherence conditions, the "up to isomorphism" freedom would collapse into
chaos: different re-bracketings would give incompatible answers.

Proving coherence is, in general, hard work. But in our universe it is **free**, and the
reason is beautiful. Our category is *thin*: there is at most one transformation between any
two objects. So *any diagram whatsoever commutes* — if two composite transformations have
the same source and target, they are automatically equal, because there is only one
transformation to be. The pentagon holds because both sides are transformations between the
same pair of objects, and there is only one such transformation. The same is true of the
triangle, and of every naturality condition one could ask for.

> **Coherence from thinness.** On any thin category, *any* choice of product-and-associator
> data automatically satisfies the pentagon, the triangle, and all naturality laws. It is a
> genuine monoidal category, for free.

This is the abstract heart of the story: *rigidity guarantees coherence*. When the
transformations recording "how composition loops back" are so constrained that each is
unique, no inconsistency can ever creep in. The causal loop — travel out along the long
route around the pentagon, return along the short one — closes exactly to the identity. When
composition loops back, it loops back to precisely where it started.

## Collapsing the tower

We have built an elaborate structure: infinitely many objects (one per bracketing), all
knitted together by canonical bridges. What is it *really*? Here coherence pays its final
dividend. Pick, for each word, a single preferred bracketing — say the fully **right-nested**
one, $a \cdot (b \cdot (c \cdots))$, a canonical *normal form*. Then:

> **Every bracketing is uniquely isomorphic to its normal form**, and two bracketings are
> isomorphic **if and only if** they have the same underlying word. The isomorphism class of
> a tree remembers *only* its word — never how it was grouped.

Flattening, it turns out, is not just a map on objects but a structure-preserving functor
onto the **discrete** world of plain words, where the only transformations are identities.
Under this functor the associator — that carefully constructed repair of associativity —
is squashed down to a trivial identity. And the two universes are **equivalent**: the
whole non-strict tower of bracketings and bridges is, up to equivalence, nothing more than
the flat, strict world of words under concatenation.

> **Strictification.** The parenthesization category is equivalent to the discrete category
> of words. The non-strict structure — objects for every bracketing, an associator loop
> binding them — can be replaced, without loss, by a strict, loop-free one.

This is a hands-on incarnation of one of the deepest theorems about monoidal categories:
**every monoidal category is equivalent to a strict one**. All the apparent complexity of
"associativity only up to isomorphism" is, in the end, harmless bookkeeping — *provided* the
bookkeeping is coherent. Coherence is exactly the license to forget the parentheses again.

## Why any of this matters

It is tempting to view all this as an elaborate meditation on a rule we learned as children.
But the pattern — *replace equalities by reversible transformations, then demand those
transformations be coherent* — is one of the organizing principles of contemporary
mathematics and theoretical physics.

In **topology**, spaces are compared not by equality but by continuous deformation, and the
"associativity" of gluing paths holds only up to homotopy; the pentagon reappears as a
consistency condition on how those homotopies fit together. In **quantum algebra and
knot theory**, the associator is a genuine piece of data — it is literally the source of
the invariants that distinguish knots and underlies the mathematics of quantum computation.
In **theoretical physics**, the fusion of anyons — exotic quasiparticles proposed as a
substrate for fault-tolerant quantum computers — is governed by an associator satisfying the
very pentagon identity we met above, and the coherence of that associator is what makes the
computation reliable. Everywhere the same drama plays out: a law that "should" be an equation
is really an isomorphism, and everything hinges on whether the isomorphisms are consistent.

The parenthesization universe is the simplest possible stage on which that drama runs to
completion. It shows, in fully explicit and checkable detail, three things at once:
associativity *can* fail as a literal equation; its failure *can* be repaired by a canonical
reversible bridge; and when the bridges are rigid enough to be unique, coherence is
automatic and the whole edifice collapses back to something strict and simple. The
parentheses, in the end, really don't matter — but understanding *why* they don't, and what
it would take for them to matter, opens a window onto the higher structures where modern
mathematics increasingly lives.

So the next time you drop a pair of parentheses without thinking, pause for a moment. You are
invoking a theorem — a small, perfect causal loop in which composition circles around and
returns, unfailingly, to where it began.
