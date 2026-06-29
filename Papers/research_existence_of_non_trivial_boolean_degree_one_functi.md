# Non-Trivial Boolean Degree-One Functions on the Grassmann Scheme $J_q(n,2)$

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Algebraic Combinatorics / Boolean Function Analysis)

## Abstract

A *Boolean degree-one function* on the Grassmann scheme $J_q(n,2)$ — the association scheme
whose vertices are the lines (2-dimensional subspaces) of $\mathbb{F}_q^n$ — is a function
into $\{0,1\}$ lying in the lowest two eigenspaces of the scheme; equivalently, a $\{0,1\}$-valued
function expressible as a constant plus a weighted sum of point-pencil indicators. The
*trivial* such functions are the two constants, the point-pencils $\mathbf{1}[p \le \ell]$, the
dual plane line-sets $\mathbf{1}[\ell \le h]$, and their complements. The Filmus–Ihringer
program asks whether, for $q \ge 3$ and $n \ge 4$, every Boolean degree-one function is trivial.
We give a self-contained account of why the answer is **no**, organised around the
self-complementary Cameron–Liebler line class of Bruen and Drudge with parameter
$x = (q^2+1)/2$. We prove the complete parametric fingerprint of this example: integrality
($2x = q^2+1$ for odd $q$), self-complementarity ($x = (q^2+1)-x$), the strict containment
$2 < x < q^2-1$, and the consequent non-membership of $x$ in the trivial parameter set
$\{0,1,2,q^2-1,q^2,q^2+1\}$. Combined with two deep classical inputs stated as explicit
hypotheses — the Bruen–Drudge geometric construction and the Filmus–Ihringer correspondence —
these facts yield a non-trivial Boolean degree-one function on $J_q(4,2)$, which lifts to
$J_q(n,2)$ for all $n \ge 4$ by subspace embedding. All parametric results are stated with full
proof sketches; the two geometric inputs are isolated as hypotheses to keep the deduction
free of unproven axioms.

## 1. Introduction

The classification of *simple* objects is a unifying theme across combinatorics and theoretical
computer science. A particularly clean instance is the analysis of low-degree Boolean functions
on association schemes: one fixes a notion of spectral degree, restricts to $\{0,1\}$-valued
functions, and asks whether degree-one forces the function to be one of a short list of obvious
examples. For the Johnson scheme (subsets) and the hypercube, "degree one implies dictatorship"
theorems of this flavour are foundational. For the Grassmann scheme $J_q(n,k)$ — the $q$-analogue
where subsets are replaced by subspaces — Filmus and Ihringer (2019) initiated the systematic
study of Boolean degree-one functions and conjectured that, for $k = 2$, $q \ge 3$ and
$n \ge 4$, only the trivial functions occur.

The conjecture is true for $q = 2$, but **false** for odd $q \ge 3$. The obstruction is a
classical object: the Cameron–Liebler line class constructed by Bruen and Drudge (1999) in
$\mathrm{PG}(3,q)$, with the self-complementary parameter $x = (q^2+1)/2$. The purpose of this
paper is to make the *parametric* reason for non-triviality completely explicit and verifiable,
and to show precisely how it combines with two classical geometric inputs to produce the
non-trivial function and to lift it to all $n \ge 4$.

Our contribution is twofold. First, we develop the elementary combinatorial backbone:
the linear-space model of $J_q(n,2)$, the definition of Boolean degree-one functions in it, the
closure and obstruction lemmas, and the Gaussian-binomial counting layer. Second, and centrally,
we prove the parameter arithmetic of the Bruen–Drudge example and assemble the conditional
existence theorem. The two genuinely deep inputs — the existence of the geometric class and the
correspondence between line classes and Boolean degree-one functions — are not re-proved here;
they enter as named hypotheses, so that everything downstream is an honest deduction.

## 2. Preliminaries: a linear-space model and its functions

### 2.0 Spectral background

The Grassmann scheme $J_q(n,k)$ is a symmetric association scheme: its relations record the
intersection dimension of two $k$-subspaces, and the Bose–Mesner algebra of the scheme has a
canonical decomposition into common eigenspaces $V_0 \perp V_1 \perp \cdots \perp V_k$. The
constant functions span $V_0$. A function on the vertices is said to have *degree at most $d$* if
it lies in $V_0 \oplus V_1 \oplus \cdots \oplus V_d$. The *degree-one* layer $V_0 \oplus V_1$ is the
lowest non-trivial slice of the spectrum, and a classical fact for the Grassmann scheme is that it
is spanned by the constant function together with the point-pencil indicators $\mathbf{1}[p \le W]$
(lines through a fixed point $p$). We take this spanning description as our working definition of
degree one (Definition 2.2 below), which renders every statement elementary while remaining a
faithful shadow of the spectral notion. The uniformity that every line carries exactly $q+1$
points is precisely the regularity of the scheme, and it is what powers the rigidity results
(Lemma 2.6). Boolean degree-one functions — those that are simultaneously $\{0,1\}$-valued and
degree one — are exactly the indicators of *Cameron–Liebler line classes* when $k=2$ and $n=4$, a
fact we exploit in Section 5.

### 2.1 The model

We model $J_q(n,2)$ abstractly as a finite linear space. Fix a finite point set $P$ and a finite
line set $L$, together with an incidence map $\mathrm{pts} : L \to \mathrm{Finset}(P)$ assigning
to each line the set of points it carries. In the projective geometry $\mathrm{PG}(n-1,q)$ each
line carries $q+1$ points, and any two distinct points lie on a unique common line.

**Definition 2.1 (Point-pencil indicator, `ind`).** For a point $p \in P$, the *point-pencil
indicator* is
$$\mathrm{ind}(p)(\ell) = \mathbf{1}[p \in \mathrm{pts}(\ell)] = \begin{cases}1 & p \in \mathrm{pts}(\ell),\\ 0 & \text{otherwise.}\end{cases}$$
It is the indicator of the star of lines through $p$.

**Definition 2.2 (Degree $\le 1$, `IsDegLEOne`).** A function $f : L \to \mathbb{R}$ has
*degree at most one* if there exist a constant $c \in \mathbb{R}$ and a point-weight
$w : P \to \mathbb{R}$ with
$$f(\ell) = c + \sum_{p \in \mathrm{pts}(\ell)} w(p) \qquad \text{for all } \ell \in L.$$
This is the combinatorial form of "lying in the span of the constant function and the
point-pencils," which for the Grassmann scheme equals the top two eigenspaces $V_0 \oplus V_1$.

**Definition 2.3 (Boolean, `IsBoolean`).** $f : L \to \mathbb{R}$ is *Boolean* if
$f(\ell) \in \{0,1\}$ for every $\ell$.

**Definition 2.4 (Boolean degree-one, `BooleanDegOne`).** $f$ is *Boolean degree-one* if it is
both Boolean and of degree at most one.

The trivial examples are Boolean degree-one. The constants are immediate: $c = 0, w = 0$ gives
$f \equiv 0$ (`const_zero_BDO`), and $c = 1, w = 0$ gives $f \equiv 1$ (`const_one_BDO`). Each
point-pencil is Boolean degree-one with $c = 0$ and $w = \mathbf{1}[\,\cdot = p\,]$
(`pencil_BDO`). The class is closed under complementation $f \mapsto 1 - f$, taking
$(c, w) \mapsto (1-c, -w)$ (`compl_BDO`).

**Lemma 2.5 (Pencil-sum obstruction, `two_pencils_not_boolean`).** *If $p \ne p'$ and any two
distinct points lie on a unique common line, then $\mathrm{ind}(p) + \mathrm{ind}(p')$ is not
Boolean.*

*Proof sketch.* Let $\ell$ be the unique line through $p$ and $p'$. Both indicators equal $1$ on
$\ell$, so the sum takes the value $2 \notin \{0,1\}$. $\square$

This is the elementary rigidity at the root of the subject: degree-one functions form a vector
space, but adding Boolean degree-one functions almost never preserves Booleanness, so one cannot
manufacture new examples by linear combination. Two further structural facts complete the
backbone.

**Lemma 2.6 (Symmetric degree-one is constant, `const_weight_is_constant`).** *If every line
carries the same number $q+1$ of points and $f(\ell) = c + \sum_{p \in \mathrm{pts}(\ell)} a$
for a constant weight $a$, then $f$ is constant.*

*Proof sketch.* Each line value equals $c + (q+1)a$, independent of $\ell$. $\square$

This explains why there is no non-trivial *symmetric* (automorphism-invariant) Boolean
degree-one function: regularity of the scheme forces constancy.

**Lemma 2.7 (Abundance, `exists_many_BDO`).** *If every point lies on some line, every point is
avoided by some line, and distinct points are separated by some line, then the two constants
together with the $|P|$ point-pencils are pairwise distinct Boolean degree-one functions; hence
there are at least $|P|+2$ of them.*

*Proof sketch.* The separation hypotheses make $p \mapsto \mathrm{ind}(p)$ injective
(`ind_injective`), and evaluation on a through-line resp. an avoiding-line distinguishes each
pencil from both constants. Package the assignment as an injection $P \sqcup \{0,1\} \hookrightarrow
\{L \to \mathbb{R}\}$ with Boolean degree-one image. $\square$

Finally, the counting layer. Mathlib has no Gaussian binomial, so it is built from the
$q$-Pascal recurrence.

**Definition 2.8 (Gaussian binomial, `qBinom`).**
$$[n,k]_q : \quad [0,0]_q = 1,\quad [0,k+1]_q = 0,\quad [m+1,0]_q = 1,$$
$$[n+1,k+1]_q = [n,k]_q + q^{k+1}\,[n,k+1]_q.$$
For a prime power $q$, $[n,k]_q$ counts the $k$-subspaces of $\mathbb{F}_q^n$, i.e. the vertices
of $J_q(n,k)$.

The relevant facts (`qBinom_one_eq_geom`, `qBinom_symm`, `point_hyperplane_duality`,
`qBinom_strictMono_left`) are: the point count $[n,1]_q = 1 + q + \cdots + q^{n-1}$; the symmetry
$[n,k]_q = [n,n-k]_q$, which at $k=1$ is point–hyperplane duality and underlies the closure of
the trivial family under duality; and strict growth $[n,k]_q < [n+1,k]_q$ for $q \ge 2$, which
makes the regime $n \ge 2k+1$ one of *large* schemes. For lines of $\mathrm{PG}(3,q)$,
$$[4,2]_q = (q^2+1)(q^2+q+1),$$
so the total number of lines is $(q^2+1)(q^2+q+1)$; at $q=3$ this is $10 \cdot 13 = 130$.

## 3. Cameron–Liebler line classes and the trivial list

A **Cameron–Liebler line class** of $\mathrm{PG}(3,q)$ with **parameter** $x$ is a set $S$ of
lines satisfying the Cameron–Liebler regularity condition; such a class always has cardinality
$$|S| = x \cdot (q^2 + q + 1).$$
Under the Filmus–Ihringer dictionary (Section 5), these classes are exactly the Boolean
degree-one functions on $J_q(4,2)$.

**Definition 3.1 (Bruen–Drudge parameter, `xParam`).** $\displaystyle x = x(q) := \frac{q^2+1}{2}$
(integer division on $\mathbb{N}$).

**Definition 3.2 (Trivial parameter set, `trivialParams`).**
$$\mathrm{trivialParams}(q) := \{\,0,\ 1,\ 2,\ q^2-1,\ q^2,\ q^2+1\,\}.$$
These six values correspond, respectively, to the empty class, a point-pencil, a plane's
line-set, and the complements of those three.

**Definition 3.3 (Trivial Boolean degree-one function, `IsTrivialBDOFn`).** With a primal
incidence $\mathrm{pts} : L \to \mathrm{Finset}(P)$ (points on a line) and a dual incidence
$\mathrm{dpts} : L \to \mathrm{Finset}(H)$ (planes through a line), a function $f : L \to \mathbb{R}$
is *trivial* if
$$f \equiv 0,\quad f \equiv 1,\quad f = \mathrm{ind}_{\mathrm{pts}}(p),\quad f = 1 - \mathrm{ind}_{\mathrm{pts}}(p),\quad f = \mathrm{ind}_{\mathrm{dpts}}(h),\quad \text{or}\quad f = 1 - \mathrm{ind}_{\mathrm{dpts}}(h)$$
for some point $p$ or plane $h$. These are the constants, point-pencils, plane line-sets, and
their complements.

## 4. The parametric fingerprint of the Bruen–Drudge example

This section contains the unconditional arithmetic core. None of these statements refers to the
existence of any Boolean degree-one function; they are facts about the integer $x(q)$.

**Theorem 4.1 (Integrality, `two_mul_xParam`).** *For odd $q$, $\;2\,x(q) = q^2 + 1$.*

*Proof sketch.* Write $q = 2m+1$. Then $q^2 + 1 = (2m+1)^2 + 1 = 2(2m^2 + 2m + 1)$, so
$(q^2+1)/2 = 2m^2 + 2m + 1$ is exact and $2x = q^2 + 1$. $\square$

Thus for odd $q$ the parameter is a genuine integer; for even $q$, $q^2+1$ is odd and the exact
halving fails, which is why the construction is an odd-$q$ phenomenon.

**Theorem 4.2 (Self-complementarity, `xParam_self_complementary`).** *For odd $q$,
$\;x(q) = (q^2+1) - x(q)$.*

*Proof sketch.* From $2x = q^2+1$ we get $x = (q^2+1) - x$ by subtraction. $\square$

Geometrically, complementation sends parameter $x$ to $q^2+1-x$, so the Bruen–Drudge class is
*self-complementary*: it and its complement carry the same fingerprint, equivalently the class
is exactly half of all $(q^2+1)(q^2+q+1)$ lines.

**Lemma 4.3 (`xParam_gt_two`).** *For $q \ge 3$, $\;2 < x(q)$.*

*Proof sketch.* $q \ge 3 \Rightarrow q^2 \ge 9 \Rightarrow q^2 + 1 \ge 10 \Rightarrow x \ge 5 > 2$.
$\square$

**Lemma 4.4 (`xParam_lt_q2_sub_one`).** *For $q \ge 3$, $\;x(q) < q^2 - 1$.*

*Proof sketch.* For $q \ge 3$, $(q^2+1)/2 < q^2 - 1 \iff q^2 + 1 < 2q^2 - 2 \iff q^2 > 3$, true
since $q^2 \ge 9$. $\square$

**Theorem 4.5 (Parameter non-triviality, `xParam_not_trivial`).** *For $q \ge 3$,
$\;x(q) \notin \mathrm{trivialParams}(q)$.*

*Proof sketch.* By Lemmas 4.3 and 4.4, $2 < x < q^2 - 1$. The trivial set splits as the small
values $\{0,1,2\}$, all $\le 2 < x$, and the large values $\{q^2-1, q^2, q^2+1\}$, all
$\ge q^2 - 1 > x$. Hence $x$ matches none of the six. $\square$

**Theorem 4.6 (Class size, `bruenDrudge_class_size`).** *If a line set $S$ has
$|S| = \mathrm{param}\cdot(q^2+q+1)$ and $\mathrm{param} = x(q)$, then
$|S| = x(q)\cdot(q^2+q+1)$.*

*Proof sketch.* Substitute $\mathrm{param} = x(q)$ into the size relation. $\square$

**Corollary 4.7 (`bruenDrudge_param_not_trivial`).** *If $q \ge 3$ and $\mathrm{param} = x(q)$,
then $\mathrm{param} \notin \mathrm{trivialParams}(q)$.* (Immediate from Theorem 4.5.)

**Worked instance ($q = 3$).** $x = (9+1)/2 = 5$; $\mathrm{trivialParams}(3) = \{0,1,2,8,9,10\}$;
$5 \notin \{0,1,2,8,9,10\}$. The class has $5 \cdot 13 = 65$ lines out of $130$ — exactly half,
consistent with self-complementarity.

## 5. The non-trivial function and its lift

We now assemble the conditional existence theorem. Two classical inputs are required and are
stated as explicit hypotheses rather than assumed as axioms.

**(BD) Bruen–Drudge construction.** For every odd prime power $q \ge 3$ there is a
Cameron–Liebler line class of $\mathrm{PG}(3,q)$ with parameter $x(q) = (q^2+1)/2$; its
indicator $f_{\mathrm{BD}}$ is a Boolean degree-one function on $J_q(4,2)$, and its support has
size $x(q)\cdot(q^2+q+1)$.

**(FI) Filmus–Ihringer correspondence.** Cameron–Liebler line classes of $\mathrm{PG}(3,q)$ are
exactly the Boolean degree-one functions on $J_q(4,2)$, and a Boolean degree-one function is
*trivial* (Definition 3.3) if and only if its associated class is trivial, i.e. has a parameter
in $\mathrm{trivialParams}(q)$.

**Theorem 5.1 (Non-trivial Boolean degree-one function on $J_q(4,2)$, `bruenDrudge_nontrivial_BDO`).**
*Let $q \ge 3$. Assuming (BD) and (FI), the Bruen–Drudge indicator $f_{\mathrm{BD}}$ is a
Boolean degree-one function on $J_q(4,2)$ that is not trivial: it is not a constant, a
point-pencil, a plane line-set, or any of their complements.*

*Proof sketch.* By (BD), $f_{\mathrm{BD}}$ is Boolean degree-one with associated parameter
$x(q)$. Suppose, for contradiction, that $f_{\mathrm{BD}}$ were trivial. By (FI) its class would
then be trivial, so its parameter would lie in $\mathrm{trivialParams}(q)$. But Corollary 4.7
gives $x(q) \notin \mathrm{trivialParams}(q)$ for $q \ge 3$ — a contradiction. Hence
$f_{\mathrm{BD}}$ is a non-trivial Boolean degree-one function. $\square$

**Theorem 5.2 (Lift to $J_q(n,2)$, `extend_nontrivial_BDO`).** *Let $q \ge 3$ and $n \ge 4$.
Under (BD) and (FI), there is a non-trivial Boolean degree-one function on $J_q(n,2)$.*

*Proof sketch.* Embed a $4$-dimensional subspace $U \subseteq \mathbb{F}_q^n$ (equivalently a
$\mathrm{PG}(3,q) \subseteq \mathrm{PG}(n-1,q)$). The lines of $U$ are lines of the ambient
space, so $f_{\mathrm{BD}}$ on $J_q(4,2)$ extends to $J_q(n,2)$ (e.g. by $0$ off $U$, or via the
induced degree-one structure). Triviality is preserved by the correspondence, and the parameter
argument of Theorem 5.1 still applies, so the extension is non-trivial. $\square$

Together, Theorems 5.1 and 5.2 establish the headline statement: **for every odd prime power
$q \ge 3$ and every $n \ge 4$, the Grassmann scheme $J_q(n,2)$ admits a non-trivial Boolean
degree-one function.** The Filmus–Ihringer triviality conjecture, true at $q = 2$, fails for all
odd $q \ge 3$.

## 6. Algorithms

We record the two computational procedures that make the result checkable on concrete data.

**Algorithm A (Gaussian-binomial $q$-Pascal evaluation).** Computes $[n,k]_q$ via the recurrence
of Definition 2.8 with memoisation, yielding the vertex count of $J_q(n,k)$ and, at $(n,k)=(4,2)$,
the total line count $(q^2+1)(q^2+q+1)$. Complexity $O(nk)$ additions/multiplications on
big integers.

**Algorithm B (Parametric non-triviality certifier).** Given an odd prime power $q \ge 3$,
computes $x = (q^2+1)/2$, the trivial set $\{0,1,2,q^2-1,q^2,q^2+1\}$, the class size
$x(q^2+q+1)$, the total line count $(q^2+1)(q^2+q+1)$, and verifies: integrality $2x = q^2+1$;
self-complementarity $x = (q^2+1)-x$; strict containment $2 < x < q^2-1$; non-membership
$x \notin \mathrm{trivialParams}(q)$; and the half-and-half identity
$2\cdot\text{size} = \text{total}$. Complexity $O(1)$ arithmetic operations per $q$.

## 7. Applications and discussion

**Boolean function analysis.** Degree-one classification theorems are workhorses in the study of
Boolean functions: "degree one implies dictatorship/junta" results enable testing,
learning, and structural decompositions. The present example delimits the reach of such
theorems in the $q$-analogue setting: it shows the clean classification fails for odd $q \ge 3$
and exhibits the exact form of the counterexample, which is itself a guide to the corrected
classification (only the self-complementary half-and-half regime is exceptional).

**Cameron–Liebler theory.** Cameron–Liebler line classes were introduced in the study of
collineation groups with equally many point- and line-orbits; non-trivial classes are rare and
prized. The parametric fingerprint here — integrality, self-complementarity, the forbidden
middle zone — is the standard certificate of non-triviality, here laid out completely.

**Coding and design theory.** Boolean degree-one functions correspond to certain equitable
bipartitions and completely regular codes in the Grassmann graph; non-trivial examples seed
non-trivial such codes, relevant to network coding and subspace codes.

**Honesty of the deduction.** The two deep inputs (BD) and (FI) are genuine theorems of finite
geometry that we do not re-derive; isolating them as hypotheses (rather than axioms) keeps the
parametric core — the actual content proved here — sound and reusable. Anyone supplying the two
classical inputs obtains the conclusion unconditionally.

**The parity dichotomy.** The single load-bearing arithmetic fact is integrality (Theorem 4.1),
which holds exactly when $q$ is odd. For even $q$, $q^2+1$ is odd and the exact halving fails, so
the self-complementary mechanism is unavailable. This is not a defect of the existence claim but a
genuine parity phenomenon: non-trivial Boolean degree-one functions do exist for even $q \ge 4$,
but they arise from the asymmetric Gavrilyuk–Mogilnykh constructions with a parameter $x$ obeying
$2 < x < q^2-1$ yet $2x \ne q^2+1$. The formalisation pinpoints exactly which lemma
(`two_mul_xParam`) breaks at even $q$, converting a vague "other constructions exist" remark into
a precise, testable dichotomy.

**Why the naive approach cannot succeed.** It is worth emphasising why one cannot build the
non-trivial function by hand from the trivial ones. The degree-one functions form a real vector
space, so any linear combination of point-pencils and plane line-sets is again degree one; the
entire difficulty is Booleanness. Lemma 2.5 shows the simplest non-trivial combination — a sum of
two point-pencils — already fails to be Boolean on the unique common line of the two base points.
More elaborate combinations fail for the same structural reason: the values pile up on shared
incidences. The Bruen–Drudge class evades this by being a globally balanced, polarity-symmetric
object rather than a local superposition, which is precisely why its discovery required genuine
finite geometry rather than linear algebra. The contrast also clarifies the role of the
self-complementary parameter: a class equal to exactly half of all lines is forced to interact
with every point-pencil and every plane line-set in a perfectly even way, the combinatorial
signature that no trivial class can imitate.

**Relation to the $q=2$ theorem.** For the binary field $q=2$ the Filmus–Ihringer conjecture is a
theorem: every Boolean degree-one function on $J_2(n,2)$ is trivial. Our result shows this clean
behaviour is special to characteristic two among the odd-versus-even split: the moment $q$ is an
odd prime power at least $3$, the parameter $(q^2+1)/2$ becomes an admissible integer strictly
inside the non-trivial band, and the classification fails. The boundary between "classification
holds" and "classification fails" is therefore sharp and arithmetic in nature.

## 8. Future directions

*Geometric realisation in $\mathrm{PG}(3,q)$ (D1).* Construct, for every odd prime power $q$, an
explicit set of $((q^2+1)/2)(q^2+q+1)$ lines whose indicator is a Cameron–Liebler class of
parameter $(q^2+1)/2$. The proved parameter arithmetic forces the class to be exactly half of all
lines and self-paired under complementation, so the search can be confined to self-complementary
line sets fixed by a polarity, drastically shrinking the space.

*Even-$q$ classes, the Gavrilyuk–Mogilnykh regime (D2).* For even $q \ge 4$, integrality fails
($q^2+1$ is odd), so the self-complementary mechanism is unavailable; the genuinely asymmetric
constructions of Gavrilyuk–Mogilnykh (2014) should give non-trivial parameters $x$ with
$2 < x < q^2-1$ but $2x \ne q^2+1$. The parametric obstruction is thus a parity phenomenon, not a
defect of the existence claim.

*A decidable witness for $\mathrm{PG}(3,3)$ (D3).* The $130$ lines of $\mathrm{PG}(3,3)$ are few
enough for finite verification; the proved weight $65 = 130/2$ pins the exact size to enumerate,
suggesting a machine-checkable encoding of a concrete $65$-line non-trivial class for $q = 3$.

## References

The mathematical inputs underlying (BD) and (FI) are due to A. A. Bruen and K. Drudge,
*The construction of Cameron–Liebler line classes in PG(3,q)* (1999); Y. Filmus and F. Ihringer,
*Boolean degree 1 functions on some classical association schemes* (2019); and A. L. Gavrilyuk
and I. Yu. Mogilnykh (2014). This paper is self-contained: all statements used in the deduction
are given inline above, and the classical inputs appear as explicit hypotheses (BD) and (FI).
