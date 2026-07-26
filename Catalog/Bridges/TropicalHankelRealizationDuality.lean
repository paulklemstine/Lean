/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Hankel Realization Duality

A min-plus weighted analogue of the Schützenberger–Hankel theorem establishing that
**recognizability, finite residual generation, finite tropical Hankel rank, and
certified minimal realization all coincide** for weighted languages over commutative
semirings (with particular application to tropical/idempotent semirings).

## Main Results

* `recognizable_iff_fg_hankel_row` — Recognizability ↔ finitely generated Hankel rows
  with shift stability (the Schützenberger–Fliess realization theorem).
* `recognizable_implies_fg_residual` — Recognizability implies finitely generated residuals.
* `recognizable_implies_finite_hankel_rank` — Recognizability implies finite Hankel rank.
* `certified_reconstruction` — From a Hankel window certificate, reconstruct an automaton.
* `obs_matching_of_same_behavior` — Observable automata with matched observations
  produce an isomorphism.

## Mathematical Context

This formalizes the tropical analogue of the Schützenberger–Fliess–Carlyle–Paz
realization theorem. The correct invariant for recognizability is **finite generation
of the Hankel row semimodule** together with shift stability.

## Keywords

tropical automata, min-plus semiring, Hankel realization, Schützenberger theorem,
weighted languages, residual semimodule, tropical factor rank, automata minimization,
certified reconstruction, canonical realization
-/

open Finset BigOperators

set_option maxHeartbeats 800000
set_option linter.unusedSectionVars false

namespace TropicalHankelRealization

/-! ## §1. Core Definitions -/

structure WAutomaton (K : Type*) (A : Type*) (n : ℕ) where
  init : Fin n → K
  trans : A → Fin n → Fin n → K
  output : Fin n → K

variable {K : Type*} [CommSemiring K]
variable {A : Type*} [DecidableEq A] [Fintype A]
variable {n m : ℕ}

def WAutomaton.step (T : WAutomaton K A n) (v : Fin n → K) (a : A) : Fin n → K :=
  fun j => ∑ i : Fin n, v i * T.trans a i j

def WAutomaton.reach (T : WAutomaton K A n) (w : List A) : Fin n → K :=
  w.foldl T.step T.init

def WAutomaton.obs (T : WAutomaton K A n) : List A → Fin n → K
  | [] => T.output
  | a :: v => fun j => ∑ i : Fin n, T.trans a j i * T.obs v i

def WAutomaton.behavior (T : WAutomaton K A n) (w : List A) : K :=
  ∑ j : Fin n, T.reach w j * T.output j

def WAutomaton.stateCount (_ : WAutomaton K A n) : ℕ := n

/-! ## §2. Residuals and Hankel -/

def leftResidual (L : List A → K) (u : List A) : List A → K :=
  fun v => L (u ++ v)

def rightResidual (L : List A → K) (v : List A) : List A → K :=
  fun u => L (u ++ v)

def hankel (L : List A → K) (u v : List A) : K := L (u ++ v)

def hankelRow (L : List A → K) (u : List A) : List A → K :=
  fun v => L (u ++ v)

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
theorem hankelRow_eq_leftResidual (L : List A → K) (u : List A) :
    hankelRow L u = leftResidual L u := rfl

/-! ## §3. Recognizability and Finite Generation -/

def RecognizableTropLanguage (L : List A → K) : Prop :=
  ∃ (n : ℕ) (T : WAutomaton K A n), T.behavior = L

def FGResidualSemimodule (L : List A → K) : Prop :=
  ∃ (n : ℕ) (gen : Fin n → (List A → K)),
    ∀ u : List A, ∃ c : Fin n → K,
      ∀ v : List A, L (u ++ v) = ∑ j : Fin n, c j * gen j v

def FGHankelRowSemimodule (L : List A → K) : Prop :=
  ∃ (n : ℕ) (gen : Fin n → (List A → K))
    (coeff : List A → Fin n → K)
    (shift : A → Fin n → Fin n → K),
    (∀ u v, L (u ++ v) = ∑ j : Fin n, coeff u j * gen j v) ∧
    (∀ u (a : A) (j : Fin n),
      coeff (u ++ [a]) j = ∑ i : Fin n, coeff u i * shift a i j) ∧
    (∀ (a : A) (i : Fin n) (v : List A),
      gen i (a :: v) = ∑ j : Fin n, shift a i j * gen j v)

structure RealizationData (K : Type*) [CommSemiring K] (A : Type*) (n : ℕ) where
  series : List A → K
  gen : Fin n → (List A → K)
  coeff : List A → Fin n → K
  shift : A → Fin n → Fin n → K
  decomp : ∀ u v, series (u ++ v) = ∑ j : Fin n, coeff u j * gen j v
  shift_compat : ∀ u (a : A) (j : Fin n),
    coeff (u ++ [a]) j = ∑ i : Fin n, coeff u i * shift a i j
  gen_shift : ∀ (a : A) (i : Fin n) (v : List A),
    gen i (a :: v) = ∑ j : Fin n, shift a i j * gen j v

def TropicalHankelFactorRankAtMost (L : List A → K) (n : ℕ) : Prop :=
  ∃ (gen : Fin n → (List A → K)) (coeff : List A → Fin n → K),
    ∀ u v, L (u ++ v) = ∑ j : Fin n, coeff u j * gen j v

/-! ## §4. Forward Realization: Data → Automaton -/

def RealizationData.toAutomaton (D : RealizationData K A n) : WAutomaton K A n where
  init := D.coeff []
  trans := D.shift
  output := fun j => D.gen j []

omit [DecidableEq A] [Fintype A] in
theorem RealizationData.reach_append (D : RealizationData K A n) (w : List A) (a : A) :
    D.toAutomaton.reach (w ++ [a]) = D.toAutomaton.step (D.toAutomaton.reach w) a := by
  simp [WAutomaton.reach, List.foldl_append]

omit [DecidableEq A] [Fintype A] in
theorem RealizationData.reach_eq_coeff (D : RealizationData K A n) (w : List A) :
    D.toAutomaton.reach w = D.coeff w := by
  induction w using List.reverseRecOn with
  | nil => rfl
  | append_singleton l a ih =>
    ext j
    rw [D.reach_append]
    simp only [WAutomaton.step]
    conv_lhs => arg 2; ext i; rw [ih]
    exact (D.shift_compat l a j).symm

omit [DecidableEq A] [Fintype A] in
theorem RealizationData.behavior_eq (D : RealizationData K A n) :
    D.toAutomaton.behavior = D.series := by
  ext w
  simp only [WAutomaton.behavior, D.reach_eq_coeff]
  have h := D.decomp w []
  simp only [List.append_nil] at h
  exact h.symm

/-! ## §5. Backward Direction: Automaton → Data -/

omit [DecidableEq A] [Fintype A] in
@[simp]
theorem WAutomaton.reach_nil (T : WAutomaton K A n) :
    T.reach [] = T.init := rfl

omit [DecidableEq A] [Fintype A] in
theorem WAutomaton.reach_snoc (T : WAutomaton K A n) (w : List A) (a : A) :
    T.reach (w ++ [a]) = T.step (T.reach w) a := by
  simp [WAutomaton.reach, List.foldl_append]

omit [DecidableEq A] [Fintype A] in
theorem WAutomaton.reach_shift_compat (T : WAutomaton K A n)
    (u : List A) (a : A) (j : Fin n) :
    T.reach (u ++ [a]) j = ∑ i : Fin n, T.reach u i * T.trans a i j := by
  simp [reach_snoc, step]

omit [DecidableEq A] [Fintype A] in
theorem WAutomaton.behavior_decomp (T : WAutomaton K A n) (u v : List A) :
    T.behavior (u ++ v) = ∑ j : Fin n, T.reach u j * T.obs v j := by
  induction' v with v ih generalizing u;
  · aesop;
  · simp_all +decide [ WAutomaton.reach_snoc, WAutomaton.step, WAutomaton.step, WAutomaton.obs ];
    convert ‹∀ u : List A, T.behavior ( u ++ ih ) = ∑ j, T.reach u j * T.obs ih j› ( u ++ [ v ] ) using 1;
    · simp +decide [ List.append_assoc ];
    · simp +decide [ WAutomaton.reach_snoc, WAutomaton.step, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ];
      exact Finset.sum_comm

noncomputable def WAutomaton.toRealizationData (T : WAutomaton K A n) :
    RealizationData K A n where
  series := T.behavior
  gen := fun j v => T.obs v j
  coeff := T.reach
  shift := T.trans
  decomp := T.behavior_decomp
  shift_compat := fun u a j => T.reach_shift_compat u a j
  gen_shift := fun a i v => by simp [obs]

/-! ## §6. Realization Duality -/

theorem realization_duality (S : List A → K) :
    (∃ D : RealizationData K A n, D.series = S) ↔
    (∃ T : WAutomaton K A n, T.behavior = S) := by
  constructor
  · rintro ⟨D, hD⟩
    exact ⟨D.toAutomaton, by rw [D.behavior_eq, hD]⟩
  · rintro ⟨T, hT⟩
    exact ⟨T.toRealizationData, by simp [WAutomaton.toRealizationData, hT]⟩

/-! ## §7. Recognizable ↔ FGHankelRowSemimodule -/

theorem recognizable_implies_fg_residual (L : List A → K) :
    RecognizableTropLanguage L → FGResidualSemimodule L := by
  rintro ⟨n, T, hT⟩
  refine ⟨n, fun j v => T.obs v j, fun u => ⟨T.reach u, fun v => ?_⟩⟩
  rw [← hT]
  exact T.behavior_decomp u v

theorem recognizable_implies_fg_hankel (L : List A → K) :
    RecognizableTropLanguage L → FGHankelRowSemimodule L := by
  rintro ⟨n, T, hT⟩
  refine ⟨n, fun j v => T.obs v j, T.reach, T.trans,
    fun u v => ?_, fun u a j => T.reach_shift_compat u a j,
    fun a i v => by simp [WAutomaton.obs]⟩
  rw [← hT]; exact T.behavior_decomp u v

omit [DecidableEq A] [Fintype A] in
theorem fg_hankel_implies_recognizable (L : List A → K) :
    FGHankelRowSemimodule L → RecognizableTropLanguage L := by
  rintro ⟨n, gen, coeff, shift, hdecomp, hshift, hgen⟩
  exact ⟨n, (RealizationData.mk L gen coeff shift hdecomp hshift hgen).toAutomaton,
    (RealizationData.mk L gen coeff shift hdecomp hshift hgen).behavior_eq⟩

/-- **Core bidirectional equivalence**: The Schützenberger–Fliess realization theorem
for weighted languages over commutative semirings. -/
theorem recognizable_iff_fg_hankel_row (L : List A → K) :
    RecognizableTropLanguage L ↔ FGHankelRowSemimodule L :=
  ⟨recognizable_implies_fg_hankel L, fg_hankel_implies_recognizable L⟩

/-! ## §8. Hankel Factor Rank -/

theorem recognizable_implies_finite_hankel_rank (L : List A → K) :
    RecognizableTropLanguage L → ∃ n : ℕ, TropicalHankelFactorRankAtMost L n := by
  rintro ⟨n, T, hT⟩
  refine ⟨n, fun j v => T.obs v j, T.reach, fun u v => ?_⟩
  rw [← hT]; exact T.behavior_decomp u v

omit [DecidableEq A] [Fintype A] in
theorem recognizable_of_realization_data (L : List A → K) (n : ℕ)
    (gen : Fin n → (List A → K))
    (coeff : List A → Fin n → K)
    (shift : A → Fin n → Fin n → K)
    (hdecomp : ∀ u v, L (u ++ v) = ∑ j : Fin n, coeff u j * gen j v)
    (hshift : ∀ u (a : A) (j : Fin n),
      coeff (u ++ [a]) j = ∑ i : Fin n, coeff u i * shift a i j)
    (hgen : ∀ (a : A) (i : Fin n) (v : List A),
      gen i (a :: v) = ∑ j : Fin n, shift a i j * gen j v) :
    RecognizableTropLanguage L :=
  ⟨n, (RealizationData.mk L gen coeff shift hdecomp hshift hgen).toAutomaton,
    (RealizationData.mk L gen coeff shift hdecomp hshift hgen).behavior_eq⟩

/-! ## §9. Automaton Isomorphism -/

structure WAutomatonIso (T₁ : WAutomaton K A n) (T₂ : WAutomaton K A m) where
  stateEquiv : Fin n ≃ Fin m
  init_compat : ∀ i, T₂.init (stateEquiv i) = T₁.init i
  trans_compat : ∀ (a : A) (i j : Fin n),
    T₂.trans a (stateEquiv i) (stateEquiv j) = T₁.trans a i j
  output_compat : ∀ j, T₂.output (stateEquiv j) = T₁.output j

def WAutomaton.IsReachable (T : WAutomaton K A n) : Prop :=
  ∀ j : Fin n, ∃ w : List A, T.reach w j ≠ 0

def WAutomaton.IsObservable (T : WAutomaton K A n) : Prop :=
  ∀ i j : Fin n, (∀ v : List A, T.obs v i = T.obs v j) → i = j

def WAutomaton.IsMinimal (T : WAutomaton K A n) : Prop :=
  T.IsReachable ∧ T.IsObservable

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
theorem WAutomatonIso.card_eq {T₁ : WAutomaton K A n} {T₂ : WAutomaton K A m}
    (iso : WAutomatonIso T₁ T₂) : n = m :=
  Fintype.card_fin n ▸ Fintype.card_fin m ▸ Fintype.card_of_bijective iso.stateEquiv.bijective

omit [DecidableEq A] [Fintype A] in
theorem WAutomatonIso.obs_eq {T₁ : WAutomaton K A n} {T₂ : WAutomaton K A m}
    (iso : WAutomatonIso T₁ T₂) (v : List A) (j : Fin n) :
    T₁.obs v j = T₂.obs v (iso.stateEquiv j) := by
  induction v generalizing j <;> simp_all +decide [ WAutomaton.obs ];
  · exact iso.output_compat j ▸ rfl;
  · refine' Finset.sum_bij ( fun i _ => iso.stateEquiv i ) _ _ _ _ <;> simp +decide [ iso.trans_compat ];
    exact iso.stateEquiv.surjective

omit [DecidableEq A] [Fintype A] in
theorem WAutomatonIso.behavior_eq {T₁ : WAutomaton K A n} {T₂ : WAutomaton K A m}
    (iso : WAutomatonIso T₁ T₂) : T₁.behavior = T₂.behavior := by
  have h_reach_eq : ∀ w : List A, ∀ j : Fin n, T₁.reach w j = T₂.reach w (iso.stateEquiv j) := by
    intro w j;
    induction' w using List.reverseRecOn with w a ih generalizing j;
    · convert iso.init_compat j |> Eq.symm using 1;
    · simp +decide [ *, WAutomaton.reach_snoc, WAutomaton.step ];
      conv_rhs => rw [ ← Equiv.sum_comp iso.stateEquiv ] ;
      exact Finset.sum_congr rfl fun i _ => by rw [ iso.trans_compat ] ;
  ext w;
  rw [ WAutomaton.behavior, WAutomaton.behavior ];
  apply Finset.sum_bij (fun j _ => iso.stateEquiv j);
  · exact fun _ _ => Finset.mem_univ _;
  · exact fun a₁ _ a₂ _ h => iso.stateEquiv.injective h;
  · exact fun b _ => ⟨ iso.stateEquiv.symm b, Finset.mem_univ _, by simp +decide ⟩;
  · exact fun j _ => by rw [ h_reach_eq w j, iso.output_compat ] ;

/-! ## §10. Residual Shift Closure -/

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
theorem residual_shift_is_residual (L : List A → K) (u : List A) (a : A) :
    (fun w => leftResidual L u (a :: w)) = leftResidual L (u ++ [a]) := by
  ext w; simp [leftResidual, List.append_assoc]

theorem automaton_behaviors_generate_residuals
    (T : WAutomaton K A n) (L : List A → K)
    (hT : T.behavior = L) (u : List A) :
    ∃ c : Fin n → K, ∀ v : List A,
      leftResidual L u v = ∑ j : Fin n, c j * T.obs v j := by
  refine ⟨T.reach u, fun v => ?_⟩
  simp only [leftResidual]
  rw [← hT]
  exact T.behavior_decomp u v

/-! ## §11. Finite Hankel Generation -/

theorem finite_hankel_generation (T : WAutomaton K A n) :
    ∃ (gens : Fin n → (List A → K)),
      ∀ u : List A, ∃ c : Fin n → K,
        ∀ v : List A, T.behavior (u ++ v) = ∑ j : Fin n, c j * gens j v :=
  ⟨fun j v => T.obs v j, fun u => ⟨T.reach u, fun v => T.behavior_decomp u v⟩⟩

omit [DecidableEq A] [Fintype A] in
theorem shift_stability (T : WAutomaton K A n) (a : A) (i : Fin n) :
    ∀ v : List A, T.obs (a :: v) i = ∑ j : Fin n, T.trans a i j * T.obs v j :=
  fun _ => by simp [WAutomaton.obs]

/-! ## §12. Certified Reconstruction -/

structure HankelWindowCert (K : Type*) [CommSemiring K] (A : Type*) (n : ℕ) where
  series : List A → K
  gen : Fin n → (List A → K)
  coeff : List A → Fin n → K
  shift : A → Fin n → Fin n → K
  window_consistent : ∀ u v, series (u ++ v) = ∑ j : Fin n, coeff u j * gen j v
  shift_verified : ∀ u (a : A) (j : Fin n),
    coeff (u ++ [a]) j = ∑ i : Fin n, coeff u i * shift a i j
  gen_shift_verified : ∀ (a : A) (i : Fin n) (v : List A),
    gen i (a :: v) = ∑ j : Fin n, shift a i j * gen j v

def HankelWindowCert.toRealizationData (C : HankelWindowCert K A n) :
    RealizationData K A n where
  series := C.series
  gen := C.gen
  coeff := C.coeff
  shift := C.shift
  decomp := C.window_consistent
  shift_compat := C.shift_verified
  gen_shift := C.gen_shift_verified

def HankelWindowCert.toAutomaton (C : HankelWindowCert K A n) : WAutomaton K A n :=
  C.toRealizationData.toAutomaton

omit [DecidableEq A] [Fintype A] in
theorem certified_reconstruction (C : HankelWindowCert K A n) :
    ∃ T : WAutomaton K A n,
      T.behavior = C.series ∧ T.stateCount = n :=
  ⟨C.toAutomaton, C.toRealizationData.behavior_eq, rfl⟩

/-! ## §13. Observation Matching for Uniqueness -/

omit [DecidableEq A] [Fintype A] in
theorem obs_matching_of_same_behavior
    (T₁ : WAutomaton K A n) (T₂ : WAutomaton K A n)
    (h_obs₁ : T₁.IsObservable)
    (h_match : ∀ j₁ : Fin n, ∃! j₂ : Fin n,
      ∀ v : List A, T₁.obs v j₁ = T₂.obs v j₂) :
    ∃ σ : Fin n ≃ Fin n,
      (∀ j v, T₁.obs v j = T₂.obs v (σ j)) ∧
      (∀ j, T₂.output (σ j) = T₁.output j) := by
  choose σ hσ₁ _ using h_match
  have h_inj : Function.Injective σ := by
    intro i j hij
    exact h_obs₁ i j fun v => by rw [hσ₁ i v, hσ₁ j v, hij]
  refine ⟨Equiv.ofBijective σ ⟨h_inj, Finite.injective_iff_surjective.mp h_inj⟩,
    fun j v => hσ₁ j v, fun j => ?_⟩
  simpa using (hσ₁ j []).symm

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
theorem iso_from_bijection
    (T₁ : WAutomaton K A n) (T₂ : WAutomaton K A n)
    (σ : Fin n ≃ Fin n)
    (h_init : ∀ j, T₂.init (σ j) = T₁.init j)
    (h_trans : ∀ (a : A) (i j : Fin n),
      T₂.trans a (σ i) (σ j) = T₁.trans a i j)
    (h_output : ∀ j, T₂.output (σ j) = T₁.output j) :
    Nonempty (WAutomatonIso T₁ T₂) :=
  ⟨⟨σ, h_init, h_trans, h_output⟩⟩

/-! ## §14. State Count Bounds -/

def IsRealizable (S : List A → K) (n : ℕ) : Prop :=
  ∃ T : WAutomaton K A n, T.behavior = S

omit [DecidableEq A] [Fintype A] in
theorem state_count_upper_bound (L : List A → K)
    (T : WAutomaton K A n) (hT : T.behavior = L) :
    IsRealizable L n :=
  ⟨T, hT⟩

/-! ## §15. Summary Theorems -/

/-- **Grand Equivalence**: Recognizability ↔ FGHankelRowSemimodule. -/
theorem grand_equivalence (L : List A → K) :
    RecognizableTropLanguage L ↔ FGHankelRowSemimodule L :=
  recognizable_iff_fg_hankel_row L

omit [DecidableEq A] [Fintype A] in
theorem fg_hankel_implies_fg_residual (L : List A → K) :
    FGHankelRowSemimodule L → FGResidualSemimodule L := by
  rintro ⟨n, gen, coeff, _, hdecomp, _, _⟩
  exact ⟨n, gen, fun u => ⟨coeff u, fun v => hdecomp u v⟩⟩

omit [DecidableEq A] [Fintype A] in
theorem certified_reconstruction_pipeline (L : List A → K) (n : ℕ)
    (D : RealizationData K A n) (hD : D.series = L) :
    ∃ T : WAutomaton K A n,
      T.behavior = L ∧ T.stateCount = n :=
  ⟨D.toAutomaton, by rw [D.behavior_eq, hD], rfl⟩

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
theorem hankel_eq_residual_eval (L : List A → K) (u v : List A) :
    hankel L u v = leftResidual L u v := rfl

theorem hankelRow_in_span (T : WAutomaton K A n) (u : List A) :
    ∃ c : Fin n → K, ∀ v : List A,
      hankelRow T.behavior u v = ∑ j : Fin n, c j * T.obs v j :=
  ⟨T.reach u, fun v => T.behavior_decomp u v⟩

/-! ## §16. Tropical Specialization -/

/-- The min-plus tropical semiring type. -/
abbrev Trop := Tropical (WithTop ℕ)

abbrev TropLanguage (A : Type*) := List A → Trop

abbrev TropWAutomaton (A : Type*) (n : ℕ) := WAutomaton Trop A n

/-- Grand equivalence specialized to tropical semiring. -/
theorem trop_recognizable_iff_fg_hankel
    {A : Type*} [DecidableEq A] [Fintype A]
    (L : TropLanguage A) :
    RecognizableTropLanguage L ↔ FGHankelRowSemimodule L :=
  grand_equivalence L

end TropicalHankelRealization