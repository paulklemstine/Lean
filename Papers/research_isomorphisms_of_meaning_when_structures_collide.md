# Isomorphisms of Meaning: When Structures Collide

## Abstract

Isomorphic mathematical structures are indistinguishable by any predicate that
respects isomorphism: all structural truth is transported across an
identification. Yet the identification itself is not unique, and the residual
freedom — the failure of the structure to pin down the individual *meaning* of
its elements — is a genuine, measurable quantity. We formalize this phenomenon in
the concrete setting of additive groups, and cyclic groups
$\mathbb{Z}/n\mathbb{Z}$ in particular. Our central structural observation is that
the set of isomorphisms between two isomorphic objects is a **torsor** over the
automorphism group of either endpoint: fixing any one identification puts all
identifications in canonical bijection with the symmetries of the domain, and
equally with those of the codomain. We prove that every isomorphism-invariant
predicate has the same truth value on isomorphic groups (transport of truth), and
that whenever the automorphism group is nontrivial the identification is genuinely
ambiguous (non-preservation of meaning). We then quantify the ambiguity: the
number of ways to identify a cyclic group of order $n$ with $\mathbb{Z}/n\mathbb{Z}$
is exactly Euler's totient $\varphi(n)$. Complementary number-theoretic
incarnations include the Chinese Remainder collision
$\mathbb{Z}/6\mathbb{Z} \cong \mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}$
and the non-collision of $\mathbb{Z}/4\mathbb{Z}$ with the Klein four-group. We
close by interpreting the torsor of isomorphisms as the mathematical skeleton of
analogical reasoning in the spirit of Hofstadter's Copycat architecture, with the
automorphism group measuring "conceptual slippage."

**Keywords:** cyclic groups, automorphism group, torsor, Euler's totient,
structural invariance, Chinese Remainder Theorem, Klein four-group, analogy.

---

## 1. Introduction

A guiding slogan of modern mathematics is that isomorphic objects are
interchangeable: anything provable about one is provable about the other. This is
both true and, on reflection, incomplete. It is true at the level of *structure* —
of properties preserved by isomorphism. It is silent at the level of *meaning* —
of the concrete labels we attach to individual elements. The purpose of this paper
is to make that distinction precise and, remarkably, to *measure* it.

Consider the cyclic group $\mathbb{Z}/n\mathbb{Z}$, the standard model of a clock
with $n$ hours. The map $x \mapsto -x$ is an automorphism: it preserves every
equation. For $n \geq 3$ it is not the identity, so the elements $1$ and $-1$ are
structurally interchangeable — no property expressible in the language of additive
groups can distinguish them. This is a microcosm of a general phenomenon. Whenever
two isomorphic structures are compared, the identification between them is
determined only up to a symmetry, and the ambiguity is governed by the
automorphism group.

Our contributions are:

1. **The isomorphism of isomorphisms (§3).** We show that the set of isomorphisms
   between two isomorphic additive groups is a torsor: after fixing one
   identification, all identifications correspond bijectively to automorphisms of
   the domain, and to automorphisms of the codomain. Any two identifications
   differ by a unique automorphism.
2. **Transport of truth (§4).** Every isomorphism-invariant predicate — including
   element order, cyclicity, and cardinality as special cases — has the same truth
   value on isomorphic groups.
3. **Non-preservation of meaning (§5).** A nontrivial automorphism yields a
   genuinely different identification; the correspondence of individual elements
   is not determined by the abstract structure.
4. **The totient measures ambiguity (§6).** The number of self-identifications of
   $\mathbb{Z}/n\mathbb{Z}$ — hence the number of identifications of any cyclic
   group of order $n$ with it — is exactly $\varphi(n)$.
5. **Collisions and non-collisions (§7).** The Chinese Remainder Theorem is a
   collision of two faces of one structure; the distinction between
   $\mathbb{Z}/4\mathbb{Z}$ and the Klein four-group is a certified
   non-collision.
6. **An analogy-theoretic reading (§8).** The torsor of isomorphisms models the
   space of equally valid analogies between two structures, formalizing the notion
   of "slippage."

---

## 2. Preliminaries and notation

We work with additive groups. For additive groups $G$ and $H$, an *isomorphism*
is a bijection $e : G \to H$ satisfying $e(x + y) = e(x) + e(y)$; we write
$G \cong H$ and denote the set of all such isomorphisms by $\mathrm{Iso}(G, H)$.
Every isomorphism has an inverse isomorphism $e^{-1}$, and isomorphisms compose;
we write $g \circ f$ for "first $f$, then $g$." An *automorphism* of $G$ is an
isomorphism $G \to G$; the automorphisms form a group $\mathrm{Aut}(G)$ under
composition, with identity $\mathrm{id}_G$.

For a natural number $n \geq 1$, $\mathbb{Z}/n\mathbb{Z}$ is the additive group of
integers modulo $n$. The *additive order* $\operatorname{ord}(a)$ of an element
$a$ is the least positive integer $m$ with $m \cdot a = 0$ (and $0$ if no such $m$
exists). A group is *cyclic* if it is generated by a single element. We write
$|G|$ for the cardinality (number of elements) of $G$. **Euler's totient**
$\varphi(n)$ is the number of integers $k$ with $1 \le k \le n$ and
$\gcd(k, n) = 1$.

A **torsor** (principal homogeneous space) under a group $\Gamma$ is a nonempty
set $T$ equipped with a free and transitive action of $\Gamma$. Equivalently,
after choosing any basepoint $t_0 \in T$, the map $\gamma \mapsto \gamma \cdot t_0$
is a bijection $\Gamma \to T$; the choice of $t_0$ is not canonical, so $T$ "looks
like" $\Gamma$ but has no distinguished origin.

---

## 3. The isomorphism of isomorphisms

Fix isomorphic additive groups $G$ and $H$ and a single identification
$e \in \mathrm{Iso}(G, H)$. The following two results say that $\mathrm{Iso}(G, H)$
is simultaneously a torsor under $\mathrm{Aut}(G)$ (acting on the domain side) and
under $\mathrm{Aut}(H)$ (acting on the codomain side).

> **Theorem 3.1 (Isomorphism of isomorphisms, domain version).** For any fixed
> $e \in \mathrm{Iso}(G, H)$, the map
> $$ \Phi_e : \mathrm{Aut}(G) \longrightarrow \mathrm{Iso}(G, H), \qquad \Phi_e(u) = e \circ u, $$
> is a bijection, with inverse $f \mapsto e^{-1} \circ f$.

*Proof sketch.* Both composites are the identity: $e^{-1} \circ (e \circ u) = u$
and $e \circ (e^{-1} \circ f) = f$, because $e^{-1} \circ e = \mathrm{id}_G$ and
$e \circ e^{-1} = \mathrm{id}_H$. Composition of isomorphisms is again an
isomorphism, so $\Phi_e$ is well defined and its stated inverse is well defined.
$\square$

> **Theorem 3.2 (Isomorphism of isomorphisms, codomain version).** For any fixed
> $e \in \mathrm{Iso}(G, H)$, the map
> $$ \Psi_e : \mathrm{Iso}(G, H) \longrightarrow \mathrm{Aut}(H), \qquad \Psi_e(f) = f \circ e^{-1}, $$
> is a bijection, with inverse $u \mapsto u \circ e$.

*Proof sketch.* Symmetric to Theorem 3.1, composing on the codomain side.
$\square$

Combining the two bijections yields $\mathrm{Aut}(G) \cong \mathrm{Iso}(G, H)
\cong \mathrm{Aut}(H)$ as sets, so in the finite case $|\mathrm{Aut}(G)| =
|\mathrm{Iso}(G, H)| = |\mathrm{Aut}(H)|$ whenever $\mathrm{Iso}(G, H)$ is
nonempty. The absence of a canonical basepoint is the content of the next two
results.

> **Proposition 3.3 (Difference of identifications).** Any two identifications
> $f, g \in \mathrm{Iso}(G, H)$ differ by an automorphism of the domain:
> $$ g = f \circ (f^{-1} \circ g), \qquad f^{-1} \circ g \in \mathrm{Aut}(G). $$

*Proof sketch.* Immediate from associativity and $f \circ f^{-1} = \mathrm{id}_H$;
the factor $f^{-1} \circ g$ is a composite of isomorphisms $G \to H \to G$, hence
an automorphism of $G$. $\square$

> **Proposition 3.4 (Uniqueness of the connecting automorphism).** Right
> composition by a fixed isomorphism is injective: if $f \in \mathrm{Iso}(G, H)$
> and $u, v \in \mathrm{Aut}(G)$ satisfy $f \circ u = f \circ v$, then $u = v$.

*Proof sketch.* Compose on the left with $f^{-1}$; since $f^{-1} \circ f =
\mathrm{id}_G$, we get $u = v$. Equivalently, apply the injectivity of $f$
pointwise: $f(u(x)) = f(v(x))$ forces $u(x) = v(x)$ for all $x$. $\square$

Propositions 3.3 and 3.4 together say the action of $\mathrm{Aut}(G)$ on
$\mathrm{Iso}(G, H)$ is transitive and free — precisely the torsor property.

---

## 4. Transport of truth

We now record that structure is transported perfectly across an identification.
Throughout, $e \in \mathrm{Iso}(G, H)$.

> **Theorem 4.1 (Order preservation).** For every $a \in G$,
> $\operatorname{ord}(e(a)) = \operatorname{ord}(a)$.

*Proof sketch.* Because $e$ is an additive bijection, $m \cdot e(a) = e(m \cdot a)$
and $e(m \cdot a) = 0 \iff m \cdot a = 0$. The two elements therefore satisfy the
same "vanishing after $m$ steps" conditions, so their least such $m$ coincide.
$\square$

> **Theorem 4.2 (Cyclicity preservation).** If $G$ is cyclic and $G \cong H$,
> then $H$ is cyclic.

*Proof sketch.* A surjective homomorphic image of a cyclic group is cyclic: if $g$
generates $G$, then $e(g)$ generates the image $e(G) = H$. $\square$

> **Theorem 4.3 (Cardinality preservation).** $|G| = |H|$.

*Proof sketch.* An isomorphism is in particular a bijection of underlying sets.
$\square$

The three theorems above are instances of a single schema.

> **Theorem 4.4 (Structural invariance).** Let $P$ be a predicate on additive
> groups that is *transported by isomorphism*: whenever $A \cong B$, $P(A)$ implies
> $P(B)$. Then for isomorphic groups $G \cong H$ we have $P(G) \iff P(H)$.

*Proof sketch.* The forward direction is the hypothesis applied to $e : G \cong H$;
the backward direction applies it to $e^{-1} : H \cong G$. $\square$

Theorem 4.4 is the precise sense in which *no formal system distinguishes
isomorphic structures*: any predicate whose truth respects isomorphism — which
includes every property definable in the language of the structure — takes the
same value on both. Truth is transported; nothing structural is lost.

---

## 5. Non-preservation of meaning

The completeness of transport in §4 is exactly what makes *meaning* — the identity
of individual elements — irrecoverable when there is symmetry.

> **Theorem 5.1 (Ambiguity of identification).** Let $f \in \mathrm{Iso}(G, H)$
> and let $u \in \mathrm{Aut}(G)$ with $u \neq \mathrm{id}_G$. Then
> $f \circ u \neq f$. Consequently, distinct nontrivial automorphisms of the
> domain produce genuinely distinct identifications with the same codomain.

*Proof sketch.* If $f \circ u = f = f \circ \mathrm{id}_G$, then Proposition 3.4
(uniqueness of the connecting automorphism) forces $u = \mathrm{id}_G$, contrary
to hypothesis. $\square$

Thus whenever $\mathrm{Aut}(G)$ is nontrivial, there are at least two distinct
identifications of $G$ with $H$ that agree on nothing structural (by §4) yet
disagree on the concrete correspondence of elements. No structural predicate can
select the "intended" one; the choice is semantic, not mathematical.

---

## 6. Number-theoretic incarnations and the totient

We specialize to cyclic groups, where every quantity becomes explicit.

> **Theorem 6.1 (Negation is a nontrivial automorphism).** For $n \geq 3$, the map
> $\nu : \mathbb{Z}/n\mathbb{Z} \to \mathbb{Z}/n\mathbb{Z}$, $\nu(x) = -x$, is an
> automorphism with $\nu \neq \mathrm{id}$.

*Proof sketch.* Negation is always an additive automorphism. If $\nu =
\mathrm{id}$ then $\nu(1) = 1$, i.e. $-1 = 1$, i.e. $2 \equiv 0 \pmod n$, so
$n \mid 2$ and $n \le 2$, contradicting $n \ge 3$. $\square$

> **Corollary 6.2 (Two distinct self-identifications).** For $n \geq 3$ the
> identity and negation are two distinct automorphisms of $\mathbb{Z}/n\mathbb{Z}$;
> in particular $1$ and $-1$ play interchangeable structural roles, and no
> predicate of the additive group distinguishes them.

*Proof sketch.* Combine Theorem 5.1 with Theorem 6.1. $\square$

The full count of self-identifications is the totient.

> **Theorem 6.3 (Totient count of automorphisms).** For $n \geq 1$,
> $$ |\mathrm{Aut}(\mathbb{Z}/n\mathbb{Z})| = \varphi(n). $$

*Proof sketch.* An additive automorphism of $\mathbb{Z}/n\mathbb{Z}$ is determined
by the image of the generator $1$, which must again be a generator; the generators
are exactly the residues $k$ with $\gcd(k, n) = 1$. Equivalently, additive
automorphisms correspond to multiplication by a unit of the ring $\mathbb{Z}/n\mathbb{Z}$,
so $\mathrm{Aut}(\mathbb{Z}/n\mathbb{Z}) \cong (\mathbb{Z}/n\mathbb{Z})^\times$,
whose order is $\varphi(n)$ by definition. $\square$

> **Corollary 6.4 (The measure of meaning).** For any cyclic group $G$ of order
> $n$, the number of identifications of $G$ with $\mathbb{Z}/n\mathbb{Z}$ is
> exactly $\varphi(n)$. The "meaning" of the elements of $G$ is $\varphi(n)$-fold
> ambiguous.

*Proof sketch.* Since $G \cong \mathbb{Z}/n\mathbb{Z}$, the torsor bijections of
§3 give $|\mathrm{Iso}(G, \mathbb{Z}/n\mathbb{Z})| =
|\mathrm{Aut}(\mathbb{Z}/n\mathbb{Z})| = \varphi(n)$ by Theorem 6.3. $\square$

**Illustrations.** $\varphi(2) = 1$ (a two-element group has a unique
identification — no ambiguity); $\varphi(p) = p - 1$ for prime $p$ (maximal
ambiguity: every nonzero element is an equally legitimate generator);
$\varphi(12) = 4$ (the $12$-hour clock admits four genuinely different labelings).

---

## 7. Collisions and non-collisions

Two further number-theoretic phenomena round out the picture: structures that
*should* be identified, and structures that must not be.

> **Theorem 7.1 (Chinese Remainder collision).** There is an isomorphism of
> additive groups
> $$ \mathbb{Z}/6\mathbb{Z} \;\cong\; \mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}. $$
> Hence a single residue modulo $6$ and a pair of residues modulo $2$ and $3$ are
> two semantically different faces of one and the same additive structure. In
> particular, cardinalities agree: $|\mathbb{Z}/6\mathbb{Z}| =
> |\mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}| = 6$.

*Proof sketch.* Since $\gcd(2,3) = 1$, the map $x \mapsto (x \bmod 2, x \bmod 3)$
is an additive homomorphism $\mathbb{Z}/6\mathbb{Z} \to \mathbb{Z}/2\mathbb{Z}
\times \mathbb{Z}/3\mathbb{Z}$; it is injective because $2 \mid x$ and $3 \mid x$
force $6 \mid x$, and both sides have $6$ elements, so it is a bijection. The
cardinality claim then follows from Theorem 4.3. $\square$

> **Theorem 7.2 (Non-collision of $\mathbb{Z}/4\mathbb{Z}$ with the Klein
> four-group).** The groups $\mathbb{Z}/4\mathbb{Z}$ and $\mathbb{Z}/2\mathbb{Z}
> \times \mathbb{Z}/2\mathbb{Z}$ each have four elements but are **not**
> isomorphic.

*Proof sketch.* The element $1 \in \mathbb{Z}/4\mathbb{Z}$ has order $4$. In
$\mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$ every element $a$ satisfies
$2a = 0$, so no element has order $4$. "Possesses an element of order $4$" is
transported by isomorphism (Theorem 4.1 applied to a generator), so it is an
isomorphism-invariant predicate that holds for one group and fails for the other.
By Theorem 4.4 the two cannot be isomorphic. $\square$

Theorems 7.1 and 7.2 illustrate the two edges of the same blade. The order
spectrum — the multiset of element orders — is an isomorphism invariant strong
enough to hide the difference between $+1$ and $-1$ inside a single group (§5–6)
and simultaneously to *separate* non-isomorphic groups of equal size.

---

## 8. Isomorphisms as analogies: a Copycat reading

The torsor of §3 admits a striking interpretation as a theory of analogy. In
Hofstadter's *Copycat* architecture for analogical reasoning, making an analogy
means mapping the *role* an object plays in one situation onto the corresponding
role in another. A completed analogy is thus a structure-preserving
correspondence — an isomorphism, in our terms — and the celebrated phenomenon of
"slippage," in which several analogies are simultaneously defensible, is the
observation that such correspondences are not unique.

Our results formalize this. An analogy from $G$ to $H$ is an element of
$\mathrm{Iso}(G, H)$. By Theorems 3.1–3.2 the space of equally valid analogies is a
torsor under $\mathrm{Aut}(G)$ (equivalently $\mathrm{Aut}(H)$): there is no
canonical "best" analogy, only a symmetric space of alternatives, and by
Propositions 3.3–3.4 any two analogies differ by a unique symmetry, the exact
"amount of slippage" between them. In the cyclic case (Corollary 6.4) the number
of competing analogies is $\varphi(n)$.

> **Principle (Slippage as a torsor).** The space of equally valid analogies
> between two isomorphic structures is a torsor under the automorphism group of
> either. Conceptual slippage is the difference of two analogies, an element of
> that automorphism group; the freedom of the analogy is measured by the group's
> size.

This recasts a qualitative observation about human cognition as a precise
statement about symmetry: creativity in analogy-making lives exactly in the
absence of a basepoint.

---

## 9. Algorithms

The results above are effective for finite cyclic groups. We record the core
computations.

**Automorphism enumeration.** To enumerate $\mathrm{Aut}(\mathbb{Z}/n\mathbb{Z})$,
list the units $U = \{k : 1 \le k \le n,\ \gcd(k, n) = 1\}$; each unit $k$ is the
automorphism $x \mapsto kx \bmod n$. This produces exactly $\varphi(n)$
automorphisms (Theorem 6.3).

**Ambiguity count.** Given a cyclic group of order $n$, its meaning-ambiguity is
$\varphi(n) = n \prod_{p \mid n} (1 - 1/p)$, computable by factoring $n$
(Corollary 6.4).

**Order spectrum test for isomorphism.** For finite abelian groups, compute the
multiset of element orders of each; equal spectra are necessary for isomorphism
and, for the small examples here, sufficient to separate non-isomorphic groups
(Theorem 7.2). The Chinese Remainder collision (Theorem 7.1) is verified by
checking that the coordinatewise map is a bijection.

---

## 10. Discussion

The picture that emerges is a clean separation between two layers of a
mathematical object. The *structural* layer — orders, cyclicity, cardinality, and
in general every isomorphism-invariant predicate — is transported perfectly across
any identification (§4). The *semantic* layer — which concrete element deserves the
name "$1$" — is precisely the part on which identifications may disagree, and it is
irrecoverable exactly to the extent that the automorphism group is nontrivial
(§5). The two layers are joined by the torsor structure of §3, and in the cyclic
case the semantic ambiguity is measured by Euler's totient (§6).

Two consequences deserve emphasis. First, the ambiguity of meaning is not a defect
to be repaired but a genuine invariant, as objective as cardinality. Second, the
very invariants that render isomorphic twins indistinguishable are what allow
non-isomorphic strangers to be told apart (§7): structural invariance is a
double-edged tool.

---

## 11. Future directions

- **From automorphism groups to full torsors.** Upgrade the set bijections of §3
  to an equivariant statement: $\mathrm{Iso}(G, H)$ is a right torsor under
  $\mathrm{Aut}(G)$ and a left torsor under $\mathrm{Aut}(H)$, with commuting
  actions, giving $|\mathrm{Iso}(G,H)| = |\mathrm{Aut}(G)| = |\mathrm{Aut}(H)|$
  whenever nonempty, for arbitrary (not merely cyclic) groups.
- **The totient bridge for general finite abelian groups.** By the structure
  theorem, $\mathrm{Aut}(\bigoplus \mathbb{Z}/n_i)$ is a product of general linear
  groups over residue rings; a general count of $|\mathrm{Aut}(A)|$ would quantify
  meaning-ambiguity for every finite abelian $A$.
- **Multiplicative and ring-theoretic collisions.** Mirror the additive
  development for multiplicative and ring isomorphisms; a striking target is
  $(\mathbb{Z}/p\mathbb{Z})^\times \cong \mathbb{Z}/(p-1)\mathbb{Z}$ for prime
  $p$, a multiplicative structure that is secretly additive.
- **Categorical formulation.** Rephrase structural invariance as: any functor to
  truth values inverts isomorphisms; the "isomorphism of isomorphisms" becomes a
  statement about the core groupoid, with $\mathrm{Aut}$ the categorical
  automorphism group and $\mathrm{Iso}$ an $\mathrm{Aut}$-principal homogeneous
  set.
- **Logical / definability sharpening.** Strengthen structural invariance to a
  definability statement: elements related by an automorphism satisfy the same
  first-order formulas with parameters fixed by that automorphism.
- **Copycat / analogy quantification.** Equip the analogy torsor with a metric
  (e.g. via a Cayley graph of $\mathrm{Aut}$) to formalize "conceptual slippage"
  between competing analogies as graph distance.

---

## 12. Conclusion

Structure and meaning are distinct. Structure is what survives every
identification; meaning is the labeling no identification can force. The space of
meanings compatible with a fixed structure is a torsor over its automorphism
group, and for a cyclic group of order $n$ its size is Euler's totient
$\varphi(n)$. Isomorphic structures preserve all truth but not all meaning — and
the gap between the two is, at last, a number.
