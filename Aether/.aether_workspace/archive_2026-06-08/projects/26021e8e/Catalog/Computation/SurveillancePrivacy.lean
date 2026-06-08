import Mathlib

/-! # Surveillance Networks and Information-Theoretic Privacy

This module establishes a foundational information-theoretic framework for analyzing
the tradeoff between surveillance capability and privacy in finite networks.

## Core Idea

Given a finite state space `S` and an observation space `C`, any observation function
`f : S → C` induces a partition of `S` into fibers. States in the same fiber are
*indistinguishable* (contributing to privacy), while states in different fibers are
*distinguishable* (contributing to surveillance capability).

The central result is the **Privacy-Surveillance Conservation Law**: the sum of
indistinguishable and distinguishable pairs is constant, establishing surveillance
and privacy as a zero-sum game.

## Main Results

* `privacy_surveillance_conservation` — The total pairs decompose exactly into
  private (indistinguishable) and surveilled (distinguishable) pairs.
* `surveillance_privacy_exclusion` — Perfect surveillance and perfect privacy
  are mutually exclusive for any non-trivial state space.
* `privacy_amplification` — Post-processing can only increase privacy,
  the deterministic analog of the data processing inequality.
* `codebook_lower_bound` — Perfect reconstruction requires codebook size ≥ |S|.
* `dynamic_codebook_exponential` — For T-step trajectories over state space S,
  perfect reconstruction requires codebook size ≥ |S|^T.
-/

noncomputable section

open Finset Fintype Function

/-! ## Core Definitions -/

/-- The **privacy index** of an observation function `f : S → C` counts ordered pairs
of distinct states mapped to the same observation. A higher privacy index means
the observation conflates more states, providing greater privacy protection. -/
def privacyIndex {S C : Type*} [Fintype S] [DecidableEq S] [DecidableEq C]
    (f : S → C) : ℕ :=
  (Finset.univ (α := S × S)).filter (fun p => p.1 ≠ p.2 ∧ f p.1 = f p.2) |>.card

/-- The **surveillance index** of an observation function `f : S → C` counts ordered
pairs of states mapped to different observations. These are the pairs an observer
can distinguish, representing the surveillance power of `f`. -/
def surveillanceIndex {S C : Type*} [Fintype S] [DecidableEq C]
    (f : S → C) : ℕ :=
  (Finset.univ (α := S × S)).filter (fun p => f p.1 ≠ f p.2) |>.card

/-- A **surveillance system** bundles a state space, observation space,
observation function, and reconstruction function. It models a network
where states are observed through a (possibly lossy) channel. -/
structure SurveillanceSystem (S C : Type*) [Fintype S] [Fintype C] where
  /-- The observation/encoding function mapping states to observations -/
  observe : S → C
  /-- The reconstruction/decoding function recovering states from observations -/
  reconstruct : C → S

/-- A surveillance system achieves **perfect reconstruction** if the decoder
perfectly inverts the encoder on all states. -/
def SurveillanceSystem.isPerfect {S C : Type*} [Fintype S] [Fintype C]
    (sys : SurveillanceSystem S C) : Prop :=
  ∀ s : S, sys.reconstruct (sys.observe s) = s

/-- The **privacy spectrum** of a function at level k measures how many states
have fibers of size ≥ k. This captures privacy at multiple granularities:
level 1 gives total states, level 2 gives states with at least one
indistinguishable partner, etc. The spectrum encodes the full fiber
size distribution and refines the scalar privacy index. -/
def privacySpectrum {S C : Type*} [Fintype S] [DecidableEq S] [Fintype C]
    [DecidableEq C] (f : S → C) (k : ℕ) : ℕ :=
  (Finset.univ (α := S)).filter
    (fun s => k ≤ (Finset.univ.filter (fun t => f t = f s)).card) |>.card

/-! ## The Conservation Law -/

/-
**Privacy-Surveillance Conservation Law.** For any observation function
`f : S → C`, the privacy index and surveillance index sum to the total
number of ordered off-diagonal pairs `|S| · (|S| - 1)`.

This is the fundamental identity: every pair of distinct states is either
indistinguishable (contributing to privacy) or distinguishable (contributing
to surveillance), with no overlap and no remainder. Privacy gained is
surveillance lost, and vice versa.
-/
theorem privacy_surveillance_conservation {S C : Type*} [Fintype S]
    [DecidableEq S] [DecidableEq C] (f : S → C) :
    privacyIndex f + surveillanceIndex f =
      Fintype.card S * (Fintype.card S - 1) := by
  -- The key insight: the sets {(s₁,s₂) | s₁ ≠ s₂ ∧ f s₁ = f s₂} and {(s₁,s₂) | f s₁ ≠ f s₂} partition the off-diagonal {(s₁,s₂) | s₁ ≠ s₂}.
  have h_partition : (Finset.univ : Finset (S × S)).filter (fun p => p.1 ≠ p.2) =
    ((Finset.univ : Finset (S × S)).filter (fun p => p.1 ≠ p.2 ∧ f p.1 = f p.2)) ∪
    ((Finset.univ : Finset (S × S)).filter (fun p => f p.1 ≠ f p.2)) := by
      grind;
  convert congr_arg Finset.card h_partition.symm using 1;
  · rw [ Finset.card_union_of_disjoint ];
    · rfl;
    · exact Finset.disjoint_filter.mpr ( by aesop );
  · rw [ Finset.card_filter ];
    erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_ite, Finset.filter_ne ]

/-! ## Characterization Theorems -/

/-
Zero privacy index characterizes injective functions: no two distinct
states map to the same observation if and only if the function is injective.
-/
theorem zero_privacy_iff_injective {S C : Type*} [Fintype S]
    [DecidableEq S] [DecidableEq C] (f : S → C) :
    privacyIndex f = 0 ↔ Injective f := by
  unfold privacyIndex; simp +decide [ Finset.ext_iff, Function.Injective ] ;
  exact ⟨ fun h a b hab => Classical.not_not.1 fun h' => h a b h' hab, fun h a b hab => fun h' => hab ( h h' ) ⟩

/-
Zero surveillance index characterizes functions with a single value:
no two states are distinguishable if and only if the function is constant.
-/
theorem zero_surveillance_iff_const {S C : Type*} [Fintype S]
    [DecidableEq S] [DecidableEq C] [Nonempty S] (f : S → C) :
    surveillanceIndex f = 0 ↔ ∃ c, ∀ s, f s = c := by
  constructor <;> intro h;
  · simp_all +decide [ surveillanceIndex ];
    exact ⟨ f ( Classical.arbitrary S ), fun s => h s ( Classical.arbitrary S ) ⟩;
  · unfold surveillanceIndex; aesop;

/-! ## The Exclusion Theorem -/

/-
**Surveillance-Privacy Exclusion Theorem.** For any state space with
at least two elements, no observation function can achieve both perfect
privacy (zero surveillance index) and perfect surveillance (zero privacy
index) simultaneously. This is the fundamental impossibility result:
surveillance and privacy are genuinely incompatible goals.
-/
theorem surveillance_privacy_exclusion {S C : Type*} [Fintype S]
    [DecidableEq S] [DecidableEq C] [Nonempty S] (f : S → C)
    (hcard : 1 < Fintype.card S) :
    ¬(privacyIndex f = 0 ∧ surveillanceIndex f = 0) := by
  intro h
  have h_inj : Injective f := by
    exact zero_privacy_iff_injective f |>.1 h.1
  have h_const : ∃ c, ∀ s, f s = c := by
    exact zero_surveillance_iff_const f |>.1 h.2
  obtain ⟨c, hc⟩ := h_const
  have h_contra : Fintype.card S ≤ 1 := by
    exact Fintype.card_le_one_iff.mpr fun x y => h_inj <| by simp +decide [ hc ] ;
  linarith [hcard]

/-! ## Codebook Bounds -/

/-
**Codebook Size Lower Bound.** If the observation function achieves
perfect reconstruction (is injective), the codebook (observation space)
must contain at least as many elements as the state space. Information
cannot be compressed without loss.
-/
theorem codebook_lower_bound {S C : Type*} [Fintype S] [Fintype C]
    [DecidableEq S] [DecidableEq C] (f : S → C) (hf : privacyIndex f = 0) :
    Fintype.card S ≤ Fintype.card C := by
  exact Fintype.card_le_of_injective f ( by rwa [ zero_privacy_iff_injective ] at hf )

/-
Perfect reconstruction in a surveillance system implies the observation
function is injective.
-/
theorem perfect_implies_injective {S C : Type*} [Fintype S] [Fintype C]
    [DecidableEq S] [DecidableEq C] (sys : SurveillanceSystem S C)
    (h : sys.isPerfect) : Injective sys.observe := by
  exact Function.LeftInverse.injective ( fun x => by have := h x; aesop )

/-
**Perfect Reconstruction Exclusion.** A surveillance system that perfectly
reconstructs all states necessarily has zero privacy: every pair of distinct
states is distinguishable through the observation channel.
-/
theorem perfect_reconstruction_zero_privacy {S C : Type*} [Fintype S]
    [Fintype C] [DecidableEq S] [DecidableEq C]
    (sys : SurveillanceSystem S C) (h : sys.isPerfect) :
    privacyIndex sys.observe = 0 := by
  exact zero_privacy_iff_injective sys.observe |>.2 ( perfect_implies_injective sys h )

/-! ## The Data Processing Inequality (Deterministic) -/

/-
**Deterministic Data Processing Inequality (weak form).** Composing an
observation function with any post-processing map cannot decrease the
privacy index. Once information is lost, it cannot be recovered.

This is the deterministic analog of the celebrated data processing inequality
from information theory.
-/
theorem privacy_monotone_composition {S C D : Type*} [Fintype S]
    [DecidableEq S] [DecidableEq C] [DecidableEq D]
    (f : S → C) (g : C → D) :
    privacyIndex f ≤ privacyIndex (g ∘ f) := by
  exact Finset.card_mono fun x hx => by aesop;

/-
**Privacy Amplification Theorem (strict form).** If a post-processing
map `g` merges two observations that are actually used by distinct states
(i.e., `g` is non-injective on the image of `f`), then the privacy index
strictly increases. Privacy amplification is irreversible.
-/
theorem privacy_amplification {S C D : Type*} [Fintype S]
    [DecidableEq S] [DecidableEq C] [DecidableEq D]
    (f : S → C) (g : C → D)
    (h : ∃ s₁ s₂ : S, s₁ ≠ s₂ ∧ f s₁ ≠ f s₂ ∧ g (f s₁) = g (f s₂)) :
    privacyIndex f < privacyIndex (g ∘ f) := by
  refine' Finset.card_lt_card _;
  simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
  tauto

/-! ## Dynamic Surveillance -/

/-
For trajectories of length `T` over state space `S`, the number of
possible trajectories is `|S|^T`. This is the state space for dynamic
surveillance.
-/
theorem trajectory_space_card (S : Type*) [Fintype S] (T : ℕ) :
    Fintype.card (Fin T → S) = Fintype.card S ^ T := by
  simp +decide [ Fintype.card_pi ]

/-
**Dynamic Codebook Exponential Growth.** For perfect reconstruction of
T-step trajectories over a state space S, the codebook must have size
at least |S|^T. Surveillance of dynamical systems faces an exponential
information cost.
-/
theorem dynamic_codebook_exponential {S C : Type*} [Fintype S] [Fintype C]
    [DecidableEq S] [DecidableEq C] [DecidableEq (Fin T → S)]
    (T : ℕ) (f : (Fin T → S) → C) (hf : Injective f) :
    Fintype.card S ^ T ≤ Fintype.card C := by
  have h_card_le : Fintype.card (Fin T → S) ≤ Fintype.card C := by
    exact Fintype.card_le_of_injective f hf;
  aesop

/-! ## Privacy Spectrum Properties -/

/-
The privacy spectrum at level 1 equals the total number of states.
-/
theorem privacySpectrum_one {S C : Type*} [Fintype S] [DecidableEq S]
    [Fintype C] [DecidableEq C] (f : S → C) :
    privacySpectrum f 1 = Fintype.card S := by
  exact congr_arg Finset.card ( Finset.filter_true_of_mem fun s _ => Finset.card_pos.2 ⟨ s, by simp +decide ⟩ )

/-
The privacy spectrum is monotone decreasing: higher levels count
fewer states.
-/
theorem privacySpectrum_antitone {S C : Type*} [Fintype S] [DecidableEq S]
    [Fintype C] [DecidableEq C] (f : S → C) :
    Antitone (privacySpectrum f) := by
  intro k₁ k₂ hk;
  exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans hk ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-
For an injective function, the privacy spectrum drops to zero at level 2:
no state has an indistinguishable partner.
-/
theorem privacySpectrum_injective_drop {S C : Type*} [Fintype S]
    [DecidableEq S] [Fintype C] [DecidableEq C] (f : S → C) (hf : Injective f)
    (k : ℕ) (hk : 2 ≤ k) :
    privacySpectrum f k = 0 := by
  unfold privacySpectrum;
  simp +decide [ Finset.filter_eq', hf.eq_iff ];
  grind +splitIndPred

end