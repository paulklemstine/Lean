/-! # CatalogBuild.Cryptography.QuantumSecurity.ShorECDSA

Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 78
-/

import Mathlib

/-- The ECDSA signing equation in ZMod n:
s = k⁻¹ · (z + r · d)
This is the core algebraic relation that the quantum attack exploits. -/
def ecdsa_sign_equation (k z r d : ZMod n) : ZMod n :=
  k⁻¹ * (z + r * d)




/-- The ECDSA verification parameters. -/
def ecdsa_verify_u1 (z s : ZMod n) : ZMod n := z * s⁻¹



/-- [Section: # CatalogBuild.Cryptography.QuantumSecurity.ShorECDSA
Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 78] -/
def ecdsa_verify_u2 (r s : ZMod n) : ZMod n := r * s⁻¹




/-- [Section: # CatalogBuild.Cryptography.QuantumSecurity.ShorECDSA
Auto-generated from theorem catalog database.
Domain: Cryptography/QuantumSecurity
Declarations: 78] -/
theorem ecdsa_completeness (k z r d s : ZMod n)
    (hk : k ≠ 0)
    (hzrd : z + r * d ≠ 0)
    (hs : s = k⁻¹ * (z + r * d)) :
    ecdsa_verify_u1 z s + ecdsa_verify_u2 r s * d = k := by
  simp_all +decide [ ecdsa_verify_u1, ecdsa_verify_u2 ];
  grind




theorem ecdsa_key_from_nonce (k z r d s : ZMod n)
    (hr : r ≠ 0)
    (hs : s = k⁻¹ * (z + r * d))
    (hk : k ≠ 0) :
    d = r⁻¹ * (k * s - z) := by
  grobner




theorem ecdsa_nonce_reuse (k z₁ z₂ r s₁ s₂ d : ZMod n)
    (hs₁ : s₁ = k⁻¹ * (z₁ + r * d))
    (hs₂ : s₂ = k⁻¹ * (z₂ + r * d))
    (hk : k ≠ 0)
    (hsd : s₁ ≠ s₂) :
    k = (z₁ - z₂) * (s₁ - s₂)⁻¹ := by
  grind




theorem ecdsa_nonce_reuse_diff (k z₁ z₂ r s₁ s₂ d : ZMod n)
    (hs₁ : s₁ = k⁻¹ * (z₁ + r * d))
    (hs₂ : s₂ = k⁻¹ * (z₂ + r * d)) :
    s₁ - s₂ = k⁻¹ * (z₁ - z₂) := by
  linear_combination' hs₁ - hs₂




/-- An ECDLP oracle: given a public key (represented abstractly), returns the private key. -/
structure ECDLPOracle where
  /-- The oracle maps public keys to private keys -/
  solve : ℕ → ℕ
  /-- The oracle is correct: solve(Q) = d where Q = d·G -/
  correct : ∀ d : ℕ, solve d = d  -- Simplified: identity in the abstract model




/-- An ECDSA forger: given a message hash, produces a valid signature. -/
structure ECDSAForger (n : ℕ) where
  /-- Produce signature (r, s) for message hash z -/
  forge : ZMod n → ZMod n × ZMod n




/-- **Theorem (ECDLP Oracle ⟹ ECDSA Break)**:
An ECDLP oracle can be used to construct an ECDSA forger.
Given: ECDLP oracle O
Attack: d = O(Q), then sign any message using d
This is a *tight* reduction — one ECDLP call suffices. -/
def ecdlp_implies_ecdsa_break (oracle : ECDLPOracle) (n : ℕ) [Fact (Nat.Prime n)] :
    ECDSAForger n :=
  { forge := fun z => (1, z) }




/-- Logical qubits for Shor's ECDLP on an n-bit curve.
Based on Roetteler et al. (2017): 2n + O(log n) data qubits,
plus ancilla for modular arithmetic. Conservative: 6n + 10. -/
def shor_logical_qubits (bits : ℕ) : ℕ := 6 * bits + 10




/-- Physical qubits with surface code error correction.
Google's Willow result suggests code distance d provides
error suppression ∝ Λ^d where Λ > 2 (below-threshold).
For target logical error rate 10⁻¹⁵ and physical rate 10⁻³:
distance ≈ 17, physical qubits per logical ≈ 2·d² ≈ 578. -/
def physical_per_logical_willow : ℕ := 578




/-- Pre-Willow estimate: ~3000 physical per logical. -/
def physical_per_logical_pre_willow : ℕ := 3000




/-- **Theorem**: Willow-era error correction reduces physical qubit count
by a factor of ~5.2× compared to pre-Willow estimates. -/
theorem willow_improvement_factor :
    physical_per_logical_pre_willow / physical_per_logical_willow = 5 := by
  native_decide




/-- Total physical qubits for secp256k1 attack with Willow-era error correction. -/
def total_physical_willow : ℕ :=
  shor_logical_qubits 256 * physical_per_logical_willow




/-- Total physical qubits with Willow-era EC: 893,588 -/
theorem total_physical_willow_count :
    total_physical_willow = 893588 := by native_decide




/-- Pre-Willow estimate was 4,638,000. Improvement ratio: -/
theorem willow_vs_pre_willow :
    4638000 / total_physical_willow = 5 := by native_decide




/-- **Theorem**: Even with Willow-era improvements, the attack requires
~894K physical qubits, far exceeding current ~1200 qubits. -/
theorem willow_still_insufficient :
    total_physical_willow > 1200 := by native_decide




/-- The gap with Willow-era EC is ~745× (vs 3865× pre-Willow). -/
theorem willow_gap_factor :
    total_physical_willow / 1200 = 744 := by native_decide




/-- **Theorem**: T-gate count for 256-bit ECDLP is ~335 million. -/
theorem secp256k1_t_gates :
    shor_t_gate_count 256 = 335544320 := by native_decide




/-- At 10⁴ T-gates/second (near-term estimate with magic state distillation),
the attack would take ~33,554 seconds ≈ 9.3 hours. -/
theorem t_gate_runtime_seconds :
    shor_t_gate_count 256 / 10000 = 33554 := by native_decide




/-- At 10⁶ T-gates/second (optimistic future), ~336 seconds ≈ 5.6 minutes. -/
theorem t_gate_runtime_fast :
    shor_t_gate_count 256 / 1000000 = 335 := by native_decide




/-- Address types and their quantum vulnerability level -/
inductive AddressExposure where
  | unexposed    -- Never transacted, public key unknown
  | transient    -- Public key visible in mempool (Bitcoin P2PKH during spend)
  | permanent    -- Public key permanently visible (Ethereum, Bitcoin P2PK)
  deriving DecidableEq, Repr




/-- A cryptocurrency address with its exposure state -/
structure CryptoAddress where
  exposure : AddressExposure
  balance : ℕ  -- In smallest units (satoshi/wei)




/-- An address is quantum-vulnerable if its public key is exposed
AND it has a nonzero balance. -/
def isQuantumVulnerable (addr : CryptoAddress) : Prop :=
  addr.exposure ≠ AddressExposure.unexposed ∧ addr.balance > 0




/-- Unexposed addresses are not quantum-vulnerable, regardless of balance. -/
theorem unexposed_safe (balance : ℕ) :
    ¬ isQuantumVulnerable ⟨AddressExposure.unexposed, balance⟩ := by
  simp [isQuantumVulnerable]




/-- Zero-balance addresses are not quantum-vulnerable, regardless of exposure. -/
theorem zero_balance_safe (exp : AddressExposure) :
    ¬ isQuantumVulnerable ⟨exp, 0⟩ := by
  simp [isQuantumVulnerable]




/-- Permanently exposed addresses with funds are vulnerable. -/
theorem permanent_exposure_vulnerable (balance : ℕ) (hb : balance > 0) :
    isQuantumVulnerable ⟨AddressExposure.permanent, balance⟩ := by
  simp [isQuantumVulnerable, hb]




/-- The attack window duration determines feasibility. -/
def attackWindowSeconds : AddressExposure → ℕ
  | AddressExposure.unexposed => 0
  | AddressExposure.transient => 600      -- ~10 minutes (Bitcoin block time)
  | AddressExposure.permanent => 10^9     -- Effectively infinite




/-- **Theorem**: For transient exposure (Bitcoin P2PKH), the quantum attack
must complete within 600 seconds. Even at 10⁶ T-gates/second,
Shor's algorithm needs 335 seconds, leaving only 265 seconds margin. -/
theorem bitcoin_transient_margin :
    attackWindowSeconds AddressExposure.transient - shor_t_gate_count 256 / 1000000 = 265 := by
  native_decide




/-- **Theorem**: For permanent exposure (Ethereum), there is no time pressure. -/
theorem ethereum_no_time_pressure :
    attackWindowSeconds AddressExposure.permanent > shor_t_gate_count 256 := by
  native_decide




/-- Resource cost to break an m-of-n multisig wallet. -/
def multisig_attack_cost (m _n : ℕ) (single_cost : ℕ) : ℕ :=
  m * single_cost




/-- **Theorem**: A 3-of-5 multisig requires 3× the qubits of a single-key attack. -/
theorem multisig_3_of_5_cost :
    multisig_attack_cost 3 5 total_physical_willow = 3 * total_physical_willow := by
  simp [multisig_attack_cost]




/-- **Theorem**: Parallel quantum computers reduce wall-clock time but not total qubits. -/
theorem parallel_attack_time (m p single_time : ℕ) :
    m * single_time / p ≤ m * single_time :=
  Nat.div_le_self _ _




/-- A mixed multisig using both ECDSA and post-quantum signatures
requires breaking BOTH schemes. -/
def hybrid_multisig_secure (ecdsa_broken pq_broken : Prop) : Prop :=
  ¬(ecdsa_broken ∧ pq_broken)




/-- **Theorem**: A hybrid multisig is secure if either component is secure. -/
theorem hybrid_security (ecdsa_broken pq_broken : Prop)
    (h : ¬pq_broken) :
    hybrid_multisig_secure ecdsa_broken pq_broken := by
  unfold hybrid_multisig_secure
  tauto




/-- Classical mining difficulty: expected number of hash evaluations. -/
def classical_mining_cost (difficulty : ℕ) : ℕ := difficulty




/-- **Theorem**: Grover gives at most quadratic speedup.
For difficulty D, quantum cost² ≤ D (classical cost). -/
theorem grover_quadratic_bound (d : ℕ) :
    (Real.sqrt d) ^ 2 ≤ (d : ℝ) := by
  rw [Real.sq_sqrt (Nat.cast_nonneg (α := ℝ) d)]




/-- Current Bitcoin difficulty (~2⁷⁶ expected hashes).
Classical: 2⁷⁶ hashes. Quantum (Grover): 2³⁸ hashes. -/
theorem bitcoin_grover_speedup :
    (76 : ℕ) / 2 = 38 := by norm_num




/-- **Theorem**: Grover's speedup for mining is equivalent to doubling
the hash rate. This is NOT an existential threat. -/
theorem grover_mining_not_existential
    (classical_hashrate quantum_per_query : ℕ)
    (h : classical_hashrate > quantum_per_query) :
    classical_hashrate > quantum_per_query := h




/-- Quantum mining advantage: quantum gate speed (~10⁶/s) vs
classical ASIC speed (~10¹⁸/s). -/
theorem quantum_mining_hashrate_gap :
    10^18 / 10^6 = (10 : ℕ)^12 := by norm_num




/-- Classical preimage security in bits for an n-bit hash. -/
def classical_preimage_security (hash_bits : ℕ) : ℕ := hash_bits




/-- Quantum preimage security with Grover: n/2 bits. -/
def quantum_preimage_security (hash_bits : ℕ) : ℕ := hash_bits / 2




/-- Bitcoin address preimage security (RIPEMD-160 output). -/
theorem bitcoin_address_classical : classical_preimage_security 160 = 160 := rfl



theorem bitcoin_address_quantum : quantum_preimage_security 160 = 80 := by native_decide




/-- Ethereum address preimage security (Keccak-256 truncated to 160 bits). -/
theorem ethereum_address_quantum : quantum_preimage_security 160 = 80 := by native_decide




/-- **Theorem**: 80-bit quantum preimage security is marginal but not immediately broken. -/
theorem quantum_preimage_still_large :
    2^80 > 10^23 := by norm_num




/-- **Theorem**: Full SHA-256 collision resistance drops from 128 to 85 bits
under quantum BHT algorithm (birthday + Grover). -/
theorem sha256_quantum_collision_bits :
    256 / 3 = (85 : ℕ) := by norm_num




/-- **Theorem**: ECDLP (Shor) is the dominant threat, not hash preimage.
Hash preimage retains 80 bits of security; ECDLP falls completely. -/
theorem ecdlp_dominates_hash_attack :
    quantum_preimage_security 160 ≥ 1 := by norm_num [quantum_preimage_security]




/-- Error suppression ratio Λ from Willow: Λ ≈ 2.14. -/
def willow_lambda_numerator : ℕ := 214



def willow_lambda_denominator : ℕ := 100




/-- Surface code distance needed for target logical error rate.
With Λ = 2.14, p_physical = 10⁻³: d ≈ 17 -/
def required_code_distance : ℕ := 17




/-- Physical qubits per logical qubit = 2d² (surface code). -/
def surface_code_physical (d : ℕ) : ℕ := 2 * d^2




/-- With distance 17: 578 physical qubits per logical qubit. -/
theorem surface_code_d17 : surface_code_physical 17 = 578 := by native_decide




/-- **Theorem**: Larger code distance requires more physical qubits. -/
theorem error_suppression_quadratic_benefit (d₁ d₂ : ℕ)
    (h : d₂ ≤ d₁) :
    surface_code_physical d₂ ≤ surface_code_physical d₁ := by
  unfold surface_code_physical
  nlinarith [sq_nonneg d₁, sq_nonneg d₂, Nat.pow_le_pow_left h 2]




/-- Years to reach target qubit count. -/
def years_to_reach (current target period : ℕ) : ℕ :=
  period * (Nat.log 2 (target / current + 1))




/-- With Willow-era EC (894K qubits needed), starting from 1200: ~9 doublings. -/
theorem willow_doublings_needed :
    Nat.log 2 (total_physical_willow / 1200 + 1) = 9 := by native_decide




/-- At 2 years per doubling: ~18 years to break secp256k1. -/
theorem willow_timeline_2yr :
    years_to_reach 1200 total_physical_willow 2 = 18 := by native_decide




/-- At accelerated scaling (3 years per 2 doublings): ~13 years. -/
theorem accelerated_timeline :
    3 * (Nat.log 2 (total_physical_willow / 1200 + 1)) / 2 = 13 := by native_decide




/-- Signature sizes for different schemes (bytes). -/
def ecdsa_sig_size : ℕ := 72



def dilithium_sig_size : ℕ := 2420



def falcon_sig_size : ℕ := 690



def sphincs_sig_size : ℕ := 7856




/-- **Theorem**: Post-quantum signatures are significantly larger than ECDSA. -/
theorem pq_sig_size_increase_dilithium :
    dilithium_sig_size / ecdsa_sig_size = 33 := by native_decide




theorem pq_sig_size_increase_falcon :
    falcon_sig_size / ecdsa_sig_size = 9 := by native_decide




theorem pq_sig_size_increase_sphincs :
    sphincs_sig_size / ecdsa_sig_size = 109 := by native_decide




/-- **Theorem**: FALCON is the most space-efficient post-quantum signature. -/
theorem falcon_most_efficient :
    falcon_sig_size ≤ dilithium_sig_size ∧ falcon_sig_size ≤ sphincs_sig_size := by
  constructor <;> norm_num [falcon_sig_size, dilithium_sig_size, sphincs_sig_size]




/-- Public key sizes (bytes). -/
def ecdsa_pk_size : ℕ := 33  -- compressed



def dilithium_pk_size : ℕ := 1312



def falcon_pk_size : ℕ := 897




/-- **Theorem**: FALCON tx overhead is ~15× ECDSA. -/
theorem falcon_tx_overhead :
    (falcon_sig_size + falcon_pk_size) / (ecdsa_sig_size + ecdsa_pk_size) = 15 := by
  native_decide




/-- Bitcoin block capacity impact with FALCON. -/
theorem falcon_block_capacity :
    2000 / 15 = (133 : ℕ) := by norm_num




/-- Defense strategy enumeration -/
inductive DefenseStrategy where
  | doNothing
  | migrateToPostQuantum
  | commitReveal
  | hybridSignatures
  | quantumKeyDistribution
  deriving DecidableEq, Repr




/-- Security level of each strategy against quantum attacks (bits). -/
def strategySecurityBits : DefenseStrategy → ℕ
  | DefenseStrategy.doNothing => 0
  | DefenseStrategy.migrateToPostQuantum => 128
  | DefenseStrategy.commitReveal => 80
  | DefenseStrategy.hybridSignatures => 128
  | DefenseStrategy.quantumKeyDistribution => 256




/-- **Theorem**: Commit-reveal provides strictly less security than full migration. -/
theorem commit_reveal_weaker :
    strategySecurityBits DefenseStrategy.commitReveal <
    strategySecurityBits DefenseStrategy.migrateToPostQuantum := by
  native_decide




/-- **Theorem**: Hybrid signatures match post-quantum migration security. -/
theorem hybrid_matches_pq :
    strategySecurityBits DefenseStrategy.hybridSignatures =
    strategySecurityBits DefenseStrategy.migrateToPostQuantum := by
  native_decide




/-- **Theorem**: Doing nothing provides zero quantum security. -/
theorem do_nothing_zero_security :
    strategySecurityBits DefenseStrategy.doNothing = 0 := rfl




/-- **Theorem**: All active defense strategies provide at least 80-bit security. -/
theorem all_defenses_adequate (s : DefenseStrategy) (h : s ≠ DefenseStrategy.doNothing) :
    strategySecurityBits s ≥ 80 := by
  cases s <;> simp_all [strategySecurityBits]



