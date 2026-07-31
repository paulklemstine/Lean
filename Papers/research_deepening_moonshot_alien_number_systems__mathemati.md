# Canonical Negabinary Numeration: Existence, Uniqueness, and Algorithms in Radix $-2$

**Aristotle**  
**31 July 2026**

## Abstract

We develop the finite positional numeral system with radix $-2$ and binary digits. Digits are indexed from least to most significant, and a finite sequence $(b_0,\ldots,b_{n-1})$ has value $\sum_j b_j(-2)^j$. To remove leading-zero ambiguity, a sequence is called canonical when it is empty or its most-significant digit is $1$. The main result states that evaluation is a bijection from canonical finite bit sequences to the integers: every integer has exactly one canonical negabinary expansion. The proof is constructive. Parity forces the least-significant digit $d(z)=z\bmod2$, and the remaining state is $N(z)=-(z-d(z))/2$. The identity $d(z)-2N(z)=z$ proves local reconstruction, while $|N(z)|<|z|$ outside the explicitly resolved states $0$ and $-1$ proves termination. Uniqueness follows because reduction modulo $2$ recovers the first digit and canonical zero has only the empty representation. We present encoding and decoding algorithms, correctness and complexity arguments, worked examples, and extensions to general negative radices, normalization systems, golden-ratio numeration, and complex bases.

## 1. Introduction

A conventional radix-$b$ expansion uses powers $1,b,b^2,\ldots$ and digits chosen from a finite alphabet. For $b>1$, finite unsigned expansions naturally describe nonnegative integers. Signed integers are then handled by an external sign or by a separate fixed-width convention.

A negative radix changes this geometry. In radix $-2$, place values alternate:

$$
1,-2,4,-8,16,-32,\ldots.
$$

Consequently a string of unsigned binary digits can have either sign. For example,

$$
(1,1)_{-2}=1-2=-1,
$$

and

$$
(0,1,1)_{-2}=0-2+4=2,
$$

where tuples in this paper list digits from least significant to most significant. This convention aligns the representation with recursive evaluation and with the digit-extraction algorithm.

The appealing examples leave two fundamental obligations. First, existence: does every integer possess a finite expansion? Second, uniqueness: after excluding redundant leading zeroes, can distinct expansions have equal value? We settle both questions and exhibit an explicit conversion procedure.

The proof has four components. The least-significant bit is determined by Euclidean parity. Removing it leaves an even integer, which may be divided by the radix to obtain a new state. A reconstruction identity shows that this step loses no information. Finally, a well-founded descent in absolute value proves that iteration terminates, with $-1$ handled as a single exceptional transition. The same parity observation then drives an inductive uniqueness proof.

This framework is useful beyond a single theorem. It separates numeral-system design into digit selection, exact reconstruction, descent, and normalization. Those ingredients recur in arbitrary negative radices and, with suitable changes of norm and digit domain, in complex and irrational numeration.

## 2. Definitions and elementary structure

### 2.1 Finite bit sequences and evaluation

Let $\mathbb B=\{0,1\}$. A finite bit sequence is a tuple

$$
L=(b_0,b_1,\ldots,b_{n-1}),\qquad b_j\in\mathbb B.
$$

The index $0$ denotes the least-significant position.

**Definition 2.1 (Negabinary value).** The value of $L$ is

$$
V(L)=\sum_{j=0}^{n-1}b_j(-2)^j.
$$

Equivalently, evaluation is recursively characterized by

$$
V(())=0,
$$

and

$$
V((b)::T)=b-2V(T),
$$

where $(b)::T$ denotes prefixing the least-significant digit $b$ to the tail $T$.

The recursive formula follows by separating the $j=0$ term and shifting the remaining powers:

$$
\sum_{j=0}^{n-1}b_j(-2)^j=b_0+(-2)\sum_{j=1}^{n-1}b_j(-2)^{j-1}.
$$

### 2.2 Canonical sequences

Appending zeroes at the most-significant end does not change value. A normalization convention is therefore necessary.

**Definition 2.2 (Canonical sequence).** A finite bit sequence is canonical if it is empty or its most-significant digit is $1$.

Thus $()$ is canonical and represents $0$. The sequence $(1,0,0)$ is not canonical because its last digit is $0$, even though its first digit is $1$. When writing digits in the usual most-significant-first display order, this condition is exactly the prohibition of leading zeroes.

**Lemma 2.3 (Canonical tails).** The tail of a nonempty canonical sequence is canonical.

**Proof sketch.** If the tail is empty, it is canonical by definition. If it is nonempty, its most-significant digit is also the most-significant digit of the original sequence, hence is $1$.

### 2.3 The forced digit and next state

For $z\in\mathbb Z$, let $z\bmod2$ denote its Euclidean remainder, which belongs to $\{0,1\}$ even when $z$ is negative.

**Definition 2.4 (Forced digit).** Define

$$
d(z)=z\bmod2.
$$

Equivalently, $d(z)=1$ exactly when $z$ is odd and $d(z)=0$ exactly when $z$ is even.

**Definition 2.5 (Negabinary successor state).** Define

$$
N(z)=-\frac{z-d(z)}{2}.
$$

The division is exact because $d(z)$ is the remainder modulo $2$.

**Lemma 2.6 (Even remainder).** For every integer $z$,

$$
2\mid z-d(z).
$$

**Proof sketch.** The division algorithm gives $z=2q+(z\bmod2)$ for some integer $q$. Therefore $z-d(z)=2q$.

**Lemma 2.7 (One-step reconstruction).** For every integer $z$,

$$
d(z)-2N(z)=z.
$$

**Proof.** Substituting the definition of $N$ gives

$$
d(z)-2\left(-\frac{z-d(z)}2\right)
=d(z)+z-d(z)=z.
$$

Exact divisibility from Lemma 2.6 justifies the integer quotient.

This identity says that the pair consisting of the forced bit $d(z)$ and the next state $N(z)$ retains all information about $z$.

## 3. Termination of repeated digit extraction

The encoding procedure repeatedly applies $N$. To prove that it yields a finite sequence, we use absolute value as a descent measure.

**Theorem 3.1 (Strict descent outside one exceptional nonzero state).** If $z\neq0$ and $z\neq-1$, then

$$
|N(z)|<|z|.
$$

**Proof sketch.** There are two parity cases. If $z$ is even, then $d(z)=0$ and

$$
|N(z)|=\frac{|z|}{2}<|z|
$$

for nonzero $z$. If $z$ is odd, then $d(z)=1$ and

$$
|N(z)|=\frac{|z-1|}{2}.
$$

For positive odd $z$, one has $z\ge1$. The case $z=1$ gives $N(z)=0$, and for $z\ge3$ the strict inequality is immediate. For negative odd $z$, write $z=-m$ with positive odd $m$. Then

$$
|N(z)|=\frac{m+1}{2}.
$$

This is strictly smaller than $m$ whenever $m>1$. The omitted case $m=1$ is precisely $z=-1$.

The exception does not create a cycle:

$$
N(-1)=1,
\qquad
N(1)=0.
$$

Indeed, $d(-1)=1$, so $N(-1)=-(-2/2)=1$; and $d(1)=1$, so $N(1)=0$.

**Corollary 3.2 (Finite termination).** For every integer $z$, repeated application of $N$ eventually reaches $0$.

**Proof sketch.** If the current state is neither $0$ nor $-1$, Theorem 3.1 strictly decreases its nonnegative integer absolute value. Such a measure cannot descend indefinitely. If the process reaches $-1$, it reaches $0$ after two additional transitions. Hence every trajectory is finite.

The descent result also gives an asymptotic length estimate. Away from a bounded neighborhood of zero, each step approximately halves the magnitude. Thus the number of generated bits is $O(\log(1+|z|))$. A simple coarse bound follows from $|N(z)|\le(|z|+1)/2$; exact optimal length intervals require a more refined analysis of alternating partial sums.

## 4. Existence of canonical expansions

We now turn the terminating trajectory into a representation.

**Algorithm 4.1 (Canonical negabinary encoding).** Given $z\in\mathbb Z$:

1. If $z=0$, return the empty sequence.
2. Set the current state $w\leftarrow z$ and initialize an empty sequence $L$.
3. While $w\neq0$:
   1. compute $b=w\bmod2$;
   2. append $b$ to $L$;
   3. set $w\leftarrow-(w-b)/2$.
4. Return $L$.

All quotients in the algorithm are exact. Corollary 3.2 proves termination.

**Theorem 4.2 (Existence of a canonical representation).** Every integer $z$ has a finite canonical bit sequence $L$ satisfying

$$
V(L)=z.
$$

**Proof sketch.** Follow the states

$$
z=z_0,z_1,\ldots,z_k=0,
$$

where $z_{j+1}=N(z_j)$ and record $b_j=d(z_j)$. Termination makes this sequence finite. The reconstruction identity gives

$$
z_j=b_j-2z_{j+1}.
$$

Substituting these identities recursively yields

$$
z=b_0-2b_1+4b_2-\cdots+(-2)^{k-1}b_{k-1}=V(b_0,\ldots,b_{k-1}).
$$

If $z=0$, the output is empty and canonical. If $z\neq0$, the final nonzero state $z_{k-1}$ has next state $0$. The reconstruction identity gives $z_{k-1}=d(z_{k-1})$, and nonzeroness forces this digit to be $1$. Hence the most-significant output digit is $1$, so the sequence is canonical.

The exceptional state admits the explicit representation

$$
-1=1-2=V(1,1),
$$

which is consistent with the general algorithm.

### 4.1 Stable radix extension

Existence can be expressed locally as a closure property.

**Theorem 4.3 (One-step canonical extension).** For every integer $z$, there is a canonical sequence $L$ such that

$$
V((d(z))::L)=z.
$$

**Proof sketch.** By Theorem 4.2, choose a canonical $L$ with $V(L)=N(z)$. Then recursive evaluation and reconstruction give

$$
V((d(z))::L)=d(z)-2V(L)=d(z)-2N(z)=z.
$$

This theorem isolates the inductive mechanism: represent the smaller next state, then attach the uniquely forced low bit.

## 5. Uniqueness

The uniqueness argument starts with a congruence invariant.

**Lemma 5.1 (Parity recovers the first bit).** For every bit $b\in\{0,1\}$ and every finite tail $T$,

$$
V((b)::T)\bmod2=b.
$$

**Proof.** Recursive evaluation gives $V((b)::T)=b-2V(T)$. The second term is divisible by $2$, so the residue is $b$.

Before comparing arbitrary expansions, we identify the canonical representation of zero.

**Lemma 5.2 (Canonical zero lemma).** If a canonical bit sequence $L$ satisfies $V(L)=0$, then $L$ is empty.

**Proof sketch.** Induct on the sequence length. The empty case is immediate. For a nonempty sequence $(b)::T$, Lemma 5.1 and $V(L)=0$ force $b=0$. Recursive evaluation then gives $-2V(T)=0$, so $V(T)=0$. The tail is canonical by Lemma 2.3, and induction makes it empty. But then the original sequence is the one-digit sequence $(0)$, which is not canonical. This contradiction excludes every nonempty case.

**Theorem 5.3 (Injectivity of canonical evaluation).** If canonical finite bit sequences $L_1$ and $L_2$ satisfy

$$
V(L_1)=V(L_2),
$$

then $L_1=L_2$.

**Proof sketch.** If either sequence is empty, the common value is $0$, and Lemma 5.2 forces the other to be empty. Otherwise write $L_1=(b_1)::T_1$ and $L_2=(b_2)::T_2$. Reducing their common value modulo $2$ and applying Lemma 5.1 yields $b_1=b_2$. Subtract this common bit from the equality

$$
b_1-2V(T_1)=b_2-2V(T_2)
$$

and cancel $-2$ to obtain $V(T_1)=V(T_2)$. The tails are canonical by Lemma 2.3, so induction gives $T_1=T_2$, and hence $L_1=L_2$.

Existence and injectivity combine into the principal result.

**Theorem 5.4 (Unique Negabinary Representation Theorem).** For every integer $z$, there exists exactly one canonical finite bit sequence $L$ such that

$$
V(L)=z.
$$

**Proof.** Existence is Theorem 4.2. If two canonical sequences represent $z$, their values are equal, so Theorem 5.3 identifies them.

**Corollary 5.5 (Canonical correspondence).** Evaluation defines a bijection

$$
V:\{L:L\text{ is a canonical finite bit sequence}\}\longrightarrow\mathbb Z.
$$

Its inverse is Algorithm 4.1.

## 6. Algorithms and complexity

### 6.1 Decoding

A least-significant-first sequence can be evaluated by the recursive rule $V((b)::T)=b-2V(T)$. Iteratively, it is convenient to scan from most significant to least significant:

**Algorithm 6.1 (Negabinary decoding).** Given $L=(b_0,\ldots,b_{n-1})$, initialize $v=0$ and process $b_{n-1},\ldots,b_0$ in that order, updating

$$
v\leftarrow -2v+b_j.
$$

After the final update, return $v$.

**Correctness sketch.** Horner's rule rewrites

$$
\sum_{j=0}^{n-1}b_j(-2)^j
$$

as nested multiplication by $-2$ beginning with the most-significant coefficient. Induction on the processed prefix proves that the accumulator equals its positional value.

For $n$ digits, decoding uses $n$ multiplications by the fixed integer $-2$ and $n$ additions. In a unit-cost model it takes $O(n)$ time and $O(1)$ auxiliary storage. With arbitrary-precision integers, bit complexity depends on growing operand sizes; for an $n$-digit input, straightforward arithmetic remains polynomial and near-quadratic under elementary big-integer operations.

### 6.2 Encoding

Algorithm 4.1 performs one remainder, subtraction, exact halving, and sign change per output bit. Since magnitude is approximately halved at each ordinary step, an integer of magnitude $M$ produces $O(\log(1+M))$ bits. The algorithm therefore uses $O(\log(1+|z|))$ iterations and the same amount of output storage. Its working storage, excluding output, is constant in a unit-cost integer model.

### 6.3 Canonicality testing

A sequence is canonical exactly when it is empty or its final bit is $1$. Testing therefore takes $O(1)$ time for an array with direct access to its final element, or $O(n)$ for a singly linked least-significant-first list. Canonicalization of an arbitrary finite bit sequence consists of deleting all zeroes from its most-significant end; this preserves value. For binary negabinary strings, no other normalization is needed.

### 6.4 Round trips

The main theorem yields two round-trip laws. For every integer $z$,

$$
V(\operatorname{encode}(z))=z.
$$

For every canonical sequence $L$,

$$
\operatorname{encode}(V(L))=L.
$$

The first is the existence proof in algorithmic form. For the second, both $L$ and the encoded result are canonical and have the same value, so uniqueness identifies them.

## 7. Numerical examples

### 7.1 Encoding $-9$

The extraction table is

| Current state $z$ | Digit $d(z)$ | Next state $N(z)$ |
|---:|---:|---:|
| $-9$ | $1$ | $5$ |
| $5$ | $1$ | $-2$ |
| $-2$ | $0$ | $1$ |
| $1$ | $1$ | $0$ |

Thus the least-significant-first expansion is $(1,1,0,1)$. Evaluation gives

$$
1+1(-2)+0(-2)^2+1(-2)^3=1-2-8=-9.
$$

### 7.2 Encoding $2$

The trajectory is

$$
2\xrightarrow{0}-1\xrightarrow{1}1\xrightarrow{1}0.
$$

Hence $2$ has expansion $(0,1,1)$, and

$$
0-2+4=2.
$$

This example passes through the exceptional state $-1$ and illustrates why that state must be treated explicitly in the termination proof.

### 7.3 Encoding $19$

The trajectory records the bits $(1,1,1,0,1)$. Direct evaluation gives

$$
1-2+4+0(-8)+16=19.
$$

### 7.4 A local extension example

Take $z=-9$. Its forced digit is $d(-9)=1$, and $N(-9)=5$. A canonical expansion of $5$ is $(1,0,1)$ because $1+4=5$. Prefixing the forced low bit gives $(1,1,0,1)$, and

$$
V(1,1,0,1)=1-2V(1,0,1)=1-2\cdot5=-9.
$$

This is Theorem 4.3 in concrete form.

## 8. Applications and structural interpretation

### 8.1 Signed representation without an external sign

The alternating powers allow one digit alphabet to represent both signs. There is no separate sign symbol: sign emerges from the balance of positive even-indexed and negative odd-indexed place values. This supplies a mathematically uniform coordinate system for $\mathbb Z$.

The result should not be confused with a claim that negabinary always outperforms two's-complement hardware. Fixed-width overflow, carry propagation, and circuit design must be analyzed separately. The theorem instead establishes the unbounded arithmetic foundation on which such engineering questions can be posed.

### 8.2 Exact serialization

A unique canonical expansion provides an unambiguous variable-length serialization of integers. Decoding is a simple Horner recurrence, while encoding uses parity and exact halving. The representation is prefix-independent only after an external framing convention supplies sequence length or termination; the theorem concerns unique finite strings, not self-delimiting communication codes.

### 8.3 A template for exotic numeration

The proof reveals a reusable four-part pattern:

1. choose a digit as a residue modulo the radix magnitude;
2. prove that removing the digit makes exact division possible;
3. establish a reconstruction identity;
4. find a well-founded norm that decreases under the quotient map, resolving finitely many exceptional states.

Uniqueness then follows if residues recover the low digit and the normalization rule excludes zero-padding ambiguity.

## 9. Generalizations and future work

The most direct extension replaces $-2$ by $-b$ for an integer $b\ge2$ and uses digits $0,1,\ldots,b-1$. The forced digit becomes $z\bmod b$, and the next state is

$$
N_b(z)=-\frac{z-(z\bmod b)}{b}.
$$

One expects a canonical bijection with $\mathbb Z$ after proving norm descent and handling a finite exceptional region. This would isolate the role played by the radix magnitude from the special simplicity of parity.

Sharp length bounds are another natural objective. The present descent argument proves logarithmic growth but does not classify exactly which integers have expansions of length at most $n$. Such intervals are governed by alternating sums of selected powers and differ according to parity of $n$.

A rewriting approach would begin with integer coefficients outside $\{0,1\}$ and use local carry rules that preserve value. The central tasks would be termination and confluence: every expression should reduce to the same canonical bit sequence.

Irrational bases bring new phenomena. For the golden ratio $\varphi$, the relation

$$
\varphi^2=\varphi+1
$$

means unrestricted binary expansions are not unique. A standard normalization forbids consecutive ones and is closely related to Zeckendorf representations by nonconsecutive Fibonacci numbers. Here uniqueness is not merely the removal of leading zeroes; it depends on a nonlocal combinatorial constraint.

Complex radices replace the integer line by a planar lattice such as the Gaussian integers. A reusable theory would identify digit sets and a Euclidean norm for which quotient states decrease, again allowing finitely many exceptional states. Negabinary supplies the one-dimensional prototype.

## 10. Discussion

The proof of canonical negabinary numeration is notable for the economy of its invariant. Modulo $2$ serves two roles. Constructively, it chooses the only possible least-significant digit. Comparatively, it proves that equal values must begin with equal digits. Thus the encoder and uniqueness proof are two views of the same arithmetic fact.

The exceptional state $-1$ is equally instructive. A naive assertion that absolute value decreases at every nonzero state is false because $N(-1)=1$ has equal magnitude. Rather than weakening termination to an opaque global argument, one can state the sharp descent theorem and resolve the exception explicitly. This pattern is likely to recur in broader Euclidean-radix systems, where descent may fail on a small, classifiable boundary set.

Canonicality is minimal in this setting. Since powers of $-2$ are linearly independent over finite binary positional expressions in the sense established by the parity induction, the only superficial ambiguity is most-significant zero padding. More algebraic bases can satisfy polynomial relations, requiring substantially richer normal forms.

## 11. Limitations and scope

The results concern finite expansions of unbounded mathematical integers. They do not by themselves specify a fixed-width machine format, an overflow policy, or optimal arithmetic circuitry. Likewise, the asymptotic analysis counts digit-extraction iterations; a detailed bit-complexity account depends on the chosen arbitrary-precision arithmetic model.

Canonicality is imposed only at the most-significant end. Intermediate zeroes are meaningful digits and may not be removed: for instance, $(1,0,1)$ represents $5$, whereas $(1,1)$ represents $-1$. Nor may digits be reordered, since each position has a distinct signed weight. The uniqueness theorem applies precisely to finite binary coefficients and radix $-2$ under the stated leading-zero convention.

The proof uses Euclidean remainder, not a language-dependent signed remainder. For negative odd $z$, the required digit is $1$, so $z-1$ is divisible by $2$. Implementations whose remainder operator returns a negative value must normalize it into $\{0,1\}$ before applying the update. This distinction is essential for portability of the algorithm.

Finally, the logarithmic length statement here is asymptotic rather than sharp. Exact extremal values at each length oscillate with the parity of the highest exponent. Determining those intervals, and deriving exact worst-case storage bounds, is a separate refinement rather than a prerequisite for existence or uniqueness.

## 12. Conclusion

Every integer admits exactly one finite canonical expansion in radix $-2$ using only the digits $0$ and $1$. The encoder repeatedly selects the Euclidean parity digit

$$
d(z)=z\bmod2
$$

and advances to

$$
N(z)=-\frac{z-d(z)}2.
$$

The identity $d(z)-2N(z)=z$ proves exact reconstruction. Absolute-value descent, with the explicit transition $-1\to1\to0$, proves termination. Reduction modulo $2$ recovers each low digit, and the canonical zero lemma closes the induction establishing uniqueness.

Consequently, canonical finite bit sequences and the integers are in bijective correspondence. The result provides both a complete structural theorem and practical linear-in-output-length conversion algorithms, while furnishing a compact model for the study of negative, irrational, and complex numeral systems.