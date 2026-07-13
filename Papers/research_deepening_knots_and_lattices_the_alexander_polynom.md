# Knots and Lattices: The Alexander Polynomial as a Signed State Sum, and the Universality of the Signed Model

## Abstract

The Alexander polynomial $\Delta_K(t)$ of a knot $K$ is a Laurent polynomial invariant that encodes deep topological information. A recurring dream in combinatorial knot theory is to realize $\Delta_K(t)$ as a *generating function* over lattice states — a headcount of paths or configurations weighted by an "area" statistic. We settle the combinatorial status of this program in full. We formalize two enumeration models on integer coefficient functions $c : \mathbb{Z} \to \mathbb{Z}$: the **unsigned area generating function**, whose coefficient of $t^k$ counts states of area $k$, and the **signed state sum**, whose coefficient of $t^k$ is a signed total $\sum (\pm 1)$ over states of area $k$. Our main results are:

1. **Non-negativity of the unsigned model.** Every unsigned area generating function has non-negative coefficients; hence the naive conjecture fails already for the trefoil, whose reduced polynomial $t-1+t^{-1}$ has a negative coefficient.
2. **Universality of the signed model.** *Every* finitely supported integer coefficient function is a signed state sum, with no positivity or other constraint. The signed model is therefore exactly as expressive as the class of integer Laurent polynomials, so every Alexander polynomial is a signed state sum.
3. **Exact characterization of the unsigned model.** A coefficient function is an unsigned area generating function if and only if it is finitely supported and non-negative. The gap between the two models is precisely the sign group $\{\pm 1\}$.
4. **Connected sum = Cauchy product.** The signed state sum of the product state family (areas add, signs multiply) is the convolution of the two factor sums, and the total signed weight is multiplicative — the combinatorial shadow of $\Delta_{K_1 \# K_2} = \Delta_{K_1}\cdot\Delta_{K_2}$.
5. **The torus family $T(2,2k+1)$.** We introduce $\Delta_k(t) = \sum_{i=-k}^{k}(-1)^{i+k}t^i$, prove it generalizes the trefoil ($k=1$), is palindromic (reciprocity), satisfies $\Delta_k(1)=1$ and $|\Delta_k(-1)|=2k+1$, has a negative coefficient for every $k\ge 1$ (so is never an unsigned count), yet is always a signed state sum.

Together these results explain both *why* the naive lattice-path conjecture fails and *exactly* what must be added to rescue it: a single bit of sign per state.

---

## 1. Introduction

### 1.1 The Alexander polynomial and the lattice-path dream

To each knot $K \subset S^3$ the Alexander polynomial associates a Laurent polynomial $\Delta_K(t) \in \mathbb{Z}[t, t^{-1}]$, well-defined up to multiplication by $\pm t^n$. It is one of the oldest invariants in low-dimensional topology, computable from a knot diagram, a Seifert matrix, or a state-sum expansion. Two of its structural properties recur throughout this paper:

- **Reciprocity:** $\Delta_K(t) \doteq \Delta_K(t^{-1})$ (equality up to units); in a symmetric normalization the coefficient sequence is palindromic.
- **Normalization and determinant:** $\Delta_K(1) = \pm 1$, and $|\Delta_K(-1)|$ is the *knot determinant*, a classical numerical invariant.

The program we address asks whether $\Delta_K(t)$ can be presented combinatorially as a generating function

$$\Delta_K(t) \;=\; \sum_{\text{states } s} w(s)\, t^{\,a(s)},$$

where the states $s$ range over some finite combinatorial family (lattice paths in $\mathbb{Z}^2$ avoiding a knot-determined region, say), $a(s)$ is an integer "area" statistic, and $w(s)$ is a weight. Two natural choices of weight give two models with dramatically different expressive power. The purpose of this paper is to determine exactly what each model can realize.

### 1.2 Coefficient functions

We work with **coefficient functions** $c : \mathbb{Z} \to \mathbb{Z}$, where $c(k)$ is the coefficient of $t^k$ in a (formal) Laurent polynomial. All coefficient functions arising from polynomials are **finitely supported**: $c(k) = 0$ for all but finitely many $k$. We say $c$ is:

- **non-negative** if $c(k) \ge 0$ for all $k$ (property $\mathrm{NonnegGF}$);
- **palindromic** if $c(k) = c(-k)$ for all $k$ (this is reciprocity in coefficient form).

### 1.3 Contributions

We rigorously establish the five families of results listed in the abstract. The proofs are elementary and constructive, but the conclusions are sharp: the unsigned model is characterized *exactly* (finitely supported non-negative functions), and the signed model is proved *universal* (all finitely supported integer functions). We further show the two models are joined by the connected-sum/Cauchy-product bridge and stress-test the whole picture on the infinite torus family $T(2,2k+1)$.

---

## 2. The two generating-function models

Throughout, $\iota$ denotes an arbitrary finite index type for states, `states` a finite set of states, $a : \iota \to \mathbb{Z}$ an area statistic, and $\mathrm{sign} : \iota \to \mathbb{Z}$ a sign assignment (taking values in $\{+1,-1\}$ in the intended use, though the definitions do not require it).

**Definition 2.1 (Unsigned area generating function).** For a finite set of states with area statistic $a$, define
$$\operatorname{areaGF}(k) \;=\; \#\{\, s \in \text{states} : a(s) = k \,\} \;\in\; \mathbb{Z}_{\ge 0}.$$
The coefficient of $t^k$ is the number of states of area $k$.

**Definition 2.2 (Signed state sum).** For a finite set of states with area statistic $a$ and sign assignment $\mathrm{sign}$, define
$$\operatorname{signedGF}(k) \;=\; \sum_{\substack{s \in \text{states} \\ a(s) = k}} \mathrm{sign}(s).$$
The coefficient of $t^k$ is the *signed* total over states of area $k$.

These model, respectively, an honest lattice-path count and the genuine Alexander state-sum formula $\Delta_K(t) = \sum_s (-1)^{w(s)} t^{a(s)}$.

**Proposition 2.3 (Unsigned coefficients are non-negative).** For any finite state family and area statistic, $\operatorname{areaGF}$ is a non-negative coefficient function.

*Proof.* Each value is the cardinality of a finite set, cast to $\mathbb{Z}$, hence $\ge 0$. $\qquad\blacksquare$

**Proposition 2.4 (Unsigned $\subseteq$ signed).** Every unsigned area generating function equals the signed state sum on the same states and area with all signs equal to $+1$:
$$\operatorname{areaGF}(\text{states}, a) = \operatorname{signedGF}(\text{states}, \mathbf{1}, a).$$

*Proof.* Summing the constant $1$ over the states of area $k$ returns their cardinality. $\qquad\blacksquare$

Proposition 2.3 is the crux of the obstruction. The reduced Alexander polynomial of the trefoil is $t - 1 + t^{-1}$, i.e. the coefficient function $c(1) = c(-1) = 1$, $c(0) = -1$, and $c(k)=0$ otherwise. Since $c(0) = -1 < 0$, Proposition 2.3 shows $c$ is **not** an unsigned area generating function. The naive conjecture is false already at the smallest nontrivial knot.

---

## 3. Universality of the signed state sum

The central theorem is that signs are the *only* thing the unsigned model lacks.

**Theorem 3.1 (Universality).** Let $c : \mathbb{Z} \to \mathbb{Z}$ be any finitely supported coefficient function, with support contained in a finite set $\mathrm{supp} \subset \mathbb{Z}$. Then there exist a finite state family, a sign assignment, and an area statistic whose signed state sum equals $c$:
$$\exists\ \text{states},\ \mathrm{sign},\ a \quad\text{such that}\quad \operatorname{signedGF}(\text{states}, \mathrm{sign}, a) = c.$$

*Proof (constructive).* Define the **universal state family**
$$\text{states} \;=\; \bigsqcup_{k \in \mathrm{supp}} \{k\} \times \{0, 1, \dots, |c(k)|-1\},$$
concretely realized as $\bigcup_{k \in \mathrm{supp}} \{(k, j) : 0 \le j < |c(k)|\} \subset \mathbb{Z}\times\mathbb{N}$. To the state $(k, j)$ assign area $a(k,j) = k$ and sign $\mathrm{sign}(k,j) = \operatorname{sgn}(c(k)) \in \{+1, 0, -1\}$. The states of area $m$ are exactly $\{(m, j) : 0 \le j < |c(m)|\}$, of which there are $|c(m)|$, each carrying sign $\operatorname{sgn}(c(m))$. Hence
$$\operatorname{signedGF}(m) = |c(m)| \cdot \operatorname{sgn}(c(m)) = c(m),$$
using the identity $\operatorname{sgn}(n)\cdot|n| = n$ for every integer $n$ (which also covers $c(m)=0$, giving an empty family and sum $0$). The unions over distinct $k$ are disjoint because the states record their first coordinate $k$, so the biunion's signed sum splits as claimed. $\qquad\blacksquare$

**Corollary 3.2.** Every integer Laurent polynomial — in particular, every Alexander polynomial of every knot — is a signed state sum. No Alexander polynomial can escape the signed model.

The construction is deliberately transparent: it stores each coefficient as (multiplicity) $\times$ (sign). The mathematical content is the recognition that this suffices, i.e. that the sign group $\{\pm 1\}$ is exactly the cokernel obstruction that the unsigned model was missing.

---

## 4. Exact characterization of the unsigned model

Universality is complemented by a matching representation theorem for the unsigned model.

**Theorem 4.1 (Unsigned representability).** Let $c : \mathbb{Z} \to \mathbb{Z}$ be finitely supported and non-negative. Then there exist a finite state family and area statistic with $\operatorname{areaGF}(\text{states}, a) = c$.

*Proof.* Take $\text{states} = \bigcup_{k \in \mathrm{supp}} \{(k, j) : 0 \le j < c(k)\}$ (well-defined since $c(k) \ge 0$) with $a(k,j) = k$. The states of area $m$ number exactly $c(m)$. $\qquad\blacksquare$

**Theorem 4.2 (Characterization).** A coefficient function is an unsigned area generating function if and only if it is finitely supported and non-negative.

*Proof.* Necessity of non-negativity is Proposition 2.3; necessity of finite support is immediate since a finite state family produces finitely many nonzero coefficients. Sufficiency is Theorem 4.1. $\qquad\blacksquare$

Comparing Theorems 3.1 and 4.2 yields the paper's structural punchline:

> **The unsigned model realizes the finitely supported *non-negative* functions; the signed model realizes *all* finitely supported functions. The difference between them is exactly the sign group $\{+1,-1\}$.**

This is why the lattice-path dream fails in its naive form and succeeds in its signed form: the sole missing ingredient is the ability to subtract.

---

## 5. Connected sum and the Cauchy product

Knots combine by **connected sum** $K_1 \# K_2$, under which the Alexander polynomial multiplies: $\Delta_{K_1 \# K_2}(t) = \Delta_{K_1}(t)\cdot\Delta_{K_2}(t)$. The combinatorial counterpart is the Cauchy product of generating functions, realized on the **product state family**.

**Definition 5.1 (Product state family).** Given state families $S$ (with sign $\sigma_S$, area $\alpha_S$) and $T$ (with sign $\sigma_T$, area $\alpha_T$), the product family is $S \times T$ with
$$\text{sign}(i, j) = \sigma_S(i)\,\sigma_T(j), \qquad \text{area}(i, j) = \alpha_S(i) + \alpha_T(j).$$
Areas add; signs multiply.

**Theorem 5.2 (Convolution / Cauchy product).** For every $m \in \mathbb{Z}$,
$$\operatorname{signedGF}\big(S \times T,\ \sigma_S\sigma_T,\ \alpha_S + \alpha_T\big)(m) \;=\; \sum_{i \in S} \sigma_S(i)\cdot \operatorname{signedGF}(T, \sigma_T, \alpha_T)\big(m - \alpha_S(i)\big).$$

*Proof.* Expanding the left side over $S \times T$ and imposing $\alpha_S(i) + \alpha_T(j) = m$, i.e. $\alpha_T(j) = m - \alpha_S(i)$, factors the double sum: fix $i$, sum $\sigma_T(j)$ over states $j$ of area $m - \alpha_S(i)$, then weight by $\sigma_S(i)$ and sum over $i$. Distributivity ($\sigma_S(i)$ pulls into the inner sum) and reindexing complete the identity. $\qquad\blacksquare$

The right-hand side is precisely the coefficient of $t^m$ in the product of the two signed generating polynomials; thus the product state family realizes multiplication of Laurent polynomials, matching connected sum.

**Theorem 5.3 (Multiplicativity of total signed weight).** The total signed weight of the product family factors:
$$\sum_{(i,j) \in S \times T} \sigma_S(i)\,\sigma_T(j) \;=\; \Big(\sum_{i \in S} \sigma_S(i)\Big)\Big(\sum_{j \in T} \sigma_T(j)\Big).$$

*Proof.* This is the sum-over-product identity $\sum_{S\times T} f(i)g(j) = (\sum_S f)(\sum_T g)$. $\qquad\blacksquare$

Evaluating a signed state sum "at $t = 1$" is exactly summing all signs, so Theorem 5.3 is the combinatorial shadow of $\Delta_{K_1 \# K_2}(1) = \Delta_{K_1}(1)\cdot\Delta_{K_2}(1)$.

---

## 6. Reciprocity from an area-negating involution

Reciprocity — palindromy of the coefficient function — is not merely an algebraic symmetry of the polynomial; it can be *manufactured* by a symmetry of the state space.

**Theorem 6.1 (Palindromy from involution).** Suppose a finite state family admits a map $\varphi : \iota \to \iota$ that (i) preserves the family, (ii) is an involution ($\varphi(\varphi(s)) = s$) on it, (iii) negates area ($a(\varphi(s)) = -a(s)$), and (iv) preserves sign ($\mathrm{sign}(\varphi(s)) = \mathrm{sign}(s)$). Then the signed state sum is palindromic:
$$\operatorname{signedGF}(k) = \operatorname{signedGF}(-k) \quad \text{for all } k.$$

*Proof.* The map $\varphi$ restricts to a bijection between states of area $k$ and states of area $-k$, and it preserves signs, so it matches the signed total at $k$ with the signed total at $-k$ term by term. $\qquad\blacksquare$

Together with universality (Theorem 3.1), which realizes any palindromic polynomial as *some* signed state sum, this suggests the refined program: realize each palindrome by a *minimal* family whose symmetry is an honest geometric involution rather than a numerical cancellation. This is Future Direction 1.

---

## 7. The torus family $T(2, 2k+1)$

To show the phenomenon is generic rather than trefoil-specific, we study an explicit infinite family.

**Definition 7.1.** The reduced Alexander polynomial of the torus knot $T(2, 2k+1)$ is the coefficient function
$$\Delta_k(i) \;=\; \begin{cases} (-1)^{i+k}, & -k \le i \le k, \\ 0, & \text{otherwise,}\end{cases}$$
i.e. $\Delta_k(t) = \sum_{i=-k}^{k}(-1)^{i+k}\, t^i = t^k - t^{k-1} + \cdots - t^{-(k-1)} + t^{-k}$.

**Theorem 7.2 (Generalizes the trefoil).** $\Delta_1 = t - 1 + t^{-1}$, the reduced Alexander polynomial of the trefoil.

*Proof.* For $k=1$ the support is $\{-1,0,1\}$ with values $(-1)^{i+1}$: $\Delta_1(1) = 1$, $\Delta_1(0) = -1$, $\Delta_1(-1) = 1$. $\qquad\blacksquare$

**Theorem 7.3 (Reciprocity).** $\Delta_k$ is palindromic: $\Delta_k(i) = \Delta_k(-i)$ for all $i$.

*Proof.* The window $-k \le i \le k$ is symmetric, and $(-1)^{i+k} = (-1)^{-i+k}$ since $i$ and $-i$ have equal parity. $\qquad\blacksquare$

**Theorem 7.4 (Normalization $\Delta_k(1) = 1$).** $\displaystyle\sum_{i=-k}^{k} \Delta_k(i) = 1.$

*Proof.* Reindex $i = j - k$ for $j = 0, \dots, 2k$; the summand becomes $(-1)^{j}$, and $\sum_{j=0}^{2k}(-1)^j = 1$ (an odd number of alternating $\pm 1$ terms starting and ending at $+1$). $\qquad\blacksquare$

**Theorem 7.5 (Determinant $|\Delta_k(-1)| = 2k+1$).** The alternating evaluation satisfies
$$\sum_{i=-k}^{k} (-1)^i \,\Delta_k(i) = (-1)^k (2k+1),$$
so $|\Delta_k(-1)| = 2k+1$.

*Proof.* For each $i$ in the window, $(-1)^i \cdot (-1)^{i+k} = (-1)^{2i+k} = (-1)^k$ is constant. Summing the constant $(-1)^k$ over the $2k+1$ integers in $[-k, k]$ gives $(-1)^k(2k+1)$. $\qquad\blacksquare$

**Theorem 7.6 (Generic negativity).** For every $k \ge 1$, $\Delta_k(k-1) = -1$.

*Proof.* Here $-k \le k-1 \le k$, and $(k-1) + k = 2k - 1$ is odd, so $(-1)^{(k-1)+k} = -1$. $\qquad\blacksquare$

**Corollary 7.7 (Refutation on an infinite family).** For every $k \ge 1$, $\Delta_k$ is *not* an unsigned area generating function.

*Proof.* By Theorem 7.6 it has the negative coefficient $\Delta_k(k-1) = -1$, contradicting Proposition 2.3. $\qquad\blacksquare$

**Theorem 7.8 (But always a signed state sum).** For every $k$, $\Delta_k$ is a signed state sum.

*Proof.* $\Delta_k$ is finitely supported (supported in $[-k,k]$, Theorem 7.3's window), so Theorem 3.1 applies. $\qquad\blacksquare$

Thus the entire infinite torus family exhibits the full phenomenon: reciprocity, correct normalization and determinant, generic failure of the unsigned model, and universal success of the signed model.

---

## 8. Discussion

The results paint a complete and clean picture of the "Alexander polynomial as a lattice-path count" conjecture.

- **The naive conjecture is false, structurally and generically.** Non-negativity of counts (Proposition 2.3) rules out every polynomial with a negative coefficient, and Corollary 7.7 shows this affects an infinite family of knots, not merely the trefoil.
- **The signed conjecture is true, and maximally so.** Universality (Theorem 3.1) shows the signed model captures *all* integer Laurent polynomials. There is no obstruction of divisibility, degree, or magnitude — only positivity, which the sign supplies.
- **The precise gap is the sign group.** The characterization (Theorem 4.2) versus universality dichotomy isolates $\{\pm 1\}$ as the exact difference between the two models.
- **The dictionary is functorial in spirit.** Connected sum matches the Cauchy product (Theorem 5.2) and total signed weight is multiplicative (Theorem 5.3), so the correspondence respects the algebraic operations on both sides.
- **Reciprocity has a combinatorial cause.** An area-negating, sign-preserving involution forces palindromy (Theorem 6.1), pointing toward geometric explanations of Alexander reciprocity.

A caveat on interpretation: universality means the signed model is *expressive*, not that it is *canonical*. Any given Alexander polynomial admits many signed state families; the mathematically interesting question is not existence but *minimality and structure* — realizing the invariant by a family whose combinatorics reflects the knot's geometry (crossings, Seifert surface, torus structure). The torus family is a first example where the family can be read directly from a closed form.

---

## 9. Future directions

**1. Sign-balance forces reciprocity, and conversely.** *Conjecture.* A signed state sum is palindromic if and only if its state family admits an area-negating, sign-preserving involution up to sign cancellation: the fibers over $k$ and $-k$ carry equal total signed weight. Moreover, among all families realizing a fixed palindromic polynomial, there is one of minimum size that is genuinely involutive (a single geometric symmetry). Reciprocity would then be the signed shadow of a symmetry of the *state space*, with the minimal family realizing it as an honest involution rather than a coincidence. Theorem 6.1 gives one direction and Theorem 3.1 realizes any palindrome as some signed sum; the missing bridge is the minimality/involution refinement.

**2. The determinant is the only obstruction to unsigned realizability after a change of variable.** *Conjecture.* For an alternating knot, the substitution $t \mapsto -t$ turns the Alexander polynomial into a genuinely non-negative (unsigned) lattice-path generating function; the failure of unsigned realizability is entirely explained by the sign pattern captured by the determinant $\Delta(-1)$. Alternating knots have coefficients with strictly alternating signs (Crowell–Murasugi), so a single monomial rescaling absorbs the whole sign group $\{\pm 1\}$ identified here as the sole obstruction. The torus family $T(2,2k+1)$ is alternating with coefficients alternating as $(-1)^{i+k}$; the $t\mapsto -t$ rescaling visibly turns it into the all-$+1$ count, giving a template for the general alternating case and a sharp determinant-based prediction.

**3. Connected-sum multiplicativity characterizes the state-sum monoid.** *Conjecture.* The map sending a knot to its signed state sum is a monoid homomorphism from (knots, connected sum) to (integer Laurent polynomials, product), and the state-sum construction can be made functorial so that the product state family of Definition 5.1 is the image of connected sum. Theorem 5.2 and Theorem 5.3 establish the multiplicativity on the generating-function side; the task is to lift it to a structured, natural assignment of state families to knots.

---

## 10. Conclusion

The Alexander polynomial can indeed be read as a lattice-state count — but only if states carry signs. Unsigned counts realize exactly the finitely supported non-negative coefficient functions; signed state sums realize *all* finitely supported integer functions, hence every Alexander polynomial. The gap between the models is precisely the sign group $\{\pm 1\}$, connected sum corresponds to the Cauchy product, reciprocity descends from an area-negating involution, and the infinite torus family $T(2,2k+1)$ displays the entire story at once. A topological fingerprint becomes, with one bit of sign, a counting problem.
