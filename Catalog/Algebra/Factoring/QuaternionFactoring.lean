import Mathlib

/-! # CatalogBuild.Computation.Factoring.QuaternionFactoring

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11
-/

/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionFactoring
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem norm_nonneg (q : IntQuaternion) : 0 ≤ q.norm := by
  exact add_nonneg ( add_nonneg ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ( sq_nonneg _ ) ) ( sq_nonneg _ )

/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionFactoring
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem mul_conj (q : IntQuaternion) :
    mul q (conj q) = ⟨q.norm, 0, 0, 0⟩ := by
  unfold IntQuaternion.norm;
  unfold IntQuaternion.mul;
  unfold IntQuaternion.conj; ring;

theorem gcd_extraction_nontrivial (N : ℕ) (hN : 1 < N)
    (x y z : ℤ) (k : ℤ) (hk : 0 < k) (hk2 : k < N)
    (hsum : x^2 + y^2 + z^2 = k * N) :
    ∃ d : ℕ, d = Nat.gcd (Int.natAbs (x^2 + y^2 + z^2)) N ∧ d ∣ N := by
  exact ⟨ _, rfl, Nat.gcd_dvd_right _ _ ⟩

/-- The lattice L₄(N) consists of all integer triples (x, y, z) such that
x² + y² + z² ≡ 0 (mod N). A short vector in this lattice can reveal
factors of N. -/
def inQuadLattice (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)

/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionFactoring
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem zero_in_quadLattice (N : ℤ) : inQuadLattice N 0 0 0 := by
  exact ⟨ 0, by simp +decide ⟩

theorem neg_in_quadLattice (N : ℤ) (x y z : ℤ) (h : inQuadLattice N x y z) :
    inQuadLattice N (-x) (-y) (-z) := by
  simp_all +decide [ inQuadLattice ]

/-- Membership in L₃(N): the sum-of-squares constraint mod N. -/
def mem_lattice3 (N : ℤ) (x y z : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2)

/-- L₃(N) contains the zero vector. -/
theorem lattice3_zero_mem (N : ℤ) : mem_lattice3 N 0 0 0 := by
  simp [mem_lattice3]

/-- L₃(N) is closed under negation. -/
theorem lattice3_neg_mem (N : ℤ) (x y z : ℤ) (h : mem_lattice3 N x y z) :
    mem_lattice3 N (-x) (-y) (-z) := by
  simp only [mem_lattice3, neg_sq]
  exact h

/-- Membership in L₄(N). -/
def mem_lattice4 (N : ℤ) (x y z w : ℤ) : Prop :=
  N ∣ (x^2 + y^2 + z^2 + w^2)
