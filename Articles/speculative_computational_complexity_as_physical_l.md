# Complexity Is Not Heat: What Maxwell’s Demon Really Learns from $P$ versus $NP$

A locked door separates two rooms of gas. A tiny creature watches molecules approach and opens the door only for the fast ones moving one way and the slow ones moving the other. Soon one room is hotter than the other, apparently without expenditure. A heat engine can exploit the difference. Has Maxwell’s demon outwitted the second law of thermodynamics?

The modern answer begins not with the door but with the demon’s memory. To sort molecules, the demon must record observations, use them, and eventually clear space for new observations. Clearing an unknown bit is a many-to-one operation: both $0$ and $1$ are sent to the same blank state. Information disappears from the logical description, and that loss has a thermodynamic price.

Now add a very different mystery. The class $P$ contains decision problems solvable in a number of computational steps bounded by a polynomial in the input length. The class $NP$ contains problems for which a proposed solution can be checked in polynomial time. Whether $P=NP$ is unknown. If equality held, enormous families of search and optimization problems would become efficiently decidable in the asymptotic sense.

It is tempting to splice these stories together: perhaps hard computation is what protects the second law, and perhaps $P=NP$ would create an efficient Maxwell demon that turns heat wholly into useful work. That narrative is vivid—and wrong without additional premises. Computational time and thermodynamic work are different resources. The central result developed here makes the separation exact.

## Three kinds of efficiency

Fix a universe of possible inputs. A *decision problem* is a set of inputs: membership means “yes.” We distinguish three collections of such problems.

1. The class $P_{\mathrm{phys}}$ consists of problems realized by physical processes using resources bounded polynomially in input size.
2. The class $P_{\mathrm{TM}}$ consists of problems decided by deterministic machines in polynomial time.
3. The class $NP_{\mathrm{TM}}$ consists of problems decided nondeterministically in polynomial time.

We assume two familiar inclusions. The extended Church–Turing simulation principle says

$$
P_{\mathrm{phys}}\subseteq P_{\mathrm{TM}},
$$

meaning that every polynomially bounded physical decision process can be simulated by a polynomial-time machine. Ordinary deterministic simulation gives

$$
P_{\mathrm{TM}}\subseteq NP_{\mathrm{TM}}.
$$

Finally, $P_{\mathrm{TM}}$ is assumed closed under polynomial-time many-one reductions. If problem $A$ reduces efficiently to problem $B$, and $B$ lies in $P_{\mathrm{TM}}$, then so does $A$.

Call a demon problem $D$ *$NP$-hard* when every problem in $NP_{\mathrm{TM}}$ reduces efficiently to $D$. This definition captures a demon whose computational task is at least as difficult as every problem in $NP$.

These simple ingredients yield the first result.

**Physical $NP$-Hardness Collapse Theorem.** If an $NP$-hard demon problem $D$ belongs to $P_{\mathrm{phys}}$, then

$$
NP_{\mathrm{TM}}\subseteq P_{\mathrm{TM}}.
$$

Because the reverse inclusion always holds, the two classes are equal.

The reasoning is short. Physical realizability and the simulation principle place $D$ in $P_{\mathrm{TM}}$. Every $NP$ problem reduces to $D$. Closure under reductions therefore places every $NP$ problem in $P_{\mathrm{TM}}$.

This theorem says something strong but conditional. It does not establish that an $NP$-hard physical solver exists, nor does it derive the extended Church–Turing principle from mechanics. It explains what follows if both assumptions hold.

## The bit that will not vanish for free

Complexity theory alone does not specify the demon’s microscopic implementation. To discuss heat and work, consider a finite set $\Omega$ of possible thermodynamic trajectories. Let $p(\omega)\ge 0$ be the probability of trajectory $\omega$, with

$$
\sum_{\omega\in\Omega}p(\omega)=1,
$$

and let $W(\omega)$ be the work performed along that trajectory. The mean work is

$$
\langle W\rangle=\sum_{\omega\in\Omega}p(\omega)W(\omega).
$$

For an isothermal one-bit erasure, the free-energy cost is

$$
\Delta F=kT\log 2,
$$

where $k>0$ is Boltzmann’s constant and $T>0$ is temperature. Assume the finite Jarzynski equality

$$
\sum_{\omega\in\Omega}p(\omega)e^{-W(\omega)/(kT)}
=e^{-\Delta F/(kT)}.
$$

Convexity of the exponential, equivalently Jensen’s inequality, implies

$$
\langle W\rangle\ge \Delta F=kT\log 2>0.
$$

The logical erasure map itself sends both Boolean values to one blank value:

$$
E(0)=0,\qquad E(1)=0.
$$

It is not injective, because distinct inputs have the same output. That is the precise logical irreversibility being priced.

**Positive-Work Erasing-Demon Theorem.** Suppose $P_{\mathrm{TM}}=NP_{\mathrm{TM}}$ and a demon’s decision problem belongs to $NP_{\mathrm{TM}}$. Then the problem is polynomial-time decidable. If an implementation also erases one uniformly unknown bit, evolves over finitely many trajectories satisfying the Jarzynski equality, and operates with $k>0$ and $T>0$, then its erasure is logically irreversible and its mean work is strictly positive.

Notice the conjunction. A complexity collapse settles the computational membership. The fluctuation relation settles the work bound. Neither conclusion substitutes for the other.

An immediate corollary is a no-go statement.

**No-Zero-Work Corollary.** Under the same hypotheses, it is impossible for the demon to be polynomial-time and simultaneously have zero mean erasure work.

The contradiction is quantitative, not rhetorical: zero cannot be at least the strictly positive number $kT\log 2$.

## One demon, two conclusions

The strongest bridge combines the two sides without assuming $P=NP$ independently.

**Integrated Collapse-and-Cost Theorem.** Suppose an $NP$-hard demon problem is physically realizable with polynomial resources. Assume the extended Church–Turing simulation principle and closure of deterministic polynomial time under reductions. If this demon is implemented by one-bit erasure at positive temperature and its finite trajectory ensemble satisfies the Jarzynski equality with $\Delta F=kT\log 2$, then all four conclusions hold:

1. $P_{\mathrm{TM}}=NP_{\mathrm{TM}}$;
2. the demon problem lies in $P_{\mathrm{TM}}$;
3. its erasure map is noninjective;
4. its mean work is strictly positive.

This is the crucial correction to the popular speculation. The hypothetical physical solver really would collapse the complexity classes under the stated simulation assumptions. Yet the very same demon, when required to erase a bit through finite-temperature Jarzynski dynamics, cannot erase for zero mean work. Computational power does not cancel thermodynamic bookkeeping.

## A ladder of complexity

The argument extends beyond the first $P$–$NP$ boundary. Consider a hierarchy of problem classes

$$
H_0\subseteq H_1\subseteq H_2\subseteq\cdots.
$$

Suppose adjacent equality at some level $k$ is stable upward: whenever $H_m=H_{m+1}$, it follows that $H_{m+1}=H_{m+2}$. If $H_k=H_{k+1}$, induction gives

$$
H_j=H_k\qquad\text{for every }j\ge k.
$$

Now suppose every problem in $H_k$ has a polynomially bounded physical realization. The physical simulation principle puts $H_k$ inside $P_{\mathrm{TM}}$. Since every higher level equals $H_k$, we obtain the following.

**Stable-Hierarchy Simulation Theorem.** If a nested complexity hierarchy collapses at level $k$, adjacent collapse propagates upward, and every problem at level $k$ is polynomially physically realizable, then every problem at every level $j\ge k$ has a polynomial-time machine simulation.

The result is extensional: it concerns membership of problems in classes. It does not yet supply a single uniform compiler or a common polynomial exponent for all levels. That quantitative strengthening remains a natural research target.

## What the second law is—and is not—waiting for

The second law is not guarded by the presumed inequality $P\ne NP$ in this model. It is guarded, at the one-bit scale, by the energetic cost of discarding information under specified thermodynamic dynamics. Even if an answer becomes easy to compute, resetting the memory that held intermediate or final information remains a separate physical act.

This distinction suggests better engineering. Reversible computation attempts to retain enough information that each logical step can be inverted. It may reduce dissipation associated with intermediate erasures, though a final reset can still discard information and incur a cost. The right question is therefore not merely, “How long does the algorithm run?” It is also, “Which distinctions among physical states does the implementation destroy?”

The present results have sharp boundaries. They concern finite trajectory spaces, normalized probabilities, positive temperature, and a Jarzynski equality tailored to one-bit erasure. They do not claim that every computation erases a bit. They do not derive a universal time–energy tradeoff. They also do not establish that every polynomial-time algorithm has a reversible implementation with any particular overhead.

What they do establish is cleaner: reductions transfer efficient solvability; stable class equalities transfer simulation through a hierarchy; and information loss, under the stated fluctuation relation, transfers into positive work. These are three monotone mechanisms living in different mathematical currencies.

There is also a practical moral for claims about exotic hardware. Quantum devices, analog machines, biological networks, and future physical substrates may alter constants, architectures, or even accepted complexity assumptions. Any claim that one of them defeats a thermodynamic limit must nevertheless name the operation, the ensemble, and the energy accounting. A faster route to a decision is not automatically a cheaper reset. Conversely, a dissipative implementation does not prove that the underlying decision problem is computationally hard. Experiments and algorithms answer related but distinct questions. Good physical-complexity claims must therefore report both ledgers rather than folding one into the other.

Maxwell’s demon may one day receive a spectacular algorithmic upgrade. It may sort, search, and decide with resources once thought impossible. But when it crushes two possible memory states into one, the ledger does not disappear. The universe may permit astonishing computation. It does not follow that forgetting is free. That final distinction turns a seductive paradox into a disciplined research program: classify what can be computed, describe what information is destroyed, and measure what the destruction costs.
