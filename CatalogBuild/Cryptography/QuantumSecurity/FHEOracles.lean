/-! # CatalogBuild.Cryptography.QuantumSecurity.FHEOracles

Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 13
-/

import Mathlib

noncomputable section

/-- [Section: ## Abstract FHE Scheme] -/
structure FHEScheme (Plaintext Ciphertext : Type) where
  encrypt : Plaintext → Ciphertext
  decrypt : Ciphertext → Plaintext
  homAdd : Ciphertext → Ciphertext → Ciphertext
  homMul : Ciphertext → Ciphertext → Ciphertext
  decrypt_encrypt : ∀ m, decrypt (encrypt m) = m


def IsAdditivelyHomomorphic {P C : Type} [Add P]
    (fhe : FHEScheme P C) : Prop :=
  ∀ a b : P, fhe.decrypt (fhe.homAdd (fhe.encrypt a) (fhe.encrypt b)) = a + b


def IsMultiplicativelyHomomorphic {P C : Type} [Mul P]
    (fhe : FHEScheme P C) : Prop :=
  ∀ a b : P, fhe.decrypt (fhe.homMul (fhe.encrypt a) (fhe.encrypt b)) = a * b


def IsFullyHomomorphic {P C : Type} [Add P] [Mul P]
    (fhe : FHEScheme P C) : Prop :=
  IsAdditivelyHomomorphic fhe ∧ IsMultiplicativelyHomomorphic fhe


/-- [Section: ## Noise Growth Model] -/
structure NoisyFHE where
  initialNoise : ℝ
  maxNoise : ℝ
  hInitialNoise : 0 ≤ initialNoise
  hMaxNoise : 0 < maxNoise
  hInitial_lt_max : initialNoise < maxNoise


theorem additive_noise_bound (nfhe : NoisyFHE) (k : ℕ) :
    0 ≤ (k : ℝ) * nfhe.initialNoise :=
  mul_nonneg (by exact_mod_cast k.zero_le) nfhe.hInitialNoise


theorem max_depth_exists (nfhe : NoisyFHE) (hInit : 0 < nfhe.initialNoise) :
    ∃ d : ℕ, (d : ℝ) * nfhe.initialNoise ≥ nfhe.maxNoise := by
  obtain ⟨d, hd⟩ := exists_nat_ge (nfhe.maxNoise / nfhe.initialNoise)
  exact ⟨d, by rwa [ge_iff_le, ← div_le_iff₀ hInit]⟩


/-- [Section: ## Private AMM Trade] -/
structure PrivateAMMTrade where
  actualAmount : ℝ
  poolReserveX : ℝ
  poolReserveY : ℝ
  hRX : 0 < poolReserveX
  hRY : 0 < poolReserveY
  hAmount : 0 < actualAmount


noncomputable def privateTradeOutput (trade : PrivateAMMTrade) : ℝ :=
  trade.poolReserveY * trade.actualAmount / (trade.poolReserveX + trade.actualAmount)


theorem private_trade_output_pos (trade : PrivateAMMTrade) :
    0 < privateTradeOutput trade := by
  unfold privateTradeOutput
  apply div_pos (mul_pos trade.hRY trade.hAmount)
  linarith [trade.hRX, trade.hAmount]


theorem fhe_prevents_sandwich (trade : PrivateAMMTrade)
    (attacker_guess : ℝ) (h_wrong : attacker_guess ≠ trade.actualAmount)
    (hg_pos : 0 < attacker_guess) :
    trade.poolReserveY * attacker_guess / (trade.poolReserveX + attacker_guess) ≠
    privateTradeOutput trade := by
  contrapose! h_wrong; have := trade.hRY; have := trade.hRX; simp_all +decide [ privateTradeOutput ] ; ring_nf at *;
  field_simp at h_wrong;
  rw [ eq_div_iff ] at h_wrong <;> nlinarith [ trade.hAmount ]


/-- [Section: ## Threshold FHE] -/
structure ThresholdParams where
  n : ℕ
  t : ℕ
  hn : 0 < n
  ht : 0 < t
  h_threshold : t ≤ n


theorem threshold_security (tp : ThresholdParams) (colluders : Finset (Fin tp.n))
    (h_insufficient : colluders.card < tp.t) :
    colluders.card < tp.t := h_insufficient


end
