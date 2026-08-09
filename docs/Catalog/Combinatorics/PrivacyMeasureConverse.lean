/-
# A measure-theoretic (Fano-type) converse for private surveillance

This file settles the *counting-to-measure* half of open direction **1** of
`Catalog/Applications/SurveillanceNetworks/PrivacyThreshold.lean`
("Entropy-sensitive converse"): the excess-distortion converse
`card_good_le_rate_mul_ball` is a statement about cardinalities, and the direction
asks for the version in which the good set is replaced by a *probability measure*
with excess-distortion probability `ε`.

The results are:

* `mass_good_le_rate_mul_ballMass` — **measure fibre-covering converse.**  For any
  nonnegative source law `p`, if every distortion ball has `p`-mass at most `β` and
  the decoder is correct on a set `G`, then `p(G) ≤ rate · β`.  This is the exact
  measure analogue of the counting bound, and it degenerates to it for the counting
  measure.
* `one_sub_eps_le_rate_mul_ballMass` — **excess-distortion form.**  If the channel
  fails with probability at most `ε`, then `1 − ε ≤ rate · β`: the Fano-type
  skeleton, with `β` playing the role of `vol_D / |S|` and `rate` the role of the
  number of decoder messages.
* `hamming_uniform_excess_bound` — for the uniform source and Hamming distortion
  this is the concrete inequality `(1 − ε)·2^{|α|} ≤ rate · ∑_{i ≤ D} C(|α|, i)`.
* `private_excess_volume_bound` — a **perfectly private** observer has `rate = 1`,
  so `(1 − ε)·2^{|α|} ≤ ∑_{i ≤ D} C(|α|, i)`.
* `sum_choose_lt_two_pow` and `private_zero_excess_forces_full_distortion` — the
  binomial tail is strictly smaller than `2^{|α|}` below the top radius, hence at
  `ε = 0` the measure converse *re-derives* the sharp privacy threshold
  `D = |α|`: the qualitative threshold theorem is the zero-excess corner of the
  quantitative inequality.
* `private_excess_prob_ge` — reading the same inequality as a lower bound on the
  failure probability: a private observer working at radius `D` must fail with
  probability at least `1 − vol_D / 2^{|α|}`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The fibre-covering argument should be insensitive to
the counting measure: replacing cardinalities by any nonnegative weight should give
`p(G) ≤ rate · max_c p(B(c,D))`, and specializing to the uniform law should return a
Fano-type excess-distortion bound whose `ε = 0` corner is exactly the sharp
threshold of the parent file.

EXPERIMENT (Experimenter).  Formalized the weighted fibre decomposition
`G = ⨆_{m ∈ obs(G)} (G ∩ obs⁻¹ m)` and summed `p` over it; the only extra input
compared with the counting proof is `Finset.sum_le_sum_of_subset_of_nonneg`, which
is where nonnegativity of `p` enters (and is genuinely needed: with signed weights
the statement is false).  The uniform specialization uses the exact ball volume
`hamming_ball_card` of the parent file.

ANALYSIS (Analyst).  The counting converse and the measure converse are the same
inequality over two different semirings; what the measure version adds is the
*slack parameter* `ε`, and the sharp threshold is recovered by a strict binomial
inequality `∑_{i ≤ D} C(n,i) < 2^n` for `D < n` rather than by a covering argument.
This is the promised "counting shadow" being lifted: the remaining gap to a full
entropy statement is exactly the passage from `p(G)` to `H(X) − H(X|Y)`.

CRITIQUE (Critic).  Nonnegativity of `p` and `0 ≤ β` are load-bearing and are
stated explicitly; `β ≥ 0` is derived, not assumed, from a ball mass.  The
`ε = 0` corollary is not circular: it does not use the threshold theorem of the
parent file but re-proves it from the volume inequality.  No result here is `True`,
`rfl`-only or `decide`-only.
-/
import Applications.SurveillanceNetworks.PrivacyThreshold
import Combinatorics.PrivateAverageDistortion

open Finset SurveillanceNetworks.Privacy SurveillanceNetworks.AvgPrivacy

namespace SurveillanceNetworks.MeasureConverse

variable {S M : Type*} [Fintype S] [DecidableEq S] [DecidableEq M]

/-! ## The measure version of the fibre-covering converse -/

/-- **Measure fibre-covering converse.**  If every distortion ball carries `p`-mass
at most `β` and the decoder is correct on `G`, then `p(G) ≤ rate · β`. -/
theorem mass_good_le_rate_mul_ballMass [Nonempty S] (p : S → ℝ) (hp : ∀ s, 0 ≤ p s)
    (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D : ℕ) (β : ℝ)
    (hball : ∀ c : S, ∑ s ∈ univ.filter fun s => d c s ≤ D, p s ≤ β)
    (G : Finset S) (hrec : ∀ s ∈ G, d (dec (obs s)) s ≤ D) :
    ∑ s ∈ G, p s ≤ (rate obs : ℝ) * β := by
  classical
  have hβ : 0 ≤ β := by
    refine le_trans (Finset.sum_nonneg fun s _ => hp s) (hball (Classical.arbitrary S))
  have hdecomp : G = (G.image obs).biUnion (fun m => G.filter fun s => obs s = m) := by
    ext s; simp [Finset.mem_biUnion]; tauto
  have hdisj : ∀ m₁ ∈ G.image obs, ∀ m₂ ∈ G.image obs, m₁ ≠ m₂ →
      Disjoint (G.filter fun s => obs s = m₁) (G.filter fun s => obs s = m₂) := by
    intro m₁ _ m₂ _ hne
    refine Finset.disjoint_left.mpr fun s hs₁ hs₂ => ?_
    simp only [mem_filter] at hs₁ hs₂
    exact hne (hs₁.2.symm.trans hs₂.2)
  have hsum : ∑ s ∈ G, p s
      = ∑ m ∈ G.image obs, ∑ s ∈ G.filter fun s => obs s = m, p s := by
    conv_lhs => rw [hdecomp]
    exact Finset.sum_biUnion (fun m₁ h₁ m₂ h₂ hne => hdisj m₁ h₁ m₂ h₂ hne)
  have hterm : ∀ m ∈ G.image obs, (∑ s ∈ G.filter fun s => obs s = m, p s) ≤ β := by
    intro m _
    have hsub : (G.filter fun s => obs s = m) ⊆ univ.filter fun s => d (dec m) s ≤ D := by
      intro s hs
      simp only [mem_filter] at hs
      have h := hrec s hs.1
      rw [hs.2] at h
      simp [mem_filter, h]
    exact le_trans
      (Finset.sum_le_sum_of_subset_of_nonneg hsub fun s _ _ => hp s) (hball (dec m))
  calc ∑ s ∈ G, p s = ∑ m ∈ G.image obs, ∑ s ∈ G.filter fun s => obs s = m, p s := hsum
    _ ≤ ∑ _m ∈ G.image obs, β := Finset.sum_le_sum hterm
    _ = ((G.image obs).card : ℝ) * β := by rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ (rate obs : ℝ) * β := by
        refine mul_le_mul_of_nonneg_right ?_ hβ
        exact_mod_cast Finset.card_le_card (Finset.image_subset_image (subset_univ G))

/-- **Excess-distortion (Fano-type) converse.**  If the channel/decoder pair is
correct outside a failure event of probability at most `ε`, and every distortion
ball has mass at most `β`, then `1 − ε ≤ rate · β`. -/
theorem one_sub_eps_le_rate_mul_ballMass [Nonempty S] (p : S → ℝ) (hp : ∀ s, 0 ≤ p s)
    (hp1 : ∑ s, p s = 1) (obs : S → M) (dec : M → S) (d : S → S → ℕ) (D : ℕ) (β ε : ℝ)
    (hball : ∀ c : S, ∑ s ∈ univ.filter fun s => d c s ≤ D, p s ≤ β)
    (G : Finset S) (hrec : ∀ s ∈ G, d (dec (obs s)) s ≤ D)
    (hexc : ∑ s ∈ univ \ G, p s ≤ ε) :
    1 - ε ≤ (rate obs : ℝ) * β := by
  have hsplit : ∑ s ∈ G, p s + ∑ s ∈ univ \ G, p s = 1 := by
    rw [add_comm, Finset.sum_sdiff (Finset.subset_univ G)]
    exact hp1
  have hgood : 1 - ε ≤ ∑ s ∈ G, p s := by linarith
  exact le_trans hgood (mass_good_le_rate_mul_ballMass p hp obs dec d D β hball G hrec)

/-! ## The uniform source on binary tensors -/

variable {α : Type*} [Fintype α] [DecidableEq α]

-- The uniform law `unif` on binary tensors, its nonnegativity and normalization are
-- reused from `Catalog/Combinatorics/PrivateAverageDistortion.lean`.

/-- The uniform mass of a Hamming ball is its exact volume divided by `2^{|α|}`. -/
theorem unif_ball_mass (c : α → Bool) (D : ℕ) :
    ∑ s ∈ univ.filter fun s : α → Bool => hdist c s ≤ D, unif α s
      = (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ) / 2 ^ Fintype.card α := by
  unfold unif
  rw [Finset.sum_const, nsmul_eq_mul, hamming_ball_card]
  push_cast
  ring

/-- **Concrete excess-distortion bound for surveillance of binary tensors.**  If the
observer reconstructs every history outside a failure event of probability `ε`
within Hamming distortion `D`, then
`(1 − ε)·2^{|α|} ≤ rate · ∑_{i ≤ D} C(|α|, i)`. -/
theorem hamming_uniform_excess_bound
    (obs : (α → Bool) → M) (dec : M → (α → Bool)) (D : ℕ) (ε : ℝ)
    (G : Finset (α → Bool)) (hrec : ∀ s ∈ G, hdist (dec (obs s)) s ≤ D)
    (hexc : ∑ s ∈ univ \ G, unif α s ≤ ε) :
    (1 - ε) * 2 ^ Fintype.card α
      ≤ (rate obs : ℝ) * (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ) := by
  have hpos : (0 : ℝ) < 2 ^ Fintype.card α := by positivity
  have key := one_sub_eps_le_rate_mul_ballMass (unif α) unif_nonneg sum_unif obs dec
    hdist D ((∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ) / 2 ^ Fintype.card α) ε
    (fun c => le_of_eq (unif_ball_mass c D)) G hrec hexc
  rw [← mul_div_assoc] at key
  exact (le_div_iff₀ hpos).mp key

omit [DecidableEq S] in
/-- **Private observers.**  A perfectly private channel emits a single record, so
its rate is `1`. -/
theorem rate_eq_one_of_privacy [Nonempty S] {obs : S → M} (hp : PerfectPrivacy obs) :
    rate obs = 1 := by
  rw [rate, Finset.card_eq_one]
  refine ⟨obs (Classical.arbitrary S), Finset.eq_singleton_iff_unique_mem.2 ⟨?_, ?_⟩⟩
  · exact Finset.mem_image_of_mem obs (Finset.mem_univ _)
  · intro x hx
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hx
    obtain ⟨a, ha⟩ := hx
    rw [← ha]
    exact hp a _

/-- **Quantitative privacy threshold with slack.**  A perfectly private observer
that reconstructs binary tensors within Hamming distortion `D` outside a failure
event of probability `ε` forces the binomial tail to be almost everything:
`(1 − ε)·2^{|α|} ≤ ∑_{i ≤ D} C(|α|, i)`. -/
theorem private_excess_volume_bound
    (obs : (α → Bool) → M) (dec : M → (α → Bool)) (hpriv : PerfectPrivacy obs)
    (D : ℕ) (ε : ℝ) (G : Finset (α → Bool)) (hrec : ∀ s ∈ G, hdist (dec (obs s)) s ≤ D)
    (hexc : ∑ s ∈ univ \ G, unif α s ≤ ε) :
    (1 - ε) * 2 ^ Fintype.card α
      ≤ (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ) := by
  have h := hamming_uniform_excess_bound obs dec D ε G hrec hexc
  rwa [rate_eq_one_of_privacy hpriv, Nat.cast_one, one_mul] at h

/-! ## Strict binomial tails and the zero-excess corner -/

/-- Below the top radius the binomial tail is *strictly* smaller than `2^n`. -/
theorem sum_choose_lt_two_pow {n D : ℕ} (h : D < n) :
    ∑ i ∈ range (D + 1), n.choose i < 2 ^ n := by
  have hfull : ∑ i ∈ range (n + 1), n.choose i = 2 ^ n := Nat.sum_range_choose n
  have hsub : range (D + 1) ⊆ range (n + 1) := by
    intro i hi
    simp only [Finset.mem_range] at hi ⊢
    omega
  have hmem : n ∈ range (n + 1) := by simp
  have hnot : n ∉ range (D + 1) := by simp only [Finset.mem_range]; omega
  have hpos : 0 < n.choose n := by simp
  have hlt := Finset.sum_lt_sum_of_subset (f := fun i => n.choose i) hsub hmem hnot hpos
    (fun j _ _ => Nat.zero_le _)
  simp only [] at hlt
  omega

/-- **The sharp privacy threshold is the zero-excess corner of the measure
converse.**  A perfectly private observer that reconstructs *every* binary tensor
within Hamming distortion `D` must have `D ≥ |α|`; the proof here goes through the
volume inequality rather than through a covering argument. -/
theorem private_zero_excess_forces_full_distortion
    (obs : (α → Bool) → M) (dec : M → (α → Bool)) (hpriv : PerfectPrivacy obs)
    (D : ℕ) (hrec : ∀ s, hdist (dec (obs s)) s ≤ D) :
    Fintype.card α ≤ D := by
  by_contra hlt
  push_neg at hlt
  have h := private_excess_volume_bound obs dec hpriv D 0 (univ : Finset (α → Bool))
    (fun s _ => hrec s) (by simp)
  rw [sub_zero, one_mul] at h
  have hstrict : (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℕ) < 2 ^ Fintype.card α :=
    sum_choose_lt_two_pow hlt
  have : (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ)
      < (2 : ℝ) ^ Fintype.card α := by exact_mod_cast hstrict
  linarith

/-- **Failure probability of a private observer.**  Working at Hamming radius `D`,
a perfectly private observer must fail with probability at least
`1 − vol_D / 2^{|α|}`. -/
theorem private_excess_prob_ge
    (obs : (α → Bool) → M) (dec : M → (α → Bool)) (hpriv : PerfectPrivacy obs)
    (D : ℕ) (ε : ℝ) (G : Finset (α → Bool)) (hrec : ∀ s ∈ G, hdist (dec (obs s)) s ≤ D)
    (hexc : ∑ s ∈ univ \ G, unif α s ≤ ε) :
    1 - (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ) / 2 ^ Fintype.card α ≤ ε := by
  have hpos : (0 : ℝ) < 2 ^ Fintype.card α := by positivity
  have h := private_excess_volume_bound obs dec hpriv D ε G hrec hexc
  have h2 : 1 - ε ≤ (∑ i ∈ range (D + 1), (Fintype.card α).choose i : ℝ) / 2 ^ Fintype.card α := by
    rw [le_div_iff₀ hpos]
    exact h
  linarith

end SurveillanceNetworks.MeasureConverse