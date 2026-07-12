# The Kernel Law: An Exact Thermodynamics of Structure-Preserving Inference

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

We develop an exact information-theoretic and thermodynamic accounting for
reasoning steps that respect algebraic structure. Modeling a single inference as
a function $f : \alpha \to \beta$ between finite sets, we define its **erased
information** as the entropy drop $\operatorname{erasedBits}(f) = \log_2 |\alpha|
- \log_2 |\operatorname{im} f|$, and, via Landauer's principle, its dissipated
heat as $\operatorname{erasedBits}(f) \cdot k_B T \ln 2$. Our central result, the
**Kernel Law**, states that when the input space is a finite group $G$ and the
step is a homomorphism $f : G \to H$, the erased information is exactly
$\log_2 |\ker f|$. The proof rests on the counting identity $|\operatorname{im}
f| \cdot |\ker f| = |G|$, itself a consequence of the First Isomorphism Theorem
and Lagrange's theorem. We derive four immediate corollaries: (i) a homomorphic
step is reversible iff its kernel is trivial iff it is injective; (ii) the
quotient map $G \to G/N$ erases exactly $\log_2 |N|$ bits; (iii) the associated
Landauer heat of forming a quotient is $\log_2 |N| \cdot k_B T \ln 2$; and
(iv) along a pipeline whose first step is surjective, erasure is *exactly
additive*, sharpening the generic sub-additivity of composition into a
conservation law. We discuss algorithms for computing these quantities,
numerical illustrations, applications to the cost accounting of abstraction, and
a program of conjectures connecting composition series, endomorphism iteration,
and short exact sequences to conservation of dissipated information.

**Keywords:** Landauer's principle, kernel, first isomorphism theorem, Lagrange's
theorem, information erasure, entropy, group homomorphism, quotient group,
reversible computation.

---

## 1. Introduction

Reasoning is lossy. A deductive step typically discards detail: from a rich
object it extracts a coarser conclusion, and in doing so it destroys the
information needed to reconstruct the input. Landauer's principle, a cornerstone
of the physics of computation, assigns a hard thermodynamic price to precisely
this act: erasing one bit of information dissipates at least $k_B T \ln 2$ joules
of heat, where $k_B$ is Boltzmann's constant and $T$ the absolute temperature.
Logical irreversibility and physical dissipation are two faces of one coin.

This paper isolates the case in which a reasoning step *respects algebraic
structure* — formally, when it is a group homomorphism — and shows that in that
case the erased information admits an exact algebraic formula in terms of the
**kernel**. The kernel of a homomorphism is the classical record of what the map
identifies; we show it is, quantitatively and exactly, the record of what the map
*forgets*. This yields the **Kernel Law**: a homomorphic step $f : G \to H$
erases exactly $\log_2 |\ker f|$ bits.

The result is pleasing for two reasons. First, it upgrades bounds and analogies
into equalities: there is no approximation and no hidden constant. Second, it
reinterprets three classical algebraic facts — the First Isomorphism Theorem,
Lagrange's theorem, and the multiplicativity of indices — as statements about
conservation and dissipation of information.

### Contributions

1. A precise definition of erased information for a step between finite sets and
   its Landauer heat (Section 3).
2. A counting identity $|\operatorname{im} f|\cdot|\ker f| = |G|$ for finite
   group homomorphisms, packaging the First Isomorphism Theorem with Lagrange's
   theorem (Theorem 4.1).
3. The **Kernel Law** $\operatorname{erasedBits}(f) = \log_2|\ker f|$
   (Theorem 4.2), and the reversibility criterion (Theorem 4.3).
4. The **quotient cost** $\log_2|N|$ and its Landauer heat (Theorems 5.1, 5.2).
5. **Exact additivity** of erasure along a surjective-first pipeline
   (Theorem 6.2), sharpening generic sub-additivity into a conservation law.
6. A program of conjectures (Section 9) linking composition series, endomorphism
   iteration, and short exact sequences to information conservation.

---

## 2. Related perspectives

Landauer's principle (1961) and Bennett's subsequent theory of reversible
computation frame the physical cost of logically irreversible operations. In pure
mathematics, the First Isomorphism Theorem and Lagrange's theorem are foundational
counting tools. The present work sits at their intersection: it uses the
algebraic counting identity to compute a physical-information quantity exactly.
The novelty is not in any single ingredient but in the exact bridge — that the
information dissipated by a structure-preserving step equals the logarithm of a
kernel — and in the resulting reinterpretation of classical structure theory as a
ledger of dissipated information.

---

## 3. Definitions

Throughout, "finite" means finite as a set, and $|\cdot|$ denotes cardinality.
We write $\log_2$ for the base-2 logarithm, taken as a real-valued function; all
cardinalities appearing inside a logarithm are positive.

**Definition 3.1 (Image cardinality).** For a function $f : \alpha \to \beta$
with $\alpha$ finite, the *image cardinality* $|\operatorname{im} f|$ is the
number of distinct values $f$ attains, i.e. $|\{ f(x) : x \in \alpha \}|$. Since
$\alpha$ is nonempty in all cases of interest, $|\operatorname{im} f| \ge 1$.

**Definition 3.2 (Erased bits).** For $f : \alpha \to \beta$ with $\alpha$ finite
and nonempty, the *erased information* (in bits) is
$$
\operatorname{erasedBits}(f) \;=\; \log_2 |\alpha| \;-\; \log_2 |\operatorname{im} f|.
$$
Equivalently $\operatorname{erasedBits}(f) = \log_2\big(|\alpha| / |\operatorname{im}
f|\big)$. It is the drop in Hartley entropy from the (uniform) input to the
observable output. It is always $\ge 0$, and $=0$ iff $f$ is injective.

**Definition 3.3 (Landauer heat).** For a nonnegative bit count $b$, physical
constants $k_B$ (Boltzmann) and absolute temperature $T$, the *Landauer cost* is
$$
\operatorname{landauerCost}(b, k_B, T) \;=\; b \cdot k_B\, T \ln 2.
$$
Applied to $b = \operatorname{erasedBits}(f)$ this is the minimum heat a physical
realization of the step must dissipate.

**Definition 3.4 (Kernel, image of a homomorphism).** Let $f : G \to H$ be a
homomorphism of groups. Its *kernel* is $\ker f = \{ g \in G : f(g) = 1_H \}$, a
normal subgroup of $G$; its *image* $\operatorname{im} f$ is a subgroup of $H$.
Two elements $x, y \in G$ satisfy $f(x) = f(y)$ iff $x^{-1}y \in \ker f$, so the
fibers of $f$ are exactly the cosets of $\ker f$.

---

## 4. The counting identity and the Kernel Law

**Theorem 4.1 (First isomorphism theorem, counted).** Let $G$ be a finite group
and $f : G \to H$ a homomorphism into a group $H$. Then
$$
|\operatorname{im} f| \cdot |\ker f| \;=\; |G|.
$$

*Proof sketch.* The First Isomorphism Theorem gives a group isomorphism
$G/\ker f \cong \operatorname{im} f$, so $|G/\ker f| = |\operatorname{im} f|$.
Lagrange's theorem, in its quotient form, gives $|G| = |G/\ker f| \cdot |\ker f|$.
Substituting yields $|G| = |\operatorname{im} f| \cdot |\ker f|$. $\square$

This identity is a conservation statement: the domain factors exactly into "what
is retained" (the image) times "what is collapsed" (the kernel).

**Theorem 4.2 (The Kernel Law).** Let $G$ be a finite group and $f : G \to H$ a
homomorphism. Then the information erased by $f$ is exactly
$$
\operatorname{erasedBits}(f) \;=\; \log_2 |\ker f|.
$$

*Proof sketch.* By Definition 3.2, $\operatorname{erasedBits}(f) = \log_2 |G| -
\log_2 |\operatorname{im} f|$. Both cardinalities are positive, so by
Theorem 4.1 and the multiplicativity of the logarithm,
$$
\log_2 |G| = \log_2\big(|\operatorname{im} f|\cdot|\ker f|\big)
= \log_2 |\operatorname{im} f| + \log_2 |\ker f|.
$$
Subtracting $\log_2 |\operatorname{im} f|$ gives
$\operatorname{erasedBits}(f) = \log_2|\ker f|$. $\square$

The erased information depends only on the kernel; the target group $H$ and the
detailed structure of the image are irrelevant to the cost.

**Theorem 4.3 (Reversibility criterion).** Let $G$ be a finite group and
$f : G \to H$ a homomorphism. The following are equivalent:
(i) $\operatorname{erasedBits}(f) = 0$;
(ii) $\ker f$ is trivial (i.e. $\ker f = \{1_G\}$);
(iii) $f$ is injective.

*Proof sketch.* By the Kernel Law, $\operatorname{erasedBits}(f) = \log_2|\ker f|
= 0$ iff $|\ker f| = 1$ iff $\ker f = \{1_G\}$, giving (i) $\Leftrightarrow$ (ii).
The equivalence (ii) $\Leftrightarrow$ (iii) is the standard fact that a
homomorphism is injective iff its kernel is trivial. $\square$

Thus for structure-preserving steps, thermodynamic freeness, logical
reversibility, informational losslessness, and algebraic triviality of the kernel
all coincide.

---

## 5. The cost of a quotient

Forming a quotient is the archetypal act of mathematical abstraction: working
modulo a subgroup, up to a symmetry, or modulo an equivalence. Its cost is
immediate from the Kernel Law.

**Theorem 5.1 (Quotient cost).** Let $G$ be a finite group and $N \trianglelefteq
G$ a normal subgroup. The canonical projection $\pi : G \to G/N$ satisfies
$$
\operatorname{erasedBits}(\pi) \;=\; \log_2 |N|.
$$

*Proof sketch.* The kernel of the canonical projection $\pi : G \to G/N$ is
exactly $N$. Applying the Kernel Law (Theorem 4.2) to $\pi$ gives
$\operatorname{erasedBits}(\pi) = \log_2 |\ker \pi| = \log_2 |N|$. $\square$

**Theorem 5.2 (Landauer heat of a quotient).** With the notation of Theorem 5.1,
and physical constants $k_B, T$, the minimum heat dissipated in forming $G/N$ is
$$
\operatorname{landauerCost}\big(\operatorname{erasedBits}(\pi),\, k_B,\, T\big)
\;=\; \log_2 |N| \cdot \big(k_B\, T \ln 2\big).
$$

*Proof sketch.* Substitute $\operatorname{erasedBits}(\pi) = \log_2 |N|$ from
Theorem 5.1 into Definition 3.3. $\square$

Passing to a quotient dissipates precisely the entropy of the subgroup quotiented
out: abstraction is exactly as costly as the ambiguity it introduces.

---

## 6. Composition: sub-additivity and its exact refinement

Reasoning composes. Given homomorphic steps $f : G \to H$ and $g : H \to K$, we
ask how $\operatorname{erasedBits}(g \circ f)$ relates to the individual costs.

**Generic sub-additivity.** For arbitrary composable functions, erasure is
sub-additive: $\operatorname{erasedBits}(g \circ f) \le \operatorname{erasedBits}(f)
+ \operatorname{erasedBits}(g)$. Information already destroyed by $f$ cannot be
destroyed again by $g$; and $g$ may lose no new information on the (possibly
proper) image of $f$. The inequality can be strict.

We show that surjectivity of the first step forces equality.

**Lemma 6.1 (Kernel product along a surjection).** Let $G, H$ be finite groups,
$f : G \to H$ a *surjective* homomorphism, and $g : H \to K$ a homomorphism. Then
$$
|\ker(g \circ f)| \;=\; |\ker f| \cdot |\ker g|.
$$

*Proof sketch.* One exhibits a bijection between $\ker(g\circ f)$ and the product
$\ker f \times \ker g$. An element $x \in \ker(g \circ f)$ satisfies $g(f(x)) =
1_K$, i.e. $f(x) \in \ker g$. Because $f$ is surjective, choose for each
$h \in \ker g$ a preimage; the fiber over $h$ is a coset of $\ker f$ and hence has
$|\ker f|$ elements. Summing over the $|\ker g|$ elements of $\ker g$ partitions
$\ker(g\circ f)$ into $|\ker g|$ cosets each of size $|\ker f|$, giving the count.
(Concretely, $x \mapsto \big(x\cdot s(f(x))^{-1},\, f(x)\big)$, where $s$ is a
section of $f$, defines the bijection to $\ker f \times \ker g$.) $\square$

**Theorem 6.2 (Exact additivity along a surjective pipeline).** Let $G, H$ be
finite groups, $f : G \to H$ a surjective homomorphism, and $g : H \to K$ a
homomorphism. Then
$$
\operatorname{erasedBits}(g \circ f) \;=\; \operatorname{erasedBits}(f) + \operatorname{erasedBits}(g).
$$

*Proof sketch.* By the Kernel Law applied to $g \circ f$, $f$, and $g$, and by
Lemma 6.1,
$$
\operatorname{erasedBits}(g\circ f) = \log_2 |\ker(g\circ f)|
= \log_2\big(|\ker f|\cdot|\ker g|\big)
= \log_2 |\ker f| + \log_2 |\ker g|,
$$
which equals $\operatorname{erasedBits}(f) + \operatorname{erasedBits}(g)$.
$\square$

Exactness of the first stage — no wasted expressive capacity — restores a
conservation law: the dissipated heat of the whole equals the sum of the parts,
with no slack.

---

## 7. Algorithms

The quantities above are directly computable for explicitly presented finite
groups.

**Algorithm A (Erased bits of an arbitrary finite map).** Given the graph of
$f : \alpha \to \beta$ with $\alpha$ finite, count the distinct outputs to get
$|\operatorname{im} f|$, then return $\log_2 |\alpha| - \log_2 |\operatorname{im}
f|$. Complexity $O(|\alpha|)$ with hashing.

**Algorithm B (Kernel-Law verification).** Given a finite group $G$ (as a
multiplication table or generating set) and a homomorphism $f$, compute $\ker f =
\{g : f(g) = 1\}$ and $\operatorname{im} f$, and verify both $|\operatorname{im}
f|\cdot|\ker f| = |G|$ and $\operatorname{erasedBits}(f) = \log_2|\ker f|$.
Complexity $O(|G|)$ evaluations of $f$.

**Algorithm C (Composition-series ledger).** Given a finite solvable group and a
composition series $G = G_0 \rhd G_1 \rhd \cdots \rhd G_n = \{1\}$, accumulate
$\sum_i \log_2 |G_i / G_{i+1}|$; the Kernel Law predicts the total equals
$\log_2 |G|$ regardless of the series (Section 9, Conjecture 1). Complexity linear
in the number of factors given the orders.

---

## 8. Numerical illustrations

The accompanying computational suite verifies the theorems on explicit groups.
Representative checks:

- **Cyclic reduction.** For $G = \mathbb{Z}/12$ and the reduction map to
  $\mathbb{Z}/4$ (multiply by $1$, reduce mod $4$; kernel $= 4\mathbb{Z}/12$ of
  order $3$), the Kernel Law predicts $\log_2 3 \approx 1.585$ erased bits;
  direct image counting agrees.
- **Sign homomorphism.** For $G = S_n$ and the sign map to $\{\pm 1\}$, the kernel
  is the alternating group $A_n$ of order $n!/2$, so a parity check erases
  $\log_2(n!/2)$ bits — almost everything.
- **Quotient cost.** For $\mathbb{Z}/12 \to \mathbb{Z}/12 / \langle 6 \rangle$
  with $N = \langle 6 \rangle$ of order $2$, exactly $1$ bit is erased.
- **Exact additivity.** For a surjection followed by a homomorphism (e.g.
  $\mathbb{Z}/12 \twoheadrightarrow \mathbb{Z}/6 \to \mathbb{Z}/3$), the erased
  bits of the composite equal the sum of the two stages, whereas a
  non-surjective first stage exhibits a strict deficit.

Multiplying any erased-bit figure by $k_B T \ln 2$ (about $2.87 \times 10^{-21}$
J at room temperature) yields the Landauer heat.

---

## 9. Future directions

The Kernel Law suggests that classical structure theory is, in disguise, a theory
of conserved dissipation.

**Conjecture 1 (The length law).** For a finite solvable group, the minimal total
dissipation of any pipeline of homomorphic steps collapsing $G$ to the trivial
group equals $\log_2 |G|$, realized step by step by a composition series: each
factor $G_i/G_{i+1}$ contributes $\log_2 |G_i/G_{i+1}|$ bits, summing to
$\log_2 |G|$ independent of the series. The Kernel Law turns Jordan–Hölder into a
conservation law; exact additivity along surjective pipelines (Theorem 6.2) is the
telescoping mechanism. The remaining step is to rule out shorter routes.

**Conjecture 2 (Spectral gap of erasure).** For an endomorphism $f : G \to G$ of
a finite group, the sequence $\log_2 |\ker f^n|$ is non-decreasing, concave, and
eventually constant; the limiting value is $\log_2$ of the size of the stable
("eventual") kernel, and the first stabilizing index is the nilpotency length of
$f$ on the collapsing part. Data-processing monotonicity plus the Kernel Law give
monotonicity immediately; concavity is the natural next target.

**Conjecture 3 (Short exact sequences balance the ledger).** For every short
exact sequence $1 \to N \to G \to Q \to 1$ of finite groups, the dissipation of
the surjection $G \to Q$ plus the capacity created by the injection $N \to G$
equals $\log_2 |G|$; the erasure/creation ledger closes exactly, with no slack. A
short exact sequence is a lossless thermodynamic cycle. This cycle proved both
halves in isolation (quotient cost and creation); the conjecture asserts they
compose to a closed loop.

---

## 10. Conclusion

We have shown that for structure-preserving inference the physics of forgetting
becomes exact algebra: a homomorphic step $f : G \to H$ dissipates exactly
$\log_2 |\ker f|$ bits. From this single law flow the reversibility criterion, the
cost of quotients, their Landauer heat, and an exact conservation of dissipation
along surjective pipelines. The First Isomorphism Theorem reappears as
conservation of information, Lagrange's theorem as the reason the ledger balances,
and the kernel — that most classical of invariants — as the precise measure of
irreversibility. The conjectures of Section 9 chart a route toward reading the
deeper structure theory of groups as a thermodynamics of reasoning.
