import Mathlib
import Bridges.UltrametricMyhillNerode.Defs

/-!
# Ultrametric Myhill–Nerode: Main Theorems

Non-Archimedean neural minimization: the ultrametric Myhill–Nerode theorem
for contractive state transition systems.

## Main Results

* `evalWord_nonexpanding` — wordwise nonexpansion
* `evalWord_contractive` — wordwise c^|w|-contraction
* `contractive_word_bound` — output bound L · c^|w| · dX(x,y)
* `obsEqInf_congr` — congruence (the Myhill–Nerode property)
* `obsEqInf_congr_word` — word-level congruence
* `finite_stabilization` — ∃ N, ObsEqK N ε → ObsEqInf ε
* `obsEqInfSetoid` — ObsEqInf is a setoid
* `minimal_quotient_factorization` — universal factorization (minimality)
-/

noncomputable section

open Function

variable {A X Y : Type*}

/-! ## §1. Wordwise Nonexpansion and Contraction -/

/-
Iterated transition along a word is nonexpanding.
-/
theorem evalWord_nonexpanding (S : UltrametricNeuralSystem A X Y)
    (w : List A) (x y : X) :
    S.dX (evalWord S.T w x) (evalWord S.T w y) ≤ S.dX x y := by
  induction' w with a w ih generalizing x y;
  · rfl;
  · exact le_trans ( ih _ _ ) ( S.nonexpanding _ _ _ )

/-
Iterated transition along a word is c^|w|-contractive.
-/
theorem evalWord_contractive (S : ContractiveUNS A X Y)
    (w : List A) (x y : X) :
    S.dX (evalWord S.T w x) (evalWord S.T w y) ≤ S.c ^ w.length * S.dX x y := by
  induction' w with a w ih generalizing x y <;> simp_all +decide [ pow_succ, mul_assoc ];
  exact le_trans ( ih _ _ ) ( mul_le_mul_of_nonneg_left ( S.contractive a x y ) ( pow_nonneg ( S.hc_nonneg ) _ ) )

/-
**Contractive word bound**: observational difference along any word `w`
    is bounded by `L · c^|w| · dX(x, y)`.
-/
theorem contractive_word_bound (S : ContractiveUNS A X Y)
    (w : List A) (x y : X) :
    S.dY (S.o (evalWord S.T w x)) (S.o (evalWord S.T w y))
      ≤ S.L * S.c ^ w.length * S.dX x y := by
  rw [ mul_assoc ];
  refine' le_trans ( S.o_lipschitz _ _ ) _;
  exact mul_le_mul_of_nonneg_left ( evalWord_contractive S w x y ) S.hL_nonneg

/-! ## §2. Equivalence Relation Properties -/

theorem ObsEqInf.refl (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (hε : 0 ≤ ε)
    (x : X) : ObsEqInf S ε x x := by
  exact fun w => by simpa [ S.dY_self ] using hε;

theorem ObsEqInf.symm (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    {x y : X} (h : ObsEqInf S ε x y) : ObsEqInf S ε y x := by
  exact fun w => by simpa only [ S.dY_symm ] using h w;

/-
Transitivity uses the ultrametric inequality on dY.
-/
theorem ObsEqInf.trans (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    {x y z : X} (hxy : ObsEqInf S ε x y) (hyz : ObsEqInf S ε y z) :
    ObsEqInf S ε x z := by
  exact fun w => le_trans ( S.dY_ultra _ _ _ ) ( max_le ( hxy w ) ( hyz w ) )

theorem ObsEqK.refl (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (hε : 0 ≤ ε)
    (k : ℕ) (x : X) : ObsEqK S ε k x x := by
  intro w hw; exact le_trans ( by simp [ S.dY_self ] ) hε;

theorem ObsEqK.symm (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (k : ℕ)
    {x y : X} (h : ObsEqK S ε k x y) : ObsEqK S ε k y x := by
  intro w hw; specialize h w hw; exact le_trans ( by rw [ S.dY_symm ] ) h;

theorem ObsEqK.trans (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (k : ℕ)
    {x y z : X} (hxy : ObsEqK S ε k x y) (hyz : ObsEqK S ε k y z) :
    ObsEqK S ε k x z := by
  intro w hw; exact le_trans ( S.dY_ultra _ _ _ ) ( max_le ( hxy w hw ) ( hyz w hw ) ) ;

/-! ## §3. Congruence — The Myhill–Nerode Property -/

/-
**Ultrametric Myhill–Nerode Congruence**: `ObsEqInf` is a congruence.
-/
theorem obsEqInf_congr (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    {x y : X} (h : ObsEqInf S ε x y) (a : A) :
    ObsEqInf S ε (S.T a x) (S.T a y) := by
  intro w;
  convert h ( a :: w ) using 1

/-
Congruence extends to words.
-/
theorem obsEqInf_congr_word (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    {x y : X} (h : ObsEqInf S ε x y) (w : List A) :
    ObsEqInf S ε (evalWord S.T w x) (evalWord S.T w y) := by
  induction' w with a w ih generalizing x y;
  · exact h;
  · exact ih ( obsEqInf_congr S ε h a )

/-
`ObsEqK (k+1)` implies ObsEqK k after one step.
-/
theorem obsEqK_congr_succ (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (k : ℕ)
    {x y : X} (h : ObsEqK S ε (k + 1) x y) (a : A) :
    ObsEqK S ε k (S.T a x) (S.T a y) := by
  intro w hw; specialize h ( a :: w ) ; simp_all +decide ;

/-! ## §4. Monotonicity -/

theorem obsEqInf_implies_obsEqK (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (k : ℕ)
    {x y : X} (h : ObsEqInf S ε x y) : ObsEqK S ε k x y := by
  exact fun w hw => h w

theorem obsEqK_mono (S : UltrametricNeuralSystem A X Y) (ε : ℝ) {k₁ k₂ : ℕ}
    (hk : k₁ ≤ k₂) {x y : X} (h : ObsEqK S ε k₂ x y) : ObsEqK S ε k₁ x y := by
  exact fun w hw => h w ( hw.trans hk )

theorem obsEqK_mono_eps (S : UltrametricNeuralSystem A X Y) {ε₁ ε₂ : ℝ}
    (hε : ε₁ ≤ ε₂) (k : ℕ) {x y : X} (h : ObsEqK S ε₁ k x y) :
    ObsEqK S ε₂ k x y := by
  exact fun w hw => le_trans ( h w hw ) hε

theorem obsEqInf_mono_eps (S : UltrametricNeuralSystem A X Y) {ε₁ ε₂ : ℝ}
    (hε : ε₁ ≤ ε₂) {x y : X} (h : ObsEqInf S ε₁ x y) :
    ObsEqInf S ε₂ x y := by
  exact fun w => le_trans ( h w ) hε

/-! ## §5. Finite Stabilization Under Contraction -/

/-
**Finite stabilization**: Under contraction on a bounded space,
    there exists N such that k-step equivalence at depth N implies full equivalence.

    Proof idea: Choose N so that L · c^N · D < ε. Then for any word w with |w| > N,
    write w = w₁ ++ w₂ with |w₁| = N. The first N steps are checked by ObsEqK,
    and the tail contributes at most L · c^N · D ≤ ε by the contractive bound.
    Since dY is ultrametric, max(≤ε, ≤ε) ≤ ε.
-/
theorem finite_stabilization
    (S : ContractiveUNS A X Y)
    (ε : ℝ) (hε : 0 < ε)
    (D : ℝ) (_hD : 0 ≤ D) (hDiam : ∀ x y, S.dX x y ≤ D) :
    ∃ N : ℕ, ∀ x y, ObsEqK S.toUltrametricNeuralSystem ε N x y →
      ObsEqInf S.toUltrametricNeuralSystem ε x y := by
  by_cases hL : S.L = 0 ∨ D = 0;
  · use 0;
    intro x y hxy w;
    have := contractive_word_bound S w x y;
    cases hL <;> simp_all +decide;
    · linarith;
    · exact this.trans ( by nlinarith [ hDiam x y, show 0 ≤ S.L * S.c ^ w.length by exact mul_nonneg ( S.hL_nonneg ) ( pow_nonneg S.hc_nonneg _ ) ] );
  · -- Choose N such that L * c^N * D ≤ ε.
    obtain ⟨N, hN⟩ : ∃ N : ℕ, S.L * S.c ^ N * D ≤ ε := by
      have h_contra : Filter.Tendsto (fun N => S.L * S.c ^ N * D) Filter.atTop (nhds 0) := by
        simpa using Filter.Tendsto.mul ( tendsto_const_nhds.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( S.hc_nonneg ) S.hc_lt_one ) ) tendsto_const_nhds;
      exact ( h_contra.eventually ( ge_mem_nhds hε ) ) |> fun h => h.exists;
    refine' ⟨ N, fun x y hxy => fun w => _ ⟩;
    by_cases hw : w.length ≤ N;
    · exact hxy w hw;
    · refine' le_trans _ hN;
      refine' le_trans _ ( mul_le_mul_of_nonneg_left ( hDiam _ _ ) _ );
      refine' le_trans ( contractive_word_bound S w x y ) _;
      refine' mul_le_mul_of_nonneg_right _ _;
      · exact mul_le_mul_of_nonneg_left ( pow_le_pow_of_le_one ( S.hc_nonneg ) ( S.hc_lt_one.le ) ( by linarith ) ) ( S.hL_nonneg );
      · exact S.dX_nonneg x y;
      · exact mul_nonneg ( S.hL_nonneg ) ( pow_nonneg ( S.hc_nonneg ) _ )

/-! ## §6. Canonical Minimal Quotient -/

/-- `ObsEqInf` defines a setoid on X (equivalence relation). -/
def obsEqInfSetoid (S : UltrametricNeuralSystem A X Y) (ε : ℝ) (hε : 0 ≤ ε) :
    Setoid X where
  r := ObsEqInf S ε
  iseqv := {
    refl := fun x => ObsEqInf.refl S ε hε x
    symm := fun h => ObsEqInf.symm S ε h
    trans := fun hxy hyz => ObsEqInf.trans S ε hxy hyz
  }

/-
Output is well-defined up to ε on the quotient:
    observation with the empty word.
-/
theorem obsEqInf_descent_output (S : UltrametricNeuralSystem A X Y) (ε : ℝ)
    {x y : X} (h : ObsEqInf S ε x y) :
    S.dY (S.o x) (S.o y) ≤ ε := by
  simpa using h []

/-
**Universal factorization** (Myhill–Nerode minimality):
    Any map `φ : X → Z` that respects `ObsEqInf ε` (i.e., equivalent states map to
    the same value) factors uniquely through the canonical quotient `X / ObsEqInf ε`.
    This is the universal property making `Q_ε` the coarsest semantics-preserving quotient.
-/
theorem minimal_quotient_factorization
    (S : UltrametricNeuralSystem A X Y)
    (ε : ℝ) (hε : 0 ≤ ε)
    (Z : Type*) (φ : X → Z)
    (hφ_compat : ∀ x y, ObsEqInf S ε x y → φ x = φ y) :
    ∃! ψ : @Quotient X (obsEqInfSetoid S ε hε) → Z,
      ∀ x, φ x = ψ (@Quotient.mk X (obsEqInfSetoid S ε hε) x) := by
  -- Define ψ as the function that maps each equivalence class to the value of φ on any representative.
  obtain ⟨ψ, hψ⟩ : ∃ ψ : Quotient (obsEqInfSetoid S ε hε) → Z, ∀ x, φ x = ψ ⟦x⟧ := by
    exact ⟨ fun q => Quotient.liftOn' q φ ( fun x y hxy => hφ_compat x y hxy ), fun x => rfl ⟩;
  refine' ⟨ ψ, hψ, fun ψ' hψ' => _ ⟩;
  ext q; obtain ⟨ x, rfl ⟩ := Quotient.exists_rep q; exact hψ' x ▸ hψ x ▸ rfl;

end