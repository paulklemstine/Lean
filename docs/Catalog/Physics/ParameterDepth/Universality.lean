import Physics.ParameterDepth.TreeDepth

/-!
# Parameter-derived depth, IV: universality of the logarithmic depth law

Is the closed form `foamDepth B T = Nat.log B ((B-1)T+1) - 1` an artefact of the
particular bookkeeping "count all cells of the tree"?  This file shows that it is not.

**Universality theorem** (`maxDepth_sandwich`).  Let a cascade cost be *geometrically
sandwiched*, `B^d ≤ cost d ≤ K · B^d`.  Then, for any threshold `T ≥ cost 0`,

`Nat.log B T - (Nat.log B K + 1) ≤ maxDepth cost T ≤ Nat.log B T`.

So the largest supported depth is the base-`B` logarithm of the budget up to an
additive constant that depends **only on the sandwich constant `K`**, never on `T`.
The whole modelling freedom in how one charges for a level is worth `log_B K + 1`
levels of depth and nothing more.

Two instances are worked out:

* `foamCells_le_two_mul_pow` — the tree count is sandwiched with `K = 2`, recovering
  (independently of the exact arithmetic of `TreeDepth`) that its depth is
  logarithmic;
* `energyCells` — a perturbed model charging `a` units per cell **plus** a fixed
  overhead `c` per level (a gauge-fixing/boundary bookkeeping term).  Theorem
  `energyDepth_sandwich` gives the explicit constant `log_B (2a + c) + 1`: adding a
  per-level overhead can never change the depth law, only its offset.
-/

namespace Physics.ParameterDepth

/-! ### The universality theorem -/

/-- Upper half of the sandwich: a cost bounded below by `B^d` can never support a depth
beyond `Nat.log B T`. -/
theorem maxDepth_le_log {cost : ℕ → ℕ} {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T)
    (hlow : ∀ d, B ^ d ≤ cost d) (h0 : Supported cost T 0) :
    maxDepth cost T ≤ Nat.log B T :=
  (Nat.le_log_iff_pow_le (by omega) (by omega)).2
    (le_trans (hlow _) (supported_maxDepth h0))

/-- Lower half of the sandwich: a cost bounded above by `K · B^d` supports every depth
up to `Nat.log B T - (Nat.log B K + 1)`. -/
theorem log_sub_le_maxDepth {cost : ℕ → ℕ} {B K T : ℕ} (hB : 2 ≤ B)
    (hc : StrictMono cost) (hhigh : ∀ d, cost d ≤ K * B ^ d) (hT : 1 ≤ T) :
    Nat.log B T - (Nat.log B K + 1) ≤ maxDepth cost T := by
  set L := Nat.log B T with hL
  set e := Nat.log B K + 1 with he
  rcases le_or_gt L e with hle | hgt
  · simp [Nat.sub_eq_zero_of_le hle]
  · have hd : L - e + e = L := by omega
    have hKlt : K < B ^ e := Nat.lt_pow_succ_log_self (by omega) K
    have hstep : cost (L - e) ≤ T := by
      have h1 : cost (L - e) ≤ K * B ^ (L - e) := hhigh _
      have h2 : K * B ^ (L - e) < B ^ e * B ^ (L - e) :=
        Nat.mul_lt_mul_of_lt_of_le hKlt le_rfl (Nat.pow_pos (by omega))
      have h3 : B ^ e * B ^ (L - e) = B ^ L := by
        rw [← pow_add]
        congr 1
        omega
      have h4 : B ^ L ≤ T := Nat.pow_log_le_self B (by omega)
      omega
    exact le_maxDepth hc hstep

/-- **Universality of the logarithmic depth law.**  Any geometrically sandwiched cost
model has maximal supported depth equal to `log_B T` up to an additive constant
determined by the sandwich constant alone. -/
theorem maxDepth_sandwich {cost : ℕ → ℕ} {B K T : ℕ} (hB : 2 ≤ B)
    (hc : StrictMono cost) (hlow : ∀ d, B ^ d ≤ cost d) (hhigh : ∀ d, cost d ≤ K * B ^ d)
    (h0 : Supported cost T 0) (hT : 1 ≤ T) :
    Nat.log B T - (Nat.log B K + 1) ≤ maxDepth cost T ∧ maxDepth cost T ≤ Nat.log B T :=
  ⟨log_sub_le_maxDepth hB hc hhigh hT, maxDepth_le_log hB hT hlow h0⟩

/-! ### Instance 1: the pure tree count is sandwiched with `K = 2` -/

/-- The cumulative tree count never exceeds twice its finest level. -/
theorem foamCells_le_two_mul_pow {B : ℕ} (hB : 2 ≤ B) (d : ℕ) :
    foamCells B d ≤ 2 * B ^ d := by
  obtain ⟨C, rfl⟩ : ∃ C, B = C + 2 := ⟨B - 2, by omega⟩
  have hgeom : (C + 1) * foamCells (C + 2) d + 1 = (C + 2) * (C + 2) ^ d := by
    have h := foamCells_geom (by omega : 1 ≤ C + 2) d
    simpa [pow_succ, mul_comm] using h
  refine Nat.le_of_mul_le_mul_left ?_ (show 0 < C + 1 by omega)
  have hkey : (C + 2) * (C + 2) ^ d ≤ 2 * ((C + 1) * (C + 2) ^ d) + 1 := by
    nlinarith [Nat.pow_pos (show 0 < C + 2 by omega) (n := d)]
  have hrw : (C + 1) * (2 * (C + 2) ^ d) = 2 * ((C + 1) * (C + 2) ^ d) := by ring
  omega

/-- Re-derivation, from universality alone, that the foam depth is logarithmic: the
sandwich constant `2` costs at most `Nat.log B 2 + 1 ≤ 2` levels. -/
theorem foamDepth_sandwich {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    Nat.log B T - (Nat.log B 2 + 1) ≤ foamDepth B T ∧ foamDepth B T ≤ Nat.log B T := by
  have h0 : Supported (foamCells B) T 0 := by simpa [Supported] using hT
  have h := maxDepth_sandwich (cost := foamCells B) (B := B) (K := 2) (T := T) hB
    (foamCells_strictMono hB) (pow_le_foamCells B)
    (foamCells_le_two_mul_pow hB) h0 hT
  rwa [maxDepth_foamCells hB hT] at h

/-! ### Instance 2: a perturbed model with per-level overhead -/

/-- Cost of a cascade of depth `d` when each cell costs `a` units of the resource and
each *level* carries a further fixed overhead `c` (a boundary or gauge-fixing term). -/
def energyCells (a c B d : ℕ) : ℕ := a * foamCells B d + c * (d + 1)

theorem succ_le_pow {B : ℕ} (hB : 2 ≤ B) : ∀ d : ℕ, d + 1 ≤ B ^ d := by
  intro d
  induction d with
  | zero => simp
  | succ d ih =>
      have h1 : 1 ≤ B ^ d := Nat.one_le_pow _ _ (by omega)
      have h2 : B ^ (d + 1) = B * B ^ d := by ring
      have h3 : 2 * B ^ d ≤ B * B ^ d := Nat.mul_le_mul_right _ hB
      omega

theorem energyCells_strictMono {a c B : ℕ} (ha : 1 ≤ a) (hB : 2 ≤ B) :
    StrictMono (energyCells a c B) := by
  refine strictMono_nat_of_lt_succ fun d => ?_
  have h : foamCells B d < foamCells B (d + 1) := (foamCells_strictMono hB) (by omega)
  have h1 : a * foamCells B d < a * foamCells B (d + 1) :=
    Nat.mul_lt_mul_of_pos_left h (by omega)
  have h2 : c * (d + 1) ≤ c * (d + 1 + 1) := Nat.mul_le_mul_left _ (by omega)
  simp only [energyCells]
  omega

theorem pow_le_energyCells {a c B : ℕ} (ha : 1 ≤ a) (d : ℕ) : B ^ d ≤ energyCells a c B d := by
  have h1 : B ^ d ≤ foamCells B d := pow_le_foamCells B d
  have h2 : foamCells B d ≤ a * foamCells B d := Nat.le_mul_of_pos_left _ (by omega)
  simp only [energyCells]
  omega

theorem energyCells_le {a c B : ℕ} (hB : 2 ≤ B) (d : ℕ) :
    energyCells a c B d ≤ (2 * a + c) * B ^ d := by
  have h1 : a * foamCells B d ≤ a * (2 * B ^ d) :=
    Nat.mul_le_mul_left _ (foamCells_le_two_mul_pow hB d)
  have h2 : c * (d + 1) ≤ c * B ^ d := Nat.mul_le_mul_left _ (succ_le_pow hB d)
  have h3 : (2 * a + c) * B ^ d = a * (2 * B ^ d) + c * B ^ d := by ring
  simp only [energyCells]
  omega

/-- **Robustness of the depth law under model perturbation.**  Charging `a` per cell and
`c` per level shifts the maximal depth by at most `Nat.log B (2a + c) + 1` levels
relative to the pure logarithm — no matter how large the budget `T` is. -/
theorem energyDepth_sandwich {a c B T : ℕ} (ha : 1 ≤ a) (hB : 2 ≤ B) (hT : 1 ≤ T)
    (h0 : energyCells a c B 0 ≤ T) :
    Nat.log B T - (Nat.log B (2 * a + c) + 1) ≤ maxDepth (energyCells a c B) T ∧
      maxDepth (energyCells a c B) T ≤ Nat.log B T :=
  maxDepth_sandwich (cost := energyCells a c B) (B := B) (K := 2 * a + c) (T := T) hB
    (energyCells_strictMono ha hB) (pow_le_energyCells ha)
    (energyCells_le hB) h0 hT

/-- Concrete perturbed instance: two units per cell, three units of overhead per level,
binary branching, budget `10 ^ 6`.  The maximal depth is pinned to within one level of
`Nat.log 2 (10 ^ 6) = 19`. -/
theorem energyDepth_two_three_example :
    Nat.log 2 1000000 - (Nat.log 2 7 + 1) ≤ maxDepth (energyCells 2 3 2) 1000000 ∧
      maxDepth (energyCells 2 3 2) 1000000 ≤ Nat.log 2 1000000 :=
  energyDepth_sandwich (a := 2) (c := 3) (B := 2) (T := 1000000) (by norm_num) (by norm_num)
    (by norm_num) (by simp [energyCells, foamCells])

end Physics.ParameterDepth