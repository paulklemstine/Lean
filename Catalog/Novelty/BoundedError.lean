/-
# Bounded-error surveillance and the sharp rate–distortion law

This file deepens the information-theoretic study of surveillance on finite
dynamic networks.  An observer watches a network whose instantaneous
configuration ranges over a finite state space `S`.  It records a measurement in
an alphabet `M` through a channel `obs : S → M` and later reconstructs the
configuration with a decoder `dec : M → S`.  The **rate** of a channel is the
number of distinct records it can emit.

We prove two families of results that go beyond the exact-reconstruction regime.

## 1. A combinatorial Fano bound (bounded-error surveillance)

The set of configurations the observer reconstructs correctly has size at most
the rate (`reconSet_card_le_rate`).  Consequently the number of *misreconstructed*
configurations is at least `|S| - rate` (`fano_error_bound`), so to keep the
number of errors within a budget `k` the observer must collect rate at least
`|S| - k` (`bounded_error_rate_lower`), i.e. at least `log₂ (|S| - k)` bits
(`bounded_error_bits`).  In particular a *perfectly private* observer
(rate `= 1`) misreconstructs all but one configuration
(`privacy_error_bound`): perfect privacy and low-error surveillance are
quantitatively incompatible.

## 2. A sharp rate–distortion law

Fix a dissimilarity `d : S → S → ℕ` and a distortion budget `D`.  A channel/decoder
pair *achieves distortion `D`* when every configuration is reconstructed within
`D`.  We show:

* every achieving pair induces a `D`-cover of the state space by the decoded
  records, of size at most the rate (`achieves_gives_cover`);
* conversely, every `D`-cover is realised by an explicit channel of rate at most
  the cover size (`cover_achieves_rate`).

Combining the two, the minimum achievable surveillance rate equals the
`D`-covering number of the network (`rate_distortion_sharp`): the privacy–utility
tradeoff *is* a covering problem, and the bound is tight.
-/
import Mathlib

open Function Finset

namespace SurveillanceBoundedError

variable {S M : Type*} [Fintype S] [Fintype M] [DecidableEq S] [DecidableEq M]

/-- The **rate** of a channel: the number of distinct records it can emit. -/
def rate (obs : S → M) : ℕ := (Finset.univ.image obs).card

/-- The channel reveals nothing: every configuration yields the same record. -/
def PerfectPrivacy (obs : S → M) : Prop := ∀ s t, obs s = obs t

/-- The set of configurations the observer reconstructs correctly. -/
def reconSet (obs : S → M) (dec : M → S) : Finset S :=
  Finset.univ.filter (fun s => dec (obs s) = s)

/-- The set of configurations the observer misreconstructs. -/
def errSet (obs : S → M) (dec : M → S) : Finset S :=
  Finset.univ.filter (fun s => dec (obs s) ≠ s)

/-! ### 1. The combinatorial Fano bound -/

omit [DecidableEq S] in
/--
The rate is at most the size of the record alphabet.
-/
theorem rate_le_card_M (obs : S → M) : rate obs ≤ Fintype.card M := by
  exact Finset.card_le_univ _

omit [Fintype M] in
/--
**Correctly reconstructed configurations are limited by the rate.**  On the
set of correctly reconstructed configurations the channel is injective (the
decoder inverts it), so their number cannot exceed the number of distinct
records.
-/
theorem reconSet_card_le_rate (obs : S → M) (dec : M → S) :
    (reconSet obs dec).card ≤ rate obs := by
  refine' le_trans _ ( Finset.card_le_card <| show Finset.image obs ( reconSet obs dec ) ⊆ Finset.image obs Finset.univ from Finset.image_subset_image <| Finset.filter_subset _ _ );
  rw [ Finset.card_image_of_injOn ];
  intro s hs t ht hst; have := Finset.mem_filter.mp hs; have := Finset.mem_filter.mp ht; aesop;

omit [Fintype M] in
/--
**Combinatorial Fano bound.**  The state space splits into correctly and
incorrectly reconstructed configurations, so the number of errors is at least
`|S| - rate`: `|S| ≤ rate + #errors`.
-/
theorem fano_error_bound (obs : S → M) (dec : M → S) :
    Fintype.card S ≤ rate obs + (errSet obs dec).card := by
  convert Nat.le_trans ?_ ( Nat.add_le_add_right ( reconSet_card_le_rate obs dec ) ( Finset.card ( Finset.univ.filter fun x => dec ( obs x ) ≠ x ) ) );
  rw [ ← Finset.card_union_of_disjoint ];
  · convert Finset.card_le_card _;
    exact fun x _ => if hx : dec ( obs x ) = x then Finset.mem_union_left _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩ ) else Finset.mem_union_right _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩ );
  · exact Finset.disjoint_filter.mpr ( by aesop )

omit [Fintype M] in
/--
**Minimum rate for bounded-error surveillance.**  If the observer
misreconstructs at most `k` configurations, its rate is at least `|S| - k`.
-/
theorem bounded_error_rate_lower (obs : S → M) (dec : M → S) (k : ℕ)
    (hk : (errSet obs dec).card ≤ k) :
    Fintype.card S - k ≤ rate obs := by
  exact Nat.sub_le_of_le_add <| by linarith [ fano_error_bound obs dec ] ;

/--
**Minimum information for bounded-error surveillance.**  Reconstructing all
but at most `k` configurations of a finite network requires the observer to
collect at least `log₂ (|S| - k)` bits.
-/
theorem bounded_error_bits (obs : S → M) (dec : M → S) (k : ℕ)
    (hk : (errSet obs dec).card ≤ k) :
    Nat.log 2 (Fintype.card S - k) ≤ Nat.log 2 (Fintype.card M) := by
  refine' Nat.log_mono_right _;
  exact le_trans ( bounded_error_rate_lower obs dec k hk ) ( rate_le_card_M obs )

omit [Fintype M] [DecidableEq S] in
/--
A perfectly private channel has rate exactly `1`.
-/
theorem rate_eq_one_of_privacy [Nonempty S] {obs : S → M} (hp : PerfectPrivacy obs) :
    rate obs = 1 := by
  rw [ rate ];
  rw [ Finset.card_eq_one ] ; exact ⟨ obs ( Classical.arbitrary S ), by aesop ⟩ ;

omit [Fintype M] in
/--
**Privacy forces near-total error.**  A perfectly private observer
misreconstructs all but at most one configuration: `#errors ≥ |S| - 1`.  Perfect
privacy and low-error surveillance are therefore mutually exclusive on any
non-trivial network.
-/
theorem privacy_error_bound [Nonempty S] {obs : S → M} {dec : M → S}
    (hp : PerfectPrivacy obs) :
    Fintype.card S - 1 ≤ (errSet obs dec).card := by
  have h := fano_error_bound obs dec
  rw [rate_eq_one_of_privacy hp] at h
  omega

/-! ### 2. The sharp rate–distortion law -/

/-- `C` is a `D`-cover: every configuration lies within distortion `D` of some
center in `C`. -/
def IsDCover (d : S → S → ℕ) (D : ℕ) (C : Finset S) : Prop :=
  ∀ s, ∃ c ∈ C, d c s ≤ D

/-- The pair `(obs, dec)` reconstructs every configuration to within distortion
`D`. -/
def AchievesDistortion (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D : ℕ) : Prop :=
  ∀ s, d (dec (obs s)) s ≤ D

omit [Fintype M] in
/--
**Every achieving pair induces a small cover.**  The decoded records of an
achieving channel form a `D`-cover of the state space, of size at most the
rate.
-/
theorem achieves_gives_cover (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D : ℕ)
    (h : AchievesDistortion obs dec d D) :
    IsDCover d D ((Finset.univ.image obs).image dec) ∧
      ((Finset.univ.image obs).image dec).card ≤ rate obs := by
  refine' ⟨ _, _ ⟩;
  · exact fun s => ⟨ dec ( obs s ), Finset.mem_image_of_mem _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ), h s ⟩;
  · exact Finset.card_image_le

/--
**Every cover is realised by a channel.**  Given a `D`-cover `C`, there is a
channel `obs : S → S` with identity decoder that achieves distortion `D` and has
rate at most `|C|`.
-/
theorem cover_achieves_rate (d : S → S → ℕ) (D : ℕ) (C : Finset S)
    (hC : IsDCover d D C) :
    ∃ (obs : S → S) (dec : S → S),
      AchievesDistortion obs dec d D ∧ rate obs ≤ C.card := by
  have h_image_subset : ∃ obs : S → S, (∀ s, obs s ∈ C ∧ d (obs s) s ≤ D) := by
    exact ⟨ fun s => Classical.choose ( hC s ), fun s => Classical.choose_spec ( hC s ) ⟩;
  obtain ⟨obs, hobs⟩ := h_image_subset;
  use fun s => obs s, fun s => s;
  simp [AchievesDistortion, hobs];
  exact Finset.card_le_card ( Finset.image_subset_iff.mpr fun s _ => hobs s |>.1 )

/-- The **`D`-covering number** of the network: the least size of a `D`-cover. -/
noncomputable def minCover (d : S → S → ℕ) (D : ℕ) : ℕ :=
  sInf {n | ∃ C : Finset S, IsDCover d D C ∧ C.card = n}

omit [DecidableEq S] in
/--
Under the mild reflexivity budget `d s s ≤ D`, the whole space is a cover, so
the covering number is attained by an actual cover.
-/
theorem minCover_spec (d : S → S → ℕ) (D : ℕ) (hrefl : ∀ s, d s s ≤ D) :
    ∃ C : Finset S, IsDCover d D C ∧ C.card = minCover d D := by
  have h_nonempty : ∃ C : Finset S, IsDCover d D C := by
    exact ⟨ Finset.univ, fun s => ⟨ s, Finset.mem_univ _, hrefl s ⟩ ⟩;
  convert Nat.sInf_mem ( show { n : ℕ | ∃ C : Finset S, IsDCover d D C ∧ #C = n }.Nonempty from ?_ ) using 1;
  exact ⟨ _, ⟨ h_nonempty.choose, h_nonempty.choose_spec, rfl ⟩ ⟩

omit [Fintype M] in
/--
The covering number lower-bounds the rate of any achieving channel.
-/
theorem minCover_le_rate (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D : ℕ)
    (h : AchievesDistortion obs dec d D) :
    minCover d D ≤ rate obs := by
  obtain ⟨C, hC⟩ : ∃ C : Finset S, IsDCover d D C ∧ C.card ≤ rate obs := by
    exact ⟨ _, achieves_gives_cover obs dec d D h |>.1, achieves_gives_cover obs dec d D h |>.2 ⟩;
  exact le_trans ( Nat.sInf_le ⟨ C, hC.1, rfl ⟩ ) hC.2

/--
**Sharp rate–distortion law.**  Assuming each configuration reconstructs to
itself within the budget (`d s s ≤ D`), the minimum surveillance rate achieving
distortion `D` equals the `D`-covering number of the network: it is a lower bound
for every achieving channel, and it is attained by an explicit one.
-/
theorem rate_distortion_sharp (d : S → S → ℕ) (D : ℕ) (hrefl : ∀ s, d s s ≤ D) :
    (∀ (obs dec : S → S), AchievesDistortion obs dec d D → minCover d D ≤ rate obs) ∧
      (∃ (obs dec : S → S), AchievesDistortion obs dec d D ∧ rate obs = minCover d D) := by
  refine' ⟨ fun obs dec h => _, _ ⟩;
  · -- By definition of `minCover`, we know that `minCover d D` is a lower bound for the rate of any achieving channel.
    apply minCover_le_rate; assumption;
  · obtain ⟨ C, hC₁, hC₂ ⟩ := minCover_spec d D hrefl;
    obtain ⟨ obs, dec, h₁, h₂ ⟩ := cover_achieves_rate d D C hC₁;
    exact ⟨ obs, dec, h₁, le_antisymm ( h₂.trans hC₂.le ) ( minCover_le_rate obs dec d D h₁ ) ⟩

/-! ### Concrete instantiation: directed social networks on `n` nodes -/

/--
The number of directed network snapshots on `n` nodes is `2 ^ (n * n)`.
-/
theorem card_directed_network (n : ℕ) :
    Fintype.card (Fin n → Fin n → Bool) = 2 ^ (n * n) := by
  simp +decide [ pow_mul' ]

/--
**Bounded-error surveillance of a directed network costs almost `n²` bits.**
Any observer that reconstructs all but at most `k` directed social networks on
`n` nodes must collect at least `log₂ (2^(n*n) - k)` bits.
-/
theorem directed_network_bounded_error_bits {M : Type*} [Fintype M] {n k : ℕ}
    (obs : (Fin n → Fin n → Bool) → M) (dec : M → (Fin n → Fin n → Bool))
    (hk : (errSet obs dec).card ≤ k) :
    Nat.log 2 (2 ^ (n * n) - k) ≤ Nat.log 2 (Fintype.card M) := by
  convert bounded_error_bits obs dec k hk using 1;
  · rw [ card_directed_network ];
  · exact Classical.decEq M

end SurveillanceBoundedError