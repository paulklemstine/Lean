import Novelty.AttentionBudgetIncrement

/-!
# Where does an additive key-increment come from? (NET-67, structural layer)

`Novelty.AttentionBudgetIncrement` fixes the two *measured* budget laws of
NET-67 and audits the verdict at the level of arithmetic.  This file asks the
structural question behind the measurement:

> which attention-weight profiles can produce a knee that grows by a **fixed
> number of keys per context doubling**?

We work with the *retention curve* of a sorted attention profile
`p : ℕ → ℝ` — `retained p k = ∑_{i<k} p i` — and its **knee**
`knee p τ = sInf {k | τ ≤ retained p k}`, the smallest number of retained keys
whose mass reaches the drift-assert threshold `τ`.  Section 1 develops the
general theory (monotonicity, the defining inequalities, monotonicity in `τ`
and in the profile).

Section 2 computes everything for the truncated geometric profile
`geoW r n i = (1-r) rⁱ / (1 - rⁿ)` on a context of `n` keys, and proves the
main negative result:

* `knee_geoW_le` / `knee_geoW_bounded` — for a **fixed** decay rate `r` the knee
  is bounded by `⌈log(1-τ)/log r⌉`, *uniformly in the context length* `n`;
* `knee_geoW_eventually_constant` — hence, along contexts `n = 2^j`, the knee is
  monotone and bounded, so its increments are eventually `0`;
* `no_fixed_geometric_profile_matches_kneeSmall` — consequently **no** fixed
  geometric attention profile can reproduce the measured `+4`-keys-per-doubling
  law of the 0.5B model.  A persistent positive increment is not a property of
  a distribution; it is a property of a *family* of distributions whose decay
  rate degrades with context;
* `knee_truncNorm_bounded` / `no_fixed_profile_matches_kneeSmall` — and the
  obstruction is not the geometric ansatz but summability: **no** fixed profile,
  renormalised to the context, has a context-dependent knee.

Section 3 supplies the family that does work.  With `λ` the decay rate, the
exact key requirement for a tail budget `δ` is `kneeCts λ δ = log(1/δ)/λ`
(`exp_tail_le_iff` — this is a genuine equivalence, not a heuristic).  Then:

* `kneeCts_lamAt` — if the rate degrades as `λ_j = λ₀/(j+1)` over `j` context
  doublings, the knee is exactly affine in `j` with slope `log(1/δ)/λ₀`;
* `scale_halves_increment` — doubling `λ₀` (a *more peaked* model at every
  context) halves the increment.  This is the NET-67 verdict, derived;
* `rate_of_increment` — the converse: an affine knee law with slope `s` *forces*
  `λ_j = (log(1/δ)/s)/(j+1)`.  So "additive keys per doubling" and
  "decay rate ∝ 1/log(context)" are the same statement;
* `calibration_small`, `calibration_large`, `calibration_ratio` — the measured
  pair `(+4, +2)` is realised by `λ₀ = 1` and `λ₀ = 2` at tail budget
  `δ = e⁻⁴`, i.e. *the 1.5B model's attention is exactly twice as peaked*.
-/

namespace Catalog.Novelty.AttentionRetentionKnee

open Finset Catalog.Novelty.AttentionBudgetIncrement

/-! ### 1. Retention curves and their knee -/

/-- Mass retained by the top `k` keys of a *sorted* attention profile `p`
(`p i` is the `i`-th largest attention weight). -/
def retained (p : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ range k, p i

@[simp] theorem retained_zero (p : ℕ → ℝ) : retained p 0 = 0 := by simp [retained]

theorem retained_succ (p : ℕ → ℝ) (k : ℕ) : retained p (k + 1) = retained p k + p k := by
  simp [retained, Finset.sum_range_succ]

/-- Retention is monotone in the number of kept keys. -/
theorem retained_mono {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) : Monotone (retained p) := by
  intro a b hab
  have hsub : Finset.range a ⊆ Finset.range b := Finset.range_subset_range.mpr hab
  exact Finset.sum_le_sum_of_subset_of_nonneg hsub fun i _ _ => hp i

/-- The **knee**: the least number of retained keys whose mass reaches `τ`.
(`sInf ∅ = 0` in `ℕ`; every statement below carries the relevant reachability
hypothesis, so the junk value is never used.) -/
noncomputable def knee (p : ℕ → ℝ) (tau : ℝ) : ℕ := sInf {k | tau ≤ retained p k}

/-- Any `k` reaching the threshold bounds the knee. -/
theorem knee_le {p : ℕ → ℝ} {tau : ℝ} {k : ℕ} (hk : tau ≤ retained p k) : knee p tau ≤ k :=
  Nat.sInf_le hk

/-- The knee reaches the threshold, as soon as some `k` does. -/
theorem knee_spec {p : ℕ → ℝ} {tau : ℝ} (h : ∃ k, tau ≤ retained p k) :
    tau ≤ retained p (knee p tau) :=
  Nat.sInf_mem h

/-- Below the knee the threshold is missed: the knee is a genuine phase change. -/
theorem lt_knee {p : ℕ → ℝ} {tau : ℝ} {k : ℕ} (hk : k < knee p tau) :
    retained p k < tau :=
  not_le.1 fun h => absurd (knee_le h) (not_le.2 hk)

/-- A stricter drift-assert needs at least as many keys. -/
theorem knee_mono_tau {p : ℕ → ℝ} {tau tau' : ℝ} (h : tau ≤ tau')
    (hex : ∃ k, tau' ≤ retained p k) : knee p tau ≤ knee p tau' :=
  knee_le (h.trans (knee_spec hex))

/-- A pointwise heavier head needs no more keys. -/
theorem knee_mono_profile {p q : ℕ → ℝ} {tau : ℝ} (hpq : ∀ k, retained p k ≤ retained q k)
    (hex : ∃ k, tau ≤ retained p k) : knee q tau ≤ knee p tau :=
  knee_le ((knee_spec hex).trans (hpq _))

/-! ### 2. A fixed geometric profile has a context-independent knee -/

/-- The truncated geometric attention profile on a context of `n` keys:
`geoW r n i = (1-r) rⁱ / (1-rⁿ)`, a probability vector on `{0,…,n-1}`. -/
noncomputable def geoW (r : ℝ) (n : ℕ) (i : ℕ) : ℝ := (1 - r) * r ^ i / (1 - r ^ n)

/-- Exact retention of the truncated geometric profile: `(1-r^k)/(1-r^n)`. -/
theorem retained_geoW {r : ℝ} (hr : r ≠ 1) (n k : ℕ) :
    retained (geoW r n) k = (1 - r ^ k) / (1 - r ^ n) := by
  have hr1 : r - 1 ≠ 0 := sub_ne_zero.2 hr
  have key : (1 - r) * ((r ^ k - 1) / (r - 1)) = 1 - r ^ k := by
    field_simp
    ring
  simp only [retained, geoW]
  rw [← Finset.sum_div, ← Finset.mul_sum, geom_sum_eq hr, key]

/-- Sanity check: the profile is a probability vector — all `n` keys carry the
whole mass. -/
theorem retained_geoW_full {r : ℝ} (hr : r ≠ 1) {n : ℕ} (hn : r ^ n ≠ 1) :
    retained (geoW r n) n = 1 := by
  rw [retained_geoW hr]
  exact div_self (sub_ne_zero.2 (Ne.symm hn))

/-- For `0 < r < 1` the profile is nonnegative. -/
theorem geoW_nonneg {r : ℝ} (h0 : 0 < r) (h1 : r < 1) (n i : ℕ) : 0 ≤ geoW r n i := by
  have hpow : r ^ n ≤ 1 := pow_le_one₀ h0.le h1.le
  have hden : 0 ≤ 1 - r ^ n := by linarith
  have hnum : 0 ≤ (1 - r) * r ^ i := mul_nonneg (by linarith) (pow_nonneg h0.le i)
  exact div_nonneg hnum hden

/-- **Uniform retention bound.**  If the geometric tail after `k` keys is below
the slack `1 - τ`, then `k` keys already pass the drift-assert — *whatever the
context length* `n`. -/
theorem retained_geoW_ge {r tau : ℝ} (h0 : 0 < r) (h1 : r < 1) {n k : ℕ} (hn : 0 < n)
    (hk : r ^ k ≤ 1 - tau) : tau ≤ retained (geoW r n) k := by
  have hrne : r ≠ 1 := ne_of_lt h1
  have hpn : r ^ n < 1 := pow_lt_one₀ h0.le h1 hn.ne'
  have hden : (0 : ℝ) < 1 - r ^ n := by linarith
  have hk1 : r ^ k ≤ 1 := pow_le_one₀ h0.le h1.le
  rw [retained_geoW hrne, le_div_iff₀ hden]
  rcases le_total 0 tau with ht | ht
  · nlinarith [mul_nonneg ht (pow_nonneg h0.le n)]
  · nlinarith [mul_nonneg (neg_nonneg.2 ht) hden.le]

/-- The knee of a truncated geometric profile is bounded by any `k` whose tail
`r^k` fits in the slack `1 - τ`; the bound is independent of the context. -/
theorem knee_geoW_le {r tau : ℝ} (h0 : 0 < r) (h1 : r < 1) {n k : ℕ} (hn : 0 < n)
    (hk : r ^ k ≤ 1 - tau) : knee (geoW r n) tau ≤ k :=
  knee_le (retained_geoW_ge h0 h1 hn hk)

/-- The explicit key budget: `⌈log(1-τ)/log r⌉` keys have tail below the slack.
This is the exact analogue of the measured knee, and it does **not** depend on
the context length. -/
theorem geoW_ceil_bound {r tau : ℝ} (h0 : 0 < r) (h1 : r < 1) (htau : tau < 1) :
    r ^ (⌈Real.log (1 - tau) / Real.log r⌉₊) ≤ 1 - tau := by
  set K : ℕ := ⌈Real.log (1 - tau) / Real.log r⌉₊ with hK
  have hlogr : Real.log r < 0 := Real.log_neg h0 h1
  have hslack : (0 : ℝ) < 1 - tau := by linarith
  have hqK : Real.log (1 - tau) / Real.log r ≤ (K : ℝ) := Nat.le_ceil _
  have hmul : (K : ℝ) * Real.log r ≤ (Real.log (1 - tau) / Real.log r) * Real.log r :=
    mul_le_mul_of_nonpos_right hqK hlogr.le
  rw [div_mul_cancel₀ _ (ne_of_lt hlogr)] at hmul
  have hpowpos : (0 : ℝ) < r ^ K := pow_pos h0 K
  have hlogpow : Real.log (r ^ K) = (K : ℝ) * Real.log r := by
    rw [Real.log_pow]
  have hle : Real.log (r ^ K) ≤ Real.log (1 - tau) := by rw [hlogpow]; exact hmul
  exact (Real.log_le_log_iff hpowpos hslack).1 hle

/-- **The knee of a fixed geometric profile is bounded, uniformly in context.** -/
theorem knee_geoW_bounded {r tau : ℝ} (h0 : 0 < r) (h1 : r < 1) (htau : tau < 1) :
    ∃ K : ℕ, ∀ n : ℕ, 0 < n → knee (geoW r n) tau ≤ K :=
  ⟨⌈Real.log (1 - tau) / Real.log r⌉₊, fun _ hn =>
    knee_geoW_le h0 h1 hn (geoW_ceil_bound h0 h1 htau)⟩

/-- Retention at a fixed `k` degrades as the context grows: a longer context
dilutes the top-`k` mass. -/
theorem retained_geoW_antitone_context {r : ℝ} (h0 : 0 < r) (h1 : r < 1) {m n : ℕ}
    (hm : 0 < m) (hmn : m ≤ n) (k : ℕ) : retained (geoW r n) k ≤ retained (geoW r m) k := by
  have hrne : r ≠ 1 := ne_of_lt h1
  have hpm : r ^ n ≤ r ^ m := pow_le_pow_of_le_one h0.le h1.le hmn
  have hnum : (0 : ℝ) ≤ 1 - r ^ k := by
    have := pow_le_one₀ h0.le h1.le (n := k); linarith
  have hdm : (0 : ℝ) < 1 - r ^ m := by
    have := pow_lt_one₀ h0.le h1 hm.ne'; linarith
  have hdmn : (1 : ℝ) - r ^ m ≤ 1 - r ^ n := by linarith
  rw [retained_geoW hrne, retained_geoW hrne]
  exact div_le_div_of_nonneg_left hnum hdm hdmn

/-- Consequently the knee is monotone in the context length. -/
theorem knee_geoW_mono_context {r tau : ℝ} (h0 : 0 < r) (h1 : r < 1) (htau : tau < 1)
    {m n : ℕ} (hm : 0 < m) (hmn : m ≤ n) : knee (geoW r m) tau ≤ knee (geoW r n) tau := by
  refine knee_mono_profile (fun k => retained_geoW_antitone_context h0 h1 hm hmn k) ?_
  exact ⟨⌈Real.log (1 - tau) / Real.log r⌉₊,
    retained_geoW_ge h0 h1 (lt_of_lt_of_le hm hmn) (geoW_ceil_bound h0 h1 htau)⟩

/-- **A monotone bounded budget law is eventually flat.** -/
theorem eventually_constant_of_mono_bdd {K : ℕ → ℕ} (hmono : Monotone K) {B : ℕ}
    (hB : ∀ j, K j ≤ B) : ∃ j₀, ∀ j, j₀ ≤ j → K j = K j₀ := by
  have hne : (Set.range K).Nonempty := ⟨K 0, ⟨0, rfl⟩⟩
  have hbdd : BddAbove (Set.range K) := ⟨B, by rintro _ ⟨j, rfl⟩; exact hB j⟩
  obtain ⟨j₀, hj₀⟩ := Nat.sSup_mem hne hbdd
  refine ⟨j₀, fun j hj => le_antisymm ?_ (hmono hj)⟩
  rw [hj₀]
  exact le_csSup hbdd ⟨j, rfl⟩

/-- **Increments of a fixed geometric law die out.**  Along contexts `n = 2^j`
the knee is monotone and bounded, hence eventually constant: from some doubling
on it costs *zero* extra keys. -/
theorem knee_geoW_eventually_constant {r tau : ℝ} (h0 : 0 < r) (h1 : r < 1) (htau : tau < 1) :
    ∃ j₀, ∀ j, j₀ ≤ j → knee (geoW r (2 ^ j)) tau = knee (geoW r (2 ^ j₀)) tau := by
  obtain ⟨K, hK⟩ := knee_geoW_bounded h0 h1 htau
  refine eventually_constant_of_mono_bdd (K := fun j => knee (geoW r (2 ^ j)) tau) ?_ (B := K)
    (fun j => hK _ (by positivity))
  intro a b hab
  exact knee_geoW_mono_context h0 h1 htau (by positivity)
    (Nat.pow_le_pow_right (by norm_num) hab)

/-- **The negative result of NET-67's structural layer.**  No *fixed* geometric
attention profile — no matter its decay rate `r` or the drift threshold `τ` —
can reproduce the measured `16 + 4j` law of the 0.5B model.  A persistent
additive increment is impossible for a context-independent profile. -/
theorem no_fixed_geometric_profile_matches_kneeSmall :
    ¬ ∃ r tau : ℝ, 0 < r ∧ r < 1 ∧ tau < 1 ∧
        ∀ j : ℕ, knee (geoW r (2 ^ j)) tau = kneeSmall j := by
  rintro ⟨r, tau, h0, h1, htau, hmatch⟩
  obtain ⟨K, hK⟩ := knee_geoW_bounded h0 h1 htau
  have h := hK (2 ^ K) (by positivity)
  rw [hmatch K] at h
  simp only [kneeSmall] at h
  omega

/-! ### 2b. The no-go is not about geometric profiles: it holds for *any* fixed one -/

/-- Retention of a nonnegative profile is nonnegative. -/
theorem retained_nonneg {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (k : ℕ) : 0 ≤ retained p k :=
  Finset.sum_nonneg fun i _ => hp i

/-- A *fixed* attention profile `p`, renormalised to a context of `n` keys.
This is the general form of `geoW`: the only way a context length can enter a
fixed profile is through the normalising constant. -/
noncomputable def truncNorm (p : ℕ → ℝ) (n : ℕ) (i : ℕ) : ℝ := p i / retained p n

@[simp] theorem retained_truncNorm (p : ℕ → ℝ) (n k : ℕ) :
    retained (truncNorm p n) k = retained p k / retained p n := by
  simp [retained, truncNorm, Finset.sum_div]

/-- **General no-go.**  For *any* fixed summable attention profile the knee is
bounded uniformly in the context length.  Context-independence of the key
budget is therefore generic: it is not an artefact of the geometric ansatz, and
a measured increment that persists over octaves rules out the whole class. -/
theorem knee_truncNorm_bounded {p : ℕ → ℝ} {S tau : ℝ} (hp : ∀ i, 0 ≤ p i)
    (hS : Filter.Tendsto (retained p) Filter.atTop (nhds S)) (hSpos : 0 < S)
    (htau : tau < 1) :
    ∃ K : ℕ, ∀ n : ℕ, 0 < retained p n → knee (truncNorm p n) tau ≤ K := by
  have hmono : Monotone (retained p) := retained_mono hp
  have hle : ∀ n, retained p n ≤ S := fun n => hmono.ge_of_tendsto hS n
  have hlt : tau * S < S := by nlinarith
  obtain ⟨K, hK⟩ := (Filter.Tendsto.eventually_const_lt hlt hS).exists
  refine ⟨K, fun n hn => knee_le ?_⟩
  rw [retained_truncNorm, le_div_iff₀ hn]
  rcases le_total 0 tau with ht | ht
  · nlinarith [hle n]
  · nlinarith [retained_nonneg hp K, hn.le]

/-- **No fixed profile at all reproduces the measured `16 + 4j` law.**  This
strengthens `no_fixed_geometric_profile_matches_kneeSmall`: the obstruction is
summability, not the shape of the tail. -/
theorem no_fixed_profile_matches_kneeSmall {p : ℕ → ℝ} {S tau : ℝ} (hp : ∀ i, 0 ≤ p i)
    (hS : Filter.Tendsto (retained p) Filter.atTop (nhds S)) (hSpos : 0 < S)
    (htau : tau < 1) (hp1 : 0 < retained p 1) :
    ¬ ∀ j : ℕ, knee (truncNorm p (2 ^ j)) tau = kneeSmall j := by
  intro hmatch
  obtain ⟨K, hK⟩ := knee_truncNorm_bounded hp hS hSpos htau
  have hmono : Monotone (retained p) := retained_mono hp
  have hpos : 0 < retained p (2 ^ K) :=
    lt_of_lt_of_le hp1 (hmono (Nat.one_le_two_pow))
  have h := hK (2 ^ K) hpos
  rw [hmatch K] at h
  simp only [kneeSmall] at h
  omega

/-! ### 3. The family that does work: a rate degrading like `1 / log(context)` -/

/-- Keys needed to push an exponential attention tail with decay rate `λ` below
the budget `δ`. -/
noncomputable def kneeCts (lam delta : ℝ) : ℝ := Real.log (1 / delta) / lam

/-- **`kneeCts` is exact, not heuristic.**  For a tail `e^{-λk}` the budget `δ`
is met precisely when `k` reaches `kneeCts λ δ`. -/
theorem exp_tail_le_iff {lam delta k : ℝ} (hlam : 0 < lam) (hdelta : 0 < delta) :
    Real.exp (-(lam * k)) ≤ delta ↔ kneeCts lam delta ≤ k := by
  rw [← Real.le_log_iff_exp_le hdelta, kneeCts, one_div, Real.log_inv, div_le_iff₀ hlam]
  constructor <;> intro h <;> nlinarith

/-- Halving the decay rate doubles the key requirement. -/
theorem kneeCts_rate_halving (lam delta : ℝ) :
    kneeCts (lam / 2) delta = 2 * kneeCts lam delta := by
  simp only [kneeCts, div_div_eq_mul_div]
  ring

/-- Decay rate after `j` context doublings, when the rate degrades inversely
with the log of the context: `λ_j = λ₀ / (j+1)`. -/
noncomputable def lamAt (lam0 : ℝ) (j : ℕ) : ℝ := lam0 / (j + 1)

/-- **The additive law, derived.**  With `λ_j = λ₀/(j+1)` the key requirement is
exactly affine in the number of context doublings. -/
theorem kneeCts_lamAt {lam0 delta : ℝ} (hlam0 : lam0 ≠ 0) (j : ℕ) :
    kneeCts (lamAt lam0 j) delta = ((j : ℝ) + 1) * (Real.log (1 / delta) / lam0) := by
  have hj : ((j : ℝ) + 1) ≠ 0 := by positivity
  simp only [kneeCts, lamAt]
  field_simp

/-- The per-doubling increment is the constant `log(1/δ)/λ₀`. -/
theorem kneeCts_increment {lam0 delta : ℝ} (hlam0 : lam0 ≠ 0) (j : ℕ) :
    kneeCts (lamAt lam0 (j + 1)) delta - kneeCts (lamAt lam0 j) delta
      = Real.log (1 / delta) / lam0 := by
  rw [kneeCts_lamAt hlam0, kneeCts_lamAt hlam0]
  push_cast
  ring

/-- **SCALE-HALVES-THE-CONTEXT-INCREMENT, derived.**  A model whose attention is
twice as peaked at every context (`λ₀ ↦ 2λ₀`) has exactly half the
per-doubling key increment. -/
theorem scale_halves_increment {lam0 delta : ℝ} (hlam0 : lam0 ≠ 0) (j : ℕ) :
    kneeCts (lamAt (2 * lam0) (j + 1)) delta - kneeCts (lamAt (2 * lam0) j) delta
      = (kneeCts (lamAt lam0 (j + 1)) delta - kneeCts (lamAt lam0 j) delta) / 2 := by
  rw [kneeCts_increment (by simpa using hlam0), kneeCts_increment hlam0]
  field_simp

/-- **Converse: an additive law forces a `1/(j+1)` rate.**  If a family of decay
rates produces a knee that is affine in the number of doublings with slope `s`,
then the rates are exactly `λ_j = (log(1/δ)/s)/(j+1)`.  "Additive keys per
context doubling" and "decay rate inversely proportional to log context" are
the same hypothesis. -/
theorem rate_of_increment {delta s : ℝ} (hs : 0 < s) {lam : ℕ → ℝ}
    (hlam : ∀ j, lam j ≠ 0)
    (haff : ∀ j : ℕ, kneeCts (lam j) delta = s * ((j : ℝ) + 1)) (j : ℕ) :
    lam j = (Real.log (1 / delta) / s) / ((j : ℝ) + 1) := by
  have hj : ((j : ℝ) + 1) ≠ 0 := by positivity
  have h := haff j
  simp only [kneeCts] at h
  rw [div_eq_iff (hlam j)] at h
  rw [h]
  field_simp

/-! ### 4. Calibration against the NET-67 measurement -/

/-- With tail budget `δ = e⁻⁴` and base rate `λ₀ = 1`, the derived increment is
exactly the measured `+4` keys per doubling of the 0.5B model. -/
theorem calibration_small (j : ℕ) :
    kneeCts (lamAt 1 (j + 1)) (Real.exp (-4)) - kneeCts (lamAt 1 j) (Real.exp (-4))
      = ((kneeSmall (j + 1) : ℝ) - kneeSmall j) := by
  rw [kneeCts_increment (by norm_num)]
  rw [one_div, ← Real.exp_neg, Real.log_exp]
  simp only [kneeSmall]
  push_cast
  ring

/-- With the same tail budget and the doubled rate `λ₀ = 2`, the derived
increment is exactly the measured `+2` keys per doubling of the 1.5B model
(past its hinge). -/
theorem calibration_large (j : ℕ) (hj : 1 ≤ j) :
    kneeCts (lamAt 2 (j + 1)) (Real.exp (-4)) - kneeCts (lamAt 2 j) (Real.exp (-4))
      = ((kneeLarge (j + 1) : ℝ) - kneeLarge j) := by
  rw [kneeCts_increment (by norm_num)]
  rw [one_div, ← Real.exp_neg, Real.log_exp]
  rw [kneeLarge_eq _ (by omega), kneeLarge_eq _ hj]
  push_cast
  ring

/-- **The calibrated scale law.**  The two measured increments are realised by
base rates in ratio `2 : 1` — the larger model's attention is exactly twice as
peaked per unit of log-context. -/
theorem calibration_ratio :
    (Real.log (1 / Real.exp (-4)) / 1) = 2 * (Real.log (1 / Real.exp (-4)) / 2) ∧
    (Real.log (1 / Real.exp (-4)) / 1) = 4 := by
  rw [one_div, ← Real.exp_neg, Real.log_exp]
  norm_num

end Catalog.Novelty.AttentionRetentionKnee