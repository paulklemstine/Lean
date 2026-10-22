import Mathlib

/-!
# The local-win boundary for rho cycle detectors: Brent vs Floyd, counted vs uncounted

A rho-shaped sequence `x : ℕ → α` with tail `μ` and period `λ ≥ 1` (`IsRho x μ λ`) is one
that is injective on `[0, μ + λ)` and `λ`-periodic from index `μ` on.  This is exactly the
shape of the orbit of any map of a finite set (and of the reduced Pollard-rho walk mod `p`).

We model the two classical cycle detectors with exact operation counts in two channels:

* **counted channel** — map evaluations (group operations / modular multiplications);
* **uncounted channel** — comparisons (the gcds of Pollard rho).

**Floyd** steps `(xᵢ, x₂ᵢ)`: 3 evaluations and 1 comparison per index `i`, stopping at the
first `i > 0` with `xᵢ = x₂ᵢ` (`floydIdx`).

**Brent** (power-of-two variant) saves `x_{2^k − 1}` in round `k` and compares it with
`x_{2^k − 1 + j}` for `j = 1, …, 2^k`: 1 evaluation and 1 comparison per step, stopping in the
first round `K` with `μ < 2^K` and `λ ≤ 2^K`, at `j = λ` (`brentRound`).

## Main results

* `IsRho.eq_iff` — exact collision law: for `i ≤ j`, `xᵢ = xⱼ ↔ i = j ∨ (μ ≤ i ∧ λ ∣ j − i)`.
* `floyd_match_iff`, `floydIdx_first` — Floyd's stopping index is characterised exactly.
* `brent_match_iff`, `brent_first` — Brent's stopping point `(K, λ)` is characterised exactly
  and is lexicographically first.
* `brentEvals_lt_floydEvals` — **the survivor**: Brent uses *strictly fewer* map evaluations
  than Floyd on *every* rho shape (indeed `brentEvals + 1 ≤ 2·F + λ ≤ 3·F`).  The ratio
  `brent/floyd` in the counted channel can never cross `1`.
* `floydComps_le_brentComps` — **the uncounted channel moves the other way**: Brent never uses
  fewer comparisons than Floyd.
* `wall_brent_lt_iff` — the boundary law as an exact identity in a linear cost model
  `W = a·evals + b·comps`.
* `exists_brent_loses_wallclock` — **the boundary is sharp**: for any positive comparison cost
  `b` and any evaluation cost `a ≥ 0` there is a (pure-cycle) rho shape on which Brent is
  *slower* than Floyd in the wall-clock model, even though it wins the counted channel.
-/

namespace RhoBoundary

/-! ## Rho-shaped sequences -/

/-- `x` is rho-shaped with tail `mu` and period `lam`. -/
structure IsRho {α : Type*} (x : ℕ → α) (mu lam : ℕ) : Prop where
  lam_pos : 0 < lam
  periodic : ∀ i, mu ≤ i → x (i + lam) = x i
  inj : ∀ i j, i < mu + lam → j < mu + lam → x i = x j → i = j

variable {α : Type*} {x : ℕ → α} {mu lam : ℕ}

/-- The canonical representative of an index on the rho. -/
def red (mu lam i : ℕ) : ℕ := if i < mu then i else mu + (i - mu) % lam

lemma IsRho.periodic_mul (h : IsRho x mu lam) (i : ℕ) (hi : mu ≤ i) (m : ℕ) :
    x (i + lam * m) = x i := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [Nat.mul_succ, ← Nat.add_assoc, h.periodic _ (by omega), ih]

lemma IsRho.eq_red (h : IsRho x mu lam) (i : ℕ) : x i = x (red mu lam i) := by
  unfold red
  split_ifs with hi
  · rfl
  · have := h.periodic_mul (mu + (i - mu) % lam) (by omega) ((i - mu) / lam)
    rw [Nat.add_assoc, Nat.mod_add_div] at this
    rw [← this]; congr 1; omega

lemma red_lt (h : IsRho x mu lam) (i : ℕ) : red mu lam i < mu + lam := by
  unfold red
  split_ifs with hi
  · omega
  · have := Nat.mod_lt (i - mu) h.lam_pos; omega

/-- **Exact collision law** of a rho-shaped sequence. -/
theorem IsRho.eq_iff (h : IsRho x mu lam) {i j : ℕ} (hij : i ≤ j) :
    x i = x j ↔ i = j ∨ (mu ≤ i ∧ lam ∣ j - i) := by
  rw [h.eq_red i, h.eq_red j]
  have hr : x (red mu lam i) = x (red mu lam j) ↔ red mu lam i = red mu lam j :=
    ⟨h.inj _ _ (red_lt h i) (red_lt h j), fun e => by rw [e]⟩
  rw [hr]
  unfold red
  by_cases hi : i < mu
  · by_cases hj : j < mu
    · simp [hi, hj]
    · simp only [hi, hj, if_true, if_false]; omega
  · have hj : ¬ j < mu := by omega
    simp only [hi, hj, if_false]
    constructor
    · intro e
      right
      refine ⟨by omega, ?_⟩
      have e' : (i - mu) % lam = (j - mu) % lam := by omega
      have := (Nat.modEq_iff_dvd' (show i - mu ≤ j - mu by omega)).1 e'
      rwa [show j - mu - (i - mu) = j - i by omega] at this
    · rintro (e | ⟨-, d⟩)
      · subst e; rfl
      · have : (i - mu) % lam = (j - mu) % lam := by
          apply (Nat.modEq_iff_dvd' (show i - mu ≤ j - mu by omega)).2
          rwa [show j - mu - (i - mu) = j - i by omega]
        omega

/-! ## Floyd -/

lemma floyd_exists (lam_pos : 0 < lam) : ∃ i, 0 < i ∧ mu ≤ i ∧ lam ∣ i :=
  ⟨lam * (mu + 1), Nat.mul_pos lam_pos (by omega),
    by nlinarith, dvd_mul_right _ _⟩

/-- Floyd's stopping index: the first `i > 0` with `μ ≤ i` and `λ ∣ i`. -/
noncomputable def floydIdx (mu lam : ℕ) : ℕ := by
  classical
  exact if hl : 0 < lam then Nat.find (floyd_exists (mu := mu) hl) else 0

lemma floydIdx_spec (hl : 0 < lam) :
    0 < floydIdx mu lam ∧ mu ≤ floydIdx mu lam ∧ lam ∣ floydIdx mu lam := by
  classical
  unfold floydIdx; rw [dif_pos hl]
  exact Nat.find_spec (floyd_exists (mu := mu) hl)

lemma floydIdx_min (hl : 0 < lam) {i : ℕ} (hi : 0 < i) (hmu : mu ≤ i) (hd : lam ∣ i) :
    floydIdx mu lam ≤ i := by
  classical
  unfold floydIdx; rw [dif_pos hl]
  exact Nat.find_min' _ ⟨hi, hmu, hd⟩

/-- A Floyd test at `i > 0` succeeds iff `μ ≤ i` and `λ ∣ i`. -/
theorem floyd_match_iff (h : IsRho x mu lam) {i : ℕ} (hi : 0 < i) :
    x i = x (2 * i) ↔ mu ≤ i ∧ lam ∣ i := by
  rw [h.eq_iff (by omega), show 2 * i - i = i by omega]
  constructor
  · rintro (e | hh)
    · omega
    · exact hh
  · exact Or.inr

/-- **Floyd's detector stops exactly at `floydIdx`.** -/
theorem floydIdx_first (h : IsRho x mu lam) :
    0 < floydIdx mu lam ∧ x (floydIdx mu lam) = x (2 * floydIdx mu lam) ∧
      ∀ i, 0 < i → i < floydIdx mu lam → x i ≠ x (2 * i) := by
  obtain ⟨h0, h1, h2⟩ := floydIdx_spec (mu := mu) h.lam_pos
  refine ⟨h0, (floyd_match_iff h h0).2 ⟨h1, h2⟩, fun i hi hlt e => ?_⟩
  obtain ⟨a, b⟩ := (floyd_match_iff h hi).1 e
  have := floydIdx_min h.lam_pos hi a b
  omega

lemma lam_le_floydIdx (hl : 0 < lam) : lam ≤ floydIdx mu lam := by
  obtain ⟨h0, -, h2⟩ := floydIdx_spec (mu := mu) hl
  exact Nat.le_of_dvd h0 h2

/-- Floyd stops within one period of the tail end. -/
lemma floydIdx_le (hl : 0 < lam) (hmu : 0 < mu) : floydIdx mu lam + 1 ≤ mu + lam := by
  -- the multiple `lam * ((mu + lam - 1) / lam)` lies in `[mu, mu + lam - 1]`
  set q := (mu + lam - 1) / lam
  have hq1 : lam * q ≤ mu + lam - 1 := Nat.mul_div_le _ _
  have hq2 : mu + lam - 1 < lam * (q + 1) := by
    have := Nat.lt_mul_div_succ (mu + lam - 1) hl
    simpa [q, Nat.mul_comm] using this
  have hmuq : mu ≤ lam * q := by rw [mul_add, mul_one] at hq2; omega
  have := floydIdx_min hl (i := lam * q) (by omega) hmuq (dvd_mul_right _ _)
  omega

lemma floydIdx_zero_tail (hl : 0 < lam) : floydIdx 0 lam = lam := by
  have h1 := lam_le_floydIdx (mu := 0) hl
  have h2 := floydIdx_min (mu := 0) hl (i := lam) hl (Nat.zero_le _) dvd_rfl
  omega

/-- Floyd evaluations: tortoise 1 + hare 2 per index. -/
noncomputable def floydEvals (mu lam : ℕ) : ℕ := 3 * floydIdx mu lam
/-- Floyd comparisons: one per index. -/
noncomputable def floydComps (mu lam : ℕ) : ℕ := floydIdx mu lam

/-! ## Brent -/

lemma brent_exists : ∃ k, mu < 2 ^ k ∧ lam ≤ 2 ^ k :=
  ⟨mu + lam, by
    have := Nat.lt_two_pow_self (n := mu + lam)
    constructor <;> omega⟩

/-- Brent's stopping round: the first `K` with `μ < 2^K` and `λ ≤ 2^K`. -/
noncomputable def brentRound (mu lam : ℕ) : ℕ := by
  classical
  exact Nat.find (brent_exists (mu := mu) (lam := lam))

lemma brentRound_spec : mu < 2 ^ brentRound mu lam ∧ lam ≤ 2 ^ brentRound mu lam := by
  classical
  unfold brentRound
  exact Nat.find_spec (brent_exists (mu := mu) (lam := lam))

lemma brentRound_min {k : ℕ} (hk : k < brentRound mu lam) : ¬ (mu < 2 ^ k ∧ lam ≤ 2 ^ k) := by
  classical
  unfold brentRound at hk
  exact Nat.find_min _ hk

/-- A Brent test in round `k` at offset `1 ≤ j` succeeds iff `μ < 2^k` and `λ ∣ j`. -/
theorem brent_match_iff (h : IsRho x mu lam) (k : ℕ) {j : ℕ} (hj : 0 < j) :
    x (2 ^ k - 1) = x (2 ^ k - 1 + j) ↔ mu < 2 ^ k ∧ lam ∣ j := by
  have hp := Nat.one_le_two_pow (n := k)
  rw [h.eq_iff (by omega), show 2 ^ k - 1 + j - (2 ^ k - 1) = j by omega]
  constructor
  · rintro (e | ⟨a, b⟩)
    · omega
    · exact ⟨by omega, b⟩
  · rintro ⟨a, b⟩; exact Or.inr ⟨by omega, b⟩

/-- **Brent's detector stops exactly at round `K = brentRound`, offset `λ`**, and no earlier
test (any `j ≤ 2^k` in an earlier round, or `j < λ` in round `K`) succeeds. -/
theorem brent_first (h : IsRho x mu lam) :
    x (2 ^ brentRound mu lam - 1) = x (2 ^ brentRound mu lam - 1 + lam) ∧
    (∀ k < brentRound mu lam, ∀ j, 0 < j → j ≤ 2 ^ k → x (2 ^ k - 1) ≠ x (2 ^ k - 1 + j)) ∧
    (∀ j, 0 < j → j < lam →
        x (2 ^ brentRound mu lam - 1) ≠ x (2 ^ brentRound mu lam - 1 + j)) := by
  obtain ⟨s1, s2⟩ := brentRound_spec (mu := mu) (lam := lam)
  refine ⟨(brent_match_iff h _ h.lam_pos).2 ⟨s1, dvd_rfl⟩, ?_, ?_⟩
  · intro k hk j hj hjk e
    obtain ⟨a, b⟩ := (brent_match_iff h k hj).1 e
    exact brentRound_min hk ⟨a, (Nat.le_of_dvd hj b).trans hjk⟩
  · intro j hj hjl e
    obtain ⟨-, b⟩ := (brent_match_iff h _ hj).1 e
    have := Nat.le_of_dvd hj b
    omega

/-- Brent evaluations: every iterate up to index `2^K − 1 + λ` is computed once. -/
noncomputable def brentEvals (mu lam : ℕ) : ℕ := 2 ^ brentRound mu lam - 1 + lam
/-- Brent comparisons: all `2^k` tests of each completed round `k < K`, then `λ` tests. -/
noncomputable def brentComps (mu lam : ℕ) : ℕ :=
  (∑ k ∈ Finset.range (brentRound mu lam), 2 ^ k) + lam

lemma geom_two (K : ℕ) : (∑ k ∈ Finset.range K, 2 ^ k) + 1 = 2 ^ K := by
  induction K with
  | zero => simp
  | succ K ih => rw [Finset.sum_range_succ, pow_succ]; omega

/-- Brent does exactly one comparison per evaluation. -/
theorem brentComps_eq_brentEvals : brentComps mu lam = brentEvals mu lam := by
  unfold brentComps brentEvals
  have := geom_two (brentRound mu lam)
  omega

/-! ## The boundary -/

/-- **The survivor (sharp form).**  On every rho shape, Brent's evaluation count satisfies
`brentEvals + 1 ≤ 2·F + λ`, where `F` is Floyd's stopping index. -/
theorem brentEvals_succ_le (hl : 0 < lam) :
    brentEvals mu lam + 1 ≤ 2 * floydIdx mu lam + lam := by
  unfold brentEvals
  have hF1 := lam_le_floydIdx (mu := mu) hl
  obtain ⟨hF0, hF2, -⟩ := floydIdx_spec (mu := mu) hl
  obtain ⟨s1, s2⟩ := brentRound_spec (mu := mu) (lam := lam)
  rcases Nat.eq_zero_or_pos (brentRound mu lam) with hK | hK
  · rw [hK] at s1 s2 ⊢; simp at s1 s2 ⊢; omega
  · have hmin := brentRound_min (mu := mu) (lam := lam) (k := brentRound mu lam - 1) (by omega)
    have hpow : 2 ^ brentRound mu lam = 2 * 2 ^ (brentRound mu lam - 1) := by
      rw [← pow_succ']; congr 1; omega
    rw [hpow]
    have := Nat.one_le_two_pow (n := brentRound mu lam - 1)
    by_cases hA : mu < 2 ^ (brentRound mu lam - 1)
    · have hB : 2 ^ (brentRound mu lam - 1) < lam := by
        by_contra hc; exact hmin ⟨hA, by omega⟩
      omega
    · omega

/-- **The survivor.**  Brent uses strictly fewer map evaluations (the counted channel) than
Floyd on *every* rho shape: `brent/floyd < 1` always. -/
theorem brentEvals_lt_floydEvals (hl : 0 < lam) : brentEvals mu lam < floydEvals mu lam := by
  have := brentEvals_succ_le (mu := mu) hl
  have := lam_le_floydIdx (mu := mu) hl
  unfold floydEvals; omega

/-- **The uncounted channel moves the other way.**  Brent never uses fewer comparisons than
Floyd. -/
theorem floydComps_le_brentComps (hl : 0 < lam) : floydComps mu lam ≤ brentComps mu lam := by
  rw [brentComps_eq_brentEvals]
  unfold floydComps brentEvals
  obtain ⟨s1, -⟩ := brentRound_spec (mu := mu) (lam := lam)
  rcases Nat.eq_zero_or_pos mu with h0 | h0
  · subst h0; rw [floydIdx_zero_tail hl]; omega
  · have := floydIdx_le (mu := mu) hl h0; omega

/-- Wall-clock cost in the linear two-channel model. -/
def wall (a b : ℝ) (evals comps : ℕ) : ℝ := a * evals + b * comps

/-- **The boundary law as an identity.**  Brent beats Floyd in wall clock iff the counted
saving, priced at `a`, exceeds the uncounted overrun, priced at `b`. -/
theorem wall_brent_lt_iff (a b : ℝ) :
    wall a b (brentEvals mu lam) (brentComps mu lam) < wall a b (floydEvals mu lam) (floydComps mu lam)
      ↔ b * ((brentComps mu lam : ℝ) - floydComps mu lam)
          < a * ((floydEvals mu lam : ℝ) - brentEvals mu lam) := by
  unfold wall; constructor <;> intro h <;> linarith

/-- Pure cycles of length `2^m + 1`: Brent stops in round `m + 1`. -/
lemma brentRound_pure_cycle (m : ℕ) : brentRound 0 (2 ^ m + 1) = m + 1 := by
  apply le_antisymm
  · classical
    unfold brentRound
    apply Nat.find_min'
    refine ⟨by positivity, ?_⟩
    rw [pow_succ]
    have := Nat.one_le_two_pow (n := m)
    omega
  · by_contra hc
    have hle : brentRound 0 (2 ^ m + 1) ≤ m := by omega
    obtain ⟨-, s2⟩ := brentRound_spec (mu := 0) (lam := 2 ^ m + 1)
    have := Nat.pow_le_pow_right (by norm_num : 1 ≤ 2) hle
    omega

/-- On those cycles the counted saving is exactly `3` evaluations while the uncounted overrun is
`2^(m+1) − 2` comparisons. -/
lemma pure_cycle_counts (m : ℕ) :
    floydEvals 0 (2 ^ m + 1) = 3 * (2 ^ m + 1) ∧ floydComps 0 (2 ^ m + 1) = 2 ^ m + 1 ∧
    brentEvals 0 (2 ^ m + 1) = 3 * 2 ^ m ∧ brentComps 0 (2 ^ m + 1) = 3 * 2 ^ m := by
  have hF := floydIdx_zero_tail (lam := 2 ^ m + 1) (by positivity)
  have hB : brentEvals 0 (2 ^ m + 1) = 3 * 2 ^ m := by
    unfold brentEvals; rw [brentRound_pure_cycle m, pow_succ]
    have h1 := Nat.one_le_two_pow (n := m)
    generalize 2 ^ m = t at *; omega
  refine ⟨by unfold floydEvals; rw [hF], by unfold floydComps; rw [hF], hB, ?_⟩
  rw [brentComps_eq_brentEvals, hB]

/-- **The boundary is sharp.**  For any positive comparison cost `b` and any evaluation cost
`a ≥ 0`, some (tail-free) rho shape makes Brent strictly slower than Floyd in wall clock —
although Brent wins the counted channel on it (`brentEvals_lt_floydEvals`).  A local win stated
in the counted channel alone does not survive once the uncounted channel is priced in. -/
theorem exists_brent_loses_wallclock (a b : ℝ) (ha : 0 ≤ a) (hb : 0 < b) :
    ∃ lam, 0 < lam ∧ brentEvals 0 lam < floydEvals 0 lam ∧
      wall a b (floydEvals 0 lam) (floydComps 0 lam)
        < wall a b (brentEvals 0 lam) (brentComps 0 lam) := by
  obtain ⟨m, hm⟩ := pow_unbounded_of_one_lt ((3 * a + 3 * b) / b + 2) (by norm_num : (1 : ℝ) < 2)
  refine ⟨2 ^ m + 1, by positivity, brentEvals_lt_floydEvals (by positivity), ?_⟩
  obtain ⟨e1, e2, e3, e4⟩ := pure_cycle_counts m
  unfold wall
  rw [e1, e2, e3, e4]
  push_cast
  have hdiv : (3 * a + 3 * b) / b * b = 3 * a + 3 * b := div_mul_cancel₀ _ hb.ne'
  have : (3 * a + 3 * b) < b * 2 ^ m := by nlinarith
  nlinarith

end RhoBoundary