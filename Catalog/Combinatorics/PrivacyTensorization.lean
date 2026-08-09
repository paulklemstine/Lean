/-
# Tensorization of the privacy threshold along a product of components

This file provides the structural skeleton asked for by open direction **3** of
`Catalog/Applications/SurveillanceNetworks/PrivacyThreshold.lean`
("Causal / sequential covering": for time-indexed histories the record is produced
online, so the single covering number should be replaced by a covering number along
the natural filtration).

The mathematical content that makes such a replacement possible is *additivity*:
when the configuration space factors as a product `∀ i, σ i` — for histories, one
factor per time step — and the distortion is the sum of the componentwise
distortions, the one-codeword covering radius, i.e. the optimal private worst-case
distortion, is the **sum of the componentwise covering radii**:

* `coveringRadius_prod` — `coveringRadius (∑ᵢ dᵢ) = ∑ᵢ coveringRadius dᵢ`.
  Neither inequality is formal: `≤` builds a product center out of componentwise
  centers, and `≥` extracts, from any product center, a componentwise worst case
  using minimality of each `coveringRadius dᵢ`.
* `privatelyAchievable_prod_iff` — operationally, a perfectly private observer of a
  product system meets the worst-case budget `D` iff `D ≥ ∑ᵢ coveringRadius dᵢ`:
  the private budget must be split across the components, and no cross-component
  trade is possible.
* `hamming_coveringRadius_via_tensorization` — an **independent re-derivation** of
  the parent file's `hamming_coveringRadius` (`= |α|`): binary Hamming distortion is
  the product of `|α|` copies of the two-point distortion, each of covering radius
  `1` (`bool_coveringRadius`).  Two structurally different proofs of the same
  constant is a consistency check on both.
* `privDist_prodDist` — the **average-case** tensorization: for an additive
  distortion the private rate–distortion function `D_priv` is the sum of the
  componentwise private rate–distortion functions of the *marginals*, with no
  independence assumption on the source (`avgDist_prodDist` is the underlying
  splitting of the expected distortion).  This subsumes the majority-vote formula
  of `Catalog/Combinatorics/PrivateAverageDistortion.lean`.
* `history_coveringRadius_timeslices` — the time-sliced form: for a `T`-step history
  of a network on `n` participants, viewed as `T` snapshots with additive
  per-snapshot distortion, the private worst-case distortion is `∑_{t<T} n²`, i.e.
  the per-step thresholds simply add along the filtration.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  A causal (online) private observer cannot beat the
sum of the per-step private distortions; the covering radius should tensorize
exactly, with no interaction term, because a single codeword in a product is a
tuple of codewords.

EXPERIMENT (Experimenter).  Formalized `coveringRadius` of `d c s = ∑ᵢ dᵢ (c i) (s i)`.
The `≥` direction is the interesting one: from a product center `c`, for each `i`
either `c i` already covers `σ i` at radius `coveringRadius dᵢ − 1`, contradicting
the definition of the infimum, or a witness `sᵢ` at distance `≥ coveringRadius dᵢ`
exists; assembling the witnesses coordinatewise gives a configuration at distance
`≥ ∑ᵢ coveringRadius dᵢ`.

ANALYSIS (Analyst).  Additivity is the exact reason a "sequential covering number"
is a meaningful replacement for the global one: along a filtration the threshold is
a sum of per-step thresholds, so a *per-step* privacy budget is without loss.  The
Hamming case is the degenerate instance where all factors are equal, which is why
the parent file's threshold is the ambient dimension.

CRITIQUE (Critic).  Each factor must be nonempty and finite, and this is necessary:
with an empty factor every distortion is vacuously covered and the sum formula would
fail to be attained.  The re-derivation of `hamming_coveringRadius` is deliberately
independent (it does not invoke the parent theorem), so it is a genuine
cross-validation and not a restatement.  No theorem here is `True`, `rfl`-only or
`decide`-only.
-/
import Applications.SurveillanceNetworks.PrivacyThreshold
import Combinatorics.PrivateAverageDistortion

open Finset SurveillanceNetworks.Privacy SurveillanceNetworks.AvgPrivacy

namespace SurveillanceNetworks.Tensorization

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {σ : ι → Type*}
  [∀ i, Fintype (σ i)] [∀ i, Nonempty (σ i)]

/-- The additive product distortion on `∀ i, σ i`. -/
def prodDist (d : ∀ i, σ i → σ i → ℕ) (c s : ∀ i, σ i) : ℕ := ∑ i, d i (c i) (s i)

/-- If a center misses the covering radius in some component, that component
supplies a witness at distance at least the componentwise covering radius. -/
theorem exists_far_of_coveringRadius {τ : Type*} [Fintype τ] [Nonempty τ]
    (d : τ → τ → ℕ) (c : τ) : ∃ s, coveringRadius d ≤ d c s := by
  by_contra h
  push_neg at h
  have hle : ∀ s, d c s ≤ coveringRadius d - 1 := by
    intro s
    have := h s
    omega
  have hmem : coveringRadius d ≤ coveringRadius d - 1 :=
    Nat.sInf_le ⟨c, hle⟩
  have hpos : 0 < coveringRadius d := by
    obtain ⟨s⟩ : Nonempty τ := inferInstance
    have := h s
    omega
  omega

/-- **Tensorization of the private worst-case distortion.**  For an additive
distortion on a product, the one-codeword covering radius is the sum of the
componentwise covering radii. -/
theorem coveringRadius_prod (d : ∀ i, σ i → σ i → ℕ) :
    coveringRadius (prodDist d) = ∑ i, coveringRadius (d i) := by
  apply le_antisymm
  · refine (coveringRadius_le_iff _ _).mpr ?_
    choose c hc using fun i => exists_center_coveringRadius (d i)
    exact ⟨c, fun s => Finset.sum_le_sum fun i _ => hc i (s i)⟩
  · obtain ⟨c, hc⟩ := exists_center_coveringRadius (prodDist d)
    choose s hs using fun i => exists_far_of_coveringRadius (d i) (c i)
    calc ∑ i, coveringRadius (d i) ≤ ∑ i, d i (c i) (s i) :=
          Finset.sum_le_sum fun i _ => hs i
      _ = prodDist d c s := rfl
      _ ≤ coveringRadius (prodDist d) := hc s

/-- **Operational form.**  A perfectly private observer of a product system meets
the worst-case distortion budget `D` iff `D` is at least the sum of the
componentwise private distortions. -/
theorem privatelyAchievable_prod_iff {M : Type*} [Nonempty M] (d : ∀ i, σ i → σ i → ℕ)
    (D : ℕ) :
    PrivatelyAchievable M (prodDist d) D ↔ ∑ i, coveringRadius (d i) ≤ D := by
  rw [privatelyAchievable_iff_exists_center, ← coveringRadius_le_iff, coveringRadius_prod]

/-! ## Recovering the binary Hamming threshold by tensorization -/

/-- The two-point distortion on a single bit. -/
def boolDist (a b : Bool) : ℕ := if a ≠ b then 1 else 0

/-- A single bit has private worst-case distortion `1`: no single bit covers both. -/
theorem bool_coveringRadius : coveringRadius boolDist = 1 := by
  apply le_antisymm
  · exact (coveringRadius_le_iff _ _).mpr ⟨true, fun s => by cases s <;> simp [boolDist]⟩
  · rcases Nat.eq_zero_or_pos (coveringRadius boolDist) with h | h
    · exfalso
      obtain ⟨c, hc⟩ := exists_center_coveringRadius boolDist
      rw [h] at hc
      have := hc (!c)
      cases c <;> simp [boolDist] at this
    · exact h

variable {α : Type*} [Fintype α] [DecidableEq α]

omit [DecidableEq α] in
/-- Binary Hamming distortion is the additive product of two-point distortions. -/
theorem hdist_eq_prodDist :
    (hdist : (α → Bool) → (α → Bool) → ℕ) = prodDist (fun _ : α => boolDist) := by
  funext x y
  unfold hdist prodDist boolDist
  rw [Finset.card_filter]

/-- **Independent re-derivation of the binary privacy threshold.**  Tensorizing
`|α|` copies of the one-bit threshold gives back
`coveringRadius hdist = |α|`. -/
theorem hamming_coveringRadius_via_tensorization :
    coveringRadius (hdist : (α → Bool) → (α → Bool) → ℕ) = Fintype.card α := by
  rw [hdist_eq_prodDist, coveringRadius_prod]
  simp [bool_coveringRadius, Finset.card_univ]

/-- **Time-sliced network histories.**  Viewing a `T`-step history as `T` snapshots
with additive per-snapshot Hamming distortion, the private worst-case distortion is
the sum of the per-step thresholds `n²` — the privacy budget adds along the
filtration. -/
theorem history_coveringRadius_timeslices (T n : ℕ) :
    coveringRadius (prodDist (fun _ : Fin T => (hdist : ((Fin n × Fin n) → Bool) →
      ((Fin n × Fin n) → Bool) → ℕ))) = ∑ _t : Fin T, n * n := by
  rw [coveringRadius_prod]
  refine Finset.sum_congr rfl fun t _ => ?_
  rw [hamming_coveringRadius_via_tensorization]
  simp [Fintype.card_prod]

/-! ## Average-case tensorization: the private optimum sees only the marginals -/

variable [∀ i, DecidableEq (σ i)]

/-- The `i`-th marginal of a source law on a product configuration space. -/
def marginal (p : (∀ i, σ i) → ℝ) (i : ι) (a : σ i) : ℝ :=
  ∑ s ∈ univ.filter fun s : ∀ i, σ i => s i = a, p s

omit [∀ i, Nonempty (σ i)] in
/-- The expected distortion of a single reconstruction on a product system splits
into componentwise expected distortions against the marginals. -/
theorem avgDist_prodDist (p : (∀ i, σ i) → ℝ) (d : ∀ i, σ i → σ i → ℕ) (c : ∀ i, σ i) :
    avgDist p (prodDist d) c = ∑ i, ∑ a : σ i, marginal p i a * (d i (c i) a : ℝ) := by
  classical
  unfold avgDist prodDist marginal
  have hrow : ∀ s : ∀ i, σ i, p s * ((∑ i, d i (c i) (s i) : ℕ) : ℝ)
      = ∑ i, p s * (d i (c i) (s i) : ℝ) := by
    intro s
    push_cast
    rw [Finset.mul_sum]
  rw [Finset.sum_congr rfl fun s _ => hrow s, Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_fiberwise (univ : Finset (∀ i, σ i)) (fun s => s i)
        (fun s => p s * (d i (c i) (s i) : ℝ))]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.sum_mul]
  refine Finset.sum_congr rfl fun s hs => ?_
  rw [(mem_filter.mp hs).2]

/-- **Average-case tensorization.**  For an additive distortion on a product
configuration space the private rate–distortion function is the sum of the
componentwise private rate–distortion functions of the *marginals* — with no
independence assumption on the source. -/
theorem privDist_prodDist (p : (∀ i, σ i) → ℝ) (d : ∀ i, σ i → σ i → ℕ) :
    privDist p (prodDist d)
      = ∑ i, (univ : Finset (σ i)).inf' univ_nonempty
          (fun b => ∑ a : σ i, marginal p i a * (d i b a : ℝ)) := by
  classical
  set f : ∀ i, σ i → ℝ := fun i b => ∑ a : σ i, marginal p i a * (d i b a : ℝ) with hf
  apply le_antisymm
  · choose b hb using fun i => Finset.exists_mem_eq_inf' (univ_nonempty (α := σ i)) (f i)
    calc privDist p (prodDist d) ≤ avgDist p (prodDist d) (fun i => b i) :=
          privDist_le _ _ _
      _ = ∑ i, f i (b i) := avgDist_prodDist p d _
      _ = ∑ i, (univ : Finset (σ i)).inf' univ_nonempty (f i) :=
          Finset.sum_congr rfl fun i _ => ((hb i).2).symm
  · obtain ⟨c, hc⟩ := exists_avgDist_eq_privDist p (prodDist d)
    rw [← hc, avgDist_prodDist]
    exact Finset.sum_le_sum fun i _ => Finset.inf'_le (f i) (mem_univ (c i))

end SurveillanceNetworks.Tensorization