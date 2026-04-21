/-! # CatalogBuild.Cryptography.QuantumSecurity.PostQuantumSignatures

Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 11
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Cryptography.QuantumSecurity.PostQuantumSignatures
Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 11] -/
structure SignatureScheme (Message PublicKey SecretKey Signature : Type) where
  keygen : SecretKey → PublicKey
  sign : SecretKey → Message → Signature
  verify : PublicKey → Message → Signature → Prop
  correctness : ∀ sk m, verify (keygen sk) m (sign sk m)




/-- [Section: # CatalogBuild.Cryptography.QuantumSecurity.PostQuantumSignatures
Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 11] -/
structure LatticeParams where
  n : ℕ
  q : ℕ
  β : ℝ
  hn : 0 < n
  hq : 1 < q
  hβ : 0 < β




structure SISHardness where
  sisAdvantage : ℕ → ℝ
  isHard : ∀ c : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → |sisAdvantage n| < (1 / (n : ℝ)) ^ c




/-- Security of lattice signature reduces to SIS hardness -/
theorem lattice_sig_security (sis : SISHardness)
    (forgeryAdvantage : ℕ → ℝ)
    (h_reduction : ∀ n, |forgeryAdvantage n| ≤ |sis.sisAdvantage n| + (1 / (n : ℝ)) ^ n) :
    ∀ c : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      |forgeryAdvantage n| < 2 * (1 / (n : ℝ)) ^ c + (1 / (n : ℝ)) ^ n := by
  intro c
  obtain ⟨N, hN⟩ := sis.isHard c
  exact ⟨N, fun n hn => by
    have h1 := h_reduction n
    have h2 := hN n hn
    have h3 : (0:ℝ) ≤ (1 / (n : ℝ)) ^ c := by positivity
    linarith⟩




noncomputable def blsSigSize : ℝ := 48



noncomputable def latticeSigSize (n : ℕ) : ℝ := 2 * (n : ℝ)




theorem bls_more_compact_small (n : ℕ) (hn : n < 24) :
    latticeSigSize n < blsSigSize := by
  unfold latticeSigSize blsSigSize
  have : (n : ℝ) < 24 := by exact_mod_cast hn
  linarith




theorem lattice_larger_for_security (n : ℕ) (hn : 24 ≤ n) :
    blsSigSize ≤ latticeSigSize n := by
  unfold latticeSigSize blsSigSize
  have : (24 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  linarith




theorem aggregation_space_saving (k : ℕ) (sigSize aggSize : ℝ)
    (hk : 1 < k) (hSig : 0 < sigSize)
    (h_saving : aggSize < k * sigSize) :
    aggSize / (k * sigSize) < 1 := by
  rw [div_lt_one (by positivity)]
  exact h_saving




theorem quantum_lattice_exponential (n : ℕ) (hn : 2 ≤ n) :
    (1 : ℝ) < 2 ^ n := by
  have : (1:ℝ) < 2 := by norm_num
  exact one_lt_pow₀ this (by omega)




theorem bls_quantum_broken
    (blsBreakComplexity : ℕ → ℝ)
    (h_shor : ∀ n, blsBreakComplexity n ≤ (n : ℝ) ^ 3) :
    ∀ n : ℕ, blsBreakComplexity n ≤ (n : ℝ) ^ 3 :=
  h_shor




end
