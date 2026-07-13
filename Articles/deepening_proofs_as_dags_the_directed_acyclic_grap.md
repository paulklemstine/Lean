# Proofs Are Shaped Like Rivers: The Hidden Architecture of Mathematical Reasoning

## A map you have never seen

Every theorem you have ever learned rests on other theorems. The Pythagorean
theorem leans on facts about areas; those facts lean on the axioms of geometry.
Calculus leans on the theory of limits, which leans on the properties of the real
numbers, which lean on set theory. Follow any result downward and you descend
through layer after layer of prerequisites until you reach bedrock: the handful of
axioms we simply agree to accept.

Draw this out and a picture emerges. Put a dot for each statement. Draw an arrow
from statement $a$ to statement $b$ whenever $a$ is *used* in the proof of $b$.
What you get is a network — and not just any network. It is a network with a
direction and a rule that can never be broken: **you can never come back to where
you started.**

This one rule, so obvious it is easy to overlook, turns out to have surprisingly
rich consequences. It forces the entire edifice of mathematics into a particular
*shape*. The purpose of this article is to describe that shape precisely, and to
show that from a single assumption — "no circular arguments" — we can deduce that
every body of mathematical knowledge must have foundations, must have peaks, can be
sorted into a clean order of increasing sophistication, and can never be too
tangled.

## The one forbidden move

A proof cannot be circular. You are not allowed to prove statement $A$ using
statement $B$, and then turn around and prove $B$ using $A$. If you could, you would
have proved nothing at all — each result would be resting on the other, with the
whole structure floating in mid-air with no support.

Let us make this a precise property of the arrow-network. Say we have a collection
of statements and a *dependency relation*: we write $a \to b$ to mean "$a$ is used
directly in the proof of $b$." A **chain** is a sequence of these arrows,
$a \to c_1 \to c_2 \to \cdots \to b$, meaning $a$ feeds into something that feeds
into something that eventually feeds into $b$. When such a chain exists we say $a$
**reaches** $b$: statement $a$ is an ancestor of statement $b$, an ingredient
somewhere deep in its recipe.

The no-circularity rule is now a single clean sentence:

> **Acyclicity.** No statement ever reaches itself.

That is the entire assumption. A network of statements and dependency arrows that
obeys this rule is called a **directed acyclic graph**, or DAG. Everything that
follows is squeezed out of this one condition.

## Small consequences, immediately

The first consequences are almost too easy, but they are worth stating because they
are the seeds of everything else.

**No statement is used in its own proof.** If $a$ were a direct ingredient of its
own proof, then $a$ reaches $a$ in a single step — a cycle. Forbidden. So the
network has no *self-loops*.

**Two statements cannot depend on each other.** Suppose $a \to b$ and also
$b \to a$. Then $a$ reaches $a$ by going out to $b$ and coming back. Forbidden
again. In the language of relations, dependency is *asymmetric*: at most one of the
two arrows between any pair can exist.

**No cycle of any length can exist.** This is the grown-up version. It is not just
that you cannot have a two-step loop; you cannot have a loop of three steps, or ten,
or ten thousand. If $a$ reaches $b$ through some long chain, then $b$ can *never*
reach $a$ through any chain whatsoever. The technical way to say it: the "reaches"
relation is itself asymmetric. Reachability points in one consistent direction, like
water flowing downhill and never uphill.

These three facts sound like restatements of the same idea — and they are — but the
last one is genuinely stronger, and it is the engine for the deep results.

## Counting ancestors: the birth of a ruler

Here is the beautiful idea at the heart of the whole story. We want to assign to
every statement a *number* that measures how advanced it is — small numbers for the
axioms and basic facts, large numbers for the deep theorems built on top of
everything. We want this number to respect dependency: if $a$ is an ingredient in
$b$, then $a$'s number should be strictly smaller than $b$'s.

How do we manufacture such a number out of thin air? The trick is disarmingly
simple:

> **The rank of a statement is the number of its ancestors** — that is, the number
> of distinct statements that reach it.

Call it $f(a)$: the count of everything that feeds, directly or indirectly, into
$a$. A raw axiom has no ancestors at all, so its rank is $0$. A theorem sitting atop
a mountain of prerequisites has a large rank. This feels right. But does it actually
*work* — does it always increase along arrows?

The key is a clean, almost visual, observation. Suppose $a$ reaches $b$. Then:

- **Every ancestor of $a$ is also an ancestor of $b$.** If some statement $u$
  reaches $a$, and $a$ reaches $b$, then $u$ reaches $b$ by stitching the two chains
  together. So the ancestors of $a$ are a *subset* of the ancestors of $b$.
- **But $b$ has at least one ancestor that $a$ does not: namely $a$ itself.** Since
  $a$ reaches $b$, $a$ counts as an ancestor of $b$. Yet $a$ is *not* an ancestor of
  itself — that is exactly the no-cycles rule! So $a$ belongs to $b$'s ancestor set
  and is missing from its own.

Put these together and the ancestor set of $a$ is a *strict* subset of the ancestor
set of $b$. A strict subset of a finite set is strictly smaller. Therefore

$$ a \text{ reaches } b \quad\Longrightarrow\quad f(a) < f(b). $$

We have built a ruler. This is the **Topological Numbering Theorem**: in any finite
body of mathematics with no circular arguments, one can assign to every statement a
whole number so that dependencies always run from smaller numbers to larger ones.
Every proof, no matter how sprawling, can be laid out on a single number line with
all the arrows pointing the same way.

This is not a mere curiosity. It is the reason mathematics can be *taught*. You can
always find an order in which to present the material so that nothing is ever used
before it has been established. The ruler $f$ is a valid syllabus.

## Every subject has foundations, and every subject has peaks

Once you have a ruler, two landmarks appear automatically.

Look at the statement with the **smallest** rank. Could anything point *into* it —
could it depend on some earlier statement? No: an incoming arrow would come from a
statement of strictly smaller rank, but nothing has a smaller rank than the minimum.
So this statement depends on nothing. It is a **source** — a foundational,
axiom-like statement that everything else can be traced back toward.

> **Foundation Theorem.** Any nonempty finite body of mathematics with no circular
> arguments contains at least one statement that depends on nothing else.

Symmetrically, look at the statement with the **largest** rank. Nothing can point
*out* of it, because an outgoing arrow would lead to a statement of strictly larger
rank, and nothing is larger than the maximum. This is a **sink** — a capstone
result that is used by nothing further, a natural endpoint of the theory.

> **Capstone Theorem.** Any nonempty finite body of mathematics with no circular
> arguments contains at least one statement that is used in nothing else.

Foundations and peaks are not something we build in by hand or hope to find. They
are *forced to exist* by acyclicity alone. Every self-contained subject, however you
slice it, has bedrock at the bottom and open frontier at the top.

## Reasoning is sparse

The final result is about *density*. Networks can be tame or hopelessly tangled. A
group of $n$ people can have up to $n(n-1)/2$ friendships (every pair connected). A
general directed network on $n$ nodes can have up to $n(n-1)$ arrows, since each pair
can be wired in both directions. How tangled can a *proof* network get?

The no-cycles rule cuts the maximum in half. Because dependency is asymmetric, for
any pair of statements at most *one* of the two possible arrows between them can be
present — you get $a \to b$ or $b \to a$, but never both. So the number of
dependency arrows can never exceed the number of *pairs*:

$$ (\text{number of dependencies}) \;\le\; \frac{n(n-1)}{2}, \qquad\text{equivalently}\qquad 2\,|E| \le n(n-1). $$

> **Sparsity Theorem.** A body of $n$ statements with no circular arguments has at
> most $n(n-1)/2$ direct dependencies.

Consistent direction imposes a hard ceiling on tangling. A proof structure with $n$
statements cannot be arbitrarily dense; it must leave at least half of all possible
connections empty. Reasoning, by its very nature, is economical.

## Why this matters beyond mathematics

The abstract picture — a directed network in which you can never return to your
starting point — is one of the most useful shapes in all of applied science, and the
results above are not just about theorems.

- **Software.** Modern programs are built from thousands of modules, each importing
  others. That import structure is a proof-DAG in disguise. The Topological
  Numbering Theorem is exactly why a build system can figure out a valid compilation
  order; a *cycle* in the imports is a bug that makes the project impossible to
  build. Sources are the base libraries; sinks are the top-level applications.

- **Spreadsheets.** Each cell's formula depends on other cells. The moment you
  create a circular reference, the spreadsheet throws an error — it has detected a
  cycle in its DAG, and there is no consistent order in which to compute the values.

- **Project scheduling.** Tasks depend on other tasks being finished first. The
  topological order is a valid schedule; the sink is the final deliverable; the
  longest chain of dependencies is the *critical path* that sets the minimum project
  duration.

- **Version control and data pipelines.** Commits build on parent commits; data
  transformations feed into later ones. Both are acyclic by design, and both rely on
  exactly the ordering guarantee proved here.

In every one of these settings, the same tiny hypothesis — *no going in circles* —
delivers the same rich dividends: a consistent order exists, foundations and
endpoints exist, and the structure can never be too dense.

## The grand conjecture

We end with a vista. If we could draw the DAG of *all* of mathematics — every
theorem ever proved, wired to everything it uses — what would it look like? The
results here guarantee it has sources (the axioms) and can be ranked by depth. But
there is a tantalizing further belief: that this colossal network is not spread out
evenly, but concentrates on a slender **spine** of foundational hubs — a small set
of statements, like the fundamental theorems of arithmetic, calculus, and algebra,
through which a vast fraction of all reasoning must pass.

If true, this would mean the whole of mathematics hangs from a few load-bearing
pillars. Strengthen or endanger one of those hubs and immense territory is affected
at once. Mapping that spine — measuring which theorems are truly indispensable — is
the frontier this line of work points toward. The humble observation that you cannot
argue in a circle turns out to be the first step in charting the architecture of
knowledge itself.
