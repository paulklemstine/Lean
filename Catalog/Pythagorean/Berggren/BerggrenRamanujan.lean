import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenRamanujan

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 59
-/

noncomputable section

/-- A direction in the ternary Berggren tree. -/
inductive BDir where
  | left  : BDir   -- B₁ branch
  | mid   : BDir   -- B₂ branch
  | right : BDir   -- B₃ branch
  deriving DecidableEq, Repr, Inhabited

/-- A position in the Berggren tree is a finite word over {left, mid, right}. -/
abbrev BPos := List BDir

/-- Apply a single Berggren step. -/
def berggrenStep (d : BDir) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := t
  match d with
  | .left  => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid   => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The Pythagorean triple at a given position (path applied left-to-right from root). -/
def berggrenAt (path : BPos) : ℤ × ℤ × ℤ :=
  path.foldl (fun t d => berggrenStep d t) (3, 4, 5)

/-- Each Berggren step preserves the Pythagorean equation. -/
theorem berggrenStep_preserves_pyth (d : BDir) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let (a', b', c') := berggrenStep d (a, b, c)
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  cases d <;> simp [berggrenStep] <;> nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- Every position in the Berggren tree yields a Pythagorean triple. -/
theorem berggrenAt_pyth (path : BPos) :
    let (a, b, c) := berggrenAt path
    a ^ 2 + b ^ 2 = c ^ 2 := by
  simp only [berggrenAt]
  suffices h : ∀ (t : ℤ × ℤ × ℤ), t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    let r := path.foldl (fun t d => berggrenStep d t) t
    r.1 ^ 2 + r.2.1 ^ 2 = r.2.2 ^ 2 from
    h (3, 4, 5) (by norm_num)
  intro t ht
  induction path generalizing t with
  | nil => exact ht
  | cons d ds ih =>
    simp only [List.foldl]
    apply ih
    exact berggrenStep_preserves_pyth d t.1 t.2.1 t.2.2 ht

/-- Berggren matrix B₁. -/
def berggrenB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂. -/
def berggrenB₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃. -/
def berggrenB₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- B₁ has determinant 1 (it's in SL(3,ℤ)). -/
theorem det_berggrenB₁ : Matrix.det berggrenB₁ = 1 := by native_decide

/-- B₂ has determinant -1. -/
theorem det_berggrenB₂ : Matrix.det berggrenB₂ = -1 := by native_decide

/-- B₃ has determinant 1 (it's in SL(3,ℤ)). -/
theorem det_berggrenB₃ : Matrix.det berggrenB₃ = 1 := by native_decide

/-- All Berggren matrices are invertible over ℤ (|det| = 1). -/
theorem berggrenB₁_invertible : IsUnit (Matrix.det berggrenB₁) := by
  rw [det_berggrenB₁]; exact isUnit_one

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenRamanujan
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 59] -/
theorem berggrenB₂_invertible : IsUnit (Matrix.det berggrenB₂) := by
  rw [det_berggrenB₂]; exact isUnit_neg_one

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenRamanujan
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 59] -/
theorem berggrenB₃_invertible : IsUnit (Matrix.det berggrenB₃) := by
  rw [det_berggrenB₃]; exact isUnit_one

/-- The Lorentz form matrix: diag(1, 1, -1). -/
def berggren_Q : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- B₁ preserves the Lorentz form: B₁ᵀ Q B₁ = Q. -/
theorem berggrenB₁_lorentz : berggrenB₁ᵀ * berggren_Q * berggrenB₁ = berggren_Q := by
  native_decide

/-- B₂ preserves the Lorentz form. -/
theorem berggrenB₂_lorentz : berggrenB₂ᵀ * berggren_Q * berggrenB₂ = berggren_Q := by
  native_decide

/-- B₃ preserves the Lorentz form. -/
theorem berggrenB₃_lorentz : berggrenB₃ᵀ * berggren_Q * berggrenB₃ = berggren_Q := by
  native_decide

/-- Combined: all three Berggren matrices lie in the integer Lorentz group O(2,1;ℤ). -/
theorem berggren_in_lorentz :
    berggrenB₁ᵀ * berggren_Q * berggrenB₁ = berggren_Q ∧
    berggrenB₂ᵀ * berggren_Q * berggrenB₂ = berggren_Q ∧
    berggrenB₃ᵀ * berggren_Q * berggrenB₃ = berggren_Q :=
  ⟨berggrenB₁_lorentz, berggrenB₂_lorentz, berggrenB₃_lorentz⟩

/-- The generators are pairwise distinct. -/
theorem berggren_distinct :
    berggrenB₁ ≠ berggrenB₂ ∧ berggrenB₁ ≠ berggrenB₃ ∧ berggrenB₂ ≠ berggrenB₃ := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩

/-- No generator is the identity. -/
theorem berggren_ne_one :
    berggrenB₁ ≠ 1 ∧ berggrenB₂ ≠ 1 ∧ berggrenB₃ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩

/-- The generators are not involutions: B_i² ≠ I for any i.
This means the Berggren group is NOT a quotient of ℤ/2 * ℤ/2 * ℤ/2,
and the Cayley graph is 6-regular (not 3-regular). -/
theorem berggren_not_involutions :
    berggrenB₁ * berggrenB₁ ≠ 1 ∧
    berggrenB₂ * berggrenB₂ ≠ 1 ∧
    berggrenB₃ * berggrenB₃ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide⟩

/-- No product of two distinct generators is the identity. -/
theorem berggren_product2_ne_one :
    berggrenB₁ * berggrenB₂ ≠ 1 ∧ berggrenB₁ * berggrenB₃ ≠ 1 ∧
    berggrenB₂ * berggrenB₃ ≠ 1 ∧ berggrenB₂ * berggrenB₁ ≠ 1 ∧
    berggrenB₃ * berggrenB₁ ≠ 1 ∧ berggrenB₃ * berggrenB₂ ≠ 1 := by
  exact ⟨by native_decide, by native_decide, by native_decide,
         by native_decide, by native_decide, by native_decide⟩

/-- The Ramanujan bound for a d-regular graph: 2√(d-1). -/
noncomputable def ramanujanBound (d : ℕ) : ℝ := 2 * Real.sqrt (d - 1 : ℝ)

/-- For d = 3, the Ramanujan bound is 2√2. -/
theorem ramanujanBound_three : ramanujanBound 3 = 2 * Real.sqrt 2 := by
  simp [ramanujanBound]; norm_num

/-- For d = 4, the Ramanujan bound is 2√3. -/
theorem ramanujanBound_four : ramanujanBound 4 = 2 * Real.sqrt 3 := by
  simp [ramanujanBound]; norm_num

/-- The Ramanujan bound squared for d = 3 is 8. -/
theorem ramanujanBound_three_sq : (2 * Real.sqrt 2) ^ 2 = 8 := by
  rw [mul_pow, Real.sq_sqrt (by positivity : (2:ℝ) ≥ 0)]
  norm_num

/-- The Ramanujan bound squared for d = 4 is 12. -/
theorem ramanujanBound_four_sq : (2 * Real.sqrt 3) ^ 2 = 12 := by
  rw [mul_pow, Real.sq_sqrt (by positivity : (3:ℝ) ≥ 0)]
  norm_num

/-- The spectral gap of a 3-regular Ramanujan graph: d - λ₂ = 3 - 2√2. -/
noncomputable def spectralGap3 : ℝ := 3 - 2 * Real.sqrt 2

/-- The spectral gap of a 4-regular Ramanujan graph: 4 - 2√3. -/
noncomputable def spectralGap4 : ℝ := 4 - 2 * Real.sqrt 3

/-- The 3-regular spectral gap is positive: 3 - 2√2 > 0.
Proof: 2√2 = √8 < √9 = 3. -/
theorem spectralGap3_pos : spectralGap3 > 0 := by
  unfold spectralGap3
  have : Real.sqrt 2 < 3 / 2 := by
    nlinarith [Real.sq_sqrt (show (2:ℝ) ≥ 0 by norm_num), Real.sqrt_nonneg 2,
               sq_nonneg (Real.sqrt 2 - 3/2)]
  linarith

/-- The 4-regular spectral gap is positive: 4 - 2√3 > 0.
Proof: 2√3 = √12 < √16 = 4. -/
theorem spectralGap4_pos : spectralGap4 > 0 := by
  unfold spectralGap4
  have : Real.sqrt 3 < 2 := by
    nlinarith [Real.sq_sqrt (show (3:ℝ) ≥ 0 by norm_num), Real.sqrt_nonneg 3,
               sq_nonneg (Real.sqrt 3 - 2)]
  linarith

/-- The Berggren tree adjacency relation: two positions are adjacent
if one extends the other by exactly one step. -/
def berggrenAdj (p q : BPos) : Prop :=
  (∃ d : BDir, q = p ++ [d]) ∨ (∃ d : BDir, p = q ++ [d])

/-- Adjacency is symmetric. -/
theorem berggrenAdj_symm (p q : BPos) : berggrenAdj p q ↔ berggrenAdj q p := by
  simp [berggrenAdj, or_comm]

/-- Adjacency is irreflexive. -/
theorem berggrenAdj_irrefl (p : BPos) : ¬berggrenAdj p p := by
  simp only [berggrenAdj, not_or]
  constructor <;> intro ⟨d, h⟩ <;> have := congr_arg List.length h <;> simp at this

/-- The root has exactly 3 neighbors. -/
theorem root_neighbors :
    {q : BPos | berggrenAdj [] q} = {[BDir.left], [BDir.mid], [BDir.right]} := by
  ext q
  simp only [berggrenAdj, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff,
             List.nil_append]
  constructor
  · rintro (⟨d, rfl⟩ | ⟨d, h⟩)
    · cases d <;> simp
    · simp at h
  · rintro (rfl | rfl | rfl)
    · exact Or.inl ⟨BDir.left, rfl⟩
    · exact Or.inl ⟨BDir.mid, rfl⟩
    · exact Or.inl ⟨BDir.right, rfl⟩

/-- The hypotenuse component of the root triple is 5. -/
theorem root_hypotenuse : (berggrenAt []).2.2 = 5 := by rfl

/-- The hypotenuse of each child of the root.
(3,4,5) → B₁: (5,12,13), B₂: (21,20,29), B₃: (15,8,17). -/
theorem child_hypotenuses :
    (berggrenAt [BDir.left]).2.2 = 13 ∧
    (berggrenAt [BDir.mid]).2.2 = 29 ∧
    (berggrenAt [BDir.right]).2.2 = 17 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- All children have strictly larger hypotenuse than their parent (at the root). -/
theorem root_children_hyp_grow :
    (berggrenAt [BDir.left]).2.2 > (berggrenAt []).2.2 ∧
    (berggrenAt [BDir.mid]).2.2 > (berggrenAt []).2.2 ∧
    (berggrenAt [BDir.right]).2.2 > (berggrenAt []).2.2 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- The trace of B₁. -/
theorem trace_berggrenB₁ : Matrix.trace berggrenB₁ = 3 := by native_decide

/-- The trace of B₂. -/
theorem trace_berggrenB₂ : Matrix.trace berggrenB₂ = 5 := by native_decide

/-- The trace of B₃. -/
theorem trace_berggrenB₃ : Matrix.trace berggrenB₃ = 3 := by native_decide

/-- The trace of B₁B₂. -/
theorem trace_B₁B₂ : Matrix.trace (berggrenB₁ * berggrenB₂) = 17 := by native_decide

/-- The trace of B₁B₃. -/
theorem trace_B₁B₃ : Matrix.trace (berggrenB₁ * berggrenB₃) = 15 := by native_decide

/-- The trace of B₂B₃. -/
theorem trace_B₂B₃ : Matrix.trace (berggrenB₂ * berggrenB₃) = 17 := by native_decide

/-- Product determinants. -/
theorem det_B₁B₂ : Matrix.det (berggrenB₁ * berggrenB₂) = -1 := by native_decide

theorem det_B₁B₃ : Matrix.det (berggrenB₁ * berggrenB₃) = 1 := by native_decide

theorem det_B₂B₃ : Matrix.det (berggrenB₂ * berggrenB₃) = -1 := by native_decide

/-- The Lorentz form is preserved by products of Berggren matrices. -/
theorem berggren_product_lorentz (M N : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * berggren_Q * M = berggren_Q)
    (hN : Nᵀ * berggren_Q * N = berggren_Q) :
    (M * N)ᵀ * berggren_Q * (M * N) = berggren_Q := by
  rw [Matrix.transpose_mul]
  have : Nᵀ * Mᵀ * berggren_Q * (M * N) = Nᵀ * (Mᵀ * berggren_Q * M) * N := by
    simp [Matrix.mul_assoc]
  rw [this, hM, hN]

/-- The mixing time of a random walk on a graph with n vertices and spectral gap γ
is O(log(n)/γ). -/
noncomputable def berggrenMixingTime (depth : ℕ) : ℝ :=
  Real.log ((3 ^ (depth + 1) - 1 : ℝ) / 2) / spectralGap3

/-- The Cheeger constant lower bound for a d-regular graph with spectral gap γ:
h(G) ≥ γ/2 (Cheeger inequality, easy direction). -/
noncomputable def cheegerBound3 : ℝ := spectralGap3 / 2

/-- The Cheeger bound is positive. -/
theorem cheegerBound3_pos : cheegerBound3 > 0 := by
  exact div_pos spectralGap3_pos (by positivity)

/-- The Ihara parameter q for a 3-regular graph. -/
theorem ihara_q_three : (3 : ℕ) - 1 = 2 := by norm_num

/-- The Ihara parameter q for a 4-regular graph. -/
theorem ihara_q_four : (4 : ℕ) - 1 = 3 := by norm_num

/-- 2√2 is approximately 2.828. We verify (2√2)² = 8. -/
theorem two_sqrt_two_sq : (2 * Real.sqrt 2) ^ 2 = 8 := ramanujanBound_three_sq

/-- 2√3 is approximately 3.464. We verify (2√3)² = 12. -/
theorem two_sqrt_three_sq : (2 * Real.sqrt 3) ^ 2 = 12 := ramanujanBound_four_sq

/-- The spectral gap for 3-regular: (3 - 2√2)² = 17 - 12√2.
We verify this algebraically. -/
theorem spectralGap3_sq : spectralGap3 ^ 2 = 17 - 12 * Real.sqrt 2 := by
  unfold spectralGap3
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  nlinarith [sq_nonneg (3 - 2 * Real.sqrt 2)]

/-- The inverse Berggren steps are well-defined since all matrices are in GL(3,ℤ). -/
theorem berggrenStep_injective (d : BDir) :
    Function.Injective (berggrenStep d) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  cases d <;> {
    simp only [berggrenStep, Prod.mk.injEq] at h
    obtain ⟨h1, h2, h3⟩ := h
    ext <;> linarith
  }

end
