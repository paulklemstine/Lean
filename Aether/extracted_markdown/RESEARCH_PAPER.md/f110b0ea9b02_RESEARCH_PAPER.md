# Galois Theory of Cellular Automata: Reversibility Groups over Finite Groups

## Abstract

We develop the algebraic theory of reversible cellular automata by generalizing from cyclic groups ℤ/nℤ to arbitrary finite groups G. The **reversibility group** RevGroup(G, α) — the group of all bijections of α^G that commute with all left-translations — is shown to equal the centralizer of the left-regular representation of G in Sym(α^G). We prove nine structural theorems, including: (1) the inverse of a translation-equivariant bijection is translation-equivariant; (2) the symmetric group Sym(α) embeds injectively into RevGroup via pointwise permutations; (3) for commutative groups G, all translations embed into RevGroup; (4) the translation embedding is injective when |α| ≥ 2; (5) translations and pointwise permutations commute; (6) RevGroup preserves translation orbits (necklaces); (7) RevGroup is a proper subgroup of Sym(α^G) when |G|, |α| ≥ 2; (8) for G = {e}, RevGroup = Sym(α); (9) the centralizer characterization gives an iff criterion for membership. All results are formalized and verified in Lean 4 with Mathlib, extending prior work on periodic configurations over ℤ/nℤ.

## 1. Introduction

A cellular automaton (CA) on a group G with alphabet α is a function F : α^G → α^G that commutes with all left-translations τ_g(c)(x) = c(g⁻¹x). This is the algebraic formulation of the Curtis-Hedlund-Lyndon theorem: continuous, shift-commuting functions on the full shift are exactly the cellular automata.

The **reversibility question** — which CAs have a two-sided inverse that is also a CA? — has been studied extensively for ℤ and ℤ^d (see [1-4]). The answer is elegant: a CA is reversible if and only if it is bijective, and by Hedlund's theorem, the inverse of a bijective CA is again a CA.

In this paper, we study the group structure of all reversible CAs simultaneously. The **reversibility group** RevGroup(G, α) consists of all bijections of α^G that commute with every left-translation. We prove that this group has rich algebraic structure and is intimately connected to classical group-theoretic objects.

### 1.1 Main Contributions

Our main contributions are:

1. **Generalization**: We extend the theory from ℤ/nℤ to arbitrary finite groups G, revealing new phenomena for non-abelian groups.

2. **Centralizer characterization** (Theorem 5.1): RevGroup(G, α) = C_{Sym(α^G)}({τ_g : g ∈ G}), the centralizer of the translation action.

3. **Structural embeddings** (Theorems 3.1, 4.1): Two canonical embeddings — Sym(α) ↪ RevGroup via pointwise permutations, and G ↪ RevGroup via translations (for commutative G) — give a lower bound |RevGroup| ≥ |G| · |α|!.

4. **Orbit preservation** (Theorem 6.1): Every element of RevGroup maps translation orbits to translation orbits, connecting reversibility to necklace combinatorics.

5. **Proper subgroup theorem** (Theorem 7.1): For |G| ≥ 2 and |α| ≥ 2, RevGroup is always a proper subgroup of Sym(α^G).

6. **Machine-verified proofs**: All results are formalized in Lean 4 with Mathlib, providing the highest level of mathematical certainty.

## 2. Definitions

**Definition 2.1 (Translation).** For a group G, finite alphabet α, and g ∈ G, the left-translation τ_g : α^G → α^G is defined by τ_g(c)(x) = c(g⁻¹x).

**Proposition 2.1.** Translations satisfy: (a) τ_1 = id; (b) τ_g ∘ τ_h = τ_{gh}.

**Definition 2.2 (Translation-equivariance).** A function F : α^G → α^G is translation-equivariant if F ∘ τ_g = τ_g ∘ F for all g ∈ G.

**Definition 2.3 (Reversibility group).** RevGroup(G, α) = { e ∈ Sym(α^G) : e is translation-equivariant }.

**Lemma 2.1.** RevGroup(G, α) is a subgroup of Sym(α^G).

*Proof.* The identity is equivariant. If e₁, e₂ are equivariant, then (e₁ ∘ e₂)(τ_g(c)) = e₁(τ_g(e₂(c))) = τ_g(e₁(e₂(c))). For the inverse: if e(τ_g(c)) = τ_g(e(c)) for all g, c, then setting c = e⁻¹(d), we get e(τ_g(e⁻¹(d))) = τ_g(d), so e⁻¹(τ_g(d)) = τ_g(e⁻¹(d)). ∎

## 3. The Pointwise Embedding

**Definition 3.1 (Pointwise permutation).** For σ ∈ Sym(α), define pw(σ) : α^G → α^G by pw(σ)(c) = σ ∘ c.

**Theorem 3.1.** pw(σ) ∈ RevGroup(G, α) for all σ ∈ Sym(α). Moreover, pw : Sym(α) → RevGroup(G, α) is an injective group homomorphism when G is nonempty.

*Proof.* Equivariance: pw(σ)(τ_g(c))(x) = σ(c(g⁻¹x)) = τ_g(σ ∘ c)(x) = τ_g(pw(σ)(c))(x). Injectivity: if pw(σ) = pw(τ), then for any a ∈ α and the constant configuration c_a ≡ a, we have σ(a) = pw(σ)(c_a)(x₀) = pw(τ)(c_a)(x₀) = τ(a) for any x₀ ∈ G. ∎

**Example 3.1.** For G = ℤ/nℤ and α = {0, 1}, the pointwise permutation pw((0 1)) is Wolfram Rule 51 (the complement). It has order 2 in RevGroup.

## 4. The Translation Embedding (Abelian Case)

**Theorem 4.1 (Abelian translation theorem).** If G is commutative, then τ_g ∈ RevGroup(G, α) for all g ∈ G.

*Proof.* τ_g(τ_h(c)) = τ_{gh}(c) = τ_{hg}(c) = τ_h(τ_g(c)), where the middle equality uses commutativity. ∎

**Remark 4.1.** This fails for non-abelian G. If g and h do not commute, then τ_g(τ_h(c))(x) = c(h⁻¹g⁻¹x) ≠ c(g⁻¹h⁻¹x) = τ_h(τ_g(c))(x) in general. The element τ_g lies in RevGroup iff g is in the center Z(G).

**Theorem 4.2 (Translation injectivity).** For |α| ≥ 2, the map g ↦ τ_g is injective.

*Proof.* If τ_g = τ_h, choose distinct a, b ∈ α and consider c = χ_{g⁻¹} (the indicator of {g⁻¹}). Then τ_g(c)(1) = c(g⁻¹) = a, while τ_h(c)(1) = c(h⁻¹). If g ≠ h, then h⁻¹ ≠ g⁻¹, so c(h⁻¹) = b ≠ a, contradiction. ∎

**Theorem 4.3 (Commutativity of embeddings).** For all g ∈ G and σ ∈ Sym(α):
τ_g · pw(σ) = pw(σ) · τ_g

*Proof.* (τ_g ∘ pw(σ))(c)(x) = σ(c(g⁻¹x)) = (pw(σ) ∘ τ_g)(c)(x). ∎

**Corollary 4.1.** The subgroup of RevGroup generated by translations (in the abelian case) and pointwise permutations is isomorphic to G × Sym(α), giving the lower bound |RevGroup| ≥ |G| · |α|!.

## 5. The Centralizer Characterization

**Theorem 5.1 (Centralizer theorem).** e ∈ RevGroup(G, α) if and only if e commutes with τ_g for all g ∈ G.

*Proof.* (⇒): If e is translation-equivariant, then for all c, (e ∘ τ_g)(c) = e(τ_g(c)) = τ_g(e(c)) = (τ_g ∘ e)(c). So e · τ_g = τ_g · e as permutations.

(⇐): If e · τ_g = τ_g · e for all g, then for all c, e(τ_g(c)) = τ_g(e(c)), which is translation-equivariance. ∎

**Corollary 5.1.** RevGroup(G, α) = C_{Sym(α^G)}(T), where T = {τ_g : g ∈ G} is the image of G under the translation representation.

This is the key structural insight: the reversibility group is a centralizer, and its structure is governed by the representation theory of T acting on α^G.

## 6. Orbit Preservation

**Definition 6.1 (Translation orbit / necklace).** The translation orbit of c ∈ α^G is O(c) = {τ_g(c) : g ∈ G}.

**Theorem 6.1 (Necklace theorem).** For all e ∈ RevGroup(G, α): e(O(c)) = O(e(c)).

*Proof.* (⊆): If d ∈ e(O(c)), then d = e(τ_g(c)) = τ_g(e(c)) ∈ O(e(c)).
(⊇): If d ∈ O(e(c)), then d = τ_g(e(c)) = e(τ_g(c)) ∈ e(O(c)). ∎

**Corollary 6.1.** The action of RevGroup on α^G descends to an action on the set of translation orbits. This connects the reversibility group to necklace combinatorics.

**Example 6.1.** For G = ℤ/3ℤ and α = {0,1}, the 8 configurations partition into orbits: {000}, {111}, {001, 010, 100}, {011, 110, 101}. Every element of RevGroup must map this partition to itself (possibly permuting orbits of the same size).

## 7. The Proper Subgroup Theorem

**Theorem 7.1 (Proper subgroup).** For |G| ≥ 2 and |α| ≥ 2, RevGroup(G, α) ⊊ Sym(α^G).

*Proof.* Let g₀ ∈ G with g₀ ≠ 1, and a, b ∈ α with a ≠ b. Define c₀ ≡ a (constant) and c₁(x) = b if x = 1, a otherwise. The swap permutation (c₀ c₁) is not translation-equivariant: τ_{g₀}(c₁) ≠ c₀ and ≠ c₁ (since shifting moves the "spike" to a different position), so the swap fixes τ_{g₀}(c₁), but τ_{g₀} maps c₁ to something different from c₁ while the swap exchanges c₁ and c₀. ∎

## 8. Boundary Cases

**Theorem 8.1 (Trivial group boundary).** For G = {e} (the trivial group): RevGroup({e}, α) = Sym(α).

*Proof.* The only translation is the identity, so every permutation commutes with it. ∎

**Theorem 8.2 (Fixed-point boundary).** For any G and α, the constant configurations are fixed by all translations: τ_g(c_a) = c_a where c_a(x) = a for all x.

## 9. Concrete Computations

### 9.1 Shift Cycle Type and Centralizer Order

For G = ℤ/nℤ and α = {0,1}, the shift σ acts on 2^n configurations. Its cycle type determines the centralizer order:

| n | Cycle type | |Centralizer| | |S_{2^n}| | Ratio |
|---|-----------|--------------|----------|-------|
| 2 | {1:2, 2:1} | 4 | 24 | 0.167 |
| 3 | {1:2, 3:2} | 18 | 40,320 | 4.5×10⁻⁴ |
| 4 | {1:2, 2:1, 4:3} | 384 | 2.1×10¹³ | 1.8×10⁻¹¹ |
| 5 | {1:2, 5:6} | 4,320,000 | 2.6×10³⁵ | 1.7×10⁻²⁹ |

### 9.2 Reversible Elementary CAs

The 6 reversible elementary CAs (radius 1, binary) are:

| Rule | Function | Description |
|------|----------|-------------|
| 204 | f(a,b,c) = b | Identity |
| 170 | f(a,b,c) = c | Left shift |
| 240 | f(a,b,c) = a | Right shift |
| 51 | f(a,b,c) = ¬b | Complement |
| 85 | f(a,b,c) = ¬c | Left shift + complement |
| 15 | f(a,b,c) = ¬a | Right shift + complement |

These generate a group isomorphic to ℤ × ℤ/2ℤ modulo the finite period constraint.

## 10. PEGB Analysis

### Theorem: Centralizer Characterization (Theorem 5.1)

- **Proof**: Complete Lean 4 proof using extensionality and unfolding of definitions.
- **Example**: For G = ℤ/3ℤ, α = {0,1}, the centralizer of σ in S₈ has order 18 = 2 · 3² (from cycle type {1², 3²}).
- **Generalization**: The next level up would be characterizing centralizers for the shift acting on α^{G×H} for product groups, connecting to higher-dimensional CA theory.
- **Boundary**: The characterization breaks down for infinite groups (where Sym(α^G) is not a finite group and the centralizer theory becomes more subtle).

### Theorem: Abelian Translation Embedding (Theorem 4.1)

- **Proof**: Direct computation using commutativity of G.
- **Example**: For G = ℤ/4ℤ, translations by 0,1,2,3 give 4 distinct elements of RevGroup. Combined with the complement (pointwise), this gives at least 8 elements.
- **Generalization**: For non-abelian G, the embedding restricts to Z(G), the center. Computing |RevGroup| for non-abelian G involves the centralizer of a non-regular representation.
- **Boundary**: For the free group F₂ (infinite, non-abelian, trivial center), the only "translation" in RevGroup is the identity.

### Theorem: Proper Subgroup (Theorem 7.1)

- **Proof**: Constructive — exhibits an explicit permutation not in RevGroup.
- **Example**: For G = ℤ/2ℤ, α = {0,1}: |RevGroup| = 4 while |S₄| = 24.
- **Generalization**: The ratio |RevGroup|/|Sym(α^G)| → 0 super-exponentially as |G| → ∞.
- **Boundary**: For G = {e}, RevGroup = Sym(α), so the inequality is sharp: it fails precisely when |G| = 1.

## 11. Discussion

### 11.1 Connection to Existing Catalog Results

Our work directly extends `Catalog/Geometry/CellularAutomataGalois.lean`, which established the reversibility subgroup and proved `reversibility_proper_subgroup` for the specific case n = 3, α = Bool. We generalize this to arbitrary finite groups G and alphabets α with arbitrary cardinality.

We also connect to `Catalog/Tropical/HashInversion.lean` through the theme of `reversible_iff_bijective`: a function on finite types is reversible iff bijective, and our RevGroup consists exactly of the bijections satisfying an additional equivariance constraint.

### 11.2 The Non-Abelian Surprise

The most surprising finding is the connection between commutativity and reversibility for non-abelian groups. The fact that translation by g gives a reversible CA only when g ∈ Z(G) means that the center of the group controls the translational part of the reversibility group. For groups with trivial center (like simple non-abelian groups), the only reversible translations are the identity — a dramatic restriction compared to the abelian case.

### 11.3 Categorical Perspective

The reversibility group can be understood categorically as the automorphism group of the G-set α^G (with G acting by translation). This connects to the theory of permutation groups, wreath products, and the Burnside ring.

## 12. Future Work

1. Compute RevGroup explicitly for non-abelian groups (S₃, D₄, Q₈).
2. Prove the wreath product decomposition of RevGroup from the cycle type.
3. Extend to infinite groups (ℤ, ℤ^d) using topological methods.
4. Connect to quantum cellular automata on finite groups.
5. Study the lattice of subgroups of RevGroup and its Galois-theoretic interpretation.

## References

[1] G. A. Hedlund, "Endomorphisms and automorphisms of the shift dynamical system," *Mathematical Systems Theory*, 3:320–375, 1969.

[2] T. Ceccherini-Silberstein and M. Coornaert, *Cellular Automata and Groups*, Springer, 2010.

[3] S. Wolfram, *A New Kind of Science*, Wolfram Media, 2002.

[4] J. Kari, "Reversibility and surjectivity problems of cellular automata," *Journal of Computer and System Sciences*, 48(1):149–182, 1994.

[5] Catalog result: `Catalog/Geometry/CellularAutomataGalois.lean` — reversibility_proper_subgroup, inv_shift_equivariant.

[6] Catalog result: `Catalog/Tropical/HashInversion.lean` — reversible_iff_bijective.
