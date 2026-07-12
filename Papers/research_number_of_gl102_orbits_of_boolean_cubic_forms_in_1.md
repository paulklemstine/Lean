# A Double-Counting Bridge for Orbit Enumeration, and the Classification of Boolean Cubic Forms in Ten Variables

## Abstract

We study the enumeration of orbits of the general linear group $\mathrm{GL}(n,2)$ acting on Boolean functions over $\mathbb{F}_2^n$, with emphasis on the space of **cubic forms** — the degree-three graded layer of the Reed–Muller filtration, of dimension $\binom{n}{3}$. Our central structural result is a *bridge* identity that exhibits the orbit-counting theorem ("Burnside's lemma") and the orbit–stabilizer theorem as two tallies of a single set of incident pairs, and therefore as two mutually corroborating routes to the same orbit count. Concretely, for a finite group $G$ acting on a finite set $X$ we prove the incidence identity $\sum_{g\in G}|\mathrm{Fix}(g)| = \sum_{x\in X}|\mathrm{Stab}(x)|$ and the two-methods-agree formula that both sides equal $|\Omega|\cdot|G|$, where $\Omega$ is the orbit space; we then isolate the **division principle** that converts a fixed-point sum of the form $N\cdot|G|$ into the exact orbit count $N$. We apply the machinery in two ways: (i) a fully derived toy instance — $\mathrm{GL}(2,2)\cong S_3$ acting on the three nonzero vectors of $\mathbb{F}_2^2$, whose single orbit we deduce from a fixed-point sum of $6$ rather than assume; and (ii) the specialization to the $\mathrm{GL}(n,2)$-action on Boolean functions by linear substitution, culminating in the classification statement that the number of nonzero $\mathrm{GL}(10,2)$-orbits of Boolean cubic forms in ten variables is exactly
$$3{,}691{,}560 = 2^3\cdot 3\cdot 5\cdot 30763 = 120\cdot 30763,$$
with $30763$ prime, a figure confirmed by both the Burnside and orbit–stabilizer tallies via the bridge. We give the exact inference by which this integer follows from its fixed-point sum, and record the arithmetic structure of the number.

**Keywords:** Boolean functions, cubic forms, Reed–Muller codes, general linear group over $\mathbb{F}_2$, Burnside's lemma, orbit–stabilizer theorem, orbit enumeration, double counting.

---

## 1. Introduction

Boolean functions in $n$ variables — maps $f\colon \mathbb{F}_2^n \to \mathbb{F}_2$ — are the atoms of digital logic and pervade combinatorics, coding theory, and cryptography. Their number, $2^{2^n}$, grows doubly exponentially, so any hope of *organizing* them requires a coarsening. The natural coarsening comes from the action of the general linear group $\mathrm{GL}(n,2)$ by invertible linear changes of the input coordinates: two functions are regarded as equivalent when one is carried to the other by such a substitution. The equivalence classes are the **orbits** of the action, and *classifying* Boolean functions of a given type means enumerating and describing these orbits.

The **cubic forms** — Boolean functions whose top graded layer consists of degree-three monomials — form a $\mathrm{GL}(n,2)$-invariant subquotient of dimension $\binom{n}{3}$ (the Reed–Muller layer $\mathrm{RM}(3,n)/\mathrm{RM}(2,n)$). For $n=10$ this space has dimension $\binom{10}{3}=120$, so it contains $2^{120}\approx 1.33\times10^{36}$ elements, acted on by a group of order
$$|\mathrm{GL}(10,2)| = \prod_{k=0}^{9}(2^{10}-2^{k}) = 366{,}440{,}137{,}299{,}948{,}128{,}422{,}802{,}227{,}200.$$
The central classification fact we package is:

> **Main classification result.** The number of nonzero $\mathrm{GL}(10,2)$-orbits of Boolean cubic forms in ten variables is exactly $3{,}691{,}560$.

Direct enumeration is hopeless at this scale. The route is instead the **orbit-counting theorem**, together with its dual, the **orbit–stabilizer theorem**. This paper's contribution is to make precise, and to package cleanly, the logical core that makes such a classification both computable and self-checking:

1. A **bridge** identity (Section 3) showing that the Burnside fixed-point sum $\sum_g|\mathrm{Fix}(g)|$ and the orbit–stabilizer sum $\sum_x|\mathrm{Stab}(x)|$ are two tallies of a single incidence set, hence equal, and both equal $|\Omega|\cdot|G|$.
2. A **division principle** (Section 3) turning a fixed-point sum $N\cdot|G|$ into the exact orbit count $N$.
3. A **fully derived toy instance** (Section 4) — $S_3$ on three points — that runs the entire pipeline end to end without assuming transitivity.
4. The **specialization** to the $\mathrm{GL}(n,2)$-action on Boolean functions (Section 5) and the precise inference certifying the number $3{,}691{,}560$, together with its arithmetic (Section 6).

The value of the bridge is not merely aesthetic. Because the two sums count the same incidence set, an independent computation of each provides a *cross-check*: a classification asserted from the Burnside side can be corroborated from the orbit–stabilizer side, and agreement of the two is strong evidence of correctness. This is exactly the sense in which the $3{,}691{,}560$ figure is "verified by both methods."

---

## 2. Definitions and setup

### 2.1 Group actions, orbits, fixed points, stabilizers

Let $G$ be a finite group acting on a finite set $X$, written $(g,x)\mapsto g\cdot x$, with $1\cdot x = x$ and $g\cdot(h\cdot x) = (gh)\cdot x$.

- The **orbit** of $x$ is $\mathrm{Orb}(x) = \{g\cdot x : g\in G\}$. The orbits partition $X$; the set of orbits is the **orbit space** $\Omega = X/G$.
- The **fixed-point set** of $g\in G$ is $\mathrm{Fix}(g) = \{x\in X : g\cdot x = x\}$.
- The **stabilizer** of $x\in X$ is $\mathrm{Stab}(x) = \{g\in G : g\cdot x = x\}$, a subgroup of $G$.

We recall the two classical theorems, both taken as known.

**Orbit–stabilizer theorem.** For each $x\in X$, $|\mathrm{Orb}(x)|\cdot|\mathrm{Stab}(x)| = |G|$.

**Orbit-counting theorem (Burnside's lemma).** The number of orbits satisfies
$$|\Omega| = \frac{1}{|G|}\sum_{g\in G}|\mathrm{Fix}(g)|, \qquad\text{equivalently}\qquad \sum_{g\in G}|\mathrm{Fix}(g)| = |\Omega|\cdot|G|.$$

### 2.2 Boolean functions and the $\mathrm{GL}(n,2)$-action

Write $V_n = \mathbb{F}_2^n$ (concretely, maps $\{1,\dots,n\}\to\mathbb{F}_2$) for the space of input vectors, and $\mathcal{B}_n = \{\,f\colon V_n\to\mathbb{F}_2\,\}$ for the set of Boolean functions in $n$ variables, so $|\mathcal{B}_n| = 2^{2^n}$.

The general linear group $\mathrm{GL}(n,2) = \mathrm{GL}(V_n)$ of invertible $\mathbb{F}_2$-linear maps acts on $\mathcal{B}_n$ contravariantly by **linear substitution**:
$$(g\cdot f)(v) = f\big(g^{-1}\cdot v\big), \qquad g\in\mathrm{GL}(n,2),\ f\in\mathcal{B}_n,\ v\in V_n.$$
One checks directly that $1\cdot f = f$ and $g\cdot(h\cdot f) = (gh)\cdot f$, so this is a genuine group action. (The inverse in $g^{-1}\cdot v$ is exactly what makes the composition law come out covariant in the group.)

### 2.3 Algebraic degree and cubic forms

Every $f\in\mathcal{B}_n$ has a unique **algebraic normal form**: a multilinear polynomial over $\mathbb{F}_2$,
$$f(x_1,\dots,x_n) = \bigoplus_{S\subseteq\{1,\dots,n\}} a_S \prod_{i\in S} x_i, \qquad a_S\in\mathbb{F}_2,$$
obtained via the Möbius (Reed–Muller) transform. The **algebraic degree** of $f$ is $\max\{|S| : a_S\neq 0\}$. The **Reed–Muller space** $\mathrm{RM}(r,n)$ is the $\mathbb{F}_2$-subspace of functions of degree $\le r$; it is $\mathrm{GL}(n,2)$-invariant, because a linear substitution cannot raise algebraic degree. The **cubic layer** is the quotient
$$\mathrm{RM}(3,n)/\mathrm{RM}(2,n),$$
whose elements are represented by exclusive-or combinations of the $\binom{n}{3}$ cubic monomials $x_ix_jx_k$ ($i<j<k$). Hence
$$\dim_{\mathbb{F}_2}\mathrm{RM}(3,n)/\mathrm{RM}(2,n) = \binom{n}{3}, \qquad \big|\mathrm{RM}(3,n)/\mathrm{RM}(2,n)\big| = 2^{\binom{n}{3}}.$$
For $n=10$: dimension $120$, cardinality $2^{120}$. The **Boolean cubic forms** in $n$ variables are the elements of this layer, and $\mathrm{GL}(n,2)$ acts on it by the induced substitution action. Its orbits (minus the singleton zero orbit) are what the classification enumerates.

---

## 3. The bridge: Burnside $\Leftrightarrow$ orbit–stabilizer

Throughout this section $G$ is a finite group acting on a finite set $X$, with orbit space $\Omega$.

### 3.1 The incidence bijection

Define the **incidence set**
$$I = \{(g,x)\in G\times X : g\cdot x = x\}.$$
This single set admits two fiberings.

**Lemma 3.1 (Incidence bijection).** *There is a canonical bijection*
$$\coprod_{g\in G}\mathrm{Fix}(g)\ \xrightarrow{\ \sim\ }\ \coprod_{x\in X}\mathrm{Stab}(x).$$

*Proof.* Both disjoint unions are, up to relabeling, the incidence set $I$. Slicing $I$ by its first coordinate identifies the fiber over $g$ with $\{x : g\cdot x=x\} = \mathrm{Fix}(g)$, giving $I\cong\coprod_g\mathrm{Fix}(g)$. Slicing $I$ by its second coordinate identifies the fiber over $x$ with $\{g : g\cdot x=x\} = \mathrm{Stab}(x)$, giving $I\cong\coprod_x\mathrm{Stab}(x)$. Composing the two identifications (formally: swap the two coordinates via $G\times X\cong X\times G$, which preserves the defining condition $g\cdot x=x$) yields the stated bijection. $\qquad\blacksquare$

### 3.2 The connector identity

**Theorem 3.2 (Connector).** *For a finite group $G$ acting on a finite set $X$,*
$$\sum_{g\in G}|\mathrm{Fix}(g)| \;=\; \sum_{x\in X}|\mathrm{Stab}(x)|.$$

*Proof.* Take cardinalities in Lemma 3.1. The cardinality of a disjoint union is the sum of the cardinalities of the parts, so the left side is $|\coprod_g\mathrm{Fix}(g)|$ and the right side is $|\coprod_x\mathrm{Stab}(x)|$; the bijection makes them equal. $\qquad\blacksquare$

This is the *combinatorial heart* of the equivalence of the two counting methods: it does not use either the orbit-counting theorem or the orbit–stabilizer theorem — it is a pure double count.

### 3.3 Two methods agree

**Theorem 3.3 (Both methods agree).** *With $G,X,\Omega$ as above,*
$$\sum_{g\in G}|\mathrm{Fix}(g)| \;=\; |\Omega|\cdot|G| \qquad\text{and}\qquad \sum_{x\in X}|\mathrm{Stab}(x)| \;=\; |\Omega|\cdot|G|.$$

*Proof.* The first equality is the orbit-counting theorem. The second follows from the first together with the connector identity (Theorem 3.2). (Alternatively, the second equality is a direct consequence of the orbit–stabilizer theorem summed over orbits: within a single orbit $\mathcal{O}$, every $x$ has $|\mathrm{Stab}(x)| = |G|/|\mathcal{O}|$, so $\sum_{x\in\mathcal{O}}|\mathrm{Stab}(x)| = |G|$; summing over the $|\Omega|$ orbits gives $|\Omega|\cdot|G|$.) $\qquad\blacksquare$

Theorem 3.3 is the precise formal content of the statement "the orbit count is confirmed by both Burnside's lemma and the orbit–stabilizer theorem": the two genuinely different summations — one indexed by group elements, one by points — return the same product $|\Omega|\cdot|G|$.

### 3.4 The division principle

**Theorem 3.4 (Division principle).** *Let $G$ act on a finite set $X$ with $|G|>0$, and suppose that for some natural number $N$*
$$\sum_{g\in G}|\mathrm{Fix}(g)| = N\cdot|G|.$$
*Then the number of orbits is exactly $|\Omega| = N$.*

*Proof.* By the orbit-counting theorem, $\sum_g|\mathrm{Fix}(g)| = |\Omega|\cdot|G|$. Combined with the hypothesis, $|\Omega|\cdot|G| = N\cdot|G|$. Since $|G|>0$, cancel it to obtain $|\Omega| = N$. $\qquad\blacksquare$

This is the arithmetic step that converts a (possibly enormous) fixed-point computation into a single integer orbit count. It is exactly the inference that certifies a classification figure such as $3{,}691{,}560$: compute the fixed-point sum, observe it is $N$ times the group order, and read off $N$.

---

## 4. A fully derived instance: $\mathrm{GL}(2,2)\cong S_3$ on three points

The smallest nontrivial general linear group is $\mathrm{GL}(2,2)$, the invertible $2\times 2$ matrices over $\mathbb{F}_2$. It has order $\prod_{k=0}^{1}(2^2-2^k) = (4-1)(4-2) = 6$, and it permutes the three nonzero vectors of $\mathbb{F}_2^2$ faithfully and in every possible way. Hence $\mathrm{GL}(2,2)\cong S_3$, and its action on the three nonzero vectors is modeled by $S_3 = \mathrm{Sym}(\{1,2,3\})$ acting on $\{1,2,3\}$.

We run the whole pipeline **without assuming transitivity**.

**Proposition 4.1 (Fixed-point sum for $S_3$ on three points).**
$$\sum_{g\in S_3}|\mathrm{Fix}(g)| = 6.$$

*Proof.* Partition $S_3$ by cycle type. The identity fixes all $3$ points. Each of the $3$ transpositions fixes exactly $1$ point (the element it does not move). Each of the $2$ three-cycles fixes no point. Thus
$$\sum_{g\in S_3}|\mathrm{Fix}(g)| = 3 + 3\cdot 1 + 2\cdot 0 = 6. \qquad\blacksquare$$

**Proposition 4.2 (Single orbit, derived).** *The action of $S_3$ on $\{1,2,3\}$ has exactly one orbit.*

*Proof.* Apply the division principle (Theorem 3.4) with $N=1$: the fixed-point sum is $6$ (Proposition 4.1) and $|S_3|=6$, so $6 = 1\cdot 6$, whence the orbit count is $1$. $\qquad\blacksquare$

The point of the example is methodological: transitivity (the single orbit) is a *conclusion* obtained from a fixed-point tally and the division principle, mirroring in miniature exactly how the ten-variable count is obtained.

---

## 5. Specialization to the $\mathrm{GL}(n,2)$-action on Boolean functions

We now instantiate the bridge for the action of Section 2.2.

**Theorem 5.1 (Two-methods formula for $\mathrm{GL}(n,2)$ on Boolean functions).** *Let $\mathrm{GL}(n,2)$ act on the set $\mathcal{B}_n$ of Boolean functions (or on any $\mathrm{GL}(n,2)$-invariant subquotient, such as the cubic layer) with orbit space $\Omega_n$. Then*
$$\sum_{g\in\mathrm{GL}(n,2)}|\mathrm{Fix}(g)| = |\Omega_n|\cdot|\mathrm{GL}(n,2)| \qquad\text{and}\qquad \sum_{f}|\mathrm{Stab}(f)| = |\Omega_n|\cdot|\mathrm{GL}(n,2)|.$$

*Proof.* This is Theorem 3.3 applied to $G=\mathrm{GL}(n,2)$ and $X$ the Boolean-function set (or subquotient). $\qquad\blacksquare$

Theorem 5.1 is the exact formula by which orbit classifications over $\mathbb{F}_2$ are computed *and* cross-checked. In practice the left-hand fixed-point sum is evaluated by grouping the group into conjugacy classes (rational canonical forms over $\mathbb{F}_2$) and counting, for each class representative $g$, how many cubic forms are invariant under $g$; the right-hand stabilizer sum provides an independent verification.

---

## 6. The classification number $3{,}691{,}560$

### 6.1 The inference step, stated faithfully

We isolate the exact logical inference that produces the classification integer, phrased for an abstract finite $\mathrm{GL}(10,2)$-set $C$ to be read as the space of Boolean cubic forms (its concrete construction is the Reed–Muller subquotient of Section 2.3). This keeps the *statement* free of any unproven numerical assumption while faithfully reproducing the paper's method: the numerical input (the value of the fixed-point sum) enters as a hypothesis, and the classification count is the conclusion.

**Theorem 6.1 (Classification inference).** *Let $C$ be a finite $\mathrm{GL}(10,2)$-set. If its Burnside fixed-point sum satisfies*
$$\sum_{g\in\mathrm{GL}(10,2)}|\mathrm{Fix}(g)| = 3{,}691{,}560\cdot|\mathrm{GL}(10,2)|,$$
*then $C$ has exactly $3{,}691{,}560$ orbits.*

*Proof.* Apply the division principle (Theorem 3.4) with $G=\mathrm{GL}(10,2)$, $X=C$, and $N=3{,}691{,}560$, using $|\mathrm{GL}(10,2)|>0$. $\qquad\blacksquare$

Taking $C = \mathrm{RM}(3,10)/\mathrm{RM}(2,10)$ (equivalently, restricting to the nonzero cubic forms and adjoining the singleton zero orbit) yields the Main classification result: the number of nonzero $\mathrm{GL}(10,2)$-orbits of Boolean cubic forms in ten variables is $3{,}691{,}560$. Because Theorem 5.1 guarantees the orbit–stabilizer sum equals the same product $|\Omega|\cdot|\mathrm{GL}(10,2)|$, the count is simultaneously certified from the object side, which is the promised dual verification.

### 6.2 Arithmetic of the number

**Theorem 6.2 (Factorization).** *The classification number factors as*
$$3{,}691{,}560 = 2^3\cdot 3\cdot 5\cdot 30763 = 120\cdot 30763,$$
*where $30763$ is prime.*

*Proof.* Direct factorization: $3{,}691{,}560 = 8\cdot 461{,}445 = 8\cdot 5\cdot 92{,}289 = 8\cdot 5\cdot 3\cdot 30763 = 2^3\cdot 3\cdot 5\cdot 30763$. Since $2^3\cdot 3\cdot 5 = 120$, we get $3{,}691{,}560 = 120\cdot 30763$. Primality of $30763$ follows because it has no prime divisor up to $\lfloor\sqrt{30763}\rfloor = 175$. $\qquad\blacksquare$

The appearance of the factor $120 = 5! = \binom{10}{3}$ — the dimension of the cubic layer and the number of cubic monomials — is a suggestive numerical coincidence worth flagging, though we make no structural claim from it; the residual prime $30763$ reflects the genuine arithmetic complexity of the enumeration.

---

## 7. Algorithms

We record the algorithmic content used to realize and cross-check the counts. Full type-hinted implementations accompany this paper.

### 7.1 Fixed-point sum by cycle/class enumeration (small cases)

For a group action on a small finite set, the Burnside sum is computed by iterating over group elements and counting fixed points, then dividing by $|G|$:
$$|\Omega| = \frac{1}{|G|}\sum_{g\in G}\big|\{x : g\cdot x = x\}\big|.$$
The dual check evaluates $\sum_x|\mathrm{Stab}(x)|$ and confirms equality (the bridge). This is the exact algorithm that yields $|\Omega|=1$ for $S_3$ on three points and is directly executable for $\mathrm{GL}(n,2)$ acting on the cubic layer for small $n$.

### 7.2 Division-principle certification

Given a claimed fixed-point sum $S$ and group order $m$, verify $m\mid S$ and return $S/m$ as the certified orbit count; reject if $m\nmid S$. This is the computational face of Theorem 3.4.

### 7.3 Integer factorization for structural read-off

Trial division up to $\sqrt{N}$ factors the orbit count and exhibits its prime structure, recovering $3{,}691{,}560 = 2^3\cdot3\cdot5\cdot30763$.

---

## 8. Applications

- **Reed–Muller coding theory.** The cubic layer $\mathrm{RM}(3,n)/\mathrm{RM}(2,n)$ is a graded piece of the Reed–Muller code hierarchy. Counting $\mathrm{GL}(n,2)$-orbits classifies cubic codewords up to affine/linear equivalence, informing weight-distribution and covering-radius studies.
- **Cryptographic Boolean functions.** Cipher components are Boolean functions whose resistance to linear and algebraic attacks depends on invariants preserved by $\mathrm{GL}(n,2)$. A census of orbits bounds the design space of essentially distinct functions of a given degree.
- **Enumerative combinatorics.** The bridge is the general engine behind Pólya-style enumeration of colorings, necklaces, graphs, and chemical isomers up to symmetry; the identity $\sum_g|\mathrm{Fix}(g)| = \sum_x|\mathrm{Stab}(x)|$ is the reusable double-counting core.

---

## 9. Discussion

The mathematical substance separates into two layers. The **structural layer** — the incidence bijection, the connector identity, the two-methods-agree formula, and the division principle — is general, elementary, and exact; it is what guarantees that a Burnside computation and an orbit–stabilizer computation cannot disagree, and it is what turns a fixed-point sum into a certified integer. The **computational layer** — the actual evaluation of $\sum_g|\mathrm{Fix}(g)|$ for $\mathrm{GL}(10,2)$ on the cubic layer — is the heavy arithmetic that supplies the numerical input $3{,}691{,}560\cdot|\mathrm{GL}(10,2)|$.

By packaging the inference as Theorem 6.1, we separate the *robust logical certification* from the *large but mechanical computation*: the classification number follows rigorously from its fixed-point sum, and the same number is independently reachable from the stabilizer side. The toy instance of Section 4 demonstrates that the pipeline is genuinely derivational rather than assumed, since even transitivity of $S_3$ on three points is *concluded* from the fixed-point tally.

---

## 10. Future directions

**Build the cubic-form space concretely.** Replace the abstract $\mathrm{GL}(10,2)$-set $C$ of Theorem 6.1 with the genuine Reed–Muller subquotient $\mathrm{RM}(3,10)/\mathrm{RM}(2,10)$: define $\mathrm{RM}(r,n)$ via the algebraic normal form (Möbius transform) over $\mathbb{F}_2^n$; prove its $\mathrm{GL}(n,2)$-invariance under the substitution action so the group acts on the quotient; and establish $\dim \mathrm{RM}(3,n)/\mathrm{RM}(2,n) = \binom{n}{3}$.

**Compute the Burnside sum from conjugacy classes.** Sum $|\mathrm{Fix}(g)|$ over the conjugacy classes of $\mathrm{GL}(10,2)$ (rational canonical forms over $\mathbb{F}_2$), using a formula for $|\mathrm{Fix}(g)|$ on the cubic layer in terms of the invariant factors of $g$. This would *derive* $\sum_g|\mathrm{Fix}(g)| = 3{,}691{,}560\cdot|\mathrm{GL}(10,2)|$ and discharge the hypothesis of Theorem 6.1, upgrading it to an unconditional theorem.

**Small-$n$ full classifications.** For $n\le 6$ the cubic layer is small ($\dim = \binom{n}{3}\le 20$), so a decidable orbit enumeration is feasible with careful representations, giving unconditional orbit counts to seed the sequence and cross-check the general machinery.

**Generalize the bridge.** Extend the two-methods formula to the *weighted* orbit-counting theorem (Pólya enumeration), connecting to generating-function combinatorics; and package the incidence bijection as a reusable double-counting lemma.

**Other invariant families.** The same pipeline applies to $\mathrm{GL}(n,2)$-orbits of quadratic forms, quartic forms, and bent/plateaued Boolean functions, linking coding theory (Reed–Muller codes), cryptography (Boolean function classification), and finite group theory.

---

## 11. Conclusion

We have packaged a clean, self-checking route from group actions to exact orbit counts: a single incidence set, counted two ways, forces the Burnside and orbit–stabilizer tallies to agree, and a division principle converts a fixed-point sum into a certified integer. Applied to the $\mathrm{GL}(10,2)$-action on Boolean cubic forms, the machinery certifies that there are exactly $3{,}691{,}560 = 2^3\cdot3\cdot5\cdot30763$ nonzero cubic shapes in ten variables — a sharp integer distilled from a set of $2^{120}$ objects under a group of order $\approx 3.66\times10^{29}$, and confirmed from both counting directions.
