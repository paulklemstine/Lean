# The Lifebox Question: When Is a Pattern a Person?

Imagine meeting two black boxes. They look nothing alike. One is warm, biological, and threaded with cells; the other is cool silicon arranged on a circuit board. Yet whenever either box is shown a face, asked a question, challenged with a memory, or placed in a new situation, it responds in exactly the same way. Are there two different persons here, or one informational identity living in two different materials?

This is the central thought behind the “Lifebox”: perhaps the part of a person that can be preserved is not a particular collection of atoms but an organized pattern of responses. Mathematics cannot settle the ethical or metaphysical meaning of personhood. It can, however, turn the thought experiment into exact questions. What does “the same pattern” mean? Can sameness be decided by an algorithm? When can a finite experiment certify it? What changes when information is quantum rather than classical? And what does a claim such as “an identity fits in $10^{15}$ bits” actually imply?

The answers draw a sharp boundary. For finite-state models, behavioral identity is decidable, even though there are infinitely many possible interaction histories. For arbitrary systems with infinitely many possible stimuli, no fixed finite test can establish identity. Quantum theory adds a different obstruction: an unknown state cannot be copied by a universal linear device. That is a no-copying result, not by itself an undecidability result. Finally, a bit budget gives a clean counting theorem, but not automatically a theorem about Kolmogorov complexity.

## Identity as a response pattern

Begin with the simplest possible model. A system receives an input $i$ from a set $I$ and returns an output in a set $O$. Its complete behavior is a function

$$
f:I\to O.
$$

Two systems $f$ and $g$ are **person-equivalent** when

$$
\forall i\in I,\qquad f(i)=g(i).
$$

This definition deliberately ignores substrate. It asks only whether every possible stimulus receives the same response. In this model, person-equivalence is exactly equality of functions.

That simple observation has useful consequences. Person-equivalence is reflexive: every system agrees with itself. It is symmetric: if $f$ agrees with $g$, then $g$ agrees with $f$. It is transitive: if $f$ agrees with $g$ and $g$ agrees with $h$, then $f$ agrees with $h$. Thus behavioral profiles fall into equivalence classes. Each class may contain many physical implementations but only one complete input-output pattern.

This perspective is robust under sensible changes of representation. If inputs are re-encoded by a surjective map, every original stimulus still has a representative, so equivalence is preserved and reflected. If outputs are placed into a larger code by an injective map, distinct responses remain distinct, so equivalence again survives exactly. If two observation channels are recorded together, two paired systems are equivalent precisely when they agree in each channel separately. Behavioral identity, in other words, does not depend on the names of stimuli or responses; it depends on preserved distinctions.

## The finite test—and its limit

Suppose $I$ is finite and equality of outputs can be checked. Then person-equivalence is decidable by exhaustive comparison. Form the set of distinguishing stimuli

$$
D(f,g)=\{i\in I:f(i)\ne g(i)\}.
$$

The systems are equivalent exactly when $D(f,g)$ is empty. This is the **Finite Profile Decision Theorem**: complete behavioral identity over a finite stimulus space can be decided by testing every stimulus.

The word “complete” matters. If the input space is infinite, any chosen finite battery of tests can be fooled. Let $S$ be a finite set of natural-number inputs. Choose some $n$ outside $S$. Define $g$ to return false everywhere, while $f$ returns true only at $n$. Then $f$ and $g$ agree on every test in $S$, yet differ at $n$.

This gives the **No Finite Universal Test Theorem**: for every finite test set $S\subset\mathbb N$, there are distinct Boolean-valued systems that agree on all inputs in $S$. The result does not say that equivalence of every infinite-domain system is undecidable. It says something more elementary and precise: finite observations alone cannot certify equality for completely arbitrary functions on an infinite domain.

Real lives unfold through histories, not isolated prompts. That leads to the richer model where the most interesting positive result appears.

## Finite memory, infinitely many histories

A deterministic finite-state person model consists of four ingredients: a finite input alphabet $A$, a finite state set $S$, a transition rule

$$
\delta:S\times A\to S,
$$

and an observation rule

$$
\omega:S\to O.
$$

Starting at state $s$, an input word $w=a_1a_2\cdots a_m$ moves the system through successive states. Write $\delta^*(s,w)$ for the final state. Two initialized machines $(M,s)$ and $(N,t)$ are **trace-equivalent** when every finite input history gives the same final observation:

$$
\forall w\in A^*,\qquad
\omega_M(\delta_M^*(s,w))=
\omega_N(\delta_N^*(t,w)).
$$

At first this looks impossible to decide. The machines have finitely many states, but $A^*$ contains infinitely many words. One cannot simply run every experiment.

The escape is **bisimulation**. Consider pairs $(x,y)$ consisting of one state from each machine. A relation $R\subseteq S\times T$ is a bisimulation when every related pair has equal observations and, for every input symbol $a$, its successor pair is also related:

$$
(x,y)\in R\Longrightarrow
\left[
\omega_M(x)=\omega_N(y)
\ \text{and}\
(\delta_M(x,a),\delta_N(y,a))\in R
\text{ for every }a\in A
\right].
$$

A finite table of state pairs can therefore stand as a certificate for infinitely many experiments.

The **Bisimulation Characterization Theorem** states that two initialized deterministic machines are trace-equivalent if and only if some bisimulation contains their initial pair. The forward direction takes $R$ to be the relation of all state pairs that already have identical future behavior. Equal current output follows by using the empty word; closure under transitions follows by prefixing any future word with one input symbol. The reverse direction uses induction on word length: a bisimulation preserves relatedness after each symbol, and related states always have equal observations.

Because $S\times T$ is finite, there are only finitely many candidate relations. Searching them yields the **Finite-State Lifebox Theorem**: for finite input and state sets, with decidable output equality, trace-equivalence is decidable. An infinitary behavioral claim has a finite witness.

A more efficient practical method starts with all state pairs whose observations agree, then repeatedly deletes a pair if some input sends it to a deleted pair. The process must stop because only finitely many pairs exist. The surviving relation is the greatest bisimulation. This refinement view turns identity checking into a graph problem.

## Three tiny lives

Small machines reveal the definitions clearly. Consider a parity machine with Boolean state. It starts false, toggles whenever it receives true, and reports its current state. On the histories $[]$, $[\mathrm{true}]$, $[\mathrm{true},\mathrm{true}]$, and $[\mathrm{true},\mathrm{false},\mathrm{true}]$, it reports respectively

$$
[\mathrm{false},\mathrm{true},\mathrm{false},\mathrm{false}].
$$

Now compare it with a one-state silent machine that always reports false. The one-symbol history $[\mathrm{true}]$ distinguishes them immediately.

Next build a physically different silent machine with two internal states that toggle exactly like the parity machine but whose observation is always false. Its hidden state changes, while the one-state silent machine has no hidden variation at all. Nevertheless, every history produces false from both. They are trace-equivalent. The example captures the substrate-independence of the definition: additional invisible machinery does not create a behavioral difference.

## The quantum boundary: copying is not deciding

A classical bit can be read and duplicated. An arbitrary unknown quantum state cannot. In a two-dimensional vector space $V=k^2$ over any field $k$, a universal linear cloner would be a linear map

$$
C:V\to V\otimes V
$$

satisfying

$$
C(x)=x\otimes x
$$

for every $x\in V$. The **Two-Dimensional No-Cloning Theorem** says that no such linear map exists.

The reason is the collision between linearity and the quadratic nature of copying. Let $e_1=(1,0)$ and $e_2=(0,1)$. Linearity would require

$$
C(e_1+e_2)=C(e_1)+C(e_2)
=e_1\otimes e_1+e_2\otimes e_2.
$$

But universal cloning would require

$$
C(e_1+e_2)=(e_1+e_2)\otimes(e_1+e_2),
$$

which also contains the cross terms $e_1\otimes e_2$ and $e_2\otimes e_1$. A suitable bilinear measurement isolates a cross term and turns the conflict into $0=1$.

This theorem blocks a universal linear “read and duplicate” device for unknown quantum states. It does **not** show that quantum person-equivalence is undecidable. Copyability and algorithmic decidability are different properties. An undecidability claim would require a precise model of quantum programs and a reduction from a known undecidable problem. Keeping those claims separate is not a technicality; it is the difference between a proved obstruction and an unsupported leap.

## How many identities fit in a bit budget?

If an identity description is modeled as a bit-vector of fixed length $b$, then there are exactly

$$
2^b
$$

possible descriptions. Each of the $b$ positions independently contains zero or one. Under the proposed budget $b=10^{15}$, the description space has exactly

$$
2^{10^{15}}
$$

members. This number is beyond astronomical, but it is finite.

The theorem is a counting statement, not a proof that a person’s Kolmogorov complexity is at most $10^{15}$ bits. Kolmogorov complexity depends on a choice of universal description machine and measures the length of the shortest program generating an object. The numerical budget is therefore an external empirical conjecture. What mathematics supplies unconditionally is the implication: **if** identities are represented by fixed strings of $10^{15}$ bits, **then** the space of representations is finite and has the stated cardinality.

## What the Lifebox mathematics really says

The picture that emerges is neither a simple endorsement nor a refutation of informational identity. It is a map of logical boundaries.

Behavioral identity can be defined with complete precision. For finite profiles it is decidable by exhaustive comparison. For finite-state interactive systems it remains decidable despite infinitely many histories, because bisimulation compresses those histories into a finite relation on state pairs. Different substrates can genuinely occupy the same behavioral class. Yet arbitrary infinite domains defeat every fixed finite test, quantum linearity forbids universal cloning, and a finite bit count must not be confused with a theorem about shortest descriptions.

The deepest lesson may be methodological. Grand questions about selves and copies become tractable only after one asks exactly what may be observed, which experiments are allowed, how memory evolves, and what kind of information is being copied. Once those choices are explicit, the mystery does not disappear. It separates into theorems, counterexamples, and open problems—and that is often where understanding begins.
