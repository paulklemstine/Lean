# The Art of Forgetting a Variable

## How a centuries-old algebraic dream became a finite, mechanical engine

Imagine you are handed a tangle of logical rules about a system — a circuit,
a database, a chemical network, a set of beliefs — and someone asks you a
deceptively simple question: *"Forget about this one quantity. What can you
still say about everything else?"*

This is the art of **elimination**. It is one of the oldest and most useful
ideas in all of mathematics. When you solve two equations in two unknowns by
substituting one into the other, you are eliminating a variable. When a
spreadsheet hides a column but keeps every total consistent, it is eliminating
a variable. When a logician removes a quantifier — turning *"there exists an x
such that..."* into a statement that never mentions x at all — they are
eliminating a variable. Across algebra, logic, optimization, and computer
science, the same dream recurs: *project the world onto a smaller stage,
without losing any of the truths that the smaller stage can express.*

The trouble is that elimination has a reputation for being slippery. Remove a
variable from a finite set of rules, and the *shadow* it casts on the remaining
variables can, in principle, be infinitely complicated. The classic worry is
this: even if you start with a handful of equations, the consequences that
survive the projection might require infinitely many new rules to describe. If
that were true, elimination would be a beautiful idea you could never actually
*run* on a computer.

This article is about a result that puts that worry to rest — in a clean and
surprisingly combinatorial corner of algebra. It shows that for **Boolean
polynomials**, the shadow of a finite rulebook is *always* finite, and, better
still, that it has a *canonical, smallest, most atomic* description built out of
single, indivisible moves. Forgetting a variable, it turns out, is not an
unbounded act of cancellation. It is a finite machine.

---

## A world where adding twice changes nothing

To get there, we need to meet the strange and lovely algebra in which this all
takes place: the world of **Boolean polynomials**.

Start with a fixed list of variables — call them $x_0, x_1, x_2, \dots$ A
**monomial** is just a product of some of these variables, like $x_0 x_2$ or
$x_1$ or the empty product $1$. There is one rule that makes this world
"Boolean": a variable squared is just itself, $x_i^2 = x_i$. So a monomial is
completely described by the *set* of variables that appear in it. The monomial
$x_0 x_0 x_2$ is the same as $x_0 x_2$; what matters is only "which variables
are present."

A **Boolean polynomial** is then a *set* of monomials, written as a sum:
$x_0 + x_1 x_2 + 1$, for instance. And here is the twist that gives the whole
theory its character. Addition is **idempotent**:

$$
p + p = p.
$$

Adding a polynomial to itself does nothing. In ordinary algebra, $p + p = 2p$;
here there is no "2." Addition simply *collects* monomials, like throwing items
into a set. Add the same thing twice and the set is unchanged. The "zero"
polynomial is the empty collection, and "one" is the lone empty monomial.

Multiplication works the way you'd expect from distributing sums — but because
$x_i^2 = x_i$, multiplying two monomials just *unions* their variable sets:
$x_0 \cdot x_0 x_1 = x_0 x_1$. Multiply two polynomials and you take every
pairwise product of their monomials and collect the results.

This is not an exotic curiosity. It is, in disguise, the algebra of **monotone
Boolean formulas in disjunctive normal form** — the "OR of ANDs" that hardware
designers, database engineers, and SAT solvers stare at every day. The
idempotent "+" is logical OR; the union-based "$\times$" is logical AND. So when
we talk about manipulating these polynomials, we are really talking about
reasoning with logical formulas. The abstract algebra and the practical logic
are two faces of one coin.

---

## Rules, and the rules they force

Now suppose someone hands us a finite list of **equations** between Boolean
polynomials — a rulebook. Maybe it says $x_0 = x_0 x_1$ (whenever $x_0$ holds,
so does $x_0 x_1$) and $x_0 x_1 = 0$ (the combination $x_0 x_1$ never occurs).
These are our axioms.

From any rulebook, a cascade of further equalities follows automatically. If
$a = b$, then surely $a + c = b + c$ and $a \cdot c = b \cdot c$ for any $c$ —
you can add or multiply both sides by the same thing. And of course equality is
reflexive, symmetric, and transitive. The set of *all* equalities forced by the
rulebook is what algebraists call a **congruence**: the smallest equivalence
relation that respects the operations and contains your starting rules.

The Lean formalization underlying this article builds exactly this object,
inductively. It is called the **generated congruence**, and it comes with a
"universal property": it is genuinely the *smallest* relation that is reflexive,
symmetric, transitive, compatible with $+$ and $\times$, and contains the
generators. (One immediate sanity check, also proved: if you start with *no*
rules at all, the only equalities forced are the trivial ones $a = a$. Nothing
comes from nothing.)

---

## The shadow on a smaller stage

Here is where the drama begins. We single out the last variable — say $x_1$ in
a two-variable world — and we want to *eliminate* it. We ask:

> Among the polynomials that **never mention** $x_1$, which equalities are
> forced by our rulebook?

This restricted relation is the **elimination congruence**. It is the shadow
that our full rulebook casts onto the smaller world of $x_1$-free polynomials.
Formally, two $x_1$-free polynomials $f$ and $g$ are declared equivalent
exactly when their *liftings* into the bigger world (the same polynomials, now
allowed to live alongside $x_1$) are forced equal by the rulebook.

Let's run our example. The rules $x_0 = x_0 x_1$ and $x_0 x_1 = 0$ chain
together: $x_0 = x_0 x_1 = 0$. So in the shadow world, **$x_0$ collapses to
$0$** — even though *neither original rule mentions only $x_0$*! The variable
$x_1$ acted as an invisible courier, carrying the consequence "$x_0 = 0$" from
the big stage down to the small one. And once $x_0 = 0$, we also get
$1 + x_0 = 1$. The elimination congruence has exactly two classes among the
four $x_1$-free polynomials: $\{0, x_0\}$ and $\{1,\, 1 + x_0\}$.

That is the whole point of elimination: it surfaces hidden consequences. The
question is whether we can always *find* them, finitely.

---

## The first theorem: the shadow is always finite

The first main result says **yes, always** — at least once we agree to work
inside any fixed, bounded vocabulary of monomials.

> **Finite generation of bounded elimination (informal).** Fix a finite
> universe $V$ of allowed monomials. Then there is a *finite* set $S$ of
> equation-pairs such that, for any two polynomials $f$ and $g$ built only from
> monomials in $V$, the rulebook forces $f = g$ in the shadow world **if and
> only if** $S$ forces it.

In other words: the projection of a finite rulebook is again a finite rulebook.
The shadow does not require infinitely many rules to pin down. Why is this not
obvious? Because the consequences of a congruence can ripple through arbitrarily
complicated intermediate polynomials before landing back in the $x_1$-free
world. The theorem guarantees that, no matter how baroque those intermediate
steps are, the *net effect* on any bounded vocabulary is captured by a finite
list.

The reason a bound on the vocabulary suffices is delightfully simple: with a
universe of $|V|$ monomials, there are only $2^{|V|}$ polynomials you can build
at all. Finitely many objects, finitely many possible equalities — so a finite
generating set must exist. The number $2^{|V|}$ is large, but it is *finite*,
and finiteness is the gateway to computation.

---

## The second theorem: every shadow is built from atoms

A finite rulebook is good. A *canonical, minimal, atomic* one is far better.
The second — and central — result delivers exactly that, and it hinges on a
beautiful structural idea borrowed from lattice theory: **join-irreducibility**.

In a world where "adding" means "taking the union," some sets are *compound* —
they are genuinely the merger of smaller pieces — and some are *atomic*. A set
is called **join-irreducible** if it is nonempty and *cannot* be written as the
union of two strictly smaller subsets. A short, clean lemma in the formalization
shows what these atoms actually are:

> **Singletons are the atoms.** In the lattice of finite sets ordered by
> inclusion, the join-irreducible sets are *exactly the singletons* — the
> one-element sets.

This makes intuitive sense. A two-element set $\{a, b\}$ is the union of
$\{a\}$ and $\{b\}$, both strictly smaller — so it is compound. But a singleton
$\{a\}$ has no two proper subsets to union together; it is irreducible. It is an
atom of the union world.

Now bring this back to elimination. Whenever two polynomials $f$ and $g$ are
forced equal in the shadow, their *support difference* — the monomials in one
but not the other — measures how far apart they look. The **join-irreducible
witnesses** are precisely those forced equalities whose support difference is an
atom: a *single monomial*. They are the most elementary moves possible —
"these two polynomials are equal, and they differ by exactly one monomial."

The main theorem says these atomic moves are enough to rebuild everything:

> **Main theorem (informal).** Inside any bounded vocabulary, the entire
> elimination congruence is generated by its join-irreducible witnesses. Every
> equality forced in the shadow world — no matter how large the gap between the
> two sides — can be assembled, step by step, from single-monomial moves.

This is the conceptual payoff. Forgetting a variable is not an unbounded
cancellation problem. It is a finite, combinatorial engine whose *gears* are
single-monomial witnesses. Any complex equality between projected polynomials
factors into a chain of these one-monomial steps, the way any whole number
factors into primes or any motion decomposes into tiny increments.

The proof has a satisfying shape. It first reduces the general case to a
"subset case," where one polynomial's monomials are contained in the other's.
There, it peels off one monomial at a time — each peel justified by exactly one
atomic witness — using a clever induction on the *number* of monomials in the
gap. The idempotent law $p + p = p$ is the quiet hero throughout: it is what
lets you add a single monomial to one side without disturbing anything else,
because doubling never changes a Boolean sum.

In the running example, the theorem is vividly concrete. The two non-trivial
shadow equalities, $x_0 = 0$ and $1 + x_0 = 1$, both differ by the *single*
monomial $x_0$. Each is a join-irreducible witness, and together they generate
the whole shadow congruence — confirmed both by the formal proof and by the
accompanying numerical demonstration.

---

## Why this matters beyond the page

It is tempting to file this away as elegant abstract algebra. But the pattern it
captures is everywhere.

**Logic and verification.** Eliminating a variable from a set of Boolean
constraints is *quantifier elimination* — the engine inside many automated
reasoners, model checkers, and program verifiers. Knowing that the projected
theory is finitely and canonically presentable is exactly what makes such tools
terminate with predictable, minimal output.

**Databases.** Projecting a query to "forget" a column while preserving every
dependency among the remaining columns is, structurally, the same move. Finite,
atomic generation means the projected set of dependencies can be computed and
stored compactly.

**Knowledge compilation and circuits.** Monotone DNF formulas — our Boolean
polynomials in disguise — are a workhorse representation in hardware synthesis
and in compiling knowledge bases into fast-to-query forms. Reducing the number
of variables while keeping all logical consequences is precisely a circuit
simplification step.

**The grand tradition of elimination.** From Gaussian elimination in linear
algebra, to Gröbner bases for polynomial ideals, to Fourier–Motzkin elimination
for linear inequalities, mathematics is full of "projection" theorems whose
worth lies in turning an infinite-looking process into a finite, mechanical one.
The result described here is a member of that family, tailored to the idempotent,
set-flavored algebra of Boolean reasoning — and it earns its keep by replacing a
potentially unbounded search with a finite extraction of single-monomial
witnesses.

---

## The shape of a good idea

What makes this story satisfying is not just that it works, but *how cleanly* it
works. A vague, daunting question — "what survives when I forget a variable?" —
is tamed in two strokes. First, **finiteness**: the shadow of a finite rulebook
is itself finite. Second, **atomicity**: that finite shadow is built entirely
from the simplest possible moves, the ones that change exactly one monomial.

The atoms turn out to be the join-irreducible elements of a lattice — the
singletons — and the engine that powers the whole construction is the humble,
almost paradoxical law that adding something to itself changes nothing. Out of
that one quiet rule grows a complete, mechanical theory of forgetting.

There is a small philosophical pleasure here, too. We usually think of
*remembering* as the hard part. But in mathematics, as in life, deciding what to
*forget* — and proving that you can do so cleanly, finitely, without losing what
matters — is the deeper art. This is a theorem about doing exactly that, and
doing it beautifully.
