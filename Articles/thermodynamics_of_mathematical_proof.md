# Thermodynamics of Mathematical Proof

## When an argument leaves a physical trace

A proof is usually pictured as an ascent: begin with assumptions, add one justified step after another, and arrive at a theorem. Yet actual reasoning also has a less visible motion. We discard failed approaches, forget temporary distinctions, and replace a crowded landscape of possibilities by one certified route. If reasoning is performed by a physical device, that disappearance of information matters.

The relevant physical principle is Landauer’s principle. At absolute temperature $T$, irreversibly erasing one unbiased bit requires at least

$$
kT\ln 2
$$

of dissipated work in the ideal limit, where $k$ is Boltzmann’s constant. This is not a price for thinking, deduction, or computation as such. Reversible computation can, in principle, rearrange information without paying an erasure cost. The price appears when two distinguishable logical states are deliberately merged and the distinction cannot be recovered from what remains.

To make that idea mathematically sharp, consider a deliberately simple world of proofs. A candidate derivation of depth $n$ is a binary word

$$
(b_1,b_2,\ldots,b_n),\qquad b_i\in\{0,1\}.
$$

Each bit records which of two inference choices was made at one stage. There are exactly $2^n$ candidates. Suppose that one candidate is selected and retained while all the others are discarded. The number of discarded alternatives is therefore

$$
E(n)=2^n-1.
$$

This elementary count is the engine of the model. It turns a familiar metaphor—proof search as navigating a branching tree—into exact information accounting.

## Creation grows linearly; discarded multiplicity grows exponentially

Writing down a candidate of depth $n$ creates or records $n$ binary choices. Selecting one candidate from the entire unstructured family leaves $2^n-1$ alternatives behind. The contrast is stark: description length grows linearly, while the population excluded by selection grows exponentially.

The first main result is the **Exact Erased-Multiplicity Theorem**: for every nonnegative integer $n$, selecting one binary derivation of depth $n$ from all such derivations discards exactly $2^n-1$ alternatives. Moreover,

$$
n\le E(n)
$$

for every $n$, and, once $n\ge 4$,

$$
2n<E(n).
$$

Thus the discarded population is already more than twice the number of recorded choices at depth four. At $n=4$, there are $16$ candidates and $15$ discarded alternatives, compared with only $4$ bits in the retained word. At $n=10$, the corresponding numbers are $1024$, $1023$, and $10$.

The growth can also be seen one level at a time. Adding a binary choice doubles the candidate population, so

$$
E(n+1)=2E(n)+1.
$$

The extra $1$ is the old retained candidate’s newly created sibling; every previously discarded branch also splits in two. This recurrence offers a vivid picture of the acceleration. A single additional yes-or-no decision does not merely add one more road. It attaches a fresh fork to every road already present. That is why even modest depths produce a gulf between the short itinerary eventually kept and the vast atlas of routes that selection rules out.

This is a theorem about a finite proof-search model, not a declaration that every real theorem is exponentially difficult. Mathematical structure can make a correct proof locally recognizable, and clever algorithms can avoid blind search. The conclusion is narrower and more useful: whenever the relevant proof space really is an unstructured binary family and selection physically destroys separately represented alternatives, exponential multiplicity appears exactly.

## From counting to heat

Define the erasure work assigned to destroying $m$ independently represented bits by

$$
W(k,T,m)=kT\ln 2\,m.
$$

For one unbiased bit, the Shannon entropy before erasure is $\ln 2$ in natural units; after resetting the bit to a fixed value, the entropy is $0$. The entropy loss is therefore precisely $\ln 2$, which yields the one-bit Landauer unit $kT\ln 2$.

Applying this accounting convention to the discarded multiplicity gives the **Exact Proof-Selection Work Theorem**:

$$
W_n=kT\ln 2\,(2^n-1).
$$

If $k\ge 0$ and $T\ge 0$, then the elementary inequality $n\le 2^n-1$ also gives

$$
kT\ln 2\,n\le W_n.
$$

This formula should be read with care. The model charges one erasure unit for each independently recorded discarded alternative. If a machine never materializes those alternatives, or stores uncertainty in a compressed distribution, the correct charge is governed by the Shannon information actually destroyed, not by an imaginary list of branches. The result identifies an exact cost for a specified physical representation and reset operation; it is not a universal energy meter for all acts of proving.

That qualification points toward the deeper invariant: fiber multiplicity. Any irreversible map sends many possible inputs to one output. The inputs that collapse to a particular output form its fiber. A large fiber means that the output no longer reveals which input occurred. Under a uniform distribution within that fiber, a fiber of size $M$ hides $\ln M$ nats, or $\log_2 M$ bits. The binary proof model makes this loss visible in its simplest finite form.

## Why the candidates cannot all be squeezed into shorter names

Could one evade the entire problem by giving every depth-$n$ derivation a description shorter than $n$ bits? No. A depth-$n$ binary word belongs to a set of size $2^n$. The set of all binary strings of length strictly less than $n$ has size

$$
1+2+4+\cdots+2^{n-1}=2^n-1.
$$

There are more derivations than short descriptions. By the pigeonhole principle, no injective encoding can assign every derivation a distinct description of length below $n$.

This is the **Finite Incompressibility Theorem**: for every $n$, there is no lossless uniform encoding of all depth-$n$ binary derivations using only binary strings shorter than $n$.

The theorem does not say that no individual proof can be compressed. A word such as $000\cdots0$ has an obvious short verbal description. It says that compression cannot succeed strictly for every member of the family at once. Some strings must resist. This finite counting obstruction is the elementary ancestor of Kolmogorov complexity, where one measures the length of the shortest program that generates an object. The present result requires no choice of universal programming language and no asymptotic constants: it is an exact statement about finite sets.

## The verifier’s blind spot

The same count creates a limit for adversarial verification. Imagine a verifier that queries a finite set $Q$ of candidates at depth $n$. If

$$
|Q|<2^n,
$$

then at least one candidate remains unqueried. An adversary may declare that omitted candidate to be the unique successful proof. Every queried candidate then fails, while the actual proof sits outside the transcript.

This is the **Adversarial Coverage Theorem**: any verifier that examines fewer than all $2^n$ candidates leaves open a scenario in which a unique successful derivation lies beyond its queries.

Again, this is not a lower bound for every verifier in mathematics. A semantic verifier normally checks whether a supplied derivation obeys rules; it need not hunt through every possible derivation. The theorem concerns a black-box search setting in which success can be placed adversarially and no structural clue identifies it. In that setting, exhaustive coverage is unavoidable.

Now the model’s three themes align. The count $2^n$ governs the size of the candidate space. It prevents universal strict compression. It also guarantees a hiding place against every sub-exhaustive query transcript. When selection collapses the alternatives, the same multiplicity controls the chosen erasure accounting.

## Reversible reasoning and the value of memory

Landauer’s principle does not demand that every discarded possibility become heat immediately. A machine can preserve its history. Instead of overwriting a temporary bit, it can copy the useful output while retaining enough auxiliary information to reverse every step. The computation then avoids logical erasure, but memory fills with a transcript.

This creates a three-way negotiation among energy, space, and time. Keep all intermediate states, and reversal remains possible at the cost of memory. Erase aggressively, and memory is reclaimed at an energy cost. Keep only occasional checkpoints, and missing history can be reconstructed by repeating parts of the computation, trading time for space. Proof verification is therefore not just a yes-or-no logical event; its physical realization can be designed along a spectrum.

The distinction also changes how we imagine mathematical practice. A blackboard argument looks ephemeral, but the erased chalk, discarded notes, and reset memory cells belong to the implementation, not to truth itself. The theorem proved does not have a temperature. The process that finds, checks, stores, and later deletes a representation of its proof does.

## A compact synthesis

For every depth $n\ge 4$, the binary model supplies a single finite witness with four simultaneous properties:

1. the discarded alternatives number exactly $2^n-1$;
2. this number exceeds $2n$;
3. not all candidates admit distinct descriptions shorter than $n$ bits; and
4. any query set of size below $2^n$ can miss a uniquely successful candidate.

Under the independent-erasure convention, selection has exact work

$$
kT\ln 2\,(2^n-1).
$$

These statements do not turn logic into physics by analogy alone. They identify the assumptions under which counting, information, verification, and thermodynamic work become different views of one finite structure. The central lesson is not that proofs inevitably burn an exponential amount of energy. It is that lost distinctions have to go somewhere. Whenever a physical process compresses a branching history into a single irreversible outcome, the geometry of the forgotten alternatives sets the scale of the information loss—and therefore of the least possible thermodynamic bill.