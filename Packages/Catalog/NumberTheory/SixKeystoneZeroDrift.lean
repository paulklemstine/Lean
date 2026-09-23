import Mathlib

/-!
# SIX-KEYSTONE-ZERO-DRIFT: an arithmetic model of reproducible pipelines

The audit narrative behind paper 103 asserts that a family of computational keystones
(a synergy decomposition, a saturating capacity curve, and a ramp law) reproduce *exactly*
under re-execution.  A reproducibility claim of that shape is only meaningful if the
underlying pipeline is a deterministic arithmetic object whose reported statistics are
*functions of the seed alone* — invariant under how the run is chopped into batches — and
if the three reported shapes (synergy ≥ 0, deficits nondecreasing, `P₁ = ramp(q/r²)`) are
theorems rather than empirical regularities.

This file supplies exactly that: a self-contained arithmetic model of a seeded pipeline
(a linear congruential map on `ZMod`-style residues), together with proofs of the four
structural keystones.

## Main results

* **Zero drift (rebatching invariance)** — `run_add`, `runBatches_eq_run`,
  `zero_drift`: the state produced by a run depends only on the seed and the *total*
  number of steps, never on the batch schedule.  Two audits that agree on the total step
  count agree on every recorded state.
* **Capacity saturation** — `cap_mono`, `cap_le_logb_modulus`, `cap_succ_le`,
  `deficit_zero`, `deficit_mono`, `deficit_tendsto_atTop`: the orbit capacity
  `I(k) = log₂ #{states seen by time k}` is nondecreasing, bounded by `log₂ m`, and grows
  by at most `1` per step; hence the deficit `d(k) = k − I(k)` starts at `+0.000`, never
  decreases, and tends to `+∞` — the empirical saturation profile.
* **Synergy decomposition** — `jointStates_card`, `capN_lcm_add_capN_gcd`,
  `synergy_nonneg`, `synergy_eq_zero_iff`, `overlap_nonneg`, `overlap_le_one`:
  the joint channel of two periodic channels of periods `p, q` visits exactly `lcm p q`
  states, so joint capacity obeys the inclusion–exclusion identity
  `I(p ⊔ q) = I(p) + I(q) − I(p ⊓ q)`; the synergy `I(p ⊔ q) − max(I p, I q)` is
  nonnegative and vanishes precisely when one period divides the other, while the
  overlap coefficient lies in `[0,1]`.
* **The ramp law is exact** — `lexCount_eq`, `P₁_eq_ramp`: for the lexicographic
  enumeration of an `r × r` cell grid the success fraction is *exactly*
  `ramp (q / r²) = max 0 (min 1 (q / r²))`, with no error term.

Everything is proved for the concrete arithmetic model; no numerical experiment is
assumed.
-/

namespace SixKeystoneZeroDrift

open Finset

section

/-! ## Keystone R: deterministic pipelines and rebatching invariance -/

/-- One step of a seeded linear-congruential pipeline with multiplier `a`, increment `c`
and modulus `m`. -/
def step (a c m : ℕ) (x : ℕ) : ℕ := (a * x + c) % m

/-- `run a c m n s` is the state after `n` steps from seed `s`. -/
def run (a c m : ℕ) : ℕ → ℕ → ℕ
  | 0, s => s
  | (n + 1), s => run a c m n (step a c m s)

@[simp] lemma run_zero (a c m s : ℕ) : run a c m 0 s = s := rfl

lemma run_succ (a c m n s : ℕ) : run a c m (n + 1) s = run a c m n (step a c m s) := rfl

/-- **Zero drift, core form.** A run of `p + q` steps is a run of `p` steps followed by a
run of `q` steps: the intermediate checkpoint is immaterial. -/
theorem run_add (a c m : ℕ) (p q s : ℕ) :
    run a c m (p + q) s = run a c m q (run a c m p s) := by
  induction p generalizing s with
  | zero => simp
  | succ p ih => rw [Nat.succ_add, run_succ, run_succ, ih]

/-- Executing a list of batch sizes, one batch after another. -/
def runBatches (a c m : ℕ) (L : List ℕ) (s : ℕ) : ℕ :=
  L.foldl (fun x n => run a c m n x) s

/-- A batched execution equals the monolithic execution of the same total length. -/
theorem runBatches_eq_run (a c m : ℕ) (L : List ℕ) (s : ℕ) :
    runBatches a c m L s = run a c m L.sum s := by
  induction L generalizing s with
  | nil => simp [runBatches]
  | cons n L ih =>
      simp only [runBatches, List.foldl_cons, List.sum_cons] at *
      rw [ih, run_add]

/-- **SIX-KEYSTONE-ZERO-DRIFT (reproducibility).** Two audits of the same seeded pipeline
that agree on the total number of steps agree on the final state, whatever batch schedule
each one used. -/
theorem zero_drift (a c m : ℕ) (L L' : List ℕ) (s : ℕ) (h : L.sum = L'.sum) :
    runBatches a c m L s = runBatches a c m L' s := by
  rw [runBatches_eq_run, runBatches_eq_run, h]

/-- States stay inside the residue window. -/
lemma run_lt (a c m : ℕ) (hm : 0 < m) (n s : ℕ) (hs : s < m) : run a c m n s < m := by
  induction n generalizing s with
  | zero => simpa using hs
  | succ n ih => exact ih _ (Nat.mod_lt _ hm)

/-! ## Keystone C: orbit capacity and the saturating deficit curve -/

/-- The set of states visited up to and including time `k`. -/
def states (a c m s k : ℕ) : Finset ℕ :=
  (range (k + 1)).image (fun i => run a c m i s)

lemma states_card_pos (a c m s k : ℕ) : 0 < (states a c m s k).card := by
  apply Finset.card_pos.2
  exact ⟨s, by simp [states, Finset.mem_image]; exact ⟨0, by simp⟩⟩

lemma states_zero (a c m s : ℕ) : states a c m s 0 = {s} := by
  simp [states]

lemma states_subset_succ (a c m s k : ℕ) : states a c m s k ⊆ states a c m s (k + 1) := by
  simp only [states]
  exact Finset.image_subset_image (Finset.range_mono (by omega))

lemma states_card_succ_le (a c m s k : ℕ) :
    (states a c m s (k + 1)).card ≤ (states a c m s k).card + 1 := by
  have : states a c m s (k + 1)
      = insert (run a c m (k + 1) s) (states a c m s k) := by
    unfold states
    rw [Finset.range_add_one, Finset.image_insert]
  rw [this]
  exact Finset.card_insert_le _ _

lemma states_subset_range (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (k : ℕ) :
    states a c m s k ⊆ range m := by
  intro x hx
  simp only [states, Finset.mem_image] at hx
  obtain ⟨i, _, rfl⟩ := hx
  exact Finset.mem_range.2 (run_lt a c m hm i s hs)

lemma states_card_le_modulus (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (k : ℕ) :
    (states a c m s k).card ≤ m := by
  simpa using Finset.card_le_card (states_subset_range a c m s hm hs k)

/-- Orbit capacity at time `k`, in bits. -/
noncomputable def cap (a c m s k : ℕ) : ℝ := Real.logb 2 ((states a c m s k).card)

/-- The deficit: how far the capacity curve has fallen behind the ideal `k` bits. -/
noncomputable def deficit (a c m s k : ℕ) : ℝ := (k : ℝ) - cap a c m s k

lemma cap_nonneg (a c m s k : ℕ) : 0 ≤ cap a c m s k := by
  have h : (1 : ℝ) ≤ ((states a c m s k).card : ℝ) := by
    exact_mod_cast states_card_pos a c m s k
  simpa [cap] using Real.logb_nonneg (by norm_num) h

lemma cap_mono (a c m s : ℕ) {k l : ℕ} (h : k ≤ l) : cap a c m s k ≤ cap a c m s l := by
  have hsub : states a c m s k ⊆ states a c m s l := by
    simp only [states]
    exact Finset.image_subset_image (Finset.range_mono (by omega))
  have hc : ((states a c m s k).card : ℝ) ≤ ((states a c m s l).card : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  have hpos : (0 : ℝ) < ((states a c m s k).card : ℝ) := by
    exact_mod_cast states_card_pos a c m s k
  exact Real.logb_le_logb_of_le (by norm_num) hpos hc

/-- Capacity is bounded by the entropy of the residue window: the saturation ceiling. -/
theorem cap_le_logb_modulus (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (k : ℕ) :
    cap a c m s k ≤ Real.logb 2 m := by
  have hc : ((states a c m s k).card : ℝ) ≤ (m : ℝ) := by
    exact_mod_cast states_card_le_modulus a c m s hm hs k
  have hpos : (0 : ℝ) < ((states a c m s k).card : ℝ) := by
    exact_mod_cast states_card_pos a c m s k
  exact Real.logb_le_logb_of_le (by norm_num) hpos hc

/-- One extra step buys at most one extra bit. -/
theorem cap_succ_le (a c m s k : ℕ) : cap a c m s (k + 1) ≤ cap a c m s k + 1 := by
  set A := ((states a c m s k).card : ℝ) with hA
  have hApos : (0 : ℝ) < A := by
    rw [hA]; exact_mod_cast states_card_pos a c m s k
  have hle : ((states a c m s (k + 1)).card : ℝ) ≤ 2 * A := by
    have h1 : ((states a c m s (k + 1)).card : ℝ) ≤ A + 1 := by
      rw [hA]; exact_mod_cast states_card_succ_le a c m s k
    have h2 : (1 : ℝ) ≤ A := by
      rw [hA]; exact_mod_cast states_card_pos a c m s k
    linarith
  have hpos : (0 : ℝ) < ((states a c m s (k + 1)).card : ℝ) := by
    exact_mod_cast states_card_pos a c m s (k + 1)
  have := Real.logb_le_logb_of_le (b := 2) (by norm_num) hpos hle
  have h2 : Real.logb 2 (2 * A) = 1 + Real.logb 2 A := by
    rw [Real.logb_mul (by norm_num) (ne_of_gt hApos),
      Real.logb_self_eq_one (b := 2) (by norm_num)]
  rw [h2] at this
  simpa [cap, hA] using by linarith [this]

@[simp] theorem deficit_zero (a c m s : ℕ) : deficit a c m s 0 = 0 := by
  simp [deficit, cap, states_zero]

/-- **Deficits never decrease**: the empirical `+0.000 … +6.372` profile is forced. -/
theorem deficit_mono (a c m s : ℕ) {k l : ℕ} (h : k ≤ l) :
    deficit a c m s k ≤ deficit a c m s l := by
  induction l with
  | zero =>
      have : k = 0 := Nat.le_zero.1 h
      subst this; exact le_rfl
  | succ l ih =>
      rcases Nat.lt_or_ge k (l + 1) with hk | hk
      · have hkl : k ≤ l := Nat.lt_succ_iff.1 hk
        have h1 := ih hkl
        have h2 : deficit a c m s l ≤ deficit a c m s (l + 1) := by
          have := cap_succ_le a c m s l
          simp only [deficit, Nat.cast_add, Nat.cast_one]
          linarith
        linarith
      · have : k = l + 1 := le_antisymm h hk
        subst this; exact le_rfl

/-- The deficit diverges: the capacity curve saturates. -/
theorem deficit_tendsto_atTop (a c m s : ℕ) (hm : 0 < m) (hs : s < m) :
    Filter.Tendsto (fun k => deficit a c m s k) Filter.atTop Filter.atTop := by
  have hmono : ∀ k : ℕ, (k : ℝ) - Real.logb 2 m ≤ deficit a c m s k := by
    intro k
    have := cap_le_logb_modulus a c m s hm hs k
    simp only [deficit]; linarith
  refine Filter.tendsto_atTop_mono hmono ?_
  exact Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop

/-! ## Keystone S: the synergy decomposition of two periodic channels -/

/-- The joint states of two channels of periods `p` and `q` observed for `k` ticks. -/
def jointStates (p q k : ℕ) : Finset (ℕ × ℕ) :=
  (range k).image (fun i => (i % p, i % q))

/-- **Joint capacity is the lcm.** Two periodic channels of periods `p, q` jointly visit
exactly `lcm p q` distinct configurations. -/
theorem jointStates_card (p q : ℕ) :
    (jointStates p q (Nat.lcm p q)).card = Nat.lcm p q := by
  rw [jointStates, Finset.card_image_of_injOn, Finset.card_range]
  intro i hi j hj hij
  simp only [Finset.mem_coe, Finset.mem_range] at hi hj
  have h1 : i % p = j % p := congrArg Prod.fst hij
  have h2 : i % q = j % q := congrArg Prod.snd hij
  -- from the two congruences, `lcm p q` divides the difference
  rcases le_total i j with h | h
  · have hp' : p ∣ j - i := (Nat.modEq_iff_dvd' h).1 h1
    have hq' : q ∣ j - i := (Nat.modEq_iff_dvd' h).1 h2
    have hl : Nat.lcm p q ∣ j - i := Nat.lcm_dvd hp' hq'
    have : j - i = 0 := by
      rcases Nat.eq_zero_or_pos (j - i) with h0 | h0
      · exact h0
      · exact absurd (Nat.le_of_dvd h0 hl) (by omega)
    omega
  · have hp' : p ∣ i - j := (Nat.modEq_iff_dvd' h).1 h1.symm
    have hq' : q ∣ i - j := (Nat.modEq_iff_dvd' h).1 h2.symm
    have hl : Nat.lcm p q ∣ i - j := Nat.lcm_dvd hp' hq'
    have : i - j = 0 := by
      rcases Nat.eq_zero_or_pos (i - j) with h0 | h0
      · exact h0
      · exact absurd (Nat.le_of_dvd h0 hl) (by omega)
    omega

/-- Capacity of a channel with `n` configurations, in bits. -/
noncomputable def capN (n : ℕ) : ℝ := Real.logb 2 n

/-- **Inclusion–exclusion for channel capacity**:
`I(joint) + I(shared) = I(first) + I(second)`. -/
theorem capN_lcm_add_capN_gcd (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    capN (Nat.lcm p q) + capN (Nat.gcd p q) = capN p + capN q := by
  have hg : 0 < Nat.gcd p q := Nat.gcd_pos_of_pos_left _ hp
  have hl : 0 < Nat.lcm p q := Nat.pos_of_ne_zero (by
    simpa [Nat.lcm_eq_zero_iff] using ⟨hp.ne', hq.ne'⟩)
  have key : (Nat.gcd p q : ℝ) * (Nat.lcm p q : ℝ) = (p : ℝ) * (q : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (Nat.gcd_mul_lcm p q)
  have h1 : capN (Nat.gcd p q) + capN (Nat.lcm p q)
      = Real.logb 2 ((Nat.gcd p q : ℝ) * (Nat.lcm p q : ℝ)) := by
    rw [Real.logb_mul (by exact_mod_cast hg.ne') (by exact_mod_cast hl.ne')]
    rfl
  have h2 : capN p + capN q = Real.logb 2 ((p : ℝ) * (q : ℝ)) := by
    rw [Real.logb_mul (by exact_mod_cast hp.ne') (by exact_mod_cast hq.ne')]
    rfl
  rw [h2, ← key, ← h1]; ring

/-- Synergy of two channels: the capacity of the joint channel over and above the better
of the two marginal channels. -/
noncomputable def synergy (p q : ℕ) : ℝ := capN (Nat.lcm p q) - max (capN p) (capN q)

/-- The overlap coefficient: shared capacity as a fraction of the weaker channel. -/
noncomputable def overlap (p q : ℕ) : ℝ := capN (Nat.gcd p q) / min (capN p) (capN q)

lemma capN_le_capN {m n : ℕ} (hm : 0 < m) (h : m ≤ n) : capN m ≤ capN n := by
  have hpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  exact Real.logb_le_logb_of_le (by norm_num) hpos (by exact_mod_cast h)

/-- **Synergy is never negative.** -/
theorem synergy_nonneg (p q : ℕ) (hp : 0 < p) (hq : 0 < q) : 0 ≤ synergy p q := by
  have hpl : p ≤ Nat.lcm p q := Nat.le_of_dvd (Nat.pos_of_ne_zero (by
      simpa [Nat.lcm_eq_zero_iff] using ⟨hp.ne', hq.ne'⟩)) (Nat.dvd_lcm_left p q)
  have hql : q ≤ Nat.lcm p q := Nat.le_of_dvd (Nat.pos_of_ne_zero (by
      simpa [Nat.lcm_eq_zero_iff] using ⟨hp.ne', hq.ne'⟩)) (Nat.dvd_lcm_right p q)
  have h1 : capN p ≤ capN (Nat.lcm p q) := capN_le_capN hp hpl
  have h2 : capN q ≤ capN (Nat.lcm p q) := capN_le_capN hq hql
  simp only [synergy, sub_nonneg, max_le_iff]
  exact ⟨h1, h2⟩

/-- **Synergy vanishes exactly in the nested case.** Two channels contribute no joint
capacity beyond the stronger one precisely when one period divides the other. -/
theorem synergy_eq_zero_iff (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    synergy p q = 0 ↔ p ∣ q ∨ q ∣ p := by
  have hlpos : 0 < Nat.lcm p q := Nat.pos_of_ne_zero (by
    simpa [Nat.lcm_eq_zero_iff] using ⟨hp.ne', hq.ne'⟩)
  have hmax : max (capN p) (capN q) = capN (max p q) := by
    rcases le_total p q with h | h
    · rw [max_eq_right (capN_le_capN hp h), max_eq_right h]
    · rw [max_eq_left (capN_le_capN hq h), max_eq_left h]
  have hmaxpos : 0 < max p q := lt_of_lt_of_le hp (le_max_left _ _)
  constructor
  · intro h0
    rw [synergy, hmax, sub_eq_zero] at h0
    have hle : Nat.lcm p q ≤ max p q := by
      by_contra hcon
      push_neg at hcon
      have hlt : capN (max p q) < capN (Nat.lcm p q) := by
        refine Real.logb_lt_logb (by norm_num) (by exact_mod_cast hmaxpos) ?_
        exact_mod_cast hcon
      rw [h0] at hlt
      exact lt_irrefl _ hlt
    have hge : max p q ≤ Nat.lcm p q := by
      rcases le_total p q with h | h
      · rw [max_eq_right h]; exact Nat.le_of_dvd hlpos (Nat.dvd_lcm_right p q)
      · rw [max_eq_left h]; exact Nat.le_of_dvd hlpos (Nat.dvd_lcm_left p q)
    have : Nat.lcm p q = max p q := le_antisymm hle hge
    rcases le_total p q with h | h
    · left
      rw [max_eq_right h] at this
      exact this ▸ Nat.dvd_lcm_left p q
    · right
      rw [max_eq_left h] at this
      exact this ▸ Nat.dvd_lcm_right p q
  · intro h
    rcases h with h | h
    · have hl : Nat.lcm p q = q := Nat.lcm_eq_right h
      have hmx : max p q = q := max_eq_right (Nat.le_of_dvd hq h)
      rw [synergy, hmax, hl, hmx, sub_self]
    · have hl : Nat.lcm p q = p := Nat.lcm_eq_left h
      have hmx : max p q = p := max_eq_left (Nat.le_of_dvd hp h)
      rw [synergy, hmax, hl, hmx, sub_self]

lemma capN_gcd_le_min (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    capN (Nat.gcd p q) ≤ min (capN p) (capN q) := by
  have hg : 0 < Nat.gcd p q := Nat.gcd_pos_of_pos_left _ hp
  refine le_min (capN_le_capN hg (Nat.le_of_dvd hp (Nat.gcd_dvd_left p q)))
    (capN_le_capN hg (Nat.le_of_dvd hq (Nat.gcd_dvd_right p q)))

theorem overlap_nonneg (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) : 0 ≤ overlap p q := by
  have hg : 0 < Nat.gcd p q := Nat.gcd_pos_of_pos_left _ (by omega)
  have h1 : 0 ≤ capN (Nat.gcd p q) := by
    have : (1 : ℝ) ≤ (Nat.gcd p q : ℝ) := by exact_mod_cast hg
    simpa [capN] using Real.logb_nonneg (by norm_num) this
  have h2 : 0 < min (capN p) (capN q) := by
    have hp' : 0 < capN p := by
      have : (1 : ℝ) < (p : ℝ) := by exact_mod_cast (by omega : 1 < p)
      simpa [capN] using Real.logb_pos (by norm_num) this
    have hq' : 0 < capN q := by
      have : (1 : ℝ) < (q : ℝ) := by exact_mod_cast (by omega : 1 < q)
      simpa [capN] using Real.logb_pos (by norm_num) this
    exact lt_min hp' hq'
  exact div_nonneg h1 h2.le

theorem overlap_le_one (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) : overlap p q ≤ 1 := by
  have h2 : 0 < min (capN p) (capN q) := by
    have hp' : 0 < capN p := by
      have : (1 : ℝ) < (p : ℝ) := by exact_mod_cast (by omega : 1 < p)
      simpa [capN] using Real.logb_pos (by norm_num) this
    have hq' : 0 < capN q := by
      have : (1 : ℝ) < (q : ℝ) := by exact_mod_cast (by omega : 1 < q)
      simpa [capN] using Real.logb_pos (by norm_num) this
    exact lt_min hp' hq'
  rw [overlap, div_le_one h2]
  exact capN_gcd_le_min p q (by omega) (by omega)

/-! ## Keystone P: the ramp law is exact -/

/-- The clamped ramp `x ↦ max 0 (min 1 x)`. -/
noncomputable def ramp (x : ℝ) : ℝ := max 0 (min 1 x)

lemma ramp_mono : Monotone ramp := by
  intro x y h
  exact max_le_max le_rfl (min_le_min le_rfl h)

/-- Counting the first `q` cells of the lexicographic enumeration of an `r × r` grid. -/
theorem lexCount_eq (q r : ℕ) :
    (((range r) ×ˢ (range r)).filter (fun z => z.1 * r + z.2 < q)).card = min q (r * r) := by
  classical
  rcases Nat.eq_zero_or_pos r with hr | hr
  · subst hr; simp
  rw [← Finset.card_range (min q (r * r))]
  refine Finset.card_bij' (fun z _ => z.1 * r + z.2) (fun n _ => (n / r, n % r)) ?_ ?_ ?_ ?_
  · intro z hz
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hz
    obtain ⟨⟨h1, h2⟩, h3⟩ := hz
    simp only [Finset.mem_range, lt_min_iff]
    refine ⟨h3, ?_⟩
    calc z.1 * r + z.2 < z.1 * r + r := by omega
      _ = (z.1 + 1) * r := by ring
      _ ≤ r * r := Nat.mul_le_mul_right r (by omega)
  · intro n hn
    simp only [Finset.mem_range, lt_min_iff] at hn
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range]
    refine ⟨⟨?_, Nat.mod_lt _ hr⟩, ?_⟩
    · exact Nat.div_lt_of_lt_mul (by linarith [hn.2])
    · rw [Nat.div_add_mod']
      exact hn.1
  · intro z hz
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hz
    obtain ⟨⟨_, h2⟩, _⟩ := hz
    have h1 : (z.1 * r + z.2) / r = z.1 := by
      rw [Nat.add_comm, Nat.add_mul_div_right _ _ hr, Nat.div_eq_of_lt h2, Nat.zero_add]
    have h2' : (z.1 * r + z.2) % r = z.2 := by
      rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt h2]
    rw [Prod.ext_iff]
    exact ⟨h1, h2'⟩
  · intro n _
    simpa using Nat.div_add_mod' n r

/-- The measured success fraction of the first `q` cells of an `r × r` grid. -/
noncomputable def P₁ (q r : ℕ) : ℝ :=
  ((((range r) ×ˢ (range r)).filter (fun z => z.1 * r + z.2 < q)).card : ℝ) / (r : ℝ) ^ 2

/-- **The ramp law holds exactly**: `P₁(q, r) = ramp (q / r²)`, no error term. -/
theorem P₁_eq_ramp (q r : ℕ) (hr : 0 < r) : P₁ q r = ramp ((q : ℝ) / (r : ℝ) ^ 2) := by
  have hrpos : (0 : ℝ) < (r : ℝ) ^ 2 := by positivity
  rw [P₁, lexCount_eq]
  rcases le_total q (r * r) with h | h
  · have hcast : ((min q (r * r) : ℕ) : ℝ) = (q : ℝ) := by
      rw [min_eq_left h]
    rw [hcast, ramp]
    have hq : (q : ℝ) / (r : ℝ) ^ 2 ≤ 1 := by
      rw [div_le_one hrpos]
      have : (q : ℝ) ≤ ((r * r : ℕ) : ℝ) := by exact_mod_cast h
      simpa [pow_two] using this
    have hq0 : 0 ≤ (q : ℝ) / (r : ℝ) ^ 2 := by positivity
    rw [min_eq_right hq, max_eq_right hq0]
  · have hcast : ((min q (r * r) : ℕ) : ℝ) = ((r * r : ℕ) : ℝ) := by
      rw [min_eq_right h]
    rw [hcast, ramp]
    have hq : (1 : ℝ) ≤ (q : ℝ) / (r : ℝ) ^ 2 := by
      rw [le_div_iff₀ hrpos]
      have : ((r * r : ℕ) : ℝ) ≤ (q : ℝ) := by exact_mod_cast h
      simpa [pow_two] using this
    rw [min_eq_left hq, max_eq_right (by norm_num : (0:ℝ) ≤ 1)]
    push_cast
    field_simp [pow_two]

/-! ## The audit bundle -/

/-- **SIX-KEYSTONE-ZERO-DRIFT, bundled.** For any seeded pipeline and any two batch
schedules with the same total length, the final state is identical; and the three reported
shapes — a nondecreasing capacity curve with nondecreasing, divergent deficits, a
nonnegative synergy with an overlap coefficient in `[0,1]`, and an exact ramp law — are all
theorems of the model, hence cannot drift between runs. -/
theorem audit_zero_drift (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (p q r : ℕ)
    (hp : 2 ≤ p) (hq : 2 ≤ q) (hr : 0 < r) (L L' : List ℕ) (hL : L.sum = L'.sum) :
    runBatches a c m L s = runBatches a c m L' s ∧
    (∀ k l : ℕ, k ≤ l → deficit a c m s k ≤ deficit a c m s l) ∧
    deficit a c m s 0 = 0 ∧
    Filter.Tendsto (fun k => deficit a c m s k) Filter.atTop Filter.atTop ∧
    0 ≤ synergy p q ∧ overlap p q ∈ Set.Icc (0 : ℝ) 1 ∧
    (∀ n : ℕ, P₁ n r = ramp ((n : ℝ) / (r : ℝ) ^ 2)) := by
  refine ⟨zero_drift a c m L L' s hL, fun k l h => deficit_mono a c m s h,
    deficit_zero a c m s, deficit_tendsto_atTop a c m s hm hs,
    synergy_nonneg p q (by omega) (by omega),
    ⟨overlap_nonneg p q hp hq, overlap_le_one p q hp hq⟩,
    fun n => P₁_eq_ramp n r hr⟩

end

end SixKeystoneZeroDrift