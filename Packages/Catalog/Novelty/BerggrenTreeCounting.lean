import Novelty.BerggrenTreeSilverGrowth
import Novelty.BerggrenTreeCriticalLine

/-!
# Counting Berggren nodes below a height: the silver exponent as a lower bound

Let `N(H) = #{ w : c(w) ≤ H }` be the number of nodes of the Berggren tree whose hypotenuse
is at most `H`.  This file proves the two-sided estimate

* `nodesBelow_ncard_le` : `N(H) ≤ (⌊√H⌋ + 1)²`, so `N(H) = O(H)` — a consequence of the
  seed injectivity of `Novelty.BerggrenTreeZetaCore`, since a node with `c(w) = m²+n² ≤ H`
  has both Euclid parameters in `[0, √H]`;
* `silver_count_lower` / `count_ge_silver_rpow` : `N(H) ≥ 3^d` whenever `5(3+2√2)^d ≤ H`,
  hence `N(H) ≥ (1/3)·(H/5)^{σ₀}` with `σ₀ = log 3 / (2 log(1+√2))` the *silver abscissa*
  of `Novelty.BerggrenTreeCriticalLine`.

Together with `silverAbscissa_lt_one` this pins down the role of the silver exponent
exactly: the silver value `σ₀ ≈ 0.6237` is the growth exponent of the **depth-graded**
(purely exponential) model of the tree, and it is a genuine *lower* bound for the counting
function, but it is strictly smaller than the true abscissa of convergence `1` computed in
`Novelty.BerggrenTreeZetaAbscissa`.  The gap between `H^{σ₀}` and `H` is produced by the
polynomially growing outer spines (`Lspine_hyp`, `Rspine_hyp`), which contribute nodes far
below the silver speed limit.

## Lab notes (computed with `#eval` on the definitions of this development)

| `H`   | nodes with `c(w) ≤ H` | `(⌊√H⌋+1)²` | largest `d` with `5(3+2√2)^d ≤ H` | `3^d` |
|-------|----------------------|--------------|-----------------------------------|-------|
| 5     | 1                    | 9            | 0                                 | 1     |
| 50    | 7                    | 64           | 1                                 | 3     |
| 200   | 32                   | 225          | 2                                 | 9     |
| 1000  | 158                  | 1024         | 3                                 | 27    |

The counts (1, 7, 32, 158) — obtained by enumerating the admissible Euclid seeds `(m,n)`
with `m²+n² ≤ H`, which by `seedEquiv` is exactly the node count — confirm both bounds and
show that the truth sits strictly between `3^d ≍ H^{σ₀}` and `(√H+1)²`, in line with the
abscissa-`1` theorem (the counts grow essentially linearly in `H`).
-/

namespace BerggrenZeta

open Real

/-- The set of tree nodes whose hypotenuse is at most `H`. -/
def nodesBelow (H : ℕ) : Set (List (Fin 3)) := {w | hyp w ≤ H}

/-- A node below height `H` has both Euclid parameters at most `√H`. -/
theorem seed_le_sqrt {H : ℕ} {w : List (Fin 3)} (hw : w ∈ nodesBelow H) :
    (seed w).1 ≤ Nat.sqrt H ∧ (seed w).2 ≤ Nat.sqrt H := by
  have h : (seed w).1 ^ 2 + (seed w).2 ^ 2 ≤ H := hw
  constructor
  · exact Nat.le_sqrt'.2 (le_trans (Nat.le_add_right _ _) h)
  · exact Nat.le_sqrt'.2 (le_trans (Nat.le_add_left _ _) h)

/-- The box of admissible seeds for nodes below height `H`. -/
private def seedBox (H : ℕ) : Finset (ℕ × ℕ) :=
  Finset.range (Nat.sqrt H + 1) ×ˢ Finset.range (Nat.sqrt H + 1)

private theorem seed_image_subset (H : ℕ) :
    seed '' nodesBelow H ⊆ (seedBox H : Set (ℕ × ℕ)) := by
  rintro p ⟨w, hw, rfl⟩
  obtain ⟨h1, h2⟩ := seed_le_sqrt hw
  simp only [seedBox, Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_range]
  exact ⟨Nat.lt_succ_of_le h1, Nat.lt_succ_of_le h2⟩

/-- Only finitely many nodes lie below a given height. -/
theorem nodesBelow_finite (H : ℕ) : (nodesBelow H).Finite := by
  refine Set.Finite.of_finite_image ?_ (seed_injective.injOn)
  exact Set.Finite.subset (seedBox H).finite_toSet (seed_image_subset H)

/-- **Linear upper bound for the node-counting function.**
`N(H) = #{w : c(w) ≤ H} ≤ (⌊√H⌋+1)²`, so `N(H) = O(H)`. -/
theorem nodesBelow_ncard_le (H : ℕ) :
    (nodesBelow H).ncard ≤ (Nat.sqrt H + 1) ^ 2 := by
  have h1 : (seed '' nodesBelow H).ncard = (nodesBelow H).ncard :=
    Set.ncard_image_of_injective _ seed_injective
  have h2 : (seed '' nodesBelow H).ncard ≤ ((seedBox H : Finset (ℕ × ℕ)) : Set (ℕ × ℕ)).ncard :=
    Set.ncard_le_ncard (seed_image_subset H) (seedBox H).finite_toSet
  rw [h1] at h2
  refine h2.trans ?_
  rw [Set.ncard_coe_finset]
  simp [seedBox, Finset.card_product, pow_two]

/-! ## Lower bound: the depth-`d` slice -/

/-- All `3^d` words of length `d` are nodes below the silver height `5(3+2√2)^d`. -/
theorem ofFn_mem_nodesBelow {d H : ℕ} (h : 5 * (3 + 2 * Real.sqrt 2) ^ d ≤ (H : ℝ))
    (f : Fin d → Fin 3) : List.ofFn f ∈ nodesBelow H := by
  have hlen : (List.ofFn f).length = d := List.length_ofFn
  have hle : (hyp (List.ofFn f) : ℝ) ≤ 5 * (3 + 2 * Real.sqrt 2) ^ d := by
    have := hyp_le_silver_pow (List.ofFn f)
    rwa [hlen] at this
  have : (hyp (List.ofFn f) : ℝ) ≤ (H : ℝ) := hle.trans h
  exact_mod_cast this

/-- **Exponential lower bound for the node-counting function.**
If the silver height at depth `d` fits below `H`, then at least `3^d` nodes lie below `H`. -/
theorem silver_count_lower {d H : ℕ} (h : 5 * (3 + 2 * Real.sqrt 2) ^ d ≤ (H : ℝ)) :
    3 ^ d ≤ (nodesBelow H).ncard := by
  have hsub : (fun f : Fin d → Fin 3 => List.ofFn f) '' Set.univ ⊆ nodesBelow H := by
    rintro w ⟨f, -, rfl⟩
    exact ofFn_mem_nodesBelow h f
  have hcard : ((fun f : Fin d → Fin 3 => List.ofFn f) '' Set.univ).ncard = 3 ^ d := by
    rw [Set.ncard_image_of_injective _ List.ofFn_injective, Set.ncard_univ]
    simp
  calc 3 ^ d = ((fun f : Fin d → Fin 3 => List.ofFn f) '' Set.univ).ncard := hcard.symm
    _ ≤ (nodesBelow H).ncard := Set.ncard_le_ncard hsub (nodesBelow_finite H)

/-! ## The silver exponent as a counting exponent -/

private theorem silver_sq_gt_one : (1 : ℝ) < 3 + 2 * Real.sqrt 2 := by
  have := Real.sqrt_nonneg 2
  linarith

private theorem log_silver_sq :
    Real.log (3 + 2 * Real.sqrt 2) = 2 * Real.log silverUnit := by
  have h : (3 : ℝ) + 2 * Real.sqrt 2 = silverUnit ^ 2 := (silverUnit_sq).symm
  rw [h, Real.log_pow]
  push_cast
  ring

/-- **The silver exponent is a counting exponent.**
For `H ≥ 5` the number of Berggren nodes with hypotenuse at most `H` is at least
`(1/3)·(H/5)^{σ₀}`, where `σ₀ = log 3 / (2 log(1+√2))` is the silver abscissa.
Combined with `nodesBelow_ncard_le` (`N(H) = O(H)`) and `silverAbscissa_lt_one`, this shows
the silver value is a genuine lower growth exponent but not the true one. -/
theorem count_ge_silver_rpow {H : ℕ} (hH : 5 ≤ H) :
    (1 / 3 : ℝ) * ((H : ℝ) / 5) ^ silverAbscissa ≤ ((nodesBelow H).ncard : ℝ) := by
  set A : ℝ := 3 + 2 * Real.sqrt 2 with hA
  have hA1 : (1 : ℝ) < A := silver_sq_gt_one
  have hApos : (0 : ℝ) < A := by linarith
  have hlogA : 0 < Real.log A := Real.log_pos hA1
  have hH5 : (1 : ℝ) ≤ (H : ℝ) / 5 := by
    have : (5 : ℝ) ≤ (H : ℝ) := by exact_mod_cast hH
    linarith
  have hHpos : (0 : ℝ) < (H : ℝ) / 5 := by linarith
  have hlogH : 0 ≤ Real.log ((H : ℝ) / 5) := Real.log_nonneg hH5
  set L : ℝ := Real.log ((H : ℝ) / 5) / Real.log A with hL
  have hL0 : 0 ≤ L := div_nonneg hlogH hlogA.le
  set d : ℕ := ⌊L⌋₊ with hd
  have hdL : (d : ℝ) ≤ L := Nat.floor_le hL0
  have hLd : L < (d : ℝ) + 1 := Nat.lt_floor_add_one L
  -- the depth-`d` slice fits below `H`
  have hfit : 5 * A ^ d ≤ (H : ℝ) := by
    have h1 : (A : ℝ) ^ (d : ℝ) ≤ A ^ L := by
      exact (Real.rpow_le_rpow_left_iff hA1).2 hdL
    have h2 : (A : ℝ) ^ L = (H : ℝ) / 5 := by
      have hmul : Real.log A * L = Real.log ((H : ℝ) / 5) := by
        rw [hL]
        field_simp
      rw [Real.rpow_def_of_pos hApos, hmul, Real.exp_log hHpos]
    have h3 : (A : ℝ) ^ d ≤ (H : ℝ) / 5 := by
      rw [← Real.rpow_natCast A d]
      rw [h2] at h1
      exact h1
    linarith
  have hcount : (3 : ℝ) ^ d ≤ ((nodesBelow H).ncard : ℝ) := by
    have := silver_count_lower (d := d) (H := H) hfit
    exact_mod_cast this
  refine le_trans ?_ hcount
  -- `(1/3)(H/5)^{σ₀} ≤ 3^d`
  have hsig : silverAbscissa = Real.log 3 / Real.log A := by
    rw [silverAbscissa, log_silver_sq]
  have hkey : ((H : ℝ) / 5) ^ silverAbscissa = (3 : ℝ) ^ L := by
    rw [hsig, Real.rpow_def_of_pos hHpos, Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 3), hL]
    congr 1
    field_simp
  rw [hkey]
  have h1 : (3 : ℝ) ^ L ≤ 3 ^ ((d : ℝ) + 1) :=
    (Real.rpow_le_rpow_left_iff (by norm_num : (1:ℝ) < 3)).2 hLd.le
  have h2 : (3 : ℝ) ^ ((d : ℝ) + 1) = 3 * 3 ^ d := by
    rw [Real.rpow_add (by norm_num), Real.rpow_natCast]
    ring
  rw [h2] at h1
  linarith

end BerggrenZeta