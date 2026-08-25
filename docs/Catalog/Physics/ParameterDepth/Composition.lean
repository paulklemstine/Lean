import Physics.ParameterDepth.Universality

/-!
# Parameter-derived depth, V: composing subsystems

Two independent regions with information budgets `T₁` and `T₂` form a joint system whose
budget is the product `T₁ · T₂` (budgets are counts of distinguishable configurations, so
they *multiply*).  How does the maximal supported refinement depth behave under this
tensoring?

**Answer** (`foamDepth_tensor_bounds`): it is additive up to two levels,

`foamDepth B T₁ + foamDepth B T₂ ≤ foamDepth B (T₁ · T₂) ≤ foamDepth B T₁ + foamDepth B T₂ + 2`,

and both ends are attained (`foamDepth_tensor_gap_attained`, `foamDepth_tensor_additive_example`).

The mechanism is a pair of matching multiplicative inequalities for the cumulative cell
count, proved by induction from the geometric identity of `TreeDepth`:

* `foamCells_add_le_mul` : `S(x+y) ≤ S(x) · S(y)` — joining two cascades never wastes
  cells (superadditivity of depth);
* `foamCells_mul_le` : `S(x) · S(y) ≤ S(x+y+1)` — and it never gains more than one level
  per factor plus one (subadditivity up to `+2`).

A consequence for `n` identical subsystems (`foamDepth_pow_ge`) is that depth grows at
least linearly in the number of tensor factors: `n · foamDepth B T ≤ foamDepth B (T^n)`.
This is the discrete counterpart of extensivity of the holographic entropy budget.
-/

namespace Physics.ParameterDepth

/-- Every cascade fits inside a power one level deeper: `S x ≤ B^(x+1)`. -/
theorem foamCells_le_pow_succ {B : ℕ} (hB : 2 ≤ B) (x : ℕ) : foamCells B x ≤ B ^ (x + 1) := by
  have hgeom := foamCells_geom (by omega : 1 ≤ B) x
  have hle : foamCells B x ≤ (B - 1) * foamCells B x :=
    Nat.le_mul_of_pos_left _ (by omega)
  omega

/-- **Superadditivity of the cell count.**  Merging a depth-`x` and a depth-`y` cascade
costs no more than the product of their costs. -/
theorem foamCells_add_le_mul {B : ℕ} (x y : ℕ) :
    foamCells B (x + y) ≤ foamCells B x * foamCells B y := by
  induction y with
  | zero => simp
  | succ y ih =>
      have hsplit : B ^ (x + y + 1) = B ^ x * B ^ (y + 1) := by
        rw [← pow_add]; congr 1
      have h1 : B ^ x ≤ foamCells B x := pow_le_foamCells B x
      have h2 : B ^ x * B ^ (y + 1) ≤ foamCells B x * B ^ (y + 1) :=
        Nat.mul_le_mul_right _ h1
      have h3 : foamCells B x * foamCells B (y + 1)
          = foamCells B x * foamCells B y + foamCells B x * B ^ (y + 1) := by
        rw [foamCells_succ, Nat.mul_add]
      have h4 : foamCells B (x + (y + 1)) = foamCells B (x + y) + B ^ (x + y + 1) := by
        rw [show x + (y + 1) = (x + y) + 1 from rfl, foamCells_succ]
      omega

/-- **Subadditivity of the cell count.**  The product of two cascades never exceeds a
single cascade one level deeper than their sum. -/
theorem foamCells_mul_le {B : ℕ} (hB : 2 ≤ B) (x y : ℕ) :
    foamCells B x * foamCells B y ≤ foamCells B (x + y + 1) := by
  induction y with
  | zero =>
      have := (foamCells_strictMono hB).monotone (show x ≤ x + 0 + 1 by omega)
      simpa using this
  | succ y ih =>
      have hx : foamCells B x ≤ B ^ (x + 1) := foamCells_le_pow_succ hB x
      have h2 : foamCells B x * B ^ (y + 1) ≤ B ^ (x + 1) * B ^ (y + 1) :=
        Nat.mul_le_mul_right _ hx
      have hsplit : B ^ (x + 1) * B ^ (y + 1) = B ^ (x + (y + 1) + 1) := by
        rw [← pow_add]; congr 1; omega
      have h3 : foamCells B x * foamCells B (y + 1)
          = foamCells B x * foamCells B y + foamCells B x * B ^ (y + 1) := by
        rw [foamCells_succ, Nat.mul_add]
      have h4 : foamCells B (x + (y + 1) + 1)
          = foamCells B (x + y + 1) + B ^ (x + (y + 1) + 1) := by
        rw [show x + (y + 1) + 1 = (x + y + 1) + 1 from rfl, foamCells_succ]
      omega

/-- **Superadditivity of depth.**  Tensoring two budgets supports at least the sum of the
individual depths. -/
theorem foamDepth_superadditive {B T₁ T₂ : ℕ} (hB : 2 ≤ B) (h₁ : 1 ≤ T₁) (h₂ : 1 ≤ T₂) :
    foamDepth B T₁ + foamDepth B T₂ ≤ foamDepth B (T₁ * T₂) := by
  have hT : 1 ≤ T₁ * T₂ := Nat.one_le_iff_ne_zero.2 (by positivity)
  refine (foamCells_le_iff_le_foamDepth hB hT _).1 ?_
  calc foamCells B (foamDepth B T₁ + foamDepth B T₂)
      ≤ foamCells B (foamDepth B T₁) * foamCells B (foamDepth B T₂) :=
        foamCells_add_le_mul _ _
    _ ≤ T₁ * T₂ :=
        Nat.mul_le_mul (foamDepth_isGreatest hB h₁).1 (foamDepth_isGreatest hB h₂).1

/-- **Subadditivity of depth.**  Tensoring can buy at most two extra levels. -/
theorem foamDepth_mul_le {B T₁ T₂ : ℕ} (hB : 2 ≤ B) (h₁ : 1 ≤ T₁) (h₂ : 1 ≤ T₂) :
    foamDepth B (T₁ * T₂) ≤ foamDepth B T₁ + foamDepth B T₂ + 2 := by
  have hT : 1 ≤ T₁ * T₂ := Nat.one_le_iff_ne_zero.2 (by positivity)
  by_contra hcon
  push_neg at hcon
  -- the joint cascade of depth `d₁ + d₂ + 3` would fit
  have hfit : foamCells B (foamDepth B T₁ + foamDepth B T₂ + 3) ≤ T₁ * T₂ :=
    (foamCells_le_iff_le_foamDepth hB hT _).2 (by omega)
  -- but each factor is strictly below its own frontier
  have hb₁ : T₁ + 1 ≤ foamCells B (foamDepth B T₁ + 1) := by
    have := not_supported_succ_foamDepth hB h₁
    omega
  have hb₂ : T₂ + 1 ≤ foamCells B (foamDepth B T₂ + 1) := by
    have := not_supported_succ_foamDepth hB h₂
    omega
  have hprod : T₁ * T₂ < foamCells B (foamDepth B T₁ + 1) * foamCells B (foamDepth B T₂ + 1) := by
    calc T₁ * T₂ < (T₁ + 1) * (T₂ + 1) := by nlinarith
      _ ≤ foamCells B (foamDepth B T₁ + 1) * foamCells B (foamDepth B T₂ + 1) :=
          Nat.mul_le_mul hb₁ hb₂
  have hmul := foamCells_mul_le hB (foamDepth B T₁ + 1) (foamDepth B T₂ + 1)
  have hidx : foamDepth B T₁ + 1 + (foamDepth B T₂ + 1) + 1
      = foamDepth B T₁ + foamDepth B T₂ + 3 := by omega
  rw [hidx] at hmul
  omega

/-- **Depth is additive under tensoring, up to two levels.** -/
theorem foamDepth_tensor_bounds {B T₁ T₂ : ℕ} (hB : 2 ≤ B) (h₁ : 1 ≤ T₁) (h₂ : 1 ≤ T₂) :
    foamDepth B T₁ + foamDepth B T₂ ≤ foamDepth B (T₁ * T₂) ∧
      foamDepth B (T₁ * T₂) ≤ foamDepth B T₁ + foamDepth B T₂ + 2 :=
  ⟨foamDepth_superadditive hB h₁ h₂, foamDepth_mul_le hB h₁ h₂⟩

/-- **Extensivity.**  For `n` identical subsystems the depth grows at least linearly. -/
theorem foamDepth_pow_ge {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) (n : ℕ) :
    n * foamDepth B T ≤ foamDepth B (T ^ n) := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hTn : 1 ≤ T ^ n := Nat.one_le_pow _ _ (by omega)
      have hstep := foamDepth_superadditive (B := B) (T₁ := T ^ n) (T₂ := T) hB hTn hT
      have hpow : T ^ n * T = T ^ (n + 1) := by rw [pow_succ]
      rw [hpow] at hstep
      have : (n + 1) * foamDepth B T = n * foamDepth B T + foamDepth B T := by ring
      omega

/-! ### Sharpness of the two-level window -/

/-- The lower end is attained: budgets `7` and `7` (binary foam) compose additively,
`1 + 1 = 2`. -/
theorem foamDepth_tensor_additive_example :
    foamDepth 2 (7 * 7) = foamDepth 2 7 + foamDepth 2 7 := by
  have h7 : foamDepth 2 7 = 2 :=
    foamDepth_eq_of_frontier (by norm_num) (by norm_num)
      (by simp [foamCells, Finset.sum_range_succ]) (by simp [foamCells, Finset.sum_range_succ])
  have h49 : foamDepth 2 49 = 4 :=
    foamDepth_eq_of_frontier (by norm_num) (by norm_num)
      (by simp [foamCells, Finset.sum_range_succ]) (by simp [foamCells, Finset.sum_range_succ])
  norm_num [h7, h49]

/-- The upper end is attained: `foamDepth 2 5 = 1`, `foamDepth 2 13 = 2`, yet
`foamDepth 2 65 = 5 = 1 + 2 + 2`.  So the `+2` in `foamDepth_mul_le` cannot be improved. -/
theorem foamDepth_tensor_gap_attained :
    foamDepth 2 (5 * 13) = foamDepth 2 5 + foamDepth 2 13 + 2 := by
  have h5 : foamDepth 2 5 = 1 :=
    foamDepth_eq_of_frontier (by norm_num) (by norm_num)
      (by simp [foamCells, Finset.sum_range_succ]) (by simp [foamCells, Finset.sum_range_succ])
  have h13 : foamDepth 2 13 = 2 :=
    foamDepth_eq_of_frontier (by norm_num) (by norm_num)
      (by simp [foamCells, Finset.sum_range_succ]) (by simp [foamCells, Finset.sum_range_succ])
  have h65 : foamDepth 2 65 = 5 :=
    foamDepth_eq_of_frontier (by norm_num) (by norm_num)
      (by simp [foamCells, Finset.sum_range_succ]) (by simp [foamCells, Finset.sum_range_succ])
  norm_num [h5, h13, h65]

end Physics.ParameterDepth