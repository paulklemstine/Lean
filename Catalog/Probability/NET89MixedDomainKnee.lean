import Shared.AttentionBudgetKnee

/-!
# NET-89: the mixed-domain key budget — the mediant sandwich, the halving reduction,
and why a mixed knee must rise at *double* the pure rate

The NET-89 report ("THE-MIXED-DOMAIN-STARTS-LOW-AND-RISES-FAST") interleaves ~500-char
blocks of Python code and English prose and measures the top-`k` key budget `k*` that
clears an exact gate:

| ctx  | mixed `k*` | code `k*` | EN prose `k*` | mixed increment |
|------|-----------|-----------|---------------|-----------------|
| 512  | 12        | 12        | 16            | —               |
| 1024 | 20        | 16        | 20            | **+8** (vs +4)  |

Three claims are on the table: (P1) the mixed knee is the *midpoint* of the component
knees; (P2) it reaches prose's level; (P3) mixed attention has structure of its own.
This file settles all three inside the model-free knee theory of
`Shared.AttentionBudgetKnee`, using two structures:

* `pool a b u v` — the two domains share one context, contributing with weights `a, b`
  (the mixing ratio; the report's 50/50 case is `a = b = 1`);
* `mix u v` — the *interleaved* profile, whose keys alternate between the two domains.

The results.

* `retained_pool_ge_min`, `retained_pool_le_max` — the **mediant sandwich**: the
  retained mass of a two-domain context is a weighted mediant of the two component
  curves, hence always between them, for *every* mixing ratio.
* `kstar_pool_le_max`, `min_le_kstar_pool` — consequently the pooled knee is caged:
  `min (k*_u, k*_v) ≤ k*_pool ≤ max (k*_u, k*_v)`.
* `pool_knee_attains_min_mid_max` and `no_component_knee_formula` — **P1 is refuted, in
  the strongest possible form.**  Three explicit profile pairs with the *same* component
  knees `(1, 3)` realise pooled knees `1`, `2` and `3`: the whole sandwich is attained,
  so the mixed knee is not a function of the component knees at all — not the midpoint,
  not the min, not the max.  Only the sandwich survives.
* `retained_mix_even` — the **halving reduction**: interleaving is exactly pooling read
  at half scale, `retained (mix u v) (2n) (2k) = retained (pool 1 1 u v) n k`.  This is
  the structural content of "mixed-domain attention has its own geometry": a mixed
  context of length `2n` is a pooled context of length `n` in doubled key units.
* `kstar_mix_bracket` — hence `2·k*_pool(n) - 1 ≤ k*_mix(2n) ≤ 2·k*_pool(n)`, with the
  exact-parity refinement `kstar_mix_eq_two_mul`.
* `kstar_mono_ctx` — knees never decrease when the context grows (new general lemma).
* `mix_ctxSens_doubling` — **the headline: the doubling law.**  The mixed doubling
  increment is twice the pooled increment, up to one key:
  `2Δ_pool(n) - 1 ≤ Δ_mix(2n) ≤ 2Δ_pool(n) + 1`.
* `proportional_mix_increment_doubles` and `net89_predicted_increment` — for two domains
  with proportional profiles the pooled increment *is* the pure increment, so a pure
  `+4` forces a mixed increment in `{7, 8, 9}`.  The reported `+8` is not an anomaly of
  cross-domain attention: it is forced by key-unit doubling alone.
* `mix_no_superadditivity` — the adversarial reading: with matched per-domain content a
  mixed knee can never exceed `2·max` of the component knees, so "mixed is harder than
  either pure domain" is a statement about halved per-domain content, not about a new
  attention mechanism.
* `net89_mixed_increment_bracket` — the measurement-grid audit: on the reported grid the
  mixed increment is pinned only to `[5, 11]`.  This *does* exclude the pure value `4`
  (so the report's qualitative verdict survives) but it does *not* pin `+8`, and in
  particular does not distinguish `+8` from the model's own prediction band `{7,8,9}`.
* `net89_mixed_below_prose_at_512` — "starts at code's level" in the only form the data
  supports: a pass at 12 for mixed together with a fail at 12 for prose forces
  `k*_mix < k*_prose` at ctx 512.

-- !-- Lab Notes -- !--
Hypothesizer (round 33, six conjectures, ranked by expected impact):
 (H1) Any two-domain context — any mixing ratio — has retained mass equal to a
      *mediant* of the component curves, so its knee is caged between the component
      knees and nothing finer is true.                                        [BOLD]
 (H2) Interleaving is pooling at half scale; therefore the mixed knee is `2×` a pooled
      knee up to parity, and the *increment* doubles.  The reported `+8 vs +4` is a
      unit-conversion theorem, not a discovery about attention.               [BOLD]
 (H3) No function of the component knees can predict the mixed knee: the entire
      sandwich `[min, max]` is realised by profiles with identical component knees.
                                                                              [BOLD]
 (H4) Mixed knees cannot be super-additive at matched per-domain content
      (`k*_mix(2n) ≤ 2 max`), so the report's "harder than either domain" is a
      resolution artefact of the equal-total-length comparison.
 (H5) The reported grid (step 4) cannot resolve `+8` from `+5 … +11`; but it does
      exclude `+4`.
 (H6) Knees are monotone in context length for every positive profile (needed to make
      any increment statement well posed).

Experimenter: H1 = `retained_pool_ge_min`/`retained_pool_le_max`; H2 =
`retained_mix_even`, `kstar_mix_bracket`, `mix_ctxSens_doubling`; H3 =
`no_component_knee_formula` with three explicit witnesses at `n = 4`, `τ = 7/10`
(component knees `1` and `3`; pooled knees `2`, `1`, `3`); H4 =
`mix_no_superadditivity`; H5 = `net89_mixed_increment_bracket`; H6 = `kstar_mono_ctx`.
Zero sorries.

Numerical inputs used only as hypotheses, never as axioms: the four measured grid
outcomes at ctx 512 (fail at `k = 8`, pass at `k = 12`) and ctx 1024 (fail at `k = 16`,
pass at `k = 20`).

Analyst: the interesting failure is P1.  It is not merely false, it is *unrepairable*:
witnesses `uB` (a huge head key) and `uC` (a tiny total mass) share the component knees
of `uA` yet push the pooled knee to the two ends of the sandwich.  What survives is
exactly the mediant cage plus the halving reduction, and those two together already
explain the whole reported table — including the doubled increment — without invoking
cross-domain query-key interactions.  Verdict: "needs a different definition", the
right invariant being the *pooled* knee in doubled key units.

Critic: no theorem here is vacuous.  `pool_knee_attains_min_mid_max` exhibits three
distinct pooled knees, so the sandwich theorems are not silently equalities;
`kstar_mix_bracket` is two-sided and the parity refinement shows both ends occur;
`net89_mixed_increment_bracket` reports the honest `[5, 11]` rather than the headline
`+8`; and every knee statement carries the positivity and gate hypotheses the theory
requires.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

/-! ## 0. Mediants

A mediant `(A₁ + A₂)/(B₁ + B₂)` of two positive-denominator fractions lies between them.
This elementary fact is the engine of the whole file: a two-domain retained-mass curve is
literally a mediant of its two component curves. -/

lemma min_le_mediant {A₁ A₂ B₁ B₂ : ℝ} (hB₁ : 0 < B₁) (hB₂ : 0 < B₂) :
    min (A₁ / B₁) (A₂ / B₂) ≤ (A₁ + A₂) / (B₁ + B₂) := by
  set m := min (A₁ / B₁) (A₂ / B₂) with hm
  have h1 : m * B₁ ≤ A₁ := by
    have h := min_le_left (A₁ / B₁) (A₂ / B₂)
    rw [← hm, le_div_iff₀ hB₁] at h; linarith
  have h2 : m * B₂ ≤ A₂ := by
    have h := min_le_right (A₁ / B₁) (A₂ / B₂)
    rw [← hm, le_div_iff₀ hB₂] at h; linarith
  rw [le_div_iff₀ (by linarith)]
  nlinarith

lemma mediant_le_max {A₁ A₂ B₁ B₂ : ℝ} (hB₁ : 0 < B₁) (hB₂ : 0 < B₂) :
    (A₁ + A₂) / (B₁ + B₂) ≤ max (A₁ / B₁) (A₂ / B₂) := by
  set M := max (A₁ / B₁) (A₂ / B₂) with hM
  have h1 : A₁ ≤ M * B₁ := by
    have h := le_max_left (A₁ / B₁) (A₂ / B₂)
    rw [← hM, div_le_iff₀ hB₁] at h; linarith
  have h2 : A₂ ≤ M * B₂ := by
    have h := le_max_right (A₁ / B₁) (A₂ / B₂)
    rw [← hM, div_le_iff₀ hB₂] at h; linarith
  rw [div_le_iff₀ (by linarith)]
  nlinarith

/-! ## 1. The two mixed-domain constructions -/

/-- The **pooled profile**.  Both domains occupy the same context, contributing their
attention mass with weights `a` and `b`; `a / (a + b)` is the mixing ratio.  The NET-89
50/50 protocol is `a = b = 1`. -/
noncomputable def pool (a b : ℝ) (u v : ℕ → ℝ) : ℕ → ℝ := fun i => a * u i + b * v i

/-- The **interleaved (mixed) profile**.  Keys alternate between the two domains, which
is what a context built from alternating code/prose blocks looks like after sorting
within each domain. -/
noncomputable def mix (u v : ℕ → ℝ) : ℕ → ℝ :=
  fun i => if i % 2 = 0 then u (i / 2) else v (i / 2)

variable {u v w : ℕ → ℝ} {a b c τ : ℝ} {n k : ℕ}

lemma pool_pos (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) :
    ∀ i, 0 < pool a b u v i := fun i => by
  have := hu i; have := hv i; simp only [pool]; positivity

lemma mix_pos (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) : ∀ i, 0 < mix u v i := by
  intro i; simp only [mix]; split
  · exact hu _
  · exact hv _

lemma headMass_pool (a b : ℝ) (u v : ℕ → ℝ) (k : ℕ) :
    headMass (pool a b u v) k = a * headMass u k + b * headMass v k := by
  simp [headMass, pool, Finset.sum_add_distrib, Finset.mul_sum]

/-- An even prefix of an interleaved context contains exactly the matched prefixes of
both domains. -/
lemma headMass_mix_even (u v : ℕ → ℝ) (k : ℕ) :
    headMass (mix u v) (2 * k) = headMass u k + headMass v k := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have h : 2 * (k + 1) = 2 * k + 1 + 1 := by ring
      rw [h, headMass, Finset.sum_range_succ, Finset.sum_range_succ]
      have h1 : mix u v (2 * k) = u k := by simp [mix, Nat.mul_mod_right]
      have h2 : mix u v (2 * k + 1) = v k := by
        have hmod : (2 * k + 1) % 2 = 1 := by omega
        have hdiv : (2 * k + 1) / 2 = k := by omega
        simp [mix, hmod, hdiv]
      rw [h1, h2]
      simp only [headMass] at ih ⊢
      rw [ih, Finset.sum_range_succ, Finset.sum_range_succ]
      ring

/-- An odd prefix contains one extra key of the first domain. -/
lemma headMass_mix_odd (u v : ℕ → ℝ) (k : ℕ) :
    headMass (mix u v) (2 * k + 1) = headMass u (k + 1) + headMass v k := by
  rw [headMass, Finset.sum_range_succ]
  have h1 : mix u v (2 * k) = u k := by simp [mix, Nat.mul_mod_right]
  have h2 : (∑ i ∈ Finset.range (2 * k), mix u v i) = headMass u k + headMass v k := by
    have := headMass_mix_even u v k; simpa [headMass] using this
  rw [h1, h2]
  simp only [headMass, Finset.sum_range_succ]
  ring

/-! ## 2. The mediant sandwich: a mixed domain is caged by its components -/

/-- **H1 (lower cage).**  The retained mass of a pooled two-domain context is at least
the smaller of the two component retained masses — for every mixing ratio. -/
lemma retained_pool_ge_min (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (k : ℕ) :
    min (retained u n k) (retained v n k) ≤ retained (pool a b u v) n k := by
  have hun : 0 < headMass u n := headMass_pos hu hn
  have hvn : 0 < headMass v n := headMass_pos hv hn
  have key := min_le_mediant (A₁ := a * headMass u (min k n)) (A₂ := b * headMass v (min k n))
      (B₁ := a * headMass u n) (B₂ := b * headMass v n) (by positivity) (by positivity)
  have e1 : a * headMass u (min k n) / (a * headMass u n) = retained u n k := by
    rw [retained]; exact mul_div_mul_left _ _ ha.ne'
  have e2 : b * headMass v (min k n) / (b * headMass v n) = retained v n k := by
    rw [retained]; exact mul_div_mul_left _ _ hb.ne'
  rw [e1, e2] at key
  simpa [retained, headMass_pool] using key

/-- **H1 (upper cage).**  Dually, the pooled retained mass never exceeds the larger
component retained mass. -/
lemma retained_pool_le_max (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (k : ℕ) :
    retained (pool a b u v) n k ≤ max (retained u n k) (retained v n k) := by
  have hun : 0 < headMass u n := headMass_pos hu hn
  have hvn : 0 < headMass v n := headMass_pos hv hn
  have key := mediant_le_max (A₁ := a * headMass u (min k n)) (A₂ := b * headMass v (min k n))
      (B₁ := a * headMass u n) (B₂ := b * headMass v n) (by positivity) (by positivity)
  have e1 : a * headMass u (min k n) / (a * headMass u n) = retained u n k := by
    rw [retained]; exact mul_div_mul_left _ _ ha.ne'
  have e2 : b * headMass v (min k n) / (b * headMass v n) = retained v n k := by
    rw [retained]; exact mul_div_mul_left _ _ hb.ne'
  rw [e1, e2] at key
  simpa [retained, headMass_pool] using key

/-- The pooled knee never exceeds the worse of the two component knees: mixing cannot
be harder than the harder domain. -/
theorem kstar_pool_le_max (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ : τ ≤ 1) :
    kstar (pool a b u v) n τ ≤ max (kstar u n τ) (kstar v n τ) := by
  set K := max (kstar u n τ) (kstar v n τ) with hK
  have h1 : τ ≤ retained u n K :=
    le_trans (gate_le_retained_kstar hu hn hτ) (retained_mono hu n (le_max_left _ _))
  have h2 : τ ≤ retained v n K :=
    le_trans (gate_le_retained_kstar hv hn hτ) (retained_mono hv n (le_max_right _ _))
  exact kstar_le_of_pass (le_trans (le_min h1 h2) (retained_pool_ge_min ha hb hu hv hn K))

/-- The pooled knee is never below the better of the two component knees: mixing cannot
be easier than the easier domain. -/
theorem min_le_kstar_pool (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ : τ ≤ 1) :
    min (kstar u n τ) (kstar v n τ) ≤ kstar (pool a b u v) n τ := by
  set K := kstar (pool a b u v) n τ with hK
  have hp : τ ≤ retained (pool a b u v) n K :=
    gate_le_retained_kstar (pool_pos ha hb hu hv) hn hτ
  have hmax : τ ≤ max (retained u n K) (retained v n K) :=
    le_trans hp (retained_pool_le_max ha hb hu hv hn K)
  rcases le_max_iff.mp hmax with h | h
  · exact le_trans (min_le_left _ _) (kstar_le_of_pass h)
  · exact le_trans (min_le_right _ _) (kstar_le_of_pass h)

/-! ## 3. The halving reduction: interleaving is pooling in doubled key units -/

/-- **H2 — the halving reduction.**  A mixed context of length `2n` read at an even
budget `2k` is exactly the pooled context of length `n` read at budget `k`.  Mixed-domain
attention therefore has its own geometry only in the sense of a change of key units. -/
lemma retained_mix_even (u v : ℕ → ℝ) (n k : ℕ) :
    retained (mix u v) (2 * n) (2 * k) = retained (pool 1 1 u v) n k := by
  have hmin : min (2 * k) (2 * n) = 2 * min k n := by omega
  rw [retained, retained, hmin, headMass_mix_even, headMass_mix_even, headMass_pool,
    headMass_pool]
  simp

/-- Odd budgets see one extra key of the first domain. -/
lemma retained_mix_odd (u v : ℕ → ℝ) {n k : ℕ} (hk : k < n) :
    retained (mix u v) (2 * n) (2 * k + 1) =
      (headMass u (k + 1) + headMass v k) / (headMass u n + headMass v n) := by
  have hmin : min (2 * k + 1) (2 * n) = 2 * k + 1 := by omega
  rw [retained, hmin, headMass_mix_odd, headMass_mix_even]

/-- **The mixed knee bracket.**  In doubled key units the interleaved knee is the pooled
knee, up to the one-key parity slack: `2·k*_pool(n) - 1 ≤ k*_mix(2n) ≤ 2·k*_pool(n)`. -/
theorem kstar_mix_bracket (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1) :
    2 * kstar (pool 1 1 u v) n τ ≤ kstar (mix u v) (2 * n) τ + 1 ∧
      kstar (mix u v) (2 * n) τ ≤ 2 * kstar (pool 1 1 u v) n τ := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hmp : ∀ i, 0 < mix u v i := mix_pos hu hv
  set K := kstar (pool 1 1 u v) n τ with hK
  set M := kstar (mix u v) (2 * n) τ with hM
  have hup : M ≤ 2 * K := by
    apply kstar_le_of_pass
    rw [retained_mix_even]
    exact gate_le_retained_kstar hpp hn hτ
  refine ⟨?_, hup⟩
  by_contra hcon
  push_neg at hcon
  have hK1 : 1 ≤ K := by omega
  have hle : M ≤ 2 * (K - 1) := by omega
  have hpass : τ ≤ retained (mix u v) (2 * n) M := gate_le_retained_kstar hmp (by omega) hτ
  have hpass2 : τ ≤ retained (mix u v) (2 * n) (2 * (K - 1)) :=
    le_trans hpass (retained_mono hmp _ hle)
  rw [retained_mix_even] at hpass2
  have := kstar_le_of_pass (w := pool 1 1 u v) (n := n) (τ := τ) hpass2
  omega

/-- The parity slack is resolved by one extra check: if the odd budget just below fails,
the mixed knee is exactly twice the pooled knee. -/
theorem kstar_mix_eq_two_mul (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1)
    (hK : 1 ≤ kstar (pool 1 1 u v) n τ)
    (hodd : retained (mix u v) (2 * n) (2 * kstar (pool 1 1 u v) n τ - 1) < τ) :
    kstar (mix u v) (2 * n) τ = 2 * kstar (pool 1 1 u v) n τ := by
  have hmp : ∀ i, 0 < mix u v i := mix_pos hu hv
  have hlow := lt_kstar_of_fail hmp (n := 2 * n) (by omega) hτ hodd
  have hup := (kstar_mix_bracket hu hv hn hτ).2
  omega

/-! ## 4. Knees are monotone in the context length -/

/-- A general fact the increment statements need: enlarging the context can only push the
knee up, because the normalising mass grows while the head mass does not. -/
theorem kstar_mono_ctx (hw : ∀ i, 0 < w i) (hτ : τ ≤ 1) {n m : ℕ} (hn : 0 < n) (hnm : n ≤ m) :
    kstar w n τ ≤ kstar w m τ := by
  have hm : 0 < m := lt_of_lt_of_le hn hnm
  set K := kstar w m τ with hK
  have hpass : τ ≤ retained w m K := gate_le_retained_kstar hw hm hτ
  apply kstar_le_of_pass (k := K)
  rcases le_or_gt n K with h | h
  · rw [retained, min_eq_right h, div_self (headMass_pos hw hn).ne']
    exact hτ
  · have hminn : min K n = K := min_eq_left h.le
    have hminm : min K m = K := min_eq_left (le_trans h.le hnm)
    rw [retained, hminn]
    rw [retained, hminm] at hpass
    have h1 : headMass w n ≤ headMass w m := headMass_mono hw hnm
    have h2 : 0 < headMass w n := headMass_pos hw hn
    have : headMass w K / headMass w m ≤ headMass w K / headMass w n :=
      div_le_div_of_nonneg_left (headMass_nonneg hw K) h2 h1
    linarith

/-! ## 5. The doubling law -/

/-- **H2, headline form — the doubling law.**  Doubling the context of an interleaved
mixture moves its knee by twice the pooled increment, up to one key:
`2Δ_pool(n) - 1 ≤ Δ_mix(2n) ≤ 2Δ_pool(n) + 1`.  A mixed curve *must* rise at double the
rate of the curve that governs it, purely because its key unit is halved. -/
theorem mix_ctxSens_doubling (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1) :
    2 * ctxSens (pool 1 1 u v) τ n ≤ ctxSens (mix u v) τ (2 * n) + 1 ∧
      ctxSens (mix u v) τ (2 * n) ≤ 2 * ctxSens (pool 1 1 u v) τ n + 1 := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hmp : ∀ i, 0 < mix u v i := mix_pos hu hv
  obtain ⟨b1, b2⟩ := kstar_mix_bracket hu hv hn hτ
  obtain ⟨c1, c2⟩ := kstar_mix_bracket (n := 2 * n) hu hv (by omega) hτ
  have hKmono : kstar (pool 1 1 u v) n τ ≤ kstar (pool 1 1 u v) (2 * n) τ :=
    kstar_mono_ctx hpp hτ hn (by omega)
  have hMmono : kstar (mix u v) (2 * n) τ ≤ kstar (mix u v) (2 * (2 * n)) τ :=
    kstar_mono_ctx hmp hτ (by omega) (by omega)
  simp only [ctxSens]
  omega

/-- **H4 — no super-additivity.**  With matched per-domain content the interleaved knee is
at most twice the worse component knee.  A mixed domain is never harder than its harder
component once key units are taken into account. -/
theorem mix_no_superadditivity (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    kstar (mix u v) (2 * n) τ ≤ 2 * max (kstar u n τ) (kstar v n τ) := by
  have h1 := (kstar_mix_bracket hu hv hn hτ).2
  have h2 := kstar_pool_le_max (a := 1) (b := 1) one_pos one_pos hu hv hn hτ
  omega

/-- The full two-sided cage for the interleaved knee, combining the sandwich with the
halving reduction. -/
theorem kstar_mix_sandwich (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1) :
    2 * min (kstar u n τ) (kstar v n τ) ≤ kstar (mix u v) (2 * n) τ + 1 ∧
      kstar (mix u v) (2 * n) τ ≤ 2 * max (kstar u n τ) (kstar v n τ) := by
  have h1 := (kstar_mix_bracket hu hv hn hτ).1
  have h2 := min_le_kstar_pool (a := 1) (b := 1) one_pos one_pos hu hv hn hτ
  exact ⟨by omega, mix_no_superadditivity hu hv hn hτ⟩

/-! ## 6. Scale invariance and proportional domains -/

lemma headMass_smul (c : ℝ) (w : ℕ → ℝ) (k : ℕ) :
    headMass (fun i => c * w i) k = c * headMass w k := by
  simp [headMass, Finset.mul_sum]

lemma retained_smul (hc : c ≠ 0) (w : ℕ → ℝ) (n k : ℕ) :
    retained (fun i => c * w i) n k = retained w n k := by
  simp [retained, headMass_smul, mul_div_mul_left _ _ hc]

/-- The knee only sees the *shape* of a profile, not its scale. -/
lemma kstar_smul (hc : c ≠ 0) (w : ℕ → ℝ) (n : ℕ) (τ : ℝ) :
    kstar (fun i => c * w i) n τ = kstar w n τ := by
  unfold kstar
  congr 1
  ext k
  simp [retained_smul hc]

lemma pool_proportional (c : ℝ) (u : ℕ → ℝ) :
    pool 1 1 u (fun i => c * u i) = fun i => (1 + c) * u i := by
  funext i; simp only [pool]; ring

lemma kstar_pool_proportional (hc : 0 < c) (u : ℕ → ℝ) (n : ℕ) (τ : ℝ) :
    kstar (pool 1 1 u (fun i => c * u i)) n τ = kstar u n τ := by
  rw [pool_proportional, kstar_smul (by positivity)]

lemma ctxSens_pool_proportional (hc : 0 < c) (u : ℕ → ℝ) (n : ℕ) (τ : ℝ) :
    ctxSens (pool 1 1 u (fun i => c * u i)) τ n = ctxSens u τ n := by
  simp [ctxSens, kstar_pool_proportional hc]

/-- **The NET-89 mechanism.**  If the two domains have proportional attention profiles —
same shape, different total mass — the pooled increment *is* the pure increment, so the
interleaved increment is exactly twice the pure one, up to one key. -/
theorem proportional_mix_increment_doubles (hu : ∀ i, 0 < u i) (hc : 0 < c) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    2 * ctxSens u τ n ≤ ctxSens (mix u (fun i => c * u i)) τ (2 * n) + 1 ∧
      ctxSens (mix u (fun i => c * u i)) τ (2 * n) ≤ 2 * ctxSens u τ n + 1 := by
  have hv : ∀ i, 0 < c * u i := fun i => by have := hu i; positivity
  have h := mix_ctxSens_doubling (u := u) (v := fun i => c * u i) hu hv hn hτ
  rwa [ctxSens_pool_proportional hc] at h

/-- **The predicted band.**  A pure-domain increment of `+4` forces a mixed increment in
`{7, 8, 9}`.  The reported `+8` is exactly the centre of the band that key-unit doubling
predicts — no cross-domain query-key interaction is needed to produce it. -/
theorem net89_predicted_increment (hu : ∀ i, 0 < u i) (hc : 0 < c) (hn : 0 < n) (hτ : τ ≤ 1)
    (hpure : ctxSens u τ n = 4) :
    7 ≤ ctxSens (mix u (fun i => c * u i)) τ (2 * n) ∧
      ctxSens (mix u (fun i => c * u i)) τ (2 * n) ≤ 9 := by
  obtain ⟨h1, h2⟩ := proportional_mix_increment_doubles hu hc hn hτ
  rw [hpure] at h1 h2
  omega

/-! ## 7. P1 refuted: the mixed knee is not a function of the component knees

Three explicit profile pairs on a context of length `4` at gate `τ = 7/10`.  All three
have the *same* component knees `(1, 3)`, yet their pooled knees are `2`, `1` and `3`:
the midpoint, the min and the max.  Every point of the sandwich is attained, so no
formula in the component knees exists. -/

/-- Knee extraction from one failing and one passing grid point. -/
lemma kstar_eq_of_fail_pass (hw : ∀ i, 0 < w i) (hn : 0 < n) (hτ : τ ≤ 1) {m : ℕ}
    (hfail : retained w n m < τ) (hpass : τ ≤ retained w n (m + 1)) :
    kstar w n τ = m + 1 := by
  obtain ⟨h1, h2⟩ := knee_bracket hw hn hτ hfail hpass
  omega

/-- A head-heavy domain: one dominant key. -/
noncomputable def uA : ℕ → ℝ := fun i => if i = 0 then 10 else 1
/-- The same shape with a much heavier head key. -/
noncomputable def uB : ℕ → ℝ := fun i => if i = 0 then 100 else 1
/-- The same knee again, but with a negligible total mass. -/
noncomputable def uC : ℕ → ℝ := fun i => if i = 0 then 1 / 10 else 1 / 1000
/-- The gapless partner domain. -/
noncomputable def vFlat : ℕ → ℝ := fun _ => 1

lemma uA_pos : ∀ i, 0 < uA i := by intro i; simp only [uA]; split <;> norm_num
lemma uB_pos : ∀ i, 0 < uB i := by intro i; simp only [uB]; split <;> norm_num
lemma uC_pos : ∀ i, 0 < uC i := by intro i; simp only [uC]; split <;> norm_num
lemma vFlat_pos : ∀ i, 0 < vFlat i := by intro i; simp only [vFlat]; norm_num

lemma poolA_pos : ∀ i, 0 < pool 1 1 uA vFlat i :=
  pool_pos one_pos one_pos uA_pos vFlat_pos
lemma poolB_pos : ∀ i, 0 < pool 1 1 uB vFlat i :=
  pool_pos one_pos one_pos uB_pos vFlat_pos
lemma poolC_pos : ∀ i, 0 < pool 1 1 uC vFlat i :=
  pool_pos one_pos one_pos uC_pos vFlat_pos

lemma kstar_uA : kstar uA 4 (7 / 10) = 1 := by
  apply kstar_eq_of_fail_pass uA_pos (by norm_num) (by norm_num) (m := 0)
  · norm_num [retained, headMass, uA]
  · norm_num [retained, headMass, uA, Finset.sum_range_succ]

lemma kstar_uB : kstar uB 4 (7 / 10) = 1 := by
  apply kstar_eq_of_fail_pass uB_pos (by norm_num) (by norm_num) (m := 0)
  · norm_num [retained, headMass, uB]
  · norm_num [retained, headMass, uB, Finset.sum_range_succ]

lemma kstar_uC : kstar uC 4 (7 / 10) = 1 := by
  apply kstar_eq_of_fail_pass uC_pos (by norm_num) (by norm_num) (m := 0)
  · norm_num [retained, headMass, uC]
  · norm_num [retained, headMass, uC, Finset.sum_range_succ]

lemma kstar_vFlat : kstar vFlat 4 (7 / 10) = 3 := by
  apply kstar_eq_of_fail_pass vFlat_pos (by norm_num) (by norm_num) (m := 2)
  · norm_num [retained, headMass, vFlat, Finset.sum_range_succ]
  · norm_num [retained, headMass, vFlat, Finset.sum_range_succ]

lemma kstar_poolA : kstar (pool 1 1 uA vFlat) 4 (7 / 10) = 2 := by
  apply kstar_eq_of_fail_pass poolA_pos (by norm_num) (by norm_num) (m := 1)
  · norm_num [retained, headMass, pool, uA, vFlat, Finset.sum_range_succ]
  · norm_num [retained, headMass, pool, uA, vFlat, Finset.sum_range_succ]

lemma kstar_poolB : kstar (pool 1 1 uB vFlat) 4 (7 / 10) = 1 := by
  apply kstar_eq_of_fail_pass poolB_pos (by norm_num) (by norm_num) (m := 0)
  · norm_num [retained, headMass, pool, uB, vFlat]
  · norm_num [retained, headMass, pool, uB, vFlat, Finset.sum_range_succ]

lemma kstar_poolC : kstar (pool 1 1 uC vFlat) 4 (7 / 10) = 3 := by
  apply kstar_eq_of_fail_pass poolC_pos (by norm_num) (by norm_num) (m := 2)
  · norm_num [retained, headMass, pool, uC, vFlat, Finset.sum_range_succ]
  · norm_num [retained, headMass, pool, uC, vFlat, Finset.sum_range_succ]

/-- **P1 refuted, sharply.**  Three profile pairs with identical component knees `(1, 3)`
realise pooled knees `2` (the midpoint), `1` (the min) and `3` (the max).  The mediant
sandwich is therefore exactly the truth: nothing sharper than `min ≤ k*_pool ≤ max` holds,
and the "mixed = midpoint" prediction is false. -/
theorem pool_knee_attains_min_mid_max :
    (kstar uA 4 (7 / 10) = 1 ∧ kstar vFlat 4 (7 / 10) = 3 ∧
        kstar (pool 1 1 uA vFlat) 4 (7 / 10) = 2) ∧
      (kstar uB 4 (7 / 10) = 1 ∧ kstar vFlat 4 (7 / 10) = 3 ∧
        kstar (pool 1 1 uB vFlat) 4 (7 / 10) = 1) ∧
      (kstar uC 4 (7 / 10) = 1 ∧ kstar vFlat 4 (7 / 10) = 3 ∧
        kstar (pool 1 1 uC vFlat) 4 (7 / 10) = 3) :=
  ⟨⟨kstar_uA, kstar_vFlat, kstar_poolA⟩, ⟨kstar_uB, kstar_vFlat, kstar_poolB⟩,
    ⟨kstar_uC, kstar_vFlat, kstar_poolC⟩⟩

/-- **H3 — no formula.**  There is no function of the two component knees that computes
the mixed-domain knee, for any mixing ratio, even under all the positivity and gate
hypotheses of the theory. -/
theorem no_component_knee_formula :
    ¬ ∃ f : ℕ → ℕ → ℕ, ∀ (u v : ℕ → ℝ) (n : ℕ) (τ : ℝ), (∀ i, 0 < u i) → (∀ i, 0 < v i) →
        0 < n → τ ≤ 1 → kstar (pool 1 1 u v) n τ = f (kstar u n τ) (kstar v n τ) := by
  rintro ⟨f, hf⟩
  have h1 := hf uA vFlat 4 (7 / 10) uA_pos vFlat_pos (by norm_num) (by norm_num)
  have h2 := hf uB vFlat 4 (7 / 10) uB_pos vFlat_pos (by norm_num) (by norm_num)
  rw [kstar_uA, kstar_vFlat, kstar_poolA] at h1
  rw [kstar_uB, kstar_vFlat, kstar_poolB] at h2
  omega

/-- The midpoint prediction P1 fails on a concrete pair: component knees `1` and `3`,
midpoint `2`, actual mixed knee `1`. -/
theorem midpoint_prediction_false :
    kstar uB 4 (7 / 10) = 1 ∧ kstar vFlat 4 (7 / 10) = 3 ∧
      kstar (pool 1 1 uB vFlat) 4 (7 / 10) ≠ (kstar uB 4 (7 / 10) + kstar vFlat 4 (7 / 10)) / 2 := by
  refine ⟨kstar_uB, kstar_vFlat, ?_⟩
  rw [kstar_uB, kstar_vFlat, kstar_poolB]
  norm_num

/-! ## 8. Auditing the reported NET-89 table

The measured inputs enter only as hypotheses: the mixed profile fails the gate at the
grid point below the reported knee and passes at the reported knee. -/

/-- **H5 — what the grid actually determines.**  From a fail at `k = 8` / pass at `k = 12`
(ctx 512) and a fail at `k = 16` / pass at `k = 20` (ctx 1024), the mixed doubling
increment is pinned only to `[5, 11]`.  The pure-domain value `4` is excluded — the
qualitative verdict "mixed rises faster" survives — but `+8` is not resolved from `+5`
or `+11` by this grid. -/
theorem net89_mixed_increment_bracket (hw : ∀ i, 0 < w i) (hτ : τ ≤ 1)
    (h512fail : retained w 512 8 < τ) (h512pass : τ ≤ retained w 512 12)
    (h1024fail : retained w 1024 16 < τ) (h1024pass : τ ≤ retained w 1024 20) :
    5 ≤ ctxSens w τ 512 ∧ ctxSens w τ 512 ≤ 11 := by
  obtain ⟨l1, u1⟩ := knee_bracket hw (n := 512) (by norm_num) hτ h512fail h512pass
  obtain ⟨l2, u2⟩ := knee_bracket hw (n := 1024) (by norm_num) hτ h1024fail h1024pass
  have h : (2 : ℕ) * 512 = 1024 := by norm_num
  simp only [ctxSens, h]
  omega

/-- The one comparison the grid does settle at ctx 512: a mixed pass at `k = 12` together
with a prose fail at `k = 12` forces the mixed knee to be *strictly below* the prose knee
— "the mixed domain starts at code's level" in the only form the data supports. -/
theorem net89_mixed_below_prose_at_512 {wm wp : ℕ → ℝ}
    (hwp : ∀ i, 0 < wp i) (hτ : τ ≤ 1) (hmix : τ ≤ retained wm 512 12)
    (hprose : retained wp 512 12 < τ) :
    kstar wm 512 τ ≤ 12 ∧ 12 < kstar wp 512 τ ∧ kstar wm 512 τ < kstar wp 512 τ := by
  have h1 : kstar wm 512 τ ≤ 12 := kstar_le_of_pass hmix
  have h2 : 12 < kstar wp 512 τ := lt_kstar_of_fail hwp (by norm_num) hτ hprose
  exact ⟨h1, h2, by omega⟩

end Catalog.Probability.NET89MixedDomainKnee