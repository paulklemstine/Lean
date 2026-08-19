# The Converse of Poisson Summation on a Finite Abelian Group: Classification, Enumeration, and the Boundary of Rigidity

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Let $G$ be a finite abelian group with dual group $\widehat{G}$ of characters, and let $\widehat{f}(\psi) = \sum_{x \in G} \overline{\psi(x)} f(x)$ denote the discrete Fourier transform. Poisson summation asserts that for every subgroup $H \le G$ and every $f \colon G \to \mathbb{C}$,
$$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \widehat{f}(\psi),$$
where $H^{\perp}$ is the annihilator of $H$ in $\widehat{G}$. We prove the exact converse. Call a pair $(S,T)$ of subsets $S \subseteq G$, $T \subseteq \widehat{G}$ a *Poisson pair* if $|G| \sum_{x\in S} f(x) = |S| \sum_{\psi \in T} \widehat{f}(\psi)$ for **every** $f$. We show:

1. **(Delta reduction.)** The condition, quantified over the infinite-dimensional family of all test functions, is equivalent to the finite family of $|G|$ linear identities on the character table $|S|\sum_{\psi \in T} \overline{\psi(a)} = |G|\,\mathbf{1}_{S}(a)$, $a \in G$.
2. **(Classification.)** If $S \ne \emptyset$, then $(S,T)$ is a Poisson pair if and only if $S$ is a subgroup $H$ of $G$ and $T = H^{\perp}$. The empty set is the only degenerate solution and it is a Poisson set for every $T$.
3. **(Area identity and Lagrange.)** Every nonempty Poisson pair satisfies $|S|\cdot|T| = |G|$; in particular $|S|$ divides $|G|$, so Lagrange's theorem is a corollary of the summation identity.
4. **(Rectangle criterion.)** For nonempty $S$, $(S,T)$ is a Poisson pair if and only if the $S \times T$ block of the character table is identically $1$ and has area exactly $|G|$; unconditionally, every all-ones block has area at most $|G|$.
5. **(Enumeration.)** The nonempty Poisson pairs of $G$ are in explicit bijection with the subgroups of $G$; hence their number is the number of subgroups of $G$. For $|G|$ prime there are exactly two, namely $(\{0\}, \widehat{G})$ and $(G, \{0\})$; for $G = \mathbb{Z}/n$ their number is $\sigma_0(n)$, the number of divisors of $n$.
6. **(Biduality.)** $H^{\perp\perp} = H$ for every subgroup $H$, obtained as a corollary of the converse rather than as an input from Pontryagin duality.

The proof uses no analytic input beyond the equality case of the triangle inequality: $n$ unimodular complex numbers summing to $n$ are all equal to $1$. We also delimit the theorem sharply by studying the twisted (weighted) identity: with unimodular weights, rigidity survives and forces $S$ to be a coset, $T$ its annihilator, and the weight the associated phase; without unimodularity, the statement collapses, since *every* nonempty $S$ satisfies a twisted identity. Finally we record the companion application: the equality case of the Donoho–Stark uncertainty principle, $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat{f}| \ge |G|$, is attained exactly by the functions $c\,\psi_1\mathbf{1}_{a+H}$.

**Keywords:** Poisson summation, finite abelian group, character table, annihilator, Pontryagin duality, uncertainty principle, combinatorial rectangle, Lagrange's theorem.

---

## 1. Introduction

### 1.1 Poisson summation as a rigidity phenomenon

Poisson summation is one of the most versatile identities in mathematics. On the real line it relates a sum of a Schwartz function over a lattice to a sum of its Fourier transform over the dual lattice; it underlies sampling theory, theta-function transformation laws, lattice point counting, and the analytic theory of modular forms. Its finite analogue, on a finite abelian group $G$, is a statement of finite-dimensional linear algebra: for every subgroup $H \le G$,
$$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \widehat{f}(\psi) \qquad (f \colon G \to \mathbb{C}). \tag{1.1}$$

The identity is invariably stated as a theorem *about subgroups*. This paper answers the question that the statement suppresses: **is the subgroup hypothesis necessary?** Precisely: if we take arbitrary subsets $S \subseteq G$ and $T \subseteq \widehat{G}$ with no algebraic structure assumed and demand that
$$|G| \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in T} \widehat{f}(\psi) \qquad \text{for all } f \colon G \to \mathbb{C}, \tag{1.2}$$
must $S$ be a subgroup and $T$ its annihilator?

The answer is yes, with the single exception $S = \emptyset$, for which both sides of $(1.2)$ vanish identically. Poisson summation is therefore not merely valid for subgroups; it *characterizes* them. This places $(1.1)$ in the family of **extremal rigidity theorems**: identities whose validity forces maximal structure on their inputs.

### 1.2 Method: no new analytic input

The proof we give is deliberately economical. Both sides of $(1.2)$ are already understood objects — the left side is a set sum, the right side a sum of Fourier coefficients — and the whole argument consists of choosing the right test functions and then invoking one elementary geometric fact.

The two test families are dual to each other:

- **Dirac deltas** $\delta_a$, which turn $(1.2)$ into a statement about a single row of the character table;
- **characters** $\psi_0$ themselves, which turn $(1.2)$ into a statement about a single column.

Because the deltas span $\mathbb{C}^{G}$, the first reduction is not lossy: the analytic-looking condition $(1.2)$ is *equivalent* to a finite system of equations in the entries of the character table. What remains is combinatorics, and it is settled by:

> $n$ complex numbers of modulus $1$ whose sum is $n$ are all equal to $1$.

That is the entire analytic content. No estimate, no inequality other than the equality case of the triangle inequality, no appeal to Pontryagin duality.

### 1.3 Consequences

Once the classification is in hand, several corollaries follow at once.

- The **area identity** $|S|\cdot|T| = |G|$, obtained by evaluating the delta identity at $a=0$. Since $S$ is a subgroup, this contains **Lagrange's theorem**.
- **Biduality** $H^{\perp\perp} = H$, because $S$ is recovered from $T$ as the set of elements annihilated by all of $T$.
- **Uniqueness in both directions**: each side of a nonempty Poisson pair determines the other.
- A reformulation as a statement about **all-ones combinatorial rectangles** in the character table: Poisson pairs are precisely the all-ones rectangles of maximal area $|G|$.
- An **exact enumeration**: the nonempty Poisson pairs form a set in bijection with the subgroup lattice of $G$.

Section 6 delimits the result by twisting the identity with weights, and Section 7 records the application to the equality case of the Donoho–Stark uncertainty principle.

---

## 2. Setting and notation

Throughout, $G$ is a finite abelian group, written additively, with identity $0$ and order $|G| = \#G$.

**Definition 2.1 (Character, dual group).** A *character* of $G$ is a homomorphism $\psi \colon G \to \mathbb{C}^{\times}$, i.e. a function with $\psi(x+y) = \psi(x)\psi(y)$. Since $G$ is finite, every value $\psi(x)$ is a root of unity; in particular $|\psi(x)| = 1$ for all $x$, and $\psi(0) = 1$, $\psi(-x) = \overline{\psi(x)}$. The set $\widehat{G}$ of characters forms an abelian group under pointwise multiplication, with identity the trivial character $\mathbf{1}$ (written $0$ in additive notation for $\widehat G$), and $|\widehat{G}| = |G|$.

**Definition 2.2 (Discrete Fourier transform).** For $f \colon G \to \mathbb{C}$ and $\psi \in \widehat{G}$,
$$\widehat{f}(\psi) \;=\; \sum_{x \in G} \overline{\psi(x)}\, f(x).$$

**Definition 2.3 (Character table).** The *character table* of $G$ is the matrix $\big(\psi(x)\big)_{x \in G,\ \psi \in \widehat{G}}$, all of whose entries have modulus $1$. All statements below are ultimately statements about this matrix.

We shall use the standard orthogonality relation
$$\sum_{x \in G} \psi(x)\overline{\chi(x)} \;=\; \begin{cases} |G| & \psi = \chi, \\ 0 & \psi \ne \chi,\end{cases} \tag{2.1}$$
and the elementary formula for the transform of a Dirac delta $\delta_a$ (equal to $1$ at $a$ and $0$ elsewhere):
$$\widehat{\delta_a}(\psi) \;=\; \overline{\psi(a)}. \tag{2.2}$$

**Definition 2.4 (Annihilators).** For a subgroup $H \le G$, the *annihilator* of $H$ is
$$H^{\perp} \;=\; \{\psi \in \widehat{G} : \psi(x) = 1 \text{ for all } x \in H\} \;\le\; \widehat{G}.$$
Dually, for an arbitrary subset $T \subseteq \widehat{G}$ we define the *pre-annihilator*
$$T^{\perp} \;=\; \{a \in G : \psi(a) = 1 \text{ for all } \psi \in T\}.$$

**Lemma 2.5.** For every subset $T \subseteq \widehat{G}$, the pre-annihilator $T^{\perp}$ is a subgroup of $G$.

*Proof.* $\psi(0)=1$ for all $\psi$, so $0 \in T^{\perp}$. If $\psi(a) = \psi(b) = 1$ for all $\psi \in T$, then $\psi(a+b) = \psi(a)\psi(b) = 1$ and $\psi(-a) = \overline{\psi(a)} = 1$. $\square$

Lemma 2.5 is the pivot of the whole paper: *no hypothesis is placed on $T$*, yet the resulting set is automatically a group. All the work below consists of showing that a Poisson pair's primal side must equal such a pre-annihilator.

We also record the classical facts we take as given, both standard consequences of $(2.1)$:

**Proposition 2.6 (Poisson summation).** For every subgroup $H \le G$ and every $f \colon G \to \mathbb{C}$, identity $(1.1)$ holds.

**Proposition 2.7 (Annihilator index).** For every subgroup $H \le G$, $\ |H| \cdot |H^{\perp}| = |G|$.

---

## 3. Poisson pairs and reduction to the character table

**Definition 3.1 (Poisson pair).** Let $S \subseteq G$ and $T \subseteq \widehat{G}$. The pair $(S,T)$ is a *Poisson pair* if
$$|G| \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in T} \widehat{f}(\psi) \qquad \text{for every } f \colon G \to \mathbb{C}.$$

By Proposition 2.6, $(H, H^{\perp})$ is a Poisson pair for every subgroup $H$. Also $(\emptyset, T)$ is a Poisson pair for every $T$, both sides being zero. Our goal is to prove that there is nothing else.

**Definition 3.2 (Character-table condition).** The pair $(S,T)$ satisfies the *character-table condition* if for every $a \in G$,
$$|S| \sum_{\psi \in T} \overline{\psi(a)} \;=\; |G| \cdot \mathbf{1}_{S}(a), \tag{3.1}$$
where $\mathbf{1}_S(a)$ is $1$ if $a \in S$ and $0$ otherwise.

Condition $(3.1)$ is a finite system of $|G|$ scalar equations whose only ingredients are the entries of the character table and the cardinalities $|S|, |G|$.

**Theorem 3.3 (Delta reduction — only the deltas matter).** $(S,T)$ is a Poisson pair if and only if it satisfies the character-table condition $(3.1)$.

*Proof.* ($\Rightarrow$) Apply the Poisson identity to $f = \delta_a$. The left side is $|G|\sum_{x \in S}\delta_a(x) = |G|\,\mathbf{1}_S(a)$. By $(2.2)$, the right side is $|S|\sum_{\psi \in T}\overline{\psi(a)}$. This is exactly $(3.1)$.

($\Leftarrow$) Assume $(3.1)$. For an arbitrary $f$, expand both sides as linear functionals in the values $f(a)$, $a \in G$:
$$\sum_{x \in S} f(x) = \sum_{a \in G} \mathbf{1}_S(a) f(a), \qquad \sum_{\psi \in T} \widehat{f}(\psi) = \sum_{a \in G} \Big(\sum_{\psi \in T} \overline{\psi(a)}\Big) f(a),$$
the second by interchanging the order of summation in the definition of $\widehat{f}$. Multiplying the first by $|G|$ and the second by $|S|$, the two functionals have coefficients $|G|\mathbf{1}_S(a)$ and $|S|\sum_{\psi\in T}\overline{\psi(a)}$ respectively, which agree for every $a$ by hypothesis. $\square$

Theorem 3.3 is the conceptual heart of the reduction: the quantification over all $f$ — a priori a statement in an infinite-dimensional-looking function space — is precisely equivalent to a finite statement about the character table. Everything that follows is combinatorics.

The dual test function gives a complementary, and equally useful, finite statement.

**Theorem 3.4 (Character test).** Let $(S,T)$ be a Poisson pair. Then for every $\psi_0 \in \widehat{G}$,
$$\sum_{x \in S} \psi_0(x) \;=\; |S| \cdot \mathbf{1}_{T}(\psi_0). \tag{3.2}$$

*Proof.* Apply the Poisson identity to the test function $f = \psi_0$. By orthogonality $(2.1)$,
$$\widehat{\psi_0}(\chi) = \sum_{x\in G} \overline{\chi(x)}\psi_0(x) = \begin{cases}|G| & \chi = \psi_0,\\ 0 & \text{otherwise},\end{cases}$$
so the right side of the Poisson identity is $|S| \cdot |G| \cdot \mathbf{1}_T(\psi_0)$, while the left is $|G|\sum_{x \in S}\psi_0(x)$. Cancelling $|G| \ne 0$ gives $(3.2)$. $\square$

Note the pleasing symmetry: $(3.1)$ reads off a *row* of the character table and detects membership in $S$; $(3.2)$ reads off a *column* and detects membership in $T$.

---

## 4. Rigidity

### 4.1 The equality case of the triangle inequality

**Lemma 4.1.** Let $s$ be a finite index set and $(z_i)_{i \in s}$ complex numbers with $|z_i| = 1$ for all $i$. If $\sum_{i \in s} z_i = \#s$, then $z_i = 1$ for every $i$.

*Proof.* Taking real parts, $\sum_{i\in s}\operatorname{Re} z_i = \#s$, i.e. $\sum_{i \in s}\big(1 - \operatorname{Re} z_i\big) = 0$. Each summand is nonnegative, since $\operatorname{Re} z_i \le |\operatorname{Re} z_i| \le |z_i| = 1$. A sum of nonnegative reals vanishes only if each term vanishes, so $\operatorname{Re} z_i = 1$ for all $i$. Combined with $(\operatorname{Re} z_i)^2 + (\operatorname{Im} z_i)^2 = |z_i|^2 = 1$ this forces $\operatorname{Im} z_i = 0$, hence $z_i = 1$. $\square$

Geometrically: $n$ unit vectors can span a displacement of length $n$ only if they are all parallel and identically oriented. This is the only non-formal ingredient in the whole development.

### 4.2 The trivial character, and the area identity

Throughout this subsection $(S,T)$ is a Poisson pair with $S \ne \emptyset$.

**Lemma 4.2.** The trivial character lies in $T$; in particular $T \ne \emptyset$.

*Proof.* Apply the character test $(3.2)$ with $\psi_0 = \mathbf{1}$. The left side is $\sum_{x \in S} 1 = |S|$, so $|S| = |S|\cdot \mathbf{1}_T(\mathbf{1})$. Since $|S| \ne 0$, we get $\mathbf{1}_T(\mathbf{1}) = 1$. $\square$

**Theorem 4.3 (Area identity).** $|S| \cdot |T| = |G|$.

*Proof.* Evaluate the character-table condition $(3.1)$ at $a = 0$. Since $\psi(0)=1$ for all $\psi$, the left side is $|S| \cdot |T|$, and the right is $|G|\,\mathbf{1}_S(0)$. If $0 \notin S$ we would get $|S||T| = 0$, contradicting $S \ne \emptyset$ and (by Lemma 4.2) $T \ne \emptyset$. Hence $0 \in S$ and $|S||T| = |G|$. $\square$

**Corollary 4.4 (Lagrange's theorem from Poisson summation).** $|S|$ divides $|G|$.

Corollary 4.4 will be recognised, once Theorem 4.7 is proved, as Lagrange's theorem for the subgroup $S$; but it is worth stressing that the divisibility is obtained here directly from the analytic identity, before any group structure on $S$ is known.

### 4.3 Membership is detected by the character table

**Theorem 4.5 (Rigidity, primal side).** For every $a \in G$,
$$a \in S \iff \psi(a) = 1 \ \text{ for all } \psi \in T.$$

*Proof.* ($\Rightarrow$) Let $a \in S$. Then $(3.1)$ gives $|S|\sum_{\psi\in T}\overline{\psi(a)} = |G| = |S||T|$ by Theorem 4.3. Cancelling $|S|\ne 0$,
$$\sum_{\psi \in T} \overline{\psi(a)} \;=\; |T|,$$
a sum of $|T|$ unimodular numbers equal to $|T|$. By Lemma 4.1, $\overline{\psi(a)} = 1$ for every $\psi \in T$, hence $\psi(a) = 1$.

($\Leftarrow$) Suppose $\psi(a) = 1$ for all $\psi \in T$ but $a \notin S$. Then the left side of $(3.1)$ is $|S|\cdot|T| \ne 0$ (both factors nonzero by Lemma 4.2), while the right side is $0$: contradiction. $\square$

**Theorem 4.6 (Rigidity, dual side).** For every $\psi \in \widehat{G}$,
$$\psi \in T \iff \psi(x) = 1 \ \text{ for all } x \in S.$$

*Proof.* ($\Rightarrow$) If $\psi \in T$, the character test $(3.2)$ gives $\sum_{x \in S}\psi(x) = |S|$, a sum of $|S|$ unimodular numbers equal to $|S|$; Lemma 4.1 applies.

($\Leftarrow$) If $\psi(x) = 1$ for all $x \in S$ then $\sum_{x\in S}\psi(x) = |S| \ne 0$, so by $(3.2)$ we cannot have $\mathbf{1}_T(\psi) = 0$. $\square$

### 4.4 The converse of Poisson summation

**Theorem 4.7 (Converse of Poisson summation).** Let $S \subseteq G$ be nonempty and $T \subseteq \widehat{G}$, and suppose $(S,T)$ is a Poisson pair. Then $H := T^{\perp}$ is a subgroup of $G$ with
$$S = H \qquad \text{and} \qquad T = H^{\perp}.$$

*Proof.* By Lemma 2.5, $H = T^{\perp}$ is a subgroup. Theorem 4.5 says exactly that $a \in S \iff a \in T^{\perp}$, i.e. $S = H$ as sets; so $S$ is a subgroup. Theorem 4.6 then says $\psi \in T \iff \psi$ is trivial on $S = H$, i.e. $T = H^{\perp}$. $\square$

**Theorem 4.8 (Classification).** Let $S \subseteq G$ be nonempty, $T \subseteq \widehat{G}$. Then $(S,T)$ is a Poisson pair **if and only if** there is a subgroup $H \le G$ with $S = H$ and $T = H^{\perp}$.

*Proof.* Necessity is Theorem 4.7; sufficiency is Poisson summation, Proposition 2.6. $\square$

**Proposition 4.9 (Sharpness of the nonemptiness hypothesis).** $(\emptyset, T)$ is a Poisson pair for *every* $T \subseteq \widehat{G}$, since both sides of the identity are $0$. Consequently the hypothesis $S \ne \emptyset$ in Theorems 4.7 and 4.8 cannot be dropped, and $S = \emptyset$ is the only exceptional case.

**Corollary 4.10 (Uniqueness).** Let $S$ be nonempty. If $(S,T)$ and $(S,T')$ are Poisson pairs then $T = T'$. If $(S,T)$ and $(S',T)$ are Poisson pairs with $S, S'$ nonempty then $S = S'$.

*Proof.* Immediate from Theorems 4.6 and 4.5 respectively: both memberships are characterised in terms of the other side alone. $\square$

**Corollary 4.11 (Biduality).** For every subgroup $H \le G$, $\ (H^{\perp})^{\perp} = H$.

*Proof.* $(H, H^{\perp})$ is a Poisson pair with $H$ nonempty (it contains $0$). By Theorem 4.5 applied to this pair, $a \in H \iff \psi(a) = 1$ for all $\psi \in H^{\perp}$, and the right-hand side says exactly $a \in (H^\perp)^\perp$. $\square$

It is worth pausing on Corollary 4.11: the finite case of Pontryagin biduality here emerges as a *consequence* of the analytic identity, not as an ingredient of its proof.

---

## 5. Poisson pairs as extremal rectangles, and their enumeration

### 5.1 The rectangle picture

Regard the character table as a $|G| \times |G|$ grid of unimodular complex numbers.

**Definition 5.1.** A pair $(S,T)$ with $S \subseteq G$, $T \subseteq \widehat{G}$ is an *all-ones rectangle* if $\psi(x) = 1$ for every $x \in S$ and $\psi \in T$. Its *area* is $|S|\cdot|T|$.

**Theorem 5.2 (Rectangle bound).** Every all-ones rectangle has area at most $|G|$:
$$\psi(x) = 1 \ \ \forall x \in S,\ \forall \psi \in T \quad \Longrightarrow \quad |S|\cdot|T| \le |G|.$$

*Proof.* Put $H = T^{\perp}$, a subgroup by Lemma 2.5. The hypothesis says $S \subseteq H$. It also says every $\psi \in T$ is trivial on $H$ — indeed if $x \in H = T^{\perp}$ and $\psi \in T$ then $\psi(x) = 1$ by definition of $T^{\perp}$ — so $T \subseteq H^{\perp}$. Therefore
$$|S|\cdot|T| \;\le\; |H| \cdot |H^{\perp}| \;=\; |G|$$
by Proposition 2.7. $\square$

**Theorem 5.3 (Rectangle criterion).** Let $S \ne \emptyset$. Then $(S,T)$ is a Poisson pair if and only if
$$\psi(x) = 1 \ \ \text{for all } x \in S,\ \psi \in T, \qquad \text{and} \qquad |S|\cdot|T| = |G|;$$
that is, if and only if $S \times T$ is an all-ones rectangle of maximal area.

*Proof.* ($\Rightarrow$) The all-ones property is the forward implication of Theorem 4.6; the area is Theorem 4.3.

($\Leftarrow$) Set $H = T^{\perp}$. As in the proof of Theorem 5.2 we have $S \subseteq H$ and $T \subseteq H^{\perp}$, hence $|S| \le |H|$ and $|T| \le |H^{\perp}|$. Note $|S| > 0$, and also $|T| > 0$ since $|S||T| = |G| > 0$. From $|S||T| = |G| = |H||H^{\perp}|$, together with the two coordinatewise inequalities and positivity, we get $|S| = |H|$ and $|T| = |H^{\perp}|$: indeed $|S||T| \le |H||T| \le |H||H^\perp|$ with equal ends forces equality throughout, and cancellation of the positive factors gives the two equalities. Since $S \subseteq H$ with $|S| = |H|$ and $T \subseteq H^{\perp}$ with $|T| = |H^{\perp}|$, we conclude $S = H$ and $T = H^{\perp}$, and Poisson summation applies. $\square$

Theorem 5.3 completes the elimination of analysis: the analytic condition "the Poisson identity holds for all test functions" is *literally the same condition* as "this block of a $0/1$-patterned table is monochromatic and as large as possible". Combinatorially, the character table of a finite abelian group has the striking property that all its maximal all-ones rectangles have the *same* area, namely $|G|$, and each is a subgroup paired with its annihilator.

### 5.2 The bijection with the subgroup lattice

Let
$$\mathcal{P}(G) \;=\; \{(S,T) : (S,T) \text{ is a Poisson pair}, \ S \ne \emptyset\}$$
denote the set of nonempty Poisson pairs, and $\operatorname{Sub}(G)$ the set of subgroups of $G$.

**Theorem 5.4 (Poisson pairs are the subgroup lattice).** The map
$$\Phi \colon \mathcal{P}(G) \longrightarrow \operatorname{Sub}(G), \qquad \Phi(S,T) = T^{\perp}$$
is a bijection, with inverse $\Psi(H) = (H, H^{\perp})$.

*Proof.* $\Phi$ is well defined by Lemma 2.5, and $\Psi$ is well defined by Proposition 2.6 (and $H \ne \emptyset$ since $0 \in H$).

$\Phi \circ \Psi = \mathrm{id}$: for a subgroup $H$, $\Phi(\Psi(H)) = (H^{\perp})^{\perp} = H$ by Corollary 4.11.

$\Psi \circ \Phi = \mathrm{id}$: let $(S,T) \in \mathcal{P}(G)$ and $H = T^{\perp}$. Theorem 4.7 gives $S = H$ and $T = H^{\perp}$, i.e. $\Psi(\Phi(S,T)) = (H, H^\perp) = (S,T)$. $\square$

**Corollary 5.5 (Exact count).** $\ \#\mathcal{P}(G) = \#\operatorname{Sub}(G)$.

Thus the analytic question — *for how many pairs of subsets does Poisson summation hold?* — has a purely algebraic answer, given by the size of the subgroup lattice, a quantity that for many families of groups is classically known.

### 5.3 Groups of prime order

**Theorem 5.6.** Suppose $|G| = p$ is prime, $S \ne \emptyset$, and $(S,T)$ is a Poisson pair. Then
$$(S,T) = (\{0\},\, \widehat{G}) \qquad \text{or} \qquad (S,T) = (G,\, \{\mathbf{1}\}).$$
Conversely both of these are Poisson pairs.

*Proof.* By Theorem 4.3, $|S|$ divides $p$, so $|S| = 1$ or $|S| = p$. In the first case $0 \in S$ (Theorem 4.3's proof, or Theorem 4.5 with $\psi(0)=1$) forces $S = \{0\}$; in the second $S = G$. In each case the dual side is determined by Corollary 4.10, and $(\{0\}, \widehat{G})$, $(G, \{\mathbf{1}\})$ are Poisson pairs: the first is the all-ones rectangle of one row and all $p$ columns (area $p$), the second of all $p$ rows and the trivial-character column (area $p$); apply Theorem 5.3. $\square$

The two survivors are the two banalities: $(\{0\}, \widehat{G})$ says that $|G| f(0) = \sum_{\psi} \widehat{f}(\psi)$, i.e. Fourier inversion at the origin; $(G, \{\mathbf{1}\})$ says $\sum_{x} f(x) = \widehat{f}(\mathbf{1})$, the definition of the zeroth Fourier coefficient. In a group of prime order, these are *all* the Poisson identities there are.

### 5.4 The cyclic case and computational evidence

For $G = \mathbb{Z}/n$ the characters are $\psi_k(x) = e^{2\pi i k x/n}$, $k \in \mathbb{Z}/n$, and the character-table entry at $(x,k)$ equals $1$ precisely when $n \mid kx$. Theorem 5.3 therefore becomes a statement about integers with no complex numbers in sight:

> **Corollary 5.7.** For nonempty $S \subseteq \mathbb{Z}/n$ and $T \subseteq \mathbb{Z}/n$, the pair $(S,T)$ is a Poisson pair if and only if $n \mid xk$ for all $x \in S$, $k \in T$, and $|S|\cdot|T| = n$.

Since the subgroups of $\mathbb{Z}/n$ are in bijection with the divisors of $n$, Corollary 5.5 predicts
$$\#\mathcal{P}(\mathbb{Z}/n) = \sigma_0(n),$$
the number of divisors of $n$. An exhaustive search over all $2^n \cdot 2^n$ pairs of subsets confirms this:

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| number of Poisson pairs | 1 | 2 | 2 | 3 | 2 | 4 |
| $\sigma_0(n)$ | 1 | 2 | 2 | 3 | 2 | 4 |

For $n=6$ the four pairs correspond to the divisors $1,2,3,6$: the subgroups $\{0\}$, $\{0,3\}$, $\{0,2,4\}$, $\mathbb{Z}/6$, paired respectively with dual sides of size $6,3,2,1$, in each case realising the area identity $|S|\cdot|T| = 6$.

---

## 6. The boundary of rigidity: twisted Poisson summation

Theorem 4.8 is exhaustive for the *untwisted* identity, but cosets — the natural next candidate after subgroups — also satisfy a Poisson identity, at the cost of a phase.

**Proposition 6.1 (Poisson summation over a coset).** For a subgroup $H \le G$, $a \in G$, and every $f \colon G \to \mathbb{C}$,
$$|G| \sum_{x \in a+H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \psi(a)\,\widehat{f}(\psi).$$

*Proof sketch.* Apply $(1.1)$ to the translate $g(x) = f(x + a)$. The transform is covariant under translation: $\widehat{g}(\psi) = \psi(a)\widehat{f}(\psi)$, a computation with the substitution $y = x + a$ and $\overline{\psi(y-a)} = \psi(a)\overline{\psi(y)}$. $\square$

This suggests the weighted relation.

**Definition 6.2 (Twisted Poisson pair).** Let $S \subseteq G$, $T \subseteq \widehat{G}$ and $w \colon \widehat{G} \to \mathbb{C}$. The triple $(S,T,w)$ is a *twisted Poisson pair* if
$$|G|\sum_{x\in S} f(x) \;=\; |S| \sum_{\psi \in T} w(\psi)\,\widehat{f}(\psi) \qquad \text{for all } f.$$

The rigidity survives exactly as long as the weights are phases.

**Theorem 6.3 (Twisted converse, unimodular weights).** Let $(S,T,w)$ be a twisted Poisson pair with $S \ne \emptyset$ and $|w(\psi)| = 1$ for all $\psi \in T$. Then there are a subgroup $H \le G$ and $a \in G$ with
$$S = a + H, \qquad T = H^{\perp}, \qquad w(\psi) = \psi(a) \ \ (\psi \in T).$$

*Proof sketch.* Testing against deltas as in Theorem 3.3 gives $|S|\sum_{\psi\in T} w(\psi)\overline{\psi(a)} = |G|\mathbf{1}_S(a)$; the area identity is recovered at a point $a_0 \in S$, and the equality case of the triangle inequality (Lemma 4.1, applied to the unimodular numbers $w(\psi)\overline{\psi(a_0)}$) forces $w(\psi) = \psi(a_0)$ on $T$. Substituting back removes the twist from the translated pair $(S - a_0, T)$, which is then an untwisted Poisson pair; Theorem 4.7 makes it $(H, H^{\perp})$. $\square$

**Theorem 6.4 (Collapse without unimodularity).** Let $S \subseteq G$ be any nonempty subset. Then $(S, \widehat{G}, w)$ is a twisted Poisson pair for the weight
$$w(\psi) \;=\; \frac{\overline{\widehat{\mathbf{1}_S}(\psi)}}{|S|}.$$

*Proof sketch.* By Fourier inversion, $\sum_{\psi} \overline{\widehat{\mathbf{1}_S}(\psi)}\,\widehat{f}(\psi)$ reproduces $|G|\sum_{x\in S} f(x)$ for every $f$; dividing by $|S|$ gives the stated identity. $\square$

Thus without a normalisation constraint on the weight the notion is vacuous: *every* nonempty subset is a twisted Poisson set. An explicit witness that this is not an artefact is $S = \{0,1\} \subseteq \mathbb{Z}/3$, which cannot be a coset of any subgroup since $2 \nmid 3$, yet carries a valid twisted identity.

**Conclusion.** Unimodularity of the weight is not a technical convenience: it is exactly the hypothesis separating the rigid regime (Theorem 6.3) from the vacuous one (Theorem 6.4). This is precisely what one should expect from the shape of the proof, whose only substantive step, Lemma 4.1, is a statement about unit vectors.

---

## 7. Application: the equality case of the uncertainty principle

For $f \colon G \to \mathbb{C}$ write $\operatorname{supp} f = \{x : f(x) \ne 0\}$.

**Theorem 7.1 (Donoho–Stark uncertainty principle).** For every $f \ne 0$,
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat{f}| \;\ge\; |G|.$$

*Proof sketch.* Let $A = \operatorname{supp} f$, $B = \operatorname{supp}\widehat f$, $M = \max_x |f(x)|$. Fourier inversion gives $|G| \, M \le \sum_{\psi \in B}\|\widehat f(\psi)\| \le |B| \cdot \|f\|_1 \le |B|\,|A|\,M$. $\square$

The classification of Poisson pairs settles the equality case completely.

**Theorem 7.2 (Extremals of the uncertainty principle).** Let $f \ne 0$. Then
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat{f}| = |G|$$
if and only if there are a subgroup $H \le G$, an element $a \in G$, a character $\psi_1 \in \widehat{G}$ and a constant $c \ne 0$ with
$$f \;=\; c\,\psi_1 \cdot \mathbf{1}_{a+H}.$$

*Proof sketch.* Sufficiency is a direct computation: the transform of $c\psi_1 \mathbf{1}_{a+H}$ is supported exactly on the coset $\psi_1 H^{\perp}$, of size $|H^{\perp}| = |G|/|H|$.

Necessity runs the chain of inequalities in Theorem 7.1 backwards. Equality throughout forces **double flatness**: $|f|$ is constant on $\operatorname{supp} f$ and $|\widehat f|$ is constant on $\operatorname{supp}\widehat f$ (each inequality in the chain is an equality case of the triangle inequality or of a trivial bound). Double flatness plus Fourier inversion then forces, for each $x \in \operatorname{supp} f$, the phases $\psi \mapsto \psi(x)\widehat f(\psi)$ to be independent of $\psi \in \operatorname{supp}\widehat f$. Comparing this relation at two points $x, a \in \operatorname{supp} f$ and at two characters $\psi, \psi_1 \in \operatorname{supp}\widehat f$ shows that the block
$$(\operatorname{supp} f - a) \times (\operatorname{supp}\widehat f \cdot \psi_1^{-1})$$
of the character table is identically $1$, and its area is $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| = |G|$. By the rectangle criterion, Theorem 5.3, this is a Poisson pair, so by the converse of Poisson summation $\operatorname{supp} f - a = H$ is a subgroup and $\operatorname{supp}\widehat f = \psi_1 H^{\perp}$. Flatness of $|f|$ and constancy of the phase then give $f = c\psi_1\mathbf{1}_{a+H}$. $\square$

The extremals therefore form exactly one orbit of the natural symmetry group of the problem — scaling $\times$ translation $\times$ modulation — acting on subgroup indicators. Note that the only inputs are the character table and the triangle inequality; the same two ingredients as in Section 4.

---

## 8. Algorithms

The classification yields decision procedures whose costs are worth recording. Write $n = |G|$.

**Algorithm A (Poisson-pair verification).** *Input:* $S \subseteq G$, $T \subseteq \widehat{G}$. *Output:* whether $(S,T)$ is a Poisson pair.
By Theorem 5.3 it suffices to check (i) $|S|\cdot|T| = n$, and (ii) $\psi(x) = 1$ for all $x \in S$, $\psi \in T$. Step (i) is $O(1)$ given the cardinalities; step (ii) costs $O(|S||T|) = O(n)$ character-table lookups once the pair passes (i). Naively verifying Definition 3.1 by testing functions would require $O(n^2)$ work per test function and infinitely many functions; via Theorem 3.3 it becomes $O(n^2)$; via Theorem 5.3 it becomes $O(n)$.

**Algorithm B (Poisson-pair enumeration).** *Input:* $G$. *Output:* all nonempty Poisson pairs.
By Theorem 5.4 it suffices to enumerate the subgroups $H$ of $G$ and output $(H, H^{\perp})$. For $G = \mathbb{Z}/n$ the subgroups are $d\mathbb{Z}/n$ for $d \mid n$, so the enumeration is a divisor listing: $O(\sqrt n)$ to list the divisors, $O(n)$ total to write out the pairs. Contrast the brute-force search over all $4^{n}$ pairs of subsets used as an independent check for small $n$.

**Algorithm C (Extremal recognition).** *Input:* $f \colon G \to \mathbb{C}$. *Output:* whether $f$ is an extremal of the uncertainty principle, and if so its data $(c, \psi_1, a, H)$.
Compute $\widehat f$ ($O(n^2)$ naively, $O(n\log n)$ by a fast transform), compute the two support sizes, and test $|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| = n$. If it holds, Theorem 7.2 guarantees the structure; $a$ is any point of $\operatorname{supp} f$, $H = \operatorname{supp} f - a$, $\psi_1$ any character in $\operatorname{supp}\widehat f$, and $c = f(a)/\psi_1(a)$.

---

## 9. Discussion

### 9.1 What the theorem says about Poisson summation

It is tempting to read $(1.1)$ as an analytic coincidence made possible by orthogonality of characters. The converse says otherwise: $(1.1)$ is a *characterisation* of the subgroup–annihilator pairs, hidden inside an identity. Three specific readings deserve emphasis.

**Poisson summation contains Lagrange's theorem.** The divisibility $|S| \mid |G|$ (Corollary 4.4) is derived before any group structure on $S$ is available, using only the vanishing of a sum. It is a curious inversion of the usual dependency, where Lagrange is elementary and Poisson summation is built on top of representation theory.

**Poisson summation contains biduality.** Corollary 4.11 recovers $H^{\perp\perp} = H$ without invoking the structure theorem for finite abelian groups or the general Pontryagin theory.

**Poisson summation is a combinatorial extremality statement.** Theorem 5.3 replaces the identity by "all-ones rectangle of area $|G|$". In this form the theorem generalises naturally to any situation where one has a table of unimodular numbers with an orthogonality relation, which is what makes the non-abelian extension (Section 10) plausible.

### 9.2 Why the classification is so rigid

The single source of rigidity is Lemma 4.1: unit vectors summing to full length are aligned. Every rigidity conclusion in the paper is an instance. The reason the theorem admits no exotic solutions is that the Poisson identity, tested at a delta or at a character, *always presents itself as such a saturated sum*. There is simply no slack anywhere in the system to accommodate an unstructured $S$.

Section 6 makes this diagnosis precise by exhibiting what happens when the unimodularity that Lemma 4.1 requires is withdrawn: the theory collapses to triviality. The dividing line is exactly where the lemma stops applying.

### 9.3 Relation to compressed sensing

Theorem 7.1 is the theoretical justification for uniqueness results in sparse recovery: a signal supported on fewer than $\sqrt{|G|}$ points cannot have a sparse transform, so sparsity in one domain certifies spread in the other. Theorem 7.2 identifies the exact worst cases — the coset-supported modulated indicators — for which the bound is achieved and beyond which no recovery guarantee can be improved. In a design context this is actionable: the pathological signals form one orbit, and one can enumerate them.

---

## 10. Future directions

Five falsifiable conjectures grow out of this work.

**C1. Poisson pairs in the non-abelian world detect normal subgroups.** Let $G$ be a finite group and $\operatorname{Irr} G$ its irreducible characters. Call $(S,T)$, $S \subseteq G$, $T \subseteq \operatorname{Irr} G$, a *Poisson pair* if $|G|\sum_{x\in S} f(x) = |S|\sum_{\chi \in T} d_\chi \langle f, \chi\rangle$ for every class function $f$. Conjecturally the nonempty Poisson pairs are exactly the pairs $(N, \operatorname{Irr}(G/N))$ with $N \trianglelefteq G$ normal. The key insight is that the abelian proof never used commutativity except through the character table: Theorem 5.3 reduces everything to an all-ones block of maximal area, and in the non-abelian *class* character table the all-ones blocks should be exactly the kernels of quotients, i.e. the normal subgroups. Both ingredients — the rectangle criterion and the triangle-equality rigidity lemma — are already free of the group law. A counterexample would be a finite group with a non-normal Poisson pair, and searching for one is a finite computation.

**C2. Self-duality of the Poisson-pair condition.** Conjecturally $(S,T)$ is a nonempty Poisson pair for $G$ if and only if $(T, \iota(S))$ is a nonempty Poisson pair for $\widehat{G}$, where $\iota \colon G \to \widehat{\widehat{G}}$ is the canonical embedding. The key insight is that Theorem 5.3 reduces the whole condition to a $0/1$ matrix statement — an all-ones block of area $|G|$ — and that matrix is literally the transpose of the corresponding matrix for $\widehat{G}$, with $|\widehat{G}| = |G|$. Rigidity theorems that look analytic should therefore be invariant under transposition.

**C3. Approximate Poisson pairs are near-cosets (stability).** Conjecturally there is an absolute constant $C$ such that if $S \ne \emptyset$, $|w(\psi)| = 1$ on $T$, and
$$\Big|\,|G|\sum_{x\in S} f(x) - |S|\sum_{\psi\in T} w(\psi)\widehat f(\psi)\,\Big| \;\le\; \varepsilon\,|G|\,|S|\,\|f\|_{\infty} \quad \text{for all } f,$$
then there is a coset $a+H$ with $|S \,\triangle\, (a+H)| \le C\varepsilon|S|$. The key insight is that the exact proof turns on a single equality case ($n$ unimodular numbers summing to $n$), and that equality case is **stable**: $|\sum z_i| \ge (1-\varepsilon)n$ with $|z_i| = 1$ forces all but $O(\sqrt\varepsilon\, n)$ of the $z_i$ to lie within $O(\sqrt\varepsilon)$ of $1$. Rigidity should degrade continuously, not catastrophically.

**C4. Quantitative enumeration for structured families.** Corollary 5.5 turns the count of Poisson pairs into a subgroup count. For $G = (\mathbb{Z}/p)^k$ the subgroup count is the Galois number $\sum_{j} \binom{k}{j}_p$, so the number of Poisson pairs of an elementary abelian group grows like $p^{k^2/4}$. It would be interesting to characterise which growth rates of $\#\mathcal{P}(G)$ are attainable as $|G| \to \infty$, and in particular to determine the extremal groups of a given order.

**C5. Uncertainty extremals for weighted supports.** Theorem 7.2 classifies the extremals of $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| \ge |G|$. Entropic and $\ell^p$ variants of the uncertainty principle have their own equality cases; the method of this paper — read equality back through the chain of inequalities, extract a maximal all-ones rectangle, invoke the converse of Poisson summation — should adapt, and would identify how much of the "one orbit" phenomenon is specific to counting supports.

---

## 11. Conclusion

Poisson summation on a finite abelian group holds for subgroups paired with their annihilators, and for nothing else. Quantified over arbitrary pairs of subsets, the identity forces the primal side to be a subgroup and the dual side to be its annihilator; the empty set is the unique degenerate solution. The proof reduces the identity to a finite statement about the character table by testing against Dirac deltas and characters, and then invokes a single geometric fact about unit vectors. The classification converts into an exact enumeration — the nonempty Poisson pairs are in bijection with the subgroup lattice — and yields Lagrange's theorem, biduality, and the equality case of the uncertainty principle as corollaries. Twisting the identity with weights delimits the theorem exactly: unimodular weights preserve full rigidity and produce cosets, while arbitrary weights destroy it entirely.
