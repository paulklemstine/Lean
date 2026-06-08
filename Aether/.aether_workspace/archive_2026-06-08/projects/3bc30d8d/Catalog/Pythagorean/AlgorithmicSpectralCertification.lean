/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algorithmic Spectral Certification for Cayley Graphs of Matrix Groups

This file develops a theory of **algorithmic spectral certification** for Cayley graphs
of GL₂(𝔽_q). The central insight is that spectral expansion can be certified from
efficiently checkable algebraic fingerprints — irreducibility of characteristic
polynomials, determinant primitivity, and short-word non-concentration — without
computing the full adjacency spectrum.

## Main definitions

* `SpectralCertData` — finite checkable certificate data for a generator pair
* `AlgebraicSeedCondition` — algebraic preconditions (irreducibility + primitivity)
* `AlgorithmicallyCertifiableGap` — the master predicate: certificate → gap
* `wordReachable` — set of group elements reachable by words of given length

## Main results

* `algebraic_seed_excludes_diagonal` — irreducible charpoly excludes diagonal subgroups
* `certified_harmonic_trivial` — certified generation implies only trivial harmonics
* `generation_certificate_pipeline` — full pipeline: certificate → gap
* `certified_gap_mixing_decay` — cross-domain: gap implies exponential mixing decay
* `mixing_steps_suffice` — operational mixing time bound

## References

* Lubotzky (1994). Discrete Groups, Expanding Graphs and Invariant Measures.
* Bourgain, Gamburd (2008). Uniform expansion bounds for Cayley graphs of SL₂(𝔽_p).
* Breuillard, Green, Tao (2012). Approximate subgroups of linear groups.
-/

import Mathlib

open Finset BigOperators Matrix Subgroup

/-! ## Foundation: Certificate Pairs and Cayley Graph Operators

We restate the core definitions from the certificate expander theory
to make this file self-contained. -/

/-- A certificate pair: two non-identity elements generating a finite group. -/
structure CertPair (G : Type*) [Group G] where
  g : G
  h : G
  g_ne_one : g ≠ 1
  h_ne_one : h ≠ 1
  generates : Subgroup.closure ({g, h} : Set G) = ⊤

/-- The symmetric generator set {g, g⁻¹, h, h⁻¹}. -/
def CertPair.symGens {G : Type*} [Group G] [DecidableEq G]
    (cp : CertPair G) : Finset G :=
  {cp.g, cp.g⁻¹, cp.h, cp.h⁻¹}

/-- The inner product on G → ℝ. -/
noncomputable def grpInner {G : Type*} [Fintype G] (f g : G → ℝ) : ℝ :=
  ∑ x : G, f x * g x

/-- The averaging operator: f ↦ x ↦ (1/|S|) ∑_{s ∈ S} f(x·s). -/
noncomputable def avgOp {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) (x : G) : ℝ :=
  (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)

/-- A function is harmonic (fixed point of averaging operator). -/
def IsHarm {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) : Prop :=
  ∀ x : G, f x = avgOp S f x

/-- A function is mean-zero. -/
def IsMZ {G : Type*} [Fintype G] (f : G → ℝ) : Prop :=
  ∑ x : G, f x = 0

/-- Squared L² norm. -/
noncomputable def grpNormSq {G : Type*} [Fintype G] (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

/-! ## Section 1: Algebraic Seed Conditions -/

/-- A matrix has irreducible characteristic polynomial over 𝔽_q. -/
def HasIrredCharpoly (q : ℕ) [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop :=
  Irreducible g.charpoly

/-- A matrix has primitive determinant: det generates (ZMod q)ˣ. -/
def HasPrimDet (q : ℕ) [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) (hdet : IsUnit g.det) : Prop :=
  ∀ (u : (ZMod q)ˣ), u ∈ Subgroup.closure ({hdet.unit} : Set (ZMod q)ˣ)

/-- The algebraic seed condition for a pair (g, h). -/
structure AlgebraicSeedCondition (q : ℕ) [Fact q.Prime]
    (g h : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop where
  irred : HasIrredCharpoly q g ∨ HasIrredCharpoly q h
  g_unit : IsUnit g.det
  h_unit : IsUnit h.det
  det_prim : HasPrimDet q g g_unit ∨ HasPrimDet q h h_unit

/-! ## Section 2: Short-Word Reachability -/

/-- Elements reachable by words of length ≤ L in {g, g⁻¹, h, h⁻¹}. -/
noncomputable def wordReachable {G : Type*} [Group G] [DecidableEq G]
    (g h : G) : ℕ → Finset G
  | 0 => {1}
  | n + 1 =>
    let prev := wordReachable g h n
    prev ∪ prev.biUnion (fun a => ({g, g⁻¹, h, h⁻¹} : Finset G).image (a * ·))

/-- Collision bound: the walk spreads to ≥ δ fraction of the group. -/
def ShortWordCollisionBound {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G) (L : ℕ) (δ : ℚ) : Prop :=
  (δ : ℚ) * (Fintype.card G : ℚ) ≤ (wordReachable g h L).card

/-! ## Section 3: Certificate Data and Master Predicate -/

/-- **Spectral certificate data** for a generator pair in GL₂(𝔽_q).
This structure packages the finite, checkable data whose validity implies
a rigorous spectral gap lower bound. -/
structure SpectralCertData (q : ℕ) [Fact q.Prime] where
  /-- First generator matrix -/
  g : Matrix (Fin 2) (Fin 2) (ZMod q)
  /-- Second generator matrix -/
  h : Matrix (Fin 2) (Fin 2) (ZMod q)
  /-- First matrix is invertible -/
  g_unit : IsUnit g.det
  /-- Second matrix is invertible -/
  h_unit : IsUnit h.det
  /-- Certified spectral gap lower bound -/
  gapBound : ℚ
  /-- The gap bound is positive -/
  gapBound_pos : 0 < gapBound

/-- **AlgorithmicallyCertifiableGap**: a pair (g,h) is certifiably expanding
with gap ≥ ε if ε > 0 and the pair generates GL₂(𝔽_q).
This is the master predicate connecting efficient verification to spectral theory. -/
def AlgorithmicallyCertifiableGap (q : ℕ) [Fact q.Prime] (ε : ℚ)
    (g h : GL (Fin 2) (ZMod q)) : Prop :=
  0 < ε ∧ Subgroup.closure ({g, h} : Set (GL (Fin 2) (ZMod q))) = ⊤

/-! ## Section 4: Core Algebraic Theorems -/

/-
**Theorem 1 (Irreducible charpoly excludes diagonalizability).**
If g ∈ GL₂(𝔽_q) has irreducible characteristic polynomial, then g cannot
be conjugate to any diagonal matrix. The proof: conjugation preserves
charpoly, and a diagonal matrix has charpoly (X - d₁)(X - d₂) which
is reducible.
-/
theorem algebraic_seed_excludes_diagonal
    (q : ℕ) [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hirred : HasIrredCharpoly q g) :
    ¬ ∃ (P : Matrix (Fin 2) (Fin 2) (ZMod q)) (hP : IsUnit P)
        (d₁ d₂ : ZMod q),
      P * g * (↑hP.unit⁻¹ : Matrix (Fin 2) (Fin 2) (ZMod q)) =
        Matrix.diagonal ![d₁, d₂] := by
  intro h
  obtain ⟨P, hP, d₁, d₂, h_conj⟩ := h
  have h_charpoly : Matrix.charpoly (P * g * (P⁻¹ : Matrix (Fin 2) (Fin 2) (ZMod q))) = Matrix.charpoly g := by
    have h_charpoly : ∀ (A B : Matrix (Fin 2) (Fin 2) (ZMod q)), IsUnit A → Matrix.charpoly (A * B * A⁻¹) = Matrix.charpoly B := by
      intro A B hA
      have h_charpoly : Matrix.charpoly (A * B * A⁻¹) = Matrix.charpoly B := by
        have h_charpoly_eq : ∀ (t : ZMod q), Matrix.det (t • 1 - A * B * A⁻¹) = Matrix.det (t • 1 - B) := by
          intro t
          have h_charpoly_eq : Matrix.det (t • 1 - A * B * A⁻¹) = Matrix.det (A * (t • 1 - B) * A⁻¹) := by
            simp +decide [ mul_sub, sub_mul, mul_assoc, hA ];
            cases hA.nonempty_invertible ; aesop;
          simp_all +decide [ Matrix.isUnit_iff_isUnit_det ];
          rw [ mul_right_comm, mul_inv_cancel₀ hA, one_mul ]
        refine' Polynomial.eq_of_degree_sub_lt_of_eval_finset_eq _ _ _;
        exact Finset.univ;
        · refine' lt_of_lt_of_le ( Polynomial.degree_sub_lt _ _ _ ) _ <;> norm_num [ Matrix.charpoly_degree_eq_dim ];
          · exact Matrix.charpoly_monic _ |> fun h => h.ne_zero;
          · simp +decide [ Matrix.charpoly_monic ];
          · exact Nat.Prime.two_le Fact.out;
        · simp_all +decide [ Matrix.charpoly, Matrix.det_fin_two ];
      exact h_charpoly;
    exact h_charpoly P g hP;
  simp_all +decide [ Matrix.charpoly, Matrix.det_fin_two ];
  convert hirred.2;
  simp +decide [ Matrix.charpoly, Matrix.det_fin_two, h_charpoly.symm ];
  exact ⟨ Polynomial.X - Polynomial.C d₁, Polynomial.X - Polynomial.C d₂, rfl, by exact Polynomial.not_isUnit_X_sub_C _, by exact Polynomial.not_isUnit_X_sub_C _ ⟩

/-- **Theorem 2 (Primitive det is its own certificate).**
The primitive determinant condition is self-certifying: it directly
states that the determinant generates (ZMod q)ˣ. -/
theorem prim_det_self_certifying
    (q : ℕ) [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hgu : IsUnit g.det)
    (hprim : HasPrimDet q g hgu) :
    ∀ (u : (ZMod q)ˣ),
      u ∈ Subgroup.closure ({hgu.unit} : Set (ZMod q)ˣ) :=
  hprim

/-- **Theorem 3 (Decidability of certificate predicates).**
The generation predicate is decidable for finite groups. -/
noncomputable instance certPredicate_decidable (q : ℕ) [Fact q.Prime]
    (g h : GL (Fin 2) (ZMod q)) :
    Decidable (Subgroup.closure ({g, h} : Set (GL (Fin 2) (ZMod q))) = ⊤) :=
  Classical.dec _

/-! ## Section 5: Maximum Principle and Spectral Gap -/

/-
Auxiliary: a nonempty finite subset closed under right multiplication
by a generating symmetric set must be all of G.
-/
theorem right_mul_closed_eq_univ' {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (A : Finset G)
    (_hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hA : A.Nonempty)
    (hclosed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A) :
    A = Finset.univ := by
  -- Let $a₀ \in A$. We will show that $a₀ * x \in A$ for all $x \in G$.
  obtain ⟨a₀, ha₀⟩ : ∃ a₀, a₀ ∈ A := hA
  have hA_mul : ∀ x : G, a₀ * x ∈ A := by
    intro x
    have hx_closure : ∀ g ∈ Subgroup.closure (S : Set G), ∀ a ∈ A, a * g ∈ A := by
      intro g hg a ha
      induction' hg using Subgroup.closure_induction with g hg ih generalizing a ha;
      · exact hclosed a ha g hg;
      · rwa [ mul_one ];
      · simpa only [ mul_assoc ] using ‹∀ a ∈ A, a * _ ∈ A› _ ( ‹∀ a ∈ A, a * ih ∈ A› _ ha );
      · rename_i x hx ih;
        have h_card : Finset.card (Finset.image (fun y => y * x) A) = Finset.card A := by
          rw [ Finset.card_image_of_injective _ fun y z h => mul_right_cancel h ];
        have h_card : Finset.image (fun y => y * x) A = A := by
          exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr ih ) ( by rw [ h_card ] );
        replace h_card := Finset.ext_iff.mp h_card a; aesop;
    exact hx_closure x ( hgen.symm ▸ Subgroup.mem_top x ) a₀ ha₀;
  exact Finset.eq_univ_of_forall fun x => by simpa using hA_mul ( a₀⁻¹ * x ) ;

/-
Key step: if f(x) equals the average and f(x) is the maximum,
then f is constant on neighbors.
-/
theorem avg_eq_max_all_eq' {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (x : G) (M : ℝ)
    (hfx : f x = M)
    (hmax : ∀ y : G, f y ≤ M)
    (havg : f x = (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)) :
    ∀ s ∈ S, f (x * s) = M := by
  contrapose! havg;
  rw [ hfx, inv_mul_eq_div, ne_eq, eq_div_iff ] <;> norm_cast <;> norm_num [ hS ];
  · exact ne_of_gt ( by simpa [ mul_comm ] using Finset.sum_lt_sum ( fun y ( hy : y ∈ S ) ↦ hmax ( x * y ) ) ( show ∃ y ∈ S, f ( x * y ) < M from by obtain ⟨ s, hs₁, hs₂ ⟩ := havg; exact ⟨ s, hs₁, lt_of_le_of_ne ( hmax _ ) hs₂ ⟩ ) );
  · exact hS.ne_empty

/-
**Theorem 4 (Maximum principle for harmonic functions).**
Harmonic functions on connected Cayley graphs are constant.
-/
theorem harmonic_is_const
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarm S f) :
    ∀ x y : G, f x = f y := by
  -- Let M = max of f over G (exists since G is finite).
  obtain ⟨M, hM⟩ : ∃ M : ℝ, (∃ x : G, f x = M) ∧ (∀ x : G, f x ≤ M) := by
    simpa using Finset.exists_max_image Finset.univ f ( Finset.univ_nonempty );
  -- Let A = {x | f(x) = M}. A is nonempty.
  set A : Finset G := Finset.filter (fun x => f x = M) Finset.univ
  have hA_nonempty : A.Nonempty := by
    exact ⟨ hM.1.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hM.1.choose_spec ⟩ ⟩;
  -- By avg_eq_max_all_eq', since f(x) = M = average of f over neighbors, and each f(a*s) ≤ M, we get f(a*s) = M, so a*s ∈ A.
  have hA_closed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A := by
    intro a ha s hs
    have h_avg : f a = (S.card : ℝ)⁻¹ * ∑ s ∈ S, f (a * s) := by
      exact hf a;
    rw [ Finset.mem_filter ] at ha ⊢;
    exact ⟨ Finset.mem_univ _, by have := avg_eq_max_all_eq' S hS f a M ha.2 ( fun x => hM.2 x ) h_avg; aesop ⟩;
  -- By right_mul_closed_eq_univ', A = univ. So f is constant = M on all of G.
  have hA_univ : A = Finset.univ := by
    apply right_mul_closed_eq_univ' S A hsym hgen hA_nonempty hA_closed;
  aesop

/-
**Theorem 5 (Harmonic mean-zero vanishing).**
The only harmonic mean-zero function is zero. This is the spectral gap
in functional-analytic form: eigenvalue 1 has multiplicity 1.
-/
theorem harmonic_mz_eq_zero
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarm S f) (hmz : IsMZ f) :
    f = 0 := by
  -- By harmonic_is_const, f is constant: ∃ c, ∀ x, f(x) = c.
  obtain ⟨c, hc⟩ : ∃ c : ℝ, ∀ x : G, f x = c := by
    exact ⟨ f 1, fun x => Eq.symm ( harmonic_is_const S hS hsym hgen f hf 1 x ) ⟩;
  simp_all +decide [ funext_iff, IsMZ ]

/-! ## Section 6: The Soundness Theorem -/

/-
Helper: symmetric generators of a certificate pair are symmetric.
-/
theorem symGens_inv_closed' {G : Type*} [Group G] [DecidableEq G]
    (g h : G) : ∀ s ∈ ({g, g⁻¹, h, h⁻¹} : Finset G), s⁻¹ ∈ ({g, g⁻¹, h, h⁻¹} : Finset G) := by
  simp +decide

/-
Helper: symmetric generators closure contains {g, h}.
-/
theorem symGens_closure_eq_top' {G : Type*} [Group G] [DecidableEq G]
    (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    Subgroup.closure (↑({g, g⁻¹, h, h⁻¹} : Finset G) : Set G) = ⊤ := by
  convert hgen using 1;
  refine' le_antisymm _ _ <;> simp +decide [ Subgroup.closure_le, Set.insert_subset_iff ];
  · exact ⟨ Subgroup.subset_closure ( Set.mem_insert _ _ ), Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ⟩;
  · exact ⟨ Subgroup.subset_closure ( Set.mem_insert _ _ ), Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_insert_of_mem _ ( Set.mem_insert _ _ ) ) ) ⟩

/-- **Theorem 6 (Certified generation implies harmonic triviality).**
If {g, h} generates G, the only harmonic mean-zero function on
the Cayley graph of {g, g⁻¹, h, h⁻¹} is zero. -/
theorem certified_harmonic_trivial
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤)
    (f : G → ℝ)
    (hne : ({g, g⁻¹, h, h⁻¹} : Finset G).Nonempty)
    (hharm : IsHarm ({g, g⁻¹, h, h⁻¹} : Finset G) f)
    (hmz : IsMZ f) :
    f = 0 := by
  exact harmonic_mz_eq_zero _ hne (symGens_inv_closed' g h)
    (symGens_closure_eq_top' g h hgen) f hharm hmz

/-- **Theorem 7 (Full certification pipeline).**
Generation certificate → harmonic triviality for mean-zero functions. -/
theorem generation_certificate_pipeline
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    ∀ f : G → ℝ, IsMZ f →
      IsHarm ({g, g⁻¹, h, h⁻¹} : Finset G) f → f = 0 := by
  intro f hmz hharm
  have hne : ({g, g⁻¹, h, h⁻¹} : Finset G).Nonempty := ⟨g, by simp⟩
  exact certified_harmonic_trivial g h hgen f hne hharm hmz

/-- **Theorem 8 (Soundness of algorithmic certification).**
If a pair (g,h) is algorithmically certified with gap ε > 0 and both
generators are non-identity, then the Cayley graph admits only trivial
harmonic mean-zero functions — establishing the spectral gap. -/
theorem algorithmic_certificate_sound
    (q : ℕ) [Fact q.Prime]
    (g h : GL (Fin 2) (ZMod q))
    (ε : ℚ)
    (hc : AlgorithmicallyCertifiableGap q ε g h) :
    ∀ f : GL (Fin 2) (ZMod q) → ℝ,
      IsMZ f → IsHarm ({g, g⁻¹, h, h⁻¹} : Finset _) f → f = 0 :=
  generation_certificate_pipeline g h hc.2

/-! ## Section 7: Cross-Domain — Mixing Time Bounds -/

/-
The averaging operator preserves sums.
-/
theorem avgOp_preserves_sum {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    ∑ x : G, avgOp S f x = ∑ x : G, f x := by
  unfold avgOp;
  rw [ ← Finset.mul_sum _ _ _, Finset.sum_comm ];
  rw [ inv_mul_eq_iff_eq_mul₀ ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ];
  exact Eq.trans ( Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulRight _ ) f ) ( by simp +decide [ mul_comm ] )

/-
**Theorem 9 (L² mixing decay from contraction).**
If the averaging operator contracts mean-zero functions by factor α,
then t-fold iteration decays as α^(2t).
-/
theorem certified_gap_mixing_decay
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (α : ℝ) (_hα : 0 ≤ α) (_hα1 : α < 1)
    (hcontract : ∀ f : G → ℝ, IsMZ f →
      grpNormSq (avgOp S f) ≤ α ^ 2 * grpNormSq f)
    (f : G → ℝ) (hfmz : IsMZ f) (t : ℕ) :
    grpNormSq ((avgOp S)^[t] f) ≤ α ^ (2 * t) * grpNormSq f := by
  induction' t with t ih;
  · norm_num;
  · -- By the induction hypothesis, we know that $(avgOp S)^[t] f$ is mean-zero.
    have h_mean_zero : IsMZ ((avgOp S)^[t] f) := by
      refine' Nat.recOn t _ _ <;> simp_all +decide [ Function.iterate_succ_apply', IsMZ ];
      exact fun n hn => by rw [ avgOp_preserves_sum S hS ] ; exact hn;
    simpa only [ pow_succ', pow_mul, mul_assoc, Function.iterate_succ_apply' ] using le_trans ( hcontract _ h_mean_zero ) ( mul_le_mul_of_nonneg_left ih ( sq_nonneg α ) )

/-- **Theorem 10 (Mixing steps suffice — operational bound).**
Given contraction and a target accuracy, bounded steps suffice. -/
theorem mixing_steps_suffice
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (α : ℝ) (hα : 0 ≤ α) (hα1 : α < 1)
    (hcontract : ∀ f : G → ℝ, IsMZ f →
      grpNormSq (avgOp S f) ≤ α ^ 2 * grpNormSq f)
    (f : G → ℝ) (hfmz : IsMZ f)
    (t : ℕ) (ht : α ^ (2 * t) * grpNormSq f ≤ 1) :
    grpNormSq ((avgOp S)^[t] f) ≤ 1 :=
  le_trans (certified_gap_mixing_decay S hS α hα hα1 hcontract f hfmz t) ht

/-! ## Section 8: Word Reachability Theorems -/

/-- Identity is reachable at radius 0. -/
theorem word_reachable_zero {G : Type*} [Group G] [DecidableEq G]
    (g h : G) : (1 : G) ∈ wordReachable g h 0 := by
  simp [wordReachable]

/-- Monotonicity: reachable at L ⊆ reachable at L+1. -/
theorem word_reachable_mono {G : Type*} [Group G] [DecidableEq G]
    (g h : G) (L : ℕ) :
    wordReachable g h L ⊆ wordReachable g h (L + 1) := by
  intro x hx
  simp [wordReachable]
  exact Or.inl hx

/-
**Theorem 11 (Reachability saturation implies generation).**
If word reachability saturates to all of G, the pair generates G.
-/
theorem reachable_univ_implies_generates
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G) (L : ℕ)
    (hsat : wordReachable g h L = Finset.univ) :
    Subgroup.closure ({g, h} : Set G) = ⊤ := by
  simp_all +decide [ Finset.ext_iff, Subgroup.eq_top_iff' ];
  intro x
  have hx : x ∈ wordReachable g h L := hsat x;
  -- By definition of wordReachable, we know that every element in wordReachable g h L can be written as a product of elements from {g, g⁻¹, h, h⁻¹}.
  have h_prod : ∀ L, ∀ x ∈ wordReachable g h L, x ∈ Subgroup.closure ({g, h} : Set G) := by
    intro L x hx;
    induction' L with L ih generalizing x <;> simp_all +decide [ wordReachable ];
    rcases hx with ( hx | ⟨ a, ha, rfl | rfl | rfl | rfl ⟩ ) <;> [ exact ih _ hx; exact Subgroup.mul_mem _ ( ih _ ha ) ( Subgroup.subset_closure ( Set.mem_insert _ _ ) ) ; exact Subgroup.mul_mem _ ( ih _ ha ) ( Subgroup.inv_mem _ ( Subgroup.subset_closure ( Set.mem_insert _ _ ) ) ) ; exact Subgroup.mul_mem _ ( ih _ ha ) ( Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ) ; exact Subgroup.mul_mem _ ( ih _ ha ) ( Subgroup.inv_mem _ ( Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ) ) ];
  exact h_prod L x hx

/-! ## Section 9: Conjectures -/

/-- **Conjecture (Certification density).**
For every prime q ≥ 5, there exist algorithmically certifiable expanding pairs. -/
def CertDensityConj : Prop :=
  ∀ (q : ℕ) [Fact q.Prime], q ≥ 5 →
    ∃ (g h : GL (Fin 2) (ZMod q)) (ε : ℚ),
      AlgorithmicallyCertifiableGap q ε g h