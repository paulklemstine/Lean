# Intersection Forms and the Donaldson Obstruction: A Verified Algebraic Core of the Smooth 4D Poincaré Story

## Abstract

The smooth four-dimensional Poincaré conjecture — whether every smooth closed
4-manifold homotopy equivalent to $S^4$ is diffeomorphic to $S^4$ — is one of the major
open problems of low-dimensional topology. The conceptual landscape around it is
governed by the interplay of two Fields-Medal results: Freedman's topological
classification of simply-connected 4-manifolds (which realizes essentially *every*
unimodular symmetric integral form) and Donaldson's diagonalization theorem (which
forces the intersection form of a *smooth* positive-definite simply-connected
4-manifold to be standard, i.e. equivalent over $\mathbb{Z}$ to $\langle 1\rangle^n$).
The chasm between these two statements is exactly the gap between the topological and
smooth categories in dimension four.

This paper presents a fully verified formalization of the **algebraic core** of that
mechanism. We model the intersection form as a symmetric integral Gram matrix with an
attached quadratic value function, and we isolate the three decisive predicates:
unimodularity (Poincaré duality), evenness (spin), and standard-diagonalizability
(Donaldson's conclusion). Our central result, `even_not_stdDiagonalizable`, states that
a positive-rank even form is never standard-diagonalizable; this is the precise
algebraic engine through which gauge theory forbids even definite forms on smooth
4-manifolds. We instantiate it with the $E_8$ Cartan form — even, unimodular,
positive-definite, of rank $8$ — whose explicit integral inverse certifies
unimodularity, to conclude that $E_8$ is *not* the intersection form of any smooth
closed simply-connected 4-manifold, even though Freedman realizes it topologically. We
also record the boundary fact that the standard form $\langle 1\rangle^n$ is odd, and
the trivial rank-$0$ sphere form, which together explain why the intersection form
cannot detect exotic smooth structures on homotopy 4-spheres. All results are
`sorry`-free.

**Keywords:** intersection form, Donaldson's theorem, $E_8$ lattice, unimodular
quadratic form, spin 4-manifold, smooth Poincaré conjecture, gauge theory, formal
verification.

---

## 1. Introduction

### 1.1 The problem

A closed topological 4-manifold $M$ that is *homotopy equivalent* to the 4-sphere $S^4$
is, by Freedman's solution of the topological 4-dimensional Poincaré conjecture,
*homeomorphic* to $S^4$. The smooth analogue replaces "homeomorphic" with
"diffeomorphic":

> **Smooth 4-dimensional Poincaré Conjecture (SPC4).** Every smooth closed 4-manifold
> homotopy equivalent to $S^4$ is diffeomorphic to $S^4$.

SPC4 remains open. It is the only dimension in which the smooth Poincaré conjecture is
neither known to hold nor known to fail. In dimensions $\ge 5$ the $h$-cobordism theorem
and surgery resolve the question; in dimensions $\le 3$ geometrization and the rigidity
of low dimensions settle it (Perelman for $n=3$). Dimension four is uniquely pathological:
it is the only dimension supporting exotic $\mathbb{R}^4$'s, and the only one in which the
smooth and topological categories diverge so dramatically.

### 1.2 Intersection forms as the elementary invariant

For a closed oriented 4-manifold $M$ the cup product
$$H^2(M;\mathbb{Z}) \times H^2(M;\mathbb{Z}) \to H^4(M;\mathbb{Z}) \cong \mathbb{Z}$$
restricts, modulo torsion, to a symmetric bilinear pairing $Q_M$ on the free abelian
group $H^2(M;\mathbb{Z})/\mathrm{tors} \cong \mathbb{Z}^n$. Choosing a basis represents
$Q_M$ by a symmetric integer matrix $G$, its **Gram matrix**, and the self-pairing of a
homology class $v$ is $Q_M(v) = v^{\mathsf T} G v$. Three structural facts about $Q_M$
control the theory:

1. **Poincaré duality** makes $Q_M$ *unimodular*: $\det G = \pm 1$.
2. $M$ is *spin* if and only if $Q_M$ is *even*: $Q_M(v) \in 2\mathbb{Z}$ for all $v$.
3. The simplest definite forms are *standard*: equivalent over $\mathbb{Z}$ to
   $\langle 1\rangle^n = \mathrm{diag}(1,\dots,1)$.

### 1.3 Freedman versus Donaldson

The decisive tension is between two theorems.

> **Theorem (Freedman, 1982).** Every unimodular symmetric integral form is the
> intersection form of a closed simply-connected *topological* 4-manifold; in the odd
> case the manifold is unique, in the even case there are exactly two.

> **Theorem (Donaldson, 1983).** If a *smooth* closed simply-connected 4-manifold has a
> positive-definite intersection form, then that form is standard-diagonalizable, i.e.
> equivalent over $\mathbb{Z}$ to $\langle 1\rangle^n$.

Freedman says topology imposes (almost) no constraint; Donaldson says smoothness imposes
a draconian one. The set of forms realized topologically but not smoothly is the
measurable content of the smooth/topological gap, and the $E_8$ form is its most famous
inhabitant.

### 1.4 Contribution

We formalize the **algebraic mechanism** that converts Donaldson's analytic conclusion
into an obstruction, in a complete, machine-verified, `sorry`-free development. The deep
analytic inputs (Donaldson's and Freedman's theorems) are treated as named external
facts; everything algebraic downstream of them is proved from scratch. The deliverables
are:

- a lightweight model `IntersectionForm n` of the cup-product pairing;
- the predicates `Unimodular`, `IsEven`, `StdDiagonalizable`;
- the change-of-basis identity `value_basisChange`;
- the diagonal criterion `isEven_of_even_diag`;
- the **Donaldson obstruction** `even_not_stdDiagonalizable`;
- the explicit $E_8$ Cartan matrix `E8mat` with integral inverse `E8inv`, and the
  corollary that $E_8$ is not standard-diagonalizable;
- the boundary fact `stdForm_not_even`;
- the trivial `sphereForm` of $S^4$.

---

## 2. Definitions

Throughout, $n \in \mathbb{N}$ and all matrices are over $\mathbb{Z}$. We write
$v \cdot w$ for the dot product and $G \, v$ for matrix–vector multiplication.

**Definition 2.1 (Intersection form).** An *intersection form* of rank $n$ is a pair
$Q = (G, s)$ where $G \in M_n(\mathbb{Z})$ is the Gram matrix and $s$ is a proof that $G$
is symmetric ($G^{\mathsf T} = G$). In Lean:

```lean
structure IntersectionForm (n : ℕ) where
  gram   : Matrix (Fin n) (Fin n) ℤ
  isSymm : gram.IsSymm
```

**Definition 2.2 (Value / quadratic function).** For $v : \mathrm{Fin}\,n \to \mathbb{Z}$,
$$Q.\mathrm{value}(v) \;=\; v \cdot (G\, v) \;=\; \sum_{i,j} v_i\, G_{ij}\, v_j .$$

**Definition 2.3 (Unimodular).** $Q$ is *unimodular* if $\det G$ is a unit of
$\mathbb{Z}$ (equivalently $\det G = \pm 1$). This encodes Poincaré duality.

**Definition 2.4 (Even).** $Q$ is *even* if $Q.\mathrm{value}(v)$ is even for every
integer vector $v$. This encodes the spin condition.

**Definition 2.5 (Standard-diagonalizable).** $Q$ is *standard-diagonalizable* if there
is $T \in M_n(\mathbb{Z})$ with $\det T$ a unit and
$$T^{\mathsf T}\, G\, T = I_n .$$
This is exactly Donaldson's conclusion: $Q$ is integrally equivalent to
$\langle 1\rangle^n$.

**Definition 2.6 (Standard form).** $\mathrm{stdForm}(n) := (I_n, \text{symm})$, the
identity Gram matrix — the intersection form of $\#^n \mathbb{CP}^2$.

**Definition 2.7 (Sphere form).** $\mathrm{sphereForm} := \mathrm{stdForm}(0)$, the
unique rank-$0$ form — the intersection form of $S^4$.

**Definition 2.8 ($E_8$ form).** $E_8 := (E_8\text{mat}, \text{symm})$ where the Cartan
Gram matrix is
$$E_8\text{mat} = \begin{pmatrix}
2 & -1 & 0 & 0 & 0 & 0 & 0 & 0\\
-1 & 2 & -1 & 0 & 0 & 0 & 0 & 0\\
0 & -1 & 2 & -1 & 0 & 0 & 0 & 0\\
0 & 0 & -1 & 2 & -1 & 0 & 0 & 0\\
0 & 0 & 0 & -1 & 2 & -1 & 0 & -1\\
0 & 0 & 0 & 0 & -1 & 2 & -1 & 0\\
0 & 0 & 0 & 0 & 0 & -1 & 2 & 0\\
0 & 0 & 0 & 0 & -1 & 0 & 0 & 2
\end{pmatrix}.$$
All diagonal entries equal $2$; the off-diagonal pattern is the $E_8$ Dynkin
adjacency (with one trivalent node). Its determinant is $1$, and an explicit integral
inverse `E8inv` is exhibited.

---

## 3. Main Results

### 3.1 Change of basis

**Lemma 3.1 (`value_basisChange`).** For any $T \in M_n(\mathbb{Z})$ and integer vector
$v$,
$$Q.\mathrm{value}(T v) \;=\; v \cdot \big( T^{\mathsf T} G\, T \big)\, v .$$

*Proof sketch.* Expand $Q.\mathrm{value}(Tv) = (Tv) \cdot (G (Tv))$. Using the standard
matrix identities $w \cdot (A u) = (A^{\mathsf T} w) \cdot u$ and associativity of matrix
multiplication, transport $T$ across the dot product:
$$(Tv)\cdot(G T v) = v \cdot (T^{\mathsf T} (G T v)) = v \cdot ((T^{\mathsf T} G T) v).$$
The Lean proof unfolds `value`, rewrites with the `vecMul`/`mulVec`/`dotProduct`
transport lemmas, and reassociates the triple product. $\qquad\blacksquare$

This identity is the workhorse: it says the value function transforms a basis change $T$
into a *congruence* $G \mapsto T^{\mathsf T} G T$ of Gram matrices, the natural
equivalence relation on quadratic forms.

### 3.2 The diagonal criterion for evenness

**Lemma 3.2 (`isEven_of_even_diag`).** If every diagonal entry $G_{ii}$ is even, then
$Q$ is even.

*Proof sketch.* Write
$$Q.\mathrm{value}(v) = \sum_{i,j} v_i G_{ij} v_j .$$
Split the double sum using symmetry $G_{ij} = G_{ji}$ into a diagonal part and twice the
strict upper triangle:
$$\sum_{i,j} v_i G_{ij} v_j \;=\; \sum_i v_i^2 G_{ii} \;+\; 2\sum_i \sum_{j > i} v_i G_{ij} v_j .$$
The second term is manifestly divisible by $2$. Each summand of the first term is
divisible by $2$ because $G_{ii}$ is even by hypothesis. Hence the total is even. The
Lean proof establishes the symmetric splitting by an induction on $n$ (a general lemma
about symmetric arrays $f$ with $f_{ij} = f_{ji}$), then concludes by `even_iff_two_dvd`
and divisibility of sums. $\qquad\blacksquare$

The converse also holds (taking $v = e_i$ shows $G_{ii} = Q.\mathrm{value}(e_i)$ must be
even), so evenness of the *form* is equivalent to evenness of the *diagonal*. This
reduces a quantifier over all integer vectors to a finite check.

### 3.3 The Donaldson obstruction

**Theorem 3.3 (`even_not_stdDiagonalizable`).** If $n > 0$ and $Q$ is even, then $Q$ is
*not* standard-diagonalizable.

*Proof sketch.* Suppose for contradiction that $T$ witnesses
$T^{\mathsf T} G T = I_n$ with $\det T$ a unit. Let $e_0 = \mathrm{Pi.single}\;0\;1$ be
the first standard basis vector (well-defined since $n > 0$) and set $w = T e_0$. By
Lemma 3.1,
$$Q.\mathrm{value}(w) = e_0 \cdot (T^{\mathsf T} G T)\, e_0 = e_0 \cdot I_n\, e_0 = e_0 \cdot e_0 = 1 .$$
But $Q$ is even, so $Q.\mathrm{value}(w)$ must be even; this forces $\mathrm{Even}(1)$ in
$\mathbb{Z}$, which is false (`by decide`). Contradiction. $\qquad\blacksquare$

This is the algebraic heart of Donaldson's theorem as an *obstruction*. The standard
form has a vector of value $1$ (an odd value); evenness forbids odd values; so no even
form can become standard. Chained with Donaldson's analytic theorem — *smooth definite
$\Rightarrow$ standard* — it yields: **no smooth closed simply-connected 4-manifold has
an even positive-definite intersection form.**

### 3.4 The boundary case

**Theorem 3.4 (`stdForm_not_even`).** For $n \ge 1$, the standard form $\langle 1\rangle^n$
is not even.

*Proof sketch.* Evaluate at $e_0$: $\mathrm{stdForm}(n).\mathrm{value}(e_0) =
e_0^{\mathsf T} I_n e_0 = 1$, which is odd. A `simp`/`decide` computation finishes.
$\qquad\blacksquare$

This confirms that the evenness hypothesis in Theorem 3.3 is essential and not vacuous:
the standard form is itself a positive-rank form that *is* standard-diagonalizable
(trivially, with $T = I$) precisely because it is odd.

### 3.5 $E_8$ is not standard-diagonalizable

**Proposition 3.5 ($E_8$ is even).** $E_8$ is even.

*Proof.* Every diagonal entry of $E_8\text{mat}$ equals $2$, which is even; apply
Lemma 3.2. $\qquad\blacksquare$

**Proposition 3.6 ($E_8$ is unimodular).** $\det(E_8\text{mat}) = 1$; in particular
$E_8$ is unimodular.

*Proof.* The explicit matrix `E8inv` satisfies $E_8\text{mat}\cdot E_8\text{inv} = I_8$
by direct computation over $\mathbb{Z}$, so $E_8\text{mat}$ is invertible over
$\mathbb{Z}$ and its determinant is a unit; a determinant computation gives the value
$1$. $\qquad\blacksquare$

**Corollary 3.7 (`E8_not_stdDiagonalizable`).** $E_8$ is not standard-diagonalizable.

*Proof.* $E_8$ has rank $8 > 0$ and is even (Prop. 3.5); apply Theorem 3.3.
$\qquad\blacksquare$

**Interpretation.** The $E_8$ form is positive-definite, even, and unimodular of rank
$8$. By Freedman, it is realized by a closed simply-connected *topological* 4-manifold.
By Corollary 3.7 it is not standard, so by Donaldson's theorem it is *not* the
intersection form of any *smooth* closed simply-connected 4-manifold. Thus $E_8$
witnesses, in the cleanest possible algebraic form, the failure of smoothing in
dimension four — a topological 4-manifold with no smooth structure.

### 3.6 The sphere form and the limits of the invariant

**Proposition 3.8 (sphere form is trivial-standard).** $\mathrm{sphereForm} =
\mathrm{stdForm}(0)$ is unimodular, even, and standard-diagonalizable.

*Proof.* All statements are vacuous over the empty index type $\mathrm{Fin}\,0$:
$\det$ of the $0\times 0$ matrix is $1$ (unimodular), the value of the unique (empty)
vector is $0$ (even), and $T = I_0$ witnesses standardness. $\qquad\blacksquare$

This is the structural reason the intersection form cannot settle SPC4: every homotopy
4-sphere has the same trivial rank-$0$ form, so the invariant is blind to any putative
exotic smooth structure on $S^4$. The very tool that exposes $E_8$ is silent on the
sphere.

---

## 3.7 Worked examples

To make the abstract statements concrete, we record several explicit forms and the
verdicts our results deliver.

**Example A (the standard form $\langle 1\rangle^2$).** Here $G = I_2$. The value at
$v = (a,b)$ is $Q(v) = a^2 + b^2$. The diagonal entries are $1$ and $1$, both odd, so by
the diagonal criterion the form is odd; indeed $Q(1,0) = 1$. The form is trivially
standard-diagonalizable with $T = I_2$, and unimodular since $\det I_2 = 1$. It is the
intersection form of $\mathbb{CP}^2 \# \mathbb{CP}^2$, and it is realized smoothly — odd
definite forms are precisely the ones Donaldson's theorem allows.

**Example B (the hyperbolic form $H$).** Take
$$H = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}.$$
Its diagonal entries are both $0$ (even), so $H$ is even by the diagonal criterion;
explicitly $Q(a,b) = 2ab$, always even. It is unimodular ($\det H = -1$). However $H$ is
*indefinite* (it takes both signs: $Q(1,1) = 2 > 0$, $Q(1,-1) = -2 < 0$), so Donaldson's
definite hypothesis does not apply; $H$ is realized smoothly by $S^2 \times S^2$. This
shows that evenness alone does not obstruct smoothness — definiteness is essential to the
Donaldson story, even though our purely algebraic Theorem 3.3 about *standard*-
diagonalizability holds regardless of signature.

**Example C ($E_8$, the obstruction in action).** With $G = E_8\text{mat}$ the diagonal
is $(2,2,2,2,2,2,2,2)$, all even, so $E_8$ is even (Prop. 3.5). The minimum of $Q(v)$
over nonzero $v \in \{-1,0,1\}^8$ is $2$, consistent with positive-definiteness and with
the fact that the shortest vectors of the $E_8$ lattice have norm $2$. The explicit
inverse `E8inv` multiplies $E_8\text{mat}$ to $I_8$, certifying $\det = 1$. By
Theorem 3.3, $E_8$ is not standard-diagonalizable. The contrast with Example A is the
entire point: $\langle 1\rangle^8$ and $E_8$ are *both* positive-definite unimodular rank-8
forms, and they are equivalent over $\mathbb{R}$ (and over $\mathbb{Q}_p$ for all $p$),
but over $\mathbb{Z}$ they are inequivalent — and only the odd one is smoothly realizable.

**Example D ($E_8 \oplus E_8$ versus $2 E_8 \oplus 3 H$).** Iterating the obstruction,
the rank-16 form $E_8 \oplus E_8$ is again even, unimodular, positive-definite, and not
standard, hence not smoothly realizable as a definite form. The famous indefinite
diagonalization $2 E_8 \oplus 3 H \cong$ the $K3$ intersection form illustrates that once
indefiniteness is allowed, even forms *do* occur smoothly ($K3$ is a smooth spin
4-manifold). The dividing line is exactly definiteness, as Donaldson's theorem demands.

These examples bracket the theorem from both sides: Example A shows odd definite forms are
fine, Examples B and D show even indefinite forms are fine, and Example C shows the
forbidden region — even *and* definite *and* positive rank.

---

## 4. Algorithms

The development is constructive enough to drive explicit computation. Two algorithms are
central.

**Algorithm 4.1 (Evenness test via diagonal).** Given a symmetric integer matrix $G$,
$Q$ is even iff every diagonal entry is even. Cost: $O(n)$. Justified by Lemma 3.2 and
its converse.

```
isEven(G):
    for i in 0..n-1:
        if G[i][i] is odd: return False
    return True
```

**Algorithm 4.2 (Unimodularity certificate).** To certify $Q$ unimodular, exhibit an
integer matrix $H$ with $G H = I_n$ and check the product. This avoids fraction-prone
determinant expansion and is exactly how `E8inv` certifies $E_8$. Cost: one integer
matrix multiplication, $O(n^3)$.

```
isUnimodularCertified(G, H):
    return matmul(G, H) == Identity(n)
```

**Algorithm 4.3 (Obstruction check).** A positive-rank form is provably *not* smoothly
realizable in the definite case if it is even:
```
notSmoothlyStandard(G):
    return n > 0 and isEven(G)   # ⇒ not standard-diagonalizable (Thm 3.3)
```

---

## 5. Applications

1. **A verified smooth/topological separator.** The pipeline "even + positive rank
   $\Rightarrow$ not standard $\Rightarrow$ (with Donaldson) not smooth" gives a
   machine-checkable certificate that a given positive-definite even unimodular form —
   $E_8$, $E_8 \oplus E_8$, etc. — yields a non-smoothable topological 4-manifold.

2. **Spin geometry sanity checks.** Because evenness $\Leftrightarrow$ spin, the diagonal
   criterion (Lemma 3.2) provides an $O(n)$ test of the spin condition directly from a
   Gram matrix, useful in any formal development of characteristic-class computations.

3. **Lattice theory bridge.** Even unimodular positive-definite forms are exactly the
   even unimodular lattices; $E_8$ is the minimal one. The verified framework is a
   foundation for formalizing the rank-divisible-by-8 theorem and van der Blij's
   signature congruence (see §7).

4. **Pedagogy.** The proof of Theorem 3.3 is a two-line miracle that makes Donaldson's
   obstruction graspable without any gauge theory, suitable for teaching the
   smooth/topological distinction.

---

## 6. Discussion

The formalization deliberately separates the *analytic* and *algebraic* layers. Donaldson's
diagonalization theorem and Freedman's realization theorem are deep results whose proofs
involve, respectively, the moduli space of anti-self-dual Yang–Mills connections and
infinite constructions of Casson handles; these are taken as named external inputs. What
we make airtight is everything that turns those inputs into concrete verdicts: the
algebra of congruence of forms, the parity obstruction, and the explicit $E_8$ witness.

The economy of Theorem 3.3 is worth emphasizing. The entire obstruction rests on a single
evaluation: the standard form realizes the odd value $1$ at a basis vector, and evenness
forbids odd values. No spectral theory, no signature, no lattice embedding — just the
change-of-basis identity and the parity of $1$. This is the rare situation where the
formal proof is essentially the *optimal* informal proof.

A subtlety worth noting: our `StdDiagonalizable` predicate uses $T^{\mathsf T} G T = I$
with $\det T$ a unit, which is the correct integral notion (congruence by a unimodular
matrix), strictly finer than diagonalizability over $\mathbb{Q}$ or $\mathbb{R}$. Over
$\mathbb{R}$, $E_8$ is of course equivalent to $\langle 1\rangle^8$ (it is
positive-definite); the obstruction is purely *integral*. This is exactly why the
phenomenon is invisible to ordinary linear algebra and requires the integer structure
that Poincaré duality supplies.

---

## 7. Future Work

- **8-divisibility of even definite unimodular forms.** Add a `PosDef` predicate
  ($\forall v \ne 0,\ 0 < Q.\mathrm{value}(v)$) and prove that an even unimodular
  positive-definite form has rank divisible by $8$. The verified rank-$8$ witness $E_8$ is
  the minimal case; only the mod-$8$ bookkeeping remains.
- **Van der Blij / signature mod 8.** Define a characteristic element $c$ with
  $Q.\mathrm{value}(v) \equiv c \cdot v \pmod 2$ and prove $Q.\mathrm{value}(c) \equiv
  \mathrm{signature}(Q) \pmod 8$, with $c = 0$ in the even case yielding
  $\mathrm{signature} \equiv 0 \pmod 8$. This packages Theorem 3.3 into a single
  $\mathbb{Z}/8$ invariant and reuses `value_basisChange` verbatim.
- **Connected-sum additivity and stable cancellation.** Define the block-diagonal sum
  $Q \oplus R$ (modeling $M \# N$), show `Unimodular` and `IsEven` are closed under
  $\oplus$, that signatures add, and prove a stable form of Donaldson's theorem.

---

## 8. Conclusion

We have given a complete, `sorry`-free formalization of the algebraic core of the
intersection-form theory underlying the smooth 4-dimensional Poincaré problem. The
centerpiece, `even_not_stdDiagonalizable`, is the precise algebraic mechanism that, via
Donaldson's theorem, forbids even positive-definite intersection forms on smooth
4-manifolds; the $E_8$ form, with its explicit integral inverse, is its sharpest
instance and the cleanest known certificate of the smooth/topological gap in dimension
four. The trivial sphere form explains, structurally, why this powerful invariant is
nonetheless powerless against the smooth Poincaré conjecture itself — pointing to where
genuinely new ideas are still required.

## References

- S. K. Donaldson, *An application of gauge theory to four-dimensional topology*, J.
  Differential Geom. **18** (1983), 279–315.
- M. H. Freedman, *The topology of four-dimensional manifolds*, J. Differential Geom.
  **17** (1982), 357–453.
- J. W. Milnor and D. Husemoller, *Symmetric Bilinear Forms*, Springer, 1973.
- J.-P. Serre, *A Course in Arithmetic*, Springer, 1973 (even unimodular lattices and
  the $E_8$ form).
