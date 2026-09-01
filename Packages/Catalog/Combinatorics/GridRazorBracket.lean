import Combinatorics.KneeInvariance

/-!
# The grid razor: what a finite budget sweep can and cannot pin down (NET-66)

This file formalises barrier (c) of the NET-66 round — the *razor*.  The measured
`ctx = 2048` cell of the 1.5B model is a sweep of the key budget on the fine grid
`{8, 12, 16, 20, 24, 32}` at gate `0.98`:

| k        | 8      | 12     | 16          | 20     | 24     | 32     |
|----------|--------|--------|-------------|--------|--------|--------|
| retained | 0.9597 | 0.9715 | 0.9785 (✗)  | 0.9817 | 0.9846 | 0.9867 |

The reported knee is `k* = 20`, but `k = 16` misses the gate by `0.0015`, about one
standard error.  Two distinct questions are separated here.

**What the grid does determine.**  `razor_bracket_exact` proves that the set of
knees consistent with the six measured numbers (over *all* monotone curves matching
them) is **exactly** the interval `(16, 20]` — every one of `17, 18, 19, 20` is
realised by an honest monotone curve agreeing with the measurement at every grid
point, and nothing outside is.  So the sweep pins the bracket and nothing finer:
the reported `20` is the conservative right endpoint, not an identified value.

**What one standard error does to it.**  `razor_one_se_reopens` produces a monotone
curve within `0.0015` of the measurement at *every* grid point whose knee is `16`.
The razor is therefore genuinely open at the left endpoint: a one-SE perturbation of
the `k = 16` cell moves the knee out of the bracket.

**The measurement is realisable.**  `net66Row_agree`, `net66Row_knee` build an actual
`Workload 10000` in the sense of `Combinatorics.KneeInvariance` — 10000 prediction
windows with explicit key demands — whose agreement curve reproduces all six measured
values on the nose and whose knee at gate `0.98` is `20`.  The row is thus a genuine
demand profile, not merely a table of numbers.

The general tools are `knee_mem_Ioc` (a grid bracket for any monotone curve) and
`gridKnee_eq_of_mem` (the observed grid knee equals the true knee exactly when the
true knee lies on the grid).
-/

namespace Combinatorics.GridRazorBracket

open Finset Combinatorics.KneeInvariance

/-! ## Four-decimal curves -/

/-- Retained-quality readings are four-decimal rationals; `curveOf f` is the curve
whose value at budget `k` is `f k / 10000`. -/
def curveOf (f : ℕ → ℕ) : ℕ → ℚ := fun k => (f k : ℚ) / 10000

theorem curveOf_mono {f : ℕ → ℕ} (hf : Monotone f) : Monotone (curveOf f) := by
  intro a b h
  have : (f a : ℚ) ≤ (f b : ℚ) := by exact_mod_cast hf h
  unfold curveOf
  gcongr

theorem curveOf_le_iff (f : ℕ → ℕ) (k m : ℕ) : ((m : ℚ) / 10000 ≤ curveOf f k) ↔ m ≤ f k := by
  unfold curveOf
  rw [div_le_div_iff_of_pos_right (by norm_num : (0:ℚ) < 10000)]
  exact Nat.cast_le

/-- The measurement gate, `0.98`, identical to the NET-55/65 rounds. -/
def gate : ℚ := 9800 / 10000

theorem gate_eq : gate = 49 / 50 := by norm_num [gate]

/-- A single upward step of height `c` at budget `t`. -/
def step (t c : ℕ) : ℕ → ℕ := fun k => if t ≤ k then c else 0

theorem step_mono (t c : ℕ) : Monotone (step t c) := by
  intro a b h
  simp only [step]
  split_ifs <;> omega

/-! ## The measured 2048 row -/

/-- The measured retained curve of the first `ctx = 2048` cell of the 1.5B model, in
units of `10⁻⁴`, written as a sum of steps at the six grid budgets:
`9597, 9715, 9785, 9817, 9846, 9867`. -/
def measNum : ℕ → ℕ := fun k =>
  step 8 9597 k + step 12 118 k + step 16 70 k + step 20 32 k + step 24 29 k + step 32 21 k

theorem measNum_mono : Monotone measNum := by
  intro a b h
  have h1 := step_mono 8 9597 h
  have h2 := step_mono 12 118 h
  have h3 := step_mono 16 70 h
  have h4 := step_mono 20 32 h
  have h5 := step_mono 24 29 h
  have h6 := step_mono 32 21 h
  simp only [measNum]
  omega

/-- The measured curve itself. -/
def measCurve : ℕ → ℚ := curveOf measNum

theorem measCurve_mono : Monotone measCurve := curveOf_mono measNum_mono

/-- The six measured grid budgets. -/
def grid : Finset ℕ := {8, 12, 16, 20, 24, 32}

theorem measNum_grid :
    measNum 8 = 9597 ∧ measNum 12 = 9715 ∧ measNum 16 = 9785 ∧
    measNum 20 = 9817 ∧ measNum 24 = 9846 ∧ measNum 32 = 9867 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [measNum, step]

/-- Below `20` keys the measured curve never exceeds `0.9785`, so it stays under the
gate: this is the razor. -/
theorem measNum_lt_gate_of_lt_20 {j : ℕ} (hj : j < 20) : measNum j ≤ 9785 := by
  have := measNum_mono (show j ≤ 19 by omega)
  have h19 : measNum 19 = 9785 := by norm_num [measNum, step]
  omega

theorem measCurve_lt_gate_of_lt_20 {j : ℕ} (hj : j < 20) : measCurve j < gate := by
  have h : measNum j ≤ 9785 := measNum_lt_gate_of_lt_20 hj
  have : (measNum j : ℚ) ≤ 9785 := by exact_mod_cast h
  unfold measCurve curveOf gate
  linarith

theorem gate_le_measCurve_20 : gate ≤ measCurve 20 := by
  have h : measNum 20 = 9817 := measNum_grid.2.2.2.1
  unfold measCurve curveOf gate
  rw [h]
  norm_num

/-- The reported knee of the measured row: `k*(2048) = 20` at gate `0.98`. -/
theorem measCurve_knee : knee measCurve gate = 20 :=
  knee_eq_of gate_le_measCurve_20 fun _ hj => measCurve_lt_gate_of_lt_20 hj

/-! ## The general grid bracket -/

/-- **Bracket lemma.**  A failing grid point `p` and a passing grid point `k` confine
the true knee to the half-open interval `(p, k]` — and, for a monotone curve, to
nothing smaller. -/
theorem knee_mem_Ioc {A : ℕ → ℚ} (hA : Monotone A) {g : ℚ} {p k : ℕ}
    (hp : A p < g) (hk : g ≤ A k) : p < knee A g ∧ knee A g ≤ k := by
  refine ⟨?_, knee_le hk⟩
  by_contra hc
  push_neg at hc
  exact absurd (le_trans (knee_mem ⟨k, hk⟩) (hA hc)) (not_le.mpr hp)

/-- The knee observed on a finite grid: the least grid budget that passes the gate. -/
noncomputable def gridKnee (G : Finset ℕ) (A : ℕ → ℚ) (g : ℚ) : ℕ := sInf {k | k ∈ G ∧ g ≤ A k}

/-- The observed grid knee is never smaller than the true knee. -/
theorem knee_le_gridKnee {G : Finset ℕ} {A : ℕ → ℚ} {g : ℚ}
    (hne : ∃ k, k ∈ G ∧ g ≤ A k) : knee A g ≤ gridKnee G A g := by
  have h : gridKnee G A g ∈ {k | k ∈ G ∧ g ≤ A k} :=
    Nat.sInf_mem (by simpa [Set.Nonempty] using hne)
  exact knee_le h.2

/-- **The grid is exact exactly on the grid.**  If the true knee happens to be a grid
point, the sweep reports it; otherwise the sweep reports a strict overestimate. -/
theorem gridKnee_eq_of_mem {G : Finset ℕ} {A : ℕ → ℚ} {g : ℚ}
    (hne : ∃ k, k ∈ G ∧ g ≤ A k) (hmem : knee A g ∈ G) : gridKnee G A g = knee A g := by
  refine le_antisymm (Nat.sInf_le ⟨hmem, knee_mem (by obtain ⟨k, _, hk⟩ := hne; exact ⟨k, hk⟩)⟩) ?_
  exact knee_le_gridKnee hne

/-! ## The razor: curves consistent with the six measured numbers -/

/-- A one-parameter family of curves matching the measured row up to a single upward
bump of height `v` starting at budget `t`. -/
def bump (t v : ℕ) : ℕ → ℕ := fun k => max (measNum k) (step t v k)

theorem bump_mono (t v : ℕ) : Monotone (bump t v) :=
  measNum_mono.max (step_mono t v)

theorem bump_of_lt {t v k : ℕ} (h : k < t) : bump t v k = measNum k := by
  simp [bump, step, Nat.not_le.mpr h]

theorem bump_of_ge {t v k : ℕ} (h : t ≤ k) : bump t v k = max (measNum k) v := by
  simp [bump, step, h]

/-- **The knee of a bumped curve is the bump location.**  Any monotone curve obtained
from the measurement by lifting the cells from `t` onwards to at least the gate has
knee exactly `t`, provided `t ≤ 20` (below `20` the measured values are all under the
gate). -/
theorem bump_knee {t v : ℕ} (ht : t ≤ 20) (hv : 9800 ≤ v) :
    knee (curveOf (bump t v)) gate = t := by
  refine knee_eq_of ?_ fun j hj => ?_
  · have h : 9800 ≤ bump t v t := by
      rw [bump_of_ge (le_refl t)]
      exact le_max_of_le_right hv
    have := (curveOf_le_iff (bump t v) t 9800).mpr h
    simpa [gate] using this
  · have hjt : j < 20 := lt_of_lt_of_le hj ht
    have hb : bump t v j = measNum j := bump_of_lt hj
    have h : (measNum j : ℚ) ≤ 9785 := by exact_mod_cast measNum_lt_gate_of_lt_20 hjt
    unfold curveOf gate
    rw [hb]
    linarith

/-- With bump height exactly the measured `0.9817` and a bump location inside the
bracket, the curve agrees with the measurement at **every** grid point. -/
theorem bump_agrees_on_grid {t : ℕ} (h16 : 16 < t) (h20 : t ≤ 20) (k : ℕ) (hk : k ∈ grid) :
    curveOf (bump t 9817) k = measCurve k := by
  obtain ⟨n8, n12, n16, n20, n24, n32⟩ := measNum_grid
  have key : bump t 9817 k = measNum k := by
    fin_cases hk
    · rw [bump_of_lt (by omega)]
    · rw [bump_of_lt (by omega)]
    · rw [bump_of_lt (by omega)]
    · rw [bump_of_ge (by omega), n20]; omega
    · rw [bump_of_ge (by omega), n24]; omega
    · rw [bump_of_ge (by omega), n32]; omega
  unfold curveOf measCurve curveOf
  rw [key]

/-- **The razor, exactly.**  The set of knees compatible with the six measured
numbers — over all monotone curves reproducing them — is precisely the half-open
bracket `(16, 20]`.  The sweep identifies the bracket and nothing inside it: `20` is
its conservative right endpoint. -/
theorem razor_bracket_exact (m : ℕ) :
    (∃ A : ℕ → ℚ, Monotone A ∧ (∀ k ∈ grid, A k = measCurve k) ∧ knee A gate = m)
      ↔ (16 < m ∧ m ≤ 20) := by
  constructor
  · rintro ⟨A, hA, hgrid, hknee⟩
    have h16 : A 16 = measCurve 16 := hgrid 16 (by simp [grid])
    have h20 : A 20 = measCurve 20 := hgrid 20 (by simp [grid])
    have hlt : A 16 < gate := by rw [h16]; exact measCurve_lt_gate_of_lt_20 (by norm_num)
    have hge : gate ≤ A 20 := by rw [h20]; exact gate_le_measCurve_20
    obtain ⟨hl, hr⟩ := knee_mem_Ioc hA hlt hge
    exact ⟨hknee ▸ hl, hknee ▸ hr⟩
  · rintro ⟨h16, h20⟩
    exact ⟨curveOf (bump m 9817), curveOf_mono (bump_mono m 9817),
      bump_agrees_on_grid h16 h20, bump_knee h20 (by norm_num)⟩

/-- Every point of the bracket is genuinely attained: `17, 18, 19, 20` are all knees
of monotone curves reproducing the measurement exactly. -/
theorem razor_all_of_bracket_realizable {m : ℕ} (h16 : 16 < m) (h20 : m ≤ 20) :
    ∃ A : ℕ → ℚ, Monotone A ∧ (∀ k ∈ grid, A k = measCurve k) ∧ knee A gate = m :=
  (razor_bracket_exact m).mpr ⟨h16, h20⟩

/-- **One standard error reopens the bracket.**  There is a monotone curve within
`0.0015` of the measurement at every grid point whose knee is `16`: the failing razor
cell `0.9785 < 0.98` is inside noise, so the left endpoint of the bracket is not
closed by the data. -/
theorem razor_one_se_reopens :
    ∃ A : ℕ → ℚ, Monotone A ∧ (∀ k ∈ grid, |A k - measCurve k| ≤ 15 / 10000) ∧
      knee A gate = 16 := by
  obtain ⟨n8, n12, n16, n20, n24, n32⟩ := measNum_grid
  refine ⟨curveOf (bump 16 9800), curveOf_mono (bump_mono 16 9800), ?_,
    bump_knee (by norm_num) (le_refl _)⟩
  intro k hk
  have key : bump 16 9800 k = measNum k ∨ (k = 16 ∧ bump 16 9800 k = 9800) := by
    fin_cases hk
    · exact Or.inl (bump_of_lt (by omega))
    · exact Or.inl (bump_of_lt (by omega))
    · exact Or.inr ⟨rfl, by rw [bump_of_ge (le_refl 16), n16]; omega⟩
    · exact Or.inl (by rw [bump_of_ge (by omega), n20]; omega)
    · exact Or.inl (by rw [bump_of_ge (by omega), n24]; omega)
    · exact Or.inl (by rw [bump_of_ge (by omega), n32]; omega)
  rcases key with h | ⟨hk16, h⟩
  · unfold curveOf measCurve curveOf
    rw [h]
    norm_num
  · subst hk16
    unfold curveOf measCurve curveOf
    rw [h, n16]
    norm_num

/-! ## The measured row is an honest demand profile -/

/-- Key demand of window `a` in the realising workload: the windows are sorted by
demand, with `9597` served by `8` keys, the next `118` by `12`, and so on. -/
def net66Demand (a : ℕ) : ℕ :=
  if a < 9597 then 8 else if a < 9715 then 12 else if a < 9785 then 16
  else if a < 9817 then 20 else if a < 9846 then 24 else if a < 9867 then 32 else 40

/-- The cumulative count of windows served by budget `k`. -/
def cum (k : ℕ) : ℕ :=
  if k < 8 then 0 else if k < 12 then 9597 else if k < 16 then 9715
  else if k < 20 then 9785 else if k < 24 then 9817 else if k < 32 then 9846
  else if k < 40 then 9867 else 10000

theorem demand_le_iff {a : ℕ} (ha : a < 10000) (k : ℕ) : net66Demand a ≤ k ↔ a < cum k := by
  unfold net66Demand cum
  split_ifs <;> omega

theorem cum_le (k : ℕ) : cum k ≤ 10000 := by
  unfold cum
  split_ifs <;> omega

/-- The workload realising the measured `ctx = 2048` row: 10000 prediction windows
with the demands above. -/
def net66Row : Workload 10000 where
  demand := fun i => net66Demand (i : ℕ)
  correct := fun _ => true

theorem net66Row_agreeCount (k : ℕ) : agreeCount net66Row k = cum k := by
  classical
  unfold agreeCount
  have hfil : (univ.filter fun i : Fin 10000 => net66Row.demand i ≤ k)
      = univ.filter fun i : Fin 10000 => (i : ℕ) < cum k := by
    apply filter_congr
    intro i _
    exact demand_le_iff i.isLt k
  rw [hfil, card_filter_val_lt (cum_le k)]

/-- The agreement curve of the realising workload. -/
theorem net66Row_agree (k : ℕ) : net66Row.agree k = (cum k : ℚ) / 10000 := by
  unfold Workload.agree
  rw [net66Row_agreeCount]
  norm_num

/-- **The measured row, reproduced exactly.**  The workload's agreement curve hits all
six measured values `0.9597, 0.9715, 0.9785, 0.9817, 0.9846, 0.9867`. -/
theorem net66Row_measured_values :
    net66Row.agree 8 = 9597 / 10000 ∧ net66Row.agree 12 = 9715 / 10000 ∧
    net66Row.agree 16 = 9785 / 10000 ∧ net66Row.agree 20 = 9817 / 10000 ∧
    net66Row.agree 24 = 9846 / 10000 ∧ net66Row.agree 32 = 9867 / 10000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    rw [net66Row_agree] <;> norm_num [cum]

/-- ... and its knee at the gate is the reported `k*(2048) = 20`. -/
theorem net66Row_knee : knee net66Row.agree gate = 20 := by
  refine knee_eq_of ?_ fun j hj => ?_
  · rw [net66Row_agree]
    have : cum 20 = 9817 := by norm_num [cum]
    rw [this]
    norm_num [gate]
  · rw [net66Row_agree]
    have hc : cum j ≤ 9785 := by
      unfold cum
      split_ifs <;> omega
    have : (cum j : ℚ) ≤ 9785 := by exact_mod_cast hc
    unfold gate
    linarith

/-- The realising workload agrees with the abstract measured curve at every grid
budget: the demand profile and the four-decimal table describe the same object. -/
theorem net66Row_agree_eq_measCurve (k : ℕ) (hk : k ∈ grid) :
    net66Row.agree k = measCurve k := by
  obtain ⟨n8, n12, n16, n20, n24, n32⟩ := measNum_grid
  fin_cases hk <;>
    rw [net66Row_agree] <;> unfold measCurve curveOf <;>
      simp only [n8, n12, n16, n20, n24, n32] <;> norm_num [cum]

end Combinatorics.GridRazorBracket