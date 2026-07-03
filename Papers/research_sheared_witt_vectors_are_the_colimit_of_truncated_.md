# Sheared Witt Vectors as the Filtered Colimit of Truncated Witt Vectors

## Abstract

We give a concrete, self-contained account of the identification of the *sheared
Witt vector functor* with the filtered colimit of its truncations, realized at the
two levels where a filtered colimit genuinely occurs: the *arity* direction (the
truncation level) and the *base-ring* direction (a presentation of the base ring as
a rising union of subrings). Our central result states that over a commutative ring
$R$ presented as a directed union of subrings $R = \bigcup_i S_i$, the sheared Witt
coordinate sequences over $R$ — infinite sequences of finite essential support with
all coordinates in $R$ — are *exactly* the double directed union, over truncation
level $n$ and ring stage $i$, of the truncated coordinate sequences over the single
stage $S_i$. The colimit in the base-ring variable and the colimit in the
arity variable fuse into one directed union. We upgrade the statement from
coordinate sequences to genuine Witt vectors via functoriality, and we prove that
the finite-support (shearing) hypothesis is *necessary*: dropping it makes the
identification fail, witnessed by an explicit, natural counterexample — the vector
of all variables over a polynomial ring in countably many variables. Finally, we
observe that the shearing mechanism is basepoint-agnostic, yielding a verbatim
tropical analogue over the min-plus semiring. All results are stated inline with
proof sketches.

**Keywords.** Witt vectors, truncated Witt vectors, filtered colimit, direct limit,
finite support, shearing, directed system, tropical semiring, min-plus algebra.

---

## 1. Introduction

The ring of Witt vectors $W(A)$ attached to a commutative ring $A$ and a prime $p$
is a cornerstone of $p$-adic arithmetic: it is the canonical functor lifting
characteristic $p$ to characteristic $0$, reconstructing $\mathbb{Z}_p$ from
$\mathbb{F}_p$ and underlying crystalline cohomology, $p$-adic Hodge theory, and the
theory of formal groups. Classically, $W(A)$ is realized as the *inverse limit*
$\varprojlim_n W_n(A)$ of its truncations $W_n(A) \cong A^n$, gluing compatible
finite approximations.

Inverse limits, however, interact poorly with *colimits*. A general Witt vector has
infinitely many nonzero coordinates and therefore cannot descend to any finite
stage of a rising system. The remedy, central to recent work on prismatic and
sheared constructions (Zink 2003; Lau 2010; Drinfeld–Lau 2025; Hoff–Lau 2026), is
*shearing*: restricting to Witt vectors of finite essential support. This paper
isolates the elementary combinatorial content of the resulting identification
$$
\chi W \;\cong\; \operatorname*{colim}_n\; W\!\bigl(R[p^n]\bigr)/\widehat{hw}\!
\bigl(R[p^n]\bigr),
$$
transported to the concrete "directed union of subrings" model of a filtered colimit
of rings, and shows that the phenomenon is genuinely a statement about
finitely-supported sequences.

### Contributions

1. **Shearing in isolation (arity colimit).** For any coordinate type and
   basepoint, the eventually-basepoint (sheared) sequences are exactly the rising
   union of the truncated sequences (§3).
2. **The double colimit (main theorem).** For a monotone directed family of
   subrings with colimit $R = \bigcup_i S_i$, the sheared Witt coordinate sequences
   over $R$ are exactly the double directed union over truncation level and ring
   stage of truncated coordinate sequences over the stages (§4).
3. **Genuine Witt vectors.** The identification upgrades from coordinate sequences
   to honest Witt vectors through the functorial map induced by the subring
   inclusions (§5).
4. **Necessity of shearing.** Dropping finite support falsifies the identification;
   we exhibit an explicit natural counterexample (§6).
5. **Tropical analogue.** The mechanism is basepoint-agnostic, giving a verbatim
   statement over the tropical (min-plus) semiring (§7).

---

## 2. Preliminaries

### 2.1 Witt vectors and their truncations

Fix a prime $p$. For a commutative ring $A$, the ring of ($p$-typical) **Witt
vectors** $W(A)$ has underlying set $A^{\mathbb{N}}$, written
$a = (a_0, a_1, a_2, \dots)$, with ring operations determined by the requirement
that the **ghost maps**
$$
w_n(a) \;=\; \sum_{i=0}^{n} p^i\, a_i^{\,p^{\,n-i}}
\;=\; a_0^{p^n} + p\, a_1^{p^{n-1}} + \cdots + p^n a_n
$$
be ring homomorphisms $W(A) \to A$ for all $n$. The **truncated Witt vectors**
$W_n(A)$ have underlying set $A^n$, and the truncation maps $W_{n+1}(A) \to W_n(A)$
forget the last coordinate. As sets, $W(A) = \varprojlim_n W_n(A)$.

For the colimit analysis, what matters is not the ring law but the *coordinate
support*. We embed $W_n(A) \cong A^n$ into $A^{\mathbb{N}}$ by padding coordinates
$\ge n$ with the basepoint $0$; the image is precisely the sequences that vanish
beyond coordinate $n$.

### 2.2 Sheared Witt vectors

The **sheared Witt vector functor** $\chi W$ selects the coordinate sequences of
**finite essential support**:
$$
\chi W(A) \;=\; \bigl\{\, a \in A^{\mathbb N} : \exists N,\ \forall k \ge N,\ a_k = 0
\,\bigr\}.
$$

### 2.3 Directed systems and filtered colimits of rings

Let $\iota$ be a nonempty preordered index set that is **directed**: any two indices
$i, j$ admit a common upper bound $k \ge i, j$. A family $S : \iota \to
\operatorname{Subring}(R)$ is **monotone** if $i \le j \Rightarrow S_i \subseteq
S_j$. Its colimit is realized concretely as the subring $\bigsqcup_i S_i = \bigcup_i
S_i$ (the directed union is a subring). The key structural fact we use repeatedly is
membership in a directed supremum:
$$
x \in \bigsqcup_i S_i \iff \exists i,\ x \in S_i,
$$
valid precisely because the system is directed.

We record two combinatorial engines.

**Directed-merge principle.** *In a directed order, any finite set of indices has a
common upper bound.* This is immediate by induction from binary directedness and is
the workhorse for "collect finitely many stages into one."

**Finite support principle.** *A sequence of finite essential support is determined
by finitely many coordinates*; beyond the support bound $N$, every coordinate equals
the basepoint.

---

## 3. Shearing in isolation: sheared = colimit of truncated

We first isolate the shearing mechanism, free of any ring structure.

**Theorem 3.1 (Arity colimit).** *Let $A$ be any type and $b \in A$ a basepoint.
Then*
$$
\bigcup_{n \in \mathbb{N}} \bigl\{\, g : \mathbb{N} \to A \mid \forall k \ge n,\
g(k) = b \,\bigr\}
\;=\;
\bigl\{\, g : \mathbb{N} \to A \mid \exists N,\ \forall k \ge N,\ g(k) = b \,\bigr\}.
$$

*Proof sketch.* A function $g$ lies in the left-hand union iff there exists $n$ with
$g(k) = b$ for all $k \ge n$; that is verbatim the membership condition of the
right-hand set, with $N = n$. The two sets have literally the same defining
predicate up to renaming the witness, so equality holds. $\qquad\blacksquare$

**Interpretation.** Padding $W_n(A) \cong A^n$ into $A^{\mathbb N}$ by the basepoint
identifies the $n$-th truncated set with the "vanish beyond $n$" set. Theorem 3.1
says the sheared functor $\chi W$ *is* the filtered colimit $\operatorname*{colim}_n
W_n$ of these truncations, in the arity variable. This is the shearing mechanism
distilled: finite support is exactly "membership at some finite stage of the arity
tower."

---

## 4. The main theorem: sheared Witt over a filtered colimit of rings

We now combine the arity colimit with a colimit in the base ring.

**Theorem 4.1 (Double colimit).** *Let $R$ be a commutative ring and $S : \iota \to
\operatorname{Subring}(R)$ a monotone family over a nonempty directed index set.
Then*
$$
\bigcup_{i \in \iota}\ \bigcup_{n \in \mathbb{N}}\
\bigl\{\, g : \mathbb{N} \to R \mid (\forall k \ge n,\ g(k) = 0)\ \wedge\ (\forall k,\
g(k) \in S_i) \,\bigr\}
$$
$$
=\
\bigl\{\, g : \mathbb{N} \to R \mid (\exists N,\ \forall k \ge N,\ g(k) = 0)\ \wedge\
(\forall k,\ g(k) \in \textstyle\bigsqcup_i S_i) \,\bigr\}.
$$

*That is, the sheared Witt coordinate sequences over the colimit ring $R =
\bigsqcup_i S_i$ are exactly the double directed union, over truncation level $n$ and
ring stage $i$, of the truncated coordinate sequences over the stage $S_i$.*

*Proof sketch.* We prove the two inclusions.

($\subseteq$) Fix $g$ in the left union, witnessed by a stage $i$ and level $n$: $g$
vanishes beyond $n$ and every coordinate lies in $S_i$. The support bound $n$ shows
$g$ has finite essential support. And $S_i \subseteq \bigsqcup_i S_i$, so every
coordinate lies in the colimit ring. Hence $g$ lies in the right-hand set.

($\supseteq$) Fix $g$ in the right-hand set: there is a support bound $N$ with
$g(k) = 0$ for $k \ge N$, and every coordinate $g(k) \in \bigsqcup_i S_i$. We must
produce a *single* stage $i$ and *single* level $n$ working for all coordinates.

- **Take the level** $n = N$: by hypothesis $g$ vanishes beyond $N$.
- **Locate each coordinate.** By the directed-supremum criterion (§2.3), for each
  $k$ there is an index $c(k)$ with $g(k) \in S_{c(k)}$. (For $k \ge N$ the
  coordinate is $0 \in S_i$ for any $i$, so only the coordinates $k < N$ are
  constraining.)
- **Merge finitely many stages.** The indices $\{\, c(k) : k < N \,\}$ form a
  *finite* set, so by the directed-merge principle they have a common upper bound
  $M \in \iota$. Monotonicity gives $S_{c(k)} \subseteq S_M$, hence $g(k) \in S_M$
  for every $k < N$; and for $k \ge N$, $g(k) = 0 \in S_M$. Thus every coordinate
  lies in the single stage $S_M$.

With $i = M$ and $n = N$, the sequence $g$ vanishes beyond $n$ and has all
coordinates in $S_i$, so it belongs to the left union. $\qquad\blacksquare$

**Remark 4.2 (Why the fusion is the content).** The $\supseteq$ direction merges two
colimits *simultaneously*. Finite support bounds the arity (giving the level $n =
N$), and the directed-merge principle bounds the base ring (giving the stage $M$),
and — crucially — the *same* finiteness ("finitely many constraining coordinates")
feeds both bounds. This is why the statement is a genuine double colimit and not
merely a pair of independent one-dimensional statements. It is the concrete
directed-union incarnation of $\chi W \cong \operatorname*{colim}_n
W(R[p^n])/\widehat{hw}(R[p^n])$.

---

## 5. Genuine Witt vectors via functoriality

Theorem 4.1 is a statement about coordinate sequences. It lifts to honest Witt
vectors through functoriality. The Witt vector construction is a functor: a ring
homomorphism $f : A \to B$ induces $W(f) : W(A) \to W(B)$ acting coordinatewise on
Witt components, i.e. $W(f)(a)_k = f(a_k)$.

**Theorem 5.1 (Genuine sheared Witt colimit).** *With $R$, $\iota$, and $S$ as in
Theorem 4.1, apply the functorial maps $W(\text{incl}_i) : W(S_i) \to W(R)$ induced
by the subring inclusions $\mathrm{incl}_i : S_i \hookrightarrow R$. Then a Witt
vector $x \in W(R)$ is sheared (its coordinate sequence has finite essential
support) if and only if it lies in the image of some finite-support Witt vector over
some stage $S_i$; equivalently, the sheared part of $W(R)$ is the double directed
union, over $n$ and $i$, of the images of the truncated Witt vectors of $W(S_i)$.*

*Proof sketch.* Because $W(\text{incl}_i)$ acts coordinatewise, the coordinate
sequence of $W(\text{incl}_i)(a)$ is exactly the coordinate sequence of $a$ viewed
in $R$. So the statement for Witt vectors is the statement for coordinate sequences
(Theorem 4.1), repackaged: extract the coordinate sequence of $x$, apply Theorem
4.1 to obtain a stage $M$, level $N$, and a coordinate sequence over $S_M$; then
reassemble that sequence into a truncated Witt vector $a \in W(S_M)$ with
$W(\text{incl}_M)(a) = x$, using that a Witt vector is determined by its
coordinates and that the functorial map is coordinatewise. The converse is the easy
($\subseteq$) inclusion transported through the same coordinatewise identity.
$\qquad\blacksquare$

---

## 6. Necessity of shearing

The finite-support hypothesis in Theorems 4.1 and 5.1 is not cosmetic; the
identification is *false* without it. We exhibit an explicit, natural obstruction.

Let $K$ be a field (more generally a nontrivial commutative ring, $0 \ne 1$), and let
$R = K[x_0, x_1, x_2, \dots]$ be the polynomial ring in countably many variables.
Present $R$ as the rising union of the subrings
$$
S_i \;=\; K[x_0, x_1, \dots, x_{i-1}] \qquad (i \ge 0),
$$
generated by the first $i$ variables; these are monotone and directed with
$\bigcup_i S_i = R$. Form the **unsheared** coordinate sequence of all variables,
$$
X = (x_0, x_1, x_2, \dots), \qquad X(k) = x_k.
$$

**Theorem 6.1 (Shearing is necessary).** *Every individual coordinate of $X$
descends to a finite stage — indeed $X(k) = x_k \in S_{k+1}$ — yet $X$ descends to no
single stage: there is no index $i$ with $X(k) \in S_i$ for all $k$. Consequently
the colimit identification fails once the finite-support hypothesis is dropped: the
unrestricted (naive) Witt functor does not preserve the colimit.*

*Proof sketch.* Coordinatewise descent is clear: $x_k$ is a polynomial in
$x_0, \dots, x_k$, hence $x_k \in K[x_0, \dots, x_k] = S_{k+1}$. For the failure of
global descent, suppose for contradiction that $X(k) \in S_i$ for all $k$, for some
fixed $i$. Taking $k = i$ gives $x_i \in S_i = K[x_0, \dots, x_{i-1}]$. But the
variable $x_i$ does not lie in the subring generated by $x_0, \dots, x_{i-1}$: it is
algebraically independent from them (its degree in $x_i$ is $1$, while every element
of $S_i$ has degree $0$ in $x_i$). This is the arithmetic contradiction $i \in
\{0, 1, \dots, i-1\}$ in disguise. Hence no such $i$ exists. Since the sheared
identification would force such an $i$, it fails for $X$. $\qquad\blacksquare$

**Remark 6.2.** The contrast is sharp and diagnostic. In the sheared world (§4) the
support is finite, so only finitely many coordinates are constraining and the
directed-merge principle applies. Here the support is infinite, the family of
constraining stages $\{S_{k+1}\}$ is *cofinal* rather than bounded, and directed
merging has nothing finite to merge. Finite support is precisely what makes the
relevant portion of the directed system have an upper bound; it is the minimal
repair that restores colimit-preservation.

---

## 7. The tropical analogue

Theorem 3.1 makes no use of the ring structure of the coordinates: it is a statement
about sequences that are *eventually equal to a basepoint*. Changing the basepoint
transports the entire mechanism to any other pointed coordinate world. The tropical
semiring furnishes a striking instance.

Recall the **tropical (min-plus) semiring** on $\overline{\mathbb{N}} = \mathbb{N}
\cup \{+\infty\}$ (or on $\mathrm{Tropical}(\mathrm{WithTop}\,\mathbb{N})$), where
$a \oplus b = \min(a, b)$ and $a \odot b = a + b$; the additive identity is
$+\infty$ (the tropical zero) and the multiplicative identity is $0$. Tropical
algebra is the min-plus degeneration of ordinary algebra: polynomials become
piecewise-linear functions, and much of algebraic geometry becomes polyhedral
combinatorics.

The natural "finitely-supported" tropical vectors are those that are *eventually
$+\infty$* — eventually equal to the tropical zero. Specializing Theorem 3.1 to
basepoint $b = +\infty$:

**Corollary 7.1 (Tropical shearing).** *Over the tropical semiring, the
finitely-supported vectors — the sequences eventually equal to the tropical zero
$+\infty$ — are exactly the filtered colimit of the truncated tropical vectors
(those equal to $+\infty$ beyond some coordinate):*
$$
\bigcup_{n} \bigl\{\, g : \forall k \ge n,\ g(k) = +\infty \,\bigr\}
= \bigl\{\, g : \exists N,\ \forall k \ge N,\ g(k) = +\infty \,\bigr\}.
$$

*Proof sketch.* Immediate specialization of Theorem 3.1 with $A =
\mathrm{Tropical}(\mathrm{WithTop}\,\mathbb{N})$ and $b = +\infty$. $\qquad
\blacksquare$

**Remark 7.2 (Witt $\leftrightarrows$ tropical bridge).** Witt vectors (basepoint
$0$) and tropical vectors (basepoint $+\infty$) obey the *same* shearing law and
differ only in the choice of basepoint. The identification "sheared = colimit of
truncated" is therefore a basepoint-agnostic fact about how finite support interacts
with directed unions — indifferent to whether coordinates are $p$-adic ghost
components or min-plus distances.

---

## 8. Algorithms

The proofs are constructive, and the constructions are directly executable.

**Algorithm A (Descent of a sheared vector to a single stage).** Given a
finitely-supported sequence over $R = \bigcup_i S_i$ together with an oracle
locating each coordinate in some stage, return a stage $M$ and level $N$ witnessing
descent (Theorem 4.1, $\supseteq$).

1. Compute the support bound $N$ (least $N$ with $g(k) = 0$ for all $k \ge N$).
2. For each $k < N$, locate a stage $c(k)$ with $g(k) \in S_{c(k)}$.
3. Merge $\{c(0), \dots, c(N-1)\}$ to a common upper bound $M$ via directed joins.
4. Return $(M, N)$; then $g(k) \in S_M$ for all $k$ and $g(k) = 0$ for $k \ge N$.

Complexity: $O(N)$ locate-calls and $O(N)$ join operations.

**Algorithm B (Colimit membership test).** Decide whether a coordinate sequence lies
in the double directed union, by checking finite support and stagewise membership up
to the support bound.

**Algorithm C (Necessity witness).** Construct the unsheared "all variables" vector
$X$ and certify that no finite stage contains it, by exhibiting for each candidate
stage $i$ the escaping coordinate $x_i \notin S_i$ (Theorem 6.1).

---

## 9. Applications and significance

- **Prismatic and sheared constructions.** The identification is the concrete
  engine behind treating the sheared Witt functor as a filtered colimit, which
  licenses commuting it past other filtered colimits and reducing statements about
  the limit to statements at finite stages.
- **Reduction to finite stages.** Any property of a sheared Witt vector that is
  detected at finite truncation level and finite ring stage holds for the whole
  object, because the object *is* one of those finite approximations.
- **Cross-domain transfer.** The basepoint-agnostic formulation transfers the
  colimit law from $p$-adic to tropical settings for free, suggesting a common
  framework for "eventually-basepoint" functors.

---

## 10. Discussion and future work

Three directions grow directly out of the identification.

**1. Descent is an equivalence, not merely a surjection.** Every finitely-supported
vector over a rising union of subrings comes from a truncated vector at a single
finite stage. We conjecture the descent is a genuine bijection: two truncated
vectors that agree after passing to the whole ring already agree at a common later
stage. The same "common upper bound" that collects finitely many coordinates into
one stage should collect two competing representatives into one stage where they
coincide — upgrading a one-sided approximation into a structural equivalence.

**2. The natural filtration is the right filtration.** The truncation tower is
defined crudely, by forcing coordinates to vanish past a cutoff. We conjecture it
can be replaced by the intrinsic shift filtration coming from the arithmetic
structure, that the two towers are cofinal (hence define the same limit), and that
the intrinsic one additionally respects the ring operations and the Frobenius-type
symmetry — because "vanish past level $n$" is secretly the image of an $n$-fold
structural shift.

**3. The failure of the unsheared limit is cohomological.** Over a covering that is
not directed, the precise set of vectors that still descend should be governed by a
first-order gluing obstruction of the covering poset, so shearing is the exact price
of trivializing that obstruction: descent to a single stage is a gluing problem,
gluing is controlled by the nerve of the cover, and finite support keeps the
relevant piece of the nerve contractible. The extreme counterexample of §6 is a
concrete probe for stress-testing this on small non-directed lattices.

---

## References

- E. Witt, *Zyklische Körper und Algebren der Charakteristik $p$ vom Grad $p^n$*,
  J. Reine Angew. Math. **176** (1937).
- T. Zink, *The display of a formal $p$-divisible group* (2003).
- E. Lau, *Frames and finite group schemes over complete regular local rings*
  (2010).
- V. Drinfeld and E. Lau, work on sheared Witt vectors (2025).
- Hoff and Lau, further developments (2026).
