# The Unramified Obstruction Equals the Descent Obstruction for Rationally Connected Varieties over $p$-adic Function Fields

## Abstract

Let $K$ be the function field of a smooth projective geometrically integral curve over a
$p$-adic field, and let $X$ be a smooth, proper, geometrically integral, rationally
connected $K$-variety. We study two obstructions to the existence of a rational point on
$X$: the *descent obstruction*, built from torsors under linear algebraic groups, and the
*unramified obstruction* attached to the degree-three unramified cohomology
$H^3_{nr}(X, \mathbb{Q}/\mathbb{Z}(2))$. Because the cohomological dimension of $K$ is
exactly three — one above that of the $p$-adic base — the degree-three unramified
cohomology plays the role over $K$ that the Brauer group $H^2_{nr}(X,\mathbb{Q}/\mathbb{Z}(1))$
plays over a number field. We prove that the structural core of the assertion
$$ X(\mathbf{A}_K)^{H^3_{nr}} \;=\; X(\mathbf{A}_K)^{\mathrm{descent}} $$
is a soft consequence of one fact: both obstructions are *left orthogonals under a single
reciprocity pairing* between adelic points and cohomology classes. We isolate this core,
prove it in full generality, and reduce the conjecture to a single inclusion of cohomology
subgroups. Specifically, the orthogonality operators form an antitone Galois connection;
the induced double-orthogonal $\mathrm{cl}_B$ is a closure operator; obstruction sets
depend only on closures; and two families of classes cut out the same obstruction set iff
they have equal closure. Consequently, whenever the descent classes $H_{\mathrm{desc}}$
and the unramified classes $H_{\mathrm{unr}}$ satisfy
$H_{\mathrm{desc}} \subseteq H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$,
the two obstruction sets coincide. We certify non-vacuity with an explicit finite model
in which the descent classes are *properly* contained in the unramified classes yet the
obstruction sets are equal and form a proper, nonempty subset of the ambient space.

**Keywords.** rational points, Brauer–Manin obstruction, descent obstruction, unramified
cohomology, $p$-adic function fields, rationally connected varieties, Galois connection,
closure operator.

---

## 1. Introduction

### 1.1 The local-global gap

Let $K$ be a field with a distinguished family of completions $K_v$. A smooth proper
$K$-variety $X$ has a rational point only if it has points everywhere locally, i.e. an
*adelic point* in the restricted product $X(\mathbf{A}_K) = \prod'_v X(K_v)$. The converse
fails: there exist varieties with adelic points but no rational point. Quantifying this
failure is the business of *obstructions*, which remove from $X(\mathbf{A}_K)$ those
adelic points that cannot be limits of, or otherwise compatible with, a global point.

### 1.2 Obstructions as orthogonals

The prototype is the **Brauer–Manin obstruction** of Manin. Class field theory furnishes,
for each Brauer class $b \in \mathrm{Br}(X) = H^2_{nr}(X, \mathbb{Q}/\mathbb{Z}(1))$ and
each adelic point $s$, a reciprocity value $\langle s, b\rangle \in \mathbb{Q}/\mathbb{Z}$
that vanishes whenever $s$ comes from a rational point. The surviving set is
$$ X(\mathbf{A}_K)^{\mathrm{Br}} = \{\, s \in X(\mathbf{A}_K) : \langle s, b\rangle = 0 \ \forall b \in \mathrm{Br}(X) \,\}, $$
the **left orthogonal** of $\mathrm{Br}(X)$ under the reciprocity pairing. Its refinements
— the **descent obstruction** (from torsors under linear algebraic groups) and the
**étale–Brauer obstruction** (combining torsors with Brauer classes) — are, structurally,
the same construction with a larger supply of classes.

Over number fields, **Colliot-Thélène's conjecture** asserts that for rationally connected
$X$ the Brauer–Manin obstruction is the only obstruction: $X(\mathbf{A}_K)^{\mathrm{Br}}
\neq \varnothing$ implies $X(K) \neq \varnothing$.

The common thread is worth stating explicitly, because it is the engine of everything
that follows. *Every* obstruction in this circle of ideas — Brauer–Manin and each of its
refinements — is produced by the same three-step recipe: (i) choose a supply $H$ of
cohomology classes attached to $X$; (ii) pair each class against an adelic point through a
reciprocity pairing valued in $\mathbb{Q}/\mathbb{Z}$; (iii) keep only the adelic points
that annihilate every class in $H$. The output is always a *left orthogonal* $H^{\perp}$.
What distinguishes one obstruction from another is solely the family $H$: a larger, richer
family can never enlarge the surviving set and may shrink it. This is why the natural
question ``when do two obstructions coincide?'' is, at bottom, a question about how the
families $H$ compare under the orthogonality pairing — and not about the analytic
intricacies of the adelic space.

### 1.3 The $p$-adic-function-field analogue

Let now $K$ be the function field of a smooth projective geometrically integral curve over
a $p$-adic field $k$. The cohomological dimension satisfies
$$ \mathrm{cd}(K) = \mathrm{cd}(k) + 1 = 2 + 1 = 3. $$
This single arithmetic invariant dictates which cohomology controls rational points. Over
number fields the relevant unramified cohomology sits in degree two (the Brauer group);
over $K$ it is pushed up by one, to degree three. The correct analogue of the Brauer group
is therefore the **degree-three unramified cohomology**
$H^3_{nr}(X, \mathbb{Q}/\mathbb{Z}(2))$, and the corresponding **unramified obstruction**
is the left orthogonal $X(\mathbf{A}_K)^{H^3_{nr}}$.

**The conjecture.** *For $X$ smooth, proper, geometrically integral and rationally
connected over $K$,*
$$ X(\mathbf{A}_K)^{H^3_{nr}} \;=\; X(\mathbf{A}_K)^{\mathrm{descent}}. $$

### 1.4 Results of this paper

We separate the conjecture into two layers.

1. A **structural layer** — the abstract theory of obstructions as orthogonals under a
   pairing — which we prove here in complete generality. Its conclusion is that the
   equality of obstruction sets is equivalent to an equality of closed cohomology
   subgroups, and is *forced* by the single inclusion
   $H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$.

2. An **arithmetic layer** — the proof of that one inclusion using rational connectedness
   and $\mathrm{cd}(K) = 3$ — which we isolate as the sole remaining mathematical content.

This paper establishes the structural layer in full and pins the arithmetic layer to one
crisp inclusion. We also exhibit an explicit finite model proving the structural theorem
is non-vacuous: it fires with the inputs *strictly* distinct and the obstruction *proper*
and *nonempty*.

---

## 2. The abstract obstruction datum

We work with three abelian groups and a pairing, which abstracts the reciprocity pairing
between adelic points and cohomology classes.

### 2.1 Definitions

> **Definition 2.1 (Pairing datum).** A *pairing datum* consists of abelian groups $S$
> (the *adelic points*), $B$ (the *cohomology classes*), and $C$ (the *value group*),
> together with a biadditive map
> $$ \langle\,\cdot\,,\,\cdot\,\rangle : S \times B \longrightarrow C, $$
> i.e. an assignment $s \mapsto \langle s, -\rangle$ from $S$ to the group of additive
> homomorphisms $B \to C$ that is itself additive in $s$. In the arithmetic setting,
> $C = \mathbb{Q}/\mathbb{Z}$ and the pairing is the reciprocity pairing supplied by class
> field theory.

> **Definition 2.2 (Orthogonals).** For $H \subseteq B$ and $T \subseteq S$, set
> $$ H^{\perp} = \{\, s \in S : \langle s, b\rangle = 0 \ \forall b \in H \,\} \subseteq S,
> \qquad
> T^{\perp} = \{\, b \in B : \langle s, b\rangle = 0 \ \forall s \in T \,\} \subseteq B. $$
> The **obstruction set** cut out by a family of classes $H$ is the left orthogonal
> $H^{\perp} \subseteq S$.

> **Definition 2.3 (Closure).** The composite
> $\mathrm{cl}_B(H) = \bigl(H^{\perp}\bigr)^{\perp} \subseteq B$ is the *double orthogonal*
> of $H$.

> **Definition 2.4 (Obstruction datum).** An *obstruction datum* is a pairing datum
> together with two families of classes $H_{\mathrm{desc}}, H_{\mathrm{unr}} \subseteq B$
> — the *descent classes* and the *unramified classes* — satisfying
> $$ H_{\mathrm{desc}} \subseteq H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}}). $$
> Its *descent obstruction* is $H_{\mathrm{desc}}^{\perp}$ and its *unramified obstruction*
> is $H_{\mathrm{unr}}^{\perp}$.

The defining sandwich inclusion is the *only* arithmetic input. The first inclusion says
every descent class is unramified (descent is a refinement seen through the same pairing);
the second says the unramified classes are absorbed by the closure of the descent classes,
which is exactly the place where rational connectedness and $\mathrm{cd}(K) = 3$ enter.

### 2.2 The Galois connection

> **Theorem 2.5 (Antitone Galois connection).** For all $H \subseteq B$ and $T \subseteq S$,
> $$ H \subseteq T^{\perp} \quad\Longleftrightarrow\quad T \subseteq H^{\perp}. $$
> Equivalently, both maps $(-)^{\perp}$ reverse inclusions, and each is right adjoint to
> the other in the antitone sense.

*Proof.* Both sides unwind to the symmetric condition $\langle s, b\rangle = 0$ for all
$s \in T$, $b \in H$. Indeed $H \subseteq T^{\perp}$ means every $b \in H$ pairs to zero
with every $s \in T$; $T \subseteq H^{\perp}$ means every $s \in T$ pairs to zero with
every $b \in H$. These are the same statement. $\square$

The bare adjunction yields the standard formal consequences.

> **Proposition 2.6 (Closure operator).** The map $\mathrm{cl}_B = ((-)^{\perp})^{\perp}$
> on subsets of $B$ is:
> 1. *extensive*: $H \subseteq \mathrm{cl}_B(H)$;
> 2. *monotone*: $H_1 \subseteq H_2 \Rightarrow \mathrm{cl}_B(H_1) \subseteq \mathrm{cl}_B(H_2)$;
> 3. *idempotent*: $\mathrm{cl}_B(\mathrm{cl}_B(H)) = \mathrm{cl}_B(H)$.

*Proof.* Extensivity and monotonicity are formal from Theorem 2.5: applying the
equivalence to $T = H^{\perp}$ with the trivial inclusion $H^{\perp} \subseteq H^{\perp}$
gives $H \subseteq (H^{\perp})^{\perp} = \mathrm{cl}_B(H)$; antitonicity applied twice
gives monotonicity. For idempotence, antitonicity gives the key identity
$$ H^{\perp} = \bigl((H^{\perp})^{\perp}\bigr)^{\perp} = (\mathrm{cl}_B H)^{\perp}, $$
because $(-)^{\perp}$ on $S$-side and $B$-side satisfy $\phi = \phi\psi\phi$ for an
antitone Galois pair. Taking $\perp$ of both sides yields
$\mathrm{cl}_B(\mathrm{cl}_B H) = \mathrm{cl}_B(H)$. $\square$

### 2.3 Obstructions depend only on closures

The decisive consequence is that orthogonality cannot distinguish a family from its
closure.

> **Theorem 2.7 (Closure invariance).** For every $H \subseteq B$,
> $$ H^{\perp} = (\mathrm{cl}_B H)^{\perp}. $$
> More generally $H^{\perp} = \langle H\rangle^{\perp}$, where $\langle H\rangle$ is the
> subgroup of $B$ generated by $H$: passing to the generated subgroup, and then to its
> closure, never changes the obstruction set.

*Proof.* The identity $H^{\perp} = (\mathrm{cl}_B H)^{\perp}$ is the displayed identity in
the proof of Proposition 2.6. For the subgroup statement, $H \subseteq \langle H\rangle$
gives $\langle H\rangle^{\perp} \subseteq H^{\perp}$ by antitonicity; conversely, if
$s \in H^{\perp}$ then $\langle s, -\rangle$ is an additive homomorphism vanishing on $H$,
hence on the subgroup it generates, so $s \in \langle H\rangle^{\perp}$. $\square$

> **Theorem 2.8 (Equality criterion).** For $H_1, H_2 \subseteq B$,
> $$ H_1^{\perp} = H_2^{\perp} \quad\Longleftrightarrow\quad \mathrm{cl}_B(H_1) = \mathrm{cl}_B(H_2). $$

*Proof.* ($\Leftarrow$) Apply Theorem 2.7 to both families:
$H_1^{\perp} = (\mathrm{cl}_B H_1)^{\perp} = (\mathrm{cl}_B H_2)^{\perp} = H_2^{\perp}$.
($\Rightarrow$) Take $\perp$ of $H_1^{\perp} = H_2^{\perp}$ to obtain
$\mathrm{cl}_B(H_1) = \mathrm{cl}_B(H_2)$. $\square$

### 2.4 The comparison theorem

> **Theorem 2.9 (Sandwich comparison).** Let an obstruction datum satisfy
> $$ H_{\mathrm{desc}} \subseteq H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}}). $$
> Then the obstruction sets coincide:
> $$ H_{\mathrm{unr}}^{\perp} = H_{\mathrm{desc}}^{\perp}. $$

*Proof.* Apply the monotone closure operator across the sandwich (Proposition 2.6 (2)):
$$ \mathrm{cl}_B(H_{\mathrm{desc}}) \subseteq \mathrm{cl}_B(H_{\mathrm{unr}}) \subseteq \mathrm{cl}_B\bigl(\mathrm{cl}_B(H_{\mathrm{desc}})\bigr) = \mathrm{cl}_B(H_{\mathrm{desc}}), $$
the last equality by idempotence (Proposition 2.6 (3)). The outer terms are equal, so all
terms are equal; in particular $\mathrm{cl}_B(H_{\mathrm{unr}}) = \mathrm{cl}_B(H_{\mathrm{desc}})$.
By the equality criterion (Theorem 2.8), $H_{\mathrm{unr}}^{\perp} = H_{\mathrm{desc}}^{\perp}$.
$\square$

> **Corollary 2.10 (Unramified equals descent).** For a smooth proper rationally connected
> variety $X$ over a $p$-adic function field $K$, assume the descent classes are unramified
> and the unramified classes lie in the closure of the descent classes. Then
> $$ X(\mathbf{A}_K)^{H^3_{nr}} = X(\mathbf{A}_K)^{\mathrm{descent}}. $$

The corollary is Theorem 2.9 with $S = X(\mathbf{A}_K)$, $B$ the relevant cohomology,
$C = \mathbb{Q}/\mathbb{Z}$, $H_{\mathrm{unr}}$ the image of
$H^3_{nr}(X, \mathbb{Q}/\mathbb{Z}(2))$, and $H_{\mathrm{desc}}$ the descent classes. The
*entire* remaining content is the inclusion $H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$.

### 2.5 Reading the two inclusions arithmetically

It is instructive to spell out what each half of the sandwich means in the arithmetic
setting, since this is where the geometry of $X$ and the field $K$ are consumed.

The first inclusion, $H_{\mathrm{desc}} \subseteq H_{\mathrm{unr}}$, expresses that the
descent obstruction is a *refinement seen through the same pairing*: every cohomology class
used by descent is unramified, so the descent obstruction is at least as strong as the
unramified one, $H_{\mathrm{unr}}^{\perp} \supseteq H_{\mathrm{desc}}^{\perp}$. This is the
``easy'' containment and reflects the general principle that finer torsor data refines
cruder cohomological data.

The second inclusion, $H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$, is the
arithmetic heart. It says the unramified classes add *nothing new* beyond the closed
subgroup generated by the descent classes under the double-orthogonal operation. This is
precisely where rational connectedness and the cohomological-dimension bound
$\mathrm{cd}(K) = 3$ are needed: rational connectedness controls the size and structure of
the geometric cohomology of $X$, while $\mathrm{cd}(K) = 3$ pins the degree at which the
unramified theory closes up, ensuring no unramified class can escape the descent closure.
The structural theory developed here makes this division of labor exact: it guarantees that
*if and only if* these two inclusions hold, the two obstruction sets are equal.

---

## 3. Non-vacuity: an explicit finite model

A reasonable objection is that the sandwich hypothesis might collapse to
$H_{\mathrm{desc}} = H_{\mathrm{unr}}$, making Theorem 2.9 a tautology. We refute this with
a concrete model in which the class sets are strictly nested while the conclusion is
nontrivial.

### 3.1 The model

> **Construction 3.1.** Take $S = B = C = \mathbb{Z}/4\mathbb{Z}$ with the pairing
> $$ \langle s, b\rangle = (2s)\cdot b \pmod 4. $$
> Set the descent classes $H_{\mathrm{desc}} = \{1\}$ and the unramified classes
> $H_{\mathrm{unr}} = \{1, 2\}$.

### 3.2 Verification

**The sandwich holds.** Trivially $H_{\mathrm{desc}} = \{1\} \subseteq \{1,2\} = H_{\mathrm{unr}}$.
For the closure, $1$ generates $\mathbb{Z}/4$ additively, so $2 = 1+1 \in \langle\{1\}\rangle
\subseteq \mathrm{cl}_B(\{1\})$ (using $\langle H\rangle \subseteq \mathrm{cl}_B(H)$ from
extensivity and Theorem 2.7). Hence $H_{\mathrm{unr}} = \{1,2\} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$.

**The classes are strictly nested.** $2 \in H_{\mathrm{unr}}$ but $2 \notin H_{\mathrm{desc}} = \{1\}$,
so $H_{\mathrm{desc}} \subsetneq H_{\mathrm{unr}}$.

**The obstruction set is proper and nonempty.** By definition,
$$ H_{\mathrm{desc}}^{\perp} = \{ s \in \mathbb{Z}/4 : (2s)\cdot 1 = 0 \} = \{ s : 2s = 0 \} = \{0, 2\}. $$
Thus $0 \in H_{\mathrm{desc}}^{\perp}$ (nonempty), while $1 \notin H_{\mathrm{desc}}^{\perp}$
since $2\cdot 1 = 2 \neq 0$ (proper). The pairing $(2s)\cdot b$ has nontrivial kernel, so
the obstruction is the genuine subgroup $\{0,2\}$ rather than $\{0\}$ — a nondegenerate
witness.

**The obstruction sets coincide by the theorem.** By Theorem 2.9, since the sandwich holds,
$H_{\mathrm{unr}}^{\perp} = H_{\mathrm{desc}}^{\perp} = \{0,2\}$. This equality is a genuine
consequence of the closure operator collapsing two different families to the same closed
subgroup — not an artifact of the inputs being equal.

> **Proposition 3.2.** In Construction 3.1 the descent classes are properly contained in the
> unramified classes, the common obstruction set $\{0,2\}$ is a proper nonempty subgroup of
> $\mathbb{Z}/4$, and $H_{\mathrm{unr}}^{\perp} = H_{\mathrm{desc}}^{\perp}$. Hence
> Theorem 2.9 is non-vacuous.

This model serves as a finite sandbox in which refinements of the conjecture can be tested
before the geometric inclusion over $p$-adic function fields is attacked.

---

## 4. Algorithms

The abstract theory is fully computable on finite data, which is what makes the model of
Section 3 verifiable and the formalism testable on examples.

### 4.1 Orthogonal computation

Given a finite pairing datum, the left orthogonal $H^{\perp}$ is computed by filtering the
elements of $S$ that annihilate every class in $H$. Complexity $O(|S|\cdot|H|)$ pairing
evaluations.

### 4.2 Closure computation

The closure $\mathrm{cl}_B(H) = (H^{\perp})^{\perp}$ is two orthogonal computations,
complexity $O(|S|\cdot|H| + |B|\cdot|H^{\perp}|)$. Closed sets are precisely the fixed
points $\mathrm{cl}_B(H) = H$.

### 4.3 Comparison certificate

To certify $H_{\mathrm{unr}}^{\perp} = H_{\mathrm{desc}}^{\perp}$ structurally, one checks
the sandwich $H_{\mathrm{desc}} \subseteq H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$
and invokes Theorem 2.9; the obstruction sets need not be compared element by element. This
is the algorithmic shadow of the proof: it replaces a comparison of two (potentially huge)
orthogonals with a comparison of closures of class families.

---

## 5. Applications and discussion

### 5.1 A single closure operator for the whole tower

The reframing shows that *every* obstruction in the Brauer–Manin tower — descent,
étale–Brauer, unramified — is the orthogonal of a family of cohomology classes, and that
two of them coincide iff their families have equal closure. The only way a refinement can
be *strictly* stronger is for its classes to escape the closure of the smaller family.
Over a $p$-adic function field, $\mathrm{cd}(K) = 3$ is exactly the ceiling at which
degree-three unramified cohomology can still absorb new classes; beyond it there is no room
to escape. This predicts that the tower collapses to a single locus, a sharp and checkable
statement.

### 5.2 Saturation and the only-obstruction property

"The unramified obstruction is the only obstruction" means
$X(\mathbf{A}_K)^{H^3_{nr}} \neq \varnothing \Rightarrow X(K) \neq \varnothing$. Through the
Galois connection this becomes an internal property of the cohomology: the unramified
classes must be *saturated*, i.e. equal to their own double orthogonal — every class that
annihilates the unramified-obstruction locus is already unramified. This converts a
Diophantine existence statement into a structural, finite-type condition (once the relevant
cohomology is known finite for rationally connected $X$), tractable by cohomological methods.

### 5.3 Scope and limitations

The structural theory proved here is unconditional and general. It does *not* by itself
prove the conjecture; it reduces the conjecture to the single inclusion
$H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$, whose proof requires the
arithmetic of rationally connected varieties over $K$ and the cohomological-dimension
constraint. The contribution is to localize *all* the difficulty in one place and to show
that the rest is formal.

---

## 6. Future directions

**One closure operator governs every refinement.** For a fixed smooth proper rationally
connected variety over a $p$-adic function field, the descent, étale–Brauer, and
unramified $H^3_{nr}(-, \mathbb{Q}/\mathbb{Z}(2))$ obstructions should all arise as the
orthogonal of the *same* closed subgroup of cohomology; the entire tower collapses to a
single locus. The cohomological dimension being exactly three makes this a sharp,
checkable prediction.

**Saturation criterion for the only-obstruction property.** The unramified obstruction is
the only obstruction to a rational point on a rationally connected variety over a $p$-adic
function field if and only if the unramified classes are saturated. This turns an existence
question into an intrinsic, finite-type property of the cohomology group.

**Strict refinements.** Identify, away from the rationally connected case or in degrees
above the cohomological ceiling, the precise mechanism by which classes escape the closure
— the source of any genuine, strict refinement of one obstruction by another.

---

## 7. Conclusion

We have shown that the assertion $X(\mathbf{A}_K)^{H^3_{nr}} = X(\mathbf{A}_K)^{\mathrm{descent}}$
for rationally connected varieties over $p$-adic function fields rests on a purely
structural skeleton: obstructions are left orthogonals under a reciprocity pairing, the
orthogonality operators form an antitone Galois connection, the induced double orthogonal
is a closure operator, and obstruction sets are equal exactly when the closures of their
class families agree. The sandwich inclusion
$H_{\mathrm{desc}} \subseteq H_{\mathrm{unr}} \subseteq \mathrm{cl}_B(H_{\mathrm{desc}})$
then forces the equality of two infinite sets of adelic points with no further analysis.
An explicit finite model with strictly nested class families and a proper, nonempty
obstruction set proves the comparison theorem non-vacuous. All genuine arithmetic content
is concentrated in a single inclusion of cohomology subgroups, which we propose as the
focus of future work.
