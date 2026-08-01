# Finite-Test Gröbner Bases for Tropical Polynomial Semimodules

**Aristotle**  
**August 1, 2026**

## Abstract

We develop a finite-test theory of Gröbner bases for polynomial semimodules over a commutative semiring, with the rational min-plus tropical semiring as the principal example. A tropical ideal is modeled as a subsemimodule of a multivariate polynomial semiring. After fixing a monomial order, leading exponents are defined as maximal support exponents, and leading reducibility is expressed by componentwise divisibility of exponent vectors. For a finite test set $U$, a family $G$ is a Gröbner basis on $U$ when $G\subseteq I\cap U$ and every nonzero element of $I\cap U$ has a leading monomial divisible by a leading monomial of a member of $G$. We prove that this condition is equivalent to the absence of an obstruction, establish the invariants of a Buchberger-style completion step, and show that completion reaches a Gröbner basis on $U$ in at most $|U|$ iterations. We further characterize completed bases as exactly the fixed points of the completion operator. The theory requires no subtraction, coefficient division, global ideal-membership procedure, or infinite termination principle. It therefore isolates a robust finite core suitable for degree truncations, bounded-support computations, and finite tropical models.

## 1. Introduction

Tropical mathematics replaces familiar arithmetic with idempotent operations. In the min-plus convention,

$$
a\oplus b=\min(a,b),\qquad a\odot b=a+b.
$$

Optimization and geometry meet in this arithmetic: sums select optimal alternatives, products concatenate costs, and polynomial functions become piecewise linear. Tropical polynomials and their vanishing loci have become central objects in combinatorial algebraic geometry, while semiring methods also appear in shortest-path problems, scheduling, automata, and discrete-event systems.

Gröbner bases are among the most useful organizing devices in ordinary polynomial algebra. A Gröbner basis controls an ideal through leading monomials, replacing potentially complicated polynomial relations with divisibility in a monoid of exponents. Transferring this perspective to tropical algebra is subtle. Semirings need not have subtraction, ordinary cancellation-based reduction may fail, and an arbitrary ideal may not come with a decidable membership test.

This paper isolates a setting in which a complete Buchberger-style conclusion follows from finite combinatorics alone. We fix a finite test set $U$ of polynomials. Rather than asserting global control over every member of an infinite ideal, we ask whether a finite family controls the leading monomials of all nonzero ideal members in $U$. This yields a relative, finite-test Gröbner condition.

The resulting completion process is direct. Starting from valid tested ideal members, adjoin any tested ideal element whose leading monomial is not yet covered by divisibility. Each genuine step adds a new element, while all iterates remain subsets of $U$. Consequently the process stabilizes in at most $|U|$ iterations. At stabilization, the family satisfies the finite-test Gröbner condition; conversely, every finite-test Gröbner basis is already stable.

The contribution is not a claim that exhaustive finite testing replaces global tropical Gröbner theory. Rather, it provides a precise foundational layer:

- it works over an arbitrary commutative coefficient semiring;
- it needs only finite supports and a monomial order;
- it separates leading-monomial coverage from coefficient-level reduction;
- it gives an unconditional finite completion theorem;
- it identifies Gröbner completeness with absence of obstructions and with a fixed-point condition.

These features make the framework appropriate for degree-bounded calculations, finite candidate sets, computational experiments, and future attempts to derive finite global criteria from structural hypotheses.

## 2. Algebraic setting

### 2.1. Commutative semirings and the tropical example

A **commutative semiring** $K$ consists of two commutative operations, addition and multiplication, with neutral elements $0$ and $1$, such that multiplication distributes over addition and $0$ is absorbing for multiplication. Additive inverses are not required.

The motivating coefficient system is the rational min-plus tropical semiring. Its underlying set is $\mathbb{Q}\cup\{+\infty\}$, and its operations are

$$
a\oplus b=\min(a,b),\qquad a\odot b=a+b,
$$

with the expected conventions involving $+\infty$. Here $+\infty$ is the tropical zero and ordinary $0$ is the tropical multiplicative unit. Addition is idempotent because $a\oplus a=a$.

The main results below depend only on the commutative-semiring axioms. Their intended interpretation, however, is tropical: coefficients represent weights, tropical addition compares alternatives, and tropical multiplication accumulates weights.

### 2.2. Multivariate polynomials

Let $\Sigma$ be a set indexing variables. An **exponent vector** is a finitely supported function

$$
\alpha:\Sigma\longrightarrow\mathbb{N}.
$$

The associated monomial is denoted $x^\alpha$. A polynomial over $K$ is a finite semiring sum

$$
p=\bigoplus_{\alpha} c_\alpha\odot x^\alpha.
$$

The **support** of $p$, written $\operatorname{supp}(p)$, is the finite set of exponents $\alpha$ for which $c_\alpha$ is nonzero. A polynomial is nonzero exactly when its support is nonempty.

### 2.3. Tropical ideals as polynomial subsemimodules

A **tropical ideal** for the purposes of this paper is a $K$-subsemimodule $I$ of the polynomial semiring $K[x_\sigma\mid\sigma\in\Sigma]$. Thus:

1. $0\in I$;
2. if $p,q\in I$, then $p\oplus q\in I$;
3. if $a\in K$ and $p\in I$, then $a\odot p\in I$.

This definition emphasizes tropical linear closure. It should not be confused with stronger notions of tropical ideal that impose additional elimination axioms. Every result in this paper concerns the subsemimodule notion just stated.

For a set $S$ of polynomials, define its **generated tropical ideal** $\langle S\rangle$ as the intersection of all tropical ideals containing $S$, equivalently the subsemimodule spanned by $S$.

**Proposition 2.1 (Closure).** If $p,q\in I$, then $p\oplus q\in I$. If $a\in K$ and $p\in I$, then $a\odot p\in I$.

**Proof sketch.** These are exactly the additive and scalar closure axioms of a subsemimodule. No additive inverses are used. $\square$

**Proposition 2.2 (Universal property of generation).** For every set $S$ of polynomials and every tropical ideal $I$,

$$
\langle S\rangle\subseteq I\quad\Longleftrightarrow\quad S\subseteq I.
$$

**Proof sketch.** If the generated ideal is contained in $I$, then so is $S$. Conversely, if $S\subseteq I$, closure of $I$ under finite tropical linear combinations forces every element of $\langle S\rangle$ to belong to $I$. $\square$

## 3. Leading exponents and divisibility

### 3.1. Monomial orders

A **monomial order** $\preceq$ is a total order on finitely supported exponent vectors that is compatible with addition: if $a\preceq b$, then $a+c\preceq b+c$. Standard lexicographic, graded lexicographic, and graded reverse lexicographic orders fit this paradigm when the variable set is appropriately ordered.

An exponent $e$ is a **leading exponent** of a polynomial $p$ if

$$
e\in\operatorname{supp}(p)
$$

and

$$
d\preceq e\qquad\text{for every }d\in\operatorname{supp}(p).
$$

This relational definition focuses on the exponent and does not require selecting or normalizing a leading coefficient.

**Theorem 3.1 (Existence of leading exponents).** Every nonzero polynomial has a leading exponent with respect to every monomial order.

**Proof sketch.** A nonzero polynomial has finite nonempty support. A total order restricted to a finite nonempty set has a maximal element. That maximal support exponent satisfies the definition. $\square$

### 3.2. Monomial divisibility

For exponent vectors $a$ and $b$, define

$$
a\mid b\quad\Longleftrightarrow\quad a_\sigma\le b_\sigma
\text{ for every }\sigma\in\Sigma.
$$

This is equivalent to ordinary divisibility of formal monomials: $x^a$ divides $x^b$ exactly when $b=a+c$ for some exponent vector $c$.

Let $G$ be a finite family of polynomials. A polynomial $p$ is **leading-reducible by $G$** if there exist $g\in G$, a leading exponent $e_g$ of $g$, and a leading exponent $e_p$ of $p$ such that

$$
e_g\mid e_p.
$$

The terminology “leading-reducible” records a divisibility certificate. It does not assert that a subtraction-based polynomial remainder operation exists.

**Lemma 3.2 (Self-reducibility).** If $p\ne0$ and $p\in G$, then $p$ is leading-reducible by $G$.

**Proof sketch.** By Theorem 3.1, choose a leading exponent $e$ of $p$. Use $p$ itself as the family member. Since $e\mid e$ by reflexivity of componentwise order, the required certificate exists. $\square$

This elementary lemma is the key to proving strict growth of the completion process.

## 4. Finite-test Gröbner bases

### 4.1. Definition

Fix a monomial order $\preceq$, a tropical ideal $I$, a finite test set $U$, and a finite family $G$. We say that $G$ is a **Gröbner basis for $I$ on $U$** when:

1. $G\subseteq U$;
2. $G\subseteq I$;
3. every nonzero $p\in I\cap U$ is leading-reducible by $G$.

The qualifier “on $U$” is essential. The definition certifies initial-monomial coverage only for the specified finite universe. It is useful whenever $U$ has an independent computational or mathematical meaning, for example:

- all enumerated ideal members of degree at most $D$;
- candidates with support in a bounded lattice polytope;
- relations generated by a finite state-space exploration;
- a finite benchmark set used to compare monomial orders.

### 4.2. Obstructions

Given $I$, $U$, and $G$, an **obstruction** is a polynomial $p$ satisfying

$$
p\in U,
\qquad p\in I,
\qquad p\ne0,
\qquad p\text{ is not leading-reducible by }G.
$$

Thus an obstruction is precisely an uncovered nonzero tested ideal element.

**Theorem 4.1 (Obstruction characterization).** Assume $G\subseteq U$ and $G\subseteq I$. Then $G$ is a Gröbner basis for $I$ on $U$ if and only if no obstruction exists.

**Proof sketch.** If $G$ is a Gröbner basis on $U$, condition 3 makes the final clause in the definition of obstruction impossible. Conversely, suppose no obstruction exists. For any nonzero $p\in I\cap U$, failure of leading reducibility would make $p$ an obstruction. Therefore every such $p$ is leading-reducible, and the two assumed containment conditions complete the Gröbner-basis definition. $\square$

The theorem converts the universal coverage condition into an emptiness test for a finite search space.

## 5. The finite completion operator

### 5.1. One step

Define the **completion step** $B_{I,U}(G)$ as follows:

- if an obstruction to $G$ exists in $U$, choose one obstruction $p$ and set

$$
B_{I,U}(G)=G\cup\{p\};
$$

- if no obstruction exists, set

$$
B_{I,U}(G)=G.
$$

A deterministic implementation may choose the first obstruction according to a fixed enumeration of $U$. The mathematical conclusions do not depend on which obstruction is selected.

Define the iterates recursively by

$$
G_0=G,
\qquad
G_{n+1}=B_{I,U}(G_n).
$$

### 5.2. Structural invariants

**Lemma 5.1 (Monotonicity).** For every $G$,

$$
G\subseteq B_{I,U}(G).
$$

**Proof sketch.** The step either leaves $G$ unchanged or forms its union with a singleton. $\square$

**Lemma 5.2 (Preservation of the universe).** If $G\subseteq U$, then

$$
B_{I,U}(G)\subseteq U.
$$

**Proof sketch.** In the nontrivial case, the adjoined obstruction belongs to $U$ by definition. In the other case the family is unchanged. $\square$

**Lemma 5.3 (Preservation of ideal membership).** If $G\subseteq I$, then

$$
B_{I,U}(G)\subseteq I.
$$

**Proof sketch.** Every old member remains in $I$, and any adjoined obstruction belongs to $I$ by definition. $\square$

By induction, if $G_0\subseteq I\cap U$, then every iterate $G_n$ remains a subset of $I\cap U$.

**Lemma 5.4 (Strict growth in the presence of an obstruction).** If an obstruction exists, then

$$
|G|<|B_{I,U}(G)|.
$$

**Proof sketch.** Let $p$ be the chosen obstruction. If $p$ were already in $G$, then $p\ne0$ and Lemma 3.2 would show that $p$ is leading-reducible by $G$, contradicting obstructionhood. Hence $p\notin G$, so adjoining $p$ increases cardinality by one. $\square$

This lemma contains the central combinatorial insight: an unresolved element can never be a duplicate of an existing basis member.

## 6. Finite Tropical Buchberger Theorem

**Theorem 6.1 (Finite Tropical Buchberger Theorem).** Let $I$ be a tropical ideal, let $U$ be a finite test set, and let $G_0$ be a finite family satisfying

$$
G_0\subseteq U
\qquad\text{and}\qquad
G_0\subseteq I.
$$

Then there exists an integer $n$ with

$$
0\le n\le |U|
$$

such that the iterate $G_n$ is a Gröbner basis for $I$ on $U$.

**Proof sketch.** Lemmas 5.2 and 5.3 imply inductively that each $G_n$ lies in $I\cap U$. Suppose, for contradiction, that no $G_n$ with $n\le|U|$ is a Gröbner basis on $U$. By Theorem 4.1, every such $G_n$ has an obstruction. Lemma 5.4 then gives

$$
|G_0|<|G_1|<\cdots<|G_{|U|+1}|.
$$

In particular, even using only the weak lower bound $|G_0|\ge0$, repeated strict growth implies

$$
|G_{|U|+1}|\ge |U|+1.
$$

But $G_{|U|+1}\subseteq U$, so

$$
|G_{|U|+1}|\le |U|,
$$

which is impossible. Therefore some iterate with index at most $|U|$ is a Gröbner basis on $U$. $\square$

**Remark 6.2 (Sharper counting bound).** Because each nontrivial step adds exactly one new member and no member is removed, at most $|U|-|G_0|$ nontrivial additions are possible. The theorem states the uniform bound $|U|$, which requires no separate cardinality bookkeeping in its conclusion.

**Remark 6.3 (Nature of the algorithm).** The theorem presumes that obstructions in the finite set can be identified. It does not provide a global decision procedure for membership in an arbitrary ideal. In applications, membership data may be supplied by construction, by a separate certificate, or by choosing $U\subseteq I$ from the outset.

## 7. Fixed-point characterization

**Theorem 7.1 (Gröbner bases are fixed points).** If $G$ is a Gröbner basis for $I$ on $U$, then

$$
B_{I,U}(G)=G.
$$

**Proof sketch.** Theorem 4.1 says that no obstruction exists. The completion operator therefore takes its unchanged branch. $\square$

**Theorem 7.2 (Fixed points are Gröbner bases).** Assume $G\subseteq U$ and $G\subseteq I$. If

$$
B_{I,U}(G)=G,
$$

then $G$ is a Gröbner basis for $I$ on $U$.

**Proof sketch.** If $G$ were not a Gröbner basis, Theorem 4.1 would supply an obstruction $p$. By Lemma 5.4, adjoining the chosen obstruction would strictly increase cardinality, contradicting $B_{I,U}(G)=G$. Hence no obstruction exists, and Theorem 4.1 gives the result. $\square$

Combining the two directions yields the algorithmic characterization.

**Corollary 7.3 (Fixed-point criterion).** Under the validity assumptions $G\subseteq I\cap U$,

$$
G\text{ is a Gröbner basis for }I\text{ on }U
\quad\Longleftrightarrow\quad
B_{I,U}(G)=G.
$$

Thus finite-test Gröbner bases are exactly the equilibria of obstruction completion.

## 8. Algorithms and complexity

Assume $U=(p_1,\dots,p_N)$ is explicitly enumerated, membership in $I$ is available as a Boolean predicate, and a leading exponent can be computed for each nonzero polynomial. Store the current family by indices into $U$.

### 8.1. Coverage test

For each tested polynomial $p\in U\cap I$, compute its leading exponent $e_p$. It is covered by $G$ if some $g\in G$ has leading exponent $e_g$ satisfying $e_g\le e_p$ componentwise.

If exponent vectors have $d$ coordinates, one divisibility test takes $O(d)$ comparisons. A direct scan costs $O(N|G|d)$ per completion stage, excluding polynomial parsing and ideal-membership costs.

### 8.2. Completion algorithm

**Algorithm: Finite obstruction completion**

1. Verify that every initial member belongs to $U\cap I$.
2. Scan $U$ in a fixed order.
3. Ignore zero polynomials and polynomials outside $I$.
4. For each remaining polynomial, test whether a selected leading exponent is componentwise divisible by a selected leading exponent from $G$.
5. On finding the first uncovered polynomial, add it to $G$ and restart the scan.
6. If a complete scan finds no obstruction, return $G$.

At most $N-|G_0|$ additions occur. With naive rescanning and $|G|\le N$, a coarse worst-case bound for divisibility work is $O(N^3d)$. Precomputing all leading exponents and the $N\times N$ divisibility matrix reduces each coverage query to table lookup; the matrix costs $O(N^2d)$ to build, and naive completion then uses at most $O(N^3)$ Boolean checks. Bitsets or maintaining an incrementally updated covered set can reduce the postcomputation phase to roughly $O(N^2/w)$ machine-word operations, where $w$ is the word size.

The abstract theorem permits any choice of obstruction. Selection heuristics may improve the resulting basis: one may prefer smaller total degree, smaller support, or a leading exponent minimal under divisibility.

### 8.3. Redundancy removal

After completion, a basis member $g$ may be redundant at the level of leading coverage if another member $h$ has a leading exponent dividing that of $g$. Removing $g$ preserves coverage of every exponent previously covered through $g$, because divisibility is transitive. Care is needed if multiple leading exponents are possible under a non-antisymmetric presentation, but for a total monomial order the maximal exponent is unique.

This minimization is optional: completion proves correctness without it.

## 9. Worked example

Consider two variables and a finite test universe whose nonzero ideal members have leading exponent vectors

$$
u_1=(2,0),\quad
u_2=(1,1),\quad
u_3=(0,3),\quad
u_4=(3,1),\quad
u_5=(2,2).
$$

Suppose the initial family contains only a polynomial led by $\nu_1$. Since divisibility is componentwise, $\nu_1$ divides $\nu_4$ and $\nu_5$, but divides neither $\nu_2$ nor $\nu_3$. Thus the second and third candidates are obstructions.

Choose the polynomial led by $\nu_2$. The selected leaders are now $(2,0)$ and $(1,1)$. The latter divides $(2,2)$ and $(3,1)$ but still does not divide $(0,3)$. Hence the polynomial led by $\nu_3$ remains an obstruction and is added next.

The resulting family has leading exponents

$$
(2,0),\quad(1,1),\quad(0,3).
$$

Every tested leading exponent is divisible by at least one of these. The family is therefore a Gröbner basis on this test universe, and another completion step changes nothing.

The exponent-lattice interpretation is useful. A leader $a$ covers the upward orthant

$$
\{b\in\mathbb{N}^2:a\le b\}.
$$

Completion adds uncovered tested points until the union of selected orthants covers all relevant points. The algebraic termination theorem becomes the elementary fact that one cannot add distinct points from a finite set forever.

## 10. Applications and scope

### 10.1. Degree-truncated exploration

Fix a degree bound $D$ and enumerate a finite family of relevant polynomials whose monomials have total degree at most $D$. Completion produces a basis certificate relative to that enumeration. Such calculations can reveal stabilization patterns and motivate a conjectural global degree bound.

### 10.2. Bounded-support tropical models

In optimization or discrete-event systems, only finitely many support patterns may be physically meaningful. Taking these patterns as $U$ yields a basis tailored to the model rather than to the entire infinite polynomial semiring.

### 10.3. Initial-semimodule coverage

The set of leading exponents selected from $G$ generates an upward-closed region under componentwise divisibility. The Gröbner condition says that this region contains every leading exponent represented by a nonzero polynomial of $I\cap U$. This gives a finite approximation to an initial monomial semimodule.

### 10.4. Certification and reproducibility

A completed family provides a compact certificate for a finite dataset: list each tested polynomial’s chosen leader and the basis leader dividing it. Verification then reduces to membership assertions and coordinatewise inequalities.

### 10.5. Limits of the result

The finite theorem does not establish a global tropical division algorithm, an S-pair criterion, uniqueness of reduced bases, or finite generation of the full initial semimodule. It also uses “tropical ideal” in the subsemimodule sense, not in every stronger sense found in tropical geometry. These boundaries are mathematically important. The result should be read as an exact finite completion theorem, not as an unconditional global Buchberger theorem for all tropical ideals.

## 11. Discussion

Three design choices make the theory robust.

First, leading terms are handled relationally through maximal support exponents. This avoids coefficient normalization and works naturally without division.

Second, reducibility is restricted to leading-monomial divisibility. The termination proof therefore depends only on finite supports, componentwise order, and set cardinality.

Third, the test universe is explicit. Global algebraic difficulties are not hidden; they are separated from the finite combinatorial core. If future structure theorems show that some finite $U$ controls all degrees, the present completion theorem can serve as the terminal algorithmic step.

The fixed-point viewpoint also suggests broader interpretations. The completion operator is inflationary on the finite poset of subsets of $U$. Its valid fixed points are exactly the families with full tested coverage. Although the operator’s chosen obstruction may depend on a selection rule, every trajectory from a valid initial family reaches some fixed point because strict growth cannot continue indefinitely.

Different choices can yield different completed families. A canonical basis would require a canonical selection rule and likely a reduction or minimization phase. Nevertheless, all outputs satisfy the same coverage specification on $U$.

## 12. Future directions

Several questions would extend finite-test coverage toward global tropical scheme theory.

1. **Degree-truncated stabilization.** For a finitely generated homogeneous tropical ideal over the rational min-plus semiring in finitely many variables, determine whether there is a degree $D$ such that being a Gröbner basis on every polynomial of degree at most $D$ implies being a Gröbner basis in every degree.

2. **Finite universal obstruction sets.** Determine whether every finitely generated tropical ideal and monomial order admit a finite test set whose finite-test Gröbner condition is equivalent to leading-monomial divisibility for every nonzero ideal member.

3. **Order independence of tropical Hilbert data.** For a homogeneous tropical ideal, investigate whether the number of degree-$d$ monomials outside the initial monomial semimodule is independent of the monomial order.

4. **Finite tropical S-pair criteria.** Construct tropical critical pairs and determine whether checking their reduction suffices for Gröbner completeness on divisor-closed finite test sets.

5. **Bend congruence recovery.** Determine whether the bend congruence generated by a tropical Gröbner basis agrees with that generated by the entire finitely generated ideal.

## 13. Conclusion

A finite universe permits a complete and transparent tropical Gröbner theory. Every nonzero polynomial has a leading exponent; every nonzero family member covers itself; unresolved tested ideal elements are exactly the obstructions to the Gröbner condition. Adjoining an obstruction preserves validity and strictly enlarges the current family. Since all iterates remain inside the finite test set, completion reaches a Gröbner basis in at most the size of that set. Finally, validity plus invariance under one completion step characterizes the completed families exactly.

The result provides a dependable finite core for tropical Gröbner computation. Its proof uses no subtraction and no global finiteness hypothesis beyond the explicit test set. The next challenge is to identify structural conditions under which finite tests control infinite tropical ideals.
