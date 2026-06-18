# The Shape of an Indivisible Mind: Measuring Integration with Tensor Networks

## A number for "more than the sum of its parts"

Some systems can be cleanly taken apart. A library is just a collection of
books; remove half the shelves and the other half are unchanged. Other systems
resist this kind of decomposition. Cut a living brain in two and you do not get
two smaller brains working independently — you get something broken, because the
whole depended on connections that crossed the line where you made the cut.

The neuroscientist Giulio Tononi turned this intuition into a research program
called **Integrated Information Theory** (IIT). Its central quantity is a single
number, written **Φ** (the Greek letter "phi"), that is meant to measure how much
a system is *more than the sum of its parts*. A pile of disconnected components
has Φ = 0. A tightly woven, genuinely unified system has large Φ. Tononi's bold
claim is that Φ measures something like the amount of consciousness a system has.

The philosophical claim is contested, and we will not defend it here. But the
*mathematical* idea underneath it is precise, beautiful, and — it turns out —
deeply connected to one of the most successful tools in modern quantum physics:
the **tensor network**. This article is about that connection. We will show how
to give IIT's Φ an exact, computable, provably-correct definition for quantum
states, and we will prove a sharp theorem about it: how much integration a
quantum system can hold is capped by a single architectural number called the
*bond dimension*, and that cap is exactly achievable.

Everything stated below has been verified by a formal proof checker, so the
theorems are not conjectures or numerical observations — they are certified
mathematics. But you will not need to read a line of formal logic to follow the
story.

## The trouble with cutting

To measure how integrated a system is, IIT proposes a procedure that sounds
almost paradoxical: *look for the easiest way to break the system, and report how
much breaking still costs.*

Imagine you must split a system into two non-empty groups of parts — a
**bipartition**, or **cut**. For each possible cut, you measure how much
information is lost when the two halves are forced to act independently. Some cuts
slice through the heart of the system and destroy a great deal; others fall along
natural seams and barely matter. IIT defines Φ as the loss across the *gentlest*
possible cut — the **Minimum Information Partition**, or MIP.

Why the minimum? Because a system is only as integrated as its weakest seam. If
*any* cut separates the system at almost no cost, then the system was never really
whole: it had a fault line, and Φ should be small. Only a system with *no* cheap
cut — one that is expensive to break no matter where you slice — earns a large Φ.

This is a worst-case definition turned into a virtue. The hard part, and the
mathematically interesting part, is that the cuts are not independent. They are
all views of the same underlying object, so lowering the cost of one cut may be
impossible without paying somewhere else. The minimum over all cuts is therefore
a genuine, constrained optimization — and that is exactly what makes Φ informative.

## Enter the tensor network

So far this is abstract. To make it concrete we need a precise notion of "a
system" and "the cost of a cut." Quantum information theory provides a perfect
one.

A quantum system built from several parts is described by a *state* — a vast
table of complex-number amplitudes, one for every combination of the parts'
configurations. For *n* parts this table is an *n*-dimensional array, a **tensor**.
Physicists call the bookkeeping device that organizes such tensors a **tensor
network**, and tensor networks are the workhorses of modern condensed-matter
physics, quantum chemistry, and quantum computing simulation.

Now fix a single cut, splitting the parts into a group *A* and the rest. We can
flatten the whole amplitude tensor into an ordinary rectangular matrix *M*: its
rows indexed by the configurations of *A*, its columns by the configurations of
everything else. This matrix encodes exactly how the two sides of the cut are
correlated.

The decisive quantity is the **Schmidt rank** of the state across that cut —
which is simply the *rank* of the matrix *M*, the number of independent rows (or
columns). The Schmidt rank is the gold-standard measure of entanglement across a
cut:

- **Schmidt rank 1** means the matrix is a single outer product. The state
  *factorizes*: the two sides are independent, a *product state*, with no
  entanglement at all across that cut.
- **Schmidt rank larger than 1** means the sides are genuinely entangled, and the
  larger the rank, the more entangled they are.

This is the quantum cost of the cut, and it gives us our definition. Define the
single-cut integrated information of a state with coefficient matrix *M* to be

> **Φ_cut(M) = (Schmidt rank of M) − 1.**

The "−1" is the crucial calibration: a product state (rank 1) gets Φ_cut = 0, in
exact agreement with IIT's demand that an unentangled, decomposable system carry
no integration. Every additional unit of Schmidt rank adds one unit of integrated
information.

## From one cut to all cuts

The single-cut quantity only sees one bipartition. A real *n*-party system can be
cut in many ways — for three parts *{1,2,3}* the non-trivial cuts are
*{1}|{2,3}*, *{2}|{1,3}*, and *{3}|{1,2}* — and IIT insists we take the *minimum*
over all of them. So we package the Schmidt rank across *every* non-trivial cut
into a single object, which we call the **cut data** of the state, and define the
**multi-cut integrated information**:

> **Φ = the minimum, over every non-trivial bipartition A, of (Schmidt rank
> across A) − 1.**

This is the quantum, tensor-network incarnation of Tononi's MIP. With this
definition in hand, the structural laws that IIT *postulates* about Φ become
*theorems* — statements we can prove rather than assume. Here are the ones we
established.

**1. Φ is a true lower bound, and the best one.** No cut has integrated
information below Φ (by construction, Φ is the minimum). More subtly, Φ is the
*greatest* lower bound: if some number *c* is below every cut's value, then *c* is
below Φ. In short, Φ is exactly the floor of the entanglement landscape — neither
too low nor too high.

**2. The Minimum Information Partition exists.** There is always an actual cut
that *achieves* the minimum. Φ is not an unreachable infimum; it is realized by a
concrete bipartition, the system's weakest seam. This sounds obvious but matters:
it means the MIP is a real object you can point to and study.

**3. Reducibility has an exact signature.** A system has **Φ = 0 if and only if it
is a product state across at least one cut** — that is, if and only if some
bipartition has Schmidt rank exactly 1. This is the clean dividing line between
"integrated" and "decomposable." A system is reducible precisely when there exists
a seam along which it falls into two independent pieces. This is the quantum mirror
of IIT's foundational axiom that a reducible system has no integrated information.

**4. More entanglement, more integration.** If one state has Schmidt rank no
larger than another across *every* cut, then its Φ is no larger either. Integrated
information is *monotone* in entanglement: you cannot increase Φ by reducing
entanglement anywhere.

## The headline: bond dimension is a hard ceiling — and it is tight

The deepest result concerns the **bond dimension**, the single number that
controls the expressive power of a tensor network.

When physicists build a tensor network — for instance a *matrix product state*, or
MPS, the one-dimensional chain that underlies the celebrated DMRG algorithm — they
connect neighboring tensors through internal "bond" indices. The size of those
internal indices, the **bond dimension** *D*, is the network's central
resource-knob. A small *D* makes the network cheap to store and fast to compute
with; a large *D* makes it expressive enough to capture heavy entanglement. The
entire art of tensor-network methods is trading off *D* against accuracy.

There is a folk theorem that bond dimension limits entanglement. We made it exact,
in the language of integrated information:

> **Bond-dimension bound.** If the Schmidt rank across *every* cut is at most the
> bond dimension *D*, then **Φ ≤ D − 1.**

A network you can squeeze through bonds of size *D* simply *cannot* carry more than
*D − 1* units of integrated information. Architecture caps consciousness, if you
are willing to read it that way. As an immediate corollary — the explicit test
case that motivated this work — a **bond-dimension-2** tensor network, the
simplest non-trivial MPS, satisfies

> **Φ ≤ 1.**

The simplest entangled architecture permits exactly one unit of integration and no
more.

A bound is only interesting if it is sharp. Could the true maximum be smaller —
could there be some hidden obstruction that prevents a bond-*D* network from ever
reaching *D − 1*? No. We proved the bound is **attained**:

> **Tightness theorem.** Consider the *maximally entangled* network, whose Schmidt
> rank equals *D* across *every* cut. Its integrated information is exactly
> **Φ = D − 1.**

Since every cut has the same value *D − 1*, the minimum over cuts is *D − 1* too,
and the bound is met with equality. The maximally entangled state is the
extremal, most-integrated object compatible with bond dimension *D*. And this
multi-cut value agrees perfectly with the single-cut calculation for the
maximally entangled two-party state, whose coefficient matrix is the identity:
its rank is *D*, so its Φ_cut is *D − 1*. The two pictures — one cut and many —
meet exactly at the extremal state.

Put the bound and the tightness theorem together and you get a complete answer to
the question *"how much can a bond-D network integrate?"* The answer is *exactly*
*D − 1*: never more (the bound), and that much is genuinely achievable (tightness).

## A worked miniature

Take the smallest interesting example: two qubits, bond dimension 2.

- A **product state** like *|0⟩|0⟩* has coefficient matrix of rank 1. Its single
  cut costs nothing: Φ = 0. The system is two independent coins.
- A **Bell state** like *(|0⟩|0⟩ + |1⟩|1⟩)/√2* has coefficient matrix equal to the
  identity, rank 2. Its Φ = 2 − 1 = 1 — the maximum allowed at bond dimension 2,
  and the canonical example of two systems that cannot be understood apart. Measure
  one qubit and you instantly know the other; the whole is strictly more than the
  parts.

Now scale up to three qubits and you see the multi-cut minimum do real work. The
**GHZ state** *(|000⟩ + |111⟩)/√2* has Schmidt rank 2 across every one of its
three cuts, so its Φ = 1: maximally and *uniformly* integrated, with no weak seam.
The **W state** *(|001⟩ + |010⟩ + |100⟩)/√3* also has rank 2 across every cut, so
it too has Φ = 1 — but its entanglement is distributed in a famously different,
more robust way, a distinction that motivates the richer measures discussed in our
companion research paper. And a state like *(|00⟩ + |11⟩)⊗|0⟩* — a Bell pair beside
an idle qubit — has a *free* cut isolating the idle qubit, Schmidt rank 1 there, so
its Φ collapses to 0. The lone qubit is the fault line, and IIT's minimum finds it
unerringly. The numbers in our `demo.py` reproduce every one of these.

## Why this matters

The payoff of casting IIT in the language of tensor networks is threefold.

**It makes Φ computable and exact.** By identifying the cut-cost with matrix rank,
we replace fuzzy information-theoretic functionals with a quantity any linear-
algebra library computes in microseconds — and which a proof assistant can reason
about rigorously.

**It connects three fields.** Consciousness theory, quantum information, and the
representation theory behind tensor networks turn out to speak about the same
object. IIT's "minimum information partition" *is* the worst-case Schmidt rank;
its "reducible system" *is* a product state; its integration ceiling *is* the bond
dimension. Ideas developed to simulate quantum magnets become tools for thinking
about integration, and vice versa.

**It turns postulates into theorems.** Tononi's axioms — that reducible systems
have Φ = 0, that a minimum partition exists, that integration is monotone — are no
longer assumptions bolted onto the theory. In the tensor-network setting they
*follow* from the definition, with proofs that a machine has checked end to end.

None of this settles whether Φ measures consciousness. But it shows that the
mathematical core of IIT is sound, sharp, and surprisingly at home in the
quantum world — and that the question "how integrated can a system be?" has, at
least for tensor networks, a clean and final answer: *one less than the bond
dimension, and not a bit more.*
