import Mathlib

/-!
# The knee of an attention budget: grids, dilution, and the French anomaly (NET-72)

This file formalises the structural content of the NET-72 measurement
**THE-FRENCH-KNEE-EXCEEDS-THE-GRID**.

The empirical situation: a limited-memory (top-`k` key retention) sweep over the
budget grid `{…, 24}` at context 512 and `{…, 32}` at context 1024 found that on
French prose *no* grid point reached the retention bar (`0.9648` and `0.9680`
retained at the best grid point).  On English prose, code and mathematics the
knee had always been inside the grid, and the observed domain shifts were small
(`±4` keys — "one fine-step").  French broke the bracket.

We prove five things about the underlying mathematics, using an **attention
profile** `p : ℕ → ℝ` (the attention mass carried by the `i`-th most important
key, so `p` is nonnegative and antitone), its prefix mass `prefixMass p k`
(the mass retained by a budget of `k` keys), and the **knee**
`knee p tau = sInf {k | tau ≤ prefixMass p k}` (the least budget meeting the bar).

* `knee_exceeds_grid`, `knee_exceeds_grid_max`, `net72_french_knee_beyond_grid` —
  the honest reading of a failed sweep: if every grid point falls below the bar
  then the knee is *strictly larger than every grid point*.  A grid can only ever
  certify a **lower** bound on the knee.
* `grid_underdetermines_knee` — and that lower bound is all one gets: for every
  target `N` beyond the grid there is a profile with *exactly the same retention
  at every grid point*, and knee exactly `N`.  So "knee > 32" is not evidence for
  "knee = 36"; the size of the excess is invisible to the sweep.
* `dilution_law` — the tokenisation mechanism, exactly.  If a domain shift splits
  every semantic unit into `r` tokens of equal share (mass-preserving dilution
  `tokenSplit`), then the knee scales *multiplicatively*:
  `r * (knee p tau - 1) < knee (tokenSplit r p) tau ≤ r * knee p tau`.
  Both ends are attained (`dilution_upper_sharp`, `dilution_lower_sharp`), so the
  sandwich cannot be tightened.
* `no_additive_domain_shift_law` — the refutation of the "±4 fine-step" law:
  for **every** offset `d` there is a profile and a tokens-per-word ratio for
  which the knee jumps by more than `d`.  A multiplicative law admits no uniform
  additive bracket, which is precisely why French escaped the grid.
* `accuracy_knee_decoupling` — full-context accuracy and the knee are logically
  independent: two domains with the *same* accuracies can have the knee ordering
  in either direction ("code: easier and cheaper", "French: easier and dearer").

All constants are explicit; nothing is asymptotic.
-/

namespace Catalog.Novelty.KneeDilutionGrid

open Finset

/-! ### 1. Profiles, retained mass, and the knee -/

/-- Mass retained by a budget of `k` keys: the sum of the `k` largest attention
weights, when `p` lists the weights in nonincreasing order. -/
def prefixMass (p : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ range k, p i

/-- The **knee**: the least key budget whose retained mass meets the bar `tau`. -/
noncomputable def knee (p : ℕ → ℝ) (tau : ℝ) : ℕ := sInf {k | tau ≤ prefixMass p k}

@[simp] lemma prefixMass_zero (p : ℕ → ℝ) : prefixMass p 0 = 0 := by simp [prefixMass]

lemma prefixMass_succ (p : ℕ → ℝ) (k : ℕ) :
    prefixMass p (k + 1) = prefixMass p k + p k := Finset.sum_range_succ _ _

/-- Retention is monotone in the budget. -/
lemma prefixMass_mono {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) : Monotone (prefixMass p) := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset_of_nonneg (by simpa using hab) fun i _ _ => hp i

lemma prefixMass_add (p q : ℕ → ℝ) (k : ℕ) :
    prefixMass (fun i => p i + q i) k = prefixMass p k + prefixMass q k := by
  simp [prefixMass, Finset.sum_add_distrib]

lemma prefixMass_const_mul (c : ℝ) (p : ℕ → ℝ) (k : ℕ) :
    prefixMass (fun i => c * p i) k = c * prefixMass p k := by
  simp [prefixMass, Finset.mul_sum]

lemma knee_le_of_le {p : ℕ → ℝ} {tau : ℝ} {k : ℕ} (h : tau ≤ prefixMass p k) :
    knee p tau ≤ k := Nat.sInf_le h

lemma le_prefixMass_knee {p : ℕ → ℝ} {tau : ℝ} (hex : ∃ k, tau ≤ prefixMass p k) :
    tau ≤ prefixMass p (knee p tau) := Nat.sInf_mem hex

/-- Below the knee the bar is missed: this is the minimality of the knee. -/
lemma prefixMass_lt_of_lt_knee {p : ℕ → ℝ} {tau : ℝ} {k : ℕ} (h : k < knee p tau) :
    prefixMass p k < tau := by
  have := Nat.notMem_of_lt_sInf h
  simpa [Set.mem_setOf_eq, not_le] using this

/-- Characterisation of the knee by a witness plus minimality. -/
lemma knee_eq_of {p : ℕ → ℝ} {tau : ℝ} {K : ℕ} (hK : tau ≤ prefixMass p K)
    (hlt : ∀ j < K, prefixMass p j < tau) : knee p tau = K := by
  refine le_antisymm (Nat.sInf_le hK) ?_
  by_contra hcon
  push_neg at hcon
  exact absurd (le_prefixMass_knee ⟨K, hK⟩) (not_le.2 (hlt _ hcon))

/-! ### 2. A failed grid sweep bounds the knee only from below -/

/-- **The NET-72 gate, in general form.**  If a budget grid point `g` misses the
retention bar, the knee is strictly above `g`.  (Only monotonicity of retention
is used, so this is exactly what a sweep licenses — and no more.) -/
theorem knee_exceeds_grid {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ} {g : ℕ}
    (hex : ∃ k, tau ≤ prefixMass p k) (hfail : prefixMass p g < tau) :
    g < knee p tau := by
  by_contra hcon
  push_neg at hcon
  have h1 : tau ≤ prefixMass p (knee p tau) := le_prefixMass_knee hex
  have h2 : prefixMass p (knee p tau) ≤ prefixMass p g := prefixMass_mono hp hcon
  linarith

/-- The whole-grid version: if every point of a finite grid `G` misses the bar,
the knee exceeds `max G`. -/
theorem knee_exceeds_grid_max {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ} (G : Finset ℕ)
    (hG : G.Nonempty) (hex : ∃ k, tau ≤ prefixMass p k)
    (hfail : ∀ g ∈ G, prefixMass p g < tau) :
    G.max' hG < knee p tau :=
  knee_exceeds_grid hp hex (hfail _ (G.max'_mem hG))

/-- **The measured NET-72 cell (ctx 1024).**  Grid `{8, 16, 24, 32}`, bar `tau`;
every grid point measured below the bar; conclusion: the knee is at least `33`,
i.e. strictly beyond the grid.  This is the only conclusion the sweep supports. -/
theorem net72_french_knee_beyond_grid {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k)
    (h8 : prefixMass p 8 < tau) (h16 : prefixMass p 16 < tau)
    (h24 : prefixMass p 24 < tau) (h32 : prefixMass p 32 < tau) :
    33 ≤ knee p tau := by
  have key := knee_exceeds_grid_max hp ({8, 16, 24, 32} : Finset ℕ) ⟨8, by decide⟩ hex ?_
  · have hmax : ({8, 16, 24, 32} : Finset ℕ).max' ⟨8, by decide⟩ = 32 := by decide
    rw [hmax] at key
    omega
  · intro g hg
    fin_cases hg
    exacts [h8, h16, h24, h32]

/-! ### 3. Flat and two-level profiles (the calibration objects) -/

/-- Flat profile: unit mass on each of the first `n` keys. -/
def unif (n : ℕ) : ℕ → ℝ := fun i => if i < n then 1 else 0

lemma unif_nonneg (n : ℕ) : ∀ i, 0 ≤ unif n i := by
  intro i; unfold unif; split_ifs <;> norm_num

lemma unif_antitone (n : ℕ) : Antitone (unif n) := by
  refine antitone_nat_of_succ_le ?_
  intro i
  unfold unif
  split_ifs <;> first | omega | norm_num

lemma prefixMass_unif (n k : ℕ) : prefixMass (unif n) k = (min k n : ℕ) := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [prefixMass_succ, ih]
      unfold unif
      split_ifs with h
      · have hmin : min (k + 1) n = min k n + 1 := by omega
        rw [hmin]; push_cast; ring
      · have hmin : min (k + 1) n = min k n := by omega
        rw [hmin]; ring

/-- Scaled flat profile: mass `c` on each of the first `n` keys. -/
def scaled (c : ℝ) (n : ℕ) : ℕ → ℝ := fun i => c * unif n i

lemma scaled_nonneg {c : ℝ} (hc : 0 ≤ c) (n : ℕ) : ∀ i, 0 ≤ scaled c n i := fun i =>
  mul_nonneg hc (unif_nonneg n i)

lemma scaled_antitone {c : ℝ} (hc : 0 ≤ c) (n : ℕ) : Antitone (scaled c n) := by
  intro a b hab
  exact mul_le_mul_of_nonneg_left (unif_antitone n hab) hc

lemma prefixMass_scaled (c : ℝ) (n k : ℕ) :
    prefixMass (scaled c n) k = c * (min k n : ℕ) := by
  unfold scaled
  rw [prefixMass_const_mul, prefixMass_unif]

lemma unif_eq_scaled (n : ℕ) : unif n = scaled 1 n := by funext i; simp [scaled]

/-- Knee of a flat profile: the least `K` with `tau ≤ c * K`. -/
lemma knee_scaled {c : ℝ} {n K : ℕ} (hKn : K ≤ n) {tau : ℝ}
    (h1 : tau ≤ c * K) (h2 : ∀ j < K, c * j < tau) : knee (scaled c n) tau = K := by
  refine knee_eq_of ?_ ?_
  · rw [prefixMass_scaled]
    have hmin : min K n = K := by omega
    rw [hmin]; exact h1
  · intro j hj
    rw [prefixMass_scaled]
    have hmin : min j n = j := by omega
    rw [hmin]; exact h2 j hj

/-! ### 4. A grid reading determines nothing above the grid -/

/-- Two-level profile: height `1` on the first `g` keys, height `c` on keys
`g, …, N-1`, then zero. -/
def twoLevel (g N : ℕ) (c : ℝ) : ℕ → ℝ := fun i => unif g i + c * (unif N i - unif g i)

lemma twoLevel_apply {g N : ℕ} (hgN : g ≤ N) (c : ℝ) (i : ℕ) :
    twoLevel g N c i = if i < g then 1 else if i < N then c else 0 := by
  unfold twoLevel unif
  split_ifs <;> first | omega | ring

lemma twoLevel_nonneg {g N : ℕ} (hgN : g ≤ N) {c : ℝ} (hc : 0 ≤ c) :
    ∀ i, 0 ≤ twoLevel g N c i := by
  intro i
  rw [twoLevel_apply hgN]
  split_ifs <;> first | exact hc | norm_num

lemma twoLevel_antitone {g N : ℕ} (hgN : g ≤ N) {c : ℝ} (hc0 : 0 ≤ c) (hc1 : c ≤ 1) :
    Antitone (twoLevel g N c) := by
  refine antitone_nat_of_succ_le ?_
  intro i
  rw [twoLevel_apply hgN, twoLevel_apply hgN]
  split_ifs <;> first | omega | linarith

lemma prefixMass_twoLevel (g N : ℕ) (c : ℝ) (k : ℕ) :
    prefixMass (twoLevel g N c) k = (min k g : ℕ) + c * ((min k N : ℕ) - (min k g : ℕ)) := by
  unfold twoLevel
  rw [prefixMass_add (unif g) (fun i => c * (unif N i - unif g i)) k, prefixMass_unif]
  congr 1
  have h : (fun i => c * (unif N i - unif g i)) = fun i => c * unif N i + (-c) * unif g i := by
    funext i; ring
  rw [h, prefixMass_add, prefixMass_const_mul, prefixMass_const_mul,
    prefixMass_unif, prefixMass_unif]
  ring

/-- **A grid sweep underdetermines the knee.**  Fix a grid ceiling `g` and a bar
`tau = g + 1`.  For every target `N > g` there is a nonnegative antitone profile
whose retention agrees with the flat profile at *every* budget `k ≤ g` (hence at
every grid point, all of them below the bar) and whose knee is exactly `N`.
So "the knee exceeds the grid" is the entire content of a failed sweep: the size
of the excess is invisible to it. -/
theorem grid_underdetermines_knee (g N : ℕ) (hgN : g < N) :
    ∃ p : ℕ → ℝ, (∀ i, 0 ≤ p i) ∧ Antitone p ∧
      (∀ k ≤ g, prefixMass p k = k) ∧
      (∀ k ≤ g, prefixMass p k < (g : ℝ) + 1) ∧
      (∀ k, N ≤ k → prefixMass p k = (g : ℝ) + 1) ∧
      knee p ((g : ℝ) + 1) = N := by
  have hNg : (0 : ℝ) < (N : ℝ) - g := by
    have : (g : ℝ) < N := by exact_mod_cast hgN
    linarith
  set c : ℝ := 1 / ((N : ℝ) - g) with hc
  have hc0 : 0 < c := by positivity
  have hc1 : c ≤ 1 := by
    rw [hc, div_le_one hNg]
    have : (g : ℝ) + 1 ≤ N := by exact_mod_cast hgN
    linarith
  refine ⟨twoLevel g N c, twoLevel_nonneg hgN.le hc0.le, twoLevel_antitone hgN.le hc0.le hc1,
    ?_, ?_, ?_, ?_⟩
  · intro k hk
    rw [prefixMass_twoLevel]
    have e1 : min k g = k := by omega
    have e2 : min k N = k := by omega
    rw [e1, e2]; ring
  · intro k hk
    rw [prefixMass_twoLevel]
    have e1 : min k g = k := by omega
    have e2 : min k N = k := by omega
    rw [e1, e2]
    have hkg : (k : ℝ) ≤ g := by exact_mod_cast hk
    simp only [sub_self, mul_zero, add_zero]
    linarith
  · intro k hk
    rw [prefixMass_twoLevel]
    have e1 : min k g = g := by omega
    have e2 : min k N = N := by omega
    rw [e1, e2, hc]
    field_simp
  · refine knee_eq_of ?_ ?_
    · rw [prefixMass_twoLevel]
      have e1 : min N g = g := by omega
      have e2 : min N N = N := by omega
      rw [e1, e2, hc]
      field_simp
      exact le_rfl
    · intro j hj
      rw [prefixMass_twoLevel]
      have e2 : min j N = j := by omega
      rw [e2, hc]
      rcases le_or_gt j g with h | h
      · have e1 : min j g = j := by omega
        rw [e1]
        have hjg : (j : ℝ) ≤ g := by exact_mod_cast h
        simp only [sub_self, mul_zero, add_zero]
        linarith
      · have e1 : min j g = g := by omega
        rw [e1]
        have hjg : (j : ℝ) - g < (N : ℝ) - g := by
          have : (j : ℝ) < N := by exact_mod_cast hj
          linarith
        rw [div_mul_eq_mul_div, one_mul]
        have hlt1 : ((j : ℝ) - g) / ((N : ℝ) - g) < 1 := (div_lt_one hNg).2 hjg
        linarith

/-! ### 5. The tokenisation mechanism: mass-preserving dilution -/

/-- **Token dilution.**  Each semantic unit `i` is spelt with `r` tokens, each
carrying an equal share `p i / r` of the unit's attention mass.  This is the
hypothesised mechanism behind the French anomaly: the tokenizer spends more
tokens per French word, so each individual token contributes less. -/
noncomputable def tokenSplit (r : ℕ) (p : ℕ → ℝ) : ℕ → ℝ := fun j => p (j / r) / r

lemma tokenSplit_nonneg {r : ℕ} {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    ∀ j, 0 ≤ tokenSplit r p j := fun j => div_nonneg (hp (j / r)) (Nat.cast_nonneg r)

/-- Dilution preserves the shape of a profile: the diluted profile is again
antitone (equal tokens inside a word, decreasing across words). -/
lemma tokenSplit_antitone {r : ℕ} {p : ℕ → ℝ} (hp : Antitone p) :
    Antitone (tokenSplit r p) := by
  intro a b hab
  have h : a / r ≤ b / r := Nat.div_le_div_right hab
  exact div_le_div_of_nonneg_right (hp h) (by positivity)

private lemma tokenSplit_blockSum (r : ℕ) (hr : 0 < r) (p : ℕ → ℝ) (m s : ℕ) (hs : s ≤ r) :
    ∑ i ∈ range s, tokenSplit r p (r * m + i) = s * (p m / r) := by
  have h : ∀ i ∈ range s, tokenSplit r p (r * m + i) = p m / r := by
    intro i hi
    have hir : i < r := lt_of_lt_of_le (mem_range.1 hi) hs
    simp only [tokenSplit]
    rw [Nat.mul_add_div hr, Nat.div_eq_of_lt hir]
    simp
  rw [Finset.sum_congr rfl h, Finset.sum_const, card_range, nsmul_eq_mul]

/-- Dilution is mass preserving on whole words: a budget of `r * m` diluted
tokens retains exactly what a budget of `m` undiluted keys retained. -/
theorem prefixMass_tokenSplit_block (r : ℕ) (hr : 0 < r) (p : ℕ → ℝ) (m : ℕ) :
    prefixMass (tokenSplit r p) (r * m) = prefixMass p m := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h1 : r * (m + 1) = r * m + r := by ring
      rw [h1]
      unfold prefixMass at *
      rw [Finset.sum_range_add, ih, Finset.sum_range_succ]
      congr 1
      rw [tokenSplit_blockSum r hr p m r le_rfl]
      field_simp

/-- Inside a word the retained mass grows linearly with the number of its tokens
that are kept. -/
theorem prefixMass_tokenSplit_partial (r : ℕ) (hr : 0 < r) (p : ℕ → ℝ) (m s : ℕ)
    (hs : s ≤ r) :
    prefixMass (tokenSplit r p) (r * m + s) = prefixMass p m + s * (p m / r) := by
  unfold prefixMass
  rw [Finset.sum_range_add]
  have hb := prefixMass_tokenSplit_block r hr p m
  unfold prefixMass at hb
  rw [hb, tokenSplit_blockSum r hr p m s hs]

/-- Upper half of the dilution law. -/
theorem knee_tokenSplit_le {r : ℕ} (hr : 0 < r) {p : ℕ → ℝ} {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k) :
    knee (tokenSplit r p) tau ≤ r * knee p tau := by
  refine knee_le_of_le ?_
  rw [prefixMass_tokenSplit_block r hr]
  exact le_prefixMass_knee hex

/-- Lower half of the dilution law. -/
theorem knee_tokenSplit_gt {r : ℕ} (hr : 0 < r) {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k) (hK : 0 < knee p tau) :
    r * (knee p tau - 1) < knee (tokenSplit r p) tau := by
  have hsplit_ex : ∃ k, tau ≤ prefixMass (tokenSplit r p) k :=
    ⟨r * knee p tau, by rw [prefixMass_tokenSplit_block r hr]; exact le_prefixMass_knee hex⟩
  refine knee_exceeds_grid (tokenSplit_nonneg hp) hsplit_ex ?_
  rw [prefixMass_tokenSplit_block r hr]
  exact prefixMass_lt_of_lt_knee (by omega)

/-- **The dilution law.**  A tokens-per-word ratio `r` multiplies the knee:
`r * (K - 1) < K_split ≤ r * K`.  The domain-shift tax is *multiplicative*, not
an additive fine-step. -/
theorem dilution_law {r : ℕ} (hr : 0 < r) {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k) (hK : 0 < knee p tau) :
    r * (knee p tau - 1) < knee (tokenSplit r p) tau ∧
      knee (tokenSplit r p) tau ≤ r * knee p tau :=
  ⟨knee_tokenSplit_gt hr hp hex hK, knee_tokenSplit_le hr hex⟩

/-- At a *fixed* budget `g`, dilution by `r` can retain no more than the
undiluted profile retains with `g / r + 1` keys: the mechanism converts a token
budget into a word budget. -/
theorem retained_tokenSplit_le {r : ℕ} (hr : 0 < r) {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (g : ℕ) :
    prefixMass (tokenSplit r p) g ≤ prefixMass p (g / r + 1) := by
  have hmod : g % r < r := Nat.mod_lt _ hr
  have hdm : r * (g / r) + g % r = g := Nat.div_add_mod g r
  have hle : g ≤ r * (g / r + 1) := by
    calc g = r * (g / r) + g % r := hdm.symm
      _ ≤ r * (g / r) + r := Nat.add_le_add_left hmod.le _
      _ = r * (g / r + 1) := by ring
  calc prefixMass (tokenSplit r p) g
      ≤ prefixMass (tokenSplit r p) (r * (g / r + 1)) :=
        prefixMass_mono (tokenSplit_nonneg hp) hle
    _ = prefixMass p (g / r + 1) := prefixMass_tokenSplit_block r hr p _

/-! ### 6. Sharpness of the dilution law -/

lemma tokenSplit_unif (r n : ℕ) (hr : 0 < r) :
    tokenSplit r (unif n) = scaled (1 / r) (r * n) := by
  funext j
  have hcomm : n * r = r * n := Nat.mul_comm n r
  simp only [tokenSplit, scaled, unif]
  by_cases h : j < r * n
  · have hj : j / r < n := by rw [Nat.div_lt_iff_lt_mul hr, hcomm]; exact h
    simp [hj, h]
  · have hj : ¬ j / r < n := by rw [Nat.div_lt_iff_lt_mul hr, hcomm]; exact h
    simp [hj, h]

/-- The upper end `r * K` of the dilution law is attained: a flat profile with an
integral bar. -/
theorem dilution_upper_sharp (r m n : ℕ) (hr : 0 < r) (hmn : m ≤ n) :
    knee (unif n) (m : ℝ) = m ∧ knee (tokenSplit r (unif n)) (m : ℝ) = r * m := by
  constructor
  · rw [unif_eq_scaled]
    refine knee_scaled hmn ?_ ?_
    · simp
    · intro j hj
      have hjm : (j : ℝ) < m := by exact_mod_cast hj
      simpa using hjm
  · rw [tokenSplit_unif r n hr]
    have hrR : (0 : ℝ) < r := by exact_mod_cast hr
    refine knee_scaled (Nat.mul_le_mul_left r hmn) ?_ ?_
    · push_cast
      field_simp
      exact le_rfl
    · intro j hj
      have hjR : (j : ℝ) < (r : ℝ) * m := by exact_mod_cast hj
      rw [div_mul_eq_mul_div, one_mul, div_lt_iff₀ hrR]
      linarith

/-- The lower end `r * (K - 1) + 1` of the dilution law is attained: a flat
profile with a bar just past a whole word.  Together with
`dilution_upper_sharp`, the sandwich in `dilution_law` is optimal on both
sides. -/
theorem dilution_lower_sharp (r m n : ℕ) (hr : 0 < r) (hm : 0 < m) (hmn : m ≤ n) :
    knee (unif n) ((m : ℝ) - 1 + 1 / r) = m ∧
      knee (tokenSplit r (unif n)) ((m : ℝ) - 1 + 1 / r) = r * (m - 1) + 1 := by
  have hrR : (0 : ℝ) < r := by exact_mod_cast hr
  have h1r : 1 / (r : ℝ) ≤ 1 := by
    rw [div_le_one hrR]; exact_mod_cast hr
  have hrpos : (0 : ℝ) < 1 / r := by positivity
  have hm1 : ((m - 1 : ℕ) : ℝ) = (m : ℝ) - 1 := by
    have h1 : 1 ≤ m := hm
    push_cast [Nat.cast_sub h1]; ring
  constructor
  · rw [unif_eq_scaled]
    refine knee_scaled hmn ?_ ?_
    · rw [one_mul]; linarith
    · intro j hj
      have hjm : ((j : ℝ) + 1) ≤ m := by exact_mod_cast hj
      rw [one_mul]; linarith
  · rw [tokenSplit_unif r n hr]
    refine knee_scaled ?_ ?_ ?_
    · have h1 : r * (m - 1) + r ≤ r * n := by
        have hle : (m - 1) + 1 ≤ n := by omega
        calc r * (m - 1) + r = r * ((m - 1) + 1) := by ring
          _ ≤ r * n := Nat.mul_le_mul_left r hle
      omega
    · have hcast : ((r * (m - 1) + 1 : ℕ) : ℝ) = (r : ℝ) * ((m : ℝ) - 1) + 1 := by
        push_cast [hm1]; ring
      rw [hcast]
      field_simp
      exact le_rfl
    · intro j hj
      have hjle : j ≤ r * (m - 1) := by omega
      have hjR : (j : ℝ) ≤ (r : ℝ) * ((m : ℝ) - 1) := by
        have h0 : ((r * (m - 1) : ℕ) : ℝ) = (r : ℝ) * ((m : ℝ) - 1) := by
          push_cast [hm1]; ring
        calc (j : ℝ) ≤ ((r * (m - 1) : ℕ) : ℝ) := by exact_mod_cast hjle
          _ = (r : ℝ) * ((m : ℝ) - 1) := h0
      rw [div_mul_eq_mul_div, one_mul, div_lt_iff₀ hrR]
      have hexp : ((m : ℝ) - 1 + 1 / r) * r = (r : ℝ) * ((m : ℝ) - 1) + 1 := by
        field_simp
      rw [hexp]
      linarith

/-! ### 7. No additive domain-shift law -/

/-- **All additive brackets fail.**  For every claimed fine-step `d` there is an
attention profile, a bar, and a tokens-per-word ratio for which the knee moves
by strictly more than `d`.  A `±4`-key domain-shift law is therefore impossible:
the tax is multiplicative, and language families sit whole grid ranges apart. -/
theorem no_additive_domain_shift_law (d : ℕ) :
    ∃ (p : ℕ → ℝ) (r : ℕ) (tau : ℝ),
      0 < r ∧ (∀ i, 0 ≤ p i) ∧ Antitone p ∧ (∃ k, tau ≤ prefixMass p k) ∧
        knee p tau + d < knee (tokenSplit r p) tau := by
  refine ⟨unif (d + 2), d + 2, ((d + 2 : ℕ) : ℝ), by omega, unif_nonneg _, unif_antitone _,
    ⟨d + 2, ?_⟩, ?_⟩
  · rw [prefixMass_unif]
    simp
  · have hkey := dilution_upper_sharp (d + 2) (d + 2) (d + 2) (by omega) le_rfl
    rw [hkey.1, hkey.2]
    nlinarith [Nat.zero_le d]

/-! ### 8. Accuracy and knee are logically independent -/

/-- A measured domain cell: full-context accuracy together with its attention
profile. -/
structure DomainCell where
  /-- full-context accuracy of the cell -/
  acc : ℝ
  /-- attention profile (weights in nonincreasing order) -/
  weight : ℕ → ℝ
  /-- attention weights are nonnegative -/
  nonneg : ∀ i, 0 ≤ weight i
  /-- attention weights are sorted -/
  anti : Antitone weight

/-- The knee of a domain cell at bar `tau`. -/
noncomputable def DomainCell.knee (D : DomainCell) (tau : ℝ) : ℕ :=
  Catalog.Novelty.KneeDilutionGrid.knee D.weight tau

/-- **Accuracy/knee decoupling, with both signs.**  There are four cells with
only two accuracy values `0 < 1` such that in one pair the higher accuracy comes
with the *larger* knee and in the other pair with the *smaller* knee.  Hence no
function (in particular no monotone one) sends full-context accuracy to the
memory knee: "code is easier and cheaper" and "French is easier and dearer" are
both realisable. -/
theorem accuracy_knee_decoupling :
    ∃ D1 D2 D3 D4 : DomainCell,
      D1.acc = D3.acc ∧ D2.acc = D4.acc ∧ D1.acc < D2.acc ∧
      D1.knee 1 < D2.knee 1 ∧ D4.knee 1 < D3.knee 1 := by
  have hA : knee (scaled 1 4) 1 = 1 := by
    refine knee_scaled (by omega) ?_ ?_
    · norm_num
    · intro j hj
      interval_cases j
      norm_num
  have hB : knee (scaled (1 / 2) 4) 1 = 2 := by
    refine knee_scaled (by omega) ?_ ?_
    · norm_num
    · intro j hj
      interval_cases j <;> norm_num
  refine ⟨⟨0, scaled 1 4, scaled_nonneg zero_le_one 4, scaled_antitone zero_le_one 4⟩,
          ⟨1, scaled (1 / 2) 4, scaled_nonneg (by norm_num) 4, scaled_antitone (by norm_num) 4⟩,
          ⟨0, scaled (1 / 2) 4, scaled_nonneg (by norm_num) 4, scaled_antitone (by norm_num) 4⟩,
          ⟨1, scaled 1 4, scaled_nonneg zero_le_one 4, scaled_antitone zero_le_one 4⟩,
          rfl, rfl, by norm_num, ?_, ?_⟩
  · show knee (scaled 1 4) 1 < knee (scaled (1 / 2) 4) 1
    rw [hA, hB]; omega
  · show knee (scaled 1 4) 1 < knee (scaled (1 / 2) 4) 1
    rw [hA, hB]; omega

end Catalog.Novelty.KneeDilutionGrid