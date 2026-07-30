# The Heat Hidden in a Decision

## Why forgetting has a physical price

A decision looks weightless. A program receives a complicated input, returns “yes” or “no,” and the matter seems finished. Yet the apparent simplicity of the output conceals an irreversible act: many distinguishable inputs have been merged into the same answer. The machine may no longer retain enough information to reconstruct which input arrived. In that precise sense, it has forgotten.

Information is physical. A bit is not merely a symbol on a page; in any working device it is represented by a physical degree of freedom. When a computation irreversibly erases one unbiased bit while operating in contact with a thermal environment at absolute temperature $T$, Landauer’s principle assigns a minimum heat scale of $k_B T\ln 2$, where $k_B$ is Boltzmann’s constant. This does not say that every implementation reaches the minimum. Real machines usually dissipate much more. It says that logical irreversibility creates a floor beneath which no ideal implementation of that erasure can pass.

The central idea here is to lift this one-bit principle from a single fixed machine to an entire family of decision procedures whose inputs grow with a size parameter $n$. That shift matters. Complexity theory asks how resources grow: linearly, quadratically, exponentially, or without bound. Once information loss is indexed by input size, thermodynamic cost can be studied in the same language.

## Counting what survives

For each input size $n$, imagine a finite set $A_n$ of possible inputs, a set $B_n$ of possible outputs, and a deterministic procedure

$$
f_n:A_n\to B_n.
$$

Only outputs that actually occur matter. Write $f_n(A_n)$ for the image of the procedure: the set of distinguishable answers produced by some legal input. If there are $|A_n|$ possible inputs but only $|f_n(A_n)|$ possible observed outputs, then the procedure has compressed the original possibilities.

In the uniform finite-state model, define the erased information at size $n$ by

$$
e_n=\log_2|A_n|-\log_2|f_n(A_n)|.
$$

This quantity is measured in bits. It compares the logarithmic number of possible initial states with the logarithmic number of distinctions that remain visible at the output. A one-to-one procedure has $|f_n(A_n)|=|A_n|$ and therefore $e_n=0$. A procedure mapping $2^{20}$ equally possible inputs to two possible decisions has $e_n=19$: one output bit survives while nineteen bits’ worth of input distinctions disappear.

Now let $b(n)$ be any real-valued function. We say that the family discards at least $b(n)$ bits at size $n$ when

$$
b(n)\le e_n
$$

for every $n$. The function $b$ need not be linear, monotone, or integer-valued. It can reflect whatever counting argument is available for the problem at hand.

A useful counting criterion follows immediately. If, for every $n$,

$$
b(n)+\log_2|f_n(A_n)|\le \log_2|A_n|,
$$

then the family discards at least $b(n)$ bits. The reason is simple algebra: subtract the surviving-output term from both sides. This criterion turns combinatorics into thermodynamics. Count the input possibilities, count the answers that remain distinguishable, and the difference supplies an information-loss guarantee.

## The size-indexed Landauer bound

Let the ideal Landauer cost associated with erasing $q$ bits be

$$
\mathcal L(q;k_B,T)=q\,k_B T\ln 2.
$$

The main result is the **Size-Indexed Landauer Lower-Bound Theorem**:

> For every family $f_n:A_n\to B_n$ that discards at least $b(n)$ bits, and for nonnegative $k_B$ and $T$, the cost at every size $n$ satisfies
> $$
> b(n)k_B T\ln 2\le \mathcal L(e_n;k_B,T).
> $$

The proof is transparent but powerful. The hypothesis gives $b(n)\le e_n$. The factor $k_B T\ln 2$ is nonnegative because $k_B\ge0$, $T\ge0$, and $\ln2>0$. Multiplication by a nonnegative quantity preserves the inequality, producing the claimed energy bound.

There is also a strict version. The **Strict Size-Indexed Landauer Theorem** states that if $b(n)<e_n$ for every $n$ and both $k_B$ and $T$ are positive, then

$$
b(n)k_B T\ln2<\mathcal L(e_n;k_B,T).
$$

Here the positivity assumptions matter. At absolute zero, or with a zero conversion constant, multiplying by the energy-per-bit factor would collapse both sides to zero and destroy strictness. At positive temperature, a genuine margin in discarded information becomes a genuine margin in energy.

These theorems are deliberately general. The input and output sets may change arbitrarily with $n$. Their cardinalities need not follow a common formula. The same argument covers binary decisions, multiclass classifiers, finite automata, lookup procedures, lossy summaries, and any other deterministic finite-state map.

## When forgetting grows with the problem

Suppose a family loses at least $cn$ bits on inputs of size $n$, so that

$$
cn\le e_n.
$$

The **Linear Dissipation Theorem** then gives

$$
cn\,k_B T\ln2\le \mathcal L(e_n;k_B,T).
$$

The logical growth rate transfers unchanged into the thermodynamic lower bound, scaled only by the energy per erased bit. If the information loss doubles when $n$ doubles, the unavoidable ideal dissipation floor doubles as well.

Consider a concrete family. Let the input be an $n$-bit string, and let a procedure retain only the first $m(n)$ bits. There are $2^n$ inputs and $2^{m(n)}$ possible outputs, so

$$
e_n=\log_2 2^n-\log_2 2^{m(n)}=n-m(n).
$$

If the machine retains half the bits, with $m(n)=\lfloor n/2\rfloor$, it erases $n-\lfloor n/2\rfloor$ bits. The energy floor at temperature $T$ is exactly

$$
\bigl(n-\lfloor n/2\rfloor\bigr)k_B T\ln2.
$$

At room temperature the energy per bit is tiny, about $2.87\times10^{-21}$ joules at $300$ kelvin. But tiny is not zero, and scaling changes the story. Repeated operations, large workloads, and dense computing systems can turn a microscopic floor into an engineering constraint.

## From one job to a workload

Computing systems rarely solve a single isolated input size. They process portfolios of tasks. Let $S$ be any finite set of sizes. The **Finite-Workload Dissipation Theorem** states that

$$
\left(\sum_{n\in S}b(n)\right)k_B T\ln2
\le
\sum_{n\in S}\mathcal L(e_n;k_B,T).
$$

Its proof adds the individual size-indexed inequalities. Because the energy-per-bit factor is constant across the workload, it can be pulled outside the sum. No regularity of $S$ is required: the set might be a consecutive range, a sparse collection of benchmark sizes, or a schedule chosen by an application.

This workload view helps separate logical architecture from physical operating conditions. The total guaranteed information loss is $\sum_{n\in S}b(n)$. The environment contributes the common conversion factor $k_B T\ln2$. The lower bound is their product.

For example, if one task of every size from $1$ through $N$ erases at least $cn$ bits, then the total guaranteed loss is

$$
\sum_{n=1}^{N}cn=c\frac{N(N+1)}2.
$$

Thus a merely linear per-task loss becomes a quadratic cumulative floor across the growing workload. This conclusion is an application of the finite-workload theorem together with the elementary formula for the sum of the first $N$ integers.

## Unbounded forgetting means unbounded cost

The strongest asymptotic conclusion concerns families for which no fixed ceiling contains the guaranteed loss. Say that $b$ is unbounded above when, for every real number $C$, some size $n$ satisfies $C<b(n)$.

The **Unbounded Dissipation Theorem** states:

> If $b(n)\le e_n$ for every $n$, the function $b$ is unbounded above, and $k_B>0$ and $T>0$ are fixed, then the family’s Landauer costs are unbounded above. Explicitly, for every energy threshold $E$, there is a size $n$ such that
> $$
> E<\mathcal L(e_n;k_B,T).
> $$

To see why, set $L=k_B T\ln2$. Positivity of $k_B$ and $T$ gives $L>0$. Given an energy threshold $E$, unboundedness supplies an $n$ with $E/L<b(n)$. Multiplying by $L$ yields $E<b(n)L$. The size-indexed lower bound then gives $b(n)L\le\mathcal L(e_n;k_B,T)$, completing the chain.

This theorem does not claim that present-day computers are near the Landauer limit. Nor does it claim that every logical step erases information. Reversible computation can preserve enough history to reconstruct earlier states, trading erasure against memory, time, and control complexity. The theorem says something narrower and more durable: if an architecture is committed to discarding an unbounded amount of logical information, then at any fixed positive temperature its ideal Landauer floor cannot remain bounded.

## A bridge between disciplines

The results create a clean pipeline. First, model a size-$n$ procedure as a finite map. Second, count how many input distinctions exist and how many output distinctions survive. Third, obtain a lower bound $b(n)$ on erased bits. Finally, multiply by $k_B T\ln2$ to translate information loss into an energy floor. Individual, strict, linear, workload, and unbounded conclusions all follow from this same structure.

The framework also exposes the next questions. Composition should quantify the extra loss caused by adding a later stage. Fiber sizes—the number of inputs sharing one output—may yield sharper bounds when distributions are controlled. Polynomial loss rates should produce polynomial cumulative costs of one higher degree. Reversible implementations should reveal a tradeoff between erased bits and the size of a history register. And nonuniform inputs call for Shannon entropy rather than raw cardinality, replacing worst-case counting with average information loss.

The framework suggests a practical habit of mind. When evaluating an information-processing design, ask not only how many operations it performs, but also which distinctions it destroys. Two procedures may return the same answer and have similar running times while managing history very differently. One may overwrite intermediate states; another may preserve them long enough to reverse its work. Their logical interfaces look identical, yet their routes through physical state space need not carry the same erasure burden. The theorems do not choose the engineering design, but they make the cost of one architectural commitment visible.

The deepest lesson is easy to state: a decision is not only an answer. It is also a record of distinctions no longer available. By measuring those vanished distinctions as a function of input size, we can see how logical compression casts a thermodynamic shadow—one that lengthens with the computation.