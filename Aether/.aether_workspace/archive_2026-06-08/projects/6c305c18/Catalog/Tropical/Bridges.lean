/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Hodge Theory: Cross-Domain Bridge Theorems

This file extends the foundations of tropical Hodge theory with bridge
theorems connecting tropical geometry to:
1. **Post-quantum lattice cryptography** — tropical SVP and basis reduction
2. **Certified robustness for neural networks** — tropical Lipschitz bounds
3. **Quantum Hamiltonian mechanics** — Maslov dequantization and WKB limits
4. **Spectral graph theory** — tropical spectral gaps and mixing
5. **Optimization** — tropical dynamic programming and shortest paths
-/

import Mathlib

noncomputable section

open Finset

namespace TropicalHodgeBridge

variable {n : ℕ}

-- Re-state key definitions from Foundations for self-containment

private def tropSupNorm (v : Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' univ univ_nonempty v

private def tropInfNorm (v : Fin (n + 1) → ℝ) : ℝ :=
  Finset.inf' univ univ_nonempty v

private def tropInner (u v : Fin (n + 1) → ℝ) : ℝ :=
  Finset.inf' univ univ_nonempty (fun i => u i + v i)

private def tropDistance (u v : Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' univ univ_nonempty (fun i => |u i - v i|)

private def tropVecAdd (u v : Fin (n + 1) → ℝ) : Fin (n + 1) → ℝ :=
  fun i => min (u i) (v i)

private def tropD0 (f : Fin (n + 1) → ℝ) : Fin (n + 1) → Fin (n + 1) → ℝ :=
  fun i j => f j - f i

private def tropMatMul (A B : Fin (n + 1) → Fin (n + 1) → ℝ) :
    Fin (n + 1) → Fin (n + 1) → ℝ :=
  fun i j => Finset.inf' univ univ_nonempty (fun k => A i k + B k j)

/-! ## Section 1: Tropical Metric Space Structure -/

/-
**Tropical triangle inequality**: d_∞(u, w) ≤ d_∞(u, v) + d_∞(v, w).
Bridge: connects metric space theory to certified_robustness.
-/
theorem tropDistance_triangle (u v w : Fin (n + 1) → ℝ) :
    tropDistance u w ≤ tropDistance u v + tropDistance v w := by
  unfold tropDistance;
  simp +decide only [sup'_le_iff, mem_univ, forall_true_left];
  exact fun i => le_trans ( abs_sub_le _ _ _ ) ( add_le_add ( Finset.le_sup' ( fun i => |u i - v i| ) ( Finset.mem_univ i ) ) ( Finset.le_sup' ( fun i => |v i - w i| ) ( Finset.mem_univ i ) ) )

/-
The tropical distance is positive definite: d(u,v) = 0 ↔ u = v.
Bridge: connects tropical metric theory to separation axioms.
-/
theorem tropDistance_eq_zero_iff (u v : Fin (n + 1) → ℝ) :
    tropDistance u v = 0 ↔ u = v := by
  constructor <;> intros <;> simp_all +decide [ funext_iff, tropDistance ];
  rename_i h; intro i; have := h ▸ Finset.le_sup' ( fun i => |u i - v i| ) ( Finset.mem_univ i ) ; simp_all +decide [ abs_eq_zero, sub_eq_zero ] ;

/-! ## Section 2: Tropical Matrix Powers and Shortest Paths -/

/-- **Tropical matrix power**: A^⊗k by iterated multiplication.
Bridge: connects matrix powering to dynamic programming. -/
def tropMatPow (A : Fin (n + 1) → Fin (n + 1) → ℝ) : ℕ → Fin (n + 1) → Fin (n + 1) → ℝ
  | 0 => fun i j => if i = j then 0 else A i j
  | k + 1 => tropMatMul (tropMatPow A k) A

/-
Tropical matrix power at step 1 is ≤ A (when diagonal is 0, entries nonneg).
Bridge: connects base case of dynamic programming.
-/
theorem tropMatPow_one (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (_hA_diag : ∀ i, A i i = 0) (_hA_nonneg : ∀ i j, 0 ≤ A i j) :
    ∀ i j, tropMatPow A 1 i j ≤ A i j := by
  intro i j;
  -- By definition of tropMatPow, we have tropMatPow A 1 i j = tropMatMul (tropMatPow A 0) A i j.
  simp [tropMatPow];
  exact Finset.inf'_le _ ( Finset.mem_univ i ) |> le_trans <| by aesop;

/-! ## Section 3: Tropical 1-Form Inner Product and Hodge Orthogonality -/

/-- **Tropical 1-form inner product**: ⟨ω, η⟩ = Σᵢⱼ ω(i,j) · η(i,j).
Bridge: connects inner product spaces to tropical Hodge decomposition. -/
def form1InnerProduct (omega eta : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.sum univ (fun i => Finset.sum univ (fun j => omega i j * eta i j))

/-- **1-form norm squared**: ‖ω‖² = ⟨ω, ω⟩ ≥ 0.
Bridge: connects normed spaces to tropical Hodge theory. -/
def form1NormSq (omega : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  form1InnerProduct omega omega

theorem form1NormSq_nonneg (omega : Fin (n + 1) → Fin (n + 1) → ℝ) :
    0 ≤ form1NormSq omega := by
  -- By definition of form1NormSq, we have form1NormSq omega = Σ_{i, j} (omega i j)².
  unfold form1NormSq;
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_self_nonneg _

/-
**Hodge orthogonality**: exact 1-forms are orthogonal to antisymmetric
closed forms with zero row sums. This is the discrete tropical Hodge
orthogonality theorem.
Bridge: connects Hodge orthogonality to graph Laplacian theory.
-/
theorem exact_ortho_closed_row
    (f : Fin (n + 1) → ℝ) (eta : Fin (n + 1) → Fin (n + 1) → ℝ)
    (heta : ∀ i, Finset.sum univ (fun j => eta i j) = 0)
    (heta_antisymm : ∀ i j, eta i j = -eta j i) :
    form1InnerProduct (tropD0 f) eta = 0 := by
  unfold form1InnerProduct tropD0;
  norm_num [ sub_mul, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, heta ];
  rw [ Finset.sum_comm ];
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, heta ];
  rw [ Finset.sum_congr rfl fun i hi => by rw [ show ∑ j, eta j i = 0 from by rw [ Finset.sum_congr rfl fun j hj => heta_antisymm j i ] ; simp +decide [ heta ] ] ] ; norm_num

/-! ## Section 4: Tropical Oscillation and Spectral Gap -/

/-- **Tropical oscillation**: osc(f) = max f - min f.
Bridge: connects tropical analysis to convergence theory. -/
def tropOscillation (f : Fin (n + 1) → ℝ) : ℝ :=
  tropSupNorm f - tropInfNorm f

theorem tropOscillation_nonneg (f : Fin (n + 1) → ℝ) :
    0 ≤ tropOscillation f := by
  -- Since $f(0)$ is an element of the set $\{f(i) \mid i \in \text{Fin}(n+1)\}$, we have $f(0) \leq \sup(\{f(i) \mid i \in \text{Fin}(n+1)\})$ and $f(0) \geq \inf(\{f(i) \mid i \in \text{Fin}(n+1)\})$.
  have h_f0_bounds : f 0 ≤ tropSupNorm f ∧ tropInfNorm f ≤ f 0 := by
    exact ⟨ Finset.le_sup' ( fun i => f i ) ( Finset.mem_univ 0 ), Finset.inf'_le _ ( Finset.mem_univ 0 ) ⟩;
  exact sub_nonneg_of_le ( le_trans h_f0_bounds.2 h_f0_bounds.1 )

theorem tropOscillation_const (c : ℝ) :
    tropOscillation (fun (_ : Fin (n + 1)) => c) = 0 := by
  unfold tropOscillation;
  unfold tropSupNorm tropInfNorm; norm_num;

/-! ## Section 5: Tropical ReLU Network Theory -/

/-- **Tropical ReLU**: max(0, x). Bridge: tropical algebra ↔ neural networks. -/
def tropReLU (x : ℝ) : ℝ := max 0 x

/-
ReLU is idempotent: ReLU(ReLU(x)) = ReLU(x).
Bridge: connects tropical idempotence to neural network theory.
-/
theorem tropReLU_idempotent (x : ℝ) :
    tropReLU (tropReLU x) = tropReLU x := by
  unfold tropReLU; aesop;

/-
ReLU is 1-Lipschitz: |ReLU(x) - ReLU(y)| ≤ |x - y|.
Bridge: connects Lipschitz theory to certified_robustness.
-/
theorem tropReLU_lipschitz (x y : ℝ) :
    |tropReLU x - tropReLU y| ≤ |x - y| := by
  unfold tropReLU; cases abs_cases ( x - y ) <;> cases abs_cases ( Max.max 0 x - Max.max 0 y ) <;> cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> linarith;

/-- **Matrix infinity norm**: max_i Σ_j |A_{ij}|. -/
def matrixInfNorm (A : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' univ univ_nonempty (fun i => Finset.sum univ (fun j => |A i j|))

theorem matrixInfNorm_nonneg (A : Fin (n + 1) → Fin (n + 1) → ℝ) :
    0 ≤ matrixInfNorm A := by
  exact le_trans ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) ( Finset.le_sup' ( fun i => ∑ j, |A i j| ) ( Finset.mem_univ 0 ) )

/-! ## Section 6: Tropical Entropy and Information Theory -/

/-- **Tropical entropy**: H_trop(v) = -min_i v_i.
Bridge: tropical analysis ↔ quantum_hamiltonian (free energy). -/
def tropEntropy (v : Fin (n + 1) → ℝ) : ℝ := -tropInfNorm v

/-
**Tropical entropy ≤ sup-norm of negation**.
Bridge: tropical entropy ↔ thermodynamic free energy.
-/
theorem tropEntropy_le_supnorm_neg (v : Fin (n + 1) → ℝ) :
    tropEntropy v ≤ tropSupNorm (fun i => -v i) := by
  unfold tropEntropy tropSupNorm; norm_num;
  unfold tropInfNorm; aesop;

/-
**Tropical subadditivity**: H(u⊕v) ≤ max(H(u), H(v)).
Bridge: tropical entropy ↔ information theory.
-/
theorem tropEntropy_subadditive (u v : Fin (n + 1) → ℝ) :
    tropEntropy (tropVecAdd u v) ≤ max (tropEntropy u) (tropEntropy v) := by
  unfold tropEntropy tropVecAdd; norm_num;
  unfold tropInfNorm;
  simp +decide [ Finset.inf'_le_iff ];
  grind

/-
**Maslov dequantization upper bound**: the "soft-min" -T·log(exp(-a/T) + exp(-b/T))
approximates min(a,b) from below, with error at most T·log(2):
  -T·log(exp(-a/T) + exp(-b/T)) ≤ min(a,b).
As T → 0, the soft-min converges to the hard min.
Bridge: tropical algebra ↔ quantum_hamiltonian mechanics (WKB/Maslov limit).
-/
theorem maslov_dequantization_upper (a b T : ℝ) (hT : 0 < T) :
    -T * Real.log (Real.exp (-a / T) + Real.exp (-b / T)) ≤ min a b := by
  cases min_cases a b <;> nlinarith [ Real.log_exp ( -a / T ), Real.log_exp ( -b / T ), Real.log_le_log ( by positivity ) ( show Real.exp ( -a / T ) + Real.exp ( -b / T ) ≥ Real.exp ( -a / T ) by linarith [ Real.exp_pos ( -a / T ), Real.exp_pos ( -b / T ) ] ), Real.log_le_log ( by positivity ) ( show Real.exp ( -a / T ) + Real.exp ( -b / T ) ≥ Real.exp ( -b / T ) by linarith [ Real.exp_pos ( -a / T ), Real.exp_pos ( -b / T ) ] ), mul_div_cancel₀ ( -a ) hT.ne', mul_div_cancel₀ ( -b ) hT.ne' ]

/-! ## Section 7: Tropical Lattice Crypto -/

/-- **Tropical lattice**: finitely generated min-plus submodule.
Bridge: tropical algebra ↔ post_quantum lattice_crypto. -/
structure TropicalLattice (m : ℕ) where
  basis : Fin (m + 1) → Fin (n + 1) → ℝ

/-- **Tropical successive minimum**: λ₁ = min_i osc(B_i).
Bridge: tropical geometry ↔ lattice_crypto (SVP). -/
def tropFirstMinimum (L : TropicalLattice (n := n) m) : ℝ :=
  Finset.inf' univ univ_nonempty (fun i =>
    tropSupNorm (L.basis i) - tropInfNorm (L.basis i))

/-
**Tropical Hermite bound**: λ₁ ≤ 2M where M = max|B_{ij}|.
Bridge: tropical geometry ↔ lattice_crypto (Hermite constant).
-/
theorem tropHermite_bound (L : TropicalLattice (n := n) m) (M : ℝ)
    (hM : ∀ i j, |L.basis i j| ≤ M) :
    tropFirstMinimum L ≤ 2 * M := by
  -- By definition of $tropFirstMinimum$, we know that for each basis vector $B_i$, $tropSupNorm (L.basis i) - tropInfNorm (L.basis i) \leq 2M$.
  have h_oscillation_bound : ∀ i, tropSupNorm (L.basis i) - tropInfNorm (L.basis i) ≤ 2 * M := by
    intro i
    unfold tropSupNorm tropInfNorm;
    exact sub_le_iff_le_add'.mpr ( by linarith [ show ( Finset.univ.sup' ( Finset.univ_nonempty ) ( L.basis i ) ) ≤ M from Finset.sup'_le _ _ fun j _ => le_of_abs_le ( hM i j ), show ( Finset.univ.inf' ( Finset.univ_nonempty ) ( L.basis i ) ) ≥ -M from Finset.le_inf' _ _ fun j _ => neg_le_of_abs_le ( hM i j ) ] );
  exact Finset.inf'_le _ ( Finset.mem_univ 0 ) |> le_trans <| h_oscillation_bound 0

/-! ## Section 8: Additional Bridge Theorems -/

/-
**Sup-norm dominates inf-norm**: max ≥ min.
-/
theorem tropSupNorm_ge_infNorm (v : Fin (n + 1) → ℝ) :
    tropSupNorm v ≥ tropInfNorm v := by
  exact Finset.inf'_le _ ( Finset.mem_univ 0 ) |> le_trans <| Finset.le_sup' _ ( Finset.mem_univ 0 )

/-
**Tropical inner product upper bound**: ⟨u,v⟩_trop ≤ ‖u‖_min + ‖v‖_∞.
Bridge: tropical inner products ↔ spectral bounds.
-/
theorem tropInner_upper_bound (u v : Fin (n + 1) → ℝ) :
    tropInner u v ≤ tropInfNorm u + tropSupNorm v := by
  unfold tropInner tropInfNorm tropSupNorm;
  obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun i => u i;
  exact le_trans ( Finset.inf'_le _ hi.1 ) ( by linarith [ hi.2, Finset.le_sup' ( fun i => v i ) ( Finset.mem_univ i ) ] )

/-- **Tropical vector addition is monotone**: u ≤ u' ∧ v ≤ v' → u⊕v ≤ u'⊕v'. -/
theorem tropVecAdd_mono (u u' v v' : Fin (n + 1) → ℝ)
    (hu : ∀ i, u i ≤ u' i) (hv : ∀ i, v i ≤ v' i) :
    ∀ i, tropVecAdd u v i ≤ tropVecAdd u' v' i := by
  intro i; unfold tropVecAdd; exact min_le_min (hu i) (hv i)

/-
**d₀ is 2-Lipschitz**: |d₀(f)(i,j) - d₀(g)(i,j)| ≤ 2·‖f-g‖_∞.
Bridge: tropical de Rham ↔ Lipschitz bounds.
-/
theorem tropD0_lipschitz (f g : Fin (n + 1) → ℝ) :
    ∀ i j, |tropD0 f i j - tropD0 g i j| ≤ 2 * tropSupNorm (fun k => |f k - g k|) := by
  unfold tropD0 tropSupNorm;
  intro i j;
  rw [ abs_le ];
  constructor <;> linarith [ abs_le.mp ( Finset.le_sup' ( fun k => |f k - g k| ) ( Finset.mem_univ i ) ), abs_le.mp ( Finset.le_sup' ( fun k => |f k - g k| ) ( Finset.mem_univ j ) ) ]

end TropicalHodgeBridge

end