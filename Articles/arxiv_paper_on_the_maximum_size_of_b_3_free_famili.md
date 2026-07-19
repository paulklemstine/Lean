# Two Detectors, Two Kinds of Structure: Norms for Cyclotomic Signatures and Writhe for Braids

Mathematics often advances by finding the right detector: a simple quantity that ignores irrelevant detail while exposing a feature that matters. A thermometer forgets the positions of trillions of molecules but preserves temperature. A checksum compresses a long message into a small fingerprint. In algebra and topology, invariants play the same role. They turn complicated objects into numbers or coordinates that are easier to compare.

This article develops two such detectors. The first lives in the triangular arithmetic of the Eisenstein integers and measures polynomial values at a cube root of unity. The second, called **writhe**, measures the total signed twisting in a braid. Both detectors are powerful, both support exact theorems, and both have sharply defined limits. A final example from Fibonacci numbers shows a related philosophy: a prime can serve as a historical marker, certifying that a term has acquired genuinely new arithmetic content.

## Arithmetic on a triangular lattice

Let $\omega$ satisfy

$$
\omega^2+\omega+1=0.
$$

Thus $\omega$ is a nonreal cube root of unity and $\omega^3=1$. Every Eisenstein integer has the form $a+b\omega$, where $a$ and $b$ are ordinary integers. We encode it by the coordinate pair $(a,b)$. Multiplication follows from $\omega^2=-1-\omega$:

$$
(a+b\omega)(c+d\omega)=(ac-bd)+(ad+bc-bd)\omega.
$$

The natural squared length on this lattice is

$$
N(a+b\omega)=a^2-ab+b^2.
$$

Geometrically, this is the squared Euclidean distance from the origin in a lattice whose axes meet at an angle of $120$ degrees. Arithmetically, it is a norm: it converts multiplication into ordinary integer multiplication.

**Norm Multiplicativity Theorem.** For all Eisenstein integers $x$ and $y$,

$$
N(xy)=N(x)N(y).
$$

The proof is direct and illuminating. Write $x=a+b\omega$ and $y=c+d\omega$, use the multiplication formula above, substitute the resulting two coordinates into $u^2-uv+v^2$, and expand. Every cross-term combines to give $(a^2-ab+b^2)(c^2-cd+d^2)$.

Repeated multiplication now has a clean growth law. Define $x^0=1$ and $x^{k+1}=x x^k$ for natural numbers $k$.

**Eisenstein Power-Law Theorem.** For every Eisenstein integer $x$ and every natural number $k$,

$$
N(x^k)=N(x)^k.
$$

The proof is induction. At $k=0$, both sides equal $1$. If the identity holds for $k$, multiplicativity gives

$$
N(x^{k+1})=N(x)N(x^k)=N(x)N(x)^k=N(x)^{k+1}.
$$

This theorem turns an iterated two-dimensional multiplication into a one-dimensional exponential law. If $N(x)>1$, the norm grows exponentially; if $N(x)=1$, every power remains on the unit shell of the triangular lattice.

## A cube-root filter for polynomial signatures

Given an integer polynomial

$$
p(t)=c_0+c_1t+\cdots+c_mt^m,
$$

we may evaluate it at $t=\omega$. Because $\omega^3=1$, the powers repeat every three steps. The result is an Eisenstein integer, and its norm supplies a nonnegative integer statistic $N(p(\omega))$.

Consider three proposed signatures whose evaluations are

$$
p_{\mathrm{lin}}(\omega)=1,
\qquad
p_{\mathrm{cre}}(\omega)=2+2\omega,
\qquad
p_{\mathrm{conf}}(\omega)=-1-\omega.
$$

Their norms are

$$
N(1)=1,
\qquad
N(2+2\omega)=4,
\qquad
N(-1-\omega)=1.
$$

This yields an exact separation result.

**Creative-Signature Separation Theorem.** The norm of the creative signature is $4$, while the norms of both comparison signatures are $1$. Consequently, the cube-root norm separates the creative signature from each comparator.

But it also gives an exact impossibility result.

**Collision Proposition.** The linear and confused signatures have the same cube-root norm. Therefore this single statistic cannot distinguish all three signatures or impose a strict three-way ranking on them.

That negative conclusion matters. A detector is useful only when its resolution is understood. Evaluating at a cube root of unity compresses a polynomial according to exponents modulo $3$; taking the norm compresses it further by forgetting direction in the Eisenstein lattice. Different polynomials can therefore collide. The calculation does not invalidate the statistic—it tells us precisely what information it preserves and what it discards.

## Braids and signed twisting

A braid on $n+1$ strands can be described using generators $\sigma_1,\ldots,\sigma_n$. The symbol $\sigma_i$ represents one strand crossing over its neighbor; $\sigma_i^{-1}$ represents the reverse crossing. Words in these symbols are identified according to the standard braid relations.

The **writhe** of a braid word is its exponent sum: add $1$ for each positive generator and $-1$ for each inverse. For example,

$$
w(\sigma_1\sigma_2^{-1}\sigma_1)=1-1+1=1.
$$

The braid relations preserve this sum, so writhe depends only on the braid represented by the word. It also respects multiplication:

$$
w(\beta\gamma)=w(\beta)+w(\gamma).
$$

In particular, every generator has writhe $1$.

**Distinct-Powers Theorem.** Fix any Artin generator $\sigma_i$. If $a$ and $b$ are natural numbers and

$$
\sigma_i^a=\sigma_i^b,
$$

then $a=b$. Hence the natural powers $1,\sigma_i,\sigma_i^2,\ldots$ are all distinct.

The proof applies writhe to the alleged equality. Since $w(\sigma_i^k)=k$, equality of braids forces equality of natural numbers. Thus one integer-valued detector reveals an infinite cyclic pattern inside every braid group that has a generator.

A familiar two-strand braid representative of the trefoil is $\sigma_1^3$. Its writhe is $3$, whereas the identity braid has writhe $0$.

**Trefoil-Word Nonidentity Theorem.** The braid $\sigma_1^3$ is not the identity braid.

This statement is deliberately about the braid itself. Passing from a braid to the knot or link formed by closing its strands introduces a different equivalence problem. Braid equality is governed by braid relations; equivalence of closures additionally involves Markov moves. A certificate for nonidentity of a braid is not automatically a complete classifier of its closure.

Writhe also has a clear blind spot. Any balanced word containing equally many positive and negative letters has writhe zero. Such a word need not represent the identity. Thus writhe is an effective nontriviality certificate when it is nonzero, but it is not a complete classification invariant.

This asymmetry is common in mathematics: a positive test can be decisive while a zero test is inconclusive. A smoke alarm confirms smoke when it sounds, but silence does not certify that every room is clear.

## New primes in the Fibonacci sequence

The same detector philosophy appears in number theory. Let $F_0=0$, $F_1=1$, and

$$
F_{n+2}=F_{n+1}+F_n.
$$

A prime $p$ is a **primitive prime divisor** of $F_n$ if $p$ divides $F_n$ but divides no earlier positive Fibonacci number $F_k$ with $0<k<n$. Such a prime records genuinely new divisibility at index $n$.

**Finite-Range Fibonacci Primitive-Divisor Theorem.** For every integer $n$ satisfying

$$
13\le n\le 10000,
$$

there exists a prime $p$ such that $p\mid F_n$ and $p\nmid F_k$ for every integer $k$ with $0<k<n$.

The argument separates prime and composite indices. At prime indices in the range, a general prime-index result supplies the new divisor. At composite indices, one isolates the part of $F_n$ coprime to all earlier Fibonacci terms and establishes throughout the stated finite range that this part is greater than $1$; a prime factor of that part is primitive. The upper bound is essential to the stated result: no unproved extrapolation beyond $10000$ is needed.

Small examples make the definition concrete. We have $F_{13}=233$, so $233$ is primitive at index $13$. Also $F_{14}=377=13\cdot29$; the prime $29$ first appears at index $14$, while $13$ appeared earlier. The theorem says that this phenomenon of acquiring at least one new prime continues at every index through $10000$.

## Three algorithms you can perform by hand

The detectors are not merely abstract. To evaluate a polynomial at $\omega$, use Horner's rule: begin at zero, repeatedly multiply the current Eisenstein pair by $\omega$, and add the next coefficient. Because every intermediate value has only two integer coordinates, the procedure is exact and linear in the number of coefficients.

To calculate writhe, scan a braid word once. Add $1$ for a positive crossing and subtract $1$ for a negative crossing. A word of a million letters still needs only one running integer. This economy explains why writhe is a useful first test even when stronger braid invariants will ultimately be needed.

To search for a primitive divisor of a modest Fibonacci number, compute and factor $F_n$. For every prime factor $p$, generate Fibonacci residues modulo $p$ and locate the first positive zero. The prime is primitive exactly when that first zero occurs at $n$. The method becomes expensive for large indices because Fibonacci numbers grow rapidly, but it makes small examples completely transparent.

## The art of using an invariant

The Eisenstein norm, braid writhe, and primitive Fibonacci divisors live in different mathematical worlds, yet they teach the same methodological lesson.

First, define the compressed quantity exactly. The Eisenstein norm is $a^2-ab+b^2$, not an informal notion of magnitude. Writhe is an exponent sum on braid classes, not a count attached to a particular drawing. A primitive divisor is defined by exclusion from every earlier positive index.

Second, prove compatibility with the structure. Norms multiply. Writhe adds. Primitive divisors encode first occurrence. This compatibility is what makes each detector useful under iteration, concatenation, or recurrence.

Third, state the scope honestly. The cube-root norm separates one signature but permits a collision. Writhe distinguishes all natural powers of a generator but loses balanced words. The Fibonacci theorem here covers the complete interval from $13$ through $10000$, not an unsupported infinite tail.

Across all three examples, compression creates leverage: a difficult comparison becomes an integer calculation, but only after the relevant algebra has established that the integer is meaningful. A good invariant is not a magical oracle. It is a carefully calibrated instrument. Its triumph lies as much in knowing what it cannot see as in celebrating what it reveals.