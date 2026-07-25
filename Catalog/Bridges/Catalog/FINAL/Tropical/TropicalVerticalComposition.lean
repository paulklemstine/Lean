import Mathlib

/-!
# Tropical Vertical Composition as Max-Plus Spectral Amplification

This file establishes a formal theory connecting vertical composition (iterated
application) of tropical affine operators on `Fin n → ℝ` to the max-plus
spectral data of the associated weight matrix.

## Core idea

In max-plus (tropical) algebra, matrix–vector multiplication replaces the usual
`∑ A_ij * x_j` with `max_j (A_ij + x_j)`. Repeated application of such an
operator models depth in tropicalized neural networks. We prove that the
asymptotic growth of this iterated composition is controlled by the maximum
entry of the weight matrix — the tropical spectral bound — yielding a linear
depth-growth certificate.

## Main definitions

* `tropMatVec`          — tropical matrix–vector product `(A ⊗ x)_i = max_j (A_ij + x_j)`
* `verticalIterate`     — k-fold iteration of `tropMatVec A`
* `supNorm`             — sup-norm on `Fin (n+1) → ℝ`, i.e. `max_i (x_i)`
* `matMaxEntry`         — maximum matrix entry `max_{i,j} A_ij` (tropical spectral bound)
* `mat22`               — concrete 2×2 matrix from four scalars

## Main results

* `vertical_composition_one_step_bound` — one layer increases sup-norm by at most `matMaxEntry A`
* `vertical_composition_iterate_bound`  — k layers increase sup-norm by at most `k * matMaxEntry A`
* `vertical_composition_2x2_spectral_control` — concrete 2×2 one-step bound
* `vertical_composition_2x2_iterate_control`  — concrete 2×2 k-step bound
* `vertical_composition_zero_bound`     — depth certificate for zero input
* `tropical_eigenvector_iterate_exact`  — eigenvector iteration is exact: `A^k v = k*λ + v`

## Cross-domain significance

- **Deep learning**: depth stability certificates for tropicalized/ReLU-like architectures
- **Control theory**: finite-horizon cost-growth bounds for max-plus linear systems
- **Category theory**: quantitative semantics for vertical composition growth
- **Dynamical systems**: tropical Lyapunov exponent estimates
-/

noncomputable section

open Finset

/-! ## Core definitions -/

/-- Tropical matrix–vector product: `(A ⊗ x)_i = max_j (A_ij + x_j)`.
This is the fundamental operation of max-plus linear algebra applied to vectors. -/
def tropMatVec {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) (x : Fin (n+1) → ℝ) :
    Fin (n+1) → ℝ :=
  fun i => Finset.sup' Finset.univ ⟨0, mem_univ 0⟩ (fun j => A i j + x j)

/-- Vertical iterate: k-fold composition of the tropical matrix–vector operator.
Models depth-k tropical neural network computation. -/
def verticalIterate {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) :
    ℕ → (Fin (n+1) → ℝ) → (Fin (n+1) → ℝ)
  | 0 => id
  | k+1 => tropMatVec A ∘ verticalIterate A k

/-- Sup-norm on `Fin (n+1) → ℝ`: the maximum component value.
Acts as the tropical Lyapunov function / global activation scale. -/
def supNorm {n : ℕ} (x : Fin (n+1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, mem_univ 0⟩ x

/-- Maximum entry of a matrix: `max_{i,j} A_ij`.
This is the tropical spectral bound — the maximum "amplification" any single
entry can contribute in one tropical matrix–vector multiplication step. -/
def matMaxEntry {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, mem_univ 0⟩
    (fun i => Finset.sup' Finset.univ ⟨0, mem_univ 0⟩ (fun j => A i j))

/-- Concrete 2×2 matrix from four scalars. -/
def mat22 (a b c d : ℝ) : Fin 2 → Fin 2 → ℝ
  | ⟨0, _⟩, ⟨0, _⟩ => a
  | ⟨0, _⟩, ⟨1, _⟩ => b
  | ⟨1, _⟩, ⟨0, _⟩ => c
  | ⟨1, _⟩, ⟨1, _⟩ => d
  | ⟨n+2, h⟩, _ => absurd h (by omega)

/-! ## Helper lemmas -/

/-- Each component of x is bounded by supNorm x. -/
theorem le_supNorm {n : ℕ} (x : Fin (n+1) → ℝ) (i : Fin (n+1)) :
    x i ≤ supNorm x :=
  Finset.le_sup' x (mem_univ i)

/-- Each matrix entry is bounded by matMaxEntry A. -/
theorem le_matMaxEntry {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (i j : Fin (n+1)) : A i j ≤ matMaxEntry A := by
  unfold matMaxEntry
  exact le_trans (Finset.le_sup' (fun j => A i j) (mem_univ j))
    (Finset.le_sup' (fun i => Finset.sup' Finset.univ ⟨0, mem_univ 0⟩ (fun j => A i j)) (mem_univ i))

/-- The tropical matrix–vector product at index i is at least A i j + x j for any j. -/
theorem tropMatVec_le_of {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (x : Fin (n+1) → ℝ) (i j : Fin (n+1)) :
    A i j + x j ≤ tropMatVec A x i :=
  Finset.le_sup' (fun j => A i j + x j) (mem_univ j)

/-- verticalIterate 0 is the identity. -/
@[simp]
theorem verticalIterate_zero {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (x : Fin (n+1) → ℝ) : verticalIterate A 0 x = x := rfl

/-- verticalIterate (k+1) unfolds as tropMatVec A applied to verticalIterate A k. -/
@[simp]
theorem verticalIterate_succ {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (k : ℕ) (x : Fin (n+1) → ℝ) :
    verticalIterate A (k+1) x = tropMatVec A (verticalIterate A k x) := rfl

/-! ## Main Theorem A: One-step spectral growth bound -/

/-- **One-step spectral growth bound.**
One layer of tropical vertical composition cannot increase the global activation
scale (sup-norm) by more than the maximum matrix entry (tropical spectral bound).

This is the fundamental bridge: spectral theory becomes a depth-control theorem. -/
theorem vertical_composition_one_step_bound
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) (x : Fin (n+1) → ℝ) :
    supNorm (tropMatVec A x) ≤ matMaxEntry A + supNorm x := by
  unfold supNorm tropMatVec
  apply Finset.sup'_le _ _ (fun i _ => ?_)
  apply Finset.sup'_le _ _ (fun j _ => ?_)
  exact add_le_add (le_matMaxEntry A i j) (le_supNorm x j)

/-! ## Main Theorem B: k-step vertical composition bound -/

/-- **k-step vertical composition bound.**
Depth k contributes at most linearly to the global activation scale, with slope
equal to the tropical spectral bound. This is the tropical analogue of a Lyapunov
exponent estimate for compositional architectures.

Formally: `supNorm(A^k ⊗ x) ≤ k * matMaxEntry(A) + supNorm(x)`. -/
theorem vertical_composition_iterate_bound
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) (x : Fin (n+1) → ℝ) :
    ∀ k : ℕ, supNorm (verticalIterate A k x) ≤
      (k : ℝ) * matMaxEntry A + supNorm x := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    simp only [verticalIterate_succ]
    calc supNorm (tropMatVec A (verticalIterate A k x))
        ≤ matMaxEntry A + supNorm (verticalIterate A k x) :=
          vertical_composition_one_step_bound A _
      _ ≤ matMaxEntry A + ((k : ℝ) * matMaxEntry A + supNorm x) :=
          by linarith
      _ = ((k + 1 : ℕ) : ℝ) * matMaxEntry A + supNorm x := by push_cast; ring

/-! ## Main Theorem C: 2×2 exact spectral control -/

/-- **2×2 one-step spectral control.**
For a concrete 2×2 tropical matrix, one step of vertical composition is bounded
by the maximum entry plus the input sup-norm. -/
theorem vertical_composition_2x2_spectral_control
    (a b c d : ℝ) (x : Fin 2 → ℝ) :
    supNorm (tropMatVec (mat22 a b c d) x) ≤
      matMaxEntry (mat22 a b c d) + supNorm x :=
  vertical_composition_one_step_bound (mat22 a b c d) x

/-- **2×2 k-step spectral control.**
For a concrete 2×2 tropical matrix, k steps of vertical composition grow at most
linearly with slope equal to the maximum matrix entry. -/
theorem vertical_composition_2x2_iterate_control
    (a b c d : ℝ) (x : Fin 2 → ℝ) :
    ∀ k : ℕ, supNorm (verticalIterate (mat22 a b c d) k x) ≤
      (k : ℝ) * matMaxEntry (mat22 a b c d) + supNorm x :=
  vertical_composition_iterate_bound (mat22 a b c d) x

/-! ## Corollary 1: Constant-input (zero) growth control -/

/-- **Zero-input depth certificate.**
Starting from zero input, the growth after k layers is bounded by
`k * matMaxEntry(A)`. This is the cleanest depth stability certificate. -/
theorem vertical_composition_zero_bound
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) :
    ∀ k : ℕ, supNorm (verticalIterate A k (fun _ => 0)) ≤
      (k : ℝ) * matMaxEntry A := by
  intro k
  have h := vertical_composition_iterate_bound A (fun _ => 0) k
  have h0 : supNorm (fun (_ : Fin (n+1)) => (0 : ℝ)) = 0 := by
    simp [supNorm, Finset.sup'_const]
  linarith

/-! ## Corollary 2: Eigenvector exactness -/

/-
**Tropical eigenvector iteration exactness.**
If `v` is a tropical eigenvector with eigenvalue `lam` (meaning `A ⊗ v = lam + v`
pointwise), then k-fold iteration yields exactly `k*lam + v`. This shows the
iterate bound is asymptotically sharp on eigenvectors, connecting depth growth
to tropical Perron–Frobenius theory.
-/
theorem tropical_eigenvector_iterate_exact
    {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) (v : Fin (n+1) → ℝ) (lam : ℝ)
    (hEig : tropMatVec A v = fun i => lam + v i) :
    ∀ k : ℕ, verticalIterate A k v = fun i => (k : ℝ) * lam + v i := by
  intro k;
  induction' k with k ih;
  · aesop;
  · simp_all +decide [ verticalIterate, add_mul ];
    unfold tropMatVec at *;
    simp_all +decide [ funext_iff, add_left_comm, add_comm ] ;
    simp_all +decide [ ← add_assoc ];
    intro x; rw [ ← hEig x ] ;
    refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup'_iff ];
    · exact fun y => ⟨ y, le_rfl ⟩;
    · simpa using Finset.exists_max_image Finset.univ ( fun j => A x j + v j ) ⟨ x, Finset.mem_univ x ⟩

/-! ## Tropical operator monotonicity -/

/-
Tropical matrix–vector product is monotone in the vector argument:
if `x i ≤ y i` for all i, then `(A ⊗ x) i ≤ (A ⊗ y) i`.
-/
theorem tropMatVec_mono {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (x y : Fin (n+1) → ℝ) (h : ∀ i, x i ≤ y i) :
    ∀ i, tropMatVec A x i ≤ tropMatVec A y i := by
  exact fun i => Finset.sup'_le _ _ fun j _ => by linarith [ h j, tropMatVec_le_of A x i j, tropMatVec_le_of A y i j ] ;

/-
supNorm is monotone: if x ≤ y pointwise then supNorm x ≤ supNorm y.
-/
theorem supNorm_mono {n : ℕ} (x y : Fin (n+1) → ℝ) (h : ∀ i, x i ≤ y i) :
    supNorm x ≤ supNorm y := by
  exact Finset.sup'_le _ _ fun i _ => le_trans ( h i ) ( Finset.le_sup' _ ( Finset.mem_univ _ ) )

/-! ## Connection to tropicalEigenvalue2 -/

/-
The tropical eigenvalue `max(a+d, b+c)` of a 2×2 matrix is bounded by
twice the maximum entry. This connects the spectral bridge from
`SpectralIdempotentBridge` to our compositional growth theory.
-/
theorem tropicalEigenvalue2_le_twice_matMaxEntry (a b c d : ℝ) :
    max (a + d) (b + c) ≤ 2 * matMaxEntry (mat22 a b c d) := by
  nontriviality;
  refine' max_le _ _;
  · unfold matMaxEntry;
    norm_num [ Fin.univ_succ ];
    unfold mat22;
    grind;
  · unfold matMaxEntry;
    simp +decide [ Fin.univ_succ ];
    unfold mat22; norm_num; linarith [ le_max_left a b, le_max_right a b, le_max_left c d, le_max_right c d, le_max_left ( max a b ) ( max c d ), le_max_right ( max a b ) ( max c d ) ] ;

end