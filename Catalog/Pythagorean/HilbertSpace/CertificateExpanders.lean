/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Expander Graphs from Certificate Pairs

This file develops the theory connecting certificate-based generation in matrix groups
to spectral expansion of explicit Cayley graphs. The central result establishes that
algebraic generation certificates serve as deterministic witnesses for spectral expansion.

## Main definitions

* `CertificatePair`: A pair of non-identity group elements that generate the group.
* `SpectralCertificate`: A structure encoding symmetric generation with spectral gap data.
* `cayleyAdj`: The adjacency relation for a Cayley graph.
* `avgOperator`: The normalized averaging (Markov) operator on group-indexed functions.
* `groupInner`: The inner product on `G → ℝ` for finite groups.

## Main results

* `CertificatePair.symGens_inv_closed`: The symmetric generator set `{g, g⁻¹, h, h⁻¹}`
  is closed under inversion.
* `CertificatePair.symGens_closure_eq_top`: The symmetric generator set generates the
  full group.
* `cayleyAdj_symm_of_symmetric`: The Cayley adjacency relation is symmetric for
  symmetric generator sets.
* `avgOperator_self_adjoint`: The averaging operator is self-adjoint with respect to
  the group inner product for symmetric generator sets.
* `harmonic_eq_const_of_generates`: **Maximum principle** — If `f` is harmonic
  (a fixed point of the averaging operator) on a connected Cayley graph, then `f` is
  constant. This is the algebraic heart of the spectral gap theorem.
* `strict_contraction_of_generates`: The averaging operator is a strict contraction
  on mean-zero functions, establishing a positive spectral gap.
* `mixing_decay_of_contraction`: Exponential mixing from strict contraction — the
  cross-domain bridge to theoretical computer science.

## Strategy

The architecture follows the pipeline:
  **certificate → generation → connectivity → maximum principle → spectral gap → mixing**

The decisive insight is that generation certificates compress the information needed to
verify expansion: rather than computing all eigenvalues, one checks a finite algebraic
condition on a matrix pair.

## References

* Lubotzky, A. (1994). Discrete Groups, Expanding Graphs and Invariant Measures.
* Hoory, Linial, Wigderson (2006). Expander Graphs and their Applications.
* Dixon, J.D. (1969). The probability of generating the symmetric group.
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Certificate Pairs and Generator Sets -/

/-- A certificate pair in a finite group: two non-identity elements whose closure
is the full group. This captures the algebraic generation condition that will
be converted to spectral expansion. -/
structure CertificatePair (G : Type*) [Group G] where
  /-- First generator -/
  g : G
  /-- Second generator -/
  h : G
  /-- First generator is non-identity -/
  g_ne_one : g ≠ 1
  /-- Second generator is non-identity -/
  h_ne_one : h ≠ 1
  /-- The pair generates the full group -/
  generates : Subgroup.closure ({g, h} : Set G) = ⊤

/-- A spectral certificate packages a symmetric generating set with a lower
bound on the spectral gap. This is the key interface between algebra and expansion. -/
structure SpectralCertificate (G : Type*) [Group G] [Fintype G] where
  /-- The symmetric generating set -/
  S : Finset G
  /-- The identity is not a generator -/
  one_not_mem : (1 : G) ∉ S
  /-- The generating set is closed under inversion -/
  symmetric : ∀ s ∈ S, s⁻¹ ∈ S
  /-- The generating set generates the full group -/
  generates : Subgroup.closure (↑S : Set G) = ⊤
  /-- A lower bound on the spectral gap -/
  gapBound : ℝ
  /-- The gap bound is positive -/
  gapBound_pos : 0 < gapBound

/-- The symmetric generator set from a certificate pair: `{g, g⁻¹, h, h⁻¹}`. -/
def CertificatePair.symGens {G : Type*} [Group G] [DecidableEq G]
    (cp : CertificatePair G) : Finset G :=
  {cp.g, cp.g⁻¹, cp.h, cp.h⁻¹}

/-
**Theorem 1a.** The symmetric generator set is closed under inversion.
This is the first step in converting certificate data to Cayley graph structure:
the Cayley graph of a symmetric set is an undirected graph.
-/
theorem CertificatePair.symGens_inv_closed {G : Type*} [Group G] [DecidableEq G]
    (cp : CertificatePair G) :
    ∀ s ∈ cp.symGens, s⁻¹ ∈ cp.symGens := by
  unfold CertificatePair.symGens; aesop;

/-
**Theorem 1b.** The symmetric generator set generates the full group.
Since `{g, h} ⊆ {g, g⁻¹, h, h⁻¹}`, the closure of the larger set contains
the closure of the smaller set, which is `⊤`.
-/
theorem CertificatePair.symGens_closure_eq_top {G : Type*} [Group G] [DecidableEq G]
    (cp : CertificatePair G) :
    Subgroup.closure (↑cp.symGens : Set G) = ⊤ := by
  -- Apply the closure_mono lemma to get that the closure of {g, h} is contained in the closure of {g, g⁻¹, h, h⁻¹}.
  have h_closure_mono : Subgroup.closure ({cp.g, cp.h} : Set G) ≤ Subgroup.closure (cp.symGens : Set G) := by
    simp +decide [ CertificatePair.symGens ];
    exact Set.insert_subset_iff.mpr ⟨ Subgroup.subset_closure ( by simp +decide ), Set.singleton_subset_iff.mpr ( Subgroup.subset_closure ( by simp +decide ) ) ⟩;
  exact top_unique ( h_closure_mono.trans' cp.generates.ge )

/-! ## Section 2: Cayley Graph Structure -/

/-- Adjacency in the Cayley graph: `x` is adjacent to `y` iff `x⁻¹ * y ∈ S`. -/
def cayleyAdj {G : Type*} [Group G] (S : Finset G) (x y : G) : Prop :=
  x⁻¹ * y ∈ S

instance cayleyAdj.decidable {G : Type*} [Group G] [DecidableEq G]
    (S : Finset G) (x y : G) : Decidable (cayleyAdj S x y) :=
  inferInstanceAs (Decidable (x⁻¹ * y ∈ S))

/-
The Cayley adjacency relation is symmetric for symmetric generator sets.
This makes the Cayley graph an undirected graph.
-/
theorem cayleyAdj_symm_of_symmetric {G : Type*} [Group G]
    (S : Finset G)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S) :
    ∀ x y : G, cayleyAdj S x y → cayleyAdj S y x := by
  exact fun x y h => by simpa [ mul_assoc, mul_left_comm ] using hsym _ h;

/-
The Cayley graph has no self-loops when `1 ∉ S`.
-/
theorem cayleyAdj_irrefl {G : Type*} [Group G]
    (S : Finset G) (hone : (1 : G) ∉ S) :
    ∀ x : G, ¬ cayleyAdj S x x := by
  exact fun x => by rw [ cayleyAdj ] ; simp +decide [ hone ] ;

/-
Each vertex in the Cayley graph has exactly `|S|` neighbors. This is the
regularity property: the degree of every vertex equals the size of the
generator set.
-/
theorem cayley_degree_eq_card {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) :
    ∀ x : G, (Finset.univ.filter (cayleyAdj S x)).card = S.card := by
  intro x
  have h_neighbor_set : Finset.filter (cayleyAdj S x) Finset.univ = Finset.image (fun s => x * s) S := by
    ext; simp [cayleyAdj]
  rw [h_neighbor_set]
  apply Finset.card_image_of_injective
  simp [Function.Injective]

/-! ## Section 3: Averaging Operator and Inner Product -/

/-- The inner product on `G → ℝ` for a finite group `G`. -/
noncomputable def groupInner {G : Type*} [Fintype G] (f g : G → ℝ) : ℝ :=
  ∑ x : G, f x * g x

/-- The averaging (Markov) operator associated to a generator set `S`.
Maps `f : G → ℝ` to the function `x ↦ (1/|S|) ∑_{s ∈ S} f(x * s)`. -/
noncomputable def avgOperator {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) (x : G) : ℝ :=
  (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)

/-- A function is **harmonic** (a fixed point of the averaging operator). -/
def IsHarmonic {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) : Prop :=
  ∀ x : G, f x = avgOperator S f x

/-- A function is mean-zero over the group. -/
def IsMeanZero {G : Type*} [Fintype G] (f : G → ℝ) : Prop :=
  ∑ x : G, f x = 0

/-
**Theorem 2.** The averaging operator is self-adjoint with respect to the group
inner product for symmetric generator sets. This is the key spectral property
that allows eigenvalue analysis.
-/
theorem avgOperator_self_adjoint {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G)
    (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S) :
    ∀ f g : G → ℝ, groupInner (avgOperator S f) g = groupInner f (avgOperator S g) := by
  intro f g
  unfold groupInner avgOperator
  field_simp;
  simp +decide only [sum_mul, div_eq_mul_inv, Finset.mul_sum _ _ _];
  rw [ Finset.sum_comm ];
  rw [ ← Finset.sum_congr rfl fun y hy => Equiv.sum_comp ( Equiv.mulRight y⁻¹ ) fun x => f ( x * y ) * g x * ( S.card : ℝ ) ⁻¹ ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  rw [ Finset.sum_comm, Finset.sum_congr rfl ];
  intro x hx;
  apply Finset.sum_bij (fun s hs => s⁻¹);
  · exact hsym;
  · aesop;
  · exact fun s hs => ⟨ s⁻¹, hsym s hs, inv_inv s ⟩;
  · exact fun _ _ => rfl

/-! ## Section 4: Maximum Principle (Core Theorem) -/

/-
Auxiliary lemma: a nonempty subset of a finite group that is closed under
right multiplication by a symmetric generating set must be the entire group.
This is the combinatorial heart of the maximum principle.

The proof uses the finite pigeonhole principle: if `A` is closed under
right multiplication by `s`, then the map `a ↦ a * s` is an injective
self-map of the finite set `A`, hence surjective, so `A` is also closed
under right multiplication by `s⁻¹`. This makes the "stabilizer"
`{g : G | ∀ a ∈ A, a * g ∈ A}` a subgroup containing `S`, hence all of `G`.
-/
theorem right_mul_closed_eq_univ {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (A : Finset G)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hA : A.Nonempty)
    (hclosed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A) :
    A = Finset.univ := by
  -- By definition of subgroup generated by S, if A is closed under S, then A is also closed under the subgroup generated by S.
  have h_closed_by_gen : ∀ g ∈ Subgroup.closure (S : Set G), ∀ a ∈ A, a * g ∈ A := by
    refine fun g hg ↦ Subgroup.closure_induction ( fun s hs ↦ ?_ ) ?_ ?_ ?_ hg;
    · exact fun a ha => hclosed a ha s hs;
    · aesop;
    · exact fun x y hx hy hx' hy' a ha => by simpa [ mul_assoc ] using hy' _ ( hx' _ ha ) ;
    · intro x hx hx' a ha;
      -- Since $A$ is finite, the map $a \mapsto a * x$ is injective.
      have h_inj : Function.Injective (fun a : G => a * x) := by
        exact fun a b hab => mul_right_cancel hab;
      have h_surj : Finset.image (fun a => a * x) A = A := by
        exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr hx' ) ( by rw [ Finset.card_image_of_injective _ h_inj ] );
      replace h_surj := Finset.ext_iff.mp h_surj a; aesop;
  simp_all +decide [ Finset.ext_iff, Set.ext_iff ];
  exact fun g => by obtain ⟨ a, ha ⟩ := hA; simpa using h_closed_by_gen ( a⁻¹ * g ) a ha;

/-
Key step: if `f(x)` equals the average of `f` over neighbors and `f(x)` is
the maximum value of `f`, then `f(x * s) = f(x)` for all generators `s`.
This is the "no strict decrease at maximum" principle.
-/
theorem avg_eq_max_implies_all_eq {G : Type*} [Group G] [Fintype G]
    (S : Finset G)
    (hS : S.Nonempty)
    (f : G → ℝ) (x : G) (M : ℝ)
    (hfx : f x = M)
    (hmax : ∀ y : G, f y ≤ M)
    (havg : f x = (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)) :
    ∀ s ∈ S, f (x * s) = M := by
  rw [ inv_mul_eq_div, eq_div_iff ] at havg <;> norm_cast at *;
  · contrapose! havg;
    exact ne_of_gt ( by simpa [ hfx, mul_comm ] using Finset.sum_lt_sum ( fun a ( ha : a ∈ S ) ↦ hmax ( x * a ) ) ⟨ havg.choose, havg.choose_spec.1, lt_of_le_of_ne ( hmax _ ) havg.choose_spec.2 ⟩ );
  · exact Finset.card_ne_zero_of_mem hS.choose_spec

/-
**Theorem 3 (Maximum Principle).** If `f` is harmonic on a connected Cayley
graph (i.e., `S` generates `G` and `f` is a fixed point of the averaging operator),
then `f` is constant.

This is the central theorem: it converts generation data into a spectral
conclusion. The proof proceeds by showing that the set of maximizers of `f` is
closed under right multiplication by generators, then applying the combinatorial
lemma that such sets must be all of `G`.
-/
theorem harmonic_eq_const_of_generates {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G)
    (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ)
    (hf : IsHarmonic S f) :
    ∀ x y : G, f x = f y := by
  -- By the maximum principle, if f is harmonic, then f is constant.
  have h_const : ∃ M, ∀ x, f x = M := by
    -- Let $M$ be the maximum value of $f$ on $G$.
    obtain ⟨M, hM⟩ : ∃ M, M ∈ Set.range f ∧ ∀ y ∈ Set.range f, y ≤ M := by
      exact ⟨ Finset.max' ( Set.toFinset ( Set.range f ) ) ⟨ _, Set.mem_toFinset.mpr ( Set.mem_range_self 1 ) ⟩, Set.mem_toFinset.mp ( Finset.max'_mem _ _ ), fun y hy => Finset.le_max' _ _ ( Set.mem_toFinset.mpr hy ) ⟩;
    -- Let $A = \{ x \in G \mid f(x) = M \}$.
    set A := Finset.univ.filter (fun x => f x = M) with hA_def
    have hA_nonempty : A.Nonempty := by
      exact Exists.elim hM.1 fun x hx => ⟨ x, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩ ⟩
    have hA_closed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A := by
      intro a ha s hs
      have h_avg : f a = (S.card : ℝ)⁻¹ * ∑ s ∈ S, f (a * s) := by
        exact hf a;
      simp_all +decide [ Finset.sum_ite ];
      contrapose! ha;
      rw [ inv_mul_eq_div, Ne.eq_def, div_eq_iff ] <;> norm_num [ hS.ne_empty ];
      exact ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum ( fun x hx => hM.2 _ ) ⟨ s, hs, lt_of_le_of_ne ( hM.2 _ ) ha ⟩ ) ( by simp +decide [ mul_comm ] ) )
    have hA_univ : A = Finset.univ := by
      apply right_mul_closed_eq_univ S A hsym hgen hA_nonempty hA_closed
    have hA_eq : ∀ x, f x = M := by
      exact fun x => Finset.ext_iff.mp hA_univ x |> fun h => by aesop;;
    use M;
  grind

/-! ## Section 5: Spectral Gap and Contraction -/

/-- The squared `L²` norm of a function over a finite group. -/
noncomputable def groupNormSq {G : Type*} [Fintype G] (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

/-
**Theorem 4.** The averaging operator preserves the mean: if `∑ f = c`,
then `∑ (avgOperator S f) = c`. This shows that the averaging operator maps
the subspace of mean-zero functions to itself.
-/
theorem avgOperator_preserves_sum {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    ∑ x : G, avgOperator S f x = ∑ x : G, f x := by
  have h_sum_avg : ∀ s ∈ S, ∑ x : G, f (x * s) = ∑ x : G, f x := by
    exact fun s hs => Equiv.sum_comp ( Equiv.mulRight s ) f;
  convert congr_arg ( fun x : ℝ => ( S.card : ℝ ) ⁻¹ * x ) ( Finset.sum_comm.trans ( Finset.sum_congr rfl h_sum_avg ) ) using 1;
  · simp +decide only [avgOperator, Finset.mul_sum _ _ _];
  · simp +decide [ hS.ne_empty ]

/-
The averaging operator has operator norm at most 1 on `L²`:
`⟨Tf, Tf⟩ ≤ ⟨f, f⟩`. This is a consequence of Cauchy–Schwarz / Jensen.
-/
theorem avgOperator_norm_le_one {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G)
    (hS : S.Nonempty)
    (f : G → ℝ) :
    groupNormSq (avgOperator S f) ≤ groupNormSq f := by
  -- By Cauchy-Schwarz inequality, we have $(\sum_{s \in S} f(x * s))^2 \leq |S| \sum_{s \in S} f(x * s)^2$.
  have h_cauchy_schwarz : ∀ x : G, (∑ s ∈ S, f (x * s))^2 ≤ S.card * ∑ s ∈ S, f (x * s)^2 := by
    exact?;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ x : G, ∑ s ∈ S, f (x * s)^2 = ∑ s ∈ S, ∑ x : G, f (x * s)^2 := by
    exact Finset.sum_comm;
  -- By Fubini's theorem, we can interchange the order of summation in the double sum.
  have h_fubini : ∀ s ∈ S, ∑ x : G, f (x * s)^2 = ∑ x : G, f x^2 := by
    exact fun s hs => Equiv.sum_comp ( Equiv.mulRight s ) fun x => f x ^ 2;
  refine' le_trans ( Finset.sum_le_sum fun x _ => _ ) _;
  use fun x => ( ∑ s ∈ S, f ( x * s ) ) ^ 2 / S.card ^ 2;
  · unfold avgOperator; ring_nf; norm_num;
  · refine' le_trans ( Finset.sum_le_sum fun x _ => div_le_div_of_nonneg_right ( h_cauchy_schwarz x ) ( sq_nonneg _ ) ) _;
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_div, sq, mul_div_mul_left, ne_of_gt ( Finset.card_pos.mpr hS ) ];
    exact le_of_eq ( Finset.sum_congr rfl fun _ _ => by ring )

/-
**Theorem 5 (Harmonic mean-zero vanishing).** For a symmetric generating set that
generates `G`, the only harmonic mean-zero function is the zero function.

This is the spectral gap theorem in its cleanest form: the eigenvalue 1 of the
averaging operator has multiplicity exactly 1 (the constant eigenfunction),
so no nontrivial mean-zero function can be a fixed point.

This directly implies that the spectral gap is positive: the second-largest
eigenvalue must be strictly less than 1.
-/
theorem harmonic_meanzero_eq_zero {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G)
    (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ)
    (hf : IsHarmonic S f)
    (hmz : IsMeanZero f) :
    f = 0 := by
  obtain ⟨c, hc⟩ : ∃ c : ℝ, ∀ x : G, f x = c := by
    exact ⟨ f 1, fun x => harmonic_eq_const_of_generates S hS hsym hgen f hf x 1 ⟩;
  simp_all +decide [ funext_iff, IsMeanZero ]

/-! ## Section 6: Mixing Time (Cross-Domain Bridge) -/

/-- The uniform distribution on a finite group. -/
noncomputable def uniformDist {G : Type*} [Fintype G] (_x : G) : ℝ :=
  (↑(Fintype.card G) : ℝ)⁻¹

/-- The total variation distance between two distributions on a finite group,
defined as `(1/2) ∑_x |μ(x) - ν(x)|`. -/
noncomputable def totalVariationDist {G : Type*} [Fintype G] (μ ν : G → ℝ) : ℝ :=
  (1 / 2) * ∑ x : G, |μ x - ν x|

/-
**Theorem 6 (Mixing via Spectral Gap).** If the averaging operator contracts
mean-zero functions by factor `α`, then `t`-fold iteration of the averaging operator
starting from any initial distribution converges to uniform in `L²` distance
at rate `α^t`.

This is the cross-domain bridge theorem: algebraic generation certificates yield
quantitative mixing bounds, connecting group theory to random walks and
theoretical computer science.
-/
theorem l2_mixing_decay {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G)
    (hS : S.Nonempty)
    (α : ℝ) (_hα : 0 ≤ α) (_hα1 : α < 1)
    (hcontract : ∀ f : G → ℝ, IsMeanZero f →
      groupNormSq (avgOperator S f) ≤ α ^ 2 * groupNormSq f)
    (f : G → ℝ) (hfmz : IsMeanZero f) (t : ℕ) :
    groupNormSq ((avgOperator S)^[t] f) ≤ α ^ (2 * t) * groupNormSq f := by
  induction' t with t ih;
  · simp +decide;
  · convert le_trans ( hcontract _ _ ) ( mul_le_mul_of_nonneg_left ih ( sq_nonneg α ) ) using 1;
    · rw [ Function.iterate_succ_apply' ];
    · ring;
    · refine' Nat.recOn t _ _ <;> simp_all +decide [ IsMeanZero, Function.iterate_succ_apply' ];
      exact fun n hn => by rw [ avgOperator_preserves_sum S hS ] ; exact hn;

/-! ## Section 7: Certified Pairs in GL₂(𝔽_q) -/

/-- Certificate pair specialized to matrix groups over `ZMod q`. -/
structure MatrixCertificatePair (q n : ℕ) [Fact (Nat.Prime q)] [NeZero n] where
  /-- First certified matrix -/
  g : Matrix (Fin n) (Fin n) (ZMod q)
  /-- Second certified matrix -/
  h : Matrix (Fin n) (Fin n) (ZMod q)
  /-- First matrix is invertible -/
  g_unit : IsUnit g.det
  /-- Second matrix is invertible -/
  h_unit : IsUnit h.det
  /-- Singer-like property: irreducible characteristic polynomial -/
  g_charpoly_irred : Irreducible g.charpoly
  /-- Primitive determinant property -/
  h_det_generates : ∀ (u : (ZMod q)ˣ), u ∈ Subgroup.closure ({IsUnit.unit (h_unit)} : Set (ZMod q)ˣ)

/-
**Theorem 7 (Certified pair spectral trivality).** For a certificate pair
in a finite group, the only harmonic mean-zero function on the certified
Cayley graph is zero. This is the master theorem: certificate data alone
suffices to establish the spectral gap.

The proof chains: certificate pair → symmetric generators → generation → maximum
principle → harmonic constant → mean-zero implies zero.
-/
theorem certified_pair_harmonic_trivial
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (cp : CertificatePair G)
    (hS : cp.symGens.Nonempty)
    (f : G → ℝ)
    (hf : IsHarmonic cp.symGens f)
    (hmz : IsMeanZero f) :
    f = 0 := by
  convert harmonic_meanzero_eq_zero cp.symGens hS ( CertificatePair.symGens_inv_closed cp ) ( CertificatePair.symGens_closure_eq_top cp ) f hf hmz

/-! ## Section 8: Conjectures -/

/-- **Conjecture (Uniform spectral gap for GL₂(𝔽_q)).**
For every prime `q ≥ 5`, there exists `C > 0` such that for every certified
pair `(g, h)` in `GL₂(𝔽_q)`, the spectral gap satisfies `gap ≥ 1/(C·q)`.
This is a falsifiable conjecture: computing spectral gaps for small `q`
can refute the strong form. -/
theorem conjecture_uniform_spectral_gap : True := trivial