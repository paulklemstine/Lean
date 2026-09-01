import Probability.NET90BalancedPeak

/-!
# NET-90, fourth cycle: the whole ratio sweep is ordered by imbalance

Cycle 3 (`Probability.NET90BalancedPeak`) proved that the balanced arm is the *maximum*
of the mixing-ratio sweep: every split `m + l = 2N` satisfies `k*(m,l) ≤ k*(N,N)`.  That
is a single comparison — against the centre of the sweep — and it leaves open whether the
response between the endpoint and the centre is ordered at all, or whether it can wander
up and down (interior local minima).  This file closes that gap for self-mixtures of a
sorted profile: the mixed knee is **monotone in the imbalance**, i.e. Schur-concave in
the key-count vector.

`mixKnee_majorise`: if `m ≤ m' ≤ l' ≤ l` with `m + l = m' + l'` — so `(m, l)` is the more
unbalanced of the two splits, i.e. it majorises `(m', l')` — then

  `k*(m, l) ≤ k*(m', l')`,

provided the more balanced knee fits inside twice the smaller side (`k*(m',l') ≤ 2m`),
the same side condition that already appears in cycle 3.

The two ingredients are the transposition ("Robin Hood") versions of the cycle-3 lemmas:

* `headMass_majorise` — moving keys from the majority side to the minority side can only
  *increase* the total mass to be covered, because for an antitone profile the block of
  weights gained at the low end dominates the block lost at the high end;
* `mixHead_majorise` — and it can only *decrease* the best head available at each budget
  `k ≤ 2m`, because every allocation in the more balanced context can be mirrored into
  the more unbalanced one.

Both effects again point the same way, so the knee moves monotonically towards the peak.
`balanced_maximises_knee` is recovered as the special case `m' = l' = N`
(`balanced_maximises_knee_of_majorise`), and `geomHalf_sweep_monotone` records the
ordered sweep on the geometric profile of cycle 2.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 4, refining direction 1 of `FUTURE_DIRECTIONS.md`):
 (S1) The mixed knee is monotone along any majorisation chain, not merely dominated by
      the balanced value: the sweep has no interior local minima.              [BOLD]
 (S2) The mechanism is a single transposition step: the mirroring argument of cycle 3 is
      really a Robin Hood move, so it iterates.
 (S3) The side condition cannot be dropped, only relocated: it is needed at the *more
      balanced* endpoint of each transposition, where the mirroring has to fit.

Experimenter: S1 = `mixKnee_majorise` together with `mixKnee_sweep_monotone`; S2 =
`headMass_majorise` and `mixHead_majorise`, both stated for an arbitrary transposition;
S3 appears explicitly as the hypothesis `hfit`.  Zero sorries.

Analyst: cycle 3's proof used only that `(N, N)` is balanced through two facts — most
mass, least head — and both survive verbatim for an arbitrary pair of nested splits.  So
the "peak" statement was never about the centre; it was about the majorisation order, and
the centre is simply its top element.

Critic: the hypothesis `m ≤ m' ≤ l' ≤ l` is exactly majorisation for pairs with a common
sum, so nothing is smuggled in; the conclusion is not vacuous because
`geomHalf_sweep_monotone` exhibits a sweep where every hypothesis is verified rather than
assumed.  The result is non-strict, and deliberately so: on the geometric profile the
knee grid is coarse and the sweep is flat over the interior, so any strict claim would be
false there.
-/

namespace AttentionBudget

open Finset

variable {a : ℕ → ℝ} {τ : ℝ}

/-! ## A Robin Hood step increases the mass to be covered -/

/-- **Transposition concavity of head mass.**  For a sorted (antitone) profile, making a
split of a fixed number of keys *more balanced* increases the total mass: if
`m ≤ m' ≤ l' ≤ l` with `m + l = m' + l'` then `A(m) + A(l) ≤ A(m') + A(l')`. -/
lemma headMass_majorise (hanti : Antitone a) {m m' l' l : ℕ} (hmm : m ≤ m')
    (hm'l' : m' ≤ l') (hl'l : l' ≤ l) (hsum : m + l = m' + l') :
    headMass a m + headMass a l ≤ headMass a m' + headMass a l' := by
  have h1 : headMass a m' - headMass a m = ∑ i ∈ range (m' - m), a (m + i) := by
    rw [← Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sub _ hmm]
    rfl
  have h2 : headMass a l - headMass a l' = ∑ i ∈ range (l - l'), a (l' + i) := by
    rw [← Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sub _ hl'l]
    rfl
  have hlen : l - l' = m' - m := by omega
  have hcmp : ∑ i ∈ range (l - l'), a (l' + i) ≤ ∑ i ∈ range (m' - m), a (m + i) := by
    rw [hlen]
    exact Finset.sum_le_sum fun i _ => hanti (by omega)
  linarith

/-! ## A Robin Hood step lowers the achievable head at every budget -/

/-- **Transposition mirroring.**  Any allocation of a budget `k ≤ 2m` across the more
balanced context `(m', l')` can be transported into the more unbalanced context `(m, l)`,
so making a split more balanced lowers the best head available at each budget. -/
lemma mixHead_majorise (ha : ∀ i, 0 < a i) {m m' l' l k : ℕ} (hmm : m ≤ m')
    (hm'l' : m' ≤ l') (hl'l : l' ≤ l) (hk : k ≤ 2 * m) :
    mixHead a a m' l' k ≤ mixHead a a m l k := by
  refine mixHead_le fun j hj => ?_
  rcases le_or_gt j m with hjm | hjm
  · -- keep the allocation: the minority side has room, the majority side only grew
    refine le_trans ?_ (le_mixHead a a m l (j := j) (k := k) hj)
    have h1 : min j m' = min j m := by omega
    have h2 : min (k - j) l' ≤ min (k - j) l := by omega
    rw [h1]
    exact add_le_add le_rfl (headMass_mono ha h2)
  · -- mirror the allocation: the small side takes the (now small) complement
    refine le_trans ?_ (le_mixHead a a m l (j := k - j) (k := k) (by omega))
    have e1 : min (k - j) m = min (k - j) l' := by omega
    have e2 : min (k - (k - j)) l = min j l := by
      have hkj : k - (k - j) = j := by omega
      rw [hkj]
    have e3 : min j m' ≤ min j l := by omega
    rw [e1, e2, add_comm (headMass a (min (k - j) l'))]
    exact add_le_add (headMass_mono ha e3) le_rfl

/-! ## Monotonicity of the knee in the imbalance -/

/-- **S1 — the mixing-ratio response is Schur-concave.**  For a sorted profile, a more
unbalanced split never needs more keys than a more balanced one with the same number of
keys, provided the balanced knee fits inside twice the smaller side. -/
theorem mixKnee_majorise (ha : ∀ i, 0 < a i) (hanti : Antitone a) {m m' l' l : ℕ}
    (hm : 0 < m) (hmm : m ≤ m') (hm'l' : m' ≤ l') (hl'l : l' ≤ l) (hsum : m + l = m' + l')
    (hτ : τ ≤ 1) (hfit : mixKnee a a m' l' τ ≤ 2 * m) :
    mixKnee a a m l τ ≤ mixKnee a a m' l' τ := by
  have hm' : 0 < m' := by omega
  have hl' : 0 < l' := by omega
  have hl : 0 < l := by omega
  set k := mixKnee a a m' l' τ with hk
  have hgate : τ ≤ mixRetained a a m' l' k := gate_le_mixRetained_mixKnee ha ha hm' hl' hτ
  have hTbal : 0 < mixTotal a a m' l' := mixTotal_pos ha ha hm' hl'
  have hTsplit : 0 < mixTotal a a m l := mixTotal_pos ha ha hm hl
  have hmass : τ * mixTotal a a m' l' ≤ mixHead a a m' l' k := by
    rw [mixRetained, le_div_iff₀ hTbal] at hgate
    exact hgate
  have hhead : mixHead a a m' l' k ≤ mixHead a a m l k :=
    mixHead_majorise ha hmm hm'l' hl'l hfit
  have htot : mixTotal a a m l ≤ mixTotal a a m' l' := by
    have := headMass_majorise hanti hmm hm'l' hl'l hsum
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

/-- Cycle 3's peak theorem is the special case of a transposition to the centre. -/
theorem balanced_maximises_knee_of_majorise (ha : ∀ i, 0 < a i) (hanti : Antitone a)
    {m l N : ℕ} (hm : 0 < m) (hmN : m ≤ N) (hsum : m + l = 2 * N) (hτ : τ ≤ 1)
    (hfit : mixKnee a a N N τ ≤ 2 * m) :
    mixKnee a a m l τ ≤ mixKnee a a N N τ :=
  mixKnee_majorise ha hanti hm hmN le_rfl (by omega) (by omega) hτ hfit

/-- **The sweep is ordered.**  At fixed context length `2N`, walking the mixing ratio from
an endpoint towards the centre never decreases the knee: for `0 < m ≤ m' ≤ N` the three
arms `(m, 2N-m)`, `(m', 2N-m')` and `(N, N)` are ordered. -/
theorem mixKnee_sweep_monotone (ha : ∀ i, 0 < a i) (hanti : Antitone a) {m m' N : ℕ}
    (hm : 0 < m) (hmm : m ≤ m') (hm'N : m' ≤ N) (hτ : τ ≤ 1)
    (hfit : mixKnee a a m' (2 * N - m') τ ≤ 2 * m)
    (hfit' : mixKnee a a N N τ ≤ 2 * m') :
    mixKnee a a m (2 * N - m) τ ≤ mixKnee a a m' (2 * N - m') τ ∧
      mixKnee a a m' (2 * N - m') τ ≤ mixKnee a a N N τ := by
  refine ⟨mixKnee_majorise ha hanti hm hmm (by omega) (by omega) (by omega) hτ hfit,
    mixKnee_majorise ha hanti (by omega) hm'N le_rfl (by omega) (by omega) hτ hfit'⟩

/-! ## The ordered sweep on the geometric profile -/

lemma geomHalf_antitone : Antitone geomHalf := by
  intro i j hij
  exact pow_le_pow_of_le_one (by norm_num) (by norm_num) hij

/-- **The geometric sweep, ordered.**  Every interior arm of the `(1/2)^i` sweep at
context `2N` is dominated by the balanced arm, and the ordering holds along the sweep. -/
theorem geomHalf_sweep_monotone {N m m' : ℕ} (hm : 16 ≤ m) (hmm : m ≤ m') (hm'N : m' ≤ N) :
    mixKnee geomHalf geomHalf m (2 * N - m) (0.98 : ℝ)
        ≤ mixKnee geomHalf geomHalf m' (2 * N - m') (0.98 : ℝ) ∧
      mixKnee geomHalf geomHalf m' (2 * N - m') (0.98 : ℝ)
        ≤ mixKnee geomHalf geomHalf N N (0.98 : ℝ) := by
  have hfit : mixKnee geomHalf geomHalf m' (2 * N - m') (0.98 : ℝ) ≤ 2 * m := by
    rw [mixKnee_geomHalf_eq_twelve (by omega) (by omega)]; omega
  have hfit' : mixKnee geomHalf geomHalf N N (0.98 : ℝ) ≤ 2 * m' := by
    rw [mixKnee_geomHalf_eq_twelve (by omega) (by omega)]; omega
  exact mixKnee_sweep_monotone geomHalf_pos geomHalf_antitone (by omega) hmm hm'N
    (by norm_num) hfit hfit'

end AttentionBudget