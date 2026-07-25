# Explicit Sections and Persistent Collisions in Iterated Collatz Maps

## Abstract

We examine the unrestricted iterated Collatz maps as candidates for one-way functions and collision-resistant hashing. For nonnegative integers, let $T(n)=n/2$ when $n$ is even and $T(n)=3n+1$ when $n$ is odd, and let $F_a=T^a$ denote the $a$-fold iterate. Although forward evaluation is elementary and Collatz trajectories can appear irregular, every $F_a$ has an explicit efficiently computable section: $I_a(y)=2^a y$, with $F_a(I_a(y))=y$ for every target $y$. Hence every iterate is surjective, and unrestricted inversion requires no branching search. Independently, the distinct inputs $2k+1$ and $12k+8$ have the same one-step image $6k+4$ for every $k\ge 0$. Determinism propagates these collisions through every subsequent iterate, so each positive-depth map is noninjective and admits explicit persistent collisions. These conclusions are unconditional and remain true if the Collatz convergence conjecture is assumed. We formulate the resulting cryptographic obstruction, give direct algorithms and complexity bounds, distinguish structural inversion from forward convergence, and identify bounded-domain, distributional, and domain-separated variants that remain meaningful research directions.

## 1. Introduction

The Collatz map combines a halving operation with an affine expansion selected by parity. Its rule is simple enough to evaluate immediately, yet its long-term dynamics have resisted a complete analysis. This contrast makes it tempting to interpret orbit irregularity as cryptographic asymmetry: one can compute a long trajectory forward, while reconstructing a starting point from a later value appears to require navigating a branching reverse graph.

That interpretation must be tested against the exact inversion relation. Cryptographic one-wayness is not a qualitative statement that trajectories look complicated. It is a quantified average-case claim over specified input distributions and size parameters. Before asymptotic lower bounds can be plausible, one must determine whether a structural inverse exists. Similarly, collision resistance cannot follow from long trajectories if algebraically described collisions occur before iteration begins and then persist.

This paper carries out that structural test for the unrestricted map on $\mathbb N=\{0,1,2,\ldots\}$. The result is an obstruction rather than a construction. Every target has an all-even reverse path of arbitrary prescribed length. At depth $a$, this path starts at $2^a y$. Thus the proposed reverse search is bypassed by multiplication by a power of two. At the same time, every $k\ge 0$ supplies an odd-even collision:

$$
2k+1\ne 12k+8,
\qquad
T(2k+1)=T(12k+8)=6k+4.
$$

After the first merger, all later states coincide. These two mechanisms refute, respectively, unrestricted one-wayness and collision resistance of the raw iterate family.

The conclusions do not settle restricted variants. Requiring a preimage to remain in a prescribed bit-length interval can exclude $2^a y$. Sampling from a distribution and requiring an inverter to recover a preimage in its support changes the task. Keyed domain separation may exclude known collision families. Such changes are substantive: they remove precisely the structures used in the obstruction and therefore require independent analysis.

## 2. Definitions and computational setting

### 2.1. Collatz dynamics

**Definition 2.1 (Collatz map).** The Collatz map $T:\mathbb N\to\mathbb N$ is

$$
T(n)=
\begin{cases}
n/2, & n\equiv 0\pmod 2,\\
3n+1, & n\equiv 1\pmod 2.
\end{cases}
$$

Both branches produce nonnegative integers. We include $0$, for which $T(0)=0$, because the algebraic statements naturally hold on all of $\mathbb N$.

**Definition 2.2 (Iterates).** For $a\in\mathbb N$, define $T^0$ to be the identity and recursively define

$$
T^{a+1}=T^a\circ T.
$$

Equivalently, $T^a(n)$ is the state after exactly $a$ Collatz steps from $n$. We write

$$
F_a(n)=T^a(n).
$$

The family $(F_a)_{a\ge 0}$ is the unrestricted iterated Collatz family.

**Definition 2.3 (Canonical preimage).** For $a,y\in\mathbb N$, define

$$
I_a(y)=2^a y.
$$

This candidate preimage corresponds to taking the even reverse edge $y\mapsto 2y$ exactly $a$ times.

### 2.2. Inversion and collisions

For a fixed depth $a$, the unrestricted inversion relation asks, given $y$, for any $n\in\mathbb N$ satisfying $F_a(n)=y$. A function $I_a$ is a section, or right inverse, of $F_a$ when

$$
F_a(I_a(y))=y
$$

for every $y$. The existence of a section implies that $F_a$ is surjective. If the section is efficiently computable, then this unrestricted search problem is efficiently solvable.

A collision for $F_a$ is a pair $x,z\in\mathbb N$ with $x\ne z$ and $F_a(x)=F_a(z)$. The map is injective exactly when it has no collision. Cryptographic collision resistance is stronger than injectivity on any finite encoding domain: it asks that an efficient adversary be unable to find a collision. An explicit parameterized collision family directly defeats that requirement for the raw map.

### 2.3. Complexity convention

Integers are represented in binary. Let $\ell(n)$ denote the binary length, with any fixed conventional treatment of $0$. A single multiplication by $2^a$ is a left shift by $a$ positions. It produces an integer of length at most $\ell(y)+a$. Consequently, computing $I_a(y)$ takes $O(\ell(y)+a)$ time if writing the output is charged, and $O(1)$ word operations in an abstract shift model with sufficient storage. Verifying the result by direct iteration takes $a$ Collatz steps and operates on monotonically shrinking values along the canonical all-even path.

This complexity statement is output-sensitive. The integer $2^a y$ is exponentially large in the numeric parameter $a$, but its binary representation is only $a$ bits longer than that of $y$. Cryptographic complexity is measured in representation length, not numeric magnitude.

## 3. The explicit section

The elementary identity underlying the inversion algorithm is the following.

**Lemma 3.1 (Universal even predecessor).** For every $n\in\mathbb N$,

$$
T(2n)=n.
$$

**Proof sketch.** The input $2n$ is even. The even branch of the definition gives $T(2n)=(2n)/2=n$. This includes $n=0$. $\square$

Repeated use of this edge gives a preimage at any prescribed depth.

**Theorem 3.2 (Exact all-even preimage).** For all $a,y\in\mathbb N$,

$$
T^a(2^a y)=y.
$$

**Proof sketch.** Induct on $a$. At $a=0$, the statement reads $T^0(y)=y$. Suppose it holds for $a$. Since $2^{a+1}y=2(2^a y)$, Lemma 3.1 gives

$$
T(2^{a+1}y)=2^a y.
$$

Applying the remaining $a$ iterations and using the induction hypothesis yields

$$
T^{a+1}(2^{a+1}y)=T^a(2^a y)=y.
$$

Thus the claim holds for all depths. $\square$

The canonical preimages also compose exactly.

**Lemma 3.3 (Additive composition law).** For all $a,b,y\in\mathbb N$,

$$
I_{a+b}(y)=I_a(I_b(y)).
$$

**Proof sketch.** By the laws of exponents and associativity,

$$
I_{a+b}(y)=2^{a+b}y=2^a(2^b y)=I_a(I_b(y)).
$$

$\square$

**Theorem 3.4 (Section theorem).** For every $a\in\mathbb N$, the function $I_a(y)=2^a y$ is a right inverse of $F_a=T^a$:

$$
F_a\circ I_a=\operatorname{id}_{\mathbb N}.
$$

**Proof sketch.** At each $y$, the asserted identity is precisely Theorem 3.2. $\square$

**Corollary 3.5 (Surjectivity of every iterate).** For every $a\in\mathbb N$, $F_a$ is surjective.

**Proof sketch.** Given any target $y$, choose $n=I_a(y)=2^a y$. Theorem 3.4 gives $F_a(n)=y$. $\square$

Surjectivity is not itself an attack: a permutation is surjective and may still be conjectured one-way when no efficient inverse is known. Here the section is explicit and computationally elementary. This is the stronger obstruction.

## 4. Explicit inversion algorithm

**Algorithm 4.1 (Canonical all-even inverter).** On input a depth $a\ge 0$ and target $y\ge 0$, output $n=2^a y$.

The binary implementation appends $a$ zero bits to the representation of $y$. For example, with $a=5$ and $y=13$,

$$
n=2^5\cdot 13=416,
$$

and the trajectory is

$$
416\to208\to104\to52\to26\to13.
$$

**Theorem 4.2 (Total correctness of the canonical inverter).** Algorithm 4.1 terminates on every input and its output satisfies

$$
F_a(n)=y.
$$

**Proof sketch.** A left shift is a finite operation, so termination is immediate. Correctness is Theorem 3.2. $\square$

**Proposition 4.3 (Complexity).** With binary inputs, Algorithm 4.1 uses $O(\ell(y)+a)$ time and $O(\ell(y)+a)$ bits of output space under a standard bit-cost model.

**Proof sketch.** Multiplication by $2^a$ requires no general multiplication: copy the bits of $y$ and append $a$ zeros. The number of written bits is $\ell(y)+a$, giving both the upper bound and, when the entire answer must be emitted, a matching output-size lower bound. $\square$

The algorithm demonstrates why a putative lower bound such as $2^{a/\log a}$ cannot apply to the unrestricted inversion relation. No reverse tree is searched. The inverter chooses one branch known in advance—the all-even branch—and constructs its start directly.

## 5. Parameterized and persistent collisions

The second obstruction begins with a family containing one odd and one even input.

**Theorem 5.1 (Parameterized one-step collisions).** For every $k\in\mathbb N$, define

$$
x_k=2k+1,
\qquad
z_k=12k+8.
$$

Then $x_k\ne z_k$ and

$$
T(x_k)=T(z_k)=6k+4.
$$

**Proof sketch.** Since $x_k$ is odd,

$$
T(x_k)=3(2k+1)+1=6k+4.
$$

Since $z_k$ is even,

$$
T(z_k)=\frac{12k+8}{2}=6k+4.
$$

If the inputs were equal, then $2k+1=12k+8$, so $10k=-7$, impossible for $k\ge 0$. Thus they form a collision. $\square$

The cases $k=0,1,2$ give

$$
T(1)=T(8)=4,
$$

$$
T(3)=T(20)=10,
$$

and

$$
T(5)=T(32)=16.
$$

The family is infinite and can be generated in time linear in the bit length of $k$.

**Lemma 5.2 (Collision propagation).** If $T(x)=T(z)$, then for every $b\in\mathbb N$,

$$
T^{b+1}(x)=T^{b+1}(z).
$$

**Proof sketch.** Apply the deterministic function $T^b$ to both sides of $T(x)=T(z)$. Then

$$
T^b(T(x))=T^b(T(z)),
$$

which is the desired equality. $\square$

**Theorem 5.3 (Collision at every positive depth).** For every $a>0$, there exist distinct $x,z\in\mathbb N$ such that

$$
F_a(x)=F_a(z).
$$

In fact, $x=1$ and $z=8$ work for every positive $a$.

**Proof sketch.** Theorem 5.1 at $k=0$ gives $T(1)=T(8)=4$ and $1\ne8$. Write $a=b+1$. Lemma 5.2 then yields $T^{b+1}(1)=T^{b+1}(8)$. $\square$

**Corollary 5.4 (Noninjectivity).** No positive-depth iterate $F_a$ is injective.

**Proof sketch.** The collision supplied by Theorem 5.3 contradicts the defining implication of injectivity. $\square$

For collision resistance, the result is stronger than mere noninjectivity. Theorem 5.1 is an efficient collision generator, and Lemma 5.2 guarantees that its output collides at any requested positive depth. Increasing $a$ does not increase the work needed to choose colliding inputs.

## 6. Combined cryptographic obstruction

The preceding arguments concern independent structural defects. The section addresses inversion, while the stable collision family addresses hashing.

**Theorem 6.1 (Unrestricted cryptographic obstruction).** For every positive integer $a$, the map $F_a(n)=T^a(n)$ simultaneously satisfies:

1. for every $y\in\mathbb N$,
   $$
   F_a(2^a y)=y;
   $$
2. there exist distinct $x,z\in\mathbb N$ such that
   $$
   F_a(x)=F_a(z).
   $$
   One may always choose $x=1$ and $z=8$.

**Proof sketch.** The first clause is Theorem 3.2. The second is Theorem 5.3. Their conjunction holds at each positive depth. $\square$

**Cryptographic consequence.** Under the unrestricted relation “given $(a,y)$, find any natural number $n$ with $T^a(n)=y$,” the family is not one-way: Algorithm 4.1 succeeds on every instance in time linear in the output length. Under the raw collision task “given $a>0$, find distinct $x,z$ with $T^a(x)=T^a(z)$,” the pair $(1,8)$ succeeds for every instance. Therefore the raw iterate family cannot provide the proposed collision-resistant hash construction.

This consequence does not depend on a choice among standard uniform computational models, because the attacks consist only of a binary shift and fixed small integers. Nor does it depend on empirical behavior of long trajectories.

## 7. Independence from the convergence conjecture

Define the Collatz convergence assertion as follows.

**Definition 7.1 (Collatz convergence assertion).** Every positive integer eventually reaches $1$:

$$
\forall n>0\;\exists a\ge 0\text{ such that }T^a(n)=1.
$$

This statement concerns eventual forward behavior with a depth that may depend on $n$. The section theorem concerns exact-depth preimages of an arbitrary target. The latter is unconditional.

**Theorem 7.2 (Convergence does not block inversion).** Even under the assumption of the Collatz convergence assertion, for every $a,y\in\mathbb N$ there exists $n\in\mathbb N$ such that

$$
T^a(n)=y.
$$

Indeed, $n=2^a y$.

**Proof sketch.** Theorem 3.2 proves the conclusion without using the convergence assumption. Adding the assumption cannot invalidate the explicit identity. $\square$

This separation explains why evidence for convergence cannot serve as evidence for the proposed one-wayness. Forward convergence says that trajectories eventually funnel toward a particular cycle. Such funneling may actually create mergers, but neither mergers nor apparent forward irregularity force reverse search to be hard. The reverse graph always contains the deterministic edge $y\mapsto2y$.

## 8. Scope and limitations

The obstruction applies to the unrestricted domain $\mathbb N$, to inversion that accepts any preimage, and to the raw iterates without additional encoding. It is important not to claim more.

First, a length-preserving task can reject the canonical preimage. If an input must lie in

$$
[2^{b-1},2^b),
$$

then $2^a y$ will often exceed the upper boundary. Finding a preimage in that same interval may require odd reverse edges and congruence conditions. The theorem here supplies no average-case lower bound for that restricted problem.

Second, one-wayness is distributional. A complete proposal must specify how $n$ is sampled, how $a$ scales with the security parameter, how outputs are encoded, and what counts as successful inversion. The existence of an easy out-of-distribution preimage is fatal only when the inversion relation permits it—as the unrestricted proposal does.

Third, noninjectivity alone does not rule out every use of a function in hashing. Compression functions are necessarily noninjective. The relevant negative result is that collisions are efficiently parameterized and persist through the proposed raw iteration. A modified keyed construction might exclude these pairs, though it would need to address other collision families as well.

Fourth, no runtime lower bound for a restricted model is established here. The contribution is prior to such lower bounds: it identifies exact algebraic shortcuts that invalidate the unrestricted formulation before asymptotic hardness is considered.

## 9. Applications and design principles

The results provide practical screening tests for dynamical cryptography.

### 9.1. Search for sections before studying chaos

For a family of maps $G_a$, the first inversion test should be whether there is an efficiently computable $S_a$ satisfying

$$
G_a(S_a(y))=y.
$$

Such a section need not be a two-sided inverse and need not recover the original input. Cryptographic inversion commonly asks only for a valid preimage. Therefore an efficient section is sufficient to defeat distribution-free unrestricted one-wayness.

### 9.2. Search for stable kernel pairs

A pair $x\ne z$ with $G(x)=G(z)$ is stable under every deterministic suffix $H$:

$$
H(G(x))=H(G(z)).
$$

If such pairs can be efficiently parameterized, iteration alone cannot repair collision resistance. This observation applies to many dynamical constructions, not merely Collatz.

### 9.3. Make domain restrictions explicit

A security claim must state admissible preimages. Bit-length preservation, membership in the original sampling interval, parity constraints, and keyed domains can alter the problem. Restrictions should be designed to exclude known sections and then analyzed for unintended alternative sections.

### 9.4. Treat collision families as adversarial tests

The family $(2k+1,12k+8)$ is a ready-made test set. Any proposed domain separator or compression layer should be checked against the entire parameterized family. Passing isolated numerical tests is not enough when an algebraic family is known.

## 10. Numerical demonstrations

Three experiments make the structural claims transparent.

The first computes $n=2^a y$ and prints the $a$-step path. Every transition is a halving step, and the final state is exactly $y$. This tests arbitrary targets rather than only targets lying on familiar Collatz orbits.

The second generates collision pairs from $k$. It confirms both branches symbolically reflected in arithmetic: the odd input maps by $3n+1$, while the even input maps by division by two, and both reach $6k+4$.

The third chooses a positive depth $a$ and compares trajectories from $1$ and $8$. The trajectories differ initially but coincide after one step and remain equal at depth $a$. A breadth-first reverse search can also be compared with the direct section: the search explores candidates, whereas the shift computes a certified preimage immediately.

These demonstrations are illustrative rather than the basis of the theorems. The proofs are algebraic and hold for all nonnegative integers.

## 11. Future research

A meaningful successor program begins where the obstruction ceases to apply.

### 11.1. Length-preserving inversion under a truncated domain

Fix a bit length $b$, sample $n$ uniformly from $[2^{b-1},2^b)$, and reveal an encoding of $T^a(n)$ together with $a$. Require an inverter to return a preimage in the same interval. The universal preimage $2^a y$ may be inadmissible, making reverse parity constraints relevant. A precise average-case conjecture would need a specified relation between $a$ and $b$ and a specified computational model.

### 11.2. Entropy of admissible reverse parity words

Reverse trajectories can be encoded by parity words, but odd reverse moves impose divisibility and parity congruences. For typical targets, one may ask how the number of admissible bounded preimages grows with $a$. An exponential rate strictly between $0$ and $\log 2$ would quantify genuine reverse branching after the exceptional all-even path is removed.

### 11.3. Domain separation and compression

A candidate collision-resistant construction must exclude the full relation

$$
T(2k+1)=T(12k+8)
$$

and its variants. Keyed affine domain separators and length-preserving compression rules could be screened against these persistent collisions before stronger security claims are attempted.

### 11.4. A generic obstruction theorem

The Collatz analysis suggests an abstract statement: an efficiently computable dynamical system with efficiently computable sections for all iterates cannot be distribution-free one-way under unrestricted inversion. Likewise, an efficiently parameterized kernel pair stable under iteration rules out collision resistance of raw iterates. Formalizing this principle in standard circuit and probabilistic models would clarify its exact scope.

## 12. Comparison with genuine one-way-function requirements

A conventional one-way-function claim involves a family indexed by a security parameter, a polynomial-time sampling procedure, and a probability bound against every efficient probabilistic inverter. The unrestricted relation studied here fails at a more elementary level: the inverter succeeds with probability $1$ on every target, regardless of how that target was obtained, provided any natural-number preimage is accepted. Thus no choice of input distribution can rescue that exact relation.

A restricted relation can behave differently. Suppose verification additionally requires $n$ to belong to a set $D_{a,b}$. The canonical inverter is then an attack only when $2^a y\in D_{a,b}$. Security analysis must characterize that event and all alternative reverse paths. This observation supplies a checklist for future definitions: specify the sampled domain, admissible answer set, parameter scaling, output representation, and success probability. Without those ingredients, “hard to invert” is not a mathematically complete claim.

Collision resistance similarly requires a keyed or parameterized finite-domain family and a probability experiment. Yet the raw iterates fail every natural version that admits $1$ and $8$, since this fixed pair collides at all positive depths. Restricting the domain to avoid one pair is insufficient unless it excludes the complete algebraic families and any efficiently derived variants. Theorems 5.1 and 5.3 therefore serve not merely as examples but as structural requirements for subsequent designs.

## 13. Conclusion

The unrestricted iterated Collatz map has no cryptographic inversion barrier. At every depth $a$, multiplication by $2^a$ gives a total section, and in binary this is merely a left shift. Every target therefore has an explicitly constructed preimage. Separately, the infinite family $(2k+1,12k+8)$ collides after one step, and every such collision persists under all further iteration. These facts hold independently of the Collatz convergence conjecture.

The central methodological lesson is that dynamical unpredictability and cryptographic hardness are different properties. Before orbit complexity is invoked as a security resource, one must rule out efficient sections, parameterized collisions, and encoding-level shortcuts. For Collatz dynamics, any viable cryptographic successor must alter the unrestricted problem through domain bounds, distributional requirements, output encodings, or structural collision exclusion. The obstruction does not end that investigation; it gives it a mathematically precise starting line.
