# Tropical Ideals and Their Matroids: Vector Elimination for Tropical Hyperplanes, Circuit Theory, and the Vanishing Ideal of a Point

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

A *tropical ideal*, in the sense of Maclagan and Rincón, is a subsemimodule of the tropical polynomial semiring that is, in each bounded degree, the set of vectors of a valuated matroid. The matroidal condition — the **vector elimination axiom** — is what separates tropical ideals from arbitrary subsemimodules and is what makes a tropical scheme theory possible at all; without it, the objects are too plentiful and too unstructured to carry geometry. This paper develops that matroidal layer in full and exhibits a first genuinely nontrivial tropical ideal on which tropical Gröbner machinery can be run.

We prove that every **tropical hyperplane** $H(c) = \{x : \min_i (c_i \odot x_i) \text{ attained twice}\}$ over the min-plus semiring $\mathbb{T} = \mathbb{Q} \cup \{\infty\}$ satisfies the vector elimination axiom, and hence is a tropical linear space. The proof rests on a **rigidity lemma**: if the coordinatewise-minimum vector, truncated at the eliminated coordinate, possesses a strictly unique minimal coordinate, then the two input vectors already agree there. We show that the axiom is genuine extra content by producing an explicit four-coordinate pair of hyperplanes whose set-theoretic intersection is a subsemimodule but **fails** elimination; by contrast, tropical diagonal rescaling and matroid deletion both preserve tropical linear spaces. We then extract the combinatorics: the vector axiom implies Minty's support-elimination property, every nonzero member contains a circuit, and the circuits of any tropical linear space satisfy the **matroid circuit elimination axiom**. For a hyperplane with everywhere-finite coefficients the circuits are exactly the two-element subsets, so the underlying matroid is the uniform matroid $U_{n-1,n}$.

Finally we produce a nontrivial tropical ideal. For a rational point $w$, the set of tropical polynomials vanishing at $w$ (in the sense that the minimum of the term values is attained at least twice) is an ideal of the tropical polynomial semiring — closure under multiplication being the substantive point, proved by exhibiting two distinct minimizing exponents of the product. Every truncation of this ideal to a finite monomial set $E$ with $|E| \ge 2$ is *exactly* the tropical hyperplane cut out by the evaluation weights, hence a tropical linear space; the vanishing ideal is therefore a tropical ideal, its degreewise matroid is uniform, and degreewise elimination is available as an explicit polynomial operation. Buchberger-style completion terminates on this ideal relative to any finite test set $U$ in at most $|U|$ steps, and Gröbner bases relative to $U$ are exactly the fixed points of the completion step.

**Keywords:** tropical semiring, tropical ideal, valuated matroid, vector elimination, tropical hyperplane, circuit elimination, uniform matroid, tropical Gröbner basis.

---

## 1. Introduction

### 1.1 The problem with semiring ideals

Tropical geometry replaces a field by the **min-plus semiring**
$$\mathbb{T} = \mathbb{Q} \cup \{\infty\}, \qquad a \oplus b = \min(a,b), \qquad a \odot b = a + b,$$
with additive identity $\infty$ and multiplicative identity $0$. Both operations are associative and commutative, $\odot$ distributes over $\oplus$, and every finite element is invertible for $\odot$. What is missing is additive inverses: $a \oplus b = \infty$ forces $a = b = \infty$. The semiring is *idempotent*, $a \oplus a = a$.

Idempotency is catastrophic for naive ideal theory. Over a field, ideals of $K[x_1,\dots,x_n]$ correspond to geometry; over $\mathbb{T}$, the analogous objects — subsemimodules of the tropical polynomial semiring closed under $\oplus$ and multiplication by polynomials — form an enormous, ill-behaved class. There is no cancellation, so no Gaussian elimination, so no dimension theory, no Hilbert function, and no primary decomposition.

Maclagan and Rincón's insight is that the missing rigidity is *matroidal*. A **tropical ideal** is a subsemimodule $I$ such that, for every finite set $E$ of monomials, the set of coefficient vectors
$$\{ (\mathrm{coeff}_u f)_{u \in E} \ :\ f \in I,\ \operatorname{supp}(f) \subseteq E \} \subseteq \mathbb{T}^E$$
is the set of vectors of a **valuated matroid** on $E$. Concretely, this means the truncation satisfies a *vector elimination axiom* generalizing the following classical fact: over a field, if two vectors have the same $e$-th coordinate, their difference kills that coordinate. Tropically the difference does not exist, so its existence must be axiomatized.

With that axiom in place, tropical ideals behave: they have well-defined Hilbert functions, finitely many associated primes, and support Gröbner theory. Without it, they do not.

### 1.2 What this paper contributes

This paper supplies the matroidal layer in complete detail, in four movements.

1. **Elimination holds for hyperplanes** (Section 3). The basic tropical linear objects satisfy the vector elimination axiom. The proof is not formal: it requires a rigidity lemma controlling where a "lonely minimum" can sit.
2. **Elimination is sharp** (Section 4). An explicit example in $\mathbb{T}^4$ shows that the intersection of two tropical hyperplanes can be a subsemimodule that fails elimination. Rescaling and deletion, on the other hand, preserve tropical linear spaces.
3. **The axiom's combinatorial shadow** (Section 5). Vector elimination implies support elimination, hence circuit elimination; every tropical linear space carries a matroid, and for hyperplanes that matroid is uniform.
4. **A nontrivial tropical ideal** (Section 6). The vanishing ideal of a rational point is an ideal of the tropical polynomial semiring, is a tropical ideal, has uniform degreewise matroid, and supports terminating Buchberger completion (Section 7).

---

## 2. Tropical vectors and tropical linear spaces

Throughout, $E$ is an index set — for the polynomial applications, a finite set of monomials — and $\mathbb{T} = \mathbb{Q}\cup\{\infty\}$ with its min-plus structure, ordered so that $\infty$ is the top element.

**Definition 2.1 (Tropical vector operations).** For $x, y : E \to \mathbb{T}$ and $a \in \mathbb{T}$ define
$$(x \oplus y)_i = \min(x_i, y_i), \qquad (a \odot x)_i = a + x_i, \qquad \mathbf{0}_i = \infty .$$
The **support** of $x$ is $\operatorname{supp}(x) = \{ i \in E : x_i \ne \infty \}$; thus $x = \mathbf{0}$ iff $\operatorname{supp}(x) = \varnothing$.

**Definition 2.2 (Subsemimodule).** A set $V \subseteq \mathbb{T}^E$ is a **tropical subsemimodule** if $\mathbf{0} \in V$, and $V$ is closed under $\oplus$ and under $a \odot (-)$ for all $a \in \mathbb{T}$.

**Definition 2.3 (Vector elimination axiom).** $V \subseteq \mathbb{T}^E$ **satisfies elimination** if for all $x, y \in V$ and every coordinate $e$ with
$$x_e = y_e \ne \infty,$$
there exists $z \in V$ such that

* (E1) $z_e = \infty$;
* (E2) $\min(x_i,y_i) \le z_i$ for all $i \in E$;
* (E3) $z_i = \min(x_i, y_i)$ for every $i$ with $x_i \ne y_i$.

**Definition 2.4 (Tropical linear space).** $V$ is a **tropical linear space** if it is a tropical subsemimodule satisfying elimination.

Three remarks on Definition 2.3. First, (E1) is the elimination itself. Second, (E2) says $z$ dominates the tropical sum $x \oplus y$ — the tropical analogue of "$z$ lies in the span". Third, (E3) is the crucial rigidity clause: without it, $z = \mathbf{0}$ would always satisfy (E1) and (E2) is only a lower bound, making the axiom vacuous. With (E3), $z$ is *pinned* to $x \oplus y$ at every coordinate of disagreement and may only float upward where $x$ and $y$ agree. This is exactly the valuated-matroid vector axiom in min-plus coordinates.

**Definition 2.5 (Tropical hyperplane).** For a coefficient vector $c : E \to \mathbb{T}$ set
$$H(c) \ =\ \{\, x \in \mathbb{T}^E \ :\ \forall i \in E,\ \exists j \ne i,\ c_j + x_j \le c_i + x_i \,\}.$$

**Proposition 2.6 (Relational form equals "minimum attained twice").** If $E$ is finite and nonempty, then $x \in H(c)$ if and only if there exist $i \ne j$ with $c_i + x_i \le c_k + x_k$ for all $k$, and $c_j + x_j = c_i + x_i$.

*Proof.* ($\Rightarrow$) Let $i$ minimize $k \mapsto c_k + x_k$ over the finite set $E$. The defining property at $i$ gives $j \ne i$ with $c_j + x_j \le c_i + x_i$; minimality gives the reverse inequality, hence equality. ($\Leftarrow$) Given such $i,j$ and any $k$: if $k = i$ use $j$ as witness, else use $i$. $\square$

Thus $H(c)$ is the tropical vanishing locus of the linear form $c_1 \odot x_1 \oplus \cdots \oplus c_n \odot x_n$, "vanishing" meaning the minimum is attained at least twice — the standard convention forced by the absence of subtraction.

**Proposition 2.7 (Hyperplanes are subsemimodules).** If $|E| \ge 2$ then $H(c)$ is a tropical subsemimodule.

*Proof.* $\mathbf{0} \in H(c)$ since all values are $\infty$ and any $j \ne i$ witnesses. For $\oplus$: given $x, y \in H(c)$ and $i$, without loss of generality $x_i \le y_i$, so $\min(x_i,y_i) = x_i$; take the $H(c)$-witness $j$ for $x$ at $i$ and use $c_j + \min(x_j,y_j) \le c_j + x_j \le c_i + x_i = c_i + \min(x_i,y_i)$. For $a \odot (-)$: adding the constant $a$ to both sides of the witness inequality preserves it, because $\mathbb{T}$ is an ordered monoid under $+$. $\square$

---

## 3. Elimination for tropical hyperplanes

Fix a finite $E$ with $|E| \ge 2$ and $c : E \to \mathbb{T}$.

### 3.1 The rigidity lemma

Given $x, y \in H(c)$ and a coordinate $e$, write $m = x \oplus y$, i.e. $m_i = \min(x_i,y_i)$, and define the **truncation**
$$z^0_i = \begin{cases}\infty, & i = e,\\ m_i, & i \ne e.\end{cases}$$

**Lemma 3.1 (Rigidity).** Let $x, y \in H(c)$, let $e$ be a coordinate with $x_e = y_e$, and suppose $i_0 \ne e$ satisfies
$$c_{i_0} + z^0_{i_0} \ <\ c_j + z^0_j \qquad \text{for all } j \ne i_0 .$$
Then $x_{i_0} = y_{i_0}$.

*Proof.* By symmetry assume $x_{i_0} \le y_{i_0}$ and suppose, for contradiction, that $x_{i_0} < y_{i_0}$; then $z^0_{i_0} = m_{i_0} = x_{i_0}$. Write $\alpha = c_{i_0} + x_{i_0} = c_{i_0} + z^0_{i_0}$. Taking $j = e$ in the hypothesis gives $\alpha < c_e + \infty = \infty$, so $\alpha$ is finite; in particular $c_{i_0}$ and $x_{i_0}$ are finite.

Observe the following *exclusion principle*: if $j \ne i_0$ and $j \ne e$, then $z^0_j = m_j = \min(x_j,y_j)$, so any inequality of the form $c_j + x_j \le \alpha$ or $c_j + y_j \le \alpha$ would give $c_j + z^0_j \le \alpha = c_{i_0} + z^0_{i_0}$, contradicting strictness at $j$.

Apply the membership condition for $x$ at $i_0$: there is $j \ne i_0$ with $c_j + x_j \le c_{i_0} + x_{i_0} = \alpha$. By the exclusion principle, $j = e$, so
$$c_e + x_e \ \le\ \alpha, \qquad\text{hence}\qquad c_e + y_e \le \alpha \quad (\text{since } x_e = y_e).$$
Now apply the membership condition for $y$ at $e$: there is $j' \ne e$ with $c_{j'} + y_{j'} \le c_e + y_e \le \alpha$. By the exclusion principle again, $j' = i_0$, so
$$c_{i_0} + y_{i_0} \ \le\ \alpha \ =\ c_{i_0} + x_{i_0}.$$
Since $c_{i_0}$ is finite it cancels, giving $y_{i_0} \le x_{i_0}$, contradicting $x_{i_0} < y_{i_0}$. Hence $x_{i_0} = y_{i_0}$. $\square$

The lemma says: *a lonely minimum of the truncated tropical sum can never sit at a coordinate where the two inputs disagree.* This is precisely what licenses the repair in the next proof, since (E3) forbids moving $z$ at coordinates of disagreement.

### 3.2 The main theorem

**Theorem 3.2 (Vector elimination for tropical hyperplanes).** For every $c : E \to \mathbb{T}$ on a finite $E$ with $|E| \ge 2$, the tropical hyperplane $H(c)$ satisfies the vector elimination axiom.

*Proof.* Let $x,y \in H(c)$ and let $e$ satisfy $x_e = y_e \ne \infty$. Form $m = x \oplus y$ and $z^0$ as above. Conditions (E1)–(E3) hold for $z^0$ by construction: $z^0_e = \infty$; $z^0_i \ge m_i$ everywhere; and at any $i$ with $x_i \ne y_i$ we have $i \ne e$ (since $x_e = y_e$), hence $z^0_i = m_i$. So the only issue is membership.

*Case 1: $z^0 \in H(c)$.* Take $z = z^0$; done.

*Case 2: $z^0 \notin H(c)$.* Unwinding Definition 2.5, there is a coordinate $i_0$ with
$$c_{i_0} + z^0_{i_0} \ <\ c_j + z^0_j \qquad \text{for all } j \ne i_0,$$
a strictly unique minimum. First, $i_0 \ne e$: otherwise $c_{i_0} + z^0_{i_0} = c_e + \infty = \infty$ could not be strictly below anything. Hence $z^0_{i_0} = m_{i_0}$, and by Lemma 3.1, $x_{i_0} = y_{i_0}$ — so we are permitted by (E3) to modify $z$ at $i_0$, provided we only move upward.

Let
$$\beta = \min_{j \ne i_0} \big( c_j + z^0_j \big)$$
be the second-smallest adjusted value, attained at some $j_1 \ne i_0$; by strictness $c_{i_0} + z^0_{i_0} < \beta$, so $c_{i_0}$ and $z^0_{i_0}$ are both finite. Because finite tropical scalars are invertible, choose $t \in \mathbb{T}$ with
$$c_{i_0} + t = \beta ;$$
explicitly $t = \beta - c_{i_0}$ if $\beta < \infty$, and $t = \infty$ if $\beta = \infty$. In both cases $t \ge z^0_{i_0}$, since $c_{i_0} + z^0_{i_0} < \beta = c_{i_0} + t$ and $c_{i_0}$ is finite.

Set $z = z^0$ with coordinate $i_0$ replaced by $t$. Then:

* $z \in H(c)$: at $i = i_0$, the coordinate $j_1$ witnesses, since $c_{j_1} + z_{j_1} = \beta = c_{i_0} + t$; at any $i \ne i_0$, the coordinate $i_0$ witnesses, since $c_{i_0} + t = \beta \le c_i + z^0_i = c_i + z_i$ by definition of $\beta$.
* (E1): $i_0 \ne e$, so $z_e = z^0_e = \infty$.
* (E2): at $i_0$ we have $z_{i_0} = t \ge z^0_{i_0} = m_{i_0}$; elsewhere $z_i = z^0_i \ge m_i$.
* (E3): if $x_i \ne y_i$ then $i \ne e$ and, by Lemma 3.1, $i \ne i_0$; hence $z_i = z^0_i = m_i$. $\square$

**Corollary 3.3.** Every tropical hyperplane $H(c)$ on a finite ground set with $|E| \ge 2$ is a tropical linear space.

*Proof.* Combine Proposition 2.7 and Theorem 3.2. $\square$

The proof is constructive and yields Algorithm A of Section 8: compute the truncation, test membership, and if a lonely minimum exists, raise it to the level of the runner-up.

---

## 4. Operations, and sharpness of the axiom

### 4.1 Operations that preserve tropical linear spaces

**Definition 4.1 (Rescaling).** For $a : E \to \mathbb{T}$ and $V \subseteq \mathbb{T}^E$, let $a \cdot V = \{\, (a_i + x_i)_i : x \in V \,\}$.

**Theorem 4.2 (Tropical diagonal automorphisms).** If $a_i \ne \infty$ for all $i$ and $V$ is a tropical linear space, then $a \cdot V$ is a tropical linear space.

*Proof sketch.* Subsemimodule closure is immediate from $a_i + \min(u,v) = \min(a_i+u, a_i+v)$ and commutativity. For elimination: given $a\cdot x, a\cdot y \in a\cdot V$ agreeing at $e$ with finite value, finiteness of $a_e$ gives $x_e = y_e$ and $x_e \ne \infty$; apply elimination in $V$ to get $z$, and check that $a \cdot z$ satisfies (E1)–(E3), again using that adding a finite constant commutes with $\min$ and preserves both $\le$ and $\ne$. $\square$

**Definition 4.3 (Deletion).** For $S \subseteq E$,
$$V \setminus (E\setminus S) \ =\ \{\, x \in \mathbb{T}^S \ :\ \exists\, x' \in V,\ x'|_S = x \text{ and } x'_i = \infty \ \forall i \notin S \,\}.$$

**Theorem 4.4 (Deletion preserves tropical linear spaces).** If $V$ is a tropical linear space then so is its deletion to any $S \subseteq E$.

*Proof sketch.* Closure is by lifting representatives and applying the operations in $V$; the lifts remain $\infty$ outside $S$. For elimination, lift $x,y$ to $x',y'$, apply elimination in $V$ at $e \in S$ to obtain $z'$, and observe that $z'$ is automatically $\infty$ outside $S$: at such $i$, $x'_i = y'_i = \infty$, so (E2) gives $z'_i \ge \min(\infty,\infty) = \infty$. Restricting $z'$ to $S$ gives the required witness, with (E1)–(E3) inherited coordinatewise. $\square$

These are the two elementary minor operations of matroid theory, so the class of tropical linear spaces is closed under minors of this kind.

### 4.2 Intersections can fail elimination

**Theorem 4.5 (Sharpness).** Tropical linear spaces are not closed under set-theoretic intersection. Explicitly, on $E = \{1,2,3,4\}$ let
$$c^{(1)} = (0,0,0,0), \qquad c^{(2)} = (0,0,0,1).$$
Then $H(c^{(1)}) \cap H(c^{(2)})$ is a tropical subsemimodule that **fails** the vector elimination axiom.

*Proof.* That the intersection is a subsemimodule is immediate from Proposition 2.7 applied to each factor.

Consider
$$x = (0,0,1,0), \qquad y = (0,0,1,1).$$
Both lie in the intersection. For $x$ and $c^{(1)}$ the adjusted values are $(0,0,1,0)$, minimum $0$ attained at coordinates $1,2,4$; for $x$ and $c^{(2)}$ they are $(0,0,1,1)$, minimum $0$ attained at $1,2$. For $y$ and $c^{(1)}$ they are $(0,0,1,1)$, minimum attained at $1,2$; for $y$ and $c^{(2)}$ they are $(0,0,1,2)$, minimum attained at $1,2$. So $x, y \in H(c^{(1)}) \cap H(c^{(2)})$.

They agree at $e = 1$ with the finite value $0$. Suppose $z$ satisfied (E1)–(E3). Then:

* $z_1 = \infty$ by (E1);
* $x_4 = 0 \ne 1 = y_4$, so (E3) pins $z_4 = \min(0,1) = 0$;
* (E2) gives $z_2 \ge \min(0,0) = 0$ and $z_3 \ge \min(1,1) = 1$.

Apply membership in $H(c^{(1)})$ at coordinate $4$: some $j \ne 4$ has $z_j \le z_4 = 0$. Coordinate $1$ gives $\infty$, coordinate $3$ gives $\ge 1$; hence $j = 2$ and $z_2 \le 0$, so $z_2 = 0$.

Now apply membership in $H(c^{(2)})$ at coordinate $2$: some $k \ne 2$ has $c^{(2)}_k + z_k \le c^{(2)}_2 + z_2 = 0$. The options are $k=1$ with value $\infty$; $k=3$ with value $\ge 1$; $k=4$ with value $1 + 0 = 1$. All exceed $0$ — contradiction. No such $z$ exists. $\square$

Two consequences. First, elimination is *not* a formal consequence of the semimodule axioms — the intersection above is closed under $\oplus$ and rescaling, yet fails. Second, this is the structural reason tropical geometry prefers **stable intersection**: perturbing $c^{(2)}$ generically and passing to the limit destroys exactly the non-transverse coincidence of minima (here, that both $c^{(1)}$-minima and $c^{(2)}$-minima cluster at coordinates $1,2$) responsible for the failure.

---

## 5. From tropical algebra to matroids

Assume $E$ finite.

### 5.1 Support elimination

**Theorem 5.1 (Minty elimination on supports).** Let $V$ be a tropical linear space, $x, y \in V$, and $e \in \operatorname{supp}(x) \cap \operatorname{supp}(y)$. Then there is $z \in V$ with
$$\operatorname{supp}(z) \ \subseteq\ \big(\operatorname{supp}(x) \cup \operatorname{supp}(y)\big) \setminus \{e\}.$$

*Proof.* Write $x_e = p$ and $y_e = r$, both finite. Rescale: $y' = (p - r) \odot y \in V$ has $y'_e = p = x_e \ne \infty$. Apply elimination to $x, y'$ at $e$ to obtain $z \in V$ with $z_e = \infty$ and $z_i \ge \min(x_i, y'_i)$. If $i \notin \operatorname{supp}(x) \cup \operatorname{supp}(y)$ then $x_i = y_i = \infty$, hence $y'_i = \infty$ and $z_i \ge \infty$, i.e. $i \notin \operatorname{supp}(z)$. Also $e \notin \operatorname{supp}(z)$. $\square$

**Theorem 5.2 (Nonvanishing refinement).** In the situation of Theorem 5.1, suppose additionally that some $f$ satisfies $x_f \ne \infty$ and $y_f = \infty$. Then the eliminated $z$ can be chosen nonzero, with $f \in \operatorname{supp}(z)$, $z_e = \infty$, and $\operatorname{supp}(z) \subseteq (\operatorname{supp}(x)\cup\operatorname{supp}(y))\setminus\{e\}$.

*Proof sketch.* With $y'$ as above, $y'_f = \infty \ne x_f$, so $x$ and $y'$ *disagree* at $f$; clause (E3) then pins $z_f = \min(x_f, \infty) = x_f \ne \infty$. $\square$

### 5.2 Circuits

**Definition 5.3.** A finset $C \subseteq E$ is a **circuit** of $V$ if $C = \operatorname{supp}(x)$ for some nonzero $x \in V$, and $C$ is minimal with this property: every nonzero $y \in V$ with $\operatorname{supp}(y) \subseteq C$ has $\operatorname{supp}(y) = C$.

**Lemma 5.4 (Existence).** Every nonzero $x \in V$ has a circuit inside its support.

*Proof.* Among nonzero members of $V$ whose support is contained in $\operatorname{supp}(x)$, choose one, $y$, of minimum support cardinality (possible since cardinalities are naturals). Then $\operatorname{supp}(y)$ is a circuit: any nonzero $z \in V$ with $\operatorname{supp}(z) \subseteq \operatorname{supp}(y)$ has support of cardinality at least that of $y$, and a subset of equal cardinality is equal. $\square$

**Theorem 5.5 (Circuit elimination).** Let $V$ be a tropical linear space on a finite ground set, $C_1 \ne C_2$ circuits, and $e \in C_1 \cap C_2$. Then there is a circuit $C_3$ with
$$C_3 \ \subseteq\ (C_1 \cup C_2)\setminus\{e\}.$$
Hence the circuits of $V$ are the circuits of a matroid on $E$.

*Proof.* Choose nonzero $x, y \in V$ with $\operatorname{supp}(x) = C_1$, $\operatorname{supp}(y) = C_2$. Since $C_1 \ne C_2$ and $C_2$ is minimal, $C_1 \not\subseteq C_2$: otherwise minimality of $C_2$ applied to $x$ would give $C_1 = C_2$. Pick $f \in C_1 \setminus C_2$; then $x_f \ne \infty$ and $y_f = \infty$. Apply Theorem 5.2 to obtain a nonzero $z \in V$ with $\operatorname{supp}(z) \subseteq (C_1 \cup C_2)\setminus\{e\}$, and apply Lemma 5.4 to $z$. $\square$

### 5.3 The matroid of a hyperplane is uniform

**Theorem 5.6 (No loops).** Let $c : E \to \mathbb{T}$ with all $c_i$ finite, $E$ finite nonempty. Every nonzero $x \in H(c)$ has at least two finite coordinates.

*Proof.* Let $i$ minimize $k \mapsto c_k + x_k$. Since $x \ne \mathbf{0}$ some $x_k$ is finite, and $c_k$ is finite, so the minimum value $c_i + x_i$ is finite; hence $x_i \ne \infty$. The membership condition at $i$ gives $j \ne i$ with $c_j + x_j \le c_i + x_i < \infty$, so $x_j \ne \infty$. $\square$

**Theorem 5.7 (Every pair occurs).** With $c$ as above and $i \ne j$, the vector
$$x_i = -c_i, \qquad x_j = -c_j, \qquad x_k = \infty \ (k \ne i,j)$$
lies in $H(c)$ and has $\operatorname{supp}(x) = \{i,j\}$.

*Proof.* The adjusted values are $c_i + x_i = 0 = c_j + x_j$ and $\infty$ elsewhere, so the minimum $0$ is attained twice; Proposition 2.6 applies. $\square$

**Theorem 5.8 (Uniform matroid).** For $c$ with all coefficients finite on a finite ground set $E$ with $|E| = n \ge 2$, a subset $C \subseteq E$ is a circuit of $H(c)$ if and only if $|C| = 2$. The underlying matroid of $H(c)$ is the uniform matroid $U_{n-1,n}$.

*Proof.* ($\Leftarrow$) By Theorem 5.7 a pair is a support; by Theorem 5.6 no nonzero member has support of size $\le 1$, so the pair is minimal. ($\Rightarrow$) Let $C$ be a circuit. By Theorem 5.6 and Lemma 5.4, $|C| \ge 2$; choose distinct $i,j \in C$ and let $x$ be the vector of Theorem 5.7. Then $x$ is a nonzero member with $\operatorname{supp}(x) = \{i,j\} \subseteq C$, so minimality forces $C = \{i,j\}$, of cardinality $2$. $\square$

So a tropical hyperplane sees only the crudest possible matroid: any $n-1$ coordinates are independent, and dependence begins at pairs. All finer information about $H(c)$ lives in the *valuation* — the numerical data — not in the support combinatorics.

---

## 6. The vanishing ideal of a point is a tropical ideal

We now leave linear algebra for polynomials. Let $\sigma$ be a nonempty set of variables, and let
$$R = \mathrm{MvPoly}\big(\sigma,\ \mathbb{T}\big)$$
denote the semiring of polynomials in the variables $\sigma$ with coefficients in the tropical semiring: formally, finitely supported functions from exponent vectors $u \in \mathbb{N}^{(\sigma)}$ to $\mathbb{T}$, with $\oplus$ coefficientwise minimum and multiplication the tropical convolution
$$\mathrm{coeff}_v(fg) \ =\ \min_{p+q=v} \big(\mathrm{coeff}_p(f) + \mathrm{coeff}_q(g)\big).$$

**Definition 6.1 (Evaluation and vanishing).** For a point $w : \sigma \to \mathbb{Q}$ put $\langle u,w\rangle = \sum_i u_i w_i$ and define the **term value**
$$\operatorname{val}_u(f) \ =\ \mathrm{coeff}_u(f) \ +\ \langle u, w \rangle \ \in \mathbb{T}.$$
Say $f$ **vanishes at $w$** if
$$\forall u \ \exists u' \ne u : \quad \operatorname{val}_{u'}(f) \ \le\ \operatorname{val}_u(f).$$

As in Proposition 2.6, over any finite monomial set this says the minimum of $u \mapsto \operatorname{val}_u(f)$ is attained at least twice (or all values are $\infty$). Let $I_w = \{ f \in R : f \text{ vanishes at } w \}$.

**Lemma 6.2 (Values of sums).** $\operatorname{val}_u(f \oplus g) = \min(\operatorname{val}_u f, \operatorname{val}_u g)$.

*Proof.* Coefficients of $f \oplus g$ are coordinatewise minima and $\min(a,b) + t = \min(a+t, b+t)$. $\square$

**Proposition 6.3 (Closure under $\oplus$).** If $f,g \in I_w$ then $f \oplus g \in I_w$.

*Proof.* Fix $u$; by symmetry assume $\operatorname{val}_u f \le \operatorname{val}_u g$, so $\operatorname{val}_u(f\oplus g) = \operatorname{val}_u f$. Take the vanishing witness $u'$ for $f$ at $u$: then $\operatorname{val}_{u'}(f\oplus g) \le \operatorname{val}_{u'} f \le \operatorname{val}_u f = \operatorname{val}_u(f \oplus g)$. $\square$

**Lemma 6.4 (Values of products).** $\displaystyle \operatorname{val}_v(fg) = \min_{p + q = v}\big( \operatorname{val}_p f + \operatorname{val}_q g \big)$.

*Proof.* Expand the convolution and use $\langle p+q, w\rangle = \langle p,w\rangle + \langle q,w\rangle$, then regroup: $(\mathrm{coeff}_p f + \mathrm{coeff}_q g) + \langle p+q,w\rangle = \operatorname{val}_p f + \operatorname{val}_q g$; adding the constant $\langle v,w\rangle$ commutes with the minimum. $\square$

**Theorem 6.5 (Closure under multiplication).** If $f \in I_w$ then $fg \in I_w$ for every $g \in R$.

*Proof.* If $f = 0$ or $g = 0$ the product is $0$, which vanishes (any two distinct exponents witness, using that $\sigma$ is nonempty so exponents are not unique). Otherwise choose $a$ minimizing $\operatorname{val}(f)$ over the support of $f$ — a global minimizer, since off-support terms have value $\infty$ — and $b$ minimizing $\operatorname{val}(g)$. Since $f$ vanishes at $w$, its witness at $a$ is some $a' \ne a$ with $\operatorname{val}_{a'} f \le \operatorname{val}_a f$; minimality forces equality, so $a'$ is a *second* global minimizer.

Put $M = \operatorname{val}_a f + \operatorname{val}_b g$. By Lemma 6.4 every term of $fg$ satisfies $\operatorname{val}_v(fg) \ge M$, since each summand $\operatorname{val}_p f + \operatorname{val}_q g \ge M$. Also, for any global minimizer $c$ of $\operatorname{val}(f)$, the pair $(c,b)$ occurs in the convolution for $v = c + b$, so $\operatorname{val}_{c+b}(fg) \le \operatorname{val}_c f + \operatorname{val}_b g = M$, whence $\operatorname{val}_{c+b}(fg) = M$. Applying this to $c = a$ and $c = a'$ gives two exponents $a + b \ne a' + b$ (exponent addition is cancellative) at which $fg$ attains its global minimum $M$.

Now fix any $v$. If $v = a+b$, the witness is $a' + b$; if $v = a'+b$, the witness is $a+b$; otherwise either works. In each case the witness is distinct from $v$ and has value $M \le \operatorname{val}_v(fg)$. $\square$

**Corollary 6.6.** $I_w$ is an ideal of the tropical polynomial semiring: it contains $0$ and is closed under $\oplus$ and under multiplication by arbitrary polynomials.

### 6.1 Truncations are hyperplanes

Fix a finite set $E$ of exponents with $|E| \ge 2$. For $f \in R$ let $\mathrm{cv}_E(f) = (\mathrm{coeff}_u f)_{u \in E} \in \mathbb{T}^E$, and let $\pi_w \in \mathbb{T}^E$ be the **evaluation weight vector** $\pi_w(u) = \langle u, w\rangle$ (always finite). Note $\pi_w(u) + \mathrm{cv}_E(f)(u) = \operatorname{val}_u(f)$.

**Definition 6.7 (Truncation).** $\ \mathrm{Tr}_E(I_w) = \{\, \mathrm{cv}_E(f) \ :\ f \in I_w,\ \operatorname{supp}(f) \subseteq E \,\} \subseteq \mathbb{T}^E$.

**Theorem 6.8 (Truncation is exactly a tropical hyperplane).** For $|E| \ge 2$,
$$\mathrm{Tr}_E(I_w) \ =\ H(\pi_w).$$

*Proof.* ($\subseteq$) Let $f \in I_w$ with $\operatorname{supp}(f) \subseteq E$ and let $u \in E$. Take a vanishing witness $u'$ for $f$ at $u$. If $u' \in E$ it is a legitimate witness for $\mathrm{cv}_E(f)$ inside $H(\pi_w)$, by the displayed identity. If $u' \notin E$ then $\mathrm{coeff}_{u'} f = \infty$ (the support lies in $E$), so $\operatorname{val}_{u'} f = \infty$; but $\operatorname{val}_{u'} f \le \operatorname{val}_u f$ forces $\operatorname{val}_u f = \infty$ as well, and then *any* other element of $E$ — one exists, as $|E| \ge 2$ — is a witness.

($\supseteq$) Given $x \in H(\pi_w)$, define $f$ by $\mathrm{coeff}_u f = x_u$ for $u \in E$ and $\infty$ otherwise. Its support lies in $E$ and $\mathrm{cv}_E(f) = x$. To see $f$ vanishes at $w$: for $u \in E$ the $H(\pi_w)$-witness works; for $u \notin E$ the value $\operatorname{val}_u f = \infty$ and any element of $E$ is a witness. $\square$

**Theorem 6.9 (The vanishing ideal is a tropical ideal).** For every finite $E$ with $|E| \ge 2$, the truncation $\mathrm{Tr}_E(I_w)$ is a tropical linear space. Hence $I_w$ is a tropical ideal in the Maclagan–Rincón sense.

*Proof.* Combine Theorem 6.8 with Corollary 3.3. $\square$

**Theorem 6.10 (Degreewise elimination for polynomials).** Let $|E| \ge 2$, let $f, g \in I_w$ have support inside $E$, and let $e \in E$ be a monomial with
$$\mathrm{coeff}_e(f) = \mathrm{coeff}_e(g) \ne \infty .$$
Then there exists $h \in I_w$ with support inside $E$ such that

* $\mathrm{coeff}_e(h) = \infty$ (the monomial $e$ has been eliminated),
* $\mathrm{coeff}_u(h) \ge \min(\mathrm{coeff}_u f, \mathrm{coeff}_u g)$ for all $u \in E$,
* $\mathrm{coeff}_u(h) = \min(\mathrm{coeff}_u f, \mathrm{coeff}_u g)$ for every $u$ where the two coefficients differ.

*Proof.* Transport to $\mathbb{T}^E$ by Theorem 6.8, apply Theorem 3.2 to $H(\pi_w)$, and transport back using the surjectivity established in the ($\supseteq$) direction of Theorem 6.8. $\square$

**Theorem 6.11 (Uniform matroid in every degree).** For $|E| \ge 2$, a set $C$ of monomials in $E$ is a circuit of $\mathrm{Tr}_E(I_w)$ if and only if $|C| = 2$. In particular circuits exist, and the degreewise matroid of the vanishing ideal of a point is the uniform matroid $U_{|E|-1,|E|}$.

*Proof.* By Theorem 6.8 the truncation is $H(\pi_w)$, whose coefficients $\pi_w(u) = \langle u, w\rangle$ are all finite; apply Theorem 5.8. $\square$

Theorem 6.11 is the sharp base case for comparison: the vanishing ideal of *one* point is combinatorially as generic as possible, so any tropical ideal with more interesting support combinatorics must have strictly fewer circuits in some degree.

---

## 7. Tropical Gröbner theory on the point ideal

Tropical ideals support a Gröbner theory relative to a finite *test set* of polynomials. Fix a monomial order $m$ on exponents, a finite set $U \subseteq R$ of tropical polynomials, and a tropical ideal $I$. A finite family $G \subseteq U$ of elements of $I$ is a **Gröbner basis of $I$ on $U$** when it is saturated for the completion operation: no element of $I \cap U$ remains that the tropical division/reduction process against $G$ fails to handle. The **completion step** $B(G)$ enlarges $G$ by such a witness when one exists, and returns $G$ unchanged otherwise.

**Theorem 7.1 (Fixed-point characterization).** For $G \subseteq U$ consisting of polynomials vanishing at $w$,
$$G \text{ is a Gröbner basis of } I_w \text{ on } U \iff B(G) = G .$$

**Theorem 7.2 (Termination of completion on the point ideal).** Let $G_0 \subseteq U$ consist of polynomials vanishing at $w$. Then there is $n \le |U|$ such that the $n$-fold iterate $B^n(G_0)$ is a Gröbner basis of $I_w$ on $U$.

*Proof sketch.* By Theorem 7.1 the iteration stops precisely at a fixed point. Every non-fixed step strictly enlarges $G$ while keeping it inside the finite set $U$, so at most $|U|$ steps can occur; the first non-strict step is a fixed point. $\square$

The content of Theorems 7.1–7.2 is that the vanishing ideal of a point is a *bona fide* input to the tropical Buchberger machinery. Theorem 6.5 supplies membership closure under multiplication (so the family really is an ideal), Theorem 6.9 supplies the matroidal condition that makes reduction well-behaved degreewise, and Theorem 6.10 is the elimination step that a reduction performs.

---

## 8. Algorithms

**Algorithm A — Constructive elimination witness for a tropical hyperplane.** Input $c, x, y \in \mathbb{T}^E$ with $x, y \in H(c)$ and $x_e = y_e \ne \infty$; output $z \in H(c)$ satisfying (E1)–(E3).
1. $m_i \leftarrow \min(x_i,y_i)$; $z_i \leftarrow m_i$ for $i \ne e$, $z_e \leftarrow \infty$.
2. If $z \in H(c)$ (test: the minimum of $c_i + z_i$ is attained at least twice), return $z$.
3. Otherwise let $i_0$ be the unique strict minimizer of $c_i + z_i$ and $\beta \leftarrow \min_{j \ne i_0}(c_j + z_j)$.
4. $z_{i_0} \leftarrow \beta - c_{i_0}$ (with $\infty$ if $\beta = \infty$); return $z$.

Complexity: $O(n)$ arithmetic operations on $n = |E|$ coordinates. Correctness is Theorem 3.2; the key point is that step 4 only raises $z_{i_0}$, and Lemma 3.1 guarantees $i_0$ is a coordinate where $x$ and $y$ agree, so (E3) is not violated.

**Algorithm B — Circuit enumeration for a hyperplane.** For $c$ with all coordinates finite, output all $\binom{n}{2}$ pairs, each realized by the explicit vector of Theorem 5.7. Complexity $O(n^2)$ output-size-optimal; correctness is Theorem 5.8.

**Algorithm C — Tropical vanishing test at a point.** Given a polynomial as a finite map $u \mapsto \mathrm{coeff}_u$ and a point $w$: compute $\operatorname{val}_u = \mathrm{coeff}_u + \langle u,w\rangle$ over the support, and report vanishing iff the minimum value is attained at least twice, or the support is empty (or the value pattern is entirely $\infty$). Complexity $O(|{\operatorname{supp}}| \cdot |\sigma|)$.

**Algorithm D — Product witness construction.** Given $f$ vanishing at $w$ and arbitrary $g$, return the two exponents $a+b$, $a'+b$ realizing the minimum of $fg$, where $a,a'$ are two distinct minimizers of $\operatorname{val}(f)$ and $b$ any minimizer of $\operatorname{val}(g)$. This is a certificate for Theorem 6.5 and runs in $O(|\operatorname{supp} f| + |\operatorname{supp} g|)$ after value computation.

**Algorithm E — Buchberger completion driver.** Iterate the completion step on a family $G \subseteq U$; stop at the first fixed point. By Theorem 7.2 at most $|U|$ iterations occur.

---

## 9. Discussion

The results assemble into a single narrative. The elimination axiom is what makes a subsemimodule scheme-like; it holds for the basic building blocks (Theorem 3.2), it is not automatic (Theorem 4.5), it is stable under the elementary minor operations (Theorems 4.2, 4.4), it implies genuine matroid structure (Theorem 5.5), and it holds in every degree for a concrete, geometrically meaningful ideal (Theorem 6.9).

Two features deserve emphasis.

*The rigidity lemma is the crux.* One might hope that elimination is a soft consequence of closure properties, with $x \oplus y$ truncated at $e$ always doing the job. It is not: truncation destroys ties. What saves the situation is that the destroyed tie can only ever occur at a coordinate where the two inputs *agree*, which is exactly the set of coordinates the axiom leaves free. The counterexample of Theorem 4.5 shows the analogous freedom is unavailable for intersections, where two independent tie conditions must be met simultaneously.

*Support combinatorics is coarse; valuation is fine.* Theorems 5.8 and 6.11 say that the underlying matroid of a hyperplane, and hence of the vanishing ideal of a single point in every degree, is uniform. All the geometry is carried by the valuation, not by the support. This makes the uniform case the correct null hypothesis against which richer tropical ideals should be measured.

---

## 10. Future directions

The following are the concrete next steps, in decreasing order of expected impact.

### C1. Stable intersection repairs elimination

**Conjecture.** For coefficient vectors $c_1, c_2$ on a finite ground set $E$, the *stable* intersection $H(c_1) \cap_{\mathrm{st}} H(c_2)$, defined as the set of limits $\lim_{t \to 0} \big(H(c_1) \cap H(c_2 + t\,v)\big)$ along a generic perturbation direction $v$, satisfies the vector elimination axiom, even though the set-theoretic intersection does not.

*The key insight is* that the failure exhibited here is caused by a non-transverse coincidence of two tropical minima, and perturbing one hyperplane destroys precisely that coincidence while leaving the explicit elimination witnesses constructed in Theorem 3.2 intact.

*Why now?* The framework — tropical linear spaces, the explicit witness construction, and a verified counterexample delimiting the truth — is in place, so the conjecture is a statement about one extra limit operation rather than about an untested definition.

### C2. Every tropical linear space is a hyperplane intersection minor

**Conjecture.** Every tropical linear space $V \subseteq \mathbb{T}^E$ on a finite ground set is obtained from a finite family of tropical hyperplanes by *stable* intersection followed by deletion; equivalently, the operations proved here to preserve tropical linear spaces (rescaling and deletion) together with stable intersection generate the whole class from hyperplanes.

*The key insight is* that the circuits of $V$ — now available as a formal object, with circuit elimination proved — each cut out a hyperplane containing $V$, and the circuit elimination axiom is exactly the compatibility needed to reassemble $V$ from those hyperplanes.

*Why now?* Circuit elimination and the existence of circuits inside any nonzero member supply the combinatorial skeleton; what remains is a purely constructive reassembly step.

### C3. Degreewise matroids of tropical ideals are non-uniform in general

**Conjecture.** There is a point-free tropical ideal — for instance the vanishing ideal of two distinct points, or the tropicalization of a curve — whose degree-$d$ truncation has a matroid that is *not* uniform for $d$ large enough, in contrast with the uniform answer obtained here for a single point. Concretely, the number of circuits of the degree-$d$ truncation grows strictly slower than $\binom{N_d}{2}$, where $N_d$ is the number of monomials of degree at most $d$.

*The key insight is* that a single point imposes one tropical linear condition per degree, which is exactly a hyperplane and hence uniform; two points impose two conditions whose interaction is the very phenomenon that broke elimination for set-theoretic intersections, so the support combinatorics should genuinely thin out.

*Why now?* The uniform base case is settled, and the counterexample of Theorem 4.5 identifies the exact mechanism by which two conditions interact non-generically.

---

## 11. Conclusion

Tropical geometry replaces subtraction by an axiom, and the axiom is matroidal. We have shown that tropical hyperplanes satisfy the vector elimination axiom, via a rigidity lemma asserting that a lonely minimum can only occur where the two inputs agree; that the axiom is genuinely stronger than semimodule closure, via an explicit four-coordinate intersection that fails it; that the axiom is preserved by tropical rescaling and deletion; that it descends to the matroid circuit elimination axiom, with hyperplanes realizing uniform matroids; and that the vanishing ideal of a rational point is an honest ideal of the tropical polynomial semiring whose every finite-monomial truncation is exactly a tropical hyperplane — hence a tropical ideal with uniform degreewise matroid, on which terminating Buchberger completion is available.

The next frontier is stable intersection: the operation that, conjecturally, repairs the one failure identified here and closes the class of tropical linear spaces under the intersections that geometry demands.
