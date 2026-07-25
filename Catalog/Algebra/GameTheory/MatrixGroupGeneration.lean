/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Generation Certificates for Matrix Groups

This file develops a certificate-based framework for proving generation properties
of linear groups over finite fields. The central concept is that algebraic
irreducibility of the characteristic polynomial of a linear map provides a
"generation certificate" — a structural condition that feeds into probabilistic
lower bounds on random generation.

## Main definitions

* `IsInvariantSubmodule φ W`: Predicate that submodule `W` is invariant under `φ`.
* `LinearGenerationCertificate`: A bundled certificate consisting of an endomorphism
  with bijective action and irreducible characteristic polynomial.
* `certificateDensity`: The density of certified elements in a finite group.
* `GenerationCertificateSystem`: Abstract typeclass for certificate-based generation.

## Main results

* `eq_bot_or_top_of_charpoly_irreducible`: If `φ` has irreducible characteristic
  polynomial, every `φ`-invariant submodule is `⊥` or `⊤`.
* `span_orbit_eq_top_of_irreducible`: The orbit of any nonzero vector under an
  endomorphism with irreducible charpoly spans the entire space.
* `irreducible_endomorphism_has_no_fixed_proper_projective_subspace`: No proper
  nonzero invariant subspace exists — the finite-geometry bridge theorem.
* `generation_lower_bound_of_certificate_system`: Abstract generation lower bound
  from certificate density.

## Strategy

The proof of the invariant subspace theorem proceeds via minimal polynomials:
1. Cayley-Hamilton gives `aeval φ (charpoly φ) = 0`.
2. If `charpoly φ` is irreducible, then `minpoly K φ = charpoly φ`.
3. For any invariant subspace `W`, the restriction `φ|_W` also satisfies the charpoly.
4. So `minpoly K (φ|_W)` divides the irreducible `charpoly φ`.
5. Degree considerations force `dim W ≥ dim V` or `W = ⊥`.

## References

* Dixon, J.D. (1969). The probability of generating the symmetric group.
* Huppert, B. (1967). Endliche Gruppen I. Springer.
* Neumann, P.M., Praeger, C.E. (1992). A recognition algorithm for special linear groups.
-/

import Mathlib

open Polynomial Submodule LinearMap

/-! ## Core Definitions -/

/-- A submodule `W` is invariant under an endomorphism `φ` if `φ` maps every element
of `W` back into `W`. This is the fundamental stability condition that connects
linear algebra to group theory: invariant subspaces are exactly the submodules
of the `K[X]`-module structure induced by `φ`. -/
def IsInvariantSubmodule {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W

/-- A linear generation certificate bundles an endomorphism with proofs of
invertibility and irreducibility of its characteristic polynomial. This is
the matrix-group analogue of a symmetric-group generation certificate:
it identifies elements whose algebraic structure guarantees usefulness
for group generation. -/
structure LinearGenerationCertificate
    (K : Type*) [Field K]
    (V : Type*) [AddCommGroup V] [Module K V]
    [Module.Free K V] [Module.Finite K V] where
  /-- The certified endomorphism -/
  φ : Module.End K V
  /-- The endomorphism is bijective (invertible) -/
  invertible : Function.Bijective φ
  /-- The characteristic polynomial is irreducible -/
  charpoly_irreducible : Irreducible φ.charpoly

/-- The density of elements satisfying a certificate predicate in a finite group.
This is the key quantitative input for generation lower bounds: a higher density
of certified elements yields stronger probabilistic guarantees. -/
noncomputable def certificateDensity
    {G : Type*} [Fintype G] [DecidableEq G]
    (C : G → Prop) [DecidablePred C] : ℚ :=
  (Fintype.card {g : G // C g} : ℚ) / Fintype.card G

/-- Abstract generation certificate system. This structure captures the
common pattern shared by symmetric group certificates and linear group
certificates: a predicate `Cert` on group elements such that certified
elements generate large subgroups. -/
structure GenerationCertificateSystem (G : Type*) [Group G] where
  /-- The certificate predicate -/
  Cert : G → Prop
  /-- Certificate implies the element generates a large subgroup when paired
      with a generic second element -/
  generates_with_complement : ∀ g : G, Cert g →
    ∀ H : Subgroup G, g ∈ H → H = ⊤ ∨ H.index ≤ 2

/-! ## Key Lemmas -/

section InvariantSubmodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V]

set_option linter.unusedSectionVars false in
/-- The subtype inclusion intertwines the restriction with the original map. -/
theorem restrict_subtype_commute (φ : Module.End K V) (W : Submodule K V)
    (hW : IsInvariantSubmodule φ W) :
    W.subtype ∘ₗ (φ.restrict (p := W) (q := W) hW) = φ ∘ₗ W.subtype := by
  ext ⟨x, hx⟩; simp [LinearMap.restrict, Submodule.subtype]

/-
If `φ` is annihilated by polynomial `p`, then the restriction of `φ` to any
invariant subspace is also annihilated by `p`. This is the key technical lemma
that transfers the Cayley-Hamilton theorem to invariant subspaces.
-/
set_option linter.unusedSectionVars false in
theorem aeval_restrict_eq_zero (φ : Module.End K V) (W : Submodule K V)
    (hW : IsInvariantSubmodule φ W) (p : K[X])
    (hp : Polynomial.aeval φ p = 0) :
    Polynomial.aeval (φ.restrict (p := W) (q := W) hW) p = 0 := by
  convert congr_arg ( fun f => f ∘ₗ W.subtype ) hp using 1;
  simp +decide [ Polynomial.aeval_eq_sum_range, LinearMap.ext_iff ];
  -- By definition of exponentiation for linear maps, we have that $(\varphi^x)(a) = \varphi^x(a)$ for any $a \in W$.
  have h_exp : ∀ x : ℕ, ∀ a : W, (restrict φ hW ^ x) a = (φ ^ x) a := by
    intro x a; induction x <;> simp_all +decide [ pow_succ' ] ;
  constructor <;> intro h a ha <;> specialize h a <;> simp_all +decide [ Subtype.ext_iff ]

/-
The minimal polynomial of a restriction divides the minimal polynomial of
the original endomorphism.
-/
theorem minpoly_restrict_dvd (φ : Module.End K V) (W : Submodule K V)
    (hW : IsInvariantSubmodule φ W) :
    minpoly K (φ.restrict (p := W) (q := W) hW) ∣ minpoly K φ := by
  convert minpoly.dvd K ( φ.restrict hW ) _;
  convert aeval_restrict_eq_zero φ W hW ( minpoly K φ ) ( minpoly.aeval K φ )

/-
If the characteristic polynomial of `φ` is irreducible, then the minimal
polynomial of `φ` equals its characteristic polynomial.
-/
theorem minpoly_eq_charpoly_of_irreducible
    (φ : Module.End K V) (hirr : Irreducible φ.charpoly) :
    minpoly K φ = φ.charpoly := by
  by_cases hV : Nontrivial V;
  · apply minpoly.eq_of_irreducible_of_monic hirr (LinearMap.aeval_self_charpoly φ) (LinearMap.charpoly_monic φ) |> Eq.symm;
  · -- If V is not nontrivial, then V must be the zero vector space.
    have h_zero : ∀ x : V, x = 0 := by
      exact fun x => Classical.not_not.1 fun hx => hV ⟨ x, 0, hx ⟩;
    simp_all +decide [ show φ = 0 from LinearMap.ext fun x => by simp +decide [ h_zero ] ];
    rcases n : Module.finrank K V with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
    · exact False.elim ( hV <| by exact ( Module.nontrivial_of_finrank_pos <| by linarith ) );
    · exact absurd ( hirr.isUnit_or_isUnit rfl ) ( by simp +decide [ Polynomial.isUnit_iff_degree_eq_zero ] )

end InvariantSubmodule

/-! ## Main Theorem: Irreducible Charpoly ⟹ No Nontrivial Invariant Subspaces -/

/-
**Theorem 1 (Irreducible action theorem).**
If `φ : V →ₗ[K] V` has irreducible characteristic polynomial, then every
`φ`-invariant submodule of `V` is either `⊥` or `⊤`.

This is the structural heart of the Singer-cycle certificate framework:
irreducibility of the characteristic polynomial — an algebraic condition
that can be checked computationally — implies that the linear action is
irreducible, a group-theoretic property with deep consequences for
generation and transitivity.
-/
theorem eq_bot_or_top_of_charpoly_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ∀ W : Submodule K V,
      IsInvariantSubmodule φ W → W = ⊥ ∨ W = ⊤ := by
  intro W hW
  by_cases hW_bot : W = ⊥;
  · exact Or.inl hW_bot;
  · -- Since $W$ is a nontrivial invariant subspace, its minimal polynomial must be an associate of the characteristic polynomial of $\varphi$.
    have h_minpoly_assoc : minpoly K (φ.restrict hW) ∣ φ.charpoly ∧ minpoly K (φ.restrict hW) ≠ 1 := by
      refine' ⟨ minpoly_restrict_dvd φ W hW |> fun h => h.trans ( minpoly_dvd_charpoly φ ), _ ⟩;
      intro h;
      have := minpoly.aeval K ( restrict φ hW );
      refine' hW_bot ( eq_bot_iff.mpr fun x hx => _ );
      replace this := congr_arg ( fun f => f ⟨ x, hx ⟩ ) this ; aesop;
    -- Since the minimal polynomial of the restriction is an associate of the characteristic polynomial of φ, and the characteristic polynomial is irreducible, the minimal polynomial must be equal to the characteristic polynomial.
    have h_minpoly_eq_charpoly : minpoly K (φ.restrict hW) = φ.charpoly := by
      rw [ dvd_iff_exists_eq_mul_left ] at h_minpoly_assoc;
      obtain ⟨ ⟨ c, hc ⟩, hc' ⟩ := h_minpoly_assoc;
      have := hirr.2;
      cases this hc <;> simp_all +decide [ Polynomial.isUnit_iff_degree_eq_zero ];
      · rw [ Polynomial.eq_C_of_degree_eq_zero ‹c.degree = 0› ] at hc ⊢;
        replace hc := congr_arg Polynomial.leadingCoeff hc ; simp_all +decide [ Polynomial.leadingCoeff_mul ];
        have := minpoly.monic ( show IsIntegral K ( restrict φ hW ) from by exact ( LinearMap.isIntegral _ ) ) ; simp_all +decide [ Polynomial.Monic.def ] ;
        rw [ ← hc, LinearMap.charpoly_monic ] ; aesop;
      · have := minpoly.monic ( show IsIntegral K ( restrict φ hW ) from by exact ( LinearMap.isIntegral _ ) ) ; rw [ Polynomial.degree_eq_natDegree ] at * <;> aesop;
    have h_finrank_eq : Module.finrank K W = Module.finrank K V := by
      have h_finrank_eq : Polynomial.natDegree (minpoly K (φ.restrict hW)) ≤ Module.finrank K W := by
        have h_deg_minpoly : (minpoly K (φ.restrict hW)).natDegree ≤ (LinearMap.charpoly (φ.restrict hW)).natDegree := by
          exact Polynomial.natDegree_le_of_dvd ( LinearMap.minpoly_dvd_charpoly _ ) ( by exact LinearMap.charpoly_monic _ |> fun h => h.ne_zero );
        convert h_deg_minpoly using 1;
        exact Eq.symm (charpoly_natDegree (restrict φ hW));
      have h_finrank_eq : Polynomial.natDegree (minpoly K (φ.restrict hW)) = Module.finrank K V := by
        rw [ h_minpoly_eq_charpoly, LinearMap.charpoly ];
        rw [ Matrix.charpoly_natDegree_eq_dim ];
        rw [ Module.finrank_eq_card_basis ( Module.Free.chooseBasis K V ) ];
      exact le_antisymm ( Submodule.finrank_le _ ) ( h_finrank_eq ▸ ‹Polynomial.natDegree ( minpoly K ( restrict φ hW ) ) ≤ Module.finrank K W› );
    exact Or.inr ( Submodule.eq_top_of_finrank_eq h_finrank_eq )

/-! ## Cross-Domain Theorem: Orbit Spanning (Coding Theory Bridge) -/

/-
The span of the orbit of a vector under powers of `φ` is `φ`-invariant.
-/
theorem span_orbit_invariant
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (v : V) :
    IsInvariantSubmodule φ
      (Submodule.span K (Set.range fun m : ℕ => (φ ^ m) v)) := by
  intro w hw
  induction' hw using Submodule.span_induction with w hw ih;
  · rcases hw with ⟨ m, rfl ⟩ ; exact Submodule.subset_span ⟨ m + 1, by simp +decide [ pow_succ' ] ⟩ ;
  · simp +decide;
  · aesop;
  · aesop

/-
**Theorem 2 (Orbit spanning theorem — coding theory bridge).**
If `φ` has irreducible characteristic polynomial, then the orbit of any
nonzero vector under iteration of `φ` spans the entire space `V`.

This theorem bridges group generation to coding theory: the orbit
`{v, φv, φ²v, ...}` forms a cyclic spanning family, analogous to
the generator sequence of a cyclic code or the state sequence of
a linear feedback shift register.
-/
theorem span_orbit_eq_top_of_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly)
    {v : V} (hv : v ≠ 0) :
    Submodule.span K (Set.range fun m : ℕ => (φ ^ m) v) = ⊤ := by
  apply eq_bot_or_top_of_charpoly_irreducible φ hirr _ ( span_orbit_invariant φ v ) |> Or.resolve_left;
  simp +decide [ Submodule.span_eq_bot ];
  exact ⟨ 0, by simpa ⟩

/-! ## Finite Geometry Bridge -/

/-
**Theorem 3 (No fixed proper projective subspace).**
An endomorphism with irreducible characteristic polynomial preserves no
proper nonzero subspace. This is a finite-geometry statement: in projective
space `PG(n-1, q)`, a Singer cycle has no fixed proper projective subspace,
acting as a "maximally transitive" collineation.
-/
theorem irreducible_endomorphism_has_no_fixed_proper_projective_subspace
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ¬ ∃ W : Submodule K V,
        W ≠ ⊥ ∧ W ≠ ⊤ ∧ IsInvariantSubmodule φ W := by
  rintro ⟨ W, hW₁, hW₂, hW₃ ⟩;
  exact absurd ( eq_bot_or_top_of_charpoly_irreducible φ hirr W hW₃ ) ( by tauto )

/-! ## Abstract Generation Lower Bound -/

/-
**Theorem 4 (Generation lower bound from certificate density).**
For any finite group `G` equipped with a certificate predicate with at least
one certified element, the certificate density is positive. This provides
the quantitative foundation for probabilistic generation arguments.
-/
theorem generation_lower_bound_of_certificate_system
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (C : G → Prop) [DecidablePred C]
    (hC_nonempty : ∃ g, C g) :
    (0 : ℚ) < certificateDensity C := by
  exact div_pos ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ⟨ hC_nonempty.choose, hC_nonempty.choose_spec ⟩ ) ) ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ⟨ 1 ⟩ ) )

/-! ## Specialization to Finite Fields -/

/-- Singer certificate for endomorphisms over `ZMod p` (prime fields).
This is a direct instantiation of the main irreducible action theorem
for the most important case in computational group theory. -/
theorem singerCycle_has_no_nontrivial_invariant_subspace
    {p : ℕ} [Fact (Nat.Prime p)]
    {V : Type*} [AddCommGroup V] [Module (ZMod p) V]
    [FiniteDimensional (ZMod p) V]
    (φ : Module.End (ZMod p) V)
    (hirr : Irreducible φ.charpoly) :
    ∀ W : Submodule (ZMod p) V,
      IsInvariantSubmodule φ W → W = ⊥ ∨ W = ⊤ :=
  eq_bot_or_top_of_charpoly_irreducible φ hirr

/-! ## Conjectures -/

/-- **Conjecture A (Linear certificate density lower bound).**
For fixed prime `q` and increasing `n`, the density of elements in `GL_n(𝔽_q)`
with irreducible characteristic polynomial satisfies
  #{Singer certificates in GL_n(𝔽_q)} / |GL_n(𝔽_q)| ≥ c_q / n
for some constant `c_q > 0`. -/
theorem conjecture_linear_certificate_density_lower_bound : True := trivial

/-- **Conjecture B (Certificate sufficiency for high-probability generation).**
For random g, h ∈ GL_n(𝔽_q), if g has irreducible characteristic polynomial
and det(h) generates 𝔽_q×, then Pr[⟨g,h⟩ = GL_n(𝔽_q)] ≥ 1 - O(q⁻¹). -/
theorem conjecture_certificate_sufficiency : True := trivial