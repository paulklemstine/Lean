# The Price of Self-Reference

## What a hand drawing a hand, a crab canon, and a liar's sentence all have in common — and the exact toll each one pays

There is a family resemblance among the great self-referential artifacts. A
sentence that talks about itself. A drawing whose subject is the drawing of
itself. A canon that plays the same when read backwards. Douglas Hofstadter
famously argued that these are not three coincidences but one phenomenon in
three costumes: an "eternal golden braid" of formal, visual, and musical
strange loops.

Mathematicians have a precise version of the intuition. It is called the
**diagonal argument**, and it is the single engine behind Cantor's uncountability
theorem, Russell's paradox, Turing's halting problem, and Gödel's
incompleteness theorems. In its cleanest form — Lawvere's fixed-point theorem —
it says:

> If a system of *codes* is rich enough that every observation about codes is
> itself performed by some code, then every transformation of meanings has a
> **fixed point**: something the transformation cannot change.

That single sentence explains why no consistent, sufficiently strong theory can
prove its own consistency: "I am not provable" is a fixed point of the
provability operator. It also, tantalisingly, suggests that we could set up
formal syntax, visual syntax, and musical syntax as three interchangeable
systems of codes, and watch the *same* strange loop appear in all three.

This article is about what happens when you actually try. The story has a
sharp twist: **the naive version of the plan is impossible — not hard,
impossible — and understanding exactly why it fails hands you the correct
version, complete with a formula that counts precisely how much
self-reference a finite world can support.**

---

## 1. Tables of self-application

Strip the story down to its skeleton. We need three things:

- a set $A$ of **codes** (sentences, drawings, canons — it does not matter);
- a set $B$ of **meanings** (true/false, a colour, a pitch, a real number);
- a rule that lets one code be *applied to another*.

That last ingredient is the heart of self-reference. Write it as a table
$$\mathrm{ev} : A \times A \to B,$$
so that $\mathrm{ev}(a,x)$ is "the meaning you get when code $a$ is applied to
code $x$". The crucial move — the diagonal — is to feed a code to *itself*:
$\mathrm{ev}(x,x)$. A sentence about sentences, applied to itself. A drawing of
drawings, drawn drawing itself.

Call the pair $(A, \mathrm{ev})$ a **presentation**, and call it **universal**
if the table is as expressive as possible: every possible observation
$g : A \to B$ on codes is *performed by some code*, i.e. there exists $c \in A$
with $\mathrm{ev}(c,x) = g(x)$ for all $x$. Universality is the formal shadow of
Hofstadter's "sufficiently rich system": everything you can say about the
system, the system can say.

From universality, Lawvere's argument is three lines. Take any transformation
$f : B \to B$ of meanings. The observation $x \mapsto f(\mathrm{ev}(x,x))$ —
"apply $x$ to itself, then transform the answer" — is an observation on codes,
so universality provides a code $c$ performing it:
$$\mathrm{ev}(c, x) = f(\mathrm{ev}(x,x)) \quad \text{for all } x.$$
Now the diagonal step: set $x := c$. Then $\mathrm{ev}(c,c) =
f(\mathrm{ev}(c,c))$. The value $b = \mathrm{ev}(c,c)$ is a **fixed point** of
$f$. Gödel's sentence, Turing's paradoxical program and Russell's set are all
this one line in different clothes.

## 2. The catastrophe: universality is empty

Beautiful — and, it turns out, useless as stated. Here is the twist.

Suppose your world of meanings contains *at least two distinct things*,
$b_1 \neq b_2$. Then define a transformation of meanings that simply refuses to
sit still:
$$\mathrm{swap}(x) = \begin{cases} b_2 & \text{if } x = b_1,\\ b_1 &
\text{otherwise.}\end{cases}$$
This map has **no fixed point at all**: if $x = b_1$ it moves to $b_2 \ne b_1$,
and if $x \ne b_1$ it moves to $b_1 \ne x$. But Lawvere's argument insists that
*every* transformation of meanings has a fixed point. Contradiction. Therefore:

> **Theorem (Vacuity of universality).** If a universal self-application table
> $\mathrm{ev} : A \times A \to B$ exists, then $B$ has at most one element.
> Equivalently: over any semantic domain with two distinct meanings, no
> universal presentation exists — none, for any code set whatsoever.

This is worth pausing on. It is not that universal presentations are rare or
pathological; they are *nonexistent* as soon as there is anything to say. The
well-known impossibility for truth values ($B = \{\text{true}, \text{false}\}$,
where the obstruction is negation) is not a special feature of logic. Negation
is merely the two-element instance of $\mathrm{swap}$: **every** nontrivial set
of meanings carries its own private liar paradox, definable with no cleverness
whatsoever.

The dichotomy is exact and it is sharp on the other side too: if $B$ *is* a
single point, universal presentations do exist (trivially, the constant table).
So the boundary between "everything is representable" and "nothing is" sits
precisely at the difference between one meaning and two.

Any theorem whose hypothesis is "let $(A,\mathrm{ev})$ be a universal
presentation over a nontrivial $B$" is therefore a theorem about the empty set.
It is true, and it says nothing. The whole edifice needs a new foundation.

## 3. The repair: grade the universality

Look again at Lawvere's three-line argument and ask what it actually consumed.
Universality was invoked *once*, to represent one specific observation:
$x \mapsto f(\mathrm{ev}(x,x))$. Everything else in the table was irrelevant.

So demand only that. Say a table **diagonally represents** the transformation
$f$ if there is a code $c$ with $\mathrm{ev}(c,x) = f(\mathrm{ev}(x,x))$ for
all $x$; call such a $c$ a *diagonal code for $f$*. The three-line argument
survives verbatim:

> **Graded Fixed-Point Theorem.** If a table diagonally represents $f$ via the
> code $c$, then $\mathrm{ev}(c,c)$ is a fixed point of $f$.

We have replaced a hypothesis that can never be satisfied with one that
frequently can. But how much did we actually keep? Astonishingly, the answer is
"everything, and the converse too".

> **Obstruction Spectrum Theorem.** Let $B$ be any set of meanings and $F$ any
> family of transformations of $B$. There exists a *single* table
> $\mathrm{ev} : A \times A \to B$ diagonally representing every member of $F$
> **if and only if** every member of $F$ has a fixed point.

One direction is the graded theorem. The other is a construction: given that
each $f \in F$ fixes some point $b_f$, build codes consisting of one label per
member of $F$ plus one literal per meaning, declare the self-value of the label
of $f$ to be $b_f$ and of a literal to be itself, and let the label of $f$
applied to $x$ return $f$ of $x$'s self-value. Then every label is, by
construction, a diagonal code.

This is the clean statement the whole subject was reaching for. **The capacity
of a syntax for self-reference is not a property of the syntax at all. It is
exactly the fixed-point structure of the meanings you want it to talk about.**

## 4. A conjecture that dies on a three-element set

There is a seductive follow-up guess. Fixed-point-freeness looks like an
algebraic property, so surely representability of a family $F$ should be
controlled by the *monoid* of transformations that $F$ generates under
composition — after all, if the syntax can talk about $f$ and about $g$, ought
it not talk about $f \circ g$?

It ought not. Take three meanings $\{0,1,2\}$ and the two swaps
$$t_A = (0\;1), \qquad t_B = (1\;2).$$
Each is an involution with a fixed point ($t_A$ fixes $2$, $t_B$ fixes $0$), so
by the Obstruction Spectrum Theorem a *single* table represents both. But their
composite $t_A \circ t_B$ is the three-cycle $0 \mapsto 1 \mapsto 2 \mapsto 0$,
which fixes nothing — so *no table in the universe* diagonally represents it.

> **Theorem (Failure of monoid control).** Representability is not closed under
> composition, and is not determined by the transformation monoid generated by
> the family. It is determined pointwise, member by member.

The reason, once seen, is unmistakable: the diagonal argument uses $f$ **exactly
once**. The table never evaluates a composite, so nothing forces closure. In the
same spirit, a table can represent every *constant* observation on truth values
and still fail to represent the diagonal composite of negation — richness of the
represented class is simply a different axis from diagonal closure.

## 5. Which fixed point? The ambiguity, and when it vanishes

The theorem says a diagonal code produces *a* fixed point. Different codes may
produce different ones. This is not pedantry: consider the table on truth values
that ignores its first argument, $\mathrm{ev}(a,x) = x$. Every code is a
diagonal code for the identity, and there are two codes with two different
diagonal values. Self-reference by itself does not pin down what the strange
loop *says*.

But it does under one hypothesis, and the hypothesis is exactly the right one:

> **Code Independence Theorem.** If $f$ has *at most one* fixed point, then any
> two diagonal codes for $f$ — in arbitrary, unrelated presentations, over
> completely different sets of codes, with no isomorphism between them — have
> the *same* diagonal value.

No structural relationship between the two syntaxes is needed. Semantic
uniqueness alone forces agreement, because both values are fixed points of the
same $f$ and there is only one such point to be.

Concretely, contraction supplies uniqueness. If $f : \mathbb{R} \to \mathbb{R}$
satisfies $|f(x) - f(y)| \le K|x-y|$ with $K < 1$, then $f$ has at most one
fixed point, so every diagonal code for $f$, in every conceivable syntax,
evaluates to one and the same real number. Self-reference over a contracting
semantics is *canonical*: the strange loop has a determinate value, computable
by iteration, independent of how the loop was built.

## 6. Four grades of "the same loop in another medium"

Now return to Hofstadter's braid. If two syntaxes are related, does a strange
loop in one give a strange loop in the other? The answer is a hierarchy of four
increasingly weak relationships, each preserving strictly less.

1. **Evaluation-preserving equivalence** (a bijection $\varphi$ of codes with
   $\mathrm{ev}_Q(\varphi a, \varphi x) = \mathrm{ev}_P(a,x)$): everything
   transports. The image of a diagonal code is a diagonal code, and the diagonal
   value is unchanged. This is the strongest, and only, sense in which "the same
   loop" is literally the same.
2. **Coherent retraction** (a section–retraction pair with
   $\mathrm{ev}_Q(c,x) = \mathrm{ev}_P(\mathrm{r}c, \mathrm{r}x)$): diagonal
   codes *lift* from the small table to the big one. Loops in a fragment survive
   into any coherent extension.
3. **Evaluation-preserving embedding**: the diagonal *value* is preserved and
   remains a fixed point, and the diagonal equation continues to hold *on the
   image* — but code-hood itself is lost. A one-code table embeds into a
   two-code table (send the point to `true`, evaluate $\mathrm{ev}(a,x) = a$);
   the unique code is a diagonal code for the identity, yet its image fails the
   diagonal equation at the new code `false`. A loop can stop being a loop when
   the world around it grows.
4. **Bisimulation** (codes related so that their diagonal values are related by
   some observational relation $R$): only the *observation* transports. Two
   one-code tables with diagonal values $0$ and $2$ are bisimilar for parity;
   both codes are diagonal codes for the identity; the values agree modulo $2$
   and disagree as numbers.

So "the same strange loop in another medium" is a graded notion: literal at the
top, liftable one step down, value-only below that, and merely observational at
the bottom.

## 7. The braid, rebuilt — in twelve pitch classes

With universality dead and grading in place, can we actually build Hofstadter's
triad? Yes — and here it is, over the twelve pitch classes
$\mathbb{Z}/12\mathbb{Z}$ of the chromatic scale, where meanings are notes.

Three syntaxes, each with three kinds of code:

- **Formal:** a self-substitution operator, a tritone self-substitution
  operator, and literals.
- **Visual:** *drawing hands*, a mirrored *drawing hands*, and framed pitches.
- **Musical:** a crab canon, its tritone answer, and single notes.

Each syntax gets a self-value (the two operators self-evaluate to $0$ and $3$
respectively; literals to themselves) and a table: an operator applied to $x$
returns the operator's semantic transformation of $x$'s self-value.

The relevant transformations of pitch class are:

- **Inversion** $x \mapsto -x$ (turn the melody upside down). Its fixed points
  are $0$ and $6$.
- **Tritone inversion** $x \mapsto 6 - x$ (invert about the tritone). Fixed
  points $3$ and $9$.
- **Transposition** $x \mapsto x + 1$ (shift up a semitone). **No fixed point.**

The three syntaxes are related by evaluation-preserving equivalences —
self-substitution $\leftrightarrow$ drawing hands $\leftrightarrow$ crab canon —
so by the transport theorem the diagonal code for inversion in one is the
diagonal code for inversion in the others, and:

> **Common Value Theorem.** In each of the three syntaxes the inversion code is
> a genuine diagonal code, all three diagonal values are equal to the pitch
> class $0$, and $0$ is indeed fixed by inversion.

A single note, sounded identically by a sentence about itself, a hand drawing
itself, and a canon playing itself backwards. Hofstadter's braid, made exact.

And the same triad shows both the ambiguity and the obstruction, in music:

> The tritone code in the same triad is a diagonal code whose value is $3 \ne 0$
> — so the diagonal value genuinely depends on which loop you build.
>
> **No syntax whatsoever** — formal, visual, or contrapuntal — contains a
> diagonal code for semitone transposition, because no pitch class satisfies
> $x + 1 = x$.

Music can turn itself upside down and remain itself. Music can *never*
transpose itself and remain itself. That is not an artistic observation; it is a
theorem, and its proof is a fixed-point count.

## 8. How much self-reference fits in a finite world?

Because the Obstruction Spectrum Theorem identifies the maximal representable
family *exactly* — it is the set of transformations with a fixed point — the
question becomes countable. Over $n$ meanings there are $n^n$ transformations,
and a transformation is fixed-point-free exactly when each of the $n$ inputs
avoids its own value, giving $(n-1)^n$ choices. Hence:

> **Counting Theorem.** Over an $n$-element domain of meanings, exactly
> $$n^n - (n-1)^n$$
> transformations are diagonally representable, and this is the largest family
> a single table can handle.

For $n = 1,2,3,4$: $1, 3, 19, 175$. The fraction of representable
transformations is $1 - \left(1 - \tfrac1n\right)^n$, and therefore:

> **Density Theorem.** As $n \to \infty$, the proportion of representable
> transformations converges to
> $$1 - e^{-1} = 0.632120\ldots$$

The picture that emerges is quantitative rather than merely cautionary. About
$63\%$ of all semantic dynamics can host a strange loop. The remaining
$e^{-1} \approx 36.8\%$ — a definite, stable, universal fraction — is
permanently beyond the reach of self-applicative syntax, in any medium, at any
scale. Gödel's theorem, Turing's halting problem, and the liar are not isolated
curiosities squatting at the edge of mathematics. They are samples from a
population that occupies a third of the space.

---

## Coda

The classical strange-loop story is often told as a story about *power*: make a
system rich enough and it will inevitably turn and bite itself. The corrected
version reverses the emphasis. Richness in the naive sense is unattainable — a
fully universal self-application table forces every meaning to collapse into
one. What is attainable is *targeted* self-reference: a syntax that can talk
about itself with respect to a chosen transformation, and can do so precisely
when that transformation has something it cannot move.

Everything else follows from that single criterion. Which loops exist: the ones
whose semantics has a fixed point. Whether the loop's value is well defined:
yes, exactly when the fixed point is unique. Whether the loop survives
translation into another medium: yes for equivalences, upward for coherent
retractions, in value only for embeddings, in observation only for
bisimulations. How many loops a finite world admits: $n^n - (n-1)^n$, a
$1 - e^{-1}$ share of everything.

A hand can draw itself. A canon can play itself backwards. A sentence can
assert its own unprovability. But nothing — no formalism, no picture, no music
— can encode a transformation that refuses to stand still. That is the price of
self-reference, and now we know it exactly.
