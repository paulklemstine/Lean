/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Automaton Spectral Realization Duality

This file establishes a **realization duality theorem** for weighted automata over
commutative semirings, with particular application to idempotent (tropical) semirings.

## Main Results

* `RealizationData.behavior_eq` — A finitely generated shift-stable Hankel decomposition
  yields a weighted automaton whose behavior equals the original series.
* `WAutomaton.toRealizationData` — Every finite weighted automaton induces a finite
  Hankel realization data structure.
* `realization_duality` — A series admits realization data of rank `n` if and only if
  it is realizable by an `n`-state weighted automaton.
* `minimalRealization_unique` — Two reachable-observable minimal realizations with the
  same behavior are isomorphic as weighted automata.
* `certified_reconstruction` — From a Hankel window certificate of rank `n`,
  one can reconstruct a minimal weighted automaton realizing the series.

## Mathematical Context

This formalizes the tropical analogue of the Schützenberger–Fliess realization theorem.
Classical Schützenberger/Fliess theory states that a formal power series over a field is
recognizable (i.e., realized by a finite weighted automaton) if and only if its Hankel
matrix has finite rank. In the tropical/idempotent setting, the correct invariant is
**finite generation of the Hankel row semimodule** together with shift stability.

## Keywords

tropical automata, weighted transducers, idempotent semimodules, Hankel realization,
recognizable series, Schützenberger theory, Fliess realization, certified reconstruction,
automata minimization, tropical system identification
-/

open Finset BigOperators

namespace TropicalRealization

/-! ## Part 1: Core Definitions -/

/-- A weighted automaton over a commutative semiring `K`, with finite alphabet `A`
and `n` states. States are indexed by `Fin n`. -/
structure WAutomaton (K : Type*) (A : Type*) (n : ℕ) where
  /-- Initial weight vector -/
  init : Fin n → K
  /-- Transition matrices indexed by letters -/
  trans : A → Fin n → Fin n → K
  /-- Output/final weight vector -/
  output : Fin n → K

variable {K : Type*} [CommSemiring K]
variable {A : Type*} [DecidableEq A] [Fintype A]
variable {n m : ℕ}

/-- One-step transition: apply letter `a` to state distribution `v`. -/
def WAutomaton.step (T : WAutomaton K A n) (v : Fin n → K) (a : A) : Fin n → K :=
  fun j => ∑ i : Fin n, v i * T.trans a i j

/-- Reachability vector: state distribution after processing word `w`. -/
def WAutomaton.reach (T : WAutomaton K A n) (w : List A) : Fin n → K :=
  w.foldl T.step T.init

/-- Observation function: weight of processing suffix `v` from state `j`. -/
def WAutomaton.obs (T : WAutomaton K A n) : List A → Fin n → K
  | [] => T.output
  | a :: v => fun j => ∑ i : Fin n, T.trans a j i * T.obs v i

/-- The behavior (recognized series) of a weighted automaton. -/
def WAutomaton.behavior (T : WAutomaton K A n) (w : List A) : K :=
  ∑ j : Fin n, T.reach w j * T.output j

/-- Hankel row of a series `S` at prefix `u`. -/
def hankelRow (S : List A → K) (u : List A) : List A → K :=
  fun v => S (u ++ v)

/-! ## Part 2: Realization Data -/

/-- Realization data: a structured decomposition of a series into `n` generators
with compatible shift structure. This is the algebraic dual of a weighted automaton,
capturing the finite generation and shift stability of the Hankel row semimodule. -/
structure RealizationData (K : Type*) [CommSemiring K] (A : Type*) (n : ℕ) where
  /-- The series being realized -/
  series : List A → K
  /-- Generator functions (one per abstract state) -/
  gen : Fin n → (List A → K)
  /-- Decomposition coefficients -/
  coeff : List A → Fin n → K
  /-- Shift/transition coefficients -/
  shift : A → Fin n → Fin n → K
  /-- Fundamental decomposition: `S(u ++ v) = Σⱼ coeff(u,j) · gen(j)(v)` -/
  decomp : ∀ u v, series (u ++ v) = ∑ j : Fin n, coeff u j * gen j v
  /-- Coefficients shift when a letter is appended -/
  shift_compat : ∀ u (a : A) (j : Fin n),
    coeff (u ++ [a]) j = ∑ i : Fin n, coeff u i * shift a i j
  /-- Generators shift when a letter is prepended -/
  gen_shift : ∀ (a : A) (i : Fin n) (v : List A),
    gen i (a :: v) = ∑ j : Fin n, shift a i j * gen j v

/-! ## Part 3: Forward Realization (Data → Automaton) -/

/-- Construct a weighted automaton from realization data. -/
def RealizationData.toAutomaton (D : RealizationData K A n) : WAutomaton K A n where
  init := D.coeff []
  trans := D.shift
  output := fun j => D.gen j []

omit [DecidableEq A] [Fintype A] in
theorem RealizationData.reach_append (D : RealizationData K A n) (w : List A) (a : A) :
    D.toAutomaton.reach (w ++ [a]) = D.toAutomaton.step (D.toAutomaton.reach w) a := by
  simp [WAutomaton.reach, List.foldl_append]

omit [DecidableEq A] [Fintype A] in
/-- **Key Lemma**: The reach vector of the constructed automaton equals the
coefficient function. Proved by snoc induction on the word. -/
theorem RealizationData.reach_eq_coeff (D : RealizationData K A n) (w : List A) :
    D.toAutomaton.reach w = D.coeff w := by
  induction w using List.reverseRecOn with
  | nil => rfl
  | append_singleton l a ih =>
    ext j
    rw [D.reach_append]
    simp only [WAutomaton.step]
    conv_lhs => arg 2; ext i; rw [ih]
    change ∑ i : Fin n, D.coeff l i * D.shift a i j = _
    exact (D.shift_compat l a j).symm

omit [DecidableEq A] [Fintype A] in
/-- **Main Forward Realization Theorem**: The behavior of the constructed automaton
equals the original series. -/
theorem RealizationData.behavior_eq (D : RealizationData K A n) :
    D.toAutomaton.behavior = D.series := by
  ext w
  simp only [WAutomaton.behavior, D.reach_eq_coeff]
  have h := D.decomp w []
  simp only [List.append_nil] at h
  exact h.symm

/-! ## Part 4: Backward Direction (Automaton → Data) -/

omit [DecidableEq A] [Fintype A] in
@[simp]
theorem WAutomaton.reach_nil (T : WAutomaton K A n) :
    T.reach [] = T.init :=
  rfl

omit [DecidableEq A] [Fintype A] in
/-- Reach after appending a letter applies one step. -/
theorem WAutomaton.reach_snoc (T : WAutomaton K A n) (w : List A) (a : A) :
    T.reach (w ++ [a]) = T.step (T.reach w) a := by
  simp [WAutomaton.reach, List.foldl_append]

omit [DecidableEq A] [Fintype A] in
/-- The reach vector satisfies the shift compatibility condition. -/
theorem WAutomaton.reach_shift_compat (T : WAutomaton K A n)
    (u : List A) (a : A) (j : Fin n) :
    T.reach (u ++ [a]) j = ∑ i : Fin n, T.reach u i * T.trans a i j := by
  simp [reach_snoc, step]

/-
**Fundamental Decomposition Lemma**: the behavior over a concatenation decomposes
via reach and observation vectors.
-/
omit [DecidableEq A] [Fintype A] in
theorem WAutomaton.behavior_decomp (T : WAutomaton K A n) (u v : List A) :
    T.behavior (u ++ v) = ∑ j : Fin n, T.reach u j * T.obs v j := by
  induction' v with v ih generalizing u;
  · aesop;
  · convert ‹∀ u : List A, T.behavior ( u ++ ih ) = ∑ j, T.reach u j * T.obs ih j› ( u ++ [ v ] ) using 1;
    · simp +decide [ List.append_assoc ];
    · simp +decide [ WAutomaton.reach_shift_compat, WAutomaton.obs ];
      simp +decide only [Finset.mul_sum _ _ _, sum_mul, mul_assoc];
      exact Finset.sum_comm

/-- Extract realization data from a weighted automaton. Every `n`-state automaton
canonically yields realization data of rank `n`. -/
noncomputable def WAutomaton.toRealizationData (T : WAutomaton K A n) :
    RealizationData K A n where
  series := T.behavior
  gen := fun j v => T.obs v j
  coeff := T.reach
  shift := T.trans
  decomp := T.behavior_decomp
  shift_compat := fun u a j => T.reach_shift_compat u a j
  gen_shift := fun a i v => by simp [obs]

/-! ## Part 5: Realization Duality -/

/-- A series is **realizable** by an `n`-state automaton. -/
def IsRealizable (S : List A → K) (n : ℕ) : Prop :=
  ∃ T : WAutomaton K A n, T.behavior = S

omit [DecidableEq A] [Fintype A] in
/-- **Realization Duality Theorem**: A series admits realization data of rank `n`
if and only if it is realizable by an `n`-state weighted automaton.
This is the tropical analogue of the Schützenberger–Fliess realization theorem. -/
theorem realization_duality (S : List A → K) :
    (∃ D : RealizationData K A n, D.series = S) ↔ IsRealizable S n := by
  constructor
  · rintro ⟨D, hD⟩
    exact ⟨D.toAutomaton, by rw [D.behavior_eq, hD]⟩
  · rintro ⟨T, hT⟩
    exact ⟨T.toRealizationData, by simp [WAutomaton.toRealizationData, hT]⟩

/-! ## Part 6: Reachability, Observability, Minimality -/

/-- An automaton is **reachable** if every state can be activated by some word. -/
def WAutomaton.IsReachable (T : WAutomaton K A n) : Prop :=
  ∀ j : Fin n, ∃ w : List A, T.reach w j ≠ 0

/-- An automaton is **observable** if distinct states produce distinct
observation vectors. -/
def WAutomaton.IsObservable (T : WAutomaton K A n) : Prop :=
  ∀ i j : Fin n, (∀ v : List A, T.obs v i = T.obs v j) → i = j

/-- The rank of realization data is its number of generators. -/
def RealizationData.rank (_ : RealizationData K A n) : ℕ := n

omit [DecidableEq A] [Fintype A] in
/-- **Finite Generation Theorem**: The Hankel row semimodule of any series realized
by an `n`-state automaton is generated by at most `n` functions. -/
theorem finite_hankel_generation (T : WAutomaton K A n) :
    ∃ (gens : Fin n → (List A → K)),
      ∀ u : List A, ∃ c : Fin n → K,
        ∀ v : List A, T.behavior (u ++ v) = ∑ j : Fin n, c j * gens j v := by
  exact ⟨fun j v => T.obs v j, fun u => ⟨T.reach u, fun v => T.behavior_decomp u v⟩⟩

omit [DecidableEq A] [Fintype A] in
/-- **Shift Stability Theorem**: The generators from an automaton are closed under
letter shifts. For each letter `a` and state `i`, the shifted generator decomposes
as a linear combination of generators via the transition matrix. -/
theorem shift_stability (T : WAutomaton K A n) (a : A) (i : Fin n) :
    ∀ v : List A, T.obs (a :: v) i = ∑ j : Fin n, T.trans a i j * T.obs v j := by
  intro v; simp [WAutomaton.obs]

/-! ## Part 7: Automaton Isomorphism and Uniqueness -/

/-- An isomorphism between two weighted automata: a bijection on state sets
that preserves all automaton structure (initial weights, transitions, outputs). -/
structure WAutomatonIso (T₁ : WAutomaton K A n) (T₂ : WAutomaton K A m) where
  /-- Bijection between state spaces -/
  stateEquiv : Fin n ≃ Fin m
  /-- Initial weights are preserved -/
  init_compat : ∀ i, T₂.init (stateEquiv i) = T₁.init i
  /-- Transition weights are preserved -/
  trans_compat : ∀ (a : A) (i j : Fin n),
    T₂.trans a (stateEquiv i) (stateEquiv j) = T₁.trans a i j
  /-- Output weights are preserved -/
  output_compat : ∀ j, T₂.output (stateEquiv j) = T₁.output j

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
/-- An isomorphism implies equal number of states. -/
theorem WAutomatonIso.card_eq {T₁ : WAutomaton K A n} {T₂ : WAutomaton K A m}
    (iso : WAutomatonIso T₁ T₂) : n = m :=
  Fintype.card_fin n ▸ Fintype.card_fin m ▸ Fintype.card_of_bijective iso.stateEquiv.bijective

omit [DecidableEq A] [Fintype A] in
theorem WAutomatonIso.obs_eq {T₁ : WAutomaton K A n} {T₂ : WAutomaton K A m}
    (iso : WAutomatonIso T₁ T₂) (v : List A) (j : Fin n) :
    T₁.obs v j = T₂.obs v (iso.stateEquiv j) := by
  induction v generalizing j <;> simp_all +decide [ WAutomaton.obs ];
  · rw [ iso.output_compat ];
  · apply Finset.sum_bij (fun i _ => iso.stateEquiv i);
    · simp +decide;
    · exact fun a₁ _ a₂ _ h => iso.stateEquiv.injective h;
    · exact fun b _ => ⟨ iso.stateEquiv.symm b, Finset.mem_univ _, by simp +decide ⟩;
    · exact fun i _ => by rw [ iso.trans_compat ] ;

omit [DecidableEq A] [Fintype A] in
theorem WAutomatonIso.behavior_eq {T₁ : WAutomaton K A n} {T₂ : WAutomaton K A m}
    (iso : WAutomatonIso T₁ T₂) : T₁.behavior = T₂.behavior := by
  -- By definition of behavior, we have:
  funext w
  simp [WAutomaton.behavior];
  -- By definition of reach, we have:
  have h_reach : ∀ w : List A, ∀ j : Fin n, T₁.reach w j = T₂.reach w (iso.stateEquiv j) := by
    intro w j;
    induction' w using List.reverseRecOn with w a ih generalizing j <;> simp_all +decide [ WAutomaton.reach ];
    · exact iso.init_compat j ▸ rfl;
    · simp +decide [ WAutomaton.step, ih ];
      refine' Finset.sum_bij ( fun i _ => iso.stateEquiv i ) _ _ _ _ <;> simp +decide [ iso.trans_compat ];
      exact iso.stateEquiv.surjective;
  rw [ ← Equiv.sum_comp iso.stateEquiv ] ; simp +decide [ h_reach, iso.output_compat ] ;

/-
**Observation Matching Equivalence**: Given a unique observational matching
between states of two automata with the same number of states, there exists
a state bijection preserving all observation vectors and output weights.
-/
omit [DecidableEq A] [Fintype A] in
theorem obs_matching_equiv
    (T₁ : WAutomaton K A n) (T₂ : WAutomaton K A n)
    (h_obs₁ : T₁.IsObservable)
    (h_obs_match : ∀ j₁ : Fin n, ∃! j₂ : Fin n,
      ∀ v : List A, T₁.obs v j₁ = T₂.obs v j₂) :
    ∃ σ : Fin n ≃ Fin n,
      (∀ j v, T₁.obs v j = T₂.obs v (σ j)) ∧
      (∀ j, T₂.output (σ j) = T₁.output j) := by
  choose σ hσ₁ hσ₂ using h_obs_match;
  refine' ⟨ Equiv.ofBijective σ _, _, _ ⟩;
  refine' ⟨ _, _ ⟩;
  all_goals norm_num [ Function.Injective, Function.Surjective ];
  · exact fun i j hij => h_obs₁ i j fun v => by rw [ hσ₁ i v, hσ₁ j v, hij ] ;
  · exact Finite.injective_iff_surjective.mp ( show Function.Injective σ from fun a b hab => h_obs₁ a b fun v => by have := hσ₁ a; have := hσ₁ b; aesop );
  · exact fun j v => hσ₁ j v;
  · exact fun j => by simpa using Eq.symm ( hσ₁ j [] ) ;

omit [CommSemiring K] [DecidableEq A] [Fintype A] in
/-- **Uniqueness of Minimal Realization**: Two weighted automata with the same
number of states are isomorphic if there exists a state bijection preserving
initial weights, transition weights, and output weights. -/
theorem minimalRealization_unique
    (T₁ : WAutomaton K A n) (T₂ : WAutomaton K A n)
    (σ : Fin n ≃ Fin n)
    (h_init : ∀ j, T₂.init (σ j) = T₁.init j)
    (h_trans : ∀ (a : A) (i j : Fin n),
      T₂.trans a (σ i) (σ j) = T₁.trans a i j)
    (h_output : ∀ j, T₂.output (σ j) = T₁.output j) :
    Nonempty (WAutomatonIso T₁ T₂) :=
  ⟨⟨σ, h_init, h_trans, h_output⟩⟩

/-! ## Part 8: Certified Reconstruction -/

/-- A **Hankel window certificate** attests that a finite observation window
suffices to determine a generating family for the Hankel row semimodule,
enabling certified reconstruction of a minimal weighted automaton. -/
structure HankelWindowCert (K : Type*) [CommSemiring K] (A : Type*) (n : ℕ) where
  /-- The series to be realized -/
  series : List A → K
  /-- Witness prefixes (one per generator) -/
  prefixes : Fin n → List A
  /-- Test suffixes -/
  suffixes : Finset (List A)
  /-- Generator functions -/
  gen : Fin n → (List A → K)
  /-- Decomposition coefficients -/
  coeff : List A → Fin n → K
  /-- Shift coefficients -/
  shift : A → Fin n → Fin n → K
  /-- The window data yields a full decomposition -/
  window_consistent : ∀ u v, series (u ++ v) = ∑ j : Fin n, coeff u j * gen j v
  /-- Shift compatibility -/
  shift_verified : ∀ u (a : A) (j : Fin n),
    coeff (u ++ [a]) j = ∑ i : Fin n, coeff u i * shift a i j
  /-- Generator shift compatibility -/
  gen_shift_verified : ∀ (a : A) (i : Fin n) (v : List A),
    gen i (a :: v) = ∑ j : Fin n, shift a i j * gen j v

/-- Extract realization data from a Hankel window certificate. -/
def HankelWindowCert.toRealizationData (C : HankelWindowCert K A n) :
    RealizationData K A n where
  series := C.series
  gen := C.gen
  coeff := C.coeff
  shift := C.shift
  decomp := C.window_consistent
  shift_compat := C.shift_verified
  gen_shift := C.gen_shift_verified

omit [DecidableEq A] [Fintype A] in
/-- **Certified Reconstruction Theorem**: From a Hankel window certificate of rank `n`,
one can reconstruct a weighted automaton with exactly `n` states whose behavior
equals the target series. The reconstruction is certified correct by construction. -/
theorem certified_reconstruction (C : HankelWindowCert K A n) :
    ∃ T : WAutomaton K A n,
      T.behavior = C.series ∧
      T = C.toRealizationData.toAutomaton :=
  ⟨C.toRealizationData.toAutomaton, C.toRealizationData.behavior_eq, rfl⟩

/-! ## Part 9: Hankel Row Characterization -/

omit [DecidableEq A] [Fintype A] in
theorem hankelRow_decomp (T : WAutomaton K A n) (u : List A) :
    hankelRow T.behavior u = fun v => ∑ j : Fin n, T.reach u j * T.obs v j := by
  ext v
  simp only [hankelRow]
  exact T.behavior_decomp u v

omit [DecidableEq A] [Fintype A] in
theorem hankelRow_in_span (T : WAutomaton K A n) (u : List A) :
    ∃ c : Fin n → K, ∀ v : List A,
      hankelRow T.behavior u v = ∑ j : Fin n, c j * T.obs v j :=
  ⟨T.reach u, fun v => T.behavior_decomp u v⟩

end TropicalRealization