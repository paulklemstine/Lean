# Random-Valuation Soundness and Perfect Additive Hiding for Propositional Certification

**Aristotle**  
**July 16, 2026**

## Abstract

We isolate two finite primitives relevant to private certification of mathematical claims: randomized detection of false propositional formulas and information-theoretic hiding of local values. Formulas in $m$ variables are evaluated at uniformly random Boolean valuations. Every non-tautology has a rejecting valuation, so its accepting set has cardinality at most $2^m-1$. Under $k$ independent challenges, its acceptance probability is therefore at most

$$
\left(\frac{2^m-1}{2^m}\right)^k.
$$

This bound is exact for formulas with a unique falsifying valuation and, crucially, is not the commonly suggested bound $2^{-k}$. In parallel, a value $s$ in the finite cyclic group $\mathbb Z/q\mathbb Z$ is hidden as $s+r$, where $r$ is uniform. Translation invariance shows that the resulting distribution is uniform for every $s$; hence any two secrets induce identical verifier views, pointwise and as distributions. These results separate soundness from zero knowledge and identify the obstacle to succinct private theorem certification. Randomly opening raw proof locations cannot yield statement-length-only communication when invalidity may be confined to a vanishing fraction of locations. Efficient amplification requires a robust locally testable encoding, while privacy under multi-location opening requires simulation of the full dependency-closed view. Algorithms, numerical examples, limitations, and research directions are developed explicitly.

## 1. Introduction

A zero-knowledge protocol seeks to convince a verifier that a statement is true without revealing information beyond that truth. Applied to mathematics, this raises a striking possibility: a prover might certify possession of a valid derivation while keeping its strategic content secret. Such a mechanism could separate trust in a theorem from access to its proof, with potential applications to confidential algorithms, proprietary verification, sealed research contests, and controlled disclosure of security arguments.

A tempting protocol is easy to describe. Commit to every line of a derivation, let the verifier request a random line, open it, and repeat. Two intuitions then arise: random checks should make cheating exponentially unlikely, and commitments should conceal unopened lines. Neither intuition is sufficient as stated.

The first issue is quantitative. If an invalid object has only one bad location among $N$ locations, one uniform query catches it with probability merely $1/N$. After $k$ independent tests, the escape probability is $(1-1/N)^k$, not $2^{-k}$. Exponential decay in $k$ does not imply efficiency when the base approaches one with instance size.

The second issue is conceptual. Soundness and zero knowledge are distinct properties. A test can be sound while exposing sensitive data, and a hiding mechanism can conceal a value without establishing that the hidden object is valid. Moreover, hiding each coordinate separately does not necessarily hide a correlated collection of coordinates opened to verify a local constraint.

This paper studies a fully finite model in which both points can be made exactly. Propositional formulas are sampled through their truth tables, yielding a sharp geometric soundness law. Local proof values are masked in a finite additive group, yielding perfect hiding through translation invariance. The results are elementary enough to admit transparent proofs, yet strong enough to identify the missing ingredient in the proposed theorem-certification architecture: robust local inconsistency.

The contributions are:

1. a witness theorem showing that every failure of tautologicity has a concrete rejecting valuation;
2. an exact upper bound of $2^m-1$ on accepting valuations of a non-tautology in $m$ variables;
3. a $k$-round soundness bound of $(1-2^{-m})^k$, with a sharpness example;
4. an exact simulator for additive masking over $\mathbb Z/q\mathbb Z$;
5. distributional and pointwise perfect-hiding theorems; and
6. a separation analysis explaining why these primitives do not by themselves imply succinct zero-knowledge certification of arbitrary mathematical derivations.

## 2. Propositional formulas and truth-table challenges

### 2.1 Syntax

Fix a natural number $m$. Let the variables be indexed by

$$
\{0,1,\ldots,m-1\}.
$$

A **formula in $m$ variables** is generated recursively by three constructors:

1. each indexed variable is a formula;
2. the constant falsity $\bot$ is a formula; and
3. if $p$ and $q$ are formulas, then $p\to q$ is a formula.

Falsity and implication form a complete propositional basis. For example, negation may be defined by $\neg p := p\to\bot$, and the other standard connectives can then be derived. Restricting the syntax therefore loses no propositional expressive power.

### 2.2 Valuations and evaluation

A **Boolean valuation** is a function

$$
v:\{0,1,\ldots,m-1\}\longrightarrow\{0,1\},
$$

where $0$ denotes false and $1$ denotes true. Evaluation is recursive:

$$
\llbracket x_i\rrbracket_v=v(i),\qquad
\llbracket\bot\rrbracket_v=0,
$$

and

$$
\llbracket p\to q\rrbracket_v
=\neg\llbracket p\rrbracket_v\lor\llbracket q\rrbracket_v.
$$

There are exactly $2^m$ valuations because each of the $m$ variables has two independent choices.

A formula $p$ is a **tautology** if

$$
\llbracket p\rrbracket_v=1
$$

for every Boolean valuation $v$. Let

$$
A(p)=\{v:\llbracket p\rrbracket_v=1\}
$$

be its accepting set, and write $a(p)=|A(p)|$.

### 2.3 The randomized verifier

The one-round truth-table verifier samples a valuation uniformly from the $2^m$ possibilities and accepts precisely when the formula evaluates to true. Its acceptance probability is

$$
\Pr[\text{accept }p]=\frac{a(p)}{2^m}.
$$

The verifier has perfect completeness: if $p$ is a tautology, every valuation accepts and the probability is $1$. Soundness concerns non-tautologies.

## 3. Soundness from a rejecting valuation

### Lemma 1 (Rejecting-witness lemma)

If a formula $p$ is not a tautology, then there exists a valuation $v_0$ such that

$$
\llbracket p\rrbracket_{v_0}=0.
$$

**Proof sketch.** By definition, tautologicity says that every valuation evaluates to true. Negating this universal statement gives a valuation for which evaluation is not true. Since evaluation is Boolean, the remaining value is false. $\square$

This logical witness yields the exact finite counting bound.

### Theorem 2 (Accepting-set bound)

If $p$ is a non-tautology in $m$ variables, then

$$
a(p)\le 2^m-1.
$$

**Proof sketch.** Choose a rejecting valuation $v_0$ using Lemma 1. The accepting set $A(p)$ is contained in the set of all valuations with $v_0$ removed. The latter set has cardinality $2^m-1$, proving the claim. $\square$

### Corollary 3 (One-round soundness)

A non-tautology in $m$ variables is accepted by one uniform truth-table challenge with probability at most

$$
\frac{2^m-1}{2^m}=1-2^{-m}.
$$

The conclusion follows by dividing the cardinality inequality in Theorem 2 by $2^m$.

### 3.1 Independent repetition

Now choose $k$ valuations independently and accept only if all $k$ evaluations are true. For any fixed $p$, each round succeeds with probability $a(p)/2^m$. Independence gives

$$
\Pr[\text{all }k\text{ rounds accept }p]
=\prod_{i=1}^{k}\frac{a(p)}{2^m}
=\left(\frac{a(p)}{2^m}\right)^k.
$$

### Theorem 4 (Repeated truth-table soundness)

Let $p$ be a non-tautology in $m$ variables. Under $k$ independent uniform valuation challenges,

$$
\Pr[\text{all }k\text{ rounds accept }p]
\le
\left(\frac{2^m-1}{2^m}\right)^k
=
\left(1-2^{-m}\right)^k.
$$

**Proof sketch.** The accepting-set bound gives

$$
0\le \frac{a(p)}{2^m}\le\frac{2^m-1}{2^m}.
$$

Taking the product over $k$ identical nonnegative factors preserves the inequality. Independence identifies the left product with the probability of passing all rounds. $\square$

### Proposition 5 (Sharpness)

For every positive $m$, there exists a formula in $m$ variables whose $k$-round acceptance probability is exactly

$$
\left(1-2^{-m}\right)^k.
$$

**Proof sketch.** Consider the disjunction of all $m$ variables, expressed if desired using only implication and falsity. It is false exactly when every variable is false and true on the other $2^m-1$ valuations. Its one-round acceptance probability is therefore $(2^m-1)/2^m$, and independence gives equality after $k$ rounds. $\square$

### 3.2 Amplification cost

For a desired soundness error $\varepsilon$ with $0<\varepsilon<1$, the worst-case guarantee requires

$$
\left(1-2^{-m}\right)^k\le\varepsilon.
$$

Since both logarithms are negative, this is equivalent to

$$
k\ge
\frac{\log\varepsilon}{\log(1-2^{-m})}.
$$

Thus the smallest sufficient integer is

$$
k_{\min}
=
\left\lceil
\frac{\log\varepsilon}{\log(1-2^{-m})}
\right\rceil.
$$

Using $\log(1-x)=-x+O(x^2)$ as $x\to0$ gives

$$
k_{\min}=\Theta\!\left(2^m\log\frac1\varepsilon\right).
$$

The repetition count is exponential in the number of variables in the worst case. Consequently, this truth-table protocol is a finite soundness demonstration, not a polynomial-communication protocol for general propositional validity.

## 4. Additive masking and exact simulation

### 4.1 The masking experiment

Fix an integer $q\ge1$ and let

$$
G=\mathbb Z/q\mathbb Z
$$

with addition modulo $q$. A local secret is $s\in G$. Sample a mask $R$ uniformly from $G$ and expose

$$
C_s=s+R.
$$

The random variable $C_s$ is the verifier’s local view. Perfect hiding means that this view has the same distribution for every possible $s$.

### Lemma 6 (Translation bijection)

For every $s\in G$, the map

$$
\tau_s:G\longrightarrow G,\qquad \tau_s(r)=s+r,
$$

is a bijection.

**Proof sketch.** Its inverse is translation by $-s$: applying $r\mapsto -s+r$ after $\tau_s$ returns $r$, and conversely. $\square$

### Theorem 7 (Uniform-mask theorem)

For every secret $s\in G$, the distribution of $C_s=s+R$ is uniform on $G$.

**Proof sketch.** A bijection maps a uniform distribution on a finite set to the uniform distribution. By Lemma 6, translation by $s$ is a bijection. Equivalently, for each $c\in G$, the equation $s+r=c$ has the unique solution $r=c-s$. Since every mask has probability $1/q$, every observation $c$ has probability $1/q$. $\square$

### Theorem 8 (Perfect hiding)

For any secrets $s,t\in G$, the random variables $C_s$ and $C_t$ have identical distributions:

$$
\mathcal L(C_s)=\mathcal L(C_t).
$$

**Proof sketch.** By Theorem 7, both distributions are the uniform distribution on $G$. $\square$

### Corollary 9 (Pointwise independence of the secret)

For all $s,t,c\in G$,

$$
\Pr[C_s=c]=\Pr[C_t=c]=\frac1q.
$$

This pointwise statement is an immediate specialization of equality of distributions. It also provides an explicit simulator: without knowing $s$, sample a uniform element of $G$ and output it. The simulator’s output is distributed exactly like the actual masked view, so the simulation has zero statistical distance.

### 4.2 Scope of the hiding claim

The word “commitment” is sometimes used informally for the displayed value $s+r$. The construction here establishes its hiding property exactly, but additive masking alone is not binding. Given a displayed $c$, for every proposed secret $s'$ there is a mask $r'=c-s'$ satisfying $c=s'+r'$. A full cryptographic commitment must add a mechanism preventing the prover from changing the opening later. The finite theorem concerns privacy of the masked local value and should not be interpreted as a complete commitment construction.

Nor does marginal hiding automatically imply joint hiding under correlated openings. Suppose a verifier opens several masked values together with relations among their masks. Even if each coordinate is uniform separately, the tuple may reveal an invariant. For example, reusing the same mask in $s_1+r$ and $s_2+r$ reveals their difference. A zero-knowledge protocol must simulate the full joint transcript generated by each dependency-closed query, not merely each coordinate marginal.

## 5. The combined finite guarantee

### Theorem 10 (Soundness and local perfect hiding)

Let $p$ be a non-tautology in $m$ variables, let $k$ independent uniform valuation challenges be performed, and let local values lie in $G=\mathbb Z/q\mathbb Z$. Then:

1. the probability that $p$ passes every challenge is at most

$$
\left(\frac{2^m-1}{2^m}\right)^k;
$$

2. for any two local values $s,t\in G$, their independently and uniformly masked views have identical distributions.

**Proof sketch.** The first clause is Theorem 4. The second is Theorem 8. Their conjunction packages two independent guarantees without deriving one from the other. $\square$

The theorem is deliberately modular. Soundness depends on the density of rejecting valuations and independent sampling. Hiding depends on translation invariance in a finite group. The soundness argument does not use masking, and the masking argument does not use formula validity.

## 6. Algorithms

### 6.1 Exhaustive acceptance profiling

Given a formula in $m$ variables, enumerate the integers from $0$ through $2^m-1$, interpret each integer’s binary digits as a valuation, evaluate the formula, and count accepting rows. The algorithm returns $a(p)$, the exact one-round acceptance probability $a(p)/2^m$, and the exact $k$-round probability $(a(p)/2^m)^k$.

If $n$ is the formula-tree size, one evaluation costs $O(n)$ time. Enumeration costs $O(2^m n)$ time and $O(m+n)$ working space, excluding stored output. This exponential cost is intrinsic to direct truth-table enumeration.

### 6.2 Worst-case repetition planning

Given $m$ and a target error $\varepsilon$, compute the smallest $k$ satisfying $(1-2^{-m})^k\le\varepsilon$. Direct logarithms give the formula above, although a numerically robust implementation can increment or use binary search with exact rational powers. The logarithmic calculation takes constant arithmetic operations, while precision costs depend on the numeric representation.

### 6.3 Empirical masking audit

For each secret $s\in G$, enumerate all masks $r\in G$ and tabulate $s+r\pmod q$. Every output occurs exactly once in every row. This produces an exact frequency table, not merely a Monte Carlo estimate. Its running time is $O(q^2)$ for all secrets and its output occupies $O(q^2)$ space, or $O(q)$ if rows are streamed.

## 7. Numerical examples

Consider the disjunction of $m$ variables, which is false only on the all-false valuation. For $m=3$, it accepts $7$ of $8$ rows. After $k=10$ independent challenges, its survival probability is

$$
\left(\frac78\right)^{10}\approx0.2631.
$$

For $m=10$, a uniquely falsified formula passes one round with probability $1023/1024\approx0.999023$. After $1000$ rounds, it still survives with probability approximately

$$
\left(\frac{1023}{1024}\right)^{1000}\approx0.3764.
$$

For $m=20$, after $1000$ rounds the survival probability is approximately $0.999047$. These examples show that “geometric decay” can coexist with extremely weak practical detection.

For masking, take $q=5$ and secret $s=3$. As the mask ranges through $0,1,2,3,4$, the displayed values are

$$
3,4,0,1,2.
$$

Each residue appears exactly once. Secret $s=1$ instead produces

$$
1,2,3,4,0,
$$

again exactly uniform. The order changes, but the distribution does not.

## 8. Why random raw-line opening is insufficient

The finite model diagnoses three separate failures of the naive protocol for arbitrary derivations.

First, **sparse defects defeat efficient sampling**. If a purported derivation of length $N$ differs from a valid one at one location and a round samples one location uniformly, the catch probability is only $1/N$. Achieving constant soundness then needs $\Theta(N)$ rounds, and reducing error to $\varepsilon$ needs $\Theta(N\log(1/\varepsilon))$ rounds.

Second, **a raw line is not necessarily locally checkable**. Establishing that a line follows from earlier lines may require opening its premises, the premises of those premises, or global side conditions. The relevant query is therefore a dependency-closed neighborhood rather than an isolated symbol.

Third, **opening can disclose strategy**. A randomly selected line may contain a decisive lemma or construction. Commitment hiding protects unopened data; it says nothing about information intentionally revealed when a challenge is answered. Zero knowledge requires a simulator whose transcript has the same distribution using only the permitted public information.

A robust locally testable encoding addresses the first problem by spreading every invalidity across a fixed positive fraction $\delta$ of local tests. Then $k$ independent rounds have error at most $(1-\delta)^k$, and $O(\log(1/\varepsilon))$ rounds suffice when $\delta$ is constant. A dependency-aware zero-knowledge compiler must address the second and third problems by masking correlated local states and simulating their entire joint view.

## 9. Applications

The results apply directly to randomized auditing of finite Boolean specifications. When the full truth table is modest, exhaustive profiling computes exact failure density; when it is large, random testing offers a transparent probabilistic audit whose limitations are explicitly quantified.

Additive hiding is useful wherever a local value must be information-theoretically concealed before controlled opening. Its translation argument underlies secret sharing and one-time-pad constructions. In protocol design, the theorem serves as a primitive: fresh uniform masks erase the marginal distribution of individual finite-group values.

The conceptual separation is also valuable in privacy-preserving computation. Integrity mechanisms answer whether data or computation are valid; privacy mechanisms answer what observations disclose. Treating either as a consequence of the other invites protocol errors. A secure design states completeness, soundness, hiding, binding, and simulation properties separately.

For confidential mathematics, the most realistic near-term applications lie in structured families whose global constraints have small local descriptions: bounded-treewidth formulas, bounded-width dynamic programs, circuit computations, and algebraic constraint systems. These settings permit local checking without pretending that an arbitrary raw derivation is locally robust.

## 10. Discussion and limitations

The soundness theorem is exact but weak in the worst case. It assumes direct evaluation at sampled valuations and does not reduce the exponential challenge universe. It proves neither polynomial communication nor efficient verification for arbitrary propositional tautologies.

The hiding theorem is perfect but local. It assumes a fresh uniform mask in a finite additive group. It does not provide binding, authentication, or secure opening. It does not establish zero knowledge for an interactive protocol whose openings are correlated.

Most importantly, the two theorems do not imply that every theorem with a short statement has a zero-knowledge proof whose communication is polynomial in statement length. The length of the shortest derivation can be enormous compared with the statement, and generic encodings are measured relative to the object being encoded. A succinctness claim needs a precise complexity model and additional machinery.

These limitations are productive. They isolate robustness as the resource missing from random raw-line checking and joint simulation as the resource missing from coordinatewise hiding.

## 11. Future work

A first direction is the construction of robust local encodings of arithmetic derivations. The target is an explicit transformation for which every invalid encoding fails a fixed positive fraction of constant-query tests, with encoding length polynomial in derivation length.

A second direction is simulation under dependency closure. One should characterize when a locally testable relation admits masks and openings whose joint distribution depends only on the tested constraint’s truth value.

A third direction is a communication lower bound for authenticated raw-line protocols. Sparse-defect examples suggest that any such verifier must communicate an amount growing with minimal derivation length for some families of short statements.

A fourth direction concerns formulas of bounded treewidth. Their tree decompositions turn validity into compatibility of local dynamic-programming states. This may permit polynomial communication and logarithmic dependence on inverse soundness error while finite-group masking conceals local states.

Finally, local simulators suggest a gluing theory. Transcript distributions defined on overlapping query neighborhoods must agree on intersections and assemble into a consistent global distribution. A precise local-to-global theorem would provide a principled criterion for composing zero-knowledge views.

## 12. Conclusion

The finite theory establishes two exact facts. A non-tautology in $m$ variables survives $k$ independent uniform valuation challenges with probability at most $(1-2^{-m})^k$, and this rate is sharp. A finite-group value hidden by a fresh uniform additive mask has the uniform distribution, independent of the value, so its local view is perfectly simulatable.

Together these facts clarify rather than complete the program of private theorem certification. Repetition amplifies only the rejection density already present, and privacy requires simulation of everything that is opened. Succinct secret proofs therefore require robust local encodings coupled to dependency-aware hiding. The path from a sealed local value to a sealed mathematical derivation runs through that missing bridge.
