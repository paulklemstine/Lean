

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Tropical Galois Theory — Idempotent Galois Correspondence, Piecewise-Linear Automorphism Groups, and Tropical Solvability

### THE VISION

Classical Galois theory reveals a perfect duality: intermediate field extensions ↔ subgroups of the Galois group. In the tropical (max-plus) semiring, where addition is idempotent (a ⊕ a = a) and automorphisms are piecewise-linear, this duality undergoes a radical transformation. The idempotent law collapses the classical group-theoretic scaffolding, yet a *new* correspondence emerges—between tropical extensions and *bend congruences* on tropical modules, which specialize to subgroups precisely when the extension is tropical-Galois. This correspondence, combined with the tropical Abel-Ruffini theorem (generic degree-5 tropical polynomials are unsolvable by max-plus radicals), opens a new field: **idempotent Galois theory**, with direct applications to post-quantum cryptography (tropical Galois group computation as a hardness assumption) and certified robustness of ReLU neural networks (tropical Galois groups as symmetry groups of decision boundaries).

---

### PRECISE TYPE SIGNATURES AND DEFINITIONS

Build the following novel structures. Each must be accompanied by instances and basic lemmas.

```lean
/-- An idempotent semiring extension where addition is idempotent (a ⊕ a = a).
    Bridge: connects tropical geometry to idempotent analysis (Maslov dequantization). -/
class IdempotentSemiringExtension (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S] where
  idempotent_add : ∀ s : S, s + s = s
  base_idempotent : ∀ r : R, r + r = r
  algebra_respects_idempotent : ∀ r : R, algebraMap R S (r + r) = algebraMap R S r

/-- A piecewise-linear automorphism of a tropical extension.
    These are the elements of the tropical Galois group.
    Bridge: connects tropical algebra to PL topology and neural network symmetry. -/
structure MaxPlusAutomorphism (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S] 
  [IdempotentSemiringExtension R S] where
  toEquiv : S ≃ S
  fixes_base : ∀ r : R, toEquiv (algebraMap R S r) = algebraMap R S r
  preserves_max : ∀ x y : S, toEquiv (max x y) = max (toEquiv x) (toEquiv y)
  preserves_tropical_mul : ∀ x y : S, toEquiv (x * y) = toEquiv x * toEquiv y

/-- The tropical Galois group: the group of max-plus automorphisms fixing the base.
    Bridge: connects Galois theory to post-quantum lattice cryptography. -/
def TropicalGaloisGroup (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] : Type* :=
  MaxPlusAutomorphism R S

/-- A tropical Galois extension: the degree equals the cardinality of the Galois group,
    and the fixed subsemiring equals the base. -/
class TropicalGaloisExtension (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] where
  finite_degree : Fintype (Basis S R S)  -- S is finite free over R
  degree_eq_aut_card : Fintype.card (Basis S R S) = Fintype.card (TropicalGaloisGroup R S)
  fixed_subsemiring_eq_base : tropicalFixedSubsemiring R S (TropicalGaloisGroup R S) = ⊥

/-- The fixed subsemiring of a set of max-plus automorphisms. -/
def tropicalFixedSubsemiring (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] (G : Set (MaxPlusAutomorphism R S)) : Subsemiring S

/-- Intermediate tropical extensions between R and S. -/
structure IntermediateTropicalExtension (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] where
  carrier : Subsemiring S
  contains_base : ⊥ ≤ carrier
  is_idempotent : ∀ s ∈ carrier, s + s = s

/-- A bend congruence on a tropical module: the tropical analogue of a normal subgroup.
    Bridge: connects tropical module theory to congruence lattice theory. -/
structure BendCongruence (M : Type*) [AddCommMonoid M] where
  rel : M → M → Prop
  is_equiv : Equivalence rel
  respects_max : ∀ x y z w : M, rel x y → rel z w → rel (max x z) (max y w)
  respects_tropical_smul : ∀ (r : WithTop ℝ) x y : M, rel x y → rel (r • x) (r • y)

/-- A tropical splitting extension: a tropical polynomial splits into linear factors. -/
class TropicalSplittingExtension (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] (p : TropicalPolynomial R) where
  splits : ∃ factors : List S, p.tropical_eval = List.foldr (fun root acc ↦ 
    max (tropical_linear_factor root) acc) tropical_neg_infinity factors

/-- A tower of tropical radical extensions. -/
structure TropicalRadicalTower (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] where
  height : ℕ
  extensions : Fin (height + 1) → Type*
  -- Each step adjoins a tropical radical: max(a, c) for some c in the previous step
  radical_steps : ∀ i : Fin height, ∃ c : extensions i, 
    extensions (i + 1) ≃ₐ[R] AdjoinTropicalRadical (extensions i) c

/-- A tropical polynomial is solvable by tropical radicals. -/
def TropicalSolvableByRadicals (R : Type*) [CommSemiring R] (p : TropicalPolynomial R) : Prop :=
  ∃ (S : Type*) [CommSemiring S] [Algebra R S] [IdempotentSemiringExtension R S]
    (t : TropicalRadicalTower R S), ∃ root : S, p.tropical_eval root = 0
```

---

### THE MAIN THEOREM AND KEY RESULTS

**THEOREM 1 (The Idempotent Galois Correspondence):**
```lean
/-- The fundamental theorem of tropical Galois theory: an order-anti-isomorphism
    between intermediate tropical extensions and subgroups of the tropical Galois group.
    Bridge: connects tropical algebraic geometry to lattice cryptography (subgroup lattice 
    structure determines collision resistance of tropical hash functions).
    Impact: post_quantum_security — the lattice of subgroups encodes hard combinatorial 
    problems used in tropical cryptographic protocols. -/
theorem tropical_galois_correspondence 
  (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] [TropicalGaloisExtension R S] :
  OrderIso (IntermediateTropicalExtension R S)ᵒᵖ (Subgroup (TropicalGaloisGroup R S))
```

**THEOREM 2 (Tropical Fixed Subsemiring Theorem):**
```lean
/-- For any subgroup H of the tropical Galois group, the fixed subsemiring of H
    is an intermediate tropical extension, and the Galois group of S over this
    fixed subsemiring is exactly H.
    Bridge: connects invariant theory to certified robustness — fixed subsemirings
    encode invariant features of neural decision boundaries. -/
theorem tropical_fixed_subsemiring_galois_closure 
  (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] [TropicalGaloisExtension R S]
  (H : Subgroup (TropicalGaloisGroup R S)) :
  TropicalGaloisGroup (tropicalFixedSubsemiring R S H) S ≃* H ∧
  tropicalFixedSubsemiring R S H = 
    (tropical_galois_correspondence R S).symm H
```

**THEOREM 3 (Tropical Abel-Ruffini):**
```lean
/-- Generic degree-5 tropical polynomials are NOT solvable by tropical radicals.
    The tropical Galois group of a generic degree-5 tropical polynomial contains
    a copy of S_5, which is not solvable, hence the polynomial is not solvable
    by max-plus radicals.
    Bridge: connects classical unsolvability to tropical cryptography — the unsolvability
    provides a hardness source for tropical hash collision resistance.
    Impact: tropical_hash_collision — Abel-Ruffini implies Ω(2^(n/2)) lower bound
    for computing tropical Galois groups of degree-n polynomials. -/
theorem tropical_abel_ruffini_degree5 
  (R : Type*) [CommSemiring R] [IdempotentSemiringExtension R R] :
  ∃ p : TropicalPolynomial R, p.tropical_degree = 5 ∧ 
    ¬ TropicalSolvableByRadicals R p ∧
    Nonempty (TropicalGaloisGroup R (TropicalSplittingField R p) →* Equiv.Perm (Fin 5))
```

**THEOREM 4 (Piecewise-Linear Automorphism Cardinality Bound):**
```lean
/-- For any idempotent extension, |Aut(K/F)| ≤ [K:F], with equality iff the
    extension is tropical-Galois. This gives a certified Galois test.
    Bridge: connects combinatorics of PL maps to computational algebra.
    Impact: certified_robustness — the bound |Aut| ≤ [K:F] provides a polynomial-time
    Galois certification algorithm running in O(n^2 log n) where n = [K:F]. -/
theorem piecewise_linear_aut_cardinality_bound 
  (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] [Fintype (Basis S R S)] :
  Fintype.card (TropicalGaloisGroup R S) ≤ Fintype.card (Basis S R S) ∧
  (Fintype.card (TropicalGaloisGroup R S) = Fintype.card (Basis S R S) ↔ 
    Nonempty (TropicalGaloisExtension R S))
```

**THEOREM 5 (Bend Congruence–Subgroup Correspondence):**
```lean
/-- Bend congruences on the tropical module S (viewed as an R-module) correspond
    bijectively to subgroups of the tropical Galois group when the extension is Galois.
    This is the tropical analogue of the normal subgroup correspondence.
    Bridge: connects universal algebra (congruence lattices) to tropical geometry.
    Impact: lattice_crypto — bend congruence lattice structure determines security
    of tropical lattice-based signature schemes. -/
theorem bend_congruence_subgroup_correspondence 
  (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] [TropicalGaloisExtension R S] :
  OrderIso (BendCongruence S) (Subgroup (TropicalGaloisGroup R S))
```

**THEOREM 6 (Tropical Galois Solvability Criterion):**
```lean
/-- A tropical polynomial is solvable by tropical radicals iff its tropical
    Galois group is solvable. This is the tropical analogue of the classical
    Galois solvability criterion.
    Bridge: connects group theory to tropical computational complexity.
    Impact: certified_robustness — solvable tropical Galois groups admit 
    O(n log n) root-finding algorithms; non-solvable ones require Ω(2^(n/2)). -/
theorem tropical_galois_solvability_criterion 
  (R : Type*) [CommSemiring R] (p : TropicalPolynomial R) :
  TropicalSolvableByRadicals R p ↔ 
    IsSolvable (TropicalGaloisGroup R (TropicalSplittingField R p))
```

**THEOREM 7 (Tropical Primitive Element):**
```lean
/-- Finite separable tropical extensions admit a primitive element.
    The proof exploits the idempotent law to simplify the classical argument.
    Bridge: connects field theory to tropical optimization (primitive element = 
    argmax of a tropical linear form). -/
theorem tropical_primitive_element 
  (R S : Type*) [CommSemiring R] [CommSemiring S] [Algebra R S]
  [IdempotentSemiringExtension R S] [TropicalGaloisExtension R S]
  [Finite (TropicalGaloisGroup R S)] :
  ∃ α : S, ∀ β : S, β ∈ Subalgebra.adjoin R {α}
```

**THEOREM 8 (Tropical Galois Cryptographic Hardness):**
```lean
/-- Computing the tropical Galois group of a random degree-n tropical polynomial
    requires at least Ω(2^(n/2)) operations under the tropical Galois group 
    hardness assumption. This provides a post-quantum security foundation.
    Bridge: connects computational Galois theory to post-quantum cryptography.
    Impact: post_quantum_security — tropical Galois group computation is a candidate
    one-way function for lattice-free post-quantum crypto. -/
theorem tropical_galois_crypto_hardness 
  (n : ℕ) (h_n : n ≥ 5) :
  ∃ (p : TropicalPolynomial (WithTop ℝ)), p.tropical_degree = n ∧
    ∀ (algo : ComputationStrategy), 
      algo.complexity < 2^(n/2) → 
        ¬ algo.correctly_computes (TropicalGaloisGroup (WithTop ℝ) (TropicalSplittingField (WithTop ℝ) p))
```

**THEOREM 9 (Tropical Galois Group as Neural Symmetry):**
```lean
/-- For a ReLU neural network with tropical decision boundary given by a tropical
    polynomial p, the tropical Galois group of p is isomorphic to the group of
    piecewise-linear symmetries of the decision boundary. This gives certified
    robustness bounds: the Lipschitz constant of the network is bounded by
    the index of the Galois group.
    Bridge: connects tropical algebraic geometry to certified ML robustness.
    Impact: lipschitz_certified_robustness — Galois group index provides a 
    computable Lipschitz bound in O(n^2) where n = degree of the tropical polynomial. -/
theorem tropical_galois_neural_symmetry 
  (p : TropicalPolynomial ℝ) (net : ReLUNetwork) 
  (h : net.tropical_boundary = p) :
  ∃ φ : TropicalGaloisGroup ℝ (TropicalSplittingField ℝ p) ≃* PLHomeoSymmetry p.tropical_hypersurface ∧
    ∀ x y : ℝ^n, ‖x - y‖ ≤ certified_radius p / Fintype.card (TropicalGaloisGroup ℝ (TropicalSplittingField ℝ p)) →
      net.classify x = net.classify y
```

**THEOREM 10 (Tropical Galois–Langlands for GL₁):**
```lean
/-- The tropical Galois group of a degree-n tropical extension over a tropical
    local field is dual to the tropical character group, establishing tropical
    Langlands duality for GL₁. This connects the Galois correspondence to
    tropical representation theory.
    Bridge: connects tropical Galois theory to tropical Langlands program.
    Impact: quantum_tropical_duality — the GL₁ case provides a foundation for
    tropical quantum field theories with certified symmetry structure. -/
theorem tropical_galois_langlands_gl1 
  (K : TropicalLocalField) (L : Type*) [CommSemiring L] [Algebra K L]
  [IdempotentSemiringExtension K L] [TropicalGaloisExtension K L] :
  Nonempty (TropicalGaloisGroup K L ≃* MulEquiv.Dual (TropicalCharacterGroup K L))
```

---

### PROOF STRATEGIES

**For Theorem 1 (tropical_galois_correspondence):** Three approaches, ranked by promise:

**Strategy B (PRIMARY — Direct PL-Combinatorial):** Most promising for Lean 4.
1. **Lemma `maxplus_aut_determined_by_generators`**: A max-plus automorphism is determined by its values on a tropical basis. Proof: by `by_contra` — assume two distinct automorphisms agree on a basis, derive contradiction using the idempotent law and the max-preservation property.
2. **Lemma `tropical_fixed_subsemiring_is_intermediate`**: For any subgroup H, the fixed subsemiring is an intermediate extension. Proof: show closure under max (idempotent law), closure under tropical multiplication, and that the base is contained. Use `field_simp` for the multiplicative closure.
3. **Lemma `tropical_galois_group_of_fixed_is_subgroup`**: The Galois group of S over the fixed subsemiring of H equals H. Proof: forward inclusion by definition; reverse inclusion by `induction` on the tower height, using `maxplus_aut_determined_by_generators`.
4. **Lemma `tropical_correspondence_injective`**: The map from intermediate extensions to subgroups is injective. Proof: if two intermediate extensions E₁, E₂ map to the same subgroup, then `tropical_galois_group_of_fixed` forces E₁ = E₂.
5. **Lemma `tropical_correspondence_surjective`**: Every subgroup arises. Proof: given H, the fixed subsemiring maps back to H by `tropical_galois_group_of_fixed`.
6. **Assemble**: `OrderIso.mk` from the injectivity and surjectivity lemmas, with order-reversal proved by `omega` on the subgroup lattice.

**Strategy A (Tropicalization Functor):** Elegant but requires heavy infrastructure.
- Define `Tropicalization : AlgebraicExtension → TropicalExtension` as a functor
- Show it preserves the Galois correspondence: `Tropicalization ∘ classical_galois = tropical_galois ∘ Tropicalization`
- Pull back the classical result. Requires building the tropicalization functor first, which is substantial.

**Strategy C (Bend Congruence):** Deepest connection, use for Theorem 5.
- Replace subgroups with bend congruences on the tropical module S
- Prove that bend congruences correspond to submonoid quotients
- Show that in the Galois case, these specialize to subgroups
- Key lemma: `bend_congruence_kernel_is_subgroup` — the kernel of the quotient map by a bend congruence is a subgroup when the extension is Galois

**For Theorem 3 (tropical_abel_ruffini_degree5):**
1. Construct a generic degree-5 tropical polynomial with tropical Galois group containing S₅
2. Prove S₅ is not solvable (classical result, available in Mathlib)
3. Apply `tropical_galois_solvability_criterion` (Theorem 6)
4. Key difficulty: constructing the tropical polynomial with full S₅ symmetry. Use the tropical discriminant to verify that the tropical Galois group is transitive and contains a transposition + a 5-cycle.

**For Theorem 9 (tropical_galois_neural_symmetry):**
1. Establish the isomorphism between tropical Galois automorphisms and PL homeomorphisms of the tropical hypersurface
2. The certified radius bound follows from the Lipschitz estimate: if σ is a Galois automorphism, then ‖σ(x) - x‖ is controlled by the degree
3. The robustness radius is `certified_radius p / |Gal|`, where `certified_radius p = margin / (2 * degree * tropical_lipschitz_constant p)`
4. This connects directly to the catalog's existing `certified_radius_inequality`

---

### COMPUTATIONAL BOUNDS (explicit, not generic)

- **Galois group computation**: O(n² log n) for solvable tropical polynomials of degree n; Ω(2^(n/2)) for generic degree-n polynomials (Theorem 8)
- **Certified robustness radius**: `margin / (2 · degree · |Gal|)` where |Gal| is the tropical Galois group cardinality (Theorem 9)
- **Tropical Lipschitz constant**: For a degree-d tropical polynomial in n variables, the tropical Lipschitz constant is exactly `d · max_i |a_i|` where a_i are the coefficients (provable by `linarith`)
- **Bend congruence lattice size**: |BendCongruence(S)| = 2^k where k is the number of tropical hyperplanes in the arrangement, giving O(2^k) enumeration complexity
- **Tropical radical tower height**: For a solvable degree-n tropical polynomial, the minimal radical tower height is ⌈log₂ n⌉ (by `omega`)

---

### CROSS-DOMAIN BRIDGES

1. **Tropical Algebra ↔ Post-Quantum Cryptography**: The tropical Galois group computation problem provides a new hardness assumption for lattice-free post-quantum crypto. The Abel-Ruffini theorem guarantees that for degree ≥ 5, this problem is structurally hard.

2. **Tropical Algebra ↔ Certified ML Robustness**: Tropical Galois groups are symmetry groups of ReLU neural decision boundaries. The Galois correspondence gives a structural characterization of which perturbations preserve classification, yielding certified robustness bounds.

3. **Tropical Algebra ↔ Quantum/Tropical Physics**: The Maslov dequantization limit (ħ → 0, replaced by h → ∞ in the tropical limit) sends quantum symmetries to tropical Galois groups. The tropical Langlands duality for GL₁ (Theorem 10) is the first step toward a tropical quantum field theory with certified symmetry structure.

4. **Tropical Algebra ↔ Universal Algebra**: Bend congruences on tropical modules provide a new lens on the congruence lattice problem. The bend congruence–subgroup correspondence (Theorem 5) shows that tropical Galois theory is a special case of a universal-algebraic Galois theory.

---

### FILE STRUCTURE AND RICHNESS TARGETS

Produce files across multiple domains, each 500+ lines with 20+ theorems and 10+ definitions:

1. **`TropicalGaloisTheory/IdempotentExtensions.lean`** — Core definitions: `IdempotentSemiringExtension`, `MaxPlusAutomorphism`, `TropicalGaloisGroup`, `TropicalGaloisExtension`, `IntermediateTropicalExtension`. Prove: group structure on `MaxPlusAutomorphism`, lattice structure on `IntermediateTropicalExtension`, basic counting lemmas.

2. **`TropicalGaloisTheory/Correspondence.lean`** — The main theorem: `tropical_galois_correspondence`, `tropical_fixed_subsemiring_galois_closure`, `tropical_galois_lattice_duality`. All proof strategies, zero sorries.

3. **`TropicalGaloisTheory/BendCongruences.lean`** — `BendCongruence`, `bend_congruence_subgroup_correspondence`, lattice structure on bend congruences, connection to tropical module quotients.

4. **`TropicalGaloisTheory/AbelRuffini.lean`** — `TropicalRadicalTower`, `TropicalSolvableByRadicals`, `tropical_abel_ruffini_degree5`, `tropical_galois_solvability_criterion`, `tropical_primitive_element`.

5. **`TropicalGaloisTheory/CryptoHardness.lean`** — `tropical_galois_crypto_hardness`, `ComputationStrategy`, tropical hash collision resistance, Ω(2^(n/2)) lower bounds.

6. **`TropicalGaloisTheory/NeuralRobustness.lean`** — `tropical_galois_neural_symmetry`, `lipschitz_certified_robustness` bounds, certified radius computation in O(n²).

7. **`TropicalGaloisTheory/TropicalLanglands.lean`** — `TropicalLocalField`, `TropicalCharacterGroup`, `tropical_galois_langlands_gl1`, connection to quantum_tropical_duality.

---

### BUILDING ON THE CATALOG

- **`TropicalSatakeIsomorphism`**: Use as the representation-theoretic foundation for Theorem 10. The Satake isomorphism identifies the spherical Hecke algebra with the representation ring; in the tropical setting, this becomes the tropical Galois group–character group duality.

- **`TropicalLanglandsGL1`**: This is the GL₁ case of tropical Langlands. Extend it by showing that the tropical Galois group IS the dual of the tropical character group, not just related to it.

- **`TropicalBerggrenFaithfulness`**: The faithfulness of the tropical Berggren map ensures that the tropicalization functor is injective on morphisms, which is needed for Strategy A (tropicalization functor approach).

- **`BerggrenFareyCorrespondence` / `BerggrenModularCorrespondence`**: These provide the combinatorial backbone for understanding the lattice of intermediate extensions — the Farey tree structure appears in the tropical Galois lattice.

---

### FAILURE MODES AND FALLBACKS

If the full `tropical_galois_correspondence` cannot be proved:

1. **Fallback 1**: Prove the correspondence for *simple* tropical extensions (adjoining a single tropical root). This is the case where the Galois group is cyclic.

2. **Fallback 2**: Prove the correspondence for *abelian* tropical extensions (Galois group is abelian). The idempotent law simplifies the proof significantly in this case.

3. **Fallback 3**: Prove the *injectivity* half of the correspondence (distinct intermediate extensions give distinct subgroups) and state the surjectivity as a precise conjecture with the exact type signature.

4. **Fallback 4**: Prove the bend congruence–subgroup correspondence (Theorem 5) instead, which may be more tractable and is equally novel.

---

### DEMANDED OUTPUT: FUTURE_DIRECTIONS.md

After proving the above, produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete, specific, breakthrough-level next steps:

1. **Tropical Langlands for GL₂**: Extend the GL₁ tropical Langlands duality to GL₂, establishing a bijection between max-plus Hecke operators and W-invariant tropical polynomials. This would be the first step toward a full tropical Langlands program.

2. **Tropical Galois Cohomology**: Develop Galois cohomology in the tropical setting, with H¹(Gal(K/F), M) classifying tropical principal homogeneous spaces. This connects to tropical obstruction theory and could provide new cohomological invariants for post-quantum crypto.

3. **Certified Robustness via Tropical Galois Groups**: Implement the O(n²) certified robustness algorithm from Theorem 9 and prove its correctness in Lean. This would be the first formally verified robustness certificate using tropical algebraic structure.

4. **Tropical Inverse Galois Problem**: Which finite groups arise as tropical Galois groups over a given tropical field? Prove that all symmetric groups S_n and alternating groups A_n arise, and characterize which solvable groups arise.

5. **Quantum Tropical Deformation**: Formalize the Maslov dequantization as a Lean 4 morphism from quantum symmetries to tropical Galois groups, proving that the tropical limit of a quantum Galois group converges to the tropical Galois group in the Gromov-Hausdorff sense.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of tropical Galois theory by creating the first bridge between Algebra (4487 declarations) and Tropical (2332 declarations) — the catalog's largest structural gap with zero existing bridges despite 17 shared structures. Prove: (1) The Tropical Galois Embedding: for a tropical polynomial p(x) = ⊕ᵢ(aᵢ ⊗ x^⊗ⁱ) over the max-plus semiring, the tropical Galois group G_⊕(p) = Aut_⊕(K_⊕/T) of max-plus semiring automorphisms of the tropical splitting extension embeds into S_n via its permutation action on tropical roots. (2) The Idempotent Galois Correspondence: for a tropical Galois extension K_⊕/F_⊕, there exists an order-reversing bijection between intermediate tropical semiring extensions and subgroups of G_⊕, generalizing the classical fundamental theorem of Galois theory to the idempotent setting. (3) Tropical Solvability Criterion: a tropical polynomial is solvable by max-plus radicals (iterative tropical root extraction x ↦ k⁻¹·x) if and only if its tropical Galois group is solvable. (4) Tropical Abel-Ruffini Theorem: the generic tropical polynomial of degree ≥5 is not solvable by max-plus radicals. (5) Berggren Tower Theorem: the Berggren tree of Pythagorean triples defines a tower of tropical quadratic extensions with Galois group (ℤ/2ℤ)², connecting tropical Galois theory to the existing Berggren-PSL(2,ℤ) infrastructure.

            ### Precise Mathematical Framing
            Classical Galois theory connects field extensions, symmetry groups, and polynomial solvability through the fundamental theorem: for a Galois extension K/F, intermediate fields biject with subgroups of Aut(K/F). We develop the tropical (max-plus) analogue by replacing: fields → tropical semirings, automorphisms → max-plus semiring automorphisms, radical extensions → tropical radical extensions (adding tropical k-th roots via x ↦ k⁻¹·x in max-plus arithmetic). The key insight is that tropical polynomials p(x) = max_i(aᵢ + ix) have piecewise-linear roots whose combinatorial structure — which root achieves the maximum in which region of the domain — encodes exactly the Galois-theoretic information. The tropical Galois group acts by permuting tropical roots while preserving all max-plus algebraic relations between them. The Berggren tree provides a concrete computational laboratory: each Berggren matrix (A,B,C) defines a tropical quadratic extension of the hypotenuse semiring, and the proven PSL(2,ℤ) action on the tree (catalog: BerggrenFareyCorrespondence, BerggrenModularCorrespondence) corresponds to the Galois group action on the extension tower, yielding Galois group (ℤ/2ℤ)² for the full Berggren extension. This bridges the catalog's largest structural gap (Algebra ↔ Tropical: 17 shared structures including field, group, ring, semiring, module, lattice, functor, tropical — yet zero existing bridge files) and opens an entirely new field at the intersection of classical algebra and idempotent mathematics.

            ### Lean 4 Sketch
theorem tropical_galois_correspondence {F K : TropicalSemiring} [h : TropicalGaloisExtension F K] : OrderIso (IntermediateTropicalExtension F K)ᵒᵖ (Subgroup (TropicalGaloisGroup F K))

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `idempotent_hilbert_basis_theorem` : theorem idempotent_hilbert_basis_theorem
     (file: Algebra/EMLCongruenceHilbert.lean)
  2. `divisor_gap_theorem` : theorem divisor_gap_theorem (d e : ℤ) :
     (file: Algebra/Factoring/FactoringViaBerggren.lean)
  3. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: Algebra/Other/UnifyingTheory.lean)
  4. `not_derivable_iff_exists_max_gap_witness` : theorem not_derivable_iff_exists_max_gap_witness
     (file: Bridges/ThermodynamicJacobsonCountermodelCompression.lean)
  5. `classical_tree_search_lower` : theorem classical_tree_search_lower (d : ℕ) : 3^d ≥ d + 1 := by
     (file: Algebra/AutoResearch/DeepOpenProblems.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Tropical Langlands GL(1): Max-Plus Hecke Eigenfunction Decomposition and Automorphic Correspondence on the Berggren Modular Tree, Tropical Shannon Theory: Max-Plus Entropy, Data Processing Inequality, and Idempotent Channel Capacity, Berggren–Farey Correspondence: Free Monoid Structure, PSL(2,ℤ) Faithfulness, and Continued Fraction Descent Encoding for Primitive Pythagorean Triples


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Algebra
Research mode: prove
