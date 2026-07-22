# The Heat Hidden in a Reset Button

## Why forgetting has a price even when computing is fast

Every digital device is built around a small miracle of forgetting. A register may hold a password check, a sensor reading, or an intermediate result; then a reset signal arrives and all of its possible histories are funneled into one standard state. To a programmer, this looks like housekeeping. To physics, it is a many-to-one transformation, and many-to-one transformations leave a thermodynamic bill.

The key result developed here makes that bill precise for a register of any finite size. If an $n$-bit register is reset at positive temperature $T$, and the physical process obeys the usual finite-temperature fluctuation relation, then its mean work cannot fall below

$$
kTn\log 2,
$$

where $k$ is Boltzmann's constant. Even more tellingly, the result makes no assumption about how long the surrounding computation takes. A millisecond algorithm and a millennium algorithm face the same lower bound if they ultimately destroy the same $n$ bits of information.

This is not a claim that every logic gate necessarily burns that much energy, nor that computation and heat are interchangeable currencies. It says something subtler and more useful: runtime and information loss are separate resources. They may share the same size parameter $n$, but they must not be confused.

## Counting what disappears

Begin with the simplest possible memory: $n$ switches, each either false or true. There are

$$
2^n
$$

possible configurations. A reset sends every one of them to a unique blank state. Before reset, the system can distinguish $2^n$ logical possibilities; afterward, it can distinguish only one.

A natural measure of discarded information is the base-two logarithm of the number of possible input states minus the base-two logarithm of the number of reachable output states. Denoting this loss by $D(n)$, we have

$$
D(n)=\log_2(2^n)-\log_2(1)=n.
$$

This elementary identity is the combinatorial heart of the argument. It converts the architecture of a reset into an exact information count: resetting the whole register discards exactly $n$ bits. No asymptotics are needed, and there is no hidden constant.

The distinction between *changing* a bit and *erasing* one matters. A reversible operation can permute the $2^n$ register states without merging them. A NOT gate, for instance, exchanges zero and one; knowing the output determines the input. Reset is different. Once every input has become blank, the output alone no longer reveals which input occurred. It is this lost distinction—not activity by itself—that the lower bound tracks.

## From logical loss to physical work

Real microscopic processes fluctuate. A single run may consume more work than average, or less; thermal agitation occasionally produces apparently lucky trajectories. The appropriate foundation is therefore not a deterministic claim about every run, but a fluctuation relation governing an ensemble of possible outcomes.

Let the possible microscopic outcomes form a finite set. For each outcome $\omega$, let $p(\omega)$ be its probability and $W(\omega)$ the work expended. The probabilities are nonnegative and sum to one. Write $\Delta F$ for the free-energy cost assigned to the information loss and let $\beta=(kT)^{-1}$. The Jarzynski condition used here is

$$
\sum_{\omega}p(\omega)\exp\!\left[-\beta\bigl(W(\omega)-\Delta F\bigr)\right]\le 1.
$$

Equality is the familiar ideal form; allowing an inequality also accommodates processes with additional dissipation. For an $n$-bit reset, the information-based free-energy change is

$$
\Delta F=kTn\log 2.
$$

Why does the average-work bound follow? The exponential function is convex, so Jensen's inequality gives

$$
\exp\!\left[-\beta\bigl(\mathbb E[W]-\Delta F\bigr)\right]
\le
\mathbb E\!\left[\exp\!\left(-\beta(W-\Delta F)\right)\right]
\le 1.
$$

Because $\beta>0$, taking logarithms and rearranging yields

$$
\mathbb E[W]\ge \Delta F=kTn\log 2.
$$

This is the **Size-Indexed Landauer Bound**: under the stated fluctuation condition, resetting an $n$-bit Boolean register requires mean work at least $kTn\log 2$.

The assumptions deserve emphasis. Temperature and Boltzmann's constant are positive. The microscopic outcomes carry a genuine probability distribution. Most importantly, the reset dynamics satisfy the fluctuation relation with a free-energy change equal to the information destroyed. The conclusion is conditional on these physical hypotheses; it is not obtained from combinatorics alone.

## Runtime does not appear

Suppose a function $r(n)$ records runtime. It could be linear, polynomial, exponential, irregular, or chosen after everything else. The proof of the work bound never uses it. The count $2^n$, the loss $n$, and the fluctuation relation already determine the conclusion.

That absence is a positive scientific statement. It blocks a tempting but mistaken inference: “If an algorithm becomes faster, perhaps its erasure can become thermodynamically free.” Speed can change how power is delivered, how much leakage accumulates, or how closely a device approaches an ideal protocol. But runtime by itself does not change how many logical alternatives a reset merges.

This separation is relevant to low-energy computing. Reversible circuits seek to preserve information through intermediate steps, trading ordinary many-to-one gates for invertible transformations and retaining enough history to reconstruct prior states. Such a design can move the thermodynamic bottleneck. Yet if the retained history is eventually reset, the cost returns at that localized point. The right engineering question is therefore not merely “How many steps?” but also “Where, and how much, information is irreversibly discarded?”

## Partial guarantees on information loss

Often we do not know the exact number of bits erased, but we know a lower bound. Let $b(n)$ be any real-valued function satisfying

$$
b(n)\le D(n).
$$

Since $\log 2\ge 0$ and $kT>0$, multiplying preserves the inequality. Combining it with the exact Landauer bound gives the **Discarded-Bits Lower-Bound Theorem**:

$$
\mathbb E[W]\ge kT\,b(n)\log 2.
$$

This extension is useful because information accounting is often easier to bound than to compute exactly. An architecture may guarantee that at least half its workspace is overwritten, or that a protocol merges at least a specified number of distinguishable states. Any valid lower estimate immediately becomes a work lower estimate under the same fluctuation hypothesis.

For the complete Boolean reset, choosing $b(n)=n$ recovers the exact size-indexed result. Choosing a smaller bound produces a correspondingly weaker but still rigorous physical guarantee.

## Lucky runs and their exponential rarity

An average can hide drama. Could a device routinely beat the threshold, compensated by a few enormously expensive runs? The fluctuation relation answers with an exponential tail bound.

Fix a margin $\xi$. Consider the event that a run uses less work than the Landauer threshold minus that margin:

$$
W<kTn\log 2-\xi.
$$

On this event, $\exp[-\beta(W-\Delta F)]$ is larger than $\exp(\beta\xi)$. Markov's inequality, applied through the fluctuation relation, then yields the **Finite-Size Violation Bound**:

$$
\Pr\!\left(W<kTn\log 2-\xi\right)
\le
\exp\!\left(-\frac{\xi}{kT}\right).
$$

For a positive margin, every additional energy unit of size $kT$ suppresses the upper bound by a factor of $e^{-1}$. The theorem does not prohibit an individual low-work trajectory. Thermal systems can fluctuate. It says that substantial apparent violations must be exponentially rare.

At $T=300\,\mathrm{K}$, one bit has a threshold of approximately $2.87\times10^{-21}\,\mathrm{J}$. A reset of one million unbiased bits therefore has an ideal lower bound near $2.87\times10^{-15}\,\mathrm{J}$. Contemporary devices typically dissipate far more, because the Landauer quantity is a floor, not a prediction of ordinary operating energy. Its value is conceptual and architectural: as engineering improves, information destruction remains a boundary that cannot be optimized away merely by a faster algorithm.

## What the result does—and does not—say

The result concerns a uniform logical register, so counting states and measuring information coincide. Nonuniform data require a finer quantity: Shannon entropy. If some register states are overwhelmingly likely and others virtually impossible, erasing the register need not cost as much as erasing a uniformly random one with the same number of physical bits. Likewise, if another memory retains information correlated with the register, the relevant loss should be conditional entropy rather than total entropy.

The theorem also concerns a finite outcome space and assumes a fluctuation relation. It does not derive microscopic dynamics from first principles, claim that all implementations achieve the lower bound, or equate computational difficulty with thermodynamic cost. Instead, it provides a clean bridge: exact logical cardinality loss on one side, fluctuation-controlled work on the other.

That bridge suggests a broader research program. One can replace full reset by an arbitrary many-to-one map and compare the entropy before and after. One can study side information, sequential resets with correlations, and reversible simulations that postpone erasure. One can also ask how complexity classes enriched with clocks and memory bounds interact with physical resources.

## Two ledgers for computation

Computer science traditionally keeps a ledger of time and space. Thermodynamics asks for another ledger: distinguishability preserved or destroyed. The same input size may index both, but the entries measure different things.

The $n$-bit reset exposes this distinction in its purest form. The logical count is exact: $2^n$ possibilities become one, so $n$ bits disappear. The physical implication is equally crisp under the fluctuation relation: mean work is at least $kTn\log 2$, and beating that threshold by $\xi$ has probability at most $e^{-\xi/(kT)}$. Runtime never enters either statement.

A reset button looks like an endpoint. In fact, it reveals the architecture of computation: what a machine remembers, what it forgets, and which of those choices physics will ultimately charge for.