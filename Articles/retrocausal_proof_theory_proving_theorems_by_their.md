# Reasoning Backward Without Reasoning Wrong

## What consequences can—and cannot—tell us about a theorem

A detective enters a room after the event. The mechanism is hidden, but its traces are everywhere: a broken glass, a wet floor, a stopped clock. Can the detective reconstruct what happened from the consequences alone?

Mathematics often invites the same reversal. Ordinarily, a proof begins with assumptions and moves forward until it reaches a conclusion. But theorem discovery rarely feels so linear. Mathematicians guess a statement, calculate what it would imply, test those implications, and then use the resulting pattern to hunt for a proof. In computation, this strategy is irresistible: if the consequences of a proposed theorem are easy to check, perhaps enough successful checks can confirm the theorem itself.

There is a sharp logical boundary here. Verified consequences can be extraordinarily useful for *search*, but they cannot by themselves justify their cause. To reason backward soundly, one needs an additional object: a certificate showing that the consequences jointly force the proposed theorem. This distinction turns a seductive but invalid inference into a rigorous method.

## The tempting reversal

Let $P$ be a proposed theorem and let $Q$ be one of its consequences. We know

$$
P\Longrightarrow Q.
$$

Suppose we also verify $Q$. May we conclude $P$? No. This is the familiar error of affirming the consequent. “If it rains, the pavement is wet” and “the pavement is wet” do not imply that it rained; a sprinkler would produce the same observation.

The obstacle is not removed by choosing a respectable consequence, or even by insisting that the consequence be true and logically coherent. The proposition $\top$—the always-true statement—is a consequence of every proposition whatsoever. It is true, coherent, and completely uninformative. Even the false proposition $\bot$ implies $\top$. Thus the three facts

$$
P\Longrightarrow\top,\qquad \top,\qquad \text{and “$\top$ is coherent”}
$$

cannot distinguish a true candidate $P$ from a false one.

This yields the first boundary theorem.

**Uniform Confirmation Boundary.** For a fixed proposition $P$, the rule

$$
\text{for every $Q$, if $P\Rightarrow Q$ and $Q$ is true, then $P$ is true}
$$

is valid if and only if $P$ is already true.

The proof is almost mischievously simple. If the rule is available, choose $Q=\top$. Since $P\Rightarrow\top$ and $\top$ is true, the rule returns $P$. Conversely, if $P$ is already known, then any proposed consequence and its verification are irrelevant: we may simply return $P$.

The theorem exposes the danger of an unrestricted backward rule. If it worked for every $P$ and $Q$, then taking $P=\bot$ and $Q=\top$ would prove falsehood. More broadly, the rule would prove every proposition. A universal consequence-to-cause principle therefore collapses logical distinction rather than creating a new route to knowledge.

## Coherence is real—but not enough

Now replace one consequence by a finite list $Q_1,\ldots,Q_n$. Call the list **jointly verified** when every $Q_i$ is true. Call it **coherent** when their joint truth does not imply falsehood. Joint verification guarantees coherence: if all the $Q_i$ hold, then the claim that their conjunction leads to falsehood cannot itself be sustained without contradiction.

But coherence remains weaker than recovery. A list can be perfectly consistent while saying nothing about $P$. The one-item list $[\top]$ is again the universal control: every candidate implies it, it is verified, and it is coherent. Yet it does not recover $\bot$ or any other unsupported proposition.

The missing ingredient is a **backward certificate**:

$$
(Q_1\land\cdots\land Q_n)\Longrightarrow P.
$$

Once this implication has been established, backward reasoning is sound. If every $Q_i$ has been verified, their conjunction holds; the certificate then yields $P$. The certificate is not a mysterious new kind of causation. It is the exact logical bridge required to reverse direction.

For one consequence, having both $P\Rightarrow Q$ and $Q\Rightarrow P$ is simply equivalence:

$$
P\Longleftrightarrow Q.
$$

For many consequences, the same idea becomes

$$
P\Longleftrightarrow(Q_1\land\cdots\land Q_n).
$$

This motivates a precise definition. A family $Q_1,\ldots,Q_n$ is **consequence-stable for $P$** when two conditions hold: first, $P$ implies every $Q_i$; second, their conjunction implies $P$. The Consequence Stability Theorem says that this is exactly equivalent to the displayed biconditional. Conjunctions provide a basic nonempty class: $A\land B$ is consequence-stable with respect to the list $[A,B]$.

Two useful principles follow. If one member $R$ of a verified list already satisfies $R\Rightarrow P$, then $P$ is recovered immediately. And if a base list has a backward certificate, adding further verified consequences cannot destroy recovery: the original verified facts are still present.

## From logical validity to search

If consequences cannot manufacture truth, why reason from them at all? Because proof discovery is also a search problem.

Imagine a finite set $C$ of candidate objects and a list of tests. A candidate survives when it passes every test. Let $S$ denote the survivor set:

$$
S=\{a\in C: a\text{ passes every test}\}.
$$

Three elementary facts become powerful design rules.

First, filtering never enlarges the search space:

$$
S\subseteq C,
$$

so $|S|\le |C|$. Second, if even one candidate in $C$ fails, then the reduction is strict: $|S|<|C|$. Third, completeness is preserved: if the desired target belongs to $C$ and passes every test, then it remains in $S$.

If the tests isolate a unique target $t$, then passing all tests supplies a backward certificate for equality with $t$:

$$
\bigl(\text{$a$ passes every test}\bigr)\Longrightarrow a=t.
$$

Here the consequences perform two different jobs. Computationally, they prune candidates. Logically, uniqueness turns them into a certificate. Search reduction alone is not proof; search reduction plus a checked uniqueness implication is.

A natural measure of pruning power is information gain. When $S$ is nonempty, define

$$
I=\log_2\frac{|C|}{|S|}.
$$

Each bit represents a factor of two removed from the candidate space. This quantity measures semantic compression, not necessarily the length of the final proof. A test may eliminate millions of candidates yet require an expensive certificate, while a short direct argument may bypass the search entirely.

## Eight numbers, one survivor

A small arithmetic example makes the architecture visible. Begin with the natural numbers below $8$:

$$
C=\{0,1,2,3,4,5,6,7\}.
$$

Apply three tests to $n$:

$$
n>0,\qquad 2\mid n,\qquad 3\mid n.
$$

The positivity test removes $0$. Divisibility by $2$ retains the positive even candidates $2,4,6$. Divisibility by $3$ retains $3$ and $6$. Their intersection is

$$
S=\{6\}.
$$

Thus the checks compress eight candidates to one, a survivor ratio of

$$
\frac{|S|}{|C|}=\frac18,
$$

or an information gain of $3$ bits. More importantly, for any natural number $n<8$, the conjunction

$$
n>0\land 2\mid n\land 3\mid n
$$

implies $n=6$. That implication is the backward certificate. Verification of the three arithmetic facts then establishes the equality.

Notice what has—and has not—happened. The tests do not infer an arbitrary antecedent from its effects. They characterize a unique object inside a declared finite universe. The range bound $n<8$ matters: without it, $12$, $18$, and infinitely many other positive multiples of $6$ would also pass.

## A disciplined “retrocausal” workflow

The word *retrocausal* is best understood here as a metaphor for discovery, not as a reversal of logical time. A sound consequence-guided workflow has four stages:

1. **Choose candidates.** Specify the finite or otherwise controlled space in which a solution is sought.
2. **Derive necessary checks.** Find properties that every genuine solution must satisfy.
3. **Verify and filter.** Evaluate those properties to remove impossible candidates.
4. **Certify recovery.** Prove that the surviving pattern, jointly, implies the desired conclusion.

The fourth stage is indispensable. Without it, the procedure is hypothesis testing. With it, the procedure is proof.

This resembles scientific inference in a useful but limited way. Predictions can make a theory compelling when alternatives are excluded; they do not deductively establish the theory merely because they came true. A mathematical backward certificate plays the role of an exact exclusion argument: among the possibilities under consideration, the observations uniquely force the claim.

The same architecture appears in constraint solving, program synthesis, diagnosis, and cryptanalysis. Local tests rapidly prune a combinatorial universe; a final certificate guarantees that what remains truly solves the original problem. The lesson is not that forward proof has been superseded. It is that forward consequences can organize the route to a proof when their backward sufficiency is made explicit.

## Compression: the open frontier

The logical boundary is exact, but the complexity story is still open. Does consequence-guided reasoning produce shorter proofs? Sometimes it plainly produces smaller search spaces. Yet proof length must include the cost of deriving the consequences and the cost of the backward certificate. There may be no universal constant-factor saving.

This creates a concrete research program. One can fix a proof calculus, define an exact node-count convention, and compare shortest direct derivations with certified consequence-guided derivations. Arithmetic benchmarks can test whether divisibility constraints typically halve proof search, whether information gain predicts enumeration speed, and whether large semantic reductions can coexist with almost no syntactic shortening.

The central result is therefore both negative and constructive. Verified consequences, even coherent ones, cannot establish their antecedent. But consequences equipped with a backward certificate can recover it, and the same consequences can provably shrink finite search. The detective may begin with traces after all—provided the final case explains why those traces leave only one possible story.