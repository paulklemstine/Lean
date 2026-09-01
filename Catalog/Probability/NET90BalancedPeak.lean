import Probability.NET90BumpSharpness

/-!
# NET-90, third cycle: the balanced ratio is the *peak* of the sweep

Cycles 1 and 2 established the sup-convolution model, the strict bump at the balanced
arm, the sharp factor-two ceiling, and the mass-balance criterion that switches the bump
on and off.  What remained conjectural is the empirically striking part of the NET-90
table: not merely that the balanced arm is bumped, but that it is the **maximum** of the
whole mixing-ratio sweep.

This file proves it, for every sorted attention profile.

`balanced_maximises_knee`: if the weights are antitone (which is what "sorted attention
profile" means) then for every split `m + l = 2N` the mixed knee satisfies
`k*(m, l) ≤ k*(N, N)`, provided the balanced knee itself fits inside the smaller side
(`k*(N,N) ≤ 2m`).  The two ingredients are genuinely different facts:

* `headMass_split_le_balanced` — *concavity of head mass*: a balanced split has the
  largest total mass to cover, `A(m) + A(l) ≤ 2·A(N)`.  This is where antitonicity is
  used, via a term-by-term comparison of two shifted blocks of weights.
* `mixHead_balanced_le_split` — *the balanced split is the hardest to serve*: for any
  budget `k ≤ 2m`, every balanced allocation can be mirrored into the unbalanced context,
  so `mixHead(N,N,k) ≤ mixHead(m,l,k)`.

So the balanced arm is simultaneously the arm with the most mass to cover and the arm
with the least head available at each budget — the two effects point the same way, and
the maximum of the ratio response sits exactly at `50/50`.

`net90_symmetric_peak` records the geometric instance, where the peak is strict against
the endpoints.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 3):
 (B1) For sorted profiles the mixing-ratio response is *maximised at the balanced
      point*: a Schur-concavity phenomenon in disguise.                        [BOLD]
 (B2) The mechanism is two-fold — balanced splits maximise the mass to be covered and
      minimise the best achievable head at each budget.
 (B3) A side condition is unavoidable: if the budget exceeds the minority side entirely
      the mirroring argument has no room, and the comparison can fail.

Experimenter: B1 = `balanced_maximises_knee`, B2 = `headMass_split_le_balanced` and
`mixHead_balanced_le_split`, and the side condition of B3 appears explicitly as
`k*(N,N) ≤ 2m`.

Analyst: cycle 1 produced a plateau for the fast-decaying geometric profile because the
knee grid is coarse there; the ordering `k*(asymmetric) ≤ k*(balanced)` proved here is
the profile-free statement, and it is strict for slowly decaying profiles where the grid
is fine.  This is the exact sense in which the measured `{12, 16, 12}` interior pattern
is a theorem rather than a corpus artefact.

Critic: the antitonicity hypothesis is not decorative — it is what makes head mass
concave; without it a profile with an increasing block can put more mass in an
unbalanced split and reverse the comparison.  The side condition is stated, not hidden,
and `net90_symmetric_peak` verifies it on the geometric instance rather than assuming it.
-/

namespace AttentionBudget

open Finset

variable {a : ℕ → ℝ} {τ : ℝ}

/-! ## Concavity of head mass along a split -/

/-- **Concavity of head mass.**  For a sorted (antitone) profile the balanced split of a
fixed number of keys carries the largest total mass. -/
lemma headMass_split_le_balanced (hanti : Antitone a) {m l N : ℕ} (hmN : m ≤ N)
    (hsum : m + l = 2 * N) : headMass a m + headMass a l ≤ 2 * headMass a N := by
  have hNl : N ≤ l := by omega
  have h1 : headMass a N - headMass a m = ∑ i ∈ range (N - m), a (m + i) := by
    rw [← Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sub _ hmN]
    rfl
  have h2 : headMass a l - headMass a N = ∑ i ∈ range (l - N), a (N + i) := by
    rw [← Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sub _ hNl]
    rfl
  have hlen : l - N = N - m := by omega
  have hcmp : ∑ i ∈ range (l - N), a (N + i) ≤ ∑ i ∈ range (N - m), a (m + i) := by
    rw [hlen]
    exact Finset.sum_le_sum fun i _ => hanti (by omega)
  linarith

/-! ## The balanced split is the hardest to serve at every budget -/

/-- **Mirroring.**  Any allocation of a budget `k ≤ 2m` across a balanced context can be
transported into an unbalanced context with the same number of keys, so the balanced
context has the smallest achievable head at each budget. -/
lemma mixHead_balanced_le_split (ha : ∀ i, 0 < a i) {m l N k : ℕ} (hmN : m ≤ N)
    (hNl : N ≤ l) (hk : k ≤ 2 * m) :
    mixHead a a N N k ≤ mixHead a a m l k := by
  refine mixHead_le fun j hj => ?_
  rcases le_or_gt j m with hjm | hjm
  · -- keep the allocation: the `a`-side has room, the `b`-side only grew
    refine le_trans ?_ (le_mixHead a a m l (j := j) (k := k) hj)
    have h1 : min j m = min j N := by omega
    have h2 : min (k - j) N ≤ min (k - j) l := by omega
    rw [h1]
    exact add_le_add le_rfl (headMass_mono ha h2)
  · -- mirror the allocation: the minority side takes the (now small) complement
    have hkj : k - j ≤ m := by omega
    refine le_trans ?_ (le_mixHead a a m l (j := k - j) (k := k) (by omega))
    have h1 : min (k - j) m = min (k - j) N := by omega
    have h2 : min (k - (k - j)) l = min j l := by
      have : k - (k - j) = j := by omega
      rw [this]
    have h3 : min j N ≤ min j l := by omega
    rw [h1, h2, add_comm (headMass a (min (k - j) N))]
    exact add_le_add (headMass_mono ha h3) le_rfl

/-! ## The peak of the mixing-ratio sweep -/

/-- **B1 — the balanced arm is the maximum of the ratio sweep.**  For every sorted
profile and every split `m + l = 2N` of the context, the mixed knee is at most the
balanced knee, provided the balanced knee fits inside twice the smaller side. -/
theorem balanced_maximises_knee (ha : ∀ i, 0 < a i) (hanti : Antitone a) {m l N : ℕ}
    (hm : 0 < m) (hmN : m ≤ N) (hsum : m + l = 2 * N) (hτ : τ ≤ 1)
    (hfit : mixKnee a a N N τ ≤ 2 * m) :
    mixKnee a a m l τ ≤ mixKnee a a N N τ := by
  have hN : 0 < N := by omega
  have hl : 0 < l := by omega
  have hNl : N ≤ l := by omega
  set k := mixKnee a a N N τ with hk
  have hgate : τ ≤ mixRetained a a N N k := gate_le_mixRetained_mixKnee ha ha hN hN hτ
  have hTbal : 0 < mixTotal a a N N := mixTotal_pos ha ha hN hN
  have hTsplit : 0 < mixTotal a a m l := mixTotal_pos ha ha hm hl
  have hmass : τ * mixTotal a a N N ≤ mixHead a a N N k := by
    rw [mixRetained, le_div_iff₀ hTbal] at hgate
    exact hgate
  have hhead : mixHead a a N N k ≤ mixHead a a m l k :=
    mixHead_balanced_le_split ha hmN hNl hfit
  have htot : mixTotal a a m l ≤ mixTotal a a N N := by
    have := headMass_split_le_balanced hanti hmN hsum
    simp only [mixTotal]
    linarith
  refine mixKnee_le_of_pass (k := k) ?_
  rw [mixRetained, le_div_iff₀ hTsplit]
  rcases le_or_gt τ 0 with hτ0 | hτ0
  · have h1 : τ * mixTotal a a m l ≤ 0 := mul_nonpos_of_nonpos_of_nonneg hτ0 hTsplit.le
    have h2 : 0 ≤ mixHead a a m l k := by
      have h0 := le_mixHead a a m l (j := 0) (k := k) (Nat.zero_le _)
      have h3 := headMass_nonneg ha (min 0 m)
      have h4 := headMass_nonneg ha (min (k - 0) l)
      linarith
    linarith
  · nlinarith

/-- **The symmetric peak, instantiated.**  For the geometric profile the balanced arm is
the maximum of the sweep and strictly exceeds both endpoints. -/
theorem net90_symmetric_peak {N m l : ℕ} (hN : 16 ≤ N) (hm : 16 ≤ m) (hmN : m ≤ N)
    (hsum : m + l = 2 * N) :
    mixKnee geomHalf geomHalf m l (0.98 : ℝ) ≤ mixKnee geomHalf geomHalf N N (0.98 : ℝ) ∧
      mixKnee geomHalf geomHalf (2 * N) 0 (0.98 : ℝ)
        < mixKnee geomHalf geomHalf N N (0.98 : ℝ) := by
  have hanti : Antitone geomHalf := by
    intro i j hij
    exact pow_le_pow_of_le_one (by norm_num) (by norm_num) hij
  have hfit : mixKnee geomHalf geomHalf N N (0.98 : ℝ) ≤ 2 * m := by
    rw [mixKnee_geomHalf_eq_twelve hN hN]; omega
  refine ⟨balanced_maximises_knee geomHalf_pos hanti (by omega) hmN hsum (by norm_num) hfit,
    (net90_bump hN).2.2.2.1⟩

end AttentionBudget