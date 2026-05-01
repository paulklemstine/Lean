import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenCantorBoundary

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 24
-/

/-- The boundary: infinite sequences of steps {A=0, B=1, C=2} -/
abbrev BerggrenBoundary := ℕ → Fin 3

/-- [Section: ## Section 1: The Berggren Boundary Space] -/
instance berggrenBoundary_topSpace : TopologicalSpace BerggrenBoundary := Pi.topologicalSpace

theorem berggrenBoundary_compact : IsCompact (Set.univ : Set BerggrenBoundary) :=
  isCompact_univ

/-- A cylinder set: all paths agreeing on a finite prefix -/
def cylinder (prefix_ : List (Fin 3)) : Set BerggrenBoundary :=
  {f | ∀ (i : ℕ) (hi : i < prefix_.length), f i = prefix_[i]}

/-- [Section: ## Section 2: Cylinder Sets] -/
theorem cylinder_nil : cylinder [] = Set.univ := by simp [cylinder]

/-- [Section: ## Section 3: Truncation] -/
def truncate (n : ℕ) (f : BerggrenBoundary) : List (Fin 3) :=
  (List.finRange n).map (fun i => f i)

theorem truncate_zero (f : BerggrenBoundary) : truncate 0 f = [] := by simp [truncate]

theorem truncate_length (n : ℕ) (f : BerggrenBoundary) : (truncate n f).length = n := by
  simp [truncate]

/-- [Section: ## Section 4: Berggren Steps as Fin 3] -/
def stepToFin3 : Fin 3 → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0 => fun t => (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)
  | 1 => fun t => (t.1 + 2*t.2.1 + 2*t.2.2, 2*t.1 + t.2.1 + 2*t.2.2, 2*t.1 + 2*t.2.1 + 3*t.2.2)
  | 2 => fun t => (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

def applyFinPath (path : List (Fin 3)) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => stepToFin3 s t) (3, 4, 5)

theorem applyFinPath_nil : applyFinPath [] = (3, 4, 5) := rfl

/-- [Section: ## Section 5: Hypotenuse Sequence] -/
def hypSequence (f : BerggrenBoundary) (n : ℕ) : ℤ :=
  (applyFinPath (truncate n f)).2.2

theorem hypSequence_zero (f : BerggrenBoundary) : hypSequence f 0 = 5 := by
  simp [hypSequence, truncate, applyFinPath]

/-- [Section: ## Section 6: Cardinality] -/
theorem nodes_at_depth (n : ℕ) :
    Fintype.card (Fin n → Fin 3) = 3 ^ n := by simp

/-- Encode steps as sign pairs: A→(+,−), B→(+,+), C→(−,+) -/
def sigmaEncoding : Fin 3 → Bool × Bool
  | 0 => (true, false)   -- A: σ₁ > 0, σ₂ < 0
  | 1 => (true, true)    -- B: σ₁ > 0, σ₂ > 0
  | 2 => (false, true)   -- C: σ₁ < 0, σ₂ > 0

/-- [Section: ## Section 7: Sigma-Sign Encoding] -/
theorem sigmaEncoding_injective : Function.Injective sigmaEncoding := by
  intro a b h; fin_cases a <;> fin_cases b <;> simp_all [sigmaEncoding]

/-- (false, false) is the forbidden pattern -/
theorem sigmaEncoding_no_ff (s : Fin 3) : sigmaEncoding s ≠ (false, false) := by
  fin_cases s <;> simp [sigmaEncoding]

/-- [Section: ## Section 8: Shift Map (Symbolic Dynamics)] -/
def berggrenShift (f : BerggrenBoundary) : BerggrenBoundary := fun n => f (n + 1)

theorem berggrenShift_continuous : Continuous berggrenShift := by
  apply continuous_pi; intro n; exact continuous_apply (n + 1)

theorem berggrenShift_surjective : Function.Surjective berggrenShift := by
  intro g; exact ⟨fun n => match n with | 0 => 0 | n + 1 => g n, funext (fun _ => rfl)⟩

/-- [Section: ## Section 9: Fixed Points] -/
theorem shift_const_fixed (c : Fin 3) :
    berggrenShift (fun _ => c) = (fun _ => c) := by
  funext n; simp [berggrenShift]

theorem const_sequences_card : Fintype.card (Fin 3) = 3 := by simp

/-- [Section: ## Section 10: Continuity of Projections] -/
theorem coord_continuous (n : ℕ) : Continuous (fun (f : BerggrenBoundary) => f n) :=
  continuous_apply n

/-- The boundary is a product of copies of Fin 3 -/
theorem boundary_eq_product : BerggrenBoundary = (ℕ → Fin 3) := rfl