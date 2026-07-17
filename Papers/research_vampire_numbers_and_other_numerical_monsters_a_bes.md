# The Unit Curve of Vampire Factorizations: Digit Multisets, Modular Sieves, and Prime Fangs

**Aristotle**  
**17 July 2026**

## Abstract

A base-$b$ fang pair consists of positive integers $x$ and $y$ for which the base-$b$ digits of $xy$, counted with multiplicity, are exactly the combined digits of $x$ and $y$. This condition captures the central digit-permutation feature of vampire factorizations while remaining independent of auxiliary conventions about length or terminal zeros. We show that every such pair satisfies

$$
xy\equiv x+y\pmod{b-1},
$$

and hence lies on the modular unit curve

$$
(x-1)(y-1)\equiv1\pmod{b-1}.
$$

It follows that both decremented fangs are units modulo $b-1$ and, for positive fangs, are coprime to $b-1$. Every prime divisor $p$ of $b-1$ therefore forbids either fang from being congruent to $1$ modulo $p$. In decimal, the curve has exactly six ordered residue pairs modulo $9$:

$$
(0,0),(2,2),(3,6),(5,8),(6,3),(8,5).
$$

If both fangs are prime, only $(2,2)$, $(5,8)$, and $(8,5)$ remain, forcing the product to be congruent to $4$ modulo $9$. We give proofs, certified small examples, algorithms for modular filtering and bounded enumeration, and a precise account of what these results do not establish. In particular, proposed density laws, interval-existence claims, and variants involving partial or absent digit overlap require additional definitions and arguments.

## 1. Introduction

A vampire number is commonly described as a composite integer whose decimal digits can be rearranged into two factors, called fangs, whose product is the original number. The canonical example is

$$
1260=21\cdot60.
$$

The digits occurring in $21$ and $60$ are exactly the digits occurring in $1260$, including multiplicity. Other early examples are

$$
1395=15\cdot93,\qquad
1435=35\cdot41,\qquad
1530=30\cdot51,
$$

$$
1827=21\cdot87,\qquad
2187=27\cdot81,\qquad
6880=80\cdot86.
$$

Classical definitions often add requirements: the product has an even number of digits, the fangs have equal length, and the fangs do not both end in zero. Those conventions are appropriate for a taxonomy of standard vampire numbers. The present study asks a more structural question: what follows from exact conservation of the digit multiset alone?

The answer is a modular constraint that holds in every base. A number is congruent to its digit sum modulo one less than the base. When the digits of a product are precisely the combined digits of its factors, this familiar observation gives $xy\equiv x+y$. Completing the product after subtracting $1$ from each fang yields $(x-1)(y-1)\equiv1$. Thus the decremented fangs are mutual inverses modulo $b-1$.

This simple transformation has several uses. It supplies a necessary condition that is much cheaper to test than digit matching. It decomposes into simultaneous obstructions modulo every prime factor of $b-1$. It completely enumerates the possible decimal residue pairs. Under primality assumptions, it gives a still sharper product congruence. Conceptually, it translates a permutation problem into the arithmetic of units in a finite ring.

The paper is organized as follows. Section 2 gives precise definitions and separates the core notion from conventional vampire-number restrictions. Section 3 establishes the digit-sum congruence. Section 4 derives the unit curve and its coprimality consequences. Section 5 specializes to decimal arithmetic and Section 6 treats prime fangs. Section 7 verifies representative examples. Section 8 describes algorithms and complexity. Sections 9 and 10 discuss applications, limitations, and future research.

## 2. Definitions and scope

### 2.1 Base expansions and digit multisets

Fix an integer base $b\ge2$. Every nonnegative integer $n$ has a base-$b$ expansion

$$
n=\sum_{i=0}^{r}d_i b^i,
$$

where $0\le d_i<b$, and where the leading digit $d_r$ is nonzero when $n>0$. The **base-$b$ digit multiset** of $n$ records each digit value together with its multiplicity. Equivalently, it is represented by the frequency vector

$$
C_b(n)=(c_0,c_1,\ldots,c_{b-1}),
$$

where $c_j$ is the number of occurrences of digit $j$ in the standard base-$b$ expansion of $n$.

For multisets, union means addition of multiplicities. Thus

$$
C_b(x) + C_b(y)
$$

is the frequency vector obtained by concatenating the digit strings of $x$ and $y$ and forgetting order.

### 2.2 Fang pairs

**Definition 2.1 (base-$b$ fang pair).** Positive integers $x$ and $y$ form a base-$b$ fang pair if

$$
C_b(xy)=C_b(x)+C_b(y).
$$

The product $v=xy$ will be called the associated product. The definition is ordered when residue pairs are discussed: $(x,y)$ and $(y,x)$ occupy transposed points, although they determine the same multiplication.

This definition requires exact equality of digit multiplicities. It does not merely require that the same distinct digit values appear. Nor does it impose equal lengths. Consequently it isolates the hypothesis needed for all results below.

**Definition 2.2 (classical decimal vampire number).** A common classical convention calls $v$ a decimal vampire number when $v=xy$, the pair $(x,y)$ is a base-$10$ fang pair, $v$ has an even number of decimal digits, $x$ and $y$ each have half as many digits as $v$, and $x$ and $y$ do not both end in zero.

Every factorization satisfying Definition 2.2 satisfies Definition 2.1 and therefore inherits all theorems in this paper. The converse need not hold because Definition 2.1 intentionally omits the length and terminal-zero clauses.

### 2.3 Units and congruence

For a positive modulus $m$, an integer $u$ is a **unit modulo $m$** if there exists $v$ such that $uv\equiv1\pmod m$. This is equivalent to $\gcd(u,m)=1$. The invertible residue classes form the group $(\mathbb Z/m\mathbb Z)^\times$.

The phrase **unit curve** will refer to the set of residue pairs satisfying

$$
(X-1)(Y-1)\equiv1\pmod m.
$$

Translation by $1$ in each coordinate identifies this set with pairs $(u,u^{-1})$ of mutually inverse units.

## 3. The digit-sum mechanism

Define the base-$b$ digit sum of $n$ by

$$
s_b(n)=\sum_{i=0}^{r}d_i.
$$

The fundamental congruence is standard but is included to make the argument self-contained.

**Lemma 3.1 (digit-sum congruence).** For every base $b\ge2$ and every nonnegative integer $n$,

$$
n\equiv s_b(n)\pmod{b-1}.
$$

**Proof sketch.** Since $b\equiv1\pmod{b-1}$, every power $b^i$ is congruent to $1$. Therefore

$$
n=\sum_i d_i b^i\equiv\sum_i d_i=s_b(n)\pmod{b-1}.
$$

This argument also covers $b=2$, for which the modulus is $1$ and all integers are congruent. $\square$

Exact multiset equality preserves not only the number of digits but also their sum.

**Lemma 3.2 (additivity under fang permutation).** If $(x,y)$ is a base-$b$ fang pair, then

$$
s_b(xy)=s_b(x)+s_b(y).
$$

**Proof sketch.** By definition, each digit occurs in $xy$ as many times as it occurs across $x$ and $y$ together. Weighting the multiplicity of digit $j$ by $j$ and summing over $0\le j<b$ gives the identity. $\square$

Combining the two lemmas yields the first modular form of the fang condition.

**Theorem 3.3 (additive fang congruence).** Let $b\ge2$. If $(x,y)$ is a base-$b$ fang pair, then

$$
xy\equiv x+y\pmod{b-1}.
$$

**Proof sketch.** Apply Lemma 3.1 to $xy$, then Lemma 3.2, and then Lemma 3.1 separately to $x$ and $y$:

$$
xy\equiv s_b(xy)=s_b(x)+s_b(y)\equiv x+y\pmod{b-1}.
$$

$\square$

No length condition or primality assumption enters this proof. The only substantive input is exact equality of digit multisets.

## 4. The modular unit curve

**Theorem 4.1 (Unit-Curve Theorem).** Let $b\ge2$, and let $(x,y)$ be a base-$b$ fang pair. Then

$$
(x-1)(y-1)\equiv1\pmod{b-1}.
$$

Moreover, $x-1$ and $y-1$ are mutually inverse units modulo $b-1$.

**Proof sketch.** By Theorem 3.3,

$$
xy-x-y\equiv0\pmod{b-1}.
$$

Adding $1$ and factoring gives

$$
xy-x-y+1=(x-1)(y-1)\equiv1\pmod{b-1}.
$$

Thus the residue of $y-1$ is an inverse of the residue of $x-1$, and conversely. $\square$

The theorem turns a global digit-permutation condition into a local algebraic test. Its immediate integer form is coprimality.

**Corollary 4.2 (coprimality of decremented fangs).** Under the hypotheses of Theorem 4.1,

$$
\gcd(x-1,b-1)=1
\quad\text{and}\quad
\gcd(y-1,b-1)=1.
$$

**Proof sketch.** An integer has an inverse modulo $m$ if and only if it is coprime to $m$. Theorem 4.1 supplies the inverses explicitly. $\square$

Each prime divisor of the casting-out modulus now gives a forbidden residue.

**Corollary 4.3 (prime-divisor obstruction).** Let $p$ be prime and suppose $p\mid b-1$. For every base-$b$ fang pair $(x,y)$,

$$
x\not\equiv1\pmod p
\quad\text{and}\quad
y\not\equiv1\pmod p.
$$

**Proof sketch.** If $x\equiv1\pmod p$, then $p\mid x-1$. Since $p\mid b-1$, this contradicts $\gcd(x-1,b-1)=1$. The argument for $y$ is identical. $\square$

This obstruction is simultaneous across all prime divisors of $b-1$. For example, in base $16$ the modulus is $15$, so neither fang may be congruent to $1$ modulo $3$ or modulo $5$.

**Proposition 4.4 (cardinality of the abstract unit curve).** For every positive modulus $m$, the ordered solutions to

$$
(X-1)(Y-1)\equiv1\pmod m
$$

are in bijection with the units modulo $m$. Consequently there are exactly $\varphi(m)$ ordered solutions, where $\varphi$ is Euler’s totient function.

**Proof sketch.** Send a solution $(X,Y)$ to $u=X-1$. The equation shows that $u$ is a unit and that $Y-1=u^{-1}$. Conversely, each unit $u$ produces the unique solution $(u+1,u^{-1}+1)$. The constructions are inverse. $\square$

Proposition 4.4 describes the modular curve itself. Fang pairs form a subset of these points because the curve condition is necessary but not sufficient for digit-multiset equality.

## 5. Complete decimal residue classification

For decimal notation, $b-1=9$. The six units modulo $9$ are

$$
1,2,4,5,7,8.
$$

Their inverses are respectively

$$
1,5,7,2,4,8.
$$

Adding $1$ to each coordinate gives a complete list.

**Theorem 5.1 (Decimal Residue Sieve).** If $(x,y)$ is a decimal fang pair, then

$$
(x\bmod9,y\bmod9)
$$

is exactly one of

$$
(0,0),\ (2,2),\ (3,6),\ (5,8),\ (6,3),\ (8,5).
$$

**Proof sketch.** Set $u=x-1$ and $v=y-1$ modulo $9$. Theorem 4.1 gives $uv=1$, so $u$ must be one of the six units and $v$ its inverse. Enumerating these six possibilities and translating back yields the stated pairs. $\square$

**Corollary 5.2 (decimal obstruction modulo $3$).** Neither fang in a decimal fang pair is congruent to $1$ modulo $3$.

**Proof sketch.** Apply Corollary 4.3 with $p=3$, since $3\mid9$. Equivalently, inspect the six pairs in Theorem 5.1. $\square$

The sieve is one-way. For example, $(2,2)$ is an allowed pair of residues, but most integers with these residues do not have matching product digits. The theorem should therefore be used for rejection, not as a characterization of fang pairs.

## 6. Prime fangs

Suppose now that both decimal fangs are prime. The six points of Theorem 5.1 collapse to three.

**Theorem 6.1 (Prime-Fang Residue Theorem).** Let $(x,y)$ be a decimal fang pair, and suppose both $x$ and $y$ are prime. Then

$$
(x\bmod9,y\bmod9)\in\{(2,2),(5,8),(8,5)\}.
$$

**Proof sketch.** The pairs $(0,0)$, $(3,6)$, and $(6,3)$ contain residues divisible by $3$ in both coordinates. A prime divisible by $3$ must equal $3$. The exceptional value $3$ cannot complete any of these residue patterns while satisfying the fang unit curve with a second prime: directly, the corresponding other residue remains divisible by $3$, forcing the other prime also to be $3$, but $(3,3)$ has residue pair $(3,3)$ and does not lie on the decimal unit curve. Hence those three points are excluded, leaving exactly the stated alternatives. $\square$

All three surviving pairs give the same product residue.

**Corollary 6.2 (Prime-Fang Product Corollary).** Under the hypotheses of Theorem 6.1,

$$
xy\equiv4\pmod9.
$$

**Proof sketch.** Compute in the three cases:

$$
2\cdot2\equiv4,\qquad
5\cdot8\equiv40\equiv4,\qquad
8\cdot5\equiv40\equiv4\pmod9.
$$

$\square$

This is a strong preliminary test for a proposed decimal factorization into two prime fangs. If the product is not $4$ modulo $9$, the factorization cannot satisfy exact digit conservation.

## 7. Representative decimal certificates

The modular results are universal necessary conditions. Concrete examples illustrate both the original digit criterion and the residue sieve.

**Proposition 7.1 (first seven examples).** Each of the following is a decimal fang factorization:

$$
1260=21\cdot60,
$$

$$
1395=15\cdot93,
$$

$$
1435=35\cdot41,
$$

$$
1530=30\cdot51,
$$

$$
1827=21\cdot87,
$$

$$
2187=27\cdot81,
$$

$$
6880=80\cdot86.
$$

**Proof sketch.** Multiplication gives the displayed products. Sorting the digits on each side gives, respectively,

$$
0126=0126,\quad1359=1359,\quad1345=1345,
$$

$$
0153=0153,\quad1278=1278,\quad1278=1278,\quad0688=0688.
$$

Thus the digit multisets agree in every case. $\square$

Their ordered residue pairs modulo $9$ are

$$
(3,6),(6,3),(8,5),(3,6),(3,6),(0,0),(8,5),
$$

all belonging to the six-point sieve. None of these seven examples has two prime fangs; the prime-fang theorem is a conditional structural result rather than a claim that such examples occur in this list.

## 8. Algorithms

### 8.1 Exact digit-multiset checking

Given $b$, $x$, and $y$, compute the $b$-entry frequency vectors of $x$, $y$, and $xy$. Accept precisely when

$$
C_b(xy)=C_b(x)+C_b(y).
$$

If $L$ is the total number of digits processed, the time complexity is $O(L)$ and the auxiliary space is $O(b)$. For fixed base, the space is constant.

### 8.2 Unit-curve filtering

Before digit extraction, compute

$$
g_x=\gcd(x-1,b-1),\qquad g_y=\gcd(y-1,b-1).
$$

Reject unless both are $1$. Equivalently, check the single congruence

$$
(x-1)(y-1)\equiv1\pmod{b-1}.
$$

Euclid’s algorithm costs logarithmic time in the operands. When generating $y$ after choosing $x$, one may compute the inverse of $x-1$ and restrict $y$ to the unique required class

$$
y\equiv1+(x-1)^{-1}\pmod{b-1}.
$$

### 8.3 Bounded product enumeration

To enumerate fang products $v\le B$, iterate through products or candidate fangs. An elementary product-centered procedure tests each divisor $x\le\sqrt v$, sets $y=v/x$, applies the modular sieve, and then compares digit vectors. Trial division leads to worst-case work on the order of

$$
\sum_{v\le B}O(\sqrt v\log_b v)=O(B^{3/2}\log B).
$$

This can be improved by sieving factor pairs or iterating fang ranges directly. The modular filter does not alter the elementary worst-case exponent but substantially lowers the constant by rejecting residue-incompatible pairs before digit work.

The search must explicitly state whether it seeks all core fang pairs or only classical vampire numbers. In the latter case, it must additionally enforce equal fang lengths, even product length, and the trailing-zero exclusion.

### 8.4 Decimal residue-table generation

The decimal unit curve can be generated without hard-coding. Iterate $a,c\in\{0,\ldots,8\}$ and retain those satisfying

$$
(a-1)(c-1)\equiv1\pmod9.
$$

This requires only $81$ constant-time checks and returns exactly six points. In arbitrary base, iterating all $(b-1)^2$ pairs is simple, while iterating only the $\varphi(b-1)$ units and computing inverses is asymptotically cleaner.

## 9. Applications and interpretation

The unit curve provides three complementary forms of leverage.

First, it is a **search sieve**. Exact digit matching is relatively expensive and often follows factor discovery. Modular arithmetic can reject a candidate pair immediately.

Second, it is a **base-sensitive invariant**. Different bases have different casting-out moduli. If $b-1$ has many small prime factors, Corollary 4.3 gives several simultaneous forbidden classes. This suggests comparing the prevalence of fang pairs across bases through the arithmetic of $b-1$.

Third, it is a **bridge between combinatorics and algebra**. The fang condition concerns permutations with multiplicity; the conclusion concerns units and inverses in a finite ring. The mechanism is robust because digit sum is a symmetric statistic: it ignores order but preserves precisely the information needed modulo $b-1$.

Other digit statistics may produce additional congruences. Alternating digit sums, for example, interact with $b+1$ because $b\equiv-1\pmod{b+1}$. However, concatenating and permuting digits destroys positional parity, so such invariants require hypotheses controlling where digits move. The strength of the $b-1$ argument is that it is completely insensitive to position.

## 10. Limitations and future directions

The present theorems do not prove a density law. A proposal that the density of vampire numbers in a family of intervals behaves like $1/\sqrt n$ must specify the intervals and denominator precisely. More importantly, digit permutations, multiplication with carries, and divisor structure are dependent. A count of permutations alone does not count products that actually factor in the required way.

No exhaustive enumeration through $10^8$ is claimed here. The exact checker and modular sieve describe how such a search should be organized, but a bounded table requires a completeness argument showing that every admissible factor pair has been visited.

Variants called werewolf, ghost, or zombie numbers also require sharper definitions. “Exactly one shared digit” may refer either to one distinct digit value or one occurrence, and it may apply to each fang separately or to their combined multiset. “No digits in common” has the same multiplicity and scope questions. A prime-based definition must distinguish two prime fangs from a factorization with one prime and one composite; examples of the latter do not witness the former.

Several concrete research programs follow.

1. **Uniform unit-curve counting.** Use Proposition 4.4 systematically to obtain exactly $\varphi(b-1)$ admissible ordered residue pairs before length and digit restrictions.

2. **Classical conventions.** Add equal fang lengths, even product length, and terminal-zero restrictions, then transfer the unit-curve results unchanged.

3. **Complete bounded enumeration.** Combine divisor generation, the modular sieve, and exact frequency-vector checks, with a proof that no candidate pair below the bound is omitted.

4. **Rigorous upper bounds.** Combine the modular density $\varphi(b-1)/(b-1)^2$ of allowed residue pairs with divisor estimates. Such a bound is only a first step, because digit constraints and multiplication remain correlated.

5. **Forbidden-digit automata.** Once ghost-style overlap is precisely defined, finite automata can track allowable digit strings. Their counts could be combined with divisor bounds to investigate zero-density claims.

6. **Parametric families.** To prove that every interval of a stated form contains a vampire number, one needs an infinite construction with controlled carries and exact digit multiplicities. The unit curve supplies a necessary congruence that any such family must satisfy.

## 11. Further structural observations

The curve also explains a useful symmetry. If $(x,y)$ is allowed modulo $b-1$, then $(y,x)$ is allowed, because inversion pairs are exchanged. Points with equal coordinates correspond to self-inverse units $u$ satisfying $u^2\equiv1\pmod{b-1}$. In decimal, the diagonal points $(0,0)$ and $(2,2)$ arise from the self-inverse units $8$ and $1$ modulo $9$. The remaining four points form two transposed pairs. This geometry can guide both tabulation and visualization.

The modulus should nevertheless be interpreted carefully. When $b=2$, one has $b-1=1$, so the unit-curve congruence imposes no effective restriction. For larger bases, its selectivity depends on the ratio $\varphi(b-1)/(b-1)$. Among all ordered residue pairs modulo $b-1$, exactly $\varphi(b-1)$ lie on the curve, out of $(b-1)^2$ total pairs. The surviving proportion is therefore

$$
\frac{\varphi(b-1)}{(b-1)^2}.
$$

This is the proportion admitted by the modular condition, not the density of fang pairs. Actual fang pairs must also satisfy factorization and exact digit-multiset constraints. The distinction is essential: a strong necessary sieve can be sparse without approximating the frequency of the objects it filters.

Finally, the argument applies unchanged when zeros occur, because zeros contribute nothing to digit sums but remain fully represented in the multiset equality. Thus examples such as $1260=21\cdot60$ and $6880=80\cdot86$ require no exceptional treatment. Leading zeros, however, are not part of standard positional expansions and should not be inserted into a fang merely to manufacture a match.

## 12. Conclusion

Exact digit conservation in a fang factorization forces far more than equality of digit sums. In every base $b\ge2$, it places the decremented fangs on the modular hyperbola

$$
(x-1)(y-1)\equiv1\pmod{b-1}.
$$

The decremented fangs are therefore units, each is coprime to $b-1$, and neither fang can be $1$ modulo any prime divisor of $b-1$. Decimal arithmetic compresses all candidates to six ordered residue pairs modulo $9$. Under prime-fang hypotheses, three pairs remain and the product is necessarily $4$ modulo $9$.

These conclusions are elementary, exact, and broadly reusable. They do not settle the harder distribution questions surrounding vampire numbers, but they identify the correct algebraic skeleton beneath the digit permutation. Any future enumeration, asymptotic estimate, or infinite construction can begin by passing through the unit curve.