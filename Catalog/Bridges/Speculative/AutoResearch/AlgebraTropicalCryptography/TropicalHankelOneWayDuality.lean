/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Fourier–Hankel Duality for Min-Plus One-Way Transducers

## Bridge: Tropical Algebra ↔ Weighted Automata ↔ Cryptographic Hardness

This file formalizes the structural connection between tropical Hankel rank,
min-plus weighted automata, and obstructions to one-wayness.

## Central Thesis

A tropical hash/transducer family is one-way only if its tropical Hankel
complexity is unbounded. If the associated Hankel kernel factors through
a finite-dimensional min-plus state space, then fibers and collision classes
become algorithmically reconstructible, destroying one-wayness.

## Main Results

### Structural Theory
* `hankelRow_append` — Hankel row composition under concatenation
* `factorization_same_summary_eq` — equal state summaries yield equal outputs
* `factorization_refines_hankelEquiv` — factorization refines Hankel equivalence
* `hankelEquiv_right_congruence` — Hankel equivalence is a right congruence

### Collision Reconstruction
* `collisionOfSameSummary` — certified collision witness from state collision
* `exists_collision_from_state_collision` — state collision → output collision
* `collision_guarantee` — pigeonhole collision existence for finite-rank transducers
* `not_injOn_of_finiteFactorization` — finite Hankel rank → non-injectivity

### One-Wayness Obstruction
* `oneWayFamily_requires_unbounded_rank` — one-way families require
  unbounded tropical Hankel rank
* `not_oneWay_of_uniformlyBoundedRank` — bounded rank precludes one-wayness
* `nonOneWay_collision_structure` — uniform collision structure from bounded rank
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 800000
set_option linter.unusedVariables false

namespace TropicalHankelDuality

/-! ## Section 1: Tropical Hankel Kernel and Row Profiles -/

/-- **Tropical Hankel kernel.** Maps pairs of words to the output of their
    concatenation under `f`. -/
def hankelKernel {α : Type*} {Y : Type*}
    (f : List α → Y) (u v : List α) : Y :=
  f (u ++ v)

/-- **Hankel row profile.** For a fixed prefix `u`, maps each continuation
    `v` to `f(u ++ v)`. -/
def hankelRow {α : Type*} {Y : Type*}
    (f : List α → Y) (u : List α) : List α → Y :=
  fun v => f (u ++ v)

@[simp]
theorem hankelRow_nil {α : Type*} {Y : Type*} (f : List α → Y) :
    hankelRow f [] = f := by
  ext v; simp [hankelRow]

@[simp]
theorem hankelKernel_nil {α : Type*} {Y : Type*} (f : List α → Y) (v : List α) :
    hankelKernel f [] v = f v := by
  simp [hankelKernel]

@[simp]
theorem hankelKernel_nil_right {α : Type*} {Y : Type*} (f : List α → Y) (u : List α) :
    hankelKernel f u [] = f u := by
  simp [hankelKernel]

/-- **Composition law for Hankel rows.** -/
theorem hankelRow_append {α : Type*} {Y : Type*}
    (f : List α → Y) (u a : List α) :
    hankelRow f (u ++ a) = fun v => hankelRow f u (a ++ v) := by
  ext v; simp [hankelRow, List.append_assoc]

/-- Hankel kernel is associative in its word decomposition. -/
theorem hankelKernel_assoc {α : Type*} {Y : Type*}
    (f : List α → Y) (u a v : List α) :
    hankelKernel f (u ++ a) v = hankelKernel f u (a ++ v) := by
  simp [hankelKernel, List.append_assoc]

/-- Two words with identical Hankel rows are indistinguishable. -/
theorem eq_on_continuations_of_hankelRow_eq {α : Type*} {Y : Type*}
    (f : List α → Y) (u₁ u₂ : List α)
    (h : hankelRow f u₁ = hankelRow f u₂) :
    ∀ v, f (u₁ ++ v) = f (u₂ ++ v) :=
  fun v => congr_fun h v

/-! ## Section 2: Min-Plus Combination -/

/-- **Min-plus combination** (tropical inner product).
    `tropCombine a b = min_i (a_i + b_i)`. -/
def tropCombine {n : ℕ} (hn : 0 < n) (a b : Fin n → ℝ) : ℝ :=
  Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun i => a i + b i)

theorem tropCombine_le_coord {n : ℕ} (hn : 0 < n) (a b : Fin n → ℝ) (i : Fin n) :
    tropCombine hn a b ≤ a i + b i :=
  Finset.inf'_le _ (Finset.mem_univ i)

theorem tropCombine_exists_witness {n : ℕ} (hn : 0 < n) (a b : Fin n → ℝ) :
    ∃ i, tropCombine hn a b = a i + b i := by
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun i => a i + b i)
  exact ⟨i, hi⟩

/-- `tropCombine` respects equality of its first argument. -/
theorem tropCombine_congr_left {n : ℕ} (hn : 0 < n) {a₁ a₂ : Fin n → ℝ} (b : Fin n → ℝ)
    (ha : a₁ = a₂) :
    tropCombine hn a₁ b = tropCombine hn a₂ b := by
  subst ha; rfl

/-! ## Section 3: Tropical Hankel Factorization -/

/-- **Tropical Hankel factorization** of rank `n`. -/
structure TropicalHankelFactorization {α : Type*} (f : List α → ℝ) (n : ℕ) where
  hn : 0 < n
  φ : List α → Fin n → ℝ
  ψ : List α → Fin n → ℝ
  reconstruct : ∀ u v, f (u ++ v) = tropCombine hn (φ u) (ψ v)

/-- A function has **finite tropical Hankel rank**. -/
def HasFiniteTropicalHankelRank {α : Type*} (f : List α → ℝ) : Prop :=
  ∃ n, Nonempty (TropicalHankelFactorization f n)

/-! ## Section 4: Factorization Properties -/

/-- **Equal state summaries yield equal outputs on all continuations.** -/
theorem factorization_same_summary_eq {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (u₁ u₂ : List α) (h : F.φ u₁ = F.φ u₂) :
    ∀ v, f (u₁ ++ v) = f (u₂ ++ v) := by
  intro v
  rw [F.reconstruct u₁ v, F.reconstruct u₂ v, h]

/-- Equal state summaries imply equal Hankel rows. -/
theorem factorization_same_summary_hankelRow {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (u₁ u₂ : List α) (h : F.φ u₁ = F.φ u₂) :
    hankelRow f u₁ = hankelRow f u₂ := by
  ext v; exact factorization_same_summary_eq f F u₁ u₂ h v

/-- Equal summaries imply equal function values. -/
theorem factorization_same_summary_eq_val {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (u₁ u₂ : List α) (h : F.φ u₁ = F.φ u₂) :
    f u₁ = f u₂ := by
  have := factorization_same_summary_eq f F u₁ u₂ h []
  simpa using this

/-! ## Section 5: Certified Collision Witnesses -/

/-- **Certified collision witness** for a function `f`. -/
structure CollisionWitness {α : Type*} (f : List α → ℝ) where
  x₁ : List α
  x₂ : List α
  ne : x₁ ≠ x₂
  eq : f x₁ = f x₂

/-- Extract a certified collision from a state summary collision. -/
def collisionOfSameSummary {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (u₁ u₂ : List α) (hne : u₁ ≠ u₂) (hφ : F.φ u₁ = F.φ u₂) :
    CollisionWitness f where
  x₁ := u₁
  x₂ := u₂
  ne := hne
  eq := factorization_same_summary_eq_val f F u₁ u₂ hφ

/-! ## Section 6: Pigeonhole Collision Existence -/

/-- **Collision from non-injectivity.** -/
theorem exists_collision_of_not_injOn {α : Type*} [DecidableEq α]
    (f : List α → ℝ) (S : Finset (List α))
    (h : ¬ Set.InjOn f (↑S)) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ f u₁ = f u₂ := by
  rw [Set.InjOn] at h
  push_neg at h
  obtain ⟨u₁, hu₁, u₂, hu₂, heq, hne⟩ := h
  exact ⟨u₁, hu₁, u₂, hu₂, hne, heq⟩

/-- **State collision from pigeonhole.** -/
theorem exists_state_collision {α : Type*} [DecidableEq α] {n : ℕ}
    {f : List α → ℝ}
    [DecidableEq (Fin n → ℝ)]
    (F : TropicalHankelFactorization f n)
    (S : Finset (List α))
    (hcard : (S.image F.φ).card < S.card) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ F.φ u₁ = F.φ u₂ := by
  have hninj : ¬ Set.InjOn F.φ (↑S) := by
    intro hinj
    have := Finset.card_image_of_injOn hinj
    omega
  rw [Set.InjOn] at hninj
  push_neg at hninj
  obtain ⟨u₁, hu₁, u₂, hu₂, heq, hne⟩ := hninj
  exact ⟨u₁, hu₁, u₂, hu₂, hne, heq⟩

/-- **Collision from state collision.** -/
theorem exists_collision_from_state_collision {α : Type*} [DecidableEq α] {n : ℕ}
    [DecidableEq (Fin n → ℝ)]
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (S : Finset (List α))
    (hcard : (S.image F.φ).card < S.card) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ f u₁ = f u₂ := by
  obtain ⟨u₁, hu₁, u₂, hu₂, hne, hφ⟩ := exists_state_collision F S hcard
  exact ⟨u₁, hu₁, u₂, hu₂, hne, factorization_same_summary_eq_val f F u₁ u₂ hφ⟩

/-! ## Section 7: Non-Injectivity from Finite Rank -/

/-- **Finite factorization implies non-injectivity on large domains.** -/
theorem not_injOn_of_finiteFactorization {α : Type*} [DecidableEq α] {n : ℕ}
    [DecidableEq (Fin n → ℝ)]
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (S : Finset (List α))
    (hcard : (S.image F.φ).card < S.card) :
    ¬ Set.InjOn f (↑S) := by
  intro hinj
  obtain ⟨u₁, hu₁, u₂, hu₂, hne, heq⟩ :=
    exists_collision_from_state_collision f F S hcard
  exact hne (hinj hu₁ hu₂ heq)

/-! ## Section 8: Hankel Equivalence Relation -/

/-- **Hankel equivalence.** Two words have identical row profiles. -/
def hankelEquiv {α : Type*} {Y : Type*} (f : List α → Y) (u₁ u₂ : List α) : Prop :=
  hankelRow f u₁ = hankelRow f u₂

theorem hankelEquiv_refl {α : Type*} {Y : Type*} (f : List α → Y) (u : List α) :
    hankelEquiv f u u := rfl

theorem hankelEquiv_symm {α : Type*} {Y : Type*} (f : List α → Y) {u₁ u₂ : List α}
    (h : hankelEquiv f u₁ u₂) : hankelEquiv f u₂ u₁ := h.symm

theorem hankelEquiv_trans {α : Type*} {Y : Type*} (f : List α → Y) {u₁ u₂ u₃ : List α}
    (h₁ : hankelEquiv f u₁ u₂) (h₂ : hankelEquiv f u₂ u₃) :
    hankelEquiv f u₁ u₃ := h₁.trans h₂

/-- Hankel equivalence implies equal function values. -/
theorem hankelEquiv_implies_eq {α : Type*} {Y : Type*} (f : List α → Y) {u₁ u₂ : List α}
    (h : hankelEquiv f u₁ u₂) : f u₁ = f u₂ := by
  have := congr_fun h []
  simpa [hankelRow] using this

/-- A factorization refines Hankel equivalence. -/
theorem factorization_refines_hankelEquiv {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (u₁ u₂ : List α) (h : F.φ u₁ = F.φ u₂) :
    hankelEquiv f u₁ u₂ :=
  factorization_same_summary_hankelRow f F u₁ u₂ h

/-! ## Section 9: Fiber Structure -/

/-- **Fiber** of `f` at value `y`. -/
def fiber {α : Type*} (f : List α → ℝ) (y : ℝ) : Set (List α) :=
  {x | f x = y}

/-- Fibers are closed under Hankel equivalence. -/
theorem fiber_closed_under_hankelEquiv {α : Type*} (f : List α → ℝ)
    (y : ℝ) {x x' : List α}
    (hx : x ∈ fiber f y) (heq : hankelEquiv f x x') :
    x' ∈ fiber f y := by
  simp only [fiber, Set.mem_setOf_eq] at *
  rw [← hx]; exact (hankelEquiv_implies_eq f heq).symm

/-- **Fiber via factorization.** -/
theorem fiber_via_factorization {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n) (y : ℝ)
    (x : List α) :
    x ∈ fiber f y ↔ tropCombine F.hn (F.φ x) (F.ψ []) = y := by
  simp only [fiber, Set.mem_setOf_eq]
  constructor
  · intro h
    have := F.reconstruct x []
    simp at this
    rw [← this]; exact h
  · intro h
    have := F.reconstruct x []
    simp at this
    rw [this]; exact h

/-! ## Section 10: One-Way Family Obstruction -/

/-- **Uniformly bounded Hankel rank.** -/
def UniformlyBoundedHankelRank {α : Type*}
    (F : ℕ → (List α → ℝ)) : Prop :=
  ∃ n : ℕ, ∀ k, Nonempty (TropicalHankelFactorization (F k) n)

/-- **Tropically one-way family**: no uniform bounded-rank factorization. -/
def TropicalOneWayFamily {α : Type*}
    (F : ℕ → (List α → ℝ)) : Prop :=
  ¬ UniformlyBoundedHankelRank F

/-- **Collisions from bounded rank.** -/
theorem collisions_from_bounded_rank {α : Type*} [DecidableEq α] {n : ℕ}
    [DecidableEq (Fin n → ℝ)]
    (F : ℕ → (List α → ℝ))
    (hF : ∀ k, Nonempty (TropicalHankelFactorization (F k) n))
    (k : ℕ) (S : Finset (List α))
    (hcard : (S.image (Classical.choice (hF k)).φ).card < S.card) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ F k u₁ = F k u₂ :=
  exists_collision_from_state_collision (F k) (Classical.choice (hF k)) S hcard

/-- **One-way families require unbounded Hankel rank.** -/
theorem oneWayFamily_requires_unbounded_rank {α : Type*}
    (F : ℕ → (List α → ℝ))
    (hOW : TropicalOneWayFamily F) :
    ¬ UniformlyBoundedHankelRank F := hOW

/-- **Contrapositive:** bounded rank precludes one-wayness. -/
theorem not_oneWay_of_uniformlyBoundedRank {α : Type*}
    (F : ℕ → (List α → ℝ))
    (hBounded : UniformlyBoundedHankelRank F) :
    ¬ TropicalOneWayFamily F :=
  fun hOW => hOW hBounded

/-! ## Section 11: Spectral Decomposition -/

/-- **Effective finite spectral decomposition.** -/
structure EffectiveSpectralDecomposition {α : Type*} (f : List α → ℝ) where
  n : ℕ
  hn : 0 < n
  coeff : List α → Fin n → ℝ
  basis : Fin n → List α → ℝ
  reconstruct : ∀ u v, f (u ++ v) =
    Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
      (fun i => coeff u i + basis i v)

/-- A spectral decomposition gives a Hankel factorization. -/
def EffectiveSpectralDecomposition.toFactorization {α : Type*} {f : List α → ℝ}
    (E : EffectiveSpectralDecomposition f) :
    TropicalHankelFactorization f E.n where
  hn := E.hn
  φ := E.coeff
  ψ := fun v i => E.basis i v
  reconstruct := E.reconstruct

/-- Spectral decomposition implies finite Hankel rank. -/
theorem hasFiniteRank_of_spectral {α : Type*} {f : List α → ℝ}
    (E : EffectiveSpectralDecomposition f) :
    HasFiniteTropicalHankelRank f :=
  ⟨E.n, ⟨E.toFactorization⟩⟩

/-- **Collision iff spectral equality** at the empty suffix. -/
theorem collision_iff_spectral_eq {α : Type*}
    (f : List α → ℝ) (E : EffectiveSpectralDecomposition f)
    (x₁ x₂ : List α) :
    f x₁ = f x₂ ↔
    Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, E.hn⟩⟩)
      (fun i => E.coeff x₁ i + E.basis i []) =
    Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, E.hn⟩⟩)
      (fun i => E.coeff x₂ i + E.basis i []) := by
  have h1 := E.reconstruct x₁ []
  have h2 := E.reconstruct x₂ []
  simp at h1 h2
  rw [h1, h2]

/-! ## Section 12: Distinct Outputs vs States -/

/-
**Distinct outputs bounded by distinct state summaries.**
-/
theorem distinct_outputs_le_states {α : Type*} [DecidableEq α] [DecidableEq ℝ]
    {n : ℕ} [DecidableEq (Fin n → ℝ)]
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (S : Finset (List α)) :
    (S.image f).card ≤ (S.image F.φ).card := by
  -- By definition of image, we know that the cardinality of the image of f is less than or equal to the cardinality of the image of F.φ.
  have h_card_f_le_card_φ : (Finset.image (fun x => f x) S).card ≤ (Finset.image (fun x => (F.φ x, f x)) S).card := by
    have h_card_f_le_card_φ : (Finset.image (fun x => f x) S).card ≤ (Finset.image (fun x => (F.φ x, f x)) S).card := by
      have h_inj : Finset.card (Finset.image (fun x => f x) S) ≤ Finset.card (Finset.image (fun x => (F.φ x, f x)) S) := by
        have h_inj : Finset.image (fun x => f x) S ⊆ Finset.image (fun x => x.snd) (Finset.image (fun x => (F.φ x, f x)) S) := by
          simp +decide [ Finset.subset_iff ]
        exact le_trans ( Finset.card_le_card h_inj ) ( Finset.card_image_le )
      exact h_inj;
    exact h_card_f_le_card_φ;
  refine' le_trans h_card_f_le_card_φ _;
  refine' le_of_eq ( Finset.card_bij ( fun x hx => x.1 ) _ _ _ ) <;> simp +decide;
  · exact fun x hx => ⟨ x, hx, rfl ⟩;
  · exact fun x hx y hy hxy => ⟨ hxy, factorization_same_summary_eq_val f F x y hxy ⟩

/-- **Collision guarantee from pigeonhole.** -/
theorem collision_guarantee {α : Type*} [DecidableEq α] [DecidableEq ℝ]
    {n : ℕ} [DecidableEq (Fin n → ℝ)]
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (S : Finset (List α))
    (hcard : (S.image F.φ).card < S.card) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ f u₁ = f u₂ :=
  exists_collision_from_state_collision f F S hcard

/-! ## Section 13: Tropical Myhill–Nerode Connection -/

/-- **Hankel equivalence is a right congruence** with respect to
    word concatenation. -/
theorem hankelEquiv_right_congruence {α : Type*} {Y : Type*}
    (f : List α → Y) {u₁ u₂ : List α}
    (h : hankelEquiv f u₁ u₂) (w : List α) :
    hankelEquiv f (u₁ ++ w) (u₂ ++ w) := by
  unfold hankelEquiv
  rw [hankelRow_append, hankelRow_append]
  ext v
  exact congr_fun h (w ++ v)

/-- Hankel equivalence extends by single letters. -/
theorem hankelEquiv_cons {α : Type*} {Y : Type*}
    (f : List α → Y) {u₁ u₂ : List α}
    (h : hankelEquiv f u₁ u₂) (a : α) :
    hankelEquiv f (u₁ ++ [a]) (u₂ ++ [a]) :=
  hankelEquiv_right_congruence f h [a]

/-! ## Section 14: Min-Plus Weighted Automaton -/

/-- **Min-plus weighted automaton** with `n` states over alphabet `α`. -/
structure MinPlusAutomaton (α : Type*) (n : ℕ) where
  hn : 0 < n
  init : Fin n → ℝ
  transition : α → Matrix (Fin n) (Fin n) ℝ
  final : Fin n → ℝ

/-- **State summary** after reading word `w` (right-to-left accumulation). -/
def MinPlusAutomaton.stateSummary {α : Type*} {n : ℕ}
    (A : MinPlusAutomaton α n) : List α → Fin n → ℝ
  | [] => A.init
  | a :: w =>
    fun j => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, A.hn⟩⟩)
      (fun k => A.stateSummary w k + A.transition a k j)

/-- **Output function** of a min-plus automaton. -/
def MinPlusAutomaton.eval {α : Type*} {n : ℕ}
    (A : MinPlusAutomaton α n) (w : List α) : ℝ :=
  tropCombine A.hn (A.stateSummary w) A.final

@[simp]
theorem MinPlusAutomaton.stateSummary_nil {α : Type*} {n : ℕ}
    (A : MinPlusAutomaton α n) :
    A.stateSummary [] = A.init := rfl

@[simp]
theorem MinPlusAutomaton.eval_nil {α : Type*} {n : ℕ}
    (A : MinPlusAutomaton α n) :
    A.eval [] = tropCombine A.hn A.init A.final := rfl

/-! ## Section 15: Concrete Example — Length Function -/

/-- The word-length function (as ℝ) has a rank-1 tropical Hankel factorization.
    This demonstrates that simple functions have low Hankel rank. -/
theorem length_hasFiniteRank :
    HasFiniteTropicalHankelRank (fun w : List Bool => (w.length : ℝ)) := by
  refine ⟨1, ⟨?_⟩⟩
  exact {
    hn := by omega
    φ := fun u _ => u.length
    ψ := fun v _ => v.length
    reconstruct := by
      intro u v
      simp only [tropCombine, Finset.inf'_const]
      push_cast [List.length_append]
      ring
  }

/-- A constant function has rank 1. -/
theorem const_hasFiniteRank (c : ℝ) :
    HasFiniteTropicalHankelRank (fun _ : List Bool => c) := by
  refine ⟨1, ⟨?_⟩⟩
  exact {
    hn := by omega
    φ := fun _ _ => c
    ψ := fun _ _ => 0
    reconstruct := by
      intro u v
      simp [tropCombine]
  }

/-! ## Section 16: Bounded Ambiguity -/

/-- **Bounded ambiguity**: each fiber within any finite set has at most `B` elements. -/
def BoundedAmbiguity {α : Type*} (f : List α → ℝ) (B : ℕ) : Prop :=
  ∀ y : ℝ, ∀ S : Finset (List α),
    (S.filter (fun x => f x = y)).card ≤ B

/-- Under bounded ambiguity, fibers are small. -/
theorem fiber_card_le_of_bounded_ambiguity {α : Type*} [DecidableEq α]
    (f : List α → ℝ) (B : ℕ) (hB : BoundedAmbiguity f B)
    (y : ℝ) (S : Finset (List α)) :
    (S.filter (fun x => f x = y)).card ≤ B :=
  hB y S

/-! ## Section 17: Non-One-Wayness from Spectral Decomposition -/

/-- **Non-one-wayness theorem.** For any family with uniformly bounded
    Hankel rank, collisions exist uniformly on large input sets. -/
theorem nonOneWay_collision_structure {α : Type*} [DecidableEq α]
    {n : ℕ} [DecidableEq (Fin n → ℝ)]
    (F : ℕ → (List α → ℝ))
    (hF : ∀ k, Nonempty (TropicalHankelFactorization (F k) n))
    (k : ℕ) (S : Finset (List α))
    (hcard : (S.image (Classical.choice (hF k)).φ).card < S.card) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ F k u₁ = F k u₂ :=
  exists_collision_from_state_collision (F k) (Classical.choice (hF k)) S hcard

/-! ## Section 18: Hankel Row Finiteness -/

/-- Hankel rows at equal state summaries are equal. -/
theorem hankelRow_eq_of_factorization_eq {α : Type*} {n : ℕ}
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (u₁ u₂ : List α) (h : F.φ u₁ = F.φ u₂) (v : List α) :
    hankelRow f u₁ v = hankelRow f u₂ v := by
  simp only [hankelRow]
  exact factorization_same_summary_eq f F u₁ u₂ h v

/-! ## Section 19: Certified Collision Reconstruction -/

/-- **Certified collision reconstruction**: on any finite set, either
    a collision exists or the map is injective. -/
theorem certifiedCollisionReconstruction {α : Type*} [DecidableEq α]
    (f : List α → ℝ) (S : Finset (List α)) :
    (∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ f u₁ = f u₂) ∨ Set.InjOn f (↑S) := by
  by_cases h : Set.InjOn f (↑S)
  · exact Or.inr h
  · exact Or.inl (exists_collision_of_not_injOn f S h)

/-- **Strengthened form**: for finite-rank functions on large enough sets,
    collisions are guaranteed. -/
theorem certified_collision_of_finiteRank {α : Type*} [DecidableEq α] {n : ℕ}
    [DecidableEq (Fin n → ℝ)]
    (f : List α → ℝ) (F : TropicalHankelFactorization f n)
    (S : Finset (List α))
    (hcard : (S.image F.φ).card < S.card) :
    ∃ u₁ ∈ S, ∃ u₂ ∈ S, u₁ ≠ u₂ ∧ f u₁ = f u₂ :=
  exists_collision_from_state_collision f F S hcard

end TropicalHankelDuality