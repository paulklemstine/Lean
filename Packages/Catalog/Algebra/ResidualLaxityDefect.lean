import Algebra.ResidualFamilyDepth

/-!
# The laxity defect of the residual certificate calculus

`Algebra.ParallelResidualBlocks.certificate_laxity_gap` exhibits one map that the
parallel-first certificate calculus certifies by `4` while its true (least) Lipschitz
constant is `2`.  Here we quantify the phenomenon for an architecture of width two and
arbitrary depth `d`.

For certificates `a j, b j` of the two branches at layer `j`:

* the **sharp gain** is `max (∏ j, (1 + a j)) (∏ j, (1 + b j))` — this is genuinely the
  least Lipschitz constant of the corresponding parallel pair of dilation stacks
  (`stack_isLeast_lipschitz`);
* the **coarse gain**, obtained by first certifying each *layer* as a parallel block
  (certificate `max (a j) (b j)`) and then composing serially, is
  `∏ j, max (1 + a j) (1 + b j)`.

`sharpGain_le_coarseGain` is the general laxity inequality, and
`alternating_gains` computes both sides for the alternating architecture
`a = (1,0,1,0,…)`, `b = (0,1,0,1,…)`: the sharp gain is `2^n`, the coarse gain is `4^n`.
Consequently the over-estimation factor `2^n` is **unbounded in the depth**
(`laxity_defect_unbounded`): layerwise max-then-compose certification of a residual
network is exponentially loose, even with all certificates in `{0, 1}`.
-/

open NNReal ResidualCert

namespace ParallelResidualBlocks

variable {a b : ℕ → ℝ≥0}

/-- Sharp gain of a width-two, depth-`d` residual architecture: the max over branches of
the product of the branch gains. -/
def sharpGain (a b : ℕ → ℝ≥0) (d : ℕ) : ℝ≥0 :=
  max (∏ j ∈ Finset.range d, (1 + a j)) (∏ j ∈ Finset.range d, (1 + b j))

/-- Coarse gain of the same architecture: certify each layer by the max rule first, then
compose the layer certificates serially. -/
def coarseGain (a b : ℕ → ℝ≥0) (d : ℕ) : ℝ≥0 :=
  ∏ j ∈ Finset.range d, max (1 + a j) (1 + b j)

/-- **Laxity inequality.**  The parallel-first certificate always dominates the sharp one. -/
theorem sharpGain_le_coarseGain (a b : ℕ → ℝ≥0) (d : ℕ) :
    sharpGain a b d ≤ coarseGain a b d := by
  refine max_le ?_ ?_ <;>
    exact Finset.prod_le_prod' fun j _ => by simp

/-! ### The sharp gain really is the least Lipschitz constant -/

/-- The depth-`d` stack of dilation blocks with certificates `a 0, …, a (d-1)`. -/
def stackMap (a : ℕ → ℝ≥0) : ℕ → ℝ → ℝ
  | 0 => id
  | (n + 1) => (dilationBlock (a n)).toFun ∘ stackMap a n

theorem stackMap_eq (a : ℕ → ℝ≥0) (d : ℕ) :
    stackMap a d = fun x : ℝ => ((∏ j ∈ Finset.range d, (1 + a j) : ℝ≥0) : ℝ) * x := by
  induction d with
  | zero => funext x; simp [stackMap]
  | succ n ih =>
      funext x
      simp only [stackMap, Function.comp_apply, ih, dilationBlock_toFun,
        Finset.prod_range_succ]
      push_cast
      ring

/-- **The sharp gain is attained.**  The parallel pair of the two dilation stacks has
least Lipschitz constant exactly `sharpGain a b d`. -/
theorem stack_isLeast_lipschitz (a b : ℕ → ℝ≥0) (d : ℕ) :
    IsLeast {L : ℝ≥0 | LipschitzWith L (Prod.map (stackMap a d) (stackMap b d))}
      (sharpGain a b d) := by
  rw [stackMap_eq, stackMap_eq]
  exact isLeast_lipschitz_prod_dilation _ _

/-! ### The alternating architecture -/

/-- Branch certificates of the alternating architecture: `1` on even layers. -/
def altA (j : ℕ) : ℝ≥0 := if j % 2 = 0 then 1 else 0

/-- Branch certificates of the alternating architecture: `1` on odd layers. -/
def altB (j : ℕ) : ℝ≥0 := if j % 2 = 0 then 0 else 1

theorem alt_prod (n : ℕ) :
    (∏ j ∈ Finset.range (2 * n), (1 + altA j)) = 2 ^ n ∧
      (∏ j ∈ Finset.range (2 * n), (1 + altB j)) = 2 ^ n := by
  induction n with
  | zero => simp
  | succ m ih =>
      have h2 : 2 * (m + 1) = (2 * m) + 1 + 1 := by ring
      have he : (2 * m) % 2 = 0 := by omega
      have ho : ((2 * m) + 1) % 2 = 1 := by omega
      constructor
      · rw [h2, Finset.prod_range_succ, Finset.prod_range_succ, ih.1]
        simp [altA, he, ho]
        ring
      · rw [h2, Finset.prod_range_succ, Finset.prod_range_succ, ih.2]
        simp [altB, he, ho]
        ring

theorem alt_coarse (n : ℕ) : coarseGain altA altB (2 * n) = 4 ^ n := by
  induction n with
  | zero => simp [coarseGain]
  | succ m ih =>
      have h2 : 2 * (m + 1) = (2 * m) + 1 + 1 := by ring
      have he : (2 * m) % 2 = 0 := by omega
      have ho : ((2 * m) + 1) % 2 = 1 := by omega
      rw [coarseGain, h2, Finset.prod_range_succ, Finset.prod_range_succ]
      rw [coarseGain] at ih
      rw [ih]
      simp [altA, altB, he, ho]
      ring

/-- **Exact gains of the alternating architecture.**  Sharp gain `2^n`, coarse gain `4^n`
at depth `2n`. -/
theorem alternating_gains (n : ℕ) :
    sharpGain altA altB (2 * n) = 2 ^ n ∧ coarseGain altA altB (2 * n) = 4 ^ n := by
  refine ⟨?_, alt_coarse n⟩
  rw [sharpGain, (alt_prod n).1, (alt_prod n).2, max_self]

/-- **The laxity defect is unbounded.**  For every factor `M` there is a depth at which the
parallel-first certificate exceeds the sharp Lipschitz constant by more than `M`, even
though all layer certificates lie in `{0, 1}`. -/
theorem laxity_defect_unbounded (M : ℝ≥0) :
    ∃ n : ℕ, M * sharpGain altA altB (2 * n) ≤ coarseGain altA altB (2 * n) := by
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt (R := ℝ≥0) M one_lt_two
  refine ⟨n, ?_⟩
  rw [(alternating_gains n).1, (alternating_gains n).2]
  calc M * 2 ^ n ≤ (2 : ℝ≥0) ^ n * 2 ^ n := by
        gcongr
    _ = 4 ^ n := by rw [← mul_pow]; norm_num

/-- Assembled statement: at depth `2n` the alternating architecture has *true* least
Lipschitz constant `2^n`, while the layerwise max-then-compose calculus certifies `4^n`. -/
theorem alternating_defect (n : ℕ) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map (stackMap altA (2 * n)) (stackMap altB (2 * n)))} (2 ^ n) ∧
      coarseGain altA altB (2 * n) = 4 ^ n := by
  refine ⟨?_, alt_coarse n⟩
  have h := stack_isLeast_lipschitz altA altB (2 * n)
  rwa [(alternating_gains n).1] at h

end ParallelResidualBlocks