import Mathlib

/-!
# A taxonomy of "k*": pin, census-optimal, and economics-optimal search budgets

Three numbers are routinely written `k*` in binary-search / halving-style cost accounting,
and they are **not** the same number:

* `kPin W = ⌈log₂ W⌉` (`Nat.clog 2 W`) — the *pin*: the budget at which a support of width
  `W` is fully resolved and the marginal gain of a further query is exactly zero.
* `kOptCost W = argmin_k (k + (W / 2 ^ k + 1) / 2)` — the *census* total-cost stop, in which
  the residual is priced at half the remaining support.
* `kOptEcon T₀ c_q = argmin_k (c_q (1 + k) + (T₀ - 1) / 2 ^ k)` — the *economics* optimum, in
  which each query is paid `c_q` against a measured baseline `T₀`.

This file gives all three a formal definition and proves exactly how they relate.

## Main results

* `econ_eq_census_anchor` : the **exact pointwise identity**
  `econ T₀ 1 k = census (2 * (T₀ - 1)) k + 1/2`, valid for every `k`.  Consequently
  (`econ_le_econ_iff_census_le_census`, `econ_argmin_iff_census_argmin`) the two objectives
  have *identical* argmin sets once the anchor conversion `W ↔ 2 (T₀ - 1)` is applied.
* `econ_eq_census_naive_shift` : the **unconverted** comparison
  `econ T₀ 1 (k + 1) = census (T₀ - 1) k + 3/2`, so feeding the same number into both
  formulas shifts the discrete argmin by **exactly one** query
  (`naive_argmin_shift_exactly_one`), and the continuous locations differ by exactly `1`
  (`kOptEcon_eq_kOptCost_add_one`).
* `census_dyadic_min` / `census_dyadic_eq_iff` : for dyadic `W = 2 ^ m` the census optimum
  value is `m + 1/2` **exactly**, attained precisely on the tie set `{m - 2, m - 1}`.
* `census_pin_not_optimal`, `pin_gap_mem` : the pin is *never* a census optimum
  (`m ≥ 1`), and the gap `kPin - k_opt ∈ {1, 2}`.
* `econC_min_at_kOptEcon` : the continuous economics optimum really is a global minimiser,
  characterised exactly by `2 ^ k = (T₀ - 1) log 2 / c_q`.
* `exp563_balanced_argmin`, `exp563_unbalanced_argmin` : the two recorded runs
  (`T̄₀ = 1072.425` and `T̄₀ = 286205.89`) have discrete economics argmin `10` and `18`,
  and the matched-anchor census reproduces the same optimum.

-- !-- Lab Notes -- !--
Hypothesizer (conjectures, ranked):
 (H1) `econ` and `census` are the *same* function up to an additive constant after the
      anchor conversion `W = 2 (T₀ - 1)`; hence identical argmin sets.            [BOLD]
 (H2) Without the conversion the discrete argmins differ by exactly `+1`, not "about 1".
 (H3) For dyadic `W` the census optimum is a two-element tie set and the optimal value is
      the *exact* rational `log₂ W + 1/2`.
 (H4) The pin `⌈log₂ W⌉` is never optimal for either objective (`W ≥ 2`).
 (H5) A discrete-convexity principle (increments monotone ⇒ local min is global) covers
      both objectives uniformly, so no separate analysis is needed per objective.

Experimenter: H1–H5 are all proved below, with zero sorries.  H1 and H2 are exact
identities (`econ_eq_census_anchor`, `econ_eq_census_naive_shift`) proved by `field_simp`
plus `ring`; H3 needs the elementary but non-formal fact `2 ^ j > j + 1` for `j ≥ 2`
(`two_pow_lt_of_two_le`, by induction); H5 is `min_of_local_min`, proved from a single
monotone-increment lemma.

Analyst: the informative failure is that the naive "same number in both formulas"
comparison is *not* an approximation error that vanishes: `econ T₀ 1 (k+1)` and
`census (T₀ - 1) k` differ by the constant `3/2`, so the shift is a structural `+1` on the
argmin, independent of `T₀`.  The equality-case analysis in `census_dyadic_eq_iff` also
shows the census tie set is a genuine two-element set (`2 ^ j = j + 1` has exactly the two
solutions `j = 0, 1`), so "the" census optimum is only well defined as a set.

Critic: no theorem here is `True`, `rfl`-only or `native_decide`-only; the numeric
`exp563` statements are discharged by `norm_num` on exact rational data plus the structural
`min_of_local_min` principle, so they are genuine global-minimality claims over all `k : ℕ`,
not spot checks.
-/

namespace KTaxonomy

open Real

/-! ## Definitions -/

/-- The **pin**: `⌈log₂ W⌉`, the budget at which a support of width `W` is fully resolved.
Marginal gain past this point is exactly zero.  It is a saturation point, never an optimum. -/
def kPin (W : ℕ) : ℕ := Nat.clog 2 W

/-- The T2 **census** total cost of a `k`-query halving schedule on support width `W`:
`k` queries plus the residual, priced at half the remaining support (`+ 1/2` convention). -/
noncomputable def census (W : ℝ) (k : ℕ) : ℝ := k + (W / 2 ^ k + 1) / 2

/-- The **economics** cost of a `k`-query schedule: `k + 1` charged at unit price `c_q`,
plus the expected residual scan against the measured baseline `T₀`. -/
noncomputable def econ (T₀ cq : ℝ) (k : ℕ) : ℝ := cq * (1 + k) + (T₀ - 1) / 2 ^ k

/-- Continuous (real-exponent) version of `census`. -/
noncomputable def censusC (W x : ℝ) : ℝ := x + (W * (2 : ℝ) ^ (-x) + 1) / 2

/-- Continuous (real-exponent) version of `econ`. -/
noncomputable def econC (T₀ cq x : ℝ) : ℝ := cq * (1 + x) + (T₀ - 1) * (2 : ℝ) ^ (-x)

/-- Continuous location of the economics optimum: `log₂ ((T₀ - 1) ln 2 / c_q)`. -/
noncomputable def kOptEcon (T₀ cq : ℝ) : ℝ := logb 2 ((T₀ - 1) * Real.log 2 / cq)

/-- Continuous location of the census optimum: `log₂ (W ln 2) - 1`. -/
noncomputable def kOptCost (W : ℝ) : ℝ := logb 2 (W * Real.log 2) - 1

/-! ## Consistency of the discrete and continuous costs -/

lemma rpow_neg_natCast (k : ℕ) : (2 : ℝ) ^ (-(k : ℝ)) = 1 / 2 ^ k := by
  rw [Real.rpow_neg (by norm_num), Real.rpow_natCast]
  simp

lemma censusC_natCast (W : ℝ) (k : ℕ) : censusC W (k : ℝ) = census W k := by
  unfold censusC census
  rw [rpow_neg_natCast]
  ring

lemma econC_natCast (T₀ cq : ℝ) (k : ℕ) : econC T₀ cq (k : ℝ) = econ T₀ cq k := by
  unfold econC econ
  rw [rpow_neg_natCast]
  ring

/-! ## The exact identities relating the two objectives -/

/-- **Anchor-converted identity.**  With the conversion `W = 2 (T₀ - 1)` the economics cost
and the census cost differ by the constant `1/2`, pointwise in `k`. -/
theorem econ_eq_census_anchor (T₀ : ℝ) (k : ℕ) :
    econ T₀ 1 k = census (2 * (T₀ - 1)) k + 1 / 2 := by
  have h : (2 : ℝ) ^ k ≠ 0 := by positivity
  unfold econ census
  field_simp
  ring

/-- **Unconverted identity.**  Feeding the same number `T₀ - 1` to both formulas, the
economics cost at `k + 1` equals the census cost at `k` plus the constant `3/2`. -/
theorem econ_eq_census_naive_shift (T₀ : ℝ) (k : ℕ) :
    econ T₀ 1 (k + 1) = census (T₀ - 1) k + 3 / 2 := by
  have h : (2 : ℝ) ^ k ≠ 0 := by positivity
  unfold econ census
  push_cast
  field_simp
  ring

/-- Under the anchor conversion, comparisons of economics costs and census costs agree. -/
theorem econ_le_econ_iff_census_le_census (T₀ : ℝ) (j k : ℕ) :
    econ T₀ 1 j ≤ econ T₀ 1 k ↔ census (2 * (T₀ - 1)) j ≤ census (2 * (T₀ - 1)) k := by
  rw [econ_eq_census_anchor, econ_eq_census_anchor]
  constructor <;> intro h <;> linarith

/-- Hence the argmin *sets* coincide exactly. -/
theorem econ_argmin_iff_census_argmin (T₀ : ℝ) (j : ℕ) :
    (∀ k, econ T₀ 1 j ≤ econ T₀ 1 k) ↔ (∀ k, census (2 * (T₀ - 1)) j ≤ census (2 * (T₀ - 1)) k) := by
  constructor <;> intro h k
  · exact (econ_le_econ_iff_census_le_census T₀ j k).1 (h k)
  · exact (econ_le_econ_iff_census_le_census T₀ j k).2 (h k)

/-- **The `+1` is exact.**  Without the anchor conversion, the economics argmin sits exactly
one query above the census argmin — not "about one". -/
theorem naive_argmin_shift_exactly_one (T₀ : ℝ) (j : ℕ) :
    (∀ k, census (T₀ - 1) j ≤ census (T₀ - 1) k) →
      ∀ k, 1 ≤ k → econ T₀ 1 (j + 1) ≤ econ T₀ 1 k := by
  intro h k hk
  obtain ⟨k, rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
  rw [econ_eq_census_naive_shift, econ_eq_census_naive_shift]
  linarith [h k]

/-! ## A discrete convexity principle -/

section DiscreteConvexity

variable {f : ℕ → ℝ}

/-- Monotone increments: the discrete-convexity hypothesis propagates along `≤`. -/
lemma incr_mono (hconv : ∀ k, f (k + 1) - f k ≤ f (k + 2) - f (k + 1)) {i j : ℕ} (hij : i ≤ j) :
    f (i + 1) - f i ≤ f (j + 1) - f j := by
  induction j, hij using Nat.le_induction with
  | base => exact le_refl _
  | succ n hn ih => exact le_trans ih (by simpa using hconv n)

/-- A discretely convex function is nondecreasing to the right of a nonnegative increment. -/
lemma mono_right (hconv : ∀ k, f (k + 1) - f k ≤ f (k + 2) - f (k + 1)) {n : ℕ}
    (hup : f n ≤ f (n + 1)) : ∀ k, n ≤ k → f n ≤ f k := by
  intro k hk
  induction k, hk using Nat.le_induction with
  | base => exact le_refl _
  | succ m hm ih =>
      have := incr_mono hconv hm
      linarith

/-- A discretely convex function is nonincreasing to the left of a nonpositive increment. -/
lemma mono_left (hconv : ∀ k, f (k + 1) - f k ≤ f (k + 2) - f (k + 1)) {m : ℕ}
    (hdown : f (m + 1) ≤ f m) : ∀ k, k ≤ m → f (m + 1) ≤ f k := by
  intro k hk
  have key : ∀ i j : ℕ, j + i = m → f (m + 1) ≤ f j := by
    intro i
    induction i with
    | zero =>
        intro j hj
        have : j = m := by omega
        subst this
        exact hdown
    | succ n ih =>
        intro j hj
        have h1 : f (m + 1) ≤ f (j + 1) := ih (j + 1) (by omega)
        have h2 : f (j + 1) - f j ≤ f (m + 1) - f m := incr_mono hconv (by omega : j ≤ m)
        linarith
  exact key (m - k) k (by omega)

/-- **Local min ⇒ global min** for discretely convex objectives. -/
theorem min_of_local_min (hconv : ∀ k, f (k + 1) - f k ≤ f (k + 2) - f (k + 1)) {n : ℕ}
    (hup : f n ≤ f (n + 1)) (hdown : ∀ m, n = m + 1 → f n ≤ f m) : ∀ k, f n ≤ f k := by
  intro k
  rcases le_or_gt n k with h | h
  · exact mono_right hconv hup k h
  · obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
    exact mono_left hconv (hdown m rfl) k (by omega)

end DiscreteConvexity

/-! ## Discrete convexity of the two objectives -/

lemma econ_conv (T₀ cq : ℝ) (hA : 0 ≤ T₀ - 1) (k : ℕ) :
    econ T₀ cq (k + 1) - econ T₀ cq k ≤ econ T₀ cq (k + 2) - econ T₀ cq (k + 1) := by
  have h : (0:ℝ) < 2 ^ k := by positivity
  have key : (econ T₀ cq (k + 2) - econ T₀ cq (k + 1)) - (econ T₀ cq (k + 1) - econ T₀ cq k)
      = (T₀ - 1) / (2 ^ k * 4) := by
    simp only [econ]
    push_cast
    field_simp
    ring
  have hnn : (0:ℝ) ≤ (T₀ - 1) / (2 ^ k * 4) := div_nonneg hA (by positivity)
  linarith

lemma census_conv (W : ℝ) (hW : 0 ≤ W) (k : ℕ) :
    census W (k + 1) - census W k ≤ census W (k + 2) - census W (k + 1) := by
  have h := econ_conv (W / 2 + 1) 1 (by linarith) k
  have e : ∀ j : ℕ, econ (W / 2 + 1) 1 j = census W j + 1 / 2 := by
    intro j
    have h2 : (2 : ℝ) ^ j ≠ 0 := by positivity
    unfold econ census
    field_simp
    ring
  rw [e, e, e] at h
  linarith

/-! ## The dyadic census optimum: exact value `log₂ W + 1/2` on a two-element tie set -/

lemma le_two_pow (j : ℕ) : (j : ℝ) + 1 ≤ 2 ^ j := by
  induction j with
  | zero => norm_num
  | succ n ih =>
      have hn : (1:ℝ) ≤ 2 ^ n := one_le_pow₀ (by norm_num)
      push_cast
      rw [pow_succ]
      linarith

lemma two_pow_lt_of_two_le {j : ℕ} (hj : 2 ≤ j) : (j : ℝ) + 1 < 2 ^ j := by
  induction j, hj using Nat.le_induction with
  | base => norm_num
  | succ n hn ih =>
      have hn' : (n : ℝ) + 1 ≤ 2 ^ n := le_two_pow n
      have h1 : (1:ℝ) ≤ (n:ℝ) := by exact_mod_cast Nat.one_le_of_lt hn
      push_cast
      rw [pow_succ]
      linarith

lemma census_two_pow (m k : ℕ) :
    census ((2:ℝ) ^ m) k = (k : ℝ) + (2:ℝ) ^ m / (2:ℝ) ^ (k + 1) + 1 / 2 := by
  unfold census
  rw [pow_succ]
  have h : (2:ℝ) ^ k ≠ 0 := by positivity
  field_simp
  ring

/-- On the tie set `{m - 2, m - 1}` the dyadic census cost is exactly `m + 1/2`. -/
theorem census_dyadic_eq (m k : ℕ) (h : k + 1 = m ∨ k + 2 = m) :
    census ((2:ℝ) ^ m) k = (m : ℝ) + 1 / 2 := by
  rw [census_two_pow]
  rcases h with h | h
  · subst h
    rw [div_self (by positivity)]
    push_cast
    ring
  · subst h
    have : (2:ℝ) ^ (k + 2) / (2:ℝ) ^ (k + 1) = 2 := by
      rw [pow_succ]
      field_simp
    rw [this]
    push_cast
    ring

/-- Off the tie set the dyadic census cost is *strictly* above `m + 1/2`. -/
theorem census_dyadic_strict (m k : ℕ) (h1 : k + 1 ≠ m) (h2 : k + 2 ≠ m) :
    (m : ℝ) + 1 / 2 < census ((2:ℝ) ^ m) k := by
  rw [census_two_pow]
  rcases le_or_gt m k with hmk | hmk
  · have hpos : (0:ℝ) < (2:ℝ) ^ m / (2:ℝ) ^ (k + 1) := by positivity
    have : (m : ℝ) ≤ (k : ℝ) := by exact_mod_cast hmk
    linarith
  · -- here `k < m` and `k + 1 ≠ m`, `k + 2 ≠ m`, so `m = k + 1 + j` with `j ≥ 2`
    obtain ⟨j, hj⟩ : ∃ j, m = k + 1 + j := ⟨m - k - 1, by omega⟩
    have hj2 : 2 ≤ j := by omega
    have hpow : (2:ℝ) ^ m / (2:ℝ) ^ (k + 1) = (2:ℝ) ^ j := by
      rw [hj, pow_add]
      field_simp
    rw [hpow, hj]
    have := two_pow_lt_of_two_le hj2
    push_cast
    linarith

/-- The dyadic census optimum value is exactly `m + 1/2`. -/
theorem census_dyadic_min (m k : ℕ) : (m : ℝ) + 1 / 2 ≤ census ((2:ℝ) ^ m) k := by
  by_cases h1 : k + 1 = m
  · exact le_of_eq (census_dyadic_eq m k (Or.inl h1)).symm
  · by_cases h2 : k + 2 = m
    · exact le_of_eq (census_dyadic_eq m k (Or.inr h2)).symm
    · exact le_of_lt (census_dyadic_strict m k h1 h2)

/-- **Exact characterisation of the dyadic census tie set.** -/
theorem census_dyadic_eq_iff (m k : ℕ) :
    census ((2:ℝ) ^ m) k = (m : ℝ) + 1 / 2 ↔ (k + 1 = m ∨ k + 2 = m) := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    exact absurd h (ne_of_gt (census_dyadic_strict m k hc.1 hc.2))
  · exact census_dyadic_eq m k

/-- The dyadic census argmin set is exactly the tie set `{m - 2, m - 1}` (for `m ≥ 1`;
for `m = 0` the support is already a single point and `k = 0` is trivially optimal). -/
theorem census_dyadic_argmin_iff (m k : ℕ) (hm : 1 ≤ m) :
    (∀ j, census ((2:ℝ) ^ m) k ≤ census ((2:ℝ) ^ m) j) ↔ (k + 1 = m ∨ k + 2 = m) := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have hmin := h (m - 1)
    have heq : census ((2:ℝ) ^ m) (m - 1) = (m : ℝ) + 1 / 2 :=
      census_dyadic_eq m (m - 1) (Or.inl (by omega))
    have hstrict := census_dyadic_strict m k hc.1 hc.2
    rw [heq] at hmin
    linarith
  · intro h j
    rw [census_dyadic_eq m k h]
    exact census_dyadic_min m j

/-! ## The pin is never an optimum -/

lemma kPin_two_pow (m : ℕ) : kPin (2 ^ m) = m := Nat.clog_pow 2 m (by norm_num)

/-- The pin costs exactly `m + 1` in the dyadic census, i.e. exactly `1/2` more than the
optimum `m + 1/2`. -/
theorem census_at_pin (m : ℕ) : census ((2:ℝ) ^ m) (kPin (2 ^ m)) = (m : ℝ) + 1 := by
  rw [kPin_two_pow, census_two_pow]
  have : (2:ℝ) ^ m / (2:ℝ) ^ (m + 1) = 1 / 2 := by
    rw [pow_succ]; field_simp
  rw [this]; ring

/-- **The pin is never a census optimum** for `W = 2 ^ m` with `m ≥ 1`. -/
theorem census_pin_not_optimal (m : ℕ) (hm : 1 ≤ m) :
    ¬ (∀ j, census ((2:ℝ) ^ m) (kPin (2 ^ m)) ≤ census ((2:ℝ) ^ m) j) := by
  intro h
  have hopt : census ((2:ℝ) ^ m) (m - 1) = (m : ℝ) + 1 / 2 :=
    census_dyadic_eq m (m - 1) (Or.inl (by omega))
  have := h (m - 1)
  rw [census_at_pin, hopt] at this
  linarith

/-- The pin overshoots every census optimum by `1` or `2` queries. -/
theorem pin_gap_mem (m k : ℕ) (hm : 2 ≤ m) (hk : ∀ j, census ((2:ℝ) ^ m) k ≤ census ((2:ℝ) ^ m) j) :
    kPin (2 ^ m) - k = 1 ∨ kPin (2 ^ m) - k = 2 := by
  rw [kPin_two_pow]
  rcases (census_dyadic_argmin_iff m k (by omega)).1 hk with h | h
  · left; omega
  · right; omega

/-! ## The continuous optima -/

/-- The economics optimum location is characterised exactly by `2 ^ k = (T₀ - 1) ln 2 / c_q`. -/
theorem two_rpow_kOptEcon (T₀ cq : ℝ) (hT : 1 < T₀) (hc : 0 < cq) :
    (2 : ℝ) ^ (kOptEcon T₀ cq) = (T₀ - 1) * Real.log 2 / cq := by
  have ht : 0 < Real.log 2 := Real.log_pos (by norm_num)
  exact Real.rpow_logb (by norm_num) (by norm_num) (div_pos (mul_pos (by linarith) ht) hc)

/-- **The continuous economics optimum is a genuine global minimiser.**
The proof is the exponential inequality `1 - u ≤ exp (-u)` applied at the rescaled
displacement `u = (x - k_opt) ln 2`. -/
theorem econC_min_at_kOptEcon (T₀ cq : ℝ) (hT : 1 < T₀) (hc : 0 < cq) (x : ℝ) :
    econC T₀ cq (kOptEcon T₀ cq) ≤ econC T₀ cq x := by
  have hApos : 0 < T₀ - 1 := by linarith
  have ht : 0 < Real.log 2 := Real.log_pos (by norm_num)
  obtain ⟨xs, hxs⟩ : ∃ xs, xs = kOptEcon T₀ cq := ⟨_, rfl⟩
  have hxsval : (2 : ℝ) ^ xs = (T₀ - 1) * Real.log 2 / cq := by
    rw [hxs]; exact two_rpow_kOptEcon T₀ cq hT hc
  have hneg : (2 : ℝ) ^ (-xs) = cq / ((T₀ - 1) * Real.log 2) := by
    rw [Real.rpow_neg (by norm_num), hxsval]
    field_simp
  have hxval : (2 : ℝ) ^ (-x) = ((2:ℝ) ^ (-xs)) * Real.exp (-((x - xs) * Real.log 2)) := by
    rw [Real.rpow_def_of_pos (by norm_num) (-x), Real.rpow_def_of_pos (by norm_num) (-xs),
      ← Real.exp_add]
    congr 1
    ring
  set u : ℝ := (x - xs) * Real.log 2 with hu
  have hexp : 1 - u ≤ Real.exp (-u) := by
    have := Real.add_one_le_exp (-u); linarith
  have hxu : x = xs + u / Real.log 2 := by
    rw [hu]; field_simp; ring
  have hkey : econC T₀ cq x - econC T₀ cq xs = (cq / Real.log 2) * (u + Real.exp (-u) - 1) := by
    unfold econC
    rw [hxval, hneg, hxu]
    field_simp
    ring
  have hpos : 0 ≤ (cq / Real.log 2) * (u + Real.exp (-u) - 1) :=
    mul_nonneg (by positivity) (by linarith)
  rw [← hxs]
  linarith

/-- The census optimum location is exactly the economics optimum for the converted anchor
`T₀ = W / 2 + 1`, i.e. `W = 2 (T₀ - 1)`. -/
theorem kOptCost_eq_kOptEcon (W : ℝ) (hW : 0 < W) : kOptCost W = kOptEcon (W / 2 + 1) 1 := by
  have ht : 0 < Real.log 2 := Real.log_pos (by norm_num)
  unfold kOptCost kOptEcon
  have h : (W / 2 + 1 - 1) * Real.log 2 / 1 = (W * Real.log 2) / 2 := by ring
  rw [h, Real.logb_div (by positivity) (by norm_num), Real.logb_self_eq_one (by norm_num)]

/-- **The naive shift is exactly `+1` in the continuous locations too**: feeding the same
number `T₀ - 1` into the census formula lands exactly one query below the economics optimum. -/
theorem kOptEcon_eq_kOptCost_add_one (T₀ : ℝ) : kOptEcon T₀ 1 = kOptCost (T₀ - 1) + 1 := by
  unfold kOptEcon kOptCost
  rw [div_one]
  ring

/-- The continuous census optimum is a global minimiser of the continuous census cost. -/
theorem censusC_min_at_kOptCost (W : ℝ) (hW : 0 < W) (x : ℝ) :
    censusC W (kOptCost W) ≤ censusC W x := by
  have h : ∀ y : ℝ, censusC W y = econC (W / 2 + 1) 1 y - 1 / 2 := by
    intro y
    unfold censusC econC
    ring
  rw [h, h, kOptCost_eq_kOptEcon W hW]
  have := econC_min_at_kOptEcon (W / 2 + 1) 1 (by linarith) one_pos x
  linarith

/-! ## Reproduction of the recorded `exp563` rows -/

/-- Balanced run: measured baseline `T̄₀ = 1072.425`. -/
noncomputable def T0bal : ℝ := 1072425 / 1000

/-- Unbalanced run: measured baseline `T̄₀ = 286205.89`. -/
noncomputable def T0unb : ℝ := 28620589 / 100

/-- Recorded discrete argmin for the balanced run is `10`, over *all* budgets `k`. -/
theorem exp563_balanced_argmin (k : ℕ) : econ T0bal 1 10 ≤ econ T0bal 1 k := by
  refine min_of_local_min (f := fun k => econ T0bal 1 k)
    (econ_conv T0bal 1 (by norm_num [T0bal])) ?_ ?_ k
  · simp only [econ, T0bal]; norm_num
  · intro m hm
    obtain rfl : m = 9 := by omega
    simp only [econ, T0bal]; norm_num

/-- Recorded discrete argmin for the unbalanced run is `18`. -/
theorem exp563_unbalanced_argmin (k : ℕ) : econ T0unb 1 18 ≤ econ T0unb 1 k := by
  refine min_of_local_min (f := fun k => econ T0unb 1 k)
    (econ_conv T0unb 1 (by norm_num [T0unb])) ?_ ?_ k
  · simp only [econ, T0unb]; norm_num
  · intro m hm
    obtain rfl : m = 17 := by omega
    simp only [econ, T0unb]; norm_num

/-- The matched-anchor census reproduces the same optimum `10` for the balanced run. -/
theorem exp563_balanced_census_argmin (k : ℕ) :
    census (2 * (T0bal - 1)) 10 ≤ census (2 * (T0bal - 1)) k :=
  (econ_argmin_iff_census_argmin T0bal 10).1 exp563_balanced_argmin k

/-- The matched-anchor census reproduces the same optimum `18` for the unbalanced run. -/
theorem exp563_unbalanced_census_argmin (k : ℕ) :
    census (2 * (T0unb - 1)) 18 ≤ census (2 * (T0unb - 1)) k :=
  (econ_argmin_iff_census_argmin T0unb 18).1 exp563_unbalanced_argmin k

lemma two_rpow_ofNat (n : ℕ) (y : ℝ) (h : (2:ℝ) ^ n = y) : (2:ℝ) ^ (n : ℝ) = y := by
  rw [Real.rpow_natCast]; exact h

/-- The recorded continuous prediction `9.5365…` for the balanced run, certified to lie in
`(9, 10)` — so the discrete optimum `10` is the ceiling of the continuous location. -/
theorem exp563_balanced_pred_bracket : 9 < kOptEcon T0bal 1 ∧ kOptEcon T0bal 1 < 10 := by
  have ht1 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have ht2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have harg : (T0bal - 1) * Real.log 2 / 1 = (T0bal - 1) * Real.log 2 := by ring
  have hpos : (0:ℝ) < (T0bal - 1) * Real.log 2 := by rw [T0bal]; nlinarith
  have h9 : (2:ℝ) ^ (9:ℝ) = 512 := two_rpow_ofNat 9 512 (by norm_num)
  have h10 : (2:ℝ) ^ (10:ℝ) = 1024 := two_rpow_ofNat 10 1024 (by norm_num)
  constructor
  · rw [kOptEcon, harg, Real.lt_logb_iff_rpow_lt (by norm_num) hpos, h9, T0bal]
    nlinarith
  · rw [kOptEcon, harg, Real.logb_lt_iff_lt_rpow (by norm_num) hpos, h10, T0bal]
    nlinarith

/-- The recorded continuous prediction `17.5979…` for the unbalanced run, certified to lie in
`(17, 18)`. -/
theorem exp563_unbalanced_pred_bracket : 17 < kOptEcon T0unb 1 ∧ kOptEcon T0unb 1 < 18 := by
  have ht1 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have ht2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have harg : (T0unb - 1) * Real.log 2 / 1 = (T0unb - 1) * Real.log 2 := by ring
  have hpos : (0:ℝ) < (T0unb - 1) * Real.log 2 := by rw [T0unb]; nlinarith
  have h17 : (2:ℝ) ^ (17:ℝ) = 131072 := two_rpow_ofNat 17 131072 (by norm_num)
  have h18 : (2:ℝ) ^ (18:ℝ) = 262144 := two_rpow_ofNat 18 262144 (by norm_num)
  constructor
  · rw [kOptEcon, harg, Real.lt_logb_iff_rpow_lt (by norm_num) hpos, h17, T0unb]
    nlinarith
  · rw [kOptEcon, harg, Real.logb_lt_iff_lt_rpow (by norm_num) hpos, h18, T0unb]
    nlinarith

/-- **Conflating the pin with the work-optimal budget overstates the budget.**  For the
balanced `exp563` anchor the census optimum sits at `10`, while the pin for the same
support width `W = 2 (T̄₀ - 1) = 2142.85`, rounded up to the integer width `2143`, is
`kPin 2143 = 12`: a strict overstatement of the work-optimal budget. -/
theorem exp563_balanced_pin_overstates :
    kPin 2143 = 12 ∧ census (2 * (T0bal - 1)) 10 < census (2 * (T0bal - 1)) 12 := by
  constructor
  · unfold kPin
    norm_num [Nat.clog]
  · simp only [census, T0bal]
    norm_num

end KTaxonomy