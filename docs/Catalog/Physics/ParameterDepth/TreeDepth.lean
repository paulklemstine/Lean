import Physics.ParameterDepth.Core

/-!
# Parameter-derived depth, II: the maximal depth of a `B`-ary refinement cascade

Model.  Spacetime (or a lattice field, or a nested code) is refined recursively: every
cell of level `k` is split into `B` cells of level `k + 1`.  A cascade of depth `d`
therefore materialises

`foamCells B d = 1 + B + B² + ⋯ + B^d`

cells in total.  The physics supplies an **information threshold** `T`: a holographic /
Bekenstein-type bound on the number of distinguishable cells inside the region.  Depth
`d` is *supported* when `foamCells B d ≤ T`.

The point of this file is that the largest supported depth is not something to be read
off a table for one chosen numerical instance — it is a **closed-form function of the
parameters**,

`foamDepth B T = Nat.log B ((B - 1) * T + 1) - 1`,

and it is *maximal*: `foamDepth B T` is the greatest element of the support set
(`foamDepth_isGreatest`), it agrees with the abstract search of
`Physics.ParameterDepth.Core` (`maxDepth_foamCells`), and depth `foamDepth B T + 1`
provably overshoots the budget (`not_supported_succ_foamDepth`).

Further results:

* `foamCells_geom` — the exact finite-geometric identity `(B-1) · foamCells B d + 1 = B^{d+1}`
  which converts the cell budget into a pure power inequality;
* `leafDepth_isGreatest` — the naive "count only the finest level" model has maximal
  depth exactly `Nat.log B T`;
* `foamDepth_deficit` — the two models differ by at most one level:
  `Nat.log B T - 1 ≤ foamDepth B T ≤ Nat.log B T`, together with the exact criterion
  `foamDepth_eq_log_iff` for when the overhead of the coarse levels costs nothing;
* monotonicity in the threshold and antitonicity in the branching number;
* three fully computed instances (`foamDepth_two_thousand`, `foamDepth_three_hundred`,
  `foamDepth_ten_million`) each proved *maximal*, not merely exhibited.
-/

namespace Physics.ParameterDepth

open Finset

/-- Total number of cells of a `B`-ary refinement cascade carried down to depth `d`:
`1 + B + ⋯ + B^d`. -/
def foamCells (B d : ℕ) : ℕ := ∑ k ∈ range (d + 1), B ^ k

@[simp] theorem foamCells_zero (B : ℕ) : foamCells B 0 = 1 := by simp [foamCells]

theorem foamCells_succ (B d : ℕ) : foamCells B (d + 1) = foamCells B d + B ^ (d + 1) := by
  simp [foamCells, Finset.sum_range_succ]

/-- **Finite geometric identity.**  For `B ≥ 1` the cumulative cell count satisfies
`(B - 1) · foamCells B d + 1 = B^(d+1)`; this is the algebraic bridge that turns a
budget inequality into an inequality between powers. -/
theorem foamCells_geom {B : ℕ} (hB : 1 ≤ B) (d : ℕ) :
    (B - 1) * foamCells B d + 1 = B ^ (d + 1) := by
  obtain ⟨C, rfl⟩ : ∃ C, B = C + 1 := ⟨B - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  induction d with
  | zero => simp [foamCells]
  | succ d ih =>
      rw [foamCells_succ, Nat.mul_add]
      have : C * (C + 1) ^ (d + 1) + (C + 1) ^ (d + 1) = (C + 1) ^ (d + 1 + 1) := by ring
      omega

/-- The finest level alone already accounts for `B^d` cells. -/
theorem pow_le_foamCells (B d : ℕ) : B ^ d ≤ foamCells B d := by
  refine Finset.single_le_sum (f := fun k => B ^ k) (fun _ _ => Nat.zero_le _) ?_
  simp

/-- Deeper cascades are strictly more expensive (for a genuine branching `B ≥ 2`). -/
theorem foamCells_strictMono {B : ℕ} (hB : 2 ≤ B) : StrictMono (foamCells B) := by
  refine strictMono_nat_of_lt_succ fun d => ?_
  rw [foamCells_succ]
  have : 0 < B ^ (d + 1) := Nat.pow_pos (by omega)
  omega

theorem foamCells_mono_base {B B' : ℕ} (h : B ≤ B') (d : ℕ) :
    foamCells B d ≤ foamCells B' d :=
  Finset.sum_le_sum fun k _ => Nat.pow_le_pow_left h k

/-- The **parameter-derived depth**: the largest cascade depth supported by a
threshold of `T` cells with branching number `B`, in closed form. -/
def foamDepth (B T : ℕ) : ℕ := Nat.log B ((B - 1) * T + 1) - 1

/-- Budget inequality ⇄ power inequality. -/
theorem foamCells_le_iff_pow_le {B : ℕ} (hB : 2 ≤ B) (T d : ℕ) :
    foamCells B d ≤ T ↔ B ^ (d + 1) ≤ (B - 1) * T + 1 := by
  have hgeom := foamCells_geom (by omega : 1 ≤ B) d
  constructor
  · intro h
    have : (B - 1) * foamCells B d ≤ (B - 1) * T := Nat.mul_le_mul_left _ h
    omega
  · intro h
    rw [← hgeom] at h
    have hpos : 0 < B - 1 := by omega
    have := Nat.le_of_mul_le_mul_left (by omega : (B - 1) * foamCells B d ≤ (B - 1) * T) hpos
    exact this

private theorem one_le_log_aux {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    1 ≤ Nat.log B ((B - 1) * T + 1) := by
  have hle : B ^ 1 ≤ (B - 1) * T + 1 := by
    have : (B - 1) * 1 ≤ (B - 1) * T := Nat.mul_le_mul_left _ hT
    simp only [pow_one]
    omega
  exact (Nat.le_log_iff_pow_le (by omega) (by omega)).2 hle

/-- **Support characterisation.**  A depth is supported exactly when it does not exceed
the parameter-derived depth: the support set is the initial segment `[0, foamDepth B T]`. -/
theorem foamCells_le_iff_le_foamDepth {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) (d : ℕ) :
    foamCells B d ≤ T ↔ d ≤ foamDepth B T := by
  have hlog := one_le_log_aux hB hT
  rw [foamCells_le_iff_pow_le hB, foamDepth,
    ← Nat.le_log_iff_pow_le (by omega : 1 < B) (by omega : (B - 1) * T + 1 ≠ 0)]
  omega

/-- **Maximality.**  `foamDepth B T` is the greatest supported depth. -/
theorem foamDepth_isGreatest {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    IsGreatest {d | foamCells B d ≤ T} (foamDepth B T) :=
  ⟨(foamCells_le_iff_le_foamDepth hB hT _).2 le_rfl,
    fun _ hd => (foamCells_le_iff_le_foamDepth hB hT _).1 hd⟩

/-- One level deeper always breaks the budget. -/
theorem not_supported_succ_foamDepth {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    ¬ foamCells B (foamDepth B T + 1) ≤ T := by
  intro h
  have := (foamCells_le_iff_le_foamDepth hB hT _).1 h
  omega

/-- The closed form agrees with the abstract bounded search of the core layer. -/
theorem maxDepth_foamCells {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    maxDepth (foamCells B) T = foamDepth B T :=
  ((foamDepth_isGreatest hB hT).unique
      (isGreatest_maxDepth (foamCells_strictMono hB)
        (by simpa [Supported] using hT))).symm

/-- Uniqueness: any greatest supported depth *is* `foamDepth B T`. -/
theorem eq_foamDepth_of_isGreatest {B T d : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T)
    (h : IsGreatest {d | foamCells B d ≤ T} d) : d = foamDepth B T :=
  h.unique (foamDepth_isGreatest hB hT)

/-!
### The leaf-only model and the one-level deficit
-/

/-- If only the finest level is charged for (`B^d` leaves), the maximal supported depth
is exactly `Nat.log B T`. -/
theorem leafDepth_isGreatest {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    IsGreatest {d | B ^ d ≤ T} (Nat.log B T) :=
  ⟨Nat.pow_log_le_self B (by omega), fun _ hd =>
    (Nat.le_log_iff_pow_le (by omega) (by omega)).2 hd⟩

/-- **One-level deficit.**  Charging for all the coarse levels of the cascade, rather than
only for its leaves, costs at most a single level of depth. -/
theorem foamDepth_deficit {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    Nat.log B T - 1 ≤ foamDepth B T ∧ foamDepth B T ≤ Nat.log B T := by
  constructor
  · rcases Nat.eq_zero_or_pos (Nat.log B T) with hL | hL
    · simp [hL]
    · set L := Nat.log B T with hLdef
      have hpow : B ^ L ≤ T := Nat.pow_log_le_self B (by omega)
      have hgeom := foamCells_geom (by omega : 1 ≤ B) (L - 1)
      have hLsub : L - 1 + 1 = L := by omega
      rw [hLsub] at hgeom
      have hcell : foamCells B (L - 1) ≤ T := by
        have h1 : foamCells B (L - 1) ≤ (B - 1) * foamCells B (L - 1) :=
          Nat.le_mul_of_pos_left _ (by omega)
        omega
      exact (foamCells_le_iff_le_foamDepth hB hT _).1 hcell
  · have hcell : foamCells B (foamDepth B T) ≤ T := (foamDepth_isGreatest hB hT).1
    have hpow : B ^ foamDepth B T ≤ T := le_trans (pow_le_foamCells B _) hcell
    exact (leafDepth_isGreatest hB hT).2 hpow

/-- Exact criterion for a *lossless* cascade: the coarse levels cost no depth precisely
when the full tree of depth `Nat.log B T` still fits inside the threshold. -/
theorem foamDepth_eq_log_iff {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    foamDepth B T = Nat.log B T ↔ foamCells B (Nat.log B T) ≤ T := by
  constructor
  · intro h
    have := (foamDepth_isGreatest hB hT).1
    rwa [h] at this
  · intro h
    have h1 : Nat.log B T ≤ foamDepth B T := (foamCells_le_iff_le_foamDepth hB hT _).1 h
    exact le_antisymm (foamDepth_deficit hB hT).2 h1

/-!
### Parameter monotonicity
-/

/-- A larger information threshold supports at least as deep a cascade. -/
theorem foamDepth_mono_threshold {B T T' : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) (hle : T ≤ T') :
    foamDepth B T ≤ foamDepth B T' :=
  (foamCells_le_iff_le_foamDepth hB (le_trans hT hle) _).1
    (le_trans (foamDepth_isGreatest hB hT).1 hle)

/-- More branching per level means less depth for the same budget. -/
theorem foamDepth_antitone_base {B B' T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) (hle : B ≤ B') :
    foamDepth B' T ≤ foamDepth B T := by
  have hB' : 2 ≤ B' := le_trans hB hle
  refine (foamCells_le_iff_le_foamDepth hB hT _).1 ?_
  exact le_trans (foamCells_mono_base hle _) (foamDepth_isGreatest hB' hT).1

/-!
### Fully computed instances

Each instance is proved by pinning the *frontier*: the stated depth fits, the next one
does not.  Maximality is therefore part of the statement, not an afterthought.
-/

/-- Frontier certificate: a supported depth whose successor breaks the budget *is* the
parameter-derived depth. -/
theorem foamDepth_eq_of_frontier {B T d : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T)
    (hfit : foamCells B d ≤ T) (hbreak : ¬ foamCells B (d + 1) ≤ T) : foamDepth B T = d := by
  have h1 : d ≤ foamDepth B T := (foamCells_le_iff_le_foamDepth hB hT _).1 hfit
  by_contra hne
  have h2 : d + 1 ≤ foamDepth B T := by omega
  exact hbreak ((foamCells_le_iff_le_foamDepth hB hT _).2 h2)

/-- Binary foam under a budget of `1000` cells: maximal depth `8`
(`foamCells 2 8 = 511`, while `foamCells 2 9 = 1023`). -/
theorem foamDepth_two_thousand : foamDepth 2 1000 = 8 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

/-- Ternary foam under a budget of `100` cells: maximal depth `3`
(`foamCells 3 3 = 40`, while `foamCells 3 4 = 121`). -/
theorem foamDepth_three_hundred : foamDepth 3 100 = 3 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

/-- Decimal foam under a budget of one million cells: maximal depth `5`
(`foamCells 10 5 = 111111`, while `foamCells 10 6 = 1111111`). -/
theorem foamDepth_ten_million : foamDepth 10 1000000 = 5 := by
  refine foamDepth_eq_of_frontier (by norm_num) (by norm_num) ?_ ?_ <;>
    simp [foamCells, Finset.sum_range_succ]

/-- The computed instance really is the greatest supported depth, spelled out. -/
theorem foamDepth_two_thousand_isGreatest : IsGreatest {d | foamCells 2 d ≤ 1000} 8 := by
  have := foamDepth_isGreatest (B := 2) (T := 1000) (by norm_num) (by norm_num)
  rwa [foamDepth_two_thousand] at this

end Physics.ParameterDepth