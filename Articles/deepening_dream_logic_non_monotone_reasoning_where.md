# Dream Logic: A Mathematics Where Contradictions Can Coexist

## When "true and false at once" is a feature, not a bug

Close your eyes and remember a dream. Perhaps you were walking through
your childhood home, except it was also a train station, and the person
across from you was simultaneously your best friend and a stranger. In
the dream, none of this felt wrong. Impossible objects coexisted
peacefully. Only on waking did the contradictions announce themselves.

Classical logic — the logic that underpins nearly all of mathematics —
cannot dream. It obeys a ruthless law called *explosion*: from a single
contradiction, **everything** follows. If you can prove both $p$ and its
negation $\neg p$, then classical logic lets you prove that the moon is
made of cheese, that $2 + 2 = 5$, and that it doesn't. One inconsistency
and the whole edifice collapses into triviality. This is why
mathematicians treat contradiction as catastrophe.

But real reasoning — the kind humans do while dreaming, while holding
conflicting beliefs, while reading a database that contradicts itself —
is not so fragile. We routinely encounter contradictory information
without concluding that the moon is cheese. We *quarantine* the
contradiction and keep reasoning sensibly around it.

This article is about the mathematics of that quarantine. It is a logic
built for dream-like reasoning: **paraconsistent** (contradictions do
not explode), **paracomplete** (statements may be neither true nor
false), and **non-monotone** (beliefs, once held, can be retracted). At
its heart is a beautiful little algebraic object with four truth values,
and a surprising bridge to the geometry of space itself.

## Four truth values instead of two

The first move is to abandon the dogma that every statement is exactly
true or exactly false. Instead we allow **four** verdicts, corresponding
to the four possible states of evidence one could have about a claim:

- **true** ($\mathbf{t}$) — you have evidence *for* it and none against;
- **false** ($\mathbf{f}$) — you have evidence *against* it and none for;
- **both** ($\top$) — you have evidence *for and against* at once; a
  **glut**, the mathematical incarnation of an impossible object;
- **neither** ($\bot$) — you have *no evidence either way*; a **gap**, an
  undetermined claim.

The glut $\top$ is the dream's impossible object: the friend who is also
a stranger. The gap $\bot$ is the part of the dream that never resolved.
Ordinary true and false are still there, but they are no longer the only
options.

What makes these four values sing is that they carry **two different
orderings at once**, and the interplay between them is the whole story.

## Two orders, one structure

The first ordering measures **how true** a value is. Call it the *truth
order*. At the bottom sits false; at the top sits true; and the glut and
the gap float in the middle, incomparable to each other — one is not
"truer" than the other. Along this order, "and" ($\wedge$) takes the
lower of two values and "or" ($\vee$) takes the higher, exactly as in
ordinary logic.

The second ordering measures **how much you know** — how much
information a value carries. Call it the *knowledge order*. Now the gap
(no information) sits at the bottom, the glut (maximal, even
over-determined, information) sits at the top, and plain true and plain
false float incomparably in the middle — each is one honest bit of
information, neither more informative than the other. Along this order
there are two more operations: **consensus** ($\otimes$), which keeps
only what two sources agree on, and **gullibility** ($\oplus$), which
credulously accepts whatever either source claims.

Picture the four values at the corners of a diamond. Read the diamond
bottom-to-top one way and you see falsehood rising to truth; rotate your
gaze ninety degrees and you see ignorance rising to over-information.
This doubly-ordered diamond is the smallest nontrivial **interlaced
bilattice**, and it is the mathematical home of dream logic.

The word *interlaced* names the crucial harmony between the two orders.
Each of the four operations is **monotone in the other order**: if you
increase your inputs in the knowledge order, then their conjunction and
disjunction do not decrease in the knowledge order either; and dually,
increasing inputs in the truth order never decreases their consensus or
gullibility in the truth order. Formally, for all values $a,b,c,d$,

$$a \le_k b \ \text{and}\ c \le_k d \ \Longrightarrow\ (a \wedge c) \le_k (b \wedge d),$$

and three symmetric statements for $\vee$, $\otimes$, $\oplus$. These
four interlacing laws are the axioms that make the two lattices cohere
into a single organism rather than two unrelated structures sharing a
carrier. We prove all four hold.

There are also two symmetries. **Negation** ($\neg$) swaps true and
false but leaves the glut and the gap untouched — because if you have
evidence both ways, negating the claim still leaves you with evidence
both ways. Negation flips the truth order upside down (De Morgan's laws,
$\neg(a\wedge b)=\neg a \vee \neg b$) while *preserving* the knowledge
order: it is an anti-automorphism of one lattice and an automorphism of
the other. Its mirror image, **conflation**, swaps the glut and the gap
while fixing true and false, and does the opposite: it flips the
knowledge order while preserving the truth order. The two symmetries
commute. This elegant duality — negation and conflation as reflections
of the diamond across its two axes — is the signature of the bilattice.

## Why contradictions stop exploding

Here is the payoff. Declare a value **designated** — "accepted as at
least true" — when it is either plain true or a glut. A statement is
*asserted* by a model when its value is designated. Now watch what
happens to a contradiction.

Give a proposition $p$ the value glut ($\top$). Then $p$ is designated.
Its negation $\neg p$ is also $\top$ (negation fixes the glut), so
$\neg p$ is designated too. Both $p$ and $\neg p$ are accepted — the
contradiction lives. But their conjunction $p \wedge \neg p$ is still
just $\top$, which is designated yet is **not** at the top of the truth
order. It does not sit above an arbitrary false statement. So from
"$p$ and not-$p$" you cannot climb to an arbitrary conclusion $q$. The
contradiction is real, and it is *contained*. Explosion fails.

We make this precise as a genuine **consequence relation**. Build
formulas from atoms using $\neg, \wedge, \vee$; evaluate them in the four
values under an assignment of truth values to atoms; and declare
$\Gamma \vDash \varphi$ ("the premises $\Gamma$ entail $\varphi$") to
mean that every assignment designating all of $\Gamma$ also designates
$\varphi$. This relation is a bona fide logic: it satisfies

- **Reflexivity** — a premise entails itself;
- **Weakening** — adding premises never destroys an entailment;
- **Cut** — entailments chain together transitively;

the three structural pillars of any respectable deductive system. On top
of these, conjunction and disjunction behave exactly as their lattice
meanings demand ($\wedge$-introduction and elimination, $\vee$-introduction),
and the De Morgan laws are valid entailments.

Yet three classical "laws" gracefully fail, and each failure is exactly
what dream reasoning needs:

- **Explosion fails.** With two distinct atoms $p \ne q$, the premises
  $\{p, \neg p\}$ do **not** entail $q$. (Witness: send $p$ to the glut,
  $q$ to false.) A contradiction does not trivialize the world.
- **Excluded middle fails.** The statement $p \vee \neg p$ is not a
  validity. (Witness: send $p$ to the gap; then $p \vee \neg p$ is still
  the gap, undesignated.) Some claims are genuinely unsettled.
- **Non-contradiction fails.** Even $\neg(p \wedge \neg p)$ is not a
  validity. (Witness: send $p$ to the gap again.) Contradictions are not
  merely tolerated as undecided — they are permitted to be actively true.

This is not broken logic. It is logic that has learned to dream.

## The astonishing bridge to geometry

Now the story takes an unexpected turn. Where do gluts *come from*? Why
should any natural situation force a statement to be true and false at
once? The answer lies in the shape of space.

Model a proposition as a region $A$ of a space $X$ — the set of points
where the proposition holds. Define its negation geometrically as the
**closure of the complement**:

$$\neg A = \overline{\,A^{c}\,},$$

the set of all points that are outside $A$ *or infinitesimally close to
being outside*. This closure operation is what makes the logic
non-classical: taking closures adds the boundary back in.

With this definition, several things happen at once, and each is a
theorem we prove for an *arbitrary* topological space:

- **Excluded middle survives.** For every region, $A \cup \neg A = X$.
  Together, a proposition and its negation always cover all of space.
- **A glut is exactly a boundary point.** For a closed region $A$, the
  points where $A$ and $\neg A$ *coexist* are precisely the **frontier**
  (topological boundary) of $A$:
  $$A \cap \neg A = \partial A.$$
  An impossible object is a point sitting on the razor's edge between a
  region and its outside — inside the region, yet arbitrarily close to
  the outside.
- **Double negation returns you home.** For closed regions,
  $\neg\neg A \subseteq A$: negating twice cannot take you beyond where
  you started.

And then the sharp characterization, the theorem that ties the logic to
the geometry with a bow:

> **A closed proposition harbours a contradiction if and only if it is
> not open.**

In symbols, $A \cap \neg A \ne \varnothing$ exactly when $A$ is closed
but fails to be open — that is, exactly when $A$ has a nonempty
boundary. Gluts are the mathematical shadow of boundaries. In a space
where every closed set is also open (a *discrete-like* space with no
boundaries), no contradiction can ever arise and the logic collapses
back to the classical two-valued case. It is precisely the failure of
open sets to be closed — the existence of genuine boundaries — that
gives dream logic its dreams.

The deepest version makes the connection to *non-monotone* reasoning
concrete. In any reasonable space (one where distinct points can be
separated), take a sequence of distinct points $x_1, x_2, x_3, \dots$
marching toward a limit point $p$ that is not among them. Each singleton
$\{x_n\}$ is a closed proposition — an honest, settled fact. But their
infinite union

$$\{x_1\} \cup \{x_2\} \cup \{x_3\} \cup \cdots$$

is **not** closed: it is missing its own limit point $p$. Here is the
crux. A collection of individually true propositions, gathered together
without limit, can produce something that is *no longer true in the same
sense* — it fails to be a settled, closed proposition. Adding more and
more established facts changes the character of their totality. That is
exactly what non-monotonicity means: growing the premises can withdraw a
conclusion. The retraction of belief, the hallmark of dreaming and of
common-sense reasoning alike, is written into the topology of limits.

## Why any of this matters

Paraconsistent reasoning is not a philosophical curiosity. Every large
database eventually contradicts itself; every legal code contains
conflicting statutes; every scientific field passes through periods where
its best theories disagree. A reasoning system built on classical logic
must, in principle, regard all of these as equally catastrophic — from
one contradiction, anything follows. In practice we patch around this,
but the patches are ad hoc. Dream logic offers a principled alternative:
a mathematics in which a local contradiction stays local, in which "I
don't know" and "it's complicated — both" are first-class answers, and
in which conclusions can be honestly withdrawn as evidence accumulates.

The four-valued diamond at its center is among the most economical
structures in all of logic — four points, two orders, two symmetries —
and yet it captures, exactly, the difference between the waking mind that
fears contradiction and the dreaming mind that lives comfortably inside
it. That the same structure surfaces again in the geometry of
boundaries, where an impossible object turns out to be nothing more
exotic than a point on the edge of a set, is the kind of unity that
makes mathematics feel less like invention and more like discovery.

We do not usually get to prove things about dreams. Here, remarkably,
we can.
