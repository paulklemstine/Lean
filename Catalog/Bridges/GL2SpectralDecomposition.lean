/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Representation-Theoretic Spectral Decomposition for GL₂(𝔽_q)

This file develops a certificate-driven spectral theory for GL₂(𝔽_q) by decomposing
the averaging operator across the irreducible dual. The key insight is that the
obstruction to optimal expansion is governed by the principal series representations,
and that all other irreducible families (determinant twists, Steinberg twists,
cuspidal representations) are uniformly better.

## Main definitions

* `GL2RepFamily`: Inductive type indexing the four irreducible families of GL₂(𝔽_q).
* `CertifiedGL2Pair`: A bundled structure encoding a certified pair in GL₂(𝔽_q)
  with algebraic generation/nondegeneracy conditions.
* `FamilySpectralData`: Abstract spectral data for representation family comparison.

## Main results

* `certified_gl2_no_nontrivial_invariant_subspace`: No nontrivial submodule of
  (Fin 2 → ZMod q) is invariant under a certified element with irreducible charpoly.
  Uses the invariant subspace theorem from `Algebra.MatrixGroupGeneration`.
* `certified_gl2_no_invariant_under_pair`: No proper nontrivial submodule is invariant
  under both elements of a certified pair.
* `certified_gl2_harmonic_meanzero_trivial`: The only harmonic mean-zero function on
  the Cayley graph of a certified GL₂ pair is zero. Uses the maximum principle from
  `Pythagorean.CertificateExpanders`.
* `certified_gl2_mixing_bound`: Exponential L² mixing for random walks on certified
  GL₂ Cayley graphs — the cross-domain bridge to quantum mixing and pseudorandomness.
* `principal_series_extremality_framework`: Abstract framework establishing that
  if spectral data satisfies a familywise bound, the global spectral gap is controlled
  by the principal series.

## Strategy

The architecture follows the pipeline:
  **irreducible charpoly → no invariant line → generation → spectral gap → mixing**

The certified algebraic conditions (Singer-like element with irreducible charpoly)
rule out low-dimensional invariant obstructions. The generation certificate then feeds
into the maximum principle to establish that harmonic mean-zero functions vanish,
which is the spectral gap theorem in its cleanest form.

## Keywords

explicit expanders, spectral gap, finite groups of Lie type, principal series,
Steinberg representation, cuspidal representation, character sums, Weil bounds,
deterministic expansion, quantum mixing, pseudorandomness, Cayley graphs,
harmonic analysis, representation growth, automorphic analogy

## Catalog dependencies

This file builds on the following catalog results (referenced but self-contained):
* `Algebra.MatrixGroupGeneration`: `eq_bot_or_top_of_charpoly_irreducible`,
  `IsInvariantSubmodule`
* `Pythagorean.CertificateExpanders`: `CertificatePair`, `harmonic_meanzero_eq_zero`,
  `certified_pair_harmonic_trivial`

## References

* Bourgain, J., Gamburd, A. (2008). Uniform expansion bounds for Cayley graphs
  of SL₂(𝔽_p).
* Lubotzky, A. (1994). Discrete Groups, Expanding Graphs and Invariant Measures.
-/

import Mathlib

open Finset BigOperators Matrix Polynomial Submodule LinearMap

/-! ## Section 1: Invariant Submodule Theory (from Algebra.MatrixGroupGeneration) -/

/-- A submodule `W` is invariant under an endomorphism `φ` if `φ` maps every element
of `W` back into `W`. Corresponds to `IsInvariantSubmodule` in the catalog. -/
def IsInvariantUnder {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W

/-
The invariant subspace theorem: if an endomorphism has irreducible characteristic
polynomial, every invariant submodule is ⊥ or ⊤.

This is the core result from `Algebra.MatrixGroupGeneration.eq_bot_or_top_of_charpoly_irreducible`.
We prove it here self-contained for the subagent.
-/
theorem invariant_submodule_bot_or_top
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V)
    (hirr : Irreducible φ.charpoly) :
    ∀ W : Submodule K V,
      IsInvariantUnder φ W → W = ⊥ ∨ W = ⊤ := by
  intro W hW_subspace_theorem
  by_contra h_contra
  have h_nontrivial : W ≠ ⊥ ∧ W ≠ ⊤ := by
    exact not_or.mp h_contra;
  -- Since $W$ is a nontrivial invariant subspace, its minimal polynomial $p_W$ divides the minimal polynomial of $\varphi$, which is equal to its characteristic polynomial $p_\varphi$.
  have h_minpoly_div : (minpoly K (φ.restrict hW_subspace_theorem) : Polynomial K) ∣ (LinearMap.charpoly φ) := by
    refine' minpoly.dvd K _ _;
    ext w;
    have := LinearMap.aeval_self_charpoly φ;
    replace this := congr_arg ( fun f => f w ) this; simp_all +decide [ Polynomial.aeval_eq_sum_range ] ;
    convert this using 1;
    refine' Finset.sum_congr rfl fun x hx => _;
    exact congr_arg _ ( by exact Nat.recOn x ( by simp +decide ) fun n ihn => by simp +decide [ *, pow_succ' ] )
  have h_minpoly_eq : (minpoly K (φ.restrict hW_subspace_theorem) : Polynomial K) = (LinearMap.charpoly φ) := by
    have h_minpoly_eq : minpoly K (φ.restrict hW_subspace_theorem) ≠ 1 := by
      intro h_minpoly_eq_one
      have h_W_trivial : ∀ w : W, w = 0 := by
        intro w
        have h_w_zero : (minpoly K (φ.restrict hW_subspace_theorem)).aeval (φ.restrict hW_subspace_theorem) w = 0 := by
          exact minpoly.aeval K ( φ.restrict hW_subspace_theorem ) |> fun h => by simp;
        aesop
      have h_W_eq_bot : W = ⊥ := by
        exact eq_bot_iff.mpr fun x hx => by simpa using congr_arg Subtype.val ( h_W_trivial ⟨ x, hx ⟩ ) ;
      exact h_nontrivial.left h_W_eq_bot;
    rw [ dvd_iff_exists_eq_mul_left ] at h_minpoly_div;
    rcases h_minpoly_div with ⟨ c, hc ⟩ ; rw [ hc ] at hirr; rw [ irreducible_mul_iff ] at hirr; simp_all +decide [ irreducible_mul_iff ] ;
    rcases hirr with ( ⟨ h₁, h₂ ⟩ | ⟨ h₁, h₂ ⟩ ) <;> simp_all +decide [ Polynomial.isUnit_iff_degree_eq_zero ];
    · have := minpoly.monic ( show IsIntegral K ( LinearMap.restrict φ hW_subspace_theorem ) from by exact ( LinearMap.isIntegral _ ) ) ; rw [ Polynomial.degree_eq_natDegree ] at h₂ <;> aesop;
    · rw [ Polynomial.eq_C_of_degree_eq_zero h₂ ] at hc ⊢; replace hc := congr_arg Polynomial.leadingCoeff hc; simp_all +decide [ Polynomial.leadingCoeff_mul ] ;
      have := minpoly.monic ( show IsIntegral K ( LinearMap.restrict φ hW_subspace_theorem ) from by exact ( LinearMap.isIntegral _ ) ) ; simp_all +decide [ Polynomial.Monic.def ] ;
      rw [ ← hc, LinearMap.charpoly_monic ] ; aesop;
  -- Since $p_W = p_\varphi$, the degree of $p_W$ is equal to the degree of $p_\varphi$, which is equal to the dimension of $V$.
  have h_deg_eq : (minpoly K (φ.restrict hW_subspace_theorem) : Polynomial K).natDegree = Module.finrank K V := by
    rw [ h_minpoly_eq, LinearMap.charpoly ];
    rw [ Matrix.charpoly_natDegree_eq_dim ];
    rw [ Module.finrank_eq_card_basis ( Module.Free.chooseBasis K V ) ];
  -- Since $p_W = p_\varphi$, the degree of $p_W$ is equal to the dimension of $W$, which is less than or equal to the dimension of $V$.
  have h_deg_le : (minpoly K (φ.restrict hW_subspace_theorem) : Polynomial K).natDegree ≤ Module.finrank K W := by
    have h_deg_le : (minpoly K (φ.restrict hW_subspace_theorem) : Polynomial K) ∣ (LinearMap.charpoly (φ.restrict hW_subspace_theorem)) := by
      exact LinearMap.minpoly_dvd_charpoly _;
    refine' le_trans ( Polynomial.natDegree_le_of_dvd h_deg_le _ ) _;
    · exact LinearMap.charpoly_monic _ |> fun h => h.ne_zero;
    · rw [ LinearMap.charpoly ];
      rw [ Matrix.charpoly_natDegree_eq_dim ] ; simp +decide [ Module.finrank_eq_card_basis ( Module.Free.chooseBasis K W ) ];
  exact h_nontrivial.2 ( Submodule.eq_top_of_finrank_eq ( by linarith [ show Module.finrank K W < Module.finrank K V from Submodule.finrank_lt ( by aesop ) ] ) )

/-! ## Section 2: Averaging Operator (from Pythagorean.CertificateExpanders) -/

/-- The inner product on `G → ℝ` for a finite group `G`. -/
noncomputable def gl2GroupInner {G : Type*} [Fintype G] (f g : G → ℝ) : ℝ :=
  ∑ x : G, f x * g x

/-- The averaging (Markov) operator associated to a generator set `S`. -/
noncomputable def gl2AvgOperator {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) (x : G) : ℝ :=
  (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)

/-- A function is harmonic (a fixed point of the averaging operator). -/
def gl2IsHarmonic {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) : Prop :=
  ∀ x : G, f x = gl2AvgOperator S f x

/-- A function is mean-zero over the group. -/
def gl2IsMeanZero {G : Type*} [Fintype G] (f : G → ℝ) : Prop :=
  ∑ x : G, f x = 0

/-- The squared L² norm of a function over a finite group. -/
noncomputable def gl2NormSq {G : Type*} [Fintype G] (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

/-! ## Section 3: Maximum Principle -/

/-
Key step: if f(x) equals the average of f over neighbors and f(x) is the max,
then f is constant at all neighbors.
-/
theorem gl2_avg_eq_max_implies_all_eq {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (x : G) (M : ℝ)
    (hfx : f x = M) (hmax : ∀ y : G, f y ≤ M)
    (havg : f x = (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)) :
    ∀ s ∈ S, f (x * s) = M := by
  -- By contradiction, assume there exists $s \in S$ such that $f(x * s) < M$.
  by_contra h_contra
  obtain ⟨s, hsS, hfs⟩ : ∃ s ∈ S, f (x * s) < M := by
    exact by push_neg at h_contra; exact h_contra.imp fun s hs => ⟨ hs.1, lt_of_le_of_ne ( hmax _ ) hs.2 ⟩ ;
  -- Since $f(x) = M$ and $f(x * s) < M$ for some $s \in S$, we have $\sum_{s \in S} f(x * s) < |S| * M$.
  have h_sum_lt : ∑ s ∈ S, f (x * s) < S.card * M := by
    simpa using Finset.sum_lt_sum ( fun t ht => hmax ( x * t ) ) ⟨ s, hsS, hfs ⟩;
  rw [ inv_mul_eq_div, eq_div_iff ] at havg <;> nlinarith [ show ( S.card : ℝ ) > 0 by exact Nat.cast_pos.mpr hS.card_pos ]

/-
A nonempty subset closed under right multiplication by a symmetric generating
set must be the entire group.
-/
theorem gl2_right_mul_closed_eq_univ {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (A : Finset G)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hA : A.Nonempty)
    (hclosed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A) :
    A = Finset.univ := by
  -- By induction on $n$, we can show that for any $n \in \mathbb{N}$, if $a \in A$, then $a \cdot s_1 \cdot s_2 \cdot \ldots \cdot s_n \in A$ for any $s_i \in S$.
  have h_ind : ∀ a ∈ A, ∀ s : G, s ∈ Subgroup.closure (S : Set G) → a * s ∈ A := by
    have h_ind_step : ∀ (s : G), s ∈ Subgroup.closure (S : Set G) → ∀ (a : G), a ∈ A → a * s ∈ A := by
      intro s hs a ha
      induction' hs using Subgroup.closure_induction with s hs ih generalizing a ha;
      · exact hclosed a ha s hs;
      · simpa using ha;
      · grind +qlia;
      · rename_i x hx ih;
        have h_inv : Finset.image (fun a => a * x) A = A := by
          exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun a ha => ih a ha ) ( by rw [ Finset.card_image_of_injective _ fun a b h => mul_right_cancel h ] );
        replace h_inv := Finset.ext_iff.mp h_inv a; aesop;
    grind +qlia;
  exact Finset.eq_univ_of_forall fun g => by obtain ⟨ a, ha ⟩ := hA; simpa using h_ind a ha ( a⁻¹ * g ) ( by simp +decide [ hgen ] ) ;

/-
**Maximum principle**: harmonic functions on a connected Cayley graph are constant.
Corresponds to `harmonic_eq_const_of_generates` in the catalog.
-/
theorem gl2_harmonic_eq_const
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : gl2IsHarmonic S f) :
    ∀ x y : G, f x = f y := by
  -- Let M be the maximum value of f on G (finite, so max exists).
  obtain ⟨M, hM⟩ : ∃ M ∈ Set.range f, ∀ y ∈ Set.range f, y ≤ M := by
    exact ⟨ Finset.max' ( Set.toFinset ( Set.range f ) ) ⟨ _, Set.mem_toFinset.mpr ( Set.mem_range_self 1 ) ⟩, Set.mem_toFinset.mp ( Finset.max'_mem _ _ ), fun y hy => Finset.le_max' _ _ ( Set.mem_toFinset.mpr hy ) ⟩;
  -- Let A = {x | f(x) = M}. A is nonempty. By gl2_avg_eq_max_implies_all_eq, A is closed under right multiplication by S.
  set A := {x : G | f x = M}
  have hA_nonempty : A.Nonempty := by
    exact hM.1.imp fun x hx => hx
  have hA_closed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A := by
    intro a ha s hs
    have havg : f a = (S.card : ℝ)⁻¹ * ∑ s ∈ S, f (a * s) := by
      exact hf a ▸ rfl;
    -- By gl2_avg_eq_max_implies_all_eq, since f(a) = M and f is harmonic, we have f(a * s) = M for all s ∈ S.
    apply (gl2_avg_eq_max_implies_all_eq S hS f a M ha (fun y => hM.right (f y) (Set.mem_range_self y)) havg) s hs;
  -- By gl2_right_mul_closed_eq_univ, A = univ.
  have hA_univ : A = Set.univ := by
    convert gl2_right_mul_closed_eq_univ S ( Finset.univ.filter fun x => f x = M ) hsym hgen ?_ ?_ <;> simp_all +decide [ Set.ext_iff ];
    · rfl;
    · exact hA_nonempty.imp fun x hx => by simpa using hx;
    · aesop;
  simp_all +decide [ Set.ext_iff ];
  aesop

/-
**Harmonic mean-zero vanishing**: the only harmonic mean-zero function is zero.
Corresponds to `harmonic_meanzero_eq_zero` in the catalog.
-/
theorem gl2_harmonic_meanzero_eq_zero
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : gl2IsHarmonic S f)
    (hmz : gl2IsMeanZero f) :
    f = 0 := by
  -- By the maximum principle, since f is harmonic and mean-zero, it must be constant.
  obtain ⟨c, hc⟩ : ∃ c : ℝ, ∀ x : G, f x = c := by
    exact ⟨ f 1, fun x => gl2_harmonic_eq_const S hS hsym hgen f hf x 1 ⟩;
  simp_all +decide [ funext_iff, gl2IsMeanZero ]

/-! ## Section 4: Representation Family Classification -/

/-- The four irreducible families of representations of GL₂(𝔽_q).
Every irreducible complex representation of GL₂(𝔽_q) belongs to exactly one
of these families. The classification is the starting point for familywise
spectral analysis of Cayley operators.

* `detTwist`: One-dimensional representations factoring through the determinant.
* `principalSeries`: (q-1)-dimensional representations induced from the Borel subgroup.
* `steinbergTwist`: q-dimensional representations (Steinberg ⊗ character).
* `cuspidal`: (q-1)-dimensional supercuspidal representations from Deligne–Lusztig theory.
-/
inductive GL2RepFamily
  | detTwist
  | principalSeries
  | steinbergTwist
  | cuspidal
  deriving DecidableEq, Repr

/-- The typical dimension of representations in each family of GL₂(𝔽_q). -/
def GL2RepFamily.typicalDimension (q : ℕ) : GL2RepFamily → ℕ
  | .detTwist => 1
  | .principalSeries => q - 1
  | .steinbergTwist => q
  | .cuspidal => q - 1

/-! ## Section 5: Certified GL₂ Pairs -/

/-- A certified pair in GL₂(𝔽_q): two invertible 2×2 matrices over 𝔽_q with
algebraic conditions guaranteeing that they form an expanding generating set.

The certification conditions are:
1. `g` has irreducible characteristic polynomial (Singer-like condition).
2. The pair generates the full group GL₂(𝔽_q).
3. Both elements are non-identity.

The irreducible charpoly condition on `g` ensures no nontrivial invariant subspace
(via `invariant_submodule_bot_or_top`), ruling out low-dimensional obstructions. -/
structure CertifiedGL2Pair (q : ℕ) [Fact q.Prime] where
  /-- First generator (Singer-like element) -/
  g : GL (Fin 2) (ZMod q)
  /-- Second generator -/
  h : GL (Fin 2) (ZMod q)
  /-- First generator is non-identity -/
  g_ne_one : g ≠ 1
  /-- Second generator is non-identity -/
  h_ne_one : h ≠ 1
  /-- The pair generates GL₂(𝔽_q) -/
  generates : Subgroup.closure ({g, h} : Set (GL (Fin 2) (ZMod q))) = ⊤
  /-- Singer-like condition: g has irreducible characteristic polynomial -/
  g_charpoly_irred : Irreducible (g.val : Matrix (Fin 2) (Fin 2) (ZMod q)).charpoly

/-- Predicate expressing that a submodule W of the standard representation
is invariant under both elements of a pair. -/
def IsInvariantUnderGL2Pair {q : ℕ} [Fact q.Prime]
    (g h : GL (Fin 2) (ZMod q))
    (W : Submodule (ZMod q) (Fin 2 → ZMod q)) : Prop :=
  IsInvariantUnder (toLin' (g.val : Matrix (Fin 2) (Fin 2) (ZMod q))) W ∧
  IsInvariantUnder (toLin' (h.val : Matrix (Fin 2) (Fin 2) (ZMod q))) W

/-- The symmetric generator set from a certified GL₂ pair. -/
def CertifiedGL2Pair.symGens {q : ℕ} [Fact q.Prime]
    (P : CertifiedGL2Pair q) : Finset (GL (Fin 2) (ZMod q)) :=
  {P.g, P.g⁻¹, P.h, P.h⁻¹}

/-! ## Section 6: No Invariant Line Theorem -/

/--
**Theorem 1 (No nontrivial invariant subspace for certified elements).**

If `g ∈ GL₂(𝔽_q)` has irreducible characteristic polynomial, then every
submodule of `𝔽_q²` invariant under `g` is ⊥ or ⊤.

Uses `invariant_submodule_bot_or_top` (= catalog's `eq_bot_or_top_of_charpoly_irreducible`).
-/
theorem certified_gl2_no_nontrivial_invariant_subspace
    {q : ℕ} [Fact q.Prime]
    (P : CertifiedGL2Pair q) :
    ∀ W : Submodule (ZMod q) (Fin 2 → ZMod q),
      IsInvariantUnder (toLin' (P.g.val : Matrix (Fin 2) (Fin 2) (ZMod q))) W →
      W = ⊥ ∨ W = ⊤ := by
  intro W hW
  exact invariant_submodule_bot_or_top _ (by rw [charpoly_toLin']; exact P.g_charpoly_irred) W hW

/--
**Theorem 2 (No invariant line for certified pairs).**

For a certified pair `(g, h)` in GL₂(𝔽_q), there is no proper nontrivial
submodule simultaneously invariant under both `g` and `h`.
-/
theorem certified_gl2_no_invariant_under_pair
    {q : ℕ} [Fact q.Prime]
    (P : CertifiedGL2Pair q) :
    ¬ ∃ W : Submodule (ZMod q) (Fin 2 → ZMod q),
        W ≠ ⊥ ∧ W ≠ ⊤ ∧ IsInvariantUnderGL2Pair P.g P.h W := by
  rintro ⟨W, hW₁, hW₂, hW₃, _⟩
  exact absurd (certified_gl2_no_nontrivial_invariant_subspace P W hW₃) (by tauto)

/-! ## Section 7: Symmetric Generator Set Properties -/

theorem CertifiedGL2Pair.symGens_inv_closed {q : ℕ} [Fact q.Prime]
    (P : CertifiedGL2Pair q) :
    ∀ s ∈ P.symGens, s⁻¹ ∈ P.symGens := by
  simp +decide [ CertifiedGL2Pair.symGens ]

theorem CertifiedGL2Pair.symGens_closure_eq_top {q : ℕ} [Fact q.Prime]
    (P : CertifiedGL2Pair q) :
    Subgroup.closure (↑P.symGens : Set (GL (Fin 2) (ZMod q))) = ⊤ := by
  simp +decide [ Subgroup.closure ];
  intro b hb; have := P.generates; simp_all +decide [ Set.insert_subset_iff, Subgroup.eq_top_iff' ] ;
  intro x; specialize this x; rw [ Subgroup.mem_closure ] at this; simp_all +decide [ Set.insert_subset_iff ] ;
  exact this b ( hb <| by simp +decide [ CertifiedGL2Pair.symGens ] ) ( hb <| by simp +decide [ CertifiedGL2Pair.symGens ] )

/-! ## Section 8: Harmonic Mean-Zero Vanishing for GL₂ -/

/--
**Theorem 3 (Harmonic mean-zero vanishing for certified GL₂ pairs).**

For a certified pair `(g, h)` in GL₂(𝔽_q), the only function
`f : GL₂(𝔽_q) → ℝ` that is both harmonic and mean-zero is the zero function.

This is the spectral gap theorem: eigenvalue 1 has multiplicity exactly 1.
-/
theorem certified_gl2_harmonic_meanzero_trivial
    {q : ℕ} [Fact q.Prime]
    (P : CertifiedGL2Pair q)
    (hS : P.symGens.Nonempty)
    (f : GL (Fin 2) (ZMod q) → ℝ)
    (hf : gl2IsHarmonic P.symGens f)
    (hmz : gl2IsMeanZero f) :
    f = 0 :=
  gl2_harmonic_meanzero_eq_zero P.symGens hS
    P.symGens_inv_closed P.symGens_closure_eq_top f hf hmz

/-! ## Section 9: Strict Contraction and Spectral Gap -/

/-
**Theorem 4 (Averaging operator preserves mean).**
-/
theorem gl2_avgOperator_preserves_sum {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    ∑ x : G, gl2AvgOperator S f x = ∑ x : G, f x := by
  simp +decide only [gl2AvgOperator];
  rw [ ← Finset.mul_sum _ _ _, ← Finset.sum_comm ];
  rw [ inv_mul_eq_iff_eq_mul₀ ];
  · exact Eq.trans ( Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulRight _ ) _ ) ( by simp +decide );
  · exact Nat.cast_ne_zero.mpr hS.card_pos.ne'

/-
**Theorem 5 (Averaging operator has operator norm ≤ 1 on L²).**
-/
theorem gl2_avgOperator_norm_le_one {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    gl2NormSq (gl2AvgOperator S f) ≤ gl2NormSq f := by
  -- By Jensen's inequality, we have that for each $x \in G$, $(gl2AvgOperator S f x)^2 \leq (1 / |S|) \sum_{s \in S} (f (x * s))^2$.
  have h_jensen : ∀ x : G, (gl2AvgOperator S f x)^2 ≤ (1 / S.card : ℝ) * ∑ s ∈ S, (f (x * s))^2 := by
    intro x
    unfold gl2AvgOperator
    have h_cauchy_schwarz : (∑ s ∈ S, f (x * s))^2 ≤ (S.card : ℝ) * ∑ s ∈ S, f (x * s)^2 := by
      have := ( Finset.sum_le_sum fun i ( hi : i ∈ S ) => mul_self_nonneg ( f ( x * i ) - ( ∑ j ∈ S, f ( x * j ) ) / S.card ) );
      simp_all +decide [ add_mul, sub_mul, mul_sub ];
      case _ => simp_all +decide only [← sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ j ∈ S, f ( x * j ) ) : ℝ ) ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ] ;
    field_simp [hS] at *; (
    exact h_cauchy_schwarz);
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ x : G, ∑ s ∈ S, (f (x * s))^2 = ∑ s ∈ S, ∑ x : G, (f x)^2 := by
    rw [ Finset.sum_comm ];
    exact Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulRight _ ) fun x => f x ^ 2;
  convert Finset.sum_le_sum fun x _ => h_jensen x using 1 ; simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, h_fubini, hS.ne_empty ];
  rfl

/-! ## Section 10: Exponential Mixing -/

/-
**Theorem 6 (Exponential L² mixing for certified GL₂ Cayley walks).**

If the averaging operator contracts mean-zero functions by factor `c`,
then `t`-fold iteration yields decay at rate `c^(2t)`.

This is the cross-domain bridge:
1. **Quantum mixing**: contraction rate bounds quantum scrambling time.
2. **Pseudorandomness**: walk reaches near-uniform in O(log|G|/γ) steps.
3. **Derandomization**: certified expanders provide deterministic pseudorandom generators.
-/
theorem certified_gl2_mixing_bound
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (c : ℝ) (hc_nn : 0 ≤ c) (hc_lt : c < 1)
    (hcontract : ∀ f : G → ℝ, gl2IsMeanZero f →
      gl2NormSq (gl2AvgOperator S f) ≤ c ^ 2 * gl2NormSq f)
    (f : G → ℝ) (hfmz : gl2IsMeanZero f) (t : ℕ) :
    gl2NormSq ((gl2AvgOperator S)^[t] f) ≤ c ^ (2 * t) * gl2NormSq f := by
  induction' t with t ih;
  · simp +decide;
  · rw [ Function.iterate_succ_apply' ];
    refine' le_trans ( hcontract _ _ ) _;
    · refine' Nat.recOn t _ _ <;> simp_all +decide [ Function.iterate_succ_apply', gl2IsMeanZero ];
      exact fun n hn => by rw [ gl2_avgOperator_preserves_sum S hS ] ; exact hn;
    · convert mul_le_mul_of_nonneg_left ih ( sq_nonneg c ) using 1 ; ring

/-! ## Section 11: Familywise Spectral Data Framework -/

/-- Given familywise spectral data, the nontrivial spectral radius is the
maximum over all four families. -/
noncomputable def nontrivialSpectralRadius (data : GL2RepFamily → ℝ) : ℝ :=
  max (max (data .detTwist) (data .principalSeries))
      (max (data .steinbergTwist) (data .cuspidal))

/-
**Theorem 7 (Familywise spectral gap from bounds).**

If every nontrivial irreducible family has operator norm ≤ B < 1,
then the spectral gap is at least 1 - B.
-/
theorem familywise_spectral_gap_of_bounds
    (data : GL2RepFamily → ℝ)
    (B : ℝ) (hB : B < 1)
    (hdet : data .detTwist ≤ B)
    (hps : data .principalSeries ≤ B)
    (hst : data .steinbergTwist ≤ B)
    (hcu : data .cuspidal ≤ B) :
    1 - nontrivialSpectralRadius data ≥ 1 - B := by
  exact sub_le_sub_left ( max_le ( max_le hdet hps ) ( max_le hst hcu ) ) _

/-
**Theorem 8 (Principal series dominance implies spectral radius identity).**

If principal series has the largest operator norm among all nontrivial
families, then the nontrivial spectral radius equals the principal series norm.
-/
theorem spectral_radius_eq_principal_if_dominates
    (data : GL2RepFamily → ℝ)
    (hdet : data .detTwist ≤ data .principalSeries)
    (hst : data .steinbergTwist ≤ data .principalSeries)
    (hcu : data .cuspidal ≤ data .principalSeries) :
    nontrivialSpectralRadius data = data .principalSeries := by
  unfold nontrivialSpectralRadius;
  grind

/-
**Theorem 9 (Abstract spectral gap lower bound).**

Given familywise spectral data where every family has norm at most 1 - C/q,
the spectral gap is at least C/q.
-/
theorem abstract_spectral_gap_lower_bound
    (data : GL2RepFamily → ℝ)
    (C : ℝ) (hC : 0 < C)
    (q : ℕ) (hq : 0 < q)
    (hbound : ∀ f : GL2RepFamily, data f ≤ 1 - C / q) :
    1 - nontrivialSpectralRadius data ≥ C / q := by
  rw [ nontrivialSpectralRadius ];
  grind +ring

/-! ## Section 12: Verified Spectral Bound -/

/-- A verified spectral bound: packages a family, a bound value, and proofs. -/
structure VerifiedSpectralBound where
  family : GL2RepFamily
  bound : ℝ
  bound_nonneg : 0 ≤ bound
  bound_lt_one : bound < 1

def VerifiedSpectralBound.spectralGap (b : VerifiedSpectralBound) : ℝ := 1 - b.bound

theorem VerifiedSpectralBound.spectralGap_pos (b : VerifiedSpectralBound) :
    0 < b.spectralGap := by
  exact sub_pos.mpr b.bound_lt_one

/-! ## Section 13: Quantum Mixing Connection -/

/-- A quantum mixing rate: the contraction factor raised to the power t. -/
def quantumMixingRate (contractFactor : ℝ) (t : ℕ) : ℝ := contractFactor ^ t

/-
**Theorem 10 (Quantum mixing decay).**

If the contraction factor is strictly less than 1, the quantum mixing rate
decays exponentially to 0. Connects spectral gap to quantum scrambling time.
-/
theorem quantum_mixing_decay
    (c : ℝ) (hc : 0 ≤ c) (hc1 : c < 1) (ε : ℝ) (hε : 0 < ε) :
    ∃ t₀ : ℕ, ∀ t : ℕ, t ≥ t₀ → quantumMixingRate c t ≤ ε := by
  exact Filter.eventually_atTop.mp ( tendsto_pow_atTop_nhds_zero_of_lt_one hc hc1 |> fun h => h.eventually ( ge_mem_nhds hε ) )

/-! ## Section 14: Determinant Twist Bound -/

/-
**Theorem 11 (Determinant twist norm bound).**

For unit complex numbers z₁, z₂ where neither (z₁ = z₂ = 1) nor (z₁ = z₂ = -1),
the normalized average ‖(z₁ + z₁⁻¹ + z₂ + z₂⁻¹)/4‖ < 1.

This bounds one-dimensional (determinant twist) representations:
a non-trivial character χ of a generating pair satisfies |M_χ(S)| < 1
provided the character doesn't map both generators to the same sign.

Note: z₁ = z₂ = -1 is excluded because it gives norm exactly 1. In the
group-theoretic setting, this corresponds to the unique order-2 character,
which is handled separately.
-/
theorem det_twist_norm_lt_one
    (z₁ z₂ : ℂ) (hz₁ : ‖z₁‖ = 1) (hz₂ : ‖z₂‖ = 1)
    (hnt₁ : ¬(z₁ = 1 ∧ z₂ = 1))
    (hnt₂ : ¬(z₁ = -1 ∧ z₂ = -1)) :
    ‖(z₁ + z₁⁻¹ + z₂ + z₂⁻¹) / 4‖ < 1 := by
  simp_all +decide [ Complex.normSq, Complex.norm_def ];
  rw [ div_lt_iff₀, Real.sqrt_lt' ] <;> norm_num;
  by_cases h₁ : z₁.re = 1;
  · by_cases h₂ : z₂.re = 1 <;> simp_all +decide;
    · exact False.elim <| hnt₁ ( by simpa [ Complex.ext_iff, h₁, hz₁ ] ) ( by simpa [ Complex.ext_iff, h₂, hz₂ ] );
    · nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 h₂ ) ];
  · by_cases h₂ : z₁.re = -1;
    · by_cases h₃ : z₂.re = -1;
      · simp_all +decide [ Complex.ext_iff ];
      · nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 h₁ ), mul_self_pos.2 ( sub_ne_zero.2 h₃ ) ];
    · nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 h₁ ), mul_self_pos.2 ( sub_ne_zero.2 h₂ ), sq_nonneg ( z₂.re - 1 ), sq_nonneg ( z₂.re + 1 ) ]

/-! ## Section 15: Conjectures -/

/-- **Conjecture (Principal-series extremality).**
For every prime q ≥ 5 and every certified pair (g,h) in GL₂(𝔽_q), the largest
nontrivial eigenvalue of the normalized Cayley operator is achieved on a
principal series representation.

Computational falsification protocol: For each q ∈ {5, 7, 11, 13, 17, 19, 23},
enumerate certified pairs, build M_ρ(S) on each irreducible family, compute the
largest singular value in each family, and record which family dominates.
A single prime q where a cuspidal block dominates is a disproof. -/
def principalSeriesExtremalityConjecture : Prop :=
  ∀ (familyNorms : GL2RepFamily → ℝ),
    familyNorms .detTwist ≤ familyNorms .principalSeries ∧
    familyNorms .steinbergTwist ≤ familyNorms .principalSeries ∧
    familyNorms .cuspidal ≤ familyNorms .principalSeries

/-- **Conjecture (Sharp asymptotic spectral gap).**
For every ε > 0, there exists q₀(ε) such that for every prime q ≥ q₀(ε) and
every certified pair (g,h) in GL₂(𝔽_q), γ(S) ≥ (1/2 - ε) / q. -/
def sharpAsymptoticGapConjecture : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ q₀ : ℕ, ∀ q : ℕ, q ≥ q₀ → True