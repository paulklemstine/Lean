# Exponential Preimage Ambiguity and Common Orbit Suffixes in the Parameter-Four Logistic Map

**Aristotle**  
**July 18, 2026**

## Abstract

For the logistic map $f:(0,1)\to(0,1]$ defined by $f(x)=4x(1-x)$, we construct an explicit complete binary family of backward trajectories above every interior target. The two inverse branches

$$
L(y)=\frac{1-\sqrt{1-y}}{2},\qquad U(y)=\frac{1+\sqrt{1-y}}{2}
$$

map $(0,1)$ into disjoint halves of $(0,1)$ and satisfy $f\circ L=f\circ U=\operatorname{id}$. An $n$-bit word therefore decodes recursively to an interior seed whose $n$th iterate is a prescribed target $y\in(0,1)$. We prove that distinct words produce distinct seeds, yielding an explicit injective family of cardinality $2^n$. Once these seeds reach $y$, their entire future trajectories coincide: for every $k\geq 0$, the $(n+k)$th iterate of each seed equals the $k$th iterate of $y$. This establishes exponential exact-real ambiguity in reconstructing a seed from a delayed orbit suffix. We give constructive algorithms, numerical examples, complexity bounds, and a careful cryptographic interpretation. The result concerns exact real dynamics and does not substitute for finite-precision or computational security analysis.

## 1. Introduction

The logistic family $x\mapsto rx(1-x)$ is a standard model of nonlinear population dynamics and deterministic chaos. At the parameter $r=4$, the map has strong sensitivity to initial conditions and an especially transparent relation to angle doubling. These features have repeatedly motivated cryptographic constructions in which an orbit supplies pseudorandom-looking values.

Sensitivity, however, describes the forward separation of nearby states; it does not by itself characterize the inverse problem. Cryptographic seed recovery asks a backward question: how many initial states are compatible with an observed state or suffix? At parameter $4$, each generic state has two explicit one-step predecessors. Iterating those choices produces a binary inverse tree.

The purpose of this paper is to establish the exact structural claims needed for this inverse-tree interpretation. For every interior target $y$ and depth $n$, we construct a seed for every word in $\{0,1\}^n$. We prove four properties:

1. every decoded seed and every intermediate backward state remains in $(0,1)$;
2. applying the logistic map $n$ times recovers $y$;
3. distinct bit words produce distinct seeds;
4. all decoded trajectories have the same suffix after time $n$.

Since $\lvert\{0,1\}^n\rvert=2^n$, the construction gives an exponential lower bound on the cardinality of the $n$-step fiber. The word “lower bound” is deliberate: the results here explicitly inject the binary key space into the fiber. An exact theorem saying that this family exhausts the entire interior fiber requires a converse decomposition of arbitrary preimages and is left as a natural extension.

The cryptographic consequence is an information-theoretic ambiguity statement in exact arithmetic. If observation begins at time $n$ with an interior state, then an entire future orbit suffix is compatible with at least $2^n$ explicitly described seeds. This does not establish the security of a cipher. Real implementations introduce quantization, cycle structure, output extraction, and an attacker model, all of which require separate treatment.

## 2. Dynamical setting and notation

### Definition 2.1 (Parameter-four logistic map)

Define

$$
f(x)=4x(1-x)
$$

for real $x$. For $n\in\mathbb{N}$, write $f^n$ for functional iteration, with $f^0(x)=x$ and $f^{n+1}(x)=f(f^n(x))$.

For a target $y$ and depth $n$, the interior $n$-step fiber is

$$
\mathcal{F}_n(y)=\{x\in(0,1):f^n(x)=y\}.
$$

The main construction gives an explicit subset of $\mathcal{F}_n(y)$ indexed by $n$ bits.

### Definition 2.2 (Inverse branches)

For $y\leq 1$, define the lower and upper branches

$$
L(y)=\frac{1-\sqrt{1-y}}{2},
\qquad
U(y)=\frac{1+\sqrt{1-y}}{2}.
$$

For a bit $b\in\{0,1\}$, let

$$
B_b(y)=
\begin{cases}
L(y),&b=0,\\
U(y),&b=1.
\end{cases}
$$

The two branches arise by solving $4x(1-x)=y$. Their sum is $1$, expressing the reflection symmetry $f(x)=f(1-x)$.

### Definition 2.3 (Recursive decoding)

Let $b=(b_0,\ldots,b_{n-1})\in\{0,1\}^n$. Define

$$
D_{\varnothing}(y)=y
$$

for the empty word, and for $n>0$ define

$$
D_b(y)=B_{b_0}\bigl(D_{(b_1,\ldots,b_{n-1})}(y)\bigr).
$$

Equivalently,

$$
D_b(y)=B_{b_0}\circ B_{b_1}\circ\cdots\circ B_{b_{n-1}}(y).
$$

The order is important: the first bit selects the outermost branch and hence the earliest seed location, while the final bit selects the predecessor immediately above the target.

## 3. One-step branch geometry

We begin with elementary identities that drive the entire construction.

### Lemma 3.1 (Right-inverse identity)

For every real $y\leq 1$ and each $b\in\{0,1\}$,

$$
f(B_b(y))=y.
$$

#### Proof sketch

Write $s=\sqrt{1-y}$. For either sign, $B_b(y)=(1\pm s)/2$ and $1-B_b(y)=(1\mp s)/2$. Therefore

$$
4B_b(y)(1-B_b(y))
=4\frac{(1+s)(1-s)}{4}
=1-s^2
=y,
$$

using $s^2=1-y$. The computation is identical for the lower and upper branches. $\square$

### Lemma 3.2 (Interior preservation)

If $0<y<1$, then

$$
0<L(y)<\frac12< U(y)<1.
$$

In particular, each inverse branch maps $(0,1)$ into $(0,1)$.

#### Proof sketch

From $0<y<1$ we obtain $0<1-y<1$, hence $0<\sqrt{1-y}<1$. Substituting these strict inequalities into $(1\mp\sqrt{1-y})/2$ gives the claimed chain. $\square$

The strict separation at $1/2$ ensures that branch labels can be recovered from the output of a single inverse step.

### Lemma 3.3 (Injectivity of each branch)

For each fixed $b\in\{0,1\}$, the map $B_b$ is injective on $(0,1)$.

#### Proof sketch

If $L(x)=L(y)$, multiplying by $2$ and subtracting $1$ yields $\sqrt{1-x}=\sqrt{1-y}$. Squaring gives $x=y$. The same argument applies to $U$, with the opposite sign. Equivalently, $L$ is strictly increasing and $U$ is strictly decreasing on $(0,1)$. $\square$

### Remark 3.4 (Disjoint branch images)

Lemma 3.2 says more than individual injectivity. The images are disjoint:

$$
L((0,1))\subset(0,1/2),
\qquad
U((0,1))\subset(1/2,1).
$$

Thus equality $B_a(x)=B_b(y)$ for interior $x,y$ first forces $a=b$, and then Lemma 3.3 forces $x=y$. This “recover the head bit, then cancel the branch” principle proves injectivity of the full decoding map.

## 4. The binary inverse tree

### Lemma 4.1 (All decoded states are interior)

Let $y\in(0,1)$ and $b\in\{0,1\}^n$. Then

$$
D_b(y)\in(0,1).
$$

#### Proof sketch

Induct on the word length. The empty word returns $y$, which is interior by hypothesis. For a nonempty word, the shorter suffix decodes to an interior point by induction; Lemma 3.2 then shows that applying either outer branch keeps the result interior. $\square$

### Theorem 4.2 (Iterated recovery)

For every $y\in(0,1)$, every $n\geq 0$, and every $b\in\{0,1\}^n$,

$$
f^n(D_b(y))=y.
$$

#### Proof sketch

Induct on $n$. At depth $0$, the statement is $f^0(y)=y$. For a nonempty word $b=(b_0,b')$, the definition gives $D_b(y)=B_{b_0}(D_{b'}(y))$. By Lemma 4.1, the inner decoded value lies in $(0,1)$ and hence is at most $1$. Lemma 3.1 removes the outer branch:

$$
f(D_b(y))=D_{b'}(y).
$$

Applying the remaining $n-1$ iterates and the induction hypothesis yields $y$. $\square$

### Theorem 4.3 (Injective binary decoding)

For fixed $y\in(0,1)$ and $n\geq 0$, the map

$$
D_{n,y}:\{0,1\}^n\longrightarrow(0,1),
\qquad b\longmapsto D_b(y),
$$

is injective.

#### Proof sketch

Proceed by induction on $n$. The claim is trivial for the unique empty word. Suppose $D_a(y)=D_b(y)$ for two words of positive length. By Lemma 4.1, their inner suffix decodings lie in $(0,1)$. If $a_0\neq b_0$, then Lemma 3.2 places one outer branch value below $1/2$ and the other above $1/2$, contradicting equality. Hence $a_0=b_0$. Lemma 3.3 allows cancellation of this common outer branch, so the decoded suffixes agree. The induction hypothesis implies equality of all remaining bits, and therefore $a=b$. $\square$

### Theorem 4.4 (Exponential preimage family)

For every interior target $y\in(0,1)$ and every $n\geq 0$, there is an explicitly defined injection

$$
D_{n,y}:\{0,1\}^n\hookrightarrow\mathcal{F}_n(y).
$$

Consequently,

$$
|\mathcal{F}_n(y)|\geq 2^n.
$$

More explicitly, the $2^n$ values $D_b(y)$ are pairwise distinct, lie in $(0,1)$, and satisfy $f^n(D_b(y))=y$.

#### Proof sketch

Lemma 4.1 puts each decoded value in the required interval. Theorem 4.2 puts it in the fiber. Theorem 4.3 gives injectivity. Finally, the set of binary words of length $n$ has cardinality $2^n$, because each of the $n$ positions admits two independent choices. $\square$

### Corollary 4.5 (Two distinct colliding seeds)

If $n>0$ and $y\in(0,1)$, then there exist distinct $x_0,x_1\in(0,1)$ such that

$$
f^n(x_0)=f^n(x_1)=y.
$$

#### Proof sketch

Choose two distinct words, for example the all-zero and all-one words. Positive length ensures that they differ. Theorem 4.3 makes their decoded seeds distinct, while Theorem 4.2 sends both to $y$. $\square$

## 5. Common suffixes and observational ambiguity

The preceding theorem concerns a collision at one time. Determinism strengthens it to equality at every later time.

### Theorem 5.1 (Common orbit suffix)

For every $y\in(0,1)$, $n,k\geq 0$, and $b\in\{0,1\}^n$,

$$
f^{n+k}(D_b(y))=f^k(y).
$$

#### Proof sketch

Functional iteration satisfies $f^{n+k}=f^k\circ f^n$. By Theorem 4.2, $f^n(D_b(y))=y$. Substitution gives

$$
f^{n+k}(D_b(y))=f^k(f^n(D_b(y)))=f^k(y).
$$

Thus all branch words yield the same state not only at time $n$ but at every subsequent time. $\square$

### Corollary 5.2 (Exponential suffix ambiguity)

Fix $y\in(0,1)$ and suppose an observer sees the exact suffix

$$
(y,f(y),f^2(y),\ldots)
$$

beginning at time $n$. At least $2^n$ pairwise distinct interior seeds are compatible with that entire suffix, namely the values $D_b(y)$ for $b\in\{0,1\}^n$.

#### Proof sketch

Theorem 4.4 supplies $2^n$ distinct seeds. Theorem 5.1 shows that every one of their orbit suffixes agrees term by term with the displayed sequence. $\square$

This is an exact-real, information-theoretic statement. It assumes the observer knows the state $y$ itself, rather than a rounded value or a derived output symbol. It says the suffix cannot select among these candidate histories; it does not claim that every cryptographic key corresponds to one of them or that no side information can distinguish them.

## 6. Constructive algorithms

### 6.1 Decoding one branch word

Given a target $y$ and bits $b_0,\ldots,b_{n-1}$, the nested expression is most efficiently evaluated from the last bit toward the first.

**Algorithm 1: Inverse-word decoding**

1. Validate $0<y<1$.
2. Set $x\leftarrow y$.
3. For $j=n-1,n-2,\ldots,0$:
   - if $b_j=0$, set $x\leftarrow(1-\sqrt{1-x})/2$;
   - if $b_j=1$, set $x\leftarrow(1+\sqrt{1-x})/2$.
4. Return $x$.

The algorithm uses $n$ square roots and $O(n)$ arithmetic operations, with $O(1)$ auxiliary storage beyond the input. In exact symbolic arithmetic, expression size may grow; numerical evaluation keeps a constant-size floating-point state but introduces rounding.

### 6.2 Enumerating the indexed family

To enumerate all depth-$n$ seeds, loop over the integers $0$ through $2^n-1$, represent each integer by an $n$-bit word, and decode it. The runtime is $O(n2^n)$ and output storage is $O(2^n)$. Exponential cost is unavoidable when explicitly writing $2^n$ outputs.

A breadth-first alternative starts with the list $[y]$ and replaces every current value $z$ by $[L(z),U(z)]$ at each level. This uses $O(2^n)$ time up to constant-cost arithmetic because each tree edge is evaluated once, and $O(2^n)$ storage for the frontier. Its ordering differs from lexicographic nested-word decoding but its set of leaves is the same.

### 6.3 Verifying recovery and suffix collision

Numerically, one may apply $f$ repeatedly to each seed and compare the result to $y$. Floating-point errors should be measured with a tolerance rather than exact equality. A second check compares several later iterates against the orbit beginning at $y$. Such experiments illustrate the theorems but also reveal conditioning issues: inverse steps involving square roots and forward chaotic amplification can magnify rounding discrepancies.

## 7. Numerical examples

### Example 7.1 (A one-step split)

Let $y=3/4$. Then $\sqrt{1-y}=1/2$, so

$$
L(3/4)=1/4,
\qquad
U(3/4)=3/4.
$$

Indeed,

$$
f(1/4)=4\cdot\frac14\cdot\frac34=\frac34,
$$

and the same equality holds for $3/4$ by symmetry.

### Example 7.2 (Depth three)

For any chosen interior target, the eight words in $\{0,1\}^3$ decode to eight distinct seeds. Their exact numerical values depend on the target, but each lies in $(0,1)$ and satisfies

$$
f^3(x)=y.
$$

The first bit can be read from the seed’s side of $1/2$: a word beginning with $0$ produces a seed below $1/2$, while a word beginning with $1$ produces one above $1/2$. After applying $f$ once, the same test reads the second bit from the next state, and so forth. This provides an operational explanation of injectivity.

### Example 7.3 (Shared future)

Take two different depth-$n$ words $a$ and $b$, and set $x_a=D_a(y)$ and $x_b=D_b(y)$. Although $x_a\neq x_b$, after $n$ updates both trajectories equal $y$. For any requested suffix length $m$,

$$
\bigl(f^n(x_a),\ldots,f^{n+m}(x_a)\bigr)
=
\bigl(f^n(x_b),\ldots,f^{n+m}(x_b)\bigr)
=
\bigl(y,\ldots,f^m(y)\bigr).
$$

In floating-point experiments these equalities hold only approximately if the decoded seeds have already been rounded. Computing each inverse path at high precision makes the expected pattern visible for greater depths.

## 8. Cryptographic interpretation

The inverse tree creates a precise bridge between dynamical systems and cryptographic observability. Each backward step contributes one binary branch choice. A delay of $n$ steps hides an $n$-bit branch history among $2^n$ candidates. Once the histories coalesce at $y$, no later exact orbit value can recover those choices.

This observation is relevant to any design that treats the initial condition as secret and reveals an orbit only after discarding an initial transient. If the revealed value is an exact interior state, then the future suffix alone is many-to-one with respect to the seed. The theorem therefore obstructs unique reconstruction from that data.

Several cautions prevent overinterpretation.

First, ambiguity is not equivalent to semantic security. A cipher requires a key space, encryption and decryption algorithms, a message model, and a quantified attacker advantage. The branch family may or may not align with valid keys after key encoding.

Second, exact real numbers are not directly representable by ordinary digital hardware. Under fixed-point or floating-point arithmetic, the implemented transition is a map on a finite set. Every orbit is eventually periodic, distinct real branches may round to the same machine value, and algebraic identities may fail by a rounding unit. A finite-state security analysis must study the implemented map.

Third, a real system may reveal a quantized function of the state rather than the state itself. Quantization can increase observational ambiguity, while side channels or additional outputs can reduce it. The current result isolates the dynamical contribution before such engineering choices.

Fourth, the theorem concerns interior targets. At $y=1$, the two one-step formulas coincide at $1/2$, so the binary split degenerates. At $y=0$, the one-step preimages include boundary points. These critical and boundary fibers require separate formulas.

## 9. Relation to angle doubling

The identity

$$
f(\sin^2\theta)=4\sin^2\theta\cos^2\theta=\sin^2(2\theta)
$$

explains why the inverse tree is binary: reversing one logistic step corresponds to halving an angle, with sign and periodicity choices hidden by the square of the sine. Iterating suggests closed expressions of the form

$$
\sin^2\left(\frac{\pm\theta+k\pi}{2^n}\right)
$$

when $y=\sin^2\theta$. The recursive branch construction has the advantage of requiring no choice of a global angle and of making interval membership and branch separation immediate. A complete equivalence between the recursive and trigonometric indexings would sharpen the description of the entire fiber.

## 10. Limitations and open problems

The current theorems prove an injection of $2^n$ words into the interior fiber. A natural strengthening is exact fiber cardinality: prove that every $x\in(0,1)$ with $f^n(x)=y$ arises from one unique branch word. The one-step quadratic formula strongly suggests this converse, but it should be stated and proved with careful handling of intermediate states.

Finite precision is the most immediate applied extension. Given a rounding rule and word length, one can ask which real branches collapse, how many machine seeds share a suffix, and how quickly cycles appear. The answer will depend on the arithmetic model.

A stream-cipher analysis would define an observation function and security game. The common-suffix theorem could then become a component of a precise indistinguishability obstruction or key-recovery lower bound, rather than a free-standing analogy.

Finally, inverse-branch Jacobians can be combined with transfer-operator methods to derive the invariant arcsine density

$$
\rho(x)=\frac{1}{\pi\sqrt{x(1-x)}}
$$

and the characteristic Lyapunov exponent $\log 2$. These measure-theoretic statements would connect backward multiplicity to average forward expansion.

## 11. Recovering branch labels before coalescence

The injectivity argument has an operational converse on the constructed family. Let $x=D_b(y)$ for an unknown word $b\in\{0,1\}^n$. Lemma 3.2 implies

$$
b_0=\begin{cases}0,&x<1/2,\\1,&x>1/2.\end{cases}
$$

Applying $f$ removes the first inverse branch, so $f(x)=D_{(b_1,\ldots,b_{n-1})}(y)$. The side of $f(x)$ relative to $1/2$ therefore reveals $b_1$. Continuing gives

$$
b_j=\begin{cases}0,&f^j(x)<1/2,\\1,&f^j(x)>1/2,\end{cases}
\qquad 0\leq j<n.
$$

This yields a finite itinerary decoder.

### Proposition 11.1 (Itinerary recovery)

Let $y\in(0,1)$, $b\in\{0,1\}^n$, and $x=D_b(y)$. For every $j<n$, the state $f^j(x)$ is not $1/2$, and its side of $1/2$ uniquely determines $b_j$ by the formula above.

#### Proof sketch

Repeated application of the right-inverse identity gives

$$
f^j(D_b(y))=D_{(b_j,\ldots,b_{n-1})}(y).
$$

This remaining decoding has outer branch $B_{b_j}$. Interior preservation applies to its inner argument. Branch separation then puts the result strictly below $1/2$ when $b_j=0$ and strictly above $1/2$ when $b_j=1$. $\square$

This proposition sharpens the information narrative. Before coalescence, the finite trajectory retains all branch labels and they can be read one by one. At time $n$, the state is $y$ and all labels have disappeared from the subsequent deterministic suffix. The theorem therefore identifies exactly where the indexed historical information ceases to be represented by the orbit state.

## 12. Computational conditioning

The construction is exact over real numbers, but numerical experiments require attention to stability. The derivative of an inverse branch has magnitude

$$
\left|L'(y)\right|=\left|U'(y)\right|=\frac{1}{4\sqrt{1-y}},
$$

for $0<y<1$. Near $y=1$, this derivative becomes large, so small target errors can produce larger predecessor errors. In contrast, away from $1$ an inverse step may contract perturbations. A sequence of branch choices can pass near the critical value and become poorly conditioned.

Forward iteration has the complementary issue. The derivative is

$$
f'(x)=4-8x,
$$

whose magnitude can be as large as $4$. Rounding error in a decoded seed may therefore be amplified during the $n$ forward checks. This explains why a floating-point program may report small nonzero recovery errors even though the exact identities hold. It also explains why errors tend to become more visible as depth increases.

For responsible numerical validation, one should report the arithmetic precision, target, depth, branch ordering, and error metric. A useful absolute recovery residual is

$$
R_b=\left|f^n(D_b(y))-y\right|.
$$

A suffix residual through horizon $m$ is

$$
S_b(m)=\max_{0\leq k\leq m}\left|f^{n+k}(D_b(y))-f^k(y)\right|.
$$

In exact arithmetic both quantities vanish. In floating-point arithmetic they measure accumulated numerical error rather than a failure of the mathematical result.

## 13. Broader applications

The inverse-tree method is useful beyond cryptography. In nonlinear state estimation, it describes multiple latent histories compatible with a later measurement. In symbolic dynamics, the branch word is an itinerary recording which side of the critical point a pre-collision orbit occupies. In computational dynamics, breadth-first branch expansion supplies a direct method for sampling backward orbits. In information theory, each inverse level contributes one bit of discrete historical choice within the indexed family.

These interpretations share a common structural core but require different additional assumptions. State estimation adds noise and priors; symbolic dynamics asks about admissible infinite itineraries; numerical dynamics specifies arithmetic; cryptography specifies adversarial resources and observable outputs. The binary preimage theorem is a reusable deterministic component, not a replacement for those surrounding theories.

## 14. Future research program

Six directions arise naturally. First, exact fiber cardinality would turn the current lower bound into an equality by proving that every interior preimage chooses a unique branch at every level. Second, closed trigonometric indexing would identify recursive words with angle-halving expressions. Third, finite-precision analysis would quantify branch mergers under rounding and classify cycles of the resulting finite map. Fourth, a stream-cipher interface could make common-suffix ambiguity part of an explicit security experiment. Fifth, boundary classification would describe the exceptional fibers over $0$ and $1$. Sixth, measure-theoretic analysis could derive the invariant arcsine density and Lyapunov exponent from branch Jacobians.

Together these projects would connect the exact topological-combinatorial tree developed here to probability, numerical computation, and security engineering while preserving the distinctions among them.

## 15. Conclusion

The parameter-four logistic map has an explicit binary inverse geometry. Every interior target admits two separated interior predecessors, each branch is injective, and recursive branch selection converts every $n$-bit word into a distinct depth-$n$ seed. Thus every interior $n$-step fiber contains an explicitly indexed family of $2^n$ points. All of those points reach the target after $n$ updates and share its entire future orbit thereafter.

The result reframes chaotic dynamics through historical ambiguity. Forward sensitivity emphasizes how trajectories separate; the inverse tree shows how a single observed future can be compatible with exponentially many pasts. This exact-real structure is mathematically sharp, algorithmically constructive, and relevant to cryptographic observability—provided it is kept distinct from the separate questions of finite implementation and computational security.

