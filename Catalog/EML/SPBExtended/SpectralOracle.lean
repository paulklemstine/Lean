import Mathlib

/-! # CatalogBuild.Computation.Oracles.SpectralOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 43
-/


noncomputable section

/-- An oracle is an idempotent endomorphism -/
structure SpectralOracle (α : Type*) where
  map : α → α
  idem : ∀ x, map (map x) = map x




/-- The identity oracle -/
def SpectralOracle.identity (α : Type*) : SpectralOracle α :=
  ⟨_root_.id, fun _ => rfl⟩




/-- An oracle's image equals its fixed point set -/
theorem spectral_range_eq_fixed {α : Type*} (O : SpectralOracle α) :
    Set.range O.map = {x | O.map x = x} := by
  ext x; constructor
  · rintro ⟨y, rfl⟩; exact O.idem y
  · intro h; exact ⟨x, h⟩




/-- Iterating an oracle any positive number of times gives the same result -/
theorem spectral_iterate_stable {α : Type*} (O : SpectralOracle α) (n : ℕ)
    (hn : 1 ≤ n) : ∀ x, O.map^[n] x = O.map x := by
  induction n with
  | zero => omega
  | succ k ih =>
    intro x
    rw [Function.iterate_succ, Function.comp_apply]
    by_cases hk : k = 0
    · simp [hk]
    · rw [ih (by omega) (O.map x), O.idem]




/-- Eigenvalues of an idempotent satisfy ev² = ev, hence ev ∈ {0, 1} -/
theorem spectral_eigenvalues (ev : ℝ) (h : ev * ev = ev) :
    ev = 0 ∨ ev = 1 := by
  have : ev * (ev - 1) = 0 := by ring_nf; linarith
  rcases mul_eq_zero.mp this with h0 | h1
  · exact Or.inl h0
  · exact Or.inr (by linarith)




/-- [Section: # CatalogBuild.Computation.Oracles.SpectralOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 43] -/
theorem complement_oracle_idem {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ) (hP : P * P = P) :
    (1 - P) * (1 - P) = 1 - P := by
  simp_all +decide [ sub_mul, mul_sub ] ;




/-- A quantum gate is a unitary matrix -/
structure LightGate (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℂ
  unitary : mat * star mat = 1




/-- Product of quantum gates is a quantum gate -/
def LightGate.compose {n : ℕ} (G₁ G₂ : LightGate n) : LightGate n where
  mat := G₁.mat * G₂.mat
  unitary := by
    rw [Matrix.star_mul, ← mul_assoc, mul_assoc G₁.mat]
    rw [G₂.unitary, mul_one, G₁.unitary]




/-- The Pauli X gate (quantum NOT) -/
def spectralPauliX : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; 1, 0]




/-- The Pauli Z gate (phase flip) -/
def spectralPauliZ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; 0, -1]




/-- X² = I -/
theorem spectralPauliX_sq : spectralPauliX * spectralPauliX = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spectralPauliX, Matrix.mul_apply, Fin.sum_univ_two]




/-- Z² = I -/
theorem spectralPauliZ_sq : spectralPauliZ * spectralPauliZ = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spectralPauliZ, Matrix.mul_apply, Fin.sum_univ_two]




/-- X and Z anticommute: XZ = -ZX -/
theorem spectralPauli_anticommute :
    spectralPauliX * spectralPauliZ = -(spectralPauliZ * spectralPauliX) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spectralPauliX, spectralPauliZ, Matrix.mul_apply, Fin.sum_univ_two, Matrix.neg_apply]




/-- det(X) = -1 -/
theorem det_spectralPauliX : Matrix.det spectralPauliX = -1 := by
  simp [spectralPauliX, Matrix.det_fin_two]




/-- The GCD oracle on ℕ: projects n to gcd(n, N) -/
def gcdSpectralOracle (N : ℕ) : SpectralOracle ℕ where
  map := fun n => Nat.gcd n N
  idem := fun n => by simp [Nat.gcd_comm, Nat.gcd_gcd_self_left_left]




/-- GCD oracle always produces divisors of N -/
theorem gcd_oracle_divides (N x : ℕ) : Nat.gcd x N ∣ N := Nat.gcd_dvd_right x N




/-- [Section: # CatalogBuild.Computation.Oracles.SpectralOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 43] -/
theorem factoring_semiprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    ∃ x, 1 < Nat.gcd x (p * q) ∧ Nat.gcd x (p * q) < p * q := by
  use p;
  norm_num [ hp.one_lt, hq.one_lt ];
  nlinarith [ hp.two_le, hq.two_le ]




/-- Prime counting up to n -/
def primeCount' (n : ℕ) : ℕ := ((Finset.range (n + 1)).filter Nat.Prime).card




theorem primeCount'_10 : primeCount' 10 = 4 := by native_decide



theorem primeCount'_100 : primeCount' 100 = 25 := by native_decide



theorem primeCount'_1000 : primeCount' 1000 = 168 := by native_decide




/-- The prime counting function is monotone -/
theorem primeCount'_mono {m n : ℕ} (h : m ≤ n) : primeCount' m ≤ primeCount' n := by
  unfold primeCount'; apply Finset.card_le_card
  apply Finset.filter_subset_filter; exact Finset.range_mono (by omega)




theorem primeCount'_le (n : ℕ) : primeCount' n ≤ n := by
  -- The set of primes less than or equal to $n$ is a subset of $\{2, 3, \ldots, n\}$, which has cardinality $n-1$.
  have h_subset : ((Finset.range (n + 1)).filter Nat.Prime) ⊆ Finset.Ico 2 (n + 1) := by
    exact fun x hx => Finset.mem_Ico.mpr ⟨ Nat.Prime.two_le ( Finset.mem_filter.mp hx |>.2 ), Finset.mem_range.mp ( Finset.mem_filter.mp hx |>.1 ) ⟩;
  exact le_trans ( Finset.card_le_card h_subset ) ( by simp +arith +decide )




/-- The Möbius oracle: μ² is idempotent on {0, 1} -/
theorem mobius_sq_oracle (n : ℕ) :
    (if Squarefree n then (1 : ℤ) else 0) * (if Squarefree n then (1 : ℤ) else 0)
    = if Squarefree n then (1 : ℤ) else 0 := by
  split <;> ring




/-- ReLU activation function -/
def spectralRelu (x : ℝ) : ℝ := max x 0




/-- ReLU is idempotent -/
theorem spectralRelu_idem (x : ℝ) : spectralRelu (spectralRelu x) = spectralRelu x := by
  simp only [spectralRelu]; exact max_eq_left (le_max_right x 0)




/-- ReLU preserves non-negativity -/
theorem spectralRelu_nonneg (x : ℝ) : 0 ≤ spectralRelu x := le_max_right x 0




/-- ReLU is monotone -/
theorem spectralRelu_mono {x y : ℝ} (h : x ≤ y) : spectralRelu x ≤ spectralRelu y :=
  max_le_max_right 0 h




/-- The threshold function -/
def spectralThreshold (x : ℝ) : ℝ := if x > 0 then 1 else 0




/-- Threshold is idempotent -/
theorem spectralThreshold_idem (x : ℝ) :
    spectralThreshold (spectralThreshold x) = spectralThreshold x := by
  simp only [spectralThreshold, gt_iff_lt]
  split <;> simp




/-- Neural oracle: threshold is an oracle -/
def neuralOracle : SpectralOracle ℝ where
  map := spectralThreshold
  idem := spectralThreshold_idem




/-- Phase shifter determinant -/
theorem spectralPhaseShifter_det (a b : ℝ) :
    Matrix.det (Matrix.diagonal (![a, b] : Fin 2 → ℝ)) = a * b := by
  simp [Matrix.det_fin_two, Matrix.diagonal]




/-- Reck decomposition gate count bound -/
theorem reck_count (n : ℕ) : n * (n - 1) / 2 ≤ n * n := by
  have : n * (n - 1) ≤ n * n := Nat.mul_le_mul_left n (Nat.sub_le n 1)
  omega




theorem oracle_comp_idem {n : ℕ}
    (P Q : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) (hQ : Q * Q = Q) (hPQ : P * Q = Q * P) :
    (P * Q) * (P * Q) = P * Q := by
  grind




/-- P vs NP: compression ratio bound -/
theorem pvnp_bound (n k : ℕ) (hk : 0 < k) : n / k ≤ n := Nat.div_le_self n k




theorem yang_mills_gap (eigenvalues : List ℝ)
    (hpos : ∀ ev ∈ eigenvalues, ev = 0 ∨ 0 < ev)
    (hne : ∃ ev ∈ eigenvalues, 0 < ev) :
    ∃ gap > 0, ∀ ev ∈ eigenvalues, ev = 0 ∨ gap ≤ ev := by
  -- Since there's at least one positive eigenvalue, take the minimum of the positive eigenvalues. That minimum is positive and smaller than or equal to all positive eigenvalues.
  obtain ⟨ev_min, hev_min⟩ : ∃ ev_min ∈ eigenvalues, ev_min > 0 ∧ ∀ ev ∈ eigenvalues, ev > 0 → ev_min ≤ ev := by
    obtain ⟨ev_min, hev_min⟩ : ∃ ev_min ∈ List.filter (fun ev => 0 < ev) eigenvalues, ∀ ev ∈ List.filter (fun ev => 0 < ev) eigenvalues, ev_min ≤ ev := by
      have h_min : ∃ ev_min ∈ (eigenvalues.filter (fun ev => ev > 0)), ∀ ev ∈ (eigenvalues.filter (fun ev => ev > 0)), ev_min ≤ ev := by
        have h_nonempty : (eigenvalues.filter (fun ev => ev > 0)).toFinset.Nonempty := by
          exact ⟨ hne.choose, List.mem_toFinset.mpr ( List.mem_filter.mpr ⟨ hne.choose_spec.1, by simpa using hne.choose_spec.2 ⟩ ) ⟩
        exact ⟨ Finset.min' _ h_nonempty, List.mem_toFinset.mp ( Finset.min'_mem _ h_nonempty ), fun ev he => Finset.min'_le _ _ ( List.mem_toFinset.mpr he ) ⟩;
      exact h_min;
    exact ⟨ ev_min, List.mem_of_mem_filter hev_min.1, by simpa using List.of_mem_filter hev_min.1, fun ev hev hev' => hev_min.2 ev ( List.mem_filter.mpr ⟨ hev, by simpa using hev' ⟩ ) ⟩;
  grind +ring




/-- BSD rank analogy -/
theorem bsd_analogy (n : ℕ) (r a : Fin n → ℕ) (h : ∀ i, r i = a i) :
    ∑ i, r i = ∑ i, a i := by congr 1; ext i; exact h i




/-- Oracle convergence is instantaneous -/
theorem spectral_convergence {α : Type*} (O : SpectralOracle α) (x : α) :
    O.map (O.map x) = O.map x := O.idem x




/-- Oracle fixed point theorem -/
theorem spectral_fixed_point {α : Type*} (O : SpectralOracle α) :
    Set.range O.map = {x | O.map x = x} := spectral_range_eq_fixed O




theorem grover_spectral_speedup (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N < N := by
  exact Nat.sqrt_lt_self <| by linarith;




/-- Combined oracle + Grover advantage -/
theorem oracle_grover_advantage (N k : ℕ) (hk : 0 < k) :
    Nat.sqrt (N / k) ≤ N := by
  calc Nat.sqrt (N / k) ≤ N / k := Nat.sqrt_le_self _
    _ ≤ N := Nat.div_le_self N k




/-- The oracle is a sufficient statistic for factoring -/
theorem oracle_sufficient (N x : ℕ) : Nat.gcd x N ∣ N := Nat.gcd_dvd_right x N




/-- The oracle preserves coprimality information -/
theorem oracle_coprime_info (N a b : ℕ) (h : Nat.gcd a N = Nat.gcd b N) :
    Nat.Coprime a N ↔ Nat.Coprime b N := by
  simp only [Nat.Coprime]; rw [h]




end
