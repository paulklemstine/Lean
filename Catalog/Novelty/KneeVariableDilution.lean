import Novelty.KneeDilutionGrid

/-!
# Variable tokenisation, the dilution semigroup, and geometric budget grids (NET-72, round 2)

This file continues `Novelty.KneeDilutionGrid`.  There the tokenisation tax was
modelled by a *uniform* tokens-per-word ratio `r`, and the knee was shown to obey
the multiplicative sandwich `r * (K - 1) < K_split ≤ r * K`.  Real tokenizers are
not uniform: French words cost a variable number of tokens.  Here we

* replace the uniform split by a **variable dilution** `varSplit w p`, where word
  `i` is spelt with `w i ≥ 1` tokens, each carrying an equal share `p i / w i`
  of that word's attention mass;
* prove `variable_dilution_law`: the knee of the diluted profile is sandwiched by
  the *cumulative token counts* of the top words,
  `cum w (K - 1) < knee (varSplit w p) tau ≤ cum w K`, where `K` is the undiluted
  knee.  This is the exact form of the NET-72 mechanism hypothesis: the knee is
  predicted by **tokens-per-word measured on the top-`K` words**, not by any
  additive domain offset;
* derive the two-sided consequence `variable_dilution_between_extremes` in terms
  of the smallest and largest tokens-per-word ratio;
* show the dilution operators form a semigroup, `tokenSplit_comp`, so successive
  domain shifts compose *multiplicatively* (`knee_tokenSplit_comp_le`);
* prove `geometric_grid_brackets_knee`: a geometric budget grid `1, 2, 4, 8, …`
  always brackets the knee within a factor `2`, however large the multiplicative
  tokenisation tax is.  This is the design consequence of the NET-72 failure:
  arithmetic grids (`8, 16, 24, 32`) are the wrong instrument for a
  multiplicative law, geometric grids are the right one.
-/

namespace Catalog.Novelty.KneeDilutionGrid

open Finset

/-! ### 1. The dilution semigroup -/

/-- Two successive uniform dilutions compose to a single one: splitting each
word into `s` tokens and then each token into `r` sub-tokens is exactly a split
into `r * s` tokens.  Domain shifts therefore compose multiplicatively. -/
theorem tokenSplit_comp (r s : ℕ) (p : ℕ → ℝ) :
    tokenSplit r (tokenSplit s p) = tokenSplit (r * s) p := by
  funext j
  simp only [tokenSplit]
  rw [Nat.div_div_eq_div_mul]
  rw [show r * s = s * r from Nat.mul_comm r s]
  push_cast
  ring

/-- Consequently the knee tax of a composite domain shift is the product of the
individual taxes. -/
theorem knee_tokenSplit_comp_le {r s : ℕ} (hr : 0 < r) (hs : 0 < s) {p : ℕ → ℝ} {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k) :
    knee (tokenSplit (r * s) p) tau ≤ r * (s * knee p tau) := by
  have hex' : ∃ k, tau ≤ prefixMass (tokenSplit s p) k :=
    ⟨s * knee p tau, by
      rw [prefixMass_tokenSplit_block s hs]; exact le_prefixMass_knee hex⟩
  calc knee (tokenSplit (r * s) p) tau
      = knee (tokenSplit r (tokenSplit s p)) tau := by rw [tokenSplit_comp]
    _ ≤ r * knee (tokenSplit s p) tau := knee_tokenSplit_le hr hex'
    _ ≤ r * (s * knee p tau) :=
        Nat.mul_le_mul_left r (knee_tokenSplit_le hs hex)

/-! ### 2. Variable tokenisation -/

/-- Cumulative token count of the first `m` words. -/
def cum (w : ℕ → ℕ) (m : ℕ) : ℕ := ∑ i ∈ range m, w i

lemma cum_succ (w : ℕ → ℕ) (m : ℕ) : cum w (m + 1) = cum w m + w m := Finset.sum_range_succ _ _

lemma cum_mono (w : ℕ → ℕ) : Monotone (cum w) := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset (by simpa using hab)

/-- With at least one token per word, the token index of a word is at least its
word index. -/
lemma le_cum {w : ℕ → ℕ} (hw : ∀ i, 1 ≤ w i) (m : ℕ) : m ≤ cum w m := by
  induction m with
  | zero => simp [cum]
  | succ m ih =>
      rw [cum_succ]
      have := hw m
      omega

/-- The word that token `j` belongs to. -/
noncomputable def wordOf (w : ℕ → ℕ) (j : ℕ) : ℕ := sInf {m | j < cum w (m + 1)}

lemma wordOf_eq {w : ℕ → ℕ} (m t : ℕ) (ht : t < w m) : wordOf w (cum w m + t) = m := by
  have hmem : cum w m + t < cum w (m + 1) := by rw [cum_succ]; omega
  have hne : Set.Nonempty {m' | cum w m + t < cum w (m' + 1)} := ⟨m, hmem⟩
  have h2 : cum w m + t < cum w (wordOf w (cum w m + t) + 1) := Nat.sInf_mem hne
  refine le_antisymm (Nat.sInf_le hmem) ?_
  by_contra hcon
  push_neg at hcon
  have hle : cum w (wordOf w (cum w m + t) + 1) ≤ cum w m := cum_mono w (by omega)
  omega

/-- **Variable token dilution.**  Word `i` is spelt with `w i` tokens, each
carrying the equal share `p i / w i` of that word's attention mass. -/
noncomputable def varSplit (w : ℕ → ℕ) (p : ℕ → ℝ) : ℕ → ℝ :=
  fun j => p (wordOf w j) / w (wordOf w j)

lemma varSplit_nonneg {w : ℕ → ℕ} {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (j : ℕ) :
    0 ≤ varSplit w p j := div_nonneg (hp _) (Nat.cast_nonneg _)

private lemma varSplit_blockSum {w : ℕ → ℕ} (hw : ∀ i, 1 ≤ w i) (p : ℕ → ℝ) (m : ℕ) :
    ∑ t ∈ range (w m), varSplit w p (cum w m + t) = p m := by
  have h : ∀ t ∈ range (w m), varSplit w p (cum w m + t) = p m / w m := by
    intro t ht
    simp only [varSplit, wordOf_eq m t (mem_range.1 ht)]
  rw [Finset.sum_congr rfl h, Finset.sum_const, card_range, nsmul_eq_mul]
  have hwm : (w m : ℝ) ≠ 0 := by
    have := hw m
    positivity
  field_simp

/-- Variable dilution is mass preserving on whole words. -/
theorem prefixMass_varSplit {w : ℕ → ℕ} (hw : ∀ i, 1 ≤ w i) (p : ℕ → ℝ) (m : ℕ) :
    prefixMass (varSplit w p) (cum w m) = prefixMass p m := by
  induction m with
  | zero => simp [prefixMass, cum]
  | succ m ih =>
      rw [cum_succ]
      unfold prefixMass at *
      rw [Finset.sum_range_add, ih, Finset.sum_range_succ]
      congr 1
      exact varSplit_blockSum hw p m

/-- **The variable dilution law** (the NET-72 mechanism, exact form).  If the
undiluted knee is `K`, the diluted knee lies strictly between the token counts of
the top `K - 1` and the top `K` words.  Equivalently: the knee is the number of
tokens the tokenizer spends on the words the model actually needs — a quantity
measurable directly from a tokens-per-word count. -/
theorem variable_dilution_law {w : ℕ → ℕ} (hw : ∀ i, 1 ≤ w i) {p : ℕ → ℝ}
    (hp : ∀ i, 0 ≤ p i) {tau : ℝ} (hex : ∃ k, tau ≤ prefixMass p k) (hK : 0 < knee p tau) :
    cum w (knee p tau - 1) < knee (varSplit w p) tau ∧
      knee (varSplit w p) tau ≤ cum w (knee p tau) := by
  have hbar : tau ≤ prefixMass (varSplit w p) (cum w (knee p tau)) := by
    rw [prefixMass_varSplit hw]
    exact le_prefixMass_knee hex
  refine ⟨?_, knee_le_of_le hbar⟩
  refine knee_exceeds_grid (fun j => varSplit_nonneg hp j) ⟨_, hbar⟩ ?_
  rw [prefixMass_varSplit hw]
  exact prefixMass_lt_of_lt_knee (by omega)

/-- Cumulative counts are controlled by the extreme tokens-per-word ratios. -/
lemma cum_le_of_le {w : ℕ → ℕ} {R : ℕ} (hR : ∀ i, w i ≤ R) (m : ℕ) : cum w m ≤ R * m := by
  induction m with
  | zero => simp [cum]
  | succ m ih =>
      rw [cum_succ]
      have := hR m
      calc cum w m + w m ≤ R * m + R := by omega
        _ = R * (m + 1) := by ring

lemma le_cum_of_le {w : ℕ → ℕ} {L : ℕ} (hL : ∀ i, L ≤ w i) (m : ℕ) : L * m ≤ cum w m := by
  induction m with
  | zero => simp [cum]
  | succ m ih =>
      rw [cum_succ]
      have := hL m
      calc L * (m + 1) = L * m + L := by ring
        _ ≤ cum w m + w m := by omega

/-- **Tokens-per-word brackets the knee.**  If the tokenizer spends between `L`
and `R` tokens on every word, the diluted knee satisfies
`L * (K - 1) < K_dil ≤ R * K`.  Uniform dilution (`L = R = r`) recovers
`dilution_law`; a language whose ratio band `[L, R]` sits above another's must
have a strictly larger knee once `L * (K - 1) ≥ R' * K`, which is exactly the
"whole grid ranges apart" phenomenon. -/
theorem variable_dilution_between_extremes {w : ℕ → ℕ} {L R : ℕ} (hw : ∀ i, 1 ≤ w i)
    (hL : ∀ i, L ≤ w i) (hR : ∀ i, w i ≤ R) {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k) (hK : 0 < knee p tau) :
    L * (knee p tau - 1) < knee (varSplit w p) tau ∧
      knee (varSplit w p) tau ≤ R * knee p tau := by
  obtain ⟨h1, h2⟩ := variable_dilution_law hw hp hex hK
  exact ⟨lt_of_le_of_lt (le_cum_of_le hL _) h1, h2.trans (cum_le_of_le hR _)⟩

/-- Consistency: constant tokens-per-word reproduces the uniform split of
`Novelty.KneeDilutionGrid`. -/
theorem varSplit_const (r : ℕ) (hr : 0 < r) (p : ℕ → ℝ) :
    varSplit (fun _ => r) p = tokenSplit r p := by
  funext j
  have hcum : ∀ m, cum (fun _ => r) m = r * m := by
    intro m
    induction m with
    | zero => simp [cum]
    | succ m ih => rw [cum_succ, ih]; ring
  have hmod : j % r < r := Nat.mod_lt _ hr
  have hj : j = cum (fun _ => r) (j / r) + j % r := by
    rw [hcum]
    have := Nat.div_add_mod j r
    omega
  have hword : wordOf (fun _ => r) j = j / r := by
    conv_lhs => rw [hj]
    exact wordOf_eq (w := fun _ => r) (j / r) (j % r) hmod
  simp only [varSplit, tokenSplit, hword]

/-! ### 3. Geometric grids survive a multiplicative tax -/

/-- **A geometric sweep always brackets the knee within a factor two.**  Let `S`
be the least exponent whose budget `2 ^ S` meets the bar.  Then
`knee ≤ 2 ^ S` and, unless `S = 0`, `2 ^ S < 2 * knee`.  Unlike an arithmetic
grid, a geometric grid cannot be escaped by a multiplicative domain tax: the
tax only shifts `S` by `log 2 r`.  This is the experimental design correction
implied by the NET-72 failure. -/
theorem geometric_grid_brackets_knee {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass p k) :
    ∃ S : ℕ, knee p tau ≤ 2 ^ S ∧ (0 < S → 2 ^ S < 2 * knee p tau) := by
  obtain ⟨k, hk⟩ := hex
  have hkpow : k ≤ 2 ^ k := Nat.le_of_lt (Nat.lt_two_pow_self)
  have hne : Set.Nonempty {i | tau ≤ prefixMass p (2 ^ i)} :=
    ⟨k, le_trans hk (prefixMass_mono hp hkpow)⟩
  set S : ℕ := sInf {i | tau ≤ prefixMass p (2 ^ i)} with hS
  have hSmem : tau ≤ prefixMass p (2 ^ S) := Nat.sInf_mem hne
  refine ⟨S, knee_le_of_le hSmem, ?_⟩
  intro hSpos
  have hprev : prefixMass p (2 ^ (S - 1)) < tau := by
    have hnot : (S - 1) ∉ {i | tau ≤ prefixMass p (2 ^ i)} :=
      Nat.notMem_of_lt_sInf (by omega)
    simpa [Set.mem_setOf_eq, not_le] using hnot
  have hlt : 2 ^ (S - 1) < knee p tau :=
    knee_exceeds_grid hp ⟨2 ^ S, hSmem⟩ hprev
  have hpow : 2 ^ (S - 1) * 2 = 2 ^ S := by
    have h := (pow_succ 2 (S - 1)).symm
    have hS1 : S - 1 + 1 = S := by omega
    rw [hS1] at h
    exact h
  omega

/-- The arithmetic counterpart fails: for every arithmetic grid ceiling `g` there
are profiles, indistinguishable on the whole grid, whose knees are arbitrarily
far apart.  (Immediate from `grid_underdetermines_knee`; recorded here for the
contrast with `geometric_grid_brackets_knee`.) -/
theorem arithmetic_grid_gives_no_upper_bound (g : ℕ) (B : ℕ) :
    ∃ p q : ℕ → ℝ, (∀ i, 0 ≤ p i) ∧ (∀ i, 0 ≤ q i) ∧ Antitone p ∧ Antitone q ∧
      (∀ k ≤ g, prefixMass p k = prefixMass q k) ∧
      knee p ((g : ℝ) + 1) = g + 1 ∧ B < knee q ((g : ℝ) + 1) := by
  obtain ⟨p, hp0, hpa, hpv, -, -, hpk⟩ := grid_underdetermines_knee g (g + 1) (by omega)
  obtain ⟨q, hq0, hqa, hqv, -, -, hqk⟩ :=
    grid_underdetermines_knee g (g + B + 2) (by omega)
  refine ⟨p, q, hp0, hq0, hpa, hqa, ?_, hpk, ?_⟩
  · intro k hk
    rw [hpv k hk, hqv k hk]
  · rw [hqk]
    omega

/-- **A wide gap in the grid is a wide ambiguity in the knee.**  For consecutive
budget probes `a < b` there are two nonnegative antitone profiles whose retention
agrees at *every* budget outside the open interval `(a, b)` — in particular at
every grid point — but whose knees are `a + 1` and `b`.  A grid therefore cannot
certify a bracket tighter than the ratio `b / (a + 1)` of its consecutive probes,
which is exactly the guarantee that `geometric_grid_brackets_knee` attains with
ratio `2`. -/
theorem grid_gap_ambiguity (a b : ℕ) (hab : a < b) :
    ∃ p q : ℕ → ℝ, (∀ i, 0 ≤ p i) ∧ (∀ i, 0 ≤ q i) ∧ Antitone p ∧ Antitone q ∧
      (∀ k ≤ a, prefixMass p k = prefixMass q k) ∧
      (∀ k, b ≤ k → prefixMass p k = prefixMass q k) ∧
      knee p ((a : ℝ) + 1) = a + 1 ∧ knee q ((a : ℝ) + 1) = b := by
  obtain ⟨q, hq0, hqa, hqlow, -, hqhigh, hqk⟩ := grid_underdetermines_knee a b hab
  have hcast : ((a : ℝ) + 1) = ((a + 1 : ℕ) : ℝ) := by push_cast; ring
  refine ⟨unif (a + 1), q, unif_nonneg _, hq0, unif_antitone _, hqa, ?_, ?_, ?_, hqk⟩
  · intro k hk
    rw [prefixMass_unif, hqlow k hk]
    have hmin : min k (a + 1) = k := by omega
    rw [hmin]
  · intro k hk
    rw [prefixMass_unif, hqhigh k hk]
    have hmin : min k (a + 1) = a + 1 := by omega
    rw [hmin]
    push_cast
    ring
  · rw [hcast]
    exact (dilution_upper_sharp 1 (a + 1) (a + 1) one_pos le_rfl).1

/-! ### 4. Mixed domains -/

/-- Retention is affine in a pointwise mixture of two profiles. -/
theorem prefixMass_mixture (s : ℝ) (p q : ℕ → ℝ) (k : ℕ) :
    prefixMass (fun i => s * p i + (1 - s) * q i) k
      = s * prefixMass p k + (1 - s) * prefixMass q k := by
  rw [prefixMass_add (fun i => s * p i) (fun i => (1 - s) * q i) k,
    prefixMass_const_mul, prefixMass_const_mul]

/-- **The mixture law.**  Multilingual traffic is a mixture, and the knee of a
mixture is sandwiched between the knees of its components:
`min K₁ K₂ ≤ K_mix ≤ max K₁ K₂`.  Since `dilution_law` rules out interpolating
budgets *between* domains, this is the replacement rule for provisioning mixed
traffic: budget by the maximum, never by an average. -/
theorem mixture_knee_between {p q : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    {s : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) {tau : ℝ}
    (hexp : ∃ k, tau ≤ prefixMass p k) (hexq : ∃ k, tau ≤ prefixMass q k) :
    min (knee p tau) (knee q tau) ≤ knee (fun i => s * p i + (1 - s) * q i) tau ∧
      knee (fun i => s * p i + (1 - s) * q i) tau ≤ max (knee p tau) (knee q tau) := by
  set K1 := knee p tau
  set K2 := knee q tau
  have hp1 : tau ≤ prefixMass p K1 := le_prefixMass_knee hexp
  have hq1 : tau ≤ prefixMass q K2 := le_prefixMass_knee hexq
  have hupper : tau ≤ prefixMass (fun i => s * p i + (1 - s) * q i) (max K1 K2) := by
    rw [prefixMass_mixture]
    have h1 : tau ≤ prefixMass p (max K1 K2) :=
      hp1.trans (prefixMass_mono hp (le_max_left _ _))
    have h2 : tau ≤ prefixMass q (max K1 K2) :=
      hq1.trans (prefixMass_mono hq (le_max_right _ _))
    nlinarith
  refine ⟨?_, knee_le_of_le hupper⟩
  by_contra hcon
  push_neg at hcon
  have hmix : tau ≤ prefixMass (fun i => s * p i + (1 - s) * q i)
      (knee (fun i => s * p i + (1 - s) * q i) tau) := le_prefixMass_knee ⟨_, hupper⟩
  rw [prefixMass_mixture] at hmix
  have h1 : prefixMass p (knee (fun i => s * p i + (1 - s) * q i) tau) < tau :=
    prefixMass_lt_of_lt_knee (lt_of_lt_of_le hcon (min_le_left _ _))
  have h2 : prefixMass q (knee (fun i => s * p i + (1 - s) * q i) tau) < tau :=
    prefixMass_lt_of_lt_knee (lt_of_lt_of_le hcon (min_le_right _ _))
  have key : ∀ A B : ℝ, A < tau → B < tau → tau ≤ s * A + (1 - s) * B → False := by
    intro A B hA hB hAB
    rcases eq_or_lt_of_le hs1 with heq | hslt
    · rw [heq] at hAB
      simp at hAB
      linarith
    · have e1 : s * A ≤ s * tau := mul_le_mul_of_nonneg_left hA.le hs0
      have e2 : (1 - s) * B < (1 - s) * tau := by
        apply mul_lt_mul_of_pos_left hB
        linarith
      nlinarith
  exact key _ _ h1 h2 hmix

end Catalog.Novelty.KneeDilutionGrid