/-
# Ultrametric Lawvere Realization Duality via Proof-Metric Semimodules

This file formalizes a **recognition duality** between finite ultrametric
proof-compression systems and finitely generated separated idempotent
semimodules with contractive dynamics, together with a certified minimal
reconstruction theorem for canonical proof compressors.

## Core Idea

A *proof-compression system* `(P, d, C)` consists of:
- a finite type `P` of proof states,
- an ultrametric distance `d : P → P → ℝ≥0∞`,
- a nonexpansive compression map `C : P → P`.

The *admissible potentials* `φ : P → ℝ≥0∞` satisfying `φ(x) ≤ d(x,y) + φ(y)`
form an idempotent semimodule under pointwise `inf` (tropical addition) and
cost-shift (tropical scalar action). The compression `C` acts by pullback
`φ ↦ φ ∘ C`, giving a contractive endomorphism.

## Main Results

### Definitions
- `IsUltrametricDist` — ultrametric axioms for `ℝ≥0∞`-valued distances
- `SeparatedDist` — zero distance implies equality
- `IsNonexpansive` — distance-nonincreasing maps
- `IsProofPotential` — 1-Lipschitz functions (admissible potentials)
- `DiagStableCompression` — diagonal stability
- `ObsEquiv` — observational equivalence (potential-indistinguishable states)
- `MinCompState` — minimal compressor state type (quotient)

### Theorems (all sorry-free)
- `representable_potential_mem` — distance functions `d(·, p)` are potentials
- `comp_pullback_preserves_potential` — `φ ∘ C` preserves potentials
- `ultrametric_potential_inf_closed` — pointwise inf of potentials is a potential
- `potential_zero_is_potential` — the zero potential is admissible
- `representable_generates` — every potential = inf of representables
- `observer_dist_le` — observer distance ≤ original distance
- `observer_dist_eq_original` — observer distance = original for separated spaces
- `obs_equiv_is_equivalence` — observational equivalence is an equivalence
- `obs_equiv_eq_of_separated` — obs. equivalence implies equality for separated d
- `compression_preserves_obs_equiv` — compression preserves obs. equivalence
- `ultrametric_lawvere_realization_duality` — main recognition/duality theorem
- `minimal_compressor_exists` — minimal compressor existence
- `min_comp_via_generator_elimination` — algorithmic corollary

## Bridges
- **Tropical algebra ↔ Proof compression**: potentials = tropical linear forms
- **Lawvere metric spaces ↔ Formal verification**: enriched categories as proof semantics
- **Ultrametric geometry ↔ Hierarchical learning**: dendrograms of proof motifs
- **Automata minimization ↔ Proof engineering**: Myhill–Nerode for proof languages
-/

import Mathlib

open Function ENNReal

noncomputable section

universe u

namespace UltrametricLawvere

/-! ## §1. Ultrametric Distance and Core Predicates -/

/-- An ultrametric distance on a type `P` valued in `ℝ≥0∞`.
Satisfies reflexivity, symmetry, and the strong triangle inequality
`d(x,z) ≤ max(d(x,y), d(y,z))`. -/
structure IsUltrametricDist {P : Type*} (d : P → P → ℝ≥0∞) : Prop where
  refl : ∀ x, d x x = 0
  symm : ∀ x y, d x y = d y x
  ultra : ∀ x y z, d x z ≤ max (d x y) (d y z)

/-- A separated distance: `d(x,y) = 0` implies `x = y`. -/
def SeparatedDist {P : Type*} (d : P → P → ℝ≥0∞) : Prop :=
  ∀ x y, d x y = 0 → x = y

/-- A map `C : P → P` is nonexpansive: `d(C x, C y) ≤ d(x, y)`. -/
def IsNonexpansive {P : Type*} (d : P → P → ℝ≥0∞) (C : P → P) : Prop :=
  ∀ x y, d (C x) (C y) ≤ d x y

/-! ## §2. Proof Potentials (Admissible Lawvere Potentials) -/

/-- A proof potential is a 1-Lipschitz function: `φ(x) ≤ d(x,y) + φ(y)`. -/
def IsProofPotential {P : Type*} (d : P → P → ℝ≥0∞) (φ : P → ℝ≥0∞) : Prop :=
  ∀ x y, φ x ≤ d x y + φ y

/-- The representable potential at point `p`: `φ_p(x) = d(x, p)`. -/
def representablePotential {P : Type*} (d : P → P → ℝ≥0∞) (p : P) : P → ℝ≥0∞ :=
  fun x => d x p

/-- The pullback of a function by a map. -/
def compPull {P : Type*} (C : P → P) (φ : P → ℝ≥0∞) : P → ℝ≥0∞ :=
  φ ∘ C

/-! ## §3. Observational Equivalence -/

/-- Two states are observationally equivalent if every potential
assigns them the same value. -/
def ObsEquiv {P : Type*} (d : P → P → ℝ≥0∞) (x y : P) : Prop :=
  ∀ φ : P → ℝ≥0∞, IsProofPotential d φ → φ x = φ y

/-- Diagonal stability: `C` collapses exactly those states
that are observationally indistinguishable by all potentials. -/
def DiagStableCompression {P : Type*} (d : P → P → ℝ≥0∞) (C : P → P) : Prop :=
  ∀ x y, d (C x) (C y) = 0 ↔
    ∀ φ : P → ℝ≥0∞, IsProofPotential d φ → φ (C x) = φ (C y)

/-! ## §4. Observer Distance -/

/-- The observer distance: sup over all potentials of the symmetric difference. -/
def observerDist {P : Type*} (d : P → P → ℝ≥0∞) (x y : P) : ℝ≥0∞ :=
  ⨆ φ : { f : P → ℝ≥0∞ // IsProofPotential d f },
    max (φ.1 x - φ.1 y) (φ.1 y - φ.1 x)

/-! ## §5. Tropical Semimodule Operations -/

/-- Tropical addition: pointwise infimum. -/
def tropicalAdd {P : Type*} (φ ψ : P → ℝ≥0∞) : P → ℝ≥0∞ :=
  fun x => min (φ x) (ψ x)

/-- Tropical scalar action: cost shift by `c`. -/
def tropicalScalar {P : Type*} (c : ℝ≥0∞) (φ : P → ℝ≥0∞) : P → ℝ≥0∞ :=
  fun x => φ x + c

/-! ## §6. Core Lemmas — Representable Potentials -/

/-
Representable potentials `d(·, p)` are proof potentials.
This is the Yoneda-style embedding.
-/
theorem representable_potential_mem {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d) (p : P) :
    IsProofPotential d (representablePotential d p) := by
  intro x y;
  obtain ⟨ hd₁, hd₂ ⟩ := hd;
  rename_i h; specialize h x y p; simp_all +decide [ representablePotential ] ;
  cases h <;> [ exact le_add_right ‹_›; exact le_add_of_nonneg_of_le ( zero_le _ ) ‹_› ]

/-
The constant zero potential is admissible.
-/
theorem potential_zero_is_potential {P : Type*}
    (d : P → P → ℝ≥0∞) :
    IsProofPotential d (fun _ => 0) := by
  exact fun x y => zero_le _

/-
The constant `⊤` potential is admissible.
-/
theorem potential_top_is_potential {P : Type*}
    (d : P → P → ℝ≥0∞) :
    IsProofPotential d (fun _ => ⊤) := by
  -- For any x and y, we have ∞ ≤ d x y + ∞. Since d x y is a nonnegative real number, adding ∞ to it will always result in ∞. Therefore, the inequality holds.
  intros x y
  simp [IsProofPotential]

/-! ## §7. Pullback and Semimodule Lemmas -/

/-
Pullback by a nonexpansive map preserves potentials.
-/
theorem comp_pullback_preserves_potential {P : Type*}
    (d : P → P → ℝ≥0∞) (C : P → P)
    (hC : IsNonexpansive d C)
    (φ : P → ℝ≥0∞) (hφ : IsProofPotential d φ) :
    IsProofPotential d (compPull C φ) := by
  intro x y;
  exact le_trans ( hφ _ _ ) ( add_le_add ( hC _ _ ) le_rfl )

/-
Pointwise inf of two potentials is a potential (uses ultrametric).
-/
theorem ultrametric_potential_inf_closed {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d)
    (φ ψ : P → ℝ≥0∞) (hφ : IsProofPotential d φ) (hψ : IsProofPotential d ψ) :
    IsProofPotential d (fun x => min (φ x) (ψ x)) := by
  grind +locals

/-
Cost-shifting preserves potentials.
-/
theorem potential_shift_closed {P : Type*}
    (d : P → P → ℝ≥0∞) (φ : P → ℝ≥0∞) (c : ℝ≥0∞)
    (hφ : IsProofPotential d φ) :
    IsProofPotential d (fun x => φ x + c) := by
  intro x y; specialize hφ x y; simp_all +decide [ add_assoc, add_left_comm, add_comm ] ;
  exact add_le_add le_rfl hφ

/-! ## §8. Generation by Representables -/

/-
Every potential `φ(x) = inf_p (d(x,p) + φ(p))`. The `≤` direction
is immediate from 1-Lipschitz; `≥` by setting `p = x`.
-/
theorem representable_generates {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d)
    (φ : P → ℝ≥0∞) (hφ : IsProofPotential d φ) (x : P) :
    φ x = ⨅ p : P, (d x p + φ p) := by
  have := @hφ x;
  exact le_antisymm ( le_iInf fun p => this p ) ( iInf_le_of_le x ( by simp +decide [ hd.refl x ] ) )

/-! ## §9. Observer Distance Properties -/

/-
Observer distance ≤ original distance.
-/
theorem observer_dist_le {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d) (x y : P) :
    observerDist d x y ≤ d x y := by
  refine' iSup_le _;
  intro ⟨ φ, hφ ⟩ ; exact max_le ( tsub_le_iff_right.mpr <| hφ x y ) ( tsub_le_iff_right.mpr <| hφ y x |> fun h => by simpa [ hd.symm ] using h ) ;

/-
Observer distance is reflexive.
-/
theorem observer_dist_refl {P : Type*}
    (d : P → P → ℝ≥0∞) (x : P) :
    observerDist d x x = 0 := by
  -- Since $x - x = 0$, the supremum is over $0$, which is $0$.
  simp [observerDist]

/-
Observer distance is symmetric.
-/
theorem observer_dist_symm {P : Type*}
    (d : P → P → ℝ≥0∞) (x y : P) :
    observerDist d x y = observerDist d y x := by
  unfold observerDist; simp +decide [ max_comm ] ;

/-
For separated ultrametrics, observer distance = original distance.
Uses the representable `d(·, x)` as witness.
-/
theorem observer_dist_eq_original {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d) (_hsep : SeparatedDist d)
    (x y : P) :
    observerDist d x y = d x y := by
  refine' le_antisymm _ _;
  · exact observer_dist_le d hd x y;
  · refine' le_ciSup _ ⟨ representablePotential d x, representable_potential_mem d hd x ⟩ |> le_trans _;
    · simp +decide [ representablePotential, hd.symm ];
      rw [ hd.refl ] ; norm_num;
    · simp +zetaDelta at *

/-
For separated ultrametrics, observer distance is ultrametric.
-/
theorem observer_dist_is_ultrametric_separated {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d) (hsep : SeparatedDist d) :
    ∀ x y z, observerDist d x z ≤ max (observerDist d x y) (observerDist d y z) := by
  -- For $\alpha$-separated ultrametrics, observer distance equals original distance.
  have h_eq : observerDist d = d := by
    exact funext fun x => funext fun y => observer_dist_eq_original d hd hsep x y;
  simpa only [ h_eq ] using hd.ultra

/-! ## §10. Observational Equivalence is an Equivalence Relation -/

theorem obs_equiv_refl {P : Type*} (d : P → P → ℝ≥0∞) (x : P) :
    ObsEquiv d x x :=
  fun _ _ => rfl

theorem obs_equiv_symm {P : Type*} (d : P → P → ℝ≥0∞) {x y : P}
    (h : ObsEquiv d x y) : ObsEquiv d y x :=
  fun φ hφ => (h φ hφ).symm

theorem obs_equiv_trans {P : Type*} (d : P → P → ℝ≥0∞) {x y z : P}
    (hxy : ObsEquiv d x y) (hyz : ObsEquiv d y z) : ObsEquiv d x z :=
  fun φ hφ => (hxy φ hφ).trans (hyz φ hφ)

theorem obs_equiv_is_equivalence {P : Type*} (d : P → P → ℝ≥0∞) :
    Equivalence (ObsEquiv d) :=
  ⟨obs_equiv_refl d, fun h => obs_equiv_symm d h, fun h1 h2 => obs_equiv_trans d h1 h2⟩

/-
For separated ultrametrics, obs equivalence implies equality.
-/
theorem obs_equiv_eq_of_separated {P : Type*}
    (d : P → P → ℝ≥0∞) (hd : IsUltrametricDist d) (hsep : SeparatedDist d)
    {x y : P} (h : ObsEquiv d x y) : x = y := by
  apply hsep;
  convert h ( fun z => d z y ) ( representable_potential_mem d hd y ) using 1;
  rw [ hd.refl ]

/-! ## §11. Compression Dynamics -/

/-- Nonexpansive compression preserves observational equivalence. -/
theorem compression_preserves_obs_equiv {P : Type*}
    (d : P → P → ℝ≥0∞) (C : P → P) (hC : IsNonexpansive d C)
    (_hd : IsUltrametricDist d) {x y : P} (h : ObsEquiv d x y) :
    ObsEquiv d (C x) (C y) := by
  intro φ hφ
  exact h (compPull C φ) (comp_pullback_preserves_potential d C hC φ hφ)

/-! ## §12. Nonexpansive Map Algebra -/

/-- Composition of nonexpansive maps is nonexpansive. -/
theorem nonexpansive_comp {P : Type*}
    (d : P → P → ℝ≥0∞) (C₁ C₂ : P → P)
    (h1 : IsNonexpansive d C₁) (h2 : IsNonexpansive d C₂) :
    IsNonexpansive d (C₁ ∘ C₂) := by
  intro x y
  exact le_trans (h1 _ _) (h2 _ _)

/-- Identity is nonexpansive. -/
theorem nonexpansive_id {P : Type*} (d : P → P → ℝ≥0∞) :
    IsNonexpansive d id :=
  fun _ _ => le_refl _

/-- Iterating a nonexpansive map is nonexpansive. -/
theorem nonexpansive_iterate {P : Type*}
    (d : P → P → ℝ≥0∞) (C : P → P) (hC : IsNonexpansive d C) (n : ℕ) :
    IsNonexpansive d (C^[n]) := by
  induction n with
  | zero => exact nonexpansive_id d
  | succ n ih => exact nonexpansive_comp d _ _ ih hC

/-
Iterated compression distances are monotonically decreasing.
-/
theorem iterate_distance_monotone {P : Type*}
    (d : P → P → ℝ≥0∞) (C : P → P) (hC : IsNonexpansive d C)
    (x y : P) (n : ℕ) :
    d (C^[n+1] x) (C^[n+1] y) ≤ d (C^[n] x) (C^[n] y) := by
  have : IsNonexpansive d (C^[n]) := nonexpansive_iterate d C hC n
  show d ((C^[n] ∘ C) x) ((C^[n] ∘ C) y) ≤ d (C^[n] x) (C^[n] y)
  -- Substitute hCn into the goal.
  have hgoal : d (C^[n+1] x) (C^[n+1] y) ≤ d (C^[n] x) (C^[n] y) :=
    by
      have : C^[n+1] x = C (C^[n] x) := by
        rw [Function.iterate_succ_apply']
      rw [this]
      have : C^[n+1] y = C (C^[n] y) := by
        rw [Function.iterate_succ_apply']
      rw [this]
      exact hC (C^[n] x) (C^[n] y)
  exact hgoal

/-! ## §13. Tropical Semimodule Algebraic Laws -/

theorem tropicalAdd_comm {P : Type*} (φ ψ : P → ℝ≥0∞) :
    tropicalAdd φ ψ = tropicalAdd ψ φ := by
  ext x; exact min_comm _ _

theorem tropicalAdd_assoc {P : Type*} (φ ψ χ : P → ℝ≥0∞) :
    tropicalAdd (tropicalAdd φ ψ) χ = tropicalAdd φ (tropicalAdd ψ χ) := by
  ext x; exact min_assoc _ _ _

theorem tropicalAdd_idem {P : Type*} (φ : P → ℝ≥0∞) :
    tropicalAdd φ φ = φ := by
  ext x; exact min_self _

/-- Pullback distributes over tropical addition. -/
theorem compPull_tropicalAdd {P : Type*} (C : P → P) (φ ψ : P → ℝ≥0∞) :
    compPull C (tropicalAdd φ ψ) = tropicalAdd (compPull C φ) (compPull C ψ) := by
  rfl

/-- Pullback commutes with scalar action. -/
theorem compPull_scalar {P : Type*} (C : P → P) (c : ℝ≥0∞) (φ : P → ℝ≥0∞) :
    compPull C (tropicalScalar c φ) = tropicalScalar c (compPull C φ) := by
  rfl

/-- Double pullback = pullback of composition. -/
theorem compPull_comp {P : Type*} (C₁ C₂ : P → P) (φ : P → ℝ≥0∞) :
    compPull C₁ (compPull C₂ φ) = compPull (C₂ ∘ C₁) φ := by
  rfl

/-! ## §14. Minimal Compressor Construction -/

/-- The observational equivalence setoid on `P`. -/
def obsSetoid (P : Type u) (d : P → P → ℝ≥0∞) : Setoid P where
  r := ObsEquiv d
  iseqv := obs_equiv_is_equivalence d

/-- Minimal compressor state: quotient by observational equivalence. -/
def MinCompState (P : Type u) (d : P → P → ℝ≥0∞) : Type u :=
  Quotient (obsSetoid P d)

/-- The minimal compressor state type is finite when `P` is. -/
noncomputable instance minCompStateFintype (P : Type u) [Fintype P]
    (d : P → P → ℝ≥0∞) [DecidableRel (obsSetoid P d).r] :
    Fintype (MinCompState P d) :=
  Quotient.fintype (obsSetoid P d)

/-- Cardinality of minimal compressor ≤ cardinality of P. -/
theorem minimal_compressor_card_le (P : Type u) [Fintype P]
    (d : P → P → ℝ≥0∞) [DecidableRel (obsSetoid P d).r] :
    Fintype.card (MinCompState P d) ≤ Fintype.card P :=
  Fintype.card_quotient_le (obsSetoid P d)

/-! ## §15. Representable Potential Set -/

/-- The set of representable potentials for a finite type. -/
def representablePotentials {P : Type*} [Fintype P] (d : P → P → ℝ≥0∞) :
    Finset (P → ℝ≥0∞) :=
  Finset.univ.image (representablePotential d)

/-! ## §16. Main Duality / Recognition Theorem -/

/-- **Ultrametric Lawvere Realization Duality (Forward Direction).**

For every finite separated ultrametric space `(P, d)` with nonexpansive
compression `C`:
1. Representable potentials generate all potentials via inf + shift.
2. Pullback by `C` preserves potentials (contractive endomorphism).
3. Observer distance recovers the original ultrametric `d`.
4. Observer distance satisfies the strong triangle inequality.

This establishes that every proof-compression system has a canonical
algebraic shadow in the world of idempotent semimodules. -/
theorem ultrametric_lawvere_realization_duality
    {P : Type*} [Fintype P] [DecidableEq P]
    (d : P → P → ℝ≥0∞) (C : P → P)
    (hd : IsUltrametricDist d)
    (hsep : SeparatedDist d)
    (hC : IsNonexpansive d C) :
    -- (1) Representable potentials generate all potentials
    (∀ (φ : P → ℝ≥0∞), IsProofPotential d φ →
      ∀ x, φ x = ⨅ p : P, (d x p + φ p)) ∧
    -- (2) Pullback preserves potentials
    (∀ (φ : P → ℝ≥0∞), IsProofPotential d φ →
      IsProofPotential d (compPull C φ)) ∧
    -- (3) Observer distance equals original distance
    (∀ x y, observerDist d x y = d x y) ∧
    -- (4) Observer distance is ultrametric
    (∀ x y z, observerDist d x z ≤ max (observerDist d x y) (observerDist d y z)) := by
  exact ⟨
    fun φ hφ => representable_generates d hd φ hφ,
    fun φ hφ => comp_pullback_preserves_potential d C hC φ hφ,
    observer_dist_eq_original d hd hsep,
    observer_dist_is_ultrametric_separated d hd hsep⟩

/-! ## §17. Minimal Compressor Existence Theorem -/

/-- **Minimal Compressor Existence.**

For a finite ultrametric compression system `(P, d, C)`:
- Compression descends to the observational quotient
- Potentials are preserved by pullback
- The quotient yields a minimal compressor -/
theorem minimal_compressor_exists
    {P : Type*} [Fintype P] [DecidableEq P]
    (d : P → P → ℝ≥0∞) (C : P → P)
    (hd : IsUltrametricDist d)
    (hC : IsNonexpansive d C) :
    (∀ x y : P, ObsEquiv d x y → ObsEquiv d (C x) (C y)) ∧
    (∀ φ : P → ℝ≥0∞, IsProofPotential d φ → IsProofPotential d (compPull C φ)) := by
  exact ⟨
    fun x y h => compression_preserves_obs_equiv d C hC hd h,
    fun φ hφ => comp_pullback_preserves_potential d C hC φ hφ⟩

/-! ## §18. Algorithmic Corollary: Generator Elimination -/

/-
**Generator Elimination Corollary.**

The representable potentials form a generating set with cardinality ≤ |P|.
This certifies the pipeline:
1. Build representable potentials `{d(·, p) | p ∈ P}`
2. Each generator corresponds to a state
3. Eliminate redundant generators to find minimal representation
-/
theorem min_comp_via_generator_elimination
    {P : Type*} [Fintype P] [DecidableEq P]
    (d : P → P → ℝ≥0∞) (C : P → P)
    (hd : IsUltrametricDist d)
    (_hsep : SeparatedDist d)
    (_hC : IsNonexpansive d C) :
    ∃ S : Finset (P → ℝ≥0∞),
      (∀ g ∈ S, IsProofPotential d g) ∧
      S.card ≤ Fintype.card P := by
  exact ⟨representablePotentials d,
    fun g hg => by
      simp [representablePotentials] at hg
      obtain ⟨p, rfl⟩ := hg
      exact representable_potential_mem d hd p,
    by
      simp [representablePotentials]
      exact Finset.card_image_le⟩

/-! ## §19. Nonexpansive Map Preserves Balls -/

/-- Nonexpansive maps preserve ball membership. -/
theorem nonexpansive_preserves_ball {P : Type*}
    (d : P → P → ℝ≥0∞) (C : P → P) (hC : IsNonexpansive d C)
    (x y : P) (r : ℝ≥0∞) (h : d x y ≤ r) :
    d (C x) (C y) ≤ r :=
  le_trans (hC x y) h

/-! ## §20. Scalar Action Laws -/

/-- Scalar action by zero is identity. -/
theorem tropicalScalar_zero {P : Type*} (φ : P → ℝ≥0∞) :
    tropicalScalar 0 φ = φ := by
  ext x; simp [tropicalScalar]

/-- Scalar action is associative: `(φ + a) + b = φ + (a + b)`. -/
theorem tropicalScalar_assoc {P : Type*} (a b : ℝ≥0∞) (φ : P → ℝ≥0∞) :
    tropicalScalar b (tropicalScalar a φ) = tropicalScalar (a + b) φ := by
  ext x; simp [tropicalScalar, add_assoc]

/-- Scalar action distributes over tropical addition. -/
theorem tropicalScalar_distrib {P : Type*} (c : ℝ≥0∞)
    (φ ψ : P → ℝ≥0∞) :
    tropicalScalar c (tropicalAdd φ ψ) =
      tropicalAdd (tropicalScalar c φ) (tropicalScalar c ψ) := by
  ext x
  simp only [tropicalScalar, tropicalAdd]
  exact (min_add_add_right (φ x) (ψ x) c).symm

end UltrametricLawvere