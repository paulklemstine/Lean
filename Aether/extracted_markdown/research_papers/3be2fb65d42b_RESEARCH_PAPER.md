# Generation Certificates for Matrix Groups: Irreducible Characteristic Polynomials as Structural Certificates of Irreducible Action

## Abstract

We develop a certificate-based framework linking an easily computable algebraic invariant — the irreducibility of the characteristic polynomial of a linear endomorphism — to a sweeping structural property of its action: the absence of nontrivial invariant subspaces. The central result, the **Irreducible Action Theorem**, states that if a finite-dimensional endomorphism $\varphi$ over a field $K$ has irreducible characteristic polynomial $\chi_\varphi$, then every $\varphi$-invariant submodule is either $\{0\}$ or the whole space. From this single theorem we derive three corollaries spanning distinct mathematical domains: an **Orbit Spanning Theorem** (the cyclic orbit of any nonzero vector spans the space — a bridge to coding theory and linear feedback shift registers), a **finite-geometry theorem** that such an endomorphism fixes no proper nonzero projective flat (the Singer-cycle property), and a **specialization** to prime fields $\mathbb{Z}/p\mathbb{Z}$ relevant to computational group theory. We further formalize an abstract notion of a **generation certificate system** and **certificate density**, and prove a positivity lower bound that anchors probabilistic generation arguments for finite linear groups. We close with two precise conjectures on certificate density and generation sufficiency in $\mathrm{GL}_n(\mathbb{F}_q)$. All theorems stated here have been verified in a formal proof assistant and depend only on the standard foundational axioms (propositional extensionality, the axiom of choice, and quotient soundness).

**Keywords:** characteristic polynomial, irreducibility, invariant subspace, minimal polynomial, Cayley–Hamilton, Singer cycle, finite geometry, matrix group generation, computational group theory, cyclic codes.

---

## 1. Introduction

A recurring theme in algebra and its applications is the reduction of a structural, geometric, or group-theoretic property to a *checkable algebraic certificate*. The prototype is the use of determinants to certify invertibility. This paper studies a less elementary but equally powerful instance: the use of **irreducibility of the characteristic polynomial** to certify that a linear map acts **irreducibly** — that it admits no nontrivial invariant subspace.

The motivation is twofold.

First, the *structural* side. Irreducibility of a linear action is the indecomposability condition underlying the entire representation theory of a single operator. Detecting it directly appears to require quantifying over all subspaces, of which there are infinitely many over an infinite field and exponentially many over a finite one. The characteristic polynomial converts this into a finite algebraic test.

Second, the *computational* side. In computational group theory one studies enormous finite linear groups such as $\mathrm{GL}_n(\mathbb{F}_q)$ — far too large to enumerate — by *random generation*: drawing a small number of random elements and arguing that, with high probability, they generate the whole group. The Dixon-style program (Dixon 1969; Neumann–Praeger 1992) shows that such arguments hinge on identifying elements with strong structural properties. An element whose characteristic polynomial is irreducible — a *Singer-type element* — acts irreducibly and hence cannot lie in any reducible (block-triangular) maximal subgroup. This makes irreducibility a natural **generation certificate**.

Our contribution is a clean, self-contained, formally verified development of this circle of ideas: the main theorem, its three domain-spanning corollaries, the abstract certificate apparatus with a density positivity bound, the prime-field specialization, and two sharply stated conjectures.

### 1.1 Standing conventions

Throughout, $K$ is a field and $V$ is a finite-dimensional $K$-vector space; we write $n = \dim_K V$. An *endomorphism* $\varphi$ is a $K$-linear map $V \to V$, i.e. $\varphi \in \operatorname{End}_K(V)$. We write $\chi_\varphi \in K[X]$ for its characteristic polynomial (monic, of degree $n$) and $m_\varphi \in K[X]$ for its minimal polynomial. For $p \in K[X]$, $p(\varphi)$ denotes the evaluation of $p$ at $\varphi$ (the image under the $K$-algebra map $K[X] \to \operatorname{End}_K(V)$, $X \mapsto \varphi$).

---

## 2. Definitions

**Definition 2.1 (Invariant submodule).**
A submodule $W \le V$ is **$\varphi$-invariant** if $\varphi(W) \subseteq W$, i.e.
$$
\forall w \in W,\quad \varphi(w) \in W.
$$
Invariant submodules are exactly the $K[X]$-submodules of $V$ under the module structure in which $X$ acts as $\varphi$.

**Definition 2.2 (Restriction to an invariant submodule).**
If $W$ is $\varphi$-invariant, the **restriction** $\varphi|_W \in \operatorname{End}_K(W)$ is the unique linear map satisfying $\iota_W \circ \varphi|_W = \varphi \circ \iota_W$, where $\iota_W : W \hookrightarrow V$ is the inclusion. Concretely, $\varphi|_W(w) = \varphi(w)$, viewed as an element of $W$.

**Definition 2.3 (Linear generation certificate).**
A **linear generation certificate** for $(K, V)$ (with $V$ free and finite over $K$) is a triple consisting of an endomorphism $\varphi \in \operatorname{End}_K(V)$ together with proofs that

1. $\varphi$ is bijective (invertible), and
2. $\chi_\varphi$ is irreducible in $K[X]$.

This is the matrix-group analogue of a symmetric-group generation certificate: it isolates elements whose algebraic structure guarantees usefulness for generation.

**Definition 2.4 (Certificate density).**
Let $G$ be a finite group and $C : G \to \mathrm{Prop}$ a decidable predicate. The **certificate density** of $C$ is the rational number
$$
\delta(C) \;=\; \frac{\#\{g \in G : C(g)\}}{\#\,G} \;\in\; \mathbb{Q}.
$$

**Definition 2.5 (Generation certificate system).**
A **generation certificate system** on a group $G$ is a predicate $\mathrm{Cert} : G \to \mathrm{Prop}$ together with the guarantee that every certified element generates a large subgroup when completed by a generic second element: for all $g$ with $\mathrm{Cert}(g)$ and every subgroup $H \le G$ containing $g$, either $H = G$ or $[\,G : H\,] \le 2$. This abstracts the common pattern shared by symmetric-group and linear-group certificates.

---

## 3. Main results

### 3.1 The Irreducible Action Theorem

**Theorem 3.1 (Irreducible Action Theorem).**
Let $V$ be a finite-dimensional $K$-vector space and $\varphi \in \operatorname{End}_K(V)$. If $\chi_\varphi$ is irreducible in $K[X]$, then every $\varphi$-invariant submodule $W \le V$ satisfies
$$
W = \{0\} \quad\text{or}\quad W = V.
$$

This is the structural heart of the framework. We give the proof in full because every corollary descends from it.

*Proof.* Let $W$ be $\varphi$-invariant and suppose $W \neq \{0\}$; we show $W = V$.

**Step 1 — Restriction inherits annihilators.** The inclusion $\iota_W : W \hookrightarrow V$ intertwines $\varphi|_W$ and $\varphi$:
$$
\iota_W \circ \varphi|_W = \varphi \circ \iota_W. \tag{3.1}
$$
By induction on $k$, $\iota_W \circ (\varphi|_W)^k = \varphi^k \circ \iota_W$, and by $K$-linearity this extends to any polynomial: for every $p \in K[X]$,
$$
\iota_W \circ p(\varphi|_W) = p(\varphi) \circ \iota_W. \tag{3.2}
$$
Consequently, if $p(\varphi) = 0$ then $p(\varphi)\circ \iota_W = 0$, hence $\iota_W \circ p(\varphi|_W) = 0$; since $\iota_W$ is injective, $p(\varphi|_W) = 0$. **In words: every polynomial annihilating $\varphi$ also annihilates $\varphi|_W$.**

**Step 2 — Minimal polynomials divide.** Applying Step 1 to $p = m_\varphi$ (which annihilates $\varphi$) gives $m_\varphi(\varphi|_W) = 0$, so by minimality $m_{\varphi|_W} \mid m_\varphi$. Combined with the universal divisibility $m_\varphi \mid \chi_\varphi$, we obtain
$$
m_{\varphi|_W} \;\bigm|\; \chi_\varphi. \tag{3.3}
$$

**Step 3 — The minimal polynomial of the restriction is nonconstant.** Because $W \neq \{0\}$, pick $0 \neq w_0 \in W$. If $m_{\varphi|_W}$ were a unit (degree $0$), then $m_{\varphi|_W}(\varphi|_W) = 0$ would force a nonzero scalar to act as $0$ on $w_0$, a contradiction. Hence $m_{\varphi|_W}$ is not a unit.

**Step 4 — Irreducibility forces equality of degrees.** $\chi_\varphi$ is irreducible, so its only divisors up to units are units and associates of $\chi_\varphi$. By (3.3) and Step 3, $m_{\varphi|_W}$ is an associate of $\chi_\varphi$; both are monic, so
$$
m_{\varphi|_W} = \chi_\varphi, \qquad \deg m_{\varphi|_W} = \deg \chi_\varphi = n. \tag{3.4}
$$

**Step 5 — Dimension count.** For any endomorphism on a finite-dimensional space, $\deg m \le \deg \chi = \dim$. Applied to $\varphi|_W$: $\deg m_{\varphi|_W} \le \dim_K W$. With (3.4),
$$
n = \deg m_{\varphi|_W} \le \dim_K W \le \dim_K V = n,
$$
hence $\dim_K W = \dim_K V$, and a subspace of full dimension equals the whole space: $W = V$. $\qquad\blacksquare$

**Remark 3.2.** The hypotheses are minimal: only finite-dimensionality and irreducibility of $\chi_\varphi$ are used. No assumption of invertibility of $\varphi$ is needed for Theorem 3.1 (invertibility enters only in the certificate bundle of Definition 2.3, where it ensures the certified element lies in $\mathrm{GL}(V)$). The degenerate case $V = \{0\}$ is handled by noting that $\chi_\varphi = 1$ is then a unit and cannot be irreducible, so the hypothesis is vacuously unmet.

**Supporting lemmas (used above, each independently established).**

- **Lemma 3.3 (Intertwining).** $\iota_W \circ \varphi|_W = \varphi \circ \iota_W$. *(Equation 3.1; immediate from the defining property of the restriction.)*
- **Lemma 3.4 (Annihilator transfer).** If $p(\varphi) = 0$ then $p(\varphi|_W) = 0$. *(Equation 3.2 plus injectivity of $\iota_W$.)*
- **Lemma 3.5 (Minimal polynomial divisibility).** $m_{\varphi|_W} \mid m_\varphi$. *(Lemma 3.4 with $p = m_\varphi$ and minimality.)*
- **Lemma 3.6 (Minimal equals characteristic under irreducibility).** If $\chi_\varphi$ is irreducible then $m_\varphi = \chi_\varphi$. *(Since $m_\varphi \mid \chi_\varphi$, $m_\varphi$ is nonconstant by Cayley–Hamilton and minimality, and irreducibility leaves only the associate option; monic normalization gives equality.)*

### 3.2 Orbit spanning — a coding-theory bridge

For $v \in V$, the **cyclic orbit module** is
$$
Z(\varphi, v) \;=\; \operatorname{span}_K \{\, \varphi^m v : m \in \mathbb{N} \,\}.
$$

**Lemma 3.7 (Orbit module is invariant).** $Z(\varphi, v)$ is $\varphi$-invariant.

*Proof.* It suffices (by linearity and the span-induction principle) to check the generators: $\varphi(\varphi^m v) = \varphi^{m+1} v \in Z(\varphi,v)$. The zero vector and closure under addition and scalar multiplication are immediate. $\blacksquare$

**Theorem 3.8 (Orbit Spanning Theorem).**
If $\chi_\varphi$ is irreducible and $v \neq 0$, then
$$
Z(\varphi, v) = \operatorname{span}_K \{\, v, \varphi v, \varphi^2 v, \dots \,\} = V.
$$

*Proof.* By Lemma 3.7, $Z(\varphi,v)$ is invariant, so by Theorem 3.1 it is $\{0\}$ or $V$. Since $v \in Z(\varphi,v)$ and $v \neq 0$, the span is not $\{0\}$; hence it is $V$. $\blacksquare$

**Interpretation.** A nonzero vector is *cyclic*: its powers under $\varphi$ generate the whole space. This is precisely the algebraic mechanism behind maximal-period **linear feedback shift registers** and the generator structure of **cyclic codes**. When $\chi_\varphi$ is not merely irreducible but *primitive*, the companion matrix of $\chi_\varphi$ has order $q^n - 1$ and its orbit visits every nonzero vector — the maximal-period property prized in pseudo-random generation and stream ciphers.

### 3.3 Finite-geometry theorem — the Singer-cycle property

**Theorem 3.9 (No fixed proper projective flat).**
If $\chi_\varphi$ is irreducible, then there is **no** submodule $W$ with $W \neq \{0\}$, $W \neq V$, and $W$ $\varphi$-invariant. Equivalently, in the projective space $\mathrm{PG}(n-1, q)$ over a finite field $\mathbb{F}_q$, the collineation induced by $\varphi$ fixes no proper nonzero projective flat.

*Proof.* Immediate contrapositive of Theorem 3.1: any invariant $W$ is $\{0\}$ or $V$, contradicting the assumed properness and nontriviality. $\blacksquare$

**Interpretation.** Such a $\varphi$ is a **Singer cycle** (Singer 1938). It acts on the $\tfrac{q^n - 1}{q - 1}$ points of $\mathrm{PG}(n-1,q)$ as a single cycle, the maximally transitive collineation a finite projective space admits — the discrete analogue of an irrational rotation.

### 3.4 Specialization to prime fields

**Corollary 3.10 (Prime-field Singer certificate).**
Let $p$ be prime, $V$ a finite-dimensional vector space over $\mathbb{Z}/p\mathbb{Z}$, and $\varphi \in \operatorname{End}_{\mathbb{Z}/p\mathbb{Z}}(V)$ with $\chi_\varphi$ irreducible. Then every $\varphi$-invariant submodule is $\{0\}$ or $V$.

*Proof.* Direct instantiation of Theorem 3.1 with $K = \mathbb{Z}/p\mathbb{Z}$. $\blacksquare$

This is the case of greatest importance in computational group theory, where elements of $\mathrm{GL}_n(\mathbb{F}_p)$ are the basic objects manipulated by recognition and constructive-membership algorithms.

### 3.5 Certificate density and a positivity bound

**Theorem 3.11 (Density positivity).**
Let $G$ be a finite group and $C : G \to \mathrm{Prop}$ a decidable predicate with at least one certified element ($\exists g,\ C(g)$). Then
$$
\delta(C) = \frac{\#\{g : C(g)\}}{\#\,G} > 0.
$$

*Proof.* The numerator is the cardinality of the nonempty subtype $\{g : C(g)\}$, hence a positive natural number; the denominator $\#\,G \ge 1$ is positive (a group is nonempty, containing $1$). A quotient of positive rationals is positive. $\blacksquare$

**Significance.** Density positivity is the qualitative anchor of every probabilistic generation argument: if certified elements exist at all, uniform random sampling hits one with positive probability per draw, so the expected number of draws to obtain a certified element is finite. Quantitative refinements (Section 5) sharpen "positive" to "$\gtrsim 1/n$," which is what makes random-generation algorithms practical.

---

## 4. Algorithms

The theory yields three concrete computational procedures.

### 4.1 Certificate verification

**Goal.** Decide whether a matrix $A \in M_n(\mathbb{F}_q)$ is a linear generation certificate (Definition 2.3).

**Procedure.**
1. Compute $\chi_A(t) = \det(tI - A) \in \mathbb{F}_q[t]$ (e.g. via the Faddeev–LeVerrier recurrence or fraction-free Gaussian elimination), $O(n^3)$ field operations.
2. Test $\chi_A$ for irreducibility over $\mathbb{F}_q$ (e.g. Rabin's test: $\chi_A$ of degree $n$ is irreducible iff $t^{q^n} \equiv t \pmod{\chi_A}$ and $\gcd(t^{q^{n/\ell}} - t, \chi_A) = 1$ for each prime $\ell \mid n$), $\tilde{O}(n^2 \log q)$ operations using repeated squaring modulo $\chi_A$.
3. Check invertibility: $\det A \neq 0$. (Note: if $\chi_A$ is irreducible of degree $n \ge 1$ then $\chi_A(0) \neq 0$, so $A$ is automatically invertible; the explicit check is redundant but cheap.)

Total cost is dominated by characteristic-polynomial computation and the irreducibility test: $\tilde O(n^3 + n^2 \log q)$.

### 4.2 Cyclic-vector / orbit-basis construction

**Goal.** Given a certified $\varphi$ and any $v \neq 0$, materialize the spanning orbit basis guaranteed by Theorem 3.8.

**Procedure.** Form the Krylov sequence $v, \varphi v, \dots, \varphi^{n-1} v$ and assemble them as columns. By Theorem 3.8 these $n$ vectors span $V$, hence (being $n$ vectors spanning an $n$-dimensional space) form a basis; the change-of-basis to this Krylov basis puts $\varphi$ into companion form. Cost $O(n^3)$.

### 4.3 Certificate-density estimation

**Goal.** Estimate $\delta(\mathrm{Cert})$ for $\mathrm{Cert} = $ "irreducible characteristic polynomial" in $\mathrm{GL}_n(\mathbb{F}_q)$.

**Procedure (Monte Carlo).** Sample $N$ uniform elements of $\mathrm{GL}_n(\mathbb{F}_q)$; for each, run the verifier of Section 4.1; report the empirical fraction. By Theorem 3.11 the true density is positive; the estimate concentrates around the theoretical value $\sim 1/n$ (Section 5).

---

## 5. Applications and quantitative outlook

**Random generation of $\mathrm{GL}_n(\mathbb{F}_q)$.** The classical program shows that two random elements generate $\mathrm{GL}_n(\mathbb{F}_q)$ with probability $\to 1$. A standard ingredient is an element acting irreducibly (no invariant subspace), which by Theorem 3.1 is certified by an irreducible characteristic polynomial. Such an element escapes every reducible maximal subgroup, drastically shrinking the list of "bad" overgroups a random pair could be trapped in.

**Counting Singer-type elements.** The number of monic irreducible polynomials of degree $n$ over $\mathbb{F}_q$ is $\frac{1}{n}\sum_{d \mid n}\mu(d) q^{n/d} \sim q^n/n$. Each such polynomial is the characteristic polynomial of a conjugacy class of regular semisimple elements (the companion matrix and its conjugates). This yields the heuristic that a fraction $\sim 1/n$ of $\mathrm{GL}_n(\mathbb{F}_q)$ consists of certified elements — exactly the order of magnitude in the density conjecture below.

**Coding and pseudorandomness.** Theorem 3.8 is the structural underpinning of maximal-period LFSRs and the generator theory of cyclic codes; primitivity (a strengthening of irreducibility) upgrades "spans" to "visits every nonzero state."

### 5.1 Conjectures

**Conjecture A (Linear certificate density lower bound).** For fixed prime power $q$ there is a constant $c_q > 0$ with
$$
\frac{\#\{\text{Singer certificates in } \mathrm{GL}_n(\mathbb{F}_q)\}}{|\mathrm{GL}_n(\mathbb{F}_q)|} \;\ge\; \frac{c_q}{n}\qquad\text{for all } n \ge 1.
$$

**Conjecture B (Certificate sufficiency for high-probability generation).** For random $g, h \in \mathrm{GL}_n(\mathbb{F}_q)$, if $g$ has irreducible characteristic polynomial and $\det(h)$ generates $\mathbb{F}_q^\times$, then
$$
\Pr[\,\langle g, h\rangle = \mathrm{GL}_n(\mathbb{F}_q)\,] \;\ge\; 1 - O(q^{-1}).
$$

(In the formal development these appear as named placeholders, signalling targets rather than theorems.)

---

## 6. Discussion

The framework exemplifies the *certificate paradigm*: trade an apparently infinitary structural property (no invariant subspace) for a finite, polynomial-time-checkable algebraic invariant (irreducibility of $\chi_\varphi$). Three features deserve emphasis.

1. **Sharpness of the hypothesis.** Irreducibility of $\chi_\varphi$ is equivalent to $\varphi$ being a *cyclic* regular element generating a field extension $K[\varphi] \cong K[X]/(\chi_\varphi)$ of degree $n$; the invariant-subspace conclusion is exactly the statement that $V$ is a simple module over this field. Theorem 3.1 is thus the operator-theoretic shadow of the simplicity of a field.

2. **Domain-spanning leverage.** A single theorem produces a coding-theory corollary (3.8), a finite-geometry corollary (3.9), and a computational-group-theory specialization (3.10). This is the hallmark of a good structural lemma.

3. **Formal trust.** All stated theorems (3.1, 3.7–3.11, and the supporting lemmas 3.3–3.6) have machine-checked proofs depending only on the standard foundational axioms, eliminating gaps in the degree-counting and divisibility steps that are easy to wave through informally.

## 7. Future work

Beyond Conjectures A and B, natural directions include: (i) extending the certificate to *primitivity* and quantifying maximal-period guarantees for LFSRs; (ii) treating *block* certificates for classical subgroups ($\mathrm{Sp}, \mathrm{SU}, \mathrm{SO}$) where irreducibility must be refined to preserve a form; (iii) effective bounds on the second eigenvalue / mixing of random walks generated by certified elements, connecting to expander constructions; and (iv) a unified abstract theory of generation certificate systems (Definition 2.5) covering symmetric, alternating, and linear groups under one roof.

## References

- Dixon, J. D. (1969). *The probability of generating the symmetric group.* Mathematische Zeitschrift 110, 199–205.
- Huppert, B. (1967). *Endliche Gruppen I.* Springer.
- Neumann, P. M., & Praeger, C. E. (1992). *A recognition algorithm for special linear groups.* Proc. London Math. Soc. 65(3), 555–603.
- Singer, J. (1938). *A theorem in finite projective geometry and some applications to number theory.* Trans. Amer. Math. Soc. 43, 377–385.
