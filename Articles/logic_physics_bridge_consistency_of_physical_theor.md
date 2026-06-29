# The Ghost in the Theory: Why a Working Physics Can Never Prove Its Own Innocence

Imagine you are handed the final, complete theory of everything. Every force,
every particle, every cosmic accident neatly accounted for in a single set of
equations. Before you stake the future of science on it, you ask the most basic
question a careful person can ask: *Is it consistent?* Could this theory, if
pushed hard enough, ever contradict itself — predict that a measurement is both
$0$ and $1$, that an electron both exists and does not?

It feels like the kind of question a sufficiently smart machine should be able
to settle. After all, the theory is just rules and symbols; surely we can check
whether the rules ever collide. The astonishing answer, sharpened over the last
century and made completely precise in the work described here, is this: **a
rich enough theory can never prove its own consistency, and ordinary
arithmetic — the bedrock under all of physics — cannot prove the consistency of
physics either.** The cleaner and more powerful your physical theory is, the
more thoroughly its own trustworthiness slips beyond the reach of the
mathematics it is built on.

This is not a gap in our cleverness. It is a theorem.

## From spacetime to syntax

The trick that makes this possible is to stop thinking about physics as a story
about the world and start thinking about it as a story about *proofs*. Any
physical theory worth its salt — Newtonian mechanics, general relativity,
quantum field theory — is, at bottom, a machine for deriving statements. You
feed in axioms (the field equations, the commutation relations, the conservation
laws) and out come theorems (the orbit of Mercury, the magnetic moment of the
electron, the spectrum of hydrogen). Strip away the physical interpretation and
what remains is a **proof system**: a collection of derivations, each ending in
some formula it establishes.

We can capture this abstractly. A proof system $S$ comes with a type of proof
objects, a function telling us which formula each proof concludes, and a measure
of each proof's size. A formula $f$ is **provable** in $S$, written
$\mathrm{Provable}(S, f)$, exactly when some proof in $S$ has $f$ as its
conclusion:
$$\mathrm{Provable}(S, f) \;:=\; \exists\, p,\; \mathrm{concl}(p) = f.$$

A theory is **consistent** when it does *not* prove the absurd formula $\bot$
("false"):
$$\mathrm{Consistent}(S) \;:=\; \neg\,\mathrm{Provable}(S, \bot).$$

An inconsistent theory is worthless: by the classical principle that anything
follows from a contradiction, a theory that proves $\bot$ proves *everything*,
and a theory that predicts everything predicts nothing.

Crucially, real physical theories don't float free of mathematics. They are
*built on top of it*. Quantum field theory presupposes the real numbers,
calculus, and ultimately the arithmetic of the natural numbers, codified in the
standard system **Peano Arithmetic** ($\mathrm{PA}$). We make this precise with
a single relation: $S$ **simulates** $T$, written $\mathrm{Simulates}(S, T)$,
when $S$ proves everything $T$ proves:
$$\mathrm{Simulates}(S, T) \;:=\; \forall f,\; \mathrm{Provable}(T, f)
\Rightarrow \mathrm{Provable}(S, f).$$

A **physical theory** $T$ is then nothing more exotic than a proof system that
*extends the mathematical base*: $\mathrm{Simulates}(T, \mathrm{PA})$. Physics is
mathematics with extra axioms.

## The first surprise: consistency flows downhill

With these definitions in place, the first result almost proves itself — and yet
it carries real philosophical weight.

> **Physical consistency implies mathematical consistency.** If a physical
> theory $T$ extends the mathematical base $\mathrm{PA}$ and $T$ is consistent,
> then $\mathrm{PA}$ is consistent.

Why? Suppose, for contradiction, that $\mathrm{PA}$ were *inconsistent* — that it
proved $\bot$. Because $T$ simulates $\mathrm{PA}$, $T$ proves everything
$\mathrm{PA}$ proves, so $T$ would prove $\bot$ too. But $T$ is consistent, so it
proves no such thing. Contradiction. Therefore $\mathrm{PA}$ is consistent after
all.

In the formal development this is a one-line argument, the contrapositive of the
simulation relation. But read it the right way and it says something profound:
**you cannot build a trustworthy physics on rotten mathematical foundations.** If
your physical theory is free of contradiction, then so is the arithmetic
underneath it — automatically, for free. Consistency flows *downhill*, from the
richer theory to the poorer one.

This even chains. If you have a whole tower of theories — a grand unified theory
$T$ extending an effective field theory $M$ extending arithmetic
$\mathrm{PA}$ — then consistency of the top automatically guarantees consistency
all the way to the bottom:

> **Consistency transfers down a tower.** If $T$ simulates $M$, and $M$
> simulates $\mathrm{PA}$, and $T$ is consistent, then $\mathrm{PA}$ is
> consistent.

The proof simply chains the two simulation relations into one (simulation is
transitive) and reuses the result above.

## The second surprise: it does not flow uphill

Here is where intuition fails most people. If consistency flows downhill, surely
it flows uphill too? If our trusty arithmetic is consistent, surely any sensible
physical theory built on it inherits that good behavior?

**No.** And we can prove it with a brutally simple counterexample.

> **Mathematical consistency does NOT imply physical consistency.** There exists
> a consistent mathematical base $\mathrm{PA}$ and a theory $T$ extending it
> that is nonetheless inconsistent.

The witnesses are two extreme proof systems. For the base, take the "box-true"
system $\mathsf{trueSys}$, which is consistent: it does *not* prove $\bot$. For
the physical theory, take the **trivial system** $\mathsf{trivialSys}$, which
proves *every* formula — including $\bot$. Because it proves everything, it
trivially proves everything $\mathsf{trueSys}$ proves, so it extends the base.
And because it proves $\bot$, it is inconsistent.

The lesson is stark. **Adding axioms to a consistent theory can break it.** A
physicist who bolts a new symmetry, a new field, or a new boundary condition onto
a perfectly consistent mathematical core is taking a real risk: the enlarged
theory may quietly become contradictory, and no amount of consistency in the
foundations will save it. Consistency is fragile in exactly the direction we most
care about — the direction of doing more physics.

So the relationship between physical and mathematical consistency is genuinely
*asymmetric*. Downhill: free and automatic. Uphill: false, and provably so.

## The third surprise: the question is invisible to arithmetic

Now we arrive at the heart of the matter, and at a circle of ideas that goes back
to Kurt Gödel in 1931. Suppose your physical theory $T$ really *is* consistent.
Can the underlying arithmetic $\mathrm{PA}$ *prove* that it is?

To even ask this, we need arithmetic to be able to *talk about* provability. This
is the great discovery of Gödel: a sufficiently strong theory can encode
statements about its own proofs as statements about numbers. We write
$\Box_i\,a$ for the formula "theory $i$ proves $a$." The consistency of theory
$i$ then becomes a single sentence:
$$\mathrm{Con}_i \;:=\; \Box_i \bot \to \bot,$$
read as "if theory $i$ proves falsity, then falsity holds" — equivalently, "theory
$i$ does *not* prove falsity." Consistency, once an external judgment about a
theory, becomes an internal *sentence* the theory can contemplate.

The behavior of the provability operator $\Box$ is governed by the elegant modal
logic **GL** (for Gödel–Löb). A GL theory is closed under modus ponens (from $a$
and $a \to b$, derive $b$) and necessitation (if you prove $a$, you can prove
$\Box a$), and it satisfies the celebrated **Löb axiom**
$\Box(\Box a \to a) \to \Box a$. From these few ingredients flows the entire
incompleteness phenomenon. The keystone is **Löb's theorem**, here proved as a
derived rule:

> **Löb's rule.** If a GL theory proves $\Box a \to a$, then it already proves
> $a$.

The slogan is almost paradoxical: *if a theory can prove that proving $a$ would
make $a$ true, then it can just prove $a$ outright.* The proof is a tight
three-step dance of necessitation, the Löb axiom, and modus ponens.

Set $a = \bot$ and watch what happens. The statement $\Box \bot \to \bot$ is
exactly $\mathrm{Con}_i$. Löb's rule says: if the theory proves $\mathrm{Con}_i$,
then it proves $\bot$ — that is, it is inconsistent. Contrapositive:

> **Gödel's Second Incompleteness Theorem (abstract form).** A consistent GL
> theory does not prove its own consistency sentence $\mathrm{Con}_i$.

A consistent theory cannot certify its own innocence. The moment it does, it is
guilty.

This already tells us that arithmetic cannot prove $\mathrm{Con}(\mathrm{PA})$.
But what about $\mathrm{Con}(T)$, the consistency of the *physical* theory? Here
the bridge result of this work ties everything together:

> **If $T$ is consistent, then $\mathrm{Con}(T)$ is independent of
> $\mathrm{PA}$.** Suppose $\mathrm{PA}$ is a consistent GL theory and $T$ is a
> consistent theory. Assume two mild, physically reasonable conditions:
> (1) arithmetic verifies the interpretation, meaning
> $\mathrm{PA} \vdash \mathrm{Con}(T) \to \mathrm{Con}(\mathrm{PA})$ — true
> whenever $T$ extends $\mathrm{PA}$ in a way arithmetic can recognize; and
> (2) arithmetic is sound about $T$'s consistency, meaning if $\mathrm{PA}$ ever
> proved $\neg\,\mathrm{Con}(T)$ then $T$ really would be inconsistent. Then
> $\mathrm{PA}$ proves neither $\mathrm{Con}(T)$ nor $\neg\,\mathrm{Con}(T)$.

The two halves pull in opposite directions, and both land.

*Why can't arithmetic prove $\mathrm{Con}(T)$?* Because of condition (1): a proof
of $\mathrm{Con}(T)$ inside $\mathrm{PA}$ would immediately yield a proof of
$\mathrm{Con}(\mathrm{PA})$ — arithmetic proving its *own* consistency. Gödel's
Second Theorem forbids exactly that. So $\mathrm{PA} \nvdash \mathrm{Con}(T)$.

*Why can't arithmetic prove $\neg\,\mathrm{Con}(T)$?* Because of condition (2): if
it did, then $T$ would actually be inconsistent. But we assumed $T$ *is*
consistent. So $\mathrm{PA} \nvdash \neg\,\mathrm{Con}(T)$.

Caught between these two impossibilities, the consistency of a working physical
theory is **independent** of arithmetic: undecidable, suspended, neither
provable nor refutable by the mathematics it rests upon. The question "is our
physics consistent?" is not merely *unanswered* by arithmetic — it is
permanently *unanswerable* within it.

## Is this just a trick of self-reference?

A natural worry: maybe $\mathrm{Con}(T)$ is secretly the same sentence as
$\mathrm{Con}(\mathrm{PA})$ in disguise, and we have only rediscovered Gödel's
original theorem with extra steps. The formal framework rules this out by giving
each theory its *own index*. The provability operator $\Box_p$ of arithmetic and
the operator $\Box_t$ of the physical theory are genuinely different symbols, so
$\mathrm{Con}_p$ and $\mathrm{Con}_t$ are genuinely different formulas. The
independence is *cross-theory*: one theory speaking about another's consistency,
not a theory tripping over its own shoelaces.

And the result is not an empty abstraction. It is **witnessed concretely**. Take
the standard finite Kripke model $\mathsf{stdSys}$ — a small, fully computable
structure — for both roles. One checks directly that it satisfies all the
hypotheses, and concludes that $\mathsf{stdSys}$ proves neither $\mathrm{Con}_t$
nor its negation. The independence theorem has real inhabitants, not just empty
promises.

There is even a delicate boundary here. The independence has *two* sources. That
a consistent theory can't prove $\mathrm{Con}$ needs only consistency. That it
also can't *refute* $\mathrm{Con}$ needs something more — a property called
**$\Sigma_1$-soundness**, roughly that the theory doesn't prove false claims of
the form "such-and-such a computation halts." The "box-true" model
$\mathsf{trueSys}$ is the cautionary tale: it is consistent, but *not*
$\Sigma_1$-sound, and it actually proves $\neg\,\mathrm{Con}$ — it loudly
(and wrongly) declares its own inconsistency. The standard model
$\mathsf{stdSys}$, by contrast, is $\Sigma_1$-sound, and for it consistency is
truly independent. The two models sit side by side, marking the exact frontier
where independence begins.

## What this means

Step back and the picture is both humbling and clarifying.

First, **good physics protects good mathematics, but never the reverse.** A
consistent theory of nature guarantees the soundness of its arithmetic
foundations for free. But no amount of arithmetic hygiene guarantees that the
physics built atop it won't contradict itself. The risk always lives in the new
axioms.

Second, **the consistency of a fundamental physical theory is, of mathematical
necessity, an act of faith.** Not because physicists are careless, but because
the consistency of a theory strong enough to contain arithmetic is strictly
stronger than arithmetic itself — one full "consistency step" beyond it — and so
escapes arithmetic's proving power entirely. We can test a theory against
experiment forever and never find a contradiction; that is evidence, not proof.
The proof of consistency is the one theorem the theory can never supply about
itself.

Third, and most beautifully, **this is not a defect to be engineered away.** It
is a structural feature of any framework rich enough to describe a universe that
contains its own describers. The same self-reference that lets a theory talk
about its own provability is exactly what forbids it from vouching for its own
consistency. The ghost of Gödel haunts the foundations of physics not as a bug,
but as a law.

So the next time someone promises you a final theory of everything, you may
admire it, test it, even believe it. But if they tell you they have *proved* it
free of contradiction using nothing but the mathematics inside it, you now know
something they may not: that, if the theory is as strong as it claims, such a
proof is impossible. The theory can describe the cosmos. It just can't prove its
own innocence.
