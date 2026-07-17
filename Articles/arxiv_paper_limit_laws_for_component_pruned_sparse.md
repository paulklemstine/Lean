# When Pruning Preserves a Pattern—and When It Can Encode Anything

## A finite-state view of sparse structures

A very sparse graph can look less like a web than like an archipelago. Most vertices live in small connected components: isolated points, short paths, tiny trees, and occasional larger islands. If an observer deletes every component below a chosen size, what remains may be easier to study. This operation—**component pruning**—is natural in network science, reliability, percolation, and the study of rare structures.

Pruning, however, raises a subtle question. Suppose the sizes for which a certain kind of component exists eventually follow a repeating arithmetic pattern. Does pruning preserve that regularity? The answer developed here has two sides. There is a robust finite-state calculus for combining regular size patterns and counting repeated components. But there is also a sharp warning: if the cutoff is allowed to depend arbitrarily on the input size, pruning can manufacture any desired pattern, including one that never becomes periodic.

This tension—finite-state stability versus adversarial flexibility—is the central story.

## Spectra: recording which sizes are possible

A **spectrum** is simply a set $S\subseteq\mathbb N$. One may interpret $n\in S$ as saying that some structure of size $n$ has a property of interest. For example, $S$ might list the orders of trees satisfying a fixed logical sentence, the sizes of admissible components, or the total orders attainable by disjoint unions of prescribed pieces.

The relevant regularity notion is **eventual periodicity**. A spectrum $S$ is eventually periodic if there are integers $N\ge 0$ and $q>0$ such that, for every $n\ge N$,

$$
n\in S\quad\Longleftrightarrow\quad n+q\in S.
$$

The finite beginning of the set may be irregular. Beyond the threshold $N$, however, membership depends only on a residue class modulo $q$. This is the one-dimensional face of semilinear behavior: after finitely many exceptions, the set is a finite union of arithmetic progressions.

Think of a railway signal that behaves erratically while warming up, then settles into a repeating cycle. Eventual periodicity ignores the warm-up and records the cycle.

The empty spectrum and the universal spectrum are immediate examples: both repeat with period $1$. A finite set is eventually periodic too, because membership is always false beyond its largest element. The even numbers are periodic from the start with period $2$. By contrast, the powers of two become farther and farther apart, so no fixed translation can preserve them forever.

## A Boolean algebra of repeating tails

The first family of results says that eventual periodicity survives the ordinary operations used to build properties.

**Boolean Closure Theorem.** If $S$ and $T$ are eventually periodic spectra, then their complements $\mathbb N\setminus S$ and $\mathbb N\setminus T$, their intersection $S\cap T$, and their union $S\cup T$ are eventually periodic. More generally, every finite union of eventually periodic spectra is eventually periodic.

The reason is concrete. Suppose $S$ repeats after $N_S$ with period $q_S$, while $T$ repeats after $N_T$ with period $q_T$. Past $\max(N_S,N_T)$, a common period can be taken to be $q_Sq_T$. Translating by that amount makes an integer move through a whole number of $S$-periods and a whole number of $T$-periods. Membership in both sets is therefore unchanged, so the same is true of their intersection. Complementation simply reverses yes and no, and unions follow from intersections and complements.

A related result makes precise why finite beginnings do not matter.

**Tail-Equivalence Theorem.** If $S$ is eventually periodic and another spectrum $T$ agrees with $S$ for every sufficiently large integer, then $T$ is eventually periodic.

One merely moves the threshold far enough to pass both the start of $S$'s periodic regime and the final place where $S$ and $T$ differ. This simple principle is powerful: finite anomalies can be repaired, deleted, or added without disturbing long-run arithmetic structure.

Together these statements provide a small language for assembling spectra. Negation corresponds to complement, “and” to intersection, “or” to union, and finite case splits to finite unions. Once the primitive cases have repeating tails, every finite Boolean construction does as well.

## Counting components without counting forever

Spectra track sizes. A second finite-state idea tracks multiplicities of component types.

Fix a saturation threshold $q\in\mathbb N$. Two counts $a,b\in\mathbb N$ are called **$q$-equivalent** if either they are exactly equal or both are at least $q$:

$$
a\sim_q b
\quad\Longleftrightarrow\quad
(a=b)\ \text{or}\ (a\ge q\ \text{and}\ b\ge q).
$$

Below $q$, every count remains visible. At and above $q$, all counts collapse into one symbol, “many.” Thus the infinite list $0,1,2,\ldots$ is compressed to the finite list

$$
0,1,\ldots,q-1,\ge q.
$$

This is exactly the sort of memory a finite-state observer can carry. If $q=3$, it distinguishes zero copies, one copy, and two copies, but treats three, seven, and a million copies alike.

The relation behaves as a genuine notion of indistinguishability.

**Saturation Equivalence Theorem.** For every $q$, the relation $\sim_q$ is reflexive, symmetric, and transitive.

The only slightly interesting part is transitivity. If an intermediate count lies below $q$, equivalence forces exact equality on both sides. If it lies at least $q$, then both outer counts must also lie at least $q$ unless exact equalities already settle the issue.

More importantly, saturation is compatible with disjoint union, whose effect on multiplicities is addition.

**Additive Congruence Theorem.** If $a\sim_q b$ and $c\sim_q d$, then

$$
a+c\sim_q b+d.
$$

If both comparisons are exact, the sums are equal. Otherwise, at least one corresponding pair is already in the saturated region; adding nonnegative counts keeps both resulting sums at least $q$.

A whole structure generally has many component types, so its multiplicity data form a profile $a:I\to\mathbb N$, where $I$ indexes the types. Two profiles are $q$-equivalent coordinate by coordinate. The same addition rule then applies simultaneously everywhere.

**Profile Congruence Theorem.** If $a(i)\sim_q b(i)$ and $c(i)\sim_q d(i)$ for every $i\in I$, then

$$
a(i)+c(i)\sim_q b(i)+d(i)
$$

for every $i\in I$.

This theorem is the arithmetic heart of finite-state composition for disjoint unions. One can summarize each component inventory using finitely many saturated counters, combine two inventories by addition, and remain within the same finite summary system.

## Why this matters for sparse random graphs

In an Erdős–Rényi graph with edge probability $p_n=c_n/n$ and $c_n\to0$, components are overwhelmingly sparse and tree-like. A component-pruning rule deletes every component with fewer than $f(n)$ vertices. Under suitable growth conditions, a broader probabilistic program seeks zero-one laws: for each fixed logical property, the probability that the pruned graph satisfies it should tend to either $0$ or $1$.

Two deterministic mechanisms are needed in such an argument. First, order spectra of relevant tree classes must exhibit semilinear, hence eventually periodic, behavior. Second, a disjoint union must be describable through finitely saturated component counts. The theorems above establish the arithmetic calculus required by those mechanisms: periodic spectra survive finite logical combinations, while saturated multiplicities survive composition.

They do not, by themselves, estimate random component counts or prove a probabilistic limit law. Their role is more foundational: they identify exactly what arithmetic information a finite-state argument can preserve.

## The trap hidden inside an unrestricted cutoff

It is tempting to infer a sweeping principle: if a base spectrum is eventually periodic, then shifting it by a pruning cutoff should leave it eventually periodic. That principle is false when the cutoff may depend arbitrarily on the input.

For a spectrum $S$ and a function $f:\mathbb N\to\mathbb N$, define the **shifted spectrum**

$$
S_f=\{n\in\mathbb N:n-f(n)\in S\},
$$

where subtraction is truncated at zero. This models a residual size after a cutoff-sized contribution has been removed.

Now choose any target set $A\subseteq\mathbb N$ and define

$$
f_A(n)=
\begin{cases}
n,&n\in A,\\
n-1,&n\notin A.
\end{cases}
$$

For every positive $n$, the residual $n-f_A(n)$ is $0$ when $n\in A$ and $1$ when $n\notin A$. Taking the tiny base spectrum $S=\{0\}$ therefore gives

$$
n\in S_{f_A}\quad\Longleftrightarrow\quad n\in A
$$

for every $n>0$.

This is the **Arbitrary-Tail Encoding Theorem**: an input-dependent cutoff can encode any prescribed target set into the shifted version of the eventually periodic singleton spectrum $\{0\}$. The pruning function is not merely removing information; because it can inspect $n$ and react differently at every input, it acts as a communication channel.

## Powers of two break every fixed rhythm

To turn the encoding theorem into a concrete counterexample, choose

$$
A=\{1,2,4,8,16,\ldots\}=\{2^k:k\in\mathbb N\}.
$$

**Nonperiodicity Theorem.** The set of powers of two is not eventually periodic.

Suppose otherwise that it repeated beyond $N$ with positive period $q$. Choose a power $2^m$ larger than both $N$ and $q$. Periodicity would force $2^m+q$ to be another power of two. But

$$
2^m<2^m+q<2^m+2^m=2^{m+1},
$$

and there is no power of two strictly between two consecutive powers. This contradiction rules out every proposed period.

Combining this fact with arbitrary-tail encoding yields the sharp negative conclusion.

**Pruning Counterexample Theorem.** There exist an eventually periodic spectrum $S$ and a cutoff $f$ such that the shifted spectrum $S_f$ is not eventually periodic. One may take $S=\{0\}$ and let $f$ encode the powers of two as above.

The lesson is not that pruning is hopeless. It is that regularity cannot come from the base spectrum alone. It must also come from the cutoff.

## The boundary between structure and freedom

The positive and negative results fit together cleanly. Boolean operations and disjoint union are controlled: they combine finite summaries using fixed algebraic rules. Arbitrary input-dependent pruning is uncontrolled: it can consult the input and write an unrestricted bit into the residual size.

This distinction appears far beyond random graphs. In data analysis, thresholding can stabilize noise when the threshold follows a regular schedule, but an adaptively chosen threshold can overfit. In network resilience, removing small islands may expose a stable macroscopic core, but a size-dependent rule tailored to each network can create artificial patterns. In logic, finite-state composition succeeds because only bounded information is retained; an adversarial oracle defeats that bounded memory.

The natural next question is therefore constructive: which cutoffs are regular enough? A promising conjecture says that if $S$ has eventual period $q$ and $f(n)$ is eventually affine modulo $q$, then the set of $n$ satisfying $n-f(n)\in S$ is eventually periodic. Eventual constancy, affine growth, and periodic first differences are useful test classes.

Beyond that arithmetic boundary lie the deeper probabilistic tasks: developing finite-state composition for logical types, proving eventual periodicity for definable classes of finite trees, and obtaining component estimates uniform over the growing range allowed by sparse random-graph pruning. The present results supply the reusable deterministic skeleton—and the counterexample that says exactly why hypotheses on the pruning schedule are indispensable.

The broad moral is simple. Repetition survives operations that respect finite memory. It need not survive a rule with enough freedom to encode the answer it wants.