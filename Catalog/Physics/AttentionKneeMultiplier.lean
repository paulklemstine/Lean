import Mathlib

/-!
# The attention-mass knee: additive delay versus multiplicative decay tax

This file develops a formal theory of the *retention knee* of a discrete
attention (equivalently, of a discrete energy-spectrum) profile.  The
motivation is the NET-75 measurement "THE-FRENCH-KNEE-IS-FORTY": for a fixed
retention gate `τ` one measures the least number `k` of top positions whose
cumulative mass reaches `τ`, and one observes that the knee `k*` moves from
domain to domain (code 12, EN prose 20, math 20, DE prose 24, FR prose 40 at
context 1024).  The empirical question raised there is whether the
"tokenizer tax" is an *additive* step (`+4`) or a *multiplicative* factor
(`×2`).

We make both mechanisms precise and prove that they are structurally
different phenomena.

## Main results

* `retained_mono`, `kstar_eq`, `kstar_spec` — basic calculus of the knee.
* `kstar_delay` — **additive law**: prefixing a profile with `d` massless
  positions moves the knee by exactly `+d`.
* `kgeom_root` — **multiplicative law**: if one profile decays with ratio
  `r ^ m` and another with ratio `r`, the coarse knee is the *ceiling*
  `⌈B / m⌉` of the fine knee `B`; equality `B = m * A` holds exactly when
  `m ∣ B` (`kgeom_root_exact`).
* `french_knee_is_forty` — the verdict of NET-75 in structural form.
* `root_gap_unbounded` — **no fixed additive tax**: for a genuine
  root-of-ratio family the gap between the two knees is unbounded, so the
  `+4`-style law cannot be universal.
* `kstar_le_gridKnee`, `gridKnee_eq_kstar_of_mem` —
  a coarse measurement grid never underestimates the knee (the NET-75 French
  data are bracketed in `Physics/AttentionKneeSpectrum.lean`).
* `heavy_vs_geom_unbounded` — **tail-class separation**: a heavy-tailed
  profile beats every geometric profile by an arbitrary *factor*, so across
  tail classes the tax is not even a bounded multiplier.

All profiles are honest: nonnegative weights, partial sums, and a knee
defined as `Nat.sInf` of the set of admissible cut-offs.
-/

namespace Physics.AttentionKnee

open Finset

/-! ## Profiles and retained mass -/

/-- The mass retained by the first `k` positions of an attention profile `w`. -/
def retained (w : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ range k, w i

/-- The knee: the least number of positions whose retained mass reaches the
gate `τ`.  If the gate is never reached this is `0` by the `Nat.sInf`
convention; every result below either assumes reachability or derives it. -/
noncomputable def kstar (w : ℕ → ℝ) (τ : ℝ) : ℕ := sInf {k | τ ≤ retained w k}

/-- Profile `w` delayed by `d` positions (a `d`-token prefix carrying no mass). -/
def delay (d : ℕ) (w : ℕ → ℝ) : ℕ → ℝ := fun i => if i < d then 0 else w (i - d)

/-- The geometric profile with decay ratio `r`: `w i = (1 - r) * r ^ i`. -/
def geom (r : ℝ) : ℕ → ℝ := fun i => (1 - r) * r ^ i

/-- The heavy-tailed (telescoping) profile `w i = 1 / ((i+1)(i+2))`, whose
retained mass is `k / (k+1)`. -/
noncomputable def heavy : ℕ → ℝ := fun i => 1 / ((i + 1) * (i + 2))

/-! ## Basic calculus of the knee -/

theorem retained_zero (w : ℕ → ℝ) : retained w 0 = 0 := by simp [retained]

theorem retained_succ (w : ℕ → ℝ) (k : ℕ) :
    retained w (k + 1) = retained w k + w k := by
  simp [retained, Finset.sum_range_succ]

theorem retained_mono (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i) : Monotone (retained w) := by
  intro a b hab
  have hsub : range a ⊆ range b := Finset.range_subset_range.mpr hab
  exact Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => hw i)

theorem le_retained_kstar (w : ℕ → ℝ) (τ : ℝ) (hne : {k | τ ≤ retained w k}.Nonempty) :
    τ ≤ retained w (kstar w τ) := Nat.sInf_mem hne

theorem not_le_retained_of_lt_kstar (w : ℕ → ℝ) (τ : ℝ) {k : ℕ}
    (hk : k < kstar w τ) : ¬ τ ≤ retained w k :=
  fun h => Nat.notMem_of_lt_sInf hk h

/-- Characterisation of the knee: it is the unique `n` that meets the gate
while all earlier cut-offs miss it. -/
theorem kstar_eq (w : ℕ → ℝ) (τ : ℝ) {n : ℕ} (h1 : τ ≤ retained w n)
    (h2 : ∀ j < n, ¬ τ ≤ retained w j) : kstar w τ = n :=
  le_antisymm (Nat.sInf_le h1)
    (le_of_not_gt fun hlt => h2 _ hlt (le_retained_kstar w τ ⟨n, h1⟩))

theorem kstar_spec (w : ℕ → ℝ) (τ : ℝ) (hne : {k | τ ≤ retained w k}.Nonempty) :
    τ ≤ retained w (kstar w τ) ∧ ∀ j < kstar w τ, ¬ τ ≤ retained w j :=
  ⟨le_retained_kstar w τ hne, fun _ hj => not_le_retained_of_lt_kstar w τ hj⟩

/-- Once past the knee, the gate stays satisfied (monotone profiles). -/
theorem le_retained_of_kstar_le (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i) (τ : ℝ)
    (hne : {k | τ ≤ retained w k}.Nonempty) {k : ℕ} (hk : kstar w τ ≤ k) :
    τ ≤ retained w k :=
  (le_retained_kstar w τ hne).trans (retained_mono w hw hk)

/-- A lower bound for the knee: if every cut-off below `n` misses the gate,
then the knee is at least `n`. -/
theorem le_kstar_of_forall_lt (w : ℕ → ℝ) (τ : ℝ) {n : ℕ}
    (hne : {k | τ ≤ retained w k}.Nonempty)
    (h : ∀ j < n, ¬ τ ≤ retained w j) : n ≤ kstar w τ := by
  by_contra hlt
  exact h _ (Nat.lt_of_not_ge hlt) (le_retained_kstar w τ hne)

/-! ## Domination: a heavier head means an earlier knee -/

theorem kstar_le_kstar_of_retained_le (v w : ℕ → ℝ) (τ : ℝ)
    (h : ∀ k, retained w k ≤ retained v k) (hne : {k | τ ≤ retained w k}.Nonempty) :
    kstar v τ ≤ kstar w τ :=
  Nat.sInf_le ((le_retained_kstar w τ hne).trans (h _))

/-! ## The additive law: a delay shifts the knee by exactly `d` -/

theorem retained_delay (d : ℕ) (w : ℕ → ℝ) (k : ℕ) :
    retained (delay d w) (d + k) = retained w k := by
  induction k with
  | zero =>
      simp only [Nat.add_zero, retained]
      refine Finset.sum_eq_zero ?_
      intro i hi
      simp [delay, Finset.mem_range.1 hi]
  | succ n ih =>
      have h : d + (n + 1) = (d + n) + 1 := by omega
      rw [h, retained_succ, ih, retained_succ]
      have hd : ¬ (d + n < d) := by omega
      simp [delay, hd]

theorem retained_delay_of_le (d : ℕ) (w : ℕ → ℝ) {k : ℕ} (hk : k ≤ d) :
    retained (delay d w) k = 0 := by
  refine Finset.sum_eq_zero ?_
  intro i hi
  have : i < d := lt_of_lt_of_le (Finset.mem_range.1 hi) hk
  simp [delay, this]

/-- **Additive tokenizer tax.**  Delaying a profile by `d` positions moves its
knee by exactly `+d`, for every positive gate `τ`. -/
theorem kstar_delay (d : ℕ) (w : ℕ → ℝ) (τ : ℝ) (hτ : 0 < τ)
    (hne : {k | τ ≤ retained w k}.Nonempty) :
    kstar (delay d w) τ = d + kstar w τ := by
  refine kstar_eq _ _ ?_ ?_
  · rw [retained_delay]
    exact le_retained_kstar w τ hne
  · intro j hj
    rcases le_or_gt j d with hjd | hjd
    · rw [retained_delay_of_le d w hjd]
      exact not_le.2 hτ
    · obtain ⟨t, rfl⟩ : ∃ t, j = d + t := ⟨j - d, by omega⟩
      rw [retained_delay]
      exact not_le_retained_of_lt_kstar w τ (by omega)

/-! ## The geometric knee -/

theorem retained_geom (r : ℝ) (k : ℕ) : retained (geom r) k = 1 - r ^ k := by
  induction k with
  | zero => simp [retained]
  | succ n ih =>
      rw [retained_succ, ih]
      simp only [geom]
      ring

/-- The geometric knee at tail budget `t = 1 - τ`: the least `k` with
`r ^ k ≤ t`. -/
noncomputable def kgeom (r t : ℝ) : ℕ := sInf {k | r ^ k ≤ t}

theorem kgeom_nonempty {r t : ℝ} (hr1 : r < 1) (ht : 0 < t) :
    {k | r ^ k ≤ t}.Nonempty := by
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one ht hr1
  exact ⟨n, le_of_lt hn⟩

theorem kgeom_spec {r t : ℝ} (hr1 : r < 1) (ht : 0 < t) : r ^ kgeom r t ≤ t :=
  Nat.sInf_mem (kgeom_nonempty hr1 ht)

theorem lt_pow_of_lt_kgeom {r t : ℝ} {j : ℕ} (hj : j < kgeom r t) : t < r ^ j :=
  lt_of_not_ge (Nat.notMem_of_lt_sInf hj)

theorem kgeom_le_iff {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t) (n : ℕ) :
    kgeom r t ≤ n ↔ r ^ n ≤ t := by
  constructor
  · intro h
    exact le_trans (pow_le_pow_of_le_one hr0 hr1.le h) (kgeom_spec hr1 ht)
  · intro h
    exact Nat.sInf_le h

/-- The gate set of a geometric profile is a tail-budget set. -/
theorem geom_gate_set (r τ : ℝ) :
    {k | τ ≤ retained (geom r) k} = {k | r ^ k ≤ 1 - τ} := by
  ext k
  simp only [Set.mem_setOf_eq, retained_geom]
  constructor <;> intro h <;> linarith

/-- The knee of a geometric profile at gate `τ` is the geometric knee at tail
budget `1 - τ`. -/
theorem kstar_geom (r τ : ℝ) : kstar (geom r) τ = kgeom r (1 - τ) := by
  rw [kstar, kgeom, geom_gate_set]

/-- The geometric knee at tail budget `r ^ n` is exactly `n`. -/
theorem kgeom_pow_self {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (n : ℕ) :
    kgeom r (r ^ n) = n := by
  have ht : (0:ℝ) < r ^ n := pow_pos hr0 n
  refine le_antisymm ((kgeom_le_iff hr0.le hr1 ht n).2 le_rfl) ?_
  by_contra hlt
  push_neg at hlt
  have h := (kgeom_le_iff hr0.le hr1 ht (n - 1)).1 (by omega)
  have hn : 1 ≤ n := by omega
  have : r ^ n < r ^ (n - 1) := by
    apply pow_lt_pow_right_of_lt_one₀ hr0 hr1
    omega
  linarith

/-! ## The multiplicative law -/

/-- **Root-of-ratio law.**  If profile `A` decays with ratio `r ^ m` while
profile `B` decays with ratio `r`, then the knee of `A` is the ceiling of the
knee of `B` divided by `m`. -/
theorem kgeom_root {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    {m : ℕ} (hm : 0 < m) :
    kgeom (r ^ m) t = kgeom r t ⌈/⌉ m := by
  have hrm0 : (0:ℝ) ≤ r ^ m := pow_nonneg hr0 m
  have hrm1 : r ^ m < 1 := pow_lt_one₀ hr0 hr1 hm.ne'
  have key : ∀ n : ℕ, kgeom (r ^ m) t ≤ n ↔ kgeom r t ≤ m * n := by
    intro n
    rw [kgeom_le_iff hrm0 hrm1 ht, kgeom_le_iff hr0 hr1 ht, ← pow_mul]
  refine le_antisymm ((key _).2 ((ceilDiv_le_iff_le_mul hm).1 le_rfl))
    ((ceilDiv_le_iff_le_mul hm).2 ((key _).1 le_rfl))

/-- Ceiling division is exact precisely on multiples. -/
theorem ceilDiv_mul_cancel {B m : ℕ} (hm : 0 < m) (h : m ∣ B) : m * (B ⌈/⌉ m) = B := by
  obtain ⟨c, rfl⟩ := h
  have hle : m * c ⌈/⌉ m ≤ c := (ceilDiv_le_iff_le_mul hm).2 le_rfl
  rcases Nat.eq_zero_or_pos c with rfl | hc
  · simp
  · have hge : c ≤ m * c ⌈/⌉ m := by
      by_contra hlt
      push_neg at hlt
      obtain ⟨d, rfl⟩ : ∃ d, c = d + 1 := ⟨c - 1, by omega⟩
      have hstep : m * (d + 1) ≤ m * d := by
        simpa using (ceilDiv_le_iff_le_mul hm).1 (show m * (d + 1) ⌈/⌉ m ≤ d by omega)
      rw [Nat.mul_succ] at hstep
      omega
    have : m * c ⌈/⌉ m = c := le_antisymm hle hge
    rw [this]

/-- **Exact multiplier.**  The fine knee is exactly `m` times the coarse knee
precisely when `m` divides it — the "×2" law of NET-75 holds up to a ceiling
correction, and exactly on multiples. -/
theorem kgeom_root_exact {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    {m : ℕ} (hm : 0 < m) :
    kgeom r t = m * kgeom (r ^ m) t ↔ m ∣ kgeom r t := by
  constructor
  · intro h; exact ⟨_, h⟩
  · intro h
    rw [kgeom_root hr0 hr1 ht hm, ceilDiv_mul_cancel hm h]

/-- **THE-FRENCH-KNEE-IS-FORTY (structural form).**  If the French profile
decays with ratio `r`, the English profile decays with ratio `r ^ 2` (French
pays a square-root decay tax), the English knee is `20`, and the French knee
is even, then the French knee is exactly `40` — double the English one. -/
theorem french_knee_is_forty {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    (hen : kgeom (r ^ 2) t = 20) (heven : 2 ∣ kgeom r t) :
    kgeom r t = 40 := by
  have h := (kgeom_root_exact hr0 hr1 ht (m := 2) (by norm_num)).2 heven
  rw [hen] at h
  omega

/-- **No fixed additive tax.**  For a genuine root-of-ratio family (`m ≥ 2`)
the gap between the fine and the coarse knee exceeds every bound as the gate
tightens: no fixed additive constant can describe the tax. -/
theorem root_gap_unbounded {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) {m : ℕ} (hm : 2 ≤ m)
    (N : ℕ) : ∃ t : ℝ, 0 < t ∧ N + kgeom (r ^ m) t ≤ kgeom r t := by
  refine ⟨r ^ (m * N + m), pow_pos hr0 _, ?_⟩
  have hmpos : 0 < m := by omega
  have hfine : kgeom r (r ^ (m * N + m)) = m * N + m := kgeom_pow_self hr0 hr1 _
  have hcoarse : kgeom (r ^ m) (r ^ (m * N + m)) = (m * N + m) ⌈/⌉ m := by
    rw [kgeom_root hr0.le hr1 (pow_pos hr0 (m * N + m)) hmpos, hfine]
  have hdvd : m ∣ m * N + m := ⟨N + 1, by ring⟩
  have hex : m * ((m * N + m) ⌈/⌉ m) = m * N + m := ceilDiv_mul_cancel hmpos hdvd
  have hval : (m * N + m) ⌈/⌉ m = N + 1 := by
    have : m * ((m * N + m) ⌈/⌉ m) = m * (N + 1) := by rw [hex]; ring
    exact Nat.eq_of_mul_eq_mul_left hmpos this
  rw [hfine, hcoarse, hval]
  nlinarith [Nat.zero_le N]

/-! ## Coarse grids never underestimate the knee -/

/-- The knee as measured on a grid `G` of tested cut-offs. -/
noncomputable def gridKnee (w : ℕ → ℝ) (τ : ℝ) (G : Finset ℕ) : ℕ :=
  sInf {k | k ∈ G ∧ τ ≤ retained w k}

theorem kstar_le_gridKnee (w : ℕ → ℝ) (τ : ℝ) (G : Finset ℕ)
    (hne : {k | k ∈ G ∧ τ ≤ retained w k}.Nonempty) :
    kstar w τ ≤ gridKnee w τ G :=
  Nat.sInf_le (Nat.sInf_mem hne).2

theorem gridKnee_eq_kstar_of_mem (w : ℕ → ℝ) (τ : ℝ) (G : Finset ℕ)
    (hne : {k | k ∈ G ∧ τ ≤ retained w k}.Nonempty)
    (hmem : kstar w τ ∈ G) : gridKnee w τ G = kstar w τ := by
  refine le_antisymm (Nat.sInf_le ⟨hmem, ?_⟩) (kstar_le_gridKnee w τ G hne)
  exact le_retained_kstar w τ ⟨_, (Nat.sInf_mem hne).2⟩

/-! ## Heavy tails: the knee is polynomial, not logarithmic -/

theorem retained_heavy (k : ℕ) : retained heavy k = k / (k + 1) := by
  induction k with
  | zero => simp [retained]
  | succ n ih =>
      have hn1 : ((n:ℝ) + 1) ≠ 0 := by positivity
      have hn2 : ((n:ℝ) + 2) ≠ 0 := by positivity
      simp only [retained, Finset.sum_range_succ] at *
      rw [ih]
      simp only [heavy]
      push_cast
      field_simp
      ring

/-- For `0 < r < 1` the sequence `n * r ^ n` beats any linear bound: there is
`n` with `C * n * r ^ n < 1`.  (Two-step Bernoulli.) -/
theorem exists_pow_lt_inv_linear {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (C : ℕ) :
    ∃ n : ℕ, 0 < n ∧ (C * n : ℝ) * r ^ n < 1 := by
  set s : ℝ := 1 / r with hs
  have hs1 : 1 < s := by rw [hs, lt_div_iff₀ hr0]; linarith
  set c : ℝ := s - 1 with hc
  have hc0 : 0 < c := by simp only [hc]; linarith
  obtain ⟨p, hp⟩ := exists_nat_gt (max (2 * C / c ^ 2) 1)
  have hp1 : (1:ℝ) < p := lt_of_le_of_lt (le_max_right _ _) hp
  have hp2 : (2 * C / c ^ 2 : ℝ) < p := lt_of_le_of_lt (le_max_left _ _) hp
  have hpc : (2 * C : ℝ) < p * c ^ 2 := by
    rw [div_lt_iff₀ (by positivity)] at hp2; linarith
  have hppos : 0 < p := by exact_mod_cast lt_trans zero_lt_one hp1
  have hbern : 1 + (p:ℝ) * c ≤ s ^ p := by
    have := one_add_mul_le_pow (a := c) (by linarith) p
    simpa [hc] using this
  have hkey : (C : ℝ) * (2 * p) < s ^ (2 * p) := by
    have h1 : (1 + (p:ℝ) * c) ^ 2 ≤ (s ^ p) ^ 2 := pow_le_pow_left₀ (by positivity) hbern 2
    have h2 : (s ^ p) ^ 2 = s ^ (2 * p) := by rw [← pow_mul, Nat.mul_comm]
    have h3 : (C : ℝ) * (2 * p) < (1 + (p:ℝ) * c) ^ 2 := by
      have hpp : (0:ℝ) < p := by linarith
      nlinarith [mul_pos hpp hc0, sq_nonneg ((p:ℝ) * c)]
    linarith [h2 ▸ h1]
  refine ⟨2 * p, by omega, ?_⟩
  have hrn : r ^ (2 * p) = 1 / s ^ (2 * p) := by
    rw [hs, div_pow, one_pow, one_div, one_div, inv_inv]
  rw [hrn, mul_one_div, div_lt_one (by positivity)]
  push_cast
  linarith [hkey]

/-- **Tail-class separation.**  A heavy-tailed profile outgrows every
geometric profile by an arbitrary *factor*: for each `C` there is a gate `τ`
at which the heavy knee is at least `C` times the geometric knee.  Hence
across tail classes the "tax" is not a bounded multiplier at all. -/
theorem heavy_vs_geom_unbounded {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (C : ℕ) :
    ∃ τ : ℝ, 0 < τ ∧ τ < 1 ∧ C * kstar (geom r) τ ≤ kstar heavy τ := by
  obtain ⟨n, hnpos, hn⟩ := exists_pow_lt_inv_linear hr0 hr1 C
  refine ⟨1 - r ^ n, ?_, ?_, ?_⟩
  · have : r ^ n < 1 := pow_lt_one₀ hr0.le hr1 hnpos.ne'
    linarith
  · have : (0:ℝ) < r ^ n := pow_pos hr0 n
    linarith
  · have hrn : (0:ℝ) < r ^ n := pow_pos hr0 n
    -- the geometric knee is exactly `n`
    have hgeo : kstar (geom r) (1 - r ^ n) = n := by
      rw [kstar_geom]
      simpa using kgeom_pow_self hr0 hr1 n
    -- the heavy knee is at least `C * n`
    have hne : {k | (1 - r ^ n) ≤ retained heavy k}.Nonempty := by
      obtain ⟨k, hk⟩ := exists_nat_gt (1 / r ^ n)
      refine ⟨k, ?_⟩
      have hkpos : (0:ℝ) < (k:ℝ) + 1 := by positivity
      have h1 : 1 / r ^ n < (k:ℝ) + 1 := by linarith
      have h2 : 1 / ((k:ℝ) + 1) < r ^ n := by
        rw [div_lt_iff₀ hkpos]
        rw [div_lt_iff₀ hrn] at h1
        nlinarith
      have : (1 - r ^ n) ≤ (k:ℝ) / ((k:ℝ) + 1) := by
        rw [le_div_iff₀ hkpos]
        rw [div_lt_iff₀ hkpos] at h2
        nlinarith
      simpa [Set.mem_setOf_eq, retained_heavy] using this
    have hlow : C * n ≤ kstar heavy (1 - r ^ n) := by
      refine le_kstar_of_forall_lt heavy _ hne ?_
      intro j hj
      have hj1 : ((j:ℝ) + 1) ≤ (C : ℝ) * n := by
        have : (j : ℝ) + 1 ≤ ((C * n : ℕ) : ℝ) := by exact_mod_cast hj
        simpa using this
      have hjpos : (0:ℝ) < (j:ℝ) + 1 := by positivity
      have hlt : ((j:ℝ) + 1) * r ^ n < 1 := by
        have := mul_le_mul_of_nonneg_right hj1 hrn.le
        calc ((j:ℝ) + 1) * r ^ n ≤ (C:ℝ) * n * r ^ n := this
        _ < 1 := hn
      rw [retained_heavy]
      simp only [not_le]
      rw [div_lt_iff₀ hjpos] at *
      nlinarith
    rw [hgeo]
    exact hlow

end Physics.AttentionKnee