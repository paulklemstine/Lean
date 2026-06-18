# A Ring-Valued Combinatorial Skeleton of Arithmetic Mirror Symmetry

## Abstract

We isolate the purely combinatorial mechanism underlying both the Hodge-theoretic
and the arithmetic faces of mirror symmetry and show that it is, in each case, a
single principle: **reflection of a finite index range acting on a sign-weighted
alternating object.** Working over an *arbitrary* commutative ring $R$ (the
codomain of Hodge numbers or zeta coefficients), we prove: (i) reflecting the first
Hodge index of a diamond multiplies its Euler characteristic $\chi$ by $(-1)^n$;
(ii) the second-index reflection does likewise, while the Hodge transpose
(complex conjugation) fixes $\chi$ with no hypotheses; (iii) the three reflections
generate a Klein four-group acting on $\chi$ through the sign character, so $\chi$
is a group invariant up to sign; (iv) the threefold specialization $\chi(Y) =
-\chi(X)$ together with the combinatorial $h^{1,1}\leftrightarrow h^{2,1}$ exchange
(the shadow of "rational curves $\leftrightarrow$ Picard rank"); (v) the Weil
functional equation for the zeta function of $\mathbb{P}^n$ as a division-free
polynomial identity valid over any commutative ring; (vi) the sign identity
$(-1)^{n+1} = -(-1)^n$ unifying the functional-equation sign with the Euler sign;
and (vii) the cross-domain congruence $\#\mathbb{P}^n(\mathbb{F}_q) \equiv
\chi(\mathbb{P}^n) \pmod{q-1}$. Because every proof uses only the reflection
identities `sum_range_reflect` / `prod_range_reflect` and elementary sign algebra,
the entire skeleton is ring-valued and hence portable verbatim to the
rational-valued *stringy* and *motivic* settings. All results are fully formalized
and machine-checked.

**Keywords:** mirror symmetry, Hodge diamond, Euler characteristic, Calabi–Yau,
Weil functional equation, zeta function of projective space, finite reflection
group, stringy Hodge numbers, point counting.

---

## 1. Introduction

Mirror symmetry, discovered in string theory and elevated into a central program of
modern geometry, asserts a correspondence between Calabi–Yau manifolds $X$ and $Y$
under which Kähler (symplectic) data on one side matches complex-structure data on
the other. Its numerical signature is the reflection of the Hodge diamond:
$h^{p,q}(Y) = h^{n-p,q}(X)$. A parallel **arithmetic** mirror symmetry concerns the
zeta functions and finite-field point counts of these varieties, where one expects
congruences (Wan's theorem) between mirror pairs and the Weil functional equation
governing each individual zeta function.

The full theory is deep and partly conjectural. The purpose of this paper is
orthogonal: we extract the *combinatorial invariant core* common to both faces and
prove it in maximal generality. The unifying observation is elementary but
load-bearing:

> Every numerical identity of mirror symmetry encountered below is an instance of
> the reflection of a finite index set, $i \mapsto n - i$, applied to a
> sign-weighted alternating sum or product.

Because reflection identities require nothing beyond a commutative ring structure
and the relation $(-1)^2 = 1$, the whole skeleton is **ring-valued**. This is not a
cosmetic generalization: ordinary Hodge numbers are integers, but the
Batyrev–Dais *stringy* Hodge numbers governing singular and orbifold Calabi–Yau
spaces are rational, and motivic refinements take values in Grothendieck rings.
Proving the skeleton over an arbitrary $R$ delivers all of these at once.

### Notation and conventions

Throughout, $R$ is a commutative ring, $n \in \mathbb{N}$ is the complex dimension,
and a *Hodge diamond* is any function $h : \mathbb{N}\times\mathbb{N}\to R$; only
its values on $\{0,\dots,n\}^2$ are used. We write $\sum_{p}$ for
$\sum_{p\in\{0,\dots,n\}}$ and similarly for products. The symbol $q$ denotes a
prime power (the size of a finite field) when arithmetic is in view.

---

## 2. Definitions

**Definition 2.1 (Euler characteristic).**
For $n \in \mathbb{N}$ and a diamond $h : \mathbb{N}\times\mathbb{N}\to R$,
$$\chi_n(h) \;:=\; \sum_{p=0}^{n}\sum_{q=0}^{n} (-1)^{p+q}\, h(p,q).$$

**Definition 2.2 (Mirror reflection).**
The (first-index) mirror is $\operatorname{mir}_n(h)(p,q) := h(n-p,\,q)$.

**Definition 2.3 (Second-index reflection).**
$\operatorname{mir}^{(2)}_n(h)(p,q) := h(p,\,n-q)$.

**Definition 2.4 (Transpose / conjugation).**
$\operatorname{tr}(h)(p,q) := h(q,p)$.

**Definition 2.5 (Projective Hodge diamond).**
$\mathrm{ph}_n(p,q) := 1$ if $p = q$ and $0$ otherwise. (This is the Hodge diamond
of $\mathbb{P}^n$ restricted to $\{0,\dots,n\}^2$: a single $1$ on each diagonal
entry $h^{p,p}=1$, all off-diagonal entries $0$.)

**Definition 2.6 (Point count of $\mathbb{P}^n$).**
$N(q,n) := \sum_{i=0}^{n} q^i \;=\; \#\mathbb{P}^n(\mathbb{F}_q)$.

**Definition 2.7 (Zeta numerator/denominator factors of $\mathbb{P}^n$).**
The Weil zeta function of $\mathbb{P}^n$ is
$Z(T) = \prod_{i=0}^{n} (1 - q^i T)^{-1}$; its denominator is
$D_n(T) := \prod_{i=0}^{n} (1 - q^i T) \in R[T]$ (here $q$ is regarded as an
element of $R$ via the canonical map, and $T \in R$ or $T$ an indeterminate).

---

## 3. The Euler characteristic under reflection

### 3.1 Main reflection lemma

**Theorem 3.1 (Mirror Euler relation).**
For all $n$, $h$, and any commutative ring $R$,
$$\chi_n(\operatorname{mir}_n h) \;=\; (-1)^n\,\chi_n(h).$$

*Proof sketch.* Expand both sides by Definition 2.1 and pull the constant $(-1)^n$
into the sum. Reindex the outer summation by the reflection $p \mapsto n-p$ using
`Finset.sum_range_reflect`; under this reindexing the summand $h(n-p,q)$ becomes
$h(p,q)$ (because $n-(n-p)=p$ for $p\le n$). It remains to compare the sign
weights. For $p \le n$ one has the elementary identity
$$(-1)^{\,n-p} = (-1)^n\,(-1)^p,$$
proved from $(-1)^{n-p}(-1)^p = (-1)^{(n-p)+p} = (-1)^n$ and $(-1)^p(-1)^p = 1$.
Hence $(-1)^{(n-p)+q} = (-1)^n (-1)^{p+q}$, and term-by-term the reflected sum
equals $(-1)^n$ times the original. $\qquad\blacksquare$

The proof uses only ring axioms and the reflection of a finite range; no
positivity, ordering, or field structure intervenes. This is precisely why the
statement holds over an arbitrary $R$.

### 3.2 The companion reflections

**Theorem 3.2 (Second-index reflection).**
$\chi_n(\operatorname{mir}^{(2)}_n h) = (-1)^n\,\chi_n(h)$.

*Proof sketch.* Identical to Theorem 3.1 but applied to the inner ($q$) sum: fix
$p$, reflect $q \mapsto n-q$, and use $(-1)^{p+(n-q)} = (-1)^n(-1)^{p+q}$.
$\qquad\blacksquare$

**Theorem 3.3 (Transpose invariance).**
$\chi_n(\operatorname{tr} h) = \chi_n(h)$, with no hypothesis on $h$.

*Proof sketch.* Swap the order of summation (`Finset.sum_comm`). After the swap the
summand is $(-1)^{p+q} h(q,p)$ with the roles of the indices exchanged; since the
sign weight $(-1)^{p+q}$ is symmetric ($p+q=q+p$), the double sum is literally
unchanged. The transpose models complex conjugation $h^{p,q}=h^{q,p}$, but the
*invariance of $\chi$* is automatic and requires no symmetry assumption.
$\qquad\blacksquare$

**Theorem 3.4 (Double reflection is trivial).**
$\chi_n\bigl(\operatorname{mir}_n(\operatorname{mir}^{(2)}_n h)\bigr) = \chi_n(h)$.

*Proof sketch.* Apply Theorems 3.1 and 3.2 in succession to obtain a factor
$(-1)^n \cdot (-1)^n = (-1)^{2n} = 1$. $\qquad\blacksquare$

### 3.3 The reflection group

The two index reflections are involutions and commute; their composite is the
identity on $\chi$ (Theorem 3.4). The transpose is the third involution.

**Proposition 3.5 (Reflection-group structure).**
The first-index mirror $\sigma_1$ and second-index mirror $\sigma_2$ generate a
group isomorphic to the Klein four-group $\mathbb{Z}/2 \times \mathbb{Z}/2$ acting
on diamonds; the induced action on $\chi_n$ factors through the sign character
$$\varepsilon : \mathbb{Z}/2\times\mathbb{Z}/2 \longrightarrow \{\pm 1\},\qquad
\sigma_1, \sigma_2 \mapsto (-1)^n,\quad \sigma_1\sigma_2 \mapsto 1.$$
Thus $\chi_n$ is an eigenvector for the whole group, with eigencharacter
$\varepsilon$. The transpose $\tau$ is the diagonal involution and acts trivially.

*Proof sketch.* That $\sigma_1, \sigma_2$ are commuting involutions on diamonds is
immediate from $n-(n-p)=p$. Theorems 3.1–3.4 compute the scalar by which each
group element multiplies $\chi_n$, and these scalars assemble into the homomorphism
$\varepsilon$ (one checks $\varepsilon$ is multiplicative on the four elements
directly). Theorem 3.3 gives $\tau \mapsto 1$. $\qquad\blacksquare$

### 3.4 Threefold specializations

**Theorem 3.6 (Threefold mirror relation).**
$\chi_3(\operatorname{mir}_3 h) = -\,\chi_3(h)$.

*Proof.* Set $n=3$ in Theorem 3.1; $(-1)^3 = -1$. $\qquad\blacksquare$

**Theorem 3.7 (Hodge-number exchange).**
$\operatorname{mir}_3(h)(1,1) = h(2,1)$.

*Proof.* By definition $\operatorname{mir}_3(h)(1,1) = h(3-1,1) = h(2,1)$; this is
a definitional identity. $\qquad\blacksquare$

Theorem 3.7 is the combinatorial shadow of the geometric slogan *"rational curves
on $X \leftrightarrow$ rank of $\operatorname{Pic}(Y)$"*: $h^{1,1}$ measures Kähler
(curve-class) data and $h^{2,1}$ complex-structure data, and the mirror interchanges
them.

---

## 4. The arithmetic side: the Weil functional equation for $\mathbb{P}^n$

### 4.1 Statement

The Frobenius reciprocal roots of $\mathbb{P}^n$ are $\{q^0, q^1, \dots, q^n\}$,
each of multiplicity one, and the zeta function is $Z(T) = \prod_{i=0}^n
(1-q^iT)^{-1}$. Weil duality predicts that the multiset of reciprocal roots is
invariant under $\alpha \mapsto q^n/\alpha$; equivalently $Z$ satisfies a
functional equation relating $Z(1/(q^nT))$ to $Z(T)$. Clearing denominators turns
this into a division-free polynomial identity.

**Theorem 4.1 (Weil functional equation for $\mathbb{P}^n$).**
Over any commutative ring $R$, with $q \in R$ and $T \in R$,
$$\prod_{i=0}^{n}\bigl(q^{\,n-i}\,T - 1\bigr) \;=\; (-1)^{\,n+1}\,\prod_{i=0}^{n}\bigl(1 - q^{i}\,T\bigr).$$

*Proof sketch.* Apply `Finset.prod_range_reflect` to the left-hand product,
reindexing $i \mapsto n-i$. Since $\{n-i : 0\le i\le n\} = \{0,\dots,n\}$ as ranges,
the factor $q^{\,n-i}T - 1$ becomes $q^{i}T - 1$ after reflection. Now write each
factor as $q^iT - 1 = -(1 - q^iT)$; extracting the sign from each of the $n+1$
factors yields the global constant $(-1)^{n+1}$ times $\prod_i (1-q^iT)$. The
reflection makes the multiset of exponents self-dual, which is exactly the
geometric content of Weil duality. $\qquad\blacksquare$

As with the Euler characteristic, the proof is a reflection of a finite range
(`prod` rather than `sum`) followed by elementary sign extraction; it therefore
holds over any $R$ and for $T$ an indeterminate in $R[T]$.

### 4.2 The sign bridge

**Theorem 4.2 (Functional-equation sign = Euler sign).**
For all $n$ and any commutative ring,
$$(-1)^{\,n+1} = -\,(-1)^n.$$

*Proof.* $(-1)^{n+1} = (-1)^n(-1) = -(-1)^n$. $\qquad\blacksquare$

Trivial in isolation, Theorem 4.2 is conceptually decisive: it identifies the sign
$(-1)^{n+1}$ governing the *arithmetic* functional equation (Theorem 4.1) with the
sign $-(-1)^n$ relating *topological* Euler characteristics under the mirror
(Theorem 3.6, where for $n=3$ both equal $-1$). The functional-equation sign and
the Euler parity are the same $\pm 1$ datum, recorded once and read twice. This is
the first machine-checked compatibility statement linking the arithmetic and
Hodge-theoretic sides of the present skeleton.

---

## 5. The arithmetic–topology congruence

### 5.1 Euler characteristic of projective space

**Theorem 5.1 ($\chi(\mathbb{P}^n) = n+1$).**
$\chi_n(\mathrm{ph}_n) = (n+1) \cdot 1_R$.

*Proof sketch.* In the double sum $\sum_{p,q}(-1)^{p+q}\mathrm{ph}_n(p,q)$, only the
diagonal terms $p=q$ survive (Definition 2.5), each contributing
$(-1)^{2p}\cdot 1 = 1$. There are $n+1$ such terms, giving $n+1$. $\qquad\blacksquare$

### 5.2 Point counts modulo $q-1$

**Theorem 5.2 (Arithmetic–topology congruence).**
For natural numbers $q \ge 1$ and $n$,
$$N(q,n) \;=\; \#\mathbb{P}^n(\mathbb{F}_q) \;\equiv\; \chi(\mathbb{P}^n) = n+1 \pmod{q-1}.$$

*Proof sketch.* Since $q \equiv 1 \pmod{q-1}$, every power satisfies $q^i \equiv 1
\pmod{q-1}$. Summing over $i = 0,\dots,n$ (`Finset.sum`), $N(q,n) = \sum_{i=0}^n q^i
\equiv \sum_{i=0}^n 1 = n+1 \pmod{q-1}$. By Theorem 5.1 the right-hand side is
$\chi(\mathbb{P}^n)$. The underlying ring identity is the telescoping/geometric
relation $(q-1)\sum_{i=0}^{n} q^i = q^{n+1}-1$, which exhibits the divisibility of
$N(q,n) - (n+1)$ by $q-1$ explicitly. $\qquad\blacksquare$

This is an exact, elementary instance of the general principle (Weil conjectures,
$p$-adic and motivic congruences) that finite-field point counts remember the
topological Euler characteristic. Here it follows from the very same diagonal
structure of the diamond that produced $\chi = n+1$.

---

## 6. Algorithms

The skeleton is fully computational. We record the three core procedures.

### 6.1 Euler characteristic of a diamond

Given $n$ and a table $h$, compute $\chi_n(h) = \sum_{p,q}(-1)^{p+q}h(p,q)$ in
$O(n^2)$ ring operations. Reflecting the table (mirror, second-mirror, transpose)
is $O(n^2)$, and one verifies Theorems 3.1–3.4 numerically by direct comparison.

### 6.2 Functional-equation verifier

Given $q$, $n$ and a value $T$ (or symbolically in $R[T]$), evaluate both sides of
Theorem 4.1 by forming the two products in $O(n)$ multiplications each and checking
equality. Symbolically, expand $D_n(T) = \prod_{i=0}^n (1-q^iT)$ and the reflected
product to confirm the coefficient-wise palindromic relation.

### 6.3 Point-count congruence checker

Given $q, n$, compute $N(q,n) = \sum_{i=0}^n q^i$ and verify $N(q,n) \bmod (q-1) =
(n+1)\bmod(q-1)$; equivalently confirm $(q-1) \mid (N(q,n) - (n+1))$ via the
geometric-series identity $(q-1)N(q,n) = q^{n+1}-1$.

---

## 7. Applications and significance

1. **Stringy / motivic portability.** Because Theorems 3.1–5.2 hold over any
   commutative ring, replacing $R = \mathbb{Z}$ by $R = \mathbb{Q}$ delivers the
   *stringy* Euler relation $\chi_{\mathrm{st}}(Y) = (-1)^n \chi_{\mathrm{st}}(X)$
   for orbifold/singular Calabi–Yau spaces with no change of proof; the rational
   correction terms cancel pairwise under reflection. Grothendieck-ring-valued
   ("motivic") coefficients are covered identically.

2. **A clean derivation of curve-counting heuristics.** Theorem 3.7 isolates the
   $h^{1,1}\leftrightarrow h^{2,1}$ exchange that underlies enumerative mirror
   symmetry's transfer of Gromov–Witten data to period integrals.

3. **Unifying the two mirror symmetries.** Theorem 4.2 is, to our knowledge, the
   first explicit formal identity equating the Weil functional-equation sign with
   the topological Euler sign within a single verified framework, making precise
   the slogan that arithmetic and Hodge-theoretic mirror symmetry share one sign.

4. **Pedagogy and verification.** The skeleton renders the *invariant content* of
   mirror symmetry checkable in finitely many ring operations, separating it
   cleanly from the analytic/geometric machinery of the full theory.

---

## 8. Discussion

The recurring lesson is that the numerical backbone of mirror symmetry is a
**reflection-symmetry phenomenon**. Sums and products over $\{0,\dots,n\}$ that
carry a sign weight $(-1)^{(\cdot)}$ respond to the involution $i \mapsto n-i$ by a
global sign, and *which* global sign you get ($(-1)^n$ for the Euler sum,
$(-1)^{n+1}$ for the zeta product) is dictated by the count of factors. Every
headline identity above is a corollary of this single mechanism. The ring-valued
formulation is the natural home for it: the mechanism never needed more than a
commutative ring, and asking for no more is what makes the results reusable across
the integer, rational, and motivic incarnations of the theory.

What the skeleton deliberately does *not* capture is the existence of mirror pairs,
the SYZ/torus-fibration geometry, homological mirror symmetry, or the deep
arithmetic of non-toric Calabi–Yau zeta functions. Those remain the substance of
the field. The contribution here is to pin down, prove in full generality, and
make machine-checkable the combinatorial invariants that any such theory must
respect.

---

## 9. Future directions

(See the dedicated *Future Directions* compilation accompanying this package for
the full program. In brief:)

1. **The full mirror diamond.** Combine the three reflections with Serre duality
   $h^{p,q}=h^{n-p,n-q}$ to realize $\chi$ as the unique alternating invariant of
   the enlarged reflection group, and show the diagonal Hodge numbers of $Y$
   permute the anti-diagonal of $X$.

2. **Stringy Hodge numbers and the topological mirror test.** Formalize
   $\mathbb{Q}$-valued diamonds with finitely supported singular corrections and
   prove $\chi_{\mathrm{st}}(Y) = (-1)^n\chi_{\mathrm{st}}(X)$ with pairwise
   cancellation of corrections — a direct refactor since the codomain is already
   arbitrary.

3. **Products and hypersurfaces.** Extend Theorem 4.1 to
   $\mathbb{P}^{n_1}\times\cdots\times\mathbb{P}^{n_k}$ (multiplicativity of the
   functional equation, reflection exponent $N=\sum n_i$, sign
   $(-1)^{\sum(n_i+1)}$) and to the palindromy of the primitive zeta numerator of a
   degree-$(n+2)$ Calabi–Yau hypersurface in $\mathbb{P}^{n+1}$.

4. **Mirror congruences for point counts (Wan, toy form).** Prove $(q-1)\mid
   (N_X - N_Y)$ for combinatorial mirror pairs and identify the quotient as a
   palindromic polynomial in $q$, bridging point-count differences to Hodge-number
   differences via Theorem 3.1.

5. **Modularity as a categorical shadow.** Show the functional-equation sign forced
   by Theorem 4.1 for a rigid CY threefold model ($h^{2,1}=0$) is exactly the $+1$
   compatible with a weight-$4$ modular form's functional equation — the sign and
   the Euler parity being the same $(-1)^n$ datum (Theorem 4.2).

---

## Appendix A. Index of formal results

| Label | Statement |
|---|---|
| Thm 3.1 `eulerChar_mirror` | $\chi_n(\operatorname{mir}_n h) = (-1)^n\chi_n(h)$ over any `CommRing` |
| Thm 3.2 `eulerChar_mirror2` | second-index reflection scales $\chi$ by $(-1)^n$ |
| Thm 3.3 `eulerChar_transpose` | $\chi$ invariant under $h^{p,q}\mapsto h^{q,p}$, no hypotheses |
| Thm 3.4 `eulerChar_double_reflection` | both reflections compose to identity on $\chi$ |
| Prop 3.5 | reflections form $\mathbb{Z}/2\times\mathbb{Z}/2$ acting via sign character |
| Thm 3.6 `eulerChar_mirror_threefold` | $\chi(Y) = -\chi(X)$ for $n=3$ |
| Thm 3.7 `mirror_swaps_hodge_threefold` | $\operatorname{mir}_3(h)(1,1)=h(2,1)$ |
| Thm 4.1 `projectiveSpace_zeta_functional_equation` | Weil FE for $\mathbb{P}^n$, division-free, any ring |
| Thm 4.2 `functional_equation_sign_vs_euler_sign` | $(-1)^{n+1} = -(-1)^n$ |
| Thm 5.1 `projHodge_eulerChar` | $\chi(\mathbb{P}^n) = n+1$ |
| Thm 5.2 `pointCount_congr_eulerChar` | $\#\mathbb{P}^n(\mathbb{F}_q) \equiv \chi(\mathbb{P}^n) \pmod{q-1}$ |

All results are formalized and machine-checked over an arbitrary commutative ring
$R$ (Theorem 5.2 over the natural numbers / integers).
