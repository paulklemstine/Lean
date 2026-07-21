# Thermodynamics of Mathematical Proof: Finite Erasure, Incompressibility, and Adversarial Verification

**Aristotle**  
**July 20, 2026**

## Abstract

We develop a finite model connecting proof search, information loss, and Landauer’s principle. A candidate derivation of depth $n$ is represented by a binary word of length $n$, so the search space contains exactly $2^n$ candidates. Selecting one candidate and discarding the rest produces an erased multiplicity

$$
E(n)=2^n-1,
$$

with recurrence $E(n+1)=2E(n)+1$. This multiplicity dominates the $n$ created binary choices at every depth and exceeds $2n$ for $n\ge 4$. If each discarded alternative is represented by an independent bit that is irreversibly reset, the associated Landauer work is exactly

$$
W_n=kT\ln 2\,(2^n-1).
$$

Two complementary information-theoretic results arise from the same cardinality. First, no injective encoding can represent every depth-$n$ derivation by a binary string shorter than $n$. Second, any black-box verifier querying fewer than $2^n$ candidates can miss a uniquely successful derivation. We combine these facts into an exponential-erasure witness theorem. The conclusions are explicitly model-relative: the erased-alternative count is not a universal entropy formula, and the verification bound applies to adversarial unstructured search rather than semantic checking with exploitable structure. The framework isolates fiber multiplicity as the common invariant behind logical irreversibility, finite incompressibility, and adversarial ambiguity.

## 1. Introduction

Mathematical proof is abstract, but every actual process that discovers, verifies, transmits, or stores a proof is physical. This distinction permits a precise question: when a reasoning process destroys information, what thermodynamic cost is forced by that destruction?

Landauer’s principle identifies the fundamental unit. Irreversibly resetting one unbiased bit at absolute temperature $T$ requires, in the ideal limit, at least $kT\ln 2$ of work dissipated as heat, where $k$ is Boltzmann’s constant. The principle attaches cost to logically irreversible operations, not to computation or deduction in general. An injective transformation preserves enough information to recover its input and can in principle be implemented reversibly. A many-to-one transformation merges distinguishable states; if the missing distinction is not retained elsewhere, information is erased.

Proof search naturally suggests many-to-one operations. A procedure may explore many candidate derivations and retain one certificate, or normalize many syntactically distinct arguments to one canonical form. Yet broad thermodynamic claims about proof can easily outrun their assumptions. A proof space may possess strong semantic structure; an efficient checker need not search it blindly; and a machine may never materialize all rejected alternatives. For this reason, we study an explicit finite model whose claims can be stated and proved exactly.

At depth $n$, a candidate derivation is a binary word of length $n$. Each coordinate records one of two possible inference choices. There are $2^n$ words. We model certification by retaining one word and discarding the remaining $2^n-1$. We then investigate four questions:

1. How quickly does the discarded multiplicity grow relative to the retained description?
2. What Landauer work follows under a specified independent-bit erasure convention?
3. Can every candidate be encoded losslessly in fewer than $n$ bits?
4. Can a verifier with fewer than $2^n$ black-box queries exclude a hidden unique proof?

The answers are respectively: exponentially, exactly $kT\ln 2(2^n-1)$, no, and no. All four answers are controlled by the same finite cardinality.

The model is intentionally austere. It does not assert an unconditional exponential lower bound for theorem proving, nor does it equate the number of rejected candidates with Shannon entropy in every implementation. Rather, it supplies a clean bridge among combinatorics, information theory, and thermodynamics, while making the boundary of each conclusion visible.

## 2. Finite derivation spaces

### 2.1 Candidate derivations

**Definition 2.1 (Binary derivation space).** For a nonnegative integer $n$, let

$$
D_n=\{0,1\}^n
$$

be the set of binary words of length $n$. An element $b=(b_1,\ldots,b_n)$ is called a candidate derivation of depth $n$.

The terminology records an abstract branching process. At each of $n$ stages, the bit $b_i$ chooses one of two available branches. No semantic validity predicate is imposed yet.

**Lemma 2.2 (Candidate count).** For every $n\ge 0$,

$$
|D_n|=2^n.
$$

**Proof sketch.** Each of the $n$ coordinates has two independent values. By the multiplication principle, the number of words is the product of $n$ factors equal to $2$, hence $2^n$. For $n=0$, the unique empty word gives $2^0=1$. $\square$

### 2.2 Selection and erased multiplicity

**Definition 2.3 (Erased multiplicity).** Suppose one distinguished element of $D_n$ is retained and every other candidate is discarded. Define

$$
E(n)=|D_n|-1.
$$

The word “erased” here denotes a logical model of selection. A physical energy interpretation requires the additional representation assumptions introduced in Section 3.

**Theorem 2.4 (Exact erased multiplicity).** For every $n\ge 0$,

$$
E(n)=2^n-1.
$$

**Proof sketch.** Substitute the candidate count $|D_n|=2^n$ into Definition 2.3. $\square$

**Theorem 2.5 (Creation–erasure comparison).** For every $n\ge 0$,

$$
n\le E(n).
$$

For every $n\ge 4$, the stronger strict inequality

$$
2n<E(n)
$$

holds.

**Proof sketch.** The first claim is equivalent to $n+1\le 2^n$. It holds at $n=0$ and is preserved under induction because doubling $2^n$ grows at least as fast as increasing $n+1$ by one. For the second claim, the base case is $8<15$ at $n=4$. If $2n<2^n-1$, then

$$
2(n+1)=2n+2<2^{n+1}-1,
$$

since the inductive hypothesis gives $2n+2<2(2^n-1)+1=2^{n+1}-1$ once $2^n\ge 3$. $\square$

The number $n$ measures the binary choices recorded in one retained derivation. The number $E(n)$ measures how many other candidates selection excludes. The theorem compares description depth to discarded population; it does not claim that $E(n)$ bits are intrinsically necessary to represent the uncertainty.

**Theorem 2.6 (One-level recurrence).** For every $n\ge 0$,

$$
E(n+1)=2E(n)+1.
$$

**Proof sketch.** Using Theorem 2.4,

$$
E(n+1)=2^{n+1}-1=2(2^n-1)+1=2E(n)+1.
$$

Combinatorially, every old candidate acquires two extensions. Relative to one newly retained extension, the discarded set contains two extensions of every previously discarded candidate and the unused extension of the previously retained one. $\square$

## 3. Entropy and Landauer accounting

### 3.1 Shannon entropy of a bit

For a finite probability distribution $p=(p_i)$, its Shannon entropy in natural units is

$$
H(p)=-\sum_i p_i\ln p_i,
$$

with the convention $0\ln 0=0$.

Consider an unbiased bit with distribution $u=(1/2,1/2)$ and a reset bit with distribution $r=(1,0)$. Then

$$
H(u)=-2\left(\frac12\ln\frac12\right)=\ln 2,
$$

whereas

$$
H(r)=0.
$$

Thus resetting an unbiased bit destroys exactly $\ln 2$ nats of Shannon entropy.

**Theorem 3.1 (One-bit Landauer unit).** At Boltzmann scale $k$ and absolute temperature $T$, the ideal Landauer work associated with the entropy reduction from an unbiased bit to a fixed bit is

$$
kT\bigl(H(u)-H(r)\bigr)=kT\ln 2.
$$

**Proof sketch.** Insert $H(u)=\ln 2$ and $H(r)=0$ into the left-hand side. $\square$

### 3.2 Independent-bit erasure model

**Definition 3.2 (Independent erasure work).** For real parameters $k$ and $T$ and a nonnegative integer $m$, define

$$
W(k,T,m)=kT\ln 2\,m.
$$

This definition models the irreversible reset of $m$ independently represented unbiased bits. It is additive because the entropy of independent bits is additive.

**Theorem 3.3 (Entropy-loss representation).** For every $m\ge 0$,

$$
W(k,T,m)=kT\bigl(H(u)-H(r)\bigr)m.
$$

**Proof sketch.** Apply Theorem 3.1 and multiply by $m$. $\square$

**Definition 3.4 (Proof-selection work).** Under the convention that each discarded candidate contributes one independently represented bit to be reset, define the work of selecting one depth-$n$ candidate by

$$
W_n=W(k,T,E(n)).
$$

This convention is a physical modeling assumption. It corresponds, for example, to an implementation carrying one flag for each rejected candidate and resetting all flags. It should not be confused with the entropy of a single uniformly distributed index in $D_n$, which is only $n\ln 2$.

**Theorem 3.5 (Exact proof-selection work).** Under Definition 3.4,

$$
W_n=kT\ln 2\,(2^n-1).
$$

**Proof sketch.** Substitute $E(n)=2^n-1$ from Theorem 2.4 into Definition 3.2. $\square$

**Theorem 3.6 (Linear Landauer lower comparison).** If $k\ge 0$ and $T\ge 0$, then for every $n\ge 0$,

$$
kT\ln 2\,n\le W_n.
$$

**Proof sketch.** Theorem 2.5 gives $n\le E(n)$. Since $kT\ln 2$ is nonnegative, multiplication preserves the inequality. The right-hand side is $kT\ln 2\,E(n)=W_n$. $\square$

### 3.3 What the work formula does and does not mean

The exponential work in Theorem 3.5 follows from an exponential number of independently reset records. It is not a universal lower bound on every implementation that selects one proof. If a device stores a uniformly random candidate merely as its $n$-bit index and resets that index, its Shannon entropy loss is $n\ln 2$, not $(2^n-1)\ln 2$. If the distribution over candidates is nonuniform, the entropy may be smaller still.

The invariant relevant to a general deterministic map $f:X\to Y$ is conditional uncertainty. For an observed output $y$, the fiber

$$
f^{-1}(y)=\{x\in X:f(x)=y\}
$$

lists inputs made indistinguishable by the output. Under a uniform conditional distribution on a fiber of size $M$, the lost information is $\ln M$. Under a nonuniform distribution it is the conditional Shannon entropy, bounded above by $\ln M$. The finite binary model isolates multiplicity first and then imposes a specific independent-record accounting convention.

This separation is essential. It prevents a category mistake in which a combinatorial count is automatically treated as physical entropy. Thermodynamic work belongs to an implementation and a probability law; multiplicity describes the logical map that implementation realizes.

## 4. Finite incompressibility

### 4.1 Short binary descriptions

**Definition 4.1 (Strictly short descriptions).** Let

$$
S_n=\bigcup_{j=0}^{n-1}\{0,1\}^j
$$

be the set of binary strings whose lengths are strictly less than $n$. For $n=0$, this union is empty.

**Lemma 4.2 (Short-description count).** For every $n\ge 0$,

$$
|S_n|=2^n-1.
$$

**Proof sketch.** There are $2^j$ strings of length $j$. Therefore

$$
|S_n|=\sum_{j=0}^{n-1}2^j=2^n-1
$$

by the finite geometric-series formula. The empty sum for $n=0$ is $0=2^0-1$. $\square$

**Theorem 4.3 (Finite incompressibility).** For every $n\ge 0$, no injective encoding

$$
c:D_n\longrightarrow S_n
$$

exists. Equivalently, no lossless scheme gives every depth-$n$ derivation a distinct binary description shorter than $n$.

**Proof sketch.** By Lemma 2.2, $|D_n|=2^n$, while Lemma 4.2 gives $|S_n|=2^n-1$. An injection from a larger finite set to a smaller one is impossible by the pigeonhole principle. $\square$

The theorem is uniform over the family, not individual. Some candidates may have much shorter descriptions, provided other candidates do not. Nor does the result depend on a programming language or universal machine. It is an exact finite precursor to incompressibility arguments in Kolmogorov complexity.

A useful corollary is that any lossless variable-length code for all of $D_n$ must assign length at least $n$ to at least one candidate. More generally, the count of descriptions shorter than $n-c$ is $2^{n-c}-1$, so at most that many candidates can receive such descriptions injectively. Most candidates cannot enjoy large uniform savings.

## 5. Adversarial verification

### 5.1 Query model

Let a verifier query a subset $Q\subseteq D_n$. A query reveals whether a candidate is successful. We assume no structural relation among answers: an adversary may choose the successful set after seeing $Q$, subject only to the stated condition that exactly one successful candidate exists.

**Theorem 5.1 (Adversarial coverage).** Let $Q\subseteq D_n$. If

$$
|Q|<2^n,
$$

then there exists a candidate $p\in D_n\setminus Q$ such that the validity assignment declaring $p$ uniquely successful and every other candidate unsuccessful is consistent with all-negative answers on $Q$.

**Proof sketch.** Since $|Q|<|D_n|$, the subset $Q$ is proper. Choose any $p\in D_n\setminus Q$. Declare $p$ successful and all candidates in $Q$ unsuccessful. Because $p$ was never queried, the transcript cannot distinguish this assignment from one having no success among the queried candidates. $\square$

**Corollary 5.2 (Worst-case exhaustive requirement).** In the unstructured black-box model, a verifier that must rule out the existence of a uniquely successful depth-$n$ derivation after receiving only negative answers needs $2^n$ queries in the worst case.

**Proof sketch.** Any smaller query set is defeated by Theorem 5.1. Querying all candidates plainly suffices. $\square$

This result concerns search, not ordinary certificate checking. Given a candidate proof and local inference rules, a semantic checker may validate it in time polynomial in its length. The theorem instead addresses discovery or exclusion when validity is an arbitrary hidden predicate. Its purpose is to identify the operational content of cardinality in the absence of structure.

## 6. Unified exponential witness

The preceding results can be packaged into one statement.

**Theorem 6.1 (Exponential erasure witness).** For every integer $n\ge 4$, the binary derivation family $D_n$ satisfies all of the following:

1. selecting one candidate discards exactly

   $$
   E(n)=2^n-1
   $$

   alternatives;
2. the discarded multiplicity obeys

   $$
   2n<E(n);
   $$

3. there is no injective encoding of all candidates by binary strings of length strictly below $n$; and
4. for every query set $Q\subseteq D_n$ with $|Q|<2^n$, there exists an unqueried candidate that can be designated as the unique successful derivation while every queried candidate is unsuccessful.

Under the independent-bit reset convention, the corresponding selection work is

$$
W_n=kT\ln 2\,(2^n-1).
$$

**Proof sketch.** Item 1 is Theorem 2.4, item 2 is the strict part of Theorem 2.5, item 3 is Theorem 4.3, and item 4 is Theorem 5.1. The work formula is Theorem 3.5. $\square$

The theorem makes no appeal to a contradictory assumption and excludes the small depths at which strict more-than-double domination fails. At $n=0,1,2,3$, the exact formula remains valid, but $2n<2^n-1$ does not hold uniformly.

## 7. Algorithms and numerical exploration

### 7.1 Direct accounting

Given $n$, $k$, and $T$, exact combinatorial accounting requires computing $2^n-1$. With arbitrary-precision integers, exponentiation by squaring uses $O(\log n)$ integer multiplications. If the output has $n+1$ bits, bit complexity must also reflect the cost of multiplying numbers of that size. For modest $n$, direct evaluation is immediate.

A table for $0\le n\le 10$ illustrates the transition:

| $n$ | $2^n$ candidates | $E(n)=2^n-1$ | $E(n)>2n$ |
|---:|---:|---:|:---:|
| $0$ | $1$ | $0$ | no |
| $1$ | $2$ | $1$ | no |
| $2$ | $4$ | $3$ | no |
| $3$ | $8$ | $7$ | yes |
| $4$ | $16$ | $15$ | yes |
| $5$ | $32$ | $31$ | yes |
| $10$ | $1024$ | $1023$ | yes |

The theorem uses the clean sufficient boundary $n\ge 4$, although the strict inequality already happens at $n=3$ because $6<7$. The stated boundary is therefore sufficient rather than minimal.

### 7.2 Constructing a compression collision

To demonstrate finite incompressibility computationally, assign every one of the $2^n$ derivations to one of only $2^n-1$ short descriptions. A collision must occur. A program can detect the first pair with the same code by maintaining a dictionary from descriptions to prior derivations. This takes $O(2^n)$ assignments and $O(2^n)$ memory in the worst case, aside from word-length factors.

The collision is not merely a programming accident. It is guaranteed for every attempted total assignment, because the codomain is too small.

### 7.3 Adversarial witness construction

Given a query set $Q$ with $|Q|<2^n$, enumerate $D_n$ until finding the first candidate outside $Q$. The resulting word is a witness for Theorem 5.1. With hash-set membership, the scan uses at most $2^n$ membership tests and constant auxiliary space beyond storage of $Q$ and the current word. If queries are represented as integers from $0$ through $2^n-1$, the first missing integer can be found by sorting in $O(|Q|\log|Q|)$ time or by a Boolean presence array in $O(2^n)$ time and space.

## 8. Applications and interpretation

### 8.1 Proof normalization

A normalization map sends proof terms to canonical representatives. When many terms normalize to the same output, the map has nontrivial fibers. If the original term must be recoverable, a reversible implementation must retain enough side information to identify its position in the fiber. If that information is erased, conditional entropy determines the ideal thermodynamic cost.

The binary derivation family supplies a target multiplicity for normalization systems in which many bureaucratic derivations collapse to one normal proof. Establishing such a result for a concrete calculus would require an explicit syntax, reduction relation, termination theorem, and exact fiber count.

### 8.2 Reversible verification

A verifier can avoid overwriting its transcript by retaining intermediate states. This shifts cost from erasure to memory. If memory is limited, it may keep checkpoints and recompute missing segments when reversing, producing a time–space tradeoff analogous to reversible pebble games. The adversarial coverage theorem identifies how much information an unstructured verifier must distinguish; a reversible analysis would determine how that information may be retained or reconstructed.

### 8.3 Kolmogorov complexity

The finite incompressibility theorem is machine-independent because it compares raw finite sets. Kolmogorov complexity strengthens the idea by fixing a universal prefix-free machine and asking for shortest program length. Counting implies that many strings of length $n$ have complexity near $n$, up to machine-dependent constants. A thermodynamic interpretation would then ask where a verifier obtains the missing information when reconstructing an incompressible proof from a shorter certificate.

### 8.4 Shared lemmas and compositional accounting

Independent proof obligations have additive Shannon entropy under product distributions, so ideal erasure costs add. Shared lemmas introduce correlations: information stored once can serve several obligations. The reduction in total work should be measured by mutual information rather than by naive subtraction of syntax sizes. This suggests a quantitative notion of thermodynamic reuse in libraries of arguments.

## 9. Limitations

Four limitations delimit the scope of the results.

First, candidate multiplicity is not proof difficulty. The space $D_n$ contains every binary path, but a deductive calculus may reject most paths locally or guide search using semantics.

Second, discarded alternatives are not automatically independent erased bits. The exact exponential work formula assumes one resettable record per discarded candidate. Different encodings and probability laws yield different entropy losses.

Third, the adversarial verification theorem applies to a black-box validity predicate. It does not imply that checking a supplied proof requires exponential time.

Fourth, finite incompressibility rules out uniform strict compression of all candidates, not compression of a particular structured candidate. It is related to, but does not itself establish, a universal-machine statement about Kolmogorov complexity.

These limitations are strengths of the formulation: each conclusion can be traced to an explicit assumption rather than hidden in a metaphor.

## 10. Future research

A natural next step is a fiber-entropy theorem for finite terminating normalization systems. Given a probability law on proof terms, the destroyed information should equal conditional entropy. The expected logarithm of fiber size should be attained exactly when the conditional distribution is uniform on each fiber and should otherwise be a strict upper bound.

A second direction is a Bennett-style tradeoff for verification. One seeks proof-system families in which reversible verification with subexponential auxiliary space requires superlinear recomputation, while an irreversible linear-time implementation destroys a linear transcript.

Third, the abstract binary family can be realized inside a finitely presented strongly normalizing calculus. The target is a short conclusion with a short normal proof but exponentially many bounded-length preimages under normalization.

Fourth, finite incompressibility can be lifted to prefix-free Kolmogorov complexity, with explicit additive constants and a clear account of how a universal verifier receives information absent from a short certificate.

Finally, compositional Landauer accounting should quantify the savings generated by shared lemmas. For independent obligations, work is expected to add; for correlated obligations, mutual information should measure the reduction.

## 11. Conclusion

The finite binary model exhibits a precise common structure behind proof search, information loss, and thermodynamic accounting. At depth $n$, there are $2^n$ candidate derivations. Selecting one leaves $2^n-1$ alternatives; no strictly shorter binary code names every candidate uniquely; and every sub-exhaustive black-box verifier leaves room for a hidden unique success. Under an explicit independent-record reset model, the same multiplicity yields work $kT\ln 2(2^n-1)$.

The central invariant is not “proof” in isolation but the multiplicity of distinctions collapsed by a physical operation. Logical maps determine which alternatives become indistinguishable; probability distributions determine how much information is lost; physical implementations determine whether that information is preserved, recomputed, or erased. Within that separation of roles, the thermodynamics of mathematical reasoning becomes a concrete finite theory rather than a metaphor.