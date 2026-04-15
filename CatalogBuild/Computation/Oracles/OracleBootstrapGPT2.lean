/-! # CatalogBuild.Computation.Oracles.OracleBootstrapGPT2

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 26
-/

import Mathlib

noncomputable section

/-- A function is an oracle (idempotent) if applying it twice equals applying it once. -/
def IsOracleGPT {α : Type*} (f : α → α) : Prop := ∀ x, f (f x) = f x

/-- Thresholding (hard pruning) at level t ≥ 0 -/

def threshold (t : ℝ) (x : ℝ) : ℝ := if |x| ≤ t then 0 else x

/-- Thresholding is idempotent: pruning already-pruned weights does nothing. -/

theorem threshold_is_oracle (t : ℝ) (ht : 0 ≤ t) : IsOracleGPT (threshold t) := by
  intro x; simp only [threshold]
  split_ifs <;> simp_all

/-! ## §2: GPT-2 Architecture Constants -/

/-- GPT-2 Small configuration -/

structure GPT2Config where
  nLayers : ℕ := 12
  dModel : ℕ := 768
  nHeads : ℕ := 12
  dFF : ℕ := 3072
  vocabSize : ℕ := 50257
  maxSeqLen : ℕ := 1024

/-- Default GPT-2 Small config -/

def gpt2Small : GPT2Config := {}

/-- Parameter count for one transformer layer -/

def paramsPerLayer (c : GPT2Config) : ℕ :=
  4 * c.dModel * c.dModel +     -- attention (QKV + output)
  2 * c.dModel * c.dFF +         -- feedforward (up + down)
  4 * c.dModel +                  -- attention biases
  c.dFF + c.dModel +              -- FF biases
  4 * c.dModel                    -- 2 layer norms (weight + bias each)

/-- Embedding parameters -/

def embeddingParams (c : GPT2Config) : ℕ :=
  c.vocabSize * c.dModel + c.maxSeqLen * c.dModel

/-- Total parameter count -/

def totalGPT2Params (c : GPT2Config) : ℕ :=
  embeddingParams c + c.nLayers * paramsPerLayer c + 2 * c.dModel -- final layer norm

/-- GPT-2 Small parameter count -/

theorem gpt2_param_count_approx :
    totalGPT2Params gpt2Small = 124439808 := by native_decide

/-- At FP32 (4 bytes per param), GPT-2 takes ~497MB -/

def gpt2SizeBytes : ℕ := 4 * totalGPT2Params gpt2Small

/-- Compressed size in bytes -/

def compressedSizeBytes (nParams : ℕ) (quantBits : ℕ) : ℕ :=
  (nParams * quantBits + 7) / 8

/-- 4-bit quantization of GPT-2 yields ≈ 62MB -/

theorem gpt2_4bit_size :
    compressedSizeBytes (totalGPT2Params gpt2Small) 4 = 62219904 := by native_decide

/-! ## §3: The Oracle Bootstrap Map for Compression -/

/-- The oracle bootstrap map f(r) = 3r² - 2r³.
    In compression context: r is the "quality retention ratio". -/

def compressionBootstrap (r : ℝ) : ℝ := 3 * r ^ 2 - 2 * r ^ 3

/-- 0 is a fixed point (total collapse). -/

theorem bootstrap_improves_above_half (r : ℝ) (hr1 : 1/2 < r) (hr2 : r < 1) :
    r < compressionBootstrap r := by
  unfold compressionBootstrap
  nlinarith [sq_nonneg r, sq_nonneg (r - 1), sq_nonneg (r - 1/2)]

/-- If initial quality < 1/2, the bootstrap converges to r = 0 (total collapse). -/

theorem bootstrap_degrades_below_half (r : ℝ) (hr1 : 0 < r) (hr2 : r < 1/2) :
    compressionBootstrap r < r := by
  unfold compressionBootstrap
  nlinarith [sq_nonneg r, sq_nonneg (r - 1), sq_nonneg (r - 1/2)]

/-- The bootstrap preserves the unit interval [0,1] -/

theorem phase_transition :
    (∀ r : ℝ, 1/2 < r → r < 1 → r < compressionBootstrap r) ∧
    (∀ r : ℝ, 0 < r → r < 1/2 → compressionBootstrap r < r) := by
  exact ⟨bootstrap_improves_above_half, bootstrap_degrades_below_half⟩

/-! ## §5: Compression Pipeline -/

/-- Compressed parameter count after pruning -/

def compressedParams (originalParams : ℕ) (prunePercent : ℕ) : ℕ :=
  originalParams * (100 - prunePercent) / 100

/-- Final compressed size in bytes -/

def finalCompressedSizeBytes (originalParams : ℕ) (prunePercent quantBits : ℕ) : ℕ :=
  compressedSizeBytes (compressedParams originalParams prunePercent) quantBits

/-- Aggressive compression: 50% pruning + 4-bit quantization -/

theorem aggressive_compression_bound :
    finalCompressedSizeBytes (totalGPT2Params gpt2Small) 50 4 < 32000000 := by
  native_decide

/-- Even moderate compression (20% pruning + 8-bit) is significant -/

theorem moderate_compression :
    finalCompressedSizeBytes (totalGPT2Params gpt2Small) 20 8 < 125000000 := by
  native_decide

/-! ## §6: Iterative Bootstrap Convergence -/

/-- n-fold composition of the bootstrap map -/

def bootstrapIter (n : ℕ) (r : ℝ) : ℝ := compressionBootstrap^[n] r

/-
PROBLEM
The bootstrap map is monotone on [1/2, 1]

PROVIDED SOLUTION
Expand compressionBootstrap, then show f(s) - f(r) = (s-r)(6rs - 2(r² + rs + s²) + ...) ≥ 0. Since r,s ∈ [1/2, 1] and r ≤ s, use nlinarith with appropriate square terms. Key: f(s) - f(r) = 3(s²-r²) - 2(s³-r³) = (s-r)(3(s+r) - 2(s²+sr+r²)). For r,s in [1/2,1], the factor 3(s+r) - 2(s²+sr+r²) ≥ 0.
-/

theorem bootstrap_monotone_upper (r s : ℝ) (hr1 : 1/2 ≤ r) (hs1 : s ≤ 1)
    (hrs : r ≤ s) :
    compressionBootstrap r ≤ compressionBootstrap s := by
  unfold compressionBootstrap
  nlinarith [ sq_nonneg ( r - s ), mul_le_mul_of_nonneg_left hrs ( sub_nonneg.2 hr1 ) ]

/-
PROBLEM
The bootstrap iterates form an increasing sequence above 1/2

PROVIDED SOLUTION
By induction on n. Base case n=0: bootstrapIter 0 r = r, done by refl. For n+1: bootstrapIter (n+1) r = compressionBootstrap (bootstrapIter n r). By IH, r ≤ bootstrapIter n r. We need to show r ≤ compressionBootstrap (bootstrapIter n r). Since bootstrapIter n r is in (1/2, 1) (by IH it's ≥ r > 1/2, and by bootstrap_maps_unit_interval it's ≤ 1), and compressionBootstrap improves above 1/2, we get bootstrapIter n r ≤ compressionBootstrap (bootstrapIter n r). Combine with IH by transitivity. Note: we also need that the iterate stays < 1 and > 1/2 at each step — bootstrap_maps_unit_interval and bootstrap_improves_above_half handle this.
-/

theorem bootstrap_iter_increasing (r : ℝ) (hr1 : 1/2 < r) (hr2 : r < 1) (n : ℕ) :
    r ≤ bootstrapIter n r := by
  induction n with
  | zero => simp [bootstrapIter]
  | succ n ih =>
  -- By the properties of the bootstrap map and the induction hypothesis, we have that $r \leq compressionBootstrap (bootstrapIter n r)$.
  have hBootstrap : r ≤ compressionBootstrap (bootstrapIter n r) := by
    -- By the properties of the bootstrap map and the induction hypothesis, we have that $r \leq compressionBootstrap (bootstrapIter n r)$ because $bootstrapIter n r \in [1/2, 1]$.
    have hBootstrap : 1 / 2 ≤ bootstrapIter n r ∧ bootstrapIter n r ≤ 1 := by
      have hBootstrap : ∀ n r, 1 / 2 < r → r < 1 → 1 / 2 < bootstrapIter n r ∧ bootstrapIter n r < 1 := by
        intros n r hr1 hr2; induction' n with n ih generalizing r <;> simp_all +decide ;
        · exact ⟨ hr1, hr2 ⟩;
        · convert ih ( compressionBootstrap r ) _ _ using 1 <;> norm_num [ compressionBootstrap ] at *;
          · nlinarith [ sq_nonneg ( r - 1 / 2 ) ];
          · nlinarith [ sq_nonneg ( r - 1 ) ];
      exact ⟨ le_of_lt ( hBootstrap n r hr1 hr2 |>.1 ), le_of_lt ( hBootstrap n r hr1 hr2 |>.2 ) ⟩;
    exact le_trans ih ( by unfold compressionBootstrap; nlinarith [ sq_nonneg ( 1 / 2 - bootstrapIter n r ) ] );
  convert hBootstrap using 1;
  exact Function.iterate_succ_apply' _ _ _

/-! ## §7: KL Divergence and Distillation -/

/-- KL divergence between two discrete distributions -/

def klDivDiscrete (n : ℕ) (p q : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, p i * Real.log (p i / q i)

/-- Self-KL-divergence is zero: KL(p || p) = 0 -/

theorem kl_self_zero (n : ℕ) (p : Fin n → ℝ) (hp : ∀ i, 0 < p i) :
    klDivDiscrete n p p = 0 := by
  simp [klDivDiscrete, div_self (ne_of_gt (hp _))]

/-- The distillation loss at convergence equals zero
    (teacher and student agree perfectly). -/

theorem distillation_convergence_loss (n : ℕ) (p : Fin n → ℝ) (hp : ∀ i, 0 < p i) :
    klDivDiscrete n p p = 0 := by exact kl_self_zero n p hp


end
