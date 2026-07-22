# Canonical Binary Numeration in Negative, Irrational, and Complex Radices

**Aristotle**  
**July 22, 2026**

## Abstract

Positional notation remains meaningful far beyond positive integral radices. This paper develops three complementary systems. First, every integer is shown to have a unique finite canonical expansion in base $-2$ with digits $0$ and $1$. Existence follows from parity extraction and descent under an interleaving measure that handles the failure of absolute-value descent; uniqueness follows by recovering the least significant digit modulo $2$. Second, every natural number has a unique representation as a sum of nonconsecutive Fibonacci numbers. The identity $\varphi^n+\varphi^{n+1}=\varphi^{n+2}$ connects this Zeckendorf normal form to local carrying in the golden-ratio radix, while also clarifying why nonnegative phinary powers alone do not represent all integers in the asserted binary form. Third, every Gaussian integer has a unique finite canonical expansion in base $i-1$ using the same digit set. Coordinate parity forces each digit, and Gaussian-norm descent proves termination outside five explicitly treated exceptional points. Algorithms, examples, limitations, and applications are presented under a common framework of residue extraction, local normalization, well-founded descent, and canonical form.

## 1. Introduction

A conventional base-$b$ numeral is a finite sum $\sum_j d_jb^j$. Familiar theory assumes that $b$ is a positive integer and that the digits form a complete residue system modulo $b$. Those assumptions make division and magnitude descent nearly invisible: the least significant digit is a remainder, the quotient is smaller, and repeated division terminates.

When $b$ is negative, irrational, or complex, the same architecture survives but its hidden components separate. A negative radix allows signed values without a sign symbol, although ordinary absolute value may fail as a termination measure. An algebraic irrational radix creates local carries governed by its minimal polynomial, but the set represented by nonnegative powers must be handled carefully. A complex radix turns digit extraction into a lattice division problem, where norm descent can fail on a finite boundary.

This paper studies three model systems:

- base $-2$ on the integers $\mathbb Z$;
- Fibonacci numeration and its relationship to the golden ratio $\varphi$;
- base $i-1$ on the Gaussian integers $\mathbb Z[i]$.

The main conclusions are exact. Every integer has a unique canonical negabinary expansion. Every natural number has a unique nonconsecutive Fibonacci expansion. Every Gaussian integer has a unique canonical base-$(i-1)$ expansion. The golden-ratio carry law provides a precise bridge between Fibonacci recurrence and phinary normalization, but it does not by itself imply that every integer has a binary expansion using only nonnegative powers of $\varphi$.

## 2. Positional evaluation and canonical words

Let $R$ be a ring, let $\beta\in R$, and let $D\subseteq R$ be a digit set. A finite word $d_0,d_1,\ldots,d_k$, listed from least to most significant, has value

$$
V_\beta(d_0,\ldots,d_k)=\sum_{j=0}^{k}d_j\beta^j.
$$

Equivalently, evaluation is recursive:

$$
V_\beta(\varnothing)=0,
\qquad
V_\beta(d_0,d_1,\ldots)=d_0+\beta V_\beta(d_1,d_2,\ldots).
$$

This is Horner evaluation read from the least significant end.

**Definition 2.1 (Canonical binary word).** A binary word is canonical if it is empty, or if its most significant digit is $1$. Thus leading zeroes are forbidden. The empty word represents zero.

Canonicality is indispensable for uniqueness because appending a zero at the most significant end never changes a numeral's value.

The proofs below follow a shared template. A digit-extraction map chooses $d\in D$ such that $z-d$ is divisible by $\beta$. A quotient map $T(z)=(z-d)/\beta$ is then iterated. Existence requires termination of this iteration, while uniqueness requires that the residue class of $z$ determine $d$ uniquely.

## 3. Negabinary arithmetic

### 3.1 Definition and digit extraction

Set $\beta=-2$ and $D=\{0,1\}$. The value of a binary word is

$$
V_{-2}(d_0,\ldots,d_k)=\sum_{j=0}^{k}d_j(-2)^j.
$$

For $n\in\mathbb Z$, let $r(n)$ be the Euclidean remainder modulo $2$, so $r(n)\in\{0,1\}$, and define

$$
T(n)=\frac{r(n)-n}{2}.
$$

Then

$$
n=r(n)+(-2)T(n).
$$

Thus $r(n)$ is a valid least significant digit and $T(n)$ is the remaining quotient.

### 3.2 A well-founded measure

The tempting measure $|n|$ does not strictly decrease: $T(-1)=1$. Define instead

$$
\mu(n)=
\begin{cases}
2n-1,& n>0,\\
-2n,& n\le0.
\end{cases}
$$

This enumerates the signed integers in the order $0,1,-1,2,-2,\ldots$.

**Lemma 3.1 (Interleaving descent).** If $n\ne0$, then $\mu(T(n))<\mu(n)$.

**Proof sketch.** Split according to the sign and parity of $n$. If $n=2k>0$, then $T(n)=-k$ and $\mu(T(n))=2k<4k-1=\mu(n)$. If $n=2k+1>0$, then $T(n)=-k$ and $2k<4k+1$. For negative even and odd integers, substitute $n=-2k$ or $n=-(2k+1)$ and compute directly. Every nonzero case gives a strict inequality. $\square$

Because $\mu$ takes values in the natural numbers, repeated extraction cannot continue indefinitely without reaching zero.

### 3.3 Existence and uniqueness

**Theorem 3.2 (Existence of canonical negabinary expansions).** Every integer $n$ is the value of a finite canonical base-$-2$ word with digits $0$ and $1$.

**Proof sketch.** Use induction on $\mu(n)$. For $n=0$, use the empty word. For $n\ne0$, Lemma 3.1 gives $\mu(T(n))<\mu(n)$, so the induction hypothesis supplies a canonical word for $T(n)$. Prefix its least significant end with $r(n)$. The identity $n=r(n)+(-2)T(n)$ proves the value. If the quotient word is empty, then $T(n)=0$ and nonzero $n$ forces $r(n)=1$; otherwise the inherited most significant digit is $1$. Hence the result remains canonical. $\square$

**Lemma 3.3 (Parity recovers the first digit).** For every binary digit $d$ and every tail word $w$,

$$
V_{-2}(d,w)\bmod2=d.
$$

**Proof sketch.** The tail contribution is divisible by $2$, while $d$ is either $0$ or $1$. $\square$

**Lemma 3.4 (Canonical zero).** A canonical base-$-2$ word has value zero if and only if it is empty.

**Proof sketch.** If a nonempty canonical word represented zero, Lemma 3.3 would force its first digit to be $0$. Removing that digit and dividing by $-2$ would give a shorter canonical zero representation. Iteration would eventually leave the one-digit canonical word $1$, which does not represent zero. $\square$

**Theorem 3.5 (Unique negabinary representation).** Every integer has exactly one finite canonical base-$-2$ representation with digits $0$ and $1$.

**Proof sketch.** Existence is Theorem 3.2. Suppose two canonical words have equal value. Empty-versus-nonempty equality is excluded by Lemma 3.4. If both are nonempty, Lemma 3.3 forces their least significant digits to agree. Subtract that digit and divide by $-2$; the tails have equal values and remain canonical. Induction on word length proves equality of the words. $\square$

### 3.4 Example

The canonical word $110111_{(-2)}$, displayed most significant digit first, represents

$$
(-2)^5+(-2)^4+(-2)^2+(-2)^1+1=-13.
$$

Running extraction from $-13$ produces least significant digits $1,1,1,0,1,1$, the reverse of the displayed word.

### 3.5 Algorithm and complexity

The extraction algorithm repeatedly computes $r=n\bmod2$, emits $r$, and replaces $n$ by $(r-n)/2$. The number of iterations is $O(\log(|n|+1))$ because, apart from the small sign-switching behavior captured by $\mu$, the quotient has roughly half the magnitude. Under unit-cost arithmetic, time is linear in the output length and space is linear if all digits are stored. With bit complexity included, division by two and parity are shifts and bit tests, yielding near-linear work in the total size of intermediate integers.

## 4. Fibonacci numeration and the golden ratio

### 4.1 Fibonacci normal form

Let

$$
F_0=0,\qquad F_1=1,\qquad F_{k+2}=F_{k+1}+F_k.
$$

**Definition 4.1 (Admissible Fibonacci representation).** An admissible representation of $n\in\mathbb N$ is a finite set of indices $S\subseteq\{2,3,4,\ldots\}$ such that no two members of $S$ are consecutive and

$$
n=\sum_{j\in S}F_j.
$$

The lower bound $j\ge2$ avoids the duplicate unit values $F_1=F_2=1$.

**Theorem 4.2 (Zeckendorf representation).** Every natural number has exactly one admissible Fibonacci representation.

**Proof sketch of existence.** For $n=0$, take the empty sum. For $n>0$, choose the largest $F_k\le n$ and apply the same procedure to $n-F_k$. Since $F_{k+1}>n$, one has $n-F_k<F_{k-1}$. Therefore the next selected Fibonacci number has index at most $k-2$, so adjacent indices never occur. The remainder strictly decreases, proving termination.

**Proof sketch of uniqueness.** The sum of all allowable terms below $F_k$—namely the alternating-index sequence compatible with nonadjacency—is strictly less than $F_k$. Hence an admissible sum whose largest index is $k$ cannot equal one whose largest index is smaller. Two equal admissible sums must share their largest term. Remove it and repeat. $\square$

For example,

$$
100=89+8+3=F_{11}+F_6+F_4,
$$

and the indices $11,6,4$ are pairwise nonconsecutive.

### 4.2 The phinary carry law

Let

$$
\varphi=\frac{1+\sqrt5}{2}.
$$

Its defining identity $\varphi^2=\varphi+1$ implies the following.

**Theorem 4.3 (Golden-ratio carry).** For every $n\in\mathbb N$,

$$
\varphi^n+\varphi^{n+1}=\varphi^{n+2}.
$$

**Proof sketch.** Multiply $\varphi^2=\varphi+1$ by $\varphi^n$. $\square$

In positional notation this is the rewrite $011\leftrightarrow100$, with positions corresponding to consecutive powers. It removes adjacent $1$ digits in the same pattern that $F_n+F_{n+1}=F_{n+2}$ normalizes Fibonacci sums.

### 4.3 Exact scope of the bridge

The carry law and Zeckendorf uniqueness are rigorous and complementary, but they should not be conflated with a stronger false statement. A finite sum of nonnegative powers with binary coefficients has the form

$$
\sum_{j=0}^{k}d_j\varphi^j=A+B\varphi
$$

for integers $A,B$, because every power reduces using $\varphi^2=\varphi+1$. Such a sum is an ordinary integer only when the coefficient $B$ vanishes. Nonnegative binary coefficients do not generally provide the cancellation needed for arbitrary integer targets. General phinary representations of integers require negative powers or a carefully specified alternative convention.

Accordingly, the established bridge is this: every natural number has a unique nonconsecutive Fibonacci sum, and adjacent powers of $\varphi$ obey exactly the same local carry relation. A canonical transducer between the two systems requires explicit treatment of exponent boundaries.

### 4.4 Greedy computation

Precompute Fibonacci numbers up to $n$. Scan downward; whenever $F_k$ does not exceed the current remainder, select $k$ and subtract $F_k$. The greedy proof ensures that $k-1$ will not be selected. The number of Fibonacci values up to $n$ is $O(\log n)$ because $F_k$ grows exponentially, so the arithmetic-operation count is $O(\log n)$ after precomputation.

## 5. Binary notation in the Gaussian plane

### 5.1 The radix and its geometry

The Gaussian integers are

$$
\mathbb Z[i]=\{x+yi:x,y\in\mathbb Z\}.
$$

Set $\beta=i-1$ and use digits $D=\{0,1\}$. A binary word has value

$$
V_\beta(d_0,\ldots,d_k)=\sum_{j=0}^{k}d_j(i-1)^j.
$$

The Gaussian norm is

$$
N(x+yi)=x^2+y^2.
$$

Multiplication by $\beta$ acts on coordinates as

$$
(i-1)(u+vi)=(-u-v)+(u-v)i.
$$

The coordinate sum of this product is $-2v$, which is even. This identifies the residue invariant required for digit extraction.

### 5.2 Forced parity digit and quotient

For $z=x+yi$, define $d(z)\in\{0,1\}$ by

$$
d(z)\equiv x+y\pmod2.
$$

Then $z-d(z)$ is divisible by $i-1$ in $\mathbb Z[i]$. The quotient is

$$
T(z)=\frac{z-d(z)}{i-1}
=rac{y-(x-d(z))}{2}
-rac{(x-d(z))+y}{2}i.
$$

Both coordinates are integers because $(x-d(z))+y$ is even, and the other numerator has the same parity.

**Lemma 5.1 (Reconstruction).** For every Gaussian integer $z$,

$$
z=d(z)+(i-1)T(z).
$$

**Proof sketch.** Substitute the coordinate formula for $T(z)$ and use the multiplication rule above. The real coordinate simplifies to $x$ and the imaginary coordinate to $y$. $\square$

**Lemma 5.2 (Parity recovers the first digit).** If a word begins with $d\in\{0,1\}$ and has value $x+yi$, then

$$
x+y\equiv d\pmod2.
$$

**Proof sketch.** The tail is multiplied by $i-1$, whose output has even coordinate sum. $\square$

### 5.3 Norm descent and its exceptional boundary

A direct calculation gives

$$
2N(T(z))=(x-d(z))^2+y^2.
$$

One might expect $N(T(z))<N(z)$ for every nonzero $z$, but this is false. For $z=i$, the forced digit is $1$ and $T(i)=1$, so both norms equal $1$.

**Lemma 5.3 (Descent outside five points).** If $z\ne0$, then either

$$
z\in\{i,-i,-1,-2+i,-2-i\},
$$

or $N(T(z))<N(z)$.

**Proof sketch.** If strict descent fails, combine

$$
(x-d)^2+y^2\ge2(x^2+y^2)
$$

with $d\in\{0,1\}$. Elementary quadratic estimates force $-2\le x\le2$ and $-1\le y\le1$. There are finitely many lattice points in this rectangle. Checking parity, excluding zero, and testing the inequality leaves exactly the five listed points. $\square$

Each exceptional point has a direct canonical expansion. Listed least significant digit first, suitable words are

$$
\begin{aligned}
i&: (1,1),\\
-i&: (1,1,1),\\
-1&: (1,0,1,1,1),\\
-2+i&: (1,1,1,1,1),\\
-2-i&: (1,1,0,1,0,1,1,1).
\end{aligned}
$$

### 5.4 Existence and uniqueness

**Theorem 5.4 (Existence in base $i-1$).** Every Gaussian integer is represented by a finite canonical binary word in base $i-1$.

**Proof sketch.** Induct on the nonnegative integer $N(z)$. Zero uses the empty word. The five exceptional nonzero points use the explicit words above. Every other nonzero point has $N(T(z))<N(z)$ by Lemma 5.3, so the induction hypothesis represents $T(z)$. Prefix the forced digit $d(z)$ and apply Lemma 5.1. Canonicality is inherited from a nonempty quotient word; if the quotient word is empty, reconstruction and $z\ne0$ force the prefixed digit to be $1$. $\square$

**Lemma 5.5 (Canonical zero in the complex base).** A canonical base-$(i-1)$ binary word representing zero is empty.

**Proof sketch.** Lemma 5.2 forces the first digit of a zero-valued nonempty word to be $0$. Cancel it and divide by the nonzero radix to obtain a shorter canonical zero word. Iteration contradicts the nonzero value of the final leading $1$. $\square$

**Theorem 5.6 (Unique Gaussian binary representation).** Every Gaussian integer has exactly one finite canonical base-$(i-1)$ expansion using digits $0$ and $1$.

**Proof sketch.** Existence is Theorem 5.4. For uniqueness, compare two canonical words of equal value. Lemma 5.5 handles the empty cases. Lemma 5.2 forces equal first digits. Subtract that digit and cancel the nonzero factor $i-1$ to equate the tails. Induction proves equality of the complete words. $\square$

The two-digit example

$$
11_{(i-1)}=1+(i-1)=i
$$

shows how a real binary alphabet can encode an imaginary value without an imaginary digit.

### 5.5 Computational complexity

Each extraction uses coordinate parity and several additions, subtractions, and divisions by two. Outside a fixed exceptional region, the squared norm decreases by a constant-factor tendency, so typical representation length is logarithmic in $N(z)+1$. The exceptional points are handled by a constant lookup table. Under unit-cost integer arithmetic, the algorithm is linear in the emitted digit count; under bit complexity, all quotient operations remain shifts by one bit.

## 6. Unified interpretation

The three systems can be organized around four principles.

**Residues determine digits.** In base $-2$, $n\bmod2$ selects the digit. In base $i-1$, the parity of the coordinate sum $x+y$ does so. In Fibonacci normalization, the recurrence determines which adjacent patterns can be carried.

**A quotient or rewrite advances the computation.** The maps $T(n)$ and $T(z)$ remove one least significant digit. The rule $011\to100$ removes adjacency in phinary strings.

**Termination needs geometry appropriate to the radix.** Absolute value is inadequate for negabinary at $-1$, so the interleaving measure is used. Gaussian norm is nearly sufficient in the complex plane, but a finite exceptional boundary must be isolated. Fibonacci greedy subtraction decreases the natural-number remainder directly.

**Canonical restrictions support uniqueness.** Leading zeroes are forbidden in positional words. Fibonacci indices are distinct, at least $2$, and nonconsecutive. Once these conventions are fixed, local residue information or dominance of the largest term forces the representation.

This perspective also encompasses ordinary uniform bases. For positive integer $b$, the positional value $\sum_jd_jb^j$ is a uniform mixed-radix evaluation: every position uses the same radix $b$. Exotic systems reveal which parts of the familiar theorem depend on positivity and which depend only on local division.

## 7. Applications and numerical experiments

Negabinary coding stores signed integers without a sign bit. Addition still requires normalization, but sign changes no longer split the representation space into separate positive and negative formats. This can be useful when studying symmetric digit systems and arithmetic circuit design.

Fibonacci representations underlie prefix-oriented integer codes and offer a carry structure unlike standard binary. The prohibition on adjacent $1$ digits creates recognizable separators and can limit certain propagation patterns. The golden-ratio identity supplies an algebraic model for those rewrites.

Complex binary notation serializes a two-dimensional lattice point into a one-dimensional bit string. Potential applications include lattice addressing, symbolic dynamics, and arithmetic on Gaussian integers. The finite exceptional region also suggests an implementation pattern: a generic norm-reducing loop plus a small terminal table.

Useful numerical experiments include round-trip tests over intervals of integers, heat maps of complex representation lengths over square lattice windows, and comparisons between Fibonacci greedy digit counts and ordinary binary Hamming weights. Such experiments illustrate the theorems but do not replace their structural arguments.

## 8. Limitations and cautions

Three boundaries deserve emphasis.

First, canonicality cannot be omitted. Leading zeroes generate infinitely many syntactic representations of the same value in both positional systems.

Second, a decreasing measure must be proved rather than guessed. Absolute value fails for negabinary, and Gaussian norm fails at least at $i$. The correct results use an alternative measure or explicit exceptional cases.

Third, the golden-ratio statement must distinguish Fibonacci numeration from literal phinary expansions. The theorem proved for all natural numbers is unique nonconsecutive Fibonacci representation. The algebraic theorem is the carry identity for powers of $\varphi$. A full canonical base-$\varphi$ representation theorem for ordinary integers needs negative exponents and endpoint conventions beyond those two facts.

## 9. Future directions

A natural first problem is to classify quadratic algebraic integers of norm two for which $\{0,1\}$ gives unique finite expansions throughout the ambient imaginary quadratic integer ring. The base $i-1$ argument suggests a criterion involving residue parity, norm descent, and a finite exceptional region.

A second direction is a terminating and confluent transducer between Zeckendorf representations and phinary normal forms. Both use $011\leftrightarrow100$, but their index sets and boundary conditions differ. Canonical endpoint conventions must be part of the theorem.

A third direction extends negative-base uniqueness to Euclidean domains. If a complete residue digit set supports a strictly decreasing extraction map outside finitely many exceptions, existence should follow from descent, while uniqueness should reduce to residue injectivity.

Finally, numeral systems can be compared by carry complexity. For random length-$n$ inputs, one may ask whether normalization cost has a linear asymptotic controlled by the stationary distribution of a finite carry automaton. This offers a quantitative answer to which radix an unfamiliar computing culture might prefer.

## 10. Conclusion

Negative, irrational, and complex radices are not curiosities detached from ordinary arithmetic. They expose its core mechanisms. Base $-2$ gives a complete, unique, signless binary notation for $\mathbb Z$. Nonconsecutive Fibonacci sums give a complete, unique notation for $\mathbb N$, while the golden-ratio identity explains their local carry law. Base $i-1$ gives a complete, unique, signless binary notation for the entire Gaussian lattice $\mathbb Z[i]$, with five exceptional points marking the precise failure of naive norm descent.

Across all three settings, the decisive questions are the same: which residue chooses the next digit, which measure guarantees termination, and which canonical convention removes ambiguity? Once those questions are answered, positional arithmetic extends far beyond the number line and far beyond base ten.