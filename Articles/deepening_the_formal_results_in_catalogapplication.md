# The Proposition That Knows It Is Provable

## A short story about self-reference, and where it stops

Suppose you write down a mathematical statement $A$ and you manage to prove it. A
natural instinct says: *of course* you can also prove the statement "$A$ is
provable". After all, you just did it — the proof is sitting there on the page.
Write down its steps, check them, and you have a proof of provability.

That instinct is one of the most seductive in all of logic, and it is wrong in
general. It is wrong for a reason that is not about clever paradoxes or
self-swallowing sentences, but about *geometry*: the shape of the space in which
"provable" is interpreted. This article is about drawing that boundary precisely,
and about a second surprise waiting on the other side of it — that a programming
language rich enough to talk about its own evidence turns out, letter for letter,
to be a language logicians have been studying for decades under a completely
different name.

## Propositions that mention proofs

Start with an ordinary type-theoretic language, the kind that underlies modern
functional programming and constructive mathematics. It has atomic propositions,
a false proposition $\bot$ (with no evidence at all), a true proposition $\top$
(with trivial evidence), pairing $A \wedge B$ (evidence for both), and function
space $A \to B$ (a method turning evidence for $A$ into evidence for $B$). Every
proposition in this language is *inert*: it talks about mathematical objects, never
about proofs.

Now add a single new word. Write $\Box A$ for the proposition

$$\Box A \;=\; \text{“there is accessible evidence for } A \text{”}.$$

This is a **reflective** language: its propositions can talk about the availability
of their own evidence. And add one more former, a fixed-point binder $\mu X.\,A(X)$,
which lets a proposition be defined by reference to itself — the propositional
analogue of a recursive datatype. With these two additions we have the grammar of
*reflective propositions*:

$$A ::= p \;\mid\; X \;\mid\; \bot \;\mid\; \top \;\mid\; A \wedge A \;\mid\; A \to A \;\mid\; \Box A \;\mid\; \mu X.\,A .$$

Two questions immediately present themselves. First: is this really new, or is
$\Box$ secretly definable from the ingredients we already had? Second: what does
$\Box$ *mean*, and in particular, is $\Box A \to \Box\Box A$ forced?

## The first answer: reflection is genuinely new

It is easy to *say* that $\Box$ adds something, and surprisingly easy to say it
badly. Counting constructors proves nothing; a new symbol can always turn out to be
an abbreviation. The honest version of the claim is a *retraction*.

Define the obvious inclusion $\iota$ of the inert language into the reflective one:
atoms go to atoms, $\bot$ to $\bot$, $\top$ to $\top$, and pairs and arrows are
translated componentwise. Now define a partial decoder $\delta$ running the other
way, which reads a reflective proposition and tries to write it as an inert one. It
succeeds on atoms, constants, pairs and arrows (recursively), and it **fails** —
returns "undefined" — the moment it meets a bound fixed-point variable, a $\Box$, or
a $\mu$.

**Theorem (Retraction).** For every inert proposition $A$, decoding its inclusion
returns $A$ itself: $\delta(\iota(A)) = A$. Consequently $\iota$ is injective: the
inert language sits inside the reflective one without collapsing.

The proof is a two-line induction on the structure of $A$; the point is not its
difficulty but what it buys. Because $\delta \circ \iota$ is the identity, anything
on which $\delta$ *fails* cannot be in the image of $\iota$. In particular:

**Theorem (Properness).** For any atom $p$, the reflective proposition $\Box p$ is
not the image of any inert proposition.

If $\Box p$ were $\iota(A)$ for some inert $A$, then decoding it would return $A$;
but decoding $\Box p$ returns nothing. So the extension is proper, not by fiat but
by exhibiting a concrete invariant that separates the two grammars. This is exactly
the shape of argument one wants: a *witness* that no amount of clever syntactic
sugar in the inert language can produce $\Box p$.

## The second answer: $\Box$ is a shape, not a fact

To ask what $\Box$ means, model it. A **frame** is a set of *proof states* — think
of them as stages of knowledge, or moments in the life of a growing theory — together
with an accessibility relation $w \to v$: "from state $w$, state $v$ is one step of
reasoning away". A proposition is just a set $P$ of states, those where it holds. And

$$\Box P \;=\; \{\, w : \text{every } v \text{ with } w \to v \text{ lies in } P \,\}.$$

So "$A$ is provable at $w$" means: whatever one step of reasoning you take from $w$,
you land somewhere $A$ holds. This is the standard Kripke reading of necessity, and
it makes the question about iteration sharp. When is $\Box P \subseteq \Box\Box P$?

**Theorem (Transitivity forces iteration).** If the accessibility relation is
transitive — if $a \to b$ and $b \to c$ always imply $a \to c$ — then
$\Box P \subseteq \Box\Box P$ for every proposition $P$.

The proof is a one-liner once you unfold the definitions: to show $w \in \Box\Box P$,
take $w \to v$ and $v \to u$; transitivity gives $w \to u$, and $w \in \Box P$ then
puts $u$ in $P$. Reasoning "two steps out" is subsumed by reasoning "one step out"
precisely when two steps *are* one step.

And here is the payoff. Consider the reflective proposition

$$\Box A \wedge \neg\,\Box\Box A,$$

read: "$A$ is provable, but it is not provable that $A$ is provable". Call a state
where this holds a **reflection witness**. The theorem above says at once:

**Corollary (Transitive impossibility).** On a transitive frame, no state, for any
proposition, is a reflection witness. The proposition $\Box A \wedge \neg\Box\Box A$
is uninhabitable there.

So if you believe your notion of provability is transitive, you will never see the
phenomenon. But transitivity is an *assumption about the geometry of reasoning*, not
a law of thought. Drop it and the phenomenon appears — and it appears in a model with
three states.

## The three-world machine

Take exactly three proof states, labelled $2$, $1$, $0$, and exactly two arrows:

$$2 \longrightarrow 1 \longrightarrow 0 .$$

There is no arrow from $2$ to $0$. This is a chain of length two, and it is
emphatically *not* transitive: composing $2 \to 1$ with $1 \to 0$ would demand an
arrow $2 \to 0$, and there is none.

Let $M$ be the proposition true at state $1$ and nowhere else — call it "the middle
proposition". Now evaluate.

*Is $M$ provable at state $2$?* The only state accessible from $2$ in one step is
$1$, and $M$ holds at $1$. So $2 \in \Box M$: yes.

*Is $M$ provably provable at state $2$?* That would require $\Box M$ to hold at
every state one step from $2$ — that is, at state $1$. Is $M$ provable at $1$? The
only state one step from $1$ is $0$, and $M$ fails at $0$. So $1 \notin \Box M$, and
therefore $2 \notin \Box\Box M$: no.

**Theorem (Finite reflection witness).** In the three-state chain $2 \to 1 \to 0$,
the middle proposition satisfies $\Box M$ at state $2$ while $\Box \Box M$ fails
there. Hence $\Box M \wedge \neg\Box\Box M$ is inhabited.

That is the whole construction. A statement can be provable without being provably
provable, and three states with two arrows suffice to see it. Together with the
transitive impossibility theorem, the two results pin the phenomenon exactly:
non-transitivity is not merely *compatible* with the failure of iterated provability,
it is *necessary* for it, and two steps of non-transitivity are already enough.

One detail deserves emphasis, because it is where naive attempts go wrong. A
*terminal* state — one with no outgoing arrows — makes $\Box A$ vacuously true for
every $A$, since there is nothing to check. If you try to build a witness at a
terminal state you will always fail. Unwinding the definitions shows what a witness
always requires: a state $w$, a successor $v$ of it, and a successor $u$ of *that*,
with $v$ satisfying the proposition and $u$ failing it. An honest two-edge path,
with no terminal state until the end. Two edges is genuinely the minimum; the number
of *states* can be squeezed to two if one allows a cycle $0 \to 1 \to 0$, and the
three-state chain is the smallest loop-free realisation, in which the two-edge path
visits three distinct states.

## The coincidence that isn't

Now the second surprise. Look again at the grammar of reflective propositions:

$$A ::= p \mid X \mid \bot \mid \top \mid A \wedge A \mid A \to A \mid \Box A \mid \mu X.\,A .$$

A modal logician looking over your shoulder will say: that is the **modal
$\mu$-calculus**. Atoms, variables, falsum, verum, conjunction, implication,
necessity, and a least-fixed-point binder — the fragment of modal fixed-point logic
used to specify the behaviour of reactive and concurrent systems, and the setting in
which model-checking questions about infinite computations are posed.

The correspondence is not an analogy. Define a translation $\tau$ sending each
reflective constructor to its modal counterpart — atoms to atoms, bound variables to
fixed-point variables, $\bot$ to falsum, $\top$ to verum, pairing to conjunction,
function space to implication, reflection to necessity, and the fixed-point former to
$\mu$ — and define $\sigma$ running the other way by the same table read backwards.

**Theorem (Grammar isomorphism).** $\sigma(\tau(A)) = A$ for every reflective
proposition $A$, and $\tau(\sigma(\varphi)) = \varphi$ for every modal fixed-point
formula $\varphi$. The two languages are in bijection, and the bijection preserves
every constructor.

Both directions are structural inductions, and the isomorphism respects iteration:
translating an $n$-fold reflection $\Box^n A$ gives exactly the $n$-fold necessity of
the translation. Under $\sigma$, for instance, the modal formula $\mu X.\,\Box X$ —
"the least property closed under taking necessity", a canonical well-foundedness
assertion in verification — *is* the reflective proposition $\mu X.\,\Box X$, the
recursive type of things provable all the way down.

The honest reading of this theorem matters. It is an isomorphism of *grammars*, not a
claim that the two systems have the same theorems, and not a completeness result for
any proof calculus. But grammar isomorphism is precisely what licenses the transport
of *semantics* and *tools*: every model-checking algorithm, every complexity bound,
every automata-theoretic technique developed for the modal fixed-point language is
about the same syntactic objects as a reflective type theory's propositions. A
question about a program that reasons about its own evidence is a question about a
$\mu$-calculus formula, and can be handed to the machinery built for the latter.

## The one that got away

A good research cycle records its failures. The conjecture that did *not* survive was
this: every fixed-point proposition, with no restriction, should have a well-behaved
least-fixed-point meaning, obtained by iterating a monotone operator on sets of states
until it stabilises.

It fails, and the reason is variance. The operator induced by a formula is monotone
only when the bound variable occurs *positively*. Function space flips polarity: in
$X \to \bot$, the variable $X$ sits on the left of an arrow, so enlarging $X$
*shrinks* the interpretation. The associated operator is antitone, not monotone,
and the Knaster–Tarski theorem — the fixed-point engine — simply does not apply. There
is no least fixed point to speak of.

Notice the symmetry with the first half of the story. Two side conditions govern the
two forms of iteration on offer:

- **Transitivity** controls whether the *proof modality* may be iterated:
  $\Box A \to \Box \Box A$ holds exactly when reasoning composes.
- **Positivity** controls whether a *fixed point* may be reached by iteration:
  $\mu X.\,A$ has its intended meaning exactly when $X$ occurs with even polarity.

Both are constraints on how self-reference is allowed to fold back on itself, and in
both cases the unguarded version is not merely hard — it is false. The grammar
isomorphism, notably, needs neither guard: syntax is indifferent to variance. Meaning
is not.

## Where the diagonal enters

The last piece is the oldest one. Abstract away from syntax entirely: a *diagonal
theory* consists of a collection of sentences, a predicate "provable", a predicate
"true", the soundness assumption that provable sentences are true, and a distinguished
sentence $D$ satisfying the diagonal specification

$$\text{True}(D) \iff \neg\,\text{Provable}(D).$$

Nothing here mentions arithmetic, codes, or numerals; the specification is the whole
content of "$D$ says of itself that it is unprovable".

**Theorem (Diagonal incompleteness).** In any diagonal theory, $D$ is true and not
provable.

The argument is three steps and needs no machinery. If $D$ were provable, then by
soundness $D$ would be true; by the diagonal specification, being true means $D$ is
*not* provable — a contradiction. So $D$ is unprovable. But then the diagonal
specification, read in the other direction, says $D$ is true. Truth outruns
provability, and the gap is witnessed by a single sentence.

Placed next to the frame results, this completes the picture. The three-state chain
shows that provability can fail to be *self-transparent* — you can have it without
having it twice. The diagonal theorem shows that provability can fail to be
*exhaustive* — there are truths it does not reach. And the transitive impossibility
theorem shows that the first failure is not an accident of a badly chosen model but a
precise consequence of the shape of the reasoning relation: assume that reasoning
composes, and the failure vanishes.

## Why this is worth the trouble

Three concrete things come out of this.

For **type theory**, a reflective proposition former is not sugar. It is a genuinely
new constructor, and the proof of that is a retraction that no reformulation of the
inert language can defeat.

For **verification**, the isomorphism means that a system whose specifications
mention their own evidence is not exotic. It is a modal fixed-point specification in
disguise, and the entire toolkit for such specifications applies unchanged. This is
the kind of bridge that turns a research problem into an engineering one.

For **the philosophy of reasoning**, the three-state chain is a small, complete,
inspectable object showing that "if I can prove it, I can prove that I can prove it"
is a substantive assumption about the architecture of reasoning, not a triviality.
It says your reasoning steps compose. Systems with resource bounds, staged
compilation, layered trust, or bounded introspection routinely violate this — and the
moment they do, three states and two arrows suffice to exhibit a statement that is
established but not established-as-established.

The final shape of the story is a pair of guards and a bridge. Transitivity guards
the iteration of proof; positivity guards the iteration to a fixed point; and between
the language of self-aware propositions and the language of modal fixed points there
is not a similarity but an equality, constructor for constructor. Self-reference,
handled carefully, turns out to be a well-mapped country — provided you keep track of
which direction you are travelling in.
