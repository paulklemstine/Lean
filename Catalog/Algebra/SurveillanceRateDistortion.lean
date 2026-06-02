import Mathlib

/-!
# Surveillance Networks: Information-Theoretic Undetectability

## Privacy-Utility Tradeoff as a Rate-Distortion Problem

This file formalizes the fundamental tension between surveillance capability
and privacy in finite networks. We model a dynamic social network as a finite
state space, an observer as an encoding-decoding channel, and prove that
**perfect surveillance and perfect privacy are mutually exclusive** in any
non-trivial finite network.

## Main Definitions

* `NetworkDistortion` — A distortion measure on a finite network state space
* `ObservationChannel` — An encoding-decoding pair representing observer strategy
* `channelRate` — The rate (log of codebook size) of an observation channel
* `SurveillanceCapable` — A channel achieves zero distortion (perfect reconstruction)
* `PrivacyPreserving` — A channel has codebook size ≤ 1 (collects no information)

## Main Results

* `surveillance_privacy_exclusion` — **Core theorem**: perfect surveillance and
  perfect privacy are mutually exclusive for non-degenerate networks
* `positive_rate_for_zero_distortion` — Zero distortion implies rate ≥ log |states|
* `exists_nonzero_distortion_at_zero_rate` — Zero rate forces reconstruction failure
* `dynamic_surveillance_exclusion` — The exclusion scales exponentially for trajectories
* `privacy_utility_tradeoff_direction` — Monotonicity of the privacy-utility tradeoff

## Mathematical Significance

This formalizes the information-theoretic impossibility at the heart of the
surveillance debate: any observer who can perfectly reconstruct a network's
state must collect at least log(|states|) bits of information per observation.
There is no "privacy-preserving perfect surveillance" — the two goals are
mathematically contradictory for non-trivial networks.
-/

open Finset Function Real

noncomputable section

namespace SurveillanceNetwork

/-! ## §1. Network State Space and Distortion -/

/-- A `NetworkDistortion` is a pseudometric on a finite state space `S` that
measures how poorly one network state approximates another. -/
structure NetworkDistortion (S : Type*) [Fintype S] where
  d : S → S → ℝ
  d_nonneg : ∀ x y, 0 ≤ d x y
  d_self : ∀ x, d x x = 0
  d_symm : ∀ x y, d x y = d y x

/-- A network distortion is **non-degenerate** if there exist two states
with positive distortion between them. -/
def NetworkDistortion.NonDegenerate {S : Type*} [Fintype S]
    (nd : NetworkDistortion S) : Prop :=
  ∃ x y : S, 0 < nd.d x y

/-- A network distortion **separates points**: distinct states have
positive distortion. -/
def NetworkDistortion.Separating {S : Type*} [Fintype S]
    (nd : NetworkDistortion S) : Prop :=
  ∀ x y : S, nd.d x y = 0 → x = y

/-
Separating implies non-degenerate when the state space has ≥ 2 elements.
-/
theorem separating_implies_nondegenerate {S : Type*} [Fintype S]
    (nd : NetworkDistortion S) (hsep : nd.Separating)
    (hcard : 2 ≤ Fintype.card S) :
    nd.NonDegenerate := by
  obtain ⟨ x, y, hxy ⟩ := Fintype.one_lt_card_iff.mp hcard;
  exact ⟨ x, y, lt_of_le_of_ne ( nd.d_nonneg x y ) ( Ne.symm ( by rintro h; exact hxy ( hsep x y h ) ) ) ⟩

/-! ## §2. Observation Channel -/

/-- An `ObservationChannel` models an observer's surveillance strategy:
encode the network state into a compressed code, then decode back. -/
structure ObservationChannel (S : Type*) (C : Type*) [Fintype S] [Fintype C] where
  encode : S → C
  decode : C → S

/-- The **rate** of an observation channel: log of the codebook size. -/
def channelRate (S : Type*) (C : Type*) [Fintype S] [Fintype C]
    (_ch : ObservationChannel S C) : ℝ :=
  Real.log (Fintype.card C : ℝ)

/-- A channel is **surveillance-capable** if it achieves perfect reconstruction:
decode ∘ encode = id with respect to the distortion. -/
def SurveillanceCapable {S : Type*} {C : Type*} [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C) : Prop :=
  ∀ s : S, nd.d s (ch.decode (ch.encode s)) = 0

/-- A channel is **privacy-preserving** if the codebook has at most one element. -/
def PrivacyPreserving (S : Type*) (C : Type*) [Fintype S] [Fintype C]
    (_ch : ObservationChannel S C) : Prop :=
  Fintype.card C ≤ 1

/-! ## §3. Core Lemmas -/

/-
If a channel achieves zero distortion with a separating distortion,
then decode ∘ encode = id.
-/
theorem roundtrip_eq_of_zero_distortion
    {S C : Type*} [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C)
    (hsep : nd.Separating)
    (hperf : SurveillanceCapable nd ch) :
    ∀ s : S, ch.decode (ch.encode s) = s := by
  intro s; have := hsep; have := hperf s; have := nd.d_symm; aesop;

/-
If decode ∘ encode = id, then encode must be injective.
-/
theorem encode_injective_of_roundtrip
    {S C : Type*} [Fintype S] [Fintype C]
    (ch : ObservationChannel S C)
    (hrt : ∀ s : S, ch.decode (ch.encode s) = s) :
    Function.Injective ch.encode := by
  exact fun x y hxy => hrt x ▸ hrt y ▸ hxy ▸ rfl

/-
If encode is injective, the codebook is at least as large as the state space.
-/
theorem card_codebook_ge_of_injective
    {S C : Type*} [Fintype S] [Fintype C]
    (ch : ObservationChannel S C)
    (hinj : Function.Injective ch.encode) :
    Fintype.card S ≤ Fintype.card C := by
  exact Fintype.card_le_of_injective _ hinj

/-
When the codebook has ≤ 1 element, the encoder is constant.
-/
theorem encode_constant_of_privacy
    {S C : Type*} [Fintype S] [Fintype C] [Nonempty S]
    (ch : ObservationChannel S C)
    (hpriv : PrivacyPreserving S C ch) :
    ∀ s₁ s₂ : S, ch.encode s₁ = ch.encode s₂ := by
  exact fun s₁ s₂ => by have := Fintype.card_le_one_iff_subsingleton.mp hpriv; exact Subsingleton.elim _ _;

/-! ## §4. Main Theorems -/

/-
**Surveillance-Privacy Exclusion Theorem**: For any finite network with a
separating distortion and at least two states, no observation channel can
simultaneously achieve perfect surveillance and perfect privacy.
-/
theorem surveillance_privacy_exclusion
    {S C : Type*} [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C)
    (hsep : nd.Separating)
    (hcard : 2 ≤ Fintype.card S) :
    ¬(SurveillanceCapable nd ch ∧ PrivacyPreserving S C ch) := by
  intro h
  obtain ⟨h_surv, h_priv⟩ := h
  have h_inj : Function.Injective ch.encode := by
    exact encode_injective_of_roundtrip ch ( roundtrip_eq_of_zero_distortion nd ch hsep h_surv )
  have h_card : Fintype.card S ≤ Fintype.card C := by
    exact Fintype.card_le_of_injective _ h_inj
  have h_card_le : Fintype.card C ≤ 1 := by
    exact h_priv
  have h_contra : Fintype.card S ≤ 1 := by
    exact le_trans h_card h_card_le
  linarith [hcard]

/-
**Positive Rate Theorem**: Zero distortion implies rate ≥ log(|S|).
-/
theorem positive_rate_for_zero_distortion
    {S C : Type*} [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C)
    (hsep : nd.Separating)
    (hperf : SurveillanceCapable nd ch) :
    Real.log (Fintype.card S : ℝ) ≤ channelRate S C ch := by
  -- From SurveillanceCapable + Separating, get |S| ≤ |C| via roundtrip → injective → card bound.
  have h_card_bound : Fintype.card S ≤ Fintype.card C := by
    exact card_codebook_ge_of_injective ch ( encode_injective_of_roundtrip ch ( roundtrip_eq_of_zero_distortion nd ch hsep hperf ) );
  by_cases h : Fintype.card S = 0 <;> by_cases h' : Fintype.card C = 0 <;> simp_all +decide [ channelRate ];
  · exact Real.log_nonneg ( mod_cast Nat.one_le_iff_ne_zero.mpr h' );
  · exact Real.log_le_log ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero h ) ) ( Nat.cast_le.mpr h_card_bound )

/-
**Reconstruction Failure at Zero Rate**: With codebook size ≤ 1
and a non-degenerate separating distortion, reconstruction must fail
on some state.
-/
theorem exists_nonzero_distortion_at_zero_rate
    {S C : Type*} [Fintype S] [Fintype C] [Nonempty S]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C)
    (hsep : nd.Separating)
    (hnd : nd.NonDegenerate)
    (hpriv : PrivacyPreserving S C ch) :
    ∃ s : S, 0 < nd.d s (ch.decode (ch.encode s)) := by
  obtain ⟨ x, y, hxy ⟩ := hnd;
  by_cases hxy' : ch.decode ( ch.encode x ) = x;
  · use y;
    rw [ encode_constant_of_privacy ];
    rw [ hxy', nd.d_symm ] ; exact hxy;
    exact hpriv;
  · exact ⟨ x, lt_of_le_of_ne ( nd.d_nonneg _ _ ) ( Ne.symm ( by intro h; have := hsep _ _ h; tauto ) ) ⟩

/-
The codebook size for a surveillance-capable channel with separating
distortion must be at least |S|.
-/
theorem rate_distortion_counting_bound
    {S C : Type*} [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C)
    (hsep : nd.Separating)
    (hperf : SurveillanceCapable nd ch) :
    Fintype.card S ≤ Fintype.card C := by
  convert card_codebook_ge_of_injective ch _;
  exact encode_injective_of_roundtrip ch ( roundtrip_eq_of_zero_distortion nd ch hsep hperf )

/-! ## §5. Hamming Distortion on Edge Sets -/

/-- The **Hamming distortion** on graphs with `n` vertices. States are
adjacency functions, distortion counts differing edges. -/
def hammingEdgeDistortion (n : ℕ) : NetworkDistortion (Fin n → Fin n → Bool) where
  d g₁ g₂ := (Finset.univ.sum fun i =>
    Finset.univ.sum fun j => if g₁ i j = g₂ i j then (0 : ℝ) else 1)
  d_nonneg := by
    intro g₁ g₂
    apply Finset.sum_nonneg; intro i _
    apply Finset.sum_nonneg; intro j _
    split <;> linarith
  d_self := by intro g; simp
  d_symm := by intro g₁ g₂; congr 1; ext i; congr 1; ext j; simp [eq_comm]

/-
The Hamming distortion on edges separates points.
-/
theorem hammingEdgeDistortion_separating (n : ℕ) :
    (hammingEdgeDistortion n).Separating := by
  intro g₁ g₂ h; contrapose! h; simp_all +decide [ hammingEdgeDistortion ] ;
  simp_all +decide [ funext_iff, Finset.sum_ite ];
  rw [ Finset.sum_eq_zero_iff_of_nonneg ] <;> aesop

/-! ## §6. Dynamic Network Extension -/

/-- A **trajectory observation channel** encodes an entire time-series
of network states. -/
structure TrajectoryChannel (S : Type*) (C : Type*) (T : ℕ)
    [Fintype S] [Fintype C] where
  encode : (Fin T → S) → C
  decode : C → Fin T → S

/-
**Dynamic Surveillance-Privacy Exclusion**: Perfect surveillance of T ≥ 1
time steps of a network with |S| ≥ 2 requires codebook size ≥ |S|^T.
-/
theorem dynamic_surveillance_exclusion
    {S C : Type*} {T : ℕ}
    [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (tch : TrajectoryChannel S C T)
    (hsep : nd.Separating)
    (_hT : 0 < T)
    (_hcard : 2 ≤ Fintype.card S)
    (hperf : ∀ traj : Fin T → S, ∀ t : Fin T,
      nd.d (traj t) (tch.decode (tch.encode traj) t) = 0) :
    Fintype.card S ^ T ≤ Fintype.card C := by
  have h_encode_injective : Function.Injective tch.encode := by
    have h_decode_roundtrip : ∀ traj : Fin T → S, tch.decode (tch.encode traj) = traj := by
      exact fun traj => funext fun t => hsep _ _ ( hperf traj t ) ▸ rfl;
    exact fun x y hxy => h_decode_roundtrip x ▸ h_decode_roundtrip y ▸ hxy ▸ rfl;
  simpa using Fintype.card_le_of_injective tch.encode h_encode_injective

/-! ## §7. Privacy-Utility Tradeoff Direction -/

/-- The **privacy level** of a channel: 1 - (rate / max_rate). -/
def privacyLevel (S : Type*) (C : Type*) [Fintype S] [Fintype C]
    (ch : ObservationChannel S C) : ℝ :=
  1 - channelRate S C ch / Real.log (Fintype.card S : ℝ)

/-
**Privacy-Utility Tradeoff**: A surveillance-capable channel has
privacy level ≤ 0 when |S| ≥ 2 (since it needs rate ≥ log|S|, giving
privacy ≤ 1 - 1 = 0). A privacy-preserving channel has privacy level ≥ 1.
-/
theorem surveillance_channel_low_privacy
    {S C : Type*} [Fintype S] [Fintype C]
    (nd : NetworkDistortion S) (ch : ObservationChannel S C)
    (hsep : nd.Separating)
    (hcard : 2 ≤ Fintype.card S)
    (hperf : SurveillanceCapable nd ch) :
    privacyLevel S C ch ≤ 0 := by
  unfold privacyLevel; rw [ sub_nonpos ] ; rw [ div_eq_mul_inv ] ;
  rw [ ← div_eq_mul_inv, one_le_div ( Real.log_pos <| mod_cast hcard ) ] ; exact positive_rate_for_zero_distortion nd ch hsep hperf

theorem privacy_channel_high_privacy
    {S C : Type*} [Fintype S] [Fintype C]
    (_ch : ObservationChannel S C)
    (hcard : 2 ≤ Fintype.card S)
    (hpriv : PrivacyPreserving S C _ch) :
    1 ≤ privacyLevel S C _ch := by
  unfold privacyLevel; simp +decide [ * ] ;
  exact div_nonpos_of_nonpos_of_nonneg ( Real.log_nonpos ( Nat.cast_nonneg _ ) ( mod_cast hpriv ) ) ( Real.log_nonneg ( mod_cast hcard.trans' ( by norm_num ) ) )

end SurveillanceNetwork