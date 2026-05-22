/-
# Proof-Theoretic Novelty Geometry: Depth Gap on Theorem Profiles

A computable framework for measuring "conceptual distance" between mathematical
artifacts using finite theorem profiles. We define a concrete metric-like invariant
(`profileDepthGap`) on a finite model of theorem presentations, and prove:

1. **Minimum-depth attainment** (`profileDepthGap_attained`): the depth gap is
   realized by a nearest known profile.
2. **Threshold derivative characterization** (`derivativeFrom_iff_profileDepthGap_le`):
   being derivative is exactly bounded conceptual distance from the known corpus.
3. **Computability** (`computeProfileDepthGap_spec`): the depth gap is computable.
4. **Nontriviality** (`exists_positive_profileDepthGap`): profiles with positive
   depth gap exist whenever the corpus is proper.
5. **Bridge theorems** connecting profile-based depth to the graph-reachability
   `Derivative` framework from `Core.lean`.
-/

import Mathlib
import MachineLearning.DepthGap.Core

open Finset

namespace NoveltyGeometry

/-! ## Core Definitions -/

/-- A theorem profile captures key structural features of a mathematical artifact. -/
structure TheoremProfile where
  defsIntroduced    : ℕ
  typeChanges       : ℕ
  perspectiveShifts : ℕ
  proofSize         : ℕ
  compressionScore  : ℕ
  deriving DecidableEq, Repr

/-- The conceptual leap cost between two profiles: L¹ distance on the three
    conceptual dimensions (definitions, type changes, perspective shifts). -/
def leapCost (A B : TheoremProfile) : ℕ :=
  Nat.dist A.defsIntroduced B.defsIntroduced +
  Nat.dist A.typeChanges B.typeChanges +
  Nat.dist A.perspectiveShifts B.perspectiveShifts

/-- A target `T` is derivative from corpus `K` at threshold `τ` if there exists
    a known profile in `K` within leap cost `τ`. -/
def DerivativeFrom (K : Finset TheoremProfile) (T : TheoremProfile) (τ : ℕ) : Prop :=
  ∃ S ∈ K, leapCost S T ≤ τ

instance DerivativeFrom.decidable (K : Finset TheoremProfile) (T : TheoremProfile) (τ : ℕ) :
    Decidable (DerivativeFrom K T τ) := by
  unfold DerivativeFrom; infer_instance

/-- The depth gap from a nonempty corpus `K` to target `T`: the minimum leap cost. -/
def profileDepthGap (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) : ℕ :=
  K.inf' hK (fun S => leapCost S T)

/-- The computable depth gap — definitionally equal to `profileDepthGap`. -/
def computeProfileDepthGap (K : Finset TheoremProfile) (hK : K.Nonempty)
    (T : TheoremProfile) : ℕ :=
  profileDepthGap K hK T

/-! ## Basic Properties of `leapCost` -/

theorem leapCost_comm (A B : TheoremProfile) : leapCost A B = leapCost B A := by
  simp [leapCost, Nat.dist_comm]

theorem leapCost_self (A : TheoremProfile) : leapCost A A = 0 := by
  simp [leapCost, Nat.dist_self]

theorem leapCost_eq_zero_iff (A B : TheoremProfile) :
    leapCost A B = 0 ↔
      A.defsIntroduced = B.defsIntroduced ∧
      A.typeChanges = B.typeChanges ∧
      A.perspectiveShifts = B.perspectiveShifts := by
  unfold leapCost; simp [Nat.dist]; omega

theorem leapCost_triangle (A B C : TheoremProfile) :
    leapCost A C ≤ leapCost A B + leapCost B C := by
  unfold leapCost
  have h1 := Nat.dist.triangle_inequality A.defsIntroduced B.defsIntroduced C.defsIntroduced
  have h2 := Nat.dist.triangle_inequality A.typeChanges B.typeChanges C.typeChanges
  have h3 := Nat.dist.triangle_inequality A.perspectiveShifts B.perspectiveShifts C.perspectiveShifts
  omega

/-! ## Theorem A: Minimum-Depth Attainment -/

/-- **Theorem A.** The depth gap is attained by some nearest known profile.
    This converts novelty from a vague infimum into a concrete nearest-neighbor
    certificate. -/
theorem profileDepthGap_attained
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) :
    ∃ S ∈ K, profileDepthGap K hK T = leapCost S T :=
  Finset.exists_mem_eq_inf' hK _

/-! ## Theorem B: Threshold Derivative Characterization -/

/-- **Theorem B.** A target is derivative at threshold `τ` if and only if
    the depth gap is at most `τ`. This is the formal heart of the framework:
    being derivative is exactly bounded conceptual distance. -/
theorem derivativeFrom_iff_profileDepthGap_le
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) (τ : ℕ) :
    DerivativeFrom K T τ ↔ profileDepthGap K hK T ≤ τ := by
  simp only [DerivativeFrom, profileDepthGap]
  exact (Finset.inf'_le_iff hK).symm

/-- Below the threshold implies derivativeness. -/
theorem below_profileDepthGap_threshold_derivative
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) (τ : ℕ)
    (h : profileDepthGap K hK T < τ) :
    DerivativeFrom K T τ :=
  (derivativeFrom_iff_profileDepthGap_le K hK T τ).mpr (le_of_lt h)

/-- Above the threshold implies non-derivativeness (separation). -/
theorem above_threshold_not_derivativeFrom
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) (τ : ℕ)
    (h : τ < profileDepthGap K hK T) :
    ¬DerivativeFrom K T τ :=
  fun hd => not_lt.mpr ((derivativeFrom_iff_profileDepthGap_le K hK T τ).mp hd) h

/-! ## Theorem C: Computability -/

/-- **Theorem C.** `computeProfileDepthGap` equals `profileDepthGap`. -/
theorem computeProfileDepthGap_spec
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) :
    computeProfileDepthGap K hK T = profileDepthGap K hK T := rfl

/-- The depth gap is computable: there exists a function computing it. -/
theorem profileDepthGap_computable
    (K : Finset TheoremProfile) (hK : K.Nonempty) :
    ∃ f : TheoremProfile → ℕ, ∀ T, f T = profileDepthGap K hK T :=
  ⟨profileDepthGap K hK, fun _ => rfl⟩

/-! ## Theorem D: Positive Depth Gap Existence -/

/-- Positive depth gap when no corpus element has zero leap cost to target. -/
theorem profileDepthGap_pos_of_ne_all
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile)
    (hne : ∀ S ∈ K, leapCost S T ≠ 0) :
    0 < profileDepthGap K hK T := by
  obtain ⟨S, hS, hSmin⟩ := profileDepthGap_attained K hK T
  rw [hSmin]; exact Nat.pos_of_ne_zero (hne S hS)

/-- **Theorem D.** Profiles with positive depth gap exist when the corpus
    contains no element with zero leap cost to some target. -/
theorem exists_positive_profileDepthGap
    (K : Finset TheoremProfile) (hK : K.Nonempty)
    (hproper : ∃ T : TheoremProfile, ∀ S ∈ K, leapCost S T ≠ 0) :
    ∃ T, 0 < profileDepthGap K hK T := by
  obtain ⟨T, hT⟩ := hproper
  exact ⟨T, profileDepthGap_pos_of_ne_all K hK T hT⟩

/-! ## Monotonicity Properties -/

/-- Enlarging the corpus can only decrease the depth gap. -/
theorem profileDepthGap_antitone
    (K₁ K₂ : Finset TheoremProfile) (h : K₁ ⊆ K₂)
    (hK₁ : K₁.Nonempty) (T : TheoremProfile) :
    profileDepthGap K₂ (hK₁.mono h) T ≤ profileDepthGap K₁ hK₁ T :=
  Finset.inf'_mono _ h hK₁

/-- The depth gap from a corpus to one of its own members is 0. -/
theorem profileDepthGap_eq_zero_of_mem
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile)
    (hT : T ∈ K) :
    profileDepthGap K hK T = 0 := by
  apply le_antisymm
  · calc profileDepthGap K hK T ≤ leapCost T T := Finset.inf'_le _ hT
      _ = 0 := leapCost_self T
  · exact Nat.zero_le _

set_option maxHeartbeats 400000 in
/-- Depth gap is zero iff some corpus element shares conceptual coordinates. -/
theorem profileDepthGap_eq_zero_iff
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) :
    profileDepthGap K hK T = 0 ↔ ∃ S ∈ K,
      S.defsIntroduced = T.defsIntroduced ∧
      S.typeChanges = T.typeChanges ∧
      S.perspectiveShifts = T.perspectiveShifts := by
  constructor
  · intro h
    have : ∃ S ∈ K, leapCost S T ≤ 0 :=
      (Finset.inf'_le_iff hK).mp (le_of_eq h)
    obtain ⟨S, hS, hle⟩ := this
    refine ⟨S, hS, ?_⟩
    simp only [leapCost, Nat.dist] at hle; omega
  · rintro ⟨S, hS, hd, ht, hp⟩
    apply le_antisymm
    · have : leapCost S T = 0 := by simp [leapCost, hd, ht, hp, Nat.dist_self]
      calc profileDepthGap K hK T ≤ leapCost S T := Finset.inf'_le _ hS
        _ = 0 := this
    · exact Nat.zero_le _

/-! ## Arbitrarily Large Depth Gap -/

/-- For any threshold `τ`, there exists a profile with depth gap exceeding `τ`
    from any singleton corpus at the origin. -/
theorem exists_arbitrarily_large_profileDepthGap (τ : ℕ) :
    let origin : TheoremProfile := ⟨0, 0, 0, 0, 0⟩
    let K : Finset TheoremProfile := {origin}
    let hK : K.Nonempty := ⟨origin, Finset.mem_singleton_self _⟩
    let T : TheoremProfile := ⟨τ + 1, 0, 0, 0, 0⟩
    τ < profileDepthGap K hK T := by
  simp only [profileDepthGap, leapCost, Finset.inf'_singleton, Nat.dist]
  omega

/-! ## Concrete Examples -/

private def sampleCorpus : Finset TheoremProfile :=
  {⟨0, 0, 0, 10, 5⟩, ⟨1, 0, 0, 20, 15⟩, ⟨0, 1, 0, 15, 10⟩}

private theorem sampleCorpus_nonempty : sampleCorpus.Nonempty :=
  ⟨⟨0, 0, 0, 10, 5⟩, by simp [sampleCorpus]⟩

/-- The novel target has positive depth gap from the sample corpus. -/
theorem novelTarget_depthGap_pos :
    0 < profileDepthGap sampleCorpus sampleCorpus_nonempty ⟨5, 5, 5, 100, 80⟩ := by
  native_decide

/-- The derivative target is derivative at threshold 1. -/
theorem derivativeTarget_is_derivative :
    DerivativeFrom sampleCorpus ⟨0, 0, 1, 12, 6⟩ 1 := by
  native_decide

/-! ## Typed Conceptual Leaps -/

/-- Kinds of conceptual leaps between theorem presentations. -/
inductive LeapKind where
  | introDef
  | typeChange
  | perspectiveShift
  deriving DecidableEq, Repr

/-- A valid typed leap changes exactly one conceptual coordinate by 1. -/
def validTypedLeap (kind : LeapKind) (A B : TheoremProfile) : Prop :=
  match kind with
  | .introDef =>
    Nat.dist A.defsIntroduced B.defsIntroduced = 1 ∧
    A.typeChanges = B.typeChanges ∧
    A.perspectiveShifts = B.perspectiveShifts
  | .typeChange =>
    A.defsIntroduced = B.defsIntroduced ∧
    Nat.dist A.typeChanges B.typeChanges = 1 ∧
    A.perspectiveShifts = B.perspectiveShifts
  | .perspectiveShift =>
    A.defsIntroduced = B.defsIntroduced ∧
    A.typeChanges = B.typeChanges ∧
    Nat.dist A.perspectiveShifts B.perspectiveShifts = 1

/-- A valid typed leap has leap cost exactly 1. -/
theorem validTypedLeap_leapCost_one (kind : LeapKind) (A B : TheoremProfile)
    (h : validTypedLeap kind A B) :
    leapCost A B = 1 := by
  cases kind <;> simp_all [validTypedLeap, leapCost, Nat.dist_self]

/-! ## Bridge to Core.lean -/

/-- The conceptual-neighbor relation: profiles with leap cost exactly 1. -/
def ConceptualNeighbor (A B : TheoremProfile) : Prop :=
  leapCost A B = 1

instance : DecidableRel ConceptualNeighbor :=
  fun A B => inferInstanceAs (Decidable (leapCost A B = 1))

/-- Bridge: if the target is in K, it is graph-derivative at any threshold
    via the `Core.lean` framework. -/
theorem bridge_mem_derivative
    (K : Finset TheoremProfile) (T : TheoremProfile) (τ : ℕ)
    (hT : T ∈ K) :
    Derivative ConceptualNeighbor K τ T :=
  derivative_of_mem_known hT

/-- Bridge: profile-based derivativeness implies existence of a nearby witness. -/
theorem bridge_derivative_witness
    (K : Finset TheoremProfile) (T : TheoremProfile) (τ : ℕ)
    (h : DerivativeFrom K T τ) :
    ∃ S ∈ K, ∃ d, d ≤ τ ∧ d = leapCost S T := by
  obtain ⟨S, hS, hle⟩ := h
  exact ⟨S, hS, leapCost S T, hle, rfl⟩

/-- Bridge: connecting the profile-based threshold theorem to Core.lean's
    `below_threshold_derivative`. Both express the same principle:
    below a threshold, outputs are derivative. -/
theorem bridge_threshold_derivative
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T : TheoremProfile) (τ : ℕ)
    (h : profileDepthGap K hK T ≤ τ) :
    DerivativeFrom K T τ ∧
    (T ∈ K → Derivative ConceptualNeighbor K τ T) :=
  ⟨(derivativeFrom_iff_profileDepthGap_le K hK T τ).mpr h,
   fun hT => derivative_of_mem_known hT⟩

/-! ## Compression-Depth Bridge -/

/-- The depth gap is bounded by the leap cost to any particular corpus element. -/
theorem profileDepthGap_le_leapCost
    (K : Finset TheoremProfile) (hK : K.Nonempty) (T S : TheoremProfile) (hS : S ∈ K) :
    profileDepthGap K hK T ≤ leapCost S T :=
  Finset.inf'_le _ hS

/-- DerivativeFrom is monotone in the threshold. -/
theorem DerivativeFrom_mono_threshold (K : Finset TheoremProfile) (T : TheoremProfile)
    {τ₁ τ₂ : ℕ} (h : τ₁ ≤ τ₂) (hd : DerivativeFrom K T τ₁) :
    DerivativeFrom K T τ₂ := by
  obtain ⟨S, hS, hle⟩ := hd; exact ⟨S, hS, le_trans hle h⟩

/-- DerivativeFrom is monotone in the corpus. -/
theorem DerivativeFrom_mono_corpus {K₁ K₂ : Finset TheoremProfile} (h : K₁ ⊆ K₂)
    (T : TheoremProfile) (τ : ℕ) (hd : DerivativeFrom K₁ T τ) :
    DerivativeFrom K₂ T τ := by
  obtain ⟨S, hS, hle⟩ := hd; exact ⟨S, h hS, hle⟩

end NoveltyGeometry