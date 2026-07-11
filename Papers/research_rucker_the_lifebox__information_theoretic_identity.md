# The Lifebox: An Information-Theoretic Theory of Personal Identity

## Abstract

We give a precise mathematical treatment of the *Lifebox* thesis — the claim
that a person's identity is determined by informational content, its
input/output behavior, rather than by physical substrate. We define
**person-equivalence** as functional equivalence of systems and prove it is an
equivalence relation coinciding with equality of functions. We then establish a
sharp dichotomy governing *verification* of the thesis. When the stimulus space
is finite and outputs admit decidable equality, person-equivalence is
**decidable**, witnessed by the finite set of distinguishing stimuli. When the
stimulus space is infinite, we prove a **no-finite-test** theorem: for every
finite set of probe inputs there exist distinct systems agreeing on all of
them, so no finite examination certifies identity. We connect the duplication
half of the Lifebox program to quantum physics by proving a **no-cloning**
theorem: over any field, there is no linear map $C$ on a state space of
dimension $\geq 2$ with $C(x) = x \otimes x$ for all $x$. Finally we make the
quantitative claim precise: identities describable in $b$ bits number exactly
$2^b$, a finite quantity, specialized to Rucker's $\sim 10^{15}$-bit estimate.
Together these results delineate exactly where the Lifebox dream succeeds
(finite, classical minds) and where it meets fundamental obstruction (infinite
behavior and quantum substrate).

**Keywords:** personal identity, functional equivalence, decidability,
no-cloning theorem, Kolmogorov complexity, finite-state automata, quantum
information.

## 1. Introduction

Rudy Rucker's *Lifebox* is a hypothetical device that stores a person by
storing the totality of how they respond to the world. It dramatizes a
philosophical position — *substrate independence* or *functionalism* — under
which personal identity is a matter of information and behavior, not of the
particular matter that implements it. Two implementations that behave alike are
the same person.

This paper asks what mathematics has to say about the Lifebox. We isolate three
verbs implicit in the fantasy — to *define* a person, to *verify* a copy, and to
*duplicate* a mind — and analyze each rigorously. Our contributions are:

1. A clean definition of **person-equivalence** as functional equivalence, and
   a proof that it is an equivalence relation identical to function equality
   (Section 3).
2. A **decidability** theorem for finite stimulus spaces, reducing
   person-equivalence to emptiness of a distinguishing-stimulus set
   (Section 4).
3. A **no-finite-test** theorem for infinite stimulus spaces, showing the
   finiteness hypothesis is necessary (Section 5).
4. A **no-cloning** theorem grounding the impossibility of copying a quantum
   mind (Section 6).
5. A finite **counting bound** on identities, formalizing the $\sim 10^{15}$-bit
   estimate (Section 7).

Throughout, "system" means a function $f : I \to O$ from an input (stimulus)
type $I$ to an output (response) type $O$.

## 2. Preliminaries and notation

Let $I$ and $O$ be types (sets). We write $f : I \to O$ for a system. We use
$\otimes$ for the tensor product of vector spaces over a field $k$; for vectors
$x, y$ the elementary tensor is written $x \otimes y$. We write $\mathrm{Fin}\,b$
for a $b$-element index set and $\mathrm{Bool} = \{\mathrm{true},
\mathrm{false}\}$ for the two-element set of bits. For a finite type $T$ we write
$|T|$ for its cardinality.

## 3. Person-equivalence

**Definition 3.1 (Person-equivalence).** Two systems $f, g : I \to O$ are
*person-equivalent*, written $f \sim g$, if $f(i) = g(i)$ for all $i \in I$.

**Theorem 3.2 (Equivalence relation).** The relation $\sim$ is reflexive,
symmetric, and transitive.

*Proof.* Reflexivity: $f(i) = f(i)$ for all $i$. Symmetry: if $f(i) = g(i)$ for
all $i$, then $g(i) = f(i)$ for all $i$. Transitivity: if $f(i) = g(i)$ and
$g(i) = h(i)$ for all $i$, then $f(i) = h(i)$ for all $i$ by substitution. $\square$

**Theorem 3.3 (Identity is behavior).** For all systems $f, g : I \to O$,
$f \sim g$ if and only if $f = g$.

*Proof.* If $f \sim g$ then $f(i) = g(i)$ for all $i$, hence $f = g$ by function
extensionality. Conversely if $f = g$ then trivially $f(i) = g(i)$ for all $i$.
$\square$

Theorem 3.3 is the mathematical statement of substrate independence: identity is
exactly the extensional (behavioral) content of a system. The abstraction
carries no memory of *how* $f$ is implemented, only of *what* it does. In
particular $\sim$ descends to a well-defined quotient — the set of "behaviors" —
on which each equivalence class is one person.

## 4. Finite stimulus spaces: decidability

If a mind is a finite-state device, the set of stimuli it can ever perceive is
finite. In that regime the Lifebox can be *checked*.

**Definition 4.1 (Distinguishing stimuli).** For systems $f, g : I \to O$ with
$I$ finite, the *distinguishing-stimulus set* is
$$D(f, g) = \{\, i \in I : f(i) \neq g(i) \,\}.$$

**Theorem 4.2 (Finite-state decidability).** Suppose $I$ is finite and equality
on $O$ is decidable. Then
$$f \sim g \iff D(f, g) = \varnothing,$$
and consequently $f \sim g$ is decidable.

*Proof.* By definition $f \sim g$ means $f(i) = g(i)$ for all $i \in I$, i.e.
there is no $i$ with $f(i) \neq g(i)$, i.e. $D(f,g) = \varnothing$. Because $I$
is finite and equality on $O$ is decidable, $D(f,g)$ is a computable finite set;
testing its emptiness is a terminating procedure. Hence $\sim$ is decidable.
$\square$

The proof is also an algorithm: enumerate $I$, compare outputs, collect
disagreements, and report equivalence iff none are found. The cost is $|I|$
output comparisons. Thus for finite-state minds, person-equivalence is not only
well-defined but *effectively testable* — the optimistic core of the Lifebox
program.

## 5. Infinite stimulus spaces: no finite test

The decidability of Section 4 rests on finiteness. We now show finiteness is
indispensable: over an infinite input space, *no* finite test suite certifies
identity. We take $I = \mathbb{N}$ and $O = \mathrm{Bool}$.

**Theorem 5.1 (No finite test).** For every finite set $S \subseteq \mathbb{N}$
of probe inputs there exist systems $f, g : \mathbb{N} \to \mathrm{Bool}$ with
$f(i) = g(i)$ for all $i \in S$, yet $f \neq g$.

*Proof.* Since $S$ is finite and $\mathbb{N}$ is infinite, choose $n \notin S$.
Let $g$ be the constant system $g(i) = \mathrm{false}$, and let
$$f(i) = \begin{cases}\mathrm{true} & i = n,\\ \mathrm{false} & i \neq n.\end{cases}$$
For every $i \in S$ we have $i \neq n$, so $f(i) = \mathrm{false} = g(i)$; the two
systems agree on all probes. But $f(n) = \mathrm{true} \neq \mathrm{false} = g(n)$,
so $f \neq g$. $\square$

**Corollary 5.2.** Over an infinite stimulus space, person-equivalence cannot be
decided by evaluating the systems on any predetermined finite set of inputs.

Theorem 5.1 is an adversary argument: whatever finite probe set an examiner
commits to, an impostor can be constructed that passes every probe yet differs
elsewhere. This is the precise sense in which unbounded behavior escapes finite
verification, and it identifies the hypothesis of Theorem 4.2 as tight rather
than incidental.

## 6. Quantum substrate: no cloning

The Lifebox does not merely test a person; it *duplicates* one, reading out the
pattern and writing a copy. For classical data this is trivial. For quantum
states it is impossible, by a linear-algebra obstruction we now make explicit.

Model a quantum state as a vector in $k^2$ over a field $k$ (the case of a single
qubit, or any dimension $\geq 2$). A cloning device is a linear map producing two
copies of its input.

**Theorem 6.1 (No-cloning).** Let $k$ be a field. There is no $k$-linear map
$$C : k^2 \to k^2 \otimes_k k^2 \quad\text{with}\quad C(x) = x \otimes x \ \text{for all } x \in k^2.$$

*Proof.* Suppose such $C$ exists. Write $e_1 = (1,0)$ and $e_2 = (0,1)$, so
$e_1 + e_2 = (1,1)$. By linearity,
$$C(e_1 + e_2) = C(e_1) + C(e_2) = e_1 \otimes e_1 + e_2 \otimes e_2.$$
On the other hand the cloning hypothesis applied to $x = e_1 + e_2$ gives
$$C(e_1 + e_2) = (e_1 + e_2) \otimes (e_1 + e_2) = e_1\otimes e_1 + e_1\otimes e_2 + e_2\otimes e_1 + e_2\otimes e_2.$$
Equating the two expressions forces
$$e_1 \otimes e_2 + e_2 \otimes e_1 = 0 \quad\text{in } k^2 \otimes_k k^2.$$
To see this is false, apply the bilinear pairing $B(a, b) = a_1 b_2$ (the product
of the first coordinate of $a$ with the second coordinate of $b$), which extends
to a linear functional on the tensor product with $B(a \otimes b) = a_1 b_2$.
Then $B(e_1 \otimes e_2) = 1$ and $B(e_2 \otimes e_1) = 0$, so
$B(e_1\otimes e_2 + e_2\otimes e_1) = 1 \neq 0$, contradicting that the sum is
zero. Hence no such $C$ exists. $\square$

The mechanism is the mismatch between the *linearity* required of any physical
evolution and the *quadratic* nature of duplication $x \mapsto x \otimes x$; the
cross terms $e_1 \otimes e_2 + e_2 \otimes e_1$ that linearity cannot supply are
exactly the obstruction. Consequently a genuinely quantum mind admits no
universal read-and-duplicate device: the copying step of the Lifebox is
forbidden not by engineering limits but by the structure of quantum state
spaces. This is the algebraic core of the claim that quantum brains cannot be
Lifeboxed.

## 7. The information content of a person

Finally we quantify. Rucker estimates a human identity at roughly $10^{15}$ bits.
Model an identity describable in $b$ bits as a bit-vector, a function
$\mathrm{Fin}\,b \to \mathrm{Bool}$.

**Theorem 7.1 (Counting identities).** The number of identities describable in
$b$ bits is exactly $2^b$:
$$|\,\mathrm{Fin}\,b \to \mathrm{Bool}\,| = 2^b.$$

*Proof.* A function from a $b$-element domain to a $2$-element codomain is
determined by $b$ independent binary choices; the count is $2^b$ by the standard
cardinality of function spaces between finite types. $\square$

**Corollary 7.2 (Lifebox bound).** Under Rucker's $\sim 10^{15}$-bit hypothesis
the number of distinct possible identities is the finite quantity
$2^{(10^{15})}$; in particular the type of such identities is finite.

Although $2^{(10^{15})}$ is astronomically large, it is finite. The
philosophical upshot is that, under a finite-information hypothesis, the space of
all possible persons is enumerable and bounded — a Kolmogorov-style counting
principle for identity. This is a counting bound, not a genuine Kolmogorov
complexity; Section 9 discusses upgrading it to shortest-description length over
a universal machine.

## 8. Discussion

The five results assemble into a coherent verdict on the Lifebox thesis.
Definition 3.1 and Theorem 3.3 vindicate the *conceptual* claim: identity can be
formalized as behavior, independent of substrate. Theorem 4.2 vindicates the
*optimistic* claim for finite, classical minds — such a person can be both
represented and verified by finite means. Theorem 5.1 and Theorem 6.1 are the
*obstructions*: unbounded behavior defeats finite verification, and quantum
substrate defeats duplication outright. Theorem 7.1 supplies the *quantitative*
frame in which the whole discussion lives, showing that a finite-bit person
inhabits a finite (if vast) space of possibilities.

A notable feature is that the two obstructions are of different kinds. The
no-finite-test theorem is *epistemic*: the copy might be perfect, but we could
never confirm it with a finite examination. The no-cloning theorem is *ontic*:
for a quantum mind the copy cannot be made at all. The Lifebox dream survives
for finite classical minds and fractures along both of these fault lines
otherwise.

## 9. Future work

- **Genuine automaton equivalence.** Upgrade Theorem 4.2 from a finite stimulus
  space to full Moore/Mealy machines over input strings, proving language
  equivalence decidable via the product-automaton reachability construction, with
  the Myhill–Nerode distinguishing-string bound $\leq |S_1|\cdot|S_2|$.
- **Quantitative no-cloning.** Strengthen Theorem 6.1 to fidelity bounds: any
  approximate cloner has fidelity bounded away from $1$, generalizing from $k^2$
  to arbitrary dimension $\geq 2$ and to the unitary/CPTP setting.
- **Undecidability, formally.** Reduce the halting problem to equivalence of
  systems encoding Turing machines, yielding a true undecidability statement
  (rather than the no-finite-test surrogate) for the infinite/quantum regime.
- **Kolmogorov complexity proper.** Replace the counting bound of Theorem 7.1
  with a shortest-description length over a fixed universal machine, and prove
  invariance and subadditivity.
- **Substrate independence, formalized.** State the Lifebox thesis directly: two
  systems on different state spaces that are behaviorally equivalent (bisimilar)
  are the same person, i.e. person-identity factors through the behavior
  quotient.

## 10. Conclusion

The Lifebox, born as fiction, admits a rigorous mathematical anatomy. Identity
as information is a coherent and even natural definition; it is testable for
finite classical minds; it is untestable by finite means over infinite behavior;
it is uncopyable for quantum substrate; and, under a finite-bit hypothesis, the
universe of possible persons is finite. The dream is neither wholly true nor
wholly impossible — it is *conditionally* realizable, and the conditions are
precisely the ones mathematics is built to describe.
