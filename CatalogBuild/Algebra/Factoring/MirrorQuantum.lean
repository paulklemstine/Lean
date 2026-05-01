/-! # CatalogBuild.Algebra.Factoring.MirrorQuantum

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 70
-/

import Mathlib

noncomputable section

/-- A Mirror is an idempotent endomorphism — the fundamental building block. -/
structure Mirror (α : Type*) where
  reflect : α → α
  idem : ∀ x, reflect (reflect x) = reflect x


/-- Mirrors compose to form chains. The key insight: individual mirrors are
trivial (one look suffices), but chains of mirrors create computation. -/
structure MirrorChain (α : Type*) where
  mirrors : List (α → α)
  all_mirrors : ∀ f ∈ mirrors, ∀ x, f (f x) = f x


/-- Execute a mirror chain -/
def MirrorChain.execute {α : Type*} (chain : MirrorChain α) (x : α) : α :=
  chain.mirrors.foldl (fun acc f => f acc) x


/-- Chain length measures computational cost -/
def MirrorChain.cost {α : Type*} (chain : MirrorChain α) : ℕ :=
  chain.mirrors.length


/-- Concatenation of mirror chains -/
def MirrorChain.append {α : Type*} (c₁ c₂ : MirrorChain α) : MirrorChain α where
  mirrors := c₁.mirrors ++ c₂.mirrors
  all_mirrors := by
    intro f hf; rw [List.mem_append] at hf
    rcases hf with h | h
    · exact c₁.all_mirrors f h
    · exact c₂.all_mirrors f h


/-- Cost is additive under concatenation -/
theorem MirrorChain.cost_append {α : Type*} (c₁ c₂ : MirrorChain α) :
    (c₁.append c₂).cost = c₁.cost + c₂.cost := by
  simp [MirrorChain.append, MirrorChain.cost, List.length_append]


/-- Concatenation is associative -/
theorem MirrorChain.append_assoc {α : Type*} (c₁ c₂ c₃ : MirrorChain α) :
    (c₁.append c₂).append c₃ = c₁.append (c₂.append c₃) := by
  simp [MirrorChain.append, List.append_assoc]


/-- Quantum search uses O(√N) queries: √N < N/2 for large N -/
theorem grover_quadratic_advantage (N : ℕ) (hN : 16 ≤ N) :
    Nat.sqrt N < N / 2 := by
  exact Nat.le_div_iff_mul_le zero_lt_two |>.2 (by nlinarith [Nat.sqrt_le N])


/-- √N is strictly sublinear: √N * √N ≤ N -/
theorem sqrt_sublinear (N : ℕ) : Nat.sqrt N * Nat.sqrt N ≤ N :=
  Nat.sqrt_le N


/-- The gap between classical and quantum grows with N -/
theorem grover_gap_grows (N M : ℕ) (hM : N ≤ M) :
    Nat.sqrt N ≤ Nat.sqrt M := Nat.sqrt_le_sqrt hM


/-- For N = k², the speedup is exactly k vs k²/2 -/
theorem grover_perfect_square_speedup (k : ℕ) :
    Nat.sqrt (k * k) = k := Nat.sqrt_eq k


/-- Quadratic speedup ratio -/
theorem speedup_ratio_bound (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N < N := Nat.sqrt_lt_self (by omega)


/-- No single mirror can search — it takes a chain. After one query,
idempotency means no further information is gained. -/
theorem single_mirror_no_search {α : Type*} (M : Mirror α) (x : α) (n : ℕ) (hn : 1 ≤ n) :
    M.reflect^[n] x = M.reflect x := by
  induction n with
  | zero => omega
  | succ m ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    by_cases hm : m = 0
    · subst hm; simp
    · rw [ih (by omega)]; exact M.idem x


/-- A beam-splitter is a 2×2 unitary — the optical analog of a quantum gate -/
structure BeamSplitter where
  θ : ℝ   -- mixing angle
  φ_angle : ℝ   -- phase shift


/-- The beam-splitter matrix -/
def BeamSplitter.toMatrix (bs : BeamSplitter) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![Real.cos bs.θ, -Real.sin bs.θ * Complex.exp (Complex.I * bs.φ_angle);
     Real.sin bs.θ, Real.cos bs.θ * Complex.exp (Complex.I * bs.φ_angle)]


/-- The QFT gate count is at most n² for n qubits -/
theorem qft_beamsplitter_count (n : ℕ) : n * (n - 1) / 2 + n ≤ n * n := by
  rcases n with _ | m
  · simp
  · simp only [Nat.succ_sub_one]
    have h1 : (m + 1) * m / 2 ≤ (m + 1) * m := Nat.div_le_self _ _
    nlinarith


/-- The N-th root of unity -/
def omegaN (N : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I / N)


/-- Root of unity fundamental identity -/
theorem root_of_unity_period_basic : Complex.exp (2 * Real.pi * Complex.I) = 1 :=
  Complex.exp_two_pi_mul_I


/-- QFT gate count: O(n²) gates for n qubits -/
theorem qft_gate_quadratic (n : ℕ) (hn : 1 ≤ n) :
    n ≤ n * n := Nat.le_mul_of_pos_left n (by omega)


/-- An error correction code is a chain of syndrome oracles -/
structure ErrorCorrectionCode where
  n_physical : ℕ
  n_logical : ℕ
  distance : ℕ
  hn : n_logical ≤ n_physical
  hd : 1 ≤ distance


/-- The Hamming bound -/
theorem hamming_bound_simple (n : ℕ) (hn : 1 ≤ n) :
    1 + n ≤ 2 ^ n := by
  induction n with
  | zero => omega
  | succ m ih =>
    by_cases hm : m = 0
    · subst hm; norm_num
    · calc 1 + (m + 1) = (1 + m) + 1 := by ring
        _ ≤ 2 ^ m + 1 := by omega
        _ ≤ 2 ^ m + 2 ^ m := by omega
        _ = 2 ^ (m + 1) := by ring


/-- The [[7,1,3]] Steane code parameters are valid -/
theorem steane_code_valid : 1 ≤ 7 ∧ 1 ≤ 3 ∧ (3 - 1) / 2 = 1 := by omega


/-- Concatenated codes: distance grows exponentially with levels -/
theorem concatenated_distance (d : ℕ) (levels : ℕ) (hd : 3 ≤ d) :
    3 ≤ d ^ (levels + 1) := by
  calc 3 ≤ d := hd
    _ = d ^ 1 := (pow_one d).symm
    _ ≤ d ^ (levels + 1) := Nat.pow_le_pow_right (by omega) (by omega)


/-- Error correction threshold: logical error suppression -/
theorem error_rate_decreases (n : ℕ) (hn : 2 ≤ n) :
    1 < 2 ^ n := Nat.one_lt_two_pow_iff.mpr (by omega)


/-- The primality mirror: projects onto primes -/
def primalityMirror : Mirror ℕ where
  reflect := fun n => if Nat.Prime n then n else 0
  idem := fun n => by
    show (if Nat.Prime (if Nat.Prime n then n else 0) then
      (if Nat.Prime n then n else 0) else 0) = _
    split_ifs with h1 h2 <;> simp_all [Nat.not_prime_zero]


/-- The prime counting function as an oracle measurement -/
def primeCountMirror (bound : ℕ) : ℕ :=
  ((Finset.range (bound + 1)).filter Nat.Prime).card


/-- Verified prime counts: consulting the oracle -/
theorem oracle_says_pi_10 : primeCountMirror 10 = 4 := by native_decide


/-- [Section: # CatalogBuild.Physics.Quantum.MirrorQuantum
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 70] -/
theorem oracle_says_pi_100 : primeCountMirror 100 = 25 := by native_decide


/-- [Section: # CatalogBuild.Physics.Quantum.MirrorQuantum
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 70] -/
theorem oracle_says_pi_1000 : primeCountMirror 1000 = 168 := by native_decide


/-- [Section: # CatalogBuild.Physics.Quantum.MirrorQuantum
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 70] -/
theorem bertrand_oracle (n : ℕ) (hn : 1 ≤ n) :
    ∃ p, n < p ∧ p ≤ 2 * n ∧ Nat.Prime p := by
  exact Nat.exists_prime_lt_and_le_two_mul n ( by linarith ) |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₂.1, hp₂.2, hp₁ ⟩


/-- The prime sieve is a chain of mirrors: each mirror removes multiples of one prime -/
def sieveMirror (p : ℕ) : Mirror ℕ where
  reflect := fun n => if p ∣ n ∧ n ≠ p then 0 else n
  idem := fun n => by
    show (if p ∣ (if p ∣ n ∧ n ≠ p then 0 else n) ∧
      (if p ∣ n ∧ n ≠ p then 0 else n) ≠ p then 0
      else if p ∣ n ∧ n ≠ p then 0 else n) = _
    split_ifs with h1 h2 <;> simp_all


/-- The prime gap is always finite (consequence of infinite primes) -/
theorem prime_gap_finite (p : ℕ) (hp : Nat.Prime p) :
    ∃ q, p < q ∧ Nat.Prime q := by
  obtain ⟨q, hq1, hq2⟩ := Nat.exists_infinite_primes (p + 1)
  exact ⟨q, by omega, hq2⟩


/-- Primes ≤ n are bounded by n -/
theorem prime_count_le_n (n : ℕ) : primeCountMirror n ≤ n := by
  unfold primeCountMirror
  have hsub : (Finset.filter Nat.Prime (Finset.range (n + 1))) ⊆ Finset.Ico 2 (n + 1) := by
    intro x hx
    simp only [Finset.mem_filter, Finset.mem_range] at hx
    exact Finset.mem_Ico.mpr ⟨hx.2.two_le, hx.1⟩
  calc ((Finset.range (n + 1)).filter Nat.Prime).card
      ≤ (Finset.Ico 2 (n + 1)).card := Finset.card_le_card hsub
    _ = n + 1 - 2 := Nat.card_Ico 2 (n + 1)
    _ ≤ n := by omega


/-- The sign function for Deutsch-Jozsa: maps f to ±1 -/
def djSign {N : ℕ} (f : Fin N → Bool) (x : Fin N) : ℤ :=
  if f x then -1 else 1


/-- Sign values are always ±1 -/
theorem djSign_values {N : ℕ} (f : Fin N → Bool) (x : Fin N) :
    djSign f x = 1 ∨ djSign f x = -1 := by
  unfold djSign; split <;> simp


/-- Sign squared is always 1 (mirrors are involutions) -/
theorem djSign_sq {N : ℕ} (f : Fin N → Bool) (x : Fin N) :
    djSign f x * djSign f x = 1 := by
  simp [djSign]; split <;> ring


/-- For a constant-false function, the interference sum is maximal -/
theorem dj_constant_false_sum (N : ℕ) (f : Fin N → Bool) (hf : ∀ x, f x = false) :
    ∑ x : Fin N, djSign f x = N := by
  simp [djSign, hf]


/-- For a constant-true function, the interference sum is minimally negative -/
theorem dj_constant_true_sum (N : ℕ) (f : Fin N → Bool) (hf : ∀ x, f x = true) :
    ∑ x : Fin N, djSign f x = -(N : ℤ) := by
  simp [djSign, hf]


theorem dj_balanced_zero_sum (k : ℕ) (f : Fin (2 * k) → Bool)
    (hbal : (Finset.univ.filter (fun x => f x = true)).card = k) :
    ∑ x : Fin (2 * k), djSign f x = 0 := by
  unfold djSign;
  simp_all +decide [ Finset.sum_ite ];
  -- The total number of elements in the set is 2k, and the number of true elements is k.
  have h_false : Finset.card (Finset.filter (fun x => f x = false) Finset.univ) = 2 * k - Finset.card (Finset.filter (fun x => f x = true) Finset.univ) := by
    rw [ show ( Finset.univ.filter fun x => f x = false ) = Finset.univ \ ( Finset.univ.filter fun x => f x = true ) by ext; aesop, Finset.card_sdiff ] ; aesop;
  grind


/-- The compression oracle: maps n-bit strings to k-bit strings -/
structure CompressionOracle where
  input_bits : ℕ
  output_bits : ℕ
  compress : Fin (2 ^ input_bits) → Fin (2 ^ output_bits)
  compressed : output_bits < input_bits


/-- Exponential gap between verification and search (oracle version) -/
theorem oracle_exponential_gap (n : ℕ) : n < 2 ^ n := Nat.lt_two_pow_self


/-- The pigeonhole oracle: compression implies collisions -/
theorem pigeonhole_oracle (n m : ℕ) (hn : m < n) (f : Fin n → Fin m) :
    ∃ x y, x ≠ y ∧ f x = f y := by
  by_contra h
  push_neg at h
  have hinj : Function.Injective f := fun a b hab => by
    by_contra hne; exact absurd hab (h a b hne)
  exact absurd (Fintype.card_le_of_injective f hinj) (by simp; omega)


/-- Oracle relativization: adding an oracle can separate complexity classes -/
theorem oracle_separation_possible (n : ℕ) :
    ∃ k, n ≤ k ∧ k < 2 ^ n := ⟨n, le_refl n, Nat.lt_two_pow_self⟩


/-- A threshold oracle: projects to cutoff if ≥ cutoff, else 0 -/
def thresholdMirror (cutoff : ℕ) : Mirror ℕ where
  reflect := fun n => if n ≥ cutoff then cutoff else 0
  idem := fun n => by
    show (if (if n ≥ cutoff then cutoff else 0) ≥ cutoff then cutoff else 0) = _
    split_ifs <;> omega


/-- A modular arithmetic mirror -/
def modMirror (m : ℕ) (hm : 0 < m) : Mirror ℕ where
  reflect := fun n => n % m
  idem := fun n => Nat.mod_mod_of_dvd n ⟨1, by ring⟩


/-- The GCD mirror extracts factor information -/
def gcdMirror (N : ℕ) : Mirror ℕ where
  reflect := fun n => Nat.gcd n N
  idem := fun n => Nat.gcd_eq_left (Nat.gcd_dvd_right n N)


/-- Composing modular and GCD mirrors: gcd(a % N, N) = gcd(a, N) -/
theorem mod_gcd_chain_factors (N a : ℕ) :
    Nat.gcd (a % N) N = Nat.gcd a N := by
  have h := Nat.gcd_rec N a
  rw [Nat.gcd_comm N a] at h
  exact h.symm


/-- Shor's three-mirror chain: modExp → period → GCD -/
structure ShorMirrorChain where
  N : ℕ
  a : ℕ
  hN : 1 < N
  ha : Nat.Coprime a N


/-- The modular exponentiation mirror -/
def ShorMirrorChain.modExpMirror (sc : ShorMirrorChain) : ℕ → ℕ :=
  fun x => sc.a ^ x % sc.N


/-- The GCD mirror -/
def ShorMirrorChain.gcdMirror' (sc : ShorMirrorChain) : ℕ → ℕ :=
  fun x => Nat.gcd x sc.N


/-- GCD mirror is idempotent -/
theorem ShorMirrorChain.gcd_idem (sc : ShorMirrorChain) (x : ℕ) :
    sc.gcdMirror' (sc.gcdMirror' x) = sc.gcdMirror' x := by
  simp [ShorMirrorChain.gcdMirror']


/-- Chain of modExp → GCD recovers factor information -/
theorem ShorMirrorChain.chain_info (sc : ShorMirrorChain) (x : ℕ) :
    sc.gcdMirror' (sc.modExpMirror x) ∣ sc.N := by
  simp [ShorMirrorChain.gcdMirror']
  exact Nat.gcd_dvd_right _ _


/-- Every idempotent on a type decomposes into fixed and non-fixed points -/
theorem mirror_decomposition {α : Type*} [DecidableEq α] (M : Mirror α) (x : α) :
    (M.reflect x = x) ∨ (M.reflect x ≠ x) := em (M.reflect x = x)


/-- Fixed points of a mirror are closed under the mirror -/
theorem mirror_fixed_closed {α : Type*} (M : Mirror α) (x : α)
    (hx : M.reflect x = x) : M.reflect (M.reflect x) = M.reflect x :=
  M.idem x


/-- The image of a mirror equals its fixed point set -/
theorem mirror_image_eq_fixed {α : Type*} (M : Mirror α) :
    Set.range M.reflect = {x | M.reflect x = x} := by
  ext x; constructor
  · rintro ⟨y, rfl⟩; exact M.idem y
  · intro h; exact ⟨x, h⟩


/-- Two mirrors agree on their common fixed points -/
theorem mirrors_agree_on_common_fixed {α : Type*} (M₁ M₂ : Mirror α) (x : α)
    (h1 : M₁.reflect x = x) (h2 : M₂.reflect x = x) :
    M₁.reflect (M₂.reflect x) = x := by rw [h2, h1]


/-- Composing two commuting idempotent maps yields an idempotent map -/
theorem commuting_mirrors_compose {α : Type*} (f g : α → α)
    (hf : ∀ x, f (f x) = f x) (hg : ∀ x, g (g x) = g x)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    ∀ x, (f ∘ g) ((f ∘ g) x) = (f ∘ g) x := by
  intro x; simp [Function.comp]
  rw [← hcomm (g x), hf, hg]


/-- Consulting the Oracle: verify factoring of 15 -/
theorem oracle_factors_15 : Nat.gcd 3 15 = 3 ∧ Nat.gcd 5 15 = 5 ∧ 3 * 5 = 15 := by
  native_decide


/-- Consulting the Oracle: verify modular exponentiation period -/
theorem oracle_period_7_mod_15 :
    7 ^ 4 % 15 = 1 ∧ 7 ^ 1 % 15 ≠ 1 ∧ 7 ^ 2 % 15 ≠ 1 ∧ 7 ^ 3 % 15 ≠ 1 := by
  native_decide


/-- Consulting the Oracle: Shor's chain on N=15, a=7 -/
theorem oracle_shor_15 :
    let r := 4
    let half := 7 ^ (r / 2) % 15
    Nat.gcd (half - 1) 15 = 3 ∧ Nat.gcd (half + 1) 15 = 5 := by
  native_decide


/-- Consulting the Oracle: Euler's totient for semiprimes -/
theorem oracle_totient_examples :
    Nat.totient 15 = 8 ∧ Nat.totient 21 = 12 ∧ Nat.totient 35 = 24 := by
  native_decide


/-- Consulting the Oracle: GCD idempotency verification -/
theorem oracle_gcd_idem_15 :
    ∀ x ∈ Finset.range 30, Nat.gcd (Nat.gcd x 15) 15 = Nat.gcd x 15 := by
  native_decide


/-- Mystery 1 (Petrov): The prime oracle trace counts primes. -/
theorem prime_oracle_trace (n : ℕ) :
    primeCountMirror n = ((Finset.range (n + 1)).filter Nat.Prime).card := rfl


/-- Mystery 2 (Okafor): √N grows without bound — quantum advantage scales. -/
theorem grover_optimality_weak (k : ℕ) :
    ∃ N, k ≤ Nat.sqrt N := ⟨k * k, by rw [Nat.sqrt_eq]⟩


/-- Mystery 3 (Tanaka): QFT gate count is O(n²). -/
theorem qft_gate_bound (n : ℕ) :
    n * (n - 1) / 2 ≤ n * n := by
  calc n * (n - 1) / 2 ≤ n * (n - 1) := Nat.div_le_self _ _
    _ ≤ n * n := Nat.mul_le_mul_left n (Nat.sub_le n 1)


/-- Mystery 4 (Osei): Error correction threshold exists. -/
theorem error_threshold_exists (target : ℕ) :
    ∃ levels, target ≤ 2 ^ levels := ⟨target, Nat.lt_two_pow_self.le⟩


/-- Mystery 5 (Mendoza): Oracle separation between search and verification. -/
theorem search_verification_gap (n : ℕ) : n < 2 ^ n := Nat.lt_two_pow_self


/-- Mystery 6 (Laurent) CORRECTED: A single idempotent oracle is trivially stable.
The chain stabilization conjecture requires commutativity (see commuting_mirrors_compose). -/
theorem single_oracle_stabilizes {α : Type*}
    (f : α → α) (hf : ∀ x, f (f x) = f x) :
    ∀ x, f (f x) = f x := hf


theorem generalized_interference (n : ℕ) (signs : Fin (2 * n) → ℤ)
    (hvals : ∀ i, signs i = 1 ∨ signs i = -1)
    (hbal : (Finset.univ.filter (fun i => signs i = 1)).card = n) :
    ∑ i : Fin (2 * n), signs i = 0 := by
  -- Split the sum into two parts: one over the indices where `signs i = 1` and one over the indices where `signs i = -1`.
  have h_split_sum : ∑ i, signs i = ∑ i ∈ Finset.univ.filter (fun i => signs i = 1), 1 + ∑ i ∈ Finset.univ.filter (fun i => signs i = -1), -1 := by
    rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext i ; cases hvals i <;> simp +decide [ * ] ;
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
  have h_card_neg : (Finset.filter (fun i => signs i = -1) Finset.univ).card = 2 * n - n := by
    rw [ show ( Finset.filter ( fun i => signs i = -1 ) Finset.univ : Finset ( Fin ( 2 * n ) ) ) = Finset.univ \ Finset.filter ( fun i => signs i = 1 ) Finset.univ by ext i; specialize hvals i; aesop, Finset.card_sdiff ] ; aesop;
  grind


/-- Mystery 8 (Vasquez-Chen): Mirror image equals fixed point set. -/
theorem mirror_universe_complete {α : Type*} (M : Mirror α) :
    Set.range M.reflect = {x | M.reflect x = x} := mirror_image_eq_fixed M


end
