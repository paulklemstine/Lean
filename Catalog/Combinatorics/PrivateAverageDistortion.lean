/-
# The private rate–distortion function under *average* distortion

This file settles open direction **2** of
`Catalog/Applications/SurveillanceNetworks/PrivacyThreshold.lean`
("Average- rather than worst-case distortion").

That file proves a *worst-case* threshold: a perfectly private channel
(deterministic or randomized) meets an almost-sure distortion budget `D` exactly
when a single ball of radius `D` covers the configuration space, so the optimal
private worst-case distortion is the one-codeword covering radius, which for
binary tensors indexed by `α` equals the full ambient dimension `|α|`
(`SurveillanceNetworks.Privacy.hamming_coveringRadius`).

Here the almost-sure requirement is replaced by an **expected** distortion
requirement against a source law `p`.  The results are:

* `avgPrivatelyAchievable_iff` — a perfectly private *deterministic* channel meets
  the expected-distortion budget `D` iff some single reconstruction `c` has
  `E_p[d(c, X)] ≤ D`.
* `randAvgPrivatelyAchievable_iff` — the same holds for perfectly private
  *randomized* channels: averaging over the record does not beat the best single
  reconstruction (a convexity/counting argument, not a support argument, so it is
  genuinely different from the worst-case proof).
* `isLeast_avgPrivatelyAchievable` — hence the **private rate–distortion function**
  `privDist p d = min_c E_p[d(c, X)]` is the least achievable private expected
  distortion.
* `privDist_le_coveringRadius` — the average-case optimum never exceeds the
  worst-case optimum.
* `privDist_hamming_eq_sum_minority` — **exact formula.**  For Hamming distortion
  the optimal private reconstruction is the coordinatewise *majority vote* and
  `privDist p hdist = ∑_i min(P[X_i ≠ false], P[X_i ≠ true])`, the total
  coordinatewise minority mass.
* `privDist_hamming_uniform` — for the uniform source this is exactly `|α| / 2`,
  strictly below the worst-case value `|α|` as soon as `α` is nonempty
  (`privDist_lt_coveringRadius_uniform`): averaging buys back exactly a factor of
  two, and no more.
* `history_private_avg_distortion` — for `T`-step histories of a directed network
  on `n` nodes the private expected Hamming distortion is exactly `T·n²/2`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Under expected distortion, perfect privacy should
still collapse the channel to a single reconstruction, but the price should drop
from the covering radius to a *median-type* statistic of the source.  Bold form:
the optimum is attained by a coordinatewise majority vote and equals the summed
minority mass, so the uniform source pays exactly half the ambient dimension.

EXPERIMENT (Experimenter).  Formalized deterministic and randomized private
channels with finite record alphabets.  The randomized converse is a sum swap
`∑_s p_s ∑_m q_m d(dec m, s) = ∑_m q_m E_p[d(dec m, X)]` followed by
`∑_m q_m ≥` the minimum, which needs `q ≥ 0` and `∑ q = 1` but *no* assumption on
`p` — recorded as `randAvgPrivatelyAchievable_iff`.  The Hamming optimum was
obtained by the coordinate decomposition
`E_p[hdist c X] = ∑_i mass p i (c i)` (`avgDist_hamming_eq_sum_mass`), after
which the minimization separates over coordinates.

ANALYSIS (Analyst).  The worst-case theory is governed by a *covering* number,
the average-case theory by a *separable minimization*; the only reason a closed
form exists in the Hamming case is that the distortion is additive over
coordinates while the reconstruction alphabet is a full product.  The uniform
factor `1/2` is the exact combinatorial content of `card_ne_at_coord`:
each coordinate splits the cube in half.

CRITIQUE (Critic).  Two corner cases were checked.  (i) `Fintype.card α = 0`: the
formula still holds, both sides being `0`, so `privDist_lt_coveringRadius_uniform`
carries the necessary `Nonempty α` hypothesis.  (ii) The randomized statement
would be vacuous without `∑_m q_m = 1`; it is included, and both directions of the
iff are proved, so the characterization is not one-sided.  No theorem is `True`,
`rfl`-only, or `decide`-only.
-/
import Applications.SurveillanceNetworks.PrivacyThreshold

open Finset SurveillanceNetworks.Privacy

namespace SurveillanceNetworks.AvgPrivacy

variable {S M : Type*} [Fintype S]

/-! ## Expected distortion of private channels -/

/-- The expected distortion of the *single* reconstruction `c` under the source
law `p`.  For a perfectly private channel this is the only quantity available. -/
def avgDist (p : S → ℝ) (d : S → S → ℕ) (c : S) : ℝ := ∑ s, p s * (d c s : ℝ)

/-- The expected distortion of the channel/decoder pair `(obs, dec)`. -/
def sysAvgDist (p : S → ℝ) (d : S → S → ℕ) (obs : S → M) (dec : M → S) : ℝ :=
  ∑ s, p s * (d (dec (obs s)) s : ℝ)

/-- The expected-distortion budget `D` is *privately achievable* if some perfectly
private deterministic channel and decoder have expected distortion at most `D`. -/
def AvgPrivatelyAchievable (M : Type*) (p : S → ℝ) (d : S → S → ℕ) (D : ℝ) : Prop :=
  ∃ (obs : S → M) (dec : M → S), PerfectPrivacy obs ∧ sysAvgDist p d obs dec ≤ D

/-- **Average-distortion privacy threshold, deterministic case.**  A perfectly
private channel meets the expected-distortion budget `D` iff a single
reconstruction does. -/
theorem avgPrivatelyAchievable_iff [Nonempty S] [Nonempty M]
    (p : S → ℝ) (d : S → S → ℕ) (D : ℝ) :
    AvgPrivatelyAchievable M p d D ↔ ∃ c : S, avgDist p d c ≤ D := by
  constructor
  · rintro ⟨obs, dec, hpriv, hD⟩
    obtain ⟨s₀⟩ : Nonempty S := inferInstance
    refine ⟨dec (obs s₀), le_of_eq_of_le ?_ hD⟩
    unfold avgDist sysAvgDist
    exact Finset.sum_congr rfl fun s _ => by rw [hpriv s₀ s]
  · rintro ⟨c, hc⟩
    obtain ⟨m₀⟩ : Nonempty M := inferInstance
    exact ⟨fun _ => m₀, fun _ => c, fun _ _ => rfl, hc⟩

/-- The expected-distortion budget `D` is achievable by a perfectly private
*randomized* channel `ch` (a law on records that does not depend on the
configuration) together with a decoder. -/
def RandAvgPrivatelyAchievable (M : Type*) [Fintype M] (p : S → ℝ) (d : S → S → ℕ)
    (D : ℝ) : Prop :=
  ∃ (ch : S → M → ℝ) (dec : M → S),
    (∀ s m, 0 ≤ ch s m) ∧ (∀ s, ∑ m, ch s m = 1) ∧ (∀ s t, ch s = ch t) ∧
      ∑ s, p s * ∑ m, ch s m * (d (dec m) s : ℝ) ≤ D

/-- **Randomization does not help on average either.**  A perfectly private
randomized channel meets the expected-distortion budget `D` iff a single
reconstruction does.  (The proof is a convexity argument: the system distortion is
a convex combination of the single-reconstruction distortions `avgDist p d (dec m)`,
hence at least the smallest of them.) -/
theorem randAvgPrivatelyAchievable_iff [Nonempty S] [Fintype M] [Nonempty M] [DecidableEq M]
    (p : S → ℝ) (d : S → S → ℕ) (D : ℝ) :
    RandAvgPrivatelyAchievable M p d D ↔ ∃ c : S, avgDist p d c ≤ D := by
  constructor
  · rintro ⟨ch, dec, hnonneg, hsum, hpriv, hD⟩
    obtain ⟨s₀⟩ : Nonempty S := inferInstance
    -- the best single reconstruction among the decoder outputs
    obtain ⟨mStar, -, hmin⟩ :=
      Finset.exists_min_image (univ : Finset M) (fun m => avgDist p d (dec m)) univ_nonempty
    refine ⟨dec mStar, le_trans ?_ hD⟩
    -- swap the two sums: the system distortion is a convex combination
    have hswap : ∑ s, p s * ∑ m, ch s m * (d (dec m) s : ℝ)
        = ∑ m, ch s₀ m * avgDist p d (dec m) := by
      unfold avgDist
      have hrow : ∀ s : S, p s * ∑ m, ch s m * (d (dec m) s : ℝ)
          = ∑ m, ch s₀ m * (p s * (d (dec m) s : ℝ)) := by
        intro s
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun m _ => by rw [hpriv s₀ s]; ring
      rw [Finset.sum_congr rfl fun s _ => hrow s, Finset.sum_comm]
      exact Finset.sum_congr rfl fun m _ => (Finset.mul_sum _ _ _).symm
    rw [hswap]
    have hterm : ∀ m ∈ (univ : Finset M),
        ch s₀ m * avgDist p d (dec mStar) ≤ ch s₀ m * avgDist p d (dec m) := fun m _ =>
      mul_le_mul_of_nonneg_left (hmin m (mem_univ m)) (hnonneg s₀ m)
    calc avgDist p d (dec mStar)
        = (∑ m, ch s₀ m) * avgDist p d (dec mStar) := by rw [hsum s₀, one_mul]
      _ = ∑ m, ch s₀ m * avgDist p d (dec mStar) := by rw [Finset.sum_mul]
      _ ≤ ∑ m, ch s₀ m * avgDist p d (dec m) := Finset.sum_le_sum hterm
  · rintro ⟨c, hc⟩
    obtain ⟨m₀⟩ : Nonempty M := inferInstance
    refine ⟨fun _ m => if m = m₀ then 1 else 0, fun _ => c, ?_, ?_, fun _ _ => rfl, ?_⟩
    · intro s m; positivity
    · intro s; simp
    · simpa [avgDist] using hc

/-- The two private notions of expected achievability coincide. -/
theorem randAvg_iff_avg [Nonempty S] [Fintype M] [Nonempty M] [DecidableEq M]
    (p : S → ℝ) (d : S → S → ℕ) (D : ℝ) :
    RandAvgPrivatelyAchievable M p d D ↔ AvgPrivatelyAchievable M p d D :=
  (randAvgPrivatelyAchievable_iff p d D).trans (avgPrivatelyAchievable_iff p d D).symm

/-! ## The private rate–distortion function -/

/-- The **private rate–distortion function**: the least expected distortion of a
single reconstruction, `D_priv(p) = min_c E_p[d(c, X)]`. -/
noncomputable def privDist [Nonempty S] (p : S → ℝ) (d : S → S → ℕ) : ℝ :=
  (univ : Finset S).inf' univ_nonempty (avgDist p d)

theorem privDist_le [Nonempty S] (p : S → ℝ) (d : S → S → ℕ) (c : S) :
    privDist p d ≤ avgDist p d c :=
  Finset.inf'_le _ (mem_univ c)

theorem exists_avgDist_eq_privDist [Nonempty S] (p : S → ℝ) (d : S → S → ℕ) :
    ∃ c : S, avgDist p d c = privDist p d := by
  obtain ⟨c, -, hc⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S)) (avgDist p d)
  exact ⟨c, hc.symm⟩

/-- **The private rate–distortion function is the least achievable private expected
distortion.** -/
theorem isLeast_avgPrivatelyAchievable [Nonempty S] [Nonempty M]
    (p : S → ℝ) (d : S → S → ℕ) :
    IsLeast {D | AvgPrivatelyAchievable M p d D} (privDist p d) := by
  obtain ⟨cStar, hcStar⟩ := exists_avgDist_eq_privDist p d
  constructor
  · exact (avgPrivatelyAchievable_iff p d _).mpr ⟨cStar, le_of_eq hcStar⟩
  · rintro D hD
    obtain ⟨c, hc⟩ := (avgPrivatelyAchievable_iff p d D).mp hD
    exact le_trans (privDist_le p d c) hc

/-- **Averaging never costs more than the worst case.**  For a probability law `p`
the private expected distortion is at most the private worst-case distortion,
i.e. the one-codeword covering radius. -/
theorem privDist_le_coveringRadius [Nonempty S] (p : S → ℝ) (d : S → S → ℕ)
    (hp : ∀ s, 0 ≤ p s) (hp1 : ∑ s, p s = 1) :
    privDist p d ≤ (coveringRadius d : ℝ) := by
  obtain ⟨c, hc⟩ := exists_center_coveringRadius d
  refine le_trans (privDist_le p d c) ?_
  calc avgDist p d c ≤ ∑ s, p s * (coveringRadius d : ℝ) :=
        Finset.sum_le_sum fun s _ =>
          mul_le_mul_of_nonneg_left (by exact_mod_cast hc s) (hp s)
    _ = (coveringRadius d : ℝ) := by rw [← Finset.sum_mul, hp1, one_mul]

/-! ## Exact solution for Hamming distortion: majority vote -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The mass of the source that disagrees with the bit `b` in coordinate `i`. -/
def mass (p : (α → Bool) → ℝ) (i : α) (b : Bool) : ℝ :=
  ∑ x ∈ univ.filter fun x : α → Bool => x i ≠ b, p x

/-- **Coordinate decomposition of the expected Hamming distortion.**  The expected
distortion of the reconstruction `c` is the sum over coordinates of the mass
disagreeing with `c` there. -/
theorem avgDist_hamming_eq_sum_mass (p : (α → Bool) → ℝ) (c : α → Bool) :
    avgDist p hdist c = ∑ i : α, mass p i (c i) := by
  classical
  unfold avgDist mass hdist
  have hpt : ∀ x : α → Bool,
      p x * ((univ.filter fun i => c i ≠ x i).card : ℝ)
        = ∑ i : α, if x i ≠ c i then p x else 0 := by
    intro x
    rw [Finset.card_filter]
    push_cast
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by
      by_cases h : c i = x i <;> simp [h, Ne.symm]
  rw [Finset.sum_congr rfl fun x _ => hpt x, Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => (Finset.sum_filter _ _).symm

/-- The coordinatewise **majority-vote** reconstruction: in each coordinate pick the
bit carrying the larger source mass. -/
noncomputable def majority (p : (α → Bool) → ℝ) : α → Bool :=
  fun i => if mass p i false ≤ mass p i true then false else true

theorem mass_majority_eq_min (p : (α → Bool) → ℝ) (i : α) :
    mass p i (majority p i) = min (mass p i false) (mass p i true) := by
  unfold majority
  by_cases h : mass p i false ≤ mass p i true
  · simp [h]
  · simp [h, min_eq_right (le_of_not_ge h)]

/-- **Exact private rate–distortion function for Hamming distortion.**  The optimal
private reconstruction is the coordinatewise majority vote and the optimal private
expected distortion is the total coordinatewise minority mass. -/
theorem privDist_hamming_eq_sum_minority (p : (α → Bool) → ℝ) :
    privDist p hdist = ∑ i : α, min (mass p i false) (mass p i true) := by
  apply le_antisymm
  · calc privDist p hdist ≤ avgDist p hdist (majority p) := privDist_le _ _ _
      _ = ∑ i : α, mass p i (majority p i) := avgDist_hamming_eq_sum_mass p _
      _ = ∑ i : α, min (mass p i false) (mass p i true) :=
          Finset.sum_congr rfl fun i _ => mass_majority_eq_min p i
  · obtain ⟨c, hc⟩ := exists_avgDist_eq_privDist p (hdist (α := α))
    rw [← hc, avgDist_hamming_eq_sum_mass]
    refine Finset.sum_le_sum fun i _ => ?_
    cases h : c i
    · exact min_le_left _ _
    · exact min_le_right _ _

/-- **The majority vote is an optimal private reconstruction.** -/
theorem avgDist_majority_eq_privDist (p : (α → Bool) → ℝ) :
    avgDist p hdist (majority p) = privDist p hdist := by
  rw [privDist_hamming_eq_sum_minority, avgDist_hamming_eq_sum_mass]
  exact Finset.sum_congr rfl fun i _ => mass_majority_eq_min p i

/-! ## The uniform source: exactly half the ambient dimension -/

/-- Exactly half of the binary tensors disagree with a fixed bit in a fixed
coordinate. -/
theorem card_ne_at_coord (i : α) (b : Bool) :
    (univ.filter fun x : α → Bool => x i ≠ b).card * 2 = 2 ^ Fintype.card α := by
  classical
  have key : (univ.filter fun x : α → Bool => x i = b).card
      = (univ.filter fun x : α → Bool => ¬ (x i = b)).card := by
    apply Finset.card_bij (fun x _ => Function.update x i (!b))
    · intro x _; simp
    · intro x hx y hy h
      simp only [mem_filter, mem_univ, true_and] at hx hy
      funext j
      by_cases hj : j = i
      · subst hj; rw [hx, hy]
      · have := congrFun h j
        simpa [Function.update_of_ne hj] using this
    · intro y hy
      simp only [mem_filter, mem_univ, true_and] at hy
      refine ⟨Function.update y i b, by simp, ?_⟩
      funext j
      by_cases hj : j = i
      · subst hj
        simp only [Function.update_self]
        revert hy; cases b <;> cases hyi : y j <;> simp
      · simp [Function.update_of_ne hj]
  have hsum := Finset.card_filter_add_card_filter_not (s := (univ : Finset (α → Bool)))
      (p := fun x : α → Bool => x i = b)
  rw [← key, Finset.card_univ] at hsum
  have h2 : Fintype.card (α → Bool) = 2 ^ Fintype.card α := by simp
  simp only [ne_eq]
  omega

/-- The uniform law on binary tensors. -/
noncomputable def unif (α : Type*) [Fintype α] : (α → Bool) → ℝ :=
  fun _ => (1 : ℝ) / 2 ^ Fintype.card α

omit [DecidableEq α] in
theorem unif_nonneg (x : α → Bool) : 0 ≤ unif α x := by
  unfold unif; positivity

theorem sum_unif : ∑ x : α → Bool, unif α x = 1 := by
  unfold unif
  rw [Finset.sum_const, Finset.card_univ]
  have h : ((Fintype.card (α → Bool) : ℝ)) = 2 ^ Fintype.card α := by simp
  rw [nsmul_eq_mul, h]
  field_simp

/-- Every coordinate of the uniform source is an unbiased coin: each bit carries
mass `1/2`. -/
theorem mass_unif (i : α) (b : Bool) : mass (unif α) i b = 1 / 2 := by
  unfold mass unif
  rw [Finset.sum_const, nsmul_eq_mul]
  have h := card_ne_at_coord i b
  have hpos : (0 : ℝ) < 2 ^ Fintype.card α := by positivity
  have hcast : ((univ.filter fun x : α → Bool => x i ≠ b).card : ℝ) * 2
      = 2 ^ Fintype.card α := by exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) h
  field_simp
  linarith [hcast]

/-- **The uniform private rate–distortion value is exactly half the ambient
dimension.**  Compare the worst-case value `|α|` of `hamming_coveringRadius`:
allowing average- instead of worst-case distortion buys exactly a factor of two. -/
theorem privDist_hamming_uniform :
    privDist (unif α) hdist = (Fintype.card α : ℝ) / 2 := by
  rw [privDist_hamming_eq_sum_minority]
  simp only [mass_unif, min_self]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  ring

/-- **Strict separation between the worst-case and the average-case private
optimum** for any nonempty coordinate set. -/
theorem privDist_lt_coveringRadius_uniform [Nonempty α] :
    privDist (unif α) hdist < (coveringRadius (hdist : (α → Bool) → (α → Bool) → ℕ) : ℝ) := by
  rw [privDist_hamming_uniform, hamming_coveringRadius]
  have : 0 < Fintype.card α := Fintype.card_pos
  have : (0 : ℝ) < Fintype.card α := by exact_mod_cast this
  linarith

/-- **Operational form.**  Against a uniform source, a perfectly private observer
(deterministic or randomized) meets the expected Hamming distortion budget `D`
precisely when `D ≥ |α|/2`. -/
theorem avgPrivatelyAchievable_unif_iff [Nonempty M] (D : ℝ) :
    AvgPrivatelyAchievable M (unif α) hdist D ↔ (Fintype.card α : ℝ) / 2 ≤ D := by
  constructor
  · intro hD
    have := (isLeast_avgPrivatelyAchievable (M := M) (unif α) (hdist (α := α))).2 hD
    rwa [privDist_hamming_uniform] at this
  · intro hD
    have h := (isLeast_avgPrivatelyAchievable (M := M) (unif α) (hdist (α := α))).1
    obtain ⟨obs, dec, hpriv, hle⟩ := h
    refine ⟨obs, dec, hpriv, le_trans hle ?_⟩
    rwa [privDist_hamming_uniform]

/-- **Network histories.**  A perfectly private observer of a `T`-step history of a
directed network on `n` participants suffers expected Hamming distortion exactly
`T·n²/2` against the uniform source — half of the worst-case value `T·n²` of
`history_private_distortion`. -/
theorem history_private_avg_distortion (T n : ℕ) :
    privDist (unif (Fin T × Fin n × Fin n))
      (hdist : ((Fin T × Fin n × Fin n) → Bool) → ((Fin T × Fin n × Fin n) → Bool) → ℕ)
      = (T * n * n : ℝ) / 2 := by
  rw [privDist_hamming_uniform]
  congr 1
  simp [Fintype.card_prod]
  ring

end SurveillanceNetworks.AvgPrivacy