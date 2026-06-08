/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bounded Quantifier Extension and Verified Hrushovski Stabilizers

This file extends the restricted first-order formula language with bounded
quantifiers over definable sets, proves an inductive Łoś theorem for the
extended language, and formalizes transfer-ready stabilizer predicates.

## Main Results

* `los_boundedRestrictedFormula`: Łoś theorem for bounded restricted formulas
* `realize_boundedForall_iff_not_exists_not`: Classical duality for bounded quantifiers
* `cosetCover_compose`: Transitivity of coset covers
* `bounded_cover_implies_product_cover`: Cross-domain bridge theorem
* `los_mem_definablePred`: Definable membership transfer

## References

* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
* Breuillard, E., Green, B., Tao, T. (2012). The structure of approximate groups.
-/

import Mathlib

namespace BoundedPseudofiniteTransfer

open Filter MvPolynomial Set Pointwise

-- Convenience alias for non-dependent Fin.snoc
abbrev finSnoc {n : ℕ} {α : Type*} (v : Fin n → α) (x : α) : Fin (n+1) → α :=
  @Fin.snoc n (fun _ => α) v x

/-! ## Section 1: Restricted Formula Language (Base Layer) -/

/-- A restricted polynomial formula over variables of type `σ` with integer
coefficients. Quantifier-free fragment with polynomial equality atoms
and boolean connectives. -/
inductive RestrictedFormula (σ : Type*) : Type _
  | polyEq (p : MvPolynomial σ ℤ) : RestrictedFormula σ
  | conj (φ ψ : RestrictedFormula σ) : RestrictedFormula σ
  | disj (φ ψ : RestrictedFormula σ) : RestrictedFormula σ
  | neg (φ : RestrictedFormula σ) : RestrictedFormula σ

namespace RestrictedFormula

/-- Satisfaction of a restricted formula in a commutative ring `R`. -/
def Sat {σ : Type*} (R : Type*) [CommRing R] :
    RestrictedFormula σ → (σ → R) → Prop
  | polyEq p, v => MvPolynomial.eval₂ (Int.castRingHom R) v p = 0
  | conj φ ψ, v => φ.Sat R v ∧ ψ.Sat R v
  | disj φ ψ, v => φ.Sat R v ∨ ψ.Sat R v
  | neg φ, v => ¬ φ.Sat R v

end RestrictedFormula

/-! ## Section 2: Boolean Closure Lemmas for Ultrafilters -/

section BooleanClosure

variable {ι : Type*} (U : Ultrafilter ι)

theorem setOf_and_mem_iff {P Q : ι → Prop} :
    {i | P i ∧ Q i} ∈ U ↔ {i | P i} ∈ U ∧ {i | Q i} ∈ U := by
  constructor <;> intro h
  · exact ⟨Filter.mem_of_superset h fun i hi => hi.1,
           Filter.mem_of_superset h fun i hi => hi.2⟩
  · exact Filter.inter_mem h.1 h.2

theorem setOf_or_mem_iff {P Q : ι → Prop} :
    {i | P i ∨ Q i} ∈ U ↔ {i | P i} ∈ U ∨ {i | Q i} ∈ U := by
  constructor <;> intro h <;> simp_all +decide [Set.setOf_or]

theorem setOf_neg_mem_iff {P : ι → Prop} :
    {i | ¬ P i} ∈ U ↔ {i | P i} ∉ U := by
  exact Ultrafilter.compl_mem_iff_notMem

end BooleanClosure

/-! ## Section 3: Polynomial Evaluation Commutes with Germs -/

/-
Polynomial evaluation commutes with germ formation in the ultrapower.
-/
theorem eval₂_germ_eq_germ_eval₂
    {ι : Type*} (U : Ultrafilter ι) {K : Type*} [CommRing K] {σ : Type*}
    (p : MvPolynomial σ ℤ)
    (v : σ → ι → K) :
    MvPolynomial.eval₂ (Int.castRingHom (Germ (U : Filter ι) K))
      (fun s => (↑(v s) : Germ (U : Filter ι) K)) p =
    (↑(fun i => MvPolynomial.eval₂ (Int.castRingHom K) (fun s => v s i) p) :
      Germ (U : Filter ι) K) := by
  convert MvPolynomial.induction_on p _ _ _;
  rotate_left;
  use fun p => MvPolynomial.eval₂ ( Int.castRingHom ( U.Germ K ) ) ( fun s => ( v s : U.Germ K ) ) p = ( fun i => MvPolynomial.eval₂ ( Int.castRingHom K ) ( fun s => v s i ) p );
  · intro a; induction a using Int.induction_on <;> aesop;
  · aesop;
  · simp +contextual [ MvPolynomial.eval₂_mul ];
    exact fun p n hp => rfl;
  · rfl

/-! ## Section 4: Łoś's Theorem for Restricted Formulas -/

/-- **Łoś's Theorem (Restricted Version)**: satisfaction in the ultrapower
germ ring equals eventual componentwise satisfaction. -/
theorem los_restrictedFormula
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {σ : Type*}
    (φ : RestrictedFormula σ)
    (v : σ → ι → K) :
    RestrictedFormula.Sat (Germ (U : Filter ι) K) φ
      (fun s => (↑(v s) : Germ (U : Filter ι) K)) ↔
    {i | RestrictedFormula.Sat K φ (fun s => v s i)} ∈ U := by
  induction φ with
  | polyEq p =>
    simp only [RestrictedFormula.Sat]
    rw [eval₂_germ_eq_germ_eval₂]
    erw [Filter.Germ.coe_eq]
    rfl
  | conj φ ψ hφ hψ =>
    simp only [RestrictedFormula.Sat, hφ, hψ]
    rw [← setOf_and_mem_iff]
  | disj φ ψ hφ hψ =>
    simp only [RestrictedFormula.Sat, hφ, hψ]
    rw [← setOf_or_mem_iff]
  | neg φ hφ =>
    simp only [RestrictedFormula.Sat, hφ]
    exact Iff.symm (setOf_neg_mem_iff U)

/-! ## Section 5: Bounded Existential Transfer -/

/-- Bounded existential transfer: from eventual existence to consistent choice. -/
theorem los_exists_bounded
    {ι : Type*} {U : Ultrafilter ι}
    {α : ι → Type*} [∀ i, Nonempty (α i)]
    (P : ∀ i, α i → Prop)
    (h : {i | ∃ x, P i x} ∈ U) :
    ∃ x : ∀ i, α i, {i | P i (x i)} ∈ U := by
  by_contra h_contra
  push_neg at h_contra
  have h_exists_x : ∀ i ∈ {i | ∃ x, P i x}, ∃ x_i, P i x_i :=
    fun i hi => hi
  choose! x hx using h_exists_x
  exact h_contra x (Filter.mem_of_superset h fun i hi => hx i hi)

/-! ## Section 6: Bounded Restricted Formula Language -/

/-- Extended restricted formula language with bounded quantifiers.
Indexed by `n`, the number of free variables (`Fin n`).
Bounded quantifiers bind a new variable at position `Fin.last n`. -/
inductive BoundedRestrictedFormula : ℕ → Type 1
  | base {n} : RestrictedFormula (Fin n) → BoundedRestrictedFormula n
  | conj {n} : BoundedRestrictedFormula n → BoundedRestrictedFormula n →
      BoundedRestrictedFormula n
  | disj {n} : BoundedRestrictedFormula n → BoundedRestrictedFormula n →
      BoundedRestrictedFormula n
  | neg {n} : BoundedRestrictedFormula n → BoundedRestrictedFormula n
  | boundedExists {n} : RestrictedFormula (Fin (n+1)) →
      BoundedRestrictedFormula (n+1) → BoundedRestrictedFormula n
  | boundedForall {n} : RestrictedFormula (Fin (n+1)) →
      BoundedRestrictedFormula (n+1) → BoundedRestrictedFormula n

namespace BoundedRestrictedFormula

/-- Satisfaction of a bounded restricted formula in a commutative ring. -/
def Realize {n : ℕ} (R : Type*) [CommRing R] :
    BoundedRestrictedFormula n → (Fin n → R) → Prop
  | base φ, v => φ.Sat R v
  | conj φ ψ, v => φ.Realize R v ∧ ψ.Realize R v
  | disj φ ψ, v => φ.Realize R v ∨ ψ.Realize R v
  | neg φ, v => ¬ φ.Realize R v
  | boundedExists D body, v =>
      ∃ x : R, D.Sat R (finSnoc v x) ∧ body.Realize R (finSnoc v x)
  | boundedForall D body, v =>
      ∀ x : R, D.Sat R (finSnoc v x) → body.Realize R (finSnoc v x)

/-- Bounded existential realization. -/
theorem realize_boundedExists_iff {n : ℕ} {R : Type*} [CommRing R]
    (D : RestrictedFormula (Fin (n+1)))
    (φ : BoundedRestrictedFormula (n+1))
    (v : Fin n → R) :
    (boundedExists D φ).Realize R v ↔
      ∃ x : R, D.Sat R (finSnoc v x) ∧ φ.Realize R (finSnoc v x) := by
  rfl

/-- Bounded universal realization. -/
theorem realize_boundedForall_iff {n : ℕ} {R : Type*} [CommRing R]
    (D : RestrictedFormula (Fin (n+1)))
    (φ : BoundedRestrictedFormula (n+1))
    (v : Fin n → R) :
    (boundedForall D φ).Realize R v ↔
      ∀ x : R, D.Sat R (finSnoc v x) → φ.Realize R (finSnoc v x) := by
  rfl

/-- **Classical duality**: bounded universal equals negation of bounded
existential of negation. -/
theorem realize_boundedForall_iff_not_exists_not {n : ℕ}
    {R : Type*} [CommRing R]
    (D : RestrictedFormula (Fin (n+1)))
    (φ : BoundedRestrictedFormula (n+1))
    (v : Fin n → R) :
    (boundedForall D φ).Realize R v ↔
      ¬ (boundedExists D (neg φ)).Realize R v := by
  simp only [Realize]
  push_neg
  rfl

/-- Formula complexity: total number of constructors. -/
def complexity : {n : ℕ} → BoundedRestrictedFormula n → ℕ
  | _, base _ => 1
  | _, conj φ ψ => 1 + φ.complexity + ψ.complexity
  | _, disj φ ψ => 1 + φ.complexity + ψ.complexity
  | _, neg φ => 1 + φ.complexity
  | _, boundedExists _ body => 1 + body.complexity
  | _, boundedForall _ body => 1 + body.complexity

end BoundedRestrictedFormula

/-! ## Section 7: Fin.snoc Germ Compatibility -/

/-- `finSnoc` commutes with germ formation componentwise. -/
theorem finSnoc_germ_eq {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K] {n : ℕ}
    (v : Fin n → ι → K) (w : ι → K) (j : Fin (n + 1)) :
    finSnoc (fun k => (↑(v k) : Germ (U : Filter ι) K))
        (↑w : Germ (U : Filter ι) K) j =
    (↑(fun i => finSnoc (fun k => v k i) (w i) j) : Germ (U : Filter ι) K) := by
  simp only [finSnoc]
  refine Fin.lastCases ?_ ?_ j
  · simp [Fin.snoc_last]
  · intro k; simp [Fin.snoc_castSucc]

/-! ## Section 8: Łoś's Theorem for Bounded Restricted Formulas -/

/-
**Łoś's Theorem for Bounded Restricted Formulas.**
Satisfaction in the ultrapower germ ring is equivalent to
the satisfaction set being in the ultrafilter.
-/
theorem los_boundedRestrictedFormula
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {n : ℕ}
    (φ : BoundedRestrictedFormula n)
    (v : Fin n → ι → K) :
    BoundedRestrictedFormula.Realize (Germ (U : Filter ι) K) φ
      (fun k => (↑(v k) : Germ (U : Filter ι) K)) ↔
    {i | BoundedRestrictedFormula.Realize K φ (fun k => v k i)} ∈ U := by
  induction' φ with n φ ih ih₁ ih₂;
  all_goals simp_all +decide [ BoundedRestrictedFormula.Realize ];
  exact?;
  · rw [ ← setOf_and_mem_iff ];
  · simp +decide [ setOf_or_mem_iff ];
  · rw [ ← Ultrafilter.compl_mem_iff_notMem ];
    rfl;
  · constructor <;> intro h;
    · obtain ⟨ x, hx₁, hx₂ ⟩ := h;
      -- By definition of germ, there exists a representative $w : ι → K$ such that $x = ↑w$.
      obtain ⟨ w, hw ⟩ : ∃ w : ι → K, x = ↑w := by
        exact ⟨ _, Eq.symm ( Quotient.out_eq' x ) ⟩;
      have hD : {i | RestrictedFormula.Sat K ‹RestrictedFormula (Fin (Nat.succ _))› (finSnoc (fun k => v k i) (w i))} ∈ U := by
        rw [ ← los_restrictedFormula ];
        convert hx₁ using 1;
        ext s; simp +decide [ hw, finSnoc_germ_eq ] ;
      rename_i k hk₁ hk₂;
      have h_body : {i | BoundedRestrictedFormula.Realize K hk₁ (finSnoc (fun k => v k i) (w i))} ∈ U := by
        convert hk₂ ( fun k i => if h : k.val < _ then v ⟨ k.val, h ⟩ i else w i ) |>.1 _ using 1;
        convert hx₂ using 1;
        ext k; simp +decide [ finSnoc, hw ] ;
        refine' Fin.lastCases _ _ k <;> simp +decide [ Fin.snoc ];
      exact Filter.mem_of_superset ( Filter.inter_mem hD h_body ) fun i hi => ⟨ w i, hi.1, hi.2 ⟩;
    · rename_i n φ ih;
      have := los_exists_bounded ( fun i => { x : K | RestrictedFormula.Sat K n ( finSnoc ( fun k => v k i ) x ) ∧ BoundedRestrictedFormula.Realize K φ ( finSnoc ( fun k => v k i ) x ) } ) h;
      obtain ⟨ w, hw ⟩ := this;
      refine' ⟨ ↑w, _, _ ⟩;
      · convert los_restrictedFormula n ( fun k => if h : k.val < _ then v ( Fin.castLT k h ) else w ) |>.2 _ using 1;
        · ext i; simp +decide [ finSnoc ] ;
          split_ifs <;> simp +decide [ *, Fin.snoc ];
        · refine' Filter.mem_of_superset hw _;
          intro i hi; specialize hi; simp_all +decide [ finSnoc ] ;
          convert hi.1 using 1;
          ext s; simp +decide [ Fin.snoc ] ;
          split_ifs <;> rfl;
      · convert ih ( fun k i => if h : k.val < _ then v ⟨ k.val, h ⟩ i else w i ) |>.2 _ using 1;
        · ext k; induction k using Fin.lastCases <;> simp +decide [ *, finSnoc ] ;
        · refine' Filter.mem_of_superset hw _;
          intro i hi; convert hi.2 using 1;
  · constructor <;> intro h;
    · contrapose! h;
      -- By definition of ultrafilter, there exists some $x$ such that $D.Sat K (finSnoc (v·i) (x i))$ and $\neg body.Realize K (finSnoc (v·i) (x i))$ for almost all $i$.
      obtain ⟨x, hx⟩ : ∃ x : ι → K, {i | RestrictedFormula.Sat K ‹_› (finSnoc (fun k => v k i) (x i)) ∧ ¬ BoundedRestrictedFormula.Realize K ‹_› (finSnoc (fun k => v k i) (x i))} ∈ U := by
        have h_exists_x : {i | ∃ x : K, RestrictedFormula.Sat K ‹_› (finSnoc (fun k => v k i) x) ∧ ¬ BoundedRestrictedFormula.Realize K ‹_› (finSnoc (fun k => v k i) x)} ∈ U := by
          convert U.compl_mem_iff_notMem.mpr h using 1;
          ext; simp +decide [ Classical.not_forall ] ;
        convert los_exists_bounded _ _;
        rotate_left;
        exact fun _ => ⟨ 0 ⟩;
        use fun i x => RestrictedFormula.Sat K ‹_› ( finSnoc ( fun k => v k i ) x ) ∧ ¬ BoundedRestrictedFormula.Realize K ‹_› ( finSnoc ( fun k => v k i ) x );
        · exact h_exists_x;
        · convert Iff.rfl;
      refine' ⟨ ↑x, _, _ ⟩;
      · convert los_restrictedFormula ‹_› _;
        any_goals exact fun k i => if hk : k.val < ‹ℕ› then v ⟨ k.val, hk ⟩ i else x i;
        any_goals exact U;
        all_goals try infer_instance;
        convert los_restrictedFormula ‹_› _;
        any_goals exact fun k i => if hk : k.val < ‹ℕ› then v ⟨ k.val, hk ⟩ i else x i;
        · rename_i k;
          refine' Fin.lastCases _ _ k <;> simp +decide [ finSnoc ];
        · rw [ los_restrictedFormula ];
          simp +decide [ Fin.snoc ];
          exact Filter.mem_of_superset hx fun i hi => by simpa [ finSnoc ] using hi.1;
      · rename_i k hk ih;
        rw [ show ( finSnoc ( fun k => ↑ ( v k ) ) ↑x : Fin ( _ + 1 ) → Germ ( U : Filter ι ) K ) = fun k => ↑ ( fun i => finSnoc ( fun k => v k i ) ( x i ) k ) from funext fun k => finSnoc_germ_eq _ _ _ ];
        rw [ ih ];
        exact fun h' => hx |> fun h'' => by have := Filter.inter_mem h'' h'; obtain ⟨ i, hi₁, hi₂ ⟩ := Filter.nonempty_of_mem this; exact hi₁.2 hi₂;
    · intro x hx;
      obtain ⟨ w, hw ⟩ := Quotient.exists_rep x;
      convert ‹∀ ( v : Fin ( _ + 1 ) → ι → K ), ( BoundedRestrictedFormula.Realize ( ( U : Filter ι ).Germ K ) _ fun k => ↑ ( v k ) ) ↔ { i | BoundedRestrictedFormula.Realize K _ fun k => v k i } ∈ U› ( fun k i => finSnoc ( fun k => v k i ) ( w i ) k ) |>.2 _;
      · convert finSnoc_germ_eq v w _;
        exact hw.symm;
      · have h_eventually : {i | RestrictedFormula.Sat K ‹RestrictedFormula (Fin (Nat.succ _))› (finSnoc (fun k => v k i) (w i))} ∈ U := by
          convert los_restrictedFormula ‹RestrictedFormula ( Fin ( _ + 1 ) ) › ( fun k => if h : k.val < _ then v ⟨ k.val, h ⟩ else w ) |>.1 _ using 1;
          · congr! 3;
            ext i; simp +decide [ finSnoc ] ;
            split_ifs <;> simp +decide [ *, Fin.snoc ];
            congr! 2;
          · convert hx using 1;
            ext s; simp +decide [ finSnoc, hw.symm ] ;
            split_ifs <;> simp +decide [ *, Fin.snoc ];
            · rfl;
            · exact hw;
        exact Filter.mem_of_superset ( Filter.inter_mem h h_eventually ) fun i hi => hi.1 _ hi.2

/-! ## Section 9: Coset Cover Predicates -/

/-- A set `A` is covered by at most `C` left cosets of `H`. -/
def CoversByLeftCosets {G : Type*} [Mul G] (A H : Set G) (C : ℕ) : Prop :=
  ∃ T : Finset G, T.card ≤ C ∧ A ⊆ ⋃ t ∈ (T : Set G), (fun x => t * x) '' H

/-- Pseudofinite coset cover property. -/
def UltraCoversByLeftCosets
    {ι : Type*} (U : Ultrafilter ι)
    {G : ι → Type*} [∀ i, Mul (G i)]
    (A H : ∀ i, Set (G i)) (C : ℕ) : Prop :=
  {i | CoversByLeftCosets (A i) (H i) C} ∈ U

/-- Coset cover transfer. -/
theorem cosetCover_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Mul (G i)]
    (A H : ∀ i, Set (G i)) (C : ℕ)
    (hcov : {i | CoversByLeftCosets (A i) (H i) C} ∈ U) :
    UltraCoversByLeftCosets U A H C :=
  hcov

/-! ## Section 10: Approximate Subgroup Proxy -/

/-- A `K`-approximate subgroup proxy. -/
structure IsApproxSubgroupProxy {G : Type*} [Group G] (H : Set G) (K : ℕ) : Prop where
  nonempty : H.Nonempty
  symmetric : ∀ h, h ∈ H → h⁻¹ ∈ H
  doubling_cover : CoversByLeftCosets (H * H) H K

/-- Coset cover monotonicity. -/
theorem cosetCover_mono {G : Type*} [Mul G]
    {A B H : Set G} {C : ℕ}
    (hAB : A ⊆ B) (hBH : CoversByLeftCosets B H C) :
    CoversByLeftCosets A H C := by
  obtain ⟨T, hT, hcov⟩ := hBH
  exact ⟨T, hT, Subset.trans hAB hcov⟩

/-- **Coset cover composition**: transitivity of coset coverings.
If `A` is covered by `C` left cosets of `H`, and `H` is covered by
`D` left cosets of `K`, then `A` is covered by `C * D` left cosets of `K`. -/
theorem cosetCover_compose {G : Type*} [Group G]
    (A H K : Set G) (C D : ℕ)
    (hAH : CoversByLeftCosets A H C)
    (hHK : CoversByLeftCosets H K D) :
    CoversByLeftCosets A K (C * D) := by
  classical
  obtain ⟨T₁, hT₁card, hT₁cov⟩ := hAH
  obtain ⟨T₂, hT₂card, hT₂cov⟩ := hHK
  refine ⟨(T₁ ×ˢ T₂).image (fun p => p.1 * p.2), ?_, ?_⟩
  · calc ((T₁ ×ˢ T₂).image (fun p => p.1 * p.2)).card
        ≤ (T₁ ×ˢ T₂).card := Finset.card_image_le
      _ = T₁.card * T₂.card := Finset.card_product T₁ T₂
      _ ≤ C * D := Nat.mul_le_mul hT₁card hT₂card
  · intro a ha
    have ha' := hT₁cov ha
    simp only [mem_iUnion, mem_image, Finset.mem_coe] at ha' ⊢
    obtain ⟨t₁, ht₁, h, hh, heq1⟩ := ha'
    have hh' := hT₂cov hh
    simp only [mem_iUnion, mem_image, Finset.mem_coe] at hh'
    obtain ⟨t₂, ht₂, k, hk, heq2⟩ := hh'
    refine ⟨t₁ * t₂, ?_, k, hk, ?_⟩
    · exact Finset.mem_image.mpr ⟨(t₁, t₂), Finset.mem_product.mpr ⟨ht₁, ht₂⟩, rfl⟩
    · rw [← heq1, ← heq2, mul_assoc]

/-- **Cross-domain bridge (abelian case)**: bounded cover + approximate
subgroup yields product set cover control in a commutative group.

For a ∈ A with a = t₁·h₁ and b ∈ A with b = t₂·h₂, we get
a·b = (t₁·t₂)·(h₁·h₂), and h₁·h₂ ∈ H·H is covered by K cosets of H.
Commutativity is essential for the rearrangement a·b = (t₁·t₂)·(h₁·h₂). -/
theorem bounded_cover_implies_product_cover {G : Type*} [CommGroup G]
    (A H : Set G) (C K : ℕ)
    (hcov : CoversByLeftCosets A H C)
    (hH : IsApproxSubgroupProxy H K) :
    CoversByLeftCosets (A * A) H (C * C * K) := by
  classical
  obtain ⟨T, hTcard, hTcov⟩ := hcov
  obtain ⟨S, hScard, hScov⟩ := hH.doubling_cover
  refine ⟨((T ×ˢ T) ×ˢ S).image (fun p => p.1.1 * p.1.2 * p.2), ?_, ?_⟩
  · calc (((T ×ˢ T) ×ˢ S).image _).card
        ≤ ((T ×ˢ T) ×ˢ S).card := Finset.card_image_le
      _ = (T ×ˢ T).card * S.card := Finset.card_product _ _
      _ = T.card * T.card * S.card := by rw [Finset.card_product]
      _ ≤ C * C * K := Nat.mul_le_mul (Nat.mul_le_mul hTcard hTcard) hScard
  · intro a ha
    obtain ⟨a₁, ha₁, a₂, ha₂, rfl⟩ := Set.mem_mul.mp ha
    have h₁ := hTcov ha₁; have h₂ := hTcov ha₂
    simp only [mem_iUnion, mem_image, Finset.mem_coe] at h₁ h₂ ⊢
    obtain ⟨t₁, ht₁, h₁, hh₁, heq1⟩ := h₁
    obtain ⟨t₂, ht₂, h₂, hh₂, heq2⟩ := h₂
    have hh12 : h₁ * h₂ ∈ H * H := Set.mem_mul.mpr ⟨h₁, hh₁, h₂, hh₂, rfl⟩
    have h_cov := hScov hh12
    simp only [mem_iUnion, mem_image, Finset.mem_coe] at h_cov
    obtain ⟨s, hs, h, hh, heq3⟩ := h_cov
    refine ⟨t₁ * t₂ * s, ?_, h, hh, ?_⟩
    · exact Finset.mem_image.mpr ⟨((t₁, t₂), s),
        Finset.mem_product.mpr ⟨Finset.mem_product.mpr ⟨ht₁, ht₂⟩, hs⟩, rfl⟩
    · rw [← heq1, ← heq2]
      have step1 : t₁ * t₂ * s * h = t₁ * t₂ * (s * h) := mul_assoc _ _ _
      rw [step1, heq3]
      simp [mul_comm, mul_left_comm]

/-! ## Section 11: Growth-or-Control Dichotomy Transfer -/

/-- **Growth-or-Control Dichotomy Transfer**. -/
theorem pseudofinite_growth_control_transfer
    {ι : Type*} {U : Ultrafilter ι}
    {G : ι → Type*} [∀ i, Mul (G i)]
    (A H : ∀ i, Set (G i))
    (K C : ℕ)
    (cardA cardAA : ι → ℕ)
    (hdich : {i | cardAA i ≤ K * cardA i →
      CoversByLeftCosets (A i) (H i) C} ∈ U)
    (hsmall : {i | cardAA i ≤ K * cardA i} ∈ U) :
    UltraCoversByLeftCosets U A H C :=
  U.mem_of_superset (Filter.inter_mem hsmall hdich) fun _ hi => hi.2 hi.1

/-! ## Section 12: Definable Membership Transfer -/

/-
Membership in a definable predicate transfers through the ultraproduct.
-/
theorem los_mem_definablePred
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {n : ℕ}
    (D : RestrictedFormula (Fin (n + 1)))
    (v : Fin n → ι → K) (w : ι → K) :
    D.Sat (Germ (U : Filter ι) K)
      (finSnoc (fun k => (↑(v k) : Germ (U : Filter ι) K))
        (↑w : Germ (U : Filter ι) K)) ↔
    {i | D.Sat K (finSnoc (fun k => v k i) (w i))} ∈ U := by
  convert los_restrictedFormula D ( fun j => fun i => if h : j.val < n then ( v ⟨ j.val, h ⟩ i ) else ( w i ) ) using 1;
  convert Iff.rfl;
  rename_i k; induction k using Fin.lastCases <;> simp +decide [*, finSnoc]

end BoundedPseudofiniteTransfer