import Mathlib

/-!
# Adaptive smoothness bound `B` in the quadratic sieve: oracle-only gains

Round 43 measured, over 120 balanced 41-bit semiprimes and a 15-value ladder of
smoothness bounds `B`, the *paid touch* of a single-polynomial quadratic sieve on
a fixed interval of length `M`, and found:

* the closed form `2·M·Σ_{odd p} 1/p + M/2` predicts paid touch to `2·10⁻⁴`;
* the per-instance optimum `B*` moves, the oracle never loses (`0/120` worse);
* no free-feature rule recovers the oracle gain;
* `d log Q / d log m ≈ 0.997`.

This file proves the exact mathematical skeleton behind each of these four
observations.

1. **Two roots per odd prime** (`card_sq_roots_eq_two`): for an odd prime `p`
   and a nonzero square `a` in `ZMod p`, `x² = a` has exactly two roots.  This is
   where the factor `2` in the closed form comes from.
2. **Per-class touch count** (`classTouch_bounds`, `abs_classTouch_sub_le_one`):
   a root class `r mod p` meets `[0, M)` in `M/p` positions up to an error `< 1`.
3. **The paid-touch closed form with an explicit error bar**
   (`abs_paidTouch_sub_closedForm_le`, `abs_paidTouch_sub_qs_closedForm_le`):
   `|paidTouch − (2·M·Σ_{odd p} 1/p + M/2)| ≤ 2·|S| − 1`, so the relative
   deviation tends to zero like `|S| / M`.
4. **Oracle ≤ best free rule ≤ best fixed `B`** (`oracle_le_ruleCost`,
   `fiberBest_le_ruleCost`, `exists_rule_attaining_fiberBest`,
   `fiberBest_le_fixedCost`), and the exact **zero-gain characterisation**
   (`fiberBest_eq_fixedCost_iff`): a free feature yields *no* gain over the best
   fixed `B` iff one ladder value is simultaneously optimal on every fibre of the
   feature.  Its specialisation to the identity feature
   (`oracle_eq_fixedCost_iff`) says the oracle gain vanishes iff one `B` is
   optimal on every instance — so the measured `102/120` strict improvements
   prove the instances disagree, while the wash of free rules says the
   *feature fibres* do not.  `fiberBest_le_of_refines`: refining the feature
   never hurts in-sample.
5. **Overfitting** (`train_fit_rule_can_lose_on_test`): a train-optimal fibre
   rule can strictly beat the train-optimal fixed `B` on train and strictly lose
   to it on test — the `1.029×` regression outcome is not a paradox.
6. **`Q` tracks `m`** (`hasDerivAt_log_splitCount`, `elasticity_bounds`,
   `secant_elasticity_ge_one`, `secant_elasticity_le`): if the factor base has `m = Q + c` columns
   (`c` the fixed non-split columns such as `−1`, `2`), then
   `d log Q / d log m = m/(m−c) = 1 + c/Q`, and every secant slope lies in
   `[1, 1 + c/Q₁]`.  The observed `0.997` is therefore a
   *structural identity* up to `O(c/Q)` — the critic's point: this is not an
   independent empirical discovery but a bookkeeping consequence of how `m` is
   defined.
-/

namespace Catalog.MachineLearning.AdaptiveBOracleOnly

open Finset

/-! ## 1. Two roots of `x² = N` modulo an odd prime -/

/-- For an odd prime `p` and a nonzero square `a` of `ZMod p`, the congruence
`x² = a` has exactly two solutions. -/
theorem card_sq_roots_eq_two {p : ℕ} [hp : Fact p.Prime] (hp2 : p ≠ 2)
    {a : ZMod p} (ha : a ≠ 0) (hsq : IsSquare a) :
    (univ.filter (fun x : ZMod p => x ^ 2 = a)).card = 2 := by
  obtain ⟨r, hr⟩ := hsq
  have hr0 : r ≠ 0 := by
    rintro rfl
    exact ha (by simpa using hr)
  have htwo : (2 : ZMod p) ≠ 0 := by
    intro h
    have : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at this
    have := (Nat.prime_dvd_prime_iff_eq hp.out Nat.prime_two).mp this
    exact hp2 this
  have hne : r ≠ -r := by
    intro h
    have : (2 : ZMod p) * r = 0 := by
      have : r + r = 0 := by
        calc r + r = r + -r := by rw [← h]
          _ = 0 := by ring
      linear_combination this
    rcases mul_eq_zero.mp this with h2 | h2
    · exact htwo h2
    · exact hr0 h2
  have hset : univ.filter (fun x : ZMod p => x ^ 2 = a) = {r, -r} := by
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    rw [hr, ← sq_eq_sq_iff_eq_or_eq_neg]
    constructor <;> intro h <;> linear_combination h
  rw [hset, card_pair hne]

/-! ## 2. Touch count of one root class -/

/-- Number of sieve positions `x ∈ [0, M)` touched by the root class `r mod p`. -/
def classTouch (M p r : ℕ) : ℕ := ((range M).filter (fun x => x % p = r)).card

theorem classTouch_eq (M p r : ℕ) (hp : 0 < p) (hr : r < p) :
    classTouch M p r = M / p + if r < M % p then 1 else 0 := by
  have h := Nat.count_modEq_card M hp r
  rw [Nat.count_eq_card_filter_range, Nat.mod_eq_of_lt hr] at h
  rw [classTouch, ← h]
  congr 1
  apply Finset.filter_congr
  intro x _
  unfold Nat.ModEq
  rw [Nat.mod_eq_of_lt hr]

/-- Two-sided bound: `p · classTouch` is within `p` of `M`. -/
theorem classTouch_bounds (M p r : ℕ) (hp : 0 < p) (hr : r < p) :
    M < p * classTouch M p r + p ∧ p * classTouch M p r ≤ M + p := by
  rw [classTouch_eq M p r hp hr]
  have h1 := Nat.div_add_mod M p
  have h2 := Nat.mod_lt M hp
  have h3 := Nat.mul_div_le M p
  split_ifs with h
  · constructor <;> nlinarith
  · simp only [add_zero]; constructor <;> nlinarith

/-- In real numbers: a root class touches `M/p` positions up to an error `≤ 1`. -/
theorem abs_classTouch_sub_le_one (M p r : ℕ) (hp : 0 < p) (hr : r < p) :
    |(classTouch M p r : ℝ) - M / p| ≤ 1 := by
  obtain ⟨h1, h2⟩ := classTouch_bounds M p r hp hr
  have hpR : (0 : ℝ) < p := by exact_mod_cast hp
  have h1' : (M : ℝ) < p * classTouch M p r + p := by exact_mod_cast h1
  have h2' : (p : ℝ) * classTouch M p r ≤ M + p := by exact_mod_cast h2
  have hq : (p : ℝ) * ((M : ℝ) / p) = M := by field_simp
  rw [abs_le]
  constructor <;> nlinarith

/-! ## 3. Paid touch and its closed form -/

/-- Paid touch of a sieve over `[0, M)` with factor base `S`, where the prime
`p` contributes its root classes `roots p`. -/
def paidTouch (M : ℕ) (S : Finset ℕ) (roots : ℕ → Finset ℕ) : ℕ :=
  ∑ p ∈ S, ∑ r ∈ roots p, classTouch M p r

/-- General closed form with error bar: paid touch equals
`M · Σ_p ρ(p)/p` up to the total number of root classes. -/
theorem abs_paidTouch_sub_closedForm_le (M : ℕ) (S : Finset ℕ)
    (roots : ℕ → Finset ℕ) (hpos : ∀ p ∈ S, 0 < p)
    (hroots : ∀ p ∈ S, ∀ r ∈ roots p, r < p) :
    |(paidTouch M S roots : ℝ) - M * ∑ p ∈ S, ((roots p).card : ℝ) / p|
      ≤ ∑ p ∈ S, ((roots p).card : ℝ) := by
  have key : (paidTouch M S roots : ℝ) - M * ∑ p ∈ S, ((roots p).card : ℝ) / p
      = ∑ p ∈ S, ∑ r ∈ roots p, ((classTouch M p r : ℝ) - M / p) := by
    rw [paidTouch, Nat.cast_sum, mul_sum, ← sum_sub_distrib]
    refine sum_congr rfl fun p _ => ?_
    rw [Nat.cast_sum, sum_sub_distrib, sum_const, nsmul_eq_mul]
    ring
  rw [key]
  calc |∑ p ∈ S, ∑ r ∈ roots p, ((classTouch M p r : ℝ) - M / p)|
      ≤ ∑ p ∈ S, |∑ r ∈ roots p, ((classTouch M p r : ℝ) - M / p)| :=
        abs_sum_le_sum_abs _ _
    _ ≤ ∑ p ∈ S, ∑ r ∈ roots p, |((classTouch M p r : ℝ) - M / p)| :=
        sum_le_sum fun p _ => abs_sum_le_sum_abs _ _
    _ ≤ ∑ p ∈ S, ∑ _r ∈ roots p, (1 : ℝ) :=
        sum_le_sum fun p hp => sum_le_sum fun r hr =>
          abs_classTouch_sub_le_one M p r (hpos p hp) (hroots p hp r hr)
    _ = ∑ p ∈ S, ((roots p).card : ℝ) := by simp

/-- **The quadratic-sieve closed form.**  If `2 ∈ S` carries one root class and
every other prime of `S` carries two (as forced by `card_sq_roots_eq_two`), then
`paidTouch = 2·M·Σ_{p ∈ S, p ≠ 2} 1/p + M/2` up to `2·|S| − 1`. -/
theorem abs_paidTouch_sub_qs_closedForm_le (M : ℕ) (S : Finset ℕ)
    (roots : ℕ → Finset ℕ) (hpos : ∀ p ∈ S, 0 < p)
    (hroots : ∀ p ∈ S, ∀ r ∈ roots p, r < p) (h2 : 2 ∈ S)
    (hc2 : (roots 2).card = 1) (hodd : ∀ p ∈ S, p ≠ 2 → (roots p).card = 2) :
    |(paidTouch M S roots : ℝ) - (2 * M * ∑ p ∈ S.erase 2, (1 : ℝ) / p + M / 2)|
      ≤ 2 * (S.card : ℝ) - 1 := by
  have h := abs_paidTouch_sub_closedForm_le M S roots hpos hroots
  have hsplit1 : ∑ p ∈ S, ((roots p).card : ℝ) / p
      = 2 * ∑ p ∈ S.erase 2, (1 : ℝ) / p + 1 / 2 := by
    rw [← add_sum_erase S _ h2, hc2, mul_sum, add_comm]
    congr 1
    · refine sum_congr rfl fun p hp => ?_
      rw [hodd p (mem_of_mem_erase hp) (ne_of_mem_erase hp)]
      push_cast; ring
    · norm_num
  have hsplit2 : ∑ p ∈ S, ((roots p).card : ℝ) = 2 * (S.card : ℝ) - 1 := by
    rw [← add_sum_erase S _ h2, hc2]
    rw [sum_congr rfl (g := fun _ => (2 : ℝ)) (fun p hp => by
      rw [hodd p (mem_of_mem_erase hp) (ne_of_mem_erase hp)]; norm_num)]
    rw [sum_const, card_erase_of_mem h2, nsmul_eq_mul]
    have : 1 ≤ S.card := card_pos.mpr ⟨2, h2⟩
    push_cast [this]
    ring
  rw [hsplit1, hsplit2] at h
  calc _ = |(paidTouch M S roots : ℝ) - M * (2 * ∑ p ∈ S.erase 2, (1 : ℝ) / p + 1 / 2)| := by
        congr 1; ring
    _ ≤ _ := h

/-! ## 4. Oracle, free rules and fixed `B` -/

section Oracle

variable {ι β κ : Type*} [DecidableEq κ]

/-- Total cost of the oracle that picks the best ladder value per instance. -/
noncomputable def oracleCost (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) : ℝ :=
  ∑ i ∈ I, L.inf' hL (c i)

/-- Total cost of a fixed ladder value `b`. -/
def fixedCost (I : Finset ι) (c : ι → β → ℝ) (b : β) : ℝ := ∑ i ∈ I, c i b

/-- Total cost of a free rule `g` reading the feature `φ`. -/
def ruleCost (I : Finset ι) (c : ι → β → ℝ) (φ : ι → κ) (g : κ → β) : ℝ :=
  ∑ i ∈ I, c i (g (φ i))

/-- Cost of a single feature fibre `f` at ladder value `b`. -/
def fiberCost (I : Finset ι) (c : ι → β → ℝ) (φ : ι → κ) (f : κ) (b : β) : ℝ :=
  ∑ i ∈ I with φ i = f, c i b

/-- The best achievable free-rule cost: per fibre, the best fixed ladder value. -/
noncomputable def fiberBest (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) (φ : ι → κ) : ℝ :=
  ∑ f ∈ I.image φ, L.inf' hL (fiberCost I c φ f)

/-- Per instance the oracle never loses (the `0/120 worsened` count). -/
theorem oracle_pointwise_le (L : Finset β) (hL : L.Nonempty) (c : ι → β → ℝ)
    (i : ι) {b : β} (hb : b ∈ L) : L.inf' hL (c i) ≤ c i b :=
  inf'_le _ hb

theorem ruleCost_eq_sum_fiberCost (I : Finset ι) (c : ι → β → ℝ) (φ : ι → κ)
    (g : κ → β) : ruleCost I c φ g = ∑ f ∈ I.image φ, fiberCost I c φ f (g f) := by
  unfold ruleCost fiberCost
  rw [sum_image' (fun i => c i (g (φ i)))]
  intro i hi
  refine sum_congr rfl fun j hj => ?_
  rw [(mem_filter.mp hj).2]

theorem fixedCost_eq_sum_fiberCost (I : Finset ι) (c : ι → β → ℝ) (φ : ι → κ)
    (b : β) : fixedCost I c b = ∑ f ∈ I.image φ, fiberCost I c φ f b :=
  ruleCost_eq_sum_fiberCost I c φ (fun _ => b)

omit [DecidableEq κ] in
/-- The oracle is at least as good as every rule with values in the ladder. -/
theorem oracle_le_ruleCost (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) (φ : ι → κ) (g : κ → β) (hg : ∀ f, g f ∈ L) :
    oracleCost I L hL c ≤ ruleCost I c φ g :=
  sum_le_sum fun i _ => inf'_le _ (hg (φ i))

/-- `fiberBest` is a lower bound for every free rule. -/
theorem fiberBest_le_ruleCost (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) (φ : ι → κ) (g : κ → β) (hg : ∀ f, g f ∈ L) :
    fiberBest I L hL c φ ≤ ruleCost I c φ g := by
  rw [ruleCost_eq_sum_fiberCost, fiberBest]
  exact sum_le_sum fun f _ => inf'_le _ (hg f)

/-- ... and it is attained: the per-fibre argmin rule. -/
theorem exists_rule_attaining_fiberBest (I : Finset ι) (L : Finset β)
    (hL : L.Nonempty) (c : ι → β → ℝ) (φ : ι → κ) :
    ∃ g : κ → β, (∀ f, g f ∈ L) ∧ ruleCost I c φ g = fiberBest I L hL c φ := by
  classical
  choose g hgL hgmin using fun f => exists_min_image L (fiberCost I c φ f) hL
  refine ⟨g, hgL, ?_⟩
  rw [ruleCost_eq_sum_fiberCost, fiberBest]
  refine sum_congr rfl fun f _ => le_antisymm ?_ (inf'_le _ (hgL f))
  exact le_inf' _ _ fun b hb => hgmin f b hb

/-- The oracle lower-bounds even the best free rule. -/
theorem oracle_le_fiberBest (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) (φ : ι → κ) : oracleCost I L hL c ≤ fiberBest I L hL c φ := by
  obtain ⟨g, hg, hEq⟩ := exists_rule_attaining_fiberBest I L hL c φ
  rw [← hEq]; exact oracle_le_ruleCost I L hL c φ g hg

/-- The best free rule is at least as good as any fixed ladder value. -/
theorem fiberBest_le_fixedCost (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) (φ : ι → κ) {b : β} (hb : b ∈ L) :
    fiberBest I L hL c φ ≤ fixedCost I c b :=
  fiberBest_le_ruleCost I L hL c φ (fun _ => b) (fun _ => hb)

/-- **Zero-gain characterisation.**  A free feature `φ` gives no improvement
over the fixed value `b` iff `b` is simultaneously optimal on every fibre of `φ`. -/
theorem fiberBest_eq_fixedCost_iff (I : Finset ι) (L : Finset β) (hL : L.Nonempty)
    (c : ι → β → ℝ) (φ : ι → κ) {b : β} (hb : b ∈ L) :
    fiberBest I L hL c φ = fixedCost I c b ↔
      ∀ f ∈ I.image φ, ∀ b' ∈ L, fiberCost I c φ f b ≤ fiberCost I c φ f b' := by
  rw [fixedCost_eq_sum_fiberCost I c φ b, fiberBest]
  constructor
  · intro h f hf b' hb'
    have hle : ∀ f ∈ I.image φ, L.inf' hL (fiberCost I c φ f) ≤ fiberCost I c φ f b :=
      fun f _ => inf'_le _ hb
    have hall := (sum_eq_sum_iff_of_le hle).mp h f hf
    rw [← hall]
    exact inf'_le _ hb'
  · intro h
    refine sum_congr rfl fun f hf => le_antisymm (inf'_le _ hb) ?_
    exact le_inf' _ _ fun b' hb' => h f hf b' hb'

/-- Specialisation to the identity feature: the oracle gains nothing over fixed
`b` iff `b` is optimal on every single instance. -/
theorem oracle_eq_fixedCost_iff [DecidableEq ι] (I : Finset ι) (L : Finset β)
    (hL : L.Nonempty) (c : ι → β → ℝ) {b : β} (hb : b ∈ L) :
    oracleCost I L hL c = fixedCost I c b ↔ ∀ i ∈ I, ∀ b' ∈ L, c i b ≤ c i b' := by
  unfold oracleCost fixedCost
  constructor
  · intro h i hi b' hb'
    have hle : ∀ i ∈ I, L.inf' hL (c i) ≤ c i b := fun i _ => inf'_le _ hb
    rw [← (sum_eq_sum_iff_of_le hle).mp h i hi]
    exact inf'_le _ hb'
  · intro h
    refine sum_congr rfl fun i hi => le_antisymm (inf'_le _ hb) ?_
    exact le_inf' _ _ fun b' hb' => h i hi b' hb'

/-- A strict oracle gain on even one instance (the measured `102/120`) forces
the oracle strictly below every fixed ladder value. -/
theorem oracle_lt_fixedCost_of_strict [DecidableEq ι] (I : Finset ι) (L : Finset β)
    (hL : L.Nonempty) (c : ι → β → ℝ) {b : β} (hb : b ∈ L) {i : ι} (hi : i ∈ I)
    {b' : β} (hb' : b' ∈ L) (hlt : c i b' < c i b) :
    oracleCost I L hL c < fixedCost I c b := by
  refine lt_of_le_of_ne (oracle_le_ruleCost I L hL c id (fun _ => b) (fun _ => hb)) ?_
  intro h
  exact absurd ((oracle_eq_fixedCost_iff I L hL c hb).mp h i hi b' hb') (not_le.mpr hlt)

/-- **Refinement monotonicity.**  If the feature `ψ` refines `φ` (`φ = h ∘ ψ`),
the best `ψ`-rule is in-sample at least as good as the best `φ`-rule.  Richer
features never hurt on the training set — which is exactly why the held-out
comparison (Part 5) is the only meaningful one. -/
theorem fiberBest_le_of_refines {κ' : Type*} [DecidableEq κ'] (I : Finset ι)
    (L : Finset β) (hL : L.Nonempty) (c : ι → β → ℝ) (ψ : ι → κ') (h : κ' → κ) :
    fiberBest I L hL c ψ ≤ fiberBest I L hL c (h ∘ ψ) := by
  obtain ⟨g, hg, hEq⟩ := exists_rule_attaining_fiberBest I L hL c (h ∘ ψ)
  rw [← hEq]
  exact fiberBest_le_ruleCost I L hL c ψ (g ∘ h) (fun _ => hg _)

end Oracle

/-! ## 5. A train-fit rule can lose on test -/

/-- Two instances per split, feature `Bool`, ladder `Bool`.  On train the
fibre-optimal rule `g = id` strictly beats the best fixed value `false`; on test
the same rule strictly loses to it. -/
theorem train_fit_rule_can_lose_on_test :
    ∃ (ctrain ctest : Bool → Bool → ℝ),
      -- `false` is the train-optimal fixed value
      fixedCost univ ctrain false < fixedCost univ ctrain true ∧
      -- the fibre rule `id` is train-optimal and strictly better than `false`
      ruleCost univ ctrain id id = fiberBest univ univ univ_nonempty ctrain id ∧
      ruleCost univ ctrain id id < fixedCost univ ctrain false ∧
      -- on test it strictly loses
      fixedCost univ ctest false < ruleCost univ ctest id id := by
  refine ⟨fun i b => if i then (if b then 9/10 else 1) else (if b then 6/5 else 1),
    fun i b => if i then (if b then 3/2 else 1) else 1, ?_, ?_, ?_, ?_⟩
  · simp [fixedCost]; norm_num
  · apply le_antisymm _ (fiberBest_le_ruleCost _ _ _ _ _ _ (fun _ => mem_univ _))
    simp only [fiberBest, ruleCost, fiberCost, Fintype.sum_bool, Finset.image_id]
    simp
    norm_num [Finset.filter_eq', Finset.inf'_insert]
  · simp [ruleCost, fixedCost]; norm_num
  · simp [ruleCost, fixedCost]; norm_num

/-! ## 6. `Q` tracks `m` -/

/-- If the factor base has `m = e^t` columns of which `c` are not split primes,
then `log Q = log (m − c)` has derivative `m/(m−c)` with respect to `log m = t`. -/
theorem hasDerivAt_log_splitCount (c t : ℝ) (h : c < Real.exp t) :
    HasDerivAt (fun s => Real.log (Real.exp s - c))
      (Real.exp t / (Real.exp t - c)) t := by
  have hpos : Real.exp t - c ≠ 0 := by linarith
  have h1 : HasDerivAt (fun s => Real.exp s - c) (Real.exp t) t :=
    (Real.hasDerivAt_exp t).sub_const c
  have := h1.log hpos
  simpa using this

/-- The elasticity `m/(m−c)` equals `1 + c/Q` with `Q = m − c`, and lies in
`[1, 1 + c/Q]` — so it tends to `1` as the split-prime count grows. -/
theorem elasticity_bounds (m c : ℝ) (hc : 0 ≤ c) (hcm : c < m) :
    m / (m - c) = 1 + c / (m - c) ∧ 1 ≤ m / (m - c) := by
  have hQ : 0 < m - c := by linarith
  refine ⟨by field_simp; ring, ?_⟩
  rw [le_div_iff₀ hQ]; linarith

/-- Secant version: between any two factor-base sizes `m₁ < m₂` (with `c < m₁`
fixed non-split columns), `log Q` grows at least as fast as `log m`. -/
theorem secant_elasticity_ge_one (m₁ m₂ c : ℝ) (hc : 0 ≤ c) (hc1 : c < m₁)
    (h12 : m₁ ≤ m₂) :
    Real.log (m₂ / m₁) ≤ Real.log ((m₂ - c) / (m₁ - c)) := by
  have hm1 : 0 < m₁ := by linarith
  have hQ1 : 0 < m₁ - c := by linarith
  apply Real.log_le_log (div_pos (by linarith) hm1)
  rw [div_le_div_iff₀ hm1 hQ1]
  nlinarith

/-- Secant upper bound (concavity of `log Q` in `log m`): between `m₁ ≤ m₂`,
`log(Q₂/Q₁) ≤ (m₁/(m₁−c)) · log(m₂/m₁)`.  Together with
`secant_elasticity_ge_one`, every secant slope of `log Q` against `log m` lies in
`[1, 1 + c/Q₁]`. -/
theorem secant_elasticity_le (m₁ m₂ c : ℝ) (hc : 0 ≤ c) (hc1 : c < m₁)
    (h12 : m₁ ≤ m₂) :
    Real.log ((m₂ - c) / (m₁ - c)) ≤ m₁ / (m₁ - c) * Real.log (m₂ / m₁) := by
  have hm1 : 0 < m₁ := by linarith
  have hQ1 : 0 < m₁ - c := by linarith
  set e := m₁ / (m₁ - c) with he
  have he1 : 1 ≤ e := (elasticity_bounds m₁ c hc hc1).2
  set s := m₂ / m₁ - 1 with hs
  have hs0 : 0 ≤ s := by
    rw [hs, sub_nonneg, le_div_iff₀ hm1]; linarith
  have hbern := one_add_mul_self_le_rpow_one_add (by linarith : (-1 : ℝ) ≤ s) he1
  have hlhs : (m₂ - c) / (m₁ - c) = 1 + e * s := by
    rw [he, hs]; field_simp; ring
  have hx : 1 + s = m₂ / m₁ := by rw [hs]; ring
  rw [hlhs, ← Real.log_rpow (div_pos (by linarith) hm1), ← hx]
  exact Real.log_le_log (by positivity) hbern

end Catalog.MachineLearning.AdaptiveBOracleOnly