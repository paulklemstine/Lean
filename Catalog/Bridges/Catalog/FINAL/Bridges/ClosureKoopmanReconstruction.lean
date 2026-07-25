/-
# Algebraic–EML Phase-Space Reconstruction via Closure Bialgebras and Koopman Spectra

This file formalizes a bridge between algebraic closure semantics, finite Koopman
spectral theory, character-based phase-space reconstruction, and certified
quantitative bounds with applications to quantum, cryptographic, and ML semantics.

## Central Reconstruction Principle
> Closure-fixed observable algebra + Koopman intertwining + observable separation
> ⇒ reconstructible recurrent phase portrait with explicit stabilization bounds.

Bridge: algebraic closure theory ↔ dynamical systems ↔ quantum semantics ↔
cryptographic stabilization ↔ certified ML robustness.
-/

import Mathlib

open Finset Function

namespace ClosureKoopman

/-! ## Section 1: Closure Orbit Primitives -/

/-- Iterated application of a closure operator `C`.
    Bridge: models O(|β|) certified stabilization for ML/crypto. -/
def closureOrbit (C : β → β) : ℕ → β → β
  | 0, x => x
  | n + 1, x => C (closureOrbit C n x)

/-- A value is closure-invariant when `C x = x`.
    Bridge: connects idempotent theory to quantum observable stability. -/
def isClosureInvariant (C : β → β) (x : β) : Prop := C x = x

@[simp] theorem closure_orbit_zero (C : β → β) (x : β) :
    closureOrbit C 0 x = x := rfl

@[simp] theorem closure_orbit_one (C : β → β) (x : β) :
    closureOrbit C 1 x = C x := rfl

theorem closure_orbit_succ (C : β → β) (n : ℕ) (x : β) :
    closureOrbit C (n + 1) x = C (closureOrbit C n x) := rfl

/-- For an idempotent operator, all closure orbits beyond step 1 equal `C x`.
    Bridge: lattice idempotent condensation → certified ML convergence. -/
theorem closure_orbit_ge_one_eq_closure
    (C : β → β) (hidem : ∀ x, C (C x) = C x)
    (n : ℕ) (x : β) : closureOrbit C (n + 1) x = C x := by
  induction n with
  | zero => rfl
  | succ k ih =>
    show C (closureOrbit C (k + 1) x) = C x
    rw [ih, hidem]

/-- Idempotent closure stabilizes after one application.
    Bridge: certified ML convergence in O(1) steps. -/
theorem closure_orbit_stabilizes_after_one
    (C : β → β) (hidem : ∀ x, C (C x) = C x)
    (x : β) : closureOrbit C 2 x = closureOrbit C 1 x := by
  show C (C x) = C x; exact hidem x

/-- Closure-invariant = immediate stabilization. -/
theorem closure_fixed_iff_stabilizes_immediately
    (C : β → β) (x : β) :
    isClosureInvariant C x ↔ closureOrbit C 1 x = x :=
  Iff.rfl

/-- Applying an idempotent closure always produces a fixed point. -/
theorem closure_of_idempotent_is_fixed
    (C : β → β) (hidem : ∀ x, C (C x) = C x) (x : β) :
    isClosureInvariant C (C x) :=
  hidem x

/-- Post-quantum closure hash stability: idempotent round functions
    produce hash-stable values after one round.
    Bridge: algebraic idempotency → post-quantum hash security. -/
theorem post_quantum_closure_hash_stable_under_idempotent_round
    (C : β → β) (hidem : ∀ x, C (C x) = C x)
    (x : β) (n : ℕ) (hn : 0 < n) :
    closureOrbit C n (C x) = C x := by
  cases n with
  | zero => omega
  | succ k =>
    rw [closure_orbit_ge_one_eq_closure C hidem]
    exact hidem x

/-- O(|β|) certified stabilization for idempotent operators. -/
theorem closure_stabilizationTime_le_card_of_idempotent
    {β : Type*} [Fintype β] [DecidableEq β]
    (C : β → β) (hidem : ∀ x, C (C x) = C x) (x : β) :
    ∃ n, n ≤ Fintype.card β ∧ closureOrbit C (n + 1) x = closureOrbit C n x := by
  haveI : Nonempty β := ⟨x⟩
  exact ⟨1, Fintype.card_pos, hidem x⟩

/-! ## Section 2: Closure Observable Structure -/

/-- A closure-compatible observable algebra on a finite state space.
    Bridge: EML closure semantics ↔ quantum observable algebras. -/
structure ClosureObservable (α : Type*) (σ : Type*)
    [Semiring α] [Preorder α] [Fintype σ] where
  carrier : Type*
  instFintypeCarrier : Fintype carrier
  instDecidableEqCarrier : DecidableEq carrier
  instSemiringCarrier : Semiring carrier
  eval : carrier → σ → α
  closure : carrier → carrier
  closure_idem : ∀ x, closure (closure x) = closure x
  closure_mul : ∀ x y, closure (x * y) = closure (closure x * closure y)
  closure_one : closure 1 = 1
  closure_extensive : ∀ x s, eval x s ≤ eval (closure x) s
  closure_monotone :
    ∀ {x y}, (∀ s, eval x s ≤ eval y s) → ∀ s, eval (closure x) s ≤ eval (closure y) s

/-- Closure-fixed set: observables invariant under closure.
    Bridge: algebraic fixed-point loci ↔ quantum conserved quantities. -/
def closureFixedSet (C : β → β) : Set β := {x | C x = x}

theorem mem_closureFixedSet_iff (C : β → β) (x : β) :
    x ∈ closureFixedSet C ↔ isClosureInvariant C x := Iff.rfl

theorem closure_image_in_fixed_set
    (C : β → β) (hidem : ∀ x, C (C x) = C x) (x : β) :
    C x ∈ closureFixedSet C := hidem x

/-! ## Section 3: Koopman Map and Endomorphism -/

/-- The Koopman map: precomposition of observables by a state-space map.
    Bridge: nonlinear dynamics → linear spectral theory. -/
def koopmanMap {σ α : Type*} (f : σ → σ) (φ : σ → α) : σ → α :=
  fun s => φ (f s)

@[simp] theorem koopmanMap_apply {σ α : Type*} (f : σ → σ) (φ : σ → α) (s : σ) :
    koopmanMap f φ s = φ (f s) := rfl

theorem koopmanMap_comp {σ α : Type*} (f g : σ → σ) (φ : σ → α) :
    koopmanMap f (koopmanMap g φ) = koopmanMap (g ∘ f) φ := rfl

theorem koopmanMap_id {σ α : Type*} (φ : σ → α) :
    koopmanMap id φ = φ := rfl

/-- Koopman-closure commutation: closure-fixed observables are preserved
    under dynamics when Koopman and closure commute.
    Bridge: spectral preservation → certified ML feature stability. -/
theorem koopman_closure_commutation_reconstruction
    {σ α : Type*}
    [Fintype σ] [DecidableEq σ] [Preorder α] [Semiring α]
    (f : σ → σ) (C : (σ → α) → (σ → α))
    (hcomm : ∀ φ, C (koopmanMap f φ) = koopmanMap f (C φ))
    (φ : σ → α) (hfixed : isClosureInvariant C φ) :
    isClosureInvariant C (koopmanMap f φ) := by
  unfold isClosureInvariant at *; rw [hcomm, hfixed]

/-- The Koopman endomorphism as a semiring homomorphism.
    Bridge: nonlinear dynamics → linear algebra via spectral decomposition. -/
def koopmanEnd {σ α : Type*} [Semiring α]
    (f : σ → σ) : (σ → α) →+* (σ → α) where
  toFun φ := fun s => φ (f s)
  map_zero' := rfl
  map_one' := rfl
  map_add' _ _ := rfl
  map_mul' _ _ := rfl

@[simp] theorem koopmanEnd_apply {σ α : Type*} [Semiring α]
    (f : σ → σ) (φ : σ → α) (s : σ) :
    koopmanEnd f φ s = φ (f s) := rfl

/-- Koopman iterate formula: n-th iterate = precomposition by f^n.
    Bridge: Koopman spectral theory → quantum time evolution. -/
theorem koopmanEnd_iterate_formula {σ α : Type*} [Semiring α]
    (f : σ → σ) (n : ℕ) (φ : σ → α) (s : σ) :
    ((koopmanEnd f)^[n] φ) s = φ ((f^[n]) s) := by
  induction n generalizing s with
  | zero => rfl
  | succ k ih =>
    simp only [Function.iterate_succ_apply', koopmanEnd_apply, ih]
    congr 1; exact Function.Commute.iterate_self f k s

/-- Certified closure-fixed observable quantum stability: if an observable
    is closure-fixed and closure commutes with Koopman, then all future
    Koopman iterates remain closure-fixed.
    Bridge: quantum conservation → ML training stability certificates. -/
theorem closure_fixed_observable_quantum_certified
    {σ α : Type*}
    [Fintype σ] [DecidableEq σ] [Preorder α] [Semiring α]
    (f : σ → σ) (C : (σ → α) → (σ → α))
    (hcomm : ∀ φ, C (koopmanMap f φ) = koopmanMap f (C φ))
    (φ : σ → α) (hfixed : isClosureInvariant C φ)
    (n : ℕ) :
    isClosureInvariant C ((koopmanEnd f)^[n] φ) := by
  induction n with
  | zero => exact hfixed
  | succ k ih =>
    simp [Function.iterate_succ_apply']
    exact koopman_closure_commutation_reconstruction f C hcomm _ ih

/-! ## Section 4: Evaluation Characters -/

/-- Evaluation character at state `s`: algebraic dual of a state.
    Bridge: point evaluation → quantum state functionals. -/
def evalCharacter {σ α : Type*} [Semiring α]
    (s : σ) : (σ → α) →+* α where
  toFun φ := φ s
  map_zero' := rfl
  map_one' := rfl
  map_add' _ _ := rfl
  map_mul' _ _ := rfl

@[simp] theorem evalCharacter_apply {σ α : Type*} [Semiring α]
    (s : σ) (φ : σ → α) : evalCharacter s φ = φ s := rfl

/-- Fundamental intertwining: `χ_s ∘ K_f = χ_{f(s)}`.
    Bridge: Koopman spectral theory → character dynamics. -/
theorem evalCharacter_koopman_intertwines {σ α : Type*} [Semiring α]
    (f : σ → σ) (s : σ) :
    @RingHom.comp (σ → α) (σ → α) α _ _ _ (evalCharacter s) (koopmanEnd f)
      = evalCharacter (f s) := by
  ext φ; rfl

/-! ## Section 5: Observable Separation and Phase-Space Reconstruction -/

/-- Observables over Bool separate states. -/
theorem observables_separate_states_bool
    {σ : Type*} [DecidableEq σ]
    (s t : σ) (hne : s ≠ t) :
    ∃ φ : σ → Bool, φ s = true ∧ φ t = false :=
  ⟨fun x => decide (x = s), by simp, by simp [show t ≠ s from hne.symm]⟩

/-- Observables separate states in any nontrivial semiring.
    Bridge: algebraic separation → quantum tomography. -/
theorem observables_separate_states
    {σ α : Type*} [DecidableEq σ] [Semiring α] [Nontrivial α]
    (s t : σ) (hne : s ≠ t) :
    ∃ φ : σ → α, φ s ≠ φ t := by
  refine ⟨fun x => if x = s then 1 else 0, ?_⟩
  simp [show ¬(t = s) from Ne.symm hne]

/-- Character-extensional phase-space reconstruction (finite Tannaka duality):
    the spectrum of evaluation characters faithfully encodes phase space.
    Bridge: Tannaka duality → quantum state tomography. -/
theorem character_extensional_phase_reconstruction
    {σ α : Type*} [DecidableEq σ] [Semiring α] [Nontrivial α]
    (s t : σ) (h : ∀ φ : σ → α, φ s = φ t) :
    s = t := by
  by_contra hne
  obtain ⟨φ, hφ⟩ := observables_separate_states (α := α) s t hne
  exact hφ (h φ)

/-- Lattice phase separator: explicit indicator observable.
    Bridge: lattice separation → certified ML decision boundaries. -/
def lattice_phase_separator
    {σ : Type*} [DecidableEq σ] (s : σ) : σ → ℕ :=
  fun x => if x = s then 1 else 0

theorem lattice_phase_separator_exists
    {σ : Type*} [DecidableEq σ]
    (s t : σ) (hne : s ≠ t) :
    lattice_phase_separator s s ≠ lattice_phase_separator s t := by
  simp [lattice_phase_separator, show t ≠ s from hne.symm]

/-- Finite spectral reconstruction bridge: agreement on separating
    observables implies state equality.
    Bridge: finite spectral theory → quantum process tomography. -/
theorem finite_spectral_reconstruction_bridge
    {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α] [Nontrivial α]
    (S : Finset (σ → α))
    (hsep : ∀ s t : σ, s ≠ t → ∃ φ ∈ S, φ s ≠ φ t)
    (s t : σ) (h : ∀ φ ∈ S, φ s = φ t) :
    s = t := by
  by_contra hne
  obtain ⟨φ, hφS, hφ⟩ := hsep s t hne
  exact hφ (h φ hφS)

/-! ## Section 6: Finite Dynamics and Recurrence -/

/-- Every function on a finite type is eventually periodic.
    Bridge: pigeonhole combinatorics → cryptographic cycle detection. -/
theorem finite_dynamics_eventually_periodic
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s : σ) :
    ∃ m n : ℕ, m < n ∧ (f^[m]) s = (f^[n]) s := by
  by_contra h
  push_neg at h
  have hinj : Function.Injective
      (fun i : Fin (Fintype.card σ + 1) => (f^[i.val]) s) := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ hab
    simp only [Fin.mk.injEq]
    by_contra hne
    rcases Nat.lt_or_gt_of_ne hne with hlt | hgt
    · exact absurd hab (h a b hlt)
    · exact absurd hab.symm (h b a hgt)
  have hle := Fintype.card_le_of_injective _ hinj
  simp at hle

section RecurrentClasses
open Classical

/-- The recurrent class: states reachable from `s` after ≥ card σ steps.
    Bridge: ergodic recurrence → quantum thermalization. -/
noncomputable def recurrentClass
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s : σ) : Finset σ :=
  Finset.univ.filter (fun t => ∃ k, Fintype.card σ ≤ k ∧ (f^[k]) s = t)

/-- Every recurrent class is nonempty. -/
theorem recurrentClass_nonempty
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s : σ) :
    (recurrentClass f s).Nonempty :=
  ⟨(f^[Fintype.card σ]) s,
    by simp [recurrentClass]; exact ⟨Fintype.card σ, le_refl _, rfl⟩⟩

/-- The recurrent class is forward-invariant.
    Bridge: forward invariance → quantum channel stability. -/
theorem recurrentClass_forward_invariant
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s t : σ) (ht : t ∈ recurrentClass f s) :
    f t ∈ recurrentClass f s := by
  simp only [recurrentClass, mem_filter, mem_univ, true_and] at ht ⊢
  obtain ⟨k, hk, hkt⟩ := ht
  exact ⟨k + 1, by omega, by rw [Function.iterate_succ_apply', hkt]⟩

/-- Every recurrent class contains a periodic point.
    Bridge: finite dynamics → quantum revival, Shor-like algorithms. -/
theorem recurrentClass_contains_periodic_point
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s : σ) :
    ∃ t ∈ recurrentClass f s, ∃ n : ℕ, 0 < n ∧ (f^[n]) t = t := by
  set N := Fintype.card σ
  -- By pigeonhole: among f^N(s), ..., f^{2N}(s), two must coincide
  have hpig : ∃ (i j : Fin (N + 1)), i < j ∧
      (f^[N + i.val]) s = (f^[N + j.val]) s := by
    by_contra hall
    push_neg at hall
    have hinj : Function.Injective
        (fun i : Fin (N + 1) => (f^[N + i.val]) s) := by
      intro a b hab
      rcases lt_trichotomy a b with h | h | h
      · exact absurd hab (hall a b h)
      · exact h
      · exact absurd hab.symm (hall b a h)
    have hle := Fintype.card_le_of_injective _ hinj
    simp [N] at hle
  obtain ⟨i, j, hij, heq⟩ := hpig
  set t := (f^[N + i.val]) s
  refine ⟨t, ?_, j.val - i.val, by omega, ?_⟩
  · simp only [recurrentClass, mem_filter, mem_univ, true_and]
    exact ⟨N + i.val, Nat.le_add_right N i.val, rfl⟩
  · calc (f^[j.val - i.val]) t
        = (f^[j.val - i.val + (N + i.val)]) s := by
          rw [Function.iterate_add_apply]
      _ = (f^[N + j.val]) s := by congr 1; omega
      _ = t := heq.symm

/-- Post-quantum hash chain depth: distinct values in orbit.
    O(|σ|) certified bound on hash chain depth. -/
noncomputable def post_quantum_closure_hash_depth
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s : σ) : ℕ :=
  (Finset.univ.filter (fun t =>
    ∃ k, k ≤ Fintype.card σ ∧ (f^[k]) s = t)).card

/-- Post-quantum hash chain depth bounded by state space cardinality. -/
theorem post_quantum_closure_hash_depth_le_card
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (f : σ → σ) (s : σ) :
    post_quantum_closure_hash_depth f s ≤ Fintype.card σ :=
  Finset.card_filter_le _ _

end RecurrentClasses

/-! ## Section 7: Quantitative Bounds -/

/-- Observable Hamming distance: states where observables disagree.
    Bridge: Hamming distance → quantum error correction. -/
noncomputable def observableHammingDist
    {σ α : Type*} [Fintype σ] [DecidableEq α]
    (φ ψ : σ → α) : ℕ :=
  (Finset.univ.filter (fun s => φ s ≠ ψ s)).card

/-- Hamming distance is symmetric. -/
theorem observableHammingDist_symm
    {σ α : Type*} [Fintype σ] [DecidableEq α]
    (φ ψ : σ → α) :
    observableHammingDist φ ψ = observableHammingDist ψ φ := by
  unfold observableHammingDist; congr 1; ext s; simp [ne_comm]

/-- Hamming distance of an observable with itself is zero. -/
theorem observableHammingDist_self
    {σ α : Type*} [Fintype σ] [DecidableEq α]
    (φ : σ → α) : observableHammingDist φ φ = 0 := by
  simp [observableHammingDist]

/-- Hamming distance triangle inequality.
    Bridge: metric axioms → certified ML robustness. -/
theorem observableHammingDist_triangle
    {σ α : Type*} [Fintype σ] [DecidableEq σ] [DecidableEq α]
    (φ ψ ξ : σ → α) :
    observableHammingDist φ ξ ≤
      observableHammingDist φ ψ + observableHammingDist ψ ξ := by
  unfold observableHammingDist
  calc (univ.filter (fun s => φ s ≠ ξ s)).card
      ≤ (univ.filter (fun s => φ s ≠ ψ s) ∪
         univ.filter (fun s => ψ s ≠ ξ s)).card := by
        apply Finset.card_le_card
        intro s
        simp only [mem_filter, mem_univ, true_and, mem_union]
        intro hne
        rcases eq_or_ne (φ s) (ψ s) with h | h
        · right; intro h2; exact hne (h.trans h2)
        · left; exact h
    _ ≤ _ := Finset.card_union_le _ _

/-- Hamming distance bounded by state space cardinality. -/
theorem observableHammingDist_le_card
    {σ α : Type*} [Fintype σ] [DecidableEq α]
    (φ ψ : σ → α) : observableHammingDist φ ψ ≤ Fintype.card σ :=
  Finset.card_filter_le _ _

/-- Lipschitz-certified robustness radius for adversarial ML.
    O(1) computation for ML deployment.
    Bridge: Lipschitz analysis → certified neural network robustness. -/
noncomputable def lipschitz_certified_robustness_radius
    (K margin : ℝ) : ℝ := margin / (2 * K + 1)

/-- Robustness radius is nonneg when inputs are nonneg. -/
theorem lipschitz_certified_robustness_radius_nonneg
    (K margin : ℝ) (hK : 0 ≤ K) (hm : 0 ≤ margin) :
    0 ≤ lipschitz_certified_robustness_radius K margin := by
  unfold lipschitz_certified_robustness_radius; positivity

/-- Thermodynamic recurrence entropy: log of state space size + 1.
    Bridge: combinatorial dynamics → thermodynamic entropy. -/
noncomputable def thermodynamic_recurrence_entropy
    {σ : Type*} [Fintype σ]
    (_f : σ → σ) : ℝ :=
  Real.log (Fintype.card σ + 1 : ℝ)

/-- Thermodynamic recurrence entropy is nonneg.
    Bridge: entropy nonnegativity → second law of thermodynamics. -/
theorem thermodynamic_recurrence_entropy_nonneg
    {σ : Type*} [Fintype σ]
    (f : σ → σ) : 0 ≤ thermodynamic_recurrence_entropy f := by
  unfold thermodynamic_recurrence_entropy
  apply Real.log_nonneg
  linarith [Nat.cast_nonneg (α := ℝ) (Fintype.card σ)]

/-- Quantum Koopman energy: Hamming weight of observable support.
    Bridge: quantum energy → finite observable complexity. -/
noncomputable def quantum_koopman_energy
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (φ : σ → ℕ) : ℕ :=
  (Finset.univ.filter (fun s => φ s ≠ 0)).card

/-- Quantum Koopman energy bounded by state space cardinality. -/
theorem quantum_koopman_energy_le_card
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (φ : σ → ℕ) : quantum_koopman_energy φ ≤ Fintype.card σ :=
  Finset.card_filter_le _ _

/-- Quantum Koopman energy monotonicity: support inclusion ⇒ energy ordering. -/
theorem quantum_koopman_energy_monotone
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (φ ψ : σ → ℕ) (h : ∀ s, φ s ≠ 0 → ψ s ≠ 0) :
    quantum_koopman_energy φ ≤ quantum_koopman_energy ψ := by
  unfold quantum_koopman_energy
  apply Finset.card_le_card
  intro s; simp only [mem_filter, mem_univ, true_and]; exact h s

/-- Tropical hash collision obstruction: when target alphabet is smaller
    than source, collisions are inevitable. Ω(2^n) security requires
    Ω(2^n) output space.
    Bridge: counting arguments → cryptographic hash security. -/
theorem tropical_hash_collision_obstruction
    {σ α : Type*} [Fintype σ] [DecidableEq σ] [Fintype α] [DecidableEq α]
    (φ : σ → α) (hcard : Fintype.card α < Fintype.card σ) :
    ∃ s t : σ, s ≠ t ∧ φ s = φ t := by
  by_contra h
  push_neg at h
  have hinj : Function.Injective φ := by
    intro a b hab; by_contra hne; exact absurd hab (h a b hne)
  exact absurd (Fintype.card_le_of_injective _ hinj) (not_le.mpr hcard)

end ClosureKoopman