# Size-Indexed Information Erasure and Landauer Dissipation in Finite Decision Families

**Author:** Aristotle  
**Date:** 2026-07-30

## Abstract

We study the thermodynamic lower bounds induced by logical information loss in families of finite deterministic decision procedures indexed by input size. At size $n$, a procedure is a map $f_n:A_n\to B_n$ from a finite input state space to an output state space. In the uniform finite-state model, its erased information is

$$
e_n=\log_2|A_n|-\log_2|f_n(A_n)|,
$$

where $f_n(A_n)$ is the image of the map. For an arbitrary real-valued lower-bound function $b:\mathbb N\to\mathbb R$, we define the condition of discarding at least $b(n)$ bits by $b(n)\le e_n$ for every $n$. We prove a counting criterion for this condition and derive a general size-indexed Landauer inequality

$$
b(n)k_BT\ln2\le e_nk_BT\ln2
$$

for nonnegative Boltzmann constant $k_B$ and temperature $T$. We also establish a strict form under positive physical parameters, a linear-growth corollary, an additive bound for arbitrary finite workloads, and a theorem transferring unbounded logical erasure to unbounded thermodynamic cost. The state spaces may vary freely with $n$, and the lower-bound function need not be integral, monotone, or uniform in form. Numerical examples illustrate truncation maps, binary decision maps, linear families, and cumulative workloads. The framework provides a general bridge from finite counting arguments to asymptotic physical resource bounds while clearly identifying the scope of the cardinality-based model.

## 1. Introduction

Landauer’s principle connects logical irreversibility with thermodynamic dissipation. When one unbiased logical bit is irreversibly erased in a system at absolute temperature $T$, the characteristic minimum energy transferred as heat is $k_BT\ln2$. The statement concerns an ideal lower limit, not the typically much larger consumption of an actual device. Its conceptual importance is that information processing cannot always be separated from physics: merging distinguishable logical states has a physical price.

A single erasure operation is only the local picture. In theoretical computer science, one usually studies a family of procedures indexed by an input-length or problem-size parameter $n$. The natural question is therefore asymptotic: if the amount of information discarded by the size-$n$ procedure grows according to a function $b(n)$, what can be concluded about the corresponding family of Landauer costs?

This paper answers that question in a finite uniform model. Each procedure may have its own input type and output type; no common state space is required across sizes. The central theorem accepts an arbitrary real-valued lower bound $b(n)$ on logical erasure. This generality separates the physical translation from the combinatorial argument that supplies $b$. Once a counting or information-theoretic analysis proves $b(n)\le e_n$, the thermodynamic conclusion follows by multiplication by the nonnegative energy-per-bit factor.

Five concrete results are developed. First, a logarithmic image-cardinality inequality implies the desired bit-loss condition. Second, any such condition yields a pointwise Landauer lower bound. Third, strict bit loss yields strict energetic separation when the physical parameters are positive. Fourth, the pointwise theorem specializes to linear rates and sums over arbitrary finite workloads. Fifth, unbounded guaranteed erasure forces unbounded Landauer cost at every fixed positive temperature.

The proofs are elementary in algebraic complexity, but the abstraction is useful. It identifies exactly which hypotheses are needed, avoids unnecessary uniformity assumptions, and permits logical bounds obtained in one domain to be transported directly into physical lower bounds.

## 2. Finite decision families

### 2.1 State spaces and images

For every $n\in\mathbb N$, let $A_n$ be a finite set of possible input states and let $B_n$ be a set with decidable equality, so that distinct outputs can be counted. A **size-indexed finite decision family** is a sequence of deterministic maps

$$
f_n:A_n\to B_n.
$$

The terminology “decision” is broad: the output need not be Boolean. It may be a class label, finite summary, terminal state, compressed representation, or any other value in $B_n$. Only outputs actually attained by the procedure contribute to its surviving distinctions. Define the image

$$
I_n=f_n(A_n)=\{f_n(a):a\in A_n\}
$$

and its cardinality $|I_n|$.

### 2.2 Erased information

Under a uniform prior on the finite input states, the logarithmic state count $\log_2|A_n|$ is the number of bits needed to distinguish all input possibilities. After observing only the output, at most $\log_2|I_n|$ bits of state-count information remain. This motivates the following definition.

**Definition 2.1 (Cardinality-based erased information).** The erased information of $f_n$ is

$$
e_n=\log_2|A_n|-\log_2|I_n|.
$$

When $A_n$ is nonempty, $I_n$ is nonempty and the logarithms have their usual counting interpretation. The formula also has a direct ratio form,

$$
e_n=\log_2\frac{|A_n|}{|I_n|}.
$$

The quantity need not be an integer because the ratio of cardinalities need not be a power of two.

If $f_n$ is injective, then $|I_n|=|A_n|$ and $e_n=0$. At the opposite extreme, if $f_n$ is constant on a nonempty domain, then $|I_n|=1$ and $e_n=\log_2|A_n|$. Thus the model detects the collapse of global distinguishability.

**Definition 2.2 (Guaranteed size-indexed discard).** Let $b:\mathbb N\to\mathbb R$. The family $(f_n)$ **discards at least $b(n)$ bits** when

$$
\forall n\in\mathbb N,\qquad b(n)\le e_n.
$$

No positivity assumption on $b$ is needed for the general implication, although useful lower bounds are ordinarily nonnegative. Likewise, $b$ need not be monotone. This permits irregular families and sparse lower-bound arguments.

### 2.3 Thermodynamic cost model

**Definition 2.3 (Landauer cost).** For a real-valued bit loss $q$, Boltzmann constant $k_B$, and absolute temperature $T$, define

$$
\mathcal L(q;k_B,T)=q\,k_BT\ln2.
$$

The physically standard regime has $k_B>0$ and $T\ge0$. We retain nonnegative parameters for weak inequalities and require strict positivity only where strict order or division is used. The factor

$$
L_T=k_BT\ln2
$$

is the Landauer energy scale per erased bit.

This definition isolates the exact idealized cost associated with the information-loss measure. It should not be confused with total device energy, which includes switching losses, control, communication, leakage, error correction, and other implementation-dependent effects.

## 3. From counting to erasure

The first result packages the elementary counting step used in applications.

**Theorem 3.1 (Logarithmic image-count criterion).** Suppose that for every $n$,

$$
b(n)+\log_2|I_n|\le\log_2|A_n|.
$$

Then the family discards at least $b(n)$ bits; equivalently,

$$
b(n)\le e_n
$$

for every $n$.

**Proof sketch.** Substitute the definition $e_n=\log_2|A_n|-\log_2|I_n|$. Subtracting $\log_2|I_n|$ from the assumed inequality gives exactly $b(n)\le e_n$. The argument is pointwise and therefore imposes no relation between state spaces at different sizes. $\square$

This criterion is useful because combinatorial analyses often provide upper bounds on the number of distinct outputs. For example, if $|A_n|=2^n$ and $|I_n|\le2^{r(n)}$, monotonicity of the logarithm gives

$$
e_n\ge n-r(n).
$$

Thus one may choose $b(n)=n-r(n)$. In a Boolean decision procedure with both answers attainable, $|I_n|=2$, and an $n$-bit input space gives $e_n=n-1$. A yes-or-no answer can preserve at most one bit of global cardinality information about the input.

The erased-information measure is global. It compares the number of all inputs with the number of observed output classes. It does not assert that every output fiber has equal size, nor does it by itself measure Shannon conditional entropy under a nonuniform distribution. These distinctions are discussed in Section 8.

## 4. Pointwise thermodynamic bounds

### 4.1 The main lower bound

**Theorem 4.1 (Size-indexed Landauer lower bound).** Let $(f_n)$ be a size-indexed finite decision family and let $b:\mathbb N\to\mathbb R$ satisfy $b(n)\le e_n$ for every $n$. If $k_B\ge0$ and $T\ge0$, then for every $n$,

$$
b(n)k_BT\ln2\le\mathcal L(e_n;k_B,T).
$$

Equivalently,

$$
b(n)k_BT\ln2\le e_nk_BT\ln2.
$$

**Proof sketch.** Because $k_B\ge0$, $T\ge0$, and $\ln2>0$, the common factor $k_BT\ln2$ is nonnegative. Multiplication of $b(n)\le e_n$ by this factor preserves order. The right-hand side is the definition of $\mathcal L(e_n;k_B,T)$. $\square$

The theorem is independent of the origin of $b$. A bound may come from cardinality, coding theory, a structural analysis of a procedure, or another argument. The thermodynamic step is modular: every valid logical lower bound can be inserted without changing the proof.

The hypotheses allow $T=0$ because only a weak inequality is claimed. In that boundary case both displayed costs vanish. The theorem should therefore be read as an algebraic lower-bound transfer in a model whose physically informative regime normally has $T>0$.

### 4.2 Strict separation

**Theorem 4.2 (Strict size-indexed Landauer bound).** Suppose

$$
b(n)<e_n
$$

for every $n$. If $k_B>0$ and $T>0$, then for every $n$,

$$
b(n)k_BT\ln2<\mathcal L(e_n;k_B,T).
$$

**Proof sketch.** The factor $k_BT\ln2$ is strictly positive. Multiplication by a positive real number preserves strict inequality, giving the result. $\square$

Strict positivity cannot simply be weakened to nonnegativity in this theorem. If either $k_B=0$ or $T=0$, both products are zero even when $b(n)<e_n$. Thus the assumptions precisely distinguish weak monotonicity from strict monotonicity.

### 4.3 A linear corollary

**Corollary 4.3 (Linear dissipation lower bound).** Let $c\in\mathbb R$. If

$$
cn\le e_n
$$

for every $n$, then for nonnegative $k_B,T$ and every $n$,

$$
cn\,k_BT\ln2\le\mathcal L(e_n;k_B,T).
$$

**Proof sketch.** Apply Theorem 4.1 with $b(n)=cn$. $\square$

For $c>0$, this is a genuine linear lower bound in the size parameter. The energetic rate is the logical rate $c$ multiplied by $k_BT\ln2$. No asymptotic notation is needed: the inequality holds pointwise for every $n$.

## 5. Workload aggregation

Pointwise lower bounds extend additively to finite collections of sizes.

**Theorem 5.1 (Finite-workload dissipation lower bound).** Let $S\subset\mathbb N$ be finite. If $b(n)\le e_n$ for every $n$ and $k_B,T\ge0$, then

$$
\left(\sum_{n\in S}b(n)\right)k_BT\ln2
\le
\sum_{n\in S}\mathcal L(e_n;k_B,T).
$$

**Proof sketch.** Theorem 4.1 gives $b(n)k_BT\ln2\le\mathcal L(e_n;k_B,T)$ for each $n\in S$. Sum these inequalities over $S$. Distributivity yields

$$
\sum_{n\in S}b(n)k_BT\ln2
=
\left(\sum_{n\in S}b(n)\right)k_BT\ln2,
$$

which is the claimed left-hand side. $\square$

The set $S$ can be arbitrary and need not be an interval. Consequently, the theorem applies to heterogeneous benchmark suites and nonconsecutive schedules. It also handles multiplicities after representing repeated tasks separately or weighting the pointwise bounds by nonnegative task counts.

**Corollary 5.2 (Consecutive linear workload).** If $cn\le e_n$ for every $n$ and a workload contains one task of each size $1,\ldots,N$, then

$$
c\frac{N(N+1)}2k_BT\ln2
\le
\sum_{n=1}^{N}\mathcal L(e_n;k_B,T).
$$

**Proof sketch.** Apply Theorem 5.1 with $S=\{1,\ldots,N\}$ and $b(n)=cn$, then use $\sum_{n=1}^{N}n=N(N+1)/2$. $\square$

This corollary illustrates an important scaling effect: a linear per-instance floor produces a quadratic cumulative floor when all sizes through $N$ are processed once.

## 6. Unbounded logical and thermodynamic growth

We now state the asymptotic consequence without imposing a particular growth rate.

**Definition 6.1 (Unbounded above).** A function $b:\mathbb N\to\mathbb R$ is unbounded above if

$$
\forall C\in\mathbb R,\ \exists n\in\mathbb N\text{ such that }C<b(n).
$$

**Theorem 6.2 (Unbounded dissipation from unbounded discard).** Suppose $b(n)\le e_n$ for every $n$, and suppose $b$ is unbounded above. Fix $k_B>0$ and $T>0$. Then the sequence of Landauer costs is unbounded above: for every $E\in\mathbb R$, there exists $n$ such that

$$
E<\mathcal L(e_n;k_B,T).
$$

**Proof sketch.** Define $L=k_BT\ln2$. The positivity assumptions imply $L>0$. Given $E\in\mathbb R$, apply the unboundedness of $b$ to the threshold $E/L$. There is an $n$ satisfying

$$
\frac{E}{L}<b(n).
$$

Multiplication by $L>0$ gives $E<b(n)L$. Theorem 4.1 gives $b(n)L\le\mathcal L(e_n;k_B,T)$. Transitivity yields $E<\mathcal L(e_n;k_B,T)$. $\square$

The theorem is stronger than a statement about divergence along a prescribed monotone sequence: $b$ itself need not be monotone. It asserts only that arbitrarily high logical guarantees occur somewhere in the family, and concludes that arbitrarily high thermodynamic costs occur correspondingly.

Positive temperature is essential to this transfer. If $T=0$ in the algebraic model, then $L=0$ and all modeled Landauer costs vanish, regardless of $e_n$. Positivity is also required to divide by $L$ in the proof.

## 7. Algorithms and numerical examples

### 7.1 Finite-state erasure audit

For a concrete finite map, erased information can be computed by enumerating the domain, evaluating the procedure, and counting distinct outputs.

**Algorithm 7.1 (Image-cardinality erasure audit).** Given a finite list representing $A_n$ and a deterministic function $f_n$, compute the set of values $\{f_n(a):a\in A_n\}$, then return

$$
\log_2|A_n|-\log_2|f_n(A_n)|.
$$

With hashing, evaluation requires $O(|A_n|)$ function calls and expected $O(|A_n|)$ time, plus storage for at most $|I_n|$ outputs. Sorting instead of hashing gives $O(|A_n|\log|A_n|)$ time under a comparison model.

### 7.2 Prefix retention

Let $A_n=\{0,1\}^n$, and let $f_n$ retain the first $r(n)$ bits. Then

$$
|A_n|=2^n,\qquad |I_n|=2^{r(n)},
$$

so

$$
e_n=n-r(n).
$$

At $T=300$ kelvin with $k_B=1.380649\times10^{-23}$ joules per kelvin, the energy scale is

$$
k_BT\ln2\approx2.87098\times10^{-21}\text{ joules per bit}.
$$

For $n=64$ and $r(n)=16$, the map erases $48$ bits and has ideal cost

$$
48k_BT\ln2\approx1.37807\times10^{-19}\text{ joules}.
$$

### 7.3 Binary decisions

If $A_n=\{0,1\}^n$ and both Boolean outputs occur, then $|I_n|=2$ and

$$
e_n=n-1.
$$

At $n=128$, the output preserves only one bit of global state-count information, while $127$ bits are erased in this model. The lower bound is $127k_BT\ln2$.

### 7.4 Workload calculation

Suppose $e_n\ge n/2$ for every size $1\le n\le1000$. The guaranteed cumulative erasure is

$$
\sum_{n=1}^{1000}\frac n2
=
\frac12\frac{1000\cdot1001}{2}
=250250\text{ bits}.
$$

At $300$ kelvin, the corresponding workload floor is approximately

$$
250250\,k_BT\ln2\approx7.1846\times10^{-16}\text{ joules}.
$$

The number is small by macroscopic standards, but it is a lower bound for an idealized logical component, not an estimate of total device consumption. Its chief role is to reveal scaling and impossibility.

## 8. Scope, applications, and limitations

The framework applies whenever a computation can be represented as a deterministic map on a finite input state space. Potential examples include lossy summaries, classifiers, many-to-one database queries, state-machine transitions, compression stages that intentionally omit information, and decision procedures whose final answer retains far fewer distinctions than their input.

The model is deliberately based on image cardinality. This makes it robust and easy to compute, but also sets clear limits.

First, cardinality alone corresponds most naturally to uniform state counting. For a nonuniform random input $X_n$, the average information loss is better described by

$$
H(X_n)-H(f_n(X_n)),
$$

where $H$ is Shannon entropy. A rare region of the state space can dominate cardinality while contributing little probability mass.

Second, global image size does not determine the largest output fiber. The fibers

$$
f_n^{-1}(y)=\{a\in A_n:f_n(a)=y\}
$$

may be highly unequal. A large fiber demonstrates that many inputs share an output, but converting a worst-fiber statement into the global erased-information quantity may require uniformity or distributional assumptions.

Third, the results concern irreversible descriptions of the map. A reversible implementation may preserve auxiliary history sufficient to distinguish preimages. Such an implementation can avoid immediate logical erasure by paying in memory, circuit structure, runtime, or later uncomputation. The lower bounds do not say that merely evaluating a many-to-one mathematical function must erase information at the instant its output is produced; they apply when the other distinctions are genuinely discarded.

Fourth, $\mathcal L$ is an ideal lower-bound model. Actual energy consumption is not inferred from it without a detailed physical implementation. The inequalities remain valuable because they establish floors and scaling consequences independent of engineering overhead.

## 9. Further research

Several extensions follow naturally.

A **composition increment theorem** would study two stages $f_n:A_n\to B_n$ and $g_n:B_n\to C_n$. If the composition erases at least $c(n)$ more bits than $f_n$ alone, one expects its Landauer cost to exceed that of $f_n$ by at least $c(n)k_BT\ln2$ for nonnegative parameters.

A **worst-fiber theorem** would relate a fiber containing at least $2^{b(n)}$ inputs to a $b(n)$-bit loss. Such a statement requires care: a single large fiber does not automatically control the global image-cardinality difference without an additional uniform-fiber or entropy hypothesis. Finding the sharp hypothesis, or a minimal finite counterexample to an overstrong version, is a concrete problem.

For **polynomial logical loss**, a bound $b(n)\ge cn^p$ with $c>0$ and natural $p$ gives the immediate finite-sum inequality

$$
ck_BT\ln2\sum_{n=0}^{N}n^p
\le
\sum_{n=0}^{N}\mathcal L(e_n;k_B,T).
$$

Deriving an explicit elementary constant times $N^{p+1}$ would turn this into a standard asymptotic workload theorem.

A **reversible-history tradeoff** should compare the maximum fiber size with the number of states in an auxiliary history register. Intuitively, reversibility requires enough history labels to distinguish inputs that would otherwise collide at the same output.

Finally, an **expected-erasure extension** should replace logarithmic cardinality by Shannon entropy for nonuniform finite distributions. For rational probabilities, all expectations are finite sums, making exact numerical and symbolic investigation possible.

## 10. Interpretation and design implications

The factorization of the bound into logical and physical terms is useful for design analysis. The function $b(n)$ describes architecture-independent information loss at the chosen interface: it records how many distinctions are guaranteed to disappear. The factor $k_BT\ln2$ describes the energy scale of the environment. Changing temperature rescales every bound but does not alter its dependence on $n$; changing the decision procedure can alter $b(n)$ and therefore change the asymptotic form itself.

This separation also clarifies what optimization can and cannot accomplish. Better transistors may reduce overhead and move a device closer to its ideal floor, but they do not invalidate a lower bound derived from genuine erasure. Conversely, changing an irreversible architecture into a reversible one can alter the premise by retaining history rather than discarding it. Such a redesign does not contradict the theorem: it changes the map describing the full physical state, generally enlarging the output with auxiliary information.

There is an important distinction between the visible answer and the complete final state. If a Boolean procedure produces one answer bit while preserving a reversible transcript, the visible projection is many-to-one but the complete state transformation may be injective. Applying the present analysis to the visible projection describes the information absent from that projection. Applying thermodynamic conclusions requires the further physical assertion that the missing distinctions are actually erased rather than stored elsewhere. This is why the formulation speaks of procedures that discard information, not merely functions that have small codomains.

For comparative studies, one may normalize by task count, input size, or retained output information. For a finite workload $S$, the average guaranteed floor per task is

$$
\frac{1}{|S|}\left(\sum_{n\in S}b(n)\right)k_BT\ln2,
$$

provided $S$ is nonempty. The floor per input bit can similarly be studied through $b(n)/n$ when $n>0$. A positive lower limit of this ratio indicates persistent linear erasure density. If instead $b(n)/n$ tends to zero, total erasure may still be unbounded, and Theorem 6.2 still applies, but the loss is sublinear relative to input length.

Finally, the framework distinguishes pointwise and aggregate claims. A pointwise bound constrains every size separately. An aggregate bound can remain large even if individual costs fluctuate. Unboundedness requires only arbitrarily large witnesses and says nothing about monotonicity. Keeping these quantifiers explicit prevents common overinterpretations and allows the same theory to describe regular asymptotic families and highly irregular finite-state systems.

## 11. Conclusion

A family of decision procedures can discard an amount of information that depends on input size. Once this loss is bounded below by a function $b(n)$, Landauer’s energy scale converts it directly into a pointwise thermodynamic lower bound. The conversion preserves strict inequalities under positive parameters, preserves linear growth rates, adds over finite workloads, and transfers unbounded logical loss into unbounded energy cost.

The mathematical mechanism is concise: count input distinctions, count surviving output distinctions, subtract their base-two logarithms, and multiply by $k_BT\ln2$. Its value lies in modularity. Combinatorial reasoning supplies the information-loss function; thermodynamics supplies the conversion factor; order and finite summation carry the bound across scales. In this way, the distinctions that a computation forgets become a quantifiable physical resource.