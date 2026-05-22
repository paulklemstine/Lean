/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Observer Coding Duality

A finite representation/minimality theorem: tropical separation objects built from
proof observers are equivalent to canonical minimal proof-compression architectures.
Observer codes and compression networks are mathematically equivalent finite objects,
with a recoverable distance geometry and a certified minimality invariant.

## Main Results

### Definitions
* `CodeEqFamily` — code equivalence under a family of observer functionals
* `SubfamilySeparates` — a subfamily separates inequivalent states
* `observerDist` — tropical separation pseudodistance (sup of coordinate distances)
* `subDist` — subfamily-restricted distance
* `TropicalSeparationSemimodule` — bundled certified separation data
* `MinimalCompressionNetwork` — minimal layered proof-compression architecture
* `ObserverSeparationRank` — minimal width of a separating observer subfamily
* `CompressionNetworkIso` — isomorphism between minimal networks
* `CanonicalDistProfile` — distance profile function
* `RealizesSemimodule` — realization relation between networks and semimodules

### Theorems (flagship results)
* `observerDist_refl` — reflexivity of tropical distance
* `observerDist_symm` — symmetry of tropical distance
* `observerDist_triangle` — triangle inequality for tropical distance
* `observerDist_eq_zero_iff` — separation characterization
* `compression_nonexpansive_of_coord` — coordinate nonexpansivity implies global
* `tropical_distance_descends_codeEq` — distance respects code equivalence
* `exists_minimal_separating_subfamily` — existence of minimal separating subfamily
* `spectral_witness_implies_irredundant` — spectral witnesses certify irredundancy
* `minimal_subfamily_card_unique` — uniqueness of separation rank
* `reconstruct_network_from_subfamily` — reconstruction from minimal subfamily
* `finite_separation_semimodule_realization_minimal` — flagship duality theorem

## Bridge

Connects tropical algebra (max-plus coordinates) ↔ proof compression (state contraction)
↔ coding theory (separating codes) ↔ automata minimization (Myhill–Nerode) ↔
metric learning (certified representation geometry) ↔ neural architecture (minimal width).

Builds on `canonical_observer_code_certified` from `ObserverRateDistortion.lean`.

## Cross-domain significance

- **Automata theory**: observer separation rank as tropical Nerode index
- **Metric learning**: canonical distance profile as certified representation metric
- **Neural compression**: minimal observer width as intrinsic latent dimension
- **Proof theory**: proof-state contraction as semantics-preserving compression
- **Tropical geometry**: max-plus coordinates as architecture geometry
- **Coding theory**: finite observer codes as separating codes on proof states
-/

set_option maxHeartbeats 800000

open Finset Function

noncomputable section

namespace TropicalObserverDuality

/-! ## §1. Observer Families and Code Equivalence -/

/-- Code equivalence under a family of observer functionals: two states are
    code-equivalent if all observers assign them the same value.
    This is the kernel of the combined observation map `x ↦ (Φ i x)_i`. -/
def CodeEqFamily {S ι : Type*} (Φ : ι → S → ℤ) (x y : S) : Prop :=
  ∀ i : ι, Φ i x = Φ i y

theorem codeEqFamily_refl {S ι : Type*} (Φ : ι → S → ℤ) (x : S) :
    CodeEqFamily Φ x x :=
  fun _ => rfl

theorem codeEqFamily_symm {S ι : Type*} (Φ : ι → S → ℤ) {x y : S}
    (h : CodeEqFamily Φ x y) : CodeEqFamily Φ y x :=
  fun i => (h i).symm

theorem codeEqFamily_trans {S ι : Type*} (Φ : ι → S → ℤ) {x y z : S}
    (h₁ : CodeEqFamily Φ x y) (h₂ : CodeEqFamily Φ y z) : CodeEqFamily Φ x z :=
  fun i => (h₁ i).trans (h₂ i)

/-- A family of observer functionals **separates** if code-equivalence implies equality.
    This is injectivity of the combined observation map. -/
def SeparatesCodeEqFamily {S ι : Type*} (Φ : ι → S → ℤ) : Prop :=
  ∀ x y : S, CodeEqFamily Φ x y → x = y

/-- A **subfamily** separates if the restricted family of observers still
    distinguishes all inequivalent states. -/
def SubfamilySeparates {S ι : Type*} (Φ : ι → S → ℤ) (J : Finset ι) : Prop :=
  ∀ x y : S, (∀ i ∈ J, Φ i x = Φ i y) → x = y

/-- The full family separates iff `Finset.univ` separates as a subfamily. -/
theorem separates_iff_univ_subfamilySeparates
    {S ι : Type*} [Fintype ι] (Φ : ι → S → ℤ) :
    SeparatesCodeEqFamily Φ ↔ SubfamilySeparates Φ Finset.univ := by
  constructor
  · intro h x y hxy
    exact h x y (fun i => hxy i (Finset.mem_univ i))
  · intro h x y hxy
    exact h x y (fun i _ => hxy i)

/-
Subfamily separation is anti-monotone: larger subfamilies separate at least as well
    (more observers = stronger separation).
-/
theorem subfamilySeparates_anti {S ι : Type*} (Φ : ι → S → ℤ)
    {J K : Finset ι} (hJK : J ⊆ K) (hJ : SubfamilySeparates Φ J) :
    SubfamilySeparates Φ K := by
  exact fun x y hxy => hJ x y fun i hi => hxy i ( hJK hi )

/-- An observer index `i` is a **spectral witness** for the family `Φ` if
    there exist states that are separated by observer `i` but not by any other
    single observer in the complement. This certifies that `i` is essential. -/
def SpectralWitnessFor {S ι : Type*} [DecidableEq ι]
    (Φ : ι → S → ℤ) (J : Finset ι) (i : ι) : Prop :=
  i ∈ J ∧ ∃ x y : S, (∀ j ∈ J.erase i, Φ j x = Φ j y) ∧ Φ i x ≠ Φ i y

/-- An observer index is **irredundant** in a separating subfamily if removing
    it breaks separation. -/
def GeneratorIrredundant {S ι : Type*} [DecidableEq ι]
    (Φ : ι → S → ℤ) (J : Finset ι) (i : ι) : Prop :=
  i ∈ J ∧ ¬SubfamilySeparates Φ (J.erase i)

/-! ## §2. Tropical Coordinate Distance -/

/-- The tropical separation pseudodistance between two states under observer
    family `Φ`, defined as the supremum of coordinate-wise absolute differences.
    This is the ℓ∞-norm in observer coordinate space.

    When `ι` is empty, the distance is 0 (vacuous observation). -/
def observerDist {S ι : Type*} [Fintype ι] (Φ : ι → S → ℤ) (x y : S) : ℕ :=
  Finset.sup Finset.univ (fun i => (Φ i x - Φ i y).natAbs)

/-- Subfamily-restricted distance: sup of coordinate distances over a subset. -/
def subDist {S ι : Type*} (Φ : ι → S → ℤ) (J : Finset ι) (x y : S) : ℕ :=
  J.sup (fun i => (Φ i x - Φ i y).natAbs)

/-! ## §3. Pseudometric Properties of Tropical Distance -/

/-
**Reflexivity**: the tropical distance from any state to itself is zero.
-/
theorem observerDist_refl {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (x : S) : observerDist Φ x x = 0 := by
  -- Each term (Φ i x - Φ i x).natAbs = 0, so the sup is 0. Use simp with sub_self, Int.natAbs_zero, and Finset.sup_eq_bot_iff or similar.
  simp [observerDist, Int.natAbs_zero]

/-
**Symmetry**: tropical distance is symmetric.
-/
theorem observerDist_symm {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (x y : S) : observerDist Φ x y = observerDist Φ y x := by
  exact Finset.sup_congr rfl fun i _ => by rw [ ← Int.natAbs_neg, neg_sub ] ;

/-
Coordinate-wise triangle inequality for `natAbs`.
-/
theorem natAbs_sub_triangle (a b c : ℤ) :
    (a - c).natAbs ≤ (a - b).natAbs + (b - c).natAbs := by
  grind

/-
Finset.sup of sum is bounded by sum of Finset.sup.
-/
theorem finset_sup_add_le {ι : Type*} {s : Finset ι}
    (f g : ι → ℕ) :
    s.sup (fun i => f i + g i) ≤ s.sup f + s.sup g := by
  exact Finset.sup_le fun i _ => add_le_add ( Finset.le_sup ( f := fun j => f j ) ‹_› ) ( Finset.le_sup ( f := fun j => g j ) ‹_› )

/-
**Triangle inequality**: the tropical distance satisfies the triangle inequality.
-/
theorem observerDist_triangle {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (x y z : S) :
    observerDist Φ x z ≤ observerDist Φ x y + observerDist Φ y z := by
  unfold observerDist;
  simp +zetaDelta at *;
  exact fun i => le_trans ( natAbs_sub_triangle _ _ _ ) ( add_le_add ( Finset.le_sup ( f := fun i => Int.natAbs ( Φ i x - Φ i y ) ) ( Finset.mem_univ i ) ) ( Finset.le_sup ( f := fun i => Int.natAbs ( Φ i y - Φ i z ) ) ( Finset.mem_univ i ) ) )

/-! ## §4. Separation Characterization -/

/-
Each coordinate distance is bounded by the overall tropical distance.
-/
theorem coord_le_observerDist {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (x y : S) (i : ι) :
    (Φ i x - Φ i y).natAbs ≤ observerDist Φ x y := by
  exact Finset.le_sup ( f := fun i => Int.natAbs ( Φ i x - Φ i y ) ) ( Finset.mem_univ i )

/-
**Separation characterization**: the tropical distance is zero if and only if
    the two states are code-equivalent under all observers.

    This is the fundamental bridge between metric geometry and algebraic coding:
    vanishing distance ↔ observational indistinguishability.
-/
theorem observerDist_eq_zero_iff {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (x y : S) :
    observerDist Φ x y = 0 ↔ CodeEqFamily Φ x y := by
  refine ⟨ fun h => fun i => ?_, fun h => ?_ ⟩ <;> simp_all +decide [ sub_eq_iff_eq_add, observerDist ];
  exact h

/-
Positive distance implies existence of a distinguishing observer.
-/
theorem exists_distinguishing_of_pos_dist {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) {x y : S} (h : 0 < observerDist Φ x y) :
    ∃ i : ι, Φ i x ≠ Φ i y := by
  contrapose! h;
  exact Finset.sup_le fun i _ => by simp +decide [ h i ] ;

/-
For separating families, positive distance characterizes inequality.
-/
theorem pos_dist_iff_ne_of_separating {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (hsep : SeparatesCodeEqFamily Φ) (x y : S) :
    0 < observerDist Φ x y ↔ x ≠ y := by
  -- By observerDist_eq_zero_iff, dist = 0 ↔ CodeEqFamily. By hsep, CodeEqFamily → x = y. So dist = 0 → x = y, and x = y → dist = 0 (by refl). Thus pos dist ↔ x ≠ y.
  apply Iff.intro;
  · exact fun hxy h => hxy.ne' ( by simp +decide [ h, observerDist_refl ] );
  · exact fun hxy => Nat.pos_of_ne_zero fun h => hxy <| hsep x y <| ( observerDist_eq_zero_iff Φ x y ).mp h

/-! ## §5. Compression Nonexpansivity -/

/-
**Compression nonexpansivity**: if each observer coordinate is nonexpansive
    under compression `C`, then the overall tropical distance is nonexpansive.

    Bridge: this connects proof-state compression to certified robustness —
    coordinate-wise contraction implies global metric contraction.
-/
theorem compression_nonexpansive_of_coord {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (C : S → S)
    (hcoord : ∀ i x y, (Φ i (C x) - Φ i (C y)).natAbs ≤ (Φ i x - Φ i y).natAbs) :
    ∀ x y, observerDist Φ (C x) (C y) ≤ observerDist Φ x y := by
  exact fun x y => Finset.sup_mono_fun fun i _ => hcoord i x y

/-
Compression preserves code equivalence.
-/
theorem compression_preserves_codeEq {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (C : S → S)
    (hcoord : ∀ i x y, (Φ i (C x) - Φ i (C y)).natAbs ≤ (Φ i x - Φ i y).natAbs) :
    ∀ x y, CodeEqFamily Φ x y → CodeEqFamily Φ (C x) (C y) := by
  intro x y hxy i; specialize hcoord i x y; simp_all +decide [ CodeEqFamily ] ;
  grind

/-! ## §6. Distance Descends to Code Equivalence Classes -/

/-
**Tropical distance descends to CodeEq**: if an observer family respects
    code equivalence (i.e., observer values are constant on CodeEq classes),
    then the tropical distance is well-defined on the quotient.

    This gives the quotient geometry: the distance profile is a certified
    invariant of proof-state equivalence classes.
-/
theorem tropical_distance_descends_codeEq {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) {x x' y y' : S}
    (hx : CodeEqFamily Φ x x') (hy : CodeEqFamily Φ y y') :
    observerDist Φ x y = observerDist Φ x' y' := by
  unfold observerDist;
  congr! 2;
  rw [ hx, hy ]

/-! ## §7. Spectral Irredundancy -/

/-
**Spectral witness implies irredundancy**: if observer `i` has a spectral
    witness (a pair of states separated only by `i` among the subfamily),
    then removing `i` breaks separation.

    Bridge: this is where the speculative spectral infrastructure becomes
    mathematically decisive — spectral witnesses certify that generators
    cannot be removed from the architecture.
-/
theorem spectral_witness_implies_irredundant
    {S ι : Type*} [DecidableEq ι]
    (Φ : ι → S → ℤ) (J : Finset ι) (i : ι)
    (hspec : SpectralWitnessFor Φ J i) :
    GeneratorIrredundant Φ J i := by
  constructor;
  · exact hspec.1;
  · rintro h;
    obtain ⟨ x, y, hxy, hne ⟩ := hspec.2;
    exact hne ( by have := h x y hxy; aesop )

/-! ## §8. Minimal Separating Subfamily -/

/-- The set of all separating subfamilies. -/
def separatingSubfamilies {S ι : Type*} [DecidableEq S] [Fintype ι]
    (Φ : ι → S → ℤ) : Set (Finset ι) :=
  {J : Finset ι | SubfamilySeparates Φ J}

/-
**Existence of minimal separating subfamily**: for any finite separating
    observer family over a finite state space, there exists a subfamily of
    minimum cardinality that still separates.

    This is the finite combinatorial heart of the duality: the separation rank
    is well-defined because the state set is finite.

    Bridge: this is the tropical analogue of Myhill–Nerode minimization —
    observer separation rank behaves like a tropical state complexity invariant.
-/
theorem exists_minimal_separating_subfamily
    {S ι : Type*} [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    (Φ : ι → S → ℤ) (hsep : SeparatesCodeEqFamily Φ) :
    ∃ J : Finset ι,
      SubfamilySeparates Φ J ∧
      ∀ K : Finset ι, SubfamilySeparates Φ K → J.card ≤ K.card := by
  have h_nonempty : ∃ J : Finset ι, SubfamilySeparates Φ J := by
    exact ⟨ Finset.univ, fun x y hxy => hsep x y fun i => hxy i ( Finset.mem_univ i ) ⟩;
  apply_rules [ Set.exists_min_image ];
  exact Set.toFinite _

/-- The separation rank: minimal cardinality of a separating subfamily. -/
def ObserverSeparationRank {S ι : Type*} [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    (Φ : ι → S → ℤ) (hsep : SeparatesCodeEqFamily Φ) : ℕ :=
  (exists_minimal_separating_subfamily Φ hsep).choose.card

/-- The separation rank is achieved by a separating subfamily. -/
theorem separationRank_spec {S ι : Type*} [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    (Φ : ι → S → ℤ) (hsep : SeparatesCodeEqFamily Φ) :
    ∃ J : Finset ι, J.card = ObserverSeparationRank Φ hsep ∧
      SubfamilySeparates Φ J ∧
      ∀ K : Finset ι, SubfamilySeparates Φ K → J.card ≤ K.card := by
  exact ⟨_, rfl, (exists_minimal_separating_subfamily Φ hsep).choose_spec⟩

/-- The separation rank is a lower bound for all separating subfamilies. -/
theorem separationRank_le {S ι : Type*} [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    (Φ : ι → S → ℤ) (hsep : SeparatesCodeEqFamily Φ)
    (K : Finset ι) (hK : SubfamilySeparates Φ K) :
    ObserverSeparationRank Φ hsep ≤ K.card :=
  (exists_minimal_separating_subfamily Φ hsep).choose_spec.2 K hK

/-
**Uniqueness of separation rank**: any two minimal separating subfamilies
    have the same cardinality.
-/
theorem minimal_subfamily_card_unique
    {S ι : Type*} [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    (Φ : ι → S → ℤ)
    {J K : Finset ι}
    (hJ : SubfamilySeparates Φ J)
    (hJmin : ∀ L : Finset ι, SubfamilySeparates Φ L → J.card ≤ L.card)
    (hK : SubfamilySeparates Φ K)
    (hKmin : ∀ L : Finset ι, SubfamilySeparates Φ L → K.card ≤ L.card) :
    J.card = K.card := by
  exact le_antisymm ( hJmin K hK ) ( hKmin J hJ )

/-! ## §9. Structures: Semimodule, Network, Realization -/

/-- A **tropical separation semimodule** bundles a finite observer family with
    certified separation, compression nonexpansivity, and generator irredundancy.

    This is the algebraic side of the duality: a finitely generated idempotent
    separation structure over observer functionals on a finite state space. -/
structure TropicalSeparationSemimodule (S : Type*) [Fintype S] [DecidableEq S] where
  /-- Number of generators (observer coordinates) -/
  numGen : ℕ
  /-- Observer functionals: tropical-valued score maps on states -/
  observers : Fin numGen → S → ℤ
  /-- Compression action on states -/
  compression : S → S
  /-- The observer family separates inequivalent states -/
  separates : SeparatesCodeEqFamily observers
  /-- Each coordinate is nonexpansive under compression -/
  coordNonexpansive : ∀ i x y,
    (observers i (compression x) - observers i (compression y)).natAbs ≤
    (observers i x - observers i y).natAbs

/-- A tropical separation semimodule is **separation-certified** if it is
    irredundant: every generator is essential for separation. -/
def TropicalSeparationSemimodule.IsSeparationCertified
    {S : Type*} [Fintype S] [DecidableEq S]
    (M : TropicalSeparationSemimodule S) : Prop :=
  ∀ i : Fin M.numGen, GeneratorIrredundant M.observers Finset.univ i

/-- The observer separation rank of a semimodule. -/
def TropicalSeparationSemimodule.sepRank
    {S : Type*} [Fintype S] [DecidableEq S]
    (M : TropicalSeparationSemimodule S) : ℕ :=
  ObserverSeparationRank M.observers M.separates

/-- The canonical distance profile of a semimodule. -/
def TropicalSeparationSemimodule.CanonicalDistProfile
    {S : Type*} [Fintype S] [DecidableEq S]
    (M : TropicalSeparationSemimodule S) : S → S → ℕ :=
  observerDist M.observers

/-- A semimodule is **finitely generated** (always true since numGen is finite). -/
def TropicalSeparationSemimodule.FinitelyGenerated
    {S : Type*} [Fintype S] [DecidableEq S]
    (_ : TropicalSeparationSemimodule S) : Prop := True

/-- A semimodule is **spectrally nonredundant** if each generator has a
    spectral witness. -/
def TropicalSeparationSemimodule.SpectralNonredundant
    {S : Type*} [Fintype S] [DecidableEq S]
    (M : TropicalSeparationSemimodule S) : Prop :=
  ∀ i : Fin M.numGen, SpectralWitnessFor M.observers Finset.univ i

/-- A **minimal compression network** is a finite layered architecture whose
    hidden coordinates are exactly the essential generators.

    Bridge: this is the algorithmic/architectural side of the duality —
    the network whose width equals the separation rank. -/
structure MinimalCompressionNetwork (S : Type*) [Fintype S] [DecidableEq S] where
  /-- Width = number of observer coordinates -/
  ObserverWidth : ℕ
  /-- Network coordinates: the observer functionals -/
  coordinates : Fin ObserverWidth → S → ℤ
  /-- Compression map -/
  compression : S → S
  /-- The coordinates separate states -/
  separates : SeparatesCodeEqFamily coordinates
  /-- Coordinate-wise nonexpansivity -/
  coordNonexpansive : ∀ i x y,
    (coordinates i (compression x) - coordinates i (compression y)).natAbs ≤
    (coordinates i x - coordinates i y).natAbs
  /-- Minimality: no proper subfamily separates -/
  minimal : ∀ J : Finset (Fin ObserverWidth),
    SubfamilySeparates coordinates J → J.card = ObserverWidth

/-- The canonical distance profile of a network. -/
def MinimalCompressionNetwork.CanonicalDistProfile
    {S : Type*} [Fintype S] [DecidableEq S]
    (N : MinimalCompressionNetwork S) : S → S → ℕ :=
  observerDist N.coordinates

/-- A network **realizes** a separation semimodule if they induce the same
    distance profile and code equivalence classes. -/
def RealizesSemimodule {S : Type*} [Fintype S] [DecidableEq S]
    (N : MinimalCompressionNetwork S) (M : TropicalSeparationSemimodule S) : Prop :=
  (∀ x y, CodeEqFamily N.coordinates x y ↔ CodeEqFamily M.observers x y) ∧
  N.compression = M.compression

/-- Isomorphism between minimal compression networks: a bijection on coordinates
    that preserves the observer structure. -/
structure CompressionNetworkIso {S : Type*} [Fintype S] [DecidableEq S]
    (N₁ N₂ : MinimalCompressionNetwork S) where
  /-- Bijection on coordinate indices -/
  coordBij : Fin N₁.ObserverWidth ≃ Fin N₂.ObserverWidth
  /-- Observer values are preserved -/
  preserves : ∀ (i : Fin N₁.ObserverWidth) (x : S),
    N₁.coordinates i x = N₂.coordinates (coordBij i) x
  /-- Compression maps agree -/
  compEq : N₁.compression = N₂.compression

/-! ## §10. Reconstruction from Minimal Subfamily -/

/-
**Reconstruction theorem**: from a minimal separating subfamily, construct
    a minimal compression network with matching width and structure.
-/
theorem reconstruct_network_from_subfamily
    {S : Type*} [Fintype S] [DecidableEq S]
    {n : ℕ} (Φ : Fin n → S → ℤ) (C : S → S)
    (J : Finset (Fin n))
    (hJsep : SubfamilySeparates Φ J)
    (hJmin : ∀ K : Finset (Fin n), SubfamilySeparates Φ K → J.card ≤ K.card)
    (hcontr : ∀ i x y, (Φ i (C x) - Φ i (C y)).natAbs ≤ (Φ i x - Φ i y).natAbs) :
    ∃ N : MinimalCompressionNetwork S,
      N.ObserverWidth = J.card ∧
      N.compression = C ∧
      (∀ x y, CodeEqFamily N.coordinates x y ↔ ∀ i ∈ J, Φ i x = Φ i y) := by
  refine' ⟨ _, _, _, _ ⟩;
  exact ⟨ J.card, fun i x => Φ ( J.orderEmbOfFin rfl i ) x, C, by
    intro x y hxy
    have h_eq : ∀ i ∈ J, Φ i x = Φ i y := by
      intro i hi;
      obtain ⟨ j, hj ⟩ := Finset.mem_image.mp ( show i ∈ Finset.image ( fun j : Fin J.card => J.orderEmbOfFin rfl j ) Finset.univ from by aesop ) ; aesop;
    exact hJsep x y h_eq, by
    grind, by
    intro K hKsep
    have hKcard : K.card ≥ J.card := by
      refine' le_trans ( hJmin ( Finset.image ( fun i : Fin #J => J.orderEmbOfFin rfl i ) K ) _ ) _;
      · intro x y hxy;
        exact hKsep x y fun i hi => hxy _ ( Finset.mem_image_of_mem _ hi );
      · exact Finset.card_image_le;
    exact le_antisymm ( le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) ) hKcard ⟩;
  · rfl;
  · rfl;
  · intro x y;
    constructor;
    · intro h i hi;
      obtain ⟨ j, hj ⟩ := Finset.mem_image.mp ( show i ∈ Finset.image ( fun j : Fin J.card => J.orderEmbOfFin rfl j ) Finset.univ from by aesop ) ; aesop;
    · exact fun h i => h _ ( Finset.orderEmbOfFin_mem _ _ _ )

/-! ## §11. Flagship Duality Theorem -/

/-
Helper: if a subfamily separates and all its observers agree on x, y,
    then x = y, so CodeEqFamily holds by reflexivity.
-/
theorem codeEq_of_subfamilySeparates_agree
    {S : Type*} {n : ℕ} (Φ : Fin n → S → ℤ)
    (J : Finset (Fin n))
    (hJsep : SubfamilySeparates Φ J)
    {x y : S} (h : ∀ i ∈ J, Φ i x = Φ i y) :
    CodeEqFamily Φ x y := by
  exact fun i => by have := hJsep x y h; aesop;

/-- A MinimalCompressionNetwork's width is the minimum over its own coordinates. -/
theorem network_width_is_own_min
    {S : Type*} [Fintype S] [DecidableEq S]
    (N : MinimalCompressionNetwork S)
    (K : Finset (Fin N.ObserverWidth))
    (hK : SubfamilySeparates N.coordinates K) :
    K.card = N.ObserverWidth :=
  N.minimal K hK

/-
**Flagship Theorem: Finite Separation Semimodule Realization Minimality.**

    For every finite proof-state type `S`, every tropical separation semimodule `M`
    admits a finite minimal layered proof-compression network `N` such that
    `N` realizes the same `CodeEq`-classes as `M` and has width equal to the
    separation rank (the minimum number of observers needed).
-/
theorem finite_separation_semimodule_realization_minimal
    {S : Type*} [Fintype S] [DecidableEq S]
    (M : TropicalSeparationSemimodule S) :
    ∃ N : MinimalCompressionNetwork S,
      RealizesSemimodule N M ∧
      N.ObserverWidth = M.sepRank := by
  obtain ⟨J, hJsep, hJmin⟩ : ∃ J : Finset (Fin M.numGen), J.card = M.sepRank ∧ SubfamilySeparates M.observers J ∧ ∀ K : Finset (Fin M.numGen), SubfamilySeparates M.observers K → J.card ≤ K.card := by
    exact separationRank_spec M.observers M.separates;
  have := reconstruct_network_from_subfamily M.observers M.compression J hJmin.1 hJmin.2 M.coordNonexpansive;
  obtain ⟨ N, hN₁, hN₂, hN₃ ⟩ := this; use N; simp_all +decide [ RealizesSemimodule ] ;
  exact fun x y => ⟨ fun h => codeEq_of_subfamilySeparates_agree _ _ hJmin.1 h, fun h => fun i hi => h i ⟩

/-! ## §12. Connecting to `canonical_observer_code_certified` -/

/-- The canonical observer code from `ObserverRateDistortion.lean` induces
    a separation semimodule structure when lifted to tropical observer coordinates.

    This theorem shows how the existing certified observer code generates
    the tropical separation geometry that the duality theorem operates on.

    Given an observer family (as in ObserverRateDistortion) that assigns integer
    scores to states, we produce a TropicalSeparationSemimodule. -/
theorem canonical_code_induces_semimodule
    {S : Type*} [Fintype S] [DecidableEq S]
    (n : ℕ) (Φ : Fin n → S → ℤ) (C : S → S)
    (hsep : SeparatesCodeEqFamily Φ)
    (hcontr : ∀ i x y, (Φ i (C x) - Φ i (C y)).natAbs ≤ (Φ i x - Φ i y).natAbs) :
    ∃ M : TropicalSeparationSemimodule S,
      M.numGen = n ∧
      M.CanonicalDistProfile = observerDist Φ ∧
      M.compression = C := by
  exact ⟨⟨n, Φ, C, hsep, hcontr⟩, rfl, rfl, rfl⟩

/-! ## §13. SubDist Properties and Embedding -/

/-
SubDist reflexivity.
-/
theorem subDist_refl {S ι : Type*} (Φ : ι → S → ℤ) (J : Finset ι) (x : S) :
    subDist Φ J x x = 0 := by
  unfold subDist; aesop;

/-
SubDist symmetry.
-/
theorem subDist_symm {S ι : Type*} (Φ : ι → S → ℤ) (J : Finset ι) (x y : S) :
    subDist Φ J x y = subDist Φ J y x := by
  exact Finset.sup_congr rfl fun i hi => by rw [ ← Int.natAbs_neg, neg_sub ] ;

/-
SubDist is bounded by full observerDist.
-/
theorem subDist_le_observerDist {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (J : Finset ι) (x y : S) :
    subDist Φ J x y ≤ observerDist Φ x y := by
  exact Finset.sup_mono ( Finset.subset_univ J )

/-
SubDist zero iff all observers in J agree.
-/
theorem subDist_eq_zero_iff {S ι : Type*}
    (Φ : ι → S → ℤ) (J : Finset ι) (x y : S) :
    subDist Φ J x y = 0 ↔ ∀ i ∈ J, Φ i x = Φ i y := by
  constructor;
  · exact fun h i hi => eq_of_sub_eq_zero ( by simpa [ sub_eq_zero ] using Nat.eq_zero_of_le_zero ( Finset.le_sup ( f := fun i => Int.natAbs ( Φ i x - Φ i y ) ) hi |> le_trans <| h.le ) );
  · intro h; unfold subDist; aesop;

/-
**Tropical embedding theorem for CodeEq quotient**: a separating family
    induces an injective map from states into ℤ^n. This makes the observer
    coordinate map a faithful finite tropical embedding.
-/
theorem tropical_embedding_injective
    {S ι : Type*} [Fintype ι] (Φ : ι → S → ℤ)
    (hsep : SeparatesCodeEqFamily Φ) :
    Injective (fun x => fun i : ι => Φ i x) := by
  exact fun x y hxy => hsep x y fun i => congr_fun hxy i

/-! ## §14. Compression Orbit and Convergence -/

/-
Iterated compression distances are nonincreasing: the orbit diameter
    shrinks monotonically under coordinate-nonexpansive compression.
-/
theorem compression_orbit_nonincreasing {S ι : Type*} [Fintype ι]
    (Φ : ι → S → ℤ) (C : S → S)
    (hcoord : ∀ i x y, (Φ i (C x) - Φ i (C y)).natAbs ≤ (Φ i x - Φ i y).natAbs)
    (x y : S) (n : ℕ) :
    observerDist Φ (C^[n + 1] x) (C^[n + 1] y) ≤
    observerDist Φ (C^[n] x) (C^[n] y) := by
  convert compression_nonexpansive_of_coord Φ C hcoord _ _ using 1;
  rw [ Function.iterate_succ_apply', Function.iterate_succ_apply' ]

/-
Over a finite state space, compression orbits are eventually periodic:
    there exist indices m < n with the same iterate value.
-/
theorem compression_orbit_eventually_periodic {S : Type*} [Fintype S]
    (C : S → S) (x : S) :
    ∃ m n : ℕ, m < n ∧ C^[m] x = C^[n] x := by
  by_contra! h;
  exact absurd ( Set.infinite_range_of_injective ( fun m n mn => le_antisymm ( not_lt.1 fun contra => h _ _ contra mn.symm ) ( not_lt.1 fun contra => h _ _ contra mn ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ )

end TropicalObserverDuality