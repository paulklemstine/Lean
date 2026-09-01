import Probability.NET89MixedDomainKnee

/-!
# NET-89, cycle 2: the mixing-ratio sweep and block-size sensitivity

`Probability.NET89MixedDomainKnee` settled the 50/50, block-size-one case of the NET-89
report: a two-domain knee is caged by the mediant sandwich, interleaving is pooling at
half scale, and the doubling increment is therefore twice the pooled one.  The report's
own "Next" list asks for the two obvious perturbations — the **mixing-ratio sweep** and
**block-size sensitivity**.  Both are settled here, as theorems rather than experiments.

## Mixing ratio

* `retained_pool_ratio_mono` — if one domain uniformly dominates the other (its retained
  curve is everywhere higher), then the pooled retained curve is *monotone in the mixing
  ratio*.  Shifting weight to the easier domain can only raise retained mass, at every
  budget simultaneously.
* `kstar_pool_ratio_mono` — hence the pooled knee is monotone along the whole ratio
  sweep, and `net89_ratio_sweep_prediction` gives the falsifiable shape of the sweep: it
  starts at the easier domain's knee, rises monotonically, and ends at the harder one's.
  A sweep that is non-monotone would refute domination, which is checkable curve by
  curve.
* `kstar_pool_eq_of_dominant_weight` — the **endpoint law**, quantitatively: if the
  minority domain's total mass is small compared with the gate slack of the majority
  domain, the mixture's knee is *exactly* the majority domain's knee.  This is the honest
  mechanism behind "the mixed domain starts at CODE's level": at ctx 512 the mixture is
  still inside the code-dominated window.  `code_dominated_mixture_has_code_knee`
  instantiates it on an explicit profile pair, so the hypothesis class is non-empty.

## Block size

* `mixBlock b u v` — interleaving in blocks of `b` keys, the actual NET-89 protocol
  (~500-char blocks).
* `headMass_mixBlock`, `retained_mixBlock_aligned` — at block-aligned budgets the block
  size is *invisible*: `retained (mixBlock b u v) (2bn) (2bk) = retained (pool 1 1 u v)
  (bn) (bk)`, and `block_size_invariance` says every block size gives the same curve as
  the alternating one, read at the corresponding budget.
* `kstar_mixBlock_bracket` — the only effect of the block size is a quantisation error of
  one block on each side: `2Q - 2b < k*_block ≤ 2Q + 2b`.  So a block-size sweep should
  show *no* systematic trend, only `±b` jitter — a sharp, falsifiable prediction for the
  next experimental round.
* `mixBlock_ctxSens_doubling` — the doubling law survives blocking with slack `4b`.

-- !-- Lab Notes -- !--
Hypothesizer (round 33, cycle 2, four conjectures):
 (C1) Under uniform domination the pooled knee is monotone in the mixing ratio; without
      domination it need not be (the mediant derivative changes sign with `k`).  [BOLD]
 (C2) There is a *quantitative* dominance window: an explicit smallness condition on the
      minority mass forces the mixture's knee to equal the majority's exactly.   [BOLD]
 (C3) Block size is invisible at block-aligned budgets; its only effect is `±b`
      quantisation of the knee.                                                  [BOLD]
 (C4) Consequently the doubling law is block-robust with additive slack `4b`.

Experimenter: C1 = `retained_pool_ratio_mono`/`kstar_pool_ratio_mono`; C2 =
`kstar_pool_eq_of_dominant_weight` with witness `code_dominated_mixture_has_code_knee`
(`u = uA`, `v = vFlat`, `n = 4`, `τ = 7/10`, minority weight `1/100`); C3 =
`retained_mixBlock_aligned`, `block_size_invariance`, `kstar_mixBlock_bracket`; C4 =
`mixBlock_ctxSens_doubling`.  Zero sorries.

Analyst: the two perturbations behave completely differently.  The mixing ratio is a
*real* degree of freedom — it moves the knee monotonically across the whole sandwich —
whereas the block size is a *gauge* parameter: it cannot move the knee by more than one
block.  A programme that reports block-size effects larger than `±b` is therefore
measuring something outside this model (tokenisation boundaries, positional effects),
which is exactly the diagnostic value of the theorem.

Critic: `kstar_pool_ratio_mono` needs domination and says nothing without it; that
hypothesis is stated, not hidden, and cycle 1's witnesses show what goes wrong when it
fails (the pooled knee can sit at either end of the sandwich).  The block bracket is
two-sided and its slack `2b` is genuinely needed: a knee can only be observed at
block-aligned budgets, so the quantisation is real, not an artefact of the proof.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ : ℝ} {n b : ℕ}

/-! ## 1. The mixing-ratio sweep -/

/-- One domain **uniformly dominates** another when its retained curve is everywhere at
least as high: every budget retains more mass in `u` than in `v`. -/
lemma kstar_le_of_dominates (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1)
    (hdom : ∀ k, retained v n k ≤ retained u n k) :
    kstar u n τ ≤ kstar v n τ :=
  kstar_le_of_pass (le_trans (gate_le_retained_kstar hv hn hτ) (hdom _))

/-- **C1 — ratio monotonicity.**  If `u` uniformly dominates `v`, then increasing the
relative weight of `u` raises the pooled retained mass at *every* budget. -/
theorem retained_pool_ratio_mono (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    {a₁ b₁ a₂ b₂ : ℝ} (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hdom : ∀ k, retained v n k ≤ retained u n k) (hratio : a₂ * b₁ ≤ a₁ * b₂) (k : ℕ) :
    retained (pool a₂ b₂ u v) n k ≤ retained (pool a₁ b₁ u v) n k := by
  have hB : 0 < headMass u n := headMass_pos hu hn
  have hD : 0 < headMass v n := headMass_pos hv hn
  have hA : 0 ≤ headMass u (min k n) := headMass_nonneg hu _
  have hC : 0 ≤ headMass v (min k n) := headMass_nonneg hv _
  set A := headMass u (min k n)
  set B := headMass u n
  set C := headMass v (min k n)
  set D := headMass v n
  have hcross : C * B ≤ A * D := by
    have := hdom k
    exact (div_le_div_iff₀ hD hB).mp (by rw [retained, retained] at this; exact this)
  have hd1 : 0 < a₁ * B + b₁ * D := by positivity
  have hd2 : 0 < a₂ * B + b₂ * D := by positivity
  rw [retained, retained, headMass_pool, headMass_pool, headMass_pool, headMass_pool,
    div_le_div_iff₀ hd2 hd1]
  nlinarith [mul_nonneg (sub_nonneg.mpr hratio) (sub_nonneg.mpr hcross)]

/-- The pooled knee is monotone along the mixing-ratio sweep. -/
theorem kstar_pool_ratio_mono (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1)
    {a₁ b₁ a₂ b₂ : ℝ} (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hdom : ∀ k, retained v n k ≤ retained u n k) (hratio : a₂ * b₁ ≤ a₁ * b₂) :
    kstar (pool a₁ b₁ u v) n τ ≤ kstar (pool a₂ b₂ u v) n τ := by
  apply kstar_le_of_pass
  refine le_trans ?_ (retained_pool_ratio_mono hu hv hn ha₁ hb₁ ha₂ hb₂ hdom hratio _)
  exact gate_le_retained_kstar (pool_pos ha₂ hb₂ hu hv) hn hτ

/-- **The predicted shape of a mixing-ratio sweep.**  Under domination the sweep is a
monotone staircase running from the easier domain's knee to the harder domain's knee: no
overshoot at either end, no reversal in between. -/
theorem net89_ratio_sweep_prediction (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) {a₁ b₁ a₂ b₂ : ℝ} (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hdom : ∀ k, retained v n k ≤ retained u n k) (hratio : a₂ * b₁ ≤ a₁ * b₂) :
    kstar u n τ ≤ kstar (pool a₁ b₁ u v) n τ ∧
      kstar (pool a₁ b₁ u v) n τ ≤ kstar (pool a₂ b₂ u v) n τ ∧
        kstar (pool a₂ b₂ u v) n τ ≤ kstar v n τ := by
  have hle : kstar u n τ ≤ kstar v n τ := kstar_le_of_dominates hv hn hτ hdom
  have h1 := min_le_kstar_pool ha₁ hb₁ hu hv hn hτ
  have h2 := kstar_pool_le_max ha₂ hb₂ hu hv hn hτ
  refine ⟨?_, kstar_pool_ratio_mono hu hv hn hτ ha₁ hb₁ ha₂ hb₂ hdom hratio, ?_⟩
  · omega
  · omega

/-- **C2 — the endpoint law.**  If the minority domain's total mass is small enough
relative to the majority domain's gate slack, the mixture has *exactly* the majority
domain's knee.  Both smallness conditions are explicit and checkable from head masses. -/
theorem kstar_pool_eq_of_dominant_weight (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ0 : 0 < τ) (hτ : τ ≤ 1) {b : ℝ} (hb : 0 < b) (hK : 1 ≤ kstar u n τ)
    (hpass : b * (τ * headMass v n) ≤ headMass u (min (kstar u n τ) n) - τ * headMass u n)
    (hfail : b * headMass v n < τ * headMass u n - headMass u (min (kstar u n τ - 1) n)) :
    kstar (pool 1 b u v) n τ = kstar u n τ := by
  set K := kstar u n τ with hKdef
  have hB : 0 < headMass u n := headMass_pos hu hn
  have hD : 0 < headMass v n := headMass_pos hv hn
  have hden : 0 < 1 * headMass u n + b * headMass v n := by positivity
  have hCle : headMass v (min (K - 1) n) ≤ headMass v n := headMass_mono hv (min_le_right _ _)
  have hCnn : 0 ≤ headMass v (min K n) := headMass_nonneg hv _
  have hpassK : τ ≤ retained (pool 1 b u v) n K := by
    rw [retained, headMass_pool, headMass_pool, le_div_iff₀ hden]
    nlinarith
  have hfailK : retained (pool 1 b u v) n (K - 1) < τ := by
    rw [retained, headMass_pool, headMass_pool, div_lt_iff₀ hden]
    nlinarith [mul_le_mul_of_nonneg_left hCle hb.le, mul_pos hb hD,
      mul_nonneg hτ0.le (mul_pos hb hD).le]
  have := kstar_eq_of_fail_pass (w := pool 1 b u v) (pool_pos one_pos hb hu hv) hn hτ
    (m := K - 1) hfailK (by rwa [Nat.sub_add_cancel hK])
  omega

/-- The endpoint law is not vacuous: a 100:1 mixture of the head-heavy domain `uA` with
the flat domain `vFlat` has exactly `uA`'s knee, even though `vFlat`'s knee is three
times larger. -/
theorem code_dominated_mixture_has_code_knee :
    kstar (pool 1 (1 / 100) uA vFlat) 4 (7 / 10) = kstar uA 4 (7 / 10) := by
  refine kstar_pool_eq_of_dominant_weight uA_pos vFlat_pos (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) ?_ ?_ ?_
  · rw [kstar_uA]
  · rw [kstar_uA]; norm_num [headMass, uA, vFlat, Finset.sum_range_succ]
  · rw [kstar_uA]; norm_num [headMass, uA, vFlat, Finset.sum_range_succ]

/-! ## 2. Block-size sensitivity -/

/-- **Block interleaving.**  Blocks of `b` consecutive keys alternate between the two
domains; `mixBlock 1 = mix`.  This is the NET-89 protocol with its ~500-char blocks. -/
noncomputable def mixBlock (b : ℕ) (u v : ℕ → ℝ) : ℕ → ℝ :=
  fun i => if (i / b) % 2 = 0 then u (b * ((i / b) / 2) + i % b)
           else v (b * ((i / b) / 2) + i % b)

lemma mixBlock_pos (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (b : ℕ) :
    ∀ i, 0 < mixBlock b u v i := by
  intro i; simp only [mixBlock]; split
  · exact hu _
  · exact hv _

/-- Block-aligned prefixes of a blocked mixture contain matched prefixes of both
domains — the block-size analogue of `headMass_mix_even`. -/
lemma headMass_mixBlock (hb : 0 < b) (u v : ℕ → ℝ) (k : ℕ) :
    headMass (mixBlock b u v) (2 * b * k) = headMass u (b * k) + headMass v (b * k) := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have e1 : 2 * b * (k + 1) = 2 * b * k + b + b := by ring
      have hblock1 : ∀ i ∈ range b, mixBlock b u v (2 * b * k + i) = u (b * k + i) := by
        intro i hi
        have hib : i < b := mem_range.mp hi
        have hrw : 2 * b * k + i = b * (2 * k) + i := by ring
        have h1 : (2 * b * k + i) / b = 2 * k := by
          rw [hrw, Nat.mul_add_div hb, Nat.div_eq_of_lt hib, Nat.add_zero]
        have h2 : (2 * b * k + i) % b = i := by
          rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt hib]
        have h3 : (2 * k) % 2 = 0 := by omega
        have h4 : (2 * k) / 2 = k := by omega
        simp [mixBlock, h1, h2, h3, h4]
      have hblock2 : ∀ i ∈ range b, mixBlock b u v (2 * b * k + b + i) = v (b * k + i) := by
        intro i hi
        have hib : i < b := mem_range.mp hi
        have hrw : 2 * b * k + b + i = b * (2 * k + 1) + i := by ring
        have h1 : (2 * b * k + b + i) / b = 2 * k + 1 := by
          rw [hrw, Nat.mul_add_div hb, Nat.div_eq_of_lt hib, Nat.add_zero]
        have h2 : (2 * b * k + b + i) % b = i := by
          rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt hib]
        have h3 : (2 * k + 1) % 2 = 1 := by omega
        have h4 : (2 * k + 1) / 2 = k := by omega
        simp [mixBlock, h1, h2, h3, h4]
      simp only [headMass] at ih ⊢
      rw [e1, Finset.sum_range_add, Finset.sum_range_add, ih,
        Finset.sum_congr rfl hblock1, Finset.sum_congr rfl hblock2]
      have eu : b * (k + 1) = b * k + b := by ring
      rw [eu, Finset.sum_range_add, Finset.sum_range_add]
      ring

lemma min_mul_left (c k n : ℕ) : min (c * k) (c * n) = c * min k n := by
  rcases le_total k n with h | h
  · rw [min_eq_left h, min_eq_left (Nat.mul_le_mul_left _ h)]
  · rw [min_eq_right h, min_eq_right (Nat.mul_le_mul_left _ h)]

/-- **C3 — block size is invisible at block-aligned budgets.** -/
lemma retained_mixBlock_aligned (hb : 0 < b) (u v : ℕ → ℝ) (n k : ℕ) :
    retained (mixBlock b u v) (2 * b * n) (2 * b * k)
      = retained (pool 1 1 u v) (b * n) (b * k) := by
  rw [retained, retained, min_mul_left, min_mul_left, headMass_mixBlock hb, headMass_mixBlock hb,
    headMass_pool, headMass_pool]
  simp

/-- Every block size produces the same retained-mass curve as simple alternation, read at
the corresponding budget: the block size is a gauge parameter, not a physical one. -/
theorem block_size_invariance (hb : 0 < b) (u v : ℕ → ℝ) (n k : ℕ) :
    retained (mixBlock b u v) (2 * b * n) (2 * b * k)
      = retained (mix u v) (2 * (b * n)) (2 * (b * k)) := by
  rw [retained_mixBlock_aligned hb, retained_mix_even]

lemma retained_lt_of_lt_kstar {w : ℕ → ℝ} {τ : ℝ} {n k : ℕ} (h : k < kstar w n τ) :
    retained w n k < τ := by
  by_contra hcon
  push_neg at hcon
  exact absurd (kstar_le_of_pass hcon) (by omega)

/-- **Block-size sensitivity is at most one block on each side.**  With
`Q = k*_pool(bn)`, the blocked mixture's knee satisfies `2Q - 2b < k* ≤ 2Q + 2b`.  A
block-size sweep should therefore show no trend beyond `±b` jitter. -/
theorem kstar_mixBlock_bracket (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hb : 0 < b) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    2 * kstar (pool 1 1 u v) (b * n) τ ≤ kstar (mixBlock b u v) (2 * b * n) τ + 2 * b ∧
      kstar (mixBlock b u v) (2 * b * n) τ ≤ 2 * kstar (pool 1 1 u v) (b * n) τ + 2 * b := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hbp : ∀ i, 0 < mixBlock b u v i := mixBlock_pos hu hv b
  set Q := kstar (pool 1 1 u v) (b * n) τ with hQ
  set M := kstar (mixBlock b u v) (2 * b * n) τ with hM
  have hbn : 0 < b * n := Nat.mul_pos hb hn
  have hup : M ≤ 2 * Q + 2 * b := by
    have hdm : b * (Q / b) + Q % b = Q := Nat.div_add_mod Q b
    have hmod : Q % b < b := Nat.mod_lt _ hb
    set X := b * (Q / b) with hX
    have hj : b * (Q / b + 1) = X + b := by rw [hX, Nat.mul_succ]
    have hge : Q ≤ b * (Q / b + 1) := by omega
    have hpass : τ ≤ retained (pool 1 1 u v) (b * n) (b * (Q / b + 1)) :=
      le_trans (gate_le_retained_kstar hpp hbn hτ) (retained_mono hpp _ hge)
    have hpass2 : τ ≤ retained (mixBlock b u v) (2 * b * n) (2 * b * (Q / b + 1)) := by
      rw [retained_mixBlock_aligned hb]; exact hpass
    have := kstar_le_of_pass (w := mixBlock b u v) (n := 2 * b * n) hpass2
    have he : 2 * b * (Q / b + 1) = 2 * (X + b) := by rw [← hj]; ring
    omega
  refine ⟨?_, hup⟩
  rcases Nat.eq_zero_or_pos Q with hQ0 | hQpos
  · omega
  · have hdm : b * ((Q - 1) / b) + (Q - 1) % b = Q - 1 := Nat.div_add_mod (Q - 1) b
    have hmod : (Q - 1) % b < b := Nat.mod_lt _ hb
    set Y := b * ((Q - 1) / b) with hY
    have hylt : Y < Q := by omega
    have hfail : retained (pool 1 1 u v) (b * n) Y < τ := retained_lt_of_lt_kstar hylt
    have hfail2 : retained (mixBlock b u v) (2 * b * n) (2 * b * ((Q - 1) / b)) < τ := by
      rw [retained_mixBlock_aligned hb]; exact hfail
    have hlt := lt_kstar_of_fail hbp (n := 2 * b * n) (by positivity) hτ hfail2
    have he : 2 * b * ((Q - 1) / b) = 2 * Y := by rw [hY]; ring
    omega

/-- **C4 — the doubling law is block-robust.**  Blocking perturbs the doubled increment by
at most `4b`; in particular the qualitative "mixed rises at double the pure rate" verdict
is stable under the choice of block size. -/
theorem mixBlock_ctxSens_doubling (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hb : 0 < b)
    (hn : 0 < n) (hτ : τ ≤ 1) :
    2 * ctxSens (pool 1 1 u v) τ (b * n) ≤ ctxSens (mixBlock b u v) τ (2 * b * n) + 4 * b ∧
      ctxSens (mixBlock b u v) τ (2 * b * n) ≤ 2 * ctxSens (pool 1 1 u v) τ (b * n) + 4 * b := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hbp : ∀ i, 0 < mixBlock b u v i := mixBlock_pos hu hv b
  obtain ⟨l1, u1⟩ := kstar_mixBlock_bracket hu hv hb hn hτ
  obtain ⟨l2, u2⟩ := kstar_mixBlock_bracket (n := 2 * n) hu hv hb (by omega) hτ
  have e1 : b * (2 * n) = 2 * (b * n) := by ring
  have e2 : 2 * b * (2 * n) = 2 * (2 * b * n) := by ring
  rw [e1, e2] at l2 u2
  have hmono1 : kstar (pool 1 1 u v) (b * n) τ ≤ kstar (pool 1 1 u v) (2 * (b * n)) τ :=
    kstar_mono_ctx hpp hτ (Nat.mul_pos hb hn) (by omega)
  have hmono2 : kstar (mixBlock b u v) (2 * b * n) τ ≤ kstar (mixBlock b u v) (2 * (2 * b * n)) τ :=
    kstar_mono_ctx hbp hτ (by positivity) (by omega)
  simp only [ctxSens]
  omega

end Catalog.Probability.NET89MixedDomainKnee