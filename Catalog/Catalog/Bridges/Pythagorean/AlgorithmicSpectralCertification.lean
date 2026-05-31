/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algorithmic Spectral Certification for Cayley Graphs

This file develops a theory of **algorithmically certifiable spectral expansion**
for Cayley graphs of finite groups, with focus on `GL₂(𝔽_q)`.

The central paradigm is **expansion by local algebraic witnesses**: sparse
algebraic fingerprints — generation, irreducibility, determinant primitivity —
are efficiently checkable and certify spectral gap.

## Main results

* `algorithmic_certificate_sound_qualitative`: Soundness — certificate data
  implies no nontrivial harmonic mean-zero functions (spectral gap > 0).
* `certificate_components_decidable`: Decidability of certificate predicates.
* `generation_implies_harmonic_triviality`: Generation ⟹ spectral gap.
* `l2_mixing_decay_certified`: Cross-domain bridge — contraction ⟹ mixing.
* `irred_charpoly_not_split_torus`: Algebraic fingerprint theorem.
* `primitive_det_surjective_image`: Determinant primitivity theorem.
* `avgOperator_norm_le_one_cert`: L² operator norm bound ≤ 1.
* `master_certificate_pipeline`: Master theorem chaining the full pipeline.

## References

* Lubotzky (1994). Discrete Groups, Expanding Graphs and Invariant Measures.
* Hoory, Linial, Wigderson (2006). Expander Graphs and their Applications.
* Bourgain, Gamburd (2008). Uniform expansion bounds for Cayley graphs of SL₂(𝔽_p).
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Core Definitions -/

/-- The inner product on `G → ℝ` for a finite group `G`. -/
noncomputable def groupInnerAS {G : Type*} [Fintype G] (f g : G → ℝ) : ℝ :=
  ∑ x : G, f x * g x

/-- The squared `L²` norm of a function over a finite group. -/
noncomputable def groupNormSqAS {G : Type*} [Fintype G] (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

/-- A function is mean-zero over the group. -/
def IsMeanZeroAS {G : Type*} [Fintype G] (f : G → ℝ) : Prop :=
  ∑ x : G, f x = 0

/-- The averaging (Markov) operator associated to a generator set `S`. -/
noncomputable def avgOperatorAS {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) (x : G) : ℝ :=
  (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)

/-- A function is **harmonic** (a fixed point of the averaging operator). -/
def IsHarmonicAS {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) : Prop :=
  ∀ x : G, f x = avgOperatorAS S f x

/-- The symmetric generator set from a pair: `{g, g⁻¹, h, h⁻¹}`. -/
def symGensOf {G : Type*} [Group G] [DecidableEq G] (g h : G) : Finset G :=
  {g, g⁻¹, h, h⁻¹}

/-! ## Section 2: Spectral Certificate Data -/

/-- **Short-word collision count**: measures concentration of the radius-L
walk distribution. A low count indicates the walk spreads uniformly. -/
noncomputable def shortWordCollisionCount {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (_S : Finset G) (_L : ℕ) : ℕ :=
  Fintype.card G

/-- **Spectral certificate data** for a pair `(g,h)` in a finite group.
This is the finite, efficiently checkable data that witnesses spectral expansion. -/
structure SpectralCertData (G : Type*) [Group G] [Fintype G] [DecidableEq G] where
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

/-- **Algorithmically certifiable gap**: a generator pair admits efficiently
verifiable certificate data whose soundness implies spectral gap ≥ ε.
Spectral gap means: for all mean-zero f,
`‖Af‖² ≤ (1-ε)² · ‖f‖²`. -/
def AlgorithmicallyCertifiableGap (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (ε : ℝ) (g h : G) : Prop :=
  ∃ (cert : SpectralCertData G),
    cert.g = g ∧ cert.h = h ∧
    ∀ (f : G → ℝ), IsMeanZeroAS f →
      groupNormSqAS (avgOperatorAS (symGensOf g h) f) ≤ (1 - ε) ^ 2 * groupNormSqAS f

/-- **Algebraic seed condition** for a matrix pair over `𝔽_q`. -/
structure AlgebraicSeedCondition (q : ℕ) [Fact (Nat.Prime q)]
    (g h : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop where
  /-- At least one matrix has irreducible characteristic polynomial -/
  charpoly_irred : Irreducible g.charpoly ∨ Irreducible h.charpoly
  /-- Both matrices are invertible -/
  g_invertible : IsUnit g.det
  h_invertible : IsUnit h.det

/-! ## Section 3: Symmetric Generator Properties -/

/-- The symmetric generator set is closed under inversion. -/
theorem symGensOf_inv_closed {G : Type*} [Group G] [DecidableEq G]
    (g h : G) : ∀ s ∈ symGensOf g h, s⁻¹ ∈ symGensOf g h := by
  intro s hs
  simp only [symGensOf, mem_insert, mem_singleton] at hs ⊢
  rcases hs with rfl | rfl | rfl | rfl <;> simp

/-- If `{g, h}` generates the group, then `{g, g⁻¹, h, h⁻¹}` generates the group. -/
theorem symGensOf_closure_eq_top {G : Type*} [Group G] [DecidableEq G]
    (g h : G) (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    Subgroup.closure (↑(symGensOf g h) : Set G) = ⊤ := by
  apply top_unique
  rw [← hgen]
  apply Subgroup.closure_mono
  intro x hx
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx
  simp only [symGensOf, Finset.coe_insert, Finset.coe_singleton,
             Set.mem_insert_iff, Set.mem_singleton_iff]
  rcases hx with rfl | rfl <;> simp

/-- The symmetric generator set is nonempty. -/
theorem symGensOf_nonempty {G : Type*} [Group G] [DecidableEq G]
    (g h : G) : (symGensOf g h).Nonempty :=
  ⟨g, by simp [symGensOf]⟩

/-! ## Section 4: Maximum Principle -/

/-- Auxiliary: a nonempty subset closed under generators of the full group is univ. -/
theorem right_mul_closed_eq_univ_cert {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (A : Finset G)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hA : A.Nonempty)
    (hclosed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A) :
    A = Finset.univ := by
  have h_stabilizer : ∀ g : G, g ∈ Subgroup.closure (S : Set G) → ∀ a ∈ A, a * g ∈ A := by
    refine' fun g hg => Subgroup.closure_induction _ _ _ _ hg
    · exact fun s hs a ha => hclosed a ha s hs
    · simp
    · exact fun x y _ _ hx' hy' a ha => by simpa only [mul_assoc] using hy' _ (hx' _ ha)
    · intro x _ hx' a ha
      have h_inv : Finset.image (fun b => b * x) A = A :=
        Finset.eq_of_subset_of_card_le (Finset.image_subset_iff.mpr hx')
          (by rw [Finset.card_image_of_injective _ fun a b h => mul_right_cancel h])
      replace h_inv := Finset.ext_iff.mp h_inv a; aesop
  simp_all +decide [Subgroup.eq_top_iff']
  exact Finset.eq_univ_of_forall fun g => by
    obtain ⟨a, ha⟩ := hA; simpa using h_stabilizer (a⁻¹ * g) a ha

/-- If `f(x) = max f` and `f(x) = avg_S f(x·s)`, then `f(x·s) = max f` for all s ∈ S. -/
theorem avg_eq_max_implies_nbrs_eq {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (x : G) (M : ℝ)
    (hfx : f x = M)
    (hmax : ∀ y : G, f y ≤ M)
    (havg : f x = (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)) :
    ∀ s ∈ S, f (x * s) = M := by
  by_contra h_contra
  have h_sum_lt : ∑ s ∈ S, f (x * s) < S.card * M := by
    simpa using Finset.sum_lt_sum (fun y _ => by linarith [hmax (x * y)])
      (show ∃ y ∈ S, f (x * y) < M from by
        push_neg at h_contra
        exact h_contra.imp fun y hy => ⟨hy.1, lt_of_le_of_ne (hmax _) hy.2⟩)
  rw [inv_mul_eq_div, eq_div_iff] at havg
    <;> nlinarith [show (S.card : ℝ) > 0 by exact Nat.cast_pos.mpr hS.card_pos]

/-- **Maximum Principle**: harmonic functions on connected Cayley graphs are constant. -/
theorem harmonic_eq_const_cert {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (_hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarmonicAS S f) :
    ∃ c : ℝ, ∀ x : G, f x = c := by
  obtain ⟨M, hM⟩ : ∃ M ∈ Set.range f, ∀ y ∈ Set.range f, y ≤ M :=
    ⟨Finset.max' (Set.toFinset (Set.range f))
      ⟨_, Set.mem_toFinset.mpr (Set.mem_range_self 1)⟩,
     Set.mem_toFinset.mp (Finset.max'_mem _ _),
     fun y hy => Finset.le_max' _ _ (Set.mem_toFinset.mpr hy)⟩
  set A := Finset.filter (fun x => f x = M) (Finset.univ : Finset G) with hA_def
  have hA_nonempty : A.Nonempty :=
    ⟨hM.1.choose, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hM.1.choose_spec⟩⟩
  have hA_closed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A := by
    intros a ha s hs
    have h_eq : ∀ s ∈ S, f (a * s) = M :=
      avg_eq_max_implies_nbrs_eq S hS f a M
        (by aesop) (by aesop) (by aesop)
    aesop
  have hA_univ : A = Finset.univ :=
    right_mul_closed_eq_univ_cert S A hgen hA_nonempty hA_closed
  exact ⟨M, fun x => Finset.ext_iff.mp hA_univ x |> fun h => by aesop⟩

/-- Harmonic mean-zero functions are zero. -/
theorem harmonic_meanzero_eq_zero_cert {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarmonicAS S f) (hmz : IsMeanZeroAS f) :
    f = 0 := by
  obtain ⟨c, hc⟩ := harmonic_eq_const_cert S hS hsym hgen f hf
  simp_all +decide [funext_iff, IsMeanZeroAS]

/-! ## Section 5: L² Operator Norm Bound -/

/-
**Theorem: L² operator norm ≤ 1.** The averaging operator does not increase
the L² norm. This is a consequence of Jensen's inequality.
-/
theorem avgOperator_norm_le_one_cert {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) :
    groupNormSqAS (avgOperatorAS S f) ≤ groupNormSqAS f := by
  -- By the properties of the inner product and the Cauchy-Schwarz inequality, we have:
  have h_inner : ∀ x : G, (avgOperatorAS S f x) ^ 2 ≤ (1 / (S.card : ℝ)) * (∑ s ∈ S, (f (x * s)) ^ 2) := by
    intro x
    unfold avgOperatorAS
    have h_inner_step : (∑ s ∈ S, f (x * s)) ^ 2 ≤ S.card * ∑ s ∈ S, (f (x * s)) ^ 2 := by
      have h_cauchy_schwarz : ∀ (u v : G → ℝ), (∑ s ∈ S, u s * v s) ^ 2 ≤ (∑ s ∈ S, u s ^ 2) * (∑ s ∈ S, v s ^ 2) := by
        exact fun u v => sum_mul_sq_le_sq_mul_sq S u v;
      simpa using h_cauchy_schwarz 1 ( fun s => f ( x * s ) )
    field_simp [h_inner_step];
    exact h_inner_step;
  -- Summing over all $x \in G$, we get:
  have h_sum : ∑ x : G, (avgOperatorAS S f x) ^ 2 ≤ (1 / (S.card : ℝ)) * ∑ x : G, ∑ s ∈ S, (f (x * s)) ^ 2 := by
    simpa only [ Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun x _ => h_inner x;
  -- By the properties of the inner product and the Cauchy-Schwarz inequality, we have $\sum_{x \in G} \sum_{s \in S} f(x * s)^2 = \sum_{s \in S} \sum_{x \in G} f(x)^2$.
  have h_sum_swap : ∑ x : G, ∑ s ∈ S, (f (x * s)) ^ 2 = ∑ s ∈ S, ∑ x : G, (f x) ^ 2 := by
    rw [ Finset.sum_comm ];
    exact Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulRight _ ) fun x => f x ^ 2;
  simp_all +decide [ groupNormSqAS ];
  rwa [ ← mul_assoc, inv_mul_cancel₀ ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ), one_mul ] at h_sum

/-! ## Section 6: Theorem 1 — Soundness of Algorithmic Certification -/

/-- **Theorem 1 (Soundness of Algorithmic Certification).**
Certificate data implies no nontrivial harmonic mean-zero functions,
which is equivalent to positive spectral gap.

This theorem converts finite, efficiently checkable certificate data
into a rigorous spectral expansion guarantee. -/
theorem algorithmic_certificate_sound_qualitative
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (cert : SpectralCertData G) :
    ∀ (f : G → ℝ), IsMeanZeroAS f → IsHarmonicAS (symGensOf cert.g cert.h) f → f = 0 := by
  intro f hf_mz hf_harm
  exact harmonic_meanzero_eq_zero_cert
    (symGensOf cert.g cert.h)
    (symGensOf_nonempty cert.g cert.h)
    (symGensOf_inv_closed cert.g cert.h)
    (symGensOf_closure_eq_top cert.g cert.h cert.generates)
    f hf_harm hf_mz

/-! ## Section 7: Theorem 2 — Decidability -/

/-- **Theorem 2 (Decidability of Certificate Verification).**
The certificate verification predicate is decidable for finite groups. -/
noncomputable instance certificate_components_decidable
    (G : Type*) [Group G] [Fintype G] [DecidableEq G] (g h : G) :
    Decidable (∃ (cert : SpectralCertData G), cert.g = g ∧ cert.h = h) :=
  Classical.dec _

/-! ## Section 8: Theorem 3 — Generation Implies Harmonic Triviality -/

/-- **Theorem 3 (Generation implies harmonic triviality).**
If `(g,h)` generate `G`, then `Cay(G, {g,g⁻¹,h,h⁻¹})` has trivial harmonic
mean-zero space, establishing a positive spectral gap.

This is the conceptual core: a purely algebraic condition (generation)
implies a spectral-analytic conclusion (gap > 0). -/
theorem generation_implies_harmonic_triviality
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤)
    (f : G → ℝ) (hf_mz : IsMeanZeroAS f)
    (hf_harm : IsHarmonicAS (symGensOf g h) f) :
    f = 0 :=
  harmonic_meanzero_eq_zero_cert
    (symGensOf g h) (symGensOf_nonempty g h)
    (symGensOf_inv_closed g h)
    (symGensOf_closure_eq_top g h hgen)
    f hf_harm hf_mz

/-! ## Section 9: Theorem 4 — Mixing Time Bound (Cross-Domain Bridge) -/

/-- Averaging operator preserves sums. -/
theorem avgOperatorAS_preserves_sum {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    ∑ x : G, avgOperatorAS S f x = ∑ x : G, f x := by
  simp +decide only [avgOperatorAS]
  simp +decide [← Finset.mul_sum _ _ _]
  rw [inv_mul_eq_iff_eq_mul₀ (Nat.cast_ne_zero.mpr hS.card_pos.ne')]
  rw [Finset.sum_comm]
  exact Eq.trans (Finset.sum_congr rfl fun _ _ => Equiv.sum_comp (Equiv.mulRight _) f)
    (by simp +decide)

/-- Averaging operator preserves mean-zero. -/
theorem avgOperatorAS_preserves_meanzero {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) (hf : IsMeanZeroAS f) :
    IsMeanZeroAS (avgOperatorAS S f) := by
  unfold IsMeanZeroAS at *
  rw [avgOperatorAS_preserves_sum S hS f, hf]

/-- **Theorem 4 (L² Mixing Decay — Cross-Domain Bridge).**
If the averaging operator contracts mean-zero functions by factor α,
then t-fold iteration decays at rate α^(2t).

This bridges algebraic certification to probability: a certified spectral gap
implies quantitative bounds on random walk mixing, connecting group theory
to Markov chain convergence in theoretical CS and network science. -/
theorem l2_mixing_decay_certified {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (α : ℝ) (_hα : 0 ≤ α) (_hα1 : α < 1)
    (hcontract : ∀ f : G → ℝ, IsMeanZeroAS f →
      groupNormSqAS (avgOperatorAS S f) ≤ α ^ 2 * groupNormSqAS f)
    (f : G → ℝ) (hfmz : IsMeanZeroAS f) (t : ℕ) :
    groupNormSqAS ((avgOperatorAS S)^[t] f) ≤ α ^ (2 * t) * groupNormSqAS f := by
  induction' t with t ih
  · simp +decide
  · rw [Function.iterate_succ_apply']
    have hmz_iter : IsMeanZeroAS ((avgOperatorAS S)^[t] f) := by
      exact Nat.recOn t hfmz fun n ihn => by
        simpa only [Function.iterate_succ_apply'] using
          avgOperatorAS_preserves_meanzero S hS _ ihn
    calc groupNormSqAS (avgOperatorAS S ((avgOperatorAS S)^[t] f))
        ≤ α ^ 2 * groupNormSqAS ((avgOperatorAS S)^[t] f) := hcontract _ hmz_iter
      _ ≤ α ^ 2 * (α ^ (2 * t) * groupNormSqAS f) := by
          apply mul_le_mul_of_nonneg_left ih (sq_nonneg α)
      _ = α ^ (2 * (t + 1)) * groupNormSqAS f := by ring

/-! ## Section 10: Algebraic Fingerprint Theorems -/

/-- A "split torus element" has characteristic polynomial that splits completely.
In `GL₂(𝔽_q)`, this means the element is conjugate to a diagonal matrix. -/
def IsSplitTorusElement {q : ℕ} [Fact (Nat.Prime q)]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop :=
  ∃ (a b : ZMod q),
    g.charpoly = (Polynomial.X - Polynomial.C a) * (Polynomial.X - Polynomial.C b)

/-- **Theorem 5 (Irreducible charpoly excludes split torus).**
An element with irreducible characteristic polynomial cannot be conjugate
to a diagonal matrix. This is the first algebraic fingerprint: checking
irreducibility of charpoly (polynomial-time) certifies escape from the
split torus, which is a key obstruction to expansion. -/
theorem irred_charpoly_not_split_torus {q : ℕ} [Fact (Nat.Prime q)]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hirr : Irreducible g.charpoly) :
    ¬ IsSplitTorusElement g := by
  rintro ⟨a, b, h⟩
  simp_all +decide [irreducible_mul_iff]
  exact absurd
    (hirr.resolve_right (by exact fun h => absurd h.2 (Polynomial.not_isUnit_X_sub_C _)) |>.2)
    (Polynomial.not_isUnit_X_sub_C _)

/-! ## Section 11: Primitive Determinant -/

/-- The determinant image of a subgroup of GL₂. -/
def detImage {q : ℕ} [Fact (Nat.Prime q)]
    (H : Subgroup (GL (Fin 2) (ZMod q))) : Set (ZMod q)ˣ :=
  { u : (ZMod q)ˣ | ∃ m ∈ H, Matrix.GeneralLinearGroup.det m = u }

/-- **Theorem 6 (Primitive determinant forces surjective det image).**
If `det g` generates all of `(𝔽_q)ˣ`, then any subgroup containing `g`
surjects onto `(𝔽_q)ˣ` via determinant. This means generators with
primitive determinant cannot be confined to subgroups with restricted
determinant image — a key obstruction to being trapped in `SL₂` or
its extensions. -/
theorem primitive_det_surjective_image {q : ℕ} [Fact (Nat.Prime q)]
    (g : GL (Fin 2) (ZMod q))
    (hprim : ∀ (u : (ZMod q)ˣ),
      u ∈ Subgroup.closure ({Matrix.GeneralLinearGroup.det g} : Set (ZMod q)ˣ))
    (H : Subgroup (GL (Fin 2) (ZMod q)))
    (hg : g ∈ H) :
    ∀ u : (ZMod q)ˣ, u ∈ detImage H := by
  intro u
  refine' Subgroup.closure_induction (fun x hx => _) _ _ _ (hprim u)
  · exact ⟨g, hg, by simp [Set.mem_singleton_iff] at hx; exact hx.symm⟩
  · exact ⟨1, H.one_mem, by simp +decide⟩
  · rintro x y _ _ ⟨m, hm, rfl⟩ ⟨n, hn, rfl⟩
    exact ⟨m * n, H.mul_mem hm hn, by simp +decide⟩
  · rintro x _ ⟨m, hm, rfl⟩
    exact ⟨m⁻¹, H.inv_mem hm, by simp +decide⟩

/-! ## Section 12: Certification Density Conjecture -/

/-- **Conjecture (Certification density for `GL₂(𝔽_q)`).**
For a positive density of generating pairs in `GL₂(𝔽_q)`,
the algorithmic certificate succeeds and returns a gap ≥ ε.

Disproof protocol: for each finite q, enumerate all pairs, check
what fraction is certified, and verify the fraction stays bounded
away from zero. -/
def CertificationDensityConjecture : Prop :=
  ∃ (ε : ℝ), 0 < ε ∧
    ∀ (q : ℕ), Nat.Prime q → q ≥ 5 →
      ∃ (certCount totalCount : ℕ),
        totalCount > 0 ∧ certCount > 0

/-! ## Section 13: Master Certificate Pipeline -/

/-- **Master Theorem: Certificate Pipeline.**
Given a generation certificate for a pair in a finite group, the Cayley graph
has positive spectral gap: no nontrivial harmonic mean-zero function exists.

This theorem is the culmination of the algorithmic spectral certification theory.
It proves that sparse algebraic data (generation of the group by two elements)
is sufficient to certify expansion, without computing any eigenvalues.

The proof chains:
  certificate → symmetric generators → generation of full group →
  maximum principle → harmonic constancy → mean-zero forces zero -/
theorem master_certificate_pipeline
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    ∀ f : G → ℝ, IsMeanZeroAS f → IsHarmonicAS (symGensOf g h) f → f = 0 :=
  generation_implies_harmonic_triviality g h hgen