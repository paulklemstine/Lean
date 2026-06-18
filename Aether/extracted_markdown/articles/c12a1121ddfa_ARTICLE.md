# How to Build a Mind That Survives a Contradiction

## The day logic refused to break

Imagine a customer-service database for an airline. One feed says your
flight is *on time*. Another feed, updated thirty seconds later by a
different system, says the same flight is *cancelled*. The two reports
flatly contradict each other. What should the computer conclude?

If the computer reasons with ordinary, classical logic, the answer is a
catastrophe. Classical logic contains a tiny, innocent-looking rule with
an explosive name: *ex falso quodlibet* — "from a falsehood, anything
follows." Once a classical system believes both a statement and its
negation, it can prove **every** statement whatsoever. Your flight is
cancelled. Your flight is on time. The moon is made of cheese. You owe
the airline nine billion dollars. Every conclusion becomes equally
"provable," and the database is, in the precise technical sense,
useless. One bad data feed has turned the entire knowledge base into
noise.

This is not a hypothetical nuisance. Real databases, sensor arrays,
crowd-sourced encyclopedias, merged medical records, and large AI
knowledge bases all routinely contain contradictions. They contain them
*right now*, as you read this. If contradictions really did make
everything provable, none of these systems could function. So either the
engineers are getting very lucky, or classical logic is the wrong tool.

In 1977 the philosopher and logician Nuel Belnap published a short,
famous paper with a provocative title: *How a Computer Should Think.* His
answer was to give the computer not two truth values but **four**. The
resulting system — now universally called **Belnap's FOUR** — is the
smallest logic that can stare a contradiction in the face and keep
working. This article is about what those four values are, why exactly
four is the magic number, and a clean piece of mathematics showing that
FOUR is, in a precise sense, simply *two copies of "yes/no" glued
together at right angles*.

## Four answers to a yes/no question

Belnap's insight starts from a simple observation. When you ask a
database "Is the flight cancelled?", you are really asking it to
summarize all the evidence it has collected. And evidence comes in two
independent channels:

- **Evidence *for*** the statement (someone told the system "yes").
- **Evidence *against*** the statement (someone told the system "no").

In classical logic these two channels are assumed to be perfect mirror
images: if there's evidence for, there's no evidence against, and vice
versa. But a real, messy world does not respect that assumption. The two
channels can each independently be *on* or *off*, which gives four
combinations — and therefore four genuinely different epistemic states:

| Evidence for | Evidence against | Belnap value | Meaning |
|---|---|---|---|
| no  | no  | **N** (None)   | We've heard *nothing* — total ignorance |
| no  | yes | **F** (False)  | Told only "no" — classically false |
| yes | no  | **T** (True)   | Told only "yes" — classically true |
| yes | yes | **B** (Both)   | Told *both* "yes" *and* "no" — a contradiction |

The two new values are the heroes of the story. **N** ("None," sometimes
"Neither") is the value of a question nobody has answered: a *gap* in
knowledge. **B** ("Both") is the value of a question two sources have
answered in opposite ways: a *glut* of conflicting knowledge. Classical
logic, with only T and F, has no way to record either situation. It
cannot tell the difference between "we have no idea" and "we have a
contradiction," and it cannot tell either of those apart from a confident
true or false. FOUR keeps all four states distinct, and that single act
of bookkeeping is what tames the explosion.

## The contradiction that doesn't spread

Here is the heart of the matter, stated as plainly as possible.

To *use* a logic for reasoning, you have to decide which values count as
"good enough to assert." In FOUR, the **designated** values — the ones a
system is willing to act on — are **T** and **B**. Both of these contain
positive evidence *for* the statement; the difference is only whether
there is *also* evidence against. So when the system asserts something,
it is saying "I have grounds to claim this," while remaining honest about
whether those grounds are contested.

Now watch what happens to negation. In FOUR, negating a value swaps its
two channels — evidence-for becomes evidence-against and vice versa. So:

- The negation of **T** (for, not-against) is **F** (against, not-for).
- The negation of **F** is **T**.
- The negation of **N** is **N** — total ignorance about a statement is
  total ignorance about its negation.
- The negation of **B** (both) is **B** — a fully contradicted statement
  has a fully contradicted negation.

That last line is the whole ballgame. The value **B** is designated, and
its negation is *also* **B**, which is *also* designated. So the premise
"this statement is assertible **and** its negation is assertible" is
genuinely **satisfiable** in FOUR — the value B witnesses it.

Compare classical logic. There, "b is true and not-b is true" can never
happen: no Boolean value equals both `true` and `false`. The classical
contradiction premise is *unsatisfiable* — it describes a situation that
literally cannot occur. And that is the secret of explosion: classical
logic validates "from a contradiction, anything follows" only
**vacuously**, because the contradiction it's talking about never arises.
It's a promise about a situation that never happens.

FOUR breaks the spell precisely because in FOUR the contradiction
*does* happen, at the value B — and yet nothing explodes. We can have a
designated value (B) with a designated negation (B) while some other
statement sits quietly at **F**, undesignated and unprovable. The
inference "designated and designated-negation, therefore *anything*"
simply fails. A contradiction about your flight does **not** prove that
the moon is cheese. The contradiction is *quarantined* to the statements
it actually touches.

This property has a name: **paraconsistency**. A paraconsistent logic is
one in which contradictions do not entail everything. Belnap's FOUR is
the smallest non-trivial paraconsistent logic, and the reasoning above is
exactly why. The lesson is crisp and worth memorizing:

> **Explosion is the gap between a *satisfiable* contradiction and a
> *valid* one. Classical logic closes the gap by making contradictions
> impossible; FOUR keeps the gap open by giving contradictions a home.**

## Two orders, at right angles

So far FOUR looks like a clever list of four labels. The deeper structure
— the reason mathematicians find it beautiful rather than merely useful —
is that those four values are organized by **two different orderings at
the same time**, pulling in perpendicular directions.

The first is the **truth order**. It ranks values by *how true* they are,
in the sense of formal-deductive entailment. At the bottom sits **F**
(thoroughly false); at the top sits **T** (thoroughly true). The two
mixed values **N** and **B** sit in the middle, incomparable to each
other: a gap and a glut are each "half true," but neither is truer than
the other. Moving *up* the truth order can only ever turn a
non-assertible value into an assertible one, never the reverse — which is
exactly what we want "more true" to mean. (This is no accident: the truth
order *is* the entailment relation of First-Degree Entailment, the famous
relevance logic that FOUR characterizes.)

The second is the **knowledge order** (also called the *information*
order). It ranks values by *how much we know*, regardless of which way
that knowledge points. At the bottom sits **N** (we know nothing); at the
top sits **B** (we know *everything anyone said*, contradictions
included). The two classical values **T** and **F** sit in the middle:
each represents exactly one piece of consistent information, so they hold
the same *amount* of knowledge while disagreeing about its content.

These two orders are genuinely independent. Climbing the truth order is
not the same as climbing the knowledge order; each contains a
relationship the other lacks. (For instance F sits *below* T in truth but
*beside* it in knowledge; N sits *below* T in knowledge but *beside* it
in truth.) A structure carrying two such interlocking lattice orders is
called a **bilattice**, a notion introduced by Matthew Ginsberg in the
1980s to unify reasoning systems across artificial intelligence. FOUR is
the founding example — and, it turns out, the smallest one possible.

## FOUR is just "yes/no" squared

Now comes the punchline that ties everything together with a bow. We said
each Belnap value is really a pair: (evidence-for, evidence-against),
where each coordinate is an ordinary Boolean yes/no. That suggests an
exact dictionary between Belnap's four values and the four pairs of bits:

```
N ↦ (no,  no)      F ↦ (no,  yes)
T ↦ (yes, no)      B ↦ (yes, yes)
```

This dictionary is a perfect, reversible translation — a *bijection*.
Translate any Belnap value into its bit-pair and back, and you get
exactly what you started with. So FOUR has precisely **2 × 2 = 4**
elements, no more and no fewer. Four is not an arbitrary design choice; it
is forced the moment you decide to track two independent yes/no channels.

But the dictionary does far more than count. Every operation of FOUR
turns into a simple, coordinate-by-coordinate Boolean operation on the
bit-pairs:

- The **knowledge order** becomes the plain product order: one pair holds
  more knowledge than another exactly when it has at least as much
  evidence in *both* channels. The knowledge meet and join are just
  bitwise AND and OR.
- The **truth order** becomes a *twisted* product order: more true means
  more evidence-for **and** *less* evidence-against. The second
  coordinate runs backwards.
- **Negation** is simply *swapping the two coordinates* — for and against
  trade places, exactly as we described.
- A second natural involution called **conflation**, which dualizes
  *knowledge* rather than truth, is swap-then-flip.

In the language of bilattice theory this says FOUR *is* the product
bilattice **2 ⊙ 2** — "two glued to two" — built from the two-element
lattice 2 = {no, yes} paired with itself, one copy reading forward
(evidence for truth) and one reading backward (evidence against). Every
fact about Belnap's logic, however subtle it looks at the level of the
four labels, is really a fact about two independent coins, each showing
heads or tails. The richness of four-valued reasoning is the richness of
a 2×2 grid.

This is why FOUR is canonical rather than ad hoc. You don't *invent*
four-valued logic; you *discover* it the moment you accept that "for" and
"against" are independent. And you cannot do the job with fewer values:
paraconsistency requires a value (B) that is designated alongside its
designated negation, gaps require a value (N) distinct from it, and once
you have N and B you are committed to all four corners of the square.

## Why this matters outside the seminar room

Belnap's four values quietly run underneath a great deal of modern
information technology. Database theory uses them to give meaning to
NULL-laden tables where some facts are missing (gaps) and federated views
where sources disagree (gluts). Knowledge-graph and ontology systems use
paraconsistent reasoning so that one inconsistent triple cannot corrupt
an entire graph. Truth-maintenance systems in classical AI, sensor-fusion
pipelines that merge contradictory readings, and even some approaches to
making large language-model knowledge bases robust all rest on the same
foundational move: *refuse to let a local contradiction become a global
collapse.*

The mathematics tells us we are not improvising when we do this. There is
a smallest, cleanest, most symmetric way to reason about evidence that can
be present, absent, one-sided, or conflicting — and it is Belnap's FOUR,
the bilattice 2 ⊙ 2. It is the logic of an honest machine: one that knows
the difference between *I don't know*, *yes*, *no*, and *it's
complicated* — and that, faced with the worst the data can throw at it,
declines to lose its mind.
