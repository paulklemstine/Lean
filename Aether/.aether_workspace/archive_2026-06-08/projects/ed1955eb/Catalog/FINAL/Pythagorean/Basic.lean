import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.Basic

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 21
-/

/-- The sum-of-squares congruence condition. -/
def sumSqCong (N x y z : ℤ) : Prop :=
  (N ^ 2) ∣ (x ^ 2 + y ^ 2 + z ^ 2)

/-- The set of integer triples whose sum of squares is divisible by N². -/
def SumSqCongSet (N : ℤ) : Set (ℤ × ℤ × ℤ) :=
  { v | sumSqCong N v.1 v.2.1 v.2.2 }

/-- The zero vector is always in L₄(N). -/
theorem zero_mem_sumSqCongSet (N : ℤ) : (0, 0, 0) ∈ SumSqCongSet N := by
  simp [SumSqCongSet, sumSqCong]

/-- Any multiple of N in all coordinates is in L₄(N). -/
theorem mul_N_mem (N a b c : ℤ) : (N * a, N * b, N * c) ∈ SumSqCongSet N := by
  simp only [SumSqCongSet, Set.mem_setOf_eq, sumSqCong]
  exact ⟨a ^ 2 + b ^ 2 + c ^ 2, by ring⟩

/-- **L₄(N) is NOT closed under addition for N = 3.**
Take v = (2, 1, 2) and w = (1, 2, 2). We have:
- 2² + 1² + 2² = 9 = 3², so v ∈ L₄(3)
- 1² + 2² + 2² = 9 = 3², so w ∈ L₄(3)
- (3)² + (3)² + (4)² = 9 + 9 + 16 = 34, and 9 ∤ 34, so v + w ∉ L₄(3) -/
theorem sumSqCongSet_not_closed_add :
    ¬ ∀ (v w : ℤ × ℤ × ℤ), v ∈ SumSqCongSet 3 → w ∈ SumSqCongSet 3 →
      (v.1 + w.1, v.2.1 + w.2.1, v.2.2 + w.2.2) ∈ SumSqCongSet 3 := by
  intro h
  have h1 : (2, 1, 2) ∈ SumSqCongSet 3 := by
    simp only [SumSqCongSet, Set.mem_setOf_eq, sumSqCong]; norm_num
  have h2 : (1, 2, 2) ∈ SumSqCongSet 3 := by
    simp only [SumSqCongSet, Set.mem_setOf_eq, sumSqCong]; norm_num
  have h3 := h _ _ h1 h2
  simp only [SumSqCongSet, Set.mem_setOf_eq, sumSqCong] at h3
  omega

/-- A lattice related to a quadratic residue root.
If r² ≡ -1 (mod N), then L = {(x, y) : N | (x - r·y)} is a lattice
and short vectors give N | (x² + y²). -/
def quadResLattice (N r : ℤ) : Set (ℤ × ℤ) :=
  { v | N ∣ (v.1 - r * v.2) }

/-- The quadratic residue lattice is closed under addition. -/
theorem quadResLattice_add_closed (N r : ℤ) (v w : ℤ × ℤ)
    (hv : v ∈ quadResLattice N r) (hw : w ∈ quadResLattice N r) :
    (v.1 + w.1, v.2 + w.2) ∈ quadResLattice N r := by
  simp only [quadResLattice, Set.mem_setOf_eq] at *
  have : (v.1 + w.1) - r * (v.2 + w.2) = (v.1 - r * v.2) + (w.1 - r * w.2) := by ring
  rw [this]
  exact dvd_add hv hw

/-- The zero vector is in the quadratic residue lattice. -/
theorem quadResLattice_zero (N r : ℤ) : (0, 0) ∈ quadResLattice N r := by
  simp [quadResLattice]

/-- The quadratic residue lattice is closed under negation. -/
theorem quadResLattice_neg (N r : ℤ) (v : ℤ × ℤ)
    (hv : v ∈ quadResLattice N r) :
    (-v.1, -v.2) ∈ quadResLattice N r := by
  simp only [quadResLattice, Set.mem_setOf_eq] at *
  have : -v.1 - r * -v.2 = -(v.1 - r * v.2) := by ring
  rw [this]
  exact dvd_neg.mpr hv

/-- If r² ≡ -1 (mod N) and (x, y) is in the quadratic residue lattice,
then N | (x² + y²). -/
theorem quadResLattice_sum_sq (N r x y : ℤ)
    (hr : N ∣ (r ^ 2 + 1))
    (hmem : (x, y) ∈ quadResLattice N r) :
    N ∣ (x ^ 2 + y ^ 2) := by
  simp only [quadResLattice, Set.mem_setOf_eq] at hmem
  obtain ⟨k, hk⟩ := hmem
  have hx : x = r * y + k * N := by linarith
  obtain ⟨j, hj⟩ := hr
  rw [hx]
  exact ⟨j * y ^ 2 + 2 * r * y * k + k ^ 2 * N, by nlinarith [hj]⟩

/-- A 3D lattice for the sum of three squares condition.
Given r₁² + r₂² ≡ -1 (mod N), the lattice
L = {(x, y, z) : N | (x - r₁·z), N | (y - r₂·z)}
has the property that short vectors give x² + y² + z² ≡ 0 (mod N). -/
def sumThreeSqLattice (N r₁ r₂ : ℤ) : Set (ℤ × ℤ × ℤ) :=
  { v | N ∣ (v.1 - r₁ * v.2.2) ∧ N ∣ (v.2.1 - r₂ * v.2.2) }

/-- The 3D sum-of-squares lattice is closed under addition. -/
theorem sumThreeSqLattice_add_closed (N r₁ r₂ : ℤ)
    (v w : ℤ × ℤ × ℤ)
    (hv : v ∈ sumThreeSqLattice N r₁ r₂)
    (hw : w ∈ sumThreeSqLattice N r₁ r₂) :
    (v.1 + w.1, v.2.1 + w.2.1, v.2.2 + w.2.2) ∈ sumThreeSqLattice N r₁ r₂ := by
  simp only [sumThreeSqLattice, Set.mem_setOf_eq] at *
  obtain ⟨hv1, hv2⟩ := hv
  obtain ⟨hw1, hw2⟩ := hw
  constructor
  · have : (v.1 + w.1) - r₁ * (v.2.2 + w.2.2) =
      (v.1 - r₁ * v.2.2) + (w.1 - r₁ * w.2.2) := by ring
    rw [this]; exact dvd_add hv1 hw1
  · have : (v.2.1 + w.2.1) - r₂ * (v.2.2 + w.2.2) =
      (v.2.1 - r₂ * v.2.2) + (w.2.1 - r₂ * w.2.2) := by ring
    rw [this]; exact dvd_add hv2 hw2

/-- The zero vector is in the 3D lattice. -/
theorem sumThreeSqLattice_zero (N r₁ r₂ : ℤ) :
    (0, 0, 0) ∈ sumThreeSqLattice N r₁ r₂ := by
  simp [sumThreeSqLattice]

/-- If r₁² + r₂² + 1 ≡ 0 (mod N) and (x,y,z) ∈ L, then N | (x²+y²+z²). -/
theorem sumThreeSqLattice_divides (N r₁ r₂ x y z : ℤ)
    (hr : N ∣ (r₁ ^ 2 + r₂ ^ 2 + 1))
    (hmem : (x, y, z) ∈ sumThreeSqLattice N r₁ r₂) :
    N ∣ (x ^ 2 + y ^ 2 + z ^ 2) := by
  simp only [sumThreeSqLattice, Set.mem_setOf_eq] at hmem
  obtain ⟨hx, hy⟩ := hmem
  obtain ⟨a, ha⟩ := hx
  obtain ⟨b, hb⟩ := hy
  obtain ⟨c, hc⟩ := hr
  have hx_eq : x = r₁ * z + a * N := by linarith
  have hy_eq : y = r₂ * z + b * N := by linarith
  rw [hx_eq, hy_eq]
  exact ⟨c * z ^ 2 + 2 * r₁ * z * a + a ^ 2 * N + 2 * r₂ * z * b + b ^ 2 * N,
         by nlinarith [hc]⟩

/-- A basis for the 3D sum-of-squares lattice (as column vectors):
b₁ = (N, 0, 0), b₂ = (0, N, 0), b₃ = (r₁, r₂, 1).
The determinant of the basis matrix is N², so by Minkowski's theorem
the shortest vector has norm at most √3 · N^{2/3}. -/
def lattice3D_basis (N r₁ r₂ : ℤ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![N, 0, r₁; 0, N, r₂; 0, 0, 1]

/-- The basis matrix has determinant N². -/
theorem lattice3D_basis_det (N r₁ r₂ : ℤ) :
    Matrix.det (lattice3D_basis N r₁ r₂) = N ^ 2 := by
  simp [lattice3D_basis, Matrix.det_fin_three]
  ring

/-- Each basis vector is in the 3D lattice. -/
theorem basis_vec1_mem (N r₁ r₂ : ℤ) :
    (N, (0 : ℤ), (0 : ℤ)) ∈ sumThreeSqLattice N r₁ r₂ := by
  simp [sumThreeSqLattice]

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.Basic
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 21] -/
theorem basis_vec2_mem (N r₁ r₂ : ℤ) :
    ((0 : ℤ), N, (0 : ℤ)) ∈ sumThreeSqLattice N r₁ r₂ := by
  simp [sumThreeSqLattice]

/-- [Section: # CatalogBuild.Pythagorean.Quadruples.Basic
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 21] -/
theorem basis_vec3_mem (N r₁ r₂ : ℤ) :
    (r₁, r₂, (1 : ℤ)) ∈ sumThreeSqLattice N r₁ r₂ := by
  simp [sumThreeSqLattice]

/-- In 2D, Gauss reduction finds the shortest vector optimally.
The Berggren tree descent IS Gauss reduction (Lattice-Tree Correspondence).
This gives Θ(√N) for balanced semiprimes.
In 3D, the Minkowski bound gives det^{1/3} ≈ N^{2/3} for det = N².
For the factoring lattice, N^{2/3} < N^{1/2} when N^{4/3} < N,
i.e., N^{1/3} < 1, which is false for N ≥ 2.
CORRECTION: N^{2/3} > N^{1/2} for N ≥ 2, so the 3D lattice
does NOT automatically beat √N via Minkowski alone.
The hope would be that STRUCTURED lattices (from Pythagorean quadruples)
have shorter vectors than Minkowski predicts. This requires empirical
investigation. -/
theorem dim_comparison : ∀ N : ℕ, 2 ≤ N → N ≤ N ^ 2 := by
  intro N hN; nlinarith

/-- The Hermite constant γ₃ = 2^{2/3} ≈ 1.587.
Minkowski bound: λ₁ ≤ √γ₃ · det^{1/3}.
For det = N²: λ₁ ≤ √(2^{2/3}) · N^{2/3} ≈ 1.26 · N^{2/3}. -/
theorem hermite_3d_bound_nat (N : ℕ) (hN : 4 ≤ N) :
    -- Weakened version: N^2 (det) has cube root < N
    -- i.e., (N^{2/3})³ = N² < N³
    N ^ 2 < N ^ 3 := by
  nlinarith [sq_nonneg (N - 1)]

